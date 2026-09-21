# gc_loop GC 分析报告

## 文件信息
- **路径**: `test/gc_loop/main.cute`
- **行数**: 81
- **函数数**: 5
- **exit**: 3 (3/5 检查通过)

## 类型定义

```cute
type Node struct { val: int; next: *Node }
```

## 函数摘要

| 函数 | retOwned | hasHeapAllocs | 参数逃逸 | 说明 |
|------|----------|---------------|----------|------|
| `makeNode` | OWN | Y | - | 创建 Node，返回 ESCAPED |
| `prepend` | OWN | Y | head(0) | 头插法，新节点 next=head |
| `sum` | - | - | head(0) | 链表求和，纯遍历 |
| `length` | - | - | head(0) | 链表长度，纯遍历 |
| `main` | - | Y | - | 3 个局部变量 |

## LLR 分析

### main — 16 objs, 8 frees

```
obj[0]         site=null_init       ESCAPED     (head 初始 nil)
obj[1]         site=call:prepend    FRAME_OWN   FREE call:prepend
obj[2]         site=call:prepend    FRAME_OWN   FREE call:prepend
obj[3]         site=call:prepend    FRAME_OWN   FREE call:prepend
obj[4]         site=call:prepend    FRAME_OWN   FREE call:prepend
obj[5]         site=call:prepend    FRAME_OWN   FREE call:prepend
obj[6]         site=call:prepend    FRAME_OWN   FREE call:prepend
obj[7] head    site=call:prepend    FRAME_OWN   FREE head
obj[8]         site=null_init       ESCAPED     (head 重置 nil)
obj[9] big     site=call:prepend    FRAME_OWN   FREE big
obj[1-6]       site=call:prepend    FRAME_OWN   FREE call:prepend ×6
```

### makeNode — 1 obj, 0 frees

```
obj[0] n  site=new  ESCAPED    (返回给 prepend)
```

### prepend — 2 objs, 0 frees

```
obj[0] n  site=param:head  ESCAPED    (旧 head 传递给 next)
obj[1]    site=new         FRAME_OWN  (new(Node))
```

### sum — 0 objs, 0 frees

纯遍历，无堆分配。

### length — 0 objs, 0 frees

纯遍历，无堆分配。

## 出口释放计划

| 函数 | 待释放 | 变量列表 |
|------|--------|----------|
| main | 0 | (head, big 在 LLR 中追踪) |

## 测试场景

1. **链表构建**: 5 次 prepend → 1→2→3→4→5
2. **重用变量**: `head = nil` 后重建 10→20
3. **循环构建**: 100 次 prepend 构建大链表
4. **多次重赋值**: head 被重赋值 7 次，每次都追踪 orphans
