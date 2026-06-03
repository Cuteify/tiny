# Expression 检查系统文档（详细版）

## 概述

Expression 检查系统负责表达式 AST 的**类型推导**、**语义验证**和**常量折叠**，是编译器前端的核心枢纽。每个表达式节点通过 `Check()` 方法推导自身类型，并验证操作的合法性。

## 文件结构

| 文件                    | 行范围      | 功能                                   |
| --------------------- | -------- | ------------------------------------ |
| `parser/exp.go`       | L9-25    | Expression 结构体定义                     |
| `parser/exp.go`       | L44-67   | `opTable` 运算符优先级表                    |
| `parser/exp.go`       | L69-91   | `opMethodMap` 二元运算符重载映射              |
| `parser/exp.go`       | L93-98   | `unaryOpMethodMap` 一元运算符重载映射         |
| `parser/exp.go`       | L100-103 | `IsConst()` 常量判断                     |
| `parser/exp_check.go` | L9-30    | `Check()` 语义检查入口                     |
| `parser/exp_check.go` | L33-47   | `checkVar()` 变量解析                    |
| `parser/exp_check.go` | L50-65   | `checkCall()` 函数调用检查                 |
| `parser/exp_check.go` | L68-126  | `checkOp()` 运算符分发器                   |
| `parser/exp_check.go` | L129-150 | `checkLogic()` 逻辑运算符                 |
| `parser/exp_check.go` | L153-187 | `checkAssign()` 赋值运算符                |
| `parser/exp_check.go` | L190-212 | `checkIndexAssign()` 索引赋值            |
| `parser/exp_check.go` | L215-255 | `checkField()` 字段访问                  |
| `parser/exp_check.go` | L258-290 | `checkOverload()` 运算符重载              |
| `parser/exp_check.go` | L293-339 | `checkIndex()` 索引/切片                 |
| `parser/exp_check.go` | L342-365 | `checkListLiteral()` 列表字面量           |
| `parser/exp_check.go` | L368-413 | `checkUnary()` 一元运算符                 |
| `parser/exp_check.go` | L416-438 | `checkAdd()` 加法                      |
| `parser/exp_check.go` | L441-463 | `checkMul()` 乘法                      |
| `parser/exp_check.go` | L466-491 | `checkArith()` 算术运算                  |
| `parser/exp_check.go` | L494-516 | `checkEq()` 相等比较                     |
| `parser/exp_check.go` | L519-542 | `checkCmp()` 比较运算                    |
| `parser/exp_check.go` | L545-555 | `foldNum()` 数值折叠                     |
| `parser/exp_check.go` | L558-562 | `foldBin()` 二元折叠                     |
| `parser/exp_check.go` | L565-602 | `foldArith()` 算术折叠                   |
| `parser/exp_check.go` | L605-623 | `foldCmp()` 比较折叠                     |
| `parser/exp_check.go` | L626-648 | `foldEq()` 相等折叠                      |
| `parser/parser.go`    | L140-208 | `fieldExpr()` / `fieldExprFromExp()` |

## Expression 结构体详细说明

```go
type Expression struct {
    Call      *CallBlock     // 函数调用块，非nil时表示该表达式是函数调用
    Num       float64        // 数值常量值（整数和浮点数统一用float64存储）
    Separator string         // 运算符或特殊标记：
                             //   "+" "-" "*" "/" "%" "^"        算术/位运算
                             //   "==" "!=" "<" ">" "<=" ">="    比较运算
                             //   "&&" "||"                       逻辑运算
                             //   "&" "|" "<<" ">>"               位运算
                             //   "[]" "[]="                      索引/索引赋值
                             //   "."                             字段访问
                             //   "= := += -= *= /= ..."          赋值运算
                             //   "list_lit"                      列表字面量
                             //   常量折叠后为空字符串
    Right     *Expression    // 右操作数（二元运算的右侧、一元运算的唯一子节点）
    Left      *Expression    // 左操作数（仅二元运算有值）
    Father    *Expression    // 父表达式节点，用于向上遍历构建 AST
    Var       *VarBlock      // 变量引用，非nil时表示该表达式是变量引用
    StringVal string         // 字符串常量值
    Bool      bool           // 布尔常量值
    ConstBool bool           // 预留字段（当前未使用）
    Type      typeSys.Type   // 表达式的数据类型，由 Check 阶段推导得出
    checked   bool           // 是否已通过语义检查，防止重复检查
    Index     [3]*Expression // 列表索引 [start, end, step]，用于 arr[i], arr[1:3], arr[::2]
    ListElems []*Expression  // 列表字面量元素，Separator="list_lit" 时有效
}
```

### 表达式类型判定规则

| 字段状态                      | 表达式类型   | 说明                                 |
| ------------------------- | ------- | ---------------------------------- |
| `Var != nil`              | 变量表达式   | 引用已声明的变量                           |
| `Call != nil`             | 函数调用表达式 | 调用函数/方法                            |
| `Separator == "list_lit"` | 列表字面量   | `[1, 2, 3]`                        |
| `Separator != ""`         | 运算表达式   | 二元/一元运算、字段访问、索引                    |
| 其余                        | 常量表达式   | 数值 `Num`、字符串 `StringVal`、布尔 `Bool` |

