# gc_cond GC 分析报告

## 文件信息
- **路径**: `test/gc_cond/main.cute`
- **行数**: 66
- **函数数**: 3
- **exit**: 3 (3/3 检查通过 ✓)

## 类型定义

```cute
type Item struct { name: string; value: int }
```

## 函数摘要

| 函数 | retOwned | hasHeapAllocs | 参数逃逸 | 说明 |
|------|----------|---------------|----------|------|
| `makeItem` | OWN | Y | name(0) | 创建 Item，返回 ESCAPED |
| `pickItem` | OWN | Y | - | 4 条件分支，每个 ret makeItem |
| `main` | - | Y | - | 5 个局部变量 |

## LLR 分析

### main — 5 objs, 5 frees

```
obj[0] a   site=call:pickItem  FRAME_OWN   FREE a
obj[1] b   site=call:pickItem  FRAME_OWN   FREE b
obj[2] c   site=call:pickItem  FRAME_OWN   FREE c
obj[3] d   site=call:pickItem  FRAME_OWN   FREE d
obj[4] it  site=call:pickItem  FRAME_OWN   FREE it
```

### makeItem — 2 objs, 0 frees

```
obj[0] it  site=param:name  ESCAPED    (name 参数)
obj[1]     site=new         FRAME_OWN  (new(Item))
```

### pickItem — 0 objs, 0 frees

4 个分支各自 `ret makeItem(...)`，无本地帧对象。

## 出口释放计划

| 函数 | 待释放 | 变量列表 |
|------|--------|----------|
| main | 5 | a, b, c, d, p(it) |
| makeItem | 0 | (返回值被接管) |

## 测试场景

1. **条件分支**: `pickItem(1~4)` 4 条路径各分配
2. **循环内条件**: `for i < 10 { var it: *Item = pickItem(i) }` 每次循环分配
3. **if-else 两路径**: `if x > 3 { big } else { small }` 两条路径都分配
4. **全部通过**: 3/3 检查 ✓
