package recursion

import (
	"cuteify/parser"
)

// RecursionType 递归类型
type RecursionType int

const (
	NoRecursion      RecursionType = iota // 非递归
	SimpleLinear                          // 简单线性递归 (factorial, gcd)
	DoubleRecursion                       // 双递归 (fibonacci)
	TailRecursive                         // 尾递归
	MutualRecursive                       // 相互递归
	NestedRecursive                       // 嵌套递归 (ackermann)
	TreeRecursion                         // 树递归 (二叉树遍历)
	GeneralRecursive                      // 一般递归
)

// RecursionPattern 递归模式
type RecursionPattern struct {
	Type           RecursionType
	IsTail         bool
	HasAccumulator bool
	CallCount      int // 递归调用次数
	Params         []string
	Report         string
}

// DetectRecursionPattern 检测递归模式
func DetectRecursionPattern(funcNode *parser.Node, visited map[string]bool) *RecursionPattern {
	if funcNode == nil {
		return &RecursionPattern{
			Type:   NoRecursion,
			Report: "无效的函数节点",
		}
	}

	funcBlock, ok := funcNode.Value.(*parser.FuncBlock)
	if !ok {
		return &RecursionPattern{
			Type:   NoRecursion,
			Report: "节点不是函数定义",
		}
	}

	// 防止相互递归的无限循环
	if visited == nil {
		visited = make(map[string]bool)
	}
	if visited[funcBlock.Name] {
		return &RecursionPattern{
			Type:   NoRecursion,
			Report: "循环依赖，已访问过此函数",
		}
	}
	visited[funcBlock.Name] = true

	pattern := &RecursionPattern{
		Params: make([]string, len(funcBlock.Args)),
	}
	for i, arg := range funcBlock.Args {
		pattern.Params[i] = arg.Name
	}

	// 统计递归调用
	pattern.CallCount = countRecursiveCallsInNode(funcNode, funcBlock.Name)

	// 检测尾递归
	pattern.IsTail = checkIsTailRecursive(funcNode, funcBlock.Name)

	// 检测累加器模式
	pattern.HasAccumulator = checkAccumulatorPattern(funcNode, pattern.Params)

	// 检测递归类型
	switch pattern.CallCount {
	case 0:
		pattern.Type = NoRecursion
		pattern.Report = "非递归函数"
	case 1:
		pattern.Type = classifySingleRecursion(funcNode, pattern)
		// 如果是尾递归，优先标记为尾递归类型
		if pattern.IsTail {
			pattern.Type = TailRecursive
			pattern.Report = "尾递归，可以转换为循环"
		}
	default:
		pattern.Type = classifyMultipleRecursion(funcNode, pattern)
	}

	return pattern
}

// classifySingleRecursion 分类单次递归
func classifySingleRecursion(funcNode *parser.Node, pattern *RecursionPattern) RecursionType {
	// 检查是否是简单的线性递归
	if isSimpleLinear(funcNode) {
		pattern.Report = "简单线性递归（如 factorial），可以转换为简单循环"
		return SimpleLinear
	}

	// 检查是否是嵌套递归（递归参数本身是递归调用）
	if isNestedRecursion(funcNode) {
		pattern.Report = "嵌套递归（如 ackermann），需要使用栈来模拟递归"
		return NestedRecursive
	}

	pattern.Report = "一般线性递归，可以转换为循环"
	return GeneralRecursive
}

// classifyMultipleRecursion 分类多次递归
func classifyMultipleRecursion(funcNode *parser.Node, pattern *RecursionPattern) RecursionType {
	if pattern.CallCount == 2 {
		pattern.Report = "双递归（如 fibonacci），可以使用动态规划转换为迭代"
		return DoubleRecursion
	}

	// 检查是否是树递归
	if isTreeRecursion(funcNode) {
		pattern.Report = "树递归（如二叉树遍历），需要使用栈来模拟递归"
		return TreeRecursion
	}

	pattern.Report = "一般多递归，需要使用栈来模拟递归"
	return GeneralRecursive
}

// isSimpleLinear 检查是否是简单线性递归
// 例如：factorial(n) = n <= 1 ? 1 : n * factorial(n-1)
func isSimpleLinear(funcNode *parser.Node) bool {
	if funcNode == nil || len(funcNode.Children) == 0 {
		return false
	}

	// 检查是否有 if 语句
	for _, child := range funcNode.Children {
		if _, ok := child.Value.(*parser.IfBlock); ok {
			// 有 if 语句说明有条件判断和递归，是简单线性递归的特征
			return true
		}
	}

	// 如果没有 if 语句但有递归调用，也可能是简单线性递归
	funcBlock, _ := funcNode.Value.(*parser.FuncBlock)
	if funcBlock != nil {
		count := countRecursiveCallsInNode(funcNode, funcBlock.Name)
		return count == 1
	}

	return false
}

// isNestedRecursion 检查是否是嵌套递归
// 例如：ackermann(m, n) = m == 0 ? n+1 : n == 0 ? ackermann(m-1, 1) : ackermann(m-1, ackermann(m, n-1))
func isNestedRecursion(funcNode *parser.Node) bool {
	if funcNode == nil {
		return false
	}

	// 检查递归调用中是否嵌套了另一个递归调用
	for _, child := range funcNode.Children {
		if hasNestedCall(child, funcNode) {
			return true
		}
	}

	return false
}

