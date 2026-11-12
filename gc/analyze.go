package gc

import (
	"sort"
	"strings"

	"cuteify/parser"
	"cuteify/type"
)

// analyzer 全程序摘要分析器。
// 输入为包合并、Check 重试完成之后的根 AST；
// 输出写入 Table（键 = 函数全路径名）。
type analyzer struct {
	fns   map[string]*parser.FuncBlock // 全路径名 → 定义块
	nodes map[string]*parser.Node      // 全路径名 → 函数体节点（Children 即语句）
	// 工作表：每函数“返回值携带拥有指针”与“体内有无 any 调用”的当前态，
	// 迭代至不动点后再落盘到 Table。
	retOwned map[string]bool
	retEsc   map[string]Escape
	anyCalls map[string][]string
	changed  bool
	// localCache 函数体 → 局部变量名 → 所有权来源。用于识别 `ret result`
	// 这类“返回局部变量”的拥有型返回值；按 body 指针缓存，不动点迭代内复用。
	localCache map[*parser.Node]map[string]*retOwnInfo
	// localBusy 递归保护：局部变量初始化表达式可能互相引用。
	localBusy map[*parser.Node]map[string]bool
	// calleeView 收紧阶段使用的被调摘要快照；nil 表示直接读 Table。
	calleeView map[string]*FnSummary
}

