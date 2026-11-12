// Package exp 表达式编译器
package exp

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"fmt"
	"os"
	"runtime/debug"
	"strconv"
	"strings"
	"unsafe"
)

// ECompiler 表达式编译器
type ECompiler struct {
	ctx        *context.Context
	arch       arch.Arch
	expInfo    map[*parser.Expression]*ExpInfo // 表达式信息
	expCounter int                             // 表达式 ID 计数器
	expIDMap   map[string]int                  // 结构 key -> ID
	idx        int                             // BindIndex 计数器
}

// New 创建表达式编译器
func New(ctx *context.Context) *ECompiler {
	return &ECompiler{
		ctx:      ctx,
		arch:     ctx.Arch,
		expInfo:  make(map[*parser.Expression]*ExpInfo),
		expIDMap: make(map[string]int),
	}
}

// danglingBuiltinNames 内建/合成调用名单：这些名字由 builtinCall 或 parser 的
// checkBuiltin 分派（Func 是合成 FuncBlock），绝不能按函数名绑定真实 FuncBlock，
// 否则会把内建语义误绑到同名包函数（如 strings.len）。
var danglingBuiltinNames = map[string]bool{
	"len": true, "cap": true, "append": true, "copy": true,
	"make": true, "realloc": true, "new": true, "newRC": true,
	"sizeof": true, "unsafe.cast": true,
	"memory.new": true, "memory.sizeof": true,
}

// BindDanglingCall 惰性绑定悬空调用（第四根因修复）。
//
// 根因："*p = unsafe.cast[ptr](memory.malloc(16))" 一类语句里，外层 cast 调用名
// 不是真函数 → parser Check 在 checkOp 因右子（内建调用）未解析而提前 return，
// cast 的参数子树从未被 Check → 嵌套调用的 CallBlock.Func 恒为 nil，且步骤 5
// 的伪接收者 ThisVar（VarBlock{Name:"memory"}）残留。发射端 arch.Call 对
// Func==nil 首行返回空串 → call 指令整体消失，寄存器复用陈旧值，运行期空指针写。
//
// 修复语义逐条复刻 parser.CallBlock.Check 的成功绑定路径：
//   - 候选匹配优先全名 Eq；否则唯一 Last() 相等（corpus 无同名重载；
//     多候选/零候选保守不绑，宁可漏发不乱绑）
//   - BuildFlags.Ignore 的候选跳过（build 别名壳）
//   - fb.Useful = true；绑定后若 fb.Class == nil 清除伪 ThisVar
//     （"包名被方法分支误判为接收者时，清除伪 ThisVar"）
//   - Class != nil（方法）不在此路径绑定：方法分派有自己的接收者链路
//
// 命中返回 true。调用点：leaf() 与 compileCallBlock() 的 Func==nil 分支。
func BindDanglingCall(ctx *context.Context, call *parser.CallBlock) bool {
	if ctx == nil || call == nil || call.Func != nil || call.Name.IsEmpty() {
		return false
	}
	full := call.Name.String()
	if danglingBuiltinNames[full] {
		return false
	}
	if !ctx.FuncBlockCacheOK {
		root := ctx.Now
		for root != nil && root.Father != nil {
			root = root.Father
		}
		var acc []*parser.FuncBlock
		var w func(n *parser.Node)
		w = func(n *parser.Node) {
			if n == nil {
				return
			}
			// 后序遍历，同名时最后注册者优先（贴近 parser FindFunc 的反序优先）
			for _, ch := range n.Children {
				w(ch)
			}
			if fb, ok := n.Value.(*parser.FuncBlock); ok && fb.Name != nil && fb.Name.Length() >= 1 {
				acc = append(acc, fb)
			}
		}
		w(root)
		ctx.FuncBlockCache = acc
		ctx.FuncBlockCacheOK = true
	}
	var eqs []int
	var lasts []int
	for i := len(ctx.FuncBlockCache) - 1; i >= 0; i-- { // 反序 = 最先注册者优先贴近 FindFunc
		fb := ctx.FuncBlockCache[i]
		if fb.Name.Eq(call.Name) {
			eqs = append(eqs, i)
		} else if fb.Name.Last() == call.Name.Last() {
			lasts = append(lasts, i)
		}
	}
	idxs := eqs
	if len(idxs) == 0 {
		idxs = lasts
	}
	if len(idxs) == 0 {
		return false
	}
	// BuildFlags.Ignore 的候选是 build 别名壳，跳过；全被跳过视为未找到
	chosen := -1
	for _, i := range idxs {
		fb := ctx.FuncBlockCache[i]
		ignored := false
		for _, bf := range fb.BuildFlags {
			if bf.Ignore {
				ignored = true
				break
			}
		}
		if ignored {
			continue
		}
		if chosen == -1 {
			chosen = i
		}
	}
	if chosen == -1 {
		return false
	}
	// 多候选（含重载）保守不绑——宁可沿用旧行为（漏发）也不绑错目标
	if len(idxs) > 1 && chosen != -1 {
		// eqs 唯一时 idxs 只有一个元素；multi-candidate只允许来自 lasts 唯一相同的场景
		return false
	}
	fb := ctx.FuncBlockCache[chosen]
	fb.Useful = true
	call.Func = fb
	// 包名被方法分支误判为接收者时，清除伪 ThisVar（与 parser 绑定成功路径一致）
	if fb.Class == nil {
		call.ThisVar = nil
	}
	return true
}

// Compile 编译表达式（两趟流程）
func (c *ECompiler) Compile(exp *parser.Expression, result, desc string) string {
	if exp == nil {
		return ""
	}

	// 重置状态
	c.expInfo = make(map[*parser.Expression]*ExpInfo)
	c.expCounter = 0
	c.idx = 0

	// 第一趟：收集信息
	c.Collect(exp)

	// 第二趟：生成代码
	code := c.generate(exp, result)

	if code != "" {
		code += "; " + desc + "\n"
	}
	return code
}

// Assign 编译变量赋值（p1.x = v、self.x += dx 等），
// this/self 字段走间接寻址（this 是指针）
func (c *ECompiler) Assign(v *parser.VarBlock) string {
	if v == nil || v.Value == nil {
		return ""
	}
	// x86：64 位标量变量赋值走寄存器对路径。
	// 值表达式可能是无类型的整型字面量，须按目标变量类型分流；
	// 地址剥宽度前缀（compile64Type 自带 dword 前缀）
	if c.arch.PointerSize() == 4 && v.Type != nil {
		if tn := v.Type.Type(); tn == "u64" || tn == "i64" {
			addr := c.arch.VarAddr(v)
			if idx := strings.Index(addr, "["); idx > 0 {
				addr = addr[idx:]
			}
			return c.arch.Compile64Type(v.Value, addr, "64bit") + "; 设置变量" + v.Name.String() + "\n"
		}
	}
	c.Collect(v.Value)
	if isThisField(v) {
		pre, addr, reg := c.thisMem(v)
		mem := c.fieldValPrefix(v.Type) + "[" + addr + "]"
		code := pre + c.generate(v.Value, mem)
		c.freeTmpReg(reg)
		return code + "; 设置变量" + v.Name.String() + "\n"
	}
	// 指针基字段写入（p.x = v）：先加载指针值再间接寻址
	// 如果字段是 owning 类型，需要先释放旧值
	// 如果字段是 owning 指针类型（*T），还需 rcInc 新值
	// 注意：string/list 类型虽然是 owning，但不使用 RC 块，不需 rcInc
	if needPtrMem(v) {
		pre, addr, reg := c.ptrMem(v)
		mem := c.fieldValPrefix(v.Type) + "[" + addr + "]"
		code := pre + c.generate(v.Value, mem)
		c.freeTmpReg(reg)
		return code + "; 设置变量" + v.Name.String() + "\n"
	}
	return c.generate(v.Value, c.arch.VarAddr(v)) + "; 设置变量" + v.Name.String() + "\n"
}

// isThisField 判断是否为 this/self 的字段访问（self.x）
func isThisField(v *parser.VarBlock) bool {
	if v == nil || len(v.Name) <= 1 {
		return false
	}
	first := v.Name.First()
	return first == "this" || first == "self"
}

// thisMem 为 this/self 字段访问生成间接寻址
// 返回（前置代码, 内存地址表达式, 临时寄存器）
func (c *ECompiler) thisMem(v *parser.VarBlock) (string, string, *regmgr.Reg) {
	reg := c.allocTmpReg()
	size := c.arch.PointerSize()
	frame := "rbp"
	// this 的家统一取 ctx（Cluster A 单一事实源：sysv=-48 / win64=+16 / 32位 cdecl=+8）
	thisOffset := c.ctx.ThisHomeOffset()
	if size == 4 {
		frame = "ebp"
	}
	pre := utils.Format("mov " + reg.Name + ", " + c.arch.LengthName(size) + "[" + frame + "+" + strconv.Itoa(thisOffset) + "]")
	off := fieldOffsetOf(v)
	if off == 0 {
		return pre, reg.Name, reg
	}
	return pre, reg.Name + "+" + strconv.Itoa(off), reg
}

// needPtrMem 判断字段访问是否需要指针间接寻址（p.x / head.next.x 等）。
// 路径中存在指针中间层（除最后一个目标字段类型外）时返回 true。
// Path 项可能是变量/参数/字段/类型本身——逐结构判它是不是指针语义。
func pathEntryIsPointer(e any) bool {
	switch t := e.(type) {
	case typeSys.Type:
		return t != nil && t.IsPointer()
	case *parser.VarBlock:
		return t.Type != nil && t.Type.IsPointer()
	case *parser.ArgBlock:
		return t.Type != nil && t.Type.IsPointer()
	case *typeSys.StructField:
		return t.Type != nil && t.Type.IsPointer()
	}
	return false
}

func needPtrMem(v *parser.VarBlock) bool {
	if v == nil || len(v.Name) <= 1 || isThisField(v) || v.Define.Node == nil || len(v.Define.Path) < 2 {
		return false
	}
	for i := 0; i < len(v.Define.Path)-1; i++ {
		if pathEntryIsPointer(v.Define.Path[i]) {
			return true
		}
	}
	return false
}

// ptrMem 为指针基/指针中间层字段访问生成间接寻址（一层或多层装载）。
// 返回（前置代码, 内存地址表达式, 临时寄存器）。
func (c *ECompiler) ptrMem(v *parser.VarBlock) (string, string, *regmgr.Reg) {
	reg := c.allocTmpReg()
	size := c.arch.PointerSize()
	ln := c.arch.LengthName(size)

	// 基础变量槽地址（Path[0] 为变量/参数；this/self 已由 isThisField 排除）
	var baseOff int
	isGlobal := false
	var globalName string
	var baseType typeSys.Type
	if len(v.Define.Path) > 0 {
		switch base := v.Define.Path[0].(type) {
		case *parser.VarBlock:
			baseOff = base.Offset
			baseType = base.Type
			if base.IsGlobal {
				isGlobal = true
				name := base.Name.String()
				if base.Define.Value != nil {
					if vb, ok := base.Define.Value.(*parser.VarBlock); ok && vb.Name != nil {
						name = vb.Name.String()
					}
				}
				globalName = "__global_" + utils.ToNASMName(name)
			}
		case *parser.ArgBlock:
			baseOff = base.Offset
			baseType = base.Type
		}
	}
	var base string
	if isGlobal {
		base = "[rel " + globalName + "]"
	} else {
		frame := c.arch.FramePtr()
		if baseOff < 0 {
			base = "[" + frame + strconv.Itoa(baseOff) + "]"
		} else if baseOff == 0 {
			base = "[" + frame + "]"
		} else {
			base = "[" + frame + "+" + strconv.Itoa(baseOff) + "]"
		}
	}

	// 第一装载：基础变量是指针则读指针值，否则取地址（值结构体在栈上）
	var pre string
	var currentType typeSys.Type
	if baseType != nil && baseType.IsPointer() {
		pre = utils.Format("mov " + reg.Name + ", " + ln + " " + base)
		currentType = baseType.Elem()
	} else {
		pre = utils.Format("lea " + reg.Name + ", " + base)
		currentType = baseType
	}
	if currentType == nil {
		c.freeTmpReg(reg)
		return pre, reg.Name, reg
	}

	// 沿字段路径：遇指针字段装载一层，普通字段累计偏移
	off := 0
	for i := 1; i < len(v.Name); i++ {
		st, ok := currentType.(*typeSys.StructType)
		if !ok {
			break
		}
		st.Layout()
		field := st.Field(v.Name[i].Name)
		if field == nil {
			break
		}
		off += field.Offset
		if i == len(v.Name)-1 {
			break
		}
		currentType = field.Type
		if currentType == nil {
			break
		}
		if currentType.IsPointer() {
			// 指针中间层：从当前地址装载指针值并清零偏移
			if off != 0 {
				pre += utils.Format("mov " + reg.Name + ", " + ln + " [" + reg.Name + "+" + strconv.Itoa(off) + "]")
			} else {
				pre += utils.Format("mov " + reg.Name + ", " + ln + " [" + reg.Name + "]")
			}
			off = 0
			currentType = currentType.Elem()
		}
	}
	addr := reg.Name
	if off != 0 {
		addr = reg.Name + "+" + strconv.Itoa(off)
	}
	return pre, addr, reg
}

// allocTmpReg 分配临时寄存器（不绑定表达式，调用方负责 freeTmpReg）
// 避开 ReturnReg：derefLoad/derefStore 用 ReturnReg 作临时寄存器，避免覆盖
func (c *ECompiler) allocTmpReg() *regmgr.Reg {
	returnReg := c.arch.ReturnReg()
	for _, reg := range c.ctx.Reg.Regs {
		if reg.Free && reg.ClassMask&c.ctx.Arch.DefaultRegMask() != 0 && reg.Name != returnReg {
			reg.Free = false
			reg.ExpID = 0
			return reg
		}
	}
	return &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
}

// freeTmpReg 释放临时寄存器
func (c *ECompiler) freeTmpReg(reg *regmgr.Reg) {
	reg.Free = true
	reg.ExpID = 0
}

// fieldOffsetOf 沿 v.Name[1:] 字段路径累加结构体偏移（基础类型取自 Define.Path[0]）
func fieldOffsetOf(v *parser.VarBlock) int {
	if v == nil || len(v.Name) <= 1 || v.Define.Node == nil || len(v.Define.Path) == 0 {
		return 0
	}
	base, ok := v.Define.Path[0].(typeSys.Type)
	if !ok {
		switch t := v.Define.Path[0].(type) {
		case *parser.VarBlock:
			base, ok = t.Type, t.Type != nil
		case *parser.ArgBlock:
			base, ok = t.Type, t.Type != nil
		case *parser.FuncBlock:
			base, ok = t.Class, t.Class != nil
		case *typeSys.StructField:
			base, ok = t.Type, t.Type != nil
		}
	}
	if !ok || base == nil {
		return 0
	}
	if base.IsPointer() {
		base = base.Elem()
	}
	if base == nil {
		return 0
	}

	totalOffset := 0
	currentType := base
	for i := 1; i < len(v.Name); i++ {
		st, ok := currentType.(*typeSys.StructType)
		if !ok {
			return 0
		}
		st.Layout()
		field := st.Field(v.Name[i].Name)
		if field == nil {
			return 0
		}
		totalOffset += field.Offset
		currentType = field.Type
		if currentType == nil {
			return 0
		}
		if i < len(v.Name)-1 && currentType.IsPointer() {
			currentType = currentType.Elem()
		}
	}
	return totalOffset
}

// generate 第二趟：自顶向下生成代码（含 BindIndex 分配）
func (c *ECompiler) generate(exp *parser.Expression, result string) string {
	if exp == nil {
		return ""
	}

	// 闭包字面量：f := fn(x: int) int { ... } —— 堆分配 {code, env} 对象。
	if exp.Anon != nil {
		return c.genClosureAnon(exp, result)
	}

	// 32 位架构：64 位标量（u64/i64）路由到 arch 的寄存器对实现（EAX:EDX）。
	// f64 有独立浮点路径，不在此列。
	if c.arch.PointerSize() == 4 && exp.Type != nil {
		if tn := exp.Type.Type(); tn == "u64" || tn == "i64" {
			return c.arch.Compile64Type(exp, result, "64bit")
		}
	}

	// 分配当前节点的 BindIndex
	ei := c.expInfo[exp]
	if ei == nil {
		ei = &ExpInfo{Exp: exp}
		c.expInfo[exp] = ei
	}
	ei.BindIndex = c.idx
	c.idx++
	// 叶子节点
	if exp.Separator == "" {
		return c.leaf(exp, result)
	}

	// 赋值形状兜底：parser 的 checkAssign 会在 Check 期把 "*p = val" 转成
	// deref=(val, 指针)，但 RHS 为跨包/编译器内建调用（如 unsafe.cast[T]）时
	// checkOp 先因右子未解析提前 return，转换被跳过且后续重试同样过不来。
	// 未转换的 "=" 会以二元路径进入本函数，把解引用按"读值"编进左子——
	// 空寄存器操作数问题的直接来源。此处按 parser checkAssign 同规则
	// 原地重排后再走 derefSet（重排幂等：转换后 Separator 已变为 deref=）。
	if exp.Separator == "=" && exp.Left != nil &&
		exp.Left.Separator == "*" && exp.Left.Left == nil && exp.Right != nil {
		ptr := exp.Left.Right
		exp.Separator = "deref="
		exp.Left = exp.Right
		exp.Right = ptr
	}

	// 解引用赋值：deref=(值, 指针)
	if exp.Separator == "deref=" {
		return c.derefSet(exp)
	}

	// 列表/字符串专有节点：字面量、索引读、切片、索引赋值
	switch exp.Separator {
	case "list_lit":
		return c.listLiteral(exp, result)
	case "array_lit":
		return c.arrayLiteral(exp, result)
	case "[]":
		if exp.IndexSlice {
			return c.sliceExp(exp, result)
		}
		return c.indexAccess(exp, result)
	case "[]=":
		return c.indexSet(exp)
	case "map_lit":
		return c.mapLiteral(exp, result)
	}

	// 内建调用（len/cap/append/make/realloc）：非内建时继续走叶子
	if exp.Call != nil {
		if code := c.builtinCall(exp, result); code != "" {
			return code
		}
	}

	// string 拼接 +（运行期，常量折叠已在 parser 层处理）
	if exp.Separator == "+" && exp.Type != nil && typeSys.CheckKind(exp.Type, "string") {
		return c.stringConcatExp(exp, result, ei)
	}

	// 一元运算：只有 Right 子节点，Left 为 nil
	if exp.Left == nil && exp.Right != nil {
		return c.unary(exp, result, ei)
	}

	// 二元运算：按 SU 顺序处理子节点（先处理 MinPeak 大的子树）
	li, ri := ei.Left, ei.Right

	// 保护 nil 子节点
	if li == nil || ri == nil {
		return ""
	}

	if li.MinPeak >= ri.MinPeak {
		return c.binLR(exp, result, ei)
	}
	return c.binRL(exp, result, ei)
}

// leaf 编译叶子节点
func (c *ECompiler) leaf(exp *parser.Expression, result string) string {
	// 内建调用（len/cap/append/make）优先于普通函数调用
	if exp.Call != nil {
		if code := c.builtinCall(exp, result); code != "" {
			return code
		}
	}
	// 特殊处理函数调用：需要先生成 call 指令
	if exp.Call != nil {
		// 悬空调用惰性绑定（第四根因修复）：parser Check 提前返回导致 Func 未绑定时，
		// 在发射前按名字解析补绑；绑定成功后泛型调用还能接上 Monomorphize 链路。
		if exp.Call.Func == nil {
			BindDanglingCall(c.ctx, exp.Call)
		}
		// Monomorphize generic function calls
		// 单态化：生成/复用特化副本，Func 直接指向特化 FuncBlock
		// （Name/MangledOverride = 特化标签；返回类型已是具体类型）。
		if c.ctx.MonomorphizeCall != nil && exp.Call.Func != nil && len(exp.Call.Func.TypeParams) > 0 {
			c.ctx.MonomorphizeCall(exp.Call)
		}
		// DEBUG: trace call.Func before arch.Call
		if exp.Call.Func != nil && exp.Call.Func.Name.NASM() == "" {
			fmt.Fprintf(os.Stderr, "[DEBUG-LEAF] call.Func with empty Name: fn=%p TypeParams=%d call.Name=%q call.ThisVar=%v\n",
				exp.Call.Func, len(exp.Call.Func.TypeParams), exp.Call.Name, exp.Call.ThisVar != nil)
			fmt.Fprintf(os.Stderr, "[DEBUG-LEAF] stack:\n%s\n", string(debug.Stack()))
		}
		code := c.arch.Call(exp.Call)
		// 大值（容器/结构体）返回值：call 已写入本帧返回槽，从这里多槽装载
		if exp.Call.Func != nil && len(exp.Call.Func.Return) > 0 && arch.FuncReturnsLarge(exp.Call.Func) {
			ps := c.arch.PointerSize()
			ln := c.arch.LengthName(ps)
			slots := arch.ArgSlots(exp.Call.Func.Return[0])
			retBase := c.arch.FramePtr() + strconv.Itoa(c.ctx.RetSlot)
			if result == "" {
				// 多返回值解构自行从返回槽逐槽装载，这里只负责发 call。
				return code
			}
			if result == "push" {
				var pcode string
				for i := slots - 1; i >= 0; i-- {
					off := i * ps
					if off == 0 {
						pcode += utils.Format("push " + ln + " [" + retBase + "]")
					} else {
						pcode += utils.Format("push " + ln + " [" + retBase + "+" + strconv.Itoa(off) + "]")
					}
				}
				return code + pcode
			}
			if strings.Contains(result, "[") {
				code += c.copySlots(stripOuterBrackets(result), retBase, slots*ps)
				return code
			}
			return code + utils.Format("mov "+result+", "+ln+" ["+retBase+"]")
		}
		val := c.arch.ReturnReg() // 函数返回值寄存器（EAX/RAX）
		if result == "push" {
			return code + utils.Format("push "+val)
		}
		if result == "" {
			// 空目标（如 multi-return 调用）：值已在寄存器中，无需 mov
			return code
		}
		if result != val {
			// 目标为窄内存槽时源寄存器名匹配槽宽度（RAX→AL/AX/EAX）
			if strings.Contains(result, "[") {
				val = matchMemWidth(result, val)
			}
			return code + utils.Format("mov "+result+", "+val)
		}
		return code
	}

	val := c.val(exp)
	// 函数名作为值：堆分配 {code, env} 闭包对象（env = fb.Env 指针；普通 FB 为 0）。
	// 所有 fn 值都走间接调用 ABI —— 调用参数/返回值/复合赋值中的 fn 值
	// 都按闭包对象 {code@0, env@ptrSize} 传递，不能只写原始代码标签进去。
	if exp.Var != nil && exp.Var.Type != nil {
		if _, isFunc := exp.Var.Type.(*typeSys.FuncType); isFunc {
			if exp.Var.Define.Value != nil {
				if fb, ok := exp.Var.Define.Value.(*parser.FuncBlock); ok {
					envVar := fb.Env
					objCode := c.emitClosureObject(fb, envVar, c.arch.ReturnReg())
					objReg := c.arch.ReturnReg()
					if result == "push" {
						code := objCode + utils.Format("push " + objReg)
						return code
					}
					if result == "" {
						return objCode
					}
					return objCode + utils.Format("mov " + result + ", " + objReg)
				}
			}
		}
	}
	// 多槽叶子（容器/结构体）：常量/变量多槽装载
	if c.isMultiSlotLeaf(exp) {
		return c.loadMultiSlot(exp, result)
	}
	// this/self 字段访问（self.x）：this 是指针，需先加载再间接寻址
	if exp.Var != nil && isThisField(exp.Var) {
		pre, addr, reg := c.thisMem(exp.Var)
		prefix := c.fieldValPrefix(exp.Var.Type)
		var code string
		if result == "push" {
			code = c.derefLoad(prefix, reg.Name, addr)
			code += utils.Format("push " + reg.Name)
		} else {
			code = c.derefLoad(prefix, result, addr)
		}
		c.freeTmpReg(reg)
		return pre + code
	}
	// 指针基字段访问（p.x）：先加载指针值再间接寻址
	if exp.Var != nil && needPtrMem(exp.Var) {
		pre, addr, reg := c.ptrMem(exp.Var)
		prefix := c.fieldValPrefix(exp.Var.Type)
		var code string
		if result == "push" {
			code = c.derefLoad(prefix, reg.Name, addr)
			code += utils.Format("push " + reg.Name)
		} else {
			code = c.derefLoad(prefix, result, addr)
		}
		c.freeTmpReg(reg)
		return pre + code
	}
	// 常量 → QWORD 内存槽：NASM mov r/m64,imm 只支持 imm32（符号扩展），
	// 因此 ≥2^31 的正数会被扩展成负值（4294967295 → 全 F），
	// 必须拆成高低两条 mov dword（x86_64 防符号扩展，x86 直接非法）
	if isQwordMem(result) && !strings.Contains(val, "[") {
		loAddr := result
		if strings.Contains(loAddr, "QWORD [") {
			loAddr = strings.Replace(loAddr, "QWORD [", "DWORD [", 1)
		} else {
			loAddr = strings.Replace(loAddr, "QWORD[", "DWORD[", 1)
		}
		hiAddr := hiMemAddr(loAddr)
		// f64 常量以 IEEE-754 位模式的十六进制输出；QWORD 内存立即数
		// 只能吃 imm32，必须无条件拆高低 dword。
		if strings.HasPrefix(val, "0x") {
			if bits, err := strconv.ParseUint(val[2:], 16, 64); err == nil {
				lo32 := bits & 0xFFFFFFFF
				hi32 := bits >> 32
				return utils.Format("mov "+loAddr+", "+strconv.FormatUint(lo32, 10)+"; 64bit low") +
					utils.Format("mov "+hiAddr+", "+strconv.FormatUint(hi32, 10)+"; 64bit high")
			}
		}
		if num, err := strconv.ParseFloat(val, 64); err == nil {
			if num > 0x7FFFFFFF || num < -0x80000000 || c.arch.PointerSize() == 4 {
				lo32 := int64(num) & 0xFFFFFFFF
				hi32 := (int64(num) >> 32) & 0xFFFFFFFF
				return utils.Format("mov "+loAddr+", "+strconv.FormatInt(lo32, 10)+"; 64bit low") +
					utils.Format("mov "+hiAddr+", "+strconv.FormatInt(hi32, 10)+"; 64bit high")
			}
		}
	}
	if result == "push" {
		// x86_64：push 仅支持 64 位操作数，窄内存值经 EAX 零扩展后 push RAX
		if c.arch.PointerSize() == 8 {
			switch memPrefix(val) {
			case "BYTE", "WORD", "DWORD":
				return utils.Format("mov EAX, "+val) +
					utils.Format("push RAX")
			}
		} else {
			// x86：push 只支持 16/32 位操作数；窄内存值经寄存器零扩展
			switch memPrefix(val) {
			case "BYTE":
				return utils.Format("movzx EAX, "+val) +
					utils.Format("push EAX")
			case "WORD":
				return utils.Format("movzx EAX, "+val) +
					utils.Format("push EAX")
			}
		}
		// 大立即数：push 只支持 32 位有符号立即数（符号扩展），超出必须经 RAX 中转
		if !strings.Contains(val, "[") {
			if num, err := strconv.ParseFloat(val, 64); err == nil {
				if num > 0x7FFFFFFF || num < -0x80000000 {
					return utils.Format("mov RAX, "+val) +
						utils.Format("push RAX")
				}
			}
		}
		return utils.Format("push " + val)
	}
	if result == "" {
		// 空目标（如 multi-return 调用）：值已在寄存器中，无需 mov
		return ""
	}
	if result != val {
		// 内存到内存：无法直接 mov，需要经寄存器中转（两端宽度匹配）
		if strings.Contains(val, "[") && strings.Contains(result, "[") {
			tmp := c.arch.ReturnReg()
			if reg := c.allocReg(exp); reg != nil {
				tmp = reg.Name
			}
			var code string
			// 宽度匹配装载：BYTE/WORD → movzx，DWORD → 32 位名，QWORD 直接
			switch memPrefix(val) {
			case "BYTE", "WORD":
				code += utils.Format("movzx " + tmp + ", " + val)
			case "DWORD":
				code += utils.Format("mov " + eName(tmp) + ", " + val)
			default:
				code += utils.Format("mov " + tmp + ", " + val)
			}
			code += utils.Format("mov " + result + ", " + matchMemWidth(result, tmp))
			c.ctx.Reg.Free(exp)
			return code
		}
		// 寄存器 → 窄内存槽：源寄存器名匹配槽宽度
		if strings.Contains(result, "[") && isRegLike(val) {
			val = matchMemWidth(result, val)
		} else if strings.Contains(val, "[") {
			// 内存 → 寄存器：BYTE/WORD 需 movzx（零扩展），DWORD 用 32 位名
			switch memPrefix(val) {
			case "BYTE", "WORD":
				return utils.Format("movzx " + result + ", " + val)
			case "DWORD":
				if strings.HasPrefix(result, "R") {
					result = "E" + result[1:]
				}
			}
		}
		// x86 32-bit: large immediate values outside int32 range cause NASM to
		// treat them as unsigned, producing wrong bit patterns.
		// E.g., mov DWORD[ebp-8], -2177481943 → NASM stores 0x7E364329 (unsigned 2117485353)
		// instead of 0x81D24F97 (signed -2177481943).
		// Fix: load through register first, then store to memory.
		if c.arch.PointerSize() == 4 && strings.Contains(result, "[") && !strings.Contains(val, "[") {
			if num, err := strconv.ParseFloat(val, 64); err == nil {
				if num > 0x7FFFFFFF || num < -0x80000000 {
					tmp := c.arch.ReturnReg()
					code := utils.Format("mov " + tmp + ", " + val + "; large imm via reg")
					code += utils.Format("mov " + result + ", " + matchMemWidth(result, tmp))
					return code
				}
			}
		}
		return utils.Format("mov " + result + ", " + val)
	}
	return ""
}

// numLiteral 输出常量操作数的 NASM 字面量。
// f64 当前没有 XMM 代码生成，统一以 IEEE-754 位模式存放（比较语义对正数保序）。
func numLiteral(exp *parser.Expression) string {
	if typeSys.CheckKind(exp.Type, "float") {
		return utils.Float64BitsLiteral(exp.Num)
	}
	return strconv.FormatFloat(exp.Num, 'f', -1, 64)
}

// val 获取表达式的值（不生成代码）
func (c *ECompiler) val(exp *parser.Expression) string {
	if exp.IsConst() {
		if exp.ConstNil {
			return "0"
		}
		if exp.StringVal != "" {
			return c.getStringLabel(exp.StringVal)
		}
		if exp.Type != nil && exp.Type.Kind() == "bool" {
			if exp.Bool {
				return "1"
			}
			return "0"
		}
		return numLiteral(exp)
	}
	if exp.Var != nil {
		return c.arch.VarAddr(exp.Var)
	}
	if exp.Call != nil {
		return c.arch.ReturnReg() // 返回值寄存器（EAX/RAX）
	}
	return ""
}

