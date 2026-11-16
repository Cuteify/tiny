# 自举 Parser 重写计划（S4：自举侧实现 Block 接口，照 Go 参考形态）

> 状态：**设计冻结** — 方案由用户拍板（节点/接口对齐 Go；selfhost 侧落地，不动 Go 版本）。
> 目标：把自举 parser 做成**能编译、能跑、能对拍**的实体效果（去 cuteify2 全测通过 `.want`）。
> 关联：`docs/SELFHOST.md`（总计划）、`docs/LANGUAGE.md`（语言能力）、`docs/CUTE_ABI.md`（ABI）。

## 1. 范围与非目标

### 1.1 范围

- 新 parser 内容全在 `selfhost/parse/parse.cute`（同名替换停用中的旧文件）。
- 词法输入 = `selfhost/lexer`；**必须用 `lexer.Prefetch` 做语句/表达式分支决策**
  （先窥 token 再按 tag 派发，避免在分支内重复扫）。
- parser 导出的 AST 类型与 Go 参考**同形**：`Node{Value Block, Father *Node, Children []*Node}`、
  `Block = interface{...}`（selfhost 用 Go 参考同名同形 interface）。
- user-facing API 兼容 `selfhost/parse/parse.cute` 旧形态（`mk`、`file`、`err`、`errPos`、
  `declKindCounting`、……对拍所需的最小 API），便于 `scripts/selfhost_parse.sh` 沿用语料。
- 方法形态：`fn Type.name(self|&self, args...) ret { ... }`，接收者类型由 `Type.` 前缀推断；`self` = 值接收者，`&self` = `*Type` 指针接收者。
- 方法调用：`value.method(args)` 或 `ptr.method(args)`；成员方法不静态派发（保持 member dispatch），无 `self` 的静态方法用 `Cls.method(args)`。
- 接口方法声明 **不写 receiver**（`m() X`）。
- 成员 dispatch 对 `obj.m(args)` 中的 `obj` 求值；无 receiver 方法则丢弃 obj 的值。
- 12+ block 种类全实现：`Arg, Break, Call, Case, Cont, Defer, Else, Func, If, Import, Return, Struct, Switch, Type, Var`
  （`Fallthrough` 为 NoOp，仅在 Switch 内处理）。
- 结构体/枚举/类型/常量/import/build 全部解析；类型引用（限定/裸/指针/列表/基础）并全量还原。

### 1.2 非目标

- **不修改** Go 版本 parser（`parser/*.go`）或 Go 版本 lexer（本阶段不动）。
- 不做完整语义 **Check**；`Type int` 只保留对拍必需的最小信息。
- 不做 code generation / assembler 输出 / 自举编译。
- 不做 `build` 标签语义（`os/arch/bits` 仅识别语法，不执行过滤）。

## 2. 交付形态（每一阶段独立 commit，保证 `git bisect` 干净）

### M0：`Block interface` 骨架 + 类型声明解析 + `file()` 主循环

能编译、能跑空语料、能识别空顶层声明：
`selfhost/parse/test/main.cute` 返回 42。

- `Block interface { Size(x *Parser) int }`（selfhost 侧最小 interface，Method: Size/tag/…，具体见 §4）
- 10 个 Block（`ArgBlock / FuncBlock / TypeBlock / VarBlock / IfBlock / ElseBlock / ForBlock / SwitchBlock / CaseBlock / ImportBlock`）
  全部 `type … Block struct {...}` 落界；每个有对应 `Node{Value: Block, Father: *Node, Children: []*Node}`。
- 树节点 = `Node`（payload = `Block interface`），`Kind()` 按 `Block` 类型返回枚举常量；`Father`/`Children` 走 `*Node`。
- `file(x *Parser)`：文件 → 顶层声明（import / build / fn / type / var / const / struct / enum）分发。
- 语法错误 `fail(x, code int, pos uint)`；首个错误不覆盖后续。
- 接口 **仅**为 selfhost 本地使用；不导出到外部测试，不依赖 `go interface`。

### M1：顶层声明完成

`parseDecl` 完整分派 `fn / type / var / const / import / build / struct / enum`；
`type ( ... )` 分组语法完整支持；`build` 识别 + 暂存 PendingBuilds；empty fn/struct/interface 能跑通。

- 验收：`test/main.cute` 的正负例（fn/struct/interface/type/var/const/import/build）PARSE_OK。
- 语料：本仓库 `pkg/*/test/*.cute`、`selfhost/*/*.cute`、`test/*/main.cute` 的 Parse 皆成功。

### M2：语句/表达式

`if / else / for / switch / break / continue / defer / fallthrough / ret / var / assign / call`
全部落地；算术/比较/逻辑/位移/索引/限定路径表达式；操作符优先级链按 Go 参考；多值赋值（`a, b := f()`）支持。

- 验收：`test/main.cute` 全部正负例 OK；语料对拍（`scripts/selfhost_parse.sh`）sub-set PASS。

### M3：AST 对拍

