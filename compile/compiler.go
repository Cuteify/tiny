package compile

import (
	"cuteify/compile/context"
	cuteExp "cuteify/compile/exp"
	"cuteify/gc"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"fmt"
	"os"
	"reflect"
	"strconv"
	"strings"
)

var GoArch = "x86"

func init() {
	GoArch = typeSys.TargetArch()
	if os.Getenv("CUTE_ARCH") != "" {
		fmt.Println("Using target arch:", GoArch)
	}
}

// Compiler 编译器结构体，负责将AST转换为汇编代码
type Compiler struct {
	Ctx            *context.Context                   // 编译器上下文
	RootGenerated  bool                               // 标记是否已生成 section .text
	stringSyms     map[string]bool                    // build link 声明的全局符号（如 __string_len）
	currentFuncKey string                             // 当前编译函数的全路径名（用于 GC block frees 查询）
	typeSubsts     map[string]map[string]typeSys.Type // 单态化函数的类型替换表（label → substMap）
	funcNodeMap    map[*parser.FuncBlock]*parser.Node // FuncBlock → AST Node 映射（跨包查找用）
	compiling      bool                               // 标记是否在顶层编译中（防止递归调用重置泛型注册表）
	condSeq        int                                // 条件表达式内部标签序号（&& mid / || andFail，保证唯一）
}

// nextCondLabel 生成条件表达式内部唯一标签（前缀 + 单调序号）
func (c *Compiler) nextCondLabel(prefix string) string {
	c.condSeq++
	return prefix + strconv.Itoa(c.condSeq)
}

// NewCompiler 创建新的编译器
func NewCompiler(parser *parser.Parser) *Compiler {
	return &Compiler{
		Ctx:        context.NewContext(),
		stringSyms: map[string]bool{},
	}
}

// Compile 编译入口方法，将AST节点编译为汇编代码
func (c *Compiler) Compile(node *parser.Node) (code string) {
	c.initializeContext()
	// Only run top-level pre-passes (and GC analysis) at the top-level entry,
	// not in recursive calls.
	if !c.compiling {
		gc.Analyze(node)
		resetGenericRegistry()
		c.compiling = true
		defer func() { c.compiling = false }()
	}
	c.collectLinkSyms(node)
	c.Ctx.StringSyms = c.stringSyms
	c.Ctx.LinkProviders = parser.LinkProviders
	// Pre-pass: mark methods needed by interface assignments as useful
	c.markIfaceMethods(node)
	// Pre-pass: mark build link providers as useful so they get compiled.
	// This must happen at compile-time because Check() can't re-evaluate
	// nodes that were already Checked=true when LinkProviders was empty.
	c.markLinkProviders(node)
	// Pre-pass: mark memory.rcDec/rcInc as useful (called from GC emit)
	c.markRCFuncs(node)
	// Pre-pass: collect build export aliases for global declarations
	c.collectExports(node)
	code = c.compileRoot(node, code)
	code += c.compileChildren(node, "")
	code += c.compileRootTail(node)
	return code
}

// collectLinkSyms 收集 build link 声明的全局符号名（如 __string_len），
// 供内建 len/cap 检测后改为调用 strings 包实现（未提供时保持内联）。
func (c *Compiler) collectLinkSyms(node *parser.Node) {
	if node == nil {
		return
	}
	if fb, ok := node.Value.(*parser.FuncBlock); ok {
		for _, bf := range fb.BuildFlags {
			if bf.Type == "link" && bf.Link != "" && !bf.Ignore {
				if c.stringSyms == nil {
					c.stringSyms = map[string]bool{}
				}
				c.stringSyms[bf.Link] = true
			}
		}
	}
	for _, ch := range node.Children {
		c.collectLinkSyms(ch)
	}
}

// collectExports 收集 build export 声明的导出别名（pre-pass，用于在函数前输出 global 声明）
func (c *Compiler) collectExports(node *parser.Node) {
	if node == nil {
		return
	}
	if fb, ok := node.Value.(*parser.FuncBlock); ok {
		for _, bf := range fb.BuildFlags {
			if bf.Type == "export" && bf.Export != "" && !bf.Ignore {
				if c.Ctx.Exports == nil {
					c.Ctx.Exports = make(map[string]string)
				}
				c.Ctx.Exports[bf.Export] = fb.MangledName()
			}
		}
	}
	for _, ch := range node.Children {
		c.collectExports(ch)
	}
}

// findLinkFlag 返回函数的 build link 标志（若有）。
func (c *Compiler) findLinkFlag(funcBlock *parser.FuncBlock) *parser.Build {
	for _, bf := range funcBlock.BuildFlags {
		if bf.Type == "link" && !bf.Ignore {
			return bf
		}
	}
	return nil
}

// markIfaceMethods pre-pass: mark methods needed by interface assignments as useful
// so they get compiled even though they're not directly called.
func (c *Compiler) markIfaceMethods(node *parser.Node) {
	if node == nil {
		return
	}
	if vb, ok := node.Value.(*parser.VarBlock); ok {
		if vb.Value != nil && vb.Type != nil && vb.Value.Type != nil {
			if _, isIface := vb.Type.(*typeSys.InterfaceType); isIface {
				// Mark all methods on the concrete type as useful
				for _, m := range vb.Value.Type.Methods() {
					if fb, ok := m.(*parser.FuncBlock); ok {
						fb.Useful = true
					}
				}
			}
		}
	}
	for _, ch := range node.Children {
		c.markIfaceMethods(ch)
	}
}

// markLinkProviders pre-pass: mark build link providers as useful so they get compiled.
// This is necessary because Check() may evaluate len()/cap() calls (which trigger
// checkBuiltin → mark Useful) BEFORE LinkProviders is populated (dependency packages
// not yet loaded). Since Node.Check() caches Checked=true and skips re-evaluation,
// the providers are never marked useful at Check-time.
func (c *Compiler) markLinkProviders(node *parser.Node) {
	if node == nil {
		return
	}
	if fb, ok := node.Value.(*parser.FuncBlock); ok {
		for _, bf := range fb.BuildFlags {
			if bf.Type == "link" && bf.Link != "" && !bf.Ignore {
				// Only mark if actually needed by len/cap/strings calls
				if c.stringSyms != nil && c.stringSyms[bf.Link] {
					fb.Useful = true
				}
			}
		}
	}
	for _, ch := range node.Children {
		c.markLinkProviders(ch)
	}
}

// markRCFuncs pre-pass: mark memory.rcDec/rcInc/rcGet as useful.
// These are called from GC emit codegen but never appear in user source,
// so they aren't marked Useful during Check.
func (c *Compiler) markRCFuncs(node *parser.Node) {
	// malloc/free/realloc 由 emitMalloc/emitFree/emitRealloc 合成调用（字符串拼接、
	// 列表分配等路径），同样不出现在用户源码里，必须预标记 Useful
	rcNames := map[string]bool{"rcDec": true, "rcInc": true, "rcGet": true, "mallocRC": true, "freeRC": true, "rcIsOne": true, "rcAdd": true, "rcSub": true, "rcTryRelease": true, "rcSet": true, "trackAlloc": true, "trackFree": true, "reportLeaks": true, "reportAllocCount": true, "reportFreeCount": true, "resetLeakTracker": true, "malloc": true, "realloc": true, "free": true, "freeSlot": true, "freeRCSlot": true}
	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if n == nil {
			return
		}
		if fb, ok := n.Value.(*parser.FuncBlock); ok && fb.Name != nil {
			if rcNames[fb.Name.Last()] && len(fb.Name) >= 2 && fb.Name[0].IsPkgPath {
				fb.Useful = true
			}
		}
		for _, ch := range n.Children {
			walk(ch)
		}
	}
	walk(node)
}

func (c *Compiler) initializeContext() {
	if c.Ctx == nil {
		c.Ctx = context.NewContext()
	}
	if c.Ctx.Arch == nil {
		c.Ctx.Arch = NewArch(GoArch, c.Ctx)
	}
	// Set monomorphize callback so expression compiler can trigger specialization
	c.Ctx.MonomorphizeCall = func(call *parser.CallBlock) string {
		if IsGenericFunction(call.Func) {
			return c.MonomorphizeIfNeeded(call)
		}
		return ""
	}
	if c.funcNodeMap == nil {
		c.funcNodeMap = make(map[*parser.FuncBlock]*parser.Node)
	}
}

func (c *Compiler) compileRoot(node *parser.Node, code string) string {
	// 只在最外层生成一次 section .text
	if c.RootGenerated {
		return ""
	}
	// 只在根节点（没有Father）生成
	if node.Father != nil {
		return ""
	}
	c.RootGenerated = true
	var globals string
	if c.Ctx.Exports != nil {
		for exportName := range c.Ctx.Exports {
			globals += "global " + exportName + "\n"
		}
		globals += "\n"
	}
	return globals + c.generateGlobalSection(node) + "section .text\nglobal _start\n\n"
}

