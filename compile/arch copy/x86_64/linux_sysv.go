package x86_64

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strconv"
)

var sysvArgRegs = []string{"RDI", "RSI", "RDX", "RCX", "R8", "R9"}

type SysV struct {
	ctx *context.Context
}

func NewSysV(ctx *context.Context) *SysV {
	a := &SysV{ctx: ctx}
	ctx.Reg = regmgr.NewRegMgr(Regs, a.GenVarAddr)
	ctx.PointerSize = 8
	ctx.Is64Bit = true
	ctx.StackAlignment = 16
	return a
}

func (a *SysV) Info(ctx *context.Context) string { return "x86_64 System V AMD64 ABI" }

func (a *SysV) Call(ctx *context.Context, call *parser.CallBlock) (code string) {
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
		thisAddr := GenVarAddr(a.ctx, call.ThisVar)
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
			code += a.Exp(ctx, arg.Value, "push", "参数"+strconv.Itoa(i))
		}
	}

	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		regIdx := argRegIdx + i
		if regIdx < len(sysvArgRegs) {
			code += a.Exp(ctx, arg.Value, sysvArgRegs[regIdx], "参数"+strconv.Itoa(i))
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

func (a *SysV) Return(ctx *context.Context, ret *parser.ReturnBlock) (code string) {
	if ret != nil && len(ret.Value) != 0 {
		raxReg := &regmgr.Reg{Name: "RAX", RegIndex: 0}
		a.ctx.Reg.Force(raxReg, ret.Value[0])

		if raxReg.StoreCode != "" {
			code += utils.Format(raxReg.StoreCode)
		}

		code += a.Exp(ctx, ret.Value[0], "RAX", "return值存入RAX")
		a.ctx.Reg.Free(ret.Value[0])
	}

	// 跳转到函数末尾的公共 epilogue
	code += utils.Format("jmp func_end")
	return code
}

func (a *SysV) Func(ctx *context.Context, funcBlock *parser.FuncBlock) (code string) {
	if funcBlock == nil {
		return ""
	}

	// 计算参数在栈上的偏移(从rbp+16开始,因为rbp在rbp+0,返回地址在rbp+8)
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

	// 只保存实际使用的 callee-save 寄存器
	csCount := 0
	for _, regName := range a.ctx.UsedCalleeSaveRegs {
		code += utils.Format("push " + regName)
		csCount++
	}

	// 设置局部变量偏移
	a.ctx.StackSize = arch.SetupVarOffsets(a.ctx.Now, a.ctx.StackAlignment, -8*csCount)

	if a.ctx.StackSize > 0 {
		code += utils.Format("sub rsp, " + strconv.Itoa(a.ctx.StackSize))
	}

	// 将寄存器参数保存到栈上(SysV ABI: RDI, RSI, RDX, RCX, R8, R9)
	argRegIdx := 0
	if funcBlock.Class != nil {
		// 如果有this指针,第一个寄存器是this
		argRegIdx = 1
	}

	for i := 0; i < len(funcBlock.Args); i++ {
		arg := funcBlock.Args[i]
		if argRegIdx+i < len(sysvArgRegs) {
			regName := sysvArgRegs[argRegIdx+i]
			// 参数地址是 [rbp + arg.Offset]
			addr := "[rbp+" + strconv.Itoa(arg.Offset) + "]"
			code += utils.Format("mov QWORD " + addr + ", " + regName + "; 保存参数" + strconv.Itoa(i) + "到栈")
		}
	}

	return code
}

func (a *SysV) Exp(ctx *context.Context, exp *parser.Expression, result, desc string) (code string) {
	expc := ExpCom{ctx: a.ctx}
	return expc.CompileExpr(exp, result, desc)
}

func (a *SysV) For(ctx *context.Context, forBlock *parser.ForBlock) (code string) {
	if forBlock == nil {
		return ""
	}

	// 使用独立的 ForCount 计数器，避免与 IfCount 冲突
	a.ctx.ForCount++
	forBlock.Offset = a.ctx.ForCount
	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	forEndLabel := forLabel + "_end"

	code += utils.Format("")
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

func (a *SysV) EndFor(ctx *context.Context, forBlock *parser.ForBlock) (code string) {
	code += utils.Format("")
	code += utils.Format("")

	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	code += a.Exp(ctx, forBlock.Increment, "", "for循环增量")
	code += utils.Format("jmp " + forLabel + "; for循环")
	code += utils.Format(forLabel + "_end: ; for循环结束")
	return
}

func (a *SysV) Var(ctx *context.Context, varBlock *parser.VarBlock) (code string) {
	addr := GenVarAddr(a.ctx, varBlock)
	if varBlock.Value == nil {
		return
	}
	code += a.ctx.Arch.Exp(varBlock.Value, addr, "设置变量"+varBlock.Name.String())
	return
}

func (a *SysV) GenVarAddr(ctx *context.Context, varBlock *parser.VarBlock) (addr string) {
	return GenVarAddr(a.ctx, varBlock)
}

// ---- Arch 接口：寄存器信息 ----

func (a *SysV) CalleeSaveReg(ctx *context.Context) string  { return "RBX" }
func (a *SysV) DefaultRegMask(ctx *context.Context) uint32 { return ClassGPR }

// ---- Arch 接口：大小/前缀 ----

func (a *SysV) PointerSize(ctx *context.Context) int           { return 8 }
func (a *SysV) SizePrefix(ctx *context.Context) string         { return "QWORD" }
func (a *SysV) LengthName(ctx *context.Context, sz int) string { return GetLenName(sz) }

// ---- Arch 接口：寄存器绑定 ----

func (a *SysV) NeedBindMask(ctx *context.Context, op string) uint32 {
	switch op {
	case "/", "%":
		return ClassDiv // 除法/取模需要 RAX/RDX
	default:
		return 0
	}
}

func (a *SysV) NeedBindRegs(ctx *context.Context, op string) []*regmgr.Reg {
	switch op {
	case "/", "%":
		return []*regmgr.Reg{
			{Name: "RAX", RegIndex: 0, ClassMask: ClassDiv},
			{Name: "RDX", RegIndex: 3, ClassMask: ClassDiv},
		}
	default:
		return nil
	}
}

func (a *SysV) NeedRegClass(ctx *context.Context, bt typeSys.BackendType) uint32 {
	return ClassGPR // x86_64 所有类型都用通用寄存器
}
