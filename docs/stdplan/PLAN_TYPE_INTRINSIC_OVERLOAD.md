# 内建类型 → std 实现映射 + 函数重载 计划

> 状态：**Go 编译器 Phase 1–4 已实施 ✅（2026-11-07）**；自举编译器后续对齐。  
> 日期：2026-11-07（计划）；2026-11-07（实施回填）  
> 范围：**Go 编译器先做**，自举编译器后续对齐。  
> 关联：`docs/stdplan/PLAN.md`（stdlib 总规划）、`docs/stdplan/TYPE_INTRINSIC.md`（用户可读映射表）、`docs/SELFHOST.md`（自举）、`test/overload/main.cute`（重载现状）。

---

## 0. TL;DR

1. 新增一张**类型内建算子表**（type intrinsic table），以 `Kind`（`string` / `map` / `list`）为键，把语言层的操作映射到 `std:strings`、`std:maps`、`std:slices` 中的真实 `FuncBlock`。
2. 映射在 **parser Check 阶段降低**为普通 `CallBlock`，复用现有调用/传参/泛型单态化/`build link` 机制；只有 `m[k]` 读写这种需要临时地址且必须拿左值的形状，在 **codegen 阶段**用同一张表做专用降低。
3. `string` / `map[K]V` / `[]T` **被使用即自动生效**：根包加载时预加载对应 std 包，并登记到 `parser.IntrinsicPkgs`；不要求用户写 `import "std:strings"`，也不占用用户的 import 别名。
4. 函数重载分两层落地：
   - 先修好现有的**按参数个数**重载（`test/overload` 当前失败）；
   - 再补**同参数个数、按参数类型**消歧，并给 mangled name 增加类型标签，避免同名同 arity 标签冲突。
5. 分阶段提交，每阶段可单独回滚；x86_64 为主验收目标，x86 不阻塞。

### 0.1 实施结果（2026-11-07 回填）

| 阶段 | 结果 | 证据 |
|---|---|---|
| Phase 1 string | ✅ | `test/intrinsic_string` ALL PASS/42；`CUTE_NO_INTRINSIC=1` 回退旧比较路径 |
| Phase 2 重载 | ✅ | `test/overload`、`test/overload_types` ALL PASS/42；`add2/add3`、`describe1_int` 等标签 |
| Phase 3 map | ✅ | `test/map_index` ALL PASS/42；nil map 读零值/写自动初始化/`len(nil)=0` |
| Phase 4 slice 自动可用 | ✅ | `test/intrinsic_auto` ALL PASS/42（无 import 的 `slices.len/cap`） |
| 附加：负数索引/步长 | ✅ | `test/neg_index_step` 25 项 ALL PASS/42；x86_64 |
| Phase 5 文档 | ✅ | 新增 `TYPE_INTRINSIC.md`；PLAN/SELFHOST/PROGRESS 回填 |

未收口项（已写入 `TYPE_INTRINSIC.md` §6）：动态负边界无 step 不归一化；
x86 负数索引/步长留 Batch 4；无 import 的 `maps.len(m)` 与 `maps.new` 返回值
直接赋给 map 变量仍受限。

---

## 1. 为什么这样做

当前语言里 `string`、`map[K]V`、`[]T` 是编译器内建类型，但它们的操作并没有统一落到 std 包：

- `string ==` / `!=` 走通用二元比较，比较的是容器三槽，不是内容；`pkg/strings` 里已经有内容比较的 `eq/ne`，但只有显式调用才用得上。
- `map[K]V` 只解析了类型，`m[k]` 读写不可用；只能显式 `import "std:maps"` 后调用 `maps.get/set`。
- `[]T` 的 `len/cap/index/append` 是编译器内建；`pkg:slices` 的 `push/get/set/...` 需要显式导入，两套设施没有统一的“类型即能力”入口。
- 用户明确要求：**类型被使用就自动应用对应 std 实现**，不要在业务代码里到处补 import。
- 用户同时要求把**函数重载**顺手做掉，因为类型分派和后续 std 映射都需要“同名不同签名”的选择能力。

目标不是把编译器内建全部删掉，而是：

> 编译器内建负责“语言语义与最底层布局”，std 包负责“可替换、可测试、可自举对齐的实现”；两者用一张显式表连接，默认自动启用。

---

## 2. 现状核查（事实）

### 2.1 类型系统

| 设施 | 位置 | 现状 |
|---|---|---|
| 内建类型入口 | `type/type.go: GetSystemType` | `string` 返回新的 `StringType`；`[]T` 走 `NewList`；`map[K]V` 由 parser 单独解析 |
| map 语法 | `parser/parser.go: parseMapTypeRef`、`parser/var.go` | `map[string]int` 可以声明，得到 `*typeSys.MapType` |
| map 表示 | `type/map.go` | `Size()` 目前返回 **24/12 字节（ptr+len+cap）**；`pkg/maps` 实际使用**单个 header 指针** |
| list 表示 | `type/list.go` | `[]T` = data/len/cap 三槽（Go 序），有 `Shape()` 视图 |
| string 表示 | `type/type.go: StringType/RType.Size` | ptr/len/cap 三槽；`IsOwning` 为真 |

