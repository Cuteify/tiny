# Cuteify 自举（selfhost）

本目录用 Cute 语言重写 Cuteify 自身的组件，目标是逐步摆脱“用 Go 写 Cute 编译器”的单向依赖。
当前完成 S0 **词法分析器**、S1 **token 流 driver** 与 S2 **最小 parser**。
仓库里还没有可自举的完整编译器；S2 parser 只验证语法并统计结构，不建 AST，
也没有自举代码生成器。本目录不会假装已经完成自举。

## 当前状态

| 模块 | 版本 | 状态 | 说明 |
|---|---|---|---|
| `lex/` | 0.1.0 | 可用 | Cute 实现的词法分析器，输入 `string`，输出 token 类型 + 文本 + 区间 |
| `cmd/tokdump/` | 0.1.0 | 可用 | S1 token 流 driver：从 stdin 读入源码，打印 token 类型/文本/行列/区间 |
| `parse/` | 0.1.0 | 可用 | S2 最小 parser：递归下降语法验证 + 结构计数，不建 AST |
| `cmd/parsedump/` | 0.1.0 | 可用 | S2 parser driver：从 stdin 读入源码，输出计数或语法错误 |

- 入口：`selfhost/lex/lex.cute`、`selfhost/parse/parse.cute`、
  `selfhost/cmd/tokdump/main.cute`、`selfhost/cmd/parsedump/main.cute`
- 测试：`selfhost/lex/test/main.cute`、`selfhost/parse/test/main.cute`
  （期望退出码 `42`，x86_64 已通过）
- 编译器仍由仓库根目录的 Go 程序提供；自举模块目前作为**被编译的 Cute 包**运行。
- 自举 lexer 不读文件：宿主读入源码后以 `string` 传入，避免在第一阶段引入平台 I/O 差异。

## 目录

```
selfhost/
├── README.md              # 本文件：自举目标、状态、构建与测试
├── lex/
│   ├── package.json       # 包元数据（name=lex）
│   ├── lex.cute           # 词法分析器实现
│   ├── README.md          # API、token 枚举、扫描规则、错误码
│   └── test/
│       └── main.cute      # 行为测试（关键字/数字/字符串/注释/错误）
├── parse/
│   ├── package.json       # 包元数据（name=parse）
│   ├── parse.cute         # S2 最小 parser（语法验证 + 结构计数）
│   ├── README.md          # API、支持子集、错误码、计数口径
│   └── test/
│       └── main.cute      # 正/负例测试（声明/语句/表达式/换行/词法错误）
└── cmd/
    ├── tokdump/
    │   ├── package.json   # 包元数据（name=tokdump）
    │   ├── main.cute      # S1：stdin → token 行
    │   └── README.md      # driver 用法与输出格式
    └── parsedump/
        ├── package.json   # 包元数据（name=parsedump）
        ├── main.cute      # S2：stdin → PARSE_OK / PARSE_ERROR
        └── README.md      # driver 用法与输出格式
```

项目级自举计划与阶段划分见 [`docs/SELFHOST.md`](../docs/SELFHOST.md)。

## 设计原则

1. **行为以 Go 版 `lexer/` 为基准**：关键字集合、最长分隔符匹配、数字扫描、注释与
   字符串规则都对照 `lexer/lexer.go`、`lexer/keywords.go` 移植。
2. **token 枚举与 Go 版一致**：`NONE / FUNC / VAR / PROCESSCONTROL / SEPARATOR /
   STRING / NUMBER / NAME / CHAR / TYPE / RAW / BOOL / BUILD / IMPORT`，编号也逐项相同。
   Go 侧用现代枚举写法 `type TokenType int` + `const (... = iota)`，并提供
   `TokenType.String()`；自举侧用 `enum TokenType { ... }` 声明，生成独立的命名类型
   （等价于 `type TokenType int`），成员按顺序自动从 0 自增且类型就是 `TokenType`。
   `Lex.k`、`next`、`kw`、`kind`、`tname` 全部使用该类型；`tname(k)` 用 `switch`
   覆盖全部 14 个值（含 `NONE` → `"NONE"`），未知值返回 `""`。
3. **API 名称从简**：`mk`、`next`、`text`、`kind`、`err`、`start`、`end`、`pos`、`tname`。
   与 Go 版 `NewLexer` / `GetToken` / `TokenTypeName` 的职责一一对应，但不照搬长名称。
4. **结构体不存 `string` 字段**：`Lex` 只保存 `ptr + uint`（源码指针、长度、游标、token
   区间），`text()` 时用 `strings.makeString` 构造切片视图。这样规避全局结构体 string
   字段寻址不稳定，也避免每个 token 都复制字符串。
5. **不依赖 map 索引**：关键字映射用 if 链，分隔符匹配用显式字节比较；当前语言没有
   `m[k]`，简单直接的实现反而更容易自举。
6. **不隐藏错误**：`next()` 每次调用重置错误码；`err()` 返回 `OK/ESTR/ERAW/ECHAR`，
   调用方必须检查。EOF 与错误都返回 `NONE`，靠 `err()` 区分。
