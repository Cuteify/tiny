// gc/facts.go — 后置事实收集：Check 收敛后遍历 AST，复刻旧链
// var.go / call.go / return.go 里的 GC 钩子。
//
// 纪律与旧链一致：只写正向事实不撤销；“对象被哪些名字指着”由 collectNames
// 一次反转得出；每条语句只回答“现在指向谁”；失败方向只有一边 —— 拿不准就
// 往多标 / 不释放偏，绝不提前释放。
//
// 与 Check 期的差异：这里按最终 AST 做一次完整后序遍历，顺序复刻
// Node.Check（进入作用域 → Children → 自身 Check；IfBlock 的 else 在
// Children 之后；ForBlock 的 init/cond/incr 在循环体之后；FuncBlock 的
// 参数在函数体之后）。多轮 Check 的中间形态不参与，最终事实以最后一轮为准。

package gc

import (
	"fmt"

	"cuteify/parser"
)

// markFlag 一条待施加的事实。分四组，每组由唯一的收集器发出。
type markFlag uint16

const (
	// --- 变量写站点（collectVar）---
	// 纯判别值，每条 mark 恰好一个 flag。mkOldObj 施加序必须先于 mkObj*
	// （claim 会覆盖 obj）—— 由 collectVar 的追加顺序保证，与编号无关。
	mkInit      markFlag = iota + 1 // initBinding(m.l, m.v)：清空（保 alloc），owner = m.v
	mkScope                         // m.l.scope = curScope
	mkOldObj                        // m.v 的 oldObj = m.l.obj
	mkObjClaim                      // m.l.obj = claim(m.v)
	mkObjAlias                      // m.l.unify(m.src)：抄对方对象身份
	mkObjNil                        // m.l.obj = nil
	mkWroteTo                       // m.src.wroteTo += m.l.owner
	mkFromParam                     // m.l.fromParam = m.src 的参数来源

	// --- 字段写站点（collectField）---
	mkFieldBind // 容器 m.v 的字段 m.name 绑定到 m.src.owner

	// --- 调用点（collectArgs）---
	mkParamOut // m.l.out += paramOut{cb,i}；按 (cb,i) 判重

	// --- 返回点（collectRet）---
	mkTransferObj // m.o.Transferred = true：交给调用者，callee 侧不再释放
	mkFuncOwns    // m.fb.ReturnsOwned = true：返回值里有本帧分配的对象

	// --- 逃逸（多数站点都可能发）---
	mkEscape // m.l.markEscapes()：变量 / 对象 / 参数链 三级级联
)

// mark 一条事实的完整载荷。字段按“哪个收集器用”分组，用不到的留零值。
type mark struct {
	flag markFlag

	// 变量写 / 返回点用
	l   *binding         // 落点：绝大多数事实作用在这个 binding 上
	src *binding         // 右值 / 借用来源（别名、wroteTo、fromParam、字段绑定）
	v   *parser.VarBlock // 语句块：清空的 owner、claim 的宿主、记 oldObj 的宿主

	// 返回点用
	o  *Object           // 被转移所有权的那块
	fb *parser.FuncBlock // 归属函数（声明“返回值里有本帧分配的对象”）

	// 字段写站点用
	name string // 字段名

	// 调用点用
	cb *parser.CallBlock // 调用点（参数链的另一半）
	i  int               // 第几号实参
}

// applyMark 唯一施加点：把一条 mark 翻成具体字段写。
func (a *analysis) applyMark(m mark) {
	switch m.flag {
	case mkInit:
		a.initBinding(m.l, m.v)
	case mkScope:
		m.l.scope = a.curScope
	case mkOldObj: // 记在语句块而不是定义 binding：同一变量多次赋值会互相覆盖
		a.state(m.v).oldObj = m.l.obj
	case mkObjClaim:
		a.claim(m.l, m.v)
	case mkObjAlias:
		m.l.unify(m.src)
	case mkObjNil:
		m.l.obj = nil
	case mkWroteTo:
		if m.l.owner != nil {
			m.src.wroteTo = append(m.src.wroteTo, m.l.owner)
		}
	case mkFromParam: // 摘要要靠它把逃逸算回参数头上
		m.l.fromParam = m.src.paramRoot()
	case mkFieldBind:
		a.bindField(m.v, m.name, m.src.owner)
	case mkParamOut: // 参数无 define，init 清不到账；每轮重发同批边 → 查重
		for _, e := range m.l.out {
			if e.cb == m.cb && e.i == m.i {
				return
			}
		}
		m.l.out = append(m.l.out, paramOut{cb: m.cb, i: m.i})
	case mkTransferObj:
		m.o.Transferred = true
	case mkFuncOwns:
		a.owns[m.fb] = true
	case mkEscape:
		a.markEscapes(m.l)
	default: // 新 flag 忘写 case 的症状是“对象凭空消失” —— 必须炸出来
		panic(fmt.Sprintf("gc: 未知事实 flag=%d", m.flag))
	}
}

