// Package x86 x86 架构表达式编译，使用共享表达式编译器 + 架构适配。
package x86

import (
	"cuteify/compile/context"
	"cuteify/compile/exp"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strconv"
	"strings"
)

// ExpCom x86 表达式编译器
type ExpCom struct {
	ctx *context.Context
	ec  *exp.ECompiler
}

func NewExpCom(ctx *context.Context) *ExpCom {
	return &ExpCom{ctx: ctx, ec: exp.New(ctx)}
}

func (c *ExpCom) CompileExpr(e *parser.Expression, result, desc string) string {
	return c.ec.Compile(e, result, desc)
}
func (c *ExpCom) CompileExprChildren(e *parser.Expression) (string, *regmgr.Reg) {
	return "", nil // TODO: implement if needed
}
func (c *ExpCom) CompileBoolExpr(e *parser.Expression, result string) string {
	return "" // TODO: implement if needed
}
func (c *ExpCom) CompileExprVal(e *parser.Expression) (string, string) {
	return "", "" // TODO: implement if needed
}

// ---- x86 特有：64 位类型处理 ----

// splitConst64 将 float64 常量拆成低 32 位、高 32 位两个十进制字符串
func splitConst64(num float64) (string, string) {
	u := uint64(num)
	return strconv.FormatUint(uint64(uint32(u)), 10), strconv.FormatUint(u>>32, 10)
}

func Is64Type(t typeSys.Type) bool {
	if t == nil {
		return false
	}
	return t.Size() == 8 && (t.Type() == "i64" || t.Type() == "u64" || t.Type() == "f64")
}

func compile64Type(ctx *context.Context, e *parser.Expression, result, desc string) (code string) {
	if e.IsConst() && typeSys.CheckKind(e.Type, "int", "uint", "i64", "u64") {
		lo, hi := splitConst64(e.Num)
		if result == "push" {
			code += utils.Format("push " + hi + "; high 32bit " + desc)
			code += utils.Format("push " + lo + "; low 32bit " + desc)
		} else if isRegPair(result) {
			code += utils.Format("mov eax, " + lo + "; " + desc)
			code += utils.Format("mov edx, " + hi)
		} else if isRegName(result) {
			// 单寄存器结果：值 = 寄存器(低):EDX(高)
			code += utils.Format("mov " + result + ", " + lo + "; " + desc)
			if result != "edx" {
				code += utils.Format("mov edx, " + hi)
			}
		} else {
			loAddr := result
			hiAddr := makeHiAddr(result)
			code += utils.Format("mov dword " + loAddr + ", " + lo + "; " + desc)
			code += utils.Format("mov dword " + hiAddr + ", " + hi)
		}
		return
	}
	if e.Var != nil {
		loAddr := genLoAddr(ctx, e.Var)
		hiAddr := genHiAddr(ctx, e.Var)
		if result == "push" {
			code += utils.Format("push dword " + hiAddr + "; high 32bit " + desc)
			code += utils.Format("push dword " + loAddr + "; low 32bit " + desc)
		} else if isRegPair(result) {
			code += utils.Format("mov eax, dword " + loAddr + "; " + desc)
			code += utils.Format("mov edx, dword " + hiAddr)
		} else if isRegName(result) {
			// 单寄存器结果：值 = 寄存器(低):EDX(高)
			code += utils.Format("mov " + result + ", dword " + loAddr + "; " + desc)
			if result != "edx" {
				code += utils.Format("mov edx, dword " + hiAddr)
			}
		} else {
			dstLo := result
			dstHi := makeHiAddr(result)
			code += utils.Format("mov eax, dword " + loAddr)
			code += utils.Format("mov edx, dword " + hiAddr)
			code += utils.Format("mov dword " + dstLo + ", eax; " + desc)
			code += utils.Format("mov dword " + dstHi + ", edx")
		}
		return
	}
	if e.Call != nil {
		code += ctx.Arch.Call(e.Call)
		// 被调函数返回 32 位时，EDX 高位无定义，零扩展保证 u64 变量高 32 位为 0
		if fn := e.Call.Func; fn != nil && len(fn.Return) > 0 && !is64Type(fn.Return[0]) {
			code += utils.Format("mov edx, 0; zero extend 32bit return")
		}
		if result == "push" {
			code += utils.Format("push edx; high 32bit " + desc)
			code += utils.Format("push eax; low 32bit " + desc)
		} else if isRegPair(result) || result == "eax" {
			// 返回值已在 EAX:EDX 中
		} else if isRegName(result) {
			// 单寄存器结果：值 = 寄存器(低):EDX(高)
			code += utils.Format("mov " + result + ", eax")
		} else {
			dstLo := result
			dstHi := makeHiAddr(result)
			code += utils.Format("mov dword " + dstLo + ", eax; " + desc)
			code += utils.Format("mov dword " + dstHi + ", edx")
		}
		return
	}
	if e.Separator != "" {
		return compileBinOp64(ctx, e, result, desc)
	}
	code += utils.Format("mov eax, 0; mov edx, 0; unknown 64bit " + desc)
	if result == "push" {
		code += utils.Format("push edx; high 32bit")
		code += utils.Format("push eax; low 32bit")
	} else if isRegPair(result) {
	} else if !isRegName(result) {
		dstLo := result
		dstHi := makeHiAddr(result)
		code += utils.Format("mov dword " + dstLo + ", eax")
		code += utils.Format("mov dword " + dstHi + ", edx")
	}
	return
}

