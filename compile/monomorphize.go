package compile

import (
	"fmt"
	"strings"

	"cuteify/compile/arch"
	"cuteify/compile/gc"
	"cuteify/parser"
	typeSys "cuteify/type"
)

// GenericInstantiation 记录一个单态化的函数特化。
type GenericInstantiation struct {
	Original    *parser.FuncBlock
	SubstMap    map[string]typeSys.Type
	FuncLabel   string
	Specialized *parser.FuncBlock
}

// genericRegistry 跟踪所有泛型函数的单态化特化。
type genericRegistry struct {
	specializations map[string]*GenericInstantiation
}

func newGenericRegistry() *genericRegistry {
	return &genericRegistry{
		specializations: make(map[string]*GenericInstantiation),
	}
}

// 全局泛型注册表，编译器生命周期内复用。
var generics = newGenericRegistry()

// buildGenericLabel 根据函数名和类型替换映射生成唯一的 NASM 标签名。
// 例如 max__int、max__string、swap__i32。
func buildGenericLabel(funcName string, subst map[string]typeSys.Type) string {
	var parts []string
	parts = append(parts, funcName)
	// 按参数名排序，确保确定性
	for paramName, concreteType := range subst {
		parts = append(parts, paramName+"__"+concreteType.Type())
	}
	return strings.Join(parts, "__")
}

// IsGenericFunction 判断函数是否包含类型参数（即为泛型函数）。
func IsGenericFunction(fn *parser.FuncBlock) bool {
	return fn != nil && len(fn.TypeParams) > 0
}

// MonomorphizeIfNeeded 检查调用是否目标为泛型函数，若是则创建单态化特化。
// 返回特化后的标签名，空字符串表示不需要单态化。
func (c *Compiler) MonomorphizeIfNeeded(call *parser.CallBlock) string {
	if call == nil || call.Func == nil {
		return ""
	}
	fn := call.Func
	if len(fn.TypeParams) == 0 {
		return ""
	}

	// 优先使用显式 [Type] 语法指定的类型参数（如 leadingZeros[u32](1)）
	substMap := make(map[string]typeSys.Type)
	if call.NewType != nil && len(fn.TypeParams) > 0 {
		for _, tp := range fn.TypeParams {
			substMap[tp.Name] = call.NewType
		}
	} else {
		// 否则从调用参数推断类型参数的具体类型
		substMap = c.inferTypeParams(fn, call)
	}
	if substMap == nil {
		return ""
	}

	// Cache: check by FuncBlock pointer (handles fn.Name mutation by compileCallBlock/exp.go)
	for _, inst := range generics.specializations {
		if inst.Original == fn && typeSubstMapEq(inst.SubstMap, substMap) {
			return inst.FuncLabel
		}
	}
	// Also check by original name (handles the case where fn.Name hasn't been mutated yet)
	origName := fn.Name.String()
	key := buildGenericLabel(origName, substMap)
	if inst, ok := generics.specializations[key]; ok {
		return inst.FuncLabel
	}

	// 创建特化副本
	specialized := c.MonomorphizeFunction(fn, substMap)
	label := buildGenericLabel(fn.Name.NASM(), substMap)

	// 将 TypeSubst 存储在编译器中，供特化函数编译时 codegen 使用（sizeof 等内建需要）
	if c.typeSubsts == nil {
		c.typeSubsts = map[string]map[string]typeSys.Type{}
	}
	c.typeSubsts[label] = substMap

	// Suppress the original generic function from being compiled (it's replaced by the specialized version)
	fn.Useful = false

	inst := &GenericInstantiation{
		Original:    fn,
		SubstMap:    substMap,
		FuncLabel:   label,
		Specialized: specialized,
	}
	// Store under both original name key and pointer key for future lookups
	generics.specializations[key] = inst

	// 找到原始函数所在的 AST 节点，复制其子节点（函数体）给特化函数
	origNode := c.findFuncNode(fn)
	c.addSpecializedFunc(specialized, fn, origNode, substMap)

	return label
}

// typeSubstMapEq compares two type substitution maps for equality.
func typeSubstMapEq(a, b map[string]typeSys.Type) bool {
	if len(a) != len(b) {
		return false
	}
	for k, va := range a {
		vb, ok := b[k]
		if !ok || va.Type() != vb.Type() {
			return false
		}
	}
	return true
}

// inferTypeParams 从调用实参推断类型参数替换映射。
// 通过对比参数定义类型和调用实参类型，从嵌套类型中提取 TypeParam 的具体类型。
func (c *Compiler) inferTypeParams(fn *parser.FuncBlock, call *parser.CallBlock) map[string]typeSys.Type {
	if len(fn.TypeParams) == 0 {
		return nil
	}

	subst := make(map[string]typeSys.Type)
	for _, tp := range fn.TypeParams {
		// 遍历所有参数，对比定义类型和实参类型
		for j := 0; j < len(fn.Args) && j < len(call.Args); j++ {
			defType := fn.Args[j].Type
			argType := call.Args[j].Type
			if call.Args[j].Value != nil && call.Args[j].Value.Type != nil {
				argType = call.Args[j].Value.Type
			}
			if defType == nil || argType == nil {
				continue
			}
			// 并行遍历定义类型和实参类型，找到 TypeParam 对应的具体类型
			if concrete := matchTypeParam(defType, argType, tp.Name); concrete != nil {
				subst[tp.Name] = concrete
				break
			}
		}
	}

	// 确保所有类型参数都被解析
	for _, tp := range fn.TypeParams {
		if _, ok := subst[tp.Name]; !ok {
			return nil
		}
	}
	return subst
}

// matchTypeParam 并行遍历 defType 和 argType，在 defType 中找到 TypeParam 后
// 从 argType 对应位置提取具体类型。
func matchTypeParam(defType, argType typeSys.Type, paramName string) typeSys.Type {
	if defType == nil || argType == nil {
		return nil
	}
	// defType 是目标 TypeParam → 返回 argType 的具体类型
	if tp, ok := defType.(*typeSys.TypeParam); ok && tp.Name == paramName {
		// argType 不能也是 TypeParam（否则无具体信息）
		if _, argIsTP := argType.(*typeSys.TypeParam); !argIsTP {
			return argType
		}
		return nil
	}
	// 递归：比较 defType.Elem() 和 argType.Elem()
	defElem := defType.Elem()
	argElem := argType.Elem()
	if defElem != nil && argElem != nil {
		return matchTypeParam(defElem, argElem, paramName)
	}
	return nil
}

