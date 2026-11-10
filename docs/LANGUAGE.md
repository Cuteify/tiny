# Cute 语言语法参考（现行实现）

> 本文描述当前仓库中 **Go 版编译器**（`main.go` + `lexer/` + `parser/` + `type/` + `compile/`）实际接受并实现的语法。
> 自举 parser（`selfhost/`）的支持范围是另一套事实，见 [`SELFHOST.md`](SELFHOST.md) §5；两者不能互相替代。
>
> - 验证目标：`x86_64`，`nasm 2.16.03`，`gcc -nostartfiles -no-pie -e _start`
> - 事实源：`lexer/keywords.go`、`lexer/lexer.go`、`parser/*.go`、`type/*.go`、`compile/*.go`
> - 类型内建与重载的唯一事实源：`parser/intrinsic.go` + [`stdplan/TYPE_INTRINSIC.md`](stdplan/TYPE_INTRINSIC.md)
> - `PROJECT.md` §8 是过期速记；与本文冲突时以源码和本文为准，差异汇总见 §16。
>
> 图例：
>
> - ✅ **可用**：解析、编译、运行均符合描述（在 x86_64 探针环境）。
> - ⚠️ **仅解析 / 部分可用**：能过 parser 或只在受限场景可用，限制已注明。
> - ❌ **不支持**：解析或编译报错，或运行结果不可用。
>
> 本文把“能解析但运行/编译无效或崩溃”的写法单列为已知缺陷（§15），不写成可用特性。

---

## 目录

