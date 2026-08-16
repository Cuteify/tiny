// Package x86 x86 架构共享实现（cdecl/stdcall 共用）。
package x86

import (
	"strings"
	"cuteify/compile/arch"
	exppkg "cuteify/compile/exp"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strconv"
)

// x86Ops 实现 x86 架构共用的 Arch 接口方法（寄存器/指令/地址等）。
// 通过内嵌到 Cdecl/Stdcall 复用。
type x86Ops struct {
	ctx *context.Context
}

// newOps 创建共享实现
func newOps(ctx *context.Context) *x86Ops {
	return &x86Ops{ctx: ctx}
}

// ---- 寄存器信息 ----

func (a *x86Ops) ReturnReg() string { return "EAX" }
func (a *x86Ops) HiReg() string     { return "EDX" }

func (a *x86Ops) CalleeSaveReg() string { return "EBX" }

func (a *x86Ops) CalleeSaveRegs() []string { return []string{"EBX"} }

func (a *x86Ops) IsCalleeSave(name string) bool { return name == "EBX" }

func (a *x86Ops) DefaultRegMask() uint32 { return ClassGPR }

func (a *x86Ops) NeedRegClass(bt typeSys.BackendType) uint32 { return ClassGPR }

func (a *x86Ops) NeedBindMask(op string) uint32 {
	switch op {
	case "/", "%":
		return ClassDiv // 除法/取模需要 EAX/EDX
	default:
		return 0
	}
}

