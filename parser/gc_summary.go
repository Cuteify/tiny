// parser/gc_summary.go — 跨函数过程摘要：入参指针是否逃逸
//
// ============================================================
// 解决的问题
// ============================================================
//
// 调用点不必读被调函数体，只查这张表：
//
//	ArgEscapeOf(call, idx) == false  第 idx 个实参是"只读不存"的，
//	                                  调用方可以继续按作用域释放
//	                             true  被调方可能把它存到别处 → 退回 RC
//
// 不做这个摘要的代价：任何一个跨包函数调用都让实参判逃逸，
// sortTest 里 8 个 slices.new 的结果全退到 RC。
//
// ============================================================
// 判定规则（sound 的 may 分析）
// ============================================================
//
//	参数逃逸 ⟸ 存进全局
//	参数逃逸 ⟸ 装箱进接口或结构体值
//	参数逃逸 ⟸ 写进结构体字段
//	参数逃逸 ⟸ 作为第 j 个实参传出，且被调函数的第 j 号参数也逃逸
//	参数逃逸 ⟸ 被调函数认不出来（泛型未解析 / 不在合并树里）
//
// 不算逃逸：读取、只在本帧局部之间倒手、作为返回值传出
// （返回参数意味着所有权仍在调用方，见 gc_write.go 的 retValue）。
//
// ============================================================
// 为什么用最小定点，不是最大定点
// ============================================================
//
// may 分析的结论应当是"存在一条推导链能证明逃逸"：
//
//	逃逸[f][i] = 地面事实[i]  ∨  ∃j: 作为第 j 实参传给 callee 且 逃逸[callee][j]
//
// 最大定点（从全逃逸往回收缩）会把纯递归锁死：quickSortInts(s) 递归传自己，
// 那条边自己依赖自己，收缩不掉 → 整个函数判逃逸 → 摘要白做。
// 最小定点下，没有地面事实的递归环推不出逃逸，判不逃逸 —— 这是对的，
// 环里没有一条真的把指针存到了外面。
//
// ============================================================
// 为什么懒算，不全局预扫描
// ============================================================
//
// GetPackage 是递归的：依赖包的 Check 在外层建表**之前**就跑完了。
// 表是包级全局，预扫描的结果会被内层的 Check 读走（拿到空表 → 全判逃逸），
// 而 Escapes 单调递增，这个保守值会永久留下。懒算把顺序彻底解耦：
// 谁问谁算，只算那棵子树。
//
// ============================================================
// 递归
// ============================================================
//
// paramBusy 记录"正在算它自己"。f 的摘要要问 g，g 的又要问 f，不加这道
// 守卫会无限递归爆栈 —— memo 是算完才写的，中途重入看不到标记。
//
// 注意 scanFuncFacts 是**按被调方 AST 的现状**收集地面事实，不读 Check 期
// 记录的东西。这样就不依赖"被调方查完了吗"那个判断（Check 期间不可靠），
// 代价是多一个局部别名表的不动点（scopeOf 认不出 src 来自哪个参数时，
// 得靠别名表把 a = p; b = a; g = b 这种链条接上）。
//
//   0 行注释 ←───────────────────────────────────────────────────

package parser

// ============================================================
// 跨函数过程摘要：入参指针是否逃逸
// ============================================================
//
// §2.2 的三类摘要之一。调用点不必读被调函数体，只查这张表：
//
//	ArgEscapeOf(call, idx) == false  →  第 idx 号实参是"只读不存"的，
//	                                   调用方可以继续按作用域释放
//	                              true   →  被调方可能把它存到别处，退回保守
//
// 判定规则（sound 的 may 分析）：
//
//	参数逃逸 ⟸ 被存进全局 / 被装箱进接口或结构体值 / 被写进结构体字段
//	参数逃逸 ⟸ 作为第 j 个实参传出，且被调函数的第 j 号参数也逃逸
//	参数逃逸 ⟸ 被调函数认不出来（泛型未解析 / 不在合并树里）
//
// 用**最小定点**：may 分析的结论应当是"存在一条推导链能证明逃逸"。
// 最大定点（从全逃逸往回收缩）会把纯递归锁死 —— quickSortInts(s) 递归调用自己，
// 那条边自己依赖自己，收缩不掉 → 整个函数判逃逸 → 摘要白做。
// 最小定点下，没有地面事实（存全局 / 装箱 / 字段写入）的递归环推不出逃逸，
// 判不逃逸，这才是对的 —— 环里没有一条真的把指针存到了外面。
//
// 不算逃逸的情况：读取、作为返回值传出（返回参数意味着所有权仍在调用方，
// 见 markRets 的所有权转移）、只在本帧局部之间倒手。
//
// ── 为什么懒算而不是全局预扫描 ──
// GetPackage 是递归的：依赖包的 Check 在外层建表之前就跑完了。表是包级全局，
// 预扫描的结果会被内层的 Check 读走（拿到空表 → 全判逃逸），而 Escapes 单调
// 递增，这个保守值会永久留下。懒算把顺序彻底解耦：谁问谁算，只算那棵子树。

