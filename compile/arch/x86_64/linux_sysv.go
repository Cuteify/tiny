package x86_64

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"cuteify/utils"
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

	if a.ctx.StackSize > 0 {
		code += utils.Format("sub rsp, " + strconv.Itoa(a.ctx.StackSize) + "; 分配局部变量空间(" + strconv.Itoa(a.ctx.StackSize) + "字节)")
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
		if argRegIdx+i < len(sysvArgRegs) {
			regName := sysvArgRegs[argRegIdx+i]
			addr := "[rbp+" + strconv.Itoa(arg.Offset) + "]"
			code += utils.Format("mov QWORD " + addr + ", " + regName + "; 保存参数" + strconv.Itoa(i) + "到栈")
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

	argRegIdx := 0

	// this 指针作为第一个寄存器参数
	if call.ThisVar != nil {
		thisAddr := GenVarAddr(a.ctx, call.ThisVar)
		code += utils.Format("mov " + sysvArgRegs[0] + ", " + thisAddr + "; this pointer")
		argRegIdx = 1
	}

	// 统计需要压栈的参数个数
	stackArgs := 0
	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		if argRegIdx+i >= len(sysvArgRegs) {
			stackArgs++
		}
	}

	// 栈参数对齐（rsp 16 字节对齐）
	if stackArgs > 0 {
		if stackArgs%2 != 0 {
			code += utils.Format("sub rsp, 8; align stack for stack args")
		}
	}

	// 压栈参数（从右到左）
	for i := len(call.Args) - 1; i >= 0; i-- {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		regIdx := argRegIdx + i
		if regIdx >= len(sysvArgRegs) {
			code += a.Exp(arg.Value, "push", "参数"+strconv.Itoa(i))
		}
	}

	// 寄存器参数
	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		regIdx := argRegIdx + i
		if regIdx < len(sysvArgRegs) {
			code += a.Exp(arg.Value, sysvArgRegs[regIdx], "参数"+strconv.Itoa(i))
		}
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

// Return 函数返回
func (a *SysV) Return(ret *parser.ReturnBlock) (code string) {
	code = a.returnValue(ret)
	code += a.returnJump()
	return code
}

// Exp 编译表达式
func (a *SysV) Exp(exp *parser.Expression, result, desc string) string {
	return a.exp(exp, result, desc)
}
