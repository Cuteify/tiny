# Cuteify 编译器完整接口文档

***

# 第一部分：前端

前端负责将源代码文本转换为抽象语法树（AST），包括词法分析、语法分析、类型系统和错误处理四个核心模块。

***

## 1. 词法分析器 `lexer`

**包路径**: `cuteify/lexer`

**文件**: `lexer/lexer.go`, `lexer/keywords.go`

### 1.1 Lexer 结构体

词法分析器，将源代码文本分解为 Token 流。

```go
type Lexer struct {
    Text       string   // 源代码文本
    LineFeed   string   // 换行符类型（\n, \r\n, \n\r, \r）
    Cursor     int      // 当前读取位置
    IsString   bool     // 是否正在读取字符串
    Error      *errorUtil.Error  // 错误处理器
    Filename   string   // 源文件名
    TextLength int      // 源代码文本长度
    SepTmp     string   // 分隔符暂存
}
```

#### 构造函数

```go
func NewLexer(filename string) *Lexer
```

读取指定文件并创建词法分析器实例。自动检测换行符类型。

#### 核心方法

| 方法           | 签名                                                      | 说明                                    |
| ------------ | ------------------------------------------------------- | ------------------------------------- |
| Next         | `func (l *Lexer) Next() Token`                          | 获取下一个 Token（主入口）                      |
| GetToken     | `func (l *Lexer) GetToken() (Token, error)`             | 从光标位置读取一个 Token，返回 Token 和可能的错误       |
| Skip         | `func (l *Lexer) Skip(s ...byte)`                       | 跳过指定字符，不匹配则报错                         |
| SetCursor    | `func (l *Lexer) SetCursor(cursor int)`                 | 设置读取位置（同时清空 SepTmp）                   |
| AddCursor    | `func (l *Lexer) AddCursor(cursor int)`                 | 前进指定字符数（同时清空 SepTmp）                  |
| GetWord      | `func (l *Lexer) GetWord() (string, bool)`              | 获取下一个词法单元（返回词和是否为分隔符）                 |
| GetString    | `func (l *Lexer) GetString() string`                    | 读取双引号字符串内容                            |
| GetChar      | `func (l *Lexer) GetChar() string`                      | 读取单引号字符内容                             |
| GetRawString | `func (l *Lexer) GetRawString() string`                 | 读取反引号原始字符串内容                          |
| SkipSep      | `func (l *Lexer) SkipSep()`                             | 跳过空格                                  |
| handleSep    | `func (l *Lexer) handleSep(word string) (Token, error)` | 处理分隔符类型的 Token（字符串/字符/原始字符串/注释/普通分隔符） |

### 1.2 Token 结构体

```go
type Token struct {
    Type      int    // Token 类型
    Value     string // Token 值
    Cursor    int    // 起始位置
    EndCursor int    // 结束位置
}
```

#### Token 方法

| 方法      | 签名                                  | 说明                        |
| ------- | ----------------------------------- | ------------------------- |
| String  | `func (t Token) String() string`    | 返回 Token 的可读字符串表示（含类型名和值） |
| Len     | `func (t Token) Len() int`          | 返回 Token 值的长度             |
| IsEmpty | `func (token Token) IsEmpty() bool` | 判断 Token 是否为空（Type == 0）  |

### 1.3 Token 类型常量

```go
const (
    NONE           = iota  // 无
    FUNC                   // 函数关键字 fn
    VAR                    // 变量关键字 var/const/let
    PROCESSCONTROL         // 流程控制关键字 if/while/for/ret/break/continue/else/switch/case/try/except/finally
    SEPARATOR              // 分隔符（运算符、括号、标点等）
    STRING                 // 字符串字面量
    NUMBER                 // 数字字面量
    NAME                   // 标识符
    CHAR                   // 字符字面量
    TYPE                   // 类型关键字 type/struct/interface
    RAW                    // 原始字符串字面量
    BOOL                   // 布尔字面量 true/false
    BUILD                  // 编译指令关键字 build
)
```

### 1.4 关键字映射

| 类别   | 关键字                                                                                                    |
| ---- | ------------------------------------------------------------------------------------------------------ |
| 流程控制 | `if`, `while`, `for`, `ret`, `break`, `continue`, `else`, `switch`, `case`, `try`, `except`, `finally` |
| 类型   | `type`, `struct`, `interface`                                                                          |
| 变量   | `var`, `const`, `let`                                                                                  |
| 函数   | `fn`                                                                                                   |
| 布尔   | `true`, `false`                                                                                        |
| 编译指令 | `build`                                                                                                |
| 标识符  | `self`                                                                                                 |

### 1.5 分隔符列表

