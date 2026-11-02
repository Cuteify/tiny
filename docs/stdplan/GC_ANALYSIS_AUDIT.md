# GC 分析产物最优性审计（2026-11-03）

> 范围：只读审计。检查 `gc_summary.json` / `gc_llr.txt` 的覆盖率、逃逸/释放计划与当前
> 语料的一致性；**不修改** `parser/*`、`compile/gc/*`、`type/struct.go` 或 `package/*.go`。
> 审计对象是当前 `HEAD=91841e0` 下由 `/tmp/opencode/bin/w13` 生成/复核的产物。

## 0. 结论先行

1. **esccheck 红项 0 不是 GC 分析最优的证明。** esccheck 只统计根 `new` 对象；
   `test/gcfree2`、`test/sortTest`、`test/sortStrOnly` 等字符串/库调用测试均报告
   `对象=0 泄漏=0 提前释放=0`，无法验证 LLR 的字符串分配与释放计划。
2. **当前 22 个 11-03 产物不是“全库最优”样本。** 全库 109 个目录中只有 22 个是当前
   产物；80 个仍是 10-18 旧产物，另有 10-31、11-01、11-02 的少量旧产物。旧产物与新
   产物不可混用计数。
3. **当前语料存在真实漏释放/漏分析。** 最明确的是 `ret len(t)` 路径：
   `test/gcfree.useTemp` 与 `test/gcfree2.useTemp` 的 `t` 标记为
   `site=call:makeGreeting ESCAPED`，没有 `FREE`。两个测试仍然通过，因为它们只校验值，
   不校验泄漏计数。
4. **当前语料存在潜在 use-after-free / double-free 形态。** 参数经 `VarBlock` 右值调用
   写入全局时逃逸没有传播到调用方；返回参数别名的函数被当作“新分配”返回，调用方可能
   同时释放原对象和返回值。
5. **`bumpParams` 有明显过度逃逸。** `pkg/strings` 中 12 个拥有参数被标为
   `mode=4 escape=1`；其中 7 个在当前实现下可以确定为不必要，5 个属于“空串/无匹配时
   返回原参数”的保守分支。
6. **旧产物的 `callsAny ["len"]` / `["new"]` 与 cast-as-new 不是当前行为。** 当前 22 个
   产物只有 `callsAny [""]`，`new` 实际分配仅 1 个；旧计数只能用于历史对照。
7. 当前 `retOwned && retEscape==0` 与 `!retOwned && retEscape!=0` 均为 0，但这是
   **同源初始化造成的恒真检查**，不能据此认为 RetOwned 语义正确。

## 1. 审计方法

### 1.1 产物解析

- `gc_summary.json` 不是单个 JSON 文档，而是 `== <fn>` 分节，每节后跟一个 JSON 对象；
  按 `^== ` 分节并逐节解析 JSON。
- `gc_llr.txt` 同样按 `^== <fn>` 分节，节内包含：
  - `obj[i] <name> site=<site> [ESCAPED] [FRAME_OWN]`
  - `FREE <var> [<type>] [scope=n]`
  - `FIELD_FREE <var>.<field> [<type>]`
- 覆盖率按函数全路径名中 `/tiny/` 后的首段归类：`pkg/<name>` 或测试根目录。
- 产物日期按 `gc_summary.json` 的 mtime 归类；同一目录的 `gc_llr.txt` 作为配对产物。
- 统计口径：
  - **实际分配**：`site=new`、`site=call:<fn>`、`site=string-concat`。
  - **借用对象**：`site=param:*`、`site=null_init`。它们也会显示 `ESCAPED`，但不是
    堆分配，不能与分配计数混用。
  - `ESCAPED` 表示“分析认为对象逃逸”，不是“泄漏”本身；泄漏要看是否有对应的
    `FREE`/`FIELD_FREE` 或真实运行期分配扩张。

### 1.2 覆盖率与复核

- 用当前 22 个 11-03 产物统计当前语料。
- 对旧产物在 `/tmp/opencode` 的副本上用 w13 重新生成，比较 `funcs`、LLR 对象、`FREE`、
  `FIELD_FREE`、`site=new`、`callsAny`、`retOwned`。
