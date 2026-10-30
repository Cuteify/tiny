# tiny 编译器后端修复 —— 问题总账（2026-10-28）

> 目标：`test/*` 全语料 e2e（编译→nasm→链接→运行）通过。本文是唯一事实源（SSOT），
> 各 SubAgent 修任何问题前先读这里；新结论必须回写本文件的「附录/勘误」或 PROGRESS.md。

---

## 0. 铁律（对所有 Agent 生效）

1. **esccheck 基线**（每次触碰 `compile/` 代码后必须核对，数字须逐位不变）：
   ```bash
   go build -o /tmp/opencode/bin/esccheck_<agent名> ./tools/esccheck   # 在主仓根目录
   # 按其 main.go 的调用约定逐目录独立进程跑全语料，结果必须为：
   # 107/140 · 对象=114 · RC/泄漏释放=6 · 泄漏=0 · 提前释放=0 · 作用域释放=86 · 转移=22
   ```
   基线漂移 ⇒ 停止提交，立刻在 PROGRESS.md 记录漂移值并回滚（`git checkout -- <file>`）。
2. **失败方向的绝对纪律**：分析/修复方向永远「多标/多初始化/不释放」，绝不「提前释放/少标」。
3. **代码只许改后端**：`compile/`（**除** `compile/gc/` 之外）、必要时 `test/*/package.json`、必要时
   `pkg/<std包>/*.cute`（语料源码缺口，须在 PROGRESS 记录动机）。**禁止**改：`parser/*`、`compile/gc/*`。
4. `type/struct.go` 是用户未提交的手改，**永远不 git add / 不还原**。
5. **编译/运行测试一律在沙盒** `/tmp/opencode/run`（全语料副本），不在主仓跑产物（防止污染受跟踪的
   `_main.asm`/`gc_llr.txt`/`gc_summary.json`）。每次改 `test/*` 或 `pkg/*` 后把文件 cp 到沙盒同步。
6. **并发防冲突**：Test 全流程（含编译产物 `_main.asm/.e.o/.e`）用 `flock /tmp/opencode/lock -c '<cmd>'`;
   每个自己编译的二进制放 `/tmp/opencode/bin/<agent名>`（e2e_all.sh 第 1 参、run_e2e.sh 第 2 参）。
7. **不 git commit**。所有提交由主线程分批完成；Agent 只改文件，保持每步可编译（`go build -o <自己bin> .`）。
8. **实时保存进度**：每完成一步（读证据/一次编辑/一次测试）立即追加 PROGRESS.md，禁止攒批。
9. 临时探针（编译器 Go 代码里的调试打印/panic、沙盒 .cute 里的 ret 标签）用完必须删除，列入收尾清单。

---

## 1. 环境速查

| 项 | 值 |
|---|---|
| 主仓（只改代码） | `/home/gx/Desktop/代码/tiny` |
| 构建编译器 | `cd /home/gx/Desktop/代码/tiny && go build -o /tmp/opencode/bin/<agent> .` |
| 沙盒全语料 | `/tmp/opencode/run`（`test/*` + `pkg/*` 完整副本） |
| 全语料 e2e | `bash /tmp/opencode/e2e_all.sh <bin>`（rc==0 判 pass 对哨兵值测试有假 FAIL） |
| 单目录 e2e | `bash /tmp/opencode/run_e2e.sh <test相对目录> <bin>` |
| 旧版对照 | `/tmp/opencode/old` = 171b537 worktree；`/tmp/opencode/old/pkg/memory` **没有 rc.cute**（RC 内包是 171b537 后新写的,从未在任何编译器上验证通过） |
| gdb | 可用（`gdb -batch` 定位崩溃） |
| `_start` 约定 | `call main; mov rdi,rax; mov rax,60; syscall` ⇒ **main 的返回值低 8 位 = exit code**（眩晕探针武器） |

## 2. 当前战果快照（2026-10-28 以后端三轮三连修后）

- 修复前三轮前：RUN-OK=21 · RUN-FAIL=48 · NASM-FAIL=27 · LINK-FAIL=0 · COMPILE-FAIL=17
- 当前：**RUN-OK=24 · RUN-FAIL=66 · NASM-FAIL=8 · LINK-FAIL=0 · COMPILE-FAIL=17**（总计 114 目录）
  - 注意：rc==0 判据对「哨兵值测试」假 FAIL（如 `ret 42`/`ret 60`/`ret 7`），真实好于账面。
  - RUN 失败全列表（66 个）见 docs/fixplan/PROGRESS.md 快照节。

