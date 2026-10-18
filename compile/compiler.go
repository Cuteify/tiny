package compile

import (
	"cuteify/compile/context"
	"cuteify/compile/gc"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"fmt"
	"os"
	"reflect"
	"strconv"
	"strings"
)

var GoArch = "x86"

func init() {
	if v := os.Getenv("CUTE_ARCH"); v != "" {
		GoArch = v
		fmt.Println("Using target arch:", GoArch)
	}
}

// Compiler 编译器结构体，负责将AST转换为汇编代码
type Compiler struct {
	Ctx            *context.Context                   // 编译器上下文
	RootGenerated  bool                               // 标记是否已生成 section .text
	stringSyms     map[string]bool                    // build link 声明的全局符号（如 __string_len）
	currentFuncKey string                             // 当前编译函数的全路径名（用于 GC block frees 查询）
	typeSubsts     map[string]map[string]typeSys.Type // 单态化函数的类型替换表（label → substMap）
	funcNodeMap    map[*parser.FuncBlock]*parser.Node // FuncBlock → AST Node 映射（跨包查找用）
	compiling      bool                               // 标记是否在顶层编译中（防止递归调用重置泛型注册表）
}

// NewCompiler 创建新的编译器
func NewCompiler(parser *parser.Parser) *Compiler {
	return &Compiler{
		Ctx:        context.NewContext(),
		stringSyms: map[string]bool{},
	}
}

// Compile 编译入口方法，将AST节点编译为汇编代码
func (c *Compiler) Compile(node *parser.Node) (code string) {
	c.initializeContext()
	// Only reset the generic registry at the top-level entry, not in recursive calls.
	if !c.compiling {
		resetGenericRegistry()
		c.compiling = true
		defer func() { c.compiling = false }()
	}
	c.collectLinkSyms(node)
	c.Ctx.StringSyms = c.stringSyms
	c.Ctx.LinkProviders = parser.LinkProviders
	// Pre-pass: mark methods needed by interface assignments as useful
	c.markIfaceMethods(node)
	// Pre-pass: mark build link providers as useful so they get compiled.
	// This must happen at compile-time because Check() can't re-evaluate
	// nodes that were already Checked=true when LinkProviders was empty.
	c.markLinkProviders(node)
	// Pre-pass: mark memory.rcDec/rcInc as useful (called from GC emit)
	c.markRCFuncs(node)
	// Pre-pass: collect build export aliases for global declarations
	c.collectExports(node)
	code = c.compileRoot(node, code)
	code += c.compileChildren(node, "")
	code += c.compileRootTail(node)
	return code
}

// collectLinkSyms 收集 build link 声明的全局符号名（如 __string_len），
// 供内建 len/cap 检测后改为调用 strings 包实现（未提供时保持内联）。
func (c *Compiler) collectLinkSyms(node *parser.Node) {
	if node == nil {
		return
	}
	if fb, ok := node.Value.(*parser.FuncBlock); ok {
		for _, bf := range fb.BuildFlags {
			if bf.Type == "link" && bf.Link != "" {
				if c.stringSyms == nil {
					c.stringSyms = map[string]bool{}
				}
				c.stringSyms[bf.Link] = true
			}
		}
	}
	for _, ch := range node.Children {
		c.collectLinkSyms(ch)
	}
}

// collectExports 收集 build export 声明的导出别名（pre-pass，用于在函数前输出 global 声明）
func (c *Compiler) collectExports(node *parser.Node) {
	if node == nil {
		return
	}
	if fb, ok := node.Value.(*parser.FuncBlock); ok {
		for _, bf := range fb.BuildFlags {
			if bf.Type == "export" && bf.Export != "" {
				if c.Ctx.Exports == nil {
					c.Ctx.Exports = make(map[string]string)
				}
				c.Ctx.Exports[bf.Export] = fb.MangledName()
			}
		}
	}
	for _, ch := range node.Children {
		c.collectExports(ch)
	}
}

// findLinkFlag 返回函数的 build link 标志（若有）。
func (c *Compiler) findLinkFlag(funcBlock *parser.FuncBlock) *parser.Build {
	for _, bf := range funcBlock.BuildFlags {
		if bf.Type == "link" && !bf.Ignore {
			return bf
		}
	}
	return nil
}

// markIfaceMethods pre-pass: mark methods needed by interface assignments as useful
// so they get compiled even though they're not directly called.
func (c *Compiler) markIfaceMethods(node *parser.Node) {
	if node == nil {
		return
	}
	if vb, ok := node.Value.(*parser.VarBlock); ok {
		if vb.Value != nil && vb.Type != nil && vb.Value.Type != nil {
			if _, isIface := vb.Type.(*typeSys.InterfaceType); isIface {
				// Mark all methods on the concrete type as useful
				for _, m := range vb.Value.Type.Methods() {
					if fb, ok := m.(*parser.FuncBlock); ok {
						fb.Useful = true
					}
				}
			}
		}
	}
	for _, ch := range node.Children {
		c.markIfaceMethods(ch)
	}
}

// markLinkProviders pre-pass: mark build link providers as useful so they get compiled.
// This is necessary because Check() may evaluate len()/cap() calls (which trigger
// checkBuiltin → mark Useful) BEFORE LinkProviders is populated (dependency packages
// not yet loaded). Since Node.Check() caches Checked=true and skips re-evaluation,
// the providers are never marked useful at Check-time.
func (c *Compiler) markLinkProviders(node *parser.Node) {
	if node == nil {
		return
	}
	if fb, ok := node.Value.(*parser.FuncBlock); ok {
		for _, bf := range fb.BuildFlags {
			if bf.Type == "link" && bf.Link != "" && !bf.Ignore {
				// Only mark if actually needed by len/cap/strings calls
				if c.stringSyms != nil && c.stringSyms[bf.Link] {
					fb.Useful = true
				}
			}
		}
	}
	for _, ch := range node.Children {
		c.markLinkProviders(ch)
	}
}

