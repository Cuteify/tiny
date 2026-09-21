package gc

import (
	"fmt"
	"sort"

	"cuteify/parser"
	"cuteify/type"
)

// analyzer 全程序摘要分析器。
// 输入为包合并、Check 重试完成之后的根 AST；
// 输出写入 Table（键 = 函数全路径名）。
type analyzer struct {
	fns   map[string]*parser.FuncBlock // 全路径名 → 定义块
	nodes map[string]*parser.Node      // 全路径名 → 函数体节点（Children 即语句）
	// 工作表：每函数“返回值携带拥有指针”与“体内有无 any 调用”的当前态，
	// 迭代至不动点后再落盘到 Table。
	retOwned map[string]bool
	retEsc   map[string]Escape
	anyCalls map[string][]string
	changed  bool
}

// Build 遍历根 AST，构建全程序函数摘要（不动点迭代后写入 Table）。
// 必须在 package 合并与 rootNode.Check() 之后调用。
func Build(root *parser.Node) {
	a := &analyzer{
		fns:      map[string]*parser.FuncBlock{},
		nodes:    map[string]*parser.Node{},
		retOwned: map[string]bool{},
		retEsc:   map[string]Escape{},
		anyCalls: map[string][]string{},
	}
	a.collectFuncs(root)

	// 初始化每函数摘要骨架
	for key, fb := range a.fns {
		fs := &FnSummary{Name: key}
		for i, ag := range fb.Args {
			if isOwning(ag.Type) {
				ps := fs.EnsureParam(i)
				ps.Index = i
				ps.Mode = ModeRead
				ps.Escape = EscNone
			}
		}
		if len(fb.Return) > 0 && isOwning(fb.Return[0]) {
			fs.RetOwned = true
			fs.RetEscape = EscCaller
		}
		Table[key] = fs
		a.retOwned[key] = fs.RetOwned
		a.retEsc[key] = fs.RetEscape
		a.anyCalls[key] = nil
	}

	// 不动点迭代：参数逃逸沿调用边反向传播
	for {
		a.changed = false
		for key, fb := range a.fns {
			a.analyzeBody(key, fb, a.nodes[key])
		}
		if !a.changed {
			break
		}
	}

	// LLR 分析：基于对象绑定的精确生命周期
	LLRResults = map[string]*LLRResult{}
	for fnKey, fb := range a.fns {
		fs := Table[fnKey]
		if fs == nil { continue }
		body := a.nodes[fnKey]
		res := ComputeLLR(fnKey, fb, fs, body)
		LLRResults[fnKey] = res
	}

	// 落盘
	keys := make([]string, 0, len(Table))
	for k := range Table {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	for _, k := range keys {
		fs := Table[k]
		fs.RetEscape = a.retEsc[k]
		sort.Slice(fs.Params, func(i, j int) bool { return fs.Params[i].Index < fs.Params[j].Index })
	}
}

// collectFuncs 递归收集全树 FuncBlock。
func (a *analyzer) collectFuncs(n *parser.Node) {
	if n == nil {
		return
	}
	if fb, ok := n.Value.(*parser.FuncBlock); ok && fb.Name != nil {
		key := fb.Name.String()
		if _, dup := a.fns[key]; !dup {
			a.fns[key] = fb
			a.nodes[key] = n
		}
	}
	for _, ch := range n.Children {
		a.collectFuncs(ch)
	}
}

// analyzeBody 流不敏感扫描单个函数体，更新其摘要；有变化置 changed。
func (a *analyzer) analyzeBody(key string, fb *parser.FuncBlock, body *parser.Node) {
	fs := Table[key]
	if fs == nil {
		return
	}
	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if body != nil && n == nil {
			return
		}
		if n == nil {
			return
		}
		switch v := n.Value.(type) {
		case *parser.ReturnBlock:
			// 仅当返回类型本身是拥有指针时，返回表达式引用参数才算逃逸
			// （如 print 返回 i32 只是消费参数，不构成逃逸）
			retOwns := len(fb.Return) > 0 && isOwning(fb.Return[0])
			for _, rv := range v.Value {
				if rv == nil {
					continue
				}
				if retOwns && refsTracked(rv, fb) {
					a.bumpRet(key, EscCaller)
					a.bumpParams(fs, EscCaller, ModeOtherRef)
				}
				// 传播 HasHeapAllocs：ret 调用了有堆分配的函数
				if !fs.HasHeapAllocs && exprAllocates(rv) {
					fs.HasHeapAllocs = true
					a.changed = true
				}
				// 返回表达式里的嵌套调用也要传播逃逸
				walkExprCalls(rv, func(cb *parser.CallBlock) { a.applyCallee(key, fs, cb, fb) })
			}
		case *parser.VarBlock:
			// 赋值语句（IsDefine=false）：目标是全局 且 右值为拥有值
			// （引用参数 / 调用 RetOwned 函数 / 字符串拼接）→ EscGlobal
			// + 标记函数含全局拥有存储（保守门槛）
			if !v.IsDefine && v.IsGlobal && v.Value != nil {
				hit := refsTracked(v.Value, fb)
				alloc := exprAllocates(v.Value)
				if hit {
					a.bumpParams(fs, EscGlobal, ModeOtherRef)
				}
				if (hit || alloc) && !fs.HasGlobalOwnStore {
					fs.HasGlobalOwnStore = true
					a.changed = true
				}
			}
		case *parser.CallBlock:
			a.applyCallee(key, fs, v, fb)
		}
		// 检测堆分配：任何表达式含 RetOwned 调用 / 字符串拼接 / new / make
		if !fs.HasHeapAllocs {
			if vb, ok := n.Value.(*parser.VarBlock); ok && vb.Value != nil && vb.Type != nil && isOwning(vb.Type) {
				if exprAllocates(vb.Value) {
					fs.HasHeapAllocs = true
				}
			}
		}
		for _, ch := range n.Children {
			walk(ch)
		}
		// 表达式子树里的调用也要扫（如赋值右值的嵌套调用）
		if v2, ok := n.Value.(*parser.VarBlock); ok && v2.Value != nil {
			walkExprCalls(v2.Value, func(cb *parser.CallBlock) { a.applyCallee(key, fs, cb, fb) })
		}
	}
	if body != nil {
		walk(body)
	}
}

