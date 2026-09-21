#!/usr/bin/env bash
# cute 编译器测试运行脚本
# 用法: ./test_run.sh [测试目录] [架构...]
#   默认: ./test_run.sh test/derefTest x86_64 x86
# 退出码含义见各测试 main.cute（deref_test 中 ret 7 = 全部通过）

set -u
cd "$(dirname "$0")" || exit 1

TARGET_DIR="${1:-test/derefTest}"
if [ $# -gt 1 ]; then
    ARCHS=("${@:2}")
else
    ARCHS=(x86_64 x86)
fi

BUILD_BIN="$(pwd)/.tmp/cuteify2"
WORK="$(pwd)/.tmp/cuterun"

[ -d "$TARGET_DIR" ] || { echo "错误: 测试目录不存在: $TARGET_DIR"; exit 1; }
command -v nasm >/dev/null || { echo "错误: 缺少 nasm"; exit 1; }
command -v ld >/dev/null || { echo "错误: 缺少 ld"; exit 1; }

echo "==> 构建编译器: go build -o $BUILD_BIN ."
TMPDIR="${TMPDIR:-$(pwd)/.tmp}" go build -o "$BUILD_BIN" . || { echo "编译器构建失败"; exit 1; }

mkdir -p "$WORK"
rm -f "$WORK"/*

for arch in "${ARCHS[@]}"; do
    echo ""
    echo "================================================"
    echo "==> 编译 ($arch): $TARGET_DIR"
    echo "================================================"
    if ! CUTE_ARCH=$arch "$BUILD_BIN" "$TARGET_DIR"; then
        echo "[$arch] 编译失败"
        continue
    fi

    cp _main.asm "$WORK/main_$arch.asm"
    if [ "$arch" = "x86_64" ]; then
        nasm -f elf64 -w-label-redef-late -o "$WORK/main_$arch.o" "$WORK/main_$arch.asm" || continue
        gcc -nostartfiles -no-pie -e _start -o "$WORK/main_$arch" "$WORK/main_$arch.o" -lpthread || continue
    else
        nasm -f elf32 -w-label-redef-late -o "$WORK/main_$arch.o" "$WORK/main_$arch.asm" || continue
        gcc -m32 -nostartfiles -no-pie -e _start -o "$WORK/main_$arch" "$WORK/main_$arch.o" -lpthread || continue
    fi

    "$WORK/main_$arch"
    code=$?
    echo "[$arch] exit=$code"
done

echo ""
echo "完成。产物目录: $WORK"
