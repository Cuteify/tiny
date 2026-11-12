# Cuteify 自举（selfhost）

本目录用 Cute 语言重写 Cuteify 自身的组件，目标是逐步摆脱“用 Go 写 Cute 编译器”的单向依赖。
当前最新状态：S0 **词法分析器已以 Go 参考实现 `/home/gx/Downloads/dev/lexer` 逐行 1:1
移植**（token 枚举缩编为 `NONE/STRING/KEYWORD/DELIMITER/NUMBER/NAME`），
`scripts/selfhost_test.sh x86_64` 期望 `SELFHOST_OK|x86_64|RC=42`。
上一阶段旧 token 模型（`lex.cute` + `cmd/tokdump` + `parse` + `parsedump`，14 枚举）
随本移植被替换；`parse/`、`cmd/` 及 Go 侧 `lexer/`、`tools/gotokens/`、
`scripts/selfhost_dump.sh` / `selfhost_parity.sh` / `selfhost_parse.sh` /
`selfhost_ast_parity.sh` 仍是旧模型口径，本阶段统一停用，待下游统一 token 模型后恢复。
仓库里还没有可自举的完整编译器。本目录不会假装已经完成自举。

## 当前状态

| 模块 | 版本 | 状态 | 说明 |
|---|---|---|---|
| `lex/` | 0.2.0 | 可用 | **1:1 移植** `/home/gx/Downloads/dev/lexer`（Go 参考实现）：输入 `string`，输出 6 种 token 枚举 + 文本 + 字节区间；行为测试 `RC=42`（`scripts/selfhost_test.sh x86_64`） |
| `cmd/tokdump/` | 0.1.0 | 停用中 | 仍是旧 14 枚举 token 模型，与新 `lex/` **未对接**；等下游统一 token 模型后再移植 |
| `parse/` | 0.2.0 | 停用中 | 语法验证 + 结构计数 + canonical AST 逻辑保留，但 token 枚举是旧模型，依赖新 `lex/` 后需重编验证 |
| `cmd/parsedump/` | 0.2.0 | 停用中 | 依赖 `parse/`，同上 |

- 入口：`selfhost/lex/{buf.cute,lexer.cute}`、`selfhost/parse/parse.cute`、
  `selfhost/cmd/tokdump/main.cute`、`selfhost/cmd/parsedump/main.cute`
- 测试：`selfhost/lex/test/main.cute`（期望退出码 `42`，`scripts/selfhost_test.sh x86_64` 已通过）；
  `selfhost/parse/test/main.cute` 在新 token 模型上未重新验证
- 编译器仍由仓库根目录的 Go 程序提供；自举模块目前作为**被编译的 Cute 包**运行。
- 自举 lexer 不读文件：宿主读入源码后以 `string` 传入，避免在第一阶段引入平台 I/O 差异。

## 目录

```
selfhost/
├── README.md              # 本文件：自举目标、状态、构建与测试
├── lex/
│   ├── package.json       # 包元数据（name=lex）
│   ├── buf.cute           # TokenType / Token / RingBuffer 与关键字/分隔符表（token.go+buf.go 合并）
│   ├── lexer.cute         # Lexer 与扫描器（lexer.go 移植）
│   ├── README.md          # API、token 枚举、与 Go 参考的差异、已知限制
│   ├── testdata/          # 示例语料（sample.cute，取自 Go 参考）
│   └── test/
│       └── main.cute      # 行为测试（关键字/数字/字符串/注释/数字边界）
├── parse/
│   ├── package.json       # 包元数据（name=parse）
│   ├── parse.cute         # S2/S3 parser（语法验证 + 结构计数 + canonical AST）
│   ├── README.md          # API、支持子集、错误码、计数口径、折叠与已知差异
│   └── test/
│       ├── main.cute      # 正/负例与 AST 形状测试
│       └── ast/           # S3 持久 AST 对拍语料（7 个专项文件）
└── cmd/
    ├── tokdump/
    │   ├── package.json   # 包元数据（name=tokdump）
    │   ├── main.cute      # S1：stdin → token 行
    │   └── README.md      # driver 用法与输出格式
    └── parsedump/
        ├── package.json   # 包元数据（name=parsedump）
        ├── main.cute      # S2/S3：stdin → 计数 / canonical AST
        └── README.md      # driver 用法与输出格式
```

项目级自举计划与阶段划分见 [`docs/SELFHOST.md`](../docs/SELFHOST.md)。