// applyCallee 把被调摘要的效果施加到实参表达式引用的 tracked 名字上。
func (a *analyzer) applyCallee(key string, fs *FnSummary, cb *parser.CallBlock, fb *parser.FuncBlock) {
	if cb == nil || cb.Func == nil {
		return
	}
	calleeKey := cb.Func.Name.String()
	callee := Table[calleeKey]

	// 无摘要被调：实参退化 any（v1 仅记录）
	if callee == nil {
		name := cb.Func.Name.String()
		fs.CallsAny = appendUnique(fs.CallsAny, name)
		if !strSliceEq(a.anyCalls[key], fs.CallsAny) {
			a.anyCalls[key] = fs.CallsAny
			a.changed = true
		}
		return
	}
	for _, ps := range callee.Params {
		idx := ps.Index
		if idx >= len(cb.Args) {
			continue
		}
		arg := cb.Args[idx]
		if arg == nil || arg.Value == nil {
			continue
		}
		if ps.Escape > EscNone && refsTracked(arg.Value, fb) {
			a.bumpParams(fs, ps.Escape, ps.Mode)
		}
	}
	// 传播 HasHeapAllocs：被调函数有堆分配 → 调用者也有
	if callee.HasHeapAllocs && !fs.HasHeapAllocs {
		fs.HasHeapAllocs = true
		a.changed = true
	}
	// 实参里若出现嵌套复杂表达式调用（右值含其它调用），递归扫描其内部调用点
	for _, ag := range cb.Args {
		if ag != nil && ag.Value != nil {
			walkExprCalls(ag.Value, func(cb2 *parser.CallBlock) { a.applyCallee(key, fs, cb2, fb) })
		}
	}
}

// bumpRet 提升函数返回逃逸层级。
func (a *analyzer) bumpRet(key string, e Escape) {
	if a.retEsc[key] < e {
		a.retEsc[key] = e
		a.changed = true
	}
}

// bumpParams 提升函数全部拥有指针参数的模式与逃逸。
func (a *analyzer) bumpParams(fs *FnSummary, e Escape, m Mode) {
	ch := false
	for i := range fs.Params {
		if fs.Params[i].Escape < e {
			fs.Params[i].Escape = e
			ch = true
		}
		nm := fs.Params[i].Mode.Merge(m)
		if nm != fs.Params[i].Mode {
			fs.Params[i].Mode = nm
			ch = true
		}
	}
	if ch {
		a.changed = true
	}
}

