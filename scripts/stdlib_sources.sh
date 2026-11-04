#!/usr/bin/env bash
# stdlib 源码级探针：对每个非测试包生成
#   import "std:<pkg>"
#   fn main() int { ret 0 }
# 只跑编译器 -S，不经过 NASM/链接/运行。
#
# 用法：
#   scripts/stdlib_sources.sh <x86_64|x86>
#   BIN=/path/to/cuteify2 scripts/stdlib_sources.sh x86_64
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd) || exit 1
BIN=${BIN:-$ROOT/cuteify2}
ARCH=${1:-}

if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "x86" ]; then
    echo "用法: $0 <x86_64|x86>" >&2
    exit 2
fi
if [ ! -x "$BIN" ]; then
    echo "编译器不存在或不可执行: $BIN（先 go build -o cuteify2 . 或设置 BIN=）" >&2
    exit 2
fi

WORK=${WORK:-/tmp/opencode/stdlib-sources-$ARCH}
rm -rf "$WORK"
mkdir -p "$WORK"
cd "$WORK" || exit 1

for d in $(cd "$ROOT" && find pkg -type f -name '*.cute' -printf '%h\n' | sort -u | grep -v '/test$' | sed 's|^pkg/||'); do
    probe="$WORK/probe"
    rm -rf "$probe"
    mkdir -p "$probe"
    printf 'import "std:%s"\nfn main() int {\n    ret 0\n}\n' "$d" > "$probe/main.cute"
    log="$WORK/$(echo "$d" | tr '/' '_').log"
    if CUTE_ROOT="$ROOT" CUTE_ARCH="$ARCH" timeout 30 "$BIN" -S "$probe" >"$log" 2>&1; then
        echo "$d|OK"
    else
        rc=$?
        if [ "$rc" -eq 124 ]; then
            echo "$d|TIMEOUT"
        else
            msg=$(sed 's/\x1b\[[0-9;]*m//g' "$log" | grep -m1 -E "Type Error|Syntax Error|Call Error|panic:|Error:" | tr '|' ' ' | cut -c1-160)
            echo "$d|FAIL|$msg"
        fi
    fi
done
