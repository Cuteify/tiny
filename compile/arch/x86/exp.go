package x86

import (
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
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
	ctx           *context.Context
	varWithSetVal bool
}

func (c *expCom) CompileExpr(exp *parser.Expression, result, desc string) (code string) {
	if exp.Type == nil {
		panic("Expression Type is nil: " + desc)
	}

	if exp.Type.Type() == "bool" {
		return c.CompileBoolExpr(exp, result)
	}
	if tmp := c.numConstHandle(exp, result, desc); tmp != "" {
		code = tmp
		return
	}

	var reg *regmgr.Reg
	code, reg = c.CompileExprChildren(exp)

	// 保存结果
	if reg != nil && !c.varWithSetVal {
		if result == "push" {
			code += utils.Format("push " + reg.Name + "; " + desc)
			// push后立即释放寄存器，避免被SaveAll溢出
			c.ctx.Reg.Free(exp)
		} else {
			if result != reg.Name {
				code += utils.Format("mov " + result + ", " + reg.Name + "; " + desc)
				c.ctx.Reg.Free(exp)
			} else {
				code = code[:len(code)-1] // 去除原先的换行
				code += "; " + desc + "\n"
			}
		}
	}
	return
}

func (c *expCom) CompileExprChildren(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	//末端子节点处理，递归终止
	if exp.Separator == "" {
		return c.compileLeafNode(exp)
	}

	// 处理二元运算
	return c.compileBinaryOp(exp)
}

func (c *expCom) numConstHandle(exp *parser.Expression, result, desc string) (code string) {
	if typeSys.CheckTypeType(exp.Type, "int", "uint") && exp.IsConst() {
		var tmp string
		code, tmp = c.CompileExprVal(exp)
		if result == "push" {
			code += utils.Format("push " + tmp + "; " + desc)
		} else {
			code += utils.Format("mov " + result + ", " + tmp + "; " + desc)
		}
		return
	}
	return ""
}

// 编译末端叶子节点（常量、变量、函数调用）
func (c *expCom) compileLeafNode(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	tmp, resultVal := c.CompileExprVal(exp)
	code += tmp
	reg = c.ctx.Reg.Get(c.ctx.Now, exp, false)

	if c.varWithSetVal {
		return
	}

	// 如果 EBX 已被占用（左子使用），重新分配到其他寄存器
	if c.ctx.EbxOccupied && reg != nil && reg.Name == "EBX" {
		c.ctx.Reg.Free(exp)
		reg = c.ctx.Reg.Get(c.ctx.Now, exp, false)
	}

	if reg.StoreCode != "" {
		code += reg.StoreCode
	}

	if reg.Name != resultVal {
		code += utils.Format("mov " + reg.Name + ", " + resultVal)
	}
	return
}

// 编译二元运算表达式
func (c *expCom) compileBinaryOp(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	var leftReg, rightReg *regmgr.Reg
	var leftResult string
	var rightResult string

	// 编译左子
	leftCode, leftReg, leftResult := c.compileLeftChild(exp)

	// 如果右子包含函数调用，左子需要保存到 EBX
	if c.needSaveLeftToEBX(exp, leftReg) {
		code += leftCode
		code += c.saveLeftToEBX(exp.Left, leftReg, leftResult)
		leftResult = "EBX"
		leftReg = nil
	} else {
		code = leftCode
	}

	// 编译右子
	rightCode, rightReg, rightResult := c.compileRightChild(exp, leftResult)
	code += rightCode

	// 生成运算代码
	if exp.Separator != "" {
		if leftResult == "EBX" && leftReg == nil {
			code = c.generateOpWithEBX(code, exp, rightResult, rightReg, exp.Left)
			reg = &regmgr.Reg{Name: "EBX"}
		} else {
			code, reg = c.generateOpNormal(code, exp, leftReg, rightReg, leftResult, rightResult)
		}
	}

	return code, reg
}

