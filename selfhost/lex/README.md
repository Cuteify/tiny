# lex —— Cuteify 自举词法分析器

`selfhost/lex` 是 `lexer/`（Go 版）的 Cute 移植，第一阶段只做词法分析。
输入是一段源码 `string`，输出 token 类型、token 文本和字节区间；不读文件、不建 AST。

- 实现：`lex.cute`
- 包名：`lex`
- 测试：`test/main.cute`（通过返回 `42`）
- S1 token 流 driver：`../cmd/tokdump/`（stdin → token 行）
- 外层总览：`../README.md`

## 快速开始

```cute
import "std:strings"
import lex "../"

fn main() int {
    var l: *lex.Lex = lex.mk("fn main() {}")

    for ; true; {
        var k: int = lex.next(l)
        if k == lex.NONE {
            break
        }
        if lex.err(l) != lex.OK {
            // token 可能只扫描到一半，按错误处理并停止
            ret lex.err(l)
        }
        // lex.text(l) 是 token 文本；lex.start(l)/lex.end(l) 是字节区间
        if k == lex.FUNC {
            if !strings.eq(lex.text(l), "fn") {
                ret 1
            }
        }
    }
    ret 42
}
```

## API

| 函数 | 签名 | 作用 |
|---|---|---|
| `mk` | `fn mk(s string) *Lex` | 基于源码字符串创建词法状态；不复制源码 |
| `next` | `fn next(l *Lex) TokenType` | 扫描下一个 token，返回 token 类型；EOF 返回 `NONE` |
| `text` | `fn text(l *Lex) string` | 最近 token 的文本；字符串/字符/裸串不含定界符 |
| `kind` | `fn kind(l *Lex) TokenType` | 最近 token 的类型（与 `next` 返回值相同） |
| `err` | `fn err(l *Lex) int` | 最近一次 `next` 的错误码；`OK` 表示无错误 |
| `start` | `fn start(l *Lex) uint` | 最近 token 的起始字节偏移（含） |
| `end` | `fn end(l *Lex) uint` | 最近 token 的结束字节偏移（不含） |
| `pos` | `fn pos(l *Lex) uint` | 当前扫描游标（下一个待读字节） |
| `tname` | `fn tname(k TokenType) string` | token 类型名，与 Go 版 `TokenTypeName` 一致；覆盖全部 14 个枚举值，未知值返回 `""` |

内部辅助函数 `bt`、`skip`、`dig`、`hex`、`oct`、`bin`、`sep`、`num`、`name`、`kw`、
`str`、`chr`、`raw`、`comment` 也放在包内，但不建议外部依赖。

### 调用约定

- `next()` 每次调用开头把 `err` 重置为 `OK`。
- 正常 EOF：`next()` 返回 `NONE`，`err()` 为 `OK`，`text()` 为空串。
- 词法错误：`next()` 仍可能返回一个类型（例如未闭合字符串返回 `STRING`），但
  `err()` 非 `OK`；调用方应丢弃该 token 并停止。
- `next()` 返回 `NONE` 且 `err() != OK` 也表示错误，不要当成 EOF。
- 空白：空格和 Tab 在 token 起始处跳过；换行 `\n`/`\r` 作为 `SEPARATOR` 返回。
- 所有偏移都是**字节偏移**，不是 Unicode 字符下标。

## Token 枚举

编号与 Go 版 `lexer/keywords.go` 完全一致。Go 侧现在是现代枚举写法：
`type TokenType int` + `const (... = iota)`，并提供 `TokenType.String()` 与
`TokenTypeName(...)`；自举侧用 `enum TokenType { ... }` 声明，生成独立的命名类型，
成员自动从 0 自增且常量类型就是 `TokenType`。`Lex.k`、`next`、`kw`、`kind`、`tname`
全部使用该类型，名称、顺序、值与类型身份逐项对齐。

