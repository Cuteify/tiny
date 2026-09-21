# PLAN: 内存管理器系统整理 + rcLeak 修复

> 基于 DOC_memory_gc.md 为准，不重写，系统整理

---

## 背景

以 `DOC_memory_gc.md` 为权威文档，CLAUDE.md 中的内存分配器描述已过时需修正。
当前内存管理代码存在死代码、bug、职责混乱等问题，需要系统整理。

### 参考文档
- `DOC_memory_gc.md` — 权威设计文档
- `PLAN_rcDebug.md` — test/rcLeak segfault 修复计划（本计划包含）

---

## Phase 0: 修复 rcLeak segfault（最高优先级）

> 从 PLAN_rcDebug.md 合并，test/rcLeak 在 x86_64 上 exit=139 阻塞所有 RC 测试

### 0.1 验证 mallocRC 块布局兼容性
- **文件**: `pkg/memory/memory.cute` — `mallocRC()`, `freeRC()`, `freeAt()`, `coalesce()`
- **检查项**:
  1. `mallocRC(size)` 分配的块布局是否与 allocator 的 `hdrSizeRaw`/`hdrSetFooter`/`coalesce` 兼容
  2. `mallocRC` 内部调用 `malloc()` 时，`hdrSetSizeRaw` 和 `hdrSetFooter` 写入的 header/footer 位置正确
  3. `freeRC(ptr)` 调用 `freeAt(ptr - 3*ptrSize)` 时，`blk` 地址正确指向 header

### 0.2 添加调试输出定位崩溃点
- **文件**: `pkg/memory/memory.cute`
- **操作**:
  1. 在 `free()` 中加 `println`：打印 ptr 值和 flagLoad 结果
  2. 在 `coalesce()` 入口加 `println`：打印 blk 和 header 值
  3. 在 `removeFreeList()` 加 `println`：打印 prev 值
  4. 编译运行，根据最后输出定位崩溃点

### 0.3 修复堆损坏根因
- **可能方向**:
  a. mallocRC 的 header 格式与 allocator 不兼容 → 调整 mallocRC 布局
  b. free() 的 flagLoad 误判 → 改用更可靠的检测方式
  c. freeAt() 的块地址计算错误 → 修正 ptr 偏移

### 0.4 修复 store64 第二参数 bug
- **文件**: `compile/exp/exp.go` — `collectValues`, `inorder`
- **问题**: `store64(buf + idx*8, node.value)` 生成的汇编把 `idx*8` 当作 node.value
- **根因**: 编译器 expression evaluation 在地址计算后复用了 RAX，没有重新加载 node.value

### 0.5 验证
- [ ] test/rcLeak x86_64 → exit 不再是 139
- [ ] test/rcSimple x86/x86_64 → 通过
- [ ] test/rcTracking x86_64 → 通过
- [ ] test/gcStructFree x86/x86_64 → 通过

---

## Phase 1: 清理死代码 + 修复其他 bug（高优先级）

### 1.1 ~~删除 freeplan.go 死代码~~ ✅ 已完成
- **文件**: `compile/gc/freeplan.go`（394 行）— 已删除
- **操作**:
  1. ✅ 删除 `compile/gc/freeplan.go`
  2. ✅ 删除 `compile/gc/analyze.go` 的 `PlanFrees(root)` 调用
  3. ✅ 保留 `hasRealAnyCalls` / `allocSiteDesc` / `DumpFrees` 迁移至 `llr.go`
  4. ✅ 删除 `gc.FreePlan` / `gc.FreeVar` / `gc.Plans` / `gc.freeScan` 等类型和变量
  5. ✅ 编译通过，rcSimple / gcStructFree 测试无回归
  6. ✅ 更新 PROJECT.md 目录树和已知问题

### 1.2 修复 isGlobalTarget 恒返回 false
- **文件**: `compile/gc/llr.go:731-739`
- **原因**: `isGlobalTarget()` 永远返回 false，导致全局变量赋值不会触发孤儿 free
- **当前代码**:
  ```go
  func isGlobalTarget(name string, fb *parser.FuncBlock) bool {
      return false
  }
  ```
- **修复方案**: 需要检查变量是否被赋值到全局变量
  ```go
  func isGlobalTarget(name string, fb *parser.FuncBlock) bool {
      // 检查 name 是否在函数体中被赋值给全局变量
      // 遍历 AST 查找 IsGlobal 的 VarBlock
      // 如果找到 name = global_var 的赋值，返回 true
  }
  ```
