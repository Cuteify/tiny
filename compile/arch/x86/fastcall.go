package x86

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"cuteify/utils"
	"strconv"
)

type Fastcall struct {
	ctx *context.Context
}

func NewFastcall(ctx *context.Context) *Fastcall {
	a := &Fastcall{
		ctx: ctx,
	}
	ctx.Reg = regmgr.NewRegMgr(regs, a.GenVarAddr)
	return a
}

func (a *Fastcall) Info() string { return "x86 fastcall" }

func (a *Fastcall) Call(call *parser.CallBlock) (code string) {
	if call == nil || call.Func == nil {
		return ""
	}

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
		code += utils.Format("mov eax, dword " + addr + "; " + methodName + "()")
		return
	}

normalCall:
	fn := call.Func

	savedRegs := a.ctx.Reg.SaveAll(false)
	for _, regCode := range savedRegs {
		code += regCode
	}

	pushed := 0

	if call.ThisVar != nil {
		thisAddr := genVarAddr(a.ctx, call.ThisVar)
		code += utils.Format("push " + thisAddr + "; push this pointer")
		pushed += 4
	}

	isRegArg := make([]bool, len(call.Args))
	for i := 0; i < len(call.Args) && i < 2; i++ {
		arg := call.Args[i]
		if arg != nil && arg.Type != nil && arg.Type.Size() == 4 {
			isRegArg[i] = true
		}
	}

	for i := len(call.Args) - 1; i >= 0; i-- {
		if isRegArg[i] {
			continue
		}
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		code += a.Exp(arg.Value, "push", "参数"+strconv.Itoa(i))
		if arg.Type != nil {
			pushed += arg.Type.Size()
		} else {
			pushed += 4
		}
	}

	for i := 0; i < len(call.Args) && i < 2; i++ {
		if !isRegArg[i] {
			continue
		}
		arg := call.Args[i]
		var regName string
		if i == 0 {
			regName = "ECX"
		} else {
			regName = "EDX"
		}
		code += a.Exp(arg.Value, regName, "参数寄存器"+strconv.Itoa(i))
	}

	name := fn.Name.String()
	if name != "main" {
		name = name + strconv.Itoa(len(fn.Args))
	}
	code += utils.Format("call " + name)

	if pushed > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(pushed) + "; 清理压栈参数(fastcall)")
	}

	return code
}

func (a *Fastcall) Return(ret *parser.ReturnBlock) (code string) {
	if ret != nil && len(ret.Value) != 0 {
		if is64Type(ret.Value[0].Type) {
			code += a.Exp(ret.Value[0], "EDX:EAX", "return值存入EDX:EAX")
			a.ctx.Reg.Free(ret.Value[0])
		} else {
			eaxReg := &regmgr.Reg{Name: "EAX", RegIndex: 0}
			a.ctx.Reg.Force(eaxReg, a.ctx.Now, ret.Value[0])

			if eaxReg.StoreCode != "" {
				code += utils.Format(eaxReg.StoreCode)
			}

			code += a.Exp(ret.Value[0], "EAX", "return值存入EAX")
			a.ctx.Reg.Free(ret.Value[0])
		}
	}

	code += utils.Format("; ---- 退出函数 ----")

	if a.ctx.StackSize > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(a.ctx.StackSize) + "; 清理局部变量栈空间(" + strconv.Itoa(a.ctx.StackSize) + "字节)")
	}

	for i := len(regs) - 1; i >= 0; i-- {
		r := regs[i]
		if r.CalleeSave {
			code += utils.Format("pop " + r.Name + "; 恢复" + r.Name)
		}
	}

	code += utils.Format("leave")
	code += utils.Format("ret\n")
	return code
}

func (a *Fastcall) Func(funcBlock *parser.FuncBlock) (code string) {
	if funcBlock == nil {
		return ""
	}

	argOffset := 8
	if funcBlock.Class != nil {
		argOffset += 4
	}

	for i := 0; i < len(funcBlock.Args); i++ {
		arg := funcBlock.Args[i]
		arg.Offset = argOffset
		argOffset += arg.Type.Size()
	}

	name := funcBlock.Name.String()
	if name != "main" {
		name = name + strconv.Itoa(len(funcBlock.Args))
	}
	code += utils.Format("; ==============================")
	code += utils.Format("; Function:" + name)
	code += utils.Format(name + ":")
	code += utils.Format("push ebp; 保存调用者的栈帧基址")
	code += utils.Format("mov ebp, esp; 设置当前栈帧基址")

	csCount := 0
	for i := 0; i < len(regs); i++ {
		r := regs[i]
		if r.CalleeSave {
			code += utils.Format("push " + r.Name + "; 保存" + r.Name)
			csCount++
		}
	}

	a.ctx.StackSize = arch.SetupVarOffsets(a.ctx.Now, a.ctx.StackAlignment, -4*csCount)

	if a.ctx.StackSize > 0 {
		code += utils.Format("sub esp, " + strconv.Itoa(a.ctx.StackSize) + "; 分配栈空间(" + strconv.Itoa(a.ctx.StackSize) + "字节)")
	}

	code += utils.Format("; ---- 函数开始 ----")
	return code
}

func (a *Fastcall) Exp(exp *parser.Expression, result, desc string) (code string) {
	expc := expCom{ctx: a.ctx}
	return expc.CompileExpr(exp, result, desc)
}

func (a *Fastcall) For(forBlock *parser.ForBlock) (code string) {
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

func (a *Fastcall) EndFor(forBlock *parser.ForBlock) (code string) {
	code += utils.Format("")
	code += utils.Format("")

	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	code += a.Exp(forBlock.Increment, "", "for循环增量")
	code += utils.Format("jmp " + forLabel + "; for循环")
	code += utils.Format(forLabel + "_end: ; for循环结束")
	return code
}

func (a *Fastcall) Var(varBlock *parser.VarBlock) (code string) {
	if varBlock.Value == nil {
		return ""
	}
	if is64Type(varBlock.Type) {
		loAddr := genLoAddr(a.ctx, varBlock)
		hiAddr := genHiAddr(a.ctx, varBlock)
		code += a.Exp(varBlock.Value, loAddr, "设置变量"+varBlock.Name.String())
		if !isRegName(loAddr) {
			code += utils.Format("mov dword " + hiAddr + ", edx; 设置变量high")
		}
		return
	}
	addr := genVarAddr(a.ctx, varBlock)
	return a.ctx.Arch.Exp(varBlock.Value, addr, "设置变量"+varBlock.Name.String())
}

func (a *Fastcall) GenVarAddr(varBlock *parser.VarBlock) (addr string) {
	return genVarAddr(a.ctx, varBlock)
}
