package compile

import (
	"future/parser"
	"strconv"
)

const (
	NumExp = 1
	BoolExp = 2
	AndExp = 3
	OrExp = 4
	NotExp = 5
)

func (c *Compiler) CompileExpr(exp *parser.Expression, result string) (code string) {
	c.ExpCount++
    leftResult, rightResult := result, result
	if exp.Left != nil && !exp.Left.IsConst() {
		var leftReg *Reg
		if exp.Type.Type() == "bool" {
			leftReg = c.Reg.GetRegister(strconv.Itoa(c.ExpCount)+"boolResult1")
			leftResult = leftReg.RegName
			if leftReg.BeforeCode != "" {
				code += Format(leftReg.BeforeCode)
			}
		}
		code += c.CompileExpr(exp, leftResult)
		if leftReg != nil {
			if leftReg.AfterCode != "" {
				code += Format(leftReg.AfterCode)
			}
			c.Reg.FreeRegister(leftReg.RegName)
		}
	}
	if exp.Right != nil && !exp.Right.IsConst() {
		var rightReg *Reg
		if exp.Type.Type() == "bool" {
			rightReg = c.Reg.GetRegister(strconv.Itoa(c.ExpCount)+"boolResult2")
			rightResult = rightReg.RegName
			if rightReg.BeforeCode != "" {
				code += Format(rightReg.BeforeCode)
			}
		}
		code += c.CompileExpr(exp, rightResult)
		if rightReg != nil {
			if rightReg.AfterCode != "" {
				code += Format(rightReg.AfterCode)
			}
			c.Reg.FreeRegister(rightReg.RegName)
		}
	}
	if exp.Left != nil && exp.Right != nil {
		if exp.Type.Type() == "bool" {
			code += Format("\033[35mcmp\033[0m " + result + ", 0\033[32m; 比较表达式的值\n")
			if c.ExpType == BoolExp {
				switch exp.Separator {
					case "==":
						code += Format("\033[35mje\033[0m " + result + "\033[32m; 判断后跳转到目标\n")
					case "!=":
						code += Format("\033[35mjne\033[0m " + result + "\033[32m; 判断后跳转到目标\n")
					case "<":
					    code += Format("\033[35mjl\033[0m " + result + "\033[32m; 判断后跳转到目标\n")
					case ">":
					    code += Format("\033[35mjg\033[0m " + result + "\033[32m; 判断后跳转到目标\n")
					case "<=":
						code += Format("\033[35mjl\033[0m " + result + "\033[32m; 判断后跳转到目标\n")
					case ">=":
						code += Format("\033[35mjg\033[0m " + result + "\033[32m; 判断后跳转到目标\n")
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
	/*
	if len(exp.Children) == 1 && exp.Children[0].IsConst() {
		if typeSys.CheckTypeType(exp.Children[0].Type, "int", "float", "uint") {
			code += Format("\033[35mmov\033[0m \033[34m" + result + ", " + strconv.FormatFloat(exp.Children[0].Num, 'f', -1, 64) + "\033[0m\033[32m; 修改局部变量\n")
		} else if typeSys.CheckTypeType(exp.Children[0].Type, "bool") {
			if exp.Children[0].Bool == true {
				code += Format("\033[35mmov\033[0m \033[34m" + result + "\033[0m, 1\033[0m\033[32m; 修改局部变量\n")
			} else {
				code += Format("\033[35mmov\033[0m \033[34m" + result + "\033[0m, 0\033[0m\033[32m; 修改局部变量\n")
			}
		}
	} else {
		
	}*/
	return
}