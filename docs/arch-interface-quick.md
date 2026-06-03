# Cuteify 编译器接口速查

## 前端

### lexer

```go
type Lexer struct {
    Text, LineFeed, Filename string   // 源代码文本、换行符类型、文件名
    Cursor, TextLength       int      // 当前读取位置、文本总长度
    IsString                 bool     // 是否正在读取字符串
    Error                    *errorUtil.Error  // 错误处理器
    SepTmp                   string   // 分隔符暂存
}

func NewLexer(filename string) *Lexer         // 读取文件并创建词法分析器
func (l *Lexer) Next() Token                  // 获取下一个Token（主入口）
func (l *Lexer) GetToken() (Token, error)     // 从光标位置读取一个Token
func (l *Lexer) Skip(s ...byte)               // 跳过指定字符，不匹配则报错
func (l *Lexer) SetCursor(cursor int)         // 设置读取位置
func (l *Lexer) AddCursor(cursor int)         // 前进指定字符数
func (l *Lexer) GetWord() (string, bool)      // 获取下一个词法单元（返回词和是否为分隔符）
func (l *Lexer) GetString() string            // 读取双引号字符串内容
func (l *Lexer) GetChar() string              // 读取单引号字符内容
func (l *Lexer) GetRawString() string         // 读取反引号原始字符串内容
func (l *Lexer) SkipSep()                     // 跳过空格

type Token struct { Type int; Value string; Cursor, EndCursor int }
func (t Token) String() string   // 可读字符串表示（含类型名和值）
func (t Token) Len() int         // Token值的长度
func (t Token) IsEmpty() bool    // 是否为空（Type == 0）

// Token类型: NONE FUNC VAR PROCESSCONTROL SEPARATOR STRING NUMBER NAME CHAR TYPE RAW BOOL BUILD
```

### parser

```go
type Parser struct {
    Block, ThisBlock *Node              // AST根节点、当前作用域节点
    Lexer            *lexer.Lexer       // 词法分析器
    BracketsNum      int                // 括号计数
    Error            *errorUtil.Error   // 错误处理器
    Package          *packageFmt.Info   // 包信息
    DontBack         int                // 阻止回退计数
}

func NewParser(lex *lexer.Lexer) *Parser                             // 创建语法分析器
func (p *Parser) Parse() *Node                                      // 执行完整语法分析，返回AST根节点
func (p *Parser) Next() (finish bool)                               // 解析下一个语法单元，返回是否结束
func (p *Parser) AddChild(node *Node)                               // 向当前作用域添加子节点
func (p *Parser) Back(num int) error                                // 从当前作用域回退num层
func (p *Parser) Need(value string) []lexer.Token                   // 持续读取Token直到遇到指定值
func (p *Parser) Wait(value string) int                             // 等待指定Token出现，返回经过的Token数
func (p *Parser) Name(allowPath bool) (Name, int)                   // 解析名称（支持a.b.c路径形式）
func (p *Parser) ParseExp(stopCursor int) *Expression               // 解析表达式
func (p *Parser) FindVar(name Name) (*Node, any)                    // 查找变量定义
func (p *Parser) FindFunc(name Name) (*Node, *FuncBlock)            // 查找函数定义
func (p *Parser) FindStruct(name Name) (*Node, *TypeBlock)          // 查找结构体定义
func (p *Parser) FindType(name Name) (*Node, typeSys.Type)          // 查找类型定义
func (p *Parser) FindGlobal(name Name) *Node                        // 查找全局定义

type Name []string   // 点分路径名称，如 ["pkg", "module", "func"]
func NewName(parts ...string) Name             // 从字符串列表创建Name
func (n Name) String() string                  // 返回NASM安全的点分连接形式
func (n Name) Path() string                    // 返回路径部分（除最后一部分）
func (n Name) Last() string                    // 返回最后一部分
func (n Name) First() string                   // 返回第一部分
func (n Name) Eq(other Name) bool              // 判断两个名称是否完全相等
func (n Name) IsEmpty() bool                   // 判断名称是否为空
func (n Name) IsPath() bool                    // 判断是否为多段路径
func (n Name) Fork() Name                      // 创建深拷贝
func (n Name) ForkJoin(other ...string) Name   // 创建拷贝后追加更多段
func (n Name) ForkSlice(other Name) Name       // 创建拷贝后裁切匹配前缀
func (n Name) FixPath(pkg *packageFmt.Info) bool  // 将名称第一段替换为包导入的实际路径

type Node struct { Value Block; Father *Node; Children []*Node; Ignore, Checked bool; Parser *Parser }
func (n *Node) AddChild(node *Node)  // 添加子节点并建立父子关系
func (n *Node) Check() bool          // 递归检查语义有效性

type Expression struct {
    Call *CallBlock; Num float64; Separator string
    Right, Left, Father, Field *Expression
    Var *VarBlock; StringVal string; Bool, ConstBool bool
    Type typeSys.Type; ListElems []*Expression
}
func (exp *Expression) IsConst() bool         // 判断是否为编译期常量
func (exp *Expression) Check(p *Parser) bool  // 语义检查（类型推导、运算符合法性）

type FuncBlock   struct { Args []*ArgBlock; Class typeSys.Type; Return []typeSys.Type; Name Name; BuildFlags []*Build; Useful bool }
type ArgBlock    struct { Name Name; Type typeSys.Type; Default, Value *Expression; Defind *ArgBlock; Offset int }
type VarBlock    struct { Name Name; IsConst, IsDefine, IsInitialized, Used bool; Value *Expression; Define *Node; StartCursor, Offset int; Type typeSys.Type }
type CallBlock   struct { Name Name; Args []*ArgBlock; Func *FuncBlock; Node *Node; ThisVar *VarBlock }
type IfBlock     struct { ElseBlock *Node; Else bool; Condition *Expression }
type ElseBlock   struct { IfCondition *Expression }
type ForBlock    struct { Init, Condition, Increment *Expression; Offset int }
type ReturnBlock struct { Value []*Expression }
type TypeBlock   struct { Name Name; Kind TypeKind; Struct *StructBlock; Interface *InterfaceDef; Alias typeSys.Type; StartCursor, EndCursor int }
type StructBlock struct { Type typeSys.StructType; EndCursor int }
type InterfaceDef struct { Methods []InterfaceMethod; EndCursor int }
type Build       struct { Type, Asm, Ext, ExtRet, Link string; UseMoreStack, Ignore bool; OS []string; VarMap map[string]*VarBlock }
// TypeKind: TypeAlias TypeStruct TypeInterface
```

