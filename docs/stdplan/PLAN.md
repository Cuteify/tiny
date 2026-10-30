# stdlib 重构规划 v2（参照 Go 设计）

> 状态：**v2.2**（2026-10-30）。v1 → v2 变更：① 用户架构铁律固化（依赖方向 / 结构体表示 / build 对齐控制）；
> ② 内存管理器结构审阅结论并入（§2）；③ 三个决策点拍板（波次顺序 / W5 随手清 / hashmap 删包）。
> v2.1 变更：④ 波次顺序微调 + import 五形态定案。
> v2.2 变更：⑤ **切片头布局改 Go 序**（v2.1 的 len@0/cap@8/data@16 撤销——user 定案「slice 参考 Go，真的
> 定义结构体，编译器只负责映射和展开」，Go runtime.slice/reflect.SliceHeader = data@0/len@8/cap@16，
> 与现编译器 `listFields()` 及 string 布局天然同构）；⑥ **P11 类型视图铁律**（裸偏移清零：stdlib 一律
> unsafe.cast 到覆写结构体、编译器一律 shape 字段查表）；⑦ Wave S 前插 **S0 shape 基建**；
> ⑧ Wave 0 门禁 ④ A5 探针收口（谱系见 PROGRESS.md）。
> SSOT：本文件 = 规划；`PROGRESS.md` = 实时执行日志。
> 上游决策：用户 2026-10-29 指示「好好规划和实现 memory、slice、string、map 等，参考 go」（v1 起点）；
> 同日追加：「string 和 slice 单向依赖 memory，反过来说没有依赖的，map 也同理；各种数据结构尽量使用
> 结构体表示；结构体可以用 build 关键字设置不对齐或者对齐宽度，struct 做的时候参考这个数据，
> 这样就可以实现自己的 unsafe 获得类型版本」。

---

## 0. 结论先行（TL;DR v2）

1. **依赖方向铁律（新，P7）**：
   - `memory` 只 import `syscall`（现状已成立）；**memory 的依赖里永远不得出现任何 stdlib 包**；
   - `slices` / `strings` / `maps` 同层：**只依赖 memory，容器之间零横依赖**
     （maps 的 string 键 hash/eq 手写实现，不 import strings）；
   - L3 上层（sort/console/fmt/io/testing…）沿 Go 方向纵向叠加，不受此条约束。
2. **结构体表示（新，P8）**：内置 `string` = 24B（ptr@0/len@8/cap@16）、切片头 = 24B
   （**v2.2 拍板：data@0/len@8/cap@16，参照 Go，与 string 同构**）；strings/slices 各自定义**非泛型覆写结构体**获得类型化视图
   （自己的 unsafe 获得类型版本）；**泛型结构（maps 条目）在泛型 struct 落地前 = 裸 ptr 手工寻址**
   （A5 已收口 2026-10-30：缺陷谱系与两处实锤发现见 PROGRESS.md；执行纪律见 P11 裸偏移清零）。
3. **语言设施前置（拍板：先把 import 和 align，然后再重写 stdlib）**：
   - `build align(N)` / `noalign`（P9）：build 关键字设置结构体「不对齐或对齐宽度」，`Layout()` 参考该数据
     （pack(N) = min(自然对齐, N)，noalign = align(1)）；默认路径逐位不变；
   - `import` 关键字（P10）：依赖声明从 package.json 迁到文件顶层（参考 Go），json 降级为纯包信息；
   - CUTE_ROOT：std 根解析 = 环境变量 → 编译器本地兜底，替代 Getwd。
4. **波次顺序（拍板 v2.1；v2.2 增补 S0）**：`Wave 0 门禁 → L 语言设施(import+align+CUTE_ROOT) → M memory → S slices（S0 shape 基建先行 → 全套） →
   St strings → Mp maps → T timsort + F assertEq`；
   **W5 探针删除改为各 Wave 尾部随手清**（不设独立阶段）；**hashmap 删包**（不做薄壳），
   text/template 切 std:maps。
5. **内存管理器结构审阅完成**（§2）：分层健全、60 class 分级空闲链表 + boundary tag + RC 族，
   发现 6 项问题——3 修（RC_BIT / memset / gDbg 清理）进 Wave M，3 项文档化。
6. 沿用铁律：`parser/*`、`compile/gc/*`、`type/struct.go` 冻结（Wave L 有限破冻，见 R6）；
   失败铁律（零候选/多候选保守不绑）；esccheck 不变列（泄漏释放=6 · 泄漏=0 · 提前释放=0 · 转移=22）
   对后端改动逐位不变；编译/运行只在沙盒 /tmp/opencode/run。

---

## 1. 现状盘点（事实，2026-10-29 全库审计）

### 1.1 包清单

