# Cuteify 前端表达式解析完整文档

## 概述

表达式解析器（`parser/exp.go`，1256行）是前端最复杂的模块，基于 **Pratt Parser**（运算符优先级解析）实现，包含三个核心阶段：

1. **解析**（Parsing）：Token流 → AST
2. **语义检查**（Check）：类型推导 + 常量折叠
3. **调试输出**（String）：AST → 可读字符串

---

## 一、核心数据结构

### Expression

```go
type Expression struct {
    Call      *CallBlock     // 函数调用块
    Num       float64        // 数值常量
    Separator string         // 运算符或特殊标记
    Right     *Expression    // 右操作数
    Left      *Expression    // 左操作数
    Father    *Expression    // 父节点
    Var       *VarBlock      // 变量引用
    StringVal string         // 字符串常量
    Bool      bool           // 布尔常量
    ConstBool bool           // 预留
    Type      typeSys.Type   // 数据类型
    Field     *Expression    // 预留
    ListElems []*Expression  // 列表元素
    checked   bool           // 已检查标记
}
```

**表达式类型判定规则**（优先级从高到低）：

| 条件 | 表达式类型 | 示例 |
|------|-----------|------|
| `Call != nil` | 函数调用 | `foo(1)` |
| `Var != nil` | 变量引用 | `x` |
| `Separator == "list_lit"` | 列表字面量 | `[]int{1,2}` |
| `Separator != ""` | 运算表达式 | `a + b` |
| 其余 | 常量 | `42`, `"hello"`, `true` |

**常量折叠规则**：折叠后 `Separator=""`, `Left=nil`, `Right=nil`，值存入 `Num`/`Bool`/`StringVal`。

---

## 二、Pratt Parser 机制

### 2.1 绑定力表（bpTable）

每个运算符对应 `[leftBP, rightBP]`：

| 优先级 | 运算符 | 结合性 | lbp | rbp |
|--------|--------|--------|-----|-----|
| 1 | `= := += -= *= /= %= ^= &= \|= <<= >>=` | 右结合 | 1 | 1 |
| 2-3 | `\|\|` | 左结合 | 2 | 3 |
| 4-5 | `&&` | 左结合 | 4 | 5 |
| 6-7 | `== !=` | 左结合 | 6 | 7 |
| 8-9 | `< > <= >=` | 左结合 | 8 | 9 |
| 10-11 | `\|` | 左结合 | 10 | 11 |
| 12-13 | `^` | 左结合 | 12 | 13 |
| 14-15 | `&` | 左结合 | 14 | 15 |
| 16-17 | `<< >>` | 左结合 | 16 | 17 |
| 18-19 | `+ -` | 左结合 | 18 | 19 |
| 20-21 | `* / %` | 左结合 | 20 | 21 |
| 24-25 | `. [` | 左结合 | 24 | 25 |

**前缀运算符**绑定力：`-`/`!`/`~` → 13

### 2.2 解析流程

```
ParseExp(stopCursor)
  └→ parseExpr(stopCursor, minBP=0)
       ├→ nud(stopCursor)          // 解析左操作数（前缀表达式）
       └→ 循环:
            ├→ peek()              // 向前看一个Token
            ├→ if lbp(op) <= minBP → break  // 优先级不足，停止
            ├→ Next()              // 消费运算符
            └→ led(left, opToken)  // 解析中缀/后缀表达式
```

### 2.3 nud（null denotation）— 前缀表达式

处理没有左操作数的Token：

| Token类型 | 处理逻辑 |
|-----------|---------|
| NUMBER | 解析为float64，整数→int类型，小数→f64类型 |
| STRING/CHAR/RAW | 创建字符串常量表达式 |
| BOOL | 创建布尔常量表达式 |
| NAME | 调用 `parseName`（见下文） |
| `(` | 递归解析括号内表达式 |
| `-` | 前缀取负：常量直接取反，否则创建 Separator="-" 的一元表达式 |
| `!` | 逻辑非：创建 Separator="!" 的一元表达式，类型bool |
| `~` | 按位取反：创建 Separator="~" 的一元表达式，继承操作数类型 |
| `[` | 调用 `parseListLiteral` |
| `;`/`\n`/`\r` | 语句结束，回退光标，返回nil |

