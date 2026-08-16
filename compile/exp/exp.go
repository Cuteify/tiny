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

// Assign 编译变量赋值（p1.x = v、self.x += dx 等），
// this/self 字段走间接寻址（this 是指针）
func (c *ECompiler) Assign(v *parser.VarBlock) string {
	if v == nil || v.Value == nil {
		return ""
	}
	c.Collect(v.Value)
	if isThisField(v) {
		pre, addr, reg := c.thisMem(v)
		mem := c.derefPrefix(v.Type) + "[" + addr + "]"
		code := pre + c.generate(v.Value, mem)
		c.freeTmpReg(reg)
		return code + "; 设置变量" + v.Name.String() + "\n"
	}
	return c.generate(v.Value, c.arch.VarAddr(v)) + "; 设置变量" + v.Name.String() + "\n"
}

// isThisField 判断是否为 this/self 的字段访问（self.x）
func isThisField(v *parser.VarBlock) bool {
	if v == nil || len(v.Name) <= 1 {
		return false
	}
	first := v.Name.First()
	return first == "this" || first == "self"
}

// thisMem 为 this/self 字段访问生成间接寻址
// 返回（前置代码, 内存地址表达式, 临时寄存器）
func (c *ECompiler) thisMem(v *parser.VarBlock) (string, string, *regmgr.Reg) {
	reg := c.allocTmpReg()
	size := c.arch.PointerSize()
	frame := "rbp"
	thisOffset := 16
	if size == 4 {
		frame = "ebp"
		thisOffset = 8
	}
	pre := utils.Format("mov " + reg.Name + ", " + c.arch.LengthName(size) + "[" + frame + "+" + strconv.Itoa(thisOffset) + "]")
	off := fieldOffsetOf(v)
	if off == 0 {
		return pre, reg.Name, reg
	}
	return pre, reg.Name + "+" + strconv.Itoa(off), reg
}

// allocTmpReg 分配临时寄存器（不绑定表达式，调用方负责 freeTmpReg）
// 避开 ReturnReg：derefLoad/derefStore 用 ReturnReg 作临时寄存器，避免覆盖
func (c *ECompiler) allocTmpReg() *regmgr.Reg {
	returnReg := c.arch.ReturnReg()
	for _, reg := range c.ctx.Reg.Regs {
		if reg.Free && reg.ClassMask&c.ctx.Arch.DefaultRegMask() != 0 && reg.Name != returnReg {
			reg.Free = false
			reg.ExpID = 0
			return reg
		}
	}
	return &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
}

// freeTmpReg 释放临时寄存器
func (c *ECompiler) freeTmpReg(reg *regmgr.Reg) {
	reg.Free = true
	reg.ExpID = 0
}

