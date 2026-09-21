# Cuteify GC/RC 编译期所有权分析 — 理论最优解

## 一、当前系统架构

### LLR 分析追踪的概念
| 概念 | 字段 | 作用 |
|------|------|------|
| **FRAME_OWN** | `frameOwn = !escaped && !isParamObj` | 局部分配，函数退出时自动释放 |
| **ESCAPED** | `objEscaped[objID] = true` | 逃逸到外部，不在本函数释放 |
| **null_init** | `site = "null_init"` | `var x: *T = nil` 绑定，跟踪后续赋值 |
| **orphans** | `orphans []ObjID` | 被重新赋值覆盖的旧对象 |
| **fieldOrphans** | `fieldOrphans []fieldOrphan` | 被赋值覆盖的旧字段值 |

### 当前释放机制
1. **`emitGCFrees`** — 函数出口释放所有 FRAME_OWN 变量
2. **`emitBlockFrees`** — 块级释放（for/if 块内分配的对象）
3. **`free()` 运行时检测** — 读 flags 字段区分 malloc/mallocRC 块

---

## 二、测试结果（gcOwnership 测试）

### LLR 分析输出
| 函数 | 对象 | 标记 | 释放方式 |
|------|------|------|----------|
| `testLocalAlloc` | a, b, c | FRAME_OWN | FREE + FIELD_FREE |
| `testLoopAlloc` | tmp | FRAME_OWN (scope=1) | block free (循环内) + function free (函数出口) |
| `testListWalk` | — | — | 无释放（参数指针）✅ |
| `testFieldOrphan` | root, b1, b2, b3 | FRAME_OWN | FREE + FIELD_FREE |
| `testNestedAlloc` | a, b, c | FRAME_OWN (call:makeBox) | FREE + FIELD_FREE |
| `testBranchAlloc` | n | FRAME_OWN (scope=1) | block free + function free |
| `testMassiveLoop` | tmp | FRAME_OWN (scope=1) | block free + function free |
| `testLeakDetection` | tmp | FRAME_OWN (scope=1) | block free + function free |

### 关键发现
1. **LLR 分析正确** — 所有局部 `new()` 分配都被标记为 FRAME_OWN
2. **emitGCFrees 正确** — 函数出口生成 `call std_memory_free__ptr`
3. **emitBlockFrees 正确** — 循环体内生成 block free
4. **Bug: 双重释放** — block free + function free 导致同一对象被释放两次

---

## 三、理论最优解分析

### 场景 1: 局部 *T 分配，永不逃逸
```cute
fn build() *Node {
    var node: *Node = new(Node)
    node.left = new(Node, 2, nil, nil)
    node.right = new(Node, 3, nil, nil)
    ret node
}
```
**编译期可证明**: `node.left` 和 `node.right` 是局部 alloc，未逃逸
**最优 emit**: 函数出口 `free(node.left)`, `free(node.right)` — **已实现** ✅

### 场景 2: 循环内重复分配（最经典的泄漏场景）
```cute
fn process() {
    var i: int = 0
    for ; i < 10; {
        var tmp: *Node = new(Node)
        tmp.val = i
        i = i + 1
    }
}
```
**编译期可证明**: `tmp` 是局部 alloc，每次循环迭代结束时 orphan
**最优 emit**: 循环体末尾 `free(tmp)` — **已实现** ✅ (emitBlockFrees)
**Bug**: 函数出口又重复释放了 tmp — **需要修复** ⚠️

### 场景 3: 链表遍历（c = c.next 模式）
```cute
fn walk(head: *Node) {
    var c: *Node = head
    for ; c != nil; {
        c = c.next
    }
}
```
**编译期可证明**: `c` 来自参数 `head`，不是局部 alloc
**最优 emit**: 不释放 — **已实现** ✅ (isParamObj 检查)