- 用最小探针验证逃逸/释放规则：
  - `/tmp/opencode/gcprobe_lenret`
  - `/tmp/opencode/gcprobe_paramesc`
  - `/tmp/opencode/gcprobe_retparam`
  - `/tmp/opencode/gcprobe_overesc`
  - `/tmp/opencode/gcprobe_overesc2`
- 用 `esccheck` 检查当前测试的前端泄漏/提前释放基线，但不把其红项 0 当作 LLR 正确性
  证明。

## 2. 产物版本与总量

### 2.1 版本分布

| 日期 | 目录数 | 说明 |
|---|---:|---|
| 2026-10-18 | 80 | 旧产物，`callsAny` 仍含 `len`/`new`，cast 可能被当作 `new` |
| 2026-10-31 | 1 | `pkg/slices`，cast-as-new 假阳性样本 |
| 2026-11-01 | 1 | `test/_mp_probe`，探针产物，不是正式语料 |
| 2026-11-02 | 5 | `pkg/sort/test`、`test/builtinTest`、`test/fortest`、`test/helloWorld`、`test/import` |
| 2026-11-03 | 22 | 当前审计样本 |

当前 22 个目录：

`test/complexTest`、`test/derefTest`、`test/gcfree`、`test/gcfree2`、`test/m5`、
`test/map_test`、`test/mp_map`、`test/mp_min`、`test/negIdx`、`test/rcSimple`、
`test/rctest`、`test/slice_minimal`、`test/slice_test`、`test/sliceTest`、
`test/sortIntOnly`、`test/sortMinimal`、`test/sortMinimal2`、`test/sortQuick`、
`test/sortStrOnly`、`test/sortTest`、`pkg/slices/test`、`pkg/strings/test`。

### 2.2 全量 vs 当前

| 范围 | 目录 | LLR 对象 | 实际分配 | `new` | `call` | `string-concat` | `FREE` | `FIELD_FREE` |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 全量（109 目录） | 109 | 7150 | 1817 | 138 | 1668 | 11 | 361 | 71 |
| 当前（11-03） | 22 | 2611 | 580 | 1 | 577 | 2 | 106 | 0 |

全量中的借用对象为 `param` 1426、`null_init` 3907；当前为 `param` 481、
`null_init` 1550。当前 2611 个对象中只有 580 个是实际分配，其余 2031 个是借用对象，
因此不能把 `obj` 总数当作“分配/泄漏”总数。

当前实际分配的逃逸/归属：

- `call`：577 = 473 `ESCAPED` + 104 `FRAME_OWN`
- `new`：1 = 0 `ESCAPED` + 1 `FRAME_OWN`
- `string-concat`：2 = 1 `ESCAPED` + 1 `FRAME_OWN`
- 合计：580 = 474 `ESCAPED` + 106 `FRAME_OWN`
- 当前 `FREE` 106，`FIELD_FREE` 0；`FRAME_OWN` 与 `FREE` 数量相等，但数量相等不等于
  语义正确（见第 4 节）。

当前参数摘要共 1879 个：

- 1612 个 `Read` / `EscNone`
- 267 个 `OtherRef` / `EscCaller`
- 0 个 `EscAny`、0 个 `EscGlobal`

### 2.3 当前 22 项逐项数据

`obj` 含借用对象；`actual` = `new + call + concat`；`esc`/`own` 均只统计实际分配。

