# 优化器包使用说明

## 概述

`optimizer` 包提供编译器优化功能，主要包括：
1. **递归函数分析和转换** - 将递归函数自动转换为迭代器
2. **复合赋值运算符展开** - 将 `++`, `--`, `+=`, `*=` 等运算符展开为普通赋值

## 核心功能

### 1. 递归分析 (`recursion_analyzer.go`)

#### 递归类型识别

支持 7 种递归类型的自动识别：

| 类型 | 说明 | 示例 | 转换策略 |
|------|------|------|----------|
| `SimpleLinear` | 简单线性递归 | factorial, gcd | 累加器/累乘器 |
| `DoubleRecursion` | 双递归 | fibonacci | 动态规划（数组） |
| `TailRecursive` | 尾递归 | 优化后的函数 | 直接转换为循环 |
| `MutualRecursive` | 相互递归 | A调用B，B调用A | ⚠️ 不支持 |
| `NestedRecursive` | 嵌套递归 | ackermann | ⚠️ 需要显式栈 |
| `TreeRecursion` | 树递归 | 二叉树遍历 | ⚠️ 需要显式栈 |
| `GeneralRecursive` | 一般递归 | 其他复杂模式 | ⚠️ 不支持 |
| `NoRecursion` | 无递归 | 普通函数 | 不需要转换 |

#### API

```go
import "cuteify/optimizer"

// 分析函数的递归类型
info := optimizer.AnalyzeRecursionType(funcNode)

// 查看分析结果（调试用）
optimizer.PrintRecursionInfo(info)

// 将递归函数转换为迭代器（自动处理所有类型）
info := optimizer.TransformRecursionToIteration(funcNode)
```

#### 返回信息 (`RecursionInfo`)

```go
type RecursionInfo struct {
    Type             RecursionType    // 递归类型
    IsRecursive      bool             // 是否递归
    RecursiveCalls   []*parser.Node   // 所有递归调用点
    BaseCaseNodes    []*parser.Node   // 基本情况的节点
    RecursiveParams  []string         // 递归参数
    LoopVar          string           // 循环变量
    LoopCond         *parser.Expression // 循环条件
    LoopBody         []*parser.Node   // 循环体
    LoopInit         []*parser.Node   // 循环初始化
    LoopUpdate       []*parser.Node   // 循环更新
}
```

### 2. 复合赋值展开 (`optimizer.go`)

#### 支持的运算符

- 自增/自减：`++`, `--`
- 复合赋值：`+=`, `-=`, `*=`, `/=`, `%=`, `^=`, `&=`, `|=`, `<<=`, `>>=`

#### API

```go
// 展开节点及其子树中的所有复合赋值运算符
optimizer.ExpandCompoundAssignments(node)

// 示例：x++  =>  x = x + 1
// 示例：x *= y  =>  x = x * y
```

## 使用示例

### 示例 1：转换单个递归函数

```go
package main

import (
    "cuteify/parser"
    "cuteify/optimizer"
)

func main() {
    // 假设已经有解析好的 AST
    var programNode *parser.Node

    // 分析递归类型
    info := optimizer.AnalyzeRecursionType(funcNode)
    optimizer.PrintRecursionInfo(info)

    // 转换为迭代器
    if info.IsRecursive {
        optimizer.TransformRecursionToIteration(funcNode)
    }

    // 展开复合赋值运算符
    optimizer.ExpandCompoundAssignments(funcNode)
}
```

### 示例 2：批量转换所有递归函数

```go
package main

import (
    "cuteify/parser"
    "cuteify/optimizer"
    "fmt"
)

func main() {
    var programNode *parser.Node

    // 转换所有递归函数
    results := optimizer.ConvertAllRecursions(programNode)

    // 打印结果
    convertedCount := 0
    for i, success := range results {
        if success {
            convertedCount++
            fmt.Printf("函数 %d: 成功转换\n", i+1)
        } else {
            fmt.Printf("函数 %d: 未转换（非递归或不支持）\n", i+1)
        }
    }
    fmt.Printf("总计转换: %d 个函数\n", convertedCount)
}
```

### 示例 3：单独使用复合赋值展开

```go
package main

import (
    "cuteify/parser"
    "cuteify/optimizer"
)

func main() {
    var funcNode *parser.Node

    // 只展开复合赋值运算符，不转换递归
    optimizer.ExpandCompoundAssignments(funcNode)
}
```

## 转换效果

### ✅ 已支持的递归转换

#### 1. 简单线性递归 (SimpleLinear)

**示例**：factorial

```
// 原始代码
fn factorial(n:i32) i32 {
    if (n <= 1) {
        ret 1
    }
    ret n * factorial(n - 1)
}

// 转换后（迭代）
fn factorial(n:i32) i32 {
    n_result = 1
    for (n > 1) {
        n_result = n_result * n
        n--
    }
    ret n_result
}
```

