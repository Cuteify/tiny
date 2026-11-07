# Cuteify 自举计划（SELFHOST）

> 状态：**进行中，已完成 S0 词法分析器、S1 token 流 driver 与 S2 最小 parser**。
> 仓库当前没有自举编译器或自举代码生成器；S2 parser 只验证语法并统计结构，不建 AST。
> 入口目录：[`selfhost/`](../selfhost/README.md)。
> 模块文档：[`selfhost/lex/README.md`](../selfhost/lex/README.md)、
> [`selfhost/parse/README.md`](../selfhost/parse/README.md)。

本文是项目级自举说明；模块的 API、扫描规则、错误码以对应模块的 README 为准。

## 1. 目标与非目标

### 目标

1. 用 Cute 语言实现 Cuteify 编译器的前端组件，逐步减少对 Go 宿主的依赖。
2. 每个阶段都能被当前 Go 编译器编译、运行、测试，并留下可复现的验收命令。
3. 与 Go 版实现保持**行为兼容**：关键规则逐条对照 `lexer/`、`parser/`，差异必须写进文档。
4. 最终目标是自举解析：自举 lexer/parser 能读取自身源码，并与 Go 版输出对拍。

### 非目标

- 本阶段不替换 Go 编译器入口，不修改 `main.go` 的构建方式。
- 不承诺“源码自举”（用 Cute 编译器编译 Cute 编译器）的时间表；S2 parser 仍是最小子集。
- 不把 `selfhost/` 混进 `pkg/` 标准库计数，也不改现有 stdlib 测试矩阵的口径。
- 不为自举而给语言仓促加特性；确实需要语言能力时，先单独评估/提交。

## 2. 阶段划分

| 阶段 | 内容 | 状态 | 验收 |
|---|---|---|---|
| S0 | 词法分析器（string 输入） | ✅ 0.1.0 | `BIN=... scripts/selfhost_test.sh x86_64` 返回 42 |
| S1 | token 流 driver / 诊断输出 | ✅ 0.1.0 | `scripts/selfhost_dump.sh` 打印 `lex.cute` 的 token 序列（末尾 `EOF ... tokens=N`） |
| S2 | 最小 parser（声明/表达式/语句子集） | ✅ 0.1.0 | `scripts/selfhost_parse.sh x86_64`：自测 `RC=42`、固定语料全部 `PARSE_OK` |
| S3 | 完整自举 parser | 计划中 | 与 Go parser 对拍同一批源码（AST 逐节点） |
| S4 | 自举代码生成/后端 | 计划中 | 与 Go 版汇编或运行结果对拍 |

当前完成 S0、S1、S2。S3 之前不宣称“自举 parser 已具备完整 AST/语义”。

## 3. 目录与边界

```
selfhost/                 # 自举实现，独立于 pkg/ 与 Go lexer/
├── README.md             # 总览、状态、构建测试
├── lex/                  # S0：词法分析
│   ├── lex.cute
│   ├── package.json
│   ├── README.md
│   └── test/main.cute
├── parse/                # S2：最小 parser（语法验证 + 结构计数）
│   ├── parse.cute
│   ├── package.json
│   ├── README.md
│   └── test/main.cute
└── cmd/
    ├── tokdump/          # S1：token 流 driver（stdin → token 行）
    │   ├── main.cute
    │   ├── package.json
    │   └── README.md
    └── parsedump/        # S2：parser driver（stdin → 计数/错误）
        ├── main.cute
        ├── package.json
        └── README.md
scripts/selfhost_test.sh   # S0 行为测试入口（复制到临时目录编译运行）
scripts/selfhost_dump.sh   # S1 token 流入口（编译 driver 并喂入源码）
scripts/selfhost_parity.sh # S0 token 序列 Go/Cute 对拍
scripts/selfhost_parse.sh  # S2 parser 自测、固定语料与单文件验证
```

边界约定：

- `selfhost/` 不被 `pkg/` 的通配测试脚本自动收录；需要单独运行 `scripts/selfhost_test.sh`。
- 自举代码不 import 编译器内部 Go 包，只使用 `std:strings`、`std:memory` 等 Cute 标准库。
- Go 版 `lexer/` 继续作为行为基准和回归对拍对象，不因自举而删除或改写。

## 4. 关键设计决定

### 4.1 输入是 `string`，不是文件

宿主负责读文件并把内容传给 `lex.mk(text)`。原因：

