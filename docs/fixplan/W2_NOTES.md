# W2 Notes —— 8 个 NASM 形状错误战役（2026-10-28）

> Agent W2。目的：`test/*` NASM-FAIL=8 → 0。全部独立根因 + 修复 + 验证记录如下。

## 战役结论总表

| 测试 | 根因 | 层 | 修复 | 复跑 |
|---|---|---|---|---|
| thread | pkg asm 引用 `std_thread_threadEntryRaw__ptr`——一个从未有编译器发射过的合成符号；函数本体 `std_thread_threadEntryRaw` 经 `var _entryFn: ptr = threadEntryRaw`（函数作值→Useful）已正常发射 | 语料缺口 (pkg/thread) | 两个 .cute 的 `lea rdx, [...]` 改直接引用已发射函数标签 | nasm 干净, exit=0 |
| structValue / m5 | `stripOuterBrackets("QWORD [rsp+0]")` 剥掉 QWORD 前缀后残留**前导空格**→首字符非 `[` 不剥括号→`copySlots` 拼出 `[ [rsp+0]+0]` 双括号 | 后端发射形状工具 | exp.go/linux_sysv.go/cdecl.go 三处同构：剥前缀后二次 TrimSpace；arch 版补本地 stripMemPrefix | structValue exit=11 (语义归 W4)；m5 exit=7 |
| rcLeak | `InstBinary` 比较分支（==,!=,<,>,<=,>=）对**内存目的**发 `movzx mem, al`——movzx 目的操作数只能是寄存器 | arch/x86_64/ops.go | 内存目的分支：`movzx RAX/EAX, al` + 同宽写回 | exit=0 |
| fullSyntaxTest | 上一修复漏 BYTE/WORD 目标宽度（`mov BYTE[..], RAX` 尺寸不符） | 同上 | 宽度分派 BYTE→al / WORD→ax / DWORD→EAX / 默认 RAX | nasm 干净, exit=139（运行段错误, 归 W4） |
| memoryTest | 语料在 x86_64 目标下写 i386 ABI：EBX/ECX/EBP 装载 u64 参数的 QWORD 操作数 + `int 0x80`，64 位下形状/语义双不成立 | 语料缺口 (test/memoryTest) | 重写为 64 位 syscall ABI（RDI/RSI/RDX/R10/R8/R9、trap 号紧贴 syscall、参数统一 u64 保证 QWORD 替换合法）；**`ret 0` 等返回语义原样保留** | nasm 干净, exit=0 |
| simple | 函数名 `abs` 与 **NASM 保留一元运算符** 撞名——`abs:` 标签与 `call abs` 都非法（最小复现：两行 asm 即触发） | 语料 (test/simple) | `fn abs`→`absValue`，调用点同步；语义不变 | nasm 干净, exit=116（=正确 372 低 8 位） |
| asmTest | 语料手写非法 NASM：`mov [mem], 100`（立即数无尺寸）与 `add [mem],[mem]`（mem,mem 非法） | 语料 (test/asmTest) | 按意图重写为等价合法形态（QWORD 尺寸 + RAX 中转） | nasm 干净, exit=0 |

## 关键细节

### stripOuterBrackets 修复（structValue/m5，覆盖面最广）
- 生成链：`linux_sysv.go:378` 以 `"QWORD [rsp+N]"`（带空格）为 Exp 目标 → `exp.go loadMultiSlot:1622`
  → `copySlots(stripOuterBrackets(result), ...)`。
- 原实现 `stripMemPrefix(TrimSpace(addr))`：TrimSpace 只在剥前缀**前**做，`"QWORD [rsp+0]"` → `" [rsp+0]"`（前导空格）
  → `[0]=='['` 判定失败 → 原样返回 → copySlots 里再套一层括号。