// generateGlobalSection 输出全局变量的 .bss/.data 声明
func (c *Compiler) generateGlobalSection(node *parser.Node) string {
	var bssCode, dataCode string
	for _, ch := range node.Children {
		if ch.BuildIgnored {
			continue
		}
		vb, ok := ch.Value.(*parser.VarBlock)
		if !ok || !vb.IsGlobal || !vb.IsDefine {
			continue
		}
		name := "__global_" + utils.ToNASMName(vb.Name.String())
		size := vb.Type.Size()
		if os.Getenv("CUTE_DEBUG_GLOB") != "" {
			valDesc := "<nil>"
			if vb.Value != nil {
				valDesc = fmt.Sprintf("Num=%v IsConstExp=%v", vb.Value.Num, vb.Value.IsConst())
			}
			fmt.Fprintf(os.Stderr, "[GLOB] %s size=%d IsConst=%v IsDefine=%v IsGlobal=%v Value=%s\n",
				vb.Name.String(), size, vb.IsConst, vb.IsDefine, vb.IsGlobal, valDesc)
		}
		// 字符串（ptr+len+cap=24 字节）延后到 generateDataSection 生成（需字符串字面量）
		if typeSys.CheckKind(vb.Type, "string") {
			c.Ctx.GlobalStrings = append(c.Ctx.GlobalStrings, vb)
			continue
		}
		// 聚合类型（list/struct）：按 Size 预留 .bss 槽（未初始化），
		// 运行期由赋值语句填充三槽/字段
		if size != 4 && size != 8 {
			bssCode += "    " + name + " resb " + strconv.Itoa(size) + "\n"
			continue
		}
		// 可折叠字面量初始化值放入 .data（const 或带字面量初值的全局都应从初值开始），
		// 其余放 .bss；注意不能只看 vb.IsConst：包内 const 的 VarBlock 标志可能缺失，
		// 而有确实可折叠初值的非 const 全局放进 .bss(零值) 同样是错的
		if vb.Value != nil && vb.Value.IsConst() {
			val := int64(vb.Value.Num)
			if size == 8 {
				dataCode += "    " + name + " dq " + strconv.FormatInt(val, 10) + "\n"
			} else {
				dataCode += "    " + name + " dd " + strconv.FormatInt(val, 10) + "\n"
			}
		} else {
			if size == 8 {
				bssCode += "    " + name + " resq 1\n"
			} else {
				bssCode += "    " + name + " resd 1\n"
			}
		}
	}
	code := ""
	if bssCode != "" {
		code += "section .bss\n" + bssCode
	}
	if dataCode != "" {
		code += "section .data\n" + dataCode
	}
	return code
}

func (c *Compiler) compileChildren(node *parser.Node, code string) string {
	for i := 0; i < len(node.Children); i++ {
		n := node.Children[i]
		if n.Ignore || n.BuildIgnored {
			continue
		}
		c.Ctx.Now = n
		if i > 0 && i%100 == 0 {
			fmt.Fprintf(os.Stderr, "[compileChildren] i=%d/%d\n", i, len(node.Children))
		}
		code += c.compileChild(n)
	}
	return code
}

func (c *Compiler) compileChild(n *parser.Node) string {
	switch v := n.Value.(type) {
	case *parser.FuncBlock:
		for _, buildFlag := range v.BuildFlags {
			if buildFlag.Ignore {
				return ""
			}
		}
		// 泛型原体只作为单态化模板存在，不应直接发射：参数/局部变量仍是
		// TypeParam.Size()==-1，会生成没有宽度前缀的非法内存操作数。
		// 真正被调用的泛型会由 MonomorphizeIfNeeded 生成 TypeParams=nil 的特化节点。
		if len(v.TypeParams) > 0 {
			return ""
		}
		if !v.Useful && v.Name.String() != "main" {
			return ""
		}
		return c.compileFuncBlock(n)
	case *parser.IfBlock:
		return c.compileIfBlock(n)
	case *parser.ReturnBlock:
		return c.compileReturnBlock(n)
	case *parser.VarBlock:
		return c.compileVarBlock(n)
	case *parser.CallBlock:
		return c.compileCallBlock(n)
	case *parser.Expression:
		return c.compileExprBlock(n)
	case *parser.ForBlock:
		if n.Value.(*parser.ForBlock).Range != nil {
			return c.compileForRangeBlock(n)
		}
		return c.compileForBlock(n)
	case *parser.BreakBlock:
		return c.compileBreakBlock(n)
	case *parser.ContinueBlock:
		return c.compileContinueBlock(n)
	case *parser.FallthroughBlock:
		// fallthrough 本身不生成代码；是否跳到下一个 case 由
		// compileSwitchBlock 根据 case 末尾节点决定。
		return ""
	case *parser.ElseBlock:
		// 独立作用域块：零槽 → 顺序编译 → 块尾释放（同 then/else 块形态）
		code := c.emitGCZeroSlots(n, c.blockFreesOf(n))
		code += c.Compile(n)
		code += c.emitBlockFrees(n)
		return code
	case *parser.SwitchBlock:
		return c.compileSwitchBlock(n)
	case *parser.CaseBlock:
		// CaseBlock 本身不生成代码，body 语句由 compileSwitchBlock 编译
		return ""
	case *parser.DeferBlock:
		return c.compileDeferBlock(n)
	case *parser.TypeBlock:
		return c.compileTypeBlock(n)
	case *parser.Build:
		return c.CompileBuild(n)
	default:
		return ""
	}
}

func (c *Compiler) compileFuncBlock(n *parser.Node) string {
	funcBlock := n.Value.(*parser.FuncBlock)
	if len(funcBlock.TypeParams) > 0 {
		return ""
	}
	if !funcBlock.Useful && funcBlock.Name.String() != "main" {
		return ""
	}
	// Record FuncBlock → Node mapping for cross-package monomorphization lookup
	if c.funcNodeMap != nil {
		c.funcNodeMap[funcBlock] = n
	}
	// 变量栈设置和栈大小计算现在由 arch.Pro/Epilogue 处理
	return c.funcHandle(funcBlock, n)
}

func (c *Compiler) compileIfBlock(n *parser.Node) string {
	ifBlock := n.Value.(*parser.IfBlock)
	c.Ctx.IfCount++
	label := fmt.Sprintf("if_%d", c.Ctx.IfCount)

	var code string
	var endLabel string
	if ifBlock.Else {
		endLabel = "else_" + label
	} else {
		endLabel = "end_" + label
	}

	// 进入分支前清零 then/else 块将释放的局部槽：条件为假或零次执行时，
	// 块尾 freeSlot 不能看到未初始化的栈槽。
	code += c.emitGCZeroSlots(n, c.blockFreesOf(n))
	if ifBlock.ElseBlock != nil {
		code += c.emitGCZeroSlots(ifBlock.ElseBlock, c.blockFreesOf(ifBlock.ElseBlock))
	}

	// 编译条件表达式，生成比较和跳转指令
	// P21-||:第三参 = if 体标签(label,真目标)——|| 链任一叶子为真即跳体;
	// 旧实现只有假目标(jumpLabel),|| 被错误发成 && 形态(每叶 jz/jne-else 且末项蒸发)
	condPlan := c.prepareScratchFrees(gc.CondFreesForNode(c.currentFuncKey, n), "cond free")
	if condPlan.code != "" {
		// 条件表达式里的拥有型临时对象在两条路径上各自释放：
		// false → 清理后跳 else/end；true → 清理后进 if 体。
		falseLabel := c.nextCondLabel("cond_false_")
		trueLabel := c.nextCondLabel("cond_true_")
		code += c.compileCondition(ifBlock.Condition, falseLabel, trueLabel)
		c.releaseScratchFrees(condPlan)
		// 比较/单表达式条件真路径是直落，需跳过紧随其后的 false 清理块；
		// || 链的真跳转直接落到 trueLabel，不受影响。
		code += utils.Format("jmp " + trueLabel)
		code += utils.Format(falseLabel + ":")
		code += condPlan.code
		if ifBlock.Else {
			code += utils.Format("jmp else_" + label)
		} else {
			code += utils.Format("jmp end_" + label)
		}
		code += utils.Format(trueLabel + ":")
		code += condPlan.code
	} else {
		code += c.compileCondition(ifBlock.Condition, endLabel, label)
	}

	code += utils.Format(label+":") + c.Compile(n)
	// if 体块级释放
	code += c.emitBlockFrees(n)

	if ifBlock.Else {
		code += utils.Format("jmp end_" + label)
		code += c.compileElseBlock(ifBlock, label)
	}
	code += utils.Format("end_" + label + ":")
	return code
}

// compileCondition 编译条件表达式，生成比较和跳转指令
// jumpLabel = 假目标(if 的 else/end);trueLabel = 真目标(if 体 == label)
func (c *Compiler) compileCondition(cond *parser.Expression, jumpLabel string, trueLabel string) string {
	if cond == nil {
		return ""
	}

	var code string

	// 根据架构选择寄存器名
	scratchReg1 := "EAX"
	if c.Ctx.Is64Bit {
		scratchReg1 = "RAX"
	}

	// 处理比较运算
	switch cond.Separator {
	case "==", "!=", "<", ">", "<=", ">=":

		// 32 位模式下 64 位类型比较需要专用双寄存器路径
		if !c.Ctx.Is64Bit && cond.Left != nil && c.Ctx.Arch.Is64Type(cond.Left.Type) {
			return c.Ctx.Arch.Compare64(cond, jumpLabel)
		}

		// P21-||:比较主体抽出 emitCompareOps,跳转向保持旧假向语义
		opFalse, _ := c.compareJumpOps(cond)
		return c.emitCompareOps(cond) + utils.Format(opFalse+" "+jumpLabel)
	case "||":
		// P21-|| 修复:或链真目标短路——任一叶子为真即跳 if 体。
		// 旧实现把 || 发成 && 形态(每叶 jz/jne-else,叶间语义为 AND 且末项蒸发):
		// test/mp_map S6.2 *pk==50||60||70 曾被发成仅 50/60 两 cmp 的 AND 链
		return c.compileOrChain(cond, trueLabel, jumpLabel, true)
	case "&&":
		// 处理逻辑与:任一假 → 假目标短路。
		// 左侧"真"只代表还需评估右侧，不能直接外传 trueLabel:
		// (a||b)&&c 中 a 为真若直接跳 if 体，就跳过了 c。
		// 故左侧的 || 真目标一律落在局部 mid 标签上，mid 之后再编右侧。
		if cond.Left != nil {
			mid := c.nextCondLabel("and_mid_")
			code += c.compileCondition(cond.Left, jumpLabel, mid)
			code += utils.Format(mid + ":")
		}
		if cond.Right != nil {
			code += c.compileCondition(cond.Right, jumpLabel, trueLabel)
		}
	default:
		// 单个表达式，编译到 scratchReg1 并测试是否为 0
		code += c.Ctx.Arch.Exp(cond, scratchReg1, "condition")
		code += utils.Format("test " + scratchReg1 + ", " + scratchReg1)
		code += utils.Format("jz " + jumpLabel) // 为 0 则跳转
	}

	return code
}