- 第一阶段避免文件 I/O、路径、换行规范化的平台差异；
- lexer 可以纯函数式地测试任意构造的源码；
- 后续需要 `fromFile` 时，在宿主侧或独立适配层增加即可。

### 4.2 token 枚举与 Go 版逐项一致

Go 版 `lexer/keywords.go` 使用现代枚举写法：

```go
type TokenType int

const (
    NONE TokenType = iota
    FUNC
    VAR
    PROCESSCONTROL
    SEPARATOR
    STRING
    NUMBER
    NAME
    CHAR
    TYPE
    RAW
    BOOL
    BUILD
    IMPORT
)

func (t TokenType) String() string { /* NONE → "NONE" ... */ }
```

自举版使用同名的 Cute `enum` 声明：

```cute
enum TokenType {
    NONE
    FUNC
    VAR
    PROCESSCONTROL
    SEPARATOR
    STRING
    NUMBER
    NAME
    CHAR
    TYPE
    RAW
    BOOL
    BUILD
    IMPORT
}
```

Cute 的 `enum` 创建独立命名类型：`enum TokenType` 等价于 Go 的
`type TokenType int`。成员默认从 0 自增，可用 `= 整数` 指定值；成员常量的类型就是
`TokenType`，而不是 `int`。**名称、顺序、数值与成员类型身份与 Go 版全部对齐**。
`Lex.k`、`next`、`kw`、`kind`、`tname` 都使用 `TokenType`，lexer API 不出现
int/enum 混用。`tname(k)` 用 `switch` 覆盖全部 14 个值（`NONE` → `"NONE"`，未知值
返回 `""`），与 Go 版 `TokenType.String()` 的分支一一对应；`TokenTypeName` 只是
`String()` 的兼容入口。

这不是两套枚举，而是同一套枚举在两种语言里的声明形式。Cute 侧暂不支持
`TokenType.NONE` 作用域限定访问；这属于后续语言演进。Cute 的通用数值兼容规则仍允许
命名数值类型与内置数值类型隐式互转，该规则不限于 enum，也不影响本模块的 typed API。

### 4.3 简化 API，不简化语义

与 Go 版的职责对应：

| Go 版 | 自举版 |
|---|---|
| `NewLexer(filename)` | `mk(text)` |
| `GetToken()` / `Next()` | `next(l)` |
| `Token.Value` | `text(l)` |
| `Token.Type` | `kind(l)` / `next` 返回值 |
| `Token.Cursor/EndCursor` | `start(l)/end(l)` |
| `LexTokenType` / `TokenTypeName` | `tname(k)` |

自举版没有 `Token` 结构体值返回，也没有 `Filename`/`LineFeed` 字段；错误通过 `err(l)`
返回码暴露，EOF 与错误都用 `NONE` + 错误码区分。

### 4.4 字符串/字符/裸串的区间语义

Go 版 token 的 `Cursor/EndCursor` 覆盖含定界符的原始文本，`Value` 不含定界符；自举版
只有一组区间，选择指向**内容**：

- `"hello"` → `text="hello"`，`start=1`，`end=6`，`pos=7`
- `` `raw` `` → `text="raw"`，`start=1`，`end=4`，`pos=5`
- `'a'` → `text="a"`，`start=1`，`end=2`，`pos=3`

parser 若需要定界符位置，可由 `start-1`/`end+1` 推回；文档和测试固定这一约定。

### 4.5 注释与 CRLF

注释 `//` 跳到行尾，游标停在 `\r` 或 `\n` 上；后续按单字符分隔符返回，因此 CRLF 会产生
`\r`、`\n` 两个 `SEPARATOR`。这与 Go 版在 CRLF 下的实际 token 序列一致（Go 版先返回
`\r`，再返回 `\n`）。如果未来要归一化换行，应在宿主读文件时做，而不是 lexer 内部偷偷改。

### 4.6 宿主编译器配套修复

自举不是“只写 Cute 代码”。S0 期间发现并修复了以下 Go 侧问题，否则自举 lexer 无法
稳定跑通：