// applyMarks 施加一个站点收集到的全部事实（产物总是立刻用完，不缓存）。
func (a *analysis) applyMarks(ms []mark) {
	for _, m := range ms {
		a.applyMark(m)
	}
}

// collectFacts 后置事实收集入口。root 必须是包合并、Check 收敛后的根节点。
func (a *analysis) collectFacts(root *parser.Node) {
	a.walkFacts(root)
}

// walkFacts 复刻 Node.Check 的遍历顺序。Check 先递归 Children，再调用节点
// 自己的 Check；作用域在进入节点时切到 n.Value，退出时恢复。
func (a *analysis) walkFacts(n *parser.Node) {
	if n == nil {
		return
	}
	if parser.IsScopeBlock(n.Value) {
		prev := a.curScope
		a.curScope = n.Value
		defer func() { a.curScope = prev }()
	}
	if fb, ok := n.Value.(*parser.FuncBlock); ok {
		prev := a.curFunc
		a.curFunc = fb
		defer func() { a.curFunc = prev }()
	}

	for _, c := range n.Children {
		a.walkFacts(c)
	}

	// 节点自身的 Check 钩子。IfBlock.Check 先查条件、再查 else；
	// ForBlock.Check 在循环体之后查 init/cond/incr；FuncBlock.Check 在
	// 函数体之后查参数；SwitchBlock.Check 在 case 之后查 target。
	switch v := n.Value.(type) {
	case *parser.VarBlock:
		a.markVar(v)
	case *parser.CallBlock:
		a.markArgs(v)
	case *parser.ReturnBlock:
		a.markRets(v)
	case *parser.IfBlock:
		a.markExprCalls(v.Condition)
		if v.ElseBlock != nil {
			a.walkFacts(v.ElseBlock)
		}
	case *parser.ElseBlock:
		a.markExprCalls(v.IfCondition)
	case *parser.ForBlock:
		if v.Range != nil {
			a.markExprCalls(v.Range)
		} else {
			a.markExprCalls(v.Init)
			a.markExprCalls(v.Condition)
			a.markExprCalls(v.Increment)
		}
	case *parser.SwitchBlock:
		a.markExprCalls(v.Target)
	case *parser.CaseBlock:
		for _, e := range v.Values {
			a.markExprCalls(e)
		}
	case *parser.DeferBlock:
		if v.Call != nil {
			a.markArgs(v.Call)
		}
	case *parser.FuncBlock:
		for _, ag := range v.Args {
			if ag != nil && ag.Default != nil {
				a.markExprCalls(ag.Default)
			}
		}
	}
}

// markVar 变量写站点：定义 / 赋值两分支都挂，改的都是定义那份账本。
// 字段写（!IsDefine && len(Name)>1）经 lifeOf 进来时 l 是容器的 binding。
// 定义点多一条 Init（清空上一轮，alloc 除外），collectVar 按 v.IsDefine 发出。
//
// 调用前必须先走一遍 v.Value 里的调用点：旧链 VarBlock.Check 先
// v.Value.Check(p)（Expression.checkCall → CallBlock.Check → markArgs），
// 再 l.markVar(v)；collectVar 对 fresh 分配提前 return，不会自己补这一趟。
func (a *analysis) markVar(v *parser.VarBlock) {
	if v == nil {
		return
	}
	a.markExprCalls(v.Value)

	// 字段操作
	if !v.IsDefine && len(v.Name) > 1 {
		if l := a.lifeOf(v); l != nil {
			a.applyMarks(a.collectField(l, v))
		}
		return
	}

	// 普通赋值。定义点的账本直接是语句自己（旧链 v.Life.markVar(v)）；
	// 赋值点沿解析链挂到定义 / 参数上。
	var l *binding
	if v.IsDefine {
		l = a.state(v)
	} else {
		l = a.lifeOf(v)
	}
	if l == nil {
		return
	}
	a.applyMarks(a.collectVar(l, v))
}

