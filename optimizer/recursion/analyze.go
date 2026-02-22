// Package recursion 提供递归分析功能
package recursion

import (
	"cuteify/parser"
	"fmt"
)

// AnalyzeRecursionType 分析函数的递归类型
// 返回详细的递归分析结果
func AnalyzeRecursionType(funcNode *parser.Node) *RecursionInfo {
	if funcNode == nil {
		return &RecursionInfo{Type: NoRecursion, IsRecursive: false}
	}

	funcBlock, ok := funcNode.Value.(*parser.FuncBlock)
	if !ok {
		return &RecursionInfo{Type: NoRecursion, IsRecursive: false}
	}

	info := &RecursionInfo{
		Type:            NoRecursion,
		IsRecursive:     false,
		RecursiveCalls:  []*parser.Node{},
		BaseCaseNodes:   []*parser.Node{},
		RecursiveParams: []string{},
		LoopBody:        []*parser.Node{},
		LoopInit:        []*parser.Node{},
		LoopUpdate:      []*parser.Node{},
	}

	// 1. 收集函数体中所有的函数调用
	collectRecursiveCalls(funcNode, funcBlock.Name.String(), info)

	if len(info.RecursiveCalls) == 0 {
		return info // 不是递归函数
	}

	info.IsRecursive = true

	// 2. 分析递归类型
	info.Type = classifyRecursionType(funcNode, info)

	// 3. 提取基本情况
	extractBaseCases(funcNode, info)

	// 4. 提取递归参数
	extractRecursiveParams(funcNode, info)

	return info
}

// classifyRecursionType 分类递归类型
func classifyRecursionType(funcNode *parser.Node, info *RecursionInfo) RecursionType {
	if len(info.RecursiveCalls) == 0 {
		return NoRecursion
	}

	// 1. 检查是否是尾递归
	if isTailRecursion(funcNode, info) {
		return TailRecursive
	}

	// 2. 检查是否是相互递归
	if isMutualRecursion(funcNode, info) {
		return MutualRecursive
	}

	// 3. 根据递归调用数量和模式分类
	callCount := len(info.RecursiveCalls)

	if callCount == 1 {
		// 单个递归调用
		return SimpleLinear
	} else if callCount == 2 {
		// 两个递归调用，检查是否是双递归（如 fibonacci）
		if isDoubleRecursion(funcNode, info) {
			return DoubleRecursion
		}
		return GeneralRecursive
	} else if callCount > 2 {
		// 多个递归调用，可能是树递归
		if isTreeRecursion(funcNode, info) {
			return TreeRecursion
		}
		return GeneralRecursive
	}

	// 检查嵌套递归（如 ackermann）
	if isNestedRecursion(funcNode, info) {
		return NestedRecursive
	}

	return GeneralRecursive
}

// TransformRecursionToIteration 将递归函数转换为迭代器
// 支持所有类型的递归转换
func TransformRecursionToIteration(funcNode *parser.Node) *RecursionInfo {
	info := AnalyzeRecursionType(funcNode)
	if !info.IsRecursive {
		return info
	}

	// 根据递归类型选择转换策略
	switch info.Type {
	case TailRecursive:
		transformTailRecursion(funcNode, info)
	case SimpleLinear:
		transformSimpleLinear(funcNode, info)
	case DoubleRecursion:
		transformDoubleRecursion(funcNode, info)
	case MutualRecursive:
		transformMutualRecursion(funcNode, info)
	case NestedRecursive:
		transformNestedRecursion(funcNode, info)
	case TreeRecursion:
		transformTreeRecursion(funcNode, info)
	case GeneralRecursive:
		fmt.Printf("Warning: General recursion not yet supported\n")
	default:
		fmt.Printf("Warning: Unknown recursion type\n")
	}

	return info
}

// GetRecursionTypeString 获取递归类型的字符串表示
func GetRecursionTypeString(rType RecursionType) string {
	switch rType {
	case NoRecursion:
		return "No Recursion"
	case SimpleLinear:
		return "Simple Linear Recursion (factorial, gcd)"
	case DoubleRecursion:
		return "Double Recursion (fibonacci)"
	case TailRecursive:
		return "Tail Recursive"
	case MutualRecursive:
		return "Mutual Recursive"
	case NestedRecursive:
		return "Nested Recursive (ackermann)"
	case TreeRecursion:
		return "Tree Recursion (binary tree traversal)"
	case GeneralRecursive:
		return "General Recursive"
	default:
		return "Unknown"
	}
}

// PrintRecursionInfo 打印递归分析信息（用于调试）
func PrintRecursionInfo(info *RecursionInfo) {
	fmt.Printf("=== Recursion Analysis Result ===\n")
	fmt.Printf("Is Recursive: %v\n", info.IsRecursive)
	fmt.Printf("Recursion Type: %s\n", GetRecursionTypeString(info.Type))
	fmt.Printf("Number of Recursive Calls: %d\n", len(info.RecursiveCalls))
	fmt.Printf("Number of Base Cases: %d\n", len(info.BaseCaseNodes))
	fmt.Printf("Recursive Parameters: %v\n", info.RecursiveParams)
	fmt.Printf("Loop Variable: %s\n", info.LoopVar)
	fmt.Printf("===============================\n")
}
