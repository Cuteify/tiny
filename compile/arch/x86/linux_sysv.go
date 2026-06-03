package x86

import (
	"cuteify/compile/arch"
	"cuteify/compile/arch/x86_64"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"cuteify/utils"
	"strconv"
)

var sysvArgRegs = []string{"RDI", "RSI", "RDX", "RCX", "R8", "R9"}

type SysV struct {
	ctx *context.Context
}

func NewSysV(ctx *context.Context) *SysV {
	a := &SysV{ctx: ctx}
	ctx.Reg = regmgr.NewRegMgr(Regs64, a.GenVarAddr)
	ctx.PointerSize = 8
	ctx.Is64Bit = true
	ctx.StackAlignment = 16
	return a
}

func (a *SysV) Info() string { return "x86_64 System V AMD64 ABI" }

func (a *SysV) Call(call *parser.CallBlock) (code string) {
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
		addr := x86_64.GenListFieldAddr(a.ctx, call.ThisVar, fieldOffset)
		code += utils.Format("mov rax, QWORD " + addr + "; " + methodName + "()")
		return
	}

normalCall:
	fn := call.Func

	savedRegs := a.ctx.Reg.SaveAll(false)
	for _, regCode := range savedRegs {
		code += regCode
	}

	argRegIdx := 0

	if call.ThisVar != nil {
		thisAddr := x86_64.GenVarAddr(a.ctx, call.ThisVar)
		code += utils.Format("mov " + sysvArgRegs[0] + ", " + thisAddr + "; this pointer")
		argRegIdx = 1
	}

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

	if stackArgs > 0 {
		if stackArgs%2 != 0 {
			code += utils.Format("sub rsp, 8; align stack for stack args")
		}
	}

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

	name := fn.Name.String()
	if name != "main" {
		name = name + strconv.Itoa(len(fn.Args))
	}
	code += utils.Format("call " + name)

	if stackArgs > 0 {
		totalStackArgs := stackArgs * 8
		if stackArgs%2 != 0 {
			totalStackArgs += 8
		}
		code += utils.Format("add rsp, " + strconv.Itoa(totalStackArgs) + "; clean stack args")
	}

	return code
}

func (a *SysV) Return(ret *parser.ReturnBlock) (code string) {
	if ret != nil && len(ret.Value) != 0 {
		raxReg := &regmgr.Reg{Name: "RAX", RegIndex: 0}
		a.ctx.Reg.Force(raxReg, a.ctx.Now, ret.Value[0])

		if raxReg.StoreCode != "" {
			code += utils.Format(raxReg.StoreCode)
		}

		code += a.Exp(ret.Value[0], "RAX", "return值存入RAX")
		a.ctx.Reg.Free(ret.Value[0])
	}

	if a.ctx.StackSize > 0 {
		code += utils.Format("add rsp, " + strconv.Itoa(a.ctx.StackSize))
	}

	for i := len(Regs64) - 1; i >= 0; i-- {
		r := Regs64[i]
		if r.CalleeSave {
			code += utils.Format("pop " + r.Name)
		}
	}

	code += utils.Format("leave")
	code += utils.Format("ret\n")
	return code
}

func (a *SysV) Func(funcBlock *parser.FuncBlock) (code string) {
	if funcBlock == nil {
		return ""
	}

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

	csCount := 0
	for i := 0; i < len(Regs64); i++ {
		r := Regs64[i]
		if r.CalleeSave {
			code += utils.Format("push " + r.Name)
			csCount++
		}
	}

	a.ctx.StackSize = arch.SetupVarOffsets(a.ctx.Now, a.ctx.StackAlignment, -8*csCount)

	if a.ctx.StackSize > 0 {
		code += utils.Format("sub rsp, " + strconv.Itoa(a.ctx.StackSize))
	}

	return code
}

func (a *SysV) Exp(exp *parser.Expression, result, desc string) (code string) {
	expc := x86_64.NewExpCom(a.ctx)
	return expc.CompileExpr(exp, result, desc)
}

func (a *SysV) For(forBlock *parser.ForBlock) (code string) {
	if forBlock == nil {
		return ""
	}

	forBlock.Offset = a.ctx.IfCount
	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	forEndLabel := forLabel + "_end"

	code += utils.Format("")
	code += utils.Format("")

	if forBlock.Init != nil {
		code += a.Exp(forBlock.Init, "", "初始化for循环")
	}

	code += utils.Format("")
	code += utils.Format("")

	code += utils.Format(forLabel + ": ; for循环开始")

	if forBlock.Condition != nil && !forBlock.Condition.Bool {
		code += a.Exp(forBlock.Condition, forEndLabel, "for循环条件检查")
	}

	code += utils.Format("")
	code += utils.Format("")

	return code
}

func (a *SysV) EndFor(forBlock *parser.ForBlock) (code string) {
	code += utils.Format("")
	code += utils.Format("")

	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	code += a.Exp(forBlock.Increment, "", "for循环增量")
	code += utils.Format("jmp " + forLabel + "; for循环")
	code += utils.Format(forLabel + "_end: ; for循环结束")
	return
}

func (a *SysV) Var(varBlock *parser.VarBlock) (code string) {
	addr := x86_64.GenVarAddr(a.ctx, varBlock)
	if varBlock.Value == nil {
		return
	}
	code += a.ctx.Arch.Exp(varBlock.Value, addr, "设置变量"+varBlock.Name.String())
	return
}

func (a *SysV) GenVarAddr(varBlock *parser.VarBlock) (addr string) {
	return x86_64.GenVarAddr(a.ctx, varBlock)
}
