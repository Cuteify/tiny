package compile

import (
	"cuteify/parser"
	typeSys "cuteify/type"
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

// CompileExpr 编译表达式节点
// 参数:
//   - exp: 要编译的表达式节点
//   - result: 结果存储位置（寄存器或内存地址）
//   - desc: 指令描述信息
//
// 返回:
//   - code: 生成的汇编代码
func (c *Compiler) CompileExpr(exp *parser.Expression, result, desc string) (code string) {
	// 如果是常量表达式且没有父节点，则直接编译值
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

	// 如果表达式为空、是常量或者没有左右子表达式，则直接返回
	if exp == nil || exp.IsConst() || exp.Right == nil && exp.Left == nil {
		return
	}

	// 编译左右子表达式的值
	leftCode, leftResult := c.CompileExprVal(exp.Left)
	rightCode, rightResult := c.CompileExprVal(exp.Right)
	var leftReg *Reg
	var rightReg *Reg

	// 如果左子表达式不为空且不是常量
	if exp.Left != nil && !exp.Left.IsConst() {
		// 如果是布尔类型表达式
		if exp.Left.Type.Type() != "bool" && exp.Left.Separator != "" {
			leftReg = c.Reg.GetRegister(c.Now, exp.Left)
			leftResult = leftReg.Name
			if leftReg.StoreCode != "" {
				code += Format(leftReg.StoreCode)
			}
		}
		// 递归编译左子表达式
		leftCode = c.CompileExpr(exp.Left, leftResult, desc)
	}

	// 如果右子表达式不为空且不是常量
	if exp.Right != nil && !exp.Right.IsConst() && exp.Right.Separator != "" {
		// 如果是布尔类型表达式
		if exp.Right.Type.Type() != "bool" {
			rightReg = c.Reg.GetRegister(c.Now, exp.Left)
			rightResult = rightReg.Name
			if rightReg.StoreCode != "" {
				code += Format(rightReg.StoreCode)
			}
		}
		// 递归编译右子表达式
		rightCode = c.CompileExpr(exp.Right, rightResult, desc)
	}

	// 添加左右子表达式的代码
	code += leftCode
	code += rightCode

	// 如果左右子表达式都不为空
	if exp.Left != nil && exp.Right != nil {
		// 如果是布尔类型表达式
		if exp.Type.Type() == "bool" {
			code += Format("cmp " + leftResult + ", " + rightResult + "; 比较表达式的值")
			switch c.ExpType {
			case OrExp:
				// 逻辑或表达式处理

			case AndExp:
				// 逻辑与表达式处理

			default:
				// 比较表达式处理
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
			var reg *Reg
			if leftReg == nil {
				// 获取寄存器用于存储计算结果
				reg = c.Reg.GetRegister(c.Now, exp)
				if reg.StoreCode != "" {
					code += Format(reg.StoreCode)
				}
				if result == "" {
					panic("没有指定结果寄存器")
				}

				// 根据操作符生成对应的汇编指令
				code += Format("mov " + reg.Name + ", " + leftResult + "; 保存表达式左边的值")
			} else {
				reg = leftReg
			}
			switch exp.Separator {
			case "+":
				code += Format("add " + reg.Name + ", " + rightResult + "; 计算表达式的值")
			case "-":
				code += Format("sub " + reg.Name + ", " + rightResult + "; 计算表达式的值")
			case "*":
				code += Format("imul " + reg.Name + ", " + rightResult + "; 计算表达式的值")
			case "/":
				code += Format("idiv " + reg.Name + ", " + rightResult + "; 计算表达式的值")
			case "%": // 取模运算
				code += Format("idiv " + reg.Name + ", " + rightResult + "; 计算表达式的值")
			}

			if result != reg.Name {
				// 将结果移动到目标位置
				code += Format("mov " + result + ", " + reg.Name + "; " + desc)
			}

			c.Reg.FreeRegister(exp)
		}
	}

	// 释放左子表达式的寄存器
	c.Reg.FreeRegister(exp.Left)

	// 释放右子表达式的寄存器
	c.Reg.FreeRegister(exp.Right)
	return
}

// CompileExprVal 编译表达式的值
// 将表达式节点转换为汇编代码中的立即数、寄存器或内存地址
// 参数:
//   - exp: 要编译的表达式节点
//
// 返回:
//   - code: 生成的汇编代码（通常为空）
//   - result: 表达式的值表示（立即数、寄存器名或内存地址）
func (c *Compiler) CompileExprVal(exp *parser.Expression) (code, result string) {
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

		if rInfo := c.Reg.ReuseNode(exp.Var.Define); rInfo != nil {
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
			result = getLengthName(exp.Var.Type.Size()) + addr
		}
	} else if exp.Call != nil {
		// 如果是函数调用表达式（此处未实现完整逻辑）

	}
	return
}
