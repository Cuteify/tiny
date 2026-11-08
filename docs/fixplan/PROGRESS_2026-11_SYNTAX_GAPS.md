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

- [x] checkBuiltin 转换分支
  - `parser/call.go` 新增 `CallBlock.ConvertType`；`convertTypeNames` 覆盖 int/uint/i8–i64/u8–u64/别名/byte/f32/f64
  - `checkConvertBuiltin`：单实参校验、源类型限定整数/浮点/byte、x86 显式拒绝浮点与 64 位转换
- [x] codegen 转换
  - `compile/exp/exp.go` 的 `builtinCall` 按 `ConvertType` 分派 `builtinConvert`
  - float→int `cvttsd2si`/`cvttss2si`；int→float `cvtsi2sd`/`cvtsi2ss`；f32↔f64 `cvtss2sd`/`cvtsd2ss`
  - int 窄化截断低位；有符号 `movsx`/`movsxd`，无符号 `movzx`/`mov eax,eax`
- [x] unsafe.cast 回归
  - 保持 codegen 透传（位级重解释），`unsafe.cast[byte]`、`unsafe.cast[ptr]`、`unsafe.cast[*int]` 均通过
- [x] 测试与提交
  - `test/convert`：整数截断/扩展、变量/链式转换、`unsafe.cast` 三种形态；x86_64 与 x86 均 exit=42
  - `test/convertFloat`：浮点↔整数、f32↔f64 往返、`f64(7)` 位模式高低 32 位校验；x86_64 exit=42
  - 负例：`neg32_float` 报 `floating-point conversion f64 -> int is not supported on 32-bit target`；`neg32_i64` 报 `64-bit conversion int -> i64 is not supported on 32-bit target`
  - 修复 `compile/exp/collect.go`：调用实参递归进入 `expInfo`，避免 `u32(bits >> 32)` 这类复合实参在 `builtinConvert` 里被静默丢弃
  - 回归与基线一致：operatorOverload 42、overload 42、controlFlow 39、complexTest 17、for_range_test 139、gcRetFree 3/0、fullSyntaxTest 1、structValue 11、structMethod 45、enum 42、iface_generic 0、mp_map 74

## P4 自动导入收窄

- [x] FixPath 收窄
  - `parser/name.go`：移除 `IntrinsicPkgs` 裸名回退，只查 `pkg.Imports` 与包名自引用
  - `pkg.Imports == nil` 时仍允许自引用（合并树上的包名带路径前缀）
- [x] 最终 Check 报错
  - `parser/call.go`：`FinalCheck` 下未解析的路径调用报 `not found function '<name>'`
  - 白名单 `pathBuiltinCalls`：`unsafe.cast` / `memory.new` / `memory.sizeof` 由 codegen 直接分派
- [x] 正负例测试
  - `test/autoImport`：builtin 无 import 可用、string `==` intrinsic 可用；x86_64/x86 exit=42
  - `test/autoImport/pos_strings`、`pos_slices`：显式 import 后命名空间可用；x86_64/x86 exit=42
  - `test/autoImport/neg_strings`：报 `not found function 'strings.len'`
  - `test/autoImport/neg_slices`：报 `not found function 'slices.make'`
- [x] 暴露的沉默失败修复
  - `test/sliceTest/main.cute` 补 `import "std:testing"`
  - `test/echo`、`test/fsTest`、`test/stringsTest` 补 `import "std:memory"`
  - `test/console_adv` 改调用真实 API `console.moveCursor`（原 `setCursorPos` 不存在）
  - `test/rcLeak` 的 `leaks.toInt()` 改为 P3 显式转换 `int(leaks)`（原方法不存在）
  - `test/intrinsic_auto` 按新语义改写：命名空间显式 import，intrinsic `==/!=` 不依赖 import
  - `parser/exp_check.go`：`*[]T` 索引按 list 归类，与 codegen `indexAccess/indexSet` 一致
- [x] 全量 `-S` 扫描
  - 只剩基线既有失败：`buildKeyword` panic、`fnptr_test` not found `f`、`iface_dispatch` 类型错误、`stringUtils` `strings.join` 无匹配重载
- [x] 回归与提交
  - P2/P3 测试与核心回归退出码和基线一致；`test/slice_test` x86_64 exit=0（x86 汇编失败为基线既有）

## P5 内建表符号化

- [x] string `*` 表项
  - `parser/intrinsic.go`：新增 `{Kind:"string", Op:"*", Pkg:"std:strings", Fn:"repeatN", Form:IntrinsicCall, Phase:1}`
  - 新增 `lowerIntrinsicCall` 公共 helper；`tryIntrinsicStringEq` 复用之
  - `tryIntrinsicStringMul`：`string * int` 运行期 lowering 到 `strings.repeatN`
  - `parser/exp_check.go` 的 `checkMul`：常量仍本地折叠；运行期 lowering 失败时显式报 `operator * not defined for type string`，不再静默生成空结果
- [x] Native 例外注释
  - `intrinsicTable`：string `+`（GC 来源标记）、len/cap/索引、map len（nil map）、list len/cap/索引（左值/地址）均在表项旁注明保留原因
  - `docs/stdplan/TYPE_INTRINSIC.md`：同步 `*` 表项；修正 P4 后的自动导入说明（预加载不提供用户命名空间回退）
