package x86_64

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"cuteify/utils"
	"strings"
	"strconv"
)

// sysvArgRegs System V AMD64 ABI 参数寄存器（第1-6个参数）
var sysvArgRegs = []string{"RDI", "RSI", "RDX", "RCX", "R8", "R9"}

// sysvCalleeSaved System V ABI 的 callee-save 寄存器
var sysvCalleeSaved = []string{"RBX", "R12", "R13", "R14", "R15"}

// SysV 实现 x86_64 System V AMD64 ABI 调用约定。
type SysV struct {
	ctx *context.Context
	*x86_64Ops
}

func NewSysV(ctx *context.Context) *SysV {
	a := &SysV{
		ctx:       ctx,
		x86_64Ops: newOps(ctx, sysvCalleeSaved),
	}
	regs := cloneRegs(Regs, sysvCalleeSaved)
	ctx.Reg = regmgr.NewRegMgr(regs)
	ctx.PointerSize = 8
	ctx.Is64Bit = true
	ctx.StackAlignment = 16
	return a
}

// Info 返回调用约定的名称
func (a *SysV) Info() string { return "x86_64 System V AMD64 ABI" }

// Prologue 函数前序代码
func (a *SysV) Prologue(fn *parser.FuncBlock) (code string) {
	if fn == nil {
		panic("内部错误")
	}

	// 设置参数偏移量（rbp+16 起）
	setArgsOffset(fn)

	code += utils.Format("push rbp")
	code += utils.Format("mov rbp, rsp")

	// 固定保存所有 callee-save 寄存器（不依赖分配器记录，保证确定性和栈布局一致性）
	csRegs := a.CalleeSaveRegs()
	for _, regName := range csRegs {
		code += utils.Format("push " + regName + "; 保存" + regName)
	}

	a.ctx.StackSize = arch.SetupVarOffsets(a.ctx.Now, a.ctx.StackAlignment, -8*len(csRegs))

	// 预留大值返回槽：容器 24B + R10 保存 8B；结构体按槽数（Size/8）计算
	retBytes := 24
	if arch.FuncReturnsLarge(fn) {
		retBytes = arch.ArgSlots(fn.Return[0]) * 8
	}
	a.ctx.RetSlot = -(a.ctx.StackSize) - retBytes - 8
	a.ctx.StackSize += retBytes + 8

	if a.ctx.StackSize > 0 {
		code += utils.Format("sub rsp, " + strconv.Itoa(a.ctx.StackSize) + "; 分配局部变量空间(" + strconv.Itoa(a.ctx.StackSize) + "字节)")
	}

	// 大值返回函数：保存调用者传入的返回槽地址（R10）
	if arch.FuncReturnsLarge(fn) {
		code += utils.Format("mov QWORD [rbp" + strconv.Itoa(a.ctx.RetSlot+retBytes) + "], R10; 保存返回槽地址")
	}

	// 将寄存器参数保存到栈上(SysV ABI: RDI, RSI, RDX, RCX, R8, R9)
	argRegIdx := 0
	if fn.Class != nil {
		// 如果有this指针,第一个寄存器是this，保存到 [rbp+16]
		code += utils.Format("mov QWORD [rbp+16], " + sysvArgRegs[0] + "; this pointer")
		argRegIdx = 1
	}

	for i := 0; i < len(fn.Args); i++ {
		arg := fn.Args[i]
		slots := arch.ArgSlots(arg.Type)
		if slots > 1 {
			// 容器（3 槽）/ 大结构体（多槽）参数占连续寄存器
			if argRegIdx+slots-1 < len(sysvArgRegs) {
				for j := 0; j < slots; j++ {
					regName := sysvArgRegs[argRegIdx+j]
					addr := "[rbp+" + strconv.Itoa(arg.Offset+j*8) + "]"
					code += utils.Format("mov QWORD " + addr + ", " + regName + "; 保存参数" + strconv.Itoa(i) + "槽" + strconv.Itoa(j) + "到栈")
				}
			}
			argRegIdx += slots
		} else {
			if argRegIdx < len(sysvArgRegs) {
				regName := sysvArgRegs[argRegIdx]
				addr := "[rbp+" + strconv.Itoa(arg.Offset) + "]"
				// 窄类型（i32 等）按宽度保存，避免越界覆盖下一参数槽
				size := arg.Type.Size()
				if size != 8 {
					regName = sysvWidthName(regName, size)
				}
				code += utils.Format("mov " + GetLenName(size) + " " + addr + ", " + regName + "; 保存参数" + strconv.Itoa(i) + "到栈")
			}
			argRegIdx++
		}
	}

	return code
}

