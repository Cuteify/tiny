# GC 前端 API 与调用流程

> 与 `gc_frontend_design.md` 的分工：设计文档讲"为什么"（原理、公式推导、取舍论证）；
> 本文档讲"谁调用谁、谁提供什么"，是接入与排查用的事实参考。
> 符号均在 `parser/gc_*.go`（九个文件）。
>
> 当前基线：`语料 107/140 · 对象=114 · RC=6 · 泄漏=0 · 提前释放=0`（§5）。

---

## 1. 调用流程总览

### 1.1 Check 期：挂接 → 收集 → 施加

```
package.GetPackage ── Check 多轮收敛（package/package.go，直到稳定）
 │
 ├─ 语句块 Check 挂接（parser 内，每条语句每次轮次都触发）
 │    var.go    定义分支  v.Life.markVar(v)       含"无初值声明"（var p: *Node）
 │    var.go    赋值分支  LifeOf(v).markVar(v)    l 是定义的 Life，v 是引用块
 │    call.go   调用点    markArgs(c)             挂在 Check 尾部（参数检查全部走完）
 │    return.go 返回点    markRets(fb, r.Value)
 │
 ├─ 收集器（gc_write.go，只探测不写）：collectWrite / collectField / collectArgs /
 │    collectRet / collectExpr —— 形态判定 + 优先序，产物是 []mark
 │    期间查询：owningType 等谓词（gc_pred.go）、ArgEscapeOf（§1.3 摘要）
 │
 └─ 施加器（gc_mark.go，唯一处理器）：applyMarks → applyMark → 具体字段写
      每站点即收即施，不攒批；定义点每轮以 mkInit 清账（alloc 保）
```

| 挂接点 | 触发条件 | 例外（不触发） |
|---|---|---|
| `markVar` | VarBlock 定义 / 赋值 `Check` 走到底 | 跨文件未解析标记 `Unresolved` 提前返回的轮次 |
| `markArgs` | 调用参数检查全部走完、`Func` 已解析 | `checkBuiltin` 提前返回的调用（print/len 等只读内建）；跨包未解析的轮次（合并重查轮补挂） |
| `markRets` | 返回语句 `Check` | 非 owning 返回值跳过（`ret n.val` 不带堆指针） |

纪律（详见设计文档 §4）：`curScope` 由 `Node.Check` 逐层设置；失败方向只有
"多标 / 不释放"；只写正向事实，撤销靠多轮 Init 重算而不是回滚。

### 1.2 发布期：SimulateRC 四步（唯一公开入口）

```
package/package.go（Check 收敛之后） → parser.SimulateRC(root)
 1. collectNames(root)   gc_names.go   反转绑定名 → Object.Names
 2. s.walk(root)         gc_inplace.go 槽位表模拟 → 就地释放判定
 3. scopeRelease()       gc_release.go 释放点计算 → Object.FreeScope / Holder
 4. checkPremature()     gc_diag.go    自检，提前释放数必须为 0
```

| 步骤 | 输入 | 产出 | 要点 |
|---|---|---|---|
| collectNames | Life 正向事实 | `Object.Names`、对象级 `Escapes`、FieldVals 收敛 | WroteTo 记在右值：顺序覆盖也算持有（释放点偏外=安全）；同一字段留最后一次，槽已改绑的丢弃 |
| rcSim.walk | 语句序 | `Life.ReleasesOld` / `OldObj` | 旧值再无别的引用（其它槽位 / 字段）才就地释放；有引用 → 交给步骤 3 的作用域规则。调用点不处理——"实参被被调存下"由 Check 期摘要判逃逸，逃逸对象进不了槽位表 |
| scopeRelease | Names / Scope | `Object.FreeScope`、`Holder` | 公式：全部绑定名里最外层的作用域；算不出兜底到所属函数出口 + 创建者槽；`Escapes` / `Transferred` 的跳过 |
| checkPremature | 全对象 | `Premature`（必须 0） | FreeScope 深度不得早于任一绑定名的作用域 |

### 1.3 跨函数摘要：懒算触发链（谁问、谁答、何时算）