// MonomorphizeFunction 创建泛型函数的特化副本，用具体类型替换所有类型参数。
func (c *Compiler) MonomorphizeFunction(fn *parser.FuncBlock, typeSubst map[string]typeSys.Type) *parser.FuncBlock {
	if fn == nil || len(fn.TypeParams) == 0 {
		return fn
	}

	newName := buildGenericLabel(fn.Name.NASM(), typeSubst)

	// 创建特化后的参数列表
	specializedArgs := make([]*parser.ArgBlock, len(fn.Args))
	for i, arg := range fn.Args {
		sub := typeSys.SubstituteTypeParams(arg.Type, typeSubst)
		newArg := &parser.ArgBlock{
			Name:    arg.Name,
			Type:    sub,
			Default: arg.Default,
			Offset:  arg.Offset,
		}
		specializedArgs[i] = newArg
	}

	// 重新计算参数偏移量（原始偏移量基于 TypeParam 的 Size()=-1，需要修正）
	// x86 cdecl: [ebp+0]=saved_ebp, [ebp+4]=return_addr, [ebp+8]=first_arg
	// x86_64 sysv: [rbp+0]=saved_rbp, [rbp+8]=return_addr, [rbp+16]=first_arg (16-byte aligned)
	pointerSize := c.Ctx.Arch.PointerSize()
	argOffset := pointerSize * 2 // skip saved EBP/RBP + return address
	for _, arg := range specializedArgs {
		arg.Offset = argOffset
		argSize := arg.Type.Size()
		if argSize < 0 {
			argSize = pointerSize
		}
		argOffset += argSize
	}

	// 创建特化后的返回类型列表
	specializedReturn := make([]typeSys.Type, len(fn.Return))
	for i, ret := range fn.Return {
		specializedReturn[i] = typeSys.SubstituteTypeParams(ret, typeSubst)
	}

	// 构建特化后的函数名（Name 是 []NamePart，创建新的）
	specializedName := parser.NewName(newName)

	specialized := &parser.FuncBlock{
		Args:            specializedArgs,
		Class:           typeSys.SubstituteTypeParams(fn.Class, typeSubst),
		Return:          specializedReturn,
		Name:            specializedName,
		BuildFlags:      fn.BuildFlags,
		Useful:          true,
		TypeParams:      nil,     // 特化后不再是泛型
		MangledOverride: newName, // 确保 MangledName() 返回正确的单态化标签
	}

	return specialized
}

// findFuncNode 在 AST 中查找包含给定 FuncBlock 的节点。
// 优先使用 funcNodeMap 进行跨包查找，然后回退到树遍历。
func (c *Compiler) findFuncNode(fn *parser.FuncBlock) *parser.Node {
	// 优先从 funcNodeMap 查找（跨包支持）
	if c.funcNodeMap != nil {
		if node, ok := c.funcNodeMap[fn]; ok {
			return node
		}
	}
	root := c.Ctx.Now
	if root == nil {
		return nil
	}
	for root.Father != nil {
		root = root.Father
	}
	return findNodeByFuncBlock(root, fn)
}

func findNodeByFuncBlock(node *parser.Node, fn *parser.FuncBlock) *parser.Node {
	if node == nil {
		return nil
	}
	if fb, ok := node.Value.(*parser.FuncBlock); ok && fb == fn {
		return node
	}
	for _, child := range node.Children {
		if found := findNodeByFuncBlock(child, fn); found != nil {
			return found
		}
	}
	return nil
}

// deepCopyNode creates a deep copy of a parser.Node and all its descendants,
// ensuring that modifications to the copy (e.g., type substitution, remapping)
// do not affect the original AST tree.
func deepCopyNode(n *parser.Node) *parser.Node {
	if n == nil {
		return nil
	}
	cp := &parser.Node{
		Ignore:  n.Ignore,
		Checked: n.Checked,
	}
	cp.Value = deepCopyBlock(n.Value)
	// 病灶⑯随修：IfBlock.ElseBlock 深拷贝出的 else 子树节点不在任何
	// Children 列表里（它是克隆 if 节点的"结构体指针儿子"），这里把它的
	// Father 重绑到克隆 if 节点，恢复向上找宿主函数/块的 Father 链
	// （collectFnNameOfN / remap 走宿主函数名都依赖它）。
	if ib, ok := cp.Value.(*parser.IfBlock); ok && ib != nil && ib.ElseBlock != nil {
		if defVar, ok2 := n.Value.(*parser.IfBlock); ok2 && defVar != nil && ib.ElseBlock != defVar.ElseBlock {
			ib.ElseBlock.Father = cp
		}
	}
	for _, child := range n.Children {
		childCopy := deepCopyNode(child)
		if childCopy != nil {
			childCopy.Father = cp
		}
		cp.Children = append(cp.Children, childCopy)
	}
	return cp
}

// deepCopyBlock dispatches to type-specific deep copy functions for each Block variant.
func deepCopyBlock(b parser.Block) parser.Block {
	if b == nil {
		return nil
	}
	switch v := b.(type) {
	case *parser.VarBlock:
		return deepCopyVarBlock(v)
	case *parser.ReturnBlock:
		return deepCopyReturnBlock(v)
	case *parser.IfBlock:
		return deepCopyIfBlock(v)
	case *parser.ElseBlock:
		return deepCopyElseBlock(v)
	case *parser.ForBlock:
		return deepCopyForBlock(v)
	case *parser.SwitchBlock:
		return deepCopySwitchBlock(v)
	case *parser.CallBlock:
		return deepCopyCallBlock(v)
	case *parser.Expression:
		return deepCopyExpression(v)
	default:
		// FuncBlock, TypeBlock, etc. — not expected as child node values;
		// return as-is since they are not mutated by substituteBodyTypes.
		return b
	}
}

