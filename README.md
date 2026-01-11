# Cuteify

**Cute, but not just cute.**

一个轻量级编程语言，支持编译为 x86 汇编代码。包含词法分析、语法分析、类型检查、代码生成和递归优化等完整编译器实现。

## 特性

- **完整的编译流程**：词法分析 → 语法分析 → 类型检查 → 代码生成
- **x86 目标架构**：生成 NASM 兼容的 x86 汇编代码
- **递归优化**：自动检测并优化递归函数，转换为迭代版本
- **类型系统**：支持多种基本数据类型（i8, i16, i32, i64, u8, u16, u32, u64, f32, f64, bool, byte, string）
- **控制流**：支持 if/else、for 循环、函数调用和返回
- **寄存器管理**：智能寄存器分配和栈空间管理

## 目录结构

```
tiny/
├── compile/          # 编译器后端
│   ├── arch/        # 目标架构相关代码
│   │   └── x86/     # x86 架构实现（cdecl/stdcall 调用约定）
│   ├── context/     # 编译器上下文
│   └── regmgr/      # 寄存器管理器
├── error/           # 错误处理模块
├── lexer/           # 词法分析器
├── optimizer/       # 优化器
│   └── recursion/   # 递归优化模块
├── parser/          # 语法分析器
├── type/            # 类型系统
├── utils/           # 工具函数
├── test/            # 测试用例
└── main.go          # 主程序入口
```

## 快速开始

### 环境要求

- Go 1.25+
- NASM（汇编器）
- GCC 或 LD（链接器）

### 安装

```bash
git clone <repository-url>
cd tiny
go build -o tiny
```

### 使用方法

编译 `.cute` 源文件：

```bash
# 使用默认 test 目录
./tiny

# 编译指定文件或目录
./tiny ./test/a.cute

# 编译并生成可执行文件
./tiny ./test/a.cute
nasm -f elf32 _main.asm
ld -m elf_i386 _main.o -o output
./output
```

或者使用提供的脚本：

```bash
# Linux/macOS
./run.sh

# Windows
run.bat
```

## 语法示例

### 函数定义

```cute
fn fib(i:i32) i32 {
    if (i<=2) {
        ret 1
    }
    ret fib(i-1) + fib(i-2)
}
```

### 变量与赋值

```cute
fn main() {
    x := 10
    y:i32 = 20
    z = x + y
}
```

### 循环

```cute
fn sum(n:i32) i32 {
    result := 0
    for (i:=1; i<=n;) {
        result = result + i
        i = i + 1
    }
    ret result
}
```

### 类型系统

支持以下类型：

- 整数类型：`i8`, `i16`, `i32`, `i64`, `u8`, `u16`, `u32`, `u64`, `int`, `uint`
- 浮点类型：`f32`, `f64`
- 其他：`bool`, `byte`, `string`

## 编译流程

1. **词法分析**（lexer/）：将源代码转换为 Token 流
2. **语法分析**（parser/）：构建抽象语法树（AST）
3. **类型检查**：验证类型兼容性和变量使用
4. **优化**（optimizer/）：递归函数检测与转换
5. **代码生成**（compile/）：生成 x86 汇编代码

### 递归优化

编译器会自动检测以下递归模式并进行优化：

- **简单线性递归**：转换为简单循环
- **双重递归**：转换为动态规划版本
- **尾递归**：转换为循环
- **复杂递归**：使用栈模拟

优化器会在编译过程中自动分析和转换递归函数，提高程序执行效率。

## 模块说明

### lexer/ - 词法分析器

负责将源代码文本转换为 Token 序列，处理关键字、标识符、运算符、字符串等。

### parser/ - 语法分析器

基于 Token 流构建 AST，支持函数定义、控制流、表达式等语法结构。

### type/ - 类型系统

提供类型定义、类型检查和类型推断功能。

### optimizer/ - 优化器

主要功能：
- 检测递归函数模式
- 将递归转换为迭代版本
- 消除递归带来的栈开销

### compile/ - 代码生成器

- `arch/`：目标架构接口定义和实现
- `regmgr/`：寄存器分配和管理
- `context/`：编译器上下文维护

## 编译选项

通过环境变量设置目标架构：

```bash
# 默认 x86
./tiny

# 指定架构（未来扩展）
CUTE_ARCH=arm ./tiny
```

## 测试

运行测试用例：

```bash
go test -v
```

测试文件位于 `test/` 目录，包含各种语法和功能测试。

## 开发

### 添加新的目标架构

1. 在 `compile/arch/` 下创建新架构目录
2. 实现 `Arch` 接口
3. 在 `compile/arch/arch.go` 中注册新架构

### 添加新的优化策略

在 `optimizer/recursion/` 目录下添加新的检测和转换逻辑。

## 许可证

本项目仅供学习和研究使用。

## 贡献

欢迎提交 Issue 和 Pull Request！
