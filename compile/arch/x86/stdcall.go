package x86

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"cuteify/utils"
	"strconv"
)

type Stdcall struct {
	ctx *context.Context
}

func NewStdcall(ctx *context.Context) *Stdcall {
	a := &Stdcall{
		ctx: ctx,
	}
	ctx.Reg = regmgr.NewRegMgr(regs, a.GenVarAddr)
	return a
}

func (a *Stdcall) Info() string { return "x86 stdcall" }

func (a *Stdcall) Call(call *parser.CallBlock) string {
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
		return utils.Format("mov eax, dword " + addr + "; " + methodName + "()")
	}

normalCall:
	fn := call.Func

	savedRegs := a.ctx.Reg.SaveAll(false)
	code := ""
	for _, regCode := range savedRegs {
		code += regCode
	}

	if call.ThisVar != nil {
		thisAddr := genVarAddr(a.ctx, call.ThisVar)
		code += utils.Format("push " + thisAddr + "; push this pointer")
	}

	for i := len(call.Args) - 1; i >= 0; i-- {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		code += a.Exp(arg.Value, "push", "参数"+strconv.Itoa(i))
	}

	name := fn.Name.String()
	if name != "main" {
		name = name + strconv.Itoa(len(fn.Args))
	}
	code += utils.Format("call " + name)

	return code
}

func (a *Stdcall) Return(ret *parser.ReturnBlock) string {
	code := ""
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

	argSize := 0
	if a.ctx.CurrentFunc != nil {
		argSize = arch.CalcArgsSize(a.ctx.CurrentFunc)
		if a.ctx.CurrentFunc.Class != nil {
			argSize += 4
		}
	}
	if argSize > 0 {
		code += utils.Format("ret " + strconv.Itoa(argSize) + "; stdcall: 被调者清理参数栈")
	} else {
		code += utils.Format("ret")
	}
	code += "\n"

	return code
}

func (a *Stdcall) Func(funcBlock *parser.FuncBlock) string {
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
	code := utils.Format("; ==============================")
	code += utils.Format("; Function:" + name)
	code += utils.Format(name + ":")
	utils.Count++
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

func (a *Stdcall) Exp(exp *parser.Expression, result, desc string) string {
	expc := expCom{ctx: a.ctx}
	return expc.CompileExpr(exp, result, desc)
}

func (a *Stdcall) For(forBlock *parser.ForBlock) string {
	if forBlock == nil {
		return ""
	}

	forBlock.Offset = a.ctx.IfCount
	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	forEndLabel := forLabel + "_end"

	code := utils.Format("")
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

func (a *Stdcall) EndFor(forBlock *parser.ForBlock) string {
	code := utils.Format("")
	code += utils.Format("")

	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	code += a.Exp(forBlock.Increment, "", "for循环增量")
	code += utils.Format("jmp " + forLabel + "; for循环")
	code += utils.Format(forLabel + "_end: ; for循环结束")
	return code
}

func (a *Stdcall) Var(varBlock *parser.VarBlock) string {
	if varBlock.Value == nil {
		return ""
	}
	if is64Type(varBlock.Type) {
		loAddr := genLoAddr(a.ctx, varBlock)
		hiAddr := genHiAddr(a.ctx, varBlock)
		code := a.Exp(varBlock.Value, loAddr, "设置变量"+varBlock.Name.String())
		if !isRegName(loAddr) {
			code += utils.Format("mov dword " + hiAddr + ", edx; 设置变量high")
		}
		return code
	}
	addr := genVarAddr(a.ctx, varBlock)
	return a.ctx.Arch.Exp(varBlock.Value, addr, "设置变量"+varBlock.Name.String())
}

func (a *Stdcall) GenVarAddr(varBlock *parser.VarBlock) string {
	return genVarAddr(a.ctx, varBlock)
}
