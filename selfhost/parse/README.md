# parse —— Cuteify 自举 parser（S2）

`selfhost/parse` 是 Cute 版递归下降 parser 的第一阶段：只验证语法并统计结构，
**不建 AST、不做类型检查、不做符号解析**。输入是一段源码 `string`，输出错误码与
若干计数器；更完整的 AST 与 Go parser 逐节点对拍留给 S3。

- 实现：`parse.cute`
- 包名：`parse`
- 测试：`test/main.cute`（通过返回 `42`）
- driver：`../cmd/parsedump/`（stdin → `PARSE_OK`/`PARSE_ERROR`）
- 验收入口：`scripts/selfhost_parse.sh`
- 外层总览：`../README.md`

## 快速开始

```cute
import parse "../"

fn main() int {
    var p: *parse.Parser = parse.mk("fn main() { ret 0 }")
    parse.file(p)

    if parse.err(p) != parse.OK {
        ret parse.err(p)
    }
    if parse.fnCount(p) != 1 {
        ret 1
    }
    ret 42
}
```

`mk` 只预读第一个有效 token；必须调用 `file` 才会解析整个文件并累计计数。

## API

| 函数 | 签名 | 作用 |
|---|---|---|
| `mk` | `fn mk(src string) *Parser` | 基于源码字符串创建 parser，预读第一个 token |
| `file` | `fn file(x *Parser)` | 解析整个文件；错误写入 parser，不抛异常 |
| `err` | `fn err(x *Parser) int` | 首个错误码；`OK` 表示成功 |
| `errPos` | `fn errPos(x *Parser) uint` | 首个错误的字节偏移 |
| `declCount` | `fn declCount(x *Parser) int` | 顶层声明数 |
| `importCount` | `fn importCount(x *Parser) int` | import 数（分组 import 记 1） |
| `buildCount` | `fn buildCount(x *Parser) int` | build 数 |
| `enumCount` | `fn enumCount(x *Parser) int` | enum 声明数 |
| `structCount` | `fn structCount(x *Parser) int` | struct 声明数（含旧式 `struct Name`） |
| `constCount` | `fn constCount(x *Parser) int` | const 声明数 |
| `varCount` | `fn varCount(x *Parser) int` | var/let 声明数 |
| `fnCount` | `fn fnCount(x *Parser) int` | 顶层 fn 声明数 |
| `stmtCount` | `fn stmtCount(x *Parser) int` | 块内语句数 |
| `exprCount` | `fn exprCount(x *Parser) int` | primary 级表达式计数 |

错误码：

| 名称 | 值 | 含义 |
|---|---:|---|
| `OK` | 0 | 无错误 |
| `ETOK` | 1 | 词法错误（未闭合字符串、跨行字符串等） |
| `EDECL` | 2 | 顶层声明错误 |
| `ETYPE` | 3 | 类型引用错误 |
| `ESTMT` | 4 | 语句/块错误 |
| `EEXPR` | 5 | 表达式错误 |

调用约定：

- `fail` 只记录**第一个**错误；后续错误不覆盖 `err/errPos`。
- `file` 遇到错误立即停止，不再解析剩余源码。
- `errPos` 是字节偏移，不是字符下标；需要行列号时由 driver 换算。
- parser 不复制源码；`src` 的生命周期必须覆盖 parser 的使用期。

## 支持的语法子集

S2 的目标是覆盖 `selfhost/lex` 与仓库现有 `.cute` 语料，不追求一次性覆盖全部语言。

### 顶层声明

- `import "path"`、`import alias "path"`、`import _ "path"`
- 分组 import：`import ( ... )`，支持组内别名与去重前的原始形式
- `build os(linux)`、`build arch("x86_64")`、`build link("sym")`
- 内联汇编：`build asm { ... }`（按花括号层级整体跳过，不解析汇编正文）
- `enum Name { A, B = 10 }`；成员可用换行或逗号分隔
- `type Name struct { ... }`
- `type Name interface { 方法签名... }`
- 类型别名/定义：`type A = []int`、`type B int`
- 旧式结构体：`struct Name { ... }`、`struct Name : Parent { ... }`
- `const` / `var` / `let` 声明（顶层与块内）
- `fn Name(...) Ret { ... }`、多返回值 `fn f() (int, string)`
- 方法接收者：`fn Point.m(...)` 与 `fn (self Point) m(...)`
- 泛型声明：`fn f[T](...)`、类型引用 `Name[T]`

### 结构体与接口

- 字段：`name: Type`、`name Type`、`x:int`（冒号两侧空格不限）
- 修饰符：`pub`、`priv`、`prot`、`!`、`?`、`+`、`-`
- 字段默认值：`name: string = "default"`
- 字段标签：字段类型后的反引号标签（如 `` `json:"meta"` ``）作为 RAW token 接受
- 内嵌：`@Parent`、`info @Parent`
- 接口方法：`print()`、`read(buf: string) int`

### 语句

- 块、`var` / `const` / `let`
- `if` / `else if` / `else`
- `for` / `while`：条件形式、`for ; cond;`、`for init; cond; post`
- `for i, v := range xs`、`for v := range xs`
- `switch [expr] { case ...: ... default: ... }`
- `ret` / `return`，支持逗号分隔的多返回值
- `break`、`continue`
- `defer expr`
- 语句级 `build`（含 `build asm { ... }`）
- 表达式语句、赋值、复合赋值、`++` / `--`
- 多左值：`a, b := f()`
- 省略 `var` 的声明简写：`x: int = 1`

