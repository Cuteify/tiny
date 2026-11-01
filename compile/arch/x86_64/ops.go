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
	condSeq        int // 条件表达式内部标签序号（&& mid / || andFail，保证唯一）
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

// shiftRspOperand 对操作数文本中的 rsp 相对寻址补偿 delta 字节（第六根因修复）。
// InstBinary 的 push 惯用法（保护 RAX / 暂存乘除数 / 暂存移位计数）会平移 rsp，
// 而调用参数 buffer 槽 "[rsp+N]" 是 rsp 相对地址 —— push 窗口内按原文本读写会
// 错位到相邻槽（实证：power(2,10) even 路径的 idiv 商写进 buf[0] 把 base 覆成 0，
// (rdi=0, rsi=10) 无限递归 8MB 栈耗尽 SIGSEGV，见 docs/fixplan/PROBLEMS.md）。
// 仅当寻址形式为 [rsp] / [rsp+N] / [rsp-N]（可带 QWORD/DWORD 宽度前缀）时改写偏移；
// 寄存器与 rbp 相对寻址原样返回。delta = 该次发射时已 outstanding 的 push 字节数
// （只统计本窗口自己的 push；不用 R10/R11 作暂存 —— 它们在 regmgr 分配池内且
// vtable 调度占用 R11，裸用会踩活寄存器）。
func shiftRspOperand(operand string, delta int) string {
	if delta == 0 {
		return operand
	}
	lo := strings.Index(operand, "[rsp")
	if lo < 0 {
		return operand
	}
	rel := operand[lo+1:]
	end := strings.Index(rel, "]")
	if end < 0 {
		return operand
	}
	inner := rel[:end] // "rsp+8" / "rsp-8" / "rsp"
	if !strings.HasPrefix(inner, "rsp") {
		return operand
	}
	rest := rel[end+1:]
	tail := inner[3:]
	off := 0
	if tail != "" {
		v, err := strconv.ParseInt(tail, 10, 64) // 十进制（"[rsp+8]" 由 strconv.Itoa 生成）
		if err != nil {
			return operand
		}
		off = int(v)
	}
	off += delta
	var body string
	switch {
	case off > 0:
		body = "rsp+" + strconv.Itoa(off)
	case off < 0:
		body = "rsp" + strconv.Itoa(off)
	default:
		body = "rsp"
	}
	return operand[:lo+1] + body + "]" + rest
}