| 问题 | 修复 |
|---|---|
| `LexTokenType` 不含 `NONE`，字符串映射不完整 | 改为 `type TokenType int` 现代枚举，补 `"NONE"`，新增 `String()` 全量 switch，`TokenTypeName` 保留为兼容入口 |
| Cute 侧缺少枚举声明形式，token 常量只能逐条 `const` | 新增 `enum Name { ... }` 语法：成员自增/显式整数、枚举名注册为独立命名类型、成员常量带枚举类型 |
| NASM 数据段双引号字符串不处理反斜杠转义 | 改用反引号字符串并转义 `\`、`` ` ``、`"`、换行、Tab、CR |
| 字符串拼接作为函数实参时被编成全零容器 | `SysV.Call` 的容器实参统一走表达式编译器三槽装载 |
| GC 误释放 `strings.makeString` 返回的视图 | 前端取地址局部判 `Unknown`，后端只认 `RetFresh` |
| `switch` 的 `case`/`default` 解析状态错误 | 新分支前退回 `SwitchBlock`；`default` 不解析 case 值 |

这些修复属于宿主编译器，不改变自举 lexer 的 API；但它们应随自举模块一起回归，
因为 `tname`、含反斜杠的 token 文本、字符串拼接测试都直接依赖它们。

### 4.7 S1 token 流 driver 的输入与输出

driver 位于 `selfhost/cmd/tokdump/`，只负责“宿主读入 + 打印诊断”，lexer 仍只接收
`string`：

- 从 stdin 读入源码（上限 1 MiB），交给 `lex.mk`；
- 一行一个 token：`line:col  TYPE  [text]  [start,end)`；
- `line:col` 由 driver 按字节偏移换算（1-based，行号按 LF 递增）；
- LF/CR/TAB 在 token 文本里显示为 `\n`/`\r`/`\t`；
- 末尾输出 `EOF line:col  tokens=N`；词法错误输出 `ERROR code at line:col` 并返回 1。

这样 S0 的 API 不需要引入文件 I/O 或行列状态；需要文件名/行列的宿主能力集中在
driver 层。

### 4.8 Go/Cute token 序列对拍

`tools/gotokens` 用 Go 版 `lexer/` 输出与 `tokdump` 完全相同的归一化格式，脚本
`scripts/selfhost_parity.sh` 对每个源码逐行 diff：

- STRING/CHAR/RAW 的 Go `Cursor/EndCursor` 含定界符，工具统一换算成内容区间；
- 输出含 1-based 行列号与字节区间，因此对拍同时校验 token 边界和换行处理；
- 默认固定语料覆盖 `selfhost/`、`test/`、`pkg/slices`、`pkg/strings`、`pkg/sort`；
- 2026-11-06：15 个文件、19160 tokens 逐字节一致。

### 4.9 S2 最小 parser：只验证，不建 AST

S2 的验收目标是证明自举词法流能被自举语法分析消费，而不是一次性复刻 Go parser。
`selfhost/parse` 因此只做递归下降验证与结构计数：

- 入口是 `mk(src)` + `file(p)`；错误通过 `err(p)` / `errPos(p)` 暴露；
- 错误码分为 `ETOK/EDECL/ETYPE/ESTMT/EEXPR`，只记录第一个错误，`file` 遇错即停；
- 覆盖 import、build（含 `build asm`）、enum、struct/interface/别名、const/var、fn
  （含方法接收者与泛型声明）、if/for/while/switch、ret/defer/break/continue、
  赋值/多左值、表达式优先级、调用/索引/切片/选择器、复合字面量与类型引用；
- 不建 AST、不做类型检查、不做符号解析；计数只是结构统计，不是 Go AST 节点数的等价物。

parser 的 API、计数口径与完整支持列表见
[`selfhost/parse/README.md`](../selfhost/parse/README.md)。

### 4.10 S2 暴露的四个实现约束

S2 期间遇到的宿主/自举行为问题已经固化为 parser 的实现约束：

| 约束 | 原因 |
|---|---|
| 换行必须保留，在声明/语句边界显式跳过 | 全局跳过会让下一行行首的 `*q` 被上一行表达式当成乘号 |
| `at()` 不比较 STRING/CHAR/RAW/NUMBER/BOOL | 否则源码里的 `"*"`、`"+"`、`"{"` 会被误判为运算符或块开始 |
| 拿到 token 时立即检查 `lex.err` | `lex.next()` 每次调用会重置错误码，延后检查会丢掉未闭合字符串的 `ESTR` |
| parser 循环不使用 `continue`，`Parser` 只用标量/指针字段 | 当前编译器在 `for ; true; { ... }` 中执行 `continue` 会退出循环；结构体数组字段读写不可靠 |

