# lex —— Cuteify 自举词法分析器

`selfhost/lex` 是 `/home/gx/Downloads/dev/lexer`（Go 参考实现，同批镜像到
`lexer/` 的对照指引版本）的**逐行 1:1 移植**：输入一段源码 `string`，输出
token 类型、文本与字节区间；不读文件、不建 AST。

- 实现：`buf.cute`（`token.go` 与 `buf.go` 合并，按文件依赖序排在前）、`lexer.cute`
- 包名：`lex`
- 测试：`test/main.cute`（通过返回 `42`）
- 外层总览：`../README.md`
- S1 token 流 driver：`../cmd/tokdump/` —— **与本移植未对接**（仍是旧 token 模型，见“已知限制”）

## 快速开始

```cute
import "std:console"
import lex "../"

fn main() int {
    var l: *lex.Lexer = lex.NewLexer("fn main() {}")
    for ; true; {
        var t: *lex.Token = l.Next()
        if t.Type == lex.NONE {
            break
        }
        console.print(lex.TokenType.String(t.Type))
        console.print(" [")
        console.print(t.Value)
        console.print("]\n")
    }
    ret 0
}
```

## API

| 函数 | 签名 | 作用 |
|---|---|---|
| `NewLexer` | `fn NewLexer(text string) *Lexer` | 以源码字符串创建词法分析器（不复制源码） |
| `Lexer.Prefetch` | `fn Lexer.Prefetch(l *Lexer) *Token` | 扫描下一个 token，写入预取缓存并返回它（`Go 参考 main.go` 用的就是这个） |
| `Lexer.Next` | `fn Lexer.Next(l *Lexer) *Token` | 纯消费 API：优先弹出缓存，否则等价 `Prefetch` 并弹出刚写入的这份副本 |
| `Lexer.consume` | `fn Lexer.consume(l *Lexer, t *Token)` | 推进 `pfPos/pfLine/pfCol`（内部） |
| `Lexer.makeToken` | `fn Lexer.makeToken(l *Lexer, t *Token) *Token` | 统一构造 token：行列写入、消费、入缓存（内部） |
| `TokenCoord` | `fn TokenCoord(pos int, endPos int) *Token` | 构造只带 `Pos/EndPos` 的“`consume` 助手” token |
| `NewRingBuffer` | `fn NewRingBuffer(size int) *RingBuffer` | 预取 FIFO（`prefetchCap = 8`） |
| `RingBuffer.Read/Write/IsEmpty/IsFull/Resize` | `*RingBuffer` 方法 | 预取队列操作 |
| `kwTable` / `delimTable` | `fn kwTable() []string` / `fn delimTable() []string` | 已排序表（`isKeyword`/`isDelimiter` 二分查找） |
| `isKeyword` / `isDelimiter` | `fn isKeyword(s string) bool` / `fn isDelimiter(s string) bool` | 关键字/分隔符判定 |
| `isDigit` / `isDigitByte` / `isSpace` | `fn ...(b byte) bool` | 字节分类 |
| `numberBase` / `isIntDigit` / `handleNumber` / `handleComment` / `handleString` | 内部函数 | 数字/注释/字符串扫描器 |
| `Error.Error` | `fn Error.Error(e *Error) string` | 错误格式化（`Error` 类型保留；当前词法错误行为同 Go 参考：`panic`） |

## Token 枚举（与 Go 参考一致）

`NONE=0`、`STRING=1`、`KEYWORD=2`、`DELIMITER=3`、`NUMBER=4`、`NAME=5`。

| 名称 | 含义 |
|---|---|
| `NONE` | EOF |
| `STRING` | 双引号 / 单引号 / 反引号字符串（含定界符文本不包含在 `Value` 里） |
| `KEYWORD` | cute 全量关键字（go 关键字表为准） |
| `DELIMITER` | 分隔符 / 运算符（1~3 字节最长匹配） |
| `NUMBER` | 数字字面量（整数/浮点统一） |
| `NAME` | 标识符、关键字表外的词素 |

## 词法规则（与 Go 参考一致）

- token 起始处跳过空格 / Tab / CR / LF。
- 数字：十进制、`0x/0b/0o` 进制前缀（内嵌 `_` 合法）、小数（`.` 后紧跟数字）、
  科学计数法（`e/E` 后可选 `+/-`，至少一位数字）、整数和指数部分都可带 `_`。
- 主扫描循环按 3 → 2 → 1 字节贪婪匹配分隔符；命中分隔符后：
  - `//` 行注释：保留其后的换行，注释本身不产出 token；
  - `/* ... */` 块注释：非嵌套，可跨行，不产出 token；
  - `` ` ``、`'`、`"` 进入字符串分支（`STRING`）；
  - 否则按词素切分，`isKeyword` 命中为 `KEYWORD`，否则 `NAME`。
- 词素扫描只有遇到分隔符才结束（结尾也可能是 EOF）。
- 行列号：`Line` 从 1 开始；`Col` 按字节列数（与 Go 参考一致），Tab 计 1 列。

## Token 字段

`t.Type` 类型；`t.Value` 词素文本；`t.Number = f64`（仅 NUMBER 有值）；
`t.Pos`/`t.EndPos` 起止字节偏移（左闭右开）；`t.Line`/`t.Col` 起点行列；
`t.EndLine`/`t.EndCol` 终点行列。`Pos/EndPos/Line/Col` 是宿主可读字段。

EOF 时 `Next()` 返回 `Type == NONE` 的 token，行列号为当前光标位置。

## 测试

```bash
scripts/selfhost_test.sh x86_64     # 期望 SELFHOST_OK|x86_64|RC=42
```

