#!/usr/bin/env python3
"""归一化 cuteify 汇编，供跨构建对比。

oob_* 标签每次运行都不同，函数块顺序也可能受 map 遍历影响；这里把可变
标签折叠成固定名、按函数块排序，其余内容保持原样。用法：

    python3 scripts/normasm.py _main.asm > _main.norm

只比较归一化结果；不要用它替代真实汇编审查。
"""
import re
import sys

TAIL = "; 程序入口点 (ELF入口)"


def norm(path):
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        text = f.read()
    text = re.sub(r"oob_[0-9a-fA-F]+", "oob_X", text)
    text = re.sub(
        r"\b(and_mid|else_if|end_if|for|if|str)_\d+(_body|_end)?\b",
        r"\1_N\2",
        text,
    )
    idx = text.find(TAIL)
    head, tail = (text, "") if idx < 0 else (text[:idx], text[idx:])
    lines = [line.rstrip() for line in head.splitlines() if line.strip()]
    starts = [i for i, line in enumerate(lines) if line.startswith("; Function: ")]
    if not starts:
        return "\n".join(lines + tail.splitlines()) + "\n"

    preamble = "\n".join(lines[: starts[0]])
    blocks = []
    for j, start in enumerate(starts):
        end = starts[j + 1] if j + 1 < len(starts) else len(lines)
        blocks.append("\n".join(lines[start:end]))
    blocks.sort()
    return preamble + "\n" + "\n".join(blocks) + "\n" + "\n".join(tail.splitlines()) + "\n"


def main():
    if len(sys.argv) != 2:
        print("用法: normasm.py <asm文件>", file=sys.stderr)
        return 2
    sys.stdout.write(norm(sys.argv[1]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