// compareJumpOps 计算比较节点双向跳转助记:opFalse(假向,旧 && 语义同)/opTrue(真向,|| 链用)
func (c *Compiler) compareJumpOps(cond *parser.Expression) (opFalse string, opTrue string) {
	// 判断是否为无符号类型比较
	isUnsigned := false
	if cond.Left != nil && cond.Left.Type != nil {
		isUnsigned = typeSys.CheckKind(cond.Left.Type, "uint")
	} else if cond.Right != nil && cond.Right.Type != nil {
		isUnsigned = typeSys.CheckKind(cond.Right.Type, "uint")
	}
	switch cond.Separator {
	case "==":
		return "jne", "je" // 相等则不跳 / 相等则跳
	case "!=":
		return "je", "jne" // 不等则不跳 / 不等则跳
	case "<":
		if isUnsigned {
			return "jnb", "jb" // 无符号:不低于则跳 / 低于则跳
		}
		return "jge", "jl" // 小于则不跳 / 小于则跳
	case ">":
		if isUnsigned {
			return "jbe", "ja" // 无符号:不高于则跳 / 高于则跳
		}
		return "jle", "jg" // 大于则不跳 / 大于则跳
	case "<=":
		if isUnsigned {
			return "jnbe", "jbe" // 无符号:高于则跳(条件为假) / 不高于则跳
		}
		return "jg", "jle" // 小于等于则不跳 / 小于等于则跳
	case ">=":
		if isUnsigned {
			return "jb", "jae" // 无符号:低于则跳(条件为假) / 不低于则跳
		}
		return "jl", "jge" // 大于等于则不跳 / 大于等于则跳
	}
	return "jne", "je"
}

// emitCompareOps 装载比较节点左右操作数并发射 cmp(不发跳转)。
// 序列与旧 compare-case 逐行一致:左装载→callee-save 保护→右装载→保护恢复→cmp
func (c *Compiler) emitCompareOps(cond *parser.Expression) string {
	scratchReg1 := "EAX"
	scratchReg2 := "ECX"
	if c.Ctx.Is64Bit {
		scratchReg1 = "RAX"
		scratchReg2 = "RCX"
	}
	var code string

	// 编译左右操作数到寄存器
	leftSavedReg := ""
	if cond.Left != nil {
		code += c.Ctx.Arch.Exp(cond.Left, scratchReg1, "left operand")
		// 用空闲 callee-save 寄存器保存左操作数（跨右子函数调用保持）。
		// 不能压栈：被调函数参数槽 [rbp+16]（=调用指令时的 rsp）落在调用者
		// 栈顶，会覆盖压栈保存的左操作数（如 load8(a) != load8(b) 这类左右都
		// 是函数调用时，右调用会覆盖左操作数的栈保存）。
		leftSavedReg = c.Ctx.Reg.AllocCalleeSaveBind(cond.Left, c.Ctx.Arch.CalleeSaveRegs(), c.Ctx.Arch.CalleeSaveReg())
		if leftSavedReg != "" {
			code += utils.Format("mov " + leftSavedReg + ", " + scratchReg1 + "; 保存左操作数到callee-save")
		} else {
			code += utils.Format("push " + scratchReg1 + "; 保护左操作数\n")
		}
	}
	if cond.Right != nil {
		code += c.Ctx.Arch.Exp(cond.Right, scratchReg2, "right operand")
	}
	if cond.Left != nil {
		if leftSavedReg != "" {
			code += utils.Format("mov " + scratchReg1 + ", " + leftSavedReg + "; 恢复左操作数")
			c.Ctx.Reg.Free(cond.Left)
		} else {
			code += utils.Format("pop " + scratchReg1 + "; 恢复左操作数\n")
		}
	}

	// 生成比较指令
	code += utils.Format("cmp " + scratchReg1 + ", " + scratchReg2)
	return code
}

// compileOrChain 摊平 || 链(左结合,任一侧是 || 均下钻):
// 每叶为真即跳 trueLabel(if 体);非末叶假直接落下一叶;末叶假补跳 falseLabel(else/end)
func (c *Compiler) compileOrChain(node *parser.Expression, trueLabel string, falseLabel string, isLast bool) string {
	if node == nil {
		return ""
	}
	var code string
	if node.Left != nil && node.Left.Separator == "||" {
		code += c.compileOrChain(node.Left, trueLabel, falseLabel, false)
	} else if node.Left != nil {
		code += c.compileOrLeaf(node.Left, trueLabel, falseLabel, false)
	}
	if node.Right != nil && node.Right.Separator == "||" {
		code += c.compileOrChain(node.Right, trueLabel, falseLabel, isLast)
	} else if node.Right != nil {
		code += c.compileOrLeaf(node.Right, trueLabel, falseLabel, isLast)
	}
	return code
}

// compileOrLeaf 发射 || 链单个叶子:比较叶复用 emitCompareOps 真向跳;
// 算式叶 Exp+test;&& 子叶经 compileCondition 递归(全真→跳 trueLabel)
func (c *Compiler) compileOrLeaf(term *parser.Expression, trueLabel string, falseLabel string, isLast bool) string {
	if term == nil {
		return ""
	}
	var code string
	switch term.Separator {
	case "==", "!=", "<", ">", "<=", ">=":
		// 比较叶:operand 序列 + 真向跳;末叶补假向跳(否则假将直接落进 if 体)
		if !c.Ctx.Is64Bit && term.Left != nil && c.Ctx.Arch.Is64Type(term.Left.Type) {
			// 32 位下 64 位类型:沿用假向路径(无 || 短路),不扩基线
			return c.Ctx.Arch.Compare64(term, falseLabel)
		}
		_, opTrue := c.compareJumpOps(term)
		code += c.emitCompareOps(term)
		code += utils.Format(opTrue + " " + trueLabel)
		if isLast {
			opFalse, _ := c.compareJumpOps(term)
			code += utils.Format(opFalse + " " + falseLabel)
		}
	case "&&":
		// && 子叶:&& 完整成立 = 该 || 项真 → 跳 trueLabel;
		// && 内部假 → 跳局部失败标(andFail)后自然落下接下一叶/(末叶)假跳
		andFail := c.nextCondLabel("or_and_")
		code += c.compileCondition(term, andFail, trueLabel)
		code += utils.Format("jmp " + trueLabel)
		code += utils.Format(andFail + ":")
		if isLast {
			// 到达 andFail 即 && 整体为假；必须无条件跳假目标。
			// 不能依赖标志位:比较叶的假向跳转(ZF=0)与算式叶的 jz(ZF=1)标志相反
			code += utils.Format("jmp " + falseLabel)
		}
	default:
		// 算式叶(变量/调用/一元):装载→test;真跳 trueLabel,末叶假跳 falseLabel
		scratchReg1 := "EAX"
		if c.Ctx.Is64Bit {
			scratchReg1 = "RAX"
		}
		code += c.Ctx.Arch.Exp(term, scratchReg1, "||-chain leaf")
		code += utils.Format("test " + scratchReg1 + ", " + scratchReg1)
		code += utils.Format("jnz " + trueLabel)
		if isLast {
			code += utils.Format("jz " + falseLabel)
		}
	}
	return code
}

func (c *Compiler) compileElseBlock(ifBlock *parser.IfBlock, label string) string {
	var code string
	code += utils.Format("else_" + label + ":")
	if ifBlock.ElseBlock != nil {
		if e, ok := ifBlock.ElseBlock.Value.(*parser.ElseBlock); ok && e.IfCondition != nil {
			code += c.Ctx.Arch.Exp(e.IfCondition, "end_"+label, "")
		}
		code += c.Compile(ifBlock.ElseBlock)
		// else 块级释放：与 then 分支对称，释放 else 体内声明的堆对象。
		code += c.emitBlockFrees(ifBlock.ElseBlock)
	}
	return code
}

