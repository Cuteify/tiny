# Cute 编译器后端文档

## 概述

Cute 编译器后端负责将前端生成的 AST（抽象语法树）转换为目标架构的汇编代码，再经 NASM 汇编、LD 链接生成可执行文件。当前支持 **x86 (cdecl/stdcall)** 和 **x86_64 (System V ABI / Win64)** 两种目标架构。

---

## 1. 目录结构

```
compile/
├── compiler.go          # 编译器主入口，AST 遍历 → 汇编生成
├── build.go             # build 块编译（内联汇编、link 声明）
├── defer.go             # defer 语句编译（LIFO 执行）
├── monomorphize.go      # 泛型单态化（类型替换 + 特化函数生成）
├── vtable.go            # 接口 vtable .data 段生成
├── utils.go             # 架构工厂 NewArch()
├── context/
│   └── context.go       # 编译器上下文（栈帧、寄存器、常量池等状态）
├── regmgr/
│   └── regmgr.go        # 寄存器分配器（表达式绑定、溢出、callee-save）
├── exp/
│   ├── exp.go           # 表达式编译器（两趟：信息收集 → 代码生成）
│   └── collect.go       # 表达式信息收集辅助
├── gc/
│   ├── summary.go       # GC 摘要数据结构（Mode/Escape/FnSummary）
│   ├── analyze.go       # 全程序 GC 摘要分析（不动点迭代）
│   └── llr.go           # LLR（Liveness-Based Local Release）分析
└── arch/
    ├── arch.go          # Arch 接口定义（架构抽象层）
    ├── utils.go         # 跨架构工具函数（ArgSlots、SetupVarOffsets 等）
    ├── x86/
    │   ├── x86.go       # x86 寄存器表 + 长度名映射
    │   ├── cdecl.go     # x86 cdecl 调用约定实现
    │   ├── stdcall.go   # x86 stdcall 调用约定实现
    │   ├── consts.go    # x86 寄存器类别位定义
    │   ├── exp.go       # x86 表达式编译
    │   └── utils.go     # x86 工具函数
    └── x86_64/
        ├── x86_64.go    # x86_64 寄存器表 + 长度名映射
        ├── linux_sysv.go # System V AMD64 ABI 调用约定
        ├── ms_win64.go  # Windows x64 调用约定
        ├── consts.go    # x86_64 寄存器类别位定义
        ├── exp.go       # x86_64 表达式编译
        ├── ops.go       # x86_64 算术/逻辑运算指令映射
        └── utils.go     # x86_64 工具函数（GenVarAddr、GenListFieldAddr 等）
```

---

## 2. 编译流程总览

```
源文件 (.cute)
  │
  ▼
Lexer (lexer/lexer.go)          ── 词法分析 → Token 流
  │
  ▼
Parser (parser/)                 ── 语法分析 → AST
  │  ├─ 包加载 (package/)
  │  ├─ Node.Check() 类型检查
  │  └─ 泛型函数标记 (Useful=false)
  │
  ▼
GC 摘要分析 (gc/analyze.go)      ── 不动点迭代 + LLR 分析
  │
  ▼
Compiler.Compile (compiler.go)   ── AST 遍历 → NASM 汇编
  │  ├─ 泛型单态化 (monomorphize.go)
  │  ├─ 内存管理注入 (gc/)
  │  ├─ vtable 生成 (vtable.go)
  │  └─ 架构代码生成 (arch/)
  │
  ▼
NASM 汇编                        ── .asm → .o
  │
  ▼
LD 链接                           ── .o → 可执行文件
```

### main.go 入口流程

```go
// 1. 加载包（递归解析所有依赖）
tmp, _ := packageSys.GetPackage(path, true)

// 2. GC 摘要分析（在 Check 完成后、代码生成之前）
gc.Build(tmp.AST.(*parser.Node))

// 3. 编译
co := &compile.Compiler{}
code := co.Compile(tmp.AST.(*parser.Node))

// 4. 写入 .asm → nasm → ld
```

---

## 3. Compiler 主结构

### 3.1 Compiler 结构体

