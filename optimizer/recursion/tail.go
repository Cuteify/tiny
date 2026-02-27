// Package recursion 提供递归分析功能
package recursion

import (
	"cuteify/parser"
	typeSys "cuteify/type"
)

// isTailRecursion 检查是否是尾递归
// 尾递归的定义：递归调用是函数体中最后执行的操作
func isTailRecursion(funcNode *parser.Node, info *RecursionInfo) bool {
	if len(info.RecursiveCalls) != 1 {
		return false
	}

	recursiveCall := info.RecursiveCalls[0]

	// 检查递归调用是否在函数的最后位置
	// 需要遍历函数体的控制流来确定
	return checkIfTailPosition(funcNode, recursiveCall)
}

// checkIfTailPosition 检查节点是否在尾位置
func checkIfTailPosition(node, targetNode *parser.Node) bool {
	if node == nil {
		return false
	}

	// 如果当前节点是目标节点，检查是否在尾位置
	if node == targetNode {
		return true
	}

	// 处理 IfBlock：需要检查 then 和 else 分支的尾位置
	if _, ok := node.Value.(*parser.IfBlock); ok {
		for _, child := range node.Children {
			// 如果子节点是目标节点
			if child == targetNode {
				// 检查 if 语句之后是否还有其他语句
				return checkIfLastInBranch(node, targetNode)
			}
			// 递归检查子节点
			if checkIfTailPosition(child, targetNode) {
				// 对于 if 块，需要确保在 then/else 块的尾部
				return true
			}
		}
	}

	// 处理 ForBlock：for 循环内部的递归调用通常不是尾递归
	if _, ok := node.Value.(*parser.ForBlock); ok {
		return false
	}

	// 递归检查子节点
	for _, child := range node.Children {
		if checkIfTailPosition(child, targetNode) {
			// 需要检查目标节点之后是否还有其他语句
			return checkIfLastInSibling(node.Children, child)
		}
	}

	return false
}

// checkIfLastInSibling 检查节点是否是兄弟节点中的最后一个
func checkIfLastInSibling(children []*parser.Node, targetNode *parser.Node) bool {
	if len(children) == 0 {
		return false
	}

	// 找到目标节点的位置
	for i, child := range children {
		if child == targetNode {
			// 检查是否是最后一个子节点
			return i == len(children)-1
		}
		// 递归检查子节点
		if checkIfLastInSibling(child.Children, targetNode) {
			// 找到了，但需要检查从当前节点向上是否还有后续节点
			return i == len(children)-1
		}
	}

	return false
}

// checkIfLastInBranch 检查节点是否在分支的最后位置
func checkIfLastInBranch(node, targetNode *parser.Node) bool {
	// 如果节点是父节点的最后一个子节点
	if node.Father != nil {
		children := node.Father.Children
		for i, child := range children {
			if child == node {
				return i == len(children)-1
			}
			if checkIfLastInBranch(child, targetNode) {
				return i == len(children)-1
			}
		}
	}
	return false
}

