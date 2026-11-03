# Cute 编译器 GC 与内存管理

> 适用源码：`compile/gc/`、`compile/compiler.go`、`compile/arch/`、`pkg/memory/`。
> 本文描述的是**当前实现**，不是目标设计；文中标注“已知缺口”的行为都已在
> 生成汇编或源码中核对过。
>
> 一句话结论：Cute 没有追踪式 GC。编译器在编译期做**所有权/逃逸摘要 + 局部
> 释放分析（LLR）**，在能证明独占所有权的位置生成 `free/freeSlot`；证明不了
> 就不释放。运行时只提供普通 `malloc/free` 分配器和**按对象选用**的引用计数
> （RC），不接管全部对象。

---

## 0. 先看结论

1. **生成释放代码的权威分析是 `compile/gc`**，不是 `parser.SimulateRC`。
   - `gc.Build` 产出全程序函数摘要 `gc.Table` 和逐函数释放计划 `gc.LLRResults`；
   - 后端 `compile.Compiler` 只查这两张表生成释放代码；
   - `parser.SimulateRC` / `parser.Object` / `Life.FreeScope` 是另一代前端模型，
     目前只服务于 `tools/esccheck` 诊断，不参与代码生成。

2. **释放的前提是“可证明的独占所有权”**：
   - 对象由本帧分配（或由已知 `RetFresh` 调用返回）；
   - 未逃逸、未被保存到字段/容器/全局、未被其它名字别名共享；
   - 不是参数、不是 `newRC` 对象；
   - 调用点没有未知调用（`CallsAny`）或全局拥有存储（`HasGlobalOwnStore`）。

3. **释放点有七类**：函数出口、块尾、循环出口、覆盖赋值前、`ret` 临时对象、
   条件表达式临时对象、`for` 增量表达式临时对象。另有手动 RC。

4. **运行时分配器保持原样**：普通块 `[header][data][footer]`，RC 块多两个前缀
   字；`free()` 通过 flags 位自动区分，RC 块走 `rcDec`。

5. **`main` 只跳过函数出口释放**，`build link` 别名包装器同样只跳过出口释放；
   块尾、循环出口、覆盖赋值、`ret`/条件/增量临时释放仍会生成。这是有意为之：
   进程退出由 OS 回收；链接包装器可能被外部调用，帧边界不成立。

6. **当前有两个已核对的活性缺口**（详见 §9）：
   - 函数出口释放代码被放在 `func_end_<name>:` 标签之前，显式 `ret` 的
     `jmp func_end_<name>` 会跳过它；
   - 直接调用 `new` 会进入 `CallsAny`，导致该函数 LLR 直接返回空结果。

---

## 1. 总体架构

### 1.1 三层分工

| 层 | 主要文件 | 输入 | 输出 | 职责 |
|---|---|---|---|---|
| 前端摘要 | `compile/gc/analyze.go`、`summary.go` | 包合并、Check 收敛后的 AST | `gc.Table`（`FnSummary`） | 全程序参数逃逸、返回值来源、堆分配/未知调用/全局存储摘要 |
| 前端 LLR | `compile/gc/llr.go` | 单函数 AST + 该函数摘要 | `gc.LLRResults`（`LLRResult`） | 抽象对象、绑定、逃逸/共享、释放点计划 |
| 后端代码生成 | `compile/compiler.go`、`compile/arch/` | AST + 两张 GC 表 | `_main.asm` | 在语句/函数边界插入 `free/freeSlot`，管理 scratch 槽 |
| 运行时 | `pkg/memory/` | 生成的调用 | 堆块/RC 块 | 分配、释放、RC、泄漏追踪 |

### 1.2 一次编译的执行顺序

```
package.GetPackage(path)
  ├─ 解析 .cute，合并包，Check 跑到收敛（最多 50 轮）
  ├─ parser.SimulateRC(root)          // 旧前端模型，诊断用
  └─ 返回 packageInfo
        │
        ▼
main.go
  ├─ gc.Build(ast)                    // 全程序摘要 + LLR，权威分析
  ├─ 打印/落盘 gc_summary.json、gc_llr.txt
  └─ compile.Compiler.Compile(ast)
        ├─ 泛型单态化时对克隆体重算 LLR
        ├─ funcHandle：按 LLR 预留 scratch、生成 Prologue/函数体
        ├─ 语句级：块尾、循环出口、覆盖赋值、ret/条件/增量临时释放
        ├─ 函数体后：emitGCFrees（出口释放）
        └─ Epilogue
              │
              ▼
        _main.asm → nasm/ld → 可执行文件
              │
              ▼
        运行时 std_memory.free / freeSlot
```

关键顺序点：

- `parser.SimulateRC` 在 `package.GetPackage` 内、Check 收敛之后调用；
- `gc.Build` 在 `main.go` 内、`GetPackage` 返回之后调用；
- `gc.Build` 必须在单态化之前跑完，因为摘要按泛型原树建立；
- 泛型克隆体在 `MonomorphizeIfNeeded` 里用原函数摘要重算一份 LLR，
  以克隆节点为键写入 `gc.LLRResults`（`compile/monomorphize.go` 的
  “单态化克隆体的 LLR 结果重算”段）。

### 1.3 两代 GC 模型的关系

仓库里同时存在两条“GC”链路，必须分清：

| 项目 | `parser.SimulateRC` 链 | `compile/gc` 链 |
|---|---|---|
| 入口 | `parser.SimulateRC(root)` | `gc.Build(root)` |
| 调用点 | `package/package.go` | `main.go` |
| 核心数据结构 | `parser.Object`、`Life`、`FreeScope` | `FnSummary`、`LLRResult` |
| 释放依据 | 变量绑定名的最外层作用域 + 槽位模拟 | 调用摘要 + 返回值来源 + 别名/借用 mask + 语句级 LLR |
| 产物消费者 | `tools/esccheck`（诊断） | `compile.Compiler`（真正生成释放代码） |
| 当前状态 | 诊断/历史模型 | 权威链路 |

`docs/gc_frontend_design.md` 开头“后端只读 `parser.Object` 与
`(*Life).Disposal()`”是旧描述，与当前代码不一致。**排查释放代码时以
`compile/gc` 为准**；`parser` 模型的统计只用于观察“如果按旧规则会在哪释放”。

---

## 2. 所有权模型

### 2.1 哪些类型算“拥有堆内存”

`compile/gc/analyze.go` 的 `isOwning` 判定：

| 类型 | 是否 owning | 说明 |
|---|---|---|
| `*T` | 是 | 指针本身是堆块的唯一入口；`&local` 例外，由调用方标记为借用 |
| `string` | 是 | 24B（x64）/12B（x86）头，首字 `p@0` 指向字符缓冲 |
| `list` | 是 | 头布局 `data@0 / len / cap`，首字指向元素缓冲 |
| 裸 `ptr` | 否 | 手动管理/借用，LLR 不自动释放 |
| 内联 struct 值 | 否 | 结构体本身不是堆块；其 owning 字段可被字段级级联释放 |
| `newRC(T)` 产生的 `*T` | 特殊 | 带 RC 头，LLR 明确排除，必须手动 `rcDec` |

`string`/`list` 的“释放”不是释放头本身，而是释放**头首字指向的缓冲**：
`freeSlot(&s)` 读到的第一个字就是 `p`，运行时 `free(p)` 回收缓冲。头通常位于
栈、寄存器或结构体内联位置，不能把头的地址直接当堆块传给 `free`。

### 2.2 所有权来源

| 来源 | 初始归类 | 谁负责释放 |
|---|---|---|
| `new(T)` | 新分配（fresh） | 当前帧，若未被返回/保存 |
| `make`/列表创建 | 新分配 | 当前帧，若未逃逸 |
| 字符串 `+` 拼接 | 新分配（缓冲） | 当前帧，若未逃逸 |
| 调用已知函数且 `RetKind=Fresh`、mask 为 0 | 新分配 | 调用方 |
| 调用 `RetKind=AliasParam/BorrowParam/Unknown` | 借用/未知 | 不自动释放 |
| 参数 | 调用方拥有 | 被调不释放 |
| 全局变量 | 全局拥有 | 不自动释放 |
| `newRC(T)` | RC 引用（初始 1） | 手动 `rcDec`/`free` |
| `strings.makeString` | 包装外部 ptr | **不释放**（非分配包装器） |
| 裸变量赋值 `b = a` | 别名共享 | 两个名字都不做提前释放 |

### 2.3 逃逸层级

`Escape` 从弱到强：

