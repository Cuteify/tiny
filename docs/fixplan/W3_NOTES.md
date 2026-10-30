# W3_NOTES —— COMPILE-FAIL 17 个逐个归档（W3 实时草稿）

> 判定三档：`语料修正`（已顺手修 or 留建议）/ `后端可修`（@W1/@MAIN 路由，W3 不改 .go）/ `parser 限制`（禁改，移交）
> 每个测试一段：错误原文 / 最小复现 / 判定 / 证据 / 建议。完成后统计在文末。
> 日志基线：/tmp/opencode/e2e_full.log（行1-25）；binary=/tmp/opencode/bin/w3。

## 待办清单（勾选）
- [x] array_basic
- [x] buildKeyword
- [x] comprehensive
- [x] fib30bench
- [x] fib30time
- [x] fnptr_test
- [x] gcDebug
- [x] gc_docs
- [ ] iface_dispatch
- [ ] multi_return
- [x] overload
- [x] runtime
- [x] slice_minimal
- [ ] stringUtils
- [x] switch_test
- [ ] "test copy"
- [ ] time

---

## array_basic（2026-10-27T17:4xZ，W3）
- **错误原文**：`Call Error: too many arguments in call to println`（e2e_full.log 行1；首例 main.cute:10）→ 修后连环冒出 `not found function 'exit'` → `not found function 'len'`。
- **最小复现**：`println("FAIL: arr[0] = ", first)`（main.cute:10）——println 只有 1 个 string 参数。
- **证据**：
  1. `pkg/builtin/builtin.cute:13` 与 `pkg/console/console.cute:15` 均为 `fn println(s string) i32`，无变参；
  2. 全 test 语料 grep `println([^)]*,`：仅 array_basic 有真实多参调用（consoleTest/console_adv 误报是字符串内含逗号）；
  3. `test/variadic/main.cute` 无 `...` 语法，语言无变参调用实证；
  4. parser/call.go:73-79 BuiltinFuncs 兜底按名注册 println，arity check 在 call.go:142（MissError panic 是 error.go:149 失败即 panic 终止行为）。
  5. `exit`：builtin 无 exit；`pkg/os/os.cute:10 fn exit(code: i32)`、syscall 亦有，但非 builtin、必须 `os.`/`syscall.` 限定调用。
  6. `len`：`len("abc")`/`len([]int)` 编译通过；`len([3]int)` → `Call Error: not found function 'len'`（最小复现多次验证）。parser/call.go:102-124 仅 `Type.Kind()=="list"` 合成 `__list_len/cap/ptr`；字符串有 finder.go:347 特判；**定长数组无 len 分派**（能力缺口，非笔误）。
- **判定：语料修正（已完成）+ 残留 NASM 归 @W2**:
  - 改动（每处理由）：
    a) 6 处多参 println → 单参字符串（5 处 FAIL 消息 + len 段重写）；理由：println 固定 arity=1，变参需 parser 支持（禁改面）。
    b) `fn main() {` → `fn main() i32 {`；6 处 `exit(1)` → `ret 1`；末尾补 `ret 0`。理由：consoleTest/builtinTest 的 canonical 形状（`fn main() i32` + ret 码），零 import，保测试语义（失败=exit 1）。
    c) len 检查改用切片 `var sl: []int = []int{55,66,77}`；理由：len 定长数组不可用，保留其余 [3]int 语义验证。
  - 修后状态：**COMPILE 通过**（数组声明/索引/赋值/零值全过 check），落进 NASM-FAIL：`_main.asm:15-17: operation size not specified`，即 `[3]int{10,20,30}` 字面量逐元素发射 `mov [rbp-64], 10`（内存目标+立即数无尺寸前缀）。**与 W2 清单里 asmTest 同签名**（可能同发射器）。
- **建议**：@W2 —— 收集「mov/movzx 装入内存缺尺寸」全部案例（asmTest、array_basic；array literal emitter 在 compile/exp 或 arch 顶层，补 `QWORD []`）。@MAIN —— len 对固定数组的支持留档（parser/call.go 合成路径只认 Kind==list）。
- **状态编码**：COMPILE-FAIL → 语料修正已消 → NASM-FAIL（移交 W2）。