// unary 编译一元运算符
func (c *ECompiler) unary(exp *parser.Expression, result string, ei *ExpInfo) string {
	// 取地址：直接 lea 变量地址，无需生成右子代码
	if exp.Separator == "&" {
		return c.emitAddrOf(exp, result)
	}

	// 分配右子寄存器
	rReg := c.allocReg(exp.Right)
	if rReg == nil {
		rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	rCode := c.generate(exp.Right, rReg.Name)

	// 生成一元运算指令
	code := rCode + c.emitUnary(exp, result, rReg)

	// 释放子节点寄存器
	c.ctx.Reg.Free(exp.Right)

	return code
}

// emitUnary 生成一元运算指令
func (c *ECompiler) emitUnary(exp *parser.Expression, result string, rReg *regmgr.Reg) string {
	rVal := rReg.Name
	var code string

	// 解引用读（必须在 push 通用处理之前，因为 push + deref 需要特殊生成）
	if exp.Separator == "*" {
		pt := exp.Right.Type
		// 未 Check 的实参子树（如 unsafe.cast[u8](*p)）表达式节点无 Type，
		// 但变量块已解析：回退 Var.Type，否则 derefPrefix 返回空串、装载整条丢失。
		if pt == nil && exp.Right.Var != nil {
			pt = exp.Right.Var.Type
		}
		prefix := c.derefPrefix(pt)
		if result == "push" {
			code = c.derefLoad(prefix, rVal, rVal)
			code += utils.Format("push " + rVal)
			return code
		}
		return c.derefLoad(prefix, result, rVal)
	}

	// 特殊处理 push：就地计算到操作数寄存器，再 push
	// （不用返回值寄存器当临时寄存器，避免与操作数/外部活跃值同寄存器）
	if result == "push" {
		if exp.Separator == "!" {
			code = utils.Format("cmp " + rVal + ", 0")
			code += utils.Format("sete " + lo8(rVal))
			code += utils.Format("movzx " + rVal + ", " + lo8(rVal))
			code += utils.Format("push " + rVal)
			return code
		}
		code = c.emitUnaryOp(rVal, exp.Separator, rVal)
		code += utils.Format("push " + rVal)
		return code
	}

	// 逻辑非：就地改写操作数寄存器（movzx 需要寄存器目标）
	if exp.Separator == "!" {
		code = utils.Format("cmp " + rVal + ", 0")
		code += utils.Format("sete " + lo8(rVal))
		code += utils.Format("movzx " + rVal + ", " + lo8(rVal))
		if result != rVal {
			code += utils.Format("mov " + result + ", " + matchMemWidth(result, rVal))
		}
		return code
	}

	// 取地址：&x → rbp+offset
	if exp.Separator == "&" {
		if exp.Right != nil && exp.Right.Var != nil {
			addr := c.genAddrOf(exp.Right.Var)
			if result == "push" {
				return utils.Format("push " + addr)
			}
			return utils.Format("mov " + result + ", " + addr)
		}
	}

	// 普通情况
	if result == rVal {
		code = c.emitUnaryOp(rVal, exp.Separator, rVal)
	} else {
		code = utils.Format("mov " + result + ", " + matchMemWidth(result, rVal))
		code += c.emitUnaryOp(result, exp.Separator, result)
	}

	return code
}

// emitUnaryOp 生成一元运算指令
func (c *ECompiler) emitUnaryOp(dst, op, src string) string {
	switch op {
	case "-":
		return utils.Format("neg " + src)
	case "~":
		return utils.Format("not " + src)
	case "!":
		// 逻辑非：与 0 比较，结果为 0 或 1
		code := utils.Format("cmp " + src + ", 0")
		code += utils.Format("sete " + lo8(src)) // 使用 setXX 指令设置结果
		code += utils.Format("movzx " + dst + ", " + lo8(src))
		return code
	default:
		return ""
	}
}

// emitAddrOf 生成取地址指令：lea result, [变量地址]
func (c *ECompiler) emitAddrOf(exp *parser.Expression, result string) string {
	if exp.Right == nil || exp.Right.Var == nil {
		return ""
	}
	// lea 需要裸地址：剥离 VarAddr 的宽度前缀（BYTE/WORD/DWORD/QWORD）
	addr := stripMemPrefix(c.arch.VarAddr(exp.Right.Var))

	// push：经临时寄存器中转
	if result == "push" || strings.Contains(result, "[") {
		rReg := c.allocReg(exp)
		if rReg == nil {
			rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		code := utils.Format("lea " + rReg.Name + ", " + addr)
		if result == "push" {
			code += utils.Format("push " + rReg.Name)
		} else {
			code += utils.Format("mov " + result + ", " + rReg.Name)
		}
		c.ctx.Reg.Free(exp)
		return code
	}

	return utils.Format("lea " + result + ", " + addr)
}

// derefSet 编译解引用赋值 *addr = value（节点形状 deref=(值, 指针)）。
func (c *ECompiler) derefSet(exp *parser.Expression) string {
	ei := c.expInfo[exp]
	calleeName := c.pickCalleeSave()
	if calleeName == "" {
		calleeName = c.arch.CalleeSaveReg()
	}

	// 1. 计算值到 vReg
	vReg := c.allocReg(exp.Left)
	if vReg == nil {
		vReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code := c.generate(exp.Left, vReg.Name)

	// 指针侧含调用时，把值保存到 callee-save 寄存器（call 会破坏 caller-saved）
	vVal := vReg.Name
	callee := ""
	if ei.Right.HasCall {
		callee = calleeName
		code += utils.Format("mov " + callee + ", " + vReg.Name)
		c.ctx.Reg.Free(exp.Left)
		if calleeReg := c.getRegByName(callee); calleeReg != nil {
			c.ctx.Reg.Force(calleeReg, exp.Left)
		}
		vVal = callee
	}

	// 2. 计算指针到 pReg（避开值寄存器）
	pReg := c.allocRegAvoid(exp.Right, vReg.Name)
	if pReg == nil {
		pReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
	}
	code += c.generate(exp.Right, pReg.Name)

	// 3. 写入：[p] = v
	prefix := c.derefPrefix(exp.Right.Type)
	code += c.derefStore(prefix, pReg.Name, vVal)

	c.ctx.Reg.Free(exp.Left)
	c.ctx.Reg.Free(exp.Right)
	return code
}

// fieldValPrefix 字段访问的读写宽度：指针字段按指针大小（存的是地址），
// 标量按自身宽度；容器/超宽字段由 loadContainer 等路径处理，回退指针宽度。
func (c *ECompiler) fieldValPrefix(t typeSys.Type) string {
	if t == nil {
		return c.arch.LengthName(c.arch.PointerSize())
	}
	if isListLike(t) || t.Size() > c.arch.PointerSize() {
		return c.arch.LengthName(c.arch.PointerSize())
	}
	return c.arch.LengthName(t.Size())
}

// derefPrefix 返回解引用类型的内存操作宽度前缀（BYTE/WORD/DWORD/QWORD）。// 真实指针（IsPointer）的宽度取被指类型 Elem 的大小；
// 系统 ptr 是地址号类型（无元素信息），宽度即指针大小。
func (c *ECompiler) derefPrefix(t typeSys.Type) string {
	if t == nil {
		return ""
	}
	if t.IsPointer() {
		if elem := t.Elem(); elem != nil {
			return c.arch.LengthName(elem.Size())
		}
		return c.arch.LengthName(c.arch.PointerSize())
	}
	if t.Type() == "ptr" {
		return c.arch.LengthName(c.arch.PointerSize())
	}
	return c.arch.LengthName(t.Size())
}

// hiMemAddr 返回 DWORD 内存操作数的相邻高 4 字节地址（[rbp-48] → [rbp-44]）
func hiMemAddr(dwordAddr string) string {
	idx := strings.LastIndex(dwordAddr, "]")
	if idx == -1 {
		return dwordAddr
	}
	base := dwordAddr[:idx]
	plus := strings.LastIndex(base, "+")
	if plus != -1 {
		if off, err := strconv.Atoi(base[plus+1:]); err == nil {
			return base[:plus] + "+" + strconv.Itoa(off+4) + "]"
		}
	}
	if minus := strings.LastIndex(base, "-"); minus != -1 {
		if off, err := strconv.Atoi(base[minus+1:]); err == nil {
			return base[:minus] + "-" + strconv.Itoa(off-4) + "]"
		}
	}
	return dwordAddr
}

// isQwordMem 判断结果操作数是否为 QWORD 内存槽。
// 调用参数 buffer 等路径会生成带空格的 "QWORD [rsp+0]"，两种写法都要识别。
func isQwordMem(s string) bool {
	return strings.Contains(s, "QWORD[") || strings.Contains(s, "QWORD [")
}

// memPrefix 返回内存操作数的宽度前缀（BYTE/WORD/DWORD/QWORD），非内存返回空串。
// 同时识别 "QWORD"（无空格）与 "QWORD "（有空格）两种形式——避免
// emitMapTempResult 这类场景重复加前缀。
func memPrefix(mem string) string {
	m := strings.TrimSpace(mem)
	switch {
	case strings.HasPrefix(m, "BYTE[") || strings.HasPrefix(m, "BYTE "):
		return "BYTE"
	case strings.HasPrefix(m, "WORD[") || strings.HasPrefix(m, "WORD "):
		return "WORD"
	case strings.HasPrefix(m, "DWORD[") || strings.HasPrefix(m, "DWORD "):
		return "DWORD"
	case strings.HasPrefix(m, "QWORD[") || strings.HasPrefix(m, "QWORD "):
		return "QWORD"
	}
	return ""
}

// matchMemWidth 根据内存槽宽度返回寄存器名的匹配形式（RAX→AL/AX/EAX）。
// 用于 64 位寄存器与窄内存槽互传时避免操作数宽度不匹配。
// 非内存目标时原样返回 reg。
func matchMemWidth(mem, reg string) string {
	switch memPrefix(mem) {
	case "BYTE":
		return lo8(reg)
	case "WORD":
		return lo16(reg)
	case "DWORD":
		return eName(reg)
	}
	return reg
}

// stripMemPrefix 去掉内存操作数的宽度前缀（BYTE/WORD/DWORD/QWORD），
// lea 等指令要求裸地址形式。
func stripMemPrefix(addr string) string {
	for _, p := range []string{"BYTE", "WORD", "DWORD", "QWORD"} {
		if strings.HasPrefix(addr, p) {
			return addr[len(p):]
		}
	}
	return addr
}

// stripOuterBrackets 去掉内存操作数的外层括号：QWORD[rbp-96] → rbp-96
func stripOuterBrackets(addr string) string {
	addr = strings.TrimSpace(stripMemPrefix(strings.TrimSpace(addr)))
	if len(addr) >= 2 && addr[0] == '[' && addr[len(addr)-1] == ']' {
		return addr[1 : len(addr)-1]
	}
	return addr
}

// isRegLike 判断字符串是否为寄存器名（常量/内存地址不会以 R/E 开头）。
// 注意：宽松前缀判断会把 "RBP-112" 这类地址文本误判为寄存器，这里精确匹配。
func isRegLike(name string) bool {
	return isBareReg(name)
}

// isBareReg 精确匹配 x86/x86_64 GPR 寄存器名（64 位、32 位两套）。
func isBareReg(name string) bool {
	switch strings.ToUpper(name) {
	case "RAX", "RBX", "RCX", "RDX", "RSI", "RDI", "RSP", "RBP",
		"R8", "R9", "R10", "R11", "R12", "R13", "R14", "R15",
		"EAX", "EBX", "ECX", "EDX", "ESI", "EDI", "ESP", "EBP":
		return true
	}
	return false
}

// genAddrOf 生成变量的原始地址（rbp+offset），不带内存引用。
func (c *ECompiler) genAddrOf(v *parser.VarBlock) string {
	addr := c.arch.VarAddr(v) // e.g. "QWORD[rbp+16]" or "[rel __global_x]"
	// 去掉 size 前缀 (QWORD/DWORD/WORD/BYTE)
	trimmed := addr
	for _, p := range []string{"QWORD", "DWORD", "WORD", "BYTE"} {
		if strings.HasPrefix(trimmed, p+"[") {
			trimmed = trimmed[len(p):]
			break
		}
	}
	// 去掉方括号 → rbp+16 或 rel __global_x
	if strings.HasPrefix(trimmed, "[") && strings.HasSuffix(trimmed, "]") {
		trimmed = trimmed[1 : len(trimmed)-1]
	}
	return trimmed
}

// derefLoad 生成内存读指令：[src] → dst。
func (c *ECompiler) derefLoad(prefix, dst, src string) string {
	if dst == "" || src == "" {
		panic("derefLoad 空操作数: prefix=" + prefix + " dst=" + dst + " src=" + src)
	}
	load := func(dst, src string) string {
		switch prefix {
		case "BYTE", "WORD":
			return utils.Format("movzx " + dst + ", " + prefix + " [" + src + "]")
		case "DWORD":
			return utils.Format("mov " + eName(dst) + ", DWORD [" + src + "]")
		case "QWORD":
			return utils.Format("mov " + dst + ", QWORD [" + src + "]")
		}
		return ""
	}

	// push 参数装载：直接 push 元素（BYTE/WORD 需先 movzx 中转）
	if dst == "push" {
		if prefix == "BYTE" || prefix == "WORD" {
			return load(c.arch.ReturnReg(), src) + utils.Format("push "+c.arch.ReturnReg())
		}
		return utils.Format("push " + prefix + " [" + src + "]")
	}
	// 内存目标需经寄存器中转（x86 不支持 mov mem, mem），写回时匹配槽宽度
	if strings.Contains(dst, "[") {
		tmp := c.arch.ReturnReg()
		return load(tmp, src) + utils.Format("mov "+dst+", "+matchMemWidth(dst, tmp))
	}
	return load(dst, src)
}

// derefStore 生成内存写指令：[dst] = src。
func (c *ECompiler) derefStore(prefix, dst, src string) string {
	switch prefix {
	case "BYTE":
		return utils.Format("mov BYTE [" + dst + "], " + lo8(src))
	case "WORD":
		return utils.Format("mov WORD [" + dst + "], " + lo16(src))
	case "DWORD":
		return utils.Format("mov DWORD [" + dst + "], " + eName(src))
	case "QWORD":
		return utils.Format("mov QWORD [" + dst + "], " + src)
	}
	return ""
}

// lo16 返回寄存器名的低16位寄存器名（16位内存写需要）
func lo16(name string) string {
	switch strings.ToUpper(name) {
	case "EAX", "RAX":
		return "ax"
	case "EBX", "RBX":
		return "bx"
	case "ECX", "RCX":
		return "cx"
	case "EDX", "RDX":
		return "dx"
	case "ESI", "RSI":
		return "si"
	case "EDI", "RDI":
		return "di"
	case "R8":
		return "r8w"
	case "R9":
		return "r9w"
	case "R10":
		return "r10w"
	case "R11":
		return "r11w"
	case "R12":
		return "r12w"
	case "R13":
		return "r13w"
	case "R14":
		return "r14w"
	case "R15":
		return "r15w"
	}
	return "ax"
}

// eName 返回寄存器的32位名（RAX→EAX；R8→R8D；EAX 等 32 位名原样）。
// x86 下寄存器本身是 EAX 形式（无 R 前缀），原样返回。
func eName(name string) string {
	switch name {
	case "R8":
		return "R8D"
	case "R9":
		return "R9D"
	case "R10":
		return "R10D"
	case "R11":
		return "R11D"
	case "R12":
		return "R12D"
	case "R13":
		return "R13D"
	case "R14":
		return "R14D"
	case "R15":
		return "R15D"
	}
	if strings.HasPrefix(name, "R") {
		return "E" + name[1:]
	}
	return name
}

// lo8 返回寄存器名的低8位寄存器名（sete/movzx 需要）
func lo8(name string) string {
	switch strings.ToUpper(name) {
	case "EAX", "RAX":
		return "al"
	case "EBX", "RBX":
		return "bl"
	case "ECX", "RCX":
		return "cl"
	case "EDX", "RDX":
		return "dl"
	case "ESI", "RSI":
		return "sil"
	case "EDI", "RDI":
		return "dil"
	case "R8":
		return "r8b"
	case "R9":
		return "r9b"
	case "R10":
		return "r10b"
	case "R11":
		return "r11b"
	case "R12":
		return "r12b"
	case "R13":
		return "r13b"
	case "R14":
		return "r14b"
	case "R15":
		return "r15b"
	}
	return "al"
}

// binLR 先左后右
// pickCalleeSave 挑一个当前空闲的 callee-save 寄存器（跨调用保活左值/右值用）。
// 不硬占第一个（RBX）：外层 ptrMem 等可能已把它当作字段基址 держ住。
// 全集都忙时返回 ""（调用方不保活，依赖外部内存目标）。
func (c *ECompiler) pickCalleeSave() string {
	for _, name := range c.arch.CalleeSaveRegs() {
		if reg := c.getRegByName(name); reg != nil && reg.Free {
			return name
		}
	}
	return ""
}

func (c *ECompiler) binLR(exp *parser.Expression, result string, ei *ExpInfo) string {

	calleeName := c.pickCalleeSave()

	// 左子：result 为寄存器/内存时就地计算到 result（左链只需 2 个寄存器），
	// 避免每层额外占一个寄存器导致寄存器压力随深度增长；
	// push 或 result 与 callee-save 冲突时退回分配独立寄存器
	lVal := result
	inPlace := result != "push" && !(ei.Right.HasCall && result == calleeName)
	// 内存目标（赋值变量槽）不能承载"左子提前落槽"优化：右子若仍
	// 引用同一变量（如 y = x % y），右值会在读取前被左子覆盖。
	// 退回独立寄存器算左子，右子求值完再写目标槽。
	if strings.Contains(result, "[") {
		inPlace = false
	}

	// 就地且 result 是空闲寄存器：绑定到左子，使右子分配避开（结果值仍在使用）
	if inPlace && !strings.Contains(result, "[") {
		if regObj := c.getRegByName(result); regObj != nil && regObj.Free {
			c.ctx.Reg.Force(regObj, exp.Left)
		}
	}

	var lCode string
	if inPlace {
		lCode = c.generate(exp.Left, result)
	} else {
		lReg := c.allocRegAvoid(exp.Left, regNameFrom(result))
		if lReg == nil {
			lReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		lVal = lReg.Name
		lCode = c.generate(exp.Left, lVal)
	}

	// 如果右子有调用或包含除法（强制占用 EAX/EDX），保存左子结果到 callee-save。
	// allocRegAvoid 的后缀掩码依赖 BindIndex 预赋值，生成期懒赋值导致未来除法节点
	// 的需求不可见，此处按 HardBindMask 兜底保护跨除法存活的左值。
	callee := ""
	if calleeName != "" && (ei.Right.HasCall || ei.Right.HardBindMask&c.arch.NeedBindMask("/") != 0) {
		callee = calleeName
		lCode += utils.Format("mov " + matchMemWidth(lVal, callee) + ", " + lVal)
		// 先释放左子原寄存器，再绑定 callee 寄存器（值已转移到 callee）
		c.ctx.Reg.Free(exp.Left)
		if calleeReg := c.getRegByName(callee); calleeReg != nil {
			c.ctx.Reg.Force(calleeReg, exp.Left)
		}
		lVal = callee
	}

	// 分配右子寄存器（避开 result 寄存器：emitBin 末尾会写 result）
	rReg := c.allocRegAvoid(exp.Right, regNameFrom(result))
	if rReg == nil {
		rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
	}
	rCode := c.generate(exp.Right, rReg.Name)

	// 生成运算指令
	code := lCode + rCode + c.emitBin(exp, result, lVal, rReg.Name, callee)

	// 释放子节点寄存器（就地且非 callee 时保留绑定：结果值仍在使用）
	if !inPlace || callee != "" {
		c.ctx.Reg.Free(exp.Left)
	}
	c.ctx.Reg.Free(exp.Right)

	return code
}

// binRL 先右后左
func (c *ECompiler) binRL(exp *parser.Expression, result string, ei *ExpInfo) string {

	calleeName := c.pickCalleeSave()

	// 分配右子寄存器（避开 result 寄存器：左子就地写入 result）
	rReg := c.allocRegAvoid(exp.Right, regNameFrom(result))
	if rReg == nil {
		rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
	}
	rCode := c.generate(exp.Right, rReg.Name)

	// 如果左子有调用或包含除法（强制占用 EAX/EDX），保存右子结果到 callee-save
	callee := ""
	rVal := rReg.Name
	if calleeName != "" && (ei.Left.HasCall || ei.Left.HardBindMask&c.arch.NeedBindMask("/") != 0) {
		callee = calleeName
		rCode += utils.Format("mov " + matchMemWidth(rVal, callee) + ", " + rVal)
		// 先释放右子原寄存器，再绑定 callee 寄存器（值已转移到 callee）
		c.ctx.Reg.Free(exp.Right)
		if calleeReg := c.getRegByName(callee); calleeReg != nil {
			c.ctx.Reg.Force(calleeReg, exp.Right)
		}
		rVal = callee
	}

	// 左子：就地计算到 result（push 或与 callee-save 冲突时退回分配独立寄存器）
	lVal := result
	inPlace := result != "push" && !(ei.Left.HasCall && result == calleeName)
	// [病灶⑱ 修复 2026-11-02] 左子这种"ulus 确实落内存"在 binRL 里必须让位：
	// 右子先编，结果常驻 ReturnReg；随后左子以 inPlace 形态直接写内存 result，
	// 而指针基字段（p.x）/this 字段（self.x）叶子的 derefLoad 走"内存目标经
	// ReturnReg 中转"模板——把右子活值覆盖掉。之后 emitBin 生成 add [X], RAX
	// 时 RAX 已是左子自身的字段值 → X=X+X（equal 实锤：sb=am.slots+i*rowU 编出
	// sb=2×slots，内层同型式因左子是普通 Var 不走 derefLoad 而正确）。
	// 该形态退回独立寄存器：allocRegAvoid 避开右侧在用的 RAX；derefLoad 对
	// 寄存器 dst 直接装载不走 ReturnReg 中转，天然无冲。
	if inPlace && callee == "" && rVal == c.arch.ReturnReg() && strings.Contains(result, "[") {
		lo := exp.Left
		if lo != nil && lo.Separator == "" && lo.Var != nil && (needPtrMem(lo.Var) || isThisField(lo.Var)) {
			inPlace = false
		}
	}

	// 就地且 result 是空闲寄存器：绑定到左子，使右子分配避开（结果值仍在使用）
	if inPlace && !strings.Contains(result, "[") {
		if regObj := c.getRegByName(result); regObj != nil && regObj.Free {
			c.ctx.Reg.Force(regObj, exp.Left)
		}
	}

	var lCode string
	if inPlace {
		lCode = c.generate(exp.Left, result)
	} else {
		lReg := c.allocRegAvoid(exp.Left, regNameFrom(result))
		if lReg == nil {
			lReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		lVal = lReg.Name
		lCode = c.generate(exp.Left, lVal)
	}

	// 生成运算指令
	code := rCode + lCode + c.emitBin(exp, result, lVal, rVal, callee)

	// 释放子节点寄存器（左子就地且非 callee 时保留绑定：结果值仍在使用）
	if !inPlace || callee != "" {
		c.ctx.Reg.Free(exp.Left)
	}
	c.ctx.Reg.Free(exp.Right)

	return code
}

// allocReg 分配寄存器（带偏好和避免）
func (c *ECompiler) allocReg(exp *parser.Expression) *regmgr.Reg {
	return c.allocRegAvoid(exp, "")
}

// allocRegAvoid 分配寄存器；avoidReg 为必须避开的寄存器名（该寄存器中的值仍在使用）
func (c *ECompiler) allocRegAvoid(exp *parser.Expression, avoidReg string) *regmgr.Reg {
	if exp == nil {
		return nil
	}

	ei, ok := c.expInfo[exp]
	if !ok || ei == nil {
		ei = &ExpInfo{Exp: exp, MinPeak: 1}
		c.expInfo[exp] = ei
	}

	// 构建 avoid：当前节点之后的硬绑定掩码
	avoidMask := uint32(0)
	for _, info := range c.expInfo {
		if info != nil && info.BindIndex > ei.BindIndex {
			avoidMask |= info.HardBindMask
		}
	}

	// 默认掩码（普通表达式也可用 GPR）+ 硬绑定掩码（除法/取模需要 EAX/EDX）
	mask := c.ctx.Arch.DefaultRegMask() | ei.HardBindMask

	// 转换为 prefer/avoid 数组
	prefer := make([]int, len(c.ctx.Reg.Regs))
	avoid := make([]int, len(c.ctx.Reg.Regs))
	for _, reg := range c.ctx.Reg.Regs {
		if reg.ClassMask&mask != 0 {
			prefer[reg.RegIndex] = 10 // 高偏好
		}
		if reg.ClassMask&avoidMask != 0 {
			avoid[reg.RegIndex] = 10 // 高厌恶
		}
	}

	reg := c.ctx.Reg.AllocPref(
		exp,
		mask,
		prefer,
		avoid,
		ei.ExpID,
		nil, // user 暂时为空
		avoidReg,
	)
	return reg
}

// regNameFrom 从地址/寄存器文本中提取基址寄存器名（RBX+8 → RBX；
// QWORD[rbx+0x18] → RBX；普通寄存器原样返回；无法识别返回 ""）。
func regNameFrom(addr string) string {
	s := stripMemPrefix(strings.TrimSpace(addr))
	s = strings.ReplaceAll(s, " ", "")
	s = strings.TrimPrefix(s, "[")
	s = strings.TrimSuffix(s, "]")
	end := len(s)
	for i := 0; i < len(s); i++ {
		r := s[i]
		if (r >= 'A' && r <= 'Z') || (r >= 'a' && r <= 'z') || (r >= '0' && r <= '9') {
			continue
		}
		end = i
		break
	}
	base := strings.ToUpper(s[:end])
	switch base {
	case "RAX", "RBX", "RCX", "RDX", "RSI", "RDI", "RSP", "RBP",
		"R8", "R9", "R10", "R11", "R12", "R13", "R14", "R15",
		"EAX", "EBX", "ECX", "EDX", "ESI", "EDI", "ESP", "EBP":
		return base
	}
	return ""
}

// getRegByName 根据寄存器名称获取寄存器对象
func (c *ECompiler) getRegByName(name string) *regmgr.Reg {
	for _, reg := range c.ctx.Reg.Regs {
		if reg.Name == name {
			return reg
		}
	}
	return nil
}

// isF64Type 判断表达式类型是否为 f64（f32 路径保持旧行为：v1 只对 f64 走 SSE2）。
func isF64Type(t typeSys.Type) bool {
	return t != nil && typeSys.CheckKind(t, "float") && t.Type() == "f64"
}

// isF64Imm 判断操作数文本是否为浮点立即数（numLiteral 统一输出 IEEE-754 位模式的
// 16 进制字面量，如 0x4024000000000000）。立即数不能直接 movq 到 XMM，须经 GP 中转。
func isF64Imm(op string) bool {
	return strings.HasPrefix(op, "0x") || strings.HasPrefix(op, "0X")
}

// floatOperandScratch 选择不与操作数/结果冲突的 GP 临时寄存器（用于立即数中转）。
func floatOperandScratch(words ...string) string {
	refs := func(op, reg string) bool {
		rest := strings.ToUpper(strings.TrimSpace(op))
		rest = strings.NewReplacer("[", " ", "]", " ", ",", " ", "+", " ", "-", " ").Replace(rest)
		rest = strings.ToUpper(rest)
		for _, tok := range strings.Fields(rest) {
			switch tok {
			case reg, "E" + reg[1:], "R" + reg[1:]: // RAX/EAX, R8/R8D 由外层按前缀覆盖
				return true
			}
			if strings.HasPrefix(tok, "E"+reg[1:]) || strings.HasPrefix(tok, "R"+reg[1:]) {
				return true
			}
		}
		return strings.Contains(rest, reg)
	}
	for _, reg := range []string{"RAX", "RBX", "RCX", "RDX", "RSI", "RDI", "R8", "R9", "R10", "R11", "R12", "R13", "R14", "R15"} {
		used := false
		for _, w := range words {
			if refs(w, reg) {
				used = true
				break
			}
		}
		if !used {
			return reg
		}
	}
	return "RAX"
}

// emitFloatBin f64 二元运算（SSE2：addsd/subsd/mulsd/divsd；比较 ucomisd + setXX）。
// 现有 ABI 不变：f64 位模式仍以 GP 寄存器/QWORD 内存槽存放；本函数借 XMM0/XMM1
// 做真实的双精度运算后写回 result，修复旧路径用 imul/idiv 处理位模式的缺陷。
func (c *ECompiler) emitFloatBin(exp *parser.Expression, result, lVal, rVal string) string {
	op := exp.Separator
	isCmp := op == "==" || op == "!=" || op == "<" || op == ">" || op == "<=" || op == ">="

	load := func(xmm, operand string, avoid ...string) string {
		if isF64Imm(operand) {
			scratch := floatOperandScratch(append(avoid, result, lVal, rVal)...)
			return utils.Format("mov " + scratch + ", " + operand) +
				utils.Format("movq " + xmm + ", " + scratch)
		}
		return utils.Format("movq " + xmm + ", " + operand)
	}

	arith := func(xop string) string {
		code := load("XMM0", lVal, rVal, result)
		code += load("XMM1", rVal, lVal, result)
		code += utils.Format(xop + " XMM0, XMM1")
		return code + utils.Format("movq " + result + ", XMM0")
	}

	cmpWrite := func(setcc string) string {
		code := utils.Format("ucomisd XMM0, XMM1")
		code += utils.Format(setcc + " al")
		if strings.Contains(result, "[") {
			switch {
			case strings.HasPrefix(result, "BYTE"):
				code += utils.Format("mov " + result + ", al")
			case strings.HasPrefix(result, "WORD"):
				code += utils.Format("movzx RAX, al") + utils.Format("mov " + result + ", ax")
			case strings.HasPrefix(result, "DWORD"):
				code += utils.Format("movzx EAX, al") + utils.Format("mov " + result + ", EAX")
			default:
				code += utils.Format("movzx RAX, al") + utils.Format("mov " + result + ", RAX")
			}
			return code
		}
		return code + utils.Format("movzx " + result + ", al")
	}

	switch op {
	case "+", "-", "*", "/":
		xop := map[string]string{
			"+": "addsd",
			"-": "subsd",
			"*": "mulsd",
			"/": "divsd",
		}[op]
		return arith(xop)
	case "==", "!=", "<", ">", "<=", ">=":
		if !isCmp {
			return ""
		}
		code := load("XMM0", lVal, rVal, result)
		code += load("XMM1", rVal, lVal, result)
		setcc := map[string]string{
			"==": "sete",
			"!=": "setne",
			"<":  "setb",
			"<=": "setbe",
			">":  "seta",
			">=": "setae",
		}[op]
		return code + cmpWrite(setcc)
	}
	// 未覆盖的情况（调用方已限定运算符集，不会到这里）。
	return ""
}

// emitBin
// 生成二元运算指令。
// lVal/rVal 为左右操作数（寄存器名或内存地址），result 为结果目标。
// 结果/操作数为窄内存槽时，寄存器操作数名匹配槽宽度（add DWORD[mem], EAX）。
func (c *ECompiler) emitBin(exp *parser.Expression, result, lVal, rVal, callee string) string {
	var code string
	if exp.Left != nil && exp.Right != nil && isF64Type(exp.Left.Type) && isF64Type(exp.Right.Type) {
		switch exp.Separator {
		case "+", "-", "*", "/", "==", "!=", "<", ">", "<=", ">=":
			return c.emitFloatBin(exp, result, lVal, rVal)
		}
	}

	// 特殊处理 push：就地计算到左操作数寄存器，再 push
	// （不用临时寄存器，避免临时寄存器与右操作数同寄存器导致 sub eax,eax 类错误）
	if result == "push" {
		if callee != "" && lVal != callee {
			code = c.arch.InstBinary(lVal, exp.Separator, callee)
		} else {
			code = c.arch.InstBinary(lVal, exp.Separator, rVal)
		}
		code += utils.Format("push " + lVal)
		return code
	}

	// 如果有 callee-save，使用它
	if callee != "" {
		if lVal == callee {
			// 左在 callee-save：先搬到 result，再运算
			if result != callee {
				code = utils.Format("mov " + result + ", " + matchMemWidth(result, callee))
			}
			code += c.arch.InstBinary(result, exp.Separator, matchMemWidth(result, rVal))
		} else {
			// 右在 callee-save
			if result != lVal {
				code = utils.Format("mov " + result + ", " + matchMemWidth(result, lVal))
			}
			code += c.arch.InstBinary(result, exp.Separator, matchMemWidth(result, callee))
		}
	} else {
		// 普通情况
		if result == lVal {
			// 结果直接写到左操作数寄存器/内存槽
			code = c.arch.InstBinary(lVal, exp.Separator, matchMemWidth(lVal, rVal))
		} else {
			// 需要先 mov 左操作数到 result，再运算
			code = utils.Format("mov " + result + ", " + matchMemWidth(result, lVal))
			code += c.arch.InstBinary(result, exp.Separator, matchMemWidth(result, rVal))
		}
	}

	return code
}

// ============ 列表/字符串（list/string）三字段容器支持 ============

// loadContainerPair 装载容器表达式到 {ptr, len} 寄存器对（常量/变量/函数调用）
func (c *ECompiler) loadContainerPair(exp *parser.Expression, r0, r1 string) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	if exp.IsConst() && isListLike(exp.Type) {
		label := "0"
		if exp.StringVal != "" {
			label = c.getStringLabel(exp.StringVal)
		}
		slen := len(exp.StringVal)
		return utils.Format("mov "+r0+", "+label) +
			utils.Format("mov "+r1+", "+strconv.Itoa(slen))
	}
	if exp.Var != nil && isListLike(exp.Var.Type) {
		if isThisField(exp.Var) {
			// this/self 字段：this 是指针，先经寄存器装载再间接寻址
			p2, addr2, reg2 := c.thisMem(exp.Var)
			code := p2 + utils.Format("mov "+r0+", "+ln+" ["+addr2+"]") +
				utils.Format("mov "+r1+", "+ln+" ["+addr2+"+"+strconv.Itoa(ps)+"]")
			c.freeTmpReg(reg2)
			return code
		}
		src := stripOuterBrackets(c.arch.VarAddr(exp.Var))
		return utils.Format("mov "+r0+", "+ln+" ["+src+"]") +
			utils.Format("mov "+r1+", "+ln+" ["+src+"+"+strconv.Itoa(ps)+"]")
	}
	if exp.Call != nil {
		// Monomorphize generic function calls
		// 单态化：生成/复用特化副本，Func 直接指向特化 FuncBlock
		// （Name/MangledOverride = 特化标签；返回类型已是具体类型）。
		if c.ctx.MonomorphizeCall != nil && exp.Call.Func != nil && len(exp.Call.Func.TypeParams) > 0 {
			c.ctx.MonomorphizeCall(exp.Call)
		}
		code := c.arch.Call(exp.Call)
		retBase := c.arch.FramePtr() + strconv.Itoa(c.ctx.RetSlot)
		code += utils.Format("mov " + r0 + ", " + ln + " [" + retBase + "]")
		code += utils.Format("mov " + r1 + ", " + ln + " [" + retBase + "+" + strconv.Itoa(ps) + "]")
		return code
	}
	// 嵌套表达式（如字符串拼接链的内层）：递归编译到返回槽再装载
	if exp.Separator != "" {
		retBase := c.arch.FramePtr() + strconv.Itoa(c.ctx.RetSlot)
		code := c.generate(exp, "["+retBase+"]")
		return code + utils.Format("mov "+r0+", "+ln+" ["+retBase+"]") +
			utils.Format("mov "+r1+", "+ln+" ["+retBase+"+"+strconv.Itoa(ps)+"]")
	}
	return ""
}

// allocRegSecond 分配除 avoidName 外的另一个空闲寄存器（不记入 Record，需手动 Free）
func (c *ECompiler) allocRegSecond(avoidNames ...string) *regmgr.Reg {
	for _, reg := range c.ctx.Reg.Regs {
		ok := true
		for _, n := range avoidNames {
			if reg.Name == n {
				ok = false
				break
			}
		}
		if ok && reg.Free {
			reg.Free = false
			reg.ExpID = 0
			reg.User = nil
			return reg
		}
	}
	return nil
}

// stringConcatExp 运行期字符串拼接：malloc 新缓冲 + 两段 rep movsb + 双 NUL + 三槽装载
// 左/右容器经 loadContainerPair 装载到寄存器后压栈暂存，避免调用间破坏。
func (c *ECompiler) stringConcatExp(exp *parser.Expression, result string, ei *ExpInfo) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	code := ""

	// 左容器 → 寄存器对 → 压栈（左ptr、左len）
	l0 := c.allocReg(exp.Left)
	l1 := c.allocRegSecond(l0.Name)
	if l0 == nil {
		l0 = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	if l1 == nil {
		l1 = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code += c.loadContainerPair(exp.Left, l0.Name, l1.Name)
	code += utils.Format("push " + l0.Name)
	code += utils.Format("push " + l1.Name)
	c.ctx.Reg.Free(exp.Left)
	l1.Free = true

	// 右容器 → 寄存器对 → 压栈（右ptr、右len）
	r0 := c.allocReg(exp.Right)
	r1 := c.allocRegSecond(r0.Name)
	if r0 == nil {
		r0 = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	if r1 == nil {
		r1 = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code += c.loadContainerPair(exp.Right, r0.Name, r1.Name)
	code += utils.Format("push " + r0.Name)
	code += utils.Format("push " + r1.Name)
	c.ctx.Reg.Free(exp.Right)
	r1.Free = true

	// 固定工作区（跨 call 安全）：
	// x64：pop 到 callee-save R12-R15（malloc 会保存它们）
	// x86：留在栈上（EBX 是唯一 callee-save，作新 ptr；四值经 [esp+N] 访问）
	var rLen, rPtr, lLen, lPtr, tmp1, tmp2, ret string
	ret = c.arch.ReturnReg()
	if ps == 8 {
		code += utils.Format("pop R12") // 右len
		code += utils.Format("pop R13") // 右ptr
		code += utils.Format("pop R14") // 左len
		code += utils.Format("pop R15") // 左ptr
		rLen, rPtr, lLen, lPtr = "R12", "R13", "R14", "R15"
		tmp1, tmp2 = "R9", "RDI"
	} else {
		rLen, rPtr, lLen, lPtr = "0", "4", "8", "12" // [esp+N] 偏移
		tmp1, tmp2 = "EAX", "ECX"
	}

	// total = 左len + 右len；x86 压栈暂存（x64 在 call 后用 R14/R12 重算，
	// 因为 callee 的参数保存槽 [rbp+16] 会落在 caller 的 rsp 处，压栈值会被覆盖）
	if ps == 8 {
		code += utils.Format("mov " + tmp1 + ", " + lLen)
		code += utils.Format("add " + tmp1 + ", " + rLen)
	} else {
		code += utils.Format("mov " + tmp1 + ", [esp+" + lLen + "]")
		code += utils.Format("add " + tmp1 + ", [esp+" + rLen + "]")
		code += utils.Format("push " + tmp1)
	}

	// malloc(align8(total+1))：x64 RDI 传参；x86 压栈传参
	code += utils.Format("lea " + tmp2 + ", [" + tmp1 + "+8]")
	code += utils.Format("and " + tmp2 + ", -8")
	callMalloc := makeMemCall("malloc", []typeSys.Type{typeSys.GetSystemType("uint")})
	if ps == 8 {
		code += utils.Format("mov RDI, "+tmp2) +
			utils.Format("call "+callMalloc.Func.MangledName())
	} else {
		code += utils.Format("push "+tmp2) +
			c.arch.Call(callMalloc)
	}
	code += utils.Format("mov " + ret + ", " + c.arch.ReturnReg())

	// 右段拷贝：dst = new + 左len，src = 右ptr，count = 右len
	if ps == 8 {
		code += utils.Format("mov " + tmp2 + ", " + ret)
		code += utils.Format("add " + tmp2 + ", " + lLen)
		code += utils.Format("mov RSI, " + rPtr)
		code += utils.Format("mov RCX, " + rLen)
	} else {
		// 栈布局（esp→）：[esp+0]=total、[esp+4]=右len、[esp+8]=右ptr、[esp+12]=左len、[esp+16]=左ptr
		code += utils.Format("mov EDI, " + ret)
		code += utils.Format("add EDI, [esp+12]")
		code += utils.Format("mov ESI, [esp+8]")
		code += utils.Format("mov ECX, [esp+4]")
	}
	code += utils.Format("rep movsb")

	// 左段拷贝：dst = new，src = 左ptr，count = 左len
	if ps == 8 {
		code += utils.Format("mov " + tmp2 + ", " + ret)
		code += utils.Format("mov RSI, " + lPtr)
		code += utils.Format("mov RCX, " + lLen)
	} else {
		code += utils.Format("mov EDI, " + ret)
		code += utils.Format("mov ESI, [esp+16]")
		code += utils.Format("mov ECX, [esp+12]")
	}
	code += utils.Format("rep movsb")

	// 双 NUL 终止
	if ps == 8 {
		// 重算 total：R9 已被 call 污染，R14（左len）/R12（右len）为 callee-saved 仍存活
		code += utils.Format("mov " + tmp1 + ", " + lLen)
		code += utils.Format("add " + tmp1 + ", " + rLen)
		code += utils.Format("mov byte [" + ret + "+" + tmp1 + "], 0")
		code += utils.Format("mov byte [" + ret + "+" + tmp1 + "+1], 0")
		// cap = align8(total+1) - 1
		code += utils.Format("lea " + rLen + ", [" + tmp1 + "+8]")
		code += utils.Format("and " + rLen + ", -8")
		code += utils.Format("dec " + rLen)
	} else {
		code += utils.Format("mov EDX, [esp+0]") // total
		code += utils.Format("mov byte [" + ret + "+EDX], 0")
		code += utils.Format("mov byte [" + ret + "+EDX+1], 0")
		code += utils.Format("lea ECX, [EDX+8]")
		code += utils.Format("and ECX, -8")
		code += utils.Format("dec ECX")
		rLen, lLen = "ECX", "EDX"
	}

	// 装载结果三槽 {ptr, len, cap}
	if ps == 8 {
		// x64：rLen 已被覆盖为 cap，total 仍在 tmp1（R9）中
		if result == "push" {
			code += utils.Format("push " + rLen) // cap
			code += utils.Format("push " + tmp1) // len
			code += utils.Format("push " + ret)  // ptr
		} else if strings.Contains(result, "[") {
			// S0-2（P11）：三字段写查表化（data@0/len/cap 经 listFields）
			_, lenOff, capOff := c.listFields()
			code += utils.Format("mov " + ln + " [" + stripOuterBrackets(result) + "], " + ret)
			code += utils.Format("mov " + ln + " [" + stripOuterBrackets(result) + "+" + strconv.Itoa(lenOff) + "], " + tmp1)
			code += utils.Format("mov " + ln + " [" + stripOuterBrackets(result) + "+" + strconv.Itoa(capOff) + "], " + rLen)
		} else {
			code += utils.Format("mov " + result + ", " + ret)
		}
	} else {
		if result == "push" {
			code += utils.Format("push " + rLen) // cap
			code += utils.Format("push " + lLen) // len
			code += utils.Format("push " + ret)  // ptr
		} else if strings.Contains(result, "[") {
			// S0-2（P11）：三字段写查表化
			_, lenOff, capOff := c.listFields()
			code += utils.Format("mov " + ln + " [" + stripOuterBrackets(result) + "], " + ret)
			code += utils.Format("mov " + ln + " [" + stripOuterBrackets(result) + "+" + strconv.Itoa(lenOff) + "], " + lLen)
			code += utils.Format("mov " + ln + " [" + stripOuterBrackets(result) + "+" + strconv.Itoa(capOff) + "], " + rLen)
		} else {
			code += utils.Format("mov " + result + ", " + ret)
		}
	}

	// 清理暂存槽：x86 5 个（total、右len、右ptr、左len、左ptr）；x64 无
	if ps != 8 {
		code += utils.Format("add esp, 20")
	}
	return code
}

// isListLike 判断是否为三字段容器类型（list/string）
func isListLike(t typeSys.Type) bool {
	return t != nil && (t.Kind() == "list" || t.Kind() == "string")
}

// isMultiSlotLeaf 判断叶子表达式是否为多槽值（容器 3 槽 / 结构体 N 槽）
func (c *ECompiler) isMultiSlotLeaf(exp *parser.Expression) bool {
	if exp.IsConst() && isListLike(exp.Type) {
		return true
	}
	if exp.Var != nil && exp.Var.Type != nil {
		if isListLike(exp.Var.Type) {
			return true
		}
		return exp.Var.Type.Size() > c.arch.PointerSize()
	}
	return false
}

// loadMultiSlot 多槽叶子装载：容器 3 槽；结构体按 Size/PointerSize 槽数
func (c *ECompiler) loadMultiSlot(exp *parser.Expression, result string) string {
	if exp.Var != nil && exp.Var.Type != nil && !isListLike(exp.Var.Type) {
		return c.loadStruct(exp.Var, result)
	}
	return c.loadContainer(exp, result)
}

// loadStruct 结构体叶子多槽装载（值语义拷贝：按 PointerSize 分槽）
func (c *ECompiler) loadStruct(v *parser.VarBlock, result string) string {
	if v == nil || v.Type == nil {
		return ""
	}
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	slots := v.Type.Size() / ps
	src := stripOuterBrackets(c.arch.VarAddr(v))
	pre := ""
	if isThisField(v) {
		p2, addr2, reg2 := c.thisMem(v)
		pre = p2
		src = addr2
		defer c.freeTmpReg(reg2)
	} else if needPtrMem(v) {
		p3, addr3, reg3 := c.ptrMem(v)
		pre = p3
		src = addr3
		defer c.freeTmpReg(reg3)
	}
	if result == "push" {
		// 高地址槽先入栈
		var code string
		for i := slots - 1; i >= 0; i-- {
			off := i * ps
			if off == 0 {
				code += utils.Format("push " + ln + " [" + src + "]")
			} else {
				code += utils.Format("push " + ln + " [" + src + "+" + strconv.Itoa(off) + "]")
			}
		}
		return pre + code
	}
	if strings.Contains(result, "[") {
		return pre + c.copySlots(stripOuterBrackets(result), src, slots*ps)
	}
	return pre + utils.Format("mov "+result+", "+ln+" ["+src+"]")
}

// loadContainer 容器（list/string）叶子三槽装载：常量 → {label, len, len}；变量 → 从内存读三槽
func (c *ECompiler) loadContainer(exp *parser.Expression, result string) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	if exp.IsConst() && isListLike(exp.Type) {
		label := "0"
		if exp.StringVal != "" {
			label = c.getStringLabel(exp.StringVal)
		}
		slen := len(exp.StringVal)
		return c.emit3(result, label, slen, slen)
	}
	if exp.Var != nil && isListLike(exp.Var.Type) {
		src := stripOuterBrackets(c.arch.VarAddr(exp.Var))
		pre := ""
		if isThisField(exp.Var) {
			// this/self 字段：this 是指针，先经寄存器装载再间接寻址
			p2, addr2, reg2 := c.thisMem(exp.Var)
			pre = p2
			src = addr2
			defer c.freeTmpReg(reg2)
		} else if needPtrMem(exp.Var) {
			// 指针基字段（p.s）：先加载指针值再间接寻址
			p3, addr3, reg3 := c.ptrMem(exp.Var)
			pre = p3
			src = addr3
			defer c.freeTmpReg(reg3)
		}
		if result == "push" {
			// 高地址槽先入栈：cap、len、ptr
			var code string
			for i := 2; i >= 0; i-- {
				off := i * ps
				code += utils.Format("push " + ln + " [" + src + "+" + strconv.Itoa(off) + "]")
			}
			return pre + code
		}
		if strings.Contains(result, "[") {
			return pre + c.copySlots(stripOuterBrackets(result), src, 3*ps)
		}
		return pre + utils.Format("mov "+result+", "+ln+" ["+src+"]")
	}
	return ""
}

// emitNarrowCastFromMultiSlot 处理 `unsafe.cast[T](v)` 中 v 为多槽值（string/list/
// struct 值，Size > 指针宽）而 T ≤ 指针宽的情形：按 §11.3“位级重解释”保留 v 的
// 低 sizeof(T) 字节（小端序 = 头字段 data）。目的与叶子多槽装载保持一致：
// push → 只入栈低槽；内存槽 → 按 T 宽度只写目标槽前的字段；否则取寄存器。
func (c *ECompiler) emitNarrowCastFromMultiSlot(call *parser.CallBlock, arg *parser.Expression, result string) string {
	dst := call.NewType
	if dst == nil {
		return ""
	}
	ps := c.arch.PointerSize()
	dstSize := dst.Size()
	if dstSize <= 0 || dstSize > ps {
		return "" // 目标不窄：常规路径
	}
	if result == "push" && dstSize != ps {
		return "" // 窄 push 罕见，回退旧路径
	}
	var pre, src string
	if arg.Call != nil && arg.Call.Func != nil && len(arg.Call.Func.Return) > 0 && arch.FuncReturnsLarge(arg.Call.Func) {
		// 大值返回调用：直接从返回槽读低字
		src = c.arch.FramePtr() + strconv.Itoa(c.ctx.RetSlot)
	} else if arg.Var != nil && arg.Var.Type != nil {
		vt := arg.Var.Type
		multi := vt.Size() > ps || isListLike(vt)
		if !multi {
			return ""
		}
		src = stripOuterBrackets(c.arch.VarAddr(arg.Var))
		if isThisField(arg.Var) {
			p2, addr2, reg2 := c.thisMem(arg.Var)
			pre = p2
			src = addr2
			defer c.freeTmpReg(reg2)
		} else if needPtrMem(arg.Var) {
			p3, addr3, reg3 := c.ptrMem(arg.Var)
			pre = p3
			src = addr3
			defer c.freeTmpReg(reg3)
		}
	} else {
		return ""
	}
	wmem := map[int]string{1: "BYTE", 2: "WORD", 4: "DWORD", 8: "QWORD"}[dstSize]
	// 装载/存储同一子寄存器（AL/AX/EAX；x86_64 ps==8 时为 RAX）
	wreg := map[int]string{1: "AL", 2: "AX", 4: "EAX", 8: c.arch.ReturnReg()}[dstSize]
	// 装载低字到返回寄存器（AL/AX/EAX 写自然清零高位；窄目标同理保留低位）
	var code string
	if dstSize == ps {
		code = pre + utils.Format("mov "+c.arch.ReturnReg()+", "+wmem+" ["+src+"]")
	} else {
		code = pre + utils.Format("mov "+wreg+", "+wmem+" ["+src+"]")
	}
	if result == "" {
		return code
	}
	retReg := c.arch.ReturnReg()
	if result == "push" {
		// 此路 dstSize==ps
		return code + utils.Format("push "+retReg)
	}
	if strings.Contains(result, "[") {
		// 去宽度前缀（QWORD[rbp-X]、QWORD [rbp-X]、[rbp-X]）后补 T 宽度
		base := stripOuterBrackets(result)
		if strings.TrimSpace(base) == "" {
			return "" // 无法识别的槽形态，回退旧路径
		}
		return code + utils.Format("mov "+wmem+" ["+base+"], "+wreg)
	}
	if dstSize == ps {
		if result != retReg {
			return code + utils.Format("mov "+result+", "+retReg)
		}
		return code
	}
	return "" // 窄寄存器目标罕见，回退旧路径
}

// listHeaderShape（S0-2，P11 编译器通道）：内建容器三字段偏移的**唯一查询源**。
// 全编译器所有 24B 头布局知识收敛到 typeSys ListType.Shape()——
// 布局由 StructType.Layout 自然计算（x64=0/8/16 Go 序；x86=0/4/8），
// exp.go 内不再存在任何 +ps/+2*ps 式字面算术。进程内单值缓存（TargetPointerSize 恒定）。
func (c *ECompiler) listHeaderShape() *typeSys.StructType {
	sh := typeSys.NewList(typeSys.GetSystemType("int")).Shape()
	return sh
}

func (c *ECompiler) listShapeField(sh *typeSys.StructType, name string) int {
	sh.Layout()
	return sh.Field(name).Offset
}

// listFields 返回三字段偏移（x64: 0/8/16；x86: 0/4/8）——S0-2 查表化（P11）
func (c *ECompiler) listFields() (ptr, length, cap int) {
	sh := c.listHeaderShape()
	return c.listShapeField(sh, "data"), c.listShapeField(sh, "len"), c.listShapeField(sh, "cap")
}

// takeFreeReg 挑一个默认类别的空闲寄存器（masked 掉 avoid 名单）。
// 绕开 AllocPref 的 Record[exp] 复用语义（同一 exp 二次分配会命中同寄
// 存器），不绑 exp：调用方用完手动置 reg.Free = true。
func (c *ECompiler) takeFreeReg(avoidNames ...string) *regmgr.Reg {
	mask := c.ctx.Arch.DefaultRegMask()
	for _, r := range c.ctx.Reg.Regs {
		if r.ClassMask&mask == 0 || !r.Free {
			continue
		}
		skip := false
		for _, n := range avoidNames {
			if r.Name == n {
				skip = true
				break
			}
		}
		if !skip {
			return r
		}
	}
	return nil
}

// listBaseResolve（S0-1/S0-2，P11 底座）：bounds 与元素寻址共用的成员链基址解析。
//
// 返回 (pre 代码, addr 文本, 持有的寄存器)。addr 即后续比较/寻址所用的
// 基址文本（最终字段链地址）：
//   - 值语义（裸局部变量、局部 struct 值的字段链）：passthrough——返回
//     baseText 原样、reg 为 nil，调用方 `[addr+off]` 栈槽直拼（逐位不变）；
//   - self/this 成员链（isThisField）：委托 thisMem（解引 thisHome 槽 +
//     fieldOffsetOf 偏移捆绑，A5 病灶修复：bounds 原直拼 [rbp-48+8] 读
//     相邻栈槽垃圾）；
//   - 多指针装载链（needPtrMem：p.x / g.head.next 等）：委托 ptrMem
//     （S0-2 全量合流：中间层逐层装载 + 全局基址 [rel __global_x]）。
//
// 合流纪律：基址语义只有本 helper 一处判定——新链型必须在此加路由，
// 禁止 bounds/元素寻址两侧各自直拼分叉（M2a/M3 两轨分叉的历史教训）。
// 持有寄存器用完由调用方 freeTmpReg 释放（与 thisMem/ptrMem 既有调用方
// 一致）。保守边界：allocTmpReg 枯竭 fallback 返回伪 ReturnReg 对象，
// 真实 RAX 未持有且可能被调用方后续 alloc 复用互踩——退回 passthrough。
func (c *ECompiler) listBaseResolve(v *parser.VarBlock, avoidReg, baseText string) (string, string, *regmgr.Reg) {
	if v == nil || len(v.Name) <= 1 {
		// 值语义：裸局部变量直拼
		return "", baseText, nil
	}
	if !isThisField(v) && !needPtrMem(v) {
		// 局部 struct 值的字段链等：栈槽直拼已经正确
		return "", baseText, nil
	}
	var pre, addr string
	var reg *regmgr.Reg
	if isThisField(v) {
		pre, addr, reg = c.thisMem(v)
	} else {
		pre, addr, reg = c.ptrMem(v)
	}
	if reg != nil && reg.Name == c.arch.ReturnReg() {
		// allocTmpReg 枯竭 fallback 返回伪 ReturnReg 对象：极端枯竭保守
		// 退回 passthrough（与旧行为等价，不引入新缺陷）。
		return "", baseText, nil
	}
	return pre, addr, reg
}

// align8 向上取整到 8 字节
func align8(n int) int { return (n + 7) &^ 7 }

// maxInt(a, b) 较大值
func maxInt(a, b int) int { if a > b { return a }; return b }

// getStringLabel 获取/注册字符串常量标签
func (c *ECompiler) getStringLabel(val string) string {
	if label, ok := c.ctx.StringConsts[val]; ok {
		return label
	}
	c.ctx.StrCount++
	label := "str_" + strconv.Itoa(c.ctx.StrCount)
	c.ctx.StringConsts[val] = label
	return label
}

// makeMemFunc 构建 memory 包函数的合成 FuncBlock（用于 emitMalloc/emitFree/emitRealloc）。
// CallBlock → arch.Call() → formatFuncName(fn) → MangledName() 自动产生正确标签。
func makeMemFunc(funcName string, argTypes []typeSys.Type) *parser.FuncBlock {
	nameParts := []parser.NamePart{
		{Name: "std_memory", IsPkgPath: true},
		{Name: funcName},
	}
	fb := &parser.FuncBlock{
		Name: parser.Name(nameParts),
	}
	for _, t := range argTypes {
		fb.Args = append(fb.Args, &parser.ArgBlock{Type: t})
	}
	return fb
}

// makeGCFunc 构建 memory 包中 RC 函数的合成 FuncBlock（用于 rcInc/rcDec）
func makeGCFunc(funcName string, argTypes []typeSys.Type) *parser.FuncBlock {
	nameParts := []parser.NamePart{
		{Name: "std_memory", IsPkgPath: true},
		{Name: funcName},
	}
	fb := &parser.FuncBlock{
		Name: parser.Name(nameParts),
	}
	for _, t := range argTypes {
		fb.Args = append(fb.Args, &parser.ArgBlock{Type: t})
	}
	return fb
}

// makeGCCall 构建 memory 包中 RC 函数的 CallBlock
func makeGCCall(funcName string, argTypes []typeSys.Type) *parser.CallBlock {
	fb := makeGCFunc(funcName, argTypes)
	args := make([]*parser.ArgBlock, len(fb.Args))
	copy(args, fb.Args)
	return &parser.CallBlock{
		Name: fb.Name,
		Func: fb,
		Args: args,
	}
}

// makeMemCall 构建 memory 包函数的 CallBlock，caller 已按约定压好参数。
func makeMemCall(funcName string, argTypes []typeSys.Type) *parser.CallBlock {
	fb := makeMemFunc(funcName, argTypes)
	args := make([]*parser.ArgBlock, len(fb.Args))
	copy(args, fb.Args)
	return &parser.CallBlock{
		Name: fb.Name,
		Func: fb,
		Args: args,
	}
}

// emitMalloc 调用运行时 malloc（返回 RAX/EAX），按架构选择调用约定
func (c *ECompiler) emitMalloc(size int) string {
	call := makeMemCall("malloc", []typeSys.Type{typeSys.GetSystemType("uint")})
	if c.arch.PointerSize() == 8 {
		return utils.Format("mov RDI, "+strconv.Itoa(size)) +
			utils.Format("call "+call.Func.MangledName())
	}
	// arch.Call 已含 cdecl 清理（add esp, 4），不再重复清理
	return utils.Format("push "+strconv.Itoa(size)) +
		c.arch.Call(call)
}

// emitRealloc 调用运行时 realloc（返回 RAX/EAX），按架构选择调用约定
func (c *ECompiler) emitRealloc(ptrReg, sizeReg string) string {
	call := makeMemCall("realloc", []typeSys.Type{typeSys.GetSystemType("ptr"), typeSys.GetSystemType("uint")})
	if c.arch.PointerSize() == 8 {
		return utils.Format("mov RDI, "+ptrReg) +
			utils.Format("mov RSI, "+sizeReg) +
			utils.Format("call "+call.Func.MangledName())
	}
	return utils.Format("push "+sizeReg) +
		utils.Format("push "+ptrReg) +
		c.arch.Call(call)
}

// emitFree 调用运行时 free（按架构选择调用约定）
func (c *ECompiler) emitFree(ptrReg string) string {
	call := makeMemCall("free", []typeSys.Type{typeSys.GetSystemType("ptr")})
	if c.arch.PointerSize() == 8 {
		return utils.Format("mov RDI, "+ptrReg) +
			utils.Format("call "+call.Func.MangledName())
	}
	// arch.Call 已含 cdecl 清理，不再重复
	return utils.Format("push "+ptrReg) +
		c.arch.Call(call)
}

// emitMallocRC 调用运行时 mallocRC（返回 RAX/EAX），按架构选择调用约定
func (c *ECompiler) emitMallocRC(size int) string {
	call := makeMemCall("mallocRC", []typeSys.Type{typeSys.GetSystemType("uint")})
	if c.arch.PointerSize() == 8 {
		return utils.Format("mov RDI, "+strconv.Itoa(size)) +
			utils.Format("call "+call.Func.MangledName())
	}
	return utils.Format("push "+strconv.Itoa(size)) +
		c.arch.Call(call)
}

// emitRCInc 调用 gc.rcInc(ptr)，增加引用计数
func (c *ECompiler) emitRCInc(ptrReg string) string {
	call := makeGCCall("rcInc", []typeSys.Type{typeSys.GetSystemType("ptr")})
	if c.arch.PointerSize() == 8 {
		return utils.Format("mov RDI, "+ptrReg) +
			utils.Format("call "+call.Func.MangledName())
	}
	return utils.Format("push "+ptrReg) +
		c.arch.Call(call)
}

// emitRCDec 调用 gc.rcDec(ptr) bool，减少引用计数；归零时释放
func (c *ECompiler) emitRCDec(ptrReg string) string {
	ps := c.arch.PointerSize()
	call := makeGCCall("rcDec", []typeSys.Type{typeSys.GetSystemType("ptr")})
	if ps == 8 {
		return utils.Format("mov RDI, "+ptrReg) +
			utils.Format("call "+call.Func.MangledName()) +
			// rcDec 返回 bool 在 AL，零扩展到 RAX
			utils.Format("movzx EAX, AL")
	}
	return utils.Format("push "+ptrReg) +
		c.arch.Call(call)
}

// storeVal 将 val（寄存器/常量/内存）写入内存槽 dst
func (c *ECompiler) storeVal(dst, ln, val string) string {
	if !strings.Contains(dst, "[") {
		dst = "[" + dst + "]"
	}
	if strings.Contains(val, "[") {
		tmp := c.arch.ReturnReg()
		code := utils.Format("mov " + tmp + ", " + val)
		return code + utils.Format("mov "+ln+" "+dst+", "+matchMemWidth(dst, tmp))
	}
	if isRegLike(val) {
		return utils.Format("mov " + ln + " " + dst + ", " + matchMemWidth(dst, val))
	}
	// 64 位槽 + 纯数值：imm32 编码会被符号扩展（4294967295 → -1 全 F），
	// 超出有符号 imm32 的常量经 64 位寄存器中转
	if ln == "QWORD" {
		if n, err := strconv.ParseFloat(val, 64); err == nil &&
			(n > 2147483647 || n < -2147483648) {
			tmp := c.arch.ReturnReg()
			return utils.Format("movabs "+tmp+", "+strconv.FormatInt(int64(n), 10)) +
				utils.Format("mov "+dst+", "+tmp)
		}
	}
	return utils.Format("mov " + ln + " " + dst + ", " + val)
}

// emitZero3 将三字段容器槽清零（内存/寄存器/push）——S0-2：偏移经形状查表
func (c *ECompiler) emitZero3(result string) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	if result == "push" {
		return utils.Format("push 0") + utils.Format("push 0") + utils.Format("push 0; 空容器")
	}
	if strings.Contains(result, "[") {
		sh := c.listHeaderShape()
		lenOff := c.listShapeField(sh, "len")
		capOff := c.listShapeField(sh, "cap")
		base := stripOuterBrackets(result)
		code := utils.Format("mov " + ln + " " + result + ", 0")
		code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "], 0")
		code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "], 0; 空容器")
		return code
	}
	return utils.Format("xor " + result + ", " + result)
}

// emit3 将 {ptr, len, cap} 三字段装载到 result（内存/寄存器/push）
// push 顺序：cap/len/ptr（ptr 最后入栈落在低地址，与 callee 参数槽序一致）
// S0-2：偏移经形状查表（P11——布局知识唯一来源 typeSys.ListType.Shape()）
func (c *ECompiler) emit3(result, ptrReg string, length, cap int) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	if result == "push" {
		code := utils.Format("push " + strconv.Itoa(cap))
		code += utils.Format("push " + strconv.Itoa(length))
		code += utils.Format("push " + ptrReg)
		return code
	}
	if strings.Contains(result, "[") {
		sh := c.listHeaderShape()
		lenOff := c.listShapeField(sh, "len")
		capOff := c.listShapeField(sh, "cap")
		base := stripOuterBrackets(result)
		code := utils.Format("mov " + ln + " " + result + ", " + matchMemWidth(result, ptrReg))
		code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "], " + strconv.Itoa(length))
		code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "], " + strconv.Itoa(cap))
		return code
	}
	return utils.Format("mov " + result + ", " + ptrReg)
}

