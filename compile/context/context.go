package context

import (
	"cuteify/compile/arch"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
)

// VtableEntry represents a vtable for a concrete type implementing an interface.
type VtableEntry struct {
	Label     string                   // assembly label (e.g., __vtable_Dog_Stringer)
	Concrete  typeSys.Type             // concrete struct type
	Interface *typeSys.InterfaceType   // interface type
	Methods   []string                 // function labels for each method in order
}

// Context 编译器上下文，统一管理编译状态
type Context struct {
	// AST 相关
	Now *parser.Node // 当前正在编译的 AST 节点

	// 当前函数上下文
	CurrentFunc *parser.FuncBlock // 当前正在编译的函数

	// 寄存器管理
	Reg  *regmgr.RegMgr // 寄存器管理器
	Arch arch.Arch      // 编译器架构接口

	// 栈帧相关
	SpOffset int // ESP 偏移量（栈指针相对于函数帧的偏移）
	BpOffset int // EBP 偏移量（栈帧基址相对于参数/变量的偏移）

	// 函数相关
	StackSize int // 当前函数的栈大小
	ArgsSize  int // 当前函数的参数大小

	// 容器（list/string）返回值槽：负数偏移（[rbp/ebp+RetSlot]）
	// 每函数预留：x64 返回槽 24B + R10 保存 8B = 32B；x86 返回槽 12B + 隐藏参数保存 4B = 16B
	RetSlot int

	// 栈对齐
	StackAlignment int // 栈对齐大小（字节），默认8

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
	SwitchCount  int // switch 块数量计数，用于生成唯一的switch标签

	// 结构体相关
	// TODO: Structs map[string]*parser.StructBlock // 存储结构体定义

	// 字符串常量池
	StringConsts map[string]string // 字面值 → 标签名
	StrCount     int               // 字符串标签计数

	// 全局 string 变量（size=24，ptr+len+cap）：在 generateDataSection 阶段生成
	GlobalStrings []*parser.VarBlock

	// build link 提供的全局符号（如 __string_len）：由 strings 包实现，
	// 编译器内建 len/cap 检测到后改为调用该符号
	StringSyms map[string]bool

	// build link 重定向表（link name → FuncBlock）：由 parser.LinkProviders 填充
	// 编译器在 Find 级别和 builtinNew 中检查此表进行函数重定向
	LinkProviders map[string]*parser.FuncBlock

	// 单态化类型替换表（TypeParam name → concrete Type）：单态化时填充
	// sizeof 等内建在 codegen 时用此表解析 TypeParam 的具体大小
	TypeSubst map[string]typeSys.Type

	ListDataCount int // list数据段标签计数

	PointerSize int
	Is64Bit     bool

	// Vtable registry for interface dispatch
	VtableEntries []VtableEntry // registered vtables
	VtableSeen    map[string]bool

	// External C function declarations (for build ext)
	Externs map[string]bool

	// Function export aliases (for build export) — exportName → mangledFuncName
	Exports map[string]string

	// Monomorphize callback: set by Compiler, called by expression compiler for generic calls.
	MonomorphizeCall func(call *parser.CallBlock) string
}

// NewContext 创建新的编译器上下文
func NewContext() *Context {
	return &Context{
		Arch:           nil,
		SpOffset:       0,
		BpOffset:       0,
		StackSize:      0,
		ArgsSize:       0,
		StackAlignment: 8, // 默认8字节对齐
		UseEBXDirect:   false,
		EbxOccupied:    false,
		ExpType:        0,
		VarStackSize:   0,
		ExpCount:       0,
		ArgOffset:      0,
		IfCount:        0,
		ForCount:       0,
		StringConsts:   make(map[string]string),
		StrCount:       0,
		PointerSize:    4,
		Is64Bit:        false,
		VtableSeen:     make(map[string]bool),
	}
}

// Reset 重置上下文状态（用于开始编译新函数）
func (ctx *Context) Reset() {
	ctx.SpOffset = 0
	ctx.BpOffset = 0
	ctx.StackSize = 0
	ctx.ArgsSize = 0
	ctx.StackAlignment = 8 // 重置为默认8字节对齐
	ctx.UseEBXDirect = false
	ctx.EbxOccupied = false
	ctx.ExpType = 0
	ctx.VarStackSize = 0
	// Note: Is64Bit and PointerSize are NOT reset - they are arch-level settings
	// Note: VtableEntries and VtableSeen are NOT reset here - they persist across functions
}

