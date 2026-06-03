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
	Ctx *context.Context // 编译器上下文
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
	code += c.compileChildren(node, code)
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
	if node.Father == nil {
		return "section .text\nglobal _start\n\n"
	}
	return ""
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
			if buildFlag.Type == "os" && buildFlag.Ignore {
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
	// 变量栈设置和栈大小计算现在由 arch.Func 调用 arch.SetupVarOffsets 处理
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

	code += c.Ctx.Arch.Exp(ifBlock.Condition, endLabel, "")

	code += utils.Format(label+":") + c.Compile(n)

	if ifBlock.Else {
		code += c.compileElseBlock(ifBlock, label)
	}
	code += utils.Format("end_" + label + ":")
	return code
}

func (c *Compiler) compileElseBlock(ifBlock *parser.IfBlock, label string) string {
	var code string
	code += utils.Format("else_" + label + ":")
	if ifBlock.ElseBlock.Value.(*parser.ElseBlock).IfCondition != nil {
		code += c.Ctx.Arch.Exp(ifBlock.ElseBlock.Value.(*parser.ElseBlock).IfCondition, "end_"+label, "")
	}
	if ifBlock.ElseBlock != nil {
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
	if varBlock.IsDefine && varBlock.Value == nil {
		return ""
	}
	return c.Ctx.Arch.Var(varBlock)
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
	return c.Ctx.Arch.Exp(exp, "", "expression statement")
}

func (c *Compiler) compileForBlock(n *parser.Node) string {
	forBlock := n.Value.(*parser.ForBlock)
	var code string
	code += c.Ctx.Arch.For(forBlock)
	code += c.Compile(n)
	code += c.Ctx.Arch.EndFor(forBlock)
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
	return code
}

func (c *Compiler) funcHandle(funcBlock *parser.FuncBlock, node *parser.Node) (code string) {
	//optimizer.OptimizeRecursion(c.Ctx.Now)           // 尝试优化递归函数
	//optimizer.ConvertRecursionToIteration(c.Ctx.Now) // 实际转换递归为迭代

	// 设置当前函数上下文
	c.Ctx.CurrentFunc = funcBlock
	defer func() { c.Ctx.CurrentFunc = nil }()

	name := funcBlock.Name.String()
	if name != "main" {
		name = name + strconv.Itoa(len(funcBlock.Args))
	}
	code += utils.Format("; ==============================")
	code += utils.Format("; Function: " + name)
	code += utils.Format(name + ":")
	utils.Count++
	code += c.Ctx.Arch.Func(funcBlock)

	code += c.Compile(c.Ctx.Now)

	// 若最后不是显式 return，则补齐尾部清理
	if _, ok := node.Children[len(node.Children)-1].Value.(*parser.ReturnBlock); !ok {
		code += c.Ctx.Arch.Return(nil)
	}
	if utils.Count > 0 {
		utils.Count--
	}
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