var (
	paramBusy   = map[*FuncBlock]bool{} // 正在计算中（防递归重入）
	paramMemo   map[*FuncBlock][]bool   // 算完的结果（定点收敛后）
	paramGround map[*FuncBlock][]bool   // 地面事实：存全局 / 装箱 / 写字段
)

// paramEscapeOfFunc 被调函数第 idx 号参数是否逃逸；认不出来返回 true。
// paramEscapeOfFunc 被调函数第 idx 号参数是否逃逸。
//
// 认不出来（泛型未解析 / 不在合并树 / 序号越界）一律 true —— 判逃逸 = 退回
// RC = 安全。这个偏好在多处出现，是有意的一致：不确定时都往安全侧倒。
//
// paramBusy 防的是求值过程中的重入：算 f 要问 g，算 g 要问 f，
// 此时两边的 memo 都还没写（写完才写），不加守卫会无限递归爆栈。
func paramEscapeOfFunc(fb *FuncBlock, idx int) bool {
	if fb == nil || idx < 0 || idx >= len(fb.Args) {
		return true // 认不出被调函数 / 序号越界 → 保守
	}
	// 正在算它自己（f 的摘要要问 g，g 的又要问 f）→ 递归，保守判逃逸。
	// 不加这道守卫会无限递归爆栈：memo 是算完才写的，中途重入看不到标记。
	if paramBusy[fb] {
		return true
	}
	paramBusy[fb] = true
	defer delete(paramBusy, fb)
	computeParamSummary(fb)
	esc := paramMemo[fb]
	if esc == nil || idx >= len(esc) {
		return true
	}
	return esc[idx]
}

// computeParamSummary 求以 fb 为根的调用图闭包上的最小定点。
// 结果写进 paramMemo，重复查询直接命中。
// computeParamSummary 求以 fb 为根的调用图闭包上的最小定点。
//
// 做法：
//  1. 收集闭包（fb + 它能调用到的所有函数，逐个扫 AST 收地面事实）
//  2. 在闭包上迭代到不动点：逃逸[f][i] ∨= ∃j: 传给 callee 且 callee 的 j 也逃逸
//  3. 结果写入 memo，重复查询直接命中
func computeParamSummary(fb *FuncBlock) {
	if paramMemo == nil {
		paramMemo = map[*FuncBlock][]bool{}
		paramGround = map[*FuncBlock][]bool{}
	}
	if _, ok := paramMemo[fb]; ok {
		return
	}

	// 1. 收集闭包：fb 以及它能（间接）调用到的函数。显式栈，避免深递归。
	closure := map[*FuncBlock]bool{}
	stack := []*FuncBlock{fb}
	for len(stack) > 0 {
		f := stack[len(stack)-1]
		stack = stack[:len(stack)-1]
		if f == nil || closure[f] {
			continue
		}
		closure[f] = true
		scanFuncFacts(f)
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
			esc := paramGround[f]
			if esc == nil {
				continue
			}
			for i := range esc {
				if esc[i] || f.Args[i] == nil {
					continue
				}
				if passedToEscaping(&f.Args[i].Life, i) {
					esc[i] = true
					changed = true
				}
			}
		}
	}

	for f := range closure {
		if e := paramGround[f]; e != nil {
			paramMemo[f] = e
		} else {
			// 没有参数表 → 任何实参都保守判逃逸
			paramMemo[f] = nil
		}
	}
}

// callsIn 函数体里出现的全部调用点。
// callsIn 函数体里出现的全部调用点。闭包收集和被调参数查询都要用。
func callsIn(f *FuncBlock) []*CallBlock {
	var out []*CallBlock
	eachSubNode(BlockNode(f), func(n *Node) {
		if cb, ok := n.Value.(*CallBlock); ok && cb != nil {
			out = append(out, cb)
		}
	})
	return out
}

