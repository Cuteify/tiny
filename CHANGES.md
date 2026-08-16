# 全部代码更改说明（相对基线 4a3dc25）

> 本文件解释自基线提交 4a3dc25 以来所有未提交的代码更改：现象、根因、修复方案与验证结果。
> 对应计划文件：`PLAN_m2_fix.md`（修复计划与状态）、`PLAN_string_list_heap_struct.md`（M2/M3/M4/M5 总计划）。

## 目录

1. [列表/字符串三字段容器支持（M1 主干）](#一列表字符串三字段容器支持m1-主干)
2. [变量/字段寻址系统](#二变量字段寻址系统)
3. [this/self 指针与值语义](#三thisself-指针与值语义)
4. [函数调用与参数传递](#四函数调用与参数传递)
5. [M2 收尾修复](#五m2-收尾修复)
6. [内存运行时新增 realloc](#六内存运行时新增-realloc)
7. [测试配置](#七测试配置)
8. [验证状态](#八验证状态)
9. [遗留问题](#九遗留问题)

---

## 一、列表/字符串三字段容器支持（M1 主干）

### 1.1 容器内存模型

list 与 string 在运行时统一表示为三字段容器 `{ptr, len, cap}`：

| 架构 | ptr 偏移 | len 偏移 | cap 偏移 | 指针宽度 |
|------|---------|---------|---------|---------|
| x86_64 | 0 | 8 | 16 | 8 字节 |
| x86 | 0 | 4 | 8 | 4 字节 |

- `ptr`：元素缓冲区指针（string 为字符缓冲区指针）
- `len`：当前元素数量
- `cap`：缓冲区容量

`compile/exp/exp.go` 新增 `listFields()` 返回三槽偏移；`isListLike()` 判断 list/string 类型；`align8()` 做 8 字节对齐（malloc 对齐要求）。

### 1.2 新增表达式编译节点

`ECompiler.generate()` 增加列表/字符串专有节点分派（compile/exp/exp.go）：

| 节点 | 说明 |
|------|------|
| `list_lit` | 列表字面量 `[]int{1,2,3}`，运行时 malloc 分配（Go 语义） |
| `[]` | 索引读 `a[i]` 或切片 `a[i:j]`、`a[i:j:k]` |
| `[]=` | 索引赋值 `a[i] = v` |

新增函数：

- `listLiteral`：空列表 = `{0,0,0}`（`emitZero3`）；非空先 `emitMalloc(align8(n*elemSize))`，逐元素写入缓冲区，string 元素三槽拷贝（`copySlots`），最后 `emit3` 装载结果三字段。
- `indexAccess` / `indexAccessGeneric`：计算 `ptr + idx*elemSize`（常量索引直接加立即数，非常量索引经寄存器 `imul`），再按元素宽度读。元素大于指针宽度（如 string 元素）时整体拷贝三槽；`result == "push"`（32 位栈传参）时按高地址槽优先逆序多槽入栈。
- `indexSet`：索引赋值。值先算到寄存器（地址计算无函数调用，值可跨指令安全保存），再取列表指针、计算索引偏移、`derefStore` 写入。
- `sliceExp`：切片装载 `{ptr+lo*es, hi-lo, 原cap-lo}`。lo/hi 支持常量和寄存器两种形式。
- `listFieldRead`：读容器字段 `len`/`cap`。变量直接读三槽；表达式先算 ptr 再 `[reg+off]`。
- `builtinCall`：`len`/`cap`（list/string 参数时读三槽）、`append`、`make` 内建分派。非内建返回空串，继续走叶子（普通函数调用）。
- `builtinAppend`：`len < cap` 直写 `[ptr+len*es]` 并递增 len；否则扩容 `newCap = max(cap*2, 1)`，`realloc` 后重读 len 写元素并回写三槽。值先存 callee-save 寄存器（跨 realloc call 安全）。
- `builtinMake`：`make([]T, len[, cap])`。`malloc(align8(cap*es))`，零填充 `len*es` 字节（常量展开逐槽写；非常量循环 `[callee+reg*ps-ps]`），装载三字段。
- `ZeroVar`：无初值容器变量（`var a: []int`）三槽清零。配套删除 `VarDecl` 中 `Value == nil` 提前返回（compile/compiler.go、两个架构的 ops.go VarDecl）。

### 1.3 表达式收集

`collectRec`（compile/exp/collect.go）新增对 `exp.Index` 子表达式（`[i]`、`[i:j]`、`[i:j:k]`）的递归收集。此前 `[]` 节点 Index 里的表达式无 ExpInfo，`allocRegAvoid` 会崩溃（complex_test SIGSEGV）。

### 1.4 字符串常量

`getStringLabel` 注册字符串常量到 `ctx.StringConsts`，生成 `str_N` 标签。list 字面量中的 string 元素直接引用标签并写三槽。

---

## 二、变量/字段寻址系统

### 2.1 Find 路径记录（parser/finder.go）

`Find` 在类型路径查找（`enterTypeFind`）命中时，把访问链上的基础节点/类型记录到 `FindResult.Path`：

- 字段/元素查找命中时 `r.Path = append([]any{基础节点}, r.Path...)`（基础节点可以是 VarBlock、ArgBlock、FuncBlock）
- `enterTypeFind` 在开始时把起始类型（`nowType`）压入 `findPath`，即 `Path[0]` 是访问前的起始类型

编译层据此恢复"基础变量/参数在栈上的偏移"与"访问前的起始类型"，是字段偏移计算的前提。

### 2.2 字段偏移计算（compile/arch/x86_64/utils.go、x86/utils.go）

新增/实现：

- `calcFieldOffset`：从 `Define.Path[0]` 解析基础类型（Type/VarBlock/ArgBlock/FuncBlock/StructField 均可），指针先解引用，再走 `walkFieldOffsets` 累加 `v.Name[1:]` 字段路径偏移。
- `walkFieldOffsets`：沿字段路径逐层 `st.Layout()` + `st.Field()` 累加 `field.Offset`；指针字段在中间层自动解引用。
- `calcThisFieldOffset`：从 `ctx.Now` 向上找当前函数（FuncBlock.Class）取 this 类型，指针解引用后走 `walkFieldOffsets`。此前是 TODO 占位返回 0。
- `calcListIndexOffset`：列表索引访问（`a[i]`、`a[i].len`）从 Path 恢复列表类型，常量索引累加 `idx*elemSize`，`.len`/`.cap`/`.ptr` 映射到三槽偏移；非常量索引返回 0（运行时计算）。
- `GenVarAddr` 的 `FindTypeField` 分支：基础偏移取自 `Define.Path[0]` 的 VarBlock/ArgBlock 偏移。

### 2.3 多段名赋值（compile/compiler.go）

`compileExprBlock` 新增：表达式语句若携带完整 VarBlock（`exp.Var != nil && exp.Var.Value != nil`，如 `p1.x = 3`、`self.x += dx`），转用 `VarDecl` 路径生成正确的目标地址，不再走通用 `Exp`。

### 2.4 表达式索引不再被 ParseName 吞掉（parser/name.go）

`ParseName` 遇到 `[` 时停在原地交给 `ParseExp` 处理（`list[0]`、`self.data[i]`），删除旧的 `parseNameSlice` 吞索引逻辑。索引进 `Expression.Index`。

---

## 三、this/self 指针与值语义

### 3.1 变量赋值与读取的间接寻址（compile/exp/exp.go）

this/self 是**指针**，字段访问必须间接寻址。新增：

- `isThisField`：判断变量是否为 `this.x`/`self.x` 形式。
- `thisMem`：生成间接寻址。先 `mov reg, [rbp+16]`（x86 为 `[ebp+8]`）取 this 指针，再加字段偏移（`fieldOffsetOf` 沿 `Define.Path[0]` 类型累加），返回 `(前置代码, 地址表达式, 临时寄存器)`。
- `Assign`：赋值时 this/self 字段走 `thisMem` 间接寻址写入，普通变量走 `VarAddr` 直接写。
- `leaf` 读取：this/self 字段先加载 this 指针再 `derefLoad`；`result == "push"` 时 push 到栈。
- `allocTmpReg`/`freeTmpReg`：临时寄存器分配，避开 ReturnReg（derefLoad/derefStore 用 ReturnReg 作中转）。

### 3.2 传参时的 this 指针（compile/arch/x86_64/linux_sysv.go、x86/cdecl.go）

- x86_64：this 作为第一寄存器参数（sysvArgRegs[0]）。this 为非指针类型（值语义）时用 `lea` 取地址传入（结构体传地址）。
- x86：修复压栈顺序。原先 this 最先压入（错误，this 应在 [ebp+8]）；改为先压参数（从右到左）、最后压 this。this 值语义时 `lea eax, [地址]` 后压 eax。

### 3.3 方法参数偏移（compile/arch/x86_64/ops.go）

`setArgsOffset`：方法（Class 非 nil）首个参数从 `rbp+24` 起，`rbp+16` 被 this 占用。此前方法参数从 rbp+16 起，与 this 冲突。

### 3.4 方法调用解析（parser/call.go）

- `Check`：找到的 Func 属于类（Class 非 nil）时，若 Name 是路径（`a.method`）且无 ThisVar，用路径最后一段作接收者构造 ThisVar（`Name[:len-1]`）。
- 包名被方法分支误判为接收者时，仅当 `fb.Class == nil` 才清除伪 ThisVar（原先无条件清除，导致方法调用丢失 this）。

---

## 四、函数调用与参数传递

### 4.1 嵌套调用游标推进（parser/call.go）

`ParseCall` 的 `,` 与 `)` 分支增加游标保护：

- `)`：仅当 `p.Lexer.Cursor <= stopCursor` 才 `Skip(')')`，防止嵌套调用（如 `f(g(x), y)`）内部参数解析时越界跳过外层 `)`。
- `,`：仅当 `p.Lexer.Cursor <= token.Cursor` 才 `SetCursor(token.Cursor+1)`，防止重复消费。

### 4.2 参数装载 push 特判（compile/exp/exp.go）

`derefLoad` 新增 `dst == "push"`（32 位栈传参）分支：直接 `push prefix [src]`；BYTE/WORD 元素先 `movzx` 到 ReturnReg 再 push（栈对齐）。此前生成 `mov push, [mem]` 非法指令（x86 编译报错）。

---

## 五、M2 收尾修复

### 5.1 imul 内存目标栈中转（compile/arch/x86_64/ops.go、x86/ops.go）

**现象**：`InstBinary` 的 `*` 在 dst 为内存时生成 `imul [mem], reg`，nasm 报错（不支持 imul 内存目标）。

**修复**：dst 含 `[` 时栈中转：

```
src 为内存时: mov RAX/EAX, src
push src            ; 暂存乘数
mov RAX/EAX, dst
imul RAX/EAX, qword/dword [rsp]
mov dst, RAX/EAX
add rsp, 8/4        ; 清理乘数
```

### 5.2 移位计数 CL 中转（compile/arch/x86_64/ops.go、x86/ops.go）

**现象**：`shl [mem], RAX` 非法。nasm 的 shift count 只接受 CL 寄存器或立即数。

**修复**：src 非立即数且非 CL 时栈中转低字节到 CL：

```
src 为内存时: mov RAX/EAX, src
push src            ; 暂存移位计数
mov cl, byte [rsp]
shl/sar dst, cl
add rsp, 8/4        ; 清理移位计数
```

立即数判断用新增 `utils.IsNumber`（utils/utils.go）：整数（含负号前缀）。

### 5.3 常量折叠 `^` 与编译不一致（parser/exp_check.go）

**现象**：`0 ^ 30` 常量折叠得 0（`math.Pow(0, 30)` = 0），而编译层 `^` 生成 xor（运行得 30）。`28 | (0 ^ 30)` 折叠成 28（28|0），运行却是 30（28|30）。常量折叠与指令生成语义矛盾。

**修复**：`foldArith` 的 `case "^"` 由 `math.Pow(left, right)` 改为 `float64(int(left) ^ int(right))`，删除 math import。验证：`0 ^ 30` = 30、`28 | (0 ^ 30)` = 30、`255 ^ 15` = 240。

### 5.4 ParseExp 括号退出后优先级错误（parser/exp.go）

**现象**：`(x+y)*(z-x)/(y+1)%(z+2) | (x&y) ^ (y|z)`（x=10,y=20,z=30）返回 2，期望 30。汇编显示按 `(28 | (x&y)) ^ (y|z)` = `(28|0)^30` = 2 计算，即 `^` 比 `|` 更高优先级时仍左结合。

**根因**：运算符结合分支的条件 `!(justExitBracket && isRoot)` 一刀切禁止"退出括号后高优先级运算符结合当前节点的右操作数"。该条件本意是处理括号内根场景（如 `(x+y)*d`：`+` 是括号内根，`*` 应把 `+` 整体作为左操作数，即 BeParent 保持左结合）。但误伤了括号外根场景（`A | (x&y) ^ C`：`(x&y)` 已插入 `|`.Right，`)` 回溯到 `|`，`^` 优先级更高时应抢走 `|`.Right，即第一分支）。

**修复**：新增 `bracketChild` 标志。`)` 时若 `current.Father != nil`（回溯到父节点，说明括号表达式已作为父节点的操作数插入）置 true，否则 false（current 是括号内根）。结合条件改为 `!(justExitBracket && !bracketChild)`：

- 括号内根（bracketChild=false）：禁止第一分支，走 BeParent，保持左结合（`(x+y)*d` 正确）。
- 括号外父节点（bracketChild=true）：正常按优先级处理（`A | (x&y) ^ C` 中 `^` 结合 `|`.Right 得 `A | ((x&y)^(y|z))`）。

顺带修正 `a + (b*c) / d` 类场景（原代码同样错误：`/` 比 `+` 高时被误判左结合）。`bracketChild` 与 `justEnterBracket`/`justExitBracket` 同步生命周期（运算符分支末尾重置）。

**验证**：complexExpression 2 → 30；multiCondition=2、nestedLoops=210 不变。

### 5.5 调试代码清理

移除所有临时调试打印（parser/return.go 的 RETEXPNIL/RETEXP、compile/exp/exp.go 的 BINNIL/BINARY^/UNARY^/BINLR^/RETN/RETVAL、compile/arch/x86_64/ops.go returnValue 打印）及多余 fmt import。`grep RETEXP|BINNIL|BINARY^|UNARY^|BINLR` 确认无残留。

---

## 六、内存运行时新增 realloc（pkg/memory/memory_x86.cute、memory_x86_64.cute）

新增 `realloc(ptr, new_size)`（append 扩容用）：

1. `ptr == 0`：等价 `malloc(new_size)`。
2. 从块头读旧大小（x64：`load64(ptr-8)-16`；x86：`load32(ptr-4)-8`，块头存 size + 指针）。
3. `malloc(new_size)` 新块，失败返回 0（原 ptr 保持有效）。
4. 逐字节拷贝 `min(old_size, new_size)`（load8/store8 循环）。
5. `free(ptr)`，返回新指针。

---

## 七、测试配置

以下测试目录 package.json 补充 `"imports": {"memory": "std:memory"}`：

- test/list、test/list_test：缺失导致 `std_memory_malloc1 not defined` 链接错误。
- test/complex_test：同样缺失（原文件缺 imports 字段且末尾无换行）。

---

## 八、验证状态

### 通过（双架构一致）

| 测试 | x86_64 | x86 |
|------|--------|-----|
| test/list | 33 | 33 |
| test/list_test | 0 | 0 |
| test/struct_test | 0 | 0 |
| control_flow / bitwise / deref_test / edge_values / fib30 / fs_test / function_calls / link_test / mem_suite / operator_precedence / recursion / scope_test / simple / simple_var / struct | 双架构一致 | 双架构一致 |

### complex_test 子函数定位（gdb 断点实测）

| 子函数 | 实测 | 期望 | 状态 |
|--------|------|------|------|
| listOperations | 224 | 224 | ✓ |
| structOperations | 39 | 39 | ✓ |
| matrixOperations | 17 | 17 | ✓ |
| recursiveTests | 1199 | 1199 | ✓ |
| bitwiseTests | 1337 | 1337 | ✓ |
| expressionTests | 242 | 242 | ✓（complexExpression=30、multiCondition=2、nestedLoops=210） |
| stringOperations | 12632304 | 31 | ✗（M3，见遗留问题） |

total 期望 224+31+39+17+1199+1337+242 = 3089，exit = 17（mod 256）。

### 基线对照（git stash 对比 4a3dc25）

以下测试在基线同样失败，非本次回归：complex_expressions（nasm expression syntax error）、memory_test（x86_64 invalid operand sizes）、frontend_test / simple_method / struct_method（编译期 MissError）、string（M3）、string_operations（M3）。

---

## 九、遗留问题

### string 参数只传 ptr 槽（M3 范畴）

`stringOperations` 返回垃圾值（12632304）。根因：string 参数传递只传 ptr 槽，callee 读 len 槽得到垃圾。complex_test 的 string 拼接（`s1 + " " + s2`）、`repeatString` 均涉及。修好 string 参数三槽传递后，可同时解锁：string（期望 92）、string_operations（期望 41）、complex_test（exit=17）。

### 基线既有失败（非回归，不属 M2 范围）

complex_expressions、memory_test、frontend_test、full_syntax_test、simple_method、struct_method、arithmetic_test、comprehensive、multi_package_test、runtime 系列、asm_test、bitwise（目录）、scope_test（目录）、as_test / build_test / "test copy"（空目录）。