| 分层 | 包 | 规模 | 注 |
|---|---|---|---|
| 内存 | memory | 66 fn / 1160 行 | 分层分配器(Tiny/Small/Middle/Big) + RC 族 + 泄漏追踪，**最厚实**（§2 审阅） |
| 集合 | slices | 20 fn / 195 行 | `len/cap/new/_elemPtr/push/free/copyOut/set/getPtr/remove` + memmove/load/store 助手 |
| 集合 | sort | 20 fn / 459 行 | 公开: `insertionSortInts/qsortInts/insertionSortStrs/qsortStrs`；缺 timsort；**Phase A api.cute 已落地** |
| 集合 | hashmap | 11 fn / 198 行 | 非泛型（string 键 ptr 值）、链地址、FNV-1a、cap=2 幂 → **Wave Mp 删包** |
| 集合 | maps | 4 fn / 71 行 | keys/values/hasKey/len —— hashmap 助手层 → Wave Mp 重写为独立泛型包 |
| 文本 | strings | 78 fn / 1799 行 | 含 `toCstring`（第四根因悬空陷阱源），覆盖度最全 |
| 输出 | console | 92 fn / 908 行 | `println` 输出链疑有 bug（sortDbg 实证，勿依赖 stdout） |
| 空壳 | archive/compress/container/encoding/index/text | 0 | 目录在、源码无 |

### 1.2 跨包调用失配表（9 处，全库 109 调用点审计）

| 失配调用 | 调用方 | stdlib 现状 | 归属 |
|---|---|---|---|
| `sort.quickSortInts` ×1 | test/sortIntOnly | 无（实为 qsortInts） | Phase A ✅ |
| `sort.quickSortInts` ×3 | test/sortTest | 同上 | Phase A ✅ |
| `sort.quickSortStrings` ×1 | test/sortTest | 无（实为 qsortStrs） | Phase A ✅ |
| `sort.insertionSortStrings` ×1 | test/sortTest | 无（实为 insertionSortStrs） | Phase A ✅ |
| `sort.timsortInts` ×5 | test/sortTest | 无（stdlib 从未有 timsort） | Wave T |
| `sort.timsortStrings` ×1 | test/sortTest | 同上 | Wave T |
| `sort.compareStrings` ×2 | test/sortTest | 无（内部 `_strCompareStrs`） | Phase A ✅ |
| `memory.ptrToStringHeader` ×1 | pkg/syscall/syscall_x86_64.cute:123 | stdlib 自引用悬空 | Wave M |
| `console.setCursorPos` ×1 | test/console_adv | console 未实现 | R1 专项 |
| `testing.assertEq` ×1 | test/sliceTest 等 | testing 未实现 | Wave F |

> 语料考古佐证：`pkg/sort/test/gc_summary.json` 旧工件含 FuncBlock 快照
> `/…/pkg/sort.quickSortInts` + `_quickSortIntsRange` —— 测试写自更老调库代际；本仓初始提交即 q* 命名。

### 1.3 依赖方向审计（v2 新增）

| 边 | 现状 | v2 处置 |
|---|---|---|
| memory → syscall | ✓ 唯一依赖（package.json） | 保持；铁律固化 |
| memory → 任何 stdlib 包 | ✗ 无（全库 grep 无 std:slices/strings/maps 引用） | 铁律：永不出现 |
| slices → memory | ✓ | 保持；**自带 memmove_x86_64.cute 属越层实现 → Wave M 提级进 memory**，slices 留薄转发 |
| strings → memory | ✓ | 保持 |
| maps → hashmap + memory | 助手层双包分裂 | Wave Mp：hashmap 删包，maps 只 import memory |
| hashmap ← text/template | 唯一外部用户（另一个是 maps 自身） | Wave Mp 切 std:maps |
| sort → slices/memory | api.cute 双形状（切片族 + 裸阵列族 ptr,n） | Phase A ✅；Wave T 真 timsort |
| 包引用通道 | package.json imports 唯一声明（**包级粒度**，P7 无法机器验证） | Wave L：源码 `import` 关键字（文件级，P10）+ json 降级纯元数据（imports 字段兼容保留） |

### 1.4 编译器现状（与 Wave L 相关）

- `build` 现仅支持 **asm / ext / extret / os(...) / arch(...) / link(...)** 六形，且**只能挂在函数上**
  （parser/build.go：ext/link 挂非函数直接报错；os/arch 挂非函数静默无效）；
- 顶层 `build os/arch` 作用于**紧随其后的函数**（parser/func.go L209-217 附加模式）；
- 结构体字段布局唯一来源 `type/struct.go Layout()`：字段 alignment = 字段 Size、padding 补齐、
  RAlignment = max——**该文件在冻结清单上**（Wave L 有限破冻，见 R6）；
