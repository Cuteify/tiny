# 负例：32 位目标不支持 64 位标量转换

`int(i64(3))` 在 `CUTE_ARCH=x86` 下应编译失败，错误信息包含：

    64-bit conversion int -> i64 is not supported on 32-bit target

x86_64 下该表达式正常。
