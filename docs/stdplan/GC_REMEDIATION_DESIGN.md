# GC 分析修复设计报告（2026-11-03）

> 依据：`docs/stdplan/GC_ANALYSIS_AUDIT.md` 的只读审计结论。
> 本报告只做方案设计，**不修改** `parser/*`、`compile/gc/*`、`type/struct.go`、
> `package/*.go` 或测试源码。文中的 `/tmp/opencode/*` 探针不属于仓库资产。
>
> 对用户表述的落地假设：把“第二个写入文件专门标记一下 1”理解为——在 LLR 的第二个
> 产物 `gc_llr.txt` 中，为 return 节点对应的释放点输出 `flag=1`，用于区分“函数出口
> 释放”和“call 之后释放”。本报告建议复用 `gc_llr.txt`，不新增第三份产物；若确实
> 需要独立文件，见 3.6 的备选方案。

## 0. 结论先行

1. **ret 释放要分两类**：
   - 有名字的局部对象（`t`、`s`）应在修正逃逸摘要后由函数出口释放；函数出口本来就在
     `ret` 求值之后执行，不需要为它单独插入 call 后释放。
   - 没有名字的临时对象（`ret compareStrings(makeString(...), makeString(...))`）以及
     条件表达式里的分配，必须由 return 节点上的 `RetFree` 标记驱动，在 call 求值后释放。
2. **double-free 不能只靠“free 后把变量置 nil”解决**。置 nil 只能消除同一个栈槽的
   重复释放；两个别名槽指向同一对象时，第二个槽仍然是悬空指针。必须同时做：
   - 静态：区分“新分配返回”与“参数别名返回”，只让 canonical owner 释放；
   - 运行时：`free`/`freeRC` 对 nil 静默跳过，并在成功移交所有权后清空当前槽；
   - 可选：对确实需要多所有者的对象使用 RC 引用计数。
3. **if/for 的释放点应从“块尾”提升为“块尾 + 汇合点”**：
   - 分支内分配、分支后不再使用 → 分支尾释放；
   - 分支内分配、汇合后仍使用 → 延迟到汇合点或外层作用域释放；
   - 循环内每轮临时对象 → 循环体尾释放；
   - 循环携带变量（循环外定义、循环后仍使用）→ 循环出口释放，并在覆盖赋值前释放旧值。
4. **`bumpParams` 的根因是“按函数而不是按参数”提升逃逸**。它只要发现返回值引用了
   任意一个拥有参数，就把该函数**所有**拥有参数提升为 `ModeOtherRef`/`EscCaller`。
   `replace` 的 `old`/`new`、`trim` 的 `cutset`、`repeatN` 的 `s` 都是这样被误标的。
5. 其他中等问题应一起纳入同一套“调用边界 + 生命周期”模型：`VarBlock` 右值逃逸、
   条件表达式分配、`HasGlobalOwnStore` 未生效、同块别名过度逃逸、`callsAny` 旧产物
   污染、`retOwned` 恒真检查、字段释放覆盖不足。

## 1. 现状与目标

### 1.1 已确认的关键缺口

| 编号 | 问题 | 级别 | 本报告对应章节 |
|---|---|---|---|
| H1 | `ret len(t)` 把 `t` 标成 `ESCAPED`，无 `FREE` | 高 | 3、6 |
| H2 | `VarBlock` 右值调用的参数逃逸未传播（callee 可能写入全局/堆），调用方可能释放仍被持有的对象 | 高 | 4、7 |
| H3 | 返回参数别名被当成新分配，可能 double-free | 高 | 4、6 |
| H4 | `if`/`for` 条件表达式中的分配不可见 | 高 | 3、5、7 |
| M1 | `bumpParams` 过度逃逸 | 中 | 6 |
| M2 | 独立调用与变量初始化路径行为不一致 | 中 | 7 |
| M3 | 同块别名导致分支局部对象被过度标记 | 中 | 5、7 |
| M4 | `HasGlobalOwnStore` 声明但未参与门控 | 中 | 7 |
| M5 | 旧产物 `callsAny`/cast-as-new 污染当前统计 | 中 | 7 |
| M6 | `retOwned` 一致性检查恒真 | 低 | 7 |
| M7 | 当前语料 `FIELD_FREE=0`，字段路径覆盖不足 | 低 | 7、9 |
| M8 | esccheck 对字符串测试是空验证 | 低 | 9 |

### 1.2 设计目标

- **正确性优先**：先消除 use-after-free、double-free、漏释放，再谈“更早释放”。
- **所有权单一**：每个堆对象在一个时刻最多只有一个 canonical owner；别名默认借用。
- **释放点显式**：每个 `FREE` 都带 `FreePoint`（函数出口、块尾、汇合点、call 后、
  循环出口），codegen 不再靠“函数出口兜底”猜测。
- **保守可回退**：任何无法证明的路径都退化为“不释放/延迟释放”，不允许错误释放。
- **产物可验证**：LLR 中能看到释放点、别名关系、ret 标记，测试能断言这些标记。

### 1.3 非目标

- 不追求完整的路径敏感/字段敏感分析；只对已确认的高频模式做局部精确化。
- 不重写 allocator，不把 `free` 改成 GC。
- 不要求所有对象都 RC 化；RC 只作为多所有者场景的兜底。
- 不改变 `main` 的“只诊断、不生成释放”的现状。

## 2. 统一模型

### 2.1 返回值所有权摘要

当前 `RetOwned` 只表示“返回类型是拥有指针”，无法区分：

- 返回新分配（caller 拥有，应释放）；
- 返回参数别名（callee 不拥有，caller 不能重复释放）；
- 返回参数内部指针（caller 只能借用，不能释放参数）；
- 未知（无摘要/外部函数，禁止自动释放）。

建议扩展为：

