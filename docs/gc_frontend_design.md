# GC 前端分析设计

> 对象：顶层 `gc` 包里的对象级前端分析（`front.go`、`facts.go`、`state.go`、
> `names.go`、`inplace.go`、`release.go`、`scope.go`、`paramsum.go`、
> `retsum.go`、`pred.go`）。
> 唯一公开入口：`gc.Analyze(root)`；前端子链也可单独用 `gc.CollectFront(root)`
> 跑（诊断 / 计划导出）。
>
> 代码生成仍以语句级 LLR（`gc.LLRResults`）为准；本文描述的对象级模型
> 由 `tools/esccheck` / `tools/gcdiff` 消费，用来验证对象归属与五态计划。
> 旧的 `parser/gc_*.go` 钩子与 `gcfe/` 已删除，本文不再保留旧路径。

---

## 1. 要解决的问题

编译器要知道：每个 `new(T)` 产生的堆块，**在哪一行 free**。

这件事有三个独立难点，混在一起看会以为是“一个逃逸分析”，其实是三个问题：

| # | 问题 | 答案由谁给 |
|---|---|---|
| A | 这块内存归谁管？ | `DisposalOf` 五态判定 |
| B | **最终**在哪释放？ | 纯作用域规则 |
| C | 这条赋值能不能**提前**释放？ | 槽位表存在性扫描 |

外加一个横切问题：**跨函数**时，被调方会不会把入参存到别处（决定实参
还算不算帧内可达）。

---

## 2. 为什么这个方案可行

### 2.1 变量是槽位，对象是内存

```
binding  挂在 VarBlock / ArgBlock 旁    变量视角：我指向谁、我的绑定在哪个作用域
Object   每次分配一个                   内存视角：谁指向它、在哪释放、读哪个槽
```

关键性质：**对象身份与变量无关**。同一变量连续两次 `new()` 是两个对象，
所以“这条赋值顶掉的是哪一块”可判定。若按变量建模，覆盖时就说不清旧内存
是谁的了。

### 2.2 释放点 = 最外层绑定作用域

```
释放点 = 全部绑定名里最外层的作用域
```

推论：对象活到它**最后一个绑定名所在作用域的出口**。块只能被还活着的
栈槽读；作用域退出后槽就没了，此时释放一定安全。反过来，任何更早的释放
都可能被某个还活着的槽读到。

**只向外放**：分支里的局部变量名会把释放点推到外层，而不是反过来。

```go
n := new(); head = n; for { ... }
// n 的绑定名是 {n(循环体), head(函数体)} → 函数出口释放
// 否则循环里的 head.next 会指向已经 free 掉的块
```

算不出绑定名（没有名字 / 只被字段读引用）：先尝试字段 cascade（只被容器
字段持有 → 随容器释放）；仍算不出才兜底到所属函数出口——宁可晚释放，
也不早释放；连安全兜底都不成立时宁可不释放。

### 2.3 为什么不做引用计数

引用计数唯一多回答的问题是：“改其中一个引用时，旧对象还有没有人指着？”
这个问题**不是作用域规则能答的**：

```go
head = prepend(head, 4)
// 旧 head 的变量名没了，但 prepend 里新建的节点 .next 还指着它
```

只看作用域会漏，漏了就是 use-after-free。所以这一步必须扫字段：
`rcSim` 用字段表判断旧对象是否还有人指着；`fieldRelease` 把“只被容器
字段持有、没有变量名”的对象挂到容器释放点。

结论：**作用域规则定“最终在哪”，存在性扫描 / 字段 cascade 定“能不能
提前、怎么级联”。** 两个问题两种判据，不要指望一个公式全包。

### 2.4 失败方向只有一边

| 不确定的情况 | 判成 | 后果 |
|---|---|---|
| 认不出被调函数 / 序号越界 | 逃逸（退回 RC） | 多一次 rcInc/rcDec |
| 算不出释放点 | 函数出口释放 | 晚释放，内存多占一会儿 |
| 分支赋值 | 两个绑定名都算持有 | 释放点偏外 |
| 字段读 / 索引 / 普通调用 | 借用（不认领新对象） | 不凭空多出内存 |

**全都不导向“提前释放”。** 这条纪律贯穿全部判据：每个 `return false` /
`return nil` / `continue` 都要能回答“这是往安全侧倒吗”。

---

## 3. 具体流程

### 3.1 时间线

