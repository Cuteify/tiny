package x86

import (
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strconv"
	"strings"
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

	if tmp := c.builtinHandle(exp, result, desc); tmp != "" {
		code = tmp
		return
	}

	if exp.Type != nil && exp.Type.Kind() == "list" && result != "push" && !isRegName(result) {
		if baseOffset, ok := extractEbpOffset(result); ok {
			return c.compileListToAddr(exp, baseOffset, desc)
		}
	}

	if exp.Type.Type() == "bool" {
		return c.CompileBoolExpr(exp, result)
	}
	if tmp := c.numConstHandle(exp, result, desc); tmp != "" {
		code = tmp
		return
	}
	if tmp := c.strConstHandle(exp, result, desc); tmp != "" {
		code = tmp
		return
	}

	if is64Type(exp.Type) {
		return c.compileExpr64(exp, result, desc)
	}

	var reg *regmgr.Reg
	code, reg = c.CompileExprChildren(exp)

	if reg != nil && !c.varWithSetVal {
		if result == "push" {
			code += utils.Format("push " + reg.Name + "; " + desc)
			c.ctx.Reg.Free(exp)
		} else {
			if result != reg.Name {
				code += utils.Format("mov " + result + ", " + reg.Name + "; " + desc)
				c.ctx.Reg.Free(exp)
			} else {
				code = code[:len(code)-1]
				code += "; " + desc + "\n"
			}
		}
	}
	return
}

func (c *expCom) compileExpr64(exp *parser.Expression, result, desc string) (code string) {
	if exp.IsConst() && typeSys.CheckKind(exp.Type, "int", "uint", "i64", "u64") {
		val := strconv.FormatFloat(exp.Num, 'f', -1, 64)
		if result == "push" {
			code += utils.Format("push 0; high 32bit " + desc)
			code += utils.Format("push " + val + "; low 32bit " + desc)
		} else if isRegName(result) {
			code += utils.Format("mov " + result + ", " + val + "; " + desc)
		} else {
			loAddr := result
			hiAddr := c.makeHiAddr(result)
			code += utils.Format("mov dword " + loAddr + ", " + val + "; " + desc)
			code += utils.Format("mov dword " + hiAddr + ", 0")
		}
		return
	}

	if exp.Var != nil {
		loAddr := genLoAddr(c.ctx, exp.Var)
		hiAddr := genHiAddr(c.ctx, exp.Var)
		if result == "push" {
			code += utils.Format("push dword " + hiAddr + "; high 32bit " + desc)
			code += utils.Format("push dword " + loAddr + "; low 32bit " + desc)
		} else if isRegName(result) {
			code += utils.Format("mov " + result + ", dword " + loAddr + "; " + desc)
		} else {
			code += utils.Format("mov eax, dword " + loAddr)
			code += utils.Format("mov edx, dword " + hiAddr)
			dstLo := result
			dstHi := c.makeHiAddr(result)
			code += utils.Format("mov dword " + dstLo + ", eax; " + desc)
			code += utils.Format("mov dword " + dstHi + ", edx")
		}
		return
	}

	if exp.Call != nil {
		code += c.ctx.Arch.Call(exp.Call)
		if result == "push" {
			code += utils.Format("push edx; high 32bit " + desc)
			code += utils.Format("push eax; low 32bit " + desc)
		} else if isRegName(result) {
		} else {
			dstLo := result
			dstHi := c.makeHiAddr(result)
			code += utils.Format("mov dword " + dstLo + ", eax; " + desc)
			code += utils.Format("mov dword " + dstHi + ", edx")
		}
		return
	}

	if exp.Separator != "" {
		return c.compileBinOp64(exp, result, desc)
	}

	code += utils.Format("mov eax, 0; mov edx, 0; unknown 64bit " + desc)
	if result == "push" {
		code += utils.Format("push edx; high 32bit")
		code += utils.Format("push eax; low 32bit")
	} else if !isRegName(result) {
		dstLo := result
		dstHi := c.makeHiAddr(result)
		code += utils.Format("mov dword " + dstLo + ", eax")
		code += utils.Format("mov dword " + dstHi + ", edx")
	}
	return
}

