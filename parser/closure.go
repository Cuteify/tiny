// 闭包（匿名函数 / 嵌套命名函数）的提升与环境管理。
//
// 捕获语义（Go 风格引用捕获）：
//
// 宿主帧为被捕获的“帧内局部声明”（参数/局部变量，不包含子单元自己的局部）
// 合成一个 $env 堆对象（结构体，字段名 = 捕获变量名）。宿主 frame 内以及
// 所有闭包体里对这些变量的引用统一改写为 __env.<name> 二段路径。
//
// env 传递：闭包对象 {code@0, env@ptrSize}，调用点约定把 env（对象 + ptrSize）
// 经 RBX/EBX 传给闭包（见 arch isIndirect 路径）；被调函数隐藏首参 $env
// 从 RBX/EBX 装载（见 x86_64 Prologue / x86 prologue）。
//
// 匿名函数与嵌套具名函数走同一套机制——具名嵌套函数提升后：
// 宿主位置替换为 `var <name>: fn(...) R = closure_N` 绑定，
// 绑定指向提升后的闭包对象（env 经隐藏约定传递，不占可见形参）。
package parser

import (
	"fmt"
	"strconv"

	typeSys "cuteify/type"
)

func init() {}

var closureSeq int

type envUnit struct {
	Fb   *FuncBlock
	Node *Node
}

// hoistClosures 入口：宿主函数解析完毕、尚未合并 Check 之前统一提升。
func hoistClosures(p *Parser, fnNode *Node) {
	frameLocals := collectFrameLocals(fnNode)

	// 捕获集只从子单元体收集——宿主帧体内直接引用局部变量不需要 env。
	units := collectUnits(fnNode)
	refs := map[string]bool{}
	for _, u := range units {
		collectRefsDeep(u.Node, refs)
	}

	// 捕获集合（保持帧声明顺序，布局稳定）
	captures := []string{}
	captureSet := map[string]bool{}
	for name := range frameLocals {
		if refs[name] {
			captures = append(captures, name)
			captureSet[name] = true
		}
	}
	sortStrings(captures)

	// 合成 env 结构体 + 注入宿主声明
	var envSt *typeSys.StructType
	var envVar *VarBlock
	if len(captures) > 0 {
		closureSeq++
		envSt = &typeSys.StructType{}
		envSt.RType.TypeName = fmt.Sprintf("$env%d", closureSeq)
		for _, name := range captures {
			envSt.StructFields = append(envSt.StructFields, &typeSys.StructField{
				Name:   name,
				Type:   frameLocals[name],
				Access: typeSys.AccessPublic,
			})
		}
		envSt.Layout()

		envName := freshName(fnNode, "__env")
		ptr := typeSys.MakePointer(envSt)
		envVar = &VarBlock{IsDefine: true, Name: NewName(envName), Type: ptr}
		envVar.Value = &Expression{
			Call: &CallBlock{Name: NewName("new"), NewType: envSt},
			Type: ptr,
		}
		inj := &Node{Value: envVar}
		inj.Father = fnNode
		blockNode[envVar] = inj
		fnNode.Children = append([]*Node{inj}, fnNode.Children...)
	}

	// 改写：子单元体先，宿主体后
	cap := &captureRewriter{captures: captureSet, envSt: envSt, envName: "__env", envVar: envVar}
	if envVar != nil {
		cap.envName = envVar.Name.First()
	}
	for _, u := range units {
		cap.rewrite(u.Node, shadowOf(u.Node))
	}
	cap.rewrite(fnNode, nil)

	// 提升子单元到包根
	for _, u := range units {
		closureSeq++
		liftUnit(p, u, fmt.Sprintf("__closure_%d", closureSeq), envSt, envVar)
	}

	// 去 checked
	for _, u := range units {
		markTreeUnchecked(u.Node)
	}
	markTreeUnchecked(fnNode)
}

// === 收集 ===

