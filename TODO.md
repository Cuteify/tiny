# TODO.md — 标准库待办事项

> 最后更新: 2026-09-19
> 按优先级排列：P0 (必须修复) → P1 (重要优化) → P2 (锦上添花)

---

## P0 — 必须修复

### 编译器缺陷

- [ ] **map[K]V 代码生成**：parser 层已支持 `map[K]V` 类型声明，但编译器没有生成 hashmap 操作的代码。使用 `map[string]int` 声明可以编译，但运行时无哈希表支持。
- [ ] **flag.parse 未实现**：`pkg/flag/flag.cute` 的 `parse()` 函数体为空，命令行参数解析无法工作。
- [ ] **hashmap delete 内存泄漏**：`pkg/hashmap/hashmap.cute` 的 `delete()` 不释放删除节点的内存。

### 测试缺失（核心包）

- [ ] **slices 测试**：`pkg/slices/` 无 test/ 目录。需测试 push/pop/get/insert/remove/reverse/find/contains/free。
- [ ] **hashmap 测试**：`pkg/hashmap/` 无 test/ 目录。需测试 set/get/delete/has/size/resize。
- [ ] **sort 测试完整性**：`pkg/sort/test/` 已存在但需验证覆盖 quickSort/timsort/insertionSort 边界情况。

---

## P1 — 重要优化

### 包功能增强

- [ ] **fmt 包增强**：当前仅 itoa/itoaHex/itoaOct/appendInt/appendStr/appendChar。需添加：
  - `Sprintf(format string, args...) string` — 无 variadic 时可用固定参数版本
  - `Sprintln(args...) string`
  - `Errorf(format string, args...) string`
  - 注意：Cute 语言无 variadic `...T`，需要设计替代方案（如用数组参数）

- [ ] **strings 包补充**：当前已有 len/cap/eq/ne/to_cstring/contains/hasPrefix/hasSuffix/index/trim/trimLeft/trimRight/compare/count/lastIndex/indexByte/containsAny/containsRune/atoi/itoa/parseBool/formatBool/bufNew/bufSetByte/bufSetInt/bufToString。需补充：
  - `split(s, sep) []string` — 字符串分割
  - `join(parts, sep) string` — 字符串连接
  - `replace(s, old, new, n) string` — 字符串替换
  - `repeat(s, count) string` — 字符串重复
  - `toUpperStr(s) string` / `toLowerStr(s) string` — 大小写转换（整字符串版）
  - `Fields(s) []string` — 按空白分割

- [ ] **os 包补充**：当前有 exit/getcwd/stdout/stderr/errnoOf/isExist/isNotExist/isPermission。需添加：
  - `getenv(name) string` — 读取环境变量
  - `setenv(name, value)` — 设置环境变量
  - `args() []string` — 命令行参数
  - `hostname() string` — 主机名

- [ ] **bytes 测试**：`pkg/bytes/` 无 test/ 目录。
- [ ] **log 测试**：`pkg/log/` 无 test/ 目录。
- [ ] **slices 测试**：同 P0 项。

### 缺失测试的包

- [ ] `pkg/slices/` — P0
- [ ] `pkg/hashmap/` — P0
- [ ] `pkg/bytes/` — P1
- [ ] `pkg/log/` — P1
- [ ] `pkg/thread/` — P1（需要线程环境测试）
- [ ] `pkg/runtime/` — P2
- [ ] `pkg/runtime/debug/` — P2
- [ ] `pkg/builtin/` — P2

### 代码质量

- [ ] **hashmap 扩容释放旧桶**：`resize()` 分配新桶后旧桶 (`oldBuckets`) 未释放，每次扩容泄漏 `oldCap * 8` 字节。
- [ ] **maps.keys/values 类型安全**：当前返回裸 `ptr`（字符串数组指针），调用方需手动管理。应返回 `*slices.StringSlice` 或等效类型。
- [ ] **flag 包 memory.store32 存指针**：64 位系统上指针 8 字节，但代码用 `memory.store32` 存储指针，会截断高位。
- [ ] **strings_common.cute parseBool 性能**：逐字符比较过于冗长（嵌套 if 层级 7 层），可用 switch 或更简洁的实现。

