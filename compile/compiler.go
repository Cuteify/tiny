package compile

import (
	"fmt"
	"cuteify/parser"
	"strconv"
	"strings"
)

const GoArch = "x86"

// Compiler 结构体
type Compiler struct {
	VarStackSize int       // 变量栈的大小
	EspOffset    int       // 堆栈指针偏移量
	Reg          *Register // 寄存器集合
	ExpCount     int       // 表达式计数
	ArgOffset    int       // 参数偏移量
	IfCount      int       // if 块数量计数
	ExpType      int       // 表达式类型
}

// Compile 方法
func (c *Compiler) Compile(node *parser.Node) (code string) {
	if c.Reg == nil {
		c.Reg = &Register{}
	}
	if node.Father == nil {
		code = "section .text\nglobal main\n\n"
	}
	for i := 0; i < len(node.Children); i++ {
		n := node.Children[i]
		switch n.Value.(type) {
		case *parser.FuncBlock:
			code += c.CompileFunc(n)
		case *parser.IfBlock:
			ifBlock := n.Value.(*parser.IfBlock)
			c.IfCount++
			label := fmt.Sprintf("if_%d", c.IfCount)
			if ifBlock.Else {
				code += c.CompileExpr(ifBlock.Condition, "else_"+label, "")
			} else {
				code += c.CompileExpr(ifBlock.Condition, "end_"+label, "")
			}
			code += Format(label+":") + c.Compile(n)
			if ifBlock.Else {
				code += Format("else_" + label + ":")
				if ifBlock.ElseBlock.Value.(*parser.ElseBlock).IfCondition != nil {
					code += c.CompileExpr(ifBlock.ElseBlock.Value.(*parser.ElseBlock).IfCondition, "end_"+label, "")
				}
				if ifBlock.ElseBlock != nil {
					code += c.Compile(ifBlock.ElseBlock)
				}
			}
			code += Format("end_" + label + ":")
		case *parser.ReturnBlock:
			returnBlock:=n.Value.(*parser.ReturnBlock)
			for (i:=len(returnBlock.))
			code += Format("add esp, " + strconv.Itoa(c.VarStackSize) + "; 还原栈指针")
			code += Format("pop ebp; 跳转到函数返回部分")
			code += Format("ret\n")
		case *parser.VarBlock:
			varBlock := n.Value.(*parser.VarBlock)
			if varBlock.IsDefine {
				c.EspOffset -= varBlock.Type.Size()
				varBlock.Offset = c.EspOffset
				addr := ""
				if varBlock.Offset <= 0 {
					addr = "[ebp" + strconv.FormatInt(int64(varBlock.Offset), 10) + "]"
				} else {
					addr = "[ebp+" + strconv.FormatInt(int64(varBlock.Offset), 10) + "]"
				}
				code += c.CompileExpr(varBlock.Value, " "+getLengthName(varBlock.Type.Size())+addr, "设置变量")
			} else {
				switch varBlock.Define.Value.(type) {
				case *parser.VarBlock:
					varBlock.Offset = varBlock.Define.Value.(*parser.VarBlock).Offset
				case *parser.ArgBlock:
					varBlock.Offset = varBlock.Define.Value.(*parser.ArgBlock).Offset
				}
				addr := ""
				if varBlock.Offset <= 0 {
					addr = "[ebp" + strconv.FormatInt(int64(varBlock.Offset), 10) + "]"
				} else {
					addr = "[ebp+" + strconv.FormatInt(int64(varBlock.Offset), 10) + "]"
				}
				code += c.CompileExpr(varBlock.Value, " "+getLengthName(varBlock.Type.Size())+addr, "设置变量")
			}
		case *parser.CallBlock:
			code += c.CompileCall(n)
		case *parser.Build:
			code += c.CompileBuild(n)
		}
	}
	switch node.Value.(type) {
	case *parser.FuncBlock:
		switch node.Children[len(node.Children)-1].Value.(type) {
		case *parser.ReturnBlock:
		default:
			code += Format("add esp, " + strconv.Itoa(c.VarStackSize) + "; 还原栈指针")
			code += Format("pop ebp; 弹出函数基指针")
			code += Format("ret\n")
		}
		if count > 0 {
			count--
		}
		code += Format("; ======函数完毕=======")
	}
	if node.Father == nil {
		code += Format("\n\nmain:\ncall test.main0\nPRINT_STRING \"MyLang First Finish!\"\nret\n")
	}
	return code
}

// CompileFunc 方法
func (c *Compiler) CompileFunc(node *parser.Node) (code string) {
	funcBlock := node.Value.(*parser.FuncBlock)
	for i := 0; i < len(funcBlock.BuildFlags); i++ {
		bdf := funcBlock.BuildFlags[i]
		if bdf.Type == "ext" {
			return
		}
	}
	if funcBlock.Name == "main" {
		return ""
	} else {
		funcBlock.Name += strconv.Itoa(len(funcBlock.Args))
	}
	code += Format("\n; " + strings.Repeat("=", 30) + "\n; Function:" + funcBlock.Name)
	code += Format(funcBlock.Name + ":")
	count++
	code += Format("push ebp; 函数基指针入栈")
	code += Format("mov ebp, esp; 设置基指针")

	c.VarStackSize = 0
	c.EspOffset = 0
	c.ArgOffset = 0
	c.calculateVarStackSize(node)
	code += Format("sub esp, " + strconv.Itoa(c.VarStackSize) + "; 调整栈指针")
	for i := 0; i < len(funcBlock.Args); i++ {
		arg := funcBlock.Args[i]
		c.ArgOffset += arg.Type.Size()
		arg.Offset = c.ArgOffset + 4
	}
	code += c.Compile(node)
	return code
}