### 2.4 led（left denotation）— 中缀/后缀表达式

处理有左操作数的运算符：

| 运算符 | 处理逻辑 |
|--------|---------|
| 二元运算符 | 递归 `parseExpr(rbp)`，构建 `Separator=op, Left, Right` |
| `.` | 读取字段名，构建 `Separator="."` |
| `[` | 索引访问或切片（见下文） |
| 赋值运算符 | `++`/`--`→`parseInc`，其余递归解析右值 |
| `(` | 从左表达式提取函数名，调用 `CallBlock.ParseCall` |

### 2.5 索引/切片语法

```
list[index]           → Separator="[]"  Left=list Right=index
list[start:end]       → Separator="[::]" Left=list Right={Left=start, Right={Left=end}}
list[start:end:step]  → Separator="[::]" Left=list Right={Left=start, Right={Left=end, Right=step}}
list[:]               → Separator="[::]" Left=list Right={Left=nil, Right={Left=nil}}
```

切片AST结构嵌套：`Right.Left`=start, `Right.Right.Left`=end, `Right.Right.Right`=step

### 2.6 parseName — 标识符解析决策树

```
parseName(token)
  ├→ 读取Name（可能多段如 a.b.c）
  │
  ├→ len(name) > 1?
  │   ├→ 后跟"(" → 方法调用 CallBlock{Name=name}
  │   └→ 否则     → fieldExpr(name) 字段访问链
  │
  └→ len(name) == 1（单段名称）
      ├→ 后跟"("  → 函数调用 CallBlock{Name=name}
      ├→ 后跟"."  → 读取完整路径名
      │   ├→ 下一个是"(" → 方法调用
      │   └→ 否则         → fieldExpr
      ├→ 后跟赋值运算符 → VarBlock.ParseVar 变量声明/赋值
      └→ 其他          → varExpr(name) 普通变量引用
```

### 2.7 fieldExpr — 字段访问链构建

将 `a.b.c` 构建为嵌套表达式树：

```
      .
     / \
    .   c
   / \
  a   b
```

特殊处理 `this`：若首段为 `this`，使用 `getThisType()` 获取当前函数的类类型。

### 2.8 parseInc — 自增/自减转换

```
x++  →  Separator="+"  Left=x  Right=1
x--  →  Separator="-"  Left=x  Right=1
```

### 2.9 parseListLiteral — 列表字面量

语法：`[]Type{elem1, elem2, ...}`

解析流程：消费 `]` → 读取类型名 → 消费 `{` → 逐个解析元素 → 消费 `}`

结果：`Separator="list_lit"`, `ListElems=[elem1, elem2, ...]`, `Type=*ListType`

---

## 三、语义检查（Check）

### 3.1 检查入口

```
Expression.Check(p)
  ├→ CheckVar(p)       // 变量引用解析
  ├→ checkCall(p)      // 函数调用检查（确保恰好1个返回值）
  └→ checkOp(p)        // 运算符类型检查 + 常量折叠
```

### 3.2 checkOp 分发逻辑

```
checkOp(p)
  ├→ "list_lit"    → 检查元素类型与列表元素类型兼容
  ├→ "!" / "~"     → 一元运算符检查 + 常量折叠
  ├→ "-" (Left==nil)→ 一元取负检查 + 常量折叠
  │
  ├→ 左右子节点Check
  │
  ├→ "."           → checkField（左操作数必须有类型）
  ├→ "[]"          → 列表索引：Type=ElemType，否则 checkOverload
  ├→ "[]="         → 列表索引赋值：检查index和value，否则 checkOverload
  ├→ "[::]"        → 列表切片：Type=ListType，否则 checkOverload
  ├→ "-" / "/" / "%" / "<<" / ">>" / "&" / "|" → checkArith → 失败则 checkOverload
  ├→ "+"           → checkAdd → 失败则 checkOverload
  ├→ "*"           → checkMul → 失败则 checkOverload
  ├→ "^"           → checkArith → 失败则 checkOverload
  ├→ "==" / "!="   → checkEq → 失败则 checkOverload
  ├→ "<" / ">" / "<=" / ">=" → checkCmp → 失败则 checkOverload
  ├→ "&&" / "||"   → checkLogic
  ├→ ""            → 已折叠，直接通过
  └→ 赋值运算符     → list[index]=value 转换为 "[]="，其余直接通过
```

