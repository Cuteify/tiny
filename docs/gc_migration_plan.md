# GC 一级模块重构计划

> 状态：2026-11-05 立项
>
> 目标：把 GC 从 `parser/gc_*.go`、`gcfe/*.go`、`compile/gc/*.go` 三处收拢为
> 顶层 `gc` 包。parser 只负责解析与类型检查；`gc` 作为前端（parser/type check）
> 与后端（codegen）之间的独立编译环节；只有后端 `compile` 调用它。
>
> 行为验收：基线不退化 —— `泄漏=0`、`提前释放=0`、`HolderBad=0`，全语料
> 五态计数尽量逐位一致（`对象=160 · 作用域=114 · 就地=7 · 字段=1 · 转移=30 ·
> RC=8`）；允许的差异只能朝"更保守 / 更少释放"方向，且必须逐项归因。

---

## 1. 现状与问题

### 1.1 当前三套代码

| 位置 | 行数 | 职责 | 调用时机 |
|---|---:|---|---|
| `parser/gc_*.go` | 1592 | 数据模型（`Life` / `Object`）、Check 期事实收集、参数/返回值摘要 | 挂在 `VarBlock.Check` / `CallBlock.Check` / `ReturnBlock.Check` 上 |
| `gcfe/*.go` | 887 | Check 后的就地释放模拟、作用域释放点、字段 cascade、计划导出 | `package.GetPackage` 末尾 |
| `compile/gc/*.go` | 2626 | 全程序函数摘要、不动点、LLR 释放计划 | `main.go` 的 `gc.Build`；消费者是 `compile.Compiler` |

三组之间没有顶层符号冲突，合计约 5105 行。

### 1.2 耦合点

1. **parser 持有 GC 状态**
   - `VarBlock.Life`、`ArgBlock.Life`、`FuncBlock.ReturnsOwned`；
   - `parser.curScope` 由 `Node.Check` 逐层维护；
   - `VarBlock.Check` / `CallBlock.Check` / `ReturnBlock.Check` 直接调用 GC 收集器；
   - `AddChild` 解析期立即 Check，事实收集因此发生在"树还没建完"的时刻；
   - `parser.CopyLife` 是单态化深拷贝的补丁，克隆体与原件共享 `Object` 身份。

2. **GC 入口分裂**
   - 前端 `gcfe.SimulateRC` 在 `package.GetPackage` 内，Check 收敛后立即运行；
   - 后端 `gc.Build` 在 `main.go`，包合并与编译之间运行；
   - 测试直接调 `compile.Compiler.Compile` 时后端 GC 根本没跑（`LLRResults` 为空）。

3. **事实收集依赖 Check 顺序**
   - `Node.Check` 先遍历子节点、再执行自身 Check；
   - `ForBlock` 的 init/cond/incr 在循环体之后检查；
   - `IfBlock` 的条件在 then/else 之后检查；
   - 常量条件会在 Check 期 `Replace` 掉死分支；
   - 多轮 Check 只重查未通过的节点。

4. **parser 私有索引**
   - `blockNode` 由 `AddChild` 维护，`CollectNames` 顺带补全（包合并时有几处
     直接挂 `Children`，绕过 `AddChild`）；
   - `gcfe` / `gc_summary` / `gc_retsum` 都靠 `BlockNode` 反查函数节点。

### 1.3 结论

不能只做"文件搬家"：parser 里的 `Life` 是 Check 期写的，搬走文件但保留字段，
GC 仍然寄生在 parser 上。必须把事实收集改成 Check 完成后的独立 pass，并把
`Life` 换成 `gc` 内部的旁挂表（side table）。这是本计划的中心工作。

---

## 2. 目标架构

