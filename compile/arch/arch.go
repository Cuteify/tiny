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

	For(forBlock *parser.ForBlock) string

	Var(varBlock *parser.VarBlock) string

	EndFor(forBlock *parser.ForBlock) string

	GenVarAddr(v *parser.VarBlock) string
}

type ExpResult struct {
	Reg       *regmgr.Reg
	MemOffset int
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
	rs := regMgr.Regs
	for i := 0; i < len(rs); i++ {
		r := rs[i]
		if callerSave != r.CalleeSave && r.Using {
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

// SetupVarOffsets 设置函数中所有变量的栈偏移量
// 在进入函数体之前调用，确保所有变量都有正确的栈位置
// 返回计算出的栈大小（已对齐）
func SetupVarOffsets(funcNode *parser.Node, alignment int, offset int) int {
	collectVarOffsets(funcNode, &offset)

	// 计算栈大小（最小偏移量的绝对值），使用对齐值
	stackSize := -offset
	if alignment > 0 && stackSize%alignment != 0 {
		stackSize = (stackSize + alignment - 1) & ^(alignment - 1)
	}

	return stackSize
}

// collectVarOffsets 递归收集并设置所有变量的偏移量
// 包括函数体中的变量、if/else 块中的变量
// 变量分配时进行自然对齐：每个变量按其类型大小对齐
func collectVarOffsets(node *parser.Node, offset *int) {
	for _, child := range node.Children {
		if child.Ignore {
			continue
		}

		switch v := child.Value.(type) {
		case *parser.VarBlock:
			// 只为定义的变量分配栈空间
			if v.IsDefine {
				varSize := v.Type.Size()
				*offset -= varSize
				v.Offset = *offset
			}
		case *parser.ForBlock:
			if v.Init != nil && v.Init.Var != nil {
				initVar := v.Init.Var
				varSize := initVar.Type.Size()
				*offset -= varSize
				initVar.Offset = *offset
			}
			collectVarOffsets(child, offset)
		case *parser.IfBlock:
			// 递归处理 if 块中的变量
			collectVarOffsets(child, offset)
			// 如果有 else 块，也递归处理    mov EBX, DWORD[ebp-16]

			if v.Else {
				collectVarOffsets(v.ElseBlock, offset)
			}
		case *parser.FuncBlock:
			// 跳过嵌套函数（如果有的话）
			collectVarOffsets(child, offset)
			continue
		}
	}
}
