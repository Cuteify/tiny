# GC 测试总览

## 文件索引

| 测试 | 路径 | 行数 | 函数数 | 覆盖场景 | exit |
|------|------|------|--------|----------|------|
| [gc_complex](gc_complex.md) | `test/gc_complex/main.cute` | 206 | 12 | BST+链表+嵌套+字符串+分支+循环 | 8/10 |
| [gc_nested](gc_nested.md) | `test/gc_nested/main.cute` | 69 | 4 | 嵌套结构体，替换内部指针 | 5/6 |
| [gc_loop](gc_loop.md) | `test/gc_loop/main.cute` | 81 | 5 | 链表 prepend，循环重赋值 | 3/5 |
| [gc_cond](gc_cond.md) | `test/gc_cond/main.cute` | 66 | 3 | 条件分支分配，循环内条件 | 3/3 ✓ |
| [gc_string](gc_string.md) | `test/gc_string/main.cute` | 70 | 4 | 字符串循环拼接，重用变量 | 6/6 ✓ |
| [gc_deep](gc_deep.md) | `test/gc_deep/main.cute` | 70 | 7 | 5 层嵌套调用链 | 3/3 ✓ |
| [gc_multiret](gc_multiret.md) | `test/gc_multiret/main.cute` | 67 | 4 | 多指针结构体，swap，共享引用 | 4/4 ✓ |

## 场景覆盖矩阵

| 场景 | complex | nested | loop | cond | string | deep | multiret |
|------|---------|--------|------|------|--------|------|----------|
| `new(T)` 分配 | ✓ | ✓ | ✓ | ✓ | - | ✓ | ✓ |
| `*T` 指针 | ✓ | ✓ | ✓ | ✓ | - | ✓ | ✓ |
| 参数传递 ESCAPED | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 返回值 ESCAPED | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 循环内分配 | ✓ | - | ✓ | ✓ | ✓ | - | - |
| 条件分支分配 | ✓ | - | - | ✓ | - | - | - |
| 变量重赋值 | ✓ | ✓ | ✓ | - | ✓ | - | ✓ |
| 嵌套结构体 | - | ✓ | - | - | - | - | ✓ |
| 链表 | ✓ | - | ✓ | - | - | - | - |
| BST | ✓ | - | - | - | - | - | - |
| 字符串拼接 | ✓ | - | - | - | ✓ | - | - |
| 深调用链 | ✓ | - | - | - | - | ✓ | - |
| `nil` 比较 | ✓ | - | ✓ | - | - | - | - |
| `null_init` 追踪 | ✓ | - | ✓ | - | ✓ | - | - |
| 共享引用 | - | ✓ | - | - | - | - | ✓ |
| 替换内部指针 | - | ✓ | - | - | - | - | ✓ |

## 关键 GC 概念验证

### 1. FRAME_OWN vs ESCAPED
- **FRAME_OWN**: 本地分配，函数退出时释放
- **ESCAPED**: 传递给调用者，由调用者管理生命周期

### 2. null_init
- `var tree: *Node = nil` 创建 null_init 绑定
- 标记为 ESCAPED 避免误 FREE
- 后续 `tree = bstInsert(tree, val)` 追踪旧值 orphans

### 3. orphans（孤儿）
- 变量重赋值时，旧对象如果非参数、未逃逸，记入 orphans
- 函数退出时 orphans 对象被 FREE

### 4. 字符串拼接
- `s = s + "A"` 标记为 `string-concat`
- 旧 s 成为 orphans，新 s 绑定
- 返回类型 OWN → 调用者接管

## 统计

| 指标 | 值 |
|------|-----|
| 总测试数 | 7 |
| 总函数数 | 39 |
| 总行数 | 623 |
| 平均 objs/函数 | 3.2 |
| 平均 frees/函数 | 1.8 |
| 最大 main objs | 39 (gc_complex) |
| 最大 main frees | 27 (gc_complex) |
