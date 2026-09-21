package gc

import (
	"fmt"
	"sort"
	"strconv"

	"cuteify/parser"
	typeSys "cuteify/type"
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
	// objRCAlloc 对象是否由 newRC() 分配（带 RC 头，LLR 不自动释放）
	objRCAlloc map[ObjID]bool
	// objSite 对象的分配来源描述
	objSite map[ObjID]string
	// objScope 对象创建时的作用域深度
	objScope map[ObjID]int
	// objBlockID 对象创建时所在的块 ID（用于区分同深度不同块）
	objBlockID map[ObjID]int
	// nextObj 下一个可用 ObjID
	nextObj ObjID
	// orphans 被替换掉的旧对象（需要在函数出口 free）
	orphans []ObjID
	// fieldOrphans 字段级孤儿：字段赋值时旧值需要在函数出口释放
	fieldOrphans []fieldOrphan
	// scopeDepth 当前作用域深度（0=函数体，1=for/if 第一层，2=嵌套第二层...）
	scopeDepth int
	// nextBlockID 下一个可用的块 ID
	nextBlockID int
	// currentBlockID 当前块 ID
	currentBlockID int
}

// fieldOrphan 字段级孤儿：字段赋值时旧值需要在函数出口释放。
type fieldOrphan struct {
	varName   string // 父 struct 变量名
	fieldName string // 字段名
	parentObj ObjID  // 父对象 ID
}

// LLRResult 单函数的 LLR 计算结果。
type LLRResult struct {
	Fn           string              `json:"fn"`
	Objects      []LLRObj            `json:"objects"`
	Frees        []LLRFree           `json:"frees"` // 出口释放
	FieldFrees   []LLRFieldFree      `json:"fieldFrees"` // 字段级级联释放
	BlockFreesMap map[*parser.Node][]LLRFree `json:"-"` // 块级释放（按块节点索引）
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
	VarName    string `json:"varName"`
	Type       string `json:"type"`
	ScopeDepth int    `json:"scopeDepth"` // 0=函数出口, >0=块出口
}

// LLRFieldFree 字段级释放条目：函数出口需递归释放 struct 字段中的拥有指针。
type LLRFieldFree struct {
	VarName   string `json:"varName"`   // 父 struct 变量名（如 "root"）
	FieldName string `json:"fieldName"` // 字段名（如 "left"）
	Type      string `json:"type"`      // 字段类型 kind（如 "struct"、"list"）
}

// llrVars 函数参数中的拥有指针（不可重绑，调用者管理生命周期）。
type llrVars struct {
	params map[string]bool // 参数名集合（拥有类型）
}

