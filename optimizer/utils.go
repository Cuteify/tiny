// Package optimizer 提供编译器优化工具集
package optimizer

import (
	"fmt"
	"strings"

	"cuteify/parser"
)

// RecursionType 递归类型
type RecursionType int

const (
	NoRecursion       RecursionType = iota // 非递归
	DirectRecursion                        // 直接递归
	IndirectRecursion                      // 间接递归
	MutualRecursion                        // 互递归
)

// RecursionInfo 递归检测信息
type RecursionInfo struct {
	IsRecursive     bool          // 是否递归
	RecursionType   RecursionType // 递归类型
	CallDepth       int           // 最大调用深度
	HasTermination  bool          // 是否有终止条件
	DepthControlled bool          // 深度是否可控
	CallChain       []string      // 调用链（用于间接递归）
	TerminationLine string        // 终止条件所在行
	Report          string        // 分析报告
}

// DetectRecursion 检测函数是否递归
// 输入: funcNode - 函数定义所在的 AST 节点
//
//	callGraph - 可选，函数调用图（用于间接递归检测）
//
// 输出: RecursionInfo - 递归检测信息
func DetectRecursion(funcNode *parser.Node, callGraph map[string][]string) *RecursionInfo {
	if funcNode == nil {
		return &RecursionInfo{
			IsRecursive:   false,
			RecursionType: NoRecursion,
			Report:        "错误: 无效的函数节点",
		}
	}

	// 类型断言获取 FuncBlock
	funcBlock, ok := funcNode.Value.(*parser.FuncBlock)
	if !ok {
		return &RecursionInfo{
			IsRecursive:   false,
			RecursionType: NoRecursion,
			Report:        "错误: 节点不是函数定义",
		}
	}

	funcName := funcBlock.Name
	result := &RecursionInfo{
		RecursionType: NoRecursion,
		CallDepth:     0,
		CallChain:     []string{},
	}

	// 1. 检测直接递归
	if hasDirectRecursiveCall(funcNode, funcName) {
		result.IsRecursive = true
		result.RecursionType = DirectRecursion
		result.CallChain = []string{funcName}
	} else if callGraph != nil {
		// 2. 检测间接递归
		if path := findRecursivePath(callGraph, funcName); path != nil {
			result.IsRecursive = true
			result.RecursionType = IndirectRecursion
			result.CallChain = path
			result.CallDepth = len(path)
		}
	}

	// 3. 如果检测到递归，分析终止条件和深度可控性
	if result.IsRecursive {
		termination := findTerminationCondition(funcNode)
		result.HasTermination = termination.found
		result.TerminationLine = termination.line
		result.DepthControlled = analyzeDepthControlled(funcNode, termination.found)

		// 生成报告
		result.Report = generateReport(funcName, result)
	} else {
		result.Report = fmt.Sprintf("函数 '%s' 不是递归函数", funcName)
	}

	return result
}

// terminationCondition 终止条件信息
type terminationCondition struct {
	found bool
	line  string
}

// hasDirectRecursiveCall 检测函数体内是否有直接调用自身
func hasDirectRecursiveCall(funcNode *parser.Node, funcName string) bool {
	// 遍历函数体的所有子节点
	for _, child := range funcNode.Children {
		if hasCallInNode(child, funcName) {
			return true
		}
	}

	return false
}

// hasCallInNode 在节点及其子节点中查找函数调用
func hasCallInNode(node *parser.Node, funcName string) bool {
	if node == nil {
		return false
	}

	// 检查当前节点的 Value 类型
	switch v := node.Value.(type) {
	case *parser.Expression:
		if hasCallInExp(v, funcName) {
			return true
		}
	case *parser.ReturnBlock:
		for _, exp := range v.Value {
			if hasCallInExp(exp, funcName) {
				return true
			}
		}
	case *parser.IfBlock:
		// If 的 body 在子节点中，ElseBlock 是另一个节点
		for _, child := range node.Children {
			if hasCallInNode(child, funcName) {
				return true
			}
		}
		if v.Else && v.ElseBlock != nil {
			if hasCallInNode(v.ElseBlock, funcName) {
				return true
			}
		}
	}

	// 递归检查子节点
	for _, child := range node.Children {
		if hasCallInNode(child, funcName) {
			return true
		}
	}

	return false
}