- **包引用现状**：lexer 无 `import` 保留字；依赖声明唯一通道 = package.json `imports`
  （package/package.go `GetPackage` 无条件读取，文件缺失即报错——沙盒新测试目录必须 cp package.json 的根源）；
  `std:` 解析绑死 `os.Getwd()`（`Getwd()/pkg/…`，工作目录必须是仓库根）；
  别名消费点：解析后 `fixPkgNamePaths`（包级 Info.Imports）→ Check 阶段 `Name.FixPath` → autoImport 兜底。

---

## 2. 内存管理器结构审阅结论（v2 新增）

### 2.1 分层与职责

| 文件 | 职责 |
|---|---|
| `const.cute` | 分级常量：TINY≤1024 / SMALL≤4096 / MIDDLE≤65536 / LARGE≤256K / HUGE；CHUNK_SIZE=64KB；IS_FREE=1 / PREV_FREE=2 / FLAG_MASK=3 |
| `memory.cute` | 全局调试寄存器 gDbgA-D + `sizeof[T]()`（`build link("__memory_sizeof")` 链接提供者） |
| `memory_x86_64.cute` / `memory_x86.cute` | arch 原语：hdr/footer/RC/flags/空闲链表访问器，已全部类型化指针化（load8/store8 族废弃） |
| `allocator.cute` | 分配核心（下述） |
| `rc.cute` | RC 族：rcInc/rcDec(归零自动释放)/rcGet/rcTryRelease/rcIsOne/rcSet/rcAdd/rcSub |
| `tracker.cute` | 泄漏表：256 条线性表 + alloc/free 计数（brk 直配不走 malloc） |
| `memops.cute` | memcpy/memset：8B 快拷 + byte 尾巴 |

### 2.2 块布局与路径

```
malloc 块:  [header: size|flags][data ...][footer: header 副本]   开销 2×ptrSize，用户 ptr = blk+8
RC 块:     [header][RC][flags][data ...][footer]                 data 前缀 3×ptrSize，最小块 5×ptrSize
free 块:   next@data+0 / prev@data+8（复用 data 区，最小块 4×ptrSize）
```

- class 体系：tiny cls 0-33（32B 起 12.5% 递增、步进 ≥16B、对齐 8）/ small 34-35（2048/4096）/
  middle 36-59（4096 起 12.5%）/ LARGE：brk 直配 + coalesce / HUGE：brk 直配不回链；
  `commit` 每次 brk +64KB 切等块入链。
- `malloc` 三路：HUGE 直 brk / LARGE brk+coalesce / TINY-SMALL 走链表（空则 commit）；
- `free` 运行时分流：`flagLoad(ptr) == IS_RC_TAG(0x18000)` → rcDec，否则 `freeAt(ptr−ptrSize)`；
- `realloc`：原地吃下一空闲块，否则 malloc+memcpy+free；收缩不拆块。
- `coalesce`：向后合并 + 经 PREV_FREE/footer 向前合并，维护后继 PREV_FREE 标记。

### 2.3 问题清单与处置

| # | 问题 | 证据 | 处置 | Wave |
|---|---|---|---|---|
| F1 | **IS_RC_TAG(0x18000) 与真实块大小碰撞**：非 RC 块的 ptr−8 即 header，header 原始值=纯大小；用户 size 98281–98288 → LARGE 路径对齐后纯大小恰= 98304=0x18000 → `free` 误判为 RC 块走 rcDec → rcLoad(ptr−16) 读到前一块 footer（垃圾），轻则计数写坏、重则 freeAt(ptr−24) 释放错块 | allocator.cute `free()` × const.cute `IS_RC_TAG`；LARGE 路径 `aligned = round8(size+16)` | 加第 3 位 **RC_BIT=4**、FLAG_MASK 3→7；mallocRC 的 header 带上 RC_BIT；`free` 改判 `(flags & RC_BIT) != 0`；FLAG_MASK 扩位后 `& ~FLAG_MASK` 取纯大小路径全部兼容，<64KB 块行为逐位不变 | M |
| F2 | **memset word 路径恒写 0**（c 只作用于 byte 尾） | memops.cute `memset` 注释自认 | c==0 快路径保留；c≠0 时 word 值按 c 广播（或整体退 byte 循环），stdlib 全在清零用途所以至今未踩 | M |
| F3 | gDbgA-D 调试写散布在 malloc/free/coalesce/rcDec 热路径，无观察者 | allocator.cute / rc.cute 多处 | 删除（纯库改动，编译器零 diff，语料行为不变） | M |
| F4 | HUGE/LARGE 的 free 只在堆顶回收（否则无空闲链表，空间滞留） | allocator.cute `freeAt` | 文档化为 brk 模型固有限制 | M（文档） |
| F5 | 泄漏表 256 条上限静默丢弃 | tracker.cute `trackAlloc` | 文档化；参数化另期 | M（文档） |
| F6 | HUGE 路径 header/footer 未对齐（req 未 round8，x86 无害） | allocator.cute `malloc` HUGE 分支 | 顺手统一 round8 | M |