// collectFrameLocals 收集宿主帧自己声明的（非子单元）局部变量与参数。
func collectFrameLocals(fnNode *Node) map[string]typeSys.Type {
	locals := map[string]typeSys.Type{}
	if fb, ok := fnNode.Value.(*FuncBlock); ok {
		for _, arg := range fb.Args {
			if arg != nil && arg.Name.Length() > 0 && arg.Type != nil {
				if _, seen := locals[arg.Name.First()]; !seen {
					locals[arg.Name.First()] = arg.Type
				}
			}
		}
	}
	var walk func(n *Node, isRoot bool)
	walk = func(n *Node, isRoot bool) {
		if n == nil {
			return
		}
		if fb, ok := n.Value.(*FuncBlock); ok && !isRoot {
			_ = fb
			return // 子单元帧，自己声明属于它自己
		}
		if v, ok := n.Value.(*VarBlock); ok && v.IsDefine && v.Name.Length() == 1 && v.Type != nil {
			if _, seen := locals[v.Name.First()]; !seen {
				locals[v.Name.First()] = v.Type
			}
		}
		for _, ch := range n.Children {
			walk(ch, false)
		}
		if ib, ok := n.Value.(*IfBlock); ok && ib.ElseBlock != nil {
			for _, ch := range ib.ElseBlock.Children {
				walk(ch, false)
			}
		}
	}
	walk(fnNode, true)
	return locals
}

// collectRefsDeep 收集整棵子树（含所有子单元体）里被引用的单段标识符名字。
func collectRefsDeep(node *Node, into map[string]bool) {
	if node == nil {
		return
	}
	switch v := node.Value.(type) {
	case *VarBlock:
		if !v.IsDefine && v.Name.Length() == 1 {
			into[v.Name.First()] = true
		}
		addRefsInExp(v.Value, into)
	case *Expression:
		if v.Var != nil && v.Var.Name.Length() == 1 {
			into[v.Var.Name.First()] = true
		}
		addRefsInExp(v, into)
	case *ReturnBlock:
		for _, e := range v.Value {
			addRefsInExp(e, into)
		}
	case *IfBlock:
		addRefsInExp(v.Condition, into)
	case *ElseBlock:
		addRefsInExp(v.IfCondition, into)
	case *ForBlock:
		addRefsInExp(v.Init, into)
		addRefsInExp(v.Increment, into)
		addRefsInExp(v.Condition, into)
		addRefsInExp(v.Range, into)
	case *SwitchBlock:
		addRefsInExp(v.Target, into)
		for _, cs := range v.Cases {
			for _, val := range cs.Values {
				addRefsInExp(val, into)
			}
		}
	case *CallBlock:
		if v.Name.Length() == 1 {
			into[v.Name.First()] = true
		}
		for _, a := range v.Args {
			addRefsInExp(a.Value, into)
		}
	case *FuncBlock:
		for _, arg := range v.Args {
			if arg != nil {
				if _, dup1 := into[arg.Name.First()]; false {
					_ = dup1
				}
			}
		}
	}
	for _, ch := range node.Children {
		collectRefsDeep(ch, into)
	}
	if ib, ok := node.Value.(*IfBlock); ok && ib.ElseBlock != nil {
		collectRefsDeep(ib.ElseBlock, into)
	}
}

func addRefsInExp(e *Expression, into map[string]bool) {
	if e == nil {
		return
	}
	if e.Var != nil && e.Var.Name.Length() == 1 {
		into[e.Var.Name.First()] = true
	}
	addRefsInExp(e.Left, into)
	addRefsInExp(e.Right, into)
	for i := 0; i < 3; i++ {
		addRefsInExp(e.Index[i], into)
	}
	for _, el := range e.ListElems {
		addRefsInExp(el, into)
	}
	if e.Call != nil {
		if e.Call.Name.Length() == 1 {
			into[e.Call.Name.First()] = true
		}
		for _, a := range e.Call.Args {
			addRefsInExp(a.Value, into)
		}
	}
	if e.Anon != nil {
		addRefsInNodeTree(e.Anon.Node, into)
	}
}