// 编译左子表达式
func (c *expCom) compileLeftChild(exp *parser.Expression) (code string, reg *regmgr.Reg, result string) {
	if exp.Left == nil {
		return
	}

	// 优化：如果左子是函数调用且右子也有函数调用，直接把返回值移到 EBX
	if exp.Left.Call != nil && exp.Right != nil && c.containsCall(exp.Right) {
		c.ctx.UseEBXDirect = true
		code, result = c.CompileExprVal(exp.Left)
		c.ctx.UseEBXDirect = false
		reg = nil

		// 锁定 EBX，防止被右子分配使用
		c.ctx.Reg.Force(&regmgr.Reg{Name: "EBX", RegIndex: 1}, c.ctx.Now, exp.Left)
		return
	}

	if exp.Left.IsConst() {
		code, result = c.CompileExprVal(exp.Left)
	} else {
		code, reg = c.CompileExprChildren(exp.Left)
		result = reg.Name
	}
	return
}

// 编译右子表达式
func (c *expCom) compileRightChild(exp *parser.Expression, leftResult string) (code string, reg *regmgr.Reg, result string) {
	if exp.Right == nil {
		return
	}

	// 如果左子结果在 EBX 中，设置标志防止右子使用 EBX
	if leftResult == "EBX" {
		c.ctx.EbxOccupied = true
	}
	defer func() { c.ctx.EbxOccupied = false }()

	if exp.Right.IsConst() {
		code, result = c.CompileExprVal(exp.Right)
	} else if exp.Right.Call != nil {
		// 右子是函数调用，返回值在 EAX
		code, result = c.CompileExprVal(exp.Right)
	} else {
		code, reg = c.CompileExprChildren(exp.Right)
		if reg != nil {
			result = reg.Name
		}
	}
	return
}

// 判断是否需要将左子结果保存到 EBX
func (c *expCom) needSaveLeftToEBX(exp *parser.Expression, leftReg *regmgr.Reg) bool {
	if exp.Right == nil {
		return false
	}
	if !c.containsCall(exp.Right) {
		return false
	}
	// 左子不是函数调用，需要保存
	return exp.Left == nil || exp.Left.Call == nil
}

// 将左子结果保存到 EBX
func (c *expCom) saveLeftToEBX(leftExp *parser.Expression, leftReg *regmgr.Reg, leftResult string) string {
	code := ""
	// 释放左子寄存器（如果有的话）
	if leftReg != nil {
		c.ctx.Reg.Free(leftExp)
	}
	code += utils.Format("mov EBX, " + leftResult + "; 保存中间结果到EBX(callee-save)")
	return code
}

// 使用 EBX 作为目标生成运算代码
func (c *expCom) generateOpWithEBX(code string, exp *parser.Expression, rightResult string, rightReg *regmgr.Reg, leftExp *parser.Expression) string {
	// 释放右子寄存器
	if rightReg != nil {
		c.ctx.Reg.Free(exp.Right)
	}

	formattedSrc := rightResult

	switch exp.Separator {
	case "+":
		code += utils.Format("add EBX, " + formattedSrc + "; EBX = fib(i-1) + fib(i-2)")
	case "-":
		code += utils.Format("sub EBX, " + formattedSrc)
	case "*":
		code += utils.Format("imul EBX, " + formattedSrc)
	case "/":
		code += utils.Format("xor edx, edx")
		code += utils.Format("mov eax, EBX")
		code += utils.Format("idiv " + formattedSrc)
		code += utils.Format("mov EBX, eax")
	case "%":
		code += utils.Format("xor edx, edx")
		code += utils.Format("mov eax, EBX")
		code += utils.Format("idiv " + formattedSrc)
		code += utils.Format("mov EBX, edx")
	}

	// 解锁 EBX
	c.ctx.Reg.Free(leftExp)

	return code
}