### typeSys

```go
type Type interface {
    Type() string          // 返回类型名称字符串
    String() string        // 返回字符串表示
    Fields() StructFileds  // 返回结构体字段（非结构体返回nil）
    Set(interface{})       // 设置类型名
    Size() int             // 返回类型大小（字节）
    Parent() Type          // 返回父类型
    IsPointer() bool       // 是否为指针类型
    Alignment() int        // 返回对齐要求
}

type RType struct { TypeName string; RSize int; RParent Type; IsPtr bool; RAlignment int }
type ListType struct { RType; Elem Type }   // 列表类型，32位=12字节，64位=24字节
type StructType struct { RType; StructFields StructFileds; Methods []any }
type StructField struct {
    Name string; Type Type; Default any; Tags []StructTag
    Offset, Size, Alignment int; Access FieldAccess; Alias, ParentName string; IsAnon bool
}
// FieldAccess: AccessPublic AccessPrivate AccessProtected AccessReadOnly AccessWriteOnly

func GetSystemType(name string) Type                // 按名称获取内置类型（支持[]T列表语法）
func GetListType(elem Type) *ListType               // 创建列表类型
func GetKind(t Type) string                     // 获取类型类别（int/uint/float/bool/byte/string/list/unknown）
func CheckType(t Type, allows ...Type) bool         // 检查类型是否在允许列表中
func CheckKind(t Type, allows ...string) bool   // 按类别检查类型
func AutoType(before, after Type, IsConst bool) bool  // 自动类型兼容性检查
func SetTargetPointerSize(size int)                 // 设置目标平台指针大小（4或8）

// 内置类型: int uint i64 u64 i32 u32 i16 u16 i8 u8 bool byte f32 f64 string
// 32位: int/uint=4, string=12 | 64位: int/uint=8, string=24
```

### error

```go
type Error struct { Text, Path, LineFeed string }
func NewError(path, text, linefeed string) *Error                          // 创建错误处理器
func (e *Error) GetErrPos(start, end int) string                          // 生成错误位置信息（行号、列号、代码片段）
func (e *Error) MissError(errType string, cursor int, msg string)         // 报告错误并终止编译（panic）
func (e *Error) MissErrors(errType string, start, end int, msg string)    // 报告范围错误并终止编译
func (e *Error) Warning(msg string)                                        // 输出警告信息（不终止）
var Errors = map[string]*Error{}                                           // 每个源文件对应一个Error实例
```

### package

```go
func GetPackage(packagePath string, isRoot bool) (*packageFmt.Info, error)  // 递归加载包及其依赖
func FixPathName(path string) string                                        // 将路径转换为合法标识符

type Info struct {
    Version string            `json:"version"`   // 包版本
    Imports map[string]string `json:"imports"`   // 依赖映射（别名→路径）
    Action  map[string]string `json:"action"`    // 构建动作
    Path    string                               // 包路径
    AST     any                                  // AST根节点（*parser.Node）
}
```

### utils

