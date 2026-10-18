package x86_64

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"fmt"
	"os"
	"runtime/debug"
	"strconv"
	"strings"
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

// rbpOffset 返回 rbp 相对地址（正偏移用 +，负偏移用 -）
func rbpOffset(offset int) string {
	if offset >= 0 {
		return "[rbp+" + strconv.Itoa(offset) + "]"
	}
	return "[rbp-" + strconv.Itoa(-offset) + "]"
}

// SetArgsOffset 将参数偏移从调用者帧位置刷新为 callee-local 位置
func (a *SysV) SetArgsOffset(fn *parser.FuncBlock) { setArgsOffset(fn) }

// Prologue 函数前序代码
func (a *SysV) Prologue(fn *parser.FuncBlock) (code string) {
	if fn == nil {
		panic("内部错误")
	}

	// 设置参数偏移量（callee 局部变量区 rbp-48 起，如 C/Rust）
	setArgsOffset(fn)

	code += utils.Format("push rbp")
	code += utils.Format("mov rbp, rsp")

	// 固定保存所有 callee-save 寄存器（不依赖分配器记录，保证确定性和栈布局一致性）
	csRegs := a.CalleeSaveRegs()
	for _, regName := range csRegs {
		code += utils.Format("push " + regName + "; 保存" + regName)
	}

	// 计算参数保存所需空间，将其纳入局部变量区（参数在 callee-saved regs 之下）
	argSaveBytes := 0
	if fn.Class != nil {
		argSaveBytes += 8 // this 指针
	}
	for i := 0; i < len(fn.Args); i++ {
		argSaveBytes += fn.Args[i].Type.Size()
	}

	a.ctx.StackSize = arch.SetupVarOffsets(a.ctx.Now, a.ctx.StackAlignment, -8*len(csRegs)-argSaveBytes)

	// 预留大值返回槽：容器 24B + R10 保存 8B；结构体按槽数（Size/8）计算
	retBytes := 24
	if arch.FuncReturnsLarge(fn) {
		retBytes = arch.ArgSlots(fn.Return[0]) * 8
	}
	a.ctx.RetSlot = -(a.ctx.StackSize) - retBytes - 8
	a.ctx.StackSize += retBytes + 8

	// 编译期 16 字节对齐：call 压返回地址(-8) + push rbp(-8) + 5 callee-save(-40) = -56
	// RSP = RBP - 40 - StackSize，需 StackSize ≡ 8 (mod 16) 使 RSP ≡ 0 (mod 16)
	totalPushed := 8 + 8 + 8*len(csRegs)   // return addr + rbp + 5 callee-saves = 56
	need := (16 - (totalPushed % 16)) % 16 // = 8
	if a.ctx.StackSize%16 != need {
		a.ctx.StackSize += (need - a.ctx.StackSize%16 + 16) % 16
	}

	if a.ctx.StackSize > 0 {
		code += utils.Format("sub rsp, " + strconv.Itoa(a.ctx.StackSize) + "; 分配局部变量空间(" + strconv.Itoa(a.ctx.StackSize) + "字节, 含对齐)")
	}

	// 大值返回函数：保存调用者传入的返回槽地址（R10）
	if arch.FuncReturnsLarge(fn) {
		code += utils.Format("mov QWORD [rbp" + strconv.Itoa(a.ctx.RetSlot+retBytes) + "], R10; 保存返回槽地址")
	}

	// 将寄存器参数保存到栈上（SysV ABI: RDI, RSI, RDX, RCX, R8, R9）
	// 保存到 callee 自己的局部变量区（如 C/Rust），不写入调用者栈帧
	argRegIdx := 0
	stackArgBase := 16
	if fn.Class != nil {
		// this 指针保存到 [rbp-48]（callee 局部变量区顶部）
		code += utils.Format("mov QWORD " + rbpOffset(-48) + ", " + sysvArgRegs[0] + "; this pointer")
		argRegIdx = 1
		stackArgBase = 24
	}

	// 先搬移栈参数（SysV 第 7+ 个）：其原始位置在 [rbp+16]（含 this 时 [rbp+24]）起的
	// 调用者栈参数区，搬到 callee 局部变量区的编译器参数槽（arg.Offset）。
	{
		stackSlot := 0
		regIdx := argRegIdx
		for i := 0; i < len(fn.Args); i++ {
			arg := fn.Args[i]
			slots := arch.ArgSlots(arg.Type)
			if regIdx+slots-1 < len(sysvArgRegs) {
				regIdx += slots
				continue
			}
			for j := 0; j < slots; j++ {
				src := "[rbp+" + strconv.Itoa(stackArgBase+(stackSlot+j)*8) + "]"
				dst := rbpOffset(arg.Offset + j*8)
				code += utils.Format("mov RAX, " + src + "; 保存栈参数" + strconv.Itoa(i) + "槽" + strconv.Itoa(j) + "到栈")
				code += utils.Format("mov " + dst + ", RAX")
			}
			stackSlot += slots
			regIdx += slots
		}
	}

	for i := 0; i < len(fn.Args); i++ {
		arg := fn.Args[i]
		slots := arch.ArgSlots(arg.Type)
		if slots > 1 {
			// 容器（3 槽）/ 大结构体（多槽）参数占连续寄存器
			if argRegIdx+slots-1 < len(sysvArgRegs) {
				for j := 0; j < slots; j++ {
					regName := sysvArgRegs[argRegIdx+j]
					addr := rbpOffset(arg.Offset + j*8)
					code += utils.Format("mov QWORD " + addr + ", " + regName + "; 保存参数" + strconv.Itoa(i) + "槽" + strconv.Itoa(j) + "到栈")
				}
			}
			argRegIdx += slots
		} else {
			if argRegIdx < len(sysvArgRegs) {
				regName := sysvArgRegs[argRegIdx]
				addr := rbpOffset(arg.Offset)
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
	funcName := formatFuncName(fn)
	code := utils.Format("func_end_" + funcName + ":")

	// 清理局部变量 + 对齐 padding（StackSize 已含编译期对齐）
	if a.ctx.StackSize > 0 {
		code += utils.Format("add rsp, " + strconv.Itoa(a.ctx.StackSize) + "; 清理局部变量 + 对齐")
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

	// Interface dispatch: if receiver is an interface type, dispatch via vtable
	if call.ThisVar != nil && call.ThisVar.Type != nil {
		if ifaceType, ok := call.ThisVar.Type.(*typeSys.InterfaceType); ok {
			return a.interfaceDispatch(call, ifaceType)
		}
	}

normalCall:
	fn := call.Func

	// 大值返回函数：预留调用者返回槽地址（R10）
	isContainerRet := arch.FuncReturnsLarge(call.Func)

	// 判断是否为函数指针间接调用
	isIndirect := call.ThisVar != nil && call.ThisVar.Type != nil &&
		call.ThisVar.Type.Kind() == "func"

	// 统计需要压栈的参数个数（容器参数占 3 个寄存器/3 个栈槽）
	argRegIdx := 0

	// this 指针作为第一个寄存器参数（函数指针间接调用不压 this）
	if call.ThisVar != nil && !isIndirect {
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

	// 寄存器参数：预分配固定 buffer，每个参数求值后直接写入 buffer[i]。
	// buffer 在 RSP 下方，嵌套 call 的 buffer 也在 RSP 下方但各自平衡（sub/add 成对），
	// 所以主 buffer 的偏移不受嵌套 call 影响。
	// 装载到寄存器后释放 buffer。
	numRegArgs := 0
	cursor = argRegIdx
	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		slots := arch.ArgSlots(arg.Type)
		if cursor+slots <= len(sysvArgRegs) {
			numRegArgs += slots
		}
		cursor += slots
	}
	if numRegArgs > 0 {
		bufferBytes := numRegArgs * 8
		if bufferBytes%16 != 0 {
			bufferBytes += 8
		}
		code += utils.Format("sub rsp, " + strconv.Itoa(bufferBytes) + "; register args buffer")
		// 求值每个参数，直接写入 buffer 槽位
		cursor = argRegIdx
		bufIdx := 0
		ps := a.ctx.PointerSize
		ln := a.ctx.Arch.LengthName(ps)
		for i := 0; i < len(call.Args); i++ {
			arg := call.Args[i]
			if arg == nil {
				continue
			}
			slots := arch.ArgSlots(arg.Type)
			if cursor+slots <= len(sysvArgRegs) {
				bufOff := bufIdx * 8
				if arch.IsListLikeType(arg.Type) {
					// 容器直接写 buffer：ptr→[bufOff], len→[bufOff+8], cap→[bufOff+16]
					exp := arg.Value
					if exp == nil {
						code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(bufOff) + "], 0")
						code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(bufOff+8) + "], 0")
						code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(bufOff+16) + "], 0")
					} else if exp.Call != nil {
						// 嵌套调用：先 call（结果在 RetSlot），再从 RetSlot 写到 buffer
						code += a.Call(exp.Call)
						code += utils.Format("mov RAX, " + ln + " [rbp" + strconv.Itoa(a.ctx.RetSlot) + "]")
						code += utils.Format("mov " + ln + " [rsp+" + strconv.Itoa(bufOff) + "], RAX")
						code += utils.Format("mov RAX, " + ln + " [rbp" + strconv.Itoa(a.ctx.RetSlot+ps) + "]")
						code += utils.Format("mov " + ln + " [rsp+" + strconv.Itoa(bufOff+ps) + "], RAX")
						code += utils.Format("mov RAX, " + ln + " [rbp" + strconv.Itoa(a.ctx.RetSlot+2*ps) + "]")
						code += utils.Format("mov " + ln + " [rsp+" + strconv.Itoa(bufOff+2*ps) + "], RAX")
					} else if exp.IsConst() {
						label := "0"
						if exp.StringVal != "" {
							label = a.stringLabel(exp.StringVal)
						}
						slen := len(exp.StringVal)
						code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(bufOff) + "], " + label + "; ptr")
						code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(bufOff+8) + "], " + strconv.Itoa(slen) + "; len")
						code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(bufOff+16) + "], " + strconv.Itoa(slen) + "; cap")
					} else if exp.Var != nil {
						src := stripOuterBrackets(GenVarAddr(a.ctx, exp.Var))
						code += utils.Format("mov RAX, " + ln + " [" + src + "]")
						code += utils.Format("mov " + ln + " [rsp+" + strconv.Itoa(bufOff) + "], RAX")
						code += utils.Format("mov RAX, " + ln + " [" + src + "+" + strconv.Itoa(ps) + "]")
						code += utils.Format("mov " + ln + " [rsp+" + strconv.Itoa(bufOff+ps) + "], RAX")
						code += utils.Format("mov RAX, " + ln + " [" + src + "+" + strconv.Itoa(2*ps) + "]")
						code += utils.Format("mov " + ln + " [rsp+" + strconv.Itoa(bufOff+2*ps) + "], RAX")
					} else {
						code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(bufOff) + "], 0")
						code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(bufOff+8) + "], 0")
						code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(bufOff+16) + "], 0")
					}
					bufIdx += slots
				} else {
					// 标量直接写 buffer
					code += a.Exp(arg.Value, "QWORD [rsp+"+strconv.Itoa(bufOff)+"]", "参数"+strconv.Itoa(i))
					bufIdx += slots
				}
			}
			cursor += slots
		}
		// 从 buffer 装载到寄存器
		cursor = argRegIdx
		bufIdx = 0
		for i := 0; i < len(call.Args); i++ {
			arg := call.Args[i]
			if arg == nil {
				continue
			}
			slots := arch.ArgSlots(arg.Type)
			if cursor+slots <= len(sysvArgRegs) {
				for k := 0; k < slots; k++ {
					bufOff := (bufIdx + k) * 8
					code += utils.Format("mov " + sysvArgRegs[cursor+k] + ", QWORD [rsp+" + strconv.Itoa(bufOff) + "]; 装载参数" + strconv.Itoa(i))
				}
				bufIdx += slots
			}
			cursor += slots
		}
		code += utils.Format("add rsp, " + strconv.Itoa(bufferBytes) + "; 释放寄存器参数 buffer")
	}

	if isContainerRet {
		code += utils.Format("lea R10, [rbp" + strconv.Itoa(a.ctx.RetSlot) + "]; 大值返回槽地址")
	}

	// 变参打包：将变参参数打包为 []T 传递（在 call 之前生成）
	var variadicArrayBytes int
	if call.IsVariadic && len(call.VariadicArgs) > 0 {
		// 获取变参元素类型（call.VariadicType 是 []T，需要取 Elem()）
		elemType := call.VariadicType
		if lt, ok := elemType.(*typeSys.ListType); ok {
			elemType = lt.Elem()
		}
		elemSize := elemType.Size()
		if elemSize <= 0 {
			elemSize = 8
		}
		count := len(call.VariadicArgs)
		variadicArrayBytes = count * elemSize

		// 在栈上分配临时数组
		if variadicArrayBytes > 0 {
			code += utils.Format("sub rsp, " + strconv.Itoa(variadicArrayBytes) + "; variadic array space")
		}

		// 将每个变参参数存入数组
		for i, varg := range call.VariadicArgs {
			offset := i * elemSize
			expCode := a.Exp(varg.Value, "RAX", "variadic "+strconv.Itoa(i))
			var storeCode string
			if elemSize == 8 {
				storeCode = utils.Format("mov QWORD [rsp+" + strconv.Itoa(offset) + "], RAX; variadic " + strconv.Itoa(i))
			} else if elemSize == 4 {
				storeCode = utils.Format("mov DWORD [rsp+" + strconv.Itoa(offset) + "], EAX; variadic " + strconv.Itoa(i))
			}
			code += expCode
			code += storeCode
		}

		// 将 slice {ptr, len, cap} 放入下一个可用的寄存器或栈
		// SysV ABI: RDI RSI RDX RCX R8 R9
		// variadic slice 占 3 个 slots (ptr=8, len=8, cap=8)
		sliceRegs := []string{"RDI", "RSI", "RDX", "RCX", "R8", "R9"}
		usedRegs := 0
		for i := 0; i < len(call.Args) && i < len(sliceRegs); i++ {
			usedRegs++
		}
		if usedRegs+3 <= len(sliceRegs) {
			code += utils.Format("lea " + sliceRegs[usedRegs] + ", [rsp]; variadic ptr")
			code += utils.Format("mov " + sliceRegs[usedRegs+1] + ", " + strconv.Itoa(count) + "; variadic len")
			code += utils.Format("mov " + sliceRegs[usedRegs+2] + ", " + strconv.Itoa(count) + "; variadic cap")
		} else {
			code += utils.Format("push " + strconv.Itoa(count) + "; variadic cap")
			code += utils.Format("push " + strconv.Itoa(count) + "; variadic len")
			code += utils.Format("push rsp; variadic ptr")
			stackArgs += 3
		}
	}

	if isIndirect {
		thisAddr := GenVarAddr(a.ctx, call.ThisVar)
		code += utils.Format("mov rax, QWORD " + thisAddr + "; 加载函数指针")
		code += utils.Format("call rax; 间接调用")
	} else {
		name := formatFuncName(fn)
		if name == "" {
			// DEBUG: trace empty function name
			fmt.Fprintf(os.Stderr, "[DEBUG-CALL] empty func name! fn=%p fn.Name=%v fn.Name.NASM()=%q fn.MangledOverride=%q fn.Args=%d\n",
				fn, fn.Name, fn.Name.NASM(), fn.MangledOverride, len(fn.Args))
			fmt.Fprintf(os.Stderr, "[DEBUG-CALL] stack:\n%s\n", string(debug.Stack()))
		}
		code += utils.Format("call " + name)
	}

	// 清理栈参数
	if stackArgs > 0 {
		totalStackArgs := stackArgs * 8
		if stackArgs%2 != 0 {
			totalStackArgs += 8
		}
		code += utils.Format("add rsp, " + strconv.Itoa(totalStackArgs) + "; clean stack args")
	}

	// 清理变参数组
	if variadicArrayBytes > 0 {
		code += utils.Format("add rsp, " + strconv.Itoa(variadicArrayBytes) + "; clean variadic array")
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

// interfaceDispatch generates indirect call via vtable for interface method dispatch.
// Layout: interface var = {vtable_ptr, data_ptr} at [rbp+offset].
// Vtable layout: [type_info | method_0 | method_1 | ...].
func (a *SysV) interfaceDispatch(call *parser.CallBlock, ifaceType *typeSys.InterfaceType) string {
	ps := a.ctx.PointerSize
	dq := "QWORD"
	if ps == 4 {
		dq = "DWORD"
	}

	// Get interface variable address
	thisAddr := GenVarAddr(a.ctx, call.ThisVar)
	thisBase := stripOuterBrackets(thisAddr)

	// Method name from call
	methodName := call.Name.Last()

	// Find method index in interface
	methodIdx := -1
	for i, m := range ifaceType.InterfaceMethods {
		if m.Name == methodName {
			methodIdx = i
			break
		}
	}
	if methodIdx < 0 {
		return "; interface dispatch: unknown method " + methodName + "\n"
	}

	// Vtable method offset: ps (type_info) + methodIdx * ps
	vtableMethodOff := ps + methodIdx*ps

	var code string

	// 1. Load vtable_ptr from interface variable (first slot)
	vtableReg := "R11"
	code += utils.Format("mov " + vtableReg + ", " + dq + " [" + thisBase + "]; vtable_ptr")

	// 2. Load data_ptr from interface variable (second slot) - this is the this pointer
	thisReg := "RDI" // first argument in SysV
	code += utils.Format("mov " + thisReg + ", " + dq + " [" + thisBase + "+" + strconv.Itoa(ps) + "]; data_ptr (this)")

	// 3. Set R10 (return slot) for methods returning large values (string/list)
	if methodIdx >= 0 && methodIdx < len(ifaceType.InterfaceMethods) {
		mret := ifaceType.InterfaceMethods[methodIdx].Returns
		if len(mret) > 0 && mret[0] != nil && arch.IsListLikeType(mret[0]) {
			code += utils.Format("lea R10, [rbp" + strconv.Itoa(a.ctx.RetSlot) + "]; 大值返回槽地址 (interface)")
		} else if len(mret) > 0 && mret[0] != nil && mret[0].Size() > ps && !(mret[0].Size() == 8 && (mret[0].Type() == "i64" || mret[0].Type() == "u64" || mret[0].Type() == "f64")) {
			code += utils.Format("lea R10, [rbp" + strconv.Itoa(a.ctx.RetSlot) + "]; 大值返回槽地址 (interface)")
		}
	}

	// 4. Load function pointer from vtable and call indirectly
	code += utils.Format("call " + dq + " [" + vtableReg + "+" + strconv.Itoa(vtableMethodOff) + "]; interface dispatch: " + methodName)

	code += utils.Format("; interface dispatch: " + methodName + "\n")
	return code
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
		return utils.Format("mov "+regs[0]+", "+label) +
			utils.Format("mov "+regs[1]+", "+strconv.Itoa(slen)) +
			utils.Format("mov "+regs[2]+", "+strconv.Itoa(slen))
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
		return utils.Format("push "+strconv.Itoa(slen)) +
			utils.Format("push "+strconv.Itoa(slen)) +
			utils.Format("push "+label)
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
