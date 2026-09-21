package x86_64

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"cuteify/utils"
	"strconv"
)

// win64ArgRegs Microsoft x64 ABI 参数寄存器（第1-4个参数）
var win64ArgRegs = []string{"RCX", "RDX", "R8", "R9"}

// win64CalleeSaved Microsoft x64 ABI 的 callee-save 寄存器
var win64CalleeSaved = []string{"RDI", "RSI", "RBX", "R12", "R13", "R14", "R15"}

// Win64 实现 x86_64 Microsoft x64 ABI 调用约定。
type Win64 struct {
	ctx *context.Context
	*x86_64Ops
}

func NewWin64(ctx *context.Context) *Win64 {
	a := &Win64{
		ctx:       ctx,
		x86_64Ops: newOps(ctx, win64CalleeSaved),
	}
	regs := cloneRegs(Regs, win64CalleeSaved)
	ctx.Reg = regmgr.NewRegMgr(regs)
	ctx.PointerSize = 8
	ctx.Is64Bit = true
	ctx.StackAlignment = 16
	return a
}

// Info 返回调用约定的名称
func (a *Win64) Info() string { return "x86_64 Microsoft x64 ABI" }

// SetArgsOffset 将参数偏移从调用者帧位置刷新为 callee-local 位置
func (a *Win64) SetArgsOffset(fn *parser.FuncBlock) { setArgsOffset(fn) }

// Prologue 函数前序代码
func (a *Win64) Prologue(fn *parser.FuncBlock) (code string) {
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

	// Win64 调用者需要 32 字节 shadow space
	a.ctx.StackSize += 32

	// 编译期 16 字节对齐：call 压返回地址(-8) + push rbp(-8) + 7 callee-save(-56) = -72
	// RSP = RBP - 56 - StackSize，需 StackSize ≡ 8 (mod 16) 使 RSP ≡ 0 (mod 16)
	totalPushed := 8 + 8 + 8*len(csRegs) // return addr + rbp + 7 callee-saves = 72
	need := (16 - (totalPushed % 16)) % 16 // = 8
	if a.ctx.StackSize%16 != need {
		a.ctx.StackSize += (need - a.ctx.StackSize%16 + 16) % 16
	}

	if a.ctx.StackSize > 0 {
		code += utils.Format("sub rsp, " + strconv.Itoa(a.ctx.StackSize) + "; 分配局部变量空间(" + strconv.Itoa(a.ctx.StackSize) + "字节)")
	}

	// 将寄存器参数保存到栈上(Win64 ABI: RCX, RDX, R8, R9)
	argRegIdx := 0
	if fn.Class != nil {
		// 如果有this指针,第一个寄存器是this，保存到 [rbp+16]
		code += utils.Format("mov QWORD [rbp+16], " + win64ArgRegs[0] + "; this pointer")
		argRegIdx = 1
	}

	for i := 0; i < len(fn.Args); i++ {
		arg := fn.Args[i]
		if argRegIdx+i < len(win64ArgRegs) {
			regName := win64ArgRegs[argRegIdx+i]
			addr := "[rbp+" + strconv.Itoa(arg.Offset) + "]"
			code += utils.Format("mov QWORD " + addr + ", " + regName + "; 保存参数" + strconv.Itoa(i) + "到栈")
		}
	}

	return code
}

// Epilogue 函数后序代码(公共返回点)
func (a *Win64) Epilogue(fn *parser.FuncBlock) string {
	funcName := formatFuncName(fn)
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

// Call 函数调用（Win64：前4个参数用寄存器 RCX/RDX/R8/R9，其余压栈 + 32字节 shadow space）
func (a *Win64) Call(call *parser.CallBlock) (code string) {
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
		code += utils.Format("mov " + win64ArgRegs[0] + ", " + thisAddr + "; this pointer")
		argRegIdx = 1
	}

	// 统计需要压栈的参数个数
	stackArgs := 0
	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		if argRegIdx+i >= len(win64ArgRegs) {
			stackArgs++
		}
	}

	// 压栈参数（从右到左）
	for i := len(call.Args) - 1; i >= 0; i-- {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		regIdx := argRegIdx + i
		if regIdx >= len(win64ArgRegs) {
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
		if regIdx < len(win64ArgRegs) {
			code += a.Exp(arg.Value, win64ArgRegs[regIdx], "参数"+strconv.Itoa(i))
		}
	}

	// shadow space
	code += utils.Format("sub rsp, 32; shadow space")

	name := formatFuncName(fn)
	code += utils.Format("call " + name)

	// 清理 shadow space + 栈参数
	cleanupSize := 32 + stackArgs*8
	if cleanupSize > 0 {
		code += utils.Format("add rsp, " + strconv.Itoa(cleanupSize) + "; cleanup shadow space + stack args")
	}

	return code
}

// Return 函数返回
func (a *Win64) Return(ret *parser.ReturnBlock) (code string) {
	code = a.returnValue(ret)
	code += a.returnJump()
	return code
}

// Exp 编译表达式
func (a *Win64) Exp(exp *parser.Expression, result, desc string) string {
	return a.exp(exp, result, desc)
}
