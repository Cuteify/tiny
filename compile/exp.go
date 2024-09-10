package compile

import (
	"future/parser"
	typeSys "future/type"
	"strconv"
)

func (c *Compiler) CompileExpr(exp *parser.Expression, result string) (code string) {
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
		reg := c.Reg.GetRegister("exp" + strconv.Itoa(c.ExpCount))
		c.ExpCount++
		if reg.BeforeCode != "" {
			code += Format(reg.BeforeCode)
		}
		for i := 0; i < len(exp.Children); i++ {
			child := exp.Children[i]
			before1 := &parser.Expression{}
			before2 := &parser.Expression{}
			before1Code, before2Code := "", ""
			before1Result, before2Result := "", ""
			if child.Separator != "" {
				before1 = exp.Children[i-2]
				before2 = exp.Children[i-1]
				before1Code, before1Result = c.CompileExprVal(before1)
				before2Code, before2Result = c.CompileExprVal(before2)
				code += before1Code
				code += before2Code
			}
			switch exp.Children[i].Separator {
			case "+":
				code += Format("\033[35mmov\033[0m \033[34m" + reg.RegName + "\033[0m, " + before1Result + "\033[32m; 保存表达式左边的值\n")
				code += Format("\033[35madd\033[0m \033[34m" + reg.RegName + "\033[0m, " + before2Result + "\033[32m; 计算表达式的值\n")
			case "-":
				code += Format("\033[35mmov\033[0m \033[34m" + reg.RegName + "\033[0m, " + before1Result + "\033[32m; 保存表达式左边的值\n")
				code += Format("\033[35msub\033[0m \033[34m" + reg.RegName + "\033[0m, " + before2Result + "\033[32m; 计算表达式的值\n")
			case "*":
				code += Format("\033[35mmov\033[0m \033[34m" + reg.RegName + "\033[0m, " + before1Result + "\033[32m; 保存表达式左边的值\n")
				code += Format("\033[35imul\033[0m \033[34m" + reg.RegName + "\033[0m, " + before2Result + "\033[32m; 计算表达式的值\n")
			case "/":
				code += Format("\033[35mmov\033[0m \033[34m" + reg.RegName + "\033[0m, " + before1Result + "\033[32m; 保存表达式左边的值\n")
				code += Format("\033[35idiv\033[0m \033[34m" + reg.RegName + "\033[0m, " + before2Result + "\033[32m; 计算表达式的值\n")
			case ">":
				code += Format("\033[35mcmp\033[0m " + before1Result + ", " + before2Result + "\033[32m; 比较表达式的值\n")
				code += Format("\033[35msetg\033[0m \033[34m" + reg.RegName + "\033[0m\033[32m; 保存比较结果\n")
			}
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
