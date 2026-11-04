# GC 分析 API 与调用流程

> 与 `gc_frontend_design.md` 的分工：设计文档讲“为什么”（原理、取舍论证）；
> 本文讲“谁调用谁、谁提供什么”，是接入与排查用的事实参考。
>
> GC 已收拢到顶层 `gc` 包：`gc.Analyze(root)` 是唯一入口，前端对象级五态
> 分析与后端全程序摘要 / LLR 都由它串起来。`parser` 不再持有 GC 状态，
> 旧的 `parser/gc_*.go`、`gcfe/`、`compile/gc/` 已删除。
>
> 当前基线（`scripts/gc_corpus_check.sh`）：106 成功 / 9 既有失败 ·
> 对象=160 · 作用域=111 · 就地=6 · 字段=1 · 转移=30 · RC=12 ·
> 泄漏=0 · 提前释放=0 · HolderBad=0。

---

## 1. 调用流程总览

### 1.1 唯一入口

```
package.GetPackage(path)
  └─ 解析、包合并、Check 跑到收敛（≤50 轮）
        │
        ▼
compile.Compiler.Compile(root)
  └─ 顶层（非递归）调用 gc.Analyze(root)     ← 唯一 GC 入口，按根指针幂等
       ├─ CollectFront(root)                 前端：对象级五态计划
       └─ analyzeBackend(root)               后端：FnSummary + LLRResults
```

调用点：

| 调用方 | 行为 |
|---|---|
| `compile.Compiler.Compile` | 顶层入口自动调用；递归 `Compile` 不会重入 |
| `main.go` | 先显式 `gc.Analyze` 以便打印 / 落盘摘要，随后 `Compile` 命中缓存 |
| `tools/esccheck`、`tools/gcdiff` | 显式 `gc.Analyze` 后读诊断面 |
| `tools/retsumcheck` | 显式 `gc.Analyze` 后读 `gc.RetSourceOf` |

`Analyze` 对同一根 AST 重复调用直接返回；换根时先清空再重算。
单进程单根包串行编译是既有前提，不承诺并发安全。

### 1.2 前端：一次后置 pass

`CollectFront(root)` 在 Check 收敛之后按最终 AST 完整走一遍，复刻原 Check
期钩子的事实语义，但不再依赖多轮 Check 的中间形态：

```
parser.RebuildBlockIndex(root)   补全 Block → Node 反向索引
a.collectFacts(root)             收集正向事实（mark），逐站点施加
a.collectNames(root)             反转绑定名：Object.Names、字段关系收敛
rcSim.walk(root)                 按语句顺序模拟槽位 / 字段表 → ReleasesOld
a.scopeRelease()                 释放点 = 全部绑定名里最外层的作用域
a.checkPremature()               自检：释放点不得早于任何绑定名 → 必须 0
```

| 步骤 | 输入 | 产出 | 要点 |
|---|---|---|---|
| collectFacts | 最终 AST | `binding` / `Object` 正向事实 | 遍历顺序复刻 `Node.Check`；只写正向事实，不撤销 |
| collectNames | 绑定关系 | `Object.Names`、`FieldVals` | `wroteTo` 记在右值：顺序覆盖也算持有（释放点偏外=安全） |
| rcSim.walk | 语句序 | `binding.releasesOld` / `oldObj` | 旧值再无槽位 / 字段引用才就地释放；调用点不处理 |
| scopeRelease | Names / Scope | `FreeScope`、`Holder` | 取最外层；算不出兜底函数出口 + 创建者槽；逃逸 / 转移跳过 |
| checkPremature | 全对象 | `Premature`（必须 0） | 释放点深度不得早于任一绑定名作用域 |

### 1.3 后端：摘要 + LLR

`analyzeBackend(root)`：

1. `collectFuncs`：递归收集 `FuncBlock`，键为 `fb.Name.String()`；
2. 初始化 `FnSummary`：owning 参数建 `ParamSummary`，owning 返回值先记
   `RetOwned` / `RetEscape=EscCaller` / `RetKind=RetUnknown`；
3. 不动点迭代：沿调用边传播参数逃逸、堆分配、未知调用、全局存储；
4. `tightenParams`：快照 + 重算的 Jacobi 迭代，收紧早期误提升；
5. 对每个函数 `ComputeLLR`，写入 `LLRResults`；
6. 排序参数、写回 `RetEscape`。

`analyzeBackend` 每次重建 `Table` 与 `LLRResults`；换根不会串表。

### 1.4 返回值来源摘要：RetSourceOf（严格 Fresh）

`freshAllocExpr` 不读旧 `ReturnsOwned`，而是问语法摘要：

