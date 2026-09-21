# Cuteify (Cute) 项目概况

> 一门面向系统编程的编程语言编译器

---

## 1. 项目简介

Cuteify（简称 Cute）是一门**静态类型、编译型**的系统编程语言，编译目标为 **x86/x86_64 Linux** 平台的 NASM 汇编，最终链接生成 ELF 原生二进制文件。

### 1.1 核心特性

| 特性 | 说明 |
|------|------|
| **静态类型** | 编译期类型检查，无运行时类型信息 |
| **手动内存管理** | 基于所有权 + 引用计数的内存管理，无 GC 停顿 |
| **系统级能力** | 直接操作内存、内联汇编、系统调用 |
| **零成本抽象** | 泛型、接口在编译期特化，无运行时开销 |
| **LLVM-free** | 自研后端，直接生成 NASM 汇编 |

### 1.2 设计哲学

```
所有权优先 → 引用计数补充 → 仅全局使用 RC
```

- **所有权（Ownership）**：编译器通过 LLR（Lazy Life Range）分析推断指针生命周期
- **引用计数（RC）**：跨函数/全局共享时使用 `newRC(T)` 分配带 RC 头的对象
- **无借用机制**：不引入 borrow checker，所有权完全由编译器推断

---

## 2. 项目结构

### 2.1 源码统计

| 类别 | 文件数 | 代码行数 |
|------|--------|----------|
| Go 源码（编译器） | ~100 | ~24,500 |
| Cute 源码（标准库 58 个包） | ~120 | ~15,000 |
| Cute 源码（运行时库） | ~70 | ~3,600 |
| 测试目录 | 105 | - |
| **总计** | **~291** | **~43,100** |

### 2.2 目录结构

```
tiny/
├── main.go                    # 编译器入口
├── go.mod                     # Go 1.25 模块定义
│
├── compile/                   # 编译器核心
│   ├── compiler.go            # 主编译器（代码生成）
│   ├── build.go               # 构建流程
│   ├── vtable.go              # 虚函数表
│   ├── monomorphize.go        # 泛型特化
│   ├── defer.go               # defer 语义实现
│   ├── utils.go               # 工具函数
│   │
│   ├── arch/                  # 平台相关代码生成
│   │   ├── x86/cdecl.go       # x86 cdecl 调用约定
│   │   └── x86_64/linux_sysv.go # x86_64 System V ABI
│   │
│   ├── exp/                   # 表达式编译
│   │   └── exp.go             # 表达式求值、内存分配指令生成
│   │
│   ├── gc/                    # GC 分析系统
│   │   ├── analyze.go         # 全程序摘要分析
│   │   ├── llr.go             # LLR 语句级分析
│   │   └── summary.go         # 函数摘要、逃逸层级
│   │
│   ├── context/               # 编译上下文
│   └── regmgr/                # 寄存器管理
│
├── parser/                    # 语法分析器
│   ├── var.go                 # 变量/赋值 AST
│   ├── type.go                # 类型 AST
│   └── ...                    # 其他 AST 节点
│
├── lexer/                     # 词法分析器
├── type/                      # 类型系统
├── error/                     # 错误处理
├── package/                   # 包管理
├── utils/                     # 工具库
│
├── pkg/                       # 标准库（34 个包）
│   ├── memory/                # 内存管理（分配器 + RC + 追踪器）
│   ├── syscall/               # 系统调用
│   ├── fmt/                   # 格式化输出
│   ├── strings/               # 字符串操作
│   ├── slices/                # 切片操作
│   ├── hashmap/               # 哈希表
│   ├── runtime/               # 运行时支持
│   └── ...                    # 其他标准库包
│
├── test/                      # 测试套件（105 个测试目录）
│   ├── rcLeak/                # RC 泄漏测试（当前 segfault）
│   ├── rcSimple/              # RC 基础测试
│   ├── rcTracking/            # RC 追踪测试
│   ├── gcStructFree/          # GC 结构体释放测试
│   └── ...                    # 其他测试
│
├── runtime/                   # 运行时（旧版，待清理）
├── cute-highlight/            # 语法高亮
├── cuteify                    # 编译器二进制
├── cuteify2                   # 编译器二进制（新版）
│
├── DOC_memory_gc.md           # 内存管理与 GC 完整文档
├── CLAUDE.md                  # AI 助手上下文文档
├── PLAN_memory_cleanup.md     # 内存管理整理计划
├── PLAN_rcDebug.md            # rcLeak 修复计划
├── TODO_rcDebug.md            # rcLeak 修复任务
└── CHANGES.md                 # 变更日志
```