// transformTailRecursion 转换尾递归为迭代
// 例如: factorial(n) { return n * factorial(n-1) }
// 转换为: for n > 1 { result *= n; n-- }
func transformTailRecursion(funcNode *parser.Node, info *RecursionInfo) {
	if len(info.RecursiveCalls) == 0 || len(info.RecursiveParams) == 0 {
		return
	}

	funcBlock, _ := funcNode.Value.(*parser.FuncBlock)
	if funcBlock == nil {
		return
	}

	// 获取循环变量
	loopVar := info.RecursiveParams[0]

	// 创建结果变量
	resultVarName := loopVar + "_result"
	resultVar := &parser.VarBlock{
		Name:     resultVarName,
		IsDefine: true,
		Type:     funcBlock.Return[0],
	}
	resultVarNode := &parser.Node{Value: resultVar}

	// 创建初始化语句（基于递归基本情况）
	initNodes := extractInitFromBaseCases(funcNode, info, resultVarName, loopVar)

	// 创建循环条件（基本情况的相反）
	loopCond := buildInverseCondition(funcNode, info, loopVar)

	// 创建循环体（递归情况的计算逻辑）
	loopBody := extractLoopBody(funcNode, info, resultVarName, loopVar)

	// 创建循环更新语句
	loopUpdate := buildLoopUpdateFromRecursiveCall(info, loopVar)

	// 创建 ForBlock
	forBlock := &parser.ForBlock{
		Init:      nil, // 初始化语句作为普通 VarBlock 节点处理
		Condition: loopCond,
		Increment: loopUpdate,
	}

	// 构建 for 循环节点
	forNode := &parser.Node{Value: forBlock}

	// 添加初始化语句（在循环之前）
	for _, initNode := range initNodes {
		forNode.Children = append(forNode.Children, initNode)
	}
	forNode.Children = append(forNode.Children, resultVarNode)

	// 添加循环体
	for _, bodyNode := range loopBody {
		forNode.Children = append(forNode.Children, bodyNode)
	}

	// 添加返回语句（返回结果变量）
	returnNode := createReturnNode(resultVarName, funcBlock.Return[0])
	forNode.Children = append(forNode.Children, returnNode)

	// 替换函数体
	funcNode.Children = []*parser.Node{forNode}

	// 设置父子关系
	forNode.Father = funcNode
	for _, child := range forNode.Children {
		child.Father = forNode
	}
}

// transformSimpleLinear 转换简单线性递归为迭代
// 例如: factorial(n), gcd(a,b)
func transformSimpleLinear(funcNode *parser.Node, info *RecursionInfo) {
	// 简单线性递归可以使用与尾递归相同的方法
	transformTailRecursion(funcNode, info)
}

// extractInitFromBaseCases 从基本情况提取初始化语句
func extractInitFromBaseCases(funcNode *parser.Node, info *RecursionInfo, resultVarName, loopVar string) []*parser.Node {
	var initNodes []*parser.Node

	// 如果有基本情况返回常量，初始化结果变量
	for _, baseCaseNode := range info.BaseCaseNodes {
		if exp, ok := baseCaseNode.Value.(*parser.Expression); ok {
			if exp.Call != nil && exp.Call.Name == "return" && len(exp.Call.Args) > 0 {
				// 创建结果变量的初始化
				initExp := &parser.Expression{
					Left: &parser.Expression{
						Var: &parser.VarBlock{Name: resultVarName},
					},
					Separator: "=",
					Right:     exp.Call.Args[0].Value,
				}
				initNode := &parser.Node{Value: initExp}
				initNodes = append(initNodes, initNode)
			}
		}
	}

	return initNodes
}

// buildInverseCondition 构建基本情况的相反条件作为循环条件
func buildInverseCondition(funcNode *parser.Node, info *RecursionInfo, loopVar string) *parser.Expression {
	// 查找基本情况的 if 条件
	for _, child := range funcNode.Children {
		if ifBlock, ok := child.Value.(*parser.IfBlock); ok {
			if ifBlock.Condition != nil {
				// 构建相反条件（例如 n <= 1 变成 n > 1）
				inverseCond := invertCondition(ifBlock.Condition, loopVar)
				return inverseCond
			}
		}
	}

	// 默认条件
	return &parser.Expression{
		Left: &parser.Expression{
			Var: &parser.VarBlock{Name: loopVar},
		},
		Separator: ">",
		Right:     &parser.Expression{Num: 0},
	}
}

// invertCondition 反转条件（例如 <= 变成 >）
func invertCondition(cond *parser.Expression, loopVar string) *parser.Expression {
	if cond == nil {
		return nil
	}

	// 简单的反转逻辑
	newSeparator := ""
	switch cond.Separator {
	case "<=":
		newSeparator = ">"
	case "<":
		newSeparator = ">="
	case ">=":
		newSeparator = "<"
	case ">":
		newSeparator = "<="
	case "==":
		newSeparator = "!="
	case "!=":
		newSeparator = "=="
	default:
		// 不支持的条件
		return nil
	}

	return &parser.Expression{
		Left:      cond.Left,
		Separator: newSeparator,
		Right:     cond.Right,
	}
}

