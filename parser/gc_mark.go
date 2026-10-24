// parser/gc_mark.go — 事实的施加点（全套分析唯一的处理器）
//
// applyMark 的 case 列表就是这套分析能记的事实全集，每个 case 标明由谁发出。
// 判据与优先序全在收集器侧（gc_write.go），这里不判任何条件。粒度必须是
// 每站点收集完立刻施加完：Check 多轮收敛，markVar 每轮 Init 清账，
// 跨站攒批会把不同轮次的事实混在一起。

package parser

import "fmt"

// markFlag 一条待施加的事实。分四组，每组由唯一的收集器发出。
type markFlag uint16

const (
	// --- 变量写站点（collectVar，gc_write.go）---
	// 纯判别值，每条 mark 恰好一个 flag。mkOldObj 施加序必须先于 mkObj*
	// （claim 会覆盖 Obj）—— 由 collectVar 的追加顺序保证，与编号无关。
	mkInit      markFlag = iota + 1 // m.l.Init(m.v)：清空（保 alloc），owner = m.v
	mkScope                         // m.l.Scope = curScope
	mkOldObj                        // m.v.Life.OldObj = m.l.Obj
	mkObjClaim                      // m.l.Obj = claim(m.v)
	mkObjAlias                      // m.l.unify(m.src)：抄对方对象身份
	mkObjNil                        // m.l.Obj = nil
	mkWroteTo                       // m.src.WroteTo += m.l.owner
	mkFromParam                     // m.l.fromParam = m.src 的参数来源

	// --- 字段写站点（collectField）---
	mkFieldBind // m.v（容器）.Life.bindField(m.name, m.src.owner)

	// --- 调用点（collectArgs）---
	mkParamOut // m.l.out += paramOut{cb,i}；按 (cb,i) 判重

	// --- 返回点（collectRet）---
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

// applyMark 唯一施加点：把一条 mark 翻成具体字段写。
func applyMark(m mark) {
	switch m.flag {
	case mkInit:
		m.l.Init(m.v)
	case mkScope:
		m.l.Scope = curScope
	case mkOldObj: // 记在语句块而不是 Life：同一变量多次赋值会互相覆盖
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
	case mkFromParam: // 摘要要靠它把逃逸算回参数头上
		m.l.fromParam = m.src.paramRoot()
	case mkFieldBind:
		m.v.Life.bindField(m.name, m.src.owner)
	case mkParamOut: // 参数无 define，Init 清不到账；Check 每轮重发同批边 → 查重
		for _, e := range m.l.out {
			if e.cb == m.cb && e.i == m.i {
				return
			}
		}
		m.l.out = append(m.l.out, paramOut{cb: m.cb, i: m.i})
	case mkTransferObj:
		m.o.Transferred = true
	case mkFuncOwns:
		m.fb.ReturnsOwned = true
	case mkEscape:
		m.l.markEscapes()
	default: // 新 flag 忘写 case 的症状是"对象凭空消失" —— 必须炸出来
		panic(fmt.Sprintf("gc_mark: 未知事实 flag=%d", m.flag))
	}
}

// applyMarks 施加一个站点收集到的全部事实（产物总是立刻用完，不缓存）。
func applyMarks(ms []mark) {
	for _, m := range ms {
		applyMark(m)
	}
}
