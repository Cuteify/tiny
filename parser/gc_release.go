// parser/gc_release.go — 释放点：在哪 free
//
// 一行公式，没有例外：
//
//	释放点 = 全部绑定名里最外层的作用域
//
//	n := new(); head = n; for { ... }
//	n 的绑定名是 {n(循环体), head(函数体)} → 最外层是函数体 → 在函数出口释放
//	否则 head.next 会指向已经 free 掉的块
//
// 纯作用域规则，不看引用计数。算不出来（没有绑定名 / 只被字段读引用）
// 就兜底到所属函数的出口，保证"绝不泄漏"。
//
// 驱动入口 SimulateRC 在这里，是整个 GC 分析的唯一公开入口。

package parser

// SimulateRC 整个 GC 分析的唯一公开入口。必须在 Check 全部轮次结束后调用
// （要先知道谁逃逸）。
func SimulateRC(root *Node) {
	s := &rcSim{
		slot:   map[*VarBlock]*Object{},
		fields: map[*VarBlock]map[string]*Object{},
	}
	// 一趟树遍历同时干两件事：反转绑定名（collectNames），以及按语句顺序
	// 维护槽位表、就地判定（stmt/fieldWrite/call）。两者互不依赖，先到先算。
	//
	// 合并之前是三趟：反转一遍、模拟一遍、sweep 再找一遍函数块。
	collectNames(root)
	s.walk(root)
	scopeRelease() // 释放点：作用域规则，算不出就兜底到所属函数出口
	checkPremature()
}

// walkSubNodes 深度优先下钻整棵子树（含 else 分支，见 eachSubNode）。
func walkSubNodes(root *Node, fn func(n *Node)) {
	if root == nil {
		return
	}
	fn(root)
	eachSubNode(root, func(c *Node) { walkSubNodes(c, fn) })
}

// outermostBindingScope 对象释放点的结构下界：全部绑定名里最外层的作用域。
// 这是"最外层绑定名作用域"这条规则唯一的实现处 —— 结构规则、RC 对比、
// 向外推三处都用它，免得三份各写一遍慢慢分叉。
func outermostBindingScope(o *Object) Block {
	var widest Block
	for _, n := range o.Names {
		if n == nil || n.Life.Scope == nil {
			continue
		}
		widest = outerScope(widest, n.Life.Scope)
	}
	return widest
}

// scopeKindOf 作用域块的可读身份。用于诊断输出（checkPremature / TransferReport）。
func scopeKindOf(b Block) string {
	switch b.(type) {
	case *FuncBlock:
		return "fn"
	case *ForBlock:
		return "for"
	case *IfBlock:
		return "if"
	case *ElseBlock:
		return "else"
	case *SwitchBlock:
		return "switch"
	case *CaseBlock:
		return "case"
	}
	return "?"
}

// scopeRelease 释放点 = 全部绑定名里最外层的作用域。
//
// 纯作用域规则，不看引用计数：对象活到它最后一个绑定名所在作用域的出口。
// 引用计数只用于"就地释放"那一个问题 —— 一个对象有多个引用时，
// 改其中一个该不该 free，别的作用域规则答不了，得数一下。
//
// 只向外放：分支里的局部变量名会把释放点推到外层作用域，而不是反过来。
func scopeRelease() {
	for _, o := range objects {
		if o.Escapes || o.Transferred {
			continue
		}
		if widest := outermostBindingScope(o); widest != nil {
			o.FreeScope = widest
			// 读哪个栈槽：创建者被改绑时要换成另一个仍持有它的名字，
			// 否则会读到一个装着别的对象的槽，free 错块。
			if o.Holder == nil || !containsName(o.Names, o.Holder) {
				o.Holder = firstLiveName(o)
			}
			continue
		}
		// 算不出释放点（没有绑定名 / 只被字段读引用）：兜底到所属函数出口，
		// 保证"绝不泄漏"。读创建者的槽 —— 即使它已被改绑，也只会漏释放，
		// 不会 free 错别人的块（创建者的槽没被改绑时它就是持有者）。
		if fb := funcOfBlock(o.Scope); fb != nil && o.Owner != nil {
			o.FreeScope, o.Holder = fb, o.Owner
		}
	}
}

func containsName(ns []*VarBlock, v *VarBlock) bool {
	for _, n := range ns {
		if n == v {
			return true
		}
	}
	return false
}

// firstLiveName 挑一个仍持有该对象的绑定名当释放时的读槽来源。
func firstLiveName(o *Object) *VarBlock {
	for _, n := range o.Names {
		if n != nil && !n.Life.Escapes {
			return n
		}
	}
	return nil
}

// funcOfBlock 作用域块所属的函数；不在任何函数内返回 nil（全局）。
func funcOfBlock(b Block) *FuncBlock {
	for ; b != nil; b = outerParent(b) {
		if fb, ok := b.(*FuncBlock); ok {
			return fb
		}
	}
	return nil
}