// refsTracked 判断表达式的标识符引用是否命中本函数的拥有指针参数。
// v1 简化：只看根名字（字段访问 p.f 取首段），不做字段级敏感。
func refsTracked(e *parser.Expression, fb *parser.FuncBlock) bool {
	if e == nil {
		return false
	}
	hit := false
	var rec func(x *parser.Expression)
	rec = func(x *parser.Expression) {
		if x == nil || hit {
			return
		}
		if x.Var != nil && x.Var.Name != nil {
			root := x.Var.Name.First()
			for _, ag := range fb.Args {
				if isOwning(ag.Type) && ag.Name != nil && ag.Name.First() == root {
					hit = true
					return
				}
			}
		}
		rec(x.Left)
		rec(x.Right)
		for _, ix := range x.Index {
			if ix != nil {
				rec(ix.Left)
				rec(ix.Right)
			}
		}
		if x.Call != nil {
			for _, ag := range x.Call.Args {
				if ag != nil {
					rec(ag.Value)
				}
			}
		}
	}
	rec(e)
	return hit
}

// walkExprCalls 遍历表达式子树中的全部 CallBlock（含嵌套）。
func walkExprCalls(e *parser.Expression, fn func(*parser.CallBlock)) {
	if e == nil {
		return
	}
	if e.Call != nil {
		fn(e.Call)
		for _, ag := range e.Call.Args {
			if ag != nil {
				walkExprCalls(ag.Value, fn)
			}
		}
	}
	walkExprCalls(e.Left, fn)
	walkExprCalls(e.Right, fn)
	for _, ix := range e.Index {
		if ix != nil {
			walkExprCalls(ix.Left, fn)
			walkExprCalls(ix.Right, fn)
		}
	}
}

// isOwning 类型是否携带堆缓冲（string/list/结构体指针 *T 视为拥有指针载体；
// 裸 ptr 为借用/手动管理，不跟踪——与 GC_PLAN §3 一致）。
func isOwning(t typeSys.Type) bool {
	if t == nil {
		return false
	}
	k := t.Kind()
	if k == "string" || k == "list" {
		return true
	}
	// *T（结构体指针）默认 owns（&local 除外，由调用方标记）
	if t.IsPointer() {
		return true
	}
	return false
}

// appendUnique 去重追加。
func appendUnique(xs []string, v string) []string {
	for _, x := range xs {
		if x == v {
			return xs
		}
	}
	return append(xs, v)
}

// strSliceEq 无序比较两个字符串切片内容是否一致。
func strSliceEq(a, b []string) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}

// exprAllocates 判断表达式是否产生新分配的拥有指针：
// 调用 RetOwned 函数、new/make（NewType 非空）、字符串拼接（"+" 且 string 类型）。
func exprAllocates(e *parser.Expression) bool {
	if e == nil {
		return false
	}
	if e.Call != nil {
		if e.Call.NewType != nil {
			return true
		}
		if e.Call.Func != nil && len(e.Call.Func.Return) > 0 && isOwning(e.Call.Func.Return[0]) {
			return true
		}
		for _, ag := range e.Call.Args {
			if ag != nil && exprAllocates(ag.Value) {
				return true
			}
		}
	}
	if e.Separator == "+" && e.Type != nil && typeSys.CheckKind(e.Type, "string") {
		return true
	}
	return exprAllocates(e.Left) || exprAllocates(e.Right)
}

// isRCAlloc 判断表达式是否是 newRC() 分配（带 RC 头，由手动 rcDec 管理，LLR 不自动释放）。
func isRCAlloc(e *parser.Expression) bool {
	if e == nil || e.Call == nil {
		return false
	}
	return e.Call.IsRC
}

// ParamEscapes 查询被调函数第 idx 个参数的逃逸层级。
// 无摘要的被调一律返回 EscAny（保守）。
func ParamEscapes(calleeKey string, idx int) Escape {
	fs := Table[calleeKey]
	if fs == nil {
		return EscAny
	}
	for _, p := range fs.Params {
		if p.Index == idx {
			return p.Escape
		}
	}
	return EscNone
}

// CalleeKnown 被调函数是否已有摘要。
func CalleeKnown(calleeKey string) bool {
	_, ok := Table[calleeKey]
	return ok
}

// DumpSummary 打印单函数摘要（调试辅助）。
func DumpSummary(fs *FnSummary) string {
	s := fmt.Sprintf("%s retOwned=%v retEsc=%s", fs.Name, fs.RetOwned, fs.RetEscape)
	for _, p := range fs.Params {
		s += fmt.Sprintf("\n  param[%d] mode=%s esc=%s", p.Index, p.Mode, p.Escape)
	}
	for _, c := range fs.CallsAny {
		s += fmt.Sprintf("\n  any-call: %s", c)
	}
	return s
}