func addRefsInNodeTree(node *Node, into map[string]bool) {
	if node == nil {
		return
	}
	collectRefsDeep(node, into)
}

// collectUnits 收集所有待提升的子单元：匿名 fb 与嵌套具名 fb。
func collectUnits(fnNode *Node) []envUnit {
	out := []envUnit{}
	seen := map[*FuncBlock]bool{}
	add := func(fb *FuncBlock, node *Node) {
		if fb == nil || seen[fb] {
			return
		}
		seen[fb] = true
		out = append(out, envUnit{Fb: fb, Node: node})
	}
	var walkVal func(b Block)
	var walkExp func(e *Expression)
	var walkNode func(n *Node)
	var walkBody func(n *Node)
	walkVal = func(b Block) {
		switch v := b.(type) {
		case *VarBlock:
			walkExp(v.Value)
		case *Expression:
			walkExp(v)
		case *ReturnBlock:
			for _, e := range v.Value {
				walkExp(e)
			}
		case *IfBlock:
			walkExp(v.Condition)
		case *ElseBlock:
			walkExp(v.IfCondition)
		case *ForBlock:
			walkExp(v.Init)
			walkExp(v.Increment)
			walkExp(v.Condition)
			walkExp(v.Range)
		case *SwitchBlock:
			walkExp(v.Target)
			for _, cs := range v.Cases {
				for _, val := range cs.Values {
					walkExp(val)
				}
			}
		case *CallBlock:
			for _, a := range v.Args {
				walkExp(a.Value)
			}
		}
	}
	walkExp = func(e *Expression) {
		if e == nil {
			return
		}
		if e.Anon != nil {
			add(e.Anon, e.Anon.Node)
			if e.Anon.Node != nil {
				walkBody(e.Anon.Node)
			}
			return
		}
		walkExp(e.Left)
		walkExp(e.Right)
		for i := 0; i < 3; i++ {
			walkExp(e.Index[i])
		}
		for _, el := range e.ListElems {
			walkExp(el)
		}
		if e.Call != nil {
			for _, a := range e.Call.Args {
				walkExp(a.Value)
			}
		}
	}
	walkBody = func(n *Node) {
		if n == nil {
			return
		}
		switch v := n.Value.(type) {
		case *FuncBlock:
			if n != fnNode {
				add(v, n)
				for _, ch := range n.Children {
					walkBody(ch)
				}
				if ib, ok := n.Value.(*IfBlock); ok && ib.ElseBlock != nil {
					walkBody(ib.ElseBlock)
				}
				return
			}
		}
		walkVal(n.Value)
		for _, ch := range n.Children {
			walkBody(ch)
		}
		if ib, ok := n.Value.(*IfBlock); ok && ib.ElseBlock != nil {
			walkBody(ib.ElseBlock)
		}
	}
	walkNode = func(n *Node) {
		if n == nil {
			return
		}
		switch v := n.Value.(type) {
		case *FuncBlock:
			if n != fnNode {
				add(v, n)
				for _, ch := range n.Children {
					walkNode(ch)
				}
				if ib, ok := n.Value.(*IfBlock); ok && ib.ElseBlock != nil {
					walkNode(ib.ElseBlock)
				}
				return
			}
		}
		walkVal(n.Value)
		for _, ch := range n.Children {
			walkNode(ch)
		}
		if ib, ok := n.Value.(*IfBlock); ok && ib.ElseBlock != nil {
			walkNode(ib.ElseBlock)
		}
	}
	walkNode(fnNode)
	return out
}

// === 捕获改写器 ===

type captureRewriter struct {
	captures map[string]bool
	envName  string
	envSt    *typeSys.StructType
	envVar   *VarBlock
}

