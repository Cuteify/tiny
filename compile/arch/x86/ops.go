// Package x86 x86 架构共享实现（cdecl/stdcall 共用）。
package x86

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	exppkg "cuteify/compile/exp"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strconv"
	"strings"
)

// x86Ops 实现 x86 架构共用的 Arch 接口方法（寄存器/指令/地址等）。
// 通过内嵌到 Cdecl/Stdcall 复用。
type x86Ops struct {
	ctx     *context.Context
	condSeq int // 条件表达式内部标签序号（&& mid / || andFail，保证唯一）
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

// lo8 返回寄存器名的低8位寄存器名（setXX/movzx 需要）
func lo8(name string) string {
	switch strings.ToUpper(name) {
	case "EAX":
		return "al"
	case "EBX":
		return "bl"
	case "ECX":
		return "cl"
	case "EDX":
		return "dl"
	case "ESI":
		return "sil"
	case "EDI":
		return "dil"
	default:
		return "al"
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
	case "==", "!=", "<", ">", "<=", ">=":
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
	// Check if this is an interface assignment (boxing required)
	if _, isIface := varBlock.Type.(*typeSys.InterfaceType); isIface {
		return exppkg.New(a.ctx).BoxInterface(varBlock)
	}
	// 函数指针赋值：fn 值统一为闭包对象 {code, env}（间接调用 ABI）
	if _, isFuncPtr := varBlock.Type.(*typeSys.FuncType); isFuncPtr {
		varAddr := genVarAddr(a.ctx, varBlock)
		// 函数名直接赋值：堆分配 {code, env=0}
		if varBlock.Value != nil && varBlock.Value.Var != nil {
			if fb, ok := varBlock.Value.Var.Define.Value.(*parser.FuncBlock); ok && fb != nil {
				objCode := exppkg.New(a.ctx).EmitClosureObjectFor(fb, fb.Env, a.ctx.Arch.ReturnReg())
				return objCode + utils.Format("mov dword " + varAddr + ", " + a.ctx.Arch.ReturnReg() + "; 设置闭包对象地址" + varBlock.Name.String()) +
					"\n"
			}
			// 值是另一个 fn 变量：复制闭包对象指针
			if vt := varBlock.Value.Var.Type; vt != nil && vt.Kind() == "func" {
				addr := genVarAddr(a.ctx, varBlock.Value.Var)
				return utils.Format("mov dword " + varAddr + ", dword " + addr + "; 设置闭包对象地址" + varBlock.Name.String()) +
					"\n"
			}
		}
	}
	return exppkg.New(a.ctx).Assign(varBlock)
}

// VarAddr 变量地址
func (a *x86Ops) VarAddr(v *parser.VarBlock) string {
	return genVarAddr(a.ctx, v)
}

// MultiVarDecl 多返回值解构（a, b := foo()）- x86 版本
func (a *x86Ops) MultiVarDecl(varBlock *parser.VarBlock) string {
	if varBlock.Value == nil || len(varBlock.MultiNames) == 0 {
		return ""
	}

	// 编译函数调用，结果在 EAX（第一个返回值）和 EDX（第二个返回值）
	code := a.exp(varBlock.Value, "", "multi-return call")

	for i, name := range varBlock.MultiNames {
		offset := varBlock.MultiOffsets[i]
		addr := a.FormatAddr(offset)
		ln := a.LengthName(a.PointerSize())

		switch i {
		case 0:
			// 第一个返回值在 EAX
			code += utils.Format("mov " + addr + ", " + ln + " EAX; multi-return: " + name.First())
		case 1:
			// 第二个返回值在 EDX
			code += utils.Format("mov " + addr + ", " + ln + " EDX; multi-return: " + name.First())
		default:
			code += utils.Format("; TODO: third+ return value not yet supported")
		}
	}

	return code
}

// ForBegin 生成 for 循环起始代码
func (a *x86Ops) ForBegin(forBlock *parser.ForBlock) string {
	return a.ForBeginCond(forBlock, "", "")
}

// ForBeginCond 生成 for 循环起始代码，条件假/真路径分别跳转到指定标签。
// falseLabel/trueLabel 为空时使用默认 body 标签（兼容旧路径）。
func (a *x86Ops) ForBeginCond(forBlock *parser.ForBlock, falseLabel, trueLabel string) string {
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
		if falseLabel == "" && trueLabel == "" {
			// 条件真目标 = 循环体入口标签(|| 链任一叶真直接进体)
			bodyLabel := forLabel + "_body"
			code += a.compileCond(forBlock.Condition, forEndLabel, bodyLabel)
			code += utils.Format(bodyLabel + ":")
		} else {
			code += a.compileCond(forBlock.Condition, falseLabel, trueLabel)
		}
	}

	code += utils.Format("")
	code += utils.Format("")

	return code
}

// ForEnd 生成 for 循环结束代码。cleanup 在增量表达式之后、回边之前执行，
// 用于释放增量表达式里的临时对象。
func (a *x86Ops) ForEnd(forBlock *parser.ForBlock, cleanup string) string {
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
	code += cleanup
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
		code += utils.Format("jl " + trueLabel)
		code += utils.Format("jg " + jumpLabel)
		code += utils.Format("cmp eax, ebx")
		code += utils.Format("jge " + jumpLabel)
	case ">":
		code += utils.Format("jg " + trueLabel)
		code += utils.Format("jl " + jumpLabel)
		code += utils.Format("cmp eax, ebx")
		code += utils.Format("jle " + jumpLabel)
	case "<=":
		code += utils.Format("jl " + trueLabel)
		code += utils.Format("jg " + jumpLabel)
		code += utils.Format("cmp eax, ebx")
		code += utils.Format("jg " + jumpLabel)
	case ">=":
		code += utils.Format("jg " + trueLabel)
		code += utils.Format("jl " + jumpLabel)
		code += utils.Format("cmp eax, ebx")
		code += utils.Format("jl " + jumpLabel)
	}
	code += utils.Format(trueLabel + ":")
	return code
}