### IsConst() 常量判断

```go
func (exp *Expression) IsConst() bool {
    return exp.Var == nil && exp.Call == nil && exp.Separator == "" && exp.ListElems == nil
}
```

**条件**：无变量引用、无函数调用、Separator 为空（已折叠或本身就是常量）、无列表字面量。

***

## 核心方法详细说明

### 1. `Expression.Check(p *Parser) bool`

**位置**：`exp_check.go:L9-30`

**签名**：`func (exp *Expression) Check(p *Parser) bool`

**参数**：

- `p *Parser` — 当前解析器实例，用于访问词法分析器、错误报告、作用域查找等

**返回值**：`bool`

- `true` — 检查通过，类型推导成功
- `false` — 检查失败，已报告错误

**功能**：语义检查入口，负责分发到具体的检查器。

**分发逻辑**（按优先级）：

```
Check(p)
  ├→ checked == true?  → return true（防重复检查）
  │
  ├→ Var != nil?       → checkVar(p)      变量引用解析
  │
  ├→ Call != nil?      → checkCall(p)     函数调用检查
  │
  ├→ Separator != ""?  → checkOp(p)       运算符类型检查
  │
  └→ 其他              → return true       常量表达式，类型已在解析阶段设置
```

**副作用**：

- 设置 `exp.checked = true`（标记已检查）
- 设置 `exp.Type`（推导出的类型）

**调用方统计**（15+ 处）：

| 调用位置                | 文件          | 行号  | 场景           |
| ------------------- | ----------- | --- | ------------ |
| `VarBlock.Check`    | `var.go`    | 362 | 变量定义分支的值检查   |
| `VarBlock.Check`    | `var.go`    | 388 | 变量使用分支的值检查   |
| `ArgBlock.Check`    | `func.go`   | 31  | 函数参数默认值检查    |
| `ArgBlock.Check`    | `func.go`   | 34  | 函数参数值检查      |
| `CallBlock.Check`   | `call.go`   | 90  | 函数调用参数检查     |
| `ReturnBlock.Check` | `return.go` | 55  | 返回值检查        |
| `IfBlock.Check`     | `ifelse.go` | 47  | if 条件检查      |
| `ElseBlock.Check`   | `ifelse.go` | 54  | else if 条件检查 |
| `ForBlock.Check`    | `for.go`    | 111 | for 增量检查     |
| `ForBlock.Check`    | `for.go`    | 118 | for 条件检查     |
| `ForBlock.Check`    | `for.go`    | 130 | for 增量检查     |

***

### 2. `checkVar(p *Parser) bool`

**位置**：`exp_check.go:L33-47`

**签名**：`func (exp *Expression) checkVar(p *Parser) bool`

**功能**：解析变量引用类型，通过 `Var.ParseDefine` 在作用域链中查找变量定义。

**流程图**：

```
checkVar(p)
  ├→ Var == nil?            → return true（无变量，直接通过）
  │
  ├→ Var.ParseDefine(p)     → 在作用域链中查找变量定义
  │    ├→ 在 FuncBlock.Args 中查找（函数参数）
  │    ├→ 在 ThisBlock.Children 中查找（局部变量）
  │    └→ 向上遍历 Father 链查找（嵌套作用域）
  │
  ├→ Var.Type != nil?       → exp.Type = Var.Type
  │    └→ return true
  │
  └→ 否则                   → Error("undefined variable: "+name)
                              └→ return false
```

**Var.ParseDefine 内部逻辑**（`var.go:L277-354`）：

1. 调用 `p.FindVar(v.Name)` 查找变量定义节点
2. 找到 `ArgBlock`：复制 `Type` 和 `Offset` 到 `Var`
3. 找到 `VarBlock`：复制 `Type` 和 `Offset` 到 `Var`
4. 未找到：保持 `Var.Define == nil`，`Var.Type == nil`

**错误消息**：

- `"undefined variable: name"` — 变量未在作用域中声明

**示例**：

```
输入：x（未声明）
结果：错误 "undefined variable: x"

输入：x（已声明为 int）
结果：exp.Type = int，返回 true
```

***

### 3. `checkCall(p *Parser) bool`

**位置**：`exp_check.go:L50-65`

**签名**：`func (exp *Expression) checkCall(p *Parser) bool`

**功能**：检查函数调用合法性并设置返回类型。

**流程图**：

```
checkCall(p)
  ├→ Call.Check(p)?         → 检查函数调用参数
  │    ├→ 检查函数名是否为空
  │    ├→ 查找函数定义 p.FindFunc()
  │    ├→ 检查参数数量（含默认参数）
  │    └→ 逐个检查参数类型兼容性 AutoType()
  │
  ├→ Call.Func != nil?
  │    ├→ len(Return) == 1? → exp.Type = Return[0]
  │    │                     └→ return true
  │    │
  │    └→ len(Return) != 1? → Error("function call must return one value")
  │                           └→ return false
  │
  └→ Call.Func == nil?      → return false（Call.Check 已报错）
```