> 总评：分层（L0 syscall ← L1 memory）与依赖方向健全；分级器/双 boundary tag/coalesce 设计正确；
> v2 公开面重写**不动分配核心**，只做 F1/F2/F3 修复与 F4/F5/F6 文档。

---

## 3. 设计原则

v1 P1–P6 保持（P1 RC 布局 `[header][RC=p−2·ptrSize][flags=p−ptrSize][data][footer]` 与
esccheck 抓取口径不动，RC 即终态；P2 growslice 曲线 `<512→2× / ≥512→1.25×`；
P3 泛型走现成 monomorphize；P4 命名 camelCase 对齐 Go 语义与参数序；P5 零候选/多候选保守不绑、
ok 形态不 panic；P6 exit-code 哨兵、R1 修好前禁 stdout 断言）。v2 新增：

- **P7 依赖方向铁律**：L0 syscall ← L1 memory ← L2 slices/strings/maps（同层零横依赖）
  ← L3 sort/console/fmt/io/testing…。反向禁止：memory 不得 import 任何 L2/L3 符号
  （`sizeof[T]` 是编译器内建 link，不算依赖）。新增包必须先声明所在层。
- **P8 结构体表示与覆写规则**：

  | 目标 | 覆写结构体 | 布局（必须与内建一致） |
  |---|---|---|
  | string | `str { p: ptr; n: uint; c: uint }`（strings 包定义） | 24B：p@0 / n@8 / c@16（= 内建 BTString：ptr+len+cap，bt.go + exp.go literal cap=align8(total+1)−1 双证） |
  | 切片头 | `sliceHdr { p: ptr; n: uint; c: uint }`（slices 包定义） | 24B：p@0 / n@8 / c@16（**v2.2 拍板：参照 Go runtime.slice/reflect.SliceHeader= data@0/len@8/cap@16**，撤销 v2.1 的 n@0/c@8/p@16（A6）；与 `str` 同形同序——三槽寻址/参数交付/零值清零保持同一套机器） |
  | maps 条目 | 裸 ptr + 手工寻址（泛型 struct 未证实前） | 桶块 = 单块 malloc，条目 i = base + i×slotSize（白名单见 P11） |

  规则：覆写结构体只做内建形状的**再解释**，不自创形状分叉；A5 定性收口前，
  结构体内部**禁止切片类型字段**（现存代码一律裸 ptr 字段替代）。
- **P9 build 对齐控制（Wave L）**：
  - 语法：`build align(N)`（N≥1）/ `build noalign`（= align(1)），作用于**紧随其后的 struct 定义**
    （复用 func.go「顶层 build 作用于紧随其后函数」的附加模式）；
  - 语义：pack(N)——字段有效对齐 = min(自然对齐, N)，padding 按此计算；
    RAlignment = min(字段自然对齐最大值, N)；RSize = 最终 offset；
  - 兼容：不带标记的结构体 = 现行为**逐位不变**（哨兵：structMethod / complexTest / 139 簇对拍）；
  - 价值：小字段桶密度（u8 tophash、位打包）、用户「自己的 unsafe 获得类型版本」的通用能力；
    不影响 str/sliceHdr 覆写（纯 8B 字段布局相同）。
- **P10 import 关键字（Wave L；拍板：json 只管包信息，依赖声明上文件顶层、参考 Go）**：
  - 语法（别名与 Go 完全一致）：
    ```
    import "std:memory"                    // 单条
    import mem "std:memory"                // 前缀别名
    import _ "std:sideeffect"              // 空导入（仅加载注册，不绑名）
    import (                               // 分组
        "std:memory"
        str "std:strings"
    )
    ```
    路径一律带引号字符串；`.` 点导入 defer（R10）；
  - **五形态判别（按冒号位置切分，零启发式；定案）**：

    | import 写法 | 判别 | 来源 | 解析 |
    |---|---|---|---|
    | `std:…` / `ext:…` / `api:…` | 冒号前 ∈ 官方前缀 | cuteify 官方：std=标准库本体、ext=标准库扩展、api=其他语言 API 绑定；**均为逻辑源，后续映射指定 git 仓库** | std→`CUTE_ROOT/pkg/…`（未设→编译器本地兜底）；ext/api 一期本地目录占位 |
    | `tiny:lib/foo` | 冒号前 == 根包 `"name"` | **项目顶层相对**（name/module 合一：根 package.json 现有 `name` 字段即顶层命名空间，不新增 module 字段） | 项目顶层目录相对 |
    | `:github.com/xxx/xxx` | **冒号在最前**（无名字、无协议） | **第三方库**——参考 Go 模块路径形态，前置 `:` 作标记 | 一期 `vendor/<冒号后路径>` 优先，未命中报错；二期远程拉取+缓存 |
    | `./x` `../x` `/abs` | 路径符开头（**本地文件没有冒号**） | 本地目录相对 / 绝对 | 沿用现 json 相对路径语义 |
    | `mylib:…` 未知名冒号 / 裸短名 | 其余 | **非法，报错** | 纪律：`X:` 命名空间保留给官方前缀与项目名；第三方用前置冒号；本地用路径符；裸短名永不合法 |

  - **模仿包归类标准**（前缀体系进货渠道，非新前缀）：语义重实现+核心稳定→`std:`；
    实验/外围/平台耦合→`ext:`；透传绑定（直接调外部库不改语义）→`api:`。
    现状落位候选：pkg/thread 内 pthread asm、test/runtime mmap 绑定 → 未来 `api:pthread`/`api:mmap`
    （thread 包本体保持 std:thread 封装层）；
  - 机制：文件级导入表（挂 Parser，解析完该文件即被 fixPkgNamePaths 消费）→ 查表序
    **文件级 import 表 → 包级 json Imports（兼容轨，旧语料不动）→ autoImport 兜底**；
  - package.json 降级为纯元数据（name/version/builtin/action）；`imports` 字段保留兼容；
  - **P7 变为机器可验证**：grep 各包 `^import` 的前缀集合即审计横依赖（maps 文件内不得出现 std:strings）；
  - CUTE_ROOT：环境变量指定根，未设则找编译器本地（可执行文件旁）——替代 Getwd，
    砍掉沙盒 cp pkg 痛点；单独哨兵验证；Windows 盘符 `C:/` 冒号冲突边角备案（一期 Linux 不涉及）。
