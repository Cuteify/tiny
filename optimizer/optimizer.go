// Package optimizer 提供编译器优化功能
package optimizer

import (
	"cuteify/optimizer/recursion"
	"cuteify/parser"
)

// AnalyzeRecursion 分析递归
func AnalyzeRecursion(f *parser.Node) {
	_ = recursion.DetectRecursion(f, nil)
}

// OptimizeRecursion 优化递归函数
// 尝试将递归函数转换为迭代版本
func OptimizeRecursion(funcNode *parser.Node) {
	if funcNode == nil {
		return
	}

	_ = recursion.DetectRecursionPattern(funcNode, nil)
	_ = recursion.ConvertToIteration(funcNode)
}

// ConvertRecursionToIteration 直接转换递归为迭代
func ConvertRecursionToIteration(funcNode *parser.Node) bool {
	if funcNode == nil {
		return false
	}

	result := recursion.ConvertToIteration(funcNode)

	// 如果转换成功，替换原函数的 AST
	if result.CanConvert && result.ModifiedFunc != nil {
		if _, ok := funcNode.Value.(*parser.FuncBlock); ok {
			if _, ok := result.ModifiedFunc.Value.(*parser.FuncBlock); ok {
				funcNode.Children = result.ModifiedFunc.Children
				return true
			}
		}
	}

	return result.CanConvert
}

// OptimizeAllRecursions 优化程序中的所有递归函数
func OptimizeAllRecursions(programNode *parser.Node) {
	if programNode == nil {
		return
	}

	// 收集所有函数
	funcs := collectFuncNodes(programNode)

	for _, funcNode := range funcs {
		OptimizeRecursion(funcNode)
	}
}

// ConvertAllRecursions 转换所有递归函数
func ConvertAllRecursions(programNode *parser.Node) []bool {
	if programNode == nil {
		return nil
	}

	funcs := collectFuncNodes(programNode)
	results := make([]bool, len(funcs))

	for i, funcNode := range funcs {
		results[i] = ConvertRecursionToIteration(funcNode)
	}

	return results
}

// collectFuncNodes 收集所有函数节点
func collectFuncNodes(root *parser.Node) []*parser.Node {
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
		funcs = append(funcs, collectFuncNodes(child)...)
	}

	return funcs
}