```go
type RetKind uint8

const (
    RetNone RetKind = iota
    RetFresh              // 新分配，调用者拥有
    RetAliasParam         // 返回某个参数本身（同一对象）
    RetBorrowParam        // 返回参数内部指针/切片，参数必须存活
    RetUnknown            // 无法证明
)

type FnSummary struct {
    // 原有字段保留...
    RetKind      RetKind `json:"retKind"`
    RetAliasMask uint64  `json:"retAliasMask"` // bit i = 可能返回第 i 个参数别名
    RetBorrowMask uint64 `json:"retBorrowMask"` // bit i = 返回值借用第 i 个参数
}
```

组合语义：`RetKind` 表示主要来源，mask 表示“可能别名/借用”的参数位。只要
`RetAliasMask` 或 `RetBorrowMask` 非零，调用方就必须按“返回值不可释放”处理；只有
路径敏感分析证明当前路径是 fresh 时才能释放。例如 `clone` 是“空串返回 `s`、否则新串”，
应标 `RetKind=RetFresh` + `RetAliasMask` 的 `s` 位；`replace` 在 `old==""` 或无匹配时
返回 `s`，也应保留 `s` 的 alias 位。这样单一 enum 不会把“有时 fresh、有时 alias”
误判成永远 fresh。

`RetAliasMask`/`RetBorrowMask` 用位掩码而不是单个 bool，原因是
`replace(s, old, new, n)` 只可能别名 `s`，`trimPrefix(s, prefix)` 只可能别名 `s`，
不能把 `old`/`new`/`prefix` 一起标记。

### 2.2 释放点模型

```go
type FreePoint uint8

const (
    FreeFuncExit FreePoint = iota // 函数出口（默认）
    FreeBlockExit                 // 块尾（循环体/分支尾）
    FreeJoin                      // if/for 汇合点
    FreeAfterCall                 // return 表达式 call 之后
    FreeLoopExit                  // 循环出口
    FreeEdge                      // break/continue/异常边（后续扩展）
)

type LLRFree struct {
    VarName    string    `json:"varName"`
    Type       string    `json:"type"`
    ScopeDepth int       `json:"scopeDepth"`
    Point      FreePoint `json:"point"`
    Flag       int       `json:"flag"` // 1 = ret 节点上的 call 后释放标记
    AliasSlots []string  `json:"aliasSlots,omitempty"`
}
```

`Flag=1` 只用于 `FreeAfterCall`，表示“这个释放点由 return 节点标记驱动”，不是
“所有 ret 都释放”。这样旧消费者可以忽略新字段，新 codegen 只在 `Point` 匹配时处理。

### 2.3 对象状态

建议把对象状态从两个 bool 扩展为：

```go
type ObjState uint8

const (
    ObjFrameOwn ObjState = iota // 帧内拥有，可释放
    ObjEscaped                  // 逃逸到调用者/全局/堆对象
    ObjBorrowed                 // 借用，不释放
    ObjUnknown                  // 未知，禁止释放
)
```

`ESCAPED` 继续保留在输出中作为兼容字段，但内部判断使用 `ObjState`，避免把
`param:*`、`null_init` 和真实逃逸混为一谈。

## 3. ret 节点上的 call 后释放

### 3.1 当前行为

- `compileReturnBlock` 只做 defer 调用和 `Arch.Return(ret)`；
- `Arch.Return` 生成返回值后 `jmp func_end_<fn>`；
- `emitGCFrees` 在函数体之后、epilogue 之前执行，所以所有 return 最终都会经过它；
- 当前问题是 LLR 把 `ret len(t)` 的 `t` 标成 `ESCAPED`，导致 `emitGCFrees` 没有
  `FREE t`，而不是“函数出口释放机制不存在”。

`ret len(t)` 的直接根因在 `markCallArgObjExpr`：它对 `len` 调用
`ParamEscapes("len", 0)`，而 `len` 没有函数摘要，`ParamEscapes` 返回 `EscAny`，于是
把实参 `t` 标成 `ESCAPED`。`markCallArgObjs` 里对 `__` 前缀合成内建的豁免不匹配
`len` 这种普通内建名，所以豁免没有生效。修复时应给纯内建补 `EscNone` 摘要，而不是
在 return 处特判。

因此：

- **有名字的局部对象**：修正 `len`/内建摘要后，函数出口释放即可，不需要额外标记。
- **没有名字的临时对象**：例如 `ret compareStrings(makeString(...), makeString(...))`，
  当前 LLR 根本没有为这两个 `makeString` 结果建立对象，函数出口无从释放；必须在
  return 表达式求值后、跳转前释放。

### 3.2 标记挂载方式

推荐两种实现，优先 B：

**A. 直接改 AST：**

```go
type RetFreeMark struct {
    CallIndex int    // return 表达式中第几个 call（按后序编号）
    VarName   string // 临时槽/变量名
    ObjID     ObjID
    Flag      int    // 1 = call 后释放
}

type ReturnBlock struct {
    Value     []*Expression
    FreeMarks []RetFreeMark
    node      *Node
}
```

优点：标记跟 AST 走，codegen 直接读；缺点：parser 包承担 GC 语义，且 monomorphize
的 `deepCopyReturnBlock` 需要同步复制标记。

**B. 编译器侧表（推荐）：**

```go
// LLRResult
RetFrees []LLRRetFree `json:"retFrees"`

type LLRRetFree struct {
    Fn        string `json:"fn"`
    NodeID    int    `json:"nodeId"`    // ReturnBlock 节点稳定 ID
    CallIndex int    `json:"callIndex"`
    VarName   string `json:"varName"`   // 临时槽名
    Flag      int    `json:"flag"`      // 1
}
```

在 `gc` 包内维护 `map[*parser.Node][]LLRRetFree`，不污染 parser AST，也不需要改
`deepCopyReturnBlock`。codegen 用 `currentFuncKey` + return 节点查找。若需要跨进程
稳定输出，再给节点分配稳定 ID。

但 B 也有单态化问题：`deepCopyReturnBlock` 会为特化函数复制新的 ReturnBlock 节点，
以原节点指针为键的侧表在特化函数里查不到。实现时必须在单态化复制节点时同步复制标记，
或改用“函数 key + 语句序号/源码位置”作为稳定键，而不是裸指针。

