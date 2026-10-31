# stdplan 执行日志（实时）

> SSOT：`docs/stdplan/PLAN.md`（现为 **v2.3**）。本文件逐日记录实施与验证事实。

## 2026-10-29（Wave L 实施完成）

- **语言设施全部落地并验证**（改动保留工作区，随 C1–C8 一起挂起提交）：
  - lexer：`IMPORT` 常量追加在 `BUILD` 后（既有编号不变）+ keywords 表 + LexTokenType
    条目 + `ImportListLength`。语料无 `import` 字 → token 流零变化。
  - `parser/import.go` 新建：`ImportBlock{Items []ImportItem{Alias,Path}}`；
    单条/前缀别名/`_` 空导入/分组四语法全支持；`.` 点导入按 R10 报错、
    反引号 RAW 报"路径必须双引号"、非顶层报错；同别名同路径去重、异路径报错
    （默认别名按 Go 语义取路径末段）。**不向语法树挂节点**（防 gc 前端未知类型）。
  - `parser/parser.go`：`FileImports` 字段（仅记录）+ dispatch `case lexer.IMPORT` +
    processTypeToken "struct" case 在 AddChild 前 `attachPendingAlign`。
  - `package/imports.go` 新建：`scanImports`（三条正则，分组优先）→
    `resolveImportPath` 五形态（按冒号位置零启发式）→ `registerFileImports`
    （别名写 `info.Imports` 与 json 同一通道；`_` 只加载不绑定；物理路径去重加载；
    std: 镜像 json 注册 autoImport）。`stdPackageDir`：CUTE_ROOT 显式即权威不回退 →
    可执行目录及其上级（须 `<root>/pkg/<sub>` 存在）→ Getwd 兜底。
    `projectRoot/projectName` 根包加载时设置（isRoot）。
  - `package/package.go`：package.json **可选化**（缺失合成 `Name=path.Base`，解码错误仍报；
    打开非 not-exist 错误仍报）；isRoot 设置 projectRoot/projectName；json std: 分支
    改 `stdPackageDir`（顺带修 `ppath[:4]` 对 len<4 的 panic 隐患，两处）；文件循环
    hoist `cuteFile` + preFilterBuild 后、解析前 `registerFileImports`。
  - `package/fmt/fmt.go`：`Info.Name` 字段 + `DefaultImportAlias`（LastIndexAny ":/"）。
  - **R6 破冻（type/struct.go）**：`StructType.Align` 字段 + `Layout()` pack 分支
    （`pack>0 && alignment>pack` 才封顶；Align=0 逐位保持旧行为；RAlignment 因逐字段
    封顶自然等于 min(max自然,N)）。
  - `parser/build.go`：`Build.Align` 字段 + `align(N)`/`noalign`(=1) case（strconv）+
    `attachPendingAlign`（只看最后一个子节点，命中即消费：应用后从 Children 移除，
    严格紧随语义）；compile/build.go 无 "align" case → 返回 ""，**零编译改动**。
  - `parser/type.go`：TypeStruct case attach 调用；`parser/func.go`：顶层 build 回溯
    对 align 透明（continue 不 break，os/arch 照常收取）。
- **测试**（全部无 package.json，兼测可选化）：
  - `test/align`：自然 8 / align(2)=6 / noalign=5 / 孤儿（隔 var）8 / 孤儿后续 struct 8
    —— 首跑全绿 exit=0。
  - `test/import`：默认别名 memory + 显式别名 mem + `_ "std:syscall"` + 分组去重 +
    `:mylib/sub` vendor fixture（answer=42）—— 首跑全绿 exit=0。
  - `test/name_rel_test`（沙盒）：`name_rel_test:lib/util` 五形态之项目顶层相对 ✓；
    `test/local_rel`：`./lib/util` 本地形态 ✓。
- **负路径验证**：`.` 导入报错 ✓ / 裸短名报错 ✓ / 未知前缀 `foo:bar` 报错 ✓ /
  无 CUTE_ROOT 且 cwd 无 pkg → builtin 报 "set CUTE_ROOT" ✓ / Getwd 兜底在
  cwd 有 pkg 时生效 ✓。
- **回归对拍（零回归证明）**：13 绿哨兵全部逐位一致（rctest=60、gcfree=60、
  castmalprobe=7、derefTest=7、rcSimple=12、probeC=1、oldprobe=0、slice_minimal=0、
  sortMinimal/2/Quick=0）；recursion=53 与 complexTest=1 为 **C1–C8 基线原状**
  （用「仓库−Wave L」对照编译器 /tmp/opencode/bin/prec_l2 验证同为 53/1；
  complexTest 的 matM 探针族全=1 与 `||`/`&&` 双发射 53→51 都是待修项）；
  另双二进制对拍 ~49 目录 exit 逐一相等；memoryTest 双方同因 NASM 失败
  （malloc 未定义；行号漂移系符号名含包物理路径——CUTE_ROOT 中文路径经
  FixPathName 的化妆差异）；comprehensive 本身非确定（双二进制各自连跑三样值）。
- **e2e 更新**：`/tmp/opencode/run_e2e.sh` 增加 `export CUTE_ROOT=<repo>`，
  std 不再依赖沙盒 pkg 副本。

## 2026-10-29

- **立项**：用户指示「好好规划和实现 memory、slice、string、map 等，参考 go」；
  PLAN.md v1 落盘（含全库审计：33 包、空壳 6、跨包失配 9 调用点、四大件+sort 阶段表）。
