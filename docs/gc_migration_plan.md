# 前端 GC 对比与接入计划

> 状态（2026-11-04）：前端 GC 已从 `parser` 中拆出 Check 后的驱动层
> （`gcfe`），修复 `[]T` 的 owning 判据，并完成 Phase 1 只读对拍
> （`gcfe.BuildPlan` + `tools/gcdiff`）。**代码生成权威仍是 `compile/gc`**；
> 本文给出两套模型的实测差异、切换阻塞项和建议的 rollout 顺序。
>
> 相关文档：`gc_frontend_design.md`（前端模型设计）、`gc_api.md`（API）、
> `GC_MEMORY_MANAGEMENT.md`（后端 LLR 现状与缺口）。

---

## 1. 两套链路的位置

```
package.GetPackage
  ├─ 解析 / 包合并 / Check 收敛
  └─ gcfe.SimulateRC(root)          ← 前端模型（本文的“新链”）
        ├─ parser.CollectNames
        ├─ gcfe.inplace（槽位模拟）
        ├─ gcfe.scopeRelease（释放点）
        └─ gcfe.checkPremature（自检）

main.go
  ├─ gc.Build(ast)                  ← 后端模型（当前权威）
  │    ├─ analyze.go：全程序 FnSummary
  │    └─ llr.go：逐函数 LLRResult
  └─ compile.Compiler.Compile(ast)
       └─ 按 gc.LLRResults 生成 7 类释放代码
```

| 维度 | 前端 `gcfe` 链 | 后端 `compile/gc` 链 |
|---|---|---|
| 输入 | 包合并 + Check 收敛后的 AST | 同一份 AST，但在 `main.go` 中更晚执行 |
| 分析单位 | 对象（`parser.Object`） | 函数摘要 + 逐函数语句级 LLR |
| 释放依据 | 全部绑定名的最外层作用域 + 槽位模拟 | 参数/返回值摘要 + 别名/共享 mask + 语句级对象表 |
| 释放点 | `Object.FreeScope` + `Holder` | 7 类：出口 / 块尾 / 循环出口 / 覆盖 / ret 临时 / 条件临时 / 增量临时 |
| 产物消费者 | `tools/esccheck`（诊断） | `compile.Compiler`（真实代码生成） |
| 泛型单态化 | 无专门处理（`CopyLife` 只复制 Life） | 克隆体在 `monomorphize.go` 重算 LLR |
| 当前状态 | 已拆包、可独立驱动 | 权威链路，但有 §9.1/§9.2 两个已知缺口 |

---

## 2. 实测对比（同一台机器、同一份源码）

前端数字来自 `tools/gcstat` 的 `FE` 行；后端数字来自同进程 `gc.Build` 后的
`gc.LLRResults`（只列目标函数，不含 `pkg/` 标准库）。

| 用例 | 前端对象 | 前端分布 | 后端目标函数释放 | 观察 |
|---|---:|---|---|---|
| `test/gc_loop` | 10 | 作用域 3 / 转移 2 / RC 5 | `main`：出口 8、字段 2 | 前端把 `main` 的链式节点判成 RC/作用域；后端只对 `main` 发出口+字段 |
| `test/heap_new` | 5 | 作用域 4 / RC 1 | 0 | 后端因直接 `new` 进 `CallsAny`，整函数 LLR 被禁用（§9.2）；前端正常释放 |
| `test/gcOverwrite` | 9 | 作用域 9 | 0 | 同 §9.2；前端按覆盖赋值逐对象定作用域 |
| `test/gcCondTemp` | 1 | 转移 1 | 条件临时 8、ret 临时 1 | 前端完全不建表达式临时对象；后端覆盖条件/ret 临时 |
| `test/gcRetFree` | 0 | — | ret 临时 4 | 前端不建返回表达式里的 owning call 对象；后端释放 4 个临时 |
| `test/gcBlocks` | 9 | 作用域：for 3 / if 3 / else 2、转移 1 | 出口 8、块尾 8、循环 3 | 前端块级释放粒度更细；后端多出出口类（含 `ret` 路径问题） |
| `test/gcStructFree` | 3 | 作用域 1 / 转移 2 | 出口 1、字段 4 | 前端没有字段 cascade；后端字段释放 4 |