> 用户提出的“在 ret 节点上挂载标记”本质上是 B 的语义；用侧表可以做到同样的效果，
> 且不把 GC 细节塞进 parser。

### 3.3 分析算法

对每个 `ReturnBlock`：

1. 后序遍历 return 表达式，收集所有 `CallBlock`（含嵌套）。
2. 对每个 call：
   - 查被调 `RetKind`：
     - `RetFresh`：返回值是新对象，属于 caller，**不释放**；
     - `RetAliasParam`：返回值与某个实参同一对象，**不释放该实参**；
     - `RetBorrowParam`：返回值借用实参内部，**不释放该实参**；
     - `RetUnknown`：不释放任何实参；
     - `RetNone`（标量/void）：继续看参数逃逸。
   - 对每个实参：
     - 若实参是拥有型临时（call 结果、字符串拼接、`new`），且被调 `ParamEscapes` 为
       `EscNone`，则该临时可在 call 返回后释放；
     - 若 `ParamEscapes` 非 none，不能释放（callee 可能保存/返回它）；
     - 若实参是 `param:*`/借用，不能释放。
3. 为每个可释放临时在 LLR 中建立 `site=call:<fn>` 对象（可用合成槽名，如 `$ret0`），
   并分配一个 `RetFreeMark`，`Flag=1`，`Point=FreeAfterCall`；只登记标记而不建对象，
   summary 里的分配仍然无法进入释放计划。
4. 对 `ret len(t)` 这类有名字参数：
   - 若 `len` 是纯内建，`ParamEscapes("len", 0)` 应为 `EscNone`；
   - `t` 保持 `FRAME_OWN`，由函数出口释放；
   - 不需要 `RetFree` 标记（避免重复释放）。
5. 对 `ret f(g())`：
   - 若 `g` 返回 `RetFresh`，`f` 的 `RetKind` 为 `RetNone` 且 `ParamEscapes(f,0)=EscNone`
     → 在 `f` 返回后释放 `g()` 的临时；
   - 若 `f` 返回 `RetAliasParam`/`RetBorrowParam` → 不释放；
   - 若 `f` 是 `RetUnknown` → 不释放。

### 3.4 codegen 序列

`compileReturnBlock` 建议改为：

```
1. 生成 defer 调用
2. 编译 return 表达式到返回寄存器/返回槽
3. 若该 ReturnBlock 有 RetFrees：
     按 call 求值顺序（或后序逆序）生成 FREE
     每个 FREE 前把临时槽加载到参数寄存器
4. jmp func_end_<fn>
```

实现注意：当前 `Arch.Return(ret)` 把“返回值生成”和 `jmp func_end` 合在一起，无法在
中间插入释放。需要把架构接口拆成 `ReturnValue(ret)` + `ReturnJump()`，或给 `Return`
增加一个“值生成后执行的释放代码”参数；否则 3.4 的第 3 步没有落点。`emitRetFrees` 也应
遵守 `main` 和 build-link alias 的跳过规则。

对 `ret len(t)`（修正后）不需要第 3 步；对 `ret compareStrings(makeString(...), ...)`
第 3 步释放两个临时字符串。

关键安全条件：

- **返回值不能被释放**：`RetFresh` 的返回值、`RetAliasParam` 的参数、`RetBorrowParam`
  的参数都不能出现在 `RetFrees` 中。
- **返回槽中的值不能被覆盖**：释放临时时不能使用返回寄存器/返回槽作为临时寄存器；
  `free` 是普通调用，会破坏 RAX/EAX 等 caller-saved 寄存器。若返回值在 RAX，必须在
  释放前把返回值存入临时栈槽（或返回槽），释放后再装回；大值返回槽也不能被 free 用作
  临时区。
- **释放顺序**：多个临时按后序逆序释放，避免释放表达式内部仍被使用的对象。
- **异常/panic 路径**：当前没有异常，暂不处理；若以后加 panic，需要 edge free。

### 3.5 示例

**例 1：`ret len(t)`**

```cute
fn useTemp() int {
    var t: string = makeGreeting("gc")
    ret len(t)
}
```

目标 LLR：

```
obj[0] t site=call:makeGreeting FRAME_OWN
FREE t [string] point=func_exit
```

`len` 是纯内建，`t` 不逃逸；函数出口释放。这里不需要 `RetFree`。

**例 2：`ret compareStrings(makeString(...), makeString(...))`**

目标 LLR：

```
obj[0] tmp0 site=call:makeString FRAME_OWN
obj[1] tmp1 site=call:makeString FRAME_OWN
RET_FREE tmp0 after=call:compareStrings flag=1
RET_FREE tmp1 after=call:compareStrings flag=1
```

codegen 在 `compareStrings` 返回后、`jmp func_end` 前释放两个临时。

**例 3：`ret f(g())` 且 `f` 返回 `g()` 的别名**

目标：不生成 `RET_FREE tmp`；`g()` 的对象由调用者/外层 owner 管理。

### 3.6 输出与“第二个文件标记 1”

推荐在现有 `gc_llr.txt` 中增加：

```
RET_FREE <var> after=call:<callee> flag=1
```

并在 `gc_summary.json` 的 `FnSummary` 中输出 `retKind`、`retAliasMask`、
`retBorrowMask`。这样“第二个写入文件”就是 `gc_llr.txt`，`flag=1` 明确表示 call 后
释放。

如果确实需要独立文件，可增加 `gc_retfree.txt`，内容为：

```
== <fn>
RET_FREE <var> node=<id> call=<idx> flag=1
```

但不建议：会多一份需要同步清理的产物，且现有 `gc_llr.txt` 已经按函数分节，足够承载。

## 4. double-free 与 free/RCfree 改造

### 4.1 当前运行时行为

`pkg/memory/allocator.cute`：

```cute
fn free(ptr: ptr) {
    if ptr == 0 { ret }
    var flags: uint = flagLoad(ptr)
    if (flags & RC_BIT) != 0 { rcDec(ptr); ret }
    freeAt(ptr - ptrSize)
}
```