**错误消息**：

- `"function call must return one value"` — 函数返回值数量不为 1（可能是 void 或多个返回值）
- Call.Check 内部可能产生的错误：
  - `"function name is empty"`
  - `"function not found: name"`
  - `"expected N arguments, got M"`
  - `"cannot use X as type Y in argument"`

**示例**：

```
输入：print("hello")（返回 void）
结果：错误 "function call must return one value"

输入：add(1, 2)（返回 int）
结果：exp.Type = int，返回 true
```

***

### 4. `checkOp(p *Parser) bool`

**位置**：`exp_check.go:L68-126`

**签名**：`func (exp *Expression) checkOp(p *Parser) bool`

**功能**：运算符类型检查分发器，负责递归检查子节点并按 Separator 分发到具体检查函数。

**完整分发表**：

| Separator 值       | 前置处理          | 分发函数                  | 说明                | <br />          | <br /> |
| ----------------- | ------------- | --------------------- | ----------------- | :-------------- | :----- |
| `"list_lit"`      | 无             | `checkListLiteral(p)` | 列表字面量 `[1, 2, 3]` | <br />          | <br /> |
| `"!"`             | 无             | `checkUnary(p)`       | 逻辑非               | <br />          | <br /> |
| `"~"`             | 无             | `checkUnary(p)`       | 位取反               | <br />          | <br /> |
| `"-"` (Left==nil) | 无             | `checkUnary(p)`       | 一元取负              | <br />          | <br /> |
| `""`              | 检查 Left/Right | 无（直接返回 true）          | 已折叠，不再处理          | <br />          | <br /> |
| `"."`             | 检查 Left/Right | `checkField(p)`       | 结构体字段访问           | <br />          | <br /> |
| `"[]"`            | 检查 Left/Right | `checkIndex(p)`       | 列表/字符串索引          | <br />          | <br /> |
| `"+"`             | 检查 Left/Right | `checkAdd(p)`         | 加法/字符串拼接          | <br />          | <br /> |
| `"*"`             | 检查 Left/Right | `checkMul(p)`         | 乘法/字符串重复          | <br />          | <br /> |
| `"=="`            | 检查 Left/Right | `checkEq(p)`          | 相等                | <br />          | <br /> |
| `"!="`            | 检查 Left/Right | `checkEq(p)`          | 不等                | <br />          | <br /> |
| `"<"`             | 检查 Left/Right | `checkCmp(p)`         | 小于                | <br />          | <br /> |
| `">"`             | 检查 Left/Right | `checkCmp(p)`         | 大于                | <br />          | <br /> |
| `"<="`            | 检查 Left/Right | `checkCmp(p)`         | 小于等于              | <br />          | <br /> |
| `">="`            | 检查 Left/Right | `checkCmp(p)`         | 大于等于              | <br />          | <br /> |
| `"&&"`            | 检查 Left/Right | `checkLogic(p)`       | 逻辑与               | <br />          | <br /> |
| \`"               | <br />        | "\`                   | 检查 Left/Right     | `checkLogic(p)` | 逻辑或    |
| `"-"`             | 检查 Left/Right | `checkArith(p)`       | 减法                | <br />          | <br /> |
| `"/"`             | 检查 Left/Right | `checkArith(p)`       | 除法                | <br />          | <br /> |
| `"%"`             | 检查 Left/Right | `checkArith(p)`       | 取模                | <br />          | <br /> |
| `"<<"`            | 检查 Left/Right | `checkArith(p)`       | 左移                | <br />          | <br /> |
| `">>"`            | 检查 Left/Right | `checkArith(p)`       | 右移                | <br />          | <br /> |
| `"&"`             | 检查 Left/Right | `checkArith(p)`       | 位与                | <br />          | <br /> |
| \`"               | "\`           | 检查 Left/Right         | `checkArith(p)`   | 位或              | <br /> |
| `"^"`             | 检查 Left/Right | `checkArith(p)`       | 位异或               | <br />          | <br /> |
| `"="`             | 检查 Left/Right | `checkAssign(p)`      | 赋值                | <br />          | <br /> |
| `":="`            | 检查 Left/Right | `checkAssign(p)`      | 定义并赋值             | <br />          | <br /> |
| `"+="`            | 检查 Left/Right | `checkAssign(p)`      | 加赋值               | <br />          | <br /> |
| `"-="`            | 检查 Left/Right | `checkAssign(p)`      | 减赋值               | <br />          | <br /> |
| `"*="`            | 检查 Left/Right | `checkAssign(p)`      | 乘赋值               | <br />          | <br /> |
| `"/="`            | 检查 Left/Right | `checkAssign(p)`      | 除赋值               | <br />          | <br /> |
| `"%="`            | 检查 Left/Right | `checkAssign(p)`      | 取模赋值              | <br />          | <br /> |
| `"^="`            | 检查 Left/Right | `checkAssign(p)`      | 幂赋值               | <br />          | <br /> |
| `"&="`            | 检查 Left/Right | `checkAssign(p)`      | 位与赋值              | <br />          | <br /> |
| \`"               | ="\`          | 检查 Left/Right         | `checkAssign(p)`  | 位或赋值            | <br /> |
| `"<<="`           | 检查 Left/Right | `checkAssign(p)`      | 左移赋值              | <br />          | <br /> |
| `">>="`           | 检查 Left/Right | `checkAssign(p)`      | 右移赋值              | <br />          | <br /> |
| 其他                | 无             | 返回 true               | 未识别运算符            | <br />          | <br /> |

**递归检查逻辑**：

```go
// 二元运算符必须先递归检查左右子节点
if exp.Left != nil {
    if !exp.Left.Check(p) { return false }
}
if exp.Right != nil {
    if !exp.Right.Check(p) { return false }
}
```

**注意**：一元运算符（`!`、`~`、前缀 `-`）在 `checkUnary` 内部递归检查 `exp.Right`，不在 `checkOp` 中提前检查。

***

### 5. `checkIndex(p *Parser) bool`

**位置**：`exp_check.go:L293-339`

**签名**：`func (exp *Expression) checkIndex(p *Parser) bool`

**功能**：列表/字符串索引和切片的类型检查。

**输入要求**：

- `exp.Left` — 被索引的对象（列表、字符串或自定义类型）
- `exp.Index` — `[3]*Expression` 数组，`[start, end, step]`
  - `Index[0]`：起始索引（必选，但可为 nil 表示从头开始）
  - `Index[1]`：结束索引（可选，nil 表示到末尾）
  - `Index[2]`：步长（可选，nil 表示步长为 1）

**类型推导规则表**：

| Left.Type  | Index\[1]/Index\[2]    | exp.Type           | 说明          |
| ---------- | ---------------------- | ------------------ | ----------- |
| `ListType` | 均为 nil                 | `Elem`             | 索引操作，返回元素类型 |
| `ListType` | end 非 nil 或 step 非 nil | `ListType`（同 Left） | 切片操作，返回列表类型 |
| `string`   | 均为 nil                 | `byte`             | 字符串索引，返回字节  |
| `string`   | end 非 nil 或 step 非 nil | `string`           | 字符串切片，返回字符串 |
| 自定义类型      | 任意                     | `checkOverload()`  | 通过方法重载处理    |

**错误消息**：

- `"left operand of '[]' has no type"` — 被索引的对象类型未推导

**Index 表达式检查**：

```go
for i := 0; i < 3; i++ {
    if exp.Index[i] != nil {
        if !exp.Index[i].Check(p) { return false }
    }
}
```

**示例**：

```
arr[i]     → exp.Index[0]=i, Index[1]=nil, Index[2]=nil
             exp.Type = arr.Elem

