# gc_nested GC 分析报告

## 文件信息
- **路径**: `test/gc_nested/main.cute`
- **行数**: 69
- **函数数**: 4
- **exit**: 5 (5/6 检查通过)

## 类型定义

```cute
type Inner struct { val: int; tag: string }
type Outer struct { name: string; data: *Inner; score: int }
```

## 函数摘要

| 函数 | retOwned | hasHeapAllocs | 参数逃逸 | 说明 |
|------|----------|---------------|----------|------|
| `makeInner` | OWN | Y | tag(0) | 创建 Inner，返回 ESCAPED |
| `makeOuter` | OWN | Y | name(0), tag(0) | 创建 Outer+Inner 两层 |
| `getInnerVal` | - | - | o(0) | 纯读取，无堆分配 |
| `main` | - | Y | - | 5 个局部变量 |

## LLR 分析

### main — 10 objs, 7 frees

```
obj[0]    site=call:makeOuter  FRAME_OWN   (o1 初始分配)
obj[1] o2 site=call:makeOuter  FRAME_OWN   FREE o2
obj[2] o3 site=call:makeOuter  FRAME_OWN   FREE o3
obj[3] o1 site=call:makeInner  FRAME_OWN   FREE o1     (o1.data = makeInner 替换)
obj[4]    site=call:makeOuter  FRAME_OWN   (a 初始)
obj[5]    site=call:makeOuter  FRAME_OWN   (b 初始)
obj[6] c  site=call:makeOuter  FRAME_OWN   FREE c
obj[7] a  site=call:makeInner  FRAME_OWN   FREE a      (a.data = makeInner 替换)
obj[0]    site=call:makeOuter  FRAME_OWN   (重绑定)
obj[4]    site=call:makeOuter  FRAME_OWN   (重绑定)
FREE o2 [unknown]
FREE o3 [unknown]
FREE o1 [unknown]
FREE c [unknown]
FREE a [unknown]
FREE call:makeOuter [heap-ptr] ×2
```

### makeInner — 2 objs, 0 frees

```
obj[0] p  site=param:tag  ESCAPED    (tag 参数)
obj[1]    site=new         FRAME_OWN  (new(Inner))
```

### makeOuter — 4 objs, 0 frees

```
obj[0] name site=param:name  ESCAPED
obj[1] tag  site=param:tag   ESCAPED
obj[2]      site=new         FRAME_OWN  (new(Outer))
obj[3] o    site=call:makeInner ESCAPED  (o.data = makeInner 返回值)
```

### getInnerVal — 0 objs, 0 frees

纯读取 `o.data.val`，无堆操作。

## 出口释放计划

| 函数 | 待释放 | 变量列表 |
|------|--------|----------|
| main | 5 | o1, o2, o3, b, c |
| makeInner | 0 | (返回值被接管) |
| makeOuter | 0 | (返回值被接管) |

## 测试场景

1. **嵌套分配**: `makeOuter` → 内部调用 `makeInner`，两层堆对象
2. **多结构体**: 3 个 Outer 同时存在
3. **替换内部**: `o1.data = makeInner(99, "replaced")` 旧 Inner 应被释放
4. **共享引用**: `b.data = a.data` 共享同一个 Inner