// Epilogue 函数后序代码(公共返回点)
func (a *SysV) Epilogue(fn *parser.FuncBlock) string {
	funcName := formatFuncName(fn.Name.NASM(), len(fn.Args))
	code := utils.Format("func_end_" + funcName + ":")

	// 清理局部变量栈空间
	if a.ctx.StackSize > 0 {
		code += utils.Format("add rsp, " + strconv.Itoa(a.ctx.StackSize) + "; 清理局部变量栈空间")
	}

	// 恢复 callee-save 寄存器(逆序)
	csRegs := a.CalleeSaveRegs()
	for i := len(csRegs) - 1; i >= 0; i-- {
		code += utils.Format("pop " + csRegs[i] + "; 恢复" + csRegs[i])
	}

	code += utils.Format("leave; 恢复栈帧")
	code += utils.Format("ret")
	code += "\n"
	return code
}

// Call 函数调用（SysV：前6个参数用寄存器 RDI/RSI/RDX/RCX/R8/R9，其余压栈）
func (a *SysV) Call(call *parser.CallBlock) (code string) {
	if call == nil || call.Func == nil {
		return ""
	}

	// 处理 list 方法调用（len/cap/ptr）
	if call.ThisVar != nil && call.ThisVar.Type != nil &&
		call.ThisVar.Type.Kind() == "list" && len(call.Args) == 0 {
		methodName := call.Name.Last()
		var fieldOffset int
		switch methodName {
		case "len":
			fieldOffset = 8
		case "cap":
			fieldOffset = 16
		case "ptr":
			fieldOffset = 0
		default:
			goto normalCall
		}
		addr := GenListFieldAddr(a.ctx, call.ThisVar, fieldOffset)
		return utils.Format("mov rax, QWORD " + addr + "; " + methodName + "()")
	}

normalCall:
	fn := call.Func

	// 大值返回函数：预留调用者返回槽地址（R10）
	isContainerRet := arch.FuncReturnsLarge(call.Func)

	// 统计需要压栈的参数个数（容器参数占 3 个寄存器/3 个栈槽）
	argRegIdx := 0

	// this 指针作为第一个寄存器参数
	if call.ThisVar != nil {
		thisAddr := GenVarAddr(a.ctx, call.ThisVar)
		if call.ThisVar.Type != nil && !call.ThisVar.Type.IsPointer() {
			// 值语义：传结构体地址（lea 取地址）
			addrOnly := thisAddr[strings.Index(thisAddr, "["):]
			code += utils.Format("lea " + sysvArgRegs[0] + ", " + addrOnly + "; this pointer")
		} else {
			code += utils.Format("mov " + sysvArgRegs[0] + ", " + thisAddr + "; this pointer")
		}
		argRegIdx = 1
	}

	// 预计算每个参数的寄存器区间
	argRegStart := make([]int, len(call.Args))
	cursor := argRegIdx
	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		argRegStart[i] = cursor
		cursor += arch.ArgSlots(arg.Type)
	}

	// 栈参数对齐（rsp 16 字节对齐）
	stackArgs := 0
	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		need := arch.ArgSlots(arg.Type)
		if argRegStart[i]+need > len(sysvArgRegs) {
			stackArgs += need
		}
	}
	if stackArgs > 0 {
		if stackArgs%2 != 0 {
			code += utils.Format("sub rsp, 8; align stack for stack args")
		}
	}

	// 压栈参数（从右到左，容器压 3 槽：cap/len/ptr，ptr 最后压落在低地址 [rbp+16] 槽）
	for i := len(call.Args) - 1; i >= 0; i-- {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		need := arch.ArgSlots(arg.Type)
		if argRegStart[i]+need > len(sysvArgRegs) {
			if arch.IsListLikeType(arg.Type) {
				code += a.pushContainer(arg.Value, "参数"+strconv.Itoa(i))
			} else {
				code += a.Exp(arg.Value, "push", "参数"+strconv.Itoa(i))
			}
		}
	}

	// 寄存器参数：先算好暂存到栈（装载内部调用或容器三槽装载会覆盖前序参数寄存器，
	// 且被调函数参数槽 [rbp+16] 落在调用者栈顶，内部调用参数区最大 64B（6 寄存器参数），
	// 故每个参数 push 后统一下沉 80B 安全区（标量总下沉 88B、容器 104B），
	// 全部算完后逆序 mov 到参数寄存器，最后 add rsp 恢复总量）
	type regArg struct {
		regs []string
		size int
	}
	var regArgs []regArg
	tempBytes := 0
	cursor = argRegIdx
	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		slots := arch.ArgSlots(arg.Type)
		if slots > 1 {
			if cursor+slots-1 < len(sysvArgRegs) {
				code += a.Exp(arg.Value, "push", "参数"+strconv.Itoa(i))
				code += utils.Format("sub rsp, 80; 下沉暂存多槽参数")
				tempBytes += 80 + slots*8
				regArgs = append(regArgs, regArg{regs: sysvArgRegs[cursor : cursor+slots], size: 80 + slots*8})
				cursor += slots
			} else {
				cursor += slots
			}
		} else {
			if cursor < len(sysvArgRegs) {
				code += a.Exp(arg.Value, "push", "参数"+strconv.Itoa(i))
				code += utils.Format("sub rsp, 80; 下沉暂存标量参数")
				tempBytes += 88
				regArgs = append(regArgs, regArg{regs: sysvArgRegs[cursor : cursor+1], size: 88})
				cursor++
			} else {
				cursor++
			}
		}
	}
	off := 80
	for j := len(regArgs) - 1; j >= 0; j-- {
		base := off
		for k := 0; k < len(regArgs[j].regs); k++ {
			code += utils.Format("mov " + regArgs[j].regs[k] + ", QWORD [rsp+" + strconv.Itoa(base+8*k) + "]; 装载暂存参数")
		}
		off += regArgs[j].size
	}
	if tempBytes > 0 {
		code += utils.Format("add rsp, " + strconv.Itoa(tempBytes) + "; 清理暂存参数")
	}

	if isContainerRet {
		code += utils.Format("lea R10, [rbp" + strconv.Itoa(a.ctx.RetSlot) + "]; 大值返回槽地址")
	}

	name := formatFuncName(fn.Name.NASM(), len(fn.Args))
	code += utils.Format("call " + name)

	// 清理栈参数
	if stackArgs > 0 {
		totalStackArgs := stackArgs * 8
		if stackArgs%2 != 0 {
			totalStackArgs += 8
		}
		code += utils.Format("add rsp, " + strconv.Itoa(totalStackArgs) + "; clean stack args")
	}

	return code
}

