// Package x86_64 x86_64 架构共享实现（SysV/Win64 共用）。
package x86_64

import (
	"strings"
	"cuteify/compile/arch"
	"cuteify/compile/context"
	exppkg "cuteify/compile/exp"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strconv"
)

// x86_64Ops 实现 x86_64 架构共用的 Arch 接口方法（寄存器/指令/地址等）。
// calleeSaveList 由具体 ABI 构造时设置（SysV: RBX/R12-R15；Win64: RDI/RSI/RBX/R12-R15）。
type x86_64Ops struct {
	ctx            *context.Context
	calleeSaveList []string
}

func newOps(ctx *context.Context, calleeSaveList []string) *x86_64Ops {
	return &x86_64Ops{ctx: ctx, calleeSaveList: calleeSaveList}
}

// ---- 寄存器信息 ----

func (a *x86_64Ops) ReturnReg() string { return "RAX" }
func (a *x86_64Ops) HiReg() string     { return "RDX" }

func (a *x86_64Ops) CalleeSaveReg() string {
	if len(a.calleeSaveList) > 0 {
		// 返回一个适合保存中间值的 callee-save 寄存器（RBX）
		for _, name := range a.calleeSaveList {
			if name == "RBX" {
				return name
			}
		}
		return a.calleeSaveList[0]
	}
	return "RBX"
}

func (a *x86_64Ops) CalleeSaveRegs() []string { return a.calleeSaveList }

func (a *x86_64Ops) IsCalleeSave(name string) bool {
	for _, n := range a.calleeSaveList {
		if n == name {
			return true
		}
	}
	return false
}

func (a *x86_64Ops) DefaultRegMask() uint32 { return ClassGPR }

func (a *x86_64Ops) NeedRegClass(bt typeSys.BackendType) uint32 { return ClassGPR }

func (a *x86_64Ops) NeedBindMask(op string) uint32 {
	switch op {
	case "/", "%":
		return ClassDiv // 除法/取模需要 RAX/RDX
	default:
		return 0
	}
}

func (a *x86_64Ops) NeedBindRegs(op string) []*regmgr.Reg {
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

// ---- 栈与地址 ----

func (a *x86_64Ops) FramePtr() string { return "RBP" }
func (a *x86_64Ops) StackPtr() string { return "RSP" }

func (a *x86_64Ops) PointerSize() int   { return 8 }
func (a *x86_64Ops) PushSize() int      { return 8 }
func (a *x86_64Ops) SizePrefix() string { return "QWORD" }

func (a *x86_64Ops) LengthName(sz int) string { return GetLenName(sz) }

func (a *x86_64Ops) FormatAddr(offset int) string {
	return MakeRbpAddr(offset)
}

func (a *x86_64Ops) ExtractOffset(addr string) (int, bool) {
	return GetRbpOffset(addr)
}

// ---- 指令 ----

func (a *x86_64Ops) Cmp(dst, src string) string {
	return utils.Format("cmp " + dst + ", " + src)
}

// Jump 生成比较跳转：当条件不成立时跳转到目标标签
func (a *x86_64Ops) Jump(typ, dst, src string) string {
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

func (a *x86_64Ops) InstMov(dst, src string) string {
	return utils.Format("mov " + dst + ", " + src)
}

func (a *x86_64Ops) InstPush(val string) string {
	return utils.Format("push " + val)
}

func (a *x86_64Ops) InstPop(addr string) string {
	return utils.Format("pop " + addr)
}

func (a *x86_64Ops) InstUnary(op, reg string) string {
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
// 除法/取模通过 push 除数到栈上避免寄存器冲突（RAX/RDX 被 cqo 占用）。
func (a *x86_64Ops) InstBinary(dst, op, src string) string {
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
				code += utils.Format("mov RAX, " + src)
				src = "RAX"
			}
			code += utils.Format("push " + src + "; 暂存乘数")
			code += utils.Format("mov RAX, " + dst)
			code += utils.Format("imul RAX, qword [rsp]")
			code += utils.Format("mov " + dst + ", RAX")
			code += utils.Format("add rsp, 8; 清理乘数")
			return code
		}
		return utils.Format("imul " + dst + ", " + src)
	case "/":
		code := utils.Format("push " + src + "; 保存除数")
		code += utils.Format("mov rax, " + dst)
		code += utils.Format("cqo")
		code += utils.Format("idiv qword [rsp]")
		code += utils.Format("add rsp, 8; 清理除数")
		code += utils.Format("mov " + dst + ", rax")
		return code
	case "%":
		code := utils.Format("push " + src + "; 保存除数")
		code += utils.Format("mov rax, " + dst)
		code += utils.Format("cqo")
		code += utils.Format("idiv qword [rsp]")
		code += utils.Format("add rsp, 8; 清理除数")
		code += utils.Format("mov " + dst + ", rdx")
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
				code += utils.Format("mov RAX, " + src)
				src = "RAX"
			}
			code += utils.Format("push " + src + "; 暂存移位计数")
			code += utils.Format("mov cl, byte [rsp]")
			code += utils.Format("shl " + dst + ", cl")
			code += utils.Format("add rsp, 8; 清理移位计数")
			return code
		}
		return utils.Format("shl " + dst + ", " + src)
	case ">>":
		if !utils.IsNumber(src) && strings.ToUpper(src) != "CL" && src != "cl" {
			code := ""
			if strings.Contains(src, "[") {
				code += utils.Format("mov RAX, " + src)
				src = "RAX"
			}
			code += utils.Format("push " + src + "; 暂存移位计数")
			code += utils.Format("mov cl, byte [rsp]")
			code += utils.Format("sar " + dst + ", cl")
			code += utils.Format("add rsp, 8; 清理移位计数")
			return code
		}
		return utils.Format("sar " + dst + ", " + src)
	default:
		return ""
	}
}