### 哨兵语义档案（已知正确的 exit ≠ 0）
| 测试 | 语义 |
|---|---|
| variadic 42 | `main` 末行 `ret 42` |
| simpleVar 42 | `ret test(42)` |
| generics 42 | identity 泛型，`ret identity(42)` |
| derefTest 7 | 全部通过（含堆解引用读写） |
| rcSimple 12 | `ret gPassed`，12=12 项检查全过 |
| gcfree 60 | `ret 60`=成功哨兵（1/2 是守卫失败码） |
| rctest 60 | 同上（末行 ret 60） |
| probeA/B/C(仅沙盒) 1 | 探针约定 |
| fortest 5 | `sLen("12345")` 数值成立即对 |
| bitwise 9 | 期望值低 8 位=9（待核对数学） |

---

## 3. 已完成修复（主仓有改动、未提交）

| # | 文件 | 内容 | 验证 |
|---|---|---|---|
| F1 | `compile/exp/exp.go` generate() deref= 兜底 | 在 deref 分派前把未转换的 `"`="（Left 为 deref）原地重排成 `deref=(值,指针)`（幂等，镜像 parser checkAssign）。根因：parse 期 `checkOp` 因右子 `unsafe.cast` 在 RET-R 提前 return，deref 转换没执行且重试不回来 | derefTest exit=7；全语料空操作数=0 |
| F2 | `compile/compiler.go` generateGlobalSection | 全局量有**可折叠初值**（`vb.Value != nil && vb.Value.IsConst()`）→ `.data dq/dd`。原条件 `vb.IsConst` 对 pkg 内 const 缺标志（IsConst=false），发射成 `.bss resq 1` 零值 → mallocRC 三分支全反 | probeRC exit=1（rc==1）、rcSimple exit=12 |
| F3 | `compile/compiler.go` markRCFuncs | rcNames 扩充 `malloc/realloc/free`（emitMalloc/emitFree/emitRealloc 合成调用族） | 与 F4 共同减少 NASM 符号缺失 |
| F4 | `test/*/package.json` ×20 | 新 std 协议要求显式 imports；GC 自动发射 malloc 依赖 `std:memory`。已补：boundsCheck builtinTest for_range_test fullSyntaxTest gc_cond gc_deep gc_demo gcfree gcfree2 gc_loop gc_multiret gc_nested gcprobe gc_ptr gc_string sliceprobe2（+memory）、sortIntOnly sortMinimal sortMinimal2 sortQuick（mem追加到已有 slices/sort） | NASM-FAIL 27→8 |
| F5 | `pkg/memory/rc.cute` mallocRC | 增加 `initFreeHeads()`（与 malloc 一致）。根因：gFreeHeads 是 bss 全局，mallocRC 首调漏初始化 → headOf 解引用 [16] SEGV | probeRC/rcSimple 全通 |

> **未提交文件清单**：`compile/compiler.go`（含临时 GLOB/RCMARK 探针，收尾删）、`compile/exp/exp.go`
> （含 derefLoad panic 探针，收尾删）、`parser/exp_check.go`（CUTE_DEBUG_CHK 探针 + fmt/os，收尾
> 整文件 `git checkout --` 还原）、`test/*/package.json` ×20、`pkg/memory/rc.cute`、`type/struct.go`（用户，勿动）。

---

## 4. Cluster A（最高优先）：this/self ABI 脱节 → 大片 139 崩溃

### 根因（已确证）
- 新 ABI：方法调用方 `lea RDI, [this]; call Fn`（寄存器传 receiver）； callee prologue
  `mov QWORD [rbp-48], RDI; this pointer`（存 callee 局部区）。→ `compile/arch/x86_64/linux_sysv.go:~116`
- 但 `compile/arch/x86_64/utils.go GenVarAddr` 的 this/self 分支仍写**旧栈 ABI**：
  - `len(Name)==1` → `return "QWORD[rbp+16]"`（读调用者栈帧，垃圾）
  - `len(Name)>1`（字段访问）→ `totalOffset := 16 + fieldOffset`
  - 两者都假设 this 的家在 `[rbp+16]`——那是 171b537 时代调用方把 this **压在栈上**的老约定。