```go
type Compiler struct {
    Ctx            *context.Context           // 编译器上下文
    RootGenerated  bool                       // 是否已生成 section .text
    stringSyms     map[string]bool            // build link 声明的全局符号
    currentFuncKey string                     // 当前编译函数全路径名（GC block frees 查询用）
    typeSubsts     map[string]map[string]Type // 单态化函数的类型替换表
    funcNodeMap    map[*FuncBlock]*Node       // FuncBlock → AST Node 映射
    compiling      bool                       // 防止递归调用重置泛型注册表
}
```

### 3.2 Compile() 主循环

```go
func (c *Compiler) Compile(node *Node) (code string)
```

**执行步骤：**

1. **初始化上下文** — 创建架构处理器、设置指针大小
2. **重置泛型注册表** — 顶层入口才重置
3. **收集 link 符号** — 遍历 AST 收集 `build link` 声明
4. **标记接口方法** — 确保接口赋值时需要的方法被编译
5. **标记 build link 提供者** — 确保提供者函数被编译
6. **遍历 AST 根节点的子节点** — 对每个节点调用 `c.CompileNode(child)`
7. **追加 vtable 段** — 所有接口 vtable 的 `.data` 段
8. **追加字符串常量** — 所有字符串字面量的 `.rodata` 段
9. **生成 section .text** — 将所有函数汇编拼接

### 3.3 CompileNode() — 节点分发

```go
func (c *Compiler) CompileNode(n *Node) (code string)
```

根据 `n.Value` 的类型分发到对应的编译方法：

| 节点类型 | 编译方法 | 说明 |
|----------|----------|------|
| `*FuncBlock` | `compileFuncBlock` | 函数定义（仅编译 `Useful=true` 的函数） |
| `*VarBlock` | `compileVarBlock` | 变量声明/赋值 |
| `*ReturnBlock` | `compileReturnBlock` | return 语句 |
| `*IfBlock` | `compileIfBlock` | if/else if/else 链 |
| `*ForBlock` | `compileForBlock` | for 循环 |
| `*SwitchBlock` | `compileSwitchBlock` | switch/case |
| `*BreakBlock` | `compileBreakBlock` | break |
| `*DeferBlock` | `compileDeferBlock` | defer（标记，实际在返回前执行） |
| `*Build` | `CompileBuild` | build 块（内联汇编、link 声明） |
| `*CallBlock` | `compileCallBlock` | 函数调用语句 |
| `*Expression` | 直接编译 | 表达式语句 |
| `*CaseBlock` | 无操作 | case 分支由 `compileSwitchBlock` 统一处理 |

---

## 4. 架构抽象层 (arch/)

### 4.1 Arch 接口

```go
type Arch interface {
    // 函数生命周期
    SetArgsOffset(fn *FuncBlock)   // 将参数偏移刷新为 callee-local 位置
    Prologue(fn *FuncBlock) string // 函数前序（push rbp; mov rbp,rsp; ...）
    Epilogue(fn *FuncBlock) string // 函数后序（leave; ret）
    
    // 函数调用
    Call(call *CallBlock) string   // 生成 call 指令
    Return(ret *ReturnBlock) string // 生成 return 指令
    ReturnReg() string             // 返回值寄存器名（EAX/RAX）
    
    // 表达式与语句
    Exp(exp *Expression, result, desc string) string  // 编译表达式到目标寄存器/地址
    ForBegin(forBlock *ForBlock) string
    ForEnd(forBlock *ForBlock) string
    VarDecl(varBlock *VarBlock) string
    VarAddr(v *VarBlock) string
    MultiVarDecl(varBlock *VarBlock) string  // 多返回值解构
    
    // 条件跳转
    Cmp(dst, src string) string
    Jump(typ, dst, src string) string
    Compare64(cond *Expression, jumpLabel string) string
    
    // 指令映射
    InstMov(dst, src string) string
    InstPush(val string) string
    InstPop(addr string) string
    InstUnary(op, reg string) string
    InstBinary(dst, op, src string) string
    
    // 寄存器信息
    DefaultRegMask() uint32
    NeedRegClass(bt BackendType) uint32
    NeedBindRegs(op string) []*Reg
    NeedBindMask(op string) uint32
    CalleeSaveReg() string
    CalleeSaveRegs() []string
    IsCalleeSave(name string) bool
    HiReg() string
    
    // 栈与地址
    FramePtr() string    // EBP/RBP
    StackPtr() string    // ESP/RSP
    PointerSize() int    // 4 或 8
    LengthName(size int) string  // BYTE/WORD/DWORD/QWORD
}
```

