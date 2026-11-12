# Cute 标准库现状

> 适用源码：`pkg/`（58 个非测试包、22 个测试目录）。
> 历史审计基线：`HEAD=d4aa03a`，审计用 detached worktree
> `/tmp/opencode/stdlib-audit`，审计编译器 `/tmp/opencode/stdlib-audit-bin`。
>
> **现状更新（2026-11-06，Batch 1–2 后）**：Batch 2 分组提交为 `e0dedb8`
> （compile）、`cb5372e`（type）、`759f9c2`/`bccf4e8`（parser）、`c4edbf1`（stdlib）。
> x64 测试矩阵 **22/22 全绿**
> （`slices=230`，其余 `=42`）；x64 源码探针 **58/58 OK**；x86 矩阵 8 绿
> （`bytes/math/bits/os/strings/unicode/unicode/utf8` + `slices=230`），
> `io=8`、`math=10`、`time=1`，`path` 因 x86 大值多返回值未实现而 NASM_FAIL；
> x86 源码探针 1/58（与基线一致，后端红面归 Batch 4）。
> 语言面已支持进制/字符字面量、f64 位模式常量、`*T → *ptr`、包限定类型、
> 多返回值声明 `a, b := f()`；仍未支持完整 f64 算术/XMM、多返回值赋值
> `a, b = f()`、x86 大值多返回值。本文 §0–§5 保留 `d4aa03a` 的历史审计快照，
> 其中的 P0/P1 缺口与矩阵数字**不再代表当前状态**；当前事实以本段和
> `docs/stdplan/PROGRESS.md` 的 Batch 1/2 收口段为准。
>
> 本文只写**当前实测结果**，不写目标设计。“能编译”不等于“能用”，
> “测试通过”也不等于“语义正确”——两类反例在 §5 都有记录。
>
> 一句话结论：标准库不是整体不可用，而是**核心可用、外围被语言能力卡住、
> 少数包自身有 bug 或仍是存根**。不能笼统说“标准库不可用”。

---

## 0. 先看结论

### 0.1 三层分化

1. **核心可用**：`strings`、`slices`、`unicode`、`container/heap`、
   `container/list`、`console`、`log` 等在 x86_64 上有可稳定复跑的通测试
   （其中 `console`/`container/heap`/`container/list`/`log`/`unicode`
   需补显式 `import "std:strings"`，见 §3.2）；`uuid` 原生 x64 测试绿。
2. **被语言/编译器能力卡住**：27 个 x64 源码探针失败包中，20 个不是包写得差，
   而是缺十六进制字面量、结构体复合字面量、`*Struct` → `ptr` 赋值、多返回值签名等；
   另有 7 个是包源码自身的注释位置或命名问题，改几行即可。
3. **包自身 bug 或存根**：`mime` 两处死循环、`html` 跨作用域变量、
   `strings.eq` 是身份比较而不是内容比较；`bzip2`/`gif`/`jpeg`/`png`/`math/big`
   等是明确标注的存根。

### 0.2 数字总览

| 项目 | 数值 | 口径 |
|---|---:|---|
| 非测试包 | 58 | `pkg/` 下不含 `test` 的目录 |
| 非测试 `.cute` 文件 | 89 | 不含 `pkg/**/test/main.cute` |
| 非测试代码行 | 17,149 | `wc -l` 求和 |
| `fn` 声明 | 879 | 含 `x86` / `x86_64` 双架构重复定义 |
| 测试目录 | 22 | `find pkg -type d -name test` |
| 全部 `.cute` 文件 | 111 | 89 + 22 个测试 |
| x64 源码级探针 | 31 OK / 27 FAIL | 只验证解析、类型检查、可达代码生成 |
| x86 源码级探针 | 1 OK / 57 FAIL | 其中 30 个是编译器 nil-Type panic，不能当包质量统计 |
| x64 测试通过 | 8 / 22 | 原生 3 + 补显式 import 后 5 |
| x86 测试通过 | 3 / 22 | 原生 2 + 补显式 import 后 1 |

### 0.3 可用性分级

| 级别 | 判据 | 包 |
|---|---|---|
| A 双架构测试绿 | x64/x86 均按约定 rc 通过 | `strings`、`slices`；`unicode`（补显式 `import "std:strings"` 后） |
| B x64 测试绿、x86 未过 | x64 按约定 rc 通过，x86 编译/NASM 红 | `uuid`（x64 原生）、`console`、`container/heap`、`container/list`、`log`（后四者需补 import） |
| C x64 可运行但有明确失败 | 根因已定位到具体 API 或编译器行为 | `io`（x64 仅 `eq` 失配；x86 另有 8 项真实失败）、`time`（大整数字面量实参截断） |
| D 包源码 bug | 双架构红，且根因在包实现 | `mime`（死循环）、`html`（`_p33` 跨 else-if 作用域） |
| E 语言/编译器阻塞 | x64 源码探针失败，首个错误在语言能力 | 20 个包，见 §5.1 |
| F 存根/占位 | 可编译或不可编译，但功能明确未实现 | `compress/bzip2`、`image/gif`、`image/jpeg`、`image/png`、`math/big`、`runtime/debug`、`encoding/asn1`（部分）、`hash`（接口壳）、`memory/gc`（仅 RC 三函数） |

该分级只看测试执行结果和已定位的阻塞点，**不评价语义正确性**：
`strings` 虽列在 A，但 `eq/ne` 仍是最危险的身份比较 bug（§5.5、P0）。

---

## 1. 口径与复现

### 1.1 审计基线

| 项 | 值 |
|---|---|
| 仓库 | `/home/gx/Desktop/代码/tiny` |
| 基线提交 | `d4aa03a docs: 新增 GC 与内存管理总览` |
| 审计 worktree | `/tmp/opencode/stdlib-audit`（`git worktree add --detach`） |
| 审计二进制 | `/tmp/opencode/stdlib-audit-bin`（仓库根 `go build`） |
| 架构 | `CUTE_ARCH=x86_64` / `CUTE_ARCH=x86` |
| 标准库根 | `CUTE_ROOT=/tmp/opencode/stdlib-audit` |
| 链接 | x64：`nasm -f elf64` + `gcc -nostartfiles -no-pie`；x86：`nasm -f elf32` + `gcc -m32 -nostartfiles -no-pie` |

### 1.2 三类探针

**（1）源码级编译探针**

对每个非测试包生成一个最小目录：

```cute
import "std:<pkg>"
fn main() int {
    ret 0
}
```