func (c *Compiler) compileSwitchBlock(n *parser.Node) string {
	switchBlock := n.Value.(*parser.SwitchBlock)
	c.Ctx.SwitchCount++
	switchBlock.Offset = c.Ctx.SwitchCount
	label := fmt.Sprintf("switch_%d", switchBlock.Offset)
	endLabel := "switch_end_" + label

	// 根据架构选择寄存器名
	scratchReg1 := "EAX"
	scratchReg2 := "ECX"
	if c.Ctx.Is64Bit {
		scratchReg1 = "RAX"
		scratchReg2 = "RCX"
	}

	var code string

	// 编译 switch 目标表达式到寄存器
	if switchBlock.Target != nil {
		code += c.Ctx.Arch.Exp(switchBlock.Target, scratchReg1, "switch target")
	}

	// CaseBlock 节点在 n.Children 中，顺序即源码顺序。
	// 标签按源码顺序编号，default 不再特殊移到最后。
	caseNodes := make([]*parser.Node, 0, len(switchBlock.Cases))
	for _, child := range n.Children {
		if _, ok := child.Value.(*parser.CaseBlock); ok {
			caseNodes = append(caseNodes, child)
		}
	}

	// 先为每个 case 生成比较跳转
	defaultLabel := ""
	for i, child := range caseNodes {
		sc := child.Value.(*parser.CaseBlock)
		caseLabel := fmt.Sprintf("case_%s_%d", label, i)
		if sc.IsDefault {
			defaultLabel = caseLabel
			continue
		}
		for _, val := range sc.Values {
			// 编译 case 值到寄存器
			code += c.Ctx.Arch.Exp(val, scratchReg2, "case value")
			if switchBlock.Target == nil {
				// 无目标 switch：每个 case 值按布尔条件独立判断
				code += utils.Format("test " + scratchReg2 + ", " + scratchReg2)
				code += utils.Format("jnz " + caseLabel)
				continue
			}
			// 保存左操作数（如果有 callee-save 可用）
			leftSavedReg := c.Ctx.Reg.AllocCalleeSaveBind(val, c.Ctx.Arch.CalleeSaveRegs(), c.Ctx.Arch.CalleeSaveReg())
			if leftSavedReg != "" {
				code += utils.Format("mov " + leftSavedReg + ", " + scratchReg1 + "; 保存switch目标到callee-save")
			}
			code += utils.Format("cmp " + scratchReg1 + ", " + scratchReg2)
			if leftSavedReg != "" {
				code += utils.Format("mov " + scratchReg1 + ", " + leftSavedReg + "; 恢复switch目标")
				c.Ctx.Reg.Free(val)
			}
			code += utils.Format("je " + caseLabel)
		}
	}

	// 没有匹配的 case，跳转到 default 或 end
	if defaultLabel != "" {
		code += utils.Format("jmp " + defaultLabel)
	} else {
		code += utils.Format("jmp " + endLabel)
	}

	// 按源码顺序编译每个 case 的 body
	for i, child := range caseNodes {
		code += utils.Format(fmt.Sprintf("case_%s_%d:", label, i))

		hasFallthrough := false
		for _, stmt := range child.Children {
			if _, ok := stmt.Value.(*parser.FallthroughBlock); ok {
				hasFallthrough = true
				continue
			}
			code += c.compileChild(stmt)
		}

		if hasFallthrough && i+1 < len(caseNodes) {
			// fallthrough：直接进入下一个 case 的 body 标签。
			code += utils.Format(fmt.Sprintf("jmp case_%s_%d; fallthrough", label, i+1))
		} else {
			// 隐式 break：跳出 switch。最后一个 case 的 fallthrough
			// 已在 Parse 期报错，这里兜底跳出口。
			code += utils.Format("jmp " + endLabel)
		}
	}

	// 结束标签
	code += utils.Format(endLabel + ":")
	return code
}

func (c *Compiler) compileReturnBlock(n *parser.Node) string {
	ret := n.Value.(*parser.ReturnBlock)
	var code string

	// 执行所有延迟的函数调用（LIFO 顺序）
	deferCode := c.compileDeferCalls(n.Father)
	if deferCode != "" {
		code += deferCode
	}

	frees := gc.RetFreesForNode(c.currentFuncKey, n)
	if len(frees) == 0 || c.Ctx.RetScratchBase == 0 {
		// 生成返回代码
		code += c.Ctx.Arch.Return(ret)
		return code
	}

	is64 := c.Ctx.Arch.PointerSize() == 8
	slotSize := 4
	base := "ebp"
	retReg, hiReg := "EAX", "EDX"
	if is64 {
		slotSize = 8
		base = "rbp"
		retReg, hiReg = "RAX", "RDX"
	}

	if c.Ctx.RetScratchMap == nil {
		c.Ctx.RetScratchMap = make(map[*parser.CallBlock]int)
	}
	// 为每个 ret 临时对象分配 scratch 槽；Arch.Call 在内层调用返回后
	// 按此表把拥有型指针写入槽，外层调用返回后再统一释放。
	for i, rf := range frees {
		if rf.Call == nil {
			continue
		}
		c.Ctx.RetScratchMap[rf.Call] = c.Ctx.RetScratchBase + i*slotSize
	}

	// 1. 生成返回值（大值写入返回槽/隐藏参数，标量写入 RAX/EAX）
	code += c.Ctx.Arch.ReturnValue(ret)

	// 2. 先保存返回值寄存器：free 是普通调用，会破坏 caller-saved 寄存器
	code += utils.Format("push " + retReg + "; gc ret 保存返回值")
	code += utils.Format("push " + hiReg + "; gc ret 保存返回值")

	// 3. 逐个释放 scratch 槽。freeSlot 成功后清槽，天然幂等。
	nameParts := []parser.NamePart{{Name: "std_memory", IsPkgPath: true}, {Name: "freeSlot"}}
	freeFunc := &parser.FuncBlock{
		Name: parser.Name(nameParts),
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}
	freeCall := &parser.CallBlock{
		Name: freeFunc.Name,
		Func: freeFunc,
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}
	for i, rf := range frees {
		off := c.Ctx.RetScratchBase + i*slotSize
		code += utils.Format("; gc: ret free " + rf.VarName + " after=call:" + rf.Callee)
		if is64 {
			code += utils.Format("lea RDI, [" + base + strconv.Itoa(off) + "]")
			code += utils.Format("call " + freeFunc.MangledName())
		} else {
			code += utils.Format("lea eax, [" + base + strconv.Itoa(off) + "]")
			code += utils.Format("push eax")
			code += c.Ctx.Arch.Call(freeCall)
		}
	}

	// 4. 恢复返回值寄存器并跳转公共返回点
	code += utils.Format("pop " + hiReg + "; gc ret 恢复返回值")
	code += utils.Format("pop " + retReg + "; gc ret 恢复返回值")
	code += c.Ctx.Arch.ReturnJump()

	for _, rf := range frees {
		if rf.Call != nil {
			delete(c.Ctx.RetScratchMap, rf.Call)
		}
	}
	return code
}

func (c *Compiler) compileVarBlock(n *parser.Node) string {
	varBlock := n.Value.(*parser.VarBlock)
	if varBlock.IsGlobal && varBlock.IsDefine {
		return ""
	}
	// 覆盖赋值：旧对象唯一/未共享时，先 freeSlot(&x) 再写入新值。
	code := c.emitAssignFrees(n)
	// Multi-return destructuring: a, b := foo()
	if len(varBlock.MultiNames) > 0 {
		return code + c.Ctx.Arch.MultiVarDecl(varBlock)
	}
	return code + c.Ctx.Arch.VarDecl(varBlock)
}

// emitAssignFrees 生成覆盖赋值前的旧对象释放序列（freeSlot 成功后清槽）。
func (c *Compiler) emitAssignFrees(n *parser.Node) string {
	llr := gc.LLRResults[c.currentFuncKey]
	if llr == nil || llr.AssignFrees == nil {
		return ""
	}
	return c.emitSlotFrees(n, llr.AssignFrees[n], "assign free")
}

func (c *Compiler) compileCallBlock(n *parser.Node) string {
	callBlock := n.Value.(*parser.CallBlock)

	// 悬空调用惰性绑定（第四根因修复，与 exp.go leaf 同机制）
	if callBlock.Func == nil {
		cuteExp.BindDanglingCall(c.Ctx, callBlock)
	}

	// 检查是否为泛型函数调用：单态化生成/复用特化副本，MonomorphizeIfNeeded
	// 已把 Func 指向特化 FuncBlock（Name/MangledOverride = 特化标签），
	// arch.Call 直接发调用（Func 必须非 nil，否则 isContainerRet/大值装载全废）。
	if IsGenericFunction(callBlock.Func) {
		c.MonomorphizeIfNeeded(callBlock)
	}

	return c.Ctx.Arch.Call(callBlock)
}

func (c *Compiler) compileExprBlock(n *parser.Node) string {
	exp := n.Value.(*parser.Expression)
	if exp.Separator == "[]=" {
		return c.Ctx.Arch.Exp(exp, "", "list index assignment")
	}
	// 多段名赋值（p1.x = 3、self.x += dx 等）：表达式里携带完整 VarBlock，
	// 转用变量声明路径生成正确的目标地址
	if exp.Var != nil && exp.Var.Value != nil {
		return c.emitAssignFrees(n) + c.Ctx.Arch.VarDecl(exp.Var)
	}
	return c.Ctx.Arch.Exp(exp, "", "expression statement")
}

func (c *Compiler) compileForBlock(n *parser.Node) string {
	forBlock := n.Value.(*parser.ForBlock)
	var code string
	// 进入循环前清零循环体将释放的局部槽：零次迭代时 for_end 后的
	// 循环出口释放不能看到未初始化的栈槽。
	code += c.emitGCZeroSlots(n, c.blockFreesOf(n))

	condPlan := c.prepareScratchFrees(gc.CondFreesForNode(c.currentFuncKey, n), "cond free")
	incrPlan := c.prepareScratchFrees(gc.IncrFreesForNode(c.currentFuncKey, n), "incr free")
	if condPlan.code != "" {
		// 条件每轮求值：true 路径清理后进循环体，false 路径清理后直接
		// 跳到循环出口（跳过增量）。tag 与 for_end 标签由 ForBeginCond
		// 设定的 Offset 生成。
		trueLabel := c.nextCondLabel("for_cond_true_")
		falseLabel := c.nextCondLabel("for_cond_false_")
		code += c.Ctx.Arch.ForBeginCond(forBlock, falseLabel, trueLabel)
		c.releaseScratchFrees(condPlan)
		// 条件真路径直落，跳过 false 清理块后再进循环体。
		code += utils.Format("jmp " + trueLabel)
		code += utils.Format(falseLabel + ":")
		code += condPlan.code
		code += utils.Format("jmp for_" + strconv.Itoa(forBlock.Offset) + "_end; for条件假路径")
		code += utils.Format(trueLabel + ":")
		code += condPlan.code
	} else {
		c.releaseScratchFrees(condPlan)
		code += c.Ctx.Arch.ForBegin(forBlock)
	}

	code += c.Compile(n)
	// continue 落点：先执行块级释放，再进入增量表达式。
	code += utils.Format("for_" + strconv.Itoa(forBlock.Offset) + "_continue:")
	// 块级释放：在循环体末尾释放该块内分配的对象
	code += c.emitBlockFrees(n)
	code += c.Ctx.Arch.ForEnd(forBlock, incrPlan.code)
	c.releaseScratchFrees(incrPlan)
	// 循环出口释放：覆盖 break 跳过 body 尾释放的路径；正常迭代已清槽，
	// freeSlot 幂等跳过。
	code += c.emitLoopExitFrees(n)
	return code
}