```
parser / type
    │  解析、包合并、Check 收敛；不写任何 GC 状态
    ▼
已 Check 的 AST
    │
    ▼
gc.Analyze(root)                 ← 唯一的 GC 入口（编译环节，幂等）
    ├─ collectFacts        Check 后事实收集（旁挂表）
    ├─ collectNames        绑定名反转 → Object.Names / 字段关系收敛
    ├─ simulateInplace     槽位模拟 → 就地释放
    ├─ scopeRelease        作用域释放点 + 字段 cascade
    ├─ checkPremature      自检（必须为 0）
    ├─ analyzeSummaries    参数逃逸 / 返回值来源 / 全程序摘要
    └─ computeLLRs         逐函数 LLR
    ▼
compile.Compiler.Compile
    └─ 只读 gc.Table / gc.LLRResults / *FreesForNode
```

### 2.1 调用边界（硬约束）

| 包 | 允许做的事 | 禁止 |
|---|---|---|
| `parser` | AST、类型、Check、`BlockNode` 索引 | 不 import `gc`；不持有 `Life` / `curScope` / GC 钩子 |
| `gc` | import `parser` / `type`；拥有对象表、摘要、LLR | 不 import `compile` |
| `compile` | import `gc`；在顶层 `Compile` 调 `gc.Analyze` | 不直接读 parser 里的 GC 状态（已不存在） |
| `package` | 只做解析/合并/Check | 不调 GC |
| `main` / `tools` | 需要诊断时显式调 `gc.Analyze` | 不依赖 `gcfe` / `parser.Life` |

### 2.2 唯一入口与幂等

- `gc.Analyze(root *parser.Node)`：完整流水线，重置上一轮状态，分析完成后
  缓存 `root` 指针。
- `compile.Compiler.Compile` 在**顶层**（`!c.compiling`）调用 `Analyze`；
  递归 `Compile` 与 `main.go` 的显式调用命中缓存，不重复分析。
- 单态化克隆体不进入前端五态计划；后端 `ComputeLLR` 在克隆时按现有逻辑
  重算（`compile/monomorphize.go`），与今天的行为一致。

---

## 3. 目标模块布局

```
gc/
  gc.go           Analyze 门面、幂等、重置、Objects()
  model.go        Object / FieldBinding / Disposal（原 parser/gc_model.go）
  state.go        旁挂表：varState / argState / 站点账本
  pred.go         只读判据：owningType / freshAllocExpr / isRCExpr / bareRef
  facts.go        Check 后事实收集（原 gc_write.go + gc_mark.go）
  summary.go      参数逃逸摘要（原 parser/gc_summary.go）
  retsum.go       返回值来源摘要（原 parser/gc_retsum.go）
  names.go        绑定名反转、字段关系收敛
  scope.go        作用域深度 / 外层 / 所属函数
  inplace.go      就地释放模拟（原 gcfe/inplace.go）
  release.go      作用域释放 + 字段 cascade（原 gcfe/release.go）
  plan.go         只读计划快照（原 gcfe/plan.go）
  diag.go         Premature / TransferReport（原 gcfe/diag.go）
  analyze.go      全程序函数摘要（原 compile/gc/analyze.go）
  llr.go          LLR 释放计划（原 compile/gc/llr.go）
  fnsummary.go    摘要数据结构（原 compile/gc/summary.go）
```

`gc` 内部仍沿用包级状态（对象表、摘要缓存、`Table`、`LLRResults`），因为
当前编译模型就是"单进程单根包串行编译"。`Analyze` 开头统一重置，语义与
今天的 `ResetObjects` + `Build` 一致。并行编译多个根不在本次范围。

---

## 4. 旁挂表设计

### 4.1 为什么不能保留 `Life`

`Life` 是"变量视角"的账本，字段不多但语义很细：

- 定义点：`Obj` / `Scope` / `alloc`；
- 赋值点：`OldObj`（挂在**语句自己的** `VarBlock` 上，不是定义上）；
- 使用：`Escapes` / `WroteTo` / `fromParam` / `out`；
- 参数：`arg` / `fromParam`；
- 宿主：`owner`。

`gc` 需要的正是这些字段，只是不能再把它们放在 `parser.VarBlock` 上。

### 4.2 表结构