| 测试 | funcs | params | obj | new | call | concat | actual | esc | own | FREE | FF | callsAny |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| `pkg/slices/test` | 180 | 95 | 108 | 0 | 21 | 0 | 21 | 21 | 0 | 0 | 0 | `{"": 30}` |
| `pkg/strings/test` | 151 | 66 | 187 | 0 | 59 | 0 | 59 | 21 | 38 | 38 | 0 | `{"": 14}` |
| `test/complexTest` | 173 | 68 | 115 | 0 | 22 | 2 | 24 | 22 | 2 | 2 | 0 | `{"": 16}` |
| `test/derefTest` | 159 | 66 | 108 | 0 | 21 | 0 | 21 | 21 | 0 | 0 | 0 | `{"": 14}` |
| `test/gcfree` | 153 | 67 | 111 | 1 | 22 | 0 | 23 | 22 | 1 | 1 | 0 | `{"": 16}` |
| `test/gcfree2` | 153 | 68 | 111 | 0 | 22 | 0 | 22 | 22 | 0 | 0 | 0 | `{"": 15}` |
| `test/m5` | 155 | 67 | 110 | 0 | 22 | 0 | 22 | 21 | 1 | 1 | 0 | `{"": 14}` |
| `test/map_test` | 151 | 66 | 108 | 0 | 21 | 0 | 21 | 21 | 0 | 0 | 0 | `{"": 14}` |
| `test/mp_map` | 165 | 66 | 108 | 0 | 21 | 0 | 21 | 21 | 0 | 0 | 0 | `{"": 24}` |
| `test/mp_min` | 165 | 66 | 108 | 0 | 21 | 0 | 21 | 21 | 0 | 0 | 0 | `{"": 24}` |
| `test/negIdx` | 180 | 95 | 108 | 0 | 21 | 0 | 21 | 21 | 0 | 0 | 0 | `{"": 30}` |
| `test/rcSimple` | 152 | 66 | 108 | 0 | 21 | 0 | 21 | 21 | 0 | 0 | 0 | `{"": 14}` |
| `test/rctest` | 151 | 66 | 108 | 0 | 21 | 0 | 21 | 21 | 0 | 0 | 0 | `{"": 14}` |
| `test/sliceTest` | 181 | 96 | 108 | 0 | 21 | 0 | 21 | 21 | 0 | 0 | 0 | `{"": 30}` |
| `test/slice_minimal` | 272 | 100 | 112 | 0 | 23 | 0 | 23 | 22 | 1 | 1 | 0 | `{"": 30}` |
| `test/slice_test` | 272 | 100 | 114 | 0 | 23 | 0 | 23 | 22 | 1 | 1 | 0 | `{"": 30}` |
| `test/sortIntOnly` | 245 | 109 | 128 | 0 | 32 | 0 | 32 | 22 | 10 | 10 | 0 | `{"": 34}` |
| `test/sortMinimal` | 245 | 109 | 128 | 0 | 32 | 0 | 32 | 22 | 10 | 10 | 0 | `{"": 34}` |
| `test/sortMinimal2` | 245 | 109 | 128 | 0 | 32 | 0 | 32 | 22 | 10 | 10 | 0 | `{"": 34}` |
| `test/sortQuick` | 245 | 109 | 128 | 0 | 32 | 0 | 32 | 22 | 10 | 10 | 0 | `{"": 34}` |
| `test/sortStrOnly` | 337 | 114 | 139 | 0 | 35 | 0 | 35 | 23 | 12 | 12 | 0 | `{"": 34}` |
| `test/sortTest` | 248 | 111 | 128 | 0 | 32 | 0 | 32 | 22 | 10 | 10 | 0 | `{"": 34}` |
| **合计** | **4378** | **1879** | **2611** | **1** | **577** | **2** | **580** | **474** | **106** | **106** | **0** | **533 个空字符串** |

> `callsAny` 当前只出现空字符串条目；非空 `callsAny` 全部来自旧产物。当前
> `hasRealAnyCalls` 会过滤空字符串，因此这些条目本身不再代表“未知调用”。

## 3. 覆盖率分析

### 3.1 没有单个测试覆盖全部标准库

当前 22 个产物的包根并集为：

`pkg/builtin`、`pkg/console`、`pkg/maps`、`pkg/memory`、`pkg/slices`、`pkg/sort`、
`pkg/strings`、`pkg/syscall`，外加测试根目录。

没有单个测试导入上述全部包。最宽覆盖是 `test/sortStrOnly`，但它也只有 8 个根：

`(test-root)`、`pkg/builtin`、`pkg/console`、`pkg/memory`、`pkg/slices`、`pkg/sort`、
`pkg/strings`、`pkg/syscall`。

### 3.2 最宽覆盖测试

| 测试 | funcs | 根数 | params | obj | actual | esc | own/free |
|---|---:|---:|---:|---:|---:|---:|---:|
| `test/sortStrOnly` | 337 | 8 | 114 | 139 | 35 | 23 | 12 |
| `test/slice_minimal` | 272 | 7 | 100 | 112 | 23 | 22 | 1 |
| `test/slice_test` | 272 | 7 | 100 | 114 | 23 | 22 | 1 |
| `test/sortTest` | 248 | 7 | 111 | 128 | 32 | 22 | 10 |
| `test/sortIntOnly` | 245 | 7 | 109 | 128 | 32 | 22 | 10 |
| `test/sortMinimal` | 245 | 7 | 109 | 128 | 32 | 22 | 10 |
| `test/sortMinimal2` | 245 | 7 | 109 | 128 | 32 | 22 | 10 |
| `test/sortQuick` | 245 | 7 | 109 | 128 | 32 | 22 | 10 |