### 场景 4: 字段赋值产生 orphan
```cute
fn process() {
    var root: *Box = new(Box)
    var b1: *Box = new(Box)
    root.child = b1      // 无 orphan（nil）
    var b2: *Box = new(Box)
    root.child = b2      // orphan: b1
}
```
**编译期可证明**: `b1` 是局部 alloc，被 `b2` 覆盖
**最优 emit**: 赋值点 `free(b1)` — **未实现** ⚠️ (orphan-free 已回退)
**当前行为**: 函数出口释放 root, b1, b2 — 正确但延迟

### 场景 5: 函数调用链返回值
```cute
fn makeBox(v int) *Box {
    var b: *Box = new(Box)
    b.data = v
    ret b  // b 逃逸
}
fn caller() {
    var a: *Box = makeBox(1)
    var b: *Box = makeBox(2)
}
```
**编译期可证明**: `a`, `b` 是局部 alloc（site=call:makeBox），未逃逸
**最优 emit**: 函数出口 `free(a)`, `free(b)` — **已实现** ✅

### 场景 6: 条件分支分配
```cute
fn pick(flag: int) int {
    var result: *Node
    if flag == 1 {
        var n: *Node = new(Node)
        n.val = 100
        result = n
    } else {
        var n: *Node = new(Node)
        n.val = 200
        result = n
    }
    ret result.val
}
```
**编译期可证明**: 每个分支的 `n` 是局部 alloc，scope=1
**最优 emit**: 分支块末尾 `free(n)` — **已实现** ✅ (emitBlockFrees)
**Bug**: 函数出口又释放了 n — **需要修复** ⚠️

---

## 四、已识别的 Bug

### Bug 1: 双重释放（block free + function free）
**现象**: `testLoopAlloc` 中 `tmp` 在循环体内被 block free，函数出口又被 function free
**原因**: `emitGCFrees` 不检查变量是否已在块级释放
**影响**: 双重释放可能导致内存损坏
**修复方案**: 在 `emitGCFrees` 中跳过已在 `BlockFreesMap` 中释放的变量

### Bug 2: field orphan 只释放最后一个
**现象**: 多次赋值 `root.child`，只有最后一个 orphan 被释放
**原因**: `fieldOrphans` 按 `varName.fieldName` 去重，只保留最后一个
**影响**: 中间的 orphan 泄漏
**修复方案**: 保留所有 field orphan，或在赋值点即时释放

---

## 五、理论最优 vs 当前实现

| 场景 | 理论最优 | 当前实现 | 差距 |
|------|----------|----------|------|
| 局部分配不逃逸 | 函数出口 free | ✅ emitGCFrees | 无 |
| 循环内分配 | 循环体 free | ✅ emitBlockFrees | 无（但有 double-free bug）|
| 参数指针遍历 | 不释放 | ✅ isParamObj | 无 |
| 字段赋值 orphan | 赋值点 free | ⚠️ 函数出口 free | 延迟释放（正确但非最优）|
| 函数返回值 | 接收方 free | ✅ FRAME_OWN | 无 |
| 条件分支 | 分支块 free | ✅ emitBlockFrees | 无（但有 double-free bug）|
| newRC() 单所有者 | 降级为 new() | ❌ 未实现 | 可节省 3×ptrSize 开销 |

---

## 六、建议的优化路径

### 优先级 1: 修复 double-free bug
在 `emitGCFrees` 中维护一个 `freedVars` 集合，跳过已在块级释放的变量。

### 优先级 2: 恢复 orphan-free（带修正）
在 `Assign()` 中，对于 `isThisField` 和 `needPtrMem` 路径，检查旧值是否为 FRAME_OWN，如果是则在赋值点 `free` 旧值。

### 优先级 3: newRC() 降级优化
在整个程序分析中，如果 `newRC()` 对象从未逃逸且 RC 始终为 1，降级为 `new()`，节省 3×ptrSize 开销。

### 优先级 4: 跨过程分析
如果函数 A 创建对象并传给函数 B，且 B 从未使用该对象，A 可以证明 B 不会持有引用，直接 free。
