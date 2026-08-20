package x86

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"cuteify/utils"
	"strings"
	"strconv"
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

	// 最后压入 this 指针（如果有）：this 位于 [ebp+8]，参数从 [ebp+12] 起
	if call.ThisVar != nil {
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

	// 生成函数名
	name := formatFuncName(fn.Name.NASM(), len(fn.Args))
	isContainerRet := arch.FuncReturnsLarge(fn)
	if isContainerRet {
		code += utils.Format("lea EAX, [ebp" + strconv.Itoa(a.ctx.RetSlot) + "]; 大值返回槽地址")
		code += utils.Format("push EAX; 大值返回槽地址")
	}
	code += utils.Format("call " + name)

	// cdecl: 调用者清理参数栈
	argSize := callArgsSize(call)
	if argSize > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(argSize) + "; cdecl: 清理参数栈")
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
