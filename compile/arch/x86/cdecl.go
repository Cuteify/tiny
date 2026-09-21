package x86

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

// Cdecl 实现 x86 cdecl 调用约定（全部压栈，调用者清理）。
type Cdecl struct {
	ctx *context.Context
	*x86Ops
}

func NewCdecl(ctx *context.Context) *Cdecl {
	a := &Cdecl{
		ctx:    ctx,
		x86Ops: newOps(ctx),
	}
	ctx.Reg = regmgr.NewRegMgr(regs)
	return a
}

// Info 返回调用约定的名称
func (a *Cdecl) Info() string { return "x86 cdecl" }

// SetArgsOffset 将参数偏移从调用者帧位置刷新为 callee-local 位置
func (a *Cdecl) SetArgsOffset(fn *parser.FuncBlock) { setArgsOffset(fn) }

// Prologue 函数前序代码
func (a *Cdecl) Prologue(fn *parser.FuncBlock) string {
	return a.prologue(fn)
}

// Epilogue 函数后序代码(公共返回点)
func (a *Cdecl) Epilogue(fn *parser.FuncBlock) string {
	return a.epilogue(fn, false)
}

// Call 函数调用（cdecl：调用者清理参数）
func (a *Cdecl) Call(call *parser.CallBlock) string {
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
			fieldOffset = 4
		case "cap":
			fieldOffset = 8
		case "ptr":
			fieldOffset = 0
		default:
			goto normalCall
		}
		addr := listFieldAddr(a.ctx, call.ThisVar, fieldOffset)
		return utils.Format("mov eax, dword " + addr + "; " + methodName + "()")
	}

	// Interface dispatch: if receiver is an interface type, dispatch via vtable
	if call.ThisVar != nil && call.ThisVar.Type != nil {
		if ifaceType, ok := call.ThisVar.Type.(*typeSys.InterfaceType); ok {
			return a.interfaceDispatch(call, ifaceType)
		}
	}

