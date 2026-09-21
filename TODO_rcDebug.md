# TODO: 修复 rcLeak segfault（按优先级排序）

## 当前阻塞
- [ ] **Phase 1: 理解 mallocRC 块布局**
  - [ ] 读 `mallocRC()` 生成的汇编，确认块布局：header → RC → flags(IS_RC_TAG) → data
  - [ ] 读 `freeAt()` / `coalesce()` 生成的汇编，确认它们期望的块布局
  - [ ] 对比两者是否兼容（关键：`hdrSizeRaw(blk)` 读的是 malloc 的 header，不是 mallocRC 的 RC 字段？）

- [ ] **Phase 2: 添加调试 println 定位崩溃**
  - [ ] 在 `free()` 中加 println：打印 ptr 值和 flagLoad 结果
  - [ ] 在 `coalesce()` 入口加 println：打印 blk 和 header 值
  - [ ] 在 `removeFreeList()` 加 println：打印 prev 值
  - [ ] 编译运行，根据最后输出定位崩溃点

- [ ] **Phase 3: 修复堆损坏根因**
  - [ ] 根据 Phase 2 定位结果修复
  - [ ] 可能的修复方向：
    a. mallocRC 的 header 格式与 allocator 不兼容 → 调整 mallocRC 布局
    b. free() 的 flagLoad 误判 → 改用更可靠的检测方式
    c. freeAt() 的块地址计算错误 → 修正 ptr 偏移

- [ ] **Phase 4: 修复 store64 第二参数 bug**
  - [ ] `collectValues` 中 `store64(buf + idx*8, node.value)` 生成的汇编把 `idx*8` 当作 node.value
  - [ ] `inorder` 中同样的 bug
  - [ ] 根因：编译器 expression evaluation 在地址计算后复用了 RAX，没有重新加载 node.value

- [ ] **Phase 5: 全量回归测试**
  - [ ] test/rcLeak x86_64 → exit 不再是 139
  - [ ] test/rcSimple x86/x86_64 → 通过
  - [ ] test/rcTracking x86_64 → 通过
  - [ ] test/gcStructFree x86/x86_64 → 通过
  - [ ] ./test_run.sh 全量 → 无回归

## 参考
- 详细计划见 PLAN_memory_cleanup.md（Phase 0）
- 旧计划见 PLAN_rcDebug.md
- CLAUDE.md 中的 memory allocator v3 和 GC 系统文档