1. [词法](#1-词法)
2. [顶层声明](#2-顶层声明)
3. [函数](#3-函数)
4. [变量、常量与赋值](#4-变量常量与赋值)
5. [类型系统](#5-类型系统)
6. [结构体](#6-结构体)
7. [接口](#7-接口)
8. [枚举](#8-枚举)
9. [语句](#9-语句)
10. [表达式与运算符](#10-表达式与运算符)
11. [内建函数与自动包](#11-内建函数与自动包)
12. [build 指令](#12-build-指令)
13. [import](#13-import)
14. [语法糖与便利写法](#14-语法糖与便利写法)
15. [已知缺陷与未实现清单](#15-已知缺陷与未实现清单)
16. [与 PROJECT.md §8 的差异](#16-与-projectmd-8-的差异)
17. [复现与验收](#17-复现与验收)

---

## 1. 词法

### 1.1 源文件与注释

| 项目 | 状态 | 说明 |
|---|---|---|
| 源文件编码 | ✅ | UTF-8 文本；空文件会触发 lexer panic（`Lexer:Text is empty`） |
| 行注释 `// ...` | ✅ | 注释持续到行末 |
| 块注释 `/* ... */` | ✅ | 非嵌套（C 风格）；允许跨行；`*/` 结束 |
| 续行 | ❌ | 没有反斜杠续行；语句在换行处结束 |

### 1.2 空白与语句分隔

| 项目 | 状态 | 说明 |
|---|---|---|
| 空格 / 制表符 | ✅ | 仅作空白跳过 |
| 换行 | ✅ | 与 `;` 一样是语句分隔符 |
| 分号 `;` | ✅ | 可替代换行分隔语句 |
| CRLF / LF | ✅ | lexer 会识别并统一处理行尾 |

### 1.3 标识符

标识符规则与 Go 的 ASCII 子集一致：

```text
[A-Za-z_][A-Za-z0-9_]*
```

- ✅ 首字符必须是 ASCII 字母或 `_`。
- ✅ 后续字符可以是 ASCII 字母、数字或 `_`。
- ❌ 不支持 Unicode 标识符。
- ❌ 标识符里不能直接出现 `$`、`-`、`.` 等字符（`.` 只用于字段/包路径语法）。

### 1.4 关键字

`lexer/keywords.go` 词法表登记的关键字与伪关键字如下。**登记为关键字不等于 parser 实现了它**。

| 关键字 | 状态 | 说明 |
|---|---|---|
| `if` / `else` | ✅ | 条件语句 |
| `for` | ✅ | 传统 for 与 range |
| `range` | ✅ | 仅 `for ... range` 上下文 |
| `return` / `ret` | ✅ | 两者等价 |
| `break` | ✅ | 支持 `break`、`break N`、`break(N)`；同时统计 for 与 switch |
| `switch` / `case` / `default` | ✅ | 带目标、单值 case 可用；支持 `break` 与 `fallthrough` |
| `type` | ✅ | 别名、结构体、接口 |
| `struct` | ✅ | 结构体声明 |
| `interface` | ⚠️ | 仅 `type X interface { ... }` 形式 |
| `enum` | ✅ | 枚举声明 |
| `fn` | ✅ | 函数、方法 |
| `var` | ✅ | 变量声明 |
| `const` | ✅ | 常量声明（只读不强制，见 §4.5） |
| `let` | ⚠️ | 可用，但会发 `let is not support, use var instead` 警告 |
| `build` | ✅ | 编译指令 |
| `import` | ✅ | 文件顶层导入 |
| `true` / `false` | ✅ | 布尔字面量 |
| `nil` | ✅ | 空指针常量（词法上归入 BOOL） |
| `self` | ✅ | 词法表中登记为 NAME（普通标识符）；仅方法接收者位置有特殊含义 |
| `continue` | ✅ | 支持 `continue`、`continue N`、`continue(N)`；只统计 for 循环 |
| `defer` | ❌ | 关键字被 parser 静默丢弃；后续调用按普通语句立即执行 |
| `while` | ✅ | `while cond { ... }`；复用 for 代码生成 |
| `try` / `except` / `finally` | ❌ | 关键字保留；遇到时显式报 `'try' is not supported yet`（不会静默跳过） |
| `fallthrough` | ✅ | 仅允许作为 switch case 的最后一条语句；最后一个 case 禁止使用 |

### 1.5 字面量

#### 整数字面量 ✅

| 形式 | 示例 | 说明 |
|---|---|---|
| 十进制 | `42` | 常规 |
| 十六进制 | `0xFF` / `0Xff` | `0x` / `0X` |
| 二进制 | `0b1010` / `0B1010` | `0b` / `0B` |
| 八进制（前缀） | `0o755` / `0O755` | `0o` / `0O` |
| 八进制（C 风格前导零） | `010` | 等于 8 |
| 下划线分隔 | `1_000_000` | 解析前删除 `_` |

- 没有 `u` / `l` / `i64` 之类的字面量后缀。
- 字面量类型：值在 `int32` 范围内时是 `int`；超出 `int32` 范围自动提升为 `i64`。
- 超大十进制常量受 `float64` 解析路径限制，超过 `int64` 的精度会丢失（见 §15）。

#### 浮点字面量 ⚠️

| 形式 | 示例 | 说明 |
|---|---|---|
| 小数点 | `1.5` / `0.0` | 类型为 `f64` |
| 科学计数法 | `1e3` / `2.5E-2` | 类型为 `f64` |
| 十六进制浮点 | ❌ | 不支持 |

浮点字面量能解析、能声明变量、能参与部分算术与比较（实测 `1.5 + 2.0 > 3.0` 成立），但后端不完整：运行期浮点除法会走整数路径，除零触发 SIGFPE（见 §15）。

#### 字符串字面量 ✅（有限制）

- 双引号 `"..."`。
- **不做转义处理**：`\n`、`\t`、`\"` 都按两个字符原样保留。
  - 例：`len("hello\nworld")` 等于 12，不是 11。
- 因此字符串内容里不能直接出现未转义的双引号（会提前结束）。
- 字符串类型在 x86_64 上是 24 字节头：`ptr@0`、`len@8`、`cap@16`。

#### 原始字符串（反引号）✅

- 语法：`` `...` ``，内容原样保留，不处理转义。
- 单行原始字符串可用。

#### 字符字面量 ✅

- 单引号 `'a'`、`'\n'`、`'\x41'` 等。
- 通过 `strconv.Unquote` 解析转义。
- 类型是 `int`，不是 `byte` 或 `rune`。
- 例：`'\n'` 的值是 10。

#### 布尔与 nil ✅

- `true` / `false`，类型 `bool`。
- `nil` 是空指针常量；可用于 `*T`、`ptr`、map 等零值语境。
- `nil` 不是“万能空值”：`e == nil` 对 `error` 接口会报运算符错误（见 §7.4）。

### 1.6 运算符与标点

lexer 登记的运算符/标点：

```text
// ; { } ( ) [ ] , : . @ ? ~
= + - * / % < > & | ^ ! 
== != <= >= ++ -- -> ... && || << >> :=
+= -= *= /= %= ^= &= |= <<= >>=
" ' ` \
```

其中 `->` 目前没有 parser 分支。`...` 只在参数列表末尾用于变参形参与实参（`xs ...int`），其它位置无语法入口。

---

## 2. 顶层声明

### 2.1 支持的顶层形式

| 形式 | 状态 | 示例 |
|---|---|---|
| 函数 | ✅ | `fn add(a: int, b: int) int { ret a + b }` |
| 变量 | ✅ | `var g: int = 5` |
| 常量 | ✅ | `const c: int = 7` |
| 类型别名/定义 | ✅ | `type MyInt = int` / `type MyInt int` |
| 结构体 | ✅ | `struct P { x: int }` 或 `type P struct { x: int }` |
| 接口 | ✅ | `type I interface { ... }` 或裸 `interface I { ... }` |
| 枚举 | ✅ | `enum Color { Red; Green = 5 }` |
| 分组声明 | ✅ | `var ( ... )` / `const ( ... )` / `let ( ... )` / `type ( ... )` |
| 推断声明 | ✅ | `var x = 5` / `const x = 5`（按值推断） |
| 导入 | ✅ | `import "std:memory"` |
| 编译指令 | ✅ | `build arch("x86_64")` |
| 顶层 `:=` | ✅ | `g := 5` |
| 顶层 `let` | ⚠️ | `let g: int = 5`，可用但告警 |

顶层声明之间用换行或 `;` 分隔。

### 2.2 顶层形式（已支持）

| 形式 | 状态 | 现象 |
|---|---|---|
| `var x = 5`（省略类型） | ✅ | 类型按值推断；初始化省略时才报错 |
| `const x = 5`（省略类型） | ✅ | 同上 |
| `var ( ... )` 分组 | ✅ | 多条逐行声明，语法与单行一致 |
| `const ( ... )` 分组 | ✅ | 同上 |
| `type ( ... )` 分组 | ✅ | 多条类型逐行声明 |
| `let ( ... )` 分组 | ✅ | 同 `var` 分组，`let` 会发警告 |
| 裸 `interface I { ... }` | ✅ | 等价于 `type I interface { ... }` |

### 2.3 声明顺序与前向引用

- 同包内跨文件的前向引用由包合并后的 `rootNode.Check()` 重试解决。
- 解析期查不到的名称会标记 `Unresolved`，合并后再查；最终仍查不到才报错。
- 因此“文件按字母序解析”不应作为语言语义依赖；正常使用函数/类型的前向引用即可。

---

## 3. 函数

### 3.1 基本形式 ✅

```cute
fn add(a: int, b: int) int {
    ret a + b
}
```

- `fn` 开头，函数名，参数列表，可选返回类型，函数体。
- 无返回值时省略返回类型：

```cute
fn hello() {
    println("hi")
}
```

- 函数体必须用 `{ }`，且 `{` 必须与签名同行；`fn main() int` 后换行再写 `{` 会报 `need '{'`。

### 3.2 参数 ✅

两种写法都可用：

```cute
fn f(a: int, b: string) int { ret a }
fn f(a int, b string) int { ret a }
```

- 每个参数都必须写类型（单飞形式）；可在最后一个具名参数上统一类型：`fn f(a, b int)` 和 `fn f(a, b: int)`。
- ✅ 默认参数支持：`fn f(a: int, b: int = 10, c: string = "x")`；默认参数必须位于必带参数之后（`non-default parameter follows default parameter`）。多个默认参数可用。
- ✅ 变参支持：`fn f(xs ...int)`；调用时额外传入的参数打包成 `[]int` 传给函数（代码生成已支持打包）。
- 默认参数按小端传参的位置处理；调用方也可省略默认参数并直接写 `f(1)`。
- 参数类型可以是内建类型、别名、结构体、`[]T`、`[N]T`、`map[K]V`、`*T`、`fn(...) R`。

### 3.3 返回值 ✅

| 形式 | 示例 | 说明 |
|---|---|---|
| 无返回值 | `fn f() { }` | |
| 单返回值 | `fn f() int { ret 1 }` | |
| 多返回值 | `fn f() (int, int) { ret 1, 2 }` | 返回类型必须用括号 |
| `return` | `return 1` | 与 `ret` 等价 |
| 带括号的返回值 | `return (7)` | 可用 |

多返回值接收：

```cute
q, r := divide(17, 5)
```

- ✅ `a, b := f()` 可用。
- ✅ `a, b = f()` 与 `a, b := f()` 均可用（多值按返回槽装载解构）。

### 3.4 方法 ✅

方法签名是“**接收者作为显式首形参**”的普通函数：

```cute
type Point struct { x: int; y: int }

fn Point.move(p: *Point, dx int, dy int) {
    p.x += dx
    p.y += dy
}

fn Point.getX(p: Point) int {
    ret p.x
}

fn main() int {
    var p: Point
    p.x = 10
    p.move(5, 10)
    ret p.getX()
}
```

- 方法名是 `Type.name`（或 `Type.name` 且首形参类型为 `Type`/`*Type`）。
- 接收者为指针（`p: *Point`）：方法内改动生效到调用方对象；
  接收者为值（`p: Point`）：方法内改动只对副本生效。
- 指针接收者可直接 `ptr.method(...)`；值接收者用 `value.method(...)`。
- `self` ❌：不是合法接收者名；`(self P) m()` / `(self *P) m()` 这类旧接收者语法已废弃且当前不编译通过——用显式首形参。
- `this` ❌：同上，不是合法标识符。
- 方法体可以多行；单行体也能用，但若最后一条是字段赋值，需要在 `}` 前加 `;`（`fn P.set(v: int) { self.x = v; }`）。

### 3.5 泛型 ⚠️

基本形式：

```cute
fn identity[T](x: T) T {
    ret x
}
```

| 能力 | 状态 | 说明 |
|---|---|---|
| 单类型参数声明 | ✅ | `fn f[T](x: T) T` |
| 隐式推断 | ✅ | `identity(42)` |
| 显式实例化 | ✅ | `identity[int](42)` |
| 泛型 int 运算 | ✅ | `id(5) + id(6)` 得 11 |
| 泛型返回 `T` | ✅ | 正常 |
| 泛型字符串实例化 | ✅ | 按具体化签名单态化，字符串可参与 |
| 多类型参数 `fn f[T, U]` | ✅ | 位置绑定按实参顺序两类型分别实例化 |
| `[]T` 作为参数类型 | ✅ | 切片形参按 `[]T` 传递 |
| 泛型结构体 `Box[T]` | ✅ | 模板 + 实例化缓存；字面量 `Box[int]{...}` 可用 |
| fn 类型在 `fn(...) R` 声明/赋值/形参/返回 | ✅ | 见 §3.7 |

### 3.6 函数重载 ✅

支持同名函数重载：

```cute
fn f(a: int) int { ret 1 }
fn f(a: string) int { ret 2 }
fn f(a: int, b: int) int { ret 3 }
```

| 能力 | 状态 | 说明 |
|---|---|---|
| 同名不同参数个数 | ✅ | 按 arity 选择 |
| 同名同个数、不同类型 | ✅ | 按实参类型打分选择 |
| 实参类型不匹配 | ✅ | 报 `no matching overload` |
| 歧义调用 | ✅ | 报 `ambiguous call` |
| 函数指针按 `fn(...)` 类型选重载 | ✅ | 见 §3.7 |

重载的汇编标签规则：

- 非重载函数：原名。
- 同名不同 arity：`name + arity`。
- 同名同 arity 多定义：`name + arity + "_" + 类型标签`。
- `main` 永不加后缀。

### 3.7 函数类型与函数指针 ✅

函数类型可以声明、赋值并**通过变量调用**（间接调用，env 经隐藏约定传递）：

```cute
fn add(a: int, b: int) int { ret a + b }

fn main() int {
    var f: fn(int, int) int = add
    ret f(3, 4)   // 7
}
```

| 能力 | 状态 | 说明 |
|---|---|---|
| 声明 `fn(T1, T2) R` 类型 | ✅ | 参数类型、变量注解、结构体字段均可用 |
| 把函数名赋给函数指针变量 | ✅ | 按 `fn(...)` 形状选重载 |
| 通过变量调用 `f(3, 4)` | ✅ | fn 变量优先于同名函数（局部变量优先，帧内绑定/闭包对象走间接调用 ABI） |
| fn 类型形参 `fn apply(f: fn(int, int) int, x: int, y: int)` | ✅ | 实参检查照常；调用点按间接调用 ABI 传闭包对象 |
| fn 类型返回 `fn(int) int` | ✅ | 函数返回 fn 值（闭包对象） |
| 把函数指针赋给 `ptr` | ✅ | `AutoType` 允许 `fn → ptr` |

调用 ABI：fn 值统一为 `{code@0, env@ptrSize}` 闭包对象（堆分配）；
call site 装载 `RBX=env`，被调函数前序把 EBX/RBX 装入隐藏槽 `[ebp-8]/[rbp-48]`。

### 3.8 闭包、匿名函数、嵌套函数 ✅

三类形态统一由**同一套“env + 提升”机制**实现：

- **具名嵌套函数**：提升到包根，宿主帧位置替换为 `var name: fn(...) R = closure_N` 绑定；
- **匿名函数**：`var f: fn(int) int = fn(x: int) int { ... }`，作为表达式返回闭包对象；
- **env**：宿主帧为每个捕获的“帧内局部声明”合成一个 `$envN` 结构体堆对象
  （`var __env: *$envN = new($envN)`，env 槽存捕获字段），宿主帧与所有闭包体
  对捕获名的引用统一改写为 `__env.<name>` 二段路径。

```cute
fn main() int {
    var n: int = 7
    fn addN(x: int) int {
        ret x + n        // n 从 env 读入
    }
    if addN(3) != 10 { ret 1 }
    n = 100
    if addN(3) != 103 { ret 2 }
    ret 0
}
```

捕获语义（Go 风格引用捕获）：闭包读写的是宿主帧的同一 env 槽；
宿主帧 `n = 100` 后闭包体读到的就是 `100`。

限制：

| 形式 | 状态 | 说明 |
|---|---|---|
| `f := fn(x: int) int { ... }`（无显式 fn 注解的内联声明）| ❌ | 报 `unexpected token`；需写显式 `var f: fn(int) int = ...` |
| env 跨帧捕获（闭包体中嵌套再创建闭包，捕获祖父帧变量） | ❌ | 祖父帧变量捕获不完整（每帧各自合成 env，不形成链表）|
| 捕获变量在宿主帧内与局部嵌套块同名重定义 | ⚠️ | 走宿主帧 env（不重复分配独立局部槽）|
| 匿名闭包/具名嵌套函数作为普通函数返回值/作为列表元素保存 | ⚠️ | 保存 fn 值正常；回调场景（fn 作参数、fn 作返回）均可用 |

---

## 4. 变量、常量与赋值

### 4.1 声明形式

| 形式 | 状态 | 示例 | 说明 |
|---|---|---|---|
| `var name: T = expr` | ✅ | `var x: int = 5` | 最标准 |
| `var name: T` | ✅ | `var x: int` | 零值 |
| `name := expr` | ✅ | `x := 5` | 类型推断 |
| `name: T = expr` | ✅ | `x: int = 5` | 省略 `var` |
| `const name: T = expr` | ✅ | `const c: int = 5` | 只读不强制 |
| `let name: T = expr` | ⚠️ | `let x: int = 5` | 可用，但告警 |
| `var name = expr` | ✅ | `var x = 5` | 类型推断；无初始化必须写类型 |
| `const name = expr` | ✅ | `const x = 5` | 同上 |
| 分组声明 | ✅ | `var ( ... )` / `const ( ... )` / `let ( ... )` / `type ( ... )` | 多条逐行，语法与单行一致 |

顶层也支持 `g := 5` 和 `let g: int = 5`。

### 4.2 零值

| 类型 | 零值 |
|---|---|
| 整数 / 浮点 | `0` |
| `bool` | `false` |
| `string` | 空串（len = 0） |
| `*T` / `ptr` | `nil` |
| `[]T` | nil 切片（len = 0, cap = 0） |
| `map[K]V` | nil map（len = 0；首次写入自动初始化） |
| 结构体 | 所有字段按类型零值 |
| 定长数组 | 所有元素零值 |

`var x: int` 后直接 `ret x` 得 0（已验证）。

### 4.3 多返回值

```cute
q, r := divide(17, 5)
```

- ✅ `:=` 接收多返回值。
- ❌ `=` 接收多返回值报 `need ':=' in multi-value declaration`。
- ⚠️ `_` 不是特殊丢弃符，只是普通标识符；`q, _ := f()` 能工作，但 `_` 会被当作真实变量声明（range 里的 `_` 见 §9.4）。

### 4.4 赋值、复合赋值、自增自减

| 形式 | 状态 | 说明 |
|---|---|---|
| `x = expr` | ✅ | 普通赋值 |
| `x += expr` | ✅ | 复合赋值（`+= -= *= /= %= ^= &= \|= <<= >>=`） |
| `x++` / `x--` | ✅ | 语句形式，不能当表达式用 |
| `*p = expr` | ✅ | 解引用赋值 |
| `arr[i] = expr` | ✅ | 索引赋值 |
| `m[k] = expr` | ✅ | map 索引赋值 |
| `a, b = f()` | ✅ | `=` 与 `:=` 均可，槽位按返回顺序装载 |

`++` / `--` 是**语句**，不是表达式；不能写 `y := x++`。

### 4.5 const 语义 ⚠️

- `const` 只设置 `IsConst` 标志，**不做只读强制**。
- 对 `const` 变量重新赋值可以编译并运行（探针 `const x: int = 5; x = 9; ret x` 得 9）。
- 因此 `const` 目前只是“声明意图”，不是编译期常量保证。

### 4.6 全局变量 ✅

- 顶层 `var` / `const` / `:=` / `let` 都会成为全局变量。
- 全局变量可在函数中直接读写。
- 全局变量跨包时通过包路径限定访问（`pkg.Var`）。

---

## 5. 类型系统

### 5.1 内建类型与尺寸（x86_64）

| 源码写法 | 规范名 | 尺寸 | Kind | 说明 |
|---|---|---|---|---|
| `int` | `int` | 8 | `int` | 架构字长（x86 上 4） |
| `uint` | `uint` | 8 | `uint` | 架构字长（x86 上 4） |
| `i64` / `int64` | `i64` | 8 | `int` | |
| `u64` / `uint64` | `u64` | 8 | `uint` | |
| `i32` / `int32` / `rune` | `i32` | 4 | `int` | `rune` 是 `i32` 的别名 |
| `u32` / `uint32` | `u32` | 4 | `uint` | |
| `i16` / `int16` | `i16` | 2 | `int` | |
| `u16` / `uint16` | `u16` | 2 | `uint` | |
| `i8` / `int8` | `i8` | 1 | `int` | |
| `u8` / `uint8` | `u8` | 1 | `uint` | |
| `byte` | `byte` | 1 | `byte` | 与 `u8` 是不同类型 |
| `bool` | `bool` | 1 | `bool` | |
| `f32` | `f32` | 4 | `float` | 后端不完整 |
| `f64` | `f64` | 8 | `float` | 后端不完整 |
| `ptr` | `ptr` | 8 | `uint` | 地址语义 |
| `string` | `string` | 24 | `string` | `{ptr,len,cap}` |
| `error` | `error` | — | 接口 | 内建接口，当前不可用（§7.4） |
| `[]T` | list | 24 | `list` | `{ptr,len,cap}` |
| `[N]T` | array | `N * sizeof(T)` | `array` | 定长数组 |
| `map[K]V` | map | 8 | `map` | 单指针，指向 map header |
| `*T` | pointer | 8 | — | 指针 |

补充：

- `string` 头在 x86_64 上为 `ptr@0`、`len@8`、`cap@16`；x86 上为 `ptr@0`、`len@4`、`cap@8`。
- `[]T` 头布局与 `string` 相同（x86_64：24 字节）。
- `map[K]V` 在编译器里是单个指针，header 布局见 `docs/stdplan/TYPE_INTRINSIC.md` §3.1。
- 结构体布局：字段按自然对齐填充，**没有尾部补齐**。例：`struct { a: u8; b: u32; c: u8 }` 的 `sizeof` 是 9。
- `sizeof` 实测：`int/uint/ptr/f64 = 8`、`i32/f32 = 4`、`i16 = 2`、`bool/byte/u8 = 1`、`string = 24`。

### 5.2 复合类型

| 类型 | 语法 | 状态 | 说明 |
|---|---|---|---|
| 列表 | `[]T` | ✅ | 切片语义 |
| 定长数组 | `[N]T` | ✅ | `N` 是正整数常量 |
| map | `map[K]V` | ✅ | 索引读写可用；字面量不支持 |
| 指针 | `*T` | ✅ | 取地址/解引用 |
| 函数类型 | `fn(T1, T2) R` | ✅ | 可声明/赋值；函数指针变量可调用 `f(x)` |
| 嵌套列表类型 | `[][]T` | ⚠️ | 类型可声明；字面量报 `unexpected '['` |
| 嵌套数组类型 | `[N][M]T` | ⚠️ | 可编译；运行段错误 |
| 接口类型 | `type I interface` | ⚠️ | 无动态派发 |

### 5.3 别名与定义类型

两种写法都接受：

```cute
type MyInt = int      // 真别名
type MyInt2 int       // 新类型（底层 int）
```

| 场景 | 状态 | 说明 |
|---|---|---|
| `type MyInt = int` | ✅ | 与 `int` 互操作 |
| `type MyInt int` | ✅ | 与 `int` 互操作（整数按 Kind 放宽） |
| `type P2 = P` / `type P2 P`（结构体） | ✅ | 可用于声明变量/参数 |
| `type MyList = []int` 声明 | ✅ | 零值、`len` 可用 |
| 把 `[]int{...}` 赋给 `MyList` | ❌ | 报 `need type MyList, not []int` |
| 别名作为 `sizeof` 参数 | ✅ | 推荐用法 |
| 内联 `sizeof[[]int]()` | ❌ | 见 §11.1 |

### 5.4 类型兼容与隐式转换

赋值/初始化走 `typeSys.AutoType`。实际可观察规则：

| 规则 | 状态 | 说明 |
|---|---|---|
| 相同 `Type()` 且指针标记相同 | ✅ | 直接兼容 |
| 同 Kind、不同宽度的数值 | ✅ | 零扩展/截断，如 `i32 → i64` |
| `int` / `uint` 互转 | ✅ | 有符号/无符号按位模式处理 |
| `*T → ptr`、`ptr → *T` | ✅ | 地址语义互通 |
| `fn → ptr` | ✅ | 函数地址 |
| 常量 `0 → *T` | ✅ | 空指针 |
| 同 Kind 的 `f32 ↔ f64` | ✅ | 宽度不同，允许 |
| `int → f64` 普通赋值 | ❌ | 报 `need type f64, not int` |
| `f64 → int` 普通赋值 | ❌ | 报 `need type int, not f64` |
| `int → f64` 声明初始化 | ⚠️ | `var y: f64 = x` 能编译（初始化把右值当常量），但值不可靠 |
| `f64 → int` 声明初始化 | ⚠️ | 能编译，但实测 `5.0 → 0`、`6.9 → 154`，结果错误 |
| `[]T` / `[N]T` / `map` / 结构体之间 | ❌ | 不做隐式转换 |

**推断声明**：`var x = expr` / `const x = expr` 不写类型注解时，类型按 `expr` 推断。整数字面量超出 `int32` 范围自动提升为 `i64`；其余表达式按自身类型取整。无初始化值（`var x`）必须写类型，否则报错。

**显式数值转换**：用与目标类型同名的函数调用，语义是数值转换（截断/扩展/舍入），不是 `unsafe.cast` 的位重解释。

```cute
int(x)   uint(x)
i8(x)    i16(x)   i32(x)   i64(x)
u8(x)    u16(x)   u32(x)   u64(x)
int8(x)  int16(x) int32(x) int64(x)
uint8(x) uint16(x) uint32(x) uint64(x)
byte(x)  f32(x)   f64(x)
```

| 转换 | 状态 | 说明 |
|---|---|---|
| 整数 → 更窄整数 | ✅ | 截断低位，如 `u8(300) == 44`、`i8(200) == -56` |
| 窄整数 → 更宽整数 | ✅ | 按源类型符号扩展/零扩展，如 `int(i8(200)) == -56`、`u16(i8(-1)) == 65535` |
| 浮点 → 整数 | ✅（x86_64） | 向零截断，如 `int(3.9) == 3`、`int(-3.9) == -3` |
| 整数 → 浮点 | ✅（x86_64） | 数值转换，如 `f64(7) == 7.0` |
| `f32 ↔ f64` | ✅（x86_64） | 精度收窄/扩展 |
| 常量/变量作为源 | ✅ | 两种形态都支持 |
| `bool` / `string` / 容器作为源 | ❌ | 报 `cannot convert ...` |
| x86（32 位）浮点转换 | ❌ | 显式报 `floating-point conversion ... is not supported on 32-bit target` |
| x86（32 位）64 位标量转换 | ❌ | 显式报 `64-bit conversion ... is not supported on 32-bit target` |

**重要**：声明初始化 `var y: T = x` 在 `parser/var.go` 里把 `IsConst` 硬编码为 `true`，因此比普通赋值宽松；这只是实现差异，不应作为“跨 Kind 转换可用”的依据。需要跨 Kind 转换时一律写显式转换（如 `var y: f64 = f64(x)`）。

### 5.5 byte 与 u8 的区别 ⚠️

- `byte` 和 `u8` 都是 1 字节，但 `Type()` 和 `Kind()` 不同。
- `var b: u8 = 65` ✅。
- `var b: byte = 65` ❌ 报 `need type byte, not int`。
- 字符串索引 `s[i]` 返回 `byte`。
- `byte` 参与算术会提升为 `int`，结果不能直接赋回 `byte`。
- 把整数转成 `byte` 需要 `unsafe.cast[byte](x)`（位重解释，不是数值转换）。

### 5.6 sizeof 与类型宽度

- 推荐写法：`sizeof[T]()`，必须带括号。
- `sizeof[T]`（不带括号）会返回一个伪值（实测 56），不要使用。
- 参数必须是**具名类型或别名**；`sizeof[[]int]()`、`sizeof[[3]int]()` 会报 `unexpected '['`。
- 定长数组宽度需要先起别名：

```cute
type Arr3 = [3]int
if sizeof[Arr3]() != 24 { ret 1 }
```

---

## 6. 结构体

### 6.1 声明 ✅

两种形式等价：

```cute
struct P {
    x: int
    y: int
}

type P struct {
    x: int
    y: int
}
```

- 结构体名注册为类型，可用于变量、参数、返回值、字段、`new`。
- 字段之间用换行或 `;` 分隔。
- 字段访问：`p.x`；指针字段访问：`p.x`（自动解引用）。
- `&p.x` 可用。

### 6.2 字段语法

```cute
struct P {
    x: int
    name: string
    next: *P
}
```

- 字段名 + `:` + 类型。
- 支持自引用字段 `next: *P`（解析时 `CurStructName`/`CurStructType` 生效）。
- 字段类型可以是任意可用类型（包括 `[]T`、`[N]T`、`map[K]V`、`fn(...)`）。

### 6.3 访问修饰符 ⚠️

| 写法 | 解析结果 | 是否强制 |
|---|---|---|
| `field: T` | `AccessPublic` | — |
| `_field: T` | `AccessPrivate` | ❌ 不强制 |
| `!field: T` | `AccessReadOnly` | ❌ 不强制 |
| `?field: T` | `AccessWriteOnly` | ❌ 不强制 |
| `pub field: T` | 现在显式报错 `'pub' field modifier is not supported; use _field for private, or remove` | ❌ 无导出语义且意义不明确，不再静默忽略 |

结论：这些标记只写入 `StructField.Access`，编译期/运行期都不做读写检查（探针 `p_access` 退出 0）。

### 6.4 继承 / 嵌入 ⚠️（仅解析）

以下写法能被 parser 吃掉，但**不产生继承效果**：

```cute
struct A {
    @Parent
    alias @Parent
}

struct B : Parent {
    x: int
}
```

| 写法 | 状态 | 说明 |
|---|---|---|
| `@Parent` | ⚠️ | 记录 `ParentName`，但不展开字段 |
| `alias @Parent` | ⚠️ | 记录别名 + `ParentName`，不展开 |
| `struct B : Parent` | ⚠️ | 父名读取后被丢弃（`TODO`） |

根因：`TypeBlock.Check` 的 `Inherit` 回调期望 `results[0].Value.(*TypeBlock)`，而 `p.Find(..., FindTypeType)` 返回的是 `v.Type()`；同时 `StructBlock.Parse` 在 `:` 分支没有保存父名。两处都没修完，所以继承不可用。

### 6.5 字段默认值与标签 ⚠️（仅解析）

```cute
struct P {
    x: int = 42
    y: int `json:"y"`
}
```

| 写法 | 状态 | 说明 |
|---|---|---|
| 字段默认值 `= expr` | ⚠️ | 解析进 `field.Default`，运行时不生效；字段仍是 0 |
| RAW 标签 `` `json:"y"` `` | ⚠️ | 解析进 `field.Tags`，不参与运行/反射 |
| 普通字符串标签 | ⚠️ | 同上 |

### 6.6 构造 ✅

结构体字面量 ✅：

```cute
var p: *P = P{}             // 零值（所有字段 0）
var p: *P = P{x: 3, y: 4}   // 按名称匹配字段；未给出的字段零值
```

语义接近 `new(P, ...)`：堆分配 + 零填充 + 按字段声明顺序填值。匿名嵌入字段不能出现在字面量中。
也可以写 `new`：

```cute
var p: *P = new(P)          // 零值
var q: *P = new(P, 7, 8)    // 按字段顺序初始化
```

- `new(P, v1, v2, ...)` 按结构体字段声明顺序填值。
- `new(P)` 返回 `*P`，所有字段零值。
- `new(int, 7)` 返回指向 7 的 `*int`。
- `new([]int, 4, 8)` 返回长度 4、容量 8 的列表。
- ❌ `new([]int)`（不传长度）会在汇编阶段报 `invalid combination of opcode and operands`。
- ❌ `newRC([]int, n)` 能分配，但列表读写结果错误；`newRC(int, 7)` 正常。

### 6.7 结构体方法 ✅

见 §3.4。方法=接收者显式首形参的普通函数；值接收者按值复制，指针接收者改原对象。
方法内不可用 `self` / `this`。

### 6.8 对齐控制 ✅

`build align(N)` / `build noalign` 只对**紧随其后**的结构体生效：

```cute
build align(2)
struct Pack2 {
    a: u8
    b: u32
}
```

| 写法 | 效果 |
|---|---|
| 自然布局 | 字段按自身尺寸对齐；无尾部补齐 |
| `build align(N)` | 字段对齐 = `min(自然对齐, N)` |
| `build noalign` | 等价 `align(1)`，无填充 |
| align 与 struct 之间隔了别的声明 | 孤儿，不生效 |

实测（`test/align`）：

- `struct { a: u8; b: u32 }` 自然布局 8 字节。
- `build align(2)` 后同一结构体 6 字节。
- `build noalign` 后 5 字节。
- 孤儿 align 不生效；后续 struct 也不继承。

---

## 7. 接口

### 7.1 声明 ⚠️

支持 `type X interface { ... }` 和裸 `interface X { ... }` 两种等价形式：

```cute
type Stringer interface {
    stringify() string
}
```

| 形式 | 状态 |
|---|---|
| `type I interface { ... }` | ✅ 解析 |
| 裸 `interface I { ... }` | ✅ 解析 |
| 接口字段 | ❌ 不支持 |
| 接口嵌入其他接口 | ❌ 不支持 |

### 7.2 方法签名

```cute
type Counter interface {
    increment()
    getCount() int
}
```

- 方法参数写成 `name: Type`；`()` 无参可用；省略类型也能解析，但参数类型为 nil（无实际用途）。
- 返回类型只解析**单个 NAME 类型**：`int`、`string`、结构体名等。
- ❌ 返回 `[]T`、`[N]T`、多返回值不支持（parser 只读一个 NAME）。
- 参数/返回类型在运行期不参与派发（见下）。

### 7.3 动态派发 ❌

接口赋值/动态派发不可用：

```cute
var d: Dog
var s: Stringer = d    // Type Error: need type Stringer, not Dog
```

- 接口没有运行时表示/vtable。
- 直接调用具体类型的方法 ✅：`d.stringify()`。
- 接口方法参数/返回值只影响解析，不影响调用约定。
- 结论：接口目前只能当“声明形状”，不能当多态机制使用。

### 7.4 error ❌

- `error` 是内建接口类型（`Error() string`）。
- 但当前不可用：
  - `e == nil` 报 `operator == not defined for type error`。
  - `e.Error()` 返回错误值（实测 56，不是字符串地址/内容）。
- 需要错误处理时，当前代码库更多使用整数返回码或 `panic`。

---

## 8. 枚举

### 8.1 声明 ✅

```cute
enum Color {
    Red
    Green = 5
    Blue
}
```

- 成员默认从 0 开始自增。
- 显式值必须是整数常量；支持十进制、十六进制、二进制、八进制和负号。
- 成员之间可用换行、逗号 `,` 或分号 `;` 分隔。
- 重复成员报 `duplicate enum member`。

### 8.2 访问与类型

| 能力 | 状态 | 说明 |
|---|---|---|
| 裸成员名访问 `Red` | ✅ | 成员注册为同作用域常量 |
| `Color.Red` 限定访问 | ❌ | 不支持 |
| 赋给变量 | ✅ | `var c: Color = Red` |
| 作为函数参数/返回值 | ✅ | |
| 作为结构体字段 | ✅ | |
| 用于 `switch case` | ✅ | |
| 底层类型 | ✅ | 默认 `int`；成员值超出 `int32` 时底层变 `i64` |

枚举名注册为“非真别名”（`type Color int` 语义），成员常量类型就是该枚举类型。

---

## 9. 语句

### 9.1 语句分隔与块

- 语句之间用换行或 `;` 分隔。
- `{ ... }` 是独立作用域块（块尾释放与 if/else 体一致），函数内可用：

```cute
fn main() int {
    {
        var x: int = 5
    }
    ret 7
}
```

### 9.2 if / else ✅

```cute
if cond {
    ...
} else if other {
    ...
} else {
    ...
}
```

| 能力 | 状态 | 说明 |
|---|---|---|
| `if cond { }` | ✅ | |
| `else` / `else if` | ✅ | |
| `if (cond)` | ✅ | 括号只是表达式分组 |
| `else` 换行写 | ✅ | `}\nelse {` 可用 |
| 条件真值判断 | ✅ | `if 1`、`if "a"`、非 nil 指针为真；`if 0`、空串、nil 指针为假 |
| `!x` 对整数 | ✅ | 按真值取反（`!0` 为真，`!5` 为假） |
| `if init; cond` | ⚠️ | 能编译，但条件执行不正确（实测 `if x := 1; x > 0` 走进假分支） |
| `&&` / `\|\|` 条件 | ✅ | 短路；操作数必须 bool |

注意：`if` 条件本身接受任意真值表达式，但 `&&` / `||` 的操作数仍然强制 bool（`int` 会报 `operands of '&&' must be bool`）。

### 9.3 for ✅（有明确限制）

```cute
for i := 0; i < 3; i++ {
    ...
}
```

| 形式 | 状态 | 说明 |
|---|---|---|
| `for { }` | ✅ | 无限循环 |
| `for cond { }` | ✅ | 条件必须是 bool |
| `for ; cond; { }` | ✅ | 省略 init/post |
| `for ; ; { }` | ✅ | 等价 `for {}` |
| `for i := 0; i < 3; i++ { }` | ✅ | 标准形式 |
| `for i = 0; i < 3; i++ { }` | ✅ | `i` 需已声明 |
| `for var i: int = 0; ...` | ✅ | init 可以是 `var` 声明（单条语句）；`for (var i: int = 0)` 括号形式也支持 |
| post `i = i + 1` | ✅ | 普通赋值表达式 |
| `for (var i: int = 0)` | ✅ | init 是 var 声明时需 `()` 包裹 |
| post `i += 1` | ✅ | 复合赋值 |
| post `i++` / `i--` | ✅ | 自增/自减 |
| `for ... \n {` | ❌ | `{` 必须与 for 头部同行；报 `for loop must end by '{'` |
| 整个 body 写在同一行 | ❌ | `for ... { stmt }` 报 `expected right operand` |
| `{` 后同行写语句、`}` 另起一行 | ✅ | 可用 |

`for` 条件强制 bool：`for 1` / `for x`（int）报 `for loop condition must be boolean`。

### 9.4 range ⚠️

基本形式：

```cute
for i := range list {
    ...
}
```

| 形式 | 状态 | 说明 |
|---|---|---|
| `for i := range list` | ⚠️ | 单变量绑定**索引**；`n += i` 可用，但 `n += a[i]` 可能越界 |
| `for i = range list` | ✅ | `i` 已声明时可用 |
| `for i, v := range list` | ❌ | 多行 body 运行段错误（exit 139） |
| `for _, v := range list` | ❌ | 段错误 |
| `for i := range string` | ⚠️ | 单变量绑定索引；`n += s[i]` 会编译 panic |
| `for i, v := range string` | ❌ | 段错误 |
| `for i := range array` | ⚠️ | 能启动；`ret i` 得 0、`ret a[0]` 得 10，但 `sum = sum + a[i]` 结果错误 |
| `for i := range map` | ❌ | 循环体 0 次 |
| `for k, v := range map` | ❌ | 用值时报 `operator + not defined for type int` |
| `for i := range []int{...}` | ❌ | 列表字面量 range 0 次迭代 |
| range body 单行 | ❌ | 失败 |
| `{` 换行 | ❌ | 失败 |

结论：range 目前只有“列表/字符串单变量绑定索引”本身可靠。把循环变量直接用于复合表达式里的索引（`n + a[i]`、`n += s[i]`）会越界或编译 panic；先单独取值到局部变量（`var v: int = a[i]`、`var b: byte = s[i]`）再参与运算可用。

### 9.5 switch ⚠️

```cute
switch x {
case 1:
    ret 1
case 2:
    ret 7
default:
    ret 3
}
```

| 能力 | 状态 | 说明 |
|---|---|---|
| 带目标 `switch x` | ✅ | |
| int case | ✅ | |
| string case | ✅ | |
| `default` | ✅ | 按源码顺序编译，可以出现在中间 |
| 无匹配 | ✅ | 继续执行 switch 之后 |
| `break` | ✅ | 只退出当前 switch；`break N` 可继续向外跳出 |
| `fallthrough` | ✅ | 跳到下一个 case body；必须是 case 最后一条语句，最后一个 case 禁用 |
| 多值 `case 1, 2:` | ✅ | 值列表独立比较，`je` 跳转到 case 体 |
| 无目标 `switch {` | ✅ | 每个 case 按布尔条件独立判断（`test/jnz` 直跳）；等价 Go `switch {}` |
| case body 单行 | ✅ | `case 1: ret 1` 可用 |

`break` 在 switch 内按 Go 语义退出 switch：`compileBreakBlock` 按祖先顺序同时统计
`ForBlock` 与 `SwitchBlock`，`break` 命中最近的 switch/for，`break N` 逐层向外。
`fallthrough` 不执行任何运行期代码，只由 `compileSwitchBlock` 在 case 末尾发跳转。

### 9.6 break ✅

| 形式 | 状态 | 说明 |
|---|---|---|
| `break` | ✅ | 退出最内层 for 或 switch |
| `break N` | ✅ | 退出 N 层 for/switch |
| `break(N)` | ✅ | 同上，括号形式 |
| 循环/switch 外 `break` | ❌ | 显式报 `'break' outside of loop or switch` |
| 层级过深 | ❌ | 显式报 `break level N exceeds enclosing loop/switch depth M` |

嵌套循环验证：`break 2` / `break(2)` 可跳出两层。

### 9.7 continue / defer

| 关键字 | 状态 | 实际行为 |
|---|---|---|
| `continue` | ✅ | 跳到当前循环的继续点（块级释放之后、增量/索引自增之前） |
| `continue N` / `continue(N)` | ✅ | 只统计 for 循环；switch 不构成 continue 目标 |
| 循环外 `continue` | ❌ | 显式报 `'continue' outside of loop` |
| 层级过深 | ❌ | 显式报 `continue level N exceeds enclosing loop depth M` |
| `defer` | ❌ | 被 parser 静默丢弃；后续调用按普通语句立即执行，顺序与源码相同 |

`test/controlFlow` 中 `continue` 生效后退出码由 39 变为 **37**。
`test/defer_test` 输出 `cleanup1cleanup2main`，说明 `defer` 没有延迟执行。

`compile/defer.go` 里有 `DeferBlock` 收集逻辑，但 parser 从未构造 `DeferBlock`，属于死代码。

### 9.8 return / ret ✅

| 形式 | 状态 | 示例 |
|---|---|---|
| 无值 | ✅ | `return` / `ret` |
| 单值 | ✅ | `return 1` / `ret 1` |
| 多值 | ✅ | `return a, b` / `ret a, b` |
| 括号 | ✅ | `return (7)` |
| 返回字符串 | ✅ | `ret "ok"` |
| 返回结构体 | ✅ | 按值返回 |
| 返回指针 | ✅ | |

`return` 与 `ret` 完全等价。

### 9.9 表达式语句与解引用赋值

- 函数调用可以单独成句：`println("hi")`。
- 赋值/复合赋值/自增自减是语句。
- 解引用赋值：`*p = expr` ✅。
- 索引赋值：`a[i] = expr`、`m[k] = expr` ✅。
- 纯表达式（如 `1 + 2`）单独成句没有意义，但 parser 可能接受；不要依赖。

### 9.10 未支持语句

| 语句 | 状态 | 现象 |
|---|---|---|
| `while cond { ... }` | ✅ | 等价 `for cond { ... }` |
| `try` / `except` / `finally` | ❌ | 显式报 `'try' is not supported yet`（关键字保留，不会静默跳过） |
| `fallthrough` | ✅ | 仅 switch case 内，见 §9.5 |
| 独立块 `{ ... }` | ✅ | 顺序编译为普通块；块尾释放与 if/else 体一致 |
| 标签语句 / `goto` | ❌ | 无实现 |

---

## 10. 表达式与运算符

### 10.1 优先级表

`parser/exp.go` 的 `opTable`（数字越大绑定越紧）：

| 优先级 | 运算符 | 说明 |
|---|---|---|
| 0 | `=` | 赋值（最低） |
| 1 | `\|\|` | 逻辑或 |
| 2 | `&&` | 逻辑与 |
| 3 | `==` `!=` | 相等比较 |
| 4 | `<` `>` `<=` `>=` | 大小比较 |
| 5 | `\|` | 按位或 |
| 6 | `^` | 按位异或 |
| 7 | `&` | 按位与 |
| 8 | `~` `!` | 一元前缀（按位取反 / 逻辑非） |
| 9 | `<<` `>>` | 移位 |
| 10 | `+` `-` | 加减 |
| 11 | `*` `/` `%` | 乘除取模 |
| 12 | `+=` `-=` `*=` `/=` `%=` `^=` `&=` `\|=` `<<=` `>>=` | 复合赋值 |
| 13 | `++` `--` | 后缀自增自减 |
| 100 | `[]` | 索引/切片（最高） |

**与 Go 不同的关键点**：

- `+` / `-` 比 `&`、`|`、`^`、`<<`、`>>` 绑定更紧。例：`a + b & c` 解析为 `(a + b) & c`；Go 里是 `a + (b & c)`。
- `==` / `!=` 比 `<` / `>` / `<=` / `>=` 绑定更松。例：`a == b < c` 解析为 `a == (b < c)`。
- `^` 是**按位异或**，不是幂运算。
- `~` 是一元按位取反，不是 Go 的 `^` 一元取反。

建议：复杂表达式显式加括号，不要依赖优先级细节。

### 10.2 算术与位运算

| 运算符 | 内建语义 | 状态 |
|---|---|---|
| `+` | 数值加；string 拼接；指针 + 整数 | ✅ |
| `-` | 数值减；指针 - 整数 | ✅ |
| `*` | 数值乘；`string * int` 重复 | ✅ |
| `/` | 整数除法（向零截断）；浮点除法 ⚠️ | ✅ / ⚠️ |
| `%` | 整数取模 | ✅ |
| `^` | 按位异或 | ✅ |
| `&` | 按位与 | ✅ |
| `\|` | 按位或 | ✅ |
| `<<` / `>>` | 左移/右移 | ✅ |
| `~` | 一元按位取反 | ✅ |
| `-`（一元） | 取负 | ✅ |

- 整数常量折叠按运行期语义处理：`/` 向零截断，`%` 取余，除零/模零报编译错误。
- 浮点常量 `1.0/0.0` 会折叠为 `+Inf`，但运行期浮点除法会走整数 `idiv` 并触发 SIGFPE（见 §15）。

### 10.3 比较与逻辑

| 运算符 | 状态 | 说明 |
|---|---|---|
| `==` / `!=` | ✅ | 数值、指针、string 内容比较 |
| `<` `>` `<=` `>=` | ✅ | 仅数值；string 报 `operator < not defined for type string` |
| `&&` / `\|\|` | ✅ | 操作数必须 bool；短路求值 |
| `!` | ✅ | 逻辑非；对 int 按真值取反 |

短路已验证：`&&` 左侧为假时右侧不执行；`||` 左侧为真时右侧不执行。

### 10.4 字符串运算

| 运算 | 状态 | 说明 |
|---|---|---|
| `+` 拼接 | ✅ | `"ab" + "cd"` |
| `*` 重复 | ✅ | `s * n`；常量在编译期折叠，运行期 lowering 到 `std:strings.repeatN`；`n <= 0` 返回空串 |
| `==` / `!=` | ✅ | 内容比较（lowering 到 `std:strings.eq/ne`） |
| `<` / `>` 等 | ❌ | 不支持 |
| `len(s)` | ✅ | 变量可用 |
| `cap(s)` | ✅ | 变量可用 |
| `s[i]` | ✅ | 返回 `byte` |
| `s[lo:hi:step]` | ✅ | 返回 string |
| 负索引/负步长 | ✅ | x86_64 可用，如 `s[::-1]` |
| `len("literal")` | ❌ | 直接传字面量返回 0；先存变量 |
| `cap("literal")` | ❌ | 同上 |
| `s.len()` | ❌ | 返回值错误（实测 56）；用 `len(s)` |

重复只支持 `string * int`；反向 `int * string` 未实现。运行期的负数/零次数与常量折叠一致，均返回空串，不会 panic。

### 10.5 指针运算

| 运算 | 状态 | 说明 |
|---|---|---|
| `&x` | ✅ | 取地址 |
| `*p` | ✅ | 读/写解引用 |
| `p == nil` / `p != nil` | ✅ | |
| `p + 1` / `p - 1` | ✅ | 指针算术（按字节还是按元素取决于代码生成，慎用） |
| `*p = v` | ✅ | 解引用赋值 |
| `&p.x` | ✅ | 字段地址 |
| 指针比较大小 | ⚠️ | 不保证语义，避免使用 |

### 10.6 索引与切片

#### 索引

| 形式 | 状态 | 说明 |
|---|---|---|
| `a[i]` | ✅ | 列表/数组/字符串 |
| `m[k]` | ✅ | map；缺失键返回零值 |
| 负索引 `a[-1]` | ✅ | x86_64；运行期归一化 `idx += len` |
| 越界 | ✅ | 报 `index out of range`，退出码 1 |

#### 切片

语法：`a[lo:hi]`、`a[lo:hi:step]`、`a[:]`、`a[lo:]`、`a[:hi]`、`a[::step]`。

| 形式 | 列表 | 字符串 | 定长数组 |
|---|---|---|---|
| `a[1:3:1]` | ✅ | ✅ | ❌ `cannot slice a fixed-size array` |
| `a[1:3]`（无 step） | ❌ 取元素段错误（139）；`len` 可能正常 | ✅ | ❌ |
| `a[2:]`（无 step） | ❌ 返回错误数据（len 0） | ✅ | ❌ |
| `a[:]`（无 step） | ❌ 返回错误数据（len 0） | ✅ | ❌ |
| `a[::-1]` | ✅ | ✅ | ❌ |
| `a[::2]` | ✅ | ✅ | ❌ |
| 负边界 `a[-2:]` | ✅（建议带 step） | ✅ | ❌ |

**重要**：列表切片目前只有“显式 step”路径可靠；无 step 的正边界/省略边界路径存在段错误或错误数据。字符串切片两条路径都可用。

#### 索引赋值

| 形式 | 状态 |
|---|---|
| `a[i] = v` | ✅ |
| `m[k] = v` | ✅ |
| `a[i] += v` | ⚠️ 列表可用；map 结果错误（见 §15） |
| `a[i:j] = v` | ❌ 不支持 |

### 10.7 字面量

| 字面量 | 语法 | 状态 | 说明 |
|---|---|---|---|
| 列表 | `[]T{1, 2, 3}` | ✅ | |
| 空列表 | `[]T{}` | ✅ | |
| 定长数组 | `[N]T{1, 2, 3}` | ✅ | 元素个数必须等于 N |
| 嵌套列表 | `[][]T{[]T{...}}` | ❌ | `unexpected '['` |
| map | `map[K]V{k: v}` | ❌ | 不支持 |
| 结构体 | `P{x: 1}` | ❌ | `expected right operand` |

定长数组字面量元素个数不匹配时报 `array literal has N elements but wants M`。

### 10.8 调用与字段访问

| 形式 | 状态 | 示例 |
|---|---|---|
| 函数调用 | ✅ | `f(1, 2)` |
| 包函数调用 | ✅ | `strings.len(s)` |
| 方法调用 | ✅ | `p.get()`、`p.set(1)` |
| 泛型显式调用 | ✅ | `identity[int](42)` |
| 泛型隐式推断 | ✅ | `identity(42)` |
| 链式字段访问 | ✅ | `a.b.c` |
| 包限定名 | ✅ | `pkg.Func`、`pkg.Var`、`pkg.Type` |
| 函数指针变量调用 | ✅ | fn 变量优先于同名函数，间接调用 |
| 结构体字面量 | ✅ | 见 §6.6 |

### 10.9 运算符重载 ⚠️

当左操作数是自定义类型时，编译器按方法名查找重载：

| 运算符 | 方法名 |
|---|---|
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
| 一元 `-` | `neg` |
| 一元 `!` | `not` |
| 一元 `~` | `bnot` |

实测：

| 重载 | 状态 | 说明 |
|---|---|---|
| `V.add` | ✅ | `a + b` 调用成功（exit 7） |
| `V.eq` | ✅ | `a == b` 调用成功（exit 7） |
| `V.get`（`[]`） | ✅ | `v[i]` 改写为 `v.get(i)`；接收者必须是左值 |
| `V.set`（`[]=`） | ✅ | `v[i] = x` 改写为 `v.set(i, x)`；支持 `v[i] += x` |
| `V.slice`（`[::]`） | ✅ | `v[lo:hi:step]` 改写为 `v.slice(lo, hi, step)`；缺省 start=0、end=-1、step=1 |

注意：

- `[]` / `[]=` / `[::]` lowering 只对非内建自定义类型生效；`[]T`、`string`、`map` 仍走原有内建路径。
- 接收者必须是可寻址左值。`makeVec()[0]` 这类非左值接收者会显式报错，不会生成错误代码。
- 复合赋值 `v[i] += x` 展开为 `v.set(i, v.get(i) + x)`。
- `^` 的内建语义是异或，但重载方法名叫 `pow`（历史命名）；不要据此认为 `^` 是幂运算。

---

## 11. 内建函数与自动包

### 11.1 编译器内建 ✅/⚠️

| 名称 | 状态 | 签名/说明 |
|---|---|---|
| `new(T, v...)` | ✅ | 堆分配；返回 `*T`；结构体按字段顺序填值 |
| `new([]T, len[, cap])` | ⚠️ | 必须传 len；不传 len 汇编失败 |
| `newRC(T, v...)` | ⚠️ | RC 分配；`newRC(int, 7)` 正常，`newRC([]T, n)` 列表读写错误 |
| `sizeof[T]()` | ✅ | 必须带括号；参数必须是具名类型/别名 |
| `sizeof[T]` | ❌ | 不带括号返回伪值（56） |
| `len(x)` | ✅ | string/list/map 变量；数组不支持；字面量直接传不可靠 |
| `cap(x)` | ✅ | string/list 变量；字面量直接传不可靠 |
| `copy(dst, src)` | ✅ | 返回复制的元素数（`min(len(dst), len(src))`，实测 2） |
| `unsafe.cast[T](x)` | ⚠️ | 位级重解释，不是数值转换 |
| `int(x)` / `i64(x)` / `f64(x)` 等 | ✅ | 显式数值转换，见 §5.4；x86 限制浮点/64 位标量 |
| `print(s)` | ✅ | 来自 `std:builtin` |
| `println(s)` | ✅ | 仅接受一个 string 参数 |
| `panic(msg)` | ✅ | 来自 `std:builtin` |

补充：

- `len(array)` ❌ 不支持（数组没有切片头）。
- `len("hello")` / `cap("hello")` 直接传字面量返回 0；先赋给 string 变量再调用。
- `m.len()` 返回错误值（1 项时返回 4）；用 `len(m)`。
- `s.len()` 返回错误值（实测 56）；用 `len(s)`。
- `.len` 属性不是长度；不要写 `s.len`。
- 列表的 `a.len()` / `a.cap()` 可用（映射到 `__list_len` / `__list_cap`）。
- `append` / `make` **不是** parser 内建：`append` 报 `not found function 'append'`，`make` 报 `unexpected '['`。

### 11.2 builtin 包 ✅

`pkg/builtin/builtin.cute` 提供并自动导入：

```cute
fn print(s: string) i32
fn println(s: string) i32
fn panic(msg: string)
```

- 无需 `import` 即可调用。
- `println` 只有一个 string 参数；多参/非 string 报 `no matching overload`。
- 需要格式化时先用 `strings` 包拼接，或使用 `std:console`（若已加载）。

### 11.3 unsafe.cast ⚠️

```cute
unsafe.cast[T](x)
```

- 是**位级重解释**（no-op 地址/位模式传递），不是数值转换。
- `unsafe.cast[int](1.5)` 得 0。
- 把整数转成 `byte`：`unsafe.cast[byte](x)`；只想要数值截断时用 `byte(x)`。
- 指针/地址互转：`unsafe.cast[ptr](p)`、`unsafe.cast[*T](addr)`。
- 数值转换请用 §5.4 的显式转换函数（`int(x)` / `i64(x)` / `f64(x)` 等），不要用 `unsafe.cast` 代替。

### 11.4 自动 std 包与 intrinsic 表 ✅

根包加载时只自动导入 `builtin`（`print` / `println` / `panic` 可无 import 调用）。
`std:strings`、`std:maps`、`std:slices` 会被**预加载**，但仅用于 `intrinsicTable`
的 lowering，不写入根包 import 别名、也不提供用户命名空间回退：

```cute
// 没有 import 时：
strings.len("abc")      // ❌ not found function 'strings.len'
slices.make[int](4)     // ❌ not found function 'slices.make'

// 需要显式导入：
import "std:strings"
strings.len("abc")      // ✅
```

| 规则 | 说明 |
|---|---|
| 自动包只有 `builtin` | `strings` / `maps` / `slices` 必须显式 import 才能按名字调用 |
| 预加载不占用 import 别名 | 用户变量/导入别名优先 |
| 显式 import 别名优先 | `import my "std:strings"` 后用 `my.len` |
| `CUTE_NO_INTRINSIC=1` | 关闭预加载以及 string 内容比较/重复 lowering |
| 局部变量优先 | 函数内先查局部/参数/字段，再走包路径 |

intrinsic 映射（唯一事实源 `parser/intrinsic.go`）：

| Kind | 操作 | 实现 | 形态 | 保留 Native 的原因 |
|---|---|---|---|---|
| `string` | `==` / `!=` | `std:strings.eq` / `ne` | parser lowering | — |
| `string` | `*` | `std:strings.repeatN` | parser lowering | — |
| `string` | `+` | 编译器内建 | Native | 拼接要分配新缓冲并构造三槽头 |
| `string` | `len` / `cap` | 编译器内建 | Native | 直接读字符串头 |
| `string` | `s[i]` / `s[lo:hi:step]` | 编译器内建 | Native | 索引返回 `byte`，切片要分配/按步长拷贝 |
| `map` | `len(m)` | 编译器内建 | Native | nil 安全地读 header `count` |
| `map` | `m[k]` | `std:maps.get` | codegen | 需要临时出参地址 |
| `map` | `m[k] = v` | `std:maps.set` | codegen | 需要左值地址与 nil 自动初始化 |
| `list` | `len` / `cap` | 编译器内建 | Native | 需要左值/地址读切片头 |
| `list` | `s[i]` / `s[i] = v` | 编译器内建 | Native | 需要地址做越界检查/写入 |
| `list` | `s[lo:hi:step]` | 编译器内建 | Native | 视图或新建缓冲，见 `docs/stdplan/TYPE_INTRINSIC.md` §4 |

`std:slices` 的 `len/cap/push/get/set/...` 在显式 import 后作为命名 API 可用，
但不替换 `[]T` 的内建操作。

---

## 12. build 指令

`build` 可出现在文件顶层或函数体内。不同分支的有效位置不同。

| 指令 | 状态 | 位置 | 说明 |
|---|---|---|---|
| `build asm { ... }` | ✅ | 函数内 | 内联 NASM；`$var` 替换为栈偏移 |
| `build ext("sym")` | ✅ | 函数内 | 调用外部 SysV/Cdecl 函数；最多 6 个整数/指针参数；返回值被忽略 |
| `build extret("sym")` | ✅ | 函数内 | 调用外部函数并直接返回其标量结果 |
| `build link("sym")` | ✅ | 函数内 | 注册符号提供者/别名标签 |
| `build align(N)` | ✅ | 顶层 | 仅对紧随其后的 struct 生效 |
| `build noalign` | ✅ | 顶层 | 等价 `align(1)` |
| `build os(...)` | ✅ | 顶层/函数 | 顶层过滤下一个声明；函数内挂到当前函数 |
| `build arch(...)` | ✅ | 顶层/函数 | 同上 |
| `build bits(32\|64)` | ✅ | 顶层/函数 | 按目标指针位宽过滤 |
| `build export("alias")` | ✅ | 函数内 | 以别名导出全局符号 |

### 12.1 build asm ✅

```cute
fn main() int {
    var x: int
    build asm {
        mov QWORD [$x], 100
        mov RAX, [$x]
    }
    ret 0
}
```

- `$var` 会替换为变量的栈偏移。
- 替换宽度按变量大小选择 `BYTE` / `WORD` / `DWORD` / `QWORD`。
- `test/asmTest` 退出 0。

### 12.2 build ext / extret ✅

```cute
// 返回值忽略：适合 puts 这类只需要副作用的调用
fn my_puts(s: ptr) {
    build ext("puts")
}

// 直接返回外部函数结果（单个整数/指针）
fn abs_ret(x: i32) i32 {
    build extret("labs")
}
```

v1 边界（parser 期显式校验，不满足直接报错）：

- 仅在函数内可用；顶层报 `ext only in func` / `extret only in func`。
- 最多 6 个参数，且只能是整数/指针；浮点、容器、结构体会报错。
- `ext` 的返回值被忽略；需要返回值时用 `extret`。
- `extret` 要求函数只有一个整数/指针返回值，否则显式报错。
- x86_64 按 SysV 传递：前 6 个参数进 `RDI` / `RSI` / `RDX` / `RCX` / `R8` / `R9`，按声明宽度装载，有符号用 `movsx`/`movsxd`，无符号用 `movzx`/32 位 `mov`。
- x86 走 cdecl 压栈；8 字节参数先压高 32 位、再压低 32 位。
- 需要链接外部库时用 `-l` 参数（如 `-lm`），`extret` 的返回值直接作为函数返回值。

### 12.3 build link ✅

```cute
fn test_link() i32 {
    build link("my_export")
    ret 1
}
```

- 仅在函数内可用；顶层报 `link only in func`。
- 注册符号提供者/别名标签；`test/linkTest` 退出 0。

### 12.4 build align / noalign ✅

见 §6.8。严格紧随语义：align 与 struct 之间隔了任何声明，align 成为孤儿，不生效。

### 12.5 build os / arch / bits ✅

语法：

```cute
build os(linux)
build os(linux, windows)
build os("linux")
build arch(x86_64)
build arch(x86, x86_64)
build bits(64)
build bits(32, 64)
```

- 支持裸名字、字符串、RAW、CHAR；逗号分隔列表。
- `build os` 用 `runtime.GOOS` 比较。
- `build arch` 用 `CUTE_ARCH` 比较；未设置时默认 `x86`（**不是**宿主架构）。
- 因此 x86_64 构建必须显式设置 `CUTE_ARCH=x86_64`。
- `build bits` 比较 `TargetPointerSize * 8`；只接受 32/64。

作用范围：

| 位置 | 行为 |
|---|---|
| 顶层，紧邻 `fn` / `type` / `var` | 只过滤紧随其后的那一个声明；不匹配时该节点标记 `BuildIgnored`，不进入重载表/查找/代码生成 |
| 顶层，后接 `import` | 不打断 pending，继续等待下一个声明 |
| 顶层，后接其它 token | 作废 pending（避免误挂到无关声明） |
| 函数体内 | 挂到当前函数（`FuncBlock.BuildFlags`），不匹配时整个函数被忽略 |
| 非根包（std/子包）文件头 | 保留整文件级 `build os/arch` 预过滤（如 `memory_x86.cute`） |

根包不做整文件过滤，因此同一文件可以混写多个平台分支：

```cute
build arch(x86_64)
fn archValue() int { ret 1 }

build arch(x86)
fn archValue() int { ret 2 }
```

`test/buildKeyword` 与 `test/buildDirective` 均通过（含 `bits`/`arch` 过滤、
`ext`/`extret`、`export`）。

### 12.6 build export ✅

```cute
fn exported(x: int) int {
    build export("cute_exported")
    ret x + 10
}
```

- 仅在函数内可用；顶层报 `export only in func`。
- 别名以 `global` 符号输出，并生成 `alias: jmp <mangled>` 跳板。
- `nm` 可看到 `cute_exported`。

---

## 13. import

### 13.1 支持的形式 ✅

```cute
import "std:memory"
import alias "std:memory"
import _ "std:memory"

import (
    "std:memory"
    m "std:math"
    _ "std:fs"
)
```

| 形式 | 状态 | 说明 |
|---|---|---|
| `import "path"` | ✅ | 默认别名 = 路径末段 |
| `import alias "path"` | ✅ | 前缀别名 |
| `import _ "path"` | ✅ | 空导入，仅加载副作用 |
| `import ( ... )` | ✅ | 分组，条目间换行/分号 |
| 文件顶层 | ✅ | 函数内报 `import is only allowed at top level` |
| 重复同别名同路径 | ✅ | 去重 |
| 同别名不同路径 | ❌ | 报 `import alias 'x' already used for 'y'` |

### 13.2 路径约定

| 形式 | 示例 | 说明 |
|---|---|---|
| 官方前缀 | `std:memory` / `ext:foo` / `api:bar` | 标准库/扩展/API |
| 第三方前缀 | `:vendor/pkg` | 以 `:` 开头 |
| 命名空间相对 | `name:rel` | 别名空间内的相对路径 |
| 相对路径 | `./rel` | 相对当前文件 |
| 绝对路径 | `/abs` | 绝对路径 |
| 裸短名 | `memory` | ❌ 非法 |

- 默认别名取路径末段：`import "std:memory"` → `memory`；`import ":mylib/sub"` → `sub`。
- 路径必须用双引号；反引号 RAW 路径被拒绝（`import path must be a quoted string`）。
- `.` 点导入报 `dot import is not supported yet`。

### 13.3 导入与包名解析

- 导入别名注册在 package 层，与 `package.json` 的 `imports` 同一通道。
- 显式 import 别名优先于自动 std 包回退。
- 跨包名称在合并树中固定为包路径前缀，避免根包导入表缺失导致解析失败。

---

## 14. 语法糖与便利写法

以下写法是当前实现里真实可用的“糖”，汇总便于查阅。

| 糖 | 展开/等价写法 | 状态 |
|---|---|---|
| `ret` | `return` | ✅ |
| `x := v` | `var x: T = v`（类型推断） | ✅ |
| `x: T = v` | `var x: T = v` | ✅ |
| `var x = v` | `var x: T = v`（T 推断） | ✅ |
| `var ( ... )` | 多条 `var/const/let/type x: T = v` | ✅ |
| `interface I { ... }` | `type I interface { ... }` | ✅ |
| 参数 `a int` | `a: int` | ✅ |
| 方法 `fn P.m()` | 接收者 `self` 自动可用 | ✅ |
| 枚举裸成员 `Red` | `Color.Red`（但后者不支持） | ✅ |
| 负索引 `a[-1]` | 运行期 `a[len-1]` | ✅（x86_64） |
| 负步长 `a[::-1]` | 反向切片 | ✅（列表/字符串） |
| `s + t` | string 拼接 | ✅ |
| `s * n` | string 重复（常量折叠 / 运行期 `strings.repeatN`） | ✅ |
| `s == t` | 内容比较（lowering 到 `strings.eq`） | ✅ |
| 整数字面量自动拓宽 | 超过 int32 自动 `i64` | ✅ |
| 换行/`;` 分隔语句 | 无需分号 | ✅ |
| 自动导入 | 仅 `builtin` 可无 import 调用；`strings`/`maps`/`slices` 需显式 import | ✅ |
| `x++` / `x--` | 自增/自减语句 | ✅ |
| `break(N)` / `continue(N)` | `break N` / `continue N` | ✅ |
| `while cond` | `for cond` | ✅ |
| `fallthrough` | switch case 内跳下一个 body | ✅ |
| `int(x)` / `f64(x)` 等 | 显式数值转换 | ✅（x86 有限制） |
| 字符字面量 | 按 `int` 常量 | ✅ |
| import 默认别名 | 路径末段 | ✅ |
| `type A = B` / `type A B` | 两种别名写法都接受 | ✅（整数/结构体） |
| 顶层 `g := 5` | 全局变量 | ✅ |
| `sizeof[T]()` | 类型宽度 | ✅（必须带括号） |
| `new(P, ...)` | 按字段顺序构造 | ✅ |

---

## 15. 已知缺陷与未实现清单

> 本节列的是“当前实现不能按直觉工作”的项。写代码时应避开，或按“规避”列处理。
> 这里的 ❌ 不代表语言设计目标，只代表当前 HEAD 的可观察行为。

### 15.1 解析/编译直接失败

| 项目 | 现象 | 规避 |
|---|---|---|
| `a, b = f()` | ✅ 已支持 | `:=` 与 `=` 都允许（多返回值解构按返回槽装载） |
| 接口赋值 `var s: I = d` | `need type I, not Dog` | 直接调用具体类型方法 |
| map 字面量 | 不支持 | 声明后逐项 `m[k] = v` |
| `pub fn` / `pub var` | `'pub' is not a valid expression` | 去掉 `pub` |
| `try` / `except` / `finally` | `'try' is not supported yet` | 用返回码/panic |
| `import` 在函数内 | `import is only allowed at top level` | 提到文件顶层 |
| 点导入 `.` | `dot import is not supported yet` | 用别名 |
| 反引号 import 路径 | `import path must be a quoted string` | 用双引号 |
| `sizeof[T]` 不带括号 | 返回伪值 56 | 写 `sizeof[T]()` |
| `sizeof[[]T]()` / `sizeof[[N]T]()` | `unexpected '['` | 先起别名 |
| `new([]T)` 不传长度 | 汇编 `invalid combination of opcode and operands` | 传长度 |
| 嵌套列表字面量 | `unexpected '['` | 逐层构造或先声明变量 |
| 跨行 RAW 字符串 | 报 `Miss ...` | 单行 RAW 或运行时拼接 |

### 15.2 能编译但运行结果错误/崩溃

| 项目 | 现象 | 规避 |
|---|---|---|
| `if init; cond` | 条件执行不正确（走进假分支） | 把 init 拆到 if 之前 |
| 列表切片无 step `a[1:3]` | 取元素段错误（139）；len 可能正常 | 显式写 step：`a[1:3:1]` |
| 列表切片无 step `a[2:]` / `a[:]` | 返回错误数据 | 显式 step 或先算索引 |
| 定长数组切片 | `cannot slice a fixed-size array` | 手动复制到列表 |
| 嵌套数组 `[2][3]int` | 运行段错误 | 用一维数组或列表 |
| 双变量 range `for i, v := range` | 段错误（139） | 用单变量绑定索引，先 `var v: int = a[i]` 再使用 |
| 列表 range 内 `n + a[i]` | index out of range | 先 `var v: int = a[i]`，再参与运算 |
| 字符串 range 内 `n += s[i]` | 编译 panic | 先 `var b: byte = s[i]` |
| `for _, v := range` | 段错误 | 同上 |
| 数组 range 求和 `sum += a[i]` | 结果错误（应 60 得 1） | 用传统 for |
| 列表字面量 range | 0 次迭代 | 先赋给变量再 range |
| map range | 0 次迭代 | 用显式键列表/其他结构 |
| `defer` | 被丢弃，调用立即执行 | 手动在返回前调用 |
| `const` 重新赋值 | 允许，值改变 | 不要依赖只读 |
| 泛型字符串实例化 | 结果错误 | 泛型只用于数值 |
| 泛型多类型参数 | 编译挂起 | 拆成单类型参数函数 |
| 泛型 `[]T` 参数 | `no matching overload` | 用具体类型 |
| 泛型结构体 | `name contains invalid characters` | 用具体结构体 |
| `byte` 字面量赋值 | `need type byte, not int` | 用 `u8` 或 `unsafe.cast[byte]` |
| `byte` 算术回赋 | 结果提升为 int | 显式 `unsafe.cast[byte]` |
| int↔float 隐式声明初始化 | 能编译但值错误（5.0→0，6.9→154） | 写显式转换 `f64(x)` / `int(x)` |
| 运行期浮点除法 | 除零 SIGFPE（136） | 避免运行期浮点除零 |
| `m.len()` | 返回错误值（1 项→4） | 用 `len(m)` |
| `m[k] += v` | 结果错误（3 而非 8） | 用 `m[k] = m[k] + v` |
| `s.len()` | 返回错误值（56） | 用 `len(s)` |
| `len("literal")` / `cap("literal")` | 返回 0 | 先赋给 string 变量 |
| `len(array)` | 不支持 | 用常量 N 或 `sizeof[Arr]()/elemSize` |
| `newRC([]T, n)` | 列表读写错误 | 用 `new([]T, n)` |
| `error` 接口 | `e == nil` 报错；`e.Error()` 值错误 | 用整数返回码/panic |
| 结构体继承/嵌入 | 仅解析，不生效 | 手动复制字段或组合 |
| 字段默认值 | 仅解析，运行时为 0 | 在 `new` 后手动赋值 |
| 字段标签 | 仅解析 | 不要依赖反射/标签 |
| 访问修饰符 `!`/`?`/`_` | 不强制 | 自行约束 |
| 字段前 `pub` | 被忽略，无导出语义 | 不要依赖可见性 |
| 大整数常量 | 超过 int64 精度丢失 | 避免超大常量 |
| 空源文件 | lexer panic | 保持文件非空 |

### 15.3 测试基线中的已知失败

| 用例 | 期望 | 实际 | 原因 |
|---|---|---|---|
| `test/fullSyntaxTest` | 全通过 | exit 1 | 覆盖面广，仍有未收口项（切片等） |
| `test/iface_dispatch` | exit 0 | 编译失败 | `d.age = 5` 处报 `need type Stringer, not Dog` |
| `test/for_range_test` | exit 0 | exit 139 | 双变量 range 段错误 |
| `test/defer_test` | 延迟顺序 | `cleanup1cleanup2main` | `defer` 被丢弃 |
| `test/neg_index_step` | 通过 | 未确认 | 探针环境 nasm SIGBUS；不作为可用性证据 |

其余基线（摘要）：`generics=42`、`overload=42`、`overload_types=42`、`multi_return=0`、`asmTest=0`、`linkTest=0`、`map_index=42`、`align=0`、`import=0`、`structMethod=45`、`ifaceTest=0`、`iface_generic=0`、`listTest=0`、`bitwise=9`、`operatorPrecedence=61`、`scopeTest=119`、`reassign=0`、`intrinsic_string=42`、`intrinsic_auto=42`、`strings=60`、`frontendTest=0`、`slice_minimal=0`。

---

## 16. 与 PROJECT.md §8 的差异

`PROJECT.md` §8 是早期速记，多处已经过期。逐条对照：

| `PROJECT.md` §8 的说法 | 现行实现 | 结论 |
|---|---|---|
| `for ; i < n; { ... }` | `for ; i < n; { ... }` 仍可用 | ✅ 不变 |
| “无 i++ 自运算” | `i++` / `i--` 实际可用 | ❌ 过期 |
| “步进=显式 i = i + 1” | post 接受 `i = i + 1`、`i += 1`、`i++`/`i--` | ✅ 已支持 |
| `int/uint = arch word` | 正确（x86_64 8B / x86 4B） | ✅ 不变 |
| `ptr = arch word` | 正确 | ✅ 不变 |
| `bool 1B` | 正确 | ✅ 不变 |
| `string = 24B 头 {p@0,n@8/4,c@16/8}` | 正确 | ✅ 不变 |
| 切片头 data@0/len@8/4/cap@16/8 | 正确 | ✅ 不变 |
| `unsafe.cast[T]` 强转 | 可用，但是位重解释；数值转换用 `int(x)` / `f64(x)` 等 | ⚠️ 表述过宽 |
| `build arch("x86"\|x86_64)` 分片头 | 可用；`CUTE_ARCH` 默认 `x86`；根包按声明过滤，非根包按文件过滤 | ✅ 已完善 |
| `import "std:xxx"` | 可用，且还有别名/空导入/分组/第三方前缀 | ✅ 不完整 |
| `enum Name { A, B = 10 }` 独立命名类型、成员 typed | 正确 | ✅ 不变 |
| 无 `Name.MEMBER` 作用域访问 | 正确 | ✅ 不变 |
| “if/for/blocks 均花括号制” | if/for 是；函数内独立 block 不支持 | ⚠️ 表述过宽 |

---

## 17. 复现与验收

### 17.1 构建编译器

```bash
cd /home/gx/Desktop/代码/tiny
go build -o /tmp/cute .
```

### 17.2 编译、汇编、链接、运行

```bash
CUTE_ARCH=x86_64 /tmp/cute -S -o /tmp/probe.asm path/to/pkg
nasm -f elf64 -o /tmp/probe.o /tmp/probe.asm
gcc -nostartfiles -no-pie -e _start -o /tmp/probe /tmp/probe.o
/tmp/probe
echo "EXIT=$?"
```

- `path/to/pkg` 必须是**目录**（其中放 `.cute` 文件）；`package.json` 可选，缺失时包名取目录名。
- 传单个 `.cute` 文件会报 `not a directory`。
- x86_64 目标必须显式 `CUTE_ARCH=x86_64`；否则 `build arch("x86_64")` 文件会被跳过。
- 需要外部库时在链接阶段加 `-l`（如 `-lm`、`-lpthread`）。

### 17.3 本次文档的验证范围

- 词法/声明/类型/结构体/接口/枚举/泛型/重载/控制流/表达式/内建/import/build 的边界探针均在 `/tmp/opencode/syn/` 下逐项运行。
- 探针采用“`CUTE_ARCH=x86_64` 编译 → nasm → gcc 链接 → 运行 → 读取退出码”的流程。
- 文中标注 ✅ 的项至少通过一次上述流程；标注 ⚠️/❌ 的项记录了实际报错或错误结果。
- 测试套件基线见 §15.3。

### 17.4 维护约定

- 修改 `parser/intrinsic.go` 的映射表时，必须同步 `docs/stdplan/TYPE_INTRINSIC.md` 与本文 §11.4。
- 修改 `lexer/keywords.go` 的关键字表时，必须同步本文 §1.4。
- 修改 `parser/exp.go` 的 `opTable` 时，必须同步本文 §10.1。
- 新增语法特性时，先在 `test/` 增加可执行用例，再更新本文状态标记。

---

*本文以当前 HEAD 的 Go 编译器行为为准；自举 parser 的差异请查阅 [`SELFHOST.md`](SELFHOST.md)。*

*2026-11-10 更新：块注释、跨行 RAW、分组/默认/变参参数、指针接收者、结构体字面量、for var 初始化、独立块、多值 case、无目标 switch、`a, b = f()`（脱糖）、`var x = expr` 推断、pub field 错误、真别名 list 赋值等条目已与实现一致。*
