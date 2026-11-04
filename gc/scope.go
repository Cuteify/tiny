// gc/scope.go — 作用域工具：深度、外层、可读身份。
//
// 全部只读 parser.Block 与旁挂表，不碰解析器内部账本。

package gc

import "cuteify/parser"

// scopeKindOf 作用域块的可读身份。用于诊断输出（checkPremature / TransferReport）。
func scopeKindOf(b parser.Block) string {
	switch b.(type) {
	case *parser.FuncBlock:
		return "fn"
	case *parser.ForBlock:
		return "for"
	case *parser.IfBlock:
		return "if"
	case *parser.ElseBlock:
		return "else"
	case *parser.SwitchBlock:
		return "switch"
	case *parser.CaseBlock:
		return "case"
	}
	return "?"
}

// outerScope 取更外层的作用域（nil 表示未知）。深度按块的祖先链算，
// 靠 parser.BlockNode 索引反查节点。
func outerScope(a, b parser.Block) parser.Block {
	if a == nil {
		return b
	}
	if b == nil {
		return a
	}
	if scopeDepth(a) <= scopeDepth(b) {
		return a
	}
	return b
}

// scopeDepth 作用域的嵌套深度：函数体最浅，块体依次加深。
func scopeDepth(b parser.Block) int {
	d := 0
	for ; b != nil; b = outerParent(b) {
		d++
	}
	return d
}

// outerParent 直接外层的作用域块（跳过不圈作用域的节点，如普通语句）。
func outerParent(b parser.Block) parser.Block {
	for n := parser.BlockNode(b); n != nil && n.Father != nil; n = n.Father {
		if n.Father.Value != nil && parser.IsScopeBlock(n.Father.Value) {
			return n.Father.Value
		}
	}
	return nil
}

// funcOfBlock 作用域块所属的函数；不在任何函数内返回 nil（全局）。
func funcOfBlock(b parser.Block) *parser.FuncBlock {
	for ; b != nil; b = outerParent(b) {
		if fb, ok := b.(*parser.FuncBlock); ok {
			return fb
		}
	}
	return nil
}