### 2.2 std 实现现状

| 包 | 可用能力 | 说明 |
|---|---|---|
| `pkg/strings` | `len/cap/eq/ne/compare/index/contains/...` | `eq/ne` 已做内容比较，并挂 `build link("__string_eq"/"__string_ne")` |
| `pkg/maps` | `new[K]/set[K]/get[K]/has[K]/delete[K]/len/clear/keys/values/clone/equal` | `new` 返回 header 指针；`get` 把值 `memmove` 到 `out`，缺失时清零并返回 `false` |
| `pkg/slices` | `len/cap/make/push/pop/get/set/...` | 以 `*[]T` 为接收者；与编译器内建 `append/len/cap` 并存 |

### 2.3 自动导入/链接设施

- `package/imports.go`：文件级 `import "std:xxx"` 在解析前预扫描、解析路径、注册别名。
- `package/package.go`：
  - 只有**根包**自动导入 `pkg/builtin`（`BuiltinFuncs`，`print/println/panic` 等）。
  - 包加载完成后，登记 `build link` 符号 → `parser.LinkProviders`。
  - 合并所有包 AST 后执行最多 50 轮 `rootNode.Check()`。
- 目前**没有** `string`/`map`/`slice` 的隐式 std 导入。

### 2.4 现有运算符与内建

- `parser/exp.go: opMethodMap`：运算符 → 方法名的映射，仅用于**自定义类型**的 `checkOverload`。
- `parser/exp_check.go: checkOverload`：只查 `TypeName.method` 并把返回类型写回；**没有代码生成**，所以自定义类型运算符重载目前只是 parser 钩子。
- `compile/exp/exp.go`：
  - `+` 且类型为 `string` → `stringConcatExp` 原生拼接。
  - `len/cap` → `builtinCall`；string 变量且 `StringSyms` 有提供者时走 `__string_len/__string_cap`。
  - `==/!=` 没有 string 特判，走通用比较。
- `parser/exp_check.go: checkIndex`：只处理 `list`/`string`/`array`；`map` 会落入 `checkOverload` 并报“operator [] not defined”。
- `parser/exp_check.go: checkIndexAssign`：只处理 `list`，map 同样不可用。

### 2.5 函数重载现状

- `parser/func.go`：
  - `MangledName()` 只在同名函数存在**不同参数个数**时追加 `len(Args)`。
  - `overloadNames` 是全局 `map[name]map[arity]bool`，`registerOverload` 在解析每个函数后登记。
  - `isOverloadedName` 只看 arity 集合大小。
- `parser/call.go: CallBlock.Check`：
  - `p.Find(c.Name, FindTypeFunc)` 返回**所有**同名结果，但循环里直接取第一个可用的 `FuncBlock`；
  - 随后按第一个函数检查参数个数，所以 `test/overload/main.cute` 报 `too many arguments in call to add`。
  - 同 arity、不同类型时，第一个函数被选中，类型检查失败或错误选择。
- 没有“按参数类型打分/歧义诊断/候选列表”的逻辑；也没有重载注册表在包合并后的重建。

### 2.6 自举约束

S3 的 canonical AST 对拍只观察 **parse 后的语法形状**。本计划的 lowering 发生在 `Check`/`codegen`，不应改变 `parsedump` 的输出；因此自举 parser 侧**不需要**跟随这次类型映射改动。自举编译器未来要对齐时，再复用同一张表和同一套重载规则。

---

## 3. 设计

### 3.1 总原则

1. **一张表是唯一事实源**：`Kind + 操作` → `std` 函数/内建实现。parser、codegen、文档都查这张表，禁止散落 `if kind == "string"`。
2. **能降成普通调用就降成普通调用**：复用 `CallBlock`、`arch.Call`、泛型单态化、`Useful` 死代码消除和 `build link`。
3. **只对必须拿地址/左值的形状开 codegen 特例**：目前只有 `m[k]` 读和 `m[k] = v` 写。
4. **自动生效，但不污染用户命名空间**：用完整 package path 构造 `Name`（`IsPkgPath=true`），不注册 `strings`/`maps`/`slices` 这些可能冲突的别名。
5. **失败要显式**：重载歧义、无候选、类型不兼容都报错并列出候选；禁止“取第一个”这种静默行为。
6. **不改变 parse 形状**：所有 lowering 在 `Check` 之后发生，S3 AST 对拍不受影响。

### 3.2 类型内建算子表

新增文件：`parser/intrinsic.go`（parser 需要同时访问 `typeSys` 和 `FuncBlock`，放 parser 最合适）。

```go
// 仅示意，最终以代码为准
type IntrinsicForm uint8

const (
    IntrinsicCall     IntrinsicForm = iota // 降成普通函数调用
    IntrinsicNative                        // 保留编译器现有内建/代码生成
    IntrinsicIndexGet                      // 需要地址临时量的索引读
    IntrinsicIndexSet                      // 需要地址临时量的索引写
)

type IntrinsicEntry struct {
    Kind string // "string" | "map" | "list"
    Op   string // "==", "!=", "+", "[]", "[]=", "len", "cap", ...
    Pkg  string // "std:strings" / "std:maps" / "std:slices"；Native 时为空
    Fn   string // 包内函数名；Native 时为空
    Form IntrinsicForm
    Phase int // 1=string, 2=map, 3=list；便于分阶段开关
}
```