// deepCopyFindResult shallow-copies a FindResult. The referenced Node/Value
// targets are intentionally NOT deep-copied — they point to definition sites
// that should remain shared; only the FindResult struct itself is duplicated
// so that remapFuncBodyRefs can update Value/Offset on the copy independently.
func deepCopyFindResult(fr parser.FindResult) parser.FindResult {
	pathCopy := make([]any, len(fr.Path))
	copy(pathCopy, fr.Path)
	return parser.FindResult{
		Node:       fr.Node,
		Value:      fr.Value,
		Path:       pathCopy,
		Type:       fr.Type,
		MultiIndex: fr.MultiIndex,
	}
}

// deepCopyVarBlock creates an independent copy of a VarBlock.
func deepCopyVarBlock(v *parser.VarBlock) *parser.VarBlock {
	if v == nil {
		return nil
	}
	cp := &parser.VarBlock{
		Name:          deepCopyName(v.Name),
		MultiNames:    deepCopyNames(v.MultiNames),
		MultiOffsets:  append([]int(nil), v.MultiOffsets...),
		MultiIndex:    v.MultiIndex,
		IsConst:       v.IsConst,
		Value:         deepCopyExpression(v.Value),
		IsDefine:      v.IsDefine,
		IsInitialized: v.IsInitialized,
		Define:        deepCopyFindResult(v.Define),
		Used:          v.Used,
		StartCursor:   v.StartCursor,
		Offset:        v.Offset,
		Type:          v.Type, // Type is an interface; SubstituteTypeParams returns a new value
		IsGlobal:      v.IsGlobal,
	}
	// Life 必须单独拷：它是非导出字段，结构体字面量不会带上它。漏拷会让特化
	// 副本的归属与逃逸信息全丢（Obj/Scope/owner 都是零值）—— 副本里的
	// new() 分配因此不被记录，块永远没人 free。
	parser.CopyLife(cp, v)
	// MultiTypes is []typeSys.Type — shallow copy the slice; individual types
	// are immutable interfaces replaced (not mutated) by SubstituteTypeParams.
	if v.MultiTypes != nil {
		cp.MultiTypes = make([]typeSys.Type, len(v.MultiTypes))
		copy(cp.MultiTypes, v.MultiTypes)
	}
	return cp
}

// deepCopyReturnBlock creates an independent copy of a ReturnBlock.
func deepCopyReturnBlock(v *parser.ReturnBlock) *parser.ReturnBlock {
	if v == nil {
		return nil
	}
	cp := &parser.ReturnBlock{}
	if v.Value != nil {
		cp.Value = make([]*parser.Expression, len(v.Value))
		for i, exp := range v.Value {
			cp.Value[i] = deepCopyExpression(exp)
		}
	}
	return cp
}

// deepCopyIfBlock creates an independent copy of an IfBlock.
func deepCopyIfBlock(v *parser.IfBlock) *parser.IfBlock {
	if v == nil {
		return nil
	}
	cp := &parser.IfBlock{
		Else:      v.Else,
		Condition: deepCopyExpression(v.Condition),
		// Node 仍共享：它指向本 if 节点自身（解析期的自反性结构指针），
		// 单态化不依赖它。
		Node: v.Node,
	}
	// 病灶⑯（2026-11-02）：ElseBlock（else 子树节点）不在 node.Children，
	// 仅经此结构体指针可达：
	//   · 发射：compileElseBlock → c.Compile(ifBlock.ElseBlock)（compiler.go）；
	//   · 盖章：collectVarOffsets 显式用它递归（arch/utils.go）。
	// 原样共享会把"原树 else 语句"直接装进克隆身体——其 Define 仍指原树
	// decl，GenVarAddr 发射期 live 重绑读到"最后一个 Setup(orig) 刷过的
	// 布局"（多 mono 串扰：单 mono 时原树 = 唯一布局，错位不可见；
	// x86_64 mp_map 双 mono（int+string）触发 else 写点整体 +16 → place
	// 读到零值 → *pm = 1 写空指针 SIGSEGV）。同时 deepCopyNode 和
	// remapNodeRefs 的 node.Children 遍历都够不到 else 子树 → 双向漏网。
	// 此处深拷贝 else 子树（deepCopyNode 递归克隆其 Children），克隆 if
	// 节点生成后再把 Father 挂上（deepCopyNode 病灶⑯随修注释）。
	if v.ElseBlock != nil {
		cp.ElseBlock = deepCopyNode(v.ElseBlock)
	}
	return cp
}

// deepCopyElseBlock creates an independent copy of an ElseBlock.
func deepCopyElseBlock(v *parser.ElseBlock) *parser.ElseBlock {
	if v == nil {
		return nil
	}
	return &parser.ElseBlock{
		IfCondition: deepCopyExpression(v.IfCondition),
	}
}

// deepCopyForBlock creates an independent copy of a ForBlock.
func deepCopyForBlock(v *parser.ForBlock) *parser.ForBlock {
	if v == nil {
		return nil
	}
	cp := &parser.ForBlock{
		Init:      deepCopyExpression(v.Init),
		Condition: deepCopyExpression(v.Condition),
		Increment: deepCopyExpression(v.Increment),
		Range:     deepCopyExpression(v.Range),
		Offset:    v.Offset,
	}
	// RangeNames are VarBlock pointers for range variables — copy the slice
	// and each VarBlock so type substitution is isolated.
	if v.RangeNames != nil {
		cp.RangeNames = make([]*parser.VarBlock, len(v.RangeNames))
		for i, rn := range v.RangeNames {
			cp.RangeNames[i] = deepCopyVarBlock(rn)
		}
	}
	return cp
}

// deepCopySwitchBlock creates an independent copy of a SwitchBlock.
func deepCopySwitchBlock(v *parser.SwitchBlock) *parser.SwitchBlock {
	if v == nil {
		return nil
	}
	cp := &parser.SwitchBlock{
		Target: deepCopyExpression(v.Target),
	}
	if v.Cases != nil {
		cp.Cases = make([]*parser.CaseBlock, len(v.Cases))
		for i, c := range v.Cases {
			cpCase := &parser.CaseBlock{
				IsDefault: c.IsDefault,
				Switch:    nil, // circular ref; not needed after copy
			}
			if c.Values != nil {
				cpCase.Values = make([]*parser.Expression, len(c.Values))
				for j, val := range c.Values {
					cpCase.Values[j] = deepCopyExpression(val)
				}
			}
			cp.Cases[i] = cpCase
		}
	}
	return cp
}

