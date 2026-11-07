# parse —— Cuteify 自举 parser（S2/S3）

`selfhost/parse` 是 Cute 版递归下降 parser。S2 只验证语法并统计结构；S3 在同一骨架
上构建 canonical AST 与常量折叠，用于和 Go parser 逐节点对拍。它**不做完整类型检查、
不做符号解析、不做代码生成**。输入是一段源码 `string`，输出错误码、计数器或 AST 根节点。

- 实现：`parse.cute`
- 包名：`parse`
- 测试：`test/main.cute`（通过返回 `42`）；`test/ast/` 是持久 AST 对拍语料
- driver：`../cmd/parsedump/`（stdin → `PARSE_OK`/`PARSE_ERROR`，或 `PARSEDUMP_AST=1` → AST）
- 验收入口：`scripts/selfhost_parse.sh`（S2）、`scripts/selfhost_ast_parity.sh`（S3）
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
| `astRoot` | `fn astRoot(x *Parser) *Ast` | canonical AST 根节点；子链是顶层声明 |
| `astNull` | `fn astNull(n *Ast) bool` | 节点指针是否为空 |
| `nodeKind` | `fn nodeKind(n *Ast) int` | 节点种类（`A_*` 常量） |
| `nodeName` | `fn nodeName(n *Ast) string` | 主文本（名字/字面量） |
| `nodeAttr` | `fn nodeAttr(n *Ast) string` | 附加属性（flags、op、level 等） |
| `nodeAux` | `fn nodeAux(n *Ast) string` | 次要属性（类型文本 / under 类型） |
| `nodeChild` | `fn nodeChild(n *Ast) *Ast` | 第一个子节点 |
| `nodeNext` | `fn nodeNext(n *Ast) *Ast` | 下一个兄弟节点 |

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

S2/S3 的目标是覆盖 `selfhost/lex` 与仓库现有 `.cute` 语料，不追求一次性覆盖全部语言。

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

## S3 canonical AST

S3 的目标不是“实现一个更漂亮的 AST”，而是让自举 parser 构建出与 Go parser
**可观察形状一致**的 AST，再用 `tools/astdump` 逐字节对拍。Go 侧的实现噪声允许
登记为已知差异，但结构差异必须先修 parser，不能静默跳过。

### 节点种类

`parse.cute` 顶部用 `A_*` 常量定义节点种类，driver 按种类输出固定文本：

| 常量 | canonical 文本 | 说明 |
|---|---|---|
| `A_FILE` | `FILE` | 文件根，子链为顶层声明 |
| `A_VAR` | `VAR name=... flags=...` | 变量声明，`flags` 可含 `d/i/g` |
| `A_TYPE` | `TYPE name=... [under=...]` | struct/interface/别名 |
| `A_FIELD` | `FIELD name=... type=...` | 结构体字段 |
| `A_METHOD` | `METHOD name=... nargs=N` | 接口方法 |
| `A_FN` | `FN name=...` | 函数声明 |
| `A_ARG` | `ARG [name=... type=...]` | 形参带 name/type；调用实参是裸 `ARG` |
| `A_RET` | `RET type=...` | 返回类型 |
| `A_IF` / `A_ELSE` / `A_COND` | `IF` / `ELSE` / `COND` | 条件语句 |
| `A_FOR` / `A_INIT` / `A_POST` | `FOR` / `INIT` / `POST` | 三种 for 形式 |
| `A_RANGE` / `A_RNAME` | `RANGE` / `RNAME name=...` | range 子句 |
| `A_SWITCH` / `A_TARGET` / `A_CASE` / `A_VAL` | `SWITCH` / `TARGET` / `CASE` / `VAL` | switch/case |
| `A_RETURN` / `A_BREAK` | `RETURN` / `BREAK level=N` | 控制流 |
| `A_CALL` | `CALL name=...` | 调用 |
| `A_EXPR` | `EXPR` | 表达式包装节点 |
| `A_NAME` / `A_LIT` / `A_STR` / `A_BOOL` / `A_NIL` | `NAME x` / `LIT 1` / `STR "s"` / `BOOL true` / `NIL` | 字面量/名字 |
| `A_LIST` / `A_ARRAY` | `LIST` / `ARRAY` | 切片/数组复合字面量 |
| `A_INDEX` / `A_SLICE` / `A_LO` / `A_HI` / `A_MAX` | `INDEX` / `SLICE` / `LO` / `HI` / `MAX` | 索引与切片 |
| `A_BIN` / `A_UN` | `BIN op=...` / `UN op=...` | 二元/一元表达式 |

输出格式固定为 2 空格缩进、`KIND key=value`，与 `tools/astdump` 完全一致。
`Ast` 只保存 `ptr/uint/int` 与 `string` 视图，不复制源码；`astRoot` 的生命周期与
`Parser` 相同。

### 形状规则