这些问题目前通过 parser 侧规避，后续修宿主编译器时应同步移除对应 workaround，
并保留 `selfhost/parse/test` 的负例防止回归。

### 4.11 类型内建映射与自举 parser

Go 编译器的类型内建映射（string/map/list → std，见
[`stdplan/TYPE_INTRINSIC.md`](stdplan/TYPE_INTRINSIC.md)）发生在 **parser Check
与 codegen**，不改变 lexer 的 token 流，也不改变 S2 parser 的“只验证/计数”
职责：

- `test/intrinsic_string`、`overload`、`map_index`、`neg_index_step` 的 AST
  形状仍以 Go parser 可观察结果为准；`parsedump` 的计数口径不因 lowering
  改变。
- 自举 parser 目前只消费源码并统计结构，不执行 Check/codegen，因此不受
  `CUTE_NO_INTRINSIC` 影响；该开关只用于 Go 编译器的回归定位。
- 后续自举编译器/完整 AST（S3）需要按同一张 `parser/intrinsic.go` 表实现
  lowering 与重载 mangling；在 S3 完成前不宣称自举侧已对齐。
- 本波不修改 `selfhost/`；若自举 parser 的固定语料出现差异，先按 S2 语法
  子集缺口归因，再回到本节的待办。

## 5. 与 Go 版的已知差异

| 差异 | 影响 | 处理 |
|---|---|---|
| 无文件 I/O / `Filename` | 错误没有文件名 | S1 driver 从 stdin 读入；文件名仍由宿主补 |
| 无行列号 | 错误只有字节区间 | S1 `tokdump` 已按偏移补行列换算 |
| 错误码代替 panic | 调用方必须检查 `err()` | 文档 + 测试固定 |
| 字符串/字符 token 区间指向内容 | 与 Go 的 `Cursor/EndCursor` 不同 | 文档固定；parser 按内容区间使用 |
| 无 `Lexer.Next()` 的自检分支 | 不会复现 Go 版对带定界符 token 的怪异判断 | 视为修正，不追求 bug-for-bug |
| 关键字 if 链 | 代码更长，性能非瓶颈 | 等语言有 map 索引或 trie 再优化 |
| 跨行裸串字面量测试受限 | 当前编译器对源码内跨行 RAW 支持不完整 | 测试用 `nl()` + `makeString` 运行时构造换行；lexer 扫描本身已覆盖 |
| `tname` 用 switch | 代码略长，token 类型少，非瓶颈 | 与 Go `TokenType.String()` 分支对齐，不追求表驱动 |
| S2 parser 不建 AST | 无法做语义检查、无法逐节点对拍 | 只做语法验证与结构计数；AST 对拍留给 S3 |
| S2 parser 额外接受旧式语法 | 与 Go parser 不是 bug-for-bug 兼容 | 为兼容仓库语料接受 `struct Name`、`fn (self T)`、无冒号参数/字段等写法 |
| S2 不支持命名/map 复合字面量与函数字面量 | 当前仓库语料未使用，先不扩大语法面 | 遇到时返回 `EEXPR`/`ETYPE`，不静默跳过 |

## 6. 验收与回归

```bash
# 构建当前 Go 编译器
TMPDIR=/tmp/opencode go build -o /tmp/opencode/bin/selfhostc .

# 自举 lexer 行为测试（期望 RC=42）
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_test.sh x86_64

# S1 token 流 driver：默认打印 lex.cute 自身的 token 序列
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_dump.sh x86_64

# Go/Cute token 序列对拍（默认固定语料）
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_parity.sh x86_64

# S2 parser：自测（RC=42）+ 固定语料，全部要求 PARSE_OK
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_parse.sh x86_64

# S2 parser：只验证指定文件
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_parse.sh x86_64 test/enum/main.cute

# 标准库 22 个用例的回归矩阵（只比较结果行，不改变口径）
BIN=/tmp/opencode/bin/selfhostc scripts/stdlib_matrix.sh x86_64 1
```

当前基线（2026-11-06）：

- `scripts/selfhost_test.sh x86_64`：连续 5 轮 `SELFHOST_OK|RC=42`。
- `scripts/selfhost_dump.sh x86_64`：`SELFHOST_DUMP_OK|x86_64|tokens=3851`
  （2026-11-06；token 数随 `lex.cute` 改动变化，判据是末尾 `EOF ... tokens=N`
  且含 `IMPORT [import]` / `TYPE [enum]`）。