只调用编译器 `-S`，不经过 NASM、链接和运行。它验证的是：

- 包头文件能被解析；
- 包内所有文件能通过类型检查；
- 可达函数的代码生成不会 panic。

它**不验证**任何 API 的运行时行为。因此“31/58 OK”只能说明这 31 个包
在 x64 上“源码可编译”，不能说明它们“功能可用”。

**（2）包级测试矩阵**

对 22 个 `pkg/**/test` 逐目录执行：

```
编译 → NASM → 链接 → 运行（timeout 20s）→ 取 rc
```

每组跑三遍，rc 三连一致才算稳定。原始结果见
`/tmp/opencode/audit_x64.txt` 与 `/tmp/opencode/audit_x86.txt`。

**（3）定点功能探针**

对可疑语义单独写最小目录验证，例如：

- `strings.eq("ab","ab")` vs `strings.eq(view(...), "ab")`；
- `time.durationString(u64变量)` vs `time.durationString(大整数字面量)`；
- 把 `pkg/io/test`、`pkg/time/test` 里的 `strings.eq` 全部替换为
  `strings.compare(...) != 0` 后复跑。

这类探针用于区分“包实现错误”和“测试/编译器错误”，结论写在 §5.5。

### 1.3 测试通过判据

| 测试 | 通过 rc | 说明 |
|---|---:|---|
| 多数包 | `42` | `failures == 0` 时返回 42 |
| `pkg/slices/test` | `230` | `pass * 10 + fail`，230 = 23 pass × 10 + 0 fail |
| `pkg/io/test` | `42` | 失败计数为 0 时返回 42，否则返回失败数 |
| `pkg/time/test` | `42` | 同上 |
| `pkg/mime/test` | `42` | 实测 x64 超时 rc=124 |
| `pkg/sort/test` | `42` | 实测补 import 后 rc=1，属陈旧测试 |

`COMPILE_FAIL`、`NASM_FAIL`、`RC=<非期望值>`、`RC=124`（超时）都按红处理。

### 1.4 这些结论不覆盖什么

1. **x86 源码探针不能用于包质量统计**：57 个 FAIL 中 30 个是
   `compile/arch/x86/cdecl.go:120` 的 nil-Type panic，和包源码无关。
2. **x64 源码探针 OK 不等于 API 正确**：它没有调用任何函数。
3. **测试绿不等于语义正确**：`strings` 测试 42，但没有覆盖 `eq` 对
   构造字符串的行为；`strings.eq` 的内容比较 bug 因此长期未被捕获。
4. **未做性能、并发、内存占用和长稳测试**；本文只谈可编译性、测试 rc 和
   已确认的功能语义。

---

## 2. 分层与规模

### 2.1 分层小计

| 层 | 包数 | 文件 | 行 | fn | 说明 |
|---|---:|---:|---:|---:|---|
| 基础/运行时 | 7 | 21 | 2,066 | 138 | `builtin`、`memory`、`memory/gc`、`runtime`、`runtime/debug`、`syscall`、`thread` |
| 容器 | 6 | 14 | 4,009 | 176 | `slices`、`maps`、`sort`、`container/heap`、`container/list`、`container/ring` |
| 字符串/文本 | 6 | 9 | 3,390 | 131 | `strings`、`unicode`、`unicode/utf8`、`html`、`text/template`、`text/tabwriter` |
| I/O/OS | 12 | 18 | 3,897 | 231 | `io`、`bytes`、`fs`、`path`、`os`、`os/signal`、`flag`、`fmt`、`log`、`console`、`mime`、`time` |
| 压缩/编码/哈希 | 18 | 18 | 2,482 | 70 | `archive/*`、`compress/*`、`encoding/*`、`hash/*`、`index/suffixarray`、`uuid` |
| 数学/图像 | 8 | 8 | 967 | 115 | `math`、`math/big`、`math/bits`、`image`、`image/*` |
| 测试 | 1 | 1 | 338 | 18 | `testing` |
| **合计** | **58** | **89** | **17,149** | **879** | |

### 2.2 规模最大的包

| 包 | 行 | fn | 备注 |
|---|---:|---:|---|
| `strings` | 2,693 | 112 | 4 个文件，common + 双 arch；标准库最大包 |
| `sort` | 2,079 | 86 | 快排/插入/TimSort + 裸阵列 API；测试陈旧 |
| `memory` | 1,356 | 73 | 分配器 + RC + 泄漏追踪 |
| `slices` | 983 | 58 | Go 风格动态数组；测试 230 |
| `console` | 920 | 92 | ANSI 颜色/光标/输入 |
| `time` | 891 | 47 | 日历换算 + IANA tzdata |
| `path` | 849 | 23 | `base/dir/ext/join/clean/glob/walk` |
| `maps` | 667 | 14 | 开放寻址 + tombstone，仅依赖 `memory` |

---

## 3. 导入机制与缺陷⑪

### 3.1 文件级 `import` 是唯一依赖通道

Wave I 之后，`pkg/**/package.json` 的 `imports` 字段已全部迁移并停用。
全库统计：

```text
grep -rl '"imports"' pkg --include=package.json | wc -l
0
```

依赖声明只写在 `.cute` 文件顶层：

```cute
import "std:strings"
import "std:memory"
```

解析器支持五种形态（`package/imports.go`）：

| 形态 | 含义 |
|---|---|
| `std:xxx` | 官方标准库，映射 `<root>/pkg/xxx` |
| `ext:xxx` / `api:xxx` | 标准库扩展 / 其他语言 API 绑定，当前同样映射 `<root>/pkg/xxx` |
| `<根包名>:rel` | 项目顶层相对路径 |
| `:third/party` | 第三方，`vendor/` 优先 |
| `./rel`、`../rel`、`/abs` | 本地路径 |

`CUTE_ROOT` 显式设置时是权威根；未设置才走“编译器可执行目录及其上级 →
当前工作目录”的兜底。审计时一律显式设置，避免解析到别的树。

### 3.2 缺陷⑪：间接依赖的 arch/common 不对等

**症状**：测试只 `import "std:console"`，而 `console` 内部 `import "std:strings"`。
构建时 `strings` 的**架构文件**（`strings_x86_64.cute` / `strings_x86.cute`）
被连带拉入，**common 文件**（`strings_common.cute`）的定义却没有全部进入符号表：

- x64：NASM 报 `symbol 'std_strings_count' not defined`；
- x86：编译期走 `BindDanglingCall` 兜底补绑，签名面不齐，
  `compile/arch/x86/cdecl.go:120` 对 `arg.Type` 取 `Size()` 时 nil deref panic。