// ComputeLLR 对单个函数做 LLR 分析，返回结果。
// body 为函数体节点，fs 为该函数的摘要。
func ComputeLLR(fnKey string, fb *parser.FuncBlock, fs *FnSummary, body *parser.Node) *LLRResult {
	res := &LLRResult{Fn: fnKey, BlockFreesMap: map[*parser.Node][]LLRFree{}}

	// 函数级保守门槛：仅当存在未知调用时禁用
	if hasRealAnyCalls(fs.CallsAny) {
		return res
	}
	// 无堆分配的函数：跳过 LLR 分析（无可释放的堆 ptr）
	if !fs.HasHeapAllocs {
		return res
	}

	st := &llrState{
		bindings:     map[string]ObjID{},
		objEscaped:   map[ObjID]bool{},
		objRCAlloc:   map[ObjID]bool{},
		objSite:      map[ObjID]string{},
		objScope:     map[ObjID]int{},
		objBlockID:   map[ObjID]int{},
		nextObj:      0,
		nextBlockID:  1, // 从 1 开始，0 留给函数体
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
	scanStatements(body, st, fb, paramNames, res.BlockFreesMap)

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

		// 帧内拥有且未逃逸 → 出口释放（变量仍绑定着该对象）
		if frameOwn && mainName != "" && !st.objRCAlloc[id] {
			tk := typeKindOf(st, id, fb, body)
			sd := st.objScope[id]
			res.Frees = append(res.Frees, LLRFree{VarName: mainName, Type: tk, ScopeDepth: sd})
		}
	}

	// 孤儿对象：被替换掉的旧 ptr，需要在出口 free（无变量名绑定，用 site 标识）
	for _, id := range st.orphans {
		escaped := st.objEscaped[id]
		if escaped || isParamObj(st, id) {
			continue
		}
		site := st.objSite[id]
		res.Objects = append(res.Objects, LLRObj{
			ID: id, Site: site, Escaped: false,
			Name: "", FrameOwn: true,
		})
		res.Frees = append(res.Frees, LLRFree{VarName: site, Type: "heap-ptr", ScopeDepth: st.objScope[id]})
	}

	// 字段级孤儿：字段赋值时旧值需要在函数出口释放
	fieldSeen := map[string]bool{}
	for _, fo := range st.fieldOrphans {
		key := fo.varName + "." + fo.fieldName
		if fieldSeen[key] {
			continue // 同一字段只需释放一次（最后一次赋值的旧值）
		}
		fieldSeen[key] = true
		// 查找父变量的类型，确定字段的类型 kind
		fieldTypeKind := lookupFieldTypeKind(fb, body, fo.varName, fo.fieldName)
		if fieldTypeKind == "" {
			continue
		}
		res.FieldFrees = append(res.FieldFrees, LLRFieldFree{
			VarName:   fo.varName,
			FieldName: fo.fieldName,
			Type:      fieldTypeKind,
		})
	}

	// 收集 struct 类型中所有 owning 字段的级联释放条目
	// 当 struct 指针变量在函数出口被释放时，其 owning 字段也需要递归释放
	structFieldFrees := collectStructFieldFrees(fb, body, res.Frees)
	// 合并（去重：fieldOrphans 已有的不重复添加）
	existingKeys := map[string]bool{}
	for _, ff := range res.FieldFrees {
		existingKeys[ff.VarName+"."+ff.FieldName] = true
	}
	for _, ff := range structFieldFrees {
		if !existingKeys[ff.VarName+"."+ff.FieldName] {
			res.FieldFrees = append(res.FieldFrees, ff)
		}
	}

	return res
}