// envField 返回 envSt 中名为 name 的 StructField（不存在时返回 nil）。
func (ce *captureRewriter) envField(name string) *typeSys.StructField {
	if ce.envSt != nil {
		for _, f := range ce.envSt.StructFields {
			if f.Name == name {
				return f
			}
		}
	}
	return nil
}

func (ce *captureRewriter) fieldType(name string) typeSys.Type {
	if ce.envSt != nil {
		for _, f := range ce.envSt.StructFields {
			if f.Name == name {
				return f.Type
			}
		}
	}
	return typeSys.GetSystemType("int")
}

// shadowOf 返回该 FuncBlock 子树（不深入嵌套子单元）自身声明的名字集合。
func shadowOf(fbNode *Node) map[string]bool {
	out := map[string]bool{}
	if fb, ok := fbNode.Value.(*FuncBlock); ok {
		for _, a := range fb.Args {
			if a != nil && a.Name.Length() > 0 {
				out[a.Name.First()] = true
			}
		}
	}
	var walk func(n *Node, isRoot bool)
	walk = func(n *Node, isRoot bool) {
		if n == nil {
			return
		}
		if fb, ok := n.Value.(*FuncBlock); ok && !isRoot {
			_ = fb
			return
		}
		if v, ok := n.Value.(*VarBlock); ok && v.IsDefine && v.Name.Length() == 1 {
			out[v.Name.First()] = true
		}
		for _, ch := range n.Children {
			walk(ch, false)
		}
		if ib, ok := n.Value.(*IfBlock); ok && ib.ElseBlock != nil {
			for _, ch := range ib.ElseBlock.Children {
				walk(ch, false)
			}
		}
	}
	walk(fbNode, true)
	return out
}

// rewrite 改写整棵子树；shadow 为当前路径上被声明/遮蔽的名字。
func (ce *captureRewriter) rewrite(node *Node, shadow map[string]bool) {
	if node == nil {
		return
	}
	curShadow := shadow

	switch v := node.Value.(type) {
	case *VarBlock:
		if v.IsDefine && v.Name.Length() == 1 && ce.captures[v.Name.First()] && !shadowOfSet(curShadow, v.Name.First()) {
			ce.rewriteCapturedDecl(v)
			break
		}
		// statement LHS 的捕获引用（如 `n = 100`）也要改写；FuncBlock 子节点不深入
		ce.rewriteVar(v, curShadow)
		ce.rewriteExp(v.Value, curShadow)
	case *Expression:
		ce.rewriteExp(v, curShadow)
	case *ReturnBlock:
		for _, e := range v.Value {
			ce.rewriteExp(e, curShadow)
		}
	case *IfBlock:
		ce.rewriteExp(v.Condition, curShadow)
	case *ElseBlock:
		ce.rewriteExp(v.IfCondition, curShadow)
	case *ForBlock:
		ce.rewriteExp(v.Init, curShadow)
		ce.rewriteExp(v.Increment, curShadow)
		ce.rewriteExp(v.Condition, curShadow)
		ce.rewriteExp(v.Range, curShadow)
	case *SwitchBlock:
		ce.rewriteExp(v.Target, curShadow)
		for _, cs := range v.Cases {
			for _, val := range cs.Values {
				ce.rewriteExp(val, curShadow)
			}
		}
	case *CallBlock:
		ce.rewriteName(&v.Name, curShadow)
		for _, a := range v.Args {
			ce.rewriteExp(a.Value, curShadow)
		}
	}
	for _, ch := range node.Children {
		if _, isFB := ch.Value.(*FuncBlock); isFB {
			continue
		}
		ce.rewrite(ch, curShadow)
	}
	if ib, ok := node.Value.(*IfBlock); ok && ib.ElseBlock != nil {
		ce.rewrite(ib.ElseBlock, curShadow)
	}
}

func mergeShadow(a, b map[string]bool) map[string]bool {
	out := map[string]bool{}
	for k := range a {
		out[k] = true
	}
	for k := range b {
		out[k] = true
	}
	return out
}