func (a *x86Ops) compileCond(cond *parser.Expression, jumpLabel string, trueLabel string) string {
	if cond == nil {
		return ""
	}

	scratchReg1 := "EAX"

	var code string

	switch cond.Separator {
	case "==", "!=", "<", ">", "<=", ">=":

		is64 := (cond.Left != nil && a.Is64Type(cond.Left.Type)) || (cond.Right != nil && a.Is64Type(cond.Right.Type))

		if is64 {
			// 32 位下 64 位比较沿用假向路径(compileCond64 无真向出口,不扩基线)
			code += a.compileCond64(cond, jumpLabel)
			break
		}

		code += a.emitCondCompare(cond)
		opFalse, _ := condJumpOps(cond)
		code += utils.Format(opFalse + " " + jumpLabel)
	case "||":
		// 或链:任一叶真 → trueLabel(循环体);末叶假 → jumpLabel(循环结束)
		code += a.compileOrChain(cond, trueLabel, jumpLabel, true)
	case "&&":
		// 左侧"真"仅代表还需评估右侧:左子链真目标落局部 mid,不能直跳 trueLabel
		if cond.Left != nil {
			mid := a.nextCondLabel("for_and_mid_")
			code += a.compileCond(cond.Left, jumpLabel, mid)
			code += utils.Format(mid + ":")
		}
		if cond.Right != nil {
			code += a.compileCond(cond.Right, jumpLabel, trueLabel)
		}
	default:
		code += a.exp(cond, scratchReg1, "condition")
		code += utils.Format("test " + scratchReg1 + ", " + scratchReg1)
		code += utils.Format("jz " + jumpLabel)
	}

	return code
}

// nextCondLabel 生成条件表达式内部唯一标签（前缀 + 单调序号）
func (a *x86Ops) nextCondLabel(prefix string) string {
	a.condSeq++
	return prefix + strconv.Itoa(a.condSeq)
}