第一阶段表内容（**Go 编译器**）：

| Kind | 操作 | 目标 | Form | 阶段 |
|---|---|---|---|---|
| string | `==` | `std:strings.eq(a,b)` | Call | 1 |
| string | `!=` | `std:strings.ne(a,b)` | Call | 1 |
| string | `+` | `compile/exp.stringConcatExp` | Native | 1（保持现状） |
| string | `len` / `cap` | `std:strings.len/cap`（现有 link 路径） | Native/Call | 1（保持现状） |
| string | `[]` / `[]=` | 现有 string 索引/切片 | Native | 1 |
| map | `len` | `std:maps.len(m)` | Call | 2 |
| map | `[]` 读 | `std:maps.get[K](m,k,&tmp)` + 零值 | IndexGet | 2 |
| map | `[]=` 写 | `std:maps.set[K](m,k,&v)` | IndexSet | 2 |
| map | 零值初始化 | `std:maps.new[K](zeroK, sizeof[V]())` | Call | 2 |
| list | `len` / `cap` / `[]` / `[]=` / `append` / `copy` / `make` | 现有编译器内建 | Native | 3（保持现状） |
| list | 命名 API | `std:slices.*` 自动可用 | AutoImport | 3 |

说明：

- `string +` **第一阶段不强行改成 `strings.concat`**：现有 `stringConcatExp` 是完整可用的代码生成路径，`pkg/strings` 没有等价的 `concat` 公开函数。表里明确登记为 `Native`，避免“为了映射而映射”引入回归。后续若要统一，可在 `pkg/strings` 增加 `concat`（内部仍走同一实现）再切换。
- `len/cap` 已有 link 提供者机制，保留现状；表的职责是声明“这是 string 的官方实现”，而不是重复实现。
- `map` / `list` 的 `len` 优先查表；用户显式调用的 `maps.len(m)` 仍然正常工作。

### 3.3 自动生效机制

#### 3.3.1 预加载

在 `package/package.go` 的根包加载分支（当前 `builtin` 自动导入处）增加：

1. 解析 `std:strings`、`std:maps`、`std:slices` 的目录（`stdPackageDir`）。
2. 若尚未加载，`GetPackage(path, false)` 加载并放入 `packages`。
3. 把路径登记到新表：
   ```go
   parser.IntrinsicPkgs["strings"] = stringsPath
   parser.IntrinsicPkgs["maps"]    = mapsPath
   parser.IntrinsicPkgs["slices"]  = slicesPath
   ```
4. **不**写入根包 `Imports` 的 `strings/maps/slices` 别名，避免和用户同名别名/变量冲突。lowering 时直接用：
   ```go
   Name{{Name: path, IsPkgPath: true}, {Name: fn}}
   ```

`pkg/strings` 已经由 `pkg/builtin` 间接加载；`maps`/`slices` 是新增加载。第一版可以无条件加载（实现简单、结果确定），后续再按源码预扫描优化：

- 预扫描 `\bmap\s*\[` 决定是否加载 maps；
- 预扫描 `\[\]` 或 `list` 决定是否加载 slices；
- 预扫描 `\bstring\b`（strings 已加载，无需额外动作）。

#### 3.3.2 依赖方向

`pkg/maps` / `pkg/slices` 只依赖 `memory`（现有约束）。自动加载只是在编译期把它们加入包集合，不改变源码 import 关系，不破坏 P7。若某个包自身使用了内建类型操作，lowering 仍只调用已加载的 std 路径。

#### 3.3.3 死代码消除

- lowering 解析到具体 `FuncBlock` 后必须设置 `Useful = true`。
- 如果目标函数有 `build link` 符号，同时把 `LinkProviders[symbol]` 标记 `Useful`（现有 `len/cap` 已这么做）。
- 未被任何代码使用的自动加载包函数仍会被 DCE 清掉，不增加最终二进制体积。

#### 3.3.4 失败策略

- 若某个 std 包加载失败：编译期只在**真正使用对应类型操作**时报错，错误信息包含包路径与原因；纯声明 `var m: map[string]int` 不因 maps 缺失而失败（第一阶段可先简化为加载失败即报错，但需要在测试中固定）。
- 提供环境变量 `CUTE_NO_INTRINSIC=1` 关闭隐式映射，回退到当前行为，便于回归定位与逐阶段回滚。

### 3.4 Lowering 位置与形状

#### 3.4.1 string `==` / `!=`

入口：`parser/exp_check.go: checkOp` → `checkEq` 之前。

