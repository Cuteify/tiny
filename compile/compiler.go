package compile

import (
	"cuteify/compile/arch"
	"cuteify/compile/arch/x86"
	"cuteify/compile/regmgr"
	"cuteify/optimizer"
	"cuteify/parser"
	"cuteify/utils"
	"fmt"
	"os"
	"strconv"
)

var GoArch = "x86"

func init() {
	if v := os.Getenv("CUTE_ARCH"); v != "" {
		GoArch = v
		fmt.Println("Using target arch:", GoArch)
	}
}

func NewArch(arch string) arch.Arch {
	switch arch {
	case "x86":
		return &x86.Cdecl{}
	case "x86.cdecl":
		return &x86.Cdecl{}

	case "x86.stdcall":
		return &x86.Stdcall{}

	/*case "x86.fastcall":
	return &x86FastcallArch{}*/
	default:
		return &x86.Cdecl{}
	}
}

// Compiler 编译器结构体，负责将AST转换为汇编代码
type Compiler struct {
	VarStackSize int            // 变量栈的大小，用于跟踪局部变量所需栈空间
	EspOffset    int            // 堆栈指针偏移量，用于跟踪当前栈帧中变量的位置
	Reg          *regmgr.RegMgr // 寄存器集合，用于管理寄存器分配
	ExpCount     int            // 表达式计数，用于给表达式生成唯一标识
	ArgOffset    int            // 参数偏移量，用于跟踪函数参数在栈中的位置
	IfCount      int            // if 块数量计数，用于生成唯一的if标签
	Parser       *parser.Parser
	Arch         arch.Arch
	Now          *parser.Node
}