// ---- 数据类型 ----

// Is64Type x86_64 上所有整数都在单个寄存器中，无需特殊的 64 位拆分
func (a *x86_64Ops) Is64Type(t typeSys.Type) bool { return false }

// Compare64 x86_64 单寄存器（RAX）比较已由 compileCondition 正确处理，无需专用路径
func (a *x86_64Ops) Compare64(cond *parser.Expression, jumpLabel string) string { return "" }

func (a *x86_64Ops) Compile64Type(e *parser.Expression, result, desc string) string {
	return a.exp(e, result, desc)
}

// ---- 变量与循环 ----

// VarDecl 变量声明/赋值
func (a *x86_64Ops) VarDecl(varBlock *parser.VarBlock) string {
	if varBlock.Value == nil {
		return exppkg.New(a.ctx).ZeroVar(varBlock)
	}
	return exppkg.New(a.ctx).Assign(varBlock)
}

// VarAddr 变量地址
func (a *x86_64Ops) VarAddr(v *parser.VarBlock) string {
	return GenVarAddr(a.ctx, v)
}

// ForBegin 生成 for 循环起始代码
func (a *x86_64Ops) ForBegin(forBlock *parser.ForBlock) string {
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
func (a *x86_64Ops) ForEnd(forBlock *parser.ForBlock) string {
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

// ---- 程序入口 ----

func (a *x86_64Ops) GenerateStartEntry() string {
	var code string
	code += utils.Format("; ==============================")
	code += utils.Format("; 程序入口点 (ELF入口)")
	code += utils.Format("_start:")
	utils.Count++
	code += utils.Format("call main")
	code += utils.Format("mov rdi, rax")
	code += utils.Format("mov rax, 60")
	code += utils.Format("syscall\n")
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

// exp 编译表达式（共享 ECompiler）
func (a *x86_64Ops) exp(e *parser.Expression, result, desc string) string {
	return exppkg.New(a.ctx).Compile(e, result, desc)
}

// setArgsOffset 设置参数偏移（rbp+16 起；方法首个参数从 rbp+24 起，rbp+16 被 this 占用）
func setArgsOffset(fn *parser.FuncBlock) {
	argOffset := 16
	if fn.Class != nil {
		argOffset = 24
	}
	for i := 0; i < len(fn.Args); i++ {
		arg := fn.Args[i]
		arg.Offset = argOffset
		argOffset += arg.Type.Size()
	}
}

// varDecl 变量声明/赋值
func (a *x86_64Ops) varDecl(varBlock *parser.VarBlock) string {
	if varBlock.Value == nil {
		return exppkg.New(a.ctx).ZeroVar(varBlock)
	}
	return exppkg.New(a.ctx).Assign(varBlock)
}

// returnValue 生成返回值代码（RAX）
func (a *x86_64Ops) returnValue(ret *parser.ReturnBlock) (code string) {
	if ret == nil || len(ret.Value) == 0 {
		return ""
	}

	// 大值（容器 3 槽 / 结构体多槽）返回值：装载到本帧返回槽，再拷到 R10 指向的调用者返回槽
	if ret.Value[0].Type != nil && arch.FuncReturnsLarge(a.ctx.CurrentFunc) {
		slots := arch.ArgSlots(ret.Value[0].Type)
		slot := "[rbp" + strconv.Itoa(a.ctx.RetSlot) + "]"
		code += exppkg.New(a.ctx).Compile(ret.Value[0], "QWORD"+slot, "return值存入返回槽")
		code += utils.Format("mov R10, QWORD [rbp" + strconv.Itoa(a.ctx.RetSlot+slots*8) + "]; 恢复返回槽地址")
		for j := 0; j < slots; j++ {
			off := j * 8
			if off == 0 {
				code += utils.Format("mov RAX, QWORD " + slot)
			} else {
				code += utils.Format("mov RAX, QWORD [rbp" + strconv.Itoa(a.ctx.RetSlot+off) + "]")
			}
			if j == 0 {
				code += utils.Format("mov QWORD [R10], RAX")
			} else {
				code += utils.Format("mov QWORD [R10+" + strconv.Itoa(off) + "], RAX")
			}
		}
		return code
	}

	raxReg := a.ctx.Reg.FindByName("RAX")
	if raxReg != nil {
		a.ctx.Reg.Force(raxReg, ret.Value[0])

		if raxReg.StoreCode != "" {
			code += utils.Format(raxReg.StoreCode)
		}
	}

	code += a.exp(ret.Value[0], "RAX", "return值存入RAX")
	a.ctx.Reg.Free(ret.Value[0])
	return code
}

// returnJump 生成跳转到公共返回点的代码
func (a *x86_64Ops) returnJump() string {
	funcName := formatFuncName(a.ctx.CurrentFunc.Name.NASM(), len(a.ctx.CurrentFunc.Args))
	return utils.Format("jmp func_end_" + funcName)
}

// compileCond 编译条件表达式，生成比较和跳转指令（与 compiler.compileCondition 逻辑一致）
func (a *x86_64Ops) compileCond(cond *parser.Expression, jumpLabel string) string {
	if cond == nil {
		return ""
	}

	scratchReg1 := "RAX"
	scratchReg2 := "RCX"

	var code string

	if cond.Separator == "==" || cond.Separator == "!=" ||
		cond.Separator == "<" || cond.Separator == ">" ||
		cond.Separator == "<=" || cond.Separator == ">=" {

		if cond.Left != nil {
			code += a.exp(cond.Left, scratchReg1, "left operand")
			code += utils.Format("push RAX; 保护左操作数\n")
		}
		if cond.Right != nil {
			code += a.exp(cond.Right, scratchReg2, "right operand")
		}
		if cond.Left != nil {
			code += utils.Format("pop RAX; 恢复左操作数\n")
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
	} else if cond.Separator == "&&" || cond.Separator == "||" {
		if cond.Left != nil {
			code += a.compileCond(cond.Left, jumpLabel)
		}
		if cond.Right != nil {
			code += a.compileCond(cond.Right, jumpLabel)
		}
	} else {
		code += a.exp(cond, scratchReg1, "condition")
		code += utils.Format("test " + scratchReg1 + ", " + scratchReg1)
		code += utils.Format("jz " + jumpLabel)
	}

	return code
}