`pkg/memory/rc.cute`：

```cute
fn freeRC(ptr: ptr) {
    if ptr == 0 { ret }
    freeAt(ptr - ptrSize * 3)
}
```

所以 **`free(nil)` 已经静默跳过**；缺的是“释放后把原变量置 nil”以及别名处理。

### 4.2 方案 A：释放后清空当前槽（用户建议）

在 codegen 的 `emitGCFrees`/`emitBlockFrees` 中，`call free` 之后生成：

```asm
; gc: free t
mov RDI, QWORD [rbp-8]
call std_memory_free__ptr
mov QWORD [rbp-8], 0
```

或封装成运行时 helper：

```cute
// 传入变量地址，释放后把槽清 0
fn freeSlot(p: *ptr) {
    if p == 0 { ret }
    var q: ptr = *p
    if q == 0 { ret }
    free(q)
    *p = 0
}
```

上面的 `freeSlot` 只是示意；由于 `free` 目前是 void 且可能 no-op，真正实现应使用
4.3 的 `freeOwn`/`freeRCSlot` 返回“所有权是否已移交”，只在成功时清槽。

优点：

- 同一个槽被重复加入释放计划时，第二次 `free(nil)` 自动跳过；
- 不需要改 `free` 的调用约定；
- 对 `block free + func exit free` 的重复计划有直接保护。

限制：

- **不能解决别名 double-free**：`n` 和 `m` 都指向同一对象时，清空 `n` 不会清空 `m`；
- 若 `freeAt` 对 HUGE/LARGE 非堆顶块是 no-op，直接清空会丢失指针并造成泄漏；因此
  必须先定义“成功”的语义（见 4.3）；
- string/list 的栈槽是“指针 + 长度”复合值，清槽时只清指针字（第一个字），不要误清
  后续仍可能读取的 len 字段；若变量已经死亡，清零整个槽也可以，但必须保证不会再用。

### 4.3 “free 成功”的语义

当前 `freeAt` 是 `void`，且存在提前 `ret` 不释放的分支：

- HUGE 块不在堆顶：不 `brk`，直接返回；
- LARGE 块合并后不在堆顶：直接返回；
- TINY/SMALL：合并后插入空闲链表。

因此“free 成功”不能简单理解为“函数返回”。建议：

1. 给 `freeAt` 增加状态返回（内部 helper，不一定改公开 ABI）：
   - `true` = 所有权已移交（块已回缩/入空闲链表，或 RC 已减计数）；
   - `false` = 未实际释放（HUGE/LARGE 非堆顶，保留指针，避免丢失）。
2. `free` 保持现有签名，新增 `freeSlot` 使用状态；
3. `freeRC` 同理，新增 `freeRCSlot`；
4. `rcDec` 已经有 `bool` 返回值，可直接复用：`false` 表示还有其他引用，槽应清空
   （caller 不再拥有），但对象仍存活。

这里要区分两个概念：

- **所有权移交**：调用者不再拥有该引用 → 槽应清 0；
- **物理释放**：块回到 allocator → 只有引用计数归零/无别名时才发生。

`freeSlot` 应在“所有权移交”后清 0，而不是只在“物理释放”后清 0。

### 4.4 方案 B：canonical owner + 别名借用（推荐）

仅靠置 nil 不够，必须在 LLR 层解决别名所有权：

- `processAssign` 遇到 `RetFresh` 调用 → 新建 `site=call:<fn>` 对象，调用者拥有；
- 遇到 `RetAliasParam` → 不新建对象，把目标变量绑定到实参对象，标记为 `Borrowed`；
- 遇到 `RetBorrowParam` → 目标变量 `Borrowed`，禁止释放；
- 遇到 `RetUnknown` → `Unknown`，禁止释放；
- 普通 `b = a` 别名 → `b` 借用 `a` 的对象，只有 `a` 是 canonical owner；
- 同一对象多个 owner 的情况，要么在赋值点做 `rcInc`，要么报保守泄漏。

对 `ident(p){ret p}`：

```
n: new -> canonical owner
m: call:ident -> alias of n, Borrowed
FREE n (func_exit)
// 不生成 FREE m
```

这样不需要运行时猜测，也不会 double-free。

### 4.5 方案 C：RC 兜底（可选）

如果确实存在多所有者（例如对象被存入全局、容器、多个字段），可以：

- 对 `*T` 使用 `newRC`/`mallocRC`；
- 每次别名赋值 `rcInc`；
- 每个 owner 离开作用域 `free`/`rcDec`；
- `freeRC` 只在 RC 归零时 `freeAt`。

优点：运行时语义强，别名安全；缺点：

- 所有别名赋值都要插桩，代码体积/性能上升；
- string/list 的缓冲区不是 RC 头，不能直接套用；
- 当前 `free` 已按 flags 分派 RC，但普通 `new` 没有 RC 头，需要先决定哪些对象升级。

建议：**先做 B，A 作为防御性硬化，C 只在确认多所有者且静态无法消解时使用**。

## 5. if/for 的汇合点释放

### 5.1 当前实现

- `compileIfBlock`：then 分支尾调用 `emitBlockFrees(n)`，然后 `jmp end`；else 分支
  由 `compileElseBlock` 编译，但没有对应的 `emitBlockFrees`。
- `compileForBlock`：循环体尾 `emitBlockFrees(n)`，然后 `ForEnd` 生成增量与回跳。
- `LLRResult.BlockFreesMap` 以 `*parser.Node` 为键，记录块级释放。
- `emitGCFrees` 用 `blockFreedVars` 跳过已在块级释放的变量。

当前策略对“分支/循环内分配且立即死亡”的对象有效，但对“分支内分配、汇合后仍使用”
和“循环携带变量”不够精确；else 分支还缺少块级释放。

### 5.2 汇合点定义

对结构化 AST，汇合点是所有前驱路径都到达、且对象不再被使用的最近节点：