```
collectArgs / collectExpr 的实参位
   └─ ArgEscapeOf(cb, idx)             gc_pred.go —— 可替换钩子 var
        └─ paramEscapeOfFunc(fb, idx)   gc_summary.go —— 认不出一律 true
             ├─ memo 命中 → 直接返回
             └─ 首次：computeParamSummary(fb) 当前调用**同步**算到定点再作答
                  ├─ callsIn 收集闭包（显式栈，fb 及其可达被调）
                  ├─ 对闭包内每个 f 跑 scanFuncFacts：
                  │    paramGround：参数写入 全局 / owning 字段 / 装箱(copiesFields)
                  │    out 边：参数被当实参传出 → applyMark(mkParamOut)
                  ├─ 定点迭代：esc[f][i] ∨= ground[i] ∨ passedToEscaping(&f.Args[i].Life)
                  └─ 写 paramMemo[fb]，此后查询直接命中
```

性质：

- **不是两轮舞蹈**——第一次查询在当轮就算完定点再作答；多轮 Check 只是让
  早期解析不出的调用（跨包）在后续轮次重新询问。定义点每轮 `mkInit`
  清账，`Escapes` 单调只增，保证收敛。
- 保守语义只出现在认不出的地方：`cb==nil` / 递归重入 / 传出边指向认不出的
  被调 → 一律按逃逸（退 RC）。
- `passedToEscaping` 读参数 Life 上的 `out`（一片 `paramOut{cb,i}`，调用点存
  指针读取时活解；两路写入经 `applyMark` 按 `(cb,i)` 判重，幂等）。
- 摘要查询在三个消费面生效：`collectArgs` 的实参位、`collectWrite` 全局
  分支与 `collectRet` 经 `collectExpr` 递归进表达式内层调用的实参位。

---

## 2. 端到端示例

### 2.1 覆盖写与就地释放

```
var a: *Node = new(Node)      // 定义分支 → [mkInit, mkScope, mkObjClaim] → a.Life.Obj = #k
var b: *Node = a              // 裸引用 → [mkObjAlias, mkWroteTo, mkFromParam]
                              //   名字反转后 #k.Names = [a, b]
b = new(Node)                 // 覆盖点 → [mkOldObj(#k), mkObjClaim(#m)]
                              //   sim：#k 仍有 a 指着 → 不就地释放；
                              //   释放点由 scopeRelease = max(a.Scope, b.Scope)（函数出口）
b = b.next                    // 字段读（非裸引用）→ [mkOldObj(#m), mkObjNil]
                              //   sim：#m 再无任何名字 → ReleasesOld = true
                              //   后端：先 free #m，再把 b.next 抄进 b
```

### 2.2 返回转移与调用方接管（test/gc_loop 的 prepend）

```
fn prepend(head: *Node, val: int) *Node {
    var n: *Node = new(Node)   // claim 对象 #a
    n.next = head              // 字段写（源是参数：不产生可释放的边）
    ret n                      // markRets → [mkTransferObj(#a), mkFuncOwns(prepend)]
}                              //   #a.Transferred：callee 侧不再释放
caller:
    head = prepend(head, 4)
    // collectWrite：freshAllocExpr 经 FuncBlock.ReturnsOwned 判真 → mkObjClaim
    //   → 调用方 claim 出本帧对象，释放点随调用方作用域走
    // markArgs（实参位）：ArgEscapeOf(prepend, 0) —— prepend 的摘要说
    //   参数存进了字段（paramGround）→ true → mkEscape 级联到旧对象
    //   → 旧对象 Escapes → RC，而不是作用域释放
```

最后一行是 markArgs 的意义所在：不看"我只是把 head 递进去"的表象，问被调
摘要——存了就升级，没存就保持作用域释放（sortTest 类只读调用由此省 RC）。

### 2.3 全局写

```
g = ...                       // 全局分支（collectWrite）→ [mkEscape, mkWroteTo]
                              //   再经 collectExpr(escapes=true) 把右值全树标逃逸
                              //   全局对象一律 RC，不按作用域释放
```

---

