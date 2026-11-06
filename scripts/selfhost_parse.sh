#!/usr/bin/env bash
# 自举 parser（S2）验收入口：构建 parsedump，跑 parser 自测与固定语料，
# 或对指定源码文件做语法验证。
#
# 用法（仓库根目录或任意位置）：
#   scripts/selfhost_parse.sh [x86_64|x86]
#   scripts/selfhost_parse.sh [x86_64|x86] file.cute [file2.cute ...]
#
# 无源码参数时：
#   1. 编译并运行 selfhost/parse/test，要求退出码 42；
#   2. 用 parsedump 跑固定语料，要求全部 PARSE_OK。
# 给了源码参数时只验证这些文件，不跑自测。
#
# 说明：
#   - 源码复制到临时目录，避免 _main.asm / 目标文件污染工作区；
#   - 默认编译器为仓库根的 cuteify2，可用 BIN 覆盖；
#   - 与其它 e2e/汇编任务共用 /tmp/opencode/lock 串行执行。
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd) || exit 1
BIN=${BIN:-$ROOT/cuteify2}
ARCH=${1:-x86_64}
shift || true

DEFAULT_FILES="
selfhost/lex/lex.cute
selfhost/lex/test/main.cute
selfhost/parse/parse.cute
selfhost/parse/test/main.cute
selfhost/cmd/tokdump/main.cute
selfhost/cmd/parsedump/main.cute
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

if [ "$ARCH" = "x86_64" ]; then
    fmt=elf64
    gccargs=""
else
    fmt=elf32
    gccargs="-m32"
fi

# 串行化编译/汇编/链接与运行，避免与其它 e2e 任务争用临时文件。
exec 9>/tmp/opencode/lock
flock 9

WORK=${WORK:-/tmp/opencode/selfhost-parse-$ARCH}
rm -rf "$WORK"
mkdir -p "$WORK"
cp -a "$ROOT/selfhost" "$WORK/selfhost"

# build_driver 编译一个目录下的 main.cute，产出 $WORK/$1。
build_driver() {
    name=$1
    dir=$2
    log="$WORK/$name-compile.log"
    cd "$dir" || exit 1
    if ! CUTE_ROOT="$ROOT" CUTE_ARCH="$ARCH" "$BIN" "$PWD" >"$log" 2>&1; then
        echo "SELFHOST_PARSE_FAIL|COMPILE|$name"
        tail -20 "$log"
        exit 1
    fi
    if [ ! -f _main.asm ]; then
        echo "SELFHOST_PARSE_FAIL|missing _main.asm|$name"
        tail -20 "$log"
        exit 1
    fi
    if ! nasm -f "$fmt" -w-label-redef-late -o "$WORK/$name.o" _main.asm >"$WORK/$name-nasm.log" 2>&1; then
        echo "SELFHOST_PARSE_FAIL|NASM|$name"
        tail -10 "$WORK/$name-nasm.log"
        exit 1
    fi
    # shellcheck disable=SC2086
    if ! gcc $gccargs -nostartfiles -no-pie -e _start -o "$WORK/$name" "$WORK/$name.o" -lpthread >"$WORK/$name-link.log" 2>&1; then
        echo "SELFHOST_PARSE_FAIL|LINK|$name"
        tail -10 "$WORK/$name-link.log"
        exit 1
    fi
}

build_driver parsedump "$WORK/selfhost/cmd/parsedump"

selftest=skip
if [ "$#" -eq 0 ]; then
    build_driver parsetest "$WORK/selfhost/parse/test"
    (ulimit -Sc 0; timeout 60 "$WORK/parsetest")
    rc=$?
    if [ "$rc" -ne 42 ]; then
        echo "SELFHOST_PARSE_FAIL|SELFTEST|RC=$rc (expected 42, failure group is $rc)"
        exit 1
    fi
    selftest=42
    set -- $DEFAULT_FILES
fi

cd "$ROOT" || exit 1
ok=0
bad=0
for f in "$@"; do
    if [ ! -f "$f" ]; then
        echo "PARSE_FAIL|$f|missing"
        bad=$((bad + 1))
        continue
    fi

    (ulimit -Sc 0; timeout 60 "$WORK/parsedump" <"$f" >"$WORK/parse.out" 2>"$WORK/parse.err")
    rc=$?
    out=$(cat "$WORK/parse.out")
    if [ "$rc" -ne 0 ]; then
        echo "PARSE_FAIL|$f|rc=$rc|$out"
        sed -n '1,5p' "$WORK/parse.err"
        bad=$((bad + 1))
        continue
    fi
    case "$out" in
        PARSE_OK\|*)
            echo "PARSE_OK|$f|${out#PARSE_OK|}"
            ok=$((ok + 1))
            ;;
        *)
            echo "PARSE_FAIL|$f|bad output|$out"
            bad=$((bad + 1))
            ;;
    esac
done

if [ "$ok" -eq 0 ] && [ "$bad" -eq 0 ]; then
    echo "SELFHOST_PARSE_FAIL|no input files"
    exit 1
fi
if [ "$bad" -ne 0 ]; then
    echo "SELFHOST_PARSE_FAIL|$ARCH|ok=$ok|bad=$bad|selftest=$selftest"
    exit 1
fi
echo "SELFHOST_PARSE_OK|$ARCH|selftest=$selftest|files=$ok"
