// Package gcfe 前端 GC 的驱动与计划构建（front-end GC）。
//
// 输入是完成包合并、Check 收敛之后的根 AST。数据模型（parser.Life /
// parser.Object）与 Check 期的事实收集仍留在 parser：Life 非导出字段
// （owner / alloc）是解析器内部账本，硬搬到包外会引入循环依赖与大面积
// API 暴露。这里只承载“Check 之后怎么走一遍树、怎么定释放点”的算法，
// 单向 import parser。
//
// 时序（必须在 package.GetPackage 的 Check 收敛后调用）：
//
//	CollectNames  → 反转绑定名、收敛字段关系、补 blockNode
//	rcSim.walk    → 按语句顺序模拟覆盖赋值，标记可就地释放的旧对象
//	scopeRelease  → 释放点 = 全部绑定名里最外层的作用域
//	checkPremature→ 校验释放点不早于任何绑定名的作用域
package gcfe

import "cuteify/parser"

// SimulateRC 唯一公开入口。必须在 Check 全部轮次结束后调用（要先知道谁逃逸）。
func SimulateRC(root *parser.Node) {
	s := &rcSim{
		slot:   map[*parser.VarBlock]*parser.Object{},
		fields: map[*parser.VarBlock]map[string]*parser.Object{},
	}
	// 两趟遍历：CollectNames 反转绑定名，walk 按语句顺序维护槽位表与就地判定。
	parser.CollectNames(root)
	s.walk(root)
	scopeRelease() // 释放点：作用域规则，算不出就兜底到所属函数出口
	checkPremature()
}
