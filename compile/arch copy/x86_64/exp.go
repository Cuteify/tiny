package x86_64

import (
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strconv"
)

const (
	NumExp  = 1
	BoolExp = 2
	AndExp  = 3
	OrExp   = 4
	NotExp  = 5
)

type ExpCom struct {
	ctx           *context.Context
	varWithSetVal bool
}

func NewExpCom(ctx *context.Context) *ExpCom {
	return &ExpCom{ctx: ctx}
}

func (c *ExpCom) CompileExpr(exp *parser.Expression, result, desc string) (code string) {
	if exp.Type == nil {
		panic("Expression Type is nil: " + desc)
	}

	if tmp := c.builtinHandle(exp, result, desc); tmp != "" {
		code = tmp
		return
	}

	if exp.Type != nil && exp.Type.Kind() == "list" && result != "push" && !IsReg(result) {
		if baseOffset, ok := GetRbpOffset(result); ok {
			return c.compileListToAddr(exp, baseOffset, desc)
		}
	}

	// 移除对 CompileBoolExpr 的调用，避免与 compileCondition 重复生成 cmp 指令
	// if exp.Type.Type() == "bool" {
	// 	return c.CompileBoolExpr(exp, result)
	// }

	if tmp := c.numConstHandle(exp, result, desc); tmp != "" {
		code = tmp
		return
	}
	if tmp := c.strConstHandle(exp, result, desc); tmp != "" {
		code = tmp
		return
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

func (c *ExpCom) CompileExprChildren(exp *parser.Expression) (code string, reg *regmgr.Reg) {
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

func (c *ExpCom) builtinHandle(exp *parser.Expression, result, desc string) (code string) {
	if exp.Call == nil {
		return ""
	}

	if exp.Call.ThisVar != nil && exp.Call.ThisVar.Type != nil &&
		exp.Call.ThisVar.Type.Kind() == "list" && len(exp.Call.Args) == 0 {
		methodName := exp.Call.Name.Last()
		var fieldOffset int
		switch methodName {
		case "len":
			fieldOffset = 8
		case "cap":
			fieldOffset = 16
		case "ptr":
			fieldOffset = 0
		default:
			return ""
		}
		addr := GenListFieldAddr(exp.Call.ThisVar, fieldOffset)
		if result == "push" {
			code += utils.Format("push QWORD " + addr + "; " + desc)
		} else if IsReg(result) {
			code += utils.Format("mov " + result + ", QWORD " + addr + "; " + desc)
		} else {
			code += utils.Format("mov rax, QWORD " + addr + "; " + desc)
			code += utils.Format("mov " + result + ", rax; " + desc)
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
				code += utils.Format("push QWORD [" + argResult + "+8]; " + desc)
			} else {
				code += utils.Format("mov " + result + ", QWORD [" + argResult + "+8]; " + desc)
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
				code += utils.Format("push QWORD [" + argResult + "+16]; " + desc)
			} else {
				code += utils.Format("mov " + result + ", QWORD [" + argResult + "+16]; " + desc)
			}
			return
		}
	}
	return ""
}

func (c *ExpCom) numConstHandle(exp *parser.Expression, result, desc string) (code string) {
	if typeSys.CheckKind(exp.Type, "int", "uint") && exp.IsConst() {
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

func (c *ExpCom) strConstHandle(exp *parser.Expression, result, desc string) (code string) {
	if typeSys.CheckKind(exp.Type, "string") && exp.IsConst() && exp.StringVal != "" {
		label := c.getStringLabel(exp.StringVal)
		if result == "push" {
			code += utils.Format("push " + label + "; " + desc)
		} else {
			code += utils.Format("mov QWORD " + result + ", " + label + "; " + desc)
			strLen := len(exp.StringVal)
			// 如果result是寄存器名，直接使用寄存器；如果是内存地址，提取地址部分
			addr := result
			if len(result) > 5 && result[:5] == "QWORD" {
				addr = result[5:]
			}
			code += utils.Format("mov QWORD [" + addr + "+8], " + strconv.Itoa(strLen))
			code += utils.Format("mov QWORD [" + addr + "+16], " + strconv.Itoa(strLen))
		}
		return
	}
	return ""
}

func (c *ExpCom) compileLeafNode(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	tmp, resultVal := c.CompileExprVal(exp)
	code += tmp
	reg = c.ctx.Reg.Get(c.ctx.Now, exp, ClassGPR, false)

	if c.varWithSetVal {
		return
	}

	if c.ctx.EbxOccupied && reg != nil && reg.Name == "RBX" {
		c.ctx.Reg.Free(exp)
		reg = c.ctx.Reg.Get(c.ctx.Now, exp, ClassGPR, false)
	}

	if reg == nil {
		// 如果寄存器分配失败，使用RAX作为默认寄存器
		reg = &regmgr.Reg{Name: "RAX", RegIndex: 0}
	}

	if reg.StoreCode != "" {
		code += reg.StoreCode
	}

	if reg.Name != resultVal {
		code += utils.Format("mov " + reg.Name + ", " + resultVal)
	}
	return
}

func (c *ExpCom) compileBinaryOp(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	var leftReg, rightReg *regmgr.Reg
	var leftResult string
	var rightResult string

	leftCode, leftReg, leftResult := c.compileLeftChild(exp)

	if c.needSaveLeftToRBX(exp, leftReg) {
		code += leftCode
		code += c.saveLeftToRBX(exp.Left, leftReg, leftResult)
		leftResult = "RBX"
		leftReg = nil
	} else {
		code = leftCode
	}

	rightCode, rightReg, rightResult := c.compileRightChild(exp, leftResult)
	code += rightCode

	if exp.Separator != "" {
		if leftResult == "RBX" && leftReg == nil {
			code = c.generateOpWithRBX(code, exp, rightResult, rightReg, exp.Left)
			reg = &regmgr.Reg{Name: "RBX"}
		} else {
			code, reg = c.generateOpNormal(code, exp, leftReg, rightReg, leftResult, rightResult)
		}
	}

	return code, reg
}

func (c *ExpCom) compileLeftChild(exp *parser.Expression) (code string, reg *regmgr.Reg, result string) {
	if exp.Left == nil {
		return
	}

	if exp.Left.Call != nil && exp.Right != nil && c.containsCall(exp.Right) {
		c.ctx.UseEBXDirect = true
		code, result = c.CompileExprVal(exp.Left)
		c.ctx.UseEBXDirect = false
		reg = nil

		c.ctx.Reg.Force(&regmgr.Reg{Name: "RBX", RegIndex: 1}, exp.Left)
		return
	}

	if exp.Left.IsConst() {
		code, result = c.CompileExprVal(exp.Left)
	} else {
		code, reg = c.CompileExprChildren(exp.Left)
		if reg != nil {
			result = reg.Name
		}
	}
	return
}

func (c *ExpCom) compileRightChild(exp *parser.Expression, leftResult string) (code string, reg *regmgr.Reg, result string) {
	if exp.Right == nil {
		return
	}

	if leftResult == "RBX" {
		c.ctx.EbxOccupied = true
	}
	defer func() { c.ctx.EbxOccupied = false }()

	if exp.Right.IsConst() {
		code, result = c.CompileExprVal(exp.Right)
	} else if exp.Right.Call != nil {
		code, result = c.CompileExprVal(exp.Right)
	} else {
		code, reg = c.CompileExprChildren(exp.Right)
		if reg != nil {
			result = reg.Name
		}
	}
	return
}

func (c *ExpCom) needSaveLeftToRBX(exp *parser.Expression, leftReg *regmgr.Reg) bool {
	if exp.Right == nil {
		return false
	}
	if !c.containsCall(exp.Right) {
		return false
	}
	return exp.Left == nil || exp.Left.Call == nil
}

func (c *ExpCom) saveLeftToRBX(leftExp *parser.Expression, leftReg *regmgr.Reg, leftResult string) string {
	code := ""
	if leftReg != nil {
		c.ctx.Reg.Free(leftExp)
	}
	code += utils.Format("mov RBX, " + leftResult + "; 保存中间结果到RBX(callee-save)")
	return code
}

func (c *ExpCom) generateOpWithRBX(code string, exp *parser.Expression, rightResult string, rightReg *regmgr.Reg, leftExp *parser.Expression) string {
	if rightReg != nil {
		c.ctx.Reg.Free(exp.Right)
	}

	formattedSrc := rightResult

	switch exp.Separator {
	case "+":
		code += utils.Format("add RBX, " + formattedSrc + "; RBX = fib(i-1) + fib(i-2)")
	case "-":
		code += utils.Format("sub RBX, " + formattedSrc)
	case "*":
		code += utils.Format("imul RBX, " + formattedSrc)
	case "/":
		code += utils.Format("cqo")
		code += utils.Format("mov rax, RBX")
		code += utils.Format("idiv " + formattedSrc)
		code += utils.Format("mov RBX, rax")
	case "%":
		code += utils.Format("cqo")
		code += utils.Format("mov rax, RBX")
		code += utils.Format("idiv " + formattedSrc)
		code += utils.Format("mov RBX, rdx")
	}

	c.ctx.Reg.Free(leftExp)

	return code
}

func (c *ExpCom) generateOpNormal(code string, exp *parser.Expression, leftReg, rightReg *regmgr.Reg, leftResult, rightResult string) (string, *regmgr.Reg) {
	reg, src := c.selectResultReg(leftReg, rightReg, leftResult, rightResult, exp)

	if reg == nil {
		reg = c.ctx.Reg.Get(c.ctx.Now, exp, ClassGPR, false)
		if reg == nil {
			return code, nil
		}
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

func (c *ExpCom) selectResultReg(leftReg, rightReg *regmgr.Reg, leftResult, rightResult string, exp *parser.Expression) (*regmgr.Reg, string) {
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

func (c *ExpCom) emitOpInstruction(regName, op, src string) string {
	switch op {
	case "+":
		return utils.Format("add " + regName + ", " + src)
	case "-":
		return utils.Format("sub " + regName + ", " + src)
	case "*":
		return utils.Format("imul " + regName + ", " + src)
	case "/":
		return utils.Format("cqo") +
			utils.Format("mov rax, "+regName) +
			utils.Format("idiv "+src) +
			utils.Format("mov "+regName+", rax")
	case "%":
		return utils.Format("cqo") +
			utils.Format("mov rax, "+regName) +
			utils.Format("idiv "+src) +
			utils.Format("mov "+regName+", rdx")
	default:
		return ""
	}
}

func (c *ExpCom) CompileBoolExpr(exp *parser.Expression, result string) (code string) {
	var leftReg *regmgr.Reg
	var rightReg *regmgr.Reg
	var leftCode, leftResult string
	var rightCode, rightResult string
	if exp.Left != nil {
		if exp.Left.IsConst() {
			leftCode, leftResult = c.CompileExprVal(exp.Left)
		} else {
			leftCode, leftReg = c.CompileExprChildren(exp.Left)
			if leftReg != nil {
				leftResult = leftReg.Name
			} else {
				// 回退到CompileExprVal
				leftCode, leftResult = c.CompileExprVal(exp.Left)
			}
		}
	}
	code += leftCode

	if exp.Right != nil {
		if exp.Right.IsConst() {
			rightCode, rightResult = c.CompileExprVal(exp.Right)
		} else {
			rightCode, rightReg = c.CompileExprChildren(exp.Right)
			if rightReg != nil {
				rightResult = rightReg.Name
			} else {
				// 回退到CompileExprVal
				rightCode, rightResult = c.CompileExprVal(exp.Right)
			}
		}
	}
	code += rightCode

	formattedLeft := leftResult
	formattedRight := rightResult
	code += utils.Format("cmp " + formattedLeft + ", " + formattedRight)
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

	return
}

func (c *ExpCom) CompileExprVal(exp *parser.Expression) (code, result string) {
	if exp.IsConst() {
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
			code = c.ctx.Arch.VarDecl(exp.Var)
			c.varWithSetVal = true
			return
		}
		result = GenVarAddr(exp.Var)
	} else if exp.Call != nil {
		code = c.ctx.Arch.Call(exp.Call)
		result = "RAX"
		if c.ctx.UseEBXDirect {
			code += utils.Format("mov RBX, RAX; 函数返回值直接移到RBX")
			result = "RBX"
		}
	}
	return
}

func (c *ExpCom) containsCall(exp *parser.Expression) bool {
	if exp == nil {
		return false
	}
	if exp.Call != nil {
		return true
	}
	return c.containsCall(exp.Left) || c.containsCall(exp.Right)
}

func (c *ExpCom) getStringLabel(val string) string {
	if label, ok := c.ctx.StringConsts[val]; ok {
		return label
	}
	c.ctx.StrCount++
	label := "str_" + strconv.Itoa(c.ctx.StrCount)
	c.ctx.StringConsts[val] = label
	return label
}

func (c *ExpCom) compileListToAddr(exp *parser.Expression, baseOffset int, desc string) (code string) {
	ptrAddr := MakeRbpAddr(baseOffset)
	lenAddr := MakeRbpAddr(baseOffset + 8)
	capAddr := MakeRbpAddr(baseOffset + 16)

	switch exp.Separator {
	case "list_lit":
		return c.compileListLitFields(exp, ptrAddr, lenAddr, capAddr, desc)
	case "[::]":
		return c.compileSliceFields(exp, ptrAddr, lenAddr, capAddr, desc)
	case "":
		if exp.Var != nil {
			srcAddr := GenVarAddr(exp.Var)
			srcBaseOffset, ok := GetRbpOffset(srcAddr)
			if ok {
				srcPtrAddr := MakeRbpAddr(srcBaseOffset)
				srcLenAddr := MakeRbpAddr(srcBaseOffset + 8)
				srcCapAddr := MakeRbpAddr(srcBaseOffset + 16)
				code += utils.Format("mov rax, QWORD " + srcPtrAddr + "; " + desc)
				code += utils.Format("mov QWORD " + ptrAddr + ", rax")
				code += utils.Format("mov rax, QWORD " + srcLenAddr)
				code += utils.Format("mov QWORD " + lenAddr + ", rax")
				code += utils.Format("mov rax, QWORD " + srcCapAddr)
				code += utils.Format("mov QWORD " + capAddr + ", rax")
				return
			}
		}
		var reg *regmgr.Reg
		code, reg = c.CompileExprChildren(exp)
		if reg != nil {
			code += utils.Format("mov QWORD " + ptrAddr + ", " + reg.Name + "; " + desc)
			c.ctx.Reg.Free(exp)
		}
		return
	default:
		var reg *regmgr.Reg
		code, reg = c.CompileExprChildren(exp)
		if reg != nil {
			code += utils.Format("mov QWORD " + ptrAddr + ", " + reg.Name + "; " + desc)
			c.ctx.Reg.Free(exp)
		}
		return
	}
}

func (c *ExpCom) compileListLitFields(exp *parser.Expression, ptrAddr, lenAddr, capAddr, desc string) (code string) {
	lt := exp.Type.(*typeSys.ListType)
	n := len(exp.ListElems)

	if n == 0 {
		code += utils.Format("mov QWORD " + ptrAddr + ", 0; " + desc)
		code += utils.Format("mov QWORD " + lenAddr + ", 0")
		code += utils.Format("mov QWORD " + capAddr + ", 0")
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
			dataSection += "dq " + strLabel + "\n"
			dataSection += "dq " + strconv.Itoa(len(elem.StringVal)) + "\n"
			dataSection += "dq " + strconv.Itoa(len(elem.StringVal)) + "\n"
		} else {
			dataSection += "dq 0\n"
			if elemSize > 8 {
				for i := 8; i < elemSize; i += 8 {
					dataSection += "dq 0\n"
				}
			}
		}
	}

	code += utils.Format("; list literal [" + strconv.Itoa(n) + " elements]")
	code += "section .data\n" + dataSection + "section .text\n"

	code += utils.Format("mov QWORD " + ptrAddr + ", " + dataLabel + "; " + desc)
	code += utils.Format("mov QWORD " + lenAddr + ", " + strconv.Itoa(n))
	code += utils.Format("mov QWORD " + capAddr + ", " + strconv.Itoa(n))

	return
}

func (c *ExpCom) compileSliceFields(exp *parser.Expression, ptrAddr, lenAddr, capAddr, desc string) (code string) {
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

	reg := c.ctx.Reg.Get(c.ctx.Now, exp, ClassGPR, false)
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

	code += utils.Format("mov QWORD " + ptrAddr + ", " + reg.Name + "; " + desc)

	if startExpr != nil && endExpr != nil {
		if startExpr.IsConst() && endExpr.IsConst() {
			startVal := int(startExpr.Num)
			endVal := int(endExpr.Num)
			newLen := endVal - startVal
			code += utils.Format("mov QWORD " + lenAddr + ", " + strconv.Itoa(newLen))
			code += utils.Format("mov QWORD " + capAddr + ", " + strconv.Itoa(newLen))
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
			code += utils.Format("mov QWORD " + lenAddr + ", " + endResult)
			if startExpr.IsConst() {
				startVal := int(startExpr.Num)
				if startVal != 0 {
					code += utils.Format("sub QWORD " + lenAddr + ", " + strconv.Itoa(startVal))
				}
			}
			code += utils.Format("mov rax, QWORD " + lenAddr)
			code += utils.Format("mov QWORD " + capAddr + ", rax")
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
		code += utils.Format("mov QWORD " + lenAddr + ", " + endResult)
		code += utils.Format("mov QWORD " + capAddr + ", " + endResult)
	} else if startExpr != nil && endExpr == nil {
		if startExpr.IsConst() {
			startVal := int(startExpr.Num)
			srcAddr := GenVarAddr(exp.Left.Var)
			srcBaseOffset, ok := GetRbpOffset(srcAddr)
			if ok {
				srcLenAddr := MakeRbpAddr(srcBaseOffset + 8)
				srcCapAddr := MakeRbpAddr(srcBaseOffset + 16)
				code += utils.Format("mov rax, QWORD " + srcLenAddr)
				if startVal != 0 {
					code += utils.Format("sub rax, " + strconv.Itoa(startVal))
				}
				code += utils.Format("mov QWORD " + lenAddr + ", rax")
				code += utils.Format("mov rax, QWORD " + srcCapAddr)
				if startVal != 0 {
					code += utils.Format("sub rax, " + strconv.Itoa(startVal))
				}
				code += utils.Format("mov QWORD " + capAddr + ", rax")
			}
		}
	} else if startExpr == nil && endExpr == nil {
		srcAddr := GenVarAddr(exp.Left.Var)
		srcBaseOffset, ok := GetRbpOffset(srcAddr)
		if ok {
			srcLenAddr := MakeRbpAddr(srcBaseOffset + 8)
			srcCapAddr := MakeRbpAddr(srcBaseOffset + 16)
			code += utils.Format("mov rax, QWORD " + srcLenAddr)
			code += utils.Format("mov QWORD " + lenAddr + ", rax")
			code += utils.Format("mov rax, QWORD " + srcCapAddr)
			code += utils.Format("mov QWORD " + capAddr + ", rax")
		}
	}

	c.ctx.Reg.Free(exp)
	return
}

func (c *ExpCom) compileListLiteral(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	if len(exp.ListElems) == 0 {
		reg = c.ctx.Reg.Get(c.ctx.Now, exp, ClassGPR, false)
		if reg.StoreCode != "" {
			code += reg.StoreCode
		}
		code += utils.Format("xor " + reg.Name + ", " + reg.Name)
		code += utils.Format("mov QWORD [" + reg.Name + "+8], 0")
		code += utils.Format("mov QWORD [" + reg.Name + "+16], 0")
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
			dataSection += "dq " + strLabel + "\n"
			dataSection += "dq " + strconv.Itoa(len(elem.StringVal)) + "\n"
			dataSection += "dq " + strconv.Itoa(len(elem.StringVal)) + "\n"
		} else {
			dataSection += "dq 0\n"
			if elemSize > 8 {
				for i := 8; i < elemSize; i += 8 {
					dataSection += "dq 0\n"
				}
			}
		}
	}

	code += utils.Format("; list literal [" + strconv.Itoa(n) + " elements]")
	code += "section .data\n" + dataSection + "section .text\n"

	reg = c.ctx.Reg.Get(c.ctx.Now, exp, ClassGPR, false)
	if reg.StoreCode != "" {
		code += reg.StoreCode
	}
	code += utils.Format("mov " + reg.Name + ", " + dataLabel)
	code += utils.Format("mov QWORD [" + reg.Name + "+8], " + strconv.Itoa(n))
	code += utils.Format("mov QWORD [" + reg.Name + "+16], " + strconv.Itoa(n))

	return
}

func (c *ExpCom) compileIndexAccess(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	// exp.Right is the list being indexed, exp.Index[0] is the index
	lt := exp.Right.Type.(*typeSys.ListType)
	elemSize := lt.Elem().Size()

	var listCode, listResult string
	var listReg *regmgr.Reg
	if exp.Right.IsConst() {
		listCode, listResult = c.CompileExprVal(exp.Right)
	} else {
		listCode, listReg = c.CompileExprChildren(exp.Right)
		if listReg != nil {
			listResult = listReg.Name
		} else {
			listCode2, listResult2 := c.CompileExprVal(exp.Right)
			listCode += listCode2
			listResult = listResult2
		}
	}
	code += listCode

	reg = c.ctx.Reg.Get(c.ctx.Now, exp, ClassGPR, false)
	if reg.StoreCode != "" {
		code += reg.StoreCode
	}

	if listReg != nil && reg.Name == listReg.Name {
		code += utils.Format("; load list ptr (already in " + reg.Name + ")")
	} else {
		code += utils.Format("mov " + reg.Name + ", " + listResult + "; load list ptr")
	}

	idxExpr := exp.Index[0]
	if idxExpr.IsConst() {
		idx := int(idxExpr.Num)
		byteOffset := idx * elemSize
		if byteOffset != 0 {
			code += utils.Format("add " + reg.Name + ", " + strconv.Itoa(byteOffset) + "; ptr += index*elemSize")
		}
	} else {
		var indexCode, indexResult string
		var indexReg *regmgr.Reg
		indexCode, indexReg = c.CompileExprChildren(idxExpr)
		if indexReg != nil {
			indexResult = indexReg.Name
		} else {
			indexCode2, indexResult2 := c.CompileExprVal(idxExpr)
			indexCode += indexCode2
			indexResult = indexResult2
		}
		code += indexCode
		code += utils.Format("imul " + indexResult + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + reg.Name + ", " + indexResult)
		if indexReg != nil {
			c.ctx.Reg.Free(idxExpr)
		}
	}

	sizePrefix := GetLenName(elemSize)
	code += utils.Format("mov " + reg.Name + ", " + sizePrefix + "[" + reg.Name + "]; load element")

	return
}

func (c *ExpCom) compileIndexSet(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	// exp.Left is the index expression (list[idx]), exp.Right is the value
	indexExpr := exp.Left
	lt := indexExpr.Right.Type.(*typeSys.ListType)
	elemSize := lt.Elem().Size()

	var listCode, listResult string
	if indexExpr.Right.IsConst() {
		listCode, listResult = c.CompileExprVal(indexExpr.Right)
	} else {
		var listReg *regmgr.Reg
		listCode, listReg = c.CompileExprChildren(indexExpr.Right)
		if listReg != nil {
			listResult = listReg.Name
			c.ctx.Reg.Free(indexExpr.Right)
		} else {
			listCode2, listResult2 := c.CompileExprVal(indexExpr.Right)
			listCode += listCode2
			listResult = listResult2
		}
	}
	code += listCode

	addrReg := c.ctx.Reg.Get(c.ctx.Now, exp, ClassGPR, false)
	if addrReg.StoreCode != "" {
		code += addrReg.StoreCode
	}

	code += utils.Format("mov " + addrReg.Name + ", " + listResult + "; load list ptr")

	idxExpr := indexExpr.Index[0]
	if idxExpr.IsConst() {
		idx := int(idxExpr.Num)
		byteOffset := idx * elemSize
		if byteOffset != 0 {
			code += utils.Format("add " + addrReg.Name + ", " + strconv.Itoa(byteOffset) + "; ptr += index*elemSize")
		}
	} else {
		var indexCode, indexResult string
		var indexReg *regmgr.Reg
		indexCode, indexReg = c.CompileExprChildren(idxExpr)
		if indexReg != nil {
			indexResult = indexReg.Name
			c.ctx.Reg.Free(idxExpr)
		} else {
			indexCode2, indexResult2 := c.CompileExprVal(idxExpr)
			indexCode += indexCode2
			indexResult = indexResult2
		}
		code += indexCode
		code += utils.Format("imul " + indexResult + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + addrReg.Name + ", " + indexResult)
	}

	var valCode, valResult string
	if exp.Right.IsConst() {
		valCode, valResult = c.CompileExprVal(exp.Right)
	} else {
		var valReg *regmgr.Reg
		valCode, valReg = c.CompileExprChildren(exp.Right)
		if valReg != nil {
			valResult = valReg.Name
		} else {
			valCode2, valResult2 := c.CompileExprVal(exp.Right)
			valCode += valCode2
			valResult = valResult2
		}
	}
	code += valCode

	sizePrefix := GetLenName(elemSize)
	code += utils.Format("mov " + sizePrefix + "[" + addrReg.Name + "], " + valResult + "; store element")

	c.ctx.Reg.Free(exp)

	reg = nil
	return
}

func (c *ExpCom) compileSlice(exp *parser.Expression) (code string, reg *regmgr.Reg) {
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

	reg = c.ctx.Reg.Get(c.ctx.Now, exp, ClassGPR, false)
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
		code += utils.Format("mov QWORD [" + reg.Name + "+8], " + endResult)
	}

	return
}