```
包解析（每包递归）
  └─ Check 多轮 ──────────────► 类型 / 解析全部收敛
GetPackage 返回
  └─ compile.Compiler.Compile(root)
       └─ gc.Analyze(root)                 ← 唯一入口，按根幂等
            ├─ CollectFront(root)
            │    ├─ RebuildBlockIndex      补 Block → Node 反向索引
            │    ├─ collectFacts           后置一次遍历，复刻旧 Check 钩子
            │    ├─ collectNames           反转绑定名
            │    ├─ rcSim.walk             槽位 / 字段模拟
            │    ├─ scopeRelease           作用域释放点
            │    └─ checkPremature         自检：UAF 必须 0
            └─ analyzeBackend(root)         摘要 + LLR（代码生成消费）
```

### 3.2 为什么必须在 Check 收敛之后

GC 要读**事实的最终形态**。Check 中途的绑定名集合、类型、跨包别名都
可能还没稳定；在中间轮次分析的后果是泄漏或提前释放。`Analyze` 的契约是
“`GetPackage` 返回之后调用”，`Compile` 顶层已自动保证。

### 3.3 为什么 `collectNames` 要反转

事实收集只写**正向事实**：每个变量指向哪个对象。“某个对象当前被哪些
名字指着”是反过来的关系，算一遍就行，不必增量维护。

反转要补一类边 —— `wroteTo`，**记在右值上**：

```go
if c { result = n1 } else { result = n2 }
```

`n1` 记着“我被写进过 result”，`n2` 也记着。两个都算持有者，**不需要猜
这次赋值是分支还是顺序覆盖**。代价：顺序覆盖也算持有（`head = n;
head = m` 之后 head 仍算 n 的名字），释放点偏外。**偏外是安全方向。**

### 3.4 槽位表模拟（就地释放）

`rcSim` 按源码顺序走一遍树，维护两张表：

```go
slot   map[*VarBlock]*Object             // 局部变量当前持有哪个对象
fields map[*VarBlock]map[string]*Object  // 容器各字段当前持有哪个对象
```

覆盖一条语句时：先从表里摘掉旧槽位，再问 `referenced(old)` —— 还有没有
任何槽位或字段指着它。没有就地释放，有就不释放。就地释放回写
`binding.releasesOld` / `oldObj`，`scopeRelease` 与 `checkPremature` 都跳过
它——否则同一对象会有两个释放点。

顺序敏感，但**与迭代次数无关**：生成的代码（覆盖前先释放旧值）本来就是
这个语义。

### 3.5 五态判定

```go
func DisposalOf(o *Object) Disposal {
    if o.Inplace             { return DisposalInplace } // 覆盖点已释放
    if o.Transferred         { return DisposalBorrow }  // 交给调用者了
    if o.FieldOwner != nil   { return DisposalField }   // 随容器字段释放
    if o.Escapes             { return DisposalRC }      // 帧外可达
    if o.FreeScope == nil    { return DisposalBorrow }  // 孤儿
    return DisposalScope
}
```

`DisposalScope` 时在 `FreeScope` 处 free，读 `Holder` 那个槽。
`DisposalField` 时在容器释放点先 free `容器.FieldName`，再 free 容器。

三种释放点互斥：`Inplace` / `Field` / `Scope` 一个对象只能占一个。`Holder`
只保证“是该对象的绑定名且活到释放点”，分支合流时同一槽可能对应不同对象，
所以后端释放必须走清槽语义（`freeSlot`），不能裸 free 槽值。

字段 cascade 只覆盖最小安全集：对象没有变量名、恰好一个字段引用、容器已按
作用域释放、容器读槽唯一且确定持有它。任何一条不满足就不挂字段释放
（宁可漏释放，也绝不 free 错块）。

### 3.6 跨函数摘要

调用点不必读被调函数体，只查一张表：

```go
argEscapeOf(call, idx) == false   → 实参“只读不存”，调用方继续按作用域释放
                            true  → 被调方可能存到别处，退回 RC
```

**判定规则**（sound 的 may 分析）：

```
参数逃逸 ⟸ 存进全局
参数逃逸 ⟸ 装箱进接口或结构体值
参数逃逸 ⟸ 写进结构体字段
参数逃逸 ⟸ 作为第 j 个实参传出，且被调第 j 号参数也逃逸
参数逃逸 ⟸ 被调函数认不出来（泛型未解析 / 不在合并树里）

不算逃逸：读取、只在本帧局部之间倒手、作为返回值传出
```

**用最小定点，不用最大定点。** may 分析的结论应是“存在一条推导链能证明
逃逸”：

