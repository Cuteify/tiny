package compile

import (
	"cuteify/parser"
	"cuteify/utils"
)

// compileDeferBlock 编译 defer 语句
// defer 语句将函数调用延迟到当前作用域退出时执行
func (c *Compiler) compileDeferBlock(n *parser.Node) string {
	deferBlock := n.Value.(*parser.DeferBlock)
	if deferBlock.Call == nil {
		return ""
	}

	// 记录延迟的函数调用
	// 在编译函数体时收集 defer 语句，在函数返回前统一执行
	// 这里生成注释标记，实际的 defer 执行在 compileReturnBlock 中处理
	code := utils.Format("; defer: " + deferBlock.Call.Name.String() + "() — 将在函数返回时执行")
	return code
}

// compileDeferCalls 编译所有延迟的函数调用（在函数返回前调用）
func (c *Compiler) compileDeferCalls(funcNode *parser.Node) string {
	var code string

	// 遍历函数体，收集所有 defer 语句
	// defer 按 LIFO 顺序执行（后进先出）
	deferNodes := c.collectDeferNodes(funcNode)
	for i := len(deferNodes) - 1; i >= 0; i-- {
		deferBlock := deferNodes[i].Value.(*parser.DeferBlock)
		if deferBlock.Call != nil {
			deferNode := &parser.Node{Value: deferBlock.Call}
			deferNode.Father = funcNode
			code += c.compileCallBlock(deferNode)
		}
	}

	return code
}

// collectDeferNodes 递归收集所有 defer 节点
func (c *Compiler) collectDeferNodes(node *parser.Node) []*parser.Node {
	var deferNodes []*parser.Node

	for _, child := range node.Children {
		if child.Ignore {
			continue
		}

		switch v := child.Value.(type) {
		case *parser.DeferBlock:
			deferNodes = append(deferNodes, child)
		case *parser.IfBlock:
			// 递归收集 if 块中的 defer
			deferNodes = append(deferNodes, c.collectDeferNodes(child)...)
			if v.Else {
				deferNodes = append(deferNodes, c.collectDeferNodes(v.ElseBlock)...)
			}
		case *parser.ForBlock:
			// 递归收集 for 块中的 defer
			deferNodes = append(deferNodes, c.collectDeferNodes(child)...)
		case *parser.SwitchBlock:
			// 递归收集 switch 块中的 defer
			deferNodes = append(deferNodes, c.collectDeferNodes(child)...)
		}
	}

	return deferNodes
}