// hasCallInExp 在表达式中查找函数调用
func hasCallInExp(exp *parser.Expression, funcName string) bool {
	if exp == nil {
		return false
	}

	// 检查当前表达式是否有函数调用
	if exp.Call != nil && exp.Call.Func != nil && exp.Call.Func.Name == funcName {
		return true
	}

	// 递归检查左子表达式
	if exp.Left != nil && hasCallInExp(exp.Left, funcName) {
		return true
	}

	// 递归检查右子表达式
	if exp.Right != nil && hasCallInExp(exp.Right, funcName) {
		return true
	}

	return false
}

// findRecursivePath 在调用图中查找递归路径
func findRecursivePath(callGraph map[string][]string, startFunc string) []string {
	if callGraph == nil {
		return nil
	}

	visited := make(map[string]bool)
	maxDepth := 20 // 最大递归深度限制
	path := []string{}

	// DFS 查找回到起点的路径
	if dfsFindPath(callGraph, startFunc, startFunc, visited, &path, 0, maxDepth) {
		return path
	}

	return nil
}

// dfsFindPath DFS 查找递归路径
func dfsFindPath(callGraph map[string][]string, current, target string, visited map[string]bool, path *[]string, depth, maxDepth int) bool {
	if depth > maxDepth {
		return false
	}

	// 记录路径
	*path = append(*path, current)

	// 检查当前节点是否调用目标函数
	for _, calledFunc := range callGraph[current] {
		if calledFunc == target && depth > 0 {
			*path = append(*path, target)
			return true
		}

		// 继续深度优先搜索
		if !visited[calledFunc] {
			visited[calledFunc] = true
			if dfsFindPath(callGraph, calledFunc, target, visited, path, depth+1, maxDepth) {
				return true
			}
		}
	}

	// 回溯
	if len(*path) > 0 {
		*path = (*path)[:len(*path)-1]
	}

	return false
}

// findTerminationCondition 查找递归终止条件
func findTerminationCondition(funcNode *parser.Node) terminationCondition {
	// 遍历子节点，查找 return 语句前是否有条件判断
	for _, child := range funcNode.Children {
		if termination := findTerminationInNode(child); termination.found {
			return termination
		}
	}

	return terminationCondition{found: false}
}

// findTerminationInNode 在节点中查找终止条件
func findTerminationInNode(node *parser.Node) terminationCondition {
	if node == nil {
		return terminationCondition{found: false}
	}

	// 检查 If 语句中是否有 return
	if _, ok := node.Value.(*parser.IfBlock); ok {
		if hasReturnInChildren(node) {
			return terminationCondition{
				found: true,
				line:  "found",
			}
		}
	}

	// 递归检查子节点
	for _, child := range node.Children {
		if termination := findTerminationInNode(child); termination.found {
			return termination
		}
	}

	return terminationCondition{found: false}
}

// hasReturnInChildren 检查节点的子节点中是否有 return 语句
func hasReturnInChildren(node *parser.Node) bool {
	if node == nil {
		return false
	}

	// 遍历子节点查找 Return
	for _, child := range node.Children {
		if _, ok := child.Value.(*parser.ReturnBlock); ok {
			return true
		}
		if hasReturnInChildren(child) {
			return true
		}
	}

	return false
}

// analyzeDepthControlled 分析调用栈深度是否可控
func analyzeDepthControlled(_ *parser.Node, hasTermination bool) bool {
	if !hasTermination {
		return false
	}

	// 简单策略：如果有终止条件，认为深度可控
	return true
}

// generateReport 生成分析报告
func generateReport(funcName string, info *RecursionInfo) string {
	var sb strings.Builder

	sb.WriteString("=== 递归检测报告 ===\n")
	sb.WriteString(fmt.Sprintf("函数名: %s\n", funcName))
	sb.WriteString(fmt.Sprintf("递归类型: %s\n", recursionTypeToString(info.RecursionType)))
	sb.WriteString(fmt.Sprintf("最大深度: %d\n", info.CallDepth))
	sb.WriteString(fmt.Sprintf("有终止条件: %v\n", info.HasTermination))
	sb.WriteString(fmt.Sprintf("深度可控: %v\n", info.DepthControlled))

	if len(info.CallChain) > 0 {
		sb.WriteString(fmt.Sprintf("调用链: %s\n", strings.Join(info.CallChain, " -> ")))
	}

	if info.TerminationLine != "" {
		sb.WriteString(fmt.Sprintf("终止条件: %s\n", info.TerminationLine))
	}

	return sb.String()
}

