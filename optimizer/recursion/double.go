// Package recursion 提供递归分析功能
package recursion

import (
	"cuteify/parser"
	typeSys "cuteify/type"
)

// isDoubleRecursion 检查是否是双递归（如 fibonacci）
// 双递归：两个递归调用在同一层级，不是嵌套关系，参数不同
// 例如: fib(n) = fib(n-1) + fib(n-2)
func isDoubleRecursion(funcNode *parser.Node, info *RecursionInfo) bool {
	if len(info.RecursiveCalls) != 2 {
		return false
	}

	// 检查是否有嵌套调用（一个调用是另一个调用的参数）
	// 双递归不应该有嵌套
	if hasNestedCalls(info) {
		return false
	}

	// 查找函数体中是否有一个二元运算表达式使用了两个函数调用
	// 例如: return fib(i-1) + fib(i-2)
	for _, child := range funcNode.Children {
		if returnBlock, ok := child.Value.(*parser.ReturnBlock); ok {
			if len(returnBlock.Value) > 0 {
				returnExp := returnBlock.Value[0]
				// 检查返回表达式是否是二元运算
				if returnExp.Separator == "+" || returnExp.Separator == "-" ||
					returnExp.Separator == "*" || returnExp.Separator == "/" {
					// 检查左右操作数是否都包含函数调用
					leftHasCall := checkExpressionHasAnyCall(returnExp.Left)
					rightHasCall := checkExpressionHasAnyCall(returnExp.Right)
					if leftHasCall && rightHasCall {
						return true
					}
				}
			}
		}
	}

	return false
}

// transformDoubleRecursion 转换双递归（如 fibonacci）为迭代
// 使用动态规划：数组存储中间结果
// 例如：fib(n) 需要 fib[n-1] 和 fib[n-2]
func transformDoubleRecursion(funcNode *parser.Node, info *RecursionInfo) {
	if len(info.RecursiveCalls) != 2 {
		return
	}

	funcBlock, _ := funcNode.Value.(*parser.FuncBlock)
	if funcBlock == nil || len(funcBlock.Args) == 0 {
		return
	}

	// 创建循环结构
	forNode := createDoubleRecursionLoop(funcBlock)

	// 构建并添加初始化语句
	addDoubleRecursionInitVars(forNode, funcBlock)

	// 添加循环体
	addDoubleRecursionLoopBody(forNode, funcBlock)

	// 添加返回语句
	addDoubleRecursionReturn(forNode, funcBlock)

	// 替换函数体为 for 循环
	funcNode.Children = []*parser.Node{forNode}
}

// createDoubleRecursionLoop 创建双递归的循环结构
func createDoubleRecursionLoop(funcBlock *parser.FuncBlock) *parser.Node {
	loopVar := funcBlock.Args[0].Name
	jVarName := parser.Name([]string{"j"})

	// 创建循环初始化变量
	loopInit := &parser.Expression{
		Var: &parser.VarBlock{
			Name: jVarName,
			Type: typeSys.GetSystemType("int"),
			Value: &parser.Expression{
				Num: 0,
			},
		},
	}

	// 构建循环条件：j < n
	loopCond := &parser.Expression{
		Left: &parser.Expression{
			Var: &parser.VarBlock{
				Name:   jVarName,
				Type:   typeSys.GetSystemType("int"),
				Define: &parser.Node{Value: loopInit.Var},
			},
			Type: typeSys.GetSystemType("int"),
		},
		Separator: "<",
		Right: &parser.Expression{
			Var: &parser.VarBlock{
				Name:   loopVar,
				Type:   funcBlock.Return[0],
				Define: &parser.Node{Value: loopInit.Var},
			},
			Type: funcBlock.Return[0],
		},
	}

	// 构建循环更新：j++
	loopUpdate := &parser.Expression{
		Var: &parser.VarBlock{
			Name: jVarName,
			Type: typeSys.GetSystemType("int"),
			Value: &parser.Expression{
				Left: &parser.Expression{
					Var: &parser.VarBlock{
						Name:   jVarName,
						Type:   typeSys.GetSystemType("int"),
						Define: &parser.Node{Value: loopInit.Var},
					},
				},
				Separator: "+",
				Right: &parser.Expression{
					Num:  1,
					Type: typeSys.GetSystemType("int"),
				},
			},
		},
	}

	forBlock := &parser.ForBlock{
		Init:      loopInit,
		Condition: loopCond,
		Increment: loopUpdate,
	}

	return &parser.Node{Value: forBlock, Parser: nil}
}