func shadowOfSet(shadow map[string]bool, name string) bool {
	if shadow == nil {
		return false
	}
	return shadow[name]
}

// rewriteName 改写捕获名为 __env 前缀路径。
func (ce *captureRewriter) rewriteName(n *Name, shadow map[string]bool) {
	if len(*n) == 0 {
		return
	}
	head := (*n)[0].Name
	if !ce.captures[head] || shadowOfSet(shadow, head) {
		return
	}
	*n = append(Name{{Name: ce.envName}}, *n...)
}

// rewriteVar 就地改写捕获变量引用为 __env.<name>(...)。
func (ce *captureRewriter) rewriteVar(v *VarBlock, shadow map[string]bool) {
	if v == nil || len(v.Name) == 0 {
		return
	}
	head := v.Name.First()

	if !ce.captures[head] || shadowOfSet(shadow, head) {
		return
	}
	field := ce.envField(head)
	v.Name = append(Name{{Name: ce.envName}}, v.Name...)
	v.Offset = 0
	v.IsDefine = false
	v.Used = true
	v.MultiIndex = -1
	v.MultiOffsets = nil
	v.MultiTypes = nil
	if field != nil {
		// 直接填入 FindTypeField 结果——“__env.<field>” 的语义 = 字段访问，
		// 不再依赖合并后的 rootNode.Check 重新解析（合并树无 FB 作用域）。
		// Path[0] 必须是 env 实例 VarBlock：ptrMem/needPtrMem 依赖它判
		// “指针基字段” 并发出间接寻址（_env 槽里装的是指针）。
		v.Define = FindResult{
			Node:  BlockNode(ce.envVar),
			Value: field,
			Path:  []any{ce.envVar, field},
			Type:  FindTypeField,
		}
		v.Type = field.Type
	} else {
		v.Define = FindResult{}
		v.Type = nil
	}
}

// rewriteCapturedDecl 把捕获变量的声明改写为 env 字段赋值；无初值则丢弃。
func (ce *captureRewriter) rewriteCapturedDecl(v *VarBlock) {
	name := v.Name.First()
	field := ce.envField(name)
	v.Name = Name{{Name: ce.envName}, {Name: name}}
	v.IsDefine = false
	v.Type = field.Type
	v.Offset = 0
	if field != nil {
		v.Define = FindResult{
			Node:  BlockNode(ce.envVar),
			Value: field,
			Path:  []any{ce.envVar, field},
			Type:  FindTypeField,
		}
		return
	}
	v.Define = FindResult{}
}

// rewriteExp 改写表达式里所有捕获引用。
func (ce *captureRewriter) rewriteExp(e *Expression, shadow map[string]bool) {
	if e == nil {
		return
	}
	if e.Var != nil {
		ce.rewriteVar(e.Var, shadow)
	}
	ce.rewriteExp(e.Left, shadow)
	ce.rewriteExp(e.Right, shadow)
	for i := 0; i < 3; i++ {
		ce.rewriteExp(e.Index[i], shadow)
	}
	for _, el := range e.ListElems {
		ce.rewriteExp(el, shadow)
	}
	if e.Call != nil {
		ce.rewriteName(&e.Call.Name, shadow)
		ce.rewriteVar(e.Call.ThisVar, shadow)
		for _, a := range e.Call.Args {
			ce.rewriteExp(a.Value, shadow)
		}
	}
}

// releaseLiftedBinding 丢弃指向 Lifted（宿主帧子单元提升后的 FB）或匿名闭包 FB
// 的 CallBlock 绑定：合并后的 rootNode.Check 会重新解析为 fn 变量间接调用
// （binding VarBlock 已经存在），避免直接以废弃 FB 标签生成 call 而不传递 env。
// liftBindings FB → 具名提升后宿主 frame 位置上替换成的 binding VarBlock。
// 用于合并 Check 重查时重新绑定调用点（c.Func 直接指向提升后的 FB，
// 从 root 作用域重查找不到宿主帧内部 binding，必须按指针重新绑定）。
var liftBindings = map[*FuncBlock]*VarBlock{}

