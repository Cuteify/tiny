// gcfe/release.go — 释放点：在哪 free
//
// 一行公式，没有例外：释放点 = 全部绑定名里最外层的作用域。
// 纯作用域规则，不看引用计数；算不出（无绑定名 / 只被字段读引用）就兜底到
// 所属函数出口，保证绝不泄漏。

package gcfe

import "cuteify/parser"

// scopeRelease 释放点 = 全部绑定名里最外层的作用域，只向外放（分支里的局部名
// 把释放点推向外层，不会反过来）。引用计数只用于"就地释放"那一个问题：
// 多个引用时改其中一个要不要 free，作用域规则答不了。
func scopeRelease() {
	for _, o := range parser.Objects() {
		if o.Escapes || o.Transferred {
			continue
		}
		// 释放点 = 全部绑定名里最外层的作用域。
		var widest parser.Block
		for _, n := range o.Names {
			if n == nil || n.Life.Scope == nil {
				continue
			}
			widest = outerScope(widest, n.Life.Scope)
		}
		if widest != nil {
			o.FreeScope = widest
			// 读槽：创建者被改绑时换成仍持它的名字，否则 free 错块。
			if o.Holder == nil || !containsName(o.Names, o.Holder) {
				o.Holder = firstLiveName(o)
			}
			continue
		}
		// 兜底：函数出口 + 读创建者的槽。改绑过也只会漏释放，不会 free 错块。
		if fb := funcOfBlock(o.Scope); fb != nil && o.Owner != nil {
			o.FreeScope, o.Holder = fb, o.Owner
		}
	}
}

func containsName(ns []*parser.VarBlock, v *parser.VarBlock) bool {
	for _, n := range ns {
		if n == v {
			return true
		}
	}
	return false
}

// firstLiveName 挑一个仍持有该对象的绑定名当释放时的读槽来源。
func firstLiveName(o *parser.Object) *parser.VarBlock {
	for _, n := range o.Names {
		if n != nil && !n.Life.Escapes {
			return n
		}
	}
	return nil
}