// 计算变量的栈空间
func (c *Compiler) calculateVarStackSize(node *parser.Node) {
	for _, child := range node.Children {
		switch child.Value.(type) {
		case *parser.VarBlock:
			if child.Value.(*parser.VarBlock).IsDefine {
				c.VarStackSize += child.Value.(*parser.VarBlock).Type.Size()

			}
		case *parser.IfBlock:
			c.calculateVarStackSize(child)
			if child.Value.(*parser.IfBlock).Else {
				c.calculateVarStackSize(child.Value.(*parser.IfBlock).ElseBlock)
			}
		case *parser.FuncBlock:
			c.calculateVarStackSize(child)
		case *parser.CallBlock:
			funcBlock := child.Value.(*parser.CallBlock).Func
			for i := 0; i < len(funcBlock.BuildFlags); i++ {
				bdf := funcBlock.BuildFlags[i]
				if bdf.Type == "UseMoreStack" {
					continue
				}
			}
			for i := 0; i < len(child.Value.(*parser.CallBlock).Args); i++ {
				c.VarStackSize += child.Value.(*parser.CallBlock).Args[i].Defind.Type.Size()
			}
		}
	}
}

func getLengthName(size int) string {
	switch size {
	case 1:
		return "BYTE"
	case 2:
		return "WORD"
	case 4:
		return "DWORD"
	case 8:
		return "QWORD"
	default:
		return ""
	}
}

// compileCallBlock 处理函数调用块
func (c *Compiler) CompileCall(node *parser.Node) (code string) {
	// 设置参数
	// 便利参数，然后生成，然后设置到寄存器中，大于等于4个参数时，需要先将参数压入栈中，然后再从栈中取出
	callBlock := node.Value.(*parser.CallBlock)
	funcBlock := node.Value.(*parser.CallBlock).Func
	afterCode := ""
	/*if len(callBlock.Args) >= 4 {
		// 先将参数压入栈中
		for i := len(callBlock.Args) - 1; i >= 4; i-- {
			//处理表达式到栈中, 根据c.CallCount来生成一个寄存器位置
			code += c.CompileExpr(callBlock.Args[i].Value, " [ebp+"+strconv.Itoa(c.CallCount)+"] ; 设置 "+callBlock.Args[i].Name+" 参数")
			c.CallCount += callBlock.Args[i].Type.Size()
		}
		// 然后从栈中取出参数
		for i := 3; i >= 0; i-- {
			reg := c.Reg.GetRegister(callBlock.Name + "_" + callBlock.Args[i].Name)
			if reg.BeforeCode != "" {
				code += reg.BeforeCode
			}
			code += c.CompileExpr(callBlock.Args[i].Value, " "+reg.RegName+"")
			afterCode += reg.AfterCode
		}
	} else {
		for i := len(callBlock.Args) - 1; i >= 0; i-- {
			reg := c.Reg.GetRegister(callBlock.Name + "_" + callBlock.Args[i].Name)
			if reg.BeforeCode != "" {
				code += reg.BeforeCode
			}
			code += c.CompileExpr(callBlock.Args[i].Value, " "+reg.RegName+"")
			afterCode += reg.AfterCode
		}
	}*/
	useMoreStack := false
	for i := 0; i < len(funcBlock.BuildFlags); i++ {
		bdf := funcBlock.BuildFlags[i]
		if bdf.Type == "UseMoreStack" {
			useMoreStack = true
		}
	}
	// 先将参数压入栈中
	for i := len(callBlock.Args) - 1; i >= 0; i-- {
		//处理表达式到栈中, 根据c.CallCount来生成一个寄存器位置
		if callBlock.Args[i].Type == nil {
			if callBlock.Args[i].Defind.Type == nil {
				continue
			}
			callBlock.Args[i].Type = callBlock.Args[i].Defind.Type
		}
		if useMoreStack {
			code += c.CompileExpr(callBlock.Args[i].Value, "push", "设置函数参数")
		} else {
			code += c.CompileExpr(callBlock.Args[i].Value, getLengthName(callBlock.Args[i].Type.Size())+"[esp+"+strconv.Itoa(callBlock.Args[i].Defind.Offset-4)+"]", "设置函数参数")
		}
	}
	for i := 0; i < len(funcBlock.BuildFlags); i++ {
		bdf := funcBlock.BuildFlags[i]
		if bdf.Type == "ext" {
			code += Format("extern " + bdf.Ext + "; 外部函数")
			code += Format("call " + bdf.Ext + "; 调用外部函数")
			if afterCode != "" {
				code += afterCode
			}
			return code
		}
	}
	code += Format("call " + node.Value.(*parser.CallBlock).Func.Name + "; 调用函数")
	if afterCode != "" {
		code += afterCode
	}
	return code
}
