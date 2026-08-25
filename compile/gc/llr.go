package gc

import (
	"fmt"
	"sort"
	"strconv"

	"cuteify/parser"
)

// ObjID 抽象堆对象标识符（按分配点唯一）。
type ObjID int

const NilObj ObjID = -1

// llrState 单函数的语句级前向扫描状态。
type llrState struct {
	// bindings 变量名（首段）→ 当前绑定的抽象对象
	bindings map[string]ObjID
	// objEscaped 对象是否已逃逸（一旦逃逸永不回收）
	objEscaped map[ObjID]bool
	// objSite 对象的分配来源描述
	objSite map[ObjID]string
	// nextObj 下一个可用 ObjID
	nextObj ObjID
}

// LLRResult 单函数的 LLR 计算结果。
type LLRResult struct {
	Fn      string          `json:"fn"`
	Objects []LLRObj        `json:"objects"`
	Frees   []LLRFree       `json:"frees"` // 需要在出口释放的对象
}

// LLRObj 一个抽象对象的完整信息。
type LLRObj struct {
	ID       ObjID `json:"id"`
	Site     string `json:"site"`
	Escaped  bool   `json:"escaped"`
	Name     string `json:"name"`     // 主要绑定名（调试用）
	FrameOwn bool   `json:"frameOwn"` // 帧内拥有且未逃逸 → 可自动释放
}

// LLRFree 出口释放条目。
type LLRFree struct {
	VarName string `json:"varName"`
	Type    string `json:"type"`
}

// llrVars 函数参数中的拥有指针（不可重绑，调用者管理生命周期）。
type llrVars struct {
	params map[string]bool // 参数名集合（拥有类型）
}

// ComputeLLR 对单个函数做 LLR 分析，返回结果。
// body 为函数体节点，fs 为该函数的摘要。
func ComputeLLR(fnKey string, fb *parser.FuncBlock, fs *FnSummary, body *parser.Node) *LLRResult {
	res := &LLRResult{Fn: fnKey}

	// 函数级保守门槛
	if fs.HasGlobalOwnStore || len(fs.CallsAny) > 0 {
		return res
	}

	st := &llrState{
		bindings:   map[string]ObjID{},
		objEscaped: map[ObjID]bool{},
		objSite:    map[ObjID]string{},
		nextObj:    0,
	}

	// 参数中的拥有指针：绑定为 param 对象（调用者管理，不自动释放）
	paramNames := map[string]bool{}
	for _, ag := range fb.Args {
		if ag.Type != nil && isOwning(ag.Type) && ag.Name != nil {
			n := ag.Name.First()
			id := st.newObj("param:" + n)
			st.bindings[n] = id
			st.objEscaped[id] = true // 参数由调用者管理
			paramNames[n] = true
		}
	}

	// 前向扫描函数体顶层语句
	if body == nil {
		return res
	}
	scanStatements(body, st, fb, paramNames)

	// 汇总结果
	objIDs := make([]ObjID, 0)
	for id := range st.objSite {
		objIDs = append(objIDs, id)
	}
	sort.Slice(objIDs, func(i, j int) bool { return objIDs[i] < objIDs[j] })

	for _, id := range objIDs {
		mainName := ""
		for name, oid := range st.bindings {
			if oid == id && (mainName == "" || len(name) < len(mainName)) {
				mainName = name
			}
		}
		escaped := st.objEscaped[id]
		frameOwn := !escaped && !isParamObj(st, id)

		res.Objects = append(res.Objects, LLRObj{
			ID: id, Site: st.objSite[id], Escaped: escaped,
			Name: mainName, FrameOwn: frameOwn,
		})

		// 帧内拥有且未逃逸 → 出口释放
		if frameOwn && mainName != "" {
			tk := typeKindOf(st, id, fb, body)
			res.Frees = append(res.Frees, LLRFree{VarName: mainName, Type: tk})
		}
	}
	return res
}