| 值 | 含义 | 后果 |
|---|---|---|
| `EscNone` | 只在当前函数内读/写 | 仍可能帧内释放 |
| `EscCaller` | 通过返回值/输出参数交给上层 | 本帧不释放 |
| `EscHeapObj` | 存进另一个堆对象字段 | 本帧不释放 |
| `EscGlobal` | 存进全局变量 | 本帧不释放；函数可能被 `HasGlobalOwnStore` 整体禁用 |
| `EscAny` | 未知/外部调用 | 本帧不释放 |

`Merge` 取更强的一级；未知值按最强处理。

### 2.4 返回值分类

`RetKind` 描述“返回的 owning 指针从哪来”：

| 值 | 含义 | 调用方能否自动释放 |
|---|---|---|
| `RetNone` | 返回值不携带 owning 指针 | 不适用 |
| `RetFresh` | 新分配，所有权转移给调用方 | 可以（还需 mask 为 0） |
| `RetAliasParam` | 可能返回某个参数本身 | 不可以 |
| `RetBorrowParam` | 可能返回参数内部指针 | 不可以 |
| `RetUnknown` | 来源无法证明 | 不可以 |

`RetAliasMask` / `RetBorrowMask` 是逐参数位图：bit i 表示“可能返回第 i 个
参数本身/内部指针”。**只要 mask 非零，返回值就不能由调用方自动释放**。
典型例子是 `clone` 在空串分支直接返回入参、在非空分支返回新缓冲。

### 2.5 可释放判定：canonical owner

一个对象要被 LLR 自动释放，至少要满足：

1. `objEscaped[id] == false`：没有逃逸到 caller/heap/global/unknown；
2. `objShared[id] == false`：没有被另一个变量、字段、列表元素保存成别名；
3. `objRCAlloc[id] == false`：不是 `newRC` 对象；
4. 不是参数透传对象（`isParamObj`）；
5. 覆盖赋值点还要额外满足：旧对象是当前名字的唯一绑定、来源可识别
   （不是 `null_init`/`unknown`/`expr`）、右值不引用目标变量本身；
6. 函数级门槛通过：没有 `CallsAny`、没有 `HasGlobalOwnStore`、确有堆分配。

“唯一绑定”是覆盖释放的核心：如果还有另一个名字指向同一对象，提前释放旧值
会让另一个名字悬空，因此宁可留到函数出口或直接不释放。

### 2.6 生命周期状态图

```
                    ┌──────────────────────────────┐
                    │  new / make / RetFresh call  │
                    └──────────────┬───────────────┘
                                   │
                                   ▼
                            FRESH / FRAME_OWN
                                   │
          ┌────────────────────────┼─────────────────────────┐
          │                        │                         │
          ▼                        ▼                         ▼
   存字段/容器/全局          被另一名字绑定              newRC
          │                        │                         │
          ▼                        ▼                         ▼
      ESCAPED                  SHARED                    RC_OWN
   （本帧不释放）           （不做提前释放）          （手动 rcDec）
          │                        │
          └────────────┬───────────┘
                       ▼
              函数出口/块尾/循环出口
              （仅 FRAME_OWN 且未被释放）
                       │
                       ▼
                 freeSlot(&x) / free(p)
                       │
                       ▼
                  RELEASED（槽清 0）
```

### 2.7 释放点与安全条件

| 释放点 | 触发 | 生成调用 | 安全条件 |
|---|---|---|---|
| 函数出口 | 函数体结束/汇合到出口 | `freeSlot(&x)`、字段先 `free(p)` | 帧内拥有、未逃逸、未共享、非参数、非 RC |
| 块尾 | `if/else` 体、`for` 体等块结束 | `freeSlot(&x)` | 变量声明在该块内，且仍绑定 |
| 循环出口 | `for_end` 之后 | `freeSlot(&x)` | 循环体内声明的变量；覆盖 `break` 跳过块尾的路径 |
| 覆盖赋值前 | `x = ...` 写入新值前 | `freeSlot(&x)` | 旧对象唯一绑定、未共享、未逃逸、右值不引用 `x` |
| `ret` 临时 | 外层调用返回后 | `freeSlot(scratch)` | 内层调用 `RetFresh`、mask 为 0、外层不保存/不返回该实参 |
| 条件临时 | 条件 true/false 两条路径 | `freeSlot(scratch)` | 条件中的 owning call 满足 Fresh/mask 0/被调确有堆分配 |
| 增量临时 | `for` 增量求值后 | `freeSlot(scratch)` | 同上 |
| 手动 RC | 用户代码 | `rcDec`/`freeRC` | 用户保证配对与单线程 |

---

## 3. 前端：全程序函数摘要

### 3.1 入口与阶段

```go
// compile/gc/analyze.go
func Build(root *parser.Node)
```

`Build` 的阶段：

1. `collectFuncs`：递归收集所有 `FuncBlock`，键为 `fb.Name.String()`（包合并后
   是全路径名）；
2. 初始化每个函数的 `FnSummary`：拥有型参数建 `ParamSummary`，拥有型返回值
   先置 `RetOwned=true`、`RetEscape=EscCaller`、`RetKind=RetUnknown`；
3. 单调不动点迭代：沿调用边反向传播参数逃逸、堆分配、未知调用等；
4. `tightenParams`：用“快照 + 重置重算”的 Jacobi 迭代，把早期因
   `RetUnknown` 误提升的参数收紧回来；
5. 对每个函数调用 `ComputeLLR`，写入 `gc.LLRResults`；
6. 排序参数、写回 `RetEscape`。

全局表：

```go
var Table = map[string]*FnSummary{}      // 函数全路径名 → 摘要
var LLRResults = map[string]*LLRResult{} // 函数全路径名 → LLR 结果
```

`Build` 会重置 `LLRResults`，但**不会清空 `Table`**；正常编译器入口只调用一次
`Build`。若在同一进程内对完全不同的 AST 重复调用，需要调用方自己保证表不串。

### 3.2 `FnSummary` 与 `ParamSummary`

```go
type ParamSummary struct {
    Index  int    `json:"index"`
    Mode   Mode   `json:"mode"`
    Escape Escape `json:"escape"`
}

type FnSummary struct {
    Name      string
    Params    []ParamSummary
    RetOwned  bool
    RetEscape Escape
    RetKind   RetKind
    RetAliasMask  uint64
    RetBorrowMask uint64
    CallsAny      []string
    HasGlobalOwnStore bool
    HasHeapAllocs     bool
}
```

字段语义：

- `Params`：只包含 owning 类型参数；`Index` 是源码参数序号；
- `RetOwned`：返回类型是否携带 owning 指针；
- `RetEscape`：返回值最高逃逸层级；
- `RetKind`/`RetAliasMask`/`RetBorrowMask`：返回值来源与逐参数别名/借用位图；
- `CallsAny`：调用过的“无摘要函数”名单。只要非空，LLR 直接放弃该函数；
- `HasGlobalOwnStore`：函数体存在“全局 = 拥有值”赋值；LLR 直接放弃该函数；
- `HasHeapAllocs`：函数体内有 `new`/`make`/字符串拼接/RetOwned 调用；没有则
  跳过 LLR。

### 3.3 `Mode` / `Escape` / `RetKind`

`Mode` 描述被调函数怎么使用 owning 参数，强度从弱到强：

```
Read < Write < DeepCopy < ShallowCopy < OtherRef
```

`Escape` 的强度：

```
None < Caller < HeapObj < Global < Any
```

`RetKind` 见 §2.4。`Merge` 都是“取更强”，保证摘要单调、幂等。

### 3.4 摘要查询 API

| API | 签名 | 说明 |
|---|---|---|
| `gc.ParamEscapes` | `func ParamEscapes(calleeKey string, idx int) Escape` | 查第 idx 个参数的逃逸层级；无摘要返回 `EscAny`，纯内建例外 |
| `gc.CalleeKnown` | `func CalleeKnown(calleeKey string) bool` | 是否已有摘要 |
| `gc.DumpSummary` | `func DumpSummary(fs *FnSummary) string` | 单函数可读摘要 |
| `gc.DumpAll` | `func DumpAll(w io.Writer) error` | 按名字排序输出所有摘要（`== name` + JSON） |
| `gc.DumpLLRs` | `func DumpLLRs() string` | 所有 LLR 结果的可读 dump |
| `gc.DumpLLR` | `func DumpLLR(res *LLRResult) string` | 单函数 LLR dump |
| `gc.DumpFrees` | `func DumpFrees() string` | 所有释放计划扁平 dump |

