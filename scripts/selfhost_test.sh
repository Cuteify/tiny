#!/usr/bin/env bash
# 自举 lexer 行为测试：编译 selfhost/lexer/test，汇编、链接后对 testdata 语料做
# 逐字节对拍（main <语料>，stdout = [TYPE]value token 流，与对应 .want 比较）；
# 全部通过才输出 SELFHOST_OK|x86_64|RC=42。
#
# 用法（仓库根目录或任意位置）：
#   scripts/selfhost_test.sh [x86_64|x86]
#   BIN=/tmp/opencode/bin/selfhostc scripts/selfhost_test.sh x86_64
#
# 说明：
#   - 源码先复制到临时目录，避免 _main.asm / gc_* 污染工作区；
#   - 默认编译器为仓库根的 cuteify2，可用 BIN 覆盖；
#   - 编译器参数是目录；测试目录内必须有 main.cute；
#   - 语料与 .want 存放于 selfhost/lexer/testdata/（sample.cute + cases/*.cute）；
#     .want 由本移植生成，与 Go 参考的唯一被登记背离是“文件不以 DELIMITER
#     结尾时 EOF 尾部词素的补发”，重生成时需逐例 diff 复核。
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
cp -a "$ROOT/selfhost/lexer" "$WORK/lexer"
cd "$WORK/lexer/test" || exit 1

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
if ! gcc $gccargs -nostartfiles -s -Wl,--build-id=none,--gc-sections -no-pie -e _start -o "$WORK/main" "$WORK/main.o" -nostdlib >"$WORK/link.log" 2>&1; then
    objcopy -R .gnu.hash -R .gnu.version -R .gnu.version_r -R .note.gnu.build-id "$WORK/main"
    objcopy --strip-section-headers "$WORK/main"
    llvm-objcopy --strip-sections "$WORK/main"
    python "$ROOT/scripts/cutelf.py" "$WORK/main"
    echo "SELFHOST_FAIL|LINK"
    tail -10 "$WORK/link.log"
    exit 1
fi

# 对拍每个 .cute 测试语料：运行 main（main <语料>，stdout = [TYPE]value 流）
# 并与其 .want 文件逐字节比较；全部通过才输出 SELFHOST_OK。
mkdir -p "$WORK/out"
failed=0
case_count=0
for case_file in "$WORK/lexer/testdata/cases/"*.cute "$WORK/lexer/testdata/sample.cute"; do
    base=$(basename "$case_file" .cute)
    want="${case_file%.cute}.want"
    out="$WORK/out/$base.out"
    "$WORK/main" "$case_file" | tee "$out"
    rc=${PIPESTATUS[0]}
    case_count=$((case_count + 1))
    if [ $rc -ne 42 ]; then
        echo "SELFHOST_FAIL|case=$base|RC=$rc"
        failed=1
        break
    fi
    if ! cmp -s "$out" "$want"; then
        echo "SELFHOST_FAIL|case=$base|DIFF"
        diff "$want" "$out" | head -20
        failed=1
        break
    fi
done
if [ "$failed" -ne 0 ]; then
    exit 1
fi

echo "SELFHOST_CASES|$ARCH|checked=$case_count"
echo "SELFHOST_OK|$ARCH|RC=42"
