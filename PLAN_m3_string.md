# M3 string 支持计划

> 前置：M1（字段访问）、M2（list 三字段容器）已完成，见 `CHANGES.md` 与 `PLAN_m2_fix.md`。
> 目标：test/string 双架构通过；同步解锁 test/string_operations（41）、complex_test 的 stringOperations（31）与最终 exit=17。

## 1. 现状调研（已验证）

string 已具备的基础（M1/M2 产物）：
- 三字段容器模型 `{ptr, len, cap}`（x64: 0/8/16；x86: 0/4/8），`isListLike`/`listFields`/`emit3`/`copySlots`/`storeVal` 等工具函数可用
- `len(s)` 内建：builtinCall 已支持 list/string 读三槽
- list 字面量内 string 元素：getStringLabel 生成 `.data` 标签并写三槽（listLiteral 内）
- callee 端参数偏移：setArgsOffset 按 `arg.Type.Size()` 递增（x86 已确认 Size 步长；x64 同），string 参数在栈/帧上占三槽位置已预留

M3 缺失项（全部集中在调用/装载/拼接）：

| # | 缺失项 | 现状表现 | 位置 |
|---|--------|----------|------|
| 1 | string 常量装载 | `val()` 对 string 常量返回 `FormatFloat(Num)` = "0"，`var s = "hello"` 生成 `mov QWORD [addr], 0` | compile/exp/exp.go `val()`/`leaf()` |
| 2 | string 变量读取 | leaf() 变量分支只 mov 单槽（ptr），len/cap 槽被忽略 | compile/exp/exp.go `leaf()` |
| 3 | string 参数传递（caller） | x64 寄存器参数 `Exp(arg, sysvArgRegs[i])` 单槽；栈参数 `Exp(arg, "push")` 单槽；x86 `push` 单槽（只有 indexAccessGeneric 有多槽 push 特判） | linux_sysv.go `Call`、x86/cdecl.go `Call`、exp.go `leaf()` push 分支 |
| 4 | string 返回值 | returnValue 只写 RAX/EAX 单槽（x86 的 EDX:EAX 是 64 位整数，非容器） | x86_64/ops.go、x86/ops.go `returnValue` |
| 5 | string 拼接 `+` | 无分派，走 binLR 生成 `add`（数值相加，完全错误） | compile/exp/exp.go `generate()` |
| 6 | string 比较 `==`/`!=` | 无实现（test/string 未使用，列为可选） | compile/exp/exp.go |

## 2. 设计（遵循总计划 PLAN_string_list_heap_struct.md 2.1/2.1b）

- **Go string 语义**：len 返回字节数；string 变量赋值 = 拷贝三字段（共享底层）；零值 `""` = `{0,0,0}`
- **内存布局**：内容始终双 NUL 结尾（`\x00\x00`），与 C char* 互操作
  - 常量：`.data` 段 `str_N: db "<字节>", 0, 0`，装载 = `{label, len(字节数), len}`
  - 运行期分配（拼接）：`malloc(align8(l1+l2+1))`，尾部写双 NUL
- **cap 规则**：`cap = align8(内容字节数+1) - 1`（NUL 预留）
- **拼接 `+`**：
  - 常量折叠：两侧 string 常量 → 折叠成单个常量（foldArith 扩展）
  - 运行期：`malloc(align8(l1+l2+1))` + 两次 memcpy（按 len 字段，非 C strcpy，避免内容含 NUL）+ 尾部双 NUL + 三槽装载
- **追加 `+=`**：`len + lt + 1 <= cap` 直接 memcpy 尾部更新 len 重写双 NUL；不足则 `realloc` 扩容（newCap = `max(cap*2, align8(len+lt+1)) - 1`）。注：test/string 用的是 `result = result + s`（赋值+拼接），`+=` 语法本身待确认 parser 支持，列为可选
- **比较 `==`/`!=`**：先比 len，再按 len 逐字节比（可选，后续）

## 3. 实现步骤（顺序依赖）

### 步骤 1：string 常量/变量装载（compile/exp/exp.go）
- `leaf()`/`val()`：string 常量（`StringVal != ""`）→ `getStringLabel` + `emit3(result, label, len, len)`；`result == "push"` 时三槽 push
- `leaf()` 变量分支：`isListLike(exp.Var.Type)` 时三槽装载（`VarAddr` 基址 + emit3 从内存读三槽，或 push 三槽）；非容器类型保持单槽
- 复用 `listFieldRead`/`copySlots` 思路，新增 `loadContainer(result, baseAddr, isPush)` 统一入口（list 也可复用）

