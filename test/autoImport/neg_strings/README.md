# 负例：无 import 使用 strings

`strings.len("abc")` 在未显式 `import "std:strings"` 时必须编译失败，
错误信息包含：

    not found function 'strings.len'