// compileForRangeBlock 编译 for range 循环
func (c *Compiler) compileForRangeBlock(n *parser.Node) string {
	forBlock := n.Value.(*parser.ForBlock)
	if forBlock.Range == nil || len(forBlock.RangeNames) == 0 {
		return ""
	}

	var code string
	ps := c.Ctx.Arch.PointerSize()
	ln := c.Ctx.Arch.LengthName(ps)
	frame := c.Ctx.Arch.FramePtr()
	is64 := c.Ctx.Is64Bit

	// 寄存器名
	var rax, rdx, rbx string
	if is64 {
		rax, rdx, rbx = "RAX", "RDX", "RBX"
	} else {
		rax, rdx, rbx = "EAX", "EDX", "EBX"
	}

	// 1. 编译 range 表达式（list/string 的地址）
	// list 在栈上的布局: [ptr, len, cap]，共 3 × ps 字节
	code += c.Ctx.Arch.Exp(forBlock.Range, rax, "range target")

	// 2. 为循环体创建标签
	c.Ctx.ForCount++
	forBlock.Offset = c.Ctx.ForCount
	forLabel := "for_range_" + strconv.Itoa(forBlock.Offset)
	// break 统一跳到 for_<n>_end（compileBreakBlock），range 循环必须使用
	// 同一出口标签，否则 range + break 会引用未定义标签。
	endLabel := "for_" + strconv.Itoa(forBlock.Offset) + "_end"

	// 3. 分配临时空间存储 range 目标信息（ptr, len）
	// 在函数开头已经分配了空间，这里使用临时寄存器
	// 我们用 RBX 存储 ptr，RDX 存储 len

	// 从 list 结构加载 ptr 和 len
	// list 变量的栈地址: 用 exp 计算得到的是 ptr 值（list 的第一个字段）
	// 但我们需要访问 list 的 ptr 和 len 字段
	// 对于栈上的 list 变量，其布局是 [ptr, len, cap]
	// exp 对 list 变量返回的是 ptr 值（第一个字段）
	// 我们需要重新计算地址

	// 方案：使用 range 变量的 VarBlock 来获取地址
	if forBlock.Range.Var != nil {
		// 变量引用：加载其栈地址
		vb := forBlock.Range.Var
		var baseAddr string
		if vb.IsGlobal {
			baseAddr = "[rel __global_" + utils.ToNASMName(vb.Name.String()) + "]"
		} else {
			off := vb.Offset
			if off < 0 {
				baseAddr = "[" + frame + strconv.Itoa(off) + "]"
			} else if off == 0 {
				baseAddr = "[" + frame + "]"
			} else {
				baseAddr = "[" + frame + "+" + strconv.Itoa(off) + "]"
			}
		}
		// 加载 list 的 ptr 字段（offset 0）
		code += utils.Format("mov " + rbx + ", " + ln + " " + baseAddr + "; range ptr")
		// 加载 list 的 len 字段（offset ps）
		code += utils.Format("mov " + rdx + ", " + ln + " " + baseAddr[:len(baseAddr)-1] + "+" + strconv.Itoa(ps) + "]; range len")
	} else {
		// 表达式计算：假设返回的是 list 结构的首地址
		// 对于复杂表达式，需要先计算地址，然后从该地址加载 ptr 和 len
		// 暂时使用简化方案：range 表达式结果在 RAX 中，假设是 list 的 ptr
		code += utils.Format("mov " + rbx + ", " + rax + "; range ptr")
		// len 需要从 ptr-2*ps 位置读取（因为 list 结构是 [ptr, len, cap]，ptr 指向第一个元素）
		// 但实际上 exp 对 list 变量返回的是 ptr 字段的值
		// 我们需要原始地址来读取 len，这比较复杂
		// 暂时假设 range 只用于简单变量引用
		code += utils.Format("; TODO: complex range expression support")
		code += utils.Format("xor " + rdx + ", " + rdx + "; len=0 for now")
	}

	// 4. 初始化索引变量
	indexVar := forBlock.RangeNames[0]
	// 声明索引变量（在函数开头已声明，这里赋值为 0）
	code += utils.Format("mov " + ln + " [" + frame + strconv.Itoa(indexVar.Offset) + "], 0; range index = 0")

	// 5. 循环开始前清零循环体将释放的局部槽（零次迭代时出口释放需要）。
	code += c.emitGCZeroSlots(n, c.blockFreesOf(n))
	code += utils.Format("")
	code += utils.Format(forLabel + ": ; for range 循环开始")

	// 6. 检查索引 < len
	// 加载当前索引
	code += utils.Format("mov " + rax + ", " + ln + " [" + frame + strconv.Itoa(indexVar.Offset) + "]; 加载索引")
	// 比较索引和 len
	code += utils.Format("cmp " + rax + ", " + rdx + "; 索引 vs len")
	code += utils.Format("jge " + endLabel + "; 索引 >= len 则退出")

	// 7. 如果有第二个变量（value），加载 list[index]
	if len(forBlock.RangeNames) > 1 {
		valueVar := forBlock.RangeNames[1]
		elemSize := 8 // 默认元素大小
		if forBlock.Range.Type != nil {
			if lt, ok := forBlock.Range.Type.(*typeSys.ListType); ok {
				if lt.Elem() != nil {
					elemSize = lt.Elem().Size()
				}
			}
		}
		// 计算元素地址: ptr + index * elemSize
		code += utils.Format("imul " + rax + ", " + strconv.Itoa(elemSize) + "; index * elemSize")
		code += utils.Format("add " + rax + ", " + rbx + "; ptr + offset")
		// 加载元素
		code += utils.Format("mov " + rax + ", " + ln + " [" + rax + "]; 加载 list[index]")
		// 存储到 value 变量
		code += utils.Format("mov " + ln + " [" + frame + strconv.Itoa(valueVar.Offset) + "], " + rax + "; 存储 value")
	}

	// 8. 编译循环体
	code += c.Compile(n)
	// continue 落点：先执行块级释放，再做索引自增。
	code += utils.Format("for_" + strconv.Itoa(forBlock.Offset) + "_continue:")
	// 块级释放：在循环体末尾释放该块内分配的对象
	code += c.emitBlockFrees(n)

	// 9. 递增索引
	code += utils.Format("mov " + rax + ", " + ln + " [" + frame + strconv.Itoa(indexVar.Offset) + "]; 加载索引")
	code += utils.Format("add " + rax + ", 1; index++")
	code += utils.Format("mov " + ln + " [" + frame + strconv.Itoa(indexVar.Offset) + "], " + rax + "; 存储索引")

	// 10. 跳回循环开始
	code += utils.Format("jmp " + forLabel + "; 继续循环")

	// 11. 循环结束
	code += utils.Format(endLabel + ": ; for range 循环结束")
	// 循环出口释放：覆盖 break 跳过 body 尾释放的路径。
	code += c.emitLoopExitFrees(n)

	return code
}

func (c *Compiler) compileBreakBlock(n *parser.Node) string {
	breakBlock := n.Value.(*parser.BreakBlock)
	seen := 0
	for current := n.Father; current != nil; current = current.Father {
		switch v := current.Value.(type) {
		case *parser.ForBlock:
			seen++
			if seen == breakBlock.Level {
				return utils.Format("jmp for_" + strconv.Itoa(v.Offset) + "_end")
			}
		case *parser.SwitchBlock:
			seen++
			if seen == breakBlock.Level {
				return utils.Format("jmp switch_end_switch_" + strconv.Itoa(v.Offset))
			}
		}
	}
	return "; break: no enclosing loop/switch at level " + fmt.Sprintf("%d", breakBlock.Level) + "\n"
}

// compileContinueBlock 生成 continue 跳转。Go 语义：只统计 for 循环，
// switch 不构成 continue 目标；目标标签位于循环体释放之后、增量之前。
func (c *Compiler) compileContinueBlock(n *parser.Node) string {
	continueBlock := n.Value.(*parser.ContinueBlock)
	seen := 0
	for current := n.Father; current != nil; current = current.Father {
		if fb, ok := current.Value.(*parser.ForBlock); ok {
			seen++
			if seen == continueBlock.Level {
				return utils.Format("jmp for_" + strconv.Itoa(fb.Offset) + "_continue")
			}
		}
	}
	return "; continue: no enclosing loop at level " + fmt.Sprintf("%d", continueBlock.Level) + "\n"
}

func (c *Compiler) compileTypeBlock(n *parser.Node) string {
	return ""
}

func (c *Compiler) compileRootTail(node *parser.Node) string {
	if node.Father == nil {
		var code string
		// Emit extern declarations for build ext / build asm external calls
		if c.Ctx.Externs != nil {
			for extName := range c.Ctx.Externs {
				code += "extern " + extName + "\n"
			}
			code += "\n"
		}
		// Emit export alias labels (after all functions, jumps to function entry)
		if c.Ctx.Exports != nil {
			for exportName, funcName := range c.Ctx.Exports {
				code += exportName + ":\n"
				code += "    jmp " + funcName + "\n"
			}
			code += "\n"
		}
		if c.hasMainFunction(node) {
			code += c.generateStartEntry()
		}
		// 运行时辅助：边界检查 panic
		code += c.generatePanicOOB()
		// 运行时辅助：memmove(dst, src, n)
		code += c.generateMemmove()
		code += c.generateDataSection()
		code += c.CompileVtableSection() // emit vtable data for interface dispatch
		return code
	}
	return ""
}