- `if`：`end_<label>`；
- `if/else`：`end_<label>`（两个分支的共同后继）；
- `for`：`for_<n>_end`；
- `for` 内 `if`：先 `if` 的 `end`，再循环体尾/循环出口；
- 嵌套 `if`：取最内层共同后继，再逐层向外。

对象释放点选择：

```
if obj 在 return 中返回/被全局保存/被 callee 保存:
    不释放
else if obj 是参数/借用:
    不释放
else if obj 在分支内分配 and 分支后不再使用:
    FreeBlockExit（分支尾）
else if obj 在分支内分配 and 汇合后仍使用:
    FreeJoin（汇合点）或外层作用域出口
else if obj 在循环体内分配 and 不跨迭代:
    FreeBlockExit（循环体尾）
else if obj 是循环携带变量:
    FreeLoopExit + 覆盖赋值前释放旧值
else:
    FreeFuncExit
```

### 5.3 if 分支

目标 codegen：

```
compile condition
jz else_label
  then body
  emit frees for then-local objects
  jmp end_label
else_label:
  else body
  emit frees for else-local objects
end_label:
  emit join frees for objects live after join
```

关键点：

- then/else 都应有块级释放，当前 else 缺失；
- 条件表达式中的临时对象要在条件求值后释放；若为了简单延迟到分支尾，then/else 两条
  路径都必须生成释放，不能只放在汇合点（汇合点只覆盖到达该点的路径）；
- 当前 `emitGCFrees` 会把 `BlockFreesMap` 中出现的变量从函数出口释放计划中剔除；如果
  `return` 从 then 分支直接跳到 `func_end`，块尾释放不会执行，函数出口又跳过该变量，
  就会漏释放。必须保证所有出口边都经过 cleanup，或让函数出口保留这些变量并依赖
  `freeSlot` 的空指针幂等；
- 如果对象在 then 分配、else 未分配，汇合后变量可能为 nil；`free(nil)` 跳过；
- 如果 then/else 都分配并赋给同一个外层变量，汇合点只释放外层变量一次，不按分支
  分别释放（否则会释放未选中的对象/重复释放）；
- 如果对象只在 then 分配且汇合后不再使用，then 尾释放即可，不必等到 join。

### 5.4 for 循环

目标 codegen：

```
for_label:
  condition (false -> for_end)
  body
  emit per-iteration frees
  increment
  jmp for_label
for_cleanup:
  emit break cleanup frees
for_end:
  emit loop-exit frees
```

关键点：

- 每轮临时对象在 body 尾释放，避免下一轮泄漏；
- 循环条件每轮都会求值，条件表达式里的临时对象必须在每轮释放（可在 body 入口或
  body 尾统一清理），不能只等到 `for_end`；
- 循环携带变量在 `for_end` 释放；
- `break` 跳到 `for_end` 时既会跳过本轮 body 尾释放，也会跳过 loop-exit frees；
  建议给 `break` 生成 cleanup 边（先释放本轮 body 临时对象），或设置统一的
  `for_cleanup` 标签，让正常回边和所有 `break` 都汇合到该标签后再执行释放；
  仅把 loop-exit frees 放在 `for_end` 之后不能覆盖 `break` 前已分配的 body 临时对象；
- `return` 跳到 `func_end`，由 ret/函数出口释放覆盖；
- 若循环体有多个 `break`，统一汇合到 `for_cleanup` 释放，避免每条边重复生成。

### 5.5 for + if 且变量生命周期在两者之外

这是用户指出的“稍微复杂的机制”。例子：

```cute
var x: *Node = nil
var i: int = 0
for ; i < n; {
    if cond {
        x = new(Node)
    } else {
        x = new(Node)
    }
    use(x)
    i = i + 1
}
ret x.val
```

问题：

- `x` 在循环外定义，生命周期跨循环；
- 每轮 `if` 都覆盖 `x`，旧对象必须在覆盖前释放，否则只释放最后一次；
- 不能在 `if` 汇合点释放 `x`，因为 `use(x)` 还要用；
- 不能只在 `for_end` 释放，因为中间轮次会泄漏。

建议机制：

1. **覆盖赋值前释放旧值**：`x = new(...)` 前插入 `freeIfOwned(x)`；
2. **循环出口释放最后一次值**：`for_end` 后释放 `x`；
3. **分支合并绑定**：`x` 是外层变量，then/else 都绑定到 `x`；不把分支局部 `n` 作为
   独立 owner，避免分支尾释放；
4. **RC 可选**：若 `x` 可能被多个地方持有，用 `rcInc`/`rcDec` 替代覆盖前释放。

这比“所有释放都延迟到汇合点”更复杂，但语义正确：汇合点只处理分支局部对象，
循环携带变量需要“覆盖点 + 循环出口”两个释放点。

### 5.6 需要的数据结构

```go
type LLRResult struct {
    // ...
    JoinFrees map[*parser.Node][]LLRFree `json:"-"` // if/for 汇合点
    LoopExitFrees map[*parser.Node][]LLRFree `json:"-"` // 循环出口
    RetFrees []LLRRetFree `json:"retFrees"`
}
```

codegen：

- `compileIfBlock`：`emitBlockFrees(n)` + `emitBlockFrees(else)` + `emitJoinFrees(endLabel)`
- `compileForBlock`：`emitBlockFrees(n)` + `emitForCleanup` + `emitLoopExitFrees(forEndLabel)`
- `compileReturnBlock`：`ReturnValue(ret)` → `emitRetFrees(n)` → `ReturnJump()`
- `compileBreakBlock`：跳到统一 `for_cleanup` 标签，先执行本轮 body 临时释放，再执行
  loop-exit frees

注意：`JoinFrees`/`LoopExitFrees` 与 `RetFrees` 一样以节点为键，单态化复制节点时也要
同步复制这些侧表；否则特化函数查不到。

## 6. `bumpParams` 是咋回事

一句话：它把“函数级是否存在逃逸”误当成“每个参数都逃逸”，是过度保守的根源。

### 6.1 代码路径

`compile/gc/analyze.go:236`：