// newObj 创建新抽象对象。
func (st *llrState) newObj(site string) ObjID {
	id := st.nextObj
	st.nextObj++
	st.objSite[id] = site
	return id
}

// isParamObj 判断对象是否为参数透传（不由本帧管理）。
func isParamObj(st *llrState, id ObjID) bool {
	site := st.objSite[id]
	return len(site) > 6 && site[:6] == "param:"
}

// typeKindOf 查找对象主要绑定名的类型 Kind。
func typeKindOf(st *llrState, id ObjID, fb *parser.FuncBlock, body *parser.Node) string {
	for name, oid := range st.bindings {
		if oid == id {
			if vk := lookupVarKind(body, name); vk != "" {
				return vk
			}
		}
	}
	return "string" // 兜底
}

// lookupVarKind 在函数体中查找指定名变量的类型 Kind。
func lookupVarKind(body *parser.Node, name string) string {
	var found string
	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if n == nil || found != "" {
			return
		}
		if vb, ok := n.Value.(*parser.VarBlock); ok && vb.IsDefine &&
			vb.Type != nil && vb.Name != nil && vb.Name.First() == name {
			found = vb.Type.Kind()
			return
		}
		for _, ch := range n.Children {
			walk(ch)
		}
	}
	walk(body)
	return found
}

// scanStatements 前向扫描语句列表，更新绑定与逃逸状态。
func scanStatements(body *parser.Node, st *llrState, fb *parser.FuncBlock, paramNames map[string]bool) {
	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if n == nil {
			return
		}
		switch v := n.Value.(type) {
		case *parser.VarBlock:
			processAssign(v, st, fb, paramNames)
		case *parser.ReturnBlock:
			// 返回类型为 owning 时，return 表达式引用的对象标记为逃逸到调用者
			retOwns := len(fb.Return) > 0 && isOwning(fb.Return[0])
			if retOwns {
				markAllReferencedObjs(v, st, fb)
			}
		case *parser.CallBlock:
			// 调用实参引用的对象按被调摘要传播逃逸
			markCallArgObjs(v, st, fb)
		}
		for _, ch := range n.Children {
			walk(ch)
		}
	}
	walk(body)
}

// processAssign 处理赋值/定义语句。
func processAssign(v *parser.VarBlock, st *llrState, fb *parser.FuncBlock, paramNames map[string]bool) {
	if v.Value == nil || v.Type == nil || !isOwning(v.Type) {
		return
	}
	name := ""
	if v.Name != nil {
		name = v.Name.First()
	}
	if name == "" {
		return
	}

	if v.IsDefine {
		// 新定义：创建新对象绑定
		if exprAllocates(v.Value) {
			site := allocSiteDesc(v.Value)
			id := st.newObj(site)
			st.bindings[name] = id
		} else if refObj := getRefObj(v.Value, st); refObj != NilObj {
			// 别名赋值：b = a → b 绑定到 a 的对象
			st.bindings[name] = refObj
		}
		return
	}

	// 非定义赋值（name = value）
	targetObj := NilObj
	if oid, ok := st.bindings[name]; ok {
		targetObj = oid
	}
	if targetObj == NilObj {
		return
	}

	// 全局目标：对象逃逸到全局
	// 局部目标：重新绑定
	if exprAllocates(v.Value) {
		site := allocSiteDesc(v.Value)
		newID := st.newObj(site)
		st.bindings[name] = newID
		// 旧对象不再由此名持有——如果无其他名字持有则成为泄漏候选（v1 忽略）
	} else if refObj := getRefObj(v.Value, st); refObj != NilObj {
		if isGlobalTarget(name, fb) {
			st.objEscaped[targetObj] = true
			_ = refObj
		} else {
			// 局部间别名：target 重绑到 value 的对象
			st.bindings[name] = refObj
		}
	}
}

