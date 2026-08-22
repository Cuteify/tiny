package gc

import (
	"os"
	"fmt"
	"sort"

	"cuteify/parser"
)

// FreeVar 计划在函数出口释放的一个帧内拥有值。
type FreeVar struct {
	Name    string `json:"name"`    // 局部变量名（首段）
	Type    string `json:"type"`    // "string" / "list"
	Site    string `json:"site"`    // 分配来源描述（RetOwned 调用/拼接/make/new/列表字面量）
	Offset  int    `json:"offset"`  // 栈槽偏移（代码生成期回填，分析期为 -1）
}

// FreePlan 单个函数的出口释放计划。
// 空计划 = 该函数无可安全释放的帧内分配。
type FreePlan struct {
	Fn   string     `json:"fn"`
	Vars []FreeVar  `json:"vars"`
}

// Plans 全程序释放计划（键 = 函数全路径名；仅含有非空计划的函数）。
var Plans = map[string]*FreePlan{}

// freeScan 单函数扫描上下文。
type freeScan struct {
	fnKey string
	plan  *FreePlan
	// topAssigned: 顶层（函数体直接子级）赋值过的拥有变量名 → 分配来源
	// 出现第二次赋值即取消资格（多分配泄漏，v1 禁用自动释放）
	topAssigned map[string]*FreeVar
	// escaped: 因逃逸规则被豁免的变量名
	escaped map[string]bool
	// aliased: 作为其他赋值 RHS 出现过 → 共享缓冲，禁用自动释放
	aliased map[string]bool
}

// PlanFrees 基于已有 Table 摘要，为每个函数计算出口释放计划。
// 必须在 Build 之后调用。结果写入 Plans。
func PlanFrees(root *parser.Node) {
	for k := range Plans {
		delete(Plans, k)
	}
	a := &analyzer{} // 复用收集器逻辑只需 fns/nodes
	_ = a

	var walkFn func(n *parser.Node)
	walkFn = func(n *parser.Node) {
		if n == nil {
			return
		}
		if fb, ok := n.Value.(*parser.FuncBlock); ok && fb.Name != nil {
			key := fb.Name.String()
			fs := Table[key]
			if fs != nil {
				scanFunction(key, fb, fs, n)
			}
			return // 不深入嵌套函数（当前语言无嵌套函数定义）
		}
		for _, ch := range n.Children {
			walkFn(ch)
		}
	}
	walkFn(root)
}

// scanFunction 扫描单个函数体，产出该函数的 FreePlan。
func scanFunction(fnKey string, fb *parser.FuncBlock, fs *FnSummary, body *parser.Node) {
	// 函数级保守门槛：含全局拥有存储 / any 调用 → 整函数跳过
	if fs.HasGlobalOwnStore || len(fs.CallsAny) > 0 {
		return
	}
	sc := &freeScan{
		fnKey:       fnKey,
		plan:        &FreePlan{Fn: fnKey},
		topAssigned: map[string]*FreeVar{},
		escaped:     map[string]bool{},
		aliased:      map[string]bool{},
	}
	paramOwn := map[string]bool{}
	for _, ag := range fb.Args {
		if isOwning(ag.Type) && ag.Name != nil {
			paramOwn[ag.Name.First()] = true
		}
	}

	if body == nil {
		return
	}
	// 第一遍：仅顶层语句（body 直接子级），收集“单次顶层分配”候选
	for _, ch := range body.Children {
		vb, ok := ch.Value.(*parser.VarBlock)
		if !ok || !vb.IsDefine || vb.Type == nil || !isOwning(vb.Type) {
			continue
		}
		name := ""
		if vb.Name != nil {
			name = vb.Name.First()
		}
		if name == "" || paramOwn[name] {
			continue
		}
		if sc.topAssigned[name] != nil {
			// 多次顶层赋值：前一次分配泄漏（v1 接受），取消该变量资格
			sc.escaped[name] = true
			continue
		}
		fv := &FreeVar{Name: name, Type: vb.Type.Kind(), Offset: -1}
		fv.Site = allocSiteDesc(vb.Value)
		sc.topAssigned[name] = fv
	}
	if len(sc.topAssigned) == 0 {
		return
	}

	// 第二遍：全深度扫描，施加豁免规则
	var walk func(n *parser.Node, depth int, inTopAssignRHS bool)
	walk = func(n *parser.Node, depth int, inTopAssignRHS bool) {
		if n == nil {
			return
		}
		switch v := n.Value.(type) {
		case *parser.ReturnBlock:
			// 仅当返回类型本身是拥有指针时，返回表达式引用候选才算逃逸；
			// 返回 int/bool 等只是对数据的计算，不构成逃逸
			if fb.Return != nil && len(fb.Return) > 0 && isOwning(fb.Return[0]) {
				for _, rv := range v.Value {
					markRefs(rv, sc, EscCaller)
				}
			}
		case *parser.VarBlock:
			if v.IsDefine && depth == 1 && inTopAssignRHS {
				// 顶层定义本身：其 RHS 的引用不算逃逸（就是分配来源）
				break
			}
			// 别名传播：候选作为赋值 RHS → 共享缓冲
			if !v.IsDefine && v.Value != nil {
				markRefsAsAliased(v.Value, sc)
			}
			// 全局赋值：RHS 引用候选 → 逃逸到全局
			if !v.IsDefine && v.IsGlobal && v.Value != nil {
				markRefs(v.Value, sc, EscGlobal)
			}
		case *parser.CallBlock:
			if v.Func == nil {
				break
			}
			// 合成内建（__list_len 等）参数只读且返回非拥有值，跳过
			fnName := v.Func.Name.String()
			if len(fnName) > 2 && fnName[:2] == "__" && fnName[2:7] != "globa" {
				break
			}
			calleeKey := fnName
			for idx, ag := range v.Args {
				if ag == nil || ag.Value == nil {
					continue
				}
				esc := ParamEscapes(calleeKey, idx)
				if esc > EscNone {
					markRefs(ag.Value, sc, esc)
				}
			}
		}
		for _, ch := range n.Children {
			walk(ch, depth+1, false)
		}
		// 表达式内的调用/别名也扫（如赋值右值的嵌套调用）
		if vb, ok := n.Value.(*parser.VarBlock); ok && vb.Value != nil {
			walkExprForPlan(vb.Value, sc, depth)
		}
	}
	walk(body, 0, false)

	// 汇总：未被豁免/未别名的候选进入计划
	names := make([]string, 0, len(sc.topAssigned))
	for n := range sc.topAssigned {
		names = append(names, n)
	}
	sort.Strings(names)
	for _, n := range names {
		if sc.escaped[n] || sc.aliased[n] {
			continue
		}
		fv := sc.topAssigned[n]
		// 回填栈槽偏移
		fv.Offset = -1 // 代码生成期回填
		sc.plan.Vars = append(sc.plan.Vars, *fv)
	}
	if len(sc.plan.Vars) > 0 {
		Plans[fnKey] = sc.plan
	}
	if os.Getenv("GC_DBG") != "" {
		fmt.Fprintf(os.Stderr, "PLANDBG %s: candidates=%d escaped=%v aliased=%v plan_vars=%d gate_skip=%v\n",
			fnKey, len(sc.topAssigned), sc.escaped, sc.aliased, len(sc.plan.Vars),
			fs.HasGlobalOwnStore || len(fs.CallsAny) > 0)
		for n := range sc.topAssigned {
			fmt.Fprintf(os.Stderr, "  cand %s: esc=%v ali=%v\n", n, sc.escaped[n], sc.aliased[n])
		}
	}
}

