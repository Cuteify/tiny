# 负例：32 位目标不支持浮点转换

`int(3.9)` 在 `CUTE_ARCH=x86` 下应编译失败，错误信息包含：

    floating-point conversion f64 -> int is not supported on 32-bit target

x86_64 下该表达式正常。