---

## 3. 编译流程

### 3.1 编译管线

```
源码 (.cute)
    │
    ▼
┌─────────────┐
│  词法分析    │  lexer/
│  Lexer       │  → Token 流
└─────────────┘
    │
    ▼
┌─────────────┐
│  语法分析    │  parser/
│  Parser      │  → AST (Abstract Syntax Tree)
└─────────────┘
    │
    ▼
┌─────────────┐
│  包解析      │  package/
│  Package     │  → 依赖解析、包合并
└─────────────┘
    │
    ▼
┌─────────────┐
│  类型检查    │  type/
│  TypeCheck   │  → 类型推导、类型验证
└─────────────┘
    │
    ▼
┌─────────────┐
│  GC 分析     │  compile/gc/
│  LLR         │  → 逃逸分析、生命周期分析
└─────────────┘
    │
    ▼
┌─────────────┐
│  代码生成    │  compile/
│  CodeGen     │  → NASM x86/x86_64 汇编
└─────────────┘
    │
    ▼
┌─────────────┐
│  汇编        │  nasm -f elf64
│  Assemble    │  → 目标文件 (.o)
└─────────────┘
    │
    ▼
┌─────────────┐
│  链接        │  ld
│  Link        │  → ELF 可执行文件
└─────────────┘
    │
    ▼
  原生二进制
```

### 3.2 命令行接口

```bash
# 基本用法
./cuteify2 <path>              # 编译并链接
./cuteify2 -S <path>           # 仅生成汇编
./cuteify2 -c <path>           # 仅生成目标文件
./cuteify2 -o <output> <path>  # 指定输出文件
./cuteify2 -ast <path>         # 生成 AST 文本

# 使用测试脚本
./test_run.sh test/<testdir> x86        # x86 模式
./test_run.sh test/<testdir> x86_64     # x86_64 模式
./test_run.sh                          # 运行所有测试
```

---

## 4. 语法概览

### 4.1 基本语法

```cute
// 注释
package main

// 函数定义
fn add(a: int, b: int) int {
    ret a + b
}

// 变量声明
var x: int = 10
var name: string = "hello"
var ptr: *int = nil

// 指针操作
var p: *int = new(int)
p.* = 42

// 结构体
struct Point {
    x: int
    y: int
}

// 方法
fn (p: *Point) distance() int {
    ret (p.x * p.x + p.y * p.y)
}
```

### 4.2 控制流

```cute
// if-else
if x > 0 {
    // positive
} else if x < 0 {
    // negative
} else {
    // zero
}

// for 循环
for ; i < 10; {
    i = i + 1
}

// switch
switch value {
    case 1 { // ... }
    case 2 { // ... }
    default { // ... }
}

// defer
fn example() {
    var f: *File = open("test.txt")
    defer close(f)
    // 使用 f
    // 函数退出时自动 close(f)
}
```

### 4.3 内存管理

```cute
// 普通分配（栈/堆，编译器决定）
var node: *Node = new(Node)
node.value = 10

// RC 分配（用于跨函数共享）
var shared: *Data = newRC(Data)
rcInc(shared)   // 增加引用计数
rcDec(shared)   // 减少引用计数（归零时释放）

// 裸指针（非拥有，用于系统编程）
var raw: ptr = getSystemAddress()
```

---

## 5. 内存管理系统

> 详细文档见 `DOC_memory_gc.md`

### 5.1 分配器 v3

采用 **5 级分层**设计：