- [x] 验证
  - 临时用例：`s * n`（运行期）、`s * 0`、`"xy" * 2`（常量折叠）x86_64 编译运行 exit=42
  - `CUTE_NO_INTRINSIC=1` 时运行期重复显式报 `operator * not defined for type string`
  - 回归与基线一致：intrinsic_string 42、intrinsic_auto 42、autoImport 42、operatorOverload 42、overload 42、controlFlow 39、convert 42、sliceTest 0、mp_map 74、structValue 11、string 100、strings 60、stringOperations 50、stringsUtils 62、stringUtils 编译失败（既有 `strings.join` 无匹配重载）
- [x] 提交：`实现: string 乘法内建表项`

## P6 build 指令

- [x] os/arch/bits pending
  - `parser/build.go`：`Build.Bits`；`bits(32/64)` 按 `TargetPointerSize*8` 判定；`os/arch/bits` 在根作用域只记 `Parser.PendingBuilds`，由下一个 func/type/var 声明消费（import 不打断，非声明 token 清空）
  - `parser/parser.go`：`PendingBuilds`、`takePendingBuilds`、`buildsIgnored`、`pendingDeclIgnored`、`addDeclNode`
  - `parser/func.go`：声明点消费并挂 `FuncBlock.BuildFlags`（在 `registerOverload` 前）；被过滤函数节点设 `BuildIgnored`
  - `parser/type.go`/`var.go`/`enum.go`：被过滤声明不注册全局表；enum 成员同步忽略
  - `parser/node.go`：`Node.BuildIgnored`；`Check`/eager Checker 跳过；`parser/finder.go` 的 `Find`/`findGlobalVar` 跳过
  - `package/package.go`：根包移除文件级 `preFilterBuild`（非根 std/子包保留）；无源文件显式报错
  - `compile/compiler.go`：`compileChildren`/`generateGlobalSection`/`hasMainFunction` 跳过 `BuildIgnored`；`collectExports`/`collectLinkSyms`/`markLinkProviders` 跳过 `Ignore`
- [x] export
  - 函数体内 `build export("alias")` → `FuncBlock.BuildFlags`；`collectExports` 预扫描输出 `global`，`compileRootTail` 生成 `alias: jmp <mangled>`
- [x] ext/extret
  - `parser/build.go`：`ext/extret` 改为 token 解析符号名（旧实现截到行尾，call 目标带 `("name")`）
  - v1 边界：最多 6 个整数/指针参数；`extret` 要求单整数/指针返回；浮点/容器/结构体显式报错
  - `compile/build.go`：SysV 按声明宽度装载（8B 整槽；4B 有符号 `movsxd`/无符号 `mov r32`；2/1B `movsx`/`movzx`）
  - cdecl 使用 `arg.Offset`，8 字节参数先高后低压栈；ESP 保存改用 callee-saved EBX（EDX 会被外部函数破坏）
  - `extret` 调用后 `jmp func_end_<mangled>`
- [x] P4 收尾：`pkg/fs`、`pkg/sort` 补 `import "std:memory"`（收窄自动导入后依赖包不得再依赖根包导入解析）
- [x] 测试
  - `test/buildDirective`：bits(64)/bits(32) 同名分支、arch(x86_64)/arch(x86)、bits(32,64)、`ext("labs")`、`extret("labs")`、`export("cute_exported")`；x86_64/x86 exit=0
  - `test/buildKeyword`：Linux 下跳过 windowsFunc、调用 linuxFunc/multiOSFunc；x86_64/x86 exit=0
  - `nm` 验证 `cute_exported` 为全局符号并跳转到 `exported`（x86_64/x86）
  - `test/derefTest` x86_64/x86 exit=7（修复被过滤函数的函数体仍被 Check 的问题）
  - 全量 `-S` 扫描与基线一致：x86_64 仅 `fnptr_test`/`iface_dispatch`/`stringUtils`；x86 额外既有失败 `convertFloat`、`sortStrOnly`、`sortTest`
- [x] 提交：`实现: build 指令`

## P7 string 重复

- [x] lowering
  - `parser/intrinsic.go`：`string * int` → `std:strings.repeatN`（P5 已落表）
  - `parser/exp_check.go`：运行期 `checkMul` 走 `tryIntrinsicStringMul`，改写为普通调用；`repeatN` 内 `count <= 0` 返回 `""`
- [x] 负数折叠
  - 常量 `n <= 0` 直接折叠为空串，不再调用 `strings.Repeat`（负数会编译期 panic）
- [x] 测试与提交
  - `test/syntaxGaps/string_mul.cute`：`"ab"*3`、`"ab"*0`、`"ab"*-1`；运行期变量次数、0、负数
  - `test/syntaxGaps` x86_64/x86 exit=42
  - 回归：`strings` 60、`stringOperations` 50、`intrinsic_string` 42、`convert` 42；`stringUtils` 仍为基线 `strings.join` 无匹配重载

## P8 控制流

- [ ] continue/while
- [ ] 多级跳转
- [ ] fallthrough
- [ ] 测试与提交

## P9 文档

- [ ] LANGUAGE.md
- [ ] TYPE_INTRINSIC.md
- [ ] 总验收与提交