func (a *x86Ops) NeedBindRegs(op string) []*regmgr.Reg {
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

// ---- 栈与地址 ----

func (a *x86Ops) FramePtr() string { return "EBP" }
func (a *x86Ops) StackPtr() string { return "ESP" }

func (a *x86Ops) PointerSize() int   { return 4 }
func (a *x86Ops) PushSize() int      { return 4 }
func (a *x86Ops) SizePrefix() string { return "DWORD" }

func (a *x86Ops) LengthName(sz int) string { return GetLengthName(sz) }

func (a *x86Ops) FormatAddr(offset int) string {
	if offset < 0 {
		return "[ebp" + strconv.Itoa(offset) + "]"
	} else if offset == 0 {
		return "[ebp]"
	}
	return "[ebp+" + strconv.Itoa(offset) + "]"
}

func (a *x86Ops) ExtractOffset(addr string) (int, bool) {
	return extractEbpOffset(addr)
}

// ---- 指令 ----

func (a *x86Ops) Cmp(dst, src string) string {
	return utils.Format("cmp " + dst + ", " + src)
}

// Jump 生成比较跳转：当条件不成立时跳转到目标标签
func (a *x86Ops) Jump(typ, dst, src string) string {
	op := "jmp"
	switch typ {
	case "==":
		op = "jne"
	case "!=":
		op = "je"
	case "<":
		op = "jge"
	case ">":
		op = "jle"
	case "<=":
		op = "jg"
	case ">=":
		op = "jl"
	}
	return utils.Format(op + " " + dst)
}

func (a *x86Ops) InstMov(dst, src string) string {
	return utils.Format("mov " + dst + ", " + src)
}

func (a *x86Ops) InstPush(val string) string {
	return utils.Format("push " + val)
}

func (a *x86Ops) InstPop(addr string) string {
	return utils.Format("pop " + addr)
}

func (a *x86Ops) InstUnary(op, reg string) string {
	switch op {
	case "-":
		return utils.Format("neg " + reg)
	case "~":
		return utils.Format("not " + reg)
	case "!":
		code := utils.Format("cmp " + reg + ", 0")
		code += utils.Format("sete al")
		code += utils.Format("movzx " + reg + ", al")
		return code
	default:
		return ""
	}
}

// InstBinary 生成二元运算指令。
// dst 可以是寄存器或内存地址（如 DWORD[ebp-8]）。
// 除法/取模通过 push 除数到栈上避免寄存器冲突（EAX/EDX 被 cdq 占用）。
func (a *x86Ops) InstBinary(dst, op, src string) string {
	switch op {
	case "+":
		return utils.Format("add " + dst + ", " + src)
	case "-":
		return utils.Format("sub " + dst + ", " + src)
	case "*":
		if strings.Contains(dst, "[") {
			// nasm 不支持 imul 内存目标，经栈中转
			code := ""
			if strings.Contains(src, "[") {
				code += utils.Format("mov EAX, " + src)
				src = "EAX"
			}
			code += utils.Format("push " + src + "; 暂存乘数")
			code += utils.Format("mov EAX, " + dst)
			code += utils.Format("imul EAX, dword [esp]")
			code += utils.Format("mov " + dst + ", EAX")
			code += utils.Format("add esp, 4; 清理乘数")
			return code
		}
		return utils.Format("imul " + dst + ", " + src)
	case "/":
		code := utils.Format("push " + src + "; 保存除数")
		code += utils.Format("mov eax, " + dst)
		code += utils.Format("cdq")
		code += utils.Format("idiv dword [esp]")
		code += utils.Format("add esp, 4; 清理除数")
		code += utils.Format("mov " + dst + ", eax")
		return code
	case "%":
		code := utils.Format("push " + src + "; 保存除数")
		code += utils.Format("mov eax, " + dst)
		code += utils.Format("cdq")
		code += utils.Format("idiv dword [esp]")
		code += utils.Format("add esp, 4; 清理除数")
		code += utils.Format("mov " + dst + ", edx")
		return code
	case "^":
		return utils.Format("xor " + dst + ", " + src)
	case "&":
		return utils.Format("and " + dst + ", " + src)
	case "|":
		return utils.Format("or " + dst + ", " + src)
	case "<<":
		if !utils.IsNumber(src) && strings.ToUpper(src) != "CL" && src != "cl" {
			// shift count 只能是 CL 或立即数，经栈中转低字节到 CL
			code := ""
			if strings.Contains(src, "[") {
				code += utils.Format("mov EAX, " + src)
				src = "EAX"
			}
			code += utils.Format("push " + src + "; 暂存移位计数")
			code += utils.Format("mov cl, byte [esp]")
			code += utils.Format("shl " + dst + ", cl")
			code += utils.Format("add esp, 4; 清理移位计数")
			return code
		}
		return utils.Format("shl " + dst + ", " + src)
	case ">>":
		if !utils.IsNumber(src) && strings.ToUpper(src) != "CL" && src != "cl" {
			code := ""
			if strings.Contains(src, "[") {
				code += utils.Format("mov EAX, " + src)
				src = "EAX"
			}
			code += utils.Format("push " + src + "; 暂存移位计数")
			code += utils.Format("mov cl, byte [esp]")
			code += utils.Format("sar " + dst + ", cl")
			code += utils.Format("add esp, 4; 清理移位计数")
			return code
		}
		return utils.Format("sar " + dst + ", " + src)
	default:
		return ""
	}
}

// ---- 数据类型 ----

func (a *x86Ops) Is64Type(t typeSys.Type) bool {
	return is64Type(t)
}

func (a *x86Ops) Compile64Type(e *parser.Expression, result, desc string) string {
	return compile64Type(a.ctx, e, result, desc)
}

// ---- 表达式与语句 ----

// VarDecl 变量声明/赋值
func (a *x86Ops) VarDecl(varBlock *parser.VarBlock) string {
	if varBlock.Value == nil {
		return exppkg.New(a.ctx).ZeroVar(varBlock)
	}
	return exppkg.New(a.ctx).Assign(varBlock)
}

// VarAddr 变量地址
func (a *x86Ops) VarAddr(v *parser.VarBlock) string {
	return genVarAddr(a.ctx, v)
}

// ForBegin 生成 for 循环起始代码
func (a *x86Ops) ForBegin(forBlock *parser.ForBlock) string {
	// 使用独立的 ForCount 计数器，避免与 IfCount 冲突
	a.ctx.ForCount++
	forBlock.Offset = a.ctx.ForCount
	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	forEndLabel := forLabel + "_end"

	var code string
	code += utils.Format("")
	code += utils.Format("")

	if forBlock.Init != nil {
		if forBlock.Init.Var != nil {
			code += a.VarDecl(forBlock.Init.Var)
		} else {
			code += a.exp(forBlock.Init, "", "初始化for循环")
		}
	}

	code += utils.Format("")
	code += utils.Format("")

	code += utils.Format(forLabel + ": ; for循环开始")

	if forBlock.Condition != nil && !forBlock.Condition.Bool {
		code += a.compileCond(forBlock.Condition, forEndLabel)
	}

	code += utils.Format("")
	code += utils.Format("")

	return code
}

// ForEnd 生成 for 循环结束代码
func (a *x86Ops) ForEnd(forBlock *parser.ForBlock) string {
	var code string
	code += utils.Format("")
	code += utils.Format("")

	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	if forBlock.Increment != nil {
		if forBlock.Increment.Var != nil {
			code += a.VarDecl(forBlock.Increment.Var)
		} else {
			code += a.exp(forBlock.Increment, "", "for循环增量")
		}
	}
	code += utils.Format("jmp " + forLabel + "; for循环")
	code += utils.Format(forLabel + "_end: ; for循环结束")
	return code
}

// compileCond 编译条件表达式，生成比较和跳转指令（与 compiler.compileCondition 逻辑一致）
func (a *x86Ops) Compare64(cond *parser.Expression, jumpLabel string) string {
	return a.compileCond64(cond, jumpLabel)
}

// compileCond64 64 位比较：右侧先算压栈，左侧算到 EDX:EAX，右出栈到 EBX:ECX（无符号比较）
func (a *x86Ops) compileCond64(cond *parser.Expression, jumpLabel string) string {
	var code string
	if cond.Right != nil {
		if cond.Right.IsConst() {
			lo, hi := splitConst64(cond.Right.Num)
			code += utils.Format("mov eax, " + lo + "; right operand")
			code += utils.Format("mov edx, " + hi)
		} else if a.Is64Type(cond.Right.Type) {
			code += a.exp(cond.Right, "EDX:EAX", "right operand")
		} else {
			code += a.exp(cond.Right, "EAX", "right operand")
			code += utils.Format("mov edx, 0")
		}
		code += utils.Format("push edx; right high")
		code += utils.Format("push eax; right low")
	} else {
		code += utils.Format("push 0")
		code += utils.Format("push 0")
	}
	if cond.Left != nil {
		if cond.Left.IsConst() {
			lo, hi := splitConst64(cond.Left.Num)
			code += utils.Format("mov eax, " + lo + "; left operand")
			code += utils.Format("mov edx, " + hi)
		} else if a.Is64Type(cond.Left.Type) {
			code += a.exp(cond.Left, "EDX:EAX", "left operand")
		} else {
			code += a.exp(cond.Left, "EAX", "left operand")
			code += utils.Format("mov edx, 0")
		}
	} else {
		code += utils.Format("mov eax, 0")
		code += utils.Format("mov edx, 0")
	}
	code += utils.Format("pop ebx; right low")
	code += utils.Format("pop ecx; right high")

	utils.Count++
	trueLabel := "c64_" + strconv.Itoa(utils.Count)
	code += utils.Format("cmp edx, ecx")
	switch cond.Separator {
	case "==":
		code += utils.Format("jne " + jumpLabel)
		code += utils.Format("cmp eax, ebx")
		code += utils.Format("jne " + jumpLabel)
	case "!=":
		code += utils.Format("jne " + trueLabel)
		code += utils.Format("cmp eax, ebx")
		code += utils.Format("je " + jumpLabel)
	case "<":
		code += utils.Format("jb " + trueLabel)
		code += utils.Format("ja " + jumpLabel)
		code += utils.Format("cmp eax, ebx")
		code += utils.Format("jae " + jumpLabel)
	case ">":
		code += utils.Format("ja " + trueLabel)
		code += utils.Format("jb " + jumpLabel)
		code += utils.Format("cmp eax, ebx")
		code += utils.Format("jbe " + jumpLabel)
	case "<=":
		code += utils.Format("jb " + trueLabel)
		code += utils.Format("ja " + jumpLabel)
		code += utils.Format("cmp eax, ebx")
		code += utils.Format("ja " + jumpLabel)
	case ">=":
		code += utils.Format("ja " + trueLabel)
		code += utils.Format("jb " + jumpLabel)
		code += utils.Format("cmp eax, ebx")
		code += utils.Format("jb " + jumpLabel)
	}
	code += utils.Format(trueLabel + ":")
	return code
}

func (a *x86Ops) compileCond(cond *parser.Expression, jumpLabel string) string {
	if cond == nil {
		return ""
	}

	scratchReg1 := "EAX"
	scratchReg2 := "ECX"

	var code string

	switch cond.Separator {
	case "==", "!=", "<", ">", "<=", ">=":

		is64 := (cond.Left != nil && a.Is64Type(cond.Left.Type)) || (cond.Right != nil && a.Is64Type(cond.Right.Type))

		if !is64 {
			if cond.Left != nil {
				code += a.exp(cond.Left, scratchReg1, "left operand")
			}
			if cond.Right != nil {
				code += a.exp(cond.Right, scratchReg2, "right operand")
			}

			code += utils.Format("cmp " + scratchReg1 + ", " + scratchReg2)

			var jumpOp string
			switch cond.Separator {
			case "==":
				jumpOp = "jne"
			case "!=":
				jumpOp = "je"
			case "<":
				jumpOp = "jge"
			case ">":
				jumpOp = "jle"
			case "<=":
				jumpOp = "jg"
			case ">=":
				jumpOp = "jl"
			}
			code += utils.Format(jumpOp + " " + jumpLabel)
			break
		}

		code += a.compileCond64(cond, jumpLabel)
	case "&&", "||":
		if cond.Left != nil {
			code += a.compileCond(cond.Left, jumpLabel)
		}
		if cond.Right != nil {
			code += a.compileCond(cond.Right, jumpLabel)
		}
	default:
		code += a.exp(cond, scratchReg1, "condition")
		code += utils.Format("test " + scratchReg1 + ", " + scratchReg1)
		code += utils.Format("jz " + jumpLabel)
	}

	return code
}

// ---- 程序入口 ----

func (a *x86Ops) GenerateStartEntry() string {
	var code string
	code += utils.Format("; ==============================")
	code += utils.Format("; 程序入口点 (ELF入口)")
	code += utils.Format("_start:")
	utils.Count++
	code += utils.Format("call main")
	code += utils.Format("mov ebx, eax")
	code += utils.Format("mov eax, 1")
	code += utils.Format("int 0x80\n")
	utils.Count--
	return code
}

// formatFuncName 生成汇编函数名（非 main 函数附加参数个数）
func formatFuncName(name string, argsLen int) string {
	if name != "main" {
		name = name + strconv.Itoa(argsLen)
	}
	return name
}

// varDecl64 生成 64 位变量声明代码（x86 上占用两个 32 位槽位）
func (a *x86Ops) varDecl64(varBlock *parser.VarBlock) string {
	if varBlock.Value == nil {
		return ""
	}
	loAddr := genLoAddr(a.ctx, varBlock)
	hiAddr := genHiAddr(a.ctx, varBlock)
	code := compile64Type(a.ctx, varBlock.Value, loAddr, "设置变量"+varBlock.Name.String())
	if !isRegName(loAddr) {
		code += utils.Format("mov dword " + hiAddr + ", edx; 设置变量high")
	}
	return code
}

// setArgsOffset 设置参数偏移（ebp+8 起，this 指针额外 +4）
func setArgsOffset(fn *parser.FuncBlock) {
	argOffset := 8
	if fn.Class != nil {
		argOffset += 4
	}
	for i := 0; i < len(fn.Args); i++ {
		arg := fn.Args[i]
		arg.Offset = argOffset
		argOffset += arg.Type.Size()
	}
}

// prologue 生成函数前序（cdecl/stdcall 共用）
func (a *x86Ops) prologue(fn *parser.FuncBlock) (code string) {
	if fn == nil {
		panic("内部错误")
	}

	// 设置参数偏移量（ebp+8 起）
	setArgsOffset(fn)

	// 准备栈帧
	code += utils.Format("push ebp; 保存调用者的栈帧基址")
	code += utils.Format("mov ebp, esp; 设置当前栈帧基址")

	// 固定保存所有 callee-save 寄存器（不依赖分配器记录，保证确定性和栈布局一致性）
	csRegs := a.CalleeSaveRegs()
	for _, regName := range csRegs {
		code += utils.Format("push " + regName + "; 保存" + regName)
	}

	a.ctx.StackSize = arch.SetupVarOffsets(a.ctx.Now, a.ctx.StackAlignment, -4*len(csRegs))

	if a.ctx.StackSize > 0 {
		code += utils.Format("sub esp, " + strconv.Itoa(a.ctx.StackSize) + "; 分配栈空间(" + strconv.Itoa(a.ctx.StackSize) + "字节)")
	}

	code += utils.Format("\n")
	return code
}

// epilogue 生成函数后序公共返回点
func (a *x86Ops) epilogue(fn *parser.FuncBlock, stdcallCleanup bool) string {
	funcName := formatFuncName(fn.Name.NASM(), len(fn.Args))
	code := utils.Format("func_end_" + funcName + ":")

	// 清理局部变量栈空间
	if a.ctx.StackSize > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(a.ctx.StackSize) + "; 清理局部变量栈空间(" + strconv.Itoa(a.ctx.StackSize) + "字节)")
	}

	// 恢复 callee-save 寄存器(逆序)
	csRegs := a.CalleeSaveRegs()
	for i := len(csRegs) - 1; i >= 0; i-- {
		code += utils.Format("pop " + csRegs[i] + "; 恢复" + csRegs[i])
	}

	code += utils.Format("leave; 恢复栈帧")

	if stdcallCleanup {
		// stdcall: 被调者清理参数栈
		argSize := 0
		if a.ctx.CurrentFunc != nil {
			argSize = arch.CalcArgsSize(a.ctx.CurrentFunc, 4)
			if a.ctx.CurrentFunc.Class != nil {
				argSize += 4
			}
		}
		if argSize > 0 {
			code += utils.Format("ret " + strconv.Itoa(argSize) + "; stdcall: 被调者清理参数栈")
		} else {
			code += utils.Format("ret")
		}
	} else {
		// cdecl: ret 不带参数(调用者清理)
		code += utils.Format("ret")
	}
	code += "\n"
	return code
}