// fieldOffsetOf 沿 v.Name[1:] 字段路径累加结构体偏移（基础类型取自 Define.Path[0]）
func fieldOffsetOf(v *parser.VarBlock) int {
	if v == nil || len(v.Name) <= 1 || v.Define.Node == nil || len(v.Define.Path) == 0 {
		return 0
	}
	base, ok := v.Define.Path[0].(typeSys.Type)
	if !ok || base == nil {
		return 0
	}
	if base.IsPointer() {
		base = base.Elem()
	}
	if base == nil {
		return 0
	}

	totalOffset := 0
	currentType := base
	for i := 1; i < len(v.Name); i++ {
		st, ok := currentType.(*typeSys.StructType)
		if !ok {
			return 0
		}
		st.Layout()
		field := st.Field(v.Name[i].Name)
		if field == nil {
			return 0
		}
		totalOffset += field.Offset
		currentType = field.Type
		if currentType == nil {
			return 0
		}
		if i < len(v.Name)-1 && currentType.IsPointer() {
			currentType = currentType.Elem()
		}
	}
	return totalOffset
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

	// 列表/字符串专有节点：字面量、索引读、切片、索引赋值
	switch exp.Separator {
	case "list_lit":
		return c.listLiteral(exp, result)
	case "[]":
		if exp.Index[1] != nil || exp.Index[2] != nil {
			return c.sliceExp(exp, result)
		}
		return c.indexAccess(exp, result)
	case "[]=":
		return c.indexSet(exp)
	}

	// 内建调用（len/cap/append/make/realloc）：非内建时继续走叶子
	if exp.Call != nil {
		if code := c.builtinCall(exp, result); code != "" {
			return code
		}
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
	// 内建调用（len/cap/append/make）优先于普通函数调用
	if exp.Call != nil {
		if code := c.builtinCall(exp, result); code != "" {
			return code
		}
	}
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
	// this/self 字段访问（self.x）：this 是指针，需先加载再间接寻址
	if exp.Var != nil && isThisField(exp.Var) {
		pre, addr, reg := c.thisMem(exp.Var)
		prefix := c.derefPrefix(exp.Var.Type)
		var code string
		if result == "push" {
			code = c.derefLoad(prefix, reg.Name, addr)
			code += utils.Format("push " + reg.Name)
		} else {
			code = c.derefLoad(prefix, result, addr)
		}
		c.freeTmpReg(reg)
		return pre + code
	}
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

// stripOuterBrackets 去掉内存操作数的外层括号：QWORD[rbp-96] → rbp-96
func stripOuterBrackets(addr string) string {
	addr = stripMemPrefix(strings.TrimSpace(addr))
	if len(addr) >= 2 && addr[0] == '[' && addr[len(addr)-1] == ']' {
		return addr[1 : len(addr)-1]
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

	// push 参数装载：直接 push 元素（BYTE/WORD 需先 movzx 中转）
	if dst == "push" {
		if prefix == "BYTE" || prefix == "WORD" {
			return load(c.arch.ReturnReg(), src) + utils.Format("push " + c.arch.ReturnReg())
		}
		return utils.Format("push " + prefix + " [" + src + "]")
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

// ============ 列表/字符串（list/string）三字段容器支持 ============

// isListLike 判断是否为三字段容器类型（list/string）
func isListLike(t typeSys.Type) bool {
	return t != nil && (t.Kind() == "list" || t.Kind() == "string")
}

// listFields 返回三字段偏移（x64: 0/8/16；x86: 0/4/8）
func (c *ECompiler) listFields() (ptr, length, cap int) {
	ps := c.arch.PointerSize()
	return 0, ps, 2 * ps
}

// align8 向上取整到 8 字节
func align8(n int) int { return (n + 7) &^ 7 }

// getStringLabel 获取/注册字符串常量标签
func (c *ECompiler) getStringLabel(val string) string {
	if label, ok := c.ctx.StringConsts[val]; ok {
		return label
	}
	c.ctx.StrCount++
	label := "str_" + strconv.Itoa(c.ctx.StrCount)
	c.ctx.StringConsts[val] = label
	return label
}

// emitMalloc 调用运行时 malloc（返回 RAX/EAX），按架构选择调用约定
func (c *ECompiler) emitMalloc(size int) string {
	if c.arch.PointerSize() == 8 {
		return utils.Format("mov RDI, " + strconv.Itoa(size)) +
			utils.Format("call std_memory_malloc1")
	}
	return utils.Format("push " + strconv.Itoa(size)) +
		utils.Format("call std_memory_malloc1") +
		utils.Format("add esp, 4")
}

// emitRealloc 调用运行时 realloc（返回 RAX/EAX），按架构选择调用约定
func (c *ECompiler) emitRealloc(ptrReg, sizeReg string) string {
	if c.arch.PointerSize() == 8 {
		return utils.Format("mov RDI, " + ptrReg) +
			utils.Format("mov RSI, " + sizeReg) +
			utils.Format("call std_memory_realloc2")
	}
	return utils.Format("push " + sizeReg) +
		utils.Format("push " + ptrReg) +
		utils.Format("call std_memory_realloc2") +
		utils.Format("add esp, 8")
}

// storeVal 将 val（寄存器/常量/内存）写入内存槽 dst
func (c *ECompiler) storeVal(dst, ln, val string) string {
	if !strings.Contains(dst, "[") {
		dst = "[" + dst + "]"
	}
	if strings.Contains(val, "[") {
		tmp := c.arch.ReturnReg()
		code := utils.Format("mov " + tmp + ", " + val)
		return code + utils.Format("mov "+ln+" "+dst+", "+matchMemWidth(dst, tmp))
	}
	if isRegLike(val) {
		return utils.Format("mov " + ln + " " + dst + ", " + matchMemWidth(dst, val))
	}
	return utils.Format("mov " + ln + " " + dst + ", " + val)
}

// emitZero3 将三字段容器槽清零（内存/寄存器/push）
func (c *ECompiler) emitZero3(result string) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	if result == "push" {
		return utils.Format("push 0") + utils.Format("push 0") + utils.Format("push 0; 空容器")
	}
	if strings.Contains(result, "[") {
		base := stripOuterBrackets(result)
		code := utils.Format("mov " + ln + " " + result + ", 0")
		code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(ps) + "], 0")
		code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(2*ps) + "], 0; 空容器")
		return code
	}
	return utils.Format("xor " + result + ", " + result)
}

// emit3 将 {ptr, len, cap} 三字段装载到 result（内存/寄存器/push）
func (c *ECompiler) emit3(result, ptrReg string, length, cap int) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	if result == "push" {
		code := utils.Format("push " + ptrReg)
		code += utils.Format("push " + strconv.Itoa(length))
		code += utils.Format("push " + strconv.Itoa(cap))
		return code
	}
	if strings.Contains(result, "[") {
		base := stripOuterBrackets(result)
		code := utils.Format("mov " + ln + " " + result + ", " + matchMemWidth(result, ptrReg))
		code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(ps) + "], " + strconv.Itoa(length))
		code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(2*ps) + "], " + strconv.Itoa(cap))
		return code
	}
	return utils.Format("mov " + result + ", " + ptrReg)
}