注意：`gc_summary.json` 实际是“多个 `== name` 分节 + 每节一段 JSON”的文本，
不是单个合法 JSON 文档；`gc_llr.txt` 是纯文本，不要当机器格式解析。

### 3.5 三个保守门槛

`ComputeLLR` 开头依次检查：

```go
if hasRealAnyCalls(fs.CallsAny) { return res } // 未知调用
if fs.HasGlobalOwnStore { return res }         // 全局拥有存储
if !fs.HasHeapAllocs { return res }            // 无堆分配
```

- **未知调用**：被调没有摘要（跨语言、未解析、`new` 等），调用方无法知道实参
  是否被保存到别处；整个函数的 LLR 置空，宁可不释放。
- **全局拥有存储**：全局可能仍持有帧内对象，跨函数别名无法证明；整个函数放弃。
- **无堆分配**：没有可释放的堆指针，直接跳过。

这三个门槛都是**函数级**的，粒度很粗：一个无关的未知调用也会让整个函数不释放。
这是当前安全策略的代价，不是 bug；但 `new` 被误归入未知调用是实际缺口（§9.2）。

---

## 4. 前端：LLR 局部释放分析

`LLR` = Liveness/Local Release，按语句前向扫描，维护“变量名 → 抽象对象”的
绑定，并在能证明独占的位置登记释放计划。

### 4.1 `LLRResult`

```go
type LLRResult struct {
    Fn            string
    Objects       []LLRObj
    Frees         []LLRFree        // 函数出口释放
    FieldFrees    []LLRFieldFree   // 函数出口字段级级联
    BlockFreesMap map[*parser.Node][]LLRFree // 块节点 → 块尾释放
    AssignFrees   map[*parser.Node][]LLRFree // 赋值节点 → 覆盖前释放
    LoopExitFrees map[*parser.Node][]LLRFree // for 节点 → 循环出口释放
    RetFrees      []LLRRetFree     // 扁平，调试输出
    RetFreesMap   map[*parser.Node][]LLRRetFree // return 节点 → call 后释放
    CondFreesMap  map[*parser.Node][]LLRCondFree // if/for 节点 → 条件临时释放
    IncrFreesMap  map[*parser.Node][]LLRCondFree // for 节点 → 增量临时释放
    RetScratchSlots int            // 单清理点最大 scratch 槽数
}
```

`LLRResult` 中按 AST 节点索引的 map 标记为 `json:"-"`，不参与 JSON 序列化；
`gc_llr.txt` 本身是文本格式，`DumpLLR` 会把它们展开为
`FREE`/`FIELD_FREE`/`RET_FREE`/`COND_FREE`/`INCR_FREE` 行。

### 4.2 抽象对象与绑定

`llrState` 的关键状态：

| 字段 | 作用 |
|---|---|
| `bindings` | 变量名（首段）→ 当前 `ObjID` |
| `objEscaped` | 对象是否已逃逸；一旦为真永不自动释放 |
| `objRCAlloc` | 是否 `newRC` 分配；不自动释放 |
| `objSite` | 分配来源描述（`new`、`call:xxx`、`string-concat`、`null_init`、`param:x`） |
| `objScope` / `objBlockID` | 创建时作用域深度/块 ID，用于块尾释放归属 |
| `objShared` | 是否被保存成非 canonical 别名 |
| `objReleased` | 是否已在覆盖点释放；后续出口/块尾跳过 |
| `varBlockID` | 变量声明所在块；块尾只释放本块声明的变量 |
| `orphans` | 被覆盖掉的旧对象（调试/出口候选） |
| `fieldOrphans` | 字段赋值产生的旧值（字段级 orphan） |

`ObjID` 按分配点唯一；同一变量连续两次 `new` 是两个不同对象。参数绑定为
`param:<name>` 对象并立即标记 `objEscaped=true`，表示“由调用者管理”。

### 4.3 释放计划分类

| 计划 | 键 | 生成位置 | 语义 |
|---|---|---|---|
| `Frees` | 变量名 | 函数出口 | 帧内拥有且仍绑定的命名对象 |
| `FieldFrees` | `varName.fieldName` | 函数出口，先于父对象 | 直接 owning 字段级联 |
| `BlockFreesMap` | 块节点 | 块尾 | 本块声明的局部对象 |
| `AssignFrees` | 赋值节点 | 写入新值前 | 旧对象唯一/未共享时 |
| `LoopExitFrees` | `for` 节点 | `for_end` 后 | 覆盖 `break` 跳过块尾 |
| `RetFreesMap` | `return` 节点 | 外层调用返回后 | 嵌套调用临时对象 |
| `CondFreesMap` | `if`/`for` 节点 | 条件 true/false 路径 | 条件临时对象 |
| `IncrFreesMap` | `for` 节点 | 增量求值后 | 增量临时对象 |

`RetScratchSlots` 取 `RetFrees`、条件、增量三类计划的最大长度；三类清理点不会
同时求值，所以 scratch 槽复用。

### 4.4 收集规则

#### 4.4.1 参数

```go
for _, ag := range fb.Args {
    if ag.Type != nil && isOwning(ag.Type) && ag.Name != nil {
        id := st.newObj("param:" + name)
        st.bindings[name] = id
        st.objEscaped[id] = true  // 调用者管理
        paramNames[name] = true
    }
}
```

#### 4.4.2 定义与覆盖赋值

`processAssign` 的核心分支：

- `var x: *T`（无初值、owning）：绑定 `null_init` 并标逃逸，后续 `x = ...`
  可以继续追踪；
- `var x = new(T)` / `= RetFresh 调用` / `= 字符串拼接`：
  创建新对象，`objSite` 记录来源；`newRC` 额外标 `objRCAlloc`；
- `var x = y`（裸变量别名）：`x` 绑定到 `y` 的对象，并标 `objShared[y]`；
- `x = ...`（非定义）：先尝试覆盖释放旧对象，再绑定新对象；
- 字段赋值 `x.f = ...`：若右值分配新对象，登记字段级 orphan；把右值对象标
  `objShared`，禁止后续覆盖释放误杀；
- 全局赋值：旧对象和右值都标逃逸，并可能置 `HasGlobalOwnStore`。

覆盖释放 `canFreeOverwrite` 的检查顺序：

```go
if id == NilObj || objReleased[id] || objEscaped[id] ||
   objShared[id] || objRCAlloc[id] || isParamObj(st, id) {
    return false
}
switch objSite[id] {
case "", "null_init", "unknown", "expr":
    return false
}
// 仍有其它名字持有同一对象 → false
```

#### 4.4.3 块尾与循环出口

`scanStatements` 维护 `scopeDepth`/`currentBlockID`。进入 `if`/`for` 体时：

- `scopeDepth++`，分配新块 ID；
- 块内 `var` 声明记录 `varBlockID[name] = currentBlockID`；
- 块结束时，只对本块声明、仍绑定、未逃逸/共享/参数/RC 的对象登记
  `BlockFreesMap[blockNode]`；
- 若块是 `for` 体，`BlockFreesMap[forNode]` 同时复制一份到
  `LoopExitFrees[forNode]`，供 `for_end` 处理 `break`。

#### 4.4.4 `ret` 临时对象

`collectRetFrees` 遍历每个 `return` 表达式，寻找“内层调用返回 owning 临时对象，
外层调用不保存也不返回它”的形态：

- 内层调用摘要 `RetKind=RetFresh`；
- `RetAliasMask == 0 && RetBorrowMask == 0`；
- 内层调用直接作为外层调用的实参；
- 外层调用对该实参的 `ParamEscapes == EscNone`，且外层返回的
  alias/borrow mask 未命中该实参；
- 外层摘要存在且 `RetKind != RetUnknown`（纯内建视为不返回实参）。

登记为 `RetFreesMap[returnNode]`，后端在外层调用返回后从 scratch 释放。

**注意**：`collectRetFreesExpr` **不检查被调的 `HasHeapAllocs`**。
`HasHeapAllocs` 门槛只存在于条件/增量临时（`condTempFreeable`）。因此
`strings.makeString` 这类“包装外部 ptr、自身不分配”的函数，如果作为另一个
有摘要调用的实参出现，理论上会被登记为 `RET_FREE`；当前用例里没有这种嵌套
形态，所以尚未触发。这是潜在风险，修复时应给 ret 收集器补同一门槛。

#### 4.4.5 条件/增量临时对象