```go
func (a *analyzer) bumpParams(fs *FnSummary, e Escape, m Mode) {
    for i := range fs.Params {
        if fs.Params[i].Escape < e {
            fs.Params[i].Escape = e
        }
        nm := fs.Params[i].Mode.Merge(m)
        if nm != fs.Params[i].Mode {
            fs.Params[i].Mode = nm
        }
    }
}
```

它没有参数索引，天然就是“提升全部参数”。三个调用点：

1. `ReturnBlock`：`retOwns && refsTracked(rv, fb)` → `bumpParams(fs, EscCaller, ModeOtherRef)`；
2. 全局赋值：`!v.IsDefine && v.IsGlobal && refsTracked(v.Value, fb)` →
   `bumpParams(fs, EscGlobal, ModeOtherRef)`；
3. `applyCallee`：被调某个参数逃逸且实参引用本函数任意拥有参数 →
   `bumpParams(fs, ps.Escape, ps.Mode)`。

`refsTracked` 只返回 bool（“有没有命中任意拥有参数”），不返回“命中了哪个参数”。
因此只要返回值/全局右值/实参里出现任意一个拥有参数，所有拥有参数都会升级。

### 6.2 典型误标

| 函数 | 返回/调用 | 当前被标 | 实际别名参数 | 结论 |
|---|---|---|---|---|
| `clone(s)` | 空串 `ret s`，否则新串 | `s` | `s` | 空串路径保守必要 |
| `repeatN(s,count)` | `ret strings.repeat(s,count)` 或 `""` | `s` | 无 | **明显多余** |
| `replace(s,old,new,n)` | `old==""`/无匹配 `ret s`，否则新串 | `s, old, new` | `s` | `old/new` 多余 |
| `reverse(s)` | 空串 `ret s`，否则新串 | `s` | `s` | 空串路径保守必要 |
| `trim(s,cutset)` | 委托 `trimLeft/trimRight`，总是新串 | `s, cutset` | 无 | **两者都多余** |
| `trimPrefix(s,prefix)` | 无匹配 `ret s`，否则新串 | `s, prefix` | `s` | `prefix` 多余 |
| `trimSuffix(s,suffix)` | 无匹配 `ret s`，否则新串 | `s, suffix` | `s` | `suffix` 多余 |
| `makeGreeting(name)` | `"hello, " + name + "!"` | `name` | 无（拼接新串） | **多余** |

`replace` 的 `old`/`new` 被标，是因为 `bumpParams` 不看“哪个参数被返回”，只看
“返回表达式是否引用任意拥有参数”。`makeGreeting` 的 `name` 被标，是因为字符串拼接
表达式引用了 `name`，但拼接结果不借用 `name` 的缓冲区。

### 6.3 修复方式

**核心：把 bool 改成参数索引集合。**

```go
func refsTrackedParams(e *parser.Expression, fb *parser.FuncBlock) []int
```

- 递归表达式，遇到 `Var` 根名，匹配 `fb.Args` 的拥有参数索引；
- 返回去重后的索引列表；
- `bumpParams` 改为 `bumpParam(fs, idx, e, m)`，只提升命中的参数。

`applyCallee`：

```go
for _, ps := range callee.Params {
    arg := cb.Args[ps.Index]
    if ps.Escape > EscNone {
        for _, pi := range refsTrackedParams(arg.Value, fb) {
            a.bumpParam(fs, pi, ps.Escape, ps.Mode)
        }
    }
}
```

`ReturnBlock`：

```go
if retOwns {
    for _, pi := range refsTrackedParams(rv, fb) {
        a.bumpParam(fs, pi, EscCaller, ModeOtherRef)
    }
}
```

全局赋值同理，只提升实际被存入全局的参数。

**路径敏感（可选）**：

- `clone`/`reverse`/`trimPrefix`/`trimSuffix` 的空串/无匹配路径确实可能返回 `s`，
  所以 `s` 保留 `EscCaller` 是保守正确的；
- `repeatN`/`trim`/`makeGreeting` 没有别名路径，可以直接改为 `EscNone`；
- `replace` 的 `s` 保留，`old/new` 改为 `EscNone`；
- 若以后做路径敏感，可把“空串路径”的别名标为 `MayAlias`，仅在调用方需要时保守处理。

**预期效果**：

- `pkg/strings` 12 个 `mode=4 escape=1` 参数中，至少 7 个可降为 `Read/EscNone`；
- 独立调用 `strings.trim(...)` 等输入不再被 `ESCAPED`，可生成 `FREE`；
- `VarBlock` 右值路径与独立调用路径行为一致（见 7.1）。

## 7. 其他中等严重问题

### 7.1 `VarBlock` 右值与条件表达式没有统一传播

当前：

- `markCallArgObjs` 只处理独立 `CallBlock`；
- `markCallArgObjExpr` 只处理 `ReturnBlock` 顶层 call；
- `processAssign` 处理 `VarBlock` 右值时只建立绑定，不调用 `markCallArgObjs`，所以右值
  调用中的参数逃逸不传播；
- `scanStatements` 的 `IfBlock`/`ForBlock` 分支只遍历 `Children`，不扫描 `Condition`
  （也不扫描 `ForBlock.Increment`）；
- `analyzeBody` 对 `VarBlock.Value` 已有 `walkExprCalls`，但对 `IfBlock.Condition`/
  `ForBlock.Condition`/`ForBlock.Increment` 没有对应扫描；`HasHeapAllocs` 只在拥有型
  `VarBlock` 的 `exprAllocates` 和 `ReturnBlock` 中设置，条件表达式不会设置。

修复建议：

- 抽出统一遍历器 `walkExprCalls`（已有）并在所有表达式位置调用；
- `scanStatements` 用 `walkExprCalls` 遍历 `VarBlock.Value`、`IfBlock.Condition`、
  `ForBlock.Condition`、`ForBlock.Increment`，对每个 `CallBlock` 调用
  `markCallArgObjs`；`ReturnBlock` 的嵌套 call 也统一走 `walkExprCalls`，不再只处理
  顶层 `rv.Call`；