// listLiteral 运行时分配列表字面量（Go 语义：ptr/len/cap 三字段）
func (c *ECompiler) listLiteral(exp *parser.Expression, result string) string {
	lt, ok := exp.Type.(*typeSys.ListType)
	if !ok || lt.Elem() == nil {
		return ""
	}
	elemSize := lt.Elem().Size()
	ps := c.arch.PointerSize()
	ptrOff, lenOff, capOff := c.listFields()
	n := len(exp.ListElems)

	// 空列表 = {0,0,0}
	if n == 0 {
		return c.emitZero3(result)
	}

	code := c.emitMalloc(align8(n * elemSize))
	callee := c.arch.CalleeSaveReg()
	code += utils.Format("mov " + callee + ", " + c.arch.ReturnReg() + "; list buffer")

	// 逐元素装载
	for i, elem := range exp.ListElems {
		off := i * elemSize
		if elem.Type != nil && elem.Type.Kind() == "string" {
			// string 元素：三槽（ptr/len/cap）
			if elem.IsConst() && elem.StringVal != "" {
				label := c.getStringLabel(elem.StringVal)
				slen := len(elem.StringVal)
				code += utils.Format("mov " + c.arch.LengthName(ps) + " [" + callee + "+" + strconv.Itoa(off+ptrOff) + "], " + label)
				code += utils.Format("mov " + c.arch.LengthName(ps) + " [" + callee + "+" + strconv.Itoa(off+lenOff) + "], " + strconv.Itoa(slen))
				code += utils.Format("mov " + c.arch.LengthName(ps) + " [" + callee + "+" + strconv.Itoa(off+capOff) + "], " + strconv.Itoa(slen))
				continue
			}
			// 非常量 string：整体三槽拷贝（元素必须是变量）
			if elem.Var != nil {
				src := stripOuterBrackets(c.arch.VarAddr(elem.Var))
				code += c.copySlots(callee+"+"+strconv.Itoa(off), src, ps)
				continue
			}
			return ""
		}
		if elem.IsConst() && typeSys.CheckKind(elem.Type, "int", "uint") {
			val := strconv.FormatFloat(elem.Num, 'f', -1, 64)
			code += utils.Format("mov " + c.arch.LengthName(elemSize) + " [" + callee + "+" + strconv.Itoa(off) + "], " + val)
			continue
		}
		// 非常量标量：算到独立寄存器再写槽（避开 callee）
		rReg := c.allocRegAvoid(elem, callee)
		if rReg == nil {
			rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		code += c.generate(elem, rReg.Name)
		code += utils.Format("mov " + c.arch.LengthName(elemSize) + " [" + callee + "+" + strconv.Itoa(off) + "], " + matchMemWidth(c.arch.LengthName(elemSize)+"[", rReg.Name))
		c.ctx.Reg.Free(elem)
	}

	// 结果三字段
	return code + c.emit3(result, callee, n, n)
}

// copySlots 按指针宽度槽从 src 拷贝 size 字节到 dst（裸地址，经 RAX 中转）
func (c *ECompiler) copySlots(dst, src string, size int) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	var code string
	for off := 0; off < size; off += ps {
		code += utils.Format("mov " + c.arch.ReturnReg() + ", " + ln + " [" + src + "+" + strconv.Itoa(off) + "]")
		code += utils.Format("mov " + ln + " [" + dst + "+" + strconv.Itoa(off) + "], " + c.arch.ReturnReg())
	}
	return code
}