```go
// 伪代码
func (exp *Expression) tryIntrinsicBinary(p *Parser) bool {
    if exp.Left == nil || exp.Right == nil { return false }
    if exp.Left.Type == nil || exp.Right.Type == nil { return false }
    if exp.Left.Type.Kind() != "string" || exp.Right.Type.Kind() != "string" { return false }
    entry := lookupIntrinsic("string", exp.Separator)
    if entry == nil || entry.Form != IntrinsicCall { return false }
    fb, err := resolveIntrinsicFunc(p, entry)
    if err != nil { p.Error...; return false }
    fb.Useful = true
    // 原地改写成调用表达式；parse 形状已被 Check 消费，不影响 parsedump
    exp.Call = &CallBlock{
        Name: fb.Name,
        Func: fb,
        Args: []*ArgBlock{{Value: exp.Left}, {Value: exp.Right}},
    }
    exp.Separator = ""
    exp.Left, exp.Right = nil, nil
    exp.Type = typeSys.GetSystemType("bool")
    return true
}
```

要点：

- 只在**两侧都是 string** 时触发；`string` 与自定义类型混用不触发。
- 改写后 `exp.Separator == ""`，codegen 走 `leaf → arch.Call`，参数由 `arch.Call` 自身编译，返回 `bool`。
- 改写是幂等的：`Expression.Check` 的 `checked` 标记会阻止二次进入。
- 不能影响常量折叠/类型检查的其他分支；如果 `checkEq` 已做常量折叠（字面量比较），保留原有折叠逻辑，只在运行期路径上替换。

#### 3.4.2 map `len`

入口：`parser/call.go: checkBuiltin` 的 `case "len"`：

- 参数类型 `Kind() == "map"` 时，查表得到 `std:maps.len`，设置 `c.Func`，返回 `true`。
- 参数个数/类型诊断复用现有 `CallBlock.Check`。
- 返回类型 `uint`（与 `pkg/maps.len` 一致；如需 `int`，在表里加转换或让 maps 提供 `len` 的 `int` 版本，第一阶段按现有 API 返回 `uint`）。

#### 3.4.3 map `m[k]` 读 / `m[k] = v` 写

这是唯一需要 codegen 特例的部分，原因是：

- `maps.get[K]` 需要 `out` 指针，表达式层没有临时变量；
- `maps.set[K]` 需要 `valAddr`，右值可能是任意表达式，不能总是取地址。

方案：在 `compile/exp/exp.go` 的 `indexAccess` / `indexSet` 增加 map 分支，并且**从 parser 表读取目标**：

- 读：
  1. 计算值类型 `V` 的 `Size()`，按栈对齐向上取整到 8/16 字节。
  2. `sub rsp, size` 预留临时槽，先清零（`maps.get` 在未命中时也会 memset，但清零更稳）。
  3. 构造 `CallBlock{Name: std_maps.get, Func: 具体 FuncBlock, Args: [m, key, &tmp]}`。
  4. 用 `arch.Call` 发调用（泛型需先走 `MonomorphizeCall` / 显式 `[K]` 标签）。
  5. 从 `[rsp]` 把值装载到 `result`（支持 1/3 槽/结构体多槽）。
  6. `add rsp, size`。
- 写：
  1. 同样预留 `size` 临时槽。
  2. 把右值编译到 `[rsp]`（复用 `Compile(exp, mem)` 的多槽写入能力；字符串/列表值走三槽拷贝）。
  3. 构造 `CallBlock{Name: std_maps.set, Func, Args: [m, key, &tmp]}`。
  4. `add rsp, size`。
- `m` 的求值必须只发生一次（先算到寄存器/临时槽），避免 `m` 本身是函数调用时重复副作用。
- 如果 `m` 是 nil（零值 map）：
  - 读：直接返回 `V` 的零值，不调用 `maps.get`；
  - 写：先调用 `maps.new[K]` 初始化，再 `set`。这一条是 Cute 的便利语义，明确写入文档；若用户希望严格 Go 的 nil panic，可在后续用 `CUTE_STRICT_MAP=1` 切换。
- 键/值类型必须具体化：`K` 来自 `MapType.Key()`，`V` 来自 `MapType.Elem()`；泛型 `K` 在单态化后必须有具体类型，否则报错。
- `sizeof[V]()` 走现有编译期求值；`struct` 值按 `Size()` 传，`maps` 全运行期按字节拷贝。

**代码生成与 parser 的边界**：parser 只负责把 `[]` 节点的类型标成 map 的 `V`、并校验键类型；codegen 负责真正的调用形状。表的 `Form=IndexGet/IndexSet` 是两边的契约。

#### 3.4.4 list / slice

第一阶段到第三阶段都**不改变**现有 `[]T` 语义：

- `len/cap/index/slice/append/copy/make` 继续走编译器内建；
- `std:slices` 作为自动可用的包加载，用户可以写 `slices.push[T](&s, v)`，但不会强制把 `append` 改成 `slices.push`；
- 表的 list 行登记为 `Native`，并在文档中说明“内建实现优先，std:slices 是命名 API”。

后续若要做 `s.push(v)` 方法糖，单独立项；不在本计划内。

### 3.5 map 类型表示（关键决策）