func (c *expCom) compileBinOp64(exp *parser.Expression, result, desc string) (code string) {
	var leftLo, leftHi string
	var rightLo, rightHi string

	if exp.Left != nil {
		if exp.Left.IsConst() {
			leftLo = strconv.FormatFloat(exp.Left.Num, 'f', -1, 64)
			leftHi = "0"
		} else if exp.Left.Var != nil {
			leftLo = "dword " + genLoAddr(c.ctx, exp.Left.Var)
			leftHi = "dword " + genHiAddr(c.ctx, exp.Left.Var)
		} else {
			leftLo = "eax"
			leftHi = "edx"
			code += c.compileExpr64(exp.Left, "EDX:EAX", desc+" left")
		}
	}

	if exp.Right != nil {
		if exp.Right.IsConst() {
			rightLo = strconv.FormatFloat(exp.Right.Num, 'f', -1, 64)
			rightHi = "0"
		} else if exp.Right.Var != nil {
			rightLo = "dword " + genLoAddr(c.ctx, exp.Right.Var)
			rightHi = "dword " + genHiAddr(c.ctx, exp.Right.Var)
		} else {
			code += utils.Format("push edx; save left high")
			code += utils.Format("push eax; save left low")
			code += c.compileExpr64(exp.Right, "push", desc+" right")
			code += utils.Format("pop ebx; restore left low")
			code += utils.Format("pop ecx; restore left high")
			leftLo = "ebx"
			leftHi = "ecx"
			rightLo = "eax"
			rightHi = "edx"
		}
	}

	switch exp.Separator {
	case "+":
		code += utils.Format("mov eax, " + leftLo + "; 64bit add low")
		code += utils.Format("add eax, " + rightLo)
		code += utils.Format("mov edx, " + leftHi + "; 64bit add high")
		code += utils.Format("adc edx, " + rightHi)
	case "-":
		code += utils.Format("mov eax, " + leftLo + "; 64bit sub low")
		code += utils.Format("sub eax, " + rightLo)
		code += utils.Format("mov edx, " + leftHi + "; 64bit sub high")
		code += utils.Format("sbb edx, " + rightHi)
	case "*":
		code += utils.Format("mov eax, " + leftLo + "; 64bit mul low")
		code += utils.Format("imul dword " + rightLo)
		code += utils.Format("mov ecx, edx; save high")
		code += utils.Format("mov ebx, eax; save low")
		code += utils.Format("mov eax, " + leftHi)
		code += utils.Format("imul dword " + rightHi)
		code += utils.Format("add ecx, eax")
		code += utils.Format("mov eax, ebx; restore low")
		code += utils.Format("mov edx, ecx; restore high")
	default:
		code += utils.Format("mov eax, " + leftLo + "; 64bit op " + exp.Separator)
		code += utils.Format("mov edx, " + leftHi)
	}

	if result == "push" {
		code += utils.Format("push edx; high 32bit " + desc)
		code += utils.Format("push eax; low 32bit " + desc)
	} else if isRegName(result) {
	} else {
		dstLo := result
		dstHi := c.makeHiAddr(result)
		code += utils.Format("mov dword " + dstLo + ", eax; " + desc)
		code += utils.Format("mov dword " + dstHi + ", edx")
	}
	return
}

func (c *expCom) makeHiAddr(loAddr string) string {
	idx := strings.Index(loAddr, "[ebp")
	if idx == -1 {
		return loAddr
	}
	prefix := loAddr[:idx]
	ebpPart := loAddr[idx:]
	closeIdx := strings.Index(ebpPart, "]")
	if closeIdx == -1 {
		return loAddr
	}
	offsetStr := ebpPart[4:closeIdx]
	if offsetStr == "" {
		return prefix + "[ebp+4]"
	}
	offset, err := strconv.Atoi(offsetStr)
	if err != nil {
		return loAddr
	}
	offset += 4
	if offset < 0 {
		return prefix + "[ebp" + strconv.Itoa(offset) + "]"
	}
	return prefix + "[ebp+" + strconv.Itoa(offset) + "]"
}

func (c *expCom) CompileExprChildren(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	if exp.Separator == "" {
		return c.compileLeafNode(exp)
	}

	switch exp.Separator {
	case "[]":
		return c.compileIndexAccess(exp)
	case "[]=":
		return c.compileIndexSet(exp)
	case "[::]":
		return c.compileSlice(exp)
	case "list_lit":
		return c.compileListLiteral(exp)
	}

	return c.compileBinaryOp(exp)
}

