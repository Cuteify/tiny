// Package exp 表达式编译器
package exp

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
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

	// 解引用赋值：deref=(值, 指针)
	if exp.Separator == "deref=" {
		return c.derefSet(exp)
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
				// 目标为窄内存槽时源寄存器名匹配槽宽度（RAX→AL/AX/EAX）
				if strings.Contains(result, "[") {
					val = matchMemWidth(result, val)
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
		// 内存到内存：无法直接 mov，需要经寄存器中转（两端宽度匹配）
		if strings.Contains(val, "[") && strings.Contains(result, "[") {
			tmp := c.arch.ReturnReg()
			if reg := c.allocReg(exp); reg != nil {
				tmp = reg.Name
			}
			var code string
			// 宽度匹配装载：BYTE/WORD → movzx，DWORD → 32 位名，QWORD 直接
			switch memPrefix(val) {
			case "BYTE", "WORD":
				code += utils.Format("movzx " + tmp + ", " + val)
			case "DWORD":
				code += utils.Format("mov " + eName(tmp) + ", " + val)
			default:
				code += utils.Format("mov " + tmp + ", " + val)
			}
			code += utils.Format("mov " + result + ", " + matchMemWidth(result, tmp))
			c.ctx.Reg.Free(exp)
			return code
		}
		// 寄存器 → 窄内存槽：源寄存器名匹配槽宽度
		if strings.Contains(result, "[") && isRegLike(val) {
			val = matchMemWidth(result, val)
		} else if strings.Contains(val, "[") {
			// 内存 → 寄存器：BYTE/WORD 需 movzx（零扩展），DWORD 用 32 位名
			switch memPrefix(val) {
			case "BYTE", "WORD":
				return utils.Format("movzx " + result + ", " + val)
			case "DWORD":
				if strings.HasPrefix(result, "R") {
					result = "E" + result[1:]
				}
			}
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
	// 取地址：直接 lea 变量地址，无需生成右子代码
	if exp.Separator == "&" {
		return c.emitAddrOf(exp, result)
	}

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
			code += utils.Format("mov " + result + ", " + matchMemWidth(result, rVal))
		}
		return code
	}

	// 解引用读：[src] → dst
	if exp.Separator == "*" {
		prefix := c.derefPrefix(exp.Right.Type)
		if result == "push" {
			code = c.derefLoad(prefix, rVal, rVal)
			code += utils.Format("push " + rVal)
			return code
		}
		return c.derefLoad(prefix, result, rVal)
	}

	// 普通情况
	if result == rVal {
		code = c.emitUnaryOp(rVal, exp.Separator, rVal)
	} else {
		code = utils.Format("mov " + result + ", " + matchMemWidth(result, rVal))
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

// emitAddrOf 生成取地址指令：lea result, [变量地址]
func (c *ECompiler) emitAddrOf(exp *parser.Expression, result string) string {
	if exp.Right == nil || exp.Right.Var == nil {
		return ""
	}
	// lea 需要裸地址：剥离 VarAddr 的宽度前缀（BYTE/WORD/DWORD/QWORD）
	addr := stripMemPrefix(c.arch.VarAddr(exp.Right.Var))

	// push：经临时寄存器中转
	if result == "push" || strings.Contains(result, "[") {
		rReg := c.allocReg(exp)
		if rReg == nil {
			rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		code := utils.Format("lea " + rReg.Name + ", " + addr)
		if result == "push" {
			code += utils.Format("push " + rReg.Name)
		} else {
			code += utils.Format("mov " + result + ", " + rReg.Name)
		}
		c.ctx.Reg.Free(exp)
		return code
	}

	return utils.Format("lea " + result + ", " + addr)
}

// derefSet 编译解引用赋值 *addr = value（节点形状 deref=(值, 指针)）。
func (c *ECompiler) derefSet(exp *parser.Expression) string {
	ei := c.expInfo[exp]
	calleeName := c.arch.CalleeSaveReg()

	// 1. 计算值到 vReg
	vReg := c.allocReg(exp.Left)
	if vReg == nil {
		vReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code := c.generate(exp.Left, vReg.Name)

	// 指针侧含调用时，把值保存到 callee-save 寄存器（call 会破坏 caller-saved）
	vVal := vReg.Name
	callee := ""
	if ei.Right.HasCall {
		callee = calleeName
		code += utils.Format("mov " + callee + ", " + vReg.Name)
		c.ctx.Reg.Free(exp.Left)
		if calleeReg := c.getRegByName(callee); calleeReg != nil {
			c.ctx.Reg.Force(calleeReg, exp.Left)
		}
		vVal = callee
	}

	// 2. 计算指针到 pReg（避开值寄存器）
	pReg := c.allocRegAvoid(exp.Right, vReg.Name)
	if pReg == nil {
		pReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
	}
	code += c.generate(exp.Right, pReg.Name)

	// 3. 写入：[p] = v
	prefix := c.derefPrefix(exp.Right.Type)
	code += c.derefStore(prefix, pReg.Name, vVal)

	c.ctx.Reg.Free(exp.Left)
	c.ctx.Reg.Free(exp.Right)
	return code
}

// derefPrefix 返回解引用类型的内存操作宽度前缀（BYTE/WORD/DWORD/QWORD）。
// 真实指针（IsPointer）的宽度取被指类型 Elem 的大小；
// 系统 ptr 是地址号类型（无元素信息），宽度即指针大小。
func (c *ECompiler) derefPrefix(t typeSys.Type) string {
	if t == nil {
		return ""
	}
	if t.IsPointer() {
		if elem := t.Elem(); elem != nil {
			return c.arch.LengthName(elem.Size())
		}
		return c.arch.LengthName(c.arch.PointerSize())
	}
	if t.Type() == "ptr" {
		return c.arch.LengthName(c.arch.PointerSize())
	}
	return c.arch.LengthName(t.Size())
}

// memPrefix 返回内存操作数的宽度前缀（BYTE/WORD/DWORD/QWORD），非内存返回空串。
// 使用 HasPrefix 而非 Contains 匹配，避免 QWORD[ 误匹配 WORD[。
func memPrefix(mem string) string {
	m := strings.TrimSpace(mem)
	switch {
	case strings.HasPrefix(m, "BYTE["):
		return "BYTE"
	case strings.HasPrefix(m, "WORD["):
		return "WORD"
	case strings.HasPrefix(m, "DWORD["):
		return "DWORD"
	case strings.HasPrefix(m, "QWORD["):
		return "QWORD"
	}
	return ""
}

// matchMemWidth 根据内存槽宽度返回寄存器名的匹配形式（RAX→AL/AX/EAX）。
// 用于 64 位寄存器与窄内存槽互传时避免操作数宽度不匹配。
// 非内存目标时原样返回 reg。
func matchMemWidth(mem, reg string) string {
	switch memPrefix(mem) {
	case "BYTE":
		return lo8(reg)
	case "WORD":
		return lo16(reg)
	case "DWORD":
		return eName(reg)
	}
	return reg
}

// stripMemPrefix 去掉内存操作数的宽度前缀（BYTE/WORD/DWORD/QWORD），
// lea 等指令要求裸地址形式。
func stripMemPrefix(addr string) string {
	for _, p := range []string{"BYTE", "WORD", "DWORD", "QWORD"} {
		if strings.HasPrefix(addr, p) {
			return addr[len(p):]
		}
	}
	return addr
}

// isRegLike 判断字符串是否为寄存器名（常量/内存地址不会以 R/E 开头）。
func isRegLike(name string) bool {
	return strings.HasPrefix(name, "R") || strings.HasPrefix(name, "E")
}

// derefLoad 生成内存读指令：[src] → dst。
func (c *ECompiler) derefLoad(prefix, dst, src string) string {
	load := func(dst, src string) string {
		switch prefix {
		case "BYTE", "WORD":
			return utils.Format("movzx " + dst + ", " + prefix + " [" + src + "]")
		case "DWORD":
			return utils.Format("mov " + eName(dst) + ", DWORD [" + src + "]")
		case "QWORD":
			return utils.Format("mov " + dst + ", QWORD [" + src + "]")
		}
		return ""
	}

	// 内存目标需经寄存器中转（x86 不支持 mov mem, mem），写回时匹配槽宽度
	if strings.Contains(dst, "[") {
		tmp := c.arch.ReturnReg()
		return load(tmp, src) + utils.Format("mov "+dst+", "+matchMemWidth(dst, tmp))
	}
	return load(dst, src)
}

// derefStore 生成内存写指令：[dst] = src。
func (c *ECompiler) derefStore(prefix, dst, src string) string {
	switch prefix {
	case "BYTE":
		return utils.Format("mov BYTE [" + dst + "], " + lo8(src))
	case "WORD":
		return utils.Format("mov WORD [" + dst + "], " + lo16(src))
	case "DWORD":
		return utils.Format("mov DWORD [" + dst + "], " + eName(src))
	case "QWORD":
		return utils.Format("mov QWORD [" + dst + "], " + src)
	}
	return ""
}

// lo16 返回寄存器名的低16位寄存器名（16位内存写需要）
func lo16(name string) string {
	switch strings.ToUpper(name) {
	case "EAX", "RAX":
		return "ax"
	case "EBX", "RBX":
		return "bx"
	case "ECX", "RCX":
		return "cx"
	case "EDX", "RDX":
		return "dx"
	case "ESI", "RSI":
		return "si"
	case "EDI", "RDI":
		return "di"
	case "R8":
		return "r8w"
	case "R9":
		return "r9w"
	case "R10":
		return "r10w"
	case "R11":
		return "r11w"
	case "R12":
		return "r12w"
	case "R13":
		return "r13w"
	case "R14":
		return "r14w"
	case "R15":
		return "r15w"
	}
	return "ax"
}

// eName 返回寄存器的32位名（RAX→EAX；R8→R8D；EAX 等 32 位名原样）。
// x86 下寄存器本身是 EAX 形式（无 R 前缀），原样返回。
func eName(name string) string {
	switch name {
	case "R8":
		return "R8D"
	case "R9":
		return "R9D"
	case "R10":
		return "R10D"
	case "R11":
		return "R11D"
	case "R12":
		return "R12D"
	case "R13":
		return "R13D"
	case "R14":
		return "R14D"
	case "R15":
		return "R15D"
	}
	if strings.HasPrefix(name, "R") {
		return "E" + name[1:]
	}
	return name
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
		lCode += utils.Format("mov " + matchMemWidth(lVal, callee) + ", " + lVal)
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
		rCode += utils.Format("mov " + matchMemWidth(rVal, callee) + ", " + rVal)
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
// 结果/操作数为窄内存槽时，寄存器操作数名匹配槽宽度（add DWORD[mem], EAX）。
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
				code = utils.Format("mov " + result + ", " + matchMemWidth(result, callee))
			}
			code += c.arch.InstBinary(result, exp.Separator, matchMemWidth(result, rVal))
		} else {
			// 右在 callee-save
			if result != lVal {
				code = utils.Format("mov " + result + ", " + matchMemWidth(result, lVal))
			}
			code += c.arch.InstBinary(result, exp.Separator, matchMemWidth(result, callee))
		}
	} else {
		// 普通情况
		if result == lVal {
			// 结果直接写到左操作数寄存器/内存槽
			code = c.arch.InstBinary(lVal, exp.Separator, matchMemWidth(lVal, rVal))
		} else {
			// 需要先 mov 左操作数到 result，再运算
			code = utils.Format("mov " + result + ", " + matchMemWidth(result, lVal))
			code += c.arch.InstBinary(result, exp.Separator, matchMemWidth(result, rVal))
		}
	}

	return code
}