## 设计原则

1. **行为以 Go 版为基准**：关键字集合、最长分隔符匹配、数字扫描、注释与字符串规则
   对照 Go 参考实现移植。注意**仓库内 `lexer/` 与 `tools/gotokens/` 仍是旧 14 枚举模型**
   （`/home/gx/Downloads/dev/lexer` 的参考镜像与自举版已是 6 枚举模型）；对拍脚本
   （`selfhost_dump.sh` / `selfhost_parity.sh`）的 TokenType 输出与当前实现不一致，
   继续使用前先统一 token 模型（下游阶段待办）。
2. **token 枚举与 Go 参考一致**：`NONE / STRING / KEYWORD / DELIMITER / NUMBER / NAME`，
   编号 `NONE=0, STRING=1, KEYWORD=2, DELIMITER=3, NUMBER=4, NAME=5`。
   自举侧用 `enum TokenType { ... }` 声明，成员按顺序自动从 0 自增。
3. **API 与 Go 参考一一对应**：`NewLexer` / `Prefetch` / `Next` / `consume` /
   `makeToken` / `RingBuffer` 等名称保持不变；宿主用法（peek 走 `Prefetch`，pure consume 走 `Next`）
   与 Go main 一致。
4. **结构体字段与 Go 参考一致**：`Lexer` 存 `Text/Pos/Line/Col/pfPos/...`（string 字段可寻址，
   与语境无关）。
5. **不依赖 map 索引**：关键字/分隔符表已按字典序排好，`isKeyword`/`isDelimiter` 用二分查找；
   大表动态构造（`new([]string, N, N)`），避开静态大字面量的编译时间恶化。
6. **行为与 Go 参考一致**：词法错误直接 `panic`（与参考一致）；`Lexer.Err` 保留但不写入。
   EOF 返回 `Type == NONE`；`Line` 从 1 开始，`Col` 按字节列计。
7. **parser 以 Go 可观察 AST 为准**：S3 在 S2 骨架上补建 canonical AST 与常量折叠，
   但不做完整类型/符号检查；保留换行 token 并在声明/语句边界显式跳过，`at()` 不比较
   字面量 token，避免源码里的 `"*"`/`"+"` 被当成运算符。Go 侧实现噪声登记为已知差异，
   不复刻 bug。

## 构建与测试

前置：仓库根目录可构建 Go 编译器。以下命令都在仓库根目录执行。

