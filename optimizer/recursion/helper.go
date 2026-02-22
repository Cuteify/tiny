// Package recursion 提供递归分析功能
package recursion

import (
	"cuteify/parser"
)

// collectRecursiveCalls 收集函数体中所有递归调用
func collectRecursiveCalls(node *parser.Node, funcName string, info *RecursionInfo) {
	if node == nil {
		return
	}

	// 检查当前节点是否是递归调用
	if callBlock, ok := node.Value.(*parser.CallBlock); ok {
		if callBlock.Name == funcName {
			info.RecursiveCalls = append(info.RecursiveCalls, node)
		}
	} else if exp, ok := node.Value.(*parser.Expression); ok {
		if exp.Call != nil && exp.Call.Name == funcName {
			info.RecursiveCalls = append(info.RecursiveCalls, node)
		}
	}

	// 递归检查子节点
	for _, child := range node.Children {
		collectRecursiveCalls(child, funcName, info)
	}
}

// containsParam 检查字符串切片是否包含指定参数
func containsParam(params []string, param string) bool {
	for _, p := range params {
		if p == param {
			return true
		}
	}
	return false
}

// isDescendantOrSelf 检查 target 是否是 node 或 node 的后代
func isDescendantOrSelf(node, target *parser.Node) bool {
	if node == nil {
		return false
	}
	if node == target {
		return true
	}
	for _, child := range node.Children {
		if isDescendantOrSelf(child, target) {
			return true
		}
	}
	return false
}

// containsReturn 检查节点是否包含返回语句
func containsReturn(node *parser.Node) bool {
	if node == nil {
		return false
	}

	// 检查是否是返回节点
	if exp, ok := node.Value.(*parser.Expression); ok {
		if exp.Call != nil && exp.Call.Name == "return" {
			return true
		}
	}

	// 递归检查子节点
	for _, child := range node.Children {
		if containsReturn(child) {
			return true
		}
	}

	return false
}

// containsRecursiveCall 检查节点是否包含递归调用
func containsRecursiveCall(node *parser.Node, info *RecursionInfo) bool {
	for _, recCall := range info.RecursiveCalls {
		if isDescendantOrSelf(node, recCall) {
			return true
		}
	}
	return false
}

// extractBaseCases 提取基本情况节点
func extractBaseCases(funcNode *parser.Node, info *RecursionInfo) {
	// 基本情况通常包含返回语句或没有递归调用的条件分支
	for _, child := range funcNode.Children {
		if containsReturn(child) && !containsRecursiveCall(child, info) {
			info.BaseCaseNodes = append(info.BaseCaseNodes, child)
		}
	}
}

// extractRecursiveParams 提取递归参数
func extractRecursiveParams(funcNode *parser.Node, info *RecursionInfo) {
	if len(info.RecursiveCalls) == 0 {
		return
	}

	// 获取函数参数
	funcBlock, _ := funcNode.Value.(*parser.FuncBlock)
	paramNames := make(map[string]bool)
	for _, arg := range funcBlock.Args {
		paramNames[arg.Name] = true
	}

	// 比较递归调用中的参数与原始参数
	// 找出在递归调用中发生变化的参数
	for _, recCall := range info.RecursiveCalls {
		if callBlock, ok := recCall.Value.(*parser.CallBlock); ok {
			for i, arg := range callBlock.Args {
				if i < len(funcBlock.Args) {
					paramName := funcBlock.Args[i].Name
					if arg.Value != nil {
						// 如果参数值不是简单的变量引用，则认为是递归参数
						if arg.Value.Var == nil || arg.Value.Var.Name != paramName {
							if !containsParam(info.RecursiveParams, paramName) {
								info.RecursiveParams = append(info.RecursiveParams, paramName)
							}
						}
					}
				}
			}
		}
	}

	// 如果没有找到变化的参数，检查所有参数是否都在递归调用中使用
	if len(info.RecursiveParams) == 0 {
		for _, arg := range funcBlock.Args {
			info.RecursiveParams = append(info.RecursiveParams, arg.Name)
		}
	}

	// 设置循环变量
	if len(info.RecursiveParams) > 0 {
		info.LoopVar = info.RecursiveParams[0]
	}
}

// checkExpressionHasAnyCall 检查表达式是否包含任何函数调用
func checkExpressionHasAnyCall(exp *parser.Expression) bool {
	if exp == nil {
		return false
	}

	// 检查是否是函数调用
	if exp.Call != nil {
		return true
	}

	// 递归检查左右子表达式
	if checkExpressionHasAnyCall(exp.Left) {
		return true
	}
	if checkExpressionHasAnyCall(exp.Right) {
		return true
	}

	return false
}

// expressionContainsRecursiveCall 检查表达式是否包含指定的递归调用节点
func expressionContainsRecursiveCall(exp *parser.Expression, recCallNode *parser.Node) bool {
	if exp == nil {
		return false
	}

	// 检查当前表达式是否是目标调用
	if exp.Call != nil {
		if recCallNode == nil {
			return false
		}
		callBlock, ok := recCallNode.Value.(*parser.CallBlock)
		if !ok {
			return false
		}
		if exp.Call == callBlock {
			return true
		}
	}

	// 递归检查子表达式
	if expressionContainsRecursiveCall(exp.Left, recCallNode) {
		return true
	}
	if expressionContainsRecursiveCall(exp.Right, recCallNode) {
		return true
	}

	return false
}
