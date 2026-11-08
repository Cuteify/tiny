# 语法/编译器缺口实施计划（2026-11）

> 状态：待执行。本文是可落地的分阶段实施计划，不是语法参考。
> 基线：`4273a91 up`（`docs/LANGUAGE.md` 已在 `03e34e1` 提交，未 push）。
> 目标平台：x86_64 为主，x86 保证不回归。

---

## 0. 需求映射

| # | 需求 | 阶段 | 验收 |
|---|---|---|---|
| 1 | `for` post 支持显式 `i = i + 1`，不再只接受 `i++`/`i--` | P1 | `test/syntaxGaps/for_post.cute` |
| 2 | 自定义类型 `[]` / `[]=` / `[::]` 运算符重载生成代码 | P2 | `test/operatorOverload/` |
| 3 | `unsafe.cast[T]` 保持位级重解释，不做数值转换 | P3 | `test/syntaxGaps/unsafe_cast.cute` |
| 4 | 显式数值转换 `int(x)` / `i64(x)` / `f64(x)` 等 | P3 | `test/syntaxGaps/convert.cute` |
| 5 | 收窄自动导入：无 import 不能用 `strings.len` / `slices.make` | P4 | 负例 + 正例 |
| 6 | 类型内建表尽量用符号重载实现 | P5 | `intrinsicTable` + 文档 |
| 7 | `build os/arch` 修复 panic 与过滤；增加位宽；`export`/`ext`/`extret` | P6 | `test/buildDirective/` |
| 8 | 运行期 `s * n` 映射到 string 符号重载，内部包装重复函数 | P7 | `test/syntaxGaps/string_mul.cute` |
| 9 | `continue`、`while`；`continue`/`break` 数字跳多级；`fallthrough` | P8 | `test/controlFlow2/` |
| 10 | `pub` 不新增语义；`try/except/finally` 暂不实现 | 非目标 | 文档注明 |

---

## 1. 总原则与非目标

### 1.1 总原则

- 语法行为以 Go parser/编译器的可观察行为为准；`PROJECT.md` §8 为过期速记，不作依据。
- 类型内建/重载的唯一事实源是 `parser/intrinsic.go` + `docs/stdplan/TYPE_INTRINSIC.md`。
- 新能力优先 lowering 成普通调用/符号重载；编译器内建只保留必须拿左值/地址/底层布局的形状。
- 暂不支持的能力必须显式报错，不能静默丢弃、不能生成错误代码。
- 所有新增分支先加“只对目标形态生效”的判定，再动现有通用路径。

### 1.2 非目标

- `pub`：不新增语义。当前字段默认导出已经成立，不加访问控制。
- `try / except / finally`：本轮不实现。关键字保留；遇到时明确报“暂不支持”，不要当普通标识符静默处理。
- 浮点完整 ABI：`build ext` v1 不支持浮点参数；x86 的 f64↔int 转换暂不实现。
- 容器/结构体的 `build extret` 返回值：暂不支持，显式报错。
- `int * string` 的交换形式：v1 只保证 `string * int`，是否支持反向后续再定。

---

## 2. P0：基线与测试设施

### 2.1 基线

- 构建：`go build -o /tmp/opencode/cuteify2 .`
- 运行约定：`CUTE_ROOT=<repo> CUTE_ARCH=x86_64 /tmp/opencode/cuteify2 -S -o <dir>/out.asm <dir>`，再 `nasm` + `gcc` 链接运行。
- 回归目录：
  - `test/overload`
  - `test/overload_types`
  - `test/controlFlow`
  - `test/buildKeyword`
  - `test/complexTest`
  - `test/for_range_test`
  - `test/stringUtils`
  - `test/gcRetFree`
- 记录每个目录在 x86_64 / x86 的当前退出码，作为后续对照。

### 2.2 统一架构判定

现状：`CUTE_ARCH` 在至少五处独立读取，默认值不一致：

