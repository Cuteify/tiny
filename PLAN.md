# PLAN.md — 标准库开发计划

> 最后更新: 2026-09-19

---

## 1. 标准库包审计总览

### 1.1 包清单（pkg/ 下 34 个顶层目录，58 个子包）

| 分类 | 包数 | 状态 |
|------|------|------|
| 核心基础设施 | 4 | ✅ 完成 |
| 文本处理 | 8 | ✅ 完成（部分缺测试） |
| 哈希 | 8 | ✅ 完成（部分缺测试） |
| 数学 | 3 | ⚠️ math/big 仅为占位 |
| 排序 | 1 | ✅ 完成 |
| 操作系统 | 4 | ✅ 完成 |
| I/O | 1 | ✅ 完成 |
| 数据结构 | 5 | ✅ 完成（部分缺测试） |
| 压缩归档 | 7 | ⚠️ 多数为简化/占位实现 |
| 图像 | 5 | ⚠️ image/jpeg, image/gif 为占位 |
| 运行时 | 2 | ✅ 完成 |
| 测试框架 | 1 | ✅ 完成 |
| 高级工具 | 8 | ✅ 完成（部分缺测试） |
| 线程 | 1 | ✅ 完成（仅 x86_64 有 syscall） |

---

## 2. 各包完成度

### 2.1 核心基础设施（100%）

| 包 | 实现文件 | 测试 | 完成度 | 备注 |
|----|---------|------|--------|------|
| memory | memory.cute + const.cute + allocator.cute + rc.cute + memory_x86_64.cute + memory_x86.cute + gc/ | ✅ | 100% | 核心包，分配器+RC+追踪器 |
| syscall | syscall_x86_64.cute + syscall_x86.cute | ✅ | 100% | 仅 3 个原始 syscall 需内联 asm |
| strings | strings_x86_64.cute + strings_x86.cute + strings_common.cute + cstring.cute | ✅ | 100% | 含 strconv 功能（atoi/itoa） |
| builtin | builtin.cute | - | 100% | 编译器内建函数转发 |

### 2.2 文本处理（90%）

| 包 | 实现文件 | 测试 | 完成度 | 备注 |
|----|---------|------|--------|------|
| bytes | bytes.cute | ✅ | 95% | Buffer 实现完整 |
| fmt | fmt.cute | - | 80% | 缺 format/Sprintf 等格式化函数 |
| unicode | unicode.cute | ✅ | 70% | 仅 ASCII 范围，缺 Unicode 表 |
| unicode/utf8 | utf8.cute | ✅ | 85% | encodeRune/decodeRune 完整 |
| text/tabwriter | tabwriter.cute | - | 80% | 基本实现 |
| text/template | template.cute | - | 50% | 简单模板引擎 |
| html | html.cute | ✅ | 60% | 仅 escape/unescape |
| mime | mime.cute | ✅ | 70% | MIME 类型检测 |

### 2.3 哈希（85%）

| 包 | 实现文件 | 测试 | 完成度 | 备注 |
|----|---------|------|--------|------|
| hash | hash.cute | - | 100% | 接口定义包 |
| hash/crc32 | crc32.cute | ✅ | 100% | CRC-32 IEEE |
| hash/crc64 | crc64.cute | - | 100% | CRC-64 ECMA-182 |
| hash/adler32 | adler32.cute | - | 100% | Adler-32 |
| hash/fnv | fnv.cute | - | 100% | FNV-1/FNV-1a |
| hash/maphash | maphash.cute | - | 90% | MurmurHash3 风格 |
| hashmap | hashmap.cute | - | 95% | 链式哈希表，缺扩容时旧桶释放 |
| maps | maps.cute | - | 80% | keys/values 返回裸 ptr，非类型安全 |

### 2.4 数学（80%）

| 包 | 实现文件 | 测试 | 完成度 | 备注 |
|----|---------|------|--------|------|
| math | math.cute | ✅ | 90% | 整数函数完整；浮点函数通过 build ext 调用 -lm |
| math/bits | bits.cute | ✅ | 100% | leadingZeros/trailingZeros/onesCount/rotate/reverse |
| math/big | big.cute | - | **5%** | **仅占位符，无实际实现** |

### 2.5 排序（100%）

| 包 | 实现文件 | 测试 | 完成度 | 备注 |
|----|---------|------|--------|------|
| sort | int_sort.cute + str_sort.cute | ✅ | 100% | 快排 + Timsort，int/string 双支持 |

### 2.6 操作系统（85%）

