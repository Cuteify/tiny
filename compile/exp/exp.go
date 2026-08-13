// Package exp 表达式编译器
package exp

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"cuteify/utils"
	"strconv"
	"strings"
)

// ECompiler 表达式编译器
type ECompiler struct {
	ctx        *context.Context
	arch       arch.Arch
	expInfo    map[*parser.Expression]*ExpInfo // 表达式信息
	expCounter int                             // 表达式 ID 计数器
	expIDMap   map[string]int                  // 结构 key -> ID
	idx        int                             // BindIndex 计数器
}

// New 创建表达式编译器
func New(ctx *context.Context) *ECompiler {
	return &ECompiler{
		ctx:      ctx,
		arch:     ctx.Arch,
		expInfo:  make(map[*parser.Expression]*ExpInfo),
		expIDMap: make(map[string]int),
	}
}

// Compile 编译表达式（两趟流程）
func (c *ECompiler) Compile(exp *parser.Expression, result, desc string) string {
	if exp == nil {
		return ""
	}

	// 重置状态
	c.expInfo = make(map[*parser.Expression]*ExpInfo)
	c.expCounter = 0
	c.idx = 0

	// 第一趟：收集信息
	c.Collect(exp)

	// 第二趟：生成代码
	code := c.generate(exp, result)

	if code != "" {
		code += "; " + desc + "\n"
	}
	return code
}

// generate 第二趟：自顶向下生成代码（含 BindIndex 分配）
func (c *ECompiler) generate(exp *parser.Expression, result string) string {
	if exp == nil {
		return ""
	}

	// 分配当前节点的 BindIndex
	ei := c.expInfo[exp]
	ei.BindIndex = c.idx
	c.idx++

	// 叶子节点
	if exp.Separator == "" {
		return c.leaf(exp, result)
	}

	// 一元运算：只有 Right 子节点，Left 为 nil
	if exp.Left == nil && exp.Right != nil {
		return c.unary(exp, result, ei)
	}

	// 二元运算：按 SU 顺序处理子节点（先处理 MinPeak 大的子树）
	li, ri := ei.Left, ei.Right

	// 保护 nil 子节点
	if li == nil || ri == nil {
		return ""
	}

	if li.MinPeak >= ri.MinPeak {
		return c.binLR(exp, result, ei)
	}
	return c.binRL(exp, result, ei)
}

// leaf 编译叶子节点
func (c *ECompiler) leaf(exp *parser.Expression, result string) string {
	// 特殊处理函数调用：需要先生成 call 指令
	if exp.Call != nil {
		code := c.arch.Call(exp.Call)
		val := c.arch.ReturnReg() // 函数返回值寄存器（EAX/RAX）
		if result == "push" {
			return code + utils.Format("push "+val)
		}
		if result != val {
			// 目标为 32 位内存槽时使用 EAX（x86_64 下 RAX 写入 DWORD 槽非法）
			if strings.Contains(result, "DWORD[") && strings.HasPrefix(val, "R") {
				val = "EAX"
			}
			return code + utils.Format("mov "+result+", "+val)
		}
		return code
	}

	val := c.val(exp)
	if result == "push" {
		return utils.Format("push " + val)
	}
	if result != val {
		// 32 位内存源装载到 64 位寄存器：改用 32 位寄存器名
		if strings.Contains(val, "DWORD[") && strings.HasPrefix(result, "R") {
			result = "E" + result[1:]
		}
		// 内存到内存：无法直接 mov，需要经寄存器中转
		if strings.Contains(val, "[") && strings.Contains(result, "[") {
			tmp := c.arch.ReturnReg()
			if reg := c.allocReg(exp); reg != nil {
				tmp = reg.Name
			}
			// 32 位内存源中转也需匹配宽度
			if strings.Contains(val, "DWORD[") && strings.HasPrefix(tmp, "R") {
				tmp = "E" + tmp[1:]
			}
			code := utils.Format("mov " + tmp + ", " + val)
			code += utils.Format("mov " + result + ", " + tmp)
			c.ctx.Reg.Free(exp)
			return code
		}
		return utils.Format("mov " + result + ", " + val)
	}
	return ""
}