func releaseLiftedBinding(c *CallBlock) {
	if c == nil {
		return
	}
	fb := c.Func
	if fb == nil || (!fb.Lifted && !fb.Anon) {
		return
	}
	if vb, ok := liftBindings[fb]; ok && vb != nil {
		synth := &FuncBlock{Name: c.Name}
		if ft, ok2 := vb.Type.(*typeSys.FuncType); ok2 {
			synth.Return = append([]typeSys.Type{}, ft.Returns...)
			for i, a := range ft.Args {
				synth.Args = append(synth.Args, &ArgBlock{Type: a, Name: NewName("arg" + strconv.Itoa(i))})
			}
		}
		c.ThisVar = vb
		c.Func = synth
		return
	}
	// 找不到绑定（理论上只发生于匿名闭包的 FB，用户代码不会直接调用它）：
	// 保持 c.Func=nil，让后续重查报正式错误，而不是静默发“直接调用废标签”。
	c.Func = nil
}

// === 提升 ===

// liftUnit 提升一个子单元到包根；注入隐藏 env 首参。
// 匿名 fb：节点摘出挂到包根。
// 嵌套具名函数：节点摘出挂到包根，同时在原位置替换为
//   var <name>: fn(...) R = closure_N
// 绑定节点——宿主内对 <name>(...) 的调用走 fn 变量间接调用，
// 不会绕过隐藏 env 首参。
func liftUnit(p *Parser, u envUnit, cloneName string, envSt *typeSys.StructType, envVar *VarBlock) {
	fb := u.Fb
	if fb == nil {
		return
	}
	origName := fb.Name.First()
	wasNamed := !fb.Anon && origName != ""

	fb.Name = NewName(cloneName)
	fb.Useful = true
	fb.Lifted = true
	// 具名嵌套函数提升后 behave 方式与匿名闭包一致：调用点走 fn 变量间接调用，
	// 编译器合成的 binding 指向升格后的匿名 fb。
	fb.Anon = true
	if envSt != nil {
		// EnvParam: 隐藏首参 __env（从 RBX 装入 callee 的 [rbp-48]）；
		// fn.Args 仍只保留可见参数——调用方不需要显式传递 env。
		fb.EnvParam = true
		fb.Env = envVar
	}

	node := u.Node
	parent := node.Father
	var replaced *Node
	if wasNamed {
		fnType := strippedFnType(fb, false)
		binding := &VarBlock{
			IsDefine: true,
			Name:     NewName(origName),
			Type:     fnType,
			Value: &Expression{
				Anon: fb,
				Type: fnType,
			},
		}
		binding.Value.Var = &VarBlock{Name: NewName(cloneName)}
		binding.Value.Var.ParseDefine(p)
		// binding 是“普通的 fn 变量绑定”，不能让 varIsFuncRef 把它当成裸函数引用
		binding.Define.Type = FindTypeVar
		binding.Define.Value = binding
		replaced = &Node{Value: binding}
	}
	if parent != nil {
		for i, ch := range parent.Children {
			if ch == node {
				if replaced != nil {
					replaced.Father = parent
					if relVar, ok := replaced.Value.(*VarBlock); ok {
						liftBindings[fb] = relVar
					}
					parent.Children[i] = replaced
				} else {
					parent.Children = append(parent.Children[:i], parent.Children[i+1:]...)
				}
				break
			}
		}
	}
	// Father 指向宿主块（与文件级顶层函数一致）；
	// merge 阶段会统一重设为包根节点——避免 compileRootTail 误把提升单元算成根。
	node.Father = p.Block
	p.Block.Children = append(p.Block.Children, node)
	blockNode[fb] = node
}

