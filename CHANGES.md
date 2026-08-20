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
7. [io 库文件操作](#七io-库文件操作)
8. [测试配置](#八测试配置)
9. [验证状态](#九验证状态)
10. [遗留问题](#十遗留问题)
11. [M3 收尾](#十一m3-收尾complex_test-双架构全绿本次会话)
12. [标准库整理](#十二标准库整理io-复用-syscall跨包调用修复本次会话)
13. [std:strings 重写](#十三stdstrings-重写为-linkname-全局符号方案本次会话)
14. [标准库拆分 fs/console 与 x86_64 参数装载修复](#十四标准库拆分-fsconsole-与-x86_64-参数装载修复本次会话)
15. [else 块跨包调用修复 + toString 负数修复](#十五else-块跨包调用修复--tostring-负数修复本次会话)
16. [M5 补强：\*T 函数参数/返回类型 + 嵌套 struct 字段](#十六m5-补强t-函数参数返回类型--嵌套-struct-字段本次会话)

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

## 七、io 库文件操作

### 7.1 库结构（pkg/io/）

`io.cute`（公共定义）+ `io_x86_64.cute` / `io_x86.cute`（架构 syscall 实现）：

- `open(path string, flags i32, mode u32) i32`：open 系统调用
- `read(fd i32, buf *u64, count u64) i32` / `write(fd i32, buf *u64, count u64) i32`：读写
- `close(fd i32) i32`
- `print(s string)` / `println(s string)`：基于 io.STDOUT 构建，`build asm` 内联 `repne scasb` 求字符串长度（x86_64 版用 RDI 装载、RCX=-1 + not/dec；x86 版用 push ECX 保存），不再依赖 runtime 外部符号（runtime/ 目录从不编译）
- 常量：STDOUT/STDIN/STDERR、O_RDONLY/O_WRONLY/O_RDWR/O_CREAT/O_TRUNC/O_APPEND（十进制值）

### 7.2 语言能力缺口与绕过

| 缺口 | 现象 | 绕过 |
|------|------|------|
| 函数参数 `[]u8` 类型 | 冒号风格只认名字类型、无冒号风格 `[`/`]` 被当分隔符，报 cannot use []u8 as type u8 | read/write 参数改用 `*u64`（指针缓冲） |
| `0x` 十六进制字面量 | const 与 var 初始化均解析崩溃 | 全部用十进制（如 11473676690792 = "hello\n" 小端 8 字节） |
| `*(u8*)(x)` 类型转换 | u8 被解析为变量，报 undefined variable | 不用类型转换 |
| 缺失 strlen | `call strlen` 链接失败 | build asm 内联 repne scasb |

### 7.3 编译器修复

1. **parser/func.go ParseArgs**：SEPARATOR 分支支持 `*`/`[` 前缀类型（SetCursor 回退 + parseTypeAnnotation），`buf *u64` 可解析。
2. **全局变量名含路径**：`__global_` + 完整 Name 的 NASM 名（compiler.go:75 生成端、x86/x86_64 utils.go 引用端统一，新增 globalVarName helper 从 v.Define.Value.(*parser.VarBlock) 取定义块名）。原实现只取 Name.First() 导致 9 个 const 同名重定义。
3. **Name.First() 语义修复**（parser/name.go）：首段非 PkgPath 返回首段；首段 PkgPath 返回连续 PkgPath 段。
4. **FixPathName 逐字节修复**（package/fmt/fmt.go）：原 range rune 按字节下标写字节，中文路径（如"代码"）产生 NUL 字节。
5. **64 位常量装载**（compile/exp/exp.go leaf）：`mov r/m64, imm` 在 NASM 只支持 imm32（符号扩展），大常量被截断成低 32 位（文件内容 "hell\0\0"）。超过 32 位的常量拆成高低两条 `mov dword`（新增 hiMemAddr）；x86 32 位模式任何 QWORD 内存常量赋值一律拆分（含 0）。
6. **x86 cdecl string 参数压栈**（compile/arch/x86/cdecl.go）：string 形参槽 12 字节（ptr+len+cap）但实参只压 4 字节 ptr，多参数函数全部错位（open 的 flags/mode 被 path 吞掉，open 以 O_RDONLY 打开文件导致 write 失败）。修：cap/len 补 0 先压、ptr 最后压，共 12 字节。

### 7.4 验证

`test/io_test`（main.cute：open O_WRONLY|O_CREAT|O_TRUNC → write "hello\n" 6 字节 → close → 读回校验 6 字节 → println）：

- x86_64 exit=0、x86 exit=0；io_test.txt 内容 `68 65 6c 6c 6f 0a`（hello\n）。
- 全量回归对比基线 4a3dc25：无新增失败；bitwise、list、list_test、scope_test 由基线失败转为通过。

---

## 八、测试配置

以下测试目录 package.json 补充 `"imports": {"memory": "std:memory"}`：

- test/list、test/list_test：缺失导致 `std_memory_malloc1 not defined` 链接错误。
- test/complex_test：同样缺失（原文件缺 imports 字段且末尾无换行）。

---

## 九、验证状态

### 通过（双架构一致）

| 测试 | x86_64 | x86 |
|------|--------|-----|
| test/list | 33 | 33 |
| test/list_test | 0 | 0 |
| test/struct_test | 0 | 0 |
| test/string | 100 | 100 |
| test/string_operations | 50 | 50 |
| test/complex_test | 17 | 17 |
| control_flow / bitwise / deref_test / edge_values / fib30 / fs_test / function_calls / link_test / mem_suite / operator_precedence / recursion / scope_test / simple / simple_var / struct | 双架构一致 | 双架构一致 |

### complex_test 子函数定位（gdb 断点实测）

| 子函数 | 实测 | 期望 | 状态 |
|--------|------|------|------|
| listOperations | 224 | 224 | ✓ |
| stringOperations | 31 | 31 | ✓ |
| structOperations | 39 | 39 | ✓ |
| matrixOperations | 17 | 17 | ✓ |
| recursiveTests | 1199 | 1199 | ✓ |
| bitwiseTests | 1337 | 1337 | ✓ |
| expressionTests | 242 | 242 | ✓（complexExpression=30、multiCondition=2、nestedLoops=210） |

total 期望 224+31+39+17+1199+1337+242 = 3089，exit = 17（mod 256）。

### 基线对照（git stash 对比 4a3dc25）

以下测试在基线同样失败，非本次回归：complex_expressions（nasm expression syntax error）、memory_test（x86_64 invalid operand sizes）、frontend_test / simple_method / struct_method / runtime / test（编译期 MissError）、complex_test / full_syntax_test / struct / asm_test（nasm expression syntax error / invalid combination）、string（M3）、string_operations（M3）。

以下测试在基线失败、本次已修复：bitwise（nasm {nf} 错误 → exit=9）、list（nasm 62/64 → exit=33）、list_test（nasm:18 → exit=0）、scope_test（nasm:125 → exit=119）。

---

## 十、遗留问题

### 基线既有失败（非回归，不属 M2 范围）

complex_expressions、memory_test、frontend_test、full_syntax_test、simple_method、struct_method、arithmetic_test、comprehensive、multi_package_test、runtime 系列、asm_test、as_test / build_test / "test copy"（空目录）。

### x86 string 多参数传参已修复、单参数此前靠巧合

x86 cdecl 压栈此前对 string 实参只压 4 字节（ptr 槽），而 callee 槽为 12 字节，多参数函数全部错位（open 的 flags/mode 被 path 吞掉）。单参数函数（print_cstr 等）恰好在 [ebp+8] 读到正确 ptr 槽才没暴露。本次已修：string 实参压 12 字节（cap/len 补 0 先压、ptr 最后压）。

---

## 十一、M3 收尾：complex_test 双架构全绿（本次会话）

### 11.1 this/self 字段的容器装载未解引用（matrix 段根因）

现象：complex_test 的 matrixOperations 段 x86 SIGSEGV(139)、x86_64 返回值 26（期望 17）；分段二分定位到 Matrix_get2/set3。

根因：`loadContainer`（exp.go）对容器（list/string）字段用 `VarAddr` 直接寻址。对局部变量正确（`[ebp-24]` 是 m.data 槽），对 this/self 字段错误：this 是指针，`self.data` 的 VarAddr 取到的是 this 指针本身而非 this->data。x86_64 表现为基址错（读 this 结构体内存）；x86 更糟：base 装载用 `[ebp]`（保存的 ebp）且 EAX 被 this 覆盖后把 this 写进 [caller_ebp+offset]，踩坏调用者返回地址 → SIGSEGV。`loadContainerPair`（字符串拼接/append 的 ptr/len 装载）同源同样问题。

修复：
- `loadContainer`：Var 为 this 字段时改用 `thisMem()`（先 `mov TMP,[ebp+8]` 再 `[TMP+off]` 间接寻址），push/copySlots/寄存器三种结果模式统一处理，用后 `freeTmpReg`。
- `loadContainerPair`：同样加 this 字段解引用分支。

### 11.2 indexSet 值寄存器被索引表达式覆盖（x86 特有）

现象：修好 11.1 后 x86 matrix 仍返回 51：Matrix_set3 的 `self.data[r*self.cols+c] = val` 中 val 被覆盖为 this 指针写入内存。

根因：indexSet 先算值到 vReg（常量/参数场景退化为 fallback EAX，未在 regmgr 标记占用），再算地址。x86 只有 4 个 GPR，索引表达式 `r*self.cols+c` 内部编译 self.cols 时 thisMem 在 EBX(aReg)/ECX(lReg)/EDX(rReg) 全忙的情况下走 allocTmpReg fallback 拿到 EAX，`mov EAX,[ebp+8]` 把 val 冲掉，最终 `mov [EBX],EAX` 写入的是 this。

修复：indexSet 调整顺序为先算列表指针+索引偏移（期间 EAX 空闲可安全作临时），值最后装载进 vReg 立即写入。地址计算无调用，顺序调整严格更安全（原来"值先算"在地址含调用时反而会被 caller-saved EAX 覆盖）。

### 11.3 验证

- complex_test：x86_64 exit=17、x86 exit=17（此前 x86 崩溃、x86_64=26）。
- 全量回归双架构一致：string=100、string_operations=50、list=33、struct=207、control_flow=74、simple=116。
- 测试注释更正：string_operations 的 unicode=12、special=12（len 按字节计、`\n` 无转义按字面 2 字节）、sum=50；test/string 的 chinese=12 字节。
## 十二、标准库整理：io 复用 syscall、跨包调用修复（本次会话）

### 12.1 std:io 文件操作改为调用 std:syscall

- `pkg/io/io_x86_64.cute` / `pkg/io/io_x86.cute` 的 open/read/write/close 由内联系统调用改为调用 `std:syscall` 包对应函数，消除重复实现（系统调用号与寄存器约定单一事实来源）。
- 语言层缺少 string 容器取 ptr 槽、`*u64` 转裸地址的语法，io 用 `build asm` 做类型桥接（存入 u64 中转变量后 Cuteify 层调用），签名与行为不变。
- `pkg/io/package.json` 增加 `"syscall": "std:syscall"` 依赖。
- std:memory 本就调用 syscall.brk，未改动。

### 12.2 修复：build asm 的 $局部变量偏移错误

- `compile/build.go`：$var 替换对函数内局部变量使用 Parse 期 Offset（恒 0），此前未暴露（现有 asm 只用参数）。现改为取编译期 SetupVarOffsets 分配的真实偏移（local VarBlock 且 IsDefine）。

### 12.3 修复：子包内 ret/条件/循环表达式的跨包调用解析失败

- `package/package.go` fixPkgNamePaths 只处理 CallBlock/Expression/VarBlock，漏掉 ReturnBlock.Value、IfBlock.Condition、ElseBlock.IfCondition、ForBlock.Init/Condition/Increment，且表达式只查顶层 Call/Var、不递归子表达式。导致 `ret syscall.open(...)` 在子包内解析为 Func=nil、调用不生成代码（编译静默变空跳转）。
- 新增 fixExpNamePaths 递归表达式树（Left/Right/Index/ListElems），并补全上述块类型。

### 12.4 验证

- io_test：x86_64 exit=0、x86 exit=0（此前改造中途曾 SIGSEGV/exit=2）。
- echo：双架构手动管道验证正确（含中文、二进制 NUL/0xff 原样回显，EOF 退出 0）。
- 全量回归双架构一致：string=100、string_operations=50、list=33、struct=207、control_flow=74、simple=116、complex_test=17、io_test=0、echo=0 等 36 个测试目录全部通过。
- 新增 docs/STDLIB.md：标准库函数参考文档（std:syscall/std:memory/std:io/std:fs/std:strings 全函数签名与说明、编译器内建、遗留 runtime/、使用示例）。

## 十三、std:strings 重写为 linkname 全局符号方案（本次会话）

### 13.1 用户架构指令落地：len/cap/eq 进 strings 包 + to_cstring 替代 build asm 桥接

- 编译器新增全局符号生成（`compile/compiler.go` `generateStringSyms`）：`__string_len`/`__string_cap`/`__string_eq`/`__string_ne`/`__string_to_cstring`，双架构定义，x86_64 传容器地址于 RDI（`lea RDI, QWORD[rbp+16]`）、x86 cdecl push 容器地址；x86 槽偏移 +4/+8（三槽各 4 字节），x86_64 +8/+16；`__string_eq/ne` 需先解引用容器取 ptr 槽再比较。
- 符号只在根节点生成一次（`compileRootTail`，避免 Compile 递归重复定义 label），且强制 `section .text` 前缀（此前落在 .data 导致 call 到数据段 SIGSEGV）。
- `compile/build.go` `CompileBuild` 收集被 `call __string_*` 引用的符号（`stringSyms`），未引用不生成。
- `pkg/strings/` 重写为 `strings_x86_64.cute`/`strings_x86.cute`/`package.json`：`len/cap/eq/ne/to_cstring`，经 `build asm` 调上述符号；删除旧 `strings.cute`（依赖全仓库不存在的 `__string_concat`）。旧 concat/cmp/lt/gt/le/ge/char_at 未迁移。
- `pkg/io` open 改用 `strings.to_cstring(path)`（read/write 保留 var p 桥接：语言层无 `*T`→`u64` 隐式转换，x86 指针 4 字节不能直接传 8 字节 u64）；io package.json 增加 strings 依赖。
- 非 void 函数无 ret 可行：`to_cstring` 仅 build asm + 无 ret，RAX 保持经 epilogue 返回，已验证。

### 13.2 修复：嵌套调用参数解析（ParseCall 括号深度）

- `parser/call.go` `ParseCall` 增加括号深度计数：`f(g(x), y)` 中内层 `)` 此前被误判为参数列表结束（报 `expected ')'`，随后 CallBlock.Check 在 `arg.Value.Type.Type()` 处 nil panic）。

### 13.3 修复：表达式调用参数的名字 FixPath 递归

- `package/package.go` `fixExpNamePaths` 增加 `exp.Call.Args` 递归：嵌套调用参数（如 `syscall.open(strings.to_cstring(path), ...)` 的 to_cstring）此前不 FixPath，跨包名解析失败 → Func nil → 编译静默生成空调用。

### 13.4 修复：同包跨文件引用（函数调用与全局变量/常量）

- 新暴露的编译器缺陷：包级函数/全局变量在合并时统一 `SetPkgPath` 加包前缀，而同包跨文件调用/引用在 parse 期解析失败（跨文件不可见）、合并后按原名（无前缀）找不到 → 误报 `undefined variable` / `not found function`（`pkg/memory` 拆分为 memory.cute + memory_x86_64.cute 后首次触发，store64/ptrSize）。
- 修复：
  - `package/package.go`：`fixPkgNamePaths` 的 CallBlock 分支对非路径且 `Func == nil` 的调用补 `SetPkgPath`（同包跨文件函数）；CallBlock 的 Args 也递归 fixExpNamePaths（此前漏掉语句级调用的实参）；`fixExpNamePaths` 对 `exp.Call` 非路径未解析调用、`exp.Var` 非路径且 `Type == nil` 的引用补本包前缀。
  - `parser/exp_check.go` checkVar：parse 期找不到定义时静默返回（不 panic），由合并后 `rootNode.Check()` 统一重试与报错。
  - `parser/name.go` `Name.Check`：对 `IsPkgPath` 段跳过标识符校验（路径段含 `/`、中文等，此前 ParseDefine 报 `name is not valid`）。

### 13.5 修复：pkg/memory 抽象拆分后的命名笔误

- 用户将 memory 包拆分为公共逻辑 `memory.cute` + 架构原语 `memory_x86_64.cute`（新增 `ptrSize` 常量、`uint` 类型化）；`refill` 参数 `blk_size` 与函数体 `blkSize` 不一致（未跟踪文件，导致全量回归多目录 `undefined variable: blkSize`）——统一为 `blkSize`。

### 13.6 验证

- 新增 test/strings_test（imports io+strings）：len（含中文 6 字节）/cap/eq/ne/to_cstring（经 io.open 实际打开文件验证）双架构 exit=0。
- 全量回归：string=100、string_operations=50、list=33、struct=207、control_flow=74、simple=116、complex_test=17、io_test=0、strings_test=0、mem_suite=7、deref_test=7 及 bitwise/callee_save/complex_expressions/edge_values/fib30/function_calls/operator_precedence/recursion/scope_test/simple_var 等全部通过且双架构一致（mem_suite、deref_test 由 13.5 恢复）。
- 基线既有失败不变（见第十节）：asm_test（手写 `add [mem],[mem]` 非法）、frontend_test、simple_method、struct_method、full_syntax_test（`std_memory_malloc1` 硬编码符号从未定义：string concat/append/make/slice 路径）、runtime（build extern 语法）、arithmetic_test/comprehensive（缺 package.json）。
- docs/STDLIB.md 更新：std:strings 章节重写（含 linkname 符号表）、io open 说明、包总览状态。

---

## 十四、标准库拆分 fs/console 与 x86_64 参数装载修复（本次会话）

### 14.1 标准库拆分：pkg/io → pkg/fs + pkg/console

- `pkg/io` 删除，拆为两个包（用户架构指令）：
  - `std:fs`（pkg/fs）：`O_RDONLY/O_WRONLY/O_RDWR/O_CREAT/O_TRUNC/O_APPEND` + `open(path string, flags i32, mode u32) i32` / `read(fd i32, buf *u64, count u64) i32` / `write(fd i32, buf *u64, count u64) i32` / `close(fd i32) i32`，复用 std:syscall + std:strings.to_cstring。
  - `std:console`（pkg/console）：`STDIN/STDOUT/STDERR` + `print(s string) i32` / `println(s string) i32`（返回写出字节数）。
- `println` 修复：改为 `var n: i32 = print(s); ret n + syscall.write(...)` 累加（此前只返回换行的 1 字节）。
- 测试迁移与全库驼峰化：`test/strings_test`→`stringsTest`（imports io→fs）、`test/io_test`→`fsTest`、`test/hello_world`→`helloWorld`（console.println）、`test/echo`（fs.read + console.STDIN，双架构 0）；新增 `test/consoleTest`（println("hihi") 断言返回 3，双架构 0）。
- 其余驼峰化：测试目录 27 个、根文件 `simple_test→simpleBasicTest.cute`、`simple_var→simpleVarFn.cute`、`build_test→buildTest.cute`、`struct_test_complex→structTestComplex.cute`；scopeTest 变量 `global_var→globalVar`、`local_var→localVar`；`test_run.sh` 默认路径 `test/derefTest`。

### 14.2 x86_64 SysV 参数装载系列修复

新包大量使用寄存器参数（i32/u64/string 混传）后暴露的参数传递缺陷，按根因逐一修复：

1. **被调函数参数槽按实际宽度紧凑排列**（linux_sysv.go prologue）：SysV 参数槽非 8 字节对齐，`write3(fd i32, buf ptr, count u64)` 槽在 [rbp+16]/[rbp+20]/[rbp+28]。原实现一律按 QWORD 保存/读回，i32 槽写 8 字节覆盖相邻参数。修：prologue 按类型宽度保存（新增 `sysvWidthName`：RDI→EDI/DIL/DI、R8→R8D/R8B/R8W），build asm `$var` 展开按 `tmpVar.Type.Size()` 用 BYTE/WORD/DWORD/QWORD 前缀（compile/build.go）。
2. **用户 build asm 目标寄存器宽度适配**：宽度展开后 `mov RCX, BYTE[mem]`、`mov RCX, DWORD[mem]` 非法（"invalid operand sizes"）。修：`pkg/memory/memory_x86_64.cute` store8 `mov CL,$val`/store32 `mov ECX,$val`；`pkg/syscall/syscall_x86_64.cute` 全部 u32 参数改用 32 位寄存器（EAX/EDI/ESI/EDX/R10D/R8D/R9D，flags→ESI、mode→EDX）。
3. **x86_64 push 仅支持 64 位操作数**：`push DWORD[rel STDOUT]` 非法（"instruction not valid with 32-bit operand size"）。修：compile/exp/exp.go leaf push 分支对窄内存值先 `mov EAX` 零扩展再 `push RAX`。
4. **寄存器参数"先算后装"暂存机制**（核心）：装载含调用的参数时（如 `write(fd, to_cstring(s), len(s))`），内部调用/容器三槽装载会覆盖已装入的参数寄存器；且被调函数参数槽 [rbp+16] == 调用者 call 前 rsp（gdb 实证 toCstring 覆盖栈顶暂存的 fd）。修：每个参数 push 后统一下沉 80B 安全区（内部调用参数区最大 64B，标量总下沉 88B、容器 104B），全部算完后逆序 mov 到参数寄存器，最后 `add rsp` 恢复总量。
5. **x86 cdecl 不受影响**：上述修复全部限定 x86_64（linux_sysv.go / arch 文件），x86 路径未改动。

### 14.3 验证

- `fsTest`/`consoleTest`/`stringsTest`/`helloWorld`/`echo` 双架构 exit=0（此前 x86_64 均失败：print 传参错位 247=EBADF、println 只写 1 字节、fs/strings 链式传参错位）。
- A/B 全量回归（还原旧暂存逻辑的编译器 vs 当前，21 个失败测试对比）：compile FAIL / link FAIL 清单完全一致，运行时失败测试在旧编译器下同样失败（仅退出码数值不同），x86 两侧结果完全一致。结论：**本次会话无新增回归**。
- 基线失败不变（见第十节）：arithmeticTest/asmTest/asTest/comprehensive/frontendTest/runtime/simpleMethod/structMethod（compile FAIL）、fullSyntaxTest/complexExpressions/memoryTest x86_64（link FAIL）、string=100/string_operations=50/list=33/derefTest=7/memSuite=7/bitwise=9/calleeSave=15/complexTest=17/edgeValues=75 及 controlFlow=74/fib30=40/functionCalls=251/operatorPrecedence=68/recursion=53/scopeTest=119/simple=116/simpleTest=1/simpleVar=42/struct=207（运行时失败，双架构一致）。
- docs/STDLIB.md 更新：包总览（io 删除、fs/console 现行）、std:fs/std:console 章节、使用示例。

### 14.4 syscall 包纯 Cuteify 化与 x86 cdecl 窄化修复

- `pkg/syscall` 重构（用户架构指令：能用 Cuteify 就不留 asm）：
  - 仅 3 个原始函数保留 `build asm`（`syscall`/`syscall6`/`syscall64`，必须内联 syscall 指令）。
  - 6 个便捷封装（`exit`/`brk`/`write`/`read`/`open`/`close`）改为纯 Cuteify 转发，消除全部内联汇编。
  - x86_64 原始函数参数 u32→u64（8 字节 ptr/u64 经 u32 形参会截断），asm 改用 64 位寄存器（RAX 装载 trap，RDI/RSI/RDX/R10/R8/R9 装载参数）；x86 原始函数保持 u32（32 位地址足够）。
- 编译器修复：**x86 cdecl 实参窄化**（compile/arch/x86/cdecl.go）。u64 实参→u32 形参此前按实参宽度压 8 字节，导致后续参数槽全部错位（fs.open 链 x86 返回 ENOENT，gdb 实证 syscall4 收到 EBX=0）。修：形参 4 字节而实参为 64 位值时，取低 32 位装载 EAX 后压 4 字节。
- 验证：`fsTest`/`stringsTest` x86 从 exit=2/8 修复为 0（此前为纯 Cuteify 化引入的临时回归）；5 个新测试双架构全 0；全量回归结果与 A/B 基线完全一致（asmTest 记录中本就是 link FAIL，非回归）。

### 14.5 strings 包签名统一为 uint

- `std:strings` 的 `len`/`cap`/`to_cstring` 返回值及 `eq`/`ne` 内部中间量由架构分化的 u32/u64 统一为 `uint`（平台原生字宽：x86_64 8 字节、x86 4 字节），两个架构文件签名一致。
- `uint` 与 u32/u64 同属 uint 数值系，调用方无需改动：`to_cstring` 结果作 u64 形参实参由 x86 扩展/窄化逻辑自动处理，`len` 作 count u64 实参同理。
- 验证：`consoleTest`/`fsTest`/`stringsTest`/`helloWorld`/`echo` 双架构 exit=0。

## 十五、else 块跨包调用修复 + toString 负数修复（本次会话）

### 15.1 两个编译器 bug：else 块子树不在 Children 遍历中

**现象**：单文件复现 `fn toStr(n int) string { ... if neg { ... } else { ... } }` 与跨包 `strings.toString(12345, 10)` 组合时，toString 循环内对 `memory.store8` 的调用被静默丢弃（生成汇编 3 个 store82 → 期望 4 个，缺循环内那 1 个）。

**根因**：else 容器节点（`IfBlock.ElseBlock`）只挂在 `IfBlock` 字段上，**不在任何节点的 Children 里**，导致两处仅遍历 Children 的递归都漏掉 else 子树：

1. `fixPkgNamePaths`（package/package.go，非根包文件循环内）：负责给跨包调用名加包路径前缀（`memory.store8` → `std_memory_store8`）。else 块内的调用名永不修复 → `p.Find` 搜不到 → `call.Func == nil`。
2. `fixParser`（package.go，isRoot 合并块内）：负责把合并树所有节点 Parser 统一为根包 Parser。else 子树节点仍持有库文件自己的 Parser（`ThisBlock` 指向库的根块，children 不含 memory 函数）→ `p.Find` 同样失败。

**后果链**：`call.Func == nil` → `SysV.Call` 在 linux_sysv.go:141 静默返回 `""`（空字符串拼进代码生成流），该条语句凭空消失——不报错、不 panic，是最难查的一类缺失代码。

**修复**（package/package.go）：`fixPkgNamePaths` 的 `*parser.IfBlock` 分支加 `if v.ElseBlock != nil { fixPkgNamePaths(v.ElseBlock, pkg) }`；`fixParser` 同步递归 `ib.ElseBlock`。

**验证**：单文件复现工程 toString 段 store82 由 3 → 4（循环内 store8 出现在 for_3_end 之前）；test/strconv 由 5/11 → 10/11。

### 15.2 std:strings toString 负数数字位被负号覆盖

**现象**：`toString(-42, 10)` 返回 `"-2"`（len=3 但内容截断），`sChar(b, 1)`/`sChar(b, 2)` 均非期望字符；parse 方向 `parse("-42", 10)` 正确。strconv 11 项断言恰 1 项失败（b 项）。

**根因**：toString 数字写入位置用 `buf + (digits - 1 - i)`（数字占 buf[0..digits-1]），负数时随后 `store8(buf, 45)` 把 `-` 写到 buf[0]，**覆盖了最高位数字**。正数 digits==total 不受影响，故仅负数失败。

**修复**：pkg/strings 两架构 + test/fortest/lib 复现副本统一改为 `buf + (total - 1 - i)`（正数 total==digits 行为不变；负数数字右移一位到 buf[1..digits]，`-` 占 buf[0]）。

### 15.3 验证

- test/strconv（11 项：toString 6 项 + parse 5 项）**双架构 exit=11**。
- 全量回归双架构全绿：x86_64 PASS=32 FAIL=0（skip 4：arithmeticTest/simpleMethod/structMethod compile FAIL、asmTest/fullSyntaxTest link FAIL、complexExpressions/memoryTest x86_64 link FAIL）；x86 PASS=34 FAIL=0（skip 2：compile FAIL 同上、link FAIL 仅 asmTest/fullSyntaxTest；complexExpressions/memoryTest x86 通过）。
- 单文件复现工程 drv_single exit=5 且 4 个 store82 保持（编译器修复未回归）。

---

## 十六、M5 补强：*T 函数参数/返回类型 + 嵌套 struct 字段（本次会话）

### 16.1 现象

以下四种写法此前均报类型/语法错误：

| 写法 | 错误 |
|---|---|
| `fn mkNode(v: int) *Pair`（`*T` 返回类型） | `Syntax Error: name contains invalid characters` |
| `fn bump(p: *Pair)`（`*T` 参数） | 同上（`: ` 分支 ParseName 遇 `*`） |
| `type Nest struct { p: Pair }`（嵌套 struct 字段） | `Type Error: type expected` |
| `fn sumBig(b Big)`（NAME 分支参数，无冒号） | `Syntax Error: need type` |

### 16.2 根因

1. **`parseTypeAnnotation` 断言错误**：`parser/var.go` 中对 Find 结果的断言为 `results[0].Value.(*TypeBlock)`，但 `parser/finder.go:233` 对 TypeBlock 统一返回 `Value: v.Type()`（求值后的 `*typeSys.StructType`），**断言永不成功**。凡走 parseTypeAnnotation 解析自定义类型的路径（func.go NAME 参数分支、struct.go 字段类型、跨包子类型）全部静默返回 nil；而 var 声明走 `parseTypeRef`（断言 `typeSys.Type`）、冒号参数走 `:` 分支（同断言），故此前未暴露。
2. **`ParseRetType` 用 ParseName**：`*` 不是合法名字字符 → `name contains invalid characters`（func.go 原实现，另有 TODO 注释的指针参数处理为死代码）。
3. **参数 `:` 分支用 ParseName 解析类型名**：`p: *Pair` 的 `*` 前缀同样报错。

### 16.3 修复

1. `parser/var.go` `parseTypeAnnotation` 两处断言（跨包 fullName 分支 + 主 NAME 分支）兼容 `typeSys.Type`（与 finder 返回值对齐，`*TypeBlock` 分支保留）。
2. `parser/func.go` `ParseRetType`：`*`/`[` token 回退游标走 `p.parseTypeAnnotation()`。
3. `parser/func.go` 参数 `:` 分支：下一 token 为 `*`/`[` 时走 `parseTypeAnnotation`，否则维持原 ParseName+Find 逻辑。

### 16.4 验证

- 新增 `test/m5`（7 项：5 槽 Big struct 赋值/传参/返回、`*T` 返回值工厂、`*T` 参数修改、嵌套 struct 赋值访问、`*Node` 指针链链表）→ **exit=7**。
- 回归：structValue=11、heap_struct=84、struct=207、structTest=0、list=33、strconv=11、memSuite=7、simpleVar=42 全部与基线一致；structMethod/simpleMethod 编译失败为基线既知 skip（见 15.3），经 `git stash` 隔离证实与本次改动无关。

### 16.5 遗留

- 未 import 的跨包调用（如 m45 缺 `memory` import）被静默丢弃：`SysV.Call` 对 `call.Func == nil` 返回 `""`（linux_sysv.go:141），不报错。建议后续在调用处对未解析的跨包调用报错。