## 3. API 参考（按消费方分组）

### 3.1 Check 期挂接面（parser 包内；语句块 Check 调）

| 签名 | 职责 | 挂接处 |
|---|---|---|
| `func (l *Life) markVar(v *VarBlock)` | 变量写站点入口；字段写入（`p.f = y`，按 `len(v.Name)>1` 认出）单独路由 collectField | var.go 定义 / 赋值两分支 |
| `func markArgs(cb *CallBlock)` | 调用点入口；整条实参列表 + 变参 + 方法接收者 | call.go `Check` 尾部 |
| `func markRets(fb *FuncBlock, vals []*Expression)` | 返回点入口；逐返回值按 owning 型过滤 | return.go |

`markVar` 操作**定义**的 Life（赋值也改定义那一份）；`markArgs` / `markRets`
操作整条列表，所以是包级函数。三者产物一律 `applyMarks`，不缓存。

### 3.2 发布面（唯一入口）

| 签名 | 时机 |
|---|---|
| `func SimulateRC(root *Node)` | 必须在 **Check 全部轮次收敛之后**（先知道谁逃逸，才能算释放点）。全编译只调一次（package/package.go） |

发布期读取的是 Life 的最终形态（`Obj / Scope / Escapes / WroteTo`）——这就是
不能在未收敛轮次调它的原因。

### 3.3 工具诊断面（包外可用；tools/esccheck 即此口径）

| 符号 | 语义 |
|---|---|
| `func Objects() []*Object` | 全部对象，只读快照（单线程，线性追加） |
| `func TransferReport() (sent, taken, orphan int, detail []string)` | 转移统计：`sent`=Transferred 对象数；`taken`/`orphan` 按当前流程恒为 0 / 恒=sent（转移块不设 FreeScope，结构使然）——**真泄漏不看它**，看 Objects 三态收口 |
| `var Premature int`、`PrematureDetail []string` | 提前释放计数与明细（发布期第 4 步填） |

三态收口（esccheck 口径）：对象只有三条出路 —— `FreeScope`（作用域释放）/
`Transferred`（转移给调用方）/ `Escapes`（退 RC）；三者都不沾才是真泄漏。

### 3.4 后端契约面（代码生成对 Life 的唯一读法）

| 方法 | 语义 | 后端动作对应 |
|---|---|---|
| `func (l *Life) Disposal() Disposal` | 三态判定，**唯一入口，不要自己拼条件** | Borrow 不做事；Scope 在 ReleaseScope() free；RC 走计数 |
| `func (d Disposal) String()` | `"Scope" / "RC" / "Borrow"`，诊断用 | — |
| `func (l *Life) ReleaseScope() Block` | 释放点作用域（nil = 不释放） | 每逢离开该作用域 free 一次 |
| `func (l *Life) Holder() *VarBlock` | free 时哪个栈槽（创建者被改绑时指向别的绑定名） | 释放指令的地址来源 |
| `func (l *Life) IsRep() bool` | 我是否拥有这个对象（分配就发生在我的槽位上） | 区分创建者与普通绑定名 |
| `Life.ReleasesOld bool` / `Life.OldObj *Object` | 写入前先释放旧值（就地释放判定） | 赋值前先 free 旧块再写 |
| `FuncBlock.ReturnsOwned bool` | "返回值里有本帧分配的对象"声明 | 调用方 freshAllocExpr 消费 → claim |

Disposal 判定序（一个方法写死，读语义按这个序理解）：

```
Obj == nil                         → Borrow（参数 / 字段读 / 调用结果 / newRC）
Transferred                         → Borrow（所有权已交给调用者，本帧不碰）
Escapes（自身或任一绑定名逃逸）      → RC
FreeScope == nil（无绑定名指向）     → Borrow（孤儿；连兜底都算不出的极少数）
其余                                → Scope
```

### 3.5 特殊调用面