// pickCalleeSaveAvoid 选择一个当前字面量嵌套深度中未被占用的 callee-save 寄存器。
// 外层列表字面量占用的 callee-save 通过 c.ctx.ListLitAvoid 传递，
// 嵌套列表字面量据此避开冲突；x86 仅有 EBX 一个 callee-save，嵌套深度仍
// 受限（预存限制），x86_64 有 R12-R15 可用。
func (c *ECompiler) pickCalleeSaveAvoid(extra []string) string {
	saves := c.arch.CalleeSaveRegs()
	avoid := append([]string{}, c.ctx.ListLitAvoid...)
	// 编译器在 binLR/binRL/条件求值中硬编码用 CalleeSaveReg()（SysV=RBX）做左侧
	// 暂存，完全不经过分配器——picker 必须始终避开。
	avoid = append(avoid, c.arch.CalleeSaveReg())
	avoid = append(avoid, extra...)
	for _, name := range saves {
		ok := true
		for _, av := range avoid {
			if name == av {
				ok = false
				break
			}
		}
		if ok {
			return name
		}
	}
	// 全部占用时退回首选（与原行为一致）
	return c.arch.CalleeSaveReg()
}

// listLiteral 运行时分配列表字面量（Go 语义：ptr/len/cap 三字段）
func (c *ECompiler) listLiteral(exp *parser.Expression, result string) string {
	lt, ok := exp.Type.(*typeSys.ListType)
	if !ok || lt.Elem() == nil {
		return ""
	}
	elemSize := lt.Elem().Size()
	ps := c.arch.PointerSize()
	ptrOff, lenOff, capOff := c.listFields()
	n := len(exp.ListElems)

	// 空列表 = {0,0,0}
	if n == 0 {
		return c.emitZero3(result)
	}

	code := c.emitMalloc(align8(n * elemSize))
	callee := c.pickCalleeSaveAvoid(nil)
	c.ctx.ListLitAvoid = append(c.ctx.ListLitAvoid, callee)
	defer func() { c.ctx.ListLitAvoid = c.ctx.ListLitAvoid[:len(c.ctx.ListLitAvoid)-1] }()
	code += utils.Format("mov " + callee + ", " + c.arch.ReturnReg() + "; list buffer")

	// 逐元素装载
	for i, elem := range exp.ListElems {
		off := i * elemSize
		if elem.Type != nil && elem.Type.Kind() == "string" {
			// string 元素：三槽（ptr/len/cap）
			if elem.IsConst() {
				label := "0"
				if elem.StringVal != "" {
					label = c.getStringLabel(elem.StringVal)
				}
				slen := len(elem.StringVal)
				code += utils.Format("mov " + c.arch.LengthName(ps) + " [" + callee + "+" + strconv.Itoa(off+ptrOff) + "], " + label)
				code += utils.Format("mov " + c.arch.LengthName(ps) + " [" + callee + "+" + strconv.Itoa(off+lenOff) + "], " + strconv.Itoa(slen))
				code += utils.Format("mov " + c.arch.LengthName(ps) + " [" + callee + "+" + strconv.Itoa(off+capOff) + "], " + strconv.Itoa(slen))
				continue
			}
			// 非常量 string：整体三槽拷贝（元素必须是变量）
			if elem.Var != nil {
				src := stripOuterBrackets(c.arch.VarAddr(elem.Var))
				code += c.copySlots(callee+"+"+strconv.Itoa(off), src, ps)
				continue
			}
			return ""
		}
		if elem.Type != nil && elem.Type.Kind() == "list" {
			// 列表元素：3 槽整体写/复制（与 string 元素同构）。
			// 非常量元素（列表字面量/调用）必须走带括号的目标地址：
			// emit3 在结果为内存形式时会整体写 ptr/len/cap 三槽；
			// 直接写 callee+off 会漏掉 len/cap，读端按三槽解释会崩溃。
			if elem.Var != nil {
				src := stripOuterBrackets(c.arch.VarAddr(elem.Var))
				code += c.copySlots(callee+"+"+strconv.Itoa(off), src, ps)
				continue
			}
			code += c.generate(elem, "["+callee+"+"+strconv.Itoa(off)+"]")
			continue
		}
		if elem.IsConst() && typeSys.CheckKind(elem.Type, "int", "uint", "float") {
			val := numLiteral(elem)
			code += utils.Format("mov " + c.arch.LengthName(elemSize) + " [" + callee + "+" + strconv.Itoa(off) + "], " + val)
			continue
		}
		// 非常量标量：算到独立寄存器再写槽（避开 callee）
		rReg := c.allocRegAvoid(elem, callee)
		if rReg == nil {
			rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		code += c.generate(elem, rReg.Name)
		code += utils.Format("mov " + c.arch.LengthName(elemSize) + " [" + callee + "+" + strconv.Itoa(off) + "], " + matchMemWidth(c.arch.LengthName(elemSize)+"[", rReg.Name))
		c.ctx.Reg.Free(elem)
	}

	// 结果三字段
	return code + c.emit3(result, callee, n, n)
}

// arrayLiteral 栈分配数组字面量 [N]T{...}
func (c *ECompiler) arrayLiteral(exp *parser.Expression, result string) string {
	at, ok := exp.Type.(*typeSys.ArrayType)
	if !ok || at.Elem() == nil {
		return ""
	}
	elemSize := at.Elem().Size()
	ps := c.arch.PointerSize()
	arrLen := at.Len()
	totalSize := arrLen * elemSize
	ln := c.arch.LengthName(elemSize)

	// 如果 result 是内存地址（如 DWORD[ebp-16]），直接写入该地址
	if strings.Contains(result, "[") {
		code := ""
		// Try to extract base offset from result to compute element addresses
		baseOffset, hasOffset := c.arch.ExtractOffset(result)
		// Extract size prefix (e.g., "DWORD ") if present
		sizePrefix := ""
		if idx := strings.Index(result, "["); idx > 0 {
			sizePrefix = result[:idx]
		}
		for i, elem := range exp.ListElems {
			off := i * elemSize
			var elemAddr string
			// movInstr is the instruction prefix; when elemAddr already has size prefix, skip ln
			movInstr := "mov " + ln + " "
			if hasOffset {
				elemAddr = sizePrefix + c.arch.FormatAddr(baseOffset+off)
				if sizePrefix != "" {
					movInstr = "mov " // elemAddr already includes DWORD/QWORD
				}
			} else {
				elemAddr = result + "+" + strconv.Itoa(off)
			}
			if elem.IsConst() && typeSys.CheckKind(elem.Type, "int", "uint", "float") {
				val := numLiteral(elem)
				code += utils.Format(movInstr + elemAddr + ", " + val)
			} else if elem.IsConst() && typeSys.CheckKind(elem.Type, "string") {
				label := "0"
				if elem.StringVal != "" {
					label = c.getStringLabel(elem.StringVal)
				}
				code += utils.Format(movInstr + elemAddr + ", " + label)
			} else {
				rReg := c.allocRegAvoid(elem, result)
				if rReg == nil {
					rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
				}
				code += c.generate(elem, rReg.Name)
				code += utils.Format(movInstr + elemAddr + ", " + matchMemWidth(ln+"[", rReg.Name))
				c.ctx.Reg.Free(elem)
			}
		}
		return code
	}

	// 否则分配栈空间，返回地址到 result
	code := utils.Format("sub rsp, " + strconv.Itoa(totalSize) + "; array " + strconv.Itoa(arrLen) + " elements")
	code += utils.Format("mov " + result + ", rsp; array base addr")

	for i, elem := range exp.ListElems {
		off := i * elemSize
		if elem.IsConst() && typeSys.CheckKind(elem.Type, "int", "uint", "float") {
			val := numLiteral(elem)
			code += utils.Format("mov " + ln + " [" + result + "+" + strconv.Itoa(off) + "], " + val)
		} else if elem.IsConst() && typeSys.CheckKind(elem.Type, "string") {
			label := "0"
			if elem.StringVal != "" {
				label = c.getStringLabel(elem.StringVal)
			}
			code += utils.Format("mov " + c.arch.LengthName(ps) + " [" + result + "+" + strconv.Itoa(off) + "], " + label)
		} else {
			rReg := c.allocRegAvoid(elem, result)
			if rReg == nil {
				rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
			}
			code += c.generate(elem, rReg.Name)
			code += utils.Format("mov " + ln + " [" + result + "+" + strconv.Itoa(off) + "], " + matchMemWidth(ln+"[", rReg.Name))
			c.ctx.Reg.Free(elem)
		}
	}

	return code
}

// copySlots 按指针宽度槽从 src 拷贝 size 字节到 dst（裸地址）。
// src 常是 RAX（emitMalloc 返回值），不能边拷边踩：先用 lea 把 src
// 地址暂存到临时寄存器，然后逐槽经 RAX 中转；dst 为带前缀的宽度形式时
// 原样拼接。
func (c *ECompiler) copySlots(dst, src string, size int) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	base := stripOuterBrackets(src)
	// 不借助临时寄存器做 lea：源槽位可以直接拼入内存操作数
	// （rbp-64+8 → [rbp-64+8]；rel __global_x+8 → [rel __global_x+8]）。
	// 裸寄存器（堆上多槽对象指针）在第一次装载后会被覆盖，先搬进临时寄存器做基址。
	var code string
	var tmp *regmgr.Reg
	if isRegLike(base) {
		tmp = c.allocTmpReg()
		code += utils.Format("mov " + tmp.Name + ", " + base + "; copySlots base")
		base = tmp.Name
	}
	for off := 0; off < size; off += ps {
		srcPart := base
		if off != 0 {
			srcPart += "+" + strconv.Itoa(off)
		}
		code += utils.Format("mov " + c.arch.ReturnReg() + ", " + ln + " [" + srcPart + "]")
		code += utils.Format("mov " + ln + " [" + dst + "+" + strconv.Itoa(off) + "], " + c.arch.ReturnReg())
	}
	if tmp != nil {
		c.freeTmpReg(tmp)
	}
	return code
}