- **关键事实已证**（承接 fixplan W4）：
  - `sort.qsortInts` 用真实名调用 → 5 元素排序端到端正确（sortDbg 哨兵 ret=1=全序无逆序）；
  - 失配是语料代际问题：测试写自更老 API 代际（旧 gc_summary.json 工件佐证 quickSortInts/_quickSortIntsRange 曾存在）；
  - `hashmap` 非泛型（string/ptr 单形），`maps` 为其助手 —— 合并基础确认。
- **Phase A 完成实施**：`pkg/sort/api.cute` 公开层（切片族 + 裸阵列族 ptr,n 双形状），
  失配 6 调用点归零，sortMinimal/2/Quick 哨兵清零；**改动未提交 → Wave 0 C 批次收编**。

## 2026-10-29（v2 升级）

- **用户决策点拍板**（四问）：
  1. 波次顺序 = **0 门禁 → M memory → S slices → St strings → Mp maps → T+F**；
  2. W5 探针删除 = **各 Wave 尾部随手清**（0 尾 exp_check 还原 / M 尾 compiler.go RCMARK / S 尾 leaf PROBE-CAST），不设独立阶段；
  3. hashmap = **删包**（不做薄壳）；text/template 切 std:maps；
  4. noalign 语义 = **build 关键字设置不对齐或对齐宽度，struct Layout 参考该数据** → Wave N（St 后 Mp 前）。
- **用户架构要求固化**（PLAN v2 P7–P9）：
  - string/slice/map **单向依赖 memory、memory 反向零依赖**（审计已成立，铁律化）；
  - 容器之间零横依赖（maps 的 string hash/eq 手写，不 import strings）；
  - 数据结构尽量结构体表示：`str{p,n,c}`（内建 string 24B：ptr@0/len@8/cap@16）、
    `sliceHdr{n,c,p}`（len@0/cap@8/data@16）覆写结构体 = 自己的 unsafe 获得类型版本；
  - 泛型 struct 未证实（全库无 `struct [T]` 用法、monomorphize 仅函数级）→ maps 保持裸 ptr 手工寻址（A5）。
- **内存管理器结构审阅完成**（PLAN v2 §2，用户提问「内存管理器的结构你看了吗」的正面回答）：
  - 分层健全：60 class 分级空闲链表 + 双 boundary tag + RC 族（前缀 3×ptrSize）+ 泄漏表 + memcpy/memset；
    `free` 运行时按 flagLoad(ptr)==IS_RC_TAG 分流；
  - 发现 6 项：**F1 IS_RC_TAG(0x18000) 与用户 size 98281–98288 碰撞（free 误分流 rcDec，真隐患）**、
    F2 memset word 路径恒写 0、F3 gDbgA-D 热路径残留、F4 HUGE/LARGE 仅堆顶回收、
    F5 泄漏表 256 条上限、F6 HUGE header 未 round8 —— F1/F2/F3 修复进 Wave M，其余文档化；
  - 依赖方向：memory→syscall 唯一依赖 ✓；33 包单向 import memory ✓；slices 自带 memmove 属越层实现 → Wave M 提级。
- **PLAN.md 升级 v2 + 本文件同步**（本次提交）。

## 2026-10-29（v2.1 · import 设计拍板）

- **import 关键字设计定案**（多轮商讨，PLAN v2 P10 落盘）：
  - 用户拍板：json 只管包信息，依赖声明上文件顶层（参考 Go）；`std:` 必须保留
    （除 std 外还有 ext=标准库扩展、api=其他语言 API 绑定；不带名字的冒号前缀=第三方）；
  - **五形态判别按冒号位置，零启发式**：`std:/ext:/api:` 官方（逻辑源，后续映射指定 git 仓库）｜
    `tiny:lib/foo` 冒号前==根包 name → 项目顶层相对（name/module 合一，不新增字段）｜
    `:github.com/xxx/xxx` 冒号在最前（无名字无协议）→ 第三方，一期 vendor/ 优先｜
    `./` `../` `/abs` 本地（**本地文件没有冒号**）｜未知名冒号/裸短名非法报错；
  - 别名语法与 Go 完全一致（`import mem "std:memory"` + `_` 空导入 + 分组）；`.` 点导入 defer（R10）；
  - **CUTE_ROOT 拍板**：环境变量指定 std 根，未设→编译器本地兜底，替代 Getwd（砍沙盒 cp pkg 痛点）。
- **波次重排**：原 Wave N（align）撤销并入 **Wave L 语言设施** = import + align + CUTE_ROOT，
  位于 Wave 0 之后、M memory 之前（用户：「先把 import 和 align，然后再重写 stdlib」）。
- **提交挂起**：C1–C8 分批提交（51 文件：编译器 C1–C6 / stdlib C7 / test C8 + type/struct.go 代提交 + docs 入库）
  **用户指示暂不提交**，改动保留在工作区。
- **Wave L 蓝图定稿**（PLAN §5 L 行 + P9 + P10 + R6 破冻范围 + R8/R9/R10 风险），待开工实施。

## 2026-10-31（Wave St 双战线收口 + Wave S x86 分片追凶）