// markRCFuncs pre-pass: mark memory.rcDec/rcInc/rcGet as useful.
// These are called from GC emit codegen but never appear in user source,
// so they aren't marked Useful during Check.
func (c *Compiler) markRCFuncs(node *parser.Node) {
	rcNames := map[string]bool{"rcDec": true, "rcInc": true, "rcGet": true, "mallocRC": true, "freeRC": true, "rcIsOne": true, "rcAdd": true, "rcSub": true, "rcTryRelease": true, "rcSet": true, "trackAlloc": true, "trackFree": true, "reportLeaks": true, "reportAllocCount": true, "reportFreeCount": true, "resetLeakTracker": true}
	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if n == nil {
			return
		}
		if fb, ok := n.Value.(*parser.FuncBlock); ok && fb.Name != nil {
			if rcNames[fb.Name.Last()] && len(fb.Name) >= 2 && fb.Name[0].IsPkgPath {
				fb.Useful = true
			}
		}
		for _, ch := range n.Children {
			walk(ch)
		}
	}
	walk(node)
}

func (c *Compiler) initializeContext() {
	if c.Ctx == nil {
		c.Ctx = context.NewContext()
	}
	if c.Ctx.Arch == nil {
		c.Ctx.Arch = NewArch(GoArch, c.Ctx)
	}
	// Set monomorphize callback so expression compiler can trigger specialization
	c.Ctx.MonomorphizeCall = func(call *parser.CallBlock) string {
		if IsGenericFunction(call.Func) {
			return c.MonomorphizeIfNeeded(call)
		}
		return ""
	}
	if c.funcNodeMap == nil {
		c.funcNodeMap = make(map[*parser.FuncBlock]*parser.Node)
	}
}

func (c *Compiler) compileRoot(node *parser.Node, code string) string {
	// 只在最外层生成一次 section .text
	if c.RootGenerated {
		return ""
	}
	// 只在根节点（没有Father）生成
	if node.Father != nil {
		return ""
	}
	c.RootGenerated = true
	var globals string
	if c.Ctx.Exports != nil {
		for exportName := range c.Ctx.Exports {
			globals += "global " + exportName + "\n"
		}
		globals += "\n"
	}
	return globals + c.generateGlobalSection(node) + "section .text\nglobal _start\n\n"
}

// generateGlobalSection 输出全局变量的 .bss/.data 声明
func (c *Compiler) generateGlobalSection(node *parser.Node) string {
	var bssCode, dataCode string
	for _, ch := range node.Children {
		vb, ok := ch.Value.(*parser.VarBlock)
		if !ok || !vb.IsGlobal || !vb.IsDefine {
			continue
		}
		name := "__global_" + utils.ToNASMName(vb.Name.String())
		size := vb.Type.Size()
		// 字符串（ptr+len+cap=24 字节）延后到 generateDataSection 生成（需字符串字面量）
		if typeSys.CheckKind(vb.Type, "string") {
			c.Ctx.GlobalStrings = append(c.Ctx.GlobalStrings, vb)
			continue
		}
		// 聚合类型（list/struct）：按 Size 预留 .bss 槽（未初始化），
		// 运行期由赋值语句填充三槽/字段
		if size != 4 && size != 8 {
			bssCode += "    " + name + " resb " + strconv.Itoa(size) + "\n"
			continue
		}
		// 常量初始化值放入 .data，其余放 .bss
		if vb.IsConst && vb.Value != nil {
			val := int64(vb.Value.Num)
			if size == 8 {
				dataCode += "    " + name + " dq " + strconv.FormatInt(val, 10) + "\n"
			} else {
				dataCode += "    " + name + " dd " + strconv.FormatInt(val, 10) + "\n"
			}
		} else {
			if size == 8 {
				bssCode += "    " + name + " resq 1\n"
			} else {
				bssCode += "    " + name + " resd 1\n"
			}
		}
	}
	code := ""
	if bssCode != "" {
		code += "section .bss\n" + bssCode
	}
	if dataCode != "" {
		code += "section .data\n" + dataCode
	}
	return code
}

func (c *Compiler) compileChildren(node *parser.Node, code string) string {
	for i := 0; i < len(node.Children); i++ {
		n := node.Children[i]
		if n.Ignore {
			continue
		}
		c.Ctx.Now = n
		if i > 0 && i%100 == 0 {
			fmt.Fprintf(os.Stderr, "[compileChildren] i=%d/%d\n", i, len(node.Children))
		}
		code += c.compileChild(n)
	}
	return code
}

func (c *Compiler) compileChild(n *parser.Node) string {
	switch v := n.Value.(type) {
	case *parser.FuncBlock:
		for _, buildFlag := range v.BuildFlags {
			if buildFlag.Ignore {
				return ""
			}
		}
		if !v.Useful && v.Name.String() != "main" {
			return ""
		}
		return c.compileFuncBlock(n)
	case *parser.IfBlock:
		return c.compileIfBlock(n)
	case *parser.ReturnBlock:
		return c.compileReturnBlock(n)
	case *parser.VarBlock:
		return c.compileVarBlock(n)
	case *parser.CallBlock:
		return c.compileCallBlock(n)
	case *parser.Expression:
		return c.compileExprBlock(n)
	case *parser.ForBlock:
		if n.Value.(*parser.ForBlock).Range != nil {
			return c.compileForRangeBlock(n)
		}
		return c.compileForBlock(n)
	case *parser.BreakBlock:
		return c.compileBreakBlock(n)
	case *parser.SwitchBlock:
		return c.compileSwitchBlock(n)
	case *parser.CaseBlock:
		// CaseBlock 本身不生成代码，body 语句由 compileSwitchBlock 编译
		return ""
	case *parser.DeferBlock:
		return c.compileDeferBlock(n)
	case *parser.TypeBlock:
		return c.compileTypeBlock(n)
	case *parser.Build:
		return c.CompileBuild(n)
	default:
		return ""
	}
}

func (c *Compiler) compileFuncBlock(n *parser.Node) string {
	funcBlock := n.Value.(*parser.FuncBlock)
	if !funcBlock.Useful && funcBlock.Name.String() != "main" {
		return ""
	}
	// Record FuncBlock → Node mapping for cross-package monomorphization lookup
	if c.funcNodeMap != nil {
		c.funcNodeMap[funcBlock] = n
	}
	// 变量栈设置和栈大小计算现在由 arch.Pro/Epilogue 处理
	return c.funcHandle(funcBlock, n)
}