- `scripts/selfhost_parity.sh x86_64`：`SELFHOST_PARITY_OK|x86_64|files=15|tokens=19160`
  （2026-11-06；固定语料逐字节一致，语料清单见脚本）。
- `scripts/selfhost_parse.sh x86_64`：`SELFHOST_PARSE_OK|x86_64|selftest=42|files=18`
  （2026-11-06；自测覆盖 7 组正/负例，固定语料全部 `PARSE_OK`）。
- S2 自解析基线：
  `selfhost/lex/lex.cute` → `PARSE_OK|decls=31|imports=2|builds=0|enums=1|structs=1|consts=4|vars=39|fns=23|stmts=449|exprs=954`；
  `selfhost/parse/parse.cute` → `PARSE_OK|decls=68|imports=2|builds=0|enums=0|structs=1|consts=6|vars=13|fns=59|stmts=740|exprs=1796`。
  计数随源码改动变化，验收判据是 `PARSE_OK` / 自测 `RC=42`，不是固定数值。
- 全仓 `.cute` 扫描（2026-11-06）：`test/`、`pkg/`、`selfhost/` 共 247 个文件，
  247/247 `PARSE_OK`。
- `test/enum`：编译、汇编、链接后 `RC=42`，覆盖自增、显式值、十六进制值、负值、
  显式值后续自增，以及枚举类型用于变量、函数参数/返回值和结构体字段。
- `scripts/stdlib_matrix.sh x86_64 1`：22 个用例中 21 个 `RC=42`；
  `pkg/slices/test` 为 `RC=230`，与 `HEAD` 构建的基线一致，不是本轮回归。
- x86：自举测试在 NASM 阶段失败（`operation size not specified`），属于 Batch 4 前
  的已知红面，不作为本轮门槛。
- `switch` 修复用 `test/switch_test` 验证：补 `import "std:strings"` 后返回 `20`
  （`case 2`）。裸测试的链接失败是既有 `markLinkProviders` 问题，见下。

回归纪律：

- 自举测试必须独立于 `pkg/` 矩阵，不改变 `scripts/stdlib_matrix.sh` 的 22 个用例口径。
- 修改 `selfhost/lex` 后至少跑一次 x86_64 测试；x86 只作为参考，不作为 Batch 4 之前的门槛。
- 修改 `selfhost/lex` 后还要跑一次 `selfhost_dump.sh`，确认 token 流可完整打印且无
  `ERROR` 行；token 数变化本身不是失败。
- 修改任一侧 lexer 规则后跑 `selfhost_parity.sh`，固定语料必须全部 `PARITY_OK`。
- 修改 `selfhost/parse` 后跑 `selfhost_parse.sh`：自测必须 `RC=42`，固定语料必须全部
  `PARSE_OK`；全仓扫描出现新失败时，先判断是语法子集缺口还是 parser 回归。
- 新增 parser 语法时同步补 `selfhost/parse/test` 的正/负例；负例必须断言错误码，
  不能只断言“失败”。
- 与 Go 版对拍时，以 Go 版 token 序列为基准；差异必须先写进 `selfhost/lex/README.md`。
  S2 parser 暂不与 Go parser 逐节点对拍，那是 S3 的验收项。
- 不提交 `_main.asm`、`gc_summary.json`、`gc_llr.txt` 等运行产物。
- 编译器参数必须传**绝对目录**；相对导入 `..` 会被压成标签前缀 `_`，包内 `start()`
  可能退化成 `_start`，与 ELF 入口冲突。
- 不含显式 `import "std:strings"` 的裸 `main` 程序可能链接失败
  （`std_strings_compare`/`std_strings_count` 未定义）。这是 `markLinkProviders`
  只标记包装器、不传递标记被调函数的既有问题，与自举模块无关；自举测试显式 import
  了 `std:strings`，不受影响。

## 7. 下一步

1. S3：在 `selfhost/parse` 上补 AST 节点与 `parsedump --ast`，与 Go parser 对同一批
   源码逐节点对拍；先固定声明/语句/表达式的节点形状，再扩语法覆盖。
2. 把 S2 的 workaround 与宿主编译器缺陷分开跟踪：`continue` 跳出循环、结构体数组
   字段、换行/字面量处理修复后，逐项移除 parser 侧规避并保留负例。
3. 讨论 `TokenType.NONE` 作用域限定访问等语言演进；枚举的独立命名类型与 typed
   成员已在本轮落地。