// analyzeBackend 遍历根 AST，构建全程序函数摘要（不动点迭代后写入 Table）。
// 必须在 package 合并与 rootNode.Check() 之后调用。
func analyzeBackend(root *parser.Node) {
	Table = map[string]*FnSummary{}
	LLRResults = map[string]*LLRResult{}
	a := &analyzer{
		fns:        map[string]*parser.FuncBlock{},
		nodes:      map[string]*parser.Node{},
		retOwned:   map[string]bool{},
		retEsc:     map[string]Escape{},
		anyCalls:   map[string][]string{},
		localCache: map[*parser.Node]map[string]*retOwnInfo{},
		localBusy:  map[*parser.Node]map[string]bool{},
	}
	a.collectFuncs(root)

	// 初始化每函数摘要骨架
	for key, fb := range a.fns {
		fs := &FnSummary{Name: key}
		for i, ag := range fb.Args {
			if owningType(ag.Type) {
				ps := fs.EnsureParam(i)
				ps.Index = i
				ps.Mode = ModeRead
				ps.Escape = EscNone
			}
		}
		if len(fb.Return) > 0 && owningType(fb.Return[0]) {
			fs.RetOwned = true
			fs.RetEscape = EscCaller
			// 拥有型返回值先按 Unknown 处理；analyzeBody 在不动点迭代中
			// 根据实际 return 表达式收紧为 Fresh/Alias/Borrow。
			fs.RetKind = RetUnknown
		}
		Table[key] = fs
		a.retOwned[key] = fs.RetOwned
		a.retEsc[key] = fs.RetEscape
		a.anyCalls[key] = nil
	}

	// 不动点迭代：参数逃逸沿调用边反向传播
	for {
		a.changed = false
		a.localCache = map[*parser.Node]map[string]*retOwnInfo{}
		a.localBusy = map[*parser.Node]map[string]bool{}
		for key, fb := range a.fns {
			a.analyzeBody(key, fb, a.nodes[key])
		}
		if !a.changed {
			break
		}
	}
	// 上面的迭代只做单调提升；函数返回值摘要从 Unknown 收紧为 Fresh 后，
	// 早期按 Unknown 误提升的参数不会自动回落。这里用“快照 + 重置重算”
	// 的 Jacobi 迭代把参数摘要收紧到真正的不动点。
	a.tightenParams()

	// LLR 分析：基于对象绑定的精确生命周期
	markFieldAliasStructs(a.fns, a.nodes)
	LLRResults = map[string]*LLRResult{}
	for fnKey, fb := range a.fns {
		fs := Table[fnKey]
		if fs == nil {
			continue
		}
		body := a.nodes[fnKey]
		res := ComputeLLR(fnKey, fb, fs, body)
		LLRResults[fnKey] = res
	}

	// 落盘
	keys := make([]string, 0, len(Table))
	for k := range Table {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	for _, k := range keys {
		fs := Table[k]
		fs.RetEscape = a.retEsc[k]
		sort.Slice(fs.Params, func(i, j int) bool { return fs.Params[i].Index < fs.Params[j].Index })
	}
}

// calleeSummary 返回被调函数摘要。收紧阶段优先使用快照，避免“重置当前
// 参数 → 调用方读到零值”导致的欠近似。
func (a *analyzer) calleeSummary(key string) *FnSummary {
	if a.calleeView != nil {
		if fs := a.calleeView[key]; fs != nil {
			return fs
		}
	}
	return Table[key]
}

// tightenParams 以“快照 + 重置重算”的 Jacobi 方式重算参数摘要。
// 原不动点只做单调提升；RetKind 从 Unknown 收紧为 Fresh 后，早期误提升的
// 参数需要回落。每轮用上一轮摘要作为被调视图，当前摘要从初始态重算，
// 因此参数值只会逐轮下降，最终收敛。
func (a *analyzer) tightenParams() {
	for round := 0; round < 32; round++ {
		prev := make(map[string]*FnSummary, len(Table))
		for k, fs := range Table {
			cp := *fs
			cp.Params = append([]ParamSummary(nil), fs.Params...)
			prev[k] = &cp
		}
		for _, fs := range Table {
			for i := range fs.Params {
				fs.Params[i].Escape = EscNone
				fs.Params[i].Mode = ModeRead
			}
		}
		a.localCache = map[*parser.Node]map[string]*retOwnInfo{}
		a.localBusy = map[*parser.Node]map[string]bool{}
		a.calleeView = prev
		for key, fb := range a.fns {
			a.analyzeBody(key, fb, a.nodes[key])
		}
		a.calleeView = nil
		if paramsEqual(Table, prev) {
			return
		}
	}
}

// paramsEqual 比较当前摘要与快照的参数集合是否一致。
func paramsEqual(cur, prev map[string]*FnSummary) bool {
	for k, cf := range cur {
		pf := prev[k]
		if pf == nil || len(cf.Params) != len(pf.Params) {
			return false
		}
		for i := range cf.Params {
			if cf.Params[i] != pf.Params[i] {
				return false
			}
		}
	}
	return true
}

// collectFuncs 递归收集全树 FuncBlock。
func (a *analyzer) collectFuncs(n *parser.Node) {
	if n == nil {
		return
	}
	if fb, ok := n.Value.(*parser.FuncBlock); ok && fb.Name != nil {
		key := fb.Name.String()
		if _, dup := a.fns[key]; !dup {
			a.fns[key] = fb
			a.nodes[key] = n
		}
	}
	for _, ch := range n.Children {
		a.collectFuncs(ch)
	}
}

// analyzeBody 流不敏感扫描单个函数体，更新其摘要；有变化置 changed。
func (a *analyzer) analyzeBody(key string, fb *parser.FuncBlock, body *parser.Node) {
	fs := Table[key]
	if fs == nil {
		return
	}
	// scanExpr 统一处理表达式位置：传播堆分配标志与被调参数逃逸。
	// 条件/增量/初始化/右值等位置都不是 AST 子节点，必须显式扫描，
	// 否则条件里的 owning 调用既不会让 HasHeapAllocs 变真，也不会传播逃逸。
	scanExpr := func(e *parser.Expression) {
		if e == nil {
			return
		}
		if !fs.HasHeapAllocs && exprAllocates(e) {
			fs.HasHeapAllocs = true
			a.changed = true
		}
		walkExprCalls(e, func(cb *parser.CallBlock) { a.applyCallee(key, fs, cb, fb, body) })
	}

	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if body != nil && n == nil {
			return
		}
		if n == nil {
			return
		}
		switch v := n.Value.(type) {
		case *parser.ReturnBlock:
			// 仅当返回类型本身是拥有指针时，返回表达式引用参数才算逃逸
			// （如 print 返回 i32 只是消费参数，不构成逃逸）
			retOwns := len(fb.Return) > 0 && owningType(fb.Return[0])
			for _, rv := range v.Value {
				if rv == nil {
					continue
				}
				if retOwns {
					o := a.exprOwnership(rv, fb, body)
					if o.unknown {
						// 无法证明来源：保守地把表达式引用的拥有参数都当作
						// 可能别名返回，避免调用方误释放仍被返回的对象。
						for _, pi := range refsTrackedParams(rv, fb) {
							a.bumpParam(fs, pi, EscCaller, ModeOtherRef)
						}
						a.bumpRet(key, EscCaller)
					} else {
						// 只提升真正可能被返回/借用的参数；Fresh 路径不提升。
						for _, pi := range maskIndices(o.alias | o.borrow) {
							a.bumpParam(fs, pi, EscCaller, ModeOtherRef)
						}
						if o.alias != 0 || o.borrow != 0 {
							a.bumpRet(key, EscCaller)
						}
					}
				}
				// 传播 HasHeapAllocs：ret 调用了有堆分配的函数
				if !fs.HasHeapAllocs && exprAllocates(rv) {
					fs.HasHeapAllocs = true
					a.changed = true
				}
				// 返回表达式里的嵌套调用也要传播逃逸
				walkExprCalls(rv, func(cb *parser.CallBlock) { a.applyCallee(key, fs, cb, fb, body) })
			}
		case *parser.VarBlock:
			// 赋值语句（IsDefine=false）：目标是全局 且 右值为拥有值
			// （引用参数 / 调用 RetOwned 函数 / 字符串拼接）→ EscGlobal
			// + 标记函数含全局拥有存储（保守门槛）
			if !v.IsDefine && v.IsGlobal && v.Value != nil {
				o := a.exprOwnership(v.Value, fb, body)
				if o.unknown {
					for _, pi := range refsTrackedParams(v.Value, fb) {
						a.bumpParam(fs, pi, EscGlobal, ModeOtherRef)
					}
				} else {
					for _, pi := range maskIndices(o.alias | o.borrow) {
						a.bumpParam(fs, pi, EscGlobal, ModeOtherRef)
					}
				}
				// 全局赋值右值是拥有类型（新分配或参数别名）时，函数体内存在
				// 全局拥有存储；本函数禁用自动释放优化。不要把这个函数级标志
				// 传播给调用方——调用方仍按 ParamEscapes 的逐参数摘要处理。
				if v.Value.Type != nil && owningType(v.Value.Type) && !fs.HasGlobalOwnStore {
					fs.HasGlobalOwnStore = true
					a.changed = true
				}
			}
			// 字段写入 p.f = v：v 被存进堆对象的字段，按 EscHeapObj 逃逸
			// （反方向不成立：写字段只改容器内容，容器参数本身不逃逸）。
			// 漏掉这条会让 astAdd(p, c) 这类“把节点挂进别人字段”的帮助函数
			// 摘要全是 EscNone，调用方随后就把已挂树的节点释放掉。
			if !v.IsDefine && len(v.Name) > 1 && v.Value != nil {
				if v.Value.Type == nil || owningType(v.Value.Type) {
					for _, pi := range refsTrackedParams(v.Value, fb) {
						a.bumpParam(fs, pi, EscHeapObj, ModeOtherRef)
					}
				}
			}
			scanExpr(v.Value)
		case *parser.CallBlock:
			if v.IsBuiltinNewAlloc() && !fs.HasHeapAllocs {
				fs.HasHeapAllocs = true
				a.changed = true
			}
			a.applyCallee(key, fs, v, fb, body)
		case *parser.Expression:
			// 独立表达式语句（调用、赋值）里的分配与调用逃逸。
			// 元素/解引用写入 s[i] = v、*p = v 同样把拥有值存进堆容器，
			// 右值中引用的参数按 EscHeapObj 逃逸。
			if v.Var == nil && (v.Separator == "[]=" || v.Separator == "=") && v.Right != nil {
				if v.Right.Type == nil || owningType(v.Right.Type) {
					for _, pi := range refsTrackedParams(v.Right, fb) {
						a.bumpParam(fs, pi, EscHeapObj, ModeOtherRef)
					}
				}
			}
			scanExpr(v)
		case *parser.IfBlock:
			scanExpr(v.Condition)
			// ElseBlock 不在 Children 里，显式下钻；then 体仍由通用
			// Children 循环处理。
			if v.ElseBlock != nil {
				walk(v.ElseBlock)
			}
		case *parser.ForBlock:
			scanExpr(v.Init)
			scanExpr(v.Condition)
			scanExpr(v.Increment)
			scanExpr(v.Range)
		}
		for _, ch := range n.Children {
			walk(ch)
		}
	}
	if body != nil {
		walk(body)
	}
	a.updateRetSummary(fs, fb, body)
}

