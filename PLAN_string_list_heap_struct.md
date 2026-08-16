# Plan: string / list / 堆上结构体支持

## 1. 现状调研（已验证）

### 1.1 编译架构
- 唯一生效的编译路径：`ECompiler`（`compile/exp/exp.go`）→ `compile/arch/x86_64/`（`a.exp()` → `exppkg.New(a.ctx).Compile(...)`，见 `ops.go:299`）
- `compile/arch/x86_64/exp.go` 的旧 `ExpCom` 是**死代码**（无人调用），但它包含完整的 list/string asm 生成逻辑（`compileListLiteral` / `compileIndexAccess` / `compileIndexSet` / `compileSlice` / `strConstHandle` / `builtinHandle`），是本次移植的最佳参考。
- 现状实测：`test/string`、`test/list`、`test/struct` 均能"编译通过"，但生成汇编是垃圾（如 `mov , QWORD[rbp]`），nasm 报 `expression syntax error`。**string/list/struct 字段访问在 ECompiler 下全部未实现。**

### 1.2 已就绪（无需改动）
- **解析层**（parser/）全部就绪：
  - `[]T{}` → `Separator="list_lit"`，`ListElems`
  - `a[i]` → `Separator="[]"`，`Index[0]`
  - `a[i] = v` → `Separator="[]="`（checkAssign 转换，`exp.Left`=索引表达式，`exp.Right`=值）
  - `a[i:j]` → `Separator="[::]"`，`Index[1]`/`Index[2]`（注意：新 parser 用 `Index[3]`，与旧 ExpCom 的 `exp.Right.Left/Right` 不同）
  - `a.len` / `a.cap` / `a.ptr` → `FindTypeField` + `genVLen()`（`finder.go:427`）
  - `p.x` / `p.x.y` → 多段 `Name`，`FindTypeField`，`v.Define.Path` 含类型链
  - `self.x`（方法内）、方法调用 `p.method()`（`Call.ThisVar`）、`*p` 解引用、`&v`、`memory.malloc`
- **类型层**（type/）就绪：`ListType`/`StringType` Size = 24（x64）/ 12（x86），三字段布局 ptr/len/cap；`StructField.Offset` 已计算；`PtrType`；`GetLenName` 宽度前缀已有。
- **runtime**：`memory.malloc`（三平台）；`runtime/string.cute` 有 `strlen/strcpy/strcmp/memcpy/memset`（u64 指针版，未接入编译器的 string 语义）。
- **测试机制**：`./test_run.sh <测试目录> [arch...]`，编译+链接+运行，以 `ret` 值判定通过；默认 x86_64 + x86 双架构。

### 1.3 编译层缺失（本次全部工作）
| # | 缺失项 | 现状表现 | 涉及位置 |
|---|--------|----------|----------|
| 1 | `list_lit` / `[]` / `[]=` / `[::]` 无分派 | 落入 binLR/binRL 生成垃圾 | `compile/exp/exp.go` `generate()` |
| 2 | string 常量未处理（无 StringConsts 填充、无 .data 标签） | `mov , QWORD[rbp]` 空目标 | `compile/exp/exp.go` `leaf()`/`val()` |
| 3 | 内建 `len`/`cap`/`make`/`append`/`realloc`/`clone` 与 string 运算（`+` 拼接、`+=` 追加、`==`/`!=` 比较）缺失 | 当作普通函数调用 → 找不到函数 | `compile/exp/exp.go` |
| 4 | 字段偏移是 stub | `calcFieldOffset`/`calcThisFieldOffset` 返回 0 → 所有字段挤在基址 | `compile/arch/x86_64/utils.go:77-89` |
| 5 | 指针字段访问（堆上结构体 `p.x`，p 为 `*T`）无实现 | 无 | `utils.go` + `exp.go` |
| 6 | struct/list/string 整体拷贝只 mov 单槽 | 24 字节只拷 8 字节；参数寄存器只传 8 字节；返回值只写 RAX | `exp.go` leaf、`linux_sysv.go` Call/returnValue |

## 2. 设计

