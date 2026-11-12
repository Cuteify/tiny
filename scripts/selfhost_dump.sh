#!/usr/bin/env bash
# 自举 token 流 driver（S1）：编译 selfhost/cmd/tokdump，读取源码并打印 token 序列。
#
# 用法（仓库根目录）：
#   BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_dump.sh [x86_64|x86] [source-file]
#
# 默认 arch=x86_64，默认 source-file=selfhost/lexer/lexer.cute。
# 成功标志：最后一行 `EOF line:col  tokens=N`，退出码 0。
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd) || exit 1
BIN=${BIN:-$ROOT/cuteify2}
ARCH=${1:-x86_64}
SRC=${2:-$ROOT/selfhost/lexer/lexer.cute}

if [ ! -f "$SRC" ]; then
    echo "源码不存在: $SRC" >&2
    exit 2
fi
SRC=$(realpath "$SRC") || exit 2

if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "x86" ]; then
    echo "用法: $0 [x86_64|x86] [source-file]" >&2
    exit 2
fi
if [ ! -x "$BIN" ]; then
    echo "编译器不存在或不可执行: $BIN（先 go build -o /tmp/opencode/bin/selfhostc . 或设置 BIN=）" >&2
    exit 2
fi

if [ "$ARCH" = "x86_64" ]; then
    fmt=elf64
    gccargs=""
else
    fmt=elf32
    gccargs="-m32"
fi

# 串行化复制/编译/汇编/链接，避免与同机的其它 e2e 任务争用临时文件。
exec 9>/tmp/opencode/lock
flock 9

WORK=${WORK:-/tmp/opencode/selfhost-dump-$ARCH}
rm -rf "$WORK"
mkdir -p "$WORK/selfhost"
cp -a "$ROOT/selfhost/lexer" "$WORK/selfhost/lexer"
cp -a "$ROOT/selfhost/cmd" "$WORK/selfhost/cmd"
cd "$WORK/selfhost/cmd/tokdump" || exit 1

log="$WORK/compile.log"
if ! CUTE_ROOT="$ROOT" CUTE_ARCH="$ARCH" "$BIN" "$PWD" >"$log" 2>&1; then
    echo "SELFHOST_DUMP_FAIL|COMPILE"
    tail -20 "$log"
    exit 1
fi

if ! nasm -f "$fmt" -w-label-redef-late -o "$WORK/main.o" _main.asm >"$WORK/nasm.log" 2>&1; then
    echo "SELFHOST_DUMP_FAIL|NASM"
    tail -10 "$WORK/nasm.log"
    exit 1
fi

# shellcheck disable=SC2086
if ! gcc $gccargs -nostartfiles -s -Wl,--build-id=none,--gc-sections -no-pie -e _start -o "$WORK/tokdump" "$WORK/main.o" -nostdlib >"$WORK/link.log" 2>&1; then
    echo "SELFHOST_DUMP_FAIL|LINK"
    tail -10 "$WORK/link.log"
    exit 1
fi

(ulimit -Sc 0; timeout 60 "$WORK/tokdump" < "$SRC" >"$WORK/tokens.txt")
rc=$?
cat "$WORK/tokens.txt"

if [ "$rc" -ne 0 ]; then
    echo "SELFHOST_DUMP_FAIL|RC=$rc"
    exit 1
fi
if ! tail -n 1 "$WORK/tokens.txt" | grep -q '^EOF '; then
    echo "SELFHOST_DUMP_FAIL|missing EOF"
    exit 1
fi
count=$(tail -n 1 "$WORK/tokens.txt" | sed -n 's/^EOF .*tokens=\([0-9][0-9]*\)$/\1/p')
if [ -z "$count" ] || [ "$count" -le 0 ]; then
    echo "SELFHOST_DUMP_FAIL|bad token count"
    exit 1
fi
if grep -q '^ERROR ' "$WORK/tokens.txt"; then
    echo "SELFHOST_DUMP_FAIL|lex error"
    exit 1
fi

# 默认输入必须真的覆盖到 lexer 自身的关键 token。
if [ "$SRC" = "$ROOT/selfhost/lexer/lexer.cute" ]; then
    if ! grep -qF 'IMPORT  [import]' "$WORK/tokens.txt"; then
        echo "SELFHOST_DUMP_FAIL|missing IMPORT token"
        exit 1
    fi
    if ! grep -qF 'TYPE  [enum]' "$WORK/tokens.txt"; then
        echo "SELFHOST_DUMP_FAIL|missing TYPE enum token"
        exit 1
    fi
fi

echo "SELFHOST_DUMP_OK|$ARCH|tokens=$count"