### 4.2 架构选择

通过环境变量 `CUTE_ARCH` 选择目标架构：

```bash
CUTE_ARCH=x86_64 ./cute ./test
```

支持的架构值：
- `x86` / `x86.cdecl` — 32 位 cdecl 调用约定（默认）
- `x86.stdcall` — 32 位 stdcall 调用约定
- `x86_64` / `x86_64.sysv` — 64 位 System V AMD64 ABI（Linux/macOS）
- `x86_64.win64` — 64 位 Windows x64 调用约定

### 4.3 x86_64 System V ABI 要点

**参数传递：**
- 第 1-6 个参数：`RDI, RSI, RDX, RCX, R8, R9`
- 第 7+ 个参数：压栈
- this 指针作为第 1 个参数（`RDI`）

**返回值：**
- 标量：`RAX`
- 大值（容器/大结构体）：调用者在栈上预留返回槽，通过 `R10` 传递槽地址

**callee-save 寄存器：** `RBX, R12, R13, R14, R15`

**栈对齐：** 16 字节对齐（调用 `call` 前 RSP 必须 16 字节对齐）

**栈帧布局：**
```
[rbp+16+n]  ← 栈参数（第 7+ 个参数）
[rbp+16]    ← 第 6 个参数（R9 槽位）
[rbp+8]     ← 返回地址
[rbp+0]     ← 保存的 RBP
[rbp-8]     ← callee-save R15
[rbp-16]    ← callee-save R14
...
[rbp-48]    ← 局部变量区开始
...
[rbp-48-StackSize] ← RSP（16 字节对齐）
```

### 4.4 x86 cdecl 要点

**参数传递：** 全部压栈（从右到左）

**返回值：** `EAX`（标量），大值通过隐式指针返回

**callee-save 寄存器：** `EBX`

**栈帧布局：**
```
[ebp+8+n]   ← 第 n 个参数
[ebp+8]     ← 第一个参数
[ebp+4]     ← 返回地址
[ebp+0]     ← 保存的 EBP
[ebp-4]     ← 局部变量区开始
...
```

---

## 5. 寄存器分配 (regmgr/)

### 5.1 数据结构

```go
type Reg struct {
    Name       string   // 寄存器名称（如 "RAX"）
    RegIndex   int      // 物理寄存器索引
    ClassMask  uint32   // 寄存器类别掩码（GPR、Div 等）
    CalleeSave bool     // 是否 callee-save
    User       MemAddr  // 溢出回写地址
    ExpID      int      // 绑定的表达式 ID（用于复用）
    Free       bool     // 是否空闲
    StoreCode  string   // 溢出存储代码
}

type RegMgr struct {
    Record   map[*Expression]*Reg  // 表达式 → 寄存器映射
    Regs     []*Reg                // 所有寄存器
    TotalReg int                   // 总寄存器数量
}
```

### 5.2 核心操作

| 方法 | 说明 |
|------|------|
| `Alloc(exp)` | 为表达式分配一个空闲寄存器 |
| `AllocBind(exp, mask)` | 按类别掩码分配寄存器（如除法需要 ClassDiv） |
| `AllocCalleeSaveBind(exp, regs, reg)` | 优先分配 callee-save 寄存器（用于跨调用保存） |
| `Force(reg, exp)` | 强制绑定表达式到指定寄存器 |
| `Free(exp)` | 释放表达式绑定的寄存器 |
| `FindByName(name)` | 按名称查找寄存器 |
| `SaveAll(calleeOnly)` | 生成 push 指令保存所有已使用寄存器 |
| `RestoreAll(calleeOnly)` | 生成 pop 指令恢复所有已使用寄存器 |
| `Spill(exp, addr)` | 溢出：将寄存器值写回栈地址 |

### 5.3 表达式寄存器分配流程