- 修法：`TrimSpace(stripMemPrefix(TrimSpace(addr)))`。arch 两份同型函数（linux_sysv.go / cdecl.go）原本连 QWORD 前缀都不剥
  （`QWORD[rbp-56]` 进 `[ + src + ]` 会出 `[QWORD[rbp-56]]`，iface 路径潜在睡雷），一并镜像修复。**未动 GenVarAddr/this 偏移**。

### InstBinary 比较分支（rcLeak / fullSyntaxTest）
- 进入方式：SysV 寄存器参数(sc 核心) `linux_sysv.go:378 a.Exp(arg.Value, "QWORD [rsp+N]", ...)`，表达式为比较时落到 `ops.go` 比较分支，
  且 `lo8(内存串)` 按 default 回落 `al`——setXX 其实已落对（RAX 低字节），只差 movzx 目的非法。
- 乘/除分支早有内存目的显式处理（栈中转），唯比较分支漏了——按同文件风格补齐。
- fullSyntaxTest 是同修复的深度版本：目标是 *bool*（BYTE 槽）。三次迭代覆盖：先 QWORD→全宽分派。

### NASM 保留字撞名（simple）
- NASM 表达式含一元运算符 `abs`。验证：仅 `abs` 撞（add/max/min/factorial/fibonacci 等全 ok）。
- 5 次连编 3 种 md5：编译产物存在 Go map 序非确定性（函数槽/标签顺序漂移）；abs 改名后各变体均 nasm 干净。
  ⚠ 给 W4/W5：产物非确定性是独立隐患，未列为 W2 战役范围。

### esccheck 基线核对（W2 口径）
- 聚合（107 test 目录逐目录独立进程）：`have=95 haveObj>0=17 对象=115 RC/泄漏释放=6 泄漏=0 提前释放=0 作用域=87 转移=22`；
  pkg/* 逐目录 18 有输出但对象全 0。
- 不变列逐位一致：RC=6（gc_loop=5+heap_new=1 分布保真）、泄漏=0、提前释放=0、转移=22。
- 对象 115 对基线 114 的 +1 与作用域栈 87/86 的 +1：**成对且归因 W3**——`test/comprehensive/package.json`（W3 新建）
  使 `edge_cases.cute` 首次可由 GetPackage 解析 → esccheck 多收 1 对象/1 作用域（escw2/comprehensive.out）。非 W2 编译改动所致
  （esccheck 只读 parser 状态；W2 不触 parser）。
- 注意基线分母写作 /140，主仓现 107 test 目录 + 34 pkg 目录 = 141；分母口径与当时枚举方式有关，不影响不变列对比。

## W2 修改文件（供主线程提交分批）
- `pkg/thread/thread.cute`（P4 类：语料缺口，动机见上）
- `pkg/thread/thread_x86_64.cute`（同上）
- `compile/exp/exp.go`（stripOuterBrackets）
- `compile/arch/x86_64/linux_sysv.go`（本地 stripMemPrefix + 剥前缀版 stripOuterBrackets；**与 W1 地盘无交**：不动 this 槽）
- `compile/arch/x86/cdecl.go`（镜像）
- `compile/arch/x86_64/ops.go`（InstBinary 比较分支内存目的地）
- `test/memoryTest/main.cute`（64 位 ABI 语料重写）
- `test/simple/main.cute`（abs→absValue）
- `test/asmTest/main.cute`（合法 NASM 重写）

## 哨兵（复跑全亮）
derefTest=7 · rcSimple=12 · probeC=1 · rctest=60 · gcfree=60

## 移交
- structValue exit=11、fullSyntaxTest exit=139：RUN 语义归 W4（NASM 未净时无法评估，现在可评了）。
- go build 主仓 `go build -o /tmp/opencode/bin/w2 .` 全程绿色。
- 编译器 Go 代码未加任何调试探针；沙盒 /tmp/opencode 下临存文件（escw2/、on*.asm、fail_simple.asm、t1/tw.asm）与本仓无关。
