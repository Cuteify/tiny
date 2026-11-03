# GC 修复实施计划（2026-11-03）

> 依据：`docs/stdplan/GC_REMEDIATION_DESIGN.md`、`docs/stdplan/GC_ANALYSIS_AUDIT.md`。
> 本计划把设计报告中的 Phase 0–5 落成可执行改动、验收命令和提交点。
> 约束：不把 `gc_llr.txt` / `gc_summary.json` / `ast.html` / farm 日志作为提交资产；
> 所有 e2e 命令恒 `flock`；不 push；不 `git add -A`。

## 0. 目标与安全不变量

1. **唯一所有权**：一个堆对象在同一时刻最多一个 canonical owner；别名默认借用。
2. **释放点后无使用**：`FREE O` 之后不存在读取 `O` 的路径；无法证明则不释放。
3. **返回值先保存**：`free` 是普通调用，会破坏 RAX/EAX 等 caller-saved 寄存器；
   return 节点上的 call 后释放必须先保存返回值，再释放，再跳转。
4. **槽级幂等**：块尾/函数出口的重复释放计划通过 `freeSlot`（成功移交后清槽）
   防御；别名安全仍由第 2 条保证，不能只靠置 nil。
5. **保守回退**：摘要缺失、返回值可能别名参数、参数可能被保存时，一律不自动释放。

## 1. 阶段与文件域

### Phase 1：摘要精确化（`compile/gc/analyze.go`、`compile/gc/summary.go`）

- `RetKind` / `RetAliasMask` / `RetBorrowMask`：
  - `RetNone`：非拥有返回；
  - `RetFresh`：新分配，caller 拥有；
  - `RetAliasParam`：可能返回参数本身；
  - `RetBorrowParam`：可能返回参数内部指针；
  - `RetUnknown`：无法证明。
  - 混合路径（如 `clone` 的空串分支）保留 `RetFresh` + alias mask；caller 只有
    在 `RetFresh` 且两个 mask 均为 0 时才可释放返回值。
- `refsTrackedParams` 返回命中的拥有参数索引；`bumpParam` 只提升命中参数。
- return / 全局存储 / `applyCallee` 全部按参数索引提升。
- 纯内建摘要：`len`、`cap`、`sizeof` 等参数 `EscNone`；未知内建仍 `EscAny`。
- `HasGlobalOwnStore` 纳入本函数 `ComputeLLR` 的保守门槛（有全局拥有存储时不自动
  释放帧内对象），不把它传播成 caller 的全局标志。

验收：
- `pkg/strings.test` 中 `repeatN`/`trim`/`makeGreeting` 的参数不再误标 `mode=4/escape=1`；
- `test/gcfree.useTemp` 的 `t` 为 `FRAME_OWN` 且有 `FREE`；
- `test/sortTest._checkStrSorted` 的 `hasHeapAllocs=true`。

### Phase 2：ret 节点 call 后释放（`compile/gc/llr.go`、`compile/compiler.go`、`compile/arch/*`）

- `LLRResult.RetFrees []LLRRetFree`，字段：`node`、`call`、`varName`、`flag=1`。
- 分析：只登记“嵌套 owning call 的结果作为外层 call 实参，外层参数 `EscNone`，
  且外层不返回该实参别名”的临时；返回值本身不登记。
- codegen：
  1. `Arch.ReturnValue(ret)` 生成返回值；
  2. 保存返回值寄存器（x64 `push RAX; push RDX`，x86 `push EAX; push EDX`）；
  3. 从 scratch 槽逐个 `freeSlot`；
  4. 恢复返回值寄存器；
  5. `Arch.ReturnJump()`。
- 在 `context.Context` 增加 GC scratch 基址/用量；`Prologue` 按函数
  `RetScratchSlots` 预留，保证不与 `RetSlot`、R10 保存槽重叠。
- `gc_llr.txt` 输出 `RET_FREE <var> after=call:<callee> flag=1`。

验收：
- `ret compareStrings(makeString(...), makeString(...))` 生成两个 `RET_FREE`，运行无
  double-free/崩溃；
- `ret len(t)` 不生成 `RET_FREE`，`t` 由函数出口释放；
- 单态化函数（ReturnBlock 深拷贝）仍携带/匹配标记。

### Phase 3：double-free 硬化（`pkg/memory/allocator.cute`、`pkg/memory/rc.cute`、`compile/compiler.go`）

- `freeAt` 返回 `bool`：true=所有权已移交（回缩/入空闲链表），false=未释放
  （HUGE/LARGE 非堆顶）。
- `free` 返回 `bool`：nil→true；RC 块→`rcDec`；普通块→`freeAt`。
- `freeRC` 返回 `bool`；新增 `freeSlot(p: *ptr)` / `freeRCSlot(p: *ptr)`：
  - 先读槽；nil→true；
  - `free(q)` 成功后清槽；失败保留指针。
- codegen 的块级/函数出口/字段释放改用 `freeSlot`；删除 `emitGCFrees` 的
  `blockFreedVars` 跳过逻辑（块尾已清槽，出口自然幂等）。
- 别名：`processAssign` 对 `RetAliasParam`/`RetBorrowParam` 不新建 owner；普通
  `b = a` 只在能证明 `a` 是 canonical owner 且 `b` 不跨作用域存活时才共享对象；
  否则保持保守逃逸。