表达式编译采用**两趟流程**（`compile/exp/exp.go`）：

1. **信息收集趟**（`collect.go`）：遍历表达式树，计算每个子表达式需要的寄存器数量、绑定要求
2. **代码生成趟**：根据收集的信息，按后序遍历生成汇编代码

关键优化：
- **表达式复用**：相同表达式 ID 复用已分配的寄存器
- **callee-save 跨调用**：函数调用前将左操作数保存到 callee-save 寄存器，避免溢出到栈
- **EBX 直接使用**：某些场景跳过分配器直接使用 EBX（`UseEBXDirect`）

---

## 6. 表达式编译 (exp/)

### 6.1 ECompiler 结构

```go
type ECompiler struct {
    ctx        *context.Context
    arch       arch.Arch
    expInfo    map[*Expression]*ExpInfo  // 表达式信息
    expCounter int                        // 表达式 ID 计数器
    expIDMap   map[string]int             // 结构 key → ID
    idx        int                        // BindIndex 计数器
}
```

### 6.2 表达式类型

| 常量 | 值 | 说明 |
|------|----|------|
| `NumExp` | 1 | 数值表达式 |
| `BoolExp` | 2 | 布尔表达式 |
| `AndExp` | 3 | 逻辑与 |
| `OrExp` | 4 | 逻辑或 |
| `NotExp` | 5 | 逻辑非 |

### 6.3 表达式编译目标

`Exp(exp, result, desc)` 中 `result` 参数指定结果存放位置：

- `"RAX"` / `"EAX"` — 存入返回值寄存器
- `"push"` — 压栈（用于函数调用参数）
- `"QWORD [rsp+N]"` — 存入栈上指定偏移（用于参数 buffer）
- 变量地址字符串 — 直接存入内存

---

## 7. 函数编译

### 7.1 函数前序 (Prologue)

x86_64 SysV 示例：
```nasm
push rbp                    ; 保存调用者帧指针
mov rbp, rsp                ; 建立新帧
push rbx                    ; 保存 callee-save 寄存器
push r12
push r13
push r14
push r15
sub rsp, 48                 ; 分配局部变量空间（含对齐）
; 保存寄存器参数到栈上（callee-local 区域）
mov QWORD [rbp-48], RDI    ; 参数 0
mov QWORD [rbp-56], RSI    ; 参数 1
; ...
```

### 7.2 函数后序 (Epilogue)

```nasm
func_end_<name>:
    add rsp, 48            ; 清理局部变量
    pop r15                ; 恢复 callee-save（逆序）
    pop r14
    pop r13
    pop r12
    pop rbx
    leave                  ; 恢复栈帧（mov rsp,rbp; pop rbp）
    ret
```

### 7.3 参数偏移 (SetArgsOffset)

`SetArgsOffset` 将参数偏移从调用者帧位置刷新为 callee-local 位置：

- **x86 cdecl**：参数在 `[ebp+8]`, `[ebp+12]`, ...（调用者帧）
- **x86_64 SysV**：参数保存到 callee 局部变量区 `[rbp-48]`, `[rbp-56]`, ...

这确保函数体内的变量引用使用正确的栈偏移。

### 7.4 多返回值

函数返回多个值时，通过栈上传递返回槽：
- 返回值 1 在 `[rbp+RetSlot]`
- 返回值 2 在 `[rbp+RetSlot+PointerSize]`
- ...

### 7.5 大值返回

返回容器（list/string）或大结构体时：
- 调用者在栈上预留返回槽（24 字节容器 / N×8 字节结构体）
- 通过 `R10`（SysV）或隐式指针（x86）传递槽地址
- 被调函数直接写入返回槽

---

## 8. 泛型单态化 (monomorphize.go)

### 8.1 流程