- **验证**: 运行 test/rcLeak 测试

### 1.3 修复 emitGCFrees x86 双重栈清理
- **文件**: `compile/compiler.go:1227-1229`
- **原因**: `Cdecl.Call(freeCall)` 内部已有 `add esp, 4`，外部又加了一次
- **当前代码**:
  ```go
  } else {
      code += utils.Format("push " + slot + " [" + base + strconv.Itoa(off) + "]")
      code += c.Ctx.Arch.Call(freeCall)
      code += utils.Format("add esp, 4")   // ← 多余
  }
  ```
- **修复方案**: 删除多余的 `add esp, 4`
- **验证**: 运行 x86 测试，检查生成的汇编中 free 调用后的栈清理

### 1.4 修正 CLAUDE.md 中的内存分配器描述
- **文件**: `CLAUDE.md:35-38`
- **当前描述（错误）**:
  ```
  ### Memory Allocator v3
  - 5 tiers: TINY (≤256B), SMALL (≤4KB), MIDDLE (≤64KB), LARGE (≤1MB), HUGE (brk)
  - Block header: `[size_raw | FLAG_MASK=0x7]` at `blk - ptrSize`; footer at `blk + blkSize - 2*ptrSize`
  - `ptrSize` env var: use `ptrSize` in Cute, `strconv.Itoa(context.Sizeof(&zero))` in Go
  ```
- **修正为（以 DOC_memory_gc.md 为准）**:
  ```
  ### Memory Allocator v3
  - 5 tiers: TINY (≤1024B), SMALL (≤4096B), MIDDLE (≤65536B), LARGE (≤262144B), HUGE (>262144B)
  - Block header: `[size_raw | FLAG_MASK=0x3]` at `blk - ptrSize`; footer at `blk + blkSize - ptrSize`
  - RC blocks: header + RC field + flags field + data + footer (5×ptrSize overhead)
  - `ptrSize` env var: use `ptrSize` in Cute, `strconv.Itoa(context.Sizeof(&zero))` in Go
  ```
- **注意**: 删除 "RC side-table: `gRCTable[4096]`" 的描述（实际是嵌入式 RC，无 side-table）

---

## Phase 2: 代码拆分（中优先级）

### 2.1 拆分 memory.cute
当前 `memory.cute` 承载 7 种职责（约 680 行），建议拆分为：

#### `allocator.cute` — 分配器核心
- `malloc(size: uint) ptr`
- `freeAt(blk: ptr)`
- `realloc(ptr: ptr, newSize: uint) ptr`
- `coalesce(blk: ptr) ptr`
- `commit(cls: uint, blkSize: uint) ptr`
- `removeFreeList(blk: ptr)`
- `insertFreeList(blk: ptr)`
- 空闲链表操作: `freeNext`, `freeSetNext`, `freePrev`, `freeSetPrev`
- 块头操作: `hdrSizeRaw`, `hdrSetSizeRaw`, `hdrSetFooter`, `hdrFooter`
- 常量: `TINY_MAX`, `SMALL_MAX`, `MIDDLE_MAX`, `LARGE_MAX`, `CHUNK_SIZE`, `IS_FREE`, `PREV_FREE`, `FLAG_MASK`, `HDR_SIZE`
- 全局变量: `gFreeHeads[60]`

#### `rc.cute` — 引用计数管理
- `mallocRC(size: uint) ptr`
- `freeRC(ptr: ptr)`
- `rcInc(p: ptr)`
- `rcDec(p: ptr) bool`
- `rcGet(p: ptr) uint`
- `rcSet(p: ptr, n: uint)`
- `rcAdd(p: ptr, n: uint)`
- `rcSub(p: ptr, n: uint) bool`
- `rcTryRelease(p: ptr) bool`
- `rcIsOne(p: ptr) bool`
- 常量: `IS_RC_TAG`

#### `tracker.cute` — 泄漏追踪
- `trackAlloc(p: ptr)`
- `trackFree(p: ptr)`
- `reportLeaks() uint`
- `reportAllocCount() uint`
- `reportFreeCount() uint`
- `resetLeakTracker()`
- 全局变量: `gAllocCount`, `gFreeCount`, `gLeaks[256]`, `gLeakCount`

#### `memops.cute` — 内存操作
- `memcpy(dest: ptr, src: ptr, n: uint) ptr`
- `memset(s: ptr, c: u8, n: uint) ptr`

### 2.2 更新 package.json
- 更新 `pkg/memory/package.json` 中的依赖声明
- 确保新文件被正确包含

