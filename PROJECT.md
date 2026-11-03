# PROJECT.md —— 子代理强制快照

> **CLAUDE.md「Agent Execution Rules」强制项**：所有子代理/新会话开工第一件事是读本文件。
> 已浓缩全部命令/基线/缺陷态/路径/纪律——**严禁自行重新探索项目结构与已知信息**（侦察成本耗尽免费额度，两轮实证）。
> 手头任务只需再 grep 本任务相关目录即可。
> **更新责任**：收口时把变化的命令/基线/缺陷态/新钉子即时写回本文件（保持实时）；与现实不符时先修本文件再干。

## 0. 仓库与编译器
- repo=`/home/gx/Desktop/代码/tiny`（module `cuteify`，Go 1.25；**编译器入口=仓库根 `main.go`**；语言=CUTE）
- build：`cd /home/gx/Desktop/代码/tiny && TMPDIR=/tmp/opencode go build -o /tmp/opencode/bin/<name> .`（仓库根=main 包）
  - **2026-11-04 现行**：收口二进制=`/tmp/opencode/bin/w14c`（GC 分析修复收口：条件/增量临时
    `COND_FREE`/`INCR_FREE`、`HasGlobalOwnStore` 保守门槛、ret/块/覆盖释放；
    含 Wave I/Mp/T/F 全部修复）；
    e2e=`/tmp/opencode/run_one.sh <bin> <repo相对dir> <arch>`（绝对目录用 `run_dir.sh <bin> <dir> <arch>`）；
    esccheck=`/tmp/opencode/bin/esccheck`（全语料脚本 `/tmp/opencode/esccheck_all.sh`，红项判据=泄漏/提前释放 0）
  - 上一收口二进制=`/tmp/opencode/bin/w13`（Wave I 终态）；`w14b`=GC 改动前已验证编译器
    （条件清理修复前，仅用于对拍）。
    旧 `main_s01/main_s02/main_s02f` 与 `run_e2e*.sh` 已随 /tmp 清理失存；
    HEAD 干净对拍=`/tmp/opencode/base_I0`（HEAD=`1306ddb` 树副本，`run_base.sh` 跑）
  - ast_html/ast 系文件=运行副产物，非资产；farm 跑完可能 M 态（不 commit）
- 目标产物：.cute → NASM（x86_64: elf64 / x86: elf32 + gcc -m32 -no-pie）

## 1. e2e（唯一验证方式，恒 flock）
```bash
# x86_64（<dir> = 仓库相对目录）
flock /tmp/opencode/lock -c "cd /tmp/opencode && bash /tmp/opencode/run_one.sh /tmp/opencode/bin/w14c <dir> x86_64"
# x86
flock /tmp/opencode/lock -c "cd /tmp/opencode && bash /tmp/opencode/run_one.sh /tmp/opencode/bin/w14c <dir> x86"
# 绝对目录探针（/tmp 下）
flock /tmp/opencode/lock -c "bash /tmp/opencode/run_dir.sh /tmp/opencode/bin/w14c <绝对dir> x86_64"
```
- farm 期望 rc（**2026-11-04 GC 收口（w14c）双 arch 22 项矩阵逐项对拍 w13 基线，无漂移**）：
  `test/complexTest=17` ｜ `test/rctest=60` ｜ `test/sliceTest=0` ｜
  `pkg/slices/test=230`（断言 pass*10+fail 公式）｜ `pkg/strings/test=42` ｜
  排序面全 0（sortMinimal/2/Quick/IntOnly/StrOnly，**x64**）｜ `sortTest=x64 110（11 pass/0 fail，Wave T 收口）` ｜ `slice_test=x64 0` ｜ `negIdx=48（x64；x86=32 分 arch UB 值）` ｜ `derefTest=7（缺陷⑪补录后复活）` ｜ `rcSimple=12` ｜ `gcfree=60` ｜ `gcfree2=0` ｜ `m5=7`（struct 审计 7 项）｜ `map_test=0`（builtin map 语法探针）｜ **`mp_min=80`｜`mp_map=330`（进程 rc 取模=74，Wave Mp 双 arch 三连）**
  - GC 收口新增回归（双 arch，期望 0）：`test/gcCondTemp=0`（if true/false、if/else、`||`
    短路、for 条件临时释放）｜`test/gcRetFree=0`｜`test/gcBlocks=0`｜`test/gcOverwrite=0`。
    条件清理的真路径是直落，false 清理块前必须 `jmp trueLabel`（已修）。
  - `strings.makeString` 是包装外部 ptr 的非分配函数：LLR 可见对象但不生成
    `COND_FREE`/`RET_FREE`；`_checkStrSorted` 参数指向数组元素缓冲，误释放=UAF。
  - x86 侧预存红面（非回归）：slice_minimal/slice_test/sortMinimal/2/Quick/IntOnly=NASM `operation size not specified`（console 全局 push 缺 dword，codégen 病灶见 PROGRESS 支线池）；sortStrOnly/sortTest=COMPILE_FAIL（nil Type 链，预存 deref-store/泛型 len 碰撞面，见 §4）；sprobe01 farm 目录缺失已剔出矩阵