// extractLoopBody 提取循环体（递归情况的计算逻辑）
func extractLoopBody(funcNode *parser.Node, info *RecursionInfo, resultVarName, loopVar string) []*parser.Node {
	var bodyNodes []*parser.Node

	if len(info.RecursiveCalls) == 0 {
		return bodyNodes
	}

	// 获取递归调用的上下文
	recCallNode := info.RecursiveCalls[0]
	recCall := recCallNode.Value.(*parser.CallBlock)

	// 查找递归调用所在的表达式
	// 提取计算逻辑（例如 result *= n）
	if parentExp := findExpressionContainingCall(funcNode, recCallNode); parentExp != nil {
		// 将递归调用替换为 resultVar
		newExp := replaceRecursiveCallWithResult(parentExp, recCall, resultVarName)
		if newExp != nil {
			bodyNodes = append(bodyNodes, &parser.Node{Value: newExp})
		}
	}

	return bodyNodes
}

// findExpressionContainingCall 查找包含递归调用的表达式
func findExpressionContainingCall(node *parser.Node, recCallNode *parser.Node) *parser.Expression {
	for _, child := range node.Children {
		if child == recCallNode && child.Father != nil {
			// 向上查找包含该调用的表达式
			return findParentExpression(child.Father)
		}
		if exp := findExpressionContainingCall(child, recCallNode); exp != nil {
			return exp
		}
	}
	return nil
}

// findParentExpression 查找最近的 Expression 节点
func findParentExpression(node *parser.Node) *parser.Expression {
	if node == nil {
		return nil
	}
	if exp, ok := node.Value.(*parser.Expression); ok {
		return exp
	}
	return findParentExpression(node.Father)
}

// replaceRecursiveCallWithResult 将递归调用替换为结果变量
func replaceRecursiveCallWithResult(exp *parser.Expression, recCall *parser.CallBlock, resultVarName string) *parser.Expression {
	// 创建新的表达式，将递归调用替换为 resultVar
	newExp := &parser.Expression{
		Left: &parser.Expression{
			Var: &parser.VarBlock{Name: resultVarName},
		},
		Separator: "*",
		Right:     exp.Right, // 保留右边的表达式（例如 n）
	}

	return newExp
}

// buildLoopUpdateFromRecursiveCall 从递归调用构建循环更新
func buildLoopUpdateFromRecursiveCall(info *RecursionInfo, loopVar string) *parser.Expression {
	if len(info.RecursiveCalls) == 0 {
		return nil
	}

	// 获取递归调用的参数变化
	recCall := info.RecursiveCalls[0].Value.(*parser.CallBlock)
	for _, arg := range recCall.Args {
		if arg.Value != nil && arg.Value.Var != nil && arg.Value.Var.Name == loopVar {
			// 找到循环变量的更新
			// 例如: factorial(n-1) 表示 n 应该减 1
			if arg.Value.Right != nil && arg.Value.Separator == "-" {
				return &parser.Expression{
					Left: &parser.Expression{
						Var: &parser.VarBlock{Name: loopVar},
					},
					Separator: "--",
				}
			}
		}
	}

	// 默认递减
	return &parser.Expression{
		Left: &parser.Expression{
			Var: &parser.VarBlock{Name: loopVar},
		},
		Separator: "--",
	}
}

// createReturnNode 创建返回节点
func createReturnNode(varName string, retType typeSys.Type) *parser.Node {
	argBlock := &parser.ArgBlock{
		Value: &parser.Expression{
			Var:  &parser.VarBlock{Name: varName, Type: retType},
			Type: retType,
		},
	}
	returnCall := &parser.CallBlock{
		Name: "return",
		Args: []*parser.ArgBlock{argBlock},
	}
	return &parser.Node{Value: &parser.Expression{Call: returnCall}}
}