// retOwnInfo 单个 return 表达式的所有权来源。
type retOwnInfo struct {
	fresh   bool
	alias   uint64
	borrow  uint64
	unknown bool
}

// updateRetSummary 重新计算函数返回值摘要（不动点迭代内调用）。
func (a *analyzer) updateRetSummary(fs *FnSummary, fb *parser.FuncBlock, body *parser.Node) {
	if fs == nil || fb == nil || len(fb.Return) == 0 || !owningType(fb.Return[0]) {
		if fs != nil {
			fs.RetKind = RetNone
			fs.RetAliasMask = 0
			fs.RetBorrowMask = 0
		}
		return
	}
	seenFresh := false
	seenAlias := false
	seenBorrow := false
	unknown := false
	var aliasMask, borrowMask uint64
	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if n == nil || unknown {
			return
		}
		if rb, ok := n.Value.(*parser.ReturnBlock); ok {
			for _, rv := range rb.Value {
				if rv == nil {
					continue
				}
				o := a.exprOwnership(rv, fb, body)
				if o.unknown {
					unknown = true
					return
				}
				if o.fresh {
					seenFresh = true
				}
				if o.alias != 0 {
					seenAlias = true
					aliasMask |= o.alias
				}
				if o.borrow != 0 {
					seenBorrow = true
					borrowMask |= o.borrow
				}
				if !o.fresh && o.alias == 0 && o.borrow == 0 {
					// 拥有型返回但来源既非新分配也非已知别名：保守视为未知。
					unknown = true
					return
				}
			}
		}
		for _, ch := range n.Children {
			walk(ch)
		}
		// ElseBlock 不在 Children 列表里，返回摘要也要覆盖 else 分支。
		if ib, ok := n.Value.(*parser.IfBlock); ok && ib != nil && ib.ElseBlock != nil {
			walk(ib.ElseBlock)
		}
	}
	walk(body)
	kind := RetUnknown
	switch {
	case unknown:
		kind = RetUnknown
	case seenFresh:
		kind = RetFresh
	case seenAlias:
		kind = RetAliasParam
	case seenBorrow:
		kind = RetBorrowParam
	}
	if fs.RetKind != kind || fs.RetAliasMask != aliasMask || fs.RetBorrowMask != borrowMask {
		fs.RetKind = kind
		fs.RetAliasMask = aliasMask
		fs.RetBorrowMask = borrowMask
		a.changed = true
	}
}

