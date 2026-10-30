# SubAgent 分工与执行计划（2026-10-28）

> 配套：`PROBLEMS.md`（SSOT 问题总账）、`PROGRESS.md`（实时进度日志）。
> 本文件定义任务卡、文件所有权、验证矩阵、中断恢复流程。启动前必读三文档。

---

## 0. 启动协议（每个 SubAgent 第一件事）

1. 读 `docs/fixplan/PROBLEMS.md`（重点 §0 铁律 + 自己的 Cluster 章节）
2. 读 `docs/fixplan/PLAN.md`（本文，任务卡 + 所有权）
3. 读 `docs/fixplan/PROGRESS.md` **尾部 30 行**，确认无他人正在动自己的文件（`@提及` 机制见 §3）
4. 在 PROGRESS.md 写一行 `Wn boot` 记录启动
5. 开始工作；自此**每完成一步立即追加一行进度**（格式见 PROGRESS.md 头部）

## 1. 波次总览

| 波次 | Agent | 任务 | 启动时机 | 状态 |
|---|---|---|---|---|
| 1 | W1 | ABI 修复（this/self 槽位）+ 崩溃簇验证 | 立即（后台） | 运行中 |
| 1 | W2 | NASM 形状错误 8 个战役 | 立即（后台） | ✅ DONE：NASM-FAIL 8→0；structValue=11/fullSyntaxTest=139 的 RUN 语义移交 W4 |
| 1 | W3 | COMPILE-FAIL 17 个盘点 + 语料 json 补齐 | 立即（后台） | 运行中 |
| 2 | W4 | RUN-FAIL 66 个语义核验 + 修复 | W1 DONE 后 | 待命 |
| 3 | W5（主线程） | 探针清理、esccheck 终验、分批提交 | 全部 DONE 后 | 待命 |

## 2. 任务卡

### W1 —— this/self ABI 修复（最优先，杠杆最大）
- **根因链**：PROBLEMS.md §4（gdb 铁证：`Point_distanceToOrigin` 读 `[rbp+16]` 崩溃）。
- **可改文件**：`compile/context/*`（加 this-home 单一事实源）、`compile/arch/x86_64/utils.go`（GenVarAddr this/self 两分支 + calcThisFieldOffset）、`compile/arch/x86_64/linux_sysv.go`（prologue 与 stackArgBase 的 this 相关一致化）、`compile/arch/x86_64/ms_win64.go`（win64 家在 +16，勿破坏）、32 位 `compile/arch/x86*/` 同类排查。
- **实施方案建议**：`context.Context` 增加字段（如 `ThisHomeRbp int`），linux_sysv 建编译器时设 −48，ms_win64 设 +16；GenVarAddr 从 ctx 取值。禁止硬编码散落。
- **验证矩阵**（全部 `flock /tmp/opencode/lock` + 自己 binary）：
  - 哨兵回归：derefTest=7、probeC=1、rcSimple=12、rctest=60、gcfree=60
  - 崩溃族逐个：struct（先读 main.cute 算期望值：末行 ret 各项之和）、structMethod(92)、recursion、oldprobe、complexTest、stringsUtils、slice_test、rcTracking、sortTest、sortIntOnly、sortMinimal、sortMinimal2、sortQuick
  - **每个测试独立复核，崩溃族≠一定同根**（recursion 无 method，可能是别的帧问题）；修不动的单独归因记录。
- **纪律**：每次 compile/ 改动 → esccheck 基线核对（§0/1），漂移即回滚；保持每步 `go build` 绿色。
- **完成定义**：崩溃族全部 PASS 或逐个归因清楚；哨兵全亮；esccheck 基线逐位不变；PROGRESS 写 DONE。

### W2 —— NASM 形状错误 8 个
- **清单与签名**：PROBLEMS.md §5（thread 符号缺失、structValue/m5 复括号、rcLeak/fullSyntaxTest 操作数组合、memoryTest 大小不符、simple 行首垃圾、asmTest 尺寸未指明）。
- **流程**：`run_e2e.sh <dir> <bin>` 复现 → nasm 报错行号回到 `_main.asm` → 按行附近注释/标签定位发射函数 → 修 → 复跑 → esccheck 基线。
- **可改文件**：`compile/exp/exp.go`、`compile/compiler.go`（发射形状相关处）、`compile/arch/x86_64/utils.go` 中**非 this/非 calcThisFieldOffset** 的部分（如 MakeRbpAddr/长度前缀）、arch 顶层发射器。
- **与 W1 的边界**：`GenVarAddr` 的 this/self 两分支和 `calcThisFieldOffset` 是 W1 地盘；你也可能要改 utils.go 其他函数——**只动与 this 无关的形状问题**，冲突时先在 PROGRESS 提 `@W1`。
- **thread 特例**：是缺符号不是形状。嫌疑：pkg/thread 未加载/未标记 Useful / `threadEntryRaw__ptr` 的 `__ptr` 是合成 ptr 符号 mangle。先查沙盒 `/tmp/opencode/run/pkg/thread` 与主仓 `pkg/thread` 的一致性（cp 同步纪律）。
- **完成定义**：8 个全部 NASM 干净（RUN 成败交 W4 语义），基线不变。

