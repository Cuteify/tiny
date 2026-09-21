# CLAUDE.md

## Project Overview
Cuteify (Cute) is a systems programming language compiler targeting x86/x86_64 Linux. It compiles `.cute` source files to NASM assembly, links with `ld`, and produces native ELF binaries.

## Build & Run
```bash
# Build compiler
go build -o cuteify2 .

# Compile and run a test
./test_run.sh test/<testname> x86        # x86 mode
./test_run.sh test/<testname> x86_64     # x86_64 mode

# Run all tests
./test_run.sh
```

## Syntax Reference
- **No package declaration** in `.cute` files
- `//` comments ARE supported
- **No `import` keyword** — use `configure Imports` in `package.json`
- `fn` for functions, `ret` for return
- `for ; condition; {` (no `for init; cond; step`)
- No variadic `...T` — use arrays
- `nil` keyword for null pointers
- Number literals are `int`; `int * uint` NOT supported — reorder to `ptrSize * N`
- Array indexing: `arr[i] = v` works for globals

## Key Architecture

### Name Mangling
`FuncBlock.MangledName()` → `funcName__type1__type2`. Use for all function references in asm.

### Memory Allocator v3
- 5 tiers: TINY (≤1024B), SMALL (≤4096B), MIDDLE (≤65536B), LARGE (≤262144B), HUGE (>262144B)
- Block header: `[size_raw | FLAG_MASK=0x3]` at `blk - ptrSize`; footer at `blk + blkSize - ptrSize`
- RC blocks: header + RC field + flags field + data + footer (5×ptrSize overhead)
- `ptrSize` env var: use `ptrSize` in Cute, `strconv.Itoa(context.Sizeof(&zero))` in Go

### GC System (LLR Analysis)
- **No borrow mechanism** — ownership inferred by heap-origin + LLR liveness
- `*T` = owning pointer (default); `&local` = borrowed
- `emitGCFrees()` reads `gc.LLRResults` (not old `gc.Plans`)
- `isOwning()` returns true for `*T` struct pointers (not just `string`/`list`)

### LLR Object Lifecycle
- `FRAME_OWN` = local alloc, freed at function exit
- `ESCAPED` = passed to caller/global, not freed locally
- `null_init` = `var x: *T = nil` binding, tracked for later reassignment
- `orphans` = old objects when variable is reassigned

### Pointer Types
- `ptr` = raw address (not owning, `IsPointer()=false`)
- `*T` = typed pointer (owning, `IsPointer()=true`)
- Struct fields like `left: *Node` enable GC tracking; `left: ptr` does not

## Environment
- `/usr/bin/nasm`, `/usr/bin/ld`, `/usr/bin/gcc`
- Disk: `/tmp` 80% full; use `TMPDIR=$(pwd)/.tmp` for `go build`
- **User directive: use /tmp for temp files**
- `CUTE_ARCH` env var: `preFilterBuild()` reads it (defaults `"x86"` if empty)

## User Directives
- **多用SubAgent** (use Task agents for parallel work)
- **应编写项目文档避免SubAgent重复探索**

## Test Harness
- `./test_run.sh <testdir> [arch...]` — builds, assembles, links, runs
- Many tests return meaningful non-zero exit codes as success
- 38+ "failures" are actually passing tests with non-zero success codes

## Stack Alignment (ABI requirement)
- **x86_64 prologue**: 编译期计算 padding 加到 `StackSize`，`sub rsp, N` 一步到位（N 已是 16 的倍数）
- **x86_64 epilogue**: `add rsp, StackSize` 清理（含 padding），然后 pop callee-saves，`leave; ret`
- **x86 prologue/epilogue**: No alignment needed (cdecl requires 4-byte, naturally maintained)
- **`buildExtSysV`**: No extra alignment (prologue handles it)
- **`buildExtCdecl`**: Uses `mov edx, esp; and esp, -16; call; mov esp, edx` (x86 only, prologue doesn't align)
- **`build asm` blocks**: User must add `and rsp, -16` manually before C calls (compiler cannot parse raw asm)

## Agent Execution Rules
**每次启动时必须执行：**
1. 读取 `PLAN_rcDebug.md` — 当前活跃的修复计划
2. 读取 `TODO_rcDebug.md` — 当前活跃的任务列表
3. 按 TODO 中的 Phase 顺序逐步执行
4. 完成一个 Phase 后更新 TODO 状态（`[x]` 标记完成）
5. 遇到阻塞时在 TODO 中记录阻塞原因

**计划文件说明：**
- `PLAN_rcDebug.md` — 修复 test/rcLeak segfault 的详细计划和根因分析
- `TODO_rcDebug.md` — 可执行的任务列表，按 Phase 分组

## Critical Fixes Applied
8. `blkSizeOfTiny()` alignment — Block sizes from the TINY tier (classes 1-33) were NOT multiples of 8 (e.g., class 13 → 289 bytes). This caused `hdrSetFooter` and the next block's header to overlap, corrupting memory and segfaulting in `coalesce()`. Fixed by rounding up: `ret (s + ptrSize - 1) & ~(ptrSize - 1)`. (memory.cute:35)
1. `isOwning()` — returns true for `*T` struct pointers (analyze.go:311)
2. `HasHeapAllocs` propagation — via `applyCallee()` + `ReturnBlock` walkExprCalls
3. `hasRealAnyCalls()` — filters empty strings from `CallsAny` (llr.go)
4. `ReturnBlock` LLR `markCallArgObjExpr` — propagates argument escape for nested calls in return
5. `processAssign` null_init binding — `var tree: *Node = nil` creates tracked binding
6. `emitGCFrees` — reads `gc.LLRResults` instead of old `gc.Plans`
7. ~~`Assign` orphan free~~ **REVERTED** — orphan-free at assignment sites was fundamentally wrong: can't distinguish locally-allocated vs parameter-passed values at compile time. Old code would `free(head)` when doing `c = c.next` where `c` came from a parameter. Function-exit GC via LLR `emitGCFrees()` handles cleanup correctly for FRAME_OWN variables.