`collectCondFrees` / `collectIncrFrees` 对 `if`/`for` 条件、`for` 增量表达式做
同样的“Fresh + mask 0 + 被调有堆分配”判定。它们只在表达式求值后立即释放，
因为条件结果不会被后续语句使用。

### 4.5 查询 API

```go
func RetFreesForNode(fnKey string, n *parser.Node) []LLRRetFree
func CondFreesForNode(fnKey string, n *parser.Node) []LLRCondFree
func IncrFreesForNode(fnKey string, n *parser.Node) []LLRCondFree
```

无结果时返回 `nil`；后端按节点指针查表，所以**必须传 AST 中的同一个节点**，
不能复制节点后查询。

### 4.6 `gc_llr.txt` 阅读法

```
== runBuild
  obj[0] tmp site=call:makeNode FRAME_OWN
  obj[1] a site=call:makeNode FRAME_OWN
  FREE tmp [unknown] scope=1
  FREE a [unknown]
  FIELD_FREE tmp.next [unknown]
```

- `obj[i]`：抽象对象；`site` 是来源；`FRAME_OWN` 表示帧内拥有；
- `ESCAPED`：已逃逸，不会自动释放；
- `FREE`：出口/块尾计划；
- `scope>0`：块/循环作用域；
- `FIELD_FREE`：字段级级联；
- `RET_FREE` / `COND_FREE` / `INCR_FREE`：临时对象清理点。

---

## 5. 后端：释放代码生成

### 5.1 `funcHandle` 的整体顺序

```go
// compile/compiler.go（简化）
c.Ctx.RetScratchCap = gc.LLRResults[c.currentFuncKey].RetScratchSlots
code += c.Ctx.Arch.Prologue(funcBlock)
code += c.Compile(c.Ctx.Now)
if funcBlock.Name.String() != "main" && alias == "" {
    code += c.emitGCFrees(funcBlock, node) // 出口释放
}
code += c.Ctx.Arch.Epilogue(funcBlock)
```

`Prologue` 按 `RetScratchCap` 预留并清零 scratch 槽；`Epilogue` 的第一行才是
`func_end_<name>:` 标签。这个顺序造成了 §9.1 的出口释放缺口。

### 5.2 释放点与生成代码形状

| 释放点 | 后端函数 | 生成的调用 |
|---|---|---|
| 函数出口变量 | `emitGCFrees` → `freeSlot` | `lea RDI, [rbp-off]` / `call std_memory_freeSlot` |
| 函数出口字段 | `emitGCFrees` → `free` | 取父指针、`add fieldOff`、加载字段、`call std_memory_free` |
| 块尾 | `emitBlockFrees` → `emitSlotFrees` | `freeSlot(&var)` |
| 循环出口 | `emitLoopExitFrees` | `freeSlot(&var)` |
| 覆盖赋值 | `emitAssignFrees` | 写入新值前 `freeSlot(&var)` |
| `ret` 临时 | `compileReturnBlock` | 保存返回值寄存器 → `freeSlot(scratch)` → 恢复 → `ReturnJump` |
| 条件临时 | `compileIfBlock`/`compileForBlock` | 条件求值后两条路径各 `freeSlot(scratch)` |
| 增量临时 | `compileForBlock` + `ForEnd(cleanup)` | 增量后、回跳前 `freeSlot(scratch)` |

### 5.3 函数出口释放

`emitGCFrees` 的顺序是：

1. **先字段，后父对象**：`FieldFrees` 逐条释放 `var.field`，避免父块先释放后
   再去读字段；
2. **再变量**：`Frees` 逐条 `freeSlot(&var)`；
3. 变量槽找不到（未分配/被豁免）就跳过；
4. `Type == "heap-ptr"` 的孤儿条目把 `fr.VarName`（实际存的是分配 site）
   与 `Objects` 中同 `Site` 且 `Name != ""` 的帧内对象匹配，用该对象名当变量名；
   匹配不到就跳过（当前孤儿机制基本不会真正释放，见 §9.3）。

`main` 和 `build link` 别名只跳过**出口**释放，其余释放点不受影响：

```go
if funcBlock.Name.String() != "main" && alias == "" {
    code += c.emitGCFrees(funcBlock, node)
}
```

### 5.4 块尾与循环出口

- `compileIfBlock` 在 then 体末尾 `emitBlockFrees(n)`；`compileElseBlock` 在
  else 体末尾同理；
- `compileForBlock` 在 body 末尾 `emitBlockFrees(n)`，然后 `ForEnd` 处理增量、
  清理、回跳；`for_end` 后再 `emitLoopExitFrees(n)`；
- 进入分支/循环前，`emitGCZeroSlots` 把“该块将释放的局部槽”清零。原因：
  `if` 条件为假、`for` 零次迭代、`break` 提前跳出时，块尾 `freeSlot` 可能看到
  未初始化的栈槽；
- `freeSlot` 成功后清槽，因此“块尾已释放 + 循环出口再释放”是幂等的，不会
  双释放。

### 5.5 覆盖赋值前释放

`compileVarBlock` / `compileExprBlock` 在写入新值前调用：

```go
code := c.emitAssignFrees(n)
// 然后才是 VarDecl / VarDecl 表达式
```

`emitAssignFrees` 查 `LLRResults[currentFunc].AssignFrees[n]`，对每个旧对象执行
`freeSlot(&x)`。前提是 `canFreeOverwrite` 已证明旧对象唯一、未共享、未逃逸。

### 5.6 `ret` 临时对象与 scratch

`compileReturnBlock` 的步骤：

```go
frees := gc.RetFreesForNode(c.currentFuncKey, n)
if len(frees) == 0 || c.Ctx.RetScratchBase == 0 {
    return c.Ctx.Arch.Return(ret) // 无临时对象：直接返回值 + 跳出口
}

// 1. 为每个临时对象分配 scratch 槽，登记 Call → 槽偏移
for i, rf := range frees {
    c.Ctx.RetScratchMap[rf.Call] = c.Ctx.RetScratchBase + i*slotSize
}

// 2. 生成返回值（不跳转）
code += c.Ctx.Arch.ReturnValue(ret)

// 3. 保存返回值寄存器（free 是普通调用，会破坏 caller-saved）
code += push retReg / push hiReg

// 4. 逐个 freeSlot(scratch)
// 5. 恢复返回值寄存器
// 6. ReturnJump → func_end_<fn>
```

为什么需要 scratch：内层调用返回的指针放在 `RAX`，外层调用会覆盖 `RAX`；
先把内层结果写进 `[rbp+scratch]`，外层调用返回后再按槽释放。容器返回值
（string/list 等 3 槽大值）从 `RetSlot` 取指针，而不是直接取 `RAX`。

### 5.7 条件/增量临时对象

`compileIfBlock` 生成的控制流：

```
compileCondition(cond, falseLabel, trueLabel)
jmp trueLabel                 ; 真路径落点在此，跳过 false 清理块
falseLabel:
    free cond temporaries
    jmp else_<label> / end_<label>
trueLabel:
    free cond temporaries
    <if body>
```

关键点：比较/单表达式条件只生成“假 → `falseLabel`”的跳转，真路径是直落；
因此必须在 false 清理块前插入 `jmp trueLabel`，否则真路径会执行 false 清理块。
`||` 链的真跳转直接落到 `trueLabel`，不经过这条 `jmp`。

`for` 条件/增量的形状：

```
prepareScratchFrees(CondFreesForNode)
ForBeginCond(forBlock, falseLabel, trueLabel)
  falseLabel: free cond; jmp for_end
  trueLabel:  free cond; <body>
  body 尾:    block frees
  ForEnd(forBlock, incrPlan.code)
    ; 增量 → free incr → jmp for_<n>
  for_<n>_end:
    loop exit frees
```

### 5.8 scratch 槽协议

| 项 | 位置/字段 | 说明 |
|---|---|---|
| 容量 | `LLRResult.RetScratchSlots` | `max(len(RetFrees), len(CondFrees), len(IncrFrees))` |
| 预留 | `compile/context.Context.RetScratchBase/RetScratchCap` | Prologue 按 cap 预留 `cap*ptrSize` |
| 清零 | `Prologue` | 每个槽初始为 0，短路/未求值路径 `freeSlot` 安全跳过 |
| 登记 | `Ctx.RetScratchMap[call] = off` | 后端编译调用时按 `CallBlock` 指针查槽 |
| 捕获 | `Arch.Call` | 内层调用返回后把 `RAX/EAX` 写入槽 |
| 释放 | `freeSlot(&slot)` | 成功后槽清 0，重复清理幂等 |
| 注销 | `releaseScratchFrees` | 表达式编译结束后删除登记，避免污染后续调用 |

