// gc/paramsum.go — 跨函数过程摘要：入参指针是否逃逸。
//
// 调用点不读被调函数体，只查表：第 idx 个实参"只读不存"则调用方继续按作用域
// 释放，可能被存到别处则退回 RC。
//
// 判定规则（sound 的 may 分析）—— 参数逃逸 ⟸ 存进全局 / 装箱进接口或结构体
// 值 / 写进结构体字段 / 作为第 j 实参传出且被调第 j 号参数也逃逸 / 被调函数
// 认不出来。不算逃逸：读取、本帧局部倒手、作为返回值传出（返回参数所有权
// 仍在调用方）。
//
// 为什么最小定点：may 分析的结论是"存在一条推导链证明逃逸"。最大定点从全
// 逃逸收缩会把纯递归锁死（递归边自己依赖自己）；最小定点下没有地面事实的
// 递归环推不出逃逸 —— 环里没有一条真把指针存到外面。

package gc

import "cuteify/parser"

// paramEscapeOfFunc 被调函数第 idx 号参数是否逃逸。认不出来（泛型未解析 /
// 不在合并树 / 序号越界 / 递归重入）一律 true —— 不确定时都往安全侧倒。
func (a *analysis) paramEscapeOfFunc(fb *parser.FuncBlock, idx int) bool {
	if fb == nil || idx < 0 || idx >= len(fb.Args) {
		return true // 认不出被调函数 / 序号越界 → 保守
	}
	if a.paramBusy[fb] { // 算 f 问 g、算 g 问 f：memo 还没写，不加守卫爆栈
		return true
	}
	a.paramBusy[fb] = true
	defer delete(a.paramBusy, fb)
	a.computeParamSummary(fb)
	esc := a.paramMemo[fb]
	if esc == nil || idx >= len(esc) {
		return true
	}
	return esc[idx]
}

// computeParamSummary 求 fb 调用闭包上的最小定点：
// 逃逸[f][i] ∨= ∃j: 传给 callee 且 callee 的第 j 号参数也逃逸。
func (a *analysis) computeParamSummary(fb *parser.FuncBlock) {
	if _, ok := a.paramMemo[fb]; ok {
		return
	}

	// 1. 收集闭包：fb 以及它能（间接）调用到的函数。显式栈，避免深递归。
	closure := map[*parser.FuncBlock]bool{}
	stack := []*parser.FuncBlock{fb}
	for len(stack) > 0 {
		f := stack[len(stack)-1]
		stack = stack[:len(stack)-1]
		if f == nil || closure[f] {
			continue
		}
		closure[f] = true
		a.scanFuncFacts(f)
		for _, cb := range callsIn(f) {
			if cb.Func != nil && !closure[cb.Func] {
				stack = append(stack, cb.Func)
			}
		}
	}

	// 2. 最小定点
	for changed := true; changed; {
		changed = false
		for f := range closure {
			esc := a.paramGround[f]
			if esc == nil {
				continue
			}
			for i := range esc {
				if esc[i] || f.Args[i] == nil {
					continue
				}
				if a.passedToEscaping(a.argState(f.Args[i])) {
					esc[i] = true
					changed = true
				}
			}
		}
	}

	for f := range closure {
		if e := a.paramGround[f]; e != nil {
			a.paramMemo[f] = e
		} else {
			a.paramMemo[f] = nil
		}
	}
}

// callsIn 函数体里出现的全部调用点（闭包收集用）。
func callsIn(f *parser.FuncBlock) []*parser.CallBlock {
	var out []*parser.CallBlock
	parser.EachSubNode(parser.BlockNode(f), func(n *parser.Node) {
		if cb, ok := n.Value.(*parser.CallBlock); ok && cb != nil {
			out = append(out, cb)
		}
	})
	return out
}

