#!/usr/bin/env bash
# 自举 parser（S3）AST 对拍：同一源码分别经 Go astdump 与自举 parsedump --ast，
# 逐节点比较 canonical AST 文本。
#
# 用法（仓库根目录或任意位置）：
#   BIN=/tmp/opencode/bin/cute scripts/selfhost_ast_parity.sh [x86_64|x86] [file...]
#   ALL=1 BIN=/tmp/opencode/bin/cute scripts/selfhost_ast_parity.sh [x86_64|x86]
#
# 默认跑 selfhost/parse/test/ast/ 语料与三个代表文件，每个文件一行 PARITY_OK。
# ALL=1 扫描 git ls-files '*.cute'：已知差异文件输出 PARITY_KNOWN，
# Go parser 单文件解析失败输出 PARITY_SKIP_GO_FAIL，其余必须 PARITY_OK。
# 显式传入的文件一律按严格模式比较，不套用已知差异白名单。
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd) || exit 1
BIN=${BIN:-$ROOT/cuteify2}
ARCH=${1:-x86_64}
shift || true

DEFAULT_FILES="
selfhost/parse/test/ast/fold.cute
selfhost/parse/test/ast/expr.cute
selfhost/parse/test/ast/deref.cute
selfhost/parse/test/ast/slice.cute
selfhost/parse/test/ast/generic.cute
selfhost/parse/test/ast/types.cute
selfhost/parse/test/ast/control.cute
test/gcOverwrite/main.cute
test/neg_index_step/main.cute
test/mp_min/main.cute
pkg/slices/test/main.cute
"

# known_reason 返回 ALL 模式下允许的已知差异原因；空串表示必须完全一致。
known_reason() {
    case "$1" in
    pkg/hash/fnv/fnv.cute)
        echo "大整数常量超出 int64 精度（自举侧 parseNumText 溢出）"
        ;;
    pkg/path/path.cute)
        echo "Go parser 把参数位置的 fn(T) 解析成 T（Go 侧实现噪声）"
        ;;
    test/negIdx/main.cute | test/runtime/malloc_darwin.cute | test/strconv/main.cute | \
        pkg/hash/crc32/crc32.cute | pkg/compress/lzw/lzw.cute | pkg/console/caps.cute | \
        pkg/hash/crc64/crc64.cute | pkg/sort/test/main.cute | pkg/sort/tim.cute | \
        pkg/console/advanced.cute)
        echo "Go 仅在校验可达时折叠常量（跨文件/跨包符号解析时序）"
        ;;
    test/derefTest/u64.cute)
        echo "浮点字面量保留源码文本，Go 输出 %v 最短表示"
        ;;
    test/sortTest/main.cute)
        echo "浮点格式 + Go 折叠时序"
        ;;
    pkg/math/test/main.cute)
        echo "浮点格式 + Go 折叠时序"
        ;;
    pkg/math/math.cute)
        echo "浮点格式 + Inf/NaN 折叠（自举侧未做浮点格式化）"
        ;;
    *)
        echo ""
        ;;
    esac
}

if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "x86" ]; then
    echo "用法: $0 [x86_64|x86] [file...]" >&2
    exit 2
fi
if [ ! -x "$BIN" ]; then
    echo "编译器不存在或不可执行: $BIN（先 go build -o /tmp/opencode/bin/cute . 或设置 BIN=）" >&2
    exit 2
fi

if [ "$ARCH" = "x86_64" ]; then
    fmt=elf64
    gccargs=""
else
    fmt=elf32
    gccargs="-m32"
fi

mode=list
if [ "${ALL:-0}" = "1" ] && [ "$#" -eq 0 ]; then
    mode=all
    mapfile -t FILES < <(cd "$ROOT" && git ls-files '*.cute')
elif [ "$#" -gt 0 ]; then
    FILES=("$@")
else
    mapfile -t FILES <<<"$DEFAULT_FILES"
fi

# 串行化编译/汇编/链接与运行，避免与其它 e2e 任务争用临时文件。
exec 9>/tmp/opencode/lock
flock 9

