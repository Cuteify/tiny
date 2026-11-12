// gc/retsum.go — 返回值来源摘要（前端）。
//
// 解决的问题：只说“返回值里可能有本帧分配的对象”不够，调用方还需要知道
// 是不是全部路径都归它：遇到“一个分支返回本地分配、另一个分支返回参数”
// 的函数，直接 claim 一个新对象会 free 掉调用方仍然持有的指针。
//
// 判定比后端 FnSummary 更严格：只要存在混合来源（Fresh + alias/borrow）
// 就归为 Unknown。方向是宁可不自动释放，绝不释放不属于本帧的块。
// 摘要按 AST 语法计算，不读旁挂表。
//
// 已知边界：局部变量的赋值来源按“所有同名赋值求并集”判定，不做路径敏感；
// 字段读、索引、未知调用一律 Unknown。匿名函数/闭包没有独立 AST 节点
// （BlockNode 为 nil），其自身摘要返回 Unknown；闭包体内的 return 仍会被
// 所属具名函数的扫描看到。

package gc

import "cuteify/parser"

// ReturnKind 返回值所有权来源。只有 ReturnFresh 允许调用方把结果当本帧
// 独占对象接管并自动释放。
type ReturnKind uint8

const (
	// ReturnNone 返回值类型不携带拥有指针。
	ReturnNone ReturnKind = iota
	// ReturnFresh 全部返回路径都是本帧新分配 / nil / 空串，调用方可独占。
	ReturnFresh
	// ReturnAlias 返回值是参数本身（不是内部指针）。
	ReturnAlias
	// ReturnBorrow 返回值是参数对象的内部指针（字段 / 索引）。
	ReturnBorrow
	// ReturnUnknown 来源无法证明，或存在混合来源。
	ReturnUnknown
)

// String 诊断用可读名称。
func (k ReturnKind) String() string {
	switch k {
	case ReturnNone:
		return "None"
	case ReturnFresh:
		return "Fresh"
	case ReturnAlias:
		return "Alias"
	case ReturnBorrow:
		return "Borrow"
	default:
		return "Unknown"
	}
}

// retSourceOf 返回函数的返回值来源摘要。查询结果缓存；函数体不完整或递归
// 环上返回 Unknown，不缓存。
func (a *analysis) retSourceOf(fb *parser.FuncBlock) ReturnKind {
	return a.retKindOf(fb)
}

// RetSourceOf 前端返回值来源摘要（需先 Analyze / CollectFront）。
func RetSourceOf(fb *parser.FuncBlock) ReturnKind {
	if front == nil {
		return ReturnUnknown
	}
	return front.retSourceOf(fb)
}

func (a *analysis) retKindOf(fb *parser.FuncBlock) ReturnKind {
	if fb == nil || len(fb.Return) == 0 {
		return ReturnNone
	}
	// 返回类型还没解析出来：先按未知处理，但绝不缓存，等下一轮。
	if fb.Return[0] == nil {
		return ReturnUnknown
	}
	if !owningType(fb.Return[0]) {
		return ReturnNone
	}
	if k, ok := a.retSumMemo[fb]; ok {
		return k
	}
	if a.retSumBusy[fb] {
		return ReturnUnknown // 递归环：没有可证明的地面事实
	}
	a.retSumBusy[fb] = true
	defer delete(a.retSumBusy, fb)

	out := ReturnNone
	found := false
	a.walkFuncBody(fb, func(n *parser.Node) {
		rb, ok := n.Value.(*parser.ReturnBlock)
		if !ok || rb == nil || len(rb.Value) == 0 {
			return
		}
		found = true
		out = mergeReturnKind(out, a.exprRetKind(rb.Value[0], fb, nil))
	})
	if !found {
		return ReturnUnknown // 没有 return 语句：来源不可证
	}
	if out == ReturnUnknown || out == ReturnNone {
		return ReturnUnknown
	}
	a.retSumMemo[fb] = out
	return out
}

