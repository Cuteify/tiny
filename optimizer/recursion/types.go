// Package recursion 提供递归分析功能
package recursion

import (
	"cuteify/parser"
)

// RecursionType 递归类型枚举
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

// RecursionInfo 递归分析结果
type RecursionInfo struct {
	Type             RecursionType      // 递归类型
	IsRecursive      bool               // 是否递归
	RecursiveCalls   []*parser.Node     // 所有递归调用点
	TailCallPosition int                // 尾递归调用位置（-1表示不是尾递归）
	BaseCaseNodes    []*parser.Node     // 基本情况的节点
	RecursiveParams  []string           // 递归参数（在递归调用中变化的参数）
	LoopVar          string             // 转换为迭代时的循环变量
	LoopCond         *parser.Expression // 循环条件
	LoopBody         []*parser.Node     // 循环体
	LoopInit         []*parser.Node     // 循环初始化语句
	LoopUpdate       []*parser.Node     // 循环更新语句
}