当前 `type/map.go` 把 map 当三槽容器（24/12 字节），但 `pkg/maps` 的 API 是**单 header 指针**（`new` 返回 `ptr`，`get/set/len` 都接收 `ptr`）。两者必须统一，否则 `m[k]` 无法可靠工作。

推荐：**把内建 `map[K]V` 改成单指针表示**，与 Go 的 map 值语义和 `pkg/maps` 对齐：

- `type/map.go`：`MapType.Size()` 返回 `TargetPointerSize`，`Alignment()` 返回 `TargetPointerSize`；
- 零值 = 空指针（nil map）；
- `maps.new` 返回的 header 指针直接赋给 map 变量；
- 现有代码里 `var m: map[string]int` 只声明、不解引用，改动影响面小（全仓 grep 仅 `test/map_test` 使用 map 类型）；
- GC：map header 目前没有 `maps.free`，先明确为“进程生命周期/手动管理”；如后续需要，补 `maps.free` 并纳入 owning 类型。

备选（不推荐）：保留 24B 内联 header，把 `maps.new` 返回的 24B 拷进变量。这样会多一次 header 分配/拷贝，且 `maps` 内部把 header 当独立块管理，容易产生悬挂副本。

### 3.6 函数重载

#### 3.6.1 目标语义

- 同名函数按**参数个数 + 参数类型**选择；
- 返回类型不参与重载；
- 方法重载暂不纳入（Phase 2 只做顶层函数；方法仍保留现有行为）；
- 泛型函数参与候选，但优先具体类型；只有泛型候选时才走单态化；
- 默认参数参与候选：`len(args) <= len(params)` 且所有缺失参数都有默认值；
- 变参后续支持，第一阶段先保证非变参。

#### 3.6.2 数据结构

把 `overloadNames` 替换为：

```go
type OverloadSet struct {
    Defs []*FuncBlock // 同名函数的全部定义（已去重、已过滤 ignored build）
}

var overloadRegistry = map[string]*OverloadSet{} // key = Name.String()（包路径已固定）
```

- 在包合并完成后、`rootNode.Check()` 之前调用 `parser.RebuildOverloadRegistry(root)`，遍历合并树收集所有顶层 `FuncBlock`；
- 保留 parse 期的 `registerOverload` 作为单文件/工具路径的临时数据，但最终以合并后重建为准；
- 重新加载根包前 `ResetOverloadRegistry()`，避免测试/多项目进程串味；
- 同签名重复定义 → 明确报 `redeclared function`，不进入候选。

#### 3.6.3 选择算法

`CallBlock.Check` 不再“取第一个”，而是：

1. 收集所有 `Name` 完全匹配、未被 `build os/arch` 忽略的 `FuncBlock`。
2. 按参数个数过滤：
   - 固定参数：`len(args) == len(params)`；
   - 带默认参数：`required <= len(args) <= len(params)`，`required` 为第一个有默认值之前的位置数；
   - 变参（后续）：`len(args) >= len(params)-1`。
3. 对每个候选按位置打分（分数越小越匹配）：
   - `0`：类型完全相等（`Type()` 相同且指针标记相同）；
   - `1`：`AutoType(arg, param, isConst)` 成立且为同 Kind 数值放宽/常量 0 → 指针；
   - `2`：`ptr` ↔ `*T` 等现有地址语义放宽；
   - `3`：`TypeParam` 占位（泛型候选）；
   - 其他：候选淘汰。
4. 取总分最低的候选：
   - 唯一 → 选中；
   - 多个并列最低 → `ambiguous call to X: candidate ...`，列出每个候选的签名；
   - 无候选 → `no matching overload for X(...)`，列出所有同名候选的签名。
5. 选中后：
   - 只把选中的 `FuncBlock.Useful = true`（不要像现在那样把所有同名函数都标 Useful）；
   - 追加默认参数（复用现有逻辑）；
   - 逐参数 `AutoType` 检查与 `arg.Type/Name/Offset` 回填（复用现有逻辑）。

#### 3.6.4 跨文件/跨包/前向引用

- `Find` 在合并后的树上能拿到所有同名定义；`RebuildOverloadRegistry` 让调用解析不依赖“定义先于调用”。
- 跨包调用名已由 `fixPkgNamePaths`/`FixPath` 固定为完整路径，registry key 使用 `Name.String()`，不会和根包同名函数混淆。
- 首轮 `Check` 时若目标函数尚未解析（跨包 AST 未合并），保持现有“路径调用静默返回，合并后重试”的策略；不要因为重载候选暂时为空就提前报错。
- 50 轮重试仍无候选 → 最终报错。

#### 3.6.5 Mangling

现有规则：同名且 arity 不同 → `name + arity`。需要扩展：

- registry 中同名函数只有一个定义：保持 `name`（不追加），完全向后兼容。
- 同名多定义但 arity 都不同：保持 `name + arity`。
- 同名多定义且存在**同 arity 冲突**：
  - 该 arity 的每个定义追加类型标签：`name + arity + "_" + typeCode`；
  - 其他 arity 仍用 `name + arity`，减少标签变化面。