// newObj 创建新抽象对象。
func (st *llrState) newObj(site string) ObjID {
	id := st.nextObj
	st.nextObj++
	st.objSite[id] = site
	st.objScope[id] = st.scopeDepth
	st.objBlockID[id] = st.currentBlockID
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

// lookupFieldTypeKind 查找变量指定字段的类型 Kind。
func lookupFieldTypeKind(fb *parser.FuncBlock, body *parser.Node, varName, fieldName string) string {
	// 在函数体/参数中查找变量定义，获取 struct 类型
	var structType *typeSys.StructType
	// 查找函数参数
	for _, ag := range fb.Args {
		if ag.Name != nil && ag.Name.First() == varName {
			if st, ok := ag.Type.(*typeSys.StructType); ok {
				structType = st
			}
			if ag.Type != nil && ag.Type.IsPointer() {
				if st, ok := ag.Type.Elem().(*typeSys.StructType); ok {
					structType = st
				}
			}
			break
		}
	}
	// 查找函数体中的变量定义
	if structType == nil {
		var walk func(n *parser.Node)
		walk = func(n *parser.Node) {
			if n == nil || structType != nil {
				return
			}
			if vb, ok := n.Value.(*parser.VarBlock); ok && vb.IsDefine &&
				vb.Type != nil && vb.Name != nil && vb.Name.First() == varName {
				if st, ok := vb.Type.(*typeSys.StructType); ok {
					structType = st
				}
				if vb.Type.IsPointer() {
					if st, ok := vb.Type.Elem().(*typeSys.StructType); ok {
						structType = st
					}
				}
				return
			}
			for _, ch := range n.Children {
				walk(ch)
			}
		}
		walk(body)
	}
	if structType == nil {
		return ""
	}
	field := structType.Field(fieldName)
	if field == nil || field.Type == nil {
		return ""
	}
	return field.Type.Kind()
}

// collectStructFieldFrees 收集 struct 类型中所有 owning 字段的级联释放条目。
// 当 struct 指针变量在函数出口被释放时，其 owning 字段也需要递归释放。
func collectStructFieldFrees(fb *parser.FuncBlock, body *parser.Node, frees []LLRFree) []LLRFieldFree {
	var fieldFrees []LLRFieldFree
	seen := map[string]bool{} // dedup: "varName.fieldName"
	for _, fr := range frees {
		varName := fr.VarName
		// 查找变量的 struct 类型（支持直接 struct 和 *struct 指针）
		var structType *typeSys.StructType
		for _, ag := range fb.Args {
			if ag.Name != nil && ag.Name.First() == varName {
				if st, ok := ag.Type.(*typeSys.StructType); ok {
					structType = st
				}
				if ag.Type != nil && ag.Type.IsPointer() {
					if st, ok := ag.Type.Elem().(*typeSys.StructType); ok {
						structType = st
					}
				}
				break
			}
		}
		if structType == nil {
			var walk func(n *parser.Node)
			walk = func(n *parser.Node) {
				if n == nil || structType != nil {
					return
				}
				if vb, ok := n.Value.(*parser.VarBlock); ok && vb.IsDefine &&
					vb.Type != nil && vb.Name != nil && vb.Name.First() == varName {
					if st, ok := vb.Type.(*typeSys.StructType); ok {
						structType = st
					}
					if vb.Type.IsPointer() {
						if st, ok := vb.Type.Elem().(*typeSys.StructType); ok {
							structType = st
						}
					}
					return
				}
				for _, ch := range n.Children {
					walk(ch)
				}
			}
			walk(body)
		}
		if structType == nil {
			continue
		}
		structType.Layout()
		for _, field := range structType.Fields() {
			if field.Type == nil {
				continue
			}
			if isOwning(field.Type) {
				key := varName + "." + field.Name
				if !seen[key] {
					seen[key] = true
					fieldFrees = append(fieldFrees, LLRFieldFree{
						VarName:   varName,
						FieldName: field.Name,
						Type:      field.Type.Kind(),
					})
				}
			}
		}
	}
	return fieldFrees
}

// scanStatements 前向扫描语句列表，更新绑定与逃逸状态。
// blockFreesMap 按块节点记录该块末尾需要释放的对象。
func scanStatements(body *parser.Node, st *llrState, fb *parser.FuncBlock, paramNames map[string]bool, blockFreesMap map[*parser.Node][]LLRFree) {
	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if n == nil {
			return
		}
		switch v := n.Value.(type) {
		case *parser.VarBlock:
			processAssign(v, st, fb, paramNames)
		case *parser.ReturnBlock:
			retOwns := len(fb.Return) > 0 && isOwning(fb.Return[0])
			if retOwns {
				markAllReferencedObjs(v, st, fb)
			}
			for _, rv := range v.Value {
				if rv == nil {
					continue
				}
				if rv.Call != nil {
					markCallArgObjExpr(rv, st, fb)
					// Escape call results that return owning types (e.g. ret makeNode(val))
					if retOwns && rv.Call.Func != nil && len(rv.Call.Func.Return) > 0 &&
						isOwning(rv.Call.Func.Return[0]) {
						site := "call:" + rv.Call.Func.Name.String()
						id := st.newObj(site)
						st.objEscaped[id] = true
					}
				}
				// Escape field/element results of owning type in return (e.g. ret node.left)
				if rv.Left != nil && rv.Left.Var != nil && rv.Left.Var.Name != nil {
					n := rv.Left.Var.Name.First()
					if id, ok := st.bindings[n]; ok && st.objSite[id] != "" && !st.objEscaped[id] {
						st.objEscaped[id] = true
					}
				}
			}
		case *parser.CallBlock:
			markCallArgObjs(v, st, fb)
		case *parser.ForBlock:
			st.scopeDepth++
			savedBlockID := st.currentBlockID
			st.currentBlockID = st.nextBlockID
			st.nextBlockID++
			for _, ch := range n.Children {
				walk(ch)
			}
			// 退出 for 循环块：收集该块的释放条目
			frees := collectBlockFrees(st, st.currentBlockID, fb, body)
			if len(frees) > 0 {
				blockFreesMap[n] = frees
			}
			st.currentBlockID = savedBlockID
			st.scopeDepth--
			return
		case *parser.IfBlock:
			st.scopeDepth++
			savedBlockID := st.currentBlockID
			st.currentBlockID = st.nextBlockID
			st.nextBlockID++
			for _, ch := range n.Children {
				walk(ch)
			}
			// 退出 if 块：收集该块的释放条目
			frees := collectBlockFrees(st, st.currentBlockID, fb, body)
			if len(frees) > 0 {
				blockFreesMap[n] = frees
			}
			st.currentBlockID = savedBlockID
			st.scopeDepth--
			if v.ElseBlock != nil {
				st.scopeDepth++
				st.currentBlockID = st.nextBlockID
				st.nextBlockID++
				for _, ch := range v.ElseBlock.Children {
					walk(ch)
				}
				ef := collectBlockFrees(st, st.currentBlockID, fb, body)
				if len(ef) > 0 {
					blockFreesMap[v.ElseBlock] = ef
				}
				st.currentBlockID = savedBlockID
				st.scopeDepth--
			}
			return
		}
		for _, ch := range n.Children {
			walk(ch)
		}
	}
	walk(body)
}