// stripOuterBrackets 去掉外层方括号
func stripOuterBrackets(addr string) string {
	if len(addr) >= 2 && strings.HasPrefix(addr, "[") && strings.HasSuffix(addr, "]") {
		return addr[1 : len(addr)-1]
	}
	return addr
}

// Return 函数返回
func (a *SysV) Return(ret *parser.ReturnBlock) (code string) {
	code = a.returnValue(ret)
	code += a.returnJump()
	return code
}

// stringLabel 获取/注册字符串常量标签
func (a *SysV) stringLabel(val string) string {
	if label, ok := a.ctx.StringConsts[val]; ok {
		return label
	}
	a.ctx.StrCount++
	label := "str_" + strconv.Itoa(a.ctx.StrCount)
	a.ctx.StringConsts[val] = label
	return label
}

// loadContainer3 容器（list/string）实参装载到 3 个连续寄存器
func (a *SysV) loadContainer3(exp *parser.Expression, regs []string, desc string) string {
	ps := a.ctx.PointerSize
	ln := a.ctx.Arch.LengthName(ps)
	if exp == nil {
		return ""
	}
	// 嵌套调用：先 call（返回值在本帧返回槽），再从返回槽读三槽
	if exp.Call != nil {
		code := a.Call(exp.Call)
		code += utils.Format("mov " + regs[0] + ", " + ln + " [rbp" + strconv.Itoa(a.ctx.RetSlot) + "]")
		code += utils.Format("mov " + regs[1] + ", " + ln + " [rbp" + strconv.Itoa(a.ctx.RetSlot+ps) + "]")
		code += utils.Format("mov " + regs[2] + ", " + ln + " [rbp" + strconv.Itoa(a.ctx.RetSlot+2*ps) + "]")
		return code
	}
	// 字符串常量
	if exp.IsConst() {
		label := "0"
		if exp.StringVal != "" {
			label = a.stringLabel(exp.StringVal)
		}
		slen := len(exp.StringVal)
		return utils.Format("mov " + regs[0] + ", " + label) +
			utils.Format("mov " + regs[1] + ", " + strconv.Itoa(slen)) +
			utils.Format("mov " + regs[2] + ", " + strconv.Itoa(slen))
	}
	// 容器变量：从内存读三槽
	if exp.Var != nil {
		src := stripOuterBrackets(GenVarAddr(a.ctx, exp.Var))
		code := utils.Format("mov " + regs[0] + ", " + ln + " [" + src + "]")
		code += utils.Format("mov " + regs[1] + ", " + ln + " [" + src + "+" + strconv.Itoa(ps) + "]")
		code += utils.Format("mov " + regs[2] + ", " + ln + " [" + src + "+" + strconv.Itoa(2*ps) + "]")
		return code
	}
	return ""
}

