# 编译期 GC 分析与释放插入手册

本文档描述 Cute 编译器在**编译期间**如何做 GC/所有权分析、如何决定释放点、以及代码生成在哪里插入释放。重点是当前实际生效的 **LLR（Local Lifetime/Release）** 路径；旧的 `gc/model.go` Object/Disposal 模型仍在代码库中，但出口释放以 `gc.LLRResults` 为准。

## 1. 总体流水线

入口：`gc/analyzeBackend(root *parser.Node)`，`gc/analyze.go`。

```text
AST(Check 完成)
  -> analyzeBackend
     -> collectFuncs: 收集所有 FuncBlock/body
     -> 初始化 FnSummary 骨架（owning 参数、owning 返回）
     -> 不动点迭代 analyzeBody: 构建函数摘要（escape/ret kind/heap alloc/any call）
     -> tightenParams: Jacobi 收紧参数摘要（避免单调提升后不回落）
     -> markFieldAliasStructs
     -> 对每个函数 ComputeLLR: 生成 LLRResult
     -> Table / LLRResults 落盘
  -> compile/compiler.go 编译函数时读取 gc.LLRResults[currentFuncKey]
     -> Prologue 预留 RetScratch 槽，入口清零出口槽
     -> 语句编译时插入 assign/cond/incr/ret/expr-temp/block/loop-exit frees
     -> Epilogue 在 func_end 后插入 emitGCFrees
```

核心全局表：

- `gc.Table map[string]*FnSummary`：函数摘要，键为函数全路径名。
- `gc.LLRResults map[string]*LLRResult`：每函数 LLR 结果。
- `compile/compiler.go:2271` `emitGCFrees` 读取 `gc.LLRResults[c.currentFuncKey]`。

## 2. 数据模型

### 2.1 FnSummary（`gc/summary.go`）

```go
type FnSummary struct {
    Name              string
    Params            []ParamSummary // 仅 owning 指针参数
    RetOwned          bool           // 返回类型携带 owning 指针
    RetEscape         Escape
    RetKind           RetKind        // Fresh/AliasParam/BorrowParam/Unknown/None
    RetAliasMask      uint64         // bit i: 可能返回第 i 个参数本身
    RetBorrowMask     uint64         // bit i: 可能返回第 i 个参数内部指针
    CallsAny          []string       // 无摘要/未知调用
    HasGlobalOwnStore bool           // 全局拥有存储
    HasHeapAllocs     bool           // 体内存在堆分配
}
```

`ParamSummary`：`Index, Mode, Escape`。

逃逸层级 `Escape`（`gc/model.go` 方向，按强度提升）：

- `EscNone`：不逃逸
- `EscCaller`：逃到调用者（返回、返回值别名）
- `EscHeapObj`：存入堆对象/字段/容器
- `EscGlobal`：存入全局
- `EscAny`：未知调用/保守

返回来源 `RetKind`：

- `RetFresh`：返回新分配/独占对象
- `RetAliasParam`：可能返回参数本身
- `RetBorrowParam`：可能返回参数内部指针
- `RetUnknown`：无法证明
- `RetNone`：不返回 owning

### 2.2 LLR 状态与结果（`gc/llr.go`）

`llrState` 是单函数前向扫描状态：

- `bindings map[string]ObjID`：变量名首段 -> 当前绑定对象
- `objEscaped/objRCAlloc/objShared/objReleased`：对象逃逸、RC 分配、共享、已覆盖释放
- `objSite/objScope/objBlockID/varBlockID`：分配来源、作用域深度、块 ID、变量声明块
- `orphans/fieldOrphans/poisonedFields`：无名孤儿、字段孤儿、不可 deep-drop 字段
- `scopeDepth/currentBlockID/nextBlockID/loopDepth`

`LLRResult` 包含所有释放计划：

- `Frees`：函数出口释放
- `FieldFrees`：字段级级联释放
- `BlockFreesMap`：块出口释放
- `LoopExitFrees`：for 出口释放（break 路径）
- `AssignFrees`：覆盖赋值前 freeSlot
- `AssignTempFreesMap/ExprTempFreesMap`：赋值右值/表达式临时释放
- `CondFreesMap/IncrFreesMap`：if/for 条件、for 增量临时释放
- `RetFrees/RetFreesMap`：return 节点临时释放
- `RetScratchSlots`：scratch 槽数上限
- `PoisonedFields`：字段值逃逸，deep drop 不可释放