结论：

- 前端在“直接 `new`、覆盖赋值、块级作用域”上更细，且不受 `CallsAny` 整函数禁用影响；
- 后端在“表达式临时对象、字段 cascade、函数出口/`ret` 路径”上覆盖更全；
- 两者不是简单的“新旧替代”，当前能力是互补的。

### 2.1 全量基线（`test/` 115 个目录，106 成功、9 个既有失败）

```
对象=132  RC/泄漏释放=8  泄漏=0  提前释放=0
作用域释放=100  转移=24  RC=8  真泄漏=0
```

- `[]T` 修复前是 `117 / 6`；修复后对象 +15、RC +2，泄漏与提前释放仍为 0。
- `RC=8` 分布：`gc_loop` 5、`heap_new` 1、`gcprobe` 1、`sliceprobe2` 1。
- 9 个失败目录是既有解析失败，不是本轮引入。

### 2.2 Phase 1 对拍基线（`tools/gcdiff`，106 个成功目录）

```bash
go run ./tools/gcdiff -o /tmp/gcdiff/test-gcBlocks ./test/gcBlocks
```

每个目录输出三份文件：`gcfe_plan.json`（对象级计划）、`gc_llr.json`（后端
`gc.LLRResults`）、`gc_diff.txt`（逐函数并排 + 差异归类）。全语料累计：

| 侧 | 指标 |
|---|---|
| 前端 `gcfe` | 对象 132；作用域 100；RC 8；转移 24；就地释放 7；真泄漏 0 |
| 后端 `compile/gc` | 有释放计划的函数实例 133；出口 204；块尾 67；循环出口 53；覆盖 3；字段 96；临时 48 |

逐函数归类按目录累计（同一函数在多个目录中会重复计数）：

| 归类 | 次数 | 典型函数 |
|---|---:|---|
| 前端独有 | 20 | `testLocalAlloc` / `testLoopAlloc` / `testFieldOrphan` 各 2；`overwriteLoop`、`selfRef`、`fieldAlias`、`listBuild`、`nilDrop` |
| 后端独有 | 109 | `main` 9；`useTemp` / `buildTree` 各 2；`forCond`、`ifBoth`、`ifOr`、`ifTrue`、`oneTemp`、`twoTemps`、`deepClone`；另有标准库 `strings.trim` 的 ret 临时 |
| 两边都有 | 24 | `gcBlocks` 的块函数、`stringConcat`、`testNestedAlloc` 等 |

这与 §3 的能力表一致：前端独有集中在“直接 `new` / 覆盖赋值 / 循环分配”，
后端独有集中在“表达式临时（ret/cond/incr）、字段 cascade、嵌套调用”。
对拍只统计数据，不改变生成代码。

---

## 3. 语义差异清单

| 能力 | 前端 | 后端 | 切换影响 |
|---|---|---|---|
| 变量绑定的堆对象 | ✅ `claim` + 作用域 | ✅ | 前端可作为主计划 |
| 覆盖赋值就地释放 | ✅ `ReleasesOld` / `OldObj` | ✅ `AssignFrees` | 需要把语句级标记接进代码生成 |
| 直接 `new` 函数 | ✅ 不受 `CallsAny` 影响 | ❌ §9.2 整函数禁用 | 前端是净收益 |
| 表达式内嵌 `new` / owning call | ❌ 不建对象 | ✅ `RetFrees` | **前端缺口，会漏释放** |
| `if` / `for` 条件临时 | ❌ | ✅ `CondFrees` | **前端缺口** |
| `for` 增量临时 | ❌ | ✅ `IncrFrees` | **前端缺口** |
| `obj.f = new(T)` 字段新对象 | ❌ | ✅ `RetFrees`/字段路径 | **前端缺口** |
| 容器字段 cascade | ❌ `FieldVals` 只排序 | ✅ `FieldFrees` | **前端缺口，会漏释放** |
| 函数出口释放 | ✅ `FreeScope=FuncBlock` | ⚠️ §9.1 在 `ret` 路径不可达 | 前端可修掉 §9.1，但需先验证 `Holder` |
| 块尾 / 循环出口 | ✅ `FreeScope=块` | ✅ | 结构不同，可对齐 |
| 泛型单态化克隆 | ❌ 共享原对象 | ✅ 克隆体重算 LLR | **最大阻塞项** |
| 多目录同进程复用 | ❌ `objects` 全局不重置 | ✅ `Build` 重置 `LLRResults` | 测试/多包场景会串对象 |