- `typeCode` 生成规则（稳定性优先）：
  - 逐参数取 `Type()`，指针加 `p` 前缀；
  - 只保留 `[A-Za-z0-9_]`，其余替换为 `_`；
  - 例如 `int,int` → `int_int`；`string,string` → `string_string`；`[]int,string` → `list_int_string`；
  - 过长时用 `FNV-1a` 8 位十六进制截断（需要在文档中固定规则）。
- `MangledName()` 查 registry 决定是否加标签；`MangledOverride`（单态化）优先级最高，保持不变。
- `formatFuncNameRaw` 只用于没有 `FuncBlock` 的旧路径；有 `FuncBlock` 的调用一律走 `MangledName()`。Phase 2 需要补一个“函数指针指向重载函数”的测试，确保 `lea` 标签与定义一致。

#### 3.6.6 与内建映射的关系

- 内建映射表解析目标函数时，**复用同一个重载选择器**：如果 `std:strings` 里存在同名重载，按参数类型选；没有重载就直接取唯一 `FuncBlock`。
- 这样“类型映射”和“函数重载”不是两套逻辑，避免以后 std 包增加重载时再次改 parser。

---

## 4. 分阶段实施

### Phase 0：基线（0.5 天）

- 记录当前基线：
  - `go build -o /tmp/opencode/bin/cuteify2 .`
  - `scripts/selfhost_parse.sh` 结果；
  - `test/overload` 当前失败输出；
  - `test/map_test` 当前可编译；
  - x86_64 stdlib matrix 结果。
- 新增测试目录（先红后绿）：
  - `test/intrinsic_string/main.cute`
  - `test/overload_arity/main.cute`（可直接复用 `test/overload`）
  - `test/overload_types/main.cute`
  - `test/map_index/main.cute`
- 每个测试提供纯 Cute 的 PASS/FAIL 计数与退出码，沿用现有 `println(...)/ret 42` 风格。

### Phase 1：类型表 + string 内容比较（1–2 天）

**改动**

- 新增 `parser/intrinsic.go`：表结构、`lookupIntrinsic`、`resolveIntrinsicFunc`。
- `package/package.go`：根包预加载 `strings/maps/slices`，登记 `parser.IntrinsicPkgs`；新增 `CUTE_NO_INTRINSIC` 开关。
- `parser/exp_check.go`：`checkOp` 在 `checkEq` 前调用 `tryIntrinsicBinary`；只启用 string `==/!=`。
- `parser/exp_check.go`：`checkEq` 保留原有常量折叠；确保不会对 string 再做三槽比较。
- 文档：在 `docs/stdplan/PLAN.md` 的边界表里标注 string `==/!=` 已由内建映射接管（实施后更新）。

**验收**

- `test/intrinsic_string`：
  - 字面量与字面量；
  - 字面量与 `+` 拼接结果；
  - 不同地址、同内容的构造字符串；
  - `!=` 反向用例；
  - 与显式 `strings.eq` 结果逐项一致。
- `go test ./parser ./type ./...`。
- S3 `scripts/selfhost_parse.sh` 的 parsedump 输出不变（lowering 不发生在 parse 期）。

**回滚**：单独 commit；`CUTE_NO_INTRINSIC=1` 可立即回退到旧比较路径。

### Phase 2：函数重载（2–3 天）

**2a：按 arity 选择（先让现有测试过）**

- `parser/func.go`：`overloadNames` → `overloadRegistry` 雏形；`MangledName` 保持现有 arity 后缀。
- `parser/call.go: CallBlock.Check`：收集所有候选，按 arity/默认参数过滤，选中唯一候选。
- `package/package.go`：合并后 `RebuildOverloadRegistry(root)`。
- 验收：`test/overload/main.cute` 输出 `overload: ALL PASS`、退出 42。

**2b：同 arity 按类型选择 + 类型 mangling**

- 完整打分/歧义诊断。
- `MangledName` 对同 arity 冲突追加 `typeCode`。
- 测试：
  - `add(int,int)` vs `add(string,string)`；
  - `pick(ptr)` vs `pick(*int)`（现有地址语义）；
  - 常量 `0` 匹配指针的重载；
  - 三候选歧义必须报错；
  - 无候选必须报错并列出签名；
  - 跨文件定义（一个文件声明/另一个调用）；
  - 函数指针赋给 `fn(int,int) int` 后调用；
  - 重载函数作为参数传递。
- 回归：`scripts/gc_asm_diff.sh` 或等价汇编对拍，确认非重载函数的 mangle 名不变。

**回滚**：Phase 2a/2b 分开 commit；若 2b 的 mangling 引起大范围 asm 差异，可只保留 2a。

### Phase 3：map 类型映射（3–4 天）

**3a：表示与只读**

- `type/map.go`：单指针表示（见 §3.5）。
- `test/map_index` 增加 `var m: map[string]int` + `maps.new` 显式初始化 + `m[k]` 读 + `len(m)`。
- `parser/call.go: checkBuiltin`：`len(map)`。
- `parser/exp_check.go: checkIndex`：`Kind()=="map"` 时设置 `exp.Type = MapType.Elem()`，键类型检查；不再落入 `checkOverload`。
- `compile/exp/exp.go: indexAccess`：map 读降低（§3.4.3）。