**根因**：包加载器的间接连带加载不对等——根包没有显式 import 某包时，
该包的 arch 文件函数被拉入，但 common 定义缺席。属编译器缺陷，未修。

**影响面**：22 个测试中 10 个没有显式 `import "std:strings"`：

```text
console, container/heap, container/list, hash/crc32, log,
math/bits, math, sort, unicode, unicode/utf8
```

其中 6 个在 x64 上确定触发缺陷⑪（均以 `std_strings_count` 未定义的形式暴露）：

| 测试 | 依赖链 | x64 症状 | x86 症状 |
|---|---|---|---|
| `console` | `console` → `strings` | NASM `std_strings_count` | 编译 panic；补 import 后转 NASM `operation size not specified` |
| `container/heap` | `heap` → `strings` | NASM `std_strings_count` | 编译 panic（nil Type） |
| `container/list` | `list` → `strings` | NASM `std_strings_count` | 编译 panic（nil Type） |
| `log` | `log` → `strings` | NASM `std_strings_count` | 编译 panic；补 import 后转 NASM `operation size not specified` |
| `sort` | `sort` → `strings` | NASM `std_strings_count` | 编译 panic；补 import 后转 NASM `operation size not specified` |
| `unicode` | `unicode` → `strings` | NASM `std_strings_count` | 编译 panic；补 import 后 42 |

另外 4 个（`crc32`、`math`、`math/bits`、`unicode/utf8`）也缺 import，
但在类型检查阶段就因别的原因失败，尚未走到缺陷⑪的链接阶段。

**绕行**：在测试文件顶层补一行显式依赖：

```cute
import "std:strings"
```

补完后：

- x64：`console=42`、`container/heap=42`、`container/list=42`、`log=42`、
  `unicode=42`；`sort=1`（见 §5.4 陈旧测试）。
- x86：`unicode=42`；`console`/`log`/`sort` 转入 NASM
  `operation size not specified`；`heap`/`list` 仍编译 panic。

结论：**缺陷⑪是加载器问题，不是这些包的功能问题**。补 import 是当前唯一
可靠的工程绕行，不能把“补 import 后能跑”误写成“包本身没依赖”。

### 3.3 架构分片与 fn 计数

包内常见分片方式：

```cute
build os("linux")
build arch("x86_64")
```

或：

```cute
build arch("x86")
```

`fn` 统计会把 `strings_x86.cute` 与 `strings_x86_64.cute` 中同名函数各算一次，
所以 879 不是“唯一 API 数”。看 API 规模时应以 common 文件为准；
本文所有 fn 数都标注了“含双架构重复”。

---

## 4. 双架构测试矩阵

### 4.1 x86_64

原始结果（不补 import）：

- **通过 3 个**：`strings=42`、`slices=230`、`uuid=42`。
- **可运行但失败 2 个**：`io=4`（4 项失败）、`time=3`（3 项失败）。
- **超时 1 个**：`mime=124`。
- **NASM 失败 6 个**：`console`、`container/heap`、`container/list`、
  `log`、`sort`、`unicode`（全部是缺陷⑪）。
- **编译失败 10 个**：`bytes`、`compress/flate`、`flag`、`hash/crc32`、
  `html`、`math/bits`、`math`、`os`、`path`、`unicode/utf8`。

补显式 import 后，`console`、`container/heap`、`container/list`、`log`、
`unicode` 均变为 `42`；`sort` 变为 `1`（陈旧测试，见 §5.4）。
因此 x64 最终 **8 个通过**。

### 4.2 x86

原始结果：

- **通过 2 个**：`strings=42`、`slices=230`。
- **可运行但失败 2 个**：`io=12`、`time=3`。
- **编译失败 18 个**，分两类：
  - 9 个在包加载/类型检查阶段返回源码错误：`bytes`、`compress/flate`、
    `flag`、`hash/crc32`、`math/bits`、`math`、`os`、`path`、`unicode/utf8`；
  - 9 个在代码生成阶段空指针 panic（调用栈顶均为 x86 `Cdecl.Call`）：
    `console`、`container/heap`、`container/list`、`html`、`log`、`mime`、
    `sort`、`unicode`、`uuid`。

补显式 import 后：

- `unicode=42`，x86 最终 **3 个通过**；
- `console`/`log`/`sort` 从“编译 panic”转为 NASM
  `operation size not specified`；
- `container/heap`/`container/list` 仍编译 panic。

x86 的 30 个源码探针 panic 全部指向
`compile/arch/x86/cdecl.go:120`（`arg.Type.Size()`，`arg.Type == nil`），
是 x86 后端的共性缺陷，不是逐包问题。

### 4.3 22 项矩阵总表

| 测试目录 | x64 原始 | x64 补 import | x86 原始 | x86 补 import | 根因 |
|---|---|---|---|---|---|
| `pkg/bytes/test` | COMPILE_FAIL | 同左 | COMPILE_FAIL | 同左 | `*Buffer` → `ptr` 赋值 |
| `pkg/compress/flate/test` | COMPILE_FAIL | 同左 | COMPILE_FAIL | 同左 | `*Reader` → `ptr` 赋值 |
| `pkg/console/test` | NASM_FAIL | **42** | COMPILE_FAIL（panic） | NASM_FAIL | 缺陷⑪ / x86 后端 |
| `pkg/container/heap/test` | NASM_FAIL | **42** | COMPILE_FAIL（panic） | COMPILE_FAIL（panic） | 缺陷⑪ / x86 nil Type |
| `pkg/container/list/test` | NASM_FAIL | **42** | COMPILE_FAIL（panic） | COMPILE_FAIL（panic） | 缺陷⑪ / x86 nil Type |
| `pkg/flag/test` | COMPILE_FAIL | 同左 | COMPILE_FAIL | 同左 | 调用实参内 `//` 注释 |
| `pkg/hash/crc32/test` | COMPILE_FAIL | 同左 | COMPILE_FAIL | 同左 | 十六进制字面量 |
| `pkg/html/test` | COMPILE_FAIL（panic） | 同左 | COMPILE_FAIL（panic） | 同左 | `_p33` 跨作用域 |
| `pkg/io/test` | **4** | 4 | **12** | 12 | `eq` 语义 + x86 运行时差异 |
| `pkg/log/test` | NASM_FAIL | **42** | COMPILE_FAIL（panic） | NASM_FAIL | 缺陷⑪ / x86 后端 |
| `pkg/math/bits/test` | COMPILE_FAIL | 同左 | COMPILE_FAIL | 同左 | 泛型 `T` 算术 |
| `pkg/math/test` | COMPILE_FAIL | 同左 | COMPILE_FAIL | 同左 | 科学计数法 |
| `pkg/mime/test` | **124（超时）** | 124 | COMPILE_FAIL（panic） | COMPILE_FAIL（panic） | 包内死循环 |
| `pkg/os/test` | COMPILE_FAIL | 同左 | COMPILE_FAIL | 同左 | 形参名 `ret` |
| `pkg/path/test` | COMPILE_FAIL | 同左 | COMPILE_FAIL | 同左 | 调用实参内 `//` 注释 |
| `pkg/slices/test` | **230** | 230 | **230** | 230 | 双架构绿 |
| `pkg/sort/test` | NASM_FAIL | **1**（陈旧） | COMPILE_FAIL（panic） | NASM_FAIL | 缺陷⑪ + 已删除 API |
| `pkg/strings/test` | **42** | 42 | **42** | 42 | 双架构绿；未覆盖 `eq` |
| `pkg/time/test` | **3** | 3 | **3** | 3 | 大整数字面量实参截断 |
| `pkg/unicode/test` | NASM_FAIL | **42** | COMPILE_FAIL（panic） | **42** | 缺陷⑪ |
| `pkg/unicode/utf8/test` | COMPILE_FAIL | 同左 | COMPILE_FAIL | 同左 | 多返回值签名 |
| `pkg/uuid/test` | **42** | 42 | COMPILE_FAIL（panic） | COMPILE_FAIL（panic） | x64 绿；x86 编译器 panic |