## 3. 第一阶段：函数摘要分析（analyze.go）

### 3.1 初始化

`analyzeBackend`：

1. 清空 `Table/LLRResults`。
2. `collectFuncs` 收集所有函数。
3. 为每个 owning 参数创建 `ParamSummary{ModeRead,EscNone}`。
4. 若返回 owning 类型，先保守设 `RetOwned=true, RetEscape=EscCaller, RetKind=RetUnknown`。
5. 不动点迭代 `analyzeBody`，直到 `a.changed==false`。
6. `tightenParams()` 用快照 Jacobi 迭代收紧参数，避免早期 Unknown 污染后不回落。
7. 对每个函数跑 `ComputeLLR`。

### 3.2 analyzeBody 扫描规则

`analyzeBody(key, fb, body)` 遍历函数体节点：

- **ReturnBlock**：
  - 仅当返回类型 owning 时，返回表达式才传播参数逃逸。
  - `exprOwnership(rv)` 分析返回值来源：
    - `unknown`：表达式引用的 tracked params 全部 `bumpParam(EscCaller,OtherRef)`，`bumpRet(EscCaller)`。
    - 否则 alias/borrow mask 对应参数提升为 `EscCaller`；fresh 不提升参数。
    - fresh alloc 中嵌入的参数（`refsStoredInFreshAlloc`）提升为 `EscHeapObj`。
  - 表达式有分配则 `HasHeapAllocs=true`。
  - `walkExprCalls` 递归传播被调参数逃逸。

- **VarBlock 全局赋值**：`!IsDefine && IsGlobal && Value!=nil`
  - 来源 unknown：引用参数 `EscGlobal`。
  - 否则 alias/borrow mask 参数 `EscGlobal`。
  - 右值 owning 类型则设置 `HasGlobalOwnStore=true`（只影响本函数 LLR，不传播给调用者）。

- **VarBlock 字段写入**：`!IsDefine && len(Name)>1`
  - 右值 owning/未知类型时，右值引用的参数 `EscHeapObj`。容器参数本身不逃逸。

- **CallBlock**：`IsBuiltinNewAlloc()` -> `HasHeapAllocs`；`applyCallee`。

- **Expression 语句**：
  - `[]=/=/deref=` 存储值中 tracked params `EscHeapObj`（deref 的值在 Left）。
  - `scanExpr` 处理分配和调用传播。

- **IfBlock/ForBlock**：显式扫描 condition/init/increment/range；ElseBlock 显式 walk。

最后 `updateRetSummary`。

### 3.3 exprOwnership / localOwnership

`exprOwnership` 判断表达式返回值来源（fresh/alias/borrow/unknown）：

- `p`（参数首段，单段）-> alias bit。
- `p.field/p[i]` -> borrow bit。
- 单段局部变量 -> `localOwnership`。
- 非参数非局部/局部字段/元素 -> unknown。
- `new/make` 内建分配 -> fresh。
- 调用：查 callee summary；`RetFresh` fresh；`RetAliasParam/RetBorrowParam` 通过 `mapMaskThroughArgs` 映射到调用方参数，若映射空则可能是 fresh；`RetUnknown` unknown；混合路径保留 mask。
- 空字符串常量 -> fresh（nil buffer, free 安全）；非空字符串常量 -> unknown（静态标签，不能 free）。
- nil -> fresh。
- 字符串拼接 `+` string -> fresh。
- 复合表达式保守合并子表达式。

`localOwnership` 扫描局部变量所有初始化/直接赋值：任一赋值来自参数或 unknown，保留 mask/unknown。若局部变量被取地址 `bodyTakesAddrOfNode`，保守 unknown。

### 3.4 applyCallee / ParamEscapes

`applyCallee` 将被调摘要传播到调用方：

- raw allocator call -> `HasHeapAllocs`。
- 无摘要：`pureBuiltinEscapes` 纯内建跳过；否则 `CallsAny` 追加，调用方参数后续保守。
- 有摘要：对每个 callee param，若 escape>EscNone，取实参 `exprOwnership`；unknown 则实参 tracked params 全升；否则 alias/borrow mask 参数升到 callee escape/mode。简单字段访问 `p.f` 作为实参时，borrow 不提升基对象（字段值逃逸由 poisonedFields 处理）。
- 被调 `HasHeapAllocs` 传播给调用方。
- 递归扫描嵌套调用实参。

