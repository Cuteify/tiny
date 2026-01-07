package x86

import (
	"cuteify/compile/arch"
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
	regmgr       *regmgr.RegMgr
	expType      int
	now          *parser.Node // 当前节点，指向正在编译的AST节点
	arch         arch.Arch
	useEBXDirect bool // 标记是否直接使用 EBX（不通过寄存器分配）
	ebxOccupied  bool // 标记 EBX 是否已被左子占用
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
			// push后立即释放寄存器，避免被SaveAll溢出
			c.regmgr.Free(exp)
		} else {
			formattedTarget := result
			if formattedTarget != reg.Name {
				code += utils.Format("mov " + formattedTarget + ", " + reg.Name + "; " + desc)
			} else {
				code = code[:len(code)-1] // 去除原先的换行
				code += "; " + desc + "\n"
			}
		}
	}
	return
}

func (c *expCom) CompileExprChildren(exp *parser.Expression) (code string, reg *regmgr.Reg) {
	// 末端子节点处理，递归终止
	if exp.Separator == "" {
		tmp, resultVal := c.CompileExprVal(exp)
		code += tmp
		reg = c.regmgr.Get(c.now, exp, false)

		// 如果 EBX 已被占用（左子使用），重新分配到其他寄存器
		if c.ebxOccupied && reg != nil && reg.Name == "EBX" {
			// 释放 EBX
			c.regmgr.Free(exp)
			// 重新获取寄存器（Get 会跳过锁定的 EBX）
			reg = c.regmgr.Get(c.now, exp, false)
		}

		if reg.StoreCode != "" {
			code += reg.StoreCode
		}
		formattedResult := resultVal
		if reg.Name != formattedResult {
			code += utils.Format("mov " + reg.Name + ", " + formattedResult)
		}
		return
	}

	// 处理子节点
	var leftReg *regmgr.Reg
	var rightReg *regmgr.Reg
	var leftCode, leftResult string
	var rightCode, rightResult string

	// 左子
	if exp.Left != nil {
		// 优化：如果左子是函数调用且右子也有函数调用，直接把返回值移到 EBX
		if exp.Left.Call != nil && exp.Right != nil && c.containsCall(exp.Right) {
			// 设置标志，让 CompileExprVal 直接使用 EBX
			c.useEBXDirect = true
			leftCode, leftResult = c.CompileExprVal(exp.Left)
			c.useEBXDirect = false
			leftReg = nil // 不需要寄存器对象，因为直接用 EBX

			// 锁定 EBX，防止被右子分配使用
			c.regmgr.Force(&regmgr.Reg{Name: "EBX", RegIndex: 1}, c.now, exp.Left)
		} else if exp.Left.IsConst() {
			leftCode, leftResult = c.CompileExprVal(exp.Left)
		} else {
			leftCode, leftReg = c.CompileExprChildren(exp.Left)
			leftResult = leftReg.Name
		}
	}

	// 关键修改：如果右子包含函数调用，把左子结果移到 EBX（如果不是函数调用的情况）
	if exp.Right != nil && c.containsCall(exp.Right) {
		if exp.Left == nil || exp.Left.Call == nil {
			// 左子不是函数调用，需要手动移到 EBX
			code += leftCode
			// 释放左子寄存器（如果有的话）
			if leftReg != nil {
				c.regmgr.Free(exp.Left)
			}
			code += utils.Format("mov EBX, " + leftResult + "; 保存中间结果到EBX(callee-save)")
			leftResult = "EBX"
		} else {
			code += leftCode
		}
	} else {
		code += leftCode
	}

	// 右子
	if exp.Right != nil {
		// 如果左子结果在 EBX 中，设置标志防止右子使用 EBX
		if leftResult == "EBX" {
			c.ebxOccupied = true
		}

		if exp.Right.IsConst() {
			rightCode, rightResult = c.CompileExprVal(exp.Right)
		} else {
			rightCode, rightReg = c.CompileExprChildren(exp.Right)
			rightResult = rightReg.Name
		}

		// 重置 EBX 占用标志
		c.ebxOccupied = false
	}
	code += rightCode

	// 节点处理
	if exp.Separator != "" {
		// 特殊处理：如果左子结果在 EBX 中（我们手动设置的），直接使用 EBX
		if leftResult == "EBX" && leftReg == nil {
			// 释放右子寄存器（如果有的话）
			if rightReg != nil {
				c.regmgr.Free(exp.Right)
			}

			// 计算前格式化src（如果是内存地址则需要大小前缀）
			formattedSrc := rightResult

			// 直接生成计算指令，使用 EBX 作为目标
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

			// 解锁 EBX（之前为了保护左子结果锁定了）
			c.regmgr.Free(exp.Left)

			// 返回 EBX 作为结果寄存器
			reg = &regmgr.Reg{Name: "EBX"}
		} else {
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
				// leftResult可能是常量或内存地址，需要格式化
				formattedLeft := leftResult
				code += utils.Format("mov " + reg.Name + ", " + formattedLeft)
				src = rightResult
			}

			// 计算前格式化src（如果是内存地址则需要大小前缀）
			formattedSrc := src

			// 计算
			switch exp.Separator {
			case "+":
				code += utils.Format("add " + reg.Name + ", " + formattedSrc)
			case "-":
				code += utils.Format("sub " + reg.Name + ", " + formattedSrc)
			case "*":
				code += utils.Format("imul " + reg.Name + ", " + formattedSrc)
			case "/":
				// idiv需要edx:eax作为被除数，需要先清零edx
				code += utils.Format("xor edx, edx")
				code += utils.Format("mov eax, " + reg.Name)
				code += utils.Format("idiv " + formattedSrc)
				code += utils.Format("mov " + reg.Name + ", eax")
			case "%":
				// 取模运算
				code += utils.Format("xor edx, edx")
				code += utils.Format("mov eax, " + reg.Name)
				code += utils.Format("idiv " + formattedSrc)
				code += utils.Format("mov " + reg.Name + ", edx")
			}
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
			c.regmgr.Free(exp.Left)
		}
		if exp.Right != nil {
			c.regmgr.Free(exp.Right)
		}
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
			// 根据偏移量生成内存地址（NASM格式：[ebp+offset]）
			addr := ""
			if exp.Var.Offset < 0 {
				addr = "[ebp" + strconv.FormatInt(int64(exp.Var.Offset), 10) + "]"
			} else if exp.Var.Offset == 0 {
				addr = "[ebp]"
			} else {
				addr = "[ebp+" + strconv.FormatInt(int64(exp.Var.Offset), 10) + "]"
			}
			// NASM格式：dword [ebp-4] 而不是 DWORD[ebp-4]
			result = addr
		}
	} else if exp.Call != nil {
		code = c.arch.Call(exp.Call)
		//c.regmgr.Force(&regmgr.Reg{Name: "EAX"}, c.now, exp)
		result = "EAX"
		// 如果标记为直接使用 EBX，生成 mov EBX, EAX
		if c.useEBXDirect {
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
