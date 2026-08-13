package x86

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strconv"
	"strings"
)

// Cdecl 实现 x86 cdecl 调用约定（全部压栈，调用者清理）。
type Cdecl struct {
	ctx *context.Context
}

func NewCdecl(ctx *context.Context) *Cdecl {
	a := &Cdecl{
		ctx: ctx,
	}
	ctx.Reg = regmgr.NewRegMgr(regs, a.GenVarAddr)
	return a
}

func (a *Cdecl) Info() (code string) { return "x86 cdecl" }

func (a *Cdecl) Call(call *parser.CallBlock) (code string) {
	if call == nil || call.Func == nil {
		return ""
	}

	if call.ThisVar != nil && call.ThisVar.Type != nil &&
		call.ThisVar.Type.Kind() == "list" && len(call.Args) == 0 {
		methodName := call.Name.Last()
		var fieldOffset int
		switch methodName {
		case "len":
			fieldOffset = 4
		case "cap":
			fieldOffset = 8
		case "ptr":
			fieldOffset = 0
		default:
			goto normalCall
		}
		addr := listFieldAddr(a.call.ThisVar, fieldOffset)
		code += utils.Format("mov eax, dword " + addr + "; " + methodName + "()")
		return
	}

normalCall:
	fn := call.Func

	savedRegs := a.ctx.Reg.SaveAll(false)
	for _, regCode := range savedRegs {
		code += regCode
	}

	// cdecl 约定：参数从右向左压栈
	// 1. 先压普通参数（从右向左）
	for i := len(call.Args) - 1; i >= 0; i-- {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		if arg.Value != nil && is64Type(arg.Value.Type) {
			code += a.Exp(arg.Value, "push", "参数"+strconv.Itoa(i))
		} else {
			code += a.Exp(arg.Value, "push", "参数"+strconv.Itoa(i))
		}
	}

	// 2. 最后压 this 指针（如果有）
	if call.ThisVar != nil {
		thisAddr := genVarAddr(a.call.ThisVar)
		code += utils.Format("push " + thisAddr + "; push this pointer")
	}

	name := fn.Name.String()
	if name != "main" {
		name = name + strconv.Itoa(len(fn.Args))
	}
	code += utils.Format("call " + name)

	argSize := arch.CalcArgsSize(call.Func)
	if call.ThisVar != nil {
		argSize += 4
	}
	if argSize > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(argSize) + "; 清理参数栈(cdecl)")
	}

	return code
}

func (a *Cdecl) Return(ret *parser.ReturnBlock) (code string) {
	if ret != nil && len(ret.Value) != 0 {
		if is64Type(ret.Value[0].Type) {
			code += a.Exp(ret.Value[0], "EDX:EAX", "return值存入EDX:EAX")
			a.ctx.Reg.Free(ret.Value[0])
		} else {
			eaxReg := &regmgr.Reg{Name: "EAX", RegIndex: 0}
			a.ctx.Reg.Force(eaxReg, ret.Value[0])

			if eaxReg.StoreCode != "" {
				code += utils.Format(eaxReg.StoreCode)
			}

			code += a.Exp(ret.Value[0], "EAX", "return值存入EAX")
			a.ctx.Reg.Free(ret.Value[0])
		}
	}

	// 跳转到函数末尾的公共 epilogue
	name := a.ctx.CurrentFunc.Name.NASM()
	if name != "main" {
		name = name + strconv.Itoa(len(a.ctx.CurrentFunc.Args))
	}
	code += utils.Format("jmp func_end_" + name)
	return code
}

func (a *Cdecl) Func(funcBlock *parser.FuncBlock) (code string) {
	if funcBlock == nil {
		return ""
	}

	argOffset := 8
	if funcBlock.Class != nil {
		argOffset += 4
	}

	for i := 0; i < len(funcBlock.Args); i++ {
		arg := funcBlock.Args[i]
		arg.Offset = argOffset
		argOffset += arg.Type.Size()
	}

	code += utils.Format("push ebp; 保存调用者的栈帧基址")
	code += utils.Format("mov ebp, esp; 设置当前栈帧基址")

	csCount := 0
	for i := 0; i < len(regs); i++ {
		r := regs[i]
		if r.CalleeSave {
			code += utils.Format("push " + r.Name + "; 保存" + r.Name)
			csCount++
		}
	}

	a.ctx.StackSize = arch.SetupVarOffsets(a.ctx.Now, a.ctx.StackAlignment, -4*csCount)

	if a.ctx.StackSize > 0 {
		code += utils.Format("sub esp, " + strconv.Itoa(a.ctx.StackSize) + "; 分配栈空间(" + strconv.Itoa(a.ctx.StackSize) + "字节)")
	}

	code += utils.Format("; ---- 函数开始 ----")
	return code
}