## buildKeyword（2026-10-27T17:50Z，W3）
- **错误原文**：`panic: runtime error: invalid memory address or nil pointer dereference`（SIGSEGV addr=0x8）。
- **三份堆栈（同一 panic，因 map 迭代序断点漂移）**：
  1. `parser.(*Parser).Find(0x0, …)` ← `CallBlock.Check(_, 0x0)` call.go:42 ← checkCall exp_check.go:70 ← `ReturnBlock.Check` return.go:78 ← `Node.Check`×3 ← GetPackage package.go:372（rootNode Check 收敛循环）。
  2. `parser.(*VarBlock).ParseDefine(_, 0x0)` var.go:411 ← checkVar ← checkUnary/checkOp ← `ForBlock.Check` for.go:234 ← `Node.Check`×3 ← 同上 372。
  3. （第一次复现，含 m 文件时）CallBlock 版。
  ⇒ 特征：**nil *Parser 一路贯通到 Check 内部使用点**；断点都在 pkg/fs 形状的语句（for/var/return→call）。
- **语料（test/buildKeyword/）**：main.cute = `build os(windows)/os(linux)/os(darwin,linux)` 三对顶层 build 块 + 三个空转函数 + `fn main() ret 0`；package.json imports `fs`。目录里还有 **`m`（4776B stale ELF 二进制，内含 `_main.asm func_end_main` 字符串）—— 语料垃圾，建议改名 m.bak/移除**（已验证改名与否不改 panic 结论）。
- **沙盒二分探针（垃圾重置纪律下完成）**：
  | 探针 | fs import | build os 块 | m | 结果 |
  |---|---|---|---|---|
  | A | 无 | 有 | m→m.bak | **COMPILE OK**（_main.asm 67994B） |
  | B | 有 | 无（删 3 行 build os） | m→m.bak | **COMPILE OK**（_main.asm 78711B） |
  | 原始 | 有 | 有 | 有/改名均有 | **PANIC**（nil Parser） |
  ⇒ 触发条件 = **BOTH**（build 顶层块 × 跨包 import）。单独各自成立。