加粗表示“通过约定 rc”；“补 import”只加 `import "std:strings"`，不改测试逻辑。

### 4.4 三个特殊测试的语义

**`pkg/io/test`**

- 共 6 组检查，其中 4 组用 `strings.eq` 做内容比较（第 2/3/4/5 组）。
- x64 原始 rc=4，正好对应这 4 组；把 `strings.eq` 换成
  `strings.compare(...) != 0` 后 **rc=42**。说明 x64 的 `io` 实现
  没有暴露出这 4 项错误，失败来自 `eq` 的语义。
- x86 原始 rc=12；同样替换后 **rc=8**。剩余 8 项是真实的 x86 运行时差异
  （字节级读取、`LimitReader` 等），尚未进一步区分是 `io` 实现还是
  x86 代码生成。

**`pkg/time/test`**

- 共 10 组检查；第 8/9/10 组比较 `durationString` 的结果。
- 原始 rc=3；把 `eq` 换成 `compare` 后 x64 **rc=2**、x86 **rc=1**。
- 直接用 `u64` 变量调用时，`durationString` 是正确的：

  ```text
  3600000000000 → "1h"
  61000000000   → "1m1s"
  3661000000000 → "1h1m1s"
  ```

- 失败来自把大整数字面量**直接作为调用实参**：`3600000000000` 被截成
  `817405952`，`61000000000` 被截成 `870457856`；先赋给已声明的 `u64`
  变量再传则值正确。属编译器实参宽度/截断缺陷，不是 `durationString` 逻辑错。

**`pkg/mime/test`**

- x64 rc=124（20s 超时），不是普通断言失败。
- `pkg/mime/mime.cute:172-175` 与 `:226-233` 两处循环里的指针只算一次，
  循环体只递增长度/拷贝位置，不更新指针，条件永远为真。
- 因此 `typeByExtension` 和 `Extensions` 都会挂死；x86 侧先被编译器 panic 挡住。

---

## 5. 失败分类

### 5.1 语言/编译器能力缺口（20 个包）

| 能力 | 首个错误 | 影响包 |
|---|---|---|
| 十六进制字面量 `0x...` | `Syntax Error: name contains invalid characters` | `archive/zip`、`hash/adler32`、`hash/crc32`、`hash/crc64`、`hash/maphash` |
| 科学计数法 `1.79e+308` | 同上 | `math` |
| 字符字面量 `'0'` | `Type Error: operator < not defined for type u8`（`tar.cute:44`） | `archive/tar` |
| 结构体复合字面量 `RGBA{...}` | `Expression Error: expected right operand`（`image/color/color.cute:23`） | `image`、`image/color`、`image/gif`、`image/jpeg`、`image/png`（首个错误在 `image/color`） |
| 结构体指针与 `ptr`/`*ptr` 赋值不兼容 | `Type Error: need type ptr, not Buffer/Reader`（`bytes.cute:34`、`flate.cute:36`） | `bytes`、`compress/bzip2`、`compress/flate`、`compress/gzip`、`compress/zlib` |
| `[]uint32` 类型注解 | `Type Error: type expected` | `math/big` |
| 泛型类型参数 `T` 上的算术 | `Type Error: operator * not defined for type T`（`bits.cute:13` 的 `thresh * 2`，编译器游标报 12:24） | `math/bits` |
| 多返回值签名 `(rune int, size uint)` | `Type Error: type not found`（`utf8.cute:46`） | `unicode/utf8` |

这些是**语言能力缺口**，不是包源码错误。修语言（或提供等价的显式展开写法）
才能解锁；这些包的源码本身没有写错。

### 5.2 包源码错误（改包即可）

| 包 | 位置 | 问题 | 修法 |
|---|---|---|---|
| `mime` | `mime.cute:172-175` | `_p10` 只算一次，`entryExtLen` 递增后不更新指针 | 循环体内重算 `_p10 = entryExtPtr + entryExtLen` |
| `mime` | `mime.cute:226-233` | `_p18` 只算一次，`j` 递增后不更新指针 | 循环体内重算 `_p18 = entryExtPtr + j` |
| `html` | `html.cute:115-117` | `_p33/_p34/_p35` 声明在 `if` 块内，却在 `else if` 条件中使用 | 把声明移到 `if` 之前，或改写成不跨块的形式 |
| `os` | `os.cute:42` | 形参名 `ret` 与关键字冲突 | 改名为 `code`/`rc` |
| `compress/lzw` | 调用实参括号内 | `//` 注释吞掉 `)` | 把注释移到右括号之后，如 `f(47) // '/'` |
| `encoding/ascii85` | 同上 | 同上 | 同上 |
| `flag` | 同上 | 同上 | 同上 |
| `os/signal` | 同上 | 同上 | 同上 |
| `path` | 同上 | 同上 | 同上 |
| `text/tabwriter` | 同上 | 同上 | 同上 |

