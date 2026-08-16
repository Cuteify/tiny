# M2 收尾修复计划

> 更新：2026-08-16。目标：test/list、test/list_test 双架构通过（已完成），complex_test 等遗留测试收尾（除 string 外全部子函数已修复，string 阻塞在 M3）。

## 当前状态

### 已完成（list 核心）
| 项目 | 结果 |
|------|------|
| test/list x86_64 | exit=33（期望 33）通过 |
| test/list x86 | exit=33 通过 |
| test/list_test x86_64 | exit=0 通过 |
| test/list_test x86 | exit=0 通过 |
| 全量回归 | 无回归（string 为 M3 范畴遗留） |

### 本轮已修复的 bug（M2）
1. 嵌套调用 parser bug（parser/call.go + parser/exp.go）：`,`/`)` 分支游标推进。nesttest 验证 exit=0。
2. ZeroVar：无初值变量（`var empty: []int`）三槽清零。compiler.go 删 Value==nil 提前返回；x86_64Ops.VarDecl（大写，ops.go:208）Value==nil 走 ZeroVar。
3. builtinCall 分派移入 leaf()（exp.go:229）：len(empty) 的 exp Separator=="" 必须走 leaf，否则生成 call 0（SIGILL）。
4. ParseName 不再吞表达式索引（parser/name.go）：`single[0]` 的 `[` 交给 ParseExp，索引进 Expression.Index。
5. handleIndex `:` 分支重复消费 token（parser/exp.go）：只更新 startCursor 变量未推进 Lexer.Cursor，循环重读 `:`，导致切片 Index[1] 丢失、Index[2] 误放 hi 值。修复：SetCursor(token.EndCursor)。
6. storeVal 无方括号 dst 自动补 `[]`（compile/exp/exp.go:969）。
7. x86 硬编码 RAX 改 ReturnReg()（listLiteral/makeList 两处）。
8. sliceExp 寄存器冲突（compile/exp/exp.go:1283）：capReg 用 allocRegAvoid 避免与 ptrReg 冲突。
9. collectRec 不递归 Index 子表达式（compile/exp/collect.go）：`[]` 节点 Index 里的表达式无 ExpInfo，allocRegAvoid 崩溃（complex_test SIGSEGV）。修复：collectRec 递归 Index[0..2]。
10. InstBinary 乘法内存目标（x86_64/ops.go:161、x86/ops.go:150）：nasm 不支持 `imul mem, reg`，经栈中转（push src → mov RAX/EAX, dst → imul reg, [rsp] → mov dst, reg → add rsp）。
11. 测试目录 package.json 补 memory import（test/list、test/list_test）。
12. 移位指令（x86_64/ops.go、x86/ops.go `<<`/`>>`）：src 非立即数且非 CL 时栈中转（push src → mov cl, byte [rsp]/[esp] → shl/sar dst, cl → add rsp）。立即数判断用新增 utils.IsNumber（支持负数）。
13. derefLoad / indexAccessGeneric 的 `result == "push"` 特判（compile/exp/exp.go）：32 位栈传参时生成 `push prefix [src]`（BYTE/WORD 先 movzx 中转）；indexAccessGeneric 的 elemSize > 参数槽且 result=="push" 时按高地址槽优先逆序多槽 push。
14. foldArith `case "^"`（parser/exp_check.go）：原用 math.Pow（幂）与编译层 xor 矛盾，改 `float64(int(left) ^ int(right))`，删 math import。
15. ParseExp 括号退出后优先级 bug（parser/exp.go:278）：`A | (x&y) ^ C` 被解析成 `(A|(x&y))^C`（complexExpression 返回 2 而非 30）。根因：`)` 后 `!(justExitBracket && isRoot)` 一刀切禁止高优先级运算符结合右操作数（本意只对括号内根场景保持左结合）。修复：新增 bracketChild 标志（`)` 时若 current.Father != nil 回溯并置 true），条件改 `!(justExitBracket && !bracketChild)`。验证：complexExpression 2 → 30，multiCondition=2、nestedLoops=210 不变。

### 修复中（当前）
- complex_test 仅剩 stringOperations：gdb 实测其返回值 12632304 垃圾（期望 31），根因是 M3 的 string 参数只传 ptr 槽（callee 读 len 槽得垃圾）。string 拼接 `s1 + " " + s2`、`repeatString` 均涉此。不修 string 参数三槽传递，complex_test 无法到 exit=17。
- complex_test 现状：x86_64 exit=226、x86 exit=248。子函数 gdb 实测：listOperations=224 ✓、structOperations=39 ✓、matrixOperations=17 ✓、recursiveTests=1199 ✓、bitwiseTests=1337 ✓、expressionTests=242 ✓（complexExpression=30、multiCondition=2、nestedLoops=210）、stringOperations=12632304 ✗（M3）。
- complex_test 期望：224+31+39+17+1199+1337+242=3089，exit=17（mod 256）。

### 遗留（非回归，后续里程碑）
| 测试 | 基线 | 当前 | 期望 | 归属 |
|------|------|------|------|------|
| string | SIGILL(132) | 0 / 122 | 92 | M3（string 参数只传 ptr 槽的单槽问题） |
| string_operations | SIGILL(132) | 1 / 1 | 41 | M3 |
| arithmetic_test | 编译失败 | 编译失败 | - | 基线失败 |
| as_test / build_test / "test copy" | 空目录 | 空目录 | - | 基线失败 |
| asm_test / bitwise / scope_test | nasm 失败 | nasm 失败 | - | 基线失败 |
| comprehensive / multi_package_test / runtime* | 无 main.cute | 无 main.cute | - | 基线失败 |
| frontend_test / full_syntax_test / simple_method / struct_method | 编译失败 | 编译失败 | - | 基线失败 |
| memory_test | x86_64 nasm 失败 | 同 | x86=0 | 基线失败 |

## 下一步
1. （已完成）移位指令修复、memory import、derefLoad push 特判、`^` 折叠、bracketChild 优先级修复。
2. 清理调试代码：已清 parser/return.go 的 RETEXPNIL/RETEXP 打印、compile/exp/exp.go 的 fmt import（已确认无残留）。
3. 全量回归：list/list_test/struct_test/control_flow/bitwise/deref_test/edge_values/fib30/function_calls/link_test/mem_suite/operator_precedence/recursion/scope_test/simple/simple_var/struct/fs_test 双架构一致；complex_expressions、memory_test、frontend_test、simple_method、struct_method 经 git stash 对照基线 4a3dc25 确认同为基线失败，非本次回归。
4. 进入 M3：修 string 参数三槽传递（string 拼接、repeatString 等），同步解锁 string=92、string_operations=41、complex_test exit=17。

## 关键文件
- parser/exp.go：handleIndex（427+）、ParseExp 迭代（172+）、getExp
- parser/name.go：ParseName 的 `[` 分支（334）
- compile/exp/exp.go：generate/leaf/builtinCall、indexAccess、sliceExp、listLiteral、makeList
- compile/exp/collect.go：collectRec 的 Index 递归
- compile/arch/x86_64/ops.go、compile/arch/x86/ops.go：InstBinary
- test/list、test/list_test：package.json 已加 memory import
- PLAN_string_list_heap_struct.md：M2/M3/M4/M5 总计划（untracked，勿删）