// ============ map 内建支持（Phase 3） ============
//
// map 值语义 = 单个 std:maps 的 mapHdr*（见 type.MapType.Size）。
// 索引读/写不经过 parser lowering 的普通 CallBlock，而是在这里按
// SysV 寄存器约定手工发 maps.get/set/new 调用：
//   - 需要先求值 key/值到本帧栈临时区，避免伪造 out 指针表达式；
//   - nil map 读返回零值；nil map 写自动 maps.new 初始化并写回左值；
//   - x86_64 为当前门槛，32 位路径留待 Batch 4（返回空串 = 未实现）。

// sysvMapArgRegs 仅供 map 手工调用使用；与 arch/x86_64 的 sysvArgRegs 同序。
var sysvMapArgRegs = []string{"RDI", "RSI", "RDX", "RCX", "R8", "R9"}

// mapKeySlots 返回键类型在 SysV 调用中占用的槽数。
func mapKeySlots(t typeSys.Type) int {
	if t == nil {
		return 1
	}
	if t.Kind() == "string" {
		return 3
	}
	n := arch.ArgSlots(t)
	if n < 1 {
		n = 1
	}
	return n
}

// mapTempBytes 将值大小向上取整到指针槽。
func mapTempBytes(size, ps int) int {
	if size <= 0 {
		size = ps
	}
	if rem := size % ps; rem != 0 {
		size += ps - rem
	}
	return size
}

// mapAlign16 保持 rsp 16 字节对齐（调用点 ABI 要求）。
func mapAlign16(n int) int {
	if rem := n % 16; rem != 0 {
		n += 16 - rem
	}
	return n
}

// intrinsicGenericLabel 取 std 包泛型函数的单态化标签。
// fnName 为 std:maps 包内函数名；argTypes 为调用实参类型（用于推断 K）。
func (c *ECompiler) intrinsicGenericLabel(fnName string, argTypes []typeSys.Type) string {
	fb := parser.LookupIntrinsicFunc("std:maps", fnName)
	if fb == nil {
		return ""
	}
	args := make([]*parser.ArgBlock, len(argTypes))
	for i, t := range argTypes {
		args[i] = &parser.ArgBlock{Type: t}
	}
	if c.ctx.MonomorphizeCall != nil {
		if label := c.ctx.MonomorphizeCall(&parser.CallBlock{Func: fb, Args: args, Name: fb.Name}); label != "" {
			return label
		}
	}
	if len(fb.TypeParams) > 0 {
		return ""
	}
	return fb.MangledName()
}

// emitMapKeyToTemp 将键表达式求值到 [rsp+off] 的 kslots 个槽。
func (c *ECompiler) emitMapKeyToTemp(key *parser.Expression, off int, kt typeSys.Type, kslots int) string {
	if key == nil {
		return ""
	}
	if kt != nil && kt.Kind() == "string" {
		// 容器三槽：loadContainer/emit3 直接写内存目标
		return c.generate(key, "[rsp+"+strconv.Itoa(off)+"]")
	}
	if kslots > 1 {
		// 多槽键（结构体等）：按值拷贝到临时区
		return c.generate(key, "[rsp+"+strconv.Itoa(off)+"]")
	}
	width := "QWORD"
	if kt != nil && kt.Size() > 0 && kt.Size() <= c.arch.PointerSize() {
		if w := c.arch.LengthName(kt.Size()); w != "" {
			width = w
		}
	}
	return c.generate(key, width+" [rsp+"+strconv.Itoa(off)+"]")
}

// emitMapKeyToScratch 将键表达式求值到 [scratch+off] 的 kslots 个槽（map 字面量暂存区）。
func (c *ECompiler) emitMapKeyToScratch(key *parser.Expression, scratch string, off int, kt typeSys.Type, kslots int) string {
	if key == nil {
		return ""
	}
	addr := "[" + scratch + "+" + strconv.Itoa(off) + "]"
	if kt != nil && kt.Kind() == "string" {
		// 容器三槽：loadContainer/emit3 直接写内存目标
		return c.generate(key, addr)
	}
	if kslots > 1 {
		return c.generate(key, addr)
	}
	width := "QWORD"
	if kt != nil && kt.Size() > 0 && kt.Size() <= c.arch.PointerSize() {
		if w := c.arch.LengthName(kt.Size()); w != "" {
			width = w
		}
	}
	return c.generate(key, width+" "+addr)
}

// emitMapValueTempStoreScratch 将值表达式求值到 [scratch+off]（值大小 size 字节）。
func (c *ECompiler) emitMapValueTempStoreScratch(value *parser.Expression, scratch string, off, size int) string {
	if value == nil {
		return ""
	}
	addr := "[" + scratch + "+" + strconv.Itoa(off) + "]"
	if size > c.arch.PointerSize() {
		return c.generate(value, addr)
	}
	width := "QWORD"
	if size > 0 {
		if w := c.arch.LengthName(size); w != "" {
			width = w
		}
	}
	return c.generate(value, width+" "+addr)
}

// emitMapCallScratchArgRegs 从 [scratch+keyOff] 装载键槽到 SysV 参数寄存器（从 start 起）。
func emitMapCallScratchArgRegs(scratch string, start, keyOff, keySlots int) string {
	var code string
	for j := 0; j < keySlots; j++ {
		idx := start + j
		if idx >= len(sysvMapArgRegs) {
			break
		}
		code += utils.Format("mov " + sysvMapArgRegs[idx] + ", QWORD [" + scratch + "+" + strconv.Itoa(keyOff+j*8) + "]")
	}
	return code
}

// emitMapValueTempStore 将值表达式求值到 [rsp+off]（值大小 size 字节）。
func (c *ECompiler) emitMapValueTempStore(value *parser.Expression, off, size int) string {
	if value == nil {
		return ""
	}
	if size > c.arch.PointerSize() {
		return c.generate(value, "[rsp+"+strconv.Itoa(off)+"]")
	}
	width := "QWORD"
	if size > 0 {
		if w := c.arch.LengthName(size); w != "" {
			width = w
		}
	}
	return c.generate(value, width+" [rsp+"+strconv.Itoa(off)+"]")
}

// emitMapCallArgRegs 从 [rsp+keyOff] 装载键槽到 SysV 参数寄存器（从 start 起）。
func emitMapCallArgRegs(start, keyOff, keySlots int) string {
	var code string
	for j := 0; j < keySlots; j++ {
		idx := start + j
		if idx >= len(sysvMapArgRegs) {
			break
		}
		code += utils.Format("mov " + sysvMapArgRegs[idx] + ", QWORD [rsp+" + strconv.Itoa(keyOff+j*8) + "]")
	}
	return code
}

// emitMapTempResultScratch 把 [staging+off] 的暂存区值交付到 result。
func (c *ECompiler) emitMapTempResultScratch(result, staging string, off, size int) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	if size <= ps {
		w := ln
		if size > 0 {
			if x := c.arch.LengthName(size); x != "" {
				w = x
			}
		}
		var code string
		switch w {
		case "BYTE", "WORD":
			code = utils.Format("movzx RAX, " + w + " [" + staging + "+" + strconv.Itoa(off) + "]")
		case "DWORD":
			code = utils.Format("mov EAX, DWORD [" + staging + "+" + strconv.Itoa(off) + "]")
		default:
			code = utils.Format("mov RAX, QWORD [" + staging + "+" + strconv.Itoa(off) + "]")
		}
		if result == "push" {
			return code + utils.Format("push RAX")
		}
		if result == "" {
			return code
		}
		if strings.Contains(result, "[") {
			dst := result
			if memPrefix(dst) == "" {
				dst = w + " " + dst
			}
			return code + utils.Format("mov "+dst+", "+matchMemWidth(dst, "RAX"))
		}
		return code + utils.Format("mov "+result+", RAX")
	}

	slots := mapTempBytes(size, ps) / ps
	if result == "push" {
		var code string
		for i := slots - 1; i >= 0; i-- {
			code += utils.Format("push " + ln + " [" + staging + "+" + strconv.Itoa(off+i*ps) + "]")
		}
		return code
	}
	if strings.Contains(result, "[") {
		return c.copySlots(stripOuterBrackets(result), staging+"+"+strconv.Itoa(off), slots*ps)
	}
	// 寄存器目标只承载首槽（多槽值通常走内存/push 交付）
	return utils.Format("mov " + result + ", " + ln + " [" + staging + "+" + strconv.Itoa(off) + "]")
}

// mapScratchBareRegResult 把 [staging+off] 的暂存区值交付到“裸寄存器”result。
// std_memory_free 会破坏 RAX 等 caller-saved 寄存器，因此：
// 先把单槽/首槽值装入一个独立的 callee-save 寄存器 tres（Force 钉住，防被内部再占用），
// 再发 free 调用，最后从 tres 交付给 result。
func (c *ECompiler) mapScratchBareRegResult(exp *parser.Expression, result, staging string, off, size int) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	res := c.pickCalleeSaveAvoid(nil)
	if reg := c.getRegByName(res); reg != nil {
		c.ctx.Reg.Force(reg, exp)
	}
	c.ctx.ListLitAvoid = append(c.ctx.ListLitAvoid, res)
	defer func() { c.ctx.ListLitAvoid = c.ctx.ListLitAvoid[:len(c.ctx.ListLitAvoid)-1] }()
	var code string
	w := ln
	if size > 0 && size < ps {
		if x := c.arch.LengthName(size); x != "" {
			w = x
		}
	}
	switch w {
	case "BYTE", "WORD":
		code = utils.Format("movzx " + res + ", " + w + " [" + staging + "+" + strconv.Itoa(off) + "]")
	case "DWORD":
		code = utils.Format("mov " + eName(res) + ", DWORD [" + staging + "+" + strconv.Itoa(off) + "]")
	default:
		code = utils.Format("mov " + res + ", QWORD [" + staging + "+" + strconv.Itoa(off) + "]")
	}
	code += c.emitFree(staging)
	code += utils.Format("mov " + result + ", " + res)
	return code
}

// emitMapTempResult 把 [rsp+off] 的内存值交付到 result。
// result 支持 push / 寄存器 / 带宽度或不带宽度前缀的内存槽。
func (c *ECompiler) emitMapTempResult(result string, off, size int) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	if size <= ps {
		w := ln
		if size > 0 {
			if x := c.arch.LengthName(size); x != "" {
				w = x
			}
		}
		var code string
		switch w {
		case "BYTE", "WORD":
			code = utils.Format("movzx RAX, " + w + " [rsp+" + strconv.Itoa(off) + "]")
		case "DWORD":
			code = utils.Format("mov EAX, DWORD [rsp+" + strconv.Itoa(off) + "]")
		default:
			code = utils.Format("mov RAX, QWORD [rsp+" + strconv.Itoa(off) + "]")
		}
		if result == "push" {
			return code + utils.Format("push RAX")
		}
		if result == "" {
			return code
		}
		if strings.Contains(result, "[") {
			dst := result
			if memPrefix(dst) == "" {
				dst = w + " " + dst
			}
			return code + utils.Format("mov "+dst+", "+matchMemWidth(dst, "RAX"))
		}
		return code + utils.Format("mov "+result+", RAX")
	}

	slots := mapTempBytes(size, ps) / ps
	if result == "push" {
		var code string
		for i := slots - 1; i >= 0; i-- {
			code += utils.Format("push " + ln + " [rsp+" + strconv.Itoa(off+i*ps) + "]")
		}
		return code
	}
	if strings.Contains(result, "[") {
		return c.copySlots(stripOuterBrackets(result), "rsp+"+strconv.Itoa(off), slots*ps)
	}
	// 寄存器目标只承载首槽（多槽值通常走内存/push 交付）
	return utils.Format("mov " + result + ", " + ln + " [rsp+" + strconv.Itoa(off) + "]")
}

// mapLValueAddr 返回 map 左值的内存地址表达式（无外层方括号）。
// 支持裸局部变量/全局变量、this/self 字段、指针基字段链。
func (c *ECompiler) mapLValueAddr(v *parser.VarBlock) (string, string, *regmgr.Reg) {
	if v == nil {
		return "", "", nil
	}
	if isThisField(v) {
		pre, addr, reg := c.thisMem(v)
		return pre, addr, reg
	}
	if needPtrMem(v) {
		pre, addr, reg := c.ptrMem(v)
		return pre, addr, reg
	}
	return "", stripOuterBrackets(c.arch.VarAddr(v)), nil
}

// mapLiteral 编译 map[K]V{k: v, ...} 字面量。
// maps 包的 maps.new / maps.set 在 x86_64 下经单态化标签直接调用：
// new 以 sampleK(零值，仅参与推断) + vsize 构造 16 槽空表；set 逐对插入。
// map 值语义是单个 mapHdr* —— result=push/[mem]/寄存器 均按单槽处理。32 位未支持。
func (c *ECompiler) mapLiteral(exp *parser.Expression, result string) string {
	if c.arch.PointerSize() != 8 {
		return ""
	}
	mt, ok := exp.Type.(*typeSys.MapType)
	if !ok || mt.Key() == nil || mt.Elem() == nil {
		return ""
	}
	kt, vt := mt.Key(), mt.Elem()
	vsize := vt.Size()
	if vsize <= 0 {
		vsize = c.arch.PointerSize()
	}
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	kslots := mapKeySlots(kt)
	keyBytes := kslots * ps
	mOff := 0
	keyOff := ps
	valOff := keyOff + keyBytes
	valBytes := mapTempBytes(vsize, ps)

	setLabel := c.intrinsicGenericLabel("set", []typeSys.Type{
		typeSys.GetSystemType("ptr"), kt, typeSys.GetSystemType("ptr"),
	})
	if setLabel == "" {
		return ""
	}
	newLabel := c.intrinsicGenericLabel("new", []typeSys.Type{
		kt, typeSys.GetSystemType("int"),
	})
	if newLabel == "" {
		return ""
	}

	// staging 区 malloc 到独立缓冲（不再占用 rsp，避免与外层 buffer/callee
	// 帧交错）；map 头指针暂存于一个独立的 callee-save 寄存器。
	stagingSize := align8(valOff + valBytes)
	code := c.emitMalloc(stagingSize)
	sping := c.pickCalleeSaveAvoid(nil)
	c.ctx.ListLitAvoid = append(c.ctx.ListLitAvoid, sping)
	defer func() { c.ctx.ListLitAvoid = c.ctx.ListLitAvoid[:len(c.ctx.ListLitAvoid)-1] }()
	code += utils.Format("mov " + sping + ", RAX; staging buffer")
	staging := sping
	if reg := c.getRegByName(staging); reg != nil {
		c.ctx.Reg.Force(reg, exp)
	}

	// maps.new[K](sampleK 零值, vsize)：sampleK 只参与类型推断
	for i := 0; i < kslots && i < len(sysvMapArgRegs); i++ {
		code += utils.Format("mov " + sysvMapArgRegs[i] + ", 0")
	}
	if kslots < len(sysvMapArgRegs) {
		code += utils.Format("mov " + sysvMapArgRegs[kslots] + ", " + strconv.Itoa(vsize))
	}
	code += utils.Format("call " + newLabel)
	code += utils.Format("mov QWORD [" + staging + "+" + strconv.Itoa(mOff) + "], RAX")

	for _, entry := range exp.MapElems {
		code += c.emitMapKeyToScratch(entry.Key, staging, keyOff, kt, kslots)
		code += c.emitMapValueTempStoreScratch(entry.Value, staging, valOff, vsize)
		code += utils.Format("mov RDI, QWORD [" + staging + "+" + strconv.Itoa(mOff) + "]")
		code += emitMapCallScratchArgRegs(staging, 1, keyOff, kslots)
		valReg := 1 + kslots
		if valReg < len(sysvMapArgRegs) {
			code += utils.Format("lea " + sysvMapArgRegs[valReg] + ", [" + staging + "+" + strconv.Itoa(valOff) + "]")
		}
		code += utils.Format("call " + setLabel)
	}

	// 交付单指针
	if result == "push" {
		code += utils.Format("push QWORD [" + staging + "+" + strconv.Itoa(mOff) + "]")
		code += c.emitFree(staging)
	} else if strings.Contains(result, "[") {
		base := stripOuterBrackets(result)
		code += utils.Format("mov RAX, QWORD [" + staging + "+" + strconv.Itoa(mOff) + "]")
		code += utils.Format("mov " + ln + " [" + base + "], RAX")
		code += c.emitFree(staging)
	} else if result == "" {
		code += utils.Format("mov RAX, QWORD [" + staging + "+" + strconv.Itoa(mOff) + "]")
		code += c.emitFree(staging)
	} else {
		code += c.mapScratchBareRegResult(exp, result, staging, mOff, 8)
	}
	return code
}

// mapIndexAccess map 索引读 m[k]：nil map 返回零值，否则 maps.get[K]。
func (c *ECompiler) mapIndexAccess(exp *parser.Expression, result string) string {
	if c.arch.PointerSize() != 8 {
		return ""
	}
	mt, ok := exp.Right.Type.(*typeSys.MapType)
	if !ok || mt.Key() == nil || mt.Elem() == nil || len(exp.Index) == 0 || exp.Index[0] == nil {
		return ""
	}
	kt, vt := mt.Key(), mt.Elem()
	vsize := vt.Size()
	if vsize <= 0 {
		vsize = c.arch.PointerSize()
	}
	valBytes := mapTempBytes(vsize, 8)
	kslots := mapKeySlots(kt)
	keyBytes := kslots * 8
	mOff := 0
	keyOff := 8
	valOff := keyOff + keyBytes
	uid := fmt.Sprintf("%x", uintptr(unsafe.Pointer(exp)))

	label := c.intrinsicGenericLabel("get", []typeSys.Type{
		typeSys.GetSystemType("ptr"), kt, typeSys.GetSystemType("ptr"),
	})
	if label == "" {
		return ""
	}

	// malloc 暂存区（不改变 rsp）
	stagingSize := align8(valOff + valBytes)
	sping := c.pickCalleeSaveAvoid(nil)
	c.ctx.ListLitAvoid = append(c.ctx.ListLitAvoid, sping)
	defer func() { c.ctx.ListLitAvoid = c.ctx.ListLitAvoid[:len(c.ctx.ListLitAvoid)-1] }()
	code := c.emitMalloc(stagingSize)
	code += utils.Format("mov " + sping + ", RAX; map staging")
	staging := sping
	if reg := c.getRegByName(staging); reg != nil {
		c.ctx.Reg.Force(reg, exp)
	}

	// 值临时区清零：nil map / 缺失键都返回零值
	for off := 0; off < valBytes; off += 8 {
		code += utils.Format("mov QWORD [" + staging + "+" + strconv.Itoa(valOff+off) + "], 0")
	}
	code += c.generate(exp.Right, "QWORD ["+staging+"+"+strconv.Itoa(mOff)+"]")
	code += c.emitMapKeyToScratch(exp.Index[0], staging, keyOff, kt, kslots)
	code += utils.Format("mov RAX, QWORD [" + staging + "+" + strconv.Itoa(mOff) + "]")
	code += utils.Format("test RAX, RAX")
	code += utils.Format("jz map_get_nil_" + uid)
	code += utils.Format("mov RDI, RAX")
	code += emitMapCallScratchArgRegs(staging, 1, keyOff, kslots)
	outReg := 1 + kslots
	if outReg < len(sysvMapArgRegs) {
		code += utils.Format("lea " + sysvMapArgRegs[outReg] + ", [" + staging + "+" + strconv.Itoa(valOff) + "]")
	}
	code += utils.Format("call " + label)
	code += utils.Format("jmp map_get_done_" + uid)
	code += utils.Format("map_get_nil_" + uid + ":")
	code += utils.Format("map_get_done_" + uid + ":")
	isBareReg := result != "" && result != "push" && !strings.Contains(result, "[")
	if isBareReg {
		code += c.mapScratchBareRegResult(exp, result, staging, valOff, vsize)
	} else {
		code += c.emitMapTempResultScratch(result, staging, valOff, vsize)
		code += c.emitFree(staging)
	}
	return code
}