arr[1:5]   → exp.Index[0]=1, Index[1]=5, Index[2]=nil
             exp.Type = ListType（同 arr）

arr[::2]   → exp.Index[0]=nil, Index[1]=nil, Index[2]=2
             exp.Type = ListType（同 arr）

str[0]     → exp.Index[0]=0, Index[1]=nil, Index[2]=nil
             exp.Type = byte

str[1:3]   → exp.Index[0]=1, Index[1]=3, Index[2]=nil
             exp.Type = string
```

***

### 6. `checkField(p *Parser) bool`

**位置**：`exp_check.go:L215-255`

**签名**：`func (exp *Expression) checkField(p *Parser) bool`

**功能**：结构体字段访问类型检查，通过遍历 `Left.Type.Fields()` 查找字段。

**字段名提取规则**：

| Right 表达式类型             | 字段名获取方式                  |
| ----------------------- | ------------------------ |
| `Right.Var != nil`      | `Right.Var.Name.Last()`  |
| `Right.StringVal != ""` | `Right.StringVal`        |
| 其他                      | 报错 "field name is empty" |

**查找流程**：

```go
// 1. 检查 Left 类型是否有效
if exp.Left.Type == nil {
    Error("left operand of '.' has no type")
    return false
}

// 2. 检查是否为结构体类型
fields := exp.Left.Type.Fields()
if fields == nil {
    Error("type X has no fields")
    return false
}

// 3. 提取字段名
fieldName := Right.Var.Name.Last() 或 Right.StringVal

// 4. 遍历查找字段
for _, f := range fields {
    if f.Name == fieldName {
        exp.Type = f.Type  ← 设置表达式类型为字段类型
        return true
    }
}

// 5. 未找到
Error("struct X has no field 'Y'")
return false
```

**错误消息**：

- `"left operand of '.' has no type"` — 左侧表达式类型未推导
- `"type X has no fields"` — 左侧类型不是结构体（如 int、string 等）
- `"field name is empty"` — 字段名为空
- `"struct X has no field 'Y'"` — 结构体没有该字段

**示例**：

```
point.x    → point 是 struct Point { x int, y int }
             exp.Type = int

config.host → config 是 struct Config { host string, port int }
              exp.Type = string

arr.len     → arr 是列表类型，不是结构体
              错误 "type lists.[]int has no fields"
