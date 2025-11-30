// Package compile utils.go 包含编译器工具函数
package compile

import (
	"cuteify/parser"
	"fmt"
)

// DelEmptyCFGNode 删除AST中CFG为空的节点
// 从AST中删除CFG为空的节点，Root节点不处理
// 参数:
//   - node: 当前处理的AST节点
func DelEmptyCFGNode(node *parser.Node) {
	if node == nil {
		return
	}

	if node.Children == nil {
		return
	}

	for i := 0; i < len(node.Children); i++ {
		// 如果是函数块，递归处理后跳过其他检查
		switch node.Children[i].Value.(type) {
		case *parser.FuncBlock:
			DelEmptyCFGNode(node.Children[i])
			continue
		}

		// 如果当前节点的CFG为空，则删除该节点
		/*if len(node.Children[i].CFG) == 0 {
			node.Children = append(node.Children[:i], node.Children[i+1:]...)
			i--
		}*/

		// 特殊处理不同类型的节点
		switch node.Children[i].Value.(type) {
		case *parser.ReturnBlock:
			// 遇到返回块时，截断后续所有节点
			node.Children = node.Children[:i+1]
		case *parser.IfBlock:
			// 处理if块的特殊情况
			ifNode := node.Children[i]
			if ifNode.Children == nil {
				// 如果if块没有子节点，则删除该if块
				node.Children = append(node.Children[:i], node.Children[i+1:]...)
				i--
			}

			// 检查else分支是否存在且为空
			if ifNode.Value.(*parser.IfBlock).Else &&
				ifNode.Value.(*parser.IfBlock).ElseBlock.Children == nil {
				// 如果else块为空，则将其置为nil
				ifNode.Value.(*parser.IfBlock).Else = false
				ifNode.Value.(*parser.IfBlock).ElseBlock = nil
			}
		}

		// 递归处理当前节点的子节点
		DelEmptyCFGNode(node.Children[i])
	}
}

func pr(block *parser.Node, tabnum int) {
	tmp := ""
	for i := 0; i < tabnum; i++ {
		tmp += "\t"
	}
	fmt.Println(tmp, block.Value)
	for _, k := range block.Children {
		pr(k, tabnum+1)
	}
}