```
函数调用 call.Func 有 TypeParams
  │
  ▼
MonomorphizeIfNeeded(call)
  │
  ├─ 检查缓存（是否已有相同类型替换的特化）
  │   └─ 命中 → 返回缓存标签名
  │
  ├─ 获取类型替换映射
  │   ├─ 显式 [Type] 语法 → 使用 NewType
  │   └─ 从实参推断 → inferTypeParams()
  │
  ├─ 创建特化副本 MonomorphizeFunction()
  │   ├─ 替换参数类型
  │   ├─ 替换返回类型
  │   ├─ 重新计算参数偏移
  │   └─ 生成新函数名（如 max__int）
  │
  ├─ 标记原函数 Useful=false（不编译）
  │
  └─ addSpecializedFunc()
      ├─ 复制原始函数体 AST
      ├─ SetArgsOffset（刷新参数偏移）
      ├─ remapFuncBodyRefs（重映射变量引用）
      ├─ substituteBodyTypes（替换 TypeParam 类型）
      ├─ clearExprChecked（清除检查缓存）
      ├─ node.Check()（重新类型检查）
      └─ 添加到 AST 根节点
```

### 8.2 类型推断

`inferTypeParams` 通过并行遍历函数参数定义类型和调用实参类型，找到 `TypeParam` 对应的具体类型：

```go
// defType = TypeParam{Name: "T"}, argType = IntType
// → subst["T"] = IntType
```

支持嵌套类型匹配（如 `*T` → `*int`）。

### 8.3 标签名生成

```
buildGenericLabel("max", {"T": int}) → "max__T__int"
```

---

## 9. 内存管理 (gc/)

### 9.1 概述

Cute 编译器使用**编译期内存管理**，而非运行时 GC。编译器在编译期分析每个函数的内存使用模式，自动插入 `memory.free()` 调用。

### 9.2 GC 摘要分析 (analyze.go)

**输入：** 包合并 + Check 重试完成后的根 AST

**输出：** 每个函数的摘要（`FnSummary`），写入全局 `Table`

**分析过程：**
1. 遍历 AST 收集所有函数定义
2. 初始化每函数摘要骨架（参数模式、返回值逃逸）
3. **不动点迭代**：参数逃逸沿调用边反向传播，直到收敛
4. LLR 分析：基于对象绑定的精确生命周期

### 9.3 逃逸分析 (summary.go)

**使用模式 (Mode)：**
| 模式 | 说明 |
|------|------|
| `ModeRead` | 仅读取数据，不修改不传播 |
| `ModeWrite` | 修改数据内容，不转移所有权 |
| `ModeDeepCopy` | 复制内容到新分配内存 |
| `ModeShallowCopy` | 仅复制指针值，产生别名 |
| `ModeOtherRef` | 指针逃逸：存储到他处/返回/传给其他函数 |

**逃逸层级 (Escape)：**
| 层级 | 说明 |
|------|------|
| `EscNone` | 不逃逸：仅当前函数作用域内使用 |
| `EscCaller` | 通过返回值逃逸到上层 |
| `EscHeapObj` | 存储到另一个堆对象的字段 |
| `EscGlobal` | 存储到全局变量 |
| `EscAny` | 未知（无摘要的外部调用） |

### 9.4 LLR 分析 (llr.go)

LLR（Liveness-Based Local Release）分析提供**精确的函数出口释放**：

- 跟踪每个抽象对象的绑定、逃逸状态、分配来源
- 在函数出口处释放**未逃逸的、非 RC 分配的**对象
- 支持字段级级联释放（结构体字段赋值时旧值需要释放）
- 支持块级释放（for/if 块退出时释放块内创建的对象）

**关键概念：**
- `ObjID`：抽象堆对象标识符（按分配点唯一）
- `bindings`：变量名 → 当前绑定的抽象对象
- `objEscaped`：对象是否已逃逸（一旦逃逸永不回收）
- `objRCAlloc`：对象是否由 `newRC()` 分配（带 RC 头，LLR 不自动释放）
- `orphans`：被替换掉的旧对象（需要在函数出口 free）
- `fieldOrphans`：字段级孤儿（字段赋值时旧值需要释放）

### 9.5 内存管理内建

编译器在编译期自动插入内存管理代码：
- `memory.malloc(size)` — 分配内存
- `memory.free(ptr)` — 释放内存
- `memory.loadN(ptr, offset)` — 从指针加载 N 字节
- `memory.storeN(ptr, offset, val)` — 向指针存储 N 字节
- `sizeof[T]()` — 获取类型大小（编译期内建）

---

