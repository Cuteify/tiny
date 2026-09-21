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

// lo8 返回寄存器名的低8位寄存器名（setXX/movzx 需要）
func lo8(name string) string {
	switch strings.ToUpper(name) {
	case "EAX", "RAX":
		return "al"
	case "EBX", "RBX":
		return "bl"
	case "ECX", "RCX":
		return "cl"
	case "EDX", "RDX":
		return "dl"
	case "ESI", "RSI":
		return "sil"
	case "EDI", "RDI":
		return "dil"
	case "R8":
		return "r8b"
	case "R9":
		return "r9b"
	case "R10":
		return "r10b"
	case "R11":
		return "r11b"
	case "R12":
		return "r12b"
	case "R13":
		return "r13b"
	case "R14":
		return "r14b"
	case "R15":
		return "r15b"
	default:
		return "al"
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
			// nasm 不支持 imul 内存目标，经栈中转（保护 RAX：左子中间结果可能在其中）
			code := ""
			code += utils.Format("push RAX; 保护RAX(左子结果)")
			if strings.Contains(src, "[") {
				code += utils.Format("mov RAX, " + src)
				src = "RAX"
			}
			// x86_64 push 只接受 r64/m64，32-bit 寄存器需转换
			pushSrc := to64Reg(src)
			code += utils.Format("push " + pushSrc + "; 暂存乘数")
			// 从内存加载 dst 到 RAX，DWORD 用 eax 避免大小不匹配
			loadReg := "RAX"
			if strings.HasPrefix(dst, "DWORD") {
				loadReg = "eax"
			}
			code += utils.Format("mov " + loadReg + ", " + dst)
			code += utils.Format("imul RAX, qword [rsp]")
			// 根据 dst 大小选择正确的寄存器（DWORD→EAX, QWORD→RAX）
			storeReg := "RAX"
			if strings.HasPrefix(dst, "DWORD") {
				storeReg = "EAX"
			}
			code += utils.Format("mov " + dst + ", " + storeReg)
			code += utils.Format("add rsp, 8; 清理乘数")
			code += utils.Format("pop RAX; 恢复RAX(左子结果)")
			return code
		}
		return utils.Format("imul " + dst + ", " + src)
	case "/":
		// 除法必须经 RAX 中转（cqo/idiv），保护 RAX：左子中间结果可能在其中（dst==RAX 时无需保护）
		code := ""
		if strings.ToUpper(dst) != "RAX" {
			code += utils.Format("push RAX; 保护RAX(左子结果)")
		}
		// x86_64 push 只接受 r64/m64
		pushSrc := to64Reg(src)
		code += utils.Format("push " + pushSrc + "; 保存除数")
		// 从内存加载 dst 到 rax
		loadReg := "rax"
		if strings.HasPrefix(dst, "DWORD") {
			loadReg = "eax"
		}
		code += utils.Format("mov " + loadReg + ", " + dst)
		code += utils.Format("cqo")
		code += utils.Format("idiv qword [rsp]")
		code += utils.Format("add rsp, 8; 清理除数")
		// 根据 dst 大小选择正确的寄存器（DWORD→eax, QWORD→rax）
		storeReg := "rax"
		if strings.HasPrefix(dst, "DWORD") {
			storeReg = "eax"
		}
		code += utils.Format("mov " + dst + ", " + storeReg)
		if strings.ToUpper(dst) != "RAX" {
			code += utils.Format("pop RAX; 恢复RAX(左子结果)")
		}
		return code
	case "%":
		code := ""
		if strings.ToUpper(dst) != "RAX" {
			code += utils.Format("push RAX; 保护RAX(左子结果)")
		}
		pushSrc := to64Reg(src)
		code += utils.Format("push " + pushSrc + "; 保存除数")
		loadReg := "rax"
		if strings.HasPrefix(dst, "DWORD") {
			loadReg = "eax"
		}
		code += utils.Format("mov " + loadReg + ", " + dst)
		code += utils.Format("cqo")
		code += utils.Format("idiv qword [rsp]")
		code += utils.Format("add rsp, 8; 清理除数")
		// 取余结果在 RDX，根据 dst 大小选择正确的寄存器
		storeReg := "rdx"
		if strings.HasPrefix(dst, "DWORD") {
			storeReg = "edx"
		}
		code += utils.Format("mov " + dst + ", " + storeReg)
		if strings.ToUpper(dst) != "RAX" {
			code += utils.Format("pop RAX; 恢复RAX(左子结果)")
		}
		return code
	case "^":
		return utils.Format("xor " + dst + ", " + src)
	case "&":
		return utils.Format("and " + dst + ", " + src)
	case "|":
		return utils.Format("or " + dst + ", " + src)
	case "<<":
		if !utils.IsNumber(src) && strings.ToUpper(src) != "CL" && src != "cl" {
			// shift count 只能是 CL 或立即数，经栈中转低字节到 CL（保护 RAX：左子中间结果可能在其中，dst==RAX 时无需保护）
			code := ""
			if strings.ToUpper(dst) != "RAX" {
				code += utils.Format("push RAX; 保护RAX(左子结果)")
			}
			if strings.Contains(src, "[") {
				code += utils.Format("mov RAX, " + src)
				src = "RAX"
			}
			// x86_64: push 只接受 r64/m64，32 位寄存器需先扩展到64位
			pushSrc := to64Reg(src)
			code += utils.Format("push " + pushSrc + "; 暂存移位计数")
			code += utils.Format("mov cl, byte [rsp]")
			code += utils.Format("shl " + dst + ", cl")
			code += utils.Format("add rsp, 8; 清理移位计数")
			if strings.ToUpper(dst) != "RAX" {
				code += utils.Format("pop RAX; 恢复RAX(左子结果)")
			}
			return code
		}
		return utils.Format("shl " + dst + ", " + src)
	case ">>":
		if !utils.IsNumber(src) && strings.ToUpper(src) != "CL" && src != "cl" {
			code := ""
			if strings.ToUpper(dst) != "RAX" {
				code += utils.Format("push RAX; 保护RAX(左子结果)")
			}
			if strings.Contains(src, "[") {
				code += utils.Format("mov RAX, " + src)
				src = "RAX"
			}
			pushSrc := to64Reg(src)
			code += utils.Format("push " + pushSrc + "; 暂存移位计数")
			code += utils.Format("mov cl, byte [rsp]")
			code += utils.Format("sar " + dst + ", cl")
			code += utils.Format("add rsp, 8; 清理移位计数")
			if strings.ToUpper(dst) != "RAX" {
				code += utils.Format("pop RAX; 恢复RAX(左子结果)")
			}
			return code
		}
		return utils.Format("sar " + dst + ", " + src)
	case "==", "!=", "<", ">", "<=", ">=":
		// 比较运算：cmp + setXX + movzx 产生 0/1 整数值
		code := utils.Format("cmp " + dst + ", " + src)
		switch op {
		case "==":
			code += utils.Format("sete " + lo8(dst))
		case "!=":
			code += utils.Format("setne " + lo8(dst))
		case "<":
			code += utils.Format("setl " + lo8(dst))
		case ">":
			code += utils.Format("setg " + lo8(dst))
		case "<=":
			code += utils.Format("setle " + lo8(dst))
		case ">=":
			code += utils.Format("setge " + lo8(dst))
		}
		code += utils.Format("movzx " + dst + ", " + lo8(dst))
		return code
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
	// Check if this is an interface assignment (boxing required)
	if _, isIface := varBlock.Type.(*typeSys.InterfaceType); isIface {
		return exppkg.New(a.ctx).BoxInterface(varBlock)
	}
	// 函数指针赋值：将函数名地址存入变量
	if ft, isFuncPtr := varBlock.Type.(*typeSys.FuncType); isFuncPtr {
		if varBlock.Value.Var != nil && varBlock.Value.Var.Type != nil {
			addr := GenVarAddr(a.ctx, varBlock.Value.Var)
			varAddr := GenVarAddr(a.ctx, varBlock)
			return utils.Format("lea rax, " + addr + "; 函数指针地址\n") +
				utils.Format("mov QWORD " + varAddr + ", rax; 设置函数指针变量" + varBlock.Name.String())
		}
		if varBlock.Value.Var != nil {
			fnName := formatFuncNameRaw(varBlock.Value.Var.Name.NASM(), len(ft.Args))
			varAddr := GenVarAddr(a.ctx, varBlock)
			return utils.Format("mov QWORD " + varAddr + ", " + fnName + "; 设置函数指针变量" + varBlock.Name.String())
		}
	}
	return exppkg.New(a.ctx).Assign(varBlock)
}

