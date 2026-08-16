package compile

import (
	"cuteify/compile/context"
	"cuteify/parser"
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
}

// NewCompiler 创建新的编译器
func NewCompiler(parser *parser.Parser) *Compiler {
	return &Compiler{
		Ctx: context.NewContext(),
	}
}

// Compile 编译入口方法，将AST节点编译为汇编代码
func (c *Compiler) Compile(node *parser.Node) (code string) {
	c.initializeContext()
	code = c.compileRoot(node, code)
	code += c.compileChildren(node, "")
	code += c.compileRootTail(node)
	return code
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
		name := "__global_" + vb.Name.First()
		size := vb.Type.Size()
		if size != 4 && size != 8 {
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
		if cond.Left != nil {
			code += c.Ctx.Arch.Exp(cond.Left, scratchReg1, "left operand")
			code += utils.Format("push " + scratchReg1 + "; 保护左操作数\n")
		}
		if cond.Right != nil {
			code += c.Ctx.Arch.Exp(cond.Right, scratchReg2, "right operand")
		}
		if cond.Left != nil {
			code += utils.Format("pop " + scratchReg1 + "; 恢复左操作数\n")
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
	if len(c.Ctx.StringConsts) == 0 {
		return ""
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
	return code
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

	// 重置寄存器分配器（每个函数独立）
	c.Ctx.Reg.Reset()

	// 先生成函数头部（不缩进）
	code += utils.Format("; ==============================")
	code += utils.Format("; Function: " + name)
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
