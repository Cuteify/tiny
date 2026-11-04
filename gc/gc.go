// gc/gc.go — GC 分析的唯一入口。
//
// Analyze 把前端对象级分析与后端全程序摘要串成一条链，结果分别留在
// front（Objects / Stats / Plan）与 Table / LLRResults 里。调用前提是
// package.GetPackage 已完成包合并与 Check 收敛。
//
// 幂等：同一根 AST 重复调用直接命中缓存；换根（或测试重建 AST）时整体
// 重置，指针键不会跨分析复用。单进程单根包串行编译，与今天的模型一致。

package gc

import "cuteify/parser"

// analyzedRoot 最近一次完整分析的根 AST；nil 表示尚未分析。
var analyzedRoot *parser.Node

// Analyze 执行完整 GC 流水线：后置事实收集 → 五态计划 → 全程序摘要 → LLR。
// 必须在 Check 收敛之后调用；同一 root 重复调用是幂等的。
func Analyze(root *parser.Node) {
	if root == nil {
		return
	}
	if analyzedRoot == root {
		return
	}
	analyzedRoot = nil

	CollectFront(root)
	analyzeBackend(root)

	analyzedRoot = root
}
