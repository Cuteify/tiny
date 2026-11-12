#!/usr/bin/env bash
# stdlib 包级测试矩阵：编译 → NASM → 链接 → 运行，逐目录输出结果。
#
# 用法（仓库根目录或任意位置）：
#   scripts/stdlib_matrix.sh <x86_64|x86> [run-count]
#   BIN=/path/to/cuteify2 scripts/stdlib_matrix.sh x86_64 3
#
# 说明：
#   - 每个 pkg/**/test 会先复制到临时目录再编译，避免编译器把
#     gc_summary.json / gc_llr.txt 写回工作区；
#   - 结果行格式：<目录>|<COMPILE_FAIL|NASM_FAIL|LINK_FAIL|RC=n>|详情；
#   - 多轮运行时，只有各轮 rc 一致才输出 RC=n，否则输出 RC=a/b。
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd) || exit 1
BIN=${BIN:-$ROOT/cuteify2}
ARCH=${1:-}
RUNS=${2:-1}

if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "x86" ]; then
    echo "用法: $0 <x86_64|x86> [run-count]" >&2
    exit 2
fi
if [ ! -x "$BIN" ]; then
    echo "编译器不存在或不可执行: $BIN（先 go build -o cuteify2 . 或设置 BIN=）" >&2
    exit 2
fi

WORK=${WORK:-/tmp/opencode/stdlib-matrix-$ARCH}
rm -rf "$WORK"
mkdir -p "$WORK/cases"
cd "$WORK" || exit 1

if [ "$ARCH" = "x86_64" ]; then
    fmt=elf64
    gccargs=""
    out="$WORK/main64"
else
    fmt=elf32
    gccargs="-m32"
    out="$WORK/main32"
fi

for d in $(cd "$ROOT" && find pkg -type d -name test | sort); do
    name=$(echo "$d" | tr '/' '_')
    case_dir="$WORK/cases/$name"
    mkdir -p "$case_dir"
    cp -a "$ROOT/$d/." "$case_dir/"

    final=""
    for i in $(seq 1 "$RUNS"); do
        rm -f "$case_dir/_main.asm"
        log="$WORK/$name.compile.$i.log"
        if ! ( cd "$case_dir" && CUTE_ROOT="$ROOT" CUTE_ARCH="$ARCH" timeout 60 \
            "$BIN" "$case_dir" ) >"$log" 2>&1; then
            msg=$(sed 's/\x1b\[[0-9;]*m//g' "$log" | grep -m1 -E "Type Error|Syntax Error|Call Error|panic:|Error:" | tr '|' ' ' | cut -c1-160)
            final="COMPILE_FAIL|$msg"
            break
        fi
        if [ ! -f "$case_dir/_main.asm" ]; then
            final="COMPILE_FAIL|missing _main.asm"
            break
        fi
        if ! nasm -f "$fmt" -w-label-redef-late -o "$out.o" "$case_dir/_main.asm" >"$WORK/nasm.log" 2>&1; then
            final="NASM_FAIL|$(tail -1 "$WORK/nasm.log" | tr '|' ' ')"
            break
        fi
        if ! gcc $gccargs -nostartfiles -s -Wl,--build-id=none,--gc-sections -no-pie -e _start -o "$out" "$out.o" -nostdlib >"$WORK/link.log" 2>&1; then
            final="LINK_FAIL|$(tail -1 "$WORK/link.log" | tr '|' ' ')"
            break
        fi
        timeout 30 "$out" >/dev/null 2>&1
        rc=$?
        if [ -z "$final" ]; then
            final="RC=$rc"
        elif [ "$final" != "RC=$rc" ]; then
            final="$final/RC=$rc"
        fi
    done
    echo "$d|$final"
done