WORK=${WORK:-/tmp/opencode/selfhost-ast-parity-$ARCH}
rm -rf "$WORK"
mkdir -p "$WORK"
cp -a "$ROOT/selfhost" "$WORK/selfhost"

cd "$WORK/selfhost/cmd/parsedump" || exit 1
log="$WORK/parsedump-compile.log"
if ! CUTE_ROOT="$ROOT" CUTE_ARCH="$ARCH" "$BIN" "$PWD" >"$log" 2>&1; then
    echo "SELFHOST_AST_PARITY_FAIL|COMPILE"
    tail -20 "$log"
    exit 1
fi
if ! nasm -f "$fmt" -w-label-redef-late -o "$WORK/parsedump.o" _main.asm >"$WORK/parsedump-nasm.log" 2>&1; then
    echo "SELFHOST_AST_PARITY_FAIL|NASM"
    tail -10 "$WORK/parsedump-nasm.log"
    exit 1
fi
# shellcheck disable=SC2086
if ! gcc $gccargs -nostartfiles -s -Wl,--build-id=none,--gc-sections -no-pie -e _start -o "$WORK/parsedump" "$WORK/parsedump.o" -nostdlib >"$WORK/parsedump-link.log" 2>&1; then
    echo "SELFHOST_AST_PARITY_FAIL|LINK"
    tail -10 "$WORK/parsedump-link.log"
    exit 1
fi

cd "$ROOT" || exit 1
if ! TMPDIR=/tmp/opencode go build -o "$WORK/astdump" ./tools/astdump >"$WORK/astdump-build.log" 2>&1; then
    echo "SELFHOST_AST_PARITY_FAIL|GO_BUILD"
    tail -20 "$WORK/astdump-build.log"
    exit 1
fi

ok=0
known=0
gofail=0
bad=0
for f in "${FILES[@]}"; do
    [ -n "$f" ] || continue
    if [ ! -f "$f" ]; then
        echo "PARITY_FAIL|$f|missing"
        bad=$((bad + 1))
        continue
    fi

    "$WORK/astdump" "$f" >"$WORK/go.ast" 2>"$WORK/go.err"
    grc=$?
    if [ "$grc" -ne 0 ]; then
        if [ "$mode" = "all" ]; then
            echo "PARITY_SKIP_GO_FAIL|$f"
            gofail=$((gofail + 1))
            continue
        fi
        echo "PARITY_GO_FAIL|$f|rc=$grc"
        sed -n '1,5p' "$WORK/go.err"
        bad=$((bad + 1))
        continue
    fi

    (ulimit -Sc 0; PARSEDUMP_AST=1 timeout 60 "$WORK/parsedump" <"$f" >"$WORK/cute.ast" 2>"$WORK/cute.err")
    crc=$?
    if [ "$crc" -ne 0 ]; then
        echo "PARITY_FAIL|$f|cute_rc=$crc"
        sed -n '1,5p' "$WORK/cute.err"
        bad=$((bad + 1))
        continue
    fi

    if diff -q "$WORK/go.ast" "$WORK/cute.ast" >/dev/null; then
        nodes=$(wc -l <"$WORK/go.ast" | tr -d ' ')
        echo "PARITY_OK|$f|nodes=$nodes"
        ok=$((ok + 1))
        continue
    fi

    reason=$(known_reason "$f")
    if [ "$mode" = "all" ] && [ -n "$reason" ]; then
        echo "PARITY_KNOWN|$f|$reason"
        known=$((known + 1))
        continue
    fi

    echo "PARITY_DIFF|$f"
    diff -u "$WORK/go.ast" "$WORK/cute.ast" | sed -n '1,30p'
    bad=$((bad + 1))
done

if [ "$ok" -eq 0 ] && [ "$bad" -eq 0 ] && [ "$known" -eq 0 ]; then
    echo "SELFHOST_AST_PARITY_FAIL|no input files"
    exit 1
fi
if [ "$bad" -ne 0 ]; then
    echo "SELFHOST_AST_PARITY_FAIL|$ARCH|ok=$ok|known=$known|go_fail=$gofail|bad=$bad"
    exit 1
fi
echo "SELFHOST_AST_PARITY_OK|$ARCH|ok=$ok|known=$known|go_fail=$gofail"