| 名称 | 值 | 含义 |
|---|---|---:|
| `NONE` | 0 | EOF / 空 token |
| `FUNC` | 1 | `fn` |
| `VAR` | 2 | `const` / `var` / `let` |
| `PROCESSCONTROL` | 3 | 流程控制关键字 |
| `SEPARATOR` | 4 | 分隔符、运算符、标点、换行 |
| `STRING` | 5 | 双引号字符串（文本不含引号） |
| `NUMBER` | 6 | 数字字面量 |
| `NAME` | 7 | 普通标识符 |
| `CHAR` | 8 | 单引号字符（文本不含引号） |
| `TYPE` | 9 | `type` / `struct` / `interface` / `enum` |
| `RAW` | 10 | 反引号裸字符串（文本不含反引号） |
| `BOOL` | 11 | `true` / `false` / `nil` |
| `BUILD` | 12 | `build` |
| `IMPORT` | 13 | `import` |

`tname(k)` 返回的字符串与上表左列一致，包括 `NONE` → `"NONE"`；未知值返回 `""`。
实现用 `switch` 覆盖全部 14 个值，与 Go 版 `TokenType.String()` 的分支一一对应；
`TokenTypeName` 只是 `String()` 的兼容入口。

## 关键字

| token 类型 | 关键字 |
|---|---|
| `FUNC` | `fn` |
| `VAR` | `const`、`var`、`let` |
| `PROCESSCONTROL` | `if`、`while`、`for`、`return`、`ret`、`break`、`continue`、`else`、`switch`、`case`、`default`、`range`、`defer`、`try`、`except`、`finally` |
| `TYPE` | `type`、`struct`、`interface`、`enum` |
| `BOOL` | `true`、`false`、`nil` |
| `BUILD` | `build` |
| `IMPORT` | `import` |

`self` 显式归为 `NAME`；其余未命中关键字表的单词都是 `NAME`。
关键字匹配是完整单词匹配：`ifx`、`if_x` 都是 `NAME`。

## 扫描规则

### 空白与换行

- token 起始处跳过空格（32）和 Tab（9）。
- 空格在词内也视为分隔符（与 Go 版 `GetWord` 一致）；Tab 不在分隔符表中，
  因此词内 Tab 会留在 `NAME` 里（与 Go 版一致的历史行为）。
- `\n`（10）和 `\r`（13）各自作为单字符 `SEPARATOR` 返回。
- CRLF 会连续产出 `\r`、`\n` 两个分隔符；注释扫描停在 `\r` 上，后续同样产出
  `\r`、`\n`。

### 分隔符（最长匹配 3 → 2 → 1）

三字符：

```
<<=  >>=  ...
```

二字符：

```
==  !=  <=  >=  ++  --  ->  &&  ||  <<  >>  :=
+=  -=  *=  /=  %=  ^=  &=  |=  //
```

单字符：

```
;  {  }  (  )  [  ]  ,  =  +  -  *  /  %  :  <  >  .
&  |  ^  !  ?  ~  "  '  \  @  \n  \r  `  空格
```

`"`、`'`、`` ` `` 虽然出现在分隔符表中，但会进入字符串/字符/裸串分支，不会作为普通
`SEPARATOR` 返回。`//` 进入注释分支，也不返回 token。

### 数字

在普通单词之前扫描，支持：

- 十进制：`0`、`42`、`1_000`
- 十六进制：`0xFF`、`0Xab_cd`
- 二进制：`0b1010_0101`
- 八进制：`0o755`
- 小数：`3.14`（`.` 后必须紧跟数字）
- 科学计数法：`1e10`、`2.5E-3`（`e/E` 后可选 `+/-`，必须至少一位数字）
- 数字之间可插入 `_`

边界行为与 Go 版一致：

| 输入 | 结果 |
|---|---|
| `1.` | `NUMBER "1"` + `SEPARATOR "."` |
| `1.foo` | `NUMBER "1"` + `SEPARATOR "."` + `NAME "foo"` |
| `123abc` | `NUMBER "123"` + `NAME "abc"` |
| `1e` | `NUMBER "1"` + `NAME "e"` |
| `1e+` | `NUMBER "1"` + `NAME "e"` + `SEPARATOR "+"` |
| `0x` | `NAME "0x"`（非法前缀整体退回单词扫描） |
| `0b2` | `NAME "0b2"` |
| `0o8` | `NAME "0o8"` |

### 字符串、字符、裸串

