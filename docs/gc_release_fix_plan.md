# 前端 GC 释放点修复计划（当前批次）

> 状态：2026-11-05 · 分支 `main` · 前端基线 `0a176cf` · 后端批次基线 `6841680`
> 目标：在**不切换代码生成权威**的前提下，让前端 `gcfe` 的释放计划满足
> “一个对象至多一个释放点”，把字段 cascade 缺口补到不再产生假泄漏，
> 并修掉后端 §9.1 的出口释放可达性问题。
> 验收口径：`泄漏=0`、`提前释放=0`、`HolderBad=0`，全语料逐目录对拍。

---

## 0. 为什么做这一批

Phase 1 对拍发现两个真实问题：

1. **就地释放与作用域释放会重复**：`rcSim.releasesOld` 只写
   `Life.ReleasesOld`，没有把“已就地释放”回写到 `Object`；随后
   `scopeRelease` 又给同一对象设 `FreeScope`。若代码生成同时消费两者，
   会 double free。
2. **兜底 Holder 可能读错槽**：对象被覆盖后 `Names` 为空，旧兜底把
   `FreeScope=fn`、`Holder=Owner`，但 `Owner` 可能已改绑到新对象。
   实测 `gcOverwrite` 3 个、`gc_loop` 1 个 `HolderBad`。

修完第 1 点后，`fieldAlias` 暴露出第 3 个问题：旧 `b` 只被
`holder.next` 字段持有，没有任何变量名，前端没有字段 cascade → 真泄漏。
本批次一并补最小字段 cascade。

---

## 1. 本批次改动清单

### 1.1 释放点互斥

- [x] `parser.Object` 增加 `Inplace bool`
- [x] `parser.Disposal` 增加 `DisposalInplace`
- [x] `rcSim.releasesOld` 置 `old.Inplace = true`
- [x] `scopeRelease` 跳过 `Inplace`
- [x] `checkPremature` 跳过 `Inplace`
- [x] `esccheck` 把就地释放单列，不再计入作用域释放

### 1.2 Holder 兜底加严

- [x] 兜底只接受 `Owner.Life.Obj == o`
- [x] 兜底只接受 `Owner.Life.Scope == 所在函数`（活到函数出口）
- [x] 不满足就不设 `FreeScope`：宁可不释放，不 free 错块
- [x] 正常路径 `Holder` 必须是 `Object.Names` 成员，且
      `Holder.Life.Scope` 不早于 `FreeScope` 失效（`holderLivesTo`）
- [x] `firstLiveName` 跳过活不到释放点的内层名字；找不到名字就不设释放点
- [x] `HolderBad` 改为 `containsName + holderLivesTo`：分支合流的
      `result` 在两个分支指向不同对象，不再误报
- [x] 记录生成器契约：同一槽在释放点可能对应多个对象，必须用清槽语义
      `freeSlot`，不能裸 `free(槽值)`

### 1.3 字段 cascade（最小安全版）

- [x] `parser.Object` 增加 `FieldOwner *Object` / `FieldName string`
- [x] `FieldBinding` 增加 `Stale bool`；`collectNames` 不再丢弃
      “值变量已改绑”的最后一次字段绑定（字段释放读容器字段，不读值槽）
- [x] `fieldRelease`：只被**恰好一个**字段引用、无任何变量名、无其它
      释放点的对象，挂到容器释放点
- [x] 容器必须是作用域释放（或递归地只被字段持有）；读槽无效/成环则放弃
- [x] 容器读槽必须唯一且 `Holder.Life.Obj == 容器`；分支合流 / 别名放弃
- [x] `parser.Disposal` 增加 `DisposalField`
- [x] `gcfe/plan.go` 导出 `Field` / `FieldOwner` / `FieldName` / `Stale`
- [x] `esccheck` 单列字段释放，不计入泄漏
- [x] `gcdiff` 把字段释放算作前端释放能力

### 1.4 文档与基线

- [x] `docs/gc_api.md` 三态 → 五态（Scope / Field / Inplace / RC / Borrow）
- [x] `docs/gc_frontend_design.md` 更新 §3.4 / §3.5 / §5 基线
- [x] `docs/GC_MEMORY_MANAGEMENT.md` 记录 Phase 1 数字与字段 cascade 状态（原 gc_migration_plan，已并入）
- [x] `docs/GC_MEMORY_MANAGEMENT.md` 更新“一个对象至多一个释放点”的表述
- [x] `gcfe/plan.go` 的 `Disposal` / `FieldPlan` 注释同步五态

### 1.5 后端 §9.1：出口释放挂到公共跳板（Batch D）

- [x] `Arch.Epilogue(fn, cleanup)` 接管出口释放序列，四个架构同步：
      `linux_sysv`、`ms_win64`、x86 `cdecl`、x86 `stdcall`