// deepCopyCallBlock creates an independent copy of a CallBlock.
func deepCopyCallBlock(v *parser.CallBlock) *parser.CallBlock {
	if v == nil {
		return nil
	}
	cp := &parser.CallBlock{
		Name:         deepCopyName(v.Name),
		Func:         v.Func, // shared — points to the function definition, not mutated
		Node:         v.Node, // shared — structural pointer
		ThisVar:      v.ThisVar,
		NewType:      v.NewType,
		IsRC:         v.IsRC,
		IsVariadic:   v.IsVariadic,
		VariadicType: v.VariadicType,
	}
	if v.Args != nil {
		cp.Args = make([]*parser.ArgBlock, len(v.Args))
		for i, arg := range v.Args {
			cp.Args[i] = deepCopyArgBlock(arg)
		}
	}
	if v.VariadicArgs != nil {
		cp.VariadicArgs = make([]*parser.ArgBlock, len(v.VariadicArgs))
		for i, arg := range v.VariadicArgs {
			cp.VariadicArgs[i] = deepCopyArgBlock(arg)
		}
	}
	return cp
}

// deepCopyArgBlock creates an independent copy of an ArgBlock.
func deepCopyArgBlock(v *parser.ArgBlock) *parser.ArgBlock {
	if v == nil {
		return nil
	}
	return &parser.ArgBlock{
		Name:       deepCopyName(v.Name),
		Type:       v.Type,
		Default:    deepCopyExpression(v.Default),
		Defind:     v.Defind,
		Value:      deepCopyExpression(v.Value),
		Offset:     v.Offset,
		IsVariadic: v.IsVariadic,
	}
}

// deepCopyExpression creates a deep copy of an Expression tree.
func deepCopyExpression(e *parser.Expression) *parser.Expression {
	if e == nil {
		return nil
	}
	cp := &parser.Expression{
		Num:       e.Num,
		Separator: e.Separator,
		StringVal: e.StringVal,
		Bool:      e.Bool,
		ConstBool: e.ConstBool,
		ConstNil:  e.ConstNil,
		Type:      e.Type, // interface; replaced not mutated
		// checked is unexported; default false is fine — clearExprChecked resets it
	}
	cp.Var = deepCopyVarBlock(e.Var)
	cp.Left = deepCopyExpression(e.Left)
	if cp.Left != nil {
		cp.Left.Father = cp
	}
	cp.Right = deepCopyExpression(e.Right)
	if cp.Right != nil {
		cp.Right.Father = cp
	}
	for i := 0; i < 3; i++ {
		cp.Index[i] = deepCopyExpression(e.Index[i])
	}
	if e.ListElems != nil {
		cp.ListElems = make([]*parser.Expression, len(e.ListElems))
		for i, elem := range e.ListElems {
			cp.ListElems[i] = deepCopyExpression(elem)
		}
	}
	cp.Call = deepCopyCallBlock(e.Call)
	return cp
}

// deepCopyName creates a copy of a Name (slice of NameParts).
func deepCopyName(n parser.Name) parser.Name {
	if n == nil {
		return nil
	}
	cp := make(parser.Name, len(n))
	for i, part := range n {
		cp[i] = part // NamePart contains only value types and pointers; shallow copy is sufficient
	}
	return cp
}

// deepCopyNames copies a slice of Names.
func deepCopyNames(names []parser.Name) []parser.Name {
	if names == nil {
		return nil
	}
	cp := make([]parser.Name, len(names))
	for i, n := range names {
		cp[i] = deepCopyName(n)
	}
	return cp
}