- `type/type.go` init：`CUTE_ARCH == "x86_64"` 决定 `TargetPointerSize`。
- `compile/compiler.go`：`Is64Bit`。
- `parser/func.go:898`：参数偏移。
- `parser/build.go checkArchMatch`：默认 `x86`。
- `package/package.go preFilterBuild`：默认 `x86`。

改法：

- 新增 `typeSys.TargetArch()`：
  - `CUTE_ARCH` 非空则直接使用。
  - 否则 `runtime.GOARCH` 映射：`amd64 → x86_64`、`386 → x86`，其余原样。
- `type` init、`compile/compiler.go`、`parser/func.go`、`parser/build.go`、`package/package.go` 全部改用该 helper。
- 目标：`build arch` 的比较值与 `TargetPointerSize` 永远一致。

### 2.3 新增测试目录

- `test/syntaxGaps/`：for post、数值转换、unsafe.cast、string 重复、自动导入负例。
- `test/operatorOverload/`：get/set/slice、eq、一元、复合索引赋值。
- `test/buildDirective/`：os/arch/bits/export/ext/extret。
- `test/controlFlow2/`：continue/while/fallthrough/多级跳转。

每个目录遵守现有约定：`main.cute` + `package.json`，成功用例 `ret 42`。

---

## 3. P1：for post 支持赋值表达式

### 3.1 现状与根因

- `parser/for.go parseIncrement` 调 `p.ParseExp(endCursor-1)`。
- `i = i + 1` 经 `handleName` 的赋值分支构造 `VarBlock`，再走 `ParseVar`。
- `ParseVar` 使用 `p.FindEndCursor()` 作为停止点，会吞掉循环体的 `{`，导致后续解析错位。
- `ForEnd` 已经支持 `Increment.Var != nil` 时走 `a.VarDecl(increment.Var)`，所以只要解析正确，代码生成可复用。

### 3.2 改动

- `Parser` 增加字段 `exprStop int`（0 表示未设置）。
- `parseIncrement`：
  - 解析前保存旧值，设 `p.exprStop = endCursor - 1`。
  - 调 `ParseExp`。
  - 解析后恢复旧值。
- `parser/var.go` 的 `ParseVar`：
  - 计算停止点时使用 `min(p.FindEndCursor(), p.exprStop)`；`exprStop == 0` 时忽略。
- 不改变 `i++` / `i--` 路径。

### 3.3 测试

- `for i := 0; i < 5; i = i + 1 { sum += i }` → `sum == 10`。
- `for i := 0; i < 5; i += 1 { sum += i }` → `10`。
- 嵌套 for，post 分别为 `i = i + 1` / `j++`。
- 回归 `test/controlFlow` 现有 for 用例。

### 3.4 验收

- 显式赋值、复合赋值、自增自减三种 post 都能解析。
- 循环体 `{` 不被吞，后续语句正常。
- x86_64/x86 退出码一致。

---

## 4. P2：自定义类型运算符重载 lowering

### 4.1 现状与根因

- `parser/exp_check.go checkOverload` 只设置 `exp.Type`，没有 lowering，也没有代码生成。
- `exp.Left == nil` 时 `checkOverload` 立即返回 false，一元 `-`/`!`/`~` 永远不生效。
- `checkEq` 在左右类型相同时不会进入 `checkOverload`，同类型结构体 `V == V` 走原生首字段比较，不会调用 `V.eq`。
- 自定义索引 AST 形状：
  - `Separator == "[]"`
  - `Right == receiver`
  - `Left == nil`
  - `Index[0..2]`
  - `IndexSlice == true` 表示切片
- `opMethodMap` 里的 `"[::]"` 与 `parser/pr.go` 的 `[::]` 分支是遗留/不可达；parser 实际只产生 `[]` + `IndexSlice`。
- `checkIndexAssign` 只处理 map；`v[i] += x` 不会走索引赋值路径。
- codegen 的 `indexAccess`/`indexSet`/`sliceExp` 没有自定义类型分支，默认按 list/array 裸内存寻址，`elemSize` 还会落到 1。

### 4.2 lowering 设计

在 Check 期把自定义类型索引改写成普通 `CallBlock`，带 `ThisVar`：

