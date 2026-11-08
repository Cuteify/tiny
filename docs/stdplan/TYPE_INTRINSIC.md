# 类型内建映射（Type Intrinsic）与函数重载

> 状态：**Go 编译器 Phase 1–4 已实施**（2026-11-07）；自举编译器后续按同一张表对齐。
> 计划与验收记录：[`PLAN_TYPE_INTRINSIC_OVERLOAD.md`](PLAN_TYPE_INTRINSIC_OVERLOAD.md)。
> 关联：[`PLAN.md`](PLAN.md) §6、[`../SELFHOST.md`](../SELFHOST.md) §4.11。

本文描述“某类型的某操作由哪个 std 实现承载”的规则。唯一事实源是
`parser/intrinsic.go` 的 `intrinsicTable`；本文是用户可读版本，表变更时必须同步。

---

## 1. 自动生效规则

1. 根包加载时（`CUTE_NO_INTRINSIC` 未设置）预加载 `std:strings`、`std:maps`、
   `std:slices`，并把逻辑包名 → 本地路径登记到 `parser.IntrinsicPkgs`。
2. 预加载**不写入根包 import 别名**，因此不会占用用户已有的
   `strings` / `maps` / `slices` 变量名或 import 别名。
3. 预加载**不提供用户命名空间回退**：`strings.foo` / `maps.foo` / `slices.foo`
   必须显式 `import` 对应包才能解析。预加载包只供 `intrinsicTable` 的
   lowering 用完整包路径构造调用，不参与 `Name.FixPath` 的别名解析。
4. 局部变量优先于包路径：函数内先按 `FindVar` 查局部/参数/字段，只有找不到
   名称时才走包路径解析。
5. `string` 的 `==` / `!=` 在 `checkEq` 阶段直接改写为 `std:strings.eq/ne`
   调用；两个字面量的比较仍在编译期折叠，不产生调用。
6. `string * int` 的运行期形态在 `checkMul` 阶段改写为 `std:strings.repeatN`
   调用；常量形态仍在编译期折叠。
7. `CUTE_NO_INTRINSIC=1` 关闭上述全部隐式行为：不预加载 std 包、不做 string
   内容比较/重复的 lowering；显式 import 的包不受影响。

---

## 2. 映射表

| Kind | 操作 | 实现 | 形态 | 说明 |
|---|---|---|---|---|
| `string` | `==` / `!=` | `std:strings.eq` / `ne` | parser lowering | 内容比较，不再比较三槽头 |
| `string` | `*` | `std:strings.repeatN` | parser lowering | 运行期重复；常量在编译期折叠 |
| `string` | `+` | 编译器内建 | Native | 保留现有 `stringConcatExp`（GC 来源标记 `string-concat`） |
| `string` | `len` / `cap` | 编译器内建 | Native | 读头部 len/cap |
| `string` | `s[i]` / `s[lo:hi:step]` | 编译器内建 | Native | 索引返回 `byte`，切片返回 `string` |
| `map` | `len(m)` | 编译器内建 | Native | nil map 返回 0，不解引用 |
| `map` | `m[k]` | `std:maps.get` | codegen | nil/缺失键返回零值 |
| `map` | `m[k] = v` | `std:maps.set` | codegen | nil map 自动 `maps.new` 并写回左值 |
| `list` | `len` / `cap` | 编译器内建 | Native | 读切片头（需要左值/地址） |
| `list` | `s[i]` / `s[i] = v` | 编译器内建 | Native | 保留现有代码生成（需要地址） |
| `list` | `s[lo:hi:step]` | 编译器内建 | Native | 视图或新建缓冲，见 §4 |

`std:slices` 的 `len/cap/push/get/set/...` 作为命名 API 自动可用，但不替换
`[]T` 的内建操作；`append` 语义保持不变。

---

## 3. map 语义

### 3.1 表示

`map[K]V` 在编译器内是**单个指针**（`MapType.Size() == TargetPointerSize`），
指向 `std:maps` 的 `mapHdr`：

```
slots @ 0
cap   @ 1*ptr
count @ 2*ptr
ksz   @ 3*ptr
vsz   @ 4*ptr
row   @ 5*ptr
```

### 3.2 读写

- `var m: map[string]int` 的零值是 `nil`（空指针）。
- `len(m)` 由编译器直接读 `count@2*ptr`（先判 nil），不调用 `maps.len`。
- 读 `m[k]`：先清零值临时区，再调用 `maps.get`；nil map 或缺失键返回零值。
- 写 `m[k] = v`：目标为 nil 时调用 `maps.new[K](zeroK, sizeof(V))` 初始化，
  并把新 header 写回左值；随后调用 `maps.set`。
- 键为 `string` 时按 3 个机器槽装载；值为 `string`/`[]T`/struct 时按字节宽
  拷贝。值临时区位于栈帧，调用结束即失效。

### 3.3 显式 API

`pkg/maps` 当前公开面：

```cute
maps.new[K](sampleK K, vsize int) ptr
maps.set[K](m ptr, key K, valAddr ptr)
maps.get[K](m ptr, key K, out ptr) bool
maps.len(m ptr) uint
```