// exprOwnership 判断表达式作为拥有型返回值时的来源。
// 只关心“是否新分配/是否可能复用参数对象”，不追踪具体堆对象。
// body 用于识别 `ret result` 这类返回函数内局部变量的情况。
func (a *analyzer) exprOwnership(e *parser.Expression, fb *parser.FuncBlock, body *parser.Node) retOwnInfo {
	var out retOwnInfo
	if e == nil {
		return out
	}
	merge := func(o retOwnInfo) {
		out.fresh = out.fresh || o.fresh
		out.alias |= o.alias
		out.borrow |= o.borrow
		out.unknown = out.unknown || o.unknown
	}
	if e.Var != nil && e.Var.Name != nil && len(e.Var.Name) > 0 {
		root := e.Var.Name.First()
		if idx, ok := paramIndexByName(fb, root); ok {
			if len(e.Var.Name) == 1 {
				out.alias |= 1 << uint(idx)
			} else {
				// p.field / p[i]：返回值借用参数对象内部，不拥有参数本身。
				out.borrow |= 1 << uint(idx)
			}
			return out
		}
		if len(e.Var.Name) == 1 {
			if lo, ok := a.localOwnership(root, fb, body); ok {
				return lo
			}
		}
		// 非参数、非函数内局部变量（全局/外层作用域），或返回局部变量的
		// 字段/元素：无法证明所有权来源，保守视为未知。
		out.unknown = true
		return out
	}
	if e.Call != nil {
		cb := e.Call
		if cb.IsBuiltinNewAlloc() {
			out.fresh = true
		} else if cb.Func != nil {
			key := callKey(cb)
			cs := a.calleeSummary(key)
			if cs == nil {
				if len(cb.Func.Return) > 0 && owningType(cb.Func.Return[0]) {
					out.unknown = true
				}
			} else {
				switch cs.RetKind {
				case RetFresh:
					out.fresh = true
				case RetAliasParam:
					out.alias = a.mapMaskThroughArgs(cs.RetAliasMask, cb, fb, body)
				case RetBorrowParam:
					out.borrow = a.mapMaskThroughArgs(cs.RetBorrowMask, cb, fb, body)
				case RetUnknown:
					out.unknown = true
				}
				// 混合路径（Fresh + alias/borrow）仍传播别名位。
				out.alias |= a.mapMaskThroughArgs(cs.RetAliasMask, cb, fb, body)
				out.borrow |= a.mapMaskThroughArgs(cs.RetBorrowMask, cb, fb, body)
			}
		}
		// 嵌套实参里的分配不影响“返回值来源”；但实参中的未知调用可能
		// 已经保存了参数，这由 applyCallee 单独处理。
		return out
	}
	if e.IsConst() && typeSys.CheckKind(e.Type, "string") {
		// 空字符串常量在代码生成中是 ptr=0/len=0/cap=0，调用方 free(nil)
		// 安全，可视为 fresh；非空字符串常量指向静态标签，绝不能 free。
		if e.StringVal == "" {
			out.fresh = true
		} else {
			out.unknown = true
		}
		return out
	}
	if e.ConstNil {
		// nil 指针：调用方 free(nil) 安全。
		out.fresh = true
		return out
	}
	if e.Separator == "+" && e.Type != nil && typeSys.CheckKind(e.Type, "string") {
		// 字符串拼接总是产生新缓冲，不借用操作数。
		out.fresh = true
		return out
	}
	// 其它复合表达式：保守合并子表达式来源。
	merge(a.exprOwnership(e.Left, fb, body))
	merge(a.exprOwnership(e.Right, fb, body))
	for _, ix := range e.Index {
		if ix != nil {
			merge(a.exprOwnership(ix.Left, fb, body))
			merge(a.exprOwnership(ix.Right, fb, body))
		}
	}
	return out
}