`selfhost_ast_parity.sh` 恢复为可用状态，`test/ast/*.cute` 全部 PARITY_OK（或人工 pin 接受差异，登记进 §5）。

## 3. lexer.Prefetch 工作流

旧 parser（S2/S3）环扫时（`for x.k == lex.DELIMITER {...}` 形式）每次多读/退格都直接推 lexical 缓冲；现在直接：

1. `Parser` 持有 `l: *lex.Lexer`；读 1 token = `x.k = lex.next(x.l)`（`lex.Next()`）。
2. 分支用 `if at(x, "fn")...`，语法上**相当于**预读 1 token。
3. **需要看 2 token 的情形**（`var a b = 1` / `x.a: T = f()` / `[](...)`）使用 `lex.Prefetch(x.l, 1)`，
   与 `lex.SetCursor(x.l, saved)` 组合（见 §4.6）。
4. 其余路径尽量不读到 parser；不要再写 bytewalker。

旧 parser 里的 `take` / `rollback` 模式全部改掉；自举 lexer 没有 cursor 退格，
只看 `Prefetch` / `SetCursor` 算好的 saved。

## 4. 新 parser 结构（设计与先前文档一致）

### 4.1 Block interface 与 Node

```cuteify
// 最小 Block interface：每个声明/语句/表达式成员为 *{Block}。
type Block interface {
    Tag() (int, string)           // (枚举号, 可读的名字串)
    Dump(x *Parser, n *Node)      // 可选：写 n 的 AST 字符串（供 astdump 对拍）
}

type Node struct {
    Val     Block
    Father  *Node
    Children []*Node
}
```

自举 `Block interface` 方法分发是真实接口派发（this session 复现的路径）；
若 cuteify compiler 生成慢，回退为 `switch v := n.Val.(type)` 手写——性能优先后者，
接口派发是为了自举的代码可读性与跨包友好。

### 4.2 token 层

```cuteify
fn atKeyword(x *Parser, s string) bool {
    // 前提：x.k 为 KEYWORD；否则按 Go 参考返回 false
    ret x.k == lex.KEYWORD && strings.eq(lex.tval(x.l, x.a, x.b), s)
}
fn atDelim(x *Parser, s string) bool {
    ret x.k == lex.DELIMITER && strings.eq(lex.tval(x.l, x.a, x.b), s)
}
fn atName(x *Parser) bool { ret x.k == lex.NAME }
fn isNewlineTok(x *Parser) bool { /* LF/CR DELIMITER */ }
fn atEOF(x *Parser) bool         { /* x.k == lex.NONE */ }

fn skipNL(x *Parser) { for isNewlineTok(x) { bump(x) } }
fn skipSep(x *Parser) { for isNewlineTok(x) || at(x, ";") { bump(x) } }

fn peek(x *Parser, offset int) lex.Token  // Prefetch 读 offset 个 token 到缓冲
fn bump(x *Parser)                 // 前进 1 token
```

### 4.3 错误码（与旧 S2 兼容）

```text
0  = OK    1 = ETOK（词法错）  2 = EDECL（decl 错）
3  = ETYPE（type 错）        4 = ESTMT（stmt 错）   5 = EEXPR（expr 错）
```

错误被写入 `x.e` / `x.ep`（首个不覆盖）；一次 error 后 `file()` 立即停止（`fail()` 赋值 + 调出）。

### 4.4 计数口径（保持与旧 S2/S3 对拍）

Parser 打印/返回:
`decls / imports / builds / enums / structs / consts / vars / fns / stmts / exprs`。
按旧 `selfhost/parse/test/main.cute` 中约定；全部保留后跑 `PARSE_OK` 恢复。

### 4.5 方法接收者

方法接收者 = 第一个参数，命名为 `self`（值 receiver）或 `&self`（指针 receiver），类型由方法名前缀推断：

```cute
fn Counter.increment(&self) { ... }   // receiver = *Counter，方法内改动调用方可见
fn Counter.get(self) int { ... }      // receiver = Counter，按值复制
```

**不写 receiver** = 无 receiver 静态方法（省一次 receiver 传递；调用 `c.increment()` 时 obj 被求值后丢弃）。
接口 `Counter interface { increment() }` 的实现不关心接收者 `self` / `&self` / 无 receiver 哪种形态，只要签名匹配。

### 4.6 Peek / SetCursor（需求 >1 token 的决策）

```cuteify
fn peek2(x *Parser) (lex.KW, string) {
    // 保存当前，预读下一个，比较类型；恢复缓冲到原位
    saved := x.k; saveC := x.a; saveE := x.b
    nx := lex.Next()
    lex.SetCursor(x.l, savedC)
    ret saved, nx.Value
}
```

`var a b = 1` → `nx.Type == NAME`（`b` 是类型）；`x.a: T = f()` → `nx == DELIMITER ":"`。
tag 大部分路径不需要 peek2。

### 4.7 Go reference 对照表