`sortStrOnly` 的 337 个函数、8 个根和 12 个释放计划是当前最丰富的样本；`slice_minimal`
/`slice_test` 覆盖 `pkg/slices`，但只有 1 个归属/释放对象。`sortTest` 是唯一包含
`_checkStrSorted` 条件表达式分配的当前测试，但该函数 LLR 为空（见 4.4）。

### 3.3 旧测试的覆盖不能直接算入当前结论

- `test/thread`：旧 246 funcs、7 根；重新生成 262 funcs、94 obj、2 FREE。
- `test/time`：旧 257 funcs、6 根；重新生成 286 funcs、146 obj、7 FREE。
- `pkg/console/test`：旧 195 funcs、5 根；重新生成 243 funcs、69 obj、1 FREE。
- `pkg/sort/test`：旧 247 funcs、6 根；重新生成 245 funcs、85 obj、10 FREE；该测试
  目录引用已删除函数，是 stale test，不应作为当前语料。
- `pkg/math/bits/test`：10-18 产物，129 funcs；w13 重新生成失败：
  `Type Error: operator * not defined for type T`（`pkg/math/bits/bits.cute:12:24`）。
  该产物不可验证，不能用于当前结论。
- `test/_mp_probe`：探针产物，不是正式语料。

### 3.4 旧产物重生成的差异

| 目录 | funcs | obj | FREE | callsAny | retOwned |
|---|---:|---:|---:|---|---:|
| `test/thread` | 246→262 | 75→94 | 2→2 | `len` 11→`""` 14 | 26→28 |
| `test/time` | 257→286 | 31→146 | 7→7 | `len` 10→`""` 14 | 20→26 |
| `pkg/console/test` | 195→243 | 34→69 | 1→1 | `""` 10→`""` 14 | 16→22 |
| `pkg/sort/test` | 247→245 | 128→85 | 10→10 | `""` 34→`""` 34 | 22→22 |

`gc_*` 旧测试的重新生成差异更能说明旧产物低估：

| 测试 | obj | FREE | FIELD_FREE | `site=new` |
|---|---:|---:|---:|---:|
| `gcOwnership` | 49→84 | 3→13 | 3→13 | 0→14 |
| `gcStructFree` | 48→68 | 1→1 | 4→4 | 0→1 |
| `gc_complex` | 59→123 | 2→29 | 4→31 | 0→3 |
| `gc_loop` | 62→84 | 8→8 | 2→2 | 0→2 |
| `heap_new` | 46→70 | 0→5 | 0→2 | 0→5 |
| `gc_cond` | 59→80 | 7→7 | 6→6 | 0→1 |
| `gc_deep` | 57→79 | 6→6 | 12→12 | 0→1 |

这些旧测试的 `callsAny` 也从 `len`/`new` 变为当前的空字符串条目；旧计数不能代表
w13 行为。

## 4. 非最优项清单

严重度按“对当前正确性的风险”排序；`高` 表示可能泄漏或可能 use-after-free/double-free，
`中` 表示保守泄漏或分析质量下降，`低` 表示测量/文档口径问题。

### 4.1 高：`ret len(t)` 导致真实漏释放

**证据（当前 11-03）**

- `test/gcfree.useTemp`：
  ```
  == useTemp
    obj[0] t site=call:makeGreeting ESCAPED
  ```
  没有 `FREE t`。
- `test/gcfree2.useTemp`：
  ```
  == useTemp
    obj[0] name site=param:name ESCAPED
    obj[1] t site=call:makeGreeting ESCAPED
  ```
  没有 `FREE t`。
- `test/gcfree2` 源码注释明确期望 `useTemp` 内局部 `t` 在函数出口自动释放；实际
  1000 次循环仍只靠 `rc` 值校验通过，泄漏不会让测试失败。

**最小探针**

`/tmp/opencode/gcprobe_lenret`：