// returnValue 生成返回值代码（EAX 或 EDX:EAX 双字）
func (a *x86Ops) returnValue(ret *parser.ReturnBlock) (code string) {
	if ret == nil || len(ret.Value) == 0 {
		return ""
	}
	is64 := is64Type(ret.Value[0].Type)
	if !is64 && a.ctx.CurrentFunc != nil && len(a.ctx.CurrentFunc.Return) > 0 {
		is64 = is64Type(a.ctx.CurrentFunc.Return[0])
	}
	if is64 {
		code += compile64Type(a.ctx, ret.Value[0], "EDX:EAX", "return值存入EDX:EAX")
		a.ctx.Reg.Free(ret.Value[0])
		return code
	}

	eaxReg := a.ctx.Reg.FindByName("EAX")
	if eaxReg != nil {
		a.ctx.Reg.Force(eaxReg, ret.Value[0])

		if eaxReg.StoreCode != "" {
			code += utils.Format(eaxReg.StoreCode)
		}
	}

	code += a.exp(ret.Value[0], "EAX", "return值存入EAX")
	a.ctx.Reg.Free(ret.Value[0])
	return code
}

// returnJump 生成跳转到公共返回点的代码
func (a *x86Ops) returnJump() string {
	funcName := formatFuncName(a.ctx.CurrentFunc.Name.NASM(), len(a.ctx.CurrentFunc.Args))
	return utils.Format("jmp func_end_" + funcName + "; 跳转到公共返回点")
}

// exp 编译表达式（共享 ECompiler）
func (a *x86Ops) exp(exp *parser.Expression, result, desc string) string {
	if exp != nil && a.Is64Type(exp.Type) {
		return compile64Type(a.ctx, exp, result, desc)
	}
	expc := NewExpCom(a.ctx)
	return expc.CompileExpr(exp, result, desc)
}

// callArgsSize 计算参数总大小（用于 cdecl 调用者清理）
func callArgsSize(call *parser.CallBlock) int {
	argSize := 0
	for _, arg := range call.Args {
		if arg != nil && arg.Type != nil {
			argSize += arg.Type.Size()
		}
	}
	if call.ThisVar != nil {
		argSize += 4 // this 指针
	}
	return argSize
}