`html` 的源码作用域错误同时暴露了编译器错误质量：编译器没有报
“变量未声明”，而是在 `compile/arch/x86_64/utils.go:100` 主动 panic
（`GenVarAddr: nil type for var '..._p33'`）。

### 5.3 编译器/后端缺陷

| 缺陷 | 位置 | 影响 |
|---|---|---|
| x86 `arg.Type` 为 nil 时直接 `Size()` | `compile/arch/x86/cdecl.go:120` | 30/57 个 x86 源码探针 panic；9 个 x86 测试在代码生成阶段 panic（栈顶均为 `Cdecl.Call`） |
| x64 变量类型为 nil 时 panic | `compile/arch/x86_64/utils.go:100` | `html` 测试 panic |
| 大整数字面量作调用实参被截断到低 32 位 | 实参宽度/截断逻辑 | `time` 测试第 9/10 组；赋值给 `u64` 变量则正常 |
| 间接依赖 arch/common 不对等（缺陷⑪） | 包加载器 | 6 个测试 x64 NASM 失败、x86 编译 panic |
| 未定义的限定函数调用被静默丢弃 | 调用绑定 | `pkg/sort/test` 的 `isSortedInts`/`searchInts`/`sortInts` 未进 asm，NASM 也不报未定义 |
| x86 NASM `operation size not specified` | x86 代码生成 | 补 import 后的 `console`/`log`/`sort` 测试；属既有红面 |

### 5.4 测试自身缺陷

| 测试 | 问题 | 后果 |
|---|---|---|
| `console`、`container/heap`、`container/list`、`log`、`sort`、`unicode` | 未显式 `import "std:strings"` | x64 上触发缺陷⑪，补一行后该症状消失；x86 另有后端问题 |
| `pkg/sort/test` | 引用已删除的 `sort.isSortedInts`、`sort.searchInts`、`sort.sortInts`（仅存于 `str_sort.cute.bak3`） | 补 import 后可运行但 rc=1；这三个调用被编译器静默丢弃，NASM 也不报未定义；属陈旧测试，不在 22 项 farm 矩阵 |
| `pkg/strings/test` | 只用 `eq` 比较字面量，构造字符串用 `compare` | 未覆盖 `eq` 对构造字符串的行为，导致 §5.5 的 bug 长期未捕获 |
| `pkg/io/test`、`pkg/time/test` | 用 `eq` 做内容比较 | 把 `eq` 的身份比较 bug 混入包自身的失败计数 |

### 5.5 已确认的功能语义问题

#### `strings.eq` 是身份比较，不是内容比较

`pkg/strings/strings_x86_64.cute:29` 与 `strings_x86.cute:31` 的实现只比较两个槽。
其等价逻辑如下（省去编译器生成的 `_pN` 临时指针）：

```cute
// 比较 ptr + len
var x0: uint = s 的 ptr 槽
var y0: uint = t 的 ptr 槽
if x0 != y0 { ret false }
var x1: uint = s 的 len 槽
var y1: uint = t 的 len 槽
if x1 != y1 { ret false }
ret true
```

实测：

```text
strings.eq("ab", "ab")                  -> true   // 同一字面量被去重成同一指针
strings.eq(view(...), "ab")       -> false  // 内容相同，指针不同
strings.eq(构造字符串, 构造字符串)        -> 通常 false
```

因此：

- `pkg/strings/test` 能过 42，是因为它用 `eq` 比较的两侧都是同内容字面量，
  被去重成同一指针；构造字符串一律用 `compare`。
- `pkg/io/test` 的 4 项失败全部由 `eq` 引起；`pkg/time/test` 的 3 项失败
  都经过 `eq`，但其中 2 项同时受大整数字面量截断影响（见 §4.4）。
- 正确的内容比较应使用 `strings.compare(a, b) == 0`。
  `compare` 逐字节比较，实测在 io/time 的替换探针中工作正常。

**这是当前标准库最危险的语义 bug**：它不会让测试变红，只会让业务代码
在“内容相同、指针不同”时静默走错分支。

#### `time.durationString` 逻辑正确，失败在实参截断

见 §4.4。补充证据：把大整数先赋给 `u64` 变量再传，输出完全正确；
直接传字面量则被截断。`time` 包本身不需要改。

#### `mime` 死循环

见 §5.2。两处循环的指针不随索引更新，是包实现 bug；修完后 x64 测试
才有可能从 124 转为正常 rc。

#### `io` x64 通过 `compare` 后为 42

见 §4.4。x64 的 `io` 实现目前没有证据表明有功能错误；x86 仍有 8 项
真实失败，需要继续定位。

### 5.6 存根与占位

| 包 | 状态 | 证据 |
|---|---|---|
| `compress/bzip2` | 解压桩 | `NewReader` 置 `err=1`；`Read` 恒 `ret 0` |
| `image/gif` | 编解码桩 | `Encode` 返回 `""`；`Decode` 返回 `NewRGBA(0,0)` |
| `image/jpeg` | 编解码桩 | 同上 |
| `image/png` | 非真 PNG | 仅输出自定义 `RGBA:w:h:<raw>` 格式 |
| `math/big` | 占位 | 所有算术 `TODO`，`Eq` 恒 `true`、`Cmp` 恒 `0`、`String` 恒 `"0"` |
| `runtime/debug` | 硬编码存根 | `Stack`/`ReadBuildInfo` 返回固定字符串 |
| `runtime` | 简化 | `NumCPU` 恒 1 |
| `encoding/asn1` | 部分实现 | 只有 `marshalInt`、`marshalString`，无 unmarshal |
| `hash` | 接口壳 | 仅 `VERSION` 常量，0 个函数 |
| `memory/gc` | 仅 RC 三函数 | `rcInc`/`rcDec`/`rcGet`，不是完整 GC |
| `time` | 部分 TODO | `since`/`until` 恒返回 0 |
| `fs` | 简化 | `readFile` 固定分配 4096B，不按 `stat` 大小读取 |
| `log` | 最小实现 | 只有 `log`/`logError` |

存根不等于“坏包”：它们提供了可编译的接口形状，但不应按“功能已实现”使用。

---

## 6. API 覆盖

### 6.1 核心包 API 面