func (c *expCom) builtinHandle(exp *parser.Expression, result, desc string) (code string) {
	if exp.Call == nil {
		return ""
	}

	if exp.Call.ThisVar != nil && exp.Call.ThisVar.Type != nil &&
		exp.Call.ThisVar.Type.Kind() == "list" && len(exp.Call.Args) == 0 {
		methodName := exp.Call.Name.Last()
		var fieldOffset int
		switch methodName {
		case "len":
			fieldOffset = 4
		case "cap":
			fieldOffset = 8
		case "ptr":
			fieldOffset = 0
		default:
			return ""
		}
		addr := listFieldAddr(c.ctx, exp.Call.ThisVar, fieldOffset)
		if result == "push" {
			code += utils.Format("push dword " + addr + "; " + desc)
		} else if isRegName(result) {
			code += utils.Format("mov " + result + ", dword " + addr + "; " + desc)
		} else {
			code += utils.Format("mov eax, dword " + addr + "; " + desc)
			code += utils.Format("mov " + result + ", eax; " + desc)
		}
		return
	}

	if len(exp.Call.Args) != 1 {
		return ""
	}
	callName := exp.Call.Name.String()
	arg := exp.Call.Args[0]
	if arg == nil || arg.Value == nil {
		return ""
	}
	argType := arg.Value.Type
	if argType == nil {
		return ""
	}

	switch callName {
	case "len", "lists_len":
		if typeSys.CheckKind(argType, "string") || argType.Kind() == "list" {
			var argCode, argResult string
			if arg.Value.IsConst() {
				argCode, argResult = c.CompileExprVal(arg.Value)
			} else {
				var argReg *regmgr.Reg
				argCode, argReg = c.CompileExprChildren(arg.Value)
				if argReg != nil {
					argResult = argReg.Name
				} else {
					argCode2, argResult2 := c.CompileExprVal(arg.Value)
					argCode += argCode2
					argResult = argResult2
				}
			}
			code += argCode
			if result == "push" {
				code += utils.Format("push dword [" + argResult + "+4]; " + desc)
			} else {
				code += utils.Format("mov " + result + ", dword [" + argResult + "+4]; " + desc)
			}
			return
		}
	case "cap", "lists_cap":
		if typeSys.CheckKind(argType, "string") || argType.Kind() == "list" {
			var argCode, argResult string
			if arg.Value.IsConst() {
				argCode, argResult = c.CompileExprVal(arg.Value)
			} else {
				var argReg *regmgr.Reg
				argCode, argReg = c.CompileExprChildren(arg.Value)
				if argReg != nil {
					argResult = argReg.Name
				} else {
					argCode2, argResult2 := c.CompileExprVal(arg.Value)
					argCode += argCode2
					argResult = argResult2
				}
			}
			code += argCode
			if result == "push" {
				code += utils.Format("push dword [" + argResult + "+8]; " + desc)
			} else {
				code += utils.Format("mov " + result + ", dword [" + argResult + "+8]; " + desc)
			}
			return
		}
	}
	return ""
}