```go
// gc/state.go
type varState struct {
    obj       *Object
    scope     parser.Block
    alloc     *Object
    releasesOld bool
    oldObj    *Object
    escapes   bool
    wroteTo   []*parser.VarBlock
    fromParam *parser.ArgBlock
    out       []paramOut
    owner     *parser.VarBlock
}

type argState struct {
    escapes bool
    out     []paramOut
}

type analysis struct {
    vars map[*parser.VarBlock]*varState
    args map[*parser.ArgBlock]*argState
    objects []*Object
    curScope parser.Block
    // 摘要缓存：param* / ret* / retOpen
}
```

- **每个 `VarBlock` 节点**都有一项（语句自己的 `releasesOld` / `oldObj` /
  `alloc` 必须按节点存）。
- 定义/引用解析沿用 `Define`：
  - `Define.Value == *VarBlock` → 该项就是定义账本；
  - `*ArgBlock` → 参数账本，首次访问置 `escapes = true`（等价于
    `ArgBlock.Check` + `LifeOf` 的副作用）；
  - `*typeSys.StructField` → 沿 `Define.Path` 找首个 `VarBlock` / `ArgBlock`。
- `HostOf(v)` / `LifeOf(v)` / `Alloc()` 等改为 `gc` 内部方法，语义逐条对齐。

### 4.3 单态化

删除 `parser.CopyLife` 与 `compile/monomorphize.go` 里的调用：

- 前端五态计划不消费克隆体（今天也没有正确消费：`Object.Names` / `Holder`
  仍指向原树）；
- 后端 LLR 由 `ComputeLLR` 从克隆体 AST 重算，不读旁挂表；
- 因此删除后代码生成路径不变。克隆体若出现在后续 `Analyze` 中，会被当作
  新节点重新收集，不会读到原树状态。

---

## 5. Check 后事实收集 pass

### 5.1 遍历顺序

复刻 `Node.Check`：

```
walkNode(n):
    saved := curScope
    if IsScopeBlock(n.Value): curScope = n.Value
    for child in n.Children: walkNode(child)
    if n.Value is IfBlock && ElseBlock != nil: walkNode(ElseBlock)
    nodeFacts(n.Value)
    curScope = saved
```

`nodeFacts` 按节点类型补齐 Check 期收集器的贡献：

| 节点 | 处理 |
|---|---|
| `VarBlock` | `walkExpr(v.Value)` 收集表达式内调用点；再 `markVar(v)`（定义/赋值/字段写三形态） |
| `CallBlock` | `markArgs(cb)`（语句位置的调用） |
| `ReturnBlock` | `markRets(enclosingFunc, rb.Value)` |
| `ForBlock` | 依次 `walkExpr(Range/Init/Condition/Increment)`；在循环体**之后**，与 `f.Check` 一致 |
| `IfBlock` | `walkExpr(Condition)`；在 then/else 之后，与 `i.Check` 一致 |
| `SwitchBlock` / `CaseBlock` | `walkExpr(Target)` / `walkExpr(Values...)` |
| `FuncBlock` | `walkExpr(Args[].Default/Value)`；在函数体之后，与 `f.Check` 一致 |
| `DeferBlock` | `markArgs(d.Call)` |

`walkExpr(e)`：

1. 若 `e.Call != nil` → `applyMarks(collectArgs(nil, e.Call))`；
2. 递归 `Left` / `Right` / `Index` / `ListElems`；
3. 不处理裸 `e.Var` 的逃逸 —— 逃逸由上下文决定（实参摘要 / return / 全局写）。

调用点事实（`mkEscape` / `mkParamOut`）幂等，重复施加无害；`mkInit` 只在
定义点触发一次，单趟遍历不会出现多轮覆盖问题。

### 5.2 与多轮 Check 的差异

- 包合并后的第一轮 `rootNode.Check()` 是完整遍历，绝大多数事实在这一轮写入；
- 后续轮次只重查未通过的节点；`mkInit` 会清掉该定义上的旧事实，再由同轮
  后续语句重建；