// VarAddr 变量地址
func (a *x86_64Ops) VarAddr(v *parser.VarBlock) string {
	return GenVarAddr(a.ctx, v)
}

// MultiVarDecl 多返回值解构（a, b := foo()）
func (a *x86_64Ops) MultiVarDecl(varBlock *parser.VarBlock) string {
	if varBlock.Value == nil || len(varBlock.MultiNames) == 0 {
		return ""
	}

	// 编译函数调用，结果在 RAX（第一个返回值）和 RDX（第二个返回值）
	code := a.exp(varBlock.Value, "", "multi-return call")

	for i, name := range varBlock.MultiNames {
		offset := varBlock.MultiOffsets[i]
		addr := a.FormatAddr(offset)
		ln := a.LengthName(a.PointerSize())

		switch i {
		case 0:
			// 第一个返回值在 RAX
			code += utils.Format("mov " + addr + ", " + ln + " RAX; multi-return: " + name.First())
		case 1:
			// 第二个返回值在 RDX
			code += utils.Format("mov " + addr + ", " + ln + " RDX; multi-return: " + name.First())
		default:
			code += utils.Format("; TODO: third+ return value not yet supported")
		}
	}

	return code
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

// formatFuncName 生成汇编函数名（非 main 函数使用 MangledName）
func formatFuncName(fb *parser.FuncBlock) string {
	if fb.Name.NASM() == "main" {
		return "main"
	}
	return fb.MangledName()
}

// formatFuncNameRaw 为函数指针间接调用生成汇编函数名（无 FuncBlock 时使用旧 scheme）
func formatFuncNameRaw(name string, argsLen int) string {
	if name != "main" {
		name = name + strconv.Itoa(argsLen)
	}
	return name
}

// exp 编译表达式（共享 ECompiler）
func (a *x86_64Ops) exp(e *parser.Expression, result, desc string) string {
	return exppkg.New(a.ctx).Compile(e, result, desc)
}

// setArgsOffset 设置参数偏移（callee 栈帧内，rbp-48 起；如 C/Rust 保存到 callee 自己的局部变量区）
func setArgsOffset(fn *parser.FuncBlock) {
	// callee-saved regs 占 [rbp-8]..[rbp-40]，参数从 [rbp-48] 开始往下排
	argOffset := -48
	if fn.Class != nil {
		// this 指针占 [rbp-48]，参数从 [rbp-56] 开始
		argOffset = -56
	}
	for i := 0; i < len(fn.Args); i++ {
		arg := fn.Args[i]
		arg.Offset = argOffset
		argOffset -= arg.Type.Size()
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

	// 多返回值：将值放入 RAX 和 RDX
	if len(ret.Value) == 2 {
		// 第一个返回值放入 RAX
		code += a.exp(ret.Value[0], "RAX", "return值存入RAX")
		// 第二个返回值放入 RDX
		code += a.exp(ret.Value[1], "RDX", "return值存入RDX")
		return code
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
	funcName := formatFuncName(a.ctx.CurrentFunc)
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

		leftSavedReg := ""
		if cond.Left != nil {
			code += a.exp(cond.Left, scratchReg1, "left operand")
			// 用空闲 callee-save 寄存器保存左操作数（跨右子函数调用保持）。
			// 不能压栈：被调函数参数槽 [rbp+16]（=调用指令时的 rsp）落在调用者
			// 栈顶，会覆盖压栈保存的左操作数（如 load8(a) != load8(b) 这类左右都
			// 是函数调用时，右调用会覆盖左操作数的栈保存）。
			leftSavedReg = a.ctx.Reg.AllocCalleeSaveBind(cond.Left, a.CalleeSaveRegs(), a.CalleeSaveReg())
			if leftSavedReg != "" {
				code += utils.Format("mov " + leftSavedReg + ", " + scratchReg1 + "; 保存左操作数到callee-save")
			} else {
				code += utils.Format("push RAX; 保护左操作数\n")
			}
		}
		if cond.Right != nil {
			code += a.exp(cond.Right, scratchReg2, "right operand")
		}
		if cond.Left != nil {
			if leftSavedReg != "" {
				code += utils.Format("mov " + scratchReg1 + ", " + leftSavedReg + "; 恢复左操作数")
				a.ctx.Reg.Free(cond.Left)
			} else {
				code += utils.Format("pop RAX; 恢复左操作数\n")
			}
		}

		code += utils.Format("cmp " + scratchReg1 + ", " + scratchReg2)

		var jumpOp string
		isUnsigned := false
		if cond.Left != nil && cond.Left.Type != nil {
			isUnsigned = typeSys.CheckKind(cond.Left.Type, "uint")
		} else if cond.Right != nil && cond.Right.Type != nil {
			isUnsigned = typeSys.CheckKind(cond.Right.Type, "uint")
		}
		switch cond.Separator {
		case "==":
			jumpOp = "jne"
		case "!=":
			jumpOp = "je"
		case "<":
			if isUnsigned {
				jumpOp = "jnb"
			} else {
				jumpOp = "jge"
			}
		case ">":
			if isUnsigned {
				jumpOp = "jbe"
			} else {
				jumpOp = "jle"
			}
		case "<=":
			if isUnsigned {
				jumpOp = "jnbe"
			} else {
				jumpOp = "jg"
			}
		case ">=":
			if isUnsigned {
				jumpOp = "jb"
			} else {
				jumpOp = "jl"
			}
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

// to64Reg 将 32 位寄存器名转换为 64 位（如 EAX→RAX），用于 push 等需要64位操作数的场景
func to64Reg(reg string) string {
	upper := strings.ToUpper(reg)
	regMap := map[string]string{
		"EAX": "RAX", "EBX": "RBX", "ECX": "RCX", "EDX": "RDX",
		"ESI": "RSI", "EDI": "RDI", "EBP": "RBP", "ESP": "RSP",
		"R8D": "R8", "R9D": "R9", "R10D": "R10", "R11D": "R11",
		"R12D": "R12", "R13D": "R13", "R14D": "R14", "R15D": "R15",
	}
	if mapped, ok := regMap[upper]; ok {
		return mapped
	}
	return reg
}