// mapIndexSet map 索引写 m[k] = v：nil map 自动 new 并写回左值。
func (c *ECompiler) mapIndexSet(exp *parser.Expression) string {
	if c.arch.PointerSize() != 8 {
		return ""
	}
	idxNode := exp.Left
	if idxNode == nil || idxNode.Right == nil || idxNode.Right.Type == nil ||
		len(idxNode.Index) == 0 || idxNode.Index[0] == nil || exp.Right == nil {
		return ""
	}
	mt, ok := idxNode.Right.Type.(*typeSys.MapType)
	if !ok || mt.Key() == nil || mt.Elem() == nil {
		return ""
	}
	kt, vt := mt.Key(), mt.Elem()
	vsize := vt.Size()
	if vsize <= 0 {
		vsize = c.arch.PointerSize()
	}
	valBytes := mapTempBytes(vsize, 8)
	kslots := mapKeySlots(kt)
	keyBytes := kslots * 8
	addrOff := 0
	mOff := 8
	keyOff := 16
	valOff := keyOff + keyBytes
	uid := fmt.Sprintf("%x", uintptr(unsafe.Pointer(exp)))

	getLabel := c.intrinsicGenericLabel("set", []typeSys.Type{
		typeSys.GetSystemType("ptr"), kt, typeSys.GetSystemType("ptr"),
	})
	if getLabel == "" {
		return ""
	}
	newLabel := c.intrinsicGenericLabel("new", []typeSys.Type{
		kt, typeSys.GetSystemType("int"),
	})

	stagingSize := align8(valOff + valBytes)
	sping := c.pickCalleeSaveAvoid(nil)
	c.ctx.ListLitAvoid = append(c.ctx.ListLitAvoid, sping)
	defer func() { c.ctx.ListLitAvoid = c.ctx.ListLitAvoid[:len(c.ctx.ListLitAvoid)-1] }()
	var code string
	code += c.emitMalloc(stagingSize)
	code += utils.Format("mov " + sping + ", RAX; map staging")
	staging := sping
	if reg := c.getRegByName(staging); reg != nil {
		c.ctx.Reg.Force(reg, exp)
	}

	target := idxNode.Right
	pre := ""
	var addrCode string
	if target.Var != nil {
		var held *regmgr.Reg
		pre, addrCode, held = c.mapLValueAddr(target.Var)
		code += pre
		code += utils.Format("lea RAX, [" + addrCode + "]")
		code += utils.Format("mov QWORD [" + staging + "+" + strconv.Itoa(addrOff) + "], RAX")
		if held != nil {
			c.freeTmpReg(held)
		}
	} else {
		// 非左值（调用结果等）：直接求值，不写回
		code += utils.Format("mov QWORD [" + staging + "+" + strconv.Itoa(addrOff) + "], 0")
	}
	code += c.generate(target, "QWORD ["+staging+"+"+strconv.Itoa(mOff)+"]")
	code += utils.Format("mov RAX, QWORD [" + staging + "+" + strconv.Itoa(mOff) + "]")
	code += utils.Format("test RAX, RAX")
	code += utils.Format("jnz map_set_have_" + uid)
	if newLabel != "" {
		// new[K](zero sampleK, vsize)：sampleK 只参与类型推断
		for i := 0; i < kslots && i < len(sysvMapArgRegs); i++ {
			code += utils.Format("mov " + sysvMapArgRegs[i] + ", 0")
		}
		if kslots < len(sysvMapArgRegs) {
			code += utils.Format("mov " + sysvMapArgRegs[kslots] + ", " + strconv.Itoa(vsize))
		}
		code += utils.Format("call " + newLabel)
		code += utils.Format("mov QWORD [" + staging + "+" + strconv.Itoa(mOff) + "], RAX")
		code += utils.Format("mov RDI, QWORD [" + staging + "+" + strconv.Itoa(addrOff) + "]")
		code += utils.Format("test RDI, RDI")
		code += utils.Format("jz map_set_have_" + uid)
		code += utils.Format("mov QWORD [RDI], RAX")
	}
	code += utils.Format("map_set_have_" + uid + ":")
	code += c.emitMapKeyToScratch(idxNode.Index[0], staging, keyOff, kt, kslots)
	code += c.emitMapValueTempStoreScratch(exp.Right, staging, valOff, vsize)
	code += utils.Format("mov RDI, QWORD [" + staging + "+" + strconv.Itoa(mOff) + "]")
	code += emitMapCallScratchArgRegs(staging, 1, keyOff, kslots)
	valReg := 1 + kslots
	if valReg < len(sysvMapArgRegs) {
		code += utils.Format("lea " + sysvMapArgRegs[valReg] + ", [" + staging + "+" + strconv.Itoa(valOff) + "]")
	}
	code += utils.Format("call " + getLabel)
	code += c.emitFree(staging)
	return code
}

// mapLenValue len(map)：nil map 返回 0，否则读 mapHdr.count（@2*ptr）。
func (c *ECompiler) mapLenValue(arg *parser.Expression, result string) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	uid := fmt.Sprintf("%x", uintptr(unsafe.Pointer(arg)))
	var code string
	code += c.generate(arg, c.arch.ReturnReg())
	code += utils.Format("test " + c.arch.ReturnReg() + ", " + c.arch.ReturnReg())
	code += utils.Format("jz map_len_zero_" + uid)
	code += utils.Format("mov " + c.arch.ReturnReg() + ", " + ln + " [" + c.arch.ReturnReg() + "+" + strconv.Itoa(2*ps) + "]")
	code += utils.Format("map_len_zero_" + uid + ":")
	if result == "push" {
		code += utils.Format("push " + c.arch.ReturnReg())
	} else if result == "" {
		// 结果已在返回寄存器
	} else if strings.Contains(result, "[") {
		dst := result
		if memPrefix(dst) == "" {
			dst = ln + " " + dst
		}
		code += utils.Format("mov " + dst + ", " + matchMemWidth(dst, c.arch.ReturnReg()))
	} else {
		code += utils.Format("mov " + result + ", " + c.arch.ReturnReg())
	}
	return code
}

// ============ 负数索引 / 切片步长支持 ============
//
// 负数索引语义：idx < 0 时按 idx += len 归一化，再做常规边界检查；
// 归一化后仍越界沿用既有 _panic_index_oob 报错路径。
// 切片步长：无 step 且边界非负时走 sliceExp 原有视图语义；有 step（或
// 常量负边界需要归一化）时走 sliceExpAdvanced 的新缓冲 + 跨步拷贝路径。
// x86_64 为当前门槛；32 位返回空串，由调用方回退旧路径（Batch 4 收口）。

// emitNegativeIndexNormalize 把已求值到 reg 的索引按 lenMem/arrLen 归一化。
// 仅处理非常量索引：reg < 0 → reg += len。arrLen >= 0 表示定长数组。
func (c *ECompiler) emitNegativeIndexNormalize(idx *parser.Expression, reg, lenMem string, arrLen int) string {
	uid := fmt.Sprintf("%x", uintptr(unsafe.Pointer(idx)))
	var code string
	code += utils.Format("test " + reg + ", " + reg)
	code += utils.Format("jge idx_norm_ok_" + uid)
	if arrLen >= 0 {
		code += utils.Format("add " + reg + ", " + strconv.Itoa(arrLen))
	} else {
		code += utils.Format("add " + reg + ", " + lenMem)
	}
	code += utils.Format("idx_norm_ok_" + uid + ":")
	return code
}

// indexAccessNegative 负数/动态索引读 a[i]（list/string/array）。
// 失败返回空串，调用方回退 indexAccessGeneric。
func (c *ECompiler) indexAccessNegative(exp *parser.Expression, result string, elemSize int) string {
	if c.arch.PointerSize() != 8 {
		return ""
	}
	src := exp.Right
	if src == nil || src.Type == nil || len(exp.Index) == 0 || exp.Index[0] == nil {
		return ""
	}
	idxExpr := exp.Index[0]
	kind := src.Type.Kind()
	isArr := kind == "array"
	arrLen := -1
	isStackArray := false
	if isArr {
		at, ok := src.Type.(*typeSys.ArrayType)
		if !ok || at.Elem() == nil {
			return ""
		}
		arrLen = at.Len()
		isStackArray = src.Var != nil
	}

	// list/string 需要运行时长度；非变量表达式回退旧路径。
	_, lenOff, _ := c.listFields()
	var pre, addrBase, lenMem string
	var held *regmgr.Reg
	if !isArr {
		if src.Var == nil {
			return ""
		}
		pre, addrBase, held = c.listBaseResolve(src.Var, "", stripOuterBrackets(c.arch.VarAddr(src.Var)))
		if addrBase == "" {
			return ""
		}
		ln := c.arch.LengthName(8)
		lenMem = ln + " [" + addrBase + "+" + strconv.Itoa(lenOff) + "]"
	}

	uid := fmt.Sprintf("%x", uintptr(unsafe.Pointer(exp)))
	ln := c.arch.LengthName(8)
	idxConst := idxExpr.IsConst()
	constVal := 0
	if idxConst {
		constVal = int(idxExpr.Num)
	}

	var code string
	var iReg *regmgr.Reg
	// 数组常量负索引：编译期归一化；归一化后仍为负 → 直接越界。
	constOnly := isArr && idxConst
	if constOnly {
		norm := arrLen + constVal
		if norm < 0 {
			return utils.Format("push "+strconv.Itoa(constVal)) +
				utils.Format("call _panic_index_oob")
		}
		constVal = norm
	} else {
		iReg = c.allocReg(idxExpr)
		if iReg == nil {
			iReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		// 先求值索引：表达式可能含调用，避免调用破坏后续基址寄存器。
		if !idxConst {
			code += c.generate(idxExpr, iReg.Name)
		}
	}

	if isArr {
		if !constOnly {
			code += c.emitNegativeIndexNormalize(idxExpr, iReg.Name, "", arrLen)
			// 0 <= idx < arrLen
			oob := "idx_oob_" + uid
			ok := "idx_ok_" + uid
			code += utils.Format("test " + iReg.Name + ", " + iReg.Name)
			code += utils.Format("js " + oob)
			code += utils.Format("cmp " + iReg.Name + ", " + strconv.Itoa(arrLen))
			code += utils.Format("jl " + ok)
			code += utils.Format(oob + ":")
			code += utils.Format("push " + iReg.Name)
			code += utils.Format("call _panic_index_oob")
			code += utils.Format(ok + ":")
		}
	} else {
		code += pre
		if idxConst {
			code += utils.Format("mov " + iReg.Name + ", " + lenMem)
			code += utils.Format("add " + iReg.Name + ", " + strconv.Itoa(constVal))
		} else {
			code += c.emitNegativeIndexNormalize(idxExpr, iReg.Name, lenMem, -1)
		}
		// 0 <= idx < len
		oob := "idx_oob_" + uid
		ok := "idx_ok_" + uid
		code += utils.Format("test " + iReg.Name + ", " + iReg.Name)
		code += utils.Format("js " + oob)
		code += utils.Format("cmp " + lenMem + ", " + iReg.Name)
		code += utils.Format("jg " + ok)
		code += utils.Format(oob + ":")
		code += utils.Format("push " + iReg.Name)
		code += utils.Format("call _panic_index_oob")
		code += utils.Format(ok + ":")
		if held != nil {
			c.freeTmpReg(held)
		}
	}

	// 元素地址
	ptrReg := c.allocRegAvoid(src, "")
	if iReg != nil {
		ptrReg = c.allocRegAvoid(src, iReg.Name)
	}
	if ptrReg == nil {
		ptrReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
	}
	if isStackArray {
		addr := c.arch.VarAddr(src.Var)
		if i := strings.Index(addr, "["); i > 0 {
			addr = addr[i:]
		} else if !strings.Contains(addr, "[") {
			addr = "[" + addr + "]"
		}
		code += utils.Format("lea " + ptrReg.Name + ", " + addr + "; array base addr")
	} else {
		code += c.generate(src, ptrReg.Name)
	}
	if constOnly {
		off := constVal * elemSize
		if off != 0 {
			code += utils.Format("add " + ptrReg.Name + ", " + strconv.Itoa(off))
		}
	} else {
		code += utils.Format("imul " + iReg.Name + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + ptrReg.Name + ", " + iReg.Name)
		c.ctx.Reg.Free(idxExpr)
	}

	// 读元素（与 indexAccessGeneric 相同的多槽/标量交付规则）
	if elemSize > c.arch.PointerSize() {
		if result == "push" {
			ps := c.arch.PointerSize()
			for i := elemSize/ps - 1; i >= 0; i-- {
				off := i * ps
				if off == 0 {
					code += utils.Format("push " + ln + " [" + ptrReg.Name + "]")
				} else {
					code += utils.Format("push " + ln + " [" + ptrReg.Name + "+" + strconv.Itoa(off) + "]")
				}
			}
		} else if strings.Contains(result, "[") {
			code += c.copySlots(stripOuterBrackets(result), ptrReg.Name, elemSize)
		} else {
			code += utils.Format("mov " + result + ", " + ln + " [" + ptrReg.Name + "]")
		}
	} else {
		code += c.derefLoad(c.arch.LengthName(elemSize), result, ptrReg.Name)
	}
	c.ctx.Reg.Free(src)
	return code
}

// indexSetNegative 负数/动态索引写 a[i] = v（list/string/array 标量元素）。
// 失败返回空串，调用方回退 indexSet 旧路径。
func (c *ECompiler) indexSetNegative(exp *parser.Expression, elemSize int) string {
	if c.arch.PointerSize() != 8 || elemSize > c.arch.PointerSize() {
		return ""
	}
	indexExpr := exp.Left
	if indexExpr == nil || indexExpr.Right == nil || indexExpr.Right.Type == nil ||
		len(indexExpr.Index) == 0 || indexExpr.Index[0] == nil || exp.Right == nil {
		return ""
	}
	src := indexExpr.Right
	idxExpr := indexExpr.Index[0]
	kind := src.Type.Kind()
	isArr := kind == "array"
	arrLen := -1
	isStackArray := false
	if isArr {
		at, ok := src.Type.(*typeSys.ArrayType)
		if !ok || at.Elem() == nil {
			return ""
		}
		arrLen = at.Len()
		isStackArray = src.Var != nil
	}

	_, lenOff, _ := c.listFields()
	var pre, addrBase, lenMem string
	var held *regmgr.Reg
	if !isArr {
		if src.Var == nil {
			return ""
		}
		pre, addrBase, held = c.listBaseResolve(src.Var, "", stripOuterBrackets(c.arch.VarAddr(src.Var)))
		if addrBase == "" {
			return ""
		}
		ln := c.arch.LengthName(8)
		lenMem = ln + " [" + addrBase + "+" + strconv.Itoa(lenOff) + "]"
	}

	uid := fmt.Sprintf("%x", uintptr(unsafe.Pointer(exp)))
	idxConst := idxExpr.IsConst()
	constVal := 0
	if idxConst {
		constVal = int(idxExpr.Num)
	}
	var code string
	var iReg *regmgr.Reg
	constOnly := isArr && idxConst
	if constOnly {
		norm := arrLen + constVal
		if norm < 0 {
			return utils.Format("push "+strconv.Itoa(constVal)) +
				utils.Format("call _panic_index_oob")
		}
		constVal = norm
	} else {
		iReg = c.allocReg(idxExpr)
		if iReg == nil {
			iReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		if !idxConst {
			code += c.generate(idxExpr, iReg.Name)
		}
	}

	if isArr {
		if !constOnly {
			code += c.emitNegativeIndexNormalize(idxExpr, iReg.Name, "", arrLen)
			oob := "idxw_oob_" + uid
			ok := "idxw_ok_" + uid
			code += utils.Format("test " + iReg.Name + ", " + iReg.Name)
			code += utils.Format("js " + oob)
			code += utils.Format("cmp " + iReg.Name + ", " + strconv.Itoa(arrLen))
			code += utils.Format("jl " + ok)
			code += utils.Format(oob + ":")
			code += utils.Format("push " + iReg.Name)
			code += utils.Format("call _panic_index_oob")
			code += utils.Format(ok + ":")
		}
	} else {
		code += pre
		if idxConst {
			code += utils.Format("mov " + iReg.Name + ", " + lenMem)
			code += utils.Format("add " + iReg.Name + ", " + strconv.Itoa(constVal))
		} else {
			code += c.emitNegativeIndexNormalize(idxExpr, iReg.Name, lenMem, -1)
		}
		oob := "idxw_oob_" + uid
		ok := "idxw_ok_" + uid
		code += utils.Format("test " + iReg.Name + ", " + iReg.Name)
		code += utils.Format("js " + oob)
		code += utils.Format("cmp " + lenMem + ", " + iReg.Name)
		code += utils.Format("jg " + ok)
		code += utils.Format(oob + ":")
		code += utils.Format("push " + iReg.Name)
		code += utils.Format("call _panic_index_oob")
		code += utils.Format(ok + ":")
		if held != nil {
			c.freeTmpReg(held)
		}
	}

	aReg := c.allocRegAvoid(src, "")
	if iReg != nil {
		aReg = c.allocRegAvoid(src, iReg.Name)
	}
	if aReg == nil {
		aReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
	}
	if isStackArray {
		addr := c.arch.VarAddr(src.Var)
		if i := strings.Index(addr, "["); i > 0 {
			addr = addr[i:]
		} else if !strings.Contains(addr, "[") {
			addr = "[" + addr + "]"
		}
		code += utils.Format("lea " + aReg.Name + ", " + addr + "; array base addr")
	} else {
		code += c.generate(src, aReg.Name)
	}
	if constOnly {
		off := constVal * elemSize
		if off != 0 {
			code += utils.Format("add " + aReg.Name + ", " + strconv.Itoa(off))
		}
	} else {
		code += utils.Format("imul " + iReg.Name + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + aReg.Name + ", " + iReg.Name)
		c.ctx.Reg.Free(idxExpr)
	}

	vReg := c.allocReg(exp.Right)
	if vReg == nil {
		vReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code += c.generate(exp.Right, vReg.Name)
	code += c.derefStore(c.arch.LengthName(elemSize), aReg.Name, vReg.Name)
	c.ctx.Reg.Free(exp.Right)
	return code
}

// sliceExpAdvanced 有步长/负边界的切片：新建缓冲 + 跨步拷贝。
// 仅 x86_64；不支持时返回空串由旧路径兜底。
func (c *ECompiler) sliceExpAdvanced(exp *parser.Expression, result string) string {
	if c.arch.PointerSize() != 8 {
		return ""
	}
	src := exp.Right
	if src == nil || src.Type == nil {
		return ""
	}
	kind := src.Type.Kind()
	if kind != "list" && kind != "string" {
		return ""
	}
	elemSize := 1
	if kind == "list" {
		lt, ok := src.Type.(*typeSys.ListType)
		if !ok || lt.Elem() == nil {
			return ""
		}
		elemSize = lt.Elem().Size()
	}
	if elemSize <= 0 {
		elemSize = 1
	}

	ps := c.arch.PointerSize()
	_, lenOff, capOff := c.listFields()
	uid := fmt.Sprintf("%x", uintptr(unsafe.Pointer(exp)))
	frame := mapAlign16(8 * ps)
	srcOff := 0
	sLenOff := ps
	loOff := 3 * ps
	hiOff := 4 * ps
	stepOff := 5 * ps
	cntOff := 6 * ps
	dstOff := 7 * ps
	ln := c.arch.LengthName(ps)
	sp := c.arch.StackPtr()

	loExpr := exp.Index[0]
	hiExpr := exp.Index[1]
	stepExpr := exp.Index[2]

	var code string
	code += utils.Format("sub " + sp + ", " + strconv.Itoa(frame) + "; slice step frame")
	// 源容器三槽
	code += c.generate(src, "[rsp+"+strconv.Itoa(srcOff)+"]")

	// step
	if stepExpr == nil {
		code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(stepOff) + "], 1")
	} else {
		code += c.generate(stepExpr, "QWORD [rsp+"+strconv.Itoa(stepOff)+"]")
	}

	stepConst := 0
	stepKnown := stepExpr == nil
	if stepExpr != nil && stepExpr.IsConst() {
		stepKnown = true
		stepConst = int(stepExpr.Num)
	}

	// 负边界归一化：仅对显式表达式生效（默认边界按步长方向生成）。
	emitBound := func(bound *parser.Expression, off int) string {
		var b string
		b += c.generate(bound, "QWORD [rsp+"+strconv.Itoa(off)+"]")
		b += utils.Format("mov RAX, QWORD [rsp+" + strconv.Itoa(off) + "]")
		b += utils.Format("test RAX, RAX")
		b += utils.Format("jge bound_ok_" + uid + "_" + strconv.Itoa(off))
		b += utils.Format("add RAX, QWORD [rsp+" + strconv.Itoa(sLenOff) + "]")
		b += utils.Format("mov QWORD [rsp+" + strconv.Itoa(off) + "], RAX")
		b += utils.Format("bound_ok_" + uid + "_" + strconv.Itoa(off) + ":")
		return b
	}

	// lo 默认：step>0 → 0；step<0 → len-1
	if loExpr != nil {
		code += emitBound(loExpr, loOff)
	} else if stepKnown && stepConst >= 0 {
		code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(loOff) + "], 0")
	} else if stepKnown && stepConst < 0 {
		code += utils.Format("mov RAX, QWORD [rsp+" + strconv.Itoa(sLenOff) + "]")
		code += utils.Format("dec RAX")
		code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(loOff) + "], RAX")
	} else {
		// 动态 step：按符号选择默认 lo
		lb := "lo_dyn_neg_" + uid
		ld := "lo_dyn_done_" + uid
		code += utils.Format("mov RAX, QWORD [rsp+" + strconv.Itoa(stepOff) + "]")
		code += utils.Format("test RAX, RAX")
		code += utils.Format("js " + lb)
		code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(loOff) + "], 0")
		code += utils.Format("jmp " + ld)
		code += utils.Format(lb + ":")
		code += utils.Format("mov RAX, QWORD [rsp+" + strconv.Itoa(sLenOff) + "]")
		code += utils.Format("dec RAX")
		code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(loOff) + "], RAX")
		code += utils.Format(ld + ":")
	}

	// hi 默认：step>0 → len；step<0 → -1
	if hiExpr != nil {
		code += emitBound(hiExpr, hiOff)
	} else if stepKnown && stepConst >= 0 {
		code += utils.Format("mov RAX, QWORD [rsp+" + strconv.Itoa(sLenOff) + "]")
		code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(hiOff) + "], RAX")
	} else if stepKnown && stepConst < 0 {
		code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(hiOff) + "], -1")
	} else {
		hb := "hi_dyn_neg_" + uid
		hd := "hi_dyn_done_" + uid
		code += utils.Format("mov RAX, QWORD [rsp+" + strconv.Itoa(stepOff) + "]")
		code += utils.Format("test RAX, RAX")
		code += utils.Format("js " + hb)
		code += utils.Format("mov RAX, QWORD [rsp+" + strconv.Itoa(sLenOff) + "]")
		code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(hiOff) + "], RAX")
		code += utils.Format("jmp " + hd)
		code += utils.Format(hb + ":")
		code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(hiOff) + "], -1")
		code += utils.Format(hd + ":")
	}

	// count = ceil((hi-lo)/step)（step<0 时按 lo-hi 计算）
	code += utils.Format("mov RAX, QWORD [rsp+" + strconv.Itoa(stepOff) + "]")
	code += utils.Format("test RAX, RAX")
	code += utils.Format("jz cnt_zero_" + uid)
	code += utils.Format("js cnt_neg_" + uid)
	code += utils.Format("mov RCX, QWORD [rsp+" + strconv.Itoa(hiOff) + "]")
	code += utils.Format("sub RCX, QWORD [rsp+" + strconv.Itoa(loOff) + "]")
	code += utils.Format("jle cnt_zero_" + uid)
	code += utils.Format("mov RAX, QWORD [rsp+" + strconv.Itoa(stepOff) + "]")
	code += utils.Format("dec RAX")
	code += utils.Format("add RCX, RAX")
	code += utils.Format("mov RAX, RCX")
	code += utils.Format("cqo")
	code += utils.Format("idiv QWORD [rsp+" + strconv.Itoa(stepOff) + "]")
	code += utils.Format("jmp cnt_store_" + uid)
	code += utils.Format("cnt_neg_" + uid + ":")
	code += utils.Format("mov RCX, QWORD [rsp+" + strconv.Itoa(loOff) + "]")
	code += utils.Format("sub RCX, QWORD [rsp+" + strconv.Itoa(hiOff) + "]")
	code += utils.Format("jle cnt_zero_" + uid)
	code += utils.Format("mov R8, QWORD [rsp+" + strconv.Itoa(stepOff) + "]")
	code += utils.Format("neg R8")
	code += utils.Format("mov RAX, R8")
	code += utils.Format("dec RAX")
	code += utils.Format("add RCX, RAX")
	code += utils.Format("mov RAX, RCX")
	code += utils.Format("cqo")
	code += utils.Format("idiv R8")
	code += utils.Format("jmp cnt_store_" + uid)
	code += utils.Format("cnt_zero_" + uid + ":")
	code += utils.Format("xor RAX, RAX")
	code += utils.Format("cnt_store_" + uid + ":")
	code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(cntOff) + "], RAX")

	// malloc(count*elemSize)
	code += utils.Format("mov RDI, QWORD [rsp+" + strconv.Itoa(cntOff) + "]")
	code += utils.Format("imul RDI, " + strconv.Itoa(elemSize))
	callMalloc := makeMemCall("malloc", []typeSys.Type{typeSys.GetSystemType("uint")})
	code += utils.Format("call " + callMalloc.Func.MangledName())
	code += utils.Format("mov QWORD [rsp+" + strconv.Itoa(dstOff) + "], RAX")

	// 跨步拷贝：dst[i] = src[lo + i*step]
	code += utils.Format("mov R8, QWORD [rsp+" + strconv.Itoa(dstOff) + "]")
	code += utils.Format("mov R9, QWORD [rsp+" + strconv.Itoa(loOff) + "]")
	code += utils.Format("mov R10, QWORD [rsp+" + strconv.Itoa(cntOff) + "]")
	code += utils.Format("mov R11, QWORD [rsp+" + strconv.Itoa(stepOff) + "]")
	code += utils.Format("test R10, R10")
	code += utils.Format("jz copy_done_" + uid)
	code += utils.Format("copy_loop_" + uid + ":")
	code += utils.Format("mov RAX, R9")
	code += utils.Format("imul RAX, " + strconv.Itoa(elemSize))
	code += utils.Format("add RAX, QWORD [rsp+" + strconv.Itoa(srcOff) + "]")
	code += utils.Format("mov RCX, " + strconv.Itoa(elemSize))
	code += utils.Format("copy_byte_" + uid + ":")
	code += utils.Format("mov DL, BYTE [RAX]")
	code += utils.Format("mov BYTE [R8], DL")
	code += utils.Format("inc RAX")
	code += utils.Format("inc R8")
	code += utils.Format("dec RCX")
	code += utils.Format("jnz copy_byte_" + uid)
	code += utils.Format("add R9, R11")
	code += utils.Format("dec R10")
	code += utils.Format("jnz copy_loop_" + uid)
	code += utils.Format("copy_done_" + uid + ":")

	// 交付：ptr=dst, len=cap=count。
	// 注意：result 可能相对于调用方在当前临时帧之前的 rsp（如寄存器参数槽
	// [rsp+0]）。必须先把结果装入寄存器、撤销临时帧，再写入目标地址，
	// 否则会写进即将释放的帧而丢失。
	if strings.Contains(result, "[") {
		base := stripOuterBrackets(result)
		code += utils.Format("mov RAX, QWORD [rsp+" + strconv.Itoa(dstOff) + "]")
		code += utils.Format("mov RDX, QWORD [rsp+" + strconv.Itoa(cntOff) + "]")
		code += utils.Format("add " + sp + ", " + strconv.Itoa(frame))
		code += c.storeVal(base, ln, "RAX")
		code += c.storeVal(base+"+"+strconv.Itoa(lenOff), ln, "RDX")
		code += c.storeVal(base+"+"+strconv.Itoa(capOff), ln, "RDX")
	} else if result == "push" {
		code += utils.Format("mov RAX, QWORD [rsp+" + strconv.Itoa(dstOff) + "]")
		code += utils.Format("mov RCX, QWORD [rsp+" + strconv.Itoa(cntOff) + "]")
		code += utils.Format("add " + sp + ", " + strconv.Itoa(frame))
		code += utils.Format("push RCX")
		code += utils.Format("push RCX")
		code += utils.Format("push RAX")
	} else {
		code += utils.Format("mov " + result + ", QWORD [rsp+" + strconv.Itoa(dstOff) + "]")
		code += utils.Format("add " + sp + ", " + strconv.Itoa(frame))
	}
	c.ctx.Reg.Free(src)
	return code
}

// indexAccess 列表/字符串/数组索引读 a[i]
func (c *ECompiler) indexAccess(exp *parser.Expression, result string) string {
	if exp.Right == nil || exp.Right.Type == nil || len(exp.Index) == 0 || exp.Index[0] == nil {
		return ""
	}
	// map 索引：单 header 指针 + maps.get 调用，与 list/array 的裸内存寻址不同。
	if exp.Right.Type.Kind() == "map" {
		return c.mapIndexAccess(exp, result)
	}
	elemSize := 1
	listType := exp.Right.Type
	// *[]T: 解引用指针获取 list 类型
	if listType.IsPointer() && listType.Elem() != nil && listType.Elem().Kind() == "list" {
		listType = listType.Elem()
	}
	if listType.Kind() == "list" {
		lt, ok := listType.(*typeSys.ListType)
		if !ok || lt.Elem() == nil {
			return ""
		}
		elemSize = lt.Elem().Size()
	} else if listType.Kind() == "array" {
		at, ok := listType.(*typeSys.ArrayType)
		if !ok || at.Elem() == nil {
			return ""
		}
		elemSize = at.Elem().Size()
	}
	// 负数索引：常量负值或运行时动态索引先归一化（idx += len）再走边界检查。
	if kind := listType.Kind(); kind == "list" || kind == "string" || kind == "array" {
		idx := exp.Index[0]
		if !idx.IsConst() || int(idx.Num) < 0 {
			if code := c.indexAccessNegative(exp, result, elemSize); code != "" {
				return code
			}
		}
	}
	return c.indexAccessGeneric(exp, result, elemSize)
}