- `f_ret_len()` 中 `ret len(t)`：`t site=call:make ESCAPED`，无 `FREE`。
- `f_var_len()` 中 `var n = len(t); ret n`：`t FRAME_OWN` + `FREE t`。
- `f_no_len()` 中直接返回 `t`：`t FRAME_OWN` + `FREE t`。

**根因**

`compile/gc/llr.go` 的 `markCallArgObjExpr` 在返回表达式中遇到 `len(t)` 时调用
`ParamEscapes("len", 0)`。`len` 没有函数摘要，`ParamEscapes` 返回 `EscAny`，于是 `t`
被标记为 `ESCAPED`。本应跳过内建纯函数的 `__` 前缀保护只匹配 `__...`，不匹配裸
`len`。结果是纯读取调用被当成逃逸调用，释放计划被抑制。

**影响**

实际堆分配泄漏；`test/gcfree`、`test/gcfree2` 仍返回 0，说明现有测试没有泄漏断言。
这是当前语料中最明确的“测试绿但 GC 非最优”案例。

### 4.2 高：`VarBlock` 右值调用的参数逃逸未传播

**探针**

`/tmp/opencode/gcprobe_paramesc`：

```cute
var g: *Node = nil

fn keep(p: *Node) int {
    g = p
    ret 0
}

fn f() int {
    var n: *Node = new(Node)
    n.val = 7
    var r: int = keep(n)
    ret r
}
```

摘要中 `keep`：

- `params: [{index: 0, mode: 4, escape: 3}]`（`EscGlobal`）
- `hasGlobalOwnStore: true`

但调用方 `f` 的 LLR：

- `n site=new FRAME_OWN`
- 生成 `FREE n`

**根因**

`markCallArgObjs` 只对独立的 `*parser.CallBlock` 语句调用；`markCallArgObjExpr` 只处理
`ReturnBlock` 顶层调用表达式。`VarBlock` 右值（`var r = keep(n)`）没有走参数逃逸传播。
`analyzeBody` 虽然记录了 `keep` 的全局存储，但 `applyCallee` 没有把该信息传播给调用方，
`ComputeLLR` 也没有用 `HasGlobalOwnStore` 做门控。

**影响**

全局仍持有 `n`，调用方却计划释放 `n`，存在 use-after-free 风险。该问题比单纯漏释放更
严重，因为释放后全局指针仍可被访问。

### 4.3 高：返回参数别名被当作新分配，产生 double-free 计划

**探针**

`/tmp/opencode/gcprobe_retparam`：

```cute
fn ident(p: *Node) *Node {
    ret p
}

fn f() int {
    var n: *Node = new(Node)
    var m: *Node = ident(n)
    ret 0
}
```

摘要中 `ident`：`retOwned=true, retEscape=1`，参数 `escape=1`。

调用方 LLR：

- `n site=new FRAME_OWN`
- `m site=call:ident FRAME_OWN`
- 同时生成 `FREE n` 和 `FREE m`

**根因**

`processAssign`/`exprAllocates` 把任何“拥有返回类型”的调用都视为新分配，生成
`site=call:<fn>`；但 `ident` 返回的是参数别名，不是新对象。`RetOwned` 只表示“返回类型
是拥有指针”，不表示“返回值一定是新分配”。

**影响**

同一对象可能被释放两次，或原对象在别名仍被使用时被释放。该问题与 4.2 同属“调用边界
所有权语义不完整”。

### 4.4 高：条件表达式中的分配完全不可见

**证据**

`test/sortTest._checkStrSorted`（源码约 201-217 行）在 `for` 内的 `if` 条件中调用两次
`strings.makeString(...)`：

```cute
if sort.compareStrings(
    strings.makeString(*_p1, *_p2, *_p3),
    strings.makeString(*_p4, *_p5, *_p6)
) > 0 {
    ret false
}
```

但当前 `test/sortTest/gc_summary.json` 中 `_checkStrSorted`：

- `hasHeapAllocs` 缺失
- `callsAny` 缺失
- `params` 缺失
- `gc_llr.txt` 中该函数节为空

`test/sortTest.main` 也是空 LLR；`main` 的释放计划本身只作诊断（codegen 跳过 `main`），
但 `_checkStrSorted` 是实际被调用的库函数，其条件分配应被分析。

**根因**

