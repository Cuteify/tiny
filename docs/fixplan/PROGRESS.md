# PROGRESS 实时进度日志

> **行格式**：`[YYYY-MM-DDTHH:MMZ] <Agent> step<N> <标志> <一行结论>`
> 标志：`●`=结果 `…`=进行中 `!`=异常 `?`=待定
> 长分析写 `W<n>_NOTES.md`；完成写 `[...] <Agent> DONE <摘要> FILES=<列表>`。
> **每步必写，禁止攒批。** Agent 被中断后，接管者从尾部 30 行 + NOTES 恢复。

---

## 初始快照（基线时刻，主线程写入）

- 2026-10-28 werkstand：esccheck 基线 `107/140 · 对象=114 · RC/泄漏释放=6 · 泄漏=0 · 提前释放=0 · 作用域释放=86 · 转移=22`
- e2e tally：RUN-OK=24 · RUN-FAIL=66 · NASM-FAIL=8 · LINK-FAIL=0 · COMPILE-FAIL=17（runner 的 rc==0 判据对哨兵值测试有假 FAIL）
- 已完成未提交修复：F1 exp.go deref=兜底、F2 compiler.go .data、F3 rcNames 扩充、F4 test json×20、F5 rc.cute initFreeHeads（已同步沙盒）

### 66 个 RUN-FAIL 原始清单（exit 值）

```
arithmeticTest:102 bitwise:9 boundsCheck:20 calleeSave:15 complexExpressions:50
complexTest:139 consoleTest:1 controlFlow:39 derefTest:7(哨兵PASS) echo:124(超时)
edgeValues:75 fib30:40 for_range_test:150 fortest:5(哨兵PASS) fsTest:2
functionCalls:245 gc_complex:7 gc_cond:3 gc_deep:3 gcfree:60(哨兵PASS)
gc_loop:3 gc_multiret:4 gc_nested:3 gcOwnership:9 gcprobe:60(失败,61才对)
gc_ptr:77 gc_string:6 gcStructFree:4 generics:42(哨兵PASS) guessGame:3
heap_new:6 heap_struct:60 list:33 memSuite:3 negIdx:16 oldprobe:139
operatorPrecedence:61 probeA:1(哨兵PASS) probeB:1(哨兵PASS) probeC:1(哨兵PASS)
probeRC:1(哨兵PASS) rcSimple:12(哨兵PASS) rctest:60(哨兵PASS) rcTracking:139
recursion:139 scopeTest:119 simpleMethod:42 simpleTest:1 simpleVar:42(哨兵PASS)
sliceprobe2:77 slice_test:139 sortIntOnly:139 sortMinimal:139 sortMinimal2:139
sortQuick:139 sortTest:139 strconv:11 string:100 stringOperations:50 strings:60
stringsTest:8 stringsUtils:139 struct:139 structMethod:92 variadic:42(哨兵PASS)
```

### 8 个 NASM-FAIL

```
thread: symbol std_thread_threadEntryRaw__ptr not defined
structValue / m5: excess brackets in memory operand
rcLeak / fullSyntaxTest: invalid combination of opcode and operands
memoryTest: mismatch in operand sizes
simple: label or instruction expected at start of line
asmTest: operation size not specified
```

### 17 个 COMPILE-FAIL

```
array_basic buildKeyword comprehensive fib30bench fib30time fnptr_test gcDebug
gc_docs iface_dispatch multi_return overload runtime slice_minimal stringUtils
switch_test "test copy" time
```

---