// collectVar 变量写站点（定义 / 赋值共用）：形态判定与事实收集同一条链，
// 优先序就是语义，只在这里写一次 ——
//
//  1. 非 owning 最高：连右值都不看（避开 bareRef 给参数打归调用方基线的副作用）
//  2. isRCExpr 先于 fresh：newRC 的 Call 同时带 NewType 和 IsRC，先判 fresh
//     会把 RC 块当新分配 claim，调用方再 rcDec 就是双重释放
//  3. 全局 / newRC 在记旧对象之前 return（记了会 free 全局的 / 手工管的块）
func (a *analysis) collectVar(l *binding, v *parser.VarBlock) []mark {
	// fact 本站点恒定的 l / v / src 统一填，分派里只剩“产生哪几条事实”。
	fact := func(flag markFlag, src *binding) mark {
		return mark{flag: flag, l: l, v: v, src: src}
	}

	var m []mark
	if v.IsDefine { // Init 清空上一轮（alloc 保）再记作用域 —— 作用域不能被形态闸门挡掉，
		// 否则“有 obj 却没 scope”，释放点塌回创建作用域 → 提前释放（踩过的坑）。
		m = append(m, fact(mkInit, nil), fact(mkScope, nil))
	}
	if !owningType(v.Type) {
		return m // int / bool / float：赋值与 GC 无关
	}

	src := a.bareRef(v.Value) // 右值的归属；nil = 不是裸引用
	if v.IsGlobal {
		m = append(m, fact(mkEscape, nil)) // 全局不在任何栈帧内
		if src != nil {
			m = append(m, fact(mkWroteTo, src))
		}
		return a.collectExpr(m, v.Value, true)
	}

	if isRCExpr(v.Value) {
		return append(m, fact(mkObjNil, nil)) // 生命周期由调用者手工 rcDec 管
	}

	if !v.IsDefine {
		m = append(m, fact(mkOldObj, nil)) // 覆盖点先记旧对象（全局 / newRC 已提前返回）
	}

	switch {
	case a.freshAllocExpr(v.Value):
		return append(m, fact(mkObjClaim, nil)) // 当场新建：拥有新对象（多处 new 是不同对象）
	case src != nil:
		if copiesFields(v.Type) {
			// 容器复制：d 的字段指针被 sh 带走，此后逃逸回溯不到字段 → 源当逃逸
			return append(m, mark{flag: mkEscape, l: src})
		}
		return append(m,
			fact(mkObjAlias, src),
			fact(mkWroteTo, src),
			fact(mkFromParam, src))
	default:
		return append(m, fact(mkObjNil, nil)) // 字段读 / 索引 / 调用结果 / 字面量：借用
	}
}

// collectField 字段写入 p.f = v：容器记下字段关系；认不出容器时保守让值逃逸。
// l 是容器的 binding；逃逸与绑定的 src 都是右值的 binding——装进格子的是值。
func (a *analysis) collectField(l *binding, v *parser.VarBlock) []mark {
	fname := v.Name.Last()

	// 基对象：解析链首个非全局容器；全局 / 参数容器认不出 → 走逃逸兜底
	var base *parser.VarBlock
	for _, p := range v.Define.Path {
		if vb, ok := p.(*parser.VarBlock); ok && !vb.IsGlobal {
			base = vb
			break
		}
	}

	fieldType := v.Type // 字段类型直读：checker 强制非空（var.go:600），非反查

	var src *binding
	if e := v.Value; e != nil && e.Var != nil && e.Var.Name.Length() == 1 {
		src = a.bareRef(e) // 仅普通名引用：字段读没有自己的对象，绑上即错
	}

	// 认不出容器：值存进查不出的容器，让**值**逃逸（不是容器）
	if base == nil {
		if src != nil && owningType(fieldType) {
			return []mark{{flag: mkEscape, l: src}}
		}
		return nil
	}

	if !owningType(fieldType) { // 字段不自带堆指针，无需记关系
		return nil
	}
	if src == nil {
		return nil
	}
	return []mark{{flag: mkFieldBind, v: base, name: fname, src: src}}
}

