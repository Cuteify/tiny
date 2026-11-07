# parsedump —— 自举 parser driver（S2/S3）

从 **stdin** 读入 Cute 源码，交给 `selfhost/parse` 解析。默认输出 S2 结构计数；
设置 `PARSEDUMP_AST=1` 时输出 S3 canonical AST。driver 只负责输入/输出、行列换算与
AST 文本渲染，parser 本身仍只接收 `string`。

- 输入：stdin 上的源码文本，上限 1 MiB（超出部分截断）。
- 默认成功输出（一行）：

```
PARSE_OK|decls=N|imports=N|builds=N|enums=N|structs=N|consts=N|vars=N|fns=N|stmts=N|exprs=N
```

- `PARSEDUMP_AST=1` 成功输出：canonical AST 文本（2 空格缩进、`KIND key=value`），
  与 `tools/astdump` 逐字节一致，末尾以换行结束。
- 失败输出（一行）：

```
PARSE_ERROR|code=N|at=line:col|byte=offset
```

`line:col` 为 1-based；行号按 LF 递增。`byte` 是 parser 给出的字节偏移。
失败退出码为 1，成功为 0。

错误码含义、计数口径、AST 节点种类与折叠规则见 [`../../parse/README.md`](../../parse/README.md)。

## 构建与运行

仓库根目录执行（推荐用脚本，自动在临时目录编译，不污染工作区）：

```bash
TMPDIR=/tmp/opencode go build -o /tmp/opencode/bin/selfhostc .

# parser 自测 + 固定语料
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_parse.sh x86_64

# S3 canonical AST 对拍（自动构建 astdump 与 parsedump）
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_ast_parity.sh x86_64

# 指定一个或多个源码文件
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_parse.sh x86_64 path/to/file.cute
```

手动运行等价于：

```bash
WORK=/tmp/opencode/parsedump-run
rm -rf "$WORK" && mkdir -p "$WORK/selfhost"
cp -a selfhost "$WORK/selfhost"
cd "$WORK/selfhost/cmd/parsedump"
CUTE_ROOT=/home/gx/Desktop/代码/tiny CUTE_ARCH=x86_64 /tmp/opencode/bin/selfhostc "$PWD"
nasm -f elf64 -w-label-redef-late _main.asm -o _main.o
gcc -nostartfiles -no-pie -e _start _main.o -o parsedump -lpthread
./parsedump < /home/gx/Desktop/代码/tiny/selfhost/lex/lex.cute
```

## 输出示例

```text
$ ./parsedump < selfhost/parse/test/main.cute
PARSE_OK|decls=14|imports=3|builds=0|enums=0|structs=0|consts=0|vars=19|fns=11|stmts=237|exprs=641
```

```text
$ printf 'fn f() {\n    ret 1 +\n}\n' | ./parsedump
PARSE_ERROR|code=5|at=3:1|byte=21
```

AST 模式：

```text
$ PARSEDUMP_AST=1 ./parsedump < selfhost/parse/test/ast/fold.cute | head -5
FILE
  FN name=fold
    RET type=int
    VAR name=a flags=di
      LIT -1
```

## 限制

- 默认模式只做语法验证与结构计数；AST 模式只对齐 Go parser 可观察的节点形状，
  两种模式都不做类型检查或代码生成。
- 浮点字面量保留源码文本、浮点算术不折叠；大整数常量超过 `int64` 时溢出。
  这些与 Go 侧的差异登记在 [`../../parse/README.md`](../../parse/README.md)。
- 输入上限 1 MiB；只用于源码冒烟，不是通用文件工具。
- 不读文件名/路径；错误只给字节偏移与行列号，文件名由宿主补。
- 只支持 x86_64 作为当前验收目标；x86 后端在 Batch 4 前仍有已知 NASM 红面。
- 词法错误与语法错误共用一份错误码空间，`ETOK` 表示 lexer 报错。
