# gc_string GC 分析报告

## 文件信息
- **路径**: `test/gc_string/main.cute`
- **行数**: 70
- **函数数**: 4
- **exit**: 6 (6/6 检查通过 ✓)

## 类型定义

无自定义类型。

## 函数摘要

| 函数 | retOwned | hasHeapAllocs | 参数逃逸 | 说明 |
|------|----------|---------------|----------|------|
| `buildStr` | OWN | Y | - | 循环拼接字符串 |
| `concat3` | OWN | Y | a(1), b(1), c(1) | 三路拼接 |
| `repeatStr` | OWN | Y | s(0) | 循环重复字符串 |
| `main` | - | Y | - | 7 个局部变量 |

## LLR 分析

### main — 11 objs, 9 frees

```
obj[0] s1     site=call:buildStr    FRAME_OWN   FREE s1 [string]
obj[1]        site=call:buildStr    FRAME_OWN   FREE call:buildStr
obj[2]        site=call:buildStr    FRAME_OWN   FREE call:buildStr
obj[3] s2     site=call:buildStr    FRAME_OWN   FREE s2 [string]
obj[4] s3     site=call:concat3     FRAME_OWN   FREE s3 [string]
obj[5] s4     site=call:repeatStr   FRAME_OWN   FREE s4 [string]
obj[6] big    site=call:buildStr    FRAME_OWN   FREE big [string]
obj[7] tmp    site=call:buildStr    FRAME_OWN   FREE tmp [string]
obj[8] final  site=call:repeatStr   FRAME_OWN   FREE final [string]
obj[1]        site=call:buildStr    FRAME_OWN   (重赋值 s2)
obj[2]        site=call:buildStr    FRAME_OWN   (重赋值 s2)
```

### buildStr — 2 objs, 0 frees

```
obj[0]   site=null_init      ESCAPED    (var s: string = "")
obj[1] s site=string-concat  ESCAPED    (s = s + "A" 循环)
```

### concat3 — 3 objs, 0 frees

```
obj[0] a  site=param:a  ESCAPED
obj[1] b  site=param:b  ESCAPED
obj[2] c  site=param:c  ESCAPED
```

### repeatStr — 3 objs, 0 frees

```
obj[0] s      site=null_init      ESCAPED    (var result: string = "")
obj[1]        site=null_init      ESCAPED
obj[2] result site=string-concat  ESCAPED    (result = result + s)
```

## 出口释放计划

| 函数 | 待释放 | 变量列表 |
|------|--------|----------|
| main | 7 | s1, s2, s3, s4, big, tmp, final |
| buildStr | 0 | (返回值被接管) |
| concat3 | 0 | (返回值被接管) |
| repeatStr | 0 | (返回值被接管) |

## 测试场景

1. **循环拼接**: `buildStr(50)` 循环 50 次 `s = s + "A"`
2. **重用变量**: `s2 = buildStr(10); s2 = buildStr(20); s2 = buildStr(30)` 旧 string orphans
3. **三路拼接**: `concat3("hello", " ", "world")`
4. **嵌套调用**: `repeatStr("xy", 5)` → 10 字符
5. **大量拼接**: `buildStr(200)` 200 次循环
6. **组合**: `repeatStr(buildStr(5), 4)` → 20 字符
7. **全部通过**: 6/6 检查 ✓