// localOwnership 判断 name 是否为函数体内的拥有型局部变量，并返回其
// 所有权来源。只有函数体内存在该变量的声明时才返回 ok=true。
// 扫描所有初始化/直接赋值：任一赋值来自参数或未知来源，mask/unknown
// 会保留下来，调用方因此不会自动释放返回值。
func (a *analyzer) localOwnership(name string, fb *parser.FuncBlock, body *parser.Node) (retOwnInfo, bool) {
	if body == nil || name == "" || fb == nil {
		return retOwnInfo{}, false
	}
	// 对局部变量取地址后，函数可能通过指针写入参数/静态缓冲（如
	// strings.makeString 的 `var result; &result; *_p = ptr`）。此时
	// “零值初始化”不能证明返回值归调用方所有，必须保守判为未知，
	// 否则调用方会 free 掉底层缓冲区。
	if bodyTakesAddrOfNode(body, name) {
		return retOwnInfo{unknown: true}, true
	}
	if a.localCache == nil {
		a.localCache = map[*parser.Node]map[string]*retOwnInfo{}
	}
	if a.localBusy == nil {
		a.localBusy = map[*parser.Node]map[string]bool{}
	}
	cache := a.localCache[body]
	if cache == nil {
		cache = map[string]*retOwnInfo{}
		a.localCache[body] = cache
	}
	if o, ok := cache[name]; ok {
		if o == nil {
			return retOwnInfo{}, false
		}
		return *o, true
	}
	busy := a.localBusy[body]
	if busy == nil {
		busy = map[string]bool{}
		a.localBusy[body] = busy
	}
	if busy[name] {
		// 初始化表达式自引用（如 x = x）：来源无法证明。
		return retOwnInfo{unknown: true}, true
	}
	busy[name] = true
	defer delete(busy, name)

	var out retOwnInfo
	found := false
	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if n == nil {
			return
		}
		if _, isFn := n.Value.(*parser.FuncBlock); isFn {
			return // 不跨越嵌套函数边界
		}
		if vb, ok := n.Value.(*parser.VarBlock); ok && !vb.IsGlobal && vb.Name != nil &&
			len(vb.Name) == 1 && vb.Name.First() == name {
			owning := owningType(vb.Type) || (vb.Value != nil && owningType(vb.Value.Type))
			if owning {
				found = true
				if vb.Value != nil {
					o := a.exprOwnership(vb.Value, fb, body)
					out.fresh = out.fresh || o.fresh
					out.alias |= o.alias
					out.borrow |= o.borrow
					out.unknown = out.unknown || o.unknown
				} else if vb.IsDefine {
					// 无初始化的拥有型局部变量：零值容器/空指针，
					// 返回后调用方 free(nil) 安全。
					out.fresh = true
				}
			}
		}
		for _, ch := range n.Children {
			walk(ch)
		}
		if ib, ok := n.Value.(*parser.IfBlock); ok && ib != nil && ib.ElseBlock != nil {
			walk(ib.ElseBlock)
		}
	}
	if body.Value != nil {
		if _, isRootFn := body.Value.(*parser.FuncBlock); isRootFn {
			// body 本身是 FuncBlock 节点；walk 会在函数边界提前返回，
			// 因此显式从函数体语句开始扫描。
			for _, ch := range body.Children {
				walk(ch)
			}
		} else {
			walk(body)
		}
	} else {
		walk(body)
	}
	if !found {
		cache[name] = nil
		return retOwnInfo{}, false
	}
	cache[name] = &out
	return out, true
}