func (a *Cdecl) Exp(exp *parser.Expression, result, desc string) (code string) {
	expc := NewExpCom(a.ctx)
	return expc.CompileExpr(exp, result, desc)
}

func (a *Cdecl) For(forBlock *parser.ForBlock) (code string) {
	if forBlock == nil {
		return ""
	}

	// 使用 ForCount 而不是 IfCount 来避免标签冲突
	forBlock.Offset = a.ctx.ForCount
	a.ctx.ForCount++
	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	forEndLabel := forLabel + "_end"

	code += utils.Format("")
	code += utils.Format("")

	// 1. 初始化 - 编译变量定义
	if forBlock.Init != nil {
		// 检查初始化表达式的类型
		if forBlock.Init.Call != nil {
			// 函数调用
			code += a.Call(forBlock.Init.Call)
		} else if forBlock.Init.Var != nil {
			// 变量赋值
			code += a.Var(forBlock.Init.Var)
		} else {
			// 普通表达式
			code += a.Exp(forBlock.Init, "", "初始化for循环")
		}
	}

	code += utils.Format("")
	code += utils.Format("")

	// 循环开始标签
	code += utils.Format(forLabel + ": ; for循环开始")

	// 2. 条件检查 - 如果条件为假则跳出循环
	if forBlock.Condition != nil && !forBlock.Condition.Bool {
		// 将条件编译到一个临时寄存器
		code += a.compileForCondition(forBlock.Condition, forEndLabel)
	}

	code += utils.Format("")
	code += utils.Format("")

	return code
}

// compileForCondition 编译 for 循环条件表达式
func (a *Cdecl) compileForCondition(cond *parser.Expression, jumpLabel string) string {
	if cond == nil {
		return ""
	}

	var code string

	// 处理比较运算
	if cond.Separator == "==" || cond.Separator == "!=" ||
		cond.Separator == "<" || cond.Separator == ">" ||
		cond.Separator == "<=" || cond.Separator == ">=" {

		// 编译左右操作数到寄存器
		if cond.Left != nil {
			code += a.Exp(a.cond.Left, "EAX", "left operand")
		}
		if cond.Right != nil {
			code += a.Exp(a.cond.Right, "ECX", "right operand")
		}

		// 生成比较指令
		code += utils.Format("cmp EAX, ECX")

		// 根据操作符生成跳转指令（for 循环条件为假时跳转）
		var jumpOp string
		switch cond.Separator {
		case "==":
			jumpOp = "jne" // 不相等则跳出
		case "!=":
			jumpOp = "je" // 相等则跳出
		case "<":
			jumpOp = "jge" // 大于等于则跳出
		case ">":
			jumpOp = "jle" // 小于等于则跳出
		case "<=":
			jumpOp = "jg" // 大于则跳出
		case ">=":
			jumpOp = "jl" // 小于则跳出
		}
		code += utils.Format(jumpOp + " " + jumpLabel)
	} else {
		// 单个表达式，编译到 EAX 并测试是否为 0
		code += a.Exp(a.cond, "EAX", "condition")
		code += utils.Format("test EAX, EAX")
		code += utils.Format("jz " + jumpLabel) // 为 0 则跳出
	}

	return code
}

func (a *Cdecl) EndFor(forBlock *parser.ForBlock) (code string) {
	code += utils.Format("")
	code += utils.Format("")

	forLabel := "for_" + strconv.Itoa(forBlock.Offset)
	// 检查增量表达式的类型
	if forBlock.Increment != nil {
		if forBlock.Increment.Call != nil {
			// 函数调用
			code += a.Call(forBlock.Increment.Call)
		} else if forBlock.Increment.Var != nil {
			// 变量赋值
			code += a.Var(forBlock.Increment.Var)
		} else {
			// 普通表达式
			code += a.Exp(forBlock.Increment, "", "for循环增量")
		}
	}
	code += utils.Format("jmp " + forLabel + "; for循环")
	code += utils.Format(forLabel + "_end: ; for循环结束")
	return
}

func (a *Cdecl) Var(varBlock *parser.VarBlock) (code string) {
	if varBlock.Value == nil {
		return
	}
	// 检查是否是列表索引访问
	if isListIndexAccess(varBlock) {
		return a.compileListIndexSet(varBlock)
	}
	if is64Type(varBlock.Type) {
		loAddr := genLoAddr(a.varBlock)
		hiAddr := genHiAddr(a.varBlock)
		code += a.Exp(varBlock.Value, loAddr, "设置变量"+varBlock.Name.String())
		if !isRegName(loAddr) {
			code += utils.Format("mov dword " + hiAddr + ", edx; 设置变量high")
		}
		return
	}
	addr := genVarAddr(a.varBlock)
	code += a.ctx.Arch.Exp(varBlock.Value, addr, "设置变量"+varBlock.Name.String())
	return
}

