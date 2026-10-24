// parser/gc_write.go — Check 期收集器：只探测，不写任何状态
//
// 纪律：只写正向事实不撤销（"对象被哪些名字指着"由 gc_names.go 一次反转得出）；
// 不推断，每条语句只回答"现在指向谁"；失败方向只有一边 —— 拿不准就往
// 多标 / 不释放偏，绝不提前释放。
//
// 入口三个，挂在各语句块的 Check 上：markVar（var.go）、markArgs（call.go）、
// markRets（return.go）。每条事实翻成什么字段写，见 gc_mark.go 的 applyMark。

package parser

// curScope Check 期间指向当前所在的作用域节点（由 Node.Check 设置）。
var curScope Block

// markVar 变量写站点：var.go 的定义 / 赋值两个分支都挂它。
// l 是**定义**的 Life —— 定义与赋值改的都是定义那份账本，不是这条语句。
// 定义与赋值的差别只剩一件事：定义点多一条 Init（清空上一轮，alloc 除外），
// 在 collectVar 里按 v.IsDefine 发出。
func (l *Life) markVar(v *VarBlock) {
	if v == nil {
		return
	}

	// 字段操作
	if !v.IsDefine && len(v.Name) > 1 {
		applyMarks(collectField(v))
		return
	}

	// 普通赋值
	applyMarks(l.collectVar(v))
}

