// Package recursion 提供递归分析功能
package recursion

import (
	"cuteify/parser"
)

// isTreeRecursion 检查是否是树递归（如二叉树遍历）
// 树递归：多个递归调用处理左右子树
// 例如: traverse(node) { traverse(node.left); traverse(node.right); }
func isTreeRecursion(funcNode *parser.Node, info *RecursionInfo) bool {
	if len(info.RecursiveCalls) < 2 {
		return false
	}

	// 树递归的特点：递归调用在不同的分支中（通常是顺序执行的独立语句）
	// 而不是通过运算符连接（那通常是双递归）

	// 检查所有递归调用对
	for i := 0; i < len(info.RecursiveCalls); i++ {
		for j := i + 1; j < len(info.RecursiveCalls); j++ {
			call1 := info.RecursiveCalls[i]
			call2 := info.RecursiveCalls[j]

			// 如果两个调用是兄弟节点（在同一层级），且不是运算符连接
			if call1.Father != nil && call1.Father == call2.Father {
				// 如果父节点是表达式但不是二元运算，可能是树递归
				if _, ok := call1.Father.Value.(*parser.Expression); !ok {
					// 父节点不是表达式，而是语句块，是树递归
					return true
				}
			}
		}
	}

	return false
}

// transformTreeRecursion 转换树递归为迭代
// 需要使用显式栈来模拟递归调用栈
func transformTreeRecursion(funcNode *parser.Node, info *RecursionInfo) {
	// 树递归需要显式栈来模拟递归
	// 这里暂时不做实际转换
}
