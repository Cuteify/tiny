// parser/gc_names.go — 绑定名反转与作用域工具
//
// Check 期只记了正向事实（Obj / WroteTo），"某个对象当前被哪些名字指着"
// 要在这里一次反转出来 —— Object.Names 就是那张表。
//
// 反转的关键是 WroteTo 边：它记在**右值**上，所以
//
//	if c { result = n1 } else { result = n2 }
//
// n1 和 n2 各自记着 result，两个都算持有者，不需要猜"这次赋值是分支还是
// 顺序覆盖"。代价是顺序覆盖也算持有，释放点偏外 —— 偏外是安全方向。
//
// 其余是作用域相关的纯函数：谁更外一层、有几层、属于哪个函数。

package parser

// collectNames 反转一次"变量 → 对象"这张正向表，得到"对象 → 当前指向它的
// 全部绑定名"。Check 期因此不需要任何撤销逻辑：重绑只是覆盖 Obj，旧对象在
// 这一步自然就不再含有那个名字。释放点不在这里定 —— 那是 SimulateRC 的时序结论。
//
// 反转是这里唯一算"谁指向谁"的地方 —— Check 期只写正向事实（Life.Obj
// 与「右值记左值」的 WroteTo 边），"某对象当前被哪些名字指着"是一次性反转
// 出来的，不增量维护。
func collectNames(root *Node) {
	// 阶段 1：建反向索引 + 反转绑定名。
	//
	// 反转是这里唯一算"谁指向谁"的地方 —— Check 期只写正向事实（Obj），
	// "某对象当前被哪些名字指着"是一次性反转出来的，不增量维护。
	// 顺带把 blockNode 补全：建树有几处绕过 AddChild（ifelse 的 if/else 节点、
	// package 合并根节点时的 append），走一遍全树保证反查索引没有空洞。
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
	// 补写站点记下的边：右值说"我被写进过这些左值"，这些左值也是持有者。
	//
	// 这一条让分支赋值天然正确，不用再靠"路径签名区分分支 vs 顺序"：
	//	if c { result = n1 } else { result = n2 }
	// n1 和 n2 各自记着 result，两个都算持有者。
	// 代价是顺序覆盖也算持有（head = n; head = m 之后 head 仍算 n 的名字），
	// 释放点会偏外 —— 偏外是安全方向（最多晚释放，不会提前）。
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

	// 收尾：名字的逃逸汇总到对象。（不再重写 o.Names —— 绑定名刚定稿）
	//
	// 原先"补条件赋值持有者"那一阶段已合并进 collectNames：绑定名的反转用
	// 「右值记左值」的写站点边，不再需要路径签名区分分支与顺序覆盖。
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

	// 字段关系收敛。同一字段只保留最后一次写入；并核对字段值变量的栈槽
	// 是否仍持有该对象，不再持有就跳过（宁可漏释放，不能读错槽位）。
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