```
RetSourceOf(fb)
  ├─ 返回类型非 owning / 无 return       → ReturnNone / ReturnUnknown
  ├─ 函数体仍在解析（busy）              → ReturnUnknown，且不缓存
  ├─ 逐 return 语句 exprRetKind
  │    ├─ new(T) / new([]T, n)           → Fresh
  │    ├─ nil / 空串字面量               → Fresh
  │    ├─ ret f() 且 f 摘要 Fresh        → Fresh（递归，环记 Unknown）
  │    ├─ 参数本身                       → Alias
  │    ├─ 参数对象的字段 / 索引          → Borrow
  │    ├─ 局部变量 → 所有赋值来源求并集
  │    └─ 字段读 / 未知调用 / 取地址局部 → Unknown
  └─ 全部路径合并：只有全 Fresh 才是 Fresh
```

契约：只有 `ReturnFresh` 允许调用方 claim 并自动释放；任一分支是
alias / borrow / unknown，整个函数就是 `ReturnUnknown`——方向永远是少释放。

---

## 2. 端到端示例

### 2.1 覆盖写与就地释放

```
var a: *Node = new(Node)      // claim 对象 #k；a 是绑定名
var b: *Node = a              // 裸引用：alias + wroteTo → #k.Names = [a, b]
b = new(Node)                 // 覆盖点：记录旧对象 #k，再 claim #m
                              // rcSim：#k 仍有 a 指着 → 不就地释放；
                              // FreeScope = max(a.Scope, b.Scope)
b = b.next                    // 字段读：记录旧对象 #m
                              // rcSim：#m 再无槽位 / 字段引用
                              // → ReleasesOld=true，赋值前先 free #m
```

### 2.2 返回转移与调用方接管（test/gc_loop 的 prepend）

```
fn prepend(head: *Node, val: int) *Node {
    var n: *Node = new(Node)   // claim #a
    n.next = head              // 字段写：源是参数，不产生可释放边
    ret n                      // #a.Transferred = true，callee 不再释放
}
caller:
    head = prepend(head, 4)
    // RetSourceOf(prepend)==ReturnFresh → 调用方 claim 新对象
    // 实参 head 按参数摘要判逃逸：prepend 把参数存进了字段
    // → 旧对象 Escapes → RC，而不是作用域释放
```

---

## 3. API 参考

### 3.1 包级入口与全局表

| 符号 | 语义 |
|---|---|
| `func Analyze(root *parser.Node)` | 完整流水线；Check 收敛后调用；按根指针幂等 |
| `func CollectFront(root *parser.Node)` | 只跑前端五态链，结果进包级 `front`；诊断 / 计划用 |
| `var Table map[string]*FnSummary` | 函数全路径名 → 后端摘要 |
| `var LLRResults map[string]*LLRResult` | 函数全路径名 → 语句级释放计划 |

### 3.2 诊断面（工具消费）

| 符号 | 语义 |
|---|---|
| `func Stats() PlanSummary` | 五态聚合；与 `Plan.Summary` 共用同一计数 |
| `func BuildPlan(root *parser.Node) Plan` | 只读计划快照：对象、字段绑定、就地释放语句 |
| `func Objects() []*Object` | 全部对象，只读线性快照 |
| `func Premature() (int, []string)` | 提前释放计数与明细（必须 0） |
| `func TransferReport() (sent, taken, orphan int, detail []string)` | 转移统计；`orphan` 只看结构，真泄漏看五态 |
| `func ParamEscapes(calleeKey string, idx int) Escape` | 第 idx 个参数的逃逸层级；无摘要返回 `EscAny` |
| `func RetSourceOf(fb *parser.FuncBlock) ReturnKind` | 返回值来源摘要（严格 Fresh） |
| `func ComputeLLR(fnKey string, fb *parser.FuncBlock, fs *FnSummary, body *parser.Node) *LLRResult` | 单函数 LLR；单态化克隆体会重算 |
| `func RetFreesForNode / CondFreesForNode / IncrFreesForNode` | 按 AST 节点查 LLR 计划 |
| `func DumpAll(w io.Writer) error` | 按名字排序输出全部摘要 |
| `func DumpLLRs() string` / `func DumpLLR(res *LLRResult) string` | LLR 可读 dump |

五态收口（`DisposalOf` 判定序）：`Inplace` → `Transferred`(Borrow) →
`FieldOwner` → `Escapes`(RC) → `FreeScope==nil`(Borrow) → `Scope`。
前三种释放点（Inplace / Field / Scope）互斥，同一对象只允许一个释放点。
`HolderBad` 单独校验作用域 / 字段释放读的槽：必须是该对象的绑定名，
且活到释放点。