7. **parser 只验证语法**：S2 不建 AST、不做类型/符号检查；保留换行 token 并在声明/
   语句边界显式跳过，`at()` 不比较字面量 token，避免源码里的 `"*"`/`"+"` 被当成运算符。

## 构建与测试

前置：仓库根目录可构建 Go 编译器。以下命令都在仓库根目录执行。

```bash
# 1. 构建编译器（名称随意）
TMPDIR=/tmp/opencode go build -o /tmp/opencode/bin/selfhostc .

# 2. 跑自举 lexer 测试（脚本会把源码复制到临时目录，避免污染工作区）
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_test.sh x86_64

# 3. S1 token 流 driver（默认打印 lex.cute 自身的 token 序列）
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_dump.sh x86_64

# 4. Go/Cute token 序列对拍（默认固定语料，逐字节比较）
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_parity.sh x86_64

# 5. S2 parser：自测（RC=42）+ 固定语料；也可传单个文件
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_parse.sh x86_64

# 6. 可选：重复跑几轮确认没有 GC/寄存器偶发问题
for i in 1 2 3; do
    BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_test.sh x86_64
done
```

手动运行等价于：

```bash
ROOT=$PWD
WORK=/tmp/opencode/selfhost-run
rm -rf "$WORK" && mkdir -p "$WORK"
cp -a selfhost/lex "$WORK/lex"

cd "$WORK/lex/test"
CUTE_ROOT="$ROOT" CUTE_ARCH=x86_64 /tmp/opencode/bin/selfhostc "$PWD"
nasm -f elf64 -w-label-redef-late -o "$WORK/main.o" _main.asm
gcc -nostartfiles -no-pie -e _start -o "$WORK/main" "$WORK/main.o" -lpthread
"$WORK/main"
echo $?   # 期望 42
```

说明：

- 编译器参数是**目录**，不是单个 `.cute` 文件；测试目录里必须有 `main.cute`。
- **必须传绝对目录**：相对导入路径 `..` 会被压成标签前缀 `_`，包内 `start()` 可能
  退化成 `_start`，与 ELF 入口冲突。脚本已经用 `"$PWD"` 和绝对 `WORK` 路径规避。
- 汇编产物 `_main.asm` 生成在运行命令的当前目录，所以脚本先复制到临时目录。
- `CUTE_ROOT` 指向仓库根，`std:strings` / `std:memory` 才能解析。
- 测试入口 `selfhost/lex/test` 用 `import lex "../"` 引用上一级实现；单独把
  `test/main.cute` 拷走会找不到包。
- 脚本默认编译器是仓库根的 `cuteify2`；它可能是旧构建，建议始终显式设置 `BIN=`。
- 当前建议只跑 x86_64。x86 后端在 Batch 4 之前仍有已知红面（NASM 报
  `operation size not specified`），不能作为自举代码的质量判据。

## S2 parser

`selfhost/parse` 在 lexer 之上做递归下降验证，覆盖当前仓库 `.cute` 语料的声明、语句、
表达式与类型引用子集。它**不建 AST**，只返回首个错误码和结构计数；完整 API、支持列表、
计数口径与限制见 [`parse/README.md`](parse/README.md)。

- 自测：`selfhost/parse/test/main.cute`，7 组正/负例，期望 `RC=42`。
- 验收入口：`scripts/selfhost_parse.sh x86_64`；自测通过后跑 18 个固定语料，
  全部要求 `PARSE_OK`。
- 全仓扫描（2026-11-06）：`test/`、`pkg/`、`selfhost/` 共 247 个 `.cute` 文件，
  247/247 `PARSE_OK`。
- 自解析基线：`selfhost/lex/lex.cute` 与 `selfhost/parse/parse.cute` 均可被
  S2 parser 完整解析；计数会随源码改动变化，判据是 `PARSE_OK` 而不是固定数值。
- S2 暂不支持命名/map 复合字面量、函数字面量、`try/except/finally`、`go/select`
  等语法；遇到时报错，不静默跳过。AST 与 Go parser 逐节点对拍留给 S3。

## 与 Go 版的差异

| 项目 | Go 版 `lexer/` | 自举 `selfhost/lex/` |
|---|---|---|
| 输入 | `NewLexer(filename)` 读文件 | `mk(text)` 接收字符串，宿主负责读文件 |
| 状态 | `Lexer` 带 `Text`/`Filename`/`LineFeed` 等 string 字段 | `Lex` 只存 `ptr/uint/int`，无 string 字段 |
| token | `Token{Type, Value, Cursor, EndCursor}` 值返回 | `next()` 返回类型，`text/start/end` 读取最近 token |
| token 名称 | `TokenTypeName` switch 含 `NONE` | `tname(kind)` switch，名称与编号同 Go |
| 枚举类型 | `type TokenType int` + typed 常量 | `enum TokenType` 独立命名类型 + typed 成员 |
| 关键字 | `map[string]int` | if 链 + `strings.eq` |
| 字符串 token 区间 | 包含引号的原始区间 + 去引号 `Value` | `start/end` 指向**内容**（不含定界符） |
| EOF | `io.EOF` | `NONE` + `err()==OK` |
| 错误 | `panic`/`MissError` | 错误码，调用方显式检查 |
| 注释换行 | 搜索 `LineFeed`，CRLF 下先返回 `\r` 再返回 `\n` | 注释停在 `\r` 或 `\n`，后续按单字符分隔符逐字节返回 |
| 边界检查 | 字符串/裸串结尾有历史 off-by-one | 按 `cursor < len` 扫描，收尾定界符在 EOF 也合法 |

