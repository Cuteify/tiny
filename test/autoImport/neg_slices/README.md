# 负例：无 import 使用 slices

`slices.make[int](4)` 在未显式 `import "std:slices"` 时必须编译失败，
错误信息包含：

    not found function 'slices.make'
