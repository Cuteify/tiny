package x86

import (
	"cuteify/compile/arch"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"fmt"
	"strconv"
)

// 表达式类型常量定义
const (
	NumExp  = 1 // 数值表达式
	BoolExp = 2 // 布尔表达式
	AndExp  = 3 // 逻辑与表达式
	OrExp   = 4 // 逻辑或表达式
	NotExp  = 5 // 逻辑非表达式
)

type expCom struct {
	regmgr  *regmgr.RegMgr
	expType int
	now     *parser.Node // 当前节点，指向正在编译的AST节点
	arch    arch.Arch
}

func (c *expCom) CompileExpr(exp *parser.Expression, result, desc string) (code string) {
	if exp.Type.Type() == "bool" {
		return c.CompileBoolExpr(exp, result)
	}
	var reg *regmgr.Reg
	code, reg = c.CompileExprChildren(exp)
	if reg != nil {
		if result == "push" {
			code += utils.Format("push " + reg.Name + "; " + desc)
		} else {
			code += utils.Format("mov " + result + ", " + reg.Name + "; " + desc)
		}
	}
	return
}

func (c *expCom) CompileExprChildren(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	// 末端子节点处理，递归终止
	if exp.Separator == "" && !exp.IsConst() {
		tmp, resultVal := c.CompileExprVal(exp)
		code += tmp
		reg = c.regmgr.Get(c.now, exp, false)
		if reg.StoreCode != "" {
			code += reg.StoreCode
		}
		fmt.Println(exp, resultVal)
		code += utils.Format("mov " + reg.Name + ", " + resultVal + "; 临时存储内存数据")
		return
	}

	// 处理子节点
	var leftReg *regmgr.Reg
	var rightReg *regmgr.Reg
	var leftCode, leftResult string
	var rightCode, rightResult string

	// 左子
	if exp.Left != nil {
		if exp.Left.IsConst() {
			leftCode, leftResult = c.CompileExprVal(exp.Left)
		} else if exp.Left.Separator == "" && !exp.Right.IsConst() {
			leftCode, leftResult = c.CompileExprVal(exp.Left)
		} else {
			leftCode, leftReg = c.CompileExprChildren(exp.Left)
			leftResult = leftReg.Name
		}
	}
	//fmt.Println("L", exp.Left, leftCode)
	code += leftCode

	// 右子
	if exp.Right != nil {
		if exp.Right.IsConst() {
			rightCode, rightResult = c.CompileExprVal(exp.Right)
		} else if exp.Right.Separator == "" && leftReg != nil {
			rightCode, rightResult = c.CompileExprVal(exp.Right)
		} else {
			rightCode, rightReg = c.CompileExprChildren(exp.Right)
			rightResult = rightReg.Name
		}
	}
	//fmt.Println("R", exp.Right, rightCode)
	code += rightCode

	// 节点处理
	if exp.Separator != "" {
		// 设置使用的中间寄存器
		var src string
		if leftReg != nil {
			reg = leftReg
			src = rightResult
			if rightReg != nil {
				c.regmgr.Free(exp.Right) // 实际上是计算结束时才释放，但这里的计算过程不会分配新的寄存器
			}
		} else if rightReg != nil {
			reg = rightReg
			src = leftResult
			if leftReg != nil {
				c.regmgr.Free(exp.Left) // 实际上是计算结束时才释放，但这里的计算过程不会分配新的寄存器
			}
		} else {
			reg = c.regmgr.Get(c.now, exp, false)
			if reg.StoreCode != "" {
				code += utils.Format(reg.StoreCode)
			}
			code += utils.Format("mov " + reg.Name + ", " + leftResult + "; 临时存储常量数据")
			src = rightResult
		}

		// 计算
		switch exp.Separator {
		case "+":
			code += utils.Format("add " + reg.Name + ", " + src + "; 计算表达式的值")
		case "-":
			code += utils.Format("sub " + reg.Name + ", " + src + "; 计算表达式的值")
		case "*":
			code += utils.Format("imul " + reg.Name + ", " + src + "; 计算表达式的值")
		case "/":
			code += utils.Format("idiv " + reg.Name + ", " + src + "; 计算表达式的值")
		case "%":
			code += utils.Format("idiv " + reg.Name + ", " + src + "; 计算表达式的值")
		}
	}

	return
}