// addDoubleRecursionInitVars 添加双递归的初始化变量
func addDoubleRecursionInitVars(forNode *parser.Node, funcBlock *parser.FuncBlock) {
	loopVar := funcBlock.Args[0].Name

	// 变量名
	prevVarName := parser.Name([]string{loopVar.String() + "_prev"})
	curVarName := parser.Name([]string{loopVar.String() + "_cur"})
	jVarName := parser.Name([]string{"j"})

	// 创建初始化节点
	prevVarNode := createVarNode(prevVarName, 0, funcBlock.Return[0])
	curVarNode := createVarNode(curVarName, 1, funcBlock.Return[0])
	jVarNode := createVarNode(jVarName, 0, typeSys.GetSystemType("int"))

	// 设置父子关系并添加到循环
	for _, node := range []*parser.Node{prevVarNode, curVarNode, jVarNode} {
		node.Father = forNode
		forNode.Children = append(forNode.Children, node)
	}
}

// addDoubleRecursionLoopBody 添加双递归的循环体
func addDoubleRecursionLoopBody(forNode *parser.Node, funcBlock *parser.FuncBlock) {
	loopVar := funcBlock.Args[0].Name

	// 变量名
	prevVarName := parser.Name([]string{loopVar.String() + "_prev"})
	curVarName := parser.Name([]string{loopVar.String() + "_cur"})
	nextVarName := parser.Name([]string{"next"})

	// 查找变量定义节点
	prevVarNode := findVarDefinition(forNode, prevVarName)
	curVarNode := findVarDefinition(forNode, curVarName)

	// 创建循环体节点
	bodyNodes := createDoubleRecursionBodyNodes(prevVarName, curVarName, nextVarName, funcBlock.Return[0], prevVarNode, curVarNode)

	// 设置父子关系并添加到循环
	for _, node := range bodyNodes {
		node.Father = forNode
		forNode.Children = append(forNode.Children, node)
	}
}

// findVarDefinition 在节点的子节点中查找变量定义
func findVarDefinition(node *parser.Node, varName parser.Name) *parser.Node {
	for _, child := range node.Children {
		if varBlock, ok := child.Value.(*parser.VarBlock); ok && varBlock.IsDefine && varBlock.Name.String() == varName.String() {
			return child
		}
	}
	return nil
}

// createDoubleRecursionBodyNodes 创建双递归循环体节点
func createDoubleRecursionBodyNodes(prevVarName, curVarName, nextVarName parser.Name, varType typeSys.Type, prevVarNode, curVarNode *parser.Node) []*parser.Node {
	var nodes []*parser.Node

	// next := prev + cur
	nextExp := &parser.Expression{
		Left: &parser.Expression{
			Var: &parser.VarBlock{
				Name:   prevVarName,
				Type:   varType,
				Define: prevVarNode,
			},
			Type: varType,
		},
		Separator: "+",
		Right: &parser.Expression{
			Var: &parser.VarBlock{
				Name:   curVarName,
				Type:   varType,
				Define: curVarNode,
			},
			Type: varType,
		},
		Type: varType,
	}
	nextVar := &parser.VarBlock{
		Name:  nextVarName,
		Value: nextExp,
		Type:  varType,
	}
	nextVarNode := &parser.Node{Value: nextVar}
	nodes = append(nodes, nextVarNode)

	// prev = cur
	prevAssign := createAssignNode(prevVarName, curVarName, varType, prevVarNode, curVarNode)
	nodes = append(nodes, prevAssign)

	// cur = next
	curAssign := createAssignNode(curVarName, nextVarName, varType, curVarNode, nextVarNode)
	nodes = append(nodes, curAssign)

	return nodes
}

// addDoubleRecursionReturn 添加返回语句
func addDoubleRecursionReturn(forNode *parser.Node, funcBlock *parser.FuncBlock) {
	loopVar := funcBlock.Args[0].Name
	prevVarName := parser.Name([]string{loopVar.String() + "_prev"})

	// 查找 prev 变量定义
	prevVarNode := findVarDefinition(forNode, prevVarName)

	returnNode := createReturnNode(prevVarName, funcBlock.Return[0])
	if prevVarNode != nil {
		returnNode.Parser = prevVarNode.Parser
	}
	returnNode.Father = forNode
	forNode.Children = append(forNode.Children, returnNode)
}

// createVarNode 创建变量初始化节点
func createVarNode(name parser.Name, num int, varType typeSys.Type) *parser.Node {
	return &parser.Node{
		Value: &parser.VarBlock{
			Name:     name,
			IsDefine: true,
			Value:    &parser.Expression{Num: float64(num), Type: varType},
			Type:     varType,
		},
	}
}

// createAssignNode 创建赋值节点
func createAssignNode(targetName, sourceName parser.Name, varType typeSys.Type, targetVarNode, sourceVarNode *parser.Node) *parser.Node {
	return &parser.Node{
		Value: &parser.VarBlock{
			Name:   targetName,
			Type:   varType,
			Define: targetVarNode,
			Value: &parser.Expression{
				Var: &parser.VarBlock{
					Name:   sourceName,
					Type:   varType,
					Define: sourceVarNode,
				},
				Type: varType,
			},
		},
	}
}
