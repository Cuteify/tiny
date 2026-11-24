# GC / 内存泄漏分析手册

本文记录 Cute 编译器/运行时内存问题的定位方法、命令、探针模板与判读规则。目标是把“tracker leak=0 但堆仍驻留”这类问题快速定位到根因。

## 1. 先分清三种“没释放”

1. **Tracker leak**：`memory.reportAllLeaks()` 非 0。说明 `trackAllocAll` 有记录但没有对应 `trackFreeAll`。
2. **堆驻留但 tracker 平衡**：`alloc==free && leaks==0`，但 `brk` 仍高或 `dumpAllocator()` 有 `allocN>0`。说明不是普通用户泄漏，可能是未跟踪分配、tracker 自身表、allocator 元数据、堆顶 pin。
3. **OS/页层驻留**：`brk` 已回缩但 RSS/VmData 看起来没降很多。brk 归还的是虚拟地址空间；页回收/驻留受内核行为影响。优先看 `brk` 和 allocator 扫描。

结论判定顺序：**先 tracker，再 heap scan，再 brk/RSS**。

## 2. 基本环境与纪律

- 工作目录：仓库根 `/home/gx/Desktop/代码/tiny`
- 临时构建目录用 `/tmp/opencode/...`，不要污染仓库。
- 任何可能 SIGSEGV/SIGABRT 的探针运行前：`ulimit -Sc 0`
- 需要 core 时才 `ulimit -Sc unlimited`，取证后删 core 并恢复 `ulimit -Sc 0`
- `scripts/cutebuild.sh` 默认使用仓库根 `./cuteify2`；Go 编译器改动后先重建：

```bash
cd /home/gx/Desktop/代码/tiny
GOCACHE=/tmp/opencode/gocache TMPDIR=/tmp/opencode go build -o cuteify2 .
```

- 直接用指定编译器构建 selfhost 包：

```bash
TMPDIR=/tmp/opencode CUTE_ROOT=/home/gx/Desktop/代码/tiny CUTE_ARCH=x86_64 \
  /tmp/opencode/bin/wip_gc2 "$PWD" > compile.log 2>&1
```

## 3. 快速检查入口

### 3.1 selfhost parsedump leak 检查

用户 instrumented 文件：`selfhost/cmd/parsedump/main.cute`。不要覆盖用户改动；需要额外诊断时复制到 `/tmp/opencode/...`。

运行：

```bash
cd /home/gx/Desktop/代码/tiny/selfhost/cmd/parsedump
ulimit -Sc 0
timeout 240 /home/gx/Desktop/代码/tiny/scripts/cutebuild.sh . -r
```

关键输出：

```text
SELFHOST_LEAK|alloc=N|free=N|leaks=0
```

### 3.2 只看 tracker 不够

`leaks==0` 只说明 all-tracker 平衡，不说明 brk 堆空。必须再看 `dumpAllocator()` 或 brk。

## 4. allocator dump 接口

位置：`pkg/memory/allocator.cute`

```cute
memory.dumpAllocator()  // 输出到 stdout
memory.trim()           // 回收堆顶连续空闲块，返回回收字节数
```

输出含义：

- `brk=...`：当前 `syscall.brk(0)`
- `freeHeads=...`：空闲链表头数组地址
- `slot=N blk=... free=... bytes=...`：该 size class 空闲链表节点数和字节数。只打印非空 slot。
- `freeTotal/freeBytes`：slot 空闲链表总计。注意 LARGE(>MIDDLE_MAX) 块可能不在 0-59 slot（见已知限制）。
- `scan allocN/allocB/freeN/freeB/bad/end`：从 `gFreeHeads+480` 线性扫描堆块得到的汇总。
  - `allocN/allocB`：堆头 `IS_FREE==0` 的块。若 leaks==0 仍有 allocN，重点排查。
  - `freeN/freeB`：堆头 `IS_FREE==1` 的块。
  - `bad!=0`：块大小非法或块越界，说明堆元数据损坏或 dump 扫描边界异常。
  - `end`：扫描结束地址，应接近 scan 时的 heapTop。
- `topFooter/topBlk`：堆顶 footer 和对应 top block。判断 trim 能否回缩。

注意：`dumpAllocator()` 内部 `wu()` 使用 `malloc/free` 格式化数字，会产生少量分配并可能影响 tracker/heapTop。不要放在精确 leak 计数窗口内；必要时在 dump 前后分别看，或把 dump 放在计数之后。

## 5. 标准探针模板

### 5.1 tracker + brk + trim