- `analyzeBody` 对这些位置调用 `exprAllocates`，设置 `HasHeapAllocs`；
- 对同一个 call 做去重，避免重复标记/重复 `CallsAny`。

这里要区分两件事：

- **逃逸传播**：`markCallArgObjs` 只把实参已有对象标成 `ESCAPED`；
- **临时对象创建**：条件表达式/return 表达式里的 owning call 结果需要新建
  `site=call:<fn>` 对象，并挂到条件清理点或 `RetFree`。只做逃逸传播不会让
  `makeString` 的结果出现在 LLR 中。

因此还需要一个 `trackExprTemps`（或复用 ReturnBlock 的临时对象逻辑）遍历
`IfBlock.Condition`/`ForBlock.Condition`/`ForBlock.Increment`/`VarBlock.Value`，
为 owning call 结果建对象并安排释放。

验收：

- `gcprobe_paramesc` 的 `f` 中 `n` 应为 `ESCAPED`，无 `FREE`；
- `sortTest._checkStrSorted` 的 `hasHeapAllocs=true`，条件中的 `makeString` 有对象；
- `gcprobe_overesc`/`gcprobe_overesc2` 行为一致。

### 7.2 独立调用与变量初始化不一致

`gcprobe_overesc2`：独立调用六个输入全 `ESCAPED`、零 `FREE`；
`gcprobe_overesc`：变量初始化器中的同样调用全 `FRAME_OWN`、有 `FREE`。

根因有两个，不能只归因于 `bumpParams`：

1. `bumpParams` 过度逃逸，使独立调用路径把只读实参标成 `ESCAPED`；
2. `processAssign` 不处理 `VarBlock` 右值调用的参数逃逸，使变量初始化路径“看起来更优”，
   但这其实是漏传播，遇到真正会保存实参的 callee 会变成 use-after-free。

修复 6.3 只能消除第 1 个原因；第 2 个原因必须靠 7.1 的统一遍历器解决。两者都完成后，
两条路径才应一致。

### 7.3 同块别名过度逃逸

`processAssign` 在局部别名赋值时，只要 `refObj` 与当前块相同就 `objEscaped=true`：

```go
if st.objBlockID[refObj] == st.currentBlockID && st.currentBlockID != 0 {
    st.objEscaped[refObj] = true
}
```

这会把 `test/gcOwnership.testBranchAlloc` 的分支局部对象标成 `ESCAPED`，即使
`result` 只在函数内使用。建议：

- 区分“别名逃出块”和“别名仍在块内”；
- 用 `blockID` + `lastUse`/liveness 判断，而不是“同块即逃逸”；
- 若别名被外层变量持有，把外层变量作为 canonical owner，分支局部对象标为借用；
- 若无法证明，保留保守逃逸，但至少让 `testBranchAlloc` 在 join 后释放。

### 7.4 `HasGlobalOwnStore` 未生效

`analyze.go:154-155` 设置 `HasGlobalOwnStore`，`summary.go:115-117` 注释说“禁用自动
释放优化”，但 `ComputeLLR` 只检查 `hasRealAnyCalls` 和 `HasHeapAllocs`，`applyCallee`
不传播该标志。

两种处理：

- **实现它**：把 `HasGlobalOwnStore` 纳入该函数自身的 `ComputeLLR` 保守门槛（有全局
  拥有存储时不自动释放帧内对象）；caller 侧仍依赖 `ParamEscapes` 的按参数摘要，不要
  简单把函数级标志传播成 caller 的全局标志，否则会把无关对象一起变成不可释放；
- **删除承诺**：如果短期不实现，删除注释和字段，避免误以为已有保护。

推荐实现，但要注意：H2 的直接原因不是这个字段，而是 7.1 的 `VarBlock` 右值漏传播；
`keep` 的参数摘要已经是 `EscGlobal`，调用方只是没有读取它。`HasGlobalOwnStore` 应作为
额外的保守门槛（摘要不完整时兜底），不能替代 7.1 的传播修复。

### 7.5 `callsAny` 与旧产物污染

当前 22 个 11-03 产物只有 `callsAny [""]`，无 `EscAny`/`EscGlobal` 参数；10-18 旧产物
有 869 个函数带非空 `callsAny`（`len` 840、`new` 25 等）。旧产物中的
`callsAny ["new"]`、cast-as-new、`site=new` 不能用于当前结论。

建议：

- 把 11-03 的 22 项作为唯一当前基线；
- 旧产物目录标记 stale，或在统计脚本中按日期过滤；
- `pkg/math/bits/test` 无法重新生成，保留“不可验证”标记；
- `pkg/sort/test` 是 stale test，不作为当前测试；
- `test/_mp_probe` 不进入正式统计。

### 7.6 `retOwned` 恒真检查

`RetOwned` 和 `RetEscape` 都在摘要初始化时由 `isOwning(fb.Return[0])` 赋值；`RetEscape`
后续只会在 `retOwns` 分支被 `bumpRet` 提升，非 owning 返回永远保持 0。因此：

- `retOwned && retEscape==0` 永远为 0；
- `!retOwned && retEscape!=0` 永远为 0。

这不是“检查通过”，而是“检查没有信息量”。修复 2.1 的 `RetKind` 后，用
`RetKind == RetFresh` 与 `RetAliasMask` 做独立校验。

### 7.7 字段释放与 esccheck 覆盖

当前 22 项只有 1 个 `site=new`、0 个 `FIELD_FREE`；旧 `gc_*` 测试的字段释放丰富，但
是 10-18 产物。建议：

- 把 `gcOwnership`、`gcStructFree`、`gc_complex`、`gc_loop`、`heap_new`、`gc_cond`、
  `gc_deep` 纳入当前回归并重新生成；
- 对 `FIELD_FREE` 建独立断言（父对象释放前先释放 owning 字段）；
- esccheck 增加字符串/LLR 维度，至少不要让 `对象=0` 被当作“无泄漏”。

## 8. 实施顺序

### Phase 0：回归基线