normalCall:
	fn := call.Func
	code := ""

	// 压入参数（从右到左，cdecl 约定）
	for i := len(call.Args) - 1; i >= 0; i-- {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		// string 形参：槽 12 字节（ptr+len+cap），实参三槽真实值
		if arg.Type != nil && arg.Type.Type() == "string" && arg.Value != nil {
			// 嵌套调用：先 call（返回值在本帧返回槽），再从返回槽压三槽
			if arg.Value.Call != nil {
				code += a.Call(arg.Value.Call)
				code += utils.Format("push dword [ebp" + strconv.Itoa(a.ctx.RetSlot+8) + "]; 参数" + strconv.Itoa(i) + " cap槽\n")
				code += utils.Format("push dword [ebp" + strconv.Itoa(a.ctx.RetSlot+4) + "]; 参数" + strconv.Itoa(i) + " len槽\n")
				code += utils.Format("push dword [ebp" + strconv.Itoa(a.ctx.RetSlot) + "]; 参数" + strconv.Itoa(i) + " ptr槽\n")
				continue
			}
			// 字符串常量：cap=len=slen，ptr=label
			if arg.Value.IsConst() {
				slen := len(arg.Value.StringVal)
				code += utils.Format("push " + strconv.Itoa(slen) + "; 参数" + strconv.Itoa(i) + " cap槽\n")
				code += utils.Format("push " + strconv.Itoa(slen) + "; 参数" + strconv.Itoa(i) + " len槽\n")
				code += a.exp(arg.Value, "EAX", "参数"+strconv.Itoa(i))
				code += utils.Format("push EAX; 参数" + strconv.Itoa(i) + " ptr槽\n")
				continue
			}
			// 容器变量：从内存读三槽（ptr+len+cap 各 4 字节）
			if arg.Value.Var != nil {
				src := genVarAddr(a.ctx, arg.Value.Var)
				base := strings.TrimSuffix(src, "]")
				code += utils.Format("push dword " + base + "+8]; 参数" + strconv.Itoa(i) + " cap槽\n")
				code += utils.Format("push dword " + base + "+4]; 参数" + strconv.Itoa(i) + " len槽\n")
				code += utils.Format("push dword " + src + "; 参数" + strconv.Itoa(i) + " ptr槽\n")
				continue
			}
		}
		// 8 字节形参（i64/u64/f64）但实参不是真 64 位数值：
		// 扩展为 8 字节压栈，高 32 位补 0（字面量/表达式只产生 32 位值）
		needExtend := arg.Type.Size() == 8 && !arch.IsListLikeType(arg.Type) &&
			arg.Type.Kind() != "struct" && (arg.Value == nil || !is64Type(arg.Value.Type))
		// 4 字节形参但实参是 64 位数值：窄化为低 32 位压栈（数值隐式转换语义，
		// 否则按实参宽度压 8 字节会错位后续参数槽）
		needNarrow := arg.Type.Size() == 4 && arg.Value != nil && !arch.IsListLikeType(arg.Type) &&
			arg.Type.Kind() != "struct" && is64Type(arg.Value.Type)
		switch {
		case needNarrow:
			code += a.exp(arg.Value, "EAX", "参数"+strconv.Itoa(i))
			code += utils.Format("push EAX; 参数"+strconv.Itoa(i)+" 窄化为32位\n")
		case needExtend:
			code += a.exp(arg.Value, "EAX", "参数"+strconv.Itoa(i))
			code += utils.Format("push 0\n") + utils.Format("push EAX; 参数"+strconv.Itoa(i)+" 扩展到64位\n")
		default:
			code += a.Exp(arg.Value, "push", "参数"+strconv.Itoa(i))
		}
	}

	// 变参打包：将变参参数打包为 []T 传递
	var variadicArrayBytes int
	if call.IsVariadic && len(call.VariadicArgs) > 0 {
		// 获取变参元素类型（call.VariadicType 是 []T，需要取 Elem()）
		elemType := call.VariadicType
		if lt, ok := elemType.(*typeSys.ListType); ok {
			elemType = lt.Elem()
		}
		elemSize := elemType.Size()
		if elemSize <= 0 {
			elemSize = 4
		}
		count := len(call.VariadicArgs)
		variadicArrayBytes = count * elemSize

		// 在栈上分配临时数组
		if variadicArrayBytes > 0 {
			code += utils.Format("sub esp, " + strconv.Itoa(variadicArrayBytes) + "; 变参数组空间")
		}

		// 将每个变参参数存入数组（从低地址到高地址）
		for i, varg := range call.VariadicArgs {
			offset := i * elemSize
			expCode := a.Exp(varg.Value, "EAX", "变参"+strconv.Itoa(i))
			storeCode := utils.Format("mov dword [esp+" + strconv.Itoa(offset) + "], EAX; 变参" + strconv.Itoa(i))
			code += expCode
			code += storeCode
		}

		// 压入 slice {ptr, len, cap}
		// ptr 指向临时数组（在 2 次 push 下方：cap + len = 8 bytes）
		ptrOffset := 8 // 2 pushes * 4 bytes = 8
		code += utils.Format("push " + strconv.Itoa(count) + "; 变参 cap")
		code += utils.Format("push " + strconv.Itoa(count) + "; 变参 len")
		code += utils.Format("lea eax, [esp+" + strconv.Itoa(ptrOffset) + "]; 变参 ptr → 数组起始地址")
		code += utils.Format("push eax; 变参 ptr")
	}

	// 生成函数名
	isIndirect := call.ThisVar != nil && call.ThisVar.Type != nil &&
		call.ThisVar.Type.Kind() == "func"

	// 最后压入 this 指针（如果有）：this 位于 [ebp+8]，参数从 [ebp+12] 起
	// 函数指针间接调用不压 this 指针
	if call.ThisVar != nil && !isIndirect {
		thisAddr := genVarAddr(a.ctx, call.ThisVar)
		if call.ThisVar.Type != nil && !call.ThisVar.Type.IsPointer() {
			// 值语义：压结构体地址（lea 取地址）
			addrOnly := thisAddr[strings.Index(thisAddr, "["):]
			code += utils.Format("lea eax, " + addrOnly + "; this pointer")
			code += utils.Format("push eax; push this pointer")
		} else {
			code += utils.Format("push " + thisAddr + "; push this pointer")
		}
	}
	var name string
	if !isIndirect {
		name = formatFuncName(fn)
	}
	isContainerRet := arch.FuncReturnsLarge(fn)
	if isContainerRet {
		code += utils.Format("lea EAX, [ebp" + strconv.Itoa(a.ctx.RetSlot) + "]; 大值返回槽地址")
		code += utils.Format("push EAX; 大值返回槽地址")
	}
	if isIndirect {
		// 间接调用：从变量加载函数指针到 EAX，然后 call eax
		addr := genVarAddr(a.ctx, call.ThisVar)
		code += utils.Format("mov eax, dword " + addr + "; 加载函数指针")
		code += utils.Format("call eax; 间接调用")
	} else {
		code += utils.Format("call " + name)
	}

	// cdecl: 调用者清理参数栈
	argSize := callArgsSize(call)
	if argSize > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(argSize) + "; cdecl: 清理参数栈")
	}
	// 清理变参临时数组
	if variadicArrayBytes > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(variadicArrayBytes) + "; 清理变参数组")
	}
	if isContainerRet {
		code += utils.Format("add esp, 4; 清理返回槽地址")
	}

	return code
}