| 层级 | 名称 | 请求范围 | 块大小 | 管理方式 |
|------|------|----------|--------|----------|
| 0 | TINY | ≤ 1024 B | 32 ~ 2048 B | 34 个 slot 的空闲链表 |
| 1 | SMALL | ≤ 4096 B | 2048 / 4096 B | 2 个 slot 的空闲链表 |
| 2 | MIDDLE | ≤ 65536 B | 4096 ~ 65536 B | 24 个 slot 的空闲链表 |
| 3 | LARGE | ≤ 262144 B | 对齐到 ptrSize | brk 直接分配 + 合并 |
| 4 | HUGE | > 262144 B | 直接 brk | 直接 brk 分配/释放 |

### 5.2 块内存布局

#### 普通块（malloc）

```
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

#### RC 块（mallocRC）

```
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

### 5.3 GC 分析系统

**LLR（Lazy Life Range）分析**：
- 语句级前向扫描，跟踪对象绑定与逃逸
- 帧内分配、不逃逸的指针在函数出口自动释放
- 支持字段级级联释放（struct 的 owning 字段）

**逃逸层级**：
```go
EscNone   = 0  // 不逃逸
EscCaller = 1  // 逃逸到调用者
EscGlobal = 2  // 逃逸到全局
EscAny    = 3  // 逃逸到未知（保守）
```

---

## 6. 类型系统

### 6.1 基本类型

| 类型 | 说明 | 大小 |
|------|------|------|
| `bool` | 布尔 | 1 字节 |
| `i8`/`u8` | 有符号/无符号 8 位 | 1 字节 |
| `i16`/`u16` | 有符号/无符号 16 位 | 2 字节 |
| `i32`/`u32` | 有符号/无符号 32 位 | 4 字节 |
| `i64`/`u64` | 有符号/无符号 64 位 | 8 字节 |
| `f32`/`f64` | 单精度/双精度浮点 | 4/8 字节 |
| `int`/`uint` | 平台相关整数 | 4/8 字节 |
| `ptr` | 裸地址（非拥有） | 4/8 字节 |

### 6.2 复合类型

| 类型 | 说明 |
|------|------|
| `*T` | 类型化指针（拥有所有权） |
| `[N]T` | 固定长度数组 |
| `[]T` | 切片（list） |
| `string` | 字符串（切片的一种） |
| `struct { ... }` | 结构体 |
| `fn(T) R` | 函数类型 |
| `interface { ... }` | 接口 |

### 6.3 类型判断

```go
// isOwning() 返回 true 的类型：
// - *T（类型化指针）
// - string
// - list（[]T）
// - struct 中的 *T 字段

// isOwning() 返回 false 的类型：
// - ptr（裸地址）
// - int, bool 等基本类型
// - 值类型的 struct
```

---

## 7. 标准库

### 7.1 包列表（34 个顶层目录，58 个子包）