| 包 | fn（含双架构重复） | 主要 API | 状态 |
|---|---:|---|---|
| `strings` | 112 | `len/cap/compare/eq/ne/index/contains/hasPrefix/hasSuffix/split/join/replace/trim/toUpper/toLower/parse/toString/builder*` | x64/x86 测试 42；`eq/ne` 语义 bug |
| `slices` | 58 | `push/pop/getPtr/set/len/cap/free` 及泛型特化 | x64/x86 测试 230 |
| `sort` | 86 | `quickSortInts/timsortInts` + 裸阵列族 | 包可编译；测试陈旧 |
| `maps` | 14 | 开放寻址、tombstone、FNV-1a | 无测试；P7 仅依赖 `memory` |
| `console` | 92 | 输出、ANSI 颜色、光标、输入 | x64 补 import 后 42；x86 NASM 红 |
| `io` | 10 | `NewReader/Read/ReadAll/NewWriter/Write/WriteString/String/Copy/LimitReader` | x64 用 `compare` 后 42；x86 8 项红 |
| `time` | 47 | `now/format/parse/durationString/truncate/round/daysIn/tzdata` | 逻辑基本可用；`since/until` TODO |
| `syscall` | 38 | `syscall/syscall6/read/write/open/close/stat/getcwd/...` | x64 源码可编译；x86 探针 panic |
| `thread` | 16 | pthread/futex 封装 | x64 源码可编译 |
| `testing` | 18 | `NewT/Fail/Error/Equal/EqualStr/Passed` | x64 源码可编译 |

### 6.2 没有测试的包

58 个非测试包中只有 22 个有 `test` 目录。以下核心包**没有包级测试**：

```text
memory, memory/gc, runtime, runtime/debug, syscall, thread,
maps, container/ring, text/template, text/tabwriter,
fs, os/signal, fmt, archive/*, compress/*（flate 除外）,
encoding/*, hash/*（crc32 除外）, index/suffixarray,
math/big, image/*, testing
```

其中 `memory`、`syscall`、`thread`、`maps` 属于高风险基础件，
目前主要靠 farm 端到端用例间接触及，建议优先补包级测试。

### 6.3 测试覆盖的盲区

1. `strings.eq` 的构造字符串行为（见 §5.5）。
2. `mime` 的两条死循环路径（测试直接超时，没有断言级定位）。
3. `time` 的大整数字面量实参（测试刚好用了会触发截断的写法，但失败被
   `eq` 掩盖了一部分）。
4. `io` 的 x86 字节级路径。
5. `maps` 的删除/tombstone/扩容边界。
6. `memory` 的 RC 与 `freeSlot` 组合边界（GC 文档有专项，但不在本矩阵）。

---

## 7. 修复优先级

### P0：会静默产生错误结果（✅ Batch 1 已清）

> 前 3 项已在 Batch 1 修复（`strings.eq/ne` 内容比较、`mime` 循环指针重算、
> `html.unescape` 重写）；大整数字面量实参截断由 Batch 2 的字面量扫描与
> i64 定型收口。保留原文作为历史审计记录。

1. **修 `strings.eq`/`ne` 为内容比较**（或明确改名为 `sameIdentity`，
   另提供 `eq` 内容语义）。当前所有用 `eq` 做业务判断的代码都有风险。
2. **修 `mime` 两处死循环**（`mime.cute:172-175`、`:226-233`）。
3. **修大整数字面量作调用实参的截断**（`time` 测试第 9/10 组）。
4. **修 `html` 的 `_p33` 作用域**，并让编译器对未声明变量报错而不是 panic。

### P1：解锁包数量最多的语言能力（✅ Batch 2 已清）

> 十六进制/科学计数法/字符字面量、`*T → *ptr`、多返回值签名、泛型 `T` 算术、
> `uint32` 等宽度别名（`[]uint32` 注解）已在 Batch 2 落地；结构体复合字面量
> 改为 stdlib 源码等价改写（`RGBAModel(...)`），未扩大语言面。下表保留历史审计口径。

按解锁包数排序：

| 能力 | 解锁包数 | 包 |
|---|---:|---|
| 十六进制字面量 | 5 | `archive/zip`、`hash/adler32`、`hash/crc32`、`hash/crc64`、`hash/maphash` |
| 结构体复合字面量 | 5 | `image`、`image/color`、`image/gif`、`image/jpeg`、`image/png` |
| `*Struct` → `ptr` 赋值 | 5 | `bytes`、`compress/bzip2`、`compress/flate`、`compress/gzip`、`compress/zlib` |
| 多返回值签名 | 1 | `unicode/utf8` |
| `[]uint32` 类型注解 | 1 | `math/big` |
| 泛型 `T` 上算术 | 1 | `math/bits` |
| 字符字面量 `'0'` | 1 | `archive/tar` |
| 科学计数法 | 1 | `math` |

前三项合计解锁 15 个包，收益最高。`math/big` 即使解锁类型注解也仍是存根，
优先级可后置。

### P2：测试与加载器（✅ 1–3 已清，4 留 Batch 5）

1. 修缺陷⑪（间接依赖 arch/common 不对等），或至少在 10 个测试里补
   `import "std:strings"`。
2. 修 `pkg/sort/test` 的陈旧 API 引用，或删除/重写该测试。
3. 给 `strings.test` 补 `eq` 对构造字符串的用例。
4. 给 `maps`、`memory`、`syscall`、`thread` 补包级测试。

### P3：x86 后端

1. 修 `compile/arch/x86/cdecl.go:120` 的 nil-Type panic；
   这是 30 个 x86 探针失败的共同根因。
2. 修 x86 NASM `operation size not specified`（`console`/`log`/`sort`）。
3. 定位 `io` x86 剩余的 8 项真实失败。

### P4：存根补齐

按使用频率排：`encoding/asn1` unmarshal、`image/png` 真 PNG、
`compress/bzip2`、`image/gif|jpeg`、`math/big`、`runtime/debug`。

---

## 附录 A：58 包全表

> `fn` 含 x86/x86_64 双架构重复；“x64 探针”是 §1.2 的源码级编译结果，
> 不代表运行时功能。`test=yes` 表示存在 `pkg/**/test` 目录。

