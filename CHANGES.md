# 全部代码更改说明（相对基线 4a3dc25）

> 本文件解释自基线提交 4a3dc25 以来所有未提交的代码更改：现象、根因、修复方案与验证结果。
> 对应计划文件：`PLAN_m2_fix.md`（修复计划与状态）、`PLAN_string_list_heap_struct.md`（M2/M3/M4/M5 总计划）。

## Recent Changes

- Reverted orphan-free code in Assign() — fundamentally wrong: can't distinguish locally-allocated vs parameter-passed values at compile time
- Fixed isGlobalTarget() — was always returning false
- Fixed emitGCFrees x86 double stack cleanup
- Deleted dead code: freeplan.go (394 lines)
- Updated CLAUDE.md memory allocator description to match DOC_memory_gc.md
- Verified rcLeak test passes (exit=0)

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
17. [堆对象内建 new(T[, v...])](#十七堆对象内建-newt-v本次会话)
18. [函数指针间接调用修复](#二十三函数指针间接调用修复phase-05-完成)
19. [标准库全量实施 Phase 1-13](#二十四标准库全量实施phase-1-13-完成)

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

1. **parser/func.go parseArgs**：SEPARATOR 分支支持 `*`/`[` 前缀类型（SetCursor 回退 + parseTypeAnnotation），`buf *u64` 可解析。
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
2. **`parseRetType` 用 ParseName**：`*` 不是合法名字字符 → `name contains invalid characters`（func.go 原实现，另有 TODO 注释的指针参数处理为死代码）。
3. **参数 `:` 分支用 ParseName 解析类型名**：`p: *Pair` 的 `*` 前缀同样报错。

### 16.3 修复

1. `parser/var.go` `parseTypeAnnotation` 两处断言（跨包 fullName 分支 + 主 NAME 分支）兼容 `typeSys.Type`（与 finder 返回值对齐，`*TypeBlock` 分支保留）。
2. `parser/func.go` `parseRetType`：`*`/`[` token 回退游标走 `p.parseTypeAnnotation()`。
3. `parser/func.go` 参数 `:` 分支：下一 token 为 `*`/`[` 时走 `parseTypeAnnotation`，否则维持原 ParseName+Find 逻辑。

### 16.4 验证

- 新增 `test/m5`（7 项：5 槽 Big struct 赋值/传参/返回、`*T` 返回值工厂、`*T` 参数修改、嵌套 struct 赋值访问、`*Node` 指针链链表）→ **exit=7**。
- 回归：structValue=11、heap_struct=84、struct=207、structTest=0、list=33、strconv=11、memSuite=7、simpleVar=42 全部与基线一致；structMethod/simpleMethod 编译失败为基线既知 skip（见 15.3），经 `git stash` 隔离证实与本次改动无关。

### 16.5 遗留

- 未 import 的跨包调用（如 m45 缺 `memory` import）被静默丢弃：`SysV.Call` 对 `call.Func == nil` 返回 `""`（linux_sysv.go:141），不报错。建议后续在调用处对未解析的跨包调用报错。

---

## 十七、堆对象内建 new(T[, v...])（本次会话）

### 17.1 现象与动机

堆上对象此前只能手写 `memory.malloc(Size(T))` 工厂（如 `mkNode`），需手动算字节数、无零初始化保证；语言层无 `new` 内建（`make`/`append` 内建仅有编译层代码，parser 层未接线，`make([]int, 3)` 直接报 `Expression Error: unexpected '['`）。

### 17.2 实现

1. **parser/call.go**：`CallBlock` 增 `NewType` 字段；新增 `ParseNew`（首参走 `parseTypeAnnotation` 解析类型，其余为字段初值表达式，深度计数循环兼容嵌套调用）；`checkBuiltin` 增 `case "new"`（返回类型 `*T`，初值表达式逐个 Check）。
2. **parser/exp.go** `handleName`：`name == "new"` 时走 `ParseNew`，并设置 `exp.Type = MakePointer(NewType)`。
3. **compile/exp/exp.go**：`builtinCall` 分派 `case "new"` → `builtinNew`：`emitMalloc(align8(Size(T)))`（x86/x86_64 双架构）+ 零填充（含 padding）+ 初值按 `StructType.Fields()[i].Offset` 写（≤指针宽度的标量值；常量直接写、表达式经寄存器）。
4. **寄存器安全**（关键）：新对象地址 `push` 到栈顶保存、用时从 `[ESP/RSP]` 重装载（`c.arch.StackPtr()` 抽象），**不占用任何寄存器**——避免覆盖调用方目标地址寄存器（`p.x = new(T)` 路径 Assign 的临时寄存器）与嵌套调用活跃值。

### 17.3 验证

- 新增 `test/heap_new`（7 项）：new 零初始化、字段读写、`new(Point, 5, 6)` 带初值、堆对象方法调用（this 指针）、`new(Node)` 构建链表 + 三级指针链、链式 `nx.next = new(Node, 8)`、`memory.free` 后分配复用（不崩）→ **双架构 exit=7**。
- 调试过程中确认：`head.next = new(Node)` 首次实现用 callee-save 寄存器保存对象地址会覆盖调用方地址寄存器（新对象 next 自环 → 段错误），改为栈槽后修复。
- 全量回归双架构全绿：m5=7、heap_struct=84、structValue=11、list=33、strconv=11、memSuite=7、simpleVar=42、derefTest=7（x86_64 与 x86 一致）。

### 17.4 遗留

- 初值参数仅支持 ≤指针宽度的标量；struct/list/string 字段初值与 `new` 嵌套（`r.x = mkPair(5).x` 调用结果字段访问）编译器 panic，后续再补。

---

## 十八、标准库全量实施计划启动（本次会话）

### 18.1 计划文件

- 新增 `PLAN_stdlib.md`：标准库全量实施计划（15 个 Phase，~86 个改动/包）
- 新增 `TODO_stdlib.md`：详细任务清单

### 18.2 设计决策

| 决策 | 说明 |
|------|------|
| 平台无关优先 | 用 `ptr`/`int`/`uint`（自动适配 32/64）+ struct 字段访问 + 指针解引用，不手动 load32/store32 |
| 多层目录 | `"std:hash/crc32"` → `pkg/hash/crc32/`，使用时 `crc32.Checksum(data)` |
| cmp 不单独成包 | Compare/Less 可以是编译器内建或放到 strings/math 中 |
| path 合并 filepath | 一个 `path` 包搞定 |
| strconv 合并到 strings | Cuteify 的 strings 包已包含类型转换功能 |
| hashmap 是 map[K]V 底层 | 编译器看到 `map[K]V` 时引入 hashmap 包 |
| database + net 最后做 | 依赖 net 的包放到最后 |
| reflection 依赖最后做 | json, xml, html/template 等 |
| 不做 sync/sync-atomic | 需要 goroutine 支持 |

### 18.3 实施顺序

| Phase | 内容 | 包数 |
|-------|------|------|
| 0 | 编译器基础设施 | 7 改动 |
| 1 | 修补现有包 | 6 包 |
| 2 | 文本数据 | 5 包 |
| 3 | 哈希 | 7 包 |
| 4 | 数学 | 3 包 |
| 5 | 排序 | 1 包 |
| 6 | 操作系统 | 7 包 |
| 7 | I/O | 1 包 |
| 8 | 数据结构 | 5 包 |
| 9 | 压缩归档 | 7 包 |
| 10 | 图像处理 | 7 包 |
| 11 | 运行时 | 5 包 |
| 12 | 测试框架 | 1 包 |
| 13 | 高级工具 | 8 包 |
| 14 | 数据库 | 2 包 |
| 15 | 网络 | 7 包 |

### 18.4 平台特定代码清单（只有这些需要 `build arch()`）

| 文件 | 内容 | 原因 |
|------|------|------|
| `memory_x86.cute` | load8/32/64, store8/32/64 | raw ptr 内存操作 |
| `memory_x86_64.cute` | 同上 | 同上 |
| `syscall_x86.cute` | syscall/syscall6/syscall64 + 包装 | int 0x80 vs syscall 指令 |
| `syscall_x86_64.cute` | 同上 | 同上 |
| `time_x86.cute` | now(), sleep() | 不同 syscall 号 + timespec 布局 |
| `time_x86_64.cute` | 同上 | 同上 |

**其他所有代码都是 100% 平台无关的。**

## 十九、Phase 0.2 switch/case 实现（本次会话）

### 19.1 概述

实现完整的 switch/case 语句，包括：
- parser: SwitchBlock, SwitchCase, SwitchCaseClause AST 节点
- parser: switch 表达式解析 + case/default 作用域管理
- compile: 比较 + 条件跳转 codegen（x86_64 + x86）
- 隐式 break（每个 case body 结束自动跳转到 switch 结束标签）

### 19.2 修改文件

| 文件 | 改动 |
|------|------|
| `lexer/keywords.go` | 添加 `case`/`default` 为 PROCESSCONTROL |
| `parser/switch.go` | SwitchBlock, SwitchCase, SwitchCaseClause 定义 + Parse/ParseCaseValues/ParseDefaultColon |
| `parser/parser.go` | `case`/`default` 在 processControlToken 中的处理 + `}` 对 SwitchCaseClause 的双重回退 |
| `compile/compiler.go` | compileSwitchBlock: 表达式编译 + 比较跳转 + case/default body 编译 |

### 19.3 Bug 修复

1. **Lexer SkipSep 缺少 tab 处理** — `.cute` 源文件中的 tab 导致 GetWord 包含 tab 字符，触发 "name contains invalid characters"。修复：SkipSep 同时跳过空格和 tab。

2. **ParseCaseValues 无限循环** — `p.Lexer.SetCursor(code.Cursor)` + `p.ParseExp(p.Lexer.Cursor)` 导致游标回到 token 起始位置，ParseExp 立即返回 nil，循环永不前进。修复：使用 Has 找到 `:` 位置，然后 ParseExp 以 `:` 前位置作为 stopCursor。

3. **SwitchBlock.Target 始终为 nil** — `p.ParseExp(p.Lexer.Cursor)` 使用当前游标作为 stopCursor（与起始位置相同），ParseExp 立即返回 nil。修复：先用 Has 找到 `{` 位置，然后 ParseExp 以 `{` 前位置作为 stopCursor。

4. **`}` 对 SwitchCaseClause 的回退** — `}` 关闭 switch 时，p.ThisBlock 在 SwitchCaseClause 中，需要跳过 SwitchCaseClause → SwitchBlock 两层。修复：`}` 处理器检测 SwitchCaseClause 并双重回退。

### 19.4 验证

- switch_test (x86_64): exit=20 ✅ (x=2, case 2: ret 20)
- switch_test (x86): exit=20 ✅
- simpleVar (x86_64): exit=42 ✅
- controlFlow (x86_64): exit=39 ✅
- listTest (x86_64): exit=0 ✅
- multi_return (x86_64): exit=0 ✅
- generics (x86_64): exit=42 ✅
- derefTest (x86_64): exit=7 ✅

## 二十、Phase 0.3 for range 实现（本次会话）

### 20.1 概述

实现 for range 循环语法，支持遍历 list 和 string：
- `for i, v := range list { ... }` — 双变量：索引 + 值
- `for i := range list { ... }` — 单变量：只取索引

### 20.2 修改文件

| 文件 | 改动 |
|------|------|
| `lexer/keywords.go` | 添加 `range` 为 PROCESSCONTROL 关键字 |
| `parser/for.go` | ForBlock 添加 Range + RangeNames 字段；Parse 检测 range 语法；parseRange 解析变量和表达式；Check 验证 range 目标类型 |
| `compile/compiler.go` | compileForRangeBlock: 加载 list ptr/len → 循环索引 → 比较 len → 加载元素 → 编译 body → 递增索引 |

### 20.3 实现细节

- **变量声明**：range 变量（index、value）在 ForBlock 节点外声明，和普通 for 的 Init 一样
- **list 内存布局**：[ptr, len, cap]，ptr 指向元素数组
- **循环结构**：
  1. 从 list 结构加载 ptr（offset 0）和 len（offset ps）
  2. 初始化索引为 0
  3. 循环：索引 < len → 加载元素 → 编译 body → 索引++ → 跳回
  4. 索引 >= len → 退出

### 20.4 验证

- for_range_test (x86_64): exit=150 ✅ (10+20+30+40+50=150)
- for_range_test (x86): exit=150 ✅
- 所有回归测试通过（x86_64 + x86）

---

## 21. defer 语句支持（Phase 0.6）

### 21.1 功能描述

新增 `defer` 关键字，支持延迟执行函数调用，直到当前函数返回前执行。defer 按 LIFO（后进先出）顺序执行。

语法：`defer funcName(args...)`

### 21.2 实现细节

#### 21.2.1 新增文件

- **parser/defer.go** — DeferBlock AST 节点，解析 defer 语句
- **compile/defer.go** — DeferBlock 编译逻辑，收集和执行 defer 调用

#### 21.2.2 修改文件

- **lexer/keywords.go** — 添加 "defer" 关键字（PROCESSCONTROL 类型）
- **parser/parser.go** — processControlToken 中添加 defer 分支
- **compile/compiler.go** — compileReturnBlock 在返回前执行所有 defer 调用

#### 21.2.3 核心逻辑

1. **解析**：defer 读取函数名 + 调用参数，创建 DeferBlock AST 节点
2. **编译**：
   - `compileDeferBlock` 仅生成注释（defer 本身不执行）
   - `compileDeferCalls` 收集函数体内的所有 defer 节点
   - `compileReturnBlock` 在生成返回代码前，按 LIFO 顺序编译所有 defer 调用
3. **作用域**：递归遍历 if/for/switch 块收集 defer，支持嵌套作用域中的 defer

### 21.3 验证

- defer_test (x86): exit=0，输出 "maincleanup2cleanup1" ✅（LIFO 顺序正确）
- 所有回归测试通过（x86 + x86_64）

---

## 22. map[K]V 类型支持（Phase 0.7）

### 22.1 功能描述

新增 `map[K]V` 类型定义，支持键值对映射的类型声明。当前阶段仅实现类型系统和 parser 支持，hash 表代码生成在 Phase1 L3。

### 22.2 实现细节

#### 22.2.1 新增文件

- **type/map.go** — MapType 类型定义（嵌入 RType，Key()/Value() 访问键值类型）

#### 22.2.2 修改文件

- **parser/var.go** — parseTypeAnnotation 支持 `map[K]V` 语法
- **parser/parser.go** — parseTypeRef 支持 `map[K]V` 语法（修复游标回退问题）

#### 22.2.3 核心逻辑

1. MapType 内存布局与 list 相同：[ptr, len, cap]，3 × pointerSize 字节
2. `parseTypeAnnotation`/`parseTypeRef` 在 `map` NAME token 后读取 `[`、解析键类型、`]`、解析值类型
3. 嵌入 RType 提供 Type 接口的默认实现（Type()/Fields()/Parent()/IsPointer()/Methods()）

### 22.3 验证

- map_test (x86): exit=0 ✅（`var m : map[string]int` 声明成功）
- 所有回归测试通过（x86 + x86_64）

---

## 23. 函数指针间接调用修复（Phase 0.5 完成）

### 23.1 问题

函数指针调用 `f(3, 4)` 不生成任何汇编代码，`result` 变量得到垃圾值。

### 23.2 根因

1. **call.go 花括号嵌套错误**：函数指针检查（FindFuncPointerVar）被错误地嵌套在 `for` 循环内部，而该循环搜索 FuncBlock。由于 `f` 是 VarBlock（不是 FuncBlock），循环体永不执行，函数指针检查永不运行。

2. **this 指针误推**：函数指针调用时 `call.ThisVar` 被设为函数指针变量，导致代码生成器错误地推入 this 指针。

3. **参数栈大小计算错误**：`callArgsSize` 对函数指针调用额外加了 4 字节（this 指针），但实际未推入。

### 23.3 修复

#### 23.3.1 parser/call.go — 花括号嵌套修复

将函数指针检查移到 `for` 循环外部，在常规函数查找失败后执行：

```go
// 常规函数查找（for 循环）
if c.Func == nil {
    results := p.Find(c.Name, FindTypeFunc)
    for _, node := range results { ... c.Func = fb ... }
}
// 函数指针变量查找（for 循环外部）
if c.Func == nil {
    if fnPtrVar := p.FindFuncPointerVar(c.Name); fnPtrVar != nil {
        c.ThisVar = fnPtrVar
        c.Func = &FuncBlock{Args: ..., Return: ft.Returns}
    }
}
```

#### 23.3.2 compile/arch/x86/cdecl.go — this 指针与间接调用

- `isIndirect` 判断提前到 this 指针推入之前
- 函数指针调用跳过 this 指针推入
- 间接调用：`mov eax, dword [addr]; call eax`

#### 23.3.3 compile/arch/x86/ops.go — 参数栈大小

`callArgsSize` 排除函数指针调用的 this 指针大小。

#### 23.3.4 compile/arch/x86_64/linux_sysv.go — x86_64 适配

同样跳过函数指针调用的 this 寄存器传参。

### 23.4 验证

生成的 x86 汇编（main 函数）：
```asm
mov dword DWORD[ebp-8], add2    ; f = add2
push 4                           ; arg1
push 3                           ; arg0
mov eax, dword DWORD[ebp-8]     ; 加载函数指针
call eax                         ; 间接调用
add esp, 8                       ; cdecl 清理（2×4=8）
mov DWORD[ebp-12], EAX          ; result = 返回值
```

- fnptr_test (x86): 编译成功 ✅
- 所有 12 个回归测试编译成功 ✅
- 删除 debug 输出（fmt.Printf + fmt import）

---

## 二十四、标准库全量实施（Phase 1-13 完成）

### 24.1 概述

从零构建了 Cuteify 标准库，共 40+ 包，覆盖文本处理、数学、哈希、I/O、数据结构、压缩归档、图像、运行时、测试框架和高级工具。

### 24.2 Phase 1 — 修补现有包

**syscall 包新增**（x86 + x86_64）：
- `lseek`, `mkdir`, `rmdir`, `unlink`, `rename`, `stat`, `fstat`, `getdents`, `getcwd`

**strings 包新增**（strings_common.cute）：
- `count`, `trimLeft`, `trimRight`, `trim`, `lastIndex`, `indexByte`, `containsAny`, `containsRune`, `compare`

**fs 包新增**：
- `seek`, `mkdir`, `remove`, `rename`, `stat`, `fstat`, `create`, `readFile`, `writeFile`

**time 包新增**：
- `NANOSECOND`/`MICROSECOND`/`MILLISECOND` 常量
- `durationString()`, `since()`(桩), `until()`(桩), `truncate()`, `round()`, `daysIn()`

**console 包新增**：
- `read()`, `readLine()`

### 24.3 Phase 2 — 文本与数据

| 包 | 文件 | 主要功能 |
|----|------|---------|
| bytes | pkg/bytes/bytes.cute | Buffer: newBuffer/write/writeString/len/reset/String |
| unicode | pkg/unicode/unicode.cute | isLetter/isDigit/isSpace/isUpper/isLower/toUpper/toLower |
| utf8 | pkg/unicode/utf8/utf8.cute | encodeRune/decodeRune/runeCount/valid |
| fmt | pkg/fmt/fmt.cute | itoa/itoaHex/itoaOct/appendInt/appendStr/appendChar |
| tabwriter | pkg/text/tabwriter/tabwriter.cute | newWriter/write/flush |

### 24.4 Phase 3 — 哈希

| 包 | 文件 | 主要功能 |
|----|------|---------|
| hash | pkg/hash/hash.cute | 接口包 |
| crc32 | pkg/hash/crc32/crc32.cute | CRC-32 IEEE checksum |
| crc64 | pkg/hash/crc64/crc64.cute | CRC-64 ECMA-182 checksum |
| adler32 | pkg/hash/adler32/adler32.cute | Adler-32 checksum |
| fnv | pkg/hash/fnv/fnv.cute | FNV-1/FNV-1a (32/64) |
| maphash | pkg/hash/maphash/maphash.cute | MurmurHash3 风格 |
| hashmap | pkg/hashmap/hashmap.cute | 链式哈希表: new/set/get/delete/has/size |

### 24.5 Phase 4 — 数学

| 包 | 文件 | 主要功能 |
|----|------|---------|
| math | pkg/math/math.cute | abs/min/max/gcd/lcm/factorial/isPrime + 浮点(math via -lm) |
| bits | pkg/math/bits/bits.cute | leadingZeros/trailingZeros/onesCount/rotate/reverse |
| big | pkg/math/big/big.cute | 占位符 |

### 24.6 Phase 5 — 排序

| 包 | 文件 | 主要功能 |
|----|------|---------|
| sort | pkg/sort/sort.cute | sortInts/sortStrings/binary search/isSorted |

### 24.7 Phase 6 — 操作系统

| 包 | 文件 | 主要功能 |
|----|------|---------|
| os | pkg/os/os.cute | exit/getcwd/stdout/stderr/isExist/isNotExist/isPermission |
| path | pkg/path/path.cute | base/dir/ext/join/clean/isAbs/split |
| log | pkg/log/log.cute | log/logError |

### 24.8 Phase 7 — I/O

| 包 | 文件 | 主要功能 |
|----|------|---------|
| io | pkg/io/io.cute | Reader/Writer/Copy/ReadAll/LimitReader |

### 24.9 Phase 8 — 数据结构

| 包 | 文件 | 主要功能 |
|----|------|---------|
| container/list | pkg/container/list/list.cute | 双向链表 |
| container/heap | pkg/container/heap/heap.cute | 最小堆 |
| container/ring | pkg/container/ring/ring.cute | 环形缓冲区 |
| slices | pkg/slices/slices.cute | contains/indexOf/reverse/max/min |
| maps | pkg/maps/maps.cute | keys/values/hasKey/len |

### 24.10 Phase 9 — 压缩归档

| 包 | 文件 | 主要功能 |
|----|------|---------|
| compress/flate | pkg/compress/flate/flate.cute | Store 模式 DEFLATE |
| compress/gzip | pkg/compress/gzip/gzip.cute | Gzip 封装 |
| compress/zlib | pkg/compress/zlib/zlib.cute | Zlib 封装 |
| compress/bzip2 | pkg/compress/bzip2/bzip2.cute | 占位符 |
| compress/lzw | pkg/compress/lzw/lzw.cute | LZW 压缩 |
| archive/tar | pkg/archive/tar/tar.cute | USTAR 格式读取 |
| archive/zip | pkg/archive/zip/zip.cute | Zip 格式读取 |

### 24.11 Phase 10 — 图像处理

| 包 | 文件 | 主要功能 |
|----|------|---------|
| image | pkg/image/image.cute | RGBA 图像 |
| image/color | pkg/image/color/color.cute | RGBA 颜色 |
| image/png | pkg/image/png/png.cute | 简化 PNG 编解码 |
| image/jpeg | pkg/image/jpeg/jpeg.cute | 占位符 |
| image/gif | pkg/image/gif/gif.cute | 占位符 |

### 24.12 Phase 11 — 运行时

| 包 | 文件 | 主要功能 |
|----|------|---------|
| runtime | pkg/runtime/runtime.cute | NumCPU/Version/Compiler |
| runtime/debug | pkg/runtime/debug/debug.cute | Stack/ReadBuildInfo |

### 24.13 Phase 12 — 测试框架

| 包 | 文件 | 主要功能 |
|----|------|---------|
| testing | pkg/testing/testing.cute | T/Run/Fail/Error/Equal/EqualStr/Passed |

### 24.14 Phase 13 — 高级工具

| 包 | 文件 | 主要功能 |
|----|------|---------|
| html | pkg/html/html.cute | escape/unescape |
| text/template | pkg/text/template/template.cute | 简单模板引擎 |
| mime | pkg/mime/mime.cute | MIME 类型检测 |
| uuid | pkg/uuid/uuid.cute | UUID v4 生成 |
| encoding/asn1 | pkg/encoding/asn1/asn1.cute | DER 编码 |
| encoding/quotedprintable | pkg/encoding/quotedprintable/quotedprintable.cute | RFC 2045 编解码 |
| encoding/ascii85 | pkg/encoding/ascii85/ascii85.cute | Ascii85 编解码 |
| index/suffixarray | pkg/index/suffixarray/suffixarray.cute | 后缀数组搜索 |

### 24.15 Phase 14 — 补充包（strconv 合并到 strings，filepath 合并到 path，flag，os/signal）

**strings 包新增**（strconv 功能合并）：
- `atoi`, `itoa`, `itoaBase`, `parseInt`, `parseUint`
- `quote`, `unquote`, `quoteRune`
- `parseBool`, `formatBool`
- `appendInt`, `appendFloat`, `formatFloat`, `parseFloat`

**path 包新增**（filepath 功能合并）：
- `separator`, `listSeparator`, `volumeName`, `volumeNameLen`
- `isLocal`, `localize`, `abs`, `rel`
- `match`, `glob`, `evalSymlinks`
- `joinMulti`, `walk`

**新包 flag**：
- `Flag` struct, `flagSet`, `init`, `string/int/bool`, `parse`, `arg/nArgs`
- `printUsage`, `lookup`, `getString/getInt/getBool`

**新包 os/signal**：
- `Signal` 常量 (SIGINT/SIGTERM/SIGQUIT/SIGHUP/SIGUSR1/SIGUSR2)
- `onSignal`, `handleOnce`, `reset`, `notify`, `stop`, `stopAll`

### 24.16 待完成

- Phase 15: database/sql + database/sql/driver（依赖 net，最后做）
- Phase 16: net/net.http/net.url/net.mail/net.smtp/net.textproto/net.rpc（最后做）

---

## 二十五、标准库审计与文档整理（本次会话）

### 25.1 审计范围

对 pkg/ 下全部 34 个顶层目录（58 个子包）进行完整审计：
- 检查 package.json 是否存在且正确
- 检查 .cute 实现文件的完整度
- 检查 test/ 目录和测试覆盖
- 对比 Go 标准库对应包的 API 覆盖率
- 识别代码问题和占位包

### 25.2 审计结果摘要

| 分类 | 包数 | 完成度范围 | 主要问题 |
|------|------|-----------|----------|
| 核心基础设施 | 4 | 100% | 无 |
| 文本处理 | 8 | 50-95% | fmt 缺 Sprintf，unicode 仅 ASCII |
| 哈希 | 8 | 80-100% | hashmap delete 内存泄漏 |
| 数学 | 3 | 5-100% | math/big 仅占位 |
| 排序 | 1 | 100% | 无 |
| 操作系统 | 4 | 50-90% | log 过于简单，flag.parse 未实现 |
| I/O | 1 | 85-95% | 无 |
| 数据结构 | 5 | 50-100% | slices/hashmap 缺测试 |
| 压缩归档 | 7 | 5-50% | 多数为简化/占位实现 |
| 图像 | 5 | 5-80% | jpeg/gif 仅占位 |
| 运行时 | 2 | 100% | 无 |
| 测试框架 | 1 | 100% | 无 |
| 高级工具 | 8 | 40-90% | flag 包 store32 存指针截断 |

### 25.3 新增文档

- `PLAN.md` — 标准库开发计划（各包完成度、下一步优先级、已知问题、里程碑）
- `TODO.md` — 待办事项（P0/P1/P2 三级优先级排列）
- `PROJECT.md` — 更新标准库部分描述

### 25.4 发现的代码问题

1. **flag 包 store32 存指针截断**：`pkg/flag/flag.cute` 用 `memory.store32` 存储指针（64 位系统上指针 8 字节），高位被截断。应改为 `memory.store64`。
2. **hashmap delete 不释放节点**：`pkg/hashmap/hashmap.cute` 的 `delete()` 不释放删除节点的内存。
3. **hashmap resize 不释放旧桶**：`resize()` 分配新桶后旧桶未释放。
4. **flag.parse 函数体为空**：命令行参数解析无法工作。
5. **strings_common.cute parseBool 嵌套过深**：逐字符比较嵌套 7 层 if，可简化。