单字符: \`; { } ( ) \[ ] , = + - \* / % : < > . & | ^ ! ? \~ " ' \ @ \n \r \`\`

双字符: `== != <= >= ++ -- -> && \|\| << >> := += -= *= /= %= ^= &= \|= <<= >>=`

### 1.6 全局变量

| 变量                       | 类型               | 说明               |
| ------------------------ | ---------------- | ---------------- |
| keywords                 | `map[string]int` | 关键字到 Token 类型的映射 |
| LexTokenType             | `map[string]int` | Token 类型名到类型值的映射 |
| SepListLength            | `int`            | 分隔符数量（32）        |
| FuncListLength           | `int`            | 函数关键字数量（1）       |
| VarListLength            | `int`            | 变量关键字数量（3）       |
| ProcessControlListLength | `int`            | 流程控制关键字数量（14）    |
| TypeListLength           | `int`            | 类型关键字数量（2）       |
| BoolListLength           | `int`            | 布尔关键字数量（2）       |
| BuildListLength          | `int`            | 编译指令关键字数量（1）     |

### 1.7 辅助函数

| 函数          | 签名                                    | 说明            |
| ----------- | ------------------------------------- | ------------- |
| isDigit     | `func isDigit(str string) bool`       | 判断字符串是否全为数字   |
| makeVisible | `func makeVisible(str string) string` | 将不可见字符转换为可见表示 |

***

## 2. 语法分析器 `parser`

**包路径**: `cuteify/parser`

**文件**: `parser/parser.go`, `parser/node.go`, `parser/exp.go`, `parser/func.go`, `parser/var.go`, `parser/call.go`, `parser/ifelse.go`, `parser/for.go`, `parser/return.go`, `parser/struct.go`, `parser/type.go`, `parser/interface.go`, `parser/build.go`, `parser/finder.go`, `parser/breckets.go`

### 2.1 Parser 结构体

语法分析器，将 Token 流解析为 AST。

```go
type Parser struct {
    Block       *Node          // AST 根节点
    ThisBlock   *Node          // 当前作用域节点
    Lexer       *lexer.Lexer   // 词法分析器
    BracketsNum int            // 括号计数
    Error       *errorUtil.Error  // 错误处理器
    Package     *packageFmt.Info // 包信息
    DontBack    int            // 阻止回退计数
}
```

#### 构造函数

```go
func NewParser(lex *lexer.Lexer) *Parser
```

创建新的语法分析器，初始化根节点和当前作用域。

#### 核心方法

| 方法             | 签名                                                           | 说明                           |
| -------------- | ------------------------------------------------------------ | ---------------------------- |
| Parse          | `func (p *Parser) Parse() *Node`                             | 执行完整的语法分析，返回 AST 根节点         |
| Next           | `func (p *Parser) Next() (finish bool)`                      | 解析下一个语法单元，返回是否结束             |
| AddChild       | `func (p *Parser) AddChild(node *Node)`                      | 向当前作用域添加子节点                  |
| Back           | `func (p *Parser) Back(num int) error`                       | 从当前作用域回退 num 层               |
| Need           | `func (p *Parser) Need(value string) []lexer.Token`          | 持续读取 Token 直到遇到指定值           |
| Wait           | `func (p *Parser) Wait(value string) int`                    | 等待指定 Token 出现，返回经过的 Token 数量 |
| Has            | `func (p *Parser) Has(token lexer.Token, endCursor int) int` | 在范围内查找指定 Token，返回结束位置        |
| Name           | `func (p *Parser) Name(allowPath bool) (Name, int)`          | 解析名称（支持路径形式如 a.b.c）          |
| FindEndCursor  | `func (p *Parser) FindEndCursor() int`                       | 查找当前行结束位置                    |
| ParseExp       | `func (p *Parser) ParseExp(stopCursor int) *Expression`      | 解析表达式                        |
| CheckUnusedVar | `func (p *Parser) CheckUnusedVar(node *Node)`                | 递归检查未使用的变量定义                 |

#### Token 分发方法

| 方法                  | 签名                                                                      | 说明                |
| ------------------- | ----------------------------------------------------------------------- | ----------------- |
| processFuncToken    | `func (p *Parser) processFuncToken(code lexer.Token)`                   | 处理函数关键字 Token     |
| processControlToken | `func (p *Parser) processControlToken(code lexer.Token)`                | 处理流程控制关键字 Token   |
| processNameToken    | `func (p *Parser) processNameToken(code lexer.Token, beforeCursor int)` | 处理标识符 Token       |
| processVarToken     | `func (p *Parser) processVarToken(beforeCursor int)`                    | 处理变量声明 Token      |
| processBuildToken   | `func (p *Parser) processBuildToken(token lexer.Token)`                 | 处理编译指令 Token      |
| processDefaultToken | `func (p *Parser) processDefaultToken(code lexer.Token)`                | 处理默认 Token（分号/换行） |
| fieldExpr           | `func (p *Parser) fieldExpr(name Name) *Expression`                     | 解析字段访问表达式         |

#### 符号查找方法

| 方法         | 签名                                                           | 说明      |
| ---------- | ------------------------------------------------------------ | ------- |
| FindVar    | `func (p *Parser) FindVar(name Name) (*Node, any)`           | 查找变量定义  |
| FindFunc   | `func (p *Parser) FindFunc(name Name) (*Node, *FuncBlock)`   | 查找函数定义  |
| FindStruct | `func (p *Parser) FindStruct(name Name) (*Node, *TypeBlock)` | 查找结构体定义 |
| FindType   | `func (p *Parser) FindType(name Name) (*Node, typeSys.Type)` | 查找类型定义  |
| FindGlobal | `func (p *Parser) FindGlobal(name Name) *Node`               | 查找全局定义  |

### 2.2 Name 类型

```go
type Name []string
```

表示点分路径名称，如 `["pkg", "module", "func"]`。

| 方法            | 签名                                                     | 说明                  |
| ------------- | ------------------------------------------------------ | ------------------- |
| String        | `func (n Name) String() string`                        | 返回 NASM 安全的点分连接形式   |
| Path          | `func (n Name) Path() string`                          | 返回路径部分（除最后一部分）      |
| Last          | `func (n Name) Last() string`                          | 返回最后一部分             |
| First         | `func (n Name) First() string`                         | 返回第一部分              |
| IsPrivate     | `func (n Name) IsPrivate() bool`                       | 是否包含下划线开头的私有部分      |
| Eq            | `func (n Name) Eq(other Name) bool`                    | 判断两个名称是否完全相等        |
| IsEmpty       | `func (n Name) IsEmpty() bool`                         | 判断名称是否为空            |
| IsPath        | `func (n Name) IsPath() bool`                          | 判断是否为多段路径           |
| Check         | `func (n Name) Check() bool`                           | 检查各部分是否均为有效标识符      |
| ReadFromToken | `func (n *Name) ReadFromToken(t lexer.Token) bool`     | 从 Token 读取名称        |
| Fork          | `func (n Name) Fork() Name`                            | 创建深拷贝               |
| MatchN        | `func (n Name) MatchN(name Name) int`                  | 模糊匹配前缀，返回匹配段数       |
| MatchT        | `func (n Name) MatchT(name Name, t typeSys.Type) bool` | 带类型匹配               |
| FixPath       | `func (n Name) FixPath(pkg *packageFmt.Info) bool`     | 将名称第一段替换为包导入的实际路径   |
| SetPkgPath    | `func (n Name) SetPkgPath(pkgPath string)`             | 在名称前添加包路径前缀         |
| Join          | `func (n *Name) Join(other ...string)`                 | 向名称追加更多段            |
| ForkJoin      | `func (n Name) ForkJoin(other ...string) Name`         | 创建拷贝后追加更多段          |
| Slice         | `func (n *Name) Slice(other Name)`                     | 裁切名称中匹配 other 的前缀部分 |
| ForkSlice     | `func (n Name) ForkSlice(other Name) Name`             | 创建拷贝后裁切匹配前缀         |

#### 构造函数

```go
func NewName(parts ...string) Name
```

从字符串列表创建 Name。

### 2.3 Node 结构体

AST 节点，构成树形结构。

```go
type Node struct {
    Value    Block     // 节点值（具体语法块）
    Father   *Node     // 父节点
    Children []*Node   // 子节点列表
    Ignore   bool      // 是否忽略（不编译）
    Checked  bool      // 是否已通过语义检查
    Parser   *Parser   // 所属解析器
}
```

| 方法       | 签名                                    | 说明           |
| -------- | ------------------------------------- | ------------ |
| AddChild | `func (n *Node) AddChild(node *Node)` | 添加子节点并建立父子关系 |
| Check    | `func (n *Node) Check() bool`         | 递归检查语义有效性    |

### 2.4 CFGNode 结构体

控制流图节点（预留，当前未启用）。

```go
type CFGNode struct {
    After     *Node
    Before    *Node
    Condition *Expression
}
```

### 2.5 Block 接口

```go
type Block interface {}
```

所有语法块的空接口，具体实现包括：`FuncBlock`, `VarBlock`, `CallBlock`, `IfBlock`, `ElseBlock`, `ForBlock`, `ReturnBlock`, `TypeBlock`, `Build`, `Expression`。

### 2.6 Checker 接口

```go
type Checker interface {
    Check(p *Parser) bool
}
```

语义检查接口，Node.Check() 会递归调用实现了此接口的节点。

### 2.7 Expression 结构体

表达式节点，支持运算符优先级解析（Pratt Parser）。

```go
type Expression struct {
    Call      *CallBlock     // 函数调用
    Num       float64        // 数值常量
    Separator string         // 运算符
    Right     *Expression    // 右操作数
    Left      *Expression    // 左操作数
    Father    *Expression    // 父表达式
    Var       *VarBlock      // 变量引用
    StringVal string         // 字符串常量值
    Bool      bool           // 布尔值
    ConstBool bool           // 是否为常量布尔
    Type      typeSys.Type   // 表达式类型
    Field     *Expression    // 字段访问
    ListElems []*Expression  // 列表字面量元素
    checked   bool           // 是否已检查
}
```

#### 运算符优先级表

| 优先级   | 运算符                                     | 结合性 |
| ----- | --------------------------------------- | --- |
| 1     | `= := += -= *= /= %= ^= &= \|= <<= >>=` | 右   |
| 2-3   | `\|\|`                                  | 左   |
| 4-5   | `&&`                                    | 左   |
| 6-7   | `== !=`                                 | 左   |
| 8-9   | `< > <= >=`                             | 左   |
| 10-11 | `\|`                                    | 左   |
| 12-13 | `^`                                     | 左   |
| 14-15 | `&`                                     | 左   |
| 16-17 | `<< >>`                                 | 左   |
| 18-19 | `+ -`                                   | 左   |
| 20-21 | `* / %`                                 | 左   |
| 24-25 | `. [`                                   | 左   |

前缀运算符优先级：`-` → 13, `!` → 13, `~` → 13

#### Expression 方法

| 方法      | 签名                                             | 说明                |
| ------- | ---------------------------------------------- | ----------------- |
| IsConst | `func (exp *Expression) IsConst() bool`        | 判断是否为编译期常量        |
| Check   | `func (exp *Expression) Check(p *Parser) bool` | 语义检查（类型推导、运算符合法性） |
| setVar  | `func (exp *Expression) setVar(v *VarBlock)`   | 设置关联变量            |

#### 运算符重载映射

```go
var opMethodMap = map[string]string{
    "+": "add", "-": "sub", "*": "mul", "/": "div", "%": "mod",
    "^": "pow", "==": "eq", "!=": "ne", "<": "lt", ">": "gt",
    "<=": "le", ">=": "ge", "&": "band", "|": "bor",
    "<<": "shl", ">>": "shr", "[]": "get", "[]=": "set", "[::]": "slice",
}

var unaryOpMethodMap = map[string]string{
    "-": "neg", "!": "not", "~": "bnot",
}
```

### 2.8 FuncBlock 结构体

函数定义块。

```go
type FuncBlock struct {
    Args       []*ArgBlock    // 函数参数列表
    Class      typeSys.Type   // 所属类类型（方法）
    Return     []typeSys.Type // 返回值类型列表
    Name       Name           // 函数名
    BuildFlags []*Build       // 编译标志
    Useful     bool           // 是否有用（优化标记）
}
```

| 方法           | 签名                                            | 说明     |
| ------------ | --------------------------------------------- | ------ |
| Parse        | `func (f *FuncBlock) Parse(p *Parser)`        | 解析函数定义 |
| ParseArgs    | `func (f *FuncBlock) ParseArgs(p *Parser)`    | 解析参数列表 |
| ParseRetType | `func (f *FuncBlock) ParseRetType(p *Parser)` | 解析返回类型 |

### 2.9 ArgBlock 结构体

函数参数块。

```go
type ArgBlock struct {
    Name    Name         // 参数名
    Type    typeSys.Type // 参数类型
    Default *Expression  // 默认值表达式
    Defind  *ArgBlock    // 指向参数定义（类型检查用）
    Value   *Expression  // 实际传入值
    Offset  int          // 栈中偏移量
}
```

| 方法    | 签名                                         | 说明      |
| ----- | ------------------------------------------ | ------- |
| Check | `func (f *ArgBlock) Check(p *Parser) bool` | 检查参数有效性 |

### 2.10 VarBlock 结构体

变量声明/定义块。

```go
type VarBlock struct {
    Name          Name         // 变量名（支持路径形式）
    IsConst       bool         // 是否为常量
    Value         *Expression  // 值表达式
    IsDefine      bool         // 是否为定义（:=）
    IsInitialized bool         // 是否已初始化
    Define        *Node        // 指向定义该变量的 AST 节点
    Used          bool         // 是否已被使用
    StartCursor   int          // 源码起始位置
    Offset        int          // 栈帧偏移量
    Type          typeSys.Type // 数据类型
}
```

| 方法              | 签名                                                                                | 说明                      |
| --------------- | --------------------------------------------------------------------------------- | ----------------------- |
| Parse           | `func (v *VarBlock) Parse(p *Parser)`                                             | 解析变量声明/定义               |
| ParseVar        | `func (v *VarBlock) ParseVar(p *Parser)`                                          | 根据下一个 Token 选择解析方式      |
| ParseNameVar    | `func (v *VarBlock) ParseNameVar(p *Parser, code lexer.Token, stopCursor int)`    | 解析普通变量声明                |
| ParseKeywordVar | `func (v *VarBlock) ParseKeywordVar(p *Parser, code lexer.Token, stopCursor int)` | 解析带关键字声明（var/const/let） |
| ParseDefine     | `func (v *VarBlock) ParseDefine(p *Parser) bool`                                  | 查找变量定义位置                |
| Check           | `func (v *VarBlock) Check(p *Parser) bool`                                        | 类型检查                    |

### 2.11 CallBlock 结构体

函数调用块。

```go
type CallBlock struct {
    Name    Name         // 函数名
    Args    []*ArgBlock  // 参数列表
    Func    *FuncBlock   // 关联的函数定义
    Node    *Node        // 关联的 AST 节点
    ThisVar *VarBlock    // this 指针变量（方法调用时）
}
```

| 方法        | 签名                                          | 说明        |
| --------- | ------------------------------------------- | --------- |
| Parse     | `func (c *CallBlock) Parse(p *Parser)`      | 解析函数调用    |
| ParseCall | `func (c *CallBlock) ParseCall(p *Parser)`  | 解析调用参数    |
| Check     | `func (c *CallBlock) Check(p *Parser) bool` | 检查参数数量和类型 |

### 2.12 IfBlock / ElseBlock 结构体

条件控制块。

```go
type IfBlock struct {
    ElseBlock *Node       // else 块节点
    Else      bool        // 是否有 else
    Condition *Expression // 条件表达式
}

type ElseBlock struct {
    IfCondition *Expression // else if 条件
}
```

| 方法              | 签名                                        | 说明          |
| --------------- | ----------------------------------------- | ----------- |
| IfBlock.Parse   | `func (i *IfBlock) Parse(p *Parser)`      | 解析 if 块     |
| IfBlock.Check   | `func (i *IfBlock) Check(p *Parser) bool` | 检查条件是否为布尔类型 |
| ElseBlock.Parse | `func (e *ElseBlock) Parse(p *Parser)`    | 解析 else 块   |

### 2.13 ForBlock 结构体

循环控制块。

```go
type ForBlock struct {
    Init      *Expression // 初始化表达式
    Condition *Expression // 循环条件
    Increment *Expression // 增量表达式
    Offset    int         // 标签偏移
}
```

| 方法    | 签名                                         | 说明          |
| ----- | ------------------------------------------ | ----------- |
| Parse | `func (f *ForBlock) Parse(p *Parser)`      | 解析 for 循环   |
| Check | `func (f *ForBlock) Check(p *Parser) bool` | 检查条件是否为布尔类型 |

### 2.14 ReturnBlock 结构体

返回语句块。

```go
type ReturnBlock struct {
    Value []*Expression // 返回值列表（支持多返回值）
}
```

| 方法    | 签名                                            | 说明           |
| ----- | --------------------------------------------- | ------------ |
| Parse | `func (r *ReturnBlock) Parse(p *Parser)`      | 解析 return 语句 |
| Check | `func (r *ReturnBlock) Check(p *Parser) bool` | 检查返回值有效性     |

### 2.15 TypeBlock 结构体

类型定义块。

```go
type TypeKind int

const (
    TypeAlias     TypeKind = iota  // 类型别名
    TypeStruct                     // 结构体
    TypeInterface                  // 接口
)

type TypeBlock struct {
    Name        Name         // 类型名
    Kind        TypeKind     // 类型种类
    Struct      *StructBlock // 结构体定义
    Interface   *InterfaceDef // 接口定义
    Alias       typeSys.Type // 别名指向的类型
    StartCursor int          // 起始位置
    EndCursor   int          // 结束位置
}
```

| 方法    | 签名                                          | 说明         |
| ----- | ------------------------------------------- | ---------- |
| Parse | `func (t *TypeBlock) Parse(p *Parser)`      | 解析类型定义     |
| Check | `func (t *TypeBlock) Check(p *Parser) bool` | 检查类型（布局计算） |
| Type  | `func (t *TypeBlock) Type() typeSys.Type`   | 返回类型对象     |

### 2.16 StructBlock 结构体

结构体定义块。

```go
type StructBlock struct {
    Type      typeSys.StructType // 结构体类型
    EndCursor int                // 结束位置
}
```

| 方法    | 签名                                       | 说明      |
| ----- | ---------------------------------------- | ------- |
| Parse | `func (s *StructBlock) Parse(p *Parser)` | 解析结构体定义 |

支持的字段访问修饰符：

- `!` → ReadOnly（只读）
- `?` → WriteOnly（只写）
- `_` 前缀 → Private（私有）
- 默认 → Public（公开）

支持匿名嵌入：`@ ParentName`
支持命名嵌入：`alias @ ParentName`
支持标签：反引号 `` ` `` 包裹的结构体标签

### 2.17 InterfaceDef 结构体

接口定义块。

```go
type InterfaceMethod struct {
    Name    Name           // 方法名
    Args    []*ArgBlock    // 参数列表
    Returns []typeSys.Type // 返回类型列表
}

type InterfaceDef struct {
    Methods   []InterfaceMethod // 方法列表
    EndCursor int               // 结束位置
}
```

| 方法    | 签名                                        | 说明     |
| ----- | ----------------------------------------- | ------ |
| Parse | `func (i *InterfaceDef) Parse(p *Parser)` | 解析接口定义 |

### 2.18 Build 结构体

编译指令块。

```go
type Build struct {
    Type         string               // 指令类型
    Asm          string               // 内联汇编代码
    Ext          string               // 外部函数声明
    ExtRet       string               // 外部函数返回声明
    UseMoreStack bool                 // 是否使用更多栈空间
    OS           []string             // 目标操作系统列表
    Ignore       bool                 // 是否忽略（OS 不匹配时）
    Link         string               // 链接名称
    VarMap       map[string]*VarBlock // 变量名到 VarBlock 的映射
}
```

| 指令类型     | 说明                    |
| -------- | --------------------- |
| `asm`    | 内联汇编，支持 `$变量名` 替换为栈地址 |
| `ext`    | 外部函数声明（如 C 函数）        |
| `extret` | 外部函数返回声明              |
| `os`     | 条件编译，指定目标操作系统         |
| `link`   | 指定链接名称                |

| 方法    | 签名                                 | 说明     |
| ----- | ---------------------------------- | ------ |
| Parse | `func (b *Build) Parse(p *Parser)` | 解析编译指令 |

***

## 3. 类型系统 `typeSys`

**包路径**: `cuteify/type`

**文件**: `type/type.go`, `type/struct.go`

### 3.1 Type 接口

所有类型的根接口。

```go
type Type interface {
    Type() string          // 返回类型名称字符串
    String() string        // 返回字符串表示
    Fields() StructFileds  // 返回结构体字段（非结构体返回 nil）
    Set(interface{})       // 设置类型名
    Size() int             // 返回类型大小（字节）
    Parent() Type          // 返回父类型
    IsPointer() bool       // 是否为指针类型
    Alignment() int        // 返回对齐要求
}
```

### 3.2 RType 基础类型

```go
type RType struct {
    TypeName   string  // 类型名称
    RSize      int     // 类型大小
    RParent    Type    // 父类型
    IsPtr      bool    // 是否为指针
    RAlignment int     // 对齐要求
}
```

#### RType 方法

| 方法        | 签名                                      | 说明                                                  |
| --------- | --------------------------------------- | --------------------------------------------------- |
| Type      | `func (r RType) Type() string`          | 返回类型名称                                              |
| Size      | `func (r RType) Size() int`             | 返回类型大小（根据 TargetPointerSize 动态计算 int/uint/string）   |
| String    | `func (r RType) String() string`        | 返回类型名称字符串                                           |
| Fields    | `func (r *RType) Fields() StructFileds` | 返回 nil（非结构体）                                        |
| Set       | `func (r *RType) Set(name any)`         | 设置类型名                                               |
| Parent    | `func (r *RType) Parent() Type`         | 返回父类型                                               |
| IsPointer | `func (r *RType) IsPointer() bool`      | 是否为指针                                               |
| Alignment | `func (r RType) Alignment() int`        | 返回对齐要求（默认为类型大小，int/uint/string 为 TargetPointerSize） |

### 3.3 内置类型

| 类型名      | Go 类型         | 大小（32位） | 大小（64位） | 类别       |
| -------- | ------------- | ------- | ------- | -------- |
| `int`    | `IntType`     | 4       | 8       | 整数       |
| `uint`   | `UintType`    | 4       | 8       | 无符号整数    |
| `i64`    | `Int64Type`   | 8       | 8       | 64位整数    |
| `u64`    | `Uint64Type`  | 8       | 8       | 64位无符号整数 |
| `i32`    | `Int32Type`   | 4       | 4       | 32位整数    |
| `u32`    | `Uint32Type`  | 4       | 4       | 32位无符号整数 |
| `i16`    | `Int16Type`   | 2       | 2       | 16位整数    |
| `u16`    | `Uint16Type`  | 2       | 2       | 16位无符号整数 |
| `i8`     | `Int8Type`    | 1       | 1       | 8位整数     |
| `u8`     | `Uint8Type`   | 1       | 1       | 8位无符号整数  |
| `bool`   | `BoolType`    | 1       | 1       | 布尔       |
| `byte`   | `ByteType`    | 1       | 1       | 字节       |
| `f32`    | `Float32Type` | 4       | 4       | 32位浮点    |
| `f64`    | `Float64Type` | 8       | 8       | 64位浮点    |
| `string` | `StringType`  | 12      | 24      | 字符串      |

### 3.4 ListType 列表类型

```go
type ListType struct {
    RType
    Elem Type  // 元素类型
}
```

| 方法        | 签名                                         | 说明                      |
| --------- | ------------------------------------------ | ----------------------- |
| Size      | `func (l *ListType) Size() int`            | 32位→12字节，64位→24字节       |
| Alignment | `func (l *ListType) Alignment() int`       | 返回 TargetPointerSize    |
| String    | `func (l *ListType) String() string`       | 返回 `lists.[]<elemType>` |
| Fields    | `func (l *ListType) Fields() StructFileds` | 返回 nil                  |

列表内部布局：

- 32位：`[ptr:4][len:4][cap:4]` = 12字节
- 64位：`[ptr:8][len:8][cap:8]` = 24字节

### 3.5 StructType 结构体类型

```go
type StructType struct {
    RType
    StructFields StructFileds  // 字段列表
    Methods      []any         // 方法列表
}
```

| 方法        | 签名                                                            | 说明                |
| --------- | ------------------------------------------------------------- | ----------------- |
| Fields    | `func (s *StructType) Fields() StructFileds`                  | 返回字段列表            |
| String    | `func (s *StructType) String() string`                        | 返回类型名称            |
| Size      | `func (s *StructType) Size() int`                             | 返回类型大小            |
| Alignment | `func (s *StructType) Alignment() int`                        | 返回对齐要求            |
| Layout    | `func (s *StructType) Layout()`                               | 计算字段布局（偏移量、对齐、大小） |
| Field     | `func (s *StructType) Field(name string) *StructField`        | 按名称查找字段           |
| Inherit   | `func (s *StructType) Inherit(find func(string) *StructType)` | 处理继承/嵌入           |

### 3.6 StructField 结构体字段

```go
type FieldAccess int

const (
    AccessPublic    FieldAccess = iota  // 公开
    AccessPrivate                       // 私有
    AccessProtected                     // 保护
    AccessReadOnly                      // 只读
    AccessWriteOnly                     // 只写
)

type StructTag struct {
    Key   string
    Value string
}

type StructField struct {
    Name       string        // 字段名
    Type       Type          // 字段类型
    Default    any           // 默认值
    Tags       []StructTag   // 标签
    Offset     int           // 偏移量
    Size       int           // 大小
    Alignment  int           // 对齐
    Access     FieldAccess   // 访问级别
    Alias      string        // 别名（命名嵌入）
    ParentName string        // 父类型名（嵌入）
    IsAnon     bool          // 是否匿名嵌入
}
```

| 方法          | 签名                                             | 说明      |
| ----------- | ---------------------------------------------- | ------- |
| IsPrivate   | `func (f *StructField) IsPrivate() bool`       | 是否私有    |
| IsReadOnly  | `func (f *StructField) IsReadOnly() bool`      | 是否只读    |
| IsWriteOnly | `func (f *StructField) IsWriteOnly() bool`     | 是否只写    |
| IsPublic    | `func (f *StructField) IsPublic() bool`        | 是否公开    |
| CanRead     | `func (f *StructField) CanRead() bool`         | 是否可读    |
| CanWrite    | `func (f *StructField) CanWrite() bool`        | 是否可写    |
| ParseTags   | `func (f *StructField) ParseTags(tags string)` | 解析标签字符串 |

### 3.7 类型系统工具函数

| 函数                   | 签名                                                     | 说明                                                   |
| -------------------- | ------------------------------------------------------ | ---------------------------------------------------- |
| GetSystemType        | `func GetSystemType(name string) Type`                 | 按名称获取内置类型（支持 `[]T` 列表语法）                             |
| GetListType          | `func GetListType(elem Type) *ListType`                | 创建列表类型                                               |
| GetKind          | `func GetKind(t Type) string`                      | 获取类型类别（int/uint/float/bool/byte/string/list/unknown） |
| CheckType            | `func CheckType(t Type, allows ...Type) bool`          | 检查类型是否在允许列表中                                         |
| CheckKind        | `func CheckKind(t Type, allows ...string) bool`    | 按类别检查类型                                              |
| AutoType             | `func AutoType(before, after Type, IsConst bool) bool` | 自动类型兼容性检查                                            |
| SetTargetPointerSize | `func SetTargetPointerSize(size int)`                  | 设置目标平台指针大小                                           |
| ToRType              | `func ToRType(t Type) *RType`                          | 通过 unsafe 获取 Type 底层的 RType 指针                       |

### 3.8 全局变量

| 变量                | 类型    | 说明                                      |
| ----------------- | ----- | --------------------------------------- |
| TargetPointerSize | `int` | 目标平台指针大小（默认4，由 SetTargetPointerSize 设置） |

***

## 4. 错误处理 `errorUtil`

**包路径**: `cuteify/error`

**文件**: `error/error.go`

### 4.1 Error 结构体

```go
type Error struct {
    Text     string  // 源代码文本
    Path     string  // 文件路径
    LineFeed string  // 换行符
}
```

### 4.2 Error 方法

| 方法         | 签名                                                                       | 说明                        |
| ---------- | ------------------------------------------------------------------------ | ------------------------- |
| GetErrPos  | `func (e *Error) GetErrPos(start, end int) string`                       | 生成错误位置信息（行号、列号、代码片段、红色标记） |
| MissError  | `func (e *Error) MissError(errType string, cursor int, msg string)`      | 报告错误并终止编译（panic）          |
| MissErrors | `func (e *Error) MissErrors(errType string, start, end int, msg string)` | 报告范围错误并终止编译               |
| Warning    | `func (e *Error) Warning(msg string)`                                    | 输出警告信息（不终止）               |
| STOP       | `func (e *Error) STOP()`                                                 | 未知错误终止                    |

### 4.3 全局错误映射

```go
var Errors = map[string]*Error{}

func NewError(path, text, linefeed string) *Error
```

每个源文件对应一个 Error 实例，通过文件路径索引。

***

## 5. 包管理 `packageSys`

**包路径**: `cuteify/package`

**文件**: `package/package.go`

### 5.1 GetPackage 函数

```go
func GetPackage(packagePath string, isRoot bool) (*packageFmt.Info, error)
```

递归加载包及其依赖。对于根包，合并所有依赖包的 AST。

参数说明：

- `packagePath`: 包目录路径
- `isRoot`: 是否为根包（根包会合并所有依赖的 AST 并执行语义检查）
- 返回: 包信息和可能的错误

### 5.2 All 结构体

```go
type All struct {
    Funcs map[string]*parser.Node  // 全局函数映射
    Types map[string]*parser.Node  // 全局类型映射
}
```

### 5.3 全局变量

| 变量       | 类型                            | 说明         |
| -------- | ----------------------------- | ---------- |
| packages | `map[string]*packageFmt.Info` | 已加载包的缓存映射  |
| all      | `*All`                        | 全局函数和类型收集器 |

### 5.4 Info 结构体（package/fmt）

**包路径**: `cuteify/package/fmt`

**文件**: `package/fmt/fmt.go`

```go
type Info struct {
    Version string            `json:"version"`  // 包版本
    Imports map[string]string `json:"imports"`  // 依赖映射（别名→路径）
    Action  map[string]string `json:"action"`   // 构建动作
    Path    string                               // 包路径
    AST     any                                  // AST 根节点（*parser.Node）
}
```

### 5.5 FixPathName 函数

```go
func FixPathName(path string) string
```

将路径转换为合法标识符（替换反斜杠为斜杠、空格/冒号为下划线、非 ASCII 字符为下划线）。

***

## 6. 工具函数 `utils`

**包路径**: `cuteify/utils`

**文件**: `utils/utils.go`

### 6.1 全局变量

| 变量      | 类型    | 说明                     |
| ------- | ----- | ---------------------- |
| Count   | `int` | 全局缩进级别控制（用于 Format 函数） |
| LineNum | `int` | 全局行号计数                 |

### 6.2 工具函数

| 函数               | 签名                                          | 说明                                            |
| ---------------- | ------------------------------------------- | --------------------------------------------- |
| CheckName        | `func CheckName(name string) bool`          | 检查标识符合法性（字母/下划线开头，字母数字下划线组成）                  |
| ToNASMName       | `func ToNASMName(name string) string`       | 转换为 NASM 兼容标签名（系统包→std\_前缀，中文→\_u{码点}）        |
| Format           | `func Format(text string) string`           | 格式化汇编代码行（带缩进，全局 Count 控制层级）                   |
| GetLengthName    | `func GetLengthName(size int) string`       | 返回大小对应的汇编前缀（1→BYTE, 2→WORD, 4→DWORD, 8→QWORD） |
| sanitizeNASMName | `func sanitizeNASMName(name string) string` | 清理 NASM 标签中的非法字符（内部函数）                        |

***

# 第二部分：后端

后端负责将 AST 转换为目标架构的汇编代码，包括编译器核心、架构接口、调用约定、寄存器管理和编译上下文五个核心模块。

***

## 7. 编译器核心 `compile`

**包路径**: `cuteify/compile`

**文件**: `compile/compiler.go`, `compile/build.go`, `compile/utils.go`

### 7.1 Compiler 结构体

```go
type Compiler struct {
    Ctx *context.Context  // 编译器上下文
}
```

#### 构造函数

```go
func NewCompiler(parser *parser.Parser) *Compiler
```

#### 核心方法

```go
func (c *Compiler) Compile(node *parser.Node) string
```

编译入口方法，将 AST 节点编译为汇编代码。流程：

1. 初始化上下文和架构
2. 输出 `.text` 段头
3. 递归编译所有子节点
4. 生成 `_start` 入口代码和数据段

#### 内部编译方法

| 方法                  | 签名                                                                                     | 说明                                           |
| ------------------- | -------------------------------------------------------------------------------------- | -------------------------------------------- |
| initializeContext   | `func (c *Compiler) initializeContext()`                                               | 初始化上下文和架构                                    |
| compileRoot         | `func (c *Compiler) compileRoot(node *parser.Node, code string) string`                | 编译根节点（输出段头）                                  |
| compileChildren     | `func (c *Compiler) compileChildren(node *parser.Node, code string) string`            | 递归编译子节点                                      |
| compileChild        | `func (c *Compiler) compileChild(n *parser.Node) string`                               | 根据 AST 节点类型分发编译                              |
| compileRootTail     | `func (c *Compiler) compileRootTail(node *parser.Node) string`                         | 编译根节点尾部（入口代码和数据段）                            |
| generateDataSection | `func (c *Compiler) generateDataSection() string`                                      | 生成 `.data` 段（字符串常量池）                         |
| hasMainFunction     | `func (c *Compiler) hasMainFunction(node *parser.Node) bool`                           | 检查是否存在 main 函数                               |
| generateStartEntry  | `func (c *Compiler) generateStartEntry() string`                                       | 生成 `_start` 入口代码（32位用 int 0x80，64位用 syscall） |
| funcHandle          | `func (c *Compiler) funcHandle(funcBlock *parser.FuncBlock, node *parser.Node) string` | 编译函数体（含序言、子节点、尾声）                            |

#### 节点编译分发

| AST 节点类型       | 编译方法                 | 说明        |
| -------------- | -------------------- | --------- |
| `*FuncBlock`   | `compileFuncBlock`   | 编译函数定义    |
| `*IfBlock`     | `compileIfBlock`     | 编译条件语句    |
| `*ReturnBlock` | `compileReturnBlock` | 编译返回语句    |
| `*VarBlock`    | `compileVarBlock`    | 编译变量声明/赋值 |
| `*CallBlock`   | `compileCallBlock`   | 编译函数调用    |
| `*Expression`  | `compileExprBlock`   | 编译表达式语句   |
| `*ForBlock`    | `compileForBlock`    | 编译循环语句    |
| `*TypeBlock`   | `compileTypeBlock`   | 类型定义（跳过）  |
| `*Build`       | `CompileBuild`       | 编译编译指令    |

### 7.2 CompileBuild 方法

```go
func (c *Compiler) CompileBuild(n *parser.Node) string
```

处理内联汇编指令，将 `$变量名` 替换为实际栈地址（`DWORD[ebp+N]`）。

### 7.3 全局变量

| 变量     | 类型       | 说明                                        |
| ------ | -------- | ----------------------------------------- |
| GoArch | `string` | 目标架构名称（默认 `"x86"`，可通过 `CUTE_ARCH` 环境变量设置） |

### 7.4 init 函数

```go
func init() {
    if v := os.Getenv("CUTE_ARCH"); v != "" {
        GoArch = v
    }
}
```

### 7.5 NewArch 架构选择器

```go
func NewArch(archName string, ctx *context.Context) arch.Arch
```

| 架构名            | 返回类型            | PointerSize | 说明                      |
| -------------- | --------------- | ----------- | ----------------------- |
| `x86` (默认)     | `*x86.Cdecl`    | 4           | x86 32位 cdecl           |
| `x86.cdecl`    | `*x86.Cdecl`    | 4           | x86 32位 cdecl           |
| `x86.stdcall`  | `*x86.Stdcall`  | 4           | x86 32位 stdcall         |
| `x86.fastcall` | `*x86.Fastcall` | 4           | x86 32位 fastcall        |
| `x86.sysv`     | `*x86.SysV`     | 8           | x86 包的 64位 System V ABI |
| `x86.win64`    | `*x86.Win64`    | 8           | x86 包的 64位 Win64 ABI    |
| `x86_64`       | `*x86_64.SysV`  | 8           | x86\_64 原生 System V ABI |
| `x86_64.sysv`  | `*x86_64.SysV`  | 8           | x86\_64 原生 System V ABI |
| `x86_64.win64` | `*x86_64.Win64` | 8           | x86\_64 原生 Win64 ABI    |

选择架构时会自动调用 `typeSys.SetTargetPointerSize()` 设置指针大小。

***

## 8. 架构接口 `arch.Arch`

**包路径**: `cuteify/compile/arch`

**文件**: `compile/arch/arch.go`

### 8.1 Arch 接口定义

```go
type Arch interface {
    Info() string
    Call(call *parser.CallBlock) string
    Return(ret *parser.ReturnBlock) string
    Func(funcBlock *parser.FuncBlock) string
    Exp(exp *parser.Expression, result, desc string) string
    For(forBlock *parser.ForBlock) string
    EndFor(forBlock *parser.ForBlock) string
    Var(varBlock *parser.VarBlock) string
    GenVarAddr(v *parser.VarBlock) string
}
```

| 方法                                             | 说明                                 |
| ---------------------------------------------- | ---------------------------------- |
| `Info() string`                                | 返回架构信息描述字符串                        |
| `Call(*CallBlock) string`                      | 生成函数调用汇编代码（含参数设置、寄存器保存、call、清理）    |
| `Return(*ReturnBlock) string`                  | 生成函数返回汇编代码（含返回值设置、栈恢复、ret）         |
| `Func(*FuncBlock) string`                      | 生成函数序言汇编代码（含参数偏移设置、push ebp、栈空间分配） |
| `Exp(*Expression, result, desc string) string` | 编译表达式到指定目标位置                       |
| `For(*ForBlock) string`                        | 生成 for 循环起始汇编代码                    |
| `EndFor(*ForBlock) string`                     | 生成 for 循环结束汇编代码                    |
| `Var(*VarBlock) string`                        | 生成变量赋值汇编代码                         |
| `GenVarAddr(*VarBlock) string`                 | 计算变量在栈帧中的地址表达式                     |

### 8.2 ExpResult 结构体

```go
type ExpResult struct {
    Reg       *regmgr.Reg  // 寄存器结果
    MemOffset int          // 内存偏移量
}
```

### 8.3 架构辅助函数

| 函数                  | 签名                                                                       | 说明                       |
| ------------------- | ------------------------------------------------------------------------ | ------------------------ |
| CalcArgsSize        | `func CalcArgsSize(funcBlock *parser.FuncBlock) int`                     | 计算函数参数的栈空间总大小            |
| GetNeedSaveRegs     | `func GetNeedSaveRegs(regMgr *regmgr.RegMgr, callerSave bool) []string`  | 获取需要保存的寄存器列表             |
| SetupVarOffsets     | `func SetupVarOffsets(funcNode *parser.Node, alignment, offset int) int` | 设置函数中所有变量的栈偏移量，返回对齐后的栈大小 |
| ResetLocalVarOffset | `func ResetLocalVarOffset(n *parser.Node, offset int)`                   | 递归调整变量偏移量                |
| collectVarOffsets   | `func collectVarOffsets(node *parser.Node, offset *int)`                 | 递归收集并设置所有变量的偏移量（内部函数）    |

***

## 9. 调用约定实现

### 9.1 x86 32位调用约定

#### 9.1.1 cdecl（`compile/arch/x86/cdecl.go`）

```go
type Cdecl struct {
    ctx *context.Context
}

func NewCdecl(ctx *context.Context) *Cdecl
```

**特点**：

- 参数全部通过栈传递（从右到左压栈）
- 调用者清理参数栈（`add esp, N`）
- 返回值：32位→EAX，64位→EDX:EAX
- 寄存器集：EAX, EBX(callee-save), ECX, EDX
- 参数偏移起始：\[ebp+8]（有 this 指针时 \[ebp+12]）
- 构造时自动创建 RegMgr 并绑定到 ctx.Reg

**Call 方法流程**：

1. 检查列表内置方法（len/cap/ptr）→ 直接读取字段
2. 保存 caller-saved 寄存器
3. 压入 this 指针（如果有）
4. 从右到左压入参数（64位参数压入高低32位）
5. 执行 `call`
6. 清理参数栈（`add esp, N`）

**Return 方法流程**：

1. 将返回值存入 EAX（32位）或 EDX:EAX（64位）
2. 清理局部变量栈空间
3. 恢复 callee-saved 寄存器
4. `leave` + `ret`

**Func 方法流程**：

1. 设置参数偏移量（从 \[ebp+8] 开始）
2. `push ebp` + `mov ebp, esp`
3. 保存 callee-saved 寄存器
4. 计算并分配局部变量栈空间
5. `sub esp, N`

**Var 方法**：

- 64位类型：分别编译低32位和高32位到 genLoAddr/genHiAddr
- 32位类型：编译值到 genVarAddr 地址

#### 9.1.2 stdcall（`compile/arch/x86/stdcall.go`）

```go
type Stdcall struct {
    ctx *context.Context
}

func NewStdcall(ctx *context.Context) *Stdcall
```

**特点**：

- 参数全部通过栈传递（从右到左压栈）
- 被调用者清理参数栈（`ret N`）
- 返回值：32位→EAX，64位→EDX:EAX
- 寄存器集：EAX, EBX(callee-save), ECX, EDX
- 与 cdecl 的区别：Return 方法使用 `ret N` 而非 `ret`，Call 方法不清理参数栈

#### 9.1.3 fastcall（`compile/arch/x86/fastcall.go`）

```go
type Fastcall struct {
    ctx *context.Context
}

func NewFastcall(ctx *context.Context) *Fastcall
```

**特点**：

- 前2个32位参数通过寄存器传递（ECX, EDX）
- 其余参数通过栈传递（从右到左压栈）
- 调用者清理压栈参数
- 返回值：32位→EAX，64位→EDX:EAX
- 寄存器集：EAX, EBX(callee-save), ECX, EDX

**Call 方法特殊逻辑**：

1. 判断前2个参数是否为32位（`arg.Type.Size() == 4`），标记为寄存器参数
2. 先压入栈参数（从右到左）
3. 再设置寄存器参数（ECX, EDX）
4. 调用后只清理压栈参数部分

### 9.2 x86 包的 64位调用约定

#### 9.2.1 System V AMD64 ABI（`compile/arch/x86/linux_sysv.go`）

```go
var sysvArgRegs = []string{"RDI", "RSI", "RDX", "RCX", "R8", "R9"}

type SysV struct {
    ctx *context.Context
}

func NewSysV(ctx *context.Context) *SysV
```

**特点**：

- 前6个参数通过寄存器传递：RDI, RSI, RDX, RCX, R8, R9
- 其余参数通过栈传递
- 栈对齐：16字节
- 返回值：RAX
- 寄存器集：RAX, RBX(callee), RCX, RDX, RSI, RDI, R8-R11, R12-R15(callee)
- 表达式编译委托给 `x86_64.NewExpCom`
- 构造时设置 ctx.PointerSize=8, ctx.Is64Bit=true, ctx.StackAlignment=16

**Call 方法特殊逻辑**：

1. 栈参数数量为奇数时，先 `sub rsp, 8` 对齐
2. 先压入栈参数（从右到左）
3. 再设置寄存器参数
4. 调用后清理栈参数（含对齐填充）

**Func 方法**：

- 参数偏移从 \[rbp+16] 开始
- callee-saved 寄存器：RBX, R12-R15

#### 9.2.2 Microsoft x64 ABI（`compile/arch/x86/ms_win64.go`）

```go
var win64ArgRegs = []string{"RCX", "RDX", "R8", "R9"}
var win64CalleeSaved = []string{"RDI", "RSI", "RBX", "R12", "R13", "R14", "R15"}

type Win64 struct {
    ctx *context.Context
}

func NewWin64(ctx *context.Context) *Win64
```

**特点**：

- 前4个参数通过寄存器传递：RCX, RDX, R8, R9
- 调用者必须分配 32 字节 shadow space
- 其余参数通过栈传递
- 栈对齐：16字节
- 返回值：RAX
- callee-save：RDI, RSI, RBX, R12-R15
- 表达式编译委托给 `x86_64.NewExpCom`

**Call 方法特殊逻辑**：

1. 先压入栈参数（从右到左，argIdx >= 4 的参数）
2. `sub rsp, 32` 分配 shadow space
3. 设置 this 指针到 RCX（如果有）
4. 设置寄存器参数
5. 调用后清理 shadow space + 栈参数

**Func 方法特殊逻辑**：

- 保存所有 win64CalleeSaved 寄存器
- 栈大小额外加 32（shadow space）
- 栈大小按 16 字节对齐

### 9.3 x86\_64 原生调用约定

#### 9.3.1 System V AMD64 ABI（`compile/arch/x86_64/linux_sysv.go`）

```go
var sysvArgRegs = []string{"RDI", "RSI", "RDX", "RCX", "R8", "R9"}

type SysV struct {
    ctx *context.Context
}

func NewSysV(ctx *context.Context) *SysV
```

与 x86 包的 SysV 实现相同，但使用 x86\_64 包原生的表达式编译器（`ExpCom`）和工具函数。

#### 9.3.2 Microsoft x64 ABI（`compile/arch/x86_64/ms_win64.go`）

```go
var win64ArgRegs = []string{"RCX", "RDX", "R8", "R9"}
var win64CalleeSaved = []string{"RDI", "RSI", "RBX", "R12", "R13", "R14", "R15"}

type Win64 struct {
    ctx *context.Context
}

func NewWin64(ctx *context.Context) *Win64
```

与 x86 包的 Win64 实现相同，但使用 x86\_64 包原生的表达式编译器和工具函数。

***

## 10. 寄存器管理 `regmgr`

**包路径**: `cuteify/compile/regmgr`

**文件**: `compile/regmgr/regmgr.go`

### 10.1 RegMgr 结构体

```go
type RegMgr struct {
    Record     map[*parser.Expression]*Reg  // 寄存器分配记录
    Regs       []*Reg                       // 寄存器状态数组
    RegCount   int                          // 已分配寄存器数量
    index      int                          // 分配索引（LRU）
    totalReg   int                          // 总寄存器数量
    genVarAddr func(varBlock *parser.VarBlock) string  // 变量地址生成函数
}
```

#### 构造函数

```go
func NewRegMgr(regs []*Reg, genVarAddr func(varBlock *parser.VarBlock) string) *RegMgr
```

#### 核心方法

| 方法          | 签名                                                                                        | 说明                  |
| ----------- | ----------------------------------------------------------------------------------------- | ------------------- |
| Get         | `func (rm *RegMgr) Get(n *parser.Node, exp *parser.Expression, needCalleeSave bool) *Reg` | 为表达式分配寄存器（LRU 策略）   |
| Force       | `func (rm *RegMgr) Force(reg *Reg, n *parser.Node, exp *parser.Expression) *Reg`          | 强制分配指定寄存器（溢出当前占用者）  |
| Free        | `func (rm *RegMgr) Free(exp *parser.Expression)`                                          | 释放表达式占用的寄存器         |
| Reuse       | `func (rm *RegMgr) Reuse(n *parser.Node) *Reg`                                            | 重用节点关联的寄存器          |
| Save        | `func (rm *RegMgr) Save(exp *parser.Expression) string`                                   | 生成溢出代码并释放           |
| SaveAll     | `func (rm *RegMgr) SaveAll(calleeSave bool) []string`                                     | 批量保存指定类型的寄存器        |
| Reset       | `func (rm *RegMgr) Reset()`                                                               | 重置所有寄存器状态           |
| GetRegUsage | `func (rm *RegMgr) GetRegUsage() (int, int, int)`                                         | 获取寄存器使用情况（已用、总数、索引） |

#### 内部方法

| 方法            | 签名                                                                                             | 说明              |
| ------------- | ---------------------------------------------------------------------------------------------- | --------------- |
| allocate      | `func (rm *RegMgr) allocate(n *parser.Node, exp *parser.Expression, needCalleeSave bool) *Reg` | 尝试分配空闲寄存器       |
| calcSpillCost | `func (rm *RegMgr) calcSpillCost(reg *Reg, needCalleeSave bool) int`                           | 计算溢出代价          |
| spillReg      | `func (rm *RegMgr) spillReg(n *parser.Node, exp *parser.Expression, needCalleeSave bool) *Reg` | 溢出代价最低的寄存器      |
| genSpill      | `func (rm *RegMgr) genSpill(reg *Reg) string`                                                  | 生成溢出代码（NASM 格式） |
| calcUsingReg  | `func (rm *RegMgr) calcUsingReg()`                                                             | 更新寄存器计数         |

### 10.2 Reg 结构体

```go
type Reg struct {
    StoreCode  string           // 溢出存储代码
    Name       string           // 寄存器名称
    RegIndex   int              // 物理寄存器索引
    index      int              // 分配索引
    UsingNode  *parser.Node     // 使用节点
    Using      bool             // 是否使用中
    CalleeSave bool             // 是否 callee-save
    Locked     bool             // 是否锁定
    SpillCount int              // 溢出次数
}
```

| 方法    | 签名                        | 说明                                                              |
| ----- | ------------------------- | --------------------------------------------------------------- |
| Reset | `func (reg *Reg) Reset()` | 重置寄存器状态（Using=false, Locked=false, UsingNode=nil, StoreCode=""） |

### 10.3 寄存器集定义

#### x86 32位寄存器集

```go
var regs = []*regmgr.Reg{
    {Name: "EAX"},
    {Name: "EBX", CalleeSave: true},
    {Name: "ECX"},
    {Name: "EDX"},
}
```

#### x86/x86\_64 64位寄存器集

```go
var Regs64 = []*regmgr.Reg{  // x86 包
var Regs = []*regmgr.Reg{    // x86_64 包
    {Name: "RAX",  RegIndex: 0},
    {Name: "RBX",  CalleeSave: true, RegIndex: 1},
    {Name: "RCX",  RegIndex: 2},
    {Name: "RDX",  RegIndex: 3},
    {Name: "RSI",  RegIndex: 4},
    {Name: "RDI",  RegIndex: 5},
    {Name: "R8",   RegIndex: 6},
    {Name: "R9",   RegIndex: 7},
    {Name: "R10",  RegIndex: 8},
    {Name: "R11",  RegIndex: 9},
    {Name: "R12",  CalleeSave: true, RegIndex: 10},
    {Name: "R13",  CalleeSave: true, RegIndex: 11},
    {Name: "R14",  CalleeSave: true, RegIndex: 12},
    {Name: "R15",  CalleeSave: true, RegIndex: 13},
}
```

### 10.4 溢出策略

- 使用 LRU（最近最少使用）算法选择溢出目标
- 锁定寄存器不可溢出（代价为 `int(^uint(0) >> 1)`）
- 溢出代价 = 使用索引 + 偏好调整（needCalleeSave 匹配 +1000，不匹配 +500）+ 溢出历史惩罚（SpillCount \* 100）
- 溢出代码格式：`mov [size] [addr], [reg] ; spill`
- 64位寄存器（R开头）溢出时使用 QWORD 前缀，32位寄存器使用 dword 前缀
- 只有变量节点（VarBlock）才会生成溢出代码，临时表达式值不溢出

***

## 11. 编译上下文 `context`

**包路径**: `cuteify/compile/context`

**文件**: `compile/context/context.go`

### 11.1 Context 结构体

```go
type Context struct {
    // AST 相关
    Now *parser.Node         // 当前编译的 AST 节点

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

    // 栈对齐
    StackAlignment int // 栈对齐大小（字节），默认8

    // 表达式编译状态
    UseEBXDirect bool // 标记是否直接使用 EBX（不通过寄存器分配）
    EbxOccupied  bool // 标记 EBX 是否已被左子占用
    ExpType      int  // 表达式类型（NumExp/BoolExp/AndExp/OrExp/NotExp）

    // 编译器状态
    VarStackSize int // 变量栈的大小
    ExpCount     int // 表达式计数
    ArgOffset    int // 参数偏移量
    IfCount      int // if 块数量计数
    ForCount     int // for 块数量计数

    // 字符串常量池
    StringConsts map[string]string // 字面值 → 标签名
    StrCount     int               // 字符串标签计数
    ListDataCount int              // list 数据段标签计数

    // 架构相关
    PointerSize int  // 指针大小（4或8）
    Is64Bit     bool // 是否 64 位
}
```

### 11.2 Context 方法

| 方法         | 签名                                     | 说明                                         |
| ---------- | -------------------------------------- | ------------------------------------------ |
| NewContext | `func NewContext() *Context`           | 创建新上下文（默认 PointerSize=4, StackAlignment=8） |
| Reset      | `func (ctx *Context) Reset()`          | 重置上下文状态（编译新函数时调用）                          |
| Clone      | `func (ctx *Context) Clone() *Context` | 克隆上下文（保存和恢复状态）                             |

***

## 12. x86 32位表达式编译器

**文件**: `compile/arch/x86/exp.go`, `compile/arch/x86/utils.go`

### 12.1 表达式类型常量

```go
const (
    NumExp  = 1 // 数值表达式
    BoolExp = 2 // 布尔表达式
    AndExp  = 3 // 逻辑与表达式
    OrExp   = 4 // 逻辑或表达式
    NotExp  = 5 // 逻辑非表达式
)
```

### 12.2 expCom 结构体

```go
type expCom struct {
    ctx           *context.Context
    varWithSetVal bool  // 标记表达式是否为变量赋值
}
```

#### 核心方法

| 方法                  | 签名                                                                                    | 说明                               |
| ------------------- | ------------------------------------------------------------------------------------- | -------------------------------- |
| CompileExpr         | `func (c *expCom) CompileExpr(exp *parser.Expression, result, desc string) string`    | 编译表达式入口（分发到内置函数/布尔/常量/64位/普通表达式） |
| CompileExprChildren | `func (c *expCom) CompileExprChildren(exp *parser.Expression) (string, *regmgr.Reg)`  | 编译子表达式（分发到叶节点/索引/切片/列表/二元运算）     |
| CompileExprVal      | `func (c *expCom) CompileExprVal(exp *parser.Expression) (string, string)`            | 编译表达式值（返回代码和结果地址/值）              |
| compileExpr64       | `func (c *expCom) compileExpr64(exp *parser.Expression, result, desc string) string`  | 编译64位表达式（EDX:EAX 寄存器对）           |
| compileBinOp64      | `func (c *expCom) compileBinOp64(exp *parser.Expression, result, desc string) string` | 编译64位二元运算                        |
| CompileBoolExpr     | `func (c *expCom) CompileBoolExpr(exp *parser.Expression, result string) string`      | 编译布尔表达式                          |
| compileBinaryOp     | `func (c *expCom) compileBinaryOp(exp *parser.Expression) (string, *regmgr.Reg)`      | 编译二元运算                           |
| compileLeafNode     | `func (c *expCom) compileLeafNode(exp *parser.Expression) (string, *regmgr.Reg)`      | 编译叶节点                            |
| compileIndexAccess  | `func (c *expCom) compileIndexAccess(exp *parser.Expression) (string, *regmgr.Reg)`   | 编译列表索引访问                         |
| compileIndexSet     | `func (c *expCom) compileIndexSet(exp *parser.Expression) (string, *regmgr.Reg)`      | 编译列表索引赋值                         |
| compileSlice        | `func (c *expCom) compileSlice(exp *parser.Expression) (string, *regmgr.Reg)`         | 编译列表切片                           |
| compileListLiteral  | `func (c *expCom) compileListLiteral(exp *parser.Expression) (string, *regmgr.Reg)`   | 编译列表字面量                          |
| builtinHandle       | `func (c *expCom) builtinHandle(exp *parser.Expression, result, desc string) string`  | 处理内置函数（len/cap/列表方法）             |
| numConstHandle      | `func (c *expCom) numConstHandle(exp *parser.Expression, result, desc string) string` | 处理数值常量                           |
| strConstHandle      | `func (c *expCom) strConstHandle(exp *parser.Expression, result, desc string) string` | 处理字符串常量                          |

#### 二元运算辅助方法

| 方法                | 签名                                                                                                                                                            | 说明                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| compileLeftChild  | `func (c *expCom) compileLeftChild(exp *parser.Expression) (string, *regmgr.Reg, string)`                                                                     | 编译左子表达式                    |
| compileRightChild | `func (c *expCom) compileRightChild(exp *parser.Expression, leftResult string) (string, *regmgr.Reg, string)`                                                 | 编译右子表达式                    |
| needSaveLeftToEBX | `func (c *expCom) needSaveLeftToEBX(exp *parser.Expression, leftReg *regmgr.Reg) bool`                                                                        | 判断是否需要将左子结果保存到 EBX         |
| saveLeftToEBX     | `func (c *expCom) saveLeftToEBX(leftExp *parser.Expression, leftReg *regmgr.Reg, leftResult string) string`                                                   | 将左子结果保存到 EBX               |
| generateOpWithEBX | `func (c *expCom) generateOpWithEBX(code string, exp *parser.Expression, rightResult string, rightReg *regmgr.Reg, leftExp *parser.Expression) string`        | 使用 EBX 作为目标生成运算代码          |
| generateOpNormal  | `func (c *expCom) generateOpNormal(code string, exp *parser.Expression, leftReg, rightReg *regmgr.Reg, leftResult, rightResult string) (string, *regmgr.Reg)` | 正常生成运算代码                   |
| selectResultReg   | `func (c *expCom) selectResultReg(leftReg, rightReg *regmgr.Reg, leftResult, rightResult string, exp *parser.Expression) (*regmgr.Reg, string)`               | 选择结果寄存器和源操作数               |
| emitOpInstruction | `func (c *expCom) emitOpInstruction(regName, op, src string) string`                                                                                          | 发出运算指令（add/sub/imul/idiv等） |
| containsCall      | `func (c *expCom) containsCall(exp *parser.Expression) bool`                                                                                                  | 递归检查表达式是否包含函数调用            |

### 12.3 x86 工具函数（`compile/arch/x86/utils.go`）

| 函数         | 签名                                                                 | 说明                              |
| ---------- | ------------------------------------------------------------------ | ------------------------------- |
| NewExpCom  | `func NewExpCom(ctx *context.Context) *expCom`                     | 创建 x86 32位表达式编译器                |
| genVarAddr | `func genVarAddr(ctx *context.Context, v *parser.VarBlock) string` | 生成变量栈地址（`DWORD[ebp+N]`）         |
| is64Type   | `func is64Type(t typeSys.Type) bool`                               | 判断是否为64位类型（i64/u64/f64）         |
| genLoAddr  | `func genLoAddr(ctx *context.Context, v *parser.VarBlock) string`  | 生成64位变量低32位地址（`DWORD[ebp+N]`）   |
| genHiAddr  | `func genHiAddr(ctx *context.Context, v *parser.VarBlock) string`  | 生成64位变量高32位地址（`DWORD[ebp+N+4]`） |
| isRegName  | `func isRegName(s string) bool`                                    | 判断字符串是否为寄存器名                    |

### 12.4 64位表达式编译（x86 32位环境）

在 x86 32位环境中编译64位表达式时，使用 EDX:EAX 寄存器对：

- EAX 存放低32位
- EDX 存放高32位
- 64位变量在栈中占用8字节，低32位在 `[ebp+N]`，高32位在 `[ebp+N+4]`

**compileExpr64 支持的结果位置**：

- `"push"` → 压入栈（先压高32位再压低32位）
- 寄存器名 → 直接 mov
- 内存地址 → 分别写入低/高32位

**compileBinOp64 支持的运算**：

- `+` → add/adc（带进位加法）
- `-` → sub/sbb（带借位减法）
- `*` → imul 两次乘法 + 加法组合
- 其他 → 默认加载到 EDX:EAX

***

## 13. x86\_64 表达式编译器

**文件**: `compile/arch/x86_64/exp.go`, `compile/arch/x86_64/utils.go`

### 13.1 expCom 结构体（x86\_64）

```go
type expCom struct {
    ctx           *context.Context
    varWithSetVal bool
}
```

x86\_64 的表达式编译器与 x86 32位版本结构类似，但使用64位寄存器（RAX, RBX 等）进行运算，无需 EDX:EAX 寄存器对。

#### 核心方法

| 方法                  | 签名                                                                                    | 说明       |
| ------------------- | ------------------------------------------------------------------------------------- | -------- |
| CompileExpr         | `func (c *expCom) CompileExpr(exp *parser.Expression, result, desc string) string`    | 编译表达式入口  |
| CompileExprChildren | `func (c *expCom) CompileExprChildren(exp *parser.Expression) (string, *regmgr.Reg)`  | 编译子表达式   |
| CompileExprVal      | `func (c *expCom) CompileExprVal(exp *parser.Expression) (string, string)`            | 编译表达式值   |
| CompileBoolExpr     | `func (c *expCom) CompileBoolExpr(exp *parser.Expression, result string) string`      | 编译布尔表达式  |
| compileBinaryOp     | `func (c *expCom) compileBinaryOp(exp *parser.Expression) (string, *regmgr.Reg)`      | 编译二元运算   |
| compileLeafNode     | `func (c *expCom) compileLeafNode(exp *parser.Expression) (string, *regmgr.Reg)`      | 编译叶节点    |
| compileIndexAccess  | `func (c *expCom) compileIndexAccess(exp *parser.Expression) (string, *regmgr.Reg)`   | 编译列表索引访问 |
| compileIndexSet     | `func (c *expCom) compileIndexSet(exp *parser.Expression) (string, *regmgr.Reg)`      | 编译列表索引赋值 |
| compileSlice        | `func (c *expCom) compileSlice(exp *parser.Expression) (string, *regmgr.Reg)`         | 编译列表切片   |
| compileListLiteral  | `func (c *expCom) compileListLiteral(exp *parser.Expression) (string, *regmgr.Reg)`   | 编译列表字面量  |
| builtinHandle       | `func (c *expCom) builtinHandle(exp *parser.Expression, result, desc string) string`  | 处理内置函数   |
| numConstHandle      | `func (c *expCom) numConstHandle(exp *parser.Expression, result, desc string) string` | 处理数值常量   |
| strConstHandle      | `func (c *expCom) strConstHandle(exp *parser.Expression, result, desc string) string` | 处理字符串常量  |

### 13.2 x86\_64 工具函数（`compile/arch/x86_64/utils.go`）

| 函数           | 签名                                                                 | 说明                      |
| ------------ | ------------------------------------------------------------------ | ----------------------- |
| NewExpCom    | `func NewExpCom(ctx *context.Context) *expCom`                     | 创建 x86\_64 表达式编译器       |
| genVarAddr   | `func genVarAddr(ctx *context.Context, v *parser.VarBlock) string` | 生成变量栈地址（`QWORD[rbp+N]`） |
| isRegName    | `func isRegName(s string) bool`                                    | 判断字符串是否为寄存器名            |
| GetRbpOffset | `func GetRbpOffset(addr string) int`                               | 从地址表达式中提取 rbp 偏移量       |

### 13.3 x86\_64 与 x86 32位表达式编译器的差异

| 特性      | x86 32位             | x86\_64                    |
| ------- | ------------------- | -------------------------- |
| 寄存器宽度   | 32位（EAX, EBX 等）     | 64位（RAX, RBX 等）            |
| 64位类型处理 | EDX:EAX 寄存器对，需特殊编译  | 原生64位寄存器，直接运算              |
| 变量地址前缀  | `DWORD[ebp+N]`      | `QWORD[rbp+N]`             |
| 参数寄存器   | 无（全部栈传递）            | RDI, RSI, RDX, RCX, R8, R9 |
| 可用寄存器数  | 4个（EAX/EBX/ECX/EDX） | 14个（RAX-R15）               |
| 栈帧基址    | EBP                 | RBP                        |

***

## 14. 调用约定对比总览

| 特性           | cdecl         | stdcall       | fastcall      | SysV AMD64   | Win64                  |
| ------------ | ------------- | ------------- | ------------- | ------------ | ---------------------- |
| 架构           | x86           | x86           | x86           | x86\_64      | x86\_64                |
| 参数传递         | 全栈            | 全栈            | ECX,EDX + 栈   | 6寄存器 + 栈     | 4寄存器 + 栈               |
| 栈清理          | 调用者           | 被调用者          | 调用者           | 调用者          | 调用者                    |
| Shadow Space | 无             | 无             | 无             | 无            | 32字节                   |
| 栈对齐          | 4字节           | 4字节           | 4字节           | 16字节         | 16字节                   |
| 返回值          | EAX / EDX:EAX | EAX / EDX:EAX | EAX / EDX:EAX | RAX          | RAX                    |
| callee-save  | EBX           | EBX           | EBX           | RBX, R12-R15 | RDI, RSI, RBX, R12-R15 |
