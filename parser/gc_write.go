// parser/gc_write.go — Check 期：只收集事实
//
// 在写站点（赋值 / 字段写入 / 调用 / 返回）把事实收集起来，交给 gc_mark.go
// 的 applyMark 统一施加。本文件**只探测，不写状态**：
//
//	读类型 / 读作用域 / 查跨函数摘要 → []mark → applyMarks
//
// 收集到的四类事实：
//
//	Life.Obj      我指向哪个对象
//	Life.Scope    我这个绑定处在哪个作用域（声明时定，重绑不改）
//	Life.WroteTo  我作为右值被写进过哪些左值
//	Life.Escapes  我跑出本帧了吗
//
// 三条纪律：
//
//  1. 只写正向事实，不做撤销。"某对象当前被哪些名字指着"不在这里维护，
//     由 gc_names.go 一次反转得出。
//  2. 不推断。每条语句只回答"现在指向谁"。
//  3. 失败方向只有一边：拿不准就往"多标/不释放"偏，绝不往"提前释放"偏。
//
// 入口只有四个，分别挂在 VarBlock / CallBlock / ReturnBlock 的 Check 上：
//
//	var.go     markDefine / markAssign
//	call.go    markArgs
//	return.go  markRets
//
// 收集器与发出的事实一一对应：看 gc_mark.go 的 applyMark 就知道整套分析能记
// 哪些事实、每条由谁发出。

package parser

// curScope Check 期间指向当前所在的作用域节点（由 Node.Check 设置）。
var curScope Block

// markDefine 定义点。Check 每轮都会进来一次，先 Init 清空上一轮，再记本轮。
// 变量在这一句上决定归属：= new(T) 拥有新块；= y 与 y 同对象；无初始值则是空绑定。
func (l *Life) markDefine(v *VarBlock) {
	if v == nil {
		return
	}
	applyMark(mark{flag: mkInit, l: l, v: v})
	applyMarks(l.collectWrite(v))
}

// markAssign 赋值点。l 是**定义**的 Life —— 赋值改的是定义，不是这条语句本身。
//
// 字段写入（p.f = y）走单独一条路：字段语句块自身的 Type 是 "unknown"
// （字段类型没解析进语句块），过不了 owningType 闸门，只能靠 len(Name) > 1
// 认出来，然后按"往字段里写"处理而不是"往变量里写"。
func (l *Life) markAssign(v *VarBlock) {
	if v == nil {
		return
	}
	if !v.IsDefine && len(v.Name) > 1 {
		applyMarks(collectField(v))
		return
	}
	applyMarks(l.collectWrite(v))
}

// collectWrite 变量写站点（定义点与赋值点共用）的收集器。
//
// 整个 Check 期只有这里在决定"这个变量现在指向谁"。两步：
// writeFormOf（gc_pred.go）把形态算成 bitflag，这里按形态收成事实。
// 优先序只写在 writeFormOf 里，这里不重复判条件。
func (l *Life) collectWrite(v *VarBlock) []mark {
	var m []mark
	if v.IsDefine {
		// 作用域先记：它对任何变量都有意义，不能被形态闸门挡掉。
		// 曾因闸门提前返回导致"有 Obj 却没 Scope"，释放点塌缩回创建作用域 → 提前释放。
		m = append(m, mark{flag: mkScope, l: l})
	}
	form, src := writeFormOf(v)
	if form&wfCoverOld != 0 {
		m = append(m, mark{flag: mkOldObj, l: l, v: v})
	}
	switch form & formKind {
	case wfSkip:
		// int / bool / float：赋值与 GC 无关
	case wfGlobal:
		m = append(m, mark{flag: mkEscape, l: l}) // 全局不在任何栈帧内
		if src != nil {
			m = append(m, mark{flag: mkWroteTo, l: l, src: src})
		}
		return collectExpr(m, v.Value, true)
	case wfRC:
		m = append(m, mark{flag: mkObjNil, l: l}) // 生命周期由调用者手工 rcDec 管
	case wfFresh:
		m = append(m, mark{flag: mkObjClaim, l: l, v: v})
	case wfAlias:
		if form&wfCopies != 0 {
			// 容器复制：源的字段指针被带走，去向不可追
			return append(m, mark{flag: mkEscape, l: src})
		}
		m = append(m,
			mark{flag: mkObjAlias, l: l, src: src},
			mark{flag: mkWroteTo, l: l, src: src},
			mark{flag: mkFromParam, l: l, src: src})
	default: // wfBorrow
		m = append(m, mark{flag: mkObjNil, l: l}) // 字段读 / 索引 / 调用结果：借用
	}
	return m
}