// Clone 克隆当前上下文（用于保存和恢复状态）
func (ctx *Context) Clone() *Context {
	return &Context{
		Now:            ctx.Now,
		Reg:            ctx.Reg,
		Arch:           ctx.Arch,
		SpOffset:       ctx.SpOffset,
		BpOffset:       ctx.BpOffset,
		StackSize:      ctx.StackSize,
		ArgsSize:       ctx.ArgsSize,
		StackAlignment: ctx.StackAlignment,
		UseEBXDirect:   ctx.UseEBXDirect,
		EbxOccupied:    ctx.EbxOccupied,
		ExpType:        ctx.ExpType,
		VarStackSize:   ctx.VarStackSize,
		ExpCount:       ctx.ExpCount,
		ArgOffset:      ctx.ArgOffset,
		IfCount:        ctx.IfCount,
		ForCount:       ctx.ForCount,
		PointerSize:    ctx.PointerSize,
		Is64Bit:        ctx.Is64Bit,
		VtableEntries:  ctx.VtableEntries, // shared slice (append-only, safe)
		VtableSeen:     ctx.VtableSeen,    // shared map (safe for reads)
	}
}

// TODO: // AddStruct 添加结构体定义到上下文
// TODO: func (ctx *Context) AddStruct(structBlock *parser.StructBlock) {
// TODO: 	ctx.Structs[structBlock.Name] = structBlock
// TODO: }
// TODO:
// TODO: // GetStruct 获取结构体定义
// TODO: func (ctx *Context) GetStruct(name string) (*parser.StructBlock, bool) {
// TODO: 	structBlock, exists := ctx.Structs[name]
// TODO: 	return structBlock, exists
// TODO: }
// TODO:
// TODO: // GetStructFieldOffset 获取结构体字段的偏移量
// TODO: func (ctx *Context) GetStructFieldOffset(structName, fieldName string) (int, bool) {
// TODO: 	structBlock, exists := ctx.GetStruct(structName)
// TODO: 	if !exists {
// TODO: 		return 0, false
// TODO: 	}
// TODO:
// TODO: 	for _, field := range structBlock.Fields {
// TODO: 		if field.Name == fieldName {
// TODO: 			return field.Offset, true
// TODO: 		}
// TODO: 	}
// TODO:
// TODO: 	return 0, false
// TODO: }

// vtableKey returns a unique key for a (concrete, interface) pair.
func vtableKey(concrete typeSys.Type, iface *typeSys.InterfaceType) string {
	return concrete.Type() + ":" + iface.Type()
}

// RegisterVtable registers a vtable for a concrete type implementing an interface.
// Returns the assembly label for the vtable.
func (ctx *Context) RegisterVtable(concrete typeSys.Type, iface *typeSys.InterfaceType, methodLabels []string) string {
	key := vtableKey(concrete, iface)
	if ctx.VtableSeen[key] {
		for _, e := range ctx.VtableEntries {
			if vtableKey(e.Concrete, e.Interface) == key {
				return e.Label
			}
		}
	}
	ctx.VtableSeen[key] = true

	// Build label from type names
	concreteName := concrete.Type()
	if st, ok := concrete.(*typeSys.StructType); ok {
		concreteName = st.TypeName
	}
	ifaceName := iface.TypeName
	label := "__vtable_" + concreteName + "_" + ifaceName

	entry := VtableEntry{
		Label:     label,
		Concrete:  concrete,
		Interface: iface,
		Methods:   methodLabels,
	}
	ctx.VtableEntries = append(ctx.VtableEntries, entry)
	return label
}

// LookupVtable finds the vtable label for a concrete type implementing an interface.
func (ctx *Context) LookupVtable(concrete typeSys.Type, iface *typeSys.InterfaceType) string {
	key := vtableKey(concrete, iface)
	for _, e := range ctx.VtableEntries {
		if vtableKey(e.Concrete, e.Interface) == key {
			return e.Label
		}
	}
	return ""
}

// GetVtableMethodOffset returns the byte offset of a method in the vtable.
// Vtable layout: [type_info_ptr | method_0 | method_1 | ...]
// Each slot is pointerSize bytes. methodIndex 0 is at offset pointerSize.
func (ctx *Context) GetVtableMethodOffset(methodIndex int) int {
	ps := ctx.PointerSize
	if ps == 0 {
		ps = 4
	}
	return ps + methodIndex*ps
}

// GetMethodIndex returns the index of a method in the interface's method list.
func GetMethodIndex(iface *typeSys.InterfaceType, methodName string) int {
	for i, m := range iface.InterfaceMethods {
		if m.Name == methodName {
			return i
		}
	}
	return -1
}
