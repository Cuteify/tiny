package context

import (
	"cuteify/compile/arch"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	"strconv"
)

// Context 编译器上下文，统一管理编译状态
type Context struct {
	// AST 相关
	Now *parser.Node // 当前正在编译的 AST 节点

	// 寄存器管理
	Reg  *regmgr.RegMgr // 寄存器管理器
	Arch arch.Arch      // 编译器架构接口

	// 栈帧相关
	SpOffset int // ESP 偏移量（栈指针相对于函数帧的偏移）
	BpOffset int // EBP 偏移量（栈帧基址相对于参数/变量的偏移）

	// 函数相关
	StackSize int // 当前函数的栈大小
	ArgsSize  int // 当前函数的参数大小

	// 表达式编译状态
	UseEBXDirect bool // 标记是否直接使用 EBX（不通过寄存器分配）
	EbxOccupied  bool // 标记 EBX 是否已被左子占用
	ExpType      int  // 表达式类型

	// 编译器状态
	VarStackSize int // 变量栈的大小，用于跟踪局部变量所需栈空间
	ExpCount     int // 表达式计数，用于给表达式生成唯一标识
	ArgOffset    int // 参数偏移量，用于跟踪函数参数在栈中的位置
	IfCount      int // if 块数量计数，用于生成唯一的if标签
	ForCount     int // for 块数量计数，用于生成唯一的for标签
	Parser       *parser.Parser
}

// NewContext 创建新的编译器上下文
func NewContext() *Context {
	return &Context{
		Arch:         nil,
		SpOffset:     0,
		BpOffset:     0,
		StackSize:    0,
		ArgsSize:     0,
		UseEBXDirect: false,
		EbxOccupied:  false,
		ExpType:      0,
		VarStackSize: 0,
		ExpCount:     0,
		ArgOffset:    0,
		IfCount:      0,
		ForCount:     0,
	}
}

// Reset 重置上下文状态（用于开始编译新函数）
func (ctx *Context) Reset() {
	ctx.SpOffset = 0
	ctx.BpOffset = 0
	ctx.StackSize = 0
	ctx.ArgsSize = 0
	ctx.UseEBXDirect = false
	ctx.EbxOccupied = false
	ctx.ExpType = 0
	ctx.VarStackSize = 0
}

// Clone 克隆当前上下文（用于保存和恢复状态）
func (ctx *Context) Clone() *Context {
	return &Context{
		Now:          ctx.Now,
		Reg:          ctx.Reg,
		Arch:         ctx.Arch,
		SpOffset:     ctx.SpOffset,
		BpOffset:     ctx.BpOffset,
		StackSize:    ctx.StackSize,
		ArgsSize:     ctx.ArgsSize,
		UseEBXDirect: ctx.UseEBXDirect,
		EbxOccupied:  ctx.EbxOccupied,
		ExpType:      ctx.ExpType,
		VarStackSize: ctx.VarStackSize,
		ExpCount:     ctx.ExpCount,
		ArgOffset:    ctx.ArgOffset,
		IfCount:      ctx.IfCount,
		ForCount:     ctx.ForCount,
		Parser:       ctx.Parser,
	}
}

func (ctx *Context) Sp(offset int) string {
	return strconv.FormatInt(int64(ctx.SpOffset+offset), 10)
}

func (ctx *Context) Bp(offset int) string {
	return strconv.FormatInt(int64(ctx.BpOffset+offset), 10)
}