// indexAccessGeneric 计算 ptr+idx*es 并读元素
func (c *ECompiler) indexAccessGeneric(exp *parser.Expression, result string, elemSize int) string {
	code := ""

	// 边界检查
	if exp.Right != nil && exp.Right.Type != nil && len(exp.Index) > 0 && exp.Index[0] != nil {
		idxExpr := exp.Index[0]
		isArr := exp.Right.Type.Kind() == "array"
		isList := exp.Right.Type.Kind() == "list"
		// 使用表达式指针生成唯一前缀，避免跨函数标签冲突
		expUID := fmt.Sprintf("%x", uintptr(unsafe.Pointer(exp)))

		if isArr && idxExpr.IsConst() {
			// 编译期常量数组索引：const 索引跳过检查
		} else if isArr && !idxExpr.IsConst() {
			// 非 const 数组索引：编译期长度比较
			if at, ok := exp.Right.Type.(*typeSys.ArrayType); ok {
				arrLen := at.Len()
				lbl := "oob_" + expUID
				idxReg := c.allocReg(idxExpr)
				if idxReg == nil {
					idxReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
				}
				code += c.generate(idxExpr, idxReg.Name)
				code += utils.Format("cmp " + idxReg.Name + ", " + strconv.Itoa(arrLen))
				code += utils.Format("jl " + lbl)
				code += utils.Format("push " + idxReg.Name)
				code += utils.Format("call _panic_index_oob")
				code += utils.Format(lbl + ":")
				c.ctx.Reg.Free(idxExpr)
			}
		} else if isList && exp.Right.Var != nil {
			// 列表变量：运行时从列表头读 len 比较
			// S0-1（P11 基址解析合流）：bounds 与元素寻址共用 listBaseResolve——
			// 值语义（局部变量/局部 struct 字段链）直拼原样（逐位不变）；
			// self/this 指针链 pre=解引 thisHome 槽 + fieldOffsetOf 捆绑。
			// A5 病灶：此前 bounds 用 VarAddr 文本直拼 [rbp-48+8]（读相邻栈槽
			// 垃圾），元素加载走 generate 解引，两轨分叉 → M2a panic 实锤。
			_, lenOff, _ := c.listFields()
			ln := c.arch.LengthName(c.arch.PointerSize())
			pre, addrBase, heldBase := c.listBaseResolve(exp.Right.Var, "", stripOuterBrackets(c.arch.VarAddr(exp.Right.Var)))
			lbl := "oob_" + expUID
			if idxExpr.IsConst() {
				idx := int(idxExpr.Num)
				code += pre
				code += utils.Format("cmp " + ln + " [" + addrBase + "+" + strconv.Itoa(lenOff) + "], " + strconv.Itoa(idx))
				code += utils.Format("jg " + lbl)
				code += utils.Format("push " + strconv.Itoa(idx))
				code += utils.Format("call _panic_index_oob")
				code += utils.Format(lbl + ":")
			} else {
				avoidBase := ""
				if heldBase != nil {
					avoidBase = heldBase.Name
				}
				lenReg := c.allocRegAvoid(idxExpr, avoidBase)
				if lenReg == nil {
					lenReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
				}
				code += pre
				code += c.generate(idxExpr, lenReg.Name)
				code += utils.Format("cmp " + ln + " [" + addrBase + "+" + strconv.Itoa(lenOff) + "], " + lenReg.Name)
				code += utils.Format("jg " + lbl)
				code += utils.Format("push " + lenReg.Name)
				code += utils.Format("call _panic_index_oob")
				code += utils.Format(lbl + ":")
				c.ctx.Reg.Free(idxExpr)
			}
			if heldBase != nil {
				c.freeTmpReg(heldBase)
			}
		}
		// isList && Var==nil: 复杂表达式，跳过边界检查
	}

	// For stack arrays, use the variable's address directly (lea) instead of loading value
	isStackArray := exp.Right.Type != nil && exp.Right.Type.Kind() == "array" && exp.Right.Var != nil
	if isStackArray {
		addr := c.arch.VarAddr(exp.Right.Var)
		// Strip size prefix (e.g., "DWORD ") to get pure [ebp+N]
		if idx := strings.Index(addr, "["); idx > 0 {
			addr = addr[idx:]
		} else if !strings.Contains(addr, "[") {
			addr = "[" + addr + "]"
		}
		ptrReg := c.allocReg(exp.Right)
		if ptrReg == nil {
			ptrReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		code += utils.Format("lea " + ptrReg.Name + ", " + addr + "; array base addr")
		// Proceed with index calculation using ptrReg
		idxExpr := exp.Index[0]
		if idxExpr.IsConst() {
			off := int(idxExpr.Num) * elemSize
			if off != 0 {
				code += utils.Format("add " + ptrReg.Name + ", " + strconv.Itoa(off))
			}
		} else {
			iReg := c.allocRegAvoid(idxExpr, ptrReg.Name)
			if iReg == nil {
				iReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
			}
			code += c.generate(idxExpr, iReg.Name)
			code += utils.Format("imul " + iReg.Name + ", " + strconv.Itoa(elemSize))
			code += utils.Format("add " + ptrReg.Name + ", " + iReg.Name)
			c.ctx.Reg.Free(idxExpr)
		}
		// Read element
		if elemSize > c.arch.PointerSize() {
			if result == "push" {
				ps := c.arch.PointerSize()
				for i := elemSize/ps - 1; i >= 0; i-- {
					off := i * ps
					if off == 0 {
						code += utils.Format("push " + c.arch.LengthName(ps) + " [" + ptrReg.Name + "]")
					} else {
						code += utils.Format("push " + c.arch.LengthName(ps) + " [" + ptrReg.Name + "+" + strconv.Itoa(off) + "]")
					}
				}
			} else if strings.Contains(result, "[") {
				code += c.copySlots(stripOuterBrackets(result), ptrReg.Name, elemSize)
			} else {
				code += utils.Format("mov " + result + ", " + c.arch.LengthName(c.arch.PointerSize()) + " [" + ptrReg.Name + "]")
			}
		} else {
			code += c.derefLoad(c.arch.LengthName(elemSize), result, ptrReg.Name)
		}
		c.ctx.Reg.Free(exp.Right)
		return code
	}

	ptrReg := c.allocReg(exp.Right)
	if ptrReg == nil {
		ptrReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code += c.generate(exp.Right, ptrReg.Name)

	// *[]T: 解引用指针获取 data_ptr（list struct 第一个字段）
	if exp.Right.Type != nil && exp.Right.Type.IsPointer() && exp.Right.Type.Elem() != nil && exp.Right.Type.Elem().Kind() == "list" {
		ps := c.arch.PointerSize()
		code += utils.Format("mov " + ptrReg.Name + ", " + c.arch.LengthName(ps) + " [" + ptrReg.Name + "]")
	}

	idxExpr := exp.Index[0]
	if idxExpr.IsConst() {
		off := int(idxExpr.Num) * elemSize
		if off != 0 {
			code += utils.Format("add " + ptrReg.Name + ", " + strconv.Itoa(off))
		}
	} else {
		iReg := c.allocRegAvoid(idxExpr, ptrReg.Name)
		if iReg == nil {
			iReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
		}
		code += c.generate(idxExpr, iReg.Name)
		code += utils.Format("imul " + iReg.Name + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + ptrReg.Name + ", " + iReg.Name)
		c.ctx.Reg.Free(idxExpr)
	}

	// 读元素
	if elemSize > c.arch.PointerSize() {
		// 多槽元素（string 等）：整体拷到内存目标
		if result == "push" {
			// 参数装载：多槽元素整体入栈，高地址槽先入栈
			ps := c.arch.PointerSize()
			for i := elemSize/ps - 1; i >= 0; i-- {
				off := i * ps
				if off == 0 {
					code += utils.Format("push " + c.arch.LengthName(ps) + " [" + ptrReg.Name + "]")
				} else {
					code += utils.Format("push " + c.arch.LengthName(ps) + " [" + ptrReg.Name + "+" + strconv.Itoa(off) + "]")
				}
			}
		} else if strings.Contains(result, "[") {
			code += c.copySlots(stripOuterBrackets(result), ptrReg.Name, elemSize)
		} else {
			code += utils.Format("mov " + result + ", " + c.arch.LengthName(c.arch.PointerSize()) + " [" + ptrReg.Name + "]")
		}
	} else {
		code += c.derefLoad(c.arch.LengthName(elemSize), result, ptrReg.Name)
	}
	c.ctx.Reg.Free(exp.Right)
	return code
}

// indexSet 索引赋值 a[i] = v（Separator="[]="：Left=索引表达式，Right=值）
func (c *ECompiler) indexSet(exp *parser.Expression) string {
	indexExpr := exp.Left
	if indexExpr == nil || indexExpr.Right == nil || len(indexExpr.Index) == 0 || indexExpr.Index[0] == nil || exp.Right == nil {
		return ""
	}
	// map 索引写：nil map 自动初始化并写回左值。
	if indexExpr.Right.Type != nil && indexExpr.Right.Type.Kind() == "map" {
		return c.mapIndexSet(exp)
	}
	elemSize := 1
	if indexExpr.Right.Type != nil && indexExpr.Right.Type.Kind() == "list" {
		if lt, ok := indexExpr.Right.Type.(*typeSys.ListType); ok && lt.Elem() != nil {
			elemSize = lt.Elem().Size()
		}
	} else if indexExpr.Right.Type != nil && indexExpr.Right.Type.Kind() == "array" {
		if at, ok := indexExpr.Right.Type.(*typeSys.ArrayType); ok && at.Elem() != nil {
			elemSize = at.Elem().Size()
		}
	}
	// 负数索引写：常量负值或运行时动态索引先归一化再写。
	if kind := indexExpr.Right.Type.Kind(); kind == "list" || kind == "string" || kind == "array" {
		idx := indexExpr.Index[0]
		if !idx.IsConst() || int(idx.Num) < 0 {
			if code := c.indexSetNegative(exp, elemSize); code != "" {
				return code
			}
		}
	}

	// 边界检查（indexSet）
	// S0-1 发现：下方各分支生成的检查代码历史上写进局部 code（遮蔽），
	// 从未并入返回值 = 死代码，写路径越界零保护（数组分支同缺陷，本波不动）。
	// 改造契约：值语义保持逐位不变（检查仍不生成）；仅 self/this 指针链基址
	//（listBaseResolve 判定 heldBase != nil）补发解引 bounds，经 boundsPrepend
	// 并入下方两处返回点（P11 基址解析合流条款）。
	boundsPrepend := ""
	if indexExpr.Right != nil && indexExpr.Right.Type != nil && len(indexExpr.Index) > 0 && indexExpr.Index[0] != nil {
		idxExpr := indexExpr.Index[0]
		isArr := indexExpr.Right.Type.Kind() == "array"
		isList := indexExpr.Right.Type.Kind() == "list"
		expUID := fmt.Sprintf("%x", uintptr(unsafe.Pointer(indexExpr)))

		if isArr && idxExpr.IsConst() {
			// const 数组索引：编译期跳过
		} else if isArr && !idxExpr.IsConst() {
			if at, ok := indexExpr.Right.Type.(*typeSys.ArrayType); ok {
				arrLen := at.Len()
				lbl := "oob_" + expUID
				idxReg := c.allocReg(idxExpr)
				if idxReg == nil {
					idxReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
				}
				code := c.generate(idxExpr, idxReg.Name)
				code += utils.Format("cmp " + idxReg.Name + ", " + strconv.Itoa(arrLen))
				code += utils.Format("jl " + lbl)
				code += utils.Format("push " + idxReg.Name)
				code += utils.Format("call _panic_index_oob")
				code += utils.Format(lbl + ":")
				c.ctx.Reg.Free(idxExpr)
			}
		} else if isList && indexExpr.Right.Var != nil {
			pre, addrBase, heldBase := c.listBaseResolve(indexExpr.Right.Var, "", stripOuterBrackets(c.arch.VarAddr(indexExpr.Right.Var)))
			if heldBase != nil {
				// 指针链（self/this）写路径 bounds 补发：该类基址此前完全无边界
				// 保护（死代码发现前）；值语义不进此分支、行为逐位不变。
				_, lenOff, _ := c.listFields()
				ln := c.arch.LengthName(c.arch.PointerSize())
				lbl := "oob_" + expUID
				var bc string
				if idxExpr.IsConst() {
					idx := int(idxExpr.Num)
					bc = pre
					bc += utils.Format("cmp " + ln + " [" + addrBase + "+" + strconv.Itoa(lenOff) + "], " + strconv.Itoa(idx))
					bc += utils.Format("jg " + lbl)
					bc += utils.Format("push " + strconv.Itoa(idx))
					bc += utils.Format("call _panic_index_oob")
					bc += utils.Format(lbl + ":")
				} else {
					lenReg := c.allocRegAvoid(idxExpr, heldBase.Name)
					if lenReg == nil {
						lenReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
					}
					bc = pre
					bc += c.generate(idxExpr, lenReg.Name)
					bc += utils.Format("cmp " + ln + " [" + addrBase + "+" + strconv.Itoa(lenOff) + "], " + lenReg.Name)
					bc += utils.Format("jg " + lbl)
					bc += utils.Format("push " + lenReg.Name)
					bc += utils.Format("call _panic_index_oob")
					bc += utils.Format(lbl + ":")
					c.ctx.Reg.Free(idxExpr)
				}
				boundsPrepend = bc
				c.freeTmpReg(heldBase)
			}
		}
	}
	if elemSize > c.arch.PointerSize() {
		// 多槽元素赋值：使用 _memmove 复制字节
		// 1. 计算目标地址 (base + idx * elemSize) → aReg
		// 目标地址要跨右值求值（可能含调用）保持：优先绑 callee-save；
		// 池枯竭时退回普通分配（与旧行为一致）。
		var aReg *regmgr.Reg
		if csName := c.ctx.Reg.AllocCalleeSaveBind(indexExpr.Right, c.arch.CalleeSaveRegs()); csName != "" {
			aReg = c.ctx.Reg.FindByName(csName)
		} else {
			aReg = c.allocRegAvoid(indexExpr.Right, "")
			if aReg == nil {
				aReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
			}
		}
		isStackArray := indexExpr.Right.Type != nil && indexExpr.Right.Type.Kind() == "array" && indexExpr.Right.Var != nil
		var code string
		if isStackArray {
			addr := c.arch.VarAddr(indexExpr.Right.Var)
			if idx := strings.Index(addr, "["); idx > 0 {
				addr = addr[idx:]
			} else if !strings.Contains(addr, "[") {
				addr = "[" + addr + "]"
			}
			code = utils.Format("lea " + aReg.Name + ", " + addr + "; array base addr")
		} else {
			code = c.generate(indexExpr.Right, aReg.Name)
			// *[]T: 解引用指针获取 data_ptr
			if indexExpr.Right.Type != nil && indexExpr.Right.Type.IsPointer() && indexExpr.Right.Type.Elem() != nil && indexExpr.Right.Type.Elem().Kind() == "list" {
				ps := c.arch.PointerSize()
				code += utils.Format("mov " + aReg.Name + ", " + c.arch.LengthName(ps) + " [" + aReg.Name + "]")
			}
		}
		idxExpr := indexExpr.Index[0]
		if idxExpr.IsConst() {
			off := int(idxExpr.Num) * elemSize
			if off != 0 {
				code += utils.Format("add " + aReg.Name + ", " + strconv.Itoa(off))
			}
		} else {
			iReg := c.allocRegAvoid(idxExpr, aReg.Name)
			if iReg == nil {
				iReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
			}
			code += c.generate(idxExpr, iReg.Name)
			code += utils.Format("imul " + iReg.Name + ", " + strconv.Itoa(elemSize))
			code += utils.Format("add " + aReg.Name + ", " + iReg.Name)
			c.ctx.Reg.Free(idxExpr)
		}
		// 2. 获取源地址 → sReg（仅变量右侧；非变量右侧直接按三槽装载到目标地址）
		if exp.Right.Var != nil {
			sReg := c.allocRegAvoid(exp.Right, aReg.Name)
			if sReg == nil {
				sReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
			}
			srcAddr := c.arch.VarAddr(exp.Right.Var)
			if idx := strings.Index(srcAddr, "["); idx > 0 {
				srcAddr = srcAddr[idx:]
			} else if !strings.Contains(srcAddr, "[") {
				srcAddr = "[" + srcAddr + "]"
			}
			code += utils.Format("lea " + sReg.Name + ", " + srcAddr + "; src addr")
			_ = sReg
			sRegName := sReg.Name
			psLoc := c.arch.PointerSize()
			if psLoc == 8 {
				code += utils.Format("mov rdi, " + aReg.Name)
				code += utils.Format("mov rsi, " + sRegName)
				code += utils.Format("mov rdx, " + strconv.Itoa(elemSize))
				code += utils.Format("call _memmove")
			} else {
				lnLoc := c.arch.LengthName(psLoc)
				code += utils.Format("push " + lnLoc + " " + strconv.Itoa(elemSize))
				code += utils.Format("push " + sRegName)
				code += utils.Format("push " + aReg.Name)
				code += utils.Format("call _memmove")
				code += utils.Format("add esp, " + strconv.Itoa(psLoc*3))
			}
			c.ctx.Reg.Free(exp.Right)
			c.ctx.Reg.Free(indexExpr.Right)
			return boundsPrepend + code
		}
		// 非变量右侧：直接装三槽到目标地址（避免对常量串做 memmove——其不是 24B 头）
		code += c.generate(exp.Right, "["+aReg.Name+"]")
		return boundsPrepend + code
	}

	// 1. 列表指针 → aReg（跨右值求值保持：优先 callee-save）
	var aReg *regmgr.Reg
	if csName := c.ctx.Reg.AllocCalleeSaveBind(indexExpr.Right, c.arch.CalleeSaveRegs()); csName != "" {
		aReg = c.ctx.Reg.FindByName(csName)
	} else {
		aReg = c.allocRegAvoid(indexExpr.Right, "")
		if aReg == nil {
			aReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
		}
	}
	// For stack arrays, use lea to get the address
	isStackArray := indexExpr.Right.Type != nil && indexExpr.Right.Type.Kind() == "array" && indexExpr.Right.Var != nil
	var code string
	if isStackArray {
		addr := c.arch.VarAddr(indexExpr.Right.Var)
		if idx := strings.Index(addr, "["); idx > 0 {
			addr = addr[idx:]
		} else if !strings.Contains(addr, "[") {
			addr = "[" + addr + "]"
		}
		code = utils.Format("lea " + aReg.Name + ", " + addr + "; array base addr")
	} else {
		code = c.generate(indexExpr.Right, aReg.Name)
	}

	// 2. 索引偏移
	idxExpr := indexExpr.Index[0]
	if idxExpr.IsConst() {
		off := int(idxExpr.Num) * elemSize
		if off != 0 {
			code += utils.Format("add " + aReg.Name + ", " + strconv.Itoa(off))
		}
	} else {
		iReg := c.allocRegAvoid(idxExpr, aReg.Name)
		if iReg == nil {
			iReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		code += c.generate(idxExpr, iReg.Name)
		code += utils.Format("imul " + iReg.Name + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + aReg.Name + ", " + iReg.Name)
		c.ctx.Reg.Free(idxExpr)
	}

	// 3. 值最后装载到寄存器（先算地址：期间 EAX 空闲可作临时，避免覆盖值）
	vReg := c.allocReg(exp.Right)
	if vReg == nil {
		vReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code += c.generate(exp.Right, vReg.Name)

	// 4. 写入
	code += c.derefStore(c.arch.LengthName(elemSize), aReg.Name, vReg.Name)
	c.ctx.Reg.Free(exp.Right)
	c.ctx.Reg.Free(indexExpr.Right)
	return boundsPrepend + code
}

// sliceExp 切片 a[lo:hi]（三字段装载：ptr+lo*es、len=hi-lo、cap=原cap-lo）
func (c *ECompiler) sliceExp(exp *parser.Expression, result string) string {
	if exp.Right == nil || exp.Right.Type == nil {
		return ""
	}
	// 有步长或常量负边界：走新建缓冲 + 跨步拷贝路径。
	stepExpr := exp.Index[2]
	loExpr0 := exp.Index[0]
	hiExpr0 := exp.Index[1]
	needAdvanced := stepExpr != nil
	if loExpr0 != nil && loExpr0.IsConst() && int(loExpr0.Num) < 0 {
		needAdvanced = true
	}
	if hiExpr0 != nil && hiExpr0.IsConst() && int(hiExpr0.Num) < 0 {
		needAdvanced = true
	}
	if needAdvanced {
		if code := c.sliceExpAdvanced(exp, result); code != "" {
			return code
		}
	}
	elemSize := 1
	if exp.Right.Type.Kind() == "list" {
		lt, ok := exp.Right.Type.(*typeSys.ListType)
		if !ok || lt.Elem() == nil {
			return ""
		}
		elemSize = lt.Elem().Size()
	}
	ps := c.arch.PointerSize()
	sp := c.arch.StackPtr()
	ln := c.arch.LengthName(ps)
	_, lenOff, capOff := c.listFields()
	loExpr := exp.Index[0]
	hiExpr := exp.Index[1]

	var code string
	ptrReg := c.allocReg(exp.Right)
	if ptrReg == nil {
		ptrReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}

	// lo 为非常量时先装配 lo（lo 暂存于栈，不依赖寄存器分配器避让 RAX）；
	// 非非常量 lo 提前生成 Right 并在 lo 加法后直接交付。
	loExhausted := loExpr != nil && !loExpr.IsConst()
	if !loExhausted {
		code += c.generate(exp.Right, ptrReg.Name)
		if ro := c.getRegByName(ptrReg.Name); ro != nil {
			c.ctx.Reg.Force(ro, exp.Right)
		}
	}

	var loReg *regmgr.Reg
	loConst := 0

	// 3. lo：常量直接折叠；非常量走统一栈中转序列（下方 loExhausted 分支）。
	if loExpr != nil && loExpr.IsConst() {
		loConst = int(loExpr.Num)
		code += utils.Format("add " + ptrReg.Name + ", " + strconv.Itoa(loConst*elemSize))
	}

	if loExhausted {
		retReg := c.arch.ReturnReg()
		// 预留五结果槽（按指针大小）：R.ptr=[sp]、R.len=[sp+ps]、R.cap=[sp+2ps]、
		// staging idx=[sp+3ps]、staging right=[sp+4ps]。
		// Right 基址与 idx 都先落进 staging 槽，再按槽取出重算 R.ptr，
		// 完全不依赖寄存器（含 RAX）的临时分配顺序，x86 6 GPR 亦安全。
		code += utils.Format("sub " + sp + ", " + strconv.Itoa(5*ps))
		code += c.generate(exp.Right, ptrReg.Name)
		if ro := c.getRegByName(ptrReg.Name); ro != nil {
			c.ctx.Reg.Force(ro, exp.Right)
		}
		code += utils.Format("mov " + ln + " [" + sp + "+" + strconv.Itoa(4*ps) + "], " + ptrReg.Name + "; staging right")
		code += c.generate(loExpr, retReg)
		code += utils.Format("mov " + ln + " [" + sp + "+" + strconv.Itoa(3*ps) + "], " + retReg + "; staging lo idx")
		// R.ptr = Right 基址 + idx*elemSize（按 staging 全部从槽重算）
		code += utils.Format("mov " + retReg + ", [" + sp + "+" + strconv.Itoa(3*ps) + "]")
		code += utils.Format("imul " + retReg + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + retReg + ", [" + sp + "+" + strconv.Itoa(4*ps) + "]")
		code += utils.Format("mov " + ln + " [" + sp + "], " + retReg + "; R.ptr")
		// R.len：hi>常量 → hi-idx；hi 缺省 → 集合 len-idx；集合为变量可直读头。
		if hiExpr != nil && hiExpr.IsConst() {
			code += utils.Format("mov " + retReg + ", " + strconv.Itoa(int(hiExpr.Num)))
		} else if hiExpr != nil {
			code += c.generate(hiExpr, retReg)
		} else if exp.Right.Var != nil {
			lenAddr := stripOuterBrackets(c.arch.VarAddr(exp.Right.Var)) + "+" + strconv.Itoa(lenOff)
			code += utils.Format("mov " + retReg + ", " + ln + " [" + lenAddr + "]")
		} else {
			code += utils.Format("mov " + retReg + ", 0")
		}
		code += utils.Format("sub " + retReg + ", [" + sp + "+" + strconv.Itoa(3*ps) + "]; R.len = hi|len - lo")
		code += utils.Format("mov " + ln + " [" + sp + "+" + strconv.Itoa(ps) + "], " + retReg + "; R.len")
		// R.cap = 集合 cap - idx（仅变量形态）
		if exp.Right.Var != nil {
			capAddr := stripOuterBrackets(c.arch.VarAddr(exp.Right.Var)) + "+" + strconv.Itoa(capOff)
			code += utils.Format("mov " + retReg + ", " + ln + " [" + capAddr + "]")
			code += utils.Format("sub " + retReg + ", [" + sp + "+" + strconv.Itoa(3*ps) + "]")
			code += utils.Format("mov " + ln + " [" + sp + "+" + strconv.Itoa(2*ps) + "], " + retReg + "; R.cap")
		} else {
			code += utils.Format("mov " + ln + " [" + sp + "+" + strconv.Itoa(2*ps) + "], 0; R.cap")
		}
		// 交付
		if strings.Contains(result, "[") {
			base := stripOuterBrackets(result)
			// 先 staging 三个值入寄存器，恢复 sp 之后再写目标槽
			// （dst 可能是 rsp 相对偏移，此时正在触碰的是预留槽本身）。
			t0 := c.allocTmpReg()
			t1 := c.allocTmpReg()
			t2 := c.allocTmpReg()
			code += utils.Format("mov " + t0.Name + ", [" + sp + "]")
			code += utils.Format("mov " + t1.Name + ", [" + sp + "+" + strconv.Itoa(ps) + "]")
			code += utils.Format("mov " + t2.Name + ", [" + sp + "+" + strconv.Itoa(2*ps) + "]")
			code += utils.Format("add " + sp + ", " + strconv.Itoa(5*ps))
			code += c.storeVal(base, ln, t0.Name)
			code += c.storeVal(base+"+"+strconv.Itoa(lenOff), ln, t1.Name)
			code += c.storeVal(base+"+"+strconv.Itoa(capOff), ln, matchMemWidth(base+"+"+strconv.Itoa(capOff), t2.Name))
			c.freeTmpReg(t0)
			c.freeTmpReg(t1)
			c.freeTmpReg(t2)
		} else if result == "push" {
			// 三槽以 [ptr][len][cap] 直接压参（从右到左 cap/len/ptr，cdecl），
			// 再跳过四槽预留区。
			code += utils.Format("push " + ln + " [" + sp + "+" + strconv.Itoa(2*ps) + "]; cap")
			code += utils.Format("push " + ln + " [" + sp + "+" + strconv.Itoa(ps) + "]; len")
			code += utils.Format("push " + ln + " [" + sp + "]; ptr")
			code += utils.Format("add " + sp + ", " + strconv.Itoa(5*ps) + "; 跳过预留槽")
		} else {
			code += utils.Format("pop " + result + "; R.ptr")
			code += utils.Format("add " + sp + ", " + strconv.Itoa(4*ps) + "; 清 R.len/R.cap/staging 槽")
		}
		c.ctx.Reg.Free(loExpr)
		c.ctx.Reg.Free(hiExpr)
		c.ctx.Reg.Free(exp.Right)
		return code
	}

	if loReg != nil {
		// 物理保护基址：内层表达式编译的临时分配不感知外部持有值
		code += utils.Format("push " + ptrReg.Name + "; 保护基址")
		code += c.generate(loExpr, loReg.Name)
		code += utils.Format("imul " + loReg.Name + ", " + strconv.Itoa(elemSize))
		code += utils.Format("mov " + ptrReg.Name + ", [" + sp + "]")
		code += utils.Format("add " + ptrReg.Name + ", " + loReg.Name)
		code += utils.Format("add " + sp + ", " + strconv.Itoa(ps))
	}

	// 4+5. 统一保护块：len 与 cap 在同一保护区内经返回寄存器串行计算。
	// 压序：lo(若有)→基址；栈布局 [0]=lo、[ps]=基址；子表达式编译全程可安全
	// 覆盖任何寄存器（持有值都在栈上），彻底规避分配器不感知外部持有的问题。
	pushedLo := false
	if loReg != nil {
		code += utils.Format("push " + loReg.Name + "; 保护 lo")
		pushedLo = true
	}
	code += utils.Format("push " + ptrReg.Name + "; 保护基址")
	loSlot := "[" + sp + "]"

	var lenVal string
	var lenTmp *regmgr.Reg // runtime-hi 分支的 len 需要独立寄存器，防止被 cap 计算覆盖
	if hiExpr != nil && hiExpr.IsConst() {
		lenVal = strconv.Itoa(int(hiExpr.Num) - loConst)
	} else if hiExpr != nil {
		lReg := c.allocTmpReg()
		code += c.generate(hiExpr, lReg.Name)
		if pushedLo {
			code += utils.Format("sub " + lReg.Name + ", " + ln + " " + loSlot + "; len = hi - lo")
		} else {
			code += utils.Format("sub " + lReg.Name + ", " + strconv.Itoa(loConst))
		}
		lenVal = lReg.Name
		lenTmp = lReg
	} else {
		// hi 缺省：len = 原集合 len - lo（hi==nil 即取到末尾）。
		// 仅"右边是变量"时能读到集合 len 槽；其余形状（字面量容器等）退回 0。
		if exp.Right.Var != nil {
			lenAddr := stripOuterBrackets(c.arch.VarAddr(exp.Right.Var)) + "+" + strconv.Itoa(lenOff)
			lReg := c.allocTmpReg()
			code += utils.Format("mov " + lReg.Name + ", " + ln + " [" + lenAddr + "]")
			if pushedLo {
				code += utils.Format("sub " + lReg.Name + ", " + ln + " " + loSlot + "; len - lo")
			} else if loConst != 0 {
				code += utils.Format("sub " + lReg.Name + ", " + strconv.Itoa(loConst))
			}
			lenVal = lReg.Name
			lenTmp = lReg
		} else {
			lenVal = "0"
		}
	}

	var capVal string
	if exp.Right.Var != nil {
		capAddr := stripOuterBrackets(c.arch.VarAddr(exp.Right.Var)) + "+" + strconv.Itoa(capOff)
		retReg := c.arch.ReturnReg()
		code += utils.Format("mov " + retReg + ", " + ln + " [" + capAddr + "]")
		if pushedLo {
			code += utils.Format("sub " + retReg + ", " + ln + " " + loSlot + "; cap - lo")
		} else if loConst != 0 {
			code += utils.Format("sub " + retReg + ", " + strconv.Itoa(loConst))
		}
		capVal = retReg
	} else {
		capVal = "0"
	}

	// 6. 交付。栈顶当前：[0]=基址、[ps]=lo（保护槽）。
	deliveredPtr := false
	// 保护栈：pushedLo 时 [sp]=基址 [sp+ps]=lo；否则只有 [sp]=基址。
	barrierSlots := 1
	if pushedLo {
		barrierSlots = 2
	}
	if strings.Contains(result, "[") {
		base := stripOuterBrackets(result)
		tmp := c.allocTmpReg()
		if pushedLo {
			code += utils.Format("mov " + tmp.Name + ", [" + sp + "+" + strconv.Itoa(ps) + "]")
			code += utils.Format("add " + tmp.Name + ", [" + sp + "]")
		} else {
			code += utils.Format("mov " + tmp.Name + ", [" + sp + "]")
		}
		// 先恢复 sp 再按 result（rsp 相对）写槽：tmp 已取出推送基址和保护槽，
		// 此时 [sp+off] 才是目标槽真实位置（buffer 按 sp 相对取址）。
		code += utils.Format("add " + sp + ", " + strconv.Itoa(barrierSlots*ps))
		code += c.storeVal(base, ln, tmp.Name)
		code += c.storeVal(base+"+"+strconv.Itoa(lenOff), ln, matchMemWidth(base+"+"+strconv.Itoa(lenOff), lenVal))
		code += c.storeVal(base+"+"+strconv.Itoa(capOff), ln, matchMemWidth(base+"+"+strconv.Itoa(capOff), capVal))
		c.freeTmpReg(tmp)
		deliveredPtr = true
	} else if result == "push" {
		// 交付序：先 cap/len（压在深处），最后弹基址折叠成 ptr 压入顶端。
		// 栈：[0]=基址 [ps]=lo（若有）；先压 capVal/lenVal 会落在保护槽上方，
		// 因此顺序：push capVal、push lenVal、mov base→add lo→push ptr、清保护槽。
		code += utils.Format("push " + capVal + "; cap")
		code += utils.Format("push " + lenVal + "; len")
		code += utils.Format("mov " + ptrReg.Name + ", [" + sp + "+" + strconv.Itoa(2*ps) + "]")
		if pushedLo {
			code += utils.Format("add " + ptrReg.Name + ", [" + sp + "+" + strconv.Itoa(3*ps) + "]")
		}
		code += utils.Format("push " + ptrReg.Name + "; ptr")
		code += utils.Format("add " + sp + ", " + strconv.Itoa(barrierSlots*ps) + "; 清保护槽")
		deliveredPtr = true
	} else {
		// 寄存器结果
		tmp := c.allocTmpReg()
		if pushedLo {
			code += utils.Format("mov " + tmp.Name + ", [" + sp + "+" + strconv.Itoa(ps) + "]")
			code += utils.Format("add " + tmp.Name + ", [" + sp + "]")
		} else {
			code += utils.Format("mov " + tmp.Name + ", [" + sp + "]")
		}
		code += utils.Format("mov " + result + ", " + matchMemWidth(result, tmp.Name))
		code += utils.Format("add " + sp + ", " + strconv.Itoa(barrierSlots*ps))
		c.freeTmpReg(tmp)
		deliveredPtr = true
	}

	if !deliveredPtr {
		code += utils.Format("add " + sp + ", " + strconv.Itoa(barrierSlots*ps))
	}
	if lenTmp != nil {
		c.freeTmpReg(lenTmp)
	}
	c.ctx.Reg.Free(loExpr)
	c.ctx.Reg.Free(hiExpr)
	c.ctx.Reg.Free(exp.Right)
	return code
}

// listFieldRead 读容器字段（len/cap）：变量直接读三槽；表达式先算 ptr 再偏移
// builtinStringSlotCall len(s)/cap(s)（string 参数）链接到全局符号实现：
// 装载容器地址后 call __string_len/cap（由 strings 包 build link 提供）。
// 返回 EAX/RAX；结果装载模式与 listFieldRead 一致（push/[mem]/寄存器）。
func (c *ECompiler) builtinStringSlotCall(arg *parser.Expression, sym string, result string) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	var code string
	// 与普通容器实参一致的三槽传递（RDI/RSI/RDX = ptr/len/cap，
	// 或 32 位栈上 cap/len/ptr 右到左压栈），被调方按标准约定溢出/读取
	base := stripOuterBrackets(c.arch.VarAddr(arg.Var))
	// 指针基字段/this 字段：VarAddr 是栈槽（基础变量的槽），三槽都读不到
	// 正确的头位置——必须先加载指针、再按 [reg+0/8/16] 读。
	pre := ""
	if needPtrMem(arg.Var) {
		var reg *regmgr.Reg
		pre, base, reg = c.ptrMem(arg.Var)
		defer c.freeTmpReg(reg)
	} else if isThisField(arg.Var) {
		var reg *regmgr.Reg
		pre, base, reg = c.thisMem(arg.Var)
		defer c.freeTmpReg(reg)
	}
	// S0-2（P11）：三字段布局消费查表化（data/len/cap 经 listFields）
	// 直接以内存操作数装载三槽（无需地址寄存器，避免与目标寄存器同名冲突）
	_, lenOff, capOff := c.listFields()
	if ps == 8 {
		code += pre + utils.Format("mov RDI, " + ln + " [" + base + "]")
		code += utils.Format("mov RSI, " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "]")
		code += utils.Format("mov RDX, " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "]")
	} else {
		code += pre + utils.Format("push " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "]")
		code += utils.Format("push " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "]")
		code += utils.Format("push " + ln + " [" + base + "]")
	}
	code += utils.Format("call " + sym)
	if ps == 4 {
		code += utils.Format("add esp, 12")
	}
	// 结果装载（返回 EAX/RAX）。retReg 中是长度值本身，
	// 不是指针 —— 直接 mov 到目标，禁止经 derefLoad 二次解引用
	retReg := c.arch.ReturnReg()
	if result == "push" {
		code += utils.Format("push " + retReg)
	} else if strings.Contains(result, "[") {
		code += utils.Format("mov " + result + ", " + matchMemWidth(result, retReg))
	} else {
		code += utils.Format("mov " + result + ", " + retReg + "; len/cap 结果")
	}
	return code
}

func (c *ECompiler) listFieldRead(arg *parser.Expression, off int, result string) string {
	ln := c.arch.LengthName(c.arch.PointerSize())
	// 指针基字段/this 字段：先加载基础指针、再间接寻址（与 Var 分支同构）。
	if arg.Var != nil && needPtrMem(arg.Var) {
		pre, addr, reg := c.ptrMem(arg.Var)
		addr = addr + "+" + strconv.Itoa(off)
		var code string
		if result == "push" {
			code = utils.Format("push " + ln + " [" + addr + "]")
		} else if strings.Contains(result, "[") {
			code = c.derefLoad(ln, result, addr)
		} else {
			code = utils.Format("mov " + result + ", " + ln + " [" + addr + "]")
		}
		c.freeTmpReg(reg)
		return pre + code
	}
	if arg.Var != nil && isThisField(arg.Var) {
		pre, addr, reg := c.thisMem(arg.Var)
		addr = addr + "+" + strconv.Itoa(off)
		var code string
		if result == "push" {
			code = utils.Format("push " + ln + " [" + addr + "]")
		} else if strings.Contains(result, "[") {
			code = c.derefLoad(ln, result, addr)
		} else {
			code = utils.Format("mov " + result + ", " + ln + " [" + addr + "]")
		}
		c.freeTmpReg(reg)
		return pre + code
	}
	if arg.Var != nil {
		addr := stripOuterBrackets(c.arch.VarAddr(arg.Var)) + "+" + strconv.Itoa(off)
		if result == "push" {
			return utils.Format("push " + ln + " [" + addr + "]")
		}
		if strings.Contains(result, "[") {
			return c.derefLoad(ln, result, addr)
		}
		return utils.Format("mov " + result + ", " + ln + " [" + addr + "]")
	}
	// 非变量、类型为 list 的表达式（如 a[0] 之于 [][]int）：三槽在
	// 容器缓冲区里 inline 存储；构造到临时栈区再按槽读，避免把当前
	// 表达式当成裸指针去解引到堆指针处（会读到元素本身、读成乱码）。
	if arg.Type != nil && arg.Type.Kind() == "list" && arg.Type.IsPointer() == false {
		ps := c.arch.PointerSize()
		ln2 := c.arch.LengthName(ps)
		frame := ps * 3
		code := utils.Format("sub rsp, " + strconv.Itoa(frame) + "; len/cap 三槽临时区")
		code += c.generate(arg, "[rsp+0]")
		addr2 := "rsp+" + strconv.Itoa(off)
		if result == "push" {
			code += utils.Format("push " + ln2 + " [" + addr2 + "]")
		} else if strings.Contains(result, "[") {
			code += c.derefLoad(ln2, result, addr2)
		} else {
			code += utils.Format("mov " + result + ", " + ln2 + " [" + addr2 + "]")
		}
		code += utils.Format("add rsp, " + strconv.Itoa(frame) + "; len/cap 临时区结束")
		return code
	}
	// 表达式：算到寄存器（ptr 槽），再读 [reg+off]
	rReg := c.allocReg(arg)
	if rReg == nil {
		rReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code := c.generate(arg, rReg.Name)
	addr := rReg.Name + "+" + strconv.Itoa(off)
	if result == "push" {
		code += utils.Format("push " + ln + " [" + addr + "]")
	} else if strings.Contains(result, "[") {
		code += c.derefLoad(ln, result, addr)
	} else {
		code += utils.Format("mov " + result + ", " + ln + " [" + addr + "]")
	}
	c.ctx.Reg.Free(arg)
	return code
}

// builtinCall 内建调用分派：len/cap/append/make；非内建返回空串走叶子
func (c *ECompiler) builtinCall(exp *parser.Expression, result string) string {
	call := exp.Call
	if call == nil {
		return ""
	}
	name := call.Name.String()
	_, lenOff, capOff := c.listFields()
	switch name {
	case "int", "uint", "i8", "i16", "i32", "i64",
		"u8", "u16", "u32", "u64", "byte", "f32", "f64",
		"int8", "int16", "int32", "int64", "uint8", "uint16", "uint32", "uint64":
		if call.ConvertType != nil {
			return c.builtinConvert(call, result)
		}
	case "len", "cap":
		if len(call.Args) == 1 && call.Args[0] != nil && call.Args[0].Value != nil &&
			call.Args[0].Value.Type != nil {
			argType := call.Args[0].Value.Type
			// 数组 len 是编译期常量
			if argType.Kind() == "array" && name == "len" {
				at := argType.(*typeSys.ArrayType)
				lenVal := strconv.Itoa(at.Len())
				return utils.Format("mov " + result + ", " + lenVal + "; array len")
			}
			// map len：nil map 返回 0，否则读 header 的 count 字段。
			if argType.Kind() == "map" && name == "len" {
				return c.mapLenValue(call.Args[0].Value, result)
			}
			if isListLike(argType) {
				off := lenOff
				if name == "cap" {
					off = capOff
				}
				// string 参数且 build link 提供了全局符号（strings 包实现）：
				// 改为 call __string_len/cap，链接到 strings 包的具体实现。
				// 仅变量参数走 link 路径（需按三槽寄存器约定传参）；
				// 其它表达式回退内联槽位读取。
				if call.Args[0].Value.Type.Kind() == "string" && call.Args[0].Value.Var != nil &&
					c.ctx.StringSyms != nil && c.ctx.StringSyms["__string_"+name] {
					return c.builtinStringSlotCall(call.Args[0].Value, "__string_"+name, result)
				}
				return c.listFieldRead(call.Args[0].Value, off, result)
			}
		}
	case "append":
		return c.builtinAppend(call, result)
	case "copy":
		return c.builtinCopy(call, result)
	case "make":
		return c.builtinMake(exp, call, result)
	case "new", "memory.new":
		return c.builtinNew(exp, call, result)
	case "newRC":
		return c.builtinNewRC(exp, call, result)
	case "sizeof", "memory.sizeof":
		if call.NewType != nil {
			// 结果交付形态：x86 cdecl 调用实参走 push（result=="push"），
			// 旧实现一律发 mov <result>,imm → `mov push, 4` NASM 报错
			// （Wave Mp x86 实锤：maps.new(0, sizeof[int]())）。
			emit := func(size int) string {
				if result == "push" {
					return utils.Format("push " + strconv.Itoa(size))
				}
				return utils.Format("mov " + result + ", " + strconv.Itoa(size))
			}
			// TypeParam: 从单态化替换表解析具体类型
			if tp, ok := call.NewType.(*typeSys.TypeParam); ok {
				if c.ctx.TypeSubst != nil {
					if concrete, ok := c.ctx.TypeSubst[tp.Name]; ok {
						return emit(concrete.Size())
					}
				}
				// 编译泛型包时不知道具体类型 → 返回 0 (占位，单态化后重编译)
				return emit(0)
			}
			return emit(call.NewType.Size())
		}
	case "unsafe.cast":
		// unsafe.cast[T](addr) — 位级重解释（§11.3）：保留低 sizeof(T) 字节。
		if len(call.Args) == 1 && call.Args[0] != nil && call.Args[0].Value != nil {
			// 多槽源（string/list/struct 值，Size > 指针宽）→ 窄目标（≤指针宽）：
			// 旧实现直接交给 generate 的叶子多槽装载，按源宽度 copySlots 扩散写，
			// 会覆盖目标槽之后的栈帧（p: *u8 = unsafe.cast[*u8](s) 实锤踩掉 s.ptr/s.len）。
			if code := c.emitNarrowCastFromMultiSlot(call, call.Args[0].Value, result); code != "" {
				return code
			}
			// 不能调用 Compile()：它会整体重建 expInfo，
			// 外层 derefSet 已收集好的 q+1 等兄弟子树信息全被丢弃，
			// 导致 deref= 语句的指针侧从此发射为空。
			return c.generate(call.Args[0].Value, result)
		}
	}
	return ""
}

// builtinConvert 生成显式数值转换 int(x)/i64(x)/f64(x) 等。
// 与 unsafe.cast 不同：这里按数值语义转换（截断/扩展/浮点舍入），
// 不是位模式重解释。
func (c *ECompiler) builtinConvert(call *parser.CallBlock, result string) string {
	if call == nil || call.ConvertType == nil || len(call.Args) != 1 ||
		call.Args[0] == nil || call.Args[0].Value == nil {
		return ""
	}
	arg := call.Args[0].Value
	if arg.Type == nil {
		return ""
	}
	code := c.generate(arg, c.arch.ReturnReg())
	code += c.emitConvert(arg.Type, call.ConvertType)
	code += c.storeConvertResult(result, call.ConvertType)
	return code
}

// emitConvert 把返回寄存器中的 src 值按数值语义转换成 dst。
// 约定：f32/f64 都以 IEEE-754 位模式存放在通用寄存器中，转换借 XMM0 中转。
func (c *ECompiler) emitConvert(src, dst typeSys.Type) string {
	srcFloat := typeSys.CheckKind(src, "float")
	dstFloat := typeSys.CheckKind(dst, "float")
	reg := c.arch.ReturnReg()

	// 同类型：无操作。
	if typeSys.TypeEqual(src, dst) {
		return ""
	}

	switch {
	case srcFloat && dstFloat:
		if src.Type() == "f32" {
			// f32 → f64
			return utils.Format("movd XMM0, "+eName(reg)+"; f32 bits") +
				utils.Format("cvtss2sd XMM0, XMM0; f32 -> f64") +
				utils.Format("movq "+reg+", XMM0")
		}
		// f64 → f32
		return utils.Format("movq XMM0, "+reg+"; f64 bits") +
			utils.Format("cvtsd2ss XMM0, XMM0; f64 -> f32") +
			utils.Format("movd "+eName(reg)+", XMM0")

	case srcFloat:
		// 浮点 → 整数：向零截断。
		if src.Type() == "f32" {
			return utils.Format("movd XMM0, "+eName(reg)+"; f32 bits") +
				utils.Format("cvttss2si "+reg+", XMM0; f32 -> int") +
				c.normalizeIntReg(dst)
		}
		return utils.Format("movq XMM0, "+reg+"; f64 bits") +
			utils.Format("cvttsd2si "+reg+", XMM0; f64 -> int") +
			c.normalizeIntReg(dst)

	case dstFloat:
		// 整数 → 浮点：先按源宽度扩展到 64 位（无符号 64 位超大值不在 v1 范围）。
		code := c.extendIntReg(src)
		if dst.Type() == "f32" {
			return code +
				utils.Format("cvtsi2ss XMM0, "+reg+"; int -> f32") +
				utils.Format("movd "+eName(reg)+", XMM0")
		}
		return code +
			utils.Format("cvtsi2sd XMM0, "+reg+"; int -> f64") +
			utils.Format("movq "+reg+", XMM0")

	default:
		// 整数 → 整数：先按源宽度扩展，再按目标宽度归一化（截断低位）。
		return c.extendIntReg(src) + c.normalizeIntReg(dst)
	}
}

// intSigned 判断整数类型是否有符号。Kind "int" 覆盖 i8/i16/i32/i64/int。
func intSigned(t typeSys.Type) bool {
	if t == nil {
		return true
	}
	if _, ok := t.(*typeSys.TypeParam); ok {
		return true
	}
	return typeSys.CheckKind(t, "int")
}

// extendIntReg 把返回寄存器中的整数按源类型宽度扩展到寄存器全宽
// （x86_64 扩展到 64 位；x86 扩展到 32 位）。
func (c *ECompiler) extendIntReg(t typeSys.Type) string {
	if t == nil {
		return ""
	}
	reg := c.arch.ReturnReg()
	size := t.Size()
	signed := intSigned(t)
	if c.arch.PointerSize() == 4 {
		switch size {
		case 1:
			if signed {
				return utils.Format("movsx " + reg + ", " + lo8(reg) + "; sign-extend i8")
			}
			return utils.Format("movzx " + reg + ", " + lo8(reg) + "; zero-extend u8")
		case 2:
			if signed {
				return utils.Format("movsx " + reg + ", " + lo16(reg) + "; sign-extend i16")
			}
			return utils.Format("movzx " + reg + ", " + lo16(reg) + "; zero-extend u16")
		}
		return ""
	}
	switch size {
	case 1:
		if signed {
			return utils.Format("movsx " + reg + ", " + lo8(reg) + "; sign-extend i8")
		}
		return utils.Format("movzx " + reg + ", " + lo8(reg) + "; zero-extend u8")
	case 2:
		if signed {
			return utils.Format("movsx " + reg + ", " + lo16(reg) + "; sign-extend i16")
		}
		return utils.Format("movzx " + reg + ", " + lo16(reg) + "; zero-extend u16")
	case 4:
		if signed {
			return utils.Format("movsxd " + reg + ", " + eName(reg) + "; sign-extend i32")
		}
		return utils.Format("mov " + eName(reg) + ", " + eName(reg) + "; zero-extend u32")
	}
	return ""
}

// normalizeIntReg 把转换结果按目标整数类型宽度归一化，保证寄存器里的
// 值与目标类型语义一致（窄化截断低位，有符号补符号位）。
func (c *ECompiler) normalizeIntReg(t typeSys.Type) string {
	if t == nil {
		return ""
	}
	size := t.Size()
	if c.arch.PointerSize() == 8 && size == 8 {
		return ""
	}
	if c.arch.PointerSize() == 4 && size >= 4 {
		return ""
	}
	return c.extendIntReg(t)
}

// storeConvertResult 把返回寄存器中的转换结果交付到 result。
// result 可能是寄存器名、内存操作数、"push" 或空串（结果留在返回寄存器）。
func (c *ECompiler) storeConvertResult(result string, t typeSys.Type) string {
	reg := c.arch.ReturnReg()
	if result == "" || result == reg {
		return ""
	}
	if result == "push" {
		return utils.Format("push " + reg)
	}
	size := 8
	if t != nil && t.Size() > 0 {
		size = t.Size()
	}
	if strings.Contains(result, "[") {
		dst := result
		prefix := operandPrefix(dst)
		if prefix == "" {
			switch size {
			case 1:
				prefix = "BYTE"
			case 2:
				prefix = "WORD"
			case 4:
				prefix = "DWORD"
			default:
				prefix = "QWORD"
			}
			dst = prefix + " " + dst
		}
		low := reg
		switch prefix {
		case "BYTE":
			low = lo8(reg)
		case "WORD":
			low = lo16(reg)
		case "DWORD":
			low = eName(reg)
		}
		return utils.Format("mov " + dst + ", " + low)
	}
	// 寄存器目标：按目标宽度取低寄存器名。
	return utils.Format("mov " + regWidthName(result, size) + ", " + regWidthName(reg, size))
}

// operandPrefix 返回内存操作数已有的宽度前缀（容忍前缀与 '[' 之间的空格）。
func operandPrefix(mem string) string {
	u := strings.ToUpper(strings.TrimSpace(mem))
	switch {
	case strings.HasPrefix(u, "QWORD"):
		return "QWORD"
	case strings.HasPrefix(u, "DWORD"):
		return "DWORD"
	case strings.HasPrefix(u, "WORD"):
		return "WORD"
	case strings.HasPrefix(u, "BYTE"):
		return "BYTE"
	}
	return ""
}

// regWidthName 返回寄存器按指定字节宽度的名字。
func regWidthName(reg string, size int) string {
	switch size {
	case 1:
		return lo8(reg)
	case 2:
		return lo16(reg)
	case 4:
		return eName(reg)
	}
	return reg
}

// builtinCopy copy(dst, src)：同 Kind 容器（str/str 或 list/list）元素拷贝，
// 拷贝 min(len(dst), len(src)) 个元素，返回拷贝计数。
// v1 与 append 同约束：dst/src 必须为容器变量（直接取栈地址读三槽）。
// 注意：字符串字面量位于只读 .data 段，不可作为 dst。
// 实现：计数经栈中转交付；rep movsb 前后保存/恢复 RSI/RDI/RCX。
func (c *ECompiler) builtinCopy(call *parser.CallBlock, result string) string {
	if len(call.Args) < 2 || call.Args[0] == nil || call.Args[0].Value == nil ||
		call.Args[1] == nil || call.Args[1].Value == nil {
		return ""
	}
	dstExp := call.Args[0].Value
	srcExp := call.Args[1].Value
	if dstExp.Var == nil || srcExp.Var == nil ||
		dstExp.Type == nil || srcExp.Type == nil ||
		dstExp.Type.Kind() != srcExp.Type.Kind() || !isListLike(dstExp.Type) {
		return ""
	}
	elemSize := 1
	if lt, ok := dstExp.Type.(*typeSys.ListType); ok && lt.Elem() != nil {
		elemSize = lt.Elem().Size()
	}
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	_, lenOff, _ := c.listFields()
	dstBase := stripOuterBrackets(c.arch.VarAddr(dstExp.Var))
	srcBase := stripOuterBrackets(c.arch.VarAddr(srcExp.Var))
	label := "copy_" + strconv.Itoa(c.idx)
	scratch := c.arch.ReturnReg()

	var code string
	// 计数 = min(len(dst), len(src))
	code += utils.Format("mov " + scratch + ", " + ln + " [" + dstBase + "+" + strconv.Itoa(lenOff) + "]")
	code += utils.Format("cmp " + scratch + ", " + ln + " [" + srcBase + "+" + strconv.Itoa(lenOff) + "]")
	code += utils.Format("jbe " + label + "_min")
	code += utils.Format("mov " + scratch + ", " + ln + " [" + srcBase + "+" + strconv.Itoa(lenOff) + "]")
	code += utils.Format(label + "_min:")

	// 元素计数压栈暂存（即结果），换算字节数
	code += utils.Format("push " + scratch + "; copy count")
	code += utils.Format("imul " + scratch + ", " + strconv.Itoa(elemSize))

	// rep movsb 字节拷贝（DF 保持清零；先保存可能存活的 SI/DI/CX）
	if ps == 8 {
		code += utils.Format("push RSI")
		code += utils.Format("push RDI")
		code += utils.Format("push RCX")
		code += utils.Format("mov RSI, " + ln + " [" + srcBase + "]")
		code += utils.Format("mov RDI, " + ln + " [" + dstBase + "]")
		code += utils.Format("mov RCX, " + scratch)
		code += utils.Format("rep movsb; copy bytes")
		code += utils.Format("pop RCX")
		code += utils.Format("pop RDI")
		code += utils.Format("pop RSI")
	} else {
		code += utils.Format("push ESI")
		code += utils.Format("push EDI")
		code += utils.Format("push ECX")
		code += utils.Format("mov ESI, " + ln + " [" + srcBase + "]")
		code += utils.Format("mov EDI, " + ln + " [" + dstBase + "]")
		code += utils.Format("mov ECX, " + scratch)
		code += utils.Format("rep movsb; copy bytes")
		code += utils.Format("pop ECX")
		code += utils.Format("pop EDI")
		code += utils.Format("pop ESI")
	}

	// 交付拷贝计数：push 模式下计数已在栈顶
	if result == "push" {
		return code
	}
	if strings.Contains(result, "[") {
		code += utils.Format("pop " + scratch + "; copy result")
		code += utils.Format("mov " + ln + " " + result + ", " + matchMemWidth(result, scratch))
		return code
	}
	code += utils.Format("pop " + result + "; copy result")
	return code
}

// builtinAppend append(a, v)：len<cap 直写，否则 realloc 扩容（暂只支持变量 a）
func (c *ECompiler) builtinAppend(call *parser.CallBlock, result string) string {
	if len(call.Args) < 2 || call.Args[0] == nil || call.Args[0].Value == nil ||
		call.Args[1] == nil || call.Args[1].Value == nil {
		return ""
	}
	aExp := call.Args[0].Value
	elem := call.Args[1].Value
	if aExp.Var == nil || aExp.Type == nil || !isListLike(aExp.Type) {
		return ""
	}
	elemSize := 1
	if aExp.Type.Kind() == "list" {
		if lt, ok := aExp.Type.(*typeSys.ListType); ok && lt.Elem() != nil {
			elemSize = lt.Elem().Size()
		}
	}
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	_, lenOff, capOff := c.listFields()
	callee := c.pickCalleeSave()
	if callee == "" {
		callee = c.arch.CalleeSaveReg()
	}
	base := stripOuterBrackets(c.arch.VarAddr(aExp.Var))
	label := "append_" + strconv.Itoa(c.idx)

	// 1. 值 → callee-save（跨 realloc call 安全）
	code := c.generate(elem, callee)

	// 2. ptr 与 len
	ptrReg := c.allocRegAvoid(aExp, callee)
	if ptrReg == nil {
		ptrReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	code += c.generate(aExp, ptrReg.Name)
	lReg := c.allocRegAvoid(aExp, ptrReg.Name)
	if lReg == nil {
		lReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
	}
	code += utils.Format("mov " + lReg.Name + ", " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "]")

	// 3. len < cap → 直写
	code += utils.Format("cmp " + lReg.Name + ", " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "]")
	code += utils.Format("jge " + label + "_grow")
	code += utils.Format("mov " + c.arch.LengthName(elemSize) + " [" + ptrReg.Name + "+" + lReg.Name + "*" + strconv.Itoa(elemSize) + "], " + matchMemWidth(c.arch.LengthName(elemSize)+"[", callee))
	code += utils.Format("add " + lReg.Name + ", 1")
	code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "], " + lReg.Name)
	code += utils.Format("jmp " + label + "_end")

	// 4. grow：newCap = max(cap*2, 1)；realloc(ptr, newCap*es)；重读 len 写元素
	code += utils.Format(label + "_grow:")
	code += utils.Format("mov " + lReg.Name + ", " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "]")
	code += utils.Format("shl " + lReg.Name + ", 1")
	code += utils.Format("cmp " + lReg.Name + ", 1")
	code += utils.Format("jge " + label + "_grow2")
	code += utils.Format("mov " + lReg.Name + ", 1")
	code += utils.Format(label + "_grow2:")
	code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "], " + lReg.Name)
	code += utils.Format("imul " + lReg.Name + ", " + strconv.Itoa(elemSize))
	code += c.emitRealloc(ptrReg.Name, lReg.Name)
	code += utils.Format("mov " + ptrReg.Name + ", " + c.arch.ReturnReg())
	code += utils.Format("mov " + lReg.Name + ", " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "]")
	code += utils.Format("mov " + c.arch.LengthName(elemSize) + " [" + ptrReg.Name + "+" + lReg.Name + "*" + strconv.Itoa(elemSize) + "], " + matchMemWidth(c.arch.LengthName(elemSize)+"[", callee))
	code += utils.Format("add " + lReg.Name + ", 1")
	code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "], " + lReg.Name)
	code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(0) + "], " + ptrReg.Name)

	// 5. 结果三字段：{ptr, len, cap} 从 base 读
	code += utils.Format(label + "_end:")
	if result == "push" {
		code += utils.Format("push " + ln + " [" + base + "]")
		code += utils.Format("push " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "]")
		code += utils.Format("push " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "]")
	} else if strings.Contains(result, "[") {
		code += c.storeVal(stripOuterBrackets(result), ln, ln+" ["+base+"]")
		code += c.storeVal(stripOuterBrackets(result)+"+"+strconv.Itoa(lenOff), ln, ln+" ["+base+"+"+strconv.Itoa(lenOff)+"]")
		code += c.storeVal(stripOuterBrackets(result)+"+"+strconv.Itoa(capOff), ln, ln+" ["+base+"+"+strconv.Itoa(capOff)+"]")
	} else {
		code += utils.Format("mov " + result + ", " + ln + " [" + base + "]")
	}
	c.ctx.Reg.Free(aExp)
	c.ctx.Reg.Free(elem)
	return code
}

// builtinNew new(T[, v...])：堆上分配 Size(T) 字节并零填充，返回 *T；初值按字段偏移写入。
// 新对象地址压栈保存（[rsp]），不占用任何寄存器，避免覆盖调用方
// （Assign 指针字段路径 p.x = new(T) 的目标地址寄存器）与嵌套调用的活跃值。
func (c *ECompiler) builtinNew(exp *parser.Expression, call *parser.CallBlock, result string) string {
	if call.NewType == nil {
		return ""
	}
	// 列表创建：new(list[T], len[, cap])，按值返回三槽列表
	if lt, ok := call.NewType.(*typeSys.ListType); ok && lt.Elem() != nil {
		if len(call.Args) < 1 || call.Args[0] == nil || call.Args[0].Value == nil {
			return ""
		}
		lenExp := call.Args[0].Value
		capExp := lenExp
		if len(call.Args) > 1 && call.Args[1] != nil && call.Args[1].Value != nil {
			capExp = call.Args[1].Value
		}
		// build link 重定向: 查找 __slices_new，调用 slices.new[T]
		if c.ctx.LinkProviders != nil {
			if target, ok := c.ctx.LinkProviders["__slices_new"]; ok {
				return c.builtinNewViaLink(lt, target, capExp, result)
			}
		}
		return c.emitListAlloc(lt, lenExp, capExp, result)
	}
	// 字符串创建：new(string, n)，按值返回零填充 {ptr,len,cap=n}（"string 版 new([]u8, n)"）
	if _, ok := call.NewType.(*typeSys.StringType); ok {
		if len(call.Args) < 1 || call.Args[0] == nil || call.Args[0].Value == nil {
			return ""
		}
		return c.emitStringAlloc(call.Args[0].Value, result)
	}
	size := call.NewType.Size()
	if size <= 0 {
		return ""
	}
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	allocSize := align8(size)

	code := c.emitMalloc(allocSize)
	code += utils.Format("push " + c.arch.ReturnReg() + "; save new obj")

	// 零填充 allocSize 字节（含 padding）：地址从 [rsp] 装载到临时寄存器
	zreg := c.allocTmpReg()
	code += utils.Format("mov " + zreg.Name + ", " + ln + " [" + c.arch.StackPtr() + "]")
	code += utils.Format("mov " + c.arch.ReturnReg() + ", 0")
	for off := 0; off < allocSize; off += ps {
		code += utils.Format("mov " + ln + " [" + zreg.Name + "+" + strconv.Itoa(off) + "], " + c.arch.ReturnReg())
	}
	c.freeTmpReg(zreg)

	// 初值参数：按字段偏移写入（仅支持 ≤ps 的标量值）。
	// 实参已声明字段名（"new" 调用由 struct 字面量 lowering 产生），
	// 优先按名匹配的字段槽位写——new("C" 跳过 "A") 若按位置会串位：C 的值会被写到 A 槽。
	offs := make([]int, len(call.Args))
	if st, ok := call.NewType.(*typeSys.StructType); ok {
		fields := st.Fields()
		fieldsByName := make(map[string]int, len(fields))
		for j := range fields {
			fieldsByName[fields[j].Name] = fields[j].Offset
		}
		for i := 0; i < len(offs); i++ {
			if i < len(fields) {
				offs[i] = fields[i].Offset
			}
			if i < len(call.Args) && call.Args[i] != nil && call.Args[i].Name != nil {
				if off, ok := fieldsByName[call.Args[i].Name.String()]; ok {
					offs[i] = off
				}
			}
		}
	}
	for i, arg := range call.Args {
		if arg == nil || arg.Value == nil {
			continue
		}
		if i >= len(offs) {
			break
		}
		if arg.Value.Type != nil && arg.Value.Type.Size() > ps {
			// 容器/大结构体实参：按值拷贝（strings/lists = 3 槽；结构体按 Slot 拷贝）
			areg := c.allocTmpReg()
			code += utils.Format("mov " + areg.Name + ", " + ln + " [" + c.arch.StackPtr() + "]")
			code += c.loadMultiSlot(arg.Value, "["+areg.Name+"+"+strconv.Itoa(offs[i])+"]")
			c.freeTmpReg(areg)
			continue
		}
		areg := c.allocTmpReg()
		code += utils.Format("mov " + areg.Name + ", " + ln + " [" + c.arch.StackPtr() + "]")
		if arg.Value.IsConst() {
			code += utils.Format("mov " + ln + " [" + areg.Name + "+" + strconv.Itoa(offs[i]) + "], " + numLiteral(arg.Value))
			c.freeTmpReg(areg)
			continue
		}
		vreg := c.allocReg(arg.Value)
		if vreg == nil {
			vreg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		code += c.generate(arg.Value, vreg.Name)
		code += utils.Format("mov " + ln + " [" + areg.Name + "+" + strconv.Itoa(offs[i]) + "], " + matchMemWidth(ln+"[", vreg.Name))
		c.ctx.Reg.Free(arg.Value)
		c.freeTmpReg(areg)
	}

	// 返回 *T（对象地址）：从 [rsp] 装载，恢复栈
	oreg := c.allocTmpReg()
	code += utils.Format("mov " + oreg.Name + ", " + ln + " [" + c.arch.StackPtr() + "]")
	code += utils.Format("add " + c.arch.StackPtr() + ", " + strconv.Itoa(ps) + "; drop new obj")
	if result == "push" {
		code += utils.Format("push " + oreg.Name)
	} else if strings.Contains(result, "[") {
		code += c.storeVal(stripOuterBrackets(result), ln, oreg.Name)
	} else {
		code += utils.Format("mov " + result + ", " + oreg.Name)
	}
	c.freeTmpReg(oreg)
	return code
}

// builtinNewRC newRC(T)：堆上分配带 RC 头的对象，返回 *T。用于全局/cross-thread 指针。
// 与 builtinNew 相同逻辑，唯一区别：调用 emitMallocRC（分配含 RC 前缀的块）。
func (c *ECompiler) builtinNewRC(exp *parser.Expression, call *parser.CallBlock, result string) string {
	if call.NewType == nil {
		return ""
	}
	size := call.NewType.Size()
	if size <= 0 {
		return ""
	}
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	allocSize := align8(size)

	code := c.emitMallocRC(allocSize)
	code += utils.Format("push " + c.arch.ReturnReg() + "; save newRC obj")

	// 零填充 allocSize 字节（含 padding）：地址从 [rsp] 装载到临时寄存器
	zreg := c.allocTmpReg()
	code += utils.Format("mov " + zreg.Name + ", " + ln + " [" + c.arch.StackPtr() + "]")
	code += utils.Format("mov " + c.arch.ReturnReg() + ", 0")
	for off := 0; off < allocSize; off += ps {
		code += utils.Format("mov " + ln + " [" + zreg.Name + "+" + strconv.Itoa(off) + "], " + c.arch.ReturnReg())
	}
	c.freeTmpReg(zreg)

	// 初值参数：按字段偏移写入（仅支持 ≤ps 的标量值）。
	// 实参已声明字段名（"new" 调用由 struct 字面量 lowering 产生），
	// 优先按名匹配的字段槽位写——new("C" 跳过 "A") 若按位置会串位：C 的值会被写到 A 槽。
	offs := make([]int, len(call.Args))
	if st, ok := call.NewType.(*typeSys.StructType); ok {
		fields := st.Fields()
		fieldsByName := make(map[string]int, len(fields))
		for j := range fields {
			fieldsByName[fields[j].Name] = fields[j].Offset
		}
		for i := 0; i < len(offs); i++ {
			if i < len(fields) {
				offs[i] = fields[i].Offset
			}
			if i < len(call.Args) && call.Args[i] != nil && call.Args[i].Name != nil {
				if off, ok := fieldsByName[call.Args[i].Name.String()]; ok {
					offs[i] = off
				}
			}
		}
	}
	for i, arg := range call.Args {
		if arg == nil || arg.Value == nil {
			continue
		}
		if i >= len(offs) {
			break
		}
		if arg.Value.Type != nil && arg.Value.Type.Size() > ps {
			// 容器/大结构体实参：按值拷贝（strings/lists = 3 槽；结构体按 Slot 拷贝）
			areg := c.allocTmpReg()
			code += utils.Format("mov " + areg.Name + ", " + ln + " [" + c.arch.StackPtr() + "]")
			code += c.loadMultiSlot(arg.Value, "["+areg.Name+"+"+strconv.Itoa(offs[i])+"]")
			c.freeTmpReg(areg)
			continue
		}
		areg := c.allocTmpReg()
		code += utils.Format("mov " + areg.Name + ", " + ln + " [" + c.arch.StackPtr() + "]")
		if arg.Value.IsConst() {
			code += utils.Format("mov " + ln + " [" + areg.Name + "+" + strconv.Itoa(offs[i]) + "], " + numLiteral(arg.Value))
			c.freeTmpReg(areg)
			continue
		}
		vreg := c.allocReg(arg.Value)
		if vreg == nil {
			vreg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		code += c.generate(arg.Value, vreg.Name)
		code += utils.Format("mov " + ln + " [" + areg.Name + "+" + strconv.Itoa(offs[i]) + "], " + matchMemWidth(ln+"[", vreg.Name))
		c.ctx.Reg.Free(arg.Value)
		c.freeTmpReg(areg)
	}

	// 返回 *T（对象地址）：从 [rsp] 装载，恢复栈
	oreg := c.allocTmpReg()
	code += utils.Format("mov " + oreg.Name + ", " + ln + " [" + c.arch.StackPtr() + "]")
	code += utils.Format("add " + c.arch.StackPtr() + ", " + strconv.Itoa(ps) + "; drop newRC obj")
	if result == "push" {
		code += utils.Format("push " + oreg.Name)
	} else if strings.Contains(result, "[") {
		code += c.storeVal(stripOuterBrackets(result), ln, oreg.Name)
	} else {
		code += utils.Format("mov " + result + ", " + oreg.Name)
	}
	c.freeTmpReg(oreg)
	return code
}

// builtinNewViaLink 通过 build link 重定向调用 slices.new[T]：
// 编译 capExp → RDI，单态化目标函数，call + deref 返回值。
func (c *ECompiler) builtinNewViaLink(lt *typeSys.ListType, target *parser.FuncBlock,
	capExp *parser.Expression, result string) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)

	// 1. 编译 capExp → RDI（slices.new 的参数）
	var code string
	if capExp != nil {
		if capExp.IsConst() {
			code += utils.Format("mov RDI, " + strconv.Itoa(int(capExp.Num)))
		} else {
			vreg := c.allocReg(capExp)
			if vreg == nil {
				vreg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
			}
			code += c.generate(capExp, vreg.Name)
			code += utils.Format("mov RDI, " + vreg.Name)
			c.ctx.Reg.Free(capExp)
		}
	} else {
		code += utils.Format("mov RDI, 4")
	}

	// 2. 确定目标函数标签
	label := target.MangledName()

	// 3. 生成 call 指令
	code += utils.Format("call " + label)

	// 4. slices.new 返回 *[]T（指针），builtinNew 需要 []T（值）
	//    deref: 从 RAX 指向的内存读取 24 字节（ptr+len+cap）
	tmpPtr := c.allocTmpReg()
	code += utils.Format("mov " + tmpPtr.Name + ", " + c.arch.ReturnReg())
	if result == "push" {
		// S0-2（P11）：push 序查表化（cap→len→data 入栈序不变）
		_, lenOff, capOff := c.listFields()
		code += utils.Format("push " + ln + " [" + tmpPtr.Name + "]")
		code += utils.Format("push " + ln + " [" + tmpPtr.Name + "+" + strconv.Itoa(lenOff) + "]")
		code += utils.Format("push " + ln + " [" + tmpPtr.Name + "+" + strconv.Itoa(capOff) + "]")
	} else if strings.Contains(result, "[") {
		dst := stripOuterBrackets(result)
		// x86 不支持 mem-to-mem mov，用临时寄存器中转每个槽
		// S0-2（P11）：三槽偏移查表化（data/len/cap 经 listFields）
		dataOff, lenOff, capOff := c.listFields()
		tmpVal := c.allocTmpReg()
		for _, off := range []int{dataOff, lenOff, capOff} {
			code += utils.Format("mov " + tmpVal.Name + ", " + ln + " [" + tmpPtr.Name + "+" + strconv.Itoa(off) + "]")
			code += utils.Format("mov " + ln + " [" + dst + "+" + strconv.Itoa(off) + "], " + tmpVal.Name)
		}
		c.freeTmpReg(tmpVal)
	} else {
		code += utils.Format("mov " + result + ", " + ln + " [" + tmpPtr.Name + "]")
	}
	c.freeTmpReg(tmpPtr)
	return code
}

// builtinMake make([]T, len[, cap])：运行时分配并零填充
func (c *ECompiler) builtinMake(exp *parser.Expression, call *parser.CallBlock, result string) string {
	lt, ok := exp.Type.(*typeSys.ListType)
	if !ok || lt.Elem() == nil {
		return ""
	}
	// 参数：args[0] 为类型占位，args[1]=len，args[2]=cap（可选）
	if len(call.Args) < 2 || call.Args[1] == nil || call.Args[1].Value == nil {
		return ""
	}
	lenExp := call.Args[1].Value
	capExp := lenExp
	if len(call.Args) > 2 && call.Args[2] != nil && call.Args[2].Value != nil {
		capExp = call.Args[2].Value
	}
	return c.emitListAlloc(lt, lenExp, capExp, result)
}

// emitListAlloc 列表堆分配：malloc(cap*es) + 零填充 len*es + 装载三字段。
// new(list[T], len[, cap]) 与 make(list[T], _, len[, cap]) 共用。
func (c *ECompiler) emitListAlloc(lt *typeSys.ListType, lenExp, capExp *parser.Expression, result string) string {
	elemSize := lt.Elem().Size()
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	callee := c.pickCalleeSave()
	if callee == "" {
		callee = c.arch.CalleeSaveReg()
	}
	label := "make_" + strconv.Itoa(c.idx)

	// 从池里挑一个独立的 callee-save/通用临时寄存器（不与 buf=callee 和 RAX 冲突）
	pickTmp := func(avoid ...string) *regmgr.Reg {
		for _, reg := range c.ctx.Reg.Regs {
			if !reg.Free || reg.Name == c.arch.ReturnReg() {
				continue
			}
			skip := false
			for _, a := range avoid {
				if reg.Name == a {
					skip = true
					break
				}
			}
			if skip {
				continue
			}
			reg.Free = false
			return reg
		}
		return &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}
	log2ps := ps / 2
	_ = log2ps
	shift := 3
	if ps == 4 {
		shift = 2
	}

	// cap 值（常量/寄存器）→ size = align8(cap*es) → malloc
	var code string
	var capVal string
	if capExp.IsConst() {
		capV := int(capExp.Num)
		capVal = strconv.Itoa(capV)
		code += c.emitMalloc(align8(capV * elemSize))
	} else {
		capReg := c.allocReg(capExp)
		if capReg == nil {
			capReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		code += c.generate(capExp, capReg.Name)
		// 保存 cap 原值（随后的 size 计算会销毁该寄存器）
		tmpCap := pickTmp(callee, capReg.Name)
		code += utils.Format("mov " + tmpCap.Name + ", " + capReg.Name)
		// size = align8(cap*es)：(cap*es + 7) & ~7
		code += utils.Format("imul " + capReg.Name + ", " + strconv.Itoa(elemSize))
		code += utils.Format("add " + capReg.Name + ", 7")
		code += utils.Format("and " + capReg.Name + ", ~7")
		callMalloc := makeMemCall("malloc", []typeSys.Type{typeSys.GetSystemType("uint")})
		if ps == 8 {
			code += utils.Format("mov RDI, " + capReg.Name)
			code += utils.Format("call " + callMalloc.Func.MangledName())
		} else {
			code += utils.Format("push " + capReg.Name)
			code += c.arch.Call(callMalloc)
		}
		capVal = tmpCap.Name
		c.ctx.Reg.Free(capExp)
	}
	code += utils.Format("mov " + callee + ", " + c.arch.ReturnReg() + "; list buffer")

	// 零填充 len*es 字节
	code += utils.Format("mov " + c.arch.ReturnReg() + ", 0")
	var lenVal string
	if lenExp.IsConst() {
		lenV := int(lenExp.Num)
		lenVal = strconv.Itoa(lenV)
		zeros := align8(lenV * elemSize)
		for off := 0; off < zeros; off += ps {
			code += utils.Format("mov " + ln + " [" + callee + "+" + strconv.Itoa(off) + "], " + c.arch.ReturnReg())
		}
	} else {
		lReg := c.allocRegAvoid(lenExp, callee)
		if lReg == nil {
			lReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 1}
		}
		code += c.generate(lenExp, lReg.Name)
		// 保存 len 原值（零填充循环会消耗该寄存器）
		tmpLen := pickTmp(callee, lReg.Name)
		code += utils.Format("mov " + tmpLen.Name + ", " + lReg.Name)
		// 循环零填充：count = len*es/ps
		code += utils.Format("imul " + lReg.Name + ", " + strconv.Itoa(elemSize))
		code += utils.Format("shr " + lReg.Name + ", " + strconv.Itoa(shift))
		code += utils.Format("mov " + c.arch.ReturnReg() + ", " + lReg.Name)
		code += utils.Format("cmp " + c.arch.ReturnReg() + ", 0")
		code += utils.Format("je " + label + "_zero_done")
		code += utils.Format(label + "_zero_loop:")
		code += utils.Format("mov " + ln + " [" + callee + "+" + c.arch.ReturnReg() + "*" + strconv.Itoa(ps) + " - " + strconv.Itoa(ps) + "], 0")
		code += utils.Format("sub " + c.arch.ReturnReg() + ", 1")
		code += utils.Format("jnz " + label + "_zero_loop")
		code += utils.Format(label + "_zero_done:")
		lenVal = tmpLen.Name
		c.ctx.Reg.Free(lenExp)
	}

	// 装载结果三字段（len 装载：常量 lenVal 或寄存器）
	// S0-2（P11）：三字段写查表化
	if strings.Contains(result, "[") {
		base := stripOuterBrackets(result)
		_, lenOff, capOff := c.listFields()
		code += utils.Format("mov " + ln + " " + result + ", " + matchMemWidth(result, callee))
		if lenExp.IsConst() {
			code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "], " + lenVal)
		} else {
			code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "], " + matchMemWidth(ln+"[", lenVal))
		}
		code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "], " + capVal)
		return code
	}
	if result == "push" {
		code += utils.Format("push " + callee)
		if lenExp.IsConst() {
			code += utils.Format("push " + lenVal)
		} else {
			code += utils.Format("push " + lenVal)
		}
		code += utils.Format("push " + capVal)
		return code
	}
	return code + utils.Format("mov "+result+", "+callee)
}
// emitStringAlloc 生成字符串创建 new(string, n)：malloc n 字节 + 零填充 n 字节，
// 按 string 约定写出 {ptr, len=n, cap=n}。n 可以为常量或运行期值。
// 0 字节分配交给 malloc(0)（实现定义），len=cap=0，符合空串约定。
func (c *ECompiler) emitStringAlloc(lenExp *parser.Expression, result string) string {

	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	_, lenOff, capOff := c.listFields()
	callee := c.pickCalleeSave()
	if callee == "" {
		callee = c.arch.CalleeSaveReg()
	}

	pickTmp := func(avoid ...string) *regmgr.Reg {
		for _, reg := range c.ctx.Reg.Regs {
			if !reg.Free || reg.Name == c.arch.ReturnReg() {
				continue
			}
			skip := false
			for _, a := range avoid {
				if reg.Name == a {
					skip = true
					break
				}
			}
			if skip {
				continue
			}
			reg.Free = false
			return reg
		}
		return &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
	}

	var code string
	var lenVal string
	if lenExp.IsConst() {
		n := int(lenExp.Num)
		if n < 0 {
			n = 0
		}
		code += c.emitMalloc(align8(maxInt(n, 0)))
		lenVal = strconv.Itoa(n)
	} else {
		nReg := c.allocReg(lenExp)
		if nReg == nil {
			nReg = &regmgr.Reg{Name: c.arch.ReturnReg(), RegIndex: 0}
		}
		code += c.generate(lenExp, nReg.Name)
		// size = align8(n)
		tmpN := pickTmp(callee, nReg.Name)
		code += utils.Format("mov " + tmpN.Name + ", " + nReg.Name)
		code += utils.Format("add " + nReg.Name + ", 7")
		code += utils.Format("and " + nReg.Name + ", ~7")
		callMalloc := makeMemCall("malloc", []typeSys.Type{typeSys.GetSystemType("uint")})
		if ps == 8 {
			code += utils.Format("mov RDI, " + nReg.Name)
			code += utils.Format("call " + callMalloc.Func.MangledName())
		} else {
			code += utils.Format("push " + nReg.Name)
			code += c.arch.Call(callMalloc)
		}
		lenVal = tmpN.Name
		c.ctx.Reg.Free(lenExp)
	}
	code += utils.Format("mov " + callee + ", " + c.arch.ReturnReg() + "; string buffer")

	// 零填充 n 字节：rep stosb 对任意 n（含 n=0）都安全
	code += utils.Format("xor RAX, RAX")
	if lenExp.IsConst() {
		n := int(lenExp.Num)
		if n < 0 {
			n = 0
		}
		code += utils.Format("mov RCX, " + strconv.Itoa(n))
	} else {
		code += utils.Format("mov RCX, " + lenVal)
	}
	code += utils.Format("mov RDI, " + callee)
	code += utils.Format("rep stosb")

	// 装载结果三字段 {ptr, len, cap}
	if strings.Contains(result, "[") {
		base := stripOuterBrackets(result)
		code += utils.Format("mov " + ln + " " + result + ", " + matchMemWidth(result, callee))
		if lenExp.IsConst() {
			code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "], " + lenVal)
		} else {
			code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(lenOff) + "], " + matchMemWidth(ln+"[", lenVal))
		}
		code += utils.Format("mov " + ln + " [" + base + "+" + strconv.Itoa(capOff) + "], " + lenVal)
		return code
	}
	if result == "push" {
		code += utils.Format("push " + callee)
		code += utils.Format("push " + lenVal)
		code += utils.Format("push " + lenVal)
		return code
	}
	return code + utils.Format("mov "+result+", "+callee)
}

