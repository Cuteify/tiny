# gc_multiret GC 分析报告

## 文件信息
- **路径**: `test/gc_multiret/main.cute`
- **行数**: 67
- **函数数**: 4
- **exit**: 4 (4/4 检查通过 ✓)

## 类型定义

```cute
type User struct { name: string; age: int; email: string }
type Pair struct { first: *User; second: *User }
```

## 函数摘要

| 函数 | retOwned | hasHeapAllocs | 参数逃逸 | 说明 |
|------|----------|---------------|----------|------|
| `makeUser` | OWN | Y | name(0), email(0) | 创建 User |
| `makePair` | OWN | Y | a(0), b(0) | 创建 Pair，含两个 *User |
| `swapPair` | - | - | p(0) | 交换 first/second，无分配 |
| `main` | - | Y | - | 6 个局部变量 |

## LLR 分析

### main — 8 objs, 7 frees

```
obj[0] u1    site=call:makeUser  FRAME_OWN   FREE u1
obj[1] u2    site=call:makeUser  FRAME_OWN   FREE u2
obj[2]       site=call:makePair  FRAME_OWN   FREE call:makePair
obj[3] pair  site=call:makeUser  FRAME_OWN   FREE pair
obj[4] u3    site=call:makeUser  FRAME_OWN   FREE u3
obj[5] p1    site=call:makePair  FRAME_OWN   FREE p1
obj[6] p2    site=call:makePair  FRAME_OWN   FREE p2
obj[2]       site=call:makePair  FRAME_OWN   (重绑定)
```

### makeUser — 3 objs, 0 frees

```
obj[0] name  site=param:name  ESCAPED
obj[1] u     site=param:email ESCAPED
obj[2]        site=new         FRAME_OWN  (new(User))
```

### makePair — 3 objs, 0 frees

```
obj[0] a  site=param:a  ESCAPED    (User 指针传递)
obj[1] b  site=param:b  ESCAPED    (User 指针传递)
obj[2]    site=new      FRAME_OWN  (new(Pair))
```

### swapPair — 0 objs, 0 frees

纯交换 `p.first`/`p.second` 指针，无堆操作。

## 出口释放计划

| 函数 | 待释放 | 变量列表 |
|------|--------|----------|
| main | 6 | u1, u2, pair, u3, p1, p2 |
| makeUser | 0 | (返回值被接管) |
| makePair | 0 | (返回值被接管) |

## 测试场景

1. **多指针结构体**: Pair 含 first/second 两个 *User
2. **交换后访问**: `swapPair` 后读取 `pair.first.age`
3. **替换内部**: `pair.first = makeUser("carol", ...)` 旧 User orphans
4. **共享引用**: `p1` 和 `p2` 共享 `u3`
5. **全部通过**: 4/4 检查 ✓