- [x] **Wave St strings ✅ 2026-10-31**（§4.3 全 78 fn；main_s02 增量；x86 首个收口 pkg）：
  1. **结构与战线**：全 78 fn 分 common + 双 arch 文件（P8 切片屏障，先例=slices 分片）；
     x86_64 pkg/strings/test rc=42 全绿；**x86 strings_x86.cute 战线 rc=42 全绿**——x86 侧首个全线收口 stdlib pkg。
  2. **缺陷⑫ NASM 13 错面清零**：memmove_x86 块 push 补 `dword` / rc.cute mallocRC flagStore(RC_BIT)
     实参 staging var 化（flagRC）/ tracker.cute leakStore+resetLeakTracker 全局写 staging（cntV/zeroU）；
     bool 写回 if-dispatch 规约；strings_x86 四桥 asm 块改纯 .cute（照 x86_64 载荷）。当前 nasm rc=0。
  3. **缺陷⑯定谳+绕行结案**：x86 对 u64 返回走双 dword 接收装配但栈只分配 4B——hi 半字写进相邻变量槽；
     绕行=全链去 u64（`toU64` uint 返回 / `fromI64` uint 形参 / u64Box 删除 / 6 接收点单槽化），
     scan64.py 扫描器复扫接收点=0、撞车=0；x86_64 版 u64 原生不动。
  4. **缺陷⑪（包加载器间接连带不对等，新钉子未结案）**：未显式 import `std:strings` 的构建把 arch 文件
     全量函数拉进二进制但 common fns 整体缺席 → `symbol std_strings_count not defined`；
     绕行=五 farm 测试 package.json 全部显式 import（五项 rc 逐项命中即绿）；待 Go 补齐间接连带加载。
  5. **fieldsFunc 按 R15 摘除**（缺陷⑨a：fn 类型形参三形态 → parser.ParseArgs 死循环，双 arch 留延期备案注释）；
     arch→common 反向调用洗白正式结案（count/isSpace 反向、双 string 实参、uint 跨边全全绿）。
- [x] **Wave S x86 分片追凶 + 缺陷⑰病理定谳 ✅ 2026-10-31**（main_s02 增量）：
  1. **arch 分片**：25 fn 全迁 slice_x86.cute / slice_x86_64.cute，slice.cute 退守 doc 头+import；
     x64 六 farm 复验分片零影响全绿（sprobe01=0 / complexTest=17 / rctest=60 / sliceTest=0 / pkg-slices=230 / strings=42）。
  2. **缺陷⑰三现场**（x86 泛型单态化下一切 field/deref/call 模板皆雷）：make field base 读错槽 →
     push curLen 槽错拿 c → _elemPtr 同源；播槽暂胜版（make padv2 + push padPad3 + _elemPtr 原版）base 通到
     `sAddr@-24` 但**逻辑级错位**：curLen 错拿 c / field-assign RHS 错读 valPtr 槽 / call arg 错读 padP3 槽——
     不崩也 rc≠0，21+ fn 逻辑不可达。
  3. **病理定谳（Go 源只读，冻结红线未碰）**：`compile/monomorphize.go` L597-624 S0-3 原树预刷公式
     `base := -(8 * len(CalleeSaveRegs())) - argSave` 按 **x64 尺度烙印**（每寄存器记 8B；x86 `push EBX`
     只 4B）→ x86 下原树 Offset 表与克隆体 4B body 分配**整体错 8B**：field base 表槽恒读 -24
     （=克隆体第 5 个 4B 槽；x64 正确态 base=hdr 槽 -72=8B 第 3 decl）；remapFuncBodyRefs 只重绑
     FindTypeArg/FindTypeVar，FIELD 基址 Path[0] 走原树 define 同源，天然无我。
  4. **绕行三路径实证封锁**：A 播槽=逻辑级错位（见上）；B₁ 非泛型化 def（farm 120 处 `[int]` 全 int）→
     typer 对「泛型调用面×非泛型 def」**死循环挂死**（60s×2 实证）；B₄ 函数内去 field 化 deref 化 →
     同样挂死（60s 实证）——Common 新钉子「x86 泛型+deref 组合死循环」。
  5. **处置**：x86 slices 三 farm（sprobe01/sliceTest/pkg-slices-test）留 139 记账等 Go 修复窗口——
     S0-3 公式需按 arch push 粒度分区（CalleeSaveReg 尺寸平台常数化 + 参数 save 区按 arch 判定计入/剔除）；
     播槽暂胜版随 commit 落库。病理档案≈动态台账 wave_st_progress.md 缺陷⑰段；PLAN §7 R11。
  6. **commit×2 已落库**：`1741806`（strings+memory x86 收口=缺陷⑯结案+⑫残余）/ `2b323f2`
     （slices arch 分片+缺陷⑰播槽暂胜版+病理）。

## 2026-11-01（开门日志·环境重建·三拍板）

> 用户指令「完成 stdplan」+ 三拍板：① derefTest 挂账后续专项（不进本波次）；
> ② 每收口一模块立刻 commit（CLAUDE.md 模块独立提交纪律沿用）；③ **Wave I 终波立项**
> （PLAN §4.7：现有波次收口后全库 imports 文件级迁移 + json 通道弃用；日志先写、边做边写）。

- **工作区盘点（未提交半成品=上代会话遗留）**：
  - Wave Mp：`pkg/maps/maps.cute` 已全量重写（泛型 [K] 单参数、开放寻址+墓碑、FNV-1a 手写 hash/eq、
    只 import memory=P7）；`test/_mp_probe`（自带 maps.cute 副本 fixture，非 std:maps 真挂载）；
  - Wave T：`pkg/sort/tim.cute`（string 行族）+ `tim_x86_64.cute` / `tim_x86.cute`（int/uint 特化族）
    未跟踪新文件；`api.cute` 已改路由 timSortIntsImpl/UIntsImpl/StringsImpl；`pkg/sort/test` 加缺陷⑪绕行
    direct caller（strings.count）+ package.json 显式 import strings；
  - Wave F：`pkg/testing/testing.cute` 重写（assertEq/assertEqU/assertEqS 全局轨计数 +
    assertEqT/UT/ST T 轨 + NewT/Fail/Error/Equal/EqualStr/Passed）。
