package x86

import (
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"cuteify/utils"
	"strconv"
)

// Stdcall 实现 x86 stdcall 调用约定（全部压栈，被调者清理）。
type Stdcall struct {
	ctx *context.Context
	*x86Ops
}

func NewStdcall(ctx *context.Context) *Stdcall {
	a := &Stdcall{
		ctx:    ctx,
		x86Ops: newOps(ctx),
	}
	ctx.Reg = regmgr.NewRegMgr(regs)
	return a
}

// Info 返回调用约定的名称
func (a *Stdcall) Info() string { return "x86 stdcall" }

// SetArgsOffset 将参数偏移从调用者帧位置刷新为 callee-local 位置
func (a *Stdcall) SetArgsOffset(fn *parser.FuncBlock) { setArgsOffset(fn) }

// Prologue 函数前序代码
func (a *Stdcall) Prologue(fn *parser.FuncBlock) string {
	return a.prologue(fn)
}

// Epilogue 函数后序代码(公共返回点，stdcall: ret N 被调者清理参数)
func (a *Stdcall) Epilogue(fn *parser.FuncBlock) string {
	return a.epilogue(fn, true)
}

// Call 函数调用（stdcall：被调者清理参数）
func (a *Stdcall) Call(call *parser.CallBlock) string {
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

	// 压入 this 指针（如果有）
	if call.ThisVar != nil {
		thisAddr := genVarAddr(a.ctx, call.ThisVar)
		code += utils.Format("push " + thisAddr + "; push this pointer")
	}

	// 压入参数（从右到左）
	for i := len(call.Args) - 1; i >= 0; i-- {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		code += a.Exp(arg.Value, "push", "参数"+strconv.Itoa(i))
	}

	// 生成函数名
	name := formatFuncName(fn)
	code += utils.Format("call " + name)

	// stdcall: 被调者清理参数栈，调用者无需 add esp
	return code
}

// Return 函数返回
func (a *Stdcall) Return(ret *parser.ReturnBlock) string {
	code := a.returnValue(ret)
	code += a.returnJump()
	return code
}

// Exp 编译表达式（64 位类型路由到 compile64Type）
func (a *Stdcall) Exp(exp *parser.Expression, result, desc string) string {
	if exp != nil && is64Type(exp.Type) {
		return compile64Type(a.ctx, exp, result, desc)
	}
	return a.exp(exp, result, desc)
}