**3b：写入与零值**

- `parser/exp_check.go: checkIndexAssign`：map 写入类型检查（`exp.Left` 值类型 vs `V`）。
- `compile/exp/exp.go: indexSet`：map 写降低。
- nil map 自动初始化策略（`maps.new`）。
- 测试键类型：`int`、`string`；值类型：`int`、`string`、`ptr`、`*T`、`[]int`、struct（至少各一个）。
- 缺失键读返回零值、`get` 的 `ok` 语义不在语法层暴露（后续可加 `v, ok := m[k]`）。
- 回归：`test/map_test`、`pkg/maps` 现有测试、全仓 stdlib matrix。

**风险控制**：map 表示改动单独 commit；若发现现有代码有隐含 24B 假设，先修假设或回退到备选方案（内联 header）。

### Phase 4：slice 对齐（1 天，低风险）

- 表里登记 `list` 的 Native 行，不改现有代码生成。
- 自动加载 `std:slices`，`slices.push/get/set/...` 在根包可直接调用。
- 若用户代码里 `append` 与 `slices.push` 行为不一致，补文档和测试，不强行替换 `append`。
- 验收：`test/sliceTest` 现有断言 + 新增“无显式 import 使用 `slices.len/cap`”的测试。

### Phase 5：文档、开关与自举对齐（1 天）

- 更新 `docs/stdplan/PLAN.md` 的边界表：`m[k]` 从不做改为“由内建映射提供”；运算符重载说明更新。
- 新增 `docs/stdplan/TYPE_INTRINSIC.md`（用户可读的映射表与自动生效规则）。
- `docs/SELFHOST.md` 增加一节：自举 parser 不受 lowering 影响；自举编译器后续按同一张表实现。
- 所有新行为提供 `CUTE_NO_INTRINSIC=1` 回退说明。
- 不实施自举侧；只记录待办。

---

## 5. 测试与验收清单

### 5.1 单元/集成

```bash
# 编译器构建
go build -o /tmp/opencode/bin/cuteify2 .

# Go 单测
go test ./...

# 新增语义测试（按仓库现有测试脚本风格）
CUTE_ROOT="$PWD" CUTE_ARCH=x86_64 /tmp/opencode/bin/cuteify2 test/intrinsic_string
CUTE_ROOT="$PWD" CUTE_ARCH=x86_64 /tmp/opencode/bin/cuteify2 test/overload
CUTE_ROOT="$PWD" CUTE_ARCH=x86_64 /tmp/opencode/bin/cuteify2 test/overload_types
CUTE_ROOT="$PWD" CUTE_ARCH=x86_64 /tmp/opencode/bin/cuteify2 test/map_index
```

> 具体编译/运行命令按 `scripts/stdlib_matrix.sh` 与测试目录现有约定执行；上述命令只表示入口。

### 5.2 回归

- `scripts/stdlib_matrix.sh x86_64 1` 全绿（至少不新增红项）。
- `scripts/selfhost_parse.sh` 的 S3 parsedump 对拍 `diff=0`；若 Phase 1 只改 Check，应完全无变化。
- `scripts/gc_asm_diff.sh`：非重载函数的汇编标签/输出不变；重载测试的汇编允许新增标签。
- x86：不阻塞；Phase 4 后再看 `scripts/stdlib_matrix.sh x86` 是否新增红项。

### 5.3 负向测试

- `add(1)` 无候选：错误包含 `no matching overload` 和候选签名；
- `pick(0)` 同时匹配 `int` 与 `ptr`：按规则应选 `int`（常量 0 到指针是低优先级），若无法区分则报歧义；
- 同签名重复定义：`redeclared function`；
- `m[k] = v` 值类型不兼容：明确报 map 值类型；
- `m[k]` 的 key 类型不兼容：明确报 map 键类型；
- `CUTE_NO_INTRINSIC=1` 时 string `==` 回到旧行为（用于回归确认，不要求旧行为正确）。

---

## 6. 风险与回滚

| 风险 | 影响 | 缓解 |
|---|---|---|
| 根包自动加载 maps/slices 改变包集合 | 编译时间/合并树变化 | 先无条件加载并跑全矩阵；后续按源码预扫描优化 |
| map 表示从 24B 改为指针 | 潜在布局假设破坏 | 全仓 grep + `test/map_test` + 单独 commit；保留内联 header 备选 |
| 重载 mangling 改变标签 | 汇编对拍差异、函数指针错位 | 只在同 arity 冲突时加类型标签；补函数指针测试；asm diff |
| 重载歧义/静默选择 | 行为不可预测 | 禁止 first-match；打分 + 歧义报错 |
| lower 改写 AST 影响 GC/escape | 误释放/漏释放 | lowering 在 `gc.Analyze` 之前完成；synthetic call 参数按值传递；新增 GC 回归 |
| map 栈临时量未纳入 GC | 值类型含 owning 容器时误解 | 临时量只做浅拷贝/视图，不转移所有权；文档明确；后续如需深拷贝再设计 |
| `m[k]` 的 `m` 有副作用被求值两次 | 语义错误 | 先求 `m` 到临时寄存器/槽，再传参 |
| 自举 AST 对拍被误伤 | S3 回退 | lowering 不发生在 parse；`parsedump` 测试必须 diff=0 |