- **P11 类型视图铁律（用户定案 2026-10-30）：裸偏移清零**。
  用户原则原文：「尽量让所有类型操作避免使用裸偏移，应该有 unsafe 和结构体，这样更好维护」。
  凡布局敏感的类型操作，禁止 `cast[ptr](x) + 16` 式裸偏移算术，一律走两条类型通道：
  - **stdlib 通道**：`unsafe.cast[T]` 到覆写结构体（`sliceHdr` / `str`，P8 表）后按**字段名**访问。
    布局知识收敛到覆写结构体一处定义；改名/换序只动它，全库跟随。
    slices.cute 现有 `len/cap/new/_elemPtr/push/free/copyOut/set` 手工寻址在 Wave S 内全部迁移；
  - **编译器通道（S0，Wave S 前置）**：内建容器形状显式化为 StructType 形状——ListType 挂 shape
    （`data: *T`@0 / `len`@8 / `cap`@16，Go 序），展开点（`a[i]` 读/写、`[]T{...}`、`a[lo:hi]`、
    append/copy/make/len/cap/ZeroVar）一律经 shape 字段查表取偏移，不得再手写 `+0/+8/+16` 字面数字
    （现状 `listFields()` 8 调用点 + `emit3`/`emitZero3` 全部查表化）；
  - **基址解析合流（A5 教训条款化）**：成员链基址（`self.data` 等）的解引机制收敛为单一 base resolver
    （值语义局部→栈地址直拼；指针成员→解引 pre + 偏移捆绑，复用 thisMem/ptrMem 已有机制），
    bounds check 与元素寻址**共用同一条解析路径**。根因教训：现 bounds check 用 `VarAddr` 文本直拼
    偏移而元素加载走 `generate` 解引，两轨分叉（exp.go indexAccessGeneric L2218-2250 /
    indexSet L2410-2428 实锤，M2a panic 复现）；
  - **裸寻址白名单（收窄至最小集）**：① maps 桶块条目寻址（泛型 struct 未落地前，P8），封装在每包
    最小助手集内（_elemPtr 式）不外溢；② 编译器内 `unsafe.cast`/`sizeof` 内建本体；
    ③ memory 包现状手工寻址（Wave M 落地后按 P11 择机迁移，不阻塞）；
  - **执行顺序**：S0 先行于 §4.2/§4.3 stdlib 重写——否则重写踩在「编译器伪 string 布局 vs slices
    旧 len@0 布局」两制并存的地上（M3 segfault 实证：字面量头 + slices.push 混用）；
  - **红线关系**：S0 需 typeSys 接点（ListType 挂 shape）——`type/struct.go` 手改红线按 R6 模式
    申请有限破冻，改动量级与 Wave L 的 Align 接点相当。

---

## 4. 逐包规划

### 4.1 memory（Wave M）✅ 2026-10-30

公开面（v1 表保持）+ 修复三件（§2.3 F1/F2/F3）+ memmove 提级 + 文档两件（F4/F5）：