// 正常生成运算代码
func (c *expCom) generateOpNormal(code string, exp *parser.Expression, leftReg, rightReg *regmgr.Reg, leftResult, rightResult string) (string, *regmgr.Reg) {
	reg, src := c.selectResultReg(leftReg, rightReg, leftResult, rightResult, exp)

	if reg == nil {
		reg = c.ctx.Reg.Get(c.ctx.Now, exp, false)
		if reg.StoreCode != "" {
			code += utils.Format(reg.StoreCode)
		}
		formattedLeft := leftResult
		code += utils.Format("mov " + reg.Name + ", " + formattedLeft)
	}

	formattedSrc := src
	code += c.emitOpInstruction(reg.Name, exp.Separator, formattedSrc)

	return code, reg
}

// 选择结果寄存器和源操作数
func (c *expCom) selectResultReg(leftReg, rightReg *regmgr.Reg, leftResult, rightResult string, exp *parser.Expression) (*regmgr.Reg, string) {
	if leftReg != nil {
		if rightReg != nil {
			c.ctx.Reg.Free(exp.Right)
		}
		return leftReg, rightResult
	}
	if rightReg != nil {
		if leftReg != nil {
			c.ctx.Reg.Free(exp.Left)
		}
		return rightReg, leftResult
	}
	return nil, rightResult
}

// 发出运算指令
func (c *expCom) emitOpInstruction(regName, op, src string) string {
	switch op {
	case "+":
		return utils.Format("add " + regName + ", " + src)
	case "-":
		return utils.Format("sub " + regName + ", " + src)
	case "*":
		return utils.Format("imul " + regName + ", " + src)
	case "/":
		return utils.Format("xor edx, edx") +
			utils.Format("mov eax, "+regName) +
			utils.Format("idiv "+src) +
			utils.Format("mov "+regName+", eax")
	case "%":
		return utils.Format("xor edx, edx") +
			utils.Format("mov eax, "+regName) +
			utils.Format("idiv "+src) +
			utils.Format("mov "+regName+", edx")
	default:
		return ""
	}
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
		code += rightCode

		// 生成代码
		formattedLeft := leftResult
		formattedRight := rightResult
		code += utils.Format("cmp " + formattedLeft + ", " + formattedRight)
		// 释放寄存器
		if exp.Left != nil {
			c.ctx.Reg.Free(exp.Left)
		}
		if exp.Right != nil {
			c.ctx.Reg.Free(exp.Right)
		}
		switch c.ctx.ExpType {
		case OrExp:
		case AndExp:
		default:
			switch exp.Separator {
			case "==":
				code += utils.Format("jne " + result + "; 判断后跳转到目标")
			case "!=":
				code += utils.Format("je " + result + "; 判断后跳转到目标")
			case "<":
				code += utils.Format("jnl " + result + "; 判断后跳转到目标")
			case ">":
				code += utils.Format("jle " + result + "; 判断后跳转到目标")
			case "<=":
				code += utils.Format("jg " + result + "; 判断后跳转到目标")
			case ">=":
				code += utils.Format("jl " + result + "; 判断后跳转到目标")
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
		if exp.Var.Value != nil {
			code = c.ctx.Arch.Var(exp.Var)
			c.varWithSetVal = true
			return
		}
		// 如果是变量表达式，计算变量在栈中的偏移量
		if rInfo := c.ctx.Reg.Reuse(exp.Var.Define); rInfo != nil {
			result = rInfo.Name
		} else {
			result = genVarAddr(c.ctx, exp.Var)
		}
	} else if exp.Call != nil {
		code = c.ctx.Arch.Call(exp.Call)
		result = "EAX"
		// 如果标记为直接使用 EBX，生成 mov EBX, EAX
		if c.ctx.UseEBXDirect {
			code += utils.Format("mov EBX, EAX; 函数返回值直接移到EBX")
			result = "EBX"
		}
	}
	return
}

// containsCall 检查表达式或其子表达式中是否包含函数调用
func (c *expCom) containsCall(exp *parser.Expression) bool {
	if exp == nil {
		return false
	}
	if exp.Call != nil {
		return true
	}
	return c.containsCall(exp.Left) || c.containsCall(exp.Right)
}