### W3 —— COMPILE-FAIL 17 个盘点（分析为主，代码只动语料数据）
- **清单**：PROBLEMS.md §6。参考日志 `/tmp/opencode/e2e_full.log`。
- **允许操作**：
  - 为 `comprehensive`、`gc_docs` **创建 package.json**（读源码判断需导入的 std 包：memory/strings/slices/sort/console/fs/time…，格式仿 sortIntOnly）
  - 目录名带空格的 `test copy` 若确属语料垃圾，可改名（在 NOTES 记录）
  - 其余逐个复现、分类成三档：`语料修正`（可顺手修 json/源码小笔误必须记录理由）/ `后端可修` / `parser 限制（禁改，移交）`
- **禁止**：改任何 `.go` 文件。`GenVarAddr nil type (multi_return)`、`buildKeyword panic` 这类后端判断写进 `W3_NOTES.md` 并在 PROGRESS 提 `@W1`，由主线程路由。
- **格式**：每个测试一段，写入 `docs/fixplan/W3_NOTES.md`：错误原文 / 最小复现 / 三档判定 / 证据 / 修复建议。**边写边跑，逐条实时追加**，不要攒批。
- **完成定义**：17 个全部有归档判定；能修的语料项修完并复跑通过或给出理由。

### W4 —— RUN-FAIL 语义核验（W1 DONE 后启动）
- 按PROBLEMS §7 原则逐个读 main.cute 定语义；哨兵值=期望 ⇒ 记档 PASS（§2 表扩充）；真失败 → 修复队列。
- 修复主战场 `compile/exp/exp.go`（W2 已结束，无冲突）。
- 优先级：崩溃(139/136/134) 与 hang(124) > 小失败码簇 > 数值语义档。

### W5 —— 收尾（仅主线程）
- 删探针：compiler.go 的 GLOB/RCMARK 块、exp.go derefLoad panic、`git checkout -- parser/exp_check.go`、沙盒 .cute ret 标签逐一 grep 验证为 0。
- esccheck 基线终验 + 全语料 final tally。
- 按提交台账（PROBLEMS §9 C1-C6…）分批提交，type/struct.go 永不出现在任何 add 命令。

## 3. 中断恢复与移交（SubAgent 会断）

1. **进度格式**是恢复的锚点：每行形如 `[2026-10-28T09:15Z] W1 step7 ● 测试 struct exit=102（期望 79，还差两项）`
2. **NOTES 文件**（`W1_NOTES.md` 等）：长分析、汇编摘录、假设、待办清单。每次重大推理后立即落盘。
3. **被中断后新 Agent接管**：读 PROGRESS 尾部 → 读自己 NOTES → 先用 run_e2e 复核当前测试状态（结论可能与进度记录有出入）→ 接着做最后一个未完成 step。
4. **@提及移交**：在 PROGRESS 行里写 `@W1` / `@W2` / `@MAIN`，跨 Agent 请求用此方式；收件方每完成一 step 扫一眼本文件。
5. **冲突自保**：若发现自己文件里出现了不属于该任务卡的意外改动（他人半成品），勿回滚他人改动，在 PROGRESS 提 `@MAIN`。

## 4. 整体完成定义

- e2e 全语料：NASM-FAIL=0、LINK-FAIL=0；COMPILE-FAIL=0（或逐个归档为 parser 限制并说明）；RUN-FAIL 全部要么 PASS 要么有语义档案（哨兵表完整覆盖）。
- esccheck：`107/140 · 对象=114 · RC/泄漏释放=6 · 泄漏=0 · 提前释放=0 · 作用域释放=86 · 转移=22` 逐位不变。
- 探针 grep 为 0；分批提交全部落地；`git status` 干净（除 type/struct.go 用户改动）。