// strippedFnType 构造“去掉隐藏 env 首参”的 fn 类型（对外可见的绑定类型）。
func strippedFnType(fb *FuncBlock, hiddenFirst bool) *typeSys.FuncType {
	ret := append([]typeSys.Type{}, fb.Return...)
	args := make([]typeSys.Type, 0, len(fb.Args))
	for i, a := range fb.Args {
		if hiddenFirst && i == 0 {
			continue
		}
		if a != nil {
			args = append(args, a.Type)
		}
	}
	return &typeSys.FuncType{
		RType:   typeSys.RType{TypeName: "fn"},
		Args:    args,
		Returns: ret,
	}
}

// === checked 清除 ===

func markTreeUnchecked(node *Node) {
	if node == nil {
		return
	}
	markBlockUnchecked(node.Value)
	for _, ch := range node.Children {
		markTreeUnchecked(ch)
	}
	if ib, ok := node.Value.(*IfBlock); ok && ib.ElseBlock != nil {
		markTreeUnchecked(ib.ElseBlock)
	}
}

func markBlockUnchecked(b Block) {
	switch v := b.(type) {
	case *VarBlock:
		markExpUnchecked(v.Value)
	case *Expression:
		markExpUnchecked(v)
	case *ReturnBlock:
		for _, e := range v.Value {
			markExpUnchecked(e)
		}
	case *IfBlock:
		markExpUnchecked(v.Condition)
	case *ElseBlock:
		markExpUnchecked(v.IfCondition)
	case *ForBlock:
		markExpUnchecked(v.Init)
		markExpUnchecked(v.Increment)
		markExpUnchecked(v.Condition)
		markExpUnchecked(v.Range)
	case *SwitchBlock:
		markExpUnchecked(v.Target)
		for _, cs := range v.Cases {
			for _, val := range cs.Values {
				markExpUnchecked(val)
			}
		}
	case *CallBlock:
		releaseLiftedBinding(v)
		for _, a := range v.Args {
			markExpUnchecked(a.Value)
		}
	}
}

func markExpUnchecked(e *Expression) {
	if e == nil {
		return
	}
	e.SetChecked(false)
	markExpUnchecked(e.Left)
	markExpUnchecked(e.Right)
	for i := 0; i < 3; i++ {
		markExpUnchecked(e.Index[i])
	}
	for _, el := range e.ListElems {
		markExpUnchecked(el)
	}
	if e.Call != nil {
		releaseLiftedBinding(e.Call)
		for _, a := range e.Call.Args {
			markExpUnchecked(a.Value)
		}
	}
	if e.Anon != nil {
		markTreeUnchecked(e.Anon.Node)
	}
}

// === 小工具 ===

func sortStrings(a []string) {
	for i := 1; i < len(a); i++ {
		for j := i; j > 0 && a[j] < a[j-1]; j-- {
			a[j], a[j-1] = a[j-1], a[j]
		}
	}
}

func freshName(fnNode *Node, base string) string {
	used := map[string]bool{}
	noteNames(fnNode, used)
	if !used[base] {
		return base
	}
	for i := 1; ; i++ {
		name := fmt.Sprintf("%s%d", base, i)
		if !used[name] {
			return name
		}
	}
}

func noteNames(node *Node, used map[string]bool) {
	if node == nil {
		return
	}
	switch v := node.Value.(type) {
	case *VarBlock:
		for _, p := range v.Name {
			used[p.Name] = true
		}
	case *FuncBlock:
		for _, p := range v.Name {
			used[p.Name] = true
		}
		for _, a := range v.Args {
			for _, p := range a.Name {
				used[p.Name] = true
			}
		}
	}
	for _, ch := range node.Children {
		noteNames(ch, used)
	}
	if ib, ok := node.Value.(*IfBlock); ok && ib.ElseBlock != nil {
		noteNames(ib.ElseBlock, used)
	}
}