// ZeroVar 无初值容器的三槽清零（供 varDecl 调用）
func (c *ECompiler) ZeroVar(v *parser.VarBlock) string {
	if v == nil || v.Type == nil {
		return ""
	}
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)
	addr := stripOuterBrackets(c.arch.VarAddr(v))
	// winner 容器（string/list）：零值三槽 {ptr=0, len=0, cap=0}
	if isListLike(v.Type) {
		_, lenOff, capOff := c.listFields()
		code := utils.Format("mov " + ln + " [" + addr + "], 0")
		code += utils.Format("mov " + ln + " [" + addr + "+" + strconv.Itoa(lenOff) + "], 0")
		code += utils.Format("mov " + ln + " [" + addr + "+" + strconv.Itoa(capOff) + "], 0")
		return code + utils.Format("; 零值容器 "+v.Name.String())
	}
	// 结构体 / 指针 / 接口零值：整槽清零（fixplan 铁律方向=多初始化）。
	// 无初值 var 若不清零，方法体 via this 读到陈旧栈字节（struct 语料 zeroDist=68 实证）。
	_, isStruct := v.Type.(*typeSys.StructType)
	_, isIface := v.Type.(*typeSys.InterfaceType)
	_, isMap := v.Type.(*typeSys.MapType)
	_, isArray := v.Type.(*typeSys.ArrayType)
	if isStruct || isIface || isMap || isArray || v.Type.IsPointer() {
		code := ""
		size := v.Type.Size()
		if size <= 0 {
			size = ps
		}
		for off := 0; off < size; {
			remain := size - off
			switch {
			case remain >= ps:
				code += utils.Format("mov " + ln + " [" + addr + "+" + strconv.Itoa(off) + "], 0")
				off += ps
			case remain >= 4:
				code += utils.Format("mov DWORD [" + addr + "+" + strconv.Itoa(off) + "], 0")
				off += 4
			case remain >= 2:
				code += utils.Format("mov WORD [" + addr + "+" + strconv.Itoa(off) + "], 0")
				off += 2
			default:
				code += utils.Format("mov BYTE [" + addr + "+" + strconv.Itoa(off) + "], 0")
				off++
			}
		}
		return code + utils.Format("; 零值结构体 "+v.Name.String())
	}
	return ""
}

