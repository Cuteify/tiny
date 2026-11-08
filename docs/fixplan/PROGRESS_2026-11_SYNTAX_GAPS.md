# 语法缺口计划执行进度（2026-11）

> 配套：`PLAN_2026-11_SYNTAX_GAPS.md`。
> 规则：每完成一个可验证步骤立即追加一行；阶段完成时提交并更新本文件。

## 基线

- [x] 计划落盘并提交：`49af8dc 计划: 新增语法缺口实施计划`
- [x] 构建基线编译器
- [x] 记录既有回归目录退出码（x86_64 / x86）
  - overload: 42 / 42
  - overload_types: 通过（无 exit 行，编译运行正常）
  - controlFlow: 39 / 39
  - buildKeyword: 编译失败（基线 panic）
  - complexTest: 17 / 17
  - for_range_test: 139 / 139（基线段错误）
  - stringUtils: 编译失败（基线 `strings.join` 无匹配重载）
  - gcRetFree: 3 / 0

## P0 基线与测试设施

- [x] 统一 `TargetArch()`：`type.TargetArch()`，五处独立 `CUTE_ARCH` 读取已接入
- [x] 新增测试目录：`test/syntaxGaps`（其余 `test/operatorOverload`、`test/buildDirective`、`test/controlFlow2` 随阶段创建）

## P1 for post

- [x] exprStop 机制
- [x] parseIncrement / ParseVar 接入
- [x] 测试与提交：`test/syntaxGaps` x86_64/x86 均 exit=42

## P2 运算符重载 lowering

- [x] get/set/slice lowering
  - `checkIndex`：自定义类型 `v[i]` → `v.get(i)`；`v[a:b:c]` → `v.slice(a,b,c)`，缺省边界 `0/-1/1`
  - `checkIndexAssign`：自定义 `v[i] = x` → `v.set(i,x)`；切片赋值显式报错
  - 接收者 v1 限定 `VarBlock`；非左值报 `operator receiver of type <T> must be an lvalue`
- [x] 一元与 eq/ne
  - `checkOverload` 支持一元（Right 为接收者）与二元 lowering
  - `checkEq` 同类型自定义类型优先 `eq/ne`，无方法回退原生比较
  - `checkUnary` 的 `~` 扩展到所有整数类型（含 `uint`/`byte`），保留操作数类型
- [x] 复合索引赋值
  - `v[i] op= x` → `v.set(i, v.get(i) op x)`
  - `checkOp` 对赋值 LHS 索引跳过递归 Check，避免 `checkIndex` 提前 lower 成 get
  - 内建 list/string/array/map 保持原 `[]=` 形状
- [x] 测试与提交
  - `test/operatorOverload`：get/set/复合赋值/slice 显式与缺省边界/eq/ne/一元 `- ! ~`/二元 `+`；x86_64 与 x86 均 exit=42
  - `test/operatorOverload/neg_nonlvalue`：负例编译失败，错误含 `operator receiver of type Vec must be an lvalue`
  - 回归与基线一致：overload 42、overload_types 通过、controlFlow 39、complexTest 17、for_range_test 139、stringUtils 编译失败、gcRetFree 3/0、fullSyntaxTest 1、structValue 11、structMethod 45、enum 42、iface_generic 0、mp_map 74；comprehensive 为既有不稳定测试

## P3 数值转换

- [ ] checkBuiltin 转换分支
- [ ] codegen 转换
- [ ] unsafe.cast 回归
- [ ] 测试与提交

## P4 自动导入收窄

- [ ] FixPath 收窄
- [ ] 自引用回退
- [ ] 正负例测试
- [ ] 提交

## P5 内建表符号化

- [ ] string `*` 表项
- [ ] Native 例外注释
- [ ] 提交

## P6 build 指令

- [ ] os/arch/bits pending
- [ ] export
- [ ] ext/extret
- [ ] 测试与提交

## P7 string 重复

- [ ] lowering
- [ ] 负数折叠
- [ ] 测试与提交

## P8 控制流

- [ ] continue/while
- [ ] 多级跳转
- [ ] fallthrough
- [ ] 测试与提交

## P9 文档

- [ ] LANGUAGE.md
- [ ] TYPE_INTRINSIC.md
- [ ] 总验收与提交