| 符号 | 语义 | 谁调用 |
|---|---|---|
| `func CopyLife(dst, src *VarBlock)` | 单态化深拷贝 VarBlock 必须**显式**调用（Life 非导出字段不被字面量带上；漏拷 → 特化副本误判"自有且不逃逸" → 提前释放） | compile/monomorphize.go |
| `var ArgEscapeOf func(cb *CallBlock, idx int) bool` | 实参升级判定钩子；默认连到 gc_summary 懒算链 | 收集器；接更精确摘要（如后端）时替换此 var |
| `CallBlock.IsRC`（收集器经 `isRCExpr` 判） | `newRC` 分配自带 RC 头、用户手工 rcDec，前端不 claim 不自动释放 | collectWrite 第 3 优先级 |

### 3.6 Check 期内部 API（排查调试用；包外不可见）

| 符号 | 一句话 |
|---|---|
| `collectWrite / collectField / collectArgs / collectRet / collectExpr` | 五个收集器：形态判定 + 事实产出，优先链见 §4.1 |
| `applyMark / applyMarks` | 唯一处理器：mark 翻成字段写；未知 flag 必须 panic |
| `newObject / claim / unify / bindField / markEscapes / Init / paramRoot` | 字段写的具体执行者（gc_model.go） |
| `paramEscapeOfFunc / computeParamSummary / scanFuncFacts / passedToEscaping` | 摘要懒算链（§1.3） |
| `fieldBaseOf / lookupInFunc` | 字段写基对象解析：遮蔽歧义 → nil → 保守 |
| `collectNames / outerScope / scopeDepth / outerParent / walkSubNodes` | 反转与作用域工具（发布期第 1 步 + 诊断） |
| `scopeRelease / scopeKindOf / firstLiveName / funcOfBlock` | 释放点计算与兜底 |
| `rcSim` 系列（walk / leaveScope / releasesOld / slotOf / fieldVal / setField / stmt / evalCopy / fieldWrite / declare…） | 槽位表模拟（就地释放）；状态：`slot` 槽位表 + `fields` 字段表 + `stack` 作用域栈 |

---

## 4. 数据模型速查

### 4.1 形态判定优先链（collectWrite，按代码里的发出顺序）

```
1. 定义点：mkInit + mkScope 先发（Init 清账；作用域不能被 owning 闸门挡掉）
2. !owningType(v.Type)       → 到此为止（int / bool 与 GC 无关）
3. 全局左值                  → mkEscape + mkWroteTo + collectExpr(all escape)，提前 return
4. 右值是 newRC()            → mkObjNil，提前 return（生命周期手工管）
5. 覆盖点（非定义）          → mkOldObj 先记旧对象（此后 claim / nil都会覆盖 Obj）
6. freshAllocExpr(右值)      → mkObjClaim（new / ReturnsOwned 调用 / 字符串拼接）
7. 裸引用右值                → mkObjAlias + mkWroteTo + mkFromParam
                               （右值类型 copiesFields → 源 mkEscape）
8. 其余（字段读 / 索引 / 调用结果 / 字面量）→ mkObjNil（借用）
```

施加序约束：同一站点内 `mkOldObj` 必须先于 `mkObj*`（claim 会覆盖 Obj），
`mkInit / mkScope` 永远在最前——由收集器追加顺序保证。

### 4.2 Life 字段表（挂点：`VarBlock.Life`（var.go）、`ArgBlock.Life`（func.go））

| 字段 | 可见 | 写入者 | 消费者 |
|---|---|---|---|
| `Obj *Object` | 导出 | mkObjClaim / mkObjAlias / mkObjNil（Check） | Disposal / IsRep / ReleaseScope / Holder |
| `Scope Block` | 导出 | mkScope（定义点每轮） | scopeRelease / checkPremature |
| `alloc *Object` | 私 | claim 复用（多轮 Check 不重复建对象） | claim |
| `ReleasesOld bool` | 导出 | rcSim.walk（发布期第 2 步） | 后端（就地释放时机） |
| `OldObj *Object` | 导出 | mkOldObj（记在语句块 Life） | 后端（free 哪块） |
| `Escapes bool` | 导出 | markEscapes（mkEscape 的施加）；LifeOf / ArgBlock.Check 给参数打基线；collectNames 名字级收口到对象 | Disposal → RC |
| `WroteTo []*VarBlock` | 导出 | mkWroteTo（记在右值） | collectNames 补 Names |
| `arg / fromParam / out []paramOut` | 私 | LifeOf 基线 / mkFromParam / mkParamOut 判重 | 摘要定点（§1.3） |
| `owner *VarBlock` | 私 | Init 登记 | IsRep / mkWroteTo / bindField |