```go
var Count int      // 全局缩进级别（用于Format函数）
var LineNum int    // 全局行号计数
func CheckName(name string) bool             // 检查标识符合法性（字母/下划线开头）
func ToNASMName(name string) string          // 转换为NASM兼容标签名（中文→_u{码点}）
func Format(text string) string              // 格式化汇编代码行（带缩进，Count控制层级）
func GetLengthName(size int) string          // 大小→汇编前缀（1→BYTE 2→WORD 4→DWORD 8→QWORD）
```

---

## 后端

### compile

```go
type Compiler struct { Ctx *context.Context }
func NewCompiler(parser *parser.Parser) *Compiler       // 创建编译器
func (c *Compiler) Compile(node *parser.Node) string     // 编译入口：AST→汇编代码
func (c *Compiler) CompileBuild(n *parser.Node) string   // 处理内联汇编（$变量名→栈地址替换）

var GoArch string  // 目标架构名称，默认"x86"，可通过CUTE_ARCH环境变量设置
func NewArch(archName string, ctx *context.Context) arch.Arch  // 架构选择器，自动设置指针大小
// x86/x86.cdecl→Cdecl | x86.stdcall→Stdcall | x86.fastcall→Fastcall
// x86.sysv→SysV | x86.win64→Win64
// x86_64/x86_64.sysv→SysV | x86_64.win64→Win64
```

### arch

```go
type Arch interface {
    Info() string                                                    // 返回架构信息描述
    Call(call *parser.CallBlock) string                              // 生成函数调用汇编（参数设置、寄存器保存、call、清理）
    Return(ret *parser.ReturnBlock) string                           // 生成函数返回汇编（返回值设置、栈恢复、ret）
    Func(funcBlock *parser.FuncBlock) string                         // 生成函数序言汇编（参数偏移、push ebp、栈空间分配）
    Exp(exp *parser.Expression, result, desc string) string          // 编译表达式到指定目标位置
    For(forBlock *parser.ForBlock) string                            // 生成for循环起始汇编
    EndFor(forBlock *parser.ForBlock) string                         // 生成for循环结束汇编
    Var(varBlock *parser.VarBlock) string                            // 生成变量赋值汇编
    GenVarAddr(v *parser.VarBlock) string                            // 计算变量在栈帧中的地址表达式
}

func CalcArgsSize(funcBlock *parser.FuncBlock) int                                  // 计算函数参数的栈空间总大小
func GetNeedSaveRegs(regMgr *regmgr.RegMgr, callerSave bool) []string              // 获取需要保存的寄存器列表
func SetupVarOffsets(funcNode *parser.Node, alignment, offset int) int              // 设置函数中所有变量的栈偏移量，返回对齐后的栈大小
func ResetLocalVarOffset(n *parser.Node, offset int)                                // 递归调整变量偏移量
```

### 调用约定

| | cdecl | stdcall | fastcall | SysV AMD64 | Win64 |
|---|---|---|---|---|---|
| 架构 | x86 | x86 | x86 | x86_64 | x86_64 |
| 参数 | 全栈 | 全栈 | ECX,EDX+栈 | 6寄存器+栈 | 4寄存器+栈 |
| 栈清理 | 调用者 | 被调用者(ret N) | 调用者 | 调用者 | 调用者 |
| Shadow | 无 | 无 | 无 | 无 | 32字节 |
| 对齐 | 4 | 4 | 4 | 16 | 16 |
| 返回值 | EAX/EDX:EAX | EAX/EDX:EAX | EAX/EDX:EAX | RAX | RAX |
| callee-save | EBX | EBX | EBX | RBX,R12-R15 | RDI,RSI,RBX,R12-R15 |

### regmgr

```go
type RegMgr struct {
    Record map[*parser.Expression]*Reg  // 寄存器分配记录
    Regs   []*Reg                       // 寄存器状态数组
    RegCount, index, totalReg int       // 已分配数、LRU索引、总数
    genVarAddr func(*parser.VarBlock) string  // 变量地址生成函数
}
func NewRegMgr(regs []*Reg, genVarAddr func(*parser.VarBlock) string) *RegMgr  // 创建寄存器管理器
func (rm *RegMgr) Get(n *parser.Node, exp *parser.Expression, needCalleeSave bool) *Reg  // 为表达式分配寄存器（LRU策略）
func (rm *RegMgr) Force(reg *Reg, n *parser.Node, exp *parser.Expression) *Reg           // 强制分配指定寄存器（溢出当前占用者）
func (rm *RegMgr) Free(exp *parser.Expression)                                            // 释放表达式占用的寄存器
func (rm *RegMgr) Reuse(n *parser.Node) *Reg                                              // 重用节点关联的寄存器
func (rm *RegMgr) Save(exp *parser.Expression) string                                     // 生成溢出代码并释放
func (rm *RegMgr) SaveAll(calleeSave bool) []string                                       // 批量保存指定类型的寄存器
func (rm *RegMgr) Reset()                                                                  // 重置所有寄存器状态
func (rm *RegMgr) GetRegUsage() (int, int, int)                                            // 获取使用情况（已用、总数、索引）

type Reg struct {
    StoreCode, Name string; RegIndex, index int
    UsingNode *parser.Node; Using, CalleeSave, Locked bool; SpillCount int
}
func (reg *Reg) Reset()  // 重置寄存器状态

// x86 32位: EAX EBX(callee) ECX EDX
// x86_64:   RAX RBX(callee) RCX RDX RSI RDI R8-R11 R12-R15(callee)
// 溢出策略: LRU + 代价计算(index + calleeSave偏好 + 溢出惩罚)
```