---

## 4. 切换阻塞项（按风险排序）

### 4.1 泛型单态化会共享对象身份（最高风险）

`gcfe.SimulateRC` 在 `GetPackage` 内执行，早于 `compile.MonomorphizeIfNeeded`。
`parser.CopyLife` 只复制 `Life`（含 `Obj` 指针），不会创建新的 `Object`；
`Object.Names` 仍指向原树的 `VarBlock`。如果直接用 `parser.Objects()` 驱动
每个特化函数：

- 原函数和克隆体会对同一 `Object` 各发一次 free → 双重释放；
- 克隆体的 `Holder` 指回原树节点，栈槽偏移可能不属于克隆体；
- 克隆体新增的分配（`new` 在特化后类型变化）不会被记录。

**必须做**：像 `gc.ComputeLLR` 一样，在 `MonomorphizeFunction` 里对克隆体
重跑一份前端计划；或为克隆体深拷贝对象并把 `Names`/`Holder` 重映射到克隆节点。
后者要处理 `Object` 的全局身份，成本更高。

### 4.2 表达式临时对象完全缺失

典型场景：`ret cmpLen(strings.repeatN(...), ...)`、`if condCall()`、
`for` 增量里的 owning call、`obj.f = new(T)`。前端 `collectVar` 只在
“变量定义/赋值”上 `claim`，表达式内嵌分配没有 `Object`。

**必须做**：把后端 `collectRetFrees` / `collectCondFrees` / `collectIncrFrees`
的对象发现逻辑前移，或在前端增加“临时对象”模型：记录分配点、语句/条件/
循环结束点、scratch 槽需求。按当前设计，这需要新的 `Object` 类别或新计划表，
不能只靠 `FreeScope`。

### 4.3 字段 cascade

前端 `FieldVals` 明确只用于排序，不决定释放。若容器对象在作用域出口 free，
其字段指向的子对象不会自动释放；后端有 `FieldFrees`。

**必须做**：决定字段所有权语义（容器是否拥有字段？字段是否可能别名到外部？），
然后增加字段级释放计划；在此之前切换会漏释放字段对象。

### 4.4 `Holder` 在函数出口的有效性

`scopeRelease` 的兜底是 `FreeScope=FuncBlock`、`Holder=Owner`；但正常路径下
`Holder=firstLiveName(o)` 可能是内层块变量。若代码生成在函数出口读该槽：

- 槽位可能已被编译器复用/覆盖；
- 内层块的栈槽在出口是否仍然有效，取决于 `SetupVarOffsets` 的分配策略。

**必须做**：加一条不变量/自检：`Holder` 的作用域必须包含 `FreeScope`，否则
选择外层仍存活的绑定名；或把释放点收紧到 `Holder` 的作用域出口（但会改变
对象释放时机，需要重新验证别名安全）。

### 4.5 函数出口代码位置（§9.1）

当前 `emitGCFrees` 在 `func_end_<name>:` 之前，显式 `ret` 会 `jmp` 跳过。
前端把大量对象放在 `FuncBlock` 出口，直接接入会让这些释放全部变成死代码。