// mapMaskThroughArgs 把被调返回值的参数位掩码映射到调用方实参的参数位。
// 实参本身是 fresh 时不会产生调用方参数别名。
func (a *analyzer) mapMaskThroughArgs(mask uint64, cb *parser.CallBlock, fb *parser.FuncBlock, body *parser.Node) uint64 {
	if mask == 0 || cb == nil {
		return 0
	}
	var out uint64
	for _, idx := range maskIndices(mask) {
		if idx >= len(cb.Args) || cb.Args[idx] == nil {
			continue
		}
		o := a.exprOwnership(cb.Args[idx].Value, fb, body)
		out |= o.alias | o.borrow
		if o.unknown {
			// 实参来源未知：映射到该实参中出现的所有拥有参数。
			for _, pi := range refsTrackedParams(cb.Args[idx].Value, fb) {
				out |= 1 << uint(pi)
			}
		}
	}
	return out
}

// maskIndices 展开位掩码中的参数下标（最多 64 个）。
func maskIndices(mask uint64) []int {
	var out []int
	for i := 0; i < 64; i++ {
		if mask&(1<<uint(i)) != 0 {
			out = append(out, i)
		}
	}
	return out
}

// paramIndexByName 查找函数拥有型参数的下标。
func paramIndexByName(fb *parser.FuncBlock, name string) (int, bool) {
	if fb == nil {
		return 0, false
	}
	for i, ag := range fb.Args {
		if ag != nil && owningType(ag.Type) && ag.Name != nil && ag.Name.First() == name {
			return i, true
		}
	}
	return 0, false
}

// applyCallee 把被调摘要的效果施加到实参表达式引用的 tracked 名字上。
func (a *analyzer) applyCallee(key string, fs *FnSummary, cb *parser.CallBlock, fb *parser.FuncBlock, body *parser.Node) {
	if cb == nil || cb.Func == nil {
		return
	}
	calleeKey := callKey(cb)
	callee := a.calleeSummary(calleeKey)

	// 无摘要被调：实参退化 any（v1 仅记录）
	if callee == nil {
		name := callKey(cb)
		if _, pure := pureBuiltinEscapes(name); pure {
			return
		}
		fs.CallsAny = appendUnique(fs.CallsAny, name)
		if !strSliceEq(a.anyCalls[key], fs.CallsAny) {
			a.anyCalls[key] = fs.CallsAny
			a.changed = true
		}
		return
	}
	for _, ps := range callee.Params {
		idx := ps.Index
		if idx >= len(cb.Args) {
			continue
		}
		arg := cb.Args[idx]
		if arg == nil || arg.Value == nil {
			continue
		}
		if ps.Escape <= EscNone {
			continue
		}
		o := a.exprOwnership(arg.Value, fb, body)
		if o.unknown {
			// 实参来源未知：该实参中出现的拥有参数都可能被 callee 保存。
			for _, pi := range refsTrackedParams(arg.Value, fb) {
				a.bumpParam(fs, pi, ps.Escape, ps.Mode)
			}
			continue
		}
		// 只有“实参本身是参数别名/参数内部借用”才会把 callee 的逃逸
		// 传播回调用方参数；新分配的临时对象不牵连任何参数。
		for _, pi := range maskIndices(o.alias | o.borrow) {
			a.bumpParam(fs, pi, ps.Escape, ps.Mode)
		}
	}
	// 传播 HasHeapAllocs：被调函数有堆分配 → 调用者也有
	if callee.HasHeapAllocs && !fs.HasHeapAllocs {
		fs.HasHeapAllocs = true
		a.changed = true
	}
	// 实参里若出现嵌套复杂表达式调用（右值含其它调用），递归扫描其内部调用点
	for _, ag := range cb.Args {
		if ag != nil && ag.Value != nil {
			walkExprCalls(ag.Value, func(cb2 *parser.CallBlock) { a.applyCallee(key, fs, cb2, fb, body) })
		}
	}
}

