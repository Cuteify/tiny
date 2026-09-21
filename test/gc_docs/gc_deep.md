# gc_deep GC 分析报告

## 文件信息
- **路径**: `test/gc_deep/main.cute`
- **行数**: 70
- **函数数**: 7
- **exit**: 3 (3/3 检查通过 ✓)

## 类型定义

```cute
type User struct { name: string; age: int; email: string }
```

## 函数摘要

| 函数 | retOwned | hasHeapAllocs | 参数逃逸 | 说明 |
|------|----------|---------------|----------|------|
| `makeUser` | OWN | Y | name(0), email(0) | 创建 User |
| `level1` | OWN | Y | - | 调用 makeUser |
| `level2` | OWN | Y | - | 调用 level1，修改 age |
| `level3` | OWN | Y | - | 调用 level2，修改 age |
| `level4` | OWN | Y | - | 调用 level3，修改 age |
| `level5` | OWN | Y | - | 调用 level4，修改 age |
| `main` | - | Y | - | 6 个局部变量 |

## LLR 分析

### main — 6 objs, 6 frees

```
obj[0] u1    site=call:level5   FRAME_OWN   FREE u1
obj[1] a     site=call:level3   FRAME_OWN   FREE a
obj[2] b     site=call:level4   FRAME_OWN   FREE b
obj[3] c     site=call:level5   FRAME_OWN   FREE c
obj[4] deep  site=call:level5   FRAME_OWN   FREE deep
obj[5] local site=call:makeUser FRAME_OWN   FREE local
```

### level5 — 1 obj, 0 frees

```
obj[0] u  site=call:level4  ESCAPED    (返回给调用者)
```

### level4 — 1 obj, 0 frees

```
obj[0] u  site=call:level3  ESCAPED    (返回给调用者)
```

### level3 — 1 obj, 0 frees

```
obj[0] u  site=call:level2  ESCAPED    (返回给调用者)
```

### level2 — 1 obj, 0 frees

```
obj[0] u  site=call:level1  ESCAPED    (返回给调用者)
```

### level1 — 0 objs, 0 frees

直接 `ret makeUser(...)`，无本地帧对象。

### makeUser — 3 objs, 0 frees

```
obj[0] name  site=param:name  ESCAPED
obj[1] u     site=param:email ESCAPED
obj[2]        site=new         FRAME_OWN  (new(User))
```

## 出口释放计划

| 函数 | 待释放 | 变量列表 |
|------|--------|----------|
| main | 6 | u1, a, b, c, deep, local |
| level1-5 | 0 | (返回值被接管) |

## 测试场景

1. **五层嵌套**: `level5() → level4 → level3 → level2 → level1 → makeUser`
2. **并行深调用**: 3 条独立调用链同时存在
3. **深调用+本地**: `level5()` + `makeUser()` 混合
4. **全部通过**: 3/3 检查 ✓