```cute
import "std:console"
import "std:strings"
import "std:memory"
import "std:syscall"

fn main() int {
    var b0: ptr = syscall.brk(0)
    // workload...
    var ac: uint = memory.reportAllAllocCount()
    var fc: uint = memory.reportAllFreeCount()
    var lk: uint = memory.reportAllLeaks()
    var b1: ptr = syscall.brk(0)
    var r1: uint = memory.trim()
    var b2: ptr = syscall.brk(0)
    console.print("LEAK|alloc=")
    console.print(strings.toString(unsafe.cast[int](ac), 10))
    console.print("|free=")
    console.print(strings.toString(unsafe.cast[int](fc), 10))
    console.print("|leaks=")
    console.println(strings.toString(unsafe.cast[int](lk), 10))
    console.print("HEAP|before=")
    console.print(strings.toString(unsafe.cast[int](b1-b0), 10))
    console.print("|trim=")
    console.print(strings.toString(unsafe.cast[int](r1), 10))
    console.print("|after=")
    console.println(strings.toString(unsafe.cast[int](b2-b0), 10))
    ret 0
}
```

### 5.2 heap walk 找 pinned allocated block

```cute
var cur: ptr = b0 + 480
for cur + 8 <= b2 {
    var _hp: *ptr = cur
    var raw: uint = *_hp
    var pure: uint = raw & ~7
    if pure < 32 { break }
    if (raw & 1) == 0 {
        // allocated block: print off/pure/hdr/tracked
    }
    var next: ptr = cur + pure
    if next <= cur || next > b2 { break }
    cur = next
}
```

判读：`raw&1==0` 说明 IS_FREE 未置位。若 `isTrackedAll(cur+8)==0` 且 leaks==0，说明该块不在 all-tracker live 集合。

### 5.3 parsedump 临时复制构建

不要改 `selfhost/cmd/parsedump/main.cute`，复制到 `/tmp`：

```bash
WORK=/tmp/opencode/pd-probe
rm -rf "$WORK"; mkdir -p "$WORK"
cp -r /home/gx/Desktop/代码/tiny/selfhost "$WORK/selfhost"
# 写入 $WORK/selfhost/cmd/parsedump/main.cute
cd "$WORK/selfhost/cmd/parsedump"
TMPDIR=/tmp/opencode CUTE_ROOT=/home/gx/Desktop/代码/tiny CUTE_ARCH=x86_64 \
  /tmp/opencode/bin/wip_gc2 "$PWD" >"$WORK/compile.log" 2>&1
nasm -f elf64 -w-label-redef-late -o "$WORK/main.o" _main.asm >"$WORK/nasm.log" 2>&1
gcc -nostartfiles -s -Wl,--build-id=none,--gc-sections -no-pie -e _start \
  -o "$WORK/main" "$WORK/main.o" -nostdlib >"$WORK/link.log" 2>&1
ulimit -Sc 0
timeout 120 "$WORK/main"
```

## 6. GDB 追踪方法

用于确认某个大块是谁分配的、是否被 free。构建 debug 二进制：

```bash
nasm -f elf64 -g -F dwarf -w-label-redef-late -o /tmp/opencode/main.o _main.asm
gcc -nostartfiles -Wl,--build-id=none -no-pie -e _start \
  -o /tmp/opencode/main_dbg /tmp/opencode/main.o -nostdlib
```

### 6.1 追踪特定大小 malloc

```gdb
set debuginfod enabled off
set pagination off
break std_memory_malloc if $rdi == 65536
commands
  silent
  set $retpc = *(unsigned long *)$rsp
  tbreak *$retpc
  commands
    silent
    printf "M sz=%lu ret=%p\n", $rdi, $rax
    bt 6
    continue
  end
  continue
end
run
```

运行：

```bash
ulimit -Sc 0
timeout 240 gdb -batch -x /tmp/opencode/gdb.gdb --args /tmp/opencode/main_dbg > /tmp/opencode/gdb.txt 2>&1
```

注意：x86_64 SysV，`std_memory_malloc(size)` 的 `size` 在 `RDI`，返回值在 `RAX`。断点命中在函数入口 `push rbp` 前，`$rsp` 存返回地址。

### 6.2 追踪范围大小

大块可能不是精确 65536。LARGE path 下 `pure` 为 65552 的用户 size 范围是 65521-65536：

```gdb
break std_memory_malloc if $rdi >= 65520 && $rdi <= 65536
```

### 6.3 追踪 free

```gdb
break std_memory_free
commands
  silent
  printf "FREE ptr=%p\n", $rdi
  continue
end
```

输出和程序 stdout 交错时可重定向到文件后 grep。避免在 batch commands 里做复杂逻辑。

### 6.4 地址变化

ASLR/heap 地址每次运行可能不同。不要跨 run 复用地址。先在同 run 中拿到 block addr，再用 gdb 在同 run 或单独 run 里定位 malloc/free 模式。必要时在 probe 中打印 `B0`/`ALLOC addr`。

## 7. 堆/分配器内部知识点

### 7.1 块布局

普通块：