// walkExprForPlan 表达式内的逃逸/别名扫描（ReturnBlock/CallBlock 已单独处理）。
func walkExprForPlan(e *parser.Expression, sc *freeScan, depth int) {
	if e == nil {
		return
	}
	_ = e
	_ = sc
	_ = depth
}

// markRefs 表达式中引用的候选拥有值标记为指定逃逸层级。
func markRefs(e *parser.Expression, sc *freeScan, elevel Escape) {
	if e == nil {
		return
	}
	if e.Var != nil && e.Var.Name != nil {
		root := e.Var.Name.First()
		if sc.topAssigned[root] != nil {
			sc.escaped[root] = true
			_ = elevel
		}
	}
	markRefs(e.Left, sc, elevel)
	markRefs(e.Right, sc, elevel)
	for _, ix := range e.Index {
		if ix != nil {
			markRefs(ix.Left, sc, elevel)
			markRefs(ix.Right, sc, elevel)
		}
	}
	if e.Call != nil {
		for _, ag := range e.Call.Args {
			if ag != nil {
				markRefs(ag.Value, sc, elevel)
			}
		}
	}
}

// markRefsAsAliased 表达式引用的候选拥有值标记为已别名（共享缓冲）。
func markRefsAsAliased(e *parser.Expression, sc *freeScan) {
	if e == nil {
		return
	}
	if e.Var != nil && e.Var.Name != nil {
		root := e.Var.Name.First()
		if sc.topAssigned[root] != nil {
			sc.aliased[root] = true
		}
	}
	markRefsAsAliased(e.Left, sc)
	markRefsAsAliased(e.Right, sc)
	for _, ix := range e.Index {
		if ix != nil {
			markRefsAsAliased(ix.Left, sc)
			markRefsAsAliased(ix.Right, sc)
		}
	}
	if e.Call != nil {
		for _, ag := range e.Call.Args {
			if ag != nil {
				markRefsAsAliased(ag.Value, sc)
			}
		}
	}
}

// allocSiteDesc 描述分配来源（dump 可读性用）。
func allocSiteDesc(e *parser.Expression) string {
	if e == nil {
		return "unknown"
	}
	if e.Call != nil {
		if e.Call.NewType != nil {
			return "new"
		}
		if e.Call.Func != nil && len(e.Call.Func.Return) > 0 && isOwning(e.Call.Func.Return[0]) {
			return "call:" + e.Call.Func.Name.String()
		}
	}
	if e.Separator == "+" {
		return "string-concat"
	}
	return "expr"
}

// findLocalOffset 在函数体节点树中查找指定名局部变量的栈槽偏移。
// 未找到返回 -1（代码生成期将跳过该变量）。
func findLocalOffset(body *parser.Node, name string) int {
	var found int = -1
	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if n == nil || found != -1 {
			return
		}
		if vb, ok := n.Value.(*parser.VarBlock); ok && !vb.IsGlobal &&
			vb.Offset != 0 && vb.Name != nil && vb.Name.First() == name {
			found = vb.Offset
			return
		}
		for _, ch := range n.Children {
			walk(ch)
		}
	}
	walk(body)
	return found
}

// DumpFrees 输出全部释放计划（调试辅助）。
func DumpFrees() string {
	keys := make([]string, 0, len(Plans))
	for k := range Plans {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	out := ""
	for _, k := range keys {
		p := Plans[k]
		out += fmt.Sprintf("== %s (%d vars)\n", p.Fn, len(p.Vars))
		for _, v := range p.Vars {
			out += fmt.Sprintf("  %s [%s] site=%s off=%d\n", v.Name, v.Type, v.Site, v.Offset)
		}
	}
	return out
}