```

***

### 7. `checkOverload(p *Parser) bool`

**位置**：`exp_check.go:L258-290`

**签名**：`func (exp *Expression) checkOverload(p *Parser) bool`

**功能**：自定义类型运算符重载方法查找，通过 `p.FindFunc()` 查找 `TypeName.method` 方法。

**运算符到方法名映射**：

#### 二元运算符映射 (`opMethodMap`)

| 运算符    | 方法名     | 说明   |
| ------ | ------- | ---- |
| `+`    | `add`   | 加法   |
| `-`    | `sub`   | 减法   |
| `*`    | `mul`   | 乘法   |
| `/`    | `div`   | 除法   |
| `%`    | `mod`   | 取模   |
| `^`    | `pow`   | 幂运算  |
| `==`   | `eq`    | 相等   |
| `!=`   | `ne`    | 不等   |
| `<`    | `lt`    | 小于   |
| `>`    | `gt`    | 大于   |
| `<=`   | `le`    | 小于等于 |
| `>=`   | `ge`    | 大于等于 |
| `&`    | `band`  | 位与   |
| `\|`   | `bor`   | 位或   |
| `<<`   | `shl`   | 左移   |
| `>>`   | `shr`   | 右移   |
| `[]`   | `get`   | 索引访问 |
| `[]=`  | `set`   | 索引赋值 |
| `[::]` | `slice` | 切片   |

#### 一元运算符映射 (`unaryOpMethodMap`)

| 运算符 | 方法名    | 说明  |
| --- | ------ | --- |
| `-` | `neg`  | 取负  |
| `!` | `not`  | 逻辑非 |
| `~` | `bnot` | 位取反 |

**查找流程**：

```go
// 1. 获取左操作数类型名
leftTypeName := exp.Left.Type.Type()  // 如 "Point"

// 2. 获取方法名
if exp.Left != nil && exp.Right != nil {
    methodName = opMethodMap[exp.Separator]  // 如 "add"
} else {
    methodName = unaryOpMethodMap[exp.Separator]  // 如 "neg"
}

// 3. 构造完整方法名
methodFullName := Name{leftTypeName, methodName}  // ["Point", "add"]

// 4. 查找方法定义
_, funcBlock := p.FindFunc(methodFullName)

// 5. 找到方法
if funcBlock != nil {
    exp.Type = funcBlock.Return[0]  // 设置返回类型
    return true
}

// 6. 未找到
Error("operator X not defined for type TypeName")
return false
```

**错误消息**：

- `"operator + not defined for type Point"` — 类型未定义对应运算符方法

**示例**：

```
point1 + point2   → 查找 Point.add
                     找到 → exp.Type = add.Return[0]
                     未找到 → 错误 "operator + not defined for type Point"

-point            → 查找 Point.neg
                     找到 → exp.Type = neg.Return[0]

arr[i]            → 查找 List.get
                     找到 → exp.Type = get.Return[0]
