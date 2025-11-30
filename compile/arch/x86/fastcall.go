package x86

/*
// Fastcall: x86 fastcall 调用约定（简化实现：ECX、EDX 放前两个 4 字节参数，其余压栈，调用者清理压栈部分）
// Fastcall 实现 x86 fastcall 调用约定（ECX、EDX 放前两个 4 字节参数，其余压栈）。
type Fastcall struct{}

func (a *Fastcall) Info() string { return "x86 fastcall" }
func (a *Fastcall) Regs() []string {return regs}

func (a *Fastcall) Call(call *parser.CallBlock) string {
	if call == nil || call.Func == nil {
		return ""
	}
	fn := call.Func
	code := ""
	usedECX, usedEDX := false, false
	pushed := 0

	// 1) 先把需要压栈的参数（除去前两个寄存器可容纳者）逆序压栈
	for i := len(call.Args) - 1; i >= 0; i-- {
		arg := call.Args[i]
		if arg.Type == nil && arg.Defind != nil {
			arg.Type = arg.Defind.Type
		}
		sz := 4
		if arg.Type != nil {
			sz = arg.Type.Size()
		}
		// 仅当不是第 0、1 个且为 4 字节时才考虑寄存器，其他情况直接压栈
		if (i == 0 || i == 1) && sz == 4 {
			continue
		}
		code += a.Exp(arg.Value, "push", "参数")
		pushed += sz
	}

	// 2) 安排前两个寄存器参数（4 字节）
	for i := 0; i < len(call.Args) && i < 2; i++ {
		arg := call.Args[i]
		if arg.Type == nil && arg.Defind != nil {
			arg.Type = arg.Defind.Type
		}
		if arg.Type != nil && arg.Type.Size() == 4 {
			if i == 0 && !usedECX {
				code += a.Exp(arg.Value, "ECX", "参数寄存器")
				usedECX = true
				continue
			}
			if i == 1 && !usedEDX {
				code += a.Exp(arg.Value, "EDX", "参数寄存器")
				usedEDX = true
				continue
			}
		}
		// 不能放寄存器的（非 4 字节或没位置），补充压栈（按从左到右顺序，因此用 push）
		code += a.Exp(arg.Value, "push", "参数")
		if arg.Type != nil {
			pushed += arg.Type.Size()
		} else {
			pushed += 4
		}
	}

	// 3) 生成 call
	name := fn.Name
	if name != "main" {
		name = name + strconv.Itoa(len(fn.Args))
	}
	code += utils.Format("call " + name)
	// 4) 调用者仅清理由我们 push 的部分（寄存器不计入）
	if pushed > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(pushed))
	}
	return code
}

func (a *Fastcall) Return(ret *parser.ReturnBlock) string {
	if ret == nil || len(ret.Value) == 0 {
		return utils.Format("ret\n")
	}
	code := a.Exp(ret.Value[0], "EAX", "return")
	code += utils.Format("ret\n")
	return code
}

func (a *Fastcall) Func(funcBlock *parser.FuncBlock) string {
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
	code += utils.Format("push ebp")
	code += utils.Format("mov ebp, esp")
	return code
}

func (a *Fastcall) Exp(exp *parser.Expression, result, desc string) string {
	if exp != nil && exp.Call != nil {
		code := a.Call(exp.Call)
		code += genericExp(exp, result, desc)
		return code
	}
	return genericExp(exp, result, desc)
}

// 无额外辅助函数（通用表达式逻辑在 exp_generic.go）。*/