// emitCondCompare 装载比较节点左右操作数并发射 cmp(不发跳转)
func (a *x86Ops) emitCondCompare(cond *parser.Expression) string {
	scratchReg1 := "EAX"
	scratchReg2 := "ECX"
	var code string

	if cond.Left != nil {
		code += a.exp(cond.Left, scratchReg1, "left operand")
	}
	if cond.Right != nil {
		code += a.exp(cond.Right, scratchReg2, "right operand")
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
func (a *x86Ops) compileOrChain(node *parser.Expression, trueLabel string, falseLabel string, isLast bool) string {
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
func (a *x86Ops) compileOrLeaf(term *parser.Expression, trueLabel string, falseLabel string, isLast bool) string {
	if term == nil {
		return ""
	}
	var code string
	switch term.Separator {
	case "==", "!=", "<", ">", "<=", ">=":
		if (term.Left != nil && a.Is64Type(term.Left.Type)) || (term.Right != nil && a.Is64Type(term.Right.Type)) {
			// 32 位下 64 位比较:沿用假向路径(不扩基线)
			return a.compileCond64(term, falseLabel)
		}
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
		scratchReg1 := "EAX"
		code += a.exp(term, scratchReg1, "||-chain leaf")
		code += utils.Format("test " + scratchReg1 + ", " + scratchReg1)
		code += utils.Format("jnz " + trueLabel)
		if isLast {
			code += utils.Format("jz " + falseLabel)
		}
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

// setArgsOffset 设置参数偏移（ebp+8 起，this 指针额外 +4；容器返回函数 [ebp+8] 为隐藏返回槽地址参数）
//
// [缺陷⑰②修复 2026-10-31] 参数表步长必须按「调用端 push 粒度」取整：
// x86 调用端对每个参数一律 push 4B dword（见 std_slices_clear__T__int 调
// memset(s,c,n) 的 push 序），callee 侧旧表却按 Type.Size() 逐字节游标——
// c:u8 参数 Size()=1，n:uint 槽表记 [ebp+13] 而调用端实参在 [ebp+16]，
// 3B 错读使 len=0x08000000，word 清零循环步进 33.5M×4B 走飞 SEGV（sprobe01
// 139 现场）。亚 4B 例型（i8/u8/bool/byte=1、i16/u16=2）一律按 4B 槽记账，
// u8 值落 dword 槽低字节、BYTE 读取不变；Size>4 容器按 ceil(size/4) 槽位数
// 走（u64=2 槽、string=12=3 槽，与调用端逐 dword 推序一致）。
// x64 无此错配：参数走寄存器传递、callee 自己按本表搬槽入栈，
// 调用端栈布局与参数表不耦合（见 arch/x86_64/ops.go setArgsOffset 槽位约定注释）。
func setArgsOffset(fn *parser.FuncBlock) {
	argOffset := 8
	if arch.FuncReturnsLarge(fn) {
		argOffset += 4
	}
	for i := 0; i < len(fn.Args); i++ {
		arg := fn.Args[i]
		// 隐藏 env 不在 Args 里（fn.EnvParam 只是 callee 口令）：可见参数
		// 从 ebp+8 起按 cdecl push 序逐 dword 槽排列，与普通函数一致，
		// callee 前序代码从 EBX 装 env 到自己的隐藏槽 [ebp-8]。
		arg.Offset = argOffset
		size := arg.Type.Size()
		if size > 4 {
			// 容器/多槽参数：按 4B 槽粒度对齐（与调用端逐 dword 推序一致）
			size = ((size + 3) / 4) * 4
		} else {
			// 亚 4B 标量：占满一个 push 槽（值在 dword 低字节）
			size = 4
		}
		argOffset += size
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
	// 隐藏 env 槽（闭包与具名嵌套函数）：[ebp-8] 专用槽。
	// EBX 是唯一 callee-save 寄存器（[ebp-4] 为 EBX 的保存位）——env 绝不
	// 覆盖它；可见参数不占此槽。局部变量游标统一后移 4B 至 [ebp-8] 起。
	if fn.EnvParam {
		code += utils.Format("mov DWORD [ebp-8], EBX; 保存闭包 env（隐藏槽）")
	}

	stackStart := -4 * len(csRegs)
	if fn.EnvParam {
		stackStart -= 4
	}
	a.ctx.StackSize = arch.SetupVarOffsets(a.ctx.Now, a.ctx.StackAlignment, stackStart)

	// 预留大值返回槽：容器 12B；结构体按槽数（Size/4）；+ 隐藏参数地址保存 4B
	retBytes := 12
	if arch.FuncReturnsLarge(fn) {
		retBytes = arch.ArgSlots(fn.Return[0]) * 4
	}
	a.ctx.RetSlot = -(a.ctx.StackSize) - retBytes - 4
	a.ctx.StackSize += retBytes + 4

	// 预留 ret 临时对象 scratch 槽（每个 4B，位于 RetSlot 之下）。
	scratchSlots := a.ctx.RetScratchCap
	if scratchSlots < 0 {
		scratchSlots = 0
	}
	if scratchSlots > 0 {
		scratchBytes := scratchSlots * 4
		a.ctx.RetScratchBase = -(a.ctx.StackSize) - scratchBytes
		a.ctx.StackSize += scratchBytes
	}

	if a.ctx.StackSize > 0 {
		code += utils.Format("sub esp, " + strconv.Itoa(a.ctx.StackSize) + "; 分配栈空间(" + strconv.Itoa(a.ctx.StackSize) + "字节)")
	}

	// scratch 槽清零：freeSlot 读到 0 会安全跳过。
	if scratchSlots > 0 {
		for i := 0; i < scratchSlots; i++ {
			code += utils.Format("mov DWORD [ebp" + strconv.Itoa(a.ctx.RetScratchBase+i*4) + "], 0; gc ret scratch 清零")
		}
	}

	// 大值返回函数：保存调用者传入的返回槽地址（[ebp+8] 隐藏参数）
	if arch.FuncReturnsLarge(fn) {
		code += utils.Format("mov EAX, DWORD [ebp+8]; 保存返回槽地址") +
			utils.Format("mov DWORD [ebp"+strconv.Itoa(a.ctx.RetSlot+retBytes)+"], EAX")
	}

	code += utils.Format("\n")
	return code
}

// epilogue 生成函数后序公共返回点
func (a *x86Ops) epilogue(fn *parser.FuncBlock, cleanup string, stdcallCleanup bool) string {
	funcName := formatFuncName(fn)
	code := utils.Format("func_end_" + funcName + ":")

	// 出口释放必须在标签之后、清栈之前；EAX 是返回值、EDX 可能承载
	// 64 位返回的高半部，释放调用会破坏它们，成对保存恢复（8 字节）。
	if cleanup != "" {
		code += utils.Format("push eax; 保存返回值")
		code += utils.Format("push edx; 保存返回值(高半部)")
		code += cleanup
		code += utils.Format("pop edx; 恢复返回值(高半部)")
		code += utils.Format("pop eax; 恢复返回值")
	}

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
	// 多返回值：将值放入 EAX 和 EDX
	if len(ret.Value) == 2 {
		// 第一个返回值放入 EAX
		code += a.exp(ret.Value[0], "EAX", "return值存入EAX")
		// 第二个返回值放入 EDX
		code += a.exp(ret.Value[1], "EDX", "return值存入EDX")
		return code
	}
	// 大值（容器 3 槽 / 结构体多槽）返回值：装载到本帧返回槽，再拷到隐藏参数（[ebp+8]）指向的调用者返回槽
	if ret.Value[0].Type != nil && arch.FuncReturnsLarge(a.ctx.CurrentFunc) {
		slots := arch.ArgSlots(ret.Value[0].Type)
		slot := "[ebp" + strconv.Itoa(a.ctx.RetSlot) + "]"
		code += exppkg.New(a.ctx).Compile(ret.Value[0], "DWORD"+slot, "return值存入返回槽")
		code += utils.Format("mov EDI, DWORD [ebp" + strconv.Itoa(a.ctx.RetSlot+slots*4) + "]; 恢复返回槽地址")
		for j := 0; j < slots; j++ {
			off := j * 4
			if off == 0 {
				code += utils.Format("mov EAX, DWORD " + slot)
				code += utils.Format("mov DWORD [EDI], EAX")
			} else {
				code += utils.Format("mov EAX, DWORD [ebp" + strconv.Itoa(a.ctx.RetSlot+off) + "]")
				code += utils.Format("mov DWORD [EDI+" + strconv.Itoa(off) + "], EAX")
			}
		}
		return code
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
	funcName := formatFuncName(a.ctx.CurrentFunc)
	return utils.Format("jmp func_end_" + funcName + "; 跳转到公共返回点")
}

// ReturnValue 导出返回值生成（不跳转），供 compiler 在 ret 临时释放前调用。
func (a *x86Ops) ReturnValue(ret *parser.ReturnBlock) string {
	return a.returnValue(ret)
}

// ReturnJump 导出公共返回点跳转，供 compiler 在 ret 临时释放后调用。
func (a *x86Ops) ReturnJump() string {
	return a.returnJump()
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
		if arg == nil || arg.Type == nil {
			continue
		}
		sz := arg.Type.Size()
		// 泛型函数调用：形参类型为 TypeParam（Size()=-1），
		// 用实参的实际类型大小替代
		if sz <= 0 && arg.Value != nil && arg.Value.Type != nil {
			sz = arg.Value.Type.Size()
		}
		if sz <= 0 {
			sz = 4 // 安全回退：32 位模式指针/int 默认 4 字节
		}
		// x86 cdecl 参数按 4 字节对齐压栈
		if sz < 4 {
			sz = 4
		}
		argSize += sz
	}
	// 变参参数：slice 结构 {ptr, len, cap} = 12 字节
	if call.IsVariadic {
		argSize += 12
	}
	// 函数指针间接调用不压 this 指针
	if call.ThisVar != nil && !(call.ThisVar.Type != nil && call.ThisVar.Type.Kind() == "func") {
		argSize += 4 // this 指针
	}
	return argSize
}