| 新增/动作 | Go 参照 | 说明 |
|---|---|---|
| `ptrToStringHeader(p ptr) ptr` **✅** | runtime 反向构造 | syscall 悬空点正名落地：NUL 串反构造 24B 头（len 扫 NUL、cap=len）；返回 ptr——`*string` 返回形态无先例 defer，调用方按 P8 表 cast 完成 *string 语义 |
| `calloc(n uint) ptr` **✅** | malloc_zeroed | malloc+memset 0（容器零值初始化常用；mp2 探针实测零值守恒） |
| `memmove(dst,src,n)` **✅** | runtime.memmove | 从 slices 收编（P7：低层拷贝原语归 L1），slice.cute 两点改 `memory.memmove` 点调用 |
| `alignedAlloc(n, align)` | — | 暂缓：tier 台阶天然 8/16 对齐，需要时立项 |
| RC_BIT 修复（F1） **✅** | — | RC_BIT=4 独立位标记 + FLAG_MASK 3→7，见 §2.3 |
| memset 语义修复（F2） **✅** | — | c==0 word 快径保留 / c≠0 退 byte 循环，见 §2.3 |
| gDbgA-D 清理（F3） **✅** | — | allocator/rc/memory.cute 共 7 处删除 |
| F4/F5/F6 文档 **✅** | — | F4 brk 模型限制/F5 泄漏表 256 条上限/F6 round8 对齐写进包顶注释 |

**验收**：rcTracking/rctest/gcfree 不变列逐位比对；malloc/free 计数守恒。

### 4.2 slices（Wave S）✅ 2026-10-30

| 方向 | 新增 | Go 对照 | 备注 |
|---|---|---|---|
| 成长 | `grow[T](s *[]T, want int)` **✅** | slices.Grow + P2 曲线 | push 收敛改走 grow ✅；grow 内部用 memory.memmove ✅ |
| 拷贝 | `clone[T]` / `copy[T]` **✅** | slices.Clone | 逐元素值拷贝 / min(len) memmove，返回拷贝数 |
| 判定 | `contains/index/equal[T]` **✅** | slices 同名录 | cmp = `==`；index 独立体内实现（非 find 代理，R3 mono 缓存规避） |
| 整形 | `compact/reverse/insert/deleteRange/clear` **✅** | slices 包 | deleteRange = move-tail + len 调整；insert 容量不足走 grow |
| 拼接 | `cat/join[T]` **✅** | slices.Concat/join | cat=C 二段拼接 ✅；join=**三参变体 join(a,sep,b) ✅**（spb8/9 前置探针绿：sizeof[sliceHdr]()=24、`*[][]T` 形参可编译；spb10 判定嵌套字面量 `[[],…]` parser 拒绝 → 真形 Join 无调用侧构造器，**延期记录**） |
| 覆写 | `sliceHdr{p,n,c}`（p@0/n@8/c@16，Go 序=v2.2） | runtime.slice | P8+P11；包内全部手工寻址迁移到该视图（A6 旧序作废，与 `str` 同形）；供用户 unsafe 共用 ✅（S0-3） |
| 释放 | `free` 已有 | — | 所有权注释化（头+data 双 free ✅） |

**契约升级（Wave S 拍板）**：`remove[T](s,index) T`（void→返回被删元素；越界 UB 与 set/getPtr 同口径）；新增 `pop[T](s) T`（非空 UB）。**边界**：`append/len/cap/make` 仍是编译器内建（禁改红线），包级 API 只补运算。

### 4.3 strings（Wave St）

78 fn 已覆盖大半。补齐（按 Go 名）：
`compare / eqFold / count / lastIndex / indexAny / trimSet / trimLeftSet / trimRightSet /
splitN / split / fields / fieldsFunc / replaceN / repeatN` + **Builder 结构体**
（`builder.new/write/writeString/string`，MVP 用 `[]bytes` 容器）
+ `str{p,n,c}` 覆写结构体（P8，unsafe 类型视图首批用户）。

`toCstring` 文档化 WARNING：返回 C 串所有权（free 责任），第四根因悬空陷阱高发点。

### 4.4 maps（Wave Mp；v2 定案：**删包**）

v1「deprecated 薄壳」作废，用户拍板 **hashmap 删包**：

- 删除 `pkg/hashmap`；唯一外部用户 `pkg/text/template` 切 `std:maps`（R5）；
  现助手包 `pkg/maps` 就地重写为独立泛型包；
- **依赖**：只 import memory（P7）；string 键的 hash（FNV-1a）/ eq（逐字节）手写，
  不 import strings——容器间零横依赖；
- **形状**：开放寻址 + 墓碑；载荷 0.75 → 2× 成长；桶数组 = 单块 malloc（手工寻址，P8）；
  K 初批 int/uint/ptr/string（float Key 二期）；Wave L 落地后可评估 noalign struct 元数据形态（非硬依赖）；
- **API**：`map.new/set/get(零值+ok)/has/delete/len/clear/keys/values/clone/equal`；
- 命名冲突：monomorphize 缓存量控制（R3）。

### 4.5 sort（Phase A ✅ + Wave T）