- **判定：parser 限制（禁改，移交 @MAIN）**：
  - 证据：fixParser 的 Parser 绑定在 `build` 块参与的树形（或 GetPackage 的 build 过滤路径）未覆盖到 pkg 子树的某些 Check 分支；check 期间以 nil Parser 递归进入 use 点；三断点漂移证明非单一发射点而是结构性缺失。parser/* 与 compile/gc/* 双禁改，W3 不可动。
  - 注意：m（ELF）已排除为诱因（改名前后均 panic）。
- **建议**：@MAIN —— parser 侧排查「build 块 × 包合并」：GetPackage 的 fileSkipped/preFilterBuild 与 fixParser(rootNode) 递归对 Build 子树的处理；同时把语料 `m` 清理（二进制不属于 .cute 语料）。不用移除 build 块来绕（那就毁了测试目的）。
- **状态编码**：COMPILE-FAIL → parser 限制（移交）。

## comprehensive（2026-10-27T17:53Z，W3）
- **错误原文**：`panic: open test/comprehensive/package.json: no such file or directory`。
- **语料**：edge_cases.cute（216 行）——[]int 切片、struct(P/Line/Counter)+方法调用(increment/add)、*int 指针、多级 for、字符串 +。**零 `pkg./` 限定调用**。
- **判定：语料修正（已完成）**：创建 test/comprehensive/package.json `imports:{"memory":"std:memory"}`。理由：complexTest/fullSyntaxTest/gc_complex 同型（重 list/字符串/struct 且 0 限定调用）均为 memory-only 先例（F4 修订同型）。
- **修后状态**：COMPILE ✓ → nasm ✓ → link ✓ → **RUN exit=139（SEGV）**。139 源头大概率 `methodChain()` 的 `c.increment()/c.add(5)` —— this receiver ABI（Cluster A）。
- **建议**：@W1 复核 ABI 修后此测试（post-fix 逐个复核清单 §4 有 complexTest 同型）；@W4 语义（期望值=ret result 可从源码静态算出）。
- **状态编码**：COMPILE-FAIL → 已消 → RUN-FAIL 139（W1/W4 战场）。

## gc_docs（2026-10-27T17:56Z，W3）
- **错误原文**：`panic: open test/gc_docs/package.json: no such file or directory`。
- **语料核查**：test/gc_docs/ = **纯文档目录**（README.md + gc_{complex,cond,deep,loop,multiret,nested,string}.md 共 8 个 git 跟踪文件，**无任何 .cute 源码**）。git status 干净（已跟踪未修改）；内容与沙盒一致性 diff 通过。
- **判定：语料结构问题（非代码缺陷）——@MAIN 执行搬移**：
  - 不建 package.json：目录无 .cute，补 json 徒劳（GetPackage 无可编译文件）。
  - **建议动作（@MAIN/W5）**：`mv test/gc_docs docs/gc_docs`（内容不变，纯位置；e2e_all 的 `for test/*/` 扫描不再误入文档目录）。
  - **为何不立即搬（偏离 PLAN 原文说明）**：W1 正在全语料跑 esccheck 基线（`for d in test/*/`），搬移会改变全语料目录数（140/114 计数口径），威胁进行中的基线逐位对比 —— 铁律 §0.1 优先。等 W1 DONE 后由 MAIN/W5 执行。
- **状态编码**：COMPILE-FAIL → 判定为「非语料文档目录」→ 搬移归 @MAIN（决策已归档）。

## fib30bench / fib30time / time（2026-10-27T18:05Z，W3，一组同根）
- **错误原文（三个全部）**：`Syntax Error: missing ')' in call` —— 报错显示 pkg/time/time.cute:1:0（文件头游标，位置误导）。
- **根因（已确证，pkg/time/time.cute:64/83/102）**：
  ```cute
  *_p3 = unsafe.cast[u8](104 // 'h')
  ```
  注释**置于调用括号内部**：`//` 吃掉 EOL（包括即将闭合的 `)`），parser 下一个 token 变成下一行语句 → CallBlock.ParseCall call.go:203 报 missing ')'。
- **Bisect 证据**：head -60 截断后错误变为 `Need }`（60 行内干净）→ 罪点在 61 行后；逐行核对得三处 `unsafe.cast[u8](NNN // 'h'|'m'|'s')`。其余嫌疑全排除：`build os("linux")` 引号样式在 pkg/memory、pkg/slices 大量同型正常编译；全角括号注释在 builtin/console/fs 常见正常。
- **判定：语料修正（已完成，pkg/<std包> 语料源码缺口）**：三处 `(104 // 'h')`→`(104)`、`(109 // 'm')`→`(109)`、`(115 // 's')`→`(115)`。理由：注释误置进参数列表；ASCII 标注纯装饰，删除零语义影响。已 cp 同步沙盒。
- **修后状态**：test/time COMPILE ✓ → **NASM-FAIL** `_main.asm:9132-9136: excess brackets in memory operand`（`mov QWORD [ [rsp+0]+0], RAX`，Time struct 拷贝路径）；fib30bench（134/136/138 同）、fib30time（227/229/231 同）。**与 W2 清单 structValue/m5 同签名，疑似同一发射器**。
- **建议**：@W2 —— 「excess brackets」集中在 struct 以 `[reg]+off` 二级寻址展开复制处（`[[rsp+0]+off]` 应折成 `[rsp+off]` 或先经寄存器）。@W4 —— test/time 的 i64 比较 `-2177481943 <= 1696204800` 恒真 → 期望 exit 1；fib30bench 期望 fib(30)=832040 校验 + ns!=0。
- **状态编码**：COMPILE-FAIL → 语料修正已消 → NASM-FAIL（移交 W2）。

## gcDebug（2026-10-27T18:10Z，W3）✅ 完全通过
- **错误原文**：`Type Error: cannot use int as type string in argument to println`（main.cute:45:14 `println(r1)`）。
- **最小复现**：`var r1: int = ...; println(r1)` —— println 参数类型固定 string；语料把 int 直接喂给它。
- **第二问题**：package.json 是旧协议 `"dependencies": ["memory","strings"]`（F4 后新协议为 imports 映射）—— new(Node) 需 std:memory。
- **判定：语料修正（已完成）**：
  1) `println(rN)` ×3 → `println(strings.toString(rN, 10))`（保留数值打印意图；strings 先例=fib30time 同型写法）。
  2) package.json 改 `imports:{"memory":"std:memory","strings":"std:strings"}`（保留原依赖意图）。
- **修后状态**：**RUN exit=0 全绿**（compile/nasm/link/run 全通过）。gcDebug 的 new(Node) 三件套（localAlloc/loopAlloc/fieldOrphan）在当前后端下语义自洽。
- **状态编码**：COMPILE-FAIL → 语料修正已消 → 全 PASS。

## fnptr_test（2026-10-27T18:15Z，W3）
- **错误原文**：`Call Error: not found function 'f'`（main.cute:7 `f(3, 4)`）。
- **语料全貌**（9 行）：`fn add(a,b int) int` + `var f: fn(int,int) int = add` + `f(3,4)` + `ret result` —— 一等函数值用法。
- **证据**：
  1. parser/call.go CallBlock.Check：bare 名 `f` → Func==nil 且 ThisVar==nil（无 path）→ 直接落到 "not found function 'f'"（call.go:133）；**无「VarBlock 持 fn 值 → 作为 c.Func」的分支**；
  2. `fn(int,int) int` 类型字面量本身可解析（parser.go:236-250 RType{TypeName:"fn"}），失败点只在调用侧；
  3. 语料 grep `var f: fn(`：全语料**仅此一处**；pkg/sort 无回调 API（排序全是专用 int 版）；[没有]任何一等函数先例。
- **判定：parser 限制（禁改，移交 @MAIN）**：
  - 语料改写（去掉 fn 值）会摧毁测试目的（测试的就是函数指针），不做。
  - 建议：如要把语言支持一等函数：CallBlock.Check 需把「名字解析到 VarBlock/ArgBlock 且 Type.Kind()=="fn"」绑定为 c.Func（合成 FuncBlock 带 Return/Params 签名），再由编译器发射间接 call —— 是语言特性级工作，非小修。
- **状态编码**：COMPILE-FAIL → parser 限制（移交，语料保留原样）。

## switch_test（2026-10-27T18:3xZ，W3）
- **错误原文**：`Syntax Error: 'case' outside of switch`（py_switch_test.log；首例 main.cute:5 附近游标误指）。
- **语料**：`switch x { case 1: ret 10 / case 2: ret 20 / default: ret 30 }`（tab 缩进，标准形状）。
- **设计探针（3 变体，w3probe 沙盒）**：
  | 变体 | 内容 | 结果 |
  |---|---|---|
  | V1 | 单 case + default | `case 2:` 过，`default:` → **'default' outside of switch** |
  | V2 | `switch (x)` 加括号 + 多 case | 第二个 `case 2:` → 同错 |
  | V3 | 无末行 ret（语法最小化） | 同错 |
- **根因定位（读码证据）**：parser/switch.go:78-91 CaseBlock.Parse 要求 `p.ThisBlock.Value.(*SwitchBlock)`；但首个 case 解析后 ThisBlock=case 节点，**没有任何路径在新 case/default 到达前弹回 switch**（parser.go:42-53 仅在 `}` 共用退两层）。⇒ **连续 case 分支不可解析**（switch 本身 lex 到 PROCESSCONTROL：lexer/keywords.go:14-16 齐；第一个 case OK）。
- **全语料先例**：grep `switch ` 全 test/* + pkg/*.cute —— **只有 switch_test 用**，无任何通过案例。
- **判定：parser 限制（禁改，移交 @MAIN）**：
  - 修法草案（MAIN 审定）：processControlToken 的 case/default 分支（parser.go:278-283）在 New CaseBlock 前若 ThisBlock 是 *CaseBlock 且其 .Switch != nil，先退回 switch 作用域（或 CaseBlock.Parse 头部自顶逐层寻找最近 Switch）。编译侧 SwitchBlock 编译器已有 consumer（Cases []*CaseBlock 在 Parse 阶段填充）。
  - 语料不可修复（≥2 case 是测试目的），保留原样。
- **状态编码**：COMPILE-FAIL → parser 限制（移交）。

## overload（2026-10-27T18:3xZ，W3）
- **错误原文**：`Call Error: too many arguments in call to add`（main.cute:21 `add(1, 2, 3)`）。
- **语料**：同文件两个 `fn add`（2 参 / 3 参）——函数重载测试。
- **证据（读码）**：parser/finder.go:69-95 `FindFunc` 逆序扫 Children **首个名字匹配即 return**；`FindGlobal` 同理单值；call.go Check 拿单 FuncBlock 比参数个数。**无任何签名/arity 分派**（声明顺序定胜者：首声明 add(2参) 被找到 → 3 参调用报 too many）。
- **语料先例**：全语料无同名函数重载先例（pkg 内名字全唯一）。
- **判定：parser 限制（禁改，移交 @MAIN）**：
  - 重载就是测试目的，语料改写（改名 add2）会毁测试，不做。
  - 修法草案：FindFunc/FindGlobal 返回候选列表按调用 arity+类型匹配（checker 级改动，牵动 FixPath/包合并/BuiltinFuncs）。
- **状态编码**：COMPILE-FAIL → parser 限制（移交）。

## runtime（2026-10-27T18:4xZ，W3）
- **错误原文**：`Syntax Error: Miss (`（malloc_linux.cute:4:17 `build extern("mmap")`）。
- **根因**：parser/build.go 支持的 build 类型 = `asm/ext/extret/os/arch/link`；**没有 `extern`**（processBuildToken 不识别 → token 漏入 default 报 Miss）。语料拼写与现能力不符。
- **正确写法（读码证据）**：`build ext("funcname")` —— compile/build.go:84-95：函数体内放 `build ext("mmap")` 自动合成 buildExtSysV/buildExtCdecl 参数转发封装，Ext 内容去引号。
- **判定：语料修正（已完成）**：malloc_linux/darwin/windows.cute 共 6 处 `build extern("...")` → `build ext("...")`。理由：与既有 ext 能力对齐，零语义损失（目的=声明外部 libc 符号）。已 cp 同步沙盒。
- **修后状态**：COMPILE ✓（**无 main.cute 也能产 asm**:66439B，目录即多文件组）→ **NASM-FAIL**：`_main.asm:2665: identifier expected after extern, got ("mmap")` —— 发射形状 bug：正文中出现 `extern ("mmap")`/`("munmap")` 原文（含引号+括号）。
- **建议**：@W2 —— extern 指令发射应去引号输出 `extern mmap, munmap` 且置于文件头部（疑似 Build/Ext 原文直出）。@W4 —— runtime 无 main，RUN 凭据按 asm 产物定。
- **状态编码**：COMPILE-FAIL → 语料修正已消 → NASM-FAIL（移交 W2）。

## slice_minimal（2026-10-27T18:5xZ，W3）✅ 完全通过
- **错误原文**：`Syntax Error: need type`（main.cute:2 `var s: *slices.IntSlice = slices.newIntSlice(4)`）。
- **根因（已确证）**：不是 `*pkg.Type` 语法问题 —— **slices.IntSlice / newIntSlice 在现行 pkg/slices 里根本不存在**（pkg/slices/slice.cute 是泛型动态数组，`fn new[T](initialCap int) ptr`）。test 目录里遗留的 gc_llr.txt/gc_summary.json 还带旧符号 `slices.newIntSlice` —— 该测试是 pkg 泛型化重写前的老语料。
- **语料先例反证**：pkg/maps 全程用 `m *hashmap.HashMap`（跨包 named type 指针），编译正常。
- **判定：语料修正（已完成）**：
  a) main.cute → `s := slices.new[int](4)`（`:=` 推断保留原意：最小化使用 slices+console；泛型调用先例=generics 测试全安全通过）；
  b) package.json imports 追加 `memory`（slice.new 内部走 memory.malloc，同 F4 口径）。
- **修后状态**：**RUN exit=0 全绿**（compile/nasm/link/run）。
- **状态编码**：COMPILE-FAIL → 语料修正已消 → 全 PASS。