- **环境袭击**：/tmp/opencode 曾被清空（bin、e2e 脚本全失）。本会话重建：
  - `TMPDIR=/tmp/opencode go build -o /tmp/opencode/bin/main_s02f .`（工作区树编译器）
    + `git worktree add /tmp/opencode/base HEAD` → `/tmp/opencode/bin/base`（HEAD 干净对拍二进制）；
  - `/tmp/opencode/run_e2e.sh <repo相对目录> <bin>` / `run_e2e_x86.sh`（x64 elf64 / x86 elf32+-m32 gcc）；
  - `/tmp/opencode/run` → repo 符号链接；脚本把关汇编（nasm -w-label-redef-late）与链接失败信息落
    /tmp/opencode/last_{compile,nasm,link}_err.txt。
- **HEAD 实测 regard 表（摸底首发现）**：`test/derefTest` 双 arch **编译级挂**（base 二进制同挂=非工作区引入）：
  - x64：NASM `std_strings_count not defined`——缺陷⑪病理同型：derefTest 仅 json-import memory；
    builtin 根自动导入链把 strings 全量加载 → arch 文件（strings_x86_64.cute splitN）整体拉进二进制，
    splitN 体内 `strings.count` 发出 call 但 common def 绑定缺席（direct caller 无→间接连带面缺 def）——
    pkg/sort/test 同款，绕先例=farm package.json 显式 import strings；
  - x86：compile 段 Go panic——`cdecl.go:120 needExtend 判定 arg.Type==nil`（exp.leaf→x86 Call 链），
    同链发射段 nil Type 面。**处置：挂账后续专项 ❗derefTest**，本波次哨兵清单剔出绿承诺。
- **本会话执行表**：哨兵矩阵摸底 → Mp 收口（test/mp_map 真挂 std:maps + template 切包 + git rm hashmap）
  → T 收口（sort 哨兵+timsort 对拍 farm+esccheck R2）→ F 收口 → docs 补账；每模块独立 commit。
  全程本文件边做边写。

- **执行表第 1 步：哨兵矩阵摸底（2026-11-01 下午，复跑三连确认）**：
  - **首跑全红异常与根因定位（缺陷⑪全局面）**：首跑 x64 仅 slice_test/sortStrOnly/pkg-strings 通过，其余全 NASM `std_strings_count not defined`；x86 仅 pkg-strings 通过，其余 compile 段 `Cdecl.Call arg.Type=nil` panic（cdecl.go:120，exp.leaf:546 链）。
    - **三重取证**：① base（HEAD 编译器）同挂 rctest；② 纯 HEAD worktree（/tmp/opencode/base 源树）rctest x64 同样 NASM 挂——**非工作区引入，HEAD 即痛**；③ 提交点考古：40d2089 / 2b323f2 / 749a91a 三点各自自建编译器复跑全部同红——**10-31 记录的「x64 六 farm 全绿 / 23 项矩阵」在该状态不可复现=日志漂移第三处**（sprobe01 前二）。
    - **根因（缺陷⑪病理定案）**：std 包文件体内的**自/对等命名空间调用**（strings 内部 `strings.count`、console 内部 `syscall.write`）依赖根 farm 的别名表解析——farm 未显式 import 该包时：Check 期不标 Useful → x64 **def 缺失**（NASM 符号未定义）；发射期 BindDanglingCall 兜底补绑后**签名面不齐**（参数 Type 未适配）→ x86 **Cdecl.Call panic**。双 arch 双症状同一根因。
    - **决定性实验**：rctest 补显式 `strings: std:strings` 单行 → x64=60 / x86=60 双 arch 全绿，理论闭环。
    - **处置（与 40d2089「farm 显式 import 补录」先例同构）**：批量补录 `strings: std:strings` 至受影响 farm package.json——rctest/gcfree/gcfree2/rcSimple/complexTest/m5/map_test/slice_minimal/sliceTest/negIdx/sortMinimal/sortMinimal2/sortQuick/sortIntOnly/pkg/slices/test/derefTest 共 16 项；**derefTest 解除挂账**（补录后双 arch rc=7=历史挂账值全等，❗支线池撤销改已结案）。
  - **复跑后的开工基线（x64 全绿 / x86 分族）**：
    - x64（22 项）：rctest=60｜gcfree=60｜gcfree2=0｜rcSimple=12｜complexTest=17｜m5=7（7 项 struct 审计全过）｜map_test=0｜slice_minimal=0｜slice_test=0｜sliceTest=0｜negIdx=48｜sortMinimal/2/Quick/IntOnly/StrOnly=0｜pkg/slices/test=230｜pkg/strings/test=42｜derefTest=7；❗sortTest=**139**（基线 110，SEGFAULT——归 Wave T 收口体）。
    - x86（12+ 绿）：rctest=60｜gcfree=60｜gcfree2=0｜rcSimple=12｜complexTest=17｜m5=7｜map_test=0｜sliceTest=0｜negIdx=**32**（x86 独立确定性 UB 值，x64=48 分 arch 记基线）｜slices/test=230｜strings/test=42｜derefTest=7。
    - x86 预存红面（**10-31 仅六 farm x86 绿记录相容**，非新回归）：① slice_minimal/slice_test/sortMinimal/2/Quick/IntOnly x86 NASM `operation size not specified`——pkg/console 全局量（STDOUT_FD/ESC）push 缺 dword 尺寸=**x86 全局 push 代码gen缺陷（预存，console 2026-09 后未改动）**，记支线池；② sortStrOnly/sortTest x86 COMPILE panic（nil Type 链）=Wave T 收口体领域。
  - **哨兵清单修订**：sprobe01 目录**repo 缺失**（10-31 记录漂移二处）→ 从矩阵剔除，不重建（主人探针族素材不属本波次）；矩阵口径=22 项。
  - 结论：**开工基线成立**（x64 全备 + x86 十二绿 + 红项分族挂账），Wave Mp/T/F 按此推进；sortTest(139/x64) 与 x86 排序面红项=Wave T 验收面相应承担。