**必须做**：先把出口清理移到 `func_end_<name>:` 之后、栈帧清理之前；这是
后端代码生成修复，和选哪套 GC 无关。修完要重新审计字段 cascade 与共享别名
（`GC_MEMORY_MANAGEMENT.md` §9.4）。

### 4.6 `objects` 全局状态不可重置

`parser.objects` 是包级 slice；`gcfe.SimulateRC` 只追加，不重置。单进程只编译
一个目录时没问题，但测试框架/多包/多次 `GetPackage` 会串对象。

**必须做**：提供显式的分析上下文（`Analyzer` 持有 objects），或至少在
`gcfe` 入口重置并保证旧 AST 不再被消费。后者只能在“一次编译一个根”前提下成立。

### 4.7 嵌套调用的传出边（安全缺口）

`gc_frontend_design.md` §7 已记录：表达式内嵌调用不建树节点，`scanFuncFacts`
扫描域只覆盖独立成句的调用；嵌套边是否进定点取决于语句顺序，缺口方向是
**升级不足 → 提前释放**，`checkPremature` 抓不到跨帧悬垂。

**必须做**：在切换前把“任何表达式内嵌调用”作为保守逃逸（或补全扫描域），
并跑跨帧 use-after-free 用例；否则前端的作用域释放不具备生产安全性。

---

## 5. 建议的 rollout

### Phase 0（已完成）

- 抽出 `gcfe`（Check 后驱动 + 计划构建），parser 保留模型与 Check 期事实；
- 修复 `ListType.IsOwning`，重建基线 `132 / 8 / 0 / 0`；
- 全量 esccheck 逐目录对比，抽取前后逐位一致。

### Phase 1（已完成）：只读对拍，不接代码生成

- `gcfe.BuildPlan(root)` 导出对象级计划（`FreeScope` / `Holder` /
  `ReleasesOld` / 字段绑定），JSON 稳定可 diff；
- `tools/gcdiff` 把前端计划与 `gc.LLRResults` 并排落盘，逐函数归类为
  “前端独有 / 后端独有 / 两边都有”；
- 全语料结果见 §2.2；9 个既有失败目录与 `esccheck` 口径一致；
- 不改生成代码，`泄漏=0`、`提前释放=0` 保持不变。

### Phase 2：补齐前端能力

按 §4.2 → §4.3 → §4.1 → §4.4 的顺序做：

1. 临时对象（ret / 条件 / 增量 / 字段 new）；
2. 字段 cascade；
3. 单态化克隆体的对象/计划重算；
4. Holder 作用域不变量；
5. 嵌套调用保守逃逸。

每步都用“泄漏=0、提前释放=0”和 e2e GC 矩阵（gcCondTemp / gcRetFree /
gcBlocks / gcOverwrite 双架构）验收。

### Phase 3：并行生成 + 开关

- 增加 `-gc=legacy|frontend`（或环境变量）开关；
- 默认仍 legacy，CI 双跑：前端计划生成释放代码、后端计划也生成，对比汇编中
  free 点集合；
- 对差异逐项归因，直到前端是后端的超集（或差异有明确安全理由）。

### Phase 4：切换与退役

- 默认切到 frontend，保留 legacy 一个发布周期；
- 跑完整 farm/e2e；确认 §9.1/§9.2 不再存在；
- 删除 `compile/gc` 或降级为诊断，更新 `GC_MEMORY_MANAGEMENT.md` 的
  “权威链路”结论。

---

## 6. 不建议现在直接替换的理由

1. `gcRetFree`、`gcCondTemp` 会从“有释放”退化为“漏释放”；
2. `gcStructFree` 的 4 个字段释放会丢失；
3. 泛型特化可能双重释放（比漏释放更危险）；
4. §9.1 未修，前端大量 `FuncBlock` 出口释放会成为死代码；
5. 嵌套调用逃逸缺口可能产生跨帧 use-after-free，现有自检抓不到。

因此当前应把 `gcfe` 视为“已拆出的新计划器”，先对拍、补能力，再切代码生成。