### 3.3 运算符重载（checkOverload）

当左操作数为自定义类型（非内置类型）时，查找 `TypeName.methodName` 方法：

| 运算符 | 方法名 |
|--------|--------|
| `+` | `add` |
| `-` | `sub` |
| `*` | `mul` |
| `/` | `div` |
| `%` | `mod` |
| `^` | `pow` |
| `==` | `eq` |
| `!=` | `ne` |
| `<` | `lt` |
| `>` | `gt` |
| `<=` | `le` |
| `>=` | `ge` |
| `&` | `band` |
| `\|` | `bor` |
| `<<` | `shl` |
| `>>` | `shr` |
| `[]` | `get` |
| `[]=` | `set` |
| `[::]` | `slice` |

一元运算符重载：`-`→`neg`, `!`→`not`, `~`→`bnot`

### 3.4 类型检查规则

#### checkArith（算术运算：`- / % << >> & | ^`）

| 左类型 | 右类型 | 结果类型 | 常量折叠 |
|--------|--------|---------|---------|
| int/uint/float | int/uint/float | float+float→f64，否则→int | foldArith |
| 其他 | 其他 | → checkOverload | - |

#### checkAdd（加法：`+`）

| 左类型 | 右类型 | 结果类型 | 常量折叠 |
|--------|--------|---------|---------|
| int/uint/float | int/uint/float | float+float→f64，否则→int | foldNum(a+b) |
| string | string | string | StringVal拼接 |
| 其他 | 其他 | → checkOverload | - |

#### checkMul（乘法：`*`）

| 左类型 | 右类型 | 结果类型 | 常量折叠 |
|--------|--------|---------|---------|
| int/uint/float | int/uint/float | float*float→f64，否则→int | foldNum(a*b) |
| string | int | string | strings.Repeat |
| 其他 | 其他 | → checkOverload | - |

#### checkEq（相等：`== !=`）

| 左类型 | 右类型 | 结果类型 | 常量折叠 |
|--------|--------|---------|---------|
| 同类别 | 同类别 | bool | foldEq（整数int64精确比较） |
| 不同类别 | - | 失败 | - |

#### checkCmp（比较：`< > <= >=`）

| 左类型 | 右类型 | 结果类型 | 常量折叠 |
|--------|--------|---------|---------|
| int/uint/float | int/uint/float | bool | foldCmp |
| string | string | bool | 不折叠 |
| 其他 | 其他 | → checkOverload | - |

#### checkLogic（逻辑：`&& ||`）

| 左类型 | 右类型 | 结果类型 | 常量折叠 |
|--------|--------|---------|---------|
| bool | bool | bool | 直接计算布尔逻辑 |

---

## 四、常量折叠

### 4.1 折叠条件

`IsConst()` 返回 `true` 的条件：`Var==nil && Call==nil && Separator=="" && ListElems==nil`

即：无变量引用、无函数调用、无运算符、无列表字面量。

### 4.2 折叠函数

| 函数 | 触发条件 | 行为 |
|------|---------|------|
| `foldNum(value)` | 数值运算结果 | 设置Num，整数→int类型，小数→f64类型，清空Separator/Left/Right |
| `foldBin()` | 布尔/比较运算结果 | 清空Separator/Left/Right（值已存入Bool） |
| `foldArith(left, right)` | 算术常量运算 | 按Separator分发：`-`→减, `/`→除(除零保护), `%`→模(除零保护), `^`→幂, `<<`→左移, `>>`→右移, `&`→位与, `\|`→位或 |
| `foldCmp(left, right)` | 比较常量运算 | 按Separator计算布尔结果，调用foldBin |
| `foldEq(left, right)` | 相等常量运算 | 整数用int64精确比较，浮点直接比较，调用foldBin |