| 包名 | 说明 | 状态 |
|------|------|------|
| `memory` | 内存管理（分配器 + RC + 追踪器） | ✅ 完成 |
| `syscall` | 系统调用封装 | ✅ 完成 |
| `runtime` | 运行时支持 | ✅ 完成 |
| `fmt` | 格式化输出（itoa/append） | ⚠️ 缺 Sprintf |
| `strings` | 字符串操作 + strconv | ✅ 完成 |
| `slices` | 泛型动态数组 | ✅ 完成（缺测试） |
| `hashmap` | 哈希表（FNV-1a） | ✅ 完成（缺测试） |
| `console` | 标准输出/输入 | ✅ 完成 |
| `fs` | 文件操作 | ✅ 完成 |
| `os` | 操作系统接口 | ⚠️ 缺 getenv/args |
| `io` | I/O 操作 | ✅ 完成 |
| `math` | 数学函数 | ✅ 完成 |
| `sort` | 排序（快排+Timsort） | ✅ 完成 |
| `testing` | 测试框架 | ✅ 完成 |
| `thread` | 线程支持 | ⚠️ 仅 x86_64 |
| `time` | 时间处理 | ✅ 完成 |
| `encoding` | 编码解码（asn1/quotedprintable/ascii85） | ⚠️ 部分实现 |
| `compress` | 压缩算法（flate/gzip/zlib/bzip2/lzw） | ⚠️ 多数简化 |
| `hash` | 哈希算法（crc32/crc64/adler32/fnv/maphash） | ✅ 完成 |
| `html` | HTML 处理 | ⚠️ 仅 escape/unescape |
| `image` | 图像处理（color/png/jpeg/gif） | ⚠️ jpeg/gif 占位 |
| `unicode` | Unicode 支持（ASCII 范围） | ⚠️ 仅 ASCII |
| `uuid` | UUID 生成 | ✅ 完成 |
| `bytes` | 字节缓冲区 | ✅ 完成（缺测试） |
| `maps` | Map 工具函数 | ✅ 完成 |
| `path` | 路径处理 | ✅ 完成 |
| `log` | 日志 | ⚠️ 过于简单 |
| `flag` | 命令行参数 | ⚠️ parse 未实现 |
| `builtin` | 编译器内建 | ✅ 完成 |
| `container/list` | 双向链表 | ✅ 完成 |
| `container/heap` | 最小堆 | ✅ 完成 |
| `container/ring` | 环形缓冲区 | ✅ 完成 |
| `text/template` | 模板引擎 | ⚠️ 简单实现 |
| `math/big` | 大整数 | ❌ 仅占位 |
| `math/bits` | 位操作 | ✅ 完成 |
| `os/signal` | 信号处理 | ⚠️ 框架实现 |
| `index/suffixarray` | 后缀数组 | ⚠️ 简单实现 |
| `runtime/debug` | 运行时调试 | ✅ 完成 |

> 图例：✅ 完成 | ⚠️ 部分实现/缺功能 | ❌ 仅占位
> 详细审计见 `PLAN.md`

### 7.2 内存管理包

```cute
// pkg/memory/memory.cute

// 分配
malloc(size: uint) ptr           // 普通分配
mallocRC(size: uint) ptr         // RC 分配
realloc(ptr: ptr, newSize: uint) ptr

// 释放
free(ptr: ptr)                   // 自动检测 malloc/mallocRC
freeRC(ptr: ptr)                 // 显式 RC 释放
freeAt(blk: ptr)                 // 内部释放

// RC 操作
rcInc(p: ptr)                    // 增加引用计数
rcDec(p: ptr) bool               // 减少引用计数（归零时释放）
rcGet(p: ptr) uint               // 读取引用计数
rcSet(p: ptr, n: uint)           // 设置引用计数
rcAdd(p: ptr, n: uint)           // 批量增加
rcSub(p: ptr, n: uint) bool      // 批量减少
rcTryRelease(p: ptr) bool        // 尝试释放
rcIsOne(p: ptr) bool             // 检查是否只有一个引用

// 泄漏追踪
trackAlloc(p: ptr)               // 记录分配
trackFree(p: ptr)                // 记录释放
reportLeaks() uint               // 报告泄漏数量
resetLeakTracker()               // 重置追踪器
```

---

## 8. 测试系统

### 8.1 测试结构

每个测试目录包含：
- `main.cute` — 测试主函数
- `package.json` — 包配置（依赖声明）

### 8.2 测试分类

| 类别 | 测试目录 | 说明 |
|------|----------|------|
| 基础语法 | `simpleBasicTest`, `fullSyntaxTest` | 基本语法验证 |
| 控制流 | `controlFlow`, `for_range_test` | if/for/switch |
| 函数 | `functionCalls`, `multi_return` | 函数调用、返回值 |
| 数据结构 | `array_basic`, `slice_test`, `list` | 数组、切片、列表 |
| 内存管理 | `heap_new`, `heap_struct`, `memoryTest` | 堆分配、结构体 |
| GC | `gc_*`, `gcfree*`, `gcprobe` | GC 分析和释放 |
| RC | `rcLeak`, `rcSimple`, `rcTracking` | 引用计数 |
| 接口 | `ifaceTest`, `iface_dispatch` | 接口和虚函数 |
| 泛型 | `generics` | 泛型特化 |
| 平台 | `asmTest`, `thread` | 内联汇编、线程 |