- 新 pass 在最终 AST 上做一次完整、确定顺序的遍历。对正常收敛的语料，
  两者应当一致；对前向引用/跨包重查的边角，允许差异，但必须由对拍工具
  逐项确认方向安全。

### 5.3 前置条件

- `package.GetPackage` 已跑完 Check 收敛；
- `parser.RebuildBlockIndex(root)` 已重建 `blockNode`（新增导出 API，替代
  `CollectNames` 的副作用）；
- 常量条件 `Replace` 已发生，死分支不在最终树里。

### 5.4 等价性对拍（关键闸门）

在删除 `parser.Life` **之前**，让新旧两条链路并跑：

```bash
# 旧：GetPackage 内的 Check 期收集 + gcfe.SimulateRC
# 新：GetPackage 之后 gc.CollectFactsAST(root) + gc 的 names/inplace/release
go run ./tools/gcfactdiff -o /tmp/gcfactdiff ./test/<dir>
```

> 该工具只服务于 Stage 2 双轨期：Stage 3 删除 parser 钩子后已一并删除，
> 对拍结论保留在附录 B。

对拍内容：

- 对象数、五态分布、`FreeScope` / `Holder` / `Inplace` / `FieldOwner`；
- `Object.Names`（排序后）与 `FieldVals`（字段 + 对象 ID）；
- 逐对象的 `Disposal` 文本。

通过条件：全语料 106 个成功目录**逐位一致**；若不一致，逐条归因并只接受
"新链路更保守"的差异，同时把差异记录在本文档的验收附录里。

---

## 6. 分阶段实施

### Stage 0：基线快照（0.5 天）

- `go build ./...`、`go test ./...` 记录结果；
- 全语料 `tools/esccheck` 汇总，保存 JSON/文本到 `/tmp`（不入库）；
- 对 GC 重点目录保存 `_main.asm`（x86 / x86_64）作为后续逐字节对比基准；
- 记录当前 `HEAD` 与 `ast.html` 等工作区状态。

**回滚点**：无代码改动。

### Stage 1：顶层 `gc` 包 + 后端迁移（0.5 天）

- `mkdir gc; git mv compile/gc/*.go gc/`；
- `package gc` 不变，import 路径 `cuteify/compile/gc` → `cuteify/gc`；
- 更新 `compile/compiler.go`、`compile/monomorphize.go`、`main.go`、
  `tools/gcdiff`、`tools/retsumcheck`；
- 不改任何逻辑。

**验收**：`go build ./...`；`go test ./...` 与 Stage 0 相同；重点目录
`_main.asm` 逐字节一致。

**回滚**：`git revert` 单个提交即可（纯路径改动）。

### Stage 2：`gc` 内事实收集器 + 双轨对拍（2–3 天）

- 新增 `gc/state.go`、`gc/facts.go`、`gc/scope.go`、`gc/names.go`；
- 把 `gc_pred.go` / `gc_summary.go` / `gc_retsum.go` 的语义搬进 `gc`，
  改为读旁挂表；
- `gc.CollectFactsAST(root)` 只做收集，不碰 `parser.Life`；
- `gc.Analyze` 暂时仍可委托旧 `gcfe`（或提供 `gc.AnalyzeLegacy`）；
- 新增临时对拍工具 `tools/gcfactdiff`（Stage 3 删除），并跑 §5.4 的全语料对拍；
- 保持 `package.GetPackage` / `gcfe` / parser 钩子原样。

**验收**：对拍全绿；`go test ./...` 不变；代码生成路径完全未变。

**回滚**：只新增文件与工具，删除即可。

### Stage 3：切换入口、删除 parser 内 GC（2 天）

一次提交完成以下原子改动：

1. `gc.Analyze` 切到新收集器，产出 `gc.Objects()` / 五态计划；
2. 删除 `parser/gc_*.go`；
3. 删除 `VarBlock.Life`、`ArgBlock.Life`、`FuncBlock.ReturnsOwned`；
4. 删除 `parser.curScope`、`VarBlock.Check` / `CallBlock.Check` /
   `ReturnBlock.Check` 里的 GC 钩子、`ArgBlock.Check` 的 `Escapes` 置位、
   `parser.markFuncOpen/markFuncClosed`；
