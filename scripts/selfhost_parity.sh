#!/usr/bin/env bash
# Go/Cute lexer token 序列对拍：同一源码分别经 Go 版 lexer 与自举 tokdump，
# 逐行比较归一化输出（类型/文本/内容区间/行列号）。
#
# 用法（仓库根目录）：
#   BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_parity.sh [x86_64|x86] [file...]
#
# 默认 arch=x86_64；不给 file 时跑内置固定语料。每个文件一行 PARITY_OK，
# 全部一致时最后输出 SELFHOST_PARITY_OK。
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd) || exit 1
BIN=${BIN:-$ROOT/cuteify2}
ARCH=${1:-x86_64}
shift || true

DEFAULT_FILES="
selfhost/lexer/lexer.cute
selfhost/lexer/test/main.cute
selfhost/cmd/tokdump/main.cute
test/enum/main.cute
test/complexTest/main.cute
test/switch_test/main.cute
test/fullSyntaxTest/main.cute
test/frontendTest/main.cute
test/edgeValues/main.cute
test/esc_test/main.cute
test/rcSimple/main.cute
test/gcfree/main.cute
pkg/slices/test/main.cute
pkg/strings/test/main.cute
pkg/sort/test/main.cute
"

if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "x86" ]; then
    echo "用法: $0 [x86_64|x86] [file...]" >&2
    exit 2
fi
if [ ! -x "$BIN" ]; then
    echo "编译器不存在或不可执行: $BIN（先 go build -o /tmp/opencode/bin/selfhostc . 或设置 BIN=）" >&2
    exit 2
fi

if [ "$#" -gt 0 ]; then
    FILES="$*"
else
    FILES="$DEFAULT_FILES"
fi

if [ "$ARCH" = "x86_64" ]; then
    fmt=elf64
    gccargs=""
else
    fmt=elf32
    gccargs="-m32"
fi

# 串行化编译/汇编/链接，避免与其它 e2e 任务争用临时文件。
exec 9>/tmp/opencode/lock
flock 9

WORK=${WORK:-/tmp/opencode/selfhost-parity-$ARCH}
rm -rf "$WORK"
mkdir -p "$WORK/selfhost"
cp -a "$ROOT/selfhost/lexer" "$WORK/selfhost/lexer"
cp -a "$ROOT/selfhost/cmd" "$WORK/selfhost/cmd"
cd "$WORK/selfhost/cmd/tokdump" || exit 1

log="$WORK/compile.log"
if ! CUTE_ROOT="$ROOT" CUTE_ARCH="$ARCH" "$BIN" "$PWD" >"$log" 2>&1; then
    echo "SELFHOST_PARITY_FAIL|COMPILE"
    tail -20 "$log"
    exit 1
fi
if ! nasm -f "$fmt" -w-label-redef-late -o "$WORK/main.o" _main.asm >"$WORK/nasm.log" 2>&1; then
    echo "SELFHOST_PARITY_FAIL|NASM"
    tail -10 "$WORK/nasm.log"
    exit 1
fi
# shellcheck disable=SC2086
if ! gcc $gccargs -nostartfiles -s -Wl,--build-id=none,--gc-sections -no-pie -e _start -o "$WORK/tokdump" "$WORK/main.o" -nostdlib >"$WORK/link.log" 2>&1; then
    echo "SELFHOST_PARITY_FAIL|LINK"
    tail -10 "$WORK/link.log"
    exit 1
fi

cd "$ROOT" || exit 1
if ! TMPDIR=/tmp/opencode go build -o "$WORK/gotokens" ./tools/gotokens >"$WORK/gobuild.log" 2>&1; then
    echo "SELFHOST_PARITY_FAIL|GO_BUILD"
    tail -20 "$WORK/gobuild.log"
    exit 1
fi

ok=0
bad=0
total=0
for f in $FILES; do
    if [ ! -f "$f" ]; then
        echo "PARITY_SKIP|$f|missing"
        continue
    fi

    "$WORK/gotokens" "$f" >"$WORK/go.tok" 2>"$WORK/go.err"
    grc=$?
    (ulimit -Sc 0; timeout 60 "$WORK/tokdump" < "$f" >"$WORK/cute.tok" 2>"$WORK/cute.err")
    crc=$?

    if [ "$grc" -ne 0 ] || [ "$crc" -ne 0 ]; then
        echo "PARITY_FAIL|$f|go_rc=$grc|cute_rc=$crc"
        sed -n '1,5p' "$WORK/go.err"
        sed -n '1,5p' "$WORK/cute.err"
        bad=$((bad + 1))
        continue
    fi

    if ! diff -q "$WORK/go.tok" "$WORK/cute.tok" >/dev/null; then
        echo "PARITY_DIFF|$f"
        diff -u "$WORK/go.tok" "$WORK/cute.tok" | sed -n '1,30p'
        bad=$((bad + 1))
        continue
    fi

    count=$(tail -n 1 "$WORK/cute.tok" | sed -n 's/^EOF .*tokens=\([0-9][0-9]*\)$/\1/p')
    if [ -z "$count" ]; then
        echo "PARITY_FAIL|$f|bad token count"
        bad=$((bad + 1))
        continue
    fi
    echo "PARITY_OK|$f|tokens=$count"
    ok=$((ok + 1))
    total=$((total + count))
done

if [ "$ok" -eq 0 ]; then
    echo "SELFHOST_PARITY_FAIL|no input files"
    exit 1
fi
if [ "$bad" -ne 0 ]; then
    echo "SELFHOST_PARITY_FAIL|$ARCH|ok=$ok|bad=$bad"
    exit 1
fi
echo "SELFHOST_PARITY_OK|$ARCH|files=$ok|tokens=$total"