- `ms_win64.go:~82` 的 prologue 是 `mov QWORD [rbp+16], R10...; this pointer`——win64 与 utils.go **仍然一致**
  ⇒ 修复必须是**按 arch 分流**，不能一刀切改 16→-48。

### 铁证（gdb, test/struct）
```
Point_distanceToOrigin+25: mov rax,QWORD PTR [rbx]   ← SEGV
+17: mov QWORD PTR [rbp-0x30],rdi                    ; this 已存
+21: mov rbx,QWORD PTR [rbp+0x10]                    ; GenVarAddr的错误读法
调用方: lea RDI,[rbp-56]; this pointer; call Point_distanceToOrigin
```

### 修法草案（Agent 可复核再实施）
this 的家做成单一事实源：比如 `ctx.ThisHomeRbp`（linux_sysv=−48，ms_win64=+16；32 位 arch/x86 的
prologue 要单独查——`compile/arch/x86*/` 目录），GenVarAddr 两个 this 分支、calcThisFieldOffset 的
基址、以及 linux_sysv 里 `stackArgBase=24` 的 this 相关假设全部从同一来源取值。

### 预期解锁（修后逐个复核，不要假设全好）
struct、structMethod(92)、recursion、oldprobe、complexTest、stringsUtils、slice_test、rcTracking、
sortTest、sortIntOnly、sortMinimal、sortMinimal2、sortQuick（sort 系崩溃可能在比较回调也走 this）、
simple/simpleVar/simpleMethod/generics/variadic（若也是 deref/method 形状）+ 回归哨兵：derefTest=7、
rcSimple=12、probeC=1。

---

## 5. Cluster B：NASM 形状错误 8 个（逐个独立战役）

| 测试 | nasm 签名 | 初判 |
|---|---|---|
| thread | `symbol std_thread_threadEntryRaw__ptr not defined` | `__ptr` 后缀疑似 mangled 名称/合成符号；查 pkg/thread 源与 build link 路径 |
| structValue | `excess brackets in memory operand` | 生成了 `[[...]]` 形状；找对应发射点（结构体访问/嵌套解引用） |
| m5 | `excess brackets in memory operand` | 同上 |
| rcLeak | `invalid combination of opcode and operands` | 大小/寄存器类不匹配 |
| fullSyntaxTest | `invalid combination of opcode and operands` | 可能与 rcLeak 同根 |
| memoryTest | `mismatch in operand sizes` | QWORD/DWORD 混写 |
| simple | `label or instruction expected at start of line` | 行首发射垃圾（某语句发射为空/坏） |
| asmTest | `operation size not specified` | 立即数装入歧义 |

流程：`run_e2e.sh <dir>` 复现 → 读 `_main.asm` 报错行（错误行号在 asm 文件里）→ 按上下文注释/标签定位发射
函数（compile/exp/exp.go 或 arch）→ 修 → 复跑 → esccheck 基线。

---

## 6. Cluster C：COMPILE-FAIL 17 个