回滚策略：

- Phase 1/2/3/4 各自独立 commit，按阶段 revert；
- `CUTE_NO_INTRINSIC=1` 关闭隐式映射；
- map 表示改动若失败，回退到 24B 内联 header 备选，不影响 Phase 1/2；
- 不 push，遵守仓库提交纪律（中文单行前缀、显式路径、禁止 `git add -A`）。

---

## 7. 明确不做（本计划边界）

- 不做完整 Go stdlib API 对齐；只做 `string` / `map` / `slice` 的核心操作映射。
- 不做 `for k, v in map`、map 字面量、`delete(m,k)` 语法糖；继续用 `maps.keys/values/delete`。
- 不做自定义类型运算符重载的代码生成；本次只做**内建类型**的映射和**顶层函数**重载。
- 不做 x86 优先验收；x86_64 先行。
- 不在本次改自举 parser/compiler；只保证 parse 形状不变，并记录后续对齐项。
- 不做 map header 的 GC 释放（`maps.free`）；先文档化为手动/进程生命周期。

---

## 8. 变更文件清单（预估）

**新增**

- `parser/intrinsic.go`
- `test/intrinsic_string/main.cute`
- `test/overload_types/main.cute`
- `test/map_index/main.cute`
- `docs/stdplan/TYPE_INTRINSIC.md`

**修改**

- `package/package.go`：预加载 std 包、登记 `IntrinsicPkgs`、重建重载注册表、开关。
- `parser/func.go`：`overloadRegistry`、`MangledName` 类型标签、重建/重置。
- `parser/call.go`：`CallBlock.Check` 候选收集与选择；`checkBuiltin` 的 map `len`。
- `parser/exp_check.go`：string `==/!=` 降低；map 索引类型检查；map 索引赋值检查。
- `parser/builtin.go`：如需新增 `IntrinsicPkgs` 注册表（或放 `intrinsic.go`）。
- `type/map.go`：单指针表示（Phase 3）。
- `compile/exp/exp.go`：map `indexAccess` / `indexSet` 降低；`builtinCall` 的 map `len`。
- `docs/stdplan/PLAN.md`：边界表更新（Phase 5）。
- `docs/SELFHOST.md`：说明 lowering 不影响 parsedump，自举后续对齐（Phase 5）。

---

## 9. 待确认（实施前请拍板）

1. **map 零值语义**：推荐“读 nil map 返回零值、写 nil map 自动 `maps.new` 初始化”（Cute 便利语义）；是否改为严格 Go 的 nil panic？
2. **map 表示**：推荐单指针（与 `pkg/maps` 一致）；是否接受 `MapType.Size()` 从 24 改 8/4？
3. **`string +`**：第一阶段保持原生 `stringConcatExp`，不映射到 `strings.concat`；是否同意？
4. **重载范围**：第一阶段只做顶层函数，不做方法重载；是否同意？
5. **自动加载策略**：第一版无条件加载 `strings/maps/slices`，后续再按源码预扫描优化；是否接受编译期成本？

> 以上默认值已按“最小风险、可回滚、Go 编译器先行”选取；确认后按 Phase 0 → 5 实施。

---

## 10. 完成后交接：继续 `docs/SELFHOST.md`

**本计划（Phase 0–5）先做，做完再回到自举，不要在这里无限扩散。**

本计划收口后，下一个接手者/下一个会话请继续 `docs/SELFHOST.md` 的 S3 自举收口，当前待办至少包括：

1. 修 `selfhost/parse/parse.cute` 的 `prec()`：当前仍是 C 风格优先级，需对齐 Go parser 的
   `||1 / &&2 / ==!=3 / 关系4 / |5 / ^6 / &7 / 移位9 / +-10 / * / %11`。
2. 修 `dropOldConstAssign`：字段路径赋值（如 `b.val = 7`）不应被当成“旧常量清理”，
   当前导致 `test/gcOverwrite` 少 `VAR name=b.val LIT 7`。
3. 建持久对拍语料与脚本：`selfhost/parse/test/ast/` + `scripts/selfhost_ast_parity.sh`，
   重扫全仓非 runtime `.cute` 文件，目标保持 `diff=0` 或把剩余差异全部登记为已知项。
4. 补文档：`docs/SELFHOST.md`、`selfhost/README.md`、`selfhost/parse/README.md`，
   写明 S3 canonical AST 规则、已知差异边界和验收命令。
5. 清理运行产物（`_main.asm`、`ast.html`、`gc_*`、`tools/astprobe/` 等），
   按模块拆分提交；禁止 `git add -A`，不 push。

> 交接口令：**“本 PLAN 已完成，继续 `docs/SELFHOST.md` 的 S3 收口。”**