// addSpecializedFunc 将特化函数节点添加到 AST 根节点的 Children 列表末尾，
// 同时深拷贝原始函数节点的子节点（函数体）给特化函数节点，
// 以便在后续编译循环中被编译。
func (c *Compiler) addSpecializedFunc(fn *parser.FuncBlock, orig *parser.FuncBlock, origNode *parser.Node, substMap map[string]typeSys.Type) {
	// 找到 AST 根节点
	root := c.Ctx.Now
	if root == nil {
		return
	}
	for root.Father != nil {
		root = root.Father
	}
	// 创建新的节点包装特化函数
	node := &parser.Node{Value: fn}
	node.Father = root

	// [病灶⑰b 修复 2026-11-02] 克隆必须先于原树替身执行：
	// substituteBodyTypes(origNode, substMap) 会把原树 body 中的 TypeParam（含
	// sizeof[K]() 的 CallBlock.NewType）改写为 subst 首例的具体类型（{K:int} →
	// IntType(8)，改写不可逆）。旧序"先替身后深拷贝"，克隆体从被污染的原树出发；
	// 后续第二例（如 {K:string}）单态化时体内 sizeof[K] 已是 IntType(8)——TypeParam
	// 身份消失，替身表查不到 → 不再替换 → 键宽 kszU=8 而参数实宽 24 →
	// isStr=0，string 键内容路径全灭（S2/S3 实锤：get[string] kI=8）。
	// 克隆先行：克隆体从净树复制，克隆体自身的 substituteBodyTypes(node, substMap)
	// （下方）用本例 substMap 正确改写 NewType→string-24。
	if origNode != nil {
		for _, child := range origNode.Children {
			copied := deepCopyNode(child)
			copied.Father = node
			node.Children = append(node.Children, copied)
		}
	}

	// [S0-3 根因修复] 单态化克隆体内的共享引用指向原泛型树：
	//   · FIELD 基址（v.Define.Type=FindTypeField）取 Define.Path[0]——原树 define；
	//   · remap 未触达的读端 Define.Value 同样指向原树 define。
	// 原体被 Useful=false 抑制后永远轮不到 Prologue 的 SetupVarOffsets，
	// 其 define Offset 恒 0 → 生成 [RBP]/[rbp]（读 saved-rbp，SIGSEGV）。
	// 给原树补齐真实偏移（克隆已先行完成，污染不进克隆体）：
	//   ① 原树局部类型补 subst（只改身体类型，orig.Args 的 TypeParam 保全，
	//      inferTypeParams 跨 [T] 重复单态化仍可推断）；
	//   ② 原参数块 Offset 与特化体对齐（漏绑的 Arg 读也落真位）；
	//   ③ 局部 define 按 Prologue 同一公式刷偏移（argSave 取特化体实型 size；
	//      克隆体自身 Prologue 随后同式重算，值幂等一致）。
	//
	// [缺陷⑰修复 2026-10-31] base 公式必须与该 arch Prologue 的 SetupVarOffsets 同式，
	// 否则原树 Offset 表与克隆体 4B/8B body 分配错位（x86 曾整体错 8B：field base
	// 表槽恒读克隆体第 5 个 4B 槽 -24）：
	//   · x86_64 linux_sysv.go：base = -8*len(csRegs) - argSaveBytes（this 指针 8B
	//     + Σ=((Size+7)/8)*8，与 setArgsOffset 槽带消耗单源同式——病灶⑬修复后
	//     用 arch.ArgSaveBytes，参数保存区纳入局部变量区 callee-save 之下）；
	//   · x86 ops.go prologue：base = -4*len(csRegs)，无 argSave 预扣
	//     （参数在 ebp+8 起正侧区，不进 base）；
	// 分支按 arch.PushSize()（4/8）判别，与 Prologue 唯一同源。
	// [病灶⑰b v2 修复 2026-11-02] 原树替身降级为"只替 VarBlock 类型"：
	// substituteBodyTypes 会把表达式层的 TypeParam（含 sizeof[K]() 的
	// CallBlock.NewType）改写为 subst 首例具体类型，改写不可逆——原树是全部
	// mono 例共享的克隆源，第一例（{K:int}）替身后 NewType 已是 IntType(8)，
	// 第二例（{K:string}）克隆出的 body 中 TypeParam 身份已消亡，替身表
	// 查不到 → sizeof[K] 折常量 8 → 键宽 kszU=8 而参数实宽 24 → isStr=0，
	// string 键内容路径全灭（farm 实锤：get[string] kI=8）。SetupVarOffsets
	// 只消费 VarBlock.Type/MultiTypes、ForBlock Init.Var/RangeNames 的类型
	// （偏移算账账源），故改用 substituteVarTypesOnly 仅替换这些枝叶，
	// 表达式层全保 TypeParam，原树对所有例保持"净身"。
	// 替换仅"供应偏移算账"，跨例幂等：第一例刷 int 账、第二例刷 string 账，
	// 各例发射时刻恰好各自消费各自账（fallback 读端按同例发射同例账）。
	if origNode != nil && orig != nil {
		substituteVarTypesOnly(origNode, substMap)
		for i, arg := range orig.Args {
			if i < len(fn.Args) {
				arg.Offset = fn.Args[i].Offset
			}
		}
		argSave := arch.ArgSaveBytes(fn)
		var base int
		if c.Ctx.Arch.PushSize() == 4 {
			base = -4 * len(c.Ctx.Arch.CalleeSaveRegs())
		} else {
			base = -(8 * len(c.Ctx.Arch.CalleeSaveRegs())) - argSave
		}
		arch.SetupVarOffsets(origNode, c.Ctx.StackAlignment, base)
	}

	// [病灶⑰b 修复 2026-11-02] 克隆已上移至 substituteBodyTypes(origNode) 之前：
	// 克隆体从净树出发完成复制后，原树替身/偏移补账留在克隆下方执行，
	// 故此处不再重复克隆。

	// 在 Remap 之前，先将特化函数的参数偏移刷新为 callee-local 位置（-48/-56 等），
	// 这样 remapFuncBodyRefs 修改 VarBlock 时，读到的 Offset 就是正确的。
	c.Ctx.Arch.SetArgsOffset(fn)
	// Remap variable references in the body to use the specialized function's args
	remapFuncBodyRefs(node, fn)
	// 替换函数体中所有局部变量的 TypeParam 类型为具体类型
	// 确保 collectVarOffsets 能正确计算栈帧布局（TypeParam.Size()=-1 会导致偏移量错误）
	substituteBodyTypes(node, substMap)
	// 单态化克隆体的 LLR 结果重算：gc.Build 在单态化之前执行，BlockFreesMap /
	// RetFreesMap 的键都是泛型原树的节点；克隆体节点是新对象，直接查表会全部
	// miss（特化函数因此丢失块尾释放与 ret 临时释放）。克隆体类型已替换为具体
	// 类型，此处用泛型摘要作为分配/未知调用门槛，重新计算一份以克隆节点为键的
	// LLR 结果，供 funcHandle / compileReturnBlock 使用。
	if orig != nil {
		if fs := gc.Table[orig.Name.String()]; fs != nil {
			gc.LLRResults[fn.Name.String()] = gc.ComputeLLR(fn.Name.String(), fn, fs, node)
		}
	}
	// Clear check cache so expressions are re-checked with remapped types/offsets
	clearExprChecked(node)
	root.Children = append(root.Children, node)
	// 注意：不对特化函数体调用 node.Check()。
	// 虽然深拷贝避免了共享 AST 污染，但 node.Check() 对单态化函数体
	// 仍会报类型错误（如 "cannot use uint as type int"），因为类型替换后的
	// 表达式树在 Check 阶段的类型推导与替换后的类型不一致。
	// 特化函数体在原始 Check 阶段已用 TypeParam 类型验证通过，
	// substituteBodyTypes 只将 TypeParam 替换为具体类型供编译器 codegen 使用。
}

// remapFuncBodyRefs walks the AST body of a specialized function and updates
// VarBlock.Define references to point to the specialized function's ArgBlocks
// instead of the original function's ArgBlocks.
func remapFuncBodyRefs(node *parser.Node, fn *parser.FuncBlock) {
	// Build a name→ArgBlock map from the specialized function
	argMap := make(map[string]*parser.ArgBlock)
	for _, arg := range fn.Args {
		argMap[arg.Name.String()] = arg
	}
	// 单态化克隆体里的引用型局部变量（Define.Type=FindTypeVar）同样指向泛型原树的
	// Define 节点，而泛型原树永远不会被 SetupVarOffsets（只 Setup 发射用的克隆体），
	// 其 Offset 恒为 0 → 生成的加载全部读 QWORD[rbp+0]（调用者 saved rbp）。
	// 收集克隆体内的 define VarBlock，把本地引用也重绑到克隆体。
	localDefs, localDefCounts := collectDefineVarBlocks(node)
	remapNodeRefs(node, argMap, localDefs, localDefCounts)
}