- `compile/gc/llr.go:387` 的 `scanStatements` 没有扫描 `IfBlock.Condition` 和
  `ForBlock` 条件表达式中的调用。
- `compile/gc/analyze.go` 的 `analyzeBody` 没有在这些位置设置 `HasHeapAllocs`。
- `ComputeLLR` 在 `HasHeapAllocs` 为假时直接跳过整个函数。

**影响**

条件表达式中的字符串分配没有对象、没有释放计划，属于“分析不可见”的真实漏释放。
这也说明 `main` 空 LLR 不能简单当作“无分配”；`pkg/slices/test.main` 空 LLR 是合理的
（没有拥有型分配），但 `sortTest._checkStrSorted` 空 LLR 不合理。

### 4.5 中：`bumpParams` 过度逃逸

当前 `pkg/strings` 中有 12 个参数被标为 `mode=4 escape=1`：

`clone[0]`、`repeatN[0]`、`replace[0]`、`replace[1]`、`replace[2]`、`reverse[0]`、
`trim[0]`、`trim[1]`、`trimPrefix[0]`、`trimPrefix[1]`、`trimSuffix[0]`、
`trimSuffix[1]`。

按当前源码分支可判定：

- **明显不必要（7 个）**：`repeatN[0]`、`replace[1]`、`replace[2]`、`trim[0]`、
  `trim[1]`、`trimPrefix[1]`、`trimSuffix[1]`。
- **保守上必要（5 个）**：`clone[0]`、`replace[0]`、`reverse[0]`、`trimPrefix[0]`、
  `trimSuffix[0]`。这些函数在空串/无匹配路径上可能 `ret s`，在路径不敏感分析下标为
  逃逸是保守正确的。

**根因**

`compile/gc/analyze.go:236` 的 `bumpParams` 只要返回表达式引用了任意被跟踪参数，就把
**全部**拥有参数提升到同一逃逸层级和 `ModeOtherRef`。例如 `replace` 在
`old == ""` 时返回 `s`，会把 `old`、`new` 也一起标为逃逸。

`test/gcfree2.makeGreeting` 的 `name` 也被标为 `mode=4 escape=1`，但 `name` 只参与
字符串拼接返回，不应逃逸；这是同一规则的副作用。

**影响**

过度逃逸会抑制释放计划，形成保守泄漏；对独立调用尤其明显（见 4.6）。它不会造成
use-after-free，但会降低 GC 分析的实际收益。

### 4.6 中：独立调用参数被过度标记，变量初始化路径又不一致

**探针 A：`/tmp/opencode/gcprobe_overesc2`**

`f()` 中把局部 `strings.repeat(...)` 结果直接作为独立调用参数传给
`strings.trim`、`strings.replace`、`strings.trimPrefix`、`strings.trimSuffix`、
`strings.repeatN`、`strings.clone`。结果六个输入全部 `ESCAPED`，零 `FREE`。

**探针 B：`/tmp/opencode/gcprobe_overesc`**

把同样的调用放进变量初始化器后，所有输入都变成 `FRAME_OWN` 并被释放。说明
`markCallArgObjs` 的独立调用路径与 `VarBlock` 右值路径行为不一致：前者过度逃逸，后者
完全不做参数逃逸传播（与 4.2 同根）。

**影响**

同一语义的调用因语法位置不同得到不同的释放计划，既不利于测试稳定，也说明调用参数
逃逸传播没有统一入口。

### 4.7 中：同块别名导致分支局部对象被过度标记

`test/gcOwnership.testBranchAlloc`：

```cute
var result: *Node
if flag == 1 {
    var n: *Node = new(Node)
    result = n
} else {
    var n: *Node = new(Node)
    result = n
}
ret result.val
```

w13 重新生成的 LLR：

```
obj[0]  site=null_init ESCAPED
obj[1]  site=new ESCAPED
obj[2] n site=new ESCAPED
```

没有 `FREE`。对象在 `ret result.val` 之后即可释放；当前因 `result = n` 的同块别名被
`processAssign`（`compile/gc/llr.go:608-615`）直接标为 `ESCAPED`，释放计划被抑制。

这是保守但非最优的行为。它与 4.5 不同：这里不是摘要过度逃逸，而是 LLR 内别名处理
过度保守。

### 4.8 中：`HasGlobalOwnStore` 是未生效的保守门槛

