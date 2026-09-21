# PLAN: 修复 test/rcLeak segfault

## 问题现状
- `test/rcLeak` 在 x86_64 上 segfault（exit=139）
- 崩溃位置：`coalesce` → `removeFreeList` → `freeSetNext` → `store64` 写入地址 0x50（无效地址）
- `test/rcSimple` 通过（exit=12），`test/rcTracking` 通过（exit=42）
- `IS_RC_TAG` 常量、`mallocRC()` 写入 flags、`free()` 运行时检测均已实现

## 根因分析

### Bug 1: store64 第二参数错误（代码正确性问题）
- **位置**: `collectValues` 和 `inorder` 函数中 `memory.store64(buf + idx*8, node.value)`
- **现象**: 生成的汇编把 `idx*8`（地址计算的中间结果）作为第二个参数传入 store64，而非 `node.value`
- **影响**: 写入错误值（但不会 segfault，因为写入地址合法）
- **根因**: 编译器在生成 `store64(arg0, arg1)` 调用时，arg0 的计算复用了 RAX，arg1 的求值没有重新加载 node.value 到 RAX

### Bug 2: 堆元数据损坏（segfault 根因）
- **位置**: `coalesce` → `removeFreeList` 时读到错误的 prev 指针（0x48）
- **影响**: `freeSetNext(0x48, next)` → `store64(0x50, next)` → segfault
- **可能原因**:
  a. mallocRC 分配的块布局与 allocator 的 `hdrSizeRaw`/`hdrSetFooter` 不兼容
  b. `free()` 的 `flagLoad` 误判，导致错误路径调用 `freeAt`
  c. orphan-free 对 mallocRC 指针调用 `free()` → `rcDec()` → `freeRC()` → `freeAt()` 的链路中块地址计算错误

## 修复计划

### Phase 1: 验证 mallocRC 块布局兼容性
1. 检查 `mallocRC(size)` 分配的块布局是否与 allocator 的 `hdrSizeRaw`/`hdrSetFooter`/`coalesce` 逻辑兼容
2. 确认 mallocRC 内部调用 `malloc()` 时，`hdrSetSizeRaw` 和 `hdrSetFooter` 写入的 header/footer 位置正确
3. 确认 `freeRC(ptr)` 调用 `freeAt(ptr - 3*ptrSize)` 时，`blk` 地址正确指向 header

### Phase 2: 添加调试输出定位崩溃点
1. 在 `free()` 函数中添加 `println` 输出：打印 ptr、flagLoad 结果、是否走 RC 路径
2. 在 `coalesce` 入口添加 `println`：打印 blk、hdrSizeRaw、prevFooter
3. 在 `removeFreeList` 添加 `println`：打印 prev、next
4. 编译运行，根据最后一条输出定位崩溃的具体调用

### Phase 3: 修复找到的 bug
1. 根据调试输出确定是哪个分配/释放操作导致堆损坏
2. 修复块地址计算或 flag 检测逻辑
3. 重新运行 test/rcLeak 验证

### Phase 4: 修复 store64 参数 bug
1. 修复 `collectValues` 和 `inorder` 中 store64 第二参数错误
2. 确保 `node.value` 在地址计算后重新加载到正确的寄存器

### Phase 5: 全量回归测试
1. 运行 test/rcLeak x86_64 → exit 不再是 139
2. 运行 test/rcSimple x86/x86_64 → 仍然通过
3. 运行 test/rcTracking x86_64 → 仍然通过
4. 运行 test/gcStructFree x86/x86_64 → 仍然通过
5. 运行 test_run.sh（全部测试）确认无回归

## 关键文件
- `pkg/memory/memory.cute` — free(), mallocRC(), freeRC(), freeAt(), coalesce()
- `pkg/memory/memory_x86_64.cute` — store64(), load64(), hdrSizeRaw(), hdrSetFooter()
- `test/rcLeak/main.cute` — 测试文件
- `compile/exp/exp.go` — builtinNewRC(), emitMallocRC(), Assign orphan-free
- `compile/gc/llr.go` — objRCAlloc tracking
- `_main.asm` — 生成的汇编（调试用）

---

> **注意**: 本计划已合并到 `PLAN_memory_cleanup.md` 的 Phase 0，以下为原始记录。