- [ ] C1–C7 分批提交：BindDanglingCall/context/compiler.go、setArgsOffset、ops.go 六根因、sort.cute、api.cute、stdplan 文档
- [ ] (**已降级为非阻断**) console.println stdout 复验——用户裁定 2026-10-30：验收面=编译器核心+M/S/St/Mp 四模块，上层 stdlib 不作保证（println 归上层，仅定性记录）
- [x] **门禁③ for_28 triage ✅ 2026-10-30**（main_s01 + gdb 复现，bt 链与历史一致）：
  1. **崩点定位**：`for_28`（ForBegin 循环标号）实为 **`std_slices_set__T__int`** 函数内的逐字节拷贝循环（`_pd/_ps` elem 步进，`movzx rax,BYTE [rbx]`）；asm 行级：`mov RAX,[rbp-64]`（参数2=值10 载入）→ `_ps=10+i` → 从**地址 10** 读字节 → SIGSEGV（gdb #2 的 new 归属是符号缺失下的最近符号误判，set 才是真归属）
  2. **根因（独立缺陷，非两制并存同源）**：`pkg/slices/slice.cute` L84 `fn set[T](s *[]T, index int, src ptr)`——**第三形参是 `ptr`**（低级字节源指针契约），而 `test/slice_test/main.cute` 传 `slices.set[int](s, 0, val)`（int 值 10 直传）→ 值当指针 → 野地址解引。编译器侧无 bug
  3. **修复路径**：归 Wave S——slices.cute 重写时 set 改按值签名 `set[T](s *[]T, index int, v T)`（或调用方改传 &src，由 S0-3 一并统一）；不进 S0-2 编译器改动面
- [x] **S0-1 bounds check 解引修复 ✅ 2026-10-30**（读路径 helper 嵌入 + 写路径死代码发现与 gate-revive；`thisMem` 合流复用）：
  1. m1=2（值语义不回归）/ **m2a=2（修复目标：历史必 panic 的 self.data 只读）** / m2a2=2（Box2 非零偏移 data@8 校准，fieldOffsetOf self 链正确）/ m2b=2（别名）/ m2set=2（写路径）/ **m2oob=1+panic、m2a2oob=1+panic（OOB 正确拦截=bounds 真醒）**
  2. complexTest：旧 main=1（复现 panic）/ 新 main_s01=**17=1+6+10 语义正确值**（Matrix.get/set 三读数）✓ 解禁
  3. 13 绿哨兵现存 10 目录双二进制**逐位全等**（rctest=60、gcfree=60、gcfree2=0、derefTest=7、rcSimple=12、slice_minimal=0、slice_test=139（已知栈耗尽，前后一致=零回归）、sortMinimal/2/Quick=0）；castmalprobe/probeC/oldprobe 沙盒已删
  4. asm 行级：`cmp [rbp-48+8]` → `mov RBX,[rbp+-48]; cmp [RBX+8]`——bounds 与元素加载解引同形，两轨合流
  5. **新发现（写路径 bounds 死代码）**：indexSet 的 bounds 代码历史写进局部 code 遮蔽、从未并入返回值——写路径越界零保护（数组分支同缺陷，本波未动，记录待 S0-2 处理）；gate-revive 仅指针链（heldBase≠nil），值语义逐位不变
- [x] **S0-2 shape 基建（P11 编译器通道）✅ 2026-10-30**（独立二进制 main_s02，main/main_s01 基线不动）：
  1. **type/list.go 破冻（R6 最小 diff）**：ListType 挂 `shape *StructType` 字段 + `Shape()` 懒构造（`NewStruct("sliceHdr", [data:*T, len:uint, cap:uint])`，Layout 自然算偏移）；`Size()/Alignment()` 同步委托 shape（x64 8+8+8=24 / x86 4+4+4=12 与原字面量逐位等价验证）；**未动 type/struct.go**
  2. **exp.go 查表化收口**：`listHeaderShape()`/`listShapeField()` helper（进程内单值缓存）；`listFields()`/emit3/emitZero3 查表化（10 个 listFields 调用点全部查表）；grep 审计追加 **5 个残余 2*ps 直算点全部收口**（concatExp 双分支 / 容器参数传递 x64+x86 / slices.new 头搬运含 i*ps 循环 / builtinMake 结果装载）
  3. **listBaseResolve 全量合流（S0-2 核心）**：路由 = len≤1/值语义→passthrough；isThisField→thisMem（S0-1 已合）；**needPtrMem→ptrMem（新增：多指针装载层 + 全局 [rel] 基址）**；allocTmpReg 枯竭伪 ReturnReg 统一防线→passthrough。基址语义判定单点化——新链型必须在此加路由，禁 bounds/元素寻址两侧各自直拼
  4. **验证全绿**：M 7/7（m1/m2a/m2a2/m2b/m2set=2、m2oob/m2a2oob=1+panic）+ complexTest=17 + 10 哨兵双二进制 EQ（rctest=60/gcfree=60/gcfree2=0/derefTest=7/rcSimple=12/slice_minimal=0/slice_test=139/sort×3=0）+ **m1 双二进制 asm 逐位一致（唯一 diff=oob 随机标号跨进程必然不同）=查表化零 asm 影响铁证** + esccheck 红项全 0 且数值逐位等于基线（complexTest 对象=3/释放=2/转移=1 全同）
  5. **P11 收口度审计**：exp.go 容器头三字段算术**清零**；剩余 `2*ps` 全部位于 L2723+ sp 暂存区 = 调用序列 push 保护槽算术（**非** sliceHdr 布局知识，判定保留并记录）；索引/字面量/sliceExp/append/make/len/cap/清零/concat/new 头搬运/参数传递全部查表
