package x86

/*
func (c *expCom) CompileExpr(exp *parser.Expression, result, desc string) (code string) {
	if exp != nil && exp.Father == nil && exp.IsConst() {
		tmp, resultVal := c.CompileExprVal(exp)
		code += tmp
		if result == "push" {
			code += utils.Format("push " + resultVal + "; " + desc)
			return
		}
		code += utils.Format("mov " + result + ", " + resultVal + "; " + desc)
		return
	}

	if exp.Right == nil && exp.Left == nil && exp.Separator == "" && exp.Var != nil {
		tmp, resultVal := c.CompileExprVal(exp)
		code += tmp
		return utils.Format("mov " + result + ", " + resultVal + "; 复制内存到寄存器")
	}

	if exp == nil || exp.IsConst() || exp.Right == nil && exp.Left == nil {
		return
	}

	leftCode, leftResult := c.CompileExprVal(exp.Left)
	rightCode, rightResult := c.CompileExprVal(exp.Right)
	/*fmt.Println(exp)
	fmt.Println("C: \n", leftCode, "\nR: ", leftResult)
	fmt.Println(strings.Repeat("=", 5))
	fmt.Println("C: \n", rightCode, "\nR: ", rightResult)
	fmt.Println(strings.Repeat("-", 10))*/
/*fmt.Println(result, "\t\t", c.regmgr.Record)
var leftReg *regmgr.Reg
var rightReg *regmgr.Reg

if exp.Left != nil && !exp.Left.IsConst() {
	if exp.Left.Var != nil {
		leftReg = c.regmgr.Reuse(exp.Left.Var.Define)
	}
	if leftReg == nil {
		if exp.Left.Type.Type() != "bool" {
			leftReg = c.regmgr.Get(c.now, exp.Left, false)
			leftResult = leftReg.Name
			if leftReg.StoreCode != "" {
				code += utils.Format(leftReg.StoreCode)
			}
		}
		leftCode = c.CompileExpr(exp.Left, leftResult, desc)
	}
}

if exp.Right != nil && !exp.Right.IsConst() {
	if exp.Right.Var != nil {
		rightReg = c.regmgr.Reuse(exp.Right.Var.Define)
	}
	if rightReg == nil {
		if exp.Right.Type.Type() != "bool" {
			rightReg = c.regmgr.Get(c.now, exp.Left, false)
			rightResult = rightReg.Name
			if rightReg.StoreCode != "" {
				code += utils.Format(rightReg.StoreCode)
			}
		}
		rightCode = c.CompileExpr(exp.Right, rightResult, desc)
	}
}

//fmt.Println("hiihhi", exp, leftCode, rightCode)

code += leftCode
code += rightCode

if exp.Left != nil && exp.Right != nil {
	if exp.Type.Type() == "bool" {
		code += utils.Format("cmp " + leftResult + ", " + rightResult + "; 比较表达式的值")
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
	} else {
		var reg *regmgr.Reg
		if leftReg == nil && rightReg == nil {
			reg = c.regmgr.Get(c.now, exp, false)
			if reg.StoreCode != "" {
				code += utils.Format(reg.StoreCode)
			}
			if result == "" {
				panic("没有指定结果寄存器")
			}
		} else if leftReg == nil {
			reg = rightReg
		} else {
			reg = leftReg
		}

		switch exp.Separator {
		case "+":
			code += utils.Format("add " + reg.Name + ", " + rightResult + "; 计算表达式的值")
		case "-":
			code += utils.Format("sub " + reg.Name + ", " + rightResult + "; 计算表达式的值")
		case "*":
			code += utils.Format("imul " + reg.Name + ", " + rightResult + "; 计算表达式的值")
		case "/":
			code += utils.Format("idiv " + reg.Name + ", " + rightResult + "; 计算表达式的值")
		case "%":
			code += utils.Format("idiv " + reg.Name + ", " + rightResult + "; 计算表达式的值")
		}
		c.regmgr.Free(exp)
	}
}

/*fmt.Println(exp)
fmt.Println(code)*/

/*c.regmgr.Free(exp.Left)
	c.regmgr.Free(exp.Right)
	return
}*/