func (c *Compiler) compileIfBlock(n *parser.Node) string {
	ifBlock := n.Value.(*parser.IfBlock)
	c.Ctx.IfCount++
	label := fmt.Sprintf("if_%d", c.Ctx.IfCount)

	var code string
	var endLabel string
	if ifBlock.Else {
		endLabel = "else_" + label
	} else {
		endLabel = "end_" + label
	}

	// 编译条件表达式，生成比较和跳转指令
	code += c.compileCondition(ifBlock.Condition, endLabel)

	code += utils.Format(label+":") + c.Compile(n)
	// if 体块级释放
	code += c.emitBlockFrees(n)

	if ifBlock.Else {
		code += utils.Format("jmp end_" + label)
		code += c.compileElseBlock(ifBlock, label)
	}
	code += utils.Format("end_" + label + ":")
	return code
}

// compileCondition 编译条件表达式，生成比较和跳转指令
func (c *Compiler) compileCondition(cond *parser.Expression, jumpLabel string) string {
	if cond == nil {
		return ""
	}

	var code string

	// 根据架构选择寄存器名
	scratchReg1 := "EAX"
	scratchReg2 := "ECX"
	if c.Ctx.Is64Bit {
		scratchReg1 = "RAX"
		scratchReg2 = "RCX"
	}

	// 处理比较运算
	switch cond.Separator {
	case "==", "!=", "<", ">", "<=", ">=":

		// 32 位模式下 64 位类型比较需要专用双寄存器路径
		if !c.Ctx.Is64Bit && cond.Left != nil && c.Ctx.Arch.Is64Type(cond.Left.Type) {
			return c.Ctx.Arch.Compare64(cond, jumpLabel)
		}

		// 编译左右操作数到寄存器
		leftSavedReg := ""
		if cond.Left != nil {
			code += c.Ctx.Arch.Exp(cond.Left, scratchReg1, "left operand")
			// 用空闲 callee-save 寄存器保存左操作数（跨右子函数调用保持）。
			// 不能压栈：被调函数参数槽 [rbp+16]（=调用指令时的 rsp）落在调用者
			// 栈顶，会覆盖压栈保存的左操作数（如 load8(a) != load8(b) 这类左右都
			// 是函数调用时，右调用会覆盖左操作数的栈保存）。
			leftSavedReg = c.Ctx.Reg.AllocCalleeSaveBind(cond.Left, c.Ctx.Arch.CalleeSaveRegs(), c.Ctx.Arch.CalleeSaveReg())
			if leftSavedReg != "" {
				code += utils.Format("mov " + leftSavedReg + ", " + scratchReg1 + "; 保存左操作数到callee-save")
			} else {
				code += utils.Format("push " + scratchReg1 + "; 保护左操作数\n")
			}
		}
		if cond.Right != nil {
			code += c.Ctx.Arch.Exp(cond.Right, scratchReg2, "right operand")
		}
		if cond.Left != nil {
			if leftSavedReg != "" {
				code += utils.Format("mov " + scratchReg1 + ", " + leftSavedReg + "; 恢复左操作数")
				c.Ctx.Reg.Free(cond.Left)
			} else {
				code += utils.Format("pop " + scratchReg1 + "; 恢复左操作数\n")
			}
		}

		// 生成比较指令
		code += utils.Format("cmp " + scratchReg1 + ", " + scratchReg2)

		// 根据操作符生成跳转指令
		var jumpOp string
		// 判断是否为无符号类型比较
		isUnsigned := false
		if cond.Left != nil && cond.Left.Type != nil {
			isUnsigned = typeSys.CheckKind(cond.Left.Type, "uint")
		} else if cond.Right != nil && cond.Right.Type != nil {
			isUnsigned = typeSys.CheckKind(cond.Right.Type, "uint")
		}
		switch cond.Separator {
		case "==":
			jumpOp = "jne" // 相等则不跳转
		case "!=":
			jumpOp = "je" // 不等则不跳转
		case "<":
			if isUnsigned {
				jumpOp = "jnb" // 无符号：不低于则跳转
			} else {
				jumpOp = "jge" // 小于则不跳转
			}
		case ">":
			if isUnsigned {
				jumpOp = "jbe" // 无符号：不高于则跳转
			} else {
				jumpOp = "jle" // 大于则不跳转
			}
		case "<=":
			if isUnsigned {
				jumpOp = "jnbe" // 无符号：不高于等于则跳转
			} else {
				jumpOp = "jg" // 小于等于则不跳转
			}
		case ">=":
			if isUnsigned {
				jumpOp = "jb" // 无符号：低于则跳转（条件为假）
			} else {
				jumpOp = "jl" // 大于等于则不跳转
			}
		}
		code += utils.Format(jumpOp + " " + jumpLabel)
	case "&&", "||":
		// 处理逻辑与/或
		if cond.Left != nil {
			code += c.compileCondition(cond.Left, jumpLabel)
		}
		if cond.Right != nil {
			code += c.compileCondition(cond.Right, jumpLabel)
		}
	default:
		// 单个表达式，编译到 scratchReg1 并测试是否为 0
		code += c.Ctx.Arch.Exp(cond, scratchReg1, "condition")
		code += utils.Format("test " + scratchReg1 + ", " + scratchReg1)
		code += utils.Format("jz " + jumpLabel) // 为 0 则跳转
	}

	return code
}

func (c *Compiler) compileElseBlock(ifBlock *parser.IfBlock, label string) string {
	var code string
	code += utils.Format("else_" + label + ":")
	if ifBlock.ElseBlock != nil {
		if e, ok := ifBlock.ElseBlock.Value.(*parser.ElseBlock); ok && e.IfCondition != nil {
			code += c.Ctx.Arch.Exp(e.IfCondition, "end_"+label, "")
		}
		code += c.Compile(ifBlock.ElseBlock)
	}
	return code
}

