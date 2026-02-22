# self 和 *self 使用指南

## 概述

在 Cute 语言中，方法使用 `self` 和 `*self` 作为接收者来访问结构体实例。

**重要**：`self` 本身就是指针（指向实例的指针），`*self` 是解引用操作（获取实际的值）。

## 语法

### 方法定义

```cute
fn StructName.MethodName() ReturnType {
    // 方法体
}

fn StructName.MethodName(param1: Type, ...) ReturnType {
    // 方法体
}
```

**重要说明**：
- `self` 和 `*self` **完全隐式**，不需要在参数列表中声明
- 方法体内直接使用 `self` 或 `*self` 来访问接收者
- 编译器自动识别方法体内使用的 `self` 或 `*self`

### 方法调用

```cute
// self 隐式传递，不需要显式传递
instance.MethodName(param1, param2, ...)
```

### self vs *self

| 特性 | self | *self |
|------|----------------|-------------------|
| 类型 | *StructType（指针） | StructType（值） |
| 语义 | 指向实例的指针 | 解引用获取的值 |
| 访问方式 | 通过指针访问 | 直接访问值 |
| 内存开销 | 只传递指针 | 需要复制值 |
| 使用场景 | 通过指针访问和修改 | 获取结构体的副本 |

## self 和 *self 表达式

### 直接使用 self 和 *self

在方法体内，可以直接使用 `self` 和 `*self` 作为表达式：

```cute
// self - 获取指针
fn Point.GetPointer() *Point {
    return self  // 返回指针
}

// *self - 解引用获取值
fn Point.GetValue() Point {
    return *self  // 返回值
}
```

### 语义说明

| 表达式 | 类型 | 用途 | 示例 |
|--------|------|------|------|
| `self` | *StructType | 获取指针 | `return self` |
| `*self` | StructType | 解引用获取值 | `return *self` |
| `self.field` | FieldType | 通过指针访问字段 | `return self.x` |

## 使用示例

### 基本用法

```cute
struct Point {
    x: int
    y: int
}

// self - 通过指针读取字段值
fn Point.GetX() int {
    return self.x
}

fn Point.GetY() int {
    return self.y
}

// *self - 解引用后修改字段值
fn Point.SetX(x: int) {
    self.x = x
}

fn Point.SetY(y: int) {
    self.y = y
}
```

### 方法调用（self 隐式传递）

```cute
p: Point = Point{x: 10, y: 20}

// 调用 self 方法（self 隐式传递）
x: int = p.GetX()     // 10
y: int = p.GetY()     // 20

// 调用 *self 方法（self 隐式传递）
p.SetX(15)            // p.x = 15
p.SetY(25)            // p.y = 25
```

### 直接使用 self 和 *self 表达式

```cute
struct Point {
    x: int
    y: int
}

// self 获取值
fn Point.GetValue() Point {
    return self  // 返回结构体值
}

// self - 获取指针
fn Point.GetPointer() *Point {
    return self  // 返回指针
}

// *self - 解引用获取值
fn Point.GetValue() Point {
    return *self  // 返回值
}

// 通过指针赋值
fn Point.CopyTo(target: *Point) {
    // self 是指针，target 也是指针
    target.x = self.x
    target.y = self.y
}
```

### 对比：显式传递 vs 隐式传递

```cute
// ❌ 错误：self 不需要显式传递
x: int = p.GetX(self)  // 编译错误！

// ✅ 正确：self 隐式传递
x: int = p.GetX()      // 正确！

// ❌ 错误：self 不需要显式传递
p.SetX(self, 15)       // 编译错误！

// ✅ 正确：self 隐式传递，只传递其他参数
p.SetX(15)             // 正确！
```

### 方法定义语法对比

```cute
// ❌ 错误：不需要声明 self 参数
// fn Point.SetX(self: *Point, x: int) {
//     self.x = x
// }

// ✅ 正确：self 完全隐式，不写在参数列表中
fn Point.SetX(x: int) {
    self.x = x
}

// self 和 *self 在方法体内直接使用，不需要声明
```

### 复杂示例

```cute
struct Counter {
    value: int
}

// 读取操作使用 self
fn Counter.GetValue(self: Counter) int {
    return self.value
}

fn Counter.IsZero(self: Counter) bool {
    return self.value == 0
}

// 修改操作使用 *self
fn Counter.Increment(self: *Counter) {
    self.value = self.value + 1
}

fn Counter.Add(self: *Counter, delta: int) {
    self.value = self.value + delta
}

// 混合使用
fn Counter.Double(self: *Counter) {
    // 在 *self 方法中可以调用 self 方法
    current: int = self.GetValue()
    self.value = current * 2
}
```

## 设计原则

### 何时使用 self

- 只需要读取字段值
- 不需要修改结构体状态
- 结构体较小（复制开销小）
- 方法需要保证不被修改

### 何时使用 *self

- 需要修改字段值
- 结构体较大（避免复制）
- 方法需要修改状态
- 需要传递给其他需要指针的函数

## 编译器行为

### self 接收者

```cute
fn Point.GetX(self: Point) int {
    return self.x
}

// 调用方式（self 隐式传递）：
// x: int = p.GetX()

// 编译器会生成类似这样的代码：
// int Point_GetX(Point self) {
//     return self.x;
// }
```

### *self 接收者

```cute
fn Point.SetX(self: *Point, x: int) {
    self.x = x
}

// 调用方式（self 隐式传递，只传递 x 参数）：
// p.SetX(15)

// 编译器会生成类似这样的代码：
// void Point_SetX(Point* self, int x) {
//     self->x = x;
// }
```

### 方法调用的转换

**Cute 源码：**
```cute
p.SetX(15)
```

**编译器转换为：**
```c
Point_SetX(&p, 15)  // 自动传入 &p 作为 self，15 作为 x
```

## 方法调用规则

1. **self 方法**：可以在值上调用，编译器会自动复制值
2. **self 方法**：可以在指针上调用，编译器会自动解引用
3. **self 方法**：不能在方法内修改原值
4. ***self 方法**：可以在值上调用（如果值是可寻址的）
5. ***self 方法**：可以在指针上调用
6. ***self 方法**：可以在方法内修改原值
7. **所有方法**：调用时 `self` 隐式传递，不需要显式写参数

## 注意事项

1. **一致性**：同一结构体的方法应该保持一致的接收者类型
2. **性能**：大型结构体优先使用 *self
3. **安全性**：只读方法应该使用 self
4. **可变性**：需要修改状态的方法必须使用 *self
5. **递归调用**：*self 方法可以调用 self 方法

## 实现细节

### ReceiverBlock 结构

```go
type ReceiverBlock struct {
    Name      string         // "self" 或 "*self"
    Type      *typeSys.RType // 接收者类型
    IsPointer bool           // 是否指针接收
    VarNode   *Node          // 对应的 VarBlock 节点
}
```

### SelfBlock 结构

```go
type SelfBlock struct {
    IsPointer bool   // 是否是 *self 访问
    Field     string // 访问的字段（如 self.x）
    StartCursor int
}
```

### 解析流程

1. 解析器识别 `fn StructName.MethodName` 格式
2. 解析接收者声明 `(self: StructType)` 或 `(*self: *StructType)`
3. 创建 `ReceiverBlock` 节点
4. 解析方法体中的 `self` 和 `*self` 访问
5. 创建 `SelfBlock` 节点处理字段访问

## 关键字

- `self`：值接收者关键字，已添加到 lexer 的 NAME 类型
- `*self`：指针接收者关键字，通过 SEPARATOR "*" 和 NAME "self" 组合