// Compile 编译入口方法，将AST节点编译为汇编代码
func (c *Compiler) Compile(node *parser.Node) (code string) {
	if c.Arch == nil {
		c.Arch = NewArch(GoArch)
		c.Reg = c.Arch.Regs()
	}
	if node.Father == nil {
		code = "section .text\nglobal _start\n\n"
	}
	for i := 0; i < len(node.Children); i++ {
		n := node.Children[i]
		if n.Ignore {
			continue
		}
		c.Now = n
		c.Arch.Now(n)
		switch n.Value.(type) {
		case *parser.FuncBlock:
			funcBlock := n.Value.(*parser.FuncBlock)
			funcBlock.Check(c.Parser) // parser
			//fmt.Println(funcBlock.Name)
			optimizer.AnalyzeRecursion(n)
			name := funcBlock.Name
			if name != "main" {
				name = name + strconv.Itoa(len(funcBlock.Args))
			}
			code += utils.Format("; ==============================")
			code += utils.Format("; Function: " + name)
			code += utils.Format(name + ":")
			utils.Count++
			code += c.Arch.Func(funcBlock)
			code += c.Compile(n)
		case *parser.IfBlock:
			ifBlock := n.Value.(*parser.IfBlock)
			c.IfCount++
			label := fmt.Sprintf("if_%d", c.IfCount)
			if ifBlock.Else {
				code += c.Arch.Exp(ifBlock.Condition, "else_"+label, "")
			} else {
				code += c.Arch.Exp(ifBlock.Condition, "end_"+label, "")
			}
			code += utils.Format(label+":") + c.Compile(n)
			if ifBlock.Else {
				code += utils.Format("else_" + label + ":")
				if ifBlock.ElseBlock.Value.(*parser.ElseBlock).IfCondition != nil {
					code += c.Arch.Exp(ifBlock.ElseBlock.Value.(*parser.ElseBlock).IfCondition, "end_"+label, "")
				}
				if ifBlock.ElseBlock != nil {
					code += c.Compile(ifBlock.ElseBlock)
				}
			}
			code += utils.Format("end_" + label + ":")
		case *parser.ReturnBlock:
			//returnBlock:=n.Value.(*parser.ReturnBlock)
			/*code += utils.Format("add esp, " + strconv.Itoa(c.VarStackSize) + "; 还原栈指针")
			code += utils.Format("pop ebp; 跳转到函数返回部分")
			code += utils.Format("ret\n")*/
			ret := n.Value.(*parser.ReturnBlock)
			ret.Check(c.Parser)
			code += c.Arch.Return(ret)
		case *parser.VarBlock:
			varBlock := n.Value.(*parser.VarBlock)
			varBlock.Check(c.Parser)
			if varBlock.IsDefine {
				c.EspOffset -= varBlock.Type.Size()
				varBlock.Offset = c.EspOffset
				addr := ""
				if varBlock.Offset < 0 {
					addr = "[ebp" + strconv.FormatInt(int64(varBlock.Offset), 10) + "]"
				} else if varBlock.Offset == 0 {
					addr = "[ebp]"
				} else {
					addr = "[ebp+" + strconv.FormatInt(int64(varBlock.Offset), 10) + "]"
				}

				// 使用DWORD或QWORD前缀
				// 在x86 32位平台，i32及以下类型使用DWORD（4字节）
				sizePrefix := utils.GetLengthName(varBlock.Type.Size())
				code += c.Arch.Exp(varBlock.Value, sizePrefix+addr, "设置变量"+varBlock.Name)
			} else {
				switch varBlock.Define.Value.(type) {
				case *parser.VarBlock:
					varBlock.Offset = varBlock.Define.Value.(*parser.VarBlock).Offset
				case *parser.ArgBlock:
					varBlock.Offset = varBlock.Define.Value.(*parser.ArgBlock).Offset
				}
				addr := ""
				if varBlock.Offset < 0 {
					addr = "[ebp" + strconv.FormatInt(int64(varBlock.Offset), 10) + "]"
				} else if varBlock.Offset == 0 {
					addr = "[ebp]"
				} else {
					addr = "[ebp+" + strconv.FormatInt(int64(varBlock.Offset), 10) + "]"
				}
				// 使用DWORD或QWORD前缀
				sizePrefix := utils.GetLengthName(varBlock.Type.Size())
				code += c.Arch.Exp(varBlock.Value, sizePrefix+addr, "设置变量"+varBlock.Name)
			}
		case *parser.CallBlock:
			callBlock := n.Value.(*parser.CallBlock)
			callBlock.Check(c.Parser) // parser
			code += c.Arch.Call(callBlock)
		case *parser.Build:
			code += c.CompileBuild(n)
		}
	}
	switch node.Value.(type) {
	case *parser.FuncBlock:
		// 若最后不是显式 return，则补齐尾部清理
		if _, ok := node.Children[len(node.Children)-1].Value.(*parser.ReturnBlock); !ok {
			code += c.Arch.Return(nil)
		}
		if utils.Count > 0 {
			utils.Count--
		}
		code += utils.Format("; ======函数完毕=======\n\n")

		// 清理寄存器记录
		c.Reg.Record = map[*parser.Expression]*regmgr.Reg{}
		c.Reg.RegisterCount = 0
	}
	if node.Father == nil {
		// 检查是否有main函数
		hasMain := false
		for _, ch := range node.Children {
			if fb, ok := ch.Value.(*parser.FuncBlock); ok {
				if fb.Name == "main" {
					hasMain = true
					break
				}
			}
		}

		if hasMain {
			// 生成_start入口点，调用main函数后使用系统调用退出
			code += utils.Format("; ==============================")
			code += utils.Format("; 程序入口点 (ELF入口)")
			code += utils.Format("_start:")
			utils.Count++
			code += utils.Format("; 调用main函数")
			code += utils.Format("call main")
			code += utils.Format("; 使用系统调用退出程序 (sys_exit = 1)")
			code += utils.Format("; 返回值在EAX中")
			code += utils.Format("mov ebx, eax; 返回码")
			code += utils.Format("mov eax, 1; sys_exit")
			code += utils.Format("int 0x80; 调用内核\n")
		} else {
			//code += utils.Format("\n\nmain:\nPRINT_STRING \"MyLang First Finish!\"\nret\n")
		}
	}
	return code
}