// collectField 字段写入 p.f = v 的收集器：容器记下字段关系；
// 认不出容器时保守标记值逃逸。
func collectField(v *VarBlock) []mark {
	fname := v.Name.Last()
	base := fieldBaseOf(curScope, v)
	if base == nil {
		// 认不出基对象：值被存进未知容器，保守当作逃逸
		if l := bareRef(v.Value); l != nil && fieldTypeOwning(v.Value.Type, fname) {
			return []mark{{flag: mkEscape, l: l}}
		}
		return nil
	}
	if !fieldTypeOwning(base.Type, fname) {
		return nil
	}
	l := bareRef(v.Value)
	if l == nil {
		return nil
	}
	return []mark{{flag: mkFieldBind, v: base, name: fname, src: l}}
}

// fieldBaseOf 解析字段写入的基对象（p.f 中的 p）。字段语句块的 Define 指向
// StructField，拿不到基对象，只能在当前函数里按名字反查；遮蔽导致歧义时返回 nil。
func fieldBaseOf(scope Block, v *VarBlock) *VarBlock {
	root := v.Name.First()
	found, ambiguous := lookupInFunc(scope, root)
	if ambiguous {
		return nil
	}
	return found
}

// lookupInFunc 在当前函数体里按名字找定义。
//
// 字段语句块的 Define 指向 StructField，拿不到基对象，只能靠名字反查。
// 出现多个不同定义（遮蔽）时返回 ambiguous —— 调用方要按 nil 处理，
// 因为选错基对象会 free 错块。
// lookupInFunc 在当前函数体里按名字找定义；出现多个不同定义（遮蔽）时返回 ambiguous。
func lookupInFunc(scope Block, name string) (def *VarBlock, ambiguous bool) {
	fn := scope
	for fn != nil {
		if _, ok := fn.(*FuncBlock); ok {
			break
		}
		fn = outerParent(fn)
	}
	if fn == nil {
		return nil, false
	}
	var walk func(n *Node)
	walk = func(n *Node) {
		if n == nil {
			return
		}
		if vb, ok := n.Value.(*VarBlock); ok && vb.IsDefine && vb.Name != nil &&
			vb.Name.First() == name && def != vb {
			if def == nil {
				def = vb
			} else {
				ambiguous = true
			}
		}
		for _, ch := range n.Children {
			walk(ch)
		}
	}
	walk(BlockNode(fn))
	return def, ambiguous
}

// markArgs 调用点：实参是否升级逃逸，取决于**被调函数的参数摘要**。
// 摘要说"这个参数只读不存"，实参就还能按作用域释放 —— sortTest 里那 8 个
// RC 就是这里省下来的。
// markArgs 调用点。它不属于任何单个变量（操作的是整条调用的实参列表），
// 所以留在包级，不做 Life 的成员函数。
func markArgs(cb *CallBlock) {
	if cb == nil {
		return
	}
	applyMarks(collectArgs(cb))
}

// collectArgs 调用点的收集器。两条独立的事：
// 实参是否升级逃逸（问被调函数的参数摘要），以及参数链记一笔"我被传出过"。
func collectArgs(cb *CallBlock) []mark {
	var m []mark
	for i, ag := range cb.Args {
		// 缺参补的默认值（Defind != nil）不是调用方传进来的东西 ——
		// 它是函数声明里的那个表达式，在**被调方自己的帧**里求值。
		// 当成实参处理会让它被调用点的参数摘要误判逃逸
		// （`b: *Node = someGlobal` 这种默认值会被记成"调用方传了 someGlobal"）。
		if ag == nil || ag.Value == nil || ag.Defind != nil {
			continue
		}
		m = collectExpr(m, ag.Value, ArgEscapeOf(cb, i))
		// 参数 / 参数借用被当作第 i 个实参传出 → 记进参数链，供摘要判定
		if l := bareRef(ag.Value); l != nil {
			if p := l.arg; p != nil {
				m = append(m, mark{flag: mkParamOut, l: &p.Life, i: i, cb: cb})
			} else if p := l.fromParam; p != nil {
				m = append(m, mark{flag: mkParamOut, l: &p.Life, i: i, cb: cb})
			}
		}
	}
	for _, ag := range cb.VariadicArgs {
		if ag != nil && ag.Value != nil {
			m = collectExpr(m, ag.Value, ArgEscapeOf(cb, len(cb.Args)))
		}
	}
	if cb.ThisVar != nil && TreatMethodReceiverAsArg {
		m = collectExpr(m, &Expression{Var: cb.ThisVar}, true)
	}
	return m
}