```

***

### 8. `checkAdd(p *Parser) bool`

**位置**：`exp_check.go:L416-438`

**签名**：`func (exp *Expression) checkAdd(p *Parser) bool`

**功能**：加法类型检查，支持数值加法和字符串拼接。

**类型推导规则表**：

| Left.Type        | Right.Type       | exp.Type          | 常量折叠               | 说明                 |
| ---------------- | ---------------- | ----------------- | ------------------ | ------------------ |
| `string`         | `string`         | `string`          | `"a" + "b" → "ab"` | 字符串拼接              |
| `int/uint/float` | `int/uint/float` | `int` 或 `f64`     | `1 + 2 → 3`        | 数值加法（见 checkArith） |
| 其他               | 其他               | `checkOverload()` | 无                  | 运算符重载              |

**字符串拼接常量折叠**：

```go
if exp.Left.IsConst() && exp.Right.IsConst() {
    exp.StringVal = exp.Left.StringVal + exp.Right.StringVal  // 字符串连接
    exp.Separator = ""                                         // 清空运算符
    exp.Left = nil                                             // 清空左子节点
    exp.Right = nil                                            // 清空右子节点
}
```

***

### 9. `checkMul(p *Parser) bool`

**位置**：`exp_check.go:L441-463`

**签名**：`func (exp *Expression) checkMul(p *Parser) bool`

**功能**：乘法类型检查，支持数值乘法和字符串重复。

**类型推导规则表**：

| Left.Type        | Right.Type       | exp.Type          | 常量折叠                  | 说明                 |
| ---------------- | ---------------- | ----------------- | --------------------- | ------------------ |
| `string`         | `int`            | `string`          | `"ab" * 3 → "ababab"` | 字符串重复              |
| `int/uint/float` | `int/uint/float` | `int` 或 `f64`     | `2 * 3 → 6`           | 数值乘法（见 checkArith） |
| 其他               | 其他               | `checkOverload()` | 无                     | 运算符重载              |

**字符串重复常量折叠**：

```go
if exp.Left.IsConst() && exp.Right.IsConst() {
    exp.StringVal = repeatString(exp.Left.StringVal, int(exp.Right.Num))
    exp.Separator = ""
    exp.Left = nil
    exp.Right = nil
}
```

***

### 10. `checkArith(p *Parser) bool`

**位置**：`exp_check.go:L466-491`

**签名**：`func (exp *Expression) checkArith(p *Parser) bool`

**功能**：算术运算类型检查（`- / % << >> & | ^`），处理数值类型推导和常量折叠。

**类型推导规则表**：

| Left.Type | Right.Type | exp.Type          | 常量折叠          |
| --------- | ---------- | ----------------- | ------------- |
| `int`     | `int`      | `int`             | `foldArith()` |
| `int`     | `uint`     | `int`             | `foldArith()` |
| `uint`    | `uint`     | `int`             | `foldArith()` |
| `float`   | `int`      | `f64`             | `foldArith()` |
| `int`     | `float`    | `f64`             | `foldArith()` |
| `float`   | `float`    | `f64`             | `foldArith()` |
| 非数值       | 任意         | `checkOverload()` | 无             |
| 任意        | 非数值        | `checkOverload()` | 无             |

**规则**：

- 左或右任意一个为 `float` → 结果为 `f64`
- 否则结果为 `int`
- 左右均为数值常量 → 调用 `foldArith(p)` 折叠
- 任一操作数为非数值 → 调用 `checkOverload(p)`

***

### 11. `checkEq(p *Parser) bool`

**位置**：`exp_check.go:L494-516`

**签名**：`func (exp *Expression) checkEq(p *Parser) bool`

**功能**：相等比较类型检查（`== !=`），支持同类别比较和常量折叠。

**类型兼容性规则**：

| 左类别      | 右类别              | 结果                | 折叠           |
| -------- | ---------------- | ----------------- | ------------ |
| `int`    | `int/uint/float` | `bool`            | `int64` 精确比较 |
| `uint`   | `int/uint/float` | `bool`            | `int64` 精确比较 |
| `float`  | `int/uint/float` | `bool`            | 浮点直接比较       |
| `bool`   | `bool`           | `bool`            | 直接比较         |
| `string` | `string`         | `bool`            | 直接比较         |
| 其他       | 其他               | `checkOverload()` | 无            |

**整数精确比较**：

```go
// 整数用 int64 精确比较，避免浮点精度问题
result = int64(left.Num) == int64(right.Num)
```

**浮点直接比较**：

```go
// 浮点数直接比较（可能有精度问题）
result = left.Num == right.Num
```

***

### 12. `checkCmp(p *Parser) bool`

**位置**：`exp_check.go:L519-542`

**签名**：`func (exp *Expression) checkCmp(p *Parser) bool`

**功能**：比较运算类型检查（`< > <= >=`），支持数值和字符串比较。

**类型推导规则表**：

| Left.Type        | Right.Type       | exp.Type          | 常量折叠        |
| ---------------- | ---------------- | ----------------- | ----------- |
| `int/uint/float` | `int/uint/float` | `bool`            | `foldCmp()` |
| `string`         | `string`         | `bool`            | 不折叠         |
| 其他               | 其他               | `checkOverload()` | 无           |

**注意**：字符串比较不折叠，因为需要运行时比较逻辑。

***

### 13. `checkLogic(p *Parser) bool`

**位置**：`exp_check.go:L129-150`

**签名**：`func (exp *Expression) checkLogic(p *Parser) bool`

**功能**：逻辑运算类型检查（`&& ||`），要求左右均为 `bool`。

**规则**：

- 左必须为 `bool`，否则报错
- 右必须为 `bool`，否则报错
- 均为 `bool` → `exp.Type = bool`
- 均为常量 → 折叠

**常量折叠**：

```go
if exp.Left.IsConst() && exp.Right.IsConst() {
    if exp.Separator == "&&" {
        exp.Bool = exp.Left.Bool && exp.Right.Bool
    } else {
        exp.Bool = exp.Left.Bool || exp.Right.Bool
    }
    exp.foldBin()  // 清空 Separator/Left/Right
}
```

**错误消息**：

- `"left operand of '&&' must be bool, not int"` — 左操作数非 bool
- `"right operand of '||' must be bool, not string"` — 右操作数非 bool

***

### 14. `checkAssign(p *Parser) bool`

**位置**：`exp_check.go:L153-187`

**签名**：`func (exp *Expression) checkAssign(p *Parser) bool`

**功能**：赋值运算符类型兼容性检查。

**索引赋值转换**：

```
arr[i] = value  →  exp.Separator = "[]="
                   转为 checkIndexAssign(p)