### 8.3 运行测试

```bash
# 运行单个测试
./test_run.sh test/rcSimple x86_64

# 运行所有测试
./test_run.sh

# 测试退出码说明
# 0 = 测试通过
# 非0 = 测试完成（部分测试用退出码表示结果）
```

---

## 9. 已知问题

### 9.1 rcLeak segfault（阻塞中）

- **现象**: `test/rcLeak` 在 x86_64 上 exit=139
- **根因**: mallocRC 块布局与 allocator 的 coalesce 不兼容
- **状态**: 修复中，见 `PLAN_memory_cleanup.md` Phase 0

### 9.2 ~~freeplan.go 死代码~~ （已清理）

- **已删除**: `compile/gc/freeplan.go`（394 行），`PlanFrees()` / `Plans` map 已移除
- **保留**: `hasRealAnyCalls` / `allocSiteDesc` / `DumpFrees` 已迁移至 `llr.go`
- **状态**: ✅ 已完成（Phase 1.1）

### 9.3 isGlobalTarget 恒返回 false

- **现象**: `isGlobalTarget()` 永远返回 false
- **影响**: 全局变量赋值不会触发孤儿 free，可能导致内存泄漏
- **状态**: 计划修复，见 `PLAN_memory_cleanup.md` Phase 1

### 9.4 emitGCFrees x86 双重栈清理

- **现象**: x86 路径 `emitGCFrees` 多了一行 `add esp, 4`
- **影响**: 栈指针多偏移 4 字节
- **状态**: 计划修复，见 `PLAN_memory_cleanup.md` Phase 1

### 9.5 CLAUDE.md 文档过时

- **现象**: CLAUDE.md 中的 tier 描述与实际实现不符
- **影响**: 开发者误解分配器行为
- **状态**: 计划修正，见 `PLAN_memory_cleanup.md` Phase 1

---

## 10. 构建与环境

### 10.1 依赖

- **Go**: 1.25+
- **NASM**: `/usr/bin/nasm`
- **ld**: `/usr/bin/ld`
- **gcc**: `/usr/bin/gcc`（可选，用于 C 调用）

### 10.2 构建

```bash
# 构建编译器
go build -o cuteify2 .

# 使用临时目录（磁盘空间不足时）
TMPDIR=$(pwd)/.tmp go build -o cuteify2 .
```

### 10.3 环境变量

| 变量 | 说明 |
|------|------|
| `CUTE_ARCH` | 目标架构：`x86` 或 `x86_64`（默认 `x86`） |
| `GC_DBG` | 启用 GC 调试输出 |
| `TMPDIR` | 临时目录 |

---

## 11. 开发指南

### 11.1 代码风格

- **Go**: 遵循 `gofmt` 标准
- **Cute**: 使用 4 空格缩进，`//` 注释

### 11.2 添加新测试

1. 创建 `test/<testname>/` 目录
2. 添加 `main.cute` 测试文件
3. 添加 `package.json` 配置
4. 运行 `./test_run.sh test/<testname>` 验证

### 11.3 修改内存管理器

1. 阅读 `DOC_memory_gc.md` 了解设计
2. 查看 `PLAN_memory_cleanup.md` 了解当前计划
3. 修改 `pkg/memory/` 下的文件
4. 运行 `./test_run.sh` 确认无回归

---

## 12. 参考文档

| 文档 | 说明 |
|------|------|
| `DOC_memory_gc.md` | 内存管理与 GC 完整文档（权威） |
| `CLAUDE.md` | AI 助手上下文文档 |
| `PLAN_memory_cleanup.md` | 内存管理整理计划 |
| `PLAN_rcDebug.md` | rcLeak 修复计划 |
| `TODO_rcDebug.md` | rcLeak 修复任务 |
| `CHANGES.md` | 变更日志 |

---

> 最后更新: 2026-09-19