- [x] **S0-3 ✅ 2026-10-30** slices.cute 迁 sliceHdr{p,n,c}（Go 序）+ set 契约改按值——S0 shape 基建三代目通关：
  1. **根因铁证（mono 残读端）**：BAD-READ 埋点实锤两类漏绑——①`hdr.p defType=16 defVal=other`（FIELD 基址走 exp.go L262 `Define.Path[0]`，remap 从未重绑）；②`bufSize defType=2 defVal=Var@(off=0)`（remap 只触达同语句的其中一份读拷贝，发射用另一份，其 Define 仍指原树 Offset=0）。原体被 `Useful=false` 抑制后从未 SetupVarOffsets → define Offset 恒 0 → 生成 `[RBP]/[rbp]` 读 saved-rbp → SIGSEGV。GOOD/BROKEN 真分母=原体是否在单态化前已被弱发射过
  2. **修法（addSpecializedFunc 深拷贝前原树补 Setup 三步）**：①原树身体类型补 subst（orig.Args TypeParam 保全，跨 [T] 重复推断不坏）②orig.Args.Offset 对齐特化体 ③`arch.SetupVarOffsets(origNode, StackAlignment, -(8*CsRegs)-argSave)`（argSave 取特化体实型 size）。幂等性：克隆体 Prologue 同式重算同序偏移，两边一致
  3. **验收**：slice_minimal=0（首绿）/ **slice_test=0（基线 139 栈耗尽 → 历史性通过）** / negIdx=48 三连稳定（负索引=确定性 UB，崩溃已治愈）
  4. **sort 族回归双根因连修**：①`new`→`make` 改名实验残留——sort 面的 `slices.new[int]` 被静默折叠成 `mov [rbp-48],RAX`（RAX=0）→ s=0 → push `[RBX+8]` 崩（**衍生发现：对未定义函数调用被静默折叠不发 call，记录在案**）；7 文件统一迁 make②pkg/sort 手写指针序契约脱节——sort.cute 4 处 `lenP=sAddr/dataP=sAddr+16` 旧序（len@0/data@16），S0-3 拍板 Go 序统一后 slices 包自身=Go 序、sort 包手写读 n=*data 指针→0x7ffffffff000 崩；4 处改 `lenP=sAddr+8/dataP=sAddr` 全数对齐
  5. **最终基线（23 项全数）**：sort 面全 0 + sortTest=110（pass*10+fail=11/0 全过，旧 7=旧布局假残值）/ sortIntOnly=0（旧 1 一并转正）/ sliceTest=0 / slice 三试绿 / 13 哨兵逐位不变（rctest=60/gcfree=60/gcfree2=0/derefTest=7/rcSimple=12/complexTest=17/m 族/m2oob=1/m2a2oob=1）+ esccheck 三目录红项全 0；instrument 埋点（monoDbg/MONO-REMAP/MONO-DEFS/BAD-READ）已拆除，gofmt 干净
- [x] 切片字段索引定性探针 ×4（A5 收口 2026-10-29）：
  - M1 字面量→字段→`b.data[i]` 直接索引 ✅（自洽）；M2a 方法内 `self.data[i]` 只读 ❌ panic；
  - M2b 别名化 `var t=self.data; t[i]` ✅ 绕过；M3 字面量头+`slices.push` 混用 ❌ segfault 139；M4 字段↔局部别名共享 ✅
  - **发现 A（实锤编译器 bug）**：`compile/exp/exp.go indexAccessGeneric`（L2218-2250 及 2396-2428 同构两处）bounds check 的 len 加载用 `VarAddr(exp.Right.Var)` 直接拼地址——成员链（`self.data`）时得到 this 槽位文本 `[rbp-48+0]`+lenOff=8 → `cmp [rbp-48+8]` **缺一层解引 this**（element 加载路径走 generate 有解引，仅 bounds check 漏）；值语义成员（局部 struct 的字段）直接拼恰好正确
  - **发现 B（架构，已并入 P11/S0）**：切片头布局一量两制——编译器全线 `listFields()` L1800 = ptr@0/len@8/cap@16（string 同布局），`pkg/slices/slice.cute` 手写 = len@0/cap@8/data@16；字面量头与 slices 函数混用即 segfault（push 把 cap 槽值 2 当 oldData 指针从地址 2 拷贝）
  - **拍板（用户 2026-10-30）**：slice 参考 Go 真定义结构体、编译器只做映射和展开 → v2.2 落 PLAN：切片头布局定 Go 序 data@0/len@8/cap@16（=现编译器序，撤销 A6 旧序）；新增 P11 类型视图铁律（裸偏移清零：stdlib 走 unsafe.cast+覆写结构体、编译器走 shape 字段查表、base resolver 合流条款化 A5 根因）；Wave S 前插 S0 shape 基建（布局不动=重构无行为变化，哨兵逐位不变验证）
