# 标准库实施 TODO

泛型语法决策：Go 风格方括号 `[T Constraint]`
日期：2026-08-26

## Phase 0 — 编译器核心（前置）
- [ ] 0A. 接口系统
  - [ ] parser：接口类型声明语法 `type X interface { M() T }`
  - [ ] parser：方法接收者语法 `fn (r Receiver) Method() T`
  - [ ] typeSys：InterfaceType + 接口匹配判定
  - [ ] compile：itab 生成 + 接口值 {itab, data} 双槽表示
  - [ ] compile：通过 itab 的动态分派调用发射
- [ ] 0B. 泛型（单态化，Go 风格方括号）
  - [ ] parser：函数类型参数 `[T Constraint]` 语法（fn 名后 `[` → 类型参数列表）
  - [ ] parser：类型声明参数 `type List[T]` 语法（type 名后 `[` → 类型参数列表）
  - [ ] typeSys：TypeParam 占位与实例化替换
  - [ ] compile：单态化 pass（AST 复制+类型替换）
- [ ] 0C. 测试迁移到每包 test/ 子目录

## Phase 1 — strings 工具函数补齐
- [ ] Contains(s, substr) bool
- [ ] Index(s, substr) int
- [ ] Split(s, sep) []string
- [ ] Join(elems []string, sep) string
- [ ] Replace(s, old, new, n) string
- [ ] TrimSpace(s) string
- [ ] TrimPrefix / TrimSuffix
- [ ] Upper / Lower
- [ ] Repeat(s, count) string
- [ ] Fields(s) []string
- [ ] HasPrefix / HasSuffix
- [ ] 测试：pkg/strings/test/

## Phase 2 — 标准库批次

### 批次 1（基础原语，无依赖）
- [ ] strconv: Atoi/Itoa/ParseInt/FormatInt/FormatFloat/Quote
- [ ] errors: New/Is/As/Unwrap/Join（验收接口系统）
- [ ] cmp: Compare/Less/Or

### 批次 2（文本字节，依赖泛型+接口）
- [ ] sort/slices: Sort[T]/Search[T]/Contains[T]（泛型）
- [ ] unicode/utf8
- [ ] bytes: Buffer/Split/Join/Replace/Trim/Equal
- [ ] bufio: Reader/Writer/Scanner（依赖 io.Reader 接口）

### 批次 3（编码校验）
- [ ] encoding/base64 + hex
- [ ] encoding/binary: LittleEndian/BigEndian/Uvarint
- [ ] encoding/pem

### 批次 4（数学）
- [ ] math: Sqrt/Floor/Ceil/Pow/Mod
- [ ] math/rand: LCG/Shuffle/Int63n
- [ ] math/big: 大整数 Add/Mul/DivMod
- [ ] math/bits: LeadingZeros/OnesCount/Add64/Mul64/RotateLeft

### 批次 5（哈希与校验，math 之后）
- [ ] hash/crc32: CRC-32 查表（IEEE + Castagnoli）
- [ ] hash/fnv: FNV-1a 32/64
- [ ] hash/adler32: Adler-32
- [ ] hash/maphash: xxHash 或 FNV 内部 hash

### 批次 6（hashmap 新包，依赖泛型）
- [ ] hashmap: 泛型 HashMap[K comparable, V]
- [ ] 开放寻址 + 负载因子扩容
- [ ] 接口：Get/Put/Has/Delete/Len/Keys/Values/Clear

### 批次 7（B 层 syscall 壳）
- [ ] syscall 补 stat/lseek/mmap/getdents/getpid/getuid
- [ ] os: File/Open/ReadDir/Mkdir/Remove/Getenv/Args/Exit
- [ ] path/filepath: Clean/Walk/Abs
- [ ] log: Printf/Fatal
- [ ] flag: Parse/String/Bool/Int

### 批次 8（高级编码与正则，反射最后）
- [ ] encoding/json: tag 元数据表驱动序列化
- [ ] regexp: Thompson NFA
- [ ] csv: Reader/Writer
- [ ] html: Escape/Unescape

## 已知前置修复项
- [ ] f32/f64 后端代码路径完整性确认（math 需要 SSE2）
- [ ] strings.toString 双参跨包 panic（已有 nil 守卫，需查根因）