- `compile/gc/analyze.go:154-155` 在“全局 = 拥有值”时设置
  `fs.HasGlobalOwnStore = true`。
- `compile/gc/summary.go:115-117` 声明并注释为“禁用自动释放优化（保守门槛）”。
- 但 `ComputeLLR` 只检查 `hasRealAnyCalls` 和 `HasHeapAllocs`；`applyCallee` 也没有
  把该标志传播给调用方。

因此该门槛目前是“文档存在、实现未使用”。4.2 的探针正是该缺口的直接表现。要么让
`ComputeLLR`/调用边界真正消费该标志，要么删除“禁用自动释放”的文档承诺，避免误以为
已有保护。

### 4.9 中：`callsAny` 语义与旧产物污染

当前 22 个产物只有 `callsAny: [""]`，共 533 个条目；`hasRealAnyCalls` 会过滤空字符串。
当前没有 `EscAny`/`EscGlobal` 参数。

10-18 旧产物中有 869 个函数带非空 `callsAny`：

- `len` 840
- `new` 25
- `f` 1
- `s.stringify` 1
- `__list_len` 1
- `__list_cap` 1
- `newRC` 1

其中 `callsAny ["new"]` 正是旧版把 cast 当 `new`、并把内建 `new` 当无摘要调用的历史
问题；w13 已把它改为空字符串条目。当前不能再用旧产物证明 `callsAny` 仍在污染参数
逃逸，但旧产物仍会误导覆盖率/释放计数。

### 4.10 低：`retOwned` 一致性检查是恒真式

当前统计：

- `retOwned && retEscape == 0`：0
- `!retOwned && retEscape != 0`：0

看似“无矛盾”，但 `compile/gc/analyze.go:48-54` 中两个字段都来自同一个
`isOwning(fb.Return[0])` 初始化：

```go
if len(fb.Return) > 0 && isOwning(fb.Return[0]) {
    fs.RetOwned = true
    fs.RetEscape = EscCaller
}
```

因此上述检查无法发现“返回参数别名却标记 RetOwned”的问题（见 4.3）。要检测该问题，
需要独立的“返回值是否为新分配”摘要，而不是用 `RetOwned` 与 `RetEscape` 互校。

### 4.11 低：esccheck 对字符串测试是空验证

`esccheck` 只统计根 `new` 对象。当前：

- `test/gcfree2`：`对象=0 泄漏=0 提前释放=0`
- `test/sortTest`：`对象=0 泄漏=0 提前释放=0`
- `test/sortStrOnly`：`对象=0 泄漏=0 提前释放=0`

因此这些测试的“红项 0”不能证明字符串分配/释放正确。`test/gcfree2` 的 4.1 漏释放就是
反例：esccheck 看不到它。

### 4.12 低：旧产物 cast-as-new 与 stale 测试

- `pkg/slices` 的 10-31 产物有 70 个 `site=new`，其中大量来自 cast；当前
  `pkg/slices/test` 为 0 个 `site=new`，`splitGet` 的 `hdr`/`cell` 是
  `site=null_init`。不能用旧产物声称当前仍有 cast-as-new。
- `pkg/sort/test` 是引用已删除函数的 stale test；其 11-02 产物不能作为当前测试。
- `pkg/math/bits/test` 无法用 w13 重新生成，10-18 产物不可验证。
- `test/_mp_probe` 是探针目录，不是正式语料。

### 4.13 低：当前 `new`/字段释放覆盖不足

当前 22 个产物只有 1 个 `site=new`（`test/gcfree.loc`），`FIELD_FREE` 为 0。这不是说
当前分析一定错了，而是说当前样本几乎不覆盖 `new`/字段释放路径；旧 `gc_*` 测试虽然
覆盖丰富，但产物是 10-18，重新生成后差异很大（见 3.4）。因此：

- 不能用当前 22 项的 `FIELD_FREE=0` 推断字段释放逻辑已退化；
- 也不能用旧 `gc_*` 的 `FIELD_FREE` 数量推断当前行为；
- 需要重新生成 `gc_*` 或新增当前版本的字段释放测试，才能对字段路径下结论。

## 5. 建议（仅文档结论，未实施）

按优先级：