三类清理点不会同时求值，所以可以复用同一段槽；但**同一函数内不同 return 节点**
的临时对象也不会同时存在，槽位同样复用。

### 5.9 架构差异

`compile/arch/arch.go` 提供与 GC 相关的抽象：

| 方法 | 作用 |
|---|---|
| `Prologue` / `Epilogue` | 预留 scratch、发 `func_end_<name>`、恢复栈帧 |
| `ReturnValue` / `ReturnJump` | 把“返回值生成”和“跳公共出口”拆开，供 ret 临时释放插入 |
| `ForBeginCond` / `ForEnd` | 条件/增量清理点插入 |
| `ReturnReg` | 返回值寄存器（x64 `RAX`，x86 `EAX`） |
| `PointerSize` | 8/4，决定槽宽和 `[rbp/ebp]` |

x64 SysV：

- `freeSlot` 参数走 `RDI`：`lea RDI, [rbp-off]`；`call std_memory_freeSlot`；
- `ret` 临时释放保存 `RAX`/`RDX`；
- scratch 每槽 8B，`Prologue` 清零用 `QWORD`。

x86 cdecl：

- `freeSlot` 参数压栈：`lea eax, [ebp-off]`；`push eax`；`call ...`；
- `ret` 临时释放保存 `EAX`/`EDX`；
- scratch 每槽 4B，清零用 `DWORD`。

### 5.10 生成代码样例

来自 `test/gcOwnership` 的 `testNestedAlloc`（x64）：

```asm
; return值存入RAX
jmp func_end_testNestedAlloc
; gc: free field a.child
mov RAX, QWORD [rbp-48]
test RAX, RAX
jz gc_field_skip1
add RAX, 8
mov RAX, QWORD [RAX]
mov RDI, RAX
call std_memory_free
gc_field_skip1:
; gc: free a
lea RDI, [rbp-48]
call std_memory_freeSlot
func_end_testNestedAlloc:
add rsp, 104
...
```

这段同时展示了字段释放先于父对象、`freeSlot(&var)` 的形态，以及 §9.1 的
“`jmp func_end` 在释放代码之前”问题。

---

## 6. 运行时：分配器

### 6.1 内存布局

普通块：

```
低地址                                              高地址
┌──────────┬──────────────────────┬──────────┐
│ header   │ user data ...        │ footer   │
│ ptrSize  │ size 字节            │ ptrSize  │
└──────────┴──────────────────────┴──────────┘
           ▲
           └── malloc 返回的用户指针 ptr
```

RC 块：

```
┌──────────┬──────────┬──────────┬──────────────────┬──────────┐
│ header   │ RC       │ flags    │ user data ...    │ footer   │
│ ptrSize  │ ptrSize  │ ptrSize  │ size 字节        │ ptrSize  │
└──────────┴──────────┴──────────┴──────────────────┴──────────┘
                                 ▲
                                 └── mallocRC 返回的 ptr
```

- `header`/`footer` 存块大小 + 标志位；
- 普通块用户指针 = 块起始 + `ptrSize`；
- RC 块用户指针 = 块起始 + `3*ptrSize`；
- `free(ptr)` 读 `ptr - ptrSize`：普通块读到 header 的大小（RC_BIT 为 0），
  RC 块读到 flags（RC_BIT 为 1），据此分派。

常量（`pkg/memory/const.cute`）：

| 常量 | 值 | 含义 |
|---|---|---|
| `TINY_MAX` | 1024 | TINY 上限 |
| `SMALL_MAX` | 4096 | SMALL 上限 |
| `MIDDLE_MAX` | 65536 | MIDDLE 上限 |
| `LARGE_MAX` | 262144 | LARGE 上限；之上为 HUGE |
| `IS_FREE` | 1 | 块空闲 |
| `PREV_FREE` | 2 | 前一块空闲 |
| `RC_BIT` | 4 | RC 块标记 |
| `FLAG_MASK` | 7 | 大小/标志分离掩码 |

`ptrSize` 由架构文件定义：x64=8，x86=4。

### 6.2 `malloc`

```cute
fn malloc(size: uint) ptr
```

步骤：

1. `initFreeHeads()`：首次调用用 `brk` 分配 60 个空闲链表头（60*8=480B），
   不走 `malloc`，避免循环依赖；
2. `req = size + 2*ptrSize`，最小 `4*ptrSize`（x64 32B，x86 16B）；
3. 按 `req` 选路径：
   - `req > LARGE_MAX`：HUGE，直接 `brk` 扩展；
   - `req > MIDDLE_MAX`：LARGE，`brk` 扩展 + `coalesce`；
   - 否则 TINY/SMALL/MIDDLE：按 `slotOf(req)` 取空闲链表，空链则 `commit`；
4. 返回 `块起始 + ptrSize`。

tier 与 class 对应（`blkSizeOf`）：

| class | 区域 | 块大小 |
|---|---|---|
| 0-33 | TINY | 32B 起，按 12.5% 增长，最小步长 16B，按 ptrSize 对齐 |
| 34-35 | SMALL | 2048B / 4096B |
| 36-59 | MIDDLE | 4096B 起，按 12.5% 增长 |
| — | LARGE | `brk` + coalesce，无空闲链表 |
| — | HUGE | `brk`，无空闲链表 |

空闲块在 data 区前两个字存 `next/prev`；`freeListClassOf` 按“规范块大小 <=
实际块大小”的最大 class 入链，避免合并块 footer 越界。

### 6.3 `free` / `freeAt` / `freeSlot`

```cute
fn free(ptr: ptr) bool
fn freeAt(blk: ptr) bool        // blk 是块起始，不是用户指针
fn freeSlot(slot: *ptr) bool
```

`free`：

1. `ptr == 0` → `true`；
2. `flags = flagLoad(ptr)`（即 `ptr - ptrSize`）；
3. `flags & RC_BIT != 0` → `rcDec(ptr)`，返回 `true`；
4. 否则 `freeAt(ptr - ptrSize)`。

`freeAt`：

- HUGE：只有块在堆顶（`blk + pure == brk(0)`）才 `brk` 回缩，否则 `false`；
- LARGE：先 `coalesce`，合并后在堆顶才回缩，否则 `false`；
- TINY/SMALL/MIDDLE：`coalesce` 后插入空闲链表，返回 `true`。

`freeSlot`：

```cute
var p: ptr = *slot
if p == 0 { ret true }
if free(p) {
    *slot = 0
    ret true
}
ret false
```

语义要点：

- `free(nil)` 安全；`freeSlot(nil)` 安全；
- 普通块：`freeSlot` 在 `freeAt` 真正回收时清槽；LARGE/HUGE 非堆顶返回
  `false`，槽保留，以后堆顶时还可以再试；
- RC 块：`free()` 走 `rcDec` 后**总是返回 `true`**，即使 RC 仍大于 1、内存
  尚未回收。此时 `freeSlot` 清槽表示“本引用已释放”，不表示“内存已回收”；
- 生成代码通常忽略 `free/freeSlot` 的返回值，依赖“清槽 + 幂等”兜底；
- 直接对非堆指针调用 `free` 是未定义行为；不要把栈上 string/list 头的地址
  当普通块传进去（`freeSlot(&s)` 会先读首字，释放的是缓冲）。

### 6.4 `calloc` / `realloc`

```cute
fn calloc(n: uint) ptr
fn realloc(ptr: ptr, newSize: uint) ptr
```

- `calloc(n)`：`malloc(n)` + `memset(p, 0, n)`；分配失败返回 0；
- `realloc(p, 0)`：`free(p)` 后返回 0；
- `realloc(p, n)` 且 `n <= 当前块大小`：直接返回原指针（不缩小）；
- 否则尝试与下一空闲块合并原地扩展；失败则 `malloc + memcpy + free`；
- **`realloc` 只适用于普通 `malloc/calloc` 块**。RC 块的用户指针前是 flags，
  不是普通 header；对 RC 指针调用 `realloc` 会算错块起点。RC 扩容应手动
  `mallocRC + 复制 + rcDec/freeRC`。

### 6.5 分配器 API 表