// val 获取表达式的值（不生成代码）
func (c *ECompiler) val(exp *parser.Expression) string {
	if exp.IsConst() {
		return strconv.FormatFloat(exp.Num, 'f', -1, 64)
	}
	if exp.Var != nil {
		return c.arch.VarAddr(exp.Var)
	}
	if exp.Call != nil {
		return c.arch.ReturnReg() // 返回值寄存器（EAX/RAX）
	}
	return ""
}

// unary 编译一元运算符
func (c *ECompiler) unary(exp *parser.Expression, result string, ei *ExpInfo) string {
	// 分配右子寄存器
	rReg := c.allocReg(exp.Right)
	if rReg == nil {
		rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	rCode := c.generate(exp.Right, rReg.Name)

	// 生成一元运算指令
	code := rCode + c.emitUnary(exp, result, rReg)

	// 释放子节点寄存器
	c.ctx.Reg.Free(exp.Right)

	return code
}

// emitUnary 生成一元运算指令
func (c *ECompiler) emitUnary(exp *parser.Expression, result string, rReg *regmgr.Reg) string {
	rVal := rReg.Name
	var code string

	// 特殊处理 push：就地计算到操作数寄存器，再 push
	// （不用返回值寄存器当临时寄存器，避免与操作数/外部活跃值同寄存器）
	if result == "push" {
		if exp.Separator == "!" {
			code = utils.Format("cmp " + rVal + ", 0")
			code += utils.Format("sete " + lo8(rVal))
			code += utils.Format("movzx " + rVal + ", " + lo8(rVal))
			code += utils.Format("push " + rVal)
			return code
		}
		code = c.emitUnaryOp(rVal, exp.Separator, rVal)
		code += utils.Format("push " + rVal)
		return code
	}

	// 逻辑非：就地改写操作数寄存器（movzx 需要寄存器目标）
	if exp.Separator == "!" {
		code = utils.Format("cmp " + rVal + ", 0")
		code += utils.Format("sete " + lo8(rVal))
		code += utils.Format("movzx " + rVal + ", " + lo8(rVal))
		if result != rVal {
			code += utils.Format("mov " + result + ", " + rVal)
		}
		return code
	}

	// 普通情况
	if result == rVal {
		code = c.emitUnaryOp(rVal, exp.Separator, rVal)
	} else {
		code = utils.Format("mov " + result + ", " + rVal)
		code += c.emitUnaryOp(result, exp.Separator, result)
	}

	return code
}

// emitUnaryOp 生成一元运算指令
func (c *ECompiler) emitUnaryOp(dst, op, src string) string {
	switch op {
	case "-":
		return utils.Format("neg " + src)
	case "~":
		return utils.Format("not " + src)
	case "!":
		// 逻辑非：与 0 比较，结果为 0 或 1
		code := utils.Format("cmp " + src + ", 0")
		code += utils.Format("sete " + lo8(src)) // 使用 setXX 指令设置结果
		code += utils.Format("movzx " + dst + ", " + lo8(src))
		return code
	default:
		return ""
	}
}

// lo8 返回寄存器名的低8位寄存器名（sete/movzx 需要）
func lo8(name string) string {
	switch strings.ToUpper(name) {
	case "EAX", "RAX":
		return "al"
	case "EBX", "RBX":
		return "bl"
	case "ECX", "RCX":
		return "cl"
	case "EDX", "RDX":
		return "dl"
	case "ESI", "RSI":
		return "sil"
	case "EDI", "RDI":
		return "dil"
	case "R8":
		return "r8b"
	case "R9":
		return "r9b"
	case "R10":
		return "r10b"
	case "R11":
		return "r11b"
	case "R12":
		return "r12b"
	case "R13":
		return "r13b"
	case "R14":
		return "r14b"
	case "R15":
		return "r15b"
	}
	return "al"
}

// binLR 先左后右
func (c *ECompiler) binLR(exp *parser.Expression, result string, ei *ExpInfo) string {
	calleeName := c.arch.CalleeSaveReg()

	// 左子：result 为寄存器/内存时就地计算到 result（左链只需 2 个寄存器），
	// 避免每层额外占一个寄存器导致寄存器压力随深度增长；
	// push 或 result 与 callee-save 冲突时退回分配独立寄存器
	lVal := result
	inPlace := result != "push" && !(ei.Right.HasCall && result == calleeName)

	// 就地且 result 是空闲寄存器：绑定到左子，使右子分配避开（结果值仍在使用）
	if inPlace && !strings.Contains(result, "[") {
		if regObj := c.getRegByName(result); regObj != nil && regObj.Free {
			c.ctx.Reg.Force(regObj, exp.Left)
		}
	}

	var lCode string
	if inPlace {
		lCode = c.generate(exp.Left, result)
	} else {
		lReg := c.allocRegAvoid(exp.Left, result)
		if lReg == nil {
			lReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		lVal = lReg.Name
		lCode = c.generate(exp.Left, lVal)
	}

	// 如果右子有调用，保存左子结果到 callee-save
	callee := ""
	if ei.Right.HasCall {
		callee = calleeName
		lCode += utils.Format("mov " + callee + ", " + lVal)
		// 先释放左子原寄存器，再绑定 callee 寄存器（值已转移到 callee）
		c.ctx.Reg.Free(exp.Left)
		if calleeReg := c.getRegByName(callee); calleeReg != nil {
			c.ctx.Reg.Force(calleeReg, exp.Left)
		}
		lVal = callee
	}

	// 分配右子寄存器（避开 result 寄存器：emitBin 末尾会写 result）
	rReg := c.allocRegAvoid(exp.Right, result)
	if rReg == nil {
		rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
	}
	rCode := c.generate(exp.Right, rReg.Name)

	// 生成运算指令
	code := lCode + rCode + c.emitBin(exp, result, lVal, rReg.Name, callee)

	// 释放子节点寄存器（就地且非 callee 时保留绑定：结果值仍在使用）
	if !inPlace || callee != "" {
		c.ctx.Reg.Free(exp.Left)
	}
	c.ctx.Reg.Free(exp.Right)

	return code
}

// binRL 先右后左
func (c *ECompiler) binRL(exp *parser.Expression, result string, ei *ExpInfo) string {
	calleeName := c.arch.CalleeSaveReg()

	// 分配右子寄存器（避开 result 寄存器：左子就地写入 result）
	rReg := c.allocRegAvoid(exp.Right, result)
	if rReg == nil {
		rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
	}
	rCode := c.generate(exp.Right, rReg.Name)

	// 如果左子有调用，保存右子结果到 callee-save
	callee := ""
	rVal := rReg.Name
	if ei.Left.HasCall {
		callee = calleeName
		rCode += utils.Format("mov " + callee + ", " + rReg.Name)
		// 先释放右子原寄存器，再绑定 callee 寄存器（值已转移到 callee）
		c.ctx.Reg.Free(exp.Right)
		if calleeReg := c.getRegByName(callee); calleeReg != nil {
			c.ctx.Reg.Force(calleeReg, exp.Right)
		}
		rVal = callee
	}

	// 左子：就地计算到 result（push 或与 callee-save 冲突时退回分配独立寄存器）
	lVal := result
	inPlace := result != "push" && !(ei.Left.HasCall && result == calleeName)

	// 就地且 result 是空闲寄存器：绑定到左子，使右子分配避开（结果值仍在使用）
	if inPlace && !strings.Contains(result, "[") {
		if regObj := c.getRegByName(result); regObj != nil && regObj.Free {
			c.ctx.Reg.Force(regObj, exp.Left)
		}
	}

	var lCode string
	if inPlace {
		lCode = c.generate(exp.Left, result)
	} else {
		lReg := c.allocRegAvoid(exp.Left, result)
		if lReg == nil {
			lReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		lVal = lReg.Name
		lCode = c.generate(exp.Left, lVal)
	}

	// 生成运算指令
	code := rCode + lCode + c.emitBin(exp, result, lVal, rVal, callee)

	// 释放子节点寄存器（左子就地且非 callee 时保留绑定：结果值仍在使用）
	if !inPlace || callee != "" {
		c.ctx.Reg.Free(exp.Left)
	}
	c.ctx.Reg.Free(exp.Right)

	return code
}

// allocReg 分配寄存器（带偏好和避免）
func (c *ECompiler) allocReg(exp *parser.Expression) *regmgr.Reg {
	return c.allocRegAvoid(exp, "")
}

// allocRegAvoid 分配寄存器；avoidReg 为必须避开的寄存器名（该寄存器中的值仍在使用）
func (c *ECompiler) allocRegAvoid(exp *parser.Expression, avoidReg string) *regmgr.Reg {
	ei := c.expInfo[exp]

	// 构建 avoid：当前节点之后的硬绑定掩码
	avoidMask := uint32(0)
	for e, info := range c.expInfo {
		if info.BindIndex > ei.BindIndex {
			avoidMask |= info.HardBindMask
			_ = e
		}
	}

	// 默认掩码（普通表达式也可用 GPR）+ 硬绑定掩码（除法/取模需要 EAX/EDX）
	mask := c.ctx.Arch.DefaultRegMask() | ei.HardBindMask

	// 转换为 prefer/avoid 数组
	prefer := make([]int, len(c.ctx.Reg.Regs))
	avoid := make([]int, len(c.ctx.Reg.Regs))
	for _, reg := range c.ctx.Reg.Regs {
		if reg.ClassMask&mask != 0 {
			prefer[reg.RegIndex] = 10 // 高偏好
		}
		if reg.ClassMask&avoidMask != 0 {
			avoid[reg.RegIndex] = 10 // 高厌恶
		}
	}

	return c.ctx.Reg.AllocPref(
		exp,
		mask,
		prefer,
		avoid,
		ei.ExpID,
		nil, // user 暂时为空
		avoidReg,
	)
}

// getRegByName 根据寄存器名称获取寄存器对象
func (c *ECompiler) getRegByName(name string) *regmgr.Reg {
	for _, reg := range c.ctx.Reg.Regs {
		if reg.Name == name {
			return reg
		}
	}
	return nil
}

// emitBin 生成二元运算指令。
// lVal/rVal 为左右操作数（寄存器名或内存地址），result 为结果目标。
func (c *ECompiler) emitBin(exp *parser.Expression, result, lVal, rVal, callee string) string {
	var code string

	// 特殊处理 push：就地计算到左操作数寄存器，再 push
	// （不用临时寄存器，避免临时寄存器与右操作数同寄存器导致 sub eax,eax 类错误）
	if result == "push" {
		if callee != "" && lVal != callee {
			code = c.arch.InstBinary(lVal, exp.Separator, callee)
		} else {
			code = c.arch.InstBinary(lVal, exp.Separator, rVal)
		}
		code += utils.Format("push " + lVal)
		return code
	}

	// 如果有 callee-save，使用它
	if callee != "" {
		if lVal == callee {
			// 左在 callee-save：先搬到 result，再运算
			if result != callee {
				code = utils.Format("mov " + result + ", " + callee)
			}
			code += c.arch.InstBinary(result, exp.Separator, rVal)
		} else {
			// 右在 callee-save
			if result != lVal {
				code = utils.Format("mov " + result + ", " + lVal)
			}
			code += c.arch.InstBinary(result, exp.Separator, callee)
		}
	} else {
		// 普通情况
		if result == lVal {
			// 结果直接写到左操作数寄存器
			code = c.arch.InstBinary(lVal, exp.Separator, rVal)
		} else {
			// 需要先 mov 左操作数到 result，再运算
			code = utils.Format("mov " + result + ", " + lVal)
			code += c.arch.InstBinary(result, exp.Separator, rVal)
		}
	}

	return code
}