### 3.3 前端内部（`gc/*.go`）

| 文件 | 职责 |
|---|---|
| `front.go` | `CollectFront` 五步编排 |
| `facts.go` | 后置事实收集：变量 / 字段 / 调用 / 返回；`mark` 全集与施加 |
| `state.go` | 旁挂账本 `binding` / `analysis`；`Objects` 只读访问 |
| `model.go` | `Object`、`FieldBinding`、`Disposal` / `DisposalOf` |
| `names.go` | `walkSubNodes` + 绑定名反转 |
| `inplace.go` | 槽位表 / 字段表模拟，就地释放判定 |
| `release.go` | 作用域释放点 + 最小字段 cascade |
| `scope.go` | 作用域深度 / 外层 / 可读身份 / 所属函数 |
| `pred.go` | `owningType` / `copiesFields` / `freshAllocExpr` / `bareRef` 等判据 |
| `paramsum.go` | 参数逃逸摘要（最小定点、懒算） |
| `retsum.go` | 返回值来源摘要（严格 Fresh） |
| `plan.go` | `Plan` / `PlanSummary` / `BuildPlan` |
| `diag.go` | `Stats` / `Premature` / `TransferReport` / Holder 校验 |

### 3.4 后端内部（`gc/*.go`）

| 文件 | 职责 |
|---|---|
| `analyze.go` | 函数收集、不动点、参数收紧、返回值来源、`ParamEscapes` |
| `summary.go` | `Mode` / `Escape` / `RetKind` / `FnSummary`；`Table`、`LLRResults`、dump |
| `llr.go` | 语句级 LLR：抽象对象、绑定、七类释放点、节点级查询 |

---

## 4. 数据模型速查

### 4.1 写入形态优先链（`collectVar`）

```
1. 定义点：mkInit + mkScope 先发（清账；作用域不能被 owning 闸门挡掉）
2. !owningType(v.Type)       → 到此为止
3. 全局左值                  → mkEscape + mkWroteTo + collectExpr(全逃逸)
4. 右值是 newRC()            → mkObjNil（生命周期手工管）
5. 覆盖点（非定义）          → mkOldObj 先记旧对象
6. freshAllocExpr(右值)      → mkObjClaim
7. 裸引用右值                → mkObjAlias + mkWroteTo + mkFromParam
8. 其余（字段读 / 索引 / 调用结果 / 字面量）→ mkObjNil（借用）
```

施加序：同一站点内 `mkOldObj` 先于 `mkObj*`；`mkInit` / `mkScope` 最前。

### 4.2 `binding` 字段（`state.go`；替代旧的 `Life`）

| 字段 | 写入者 | 消费者 |
|---|---|---|
| `obj *Object` | claim / alias / nil | DisposalOf / scopeRelease / Holder |
| `scope parser.Block` | mkScope（定义点） | scopeRelease / checkPremature |
| `alloc *Object` | claim 复用 | claim |
| `releasesOld bool` / `oldObj *Object` | rcSim 就地释放 | 计划导出 |
| `escapes bool` | markEscapes 级联 | DisposalOf → RC |
| `wroteTo []*parser.VarBlock` | mkWroteTo（记在右值） | collectNames 补 Names |
| `arg / fromParam / out` | 参数基线 / mkFromParam / mkParamOut | 参数逃逸摘要 |
| `owner *parser.VarBlock` | mkInit | IsRep 语义 / mkWroteTo / bindField |

参数由调用者持有 → `argState` 创建即打 `escapes`，本帧永不自动释放参数块。

### 4.3 `Object` 字段（`model.go`，全导出）

| 字段 | 写入者 | 用途 |
|---|---|---|
| `ID int` | newObject | 诊断 / 表索引 |
| `Owner *parser.VarBlock` | claim | 兜底 Holder |
| `Scope parser.Block` | claim | funcOfBlock 兜底 |
| `Escapes bool` | markEscapes / collectNames | Disposal → RC |
| `Transferred bool` | mkTransferObj | callee 不释放 |
| `Names []*parser.VarBlock` | collectNames | FreeScope 取最外层 / Holder 核对 |
| `FreeScope parser.Block` | scopeRelease | free 点；nil = 不按作用域释放 |
| `Holder *parser.VarBlock` | scopeRelease | free 读哪个槽 |
| `Inplace bool` | rcSim | Disposal → Inplace，出口不得重复 free |
| `FieldOwner *Object` / `FieldName string` | fieldRelease | 随容器字段释放 |
| `FieldVals []FieldBinding` | bindField + collectNames | 字段 cascade 与排序 |