## 10. defer 编译 (defer.go)

### 10.1 机制

defer 语句在**函数返回前**按 **LIFO（后进先出）** 顺序执行：

```cute
fn foo() {
    var p = memory.malloc(8)
    defer memory.free(p)
    // ... 使用 p ...
    return  // ← defer 在这里执行
}
```

### 10.2 实现

1. **标记阶段**（`compileDeferBlock`）：生成注释标记，实际不执行
2. **收集阶段**（`collectDeferNodes`）：递归遍历函数体，收集所有 defer 节点
3. **执行阶段**（`compileDeferCalls`）：在 `compileReturnBlock` 中，return 之前按 LIFO 顺序编译所有 defer 调用

支持递归收集嵌套的 if/for/switch 块中的 defer。

---

## 11. build 块编译 (build.go)

### 11.1 类型

| 类型 | 说明 |
|------|------|
| `"asm"` | 内联汇编（支持 `$var` 占位符替换） |
| `"link"` | 外部链接声明（`link name "C" as label`） |
| `"linkprovider"` | 链接提供者（提供被链接函数的实现） |

### 11.2 内联汇编变量替换

```cute
var x: i32 = 42
build asm """
    mov eax, $x          ; → mov eax, DWORD[ebp-4]
    push [$x]            ; → push [ebp-4]  (取地址)
"""
```

替换规则：
- `$x` → `DWORD[ebp+N]`（值访问）
- `[$x]` → `[ebp+N]`（地址访问）
- 负偏移（callee-local）：`[rbp-48]`
- 正偏移：`[rbp+8]`

---

## 12. 接口与 vtable (vtable.go)

### 12.1 vtable 布局

```
section .data
__vtable_Dog_Stringer:
    dq 0           ; type_info 占位
    dq _method_0   ; 方法 0 的函数指针
    dq _method_1   ; 方法 1 的函数指针
```

### 12.2 接口变量内存布局

```
接口变量 = {vtable_ptr, data_ptr}
[vbp+offset+0] = vtable_ptr  (指向 vtable 段)
[vbp+offset+8] = data_ptr    (指向实际数据)
```

### 12.3 接口分发

```nasm
mov R11, QWORD [rbp-48]           ; 加载 vtable_ptr
mov RDI, QWORD [rbp-40]           ; 加载 data_ptr (this)
call QWORD [R11+16]               ; 间接调用方法 0（偏移 8+0*8）
```

---

## 13. switch 编译

### 13.1 SwitchBlock 结构

```go
type SwitchBlock struct {
    Target *Expression  // switch 后面的表达式
    Cases  []*CaseBlock // case 分支列表
}

type CaseBlock struct {
    Values    []*Expression // case 后面的值列表（允许多值匹配）
    IsDefault bool          // 是否为 default 分支
    Switch    *SwitchBlock
}
```

### 13.2 编译策略

```nasm
; 编译 switch 目标到 RAX
mov rax, <target>

; 为每个 case 值生成比较跳转
mov rcx, <case_value>
cmp rax, rcx
je case_switch_1_0
; ... 重复所有 case 值

; 没有匹配 → 跳转到 default 或 end
jmp switch_end_switch_1

; case body
case_switch_1_0:
    <body>
    jmp switch_end_switch_1

; default body
case_switch_1_default:
    <body>

switch_end_switch_1:
```

---

## 14. for 循环编译

### 14.1 ForBlock 结构

```go
type ForBlock struct {
    Init      *Expression  // 初始化语句
    Condition *Expression  // 条件表达式
    Increment *Expression  // 递增表达式
    Range     *Expression  // range 表达式
    RangeNames []*VarBlock // range 变量名
}
```

### 14.2 普通 for 循环

```nasm
; Init
<init>
for_begin_1:
; Condition
<condition>
cmp eax, 0
je for_end_1
; Body
<body>
; Increment
<increment>
jmp for_begin_1
for_end_1:
```

### 14.3 range 循环（容器遍历）

```nasm
; 初始化索引
mov DWORD [rbp-XX], 0
for_begin_1:
; 检查索引 < len
mov eax, DWORD [rbp-XX]
cmp eax, DWORD [rbp-XX+8]  ; len
jge for_end_1
; Body（range 变量 = container[index]）
; Increment
add DWORD [rbp-XX], 1
jmp for_begin_1
for_end_1:
```