// hasNestedCall 检查是否有嵌套调用
func hasNestedCall(node *parser.Node, funcNode *parser.Node) bool {
	if node == nil {
		return false
	}

	switch v := node.Value.(type) {
	case *parser.Expression:
		if v.Call != nil && v.Call.Func != nil {
			// 检查参数中是否有另一个调用
			for _, arg := range v.Call.Args {
				if arg != nil && arg.Value != nil {
					// 检查参数值是否是函数调用
					if arg.Value.Call != nil {
						return true
					}
				}
			}
		}
	}

	for _, child := range node.Children {
		if hasNestedCall(child, funcNode) {
			return true
		}
	}

	return false
}

// isTreeRecursion 检查是否是树递归
// 树递归通常有多个递归调用，且在不同分支中
func isTreeRecursion(funcNode *parser.Node) bool {
	if funcNode == nil {
		return false
	}

	// 检查是否有多个 if/else 分支，每个分支都有递归调用
	ifBlockCount := 0
	for _, child := range funcNode.Children {
		if _, ok := child.Value.(*parser.IfBlock); ok {
			ifBlockCount++
		}
	}

	return ifBlockCount > 1
}

// checkIsTailRecursive 检查是否是尾递归
func checkIsTailRecursive(funcNode *parser.Node, funcName string) bool {
	if funcNode == nil {
		return false
	}

	// 递归遍历所有节点，查找 ReturnBlock
	return checkTailRecursiveInNode(funcNode, funcName)
}

// checkTailRecursiveInNode 在节点中检查尾递归
func checkTailRecursiveInNode(node *parser.Node, funcName string) bool {
	if node == nil {
		return false
	}

	// 检查当前节点
	switch v := node.Value.(type) {
	case *parser.ReturnBlock:
		if len(v.Value) > 0 {
			// 检查 return 的值是否直接是递归调用
			if isTailCall(v.Value[0], funcName) {
				return true
			}
		}
	case *parser.IfBlock:
		// 检查 if 块的 else 部分
		if v.Else && v.ElseBlock != nil {
			if checkTailRecursiveInNode(v.ElseBlock, funcName) {
				return true
			}
		}
	}

	// 递归检查子节点
	for _, child := range node.Children {
		if checkTailRecursiveInNode(child, funcName) {
			return true
		}
	}

	return false
}

// isTailCall 检查表达式是否是尾调用
func isTailCall(expr *parser.Expression, funcName string) bool {
	if expr == nil {
		return false
	}

	// 如果表达式是函数调用，检查是否是递归调用
	if expr.Call != nil && expr.Call.Func != nil {
		return expr.Call.Func.Name == funcName
	}

	return false
}

// checkAccumulatorPattern 检查累加器模式
func checkAccumulatorPattern(funcNode *parser.Node, params []string) bool {
	if len(params) < 2 {
		return false
	}

	// 检查第二个参数是否在递归调用中被更新
	// 这里简化实现
	return true
}

// countRecursiveCallsInNode 统计节点中的递归调用次数
func countRecursiveCallsInNode(node *parser.Node, funcName string) int {
	count := 0
	countRecursiveCallsByName(node, funcName, &count)
	return count
}

// countRecursiveCallsByName 按函数名统计递归调用
func countRecursiveCallsByName(node *parser.Node, funcName string, count *int) {
	if node == nil {
		return
	}

	switch v := node.Value.(type) {
	case *parser.Expression:
		// 检查当前表达式是否有函数调用
		if v.Call != nil && v.Call.Func != nil && v.Call.Func.Name == funcName {
			*count++
		}
		// 检查左子表达式
		if v.Left != nil {
			countRecursiveCallsByExp(v.Left, funcName, count)
		}
		// 检查右子表达式
		if v.Right != nil {
			countRecursiveCallsByExp(v.Right, funcName, count)
		}
	case *parser.ReturnBlock:
		// 检查 return 语句中的表达式
		for _, exp := range v.Value {
			countRecursiveCallsByExp(exp, funcName, count)
		}
	case *parser.IfBlock:
		// 检查条件表达式
		if v.Condition != nil {
			countRecursiveCallsByExp(v.Condition, funcName, count)
		}
		// If 的 body 在子节点中
		if v.Else && v.ElseBlock != nil {
			countRecursiveCallsByName(v.ElseBlock, funcName, count)
		}
	}

	// 递归检查子节点
	for _, child := range node.Children {
		countRecursiveCallsByName(child, funcName, count)
	}
}

// countRecursiveCallsByExp 在表达式中统计递归调用
func countRecursiveCallsByExp(exp *parser.Expression, funcName string, count *int) {
	if exp == nil {
		return
	}

	// 检查当前表达式是否有函数调用
	if exp.Call != nil && exp.Call.Func != nil && exp.Call.Func.Name == funcName {
		*count++
	}

	// 递归检查左子表达式
	if exp.Left != nil {
		countRecursiveCallsByExp(exp.Left, funcName, count)
	}

	// 递归检查右子表达式
	if exp.Right != nil {
		countRecursiveCallsByExp(exp.Right, funcName, count)
	}
}