// Return 函数返回
func (a *Cdecl) Return(ret *parser.ReturnBlock) string {
	code := a.returnValue(ret)
	code += a.returnJump()
	return code
}

// Exp 编译表达式（64 位类型路由到 compile64Type）
func (a *Cdecl) Exp(exp *parser.Expression, result, desc string) string {
	if exp != nil && is64Type(exp.Type) {
		return compile64Type(a.ctx, exp, result, desc)
	}
	return a.exp(exp, result, desc)
}

// interfaceDispatch generates indirect call via vtable for interface method dispatch on x86.
func (a *Cdecl) interfaceDispatch(call *parser.CallBlock, ifaceType *typeSys.InterfaceType) string {
	ps := a.ctx.PointerSize // 4 for x86

	// Get interface variable address - strip size prefix for raw memory access
	thisAddr := genVarAddr(a.ctx, call.ThisVar)
	// Strip size prefix (e.g. "DWORD[ebp-28]" → "[ebp-28]")
	rawAddr := thisAddr
	if idx := strings.Index(rawAddr, "["); idx >= 0 {
		rawAddr = rawAddr[idx:]
	}
	thisBase := rawAddr

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
	code += utils.Format("mov esi, dword " + thisBase + "; vtable_ptr")

	// 2. Load data_ptr from interface variable (second slot) - this is the this pointer
	code += utils.Format("mov edi, dword " + thisBase[:len(thisBase)-1] + "+" + strconv.Itoa(ps) + "]; data_ptr (this)")

	// 3. Set return slot (push) for methods returning large values (string/list)
	if methodIdx >= 0 && methodIdx < len(ifaceType.InterfaceMethods) {
		mret := ifaceType.InterfaceMethods[methodIdx].Returns
		if len(mret) > 0 && mret[0] != nil && arch.IsListLikeType(mret[0]) {
			code += utils.Format("lea eax, [ebp" + strconv.Itoa(a.ctx.RetSlot) + "]; 大值返回槽地址 (interface)")
			code += utils.Format("push eax; 大值返回槽地址")
		} else if len(mret) > 0 && mret[0] != nil && mret[0].Size() > ps && !(mret[0].Size() == 8 && (mret[0].Type() == "i64" || mret[0].Type() == "u64" || mret[0].Type() == "f64")) {
			code += utils.Format("lea eax, [ebp" + strconv.Itoa(a.ctx.RetSlot) + "]; 大值返回槽地址 (interface)")
			code += utils.Format("push eax; 大值返回槽地址")
		}
	}

	// 4. Push data_ptr (this) as first argument
	code += utils.Format("push edi; data_ptr (this)")

	// 5. Push additional arguments (from call.Args)
	for i := len(call.Args) - 1; i >= 0; i-- {
		arg := call.Args[i]
		if arg == nil || arg.Value == nil {
			continue
		}
		code += a.Exp(arg.Value, "push", "参数"+strconv.Itoa(i))
	}

	// 6. Load function pointer from vtable and call indirectly
	// x86: can't call [esi+offset] directly, need to load into register
	code += utils.Format("call dword [esi+" + strconv.Itoa(vtableMethodOff) + "]; interface dispatch: " + methodName)

	// 7. Clean up stack: this (4 bytes) + args
	cleanBytes := ps // this pointer
	for _, arg := range call.Args {
		if arg != nil && arg.Type != nil {
			cleanBytes += arch.ArgSlots(arg.Type) * ps
		}
	}
	// Check if return slot was pushed
	if methodIdx >= 0 && methodIdx < len(ifaceType.InterfaceMethods) {
		mret := ifaceType.InterfaceMethods[methodIdx].Returns
		if len(mret) > 0 && mret[0] != nil && (arch.IsListLikeType(mret[0]) || (mret[0].Size() > ps && !(mret[0].Size() == 8 && (mret[0].Type() == "i64" || mret[0].Type() == "u64" || mret[0].Type() == "f64")))) {
			cleanBytes += ps // return slot
		}
	}
	if cleanBytes > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(cleanBytes) + "; 清理接口分派参数")
	}

	code += utils.Format("; interface dispatch: " + methodName + "\n")
	return code
}

// stripOuterBrackets 去掉外层方括号
func stripOuterBrackets(addr string) string {
	if len(addr) >= 2 && strings.HasPrefix(addr, "[") && strings.HasSuffix(addr, "]") {
		return addr[1 : len(addr)-1]
	}
	return addr
}