### 2.1 string（三字段 ptr/len/cap，**Go string 语义** + C 兼容）
- **Go 语义**：string = 不可变字节序列；`len(s)` 返回**字节数**（`len("你好世界")` = 12，与 Go 一致）；`==`/`!=` 按内容逐字节比较（Go 编译为长度 + memcmp）；零值 `""` = `{ptr:0, len:0, cap:0}`；string 变量赋值 = 拷贝三字段（共享底层，Go 风格）
- **内存布局**：字符串内容在内存中**始终以双 NUL（`\x00\x00`）结尾**，与 C `char*` 互操作（可直接传给 C 函数 / 传给 u64 指针 API），并为对齐预留冗余。
  - 常量：`.data` 段 `str_N: db "<字节>", 0, 0` —— 数据区直接带双 NUL 结尾，无需初始化代码。装载变量 = `ptr=label, len=字节数, cap=字节数`（len/cap 字段**不含** NUL；只读，cap 仅标记不可写）。
  - 运行期分配（拼接等）：`malloc(align8(len1+len2+1))`，尾部写双 NUL；len 字段仍为内容字节数。
- **cap 规则（string，NUL 预留）**：`cap = align8(内容字节数+1) - 1` —— 即"malloc 申请到的最大范围（8 字节对齐向上取整，与分配器粒度一致）- 1"。示例：内容 5 字节 → 请求 `align8(5+1)=8` → cap=7（len=5，[5]=NUL，[7]=冗余 NUL）。恒有 `cap >= len+1`，追加时无需立即扩容。
  - 分配器契约（`runtime/memory.cute`）：`malloc(n)` 实际占用 `n+8`（8 字节块头，不占用户区），最小块 16 → 请求对齐 8 即可获得满额用户区，"最大范围" = 请求值。
  - 可选后续：运行时从块头 `*(u64*)(p-8) - 8` 读取真实可用范围，使 cap 自适应分配器粒度变化（当前固定 8 字节粒度，编译期规则即等价，先不做）。
- **len(s)**：读 `[s+8]`（内建，与 `s.len` 字段形式统一）。
- **拼接 `+`**：编译期常量折叠（`"a"+"b"` → 单常量）；运行期 = `malloc(align8(l1+l2+1))` + 两次 `memcpy` + 尾部双 NUL，cap 按上述规则（`align8(l1+l2+1)-1`）。注：无 GC，拼接产物不自动回收（后续可加引用计数/arena）。
- **比较 `==`/`!=`**：先比长度，再逐字节比（内建生成循环，按 len 字段而非 C strcmp，避免内容含 NUL 时误判）。
- **中文/UTF-8**：`len` 按字节数（Go `len(StringVal)` 一致）；`test/string` 注释里"字符数"要改为"字节数"，期望值相应修正（"你好世界" = 12 字节）。

### 2.1b string 动态堆上版本（可变、可扩容）
- **两级表示，与 list 同一套三字段模型**：
  - *只读引用*：常量直接指向 `.data`（`ptr=label, len=n, cap=n`，cap 表示"不可写"）
  - *堆上可变版本*：`malloc` 分配，**cap = 申请到的最大范围 - 1**（`align8(len+1)-1`，NUL 预留），尾部维护双 NUL（`[len]` 与 `[cap]` 各一个 `0`）
- **进入堆版本的途径**：任何会产生新内容的操作——拼接 `+`、追加 `+=`、`s.clone()`（显式把常量/只读引用拷贝到堆，返回堆版本）——左侧为 .data 常量时自动拷贝到堆，不写只读内存
- **追加 `s += t`（动态增长的核心，语义同 C++ std::string）**：
  - `len + lt + 1 <= cap` → 直接 `memcpy` 到尾部，更新 len，重写双 NUL（新 `[len]` 与新 `[cap]`）
  - 不足 → **与 list 共用 `realloc` 内建**（见 2.1b）：新容量 = 2 倍对齐取 `max(cap*2, align8(len+lt+1))` 再 -1；realloc 后追加，维护双 NUL
