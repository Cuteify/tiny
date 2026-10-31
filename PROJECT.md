# PROJECT.md —— 子代理强制快照

> **CLAUDE.md「Agent Execution Rules」强制项**：所有子代理/新会话开工第一件事是读本文件。
> 已浓缩全部命令/基线/缺陷态/路径/纪律——**严禁自行重新探索项目结构与已知信息**（侦察成本耗尽免费额度，两轮实证）。
> 手头任务只需再 grep 本任务相关目录即可。
> **更新责任**：收口时把变化的命令/基线/缺陷态/新钉子即时写回本文件（保持实时）；与现实不符时先修本文件再干。

## 0. 仓库与编译器
- repo=`/home/gx/Desktop/代码/tiny`（module `cuteify`，Go 1.25；**编译器入口=仓库根 `main.go`**；语言=CUTE）
- build：`cd /home/gx/Desktop/代码/tiny && TMPDIR=/tmp/opencode go build -o /tmp/opencode/bin/<name> .`（仓库根=main 包）
  - `main_s01` / `main_s02` = 公共基线二进制（S0-1/S0-2 增量代）；`main_s02f` = 缺陷⑰修后版（即验证常用）
  - **2026-11-01**：/tmp/opencode 曾被清空并重建——`main_s02f`（工作区树重编）+ `base`（HEAD git worktree 对拍二进制）已重建就位；run→repo 符号链接恢复
  - ast_html/ast 系文件=运行副产物，非资产；farm 跑完可能 M 态（不 commit）
- 目标产物：.cute → NASM（x86_64: elf64 / x86: elf32 + gcc -m32 -no-pie）

## 1. e2e（唯一验证方式，恒 flock）
```bash
# x86_64
flock /tmp/opencode/lock -c "cd /tmp/opencode && bash /tmp/opencode/run_e2e.sh <dir> /tmp/opencode/bin/main_s02f"
# x86
flock /tmp/opencode/lock -c "cd /tmp/opencode && bash /tmp/opencode/run_e2e_x86.sh <dir> /tmp/opencode/bin/main_s02f"
```
- farm 期望 rc（PROGRESS.md 基线，**2026-11-01 缺陷⑪ farm 补录后实测**）：
  `test/complexTest=17` ｜ `test/rctest=60` ｜ `test/sliceTest=0` ｜
  `pkg/slices/test=230`（断言 pass*10+fail 公式）｜ `pkg/strings/test=42` ｜
  排序面全 0（sortMinimal/2/Quick/IntOnly/StrOnly，**x64**）｜ `sortTest=x64 139（旧110，Wave T 收口体）` ｜ `slice_test=x64 0` ｜ `negIdx=48（x64；x86=32 分 arch UB 值）` ｜ `derefTest=7（缺陷⑪补录后复活）` ｜ `rcSimple=12` ｜ `gcfree=60` ｜ `gcfree2=0` ｜ `m5=7`（struct 审计 7 项）｜ `map_test=0`（builtin map 语法探针）
  - x86 侧预存红面（非回归）：slice_minimal/slice_test/sortMin 族=console 全局 push 缺 dword（codégen 病灶见 PROGRESS 支线池）；sprobe01 farm 目录缺失已剔出矩阵
- farm 跑 rc 要**三连稳定**才可判绿；异 rc 先 re-run。
- 看生成 asm：`cd /tmp/opencode/run && CUTE_ROOT=/home/gx/Desktop/代码/tiny CUTE_ARCH=x86|x86_64 <bin> -S <dir>`（run 目录=repo 符号 symlink）
- 超时纪律：`timeout 150`；编译挂死特征=60s+（判死必备）；杀掉的运行后必 `pkill -9 -f "main_s0[12Ff] -S"`——**必须字符类**（"main_s02" 直写= pkill 自杀实证）
- SIG 现场 gdb 尸检：先 `ulimit -Sc 0`，完整后恢复 `ulimit -Sc unlimited`

## 2. 提交与文件纪律
- **禁改红线**：`parser/*`、`compile/gc/*`、`type/struct.go`（用户授权范围外）；Go 改动只许明确授权的最小 diff
- .cute 域无红线但 commit 域用**显式路径**逐域 add（不 `git add -A`）
- commit：`flock /tmp/opencode/lock git add <路径> && flock /tmp/opencode/lock git commit -m '一行简短中文带模块前缀'`；**不 push**
- **不碰 docs/stdplan**（主会话收口时统一补账）；子代理战报写 `/tmp/opencode/subreport_<tag>.md`（verdict / diff 摘要 / farm rc 表 / 未竟项）
- 运行流产物（ast.html、pkg/sort/test/gc_llr.txt、gc_summary.json、farmlog）不算资产：commit 不捎带、留 M 态无妨