- 把 `/tmp/opencode/gcprobe_*` 的最小用例迁入正式测试或测试夹具；
- 固化当前 22 项 LLR 快照（只比较对象数/释放点/关键标记，不比较全部文本）；
- 明确 `main` 只诊断、不生成释放。

### Phase 1：返回值摘要与 `ret` 标记

- 增加 `RetKind`/`RetAliasMask`/`RetBorrowMask`；
- 拆分 `Arch.Return` 的“返回值生成/跳转”，为 `RetFrees` 留插入点；
- 修正 `len` 等纯内建摘要；
- 增加 `RetFree` 侧表与 `gc_llr.txt` 的 `RET_FREE ... flag=1`；
- 先只处理“无名字临时 + 标量返回”的安全子集。

### Phase 2：double-free 硬化

- `processAssign` 区分 `RetFresh`/`RetAliasParam`；
- 别名默认 `Borrowed`，只让 canonical owner 释放；
- `freeSlot`/`freeRCSlot` 做“所有权移交后清槽”；
- 保留 `free(nil)` 静默跳过。

### Phase 3：if/for 汇合点

- 先修 else 分支缺失的 `emitBlockFrees`；
- 增加 `JoinFrees`/`LoopExitFrees`；
- 再处理循环携带变量的“覆盖前释放旧值”；
- 最后处理 `break`/`return` 边。

### Phase 4：`bumpParams` 按参数精确化

- `refsTrackedParams` 返回索引；
- `bumpParam` 只提升命中参数；
- `applyCallee`/return/global store 全部改为按索引；
- 对空串/无匹配路径保留保守别名。

### Phase 5：产物清理

- 重新生成 stale 测试；
- 统计脚本按 11-03 过滤；
- esccheck/LLR 断言加入 CI 或 farm 检查。

## 9. 验收标准

### 9.1 最小探针

| 探针 | 期望 |
|---|---|
| `gcprobe_lenret` | `f_ret_len` 的 `t` 为 `FRAME_OWN` + `FREE`；`f_var_len`/`f_no_len` 保持 |
| `gcprobe_paramesc` | `keep` 的 `p` 为 `EscGlobal`；`f` 的 `n` 为 `ESCAPED`，无 `FREE n` |
| `gcprobe_retparam` | `ident` 为 `RetAliasParam`；`n` 是 owner，`m` 是借用；只 `FREE n` |
| `gcprobe_overesc2` | 六个输入不再全部 `ESCAPED`；至少可释放的临时生成 `FREE` |
| `sortTest._checkStrSorted` | `hasHeapAllocs=true`；条件中的 `makeString` 有对象/释放点 |

### 9.2 当前 22 项

- `test/gcfree`、`test/gcfree2`：`useTemp` 的 `t` 有 `FREE`，rc 仍为 0；
- `test/sortTest`：`_checkStrSorted` 不再空 LLR；
- `test/gcOwnership.testBranchAlloc`：分支局部对象在分支/汇合点释放；
- `pkg/strings/test`：`bumpParams` 误标减少，独立调用临时可释放；
- 22 项 × 双 arch × 三连 rc 稳定；
- esccheck 红项 0 保持，但新增 LLR 断言不依赖 esccheck。

### 9.3 约束

- 不改 `main` 的 codegen 释放行为；
- 不把 `gc_llr.txt`/`gc_summary.json` 当作提交资产；
- 不混用 10-18/10-31/11-02 旧产物；
- 不在没有回归测试的情况下开启“更早释放”。

## 10. 开放问题

1. **“第二个写入文件标记 1”**：本报告按“`gc_llr.txt` 中 `RET_FREE ... flag=1`”落地；
   若必须独立文件，再增加 `gc_retfree.txt`，但会增加产物同步成本。
2. **`free` 状态返回**：是否愿意把 `freeAt` 改为返回 bool，或只新增 `freeSlot` 包装？
   前者更准确，后者 ABI 改动更小。
3. **RC 范围**：是否只对 `*T` 启用 RC 兜底？string/list 的缓冲区布局不同，不能直接
   套 `freeRC`。
4. **循环携带变量**：是否接受“覆盖前释放旧值”的额外释放点？这是解决
   `for+if` 外部生命周期的最直接方式。
5. **路径敏感**：`clone`/`reverse`/`trimPrefix`/`trimSuffix` 的空串别名是否值得做
   路径敏感？短期可继续保守标记 `s` 逃逸，只修 `old/new/cutset` 等明确误标。

## 11. 证据与引用

- 审计报告：`docs/stdplan/GC_ANALYSIS_AUDIT.md`
- 理论分析：`DOC_gc_ownership_analysis.md`
- 当前实现：
  - `compile/gc/analyze.go:236`（`bumpParams`）
  - `compile/gc/analyze.go:184`（`applyCallee`）
  - `compile/gc/analyze.go:360`（`exprAllocates`）
  - `compile/gc/llr.go:91`（`ComputeLLR`）
  - `compile/gc/llr.go:387`（`scanStatements`）
  - `compile/gc/llr.go:509`（`processAssign`）
  - `compile/gc/llr.go:608-615`（同块别名）
  - `compile/gc/llr.go:660`（`markCallArgObjs`）
  - `compile/gc/llr.go:707`（`markCallArgObjExpr`）
  - `compile/compiler.go:717`（`compileReturnBlock`）
  - `compile/compiler.go:1263`（`emitGCFrees`）
  - `compile/compiler.go:1373`（`emitBlockFrees`）
  - `pkg/memory/allocator.cute:534`（`free`）
  - `pkg/memory/rc.cute:133`（`freeRC`）
- 探针：
  - `/tmp/opencode/gcprobe_lenret`
  - `/tmp/opencode/gcprobe_paramesc`
  - `/tmp/opencode/gcprobe_retparam`
  - `/tmp/opencode/gcprobe_overesc`
  - `/tmp/opencode/gcprobe_overesc2`

## 12. 边界声明

本报告是设计文档，未修改任何代码。所有“建议”“应”“可以”均为后续实现选项；在实现
前应先补回归测试，并以 11-03 的 22 项当前产物为基线。