### context

```go
type Context struct {
    Now                          *parser.Node       // 当前编译的AST节点
    CurrentFunc                  *parser.FuncBlock  // 当前正在编译的函数
    Reg                          *regmgr.RegMgr     // 寄存器管理器
    Arch                         arch.Arch          // 编译器架构接口
    SpOffset, BpOffset           int                // ESP偏移量、EBP偏移量
    StackSize, ArgsSize          int                // 当前函数栈大小、参数大小
    StackAlignment               int                // 栈对齐大小（字节），默认8
    UseEBXDirect, EbxOccupied    bool               // 是否直接使用EBX、EBX是否已被左子占用
    ExpType                      int                // 表达式类型（NumExp/BoolExp/AndExp/OrExp/NotExp）
    VarStackSize, ExpCount       int                // 变量栈大小、表达式计数
    ArgOffset, IfCount, ForCount int                // 参数偏移量、if块计数、for块计数
    StringConsts                 map[string]string  // 字符串常量池（字面值→标签名）
    StrCount, ListDataCount      int                // 字符串标签计数、list数据段标签计数
    PointerSize                  int                // 指针大小（4或8）
    Is64Bit                      bool               // 是否64位
}
func NewContext() *Context          // 创建新上下文（默认PointerSize=4, StackAlignment=8）
func (ctx *Context) Reset()        // 重置上下文状态（编译新函数时调用）
func (ctx *Context) Clone() *Context  // 克隆上下文（保存和恢复状态）
```

### x86 表达式编译器

```go
// compile/arch/x86/exp.go + utils.go
type expCom struct { ctx *context.Context; varWithSetVal bool }
func NewExpCom(ctx *context.Context) *expCom                                              // 创建x86 32位表达式编译器
func (c *expCom) CompileExpr(exp *parser.Expression, result, desc string) string          // 编译表达式入口（分发到内置/布尔/常量/64位/普通）
func (c *expCom) CompileExprChildren(exp *parser.Expression) (string, *regmgr.Reg)        // 编译子表达式（叶节点/索引/切片/列表/二元）
func (c *expCom) CompileExprVal(exp *parser.Expression) (string, string)                  // 编译表达式值（返回代码和结果地址/值）
func (c *expCom) CompileBoolExpr(exp *parser.Expression, result string) string            // 编译布尔表达式

func genVarAddr(ctx *context.Context, v *parser.VarBlock) string   // 生成变量栈地址（DWORD[ebp+N]）
func is64Type(t typeSys.Type) bool                                // 判断是否为64位类型（i64/u64/f64）
func genLoAddr(ctx *context.Context, v *parser.VarBlock) string   // 生成64位变量低32位地址（DWORD[ebp+N]）
func genHiAddr(ctx *context.Context, v *parser.VarBlock) string   // 生成64位变量高32位地址（DWORD[ebp+N+4]）
func isRegName(s string) bool                                     // 判断字符串是否为寄存器名

// 64位编译(x86 32位): EDX:EAX寄存器对, add/adc, sub/sbb, imul组合
```

### x86_64 表达式编译器

```go
// compile/arch/x86_64/exp.go + utils.go
type expCom struct { ctx *context.Context; varWithSetVal bool }
func NewExpCom(ctx *context.Context) *expCom                                              // 创建x86_64表达式编译器
func (c *expCom) CompileExpr(exp *parser.Expression, result, desc string) string          // 编译表达式入口
func (c *expCom) CompileExprChildren(exp *parser.Expression) (string, *regmgr.Reg)        // 编译子表达式
func (c *expCom) CompileExprVal(exp *parser.Expression) (string, string)                  // 编译表达式值
func (c *expCom) CompileBoolExpr(exp *parser.Expression, result string) string            // 编译布尔表达式

func genVarAddr(ctx *context.Context, v *parser.VarBlock) string   // 生成变量栈地址（QWORD[rbp+N]）
func isRegName(s string) bool                                     // 判断字符串是否为寄存器名
func GetRbpOffset(addr string) int                                // 从地址表达式中提取rbp偏移量
```