```
逃逸[f][i] = 地面事实[i]  ∨  ∃j: 作为第 j 实参传给 callee 且 逃逸[callee][j]
```

最大定点（从全逃逸往回收缩）会把纯递归锁死：`quickSortInts(s)` 递归传
自己，那条边自己依赖自己，收缩不掉 → 整个函数判逃逸 → 摘要白做。最小定点
下，没有地面事实的递归环推不出逃逸，判不逃逸——这是对的，环里没有一条
真的把指针存到了外面。

**懒算，不全局预扫描。** 一次分析里按需算被调闭包，只算那棵子树；局部
别名表也要解不动点，否则 `a = p; b = a; g = b` 会漏掉后半段的逃逸。

### 3.7 所有权转移

```
返回本地对象（不是参数）→ 转移给调用者，callee 不再释放
返回参数               → 调用者本来就有，不转移
但它已被存到外部        → 转移不了（现在有两个持有者），退回 RC
```

---

## 4. 如何实现：后置收集器 + 唯一处理器

### 4.1 两段式

```
收集器（facts.go）  只探测，不写任何状态
                    读类型 / 读作用域 / 查跨函数摘要 → []mark
处理器（facts.go）  applyMark：mark → 具体字段写，不判任何条件
```

`applyMark` 的 case 列表就是**事实全集**，每个 case 注明由哪个收集器发出。
与旧链的区别：事实收集不再挂在 `VarBlock.Check` / `CallBlock.Check` /
`ReturnBlock.Check` 上，而是 Check 收敛后跑一次完整后序遍历。这样没有
多轮中间态，也不需要“每轮 Init 清账”；`binding` 从零开始，只建一次。

遍历顺序复刻 `Node.Check`：进入作用域 → Children → 自身 Check；`IfBlock`
的 else 在 Children 之后；`ForBlock` 的 init/cond/incr 在循环体之后；
`FuncBlock` 的参数在函数体之后。

### 4.2 为什么不能“先全收集再统一施加”

后置 pass 虽然只跑一次，但事实之间有顺序依赖：定义点必须先 `mkInit` /
`mkScope` 再 `claim`，覆盖点必须 `mkOldObj` 先于 `mkObj*`（claim 会覆盖
obj）。**能落地的粒度就是每个站点收集完立刻施加完**——这是事实集成的
边界，也是 `mkInit` 清账语义能保持简单的原因。

### 4.3 写站点怎么分类

`collectVar` 内部一条优先序链，从语句形态直接产出事实：

| 优先级 | 判据 | 产生的事实 |
|---|---|---|
| 1 | 左值不是 owning 类型 | 无（连右值都不看） |
| 2 | 写全局 | 逃逸 + 记边 + 右值里所有变量逃逸 |
| 3 | 右边是 `newRC` | `obj = nil`（生命周期归调用者 `rcDec`） |
| 4 | 右边是当场新建 | `claim`：这个变量拥有新对象 |
| 5 | 右边是裸变量引用 | 别名（抄身份 + 记边 + 记参数来源） |
| 6 | 字段读 / 索引 / 调用结果 | `obj = nil`（借用） |

**优先序本身就是语义，写在一处**：

- 非 owning 类型最高——与 GC 无关，连右值都不必看；
- `isRCExpr` 必须先于 `freshAllocExpr` —— `newRC` 的 `Call` 同时带
  `NewType` 和 `IsRC`，先判 fresh 会把 RC 块当普通新分配 claim 掉，调用方
  再 `rcDec` 就是双重释放；
- 全局与 newRC 在记旧对象之前就 return —— 记了会让就地释放去 free 一个
  全局的 / 手工 `rcDec` 管的块。

### 4.4 文件分工

| 文件 | 职责 |
|---|---|
| `front.go` | `CollectFront` 五步编排 |
| `facts.go` | 事实收集 + `mark` / `applyMark` |
| `state.go` | `binding` / `analysis` / `Objects` |
| `model.go` | `Object` / `FieldBinding` / `Disposal` |
| `names.go` | 绑定名反转 + `walkSubNodes` |
| `inplace.go` | 槽位表模拟 `rcSim` |
| `release.go` | `scopeRelease` + 字段 cascade `fieldRelease` |
| `scope.go` | 深度 / 外层 / 可读身份 / 所属函数 |
| `pred.go` | 类型 / 表达式判据 |
| `paramsum.go` | 入参逃逸摘要 |
| `retsum.go` | 返回值来源摘要 |
| `plan.go` | 只读计划快照 |
| `diag.go` | 自检与五态统计 |