### 4.3 一元运算符折叠

在 `checkOp` 中直接处理：

| 运算符 | 常量折叠 | 类型推导 |
|--------|---------|---------|
| `-`（前缀） | `Num = -Num` | 继承操作数类型 |
| `!` | `Bool = !Bool` | bool |
| `~` | `Num = float64(^int(Num))` | int |

### 4.4 特殊折叠

| 运算 | 折叠行为 |
|------|---------|
| 字符串+字符串 | `StringVal = left + right` |
| 字符串*整数 | `StringVal = strings.Repeat(left, int(right))` |
| `&&` | `Bool = left.Bool && right.Bool` |
| `\|\|` | `Bool = left.Bool \|\| right.Bool` |

---

## 五、变量解析

### 5.1 CheckVar 流程

```
CheckVar(p)
  ├→ Var == nil → 返回true（非变量表达式）
  │
  ├→ Var.Value != nil → VarBlock.Check(p) 推导类型
  │
  ├→ Var.Define == nil → ParseDefine(p) 在作用域链中查找定义
  │
  ├→ Var.Type != nil → 直接使用
  │
  └→ Var.Define != nil → setVar(v) 从定义节点复制类型和偏移
```

### 5.2 setVar — 类型/偏移复制

从定义节点（VarBlock或ArgBlock）复制 `Offset` 和 `Type` 到当前变量引用：

```
setVar(v)
  ├→ v.Define == nil → 使用v自身的Type
  ├→ v.Define.Value 是 *VarBlock → 复制 def.Offset, def.Type
  └→ v.Define.Value 是 *ArgBlock → 复制 def.Offset, def.Type
```

---

## 六、AST结构示例

### 6.1 简单运算

源码：`a + b * c`

```
        +
       / \
      a    *
          / \
         b   c
```

### 6.2 字段访问

源码：`this.x.y`

```
        .
       / \
      .   y
     / \
  this   x
```

### 6.3 切片

源码：`list[1:3]`

```
     [::]
     /   \
  list    .
         / \
        1   3
```

其中 `Right.Left`=start(1), `Right.Right.Left`=end(3), `Right.Right.Right`=step(nil)

### 6.4 索引赋值

源码：`list[0] = 42`

checkOp 阶段自动转换：

```
转换前:          转换后:
  =              []=
 / \            /   \
[]  42       list    .
/ \                 / \
list 0             0   42
```

### 6.5 方法调用

源码：`obj.method(1, 2)`

led 阶段处理 `(` 时，从左表达式 `obj.method` 提取：
- `call.Name = ["obj", "method"]`
- `call.ThisVar = &VarBlock{Name=["obj"]}`

---

## 七、辅助函数速查

| 函数 | 签名 | 说明 |
|------|------|------|
| lbp | `func lbp(op string) int` | 运算符左绑定力 |
| rbp | `func rbp(op string) int` | 运算符右绑定力 |
| isBinOp | `func isBinOp(op string) bool` | 是否为二元算术/逻辑/位运算符 |
| isAssign | `func isAssign(op string) bool` | 是否为赋值类运算符 |
| peek | `func (p *Parser) peek(stopCursor int) Token` | 向前看一个Token不消费 |
| getThisType | `func (p *Parser) getThisType() Type` | 获取this指针的类类型 |
| FindVar | `func (exp *Expression) FindVar(v Block) bool` | 递归查找是否引用了指定变量 |
| IsConst | `func (exp *Expression) IsConst() bool` | 是否为编译期常量 |
| String | `func (exp *Expression) String() string` | 调试用字符串表示 |
| valStr | `func (exp *Expression) valStr() string` | 叶节点字符串表示 |
| Print | `func (exp *Expression) Print()` | 打印表达式树 |