// bumpRet 提升函数返回逃逸层级。
func (a *analyzer) bumpRet(key string, e Escape) {
	if a.retEsc[key] < e {
		a.retEsc[key] = e
		a.changed = true
	}
}

// bumpParam 只提升指定参数的模式与逃逸。
func (a *analyzer) bumpParam(fs *FnSummary, idx int, e Escape, m Mode) {
	if fs == nil || idx < 0 {
		return
	}
	ps := fs.EnsureParam(idx)
	if ps.Index != idx {
		return
	}
	ch := false
	if ps.Escape < e {
		ps.Escape = e
		ch = true
	}
	nm := ps.Mode.Merge(m)
	if nm != ps.Mode {
		ps.Mode = nm
		ch = true
	}
	if ch {
		a.changed = true
	}
}

// refsTrackedParams 返回表达式中命中的拥有指针参数下标（去重、升序）。
// v1 简化：只看根名字（字段访问 p.f 取首段），不做字段级敏感。
func refsTrackedParams(e *parser.Expression, fb *parser.FuncBlock) []int {
	if e == nil || fb == nil {
		return nil
	}
	seen := map[int]bool{}
	var rec func(x *parser.Expression)
	rec = func(x *parser.Expression) {
		if x == nil {
			return
		}
		if x.Var != nil && x.Var.Name != nil {
			root := x.Var.Name.First()
			if idx, ok := paramIndexByName(fb, root); ok {
				seen[idx] = true
			}
		}
		rec(x.Left)
		rec(x.Right)
		for _, ix := range x.Index {
			if ix != nil {
				rec(ix.Left)
				rec(ix.Right)
			}
		}
		if x.Call != nil {
			for _, ag := range x.Call.Args {
				if ag != nil {
					rec(ag.Value)
				}
			}
		}
	}
	rec(e)
	if len(seen) == 0 {
		return nil
	}
	out := make([]int, 0, len(seen))
	for i := range seen {
		out = append(out, i)
	}
	sort.Ints(out)
	return out
}

// walkExprCalls 遍历表达式子树中的全部 CallBlock（含嵌套）。
func walkExprCalls(e *parser.Expression, fn func(*parser.CallBlock)) {
	if e == nil {
		return
	}
	if e.Call != nil {
		fn(e.Call)
		for _, ag := range e.Call.Args {
			if ag != nil {
				walkExprCalls(ag.Value, fn)
			}
		}
		for _, ag := range e.Call.VariadicArgs {
			if ag != nil {
				walkExprCalls(ag.Value, fn)
			}
		}
	}
	walkExprCalls(e.Left, fn)
	walkExprCalls(e.Right, fn)
	for _, ix := range e.Index {
		if ix != nil {
			walkExprCalls(ix.Left, fn)
			walkExprCalls(ix.Right, fn)
		}
	}
	for _, el := range e.ListElems {
		walkExprCalls(el, fn)
	}
}

// appendUnique 去重追加。
func appendUnique(xs []string, v string) []string {
	for _, x := range xs {
		if x == v {
			return xs
		}
	}
	return append(xs, v)
}

// strSliceEq 无序比较两个字符串切片内容是否一致。
func strSliceEq(a, b []string) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}