| 源码 | lowering |
|---|---|
| `v[i]` | `V.get(i)` |
| `v[i] = x` | `V.set(i, x)` |
| `v[a:b:c]` | `V.slice(a, b, c)` |

约定：

- 判定依据：接收者类型不是 `list/string/array/map`，且存在 `get/set/slice` 方法。
- 切片缺省边界：
  - 省略 start → 字面量 `0`。
  - 省略 end → 字面量 `-1`（表示到末尾）。
  - 省略 step → 字面量 `1`。
- 接收者 v1 限定为 `VarBlock`（变量/字段路径）；非左值接收者报清晰错误。
- 方法名沿用 `get` / `set` / `slice`；不再使用 `[::]` 作为 separator。
- 生成 `CallBlock` 后清空 `Separator/Left/Right/Index`，语句位置调 `SetStmt()`，确保 `compile/exp/exp.go` 的 `generate` 先按 `Separator` 分派时不会命中旧索引分支。

### 4.3 一元与相等

- 一元：
  - `operand := exp.Left; if operand == nil { operand = exp.Right }`。
  - `-v → v.neg()`、`!v → v.not()`、`~v → v.bnot()`。
  - 接收者同样限定 `VarBlock`。
- 相等：
  - 左右类型相同且为自定义类型时，先查 `eq/ne` 方法。
  - 有方法 → lowering 成 `V.eq(other)` / `V.ne(other)`。
  - 无方法 → 回退现有原生比较，不改变结构体默认行为。
- `!=` 若只有 `eq` 没有 `ne`，v1 报错或按 `!eq` 处理需在实现时二选一并写测试；计划默认要求显式 `ne`，避免隐式反转带来语义差异。

### 4.4 复合索引赋值

- `v[i] += x` 在 `checkAssign` 阶段先展开为 `v[i] = v[i] + x`，再走 set lowering。
- 展开后右侧的 `v[i]` 按 get lowering；左侧按 set lowering。
- `checkIndexAssign` 必须先检查 `idxNode.Right.Type` 是否为自定义类型，再决定是否调用 `checkIndex`；否则 LHS 会被误 lower 成 get，赋值形状被破坏。

### 4.5 涉及文件

- `parser/exp_check.go`：`checkOverload`、`checkIndex`、`checkIndexAssign`、`checkAssign`、`checkEq`。
- `parser/exp.go`：`opMethodMap`、`unaryOpMethodMap`、`handleIndex` 形状确认。
- `parser/call.go`：`CallBlock` 构造、`ThisVar` 绑定、方法候选选择。
- `compile/exp/exp.go`：确认 lowering 后的 `CallBlock` 走普通调用路径；旧 `indexAccess`/`indexSet`/`sliceExp` 保留给内建类型。

### 4.6 测试

- `Matrix.get/set/slice`（现有样例）：
  - `m[1]` 读。
  - `m[1] = 7` 写。
  - `m[1:3:1]` 切片。
  - 省略边界：`m[:2]`、`m[1:]`、`m[:]`。
- `V == V` 调用 `eq`；`V != V` 调用 `ne`。
- `-v` 调用 `neg`；`!v`、`~v`。
- `v[i] += 1`。
- 非左值接收者（如 `makeV()[0]`）报清晰错误。

### 4.7 验收

- 自定义类型索引不再走裸内存寻址。
- 同类型结构体默认比较不被破坏。
- 内建 list/string/map 索引行为逐位不变。

---

## 5. P3：显式数值转换与 unsafe.cast

### 5.1 现状

- `checkBuiltin` 现有分支只有 `new/newRC/sizeof/len/cap/copy`。
- 没有数值转换分支，`int(x)` / `i64(x)` / `f64(x)` 被当普通函数调用，报 `not found function 'int'`。
- `unsafe.cast[T]` 在 `compile/exp/exp.go` 的 `builtinCall` 是直接透传实参；`checkBuiltin` 没有 `unsafe.cast` 分支，类型检查靠 `Name.IsPath()` 静默返回 true，`Type` 为 nil。
- 位级语义是成立的，但缺回归测试，容易被后续“数值转换”改动误伤。

