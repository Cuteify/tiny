#!/usr/bin/env bash
# 自举 lexer 行为测试：编译 selfhost/lex/test，汇编、链接并检查退出码为 42。
#
# 用法（仓库根目录或任意位置）：
#   scripts/selfhost_test.sh [x86_64|x86]
#   BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_test.sh x86_64
#
# 说明：
#   - 源码先复制到临时目录，避免 _main.asm / gc_* 污染工作区；
#   - 默认编译器为仓库根的 cuteify2，可用 BIN 覆盖；
#   - 编译器参数是目录；测试目录内必须有 main.cute；
#   - 与其它 e2e/汇编任务共用 /tmp/opencode/lock 串行执行。
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd) || exit 1
BIN=${BIN:-$ROOT/cuteify2}
ARCH=${1:-x86_64}

if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "x86" ]; then
    echo "用法: $0 [x86_64|x86]" >&2
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

WORK=${WORK:-/tmp/opencode/selfhost-$ARCH}
rm -rf "$WORK"
mkdir -p "$WORK"
cp -a "$ROOT/selfhost/lex" "$WORK/lex"
cd "$WORK/lex/test" || exit 1

# 串行化编译器/汇编/链接，避免与同机的其它测试争用临时文件。
exec 9>/tmp/opencode/lock
flock 9

log="$WORK/compile.log"
# 必须传绝对目录：相对包路径会被压成 ".."，包内 start() 的标签
# 会退化成 _start，与 ELF 入口冲突。
if ! CUTE_ROOT="$ROOT" CUTE_ARCH="$ARCH" "$BIN" "$PWD" >"$log" 2>&1; then
    echo "SELFHOST_FAIL|COMPILE"
    tail -20 "$log"
    exit 1
fi
if [ ! -f _main.asm ]; then
    echo "SELFHOST_FAIL|missing _main.asm"
    tail -20 "$log"
    exit 1
fi

if ! nasm -f "$fmt" -w-label-redef-late -o "$WORK/main.o" _main.asm >"$WORK/nasm.log" 2>&1; then
    echo "SELFHOST_FAIL|NASM"
    tail -10 "$WORK/nasm.log"
    exit 1
fi

# shellcheck disable=SC2086
if ! gcc $gccargs -nostartfiles -no-pie -e _start -o "$WORK/main" "$WORK/main.o" -lpthread >"$WORK/link.log" 2>&1; then
    echo "SELFHOST_FAIL|LINK"
    tail -10 "$WORK/link.log"
    exit 1
fi

"$WORK/main"
rc=$?
if [ "$rc" -ne 42 ]; then
    echo "SELFHOST_FAIL|RC=$rc (expected 42, failure group is $((rc)))"
    exit 1
fi

echo "SELFHOST_OK|$ARCH|RC=$rc"