// InstBinary 生成二元运算指令。
// 除法/取模通过 push 除数到栈上避免寄存器冲突（RAX/RDX 被 cqo 占用）。
// push 窗口内的 rsp 相对寻址一律经 shiftRspOperand 补偿（第六根因修复）。
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
			delta := 8 // protect push 已 outstanding
			if strings.Contains(src, "[") {
				code += utils.Format("mov RAX, " + shiftRspOperand(src, delta))
				src = "RAX"
			}
			// x86_64 push 只接受 r64/m64，32-bit 寄存器需转换
			pushSrc := to64Reg(src)
			code += utils.Format("push " + shiftRspOperand(pushSrc, delta) + "; 暂存乘数")
			delta = 16 // protect + 乘数 两个 push 都 outstanding
			// 从内存加载 dst 到 RAX，DWORD 用 eax 避免大小不匹配
			loadReg := "RAX"
			if strings.HasPrefix(dst, "DWORD") {
				loadReg = "eax"
			}
			code += utils.Format("mov " + loadReg + ", " + shiftRspOperand(dst, delta))
			code += utils.Format("imul RAX, qword [rsp]")
			// 根据 dst 大小选择正确的寄存器（DWORD→EAX, QWORD→RAX）
			storeReg := "RAX"
			if strings.HasPrefix(dst, "DWORD") {
				storeReg = "EAX"
			}
			code += utils.Format("mov " + shiftRspOperand(dst, delta) + ", " + storeReg)
			code += utils.Format("add rsp, 8; 清理乘数")
			code += utils.Format("pop RAX; 恢复RAX(左子结果)")
			return code
		}
		return utils.Format("imul " + dst + ", " + src)
	case "/":
		// 除法必须经 RAX 中转（cqo/idiv），保护 RAX：左子中间结果可能在其中（dst==RAX 时无需保护）
		code := ""
		delta := 0
		if strings.ToUpper(dst) != "RAX" {
			code += utils.Format("push RAX; 保护RAX(左子结果)")
			delta = 8
		}
		// x86_64 push 只接受 r64/m64
		pushSrc := to64Reg(src)
		code += utils.Format("push " + shiftRspOperand(pushSrc, delta) + "; 保存除数")
		delta += 8
		// 从内存加载 dst 到 rax
		loadReg := "rax"
		if strings.HasPrefix(dst, "DWORD") {
			loadReg = "eax"
		}
		code += utils.Format("mov " + loadReg + ", " + shiftRspOperand(dst, delta))
		code += utils.Format("cqo")
		code += utils.Format("idiv qword [rsp]")
		code += utils.Format("add rsp, 8; 清理除数")
		delta -= 8
		// 根据 dst 大小选择正确的寄存器（DWORD→eax, QWORD→rax）
		storeReg := "rax"
		if strings.HasPrefix(dst, "DWORD") {
			storeReg = "eax"
		}
		code += utils.Format("mov " + shiftRspOperand(dst, delta) + ", " + storeReg)
		if strings.ToUpper(dst) != "RAX" {
			code += utils.Format("pop RAX; 恢复RAX(左子结果)")
		}
		return code
	case "%":
		code := ""
		delta := 0
		if strings.ToUpper(dst) != "RAX" {
			code += utils.Format("push RAX; 保护RAX(左子结果)")
			delta = 8
		}
		pushSrc := to64Reg(src)
		code += utils.Format("push " + shiftRspOperand(pushSrc, delta) + "; 保存除数")
		delta += 8
		loadReg := "rax"
		if strings.HasPrefix(dst, "DWORD") {
			loadReg = "eax"
		}
		code += utils.Format("mov " + loadReg + ", " + shiftRspOperand(dst, delta))
		code += utils.Format("cqo")
		code += utils.Format("idiv qword [rsp]")
		code += utils.Format("add rsp, 8; 清理除数")
		delta -= 8
		// 取余结果在 RDX，根据 dst 大小选择正确的寄存器
		storeReg := "rdx"
		if strings.HasPrefix(dst, "DWORD") {
			storeReg = "edx"
		}
		code += utils.Format("mov " + shiftRspOperand(dst, delta) + ", " + storeReg)
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
			// 第六根因修复：与 / % 同型 —— push 窗口内 shl 的 rsp 相对 dst 需补偿
			code := ""
			delta := 0
			if strings.ToUpper(dst) != "RAX" {
				code += utils.Format("push RAX; 保护RAX(左子结果)")
				delta = 8
			}
			if strings.Contains(src, "[") {
				code += utils.Format("mov RAX, " + shiftRspOperand(src, delta))
				src = "RAX"
			}
			// x86_64: push 只接受 r64/m64，32 位寄存器需先扩展到64位
			pushSrc := to64Reg(src)
			code += utils.Format("push " + shiftRspOperand(pushSrc, delta) + "; 暂存移位计数")
			delta += 8
			code += utils.Format("mov cl, byte [rsp]")
			code += utils.Format("shl " + shiftRspOperand(dst, delta) + ", cl")
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
			delta := 0
			if strings.ToUpper(dst) != "RAX" {
				code += utils.Format("push RAX; 保护RAX(左子结果)")
				delta = 8
			}
			if strings.Contains(src, "[") {
				code += utils.Format("mov RAX, " + shiftRspOperand(src, delta))
				src = "RAX"
			}
			pushSrc := to64Reg(src)
			code += utils.Format("push " + shiftRspOperand(pushSrc, delta) + "; 暂存移位计数")
			delta += 8
			code += utils.Format("mov cl, byte [rsp]")
			code += utils.Format("sar " + shiftRspOperand(dst, delta) + ", cl")
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
		if strings.Contains(dst, "[") {
			// movzx 目的操作数只能是寄存器：内存目标经零扩展后以同宽度写回
			// （lo8(dst) 对内存目标回落为 al，故 setXX 落在 RAX 低字节）
			switch {
			case strings.HasPrefix(dst, "BYTE"):
				// sete 后 al 即 0/1 值低字节，直接同宽存回
				code += utils.Format("mov " + dst + ", al")
			case strings.HasPrefix(dst, "WORD"):
				code += utils.Format("movzx RAX, al")
				code += utils.Format("mov " + dst + ", ax")
			case strings.HasPrefix(dst, "DWORD"):
				code += utils.Format("movzx EAX, al")
				code += utils.Format("mov " + dst + ", EAX")
			default:
				code += utils.Format("movzx RAX, al")
				code += utils.Format("mov " + dst + ", RAX")
			}
			return code
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
		// 条件真目标 = 循环体入口标签(|| 链任一叶真直接进体)
		bodyLabel := forLabel + "_body"
		code += a.compileCond(forBlock.Condition, forEndLabel, bodyLabel)
		code += utils.Format(bodyLabel + ":")
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
//
// 槽位约定（第五根因修复，见 docs/fixplan/PROBLEMS.md）：
// 偏移一律"从高向低"预留；参数槽向下生长（param0 最高，paramN 最低）。
// 容器参数（string/大结构体，Size>8）占用 size 字节的完整条带，字段在条带内
// 向上展开：arg.Offset = 条带最低槽，j 号字段地址 = Offset+j*8。
// 旧实现直接把条带顶当作 Offset，容器字段向上翻越，覆写前序参数槽
// （string 当参数时 len/cap 两个字段踩进前两个参数槽，甚至踩入 callee-save 区
// [rbp-40/-32]）——string 转值参数的函数系统性读写错位（console.println 的
// len 错误即源于此）。
func setArgsOffset(fn *parser.FuncBlock) {
	// callee-saved regs 占 [rbp-8]..[rbp-40]，参数从 [rbp-48] 开始往下排
	argOffset := -48
	if fn.Class != nil {
		// this 指针占 [rbp-48]，参数从 [rbp-56] 开始
		argOffset = -56
	}
	for i := 0; i < len(fn.Args); i++ {
		arg := fn.Args[i]
		size := arg.Type.Size()
		slots := (size + 7) / 8
		if slots > 1 {
			// 容器参数：Offset=条带最低槽，字段向上展开（与 Prologue 存参环、
			// 栈参数搬移、Call 端 buffer 路径的 j 号字段序一致）
			arg.Offset = argOffset - (slots*8 - 8)
			argOffset -= slots * 8
		} else {
			// 标量/窄类型：Offset 即其唯一槽。
			// 窄类型（u8/bool/u16/i32 等 Size<8）也按满 8 字节步进预约槽带：
			// 病灶⑬（2026-11-01 memset 实锤）——旧实现 `argOffset -= size` 让
			// 后序 8 字节参数的条带从窄槽正下方紧贴起步，其 [Offset,Offset+8)
			// 跨度回吞窄槽的原字节位。memset(s:ptr, c:u8, n:uint) 即实战撞点：
			// c 槽(-56) 落入 n 条带(-57..-50)，存 n=384=0x180 时 c 被篡改为
			// n 的 byte[1]=0x01 → Prologue 存参环后 c==0 判据失真，快路径
			// 被绕过、逐字节慢路径把 0x01 写满全块（maps slots 全 01，
			// mp/mp_map 139 现象的第二个独立根因）。存参环用 GetLenName(size)
			// 只写窄宽低字节，槽带的空余字节天然无害（读方按类型宽度读同一低字节）。
			arg.Offset = argOffset
			argOffset -= 8
		}
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
// jumpLabel = 假目标;trueLabel = 真目标(|| 链任一叶真即跳此)
func (a *x86_64Ops) compileCond(cond *parser.Expression, jumpLabel string, trueLabel string) string {
	if cond == nil {
		return ""
	}

	scratchReg1 := "RAX"

	var code string

	if cond.Separator == "==" || cond.Separator == "!=" ||
		cond.Separator == "<" || cond.Separator == ">" ||
		cond.Separator == "<=" || cond.Separator == ">=" {

		code += a.emitCondCompare(cond)
		opFalse, _ := condJumpOps(cond)
		code += utils.Format(opFalse + " " + jumpLabel)
	} else if cond.Separator == "||" {
		// 或链:任一叶真 → trueLabel(循环体);末叶假 → jumpLabel(循环结束)
		code += a.compileOrChain(cond, trueLabel, jumpLabel, true)
	} else if cond.Separator == "&&" {
		// 左侧"真"仅代表还需评估右侧:左子链真目标落局部 mid,不能直跳 trueLabel
		if cond.Left != nil {
			mid := a.nextCondLabel("for_and_mid_")
			code += a.compileCond(cond.Left, jumpLabel, mid)
			code += utils.Format(mid + ":")
		}
		if cond.Right != nil {
			code += a.compileCond(cond.Right, jumpLabel, trueLabel)
		}
	} else {
		code += a.exp(cond, scratchReg1, "condition")
		code += utils.Format("test " + scratchReg1 + ", " + scratchReg1)
		code += utils.Format("jz " + jumpLabel)
	}

	return code
}

// nextCondLabel 生成条件表达式内部唯一标签（前缀 + 单调序号）
func (a *x86_64Ops) nextCondLabel(prefix string) string {
	a.condSeq++
	return prefix + strconv.Itoa(a.condSeq)
}

// emitCondCompare 装载比较节点左右操作数并发射 cmp(不发跳转)
func (a *x86_64Ops) emitCondCompare(cond *parser.Expression) string {
	scratchReg1 := "RAX"
	scratchReg2 := "RCX"
	var code string

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
	return code
}

// condJumpOps 计算比较节点双向跳转助记:opFalse(假向)/opTrue(真向,|| 链用)
func condJumpOps(cond *parser.Expression) (string, string) {
	isUnsigned := false
	if cond.Left != nil && cond.Left.Type != nil {
		isUnsigned = typeSys.CheckKind(cond.Left.Type, "uint")
	} else if cond.Right != nil && cond.Right.Type != nil {
		isUnsigned = typeSys.CheckKind(cond.Right.Type, "uint")
	}
	switch cond.Separator {
	case "==":
		return "jne", "je"
	case "!=":
		return "je", "jne"
	case "<":
		if isUnsigned {
			return "jnb", "jb"
		}
		return "jge", "jl"
	case ">":
		if isUnsigned {
			return "jbe", "ja"
		}
		return "jle", "jg"
	case "<=":
		if isUnsigned {
			return "jnbe", "jbe"
		}
		return "jg", "jle"
	case ">=":
		if isUnsigned {
			return "jb", "jae"
		}
		return "jl", "jge"
	}
	return "jne", "je"
}

// compileOrChain 摊平 || 链(左结合,任一侧是 || 均下钻):
// 每叶为真即跳 trueLabel;非末叶假直接落下一叶;末叶假补跳 falseLabel
func (a *x86_64Ops) compileOrChain(node *parser.Expression, trueLabel string, falseLabel string, isLast bool) string {
	if node == nil {
		return ""
	}
	var code string
	if node.Left != nil && node.Left.Separator == "||" {
		code += a.compileOrChain(node.Left, trueLabel, falseLabel, false)
	} else if node.Left != nil {
		code += a.compileOrLeaf(node.Left, trueLabel, falseLabel, false)
	}
	if node.Right != nil && node.Right.Separator == "||" {
		code += a.compileOrChain(node.Right, trueLabel, falseLabel, isLast)
	} else if node.Right != nil {
		code += a.compileOrLeaf(node.Right, trueLabel, falseLabel, isLast)
	}
	return code
}

// compileOrLeaf 发射 || 链单个叶子:比较叶真向跳;算式叶 Exp+test;
// && 子叶经 compileCond 递归(全真→跳 trueLabel)
func (a *x86_64Ops) compileOrLeaf(term *parser.Expression, trueLabel string, falseLabel string, isLast bool) string {
	if term == nil {
		return ""
	}
	var code string
	switch term.Separator {
	case "==", "!=", "<", ">", "<=", ">=":
		_, opTrue := condJumpOps(term)
		code += a.emitCondCompare(term)
		code += utils.Format(opTrue + " " + trueLabel)
		if isLast {
			opFalse, _ := condJumpOps(term)
			code += utils.Format(opFalse + " " + falseLabel)
		}
	case "&&":
		andFail := a.nextCondLabel("for_or_and_")
		code += a.compileCond(term, andFail, trueLabel)
		code += utils.Format("jmp " + trueLabel)
		code += utils.Format(andFail + ":")
		if isLast {
			// 到达 andFail 即 && 整体为假,无条件跳假目标(不依赖标志位)
			code += utils.Format("jmp " + falseLabel)
		}
	default:
		scratchReg1 := "RAX"
		code += a.exp(term, scratchReg1, "||-chain leaf")
		code += utils.Format("test " + scratchReg1 + ", " + scratchReg1)
		code += utils.Format("jnz " + trueLabel)
		if isLast {
			code += utils.Format("jz " + falseLabel)
		}
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