func (c *expCom) CompileBoolExpr(exp *parser.Expression, result string) (code string) {
	var leftReg *regmgr.Reg
	var rightReg *regmgr.Reg
	var leftCode, leftResult string
	var rightCode, rightResult string
	if exp.Type.Type() == "bool" {
		// 左子
		if exp.Left != nil {
			if exp.Left.IsConst() {
				leftCode, leftResult = c.CompileExprVal(exp.Left)
			} else {
				leftCode, leftReg = c.CompileExprChildren(exp.Left)
				leftResult = leftReg.Name
			}
		}
		//fmt.Println("L", exp.Left, leftCode)
		code += leftCode

		// 右子
		if exp.Right != nil {
			if exp.Right.IsConst() {
				rightCode, rightResult = c.CompileExprVal(exp.Right)
			} else {
				rightCode, rightReg = c.CompileExprChildren(exp.Right)
				rightResult = rightReg.Name
			}
		}
		//fmt.Println("R", exp.Right, rightCode)
		code += rightCode

		// 生成代码
		code += utils.Format("cmp " + leftResult + ", " + rightResult + "; 比较表达式的值")
		// 释放寄存器
		c.regmgr.Free(exp.Left)
		c.regmgr.Free(exp.Right)
		switch c.expType {
		case OrExp:
		case AndExp:
		default:
			switch exp.Separator {
			case "==":
				code += utils.Format("jne " + result + "; 判断后跳转到目标")
			case "!=":
				code += utils.Format("je " + result + "; 判断后跳转到目标")
			case "<":
				code += utils.Format("jl " + result + "; 判断后跳转到目标")
			case ">":
				code += utils.Format("jg " + result + "; 判断后跳转到目标")
			case "<=":
				code += utils.Format("jle " + result + "; 判断后跳转到目标")
			case ">=":
				code += utils.Format("jge " + result + "; 判断后跳转到目标")
			}
		}
	}

	return
}

func (c *expCom) CompileExprVal(exp *parser.Expression) (code, result string) {
	// 如果是常量表达式
	if exp.IsConst() {
		// 根据类型生成对应的值表示
		if typeSys.CheckTypeType(exp.Type, "int", "float", "uint") {
			result = strconv.FormatFloat(exp.Num, 'f', -1, 64)
		} else if typeSys.CheckTypeType(exp.Type, "bool") {
			if exp.Bool {
				result = "1"
			} else {
				result = "0"
			}
		}
	} else if exp.Var != nil {
		// 如果是变量表达式，计算变量在栈中的偏移量
		switch exp.Var.Define.Value.(type) {
		case *parser.VarBlock:
			exp.Var.Offset = exp.Var.Define.Value.(*parser.VarBlock).Offset
		case *parser.ArgBlock:
			exp.Var.Offset = exp.Var.Define.Value.(*parser.ArgBlock).Offset
		}

		if rInfo := c.regmgr.Reuse(exp.Var.Define); rInfo != nil {
			result = rInfo.Name
		} else {
			// 根据偏移量生成内存地址
			addr := ""
			if exp.Var.Offset < 0 {
				addr = "[ebp" + strconv.FormatInt(int64(exp.Var.Offset), 10) + "]"
			} else if exp.Var.Offset == 0 {
				addr = "[ebp]"
			} else {
				addr = "[ebp+" + strconv.FormatInt(int64(exp.Var.Offset), 10) + "]"
			}
			// 生成带长度前缀的内存地址（如 DWORD[ebp-4]）
			result = utils.GetLengthName(exp.Var.Type.Size()) + addr
		}
	} else if exp.Call != nil {
		code = c.arch.Call(exp.Call)
		//c.regmgr.Force(&regmgr.Reg{Name: "EAX"}, c.now, exp)
		result = "EAX"
	}
	return
}
