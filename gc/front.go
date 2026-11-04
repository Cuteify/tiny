// gc/front.go — 前端 GC 后置分析的唯一入口。
//
// 输入是完成包合并、Check 收敛之后的根 AST。所有状态（binding / 对象 /
// 摘要缓存）都放在 gc 包内，parser 不再持有 GC 字段。
//
// 时序（必须在 package.GetPackage 的 Check 收敛后调用）：
//
//	RebuildBlockIndex → 补全 Block → Node 反向索引
//	collectFacts      → 按 Check 顺序收集正向事实
//	collectNames      → 反转绑定名、收敛字段关系
//	rcSim.walk        → 按语句顺序模拟覆盖赋值，标记可就地释放的旧对象
//	scopeRelease      → 释放点 = 全部绑定名里最外层的作用域
//	checkPremature    → 校验释放点不早于任何绑定名的作用域
package gc

import "cuteify/parser"

// CollectFront 跑完整条前端分析链，结果保存在包级 front，供诊断工具 /
// 计划的只读导出使用。不能与后端 LLR 的 Build 混用：LLR 是语句级模型，
// 这里是一次分配一个对象的对象级模型。
func CollectFront(root *parser.Node) {
	if root == nil {
		front = nil
		return
	}
	parser.RebuildBlockIndex(root)

	a := newAnalysis()
	a.collectFacts(root)
	a.collectNames(root)

	s := &rcSim{
		a:      a,
		slot:   map[*parser.VarBlock]*Object{},
		fields: map[*parser.VarBlock]map[string]*Object{},
	}
	s.walk(root)
	a.scopeRelease()
	a.checkPremature()
	front = a
}
