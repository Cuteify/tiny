package compile

import (
	"cuteify/parser"
	typeSys "cuteify/type"
	"strconv"
)

const (
	NumExp  = 1
	BoolExp = 2
	AndExp  = 3
	OrExp   = 4
	NotExp  = 5
)

func (c *Compiler) CompileExpr(exp *parser.Expression, result, desc string) (code string) {
	c.ExpCount++
	if exp != nil && exp.Father == nil && exp.IsConst() {
		tmp, resultVal := c.CompileExprVal(exp)
		code += tmp
		if result == "push" {
			code += Format("push " + resultVal + "; " + desc)
			return
		}
		code += Format("mov " + result + ", " + resultVal + "; " + desc)
		return
	}
	if exp == nil || exp.IsConst() || exp.Right == nil && exp.Left == nil {
		return
	}
	leftCode, leftResult := c.CompileExprVal(exp.Left)
	rightCode, rightResult := c.CompileExprVal(exp.Right)
	var leftReg *Reg
	var rightReg *Reg
	if exp.Left != nil && !exp.Left.IsConst() {
		if exp.Type.Type() == "bool" {
			leftReg = c.Reg.GetRegister(strconv.Itoa(c.ExpCount) + "boolResult1")
			leftResult = leftReg.RegName
			if leftReg.BeforeCode != "" {
				code += Format(leftReg.BeforeCode)
			}
		}
		leftCode = c.CompileExpr(exp.Left, leftResult, desc)
	}
	if exp.Right != nil && !exp.Right.IsConst() {
		if exp.Type.Type() == "bool" {
			rightReg = c.Reg.GetRegister(strconv.Itoa(c.ExpCount) + "boolResult2")
			rightResult = rightReg.RegName
			if rightReg.BeforeCode != "" {
				code += Format(rightReg.BeforeCode)
			}
		}
		rightCode = c.CompileExpr(exp.Right, rightResult, desc)
	}
	code += leftCode
	code += rightCode
	if exp.Left != nil && exp.Right != nil {
		if exp.Type.Type() == "bool" {
			code += Format("cmp " + leftResult + ", " + rightResult + "; 比较表达式的值")
			if c.ExpType == OrExp {

			} else if c.ExpType == AndExp {

			} else {
				switch exp.Separator {
				case "==":
					code += Format("jne " + result + "; 判断后跳转到目标")
				case "!=":
					code += Format("je " + result + "; 判断后跳转到目标")
				case "<":
					code += Format("jng " + result + "; 判断后跳转到目标")
				case ">":
					code += Format("jnl " + result + "; 判断后跳转到目标")
				case "<=":
					code += Format("jg " + result + "; 判断后跳转到目标")
				case ">=":
					code += Format("jl " + result + "; 判断后跳转到目标")
				}
			}
		} else {
			reg := c.Reg.GetRegister("exp" + strconv.Itoa(c.ExpCount))
			c.ExpCount++
			if reg.BeforeCode != "" {
				code += Format(reg.BeforeCode)
			}
			switch exp.Separator {
			case "+":
				code += Format("mov " + reg.RegName + ", " + leftResult + "; 保存表达式左边的值")
				code += Format("add " + reg.RegName + ", " + rightResult + "; 计算表达式的值")
			case "-":
				code += Format("mov " + reg.RegName + ", " + leftResult + "; 保存表达式左边的值")
				code += Format("sub " + reg.RegName + ", " + rightResult + "; 计算表达式的值")
			case "*":
				code += Format("mov " + reg.RegName + ", " + leftResult + "; 保存表达式左边的值")
				code += Format("imul " + reg.RegName + ", " + rightResult + "; 计算表达式的值")
			case "/":
				code += Format("mov " + reg.RegName + ", " + leftResult + "; 保存表达式左边的值")
				code += Format("idiv " + reg.RegName + ", " + rightResult + "; 计算表达式的值")
			case "%": // 取模运算
				code += Format("mov " + reg.RegName + ", " + leftResult + "; 保存表达式左边的值")
				code += Format("idiv " + reg.RegName + ", " + rightResult + "; 计算表达式的值")
			}
			if result == reg.RegName {
				resultReg := c.Reg.GetRegister("expResult")
				if resultReg.BeforeCode != "" {
					code += Format(resultReg.BeforeCode)
				}
				code += Format("mov " + resultReg.RegName + ", " + reg.RegName + "; 暂存表达式的值")
				if reg.AfterCode != "" {
					code += Format(resultReg.AfterCode)
				}
				code += Format("mov " + result + ", " + resultReg.RegName + "; " + desc)
				if resultReg.AfterCode != "" {
					code += Format(resultReg.AfterCode)
				}
				c.Reg.FreeRegister("expResult")
			} else {
				code += Format("mov " + result + ", " + reg.RegName + "; " + desc)
				if reg.AfterCode != "" {
					code += Format(reg.AfterCode)
				}
			}
			c.Reg.FreeRegister("exp" + strconv.Itoa(c.ExpCount-1))
		}
	}
	if leftReg != nil {
		if leftReg.AfterCode != "" {
			code += Format(leftReg.AfterCode)
		}
		c.Reg.FreeRegister(leftReg.Name)
	}
	if rightReg != nil {
		if rightReg.AfterCode != "" {
			code += Format(rightReg.AfterCode)
		}
		c.Reg.FreeRegister(rightReg.Name)
	}
	return
}

func (c *Compiler) CompileExprVal(exp *parser.Expression) (code, result string) {
	if exp.IsConst() {
		if typeSys.CheckTypeType(exp.Type, "int", "float", "uint") {
			result = strconv.FormatFloat(exp.Num, 'f', -1, 64)
		} else if typeSys.CheckTypeType(exp.Type, "bool") {
			if exp.Bool == true {
				result = "1"
			} else {
				result = "0"
			}
		}
	} else if exp.Var != nil {
		switch exp.Var.Define.Value.(type) {
		case *parser.VarBlock:
			exp.Var.Offset = exp.Var.Define.Value.(*parser.VarBlock).Offset
		case *parser.ArgBlock:
			exp.Var.Offset = exp.Var.Define.Value.(*parser.ArgBlock).Offset
		}
		addr := ""
		if exp.Var.Offset < 0 {
			addr = "[ebp" + strconv.FormatInt(int64(exp.Var.Offset), 10) + "]"
		} else {
			addr = "[ebp+" + strconv.FormatInt(int64(exp.Var.Offset), 10) + "]"
		}
		result = getLengthName(exp.Var.Type.Size()) + addr
	} else if exp.Call != nil {

	}
	return
}