`ParamEscapes`：查 Table；无摘要时 `pureBuiltinEscapes` -> EscNone；`append` idx0 EscNone，其他 EscHeapObj；`copy` EscNone；默认 EscAny。

`pureBuiltinEscapes`：`len/cap/sizeof/print/println/panic/unsafe.cast` 和内建数值/bool/byte/ptr 类型转换为 EscNone。**这是关键**：cast 被误判为未知调用会导致 `CallsAny`，进而 LLR 早退。

### 3.5 exprAllocates

用于 HasHeapAllocs 和 LLR alloc 识别：

- `IsBuiltinNewAlloc` -> true
- `callSummary.RetOwned && (RetFresh || condTempFreeable)` -> true
- string `+`、`list_lit/map_lit/array_lit(owning)` -> true
- 递归子表达式/参数

### 3.6 tightenParams

Jacobi 收紧：快照 `Table` 作为 `calleeView`，重置 owning 参数为 EscNone/ModeRead，重跑 analyzeBody 至不动点。原因：第一轮单调提升可能因为 callee RetKind 从 Unknown 收紧为 Fresh 后不回落。

## 4. 第二阶段：LLR 语句级分析（llr.go）

`ComputeLLR(fnKey, fb, fs, body)`：

### 4.1 早退保守门槛

- `hasRealAnyCalls(fs.CallsAny)` -> 返回空结果（不自动释放）。
- `fs.HasGlobalOwnStore` -> 返回空结果。
- `!fs.HasHeapAllocs` -> 返回空结果。

### 4.2 初始化

- 为 owning 参数创建 param 对象：绑定名，`objEscaped=true`（调用者管理）。
- `scanStatements` 前向扫描。

### 4.3 scanStatements

按节点类型处理：

- **VarBlock**：`processAssign`。
- **Expression**：
  - `v.Var!=nil` 简单/字段赋值 -> `processAssign`。
  - `[]=/=/deref=`：标记 stored refs/escapes，收集子表达式临时，登记 `AssignTempFreesMap`。
  - 其他表达式：`collectExprTemps(...,allowFree=true,freeRoot=true)` -> `ExprTempFreesMap`。
  - `markExprCallArgs`。
- **ReturnBlock**：
  - 若 retOwns，`markAllReferencedObjs`（返回值引用的对象逃逸）。
  - 所有返回表达式 `markExprCallArgs`。
  - retOwns 且 call 返回 owning：创建 escaped call obj。
  - retOwns 且字段/元素 owning 返回：基对象逃逸。
- **CallBlock 语句**：`markCallArgObjs`，参数 `markExprCallArgs`，返回值临时作为 `ExprTempFreesMap`。
- **ForBlock**：标记 init/cond/incr/range 调用参数；init/range 只建对象不释放；cond 收集 `CondFreesMap`；incr 若非赋值收集 `IncrFreesMap`；进入 scope/loop，扫描 body，`collectBlockFrees` -> `BlockFreesMap`，退出后 `LoopExitFrees` 由 ComputeLLR 后处理。
- **IfBlock**：cond 收集 `CondFreesMap`；then/else 各自 scope/block frees。

### 4.4 processAssign 规则

1. 标记右值调用参数逃逸、stored refs；收集右值临时（freeRoot=false）。
2. `var x: *T` 无值 owning 定义 -> `null_init` 绑定，escaped=true（避免误 free）。
3. 字段赋值 `len(Name)>1`：右值对象 `objShared+objEscaped`，列表字面量元素 `markStoredEscapes`；若 alloc 且父对象帧内未逃逸，登记 `fieldOrphans`。
4. 定义 owning：alloc -> 新对象；裸变量别名 -> 共享绑定同对象；非分配 -> null_init escaped。
5. 非定义赋值：目标不是 tracked owning -> 忽略。refObj 是右值裸变量对象。
6. 全局目标：旧对象和右值对象 escaped。
7. 覆盖释放 `canOverwrite`：目标唯一、未共享、未逃逸、非 param/RC、site 可识别、右值不引用目标自身。循环内有特殊宽松（null_init/unknown/expr 且 alloc）。满足则 `st.objReleased[targetObj]=true`，登记 `AssignFrees`。
8. 右值 alloc -> 新绑定，旧对象若未释放/非param/非escaped 记 orphan。右值别名 -> 共享并绑定；若 refObj 在同块分配且块非0，标记 escaped 防止块尾释放后悬空。`append(xs,...)` self 保持绑定。其他 -> 旧对象 orphan，绑定 escaped null_init。

