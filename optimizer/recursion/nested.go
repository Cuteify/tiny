// Package recursion 提供递归分析功能
package recursion

import (
	"cuteify/parser"
)

// isNestedRecursion 检查是否是嵌套递归（如 ackermann）
// 嵌套递归：递归调用作为另一个递归调用的参数
// 例如: ackermann(m, n) = ackermann(m-1, ackermann(m, n-1))
func isNestedRecursion(funcNode *parser.Node, info *RecursionInfo) bool {
	// 至少需要两个递归调用才可能是嵌套递归
	if len(info.RecursiveCalls) < 2 {
		return false
	}

	return hasNestedCalls(info)
}

// hasNestedCalls 检查递归调用中是否存在嵌套关系
func hasNestedCalls(info *RecursionInfo) bool {
	for _, recCall := range info.RecursiveCalls {
		if isNestedCall(recCall, info) {
			return true
		}
	}
	return false
}

// isNestedCall 检查单个调用是否包含嵌套的递归调用
// 即：该调用的参数中是否包含其他递归调用
func isNestedCall(callNode *parser.Node, info *RecursionInfo) bool {
	if callNode == nil || info == nil {
		return false
	}

	callBlock, ok := callNode.Value.(*parser.CallBlock)
	if !ok || callBlock == nil {
		return false
	}

	// 遍历所有参数，检查是否包含其他递归调用
	for _, arg := range callBlock.Args {
		if !argContainsOtherRecursiveCall(arg, callNode, info) {
			continue
		}
		return true
	}
	return false
}

// argContainsOtherRecursiveCall 检查参数中是否包含除当前调用外的递归调用
func argContainsOtherRecursiveCall(arg *parser.ArgBlock, currentCall *parser.Node, info *RecursionInfo) bool {
	if arg == nil || arg.Value == nil {
		return false
	}

	// 检查参数表达式是否包含其他递归调用（排除自身）
	for _, recCall := range info.RecursiveCalls {
		if recCall != currentCall && expressionContainsRecursiveCall(arg.Value, recCall) {
			return true
		}
	}
	return false
}

// transformNestedRecursion 转换嵌套递归（如 ackermann）为迭代
// 需要使用栈来模拟递归
func transformNestedRecursion(funcNode *parser.Node, info *RecursionInfo) {
	// 嵌套递归需要显式栈来模拟调用栈
	// 这里暂时不做实际转换
}