| API | 签名 | 返回/副作用 |
|---|---|---|
| `malloc` | `fn malloc(size: uint) ptr` | 返回用户指针；失败 0 |
| `calloc` | `fn calloc(n: uint) ptr` | 零初始化；失败 0 |
| `realloc` | `fn realloc(ptr: ptr, newSize: uint) ptr` | 可能搬移；失败 0 |
| `free` | `fn free(ptr: ptr) bool` | 释放/RC 递减；false 仅 LARGE/HUGE 非堆顶 |
| `freeAt` | `fn freeAt(blk: ptr) bool` | 释放块起始；内部使用 |
| `freeSlot` | `fn freeSlot(slot: *ptr) bool` | 释放并清槽；适合重复清理 |
| `memset` | `fn memset(s: ptr, c: u8, n: uint) ptr` | 填充 |
| `memcpy` | `fn memcpy(dest: ptr, src: ptr, n: uint) ptr` | 复制 |
| `memmove` | 架构文件提供 | 重叠复制 |

### 6.6 分配器约束

- **单线程**：没有锁/原子操作；RC 也不原子。多线程共享堆/RC 需要外部串行化。
- LARGE/HUGE 中段释放不归还 OS，空间滞留在堆内；这是 brk 模型的固有限制。
- 没有 double-free 检测；`freeSlot` 的清槽只保护“同一个槽的重复清理”，
  不保护两个不同指针指向同一块。
- 空闲链表 60 个 class；`commit` 失败返回 0；调用方必须检查 `malloc` 返回值。

---

## 7. 运行时：引用计数（RC）

### 7.1 设计定位

RC 是**按对象选用**的，不是全局 GC：

- `new(T)` 产生普通块，由编译期 LLR 或手动 `free` 管理；
- `newRC(T)` 产生带 RC 头的块，初始 RC=1，生命周期由用户 `rcInc/rcDec` 管理；
- LLR 明确跳过 `newRC` 对象（`objRCAlloc`），不会生成自动释放；
- `free()` 对 RC 块自动走 `rcDec`，所以普通指针释放路径也能安全处理 RC 块。

### 7.2 API 表

| API | 签名 | 语义 |
|---|---|---|
| `mallocRC` | `fn mallocRC(size: uint) ptr` | 分配 RC 块，RC=1，flags=RC_BIT，登记 tracker |
| `freeRC` | `fn freeRC(ptr: ptr) bool` | 直接释放 RC 块（不检查 RC，不递减） |
| `freeRCSlot` | `fn freeRCSlot(slot: *ptr) bool` | 直接释放并清槽 |
| `rcInc` | `fn rcInc(p: ptr)` | RC+1 |
| `rcDec` | `fn rcDec(p: ptr) bool` | RC-1；归零时 `trackFree + freeRC`，返回 true |
| `rcGet` | `fn rcGet(p: ptr) uint` | 读 RC |
| `rcTryRelease` | `fn rcTryRelease(p: ptr) bool` | 递减但不释放；归零返回 true，由调用方决定是否释放 |
| `rcIsOne` | `fn rcIsOne(p: ptr) bool` | RC==1 |
| `rcSet` | `fn rcSet(p: ptr, n: uint)` | 直接设置 RC |
| `rcAdd` | `fn rcAdd(p: ptr, n: uint)` | RC+n |
| `rcSub` | `fn rcSub(p: ptr, n: uint) bool` | RC-n；归零时释放 |

### 7.3 `free` 的自动分派

```cute
fn free(ptr: ptr) bool {
    if ptr == 0 { ret true }
    var flags: uint = flagLoad(ptr)
    if (flags & RC_BIT) != 0 {
        rcDec(ptr)
        ret true
    }
    ret freeAt(ptr - ptrSize)
}
```

因此：

- `freeSlot(&rcPtr)` 对 RC 块是“释放调用方持有的一个引用”；
- 若 RC>1，只递减，不释放；槽被清 0，调用方不再持有该引用；
- 若 RC==1，`rcDec` 归零并 `freeRC`；
- `freeRC` 是“强制释放”，不递减、不检查其它引用；只应在确定没有其它
  owner 时使用。混用 `freeRC` 和 `free` 可能提前释放。

### 7.4 泄漏追踪器

`pkg/memory/tracker.cute`：

| API | 签名 | 语义 |
|---|---|---|
| `trackAlloc` | `fn trackAlloc(p: ptr)` | 记录一次 RC 分配，`gAllocCount++` |
| `trackFree` | `fn trackFree(p: ptr)` | 从表移除，`gFreeCount++` |
| `reportLeaks` | `fn reportLeaks() uint` | 当前未释放 RC 数 |
| `reportAllocCount` | `fn reportAllocCount() uint` | 总分配次数 |
| `reportFreeCount` | `fn reportFreeCount() uint` | 总释放次数 |
| `resetLeakTracker` | `fn resetLeakTracker()` | 清零计数 |

限制：

- 只追踪 `mallocRC` 的块，普通 `malloc` 不登记；
- 表容量 256 条，满了静默丢弃明细；分配/释放计数仍累加；
- `freeRC` 不调用 `trackFree`，`rcDec` 归零才调用；直接 `freeRC` 会让追踪器
  留下“泄漏”假阳性；
- 删除是 O(n) 线性查找 + 末尾覆盖。

### 7.5 RC 与 LLR 的边界

- `newRC` 对象在 LLR 中标记 `objRCAlloc`，不进入 `Frees`/`BlockFrees`；
- `isRCAlloc` 只看 `Expression.Call.IsRC`；
- 用户必须自己配对 `rcInc/rcDec`；编译器不会在作用域结束自动插入 RC 操作；
- `pkg/memory/gc/gc.cute` 是一个只有 `rcInc/rcDec/rcGet` 的轻量副本；
  排查/修改以 `pkg/memory/rc.cute` 为准。

---

## 8. 端到端示例

### 8.1 源码

```cute
type Node struct {
    val: int
    next: *Node
}

fn makeNode(v: int) *Node {
    var n: *Node = new(Node)
    n.val = v
    ret n
}

fn runBuild() int {
    var sum: int = 0
    var i: int = 0
    for ; i < 3; {
        var tmp: *Node = makeNode(i)
        sum = sum + tmp.val
        i = i + 1
    }
    var a: *Node = makeNode(10)
    var b: *Node = makeNode(20)
    ret sum + a.val + b.val
}

fn main() int {
    ret runBuild()
}
```

（`build` 是关键字，示例函数名用 `runBuild`。）

### 8.2 摘要

```json
== makeNode
{
  "name": "makeNode",
  "retOwned": true,
  "retEscape": 1,
  "retKind": 1,
  "callsAny": ["new"],
  "hasHeapAllocs": true
}

== runBuild
{
  "name": "runBuild",
  "retOwned": false,
  "retEscape": 0,
  "retKind": 0,
  "callsAny": null,
  "hasHeapAllocs": true
}
```

`makeNode` 的 `retKind=1` 是 `RetFresh`：调用方拿到新对象所有权。它的
`callsAny=["new"]` 说明 `new` 被当作未知调用，导致 `makeNode` 自己的 LLR 为空；
但 `n` 是返回值，本来就不该在本帧释放，所以这个例子不受影响。

`runBuild` 调用的 `makeNode` 有摘要，因此 LLR 正常：

```
== runBuild
  obj[0] tmp site=call:makeNode FRAME_OWN
  obj[1] a site=call:makeNode FRAME_OWN
  obj[2] b site=call:makeNode FRAME_OWN
  FREE tmp [unknown] scope=1
  FREE a [unknown]
  FREE b [unknown]
  FIELD_FREE tmp.next [unknown]
  FIELD_FREE a.next [unknown]
  FIELD_FREE b.next [unknown]
```

### 8.3 生成汇编（x64，节选）

```asm
; Function: runBuild
runBuild:
    push rbp
    mov rbp, rsp
    ...
    sub rsp, 120
    mov QWORD [rbp-64], 0; gc: zero slot tmp
for_1:
    ...
    call makeNode
    mov QWORD[rbp-64], RAX
; 设置变量tmp
    ...
; 设置变量i
    ; gc: block free tmp
    lea RDI, [rbp-64]
    call std_memory_freeSlot
    jmp for_1
for_1_end:
    ; gc: loop exit free tmp
    lea RDI, [rbp-64]
    call std_memory_freeSlot
    ...
    call makeNode
    mov QWORD[rbp-72], RAX
; 设置变量a
    ...
    call makeNode
    mov QWORD[rbp-80], RAX
; 设置变量b
    ...
; return值存入RAX
    jmp func_end_runBuild
    ; gc: free field tmp.next
    ...
    ; gc: free a
    lea RDI, [rbp-72]
    call std_memory_freeSlot
    ; gc: free b
    lea RDI, [rbp-80]
    call std_memory_freeSlot
    func_end_runBuild:
    add rsp, 120
    ...
```