- farm 跑 rc 要**三连稳定**才可判绿；异 rc 先 re-run。
- 看生成 asm：`cd /tmp/opencode/run && CUTE_ROOT=/home/gx/Desktop/代码/tiny CUTE_ARCH=x86|x86_64 <bin> -S <dir>`（run 目录=repo 符号 symlink）
- 超时纪律：`timeout 150`；编译挂死特征=60s+（判死必备）；杀掉的运行后必 `pkill -9 -f "w1[01234] -S"`——**必须字符类**（直写二进制名= pkill 自杀实证）
- SIG 现场 gdb 尸检：先 `ulimit -Sc 0`，完整后恢复 `ulimit -Sc unlimited`

## 2. 提交与文件纪律
- **禁改红线**：`parser/*`、`type/struct.go`（`compile/gc/*` 经用户授权用于本轮 GC 收口）；Go 改动只许明确授权的最小 diff
- .cute 域无红线但 commit 域用**显式路径**逐域 add（不 `git add -A`）
- commit：`flock /tmp/opencode/lock git add <路径> && flock /tmp/opencode/lock git commit -m '一行简短中文带模块前缀'`；**不 push**
- **不碰 docs/stdplan**（主会话收口时统一补账）；子代理战报写 `/tmp/opencode/subreport_<tag>.md`（verdict / diff 摘要 / farm rc 表 / 未竟项）
- 运行流产物（ast.html、pkg/sort/test/gc_llr.txt、gc_summary.json、farmlog）不算资产：commit 不捎带、留 M 态无妨

## 3. 语言形态纪律（.cute 必读）
1. **泛型 fn 内禁 field 访问 / `*T` deref**——形态纪律（照 `pkg/slices/slice_x86_64.cute` 直写蓝本：ptr 算术 + `unsafe.cast` 读写，布局偏移单点 const；P8/A5）
2. **fn 类型形参禁用**（缺陷⑨a：parser.ParseArgs/func.go L385 三形态全死循环 60s 挂死实证）——比较器用特化 fn 家族（int/uint/string）
3. **循环必须显式自增** `i = i + 1`（PROBE-INC 教训：缺自增=无限循环→rc=139 假缺陷）
4. 新 farm 断言模式=pkg/slices/test/main.cute 形态；独立目录 + **文件顶层 `import` 显式声明全部依赖**（Wave I 后 package.json imports 已弃用；缺陷⑪教训：不显式 → arch fns 连带进二进制但 common fns 缺席→symbol not defined）
5. 多值返回不支持则照 slices 先例（哨兵独立 fn / ok 概念位）
6. 双 arch 分片先例=P8 屏障（common+arch 文件；strings/slices 已分片；slice_x86_64.cute=直写全绿蓝本）
7. x86 参数槽新语义（缺陷⑰②修后）：sub-4B 参数占 dword 槽（API 无感，系统级）

