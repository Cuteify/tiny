package compile

import (
	"cuteify/compile/context"
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
	Ctx           *context.Context // 编译器上下文
	RootGenerated bool             // 标记是否已生成 section .text
	stringSyms    map[string]bool  // build link 声明的全局符号（如 __string_len）
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
	c.collectLinkSyms(node)
	c.Ctx.StringSyms = c.stringSyms
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

// findLinkFlag 返回函数的 build link 标志（若有）。
func (c *Compiler) findLinkFlag(funcBlock *parser.FuncBlock) *parser.Build {
	for _, bf := range funcBlock.BuildFlags {
		if bf.Type == "link" && !bf.Ignore {
			return bf
		}
	}
	return nil
}

func (c *Compiler) initializeContext() {
	if c.Ctx == nil {
		c.Ctx = context.NewContext()
	}
	if c.Ctx.Arch == nil {
		c.Ctx.Arch = NewArch(GoArch, c.Ctx)
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
	return c.generateGlobalSection(node) + "section .text\nglobal _start\n\n"
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
		if vb.Value != nil && vb.Value.IsConst() {
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
		return c.compileForBlock(n)
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
		switch cond.Separator {
		case "==":
			jumpOp = "jne" // 相等则不跳转
		case "!=":
			jumpOp = "je" // 不等则不跳转
		case "<":
			jumpOp = "jge" // 小于则不跳转
		case ">":
			jumpOp = "jle" // 大于则不跳转
		case "<=":
			jumpOp = "jg" // 小于等于则不跳转
		case ">=":
			jumpOp = "jl" // 大于等于则不跳转
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

func (c *Compiler) compileReturnBlock(n *parser.Node) string {
	ret := n.Value.(*parser.ReturnBlock)
	return c.Ctx.Arch.Return(ret)
}

func (c *Compiler) compileVarBlock(n *parser.Node) string {
	varBlock := n.Value.(*parser.VarBlock)
	if varBlock.IsGlobal && varBlock.IsDefine {
		return ""
	}
	return c.Ctx.Arch.VarDecl(varBlock)
}

func (c *Compiler) compileCallBlock(n *parser.Node) string {
	callBlock := n.Value.(*parser.CallBlock)
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
	code += c.Ctx.Arch.ForEnd(forBlock)
	return code
}

func (c *Compiler) compileTypeBlock(n *parser.Node) string {
	return ""
}

func (c *Compiler) compileRootTail(node *parser.Node) string {
	if node.Father == nil {
		var code string
		if c.hasMainFunction(node) {
			code += c.generateStartEntry()
		}
		code += c.generateDataSection()
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

func (c *Compiler) funcHandle(funcBlock *parser.FuncBlock, node *parser.Node) (code string) {
	//optimizer.OptimizeRecursion(c.Ctx.Now)           // 尝试优化递归函数
	//optimizer.ConvertRecursionToIteration(c.Ctx.Now) // 实际转换递归为迭代

	// 设置当前函数上下文
	c.Ctx.CurrentFunc = funcBlock
	defer func() { c.Ctx.CurrentFunc = nil }()

	name := funcBlock.Name.NASM()
	if name != "main" {
		name = name + strconv.Itoa(len(funcBlock.Args))
	}

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