5. 删除 `gcfe/` 整个目录；
6. `package.GetPackage` 删除 `ResetObjects` 与 `gcfe.SimulateRC`；
7. `parser.CollectNames` 删除，替换为 `parser.RebuildBlockIndex(root)`；
8. `compile/monomorphize.go` 删除 `parser.CopyLife` 调用；
9. `tools/esccheck` / `tools/gcdiff` / `tools/retsumcheck` 改读 `gc` 的导出版。

**验收**：

- `go build ./...`、`go vet ./...`；
- 全语料 `gc.Plan` 与 Stage 0 基线逐位一致（Stage 2 的临时 `gcfactdiff` 已先行验证）；
- 重点目录 `_main.asm` 与 Stage 0 逐字节一致（后端 GC 未变）；
- `泄漏=0 / 提前释放=0 / HolderBad=0`。

**回滚**：该提交整体 revert；Stage 2 的新收集器保留，可回退到双轨状态。

### Stage 3.5：gc 内聚简化（0.5 天，2026-11-05）

入口切换后、接线前做一次行为不变的清理：

- 删除只写字段与死导出（`analysis.owns`、`Object.allocSite`、
  `CalleeKnown`、`DumpSummary`、`DumpFrees`、`isRep` 等）；
- `isOwning` → `owningType`、`isRCAlloc` → `isRCExpr`，判据只留一份；
- `Stats` 与 `Plan.Summary` 共用 `PlanSummary.countObject`；`BuildPlan`
  的块编号与就地释放收集合并为一次 AST 遍历；
- 删除无调用方的 `gc.Reset`（`Analyze` 换根时自动重置）。

**验收**：五态基线 `160/111/6/1/30/12`，泄漏 / 提前释放 / HolderBad 全 0；
106 个成功目录的 `gcfe_plan.json` 与 Stage 3 逐位一致。

### Stage 4：接线与工具（0.5 天）

- `compile.Compiler.Compile` 顶层调用 `gc.Analyze(node)`；
- `main.go` 显式调用 `gc.Analyze` 以便 dump，随后 `Compile` 命中幂等缓存；
- `tools/gcdiff` 改用 `gc.Analyze` + `gc.Plan`；
- `tools/retsumcheck` 改用 `gc.RetSourceOf`；
- `tools/esccheck` 改用 `gc.Objects` / `gc.TransferReport`；
- 删除 `gc.Build`（或保留为 `Analyze` 的薄别名，二选一，优先删除）。

**验收**：

- 直接调用 `co.Compile` 的测试现在也会跑 GC；`go test ./...` 通过；
- `go run . ./test/<dir>` 两种架构均能编译/链接/运行；
- 全语料基线不变。

### Stage 5：收尾（0.5 天）

- 更新 `docs/gc_api.md`、`docs/gc_frontend_design.md`、
  `docs/GC_MEMORY_MANAGEMENT.md` 的入口与符号位置；
- 清理运行产物（`ast.html` 恢复，不提交 `gc_llr.txt` / `gc_summary.json` /
  `_main.asm` 的新改动）；
- 提交（不 push）。

---

## 7. 验收矩阵

### 7.1 编译与单测

```bash
go build ./...
go test ./...
```

既有 3 个 fixture 路径失败（`TestFullSyntaxParse` / `TestFullSyntaxCompile` /
`TestListParseAndCompile`）若仍存在，需与 Stage 0 对照，不得新增失败。

### 7.2 全语料前端基线

```bash
for d in test/*/; do go run ./tools/esccheck "$d"; done
```

目标（Stage 3 切换后的新链基线）：

```
对象=160  作用域=111  就地=6  字段=1  转移=30  RC=12
泄漏=0    提前释放=0  HolderBad=0
106 成功 / 9 既有失败
```

### 7.3 计划对拍