// getRefObj 如果表达式是裸变量引用且已绑定到某对象，返回该对象 ID。
func getRefObj(e *parser.Expression, st *llrState) ObjID {
	if e == nil || e.Call != nil || e.Left != nil || e.Right != nil {
		return NilObj
	}
	if e.Var != nil && e.Var.Name != nil {
		n := e.Var.Name.First()
		if id, ok := st.bindings[n]; ok {
			return id
		}
	}
	return NilObj
}

// markAllReferencedObjs 将表达式中引用的所有对象标记为逃逸。
// markAllReferencedObjs 将返回语句中引用的所有对象标记为逃逸。
func markAllReferencedObjs(v *parser.ReturnBlock, st *llrState, fb *parser.FuncBlock) {
	if v.Value == nil || len(v.Value) == 0 {
		return
	}
	var rec func(e *parser.Expression)
	rec = func(e *parser.Expression) {
		if e == nil {
			return
		}
		if e.Var != nil && e.Var.Name != nil {
			n := e.Var.Name.First()
			if id, ok := st.bindings[n]; ok {
				st.objEscaped[id] = true
			}
		}
		rec(e.Left)
		rec(e.Right)
		if e.Call != nil {
			for _, ag := range e.Call.Args {
				rec(ag.Value)
			}
		}
	}
	for _, expr := range v.Value {
		rec(expr)
	}
}
// markCallArgObjs 调用实参引用的对象按被调摘要传播逃逸。
func markCallArgObjs(cb *parser.CallBlock, st *llrState, fb *parser.FuncBlock) {
	if cb.Func == nil {
		return
	}
	calleeKey := cb.Func.Name.String()

	// 合成内建（__list_len 等）：参数只读，不传播
	if len(calleeKey) > 2 && calleeKey[:2] == "__" &&
		len(calleeKey) > 7 && calleeKey[2:7] != "globa" {
		return
	}

	for idx, ag := range cb.Args {
		if ag == nil || ag.Value == nil {
			continue
		}
		esc := ParamEscapes(calleeKey, idx)
		if esc == EscNone {
			continue
		}
		// 实参表达式中的所有对象继承此逃逸层级
		var rec func(e *parser.Expression)
		rec = func(e *parser.Expression) {
			if e == nil {
				return
			}
			if e.Var != nil && e.Var.Name != nil {
				n := e.Var.Name.First()
				if id, ok := st.bindings[n]; ok {
					if esc > EscNone {
						st.objEscaped[id] = true
					}
				}
			}
			rec(e.Left)
			rec(e.Right)
			if e.Call != nil {
				for _, a := range e.Call.Args {
					rec(a.Value)
				}
			}
		}
		rec(ag.Value)
	}
}

// isGlobalTarget 判断变量名是否对应全局拥有变量。
func isGlobalTarget(name string, fb *parser.FuncBlock) bool {
	// v1 简化：在 analyzeBody 的 VarBlock 分支里已经通过 IsGlobal 判定并调用了
	// bumpParams / HasGlobalOwnStore。此处通过查找全局符号名模式判断。
	// 实际上需要访问 IsGlobal 标志——但 bindings 只存了名字。
	// 暂用约定：以 "__global_" 开头的全路径名为全局（不会出现在局部变量中）。
	_ = name
	_ = fb
	return false // v1 由上层 VarBlock 分支的 IsGlobal 检查覆盖
}

// DumpLLR 输出 LLR 结果（调试辅助）。
func DumpLLR(res *LLRResult) string {
	out := fmt.Sprintf("== %s\n", res.Fn)
	for _, o := range res.Objects {
		tag := ""
		if o.Escaped {
			tag = " ESCAPED"
		}
		if o.FrameOwn {
			tag += " FRAME_OWN"
		}
		out += fmt.Sprintf("  obj[%d] %s site=%s%s\n", o.ID, o.Name, o.Site, tag)
	}
	for _, f := range res.Frees {
		out += fmt.Sprintf("  FREE %s [%s]\n", f.VarName, f.Type)
	}
	return out
}

// itoa 简写
func itoa(n int) string { return strconv.Itoa(n) }