func (c *Compiler) compileSwitchBlock(n *parser.Node) string {
	switchBlock := n.Value.(*parser.SwitchBlock)
	c.Ctx.SwitchCount++
	label := fmt.Sprintf("switch_%d", c.Ctx.SwitchCount)
	endLabel := "switch_end_" + label

	// 根据架构选择寄存器名
	scratchReg1 := "EAX"
	scratchReg2 := "ECX"
	if c.Ctx.Is64Bit {
		scratchReg1 = "RAX"
		scratchReg2 = "RCX"
	}

	var code string

	// 编译 switch 目标表达式到寄存器
	if switchBlock.Target != nil {
		code += c.Ctx.Arch.Exp(switchBlock.Target, scratchReg1, "switch target")
	}

	// 使用 SwitchBlock.Cases 信息 + 子节点中的 CaseClause 进行编译
	// CaseClause 节点在 n.Children 中，case body 语句是 CaseClause 的子节点
	defaultIdx := -1
	caseIdx := 0

	// 先为每个 case 生成比较跳转
	for i, sc := range switchBlock.Cases {
		if sc.IsDefault {
			defaultIdx = i
			continue
		}
		caseLabel := fmt.Sprintf("case_%s_%d", label, caseIdx)
		for _, val := range sc.Values {
			// 编译 case 值到寄存器
			code += c.Ctx.Arch.Exp(val, scratchReg2, "case value")
			// 保存左操作数（如果有 callee-save 可用）
			leftSavedReg := c.Ctx.Reg.AllocCalleeSaveBind(val, c.Ctx.Arch.CalleeSaveRegs(), c.Ctx.Arch.CalleeSaveReg())
			if leftSavedReg != "" {
				code += utils.Format("mov " + leftSavedReg + ", " + scratchReg1 + "; 保存switch目标到callee-save")
			}
			code += utils.Format("cmp " + scratchReg1 + ", " + scratchReg2)
			if leftSavedReg != "" {
				code += utils.Format("mov " + scratchReg1 + ", " + leftSavedReg + "; 恢复switch目标")
				c.Ctx.Reg.Free(val)
			}
			code += utils.Format("je " + caseLabel)
		}
		caseIdx++
	}

	// 没有匹配的 case，跳转到 default 或 end
	if defaultIdx >= 0 {
		code += utils.Format("jmp switch_default_" + label)
	} else {
		code += utils.Format("jmp " + endLabel)
	}

	// 编译每个 case 的 body（遍历 CaseClause 子节点，编译其子节点中的语句）
	caseIdx = 0
	for _, child := range n.Children {
		cc, ok := child.Value.(*parser.CaseBlock)
		if !ok {
			continue
		}
		if cc.IsDefault {
			continue
		}
		caseLabel := fmt.Sprintf("case_%s_%d", label, caseIdx)
		code += utils.Format(caseLabel + ":")
		// 编译 CaseClause 的子节点（case body 语句）
		for _, stmt := range child.Children {
			code += c.compileChild(stmt)
		}
		// 隐式 break：跳出 switch
		code += utils.Format("jmp " + endLabel)
		caseIdx++
	}

	// 编译 default body
	if defaultIdx >= 0 {
		code += utils.Format("switch_default_" + label + ":")
		// 找到 default 对应的 CaseClause 子节点
		for _, child := range n.Children {
			cc, ok := child.Value.(*parser.CaseBlock)
			if ok && cc.IsDefault {
				for _, stmt := range child.Children {
					code += c.compileChild(stmt)
				}
				break
			}
		}
	}

	// 结束标签
	code += utils.Format(endLabel + ":")
	return code
}

func (c *Compiler) compileReturnBlock(n *parser.Node) string {
	ret := n.Value.(*parser.ReturnBlock)
	var code string

	// 执行所有延迟的函数调用（LIFO 顺序）
	deferCode := c.compileDeferCalls(n.Father)
	if deferCode != "" {
		code += deferCode
	}

	// 生成返回代码
	code += c.Ctx.Arch.Return(ret)
	return code
}

func (c *Compiler) compileVarBlock(n *parser.Node) string {
	varBlock := n.Value.(*parser.VarBlock)
	if varBlock.IsGlobal && varBlock.IsDefine {
		return ""
	}
	// Multi-return destructuring: a, b := foo()
	if len(varBlock.MultiNames) > 0 {
		return c.Ctx.Arch.MultiVarDecl(varBlock)
	}
	return c.Ctx.Arch.VarDecl(varBlock)
}

func (c *Compiler) compileCallBlock(n *parser.Node) string {
	callBlock := n.Value.(*parser.CallBlock)

	// 检查是否为泛型函数调用
	if IsGenericFunction(callBlock.Func) {
		specializedLabel := c.MonomorphizeIfNeeded(callBlock)
		if specializedLabel != "" {
			// 将调用重定向到特化后的函数
			callBlock.Func.Name = parser.NewName(specializedLabel)
			callBlock.Func = nil // 防止重复单态化
		}
	}

	return c.Ctx.Arch.Call(callBlock)
}

func (c *Compiler) compileExprBlock(n *parser.Node) string {
	exp := n.Value.(*parser.Expression)
	if exp.Separator == "[]=" {
		return c.Ctx.Arch.Exp(exp, "", "list index assignment")
	}
	// 多段名赋值（p1.x = 3、self.x += dx 等）：表达式里携带完整 VarBlock，
	// 转用变量声明路径生成正确的目标地址
	if exp.Var != nil && exp.Var.Value != nil {
		return c.Ctx.Arch.VarDecl(exp.Var)
	}
	return c.Ctx.Arch.Exp(exp, "", "expression statement")
}

func (c *Compiler) compileForBlock(n *parser.Node) string {
	forBlock := n.Value.(*parser.ForBlock)
	var code string
	code += c.Ctx.Arch.ForBegin(forBlock)
	code += c.Compile(n)
	// 块级释放：在循环体末尾释放该块内分配的对象
	code += c.emitBlockFrees(n)
	code += c.Ctx.Arch.ForEnd(forBlock)
	return code
}

