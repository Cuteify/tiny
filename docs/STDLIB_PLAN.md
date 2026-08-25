# 标准库全量实施计划

状态：规划完成，待用户拍板语法风格与实施顺序
日期：2026-08-26

## 用户指令摘要

1. strings 工具函数缺失的必须补齐（Contains/Index/Split/Join/Replace/Trim*/Upper/Lower/Repeat/Fields）
2. 标准库测试放在每包目录下 `test/` 子文件夹
3. 反射最后再做，但**接口和泛型得先做**（编译器核心前置）
4. 除 crypto、net、线程模型外的 Go stdlib 全量实现

## 现状盘点

已有 7 包（builtin/console/fs/memory/strings/syscall/time），16 种标量类型 + `[]T` 列表。
strings 缺失：Contains/Index/Split/Join/Replace/Trim*/Upper/Lower/Repeat/Fields/HasPrefix/HasSuffix。
编译器缺：接口系统、泛型、方法接收者、函数指针。

## Phase 0 — 编译器核心扩展（必须先做）

### 0A. 接口系统
| 层 | 改动 |
|---|---|
| parser | 新语法：`type Stringer interface { String() string }`；方法接收者 `fn (s MyType) String() string` |
| typeSys | InterfaceType（方法签名集）、接口匹配 = 类型 T 方法集 ⊇ 接口 I 方法集 |
| compile | itab 生成（具体类型×接口对 → 方法指针数组）；接口值运行时表示 {itab, data} 双槽；动态分派 |

### 0B. 泛型（单态化）
| 层 | 改动 |
|---|---|
| parser | 函数类型参数 `fn Max[T Ordered](a T, b T) T`；类型声明参数 `type List[T] struct {...}` |
| typeSys | TypeParam 占位类型；实例化时替换为具体类型 |
| compile | 单态化：parse 后 codegen 前 AST 复制+类型替换——零运行时开销 |

单态化比字典传递更适合 cuteify：AOT 编译器、已有 FuncBlock AST 复制先例、零运行时开销。

### 0C. 测试框架迁移
```
pkg/strings/
├── *.cute              ← 实现
└── test/
    ├── main.cute       ← 测试入口（调子测试，ret code 断言）
    └── test_*.cute     ← 子测试文件
```

### 待用户拍板
1. 语法风格：照搬 Go 还是自定义关键字
2. 单态化时机：parse 后立即 vs check 后 typeSys 做
3. 方法接收者是否在本轮范围
4. 实施顺序：Phase 0 先行还是 Phase 0 与 Phase 1(strings补齐) 并行

## Phase 1 — strings 工具函数补齐（不依赖新特性，可并行）

~15 个缺失函数，全部放 pkg/strings/ 新 .cute 文件，测试在 pkg/strings/test/。

Contains/Index/Split/Join/Replace/TrimSpace/TrimPrefix/TrimSuffix/Upper/Lower/Repeat/Fields/HasPrefix/HasSuffix

## Phase 2 — 标准库批次（依赖泛型+接口）

| 批次 | 包 | 泛型需求 | 接口需求 |
|---|---|---|---|
| 1 | strconv, errors, cmp | 无 | errors.Error ✓ 验收接口 |
| 2 | sort/slices | ✅ Sort[T]/Search[T] | sort.Interface 可选 |
| 3 | unicode/utf8, bytes, bufio | bytes 无泛型 | bufio.Reader 用 io.Reader 接口 |
| 4 | encoding/base64/hex/binary, hash/crc32/fnv/adler32 | 无 | hash.Hash 接口 |
| 5 | math, math/rand, math/bits | 无 | 无 |
| 6 | os(B层), path/filepath, log, flag | 无 | 无 |
| 7 | encoding/json(元数据表), regexp, csv | json 需要 | json.Marshaler |

反射最后做。json v1 可用显式注册替代反射。

## 批次明细

### 批次 1 — 基础原语
| 包 | 核心内容 | 行数 |
|---|---|---|
| strconv | Atoi/Itoa/ParseInt/FormatInt/FormatFloat/Quote | ~300 |
| errors | New/Is/As/Unwrap/Join | ~50 |
| cmp | Compare/Less/Or | ~30 |

### 批次 2 — 文本与字节
| 包 | 核心内容 | 行数 |
|---|---|---|
| unicode/utf8 | DecodeRune/RuneCount/EncodeRune | ~200 |
| bytes | Buffer/Split/Join/Replace/Trim/Equal | ~400 |
| bufio | Reader/Writer/Scanner | ~350 |

### 批次 3 — 编码校验
| 包 | 核心内容 | 行数 |
|---|---|---|
| base64/hex | Encode/Decode 查表 | ~150 |
| binary | LittleEndian/BigEndian/Uvarint | ~180 |
| crc32/fnv/adler32 | 校验和查表 | ~150 |

### 批次 4 — 数学
| 包 | 核心内容 | 行数 |
|---|---|---|
| math | Sqrt/Floor/Ceil/Pow/Mod (SSE2 或查表) | ~300 |
| rand | LCG/Shuffle/Int63n | ~100 |
| big | 大整数 Add/Mul/DivMod | ~600 |

### 批次 5 — B 层 syscall 壳
| 包 | 前置 syscall | 核心内容 | 行数 |
|---|---|---|---|
| os | stat/lseek/getdents/getenv/getcwd | File/Open/ReadDir/Mkdir/Remove | ~500 |
| filepath | getwd | Clean/Walk/Abs | ~200 |
| log | write(2) | Printf/Fatal | ~80 |
| flag | os.Args | Parse/String/Bool/Int | ~200 |

### 批次 6 — 高级编码
| 包 | 核心内容 | 行数 |
|---|---|---|
| json | tag 元数据表驱动序列化 | ~800 |
| csv | 状态机 Reader/Writer | ~250 |
| regexp | Thompson NFA | ~900 |
| html | Escape/Unescape | ~50 |

### 远期
debug/elf（自举价值）、image/png、container/*、suffixarray

## 总量估算

| 批次 | 包数 | .cute 行数 | 测试目录 |
|---|---|---|---|
| 0(编译器) | - | Go 代码 ~1500 | - |
| 1(strings) | 0新 | ~600 补齐 | pkg/strings/test/ |
| 2.1 | 3 | ~380 | 各包 test/ |
| 2.2 | 2 | ~950 | 各包 test/ |
| 3 | 5 | ~480 | 各包 test/ |
| 4 | 3 | ~1000 | 各包 test/ |
| 5 | 4 | ~980 | 各包 test/ |
| 6 | 4 | ~2000 | 各包 test/ |
| 合计 | ~26 新包 | ~7000+ | ~20 个测试目录 |

## 关键约束与对策

| 约束 | 对策 |
|---|---|
| 无函数指针 | bufio/io 用具体类型嵌入或 fn 参数注入回调 |
| 无闭包 | 回调改为接口方法分派（依赖 0A） |
| 字符串共享缓冲语义 | Replace/Split malloc 新缓冲 ✓ 已确认 |
| f32/f64 后端 | math 需要 SSE2；确认 BTFloat 代码路径完整性 |