**示例**：sum

```
// 原始代码
fn sum(n:i32) i32 {
    if (n <= 0) {
        ret 0
    }
    ret n + sum(n - 1)
}

// 转换后（迭代）
fn sum(n:i32) i32 {
    n_result = 0
    for (n > 0) {
        n_result = n_result + n
        n--
    }
    ret n_result
}
```

**示例**：gcd

```
// 原始代码
fn gcd(a:i32, b:i32) i32 {
    if (b == 0) {
        ret a
    }
    ret gcd(b, a % b)
}

// 转换后（迭代）
fn gcd(a:i32, b:i32) i32 {
    for (b != 0) {
        temp = a % b
        a = b
        b = temp
    }
    ret a
}
```

#### 2. 尾递归 (TailRecursive)

与简单线性递归使用相同的转换策略，但已手动优化为尾递归形式。

### ⚠️ 暂不支持的递归转换

#### 1. 双递归 (DoubleRecursion)

**示例**：fibonacci

```
// 原始代码
fn fib(i:i32) i32 {
    if (i <= 2) {
        ret 1
    }
    ret fib(i-1) + fib(i-2)
}

// 正确的迭代版本（需要动态规划）
fn fib(i:i32) i32 {
    prev = 0
    cur = 1
    for (j := 0; j < i; j++) {
        next = prev + cur
        prev = cur
        cur = next
    }
    ret prev
}
```

**转换需求**：
- 需要分配数组或多个变量存储中间结果
- 实现动态规划算法
- 当前版本不自动转换

#### 2. 嵌套递归 (NestedRecursive)

**示例**：ackermann

```
// 原始代码
fn ackermann(m:i32, n:i32) i32 {
    if (m == 0) {
        ret n + 1
    } else if (n == 0) {
        ret ackermann(m - 1, 1)
    } else {
        ret ackermann(m - 1, ackermann(m, n - 1))
    }
}
```

**转换需求**：
- 需要显式栈模拟递归调用栈
- 当前版本不自动转换

#### 3. 树递归 (TreeRecursion)

**示例**：二叉树遍历

```
// 原始代码
fn traverse(node:TreeNode) {
    if (node == nil) {
        ret
    }
    traverse(node.left)
    visit(node)
    traverse(node.right)
}
```

**转换需求**：
- 需要显式栈模拟递归遍历
- 当前版本不自动转换

#### 4. 相互递归 (MutualRecursive)

```
// 原始代码
fn isEven(n:i32) bool {
    if (n == 0) {
        ret true
    }
    ret isOdd(n - 1)
}

fn isOdd(n:i32) bool {
    if (n == 0) {
        ret false
    }
    ret isEven(n - 1)
}
```

**转换需求**：
- 需要复杂的控制流分析
- 当前版本不自动转换

### 使用方法

```go
// 自动转换递归函数
info := optimizer.TransformRecursionToIteration(funcNode)

if info.IsRecursive {
    fmt.Printf("转换成功! 类型: %s\n",
        optimizer.GetRecursionTypeString(info.Type))
} else {
    fmt.Printf("不是递归函数\n")
}
```

### 复合赋值展开

#### 原始代码
```
i++
x *= 2
arr[index] += 5
```

#### 展开后
```
i = i + 1
x = x * 2
arr[index] = arr[index] + 5
```

## 注意事项

1. **AST 依赖** - 所有函数都依赖 `parser.Node` 类型的 AST 结构

2. **转换限制** - 不是所有递归都能转换：
   - 相互递归目前不支持转换
   - 复杂的递归模式可能需要手动调整

3. **类型系统** - 需要配合类型系统 `typeSys` 使用

4. **调用时机** - 建议在语法分析和类型检查之后调用优化器

5. **性能优化** - 尾递归转换效果最好，能完全消除递归开销

## 调试技巧

使用 `PrintRecursionInfo()` 查看详细的递归分析信息：

```go
info := optimizer.AnalyzeRecursionType(funcNode)
optimizer.PrintRecursionInfo(info)
```

输出示例：
```
=== Recursion Analysis Result ===
Is Recursive: true
Recursion Type: Tail Recursion
Number of Recursive Calls: 1
Number of Base Cases: 1
Recursive Parameters: [n]
Loop Variable: n
===============================
```

## 完整工作流

```
源代码 (.cute)
    ↓
[词法分析] lexer
    ↓
[语法分析] parser → AST
    ↓
[类型检查] typeSys
    ↓
[递归分析] optimizer.AnalyzeRecursionType()
    ↓
[递归转换] optimizer.TransformRecursionToIteration()
    ↓
[复合赋值展开] optimizer.ExpandCompoundAssignments()
    ↓
[代码生成] compile
    ↓
目标代码
```