### 步骤 2：string 参数传递（caller 端）
- **x86_64**：list/string 参数（Size > 指针宽度）：
  - 寄存器参数：连续 3 个 sysvArgRegs（如 RDI/RSI/RDX 一组），从参数地址读三槽；argRegIdx 前进 3
  - 栈参数：压 3 槽（顺序与 callee 槽序一致：ptr 低地址在栈顶方向需按 cdecl 序逆推，具体以 callee 读取顺序为准：callee `[rbp+off]` 是 ptr 槽，故 caller 先 push cap、再 len、最后 ptr）
- **x86**：栈传参压 3 槽（顺序同上）
- callee 端：偏移已按 Size 预留，无需改；但读取参数值走步骤 1 的三槽装载

### 步骤 3：string 返回值（>8B 最小方案，总计划 2.4）
- 编译器插入隐藏临时槽：函数 prologue 在 rbp 内预留 24 字节（x64）或 12 字节（x86）
- `returnValue`：string 返回值先拷三槽到临时槽（callee 侧）
- 调用端：`leaf()` Call 分支对 string 返回类型，call 后从临时槽拷回目标
- 临时槽基址需在编译函数时分配（仿局部变量分配，取不与现有局部变量冲突的偏移）

### 步骤 4：string 拼接 `+` 分派（compile/exp/exp.go）
- `generate()` 在 binLR 之前分派：`exp.Separator == "+"` 且两侧类型为 string（或一侧 string 常量）
- 常量折叠：foldArith 的 `"+"` 分支，两侧 string 常量 → 拼成一个 StringVal 常量（`isListLike` 检查在折叠前）
- 运行期：左串 ptr/len（常量标签或变量三槽）、右串 ptr/len → malloc → memcpy 两段 → 双 NUL → emit3
- 寄存器规划：左/右 ptr+len 各 2 个寄存器 + callee-save 存新 ptr，注意避开 ReturnReg（malloc 破坏 RAX）

### 步骤 5：测试修正与验证
- test/string/main.cute：注释"字符数"改"字节数"；"你好世界" 4 改 12；期望 92 → 100
- 逐级验证：`stringLength`（参数）→ `stringConcat`（参数+拼接+返回值）→ `stringRepeat`（循环拼接+返回值）→ main 全量
- gdb 断点复查各子函数值

## 4. 验证清单

| 测试 | 期望 | 说明 |
|------|------|------|
| test/string x86_64 / x86 | exit=100 | 期望值随字节数语义修正 |
| test/string_operations x86_64 / x86 | exit=41 | M3 同根因 |
| test/complex_test x86_64 / x86 | exit=17 | stringOperations=31 后 total=3089 mod 256 |
| 全量回归 | 无回归 | 重点：list、list_test、struct_test、control_flow、simple、complex_expressions（若可） |

## 5. 风险与注意

- **ABI 改动影响面**：参数/返回值三槽改造影响所有带 string 参数或返回值的函数，需全量回归
- **寄存器压力**：string 参数占 3 个参数寄存器；拼接需同时持有左右 ptr/len（4 值）+ 新 ptr，注意 regmgr 冲突（allocRegAvoid）
- **push 顺序**：x86 栈参数 3 槽顺序必须与 callee `[ebp+off]` 读取一致（off 按 Size 递增，ptr 槽在低地址，故 caller 先 push 高地址槽 cap、再 len、最后 ptr）
- **嵌套调用**：string 参数内嵌函数调用（如 `f(g("a"), "b")`）时 g 的返回值三槽拷贝要在 f 的参数装载前完成，避免寄存器覆盖
- **无 GC**：拼接 malloc 产物不回收，测试内可接受（与总计划一致）
- **x86 返回值**：x86 的 EDX:EAX 是 64 位整数路径，string 走隐藏临时槽，不与其混淆
- **test/string 期望值修改**：需同步修改注释，避免后续维护误解

## 6. 关键文件

- compile/exp/exp.go：leaf()/val() 三槽装载、generate() string 拼接分派、foldArith `+` 常量折叠、Call 分支返回值三槽拷贝
- compile/arch/x86_64/linux_sysv.go：寄存器/栈参数三槽装载
- compile/arch/x86/cdecl.go：栈参数三槽装载
- compile/arch/x86_64/ops.go、compile/arch/x86/ops.go：returnValue 隐藏临时槽
- test/string/main.cute：期望值修正
- test/string_operations、test/complex_test：验证

## 7. 里程碑内顺序

1. 步骤 1（装载）→ test/string 里 `stringLength("hello")` 类常量参数场景
2. 步骤 2（参数）→ stringLength 全量
3. 步骤 3（返回值）+ 步骤 4（拼接）→ stringConcat / stringRepeat
4. 步骤 5（测试修正+验证）→ test/string exit=100
5. string_operations、complex_test 验证，全量回归