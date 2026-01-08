package x86

import (
	"cuteify/compile/arch"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"cuteify/utils"
	"strconv"
)

// Cdecl 实现 x86 cdecl 调用约定（全部压栈，调用者清理）。
type Cdecl struct {
	stackSize int
	regmgr    *regmgr.RegMgr
	now       *parser.Node
}

func (a *Cdecl) Info() string { return "x86 cdecl" }
func (a *Cdecl) Regs() *regmgr.RegMgr {
	if a.regmgr == nil {
		a.regmgr = regmgr.NewRegMgr(regs)
	}
	return a.regmgr
}

func (a *Cdecl) Now(node *parser.Node) { a.now = node }

func (a *Cdecl) Call(call *parser.CallBlock) string {
	if call == nil || call.Func == nil {
		return ""
	}
	fn := call.Func
	code := ""

	// 1. 溢出caller-saved寄存器到栈（除了已经在EBX中的中间值）
	// 在函数调用前，需要将caller-saved寄存器中的值保存到内存
	// 注意：如果中间值已经通过 containsCall 检测保存到 EBX，这里不再溢出
	savedRegs := a.regmgr.SaveAll(false)
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

func (a *Cdecl) Return(ret *parser.ReturnBlock) string {
	code := ""

	// 处理返回值：将值放入EAX寄存器
	if ret != nil && len(ret.Value) != 0 {
		// 强制使用EAX作为返回值寄存器
		eaxReg := &regmgr.Reg{Name: "EAX", RegIndex: 0}
		a.regmgr.Force(eaxReg, a.now, ret.Value[0])

		if eaxReg.StoreCode != "" {
			code += utils.Format(eaxReg.StoreCode)
		}

		// 编译返回表达式到EAX
		code += a.Exp(ret.Value[0], "EAX", "return值存入EAX")
		// 释放表达式使用的寄存器
		a.regmgr.Free(ret.Value[0])
	}

	code += utils.Format("; ---- 退出函数 ----")

	// 清理局部变量栈空间
	if a.stackSize > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(a.stackSize) + "; 清理局部变量栈空间(" + strconv.Itoa(a.stackSize) + "字节)")
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

func (a *Cdecl) Func(funcBlock *parser.FuncBlock) string {
	if funcBlock == nil {
		return ""
	}

	code := ""

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

	// 调整局部变量起始位置让出callee-saved寄存器空间
	arch.ResetLocalVarOffset(a.now, -4*csCount)

	// 为局部变量分配栈空间（4字节对齐）
	//code += utils.Format("; ---- 分配局部变量栈空间 ----")
	a.stackSize = arch.CalcStackSize(a.now, 4)
	if a.stackSize > 0 {
		code += utils.Format("sub esp, " + strconv.Itoa(a.stackSize) + "; 分配局部变量栈空间(" + strconv.Itoa(a.stackSize) + "字节)")
	}

	code += utils.Format("; ---- 函数开始 ----")
	return code
}

func (a *Cdecl) Exp(exp *parser.Expression, result, desc string) string {
	expc := expCom{arch: a, now: a.now, regmgr: a.regmgr}
	return expc.CompileExpr(exp, result, desc)
}

// caldAddrWithLen 生成带长度前缀的内存地址表达式
// 用于函数参数传递时的栈地址计算
func caldAddrWithLen(size int, offset int) string {
	if offset == 0 {
		return utils.GetLengthName(size) + "[ebp]"
	}
	return utils.GetLengthName(size) + "[ebp + " + strconv.FormatInt(int64(offset), 10) + "]"
}
