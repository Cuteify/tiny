// parser/gc_mark.go — 事实的施加点（全套分析唯一的处理器）
//
// 分工：
//
//	收集器（gc_write.go）  只探测。"这一句会产生哪些事实" —— 读类型、读作用域、
//	                      查跨函数摘要，结果收成若干条 mark。**不写任何状态。**
//	applyMark（本文件）    只施加。mark → 具体字段写。**不判任何条件。**
//
// 为什么拆：探测要读的东西五花八门，而且带顺序约束（wfRC 必须先于 wfFresh，
// 否则 newRC 的块会被当普通新分配 claim 掉）；施加只写 Life / Object /
// ArgBlock / FuncBlock 上十几个固定字段。混在一起时，"这套分析能记哪些
// 事实"要读遍所有收集器才拼得出来 —— 现在看 applyMark 的 case 列表就是全集，
// 且每个 case 都标明由哪个收集器发出。
//
// mark 结构体胖，但**每个收集器只填其中 2~3 个**：flag 按收集器分区，
// 不存在"字段对不上的 mark"这种构造。这是 C 里 tagged union 的常规代价。
//
// 为什么不能"全量收集完再统一施加"：多轮 Check。markDefine 每轮开头 Init
// 把这个变量的 Life 整个清掉，而 Check 跑到收敛（package.go，上限 50 轮）。
// 跨语句攒起来施加会把不同轮次的事实混成一锅。能落地的粒度就是**每个站点
// 收集完立刻施加完**。

package parser

import "fmt"

// markFlag 一条待施加的事实。分四组，每组由唯一的收集器发出。
type markFlag uint16

const (
	// --- 变量写站点（collectWrite，gc_write.go）---
	mkInit      markFlag = 1 << iota // m.l.Init(m.v)：清空（保 alloc），owner = m.v
	mkScope                          // m.l.Scope = curScope
	mkOldObj                         // m.v.Life.OldObj = m.l.Obj     ← 必须排在 mkObj* 之前
	mkObjClaim                       // m.l.Obj = claim(m.v)
	mkObjAlias                       // m.l.unify(m.src)：抄对方对象身份
	mkObjNil                         // m.l.Obj = nil
	mkWroteTo                        // m.src.WroteTo += m.l.owner
	mkFromParam                      // m.l.fromParam = m.src 的参数来源

	// --- 字段写站点（collectField）---
	mkFieldBind // m.v（容器）.Life.bindField(m.name, m.src.owner)

	// --- 调用点（collectArgs）---
	mkParamOut // m.l.PassedTo += m.i；m.l.passedAt += m.cb

	// --- 返回点（collectRet）---
	mkReturned    // m.l.Returned = true
	mkTransferObj // m.o.Transferred = true：交给调用者，callee 侧不再释放
	mkFuncOwns    // m.fb.ReturnsOwned = true：返回值里有本帧分配的对象

	// --- 逃逸（多数站点都可能发）---
	mkEscape // m.l.markEscapes()：变量 / 对象 / 参数链 三级级联
)

// mark 一条事实的完整载荷。字段按"哪个收集器用"分组，用不到的留零值。
type mark struct {
	flag markFlag

	// 变量写 / 返回点用
	l   *Life     // 落点：绝大多数事实作用在这个 Life 上
	src *Life     // 右值 / 借用来源（别名、WroteTo、fromParam、字段绑定）
	v   *VarBlock // 语句块：清空的 owner、claim 的宿主、记 OldObj 的宿主

	// 返回点用
	o  *Object    // 被转移所有权的那块
	fb *FuncBlock // 归属函数（声明"返回值里有本帧分配的对象"）

	// 字段写站点用
	name string // 字段名

	// 调用点用
	cb *CallBlock // 调用点（参数链的另一半）
	i  int        // 第几号实参
}

// applyMark 唯一的施加点：把一条 mark 翻成具体字段写。不判任何条件 ——
// 判据全在收集器里，且优先序也只在那里写一次。
func applyMark(m mark) {
	switch m.flag {
	case mkInit:
		m.l.Init(m.v)
	case mkScope:
		m.l.Scope = curScope
	case mkOldObj:
		// 覆盖前把旧对象记在**语句块**上（不是定义的 Life —— 同一变量可能被
		// 赋值多次，记在定义上会互相覆盖）。旧对象"失去这个名字"是 Obj 被
		// 覆盖的自然结果，不需要撤销任何东西。
		m.v.Life.OldObj = m.l.Obj
	case mkObjClaim:
		m.l.claim(m.v)
	case mkObjAlias:
		m.l.unify(m.src)
	case mkObjNil:
		m.l.Obj = nil
	case mkWroteTo:
		if m.l.owner != nil {
			m.src.WroteTo = append(m.src.WroteTo, m.l.owner)
		}
	case mkFromParam:
		// 记住这个借用来自哪个参数：后面它被存到全局之类时，逃逸要能算回
		// 那个参数头上（跨函数摘要要用）。
		if m.src.arg != nil {
			m.l.fromParam = m.src.arg
		} else {
			m.l.fromParam = m.src.fromParam
		}
	case mkFieldBind:
		m.v.Life.bindField(m.name, m.src.owner)
	case mkParamOut:
		m.l.PassedTo = append(m.l.PassedTo, m.i)
		m.l.passedAt = append(m.l.passedAt, m.cb)
	case mkReturned:
		m.l.Returned = true
	case mkTransferObj:
		m.o.Transferred = true
	case mkFuncOwns:
		m.fb.ReturnsOwned = true
	case mkEscape:
		m.l.markEscapes()
	default:
		// 加了新 flag 却忘了写 case —— 静默什么都不做，症状是"对象凭空消失"
		// 而不是报错。这里必须炸出来。
		panic(fmt.Sprintf("gc_mark: 未知事实 flag=%d", m.flag))
	}
}

// applyMarks 施加一个站点收集到的全部事实。收集器的产物总是立刻用完，
// 所以这里是纯循环，不缓存 —— 递归收集（collectExpr）各自持有自己的切片。
func applyMarks(ms []mark) {
	for _, m := range ms {
		applyMark(m)
	}
}