// compileForRangeBlock 编译 for range 循环
func (c *Compiler) compileForRangeBlock(n *parser.Node) string {
	forBlock := n.Value.(*parser.ForBlock)
	if forBlock.Range == nil || len(forBlock.RangeNames) == 0 {
		return ""
	}

	var code string
	ps := c.Ctx.Arch.PointerSize()
	ln := c.Ctx.Arch.LengthName(ps)
	frame := c.Ctx.Arch.FramePtr()
	is64 := c.Ctx.Is64Bit

	// 寄存器名
	var rax, rdx, rbx string
	if is64 {
		rax, rdx, rbx = "RAX", "RDX", "RBX"
	} else {
		rax, rdx, rbx = "EAX", "EDX", "EBX"
	}

	// 1. 编译 range 表达式（list/string 的地址）
	// list 在栈上的布局: [ptr, len, cap]，共 3 × ps 字节
	code += c.Ctx.Arch.Exp(forBlock.Range, rax, "range target")

	// 2. 为循环体创建标签
	c.Ctx.ForCount++
	forBlock.Offset = c.Ctx.ForCount
	forLabel := "for_range_" + strconv.Itoa(forBlock.Offset)
	endLabel := forLabel + "_end"

	// 3. 分配临时空间存储 range 目标信息（ptr, len）
	// 在函数开头已经分配了空间，这里使用临时寄存器
	// 我们用 RBX 存储 ptr，RDX 存储 len

	// 从 list 结构加载 ptr 和 len
	// list 变量的栈地址: 用 exp 计算得到的是 ptr 值（list 的第一个字段）
	// 但我们需要访问 list 的 ptr 和 len 字段
	// 对于栈上的 list 变量，其布局是 [ptr, len, cap]
	// exp 对 list 变量返回的是 ptr 值（第一个字段）
	// 我们需要重新计算地址

	// 方案：使用 range 变量的 VarBlock 来获取地址
	if forBlock.Range.Var != nil {
		// 变量引用：加载其栈地址
		vb := forBlock.Range.Var
		var baseAddr string
		if vb.IsGlobal {
			baseAddr = "[rel __global_" + utils.ToNASMName(vb.Name.String()) + "]"
		} else {
			off := vb.Offset
			if off < 0 {
				baseAddr = "[" + frame + strconv.Itoa(off) + "]"
			} else if off == 0 {
				baseAddr = "[" + frame + "]"
			} else {
				baseAddr = "[" + frame + "+" + strconv.Itoa(off) + "]"
			}
		}
		// 加载 list 的 ptr 字段（offset 0）
		code += utils.Format("mov " + rbx + ", " + ln + " " + baseAddr + "; range ptr")
		// 加载 list 的 len 字段（offset ps）
		code += utils.Format("mov " + rdx + ", " + ln + " " + baseAddr[:len(baseAddr)-1] + "+" + strconv.Itoa(ps) + "]; range len")
	} else {
		// 表达式计算：假设返回的是 list 结构的首地址
		// 对于复杂表达式，需要先计算地址，然后从该地址加载 ptr 和 len
		// 暂时使用简化方案：range 表达式结果在 RAX 中，假设是 list 的 ptr
		code += utils.Format("mov " + rbx + ", " + rax + "; range ptr")
		// len 需要从 ptr-2*ps 位置读取（因为 list 结构是 [ptr, len, cap]，ptr 指向第一个元素）
		// 但实际上 exp 对 list 变量返回的是 ptr 字段的值
		// 我们需要原始地址来读取 len，这比较复杂
		// 暂时假设 range 只用于简单变量引用
		code += utils.Format("; TODO: complex range expression support")
		code += utils.Format("xor " + rdx + ", " + rdx + "; len=0 for now")
	}

	// 4. 初始化索引变量
	indexVar := forBlock.RangeNames[0]
	// 声明索引变量（在函数开头已声明，这里赋值为 0）
	code += utils.Format("mov " + ln + " [" + frame + strconv.Itoa(indexVar.Offset) + "], 0; range index = 0")

	// 5. 循环开始
	code += utils.Format("")
	code += utils.Format(forLabel + ": ; for range 循环开始")

	// 6. 检查索引 < len
	// 加载当前索引
	code += utils.Format("mov " + rax + ", " + ln + " [" + frame + strconv.Itoa(indexVar.Offset) + "]; 加载索引")
	// 比较索引和 len
	code += utils.Format("cmp " + rax + ", " + rdx + "; 索引 vs len")
	code += utils.Format("jge " + endLabel + "; 索引 >= len 则退出")

	// 7. 如果有第二个变量（value），加载 list[index]
	if len(forBlock.RangeNames) > 1 {
		valueVar := forBlock.RangeNames[1]
		elemSize := 8 // 默认元素大小
		if forBlock.Range.Type != nil {
			if lt, ok := forBlock.Range.Type.(*typeSys.ListType); ok {
				if lt.Elem() != nil {
					elemSize = lt.Elem().Size()
				}
			}
		}
		// 计算元素地址: ptr + index * elemSize
		code += utils.Format("imul " + rax + ", " + strconv.Itoa(elemSize) + "; index * elemSize")
		code += utils.Format("add " + rax + ", " + rbx + "; ptr + offset")
		// 加载元素
		code += utils.Format("mov " + rax + ", " + ln + " [" + rax + "]; 加载 list[index]")
		// 存储到 value 变量
		code += utils.Format("mov " + ln + " [" + frame + strconv.Itoa(valueVar.Offset) + "], " + rax + "; 存储 value")
	}

	// 8. 编译循环体
	code += c.Compile(n)

	// 9. 递增索引
	code += utils.Format("mov " + rax + ", " + ln + " [" + frame + strconv.Itoa(indexVar.Offset) + "]; 加载索引")
	code += utils.Format("add " + rax + ", 1; index++")
	code += utils.Format("mov " + ln + " [" + frame + strconv.Itoa(indexVar.Offset) + "], " + rax + "; 存储索引")

	// 10. 跳回循环开始
	code += utils.Format("jmp " + forLabel + "; 继续循环")

	// 11. 循环结束
	code += utils.Format(endLabel + ": ; for range 循环结束")

	return code
}

func (c *Compiler) compileBreakBlock(n *parser.Node) string {
	breakBlock := n.Value.(*parser.BreakBlock)
	current := n.Father
	forLevel := 0
	var targetFor *parser.ForBlock
	for current != nil {
		if fb, ok := current.Value.(*parser.ForBlock); ok {
			forLevel++
			if forLevel == breakBlock.Level {
				targetFor = fb
				break
			}
		}
		current = current.Father
	}
	if targetFor == nil {
		return "; break: no enclosing for loop at level " + fmt.Sprintf("%d", breakBlock.Level) + "\n"
	}
	forLabel := "for_" + strconv.Itoa(targetFor.Offset)
	return utils.Format("jmp " + forLabel + "_end")
}

func (c *Compiler) compileTypeBlock(n *parser.Node) string {
	return ""
}

func (c *Compiler) compileRootTail(node *parser.Node) string {
	if node.Father == nil {
		var code string
		// Emit extern declarations for build ext / build asm external calls
		if c.Ctx.Externs != nil {
			for extName := range c.Ctx.Externs {
				code += "extern " + extName + "\n"
			}
			code += "\n"
		}
		// Emit export alias labels (after all functions, jumps to function entry)
		if c.Ctx.Exports != nil {
			for exportName, funcName := range c.Ctx.Exports {
				code += exportName + ":\n"
				code += "    jmp " + funcName + "\n"
			}
			code += "\n"
		}
		if c.hasMainFunction(node) {
			code += c.generateStartEntry()
		}
		// 运行时辅助：边界检查 panic
		code += c.generatePanicOOB()
		// 运行时辅助：memmove(dst, src, n)
		code += c.generateMemmove()
		code += c.generateDataSection()
		code += c.CompileVtableSection() // emit vtable data for interface dispatch
		return code
	}
	return ""
}