- **新增统一内建 `realloc(ptr, newSize)`**：malloc 新 + memcpy(旧 len) + free 旧，返回新指针。list 扩容（2.2）与 string 扩容共用此内建，保证扩容策略单一来源
- **引用语义**：拷贝 string 变量 = 拷贝三字段（共享底层数据，Go 风格）；需要独立副本时用 `s.clone()`
- 注：无 GC，扩容/拼接旧内存由 `free` 显式回收；`s.clone()` 的旧引用不变（共享期无写操作则安全）

### 2.2 list（**Go slice 语义**：动态长度、动态尺寸，cap 与内存分配器对齐）
- **Go slice 布局**：三字段 `{ptr, len, cap}` 与 Go 完全一致；`a[i]`、`a[i]=v`、`a[lo:hi]`、`len`/`cap`、`append`、零值 nil slice `{0,0,0}`、切片共享底层数组 —— 全部 Go 语义。
- **分配器契约**（`runtime/memory.cute`，已验证）：`malloc(n)` 实际分配 `n+8` 字节（8 字节块头），最小块 16 字节 → **有效分配粒度 8 字节**。list 容量按此向上取整，malloc 不产生内部碎片（cap 字段向上取整到 8 字节边界能容纳的元素个数；Go 本身也不保证字面量 cap 精确，append 文档即"cap 可能大于 len"）。
- **cap 规则**：`cap = align8(n * elemSize) / elemSize`。对 elemSize=8 的元素，cap == n；elemSize=1/2/4 时自动上浮（如 10 个 u8 → bytes=10→align8=16，cap=16）。**注意与 string 的区别**：list 元素无 NUL 需求，cap 取满额对齐值；string 因 NUL 预留取"最大范围 - 1"（见 2.1）。
- **`make([]T, len)` / `make([]T, len, cap)` 内建（Go 格式的动态分配入口）**：`malloc(align8(max(len,cap)*elemSize))` + **零填充**（按 elemSize 用 `mov` 清零或 rep stosq）→ `{ptr, len, cap}`。
- **字面量 `[]T{}`**（运行时分配，Go 字面量语义）：`make` 同款分配 → 逐元素装载（常量直接写槽；非常量表达式逐个求值写入，与求值顺序一致）。空列表 `[]T{}` = `{0,0,0}`（nil，Go 同）。
  - string 元素：每元素 24 字节三槽（ptr/len/cap），尾部 NUL 指针；struct 元素按 Size 分 8 字节槽
- **索引读 `a[i]`**：`ptr + i*elemSize`，元素宽度前缀读；元素 >8 字节（string/struct）→ 多槽拷贝到目标。**越界不自动扩容（Go 语义，越界是 bug，不做运行时检查或后续再加）**。
- **索引写 `a[i]=v`**：同上算地址，按宽度写。
- **切片 `a[lo:hi]`**：`ptr+lo*es, len=hi-lo, cap=原cap-lo`（cap 保留到数组尾，与 Go 一致，为 append 留空间）；省略 lo/hi 时从原三字段推。三索引切片 `a[lo:hi:max]` 列为可选后续。
- **内建 `len(a)`/`cap(a)`** + 字段形式 `a.len`/`a.cap`/`a.ptr` 统一处理。
- **动态增长 `append(a, v)` 内建**（Go 格式，核心语法 `a = append(a, v)`）：
  - `len < cap` → 直接写 `a[ptr+len*es]`，len+1（共享底层的其他切片可见新元素，Go 语义）
  - `len == cap` → **共用 `realloc` 内建**（见 2.1b）：新容量 = `max(cap*2, 1)` 且 `align8(newCap*es)` 对齐；realloc 后写入新元素
  - 返回值是新三字段（Go：`a = append(a, v)`）
- **可选后续**（Go 格式，不在本次范围）：`copy(dst, src)`、三索引切片 `a[lo:hi:max]`、`[]byte(s)`/`string([]byte)` 转换、`range` 迭代