参数基线：参数由调用者持有 → `ArgBlock.Check` 与 `LifeOf` 都把参数的
`Escapes = true` 打上——本帧永不自动释放参数块。

### 4.3 Object 字段表（全导出）

| 字段 | 写入者 | 后端读 |
|---|---|---|
| `ID int` | newObject（第几次分配） | 诊断 / 表索引 |
| `Owner *VarBlock` | claim（创建栈槽；可能已被改绑） | 兜底 Holder |
| `Scope Block` | claim（创建作用域） | funcOfBlock 兜底 |
| `Escapes bool` | markEscapes / collectNames 收口 | Disposal → RC |
| `Transferred bool` | mkTransferObj（ret 本地裸对象） | Disposal → callee 不释放 |
| `Names []*VarBlock` | collectNames（反转 + WroteTo 补边） | FreeScope 取最外层 / Holder 核对 |
| `FreeScope Block` | scopeRelease（或兜底函数出口） | **free 点**；nil = 不释放 |
| `Holder *VarBlock` | scopeRelease（或兜底创建者） | free 读哪个栈槽 |
| `FieldVals []FieldBinding` | bindField + collectNames 收敛 | **仅排序**（字段值先于容器），不决定是否释放 |

### 4.4 markFact 全集（13 个 flag；applyMark 的 case 序即全集）

| flag | 发出者 | 施加动作（字段写） |
|---|---|---|
| `mkInit` | collectWrite（定义点） | `l.Init(v)`：清账保 alloc，owner = v |
| `mkScope` | collectWrite（定义点） | `l.Scope = curScope` |
| `mkOldObj` | collectWrite（覆盖点） | 记在**赋值语句块**的 Life：`v.Life.OldObj = l.Obj`（同一变量多处赋值各记各的） |
| `mkObjClaim` | collectWrite（fresh） | `l.claim(v)` |
| `mkObjAlias` | collectWrite（裸引用） | `l.unify(src)`：抄对象身份 |
| `mkObjNil` | collectWrite（借用 / newRC 覆盖点） | `l.Obj = nil` |
| `mkWroteTo` | collectWrite / 全局分支 | `src.WroteTo += l.owner` |
| `mkFromParam` | collectWrite（裸引用） | `l.fromParam = src.paramRoot()` |
| `mkFieldBind` | collectField | 容器 `bindField(name, src.owner)` |
| `mkParamOut` | collectArgs / scanFuncFacts（同一条事实两路，判重幂等） | `l.out += paramOut{cb,i}` |
| `mkTransferObj` | collectRet | `o.Transferred = true` |
| `mkFuncOwns` | collectRet / new 分支 | `fb.ReturnsOwned = true` |
| `mkEscape` | 多数站点（全局 / 装箱 / 实参升级 / 逃逸值全树） | `l.markEscapes()`：变量 / 对象 / 参数链三级级联 |

### 4.5 判据谓词（gc_pred.go，只读不写）

| 谓词 | 一句话 | 拿不准时 |
|---|---|---|
| `owningType(t)` | `t.IsOwning` 的 nil 安全包装（`*T` / string / list 等） | Type 未解析 → false（无堆指针，天然安全） |
| `copiesFields(t)` | 接口 / any，或含 owning 字段的值类型 | true → 源标逃逸（副本可能活得更久） |
| `fieldTypeOwning(t, f)` | 结构体字段是否带堆指针 | — |
| `freshAllocExpr(e)` | new、ReturnsOwned 的调用、字符串拼接（newRC 由 isRCExpr 先行排除） | false → 不 claim |
| `isRCExpr(e)` | `Call.IsRC`（newRC） | true → 跳过 claim 与自动释放 |
| `bareRef / bareVar` | 表达式是纯变量引用（字段读 / 索引 / 调用结果都不是） | nil → 按借用 / 孤立处理 |

