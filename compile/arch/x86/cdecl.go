package x86

import (
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
		// 64 位形参但实参是 32 位值（字面量/表达式）：扩展为 8 字节，高 32 位补 0
		if is64Type(arg.Type) && (arg.Value == nil || !is64Type(arg.Value.Type)) {
			code += a.exp(arg.Value, "EAX", "参数"+strconv.Itoa(i))
			code += utils.Format("push 0\n") + utils.Format("push EAX; 参数"+strconv.Itoa(i)+" 扩展到64位\n")
		} else {
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
	code += utils.Format("call " + name)

	// cdecl: 调用者清理参数栈
	argSize := callArgsSize(call)
	if argSize > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(argSize) + "; cdecl: 清理参数栈")
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