| Go 参考输入 | 自举等价 | 判别 |
|---|---|---|
| `lexer.FUNC`     | `lex.KEYWORD == "fn"`   | `atKeyword(x, "fn")` |
| `lexer.TYPE`     | `lex.KEYWORD == "type"` | `atKeyword(x, "type")` |
| `lexer.VAR`      | `lex.KEYWORD == "var"`  | `atKeyword(x, "var")` |
| `lexer.IMPORT`   | `lex.KEYWORD == "import"` | `atKeyword(x, "import")` |
| `lexer.BUILD`    | `lex.KEYWORD == "build"` | `atKeyword(x, "build")` |
| `lexer.PROCESSCONTROL` | 多种关键字 | `atKeyword(x, "if") / …` |
| `lexer.NAME`     | `lex.NAME`              | `atName(x)` |
| `lexer.NUMBER`   | `lex.NUMBER`            | `x.k == lex.NUMBER` |
| `lexer.STRING`   | `lex.STRING`            | `x.k == lex.STRING` |
| `Separator "\n"` | `lex.DELIMITER == "\\n"` | `isNewlineTok(x)` |
| `Separator ";"`  | `lex.DELIMITER == ";"`  | `atDelim(x, ";")` |
| `Separator "}"`  | `lex.DELIMITER == "}"`  | `atDelim(x, "}")` |
| `Separator "("`  | `lex.DELIMITER == "("`  | `atDelim(x, "(")` |

## 5. 已知差异（自举 vs Go 参考）

1. 新 `lexer` 只有 `KEYWORD/DELIMITER/NAME/NONE/STRING/NUMBER` 六种标记，关键字列表沿用。
2. `build` 标签仅识别、不语义过滤，BuildIgnored 节点保留在 AST（Go 相同行为）。
3. 常量折叠（ConstFold）延后实现（见 M3），差不影响使用方对拍。
4. 接口具名接收者 / 接口嵌入接口——`selfhost/parse` 侧暂不支持（字面量过滤），待端到端现象后恢复。
5. 枚举 `enum Test { A, B }` 通过 TypeBlock 的 "kind=enum" 属性承载，没有独立 EnumBlock。

## 6. 测试与对拍

- **M0/M1**：`selfhost/parse/test/main.cute`
  ```
  $ TMPDIR=/tmp/opencode go build -o /tmp/opencode/bin/cuteify2 . && \
    flock /tmp/opencode/lock /tmp/opencode/bin/cuteify2 selfhost/parse && \
    flock /tmp/opencode/lock selfhost/parse/test/main selfhost/parse/test/main.cute
  ```
  预期 `RC=42`。
- **性能**：同语料 Go/parser vs selfhost/parse → AST dump 对拍（见 `scripts/selfhost_ast_parity.sh`，M3）。
- **回归**：`scripts/selfhost_parse.sh`（复用旧语料，输出 `PARSE_OK`/`PARSE_ERROR(...)`）；
  `scripts/selfhost_ast_parity.sh`（恢复时用）。
- **矩阵**：`scripts/stdlib_matrix.sh x86_64 1`（本轮 Stage 修复后应保持 `22 项矩阵与基线一致`）。
- **自举测试**：`scripts/selfhost_test.sh x86_64`（S0 已有，本阶段不动）。

## 7. 与 Go 参考源文件映射

| Go 参考（`parser/*.go`） | 自举落地 | 说明 |
|---|---|---|
| parser.go（主循环 + processNext + handleEmptyToken + isScopeBlock） | 同名 `file()`、`next()`、`handleEmptyToken()` | 入口完全一致 |
| import.go | `parseImport()` | 去 `_fake` / `bang_build` 模式；只 parse import 路径+别名 |
| build.go | `parseBuild()` + `PendingBuilds` queue | OS/ARCH/BITS 仅语法 |
| enum.go | `processEnumToken()` | 只走 TypeBlock"kind=enum"路径 |
| struct.go | `parseStruct() / processStructToken()` | 含 `type ( )` 分组 |
| interface.go | `parseInterfaceMethods()` — `{ fn Name(Args raw) }` | 同 Go 形状，加上枚举 kind 属性 |
| paren.go / call.go / token.go | `parseArgList / parseLiteralArgs / parseArgs` | 共同语义 |
| exp.go | `parseExpression / parseBinary / parsePrimary / parseIndexOrSlice / parseCallGeneric` | 优先级 `||1 / &&2 / ==!=3 / rel4 / |5 / ^6 / &7 / shift9 / +−10 / */%11` |
| ifelse.go / for.go / switch.go / fallthrough.go / break.go / continue.go / defer.go / return.go | 各语句解析器 | 按 Go 参考形状/重命名保持对称 |

## 8. 验收门票与回滚方案

- 每一条 commit 必须：`go build` OK + `selfhost/parse/test/main.cute` 调用 RC=42 + 旧 `.want` 语料对拍一致（如存在）。
- 如归因未完：暂停接受 PR/直拨；不分 merge，直接 `git reset --hard` 恢复到最近的绿树。
- 不动 `scripts/*.sh`，只保留 `selfhost/test.sh` 和 `stdlib_matrix.sh` 用途；AST 对拍恢复时再开口 `selfhost_ast_parity.sh`。
- 不 push。
