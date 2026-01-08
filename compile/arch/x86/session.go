package x86

import (
	"cuteify/compile/regmgr"
	"cuteify/parser"
)

// ArchCaller 接口，用于调用编译器架构的方法
type ArchCaller interface {
	Call(call *parser.CallBlock) string
}

// Session 编译会话，统一管理编译上下文和状态
type Session struct {
	// AST 相关
	now *parser.Node // 当前正在编译的 AST 节点

	// 寄存器管理
	regmgr *regmgr.RegMgr // 寄存器管理器
	arch   ArchCaller     // 编译器架构调用接口（用于调用 Call 方法）

	// 栈帧相关
	espOffset int // ESP 偏移量（栈指针相对于函数帧的偏移）
	ebpOffset int // EBP 偏移量（栈帧基址相对于参数/变量的偏移）

	// 函数相关
	stackSize int // 当前函数的栈大小
	argsSize  int // 当前函数的参数大小

	// 表达式编译状态
	useEBXDirect bool // 标记是否直接使用 EBX（不通过寄存器分配）
	ebxOccupied  bool // 标记 EBX 是否已被左子占用
	expType      int  // 表达式类型
}

// NewSession 创建新的编译会话
func NewSession(archInst ArchCaller) *Session {
	return &Session{
		arch:      archInst,
		espOffset: 0,
		ebpOffset: 0,
		stackSize: 0,
		argsSize:  0,
	}
}

// SetCurrentNode 设置当前正在编译的 AST 节点
func (s *Session) SetCurrentNode(node *parser.Node) {
	s.now = node
}

// CurrentNode 获取当前正在编译的 AST 节点
func (s *Session) CurrentNode() *parser.Node {
	return s.now
}

// SetRegMgr 设置寄存器管理器
func (s *Session) SetRegMgr(regmgr *regmgr.RegMgr) {
	s.regmgr = regmgr
}

// RegMgr 获取寄存器管理器
func (s *Session) RegMgr() *regmgr.RegMgr {
	return s.regmgr
}

// SetEspOffset 设置 ESP 偏移量
func (s *Session) SetEspOffset(offset int) {
	s.espOffset = offset
}

// EspOffset 获取 ESP 偏移量
func (s *Session) EspOffset() int {
	return s.espOffset
}

// AdjustEspOffset 调整 ESP 偏移量
func (s *Session) AdjustEspOffset(delta int) {
	s.espOffset += delta
}

// SetEbpOffset 设置 EBP 偏移量
func (s *Session) SetEbpOffset(offset int) {
	s.ebpOffset = offset
}

// EbpOffset 获取 EBP 偏移量
func (s *Session) EbpOffset() int {
	return s.ebpOffset
}

// AdjustEbpOffset 调整 EBP 偏移量
func (s *Session) AdjustEbpOffset(delta int) {
	s.ebpOffset += delta
}

// SetStackSize 设置栈大小
func (s *Session) SetStackSize(size int) {
	s.stackSize = size
}

// StackSize 获取栈大小
func (s *Session) StackSize() int {
	return s.stackSize
}

// SetArgsSize 设置参数大小
func (s *Session) SetArgsSize(size int) {
	s.argsSize = size
}

// ArgsSize 获取参数大小
func (s *Session) ArgsSize() int {
	return s.argsSize
}

// SetUseEBXDirect 设置是否直接使用 EBX
func (s *Session) SetUseEBXDirect(use bool) {
	s.useEBXDirect = use
}

// UseEBXDirect 是否直接使用 EBX
func (s *Session) UseEBXDirect() bool {
	return s.useEBXDirect
}

// SetEbxOccupied 设置 EBX 占用状态
func (s *Session) SetEbxOccupied(occupied bool) {
	s.ebxOccupied = occupied
}

// EbxOccupied EBX 是否被占用
func (s *Session) EbxOccupied() bool {
	return s.ebxOccupied
}

// SetExpType 设置表达式类型
func (s *Session) SetExpType(expType int) {
	s.expType = expType
}

// ExpType 获取表达式类型
func (s *Session) ExpType() int {
	return s.expType
}

// Reset 重置会话状态（用于开始编译新函数）
func (s *Session) Reset() {
	s.espOffset = 0
	s.ebpOffset = 0
	s.stackSize = 0
	s.argsSize = 0
	s.useEBXDirect = false
	s.ebxOccupied = false
	s.expType = 0
}

// Clone 克隆当前会话（用于保存和恢复状态）
func (s *Session) Clone() *Session {
	return &Session{
		now:          s.now,
		regmgr:       s.regmgr,
		arch:         s.arch,
		espOffset:    s.espOffset,
		ebpOffset:    s.ebpOffset,
		stackSize:    s.stackSize,
		argsSize:     s.argsSize,
		useEBXDirect: s.useEBXDirect,
		ebxOccupied:  s.ebxOccupied,
		expType:      s.expType,
	}
}