// isListIndexAccess 检查是否是列表索引访问（如 a[0] = x, a[1] = x）
func isListIndexAccess(v *parser.VarBlock) bool {
	if v.Define.Type != parser.FindTypeItem {
		return false
	}
	// 检查名称路径中是否有索引表达式（Slice）
	for i := 1; i < len(v.Name); i++ {
		if v.Name[i].Slice != nil && v.Name[i].Slice.Start != nil && v.Name[i].Slice.End == nil {
			// 有索引表达式，且不是切片（End == nil）
			return true
		}
	}
	return false
}

// compileListIndexSet 编译列表索引赋值，如 a[1] = 10
func (a *Cdecl) compileListIndexSet(varBlock *parser.VarBlock) (code string) {
	if varBlock.Value == nil {
		return ""
	}

	// 获取列表变量的 VarBlock
	if len(varBlock.Define.Path) == 0 {
		return ""
	}
	listVar, ok := varBlock.Define.Path[0].(*parser.VarBlock)
	if !ok {
		return ""
	}

	// 获取列表类型
	listType := listVar.Type
	if listType == nil {
		return ""
	}
	if listType.IsPointer() {
		listType = listType.Elem()
	}
	lt, ok := listType.(*typeSys.ListType)
	if !ok {
		return ""
	}
	elemSize := lt.Elem().Size()

	// 获取列表变量的基地址
	listAddr := genVarAddr(a.listVar)
	// listAddr 格式如 "DWORD[ebp-16]"
	// 提取地址部分
	addrStart := strings.Index(listAddr, "[")
	if addrStart == -1 {
		return ""
	}
	addrPart := listAddr[addrStart:] // "[ebp-16]"

	// 读取 ptr 字段到寄存器
	reg := a.ctx.Reg.Get(a.ctx.Now, varBlock.Value, ClassGPR, false)
	sp := a.SizePrefix()
	code += utils.Format("mov " + reg.Name + ", " + sp + " " + addrPart + "; load list ptr")

	// 计算索引偏移
	for i := 1; i < len(varBlock.Name); i++ {
		namePart := varBlock.Name[i]
		if namePart.Slice != nil && namePart.Slice.Start != nil && namePart.Slice.End == nil {
			// 索引表达式
			idxExpr := namePart.Slice.Start
			if idxExpr.IsConst() && typeSys.CheckKind(idxExpr.Type, "int", "uint") {
				// 常量索引
				offset := int(idxExpr.Num) * elemSize
				if offset > 0 {
					code += utils.Format("add " + reg.Name + ", " + strconv.Itoa(offset) + "; add index offset")
				}
			} else {
				// 非常量索引，需要编译索引表达式
				idxReg := a.ctx.Reg.Get(a.ctx.Now, idxExpr, ClassGPR, false)
				idxCode := a.ctx.Arch.Exp(a.idxExpr, idxReg.Name, "index")
				code += idxCode
				code += utils.Format("imul " + idxReg.Name + ", " + idxReg.Name + ", " + strconv.Itoa(elemSize) + "; multiply by elem size")
				code += utils.Format("add " + reg.Name + ", " + idxReg.Name + "; add index offset")
				a.ctx.Reg.Free(idxExpr)
			}
		}
	}

	// 编译值并存储
	code += a.ctx.Arch.Exp(a.varBlock.Value, "["+reg.Name+"]", "set list element")
	a.ctx.Reg.Free(varBlock.Value)

	return code
}

func (a *Cdecl) GenVarAddr(varBlock *parser.VarBlock) (addr string) {
	// 检查是否是列表索引访问
	if isListIndexAccess(varBlock) {
		return a.genListIndexAddr(varBlock)
	}
	return genVarAddr(a.varBlock)
}