| 包 | 实现文件 | 测试 | 完成度 | 备注 |
|----|---------|------|--------|------|
| os | os.cute | ✅ | 70% | exit/getcwd/error 检查；缺 Exec/Environ/Hostname |
| os/signal | signal.cute | - | 60% | Signal 常量 + 处理框架 |
| path | path.cute | ✅ | 90% | base/dir/ext/join/clean/isAbs + filepath 功能 |
| log | log.cute | - | 50% | 仅 log/logError，缺时间戳/级别 |

### 2.7 I/O（90%）

| 包 | 实现文件 | 测试 | 完成度 | 备注 |
|----|---------|------|--------|------|
| io | io.cute | ✅ | 85% | Reader/Writer/Copy/ReadAll/LimitReader |
| fs | fs.cute | ✅ | 95% | open/read/write/close + seek/mkdir/remove/stat 等 |

### 2.8 数据结构（85%）

| 包 | 实现文件 | 测试 | 完成度 | 备注 |
|----|---------|------|--------|------|
| slices | slice.cute + ops_x86_64.cute + ops_x86.cute + memmove_x86_64.cute + memmove_x86.cute | - | 95% | 泛型动态数组，功能完整 |
| container/list | list.cute | ✅ | 100% | 双向链表 |
| container/heap | heap.cute | ✅ | 90% | 最小堆 |
| container/ring | ring.cute | - | 80% | 环形缓冲区 |
| index/suffixarray | suffixarray.cute | - | 50% | 后缀数组搜索 |

### 2.9 压缩归档（40%）

| 包 | 实现文件 | 测试 | 完成度 | 备注 |
|----|---------|------|--------|------|
| compress/flate | flate.cute | ✅ | **30%** | 仅 Store 模式 DEFLATE，缺 Huffman/LZ77 |
| compress/gzip | gzip.cute | - | **20%** | 封装层，依赖 flate |
| compress/zlib | zlib.cute | - | **20%** | 封装层，依赖 flate |
| compress/bzip2 | bzip2.cute | - | **5%** | **占位符** |
| compress/lzw | lzw.cute | - | 50% | LZW 基本实现 |
| archive/tar | tar.cute | - | **30%** | USTAR 读取，缺写入 |
| archive/zip | zip.cute | - | **30%** | Zip 读取，缺写入 |

### 2.10 图像（50%）

| 包 | 实现文件 | 测试 | 完成度 | 备注 |
|----|---------|------|--------|------|
| image | image.cute | - | 80% | RGBA 像素操作完整 |
| image/color | color.cute | - | 70% | RGBA 颜色定义 |
| image/png | png.cute | - | **30%** | 简化解码 |
| image/jpeg | jpeg.cute | - | **5%** | **占位符** |
| image/gif | gif.cute | - | **5%** | **占位符** |

### 2.11 运行时（100%）

| 包 | 实现文件 | 测试 | 完成度 | 备注 |
|----|---------|------|--------|------|
| runtime | runtime.cute | - | 100% | NumCPU/Version/Compiler |
| runtime/debug | debug.cute | - | 100% | Stack/ReadBuildInfo |

### 2.12 测试框架（100%）

| 包 | 实现文件 | 测试 | 完成度 | 备注 |
|----|---------|------|--------|------|
| testing | testing.cute | - | 100% | T/Run/Fail/Error/Equal/EqualStr/Passed |

### 2.13 高级工具（75%）

| 包 | 实现文件 | 测试 | 完成度 | 备注 |
|----|---------|------|--------|------|
| uuid | uuid.cute | ✅ | 90% | UUID v4 生成 |
| flag | flag.cute | ✅ | 60% | 命令行参数解析（简化实现） |
| encoding/asn1 | asn1.cute | - | 40% | DER 编码 |
| encoding/quotedprintable | quotedprintable.cute | - | 50% | RFC 2045 |
| encoding/ascii85 | ascii85.cute | - | 60% | Ascii85 |
| thread | thread.cute + thread_x86_64.cute + once.cute + mutex.cute + cond.cute | - | 70% | 仅 x86_64 有 syscall |

---

## 3. 下一步开发优先级

### Phase 14 — 补全缺失测试（本周）

目标：所有已实现的包都有 test/ 目录和可运行的测试

| 优先级 | 包 | 说明 |
|--------|-----|------|
| P0 | slices | 核心数据结构，缺测试 |
| P0 | sort | 已有 test/ 但需验证完整性 |
| P0 | hashmap | 被 maps/os 依赖，缺测试 |
| P1 | bytes | 缺测试 |
| P1 | path | 已有 test/ 但需验证 |
| P1 | os | 已有 test/ 但需验证 |
| P1 | log | 缺测试 |
| P1 | flag | 已有 test/ 但需验证 |
| P2 | unicode/utf8 | 已有 test/ |
| P2 | hash/crc32 | 已有 test/ |
| P2 | container/heap | 已有 test/ |
| P2 | container/list | 已有 test/ |
| P2 | compress/flate | 已有 test/ |