// collectBlockFrees 收集指定块 ID 的所有帧内拥有对象，生成块级释放条目。
func collectBlockFrees(st *llrState, blockID int, fb *parser.FuncBlock, body *parser.Node) []LLRFree {
	var frees []LLRFree
	for id := range st.objSite {
		if st.objBlockID[id] != blockID {
			continue
		}
		if st.objEscaped[id] || isParamObj(st, id) {
			continue
		}
		if st.objRCAlloc[id] {
			continue // newRC() 对象由手动 rcDec 管理，LLR 不自动释放
		}
		// 找到绑定此对象的变量名
		mainName := ""
		for name, oid := range st.bindings {
			if oid == id && (mainName == "" || len(name) < len(mainName)) {
				mainName = name
			}
		}
		if mainName == "" {
			continue // 无绑定名（孤儿），由 orphan 机制处理
		}
		tk := typeKindOf(st, id, fb, body)
		frees = append(frees, LLRFree{VarName: mainName, Type: tk, ScopeDepth: st.objScope[id]})
	}
	return frees
}

// processAssign 处理赋值/定义语句。
func processAssign(v *parser.VarBlock, st *llrState, fb *parser.FuncBlock, paramNames map[string]bool) {
	name := ""
	if v.Name != nil {
		name = v.Name.First()
	}
	if name == "" {
		return
	}

	// 定义 + 无值 + owning 类型 → null_init 绑定（var x: *T）
	// 例如 var result: *Node —— 需要绑定以便后续 result = n 追踪
	if v.IsDefine && v.Value == nil && v.Type != nil && isOwning(v.Type) {
		id := st.newObj("null_init")
		st.bindings[name] = id
		st.objEscaped[id] = true
		return
	}

	if v.Value == nil {
		return
	}

	// 字段赋值（node.left = X）：跟踪字段级 orphan，不重绑父变量
	if len(v.Name) > 1 {
		if !v.IsDefine && exprAllocates(v.Value) {
			fieldName := v.Name.Last()
			// 查找父变量当前绑定的对象
			if parentObj, ok := st.bindings[name]; ok {
				// 只有帧内拥有的父对象才需要字段级 orphan free
				// 已逃逸的对象由调用者管理，不在本帧释放
				if !isParamObj(st, parentObj) && !st.objEscaped[parentObj] {
					st.fieldOrphans = append(st.fieldOrphans, fieldOrphan{
						varName:   name,
						fieldName: fieldName,
						parentObj: parentObj,
					})
				}
			}
		}
		return
	}

	if v.IsDefine {
		// 新定义必须有类型且类型为 owning
		if v.Type == nil || !isOwning(v.Type) {
			return
		}
		// 新定义：创建新对象绑定
		if exprAllocates(v.Value) {
			site := allocSiteDesc(v.Value)
			id := st.newObj(site)
			st.bindings[name] = id
			if isRCAlloc(v.Value) {
				st.objRCAlloc[id] = true // newRC() 分配，由手动 rcDec 管理
			}
		} else if refObj := getRefObj(v.Value, st); refObj != NilObj {
			// 别名赋值：b = a → b 绑定到 a 的对象
			st.bindings[name] = refObj
		} else {
			// 非分配初始化（如 var tree: *Node = 0），创建空绑定以便后续重赋值追踪
			id := st.newObj("null_init")
			st.bindings[name] = id
			st.objEscaped[id] = true // null 初始化不拥有实际对象，标记为已逃逸避免误 FREE
		}
		return
	}

	// 非定义赋值（name = value）—— 跳过非 owning 目标
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
		if isRCAlloc(v.Value) {
			st.objRCAlloc[newID] = true // newRC() 分配，由手动 rcDec 管理
		}
		// 旧对象不再由此名持有，如果不是参数管理的，记入孤儿列表
		// 全局变量不走孤儿机制（由 RC 管理生命周期）
		if !v.IsGlobal && !isParamObj(st, targetObj) && !st.objEscaped[targetObj] {
			st.orphans = append(st.orphans, targetObj)
		}
	} else if refObj := getRefObj(v.Value, st); refObj != NilObj {
		if v.IsGlobal {
			st.objEscaped[targetObj] = true
			_ = refObj
		} else {
			// 局部间别名：target 重绑到 value 的对象
			st.bindings[name] = refObj
			// 如果引用的对象在同一块内分配，标记为已逃逸
			// 原因：别名变量可能在块外使用（如 head = n 在 for 内，head 在 for 外使用）
			// 不标记会导致 block free 释放后，别名变量成为悬空指针
			if st.objBlockID[refObj] == st.currentBlockID && st.currentBlockID != 0 {
				st.objEscaped[refObj] = true
			}
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

// markCallArgObjExpr 处理表达式中的嵌套调用参数逃逸（如 ret makeNode(val)）。
func markCallArgObjExpr(e *parser.Expression, st *llrState, fb *parser.FuncBlock) {
	if e == nil || e.Call == nil || e.Call.Func == nil {
		return
	}
	calleeKey := e.Call.Func.Name.String()
	if len(calleeKey) > 2 && calleeKey[:2] == "__" &&
		len(calleeKey) > 7 && calleeKey[2:7] != "globa" {
		return
	}
	for idx, ag := range e.Call.Args {
		if ag == nil || ag.Value == nil {
			continue
		}
		esc := ParamEscapes(calleeKey, idx)
		if esc == EscNone {
			continue
		}
		var rec func(ex *parser.Expression)
		rec = func(ex *parser.Expression) {
			if ex == nil {
				return
			}
			if ex.Var != nil && ex.Var.Name != nil {
				n := ex.Var.Name.First()
				if id, ok := st.bindings[n]; ok {
					if esc > EscNone {
						st.objEscaped[id] = true
					}
				}
			}
			rec(ex.Left)
			rec(ex.Right)
			if ex.Call != nil {
				for _, a := range ex.Call.Args {
					rec(a.Value)
				}
			}
		}
		rec(ag.Value)
	}
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
		tag := ""
		if f.ScopeDepth > 0 {
			tag = fmt.Sprintf(" scope=%d", f.ScopeDepth)
		}
		out += fmt.Sprintf("  FREE %s [%s]%s\n", f.VarName, f.Type, tag)
	}
	for _, ff := range res.FieldFrees {
		out += fmt.Sprintf("  FIELD_FREE %s.%s [%s]\n", ff.VarName, ff.FieldName, ff.Type)
	}
	return out
}

// hasRealAnyCalls 过滤掉空字符串等无效条目
func hasRealAnyCalls(calls []string) bool {
	for _, c := range calls {
		if c != "" {
			return true
		}
	}
	return false
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

// DumpFrees 输出全部释放计划（调试辅助）。
func DumpFrees() string {
	keys := make([]string, 0, len(LLRResults))
	for k, res := range LLRResults {
		if res.BlockFreesMap != nil && len(res.BlockFreesMap) > 0 {
			hasFrees := false
			for _, frees := range res.BlockFreesMap {
				if len(frees) > 0 {
					hasFrees = true
					break
				}
			}
			if hasFrees {
				keys = append(keys, k)
			}
		}
	}
	sort.Strings(keys)

	out := ""
	for _, k := range keys {
		res := LLRResults[k]
		out += fmt.Sprintf("== %s\n", k)
		for _, frees := range res.BlockFreesMap {
			for _, f := range frees {
				tag := ""
				if f.ScopeDepth > 0 {
					tag = fmt.Sprintf(" scope=%d", f.ScopeDepth)
				}
				out += fmt.Sprintf("  %s [%s]%s\n", f.VarName, f.Type, tag)
			}
		}
	}
	return out
}

// itoa 简写
func itoa(n int) string { return strconv.Itoa(n) }
