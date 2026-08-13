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

func Is64Type(t typeSys.Type) bool {
	if t == nil {
		return false
	}
	return t.Size() == 8 && (t.Type() == "i64" || t.Type() == "u64" || t.Type() == "f64")
}

func compile64Type(ctx *context.Context, e *parser.Expression, result, desc string) (code string) {
	if e.IsConst() && typeSys.CheckKind(e.Type, "int", "uint", "i64", "u64") {
		val := strconv.FormatFloat(e.Num, 'f', -1, 64)
		if result == "push" {
			code += utils.Format("push 0; high 32bit " + desc)
			code += utils.Format("push " + val + "; low 32bit " + desc)
		} else if isRegName(result) {
			code += utils.Format("mov " + result + ", " + val + "; " + desc)
		} else {
			loAddr := result
			hiAddr := makeHiAddr(result)
			code += utils.Format("mov dword " + loAddr + ", " + val + "; " + desc)
			code += utils.Format("mov dword " + hiAddr + ", 0")
		}
		return
	}
	if e.Var != nil {
		loAddr := genLoAddr(ctx, e.Var)
		hiAddr := genHiAddr(ctx, e.Var)
		if result == "push" {
			code += utils.Format("push dword " + hiAddr + "; high 32bit " + desc)
			code += utils.Format("push dword " + loAddr + "; low 32bit " + desc)
		} else if isRegName(result) {
			code += utils.Format("mov " + result + ", dword " + loAddr + "; " + desc)
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
		if result == "push" {
			code += utils.Format("push edx; high 32bit " + desc)
			code += utils.Format("push eax; low 32bit " + desc)
		} else if isRegName(result) {
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

	if e.Left != nil {
		if e.Left.IsConst() {
			leftLo = strconv.FormatFloat(e.Left.Num, 'f', -1, 64)
			leftHi = "0"
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
			rightLo = strconv.FormatFloat(e.Right.Num, 'f', -1, 64)
			rightHi = "0"
		} else if e.Right.Var != nil {
			rightLo = "dword " + genLoAddr(ctx, e.Right.Var)
			rightHi = "dword " + genHiAddr(ctx, e.Right.Var)
		} else {
			code += utils.Format("push edx; save left high")
			code += utils.Format("push eax; save left low")
			code += compile64Type(ctx, e.Right, "push", desc+" right")
			code += utils.Format("pop ebx; restore left low")
			code += utils.Format("pop ecx; restore left high")
			leftLo, leftHi = "ebx", "ecx"
			rightLo, rightHi = "eax", "edx"
		}
	}

	switch e.Separator {
	case "+":
		code += utils.Format("mov eax, " + leftLo + "; 64bit add low")
		code += utils.Format("add eax, " + rightLo)
		code += utils.Format("mov edx, " + leftHi + "; 64bit add high")
		code += utils.Format("adc edx, " + rightHi)
	case "-":
		code += utils.Format("mov eax, " + leftLo + "; 64bit sub low")
		code += utils.Format("sub eax, " + rightLo)
		code += utils.Format("mov edx, " + leftHi + "; 64bit sub high")
		code += utils.Format("sbb edx, " + rightHi)
	case "*":
		code += utils.Format("mov eax, " + leftLo + "; 64bit mul low")
		code += utils.Format("imul dword " + rightLo)
		code += utils.Format("mov ecx, edx; save high")
		code += utils.Format("mov ebx, eax; save low")
		code += utils.Format("mov eax, " + leftHi)
		code += utils.Format("imul dword " + rightHi)
		code += utils.Format("add ecx, eax")
		code += utils.Format("mov eax, ebx; restore low")
		code += utils.Format("mov edx, ecx; restore high")
	default:
		code += utils.Format("mov eax, " + leftLo + "; 64bit op " + e.Separator)
		code += utils.Format("mov edx, " + leftHi)
	}

	if result == "push" {
		code += utils.Format("push edx; high 32bit " + desc)
		code += utils.Format("push eax; low 32bit " + desc)
	} else if !isRegName(result) {
		dstLo := result
		dstHi := makeHiAddr(result)
		code += utils.Format("mov dword " + dstLo + ", eax; " + desc)
		code += utils.Format("mov dword " + dstHi + ", edx")
	}
	return
}

func makeHiAddr(loAddr string) string {
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