验收：
- `test/gcfree2` 1000 次循环 rc=0；
- `test/gcOwnership` 分支局部对象在分支/汇合点释放，无 double-free；
- 双 arch 运行不崩溃。

### Phase 4：if/for 汇合点（`compile/gc/llr.go`、`compile/compiler.go`）

- `compileElseBlock` 补 `emitBlockFrees(ifBlock.ElseBlock)`。
- `LLRResult.JoinFrees` / `LoopExitFrees`：
  - if 汇合点释放“分支内分配、汇合后不再使用”的对象；
  - for 体尾释放每轮临时对象；
  - 循环携带变量在 `for_end` 释放，覆盖赋值前释放旧值（`FreeLoopExit`）。
- `break` 统一跳 `for_cleanup`：先执行本轮 body 临时释放，再执行 loop-exit 释放。
- 条件表达式（`IfBlock.Condition`、`ForBlock.Condition`、`ForBlock.Increment`）中的
  owning call 结果建对象并在条件求值后/每轮释放。
- `return` 绕过块尾时，函数出口仍保留该变量（由 `freeSlot` 幂等兜底）。

验收：
- `test/gcOwnership.testBranchAlloc` 的 `n`/`result` 有明确释放点；
- `test/gcOwnership.testLoopAlloc`/`testMassiveLoop` 每轮释放；
- 带 `break` 的循环不泄漏本轮临时对象。

### Phase 5：回归与收口

- 新增/固化最小探针到 `test/`（或现有测试内断言）：
  - `ret len(t)`；
  - `ret f(makeString(...), ...)`；
  - `ret ident(p)` 别名；
  - `if/else` 分支局部对象；
  - `for + break` 临时对象。
- 构建 `/tmp/opencode/bin/w14`。
- 跑双 arch 三连 farm：`test/gcfree`、`test/gcfree2`、`test/gcOwnership`、
  `test/sortTest`、`test/complexTest`、`test/rctest`、`pkg/strings/test`、
  `pkg/slices/test`、`test/m5`、`test/mp_min`、`test/mp_map`。
- 跑 `esccheck_all.sh`，红项 0。
- 更新 `PROJECT.md` 的二进制/基线/缺陷态。
- 按域提交：`compile/gc`、`compile/compiler.go`、`compile/arch`、`pkg/memory`、
  `test/*`、`docs/stdplan`；逐域一行中文模块前缀。

## 2. 实施顺序与回退点

| 步骤 | 改动 | 回退条件 |
|---|---|---|
| 1 | 摘要精确化 + 纯内建 | `pkg/strings/test` rc 漂移或 esccheck 红项增加 |
| 2 | `freeSlot` + `freeAt/free` 状态 | 任一 farm 崩溃/rc 漂移 |
| 3 | 块尾/出口改用 `freeSlot` | double-free 或泄漏计数上升 |
| 4 | else 分支释放 | 分支测试崩溃 |
| 5 | ret 临时释放（先 x64） | 返回寄存器被破坏/崩溃 |
| 6 | ret 临时释放（x86） | 同上 |
| 7 | 汇合点/循环携带变量 | 复杂控制流测试漂移 |

每步独立构建、独立 farm；失败只回退当前步骤，不混入下一步。

## 3. 验收命令

```bash
cd /home/gx/Desktop/代码/tiny
TMPDIR=/tmp/opencode go build -o /tmp/opencode/bin/w14 .

flock /tmp/opencode/lock -c "cd /tmp/opencode && bash /tmp/opencode/run_one.sh /tmp/opencode/bin/w14 test/gcfree x86_64"
flock /tmp/opencode/lock -c "cd /tmp/opencode && bash /tmp/opencode/run_one.sh /tmp/opencode/bin/w14 test/gcfree x86"
flock /tmp/opencode/lock -c "cd /tmp/opencode && bash /tmp/opencode/run_one.sh /tmp/opencode/bin/w14 test/gcOwnership x86_64"
flock /tmp/opencode/lock -c "cd /tmp/opencode && bash /tmp/opencode/run_one.sh /tmp/opencode/bin/w14 test/gcOwnership x86"
bash /tmp/opencode/esccheck_all.sh /tmp/opencode/bin/w14
```

三连稳定判据：同一目录/架构连续 3 次 rc 相同；双 arch 均满足 `PROJECT.md` 基线。

## 4. 提交点

1. `docs: GC 修复实施计划`
2. `gc: 按参数精确化逃逸摘要并补纯内建`
3. `memory: free 状态返回与 freeSlot 幂等释放`
4. `compiler: 块尾/出口释放改用 freeSlot 并补 else 分支`
5. `gc: ret 节点 call 后释放标记`
6. `compiler: ret 后置释放与 scratch 槽`
7. `gc: if/for 汇合点与循环出口释放`
8. `test: GC 修复回归探针`
9. `docs: GC 修复收口与基线更新`

## 5. 非目标

- 不重写 allocator，不把 `free` 改成 GC；
- 不对所有对象启用 RC；
- 不做完整路径敏感/字段敏感分析；
- 不改变 `main` 的“只诊断、不生成释放”现状。