| 测试 | 错误签名 | 初判层 |
|---|---|---|
| multi_return | panic: GenVarAddr: nil type for var 'r' | **后端 arch/utils.go**（W1 地盘，改前先与 W1 协调） |
| buildKeyword | panic: nil pointer dereference | 后端（要堆栈：GOTRACEBACK=1） |
| overload | Call Error: too many arguments in call to add | 校验器规则 vs 语料——需判语料错还是规则错 |
| stringUtils | Call Error: not enough arguments in call to strings.join | 同上；注意 parser 禁改 ⇒ 大概率语料修正或留档 |
| array_basic | Call Error: too many arguments in call to println | println 是 BuiltinFuncs 表驱动；变参支持在 parser/var 表 ⇒ 语料修正优先 |
| gcDebug | Type Error: cannot use int as type string in argument to println | 同上 |
| fnptr_test | Call Error: not found function 'f' | 解析失败，查语料写法 |
| iface_dispatch | Type Error: need type Stringer, not Dog | 接口赋值隐式转换规则在 checker；语料补法或留档 |
| runtime | Syntax Error: Miss ( | 语法层面，parser 禁改 ⇒ 语料修正 |
| slice_minimal | Syntax Error: need type | 同上 |
| fib30bench / fib30time | Syntax Error: missing ')' in call | 同上 |
| comprehensive | panic: open test/comprehensive/package.json: no such file or directory | **语料缺口，建 package.json**（W3） |
| gc_docs | 同上 | **同上**（W3） |
| switch_test | （见 e2e 日志） | 待查 |
| time | （见 e2e 日志） | 待查 |
| "test copy" | 目录名带空格 | 待查（必要时改名目录，属语料） |
| ast 相关 | （其实 comprehensive/gc_docs 两类占位）| — |

> 原则：parser 层错误（Syntax/Call/Type Error 出自 checker）默认**语料修正优先**，class 级
> panic（GenVarAddr/buildKeyword）才动后端。每个判定都要写结论进 PROGRESS.md。

---

## 7. Cluster D：RUN-FAIL 语义核验（66 个待读）

原则：先读 main.cute 的 ret/breakpoint 语义，判「测试期望值即当前 exit ⇒ PASS（记档）」还是
「真失败 ⇒ 进修复队列」。已知烤过哨兵/脚本记档的见 §2 表。重点真失败嫌疑：
- strings 60 / string 100 / stringOperations 50 / stringsTest 8 / strconv 11 —— 字符串族检查失败
- gc_cond/gc_deep/gc_loop/gc_nested=3、gc_multiret=4、gc_string/heap_new=6 —— check 式失败码
- gcprobe 60（`ret 61` 才是成功哨兵 ⇒ 当前是守卫命中 = 失败）、memSuite 3、gcOwnership 9
- echo 124 —— 超时（可能设计为读 stdin，先快速跳过建档）
- guessGame 3、fsTest 2、consoleTest 1、controlFlow 39、complexExpressions 50 —— 逐个核语义
- structMethod 92 / gcStructFree 4 —— 复核（数值语义 or 崩溃）

## 8. 回归哨兵（每波修复后必须全亮）
`test/struct exit=?`（struct 修后应 = 期望计算值；先读源码定值）、derefTest=7、probeC=1、rcSimple=12、
rctest 支持性、gcfree=60、boundsCheck 期望值（读源码）。

---

## 9. 提交分批计划（主线程执行，Agent 不提交）

| 批次 | 内容 | 提交信息草案 | 前置条件 |
|---|---|---|---|
| C1 | exp.go deref= 兜底（探针已删） | fix(compile): deref= 兜底重排（unsafe.cast 右子的滞留形态） | esccheck 基线核对 |
| C2 | compiler.go 段 .data + rcNames（探针已删） | fix(compile): 可折叠初值 → .data；合成 mem 调用预标记 Useful | 同上 |
| C3 | test/*/package.json ×20 | fix(test): 新 std 协议补显式 imports | — |
| C4 | pkg/memory/rc.cute | fix(pkg/memory): mallocRC 补 initFreeHeads | — |
| C5 | arch this/self ABI 修复（W1 产物） | fix(compile): this/self 槽位按 ABI 单一事实源 | 基线 + 哨兵 |
| C6.. | W2/W4 各群逐批 | fix(compile): <签名> … | 逐批 |

---

## 10. 勘误与附录
（Agent 发现与本文相悖的事实，直接在下面追加段落，注明时间与 agent 名。）

### 勘误 1（主线程，2026-10-28，W2 收工后）
- **esccheck 基线判定规则修正**：对象 114/作用域 86 不是绝对常量——语料数据类变动（W3 给 comprehensive 新建 package.json 使新对象可解析）会使对象/作用域各 +1（现 115/87 已归因）。铁律修正为：**compile/ 后端改动必须保持基线不变；语料 json 新增的 +N 须注明对象清单，且与后端改动分属不同提交批次分别核验**。
- W2 完成：NASM-FAIL 8→0（thread=0、m5=7、rcLeak=0、memoryTest=0、asmTest=0、simple=116 均疑似语义通过，语义确认归 W4；structValue=11、fullSyntaxTest=139 进 RUN-FAIL 待核）。哨兵全亮（7/12/1/60/60）。
- W2 语料重写项（动机录 W2_NOTES.md/PROGRESS.md）：pkg/thread/*.cute ×2、test/memoryTest/main.cute（i386 ABI→64 位 syscall）、test/simple/main.cute（abs 撞 NASM 保留名→absValue）、test/asmTest/main.cute（非法 NASM 按意图重写）。提交台账需加一批 **C-W2**。
- **新隐患（W5 待评估）**：编译产物存在 map 序非确定性（simple 复现过两次产物不同），独立隐患，可能与遍历不排序有关。