**没有移植的部分**：`Lexer.Next()` 里 `Text[Cursor:EndCursor] != Value` 的自检（对带定界符
token 的判断本身不一致）、`Error` 的行列定位、`Filename`、`SepTmp` 暂存字段。自举版用
“扫描完直接产出 token”的状态机替代，行为等价且更简单。

## 为自举补齐的编译器修复

自举 lexer 暴露了几个宿主编译器问题，已在 Go 侧修复；它们不是 lexer 行为的一部分，
但缺少任一修复都无法稳定通过测试：

1. **token 枚举现代化**：`lexer/keywords.go` 改为 `type TokenType int` + typed `iota`
   常量，新增 `String()`（未知值返回空串），`TokenTypeName` 作为兼容入口；
   `LexTokenType` 与 `Token.Type` 同步改为 `TokenType`。`Token.String()` 走 `String()`。
2. **NASM 字符串数据段**：字符串常量改用反引号字符串，并转义反斜杠、反引号、双引号、
   换行、制表、回车。原先双引号字符串不支持转义，含反斜杠的 token 文本会汇编失败。
3. **容器实参三槽装载**：`SysV.Call` 的寄存器 buffer 与栈参数路径统一走表达式编译器，
   支持字符串拼接、切片、调用等任意容器表达式。此前 `f("a" + b)` 会把实参编译成
   全零容器，只有先赋给局部变量再传参才正常。
4. **GC 视图所有权**：`strings.makeString` 返回的是外部 ptr 的视图，不应由 LLR 自动
   释放。前端摘要把“对局部变量取地址”保守判为 `Unknown`，后端 `exprAllocates` 只认
   `RetOwned && RetKind == RetFresh`。修复前 `lex.text(l)` 的返回值会在条件分支被
   `freeSlot`，导致 token 文本偶发损坏。
5. **switch 解析**：新 `case`/`default` 前从旧 `CaseBlock` 退回 `SwitchBlock`；
   `default` 不解析 case 值。自举 lexer 的 `tname` 依赖该修复。
6. **Cute `enum` 语法**：支持 `enum Name { A, B = 10 }`，成员自动自增、可显式赋整数；
   枚举名注册为独立命名类型（`type Name int` 语义），成员常量带枚举类型，
   `Lex.k` 与 lexer API 直接使用 `TokenType`。

## 限制

- S2 parser 只做语法验证与结构计数，不建 AST、不做类型/符号/代码生成；完整 parser
  与逐节点对拍留给 S3。
- 没有文件 I/O、路径、行号/列号；错误只给字节区间，driver 负责换算行列。
- 按字节扫描，与 Go 版一致，不按 Unicode 码点切分。
- 关键字匹配是 O(关键字数) 的字符串比较；lexer 不是性能瓶颈，暂不做 trie。
- Cute 的 `enum` 会生成独立命名类型，成员常量带该类型；暂不支持
  `TokenType.NONE` 作用域限定访问。
- 测试源码里不能直接写跨行裸字符串（当前编译器对字面量 RAW 的跨行处理有缺陷），
  测试用运行时拼接构造含换行的源码；lexer 本身支持跨行裸串。
- 不含显式 `import "std:strings"` 的裸 `main` 程序可能链接失败：编译器 pre-pass
  `markLinkProviders` 会把 `strings.eq` 等 build link 包装器标为有用，但其体内调用的
  `strings.compare`/`strings.count` 未被传递标记。自举测试显式 import 了 `std:strings`，
  不受影响；这是宿主侧既有问题，单独修复。

## 下一步

1. S3：给 `selfhost/parse` 增加 AST 节点与 `parsedump --ast`，与 Go parser 对同一批
   源码逐节点对拍；先固定声明/语句/表达式节点形状，再扩语法覆盖。
2. 修复 S2 暴露的宿主编译器问题（`continue` 跳出循环、结构体数组字段、换行/字面量
   处理），修好后逐项移除 parser 侧 workaround，并保留负例防回归。
3. 再讨论文件 I/O、`TokenType.NONE` 作用域限定访问等语言/运行时增强。
4. 对拍工具位于 `tools/gotokens/`，token 基线见 `docs/SELFHOST.md` §4.8；
   parser 验收入口见 §4.9 与 §6。

任何阶段完成前都不宣称“已自举”；状态以本文件表格和 `docs/SELFHOST.md` 为准。
