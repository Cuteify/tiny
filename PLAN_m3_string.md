# M3 string 支持计划（重写 v2）

> 前置：M1（字段访问）、M2（list 三字段容器）已完成。
> 目标：test/string 双架构通过（x86 已 100 ✓）；x86_64 修复至 100；同步解锁 string_operations（41）、complex_test（exit=17）。
> 当前：**x86 = 100 全过；x86_64 = 139（段错误），根因指向 stringConcat 的 total 计算异常（=16，应为 11）。**

## 1. 已完成（相对 v1 计划）

| 项 | 内容 | 状态 |
|----|------|------|
| 装载 | string 常量/变量三槽装载；空串 `""` 用 label="0"（exp.go 4 处 + x64 loadContainer3/pushContainer 共 6 处修复） | ✓ 产物验证 |
| 参数 x64 | SysV.Prologue 容器参数三槽保存（RDI/RSI/RDX→[rbp+16/24/32]，RCX/R8/R9→[rbp+40/48/56]）；寄存器参数 3 组 3 槽、栈参数 3 槽 | ✓ 产物验证 |
| 参数 x86 | cdecl 容器实参：嵌套调用走 RetSlot、常量 cap=len=slen、变量三槽（含 `[ebp-x]+8` 括号内拼接修复）；容器返回隐藏参数 `lea EAX,[ebp+RetSlot]; push EAX` + `add esp,4` | ✓ x86=100 |
| 返回值 | x64 返回槽（R10 传址，[rbp-56] 暂存）；x86 隐藏参数返回槽 | ✓ |
| 拼接 | stringConcatExp：malloc + 两段 rep movsb + 双 NUL + 三槽装载；len=total（R9）已修；malloc size / cap 向上对齐（`lea [x+8]; and -8`）已修 | ✓ 逻辑自洽 |
| 基础 | 堆（brk malloc）正常；pkg/memory 全局发射正常；调用链不崩溃（139→之前 84/83） | ✓ |

## 2. 当前阻塞：x64 stringConcat total=16（应 11）

### 2.1 已确认事实（strdbg 最小复现 + gdb）
- 入口参数**全部正确**：s1={0x402048, 5, 5}（"hello"）、s2={0x40204e, 6, 6}（" world"）；rdi/rsi/rdx/rcx/r8/r9 与 main 传参一致。
- stringConcat2 内部：`pop R12; pop R13; pop R14; pop R15` 后 `mov R9,R14; add R9,R12`——asm 顺序自洽（R12=s2.len、R13=s2.ptr、R14=s1.len、R15=s1.ptr）。
- **结果**：cc={ptr=0x403010, len=16, cap=23}；clen=16；exit=69 = (5+16*100) mod 256 ✓ 与 gdb 一致。
- cap=23 = align8(16+8)-1（新公式，total=16 时）→ **total 确实 = 16 = R14+R12**，且新公式代码在生效（不是旧二进制）。

### 2.2 排除项
- 参数装载、prologue 三槽保存：已验证正确
- push/pop 顺序：asm 自洽（x86 同样自洽且 x86=100）
- malloc 破坏 R12-R15：ABI 规定 callee 保存，产物可见保存/恢复
- 对齐公式：cap/size 均与 total=16 自洽，说明 R9=16 是在 `mov R9,R14; add R9,R12` 处就已错