## 4. 缺陷台账快照（2026-11-02）
- ⑨a fn 类型形参 parser 死循环——⏸ 未修，绕行=禁用形态
- ⑪ 包加载器间接连带不对等——⏸ 未修，绕行=farm 文件顶层显式 import 全部依赖（Wave I 前为 package.json imports）
- ⑯ x86 u64 返回双 dword 接收踩邻槽——✅ 结案（strings_x86 全链去 u64；scan64.py=/tmp/opencode/scan64.py 可复扫）
- ⑰ x86 泛型单态化槽表错位——✅ 结案 `749a91a`（双病灶：mono 预刷 base 公式 `PushSize()` 分支；`x86/ops.go setArgsOffset` 参数表 4B 槽粒度）
- ⑰b/⑯随修 单态化 else 子树共享 + 先替身再克隆污染 `sizeof[K]`——✅ 2026-11-02（克隆先于原树替身；else 深拷贝+Father 重绑）
- ⑱ binRL 左子指针基/this 字段就地写覆盖右子活值（sb=2×slots）——✅ 2026-11-02（该形态退回独立寄存器）
- ⑫ Wave Mp 借用指针被 GC 误判 owned——✅ 2026-11-02（三站点收窄 `IsBuiltinNewAlloc()`）
- `||`/`&&` 链 BeParent 缺 `exp.Father=e.Father`（≥3 项中间复合链丢第 3 叶）——✅ 2026-11-02（1 行修复+双 arch 真向短路）
- **x86 `uint %` 发有符号 `cdq; idiv`**（新记，未全局修）——高位 FNV 哈希变负偏移；maps 六处 `& (cap-1)` 局部绕行（cap 恒 2^n）
- **free-list class 尺寸错配**（合并块 160B 按 slotOf=8 入链，class 8 规范=168，footer 越界 8B 踩后继 header）——✅ 2026-11-02 `4828d7a`（`freeListClassOf` 取规范尺寸≤实际的最大 class；malloc 按实际 rawSize 拆/消费；sortTest 139→110）
- **json imports 通道 + autoImport 兜底**（Wave I）——✅ 2026-11-02 `1306ddb`：依赖声明唯一通道=文件级 `import`；
  `GetPackage` 解码后 `Imports=nil`；`autoImport`/`RegisterAutoImport`/`LookupAutoImport` 全删（零读者取证）；
  根包 builtin 注入保留。**2026-11-03 `d120c4a` 终态**：`Info.Imports` 加 `json:"-"`（解码层彻底忽略）
  + 删除 json 导入解析循环；取证 `probe_json_local` 仅 json 声明 lib → asm 零 `lib/seven` 引用，
  对照文件级 import 双 arch RC:7
- **deref-store 右值调用静默丢弃**（预存，未修）——farm 同 import slices/sort（间接带 `slices.len[T]`/`cap[T]`）时 `*p = unsafe.cast[ptr](strings.len/cap(...))` 的调用从 asm 消失、落 stale RAX；x64 sortStrOnly 输出多 2B / x86 COMPILE_FAIL:2（nil Type 链）；w7 同现象
- **`pkg/sort/test` 陈旧测试**（预存，未修）——引用已删除的 `sort.isSortedInts/searchInts/sortInts`（仅存 `str_sort.cute.bak3`），w7/w11 同 rc=1；不在 22 项矩阵
- 缺陷⑰病理详细档案=/tmp/opencode/wave_st_progress.md L212 段
- R3 = monomorphize 缓存量（泛型组合爆炸）观测面；R2 = timsort↔RC 释放路径——✅ 2026-11-02 esccheck 红项 0

## 5. 关键资源
- bin：`/tmp/opencode/bin/`（w13=Wave I 终态编译器；w12=Wave I 收口；w11=Wave Mp/T/F 收口；esccheck=逃逸检查器）
- asm 留档：`/tmp/opencode/asm86_sprobe.asm`、`/tmp/opencode/asm64_sprobe.asm`（x86/x64 修后对照）、`/tmp/opencode/x64tmp/_main.asm`（x64 base 正确形状真值）
- esccheck：`/tmp/opencode/bin/esccheck`（验收=红项全 0；complexTest 基线=对象 3/释放 2/转移 1 逐位；全语料脚本=`/tmp/opencode/esccheck_all.sh`，W2 口径见 PROGRESS.md 待办池）
- 矩阵脚本：`/tmp/opencode/matrix.sh <bin> <arch> <runs>`；Wave I 验证日志
  `matrix_x64_I1.log`/`matrix_x86_I1.log`（w11，json 仍消费）、`matrix_x64_I2.log`/`matrix_x86_I2.log`（w12，json 通道关闭）、
  `matrix_x64_I3.log`/`matrix_x86_I3.log`（w13，`json:"-"` 终态）
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
