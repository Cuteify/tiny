#!/usr/bin/env python3
"""Generate Cuteify memory manager v3 size class table.

Five tiers:
  tiny  (≤1024)    : proportional step, max 12.5% internal fragmentation
  small (1024-4096) : strict power-of-2
  middle(4096-64KB) : quasi-exponential 1.125x growth
"""

TINY_MAX = 1024
SMALL_MAX = 4096
MIDDLE_MAX = 65536
ALIGN_MIN = 8  # 32-bit; 16 for 64-bit

classes = []

# --- tiny: proportional step ---
s = 32
cls = 0
while s <= TINY_MAX:
    classes.append(("tiny", cls, s))
    step = max(ALIGN_MIN, (s + 7) // 8)  # ceil(s/8)
    s += step
    cls += 1

# --- small: power-of-2 ---
for sz in [2048, 4096]:
    classes.append(("small", cls, sz))
    cls += 1

# --- middle: quasi-exponential 1.125x ---
s = 4096
while s < MIDDLE_MAX:
    s_next = s + (s >> 3)  # s * 1.125
    if s_next > MIDDLE_MAX:
        break
    classes.append(("middle", cls, s_next))
    s = s_next
    cls += 1

# Print table
print(f"{'Tier':<8} {'Class':>5} {'Size':>8} {'Delta':>8} {'Frag%':>6}")
print("-" * 42)
prev = 0
for tier, idx, sz in classes:
    delta = sz - prev if prev else 0
    # Max frag% for this class: size difference to next class / this size
    frag = ""
    print(f"{tier:<8} {idx:>5} {sz:>8} {delta:>8} {frag:>6}")
    prev = sz

print(f"\nTotal classes: {len(classes)}")
print(f"  tiny:  {sum(1 for t,_,_ in classes if t=='tiny')}")
print(f"  small: {sum(1 for t,_,_ in classes if t=='small')}")
print(f"  middle:{sum(1 for t,_,_ in classes if t=='middle')}")