// markRets 返回语句：判定每个返回值的所有权归属。
//
//	返回本地对象（不是参数）→ 所有权转移给调用者，callee 不再释放它
//	返回参数               → 调用者本来就有，不转移
//	但它已经被存到外部（全局 / 传给未知函数 / 装箱）→ 转移不了，仍是真逃逸
//
// markRets 返回语句。同上，操作的是函数的返回值列表，不属于某个变量。
func markRets(fb *FuncBlock, vals []*Expression) {
	if fb == nil || len(vals) == 0 {
		return
	}
	for i, e := range vals {
		// 返回值不是 owning 类型时，返回的东西不携带堆指针，
		// 表达式里引到的变量也不该跟着逃逸。
		// 反例：ret result.val 返回 int，result 本身并不返回出去。
		if i >= len(fb.Return) || !owningType(fb.Return[i]) {
			continue
		}
		applyMarks(collectRet(fb, e))
	}
}

// collectRet 一个返回值的所有权归属。三种可能：
//
//	裸引用参数        → 不转移。调用者本来就有这个对象，原样返回即可。
//	裸引用本地对象    → 转移。callee 不再释放，调用者接管。
//	                 但如果它已经以别的形式出去了（存过全局 / 装箱 / 传过
//	                 未知函数），就**转移不了** —— 现在有两个持有者，只能退回 RC。
//	不是裸引用        → 保守。当场 new 的可以转移；字段读 / 调用结果一律按
//	                   真逃逸处理，因为无法静态确定那是谁的块。
func collectRet(fb *FuncBlock, e *Expression) []mark {
	if e == nil {
		return nil
	}
	if l := bareRef(e); l != nil {
		if l.owner == nil || l.owner.IsGlobal {
			return nil // 参数 / 全局：调用者或全局本来就有，不转移
		}
		var m []mark
		if o := l.Obj; o != nil && !o.Escapes {
			m = append(m,
				mark{flag: mkTransferObj, l: l, o: o},
				mark{flag: mkFuncOwns, l: l, fb: fb})
		}
		return m
	}
	// 不是裸引用：可能是 new(...)、字段读、调用结果。
	// 只有"当场新建的"才是本帧所有、可以转移；其余一律按真逃逸处理。
	if e.Call != nil && e.Call.NewType != nil {
		m := []mark{{flag: mkFuncOwns, fb: fb}}
		if l := LifeOf(e.Call.ThisVar); l != nil {
			if o := l.Obj; o != nil && !o.Escapes {
				m = append(m, mark{flag: mkTransferObj, l: l, o: o})
			}
		}
		return m
	}
	return collectExpr(nil, e, true)
}

// collectExpr 把表达式里每个变量引用该记的事实收进 out。
//
// escapes 由**调用点**决定，不由表达式本身决定：
//
//	f(y)      实参位置 → 会不会逃逸问被调函数的参数摘要
//	ret y     返回位置 → 看这个值是不是本帧分配的
//	逃逸的值   其他情况 → 一定逃逸
//
// 遍历本身是控制流不是事实，所以留在收集侧（这里）；真正落进 out 的每一条
// 仍然是 mark，由 applyMark 施加。递归用同一个 out，不额外分配。
func collectExpr(out []mark, e *Expression, escapes bool) []mark {
	if e == nil {
		return out
	}
	if e.Var != nil && escapes {
		if l := LifeOf(e.Var); l != nil {
			out = append(out, mark{flag: mkEscape, l: l})
		}
	}
	if e.Call != nil {
		cb := e.Call
		for i, ag := range cb.Args {
			if ag != nil {
				out = collectExpr(out, ag.Value, ArgEscapeOf(cb, i))
			}
		}
		for _, ag := range cb.VariadicArgs {
			if ag != nil {
				out = collectExpr(out, ag.Value, ArgEscapeOf(cb, len(cb.Args)))
			}
		}
		if cb.ThisVar != nil && TreatMethodReceiverAsArg {
			out = collectExpr(out, &Expression{Var: cb.ThisVar}, true)
		}
	}
	out = collectExpr(out, e.Left, escapes)
	out = collectExpr(out, e.Right, escapes)
	for _, ix := range e.Index {
		out = collectExpr(out, ix, escapes)
	}
	for _, le := range e.ListElems {
		out = collectExpr(out, le, escapes)
	}
	return out
}

// ============================================================
// Check 期标记入口（写站点）
// ============================================================