- **Phase A（已落地）**：`pkg/sort/api.cute` 公开层——切片族 + 裸阵列族（ptr,n）双形状；
  失配 6 调用点归零；sortMinimal/2/Quick 哨兵清零；**未提交 → Wave 0 C 批次收编**。
- **Wave T**：真 timsort——minrun 计算、run 二分插入、归并栈（gallop 简化为指数跳）；
  验收与 qsort 对拍哨兵（有序 + 元素多重集相等）。

---

## 5. 波次实施与验收（v2）

| Wave | 交付 | e2e 哨兵 / 门禁 | 量级 |
|---|---|---|---|
| **0 基线** | ① C1–C7 分批提交（BindDanglingCall/context/compiler.go、setArgsOffset、ops.go 六根因、sort.cute、api.cute、stdplan 文档）② console.println stdout 复验（**用户裁定 2026-10-30：非阻断**——验收面=编译器核心+M/S/St/Mp 四模块，上层 stdlib 不作保证，println 属上层仅定性）③ slices.new for_28 崩点 triage（**✅ 2026-10-30 收口**：for_28=`std_slices_set__T__int` 内逐字节拷贝循环；根因=**stdlib 包 API 契约错误**——`fn set[T](..., src ptr)` 第三形参收 ptr 而调用方 slice_test 传 int 值（值当指针、从地址 10 读字节），编译器无 bug；归 Wave S 重写时改按值签名，不进 S0-2）④ 切片字段索引定性探针（**A5 收口 ✅ 2026-10-30**：M1/M2b/M4 自洽通过、M2a panic、M3 segfault——两处实锤发现与谱系见 PROGRESS.md；A5 病灶修复编入 S0）⑤ esccheck 全语料复验（W2 口径 115/87，覆盖五、六根因后端改动逐位对拍；**验收面裁定：红项全 0 + 核心目录，上层 pkg 目录失败不阻断**） | 13 绿哨兵复跑（rctest=60、gcfree=60、castmalprobe=7、derefTest=7、rcSimple=12、probeC=1、oldprobe=0、slice_minimal=0、sortMinimal/2/Quick=0…；**核心编译器不变式，保留为硬门禁**） | M |
| **L 语言设施** | P10 import（lexer IMPORT + parser 顶层 ImportBlock + 文件级导入表 + 五形态路由 + CUTE_ROOT + vendor 查找 + test/import）+ P9 align/noalign（parser/build.go align case + StructBlock 携带 + type/struct.go Layout 分支） | 13 绿哨兵逐位对拍（默认路径不变）+ 新 test/import + test/align | L |
| **M memory** | §4.1 全部（**✅ 2026-10-30**：calloc/ptrToStringHeader/memmove 提级迁 memory + F1 RC_BIT=4/F2 memset 重写/F3 gDbg 七处删 + F4/F5/F6 文档 + 尾删 RCMARK 调试块 + getenv strView 正名） | 23 项哨兵逐位零回归（rctest=60/gcfree=60/gcfree2=0/derefTest=7/rcSimple=12/complexTest=17/m 族=2·1/slice_minimal=0/slice_test=0/negIdx=48/sort 面全 0/sortTest=110/sliceTest=0）+ mprobe 5 点探针全绿 + esccheck 四目录红项全 0（complexTest 数值逐位同基线）；memoryTest 92/memSuite 3 三二进制对拍=波前旧况；**新发现待台账：跨文件 const · call-arg staging 缺陷面（绕行形态纪律=VarDecl 中转）** | M |
| **S slices** | **S0 shape 基建前置**（**S0-1 ✅** bounds 解引两轨合流+写路径死代码 gate-revive；**S0-2 ✅** ListType.Shape() 懒构造+exp.go 查表化 10 调用点+5 收口点+listBaseResolve 全量合流+P11 容器头算术清零；**S0-3 ✅** slices.cute 迁 sliceHdr 视图 + set 契约改按值 + mono 残读端根因修复（addSpecializedFunc 原树补 Setup 三步）+ pkg/sort 手写序 Go 序对齐 + new→make 改名实验收口）+ **§4.2 全 suite ✅ 2026-10-30**（grow/pop/find/index/contains/equal/clone/copy/compact/reverse/insert/deleteRange/clear/cat + join 三参变体落地、真形 Join 延期=spb10 嵌套字面量无构造器；push 收敛走 grow；remove 契约升级返被删元素）+ push 走 grow | S0：13 绿哨兵逐位不变 ✅（S0-1/S0-2 各自双二进制 EQ；S0-3 后 23 项对拍全数 + esccheck 三目录红项全 0）+ esccheck 核心红项全 0 ✅；全套 ✅：spb1=0（push→grow 成长绿）+ sprobe01=0（13 块全场探针）+ pkg/slices/test=230（23 断言 pass*10+fail）+ 23 项哨兵复跑逐位零回归 + esccheck 红项全 0（complexTest=对象3/释放2/转移1 逐位同基线）；旧 sentinel：slice_test=0（历史首绿）/slice_minimal=0/negIdx=48（确定性 UB）+ sort 面全 0 + sortTest=110（11 pass）| M |
| **St strings** | §4.3 | stringsUtils 复跑 + 新哨兵 | L |
| **Mp maps** | §4.4（删包 + 切包） | 新 test/maps 哨兵 + fmt/sortTest 复跑 | L |
| **T+F** | §4.5 Wave T + assertEq 真实现 | sortTest 归零 + sliceTest 归零 | M |