`new` 的 `sampleK` 只参与类型推断；`vsize` 是值的字节宽。

---

## 4. 负数索引与切片步长（x86_64）

### 4.1 负数索引

- 索引表达式先求值；若 `idx < 0`，运行期执行 `idx += len`，再做边界检查。
- 归一化后仍越界时走 `_panic_index_oob`：向 stderr 打印 `index out of range`，
  进程退出码 1。
- 定长数组的常量负索引同样先归一化；数组长度在编译期已知。
- 负数索引写入 `arr[i] = v` 走同一归一化。
- 当前仅 x86_64 生效；32 位回退旧路径，见 §6。

### 4.2 切片表达式

`a[lo:hi:step]` 是否按切片处理以 `Expression.IndexSlice` 为准（源码中出现
冒号即为切片，包括 `a[lo:]`、`a[:hi]`、`a[:]`），不再用 `Index[1]/Index[2]`
是否为空推断。

| 形态 | 路径 | 结果 |
|---|---|---|
| 无 step，边界均非负/动态 | 视图 | 复用原缓冲，ptr/len/cap 按 `lo` 调整 |
| 有 step，或常量负边界 | 新缓冲 | 分配 `cnt * elemSize`，按 step 跨步拷贝 |
| 动态负边界，无 step | 视图（未归一化） | 已知限制，见 §6 |
| step == 0 | 新缓冲 | 结果为空 |
| step > 0 缺省 lo/hi | — | `lo=0`、`hi=len` |
| step < 0 缺省 lo/hi | — | `lo=len-1`、`hi=-1` |

显式负边界在高级路径中先 `bound += len`。切片端点越界**不新增检查**，保持
旧切片行为；元素读取的边界检查仍由索引路径负责。

`sliceExpAdvanced` 先分配并拷贝，再把 ptr/len/cap 装寄存器、撤销临时帧，
最后写入调用方结果槽，避免结果写进已释放的栈帧。

---

## 5. 函数重载

### 5.1 标签（mangling）

| 情形 | 标签 |
|---|---|
| 非重载函数 | 原名 |
| 同名不同 arity | `name + arity` |
| 同名同 arity 多定义 | `name + arity + "_" + 类型标签` |
| `MangledOverride` 非空 | 直接使用 override（优先级最高） |

类型标签由形参类型生成（`int`/`string`/`p_int`/`list_int`/`map_string_int` …）；
超过 64 字符时保留前 16 字符 + FNV-1a 32 位 8 位十六进制哈希。`main` 永不
加后缀。

### 5.2 选择

1. 收集同名全部候选（排除 `build` 忽略项），按 arity 与实际参数数过滤。
2. 同 arity 按实参类型打分：精确类型优先，常量 `0` 可匹配指针。
3. 最高分唯一 → 选中；同分且签名不同 → 歧义错误。
4. 解析期尚未看到全部定义时返回 `false` 等待重试；包合并后
   `RebuildOverloadRegistry(root)` 重建注册表，并设置 `FinalCheck`，只有最终
   Check 才把“无匹配重载/歧义”当成致命错误。
5. 函数指针赋值按注解 `fn(...)` 类型选择重载，汇编标签直接取
   `FuncBlock.MangledName()`。

---

## 6. 已知限制

- **动态负边界 + 无 step**（如 `a[i:]`，`i` 为负变量）仍走旧视图路径，不做
  归一化；需要负边界时请显式使用 step，或先算好正索引。
- **x86（32 位）**：负数索引与步长切片回退旧路径，属 Batch 4 收口范围。
- **无 import 的 `maps.len(m)`**：`MapType` 目前不会自动匹配到 `ptr` 形参，
  会报 `no matching overload`；请用内建 `len(m)`。
- **`maps.new` 直接赋给 map 变量**：`var m: map[K]V = maps.new[K](...)` 仍报
  `need type , not ptr`；请先用 `var m: map[K]V` + `m[k] = v` 自动初始化，
  或把 `maps.new` 结果存入 `ptr` 变量再 `unsafe.cast`。
- **`_panic_index_oob` 消息长度**：实现固定发送 21 字节，但消息实际 19 字节，
  stderr 可能带尾部垃圾字节；退出码 1 不受影响。属既存问题。
- 方法重载未单列验收；当前方法调用复用同一候选选择逻辑。

---

## 7. 验收

```bash
# 构建
go build -o /tmp/opencode/bin/cute .

# 核心用例（均输出 ALL PASS 并退出 42，另有说明除外）
./cute test/intrinsic_string
./cute test/intrinsic_auto
./cute test/overload
./cute test/overload_types
./cute test/map_index
./cute test/neg_index_step

# 回归
./cute test/array_basic          # PASS: ALL
./cute test/slice_test           # x=42 *p=42 10
./cute test/strings              # PASS: ALL，退出 60
./cute test/mp_map               # 退出 74（既有基线）
BIN=/tmp/opencode/bin/cute scripts/selfhost_parse.sh x86_64
```

`CUTE_NO_INTRINSIC=1` 时 `test/intrinsic_string` 应回退旧比较路径（内容不同址
时失败），且无 import 的 `slices.len/cap` 不再自动解析；用于定位回归。
