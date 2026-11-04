// gc/names.go — 绑定名反转与作用域工具
//
// Check 后的事实只记正向，“对象当前被哪些名字指着”在这里一次反转出来。
// 关键是 wroteTo 记在**右值**上：if c { result = n1 } else { result = n2 }
// 两个都算持有者，不需要路径签名；代价是顺序覆盖也算持有，释放点偏外
// —— 偏外是安全方向。

package gc

import "cuteify/parser"

// walkSubNodes 深度优先下钻整棵子树（含 else 分支，见 parser.EachSubNode）。
// 显式栈替代递归：先压 else、再反向压 Children，出栈序与递归版完全一致
// —— collectNames 的树序（lives / wroteTo 补边 / Names 顺序）依赖它。
func walkSubNodes(root *parser.Node, fn func(n *parser.Node)) {
	if root == nil {
		return
	}
	stack := []*parser.Node{root}
	for len(stack) > 0 {
		n := stack[len(stack)-1]
		stack = stack[:len(stack)-1]
		fn(n)
		// 先压 else 再反向压 Children：出栈序 = Children 顺序、else 最后
		if ib, ok := n.Value.(*parser.IfBlock); ok && ib.ElseBlock != nil {
			stack = append(stack, ib.ElseBlock)
		}
		for i := len(n.Children) - 1; i >= 0; i-- {
			if c := n.Children[i]; c != nil {
				stack = append(stack, c)
			}
		}
	}
}

// collectNames 反转“变量 → 对象”，得到 Object.Names。事实收集只需要正向
// 覆盖写，重绑不撤销；反向表在这里建一次。
func (a *analysis) collectNames(root *parser.Node) {
	names := map[*Object][]*parser.VarBlock{} // 对象 → 当前指向它的全部名字
	var lives []*parser.VarBlock              // 参与反转的 binding 宿主，按树序
	walkSubNodes(root, func(n *parser.Node) {
		v, ok := n.Value.(*parser.VarBlock)
		if !ok || v == nil {
			return
		}
		lives = append(lives, v)
		if b := a.state(v); b.obj != nil {
			names[b.obj] = append(names[b.obj], v)
		}
	})
	// 补写站点的 wroteTo 边：右值记下的左值也是持有者（分支赋值因此天然
	// 正确）；代价是顺序覆盖也算持有，释放点偏外 —— 偏外安全。
	for _, v := range lives {
		b := a.state(v)
		if b.obj == nil {
			continue
		}
		for _, lhs := range b.wroteTo {
			if lhs != nil {
				names[b.obj] = append(names[b.obj], lhs)
			}
		}
	}
	for _, o := range a.objects {
		o.Names = names[o]
	}

	// 收尾：名字的逃逸汇总到对象。
	for _, o := range a.objects {
		if o.Escapes {
			continue
		}
		for _, n := range o.Names {
			if n != nil && a.state(n).escapes {
				o.Escapes = true
				break
			}
		}
	}

	// 字段关系收敛：同一字段只留最后一次写入。值变量改绑不再丢弃绑定：
	// 字段释放读的是“容器.字段”，不是 Val 的栈槽；只把 Val 标记为 Stale，
	// 提醒后续消费者不要拿它当读槽（读它可能 free 错对象）。
	for _, o := range a.objects {
		if len(o.FieldVals) == 0 {
			continue
		}
		last := map[string]int{}
		for i, fb := range o.FieldVals {
			last[fb.Field] = i
		}
		out := o.FieldVals[:0]
		for i, fb := range o.FieldVals {
			if last[fb.Field] != i {
				continue // 这个字段后来被覆盖了
			}
			fb.Stale = fb.Val == nil || a.state(fb.Val).obj != fb.Obj
			out = append(out, fb)
		}
		o.FieldVals = out
	}
}
