package compile

import (
	"cuteify/parser"
	"strings"
)

var count int = 0

func Format(text string) string {
	return strings.Repeat("    ", count) + text + "\n"
}

// 快速遍历AST，找到CFG为空的节点，从AST中删除，Root节点不算
func DelEmptyCFGNode(node *parser.Node) {
	if node == nil {
		return
	}
	if node.Children == nil {
		return
	}
	for i := 0; i < len(node.Children); i++ {
		switch node.Children[i].Value.(type) {
			case *parser.FuncBlock:
				DelEmptyCFGNode(node.Children[i])
				continue
		}
		if node.Children[i].CFG == nil || len(node.Children[i].CFG) == 0 {
			node.Children = append(node.Children[:i], node.Children[i+1:]...)
			i--
		}
		switch node.Children[i].Value.(type) {
		case *parser.ReturnBlock:
			node.Children = node.Children[:i+1]
		case *parser.IfBlock:
			ifNode := node.Children[i]
			if ifNode.Children == nil {
				node.Children = append(node.Children[:i], node.Children[i+1:]...)
				i--
			}
			if ifNode.Value.(*parser.IfBlock).Else && ifNode.Value.(*parser.IfBlock).ElseBlock.Children == nil {
				ifNode.Value.(*parser.IfBlock).Else = false
				ifNode.Value.(*parser.IfBlock).ElseBlock = nil
			}
		}
		DelEmptyCFGNode(node.Children[i])
	}
}