- [x] **Wave M memory ✅ 2026-10-30**（§4.1 公开面三件 + §2.3 F1–F6 + memmove 提级 + 尾删 RCMARK + getenv 正名；main_s02 增量）：
  1. **公开面三件**：`calloc(n uint) ptr`（malloc+memset 0，探针实测零值守恒）；`ptrToStringHeader(p ptr) ptr`（NUL 串反构造 24B 头：len 扫 NUL、cap=len；返回 ptr——`*string` 返回形态无先例 defer）；strHdr 覆写视图（P8 镜像，Go 序 p@0/n@8/c@16）**定义在使用文件内**（`*strHdr` 跨文件 type 引用不可达实录——P4 再证）；memmove 提级=memmove_x86*.cute 自 slices 迁 memory、slice.cute 两点改 `memory.memmove` 点调用
  2. **F1 RC_BIT=4**（独立位标记，弃 0x18000 值域碰撞方案）：const.cute RC_BIT/FLAG_MASK 3→7、rc.cute flagStore 三处带上 RC_BIT、allocator free 判定 `(flags & RC_BIT)!=0`；mprobe 100KB LARGE 块 malloc/free 对穿验证
  3. **F2 memset 重写**（c==0 word 快径保留、c≠0 退 byte 循环）；F3 gDbgA-D 七处全删（allocator 3+rc 3+memory.cute 声明 4）；F4 brk 模型 LARGE/HUGE 中部滞留限制 + F5 泄漏表 256 条静默上限（计数守恒不变）+ F6 HUGE round8 对齐分别写进包顶注释
  4. **getenv 正名（P11 通道）**：syscall_x86_64 撤 `memory.ptrToStringHeader(path)+16` 悬空调用（编译器对未解析函数静默折叠实锤面）+ A6 旧序残迹，改包内 strView 镜像（P7 反向禁 import 下 P8 同形双证）+ `unsafe.cast` 两步读 p@0 → `open(sv.p,0,0)`
  5. **mp5 二分定位（新发现，未修，记录待台账）**：「跨文件 const · call-arg staging」缺陷面——`malloc(3 * ptrSize)` 中跨文件 const（registry SetPkgPath 定义体，Type=nil、Define 全空）物化进 call-arg staging（dest="QWORD [rsp+N]"）时 val()→VarAddr 撞 `GenVarAddr: nil type` panic。实证矩阵：同 const 于 VarDecl RHS（memops `n - ptrSize * words` 系）与同文件 ptr 算术（`blk - ptrSize`）历年全可；字面量左×const 右、const 左×字面量右双形态均炸（operand 序非关键）；汇编机制=val() IsConst 短路→立即数，否则 exp.Var→VarAddr，熔断点=exp.IsConst 未置位。**绕行形态纪律**：const 计算先落 VarDecl 中转（`var hb: uint = ptrSize * 3`）再传参——mp5/mprobe 双绿
  6. **验证**：23 项哨兵逐位零回归（rctest=60/gcfree=60/gcfree2=0/derefTest=7/rcSimple=12/complexTest=17/m1·m2a·m2a2·m2b·m2set=2/m2oob·m2a2oob=1/slice_minimal=0/slice_test=0/negIdx=48（确定性 UB 旧况）/sortMinimal&2&Quick&IntOnly&StrOnly=0/sortTest=110/sliceTest=0）；mprobe 5 点探针全绿（calloc 零守恒/ptrToStringHeader p·n 槽回读/slices push 链/100KB RC_BIT 对穿/mallocRC 生命周期）；esccheck 复检红项全 0（complexTest=对象 3/释放 2/转移 1 逐位同基线）
  7. **旧况裁定补证**：memoryTest rc=92（nasm `symbol malloc not defined`，test 内自建 malloc 死信）与 memSuite rc=3 经 base/main_s01/main_s02 三二进制对拍一致=波前旧况非本波回归（缺于哨兵清单不承诺修）；RCMARK 调试块（markRCFuncs CUTE_DEBUG_GLOB 打印段 L193-256）删除后 build OK 且 23 项零漂移，markRCFuncs 主体（rcNames walk+Useful 标记）保全
