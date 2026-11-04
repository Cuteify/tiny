// parser/gc_names.go — 绑定名反转与作用域工具
//
// Check 期只记正向事实，"对象当前被哪些名字指着"在这里一次反转出来。
// 关键是 WroteTo 记在**右值**上：if c { result = n1 } else { result = n2 }
// 两个都算持有者，不需要路径签名；代价是顺序覆盖也算持有，释放点偏外
// —— 偏外是安全方向。

package parser

// walkSubNodes 深度优先下钻整棵子树（含 else 分支，见 eachSubNode）。
// 显式栈替代递归：先压 else、再反向压 Children，出栈序与递归版完全一致
// —— collectNames 的树序（lives / WroteTo 补边 / Names 顺序）依赖它。
func walkSubNodes(root *Node, fn func(n *Node)) {
	if root == nil {
		return
	}
	stack := []*Node{root}
	for len(stack) > 0 {
		n := stack[len(stack)-1]
		stack = stack[:len(stack)-1]
		fn(n)
		// 先压 else 再反向压 Children：出栈序 = Children 顺序、else 最后
		if ib, ok := n.Value.(*IfBlock); ok && ib.ElseBlock != nil {
			stack = append(stack, ib.ElseBlock)
		}
		for i := len(n.Children) - 1; i >= 0; i-- {
			if c := n.Children[i]; c != nil {
				stack = append(stack, c)
			}
		}
	}
}

// CollectNames 反转"变量 → 对象"，得到 Object.Names。Check 期因此不需要
// 撤销逻辑：重绑只是覆盖，反向表建一次不增量维护。
//
// 必须在 Check 收敛后、gcfe 的就地释放模拟之前调用。它同时补全 blockNode
// 反向索引，故不能搬到 parser 包外。
func CollectNames(root *Node) {
	// 建反向索引 + 反转绑定名。顺带补全 blockNode（建树有几处绕过 AddChild）。
	names := map[*Object][]*VarBlock{} // 对象 → 当前指向它的全部名字
	var lives []*VarBlock              // 参与反转的 Life 宿主，按树序
	walkSubNodes(root, func(n *Node) {
		if n.Value != nil {
			blockNode[n.Value] = n
		}
		v, ok := n.Value.(*VarBlock)
		if !ok || v == nil {
			return
		}
		lives = append(lives, v)
		if v.Life.Obj != nil {
			names[v.Life.Obj] = append(names[v.Life.Obj], v)
		}
	})
	// 补写站点的 WroteTo 边：右值记下的左值也是持有者（分支赋值因此天然
	// 正确）；代价是顺序覆盖也算持有，释放点偏外 —— 偏外安全。
	for _, v := range lives {
		o := v.Life.Obj
		if o == nil {
			continue
		}
		for _, lhs := range v.Life.WroteTo {
			if lhs != nil {
				names[o] = append(names[o], lhs)
			}
		}
	}
	for o, ns := range names {
		o.Names = ns
	}

	// 收尾：名字的逃逸汇总到对象。
	for _, o := range objects {
		if o.Escapes {
			continue
		}
		for _, n := range o.Names {
			if n != nil && n.Life.Escapes {
				o.Escapes = true
				break
			}
		}
	}

	// 字段关系收敛：同一字段只留最后一次写入。值变量改绑不再丢弃绑定：
	// 字段释放读的是“容器.字段”，不是 Val 的栈槽；只把 Val 标记为 Stale，
	// 提醒后续消费者不要拿它当读槽（读它可能 free 错对象）。
	for _, o := range objects {
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
			fb.Stale = fb.Val == nil || fb.Val.Life.Obj != fb.Obj
			out = append(out, fb)
		}
		o.FieldVals = out
	}
}