- [x] `funcHandle` 把 `emitGCFrees` 结果传入 `Epilogue`；`main` 与 link alias
      的跳过条件与入口清零共用 `hasExitCleanup`
- [x] `resolveExitSlots` 统一解析“变量名 + 栈偏移”；`emitGCFrees` 与
      `emitGCZeroExitSlots` 共用，避免清一个槽、释放另一个槽
- [x] `emitGCZeroExitSlots` 在 `Prologue` 之后、函数体之前把出口计划涉及的
      局部槽清零，覆盖“变量初始化前早退 `ret`”
- [x] `Epilogue` 在 cleanup 前后成对保存/恢复返回值寄存器
      （x86_64：`RAX`/`RDX`；x86：`EAX`/`EDX`）
- [x] `compile/gc/llr.go` 的 `FieldFrees` 只在容器自身属于 `res.Frees` 时生成，
      容器已 `ret` 给调用方时不再拆字段（避免 UAF）
- [x] 修 x86 字段释放路径重复 `add esp, 4`：`Arch.Call` 已清理它看到的实参，
      重复清栈会让返回值寄存器读到错位槽

---

## 2. 验收步骤与结果

```bash
# 单点
go run ./tools/esccheck ./test/gcOverwrite
go run ./tools/gcdiff -o /tmp/gcdiff/gcOverwrite ./test/gcOverwrite

# 全语料（esccheck 口径）
# 期望：test/ 106 成功目录
# 对象=160  RC=8  转移=30  作用域=114  就地=7  字段=1  泄漏=0  提前=0
# HolderBad=0

# 构建与回归
go build ./...
go test ./type
```

### 2.1 本批次实测（2026-11-04）

| 项 | 结果 |
|---|---|
| 全量目录 | 106 成功 / 9 既有失败 |
| 对象 | 132 |
| 作用域 / 就地 / 字段 / 转移 / RC | 92 / 7 / 1 / 24 / 8 |
| 泄漏 / 提前释放 | 0 / 0 |
| `HolderBad` | 0（`gcOwnership` 的误报已消除） |
| 字段释放分布 | `gcOverwrite` 1（`fieldAlias` 旧 `b`） |
| 逐函数对拍 | 前端独有 20 / 后端独有 109 / 两边都有 24（与上一轮一致） |

e2e GC 矩阵（字段 cascade 不改变代码生成，先只做解析/计划验证）：

- `test/gcOverwrite`：`fieldAlias` 旧 `b` 已从“真泄漏”变成“字段释放”；
- `test/gcStructFree`：字段释放计划仍为 0（`makeNode(...)` 右值无对象，
  Batch B）；后端 `FieldFrees=4` 的差距保留在报告里；
- `test/gc_loop`：就地释放后 `HolderBad=0`，`RC=5` 保持不变；
- `test/gcBlocks` / `gcCondTemp` / `gcRetFree`：数字不回归。

### 2.2 Batch D 实测（2026-11-05）

| 项 | 结果 |
|---|---|
| `gcOwnership` x86_64 / x86 | 各 9/9，连续 5 轮（共 10 次） |
| `gcCondTemp` / `gcRetFree` / `gcBlocks` / `gcOverwrite` | 双架构 `exit=0` |
| 早退 `ret` + 出口计划（临时用例，未入库） | 双架构 `exit=0`，汇编含 `gc: zero exit slot` |
| 全语料 112 目录 × 2 架构 | RC 与基线一致；仅既有失败、计时、非确定性输出差异 |
| `esccheck` 前端基线（Batch D 时） | `对象=132 RC=8 泄漏=0 提前=0 作用域=92 转移=24 就地=7 字段=1 HolderBad=0`（Batch B 后为 160/114/30，见 §2.3） |
| `go test ./...` | 仅既有 3 个 fixture 路径失败（`TestFullSyntaxParse` / `TestFullSyntaxCompile` / `TestListParseAndCompile`） |

`gcOwnership` 的 `testNestedAlloc` 在修复后的汇编形态：

```asm
jmp func_end_testNestedAlloc
func_end_testNestedAlloc:
push rax                     ; 保存返回值
push rdx
; gc: free field a.child
...
; gc: free a
lea RDI, [rbp-48]
call std_memory_freeSlot
pop rdx                      ; 恢复返回值
pop rax
add rsp, 104
```

返回值寄存器在 cleanup 前保存、之后恢复，因此释放调用不会破坏 `ret` 的返回值。

---

### 2.3 Batch B 实测（2026-11-05，返回值摘要）

