package compile

import "cuteify/parser"

// dceRoots 返回不应被引用计数传播禁用的根函数集合。
func (c *Compiler) isDCERoot(fb *parser.FuncBlock) bool {
	if fb == nil || fb.Name == nil {
		return false
	}
	if fb.Name.String() == "main" {
		return true
	}
	// build export
	for _, bf := range fb.BuildFlags {
		if bf.Type == "export" && bf.Export != "" && !bf.Ignore {
			return true
		}
	}
	// runtime helpers that codegen emits directly
	if len(fb.Name) >= 2 && fb.Name[0].IsPkgPath {
		last := fb.Name.Last()
		rcNames := map[string]bool{"rcDec": true, "rcInc": true, "rcGet": true, "mallocRC": true, "freeRC": true, "rcIsOne": true, "rcAdd": true, "rcSub": true, "rcTryRelease": true, "rcSet": true, "trackAlloc": true, "trackFree": true, "reportLeaks": true, "reportAllocCount": true, "reportFreeCount": true, "resetLeakTracker": true, "malloc": true, "realloc": true, "free": true, "freeSlot": true, "freeRCSlot": true}
		if rcNames[last] {
			return true
		}
	}
	// build link providers needed by string/len/cap/builtin
	for _, bf := range fb.BuildFlags {
		if bf.Type == "link" && bf.Link != "" && !bf.Ignore {
			if c.stringSyms != nil && c.stringSyms[bf.Link] {
				return true
			}
		}
	}
	return false
}

// collectFuncNodes 收集 AST 中所有 FuncBlock -> Node 映射。
func collectFuncNodes(node *parser.Node, out map[*parser.FuncBlock]*parser.Node) {
	if node == nil {
		return
	}
	if fb, ok := node.Value.(*parser.FuncBlock); ok && fb != nil {
		out[fb] = node
	}
	for _, ch := range node.Children {
		collectFuncNodes(ch, out)
	}
}

// collectCallees 扫描函数体，返回直接引用的 callee 集合（去重）。
func collectCallees(body *parser.Node) []*parser.FuncBlock {
	seen := map[*parser.FuncBlock]bool{}
	var out []*parser.FuncBlock
	var walk func(*parser.Node)
	walk = func(n *parser.Node) {
		if n == nil {
			return
		}
		switch v := n.Value.(type) {
		case *parser.CallBlock:
			if v.Func != nil && !seen[v.Func] {
				seen[v.Func] = true
				out = append(out, v.Func)
			}
			for _, a := range v.Args {
				if a != nil && a.Value != nil {
					walkExprCallees(a.Value, seen, &out)
				}
			}
		case *parser.Expression:
			walkExprCallees(v, seen, &out)
		case *parser.VarBlock:
			// 函数值引用：VarBlock.Define 指向 FuncBlock 或通过 Value 表达式
			if v.Define.Value != nil {
				if fb, ok := v.Define.Value.(*parser.FuncBlock); ok && fb != nil && !seen[fb] {
					seen[fb] = true
					out = append(out, fb)
				}
			}
			if v.Value != nil {
				walkExprCallees(v.Value, seen, &out)
			}
		case *parser.ReturnBlock:
			for _, e := range v.Value {
				if e != nil {
					walkExprCallees(e, seen, &out)
				}
			}
		case *parser.IfBlock:
			if v.Condition != nil {
				walkExprCallees(v.Condition, seen, &out)
			}
		case *parser.ForBlock:
			if v.Condition != nil {
				walkExprCallees(v.Condition, seen, &out)
			}
			if v.Init != nil {
				walkExprCallees(v.Init, seen, &out)
			}
			if v.Increment != nil {
				walkExprCallees(v.Increment, seen, &out)
			}
			if v.Range != nil {
				walkExprCallees(v.Range, seen, &out)
			}
		case *parser.SwitchBlock:
			if v.Target != nil {
				walkExprCallees(v.Target, seen, &out)
			}
		case *parser.CaseBlock:
			for _, e := range v.Values {
				if e != nil {
					walkExprCallees(e, seen, &out)
				}
			}
		case *parser.DeferBlock:
			if v.Call != nil {
				if v.Call.Func != nil && !seen[v.Call.Func] {
					seen[v.Call.Func] = true
					out = append(out, v.Call.Func)
				}
				for _, a := range v.Call.Args {
					if a != nil && a.Value != nil {
						walkExprCallees(a.Value, seen, &out)
					}
				}
			}
		case *parser.ElseBlock:
			if v.IfCondition != nil {
				walkExprCallees(v.IfCondition, seen, &out)
			}
		case *parser.ArgBlock:
			if v.Default != nil {
				walkExprCallees(v.Default, seen, &out)
			}
			if v.Value != nil {
				walkExprCallees(v.Value, seen, &out)
			}
		}
		for _, ch := range n.Children {
			walk(ch)
		}
	}
	// walk the function node itself (its children are body)
	if body != nil {
		for _, ch := range body.Children {
			walk(ch)
		}
		// also the node value may be a funcblock with args defaults etc; skip
	}
	return out
}

