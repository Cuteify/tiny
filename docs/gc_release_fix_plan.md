# 前端 GC 释放点修复计划（当前批次）

> 状态：2026-11-04 · 分支 `main` · 基线提交 `0a176cf`
> 目标：在**不接代码生成**的前提下，让前端 `gcfe` 的释放计划满足
> “一个对象至多一个释放点”，并把字段 cascade 缺口补到不再产生假泄漏。
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
- [x] `docs/gc_migration_plan.md` 更新 Phase 1 数字与字段 cascade 状态
- [x] `docs/GC_MEMORY_MANAGEMENT.md` 更新“一个对象至多一个释放点”的表述
- [x] `gcfe/plan.go` 的 `Disposal` / `FieldPlan` 注释同步五态

---

## 2. 验收步骤与结果

```bash
# 单点
go run ./tools/esccheck ./test/gcOverwrite
go run ./tools/gcdiff -o /tmp/gcdiff/gcOverwrite ./test/gcOverwrite

# 全语料（esccheck 口径）
# 期望：test/ 106 成功目录
# 对象=132  RC=8  转移=24  作用域=92  就地=7  字段=1  泄漏=0  提前=0
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

---

## 3. 后续批次（不在本批次提交）

### Batch B：表达式临时对象

- [ ] `ret f()` / 条件里的 owning call / `for` 增量临时 / `obj.f = new(T)`
- [ ] 建对象、给临时释放点；与后端 `RetFrees` / `CondFrees` / `IncrFrees` 对拍
- 验收：`gcRetFree`、`gcCondTemp` 从“后端独有”变为“两边都有”

### Batch C：单态化克隆计划重算

- [ ] `CopyLife` 之后按克隆体重算 `Object` 归属，禁止共享原树 `Names`/`Holder`
- [ ] 泛型矩阵：`test/generics`、`test/iface_generic`、`test/gc_nested`
- 验收：克隆体无双重释放、无漏释放

### Batch D：§9.1 出口释放位置

- [ ] 把函数出口释放移到每条 `ret` 之前（或统一跳板），保证显式 `ret` 不跳过
- 验收：`gcRetFree` 双架构 e2e

### Batch E：嵌套调用保守逃逸

- [ ] 表达式内嵌调用的传出边升级不足，补保守逃逸
- 验收：跨帧 use-after-free 用例，`提前释放=0`

### Batch F：并行开关与切换

- [ ] `-gc=legacy|frontend`，默认 legacy
- [ ] CI 双跑，比较汇编 free 点集合
- [ ] 前端覆盖后端后切换，保留 legacy 一个周期

---

## 4. 当前阻塞与不做的事

- 本批次**不**改 `compile/`，代码生成权威仍是 `compile/gc`；
- `Holder` 只保证“是该对象的绑定名且活到释放点”，不保证“释放那一刻槽里
  一定是它”（分支合流是合法场景）；接生成器时必须用清槽语义 `freeSlot`，
  并在 Phase 3 用汇编检查钉住；
- 字段 cascade 只处理“作用域释放容器”的字段；容器就地释放时的字段
  释放顺序留到 Batch B/D（届时需要释放语句位置）；
- 单态化克隆体仍共享 `Names`/`Holder`，切换代码生成前必须修（Batch C）；
- `ast.html` 等运行产物不提交。
