// Package arch 定义目标架构相关的代码生成接口。
package arch

import (
	"cuteify/compile/regmgr"
	"cuteify/parser"
)

// Arch 定义了针对特定目标架构的完整代码生成接口。
//
// 约定：
// - 所有方法均返回追加到汇编输出的片段字符串（已包含必要换行，由调用方负责拼接）。
// - 方法不应持久化隐式全局状态，避免跨函数污染；如需计数器/标签等，由上层编译器注入或显式传入。
// - 保持接口签名不变（严格遵循用户定义）。若需扩展能力，应通过新增实现内部配置或由编译器侧补充上下文。
type Arch interface {
	Info() string
	Regs() *regmgr.RegMgr

	// 函数调用类
	// Call: 生成调用序列（含按 ABI 设置实参、保存/恢复 caller-saved、发起 call、清理参数等）。
	Call(call *parser.CallBlock) string
	// Return: 生成 return 序列（含将返回值放入 ABI 规定寄存器/内存并收尾）。
	Return(ret *parser.ReturnBlock) string
	// Func: 生成函数定义的序言/尾声和主体拼接（或返回函数头/尾，视实现策略）。
	Func(funcBlock *parser.FuncBlock) string

	// Expression
	// Exp: 生成表达式到指定目标位置（result 可为寄存器名、push、或带长度的内存如 DWORD[ebp-4]）。
	// desc 用于注释文本。
	Exp(exp *parser.Expression, result, desc string) string

	Now(node *parser.Node)
}

type ExpResult struct {
	Reg       *regmgr.Reg
	MemOffset int
}

// 计算变量的栈空间
func CalcStackSize(node *parser.Node, align int) int {
	stackSize := 0
	for _, child := range node.Children {
		switch child.Value.(type) {
		case *parser.VarBlock:
			if child.Value.(*parser.VarBlock).IsDefine {
				stackSize += child.Value.(*parser.VarBlock).Type.Size()

			}
		case *parser.IfBlock:
			stackSize += CalcStackSize(child, 0)
			if child.Value.(*parser.IfBlock).Else {
				stackSize += CalcStackSize(child.Value.(*parser.IfBlock).ElseBlock, 0)
			}
		case *parser.FuncBlock:
			stackSize += CalcStackSize(child, 0)
		case *parser.CallBlock:
			// 函数调用的参数使用临时栈，不计入局部变量栈空间
			// 参数在调用时通过push传递，调用后立即清理
			continue
		}
	}

	// 如果需要对齐，就尝试对其
	if align > 0 {
		// 尝试对齐(可以被align整除)
		stackSize = (stackSize + align - 1) & ^(align - 1)
	}

	return stackSize
}

// 计算参数的栈空间
func CalcArgsSize(funcBlock *parser.FuncBlock) int {
	if funcBlock.Args == nil || len(funcBlock.Args) == 0 {
		return 0
	}
	argsSize := 0
	for i := 0; i < len(funcBlock.Args); i++ {
		argsSize += funcBlock.Args[i].Type.Size()
	}
	return argsSize
}

func GetNeedSaveRegs(regMgr *regmgr.RegMgr, callerSave bool) (ret []string) {
	rs := regMgr.Records
	for i := 0; i < len(rs); i++ {
		r := rs[i]
		if callerSave == r.CallerSave {
			had := false
			for e := 0; e < len(ret); e++ {
				if r.Name == ret[e] {
					had = true
				}
			}
			if !had {
				ret = append(ret, r.Name)
			}
		}
	}
	return
}

func ResetLocalVarOffset(n *parser.Node, offset int) {
	// 在原有基础上增加offset
	// 只有在函数起始位置，变量的偏移量修改才有效
	for _, child := range n.Children {
		switch child.Value.(type) {
		case *parser.VarBlock:
			child.Value.(*parser.VarBlock).Offset += offset
		case *parser.IfBlock:
			ResetLocalVarOffset(child, offset)
			if child.Value.(*parser.IfBlock).Else {
				ResetLocalVarOffset(child.Value.(*parser.IfBlock).ElseBlock, offset)
			}
		}
	}
}