| 规则 | Go 可观察结果 |
|---|---|
| 泛型调用语句 | 包一层 `EXPR → CALL`；普通调用是裸 `CALL` |
| 索引 vs 切片 | 用 `IndexSlice` 区分 `a[i]` 与 `a[i:]`；不能只看 `Index[1]/[2]` 是否为空 |
| 索引赋值 | `EXPR → BIN op=[]=`；复合赋值按 Go 形状降级 |
| 解引用赋值 | 可转换 RHS 为 `deref=(值, 指针)`；跨包/泛型调用保留 `BIN op==` |
| `*p++` / `a[i]++` | `*p++` 展开为 `VAR p = p + 1` + 残留 `EXPR UN* p`；`a[i]++` 观察为 `EXPR → LIT 0` |
| 内建类型别名 | `int64→i64`、`uint32→u32`、`uint8→u8`、`rune→i32` 等按 Go `TypeName` 输出；点号后的包限定类型不替换 |
| 旧式 const 赋值 | `const` 重新赋值时按 Go 的 `dropOldConstAssign` 形状丢弃旧赋值 |

### 常量折叠

折叠结果按 Go `checkUnary` / `foldArith` / `foldCmp` / `foldEq` / `checkAdd` /
`checkMul` / `checkLogic` 的可观察结果实现：

- 整数：`+ - * / % << >> & | ^`、`< > <= >= == !=`；除零/模零不折叠。
- bool：`&& || == !=`、一元 `!`；`==`/`!=` 对 bool 常量按 Go `foldEq` 的
  `Num` 比较行为处理。
- 字符串：`+`、`==`、`!=`、`string * int`。
- 一元：整数 `-`/`~`、bool `!`；浮点只做一元负号的文本处理。
- 折叠后的 `LIT` 文本按 Go `fmt %v` 对 float64 整数值的规则输出（`goIntText`）。

### 已知差异

`ALL=1` 全仓对拍用白名单输出 `PARITY_KNOWN`；显式传入文件仍严格比较。
2026-11-07 的 16 个已知差异分四类：

| 类别 | 文件 | 原因 |
|---|---|---|
| 大整数精度 | `pkg/hash/fnv/fnv.cute` | 超过 `int64` 的十进制常量自举侧溢出；Go 走 float64 |
| Go 参数位置 `fn(T)` bug | `pkg/path/path.cute` | Go 把 `callback fn(string)` 的类型记成 `string`；不复刻 |
| Go 折叠时序 | `test/negIdx`、`test/runtime/malloc_darwin`、`test/strconv`、`pkg/hash/crc32`、`pkg/compress/lzw`、`pkg/console/caps`、`pkg/hash/crc64`、`pkg/sort/test`、`pkg/sort/tim`、`pkg/console/advanced` | Go 只在 `Check` 可达时折叠；跨文件/跨包符号未解析时不折叠 |
| 浮点格式/折叠 | `test/derefTest/u64`、`test/sortTest`、`pkg/math/test`、`pkg/math/math` | 自举侧保留源码文本；Go 输出 `%v` 最短表示，并折叠 `+Inf`/`NaN` |

另外，`for ; cond; m[0]++` 的 Go `POST` 是未归一化表达式（canonical 为 `EXPR?`），
不复刻该噪声，也不放进固定语料，单独列为已知差异。

### 验收

```bash
# 固定语料：全部 PARITY_OK
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_ast_parity.sh x86_64

# 全仓：已知差异 PARITY_KNOWN，Go 单文件解析失败 PARITY_SKIP_GO_FAIL
ALL=1 BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_ast_parity.sh x86_64
```

当前基线：固定语料 `ok=11|known=0|go_fail=0`；全仓 `ok=214|known=16|go_fail=28`
（258 个 tracked `.cute`）。

## 不支持 / 尚未覆盖

以下语法会返回错误，而不是静默跳过。遇到时先确认是否属于 S2/S3 范围，再决定加语法或改写源码：

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
8. S3 AST 形状：`test/ast/` 下 7 个专项语料（fold/expr/deref/slice/generic/types/control）
   由 `scripts/selfhost_ast_parity.sh` 与 Go 侧逐字节对拍；`test/main.cute` 的
   `caseExprs` 额外检查 `new(int)` 不计类型实参等局部形状。

运行：

```bash
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_parse.sh x86_64
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_ast_parity.sh x86_64
```

期望输出末尾：

```
SELFHOST_PARSE_OK|x86_64|selftest=42|files=18
SELFHOST_AST_PARITY_OK|x86_64|ok=11|known=0|go_fail=0
```

## 已知限制

- S2 只做语法验证，计数变化不代表语义正确；S3 只对齐 AST 形状与常量折叠，不做
  完整类型/符号检查，也不做代码生成。
- 与 Go parser 不是 bug-for-bug 兼容：为兼容仓库语料，额外接受旧式 `struct Name`、
  `fn (self T)` 接收者、无冒号参数/字段等写法；Go 侧实现噪声登记为已知差异。
- 浮点字面量保留源码文本，未实现 Go `%v` 最短格式化；浮点算术不折叠（见
  “已知差异”）。
- 大整数常量超过 `int64` 时自举侧溢出，暂未按 float64 路径处理。
- `build asm` 正文完全不解析；括号不平衡仍会被花括号层级检查发现。
- 没有 token 缓冲/回退；递归下降只向前看当前 token。
- 输入按字节处理，不按 Unicode 码点切分。
