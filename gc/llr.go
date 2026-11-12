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
	// objShared 对象是否被保存到其它变量/字段/容器（存在非 canonical 别名）。
	// 只有唯一绑定且从未共享的对象才能在覆盖赋值点立即释放旧值。
	objShared map[ObjID]bool
	// objReleased 对象是否已在覆盖赋值点释放，后续出口/孤儿/块级释放必须跳过。
	objReleased map[ObjID]bool
	// varBlockID 变量声明时所在的块 ID（块级释放只允许释放本块声明的变量，
	// 避免把“外层变量在分支/循环内被赋值”的对象在块尾释放后仍被外层使用）
	varBlockID map[string]int
	// loopDepth 当前嵌套循环深度（0=不在循环内）
	loopDepth int
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
}

// LLRResult 单函数的 LLR 计算结果。
type LLRResult struct {
	Fn            string                     `json:"fn"`
	Objects       []LLRObj                   `json:"objects"`
	Frees         []LLRFree                  `json:"frees"`      // 出口释放
	FieldFrees    []LLRFieldFree             `json:"fieldFrees"` // 字段级级联释放
	BlockFreesMap map[*parser.Node][]LLRFree `json:"-"`          // 块级释放（按块节点索引）
	// AssignFrees 覆盖赋值点释放（按赋值 VarBlock 节点索引）：旧对象唯一、
	// 未共享、未逃逸时，在 `x = ...` 写入新值前 freeSlot(&x)。
	AssignFrees map[*parser.Node][]LLRFree `json:"-"`
	// LoopExitFrees 循环出口释放（按 for 节点索引）：仅包含循环体内声明的
	// 块局部变量，用于覆盖 break 跳过 body 尾释放的路径；正常迭代已由
	// BlockFreesMap 清槽，freeSlot 幂等跳过。
	LoopExitFrees map[*parser.Node][]LLRFree    `json:"-"`
	RetFrees      []LLRRetFree                  `json:"retFrees,omitempty"` // ret 节点 call 后释放（扁平，调试/输出）
	RetFreesMap   map[*parser.Node][]LLRRetFree `json:"-"`                  // ret 节点 call 后释放（按 return 节点索引）
	// CondFreesMap 条件表达式临时对象释放（按 IfBlock/ForBlock 节点索引）。
	CondFreesMap map[*parser.Node][]LLRCondFree `json:"-"`
	// IncrFreesMap for 增量表达式临时对象释放（按 ForBlock 节点索引）。
	IncrFreesMap map[*parser.Node][]LLRCondFree `json:"-"`
	// RetScratchSlots 本函数单个 return/条件/增量清理点最多需要的临时对象
	// scratch 槽数。Prologue 据此预留；三类清理点不会同时求值，槽位复用。
	RetScratchSlots int `json:"-"`
}

// LLRCondFree 条件/增量表达式中的 owning call 临时对象释放标记。
// 只在能证明调用结果独占（RetFresh、无 alias/borrow mask）且被调自身确有
// 堆分配时登记；非分配包装器（如 strings.view）只建对象、不释放。
type LLRCondFree struct {
	VarName string            `json:"varName"` // 合成槽名（$cond0…，调试用）
	Callee  string            `json:"callee"`  // 调用摘要键
	Call    *parser.CallBlock `json:"-"`       // 调用节点（codegen 捕获槽键）
	Flag    int               `json:"flag"`    // 1 = 条件/增量求值后释放
}

// LLRRetFree ret 节点上的 call 后释放标记。
// 语义：内层 call 返回的拥有型临时对象作为外层 call 的实参，外层不保存也不
// 返回该实参（ParamEscapes=EscNone 且 alias/borrow mask 未命中），故外层调用
// 返回后即可释放。只登记嵌套实参临时，返回值本身不登记。
type LLRRetFree struct {
	VarName string            `json:"varName"` // 合成槽名（$ret0…，调试用）
	Callee  string            `json:"callee"`  // 内层 call 的摘要键
	Call    *parser.CallBlock `json:"-"`       // 内层调用节点（codegen 捕获槽键）
	Flag    int               `json:"flag"`    // 1 = ret 节点上的 call 后释放
}