// scanFuncFacts 扫一个函数体：填各参数的地面事实（存全局 / 装箱 / 写字段），
// 记各参数被当实参传出过（out 边）。局部别名表解到不动点 ——
// 别名可能链式传递（a = p; b = a; g = b），单趟顺序扫会漏。
func (a *analysis) scanFuncFacts(f *parser.FuncBlock) {
	if f == nil || len(f.Args) == 0 {
		return
	}
	localOf := map[*parser.VarBlock]*parser.ArgBlock{} // 局部变量 → 它派生的那个参数

	// 一跳查表，不是递归：链式别名由下方 localOf 的不动点循环摊平后才进表。
	resolveParam := func(v *parser.VarBlock) *parser.ArgBlock {
		if v == nil {
			return nil
		}
		switch d := v.Define.Value.(type) {
		case *parser.ArgBlock:
			return d
		case *parser.VarBlock:
			return localOf[d] // 还没解析到就是 nil
		}
		return nil
	}

	type alias struct {
		src *parser.VarBlock
		dst *parser.VarBlock
	}
	var aliases []alias
	parser.EachSubNode(parser.BlockNode(f), func(n *parser.Node) {
		v, ok := n.Value.(*parser.VarBlock)
		if !ok || v == nil || v.Type == nil || !owningType(v.Type) ||
			v.IsGlobal || len(v.Name) != 1 {
			return
		}
		if src := bareVar(v.Value); src != nil {
			aliases = append(aliases, alias{src, v})
		}
	})
	for changed := true; changed; {
		changed = false
		for _, e := range aliases {
			if localOf[e.dst] != nil {
				continue
			}
			if p := resolveParam(e.src); p != nil {
				localOf[e.dst] = p
				changed = true
			}
		}
	}

	ground := make([]bool, len(f.Args))
	markGround := func(p *parser.ArgBlock) {
		if p == nil {
			return
		}
		for i, arg := range f.Args {
			if arg == p {
				ground[i] = true
			}
		}
	}
	paramOf := func(e *parser.Expression) *parser.ArgBlock { return resolveParam(bareVar(e)) }
	record := func(e *parser.Expression, idx int, cb *parser.CallBlock) {
		p := paramOf(e)
		if p == nil {
			return
		}
		// 与 collectArgs 记的是同一条事实：参数被当第 idx 实参传出。
		a.addParamOut(p, cb, idx)
	}

	parser.EachSubNode(parser.BlockNode(f), func(n *parser.Node) {
		switch t := n.Value.(type) {
		case *parser.VarBlock:
			if t.Value == nil || t.Type == nil || !owningType(t.Type) {
				return
			}
			p := paramOf(t.Value)
			if p == nil {
				return
			}
			switch {
			case t.IsGlobal:
				markGround(p) // 存进全局
			case len(t.Name) > 1 && fieldTypeOwning(t.Value.Type, t.Name.Last()):
				markGround(p) // 写字段：字段里存的指针可能活得比本帧久
			case !t.IsDefine && copiesFields(t.Type):
				markGround(p) // 装箱进接口 / 结构体值
			}
		case *parser.CallBlock:
			for i, ag := range t.Args {
				if ag != nil && ag.Value != nil {
					record(ag.Value, i, t)
				}
			}
			// 变参实参的形参序号按"排在全部定参之后"计，与 collectArgs 一致
			for _, ag := range t.VariadicArgs {
				if ag != nil && ag.Value != nil {
					record(ag.Value, len(t.Args), t)
				}
			}
		}
	})
	a.paramGround[f] = ground
}

// addParamOut 记一条传出边，按 (cb, i) 判重。
func (a *analysis) addParamOut(p *parser.ArgBlock, cb *parser.CallBlock, i int) {
	if p == nil {
		return
	}
	b := a.argState(p)
	for _, e := range b.out {
		if e.cb == cb && e.i == i {
			return
		}
	}
	b.out = append(b.out, paramOut{cb: cb, i: i})
}

// passedToEscaping 这个参数是否作为实参传出，且被调函数的对应参数也逃逸。
// 被调函数认不出来 → 当作逃逸，这是唯一需要保守的边。
func (a *analysis) passedToEscaping(b *binding) bool {
	if b == nil {
		return true
	}
	for _, e := range b.out {
		if e.cb == nil || e.cb.Func == nil {
			return true
		}
		if a.paramEscapeOfFunc(e.cb.Func, e.i) {
			return true
		}
	}
	return false
}