// exprRetKind 单个返回表达式的来源。visiting 是局部变量名递归栈，nil 表示
// 顶层调用；同一函数内 a = b; b = a 会在这里判 Unknown。
func (a *analysis) exprRetKind(e *parser.Expression, fb *parser.FuncBlock, visiting map[string]bool) ReturnKind {
	if e == nil {
		return ReturnUnknown
	}

	if e.Var != nil && e.Var.Name != nil {
		root := e.Var.Name.First()
		if isParamName(fb, root) {
			if e.Var.Name.Length() == 1 {
				return ReturnAlias
			}
			return ReturnBorrow // p.field / p[i]：内部指针
		}
		if e.Var.Name.Length() == 1 {
			return a.localRetKind(root, fb, visiting)
		}
		return ReturnUnknown // 字段读 / 索引 / 全局 / 外层变量
	}

	if e.Call != nil {
		if e.Call.IsRC {
			return ReturnUnknown // newRC：生命周期由用户手工 rcDec 管
		}
		if e.Call.IsBuiltinNewAlloc() {
			return ReturnFresh
		}
		if e.Call.Func == nil {
			return ReturnUnknown
		}
		switch a.retKindOf(e.Call.Func) {
		case ReturnFresh:
			return ReturnFresh
		case ReturnAlias:
			return ReturnAlias
		case ReturnBorrow:
			return ReturnBorrow
		default:
			return ReturnUnknown
		}
	}

	if e.ConstNil {
		return ReturnFresh // free(nil) 安全
	}
	if e.Type != nil && e.Type.Kind() == "string" {
		if e.Separator == "+" {
			return ReturnFresh // 拼接总是新缓冲
		}
		if e.IsConst() && e.StringVal == "" {
			return ReturnFresh // 空串 ptr=0，free(nil) 安全
		}
		if e.IsConst() {
			return ReturnUnknown // 非空常量指向静态标签
		}
	}
	return ReturnUnknown
}

// localRetKind 函数内局部变量 name 的所有赋值来源求并集。
// 只扫描当前函数体，不跨嵌套函数；同名变量在分支里多次赋值时，任一来源
// 不可证就整体 Unknown。
func (a *analysis) localRetKind(name string, fb *parser.FuncBlock, visiting map[string]bool) ReturnKind {
	if name == "" {
		return ReturnUnknown
	}
	if visiting[name] {
		return ReturnUnknown
	}
	// 取地址的局部不能按“零值 + 显式赋值”判定：函数可能通过指针把参数 /
	// 静态缓冲写进它（strings.view 的 var result + &result 就是实例）。
	// 这类局部一律 Unknown，避免调用方 free 掉非本帧分配的底层缓冲。
	if a.bodyTakesAddrOf(fb, name) {
		return ReturnUnknown
	}
	if visiting == nil {
		visiting = map[string]bool{}
	}
	busy := a.retLocalBusy[fb]
	if busy == nil {
		busy = map[string]bool{}
		a.retLocalBusy[fb] = busy
	}
	if busy[name] {
		return ReturnUnknown
	}
	busy[name] = true
	visiting[name] = true
	defer func() {
		delete(busy, name)
		delete(visiting, name)
	}()

	out := ReturnNone
	found := false
	a.walkFuncBody(fb, func(n *parser.Node) {
		vb, ok := n.Value.(*parser.VarBlock)
		if !ok || vb == nil || vb.IsGlobal || vb.Name == nil ||
			vb.Name.Length() != 1 || vb.Name.First() != name {
			return
		}
		if !owningType(vb.Type) && !(vb.Value != nil && owningType(vb.Value.Type)) {
			return // 非 owning 的同名局部与返回值无关
		}
		found = true
		if vb.Value == nil {
			if vb.IsDefine {
				out = mergeReturnKind(out, ReturnFresh) // 零值指针
			} else {
				out = mergeReturnKind(out, ReturnUnknown)
			}
			return
		}
		out = mergeReturnKind(out, a.exprRetKind(vb.Value, fb, visiting))
	})
	if !found {
		return ReturnUnknown
	}
	if out == ReturnUnknown || out == ReturnNone {
		return ReturnUnknown
	}
	return out
}

// mergeReturnKind 合并两条返回路径。相同来源保留，混合来源一律 Unknown：
// Fresh + Alias 绝不能降级成“带 mask 的 Fresh”，调用方会 free 掉参数。
func mergeReturnKind(a, b ReturnKind) ReturnKind {
	if a == ReturnNone {
		return b
	}
	if b == ReturnNone {
		return a
	}
	if a == b {
		return a
	}
	return ReturnUnknown
}

// isParamName 判断名字是否为当前函数的拥有型参数。
func isParamName(fb *parser.FuncBlock, name string) bool {
	if fb == nil || name == "" {
		return false
	}
	for _, ag := range fb.Args {
		if ag != nil && ag.Name != nil && ag.Name.First() == name {
			return true
		}
	}
	return false
}

