package compile

import (
	"cuteify/parser"
	typeSys "cuteify/type"
	"fmt"
	"strings"
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
	c.addSpecializedFunc(specialized, origNode, substMap)

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
		newArg := &parser.ArgBlock{
			Name:    arg.Name,
			Type:    typeSys.SubstituteTypeParams(arg.Type, typeSubst),
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
		// Node and ElseBlock are structural pointers into the AST tree;
		// they are rebuilt by the parser, not by substituteBodyTypes, so we
		// share them. If needed, they can be deep-copied later.
		Node:      v.Node,
		ElseBlock: v.ElseBlock,
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
func (c *Compiler) addSpecializedFunc(fn *parser.FuncBlock, origNode *parser.Node, substMap map[string]typeSys.Type) {
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
	// 深拷贝原始函数的子节点（函数体语句），使特化函数拥有独立的 AST 副本，
	// 避免 substituteBodyTypes 修改共享节点导致原始泛型函数的 AST 被污染。
	if origNode != nil {
		for _, child := range origNode.Children {
			copied := deepCopyNode(child)
			copied.Father = node
			node.Children = append(node.Children, copied)
		}
	}
	// 在 Remap 之前，先将特化函数的参数偏移刷新为 callee-local 位置（-48/-56 等），
	// 这样 remapFuncBodyRefs 修改 VarBlock 时，读到的 Offset 就是正确的。
	c.Ctx.Arch.SetArgsOffset(fn)
	// Remap variable references in the body to use the specialized function's args
	remapFuncBodyRefs(node, fn)
	// 替换函数体中所有局部变量的 TypeParam 类型为具体类型
	// 确保 collectVarOffsets 能正确计算栈帧布局（TypeParam.Size()=-1 会导致偏移量错误）
	substituteBodyTypes(node, substMap)
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
	remapNodeRefs(node, argMap)
}

func remapNodeRefs(node *parser.Node, argMap map[string]*parser.ArgBlock) {
	if node == nil {
		return
	}
	// First: recurse into all children (handles nested scopes, if/else bodies, for bodies, etc.)
	for _, child := range node.Children {
		remapNodeRefs(child, argMap)
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
		// Remap VarBlock.Value expression (e.g., var s = memory.malloc(24))
		if v.Value != nil {
			remapExpRefs(v.Value, argMap)
		}

	case *parser.ReturnBlock:
		if v == nil {
			return
		}
		for _, exp := range v.Value {
			remapExpRefs(exp, argMap)
		}

	case *parser.CallBlock:
		if v == nil {
			return
		}
		for _, arg := range v.Args {
			if arg.Value != nil {
				remapExpRefs(arg.Value, argMap)
			}
		}

	case *parser.IfBlock:
		if v == nil {
			return
		}
		remapExpRefs(v.Condition, argMap)

	case *parser.ElseBlock:
		if v == nil {
			return
		}
		remapExpRefs(v.IfCondition, argMap)

	case *parser.ForBlock:
		if v == nil {
			return
		}
		remapExpRefs(v.Init, argMap)
		remapExpRefs(v.Condition, argMap)
		remapExpRefs(v.Increment, argMap)
		remapExpRefs(v.Range, argMap)

	case *parser.SwitchBlock:
		if v == nil {
			return
		}
		remapExpRefs(v.Target, argMap)
		for i := range v.Cases {
			for _, val := range v.Cases[i].Values {
				remapExpRefs(val, argMap)
			}
		}

	case *parser.Expression:
		remapExpRefs(v, argMap)
	}
}

func remapExpRefs(exp *parser.Expression, argMap map[string]*parser.ArgBlock) {
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
	}
	// Recurse into left/right operands (binary/unary expressions)
	remapExpRefs(exp.Left, argMap)
	remapExpRefs(exp.Right, argMap)
	// Recurse into index expressions (arr[i])
	for i := 0; i < 3; i++ {
		remapExpRefs(exp.Index[i], argMap)
	}
	// Recurse into list literal elements
	for _, elem := range exp.ListElems {
		remapExpRefs(elem, argMap)
	}
	// Recurse into function call args (including nested calls)
	if exp.Call != nil {
		for _, arg := range exp.Call.Args {
			if arg.Value != nil {
				remapExpRefs(arg.Value, argMap)
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