func (c *Compiler) generateDataSection() string {
	if len(c.Ctx.StringConsts) == 0 && len(c.Ctx.GlobalStrings) == 0 {
		return ""
	}
	// 先为全局 string 变量的初始值分配字面量 label，确保 db 一并输出
	for _, vb := range c.Ctx.GlobalStrings {
		if vb.Value != nil && vb.Value.IsConst() && vb.Value.StringVal != "" {
			c.getStringLabel(vb.Value.StringVal)
		}
	}
	code := "\nsection .data\n"
	// 边界检查错误信息
	code += "    _oob_msg db \"index out of range\", 10\n"
	code += "    _oob_msg_len equ $ - _oob_msg\n"
	for val, label := range c.Ctx.StringConsts {
		escaped := strings.ReplaceAll(val, `\`, `\\`)
		escaped = strings.ReplaceAll(escaped, `"`, `\"`)
		escaped = strings.ReplaceAll(escaped, "\n", `\n`)
		escaped = strings.ReplaceAll(escaped, "\t", `\t`)
		escaped = strings.ReplaceAll(escaped, "\r", `\r`)
		code += fmt.Sprintf("    %s db \"%s\", 0\n", label, escaped)
		code += fmt.Sprintf("    %s_len equ $ - %s\n", label, label)
	}
	// 全局 string 变量：ptr/len/cap 三槽，槽宽随架构指针大小（x86 为 dd）
	dq := "dq"
	if c.Ctx.Arch.PointerSize() == 4 {
		dq = "dd"
	}
	for _, vb := range c.Ctx.GlobalStrings {
		name := "__global_" + utils.ToNASMName(vb.Name.String())
		var strVal string
		if vb.Value != nil && vb.Value.IsConst() && vb.Value.StringVal != "" {
			strVal = vb.Value.StringVal
		}
		if strVal == "" {
			code += "    " + name + " " + dq + " 0\n    " + name + "_len " + dq + " 0\n    " + name + "_cap " + dq + " 0\n"
			continue
		}
		label := c.getStringLabel(strVal)
		code += fmt.Sprintf("    %s %s %s\n", name, dq, label)
		code += fmt.Sprintf("    %s_len %s %d\n", name, dq, len(strVal))
		code += fmt.Sprintf("    %s_cap %s %d\n", name, dq, len(strVal))
	}
	return code
}

func (c *Compiler) getStringLabel(val string) string {
	if label, ok := c.Ctx.StringConsts[val]; ok {
		return label
	}
	c.Ctx.StrCount++
	label := "str_" + strconv.Itoa(c.Ctx.StrCount)
	c.Ctx.StringConsts[val] = label
	return label
}

func (c *Compiler) hasMainFunction(node *parser.Node) bool {
	for _, ch := range node.Children {
		if fb, ok := ch.Value.(*parser.FuncBlock); ok {
			if fb.Name.String() == "main" {
				return true
			}
		}
	}
	return false
}

func (c *Compiler) generateStartEntry() string {
	var code string
	code += utils.Format("; ==============================")
	code += utils.Format("; 程序入口点 (ELF入口)")
	code += utils.Format("_start:")
	utils.Count++
	code += utils.Format("call main")
	if c.Ctx.Is64Bit {
		code += utils.Format("mov rdi, rax")
		code += utils.Format("mov rax, 60")
		code += utils.Format("syscall\n")
	} else {
		code += utils.Format("mov ebx, eax")
		code += utils.Format("mov eax, 1")
		code += utils.Format("int 0x80\n")
	}
	utils.Count--
	return code
}

// generatePanicOOB 生成边界检查 panic 运行时辅助函数
// 签名：void _panic_index_oob(int index)
// 行为：打印 "index out of range" 到 stderr，然后 exit(1)
func (c *Compiler) generatePanicOOB() string {
	var code string
	code += utils.Format("; ==============================")
	code += utils.Format("; Runtime helper: index out of range panic")
	code += utils.Format("_panic_index_oob:")

	if c.Ctx.Is64Bit {
		// x86_64: write(2, msg, 21) + exit(1)
		// 参数已在栈上：[rsp+8] = index
		code += utils.Format("push rbp")
		code += utils.Format("mov rbp, rsp")
		code += utils.Format("push rbx")
		code += utils.Format("mov rax, 1")              // sys_write
		code += utils.Format("mov rdi, 2")              // stderr
		code += utils.Format("lea rsi, [rel _oob_msg]") // msg
		code += utils.Format("mov rdx, 21")             // len("index out of range\n")
		code += utils.Format("syscall")
		code += utils.Format("mov rax, 60") // sys_exit
		code += utils.Format("mov rdi, 1")  // exit code 1
		code += utils.Format("syscall")
		code += utils.Format("pop rbx")
		code += utils.Format("pop rbp")
		code += utils.Format("ret")
	} else {
		// x86: write(2, msg, 21) + exit(1)
		code += utils.Format("push ebp")
		code += utils.Format("mov ebp, esp")
		code += utils.Format("push ebx")
		code += utils.Format("mov eax, 4")        // sys_write
		code += utils.Format("mov ebx, 2")        // stderr
		code += utils.Format("mov ecx, _oob_msg") // msg
		code += utils.Format("mov edx, 21")       // len("index out of range\n")
		code += utils.Format("int 0x80")
		code += utils.Format("mov eax, 1") // sys_exit
		code += utils.Format("mov ebx, 1") // exit code 1
		code += utils.Format("int 0x80")
		code += utils.Format("pop ebx")
		code += utils.Format("pop ebp")
		code += utils.Format("ret")
	}
	return code
}

// generateMemmove 生成 memmove 运行时辅助函数
// 签名：void _memmove(ptr dst, ptr src, uint n)
// 行为：从 src 复制 n 字节到 dst，支持重叠区域（向前复制）
func (c *Compiler) generateMemmove() string {
	var code string
	code += utils.Format("; ==============================")
	code += utils.Format("; Runtime helper: memmove(dst, src, n)")
	code += utils.Format("_memmove:")

	if c.Ctx.Is64Bit {
		// x86_64 SysV: rdi=dst, rsi=src, rdx=n
		code += utils.Format("push rbp")
		code += utils.Format("mov rbp, rsp")
		code += utils.Format("push rbx")
		code += utils.Format("mov rcx, rdx") // rcx = byte count
		code += utils.Format("cmp rdi, rsi")
		code += utils.Format("jge .memmove_rev") // dst >= src → 反向复制
		// 正向复制
		code += utils.Format("cld")
		code += utils.Format("rep movsb")
		code += utils.Format("jmp .memmove_done")
		// 反向复制（处理重叠）
		code += utils.Format(".memmove_rev:")
		code += utils.Format("std")
		code += utils.Format("lea rsi, [rsi+rcx-1]") // src 末尾
		code += utils.Format("lea rdi, [rdi+rcx-1]") // dst 末尾
		code += utils.Format("rep movsb")
		code += utils.Format("cld") // 恢复方向标志
		code += utils.Format(".memmove_done:")
		code += utils.Format("pop rbx")
		code += utils.Format("pop rbp")
		code += utils.Format("ret")
	} else {
		// x86 cdecl: [ebp+8]=dst, [ebp+12]=src, [ebp+16]=n
		code += utils.Format("push ebp")
		code += utils.Format("mov ebp, esp")
		code += utils.Format("push esi")
		code += utils.Format("push edi")
		code += utils.Format("push ebx")
		code += utils.Format("mov ecx, [ebp+16]") // ecx = byte count
		code += utils.Format("mov esi, [ebp+12]") // esi = src
		code += utils.Format("mov edi, [ebp+8]")  // edi = dst
		code += utils.Format("cmp edi, esi")
		code += utils.Format("jge .memmove_rev") // dst >= src → 反向复制
		// 正向复制
		code += utils.Format("cld")
		code += utils.Format("rep movsb")
		code += utils.Format("jmp .memmove_done")
		// 反向复制（处理重叠）
		code += utils.Format(".memmove_rev:")
		code += utils.Format("std")
		code += utils.Format("lea esi, [esi+ecx-1]") // src 末尾
		code += utils.Format("lea edi, [edi+ecx-1]") // dst 末尾
		code += utils.Format("rep movsb")
		code += utils.Format("cld") // 恢复方向标志
		code += utils.Format(".memmove_done:")
		code += utils.Format("pop ebx")
		code += utils.Format("pop edi")
		code += utils.Format("pop esi")
		code += utils.Format("pop ebp")
		code += utils.Format("ret")
	}
	return code
}

func (c *Compiler) funcHandle(funcBlock *parser.FuncBlock, node *parser.Node) (code string) {
	//optimizer.OptimizeRecursion(c.Ctx.Now)           // 尝试优化递归函数
	//optimizer.ConvertRecursionToIteration(c.Ctx.Now) // 实际转换递归为迭代

	// 设置当前函数上下文
	c.Ctx.CurrentFunc = funcBlock
	c.currentFuncKey = funcBlock.Name.String()

	// 如果是单态化函数，设置 TypeSubst 供 codegen 使用（sizeof 等内建需要）
	origTypeSubst := c.Ctx.TypeSubst
	if c.typeSubsts != nil {
		if subst, ok := c.typeSubsts[funcBlock.MangledName()]; ok {
			c.Ctx.TypeSubst = subst
		}
	}

	defer func() {
		c.Ctx.CurrentFunc = nil
		c.currentFuncKey = ""
		c.Ctx.TypeSubst = origTypeSubst // 恢复 TypeSubst
	}()

	name := funcBlock.MangledName()

	// build link：函数以链接名输出为全局符号（如 __string_len），
	// 同时保留原函数名标签（供包内/跨包直接调用），两个标签指向同一实现。
	alias := ""
	if linkFlag := c.findLinkFlag(funcBlock); linkFlag != nil {
		alias = linkFlag.Link
	}

	// 重置寄存器分配器（每个函数独立）
	c.Ctx.Reg.Reset()

	// 先生成函数头部（不缩进）
	code += utils.Format("; ==============================")
	code += utils.Format("; Function: " + name)
	if alias != "" {
		code += utils.Format(alias + ":")
	}
	code += utils.Format(name + ":")

	// 增加缩进，让函数体指令有缩进
	utils.Count++

	// 恢复 Ctx.Now 为当前函数节点（Prologue 需要遍历函数体设置变量偏移）
	savedNow := c.Ctx.Now
	c.Ctx.Now = node

	// 生成 prologue（push rbp, mov rbp rsp, 保存 callee-save, 分配栈空间）
	// callee-save 固定全部保存，栈布局可在函数体编译前确定，避免依赖分配器运行结果
	code += c.Ctx.Arch.Prologue(funcBlock)

	// 编译函数体（此时参数/变量偏移已正确设置）
	code += c.Compile(c.Ctx.Now)

	// GC 出口释放（Phase 3）：所有 return 都 jmp 到 func_end（由 Epilogue 发出），
	// fallthrough 也汇合于此，故在 body 之后、epilogue 之前拼接一次释放序列
	// 即可覆盖全部出口。main 无需 GC；build link 别名是链接符号包装器，跳过。
	if funcBlock.Name.String() != "main" && alias == "" {
		code += c.emitGCFrees(funcBlock, node)
	}

	// 生成 epilogue（清理栈、恢复寄存器、返回）
	code += c.Ctx.Arch.Epilogue(funcBlock)

	// 恢复 Ctx.Now
	c.Ctx.Now = savedNow

	// 减少缩进
	utils.Count--
	code += utils.Format("; ======函数完毕=======\n\n")

	// 清理寄存器分配数据
	c.Ctx.Reg.Reset()

	return
}

func pr(block *parser.Node, tabnum int) {
	if block.Ignore {
		return
	}
	fmt.Println(strings.Repeat("\t", tabnum), reflect.TypeOf(block.Value), block.Value)
	for _, k := range block.Children {
		pr(k, tabnum+1)
	}
}

// emitGCFrees 生成函数出口的 GC 释放序列（Phase 3 代码生成）。
// 查询 gc.LLRResults 中该函数的 LLR 分析结果，把每个帧内拥有变量的栈槽
// 指针交给 memory.free 释放。无结果时跳过。
func (c *Compiler) emitGCFrees(funcBlock *parser.FuncBlock, node *parser.Node) string {
	llr := gc.LLRResults[funcBlock.Name.String()]
	if llr == nil || len(llr.Frees) == 0 && len(llr.FieldFrees) == 0 {
		return ""
	}
	is64 := c.Ctx.Arch.PointerSize() == 8
	slot := "QWORD"
	base := "rbp"
	if !is64 {
		slot = "DWORD"
		base = "ebp"
	}
	// 构建 memory.free 的 CallBlock
	freeNameParts := []parser.NamePart{{Name: "std_memory", IsPkgPath: true}, {Name: "free"}}
	freeFunc := &parser.FuncBlock{
		Name: parser.Name(freeNameParts),
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}
	freeCall := &parser.CallBlock{
		Name: freeFunc.Name,
		Func: freeFunc,
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}
	var code string

	// 收集已在块级释放的变量名，避免函数出口重复释放（double-free）
	blockFreedVars := map[string]bool{}
	for _, frees := range llr.BlockFreesMap {
		for _, fr := range frees {
			blockFreedVars[fr.VarName] = true
		}
	}

	// 字段级级联释放：在释放 struct 之前先释放其 owning 字段
	// 确保先释放子对象再释放父容器（sub-before-parent）
	for _, ff := range llr.FieldFrees {
		// 跳过已在块级释放的变量的字段，避免访问已释放内存
		if blockFreedVars[ff.VarName] {
			continue
		}
		off := findLocalVarOffset(node, ff.VarName)
		if off == -1 {
			continue
		}
		// 查找字段偏移
		fieldOff := c.findStructFieldOffset(funcBlock, node, ff.VarName, ff.FieldName)
		if fieldOff == -1 {
			continue
		}
		code += utils.Format("; gc: free field " + ff.VarName + "." + ff.FieldName)
		// 使用 RAX/EAX 作为临时寄存器（函数出口前无需保留）
		tmpReg := c.Ctx.Arch.ReturnReg()
		code += utils.Format("mov " + tmpReg + ", " + slot + " [" + base + strconv.Itoa(off) + "]")
		// 计算字段地址 = struct_ptr + field_offset
		if fieldOff > 0 {
			code += utils.Format("add " + tmpReg + ", " + strconv.Itoa(fieldOff))
		}
		// 加载字段值（指针）
		code += utils.Format("mov " + tmpReg + ", " + c.Ctx.Arch.LengthName(c.Ctx.Arch.PointerSize()) + " [" + tmpReg + "]")
		// 释放字段值（free）
		if is64 {
			code += utils.Format("mov RDI, " + tmpReg)
			code += utils.Format("call " + freeFunc.MangledName())
		} else {
			code += utils.Format("push " + tmpReg)
			code += c.Ctx.Arch.Call(freeCall)
			code += utils.Format("add esp, 4")
		}
	}

	// 顶层变量释放
	for _, fr := range llr.Frees {
		if fr.Type == "heap-ptr" {
			// 孤儿对象：用 site 名匹配局部变量（通过 ObjSite 找到绑定名）
			found := false
			for _, obj := range llr.Objects {
				if obj.FrameOwn && obj.Site == fr.VarName && obj.Name != "" {
					fr.VarName = obj.Name
					found = true
					break
				}
			}
			if !found {
				continue
			}
		}
		// 跳过已在块级释放的变量，避免 double-free
		if blockFreedVars[fr.VarName] {
			continue
		}
		off := findLocalVarOffset(node, fr.VarName)
		if off == -1 {
			continue // 栈槽未找到（未分配/被豁免），跳过该变量
		}
		code += utils.Format("; gc: free " + fr.VarName)
		if is64 {
			code += utils.Format("mov RDI, " + slot + " [" + base + strconv.Itoa(off) + "]")
			code += utils.Format("call " + freeFunc.MangledName())
		} else {
			code += utils.Format("push " + slot + " [" + base + strconv.Itoa(off) + "]")
			code += c.Ctx.Arch.Call(freeCall)
		}
	}
	return code
}

// emitBlockFrees 生成指定块节点的块级 GC 释放序列。
func (c *Compiler) emitBlockFrees(blockNode *parser.Node) string {
	llr := gc.LLRResults[c.currentFuncKey]
	if llr == nil || llr.BlockFreesMap == nil {
		return ""
	}
	frees := llr.BlockFreesMap[blockNode]
	if len(frees) == 0 {
		return ""
	}
	is64 := c.Ctx.Arch.PointerSize() == 8
	slot := "QWORD"
	base := "rbp"
	if !is64 {
		slot = "DWORD"
		base = "ebp"
	}
	nameParts := []parser.NamePart{{Name: "std_memory", IsPkgPath: true}, {Name: "free"}}
	freeFunc := &parser.FuncBlock{
		Name: parser.Name(nameParts),
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}
	freeCall := &parser.CallBlock{
		Name: freeFunc.Name,
		Func: freeFunc,
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}
	var code string
	for _, fr := range frees {
		off := findLocalVarOffset(blockNode, fr.VarName)
		if off == -1 {
			continue
		}
		code += utils.Format("; gc: block free " + fr.VarName)
		if is64 {
			code += utils.Format("mov RDI, " + slot + " [" + base + strconv.Itoa(off) + "]")
			code += utils.Format("call " + freeFunc.MangledName())
		} else {
			code += utils.Format("push " + slot + " [" + base + strconv.Itoa(off) + "]")
			code += c.Ctx.Arch.Call(freeCall)
		}
	}
	return code
}

// 只匹配非全局的 IsDefine VarBlock 且 Offset 已分配（非 0）；未找到返回 -1。
func findLocalVarOffset(node *parser.Node, name string) int {
	if node == nil {
		return -1
	}
	if vb, ok := node.Value.(*parser.VarBlock); ok && !vb.IsGlobal && vb.IsDefine &&
		vb.Offset != 0 && vb.Name != nil && vb.Name.First() == name {
		return vb.Offset
	}
	for _, ch := range node.Children {
		if off := findLocalVarOffset(ch, name); off != -1 {
			return off
		}
	}
	return -1
}

// findStructFieldOffset 查找 struct 字段在 struct 内的偏移量。
func (c *Compiler) findStructFieldOffset(funcBlock *parser.FuncBlock, node *parser.Node, varName, fieldName string) int {
	var structType *typeSys.StructType
	// 查找函数参数
	for _, ag := range funcBlock.Args {
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
		walk(node)
	}
	if structType == nil {
		return -1
	}
	structType.Layout()
	field := structType.Field(fieldName)
	if field == nil {
		return -1
	}
	return field.Offset
}