- [x] **Wave S slices 全套 ✅ 2026-10-30**（§4.2 全 suite；main_s02 增量）：
  1. **新面 15 函数**（pkg/slices/slice.cute）：grow（P2 曲线 cap<512→2×/≥512→+25%，target 取大）/pop/find/index/contains/equal/clone/copy/compact/reverse/insert/deleteRange/clear/cat/join（三参变体 a,sep,b）；**push 收敛走 grow**（原 push 内联 malloc/free 迁散）；**remove 契约升级 void→T**（返回被删元素，越界 UB 与 set/getPtr 同口径）
  2. **形态纪律沿袭**：sizeof 提 elemSize 局部（probe_gen5/6 铁律）、hdr/data 中转中转、memory.memmove 点调用；join 全用已验证原语（make+memmove 三段拼接，镜像 cat 形态）；index 独立体内实现非 find 代理（R3 mono 缓存规避）
  3. **join 拍板（前置探针谱系 spb8/9/10）**：spb8 sizeof[sliceHdr]()=24 ✓（P4 本地镜像形态）；spb9 `*[][]T` 泛型形参+跨包调用编译 ✓；spb10 嵌套字面量 `&[[1,2],[3,4,5]]` **parser 层拒绝**（`unexpected '['`）→ 真形 Join(colls *[][]T, sep) 无调用侧构造器 → 首选 fallback=三参 join 落地（pkg/slices/test 断言内证），真形延期记录
  4. **探针事故复盘（PROBE-INC，重要教训）**：spb1/2/3+sprobe01 首轮 rc=139 全系**测试代码缺 `i = i + 1`**——无限 push→几何级 grow→堆失控崩于 push 元素写（gdb：`mov [rbx],rax`@std_slices_push 的 end_if_128，rbx 页边界 0x41a000）；此前记录的「三二进制一致=成长悬空历史缺陷」为**假观测**（同一无限循环的三重复放，与 Wave S 改动无关），**「成长悬空缺陷」假设整体撤销**；反汇编定案=崩点在 push 写元素、非 grow 内部链，这一条才是把循环 bug 逼出来的关键一步；教条入册：**循环探针必须显式自增、rc=139 一律先查探针自身**
  5. **测试侧三修**（pkg/slices/test）：① 一行式 `if {} else {}` ×17 处 COMPILE_FAIL（`unexpected token: else`，语料沿用法=块体多行+`} else {` 行首）改规整形态；② pop 断言期待值 99→30（原期待把最近 set 的元素当尾元素，取尾部语义实为 30）；③ 补 clone+equal（深拷贝独立扰动）/copy(min(len)) 断言×4 + join 断言×2 → **21+2 断言 rc=210→230 全过**
  6. **S 尾删 PROBE-CAST**（exp.go leaf 悬空调用分支 stderr 探针 L532-541 删除，BindDanglingCall 主体保全）；DEBUG-LEAF（L540-545 异常门控探针）不在范围保留；rebuild 后抽检 sliceTest=0/complexTest=17/rctest=60/sprobe01=0/pkg230/spb10=91（延期证据本体），stderr PROBE-CAST/DEBUG-LEAF 命中 0=噪音消除
  7. **验证**：23 项哨兵复跑逐位零回归（全数同 M 基线：rctest=60/gcfree=60/gcfree2=0/derefTest=7/rcSimple=12/complexTest=17/m 族=2·1/slice_minimal=0/slice_test=0/negIdx=48/sort 面全 0/sortTest=110/sliceTest=0）；esccheck 复检红项全 0（complexTest=对象 3/释放 2/转移 1 逐位同基线）
  8. **记录面**：parser 不支持一行式 else（语言语法面非缺陷，语料规约=多行块）；嵌套字面量 `[[],…]` 不支持（真形 Join 延期前提，Wave St/Mp 若需在上层另行立项）；主人探针族 sprobe01/spb1–10 归档于 test/
- [ ] esccheck 全语料复验（W2 口径 115/87；覆盖五、六根因后端改动逐位对拍）
- [ ] 13 绿哨兵复跑基线
- [ ] Wave 0 尾：exp_check.go 还原

## 待办池（v2 · Wave 0 基线）

- [ ] C1–C7 分批提交：BindDanglingCall/context/compiler.go、setArgsOffset、ops.go 六根因、sort.cute、api.cute、stdplan 文档

## 待办池（v2 · 后续 Wave）

- [x] Wave M：memory 公开面（ptrToStringHeader/calloc/memmove 提级）+ F1 RC_BIT 修复 + F2 memset 修复 + F3 gDbg 清理 + F4/F5/F6 文档；M 尾删 RCMARK（**✅ 2026-10-30**，narrative 见上「Wave M memory」条目）
- [x] Wave S：slices grow/clone/copy/contains/… + sliceHdr 覆写 + push 走 grow；S 尾删 leaf PROBE-CAST（**✅ 2026-10-30**，narrative 见上「Wave S slices 全套」条目；join 三参变体落地、真形延期）
- [x] Wave St：strings split 族/Builder/compare/… + str 覆写（**✅ 2026-10-31**，双 arch rc=42 全绿、x86 首个收口 pkg；narrative 见上「2026-10-31（Wave St 双战线收口 + Wave S x86 分片追凶）」段）
- [x] Wave N（撤销=并入 Wave L）：build align(N)/noalign 已随 L 波落地（parser/build.go align case+attachPendingAlign；type/struct.go Layout pack 分支；test/align 全绿，见 2026-10-29 Wave L 段）
- [ ] Wave Mp：maps 泛型重写（只依赖 memory，开放寻址+墓碑）+ 删 pkg/hashmap + text/template 切 std:maps
- [ ] Wave T+F：真 timsort（minrun/run/归并栈）+ testing.assertEq
- [ ] Wave I（终波）：imports 全量文件级迁移 + json 通道弃用（PLAN §4.7，**拍板 2026-11-01**）

## 支线池（插空，不入波次）

- [x] ❗derefTest 双 arch 编译挂（2026-11-01 实测，HEAD 即挂→**同日结案**）：根因=缺陷⑪全局面（farm 未显式 import strings → x64 def 缺失 / x86 nil Type panic）；farm package.json 补录显式 import 后**双 arch rc=7=历史挂账值全等**，挂账撤销 ✅
- [ ] ❗x86 全局 push 代码gen缺陷（**2026-11-01 矩阵摸底新记**，预存非回归）：全局量（如 pkg/console STDOUT_FD/ESC）作为 call 实参 push 时缺 dword 尺寸前缀 → NASM `operation size not specified`（slice_minimal/slice_test/sortMinimal/2/Quick/IntOnly x86 全体预存红；console 2026-09-22 后未改动=历史遗留）；Wave T 收口排序面 x86 时一并考虑（sortMin 族 farm 依赖此路径）
- [ ] `||`/`&&` 链缺陷（recursion 53→51）：参数版 vs 字面量版判别探针 ×4
- [ ] 139 簇其余：rcTracking/stringsUtils/sliceTest（栈耗尽定性，先量 rsp 距离）
- [ ] structMethod=45
- [ ] console.println 输出链修复专项（R1，含 setCursorPos）
