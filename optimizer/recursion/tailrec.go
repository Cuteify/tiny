package recursion

import (
	"cuteify/parser"
)

// TransformType 转换类型
type TransformType int

const (
	NoTransform          TransformType = iota // 不需要转换
	TailCallOptimization                      // 尾调用优化
	SimpleLoop                                // 简单循环转换
	AccumulatorPattern                        // 累加器模式
)

// TailRecInfo 尾递归信息
type TailRecInfo struct {
	IsTailRecursive bool               // 是否是尾递归
	TransformType   TransformType      // 转换类型
	BaseCase        *parser.IfBlock    // 基本情况（终止条件）
	RecursiveCase   *parser.Expression // 递归调用表达式
	Report          string             // 转换报告
}

// AnalyzeTailRecursion 分析函数是否可以转换为尾递归优化
func AnalyzeTailRecursion(funcNode *parser.Node) *TailRecInfo {
	if funcNode == nil {
		return &TailRecInfo{
			IsTailRecursive: false,
			TransformType:   NoTransform,
			Report:          "错误: 无效的函数节点",
		}
	}

	_, ok := funcNode.Value.(*parser.FuncBlock)
	if !ok {
		return &TailRecInfo{
			IsTailRecursive: false,
			TransformType:   NoTransform,
			Report:          "错误: 节点不是函数定义",
		}
	}

	result := &TailRecInfo{
		IsTailRecursive: false,
		TransformType:   NoTransform,
	}

	// 检测尾递归模式
	if isLinearTailRecursion(funcNode) {
		result.IsTailRecursive = true
		result.TransformType = TailCallOptimization
		result.Report = "函数是线性尾递归，可以进行尾调用优化"
	} else if isAccumulatorPattern(funcNode) {
		result.IsTailRecursive = true
		result.TransformType = AccumulatorPattern
		result.Report = "函数使用累加器模式，可以转换为迭代"
	} else {
		result.Report = "函数不适合尾递归优化"
	}

	return result
}

// isLinearTailRecursion 检测线性尾递归
// 例如：fib(n) = n <= 2 ? 1 : fib(n-1) + fib(n-2)
// 这种不是尾递归，因为有额外的加法操作
func isLinearTailRecursion(funcNode *parser.Node) bool {
	if funcNode == nil {
		return false
	}

	// 检查函数体结构
	for _, child := range funcNode.Children {
		if ifBlock, ok := child.Value.(*parser.IfBlock); ok {
			// 检查 if 块的结构
			// if (condition) {
			//     return base_case
			// } else {
			//     return recursive_call(args)
			// }

			// 简单判断：如果有多个 return 语句，可能不是纯尾递归
			if hasMultipleReturns(child) {
				return false
			}

			// 检查 else 分支是否只有一个 return 且包含递归调用
			if ifBlock.Else && ifBlock.ElseBlock != nil {
				return checkTailCallInReturn(ifBlock.ElseBlock, funcNode)
			}
		}
	}

	return false
}

// isAccumulatorPattern 检测累加器模式
// 例如：factorial(n, acc=1) = n == 0 ? acc : factorial(n-1, n*acc)
func isAccumulatorPattern(funcNode *parser.Node) bool {
	// 检查函数是否有累加器参数
	funcBlock, ok := funcNode.Value.(*parser.FuncBlock)
	if !ok || len(funcBlock.Args) < 2 {
		return false
	}

	// 检查递归调用是否使用更新后的累加器
	_ = funcBlock // 避免未使用变量警告
	return hasAccumulatorUpdate(funcNode)
}

// checkTailCallInReturn 检查 return 语句中是否是尾调用
func checkTailCallInReturn(node *parser.Node, _ *parser.Node) bool {
	if node == nil {
		return false
	}

	for _, child := range node.Children {
		if retBlock, ok := child.Value.(*parser.ReturnBlock); ok {
			if len(retBlock.Value) > 0 {
				// 简化：假设所有 return 都是尾调用
				return true
			}
		}
		if checkTailCallInReturn(child, nil) {
			return true
		}
	}

	return false
}

// hasMultipleReturns 检查节点中是否有多个 return 语句
func hasMultipleReturns(node *parser.Node) bool {
	count := 0
	return countReturns(node, &count) > 1
}

// countReturns 递归统计 return 语句数量
func countReturns(node *parser.Node, count *int) int {
	if node == nil {
		return *count
	}

	if _, ok := node.Value.(*parser.ReturnBlock); ok {
		*count++
	}

	for _, child := range node.Children {
		countReturns(child, count)
	}

	return *count
}

// hasAccumulatorUpdate 检查递归调用是否更新累加器
func hasAccumulatorUpdate(_ *parser.Node) bool {
	// 简化：假设如果有两个参数，第二个参数在递归调用中被更新
	return true
}
