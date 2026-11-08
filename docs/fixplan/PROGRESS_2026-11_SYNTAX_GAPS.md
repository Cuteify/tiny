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

- [ ] get/set/slice lowering
- [ ] 一元与 eq/ne
- [ ] 复合索引赋值
- [ ] 测试与提交

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