// genListIndexAddr 生成列表索引访问的地址代码
// 返回格式：先加载 ptr 到寄存器，然后返回寄存器名
func (a *Cdecl) genListIndexAddr(varBlock *parser.VarBlock) string {
	// 获取列表变量的 VarBlock
	if len(varBlock.Define.Path) == 0 {
		return ""
	}
	listVar, ok := varBlock.Define.Path[0].(*parser.VarBlock)
	if !ok {
		return ""
	}

	// 获取列表类型
	listType := listVar.Type
	if listType == nil {
		return ""
	}
	if listType.IsPointer() {
		listType = listType.Elem()
	}
	lt, ok := listType.(*typeSys.ListType)
	if !ok {
		return ""
	}
	elemSize := lt.Elem().Size()

	// 获取列表变量的基地址
	listAddr := genVarAddr(a.listVar)
	addrStart := strings.Index(listAddr, "[")
	if addrStart == -1 {
		return ""
	}
	addrPart := listAddr[addrStart:]

	// 生成代码：读取 ptr 字段 + 索引偏移
	reg := a.ctx.Reg.Get(a.ctx.Now, varBlock.Value, ClassGPR, false)
	sp := a.SizePrefix()
	code := utils.Format("mov " + reg.Name + ", " + sp + " " + addrPart + "; load list ptr")

	// 计算索引偏移
	for i := 1; i < len(varBlock.Name); i++ {
		namePart := varBlock.Name[i]
		if namePart.Slice != nil && namePart.Slice.Start != nil && namePart.Slice.End == nil {
			idxExpr := namePart.Slice.Start
			if idxExpr.IsConst() && typeSys.CheckKind(idxExpr.Type, "int", "uint") {
				offset := int(idxExpr.Num) * elemSize
				if offset > 0 {
					code += utils.Format("add " + reg.Name + ", " + strconv.Itoa(offset) + "; add index offset")
				}
			} else {
				// 非常量索引
				idxReg := a.ctx.Reg.Get(a.ctx.Now, idxExpr, ClassGPR, false)
				idxCode := a.ctx.Arch.Exp(a.idxExpr, idxReg.Name, "index")
				code += idxCode
				code += utils.Format("imul " + idxReg.Name + ", " + idxReg.Name + ", " + strconv.Itoa(elemSize))
				code += utils.Format("add " + reg.Name + ", " + idxReg.Name)
				a.ctx.Reg.Free(idxExpr)
			}
		}
	}

	// 将代码存储到 reg.StoreCode 中
	reg.StoreCode = code
	return reg.Name
}

// ---- Arch 接口：寄存器信息 ----

func (a *Cdecl) CalleeSaveReg() string         { return "EBX" }
func (a *Cdecl) ReturnReg() string             { return "EAX" }
func (a *Cdecl) HiReg() string                 { return "EDX" }
func (a *Cdecl) IsCalleeSave(name string) bool { return name == "EBX" }
func (a *Cdecl) DefaultRegMask() uint32        { return ClassGPR }

// ---- Arch 接口：大小/前缀 ----

func (a *Cdecl) PointerSize() int         { return 4 }
func (a *Cdecl) SizePrefix() string       { return "DWORD" }
func (a *Cdecl) LengthName(sz int) string { return GetLengthName(sz) }

// ---- Arch 接口：地址 ----

func (a *Cdecl) FormatAddr(offset int) string {
	if offset < 0 {
		return "[ebp" + strconv.Itoa(offset) + "]"
	} else if offset == 0 {
		return "[ebp]"
	}
	return "[ebp+" + strconv.Itoa(offset) + "]"
}

func (a *Cdecl) ExtractOffset(addr string) (int, bool) {
	return extractEbpOffset(addr)
}

// ---- Arch 接口：指令 ----

func (a *Cdecl) EmitDiv(regName, src string) string {
	return utils.Format("div " + src + "; " + regName + " / " + src)
}

func (a *Cdecl) EmitMod(regName, src string) string {
	return utils.Format("div " + src + "; " + regName + " % " + src)
}

func (a *Cdecl) EmitDivWithCallee(regName, src string) string {
	return utils.Format("idiv " + src + "; " + regName + " / " + src)
}

func (a *Cdecl) EmitModWithCallee(regName, src string) string {
	return utils.Format("idiv " + src + "; " + regName + " % " + src)
}

func (a *Cdecl) EmitCmpJump(op, result string) string {
	return utils.Format("j" + op + " " + result + "; cmp jump " + op)
}

// ---- Arch 接口：64 位类型 ----

func (a *Cdecl) Is64Type(t typeSys.Type) bool {
	if t == nil {
		return false
	}
	return t.Size() == 8 && (t.Type() == "i64" || t.Type() == "u64" || t.Type() == "f64")
}

func (a *Cdecl) Compile64Type(e *parser.Expression, result, desc string) string {
	return compile64Type(a.e, result, desc)
}

// ---- Arch 接口：寄存器绑定 ----

func (a *Cdecl) NeedBindMask(op string) uint32 {
	switch op {
	case "/", "%":
		return ClassDiv // 除法/取模需要 EAX/EDX
	default:
		return 0
	}
}

func (a *Cdecl) NeedBindRegs(op string) []*regmgr.Reg {
	switch op {
	case "/", "%":
		return []*regmgr.Reg{
			{Name: "EAX", RegIndex: 0, ClassMask: ClassDiv},
			{Name: "EDX", RegIndex: 3, ClassMask: ClassDiv},
		}
	default:
		return nil
	}
}

func (a *Cdecl) NeedRegClass(bt typeSys.BackendType) uint32 {
	return ClassGPR // x86 所有类型都用通用寄存器
}