---

## P2 — 锦上添花

### 占位包实现

- [ ] **math/big**：大整数运算（加减乘除、位运算）。当前 `big.cute` 仅占位。
- [ ] **image/jpeg**：JPEG 解码。当前仅占位。
- [ ] **image/gif**：GIF 解码。当前仅占位。
- [ ] **compress/bzip2**：bzip2 解压缩。当前仅占位。

### 功能增强

- [ ] **unicode 包**：当前仅 ASCII 范围的字符分类。可考虑添加 Unicode 表或利用 UTF-8 支持扩展。
- [ ] **log 包增强**：添加时间戳（依赖 time 包）、日志级别（Debug/Info/Warn/Error）。
- [ ] **text/template 增强**：当前为简单模板引擎，可添加条件/循环/管道等。
- [ ] **encoding/asn1 完善**：当前仅基本 DER 编码，可添加完整 ASN.1 支持。
- [ ] **index/suffixarray 完善**：当前实现较简单，可优化为 SA-IS 算法。

### 测试补全

- [ ] `pkg/hash/crc64/` — 测试
- [ ] `pkg/hash/adler32/` — 测试
- [ ] `pkg/hash/maphash/` — 测试
- [ ] `pkg/encoding/asn1/` — 测试
- [ ] `pkg/encoding/quotedprintable/` — 测试
- [ ] `pkg/encoding/ascii85/` — 测试
- [ ] `pkg/image/color/` — 测试
- [ ] `pkg/image/png/` — 测试
- [ ] `pkg/container/ring/` — 测试
- [ ] `pkg/index/suffixarray/` — 测试
- [ ] `pkg/compress/lzw/` — 测试
- [ ] `pkg/archive/tar/` — 测试
- [ ] `pkg/archive/zip/` — 测试
- [ ] `pkg/text/tabwriter/` — 测试
- [ ] `pkg/text/template/` — 测试
- [ ] `pkg/uuid/` — 已有 test/，验证完整性
- [ ] `pkg/os/signal/` — 测试

---

## 远期计划（暂不优先）

- [ ] Phase 15: database/sql + database/sql/driver（依赖 net，最后做）
- [ ] Phase 16: net/net.http/net.url/net.mail/net.smtp/net.textproto/net.rpc（最后做）
- [ ] sync/sync-atomic（需要 goroutine 支持）
- [ ] crypto/*（太复杂）

---

## 已完成

- [x] Phase 0: 编译器基础设施（switch/case、for range、defer、map 类型、函数指针）
- [x] Phase 1: 修补现有包（syscall/strings/fs/console/time 新增函数）
- [x] Phase 2: 文本数据（bytes/unicode/utf8/fmt/tabwriter）
- [x] Phase 3: 哈希（crc32/crc64/adler32/fnv/maphash/hashmap）
- [x] Phase 4: 数学（math/bits）
- [x] Phase 5: 排序（sort — 快排 + Timsort）
- [x] Phase 6: 操作系统（os/path/log/os-signal）
- [x] Phase 7: I/O（io）
- [x] Phase 8: 数据结构（container/list/heap/ring/slices/maps）
- [x] Phase 9: 压缩归档（flate/gzip/zlib/bzip2/lzw/tar/zip）
- [x] Phase 10: 图像处理（image/color/png/jpeg/gif）
- [x] Phase 11: 运行时（runtime/runtime/debug）
- [x] Phase 12: 测试框架（testing）
- [x] Phase 13: 高级工具（html/template/mime/uuid/encoding/index/thread/flag）
- [x] Phase 14: 补充包（strconv 合并 strings、filepath 合并 path、flag、os/signal）
