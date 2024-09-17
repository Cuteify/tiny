package compile

import (
	"future/parser"
	typeSys "future/type"
	"strconv"
)

const (
	NumExp  = 1
	BoolExp = 2
	AndExp  = 3
	OrExp   = 4
	NotExp  = 5
)

func (c *Compiler) CompileExpr(exp *parser.Expression, result string) (code string) {
	c.ExpCount++
	if exp != nil && exp.Father == nil && exp.IsConst() {
		tmp, resultVal := c.CompileExprVal(exp)
		code += tmp
		code += Format("\033[35mmov\033[0m \033[34m" + result + ", " + resultVal + "\033[32m; 修改局部变量\n")
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
		leftCode = c.CompileExpr(exp.Left, leftResult)
	}
	if exp.Right != nil && !exp.Right.IsConst() {
		if exp.Type.Type() == "bool" {
			rightReg = c.Reg.GetRegister(strconv.Itoa(c.ExpCount) + "boolResult2")
			rightResult = rightReg.RegName
			if rightReg.BeforeCode != "" {
				code += Format(rightReg.BeforeCode)
			}
		}
		rightCode = c.CompileExpr(exp.Right, rightResult)
	}
	code += leftCode
	code += rightCode
	if exp.Left != nil && exp.Right != nil {
		if exp.Type.Type() == "bool" {
			code += Format("\033[35mcmp\033[0m " + leftResult + ", " + rightResult + "\033[32m; 比较表达式的值\n")
			if c.ExpType == OrExp {

			} else if c.ExpType == AndExp {

			} else {
				switch exp.Separator {
				case "==":
					code += Format("\033[35mjne\033[0m " + result + "\033[32m; 判断后跳转到目标\n")
				case "!=":
					code += Format("\033[35mje\033[0m " + result + "\033[32m; 判断后跳转到目标\n")
				case "<":
					code += Format("\033[35mjng\033[0m " + result + "\033[32m; 判断后跳转到目标\n")
				case ">":
					code += Format("\033[35mjnl\033[0m " + result + "\033[32m; 判断后跳转到目标\n")
				case "<=":
					code += Format("\033[35mjg\033[0m " + result + "\033[32m; 判断后跳转到目标\n")
				case ">=":
					code += Format("\033[35mjl\033[0m " + result + "\033[32m; 判断后跳转到目标\n")
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
				code += Format("\033[35mmov\033[0m \033[34m" + reg.RegName + "\033[0m, " + leftResult + "\033[32m; 保存表达式左边的值\n")
				code += Format("\033[35madd\033[0m \033[34m" + reg.RegName + "\033[0m, " + rightResult + "\033[32m; 计算表达式的值\n")
			case "-":
				code += Format("\033[35mmov\033[0m \033[34m" + reg.RegName + "\033[0m, " + leftResult + "\033[32m; 保存表达式左边的值\n")
				code += Format("\033[35msub\033[0m \033[34m" + reg.RegName + "\033[0m, " + rightResult + "\033[32m; 计算表达式的值\n")
			case "*":
				code += Format("\033[35mmov\033[0m \033[34m" + reg.RegName + "\033[0m, " + leftResult + "\033[32m; 保存表达式左边的值\n")
				code += Format("\033[35imul\033[0m \033[34m" + reg.RegName + "\033[0m, " + rightResult + "\033[32m; 计算表达式的值\n")
			case "/":
				code += Format("\033[35mmov\033[0m \033[34m" + reg.RegName + "\033[0m, " + leftResult + "\033[32m; 保存表达式左边的值\n")
				code += Format("\033[35idiv\033[0m \033[34m" + reg.RegName + "\033[0m, " + rightResult + "\033[32m; 计算表达式的值\n")
			case "%": // 取模运算
				code += Format("\033[35mmov\033[0m \033[34m" + reg.RegName + "\033[0m, " + leftResult + "\033[32m; 保存表达式左边的值\n")
				code += Format("\033[35idiv\033[0m \033[34m" + reg.RegName + "\033[0m, " + rightResult + "\033[32m; 计算表达式的值\n")
			}
			if result == reg.RegName {
				resultReg := c.Reg.GetRegister("expResult")
				if resultReg.BeforeCode != "" {
					code += Format(resultReg.BeforeCode)
				}
				code += Format("\033[35mmov\033[0m \033[34m" + resultReg.RegName + "\033[0m, " + reg.RegName + "\033[32m; 暂存表达式的值\n")
				if reg.AfterCode != "" {
					code += Format(resultReg.AfterCode)
				}
				code += Format("\033[35mmov\033[0m " + result + ", " + resultReg.RegName + "\033[32m; 保存表达式的值\n")
				if resultReg.AfterCode != "" {
					code += Format(resultReg.AfterCode)
				}
				c.Reg.FreeRegister("expResult")
			} else {
				code += Format("\033[35mmov\033[0m " + result + ", " + reg.RegName + "\033[32m; 保存表达式的值\n")
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
		exp.Var.Offset = exp.Var.Define.Value.(*parser.VarBlock).Offset
		result = getLengthName(exp.Var.Type.Size()) + "[ebp" + strconv.FormatInt(int64(exp.Var.Offset), 10) + "]"
	} else if exp.Call != nil {

	}
	return
}