- Stage 2：临时工具 `tools/gcfactdiff`（Stage 3 已删除）验证新旧计划逐位一致；
- Stage 4：`gc.Plan` 与 Stage 0 的前端计划 JSON 深度相等（对象 ID 可重排，
  但按 owner/函数/处置归一后必须一致）。

### 7.4 代码生成与运行

重点目录（覆盖 7 类释放点）：

| 目录 | 覆盖 |
|---|---|
| `test/gc_loop` | 出口 / 字段 / 链式分配 |
| `test/gcOverwrite` | 覆盖赋值就地释放 / 字段别名 |
| `test/gcCondTemp` | 条件临时（后端） |
| `test/gcRetFree` | ret 临时（后端） |
| `test/gcBlocks` | 块尾 / 循环出口 |
| `test/gcStructFree` | 字段 cascade |
| `test/heap_new` | 直接 new / CallsAny |
| `test/gcprobe` | RC 基线 |

每个目录跑 `./test_run.sh test/<dir> x86 x86_64`，退出码与 Stage 0 一致；
`_main.asm` 与 Stage 0 逐字节比对（Stage 1/3/4 的生成路径不应变化）。

### 7.5 模块边界

```bash
# parser 不得再出现 GC 符号
rg "Life|gcfe|ResetObjects|CollectNames|curScope|markVar|markArgs|markRets" parser/

# gc 不得 import compile
rg "cuteify/compile" gc/

# package 不得 import gc
rg "cuteify/gc" package/
```

---

## 8. 风险与对策

| 风险 | 影响 | 对策 |
|---|---|---|
| Check 期与后置 pass 顺序不等价 | 对象身份/五态变化，可能提前释放 | Stage 2 双轨对拍；只接受更保守差异；`checkPremature` 必须为 0 |
| `blockNode` 索引缺失 | 作用域深度/函数归属退化 → 释放点错误 | `RebuildBlockIndex` 在 `Analyze` 开头无条件重建；对每个 `FuncBlock` 断言可反查 |
| 单态化克隆读不到旁挂表 | 克隆体 LLR 为空 | 后端 LLR 本来就按克隆体 AST 重算；删除 `CopyLife` 后专门跑泛型语料 |
| `Compile` 内新增 `Analyze` 改变测试行为 | 原先不跑 GC 的调用方现在会插 free | Stage 4 单独提交；`go test ./...` + 双架构 e2e 对照 |
| 重复 `Analyze` | 对象表翻倍 / 双重释放 | `analyzedRoot` 幂等缓存；`Analyze` 开头重置 |
| 工具依赖旧符号 | `go build ./...` 失败 | Stage 3 同提交更新 tools；Stage 4 再收敛 API |
| 性能回退 | 编译变慢 | 记录 `go test -bench BenchmarkCompiler` Stage 0/4 对比；Analyze 只多一遍 AST 扫描 |
| 全局状态并发 | 并行编译串数据 | 与今天一致；文档明确"单进程单根包串行"前提，不扩大范围 |

---

## 9. 明确不做的事

以下都是既有语义缺口，本次只搬家、不改行为：

- 表达式临时对象（`ret f()` 嵌套 owning call、条件/增量临时、`obj.f = new(T)`）
  的前端建模；
- 字段 cascade 的右值对象覆盖；
- 单态化克隆体的前端五态计划（只保证后端 LLR 重算）；
- `compile/compiler.go` 中 Win64 GC 释放调用仍硬编码 SysV `RDI`；
- Batch E 的嵌套调用保守逃逸；
- 新的优化、新的释放类别。

---

## 10. 提交与回滚策略

- 每个 Stage 一个提交，提交信息统一 `refactor(gc): ...`；
- 不 push；
- 运行产物（`ast.html`、`gc_llr.txt`、`gc_summary.json`、`_main.asm`）不进入
  提交；`ast.html` 在提交前恢复；
- Stage 1 / Stage 2 都是可独立回滚的低风险提交；Stage 3 是原子切换点，
  回滚即恢复 parser 内 GC；Stage 4 只动接线，回滚不影响分析实现。

---

## 附录 A：历史基线（2026-11-04，迁移前）

