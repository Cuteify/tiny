#!/usr/bin/env bash
# 用两个 cuteify 二进制生成 GC 重点目录汇编，归一化后比较。
#
# 用法：
#   scripts/gc_asm_diff.sh <old-bin> <new-bin> [arch ...]
#
# 默认跑 x86_64 / x86，目录固定为 GC 重点覆盖集；可用 DIRS 覆盖：
#   DIRS="gcBlocks gc_loop" scripts/gc_asm_diff.sh ./old ./new x86_64
#
# x86 下部分目录本来就会编译失败；两个二进制都失败视为一致，只有一边
# 成功才算回归。归一化规则见 scripts/normasm.py。
set -u

if [ $# -lt 2 ]; then
  echo "用法: $0 <old-bin> <new-bin> [arch ...]" >&2
  exit 2
fi

ROOT=$(cd "$(dirname "$0")/.." && pwd) || exit 1
OLD=$(realpath "$1") || exit 1
NEW=$(realpath "$2") || exit 1
shift 2

ARCHES=("$@")
if [ ${#ARCHES[@]} -eq 0 ]; then
  ARCHES=(x86_64 x86)
fi
DIRS=${DIRS:-"gcBlocks gcCondTemp gc_loop gcOverwrite gcprobe gcRetFree gcStructFree heap_new"}

WORK=$(mktemp -d "${TMPDIR:-/tmp}/gc-asm.XXXXXX") || exit 1
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK"

LOCK=/tmp/opencode/lock
mkdir -p "$(dirname "$LOCK")"

compile_one() {
  bin=$1
  arch=$2
  dir=$3
  out=$4
  mkdir -p "$out" || return 9
  (
    cd "$out" || exit 9
    CUTE_ROOT="$ROOT" CUTE_ARCH="$arch" flock "$LOCK" \
      timeout 180 "$bin" -S "$ROOT/test/$dir" >"$out/compile.log" 2>&1
  )
}

same=0
diff=0
both_fail=0
one_fail=0
for arch in "${ARCHES[@]}"; do
  for dir in $DIRS; do
    olddir="$WORK/$arch/$dir/old"
    newdir="$WORK/$arch/$dir/new"
    compile_one "$OLD" "$arch" "$dir" "$olddir"
    oldrc=$?
    compile_one "$NEW" "$arch" "$dir" "$newdir"
    newrc=$?

    if [ "$oldrc" -ne 0 ] && [ "$newrc" -ne 0 ]; then
      echo "BOTH_FAIL $arch $dir (old=$oldrc new=$newrc)"
      both_fail=$((both_fail + 1))
      continue
    fi
    if [ "$oldrc" -ne 0 ] || [ "$newrc" -ne 0 ]; then
      echo "ONE_FAIL $arch $dir (old=$oldrc new=$newrc)"
      one_fail=$((one_fail + 1))
      continue
    fi

    python3 "$ROOT/scripts/normasm.py" "$olddir/_main.asm" >"$olddir/main.norm" || exit 9
    python3 "$ROOT/scripts/normasm.py" "$newdir/_main.asm" >"$newdir/main.norm" || exit 9
    if cmp -s "$olddir/main.norm" "$newdir/main.norm"; then
      echo "SAME $arch $dir"
      same=$((same + 1))
    else
      echo "DIFF $arch $dir"
      diff=$((diff + 1))
    fi
  done
done

echo "SAME=$same DIFF=$diff BOTH_FAIL=$both_fail ONE_FAIL=$one_fail"
[ "$diff" -eq 0 ] && [ "$one_fail" -eq 0 ]