// collectVar 变量写站点（定义 / 赋值共用）：形态判定与事实收集同一条链，
// 优先序就是语义，只在这里写一次 ——
//
//  1. 非 owning 最高：连右值都不看（避开 bareRef 给参数打归调用方基线的副作用）
//  2. isRCExpr 先于 fresh：newRC 的 Call 同时带 NewType 和 IsRC，先判 fresh
//     会把 RC 块当新分配 claim，调用方再 rcDec 就是双重释放
//  3. 全局 / newRC 在记旧对象之前 return（记了会 free 全局的 / 手工管的块）
func (l *Life) collectVar(v *VarBlock) []mark {
	// fact 本站点恒定的 l / v / src 统一填，分派里只剩"产生哪几条事实"。
	fact := func(flag markFlag, src *Life) mark {
		return mark{flag: flag, l: l, v: v, src: src}
	}

	var m []mark
	if v.IsDefine { // Init 清空上一轮（alloc 保）再记作用域 —— 作用域不能被形态闸门挡掉，
		// 否则"有 Obj 却没 Scope"，释放点塌回创建作用域 → 提前释放（踩过的坑）。
		m = append(m, fact(mkInit, nil), fact(mkScope, nil))
	}
	if !owningType(v.Type) {
		return m // int / bool / float：赋值与 GC 无关
	}
	src := bareRef(v.Value) // 右值的归属；nil = 不是裸引用
	if v.IsGlobal {
		m = append(m, fact(mkEscape, nil)) // 全局不在任何栈帧内
		if src != nil {
			m = append(m, fact(mkWroteTo, src))
		}
		return collectExpr(m, v.Value, true)
	}
	if isRCExpr(v.Value) {
		return append(m, fact(mkObjNil, nil)) // 生命周期由调用者手工 rcDec 管
	}
	if !v.IsDefine {
		m = append(m, fact(mkOldObj, nil)) // 覆盖点先记旧对象（全局 / newRC 已提前返回）
	}
	switch {
	case freshAllocExpr(v.Value):
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
func collectField(v *VarBlock) []mark {
	fname := v.Name.Last()
	base := fieldBaseOf(v)
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

// fieldBaseOf 解析字段写入的基对象（p.f 中的 p）：容器实例在解析期 Find 时
// 已落进 v.Define 里（Value 是 StructField 类型端，Path[0] 才是容器本体），
// Find 最内层优先，解析完就是词法正确的那一个 —— Check 期直读，不再按名字反查。
// 参数容器（Path[0] 是 *ArgBlock）与全局容器：FieldVals 语义未设计，
// 一律走 collectField 的"值逃逸"保守兜底；解析失败同样 nil。
func fieldBaseOf(v *VarBlock) *VarBlock {
	if len(v.Define.Path) == 0 {
		return nil
	}
	if vb, ok := v.Define.Path[0].(*VarBlock); ok && !vb.IsGlobal {
		return vb
	}
	return nil
}

// markArgs 调用点。实参是否升级逃逸取决于被调函数的参数摘要 —— 摘要说
// "只读不存"，实参就还能按作用域释放（sortTest 里 8 个 RC 就是这里省的）。
// 操作的是整条实参列表，不属于单个变量，所以是包级函数。
func markArgs(cb *CallBlock) {
	if cb == nil {
		return
	}
	applyMarks(collectArgs(cb))
}

// collectArgs 调用点收集器：实参是否升级逃逸（问被调摘要），
// 以及参数链记一笔"我被传出过"。
func collectArgs(cb *CallBlock) []mark {
	var m []mark
	for i, ag := range cb.Args {
		// 缺参补的默认值（Defind != nil）在被调方自己的帧里求值，不是调用方
		// 传进来的东西 —— 当成实参会被调用点的参数摘要误判逃逸。
		if ag == nil || ag.Value == nil || ag.Defind != nil {
			continue
		}
		m = collectExpr(m, ag.Value, ArgEscapeOf(cb, i))
		// 参数 / 参数借用被当作第 i 个实参传出 → 记进参数链，供摘要判定
		if l := bareRef(ag.Value); l != nil {
			if p := l.paramRoot(); p != nil {
				m = append(m, mark{flag: mkParamOut, l: &p.Life, i: i, cb: cb})
			}
		}
	}
	for _, ag := range cb.VariadicArgs {
		if ag != nil && ag.Value != nil {
			m = collectExpr(m, ag.Value, ArgEscapeOf(cb, len(cb.Args)))
		}
	}
	if cb.ThisVar != nil {
		m = collectExpr(m, &Expression{Var: cb.ThisVar}, true)
	}
	return m
}

// markRets 返回语句。返回本地对象 → 所有权转移给调用者；返回参数 → 不转移
// （调用者本来就有）。操作的是整个返回值列表，所以是包级函数。
func markRets(fb *FuncBlock, vals []*Expression) {
	if fb == nil || len(vals) == 0 {
		return
	}
	for i, e := range vals {
		// 非 owning 返回值不带堆指针：ret result.val 返回 int，result 并没有返回出去。
		if i >= len(fb.Return) || !owningType(fb.Return[i]) {
			continue
		}
		applyMarks(collectRet(fb, e))
	}
}

// collectRet 一个返回值的所有权归属：
//
//	裸引用参数 / 全局  → 不转移，调用者本来就有
//	裸引用本地对象    → 转移；但已存全局 / 装箱 / 传过未知函数的转移不了
//	                   （两个持有者，只能退 RC）
//	new(T)            → 转移（当场新建是本帧所有）
//	字段读 / 调用结果 → 保守当真逃逸：无法确定那是谁的块
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
				mark{flag: mkTransferObj, o: o},
				mark{flag: mkFuncOwns, fb: fb})
		}
		return m
	}
	if e.Call != nil && e.Call.NewType != nil {
		m := []mark{{flag: mkFuncOwns, fb: fb}}
		if l := LifeOf(e.Call.ThisVar); l != nil {
			if o := l.Obj; o != nil && !o.Escapes {
				m = append(m, mark{flag: mkTransferObj, o: o})
			}
		}
		return m
	}
	return collectExpr(nil, e, true)
}

// collectExpr 把表达式里每个变量引用该记的事实收进 out。escapes 由调用点决定
// 不由表达式本身决定（实参问被调摘要 / 返回看是否本帧自有 / 逃逸值里全逃）。
// 递归共用 out，不额外分配。
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
		if cb.ThisVar != nil {
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