```

**复合赋值运算符**（`+= -= *= /= %= ^= &= |= <<= >>=`）：

- 需要检查左值类型（因为要读取左值）
- 右值类型必须与左值类型兼容

**类型兼容性检查**：

```go
if !typeSys.AutoType(exp.Right.Type, exp.Left.Type, exp.Right.IsConst()) {
    Error("cannot use X as type Y in assignment")
    return false
}
```

**exp.Type 设置**：`exp.Type = exp.Left.Type`（赋值表达式的结果是左值类型）

***

### 15. `checkIndexAssign(p *Parser) bool`

**位置**：`exp_check.go:L190-212`

**签名**：`func (exp *Expression) checkIndexAssign(p *Parser) bool`

**功能**：索引赋值类型检查，确保右值类型与列表元素类型兼容。

**规则**：

- 检查左子（列表索引表达式）
- 检查右子（赋值值）
- 若左子类型为 `ListType`，右值类型必须与 `Elem` 兼容

**错误消息**：

- `"cannot use string as type int in index assignment"` — 类型不兼容

***

### 16. `checkUnary(p *Parser) bool`

**位置**：`exp_check.go:L368-413`

**签名**：`func (exp *Expression) checkUnary(p *Parser) bool`

**功能**：一元运算符检查（前缀 `-`、`!`、`~`）+ 常量折叠。

**一元运算符规则表**：

| Separator | 操作数类型要求          | exp.Type          | 常量折叠                        |
| --------- | ---------------- | ----------------- | --------------------------- |
| `-`       | `int/uint/float` | 继承操作数             | `-Num` + `foldNum()`        |
| `-`       | 非数值              | `checkOverload()` | 无                           |
| `!`       | `bool`           | `bool`            | `!Bool` + `foldBin()`       |
| `!`       | 非 bool           | `checkOverload()` | 无                           |
| `~`       | `int`            | `int`             | `^int64(Num)` + `foldNum()` |
| `~`       | 非 int            | `checkOverload()` | 无                           |

***

### 17. `checkListLiteral(p *Parser) bool`

**位置**：`exp_check.go:L342-365`

**签名**：`func (exp *Expression) checkListLiteral(p *Parser) bool`

**功能**：列表字面量元素类型检查。

**规则**：

- 逐个检查 `ListElems` 中每个元素
- 元素类型必须与列表元素类型兼容（通过 `AutoType`）

**错误消息**：

- `"list literal has no type"` — 列表类型未设置
- `"cannot use string as type int in list literal"` — 元素类型不兼容

***

## 常量折叠详细说明

### 折叠条件

```go
func (exp *Expression) IsConst() bool {
    return exp.Var == nil && exp.Call == nil && exp.Separator == "" && exp.ListElems == nil
}
```

在二元运算中，折叠条件为：`exp.Left.IsConst() && exp.Right.IsConst()`

### `foldNum(value float64)`

**位置**：`exp_check.go:L545-555`

**功能**：设置数值常量，推导类型，清空子节点。

```go
exp.Num = value
if exp.Num == float64(int(exp.Num)) {
    exp.Type = int    // 整数
} else {
    exp.Type = f64    // 浮点数
}
exp.Separator = ""    // 清空运算符
exp.Left = nil        // 清空左子
exp.Right = nil       // 清空右子
```

### `foldBin()`

**位置**：`exp_check.go:L558-562`

**功能**：清空运算符和子节点（值已存入 `Bool`）。

```go
exp.Separator = ""
exp.Left = nil
exp.Right = nil
```

### `foldArith(p *Parser) bool`

**位置**：`exp_check.go:L565-602`

**功能**：算术常量折叠，返回 false 表示折叠失败（除零）。

**运算符计算表**：

| Separator | 计算公式                      | 除零保护                         |
| --------- | ------------------------- | ---------------------------- |
| `+`       | `left + right`            | 无                            |
| `-`       | `left - right`            | 无                            |
| `*`       | `left * right`            | 无                            |
| `/`       | `left / right`            | **有**（报错 "division by zero"） |
| `%`       | `int(left) % int(right)`  | **有**（报错 "modulo by zero"）   |
| `^`       | `pow(left, right)`        | 无                            |
| `<<`      | `int(left) << int(right)` | 无                            |
| `>>`      | `int(left) >> int(right)` | 无                            |
| `&`       | `int(left) & int(right)`  | 无                            |
| `\|`      | `int(left) \| int(right)` | 无                            |

**错误消息**：

- `"division by zero"` — 除零
- `"modulo by zero"` — 取模零

### `foldCmp()`

**位置**：`exp_check.go:L605-623`

**功能**：比较常量折叠，结果存入 `Bool`。

```go
switch exp.Separator {
case "<":  result = left < right
case ">":  result = left > right
case "<=": result = left <= right
case ">=": result = left >= right
}
exp.Bool = result
exp.foldBin()
```

### `foldEq()`

**位置**：`exp_check.go:L626-648`

**功能**：相等常量折叠，整数用 int64 精确比较。

```go
if leftKind == "int" || leftKind == "uint" || rightKind == "int" || rightKind == "uint" {
    result = int64(left.Num) == int64(right.Num)  // 整数精确比较
} else {
    result = left.Num == right.Num                // 浮点直接比较
}
if exp.Separator == "!=" {
    result = !result
}
exp.Bool = result
exp.foldBin()
```

***

## 运算符优先级表

```go
var opTable = map[string]int{
    "||": 1,     // 最低优先级
    "&&": 2,
    "==": 3, "!=": 3,
    "<":  4, ">": 4, "<=": 4, ">=": 4,
    "|":  5,
    "^":  6,
    "&":  7,
    "~":  8, "!": 8,  // 一元运算符
    "<<": 9, ">>": 9,
    "+":  10, "-": 10,
    "*":  11, "/": 11, "%": 11,
    "[]": 100,        // 最高优先级
}
```

**规则**：值越大优先级越高。左结合运算符的右绑定力 `rbp = bp + 1`。

***

## 字段访问解析

### `fieldExpr(name Name) *Expression`

**位置**：`parser.go:L140-179`

**功能**：解析字段访问表达式 `a.b`，返回 Expression 节点。

**构建的 AST 结构**：

```
a.b  →  Separator: ".", Left: Var(a), Right: Var(b)
```

### `fieldExprFromExp(left *Expression) *Expression`

**位置**：`parser.go:L182-208`

**功能**：从已有表达式继续解析字段访问（处理 `a.b.c` 多级链式访问）。

**构建的 AST 结构**：

```
a.b.c  →  Separator: "."
         ├→ Left: (Separator: ".", Left: Var(a), Right: Var(b))
         └→ Right: Var(c)
