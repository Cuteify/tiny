#!/usr/bin/env bash
# 全语料前端 GC 基线检查。
#
# 用法（仓库根目录或任意位置）：
#   scripts/gc_corpus_check.sh
#   JOBS=4 scripts/gc_corpus_check.sh
#
# 默认基线：对象=160 作用域=111 就地=6 字段=1 转移=30 RC=12；
# 泄漏 / 提前释放 / HolderBad 必须为 0。可用 EXPECT_* 环境变量覆盖期望，
# 但只有在差异已逐条归因后才这样做。
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd) || exit 1
JOBS=${JOBS:-8}
WORK=$(mktemp -d "${TMPDIR:-/tmp}/gc-corpus.XXXXXX") || exit 1
trap 'rm -rf "$WORK"' EXIT

cd "$ROOT" || exit 1
go build -o "$WORK/esccheck" ./tools/esccheck || exit 1

# 分析过程可能在当前目录写 ast.html；统一在临时目录里跑，避免污染工作区。
cd "$WORK" || exit 1

run_one() {
  dir="$1"
  name=$(basename "$dir")
  out=$(timeout 40 "$WORK/esccheck" "$dir" 2>/dev/null || true)
  nums=$(printf '%s\n' "$out" | awk '
    /^对象=/ {for(i=1;i<=NF;i++){split($i,a,"="); if(a[1]=="对象")o=a[2]; if(a[1]=="泄漏")l=a[2]; if(a[1]=="提前释放")p=a[2]; if(a[1]=="就地释放")ip=a[2]; if(a[1]=="字段释放")f=a[2]}}
    /^  作用域释放=/ {for(i=1;i<=NF;i++){split($i,a,"="); if(a[1]=="作用域释放")s=a[2]; if(a[1]=="转移")x=a[2]; if(a[1]=="RC")r=a[2]; if(a[1]=="HolderBad")h=a[2]}}
    END{if(o=="")exit 1; print o,r,l,p,s,x,ip,f,h}')
  if [ -z "$nums" ]; then
    echo "FAIL|$name"
  else
    echo "OK|$name|$nums"
  fi
}

export -f run_one
export WORK CUTE_ROOT="$ROOT"
find "$ROOT/test" -mindepth 1 -maxdepth 1 -type d -print0 |
  sort -z |
  xargs -0 -P "$JOBS" -I{} bash -c 'run_one "$@"' _ {} >"$WORK/raw"

python3 - "$WORK/raw" <<'PY'
import os
import sys

rows = []
fails = []
for line in open(sys.argv[1], encoding="utf-8"):
    parts = line.strip().split("|")
    if parts[0] == "OK":
        rows.append((parts[1], list(map(int, parts[2].split()))))
    else:
        fails.append(parts[1])

# 列序：对象 RC 泄漏 提前释放 作用域 转移 就地 字段 HolderBad
tot = [sum(row[1][i] for row in rows) for i in range(9)]
print(f"成功={len(rows)} 失败={len(fails)}")
if fails:
    print("失败目录: " + " ".join(fails))
print(
    f"对象={tot[0]} 作用域={tot[4]} 就地={tot[6]} 字段={tot[7]} "
    f"转移={tot[5]} RC={tot[1]}"
)
print(f"泄漏={tot[2]} 提前释放={tot[3]} HolderBad={tot[8]}")

expected = {
    "对象": (tot[0], int(os.environ.get("EXPECT_OBJECTS", "160"))),
    "作用域": (tot[4], int(os.environ.get("EXPECT_SCOPE", "111"))),
    "就地": (tot[6], int(os.environ.get("EXPECT_INPLACE", "6"))),
    "字段": (tot[7], int(os.environ.get("EXPECT_FIELD", "1"))),
    "转移": (tot[5], int(os.environ.get("EXPECT_TRANSFER", "30"))),
    "RC": (tot[1], int(os.environ.get("EXPECT_RC", "12"))),
    "成功目录": (len(rows), int(os.environ.get("EXPECT_OK", "106"))),
    "失败目录": (len(fails), int(os.environ.get("EXPECT_FAIL", "9"))),
}
bad = []
for name, (got, want) in expected.items():
    if got != want:
        bad.append(f"{name}: {got} != {want}")
if tot[2] or tot[3] or tot[8]:
    bad.append(f"安全计数非零: 泄漏={tot[2]} 提前释放={tot[3]} HolderBad={tot[8]}")
if bad:
    print("基线不匹配:")
    for item in bad:
        print("  " + item)
    raise SystemExit(1)
print("基线通过")
PY