### 5.2 数值转换设计

- `checkBuiltin` 增加转换分支：`int/uint/i8/i16/i32/i64/u8/u16/u32/u64/f32/f64`。
- `CallBlock` 新增独立 `ConvertType typeSys.Type`，不复用 `NewType`（`IsBuiltinNewAlloc` 会把 `NewType` 当分配语义）。
- `compile/exp/exp.go` 的 `builtinCall` 按 `ConvertType` 发转换：
  - float→int：`cvttsd2si` / `cvttss2si`，向零截断。
  - int→float：`cvtsi2sd` / `cvtsi2ss`。
  - f32↔f64：`cvtss2sd` / `cvtsd2ss`。
  - int 窄化：截断低位；有符号扩展 `movsx`，无符号扩展 `movzx`；同宽 no-op。
  - f64 仍以 IEEE-754 位模式存放，转换借用 XMM0 + `movq`。
- 目标宽度以 `type.TargetPointerSize` 为准：`int/uint` 在 x86_64 为 8，x86 为 4；`i64/u64/f64` 恒 8，`i32/u32/f32` 恒 4。
- x86_64 先实现完整路径；x86 的 f64↔int 暂不实现，显式报错并在文档注明。

### 5.3 unsafe.cast

- 保持位级重解释，不做数值转换，不改现有透传实现。
- 补测试：
  - `unsafe.cast[byte](x)`
  - `unsafe.cast[ptr](p)`
  - `unsafe.cast[*T](addr)`
- 文档注明：
  - `unsafe.cast[int](1.5)` 在 x86 得 0（低 32 位），x86_64 得 `0x3FF8000000000000`。
  - 要“取低 32 位”应写 `unsafe.cast[i32]`，不要用 `unsafe.cast[int]` 表达跨架构语义。

### 5.4 测试

- `int(3.9) == 3`、`int(-3.9) == -3`。
- `u8(300) == 44`。
- `f64(7)` 的位模式正确。
- `i32(f64)`、`i64(f32)`。
- f32/f64 往返。
- `unsafe.cast` 三例。
- x86 上 f64↔int 的显式报错。

### 5.5 验收

- 所有整数/浮点转换在 x86_64 通过。
- x86 不因新分支崩溃；不支持项报错清晰。
- `unsafe.cast` 行为与当前位级语义一致。

---

## 6. P4：自动导入收窄

### 6.1 现状

- 根包预加载 `strings/maps/slices`，`parser/name.go` 的 `FixPath` 在找不到用户 import 时用 `IntrinsicPkgs` 回退。
- 结果：无 import 也能写 `strings.len("abc")`、`slices.make[int](4)`。
- `builtin` 也由根包自动注入，但这是编译器插入函数（`print/println/panic`）需要的。

### 6.2 改动

- `parser/name.go` 的 `FixPath` 删除 `IntrinsicPkgs` 裸名回退。
- `IntrinsicPkgs` 只保留给 intrinsic lowering 构造完整包路径，不再作为用户名称解析入口。
- 保留 `builtin` 自动导入。
- `FixPath` 增加“包名自引用”回退：`importName == pkg.Name` 时映射到 `pkg.Path`。否则 std 包内部 `strings.foo` 自引用会断。
- 根包预加载 `strings/maps/slices` 仍保留，用于 intrinsic 实现可用；但不注册为用户别名。

### 6.3 测试

- 负例：无 import 写 `strings.len("abc")` → 编译失败。
- 负例：无 import 写 `slices.make[int](4)` → 编译失败。
- 正例：显式 `import "std:strings"` 后 `strings.len` 可用。
- 正例：string `==` intrinsic 在不 import 时仍工作。
- 正例：std 包内部 `strings.foo` 自引用仍工作。

### 6.4 验收

- 用户裸名不再命中自动导入。
- intrinsic lowering 不受影响。
- `builtin` 函数仍可直接调用。

---

## 7. P5：类型内建表符号重载化