### 2.3 待验证假设（下一步调试）
1. **断点实测**：`break *stringConcat2+<pop R15 后偏移>`（objdump 定位），print $r12 $r14——确认 pop 后寄存器值。
2. 若 R12/R14 不是 6/5：**pop 读到的栈内容错**——检查 push 的源地址 `[rbp+16+8]`/`[rbp+40+8]` 运行时值（断点读内存）。
3. 若 R12/R14 是 6/5：**mov/add 后 R9=11**——那 push R9 后的 16 来自**第二次使用 R9 处**（pop R9 或 rep 后）——检查 `call malloc` 与 rep movsb 之间的 R9 生命周期（R9 是 caller-saved，malloc 内部可能用了 R9，且 pop R9 发生在 rep 之后——若 pop 的 total 正确=11，则装载 `[rbp-80+8]=R9` 应为 11——但实际 16，说明 pop R9 读到 16——**栈内容被破坏**？检查 `push R9` 后到 `pop R9` 之间是否有其他 push/pop 不平衡：`call malloc` 的 cdecl 清理 `add rsp,8`？x64 无。**重点复查 malloc 内部是否多 push 少 pop 或反之**（malloc 链：malloc→refill→slot_of→blk_size_of→head_of→load64/store64→brk）。
4. **x86 对照**：x86 同样用栈暂存 total（[esp+0]），若 x86 的 push 顺序/清理顺序与 x64 不对称，会暴露差异（x86 已 100，可作参照系）。
5. **test/string x64=139 段错误**：C 版（对齐修后）才出现——若 total 误算为 16，则 NUL 写在 buf+16/+17（分配 24B 内，不越界）；139 可能来自 stringRepeat 的循环堆破坏或重复 malloc 的链表损坏——修复 total 后复查。

## 3. 调试与修复步骤

1. objdump 定位 stringConcat2 内 `pop R15`/`mov R9` 的地址，断点打印 $r12/$r14/$r9（对应 2.3-1）。
2. 按 2.3 分支排查（栈内容 / malloc 生命周期 / pop R9 值）。
3. 修复后：`strdbg` 应输出 exit=69→（5+11*100=1105 → mod 256 = 49），即期望 **49**；test/string x64 恢复无崩溃并逐步逼近 100。
4. **回归对照**：x86 必须保持 100（本次改动只动 x64 分支或共用装载段，勿动 x86 路径）。
5. 全过后续：test/string 期望 92→100（两架构）；string_operations（41）、complex_test（17）；全量回归（list、list_test、struct_test、control_flow、simple 等）；CHANGES.md 更新。

## 4. 验证清单

| 测试 | 期望 | 说明 |
|------|------|------|
| strdbg（最小复现） | x64 exit=49 | alen=5 + clen=11*100，mod 256 |
| test/string x86_64 / x86 | exit=100 | 期望值随字节数语义修正 92→100 |
| test/string_operations x86_64 / x86 | exit=41 | M3 同根因 |
| test/complex_test x86_64 / x86 | exit=17 | stringOperations=31 后 total=3089 mod 256 |
| 全量回归 | 无回归 | 重点：list、list_test、struct_test、control_flow、simple |

## 5. 风险与注意

- **R9 生命周期**：x64 拼接中 R9 跨 malloc call 使用（caller-saved），两次 push/pop 暂存——任何中间 call 若破坏栈平衡都会读错 total；修复时优先保证 `push R9` 与 `pop R9` 之间无其他栈操作。
- **x86 勿动**：x86 已 100，所有修复先在 x64 分支验证，再全量回归确认 x86 不回归。
- **堆破坏**：139 段错误可能伴随堆损坏，修复 total 后需验证 malloc 链完整性（重复 malloc/free 循环）。
- **嵌套/循环拼接**：stringRepeat 是多轮 concat，任何一轮出错都会放大，先修 stringConcat 再测 stringRepeat。
- **无 GC**：拼接 malloc 产物不回收（与总计划一致，测试内可接受）。

## 6. 关键文件

- compile/exp/exp.go：`stringConcatExp`（~1032，len=total 与对齐已修；暂存 total 的 push/pop 段是当前排查重点）、loadContainerPair/isContainerLeaf/loadContainer/list 元素空串修复（~993/1179/1192/1339）
- compile/arch/x86_64/linux_sysv.go：Prologue 三槽保存（~82-102）、loadContainer3（~302）、pushContainer（~336）
- compile/arch/x86/cdecl.go：容器实参/容器返回（已完）
- pkg/memory/memory_x86_64.cute：malloc/refill 链（R9 生命周期排查点）
- /tmp/opencode/strdbg/main.cute：最小复现（stringLength + stringConcat + stringRepeat 编码返回值）
- test/string/main.cute + test_run.sh：验收入口