// collectDefineVarBlocks 收集克隆函数体内的变量定义节点（IsDefine 且非多返回值解构）。
// 返回 名字→define 映射 与 名字→定义次数（次数>1 表示存在作用域屏蔽歧义，引用保守不动）。
func collectDefineVarBlocks(node *parser.Node) (map[string]*parser.VarBlock, map[string]int) {
	names := map[string]*parser.VarBlock{}
	counts := map[string]int{}
	collectDefineVarBlocksWalk(node, names, counts)
	return names, counts
}

func collectDefineVarBlocksWalk(node *parser.Node, names map[string]*parser.VarBlock, counts map[string]int) {
	if node == nil {
		return
	}
	if vb, ok := node.Value.(*parser.VarBlock); ok && vb.IsDefine && len(vb.MultiNames) == 0 && vb.Name != nil {
		name := vb.Name.String()
		counts[name]++
		if _, exists := names[name]; !exists {
			names[name] = vb
		}
	}
	// 病灶⑯：else 子树经 IfBlock.ElseBlock 结构体指针入选（不在 node.Children），
	// 同法收集其身体内的变量定义，否则 varCounts 少挂该分支 decl、
	// uniqueLocalDefine 判歧义失败，引用保守不重绑。
	if ib, ok := node.Value.(*parser.IfBlock); ok && ib != nil && ib.ElseBlock != nil {
		collectDefineVarBlocksWalk(ib.ElseBlock, names, counts)
	}
	for _, child := range node.Children {
		collectDefineVarBlocksWalk(child, names, counts)
	}
}

func remapNodeRefs(node *parser.Node, argMap map[string]*parser.ArgBlock, varMap map[string]*parser.VarBlock, varCounts map[string]int) {
	if node == nil {
		return
	}
	// First: recurse into all children (handles nested scopes, if/else bodies, for bodies, etc.)
	for _, child := range node.Children {
		remapNodeRefs(child, argMap, varMap, varCounts)
	}

	switch v := node.Value.(type) {
	case *parser.VarBlock:
		if v == nil {
			return
		}
		// Remap VarBlock.Define reference (when variable IS the arg itself)
		if v.Define.Node != nil && v.Define.Type == parser.FindTypeArg {
			if ab, ok := v.Define.Value.(*parser.ArgBlock); ok {
				if newArg, found := argMap[ab.Name.String()]; found {
					v.Define.Value = newArg
					v.Offset = newArg.Offset
				}
			}
		}
		// Remap local-variable references to the cloned body's own define VarBlock
		// 语义与参数重绑相同：克隆体的发射只 Setup 克隆体 define 的 Offset，
		// 原泛型树 define 的 Offset 恒为 0，必须把引用的 Define.Value 重绑过去。
		if v.Define.Node != nil && v.Define.Type == parser.FindTypeVar {
			if vb, ok := v.Define.Value.(*parser.VarBlock); ok && vb != nil && vb.Name != nil && vb != v {
				if newVB, found := uniqueLocalDefine(varMap, varCounts, vb.Name.String()); found {
					v.Define.Value = newVB
					v.Offset = newVB.Offset
					if len(vb.MultiNames) == 0 && len(v.MultiNames) == 0 && newVB.Type != nil {
						// 类型与泛型解耦后兜底对齐（Clone 阶段已 subst，此处防御性）
						if v.Type == nil {
							v.Type = newVB.Type
						}
					}
				}
			}
		}
		// Remap VarBlock.Value expression (e.g., var s = memory.malloc(24))
		if v.Value != nil {
			remapExpRefs(v.Value, argMap, varMap, varCounts)
		}

	case *parser.ReturnBlock:
		if v == nil {
			return
		}
		for _, exp := range v.Value {
			remapExpRefs(exp, argMap, varMap, varCounts)
		}

	case *parser.CallBlock:
		if v == nil {
			return
		}
		for _, arg := range v.Args {
			if arg.Value != nil {
				remapExpRefs(arg.Value, argMap, varMap, varCounts)
			}
		}

	case *parser.IfBlock:
		if v == nil {
			return
		}
		remapExpRefs(v.Condition, argMap, varMap, varCounts)
		// 病灶⑯：else 子树经 IfBlock.ElseBlock 结构体指针入选（不在
		// node.Children），同法递归重绑其体内语句（含嵌套 else-if 链）的
		// Define/Offset 到克隆 decl；否则克隆体发射时 Define 仍指原树 decl，
		// live 重绑读到其他 mono 刷过的布局（+16 错位）。
		if v.ElseBlock != nil {
			remapNodeRefs(v.ElseBlock, argMap, varMap, varCounts)
		}

	case *parser.ElseBlock:
		if v == nil {
			return
		}
		remapExpRefs(v.IfCondition, argMap, varMap, varCounts)

	case *parser.ForBlock:
		if v == nil {
			return
		}
		remapExpRefs(v.Init, argMap, varMap, varCounts)
		remapExpRefs(v.Condition, argMap, varMap, varCounts)
		remapExpRefs(v.Increment, argMap, varMap, varCounts)
		remapExpRefs(v.Range, argMap, varMap, varCounts)

	case *parser.SwitchBlock:
		if v == nil {
			return
		}
		remapExpRefs(v.Target, argMap, varMap, varCounts)
		for i := range v.Cases {
			for _, val := range v.Cases[i].Values {
				remapExpRefs(val, argMap, varMap, varCounts)
			}
		}

	case *parser.Expression:
		remapExpRefs(v, argMap, varMap, varCounts)
	}
}

// uniqueLocalDefine 仅在名字在整个克隆体内只有一处定义（无屏蔽歧义）时返回该 define。
// 返回 false 表示名字重复或不存在，引用保持原状（保守不猜）。
func uniqueLocalDefine(varMap map[string]*parser.VarBlock, varCounts map[string]int, name string) (*parser.VarBlock, bool) {
	if varCounts[name] != 1 {
		return nil, false
	}
	vb, ok := varMap[name]
	return vb, ok
}