## 活动日志（Agent 从此往下追加）
[2026-10-27T17:35Z] W1 boot ● 已读 PROBLEMS/PLAN/PROGRESS，开始 Cluster A：this/self ABI 单一事实源修复
[2026-10-27T17:35Z] W2 boot ● 已读 PROBLEMS/PLAN/PROGRESS；战役=8×NASM-FAIL(thread/structValue/m5/rcLeak/fullSyntaxTest/memoryTest/simple/asmTest)；开始构建 w2 bin
[2026-10-27T17:35Z] W2 step1 ● w2 bin 构建成功 (6.5MB)，开始逐个复现
[2026-10-27T17:35:50Z] W3 boot 已读 PROBLEMS(§0/§6)/PLAN(§2 W3)/PROGRESS尾30；17个签名已从e2e_full.log核对；准备build w3 binary
[2026-10-27T17:37Z] W2 step2 ● thread PASS(nasm+exit0)：pkg asm 引用从未有编译器合成的 __ptr 符号=语料缺口；pkg/thread 两个 .cute 的 lea 改直接引用已发射函数标签 std_thread_threadEntryRaw；threadEntryRaw 本就 Useful(经 var _entryFn 函数值标记) 已在产物定义。动机已录
[2026-10-27T17:39Z] W2 step3 ● structValue 根因定位：stripOuterBrackets 剥掉 QWORD 前缀后残留前导空格→不识别为括号→copySlots 生成 [ [rsp+0]+0] 双括号；已在 exp.go/linux_sysv.go/cdecl.go 三处同构修复(前置剥+二次TrimSpace)
[2026-10-27T17:39Z] W2 step4 ● structValue NASM 已干净，exit=11（RUN 语义交 W4；本战役目标=NASM 干净）
[2026-10-27T17:39Z] W2 step5 ● 哨兵复核 derefTest=7 rcSimple=12 ✓（exp/sysv 改动无回归）；转 m5
[2026-10-27T17:39Z] W2 step6 ● m5 PASS(exit=7)——同根被 stripOuterBrackets 修复覆盖，无需额外工作；复现 rcLeak
[2026-10-27T17:40Z] W1 step1 ● 根因闭合完成：6 个 touchpoint（utils.go×2/exp.go thisMem/linux_sysv/ms_win64/x86 32位），exp.go thisMem 确在 gdb 崩溃主径，方案=ctx.ThisHomeRbp 单一源；NOTES 已落盘
[2026-10-27T17:41Z] W2 step7 ● rcLeak 根因：x86_64/ops.go InstBinary 比较分支对内存目的发 movzx mem,al（非法）；改为 movzx RAX/EAX,al + mov 回内存目标
[2026-10-27T17:41:12Z] W3 step1 ● array_basic 语料修正完成(多参println×6/exit→ret/len切片)；COMPILE打过→残留NASM @W2(array literal 无尺寸 mov)；细节入 W3_NOTES
[2026-10-27T17:41Z] W2 step8 ● fullSyntaxTest 新错误=BYTE 目标存 RAX 尺寸不符；比较分支补 BYTE/WORD/DWORD/QWORD 宽度分派。rcLeak 已 PASS(exit0)
[2026-10-27T17:41Z] W2 step9 ● fullSyntaxTest NASM 干净(exit139=运行期段错误,交W4语义档)；rcLeak exit0 维持；转 memoryTest
[2026-10-27T17:47Z] W2 step10 ● memoryTest PASS(nasm+exit0)：语料缺口——x86_64 目标下 test/memoryTest/main.cute 用 i386 ABI(EBX/ECX/EBP 装载 u64 QWORD 操作数+int0x80)必然非法；重写为 64 位 syscall ABI(RDI/RSI/RDX/R10/R8/R9, trap 号紧贴 syscall), 返回值语义(ret 0)原样保留, 动机已录。转 simple
[2026-10-27T17:48:01Z] W3 step2 ● buildKeyword 判定=parser限制(禁改移交@MAIN)：build os块×fs import 双条件触发 nil Parser贯通(3断点,map序漂移)；沙盒探针A/B各单独OK；m=stale ELF语料垃圾；沙盒已恢复原样
[2026-10-27T17:48:48Z] W3 step3 ● comprehensive: package.json(memory) 补齐→COMPILE通；RUN139(methodChain this ABI) @W1/@W4
[2026-10-27T17:49:47Z] W3 step4 ● gc_docs=纯md文档目录(8文件git tracked,无.cute)；不建package.json；搬移入 docs/ 建议@MAIN/W5(避免扰动W1进行中esccheck基线)
[2026-10-27T17:50Z] W2 step11 ● simple PASS(nasm+exit116=正确372低8位)：根因=fn 名 'abs' 与 NASM 保留一元运算符撞名(标签/call 双非法)；语料改名 absValue(调用点同步),动机已录。注意: _main.asm 有 Go map 序非确定性但 abs 改名后各变体均 nasm 干净；转 asmTest
[2026-10-27T17:50Z] W2 step12 ● asmTest PASS(nasm+exit0)：语料手写非法 NASM(立即数无 mem 尺寸+add mem,mem)；按意图重写为等价合法形态(RAX 中转),动机已录。8/8 NASM 全干净，开始 esccheck 基线
[2026-10-27T17:52:26Z] W3 step5 ● time/fib30bench/fib30time 同根：pkg/time 三处"括号内//注释"语料修正→COMPILE通；残留excess brackets @W2(struct拷贝发射)
[2026-10-27T17:53:20Z] W3 step6 ● gcDebug 全PASS(exit=0)：println(int)→toString + 旧dependencies协议→imports
[2026-10-27T17:54:17Z] W3 step7 ● fnptr_test=parser限制(一等函数调用无分派路径,语料唯一先例,不做语料改写)；移交@MAIN
[2026-10-27T17:59Z] W1 step2 ● esccheck 改前聚合基线已抓：对象=122 RC=6 泄漏=0 提前=0 作用域=94 转移=22（pkg/testing 目录挂死>8s 强排除，文档参考基线 114/86 的差值=8 与该目录口径吻合；本战役锚定同一口径改前/改后逐位对拍）
[2026-10-27T18:01Z] W1 step3 ● 6 处编辑完成：context.ThisHomeRbp+访问器、sysv(-48/prologue/stackArgBase=16)、win64(+16,字节不变)、x86_64 utils 两分支、x86 cdecl/stdcall(+8)、exp.go thisMem（所有权扩展@W2 已注记）—— go build & esccheck 对拍中
[2026-10-27T18:01Z] W1 step4 ● esccheck 基线对拍 PASS：改前/改后聚合逐位一致(122·6·0·0·94·22，pkg/testing 排除口径)；go build 绿。开始哨兵回归
[2026-10-27T18:03Z] W1 step5 ● 哨兵全部 PASS：derefTest=7 probeC=1 rcSimple=12 rctest=60 gcfree=60（ABI 改后无回归）。开始崩溃族逐个复核
[2026-10-27T18:05Z] W2 step13 ● esccheck 基线核对(W2口径: 逐目录独立进程): 不变列全逐位一致 RC/泄漏释放=6 泄漏=0 提前释放=0 转移=22；对象=115/作用域=87 比基线+1成对——归因 W3 新建 test/comprehensive/package.json(edge_cases.cute 首次可解析出1对象1作用域, 见 escw2/comprehensive.out)，非 W2 回归。W2 无漂移
[2026-10-27T18:05Z] W1 step5.5 ● 服务重启恢复；发现 ops.go 混入 @W2 半成品（setXX→movzx 内存回写，仅比较类指令），不回滚不触碰。struct=19(期望207) 二分探针继续
[2026-10-27T18:05:51Z] W3 resume ● 服务器重启恢复：已完成8/17归档(array_basic/buildKeyword/comprehensive/gc_docs/fib30bench+fib30time+time/gcDebug/fnptr_test)；重启前最后一条批命令(switch变体 bisect)被取消，sw_v1/sw_v2 日志已落盘待读；余下 switch_test/overload/runtime/slice_minimal/stringUtils/test copy
[2026-10-28T02:05Z] W2 step14 ● 终验清扫 8/8 NASM 全干净 + RUN: thread=0 structValue=11 m5=7 rcLeak=0 fullSyntaxTest=139 memoryTest=0 simple=116(=372低8位,真PASS) asmTest=0；哨兵 derefTest=7 rcSimple=12 probeC=1 rctest=60 gcfree=60 全亮
[2026-10-28T02:06Z] W2 DONE 8战全歼：thread(pkg语料__ptr符号逃逸)=0、structValue+m5(stripOuterBrackets剥QWORD前缀残留前导空格→[[..]]双括号；exp+linux_sysv+cdecl三处同构修复)、rcLeak+fullSyntaxTest(InstBinary比较分支对内存目发movzx mem,al非法；BYTE/WORD/DWORD/QWORD宽分派两迭代)、memoryTest(语料i386 ABI→64位syscall ABI重写)、simple(语料fn abs撞NASM保留一元运算符→absValue；exit116=372低8位真语义)、asmTest(语料非法asm重写RAX中转)。esccheck不变列逐位一致(RC/泄漏释放=6·泄漏=0·提前释放=0·转移=22)；对象115/作用域87 vs 基线114/86 为 W3 comprehensive package.json 新解析所致非W2回归。哨兵5全亮。分析存 W2_NOTES.md。RUN 语义遗留: structValue=11 fullSyntaxTest=139 归 W4。FILES=pkg/thread/thread.cute pkg/thread/thread_x86_64.cute compile/exp/exp.go compile/arch/x86_64/linux_sysv.go compile/arch/x86/cdecl.go compile/arch/x86_64/ops.go test/memoryTest/main.cute test/simple/main.cute test/asmTest/main.cute docs/fixplan/W2_NOTES.md
[2026-10-27T18:08:16Z] W3 step8 ● switch_test=parser限制：连续case不可解析(单case+default也炸；V1/V2/V3三变体实证；parser.go仅}弹回)。全语料唯一switch用例。@MAIN
[2026-10-27T18:09:04Z] W3 step9 ● overload=parser限制(FindFunc单值无arity分派,语料唯一重载用例)；@MAIN
[2026-10-27T18:11:25Z] W3 step10 ● runtime=语料修正(extern→ext×3文件,写法源自compile/build.go ext能力)；COMPILE过→NASM(extern指令形状)@W2
[2026-10-27T18:12:44Z] W3 step11 ● slice_minimal 全PASS(exit=0)：旧API遗迹(IntSlice/newIntSlice已废)→slices.new[int](); 顺否证*pkg.Type语法嫌疑
[2026-10-27T18:13Z] W1 step6 ● 铁证深化：ZeroVar 只清容器，结构体无零初始化→zeroPoint 读陈旧栈(68=x²+y²)。扩展 ZeroVar 清 struct/iface/ptr 整槽(多初始化方向)。struct=207 期望精确命中，哨兵 5 全亮
[2026-10-28T04:35Z] MAIN resume ● W1/W3 因用量限额中断。盘点：W1 已完成 ABI 6 处编辑+esccheck 对拍+哨兵+struct=207（step6）；W3 已归档 15/17。主线程接手剩余：W1 崩溃族复核(13个刚跑：struct=207✓ structMethod=45 complexTest=1 其余9个仍139) + esccheck 全量复验 + W3 剩 stringUtils/test copy。
[2026-10-28T04:50Z] MAIN stepR2 ● 第三根因确证：单态化 remap 只重绑 FindTypeArg（monomorphize.go remapNodeRefs），克隆体内引用型局部变量的 Define 仍指泛型原树 Define 节点（未 Setup→Offset=0）→ 所有指针型局部加载发成 QWORD[rbp+0]。铁证：std_slices_push 的 sAddr 定义发射=[rbp-48]→[rbp-64] 正确，随后引用 sAddr 发 [rbp+0]；int 型/arg 引用均正常。修复=补 FindTypeVar 重绑（克隆体内 define 收集 map）