// scanFuncFacts 扫一个函数体，填两样东西：
//  1. 该函数各参数的地面事实（存全局 / 装箱 / 写字段）
//  2. 各参数作为第 i 个实参传出过 → PassedTo / passedAt
//
// 局部别名表（var q: *T = p）要解到不动点：别名可能写在参数声明之前，
// 单趟会漏掉后半段 —— 漏一条别名 = 后面"存进全局"认不出来 = 漏判逃逸。
func scanFuncFacts(f *FuncBlock) {
	if f == nil || len(f.Args) == 0 {
		return
	}
	localOf := map[*VarBlock]*ArgBlock{} // 局部变量 → 它派生的那个参数

	var resolveParam func(v *VarBlock) *ArgBlock
	resolveParam = func(v *VarBlock) *ArgBlock {
		if v == nil {
			return nil
		}
		switch d := v.Define.Value.(type) {
		case *ArgBlock:
			return d
		case *VarBlock:
			return localOf[d] // 还没解析到就是 nil
		}
		return nil
	}

	// 别名边：q = p 形式。预扫描在 Check 之前，Life.owner 还没填，
	// 所以左右两边都用 VarBlock 解析（localOf 也是拿 VarBlock 当键）。
	type alias struct {
		src *VarBlock
		dst *VarBlock
	}
	var aliases []alias
	eachSubNode(BlockNode(f), func(n *Node) {
		v, ok := n.Value.(*VarBlock)
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
	mark := func(p *ArgBlock) {
		if p == nil {
			return
		}
		// ground[i] 必须无条件置位：OutEscape 可能已被 markEscapes 的
		// 参数链传播提前置上，而本次扫描看到的不是第一次。
		for i, a := range f.Args {
			if a == p {
				ground[i] = true
			}
		}
		p.Life.OutEscape = true
	}
	// 预扫描在 Check 之前跑，Life.owner 还没填，所以一律走 VarBlock 解析。
	paramOf := func(e *Expression) *ArgBlock { return resolveParam(bareVar(e)) }
	record := func(e *Expression, idx int, cb *CallBlock) {
		p := paramOf(e)
		if p == nil {
			return
		}
		p.Life.PassedTo = append(p.Life.PassedTo, idx)
		p.Life.passedAt = append(p.Life.passedAt, cb)
	}

	eachSubNode(BlockNode(f), func(n *Node) {
		switch t := n.Value.(type) {
		case *VarBlock:
			if t.Value == nil || t.Type == nil || !owningType(t.Type) {
				return
			}
			p := paramOf(t.Value)
			if p == nil {
				return
			}
			switch {
			case t.IsGlobal:
				mark(p) // 存进全局
			case len(t.Name) > 1 && fieldTypeOwning(t.Value.Type, t.Name.Last()):
				// b.inner = p：写结构体字段就算逃逸。基对象是本帧的还是要存的，
				// 这里分不出来，而字段里存的指针完全可能活得比本帧久
				// （基对象随后被存进全局或返回出去）。漏判就是提前释放，所以保守。
				mark(p)
			case !t.IsDefine && copiesFields(t.Type):
				mark(p) // 装箱进接口 / 结构体值
			}
		case *CallBlock:
			for i, ag := range t.Args {
				if ag != nil && ag.Value != nil {
					record(ag.Value, i, t)
				}
			}
			// 变参实参的形参序号按"排在全部定参之后"计，与 markArgs 一致
			for _, ag := range t.VariadicArgs {
				if ag != nil && ag.Value != nil {
					record(ag.Value, len(t.Args), t)
				}
			}
		}
	})
	paramGround[f] = ground
}

// passedToEscaping 这个参数是否作为实参传出，且被调函数的对应参数也逃逸。
// 被调函数认不出来（泛型未解析 / 不在合并树里）→ 当作逃逸，这是唯一需要保守的边。
func passedToEscaping(l *Life, idx int) bool {
	if l == nil {
		return true
	}
	for k, j := range l.PassedTo {
		if k >= len(l.passedAt) {
			return true
		}
		cb := l.passedAt[k]
		if cb == nil || cb.Func == nil {
			return true
		}
		if paramEscapeOfFunc(cb.Func, j) {
			return true
		}
	}
	return false
}
