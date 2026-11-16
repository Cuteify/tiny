# Cuteify 接口流程图（Go → 自举）

> **状态：持续** · 当前迭代：Go 端接口落地完毕（2026-11-14）→ 自举端接口按 Go 参考形态迁移
> 本文：**cuteify 中接口是怎么用 Go 实现的**，之后 selfhost 怎样照形态重演。
> 关联：`docs/LANGUAGE.md §7, §15.1`、`docs/SELFHOST_PARSER.md`（自举 S4）。

## 1. 目标

- Cuteify 的接口（interface）在**运行期带 vtable**、可**赋值**、可**动态派发**。
- 实现路径：**Go 编译器**完整落地接口 →
  selfhost parser 以 Go 参考 1:1 重演 →
  selfhost codegen 用同形 vtable + boxing 机制。

## 2. 分类与语义

Interface 是 **boxed value**：运行期是 `{vtable_ptr, data_ptr}`，2 个指针槽。

| 项 | 说明 |
|---|---|
| 声明 | `type I interface { m() X }` 与裸 `interface I { m() X }`；嵌入接口 **暂不支持** |
| 方法 | 参数列表 `name: Type`；返回类型只能单个 `NAME`，多返回不解析；接口方法本身不写 receiver（接口语义） |
| 赋值 | 具体类型 → 接口值：`var s: I = d`；需要 `AutoType` 走 interface 分支，`ImplementsInterface` 按方法名匹配 |
| 动态派发 | vtable 调用：`[vtable+index*8] = concrete.MangledName`；`boxInterface` 生成 `.data` 段；`ThisVar.Type = *InterfaceType` 走 interface dispatch |
| error 接口 | 仍以 Go 参考形态存在；`e == nil` 判等已回退为普通比较 |

## 3. 实现状态（截至 2026-11-14）

### 3.1 Go 编译器（`parser/`、`type/`、`pkg/`、`compile/`）

| 动作 | 状态 | 位置 |
|---|---|---|
| 接口声明 parse | ✅ | `parser/interface.go` |
| TypeBlock.Kind == TypeInterface → typeSys.InterfaceType（`{vtable_ptr, data_ptr}`、带 `InterfaceMethods []InterfaceMethodDef`） | ✅ | `parser/type.go` |
| `ImplementsInterface(concreteType)` — 支持指针形态剥一层 | ✅ | `type/type.go` |
| `Kind()` 自带返回 `"interface"`（嵌入屏蔽 RType.Kind） | ✅ | `type/type.go` |
| `AutoType` 接口分支 + 裸值→iface | ✅ | `type/type.go` |
| vtable section 生成（`{type_info, m0, m1, ...}`） | ✅ | `compile/vtable.go`、`context.go` |
| `boxInterface`（call-site boxing） | ✅ | `compile/exp/exp.go:5755+` |
| `interfaceDispatch`（call-site indirect call） | ✅ | `compile/arch/x86_64/linux_sysv.go:556+` |
| `markIfaceMethods`（vtable 保活 GC） | ✅ | `compile/compiler.go:127+` |
| 接口 `Kind() = "interface"` 出，`AutoType` 接口分支到达 | ✅ | `type/type.go` |
| 实测：`var s: I = d` / `d.stringify()` / `*Dog` 接收者 / `IfaceMethod()→Point(40B)` | ✅ | `test/iface_*`、`test/ifaceTest` |
| 可打印 "dog"、`s.stringify()`、`s.greet("...")` | ✅ | `/tmp/iface_suite 01..06` |

### 3.2 已知限制（本阶段登记）

| 项 | 状态 | 说明 |
|---|---|---|
| 接口嵌入 `interface A { ... }` 中嵌 `interface B { ... }` | ❌ | follow-up 未纳入本阶段 |
| 接口方法多返回值 | ❌ | `parseMethod` 只取单个 NAME 返回 |
| 接口方法参数/返回结构化（`[]T`、`[N]T`、多返回） | ❌ | 未支持，同上 |
| 接口嵌入具名 receiver 形式 `(self T) fn` 的 `interface Self` | ❌ 已废弃 | 确立为“接收者 `self` / `&self` 关键字 + 方法名前缀推断” |
| 大结构体（>8B）值语义 | ❌ | `LANGUAGE.md §15` 登记 |
| `error == nil` 比较 | 🟡 | 走普通指针比较 |

## 4. 端到端测试样本（本仓库）

```
# Go 全量矩阵
flock /tmp/opencode/lock /tmp/opencode/bin/w15 selfhost_parse.sh x86_64     # parse 对拍
flock /tmp/opencode/lock /tmp/opencode/bin/w15 selfhost_test.sh x86_64       # S0 lexer 验证
```

样例：
```cuteify
type Stringer interface {
    stringify() string
}
type Dog struct { name: string }
fn Dog.stringify(&self) string { ret "dog" }
fn main() int {
    var s: Stringer = Dog{name: "d"}
    var r: string = s.stringify()
    ret len(r)    // rc=3
}
```

返回值、参数、字符串、长度、大结构体均已打通。

## 5. 端到端自举（S4）流程

自举 parser 依据 Go 参考全盘重写，接口相关点逐条对照：

1. **Lexer token**（已完成，`SELFHOST_OK`）：`KEYWORD`（fn/type/var/import/build/if/else/for/switch/ret/return/break/continue/...）、`DELIMITER`、`NAME`、`NUMBER`、`STRING`、`NONE`。
2. **Parser**（`selfhost/parse/parse.cute` 正在实现）：按 Go 参考 `parser/*.go` 逐个文件复写。
3. **Block 接口**：`Node{Value Block, Father *Node, Children []*Node}` 同 Go reference。`Block` 为 selfhost 接口。
4. **接口相关 Block**：`FuncBlock`/`TypeBlock`/`InterfaceDef`——对应 Go 侧语法 element。
5. **Check**：最小可用（结构/类型形状登记、`Useful` 入、`*InterfaceType` 入）。
6. **Codegen**：待落地（M+1）。

## 6. 阶段里程碑

| 阶段 | 验收 |
|---|---|
| M0 `Block interface` & token & `file()` 主循环 | 能编译；空语料/字串闭合通过；`.cute` 文件可 parse |
| M1 顶层 decl（fn/type/var/const/struct/enum） | `.cute` 文件全覆盖 PARSE_OK |
| M2 语句/表达式 + 接口赋值（boxing） | `_ = s.stringify()` 镜像测试 parity |
| M3 AST 对拍（`PARITY_OK`） + 进程化 selfhost bench | `SELFHOST_OK` |
| M4 完整类型推导 + 接口方法 sanity checks | 进程化 test suite len ≥ 40 |

## 7. 新 parser 与接口相关的测试矩阵（计划）

```
test/iface_decl                 // type I interface{ m() int }
test/iface_dispatch             // s.m() via vtable
test/iface_value                // s := Dog{}; var i I = s; i.m()
test/iface_method_large_ret     // v := i.makePoint(); return v.field  // ret Large Struct
test/iface_method_arg           // s.greet("world")
test/iface_method_no_arg        // s.m()
test/iface_method_multi         // i.m() + i.n()
test/iface_pointer_receiver     // *Dog as interface receiver (deref 隐式)
test/iface_global_var           // var s I = ...   gloable iface
```