// BoxInterface generates code to box a concrete value into an interface value.
// Interface value = {vtable_ptr, data_ptr} on the stack (2 * pointerSize bytes).
func (c *ECompiler) BoxInterface(varBlock *parser.VarBlock) string {
	if varBlock == nil || varBlock.Value == nil || varBlock.Value.Type == nil {
		return ""
	}

	ifaceType, ok := varBlock.Type.(*typeSys.InterfaceType)
	if !ok {
		return ""
	}
	concreteType := varBlock.Value.Type
	ps := c.arch.PointerSize()
	dq := "QWORD"
	if ps == 4 {
		dq = "DWORD"
	}

	var code string

	// 1. Allocate heap for the concrete value
	concreteSize := concreteType.Size()
	code += c.emitMalloc(concreteSize)
	// RAX now holds the allocated data pointer

	// 2. Save data pointer
	callee := c.pickCalleeSave()
	if callee == "" {
		callee = c.arch.CalleeSaveReg()
	}
	code += utils.Format("mov " + callee + ", " + c.arch.ReturnReg() + "; save data_ptr")

	// 3. Copy concrete value to allocated memory
	var srcAddr string
	if varBlock.Value.Var != nil {
		srcAddr = stripOuterBrackets(c.arch.VarAddr(varBlock.Value.Var))
	} else {
		// Fallback: compile value to temp and store
		tmpReg := c.allocTmpReg()
		code += c.generate(varBlock.Value, tmpReg.Name)
		srcAddr = tmpReg.Name
		defer c.freeTmpReg(tmpReg)
	}
	// Use copySlots for multi-slot struct copy
	code += c.copySlots(callee, srcAddr, concreteSize)

	// 4. Store data_ptr in interface value (second slot)
	ifaceAddr := stripOuterBrackets(c.arch.VarAddr(varBlock))
	code += utils.Format("mov " + dq + " [" + ifaceAddr + "+" + strconv.Itoa(ps) + "], " + callee)

	// 5. Look up or register vtable and store vtable_ptr (first slot)
	vtableLabel := c.ctx.LookupVtable(concreteType, ifaceType)
	if vtableLabel == "" {
		// Build method labels from interface methods
		methodLabels := make([]string, len(ifaceType.InterfaceMethods))
		for i, m := range ifaceType.InterfaceMethods {
			// Find the concrete method FuncBlock to get the real arg count (includes self)
			argCount := 0
			var concreteFunc *parser.FuncBlock
			if concreteType != nil {
				for _, cm := range concreteType.Methods() {
					if fb, ok := cm.(*parser.FuncBlock); ok {
						if fb.Name.Last() == m.Name {
							argCount = len(fb.Args)
							concreteFunc = fb
							break
						}
					}
				}
			}
			if st, ok := concreteType.(*typeSys.StructType); ok {
				methodLabels[i] = st.TypeName + "_" + m.Name + Itoa(argCount)
			} else {
				methodLabels[i] = concreteType.Type() + "_" + m.Name + Itoa(argCount)
			}
			// Mark the concrete method as useful so it gets compiled
			if concreteFunc != nil {
				concreteFunc.Useful = true
			}
		}
		vtableLabel = c.ctx.RegisterVtable(concreteType, ifaceType, methodLabels)
	}

	// Load vtable address and store to first slot
	vreg := c.allocTmpReg()
	code += utils.Format("lea " + vreg.Name + ", [" + vtableLabel + "]")
	code += utils.Format("mov " + dq + " [" + ifaceAddr + "], " + vreg.Name)
	c.freeTmpReg(vreg)

	code += utils.Format("; box " + concreteType.Type() + " → " + ifaceType.Type())
	return code
}

// Itoa is a convenience wrapper for strconv.Itoa.
func Itoa(n int) string {
	return strconv.Itoa(n)
}

// isOwning 类型是否携带堆缓冲（string/list/结构体指针 *T 视为拥有指针载体）
func isOwning(t typeSys.Type) bool {
	if t == nil {
		return false
	}
	k := t.Kind()
	if k == "string" || k == "list" {
		return true
	}
	if t.IsPointer() {
		return true
	}
	return false
}

// ============================== 闭包 ==============================
// 闭包对象布局：{code@0, env@ptrSize}。code 是匿名函数标签；
// env 是宿主帧的 __env 指针（零捕获时 env=0，RBX 不被闭包读取）。
// 闭包调用约定见 arch/x86_64/linux_sysv.go 与 x86/cdecl.go 的 isIndirect 分支。

// closureObjType 合成闭包对象类型 {code ptr, env *envSt}。
// envSt 为空时 env 字段退化为系统 ptr。
func closureObjType(envType *typeSys.StructType) *typeSys.StructType {
	ptr := typeSys.GetSystemType("ptr")
	envT := typeSys.Type(ptr)
	if envType != nil {
		envT = typeSys.MakePointer(envType)
	}
	st := &typeSys.StructType{RType: typeSys.RType{TypeName: "closureObj"}}
	st.StructFields = []*typeSys.StructField{
		{Name: "code", Type: ptr, Access: typeSys.AccessPublic},
		{Name: "env", Type: envT, Access: typeSys.AccessPublic},
	}
	st.Layout()
	return st
}

// EmitClosureObjectFor 供 arch 包 VarDecl 调用：堆分配 {code, env}（envVar 可空）。
func (c *ECompiler) EmitClosureObjectFor(fb *parser.FuncBlock, envVar *parser.VarBlock, outReg string) string {
	return c.emitClosureObject(fb, envVar, outReg)
}

// genClosureAnon 生成匿名函数字面量的闭包对象创建代码。
func (c *ECompiler) genClosureAnon(exp *parser.Expression, result string) string {
	fb := exp.Anon
	var envVar *parser.VarBlock
	if fb != nil && fb.Env != nil {
		envVar = fb.Env
	}
	code := c.emitClosureObject(fb, envVar, c.arch.ReturnReg())
	objReg := c.arch.ReturnReg()
	if result == "push" {
		code += utils.Format("push " + objReg)
		return code
	}
	if result != "" {
		code += utils.Format("mov " + result + ", " + objReg)
	}
	return code
}

// emitClosureObject 分配闭包对象 {code, env}（堆分配）。
// envVar 非空时把它的当前值写进 env 槽；否则写 0。产出对象指针于返回寄存器。
func (c *ECompiler) emitClosureObject(fb *parser.FuncBlock, envVar *parser.VarBlock, outReg string) string {
	ps := c.arch.PointerSize()
	ln := c.arch.LengthName(ps)

	var envType *typeSys.StructType
	if envVar != nil && envVar.Type != nil && envVar.Type.IsPointer() {
		if elem, ok := envVar.Type.Elem().(*typeSys.StructType); ok {
			envType = elem
		}
	}
	objType := closureObjType(envType)

	call := &parser.CallBlock{Name: parser.NewName("new"), NewType: objType}
	inner := &parser.Expression{Call: call, Type: typeSys.MakePointer(objType)}
	code := c.generate(inner, outReg)

	code += utils.Format("mov " + ln + " [" + outReg + "], " + formatFuncLabel(fb) + "; 闭包代码指针")

	envReg := c.allocTmpReg()
	if envVar != nil {
		envAddr := stripOuterBrackets(c.arch.VarAddr(envVar))
		code += utils.Format("mov " + envReg.Name + ", " + ln + " [" + envAddr + "]")
	} else {
		code += utils.Format("mov " + envReg.Name + ", 0")
	}
	code += utils.Format("mov " + ln + " [" + outReg + "+" + strconv.Itoa(ps) + "], " + envReg.Name)
	c.freeTmpReg(envReg)
	return code
}

// formatFuncLabel 闭包标签名（匿名函数直接以名字调用自己）。
func formatFuncLabel(fb *parser.FuncBlock) string {
	if fb == nil {
		return "0"
	}
	return fb.MangledName()
}
