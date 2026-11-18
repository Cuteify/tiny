#!/usr/bin/env bash
# cutebuild.sh —— 用 cuteify2 把一个包就地编译 + 链接成 bin。
# 可在任意目录下调用：脚本位置按 BASH_SOURCE 定位项目根目录。
#
# 用法：
#   bash scripts/cutebuild.sh [-r|--run] <pkg-dir> [output-bin] [arch]
#   BIN=/path/to/cuteify2 bash scripts/cutebuild.sh -r selfhost/cmd/parsedump
#
# 行为：
#   - 直接在包目录里执行 cuteify2 —— 源码、_main.asm、垃圾回收摘要等
#     中间产物全部留在包目录，不拷贝到别处再编；
#   - output-bin 缺省 = <pkg 目录>/<pkg 目录名>；传第 2 个参数可指定输出位置；
#   - arch 缺省 x86_64，支持 x86_64|x86；
#   - -r|--run：构建成功后直接运行该 bin（rc 为 bin 的退出码）；
#   - 错误直接打印到终端；编译/汇编/链接任一步失败即非零退出（不运行）。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="${BIN:-$ROOT/cuteify2}"

wantRun=0
positional=()
for arg in "$@"; do
    case "$arg" in
        -r|--run) wantRun=1 ;;
        -h|--help)
            sed -n '2,14p' "$0"
            exit 0
            ;;
        --) shift; break ;;
        *) positional+=("$arg") ;;
    esac
done
set -- "${positional[@]}"

if [ $# -lt 1 ]; then
    echo "用法: bash $0 [-r|--run] <pkg-dir> [output-bin] [arch]" >&2
    exit 2
fi
pkg="$1"
if [ ! -d "$pkg" ]; then
    echo "包目录不存在: $pkg" >&2
    exit 2
fi
pkg="$(cd "$pkg" && pwd)"
if [ ! -f "$pkg/main.cute" ]; then
    echo "包目录缺少 main.cute: $pkg" >&2
    exit 2
fi
name="$(basename "$pkg")"
out="${2:-$pkg/$name}"
arch="${3:-x86_64}"

case "$arch" in
    x86_64) fmt=elf64; gccargs=() ;;
    x86)    fmt=elf32; gccargs=(-m32) ;;
    *) echo "arch 只支持 x86_64|x86: $arch" >&2; exit 2 ;;
esac

if [ ! -x "$BIN" ]; then
    echo "编译器不存在或不可执行: $BIN（先 go build -o \"$ROOT/cuteify2\" . 或设置 BIN=）" >&2
    exit 2
fi

cd "$pkg"
CUTE_ROOT="$ROOT" CUTE_ARCH="$arch" "$BIN" "$PWD"
nasm -f "$fmt" -w-label-redef-late -o "_main.o" _main.asm
gcc "${gccargs[@]}" -nostartfiles -no-pie -e _start -o "$out" "_main.o" -nostdlib
echo "BUILD_OK|$out"

if [ "$wantRun" -eq 1 ]; then
    rc=0
    (ulimit -Sc 0; "$out") || rc=$?
    echo "RUN_DONE|$out|rc=$rc"
    exit $rc
fi