### 7.1 原则

能 lowering 成普通调用的都走 `IntrinsicCall`；必须拿左值/地址/底层布局的保留 `IntrinsicNative`。

### 7.2 表项调整

| Kind | Op | 现状 | 计划 |
|---|---|---|---|
| string | `==` / `!=` | `strings.eq/ne` | 保持 |
| string | `*` | 无 | 新增 `strings.repeatN`，`IntrinsicCall` |
| string | `+` | Native | 暂时保留，GC 分配来源标记是 `string-concat` |
| string | `len/cap/[]/[]=` | Native | 保留 |
| map | `[]` / `[]=` | `maps.get/set` | 保持 |
| map | `len` | Native | 保留（nil map 返回 0） |
| list | `len/cap/[]/[]=` | Native | 保留（需要地址/左值，直接按布局生成） |

### 7.3 string 符号重载的落点

- string 不是 AST 里的 `TypeBlock`，不能注册 `fn string.mul`。
- 因此 string 的“符号重载”落在 `intrinsicTable` 的 `{Kind:"string", Op:"*", ...}` 条目上，Check 期 lowering 到 `strings.repeatN`。
- `docs/stdplan/TYPE_INTRINSIC.md` 同步该条目与 Native 例外原因。

### 7.4 验收

- 新增 string `*` 条目可查表、可 lowering。
- Native 例外都有注释说明，不是遗漏。
- `CUTE_NO_INTRINSIC` 行为不变。

---

## 8. P6：build 指令

### 8.1 build os / arch / bits

现状：

- `parser/build.go` 分支只有 asm、ext、extret、os、arch、link、align、noalign；无 `export`、无 `bits`。
- 顶层 `os/arch` 的 `default:` 为空，只有 `ThisBlock` 是 `FuncBlock` 时才挂 `BuildFlags`。
- `parser/func.go` 会回溯连续 os/arch Build 挂到紧随函数，但遇到 import/其他节点即断，且不覆盖 type/var。
- `package.preFilterBuild` 用正则匹配文件中第一处 `build arch/os` 并跳过整个文件；根包也走这条路径，导致 `test/buildKeyword` 在 Linux 因首处 `windows` 不匹配整文件被跳过，`rootNode == nil` 后 panic。
- std 架构文件采用文件头 `build os(...)` + import + `build arch(...)` 形式，依赖文件级过滤。

改法：

- `Build` 增加 `Bits []int`。
- `build bits(32)` / `bits(64)` / `bits(32, 64)`：
  - 解析括号内数字列表。
  - `checkBitsMatch` 比较 `type.TargetPointerSize*8`。
  - 不匹配设 `Ignore`。
- 顶层 `os/arch/bits` 语义：只作用于紧随其后的声明，不是整文件过滤。
- `Parser` 增加 `PendingBuilds []*Build`。
- `Build.Parse` 在根作用域遇到 `os/arch/bits` 时只记 pending，不 `AddChild`。
- 下一个 func/type/var 声明时消费：
  - func：挂 `FuncBlock.BuildFlags`。
  - type/var：挂 Node 级标记。
- `Node` 增加 `BuildIgnored bool`：
  - `Node.Check` 遇到 `BuildIgnored` 跳过。
  - `compileChildren` 跳过。
  - 注意不要复用 `Ignore`：`handleName` 的变量节点用 `Ignore: true`，但仍必须参与 Check。
- 根包移除 `preFilterBuild`；std 架构文件（非根包）继续用文件级预过滤。
- 修 `packageInfo.AST = &parser.Node{}` 且 `Parser == nil` 时的 `rootNode.Check()` panic：无源文件/全被过滤时显式报错或跳过 Check。

测试：

- `test/buildKeyword`：Linux 上 `windowsFunc` 被忽略，`linuxFunc`、`multiOSFunc` 正常编译，不 panic。
- `build bits(64)` 在 x86_64 生效，`bits(32)` 在 x86 生效；不匹配声明被忽略。
- 顶层 build 后隔一个 import 仍作用于下一个声明（`test/buildKeyword` 现有形状）。

