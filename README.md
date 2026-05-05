<!-- markdownlint-disable MD060 -->
# Cuteify

**Cute, but not just cute.**

Cuteify 是一门轻量级系统编程语言，编译为 x86 汇编代码。它提供从词法分析到代码生成的完整编译器实现，支持结构体、内联汇编、包管理、多种调用约定等特性，适合学习编译原理或构建底层系统软件。

## 特性

- **完整编译流程** — 词法分析 → 语法分析 → 类型检查 → 代码生成
- **x86 目标架构** — 生成 NASM 兼容的 32 位 x86 汇编，支持 cdecl / stdcall / fastcall 调用约定
- **结构体系统** — 支持字段访问控制（pub / priv / prot）、继承、方法绑定、标签注解
- **接口定义** — 通过 `interface` 关键字定义接口类型
- **内联汇编** — `build asm` 块中直接嵌入汇编指令，通过 `$变量名` 引用作用域变量
- **编译期指令** — `build os` 条件编译、`build link` 链接符号、`build ext` / `build extret` 外部函数声明
- **包管理** — 基于 `package.json` 的包系统，支持 `std:` 前缀引用标准库包
- **类型系统** — 丰富的内置类型，支持类型推断与自动类型兼容检查
- **智能寄存器分配** — LRU 策略寄存器管理器，支持溢出（spill）与 callee-save 保存
- **运行时库** — 提供内存管理（malloc/free）、字符串操作、系统调用封装等基础功能

## 目录结构

```text
tiny/
├── compile/              # 编译器后端
│   ├── arch/             # 目标架构抽象与实现
│   │   ├── arch.go       # Arch 接口定义 & 公共工具函数
│   │   └── x86/          # x86 架构实现
│   │       ├── cdecl.go  # cdecl 调用约定
│   │       ├── stdcall.go # stdcall 调用约定
│   │       ├── fastcall.go # fastcall 调用约定
│   │       ├── exp.go    # 表达式代码生成
│   │       └── utils.go  # 辅助函数
│   ├── context/          # 编译器上下文（函数、结构体、寄存器状态）
│   ├── regmgr/           # 寄存器分配管理器
│   ├── compiler.go       # 编译器主逻辑
│   ├── build.go          # build 指令编译
│   └── utils.go          # 辅助函数
├── error/                # 错误处理模块
├── lexer/                # 词法分析器
│   ├── lexer.go          # 词法分析主逻辑
│   └── keywords.go       # 关键字 & Token 类型定义
├── parser/               # 语法分析器
│   ├── parser.go         # 语法分析主逻辑
│   ├── func.go           # 函数定义解析
│   ├── var.go            # 变量声明解析
│   ├── ifelse.go         # if/else/elif 解析
│   ├── for.go            # for 循环解析
│   ├── call.go           # 函数调用解析
│   ├── return.go         # return 语句解析
│   ├── struct.go         # 结构体定义解析
│   ├── interface.go      # 接口定义解析
│   ├── build.go          # build 指令解析
│   ├── exp.go            # 表达式解析
│   ├── type.go           # 类型解析
│   ├── node.go           # AST 节点定义
│   └── finder.go         # 符号查找
├── type/                 # 类型系统
│   ├── type.go           # 类型定义 & 类型检查
│   └── struct.go         # 结构体类型
├── package/              # 包管理系统
│   ├── package.go        # 包加载 & 依赖解析
│   └── fmt/              # 包元信息定义
├── pkg/                  # 标准库包
│   ├── syscall/          # 系统调用封装
│   ├── memory/           # 内存管理（mmap/munmap/malloc/free）
│   └── fs/               # 文件系统操作（open/read/write/close）
├── runtime/              # 运行时库
│   ├── runtime.cute      # 运行时初始化 & 堆管理
│   ├── std.cute          # 标准库函数（new/make_slice/itoa/abs/min/max）
│   ├── string.cute       # 字符串操作（strlen/strcpy/strcmp/memcpy/memset）
│   ├── memory.cute       # 内存分配器（空闲链表实现）
│   ├── syscall.cute      # 系统调用封装
│   └── minimal.cute      # 最小化运行时
├── test/                 # 测试用例
│   ├── a.cute            # 基础结构体测试
│   ├── struct_test/      # 结构体字段修饰符测试
│   ├── struct_method/    # 结构体方法测试
│   ├── simple_method/    # 简单方法调用测试
│   ├── asm_test/         # 内联汇编测试
│   ├── build_keyword/    # 条件编译测试
│   ├── fs_test/          # 文件系统包测试
│   ├── memory_test/      # 内存管理测试
│   └── link_test/        # 链接指令测试
├── main.go               # 主程序入口
├── main_test.go          # 基准测试
├── go.mod                # Go 模块定义
├── run.sh                # Linux/macOS 构建脚本
└── run.bat               # Windows 构建脚本
```