| 层 | 包 | 文件 | 行 | fn | test | x64 探针 | 备注 / 首个失败点 |
|---|---|---:|---:|---:|---|---|---|
| 基础/运行时 | `builtin` | 1 | 25 | 3 | — | OK | — |
| 基础/运行时 | `memory` | 10 | 1356 | 73 | — | OK | — |
| 基础/运行时 | `memory/gc` | 1 | 38 | 3 | — | OK | 仅 `rcInc/rcDec/rcGet`，不是完整 GC |
| 基础/运行时 | `runtime` | 1 | 19 | 3 | — | OK | `NumCPU` 恒 1 |
| 基础/运行时 | `runtime/debug` | 1 | 13 | 2 | — | OK | 硬编码存根 |
| 基础/运行时 | `syscall` | 2 | 287 | 38 | — | OK | — |
| 基础/运行时 | `thread` | 5 | 328 | 16 | — | OK | — |
| 容器 | `slices` | 5 | 983 | 58 | yes | OK | x64/x86 测试 230 |
| 容器 | `maps` | 1 | 667 | 14 | — | OK | 无包级测试 |
| 容器 | `sort` | 5 | 2079 | 86 | yes | OK | x64 测试陈旧（rc=1） |
| 容器 | `container/heap` | 1 | 132 | 7 | yes | OK | x64 补 import 后 42；x86 panic |
| 容器 | `container/list` | 1 | 85 | 7 | yes | OK | x64 补 import 后 42；x86 panic |
| 容器 | `container/ring` | 1 | 63 | 4 | — | OK | 无包级测试 |
| 字符串/文本 | `strings` | 4 | 2693 | 112 | yes | OK | x64/x86 测试 42；`eq` 为身份比较 |
| 字符串/文本 | `unicode` | 1 | 64 | 7 | yes | OK | 补显式 import 后 x64/x86 测试 42 |
| 字符串/文本 | `unicode/utf8` | 1 | 178 | 4 | yes | FAIL | 多返回值签名不支持 |
| 字符串/文本 | `html` | 1 | 223 | 3 | yes | OK | x64 测试 panic：`_p33` 跨 else-if 作用域 |
| 字符串/文本 | `text/template` | 1 | 111 | 2 | — | OK | — |
| 字符串/文本 | `text/tabwriter` | 1 | 121 | 3 | — | FAIL | 调用实参内 `//` 注释 |
| I/O/OS | `io` | 1 | 170 | 10 | yes | OK | x64 4 项均为 `eq`；改 `compare` 后 42；x86 仍 8 项 |
| I/O/OS | `bytes` | 1 | 134 | 8 | yes | FAIL | `*Buffer` → `ptr` 赋值 |
| I/O/OS | `fs` | 1 | 101 | 13 | — | OK | `readFile` 固定 4096B |
| I/O/OS | `path` | 1 | 849 | 23 | yes | FAIL | 调用实参内 `//` 注释 |
| I/O/OS | `os` | 1 | 64 | 6 | yes | FAIL | 形参名 `ret` 与关键字冲突（`os.cute:42`） |
| I/O/OS | `os/signal` | 1 | 188 | 7 | — | FAIL | 调用实参内 `//` 注释 |
| I/O/OS | `flag` | 1 | 217 | 13 | yes | FAIL | 调用实参内 `//` 注释 |
| I/O/OS | `fmt` | 1 | 100 | 6 | — | OK | — |
| I/O/OS | `log` | 1 | 19 | 2 | yes | OK | x64 补 import 后 42；x86 NASM 红 |
| I/O/OS | `console` | 4 | 920 | 92 | yes | OK | x64 补 import 后 42；x86 NASM 红 |
| I/O/OS | `mime` | 1 | 244 | 4 | yes | OK | `typeByExtension`/`Extensions` 死循环；x64 124 |
| I/O/OS | `time` | 4 | 891 | 47 | yes | OK | `since/until` TODO；大整数字面量实参截断 |
| 压缩/编码/哈希 | `archive/tar` | 1 | 209 | 5 | — | FAIL | 字符字面量 `'0'` 不支持 |
| 压缩/编码/哈希 | `archive/zip` | 1 | 235 | 7 | — | FAIL | 十六进制字面量不支持 |
| 压缩/编码/哈希 | `compress/bzip2` | 1 | 45 | 3 | — | FAIL | 解压桩；`*Reader` → `ptr` 赋值 |
| 压缩/编码/哈希 | `compress/flate` | 1 | 241 | 6 | yes | FAIL | `*Reader` → `ptr` 赋值 |
| 压缩/编码/哈希 | `compress/gzip` | 1 | 183 | 6 | — | FAIL | `*Reader` → `ptr` 赋值（flate 首个错误） |
| 压缩/编码/哈希 | `compress/lzw` | 1 | 278 | 5 | — | FAIL | 调用实参内 `//` 注释 |
| 压缩/编码/哈希 | `compress/zlib` | 1 | 124 | 6 | — | FAIL | `*Reader` → `ptr` 赋值（flate 首个错误） |
| 压缩/编码/哈希 | `encoding/ascii85` | 1 | 185 | 2 | — | FAIL | 调用实参内 `//` 注释 |
| 压缩/编码/哈希 | `encoding/asn1` | 1 | 174 | 2 | — | OK | 仅两个 marshal，无 unmarshal |
| 压缩/编码/哈希 | `encoding/quotedprintable` | 1 | 141 | 5 | — | OK | — |
| 压缩/编码/哈希 | `hash` | 1 | 7 | 0 | — | OK | 仅 `VERSION` 常量，0 个函数 |
| 压缩/编码/哈希 | `hash/adler32` | 1 | 43 | 2 | — | FAIL | 十六进制字面量不支持 |
| 压缩/编码/哈希 | `hash/crc32` | 1 | 91 | 4 | yes | FAIL | 十六进制字面量不支持 |
| 压缩/编码/哈希 | `hash/crc64` | 1 | 116 | 4 | — | FAIL | 十六进制字面量不支持 |
| 压缩/编码/哈希 | `hash/fnv` | 1 | 87 | 4 | — | OK | — |
| 压缩/编码/哈希 | `hash/maphash` | 1 | 34 | 1 | — | FAIL | 十六进制字面量不支持 |
| 压缩/编码/哈希 | `index/suffixarray` | 1 | 170 | 5 | — | OK | — |
| 压缩/编码/哈希 | `uuid` | 1 | 119 | 3 | yes | OK | x64 42；x86 编译器 panic |
| 数学/图像 | `math` | 1 | 357 | 57 | yes | FAIL | 科学计数法不支持 |
| 数学/图像 | `math/big` | 1 | 124 | 14 | — | FAIL | `[]uint32` 类型注解不支持；占位实现 |
| 数学/图像 | `math/bits` | 1 | 201 | 28 | yes | FAIL | 泛型 `T` 上的算术不支持 |
| 数学/图像 | `image` | 1 | 99 | 9 | — | FAIL | 结构体复合字面量不支持（首个错误在 image/color） |
| 数学/图像 | `image/color` | 1 | 28 | 1 | — | FAIL | 结构体复合字面量 `RGBA{...}` 不支持 |
| 数学/图像 | `image/gif` | 1 | 14 | 2 | — | FAIL | 编解码桩；结构体复合字面量不支持 |
| 数学/图像 | `image/jpeg` | 1 | 14 | 2 | — | FAIL | 编解码桩；结构体复合字面量不支持 |
| 数学/图像 | `image/png` | 1 | 130 | 2 | — | FAIL | 非真 PNG，仅自定义 raw 格式；结构体复合字面量不支持 |
| 测试 | `testing` | 1 | 338 | 18 | — | OK | — |