## 3. 语言形态纪律（.cute 必读）
1. **泛型 fn 内禁 field 访问 / `*T` deref**——形态纪律（照 `pkg/slices/slice_x86_64.cute` 直写蓝本：ptr 算术 + `unsafe.cast` 读写，布局偏移单点 const；P8/A5）
2. **fn 类型形参禁用**（缺陷⑨a：parser.ParseArgs/func.go L385 三形态全死循环 60s 挂死实证）——比较器用特化 fn 家族（int/uint/string）
3. **循环必须显式自增** `i = i + 1`（PROBE-INC 教训：缺自增=无限循环→rc=139 假缺陷）
4. 新 farm 断言模式=pkg/slices/test/main.cute 形态；独立目录 + **package.json 显式 import 全部依赖**（缺陷⑪教训：不显式 → arch fns 连带进二进制但 common fns 缺席→symbol not defined）
5. 多值返回不支持则照 slices 先例（哨兵独立 fn / ok 概念位）
6. 双 arch 分片先例=P8 屏障（common+arch 文件；strings/slices 已分片；slice_x86_64.cute=直写全绿蓝本）
7. x86 参数槽新语义（缺陷⑰②修后）：sub-4B 参数占 dword 槽（API 无感，系统级）

## 4. 缺陷台账快照（2026-10-31）
- ⑨a fn 类型形参 parser 死循环——⏸ 未修，绕行=禁用形态
- ⑪ 包加载器间接连带不对等——⏸ 未修，绕行=farm package.json 全显式 import
- ⑯ x86 u64 返回双 dword 接收踩邻槽——✅ 结案（strings_x86 全链去 u64；scan64.py=/tmp/opencode/scan64.py 可复扫）
- ⑰ x86 泛型单态化槽表错位——✅ 结案 `749a91a`（双病灶：mono 预刷 base 公式 `PushSize()` 分支；`x86/ops.go setArgsOffset` 参数表 4B 槽粒度）
- 缺陷⑰病理详细档案=/tmp/opencode/wave_st_progress.md L212 段
- R3 = monomorphize 缓存量（泛型组合爆炸）观测面；R2 = timsort↔RC 释放路径（Wave T 完成后 esccheck 复验）

## 5. 关键资源
- bin：`/tmp/opencode/bin/`（main_s01 / main_s02 / main_s02f / esccheck_re）
- asm 留档：`/tmp/opencode/asm86_sprobe.asm`、`/tmp/opencode/asm64_sprobe.asm`（x86/x64 修后对照）、`/tmp/opencode/x64tmp/_main.asm`（x64 base 正确形状真值）
- esccheck：`/tmp/opencode/bin/esccheck_re`（验收=红项全 0；complexTest 基线=对象 3/释放 2/转移 1 逐位；W2 口径见 PROGRESS.md 待办池）
- SSOT：`docs/stdplan/PLAN.md`（计划）/ `docs/stdplan/PROGRESS.md`（执行日志+哨兵基线全表）
- Wave St 假想攻坚台账：`/tmp/opencode/wave_st_progress.md`

## 6. 验收语义（缺一不可）
1. 新 farm 双 arch 三连稳定（新 farm 目录名按任务指定）
2. 六 farm 双 arch 零回归（期望 rc 表见 §1）
3. esccheck 红项全 0
4. 每域独立 commit（flock 保护、显式路径、一行中文前缀）
5. 战报落 /tmp/opencode/subreport_<tag>.md（完整，= 主会话收口台账唯一来源）

## 7. 并行 SubAgent 分域原则（用户拍板）
- 多路并行必须是**互斥文件域**；每路独立二进制后缀名（如 main_s02f）防互踩；git commit 过 flock 排队。
- 用户曾两次发令：「断了，继续」「重开」= 子代理额度耗尽时**接棒主会话直接干**（规则如上全部适用）。
- **快照规则（用户拍板 2026-10-31）**：子代理强制本文件，不自行重新探索。

## 8. 语言参考（CUTE 速记）
- 变量 var x: type = expr；if/for/blocks 均花括号制；for `for ; i < n; { ... }`（无 i++ 自运算；步进=显式 i = i + 1）
- 类型宽：int/uint=arch word（x64 8B / x86 4B）、u8/u16/i16 等宽、ptr=arch word、bool 1B、string=24B 头{p@0,n@8/4,c@16/8}、切片头 data@0/len@8/4/cap@16/8
- unsafe.cast[T] 强转；build arch("x86"|x86_64) 分片头；import "std:xxx"