`gc` 单向依赖 `parser` / `type`；`parser` 不再有 GC 字段或钩子，不会形成
循环依赖。

---

## 5. 自检与基线

`checkPremature` 用最终快照校验：对象 O 的释放点 S 不能比任何绑定名的
作用域更内层。抓的是“数据已对但释放点算早”，抓不到“某条路径上曾持有过”
那类（那要路径分析）。

```
test/ 106/115      对象=160  作用域=111  就地=6  字段=1  转移=30  RC=12
                   泄漏=0    提前释放=0  HolderBad=0
```

- **`提前释放=0`** 是关键不变量——有 use-after-free 就是错；
- **`泄漏=0`** 是五态都不沾的对象为 0；
- **`HolderBad=0`**：释放读的槽必须是该对象的绑定名且活到释放点；
- 对象分布：作用域释放 111、转移 30、RC 12、就地 6、字段 1；五态互斥。

基线变更必须先逐条归因，再更新 `scripts/gc_corpus_check.sh` 的 `EXPECT_*`
默认值。旧基线 160/114/7/1/30/8 属于 Check 期钩子链；迁移到后置 pass 后
有两处更保守差异（`gc_loop`、`gc_complex`，prepend/linkPrepend 的字段事实
可见性），因此作用域/就地下降、RC 上升，属可接受方向。

---

## 6. 已知边界

| 边界 | 说明 |
|---|---|
| `for` 嵌套 `if` | 暂不处理 |
| 路径敏感 | 不做。“某条路径上曾持有过”判不出来，`checkPremature` 也抓不到 |
| 字段值排序 | `FieldVals` 只用于排序，不决定是否释放——字段值通常自己也有 `FreeScope`，按并集释放会双重释放 |
| 容器复制 | `var sh: Iface = d` 会把 d 的字段指针带走，去向不可追 → 保守把 d 当逃逸 |
| `obj.f = new(T)` | 对象压根没建（`bareRef` 返回 nil 就 return）；循环里反复覆盖同一字段会漏块 |
| 跨文件子包 | `pkg/hash:fnv` 这类 `a:b` 形式尚未解析 |
| 字段读引用 | `q = p.f` 逃逸语境下，字段读拿到**容器** binding → 对容器打逃逸（多标方向，安全） |
| 表达式内嵌调用的传出边 | 表达式里的调用不建树节点，参数摘要的闭包扫描只覆盖独立成句的调用；缺口方向 = 升级不足，基线语料未触发 |
| 单态化克隆体 | 前端五态不覆盖克隆体；后端 LLR 在 `compile/monomorphize.go` 单独重算 |

---

## 7. 后端契约

> 对象级模型是**诊断 / 对拍契约**，不是当前代码生成输入。
> 代码生成读 `gc.Table` + `gc.LLRResults`；若要接入对象级计划，必须保持
> 五态互斥，不能把同一对象再生成一遍出口释放。

若按对象级计划生成释放代码，只做两件事：

1. 遍历 `gc.Objects()`；
2. 对每个对象看 `DisposalOf(o)`，五态分别处理。

```go
DisposalScope   →  在 FreeScope 处 free，读 Holder 那个槽
DisposalField   →  在容器释放点先 free 容器.FieldName，再 free 容器
DisposalInplace →  覆盖赋值点已经 free，出口不得重复
DisposalRC      →  退回引用计数（rcInc / rcDec）
DisposalBorrow  →  本帧什么都不做
```

释放必须走清槽语义（`freeSlot`），不能裸 free 槽值——分支合流时同一槽
可能对应不同对象。

---

## 8. 已实施的设计简化

迁移到后置 pass 与统一 `gc` 包时落地，行为不变或更保守：

- 判据只留一份：`owningType` / `isRCExpr`，不再有 `isOwning` / `isRCAlloc`
  两个名字；
- `Stats` 与 `Plan.Summary` 共用 `PlanSummary.countObject`，统计口径只写
  一次；
- `BuildPlan` 的块编号与就地释放收集合并为一次 AST 遍历；
- 事实收集与 LLR 共享同一棵 AST 的节点键，不再有跨包的 `blockNode` 补建
  分叉；
- `binding.arg + fromParam` 保持两个字段：`paramRoot()` 的“参数自指优先”
  屏蔽序需要它；并成一片会把传出边算到错误形参，方向是提前释放。