func remapExpRefs(exp *parser.Expression, argMap map[string]*parser.ArgBlock, varMap map[string]*parser.VarBlock, varCounts map[string]int) {
	if exp == nil {
		return
	}
	// Remap variable references (the key remapping: arg → specialized arg)
	if exp.Var != nil {
		if exp.Var.Define.Node != nil && exp.Var.Define.Type == parser.FindTypeArg {
			if ab, ok := exp.Var.Define.Value.(*parser.ArgBlock); ok {
				if newArg, found := argMap[ab.Name.String()]; found {
					exp.Var.Define.Value = newArg
					exp.Var.Offset = newArg.Offset
				}
			}
		}
		// 本地变量引用同样重绑到克隆体（泛型原树 define 的 Offset 恒为 0）
		if exp.Var.Define.Node != nil && exp.Var.Define.Type == parser.FindTypeVar {
			if vb, ok := exp.Var.Define.Value.(*parser.VarBlock); ok && vb != nil && vb.Name != nil {
				newVB, found := uniqueLocalDefine(varMap, varCounts, vb.Name.String())
				if found {
					exp.Var.Define.Value = newVB
					exp.Var.Offset = newVB.Offset
				}
			}
		}
		// 病灶⑮（2026-11-02）：多段名赋值（hdr.slots = slots、self.x += dx）的发射
		// 载体不是 VarBlock 语句本身，而是紧跟其后的匿名 Expression 语句——其
		// exp.Var 携带"完整赋值 VB"（parser 解析多段名赋值时两处挂树共享同一
		// orig 对象；compileExprBlock: exp.Var.Value != nil → VarDecl(exp.Var)）。
		// deepCopyNode 不去重共享引用：语句槽位上的克隆 A 与匿名 exp 的 .Var克隆 B
		// 是两个独立对象——上面只重绑了 B 的 Define/Path（写端），B 的 RHS
		// （.Var.Value）引用仍指向原树 define，发射期读到的是被后续 mono
		// Setup(orig) 重刷过的槽（mp_map SIGSEGV 决定性第三病灶）。
		// 与 VarBlock 语句路径同法：把 .Var.Value 一并 remap。
		if exp.Var.Value != nil {
			remapExpRefs(exp.Var.Value, argMap, varMap, varCounts)
		}
		// 病灶⑭修复：字段访问基区重绑。FindTypeField 读端的基变量挂在 Define.Path[0]，
		// deepCopyFindResult 对 Path 只做浅拷——克隆体的 Path[0] 仍指向泛型原树 define。
		// 原树槽位表随后会被后续单态化的 Setup(orig) 按其自身布局重刷（671 多 mono
		// 布局不同：argSave 24 vs 40 → 局部基 −64 vs −80），读端便读到别的特化的槽
		// （mp_map SIGSEGV 实测：set[int] 读端拿到 −88/−168 = set[int] 克隆槽位）。
		// 与参数/本地引用重绑同法：把 Path[0] 重绑到克隆体自己的 define/arg。
		// 不缓存 Offset——发射期（ptrMem / GenVarAddr FindTypeField 分支）从
		// Path[0].Offset 现取，此时克隆体 Prologue 的 Setup 已完成。
		if exp.Var.Define.Node != nil && exp.Var.Define.Type == parser.FindTypeField && len(exp.Var.Define.Path) > 0 {
			switch base := exp.Var.Define.Path[0].(type) {
			case *parser.VarBlock:
				if base != nil && base.Name != nil {
					if newVB, found := uniqueLocalDefine(varMap, varCounts, base.Name.String()); found && newVB != base {
						exp.Var.Define.Path[0] = newVB
					}
				}
			case *parser.ArgBlock:
				if base != nil {
					if newArg, found := argMap[base.Name.String()]; found && newArg != base {
						exp.Var.Define.Path[0] = newArg
					}
				}
			}
		}
	}
	// Recurse into left/right operands (binary/unary expressions)
	remapExpRefs(exp.Left, argMap, varMap, varCounts)
	remapExpRefs(exp.Right, argMap, varMap, varCounts)
	// Recurse into index expressions (arr[i])
	for i := 0; i < 3; i++ {
		remapExpRefs(exp.Index[i], argMap, varMap, varCounts)
	}
	// Recurse into list literal elements
	for _, elem := range exp.ListElems {
		remapExpRefs(elem, argMap, varMap, varCounts)
	}
	// Recurse into function call args (including nested calls)
	if exp.Call != nil {
		for _, arg := range exp.Call.Args {
			if arg.Value != nil {
				remapExpRefs(arg.Value, argMap, varMap, varCounts)
			}
		}
	}
	// Clear check cache so types/offsets are re-evaluated during Check
	exp.SetChecked(false)
}

// clearExprChecked recursively clears the checked flag on all expressions
// in the AST body, forcing a fresh type check after remapping.
func clearExprChecked(node *parser.Node) {
	if node == nil {
		return
	}
	// Reset node-level check flag so Check() re-runs on shared children
	node.Checked = false
	for _, child := range node.Children {
		clearExprChecked(child)
	}
	switch v := node.Value.(type) {
	case *parser.VarBlock:
		if v != nil && v.Value != nil {
			clearExprCheckedExp(v.Value)
		}
	case *parser.ReturnBlock:
		if v != nil {
			for _, exp := range v.Value {
				clearExprCheckedExp(exp)
			}
		}
	case *parser.CallBlock:
		if v != nil {
			for _, arg := range v.Args {
				if arg.Value != nil {
					clearExprCheckedExp(arg.Value)
				}
			}
		}
	case *parser.IfBlock:
		if v != nil {
			clearExprCheckedExp(v.Condition)
			// 病灶⑯：else 子树经 IfBlock.ElseBlock 结构体指针入选（不在
			// node.Children），同法复位其 Checked 标记，否则克隆 else 分支
			// 的语句带原树 checked 状态跳过 Check()。
			if v.ElseBlock != nil {
				clearExprChecked(v.ElseBlock)
			}
		}
	case *parser.ElseBlock:
		if v != nil {
			clearExprCheckedExp(v.IfCondition)
		}
	case *parser.ForBlock:
		if v != nil {
			clearExprCheckedExp(v.Init)
			clearExprCheckedExp(v.Condition)
			clearExprCheckedExp(v.Increment)
			clearExprCheckedExp(v.Range)
		}
	case *parser.SwitchBlock:
		if v != nil {
			clearExprCheckedExp(v.Target)
			for i := range v.Cases {
				for _, val := range v.Cases[i].Values {
					clearExprCheckedExp(val)
				}
			}
		}
	}
}