### 8.4 运行时路径

1. `makeNode` 内 `new(Node)` → `std_memory_malloc(16)` → 普通块；
2. `makeNode` 返回 `n`（`RAX`），`RetKind=Fresh`，调用方拥有；
3. `runBuild` 把返回值存入 `tmp/a/b` 栈槽；
4. 循环体尾 `block free tmp` → `freeSlot(&tmp)` 释放当前迭代的 Node；
5. `for_end` 的 `loop exit free tmp` 看到槽已清 0，安全跳过（覆盖 `break` 的
   路径则在这里释放）；
6. `ret` 语句先 `jmp func_end_runBuild`，因此后面的 `free a/b` 和
   `FIELD_FREE` **不会执行**（§9.1）；
7. `main` 只跳过函数出口释放；块尾/循环出口等释放点仍会生成（另一个示例
   函数的 `main` 中可见 `gc: block free` / `gc: loop exit free`）。

### 8.5 这个例子说明了什么

- 块尾释放和循环出口释放是**可达且生效**的；
- 函数出口释放代码目前是**不可达**的（显式 `ret` 跳过）；
- `makeNode` 的 `new` 让它自己的 LLR 为空，但返回值所有权仍然正确；
- `RetFresh` 是“调用方能接管”的关键摘要；没有它，`runBuild` 不会把
  `tmp/a/b` 当作帧内拥有对象。

---

## 9. 安全边界与已知缺口

### 9.1 缺口一：函数出口释放被 `ret` 跳过

**现象**：`funcHandle` 先拼 `emitGCFrees`，再拼 `Epilogue`；`Epilogue` 的第一行
才发 `func_end_<name>:`。而 `compileReturnBlock` 的显式 `ret` 会生成
`jmp func_end_<name>`。因此：

```
jmp func_end_runBuild       ; ret 直接跳走
; gc: free field ...
; gc: free a
; gc: free b
func_end_runBuild:          ; 标签在释放代码之后
```

`Frees` / `FieldFrees` 只有在函数体**自然直落**到出口（无显式 `ret`）时才执行。
所有以 `ret` 结束的函数，其函数出口释放计划都是死代码。

**影响**：依赖出口释放的命名对象不会被回收；块尾/循环出口/覆盖赋值/ret 临时/
条件临时释放不受影响。`main` 本来就不生成出口释放。

**核对方式**：`test/gcOwnership` 的 `testNestedAlloc`、示例 `runBuild` 的
`_main.asm` 都能看到 `jmp func_end_*` 在 `gc: free` 之前。

**修复方向**（未实施）：把出口释放代码插到 `func_end_<name>:` 标签之后、
栈帧清理之前；或让 `Epilogue` 接受一段“出口清理”代码并在标签后发出。修复后
必须重新审计字段级 cascade 与共享别名（见 §9.4），因为当前不可达的代码一旦
可达，可能会释放被字段/别名共用的对象。

### 9.2 缺口二：`new` 进入 `CallsAny`，整个函数 LLR 被禁用

**现象**：`applyCallee` 对没有摘要的调用会执行：

```go
if _, pure := pureBuiltinEscapes(name); pure { return }
fs.CallsAny = appendUnique(fs.CallsAny, name)
```

`pureBuiltinEscapes` 只列了 `len/cap/sizeof/print/println/panic`，没有 `new`。
`new` 是内建分配，但摘要键 `"new"` 在 `Table` 里没有条目，于是被当成未知调用。
`ComputeLLR` 开头 `hasRealAnyCalls(fs.CallsAny)` 直接返回空结果。

**影响**：任何**直接**在函数体里写 `new(T)` 的函数，都不会生成该函数的 LLR
释放计划（包括它的块尾/覆盖/ret 临时释放）。`test/gcOwnership` 的
`testLocalAlloc` 是现成例子：`callsAny: ["new"]`，`gc_llr.txt` 没有任何 FREE。
通过有摘要的 helper（如 `makeNode`）间接分配的函数不受影响。

**修复方向**（未实施）：在 `applyCallee` 里把 `cb.IsBuiltinNewAlloc()` 当作
已知的 fresh 分配处理，或把 `"new"`/`"make"` 加入纯内建白名单（并确认
`new` 的实参/初值不会保存别名）。修复后需要重跑四个 GC 回归和 esccheck 基线。

### 9.3 孤儿对象与匿名临时

- `orphans` 的注释明确写着“孤儿机制当前不会在出口实际释放无名对象，仅保留
  调试信息”；`emitGCFrees` 对 `Type=="heap-ptr"` 的条目要求能匹配到
  `Objects` 中 `Name != ""` 的绑定，孤儿通常匹配不到，于是跳过。
- 因此“被覆盖掉、又没有 canonical 名字”的旧对象，若覆盖点不满足
  `canFreeOverwrite`，就不会被自动释放。
- 这类对象要么在覆盖点安全释放，要么留到进程退出；不会产生悬空指针，但会
  造成泄漏。

### 9.4 字段级 cascade 的边界

- `collectStructFieldFrees` 只枚举**直接** owning 字段（`*T`、`string`、`list`）；
  内联 struct 值里的嵌套 owning 字段不会递归展开。
- 字段级释放只出现在函数出口（`FieldFrees`），块尾/循环出口没有字段 cascade。
- 当前出口释放不可达（§9.1），所以字段 cascade 实际不执行；一旦修复 §9.1，
  需要重新审计“字段值来自别名/参数/共享对象”的情况，避免父对象释放字段时
  把仍被其它名字持有的对象提前释放。`objShared` 目前主要保护覆盖释放，不保护
  字段 cascade。

### 9.5 `realloc` 不支持 RC 块

`realloc` 用 `ptr - ptrSize` 当普通 header；RC 块的这个位置是 flags，不是
header。对 RC 指针调用 `realloc` 会算错块起点。RC 扩容必须手动：

```cute
var np: ptr = memory.mallocRC(newSize)
memory.memcpy(np, p, oldSize)
memory.rcDec(p)
```

### 9.6 追踪器只覆盖 RC，且有 256 条上限

- `trackAlloc` 只在 `mallocRC` 的三个路径调用；普通 `malloc` 不追踪；
- 表满 256 条后静默丢弃明细，`reportLeaks` 只能作为参考；
- `freeRC` 不 `trackFree`，直接 `freeRC` 会产生泄漏假阳性；
- 计数 `gAllocCount/gFreeCount` 仍会累加。

### 9.7 分配器与 RC 的通用边界

- 非线程安全：无锁、无原子；RC 的 `rcInc/rcDec` 也是普通读改写；
- 无 double-free 检测：`freeSlot` 只保证同一槽的重复清理幂等；
- LARGE/HUGE 非堆顶释放返回 `false`，空间滞留堆内；
- `free` 对非堆指针是未定义行为；string/list 头必须通过 `freeSlot(&s)` 让
  运行时读首字缓冲指针，不能把头的地址直接传给 `free`；
- `malloc` 可能返回 0，调用方必须检查；
- `realloc` 不缩小、可能搬移；旧指针在成功搬移后失效。

### 9.8 设计性保守（不是 bug）

- 未知调用 → 整个函数不释放；
- 全局拥有存储 → 整个函数不释放；
- `main` / `build link` 别名 → 只跳过函数出口释放；块尾/循环出口/覆盖赋值/
  临时释放仍生成；
- 别名/共享 → 不做提前释放；
- 参数 → 永远由调用者管理；
- `newRC` → 永远不自动释放；
- LLR 是函数内、语句级前向分析，不做路径敏感/堆形状分析；证明不了就放弃。

这些保守规则的目标是**正确性优先**：宁可泄漏，不产生 use-after-free。

---

## 10. 调试与验收

### 10.1 产物

| 产物 | 位置 | 内容 |
|---|---|---|
| `gc_summary.json` | 被测目录 | 分节 JSON 文本，所有 `FnSummary` |
| `gc_llr.txt` | 被测目录 | 所有 `LLRResult` 的可读 dump |
| `_main.asm` | 当前工作目录（`-S`） | 生成的汇编，含 `; gc:` 注释 |
| `ast.html` | 运行流产物 | 不算资产，不提交 |

这些运行产物在 `.gitignore` 中：`test/*/gc_summary.json`、`test/*/gc_llr.txt`、
`test/*/gc_frees.txt`、`ast.html`。提交时不要捎带。

### 10.2 命令