```text
[header: PTR_SIZE] [user data ...] [footer: PTR_SIZE]
user ptr = blk + PTR_SIZE
header/footer = pure_size | flags
```

标志位（低 3 位，`FLAG_MASK=7`）：

- `IS_FREE=1`：空闲
- `PREV_FREE=2`：前一物理块空闲
- `RC_BIT=4`：RC 块标记

RC 块：`[header][RC][flags][data...][footer]`，5*PTR_SIZE 开销，`free()` 读 `ptr-PTR_SIZE` flags 判断。

### 7.2 tier

- TINY <=1024
- SMALL <=4096
- MIDDLE <=65536
- LARGE <=262144，brk 分配，释放后若非堆顶则 `insertFreeList`；但 `freeListClassOf>=60` 会被丢弃（只能靠 coalesce/trim/top 回收）
- HUGE >262144，brk 分配，不入 free list

### 7.3 trim 限制

`memory.trim()` 只回缩堆顶连续空闲块：

1. 读 `brk(0)-8` footer 得到 `pure`
2. `blk = top-pure`，检查 `hdr IS_FREE`
3. `removeFreeList(blk)`，`syscall.brk(blk)`

任何非 free 块或错误 footer（如 pure==0）都会停住。中部 free 块 pin 住 heap。

### 7.4 commit 尾块

`commit(cls, blkSize)` 扩 brk CHUNK_SIZE 并切块。尾部剩余 <32 时并入前块，>=32 时初始化为合法 free block 并入链。若尾部不初始化，会留下 0 footer，`trim` 看到 `pure==0` 提前停。

### 7.5 tracker 开销

`pkg/memory/tracker.cute`：

- `initAllLeakTracker()` raw brk 分配 `65536 + PTR_SIZE*2 = 65552` 字节表，设置 header/footer，不走 trackAllocAll。
- `initLeakTracker()` 也是 64KB。

这两个表是基础设施，不是业务泄漏；但会表现为 heap scan 中 `allocN+1 allocB+65552 tracked=0`。需要“main 结束堆尽量空”时调用：

```cute
memory.releaseAllLeakTracker()
memory.releaseLeakTracker()
memory.trim()
```

必须在最后分配之后调用。之后任何 `trackAllocAll` 会重新 init tracker。

## 8. 典型根因与判据

| 现象 | 判据 | 常见根因 |
|---|---|---|
| leaks>0 | reportAllLeaks 非 0 | 用户对象未释放、LLR early return、alias/RetUnknown 导致不可 free |
| leaks==0, heap 高, top free 但 trim 停 | top footer pure==0 或坏 | commit 尾块未初始化、堆元数据损坏 |
| leaks==0, allocN==1, 大块 tracked==0 | dumpAllocator 显示 pinned block | tracker 表本身；或未跟踪分配；或 trackFreeAll/heap 不一致 |
| leaks==0, allocN>0, tracked==1 | live tracked alloc | 真泄漏但 reportAllLeaks 口径/时机有误；或 RC/allocator 路径差异 |
| cutebuild 结果与手编不同 | 用了旧 `./cuteify2` | Go 代码改了没重建 cuteify2 |

## 9. 本次定位到的实际问题

1. **`gc/analyze.go`**：内建数值/标量 cast 被当未知调用写入 `CallsAny`，`ComputeLLR` early return，handleNumber 等函数无 LLR frees。修复：`pureBuiltinEscapes` 放行 `int/uint/i8..u64/f32/f64/bool/byte/ptr`。
2. **`pkg/strings/strings_common.cute`**：`replaceAll` 在 `oLen==0` 时 `ret s`，造成 alias 返回、LLR 无法证明可释放。修复：返回 `strings.clone(s)`。
3. **`pkg/memory/allocator.cute` commit 尾块**：剩余空间未初始化合法 header/footer，`trim` 遇 0 footer 停止。修复：tail>=32 入链，tail<32 并入前块。
4. **`pkg/memory/tracker.cute` 64KB 表驻留**：`initAllLeakTracker/initLeakTracker` raw brk 64KB，非泄漏但 pin heap。修复/缓解：新增 `releaseAllLeakTracker()/releaseLeakTracker()`。
5. **调试接口**：新增 `memory.dumpAllocator()`、`memory.trim()`。

## 10. 调试时不要踩的坑

- 不要把 `dumpAllocator()` 放在 leak 计数采样区间内；它会 malloc/free。
- 不要在 release tracker 后再做会分配的打印/字符串转换，除非你接受 tracker 重新初始化。
- gdb batch 嵌套 `commands` 要小心；优先用脚本文件。
- /tmp 可能脏满；构建用 `TMPDIR=/tmp/opencode`，并清理临时 workdir。
- 不要改 `selfhost/cmd/parsedump/main.cute` 用户 instrumented 文件；复制到 /tmp。
- SIG 现场先 `ulimit -Sc 0`。