1. **先修正确性风险**：
   - 对 `len` 等纯内建函数建立显式“不逃逸”摘要，或修正 `markCallArgObjExpr` 的内建
     判断，避免 `ret len(t)` 把 `t` 标成 `ESCAPED`。
   - 统一调用参数逃逸传播入口，覆盖 `VarBlock` 右值、`ReturnBlock`、`IfBlock`/`ForBlock`
     条件表达式和独立调用。
   - 区分“返回新分配”和“返回参数别名”；`RetOwned` 不能单独作为 `site=call:*` 的
     分配依据。
   - 让 `HasGlobalOwnStore` 真正参与调用方释放门控，或删除该未实现承诺。
2. **修分析可见性**：
   - `scanStatements` 扫描条件表达式；`analyzeBody` 在条件表达式含分配时设置
     `HasHeapAllocs`。
   - 对 `main` 以外的空 LLR 增加“无分配”断言/诊断，避免条件分配被静默跳过。
3. **降低过度逃逸**：
   - 让 `bumpParams` 只提升实际被返回表达式引用的参数，或至少按参数分别判断；
   - 对空串/无匹配返回原参数的路径做路径敏感或显式别名摘要；
   - 重新评估同块别名 `objEscaped` 的保守标记，区分“可能逃出块”和“仅块内别名”。
4. **改善验证口径**：
   - esccheck 增加字符串/LLR 维度，或在 `gc_llr` 层增加期望快照/泄漏断言；
   - 至少为 `ret len(t)`、全局存储参数、别名返回、条件分配、独立调用参数建立回归
     测试；
   - 明确 `main` 的释放计划只作诊断，codegen 不执行。
5. **清理产物基线**：
   - 只把 11-03 的 22 项作为当前可比基线；
   - 重新生成 `test/thread`、`test/time`、`pkg/console/test` 或明确标记为 stale；
   - `pkg/sort/test`、`pkg/math/bits/test`、`test/_mp_probe` 不得进入当前统计；
   - 不把旧 `callsAny ["len"]`/`["new"]`、cast-as-new 当作当前行为。

## 6. 证据索引

- 当前逐项统计：`/tmp/opencode/gc_audit_current.txt`（外部审计产物，未提交）
- `ret len(t)` 探针：`/tmp/opencode/gcprobe_lenret/gc_llr.txt`
- 全局存储参数探针：`/tmp/opencode/gcprobe_paramesc/gc_llr.txt`
- 返回别名探针：`/tmp/opencode/gcprobe_retparam/gc_llr.txt`
- 变量初始化/独立调用对比：`/tmp/opencode/gcprobe_overesc`、`/tmp/opencode/gcprobe_overesc2`
- 当前条件分配空 LLR：`test/sortTest/gc_llr.txt` 的 `_checkStrSorted` 节
- 当前 `ret len(t)` 漏释放：`test/gcfree/gc_llr.txt`、`test/gcfree2/gc_llr.txt`
- 旧/新 `gcOwnership` 对比：`test/gcOwnership/gc_llr.txt` 与
  `/tmp/opencode/gcprobe_test_gcOwnership/gc_llr.txt`
- 相关实现位置：
  - `compile/gc/analyze.go:154-155`（`HasGlobalOwnStore` 设置）
  - `compile/gc/analyze.go:184`（`applyCallee`）
  - `compile/gc/analyze.go:236`（`bumpParams`）
  - `compile/gc/analyze.go:360`（`exprAllocates`）
  - `compile/gc/llr.go:91`（`ComputeLLR`）
  - `compile/gc/llr.go:387`（`scanStatements`）
  - `compile/gc/llr.go:509`（`processAssign`）
  - `compile/gc/llr.go:608-615`（同块别名标记）
  - `compile/gc/llr.go:660`（`markCallArgObjs`）
  - `compile/gc/llr.go:707`（`markCallArgObjExpr`）
  - `compile/gc/summary.go:115-117`（`HasGlobalOwnStore` 声明）
  - `tools/esccheck/main.go`（仅根 `new` 对象的前端检查器）

## 7. 审计边界声明

本文档只记录审计结论与证据，**没有修改任何编译器、解析器、标准库或测试源码**。文中
的 `/tmp/opencode/*` 是外部探针/审计产物，不属于仓库资产，不提交。当前结论以 11-03
的 22 个产物为准；旧产物仅在“版本差异”章节作为对照出现。
