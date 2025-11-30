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
	argSize := arch.CalcArgsSize(call.Func)
	// 保存寄存器
	for _, tmp := range a.regmgr.SaveAll(false) {
		utils.Format(tmp + "; 保存寄存器")
	}
	// 参数的栈空间
	if argSize > 0 {
		code += utils.Format("sub esp, " + strconv.Itoa(argSize) + "; 创建参数栈空间")
	}
	offset := 0
	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		// 计算参数地址比生成表达式
		code += a.Exp(arg.Value, caldAddrWithLen(arg.Type.Size(), offset), "")
		offset += arg.Type.Size()
	}
	name := fn.Name
	if name != "main" {
		name = name + strconv.Itoa(len(fn.Args))
	}
	code += utils.Format("call " + name)
	if argSize > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(argSize) + "; 清理参数栈")
	}
	return code
}

func (a *Cdecl) Return(ret *parser.ReturnBlock) string {
	// 清理函数栈空间
	code := ""
	if ret != nil && len(ret.Value) != 0 {
		// 强制获取寄存器
		reg := &regmgr.Reg{Name: "EAX", RegIndex: 0}
		a.regmgr.Force(reg, a.now, ret.Value[0])
		if reg.StoreCode != "" {
			code += reg.StoreCode
		}
		code += a.Exp(ret.Value[0], "EAX", "return")
		a.regmgr.Free(ret.Value[0])
	}

	if a.stackSize > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(a.stackSize) + "; 清理函数栈")
	}
	// 还原寄存器
	for i := 0; i < len(regs); i++ {
		r := regs[i]
		if r.CalleeSave {
			code += utils.Format("pop " + r.Name + "; 保存寄存器")
		}
	}
	code += utils.Format("pop ebp; 跳转到函数返回部分")
	code += utils.Format("ret\n")
	return code
}

func (a *Cdecl) Func(funcBlock *parser.FuncBlock) string {
	if funcBlock == nil {
		return ""
	}
	name := funcBlock.Name
	if name != "main" {
		name = name + strconv.Itoa(len(funcBlock.Args))
	}

	// 处理参数偏移
	argOffset := 8 // 第一个参数起始
	for i := 0; i < len(funcBlock.Args); i++ {
		arg := funcBlock.Args[i]
		arg.Offset = argOffset
		argOffset += arg.Type.Size()
	}

	code := utils.Format("; ==============================")
	code += utils.Format("; Function:" + name)
	code += utils.Format(name + ":")
	utils.Count++
	code += utils.Format("push ebp; 保存栈帧")
	code += utils.Format("; ---- 保存寄存器 ----")
	for i := 0; i < len(regs); i++ {
		r := regs[i]
		if r.CalleeSave {
			code += utils.Format("push " + r.Name + "; 保存寄存器")
		}
	}
	code += utils.Format("; ---- 分配栈空间 ----")
	code += utils.Format("mov ebp, esp; 创建新的栈帧")
	stackSize := arch.CalcStackSize(a.now, 4)
	if stackSize > 0 {
		code += utils.Format("sub esp, " + strconv.Itoa(stackSize) + "; 创建栈空间")
	}
	code += utils.Format("; ---- 函数内容 ----")
	return code
}

func (a *Cdecl) Exp(exp *parser.Expression, result, desc string) string {
	expc := expCom{arch: a, now: a.now, regmgr: a.regmgr}
	return expc.CompileExpr(exp, result, desc)
}

// 无额外辅助函数（通用表达式逻辑在 exp_generic.go）。

func caldAddrWithLen(size int, offset int) string {
	if offset == 0 {
		return utils.GetLengthName(size) + "[ebp]"
	}
	return utils.GetLengthName(size) + "[ebp + " + strconv.FormatInt(int64(offset), 10) + "]"
}