### 表达式

- 字面量：数字、字符串、字符、裸串、布尔/`nil`
- 名字、括号表达式
- 一元：`!`、`-`、`+`、`*`、`&`、`^`、`~`
- 二元优先级：`||` < `&&` < `|` < `^` < `&` < 比较 < 移位 < `+ -` < `* / %`
- 调用 `f(...)`、索引 `a[i]`、切片 `a[lo:hi]` / `a[lo:hi:max]`
- 选择器 `a.b.c`
- 复合字面量：`[]T{...}`、`[N]T{...}`（元素可嵌套）
- 泛型调用/索引共用方括号：`f[T](x)`、`xs[i]`

### 类型引用

- 名字与限定名：`T`、`pkg.T`
- 指针：`*T`
- 切片：`[]T`；数组：`[N]T`（长度只接受数字字面量）
- map：`map[K]V`
- 函数类型：`fn(...)`、`fn(...) Ret`
- 泛型实参：`Name[T]`、`Name[K, V]`

## 计数口径

计数用于回归和 driver 冒烟，**不是 Go AST 节点数的等价物**：

- 顶层 `decls` 只在声明成功解析后加 1；import/build 也算声明。
- `imports` / `builds` / `enums` / `structs` / `consts` / `vars` / `fns`
  按声明条目计数；分组 import 记 1，多名字 var 声明记 1。
- `interface` 和类型别名不计入 `structs`；旧式 `struct Name` 计入。
- `stmts` 统计块内实际解析的语句：`if`/`for`/`switch` 本身各记 1，其内部语句另计；
  `var` 在块内也记 1。
- `exprs` 是 primary 级计数：每个字面量/名字记 1，括号组和复合字面量各额外记 1；
  调用实参、索引下标、二元操作数分别计数。

示例：`f(1, "x")` 的 `exprs` 为 3（`f`、`1`、`"x"`）；
`[]int{1, 2, 3}` 为 4（复合字面量 1 + 三个元素）。

## 不支持 / 尚未覆盖

以下语法会返回错误，而不是静默跳过。遇到时先确认是否属于 S2 范围，再决定加语法或改写源码：

- 命名结构体复合字面量：`Point{1, 2}`
- map 复合字面量：`map[string]int{...}`
- 函数字面量：`fn(x int) int { ... }`
- `try` / `except` / `finally`、`go`、`select`
- 数组长度使用常量表达式，而不是数字字面量
- 语义检查：名字是否存在、类型是否匹配、参数个数、重复声明等
- 行列号与文件名；parser 只给字节偏移

## 实现注意（当前编译器的限制）

这些是维护 parser 时必须知道的坑，已在实现中规避：

1. **不要用 `continue` 控制 parser 的 `for` 循环**。当前 Cute 编译器在
   `for ; true; { ... }` 中执行 `continue` 会直接退出循环；parser 全部用嵌套 `if`
   或状态变量替代。
2. **换行不能被全局跳过**。换行是语句边界；全局跳过会让下一行行首的 `*q` 被当成
   上一行表达式的乘号。parser 保留换行 token，在声明/语句边界显式 `skipNL`/`skipSep`。
3. **`at` 不比较字面量 token**。否则源码里的 `"*"`、`"+"`、`"{"` 会被误判为运算符
   或块开始；`at` 对 STRING/CHAR/RAW/NUMBER/BOOL 直接返回 false。
4. **lexer 错误必须在拿到 token 时检查**。`lex.next()` 每次调用会重置错误码；等
   下一个 token 再查会丢掉未闭合字符串的 `ESTR`。
5. **Parser 只用标量/指针字段**。当前编译器对结构体数组字段（如 `[4]int`）的读写
   不可靠；计数和 token 状态全部用独立标量字段保存。

## 测试覆盖

`test/main.cute` 按组覆盖：

1. 空输入：合法且所有计数为 0。
2. 词法错误：未闭合字符串返回 `ETOK`，不能被当成 EOF。
3. 换行边界：行首 `*q` 解引用，不误判为乘法。
4. 声明：import 分组、build、enum、struct、interface、别名、函数类型、map、
   旧式 struct、const/var、两种方法接收者。
5. 语句：if/else-if/else、switch、range、三种 for、defer、多左值。
6. 表达式：优先级、一元、复合字面量、索引/切片/选择器、字符字面量。
7. 负例：缺 `}`、`var x: = 1`、`ret 1 +`、顶层 `@foo`、字段缺类型、未闭合 import 分组。

运行：

```bash
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_parse.sh x86_64
```

期望输出末尾：

```
SELFHOST_PARSE_OK|x86_64|selftest=42|files=18
```

## 已知限制

- 只做语法验证；计数变化不代表语义正确。
- 与 Go parser 不是 bug-for-bug 兼容：为兼容仓库语料，额外接受旧式 `struct Name`、
  `fn (self T)` 接收者、无冒号参数/字段等写法。
- `build asm` 正文完全不解析；括号不平衡仍会被花括号层级检查发现。
- 没有 token 缓冲/回退；递归下降只向前看当前 token。
- 输入按字节处理，不按 Unicode 码点切分。
