# Cuteify 内存管理与 GC 系统完整文档

> 从设计哲学到汇编实现的全面解析

---

## 目录

1. [设计总览](#1-设计总览)
2. [内存分配器 v3](#2-内存分配器-v3)
3. [引用计数（RC）系统](#3-引用计数rc系统)
4. [双分配路径：new(T) vs newRC(T)](#4-双分配路径newt-vs-newrct)
5. [静态 GC 分析（LLR）](#5-静态-gc-分析llr)
6. [编译器代码生成](#6-编译器代码生成)
7. [泄漏追踪器](#7-泄漏追踪器)
8. [内存布局图解](#8-内存布局图解)
9. [已知问题与限制](#9-已知问题与限制)

---

## 1. 设计总览

### 1.1 核心设计哲学

```
所有权优先 → 引用计数补充 → 仅全局使用 RC
```

- **所有权（Ownership）**：编译器通过 LLR（Lazy Life Range）分析推断指针的生命周期。帧内分配、不逃逸的指针在函数出口自动释放（`free()`）。
- **引用计数（RC）**：当指针需要跨函数/全局共享时，使用 `newRC(T)` 分配带 RC 头的对象，通过手动 `rcInc`/`rcDec` 管理生命周期。
- **无借用机制**：不引入 borrow checker，所有权完全由编译器推断 + 用户显式选择分配方式决定。

### 1.2 组件关系

```
┌─────────────────────────────────────────────────────────┐
│                    编译器（Go）                           │
│                                                         │
│  ┌───────────┐   ┌──────────┐   ┌───────────────────┐  │
│  │ 语法分析   │──→│ LLR 分析  │──→│ 代码生成          │  │
│  │ parser     │   │ gc/llr.go │   │ compiler/exp.go   │  │
│  └───────────┘   └──────────┘   └───────────────────┘  │
│                       │                    │             │
│                  ┌────┘                    └────┐        │
│                  ▼                              ▼        │
│           ┌──────────┐                  ┌──────────┐    │
│           │ 逃逸分析  │                  │ 释放指令  │    │
│           │ analyze.go│                  │ 生成      │    │
│           └──────────┘                  └──────────┘    │
└─────────────────────────────────────────────────────────┘
                         │
                         │ 编译输出
                         ▼
┌─────────────────────────────────────────────────────────┐
│              运行时库（Cute → NASM → ELF）                │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │              memory.cute                          │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────┐   │   │
│  │  │ malloc   │  │ mallocRC │  │ free/freeRC  │   │   │
│  │  │ freeAt   │  │ rcInc    │  │ rcDec        │   │   │
│  │  │ coalesce │  │ rcDec    │  │ free() 检测  │   │   │
│  │  └──────────┘  └──────────┘  └──────────────┘   │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │           memory_x86_64.cute / memory_x86.cute    │   │
│  │  load8/load32/load64  store8/store32/store64     │   │
│  │  hdrSizeRaw/hdrSetFooter  freeNext/freePrev       │   │
│  │  rcLoad/rcStore  flagLoad/flagStore               │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## 2. 内存分配器 v3

### 2.1 分层架构

分配器采用 **5 级分层**设计，每个层级处理不同大小范围的请求：

| 层级 | 名称 | 请求范围 | 块大小 | 管理方式 |
|------|------|----------|--------|----------|
| 0 | TINY | ≤ 1024 B | 32 ~ 2048 B | 34 个 slot 的空闲链表 |
| 1 | SMALL | ≤ 4096 B | 2048 / 4096 B | 2 个 slot 的空闲链表 |
| 2 | MIDDLE | ≤ 64 KB | 4096 ~ 65536 B | 24 个 slot 的空闲链表 |
| 3 | LARGE | ≤ 262144 B | 对齐到 ptrSize | brk 直接分配 + 合并 |
| 4 | HUGE | > 262144 B | 直接 brk | 直接 brk 分配/释放 |

### 2.2 常量定义（`const.cute`）

```cute
const TINY_MAX: uint = 1024       // TINY 层最大请求
const SMALL_MAX: uint = 4096      // SMALL 层最大请求
const MIDDLE_MAX: uint = 65536    // MIDDLE 层最大请求
const LARGE_MAX: uint = 262144    // LARGE 层最大请求
const CHUNK_SIZE: uint = 65536    // brk 批量分配的块大小
const IS_FREE: uint = 1           // 块空闲标志（header 低位）
const PREV_FREE: uint = 2         // 前一块空闲标志
const FLAG_MASK: uint = 3         // 标志位掩码（低 2 位）
const HDR_SIZE: uint = 2          // header + footer 开销（×ptrSize）
const IS_RC_TAG: uint = 98304     // mallocRC flags 字段的魔数（0x18000）
```

### 2.3 TINY 层块大小计算

TINY 层使用 **bump 分配 + 空闲链表回收**，块大小通过类号（class）计算：

```cute
fn blkSizeOfTiny(cls: uint) uint {
    if cls == 0 { ret 32 }
    var s: uint = 32
    var i: uint = 0
    for ; i < cls; {
        var step: uint = s >> 3          // 步长 = 当前大小 / 8
        if step < 16 { step = 16 }       // 最小步长 16
        s = s + step
        i = i + 1
    }
    ret (s + ptrSize - 1) & ~(ptrSize - 1)  // 对齐到 ptrSize
}
```

块大小序列：32, 48, 64, 80, 96, 112, 128, ... （递增步长逐渐增大）

请求大小到类号的映射（`slotOfTiny`）：

```
size ≤ 32    → class 0
size ≤ 48    → class 1
size ≤ 64    → class 2
...
size ≤ 2048  → class 33
```

### 2.4 块内存布局

#### 普通块（malloc 分配）

```
地址增长方向 →

┌──────────────┬────────────────────────────────┬──────────────┐
│   header     │         用户数据区              │   footer     │
│  (ptrSize)   │     (blkSize - 2×ptrSize)      │  (ptrSize)   │
├──────────────┼────────────────────────────────┼──────────────┤
│ size | flags │   [next ptr] [prev ptr] ...    │   size副本   │
└──────────────┴────────────────────────────────┴──────────────┘
^                                                     ^
blk                                                 blk + blkSize - ptrSize
用户指针 = blk + ptrSize
```

- **header**：存储块大小 | 标志位（低 2 位：IS_FREE=1, PREV_FREE=2）
- **footer**：header 的副本，用于反向合并（coalesce）时快速找到前一块
- **空闲时**：数据区前 2×ptrSize 用于存储空闲链表的 `next`/`prev` 指针

#### RC 块（mallocRC 分配）

```
地址增长方向 →

┌──────────────┬──────────┬──────────┬────────────────────────┬──────────────┐
│   header     │    RC    │  flags   │       用户数据区        │   footer     │
│  (ptrSize)   │ (ptrSize)│ (ptrSize)│   (blkSize - 5×ptrSize)│  (ptrSize)   │
├──────────────┼──────────┼──────────┼────────────────────────┼──────────────┤
│ size | flags │   RC=1   │ RC_TAG   │   [struct fields...]   │   size副本   │
└──────────────┴──────────┴──────────┴────────────────────────┴──────────────┘
^                                                    ^
blk                                                blk + blkSize - ptrSize
           ^                       ^
     user ptr = blk + 3×ptrSize    RC 在 user ptr - 2×ptrSize
                                   flags 在 user ptr - ptrSize
```

- **RC 字段**：引用计数，初始值为 1
- **flags 字段**：存储 `IS_RC_TAG`（98304），供 `free()` 运行时区分 malloc/mallocRC
- **用户指针**：指向数据区起始（跳过 header + RC + flags）

### 2.5 空闲链表管理

每个 slot 维护一个双向链表，头指针存储在全局数组 `gFreeHeads[60]` 中：

```cute
var gFreeHeads: [60]ptr    // 60 个 slot 的链表头
```

空闲块内部布局（数据区内）：

```
┌──────────────────────────────────────────┐
│  [header]  [next ptr]  [prev ptr]  ...  │
│             ^              ^             │
│         blk+ptrSize    blk+2×ptrSize    │
└──────────────────────────────────────────┘
```

```cute
fn freeNext(p: ptr) ptr { ret load64(p + ptrSize) }       // 读 next
fn freeSetNext(p: ptr, v: ptr) { store64(p + ptrSize, v) } // 写 next
fn freePrev(p: ptr) ptr { ret load64(p + 2 * ptrSize) }    // 读 prev
fn freeSetPrev(p: ptr, v: ptr) { store64(p + 2 * ptrSize, v) } // 写 prev
```

### 2.6 分配流程（malloc）

```
malloc(size):
  1. 计算请求量 req = size + 2×ptrSize（header + footer 开销）
  2. 最小请求量 = 4×ptrSize
  3. 分级路由：
     ├─ req > LARGE_MAX → brk 直接分配（HUGE）
     ├─ req > MIDDLE_MAX → brk 分配 + coalesce（LARGE）
     ├─ req > SMALL_MAX → brk 分配 + coalesce（MIDDLE）
     └─ req ≤ SMALL_MAX → 空闲链表查找（TINY/SMALL）
  4. 空闲链表查找：
     a. slotOf(req) → 确定 slot 类号
     b. headOf(cls) → 取链表头
     c. 若头为空 → commit() 批量分配 CHUNK_SIZE 字节
     d. 从链表摘除头节点
     e. 设置 header/footer
     f. 清除后继块的 PREV_FREE 标志
  5. 返回 blk + ptrSize（用户指针）
```

### 2.7 释放流程（freeAt）

```
freeAt(blk):
  1. 读取块大小 pure = hdrSizeRaw(blk) & ~FLAG_MASK
  2. 分级处理：
     ├─ pure > LARGE_MAX → 尝试收缩 brk
     ├─ pure > MIDDLE_MAX → coalesce + 尝试收缩 brk
     └─ pure ≤ MIDDLE_MAX → coalesce + insertFreeList
  3. 返回
```

### 2.8 合并（coalesce）

释放时合并相邻空闲块，减少碎片：

```
coalesce(blk):
  1. 读当前块 raw = hdrSizeRaw(blk)
  2. 检查后继块 nextBlk = blk + pure
     ├─ 若 nextBlk 在 brk 范围内且空闲 → removeFreeList(nextBlk) + 合并
  3. 检查前驱块（通过 PREV_FREE 标志）
     ├─ 若 PREV_FREE 置位 → 读前块 footer → 计算 prevBlk → removeFreeList + 合并
  4. 设置合并后的 header/footer
  5. 标记后继块的 PREV_FREE 位
  6. 返回合并后的 blk
```

### 2.10 已知限制：LARGE/MIDDLE 块仅在 brk 顶部时释放

`freeAt()` 对 LARGE/MIDDLE 块的处理：
- 只有当块在 brk 最顶端时才释放（`brk(blk)` 回缩）
- 否则直接泄漏（不加入空闲链表）

**影响**: 大块分配后如果有其他分配在其后，无法回收。
**当前状态**: 已知限制，不影响正常使用（大多数分配是 TINY/SMALL）。
**修复方案**: 需要实现空闲块合并后的 brk 收缩逻辑。

### 2.9 批量提交（commit）

当某个 slot 的空闲链表为空时，一次性从 brk 申请 `CHUNK_SIZE`（64KB）内存，切成等大小的空闲块串成链表：

```cute
fn commit(cls: uint, blkSize: uint) ptr {
    chunk = syscall.brk(0)
    nb = syscall.brk(chunk + CHUNK_SIZE)
    // 将 chunk 切分为 blkSize 大小的块
    // 每个块设置 header/footer + IS_FREE
    // 串成双向链表
    setHead(cls, head)
    ret chunk
}
```

---

## 3. 引用计数（RC）系统

### 3.1 RC 原语（平台相关）

RC 操作通过平台文件（`memory_x86_64.cute` / `memory_x86.cute`）提供：

#### x86_64

```cute
fn rcLoad(p: ptr) uint { ret load64(p - 2 * ptrSize) }    // 读 RC（p - 16）
fn rcStore(p: ptr, v: uint) { store64(p - 2 * ptrSize, v) } // 写 RC
fn flagLoad(p: ptr) uint { ret load64(p - ptrSize) }       // 读 flags（p - 8）
fn flagStore(p: ptr, v: uint) { store64(p - ptrSize, v) }   // 写 flags
```

#### x86

```cute
fn rcLoad(p: ptr) uint { ret load32(p - 2 * ptrSize) }    // 读 RC（p - 8）
fn rcStore(p: ptr, v: uint) { store32(p - 2 * ptrSize, v) } // 写 RC
fn flagLoad(p: ptr) uint { ret load32(p - ptrSize) }       // 读 flags（p - 4）
fn flagStore(p: ptr, v: uint) { store32(p - ptrSize, v) }   // 写 flags
```

### 3.2 RC 操作函数（`memory.cute`）

```cute
// 增加引用计数
fn rcInc(p: ptr) {
    if p == 0 { ret }
    var rc: uint = rcLoad(p)
    rcStore(p, rc + 1)
}

// 减少引用计数，归零时释放并返回 true
fn rcDec(p: ptr) bool {
    if p == 0 { ret true }
    var rc: uint = rcLoad(p)
    if rc <= 1 {
        rcStore(p, 0)
        trackFree(p)       // 泄漏追踪
        freeRC(p)          // 实际释放
        ret true
    }
    rcStore(p, rc - 1)
    ret false
}

// 读取当前 RC
fn rcGet(p: ptr) uint {
    if p == 0 { ret 0 }
    ret rcLoad(p)
}

// 尝试减少 RC 但不实际释放（用户自行管理）
fn rcTryRelease(p: ptr) bool {
    if p == 0 { ret true }
    var rc: uint = rcLoad(p)
    if rc <= 1 { rcStore(p, 0); ret true }
    rcStore(p, rc - 1)
    ret false
}

// 检查是否只有一个拥有者
fn rcIsOne(p: ptr) bool {
    if p == 0 { ret false }
    ret rcLoad(p) == 1
}

// 批量增加 RC
fn rcAdd(p: ptr, n: uint) { ... }

// 批量减少 RC（归零时释放）
fn rcSub(p: ptr, n: uint) bool { ... }

// 直接设置 RC
fn rcSet(p: ptr, n: uint) { ... }
```

### 3.3 freeRC

```cute
fn freeRC(ptr: ptr) {
    if ptr == 0 { ret }
    freeAt(ptr - ptrSize * 3)  // 跳过 RC + flags + header
}
```

`freeRC` 直接调用 `freeAt`，不检查 RC。RC 的递减逻辑由 `rcDec` 负责。

---

## 4. 双分配路径：new(T) vs newRC(T)

### 4.1 设计原则

```
new(T)   → malloc  → LLR GC 在函数出口 free
newRC(T) → mallocRC → 用户手动 rcDec 管理
```

| 特性 | `new(T)` | `newRC(T)` |
|------|----------|------------|
| 底层分配 | `malloc()` | `mallocRC()` |
| 块布局 | 普通块 | header + RC + flags + data |
| 初始 RC | 无 | 1 |
| 生命周期管理 | LLR 自动 free | 手动 `rcInc`/`rcDec` |
| 适用场景 | 局部变量、不逃逸 | 全局变量、跨函数共享 |
| 逃逸分析 | LLR 跟踪 | `objRCAlloc` 标记，LLR 跳过 |

### 4.2 编译器实现

#### new(T) — `builtinNew`（`exp.go:~2940`）

```go
func (c *ECompiler) builtinNew(...) string {
    code := c.emitMalloc(allocSize)     // 调用 malloc
    // 零填充 + 字段初值写入
    // 返回 *T
}
```

编译输出：
```asm
push 56              ; allocSize
call std_memory_malloc__uint
; 零填充 + 字段初始化
```

#### newRC(T) — `builtinNewRC`（`exp.go:3026`）

```go
func (c *ECompiler) builtinNewRC(...) string {
    code := c.emitMallocRC(allocSize)   // 调用 mallocRC
    // 零填充 + 字段初值写入
    // 返回 *T
}
```

编译输出：
```asm
push 80              ; allocSize = 56 + 24 (RC prefix)
call std_memory_mallocRC__uint
; 零填充 + 字段初始化
```

### 4.3 mallocRC 实现

```cute
fn mallocRC(size: uint) ptr {
    var rcPrefix: uint = ptrSize * 3       // header + RC + flags
    var req: uint = size + rcPrefix
    // ... 分级分配（同 malloc 逻辑）...
    
    var p: ptr = head + rcPrefix            // 用户指针跳过 3×ptrSize
    rcStore(p, 1)                           // RC = 1
    flagStore(p, IS_RC_TAG)                 // flags = 98304（魔数）
    trackAlloc(p)                           // 泄漏追踪
    ret p
}
```

### 4.4 free() 运行时检测

`free()` 函数需要区分 malloc 和 mallocRC 指针，以选择正确的释放路径：

```cute
fn free(ptr: ptr) {
    if ptr == 0 { ret }
    var flags: uint = flagLoad(ptr)     // 读 ptr - ptrSize
    if flags == IS_RC_TAG {             // 是 mallocRC？
        rcDec(ptr)                      // 走 RC 释放路径
        ret
    }
    freeAt(ptr - ptrSize)               // 走普通 malloc 释放路径
}
```

**关键**：`flagLoad(ptr)` 读取 `ptr - ptrSize`：
- 对于 malloc 指针：读到的是块 header（size | flags），值较小（< 1024），不会匹配 98304
- 对于 mallocRC 指针：读到的是 flags 字段，值为 IS_RC_TAG（98304），匹配

### 4.5 LLR 对 RC 对象的处理

LLR 分析通过 `objRCAlloc` 映射跟踪哪些对象是 `newRC()` 分配的：

```go
// llrState 中
objRCAlloc map[ObjID]bool  // true = newRC() 分配

// processAssign 中
if isRCAlloc(v.Value) {
    st.objRCAlloc[id] = true
}

// collectBlockFrees 中
if st.objRCAlloc[id] {
    continue  // newRC() 对象由手动 rcDec 管理，LLR 不自动释放
}
```

---

## 5. 静态 GC 分析（LLR）

### 5.1 分析流程

```
Build(root) → 全程序分析
  │
  ├─ Phase 1: 收集所有函数摘要（analyze.go）
  │   ├─ collectFuncs: 遍历 AST 收集 FuncBlock
  │   ├─ 初始化每个函数的 FnSummary
  │   └─ 不动点迭代：参数逃逸沿调用边反向传播
  │
  ├─ Phase 2: 计算出口释放计划（freeplan.go）
  │   └─ PlanFrees: 基于摘要判断哪些变量可在出口释放
  │
  └─ Phase 3: LLR 精确分析（llr.go）
      └─ ComputeLLR: 语句级前向扫描，跟踪对象绑定与逃逸
```

### 5.2 函数摘要（FnSummary）

```go
type FnSummary struct {
    Name           string
    RetOwned       bool       // 返回值是否拥有指针
    RetEscape      Escape     // 返回逃逸层级
    HasHeapAllocs  bool       // 是否有堆分配
    HasGlobalOwnStore bool    // 是否有全局拥有存储
    Params         []ParamSummary  // 参数摘要
    CallsAny       []string   // 调用的未知函数
}
```

### 5.3 逃逸层级（Escape）

```go
type Escape int
const (
    EscNone   Escape = 0  // 不逃逸
    EscCaller Escape = 1  // 逃逸到调用者
    EscGlobal Escape = 2  // 逃逸到全局
    EscAny    Escape = 3  // 逃逸到未知（保守）
)
```

### 5.4 LLR 分析详解

LLR 是**语句级前向扫描**，为每个函数产出：

1. **Objects**：所有抽象堆对象
2. **Frees**：函数出口需要释放的变量
3. **FieldFrees**：字段级级联释放（struct 的 owning 字段）
4. **BlockFreesMap**：块级释放（for/if 块内创建的对象）

#### 对象生命周期状态

```go
type LLRObj struct {
    ID       ObjID
    Site     string   // 分配来源描述
    Escaped  bool     // 是否已逃逸
    Name     string   // 主要绑定名
    FrameOwn bool     // 帧内拥有（= !escaped && !isParam）
}
```

#### 绑定跟踪

```go
type llrState struct {
    bindings     map[string]ObjID  // 变量名 → 当前绑定的对象
    objEscaped   map[ObjID]bool    // 对象是否逃逸
    objRCAlloc   map[ObjID]bool    // 是否 newRC() 分配
    orphans      []ObjID           // 被替换的旧对象
    fieldOrphans []fieldOrphan     // 字段级孤儿
    scopeDepth   int               // 当前作用域深度
}
```

#### processAssign 逻辑

```go
func processAssign(v *parser.VarBlock, st *llrState, ...) {
    if len(v.Name) > 1 {
        // 字段赋值（node.left = X）
        // 仅记录 fieldOrphan，不重绑父变量
        return
    }
    
    if v.IsDefine {
        if exprAllocates(v.Value) {
            // 新分配：创建新对象
            id := st.newObj(site)
            st.bindings[name] = id
            if isRCAlloc(v.Value) {
                st.objRCAlloc[id] = true  // newRC 标记
            }
        } else if refObj := getRefObj(v.Value, st); refObj != NilObj {
            // 别名：b = a → 共享对象
            st.bindings[name] = refObj
        } else {
            // null 初始化：var x: *T = nil
            id := st.newObj("null_init")
            st.bindings[name] = id
            st.objEscaped[id] = true  // 标记为已逃逸避免误 free
        }
        return
    }
    
    // 非定义赋值（name = value）
    if exprAllocates(v.Value) {
        newID := st.newObj(site)
        st.bindings[name] = newID
        // 旧对象进入孤儿列表（全局变量除外）
        if !v.IsGlobal && !isParamObj(st, targetObj) && !st.objEscaped[targetObj] {
            st.orphans = append(st.orphans, targetObj)
        }
    }
}
```

### 5.5 hasRealAnyCalls 门槛

当函数调用了未知函数（`CallsAny` 非空）时，LLR 分析保守地跳过该函数：

```go
func hasRealAnyCalls(calls []string) bool {
    for _, c := range calls {
        if c != "" { return true }
    }
    return false
}
```

### 5.6 collectStructFieldFrees

当 struct 指针在函数出口被释放时，其 owning 字段也需要递归释放：

```go
func collectStructFieldFrees(fb, body, frees) []LLRFieldFree {
    for _, fr := range frees {
        // 查找变量的 struct 类型
        structType := lookupStructType(...)
        // 遍历所有字段
        for _, field := range structType.Fields() {
            if isOwning(field.Type) {
                fieldFrees = append(fieldFrees, LLRFieldFree{
                    VarName: fr.VarName,
                    FieldName: field.Name,
                    Type: field.Type.Kind(),
                })
            }
        }
    }
}
```

---

## 6. 编译器代码生成

### 6.1 emitGCFrees — 函数出口释放

在函数出口生成释放指令，释放 LLR 分析标记的帧内拥有变量：

```go
func (c *Compiler) emitGCFrees(funcBlock, node) string {
    llr := gc.LLRResults[funcBlock.Name.String()]
    
    // 1. 字段级级联释放（先释放子对象再释放父容器）
    for _, ff := range llr.FieldFrees {
        off := findLocalVarOffset(node, ff.VarName)
        fieldOff := c.findStructFieldOffset(...)
        // 加载 struct_ptr → 加 fieldOffset → 加载字段值 → free
    }
    
    // 2. 顶层变量释放
    for _, fr := range llr.Frees {
        off := findLocalVarOffset(node, fr.VarName)
        // mov RDI, [rbp+off]
        // call std_memory_free__ptr
    }
}
```

生成的汇编（x86_64）：
```asm
; gc: free field root.left
mov RAX, QWORD [rbp-48]        ; 加载 root 指针
add RAX, 8                      ; + fieldOffset(8) = &left
mov RAX, QWORD [RAX]           ; 加载 left 值
mov RDI, RAX
call std_memory_free__ptr

; gc: free field root.right
mov RAX, QWORD [rbp-48]
add RAX, 16                     ; + fieldOffset(16) = &right
mov RAX, QWORD [RAX]
mov RDI, RAX
call std_memory_free__ptr

; gc: free root
mov RDI, QWORD [rbp-48]
call std_memory_free__ptr
```

### 6.2 emitBlockFrees — 块级释放

在 for/if 块出口释放块内创建的对象：

```go
func (c *Compiler) emitBlockFrees(blockNode *parser.Node) string {
    frees := llr.BlockFreesMap[blockNode]
    for _, fr := range frees {
        off := findLocalVarOffset(blockNode, fr.VarName)
        // mov RDI, [rbp+off]
        // call std_memory_free__ptr
    }
}
```

### 6.3 Assign — 变量赋值的孤儿释放

当变量被重新赋值时，旧值需要被释放（orphan-free）：

```go
func (c *ECompiler) Assign(v *parser.VarBlock) string {
    if !v.IsDefine && v.Type != nil && isOwning(v.Type) {
        // 1. 保存旧指针到临时寄存器
        freeOldTmp = c.allocTmpReg()
        code += mov freeOldTmp, [rbp+offset]  // 加载旧值
    }
    
    // 2. 计算新值并写入变量槽
    code += c.generate(v.Value, c.arch.VarAddr(v))
    
    // 3. 释放旧指针
    if freeOldTmp != nil {
        if v.IsGlobal {
            code += c.emitRCDec(freeOldTmp)  // 全局：RC 管理
        } else {
            code += c.emitFree(freeOldTmp)   // 局部：直接 free
        }
    }
}
```

生成的汇编（x86_64）：
```asm
; c = newLeaf(20)
mov RBX, QWORD [rbp-64]        ; 保存旧 c 值
push 20
call newLeaf__int               ; 计算新值
mov QWORD [rbp-64], RAX         ; 写入新值
mov RDI, RBX
call std_memory_free__ptr        ; free(旧 c)
```

### 6.4 emitMalloc / emitMallocRC

```go
func (c *ECompiler) emitMalloc(size int) string {
    // x86_64: mov RDI, size; call std_memory_malloc__uint
    // x86: push size; call std_memory_malloc__uint; add esp, 4
}

func (c *ECompiler) emitMallocRC(size int) string {
    // x86_64: mov RDI, size; call std_memory_mallocRC__uint
    // x86: push size; call std_memory_mallocRC__uint; add esp, 4
}
```

### 6.5 emitRCInc / emitRCDec

```go
func (c *ECompiler) emitRCInc(ptrReg string) string {
    // x86_64: mov RDI, ptrReg; call std_memory_rcInc__ptr
    // x86: push ptrReg; call std_memory_rcInc__ptr; add esp, 4
}

func (c *ECompiler) emitRCDec(ptrReg string) string {
    // x86_64: mov RDI, ptrReg; call std_memory_rcDec__ptr; movzx EAX, AL
    // x86: push ptrReg; call std_memory_rcDec__ptr; add esp, 4
}
```

### 6.6 isOwning — 拥有类型判断

```go
func isOwning(t typeSys.Type) bool {
    if t == nil { return false }
    k := t.Kind()
    if k == "string" || k == "list" { return true }
    if t.IsPointer() { return true }   // *T 视为拥有
    return false
}
```

### 6.7 lookupVarKind 的限制

`lookupVarKind` 在函数体中查找变量定义，但对指针类型（`*Node`）的 Kind 返回 `"*Node"` 而非 `"Node"`。GC 的 `collectStructFieldFrees` 通过直接查找 struct 类型来绕过此限制。

---

## 7. 泄漏追踪器

### 7.1 数据结构

```cute
var gAllocCount: uint = 0     // 总分配次数
var gFreeCount: uint = 0      // 总释放次数
var gLeaks: [256]ptr          // 未释放的指针列表
var gLeakCount: uint = 0      // 未释放指针数量
```

### 7.2 追踪函数

```cute
// 记录一次 RC 分配
fn trackAlloc(p: ptr) {
    gAllocCount = gAllocCount + 1
    if gLeakCount < 256 {
        gLeaks[gLeakCount] = p
        gLeakCount = gLeakCount + 1
    }
}

// 从追踪列表中移除
fn trackFree(p: ptr) {
    gFreeCount = gFreeCount + 1
    var i: uint = 0
    for ; i < gLeakCount; {
        if gLeaks[i] == p {
            // 用最后一个元素覆盖（O(1) 删除）
            gLeaks[i] = gLeaks[gLeakCount - 1]
            gLeakCount = gLeakCount - 1
            ret
        }
        i = i + 1
    }
}

// 报告泄漏数量
fn reportLeaks() uint { ret gLeakCount }

// 重置追踪器
fn resetLeakTracker() {
    gAllocCount = 0
    gFreeCount = 0
    gLeakCount = 0
}
```

### 7.3 调用时机

- `trackAlloc` → 在 `mallocRC` 中调用
- `trackFree` → 在 `rcDec` 和 `rcSub` 中调用（RC 归零时）
- `resetLeakTracker` → 测试开头调用
- `reportLeaks` / `reportAllocCount` / `reportFreeCount` → 测试结尾调用

---

## 8. 内存布局图解

### 8.1 完整的 TINY 块（malloc，56 字节块）

```
低地址                                              高地址
┌──────────┬──────────────────────┬──────────┐
│ header   │      数据区           │ footer   │
│ [56]     │  (48 字节可用)        │ [56]     │
└──────────┴──────────────────────┴──────────┘
^          ^                      ^          ^
blk        blk+8                  blk+48     blk+56
           用户指针
```

### 8.2 完整的 RC 块（mallocRC，32 字节数据）

```
低地址                                                      高地址
┌──────────┬──────────┬──────────┬──────────────────────┬──────────┐
│ header   │    RC    │  flags   │      数据区           │ footer   │
│ [80]     │   [1]    │ [98304]  │  (32 字节可用)        │ [80]     │
└──────────┴──────────┴──────────┴──────────────────────┴──────────┘
^                              ^                            ^     ^
blk                            用户指针(blk+24)              │  blk+80
                                                             footer
           用户指针-16 = RC    用户指针-8 = flags
```

### 8.3 空闲块（TINY 层）

```
┌──────────┬──────────────────────────────┬──────────┐
│ header   │      空闲链表数据             │ footer   │
│ [56|1]   │  [next ptr] [prev ptr] ...  │ [56|1]   │
└──────────┴──────────────────────────────┴──────────┘
^          ^           ^
blk        blk+8       blk+16
           next         prev
```

### 8.4 coalesce 合并过程

```
释放前：
┌──────┐┌──────┐┌──────┐┌──────┐
│ A已用 ││ B空闲 ││ C已用 ││ D空闲 │
└──────┘└──────┘└──────┘└──────┘

释放 C 后 coalesce：
┌──────┐┌─────────────────┐┌──────┐
│ A已用 ││   B+C+D 合并空闲  ││      │
└──────┘└─────────────────┘└──────┘
```

---

## 9. 已知问题与限制

### 9.1 test/rcLeak 崩溃

当前 `test/rcLeak` 在 x86_64 上 segfault，根因分析见 `PLAN_rcDebug.md`。主要嫌疑：

1. **mallocRC 块布局与 allocator 的 coalesce 不兼容**：`coalesce` 读取 header 时可能误读 RC 字段
2. **free() 的 flagLoad 误判**：malloc 指针的 header 值如果恰好等于 IS_RC_TAG 会错误走 RC 路径
3. **store64 第二参数 bug**：`collectValues` 和 `inorder` 中 `store64(buf+idx*8, node.value)` 的第二参数传入了 `idx*8` 而非 `node.value`

### 9.2 store64 参数 bug

编译器在生成 `store64(arg0, arg1)` 调用时，如果 `arg0` 的计算复用了 RAX，`arg1` 的求值不会重新加载原始值到 RAX，导致传入错误值。

### 9.3 lookupVarKind 限制

`lookupVarKind` 对 `*Node` 类型返回 `"*Node"` 而非 `"Node"`，但 GC 的 `collectStructFieldFrees` 通过直接查找 struct 类型绕过了此限制。

### 9.4 无 borrow 机制

所有权完全由编译器推断 + 用户显式选择分配方式。如果用户错误地将 `newRC` 对象赋值给多个变量而没有 `rcInc`，会导致 use-after-free。

### 9.5 泄漏追踪器容量

`gLeaks[256]` 最多追踪 256 个未释放指针，超出后静默丢弃。

### 9.7 IS_RC_TAG 与合法 block size 碰撞（已知限制）

`IS_RC_TAG = 98304 (0x18000)` 用于 `free()` 运行时区分 malloc/mallocRC 块。
但 LARGE 块的 header 直接存储 `aligned` 值（清除 flag 后），当用户分配
98288 字节时，`req = 98304 = IS_RC_TAG`，`free()` 会错误识别为 RC 块。

**当前状态**: 理论风险，实际使用中极少触发（需要分配恰好 98288 字节）。
**修复方案**: 使用不在合法 size 范围内的 magic number，或改用 flag 位的高位标记。

### 9.6 FLAG_MASK 与 IS_RC_TAG 的潜在冲突

当前 `FLAG_MASK = 3`（低 2 位），而 `IS_RC_TAG = 98304 = 0x18000`。理论上不会冲突（98304 的低 2 位为 0），但如果块大小恰好为 98304 且 header 的低 2 位被设置，`flagLoad` 可能读到一个包含低 2 位的值，但仍不等于 98304。风险极低但存在。

---

## 附录：关键文件索引

| 文件 | 用途 |
|------|------|
| `pkg/memory/const.cute` | 常量定义（TINY_MAX, IS_RC_TAG 等） |
| `pkg/memory/memory.cute` | 分配器 + RC 操作 + 泄漏追踪 |
| `pkg/memory/memory_x86_64.cute` | x86_64 平台原语（load/store/hdr/rc/flags） |
| `pkg/memory/memory_x86.cute` | x86 平台原语 |
| `compile/gc/analyze.go` | 全程序摘要分析 + isOwning + isRCAlloc |
| `compile/gc/llr.go` | LLR 语句级分析 + 绑定跟踪 |
| `compile/gc/freeplan.go` | 出口释放计划 + hasRealAnyCalls |
| `compile/compiler.go` | emitGCFrees + emitBlockFrees + findStructFieldOffset |
| `compile/exp/exp.go` | Assign 孤儿释放 + emitMalloc/MallocRC/RCInc/RCDec/Free + builtinNew/NewRC |
