package x86_64

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"cuteify/utils"
	"strconv"
)

var win64ArgRegs = []string{"RCX", "RDX", "R8", "R9"}

var win64CalleeSaved = []string{"RDI", "RSI", "RBX", "R12", "R13", "R14", "R15"}

type Win64 struct {
	ctx *context.Context
}

func NewWin64(ctx *context.Context) *Win64 {
	a := &Win64{ctx: ctx}
	ctx.Reg = regmgr.NewRegMgr(Regs, a.GenVarAddr)
	ctx.PointerSize = 8
	ctx.Is64Bit = true
	ctx.StackAlignment = 16
	return a
}

func (a *Win64) Info() string { return "x86_64 Microsoft x64 ABI" }

func (a *Win64) Call(call *parser.CallBlock) string {
	if call == nil || call.Func == nil {
		return ""
	}

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
	var code string

	savedRegs := a.ctx.Reg.SaveAll(false)
	for _, regCode := range savedRegs {
		code += regCode
	}

	thisTakesArgSlot := call.ThisVar != nil

	stackArgSize := 0
	for i := len(call.Args) - 1; i >= 0; i-- {
		arg := call.Args[i]
		if arg == nil || arg.Value == nil {
			continue
		}

		argIdx := i
		if thisTakesArgSlot {
			argIdx++
		}
		if argIdx >= 4 {
			code += a.Exp(arg.Value, "push", "stack arg"+strconv.Itoa(i))
			stackArgSize += 8
		}
	}

	code += utils.Format("sub rsp, 32; shadow space")

	regArgCount := 0
	if call.ThisVar != nil {
		thisAddr := GenVarAddr(a.ctx, call.ThisVar)
		code += utils.Format("mov RCX, " + thisAddr + "; this pointer")
		regArgCount = 1
	}

	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil || arg.Value == nil {
			continue
		}

		if regArgCount < 4 {
			code += a.Exp(arg.Value, win64ArgRegs[regArgCount], "arg"+strconv.Itoa(i))
			regArgCount++
		}
	}

	name := fn.Name.String()
	if name != "main" {
		name = name + strconv.Itoa(len(fn.Args))
	}
	code += utils.Format("call " + name)

	cleanupSize := 32 + stackArgSize
	code += utils.Format("add rsp, " + strconv.Itoa(cleanupSize) + "; cleanup shadow space + stack args")

	return code
}

func (a *Win64) Return(ret *parser.ReturnBlock) string {
	var code string

	if ret != nil && len(ret.Value) != 0 {
		raxReg := &regmgr.Reg{Name: "RAX", RegIndex: 0}
		a.ctx.Reg.Force(raxReg, a.ctx.Now, ret.Value[0])

		if raxReg.StoreCode != "" {
			code += utils.Format(raxReg.StoreCode)
		}

		code += a.Exp(ret.Value[0], "RAX", "return value -> RAX")
		a.ctx.Reg.Free(ret.Value[0])
	}

	if a.ctx.StackSize > 0 {
		code += utils.Format("add rsp, " + strconv.Itoa(a.ctx.StackSize))
	}

	for i := len(win64CalleeSaved) - 1; i >= 0; i-- {
		code += utils.Format("pop " + win64CalleeSaved[i])
	}

	code += utils.Format("leave")
	code += utils.Format("ret\n")
	return code
}

func (a *Win64) Func(funcBlock *parser.FuncBlock) string {
	if funcBlock == nil {
		return ""
	}

	var code string

	argOffset := 16

	if funcBlock.Class != nil {
		for i := 0; i < len(funcBlock.Args); i++ {
			arg := funcBlock.Args[i]
			arg.Offset = argOffset
			argOffset += arg.Type.Size()
		}
	} else {
		for i := 0; i < len(funcBlock.Args); i++ {
			arg := funcBlock.Args[i]
			arg.Offset = argOffset
			argOffset += arg.Type.Size()
		}
	}

	code += utils.Format("push rbp")
	code += utils.Format("mov rbp, rsp")

	for _, regName := range win64CalleeSaved {
		code += utils.Format("push " + regName)
	}

	csCount := len(win64CalleeSaved)

	a.ctx.StackSize = arch.SetupVarOffsets(a.ctx.Now, a.ctx.StackAlignment, -8*csCount)

	a.ctx.StackSize += 32

	if a.ctx.StackSize%16 != 0 {
		a.ctx.StackSize = (a.ctx.StackSize + 15) & ^15
	}

	if a.ctx.StackSize > 0 {
		code += utils.Format("sub rsp, " + strconv.Itoa(a.ctx.StackSize))
	}

	return code
}

func (a *Win64) Exp(exp *parser.Expression, result, desc string) string {
	expc := ExpCom{ctx: a.ctx}
	return expc.CompileExpr(exp, result, desc)
}

func (a *Win64) For(forBlock *parser.ForBlock) string {
	if forBlock == nil {
		return ""
	}

	forBlock.Offset = a.ctx.IfCount
	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	forEndLabel := forLabel + "_end"

	var code string

	code += utils.Format("")
	code += utils.Format("")

	if forBlock.Init != nil {
		code += a.Exp(forBlock.Init, "", "for init")
	}

	code += utils.Format("")
	code += utils.Format("")

	code += utils.Format(forLabel + ": ; for loop start")

	if forBlock.Condition != nil && !forBlock.Condition.Bool {
		code += a.Exp(forBlock.Condition, forEndLabel, "for condition check")
	}

	code += utils.Format("")
	code += utils.Format("")

	return code
}

func (a *Win64) EndFor(forBlock *parser.ForBlock) string {
	var code string

	code += utils.Format("")
	code += utils.Format("")

	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	code += a.Exp(forBlock.Increment, "", "for increment")
	code += utils.Format("jmp " + forLabel + "; for loop")
	code += utils.Format(forLabel + "_end: ; for loop end")
	return code
}

func (a *Win64) Var(varBlock *parser.VarBlock) string {
	addr := GenVarAddr(a.ctx, varBlock)
	if varBlock.Value == nil {
		return ""
	}
	return a.ctx.Arch.Exp(varBlock.Value, addr, "set var "+varBlock.Name.String())
}

func (a *Win64) GenVarAddr(varBlock *parser.VarBlock) string {
	return GenVarAddr(a.ctx, varBlock)
}