### 2.3 堆上结构体
- **`p.x`（p: `*T`）**：地址 = 解引用 p 得到对象地址，再 + 字段偏移。两层寻址：`mov rax, QWORD [rbp-p槽]; mov rax, [rax+off]`（读）；写同理。**这是"堆上结构体"的核心语义**。
- **`self.x`（方法内）**：this 是指针存于 `[rbp+16]` → `[rbp+16+off]`（一次解引用，`calcThisFieldOffset` 实现真实偏移）。
- **链式指针**：`list.head.value`（`List{head: *Node}`，test/struct 已定义未使用）——路径中遇到 `*T` 就插入一层解引用。
- **分配**：`memory.malloc(Size(T))` 返回 u64/ptr，赋给 `*T`。需确认/补充 `ptr ↔ *T` 赋值转换规则（parser 类型检查处，若不允许则补兼容规则）。
- **`&p.x`**：取字段地址（现有 `&` 支持 `&var`，扩展字段路径）。

### 2.4 struct/list/string 值语义（M5）
- **赋值 `var b = a`**：按 Size 分 8 字节槽拷贝（leaf 的 mem-mem 中转扩展为多槽循环）。
- **参数传递**：≤8B 走寄存器（现状）；>8B（struct/list/string 24B）走栈拷贝（从右到左压 3 槽，调用后清理）。
- **返回值**：标量走 RAX（现状）；>8B 返回值最小方案 = 编译器插入隐藏临时槽（`rbp` 内），函数返回前拷到临时槽，调用后拷回目标（不改 ABI，纯编译器内建）。

## 3. 改动文件清单
1. `compile/exp/exp.go`（主战场）
   - `generate()`：分派 `list_lit`/`[]`/`[]=`/`[::]`/string 二元运算/内建调用（放 binLR 之前）
   - `leaf()`/`val()`：string 常量 → 标签；mem-mem 多槽拷贝
   - 新增：list 字面量（运行时 malloc 装载）/`make`/索引/切片/内建 len/cap/append、string concat/追加(clone/+=)/compare、统一 `realloc` 的 asm 生成（旧 `compile/arch/x86_64/exp.go` 的字面量/切片 asm 可参考寻址部分，装载与扩容按本 plan 2.1/2.1b/2.2 重写，`Index[3]` 新结构）
2. `compile/arch/x86_64/utils.go`
   - `calcFieldOffset`：按 `v.Name` 链 + `v.Define.Path` 求字段偏移（处理多级 `p.a.b`、`*T` 解引用层）
   - `calcThisFieldOffset`：self/this 字段偏移
   - 新增 `GenFieldAddr`：返回字段访问的地址表达式或装载序列
3. `compile/arch/x86_64/linux_sysv.go`：参数 >8B 栈拷贝、返回值 >8B 临时槽
4. `compile/compiler.go`：数据段 string 标签输出（StringConsts 现有出口扩展；list 不再需要 .data 静态数组）
5. 测试更新：`test/string`（字节数注释与期望值 + 新增 `+=`/clone 动态用例）、`test/list`（期望值核对 + 新增 append/扩容用例）、`test/struct`（已有指针链类型可激活）；新增 `test/heap_struct`（malloc 分配 + p.x 读写 + 链式）

## 4. 里程碑（顺序依赖）
- **M1 字段访问**：`calcFieldOffset`/`calcThisFieldOffset` 真实偏移 + 栈上结构体字段读写（`p.x`/`self.x`）→ `test/struct` 通过
- **M2 list（Go slice 语义）**：运行时分配的字面量/`make`/索引读/索引写/切片/len/cap/append（扩容）→ `test/list`、`test/list_test` 通过
- **M3 string**：常量/len/拼接/比较 + 动态堆上版本（`+=` 追加、clone、realloc 扩容）→ `test/string` 通过
- **M4 堆上结构体**：`*T` 字段访问（两层解引用）+ malloc 分配 + 指针链 → 新增 `test/heap_struct`
- **M5 值语义**：struct/list/string 赋值拷贝、参数、返回值 → 全量回归

## 5. 验证
- 每里程碑：`./test_run.sh test/<对应目录> x86_64`（x86 架构在 M5 后统一回归）
- 每里程碑：全量 `for d in test/*/; do ./test_run.sh $d x86_64; done` 防回归
- M5 后双架构全量回归