func clearExprCheckedExp(exp *parser.Expression) {
	if exp == nil {
		return
	}
	exp.SetChecked(false)
	clearExprCheckedExp(exp.Left)
	clearExprCheckedExp(exp.Right)
	for i := 0; i < 3; i++ {
		clearExprCheckedExp(exp.Index[i])
	}
	for _, elem := range exp.ListElems {
		clearExprCheckedExp(elem)
	}
	if exp.Call != nil {
		for _, arg := range exp.Call.Args {
			if arg.Value != nil {
				clearExprCheckedExp(arg.Value)
			}
		}
	}
}

// resetGenericRegistry 重置泛型注册表（用于新编译轮次）。
func resetGenericRegistry() {
	generics = newGenericRegistry()
}

// DebugPrintGenerics 调试输出：打印所有已单态化的泛型函数信息。
func DebugPrintGenerics() {
	for key, inst := range generics.specializations {
		fmt.Printf("[generic] %s -> %s\n", key, inst.FuncLabel)
	}
}

// substituteVarTypesOnly [病灶⑰b v2 修复 2026-11-02] 原树局部类型替身（限定枝叶）：
// 只替换 SetupVarOffsets/collectVarOffsets 算账消费的类型位——VarBlock.Type、
// VarBlock.MultiTypes、ForBlock 的 Init.Var.Type 与 RangeNames[].Type；
// 表达式层（Expression.Type/Var.Type/CallBlock.NewType 等）全保 TypeParam。
// 原树是全部 mono 例共享的克隆源，完整 substituteBodyTypes 的表达式层替身
// 会把 sizeof[K]() 的 NewType 改写为首例具体类型（不可逆），使后续例的克隆体
// 失去 TypeParam 身份、替身表无从下手（S2/S3 get[string] kszU 折 8 实锤）。
func substituteVarTypesOnly(node *parser.Node, subst map[string]typeSys.Type) {
	if node == nil || len(subst) == 0 {
		return
	}
	if vb, ok := node.Value.(*parser.VarBlock); ok && vb.IsDefine {
		if vb.Type != nil {
			vb.Type = typeSys.SubstituteTypeParams(vb.Type, subst)
		}
		for i, mt := range vb.MultiTypes {
			if mt != nil {
				vb.MultiTypes[i] = typeSys.SubstituteTypeParams(mt, subst)
			}
		}
	}
	for _, child := range node.Children {
		if fb, ok := child.Value.(*parser.ForBlock); ok {
			if fb.Init != nil && fb.Init.Var != nil && fb.Init.Var.Type != nil {
				fb.Init.Var.Type = typeSys.SubstituteTypeParams(fb.Init.Var.Type, subst)
			}
			for _, rn := range fb.RangeNames {
				if rn != nil && rn.Type != nil {
					rn.Type = typeSys.SubstituteTypeParams(rn.Type, subst)
				}
			}
		}
		substituteVarTypesOnly(child, subst)
	}
}

// substituteBodyTypes 递归遍历函数体 AST，将所有 VarBlock 和 ForBlock 中的
// TypeParam 类型替换为具体类型。这确保 collectVarOffsets 能正确计算栈帧布局，
// 因为 TypeParam.Size() 返回 -1，会导致偏移量计算错误（变量重叠）。
func substituteBodyTypes(node *parser.Node, subst map[string]typeSys.Type) {
	if node == nil || len(subst) == 0 {
		return
	}
	switch v := node.Value.(type) {
	case *parser.VarBlock:
		if v != nil {
			if v.Type != nil {
				v.Type = typeSys.SubstituteTypeParams(v.Type, subst)
			}
			substituteExprTypes(v.Value, subst)
		}
	case *parser.ForBlock:
		if v != nil {
			substituteExprTypes(v.Init, subst)
			substituteExprTypes(v.Condition, subst)
			substituteExprTypes(v.Increment, subst)
			substituteExprTypes(v.Range, subst)
			for _, rn := range v.RangeNames {
				if rn != nil && rn.Type != nil {
					rn.Type = typeSys.SubstituteTypeParams(rn.Type, subst)
				}
			}
		}
	case *parser.IfBlock:
		if v != nil {
			substituteExprTypes(v.Condition, subst)
			// 病灶⑯：else 子树经 IfBlock.ElseBlock 结构体指针入选（不在
			// node.Children），同法替换其体内 TypeParam，否则 else 分支里
			// 的泛型局部变量 TypeParam.Size()==-1 会撞坏栈帧偏向计算。
			if v.ElseBlock != nil {
				substituteBodyTypes(v.ElseBlock, subst)
			}
		}
	case *parser.ReturnBlock:
		if v != nil {
			for _, exp := range v.Value {
				substituteExprTypes(exp, subst)
			}
		}
	case *parser.Expression:
		substituteExprTypes(v, subst)
	}
	for _, child := range node.Children {
		substituteBodyTypes(child, subst)
	}
}

// substituteExprTypes 递归遍历表达式树，替换所有 Expression.Var 中的 TypeParam 类型。
func substituteExprTypes(exp *parser.Expression, subst map[string]typeSys.Type) {
	if exp == nil || len(subst) == 0 {
		return
	}
	// 替换表达式自身的类型（如变量引用表达式的 Type、比较结果类型等）
	if exp.Type != nil {
		exp.Type = typeSys.SubstituteTypeParams(exp.Type, subst)
	}
	if exp.Var != nil && exp.Var.Type != nil {
		exp.Var.Type = typeSys.SubstituteTypeParams(exp.Var.Type, subst)
	}
	substituteExprTypes(exp.Left, subst)
	substituteExprTypes(exp.Right, subst)
	for i := 0; i < 3; i++ {
		substituteExprTypes(exp.Index[i], subst)
	}
	for _, elem := range exp.ListElems {
		substituteExprTypes(elem, subst)
	}
	if exp.Call != nil {
		if exp.Call.NewType != nil {
			exp.Call.NewType = typeSys.SubstituteTypeParams(exp.Call.NewType, subst)
		}
		for _, arg := range exp.Call.Args {
			if arg.Value != nil {
				substituteExprTypes(arg.Value, subst)
			}
		}
	}
}