### 2.3 验证
- 编译通过
- 运行所有测试无回归
- 生成的汇编与拆分前一致

---

## Phase 3: 文档补充（低优先级）

### 3.1 补充 IS_RC_TAG 碰撞风险到 DOC_memory_gc.md
- **位置**: `DOC_memory_gc.md:9` 常量定义部分
- **内容**:
  ```
  ### 9.7 IS_RC_TAG 与合法 block size 碰撞（已知限制）
  
  `IS_RC_TAG = 98304 (0x18000)` 用于 `free()` 运行时区分 malloc/mallocRC 块。
  但 LARGE 块的 header 直接存储 `aligned` 值（清除 flag 后），当用户分配
  98288 字节时，`req = 98304 = IS_RC_TAG`，`free()` 会错误识别为 RC 块。
  
  **当前状态**: 理论风险，实际使用中极少触发（需要分配恰好 98288 字节）。
  **修复方案**: 使用不在合法 size 范围内的 magic number，或改用 flag 位的高位标记。
  ```

### 3.2 补充 LARGE/MIDDLE 块 brk 顶部释放限制到 DOC_memory_gc.md
- **位置**: `DOC_memory_gc.md:230-237` 释放流程部分
- **内容**:
  ```
  ### 2.10 已知限制：LARGE/MIDDLE 块仅在 brk 顶部时释放
  
  `freeAt()` 对 LARGE/MIDDLE 块的处理：
  ```
  if pure > LARGE_MAX {
      if blk + pure == cur:    // 只有在 brk 最顶端才释放
          syscall.brk(blk)
      ret                      // 否则直接泄漏
  }
  ```
  
  **影响**: 大块分配后如果有其他分配在其后，无法回收。
  **当前状态**: 已知限制，不影响正常使用（大多数分配是 TINY/SMALL）。
  **修复方案**: 需要实现空闲块合并后的 brk 收缩逻辑。
  ```

### 3.3 更新 CHANGES.md
- 记录 Phase 1 和 Phase 2 的变更

---

## 验证清单

### Phase 0 验证（rcLeak）
- [ ] 编译通过: `go build -o cuteify2 .`
- [ ] mallocRC 块布局与 allocator 兼容
- [ ] test/rcLeak x86_64 → exit 不再是 139
- [ ] test/rcSimple x86/x86_64 → 通过
- [ ] test/rcTracking x86_64 → 通过
- [ ] test/gcStructFree x86/x86_64 → 通过
- [ ] store64 第二参数 bug 已修复

### Phase 1 验证
- [x] 编译通过: `go build -o cuteify2 .`
- [x] 删除 freeplan.go 后编译通过
- [x] 删除 PlanFrees() 调用后编译通过
- [ ] 运行 test/rcLeak x86_64 → exit 不再是 139
- [x] 运行 test/rcSimple x86/x86_64 → 仍然通过
- [ ] 运行 test/rcTracking x86_64 → 仍然通过
- [x] 运行 test/gcStructFree x86/x86_64 → 仍然通过
- [ ] 运行 test_run.sh（全部测试）确认无回归
- [ ] 检查 x86 生成的汇编中 free 调用后无双重 `add esp`

### Phase 2 验证
- [ ] 编译通过: `go build -o cuteify2 .`
- [ ] 运行 test_run.sh（全部测试）确认无回归
- [ ] 生成的汇编与拆分前一致（diff 检查）

### Phase 3 验证
- [ ] DOC_memory_gc.md 更新内容准确
- [ ] CLAUDE.md 更新内容准确
- [ ] CHANGES.md 记录变更

---

## 风险评估

| 操作 | 风险 | 缓解措施 |
|---|---|---|
| 删除 freeplan.go | 低（死代码） | 编译验证 + 测试 |
| 修复 isGlobalTarget | 中（可能引入新 bug） | 运行 rcLeak 测试 |
| 修复 emitGCFrees | 低（简单删除） | 检查生成的汇编 |
| 拆分 memory.cute | 中（可能遗漏依赖） | 编译验证 + 测试 |
| 更新文档 | 无 | 对照 DOC_memory_gc.md |

---

## 时间估算

| Phase | 预估时间 |
|---|---|
| Phase 0 (rcLeak) | 2-4 小时 |
| Phase 1 | 1-2 小时 |
| Phase 2 | 1-2 小时 |
| Phase 3 | 30 分钟 |
| **总计** | **4.5-8.5 小时** |
