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
	SetArgsOffset(fn *parser.FuncBlock) // 将参数偏移从调用者帧位置刷新为 callee-local 位置
	Prologue(fn *parser.FuncBlock) string
	// Epilogue 生成公共返回点。cleanup 是出口 GC 释放序列（可为空），
	// 必须插在 func_end_<name>: 之后、清理栈帧之前：显式 ret 会 jmp 到该
	// 标签，提前放置会被跳过；提前清栈则释放调用会覆写已归还的局部槽。
	// 实现负责保存/恢复返回值寄存器，释放调用不得破坏返回值。
	Epilogue(fn *parser.FuncBlock, cleanup string) string

	// ---- 函数调用 ----
	Call(call *parser.CallBlock) string
	Return(ret *parser.ReturnBlock) string
	// ReturnValue 只生成返回值代码（不跳转）；ReturnJump 只生成跳到公共
	// 返回点的代码。compileReturnBlock 在两者之间插入 ret 临时对象释放。
	ReturnValue(ret *parser.ReturnBlock) string
	ReturnJump() string
	ReturnReg() string // 返回值寄存器名（EAX/RAX）

	// ---- 表达式与语句 ----
	Exp(exp *parser.Expression, result, desc string) string
	ForBegin(forBlock *parser.ForBlock) string
	// ForBeginCond 与 ForBegin 相同，但条件假/真路径分别跳到 falseLabel/
	// trueLabel，且不发射默认 body 标签；falseLabel/trueLabel 为空时等价于
	// ForBegin。用于在条件求值后插入临时对象释放。
	ForBeginCond(forBlock *parser.ForBlock, falseLabel, trueLabel string) string
	ForEnd(forBlock *parser.ForBlock, cleanup string) string
	VarDecl(varBlock *parser.VarBlock) string
	VarAddr(v *parser.VarBlock) string
	MultiVarDecl(varBlock *parser.VarBlock) string // 多返回值解构（a, b := foo()）

	// ---- 条件跳转 ----
	Cmp(dst, src string) string
	Jump(typ, dst, src string) string
	Compare64(cond *parser.Expression, jumpLabel string) string // 32 位模式下 64 位类型比较

	// ---- 指令映射（一元/二元运算符） ----
	InstMov(dst, src string) string
	InstPush(val string) string
	InstPop(addr string) string
	InstUnary(op, reg string) string
	InstBinary(dst, op, src string) string

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

func ResetLocalVarOffset(n *parser.Node, offset int) {
	// 在原有基础上增加offset
	// 只有在函数起始位置，变量的偏移量修改才有效
	for _, child := range n.Children {
		switch child.Value.(type) {
		case *parser.VarBlock:
			vb := child.Value.(*parser.VarBlock)
			vb.Offset += offset
			for i := range vb.MultiOffsets {
				vb.MultiOffsets[i] += offset
			}
		case *parser.IfBlock:
			ResetLocalVarOffset(child, offset)
			if child.Value.(*parser.IfBlock).Else {
				ResetLocalVarOffset(child.Value.(*parser.IfBlock).ElseBlock, offset)
			}
		}
	}
}