## 快速开始

### 环境要求

- Go 1.25+
- NASM（汇编器）
- LD 或 GCC（链接器，需支持 32 位目标）

### 安装

```bash
git clone <repository-url>
cd tiny
go build -o cuteify
```

### 编译与运行

```bash
# 编译 .cute 源文件，生成 _main.asm
./cuteify ./test/memory_test

# 汇编为目标文件
nasm -f elf32 _main.asm

# 链接为可执行文件
ld -m elf_i386 -o output main.o --entry _start

# 运行
./output
```

也可使用构建脚本一键完成：

```bash
# Linux/macOS
./run.sh

# Windows
run.bat
```

### 环境变量

| 变量            | 说明     | 默认值  |
|-----------------|----------|---------|
| `CUTE_ARCH`     | 目标架构 | `x86`   |
| `CUTE_CALLCONV` | 调用约定 | `cdecl` |

## 语法参考

### 函数定义

```cute
fn add(a: i32, b: i32) i32 {
    ret a + b
}

fn main() i32 {
    ret add(3, 5)
}
```

函数名支持路径形式 `Type.Method`，用于绑定结构体方法：

```cute
fn Point.GetX() int {
    ret self.x
}
```

### 变量声明

```cute
x := 10              // 类型推断
y: i32 = 20          // 显式类型
z = x + y            // 赋值
```

### 控制流

```cute
// if / else / elif
if (x > 0) {
    // ...
} elif (x == 0) {
    // ...
} else {
    // ...
}

// for 循环
for (i := 1; i <= n;) {
    result = result + i
    i = i + 1
}
```

### 结构体

```cute
struct Point {
    x: int
    y: int
}

struct User {
    name: string
    age: int
}

// 字段访问控制
struct Config {
    _secret: string       // priv: 私有字段（下划线前缀）
    !readonly: bool       // 只读字段
    ?writeonly: i32       // 只写字段
    data: int = 10        // 带默认值
    meta: string `json:"config_meta"`  // 标签注解
}

// 继承
struct Student : Person {
    grade: int
    score: float
}

// 方法绑定
fn Point.GetX() int {
    ret self.x
}

fn Point.SetX(x: int) {
    self.x = x
}
```

### 接口

```cute
interface Reader {
    // 方法定义
}
```

### 内联汇编

通过 `build asm` 块嵌入汇编代码，使用 `$变量名` 引用当前作用域中的变量：

```cute
fn main() int {
    var x: int
    var y: int
    build asm {
        mov EAX, EBX
        mov [$x], 100
        mov [$y], EAX
        add [$x], [$y]
    }
    ret 0
}
```

系统调用封装示例：

```cute
fn sys_exit(code: i32) {
    build asm {
        mov EAX, 1
        mov EBX, $code
        int 0x80
    }
}
```

### 编译期指令

#### `build os` — 条件编译

根据目标操作系统有条件地包含代码：

```cute
build os(windows)

fn windowsFunc() int {
    ret 1
}

build os(linux)

fn linuxFunc() int {
    ret 2
}

build os(darwin, linux)

fn multiOSFunc() int {
    ret 3
}
```

#### `build link` — 链接符号

```cute
fn main() int {
    build link("test")
    ret 0
}
```

#### `build ext` / `build extret` — 外部函数声明

声明外部链接的函数，编译器不会为其生成函数体：

```cute
fn write(fd: u32, buf: u64, count: u64) u64 {
    build ext("write")
}
```

### 类型系统

| 类别       | 类型                                   | 大小                 |
|------------|----------------------------------------|----------------------|
| 有符号整数 | `i8`, `i16`, `i32`, `i64`, `int`       | 1 / 2 / 4 / 8 / 4 字节 |
| 无符号整数 | `u8`, `u16`, `u32`, `u64`, `uint`      | 1 / 2 / 4 / 8 / 4 字节 |
| 浮点数     | `f32`, `f64`                           | 4 / 8 字节           |
| 其他       | `bool`, `byte`, `string`               | 1 / 1 / — 字节       |

类型系统支持自动类型兼容检查：同族类型（如 `i32` 与 `i64`）在常量上下文中允许隐式转换。

### 包管理

每个包目录包含一个 `package.json`：

