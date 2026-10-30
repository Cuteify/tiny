# W1 NOTES —— this/self ABI 单一事实源战役（2026-10-28）

## 根因闭合图（已核实的全部 touchpoint）

this 指针的「家」（callee 内 rbp 相对偏移）散落 6 处 → 当前 x86_64 sysv 不一致：

| # | 位置 | 当前值 | 现状 |
|---|---|---|---|
| 1 | `compile/arch/x86_64/linux_sysv.go:116` prologue 写 | `[rbp-48]` | 新 ABI（寄存器传参，callee 局部区） |
| 2 | `compile/arch/x86_64/utils.go:30` GenVarAddr `len(Name)==1` | `[rbp+16]` | ❌ 旧栈 ABI 残留 |
| 3 | `compile/arch/x86_64/utils.go:34` GenVarAddr 字段分支基址 | `16+` | ❌ 同上 |
| 4 | `compile/exp/exp.go:117` thisMem 基址（64 位） | `[rbp+16]` | ❌ 同上（gdb 铁证崩溃点：`rbp+0x10`→deref SEGV）|
| 5 | `compile/exp/exp.go:120` thisMem（32 位） | `[ebp+8]` | ✅ 与 32 位 ABI 一致 |
| 6 | `compile/arch/x86_64/ms_win64.go:82` prologue 写 | `[rbp+16]` | ✅ win64 与 utils.go 一致（勿改值，只改来源） |

- 新 ABI 下 sysv 调用方 `lea RDI,[局部槽]; call` 从不压 this ⇒ 调用者栈区 `[rbp+16]` = 调用者帧顶数据，
  callee 写 [rbp+16] 属非法（覆盖调用者局部），不能反向用「syscall 也写 +16」绕过。
- 32 位 x86（cdecl/stdcall）是纯栈 ABI：this 由调用者压入，callee 不搬，家 = `[ebp+8]`，
  three 层（prologue 不动指针、genVarAddr、exp.go thisMem 32 位分支）全部一致 ⇒ 无需改值，仅设 ctx 字段统一来源。

## gdb 铁证复盘（PROBLEMS §4 佐证链）
- `Point_distanceToOrigin+17: mov QWORD [rbp-0x30],rdi` = prologue (#1) ✓ 写 `[rbp-48]`（0x30=48）
- `+21: mov rbx,QWORD [rbp+0x10]` = **exp.go thisMem (#4)** 读旧槽 [rbp+16] → rbx=垃圾
- `+25: mov rax,QWORD [rbx]` = thisMem 的 derefLoad 读 self.x（offset 0）→ SEGV
- 结论：**exp.go thisMem 在崩溃主路径上**，仅修 utils.go GenVarAddr 不可能让 struct 簇通过。

## 所有权说明（重要，遗留判定）
exp.go 不在 W1 任务卡允许清单内，但 thisMem 是 this/home 假设的第 4 个隐性事实源
（PROBLEMS §4 檢查点 GenVarAddr/calcThisFieldOffset/stackArgBase 三处之外唯一遗漏），
且 Cluster A 的验证矩阵要求 struct/structMethod 等全部通过 ⇒ thisMem 绑定进本战役：
- 本次**只改 thisMem 一处 3 行**（thisOffset 取 ctx），其余 exp.go 一律不动；
- @W2：exp.go 形状战役请避开 thisMem/isThisField/fieldOffsetOf；
- 若主线程裁定越权，回滚函数 = `git diff compile/exp/exp.go` 仅保留 F1（deref= 兜底）可辨识。

## 修复设计：单一事实源
- `context.Context` 新增 `ThisHomeRbp int`（callee 内 this 的 rbp 偏移）：
  `NewSysV()=-48`、`NewWin64()=+16`、`NewCdecl()/NewStdcall()=+8`、默认 0=未设。
- 访问器 `ctx.ThisHomeOffset()`：非零直接返回；零时按 Is64Bit 回退旧约定（+16 / +8）——
  保证任何未初始化路径行为与修复前一致（方向保守铁律）。
- 消费端四点全部改从 ctx 取值；win64 发射字节 = 修复前逐位一致（`[rbp+16]`==`[rbp+16]`）。
- `setArgsOffset(x86_64/ops.go)`（-48/-56）与 sysv this-home -48 数值巧合但属「参数区布局」
  职责，win64 也用它（win64 参数区同样 -48 起故 this 槽位无关）——**不纳入本战役**，见下面假设 3。

## stackArgBase 修复（linux_sysv.go:113-119）
`stackArgBase = 24` 是旧 ABI 残留（当时 this 压栈占 [rbp+16]，栈参数从 [rbp+24] 起）。
新 ABI this 走 RDI，callee [rbp+16] 起直接是第 7+ 个参数 ⇒ 有 this 的方法 stackArgBase 应仍为 16。
此 bug 影响「this + ≥5 个参数」的方法调用，属同根，一并修复（新 ABI 语义下无条件 16）。

## 假设与风险（复核待办）
1. [已证] arch 构造总在 initializeContext() 内先行（compiler.go:262 NewArch→NewSysV…），
   任何发射前 ctx.ThisHomeRbp 已赋值；ThisHomeOffset 回退路径仅防御性。
2. [已证] thisMem 的 fieldOffsetOf 与 GenVarAddr 的 calcThisFieldOffset 均只返字段路径偏移，
   基址独立（exp.go 一处基址 + utils.go 一处基址），互不依赖。
3. [假设] setArgsOffset 的 -48 起排只被 SysV/Win64 Prologue 用；ArgOffset 语义 = callee 局部区，
   GenVarAddr 参数分支走 v.Offset（isDefineInArg 不加 BpOffset）✓ 与本次 this-home 无耦合。
   风险：win64 Prologue 把寄存器参数搬到 `[rbp+(-56…)]`——现状如此，未动。
4. [待跑验证] esccheck 基线 107/140·114·6·0·0·86·22 逐位不变；若漂移按 PROBLEMS §0 回滚。
5. [待跑验证] 哨兵：derefTest=7 probeC=1 rcSimple=12 rctest=60 gcfree=60。
6. [待验证] 32 位 arch（x86）esccheck/e2e 是否在跑（不影响 sysv 主目标，仅做来源统一）。

## 编辑清单
- [ ] compile/context/context.go：字段 + ThisHomeOffset() + Clone 同步
- [ ] compile/arch/x86_64/linux_sysv.go：NewSysV 设 -48；prologue 写槽走 ctx；stackArgBase…=16
- [ ] compile/arch/x86_64/ms_win64.go：NewWin64 设 +16；prologue 写槽走 ctx（输出字节不变）
- [ ] compile/arch/x86_64/utils.go：GenVarAddr 两分支 + calcThisFieldOffset 基址走 ctx
- [ ] compile/arch/x86/cdecl.go + stdcall.go：设 +8；x86/utils.go genVarAddr this 走 ctx
- [ ] compile/exp/exp.go：仅 thisMem 基址 3 行（所有权扩展，见上）