### 4.4 mark 全集（`facts.go`）

| flag | 发出者 | 施加动作 |
|---|---|---|
| `mkInit` | collectVar | `initBinding`：清账保 alloc，owner = v |
| `mkScope` | collectVar | `binding.scope = curScope` |
| `mkOldObj` | collectVar | 语句块 `oldObj = l.obj` |
| `mkObjClaim` | collectVar | `claim` |
| `mkObjAlias` | collectVar | `unify` |
| `mkObjNil` | collectVar | `l.obj = nil` |
| `mkWroteTo` | collectVar | `src.wroteTo += l.owner` |
| `mkFromParam` | collectVar | `l.fromParam = src.paramRoot()` |
| `mkFieldBind` | collectField | 容器 `bindField(name, src.owner)` |
| `mkParamOut` | collectArgs / scanFuncFacts | `l.out += paramOut{cb,i}`（按 cb+i 判重） |
| `mkTransferObj` | collectRet | `o.Transferred = true` |
| `mkEscape` | 多数站点 | `markEscapes`：变量 / 对象 / 参数链三级级联 |

### 4.5 判据谓词（`pred.go`，只读）

| 谓词 | 一句话 | 拿不准时 |
|---|---|---|
| `owningType(t)` | `t.IsOwning` 的 nil 安全包装 | Type 未解析 → false |
| `copiesFields(t)` | 接口 / any，或含 owning 字段的值类型 | true → 源标逃逸 |
| `fieldTypeOwning(t, f)` | 结构体字段是否带堆指针 | — |
| `freshAllocExpr(e)` | new、`RetSourceOf==ReturnFresh`、字符串拼接 | false → 不 claim |
| `isRCExpr(e)` | `Call.IsRC`（newRC） | true → 跳过 claim 与自动释放 |
| `bareRef / bareVar` | 纯变量引用 | nil → 按借用 / 孤立 |

---

## 5. esccheck 用法与基线

```bash
go build -o /tmp/esc ./tools/esccheck
CUTE_ROOT=$PWD /tmp/esc ./test/<目录>   # 每个目录独立进程
```

全量跑法与聚合用 `scripts/gc_corpus_check.sh`（在临时目录运行，避免污染
工作区）：

```
成功=106 失败=9
对象=160 作用域=111 就地=6 字段=1 转移=30 RC=12
泄漏=0 提前释放=0 HolderBad=0
```

- 失败目录是既有解析失败，不是 GC 回归；
- `泄漏=0` 表示五态都不沾的对象为 0；
- `提前释放=0` 挂在 `checkPremature` 上，必须恒 0；
- `HolderBad=0` 表示作用域 / 字段释放读的槽合法且活到释放点；
- 基线变更必须先逐条归因，再更新脚本中的 `EXPECT_*` 默认值。

---

## 6. 后端接入边界

代码生成（`compile.Compiler`）读的是 `gc.Table` 与 `gc.LLRResults`，不是
前端 `Object`。前端五态计划目前只由 `tools/esccheck` / `tools/gcdiff`
消费，用于验证“对象级归属”与后端语句级释放是否一致。

| 检查面 | 覆盖 | 不能覆盖 |
|---|---|---|
| `tools/esccheck` | 前端对象归属 / 五态 / Holder | 后端实际是否发出 `free` |
| `tools/gcdiff` | 前端计划 vs 后端 LLR 的函数级差异 | 运行时可达性 |
| `gc_llr.txt` / `DumpLLRs` | 语句级释放计划 | 汇编里是否真的走到 |
| `_main.asm` | 实际释放代码与位置 | 运行时路径 |

纪律：

- 不要绕开 `DisposalOf` 自己拼五态条件；
- 不要给 `Inplace` / `FieldOwner` 对象再设独立出口释放；
- `newRC` 块按手工 RC 语义管，不进自动释放清单；
- 单态化克隆体在 `compile/monomorphize.go` 里用原函数摘要重算 LLR，
  节点键必须是克隆后的 AST。

---

## 7. 现状备注

- `parser` 只保留 `RebuildBlockIndex` / `BlockNode` 等树基建，不再有 GC
  字段或钩子；`gc` 单向依赖 `parser` / `type`；
- 长期验证脚本在 `scripts/`：`gc_corpus_check.sh` 锁基线，
  `gc_asm_diff.sh` 做双二进制汇编对比，`normasm.py` 归一化随机标签；
- `ast.html` 是解析调试副产物（`parser/parser.go`），运行会整体重写，
  提交前需 `git checkout -- ast.html`；
- 运行产物（`gc_llr.txt`、`gc_summary.json`、`_main.asm`）不提交。
