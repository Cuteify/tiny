// Package x86 实现 x86 平台的调用约定（cdecl/stdcall/fastcall）。
package x86

import (
	"cuteify/compile/arch"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"cuteify/utils"
	"strconv"
)

// Stdcall 实现 x86 stdcall 调用约定（全部压栈，被调者清理）。
// 由于 Arch 接口的 Return 无法直接得知总参数字节数，这里暂以简单 ret 代替；
// 真实 ret N 需要外层提供 totalArgBytes 信息并拼接到返回处（后续接线时补上）。
type Stdcall struct {
	stackSize int
	argsSize  int
	regmgr    *regmgr.RegMgr
	now       *parser.Node
}

func (a *Stdcall) Info() string { return "x86 stdcall" }
func (a *Stdcall) Regs() *regmgr.RegMgr {
	if a.regmgr == nil {
		a.regmgr = regmgr.NewRegMgr(regs)
	}
	return a.regmgr
}

func (a *Stdcall) Now(node *parser.Node) { a.now = node }

func (a *Stdcall) Call(call *parser.CallBlock) string {
	if call == nil || call.Func == nil {
		return ""
	}
	fn := call.Func
	code := ""
	//argSize := arch.CalcArgsSize(a.now)
	// 参数的栈空间
	//code += utils.Format("sub esp, " + strconv.Itoa(argSize) + "; 创建参数栈空间")
	offset := 0
	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		// 计算参数地址
		code += a.Exp(arg.Value, caldAddrWithLen(arg.Type.Size(), offset), "")
		offset += arg.Type.Size()
	}
	name := fn.Name
	if name != "main" {
		name = name + strconv.Itoa(len(fn.Args))
	}
	code += utils.Format("call " + name)
	return code
}

func (a *Stdcall) Return(ret *parser.ReturnBlock) string {
	code := ""
	if ret != nil && len(ret.Value) != 0 {
		code += a.Exp(ret.Value[0], "EAX", "return")
	}

	if a.argsSize+a.stackSize > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(a.argsSize) + "; 清理参数栈")
	}
	code += utils.Format("pop ebp; 跳转到函数返回部分")
	code += utils.Format("ret\n")
	return code
}

func (a *Stdcall) Func(funcBlock *parser.FuncBlock) string {
	if funcBlock == nil {
		return ""
	}
	name := funcBlock.Name
	if name != "main" {
		name = name + strconv.Itoa(len(funcBlock.Args))
	}
	code := utils.Format("; ==============================")
	code += utils.Format("; Function:" + name)
	code += utils.Format(name + ":")
	utils.Count++
	code += utils.Format("push ebp")
	code += utils.Format("mov ebp, esp")
	//a.argsSize = arch.CalcArgsSize(a.now)
	a.stackSize = arch.CalcStackSize(a.now, 4)
	return code
}

func (a *Stdcall) Exp(exp *parser.Expression, result, desc string) string {
	expc := expCom{arch: a, now: a.now, regmgr: a.regmgr}
	return expc.CompileExpr(exp, result, desc)
}