### 8.2 build export

- parser 增加 `case "export"`，解析 `build export("alias")`。
- 只允许函数体内，挂 `FuncBlock.BuildFlags`。
- compile 侧已有 `C.Ctx.Exports`、`collectExports`、`compileRoot` 的 `global`、`compileRootTail` 的别名标签，只需接通 parser。
- 测试：`nm` 能看到 alias 全局符号；调用 alias 可跳转到原函数。

### 8.3 build ext / extret

现状：

- `Build.Ext` / `Build.ExtRet` 只解析。
- `buildExtSysV` 只传前 6 个整数参数到 `RDI/RSI/RDX/RCX/R8/R9`，统一用 `QWORD` 装载，浮点不进 `xmm`，返回值被忽略。
- `buildExtCdecl` 统一 `push DWORD`，参数偏移用 `Type.Size()` 而 `setArgsOffset` 在 x86 按 4 字节槽记账，存在错配风险。
- `extret` 无实际代码生成。

改法：

- `build ext` v1 限定：
  - 最多 6 个整数/指针参数。
  - 不支持浮点参数，遇到显式报错。
  - 按参数宽度用 `BYTE/WORD/DWORD/QWORD` 装载；有符号用 `movsx`，无符号用 `movzx`。
  - x86_64 调用前保证 16 字节对齐。
- `build extret`：
  - 调用外部符号后，把标量返回值留在 `RAX/EAX`。
  - 跳 `func_end_<name>`。
  - 容器/结构体返回显式报错，暂不支持。
- 修 `buildExtCdecl` 的参数偏移与 `setArgsOffset` 的 4 字节槽记账错配风险。
- `compile/arch/x86_64/linux_sysv.go` 的 `Epilogue` 已生成 `func_end_<name>:`；cleanup 会保存/恢复 RAX/RDX，需确认 extret 跳转时返回值不被 cleanup 覆盖。

测试：

- `build ext` 调用 libc `abs`，验证参数与返回值。
- `build extret` 返回 `abs(-7) == 7`。
- x86_64 与 x86 各跑一次。
- 超过 6 个参数/浮点参数报错。

### 8.4 涉及文件

- `parser/build.go`：新增 bits/export，pending 逻辑。
- `parser/func.go`：移除回溯逻辑，改为统一消费 pending。
- `parser/type.go`、`parser/var.go`：type/var 的 BuildIgnored 挂载点。
- `parser/node.go`：`BuildIgnored`、Check 跳过。
- `parser/parser.go`：`PendingBuilds`。
- `package/package.go`：根包移除 preFilterBuild；空 AST 保护。
- `compile/build.go`：ext/extret 代码生成。
- `compile/compiler.go`：`compileChildren` 跳过 `BuildIgnored`；export 预扫描确认。

### 8.5 验收

- `test/buildKeyword` 不 panic。
- 顶层 build 只影响紧随声明。
- std 架构文件仍按文件级过滤。
- export/ext/extret 在 x86_64 可用；x86 至少不回归。

---

## 9. P7：string 重复

### 9.1 现状

- `checkMul` 已对 `string * int` 做类型推导和常量折叠，但运行期没有代码生成。
- 常量折叠直接调用 `strings.Repeat`，负数会 panic。
- `pkg/strings/strings_common.cute:563` 已有 `fn repeatN(s string, count int) string`，内部 `count <= 0` 返回 `""`，否则包装 `strings.repeat`。
- `pkg/strings` 没有 `concat`；string `+` 由 `compile/exp/exp.go` 的 `stringConcatExp` 内联生成，GC 标记为 `string-concat`。

### 9.2 改动

- `intrinsicTable` 新增 `{Kind:"string", Op:"*", Pkg:"std:strings", Fn:"repeatN", Form:IntrinsicCall, Phase:1}`。
- `checkMul` 在运行期形态下 lowering 到 `strings.repeatN(s, n)`。
- 常量折叠保持本地计算，但修负数：`n <= 0` 结果为 `""`。
- v1 支持 `string * int`；`int * string` 是否交换顺序后续再定。