```bash
# 构建编译器
go build -o /tmp/opencode/cute-gc .

# 生成汇编 + GC 产物（示例）
mkdir -p /tmp/opencode/gc-run
cd /tmp/opencode/gc-run
CUTE_ROOT=/home/gx/Desktop/代码/tiny \
CUTE_ARCH=x86_64 \
/tmp/opencode/cute-gc -S /home/gx/Desktop/代码/tiny/test/gcOwnership

# 看释放计划
grep -n "FREE\|RET_FREE\|COND_FREE\|INCR_FREE" gc_llr.txt
# 看生成的释放代码
grep -n "gc: free\|func_end_" _main.asm
```

双架构回归：

```bash
./test_run.sh test/gcCondTemp x86_64 x86
./test_run.sh test/gcRetFree  x86_64 x86
./test_run.sh test/gcBlocks   x86_64 x86
./test_run.sh test/gcOverwrite x86_64 x86
```

四个用例的期望退出码都是 `0`（程序内断言通过）。x86 侧另有预存红面
（如 `sortTest` 的 `COMPILE_FAIL`），不属于 GC 回归，按 `PROJECT.md` 的基线
区分“预存红”与“本轮回归”。

### 10.3 当前验收基线

截至 2026-11-04（`PROJECT.md` 的 GC 收口基线）：

- `test/gcCondTemp`、`test/gcRetFree`、`test/gcBlocks`、`test/gcOverwrite`
  双架构均为 `RC:0`；
- `test/sortTest` x64=`110`、x86=`COMPILE_FAIL:2`（与基线一致，非 GC 回归）；
- 全 `test/` 目录聚合的 `tools/esccheck`：可解析 106 个、不可解析 9 个、
  对象 117、`RC/泄漏释放=6`、`泄漏=0`、`提前释放=0`；
- 9 个 FAIL 是既有不可解析目录，不是本轮引入。

对象数会随源码和语料变化；验收时以“**泄漏=0、提前释放=0、四个 GC 回归
双架构 0**”为准，不要死记对象数。

`tools/esccheck` 是诊断工具，读的是 `parser.SimulateRC` 模型，不是
`compile/gc`；它的“泄漏=0”不能证明后端生成代码没有泄漏，反之亦然。两者要
分开看：

| 检查 | 覆盖 | 不能覆盖 |
|---|---|---|
| `tools/esccheck` | parser 作用域模型的对象归属 | 后端实际是否发出 `free`、是否可达 |
| 四个 GC 回归 | 后端块尾/循环/覆盖/ret/条件释放的可执行行为 | 未覆盖语法形态、运行时大块滞留 |
| `gc_llr.txt` | LLR 计划是否生成 | 计划是否可达（如 §9.1） |
| `_main.asm` | 实际生成的释放代码与位置 | 运行时是否真的走到 |

### 10.4 排查清单

1. **没有 FREE**：先看 `gc_summary.json` 的 `callsAny` 是否非空（`new` 是常见
   元凶）、`hasGlobalOwnStore` 是否为 true、`hasHeapAllocs` 是否为 false。
2. **有 FREE 但没执行**：看 `_main.asm` 中 `jmp func_end_*` 是否在 `gc: free`
   之前（§9.1）。
3. **释放错对象**：检查 `objShared`/别名、字段赋值、参数来源；LLR 对共享对象
   应放弃提前释放。
4. **运行时 SIGSEGV**：确认 `freeSlot` 的槽首字确实是堆指针；string/list 头
   不能直接 `free`；RC 指针不能传给 `realloc`。
5. **RC 泄漏**：`reportLeaks` 只统计 `mallocRC`；确认 `rcInc/rcDec` 配对，
   避免混用 `freeRC` 与 `free`。
6. **LARGE/HUGE 不释放**：`freeAt` 只在堆顶回缩；`freeSlot` 返回 false 时槽
   未清，属预期行为。

---

## 附录 A：API 速查

### A.1 编译器侧（Go）

```go
// 以下均为 package gc 的包级符号，调用方写 gc.Build、gc.Table 等。

// 全程序分析
func Build(root *parser.Node)

// 全局表
var Table map[string]*FnSummary
var LLRResults map[string]*LLRResult

// 单函数 LLR（Build 内部调用；单态化克隆体会再次调用）
func ComputeLLR(fnKey string, fb *parser.FuncBlock,
                fs *FnSummary, body *parser.Node) *LLRResult

// 摘要查询
func ParamEscapes(calleeKey string, idx int) Escape
func CalleeKnown(calleeKey string) bool

// 节点级释放查询（必须传同一 AST 节点）
func RetFreesForNode(fnKey string, n *parser.Node) []LLRRetFree
func CondFreesForNode(fnKey string, n *parser.Node) []LLRCondFree
func IncrFreesForNode(fnKey string, n *parser.Node) []LLRCondFree

// dump
func DumpSummary(fs *FnSummary) string
func DumpAll(w io.Writer) error
func DumpLLRs() string
func DumpLLR(res *LLRResult) string
func DumpFrees() string
```

### A.2 后端内部函数（`compile/compiler.go`）

```go
func (c *Compiler) emitGCFrees(fb *parser.FuncBlock, node *parser.Node) string
func (c *Compiler) emitBlockFrees(blockNode *parser.Node) string
func (c *Compiler) emitLoopExitFrees(loopNode *parser.Node) string
func (c *Compiler) emitAssignFrees(n *parser.Node) string
func (c *Compiler) emitSlotFrees(blockNode *parser.Node,
                                 frees []gc.LLRFree, tag string) string
func (c *Compiler) emitGCZeroSlots(blockNode *parser.Node,
                                   frees []gc.LLRFree) string
func (c *Compiler) prepareScratchFrees(frees []gc.LLRCondFree,
                                       tag string) scratchFreePlan
func (c *Compiler) releaseScratchFrees(plan scratchFreePlan)
```

### A.3 运行时（`std:memory`）

```cute
// 分配器
fn malloc(size: uint) ptr
fn calloc(n: uint) ptr
fn realloc(ptr: ptr, newSize: uint) ptr
fn free(ptr: ptr) bool
fn freeSlot(slot: *ptr) bool

// 引用计数
fn mallocRC(size: uint) ptr
fn freeRC(ptr: ptr) bool
fn freeRCSlot(slot: *ptr) bool
fn rcInc(p: ptr)
fn rcDec(p: ptr) bool
fn rcGet(p: ptr) uint
fn rcTryRelease(p: ptr) bool
fn rcIsOne(p: ptr) bool
fn rcSet(p: ptr, n: uint)
fn rcAdd(p: ptr, n: uint)
fn rcSub(p: ptr, n: uint) bool

// 追踪
fn reportLeaks() uint
fn reportAllocCount() uint
fn reportFreeCount() uint
fn resetLeakTracker()
```

调用方式：源文件 `import "std:memory"`，然后 `memory.malloc(n)` 等；编译器
生成的调用标签是 `std_memory_<fn>`（如 `std_memory_freeSlot`）。

---

## 附录 B：术语表

| 术语 | 含义 |
|---|---|
| owning | 类型自身携带堆指针：`*T`、`string`、`list` |
| 逃逸 | 对象被保存到本帧之外，或通过返回值/全局/字段被他人持有 |
| canonical owner | 唯一、未共享、未逃逸的命名绑定 |
| FRAME_OWN | LLR 判定“帧内拥有、未逃逸、可自动释放” |
| LLR | Local Release，按语句前向扫描的局部释放分析 |
| scratch | 函数栈帧中为临时对象指针预留的槽，供 `freeSlot` 使用 |
| `RetFresh` | 返回值是新分配，所有权转移给调用方 |
| `RetAliasMask`/`RetBorrowMask` | 返回值可能复用参数的位图；非零则调用方不得释放 |
| RC | 引用计数；仅对 `newRC` 对象启用，手动管理 |
| tier | 分配器块大小分级：TINY/SMALL/MIDDLE/LARGE/HUGE |
| `RC_BIT` | flags 中的 RC 块标记；`free()` 据此分派 |

---

## 附录 C：相关文档

- `docs/gc_frontend_design.md`：旧前端模型（`parser.SimulateRC`）的设计论证；
  注意其“后端只读 parser.Object”的描述已过时。
- `docs/gc_api.md`：旧前端模型的调用流程与 API。
- `docs/backend.md`：后端总体结构、架构抽象、调用约定。
- `PROJECT.md`：当前验收基线、farm 矩阵、提交纪律。
- `docs/stdplan/GC_REMEDIATION_DESIGN.md`、`GC_REMEDIATION_PLAN.md`：
  LLR 改造的历史设计与执行记录。
