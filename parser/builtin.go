package parser

// BuiltinFuncs 内置包函数注册表：函数简单名 → 函数定义块。
// 由 packageSys 在加载标记 "builtin": true 的包时填充，
// 使这些函数可无命名空间直接调用（print(...) 而非 builtin.print(...)）。
// 调用解析兜底时直接设置 c.Func，首趟即完成检查与代码生成定位。
// 注意：len/cap/copy/new 为编译器内建（checkBuiltin 类型分派），不经过本表。
var BuiltinFuncs = map[string]*FuncBlock{}

// LinkProviders build link 符号提供者注册表：链接名 → 函数定义块。
// 由 packageSys 在加载包时填充（扫描 FuncBlock.BuildFlags），
// 使编译器内建 len/cap 走 link 路径时能提前标记提供者 Useful，
// 避免提供者因无人显式调用而被死代码消除（符号未定义）。
var LinkProviders = map[string]*FuncBlock{}