`test/main.cute` 约定：返回 `42` = 全部通过；其它值 = 该失败用例编号。通过时输出以
`PASS|case=N` 逐条回显，最后一行为 `LEXER_SELFTEST|PASS|ALL`；失败时输出
`FAIL|case=N want=... got=... want_text=...`，并以对应编号返回。按组覆盖：

1. 空输入 / EOF；2. 全部关键字 + `self`/标识符；3. 数字（进制/小数/科学计数法/下划线）；
4. NUMBER 字段；5. 数字边界（`0x`、`1.`、`123abc`、`1e+`、`0b2`、`0o8`，含文本尾缀 `1.` 的越界防护）；
6. 二/三字符分隔符最长匹配；7. 字符串 / 字符 / 裸串；8. 注释（行注释/块注释/含换行）；
9. 行列号跨行；10. EOF 与缓存语义；11. 关键字最长匹配；12. 复合表达式切分。

测试里的换行用 `nl()` 在运行时构造（`memory.malloc` 写入字节 `10` + `strings.makeString`）：
当前 Cute 源码里的 `"\n"` 是两字符反斜杠 + n。

42 是约定的“通过”标记：Unix 退出码只有 0–255 约 8 个可用位，自举循环用非 0 码区分失败组，42 只是任选的通过码（无其它语义）；CI（`scripts/selfhost_test.sh`）检查的是 RC 是否等于 42。早期版本 `case=42`（`_x`）失败组编号与通过码碰撞，导致自举测试长期“假绿”——本次已把该用例失败码改为 43。

## 与 Go 参考的差异

| # | 差异 | 说明 |
|---|---|------|
| 1 | Token / Error / Lexer 按 `*T` 传递/缓存 | Cute 编译器不支持多字段结构体按值返回（与 `docs/LANGUAGE.md` §15 一致） |
| 2 | `RingBuffer[T any]` 单态化为元素类型固定 `Token` | Cute 不支持泛型结构体（§15 已登记） |
| 3 | `unsafe.cast[int](b)` / `unsafe.cast[uint](...)` 替代 Go 数值转换 | byte 与 int 不直接比较；字面量只能是 `u8` 等可判大小类型，见 LANGUAGE.md §5.5 |
| 4 | **Next 语义修复：弹出 makeToken 刚写入缓存的副本** | Go 参考 `makeToken` 既返回 token 又写预取缓存，`Next()` 纯循环会把每个词素返回 **两次**（与 `Prefetch()` 语义重复）。本移植让 `Next()` 是纯消费 API：扫描后弹出刚写入的缓存项，调用方得到每个词素一次；`Prefetch()` 行为不变（与 Go main.go 一致）。README 已登记 |
| 5 | `RenderVisible` 恒等 | 当前测试不依赖 LF 可见转义；保持 API 契约 |
| 6 | 关键字/分隔符表用列表字面量直接构造 | 大列表字面量曾指数级恶化（2026-11-12 复测全部正常，0.4s 完成）；分隔符表 Tab/LF/CR 三个控制字节无可写字面量，占位后回写，见 #8 |
| 7 | 切点：`byte` 与 `u8` 不互通 | `var b: byte = 65` 报错；需要 `unsafe.cast[byte]` |
| 8 | 字符分类活已迁入 std:strings | `isDigit`/`isSpaceByte`/`isIntDigit`/`fromByte` 统一走 std:strings；Token 构造改用 struct 字面量（`T{...}`） |
| 9 | 空白仅空格/Tab 才被跳过 | 与 Go `SkipSep` 一致；Tab/LF/CR（`0x09/0x0A/0x0D`）在 delimTable 中是 DELIMITER，**LF/CR 必须保留在 token 流中**（语句终结符语义）；早期实现误把 LF 当空白跳过，换行 token 丢失 |
| 10 | EOF 尾部词素单独补发 | Go 参考在主循环按 delimiter 切分词素，主循环因 EOF 退出时末尾词素会丢；Prefix 后置分支单独补发（主循环结束后 `i > pfPos` 兜底） |
| 11 | 进制前缀无有效数字时退回整词 NAME | 与 Go `scanNumber` digits==0 行为一致：`0b2` → `NAME|0b2`、`0x` → `NAME|0x` |
| 12 | EOF token 的 Value 恒为显式空串 | `*Token = Token{...}` 结构字面量缺省字段不保证零填充（历史事故），NONE token 显式写 `Value: ""` |
| 13 | `int` ↔ `f64` 比较没有隐式提升 | `t.Number != 42` 比较的是位模式，一律用 `42.0` 字面量（`docs/LANGUAGE.md` §10.3/§5.4） |

## 已知限制 / 与下游的衔接

- **`../cmd/tokdump` 与本移植未对接**：driver 仍按旧 token 模型（`FUNC/PROCESSCONTROL/...` 14 枚举）编写；
- **Go 侧 `lexer/` 也是旧 14 枚举模型**：`tools/gotokens` 的 `selfhost_parity.sh` 对拍口径与本移植不一致；
  S1/S2/S3 验收口径暂时停用，S0 自举验收以 `scripts/selfhost_test.sh` 为准；
  下游（parse/parsedump/tokdump、Go 侧 `lexer/`）统一到 6 枚举模型留待后续阶段；
- 仅 x86_64 验证；x86-32 侧泛型/字宽面未启用；
- 按字节扫描，不处理 Unicode（非 ASCII 字节进入 `NAME`）；
- 词法错误直接 `panic`（与 Go 参考一致）；`Lexer.Err` 字段与 `Error` 类型保留用于下游上报，
  当前实现不写入；
- 分隔符表静态构造（`[]string{...}` + Tab/LF/CR 三处 `strings.fromByte(N)` 回写）；多行字面量不支持（换行是语句终结符），表必须写在单条语句里；