// markArgs 调用点。实参是否升级逃逸取决于被调函数的参数摘要 —— 摘要说
// “只读不存”，实参就还能按作用域释放。操作的是整条实参列表，不属于单个
// 变量，所以不挂在 binding 上。
func (a *analysis) markArgs(cb *parser.CallBlock) {
	if cb == nil {
		return
	}
	a.applyMarks(a.collectArgs(nil, cb))
}

// collectArgs 调用点收集器：实参是否升级逃逸（问被调摘要），
// 以及参数链记一笔“我被传出过”。追加式：语句调用点（markArgs）与
// 表达式内嵌调用（collectExpr）共用一个拼装处，不复刻第二份循环。
func (a *analysis) collectArgs(out []mark, cb *parser.CallBlock) []mark {
	// 内建调用复刻旧链 checkBuiltin 短路：Check 在 markArgs 之前就 return，
	// 实参不升级逃逸、也不记参数链。嵌套调用在 checkBuiltin 里照常 Check
	//（其自身的 markArgs 会跑），所以这里只补嵌套调用遍历。
	// len/cap/copy 的实参在旧链里是“只读”——少标这一笔能把字符串/列表
	// 留在作用域释放，正是旧基线 scope 计数的来源。
	if builtinHandled(cb) {
		for _, ag := range cb.Args {
			if ag != nil && ag.Value != nil {
				a.markExprCalls(ag.Value)
			}
		}
		return out
	}

	// 遍历所有实参
	for i, ag := range cb.Args {
		if ag == nil || ag.Value == nil || ag.Defind != nil {
			continue
		}

		// 处理实参值
		out = a.collectExpr(out, ag.Value, a.argEscapeOf(cb, i))

		// 参数 / 参数借用被当作第 i 个实参传出 → 记进参数链，供摘要判定
		if l := a.bareRef(ag.Value); l != nil {
			if p := l.paramRoot(); p != nil {
				out = append(out, mark{flag: mkParamOut, l: a.argState(p), i: i, cb: cb})
			}
		}
	}

	// 遍历所有变参
	for _, ag := range cb.VariadicArgs {
		if ag != nil && ag.Value != nil {
			out = a.collectExpr(out, ag.Value, a.argEscapeOf(cb, len(cb.Args)))
		}
	}

	// 处理 this 指针
	if cb.ThisVar != nil {
		out = a.collectExpr(out, &parser.Expression{Var: cb.ThisVar}, true)
	}
	return out
}

// builtinHandled 判断该调用是否会被旧链 CallBlock.checkBuiltin 短路。
// 条件逐条对应 parser/call.go 的那段分派；只看 Check 收敛后的类型，
// 不引入新语义。命中时旧链不调 markArgs，新链也必须跳过外层实参标记。
func builtinHandled(cb *parser.CallBlock) bool {
	if cb == nil || cb.Name == nil {
		return false
	}
	switch cb.Name.String() {
	case "new", "newRC", "sizeof":
		return cb.NewType != nil
	case "len", "lists_len", "cap", "lists_cap":
		if len(cb.Args) != 1 || cb.Args[0] == nil || cb.Args[0].Value == nil {
			return false
		}
		t := cb.Args[0].Value.Type
		return t != nil && (t.Kind() == "string" || t.Kind() == "list")
	case "copy":
		if len(cb.Args) != 2 || cb.Args[0] == nil || cb.Args[0].Value == nil ||
			cb.Args[1] == nil || cb.Args[1].Value == nil {
			return false
		}
		dst, src := cb.Args[0].Value.Type, cb.Args[1].Value.Type
		return dst != nil && src != nil && dst.Kind() == src.Kind() &&
			(dst.Kind() == "string" || dst.Kind() == "list")
	}
	return false
}

