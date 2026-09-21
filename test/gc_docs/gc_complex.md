# gc_complex GC 分析报告

## 文件信息
- **路径**: `test/gc_complex/main.cute`
- **行数**: 206
- **函数数**: 12
- **exit**: 8 (8/10 检查通过)

## 类型定义

```cute
type User struct { name: string; age: int; email: string }
type Node struct { val: int; left: *Node; right: *Node }
type Link struct { data: int; next: *Link }
```

## 函数摘要

| 函数 | retOwned | hasHeapAllocs | 参数逃逸 | 说明 |
|------|----------|---------------|----------|------|
| `makeUser` | OWN | Y | name(0), email(0) | 创建 User，3 参数 ESCAPED |
| `makeNode` | OWN | Y | - | 创建 Node，返回 ESCAPED |
| `bstInsert` | OWN | Y | root(1) | BST 插入，递归调用自身 |
| `bstSum` | - | - | root(0) | BST 求和，纯遍历 |
| `linkPrepend` | OWN | Y | head(0) | 链表头插 |
| `linkSum` | - | - | head(0) | 链表求和，纯遍历 |
| `deepAlloc3` | OWN | Y | - | 调用 makeUser |
| `deepAlloc2` | OWN | Y | - | 调用 deepAlloc3，本地 u1 FREE |
| `deepAlloc1` | OWN | Y | - | 调用 deepAlloc2，本地 u1 FREE |
| `buildStr` | OWN | Y | - | 循环字符串拼接 |
| `branchPick` | OWN | Y | - | 4 条件分支各分配 |
| `main` | - | Y | - | 15 个局部变量，全部追踪 |

## LLR 分析

### main — 39 objs, 27 frees

```
obj[0]  u1     site=call:makeUser    FRAME_OWN   FREE u1
obj[1]  u2     site=call:makeUser    FRAME_OWN   FREE u2
obj[2]  u3     site=call:makeUser    FRAME_OWN   FREE u3
obj[3]         site=null_init        ESCAPED     (tree 初始 nil)
obj[4]         site=call:bstInsert   FRAME_OWN   FREE call:bstInsert
obj[5]         site=call:bstInsert   FRAME_OWN   FREE call:bstInsert
obj[6]         site=call:bstInsert   FRAME_OWN   FREE call:bstInsert
obj[7]         site=call:bstInsert   FRAME_OWN   FREE call:bstInsert
obj[8]         site=call:bstInsert   FRAME_OWN   FREE call:bstInsert
obj[9]         site=call:bstInsert   FRAME_OWN   FREE call:bstInsert
obj[10]        site=call:bstInsert   FRAME_OWN   FREE call:bstInsert
obj[11]        site=call:bstInsert   FRAME_OWN   FREE call:bstInsert
obj[12]        site=call:bstInsert   FRAME_OWN   FREE call:bstInsert
obj[13] tree   site=call:bstInsert   FRAME_OWN   FREE tree
obj[14]        site=null_init        ESCAPED     (head 初始 nil)
obj[15] head   site=call:linkPrepend FRAME_OWN   FREE head
obj[16] deep   site=call:deepAlloc1  FRAME_OWN   FREE deep
obj[17] s1     site=call:buildStr    FRAME_OWN   FREE s1 [string]
obj[18] s2     site=call:buildStr    FRAME_OWN   FREE s2 [string]
obj[19] s3     site=call:buildStr    FRAME_OWN   FREE s3 [string]
obj[20] b1     site=call:branchPick  FRAME_OWN   FREE b1
obj[21] b2     site=call:branchPick  FRAME_OWN   FREE b2
obj[22] b3     site=call:branchPick  FRAME_OWN   FREE b3
obj[23] b4     site=call:branchPick  FRAME_OWN   FREE b4
obj[24] tmp    site=call:makeUser    FRAME_OWN   FREE tmp
obj[25] c1     site=call:branchPick  FRAME_OWN   FREE c1
obj[26] c2     site=call:branchPick  FRAME_OWN   FREE c2
obj[27]        site=null_init        ESCAPED     (bigTree 初始 nil)
obj[28] bigTree site=call:bstInsert  FRAME_OWN   FREE bigTree
obj[29] big    site=call:buildStr    FRAME_OWN   FREE big [string]
obj[4-12]      site=call:bstInsert   FRAME_OWN   FREE call:bstInsert ×9
```

### makeUser — 3 objs, 0 frees

```
obj[0] name  site=param:name  ESCAPED    (参数传递给调用者)
obj[1] u     site=param:email ESCAPED    (参数传递给调用者)
obj[2]        site=new         FRAME_OWN  (new(User))
```

### makeNode — 1 obj, 0 frees

```
obj[0] n  site=new  ESCAPED    (返回给 bstInsert)
```

### bstInsert — 2 objs, 0 frees

```
obj[0]      site=param:root     ESCAPED    (root 参数)
obj[1] root site=call:bstInsert ESCAPED    (递归调用结果)
```

### bstSum — 0 objs, 0 frees

纯遍历，无堆分配。

### linkPrepend — 2 objs, 0 frees

```
obj[0] n  site=param:head ESCAPED    (旧 head 传递)
obj[1]    site=new        FRAME_OWN  (new(Link))
```

### linkSum — 0 objs, 0 frees

纯遍历，无堆分配。

### deepAlloc1 — 2 objs, 1 frees

```
obj[0] u1 site=call:makeUser  FRAME_OWN   FREE u1
obj[1] u2 site=call:deepAlloc2 ESCAPED    (返回给调用者)
```

### deepAlloc2 — 2 objs, 1 frees

```
obj[0] u1 site=call:makeUser  FRAME_OWN   FREE u1
obj[1] u2 site=call:deepAlloc3 ESCAPED    (返回给调用者)
```

### deepAlloc3 — 0 objs, 0 frees

直接 ret makeUser(...)，无本地堆变量。

### buildStr — 2 objs, 0 frees

```
obj[0]   site=null_init      ESCAPED    (var s: string = "")
obj[1] s site=string-concat  ESCAPED    (s = s + "A" 循环)
```

### branchPick — 0 objs, 0 frees

4 个分支各自 ret makeUser(...)，无本地帧对象。

## 出口释放计划

| 函数 | 待释放 | 变量列表 |
|------|--------|----------|
| main | 14 | u1, u2, u3, tree, head, deep, s1, s2, s3, b1, b2, b3, b4, tmp, c1, c2, bigTree, big |
| deepAlloc1 | 1 | u1 |
| deepAlloc2 | 1 | u1 |
| makeNode | 0 | (返回值被调用者接管) |
| bstInsert | 0 | (递归传递) |
| linkPrepend | 0 | (返回值被调用者接管) |