### 9.3 测试

- `"ab" * 3 == "ababab"`。
- `"ab" * 0 == ""`。
- `"ab" * -1 == ""`。
- 变量次数：`s * n`，n 为运行时值。
- `test/stringUtils` 回归。

### 9.4 验收

- 运行期 string 重复不再无代码生成。
- 负数/零不 panic。
- 常量折叠与运行期结果一致。

---

## 10. P8：控制流

### 10.1 现状

- `processControlToken` 无 `continue`/`while`/`fallthrough` 分支。
- 无 `ContinueBlock`/`WhileBlock`。
- `lexer/keywords.go` 已有 `while`/`continue`/`try`/`except`/`finally` 为 `PROCESSCONTROL`；`fallthrough` 尚未加入关键字表。
- `continue` 当前被 `processControlToken` 静默丢弃。
- `test/controlFlow/main.cute` 已有 continue 用例（期望 sum=8，实际会得 10）。
- `BreakBlock.Parse` 支持 `break N` 与 `break(N)`；`compileBreakBlock` 只统计 `ForBlock` 祖先、不统计 `SwitchBlock`。
- switch 标签为 `switch_<n>` / `switch_end_switch_<n>`；`SwitchBlock` 无 `Offset`/`Node` 字段。
- `compileSwitchBlock` 每个 case 末尾固定 `jmp switch_end`，且 default 在所有非 default case 之后统一编译；`fallthrough` 需按源码顺序重构。
- `ForEnd` 在 `compile/arch/x86_64/ops.go:583` 与 `compile/arch/x86/ops.go:392`，增量后 `jmp for_<n>`；continue 需新增 `for_<n>_continue` 标签。
- `compileForRangeBlock` 出口为 `for_<n>_end`，索引自增在 body 之后；continue 需在索引自增前落点。

### 10.2 parser

- `lexer/keywords.go` 增加 `fallthrough` 到 `PROCESSCONTROL`。
- `processControlToken` 增加：
  - `while` → `WhileBlock`。
  - `continue` → `ContinueBlock`。
  - `fallthrough` → `FallthroughBlock`。
- `WhileBlock`：
  - 复用 `ForBlock` 形态，`Init=nil`、`Increment=nil`，只解析条件。
  - 或新增独立 `WhileBlock`；计划优先复用 `ForBlock`，减少 codegen 分支。
- `ContinueBlock`：
  - 支持 `continue`、`continue N`、`continue(N)`。
  - 解析逻辑仿 `BreakBlock`。
- `FallthroughBlock`：
  - 只允许出现在 switch case 内。
  - 必须是 case 最后一条语句，否则报错。

### 10.3 codegen

- `ForEnd`：
  - 在增量前发 `for_<n>_continue:`。
  - `continue` 跳这里。
- `compileForRangeBlock`：
  - 在索引自增前发 `for_<n>_continue:`。
- `compileBreakBlock`：
  - 同时统计 `ForBlock` 和 `SwitchBlock`。
  - `SwitchBlock` 增加 `Offset int` 供 break 定位。
  - 目标标签：for → `for_<n>_end`；switch → `switch_end_<n>`。
- `continue N`：
  - 只统计 `ForBlock`（Go 语义：continue 只作用于循环）。
- `compileSwitchBlock`：
  - 按源码顺序编译 case body，default 不再最后统一编译。
  - 每个 case 末尾：
    - 有 `fallthrough` → 跳下一个 case body 标签。
    - 否则 → 跳 `switch_<n>_end`。
  - 为每个 case body 生成稳定标签：`switch_<n>_case_<i>`。
  - `fallthrough` 到最后一个 case 报错。
- `continue` 在 switch 内、外层有 for 时：跳到外层 for 的 continue 标签，不跳 switch。

### 10.4 测试

- `test/controlFlow` 的 continue 用例：`sum == 8`。
- `while` 倒计时：`while i > 0 { sum += i; i -= 1 }`。
- 嵌套 `break 2`：跳出两层。
- 嵌套 `continue 2`：跳到外层循环增量。
- switch `fallthrough`：顺序执行两个 case。
- `fallthrough` 非末尾报错。
- switch 内 `break` 只退出 switch。