func (c *expCom) numConstHandle(exp *parser.Expression, result, desc string) (code string) {
	if typeSys.CheckKind(exp.Type, "int", "uint", "i64", "u64") && exp.IsConst() {
		if is64Type(exp.Type) {
			val := strconv.FormatFloat(exp.Num, 'f', -1, 64)
			if result == "push" {
				code += utils.Format("push 0; high 32bit " + desc)
				code += utils.Format("push " + val + "; low 32bit " + desc)
			} else if isRegName(result) {
				code += utils.Format("mov " + result + ", " + val + "; " + desc)
			} else {
				loAddr := result
				hiAddr := c.makeHiAddr(result)
				code += utils.Format("mov dword " + loAddr + ", " + val + "; " + desc)
				code += utils.Format("mov dword " + hiAddr + ", 0")
			}
			return
		}
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

func (c *expCom) strConstHandle(exp *parser.Expression, result, desc string) (code string) {
	if typeSys.CheckKind(exp.Type, "string") && exp.IsConst() && exp.StringVal != "" {
		label := c.getStringLabel(exp.StringVal)
		if result == "push" {
			code += utils.Format("push " + label + "; " + desc)
		} else {
			code += utils.Format("mov dword " + result + ", " + label + "; " + desc)
			strLen := len(exp.StringVal)
			code += utils.Format("mov dword [" + result[5:len(result)-1] + "+4], " + strconv.Itoa(strLen))
			code += utils.Format("mov dword [" + result[5:len(result)-1] + "+8], " + strconv.Itoa(strLen))
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
		if typeSys.CheckKind(exp.Type, "int", "float", "uint") {
			result = strconv.FormatFloat(exp.Num, 'f', -1, 64)
		} else if typeSys.CheckKind(exp.Type, "bool") {
			if exp.Bool {
				result = "1"
			} else {
				result = "0"
			}
		} else if typeSys.CheckKind(exp.Type, "string") && exp.StringVal != "" {
			label := c.getStringLabel(exp.StringVal)
			result = label
		}
	} else if exp.Var != nil {
		if exp.Var.Value != nil {
			code = c.ctx.Arch.Var(exp.Var)
			c.varWithSetVal = true
			return
		}
		if is64Type(exp.Type) {
			loAddr := genLoAddr(c.ctx, exp.Var)
			hiAddr := genHiAddr(c.ctx, exp.Var)
			code += utils.Format("mov eax, " + loAddr)
			code += utils.Format("mov edx, " + hiAddr)
			result = "EDX:EAX"
		} else if rInfo := c.ctx.Reg.Reuse(exp.Var.Define); rInfo != nil {
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

func (c *expCom) getStringLabel(val string) string {
	if label, ok := c.ctx.StringConsts[val]; ok {
		return label
	}
	c.ctx.StrCount++
	label := "str_" + strconv.Itoa(c.ctx.StrCount)
	c.ctx.StringConsts[val] = label
	return label
}

func (c *expCom) compileListToAddr(exp *parser.Expression, baseOffset int, desc string) (code string) {
	ptrAddr := makeEbpAddr(baseOffset)
	lenAddr := makeEbpAddr(baseOffset + 4)
	capAddr := makeEbpAddr(baseOffset + 8)

	switch exp.Separator {
	case "list_lit":
		return c.compileListLitFields(exp, ptrAddr, lenAddr, capAddr, desc)
	case "[::]":
		return c.compileSliceFields(exp, ptrAddr, lenAddr, capAddr, desc)
	case "":
		if exp.Var != nil {
			srcAddr := genVarAddr(c.ctx, exp.Var)
			srcBaseOffset, ok := extractEbpOffset(srcAddr)
			if ok {
				srcPtrAddr := makeEbpAddr(srcBaseOffset)
				srcLenAddr := makeEbpAddr(srcBaseOffset + 4)
				srcCapAddr := makeEbpAddr(srcBaseOffset + 8)
				code += utils.Format("mov eax, dword " + srcPtrAddr + "; " + desc)
				code += utils.Format("mov dword " + ptrAddr + ", eax")
				code += utils.Format("mov eax, dword " + srcLenAddr)
				code += utils.Format("mov dword " + lenAddr + ", eax")
				code += utils.Format("mov eax, dword " + srcCapAddr)
				code += utils.Format("mov dword " + capAddr + ", eax")
				return
			}
		}
		var reg *regmgr.Reg
		code, reg = c.CompileExprChildren(exp)
		if reg != nil {
			code += utils.Format("mov dword " + ptrAddr + ", " + reg.Name + "; " + desc)
			c.ctx.Reg.Free(exp)
		}
		return
	default:
		var reg *regmgr.Reg
		code, reg = c.CompileExprChildren(exp)
		if reg != nil {
			code += utils.Format("mov dword " + ptrAddr + ", " + reg.Name + "; " + desc)
			c.ctx.Reg.Free(exp)
		}
		return
	}
}

func (c *expCom) compileListLitFields(exp *parser.Expression, ptrAddr, lenAddr, capAddr, desc string) (code string) {
	lt := exp.Type.(*typeSys.ListType)
	n := len(exp.ListElems)

	if n == 0 {
		code += utils.Format("mov dword " + ptrAddr + ", 0; " + desc)
		code += utils.Format("mov dword " + lenAddr + ", 0")
		code += utils.Format("mov dword " + capAddr + ", 0")
		return
	}

	elemSize := lt.Elem().Size()
	c.ctx.ListDataCount++
	dataLabel := "list_data_" + strconv.Itoa(c.ctx.ListDataCount)

	dataSection := dataLabel + ":\n"
	for _, elem := range exp.ListElems {
		if elem.IsConst() && typeSys.CheckKind(elem.Type, "int", "uint") {
			val := strconv.FormatFloat(elem.Num, 'f', -1, 64)
			switch elemSize {
			case 1:
				dataSection += "db " + val + "\n"
			case 2:
				dataSection += "dw " + val + "\n"
			case 4:
				dataSection += "dd " + val + "\n"
			case 8:
				dataSection += "dq " + val + "\n"
			}
		} else if elem.IsConst() && typeSys.CheckKind(elem.Type, "string") {
			strLabel := c.getStringLabel(elem.StringVal)
			dataSection += "dd " + strLabel + "\n"
			dataSection += "dd " + strconv.Itoa(len(elem.StringVal)) + "\n"
			dataSection += "dd " + strconv.Itoa(len(elem.StringVal)) + "\n"
		} else {
			dataSection += "dd 0\n"
			if elemSize > 4 {
				for i := 4; i < elemSize; i += 4 {
					dataSection += "dd 0\n"
				}
			}
		}
	}

	code += utils.Format("; list literal [" + strconv.Itoa(n) + " elements]")
	code += "section .data\n" + dataSection + "section .text\n"

	code += utils.Format("mov dword " + ptrAddr + ", " + dataLabel + "; " + desc)
	code += utils.Format("mov dword " + lenAddr + ", " + strconv.Itoa(n))
	code += utils.Format("mov dword " + capAddr + ", " + strconv.Itoa(n))

	return
}

func (c *expCom) compileSliceFields(exp *parser.Expression, ptrAddr, lenAddr, capAddr, desc string) (code string) {
	lt := exp.Left.Type.(*typeSys.ListType)
	elemSize := lt.Elem().Size()

	var leftCode, leftResult string
	if exp.Left.IsConst() {
		leftCode, leftResult = c.CompileExprVal(exp.Left)
	} else {
		var leftReg *regmgr.Reg
		leftCode, leftReg = c.CompileExprChildren(exp.Left)
		if leftReg != nil {
			leftResult = leftReg.Name
			c.ctx.Reg.Free(exp.Left)
		} else {
			leftCode2, leftResult2 := c.CompileExprVal(exp.Left)
			leftCode += leftCode2
			leftResult = leftResult2
		}
	}
	code += leftCode

	reg := c.ctx.Reg.Get(c.ctx.Now, exp, false)
	if reg.StoreCode != "" {
		code += reg.StoreCode
	}

	code += utils.Format("mov " + reg.Name + ", " + leftResult + "; load list ptr")

	var startExpr, endExpr *parser.Expression
	if exp.Right != nil {
		startExpr = exp.Right.Left
		if exp.Right.Right != nil {
			endExpr = exp.Right.Right.Left
		}
	}

	if startExpr != nil {
		if startExpr.IsConst() {
			startVal := int(startExpr.Num)
			byteOffset := startVal * elemSize
			if byteOffset != 0 {
				code += utils.Format("add " + reg.Name + ", " + strconv.Itoa(byteOffset) + "; ptr += start*elemSize")
			}
		} else {
			var startCode, startResult string
			var startReg *regmgr.Reg
			startCode, startReg = c.CompileExprChildren(startExpr)
			if startReg != nil {
				startResult = startReg.Name
			} else {
				startCode2, startResult2 := c.CompileExprVal(startExpr)
				startCode += startCode2
				startResult = startResult2
			}
			code += startCode
			code += utils.Format("imul " + startResult + ", " + strconv.Itoa(elemSize))
			code += utils.Format("add " + reg.Name + ", " + startResult)
			c.ctx.Reg.Free(startExpr)
		}
	}

	code += utils.Format("mov dword " + ptrAddr + ", " + reg.Name + "; " + desc)

	if startExpr != nil && endExpr != nil {
		if startExpr.IsConst() && endExpr.IsConst() {
			startVal := int(startExpr.Num)
			endVal := int(endExpr.Num)
			newLen := endVal - startVal
			code += utils.Format("mov dword " + lenAddr + ", " + strconv.Itoa(newLen))
			code += utils.Format("mov dword " + capAddr + ", " + strconv.Itoa(newLen))
		} else {
			var endCode, endResult string
			if endExpr.IsConst() {
				endCode, endResult = c.CompileExprVal(endExpr)
			} else {
				var endReg *regmgr.Reg
				endCode, endReg = c.CompileExprChildren(endExpr)
				if endReg != nil {
					endResult = endReg.Name
				} else {
					endCode2, endResult2 := c.CompileExprVal(endExpr)
					endCode += endCode2
					endResult = endResult2
				}
				c.ctx.Reg.Free(endExpr)
			}
			code += endCode
			code += utils.Format("mov dword " + lenAddr + ", " + endResult)
			if startExpr.IsConst() {
				startVal := int(startExpr.Num)
				if startVal != 0 {
					code += utils.Format("sub dword " + lenAddr + ", " + strconv.Itoa(startVal))
				}
			}
			code += utils.Format("mov eax, dword " + lenAddr)
			code += utils.Format("mov dword " + capAddr + ", eax")
		}
	} else if startExpr == nil && endExpr != nil {
		var endCode, endResult string
		if endExpr.IsConst() {
			endCode, endResult = c.CompileExprVal(endExpr)
		} else {
			var endReg *regmgr.Reg
			endCode, endReg = c.CompileExprChildren(endExpr)
			if endReg != nil {
				endResult = endReg.Name
			} else {
				endCode2, endResult2 := c.CompileExprVal(endExpr)
				endCode += endCode2
				endResult = endResult2
			}
			c.ctx.Reg.Free(endExpr)
		}
		code += endCode
		code += utils.Format("mov dword " + lenAddr + ", " + endResult)
		code += utils.Format("mov dword " + capAddr + ", " + endResult)
	} else if startExpr != nil && endExpr == nil {
		if startExpr.IsConst() {
			startVal := int(startExpr.Num)
			srcAddr := genVarAddr(c.ctx, exp.Left.Var)
			srcBaseOffset, ok := extractEbpOffset(srcAddr)
			if ok {
				srcLenAddr := makeEbpAddr(srcBaseOffset + 4)
				srcCapAddr := makeEbpAddr(srcBaseOffset + 8)
				code += utils.Format("mov eax, dword " + srcLenAddr)
				if startVal != 0 {
					code += utils.Format("sub eax, " + strconv.Itoa(startVal))
				}
				code += utils.Format("mov dword " + lenAddr + ", eax")
				code += utils.Format("mov eax, dword " + srcCapAddr)
				if startVal != 0 {
					code += utils.Format("sub eax, " + strconv.Itoa(startVal))
				}
				code += utils.Format("mov dword " + capAddr + ", eax")
			}
		}
	} else if startExpr == nil && endExpr == nil {
		srcAddr := genVarAddr(c.ctx, exp.Left.Var)
		srcBaseOffset, ok := extractEbpOffset(srcAddr)
		if ok {
			srcLenAddr := makeEbpAddr(srcBaseOffset + 4)
			srcCapAddr := makeEbpAddr(srcBaseOffset + 8)
			code += utils.Format("mov eax, dword " + srcLenAddr)
			code += utils.Format("mov dword " + lenAddr + ", eax")
			code += utils.Format("mov eax, dword " + srcCapAddr)
			code += utils.Format("mov dword " + capAddr + ", eax")
		}
	}

	c.ctx.Reg.Free(exp)
	return
}

func (c *expCom) compileListLiteral(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	if len(exp.ListElems) == 0 {
		reg = c.ctx.Reg.Get(c.ctx.Now, exp, false)
		if reg.StoreCode != "" {
			code += reg.StoreCode
		}
		code += utils.Format("xor " + reg.Name + ", " + reg.Name)
		code += utils.Format("mov dword [" + reg.Name + "+4], 0")
		code += utils.Format("mov dword [" + reg.Name + "+8], 0")
		return
	}

	lt := exp.Type.(*typeSys.ListType)
	elemSize := lt.Elem().Size()
	n := len(exp.ListElems)

	c.ctx.ListDataCount++
	dataLabel := "list_data_" + strconv.Itoa(c.ctx.ListDataCount)

	dataSection := dataLabel + ":\n"
	for _, elem := range exp.ListElems {
		if elem.IsConst() && typeSys.CheckKind(elem.Type, "int", "uint") {
			val := strconv.FormatFloat(elem.Num, 'f', -1, 64)
			switch elemSize {
			case 1:
				dataSection += "db " + val + "\n"
			case 2:
				dataSection += "dw " + val + "\n"
			case 4:
				dataSection += "dd " + val + "\n"
			case 8:
				dataSection += "dq " + val + "\n"
			}
		} else if elem.IsConst() && typeSys.CheckKind(elem.Type, "string") {
			strLabel := c.getStringLabel(elem.StringVal)
			dataSection += "dd " + strLabel + "\n"
			dataSection += "dd " + strconv.Itoa(len(elem.StringVal)) + "\n"
			dataSection += "dd " + strconv.Itoa(len(elem.StringVal)) + "\n"
		} else {
			dataSection += "dd 0\n"
			if elemSize > 4 {
				for i := 4; i < elemSize; i += 4 {
					dataSection += "dd 0\n"
				}
			}
		}
	}

	code += utils.Format("; list literal [" + strconv.Itoa(n) + " elements]")
	code += "section .data\n" + dataSection + "section .text\n"

	reg = c.ctx.Reg.Get(c.ctx.Now, exp, false)
	if reg.StoreCode != "" {
		code += reg.StoreCode
	}
	code += utils.Format("mov " + reg.Name + ", " + dataLabel)
	code += utils.Format("mov dword [" + reg.Name + "+4], " + strconv.Itoa(n))
	code += utils.Format("mov dword [" + reg.Name + "+8], " + strconv.Itoa(n))

	return
}

func (c *expCom) compileIndexAccess(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	lt := exp.Left.Type.(*typeSys.ListType)
	elemSize := lt.Elem().Size()

	var leftCode, leftResult string
	var leftReg *regmgr.Reg
	if exp.Left.IsConst() {
		leftCode, leftResult = c.CompileExprVal(exp.Left)
	} else {
		leftCode, leftReg = c.CompileExprChildren(exp.Left)
		if leftReg != nil {
			leftResult = leftReg.Name
		} else {
			leftCode2, leftResult2 := c.CompileExprVal(exp.Left)
			leftCode += leftCode2
			leftResult = leftResult2
		}
	}
	code += leftCode

	reg = c.ctx.Reg.Get(c.ctx.Now, exp, false)
	if reg.StoreCode != "" {
		code += reg.StoreCode
	}

	if leftReg != nil && reg.Name == leftReg.Name {
		code += utils.Format("; load list ptr (already in " + reg.Name + ")")
	} else {
		code += utils.Format("mov " + reg.Name + ", " + leftResult + "; load list ptr")
	}

	if exp.Right.IsConst() {
		idx := int(exp.Right.Num)
		byteOffset := idx * elemSize
		if byteOffset != 0 {
			code += utils.Format("add " + reg.Name + ", " + strconv.Itoa(byteOffset) + "; ptr += index*elemSize")
		}
	} else {
		var indexCode, indexResult string
		var indexReg *regmgr.Reg
		indexCode, indexReg = c.CompileExprChildren(exp.Right)
		if indexReg != nil {
			indexResult = indexReg.Name
		} else {
			indexCode2, indexResult2 := c.CompileExprVal(exp.Right)
			indexCode += indexCode2
			indexResult = indexResult2
		}
		code += indexCode
		code += utils.Format("imul " + indexResult + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + reg.Name + ", " + indexResult)
		if indexReg != nil {
			c.ctx.Reg.Free(exp.Right)
		}
	}

	sizePrefix := GetLengthName(elemSize)
	code += utils.Format("mov " + reg.Name + ", " + sizePrefix + "[" + reg.Name + "]; load element")

	return
}

func (c *expCom) compileIndexSet(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	lt := exp.Left.Type.(*typeSys.ListType)
	elemSize := lt.Elem().Size()

	var leftCode, leftResult string
	if exp.Left.IsConst() {
		leftCode, leftResult = c.CompileExprVal(exp.Left)
	} else {
		var leftReg *regmgr.Reg
		leftCode, leftReg = c.CompileExprChildren(exp.Left)
		if leftReg != nil {
			leftResult = leftReg.Name
			c.ctx.Reg.Free(exp.Left)
		} else {
			leftCode2, leftResult2 := c.CompileExprVal(exp.Left)
			leftCode += leftCode2
			leftResult = leftResult2
		}
	}
	code += leftCode

	addrReg := c.ctx.Reg.Get(c.ctx.Now, exp, false)
	if addrReg.StoreCode != "" {
		code += addrReg.StoreCode
	}

	code += utils.Format("mov " + addrReg.Name + ", " + leftResult + "; load list ptr")

	if exp.Right.Left.IsConst() {
		idx := int(exp.Right.Left.Num)
		byteOffset := idx * elemSize
		if byteOffset != 0 {
			code += utils.Format("add " + addrReg.Name + ", " + strconv.Itoa(byteOffset) + "; ptr += index*elemSize")
		}
	} else {
		var indexCode, indexResult string
		var indexReg *regmgr.Reg
		indexCode, indexReg = c.CompileExprChildren(exp.Right.Left)
		if indexReg != nil {
			indexResult = indexReg.Name
			c.ctx.Reg.Free(exp.Right.Left)
		} else {
			indexCode2, indexResult2 := c.CompileExprVal(exp.Right.Left)
			indexCode += indexCode2
			indexResult = indexResult2
		}
		code += indexCode
		code += utils.Format("imul " + indexResult + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + addrReg.Name + ", " + indexResult)
	}

	var valCode, valResult string
	if exp.Right.Right.IsConst() {
		valCode, valResult = c.CompileExprVal(exp.Right.Right)
	} else {
		var valReg *regmgr.Reg
		valCode, valReg = c.CompileExprChildren(exp.Right.Right)
		if valReg != nil {
			valResult = valReg.Name
		} else {
			valCode2, valResult2 := c.CompileExprVal(exp.Right.Right)
			valCode += valCode2
			valResult = valResult2
		}
	}
	code += valCode

	sizePrefix := GetLengthName(elemSize)
	code += utils.Format("mov " + sizePrefix + "[" + addrReg.Name + "], " + valResult + "; store element")

	c.ctx.Reg.Free(exp)

	reg = nil
	return
}

func (c *expCom) compileSlice(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	var leftCode, leftResult string
	if exp.Left.IsConst() {
		leftCode, leftResult = c.CompileExprVal(exp.Left)
	} else {
		var leftReg *regmgr.Reg
		leftCode, leftReg = c.CompileExprChildren(exp.Left)
		if leftReg != nil {
			leftResult = leftReg.Name
		} else {
			leftCode2, leftResult2 := c.CompileExprVal(exp.Left)
			leftCode += leftCode2
			leftResult = leftResult2
		}
	}
	code += leftCode

	reg = c.ctx.Reg.Get(c.ctx.Now, exp, false)
	if reg.StoreCode != "" {
		code += reg.StoreCode
	}

	code += utils.Format("mov " + reg.Name + ", " + leftResult)

	var startExpr, endExpr *parser.Expression
	if exp.Right != nil {
		startExpr = exp.Right.Left
		if exp.Right.Right != nil {
			endExpr = exp.Right.Right.Left
		}
	}

	if startExpr != nil {
		var startCode, startResult string
		if startExpr.IsConst() {
			startCode, startResult = c.CompileExprVal(startExpr)
		} else {
			var startReg *regmgr.Reg
			startCode, startReg = c.CompileExprChildren(startExpr)
			if startReg != nil {
				startResult = startReg.Name
				c.ctx.Reg.Free(startExpr)
			} else {
				startCode2, startResult2 := c.CompileExprVal(startExpr)
				startCode += startCode2
				startResult = startResult2
			}
		}
		code += startCode

		lt := exp.Left.Type.(*typeSys.ListType)
		elemSize := lt.Elem().Size()
		code += utils.Format("imul " + startResult + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + reg.Name + ", " + startResult)
	}

	if endExpr != nil {
		var endCode, endResult string
		if endExpr.IsConst() {
			endCode, endResult = c.CompileExprVal(endExpr)
		} else {
			var endReg *regmgr.Reg
			endCode, endReg = c.CompileExprChildren(endExpr)
			if endReg != nil {
				endResult = endReg.Name
				c.ctx.Reg.Free(endExpr)
			} else {
				endCode2, endResult2 := c.CompileExprVal(endExpr)
				endCode += endCode2
				endResult = endResult2
			}
		}
		code += endCode
		code += utils.Format("mov dword [" + reg.Name + "+4], " + endResult)
	}

	return
}
