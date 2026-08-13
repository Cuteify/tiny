// Package arch 提供架构相关的辅助函数。
package arch

import (
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
)

// Arch 定义了针对特定目标架构的完整代码生成接口。
type Arch interface {
	Info() string

	// ---- 函数生命周期 ----
	Prologue(fn *parser.FuncBlock) string
	Epilogue(fn *parser.FuncBlock) string

	// ---- 函数调用 ----
	Call(call *parser.CallBlock) string
	Return(ret *parser.ReturnBlock) string
	ReturnReg() string // 返回值寄存器名（EAX/RAX）

	// ---- 表达式与语句 ----
	Exp(exp *parser.Expression, result, desc string) string
	ForBegin(forBlock *parser.ForBlock) string
	ForEnd(forBlock *parser.ForBlock) string
	VarDecl(varBlock *parser.VarBlock) string
	VarAddr(v *parser.VarBlock) string

	// ---- 条件跳转 ----
	Cmp(dst, src string) string
	Jump(typ, dst, src string) string

	// ---- 指令映射（一元/二元运算符） ----
	InstMov(dst, src string) string
	InstPush(val string) string
	InstPop(addr string) string
	InstUnary(op, reg string) string
	InstBinary(op, dst, src string) string

	// ---- 寄存器信息 ----
	DefaultRegMask() uint32 // 默认寄存器类别掩码
	NeedRegClass(bt typeSys.BackendType) uint32
	NeedBindRegs(op string) []*regmgr.Reg
	NeedBindMask(op string) uint32 // 运算符需要的硬绑定寄存器掩码
	CalleeSaveReg() string         // 返回一个 callee-save 寄存器名
	CalleeSaveRegs() []string      // 所有 callee-save 寄存器列表
	IsCalleeSave(name string) bool // 判断是否 callee-save
	HiReg() string                 // 64位高位寄存器（EDX/RDX）

	// ---- 栈与地址 ----
	FramePtr() string                      // 帧指针寄存器（EBP/RBP）
	StackPtr() string                      // 栈指针寄存器（ESP/RSP）
	PointerSize() int                      // 指针大小（4/8）
	PushSize() int                         // push 指令压入的字节数（4/8）
	SizePrefix() string                    // "DWORD" / "QWORD"
	LengthName(sz int) string              // "byte" / "word" / "dword" / "qword"
	FormatAddr(offset int) string          // 格式化栈地址（[ebp-16]/[rbp-16]）
	ExtractOffset(addr string) (int, bool) // 提取偏移量

	// ---- 数据类型 ----
	Is64Type(t typeSys.Type) bool
	Compile64Type(e *parser.Expression, result, desc string) string

	// ---- 程序入口 ----
	GenerateStartEntry() string // 生成 _start 入口代码
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
			if v.IsDefine {
				varSize := v.Type.Size()
				if varSize == 0 {
					varSize = 4
				}
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