func compileBinOp64(ctx *context.Context, e *parser.Expression, result, desc string) (code string) {
	var leftLo, leftHi, rightLo, rightHi string

	// 右为复杂表达式（非常量且非变量）时统一协议：
	//   ① 左装入 EDX:EAX → ② 压栈保护 → ③ 右算入 EDX:EAX → ④ 弹左到 EBX:ECX
	// 旧实现假设"左已在 EDX:EAX"，左为 var/const 时并不成立，且 pop 顺序
	// 拿到的是右的值（右的 push 落在左的暂存之上），导致运算数错位。
	rightIsExpr := e.Right != nil && !e.Right.IsConst() && e.Right.Var == nil

	if rightIsExpr {
		if e.Left != nil {
			if e.Left.IsConst() {
				lo, hi := splitConst64(e.Left.Num)
				code += utils.Format("mov eax, " + lo + "; left low")
				code += utils.Format("mov edx, " + hi + "; left high")
			} else if e.Left.Var != nil {
				code += utils.Format("mov eax, dword " + genLoAddr(ctx, e.Left.Var) + "; left low")
				code += utils.Format("mov edx, dword " + genHiAddr(ctx, e.Left.Var) + "; left high")
			} else {
				code += compile64Type(ctx, e.Left, "EDX:EAX", desc+" left")
			}
		} else {
			code += utils.Format("xor eax, eax; left low")
			code += utils.Format("xor edx, edx; left high")
		}
		code += utils.Format("push edx; 保护左高字")
		code += utils.Format("push eax; 保护左低字")
		code += compile64Type(ctx, e.Right, "EDX:EAX", desc+" right")
		code += utils.Format("pop ebx; 弹左低字")
		code += utils.Format("pop ecx; 弹左高字")
		leftLo, leftHi = "ebx", "ecx"
		rightLo, rightHi = "eax", "edx"
	} else {
		if e.Left != nil {
			if e.Left.IsConst() {
				leftLo, leftHi = splitConst64(e.Left.Num)
			} else if e.Left.Var != nil {
				leftLo = "dword " + genLoAddr(ctx, e.Left.Var)
				leftHi = "dword " + genHiAddr(ctx, e.Left.Var)
			} else {
				leftLo, leftHi = "eax", "edx"
				code += compile64Type(ctx, e.Left, "EDX:EAX", desc+" left")
			}
		}
		if e.Right != nil {
			if e.Right.IsConst() {
				rightLo, rightHi = splitConst64(e.Right.Num)
			} else if e.Right.Var != nil {
				rightLo = "dword " + genLoAddr(ctx, e.Right.Var)
				rightHi = "dword " + genHiAddr(ctx, e.Right.Var)
			} else {
				rightLo, rightHi = "eax", "edx"
				code += compile64Type(ctx, e.Right, "EDX:EAX", desc+" right")
			}
		}
	}

	switch e.Separator {
	case "+":
		if rightIsExpr {
			// 右已占 EAX:EDX：就地加左（加法可交换），避免装载左时覆盖右
			code += utils.Format("add eax, " + leftLo + "; 64bit add low")
			code += utils.Format("adc edx, " + leftHi + "; 64bit add high")
		} else {
			code += utils.Format("mov eax, " + leftLo + "; 64bit add low")
			code += utils.Format("add eax, " + rightLo)
			code += utils.Format("mov edx, " + leftHi + "; 64bit add high")
			code += utils.Format("adc edx, " + rightHi)
		}
	case "-":
		if rightIsExpr {
			// 右已占 EAX:EDX：交换后做左-右
			code += utils.Format("xchg eax, " + leftLo + "; 左低↔右低")
			code += utils.Format("xchg edx, " + leftHi + "; 左高↔右高")
			code += utils.Format("sub eax, " + leftLo + "; 64bit sub low")
			code += utils.Format("sbb edx, " + leftHi + "; 64bit sub high")
		} else {
			code += utils.Format("mov eax, " + leftLo + "; 64bit sub low")
			code += utils.Format("sub eax, " + rightLo)
			code += utils.Format("mov edx, " + leftHi + "; 64bit sub high")
			code += utils.Format("sbb edx, " + rightHi)
		}
	case "*":
		// 64 位无符号乘法低 64 位：lo*lo + (lo*hi + hi*lo)<<32
		// 先把右操作数压栈固定化（可能是 EAX:EDX 寄存器对），再保护 EBX/ESI/EDI/ECX。
		// 压栈顺序 hi→lo：配合后续 4 个寄存器保存，使 [esp+16]=b.lo、[esp+20]=b.hi
		code += utils.Format("push " + rightHi + "; b.hi")
		code += utils.Format("push " + rightLo + "; b.lo")
		code += utils.Format("push ebx")
		code += utils.Format("push esi")
		code += utils.Format("push edi")
		code += utils.Format("push ecx; ECX 可能持有外层活跃值")
		// 栈布局（后压在低地址）：[esp]=ecx [esp+4]=edi [esp+8]=esi [esp+12]=ebx [esp+16]=b.lo [esp+20]=b.hi
		code += utils.Format("mov ebx, " + leftLo + "; a.lo")
		code += utils.Format("mov esi, " + leftHi + "; a.hi")
		code += utils.Format("mov eax, ebx")
		code += utils.Format("mul dword [esp+16]; a.lo*b.lo")
		code += utils.Format("mov ecx, eax; 结果低字")
		code += utils.Format("mov edi, edx; 高字累加器")
		code += utils.Format("mov eax, ebx")
		code += utils.Format("mul dword [esp+20]; a.lo*b.hi")
		code += utils.Format("add edi, eax")
		code += utils.Format("mov eax, esi")
		code += utils.Format("mul dword [esp+16]; a.hi*b.lo")
		code += utils.Format("add edi, eax")
		code += utils.Format("mov eax, ecx")
		code += utils.Format("mov edx, edi")
		code += utils.Format("pop ecx")
		code += utils.Format("pop edi")
		code += utils.Format("pop esi")
		code += utils.Format("pop ebx")
		code += utils.Format("add esp, 8; 弹出右操作数")
	case "/", "%":
		// 64 位无符号除法/取模：统一移位减法循环（任意 64 位除数）。
		// 商 = QUOT(EBX:QUOTlo槽)，余数 = REM(ESI:EDI)
		code += utils.Format("push " + rightLo + "; b.lo")
		code += utils.Format("push " + rightHi + "; b.hi")
		code += utils.Format("push " + leftLo + "; a.lo")
		code += utils.Format("push " + leftHi + "; a.hi")
		code += utils.Format("push 0; QUOT.lo 暂存槽")
		code += utils.Format("push ebx")
		code += utils.Format("push esi")
		code += utils.Format("push edi")
		code += utils.Format("push ecx; ECX 可能持有外层活跃值")
		utils.Count++
		lb := "d64_" + strconv.Itoa(utils.Count)
		// 栈布局：[esp]=ecx [esp+4]=edi [esp+8]=esi [esp+12]=ebx [esp+16]=QUOT.lo
		//         [esp+20]=a.hi [esp+24]=a.lo [esp+28]=b.hi [esp+32]=b.lo
		code += utils.Format("mov edi, [esp+24]; a.lo")
		code += utils.Format("mov [esp+16], edi; QUOT.lo = 被除数低")
		code += utils.Format("mov edi, [esp+20]; a.hi")
		code += utils.Format("mov ebx, edi; QUOT.hi = 被除数高")
		code += utils.Format("xor esi, esi; REM.hi = 0")
		code += utils.Format("xor edi, edi; REM.lo = 0")
		code += utils.Format("mov ecx, 64")
		code += utils.Format(lb + "_loop:")
		// 128 位 QUOT(低):REM(高) 整体左移一位：位从商流入余数
		code += utils.Format("shl dword [esp+16], 1; 商低字，bit0 补 0")
		code += utils.Format("rcl ebx, 1")
		code += utils.Format("rcl edi, 1; QUOT.hi 旧最高位 → 余数低位")
		code += utils.Format("rcl esi, 1")
		code += utils.Format("cmp esi, [esp+28]; REM vs b（无符号）")
		code += utils.Format("ja " + lb + "_set")
		code += utils.Format("jb " + lb + "_skip")
		code += utils.Format("cmp edi, [esp+32]")
		code += utils.Format("jb " + lb + "_skip")
		code += utils.Format(lb + "_set:")
		code += utils.Format("sub edi, [esp+32]")
		code += utils.Format("sbb esi, [esp+28]")
		code += utils.Format("or dword [esp+16], 1")
		code += utils.Format(lb + "_skip:")
		code += utils.Format("loop " + lb + "_loop")
		if e.Separator == "/" {
			code += utils.Format("mov eax, [esp+16]; 商低字")
			code += utils.Format("mov edx, ebx; 商高字")
		} else {
			code += utils.Format("mov eax, edi; 余数低字")
			code += utils.Format("mov edx, esi; 余数高字")
		}
		code += utils.Format("pop ecx")
		code += utils.Format("pop edi")
		code += utils.Format("pop esi")
		code += utils.Format("pop ebx")
		code += utils.Format("add esp, 20; 弹出 QUOT 槽与双操作数")
	default:
		code += utils.Format("mov eax, " + leftLo + "; 64bit op " + e.Separator)
		code += utils.Format("mov edx, " + leftHi)
	}

	if result == "push" {
		code += utils.Format("push edx; high 32bit " + desc)
		code += utils.Format("push eax; low 32bit " + desc)
	} else if isRegPair(result) {
		// 结果已在 EAX:EDX 中
	} else if isRegName(result) {
		if result != "eax" {
			code += utils.Format("mov " + result + ", eax; 结果低字")
		}
	} else {
		dstLo := result
		dstHi := makeHiAddr(result)
		code += utils.Format("mov dword " + dstLo + ", eax; " + desc)
		code += utils.Format("mov dword " + dstHi + ", edx")
	}
	return
}

func makeHiAddr(loAddr string) string {
	if strings.HasPrefix(loAddr, "[__global_") {
		closeIdx := strings.Index(loAddr, "]")
		if closeIdx == -1 {
			return loAddr
		}
		return loAddr[:closeIdx] + "+4]"
	}
	idx := strings.Index(loAddr, "[ebp")
	if idx == -1 {
		return loAddr
	}
	prefix := loAddr[:idx]
	ebpPart := loAddr[idx:]
	closeIdx := strings.Index(ebpPart, "]")
	if closeIdx == -1 {
		return loAddr
	}
	offsetStr := ebpPart[4:closeIdx]
	if offsetStr == "" {
		return prefix + "[ebp+4]"
	}
	offset, err := strconv.Atoi(offsetStr)
	if err != nil {
		return loAddr
	}
	offset += 4
	if offset < 0 {
		return prefix + "[ebp" + strconv.Itoa(offset) + "]"
	}
	return prefix + "[ebp+" + strconv.Itoa(offset) + "]"
}
