# tokdump —— 自举 token 流 driver（S1）

把 `selfhost/lex` 扫描出的 token 序列打印出来，用于 S1 阶段冒烟与诊断。

- 输入：**stdin** 上的源码文本（driver 负责读入，lexer 本身仍只接收 `string`）。
- 输出：一行一个 token：

```
line:col  TYPE  [text]  [start,end)
```

- `line:col`：1-based 行列号；行号按 LF 递增。
- `TYPE`：`tname(k)`，与 Go 版 `TokenType.String()` 一致。
- `text`：token 文本；字符串/字符/裸串不含定界符。换行、回车、制表渲染为
  `\n`、`\r`、`\t`，避免破坏一行一 token 的格式。
- `[start,end)`：字节偏移区间，与 `lex.start/end` 一致。
- 最后一行固定为 `EOF line:col  tokens=N`。
- 词法错误输出 `ERROR code at line:col` 并返回 1；正常结束返回 0。

## 构建与运行

仓库根目录执行（推荐用脚本，自动在临时目录编译，不污染工作区）：

```bash
TMPDIR=/tmp/opencode go build -o /tmp/opencode/bin/selfhostc .

# 默认对 selfhost/lex/lex.cute 自身做冒烟
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_dump.sh x86_64

# 指定源码
BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_dump.sh x86_64 path/to/file.cute
```

手动运行等价于：

```bash
WORK=/tmp/opencode/tokdump-run
rm -rf "$WORK" && mkdir -p "$WORK/selfhost"
cp -a selfhost/lex "$WORK/selfhost/lex"
cp -a selfhost/cmd "$WORK/selfhost/cmd"
cd "$WORK/selfhost/cmd/tokdump"
CUTE_ROOT=/home/gx/Desktop/代码/tiny CUTE_ARCH=x86_64 /tmp/opencode/bin/selfhostc "$PWD"
nasm -f elf64 -w-label-redef-late _main.asm -o _main.o
gcc -nostartfiles -no-pie -e _start _main.o -o tokdump -lpthread
./tokdump < /home/gx/Desktop/代码/tiny/selfhost/lex/lex.cute
```

## 限制

- 输入上限 1 MiB（超出部分截断）；只用于源码冒烟，不是通用文件工具。
- 只支持 x86_64；x86 后端在 Batch 4 前仍有已知 NASM 红面。
- 不读文件名/路径，错误只给字节偏移与行列号；文件 I/O 由宿主负责。
- 无 token 缓冲/回退；parser 需要回退时保存 `pos` 后重新 `mk`，或后续增加 seek/peek。