| 项 | 结果 |
|---|---|
| `parser/gc_retsum.go` | 新增 `ReturnKind`（None/Fresh/Alias/Borrow/Unknown）与 `RetSourceOf` |
| `freshAllocExpr` | 消费方从 `ReturnsOwned` 切到严格 Fresh 摘要 |
| 全语料前端基线 | `对象=160 作用域=114 就地=7 字段=1 转移=30 RC=8 泄漏=0 提前=0 HolderBad=0` |
| 对象增量 | 132→160（纯传递返回链被识别）；中间值 163 是 `newRC` 误判 Fresh，已回落到 160 |
| 与后端 `RetKind` 对拍 | `front=Fresh && back!=Fresh` 为 0；`front=Unknown / back=Fresh` 1615 处（保守） |
| 38 个 `Fresh` 函数 | 逐个核对源码，全部满足“所有路径新分配 / nil / 空串” |
| e2e | `gcCondTemp` / `gcRetFree` / `gcBlocks` / `gcOverwrite` 双架构 `exit=0`；`gcOwnership` 双架构 `exit=9` |
| 解析期缓存 | `markFuncOpen` / `markFuncClosed` 修复自递归函数前缀体被缓存成 Fresh |

**仍未完成**：表达式临时对象（`ret f()` 里的嵌套 owning call、`if`/`for`
条件、`for` 增量、`obj.f = new(T)`）。`ret f()` 的对象传播已做，但表达式
内嵌的分配点还没有临时对象模型。

---

## 3. 后续批次（Batch B 剩余 / C / E / F，尚未实施）

### Batch B：返回值摘要（已完成）+ 表达式临时对象（未完成）

- [x] 严格 Fresh 返回值摘要：混合来源一律 Unknown，不保留 mask Fresh
- [x] `ret f()` 且被调 Fresh 时传播 `mkFuncOwns`；`freshAllocExpr` 消费摘要
- [x] `markFuncOpen` / `markFuncClosed`：解析中的函数摘要不缓存
- [x] `bodyTakesAddrOf`：`&local` 后字段写入的局部降为 Unknown
- [ ] `ret f()` 中嵌套的 owning call / `if` 条件 / `for` 增量 / `obj.f = new(T)`
- [ ] 临时对象建对象、给临时释放点；与后端 `RetFrees` / `CondFrees` / `IncrFrees` 对拍
- 验收：`gcRetFree`、`gcCondTemp` 从“后端独有”变为“两边都有”

### Batch C：单态化克隆计划重算

- [ ] `CopyLife` 之后按克隆体重算 `Object` 归属，禁止共享原树 `Names`/`Holder`
- [ ] 泛型矩阵：`test/generics`、`test/iface_generic`、`test/gc_nested`
- 验收：克隆体无双重释放、无漏释放

### Batch D：§9.1 出口释放位置（已完成）

- [x] `Epilogue(fn, cleanup)` 统一跳板：显式 `ret` 的 `jmp func_end_*`
      不再跳过释放。实际采用公共 `func_end` 跳板，而不是在每条 `ret` 前
      复制释放序列，避免代码膨胀。
- [x] 入口清零出口槽，覆盖“变量初始化前早退”
- [x] `FieldFrees` 增加容器宿主约束，容器已返回时不拆字段
- [x] 验收：`gcOwnership` 双架构 9/9 × 5；`gcRetFree` 等双架构 `exit=0`；
      全语料 RC 与基线一致

### Batch E：嵌套调用保守逃逸

- [ ] 表达式内嵌调用的传出边升级不足，补保守逃逸
- 验收：跨帧 use-after-free 用例，`提前释放=0`

### Batch F：并行开关与切换

- [ ] `-gc=legacy|frontend`，默认 legacy
- [ ] CI 双跑，比较汇编 free 点集合
- [ ] 前端覆盖后端后切换，保留 legacy 一个周期

---

## 4. 当前阻塞与不做的事

- 本批次只改 `compile/` 的**出口释放可达性、入口清零、字段 cascade 宿主
  约束与 x86 调用栈**；代码生成权威仍是 `compile/gc`，前端尚未接管生成；
- `Holder` 只保证“是该对象的绑定名且活到释放点”，不保证“释放那一刻槽里
  一定是它”（分支合流是合法场景）；接生成器时必须用清槽语义 `freeSlot`，
  并在 Phase 3 用汇编检查钉住；
- 字段 cascade 仍只在函数出口执行；容器就地释放时的字段释放顺序留到后续
  批次（出口 cleanup 位置已经具备，块尾/循环出口尚未接）；
- 单态化克隆体仍共享 `Names`/`Holder`，切换代码生成前必须修（Batch C）；
- Win64 的 GC 释放调用仍硬编码 SysV `RDI`，未按 Win64 使用 `RCX` + shadow
  space（见 `docs/GC_MEMORY_MANAGEMENT.md` §9.8）；
- `ast.html`、`gc_llr.txt`、`gc_summary.json`、`_main.asm` 等运行产物不提交。
