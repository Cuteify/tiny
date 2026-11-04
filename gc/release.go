// gc/release.go — 释放点：在哪 free
//
// 一行公式，没有例外：释放点 = 全部绑定名里最外层的作用域。
// 纯作用域规则，不看引用计数。没有绑定名时按顺序退：
// 字段 cascade（只被容器字段持有）→ 创建者兜底（从未改绑且活到函数出口）
// → 放弃释放。宁可漏释放，绝不 free 错块。

package gc

import "cuteify/parser"

// scopeRelease 释放点 = 全部绑定名里最外层的作用域，只向外放（分支里的局部名
// 把释放点推向外层，不会反过来）。引用计数只用于“就地释放”那一个问题：
// 多个引用时改其中一个要不要 free，作用域规则答不了。
func (a *analysis) scopeRelease() {
	for _, o := range a.objects {
		if o.Inplace || o.FieldOwner != nil || o.Escapes || o.Transferred {
			continue
		}
		// 释放点 = 全部绑定名里最外层的作用域。
		var widest parser.Block
		for _, n := range o.Names {
			if n == nil || a.state(n).scope == nil {
				continue
			}
			widest = outerScope(widest, a.state(n).scope)
		}
		if widest != nil {
			o.FreeScope = widest
			// 读槽：创建者被改绑时换成仍持它的名字，否则 free 错块。
			// 还必须活到释放点：分支里声明的名字在函数出口已经失效。
			if o.Holder == nil || !containsName(o.Names, o.Holder) || !a.holderLivesTo(o.Holder, widest) {
				o.Holder = a.firstLiveName(o, widest)
			}
			if o.Holder == nil {
				// 没有任何名字活到释放点：放弃释放，避免读错槽。
				o.FreeScope = nil
			}
			continue
		}
		// 兜底只认“创建后从未改绑、且活到函数出口”的创建者槽。
		// 改绑过的槽此刻可能指向别的对象；函数内层声明的槽在出口已失效。
		// 两种情况都宁可不设释放点（漏释放），也绝不 free 错块。
		fb := funcOfBlock(o.Scope)
		if fb == nil || o.Owner == nil {
			continue
		}
		if a.state(o.Owner).obj == o && a.state(o.Owner).scope == fb {
			o.FreeScope, o.Holder = fb, o.Owner
		}
	}
	a.fieldRelease()
}

// fieldRelease 字段 cascade：只被容器字段持有、没有任何变量名的对象，
// 在容器释放点先 free 容器.字段。必须在 scopeRelease 之后跑：容器自己
// 先有确定的释放点，字段值才有地方挂。
//
// 保守约束（任何一条不满足就不挂，宁可漏释放）：
//   - 只认恰好一个字段引用；
//   - 容器必须已经有释放点（作用域，或递归地只被字段持有）；
//   - 容器读槽必须有效；
//   - 不形成 FieldOwner 环。
func (a *analysis) fieldRelease() {
	type fieldRef struct {
		container *Object
		field     string
	}
	refs := map[*Object][]fieldRef{}
	for _, c := range a.objects {
		for _, fb := range c.FieldVals {
			if fb.Obj == nil || fb.Obj == c {
				continue
			}
			refs[fb.Obj] = append(refs[fb.Obj], fieldRef{container: c, field: fb.Field})
		}
	}

	for changed := true; changed; {
		changed = false
		for _, o := range a.objects {
			if o.Inplace || o.Escapes || o.Transferred || o.FreeScope != nil || o.FieldOwner != nil || len(o.Names) > 0 {
				continue
			}
			rs := refs[o]
			if len(rs) != 1 {
				continue
			}
			c := rs[0].container
			if a.fieldRoot(c) == nil {
				continue
			}
			if a.fieldChainContains(c, o) {
				continue // 字段关系成环，放弃
			}
			o.FieldOwner = c
			o.FieldName = rs[0].field
			changed = true
		}
	}
}

// fieldRoot 字段链最顶端的容器：必须已经按作用域释放，且读槽仍持有它。
func (a *analysis) fieldRoot(o *Object) *Object {
	seen := 0
	for o != nil && o.FieldOwner != nil {
		o = o.FieldOwner
		if seen++; seen > len(a.objects) {
			return nil
		}
	}
	if o == nil || o.Inplace || o.FreeScope == nil {
		return nil
	}
	// 字段 cascade 读的是“容器.字段”，必须证明这个槽在释放点确定还持有
	// 该容器：Holder 就是它、且没有第二个名字（分支合流/别名会让同一个
	// 槽在不同路径指向不同容器，盲读字段会 free 错对象）。
	if o.Holder == nil || a.state(o.Holder).obj != o || a.uniqueNameCount(o) != 1 {
		return nil
	}
	return o
}

// uniqueNameCount 绑定名去重计数（wroteTo 可能重复追加同一个左值）。
func (a *analysis) uniqueNameCount(o *Object) int {
	seen := map[*parser.VarBlock]bool{}
	n := 0
	for _, name := range o.Names {
		if name != nil && !seen[name] {
			seen[name] = true
			n++
		}
	}
	return n
}

// fieldChainContains 从 o 沿 FieldOwner 向上找 target，防止字段关系成环。
func (a *analysis) fieldChainContains(o, target *Object) bool {
	for n := 0; o != nil && n <= len(a.objects); n++ {
		if o == target {
			return true
		}
		o = o.FieldOwner
	}
	return false
}

func containsName(ns []*parser.VarBlock, v *parser.VarBlock) bool {
	for _, n := range ns {
		if n == v {
			return true
		}
	}
	return false
}

// firstLiveName 挑一个仍持有该对象、且活到释放点的绑定名当读槽来源。
func (a *analysis) firstLiveName(o *Object, scope parser.Block) *parser.VarBlock {
	for _, n := range o.Names {
		if n != nil && !a.state(n).escapes && a.holderLivesTo(n, scope) {
			return n
		}
	}
	return nil
}

// holderLivesTo v 的作用域是否不早于释放点失效（深度越小活得越久）。
func (a *analysis) holderLivesTo(v *parser.VarBlock, scope parser.Block) bool {
	if v == nil || a.state(v).scope == nil || scope == nil {
		return false
	}
	return scopeDepth(a.state(v).scope) <= scopeDepth(scope)
}