// recursionTypeToString 递归类型转字符串
func recursionTypeToString(rt RecursionType) string {
	names := map[RecursionType]string{
		NoRecursion:       "非递归",
		DirectRecursion:   "直接递归",
		IndirectRecursion: "间接递归",
		MutualRecursion:   "互递归",
	}
	if name, ok := names[rt]; ok {
		return name
	}
	return "未知"
}

// BuildSimpleCallGraph 构建简单的函数调用图
// 输入: programNode - 程序根节点
// 输出: callGraph - 调用图映射 [函数名] -> [被调用函数列表]
func BuildSimpleCallGraph(programNode *parser.Node) map[string][]string {
	callGraph := make(map[string][]string)

	if programNode == nil {
		return callGraph
	}

	// 收集所有函数
	funcs := collectFunctions(programNode)

	// 为每个函数构建调用关系
	for _, fn := range funcs {
		if fn.Value == nil {
			continue
		}
		if funcBlock, ok := fn.Value.(*parser.FuncBlock); ok {
			funcName := funcBlock.Name
			calledFuncs := findCalledFunctions(fn)
			callGraph[funcName] = calledFuncs
		}
	}

	return callGraph
}

// collectFunctions 收集所有函数定义
func collectFunctions(root *parser.Node) []*parser.Node {
	var funcs []*parser.Node

	if root == nil {
		return funcs
	}

	// 如果当前节点是函数定义
	if _, ok := root.Value.(*parser.FuncBlock); ok {
		funcs = append(funcs, root)
	}

	// 递归收集子节点中的函数
	for _, child := range root.Children {
		funcs = append(funcs, collectFunctions(child)...)
	}

	return funcs
}

// findCalledFunctions 查找函数中调用的所有函数
func findCalledFunctions(funcNode *parser.Node) []string {
	var calledFuncs []string

	if funcNode == nil {
		return calledFuncs
	}

	// 遍历所有子节点
	for _, child := range funcNode.Children {
		calledFuncs = append(calledFuncs, findCalledFunctionsInNode(child)...)
	}

	// 去重
	return uniqueStrings(calledFuncs)
}

// findCalledFunctionsInNode 在节点中查找被调用的函数
func findCalledFunctionsInNode(node *parser.Node) []string {
	var calledFuncs []string

	if node == nil {
		return calledFuncs
	}

	// 检查当前节点的 Value 类型
	switch v := node.Value.(type) {
	case *parser.Expression:
		calledFuncs = append(calledFuncs, findCalledFunctionsInExp(v)...)
	case *parser.ReturnBlock:
		for _, exp := range v.Value {
			calledFuncs = append(calledFuncs, findCalledFunctionsInExp(exp)...)
		}
	case *parser.IfBlock:
		// If 的 body 在子节点中
		for _, child := range node.Children {
			calledFuncs = append(calledFuncs, findCalledFunctionsInNode(child)...)
		}
		if v.Else && v.ElseBlock != nil {
			calledFuncs = append(calledFuncs, findCalledFunctionsInNode(v.ElseBlock)...)
		}
	}

	// 递归检查子节点
	for _, child := range node.Children {
		calledFuncs = append(calledFuncs, findCalledFunctionsInNode(child)...)
	}

	return calledFuncs
}

// findCalledFunctionsInExp 在表达式中查找被调用的函数
func findCalledFunctionsInExp(exp *parser.Expression) []string {
	var calledFuncs []string

	if exp == nil {
		return calledFuncs
	}

	// 检查当前表达式是否有函数调用
	if exp.Call != nil && exp.Call.Func != nil {
		calledFuncs = append(calledFuncs, exp.Call.Func.Name)
	}

	// 递归检查左子表达式
	if exp.Left != nil {
		calledFuncs = append(calledFuncs, findCalledFunctionsInExp(exp.Left)...)
	}

	// 递归检查右子表达式
	if exp.Right != nil {
		calledFuncs = append(calledFuncs, findCalledFunctionsInExp(exp.Right)...)
	}

	return calledFuncs
}

// uniqueStrings 去重字符串列表
func uniqueStrings(strs []string) []string {
	seen := make(map[string]bool)
	result := []string{}

	for _, s := range strs {
		if !seen[s] {
			seen[s] = true
			result = append(result, s)
		}
	}

	return result
}
