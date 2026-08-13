package x86

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
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
	ctx.Reg = regmgr.NewRegMgr(a)
	return a
}

func (a *Stdcall) Info(ctx *context.Context) string { return "x86 stdcall" }

func (a *Stdcall) Call(ctx *context.Context, call *parser.CallBlock) string {
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
		code += a.Exp(ctx, arg.Value, "push", "参数"+strconv.Itoa(i))
	}

	name := fn.Name.String()
	if name != "main" {
		name = name + strconv.Itoa(len(fn.Args))
	}
	code += utils.Format("call " + name)

	return code
}

func (a *Stdcall) Return(ctx *context.Context, ret *parser.ReturnBlock) string {
	code := ""
	if ret != nil && len(ret.Value) != 0 {
		if is64Type(ret.Value[0].Type) {
			code += a.Exp(ctx, ret.Value[0], "EDX:EAX", "return值存入EDX:EAX")
			a.ctx.Reg.Free(ret.Value[0])
		} else {
			eaxReg := &regmgr.Reg{Name: "EAX", RegIndex: 0}
			a.ctx.Reg.Force(eaxReg, ret.Value[0])

			if eaxReg.StoreCode != "" {
				code += utils.Format(eaxReg.StoreCode)
			}

			code += a.Exp(ctx, ret.Value[0], "EAX", "return值存入EAX")
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

func (a *Stdcall) Func(ctx *context.Context, funcBlock *parser.FuncBlock) string {
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

func (a *Stdcall) Exp(ctx *context.Context, exp *parser.Expression, result, desc string) string {
	expc := NewExpCom(a.ctx)
	return expc.CompileExpr(exp, result, desc)
}

func (a *Stdcall) For(ctx *context.Context, forBlock *parser.ForBlock) string {
	if forBlock == nil {
		return ""
	}

	forBlock.Offset = a.ctx.IfCount
	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	forEndLabel := forLabel + "_end"

	code := utils.Format("")
	code += utils.Format("")

	if forBlock.Init != nil {
		code += a.Exp(ctx, forBlock.Init, "", "初始化for循环")
	}

	code += utils.Format("")
	code += utils.Format("")

	code += utils.Format(forLabel + ": ; for循环开始")

	if forBlock.Condition != nil && !forBlock.Condition.Bool {
		code += a.Exp(ctx, forBlock.Condition, forEndLabel, "for循环条件检查")
	}

	code += utils.Format("")
	code += utils.Format("")

	return code
}

func (a *Stdcall) EndFor(ctx *context.Context, forBlock *parser.ForBlock) string {
	code := utils.Format("")
	code += utils.Format("")

	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	code += a.Exp(ctx, forBlock.Increment, "", "for循环增量")
	code += utils.Format("jmp " + forLabel + "; for循环")
	code += utils.Format(forLabel + "_end: ; for循环结束")
	return code
}

func (a *Stdcall) Var(ctx *context.Context, varBlock *parser.VarBlock) string {
	if varBlock.Value == nil {
		return ""
	}
	if is64Type(varBlock.Type) {
		loAddr := genLoAddr(a.ctx, varBlock)
		hiAddr := genHiAddr(a.ctx, varBlock)
		code := a.Exp(ctx, varBlock.Value, loAddr, "设置变量"+varBlock.Name.String())
		if !isRegName(loAddr) {
			code += utils.Format("mov dword " + hiAddr + ", edx; 设置变量high")
		}
		return code
	}
	addr := genVarAddr(a.ctx, varBlock)
	return a.ctx.Arch.Exp(a.ctx, varBlock.Value, addr, "设置变量"+varBlock.Name.String())
}

func (a *Stdcall) GenVarAddr(ctx *context.Context, varBlock *parser.VarBlock) string {
	return genVarAddr(a.ctx, varBlock)
}

// ---- Arch 接口：寄存器信息 ----

func (a *Stdcall) CalleeSaveReg(ctx *context.Context) string           { return "EBX" }
func (a *Stdcall) ReturnReg(ctx *context.Context) string               { return "EAX" }
func (a *Stdcall) HiReg(ctx *context.Context) string                   { return "EDX" }
func (a *Stdcall) IsCalleeSave(ctx *context.Context, name string) bool { return name == "EBX" }
func (a *Stdcall) DefaultRegMask(ctx *context.Context) uint32          { return ClassGPR }

// ---- Arch 接口：大小/前缀 ----

func (a *Stdcall) PointerSize(ctx *context.Context) int           { return 4 }
func (a *Stdcall) SizePrefix(ctx *context.Context) string         { return "DWORD" }
func (a *Stdcall) LengthName(ctx *context.Context, sz int) string { return GetLengthName(sz) }

// ---- Arch 接口：地址 ----

func (a *Stdcall) FormatAddr(ctx *context.Context, offset int) string {
	if offset < 0 {
		return "[ebp" + strconv.Itoa(offset) + "]"
	} else if offset == 0 {
		return "[ebp]"
	}
	return "[ebp+" + strconv.Itoa(offset) + "]"
}

func (a *Stdcall) ExtractOffset(ctx *context.Context, addr string) (int, bool) {
	return extractEbpOffset(addr)
}

// ---- Arch 接口：指令 ----

func (a *Stdcall) EmitDiv(ctx *context.Context, regName, src string) string {
	return utils.Format("div " + src + "; " + regName + " / " + src)
}

func (a *Stdcall) EmitMod(ctx *context.Context, regName, src string) string {
	return utils.Format("div " + src + "; " + regName + " % " + src)
}

func (a *Stdcall) EmitDivWithCallee(ctx *context.Context, regName, src string) string {
	return utils.Format("idiv " + src + "; " + regName + " / " + src)
}

func (a *Stdcall) EmitModWithCallee(ctx *context.Context, regName, src string) string {
	return utils.Format("idiv " + src + "; " + regName + " % " + src)
}

func (a *Stdcall) EmitCmpJump(ctx *context.Context, op, result string) string {
	return utils.Format("j" + op + " " + result + "; cmp jump " + op)
}

// ---- Arch 接口：64 位类型 ----

func (a *Stdcall) Is64Type(ctx *context.Context, t typeSys.Type) bool {
	if t == nil {
		return false
	}
	return t.Size() == 8 && (t.Type() == "i64" || t.Type() == "u64" || t.Type() == "f64")
}

func (a *Stdcall) Compile64Type(ctx *context.Context, e *parser.Expression, result, desc string) string {
	return compile64Type(a.ctx, e, result, desc)
}

// ---- Arch 接口：寄存器绑定 ----

func (a *Stdcall) NeedBindMask(ctx *context.Context, op string) uint32 {
	switch op {
	case "/", "%":
		return ClassDiv
	default:
		return 0
	}
}

func (a *Stdcall) NeedBindRegs(ctx *context.Context, op string) []*regmgr.Reg {
	switch op {
	case "/", "%":
		return []*regmgr.Reg{
			{Name: "EAX", RegIndex: 0, ClassMask: ClassDiv},
			{Name: "EDX", RegIndex: 3, ClassMask: ClassDiv},
		}
	default:
		return nil
	}
}

func (a *Stdcall) NeedRegClass(ctx *context.Context, bt typeSys.BackendType) uint32 {
	return ClassGPR
}