```

***

## 完整调用链示例

### 示例 1：变量赋值

```
x = 1 + 2 * 3
  ↓
VarBlock.Check(p)
  └→ exp.Check(p)             [exp 是 "1 + 2 * 3"]
       └→ checkOp(p)           [Separator = "+"]
            ├→ Left.Check(p)   [exp 是 "1", 常量，直接返回]
            ├→ Right.Check(p)  [exp 是 "2 * 3"]
            │    └→ checkOp(p) [Separator = "*"]
            │         ├→ Left.Check(p)  [常量]
            │         ├→ Right.Check(p) [常量]
            │         └→ checkArith(p)  [数值乘法]
            │              └→ foldArith() → Num = 6
            └→ checkAdd(p)
                 └→ checkArith(p)
                      └→ foldArith() → Num = 7
```

### 示例 2：列表索引

```
arr[i] = 42
  ↓
Expression.Check(p)             [exp 是 "arr[i] = 42"]
  └→ checkOp(p)                 [Separator = "="]
       └→ checkAssign(p)
            ├→ Left.Separator == "[]" → 转为 "[]="
            └→ checkIndexAssign(p)
                 ├→ Left.Check(p)     [exp 是 "arr[i]"]
                 │    └→ checkIndex(p)
                 │         └→ Index[0].Check(p)  [变量 i]
                 │              └→ checkVar(p)
                 │                   └→ ParseDefine → Type = int
                 │         └→ exp.Type = ElemType
                 └→ Right.Check(p)    [常量 42]
                      └→ AutoType(int, ElemType, true)
```

### 示例 3：字段访问

```
point.x + point.y
  ↓
Expression.Check(p)
  └→ checkOp(p)                 [Separator = "+"]
       ├→ Left.Check(p)         [exp 是 "point.x"]
       │    └→ checkOp(p)       [Separator = "."]
       │         └→ checkField(p)
       │              └→ Left.Type.Fields() 查找 "x"
       │                   └→ exp.Type = int
       ├→ Right.Check(p)        [exp 是 "point.y"]
       │    └→ checkOp(p)       [Separator = "."]
       │         └→ checkField(p)
       │              └→ Left.Type.Fields() 查找 "y"
       │                   └→ exp.Type = int
       └→ checkAdd(p)
            └→ checkArith(p)
                 └→ exp.Type = int
```

***

## AutoType 类型兼容性

`typeSys.AutoType(before, after, isConst)` 检查 `before` 类型是否可以隐式转换为 `after` 类型。

**规则**：

1. 类型名和指针属性完全相同 → `true`
2. 同类别（`int/uint/float`）且指针属性相同 → 若 `isConst` 则 `true`，否则按大小比较
3. `isConst` 时 `int/uint/float` 之间互转 → `true`
4. `list` 类型不允许隐式转换

***

## 错误消息汇总

| 错误类别  | 错误消息                                           | 触发函数               |
| ----- | ---------------------------------------------- | ------------------ |
| 类型错误  | `"undefined variable: name"`                   | `checkVar`         |
| 类型错误  | `"function call must return one value"`        | `checkCall`        |
| 类型错误  | `"left operand of '.' has no type"`            | `checkField`       |
| 类型错误  | `"type X has no fields"`                       | `checkField`       |
| 类型错误  | `"field name is empty"`                        | `checkField`       |
| 类型错误  | `"struct X has no field 'Y'"`                  | `checkField`       |
| 类型错误  | `"operator + not defined for type X"`          | `checkOverload`    |
| 类型错误  | `"left operand of '[]' has no type"`           | `checkIndex`       |
| 类型错误  | `"list literal has no type"`                   | `checkListLiteral` |
| 类型错误  | `"cannot use X as type Y in list literal"`     | `checkListLiteral` |
| 类型错误  | `"left operand of '&&' must be bool, not X"`   | `checkLogic`       |
| 类型错误  | `"right operand of '&&' must be bool, not X"`  | `checkLogic`       |
| 类型错误  | `"cannot use X as type Y in assignment"`       | `checkAssign`      |
| 类型错误  | `"cannot use X as type Y in index assignment"` | `checkIndexAssign` |
| 语法错误  | `"unary operator '-' needs operand"`           | `checkUnary`       |
| 运行时错误 | `"division by zero"`                           | `foldArith`        |
| 运行时错误 | `"modulo by zero"`                             | `foldArith`        |