---

## 15. if/else 编译

### 15.1 编译策略

```nasm
; Condition
<condition>
cmp eax, 0
je else_1

; Then body
<then>
jmp if_end_1

else_1:
; Else body（或 else if 链）
<else>

if_end_1:
```

---

## 16. Context 编译上下文

### 16.1 Context 结构

```go
type Context struct {
    // AST 相关
    Now *Node              // 当前正在编译的 AST 节点
    
    // 当前函数上下文
    CurrentFunc *FuncBlock
    
    // 寄存器管理
    Reg  *RegMgr
    Arch arch.Arch
    
    // 栈帧相关
    SpOffset int           // ESP 偏移量
    BpOffset int           // EBP 偏移量
    StackSize int          // 当前函数的栈大小
    ArgsSize  int          // 当前函数的参数大小
    RetSlot int            // 返回值槽偏移（负数）
    StackAlignment int     // 栈对齐大小
    
    // 表达式编译状态
    UseEBXDirect bool
    EbxOccupied  bool
    ExpType      int
    
    // 编译器状态
    VarStackSize int
    ExpCount     int
    ArgOffset    int
    IfCount      int
    ForCount     int
    SwitchCount  int
    
    // 字符串常量池
    StringConsts map[string]string
    StrCount     int
    
    // 全局变量
    GlobalVars map[string]*VarBlock
    
    // 链接相关
    Externs     map[string]bool
    LinkProviders map[string]*FuncBlock
    
    // vtable
    VtableEntries []VtableEntry
    
    // 64 位模式标志
    Is64Bit bool
    PointerSize int
}
```

---

## 17. 完整编译示例

### 源代码

```cute
fn max(a i32, b i32) i32 {
    if a > b {
        return a
    }
    return b
}

fn main() i32 {
    return max(10, 20)
}
```

### 生成的 x86_64 SysV 汇编

```nasm
section .text
global _start

max:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 40          ; 对齐 + 局部变量
    mov QWORD [rbp-48], RDI   ; 参数 a
    mov QWORD [rbp-56], RSI   ; 参数 b
    
    ; if a > b
    mov eax, DWORD [rbp-48]   ; a
    cmp eax, DWORD [rbp-56]   ; b
    jle else_1
    
    ; return a
    mov eax, DWORD [rbp-48]
    jmp func_end_max
    
else_1:
    ; return b
    mov eax, DWORD [rbp-56]
    
func_end_max:
    add rsp, 40
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret

_start:
    ; main
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 40
    ; 调用 max(10, 20)
    mov RDI, 10
    mov RSI, 20
    call max
    ; return max(10, 20)
    mov eax, eax
    jmp func_end__start
    
func_end__start:
    add rsp, 40
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret
```

---

## 18. 关键设计决策

1. **编译期内存管理**：通过逃逸分析和 LLR 分析，在编译期自动插入 free 调用，避免运行时 GC 开销。

2. **泛型单态化**：在编译期展开泛型函数为具体类型版本，避免运行时类型擦除。

3. **接口 vtable**：编译期生成 vtable 表，运行时通过间接调用实现多态分发。

4. **架构抽象**：通过 `Arch` 接口隔离架构差异，同一 AST 可编译到不同目标。

5. **两趟表达式编译**：先收集信息再生成代码，支持寄存器复用和优化。

6. **callee-save 跨调用保存**：函数调用前将活跃的左操作数保存到 callee-save 寄存器，避免不必要的栈溢出。

7. **大值返回槽**：容器和大结构体通过栈上预分配的返回槽传递，避免大值复制。

---

## 19. 已知限制

- **x86 模式**：不支持 64 位标量（u64 需寄存器对，尚未实现），超宽类型钳制为 DWORD。
- **递归**：x86_64 上递归测试可能崩溃（栈帧布局问题）。
- **变参函数**：变参打包为 `[]T` 传递，需要 `memory` 包支持。
- **接口 vtable**：type_info 字段当前为 0 占位，未实现运行时类型信息。