// walkFuncBody 遍历函数体节点，跳过嵌套函数（嵌套函数的 return 不属于本函数），
// 并覆盖 IfBlock.ElseBlock。root 是函数节点本身时允许进入。
func (a *analysis) walkFuncBody(fb *parser.FuncBlock, fn func(*parser.Node)) {
	root := parser.BlockNode(fb)
	if root == nil {
		return
	}
	var walk func(n *parser.Node, root bool)
	walk = func(n *parser.Node, root bool) {
		if n == nil {
			return
		}
		if !root {
			if _, nested := n.Value.(*parser.FuncBlock); nested {
				return
			}
		}
		fn(n)
		for _, c := range n.Children {
			walk(c, false)
		}
		if ib, ok := n.Value.(*parser.IfBlock); ok && ib.ElseBlock != nil {
			walk(ib.ElseBlock, false)
		}
	}
	walk(root, true)
}

// bodyTakesAddrOf 函数体内是否对局部 name 取过地址。结果按函数 + 名字缓存。
func (a *analysis) bodyTakesAddrOf(fb *parser.FuncBlock, name string) bool {
	cache := a.retAddrMemo[fb]
	if cache == nil {
		cache = map[string]bool{}
		a.retAddrMemo[fb] = cache
	}
	if v, ok := cache[name]; ok {
		return v
	}
	taken := bodyTakesAddrOfNode(parser.BlockNode(fb), name)
	cache[name] = taken
	return taken
}

// bodyTakesAddrOfNode 在给定函数体节点内查找一元 &name，跳过嵌套函数。
// 独立于前端 analysis，供后端摘要分析复用；根节点允许是 FuncBlock。
func bodyTakesAddrOfNode(root *parser.Node, name string) bool {
	if root == nil || name == "" {
		return false
	}
	taken := false
	var walk func(n *parser.Node, isRoot bool)
	walk = func(n *parser.Node, isRoot bool) {
		if n == nil || taken {
			return
		}
		if !isRoot {
			if _, nested := n.Value.(*parser.FuncBlock); nested {
				return
			}
		}
		nodeExpressions(n.Value, func(e *parser.Expression) {
			if !taken && exprTakesAddrOf(e, name) {
				taken = true
			}
		})
		for _, c := range n.Children {
			walk(c, false)
		}
		if ib, ok := n.Value.(*parser.IfBlock); ok && ib.ElseBlock != nil {
			walk(ib.ElseBlock, false)
		}
	}
	walk(root, true)
	return taken
}

// nodeExpressions 枚举一个 AST 节点直接持有的表达式。表达式树不在
// n.Children 里，取地址 / 赋值来源必须从这些字段下钻。
func nodeExpressions(v parser.Block, fn func(*parser.Expression)) {
	switch x := v.(type) {
	case *parser.VarBlock:
		fn(x.Value)
	case *parser.ReturnBlock:
		for _, e := range x.Value {
			fn(e)
		}
	case *parser.IfBlock:
		fn(x.Condition)
	case *parser.ForBlock:
		fn(x.Init)
		fn(x.Condition)
		fn(x.Increment)
		fn(x.Range)
	case *parser.Expression:
		fn(x)
	case *parser.CallBlock:
		for _, ag := range x.Args {
			if ag != nil {
				fn(ag.Value)
			}
		}
		for _, ag := range x.VariadicArgs {
			if ag != nil {
				fn(ag.Value)
			}
		}
	case *parser.CaseBlock:
		for _, e := range x.Values {
			fn(e)
		}
	}
}

// exprTakesAddrOf 表达式树里是否出现一元 &name。限定 Left==nil，避免把
// 位与 a & b 误判成取地址。
func exprTakesAddrOf(e *parser.Expression, name string) bool {
	if e == nil {
		return false
	}
	if e.Separator == "&" && e.Left == nil && e.Right != nil && e.Right.Var != nil &&
		e.Right.Var.Name != nil && e.Right.Var.Name.Length() == 1 &&
		e.Right.Var.Name.First() == name {
		return true
	}
	if e.Call != nil {
		for _, ag := range e.Call.Args {
			if ag != nil && exprTakesAddrOf(ag.Value, name) {
				return true
			}
		}
		for _, ag := range e.Call.VariadicArgs {
			if ag != nil && exprTakesAddrOf(ag.Value, name) {
				return true
			}
		}
	}
	if exprTakesAddrOf(e.Left, name) || exprTakesAddrOf(e.Right, name) {
		return true
	}
	for _, ix := range e.Index {
		if exprTakesAddrOf(ix, name) {
			return true
		}
	}
	for _, el := range e.ListElems {
		if exprTakesAddrOf(el, name) {
			return true
		}
	}
	return false
}