// exprAllocates 判断表达式是否产生新分配的拥有指针：
// 调用 RetOwned 函数、new/make（NewType 非空）、字符串拼接（"+" 且 string 类型）。
func exprAllocates(e *parser.Expression) bool {
	if e == nil {
		return false
	}
	if e.Call != nil {
		if e.Call.IsBuiltinNewAlloc() {
			return true
		}
		// 用摘要键解析悬空调用（跨文件/跨包调用在 gc.Analyze 时 Func 可能尚未绑定）
		// 只有 RetFresh 才表示返回值归调用方所有；RetUnknown（如
		// strings.makeString 通过指针写入局部容器）绝不能当作本帧分配，
		// 否则调用方会释放参数/静态缓冲区。
		if fs := callSummary(e.Call); fs != nil && fs.RetOwned && fs.RetKind == RetFresh {
			return true
		}
		for _, ag := range e.Call.Args {
			if ag != nil && exprAllocates(ag.Value) {
				return true
			}
		}
	}
	if e.Separator == "+" && e.Type != nil && typeSys.CheckKind(e.Type, "string") {
		return true
	}
	if exprAllocates(e.Left) || exprAllocates(e.Right) {
		return true
	}
	for _, ix := range e.Index {
		if ix != nil && (exprAllocates(ix.Left) || exprAllocates(ix.Right)) {
			return true
		}
	}
	for _, el := range e.ListElems {
		if exprAllocates(el) {
			return true
		}
	}
	if e.Call != nil {
		for _, ag := range e.Call.VariadicArgs {
			if ag != nil && exprAllocates(ag.Value) {
				return true
			}
		}
	}
	return false
}

// ParamEscapes 查询被调函数第 idx 个参数的逃逸层级。
// 无摘要的被调一律返回 EscAny（保守）。
func ParamEscapes(calleeKey string, idx int) Escape {
	fs := Table[calleeKey]
	if fs == nil {
		// 纯内建只读取实参，不保存/返回其地址。没有这条摘要时
		// `ret len(t)` 会把 t 标成 EscAny，导致帧内对象永不释放。
		if pure, ok := pureBuiltinEscapes(calleeKey); ok {
			return pure
		}
		return EscAny
	}
	for _, p := range fs.Params {
		if p.Index == idx {
			return p.Escape
		}
	}
	return EscNone
}

// callKey 返回调用点的摘要键。编译器内建（len/cap/new 等）的 FuncBlock
// 没有名字，此时回退到调用点原名，避免把 `len` 当成空名未知函数。
// 跨文件/跨包调用的 Func 在 gc.Analyze 阶段可能尚未绑定，这里按 Table 做
// 一次保守解析：精确名 → 包路径后缀唯一匹配 → 末段名唯一匹配。
func callKey(cb *parser.CallBlock) string {
	if cb == nil {
		return ""
	}
	if cb.Func != nil && len(cb.Func.Name) > 0 {
		return cb.Func.Name.String()
	}
	if cb.Name == nil {
		return ""
	}
	raw := cb.Name.String()
	if raw == "" {
		return ""
	}
	if _, ok := Table[raw]; ok {
		return raw
	}
	// 包路径后缀唯一匹配（如 strings.repeatN → /.../pkg/strings.repeatN）
	found := ""
	for k := range Table {
		if !strings.HasSuffix(k, "/"+raw) && !strings.HasSuffix(k, "."+raw) {
			continue
		}
		if found != "" && found != k {
			found = ""
			break
		}
		found = k
	}
	if found != "" {
		return found
	}
	// 末段名唯一匹配（仅当全程序只有一个同名函数时）
	last := raw
	if i := strings.LastIndexAny(raw, "./"); i >= 0 {
		last = raw[i+1:]
	}
	found = ""
	for k := range Table {
		kl := k
		if i := strings.LastIndexAny(k, "./"); i >= 0 {
			kl = k[i+1:]
		}
		if kl != last {
			continue
		}
		if found != "" && found != k {
			return raw // 同名多候选：保守不解析
		}
		found = k
	}
	if found != "" {
		return found
	}
	return raw
}

// callSummary 返回调用点的函数摘要（callKey 解析后查 Table）。
func callSummary(cb *parser.CallBlock) *FnSummary {
	return Table[callKey(cb)]
}

// pureBuiltinEscapes 纯内建参数逃逸摘要：只读实参，不保存/返回地址。
// unsafe.cast 是编译器 no-op 内建（位级重解释，从不逃逸实参）：不入清单时，
// 含 cast 的函数被 LLR 整体禁用帧内释放（CallsAny 非空即早退）。
func pureBuiltinEscapes(name string) (Escape, bool) {
	switch name {
	case "len", "cap", "sizeof", "print", "println", "panic", "unsafe.cast":
		return EscNone, true
	}
	return EscNone, false
}
