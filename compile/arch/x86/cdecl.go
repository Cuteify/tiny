package x86

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"cuteify/utils"
	"strconv"
)

// Cdecl 实现 x86 cdecl 调用约定（全部压栈，调用者清理）。
type Cdecl struct {
	ctx *context.Context
}

func NewCdecl(ctx *context.Context) *Cdecl {
	a := &Cdecl{
		ctx: ctx,
	}
	ctx.Reg = regmgr.NewRegMgr(regs, a.GenVarAddr)
	return a
}

func (a *Cdecl) Info() (code string) { return "x86 cdecl" }

func (a *Cdecl) Call(call *parser.CallBlock) (code string) {
	if call == nil || call.Func == nil {
		return ""
	}
	fn := call.Func

	// 1. 溢出caller-saved寄存器到栈（除了已经在EBX中的中间值）
	// 在函数调用前，需要将caller-saved寄存器中的值保存到内存
	// 注意：如果中间值已经通过 containsCall 检测保存到 EBX，这里不再溢出
	savedRegs := a.ctx.Reg.SaveAll(false)
	for _, regCode := range savedRegs {
		code += regCode
	}
	// 2. cdecl约定：参数从右到左压栈
	for i := len(call.Args) - 1; i >= 0; i-- {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		// 参数直接push到栈上
		code += a.Exp(arg.Value, "push", "参数"+strconv.Itoa(i))
	}

	// 3. 生成call指令
	name := fn.Name
	if name != "main" {
		name = name + strconv.Itoa(len(fn.Args))
	}
	code += utils.Format("call " + name)

	// 4. cdecl约定：调用者清理参数栈
	argSize := arch.CalcArgsSize(call.Func)
	if argSize > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(argSize) + "; 清理参数栈(cdecl)")
	}

	// 注意：caller-saved寄存器会在后续表达式中被重新加载
	// 因此不需要在这里显式恢复，SaveAll已经溢出到栈了

	return code
}

func (a *Cdecl) Return(ret *parser.ReturnBlock) (code string) {
	// 处理返回值：将值放入EAX寄存器
	if ret != nil && len(ret.Value) != 0 {
		// 强制使用EAX作为返回值寄存器
		eaxReg := &regmgr.Reg{Name: "EAX", RegIndex: 0}
		a.ctx.Reg.Force(eaxReg, a.ctx.Now, ret.Value[0])

		if eaxReg.StoreCode != "" {
			code += utils.Format(eaxReg.StoreCode)
		}

		// 编译返回表达式到EAX
		code += a.Exp(ret.Value[0], "EAX", "return值存入EAX")
		// 释放表达式使用的寄存器
		a.ctx.Reg.Free(ret.Value[0])
	}

	code += utils.Format("; ---- 退出函数 ----")

	// 清理局部变量栈空间
	if a.ctx.StackSize > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(a.ctx.StackSize) + "; 清理局部变量栈空间(" + strconv.Itoa(a.ctx.StackSize) + "字节)")
	}

	// 恢复callee-saved寄存器
	for i := len(regs) - 1; i >= 0; i-- {
		r := regs[i]
		if r.CalleeSave {
			code += utils.Format("pop " + r.Name + "; 恢复" + r.Name)
		}
	}

	// 恢复调用者的栈帧基址
	code += utils.Format("leave")
	code += utils.Format("ret\n")
	return code
}

func (a *Cdecl) Func(funcBlock *parser.FuncBlock) (code string) {
	if funcBlock == nil {
		return ""
	}

	// cdecl约定：参数通过栈传递
	// 栈布局：[ebp+8] = 第一个参数, [ebp+12] = 第二个参数, ...
	// 注意：[ebp+4] = 返回地址, [ebp] = 保存的ebp
	argOffset := 8 // 第一个参数起始偏移
	for i := 0; i < len(funcBlock.Args); i++ {
		arg := funcBlock.Args[i]
		arg.Offset = argOffset
		argOffset += arg.Type.Size()
	}

	// 函数序言
	code += utils.Format("push ebp; 保存调用者的栈帧基址")
	code += utils.Format("mov ebp, esp; 设置当前栈帧基址")

	// 保存callee-saved寄存器
	csCount := 0
	for i := 0; i < len(regs); i++ {
		r := regs[i]
		if r.CalleeSave {
			code += utils.Format("push " + r.Name + "; 保存" + r.Name)
			csCount++
		}
	}

	// 设置变量偏移量并计算栈大小
	// StackSize 会包含局部变量空间，后续再加上 callee-saved 寄存器空间
	a.ctx.StackSize = arch.SetupVarOffsets(a.ctx.Now, a.ctx.StackAlignment, -4*csCount)

	// 为局部变量和callee-saved寄存器分配栈空间
	if a.ctx.StackSize > 0 {
		code += utils.Format("sub esp, " + strconv.Itoa(a.ctx.StackSize) + "; 分配栈空间(" + strconv.Itoa(a.ctx.StackSize) + "字节)")
	}

	code += utils.Format("; ---- 函数开始 ----")
	return code
}

func (a *Cdecl) Exp(exp *parser.Expression, result, desc string) (code string) {
	expc := expCom{ctx: a.ctx}
	exp.Check(a.ctx.Parser)
	return expc.CompileExpr(exp, result, desc)
}

func (a *Cdecl) For(forBlock *parser.ForBlock) (code string) {
	if forBlock == nil {
		return ""
	}

	forBlock.Offset = a.ctx.IfCount
	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	forEndLabel := forLabel + "_end"

	code += utils.Format("")
	code += utils.Format("")

	// 1. 初始化 - 编译变量定义
	if forBlock.Init != nil {
		// 编译初始化表达式到变量地址
		code += a.Exp(forBlock.Init, "", "初始化for循环")
	}

	code += utils.Format("")
	code += utils.Format("")

	// 循环开始标签
	code += utils.Format(forLabel + ": ; for循环开始")

	// 2. 条件检查 - 如果条件为假则跳出循环
	if forBlock.Condition != nil && !forBlock.Condition.Bool {
		// 将条件编译到一个临时寄存器
		code += a.Exp(forBlock.Condition, forEndLabel, "for循环条件检查")
	}

	code += utils.Format("")
	code += utils.Format("")

	return code
}

func (a *Cdecl) EndFor(forBlock *parser.ForBlock) (code string) {
	code += utils.Format("")
	code += utils.Format("")

	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	code += a.Exp(forBlock.Increment, "", "for循环增量")
	code += utils.Format("jmp " + forLabel + "; for循环")
	code += utils.Format(forLabel + "_end: ; for循环结束")
	return
}

func (a *Cdecl) Var(varBlock *parser.VarBlock) (code string) {
	addr := genVarAddr(a.ctx, varBlock)
	if varBlock.Value == nil {
		return
	}
	code += a.ctx.Arch.Exp(varBlock.Value, addr, "设置变量"+varBlock.Name)
	return
}

func (a *Cdecl) GenVarAddr(varBlock *parser.VarBlock) (addr string) {
	return genVarAddr(a.ctx, varBlock)
}