// LLRObj 一个抽象对象的完整信息。
type LLRObj struct {
	ID       ObjID  `json:"id"`
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

// ComputeLLR 对单个函数做 LLR 分析，返回结果。
// body 为函数体节点，fs 为该函数的摘要。
func ComputeLLR(fnKey string, fb *parser.FuncBlock, fs *FnSummary, body *parser.Node) *LLRResult {
	res := &LLRResult{
		Fn:            fnKey,
		BlockFreesMap: map[*parser.Node][]LLRFree{},
		AssignFrees:   map[*parser.Node][]LLRFree{},
		LoopExitFrees: map[*parser.Node][]LLRFree{},
		CondFreesMap:  map[*parser.Node][]LLRCondFree{},
		IncrFreesMap:  map[*parser.Node][]LLRCondFree{},
	}

	// 函数级保守门槛：仅当存在未知调用时禁用
	if hasRealAnyCalls(fs.CallsAny) {
		return res
	}
	// 有全局拥有存储的函数禁止自动释放帧内对象：全局可能仍持有这些对象，
	// 且跨函数的别名/生命周期无法在本帧证明。
	if fs.HasGlobalOwnStore {
		return res
	}
	// 无堆分配的函数：跳过 LLR 分析（无可释放的堆 ptr）
	if !fs.HasHeapAllocs {
		return res
	}

	st := &llrState{
		bindings:    map[string]ObjID{},
		objEscaped:  map[ObjID]bool{},
		objRCAlloc:  map[ObjID]bool{},
		objSite:     map[ObjID]string{},
		objScope:    map[ObjID]int{},
		objBlockID:  map[ObjID]int{},
		objShared:   map[ObjID]bool{},
		objReleased: map[ObjID]bool{},
		varBlockID:  map[string]int{},
		nextObj:     0,
		nextBlockID: 1, // 从 1 开始，0 留给函数体
	}

	// 参数中的拥有指针：绑定为 param 对象（调用者管理，不自动释放）
	paramNames := map[string]bool{}
	for _, ag := range fb.Args {
		if ag.Type != nil && owningType(ag.Type) && ag.Name != nil {
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
	scanStatements(body, st, fb, paramNames, res)

	// 循环出口释放：循环体内声明的块局部变量在 break 跳过 body 尾释放时，
	// 由 for_end 后的 cleanup 释放。正常迭代 body 尾已清槽，freeSlot 幂等。
	for node, frees := range res.BlockFreesMap {
		if _, ok := node.Value.(*parser.ForBlock); ok {
			res.LoopExitFrees[node] = append([]LLRFree(nil), frees...)
		}
	}

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
		released := st.objReleased[id]
		frameOwn := !escaped && !released && !isParamObj(st, id)

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
		if escaped || st.objReleased[id] || isParamObj(st, id) {
			continue
		}
		site := st.objSite[id]
		res.Objects = append(res.Objects, LLRObj{
			ID: id, Site: site, Escaped: false,
			Name: "", FrameOwn: true,
		})
		res.Frees = append(res.Frees, LLRFree{VarName: site, Type: "heap-ptr", ScopeDepth: st.objScope[id]})
	}

	// 字段级孤儿：字段赋值时旧值需要在函数出口释放。
	// 前置条件：容器自身必须在出口被释放（res.Frees 里有它）。若容器逃逸
	// （如 ret root 把整棵树交给调用者），在出口拆它的字段就是 use-after-free
	// ——调用方拿到的容器已被掏空。satisfied 时旧字段值留在容器里，宁可漏放。
	freedContainers := map[string]bool{}
	for _, fr := range res.Frees {
		freedContainers[fr.VarName] = true
	}
	fieldSeen := map[string]bool{}
	for _, fo := range st.fieldOrphans {
		if !freedContainers[fo.varName] {
			continue // 容器不归本帧出口释放，字段级联无宿主
		}
		key := fo.varName + "." + fo.fieldName
		if fieldSeen[key] {
			continue // 同一字段只需释放一次（最后一次赋值的旧值）
		}
		fieldSeen[key] = true
		// 查找父变量的类型，确定字段的类型 kind
		fieldTypeKind := lookupFieldTypeKind(fb, body, fo.varName, fo.fieldName)
		if fieldTypeKind == "" || fieldTypeKind == "string" {
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

	// ret 节点 call 后释放：收集 return 表达式里“外层调用不保存/不返回”的
	// 嵌套 owning call 临时对象。放在摘要收紧之后，读取的是最终 Table。
	res.RetFrees, res.RetFreesMap, res.RetScratchSlots = collectRetFrees(fb, body)
	// 条件/增量清理点与 ret 不会同时求值，scratch 槽可复用；取最大需求。
	for _, frees := range res.CondFreesMap {
		if len(frees) > res.RetScratchSlots {
			res.RetScratchSlots = len(frees)
		}
	}
	for _, frees := range res.IncrFreesMap {
		if len(frees) > res.RetScratchSlots {
			res.RetScratchSlots = len(frees)
		}
	}

	return res
}

// collectRetFrees 收集函数体内每个 return 节点上的 call 后释放标记。
// 返回：扁平标记列表、按 return 节点索引的映射、单节点最大标记数（scratch 槽数）。
func collectRetFrees(fb *parser.FuncBlock, body *parser.Node) ([]LLRRetFree, map[*parser.Node][]LLRRetFree, int) {
	var flat []LLRRetFree
	byNode := map[*parser.Node][]LLRRetFree{}
	maxSlots := 0
	seq := 0

	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if n == nil {
			return
		}
		if ret, ok := n.Value.(*parser.ReturnBlock); ok {
			seen := map[*parser.CallBlock]bool{}
			var frees []LLRRetFree
			report := func(inner *parser.CallBlock, callee string) {
				if inner == nil || seen[inner] {
					return
				}
				seen[inner] = true
				rf := LLRRetFree{
					VarName: "$ret" + itoa(seq),
					Callee:  callee,
					Call:    inner,
					Flag:    1,
				}
				seq++
				frees = append(frees, rf)
				flat = append(flat, rf)
			}
			for _, rv := range ret.Value {
				collectRetFreesExpr(rv, report)
			}
			if len(frees) > 0 {
				byNode[n] = frees
				if len(frees) > maxSlots {
					maxSlots = len(frees)
				}
			}
		}
		for _, ch := range n.Children {
			walk(ch)
		}
		// IfBlock.ElseBlock 不在 Children 列表里，需显式下钻。
		if ib, ok := n.Value.(*parser.IfBlock); ok && ib != nil && ib.ElseBlock != nil {
			walk(ib.ElseBlock)
		}
	}
	walk(body)
	return flat, byNode, maxSlots
}

// collectRetFreesExpr 后序遍历表达式，识别可在外层 call 返回后释放的嵌套
// owning call 临时对象。
//
// 安全条件（全部满足才登记）：
//  1. 内层 call 返回值 RetFresh 且 alias/borrow mask 均为 0（caller 独占）；
//  2. 内层 call 直接作为外层 call 的实参（不做任意表达式折叠）；
//  3. 外层参数摘要为 EscNone（不保存实参地址）；
//  4. 外层摘要存在且不是 RetUnknown，且其返回 alias/borrow mask 未命中该实参
//     （外层不会把该实参返回出去）；纯内建视为不返回实参。
func collectRetFreesExpr(e *parser.Expression, report func(*parser.CallBlock, string)) {
	if e == nil {
		return
	}
	if e.Call != nil {
		outer := e.Call
		outerKey := callKey(outer)
		outerFS := Table[outerKey]
		outerSafe := false
		if outerFS != nil {
			outerSafe = outerFS.RetKind != RetUnknown
		} else if _, pure := pureBuiltinEscapes(outerKey); pure {
			outerSafe = true
		}
		if outerSafe {
			for idx, ag := range outer.Args {
				if ag == nil || ag.Value == nil || ag.Value.Call == nil {
					continue
				}
				inner := ag.Value.Call
				innerFS := Table[callKey(inner)]
				if innerFS == nil || !innerFS.RetOwned || innerFS.RetKind != RetFresh ||
					innerFS.RetAliasMask != 0 || innerFS.RetBorrowMask != 0 {
					continue
				}
				if ParamEscapes(outerKey, idx) != EscNone {
					continue
				}
				if outerFS != nil {
					bit := uint64(1) << uint(idx)
					if outerFS.RetAliasMask&bit != 0 || outerFS.RetBorrowMask&bit != 0 {
						continue
					}
				}
				report(inner, callKey(inner))
			}
		}
		for _, ag := range outer.Args {
			if ag != nil {
				collectRetFreesExpr(ag.Value, report)
			}
		}
	}
	collectRetFreesExpr(e.Left, report)
	collectRetFreesExpr(e.Right, report)
	for _, ix := range e.Index {
		if ix != nil {
			collectRetFreesExpr(ix.Left, report)
			collectRetFreesExpr(ix.Right, report)
		}
	}
}

// RetFreesForNode 返回指定函数某个 return 节点上的 call 后释放标记。
func RetFreesForNode(fnKey string, n *parser.Node) []LLRRetFree {
	llr := LLRResults[fnKey]
	if llr == nil || llr.RetFreesMap == nil {
		return nil
	}
	return llr.RetFreesMap[n]
}

// CondFreesForNode 返回指定 if/for 节点条件表达式上的临时对象释放标记。
func CondFreesForNode(fnKey string, n *parser.Node) []LLRCondFree {
	llr := LLRResults[fnKey]
	if llr == nil || llr.CondFreesMap == nil {
		return nil
	}
	return llr.CondFreesMap[n]
}

// IncrFreesForNode 返回指定 for 节点增量表达式上的临时对象释放标记。
func IncrFreesForNode(fnKey string, n *parser.Node) []LLRCondFree {
	llr := LLRResults[fnKey]
	if llr == nil || llr.IncrFreesMap == nil {
		return nil
	}
	return llr.IncrFreesMap[n]
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
		// 同基字段互赋（x.f = x.g）会让字段互为别名，逐字段释放不安全。
		if fieldAliasStructs[structType.TypeName] {
			continue
		}
		structType.Layout()
		for _, field := range structType.Fields() {
			if field.Type == nil {
				continue
			}
			// 字符串字段可能是源码视图/字面量，不保证指向 malloc 块；
			// 字段级联只处理指针字段。
			if field.Type.Kind() == "string" {
				continue
			}
			if owningType(field.Type) {
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
// res 记录块级/覆盖赋值/条件/增量释放计划。
func scanStatements(body *parser.Node, st *llrState, fb *parser.FuncBlock, paramNames map[string]bool, res *LLRResult) {
	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if n == nil {
			return
		}
		switch v := n.Value.(type) {
		case *parser.VarBlock:
			processAssign(n, v, st, fb, paramNames, res.AssignFrees)
		case *parser.Expression:
			// 简单赋值/字段赋值可能以 Expression.Var 形式出现，统一走
			// processAssign，保证覆盖释放计划与代码生成节点一致。
			if v.Var != nil && v.Var.Value != nil {
				processAssign(n, v.Var, st, fb, paramNames, res.AssignFrees)
			} else if v.Separator == "[]=" || v.Separator == "=" {
				// 元素/字段写入会把右值对象保存到容器中，形成非 canonical 别名。
				// 这里只标记裸变量引用，阻止其后续被覆盖释放误杀。
				markStoredRefs(v.Right, st)
				// 容器可能活过本块/本帧（列表/堆对象），右值按逃逸处理。
				markStoredEscapes(v.Right, st)
			}
			markExprCallArgs(v.Right, st)
		case *parser.ReturnBlock:
			retOwns := len(fb.Return) > 0 && owningType(fb.Return[0])
			if retOwns {
				markAllReferencedObjs(v, st, fb)
			}
			for _, rv := range v.Value {
				if rv == nil {
					continue
				}
				// 返回表达式内所有调用实参都按摘要传播逃逸（含嵌套调用）。
				markExprCallArgs(rv, st)
				if rv.Call != nil {
					// Escape call results that return owning types (e.g. ret makeNode(val))
					if retOwns {
						if fs := callSummary(rv.Call); fs != nil && fs.RetOwned {
							site := "call:" + callKey(rv.Call)
							id := st.newObj(site)
							st.objEscaped[id] = true
						}
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
			for _, ag := range v.Args {
				if ag != nil {
					markExprCallArgs(ag.Value, st)
				}
			}
		case *parser.ForBlock:
			// 循环初始化/条件/增量/range 表达式中的调用同样可能保存实参。
			markExprCallArgs(v.Init, st)
			markExprCallArgs(v.Condition, st)
			markExprCallArgs(v.Increment, st)
			markExprCallArgs(v.Range, st)
			// 初始化/range 只建临时对象（当前无清理点，不登记释放）；
			// 条件每轮求值，增量每轮收尾，均可建立清理点。
			collectExprTemps(v.Init, st, false)
			if frees := collectExprTemps(v.Condition, st, true); len(frees) > 0 {
				res.CondFreesMap[n] = frees
			}
			// 增量是赋值时，右值结果会被变量持有，不能当临时释放。
			incrFree := v.Increment != nil && v.Increment.Var == nil
			if frees := collectExprTemps(v.Increment, st, incrFree); len(frees) > 0 {
				res.IncrFreesMap[n] = frees
			}
			collectExprTemps(v.Range, st, false)
			st.scopeDepth++
			st.loopDepth++
			savedBlockID := st.currentBlockID
			st.currentBlockID = st.nextBlockID
			st.nextBlockID++
			for _, ch := range n.Children {
				walk(ch)
			}
			// 退出 for 循环块：收集该块的释放条目
			frees := collectBlockFrees(st, st.currentBlockID, fb, body)
			if len(frees) > 0 {
				res.BlockFreesMap[n] = frees
			}
			st.currentBlockID = savedBlockID
			st.loopDepth--
			st.scopeDepth--
			return
		case *parser.IfBlock:
			markExprCallArgs(v.Condition, st)
			if frees := collectExprTemps(v.Condition, st, true); len(frees) > 0 {
				res.CondFreesMap[n] = frees
			}
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
				res.BlockFreesMap[n] = frees
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
					res.BlockFreesMap[v.ElseBlock] = ef
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

// collectExprTemps 为表达式中的 owning call 结果建立抽象对象；当 allowFree
// 为真且能证明结果独占、被调自身有堆分配时，登记条件/增量临时释放标记。
// 返回的槽名按清理点内序号编号；同一调用只登记一次。
func collectExprTemps(e *parser.Expression, st *llrState, allowFree bool) []LLRCondFree {
	if e == nil {
		return nil
	}
	var out []LLRCondFree
	seen := map[*parser.CallBlock]bool{}
	var walk func(x *parser.Expression, freeOK bool)
	walk = func(x *parser.Expression, freeOK bool) {
		if x == nil {
			return
		}
		if x.Call != nil {
			cb := x.Call
			key := callKey(cb)
			fs := Table[key]
			if fs != nil && fs.RetOwned && !cb.IsRC && !seen[cb] {
				seen[cb] = true
				id := st.newObj("call:" + key)
				if freeOK && allowFree && condTempFreeable(fs) {
					out = append(out, LLRCondFree{
						VarName: "$cond" + itoa(len(out)),
						Callee:  key,
						Call:    cb,
						Flag:    1,
					})
				} else {
					// 包装器/未知别名/被外层保存：保留对象可见性，但不自动释放。
					st.objEscaped[id] = true
				}
			}
			for i, ag := range cb.Args {
				if ag == nil {
					continue
				}
				walk(ag.Value, freeOK && callArgSafe(cb, i))
			}
			for _, ag := range cb.VariadicArgs {
				if ag != nil {
					walk(ag.Value, false)
				}
			}
		}
		walk(x.Left, freeOK)
		walk(x.Right, freeOK)
		for _, ix := range x.Index {
			if ix != nil {
				walk(ix.Left, freeOK)
				walk(ix.Right, freeOK)
			}
		}
		// 列表字面量会把元素指针存入容器，不能当独立临时释放。
		for _, el := range x.ListElems {
			walk(el, false)
		}
	}
	walk(e, allowFree)
	return out
}

// condTempFreeable 判断一次 owning call 的结果能否作为独立临时释放。
// 必须同时满足：新分配、无参数别名/借用 mask、被调自身确有堆分配。
// 最后一条排除 strings.view 这类只包装外部 ptr 的非分配函数：
// 其 RetFresh 目前只是“返回局部容器”的近似，底层缓冲仍由调用方/容器持有。
func condTempFreeable(fs *FnSummary) bool {
	if fs == nil || !fs.RetOwned || fs.RetKind != RetFresh {
		return false
	}
	if fs.RetAliasMask != 0 || fs.RetBorrowMask != 0 {
		return false
	}
	return fs.HasHeapAllocs
}

// callArgSafe 判断外层调用第 idx 个实参是否只被读取：不保存、不返回、
// 不通过返回值别名/借用。只有安全时，实参表达式内部的临时对象才能在
// 外层调用返回后释放。
func callArgSafe(cb *parser.CallBlock, idx int) bool {
	if cb == nil {
		return false
	}
	key := callKey(cb)
	fs := Table[key]
	if fs == nil {
		_, pure := pureBuiltinEscapes(key)
		return pure
	}
	if ParamEscapes(key, idx) != EscNone {
		return false
	}
	bit := uint64(1) << uint(idx)
	return fs.RetAliasMask&bit == 0 && fs.RetBorrowMask&bit == 0
}

// collectBlockFrees 收集指定块 ID 的所有帧内拥有对象，生成块级释放条目。
func collectBlockFrees(st *llrState, blockID int, fb *parser.FuncBlock, body *parser.Node) []LLRFree {
	var frees []LLRFree
	for id := range st.objSite {
		if st.objBlockID[id] != blockID {
			continue
		}
		if st.objEscaped[id] || st.objReleased[id] || isParamObj(st, id) {
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
		// 只释放本块声明的变量：外层变量在本块内被赋值时，其对象生命周期
		// 属于外层作用域，块尾释放会导致汇合后/循环出口使用悬空指针。
		// 外层变量的旧值由覆盖点释放（或保守地留到函数出口）。
		if declBlock, declared := st.varBlockID[mainName]; !declared || declBlock != blockID {
			continue
		}
		tk := typeKindOf(st, id, fb, body)
		frees = append(frees, LLRFree{VarName: mainName, Type: tk, ScopeDepth: st.objScope[id]})
	}
	return frees
}

// processAssign 处理赋值/定义语句。
func processAssign(n *parser.Node, v *parser.VarBlock, st *llrState, fb *parser.FuncBlock, paramNames map[string]bool, assignFreesMap map[*parser.Node][]LLRFree) {
	name := ""
	if v.Name != nil {
		name = v.Name.First()
	}
	if name == "" {
		return
	}

	// 右值中的所有调用都可能保存实参；先传播逃逸，再决定覆盖/孤儿。
	if v.Value != nil {
		markExprCallArgs(v.Value, st)
		markStoredRefs(v.Value, st)
	}

	// 定义 + 无值 + owning 类型 → null_init 绑定（var x: *T）
	// 例如 var result: *Node —— 需要绑定以便后续 result = n 追踪
	if v.IsDefine && v.Value == nil && v.Type != nil && owningType(v.Type) {
		id := st.newObj("null_init")
		st.bindings[name] = id
		st.varBlockID[name] = st.currentBlockID
		st.objEscaped[id] = true
		return
	}

	if v.Value == nil {
		return
	}

	// 字段赋值（node.left = X）：跟踪字段级 orphan，不重绑父变量
	if len(v.Name) > 1 {
		if !v.IsDefine {
			// 右值对象被保存进字段：既形成非 canonical 别名（禁止覆盖释放），
			// 也按 EscHeapObj 逃逸（禁止块尾/函数出口释放）。字段宿主可能是
			// 参数或更外层对象，其生命周期不受本块约束；若宿主是本帧容器，
			// 字段级级联释放会负责回收，重复释放同样致命。
			if refObj := getRefObj(v.Value, st); refObj != NilObj {
				st.objShared[refObj] = true
				st.objEscaped[refObj] = true
			}
			// 列表字面量元素会随容器一起存活，按逃逸处理。
			markStoredEscapes(v.Value, st)
			if exprAllocates(v.Value) {
				fieldName := v.Name.Last()
				// 查找父变量当前绑定的对象
				if parentObj, ok := st.bindings[name]; ok {
					// 只有帧内拥有的父对象才需要字段级 orphan free
					// 已逃逸的对象由调用者管理，不在本帧释放
					if !isParamObj(st, parentObj) && !st.objEscaped[parentObj] {
						st.fieldOrphans = append(st.fieldOrphans, fieldOrphan{
							varName:   name,
							fieldName: fieldName,
						})
					}
				}
			}
		}
		return
	}

	if v.IsDefine {
		// 新定义必须有类型且类型为 owning
		if v.Type == nil || !owningType(v.Type) {
			return
		}
		st.varBlockID[name] = st.currentBlockID
		// 新定义：创建新对象绑定
		if exprAllocates(v.Value) {
			site := allocSiteDesc(v.Value)
			id := st.newObj(site)
			st.bindings[name] = id
			if isRCExpr(v.Value) {
				st.objRCAlloc[id] = true // newRC() 分配，由手动 rcDec 管理
			}
		} else if refObj := getRefObj(v.Value, st); refObj != NilObj {
			// 别名赋值：b = a → b 绑定到 a 的对象；a 不再是唯一 owner。
			st.objShared[refObj] = true
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

	refObj := getRefObj(v.Value, st)

	if v.IsGlobal {
		// 全局目标：旧对象与新右值都逃逸到全局，由全局/RC 生命周期管理。
		st.objEscaped[targetObj] = true
		if refObj != NilObj {
			st.objEscaped[refObj] = true
		}
		return
	}

	// 覆盖前释放：旧对象唯一、未共享、未逃逸，且右值不引用目标变量本身
	// （如 c = c.next / head = prepend(head, ...) 一律保留旧值）。
	if refObj != targetObj && canFreeOverwrite(st, targetObj, name) && !exprReferencesVar(v.Value, name) {
		tk := "string"
		if v.Type != nil {
			tk = v.Type.Kind()
		}
		st.objReleased[targetObj] = true
		assignFreesMap[n] = append(assignFreesMap[n], LLRFree{
			VarName:    name,
			Type:       tk,
			ScopeDepth: st.objScope[targetObj],
		})
	}

	// 局部目标：重新绑定
	if exprAllocates(v.Value) {
		site := allocSiteDesc(v.Value)
		newID := st.newObj(site)
		st.bindings[name] = newID
		if isRCExpr(v.Value) {
			st.objRCAlloc[newID] = true // newRC() 分配，由手动 rcDec 管理
		}
		// 旧对象不再由此名持有；已覆盖释放的不再记孤儿（孤儿机制当前不会
		// 在出口实际释放无名对象，仅保留调试信息）。
		if !st.objReleased[targetObj] && !isParamObj(st, targetObj) && !st.objEscaped[targetObj] {
			st.orphans = append(st.orphans, targetObj)
		}
	} else if refObj != NilObj {
		// 局部间别名：target 重绑到 value 的对象
		st.objShared[refObj] = true
		st.bindings[name] = refObj
		// 如果引用的对象在同一块内分配，标记为已逃逸
		// 原因：别名变量可能在块外使用（如 head = n 在 for 内，head 在 for 外使用）
		// 不标记会导致 block free 释放后，别名变量成为悬空指针
		if st.objBlockID[refObj] == st.currentBlockID && st.currentBlockID != 0 {
			st.objEscaped[refObj] = true
		}
	} else {
		// 右值不分配也不是裸变量（nil/字段/元素等）：目标不再持有旧对象，
		// 绑定到逃逸的 null_init，避免后续把已释放对象当成仍被持有。
		id := st.newObj("null_init")
		st.bindings[name] = id
		st.objEscaped[id] = true
	}
}

// canFreeOverwrite 判断旧对象能否在覆盖赋值点立即释放。
// 安全前提：唯一绑定、未逃逸、未共享、非参数/RC，且来源可识别为帧内分配。
func canFreeOverwrite(st *llrState, id ObjID, name string) bool {
	if id == NilObj || st.objReleased[id] || st.objEscaped[id] ||
		st.objShared[id] || st.objRCAlloc[id] || isParamObj(st, id) {
		return false
	}
	switch site := st.objSite[id]; {
	case site == "", site == "null_init", site == "unknown", site == "expr":
		return false
	}
	for n, oid := range st.bindings {
		if oid == id && n != name {
			return false // 仍有其它名字持有该对象
		}
	}
	return true
}

// exprReferencesVar 判断表达式是否直接或间接引用了指定变量名。
func exprReferencesVar(e *parser.Expression, name string) bool {
	if e == nil {
		return false
	}
	if e.Var != nil && e.Var.Name != nil && e.Var.Name.First() == name {
		return true
	}
	if exprReferencesVar(e.Left, name) || exprReferencesVar(e.Right, name) {
		return true
	}
	for _, ix := range e.Index {
		if exprReferencesVar(ix, name) {
			return true
		}
	}
	for _, el := range e.ListElems {
		if exprReferencesVar(el, name) {
			return true
		}
	}
	if e.Call != nil {
		for _, ag := range e.Call.Args {
			if ag != nil && exprReferencesVar(ag.Value, name) {
				return true
			}
		}
		for _, ag := range e.Call.VariadicArgs {
			if ag != nil && exprReferencesVar(ag.Value, name) {
				return true
			}
		}
	}
	return false
}

// markStoredRefs 标记被写入列表字面量的裸变量对象为共享。
// 这类对象可能在容器中长期存活，不能作为覆盖释放的候选。
func markStoredRefs(e *parser.Expression, st *llrState) {
	if e == nil {
		return
	}
	for _, el := range e.ListElems {
		if id := getRefObj(el, st); id != NilObj {
			st.objShared[id] = true
		}
		markStoredRefs(el, st)
	}
	if e.Call != nil {
		for _, ag := range e.Call.Args {
			if ag != nil {
				markStoredRefs(ag.Value, st)
			}
		}
		for _, ag := range e.Call.VariadicArgs {
			if ag != nil {
				markStoredRefs(ag.Value, st)
			}
		}
	}
	markStoredRefs(e.Left, st)
	markStoredRefs(e.Right, st)
	for _, ix := range e.Index {
		markStoredRefs(ix, st)
	}
}

// markStoredEscapes 标记写入容器的右值中直接引用的对象为逃逸。
// 覆盖裸变量、列表字面量元素与复合字面量；调用实参的逃逸由被调摘要
// （markExprCallArgs）单独传播，避免把所有调用实参一律当成已存储。
func markStoredEscapes(e *parser.Expression, st *llrState) {
	if e == nil {
		return
	}
	if id := getRefObj(e, st); id != NilObj {
		st.objEscaped[id] = true
	}
	for _, el := range e.ListElems {
		markStoredEscapes(el, st)
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
	if cb == nil {
		return
	}
	calleeKey := callKey(cb)

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

// markExprCallArgs 递归遍历表达式中的所有调用点，按被调摘要传播实参逃逸。
// 赋值右值、条件、return 等所有表达式位置都应调用它，否则“外层变量被传给
// 可能保存它的被调”不会被标记逃逸，后续覆盖/块尾释放会误杀仍被引用的对象。
func markExprCallArgs(e *parser.Expression, st *llrState) {
	if e == nil {
		return
	}
	if e.Call != nil {
		markCallArgObjs(e.Call, st, nil)
		for _, ag := range e.Call.Args {
			if ag != nil {
				markExprCallArgs(ag.Value, st)
			}
		}
		for _, ag := range e.Call.VariadicArgs {
			if ag != nil {
				markExprCallArgs(ag.Value, st)
			}
		}
	}
	markExprCallArgs(e.Left, st)
	markExprCallArgs(e.Right, st)
	for _, ix := range e.Index {
		markExprCallArgs(ix, st)
	}
	for _, elem := range e.ListElems {
		markExprCallArgs(elem, st)
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
	for _, rf := range res.RetFrees {
		out += fmt.Sprintf("  RET_FREE %s after=call:%s flag=%d\n", rf.VarName, rf.Callee, rf.Flag)
	}
	for node, frees := range res.CondFreesMap {
		_ = node
		for _, cf := range frees {
			out += fmt.Sprintf("  COND_FREE %s after=call:%s flag=%d\n", cf.VarName, cf.Callee, cf.Flag)
		}
	}
	for node, frees := range res.IncrFreesMap {
		_ = node
		for _, cf := range frees {
			out += fmt.Sprintf("  INCR_FREE %s after=call:%s flag=%d\n", cf.VarName, cf.Callee, cf.Flag)
		}
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
		if e.Call.IsBuiltinNewAlloc() {
			return "new"
		}
		if fs := callSummary(e.Call); fs != nil && fs.RetOwned {
			return "call:" + callKey(e.Call)
		}
	}
	if e.Separator == "+" {
		return "string-concat"
	}
	return "expr"
}

// itoa 简写
func itoa(n int) string { return strconv.Itoa(n) }