### 10.5 验收

- continue 不再被静默丢弃。
- while 与 for 行为一致。
- 多级 break/continue 计数正确。
- fallthrough 只在 switch 内、按源码顺序生效。

---

## 11. P9：文档同步

- `docs/LANGUAGE.md`：
  - for post 三种形式。
  - 运算符重载 lowering 与接收者限制。
  - 数值转换规则与 x86 限制。
  - 自动导入收窄。
  - build os/arch/bits/export/ext/extret。
  - continue/while/fallthrough/多级跳转。
  - string 重复。
  - `pub` 不需要；`try/except/finally` 暂不支持。
- `docs/stdplan/TYPE_INTRINSIC.md`：
  - string `*` 条目。
  - Native 例外及原因（string `+`、map `len`、list 索引/len/cap）。
- 文档中的语法状态必须与实现一致；不再把“残留代码/无效代码”写成特性。

---

## 12. 总验收矩阵

| 项目 | x86_64 | x86 |
|---|---|---|
| 现有回归目录 | 原退出码或更好 | 原退出码或更好 |
| for post | PASS | PASS |
| 自定义 get/set/slice | PASS | PASS |
| 自定义 eq/ne、一元 | PASS | PASS |
| 数值转换 | PASS | 除 f64↔int 外 PASS |
| unsafe.cast | PASS | PASS |
| 自动导入负例 | 编译失败 | 编译失败 |
| 自动导入正例 | PASS | PASS |
| string 重复 | PASS | PASS |
| build os/arch/bits | PASS | PASS |
| build export | PASS | PASS |
| build ext/extret | PASS | PASS（标量） |
| continue/while/fallthrough | PASS | PASS |
| 多级 break/continue | PASS | PASS |
| `go build ./...` | 绿色 | 绿色 |
| 新增 panic / 静默 no-op | 0 | 0 |

---

## 13. 提交拆分

按阶段一提交，中文单行前缀，显式路径，禁止 `git add -A`，不 push：

1. `计划: 新增语法缺口实施计划`
2. `修复: for 增量支持赋值表达式`
3. `实现: 自定义类型运算符重载 lowering`
4. `实现: 显式数值转换`
5. `收窄: 自动导入仅保留 builtin`
6. `重构: 类型内建表符号重载化`
7. `修复: build 指令过滤与导出`
8. `实现: string 重复运算`
9. `实现: continue/while/fallthrough`
10. `文档: 同步语法参考`

每个提交前跑对应阶段测试 + 至少一个既有回归目录；提交后 `git status` 必须干净（除用户自己的 WIP）。

---

## 14. 风险与回滚

| 风险 | 影响 | 缓解 |
|---|---|---|
| P2 lowering 误伤内建 list/string/map | 大面积回归 | 只对“非内建 Kind + 有方法”生效；先加负例测试 |
| P2 同类型 eq 改动破坏结构体默认比较 | 现有结构体语义变化 | 有 `eq/ne` 才 lowering，否则原路径 |
| P6 顶层 build 改动破坏 std 架构文件 | std 包编译失败 | 根包移除 preFilter，非根包保留；先跑 `test/stringUtils` |
| P6 pending build 误挂声明 | 平台代码被错误编译 | 严格“紧随声明”消费；隔其他声明即丢弃并记录 |
| P3 浮点转换 ABI 错误 | 运行结果错误/崩溃 | x86_64 先行；x86 不支持项显式报错 |
| P8 switch 重构改变 case 顺序 | 现有 switch 行为变化 | 先补 switch 回归，再重构；default 按源码顺序 |
| P4 收窄导致 intrinsic 断链 | string `==` 等失效 | `IntrinsicPkgs` 只服务 lowering；加无 import 的 intrinsic 正例 |

回滚策略：每个阶段独立提交，出问题按提交粒度回滚；不跨阶段混提交。