---

## 附录 B：rc 约定与测试清单

### B.1 22 个测试目录

```text
pkg/bytes/test
pkg/compress/flate/test
pkg/console/test
pkg/container/heap/test
pkg/container/list/test
pkg/flag/test
pkg/hash/crc32/test
pkg/html/test
pkg/io/test
pkg/log/test
pkg/math/bits/test
pkg/math/test
pkg/mime/test
pkg/os/test
pkg/path/test
pkg/slices/test
pkg/sort/test
pkg/strings/test
pkg/time/test
pkg/unicode/test
pkg/unicode/utf8/test
pkg/uuid/test
```

### B.2 rc 语义

| rc | 含义 |
|---:|---|
| `42` | 多数测试的“全部通过”哨兵 |
| `230` | `slices` 的 `pass*10+fail`，23 项全过 |
| `0` | 本文矩阵中未作为通过 rc 出现；`io`/`time` 在失败计数为 0 时返回 42 |
| `1..n` | `io`/`time` 失败计数；`sort` 的 `1` 是首个断言失败 |
| `124` | `timeout` 杀掉，`mime` 的死循环 |
| `COMPILE_FAIL` / `NASM_FAIL` | 编译阶段 / 汇编阶段失败 |

### B.3 三连稳定

矩阵中的每个结果至少来自一次完整编译 + 运行。关键项另做三连复跑：

- x64：`strings=42`、`slices=230`、`uuid=42`、`io=4`、`time=3`、
  `mime=124`，三连一致；
- x86：`io=12`、`time=3` 三连一致；`mime` 三次均在编译期失败。

---

## 附录 C：复跑命令

### C.1 建审计 worktree 与二进制

```bash
cd /home/gx/Desktop/代码/tiny
git worktree add --detach /tmp/opencode/stdlib-audit HEAD
cd /tmp/opencode/stdlib-audit
TMPDIR=/tmp/opencode go build -o /tmp/opencode/stdlib-audit-bin .
```

### C.2 源码级探针（x64）

```bash
ROOT=/tmp/opencode/stdlib-audit
BIN=/tmp/opencode/stdlib-audit-bin
WORK=/tmp/opencode/audit-src-x86_64
mkdir -p "$WORK"
cd "$WORK"
for d in $(cd "$ROOT" && find pkg -type f -name '*.cute' -printf '%h\n' \
    | sort -u | grep -v '/test$' | sed 's|^pkg/||'); do
  probe="$WORK/probe"
  rm -rf "$probe"; mkdir -p "$probe"
  printf 'import "std:%s"\nfn main() int {\n    ret 0\n}\n' "$d" > "$probe/main.cute"
  if CUTE_ROOT="$ROOT" CUTE_ARCH=x86_64 timeout 30 "$BIN" -S "$probe" \
      >"$WORK/$(echo "$d" | tr '/' '_').log" 2>&1; then
    echo "$d|OK"
  else
    echo "$d|FAIL"
  fi
done
```

把 `CUTE_ARCH` 换成 `x86` 即得 x86 探针；注意 x86 结果会被
`cdecl.go:120` 的 panic 污染。

### C.3 单个测试目录（双架构）

```bash
run_one() {
  arch="$1"; dir="$2"
  cd /tmp/opencode/audit-run-"$arch"
  rm -f _main.asm
  CUTE_ROOT=/tmp/opencode/stdlib-audit CUTE_ARCH="$arch" \
    timeout 60 /tmp/opencode/stdlib-audit-bin "/tmp/opencode/stdlib-audit/$dir" || return
  if [ "$arch" = x86_64 ]; then
    nasm -f elf64 -w-label-redef-late -o p.o _main.asm || return
    gcc -nostartfiles -no-pie -e _start -o p p.o -lpthread || return
  else
    nasm -f elf32 -w-label-redef-late -o p.o _main.asm || return
    gcc -m32 -nostartfiles -no-pie -e _start -o p p.o -lpthread || return
  fi
  timeout 20 ./p; echo "rc=$?"
}
```

### C.4 补 import 的对照

```bash
dst=/tmp/opencode/fix-x86_64-console
rm -rf "$dst"; mkdir -p "$dst"
cp -r /tmp/opencode/stdlib-audit/pkg/console/test/* "$dst"/
sed -i '1i import "std:strings"' "$dst/main.cute"
```

`pkg/console/test` 等目录本身没有 `main.cute` 之外的文件冲突，直接复制即可。
`pkg/container/heap` 等带子路径的目录要保留路径，复制时用
`cp -r pkg/<pkg>/test/* "$dst"/`。

### C.5 `strings.eq` 语义探针

```cute
import "std:strings"
import "std:memory"
import "std:console"

fn main() int {
    var a: string = "ab"
    var b: string = "ab"
    console.print("literal=")
    if strings.eq(a, b) { console.print("Y\n") } else { console.print("N\n") }

    var buf: ptr = memory.malloc(2)
    var _p1: *u8 = buf
    *_p1 = 97
    var _p2: *u8 = buf + 1
    *_p2 = 98
    var c: string = strings.view(buf, 2, 2)
    console.print("constructed=")
    if strings.eq(c, "ab") { console.print("Y\n") } else { console.print("N\n") }
    console.print("compare=")
    if strings.compare(c, "ab") == 0 { console.print("0\n") } else { console.print("non0\n") }
    ret 0
}
```

期望输出：

```text
literal=Y
constructed=N
compare=0
```

---

## 附录 D：相关文档

- `docs/GC_MEMORY_MANAGEMENT.md`：GC 与内存管理总览（分配器、RC、LLR）。
- `docs/stdplan/PLAN.md`：标准库分层、依赖铁律、Wave 规划。
- `docs/stdplan/PROGRESS.md`：标准库实施历史、缺陷⑪/⑰等背景。
- `PROJECT.md`：e2e 验收基线、farm 期望 rc、提交纪律。
- `docs/backend.md`：后端总体结构、架构抽象、调用约定。