---

## 5. esccheck 用法与基线

```
go build -o /tmp/esc ./tools/esccheck
/tmp/esc ./test/<目录>      # 每个目录独立进程（objects 全局寄存器不能跨目录混跑）
```

全量跑法是 `for d in test/*/ pkg/*/` 逐目录执行（报错目录跳过），首两行聚合：

```
对象=114  RC/泄漏释放=6  泄漏=0  提前释放=0
  作用域释放=86  转移=22  RC=6  真泄漏=0  (转移报告 交出=22 接管=0 无人接管=22)
```

- 基线：通过 107/140 · 对象=114 · RC=6 · 泄漏=0 · 提前=0。改动 `gc_*.go`
  之后必须钉住这组数字（基线变更史见 `gc_frontend_design.md` §5）。
- `RC=6` 来自 markArgs 挂接恢复（prepend 存字段类实参，方向=多标）。
- `提前释放` 必须恒 0——它挂在 checkPremature 的自检上。
- 工具本身是临时调器件（"验证完即删"），不属交付物。

---

## 6. 后端接入清单（谁在何时读什么）

**总顺序**：`Check` 收敛 → `parser.SimulateRC(root)` → 按下面清单消费。
Check 中间轮次的快照不可信（绑定名集合 / 摘要 / 类型都可能还没收敛）。

1. **遍历 `parser.Objects()`**，按每块对象的三态分派（三态与 `Life.Disposal()`
   的判定序一一对应，§3.4）：

   | 对象状态 | 后端动作 |
   |---|---|
   | `Transferred` | 什么都不做——调用方已经接管 |
   | `FreeScope != nil`（非 Transferred / 非 Escapes） | Scope 释放：在 `FreeScope` 对应作用域出口 free 一次；读 `Holder()` 槽；`FieldVals` 里的字段值块排在容器之前释放（**FieldVals 只用于排序**，绝不据此判是否释放） |
   | `FreeScope == nil` 且 `Escapes` | RC 释放：分配带 RC 头、rcInc / rcDec；全局属此类 |
   | 三态全空 | 真泄漏——基线上不允许出现，出现即报 |

2. **就地释放**：写左值前读右值侧 `Life.ReleasesOld`（+ `OldObj`），为 true
   则先 free 旧块再写——"多个引用时改一个槽位要不要 free"的答案在这里。

3. **转移**：`Transferred` 的块 callee 侧绝不释放；调用方经
   `FuncBlock.ReturnsOwned` 把返回值当作本帧新分配接管（§2.2），释放点随
   调用方的作用域 / RC 规则走。

4. **单态化**：特化副本必须调 `parser.CopyLife`（compile/monomorphize.go
   现挂）。漏拷的后果不是泄漏而是**提前释放**（Life 缺失被当成
   "自有且不逃逸"）。

5. **禁忌**：

   - 不要绕开 `Disposal()` 自己拼三态条件（判定序一变就悬垂）；
   - 不要读 Check 中间轮次；不要在 SimulateRC 之前读 FreeScope / Names；
   - 不要为 `FieldVals` 单独建释放逻辑；
   - 不要假设 `TransferReport.taken` > 0（结构上恒 0，§3.3）；
   - `newRC` 块与全局初始化路径不进清单第 1 条，按手工 RC 语义管。

---

## 7. 现状备注

- 九个 `parser/gc_*.go` 是前端全部；`compile/gc*` 是后端（用户手动重构域）。
  旧 `docs/frontend_gc_contract.md` 已丢失，契约以 `gc_frontend_design.md`
  §8 为准，本档 §3.4 / §6 是它的展开。
- 基线跳过口径：140 个目录中 33 个不可跑（10 远端缺文件、9 语料语法错、
  14 真代码缺口），验证时这些目录不产数字、不参与聚合。
- `ast.html`（parser/parser.go:677）是解析调试副产物，每次运行整体重写；
  若不需要可加 `.gitignore` 或随调试容器一并删除。