func (c *Compiler) generateDataSection() string {
	if len(c.Ctx.StringConsts) == 0 && len(c.Ctx.GlobalStrings) == 0 {
		return ""
	}
	// 先为全局 string 变量的初始值分配字面量 label，确保 db 一并输出
	for _, vb := range c.Ctx.GlobalStrings {
		if vb.Value != nil && vb.Value.IsConst() && vb.Value.StringVal != "" {
			c.getStringLabel(vb.Value.StringVal)
		}
	}
	code := "\nsection .data\n"
	// 边界检查错误信息
	code += "    _oob_msg db \"index out of range\", 10\n"
	code += "    _oob_msg_len equ $ - _oob_msg\n"
	for val, label := range c.Ctx.StringConsts {
		escaped := strings.ReplaceAll(val, `\`, `\\`)
		escaped = strings.ReplaceAll(escaped, "`", "\\`")
		escaped = strings.ReplaceAll(escaped, "\"", `\"`)
		escaped = strings.ReplaceAll(escaped, "\n", `\n`)
		escaped = strings.ReplaceAll(escaped, "\t", `\t`)
		escaped = strings.ReplaceAll(escaped, "\r", `\r`)
		// NASM 的双引号字符串不支持反斜杠转义；用反引号字符串承载转义。
		code += fmt.Sprintf("    %s db `%s`, 0\n", label, escaped)
		code += fmt.Sprintf("    %s_len equ $ - %s\n", label, label)
	}
	// 全局 string 变量：ptr/len/cap 三槽，槽宽随架构指针大小（x86 为 dd）
	dq := "dq"
	if c.Ctx.Arch.PointerSize() == 4 {
		dq = "dd"
	}
	for _, vb := range c.Ctx.GlobalStrings {
		name := "__global_" + utils.ToNASMName(vb.Name.String())
		var strVal string
		if vb.Value != nil && vb.Value.IsConst() && vb.Value.StringVal != "" {
			strVal = vb.Value.StringVal
		}
		if strVal == "" {
			code += "    " + name + " " + dq + " 0\n    " + name + "_len " + dq + " 0\n    " + name + "_cap " + dq + " 0\n"
			continue
		}
		label := c.getStringLabel(strVal)
		code += fmt.Sprintf("    %s %s %s\n", name, dq, label)
		code += fmt.Sprintf("    %s_len %s %d\n", name, dq, len(strVal))
		code += fmt.Sprintf("    %s_cap %s %d\n", name, dq, len(strVal))
	}
	return code
}

func (c *Compiler) getStringLabel(val string) string {
	if label, ok := c.Ctx.StringConsts[val]; ok {
		return label
	}
	c.Ctx.StrCount++
	label := "str_" + strconv.Itoa(c.Ctx.StrCount)
	c.Ctx.StringConsts[val] = label
	return label
}

func (c *Compiler) hasMainFunction(node *parser.Node) bool {
	for _, ch := range node.Children {
		if ch.BuildIgnored {
			continue
		}
		if fb, ok := ch.Value.(*parser.FuncBlock); ok {
			ignored := false
			for _, bf := range fb.BuildFlags {
				if bf.Ignore {
					ignored = true
					break
				}
			}
			if !ignored && fb.Name.String() == "main" {
				return true
			}
		}
	}
	return false
}

func (c *Compiler) generateStartEntry() string {
	var code string
	code += utils.Format("; ==============================")
	code += utils.Format("; 程序入口点 (ELF入口)")
	code += utils.Format("_start:")
	utils.Count++
	code += utils.Format("call main")
	if c.Ctx.Is64Bit {
		code += utils.Format("mov rdi, rax")
		code += utils.Format("mov rax, 60")
		code += utils.Format("syscall\n")
	} else {
		code += utils.Format("mov ebx, eax")
		code += utils.Format("mov eax, 1")
		code += utils.Format("int 0x80\n")
	}
	utils.Count--
	return code
}

// generatePanicOOB 生成边界检查 panic 运行时辅助函数
// 签名：void _panic_index_oob(int index)
// 行为：打印 "index out of range" 到 stderr，然后 exit(1)
func (c *Compiler) generatePanicOOB() string {
	var code string
	code += utils.Format("; ==============================")
	code += utils.Format("; Runtime helper: index out of range panic")
	code += utils.Format("_panic_index_oob:")

	if c.Ctx.Is64Bit {
		// x86_64: write(2, msg, 21) + exit(1)
		// 参数已在栈上：[rsp+8] = index
		code += utils.Format("push rbp")
		code += utils.Format("mov rbp, rsp")
		code += utils.Format("push rbx")
		code += utils.Format("mov rax, 1")              // sys_write
		code += utils.Format("mov rdi, 2")              // stderr
		code += utils.Format("lea rsi, [rel _oob_msg]") // msg
		code += utils.Format("mov rdx, 21")             // len("index out of range\n")
		code += utils.Format("syscall")
		code += utils.Format("mov rax, 60") // sys_exit
		code += utils.Format("mov rdi, 1")  // exit code 1
		code += utils.Format("syscall")
		code += utils.Format("pop rbx")
		code += utils.Format("pop rbp")
		code += utils.Format("ret")
	} else {
		// x86: write(2, msg, 21) + exit(1)
		code += utils.Format("push ebp")
		code += utils.Format("mov ebp, esp")
		code += utils.Format("push ebx")
		code += utils.Format("mov eax, 4")        // sys_write
		code += utils.Format("mov ebx, 2")        // stderr
		code += utils.Format("mov ecx, _oob_msg") // msg
		code += utils.Format("mov edx, 21")       // len("index out of range\n")
		code += utils.Format("int 0x80")
		code += utils.Format("mov eax, 1") // sys_exit
		code += utils.Format("mov ebx, 1") // exit code 1
		code += utils.Format("int 0x80")
		code += utils.Format("pop ebx")
		code += utils.Format("pop ebp")
		code += utils.Format("ret")
	}
	return code
}

// generateMemmove 生成 memmove 运行时辅助函数
// 签名：void _memmove(ptr dst, ptr src, uint n)
// 行为：从 src 复制 n 字节到 dst，支持重叠区域（向前复制）
func (c *Compiler) generateMemmove() string {
	var code string
	code += utils.Format("; ==============================")
	code += utils.Format("; Runtime helper: memmove(dst, src, n)")
	code += utils.Format("_memmove:")

	if c.Ctx.Is64Bit {
		// x86_64 SysV: rdi=dst, rsi=src, rdx=n
		code += utils.Format("push rbp")
		code += utils.Format("mov rbp, rsp")
		code += utils.Format("push rbx")
		code += utils.Format("mov rcx, rdx") // rcx = byte count
		code += utils.Format("cmp rdi, rsi")
		code += utils.Format("jge .memmove_rev") // dst >= src → 反向复制
		// 正向复制
		code += utils.Format("cld")
		code += utils.Format("rep movsb")
		code += utils.Format("jmp .memmove_done")
		// 反向复制（处理重叠）
		code += utils.Format(".memmove_rev:")
		code += utils.Format("std")
		code += utils.Format("lea rsi, [rsi+rcx-1]") // src 末尾
		code += utils.Format("lea rdi, [rdi+rcx-1]") // dst 末尾
		code += utils.Format("rep movsb")
		code += utils.Format("cld") // 恢复方向标志
		code += utils.Format(".memmove_done:")
		code += utils.Format("pop rbx")
		code += utils.Format("pop rbp")
		code += utils.Format("ret")
	} else {
		// x86 cdecl: [ebp+8]=dst, [ebp+12]=src, [ebp+16]=n
		code += utils.Format("push ebp")
		code += utils.Format("mov ebp, esp")
		code += utils.Format("push esi")
		code += utils.Format("push edi")
		code += utils.Format("push ebx")
		code += utils.Format("mov ecx, [ebp+16]") // ecx = byte count
		code += utils.Format("mov esi, [ebp+12]") // esi = src
		code += utils.Format("mov edi, [ebp+8]")  // edi = dst
		code += utils.Format("cmp edi, esi")
		code += utils.Format("jge .memmove_rev") // dst >= src → 反向复制
		// 正向复制
		code += utils.Format("cld")
		code += utils.Format("rep movsb")
		code += utils.Format("jmp .memmove_done")
		// 反向复制（处理重叠）
		code += utils.Format(".memmove_rev:")
		code += utils.Format("std")
		code += utils.Format("lea esi, [esi+ecx-1]") // src 末尾
		code += utils.Format("lea edi, [edi+ecx-1]") // dst 末尾
		code += utils.Format("rep movsb")
		code += utils.Format("cld") // 恢复方向标志
		code += utils.Format(".memmove_done:")
		code += utils.Format("pop ebx")
		code += utils.Format("pop edi")
		code += utils.Format("pop esi")
		code += utils.Format("pop ebp")
		code += utils.Format("ret")
	}
	return code
}

func (c *Compiler) funcHandle(funcBlock *parser.FuncBlock, node *parser.Node) (code string) {
	//optimizer.OptimizeRecursion(c.Ctx.Now)           // 尝试优化递归函数
	//optimizer.ConvertRecursionToIteration(c.Ctx.Now) // 实际转换递归为迭代

	// 设置当前函数上下文
	c.Ctx.CurrentFunc = funcBlock
	c.currentFuncKey = funcBlock.Name.String()

	// 如果是单态化函数，设置 TypeSubst 供 codegen 使用（sizeof 等内建需要）
	origTypeSubst := c.Ctx.TypeSubst
	if c.typeSubsts != nil {
		if subst, ok := c.typeSubsts[funcBlock.MangledName()]; ok {
			c.Ctx.TypeSubst = subst
		}
	}

	defer func() {
		c.Ctx.CurrentFunc = nil
		c.currentFuncKey = ""
		c.Ctx.TypeSubst = origTypeSubst // 恢复 TypeSubst
	}()

	name := funcBlock.MangledName()

	// build link：函数以链接名输出为全局符号（如 __string_len），
	// 同时保留原函数名标签（供包内/跨包直接调用），两个标签指向同一实现。
	alias := ""
	if linkFlag := c.findLinkFlag(funcBlock); linkFlag != nil {
		alias = linkFlag.Link
	}

	// 重置寄存器分配器（每个函数独立）
	c.Ctx.Reg.Reset()

	// 先生成函数头部（不缩进）
	code += utils.Format("; ==============================")
	code += utils.Format("; Function: " + name)
	if alias != "" {
		code += utils.Format(alias + ":")
	}
	code += utils.Format(name + ":")

	// 增加缩进，让函数体指令有缩进
	utils.Count++

	// 恢复 Ctx.Now 为当前函数节点（Prologue 需要遍历函数体设置变量偏移）
	savedNow := c.Ctx.Now
	c.Ctx.Now = node

	// GC ret 临时对象 scratch 槽：Prologue 之前按本函数 LLR 结果预留。
	// 每个 return 节点最多同时持有 len(RetFrees) 个临时对象。
	c.Ctx.RetScratchBase = 0
	c.Ctx.RetScratchUsed = 0
	c.Ctx.RetScratchCap = 0
	if llr := gc.LLRResults[c.currentFuncKey]; llr != nil {
		c.Ctx.RetScratchCap = llr.RetScratchSlots
	}

	// 生成 prologue（push rbp, mov rbp rsp, 保存 callee-save, 分配栈空间）
	// callee-save 固定全部保存，栈布局可在函数体编译前确定，避免依赖分配器运行结果
	code += c.Ctx.Arch.Prologue(funcBlock)

	// GC 出口释放计划涉及局部槽：与 cleanup 用同一套跳过条件，入口先清零。
	// 早退 ret 可能在变量初始化之前就跳到 func_end，必须先让出口释放看到 0。
	hasExitCleanup := funcBlock.Name.String() != "main" && alias == ""
	if hasExitCleanup {
		code += c.emitGCZeroExitSlots(funcBlock, node)
	}

	// 编译函数体（此时参数/变量偏移已正确设置）
	code += c.Compile(c.Ctx.Now)

	// GC 出口释放（Phase 3）：序列交给 Epilogue，由它在 func_end_<name>:
	// 标签之后、清栈之前插入——显式 ret 的 jmp 会跳到标签，提前放置会被
	// 跳过。main 无需 GC；build link 别名是链接符号包装器，跳过。
	cleanup := ""
	if hasExitCleanup {
		cleanup = c.emitGCFrees(funcBlock, node)
	}

	// 生成 epilogue（清理栈、恢复寄存器、返回）
	code += c.Ctx.Arch.Epilogue(funcBlock, cleanup)

	// 恢复 Ctx.Now
	c.Ctx.Now = savedNow

	// 减少缩进
	utils.Count--
	code += utils.Format("; ======函数完毕=======\n\n")

	// 清理寄存器分配数据
	c.Ctx.Reg.Reset()

	return
}

func pr(block *parser.Node, tabnum int) {
	if block.Ignore {
		return
	}
	fmt.Println(strings.Repeat("\t", tabnum), reflect.TypeOf(block.Value), block.Value)
	for _, k := range block.Children {
		pr(k, tabnum+1)
	}
}

// exitSlot 函数出口释放计划里一个可落地的局部槽。
type exitSlot struct {
	name string
	off  int
}

// resolveExitSlots 把 LLR 的出口释放条目解析成“变量名 + 栈偏移”。
// heap-ptr 孤儿用 site 匹配绑定名；找不到槽的条目跳过（未分配/被豁免）。
// 出口释放与入口清零必须用同一份解析，否则会清一个槽、释放另一个槽。
func (c *Compiler) resolveExitSlots(llr *gc.LLRResult, node *parser.Node) []exitSlot {
	var slots []exitSlot
	for _, fr := range llr.Frees {
		name := fr.VarName
		if fr.Type == "heap-ptr" {
			found := false
			for _, obj := range llr.Objects {
				if obj.FrameOwn && obj.Site == fr.VarName && obj.Name != "" {
					name = obj.Name
					found = true
					break
				}
			}
			if !found {
				continue
			}
		}
		off := findLocalVarOffset(node, name)
		if off == -1 {
			continue
		}
		slots = append(slots, exitSlot{name: name, off: off})
	}
	return slots
}

// emitGCZeroExitSlots 在函数入口把出口释放计划读到的槽清零。
// 显式 ret 可能发生在变量初始化之前（if c { ret 0 }; var x = new(T)），
// 出口释放若读到未初始化的栈垃圾就会 free 野指针。入口清零是廉价的
// 全路径保险：freeSlot 见 0 直接跳过。
func (c *Compiler) emitGCZeroExitSlots(funcBlock *parser.FuncBlock, node *parser.Node) string {
	llr := gc.LLRResults[funcBlock.Name.String()]
	if llr == nil || len(llr.Frees) == 0 {
		return ""
	}
	is64 := c.Ctx.Arch.PointerSize() == 8
	slot := "QWORD"
	base := "rbp"
	if !is64 {
		slot = "DWORD"
		base = "ebp"
	}
	var code string
	seen := map[int]bool{}
	for _, s := range c.resolveExitSlots(llr, node) {
		if seen[s.off] {
			continue
		}
		seen[s.off] = true
		code += utils.Format("mov " + slot + " [" + base + strconv.Itoa(s.off) + "], 0; gc: zero exit slot " + s.name)
	}
	return code
}

// emitGCFrees 生成函数出口的 GC 释放序列（Phase 3 代码生成）。
// 查询 gc.LLRResults 中该函数的 LLR 分析结果，把每个帧内拥有变量的栈槽
// 指针交给 memory.free 释放。无结果时跳过。
// 调用方必须把它放在 func_end_<name>: 之后、清栈之前（见 Arch.Epilogue）。
func (c *Compiler) emitGCFrees(funcBlock *parser.FuncBlock, node *parser.Node) string {
	llr := gc.LLRResults[funcBlock.Name.String()]
	if llr == nil || len(llr.Frees) == 0 && len(llr.FieldFrees) == 0 {
		return ""
	}
	is64 := c.Ctx.Arch.PointerSize() == 8
	slot := "QWORD"
	base := "rbp"
	if !is64 {
		slot = "DWORD"
		base = "ebp"
	}
	// 构建 memory.free / memory.freeSlot 的 CallBlock
	freeNameParts := []parser.NamePart{{Name: "std_memory", IsPkgPath: true}, {Name: "free"}}
	freeFunc := &parser.FuncBlock{
		Name: parser.Name(freeNameParts),
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}
	freeCall := &parser.CallBlock{
		Name: freeFunc.Name,
		Func: freeFunc,
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}
	slotNameParts := []parser.NamePart{{Name: "std_memory", IsPkgPath: true}, {Name: "freeSlot"}}
	slotFunc := &parser.FuncBlock{
		Name: parser.Name(slotNameParts),
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}
	slotCall := &parser.CallBlock{
		Name: slotFunc.Name,
		Func: slotFunc,
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}
	var code string

	// 字段级级联释放：在释放 struct 之前先释放其 owning 字段
	// 确保先释放子对象再释放父容器（sub-before-parent）
	for _, ff := range llr.FieldFrees {
		off := findLocalVarOffset(node, ff.VarName)
		if off == -1 {
			continue
		}
		// 查找字段偏移
		fieldOff := c.findStructFieldOffset(funcBlock, node, ff.VarName, ff.FieldName)
		if fieldOff == -1 {
			continue
		}
		code += utils.Format("; gc: free field " + ff.VarName + "." + ff.FieldName)
		// 使用 RAX/EAX 作为临时寄存器（函数出口前无需保留）
		tmpReg := c.Ctx.Arch.ReturnReg()
		code += utils.Format("mov " + tmpReg + ", " + slot + " [" + base + strconv.Itoa(off) + "]")
		// 父对象可能已在块尾释放并清槽；nil 时跳过，避免解引用空指针。
		skipLabel := c.nextCondLabel("gc_field_skip")
		code += utils.Format("test " + tmpReg + ", " + tmpReg)
		code += utils.Format("jz " + skipLabel)
		// 计算字段地址 = struct_ptr + field_offset
		if fieldOff > 0 {
			code += utils.Format("add " + tmpReg + ", " + strconv.Itoa(fieldOff))
		}
		// 加载字段值（指针）
		code += utils.Format("mov " + tmpReg + ", " + c.Ctx.Arch.LengthName(c.Ctx.Arch.PointerSize()) + " [" + tmpReg + "]")
		// 释放字段值（free）
		if is64 {
			code += utils.Format("mov RDI, " + tmpReg)
			code += utils.Format("call " + freeFunc.MangledName())
		} else {
			// Call 负责按 cdecl 清理它看到的这一个实参；这里手工压入的
			// 正是该实参，不能再额外 add esp——否则会多弹 4 字节，
			// 随后恢复返回值寄存器时读到错位栈槽。
			code += utils.Format("push " + tmpReg)
			code += c.Ctx.Arch.Call(freeCall)
		}
		code += utils.Format(skipLabel + ":")
	}

	// 顶层变量释放：统一用 freeSlot(&slot)，成功后清槽。块尾已释放的
	// 变量在函数出口自然变成 nil，freeSlot 幂等跳过，不再需要静态跳过表。
	for _, s := range c.resolveExitSlots(llr, node) {
		code += utils.Format("; gc: free " + s.name)
		if is64 {
			code += utils.Format("lea RDI, [" + base + strconv.Itoa(s.off) + "]")
			code += utils.Format("call " + slotFunc.MangledName())
		} else {
			code += utils.Format("lea eax, [" + base + strconv.Itoa(s.off) + "]")
			code += utils.Format("push eax")
			code += c.Ctx.Arch.Call(slotCall)
		}
	}
	return code
}

// emitBlockFrees 生成指定块节点的块级 GC 释放序列。
func (c *Compiler) emitBlockFrees(blockNode *parser.Node) string {
	llr := gc.LLRResults[c.currentFuncKey]
	if llr == nil || llr.BlockFreesMap == nil {
		return ""
	}
	return c.emitSlotFrees(blockNode, llr.BlockFreesMap[blockNode], "block free")
}

// blockFreesOf 返回指定块的块级释放计划（无结果时返回 nil）。
func (c *Compiler) blockFreesOf(blockNode *parser.Node) []gc.LLRFree {
	llr := gc.LLRResults[c.currentFuncKey]
	if llr == nil || llr.BlockFreesMap == nil {
		return nil
	}
	return llr.BlockFreesMap[blockNode]
}

// emitLoopExitFrees 生成循环出口的块局部变量释放序列（for_end 之后）。
func (c *Compiler) emitLoopExitFrees(loopNode *parser.Node) string {
	llr := gc.LLRResults[c.currentFuncKey]
	if llr == nil || llr.LoopExitFrees == nil {
		return ""
	}
	return c.emitSlotFrees(loopNode, llr.LoopExitFrees[loopNode], "loop exit free")
}

// emitGCZeroSlots 在进入分支/循环前把该块将释放的局部槽清零。
// 块尾/循环出口的 freeSlot 可能在没有执行过声明语句的路径上运行（例如
// if 条件为假、for 零次迭代、break 提前跳出），未清零的栈槽会被误当成指针。
func (c *Compiler) emitGCZeroSlots(blockNode *parser.Node, frees []gc.LLRFree) string {
	if len(frees) == 0 {
		return ""
	}
	is64 := c.Ctx.Arch.PointerSize() == 8
	slot := "QWORD"
	base := "rbp"
	if !is64 {
		slot = "DWORD"
		base = "ebp"
	}
	seen := map[int]bool{}
	var code string
	for _, fr := range frees {
		off := findBlockVarOffset(blockNode, fr.VarName)
		if off == -1 || seen[off] {
			continue
		}
		seen[off] = true
		code += utils.Format("mov " + slot + " [" + base + strconv.Itoa(off) + "], 0; gc: zero slot " + fr.VarName)
	}
	return code
}

// emitSlotFrees 按变量槽生成 freeSlot(&slot) 序列。
func (c *Compiler) emitSlotFrees(blockNode *parser.Node, frees []gc.LLRFree, tag string) string {
	if len(frees) == 0 {
		return ""
	}
	is64 := c.Ctx.Arch.PointerSize() == 8
	base := "rbp"
	if !is64 {
		base = "ebp"
	}
	nameParts := []parser.NamePart{{Name: "std_memory", IsPkgPath: true}, {Name: "freeSlot"}}
	freeFunc := &parser.FuncBlock{
		Name: parser.Name(nameParts),
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}
	freeCall := &parser.CallBlock{
		Name: freeFunc.Name,
		Func: freeFunc,
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}
	var code string
	seen := map[int]bool{}
	for _, fr := range frees {
		off := findBlockVarOffset(blockNode, fr.VarName)
		if off == -1 || seen[off] {
			continue
		}
		seen[off] = true
		code += utils.Format("; gc: " + tag + " " + fr.VarName)
		if is64 {
			code += utils.Format("lea RDI, [" + base + strconv.Itoa(off) + "]")
			code += utils.Format("call " + freeFunc.MangledName())
		} else {
			code += utils.Format("lea eax, [" + base + strconv.Itoa(off) + "]")
			code += utils.Format("push eax")
			code += c.Ctx.Arch.Call(freeCall)
		}
	}
	return code
}

// scratchFreePlan 条件/增量清理点的 scratch 槽布局与释放代码。
// 槽位在 prepare 时登记到 RetScratchMap，表达式编译期间 Arch.Call 会把
// 拥有型结果写入对应槽；清理代码由调用方插到条件/增量求值之后。
type scratchFreePlan struct {
	code string
	keys []*parser.CallBlock
}

// prepareScratchFrees 为条件/增量表达式中的临时对象分配 scratch 槽并
// 生成 freeSlot 序列。槽位与 ret 清理复用（三类清理点不会同时求值）。
func (c *Compiler) prepareScratchFrees(frees []gc.LLRCondFree, tag string) scratchFreePlan {
	if len(frees) == 0 || c.Ctx.RetScratchBase == 0 {
		return scratchFreePlan{}
	}
	is64 := c.Ctx.Arch.PointerSize() == 8
	slotSize := 4
	base := "ebp"
	if is64 {
		slotSize = 8
		base = "rbp"
	}

	if c.Ctx.RetScratchMap == nil {
		c.Ctx.RetScratchMap = make(map[*parser.CallBlock]int)
	}
	nameParts := []parser.NamePart{{Name: "std_memory", IsPkgPath: true}, {Name: "freeSlot"}}
	freeFunc := &parser.FuncBlock{
		Name: parser.Name(nameParts),
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}
	freeCall := &parser.CallBlock{
		Name: freeFunc.Name,
		Func: freeFunc,
		Args: []*parser.ArgBlock{{Type: typeSys.GetSystemType("ptr")}},
	}

	var plan scratchFreePlan
	for i, f := range frees {
		if f.Call == nil {
			continue
		}
		off := c.Ctx.RetScratchBase + i*slotSize
		c.Ctx.RetScratchMap[f.Call] = off
		plan.keys = append(plan.keys, f.Call)
		plan.code += utils.Format("; gc: " + tag + " " + f.VarName)
		if is64 {
			plan.code += utils.Format("lea RDI, [" + base + strconv.Itoa(off) + "]")
			plan.code += utils.Format("call " + freeFunc.MangledName())
		} else {
			plan.code += utils.Format("lea eax, [" + base + strconv.Itoa(off) + "]")
			plan.code += utils.Format("push eax")
			plan.code += c.Ctx.Arch.Call(freeCall)
		}
	}
	return plan
}

// releaseScratchFrees 注销表达式编译期间登记的 scratch 捕获点。
func (c *Compiler) releaseScratchFrees(plan scratchFreePlan) {
	for _, call := range plan.keys {
		delete(c.Ctx.RetScratchMap, call)
	}
}

// 只匹配非全局的 IsDefine VarBlock 且 Offset 已分配（非 0）；未找到返回 -1。
// findBlockVarOffset 在指定块内查找局部变量槽偏移。
// 优先匹配该块的直接声明，避免内层同名变量遮蔽时错误命中内层槽；
// 找不到再退回递归搜索（兼容包装节点等结构）。
func findBlockVarOffset(blockNode *parser.Node, name string) int {
	if blockNode == nil {
		return -1
	}
	// 赋值节点本身携带目标变量槽偏移（非 IsDefine 也算）。
	if vb, ok := blockNode.Value.(*parser.VarBlock); ok && !vb.IsGlobal && vb.Offset != 0 &&
		vb.Name != nil && vb.Name.First() == name {
		return vb.Offset
	}
	// 简单赋值可能以 Expression.Var 形式出现。
	if exp, ok := blockNode.Value.(*parser.Expression); ok && exp.Var != nil {
		vb := exp.Var
		if !vb.IsGlobal && vb.Offset != 0 && vb.Name != nil && vb.Name.First() == name {
			return vb.Offset
		}
	}
	for _, ch := range blockNode.Children {
		if vb, ok := ch.Value.(*parser.VarBlock); ok && !vb.IsGlobal && vb.IsDefine &&
			vb.Offset != 0 && vb.Name != nil && vb.Name.First() == name {
			return vb.Offset
		}
	}
	return findLocalVarOffset(blockNode, name)
}

func findLocalVarOffset(node *parser.Node, name string) int {
	if node == nil {
		return -1
	}
	if vb, ok := node.Value.(*parser.VarBlock); ok && !vb.IsGlobal && vb.IsDefine &&
		vb.Offset != 0 && vb.Name != nil && vb.Name.First() == name {
		return vb.Offset
	}
	for _, ch := range node.Children {
		if off := findLocalVarOffset(ch, name); off != -1 {
			return off
		}
	}
	return -1
}

// findStructFieldOffset 查找 struct 字段在 struct 内的偏移量。
func (c *Compiler) findStructFieldOffset(funcBlock *parser.FuncBlock, node *parser.Node, varName, fieldName string) int {
	var structType *typeSys.StructType
	// 查找函数参数
	for _, ag := range funcBlock.Args {
		if ag.Name != nil && ag.Name.First() == varName {
			if st, ok := ag.Type.(*typeSys.StructType); ok {
				structType = st
			}
			if ag.Type != nil && ag.Type.IsPointer() {
				if st, ok := ag.Type.Elem().(*typeSys.StructType); ok {
					structType = st
				}
			}
			break
		}
	}
	// 查找函数体中的变量定义
	if structType == nil {
		var walk func(n *parser.Node)
		walk = func(n *parser.Node) {
			if n == nil || structType != nil {
				return
			}
			if vb, ok := n.Value.(*parser.VarBlock); ok && vb.IsDefine &&
				vb.Type != nil && vb.Name != nil && vb.Name.First() == varName {
				if st, ok := vb.Type.(*typeSys.StructType); ok {
					structType = st
				}
				if vb.Type.IsPointer() {
					if st, ok := vb.Type.Elem().(*typeSys.StructType); ok {
						structType = st
					}
				}
				return
			}
			for _, ch := range n.Children {
				walk(ch)
			}
		}
		walk(node)
	}
	if structType == nil {
		return -1
	}
	structType.Layout()
	field := structType.Field(fieldName)
	if field == nil {
		return -1
	}
	return field.Offset
}