### 4.5 逃逸传播

- `markCallArgObjs`：按被调 `ParamEscapes` 传播。EscNone 跳过；否则实参表达式中裸变量绑定对象 `objEscaped=true`；字段访问标记 `poisonedFields[base.field]`。
- `markExprCallArgs`：递归遍历表达式所有调用点。
- `markAllReferencedObjs`：return 中引用的所有绑定对象 escaped；字段返回 poison 字段。
- `markStoredRefs/markStoredEscapes`：容器/字段存储使对象 shared/escaped，阻止覆盖释放。
- `getRefObj`：只识别裸单段变量引用。

### 4.6 临时释放

`collectExprTemps` 创建/登记 owning 临时：

- 只对 `RetOwned` 调用、runtime string concat、某些表达式分配。
- `freeRoot=false` 用于赋值/return，根值由变量/返回持有。
- `condTempFreeable(fs)` 判定是否可释放：RetFresh 或 RetUnknown 但有堆分配、无 alias/borrow mask、RetEscape < EscGlobal。参数逃逸不单独阻止，只要返回不 alias/borrow 参数。
- 不可释放时对象标记 escaped，避免误释放。
- 插入点：`CondFreesMap`(if/for cond), `IncrFreesMap`(for incr), `AssignTempFreesMap`, `ExprTempFreesMap`, `RetFreesMap`。

`collectRetFrees`：扫描 return 表达式，登记外层调用后可释放的嵌套 owning 临时。`callArgSafe` 要求被调 param EscNone 且 retAlias/borrow mask 未命中该 idx。

### 4.7 块/循环/出口释放

- `collectBlockFrees`：只释放本块声明的变量（`varBlockID==blockID`），对象未 escaped/released/param/RCAlloc，且有 mainName。
- `LoopExitFrees`：for 节点从 `BlockFreesMap` 拷贝，用于 break 跳过 body 尾释放后的 for_end 清理。
- `ComputeLLR` 末尾：汇总 frameOwn 对象生成 `Frees`；orphans 生成 heap-ptr frees；fieldOrphans 生成 `FieldFrees`（容器必须本帧释放）；`collectStructFieldFrees` 补齐 struct owning 字段级联。
- `RetScratchSlots` 取 ret/cond/incr/assign-temp/expr-temp 最大值，槽复用。

## 5. 代码生成插入点（compile/compiler.go 等）

### 5.1 函数级

`compileFuncBlock`：

- `llr := gc.LLRResults[c.currentFuncKey]` 设置 `RetScratchCap=llr.RetScratchSlots`。
- `Prologue` 预留栈，包括 scratch 槽。
- 若有出口 cleanup，`emitGCZeroExitSlots` 入口清零出口释放槽。原因：早退 ret 可能在变量初始化前跳到 func_end。
- 编译 body。
- `cleanup = emitGCFrees`（main/alias 跳过）。
- `Epilogue(funcBlock, cleanup)` 在 `func_end_<name>` 后、清栈前插入 cleanup。

### 5.2 出口释放 emitGCFrees

- 读 `llr.Frees` 和 `llr.FieldFrees`。
- 字段级释放：若父对象将 deep-drop 跳过；若 `PoisonedFields` 含字段跳过；读 `base.field` ptr，null 跳过；字段是可 deep-drop struct 时调用 drop，否则 `memory.free`。
- 顶层变量：有 dropLabel 用 deep drop，否则 `memory.freeSlot(&slot)`。`freeSlot` 接收槽地址，成功释放后清槽，幂等。

### 5.3 块/循环

- `emitGCZeroSlots`：进入 if/else/for 前清零该块将释放槽，避免零次执行或未走分支时 freeSlot 看到栈垃圾。
- `emitBlockFrees`：块尾调用 `BlockFreesMap`。
- `emitLoopExitFrees`：for_end 后按 `LoopExitFrees` 调用，覆盖 break。
- for continue 落点先 `emitBlockFrees`，再增量。

### 5.4 赋值/表达式

- `compileVarBlock`：先 `prepareScratchFrees(AssignTempFreesForNode)`，`emitAssignFrees`（覆盖赋值前 freeSlot），再 `VarDecl`，再执行 scratch frees。
- `compileExprBlock`：`[]=/=/deref=` 或 `.Var!=nil` 走 assign frees + scratch frees；普通表达式走 `ExprTempFreesForNode` scratch frees。
- `compileCallBlock`：语句级 call 后执行 `ExprTempFreesForNode` scratch frees。