// markRets 返回语句。返回本地对象 → 所有权转移给调用者；返回参数 → 不转移
// （调用者本来就有）。操作的是整个返回值列表。
func (a *analysis) markRets(r *parser.ReturnBlock) {
	if r == nil || len(r.Value) == 0 {
		return
	}
	fb := a.curFunc
	if fb == nil {
		return
	}
	for i, e := range r.Value {
		// 非 owning 返回值不带堆指针：ret result.val 返回 int，result 并没有返回出去。
		if i >= len(fb.Return) || !owningType(fb.Return[i]) {
			continue
		}
		a.applyMarks(a.collectRet(fb, e))
	}
}

// collectRet 一个返回值的所有权归属：
//
//	裸引用参数 / 全局  → 不转移，调用者本来就有
//	裸引用本地对象    → 转移；但已存全局 / 装箱 / 传过未知函数的转移不了
//	                   （两个持有者，只能退 RC）
//	new(T)            → 转移（当场新建是本帧所有）
//	字段读 / 调用结果 → 保守当真逃逸：无法确定那是谁的块
func (a *analysis) collectRet(fb *parser.FuncBlock, e *parser.Expression) []mark {
	if e == nil {
		return nil
	}

	// 处理裸引用
	if l := a.bareRef(e); l != nil {
		if l.owner == nil || l.owner.IsGlobal {
			return nil // 参数 / 全局：调用者或全局本来就有，不转移
		}
		var m []mark
		if o := l.obj; o != nil && !o.Escapes {
			m = append(m,
				mark{flag: mkTransferObj, o: o},
				mark{flag: mkFuncOwns, fb: fb})
		}
		return m
	}

	// 处理 new(T) 调用
	if e.Call != nil && e.Call.IsBuiltinNewAlloc() {
		m := []mark{{flag: mkFuncOwns, fb: fb}}
		if l := a.lifeOf(e.Call.ThisVar); l != nil {
			if o := l.obj; o != nil && !o.Escapes {
				m = append(m, mark{flag: mkTransferObj, o: o})
			}
		}
		return m
	}

	// 调用结果：实参照常按逃逸传播；被调返回来源为 Fresh 时，本函数把
	// 所有权继续转交给调用者，owns 也应为真（摘要本身不依赖它）。
	if e.Call != nil {
		m := a.collectExpr(nil, e, true)
		if !e.Call.IsRC && e.Call.Func != nil && a.retSourceOf(e.Call.Func) == ReturnFresh {
			m = append(m, mark{flag: mkFuncOwns, fb: fb})
		}
		return m
	}
	return a.collectExpr(nil, e, true)
}

// collectExpr 把表达式里每个变量引用该记的事实收进 out。escapes 由调用点决定
// 不由表达式本身决定（实参问被调摘要 / 返回看是否本帧自有 / 逃逸值里全逃）。
// 递归共用 out，不额外分配。
func (a *analysis) collectExpr(out []mark, e *parser.Expression, escapes bool) []mark {
	if e == nil {
		return out
	}

	// 处理变量引用
	if e.Var != nil && escapes {
		if l := a.lifeOf(e.Var); l != nil {
			out = append(out, mark{flag: mkEscape, l: l})
		}
	}

	// 处理调用点
	if cb := e.Call; cb != nil {
		out = a.collectArgs(out, cb)
	}

	// 处理子表达式
	out = a.collectExpr(out, e.Left, escapes)
	out = a.collectExpr(out, e.Right, escapes)

	// 处理索引表达式
	for _, ix := range e.Index {
		out = a.collectExpr(out, ix, escapes)
	}

	// 处理列表元素表达式
	for _, le := range e.ListElems {
		out = a.collectExpr(out, le, escapes)
	}
	return out
}

// markExprCalls 处理节点自身表达式里的调用点。CallBlock.Check 不一定是 AST
// 节点（表达式里的调用只在 Expression.Check 里被查），旧链靠 checkCall 触发
// markArgs；后置 pass 必须显式走一遍表达式树，否则 if/for/switch 条件里的
// 实参逃逸事实会漏。重复施加是幂等的。
func (a *analysis) markExprCalls(e *parser.Expression) {
	if e == nil {
		return
	}
	if e.Call != nil {
		a.markArgs(e.Call)
	}
	a.markExprCalls(e.Left)
	a.markExprCalls(e.Right)
	for _, ix := range e.Index {
		a.markExprCalls(ix)
	}
	for _, le := range e.ListElems {
		a.markExprCalls(le)
	}
}