// indexAccess 列表/字符串索引读 a[i]
func (c *ECompiler) indexAccess(exp *parser.Expression, result string) string {
	if exp.Right == nil || exp.Right.Type == nil || len(exp.Index) == 0 || exp.Index[0] == nil {
		return ""
	}
	elemSize := 1
	if exp.Right.Type.Kind() == "list" {
		lt, ok := exp.Right.Type.(*typeSys.ListType)
		if !ok || lt.Elem() == nil {
			return ""
		}
		elemSize = lt.Elem().Size()
	}
	return c.indexAccessGeneric(exp, result, elemSize)
}

// indexAccessGeneric 计算 ptr+idx*es 并读元素
func (c *ECompiler) indexAccessGeneric(exp *parser.Expression, result string, elemSize int) string {
	code := ""
	ptrReg := c.allocReg(exp.Right)
	if ptrReg == nil {
		ptrReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code += c.generate(exp.Right, ptrReg.Name)

	idxExpr := exp.Index[0]
	if idxExpr.IsConst() {
		off := int(idxExpr.Num) * elemSize
		if off != 0 {
			code += utils.Format("add " + ptrReg.Name + ", " + strconv.Itoa(off))
		}
	} else {
		iReg := c.allocRegAvoid(idxExpr, ptrReg.Name)
		if iReg == nil {
			iReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
		}
		code += c.generate(idxExpr, iReg.Name)
		code += utils.Format("imul " + iReg.Name + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + ptrReg.Name + ", " + iReg.Name)
		c.ctx.Reg.Free(idxExpr)
	}

	// 读元素
	if elemSize > c.arch.PointerSize() {
		// 多槽元素（string 等）：整体拷到内存目标
		if result == "push" {
			// 参数装载：多槽元素整体入栈，高地址槽先入栈
			ps := c.arch.PointerSize()
			for i := elemSize/ps - 1; i >= 0; i-- {
				off := i * ps
				if off == 0 {
					code += utils.Format("push " + c.arch.LengthName(ps) + " [" + ptrReg.Name + "]")
				} else {
					code += utils.Format("push " + c.arch.LengthName(ps) + " [" + ptrReg.Name + "+" + strconv.Itoa(off) + "]")
				}
			}
		} else if strings.Contains(result, "[") {
			code += c.copySlots(stripOuterBrackets(result), ptrReg.Name, elemSize)
		} else {
			code += utils.Format("mov " + result + ", " + c.arch.LengthName(c.arch.PointerSize()) + " [" + ptrReg.Name + "]")
		}
	} else {
		code += c.derefLoad(c.arch.LengthName(elemSize), result, ptrReg.Name)
	}
	c.ctx.Reg.Free(exp.Right)
	return code
}

// indexSet 索引赋值 a[i] = v（Separator="[]="：Left=索引表达式，Right=值）
func (c *ECompiler) indexSet(exp *parser.Expression) string {
	indexExpr := exp.Left
	if indexExpr == nil || indexExpr.Right == nil || len(indexExpr.Index) == 0 || indexExpr.Index[0] == nil || exp.Right == nil {
		return ""
	}
	elemSize := 1
	if indexExpr.Right.Type != nil && indexExpr.Right.Type.Kind() == "list" {
		if lt, ok := indexExpr.Right.Type.(*typeSys.ListType); ok && lt.Elem() != nil {
			elemSize = lt.Elem().Size()
		}
	}

	// 1. 值先算到寄存器（地址计算无调用，值可安全跨指令保存）
	vReg := c.allocReg(exp.Right)
	if vReg == nil {
		vReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code := c.generate(exp.Right, vReg.Name)
	if elemSize > c.arch.PointerSize() {
		// 多槽元素（string）赋值暂不支持非常量源
		c.ctx.Reg.Free(exp.Right)
		return ""
	}

	// 2. 列表指针 → aReg（避开值寄存器）
	aReg := c.allocRegAvoid(indexExpr.Right, vReg.Name)
	if aReg == nil {
		aReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
	}
	code += c.generate(indexExpr.Right, aReg.Name)

	// 3. 索引偏移
	idxExpr := indexExpr.Index[0]
	if idxExpr.IsConst() {
		off := int(idxExpr.Num) * elemSize
		if off != 0 {
			code += utils.Format("add " + aReg.Name + ", " + strconv.Itoa(off))
		}
	} else {
		iReg := c.allocRegAvoid(idxExpr, aReg.Name)
		if iReg == nil {
			iReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		code += c.generate(idxExpr, iReg.Name)
		code += utils.Format("imul " + iReg.Name + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + aReg.Name + ", " + iReg.Name)
		c.ctx.Reg.Free(idxExpr)
	}

	// 4. 写入
	code += c.derefStore(c.arch.LengthName(elemSize), aReg.Name, vReg.Name)
	c.ctx.Reg.Free(exp.Right)
	c.ctx.Reg.Free(indexExpr.Right)
	return code
}

// sliceExp 切片 a[lo:hi]（三字段装载：ptr+lo*es、len=hi-lo、cap=原cap-lo）
func (c *ECompiler) sliceExp(exp *parser.Expression, result string) string {
	if exp.Right == nil || exp.Right.Type == nil {
		return ""
	}
	elemSize := 1
	if exp.Right.Type.Kind() == "list" {
		lt, ok := exp.Right.Type.(*typeSys.ListType)
		if !ok || lt.Elem() == nil {
			return ""
		}
		elemSize = lt.Elem().Size()
	}
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	_, lenOff, capOff := c.listFields()
	loExpr := exp.Index[0]
	hiExpr := exp.Index[1]

	// 1. 原列表 ptr → ptrReg
	ptrReg := c.allocReg(exp.Right)
	if ptrReg == nil {
		ptrReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code := c.generate(exp.Right, ptrReg.Name)

	// 2. lo 偏移（常量/非常量）
	var loReg *regmgr.Reg
	loConst := 0
	if loExpr != nil && loExpr.IsConst() {
		loConst = int(loExpr.Num)
		if loConst != 0 {
			code += utils.Format("add " + ptrReg.Name + ", " + strconv.Itoa(loConst*elemSize))
		}
	} else if loExpr != nil {
		loReg = c.allocRegAvoid(loExpr, ptrReg.Name)
		if loReg == nil {
			loReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
		}
		code += c.generate(loExpr, loReg.Name)
		code += utils.Format("imul " + loReg.Name + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + ptrReg.Name + ", " + loReg.Name)
	}

	// 3. len = hi - lo（常量/寄存器）
	var lenVal string
	if hiExpr != nil {
		if hiExpr.IsConst() {
			lenVal = strconv.Itoa(int(hiExpr.Num) - loConst)
		} else {
			hiReg := c.allocRegAvoid(hiExpr, ptrReg.Name)
			if hiReg == nil {
				hiReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
			}
			code += c.generate(hiExpr, hiReg.Name)
			if loReg != nil {
				code += utils.Format("sub " + hiReg.Name + ", " + loReg.Name)
			} else if loConst != 0 {
				code += utils.Format("sub " + hiReg.Name + ", " + strconv.Itoa(loConst))
			}
			c.ctx.Reg.Free(hiExpr)
			lenVal = hiReg.Name
		}
	} else {
		lenVal = "0"
	}

	// 4. cap = 原cap - lo（从原变量三槽读；lo 非常量时经寄存器）
	var capVal string
	if exp.Right.Var != nil {
		capAddr := stripOuterBrackets(c.arch.VarAddr(exp.Right.Var)) + "+" + strconv.Itoa(capOff)
		if loReg != nil {
			capReg := c.allocRegAvoid(exp.Right, ptrReg.Name)
			if capReg == nil {
				capReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
			}
			code += utils.Format("mov " + capReg.Name + ", " + ln + " [" + capAddr + "]")
			code += utils.Format("sub " + capReg.Name + ", " + loReg.Name)
			capVal = capReg.Name
		} else if loConst != 0 {
			capReg := c.allocRegAvoid(exp.Right, ptrReg.Name)
			if capReg == nil {
				capReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
			}
			code += utils.Format("mov " + capReg.Name + ", " + ln + " [" + capAddr + "]")
			code += utils.Format("sub " + capReg.Name + ", " + strconv.Itoa(loConst))
			capVal = capReg.Name
		} else {
			capVal = ln + " [" + capAddr + "]"
		}
	} else {
		capVal = "0"
	}

	// 5. 装载 result 三字段
	if result == "push" {
		code += utils.Format("push " + ptrReg.Name)
		if strings.Contains(capVal, "[") {
			tmp := c.arch.ReturnReg()
			code += utils.Format("mov " + tmp + ", " + capVal)
			code += utils.Format("push " + tmp)
		} else {
			code += utils.Format("push " + capVal)
		}
		if strings.Contains(lenVal, "[") {
			tmp := c.arch.ReturnReg()
			code += utils.Format("mov " + tmp + ", " + lenVal)
			code += utils.Format("push " + tmp)
		} else {
			code += utils.Format("push " + lenVal)
		}
	} else if strings.Contains(result, "[") {
		base := stripOuterBrackets(result)
		code += utils.Format("mov " + ln + " " + result + ", " + matchMemWidth(result, ptrReg.Name))
		code += c.storeVal(base+"+"+strconv.Itoa(lenOff), ln, lenVal)
		code += c.storeVal(base+"+"+strconv.Itoa(capOff), ln, capVal)
	} else {
		code += utils.Format("mov " + result + ", " + ptrReg.Name)
	}
	c.ctx.Reg.Free(exp.Right)
	return code
}

// listFieldRead 读容器字段（len/cap）：变量直接读三槽；表达式先算 ptr 再偏移
func (c *ECompiler) listFieldRead(arg *parser.Expression, off int, result string) string {
	ln := c.arch.LengthName(c.arch.PointerSize())
	if arg.Var != nil {
		addr := stripOuterBrackets(c.arch.VarAddr(arg.Var)) + "+" + strconv.Itoa(off)
		if result == "push" {
			return utils.Format("push " + ln + " [" + addr + "]")
		}
		if strings.Contains(result, "[") {
			return c.derefLoad(ln, result, addr)
		}
		return utils.Format("mov " + result + ", " + ln + " [" + addr + "]")
	}
	// 表达式：算到寄存器（ptr 槽），再读 [reg+off]
	rReg := c.allocReg(arg)
	if rReg == nil {
		rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code := c.generate(arg, rReg.Name)
	addr := rReg.Name + "+" + strconv.Itoa(off)
	if result == "push" {
		code += utils.Format("push " + ln + " [" + addr + "]")
	} else if strings.Contains(result, "[") {
		code += c.derefLoad(ln, result, addr)
	} else {
		code += utils.Format("mov " + result + ", " + ln + " [" + addr + "]")
	}
	c.ctx.Reg.Free(arg)
	return code
}

// builtinCall 内建调用分派：len/cap/append/make；非内建返回空串走叶子
func (c *ECompiler) builtinCall(exp *parser.Expression, result string) string {
	call := exp.Call
	if call == nil {
		return ""
	}
	name := call.Name.String()
	_, lenOff, capOff := c.listFields()
	switch name {
	case "len", "cap":
		if len(call.Args) == 1 && call.Args[0] != nil && call.Args[0].Value != nil &&
			call.Args[0].Value.Type != nil && isListLike(call.Args[0].Value.Type) {
			off := lenOff
			if name == "cap" {
				off = capOff
			}
			return c.listFieldRead(call.Args[0].Value, off, result)
		}
	case "append":
		return c.builtinAppend(call, result)
	case "make":
		return c.builtinMake(exp, call, result)
	}
	return ""
}

// builtinAppend append(a, v)：len<cap 直写，否则 realloc 扩容（暂只支持变量 a）
func (c *ECompiler) builtinAppend(call *parser.CallBlock, result string) string {
	if len(call.Args) < 2 || call.Args[0] == nil || call.Args[0].Value == nil ||
		call.Args[1] == nil || call.Args[1].Value == nil {
		return ""
	}
	aExp := call.Args[0].Value
	elem := call.Args[1].Value
	if aExp.Var == nil || aExp.Type == nil || !isListLike(aExp.Type) {
		return ""
	}
	elemSize := 1
	if aExp.Type.Kind() == "list" {
		if lt, ok := aExp.Type.(*typeSys.ListType); ok && lt.Elem() != nil {
			elemSize = lt.Elem().Size()
		}
	}
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	_, lenOff, capOff := c.listFields()
	callee := c.arch.CalleeSaveReg()
	base := stripOuterBrackets(c.arch.VarAddr(aExp.Var))
	label := "append_" + strconv.Itoa(c.idx)

	// 1. 值 → callee-save（跨 realloc call 安全）
	code := c.generate(elem, callee)

	// 2. ptr 与 len
	ptrReg := c.allocRegAvoid(aExp, callee)
	if ptrReg == nil {
		ptrReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code += c.generate(aExp, ptrReg.Name)
	lReg := c.allocRegAvoid(aExp, ptrReg.Name)
	if lReg == nil {
		lReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
	}
	code += utils.Format("mov " + lReg.Name + ", " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "]")

	// 3. len < cap → 直写
	code += utils.Format("cmp " + lReg.Name + ", " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "]")
	code += utils.Format("jge " + label + "_grow")
	code += utils.Format("mov " + c.arch.LengthName(elemSize) + " [" + ptrReg.Name + "+" + lReg.Name + "*" + strconv.Itoa(elemSize) + "], " + matchMemWidth(c.arch.LengthName(elemSize)+"[", callee))
	code += utils.Format("add " + lReg.Name + ", 1")
	code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "], " + lReg.Name)
	code += utils.Format("jmp " + label + "_end")

	// 4. grow：newCap = max(cap*2, 1)；realloc(ptr, newCap*es)；重读 len 写元素
	code += utils.Format(label + "_grow:")
	code += utils.Format("mov " + lReg.Name + ", " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "]")
	code += utils.Format("shl " + lReg.Name + ", 1")
	code += utils.Format("cmp " + lReg.Name + ", 1")
	code += utils.Format("jge " + label + "_grow2")
	code += utils.Format("mov " + lReg.Name + ", 1")
	code += utils.Format(label + "_grow2:")
	code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "], " + lReg.Name)
	code += utils.Format("imul " + lReg.Name + ", " + strconv.Itoa(elemSize))
	code += c.emitRealloc(ptrReg.Name, lReg.Name)
	code += utils.Format("mov " + ptrReg.Name + ", " + c.arch.ReturnReg())
	code += utils.Format("mov " + lReg.Name + ", " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "]")
	code += utils.Format("mov " + c.arch.LengthName(elemSize) + " [" + ptrReg.Name + "+" + lReg.Name + "*" + strconv.Itoa(elemSize) + "], " + matchMemWidth(c.arch.LengthName(elemSize)+"[", callee))
	code += utils.Format("add " + lReg.Name + ", 1")
	code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "], " + lReg.Name)
	code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(0) + "], " + ptrReg.Name)

	// 5. 结果三字段：{ptr, len, cap} 从 base 读
	code += utils.Format(label + "_end:")
	if result == "push" {
		code += utils.Format("push " + ln + " [" + base + "]")
		code += utils.Format("push " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "]")
		code += utils.Format("push " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "]")
	} else if strings.Contains(result, "[") {
		code += c.storeVal(stripOuterBrackets(result), ln, ln+" ["+base+"]")
		code += c.storeVal(stripOuterBrackets(result)+"+"+strconv.Itoa(lenOff), ln, ln+" ["+base+"+"+strconv.Itoa(lenOff)+"]")
		code += c.storeVal(stripOuterBrackets(result)+"+"+strconv.Itoa(capOff), ln, ln+" ["+base+"+"+strconv.Itoa(capOff)+"]")
	} else {
		code += utils.Format("mov " + result + ", " + ln + " [" + base + "]")
	}
	c.ctx.Reg.Free(aExp)
	c.ctx.Reg.Free(elem)
	return code
}

// builtinMake make([]T, len[, cap])：运行时分配并零填充
func (c *ECompiler) builtinMake(exp *parser.Expression, call *parser.CallBlock, result string) string {
	lt, ok := exp.Type.(*typeSys.ListType)
	if !ok || lt.Elem() == nil {
		return ""
	}
	// 参数：args[0] 为类型占位，args[1]=len，args[2]=cap（可选）
	if len(call.Args) < 2 || call.Args[1] == nil || call.Args[1].Value == nil {
		return ""
	}
	lenExp := call.Args[1].Value
	capExp := lenExp
	if len(call.Args) > 2 && call.Args[2] != nil && call.Args[2].Value != nil {
		capExp = call.Args[2].Value
	}
	elemSize := lt.Elem().Size()
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	callee := c.arch.CalleeSaveReg()
	label := "make_" + strconv.Itoa(c.idx)

	// cap 值（常量/寄存器）→ size = align8(cap*es) → malloc
	var code string
	var capVal string
	if capExp.IsConst() {
		capV := int(capExp.Num)
		capVal = strconv.Itoa(capV)
		code += c.emitMalloc(align8(capV * elemSize))
	} else {
		capReg := c.allocReg(capExp)
		if capReg == nil {
			capReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		code += c.generate(capExp, capReg.Name)
		// size = align8(cap*es)：(cap*es + 7) & ~7
		code += utils.Format("imul " + capReg.Name + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + capReg.Name + ", 7")
		code += utils.Format("and " + capReg.Name + ", ~7")
		if ps == 8 {
			code += utils.Format("mov RDI, " + capReg.Name)
			code += utils.Format("call std_memory_malloc1")
		} else {
			code += utils.Format("push " + capReg.Name)
			code += utils.Format("call std_memory_malloc1")
			code += utils.Format("add esp, 4")
		}
		capVal = capReg.Name
		c.ctx.Reg.Free(capExp)
	}
	code += utils.Format("mov " + callee + ", " + c.arch.ReturnReg() + "; list buffer")

	// 零填充 len*es 字节
	code += utils.Format("mov " + c.arch.ReturnReg() + ", 0")
	var lenVal string
	if lenExp.IsConst() {
		lenV := int(lenExp.Num)
		lenVal = strconv.Itoa(lenV)
		zeros := align8(lenV * elemSize)
		for off := 0; off < zeros; off += ps {
			code += utils.Format("mov " + ln + " [" + callee + "+" + strconv.Itoa(off) + "], " + c.arch.ReturnReg())
		}
	} else {
		lReg := c.allocRegAvoid(lenExp, callee)
		if lReg == nil {
			lReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
		}
		code += c.generate(lenExp, lReg.Name)
		// 循环零填充：count = len*es/ps
		code += utils.Format("imul " + lReg.Name + ", " + strconv.Itoa(elemSize))
		code += utils.Format("shr " + lReg.Name + ", " + strconv.Itoa(ps/2))
		code += utils.Format("mov " + c.arch.ReturnReg() + ", " + lReg.Name)
		code += utils.Format("cmp " + c.arch.ReturnReg() + ", 0")
		code += utils.Format("je " + label + "_zero_done")
		code += utils.Format(label + "_zero_loop:")
		code += utils.Format("mov " + ln + " [" + callee + "+" + c.arch.ReturnReg() + "*" + strconv.Itoa(ps) + " - " + strconv.Itoa(ps) + "], 0")
		code += utils.Format("sub " + c.arch.ReturnReg() + ", 1")
		code += utils.Format("jnz " + label + "_zero_loop")
		code += utils.Format(label + "_zero_done:")
		lenVal = lReg.Name
		c.ctx.Reg.Free(lenExp)
	}

	// 装载结果三字段（len 装载：常量 lenVal 或寄存器）
	if strings.Contains(result, "[") {
		base := stripOuterBrackets(result)
		code += utils.Format("mov " + ln + " " + result + ", " + matchMemWidth(result, callee))
		if lenExp.IsConst() {
			code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(ps) + "], " + lenVal)
		} else {
			code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(ps) + "], " + matchMemWidth(ln+"[", lenVal))
		}
		code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(2*ps) + "], " + capVal)
		return code
	}
	if result == "push" {
		code += utils.Format("push " + callee)
		if lenExp.IsConst() {
			code += utils.Format("push " + lenVal)
		} else {
			code += utils.Format("push " + lenVal)
		}
		code += utils.Format("push " + capVal)
		return code
	}
	return code + utils.Format("mov " + result + ", " + callee)
}

// ZeroVar 无初值容器的三槽清零（供 varDecl 调用）
func (c *ECompiler) ZeroVar(v *parser.VarBlock) string {
	if v == nil || !isListLike(v.Type) {
		return ""
	}
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	addr := stripOuterBrackets(c.arch.VarAddr(v))
	_, lenOff, capOff := c.listFields()
	code := utils.Format("mov " + ln + " [" + addr + "], 0")
	code += utils.Format("mov " + ln + " [" + addr + "+" + strconv.Itoa(lenOff) + "], 0")
	code += utils.Format("mov " + ln + " [" + addr + "+" + strconv.Itoa(capOff) + "], 0")
	return code + utils.Format("; 零值容器 " + v.Name.String())
}
