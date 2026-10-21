// parser/gc_names.go — 绑定名反转与作用域工具
//
// Check 期只记正向事实，"对象当前被哪些名字指着"在这里一次反转出来。
// 关键是 WroteTo 记在**右值**上：if c { result = n1 } else { result = n2 }
// 两个都算持有者，不需要路径签名；代价是顺序覆盖也算持有，释放点偏外
// —— 偏外是安全方向。

package parser

// walkSubNodes 深度优先下钻整棵子树（含 else 分支，见 eachSubNode）。
func walkSubNodes(root *Node, fn func(n *Node)) {
	if root == nil {
		return
	}
	fn(root)
	eachSubNode(root, func(c *Node) { walkSubNodes(c, fn) })
}

// collectNames 反转"变量 → 对象"，得到 Object.Names。Check 期因此不需要
// 撤销逻辑：重绑只是覆盖，反向表建一次不增量维护。
func collectNames(root *Node) {
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

	// 字段关系收敛：同一字段只留最后一次写入；栈槽已改绑的跳过
	//（宁可漏释放，不能读错槽位）。
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
			if fb.Obj != nil && fb.Val.Life.Obj != fb.Obj {
				continue // 栈槽已被改绑，读它会 free 错对象
			}
			out = append(out, fb)
		}
		o.FieldVals = out
	}
}

// outerScope 取更外层的作用域（nil 表示未知）。深度按块的祖先链算，
// 靠 blockNode 索引反查节点。
func outerScope(a, b Block) Block {
	if a == nil {
		return b
	}
	if b == nil {
		return a
	}
	if scopeDepth(a) <= scopeDepth(b) {
		return a
	}
	return b
}

// scopeDepth 作用域的嵌套深度：函数体最浅，块体依次加深。
func scopeDepth(b Block) int {
	d := 0
	for ; b != nil; b = outerParent(b) {
		d++
	}
	return d
}

// outerParent 直接外层的作用域块（跳过不圈作用域的节点，如普通语句）。
func outerParent(b Block) Block {
	for n := BlockNode(b); n != nil && n.Father != nil; n = n.Father {
		if n.Father.Value != nil && isScopeBlock(n.Father.Value) {
			return n.Father.Value
		}
	}
	return nil
}
