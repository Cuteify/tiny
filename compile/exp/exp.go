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
	// x86：64 位标量变量赋值走寄存器对路径。
	// 值表达式可能是无类型的整型字面量，须按目标变量类型分流；
	// 地址剥宽度前缀（compile64Type 自带 dword 前缀）
	if c.arch.PointerSize() == 4 && v.Type != nil {
		if tn := v.Type.Type(); tn == "u64" || tn == "i64" {
			addr := c.arch.VarAddr(v)
			if idx := strings.Index(addr, "["); idx > 0 {
				addr = addr[idx:]
			}
			return c.arch.Compile64Type(v.Value, addr, "64bit") + "; 设置变量" + v.Name.String() + "\n"
		}
	}
	c.Collect(v.Value)
	if isThisField(v) {
		pre, addr, reg := c.thisMem(v)
		mem := c.fieldValPrefix(v.Type) + "[" + addr + "]"
		code := pre + c.generate(v.Value, mem)
		c.freeTmpReg(reg)
		return code + "; 设置变量" + v.Name.String() + "\n"
	}
	// 指针基字段写入（p.x = v）：先加载指针值再间接寻址
	if needPtrMem(v) {
		pre, addr, reg := c.ptrMem(v)
		mem := c.fieldValPrefix(v.Type) + "[" + addr + "]"
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

// needPtrMem 判断字段访问是否需要指针间接寻址（p.x / head.next.x 等）。
// 路径中存在指针中间层（除最后一个目标字段类型外）时返回 true。
func needPtrMem(v *parser.VarBlock) bool {
	if v == nil || len(v.Name) <= 1 || isThisField(v) || v.Define.Node == nil || len(v.Define.Path) < 2 {
		return false
	}
	for i := 0; i < len(v.Define.Path)-1; i++ {
		if t, ok := v.Define.Path[i].(typeSys.Type); ok && t != nil && t.IsPointer() {
			return true
		}
	}
	return false
}

// ptrMem 为指针基/指针中间层字段访问生成间接寻址（一层或多层装载）。
// 返回（前置代码, 内存地址表达式, 临时寄存器）。
func (c *ECompiler) ptrMem(v *parser.VarBlock) (string, string, *regmgr.Reg) {
	reg := c.allocTmpReg()
	size := c.arch.PointerSize()
	ln := c.arch.LengthName(size)

	// 基础变量槽地址（Path[0] 为变量/参数；this/self 已由 isThisField 排除）
	var baseOff int
	isGlobal := false
	var globalName string
	var baseType typeSys.Type
	if len(v.Define.Path) > 0 {
		switch base := v.Define.Path[0].(type) {
		case *parser.VarBlock:
			baseOff = base.Offset
			baseType = base.Type
			if base.IsGlobal {
				isGlobal = true
				name := base.Name.String()
				if base.Define.Value != nil {
					if vb, ok := base.Define.Value.(*parser.VarBlock); ok && vb.Name != nil {
						name = vb.Name.String()
					}
				}
				globalName = "__global_" + utils.ToNASMName(name)
			}
		case *parser.ArgBlock:
			baseOff = base.Offset
			baseType = base.Type
		}
	}
	var base string
	if isGlobal {
		base = "[rel " + globalName + "]"
	} else {
		frame := c.arch.FramePtr()
		if baseOff < 0 {
			base = "[" + frame + strconv.Itoa(baseOff) + "]"
		} else if baseOff == 0 {
			base = "[" + frame + "]"
		} else {
			base = "[" + frame + "+" + strconv.Itoa(baseOff) + "]"
		}
	}

	// 第一装载：基础变量是指针则读指针值，否则取地址（值结构体在栈上）
	var pre string
	var currentType typeSys.Type
	if baseType != nil && baseType.IsPointer() {
		pre = utils.Format("mov " + reg.Name + ", " + ln + " " + base)
		currentType = baseType.Elem()
	} else {
		pre = utils.Format("lea " + reg.Name + ", " + base)
		currentType = baseType
	}
	if currentType == nil {
		c.freeTmpReg(reg)
		return pre, reg.Name, reg
	}

	// 沿字段路径：遇指针字段装载一层，普通字段累计偏移
	off := 0
	for i := 1; i < len(v.Name); i++ {
		st, ok := currentType.(*typeSys.StructType)
		if !ok {
			break
		}
		st.Layout()
		field := st.Field(v.Name[i].Name)
		if field == nil {
			break
		}
		off += field.Offset
		if i == len(v.Name)-1 {
			break
		}
		currentType = field.Type
		if currentType == nil {
			break
		}
		if currentType.IsPointer() {
			// 指针中间层：从当前地址装载指针值并清零偏移
			if off != 0 {
				pre += utils.Format("mov " + reg.Name + ", " + ln + " [" + reg.Name + "+" + strconv.Itoa(off) + "]")
			} else {
				pre += utils.Format("mov " + reg.Name + ", " + ln + " [" + reg.Name + "]")
			}
			off = 0
			currentType = currentType.Elem()
		}
	}
	addr := reg.Name
	if off != 0 {
		addr = reg.Name + "+" + strconv.Itoa(off)
	}
	return pre, addr, reg
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
	if !ok {
		switch t := v.Define.Path[0].(type) {
		case *parser.VarBlock:
			base, ok = t.Type, t.Type != nil
		case *parser.ArgBlock:
			base, ok = t.Type, t.Type != nil
		case *parser.FuncBlock:
			base, ok = t.Class, t.Class != nil
		case *typeSys.StructField:
			base, ok = t.Type, t.Type != nil
		}
	}
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

	// 32 位架构：64 位标量（u64/i64）路由到 arch 的寄存器对实现（EAX:EDX）。
	// f64 有独立浮点路径，不在此列。
	if c.arch.PointerSize() == 4 && exp.Type != nil {
		if tn := exp.Type.Type(); tn == "u64" || tn == "i64" {
			return c.arch.Compile64Type(exp, result, "64bit")
		}
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

	// string 拼接 +（运行期，常量折叠已在 parser 层处理）
	if exp.Separator == "+" && exp.Type != nil && typeSys.CheckKind(exp.Type, "string") {
		return c.stringConcatExp(exp, result, ei)
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
			// 大值（容器/结构体）返回值：call 已写入本帧返回槽，从这里多槽装载
			if exp.Call.Func != nil && len(exp.Call.Func.Return) > 0 && arch.FuncReturnsLarge(exp.Call.Func) {
				ps := c.arch.PointerSize()
				ln := c.arch.LengthName(ps)
				slots := arch.ArgSlots(exp.Call.Func.Return[0])
				retBase := c.arch.FramePtr() + strconv.Itoa(c.ctx.RetSlot)
				if result == "push" {
					var pcode string
					for i := slots - 1; i >= 0; i-- {
						off := i * ps
						if off == 0 {
							pcode += utils.Format("push " + ln + " [" + retBase + "]")
						} else {
							pcode += utils.Format("push " + ln + " [" + retBase + "+" + strconv.Itoa(off) + "]")
						}
					}
					return code + pcode
				}
				if strings.Contains(result, "[") {
					code += c.copySlots(stripOuterBrackets(result), retBase, slots*ps)
					return code
				}
				return code + utils.Format("mov " + result + ", " + ln + " [" + retBase + "]")
			}
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
	// 多槽叶子（容器/结构体）：常量/变量多槽装载
	if c.isMultiSlotLeaf(exp) {
		return c.loadMultiSlot(exp, result)
	}
	// this/self 字段访问（self.x）：this 是指针，需先加载再间接寻址
	if exp.Var != nil && isThisField(exp.Var) {
		pre, addr, reg := c.thisMem(exp.Var)
		prefix := c.fieldValPrefix(exp.Var.Type)
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
	// 指针基字段访问（p.x）：先加载指针值再间接寻址
	if exp.Var != nil && needPtrMem(exp.Var) {
		pre, addr, reg := c.ptrMem(exp.Var)
		prefix := c.fieldValPrefix(exp.Var.Type)
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
	// 常量 → QWORD 内存槽：NASM mov r/m64,imm 只支持 imm32（符号扩展），
	// 因此 ≥2^31 的正数会被扩展成负值（4294967295 → 全 F），
	// 必须拆成高低两条 mov dword（x86_64 防符号扩展，x86 直接非法）
	if strings.Contains(result, "QWORD[") && !strings.Contains(val, "[") {
		if num, err := strconv.ParseFloat(val, 64); err == nil {
			if num > 0x7FFFFFFF || num < -0x80000000 || c.arch.PointerSize() == 4 {
				loAddr := strings.Replace(result, "QWORD[", "DWORD[", 1)
				hiAddr := hiMemAddr(loAddr)
				lo32 := int64(num) & 0xFFFFFFFF
				hi32 := (int64(num) >> 32) & 0xFFFFFFFF
				return utils.Format("mov " + loAddr + ", " + strconv.FormatInt(lo32, 10) + "; 64bit low") +
					utils.Format("mov " + hiAddr + ", " + strconv.FormatInt(hi32, 10) + "; 64bit high")
			}
		}
	}
	if result == "push" {
		// x86_64：push 仅支持 64 位操作数，窄内存值经 EAX 零扩展后 push RAX
		if c.arch.PointerSize() == 8 {
			switch memPrefix(val) {
			case "BYTE", "WORD", "DWORD":
				return utils.Format("mov EAX, " + val) +
					utils.Format("push RAX")
			}
		}
		// 大立即数：push 只支持 32 位有符号立即数（符号扩展），超出必须经 RAX 中转
		if !strings.Contains(val, "[") {
			if num, err := strconv.ParseFloat(val, 64); err == nil {
				if num > 0x7FFFFFFF || num < -0x80000000 {
					return utils.Format("mov RAX, " + val) +
						utils.Format("push RAX")
				}
			}
		}
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
		if exp.StringVal != "" {
			return c.getStringLabel(exp.StringVal)
		}
		if exp.Type != nil && exp.Type.Kind() == "bool" {
			if exp.Bool {
				return "1"
			}
			return "0"
		}
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

// fieldValPrefix 字段访问的读写宽度：指针字段按指针大小（存的是地址），
// 标量按自身宽度；容器/超宽字段由 loadContainer 等路径处理，回退指针宽度。
func (c *ECompiler) fieldValPrefix(t typeSys.Type) string {
	if t == nil {
		return c.arch.LengthName(c.arch.PointerSize())
	}
	if isListLike(t) || t.Size() > c.arch.PointerSize() {
		return c.arch.LengthName(c.arch.PointerSize())
	}
	return c.arch.LengthName(t.Size())
}

// derefPrefix 返回解引用类型的内存操作宽度前缀（BYTE/WORD/DWORD/QWORD）。// 真实指针（IsPointer）的宽度取被指类型 Elem 的大小；
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

// hiMemAddr 返回 DWORD 内存操作数的相邻高 4 字节地址（[rbp-48] → [rbp-44]）
func hiMemAddr(dwordAddr string) string {
	idx := strings.LastIndex(dwordAddr, "]")
	if idx == -1 {
		return dwordAddr
	}
	base := dwordAddr[:idx]
	plus := strings.LastIndex(base, "+")
	if plus != -1 {
		if off, err := strconv.Atoi(base[plus+1:]); err == nil {
			return base[:plus] + "+" + strconv.Itoa(off+4) + "]"
		}
	}
	if minus := strings.LastIndex(base, "-"); minus != -1 {
		if off, err := strconv.Atoi(base[minus+1:]); err == nil {
			return base[:minus] + "-" + strconv.Itoa(off-4) + "]"
		}
	}
	return dwordAddr
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

	// 如果右子有调用或包含除法（强制占用 EAX/EDX），保存左子结果到 callee-save。
	// allocRegAvoid 的后缀掩码依赖 BindIndex 预赋值，生成期懒赋值导致未来除法节点
	// 的需求不可见，此处按 HardBindMask 兜底保护跨除法存活的左值。
	callee := ""
	if ei.Right.HasCall || ei.Right.HardBindMask&c.arch.NeedBindMask("/") != 0 {
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

	// 如果左子有调用或包含除法（强制占用 EAX/EDX），保存右子结果到 callee-save
	callee := ""
	rVal := rReg.Name
	if ei.Left.HasCall || ei.Left.HardBindMask&c.arch.NeedBindMask("/") != 0 {
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

// loadContainerPair 装载容器表达式到 {ptr, len} 寄存器对（常量/变量/函数调用）
func (c *ECompiler) loadContainerPair(exp *parser.Expression, r0, r1 string) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	if exp.IsConst() && isListLike(exp.Type) {
		label := "0"
		if exp.StringVal != "" {
			label = c.getStringLabel(exp.StringVal)
		}
		slen := len(exp.StringVal)
		return utils.Format("mov " + r0 + ", " + label) +
			utils.Format("mov " + r1 + ", " + strconv.Itoa(slen))
	}
	if exp.Var != nil && isListLike(exp.Var.Type) {
		if isThisField(exp.Var) {
			// this/self 字段：this 是指针，先经寄存器装载再间接寻址
			p2, addr2, reg2 := c.thisMem(exp.Var)
			code := p2 + utils.Format("mov "+r0+", "+ln+" ["+addr2+"]") +
				utils.Format("mov "+r1+", "+ln+" ["+addr2+"+"+strconv.Itoa(ps)+"]")
			c.freeTmpReg(reg2)
			return code
		}
		src := stripOuterBrackets(c.arch.VarAddr(exp.Var))
		return utils.Format("mov " + r0 + ", " + ln + " [" + src + "]") +
			utils.Format("mov " + r1 + ", " + ln + " [" + src + "+" + strconv.Itoa(ps) + "]")
	}
	if exp.Call != nil {
		code := c.arch.Call(exp.Call)
		retBase := c.arch.FramePtr() + strconv.Itoa(c.ctx.RetSlot)
		code += utils.Format("mov " + r0 + ", " + ln + " [" + retBase + "]")
		code += utils.Format("mov " + r1 + ", " + ln + " [" + retBase + "+" + strconv.Itoa(ps) + "]")
		return code
	}
	// 嵌套表达式（如字符串拼接链的内层）：递归编译到返回槽再装载
	if exp.Separator != "" {
		retBase := c.arch.FramePtr() + strconv.Itoa(c.ctx.RetSlot)
		code := c.generate(exp, "["+retBase+"]")
		return code + utils.Format("mov " + r0 + ", " + ln + " [" + retBase + "]") +
			utils.Format("mov " + r1 + ", " + ln + " [" + retBase + "+" + strconv.Itoa(ps) + "]")
	}
	return ""
}

// allocRegSecond 分配除 avoidName 外的另一个空闲寄存器（不记入 Record，需手动 Free）
func (c *ECompiler) allocRegSecond(avoidNames ...string) *regmgr.Reg {
	for _, reg := range c.ctx.Reg.Regs {
		ok := true
		for _, n := range avoidNames {
			if reg.Name == n {
				ok = false
				break
			}
		}
		if ok && reg.Free {
			reg.Free = false
			reg.ExpID = 0
			reg.User = nil
			return reg
		}
	}
	return nil
}

// stringConcatExp 运行期字符串拼接：malloc 新缓冲 + 两段 rep movsb + 双 NUL + 三槽装载
// 左/右容器经 loadContainerPair 装载到寄存器后压栈暂存，避免调用间破坏。
func (c *ECompiler) stringConcatExp(exp *parser.Expression, result string, ei *ExpInfo) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	code := ""

	// 左容器 → 寄存器对 → 压栈（左ptr、左len）
	l0 := c.allocReg(exp.Left)
	l1 := c.allocRegSecond(l0.Name)
	if l0 == nil {
		l0 = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	if l1 == nil {
		l1 = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code += c.loadContainerPair(exp.Left, l0.Name, l1.Name)
	code += utils.Format("push " + l0.Name)
	code += utils.Format("push " + l1.Name)
	c.ctx.Reg.Free(exp.Left)
	l1.Free = true

	// 右容器 → 寄存器对 → 压栈（右ptr、右len）
	r0 := c.allocReg(exp.Right)
	r1 := c.allocRegSecond(r0.Name)
	if r0 == nil {
		r0 = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	if r1 == nil {
		r1 = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code += c.loadContainerPair(exp.Right, r0.Name, r1.Name)
	code += utils.Format("push " + r0.Name)
	code += utils.Format("push " + r1.Name)
	c.ctx.Reg.Free(exp.Right)
	r1.Free = true

	// 固定工作区（跨 call 安全）：
	// x64：pop 到 callee-save R12-R15（malloc 会保存它们）
	// x86：留在栈上（EBX 是唯一 callee-save，作新 ptr；四值经 [esp+N] 访问）
	var rLen, rPtr, lLen, lPtr, tmp1, tmp2, ret string
	ret = c.arch.ReturnReg()
	if ps == 8 {
		code += utils.Format("pop R12") // 右len
		code += utils.Format("pop R13") // 右ptr
		code += utils.Format("pop R14") // 左len
		code += utils.Format("pop R15") // 左ptr
		rLen, rPtr, lLen, lPtr = "R12", "R13", "R14", "R15"
		tmp1, tmp2 = "R9", "RDI"
	} else {
		rLen, rPtr, lLen, lPtr = "0", "4", "8", "12" // [esp+N] 偏移
		tmp1, tmp2 = "EAX", "ECX"
	}

	// total = 左len + 右len；x86 压栈暂存（x64 在 call 后用 R14/R12 重算，
	// 因为 callee 的参数保存槽 [rbp+16] 会落在 caller 的 rsp 处，压栈值会被覆盖）
	if ps == 8 {
		code += utils.Format("mov " + tmp1 + ", " + lLen)
		code += utils.Format("add " + tmp1 + ", " + rLen)
	} else {
		code += utils.Format("mov " + tmp1 + ", [esp+" + lLen + "]")
		code += utils.Format("add " + tmp1 + ", [esp+" + rLen + "]")
		code += utils.Format("push " + tmp1)
	}

	// malloc(align8(total+1))：x64 RDI 传参；x86 压栈传参
	code += utils.Format("lea " + tmp2 + ", [" + tmp1 + "+8]")
	code += utils.Format("and " + tmp2 + ", -8")
	if ps == 8 {
		code += utils.Format("mov RDI, " + tmp2) +
			utils.Format("call std_memory_malloc1")
	} else {
		code += utils.Format("push " + tmp2) +
			utils.Format("call std_memory_malloc1") +
			utils.Format("add esp, 4")
	}
	code += utils.Format("mov " + ret + ", " + c.arch.ReturnReg())

	// 右段拷贝：dst = new + 左len，src = 右ptr，count = 右len
	if ps == 8 {
		code += utils.Format("mov " + tmp2 + ", " + ret)
		code += utils.Format("add " + tmp2 + ", " + lLen)
		code += utils.Format("mov RSI, " + rPtr)
		code += utils.Format("mov RCX, " + rLen)
	} else {
		// 栈布局（esp→）：[esp+0]=total、[esp+4]=右len、[esp+8]=右ptr、[esp+12]=左len、[esp+16]=左ptr
		code += utils.Format("mov EDI, " + ret)
		code += utils.Format("add EDI, [esp+12]")
		code += utils.Format("mov ESI, [esp+8]")
		code += utils.Format("mov ECX, [esp+4]")
	}
	code += utils.Format("rep movsb")

	// 左段拷贝：dst = new，src = 左ptr，count = 左len
	if ps == 8 {
		code += utils.Format("mov " + tmp2 + ", " + ret)
		code += utils.Format("mov RSI, " + lPtr)
		code += utils.Format("mov RCX, " + lLen)
	} else {
		code += utils.Format("mov EDI, " + ret)
		code += utils.Format("mov ESI, [esp+16]")
		code += utils.Format("mov ECX, [esp+12]")
	}
	code += utils.Format("rep movsb")

	// 双 NUL 终止
	if ps == 8 {
		// 重算 total：R9 已被 call 污染，R14（左len）/R12（右len）为 callee-saved 仍存活
		code += utils.Format("mov " + tmp1 + ", " + lLen)
		code += utils.Format("add " + tmp1 + ", " + rLen)
		code += utils.Format("mov byte [" + ret + "+" + tmp1 + "], 0")
		code += utils.Format("mov byte [" + ret + "+" + tmp1 + "+1], 0")
		// cap = align8(total+1) - 1
		code += utils.Format("lea " + rLen + ", [" + tmp1 + "+8]")
		code += utils.Format("and " + rLen + ", -8")
		code += utils.Format("dec " + rLen)
	} else {
		code += utils.Format("mov EDX, [esp+0]") // total
		code += utils.Format("mov byte [" + ret + "+EDX], 0")
		code += utils.Format("mov byte [" + ret + "+EDX+1], 0")
		code += utils.Format("lea ECX, [EDX+8]")
		code += utils.Format("and ECX, -8")
		code += utils.Format("dec ECX")
		rLen, lLen = "ECX", "EDX"
	}

	// 装载结果三槽 {ptr, len, cap}
	if ps == 8 {
		// x64：rLen 已被覆盖为 cap，total 仍在 tmp1（R9）中
		if result == "push" {
			code += utils.Format("push " + rLen)  // cap
			code += utils.Format("push " + tmp1)  // len
			code += utils.Format("push " + ret)   // ptr
		} else if strings.Contains(result, "[") {
			code += utils.Format("mov " + ln + " [" + stripOuterBrackets(result) + "], " + ret)
			code += utils.Format("mov " + ln + " [" + stripOuterBrackets(result) + "+" + strconv.Itoa(ps) + "], " + tmp1)
			code += utils.Format("mov " + ln + " [" + stripOuterBrackets(result) + "+" + strconv.Itoa(2*ps) + "], " + rLen)
		} else {
			code += utils.Format("mov " + result + ", " + ret)
		}
	} else {
		if result == "push" {
			code += utils.Format("push " + rLen)  // cap
			code += utils.Format("push " + lLen)  // len
			code += utils.Format("push " + ret)   // ptr
		} else if strings.Contains(result, "[") {
			code += utils.Format("mov " + ln + " [" + stripOuterBrackets(result) + "], " + ret)
			code += utils.Format("mov " + ln + " [" + stripOuterBrackets(result) + "+" + strconv.Itoa(ps) + "], " + lLen)
			code += utils.Format("mov " + ln + " [" + stripOuterBrackets(result) + "+" + strconv.Itoa(2*ps) + "], " + rLen)
		} else {
			code += utils.Format("mov " + result + ", " + ret)
		}
	}

	// 清理暂存槽：x86 5 个（total、右len、右ptr、左len、左ptr）；x64 无
	if ps != 8 {
		code += utils.Format("add esp, 20")
	}
	return code
}

// isListLike 判断是否为三字段容器类型（list/string）
func isListLike(t typeSys.Type) bool {
	return t != nil && (t.Kind() == "list" || t.Kind() == "string")
}

// isMultiSlotLeaf 判断叶子表达式是否为多槽值（容器 3 槽 / 结构体 N 槽）
func (c *ECompiler) isMultiSlotLeaf(exp *parser.Expression) bool {
	if exp.IsConst() && isListLike(exp.Type) {
		return true
	}
	if exp.Var != nil && exp.Var.Type != nil {
		if isListLike(exp.Var.Type) {
			return true
		}
		return exp.Var.Type.Size() > c.arch.PointerSize()
	}
	return false
}

// loadMultiSlot 多槽叶子装载：容器 3 槽；结构体按 Size/PointerSize 槽数
func (c *ECompiler) loadMultiSlot(exp *parser.Expression, result string) string {
	if exp.Var != nil && exp.Var.Type != nil && !isListLike(exp.Var.Type) {
		return c.loadStruct(exp.Var, result)
	}
	return c.loadContainer(exp, result)
}

// loadStruct 结构体叶子多槽装载（值语义拷贝：按 PointerSize 分槽）
func (c *ECompiler) loadStruct(v *parser.VarBlock, result string) string {
	if v == nil || v.Type == nil {
		return ""
	}
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	slots := v.Type.Size() / ps
	src := stripOuterBrackets(c.arch.VarAddr(v))
	pre := ""
	if isThisField(v) {
		p2, addr2, reg2 := c.thisMem(v)
		pre = p2
		src = addr2
		defer c.freeTmpReg(reg2)
	} else if needPtrMem(v) {
		p3, addr3, reg3 := c.ptrMem(v)
		pre = p3
		src = addr3
		defer c.freeTmpReg(reg3)
	}
	if result == "push" {
		// 高地址槽先入栈
		var code string
		for i := slots - 1; i >= 0; i-- {
			off := i * ps
			if off == 0 {
				code += utils.Format("push " + ln + " [" + src + "]")
			} else {
				code += utils.Format("push " + ln + " [" + src + "+" + strconv.Itoa(off) + "]")
			}
		}
		return pre + code
	}
	if strings.Contains(result, "[") {
		return pre + c.copySlots(stripOuterBrackets(result), src, slots*ps)
	}
	return pre + utils.Format("mov " + result + ", " + ln + " [" + src + "]")
}

// loadContainer 容器（list/string）叶子三槽装载：常量 → {label, len, len}；变量 → 从内存读三槽
func (c *ECompiler) loadContainer(exp *parser.Expression, result string) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	if exp.IsConst() && isListLike(exp.Type) {
		label := "0"
		if exp.StringVal != "" {
			label = c.getStringLabel(exp.StringVal)
		}
		slen := len(exp.StringVal)
		return c.emit3(result, label, slen, slen)
	}
	if exp.Var != nil && isListLike(exp.Var.Type) {
		src := stripOuterBrackets(c.arch.VarAddr(exp.Var))
		pre := ""
		if isThisField(exp.Var) {
			// this/self 字段：this 是指针，先经寄存器装载再间接寻址
			p2, addr2, reg2 := c.thisMem(exp.Var)
			pre = p2
			src = addr2
			defer c.freeTmpReg(reg2)
		} else if needPtrMem(exp.Var) {
			// 指针基字段（p.s）：先加载指针值再间接寻址
			p3, addr3, reg3 := c.ptrMem(exp.Var)
			pre = p3
			src = addr3
			defer c.freeTmpReg(reg3)
		}
		if result == "push" {
			// 高地址槽先入栈：cap、len、ptr
			var code string
			for i := 2; i >= 0; i-- {
				off := i * ps
				code += utils.Format("push " + ln + " [" + src + "+" + strconv.Itoa(off) + "]")
			}
			return pre + code
		}
		if strings.Contains(result, "[") {
			return pre + c.copySlots(stripOuterBrackets(result), src, 3*ps)
		}
		return pre + utils.Format("mov " + result + ", " + ln + " [" + src + "]")
	}
	return ""
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
	// 64 位槽 + 纯数值：imm32 编码会被符号扩展（4294967295 → -1 全 F），
	// 超出有符号 imm32 的常量经 64 位寄存器中转
	if ln == "QWORD" {
		if n, err := strconv.ParseFloat(val, 64); err == nil &&
			(n > 2147483647 || n < -2147483648) {
			tmp := c.arch.ReturnReg()
			return utils.Format("movabs "+tmp+", "+strconv.FormatInt(int64(n), 10)) +
				utils.Format("mov "+dst+", "+tmp)
		}
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
// push 顺序：cap/len/ptr（ptr 最后入栈落在低地址，与 callee 参数槽序一致）
func (c *ECompiler) emit3(result, ptrReg string, length, cap int) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	if result == "push" {
		code := utils.Format("push " + strconv.Itoa(cap))
		code += utils.Format("push " + strconv.Itoa(length))
		code += utils.Format("push " + ptrReg)
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
			if elem.IsConst() {
				label := "0"
				if elem.StringVal != "" {
					label = c.getStringLabel(elem.StringVal)
				}
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
	if elemSize > c.arch.PointerSize() {
		// 多槽元素（string）赋值暂不支持非常量源
		return ""
	}

	// 1. 列表指针 → aReg
	aReg := c.allocRegAvoid(indexExpr.Right, "")
	if aReg == nil {
		aReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
	}
	code := c.generate(indexExpr.Right, aReg.Name)

	// 2. 索引偏移
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

	// 3. 值最后装载到寄存器（先算地址：期间 EAX 空闲可作临时，避免覆盖值）
	vReg := c.allocReg(exp.Right)
	if vReg == nil {
		vReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code += c.generate(exp.Right, vReg.Name)

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
	sp := c.arch.StackPtr()
	ln := c.arch.LengthName(ps)
	_, lenOff, capOff := c.listFields()
	loExpr := exp.Index[0]
	hiExpr := exp.Index[1]

	var code string
	ptrReg := c.allocReg(exp.Right)
	if ptrReg == nil {
		ptrReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code += c.generate(exp.Right, ptrReg.Name)
	if ro := c.getRegByName(ptrReg.Name); ro != nil {
		c.ctx.Reg.Force(ro, exp.Right)
	}

	var loReg *regmgr.Reg
	loConst := 0

	// 3. lo：常量直接折叠；非常量分配独立寄存器（绑定后分配器避开基址）；
	//    枯竭复用同名时走栈中转序列（预留三结果槽，lo 暂存于 cap 槽）。
	loExhausted := false
	if loExpr != nil && loExpr.IsConst() {
		loConst = int(loExpr.Num)
		code += utils.Format("add " + ptrReg.Name + ", " + strconv.Itoa(loConst*elemSize))
	} else if loExpr != nil {
		// 32 位通用寄存器仅 6 个，嵌套子表达式编译的临时分配不感知外部
		// 持有值，非常量边界一律走栈中转序列（下方 loExhausted 分支）；
		// x86_64 寄存器充裕，走正常分配路径。
		// 双架构统一走栈中转：不依赖分配器感知，行为确定
		loExhausted = true
	}

	if loExhausted {
		retReg := c.arch.ReturnReg()
		// 预留三结果槽（按指针大小）：R.ptr=[sp]、R.len=[sp+ps]、R.cap=[sp+2ps]
		code += utils.Format("sub "+ sp +", " + strconv.Itoa(3*ps))
		code += c.generate(loExpr, retReg)
		code += utils.Format("imul " + retReg + ", " + strconv.Itoa(elemSize))
		code += utils.Format("mov " + ln + " ["+ sp +"+" + strconv.Itoa(2*ps) + "], " + retReg + "; R.cap 槽暂存 lo")
		code += c.generate(exp.Right, retReg)
		code += utils.Format("add " + retReg + ", ["+ sp +"+" + strconv.Itoa(2*ps) +"]")
		code += utils.Format("mov " + ln + " ["+ sp +"], " + retReg + "; R.ptr")
		// len（既有语义：hi 不缩放）
		if hiExpr != nil && !hiExpr.IsConst() {
			code += c.generate(hiExpr, retReg)
			code += utils.Format("sub " + retReg + ", ["+ sp +"+" + strconv.Itoa(2*ps) + "]")
			code += utils.Format("mov " + ln + " ["+ sp +"+" + strconv.Itoa(ps) + "], " + retReg + "; R.len")
		} else if hiExpr != nil {
			code += utils.Format("mov " + retReg + ", " + strconv.Itoa(int(hiExpr.Num)))
			code += utils.Format("sub " + retReg + ", ["+ sp +"+" + strconv.Itoa(2*ps) + "]")
			code += utils.Format("mov " + ln + " ["+ sp +"+" + strconv.Itoa(ps) + "], " + retReg + "; R.len")
		} else {
			code += utils.Format("mov dword ["+ sp +"+" + strconv.Itoa(ps) + "], 0; R.len")
		}
		// cap
		if exp.Right.Var != nil {
			capAddr := stripOuterBrackets(c.arch.VarAddr(exp.Right.Var)) + "+" + strconv.Itoa(capOff)
			code += utils.Format("mov " + retReg + ", " + ln + " [" + capAddr + "]")
			code += utils.Format("sub " + retReg + ", ["+ sp +"+" + strconv.Itoa(2*ps) + "]")
			code += utils.Format("mov " + ln + " ["+ sp +"+" + strconv.Itoa(2*ps) + "], " + retReg + "; R.cap")
		} else {
			code += utils.Format("mov dword ["+ sp +"+" + strconv.Itoa(2*ps) +"], 0; R.cap")
		}
		// 交付
		if strings.Contains(result, "[") {
			base := stripOuterBrackets(result)
			code += c.storeVal(base, ln, ln+" ["+ sp +"]")
			code += c.storeVal(base+"+"+strconv.Itoa(lenOff), ln, ln+" ["+ sp +"+" + strconv.Itoa(ps) +"]")
			code += c.storeVal(base+"+"+strconv.Itoa(capOff), ln, ln+" ["+ sp +"+" + strconv.Itoa(2*ps) +"]")
			code += utils.Format("add "+ sp +", " + strconv.Itoa(3*ps))
		} else if result == "push" {
			// 三槽布局 [sp]=ptr、[sp+4]=len、[sp+8]=cap 已与 cdecl
			// 从右到左压参后的 callee 读取序一致（[ebp+16]=ptr），无需翻转
		} else {
			code += utils.Format("pop " + result + "; R.ptr")
			code += utils.Format("add "+ sp +", " + strconv.Itoa(2*ps) + "; 清 R.len/R.cap 槽")
		}
		c.ctx.Reg.Free(loExpr)
		c.ctx.Reg.Free(hiExpr)
		c.ctx.Reg.Free(exp.Right)
		return code
	}

	if loReg != nil {
		// 物理保护基址：内层表达式编译的临时分配不感知外部持有值
		code += utils.Format("push " + ptrReg.Name + "; 保护基址")
		code += c.generate(loExpr, loReg.Name)
		code += utils.Format("imul " + loReg.Name + ", " + strconv.Itoa(elemSize))
		code += utils.Format("mov " + ptrReg.Name + ", ["+ sp +"]")
		code += utils.Format("add " + ptrReg.Name + ", " + loReg.Name)
		code += utils.Format("add "+ sp +", " + strconv.Itoa(ps))
	}

	// 4+5. 统一保护块：len 与 cap 在同一保护区内经返回寄存器串行计算。
	// 压序：lo(若有)→基址；栈布局 [0]=lo、[ps]=基址；子表达式编译全程可安全
	// 覆盖任何寄存器（持有值都在栈上），彻底规避分配器不感知外部持有的问题。
	pushedLo := false
	if loReg != nil {
		code += utils.Format("push " + loReg.Name + "; 保护 lo")
		pushedLo = true
	}
	code += utils.Format("push " + ptrReg.Name + "; 保护基址")
	loSlot := "[" + sp + "]"

	var lenVal string
	if hiExpr != nil && hiExpr.IsConst() {
		lenVal = strconv.Itoa(int(hiExpr.Num) - loConst)
	} else if hiExpr != nil {
		retReg := c.arch.ReturnReg()
		code += c.generate(hiExpr, retReg)
		if pushedLo {
			code += utils.Format("sub " + retReg + ", " + ln + " " + loSlot + "; len = hi - lo")
		} else {
			code += utils.Format("sub " + retReg + ", " + strconv.Itoa(loConst))
		}
		lenVal = retReg
	} else {
		lenVal = "0"
	}

	var capVal string
	if exp.Right.Var != nil {
		capAddr := stripOuterBrackets(c.arch.VarAddr(exp.Right.Var)) + "+" + strconv.Itoa(capOff)
		retReg := c.arch.ReturnReg()
		code += utils.Format("mov " + retReg + ", " + ln + " [" + capAddr + "]")
		if pushedLo {
			code += utils.Format("sub " + retReg + ", " + ln + " " + loSlot + "; cap - lo")
		} else if loConst != 0 {
			code += utils.Format("sub " + retReg + ", " + strconv.Itoa(loConst))
		}
		capVal = retReg
	} else {
		capVal = "0"
	}

	// 6. 交付。栈顶当前：[0]=基址、[ps]=lo（保护槽）。
	deliveredPtr := false
	if strings.Contains(result, "[") {
		base := stripOuterBrackets(result)
		tmp := c.allocTmpReg()
		code += utils.Format("mov " + tmp.Name + ", [" + sp + "+" + strconv.Itoa(ps) + "]")
		code += utils.Format("add " + tmp.Name + ", [" + sp + "]")
		code += c.storeVal(base, ln, tmp.Name)
		code += c.storeVal(base+"+"+strconv.Itoa(lenOff), ln, matchMemWidth(base+"+"+strconv.Itoa(lenOff), lenVal))
		code += c.storeVal(base+"+"+strconv.Itoa(capOff), ln, matchMemWidth(base+"+"+strconv.Itoa(capOff), capVal))
		code += utils.Format("add " + sp + ", " + strconv.Itoa(2*ps))
		c.freeTmpReg(tmp)
		deliveredPtr = true
	} else if result == "push" {
		// 交付序：先 cap/len（压在深处），最后弹基址折叠成 ptr 压入顶端。
		// 栈：[0]=基址 [ps]=lo；先压 capVal/lenVal 会落在保护槽上方，
		// 因此顺序：push capVal、push lenVal、pop→加→push ptr、清两保护槽。
		code += utils.Format("push " + capVal + "; cap")
		code += utils.Format("push " + lenVal + "; len")
		code += utils.Format("mov " + ptrReg.Name + ", [" + sp + "+" + strconv.Itoa(2*ps) + "]")
		code += utils.Format("add " + ptrReg.Name + ", [" + sp + "+" + strconv.Itoa(ps) + "]")
		code += utils.Format("push " + ptrReg.Name + "; ptr")
		code += utils.Format("add " + sp + ", " + strconv.Itoa(2*ps) + "; 清保护槽")
		deliveredPtr = true
	} else {
		// 寄存器结果
		tmp := c.allocTmpReg()
		code += utils.Format("mov " + tmp.Name + ", [" + sp + "+" + strconv.Itoa(ps) + "]")
		code += utils.Format("add " + tmp.Name + ", [" + sp + "]")
		code += utils.Format("mov " + result + ", " + matchMemWidth(result, tmp.Name))
		code += utils.Format("add " + sp + ", " + strconv.Itoa(2*ps))
		c.freeTmpReg(tmp)
		deliveredPtr = true
	}

	if !deliveredPtr {
		code += utils.Format("add " + sp + ", " + strconv.Itoa(2*ps))
	}

	c.ctx.Reg.Free(loExpr)
	c.ctx.Reg.Free(hiExpr)
	c.ctx.Reg.Free(exp.Right)
	return code
}

// listFieldRead 读容器字段（len/cap）：变量直接读三槽；表达式先算 ptr 再偏移
// builtinStringSlotCall len(s)/cap(s)（string 参数）链接到全局符号实现：
// 装载容器地址后 call __string_len/cap（由 strings 包 build link 提供）。
// 返回 EAX/RAX；结果装载模式与 listFieldRead 一致（push/[mem]/寄存器）。
func (c *ECompiler) builtinStringSlotCall(arg *parser.Expression, sym string, result string) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	var code string
	// 与普通容器实参一致的三槽传递（RDI/RSI/RDX = ptr/len/cap，
	// 或 32 位栈上 cap/len/ptr 右到左压栈），被调方按标准约定溢出/读取
	base := stripOuterBrackets(c.arch.VarAddr(arg.Var))
	// 直接以内存操作数装载三槽（无需地址寄存器，避免与目标寄存器同名冲突）
	if ps == 8 {
		code += utils.Format("mov RDI, " + ln + " [" + base + "]")
		code += utils.Format("mov RSI, " + ln + " [" + base + "+" + strconv.Itoa(ps) + "]")
		code += utils.Format("mov RDX, " + ln + " [" + base + "+" + strconv.Itoa(2*ps) + "]")
	} else {
		code += utils.Format("push " + ln + " [" + base + "+" + strconv.Itoa(2*ps) + "]")
		code += utils.Format("push " + ln + " [" + base + "+" + strconv.Itoa(ps) + "]")
		code += utils.Format("push " + ln + " [" + base + "]")
	}
	code += utils.Format("call " + sym)
	if ps == 4 {
		code += utils.Format("add esp, 12")
	}
	// 结果装载（返回 EAX/RAX）。retReg 中是长度值本身，
	// 不是指针 —— 直接 mov 到目标，禁止经 derefLoad 二次解引用
	retReg := c.arch.ReturnReg()
	if result == "push" {
		code += utils.Format("push " + retReg)
	} else if strings.Contains(result, "[") {
		code += utils.Format("mov " + result + ", " + matchMemWidth(result, retReg))
	} else {
		code += utils.Format("mov " + result + ", " + retReg + "; len/cap 结果")
	}
	return code
}

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
			// string 参数且 build link 提供了全局符号（strings 包实现）：
			// 改为 call __string_len/cap，链接到 strings 包的具体实现。
			// 仅变量参数走 link 路径（需按三槽寄存器约定传参）；
			// 其它表达式回退内联槽位读取。
			if call.Args[0].Value.Type.Kind() == "string" && call.Args[0].Value.Var != nil &&
				c.ctx.StringSyms != nil && c.ctx.StringSyms["__string_"+name] {
				return c.builtinStringSlotCall(call.Args[0].Value, "__string_"+name, result)
			}
			return c.listFieldRead(call.Args[0].Value, off, result)
		}
	case "append":
		return c.builtinAppend(call, result)
	case "copy":
		return c.builtinCopy(call, result)
	case "make":
		return c.builtinMake(exp, call, result)
	case "new":
		return c.builtinNew(exp, call, result)
	}
	return ""
}

// builtinCopy copy(dst, src)：同 Kind 容器（str/str 或 list/list）元素拷贝，
// 拷贝 min(len(dst), len(src)) 个元素，返回拷贝计数。
// v1 与 append 同约束：dst/src 必须为容器变量（直接取栈地址读三槽）。
// 注意：字符串字面量位于只读 .data 段，不可作为 dst。
// 实现：计数经栈中转交付；rep movsb 前后保存/恢复 RSI/RDI/RCX。
func (c *ECompiler) builtinCopy(call *parser.CallBlock, result string) string {
	if len(call.Args) < 2 || call.Args[0] == nil || call.Args[0].Value == nil ||
		call.Args[1] == nil || call.Args[1].Value == nil {
		return ""
	}
	dstExp := call.Args[0].Value
	srcExp := call.Args[1].Value
	if dstExp.Var == nil || srcExp.Var == nil ||
		dstExp.Type == nil || srcExp.Type == nil ||
		dstExp.Type.Kind() != srcExp.Type.Kind() || !isListLike(dstExp.Type) {
		return ""
	}
	elemSize := 1
	if lt, ok := dstExp.Type.(*typeSys.ListType); ok && lt.Elem() != nil {
		elemSize = lt.Elem().Size()
	}
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	_, lenOff, _ := c.listFields()
	dstBase := stripOuterBrackets(c.arch.VarAddr(dstExp.Var))
	srcBase := stripOuterBrackets(c.arch.VarAddr(srcExp.Var))
	label := "copy_" + strconv.Itoa(c.idx)
	scratch := c.arch.ReturnReg()

	var code string
	// 计数 = min(len(dst), len(src))
	code += utils.Format("mov " + scratch + ", " + ln + " [" + dstBase + "+" + strconv.Itoa(lenOff) + "]")
	code += utils.Format("cmp " + scratch + ", " + ln + " [" + srcBase + "+" + strconv.Itoa(lenOff) + "]")
	code += utils.Format("jbe " + label + "_min")
	code += utils.Format("mov " + scratch + ", " + ln + " [" + srcBase + "+" + strconv.Itoa(lenOff) + "]")
	code += utils.Format(label + "_min:")

	// 元素计数压栈暂存（即结果），换算字节数
	code += utils.Format("push " + scratch + "; copy count")
	code += utils.Format("imul " + scratch + ", " + strconv.Itoa(elemSize))

	// rep movsb 字节拷贝（DF 保持清零；先保存可能存活的 SI/DI/CX）
	if ps == 8 {
		code += utils.Format("push RSI")
		code += utils.Format("push RDI")
		code += utils.Format("push RCX")
		code += utils.Format("mov RSI, " + ln + " [" + srcBase + "]")
		code += utils.Format("mov RDI, " + ln + " [" + dstBase + "]")
		code += utils.Format("mov RCX, " + scratch)
		code += utils.Format("rep movsb; copy bytes")
		code += utils.Format("pop RCX")
		code += utils.Format("pop RDI")
		code += utils.Format("pop RSI")
	} else {
		code += utils.Format("push ESI")
		code += utils.Format("push EDI")
		code += utils.Format("push ECX")
		code += utils.Format("mov ESI, " + ln + " [" + srcBase + "]")
		code += utils.Format("mov EDI, " + ln + " [" + dstBase + "]")
		code += utils.Format("mov ECX, " + scratch)
		code += utils.Format("rep movsb; copy bytes")
		code += utils.Format("pop ECX")
		code += utils.Format("pop EDI")
		code += utils.Format("pop ESI")
	}

	// 交付拷贝计数：push 模式下计数已在栈顶
	if result == "push" {
		return code
	}
	if strings.Contains(result, "[") {
		code += utils.Format("pop " + scratch + "; copy result")
		code += utils.Format("mov " + ln + " " + result + ", " + matchMemWidth(result, scratch))
		return code
	}
	code += utils.Format("pop " + result + "; copy result")
	return code
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

// builtinNew new(T[, v...])：堆上分配 Size(T) 字节并零填充，返回 *T；初值按字段偏移写入。
// 新对象地址压栈保存（[rsp]），不占用任何寄存器，避免覆盖调用方
// （Assign 指针字段路径 p.x = new(T) 的目标地址寄存器）与嵌套调用的活跃值。
func (c *ECompiler) builtinNew(exp *parser.Expression, call *parser.CallBlock, result string) string {
	if call.NewType == nil {
		return ""
	}
	// 列表创建：new(list[T], len[, cap])，按值返回三槽列表
	if lt, ok := call.NewType.(*typeSys.ListType); ok && lt.Elem() != nil {
		if len(call.Args) < 1 || call.Args[0] == nil || call.Args[0].Value == nil {
			return ""
		}
		lenExp := call.Args[0].Value
		capExp := lenExp
		if len(call.Args) > 1 && call.Args[1] != nil && call.Args[1].Value != nil {
			capExp = call.Args[1].Value
		}
		return c.emitListAlloc(lt, lenExp, capExp, result)
	}
	size := call.NewType.Size()
	if size <= 0 {
		return ""
	}
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	allocSize := align8(size)

	code := c.emitMalloc(allocSize)
	code += utils.Format("push " + c.arch.ReturnReg() + "; save new obj")

	// 零填充 allocSize 字节（含 padding）：地址从 [rsp] 装载到临时寄存器
	zreg := c.allocTmpReg()
	code += utils.Format("mov " + zreg.Name + ", " + ln + " [" + c.arch.StackPtr() + "]")
	code += utils.Format("mov " + c.arch.ReturnReg() + ", 0")
	for off := 0; off < allocSize; off += ps {
		code += utils.Format("mov " + ln + " [" + zreg.Name + "+" + strconv.Itoa(off) + "], " + c.arch.ReturnReg())
	}
	c.freeTmpReg(zreg)

	// 初值参数：按字段偏移写入（仅支持 ≤ps 的标量值）
	offs := make([]int, len(call.Args))
	if st, ok := call.NewType.(*typeSys.StructType); ok {
		fields := st.Fields()
		for i := 0; i < len(offs) && i < len(fields); i++ {
			offs[i] = fields[i].Offset
		}
	}
	for i, arg := range call.Args {
		if arg == nil || arg.Value == nil {
			continue
		}
		if i >= len(offs) {
			break
		}
		if arg.Value.Type != nil && arg.Value.Type.Size() > ps {
			continue
		}
		areg := c.allocTmpReg()
		code += utils.Format("mov " + areg.Name + ", " + ln + " [" + c.arch.StackPtr() + "]")
		if arg.Value.IsConst() {
			code += utils.Format("mov " + ln + " [" + areg.Name + "+" + strconv.Itoa(offs[i]) + "], " + strconv.FormatFloat(arg.Value.Num, 'f', 0, 64))
			c.freeTmpReg(areg)
			continue
		}
		vreg := c.allocReg(arg.Value)
		if vreg == nil {
			vreg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		code += c.generate(arg.Value, vreg.Name)
		code += utils.Format("mov " + ln + " [" + areg.Name + "+" + strconv.Itoa(offs[i]) + "], " + matchMemWidth(ln+"[", vreg.Name))
		c.ctx.Reg.Free(arg.Value)
		c.freeTmpReg(areg)
	}

	// 返回 *T（对象地址）：从 [rsp] 装载，恢复栈
	oreg := c.allocTmpReg()
	code += utils.Format("mov " + oreg.Name + ", " + ln + " [" + c.arch.StackPtr() + "]")
	code += utils.Format("add " + c.arch.StackPtr() + ", " + strconv.Itoa(ps) + "; drop new obj")
	if result == "push" {
		code += utils.Format("push " + oreg.Name)
	} else if strings.Contains(result, "[") {
		code += c.storeVal(stripOuterBrackets(result), ln, oreg.Name)
	} else {
		code += utils.Format("mov " + result + ", " + oreg.Name)
	}
	c.freeTmpReg(oreg)
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
	return c.emitListAlloc(lt, lenExp, capExp, result)
}

// emitListAlloc 列表堆分配：malloc(cap*es) + 零填充 len*es + 装载三字段。
// new(list[T], len[, cap]) 与 make(list[T], _, len[, cap]) 共用。
func (c *ECompiler) emitListAlloc(lt *typeSys.ListType, lenExp, capExp *parser.Expression, result string) string {
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