### 5.5 条件/增量/return scratch frees

`scratchFreePlan` 通过 `Ctx.RetScratchMap/RetScratchExprMap` 登记 call/expression -> slot offset。

- **CondFrees**：if/for cond 先 prepare。若有 cond frees，编译条件为 false/true 两条清理路径，true/false 路径都执行 `plan.code`（freeSlot scratch 槽），再跳转对应分支。确保条件求值产生的临时在两条路径都释放。
- **IncrFrees**：for end 传入 `incrPlan.code`，在增量表达式求值后释放。
- **RetFrees**：`compileReturnBlock` 给 RetFrees 分配 scratch 槽，先生成返回值，再保存 RAX/RDX，逐个 freeSlot scratch 槽，恢复返回值，`ReturnJump`。

### 5.6 arch 捕获点

- `compile/arch/x86_64/linux_sysv.go:561`、`compile/arch/x86/cdecl.go:227`：call 返回后，若 `RetScratchMap[call]` 有槽，把 RAX/容器返回指针存入 `rbp+off`。
- `compile/exp/exp.go:2100`：字符串拼接等表达式结果若在 `RetScratchExprMap[exp]` 中，存入 scratch 槽。

这意味着：LLR 先“声明哪些临时需要释放”，编译器在表达式求值产出 owning 指针的时刻把它捕获到 scratch 槽，控制流到达清理点时统一 `freeSlot`。

## 6. 关键规则速查

### 6.1 能自动释放的前提

- 函数无真实 `CallsAny`。
- 函数无 `HasGlobalOwnStore`。
- 函数有 `HasHeapAllocs`（否则跳过）。
- 对象 frameOwn：未逃逸、未释放、非 param、非 RCAlloc。
- 覆盖释放：`canFreeOverwrite` + 右值不引用自身 + 非全局目标。
- 临时释放：`condTempFreeable` 或 RetFresh 且 callArgSafe/可证明独占。

### 6.2 必须保守不释放

- 参数对象、RCAlloc 对象。
- escaped/shared/released 对象。
- alias/borrow 返回可能复用参数。
- unknown call/cast 误判导致 CallsAny（应修纯化规则，不应放宽释放）。
- 全局存储、存入容器/字段、传给 EscHeapObj/EscGlobal/EscAny 参数。
- poisoned field：deep drop 不可释放字段值。

### 6.3 释放 API 选择

- 顶层出口槽：优先 deep drop label，否则 `memory.freeSlot(&slot)`。
- 字段级：field 若可 deep drop 调 drop，否则 `memory.free(ptr)`。
- scratch/assign/block：通常 `freeSlot(&slot)` 或 scratch slot。

## 7. 调试与观察

- `gc_summary.json` / summary dump：看 FnSummary，重点 `RetKind/RetAliasMask/RetBorrowMask/CallsAny/HasHeapAllocs/HasGlobalOwnStore`。
- `gc_llr.txt` / `DumpLLR`：看对象、Frees、Cond/Ret/Assign/Expr temp frees。
- 编译产物 asm 搜 `; gc:` 注释：确认插入点。
- `memory.dumpAllocator()` / `memory.trim()`：运行时 heap 视角，区分 leak 与 pin。

## 8. 常见故障模式

1. **纯内建被当未知调用**：`CallsAny` 非空 -> LLR 全函数禁用。检查 `pureBuiltinEscapes`/`ParamEscapes`。
2. **RetKind/AliasMask 过保守**：返回 fresh 值但摘要说 alias/unknown，调用方/临时无法释放。检查 `exprOwnership/updateRetSummary/condTempFreeable`。
3. **错误释放**：遗漏 escape 传播（字段存储、调用实参、全局存储、容器写入、返回字段）。优先加 escape/poison，而不是加释放。
4. **block/loop 零次路径野指针**：检查 `emitGCZeroSlots` 和 loop exit frees。
5. **scratch 捕获遗漏**：LLR 登记了临时，但 arch/exp 未写 RetScratchMap/ExprMap，freeSlot 释放空槽或漏释放。
6. **heap pin 非 leak**：tracker 表 raw brk 分配；用 `releaseAllLeakTracker/releaseLeakTracker+trim` 确认。