```bash
# 1. 构建编译器（名称随意）
TMPDIR=/tmp/opencode go build -o /tmp/opencode/bin/selfhostc .

# 2. S0 词法测试（本移植的验收闸门：脚本会把源码复制到临时目录，避免污染工作区）
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_test.sh x86_64   # SELFHOST_OK|x86_64|RC=42

# 3. 自举 lexer 行为复测（同 2；多轮确认无寄存器分配偶发问题）
for i in 1 2 3; do
    BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_test.sh x86_64
done

# ====== 以下脚本仍是旧 token 模型口径，本阶段报告 SELFHOST_*_FAIL|COMPILE，属预期 ======
# 4. S1 token 流 driver（默认打印 lex.cute 自身的 token 序列）
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_dump.sh x86_64

# 5. Go/Cute token 序列对拍（默认固定语料，逐字节比较）
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_parity.sh x86_64

# 6. S2/S3 parser：自测（RC=42）+ 固定语料
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_parse.sh x86_64

# 7. S3 canonical AST 对拍 / 全仓对拍
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_ast_parity.sh x86_64
ALL=1 BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_ast_parity.sh x86_64
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

## S2/S3 parser

`selfhost/parse` 在 lexer 之上做递归下降解析，覆盖当前仓库 `.cute` 语料的声明、语句、
表达式与类型引用子集。S2 只返回首个错误码和结构计数；S3 在同一骨架上构建 canonical
AST 并实现常量折叠。完整 API、支持列表、计数口径、折叠规则与已知差异见
[`parse/README.md`](parse/README.md)。

- 自测：`selfhost/parse/test/main.cute`，覆盖 7 组正/负例与 AST 形状，期望 `RC=42`。
- S2 验收入口：`scripts/selfhost_parse.sh x86_64`（**停用**：与新 token 模型不一致，
  本移植后未重跑）；自测通过后跑 18 个固定语料，全部要求 `PARSE_OK`。
- S3 验收入口：`scripts/selfhost_ast_parity.sh x86_64`（**停用**，同上）。
- S3 全仓基线：`ok=214|known=16|go_fail=28`（2026-11-07，旧模型时期）。
- canonical AST 与 Go 侧逐字节对齐：`tools/astdump` 是基准，`parsedump` 设置
  `PARSEDUMP_AST=1` 输出同一格式；默认计数模式保持 S2 兼容。
- S2 暂不支持命名/map 复合字面量、函数字面量、`try/except/finally`、`go/select`
  等语法；遇到时报错，不静默跳过。S3 已补 AST 与折叠，但同样不做完整语义检查。

## 与 Go 参考（`/home/gx/Downloads/dev/lexer`）的差异

| 项目 | Go 参考 | 自举 `selfhost/lex/` |
|---|---|---|
| 输入 | `NewLexer(text string)` | `NewLexer(text string) *Lexer`（一致） |
| token | `Token` 值返回 | `*Token`（Cute 编译器不支持多字段结构体按值返回） |
| 环形缓冲 | `RingBuffer[T any]` 泛型 | 单态化为元素类型固定 `*Token` |
| 字符串 token 区间 | 内容区间（不含定界符） | 一致 |
| 下划线/进制/浮点解析 | `strconv` / `strings.ReplaceAll` | `std:strings`（`replaceAll` / `parseUint` / `parseFloat` / `formatUint`） |
| `RenderVisible` | 换行等转义 | 恒等（当前测试不依赖） |
| `Next()` | 纯循环会每词素重复两次（参考实现 quirk） | **修复为纯消费 API**（弹出刚写入缓存的副本）；`Prefetch()` 语义不变 |
| 数字/关键字/分隔符表 | 字面量初始化 | 运行时动态构造（静态大字面量编译时间指数级恶化） |
| EOF | `NONE` | 一致 |
| 错误 | `panic` | `panic`（一致）；`Lexer.Err`/`Error` 保留但不写入 |
| 关键字判定 | `map[string]int` | 二分查找（表已排序，与 `sort.Strings()` 顺序一致） |

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
4. **GC 视图所有权**：`strings.view` 返回的是外部 ptr 的视图，不应由 LLR 自动
   释放。前端摘要把“对局部变量取地址”保守判为 `Unknown`，后端 `exprAllocates` 只认
   `RetOwned && RetKind == RetFresh`。修复前 `lex.text(l)` 的返回值会在条件分支被
   `freeSlot`，导致 token 文本偶发损坏。
5. **switch 解析**：新 `case`/`default` 前从旧 `CaseBlock` 退回 `SwitchBlock`；
   `default` 不解析 case 值。自举 lexer 的 `tname` 依赖该修复。
6. **Cute `enum` 语法**：支持 `enum Name { A, B = 10 }`，成员自动自增、可显式赋整数；
   枚举名注册为独立命名类型（`type Name int` 语义），成员常量带枚举类型，
   `Lex.k` 与 lexer API 直接使用 `TokenType`。

## 限制

- S3 parser 只对齐 Go parser 可观察的 AST 形状，不做完整类型/符号/代码生成；
  S4 才实现自举后端。
- 已知差异分四类：浮点格式/折叠、Go 折叠时序、Go 参数位置 `fn(T)` 解析 bug、
  大整数常量精度；清单与白名单见 [`parse/README.md`](parse/README.md)。
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

1. S4：在 S3 canonical AST 上实现自举代码生成/后端，与 Go 版汇编或运行结果对拍；
   在此之前不宣称自举编译器已完成。
2. 逐项消除 S3 已知差异：浮点解析/最短格式化、浮点算术折叠、Go 折叠时序建模、
   大整数常量精度；每消除一类，从 `scripts/selfhost_ast_parity.sh` 白名单移除并更新文档。
3. 修复 S2 暴露的宿主编译器问题（`continue` 跳出循环、结构体数组字段、换行/字面量
   处理），修好后逐项移除 parser 侧 workaround，并保留负例防回归。
4. 再讨论文件 I/O、`TokenType.NONE` 作用域限定访问等语言/运行时增强。
5. 对拍工具位于 `tools/gotokens/` 与 `tools/astdump/`，token 基线见
   `docs/SELFHOST.md` §4.8，AST 基线见 §4.12 与 §6。

任何阶段完成前都不宣称“已自举”；状态以本文件表格和 `docs/SELFHOST.md` 为准。