func walkExprCallees(e *parser.Expression, seen map[*parser.FuncBlock]bool, out *[]*parser.FuncBlock) {
	if e == nil {
		return
	}
	// CallBlock as expression node?
	if e.Call != nil {
		if e.Call.Func != nil && !seen[e.Call.Func] {
			seen[e.Call.Func] = true
			*out = append(*out, e.Call.Func)
		}
		for _, a := range e.Call.Args {
			if a != nil && a.Value != nil {
				walkExprCallees(a.Value, seen, out)
			}
		}
	}
	if e.Left != nil {
		walkExprCallees(e.Left, seen, out)
	}
	if e.Right != nil {
		walkExprCallees(e.Right, seen, out)
	}
	for _, ix := range e.Index {
		if ix != nil {
			walkExprCallees(ix, seen, out)
		}
	}
	for _, le := range e.ListElems {
		if le != nil {
			walkExprCallees(le, seen, out)
		}
	}
	for _, me := range e.MapElems {
		if me.Key != nil {
			walkExprCallees(me.Key, seen, out)
		}
		if me.Value != nil {
			walkExprCallees(me.Value, seen, out)
		}
	}
	// function value reference as identifier
	if e.Var != nil && e.Var.Define.Value != nil {
		if fb, ok := e.Var.Define.Value.(*parser.FuncBlock); ok && fb != nil && !seen[fb] {
			seen[fb] = true
			*out = append(*out, fb)
		}
	}
	// 匿名函数（闭包）
	if e.Anon != nil && !seen[e.Anon] {
		seen[e.Anon] = true
		*out = append(*out, e.Anon)
	}
}

// propagateDead 按用户算法：函数计数为 0 时，沿其调用依次减 1；减到 0 继续传播。
func (c *Compiler) propagateDead(fb *parser.FuncBlock, funcNodes map[*parser.FuncBlock]*parser.Node, dead map[*parser.FuncBlock]bool) {
	if fb == nil || dead[fb] || c.isDCERoot(fb) {
		return
	}
	if fb.Useful > 0 {
		return
	}
	dead[fb] = true
	body := funcNodes[fb]
	if body == nil {
		body = fb.Node
	}
	callees := collectCallees(body)
	for _, callee := range callees {
		if callee == nil || dead[callee] || c.isDCERoot(callee) {
			continue
		}
		callee.Useful--
		if callee.Useful <= 0 {
			c.propagateDead(callee, funcNodes, dead)
		}
	}
}

// runDCE 执行引用计数 DCE 传播。应在顶层编译、check/预标记完成后调用。
func (c *Compiler) runDCE(root *parser.Node) {
	if root == nil {
		return
	}
	funcNodes := map[*parser.FuncBlock]*parser.Node{}
	collectFuncNodes(root, funcNodes)
	// 发现通过调用边引用但不在 AST 节点映射中的 FuncBlock
	allFuncs := map[*parser.FuncBlock]bool{}
	for fb := range funcNodes {
		allFuncs[fb] = true
	}
	var queue []*parser.FuncBlock
	for fb := range funcNodes {
		queue = append(queue, fb)
	}
	for i := 0; i < len(queue); i++ {
		body := funcNodes[queue[i]]
		if body == nil {
			body = queue[i].Node
		}
		for _, callee := range collectCallees(body) {
			if callee != nil && !allFuncs[callee] {
				allFuncs[callee] = true
				queue = append(queue, callee)
			}
		}
	}
	dead := map[*parser.FuncBlock]bool{}
	for fb := range allFuncs {
		if fb.Useful <= 0 && !c.isDCERoot(fb) {
			c.propagateDead(fb, funcNodes, dead)
		}
	}
}