全量 `test/` 115 个目录，106 成功、9 个既有失败：

```
对象=160  作用域=114  就地=7  字段=1  转移=30  RC=8
泄漏=0    提前释放=0  HolderBad=0
```

- `[]T` 修复前 `117 / 6`；修复后对象 132、RC 8。
- 返回值摘要（Batch B）把对象 132→160、转移 24→30、作用域 92→114。
- 严格 Fresh：全语料 38 个 `Fresh` 函数；`front=Fresh && back!=Fresh` 为 0。

Phase 1 对拍（`tools/gcdiff`，106 个成功目录）：

| 侧 | 指标 |
|---|---|
| 前端 `gcfe` | 对象 160；作用域 114；就地 7；字段 1；转移 30；RC 8；真泄漏 0；HolderBad 0 |
| 后端 `compile/gc` | 有释放计划的函数实例 132；出口 204；块尾 67；循环出口 53；覆盖 3；字段 94；临时 48（ret 40 / cond 8 / incr 0） |

这些数字是本次重构的回归基准，不是优化目标。

---

## 附录 B：Stage 2 双轨对拍验收（2026-11-05）

对拍命令（逐目录；该工具为 Stage 2 临时件，Stage 3 已删除）：

```bash
go run ./tools/gcfactdiff ./test/<dir>
```

语料口径：`test/` 下 114 个含 `.cute` 的目录，106 个成功，8 个既有解析失败
（`buildKeyword` panic、`fnptr_test`、`iface_dispatch`、`overload`、
`stringUtils`、`switch_test`、`test copy`、`w3probe`），与迁移前一致。

- 104 个目录：`mismatch obj=0 stmt=0`，五态逐位一致；
- 106 个成功目录：`提前释放=0`、`HolderBad=0`、`泄漏=0`；
- 2 个目录存在差异，均为新链更保守（释放更晚）：

| 目录 | 旧链 obj/scope/rc/inplace/field/transfer | 新链 obj/scope/rc/inplace/field/transfer |
|---|---|---|
| `test/gc_loop` | 10 / 2 / 5 / 1 / 0 / 2 | 10 / 0 / 8 / 0 / 0 / 2 |
| `test/gc_complex` | 24 / 18 / 0 / 0 / 0 / 6 | 24 / 17 / 1 / 0 / 0 / 6 |

逐项归因：

- 两处差异同源：`prepend` / `linkPrepend` 的 `n.next = head` 把入参存进新对象字段。
  旧链的参数摘要是 Check 期**懒算并永久缓存**的：首次查询发生在字段左值类型
  尚未解析完时，`scanFuncFacts` 跳过该字段写，`ground[head]=false` 被 memo 固化；
  调用点因此不把实参标成逃逸。新链在 Check 收敛后统一计算摘要，能看见这条
  字段边，`head` 实参升级逃逸 → 由作用域/就地释放退回 RC。
- `test/gc_loop` 的 3 个对象：`main:head`（#7，旧链就地释放；新链 RC）、
  `main:head`（#9）与 `main:big`（#10，旧链作用域释放；新链 RC）。
- `test/gc_complex` 的 1 个对象：`main:head`（#12，旧链作用域释放；新链 RC）。
- 方向安全性：旧链的就地释放发生在 `head = prepend(head, …)` 覆盖点，但新
  返回节点仍通过 `.next` 指着旧 `head` —— 这是潜在的 use-after-free；新链
  不再提前释放，只推迟到 RC 归还。因此差异属于“更保守 / 更少释放”，接受。

全语料聚合（106 成功目录）：

```
旧链：对象=160  作用域=114  就地=7  字段=1  转移=30  RC=8
新链：对象=160  作用域=111  就地=6  字段=1  转移=30  RC=12
      泄漏=0    提前释放=0   HolderBad=0
```

Stage 3 切换后以新链聚合值为回归基线；`对象 / 字段 / 转移` 不变，
`作用域 −3 / 就地 −1 / RC +4` 即上表两处归因的全部差异。