- 双引号字符串：不允许跨行；遇到 `\n`/`\r` 或 EOF 报 `ESTR`。
- 单引号字符：不允许跨行；遇到 `\n`/`\r` 或 EOF 报 `ESTR`。
  - 内容长度为 1 合法；
  - 内容为空报 `ECHAR`；
  - 内容长度 > 1 且不以反斜杠开头报 `ECHAR`；
  - 反斜杠开头不做长度校验（与 Go 版一致，转义合法性留给 parser）。
- 反引号裸串：允许跨行；遇到 EOF 报 `ERAW`。
- `text()` 返回的内容不含定界符；`start()` 指向内容首字节，`end()` 指向内容后一字节。
  例如 `"hello"` 的区间是 `[1, 6)`，`pos()` 为 7。

### 注释

- `//` 到行尾，注释本身不产出 token。
- 注释后如果有换行，下一个 token 是 `SEPARATOR "\n"` 或 `"\r"`。
- 注释直到 EOF 时，下一个 `next()` 直接返回 `NONE`。

## 错误码

| 名称 | 值 | 含义 |
|---|---:|---|
| `OK` | 0 | 无错误 |
| `ESTR` | 1 | 字符串/字符未闭合或跨行 |
| `ERAW` | 2 | 裸字符串未闭合 |
| `ECHAR` | 3 | 字符字面量长度非法（空字符或长度 >1 且非反斜杠开头） |

错误是**粘性的单次状态**：`next()` 开头重置，所以读到错误后下一次调用会恢复 `OK`；
但这不代表错误 token 可以继续参与解析。

## 测试覆盖

`test/main.cute` 按组覆盖：

1. 空输入与 EOF
2. 全部关键字（含 `enum`）+ `self`/下划线/字母数字标识符
3. 十进制/十六进制/二进制/八进制/小数/科学计数法/下划线
4. 数字边界（`1.`、`123abc`、`0x`、`1.foo`、`1e`、`1e+`、`0b2`）
5. 二字符/三字符分隔符最长匹配
6. 单字符分隔符、词内空格切分
7. 字符串/裸串/字符内容与区间
8. 未闭合字符串/字符/裸串、空字符、超长字符
9. 注释到行尾、注释到 EOF、整行注释
10. `kind/start/end/pos` 查询
11. 关键字最长匹配（`ifx` / `if_x`）
12. 复合表达式切分（`a<<=b...c`）
13. `tname` 全枚举名称与数值对齐（`NONE`..`IMPORT`，未知值不误映射）

测试里的换行源码用 `nl()` 在运行时构造：`memory.malloc(8)` 写入字节 10，再交给
`strings.makeString` 生成视图。原因是当前 Cute 字符串字面量不处理 `\n` 转义（源码
`"\n"` 是两个字符），而跨行裸串字面量在当前编译器里也不可靠。反斜杠字面量同理，
用裸串 `` `\` `` 表示单个反斜杠。区间辅助函数命名为 `span`，避免与 NASM 的 `at`
宏冲突。

运行方法与期望退出码见 `../README.md` 的“构建与测试”。期望 `RC=42`。

## 已知限制与后续

- lexer API 没有文件路径、行号/列号；错误只有字节区间。S1 `tokdump` driver
  已在上层按偏移补行列换算。
- 与 Go 版的归一化 token 序列由 `scripts/selfhost_parity.sh` 对拍；当前固定语料
  15 个文件、19160 tokens 逐字节一致。
- 没有 token 缓冲/回退 API；parser 若需要回退，可保存 `pos` 后重新 `mk`，或后续增加
  `seek`/`peek`。
- 没有 Unicode 标识符：按字节判断分隔符，非 ASCII 字节会进入 `NAME`，与 Go 版一致。
- `tname` 是 `switch`；token 类型很少，暂不做表驱动。
- Cute 的 `enum` 会生成独立命名类型（等价于 `type TokenType int`），成员常量带该类型；
  暂不支持 `TokenType.NONE` 作用域限定访问。
- 当前编译器对源码里的跨行裸字符串字面量支持不完整；测试用运行时构造的换行字符串
  拼接源码，lexer 自身的跨行裸串扫描已覆盖。