// pushContainer 容器（list/string）实参压 3 槽（cap/len/ptr，ptr 最后压落在低地址 [rbp+16] 槽）
func (a *SysV) pushContainer(exp *parser.Expression, desc string) string {
	ps := a.ctx.PointerSize
	ln := a.ctx.Arch.LengthName(ps)
	if exp == nil {
		return utils.Format("push 0") + utils.Format("push 0") + utils.Format("push 0; 空容器")
	}
	// 嵌套调用：先 call（返回值在本帧返回槽），从返回槽压三槽
	if exp.Call != nil {
		code := a.Call(exp.Call)
		code += utils.Format("push " + ln + " [rbp" + strconv.Itoa(a.ctx.RetSlot+2*ps) + "]")
		code += utils.Format("push " + ln + " [rbp" + strconv.Itoa(a.ctx.RetSlot+ps) + "]")
		code += utils.Format("push " + ln + " [rbp" + strconv.Itoa(a.ctx.RetSlot) + "]")
		return code
	}
	// 字符串常量
	if exp.IsConst() {
		label := "0"
		if exp.StringVal != "" {
			label = a.stringLabel(exp.StringVal)
		}
		slen := len(exp.StringVal)
		return utils.Format("push " + strconv.Itoa(slen)) +
			utils.Format("push " + strconv.Itoa(slen)) +
			utils.Format("push " + label)
	}
	// 容器变量：从内存压三槽
	if exp.Var != nil {
		src := stripOuterBrackets(GenVarAddr(a.ctx, exp.Var))
		code := utils.Format("push " + ln + " [" + src + "+" + strconv.Itoa(2*ps) + "]")
		code += utils.Format("push " + ln + " [" + src + "+" + strconv.Itoa(ps) + "]")
		code += utils.Format("push " + ln + " [" + src + "]")
		return code
	}
	return utils.Format("push 0") + utils.Format("push 0") + utils.Format("push 0; 空容器")
}

// Exp 编译表达式
func (a *SysV) Exp(exp *parser.Expression, result, desc string) string {
	return a.exp(exp, result, desc)
}

// expHasCall 递归判断表达式是否包含函数调用（含内建调用）
func expHasCall(e *parser.Expression) bool {
	if e == nil {
		return false
	}
	if e.Call != nil {
		return true
	}
	if expHasCall(e.Left) || expHasCall(e.Right) {
		return true
	}
	for _, idx := range e.Index {
		if expHasCall(idx) {
			return true
		}
	}
	return false
}

// sysvWidthName 返回寄存器指定宽度的名字（RDI→EDI/DIL/DI，R8→R8D/R8B/R8W）
func sysvWidthName(reg string, size int) string {
	isR8 := len(reg) == 2 && reg[0] == 'R' && reg[1] >= '8' && reg[1] <= '9'
	switch size {
	case 1:
		if isR8 {
			return reg + "B"
		}
		switch reg {
		case "RDI":
			return "DIL"
		case "RSI":
			return "SIL"
		case "RDX":
			return "DL"
		case "RCX":
			return "CL"
		}
	case 2:
		if isR8 {
			return reg + "W"
		}
		return reg[1:] + "I"
	case 4:
		if isR8 {
			return reg + "D"
		}
		return "E" + reg[1:]
	}
	return reg
}