### Phase 15 — 核心包增强（下周）

| 优先级 | 包 | 改进 |
|--------|-----|------|
| P0 | fmt | 添加 Sprintf/Sprintln/格式化动词 |
| P0 | os | 添加 Exec/Environ/Hostname/Getenv |
| P1 | strings | 补充 split/join/replace/hasPrefix/hasSuffix |
| P1 | unicode | 补充 Unicode 表（或利用已有 UTF-8 支持） |
| P1 | io | 衺充 io.ReadAll 完整实现 |
| P2 | log | 添加时间戳、日志级别 |

### Phase 16 — 占位包实现（本月）

| 优先级 | 包 | 说明 |
|--------|-----|------|
| P1 | math/big | 大整数运算 |
| P2 | image/jpeg | JPEG 解码 |
| P2 | image/gif | GIF 解码 |
| P2 | compress/bzip2 | bzip2 解压缩 |
| P3 | database/sql | 依赖 net，最后做 |
| P3 | net/* | 网络包，最后做 |

---

## 4. 已知问题列表

### 4.1 编译器层面

| 问题 | 严重度 | 状态 | 说明 |
|------|--------|------|------|
| map[K]V 类型仅 parser 支持 | 高 | 待修 | 类型系统已支持，hash 表代码生成未实现 |
| 缺少 `0x` 十六进制字面量 | 中 | 绕过 | 所有常量用十进制 |
| string 类型参数 []u8 不支持 | 中 | 绕过 | 用 *u64 指针代替 |
| 函数指针不支持方法调用 | 低 | 已知 | 仅支持普通函数指针 |
| defer 仅支持简单函数调用 | 低 | 已知 | 不支持闭包 |

### 4.2 标准库层面

| 问题 | 严重度 | 包 | 说明 |
|------|--------|-----|------|
| hashmap delete 后旧桶不释放 | 中 | hashmap | 内存泄漏 |
| maps.keys/values 返回裸 ptr | 中 | maps | 类型不安全，调用方需手动管理 |
| compress/flate 仅 Store 模式 | 高 | compress/flate | 无实际压缩能力 |
| log 无时间戳/级别 | 低 | log | 功能过于简单 |
| flag.parse 未完整实现 | 中 | flag | 仅框架，实际解析逻辑缺失 |

### 4.3 测试覆盖

| 缺失测试的包 | 优先级 |
|-------------|--------|
| slices | P0 |
| hashmap | P0 |
| bytes | P1 |
| log | P1 |
| thread | P1 |
| runtime, runtime/debug | P2 |
| builtin | P2 |
| hash/crc64, hash/adler32, hash/maphash | P2 |
| encoding/* | P3 |
| image/* | P3 |
| compress/* (除 flate) | P3 |

---

## 5. 与 Go 标准库的差异

### 5.1 不做或推迟的包

| 原因 | 包 |
|------|-----|
| 需要 goroutine | sync, sync/atomic |
| 需要网络 | net, net/http, net/url, net/mail, net/smtp, net/rpc, net/textproto |
| 需要数据库驱动 | database/sql, database/sql/driver |
| 需要反射 | reflect |
| 需要 CGO | cgo, plugin |
| 太复杂 | crypto/* |
| 已合并到其他包 | strconv → strings, filepath → path, io 包拆分为 fs + console |

### 5.2 设计差异

| Go | Cute | 原因 |
|----|------|------|
| `import "fmt"` | `package.json` 声明依赖 | 语言无 import 语法 |
| `fmt.Sprintf` | `strings.toString` + `fmt.appendStr` | 无 variadic 参数 |
| `sort.Slice` | `sort.quickSortInts` / `sort.timsortInts` | 无匿名函数 |
| `sync.Mutex` | 无 | 需要 goroutine 支持 |
| `interface{}` | `ptr` | 无空接口 |
| `map[K]V` | `hashmap.HashMap` (手动) | 编译器 map 代码生成未实现 |

---

## 6. 里程碑

| 里程碑 | 目标 | 预计时间 |
|--------|------|----------|
| M1 | 所有已实现包都有测试 | 1 周 |
| M2 | fmt 包增强（Sprintf） | 2 周 |
| M3 | strings 补充核心函数 | 2 周 |
| M4 | math/big 实现 | 1 月 |
| M5 | compress 真实实现（Huffman + LZ77） | 2 月 |
| M6 | image/jpeg + image/gif | 3 月 |
| M7 | net 包（如果需要） | 待定 |

---

> 本文档基于 2026-09-19 对 pkg/ 下所有包的完整审计。