每 Wave 三条验收（v1 沿用）：① exit-code 哨兵全绿 ② esccheck 语料 +N 单独归因记录（PROGRESS.md），
不变列逐位比对 ③ 主线程分批提交（包×Wave 一 commit）。

**W5 随手清分配（拍板：不设独立阶段）**：

| 时机 | 动作 |
|---|---|
| Wave 0 尾 | exp_check.go 还原 |
| Wave M 尾 | compiler.go RCMARK 探针删除 |
| Wave S 尾 | exp.go leaf 内 PROBE-CAST 残留打印删除（阻塞验证可提前） |

**支线（不入波次，插空）**：`||`/`&&` 链缺陷（recursion 53→51，参数 vs 字面量判别探针×4）、
139 簇其余（rcTracking/stringsUtils/sliceTest 栈耗尽定性）、structMethod=45、console.println 输出链（R1）。

---

## 6. 语言能力边界（v2 更新）

| 想要 | 需要动 | 决定 |
|---|---|---|
| `m[k]` 索引/赋值语法 | parser 绑定链 | 不做；显式 `map.get/set` |
| `for k,v in map` | parser ForBlock | 不做；keys/values 迭代 |
| 运算符重载 | parser | 不做 |
| panic/recover | 运行时机制 | 不做；ok 形态 |
| GC 代替 RC | 全世界 | 不做（P1） |
| 泛型 struct `struct [T]` | monomorphize 扩展 | 另期立项（R7；maps 手工寻址不阻塞） |
| `build align(N)/noalign` | parser/build.go + type/struct.go Layout 有限分支 | **做（Wave L）**，破冻范围见 R6 |
| `import` 关键字（五形态前缀路由） | lexer IMPORT + parser 顶层 ImportBlock + packageSys 路由 | **做（Wave L）**，见 P10；json 降级纯元数据、imports 兼容保留 |

---

## 7. 风险与开放问题（v2）

| # | 风险 | 处置 |
|---|---|---|
| R1 | console.println 输出链自身 bug（sortDbg 实证：exit=0 但 stdout 空） | 哨兵断言不依赖 stdout；Wave 0 复验定性；修复立专项（含 setCursorPos） |
| R2 | timsort 与 RC 交互的释放路径陈旧值 bug（第四根因同型） | Wave T 单独 esccheck 复验 |
| R3 | 泛型 hash 引发 monomorphize 爆炸（新组合 K×V） | monomorphize 已有缓存量控制；Wave Mp 观测 |
| R4 | syscall 路径行为变化——**✅ 收口 2026-10-30**：getenv 正名后 syscall 侧不再调用 ptrToStringHeader（包内 strView 直读 p@0，P11 通道），mp4/mp5 探针（memory+syscall 编译+运行）覆盖 | Wave M 单独哨兵：syscallWrite 类用例 |
| R5 | hashmap 删包破坏 text/template | 唯一外部用户；切 std:maps + text/template 复跑（Wave Mp） |
| R6 | Wave L 触碰冻结区（type/struct.go + parser/*） | align：diff 严格限于「StructType 加一个字段 + Layout() 分支」；import：仅新增识别路径（lexer IMPORT token、parser 顶层 ImportBlock、fixPkgNamePaths 查表序扩展），不改既有绑定逻辑；默认路径逐位不变 + 哨兵对拍；**范围外任何 diff 先经用户确认**（用户也可像 gc 一样手改，我提供精确 patch 文本） |
| R7 | 泛型 struct 未证实（全库无 `struct [T]` 用法，monomorphize 仅函数级验证） | maps 已定裸 ptr 手工寻址不阻塞；泛型 struct 另期立项 |
| R8 | import 一期落地范围 | 含：五形态判别 + std: 路由 + 文件级导入表 + json 兼容轨 + CUTE_ROOT + vendor 查找；ext:/api: 物理目录一期占位（逻辑源保留，映射 git 仓库待定）；第三方远程拉取二期 |
| R9 | ext:/api: → 指定 git 仓库的映射规则未定 | 一期本地目录占位 + 前缀路由接口化；映射规则待用户提供后接入 resolver |
| R10 | Go `.` 点导入 | defer：无前缀名并入当前命名空间与「必须有前缀」纪律及 P7 审计冲突；需要时另期立项 |
