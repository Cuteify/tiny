package compile

import (
	"fmt"
	"future/parser"
	"runtime"
	"strconv"
	"strings"
)

const GoArch = runtime.GOARCH

type Compiler struct {
	VarStackSize int
	EspOffset    int
	RegTmp       int
	Reg          *Register
	ExpCount     int
	IfCount      int
	ExpType      int
}

func (c *Compiler) Compile(node *parser.Node) (code string) {
	if c.Reg == nil {
		c.Reg = &Register{}
	}
	if node.Father == nil {
		code = "\033[35msection\033[0m .text\n\033[35mglobal\033[0m main\n\n"
	}
	for i := 0; i < len(node.Children); i++ {
		n := node.Children[i]
		switch n.Value.(type) {
		case *parser.FuncBlock:
			code += c.CompileFunc(n)
		case *parser.IfBlock:
			ifBlock := n.Value.(*parser.IfBlock)
			// 使用全局的ifCount来生成一个唯一的标签
			c.IfCount++
			label := fmt.Sprintf("if_%d", c.IfCount)
			// 生成if条件判断的代码
			if ifBlock.Else {
				code += c.CompileExpr(ifBlock.Condition, "else_"+label)
			} else {
				code += c.CompileExpr(ifBlock.Condition, "end_"+label)
			}
			// 生成if块的代码
			code += Format(label+":\n") + c.Compile(n)
			if ifBlock.Else {
				code += Format("else_" + label + ":\n")
				// 生成else块的代码
				if ifBlock.ElseBlock.Value.(*parser.ElseBlock).IfCondition != nil {
					code += c.CompileExpr(ifBlock.ElseBlock.Value.(*parser.ElseBlock).IfCondition, "end_"+label)
				}
				if ifBlock.ElseBlock != nil {
					code += c.Compile(ifBlock.ElseBlock)
				}
			}
			// 生成endif的标签
			code += Format("end_" + label + ":\n")
		case *parser.ReturnBlock:
			code += Format("\033[35mpop\033[0m ebp\033[32m; 跳转到函数返回部分\n")
			code += Format("\033[35mret\033[0m\n\n")
		case *parser.VarBlock:
			varBlock := n.Value.(*parser.VarBlock)
			if varBlock.IsDefine {
				c.EspOffset -= varBlock.Type.Size()
				varBlock.Offset = c.EspOffset
				fmt.Println()
				code += c.CompileExpr(varBlock.Value, " \033[34m"+getLengthName(varBlock.Type.Size())+"\033[0m[ebp"+strconv.FormatInt(int64(varBlock.Offset), 10)+"]\033[0m")
			} else {
				varBlock.Offset = varBlock.Define.Value.(*parser.VarBlock).Offset
				code += c.CompileExpr(varBlock.Value, " \033[34m"+getLengthName(varBlock.Type.Size())+"\033[0m[ebp"+strconv.FormatInt(int64(varBlock.Offset), 10)+"]\033[0m")
			}
		case *parser.CallBlock:
			// 设置参数
			code += Format("\033[35mcall\033[0m " + n.Value.(*parser.CallBlock).Func.Name + "\033[32m; 调用函数\n")
		}
	}
	switch node.Value.(type) {
	case *parser.FuncBlock:
		if count > 0 {
			count--
		}
		code += Format("\033[32m; ======函数完毕=======\n")
	}
	return code
}

func (c *Compiler) CompileFunc(node *parser.Node) (code string) {
	funcBlock := node.Value.(*parser.FuncBlock)
	if funcBlock.Name == "main" {
		return ""
	} else {
		funcBlock.Name += strconv.Itoa(len(funcBlock.Args))
	}
	code += Format("\n\033[32m; " + strings.Repeat("=", 30) + "\n; Function:" + node.Value.(*parser.FuncBlock).Name + "\n")
	code += Format(node.Value.(*parser.FuncBlock).Name + ":\n")
	count++
	code += Format("\033[35mpush\033[0m \033[34mebp\033[0m\033[32m; 函数基指针入栈\n")
	code += Format("\033[35mmov\033[0m \033[34mebp\033[0m, \033[34mesp\033[0m\033[32m; 设置基指针\n")
	// 计算需要的栈空间
	c.VarStackSize = 0
	c.EspOffset = 0
	c.RegTmp = 0
	// 深度优先遍历节点，计算需要的栈空间
	c.calculateVarStackSize(node)
	code += Format("\033[35msub\033[0m \033[34mrsp\033[0m, " + strconv.Itoa(c.VarStackSize) + "\033[32m; 为局部变量分配空间\n")
	code += c.Compile(node)
	return code
}

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