```json
{
    "name": "fs",
    "version": "1.0.0",
    "description": "File system operations package",
    "imports": {
        "syscall": "std:syscall"
    }
}
```

- `imports` 中使用 `std:` 前缀引用项目 `pkg/` 目录下的标准库包
- 非标准库包使用相对路径
- 编译器自动解析依赖并合并 AST

## 编译流程

```text
源代码 (.cute)
    │
    ▼
┌──────────┐
│  Lexer   │  词法分析：源代码 → Token 流
└──────────┘
    │
    ▼
┌──────────┐
│  Parser  │  语法分析：Token 流 → AST
└──────────┘
    │
    ▼
┌──────────┐
│  Check   │  语义检查：类型检查、变量使用验证
└──────────┘
    │
    ▼
┌──────────┐
│ Compile  │  代码生成：AST → x86 汇编
└──────────┘
    │
    ▼
汇编代码 (_main.asm)
```

### 代码生成细节

1. **函数编译** — 为每个函数生成序言（prologue）和尾声（epilogue），自动计算栈帧大小并按类型对齐
2. **变量分配** — 所有局部变量分配在栈上，按自然对齐规则计算偏移量
3. **寄存器管理** — LRU 策略分配 EAX / EBX / ECX / EDX，EBX 为 callee-save 寄存器；寄存器不足时自动溢出到栈
4. **表达式求值** — 递归生成表达式代码，结果存入寄存器或压栈
5. **入口点** — 若存在 `main` 函数，自动生成 `_start` 入口，调用 `main` 后通过 `int 0x80` 系统调用退出

## 模块说明

### lexer/ — 词法分析器

将源代码文本转换为 Token 序列。支持 14 种 Token 类型（关键字、标识符、运算符、字符串、数字、原始文本、布尔值、编译指令等），可识别 70+ 种符号和关键字。

### parser/ — 语法分析器

基于 Token 流构建 AST。支持函数定义、变量声明、控制流、表达式、结构体、接口、编译指令等语法结构。采用递归下降解析策略。

### type/ — 类型系统

提供类型定义、类型兼容性检查和类型推断。支持同族类型（整数族、无符号族、浮点族）之间的自动兼容判断，常量上下文中允许跨族转换。

### compile/ — 代码生成器

- `arch/` — 定义 `Arch` 接口，抽象目标架构的代码生成；x86 实现包含 cdecl、stdcall、fastcall 三种调用约定
- `regmgr/` — 寄存器分配管理器，支持 LRU 分配、溢出代价计算、callee-save 保存/恢复
- `context/` — 维护编译器全局状态（当前函数、结构体表、寄存器管理器、标签计数器等）

### package/ — 包管理系统

递归解析 `package.json` 中的依赖关系，加载并合并所有包的 AST。支持 `std:` 前缀映射到项目 `pkg/` 目录。

### pkg/ — 标准库

| 包         | 说明                                                  |
|------------|-------------------------------------------------------|
| `syscall`  | Linux x86 系统调用封装（`syscall` / `syscall6`）      |
| `memory`   | 内存管理（`mmap` / `munmap` / `malloc` / `free`）     |
| `fs`       | 文件操作（`open` / `read` / `write` / `close`）       |

### runtime/ — 运行时库

| 文件           | 说明                                               |
|----------------|----------------------------------------------------|
| `runtime.cute` | 运行时初始化、堆管理、print/println/panic          |
| `std.cute`     | 通用函数：new、make_slice、itoa、abs、min/max      |
| `string.cute`  | 字符串操作：strlen、strcpy、strcmp、memcpy、memset |
| `memory.cute`  | 基于空闲链表的内存分配器                           |
| `syscall.cute` | 系统调用高层封装                                   |
| `minimal.cute` | 最小化运行时（依赖外部 malloc/free）               |

## 测试

```bash
# 运行基准测试
go test -bench=. -benchmem

# 运行所有测试
go test -v
```

## 开发

### 添加新的目标架构

1. 在 `compile/arch/` 下创建新架构目录
2. 实现 `Arch` 接口的所有方法
3. 在 `compile/arch/arch.go` 中注册新架构

### 添加新的调用约定

1. 在 `compile/arch/x86/` 下创建新文件
2. 实现 `Arch` 接口，定义参数传递和栈清理规则
3. 在 `compile/arch/x86/x86.go` 中注册

### 添加标准库包

1. 在 `pkg/` 下创建新目录
2. 编写 `.cute` 源文件和 `package.json`
3. 在使用方的 `package.json` 中通过 `std:` 前缀引用

## 许可证

MIT
