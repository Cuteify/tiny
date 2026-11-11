package parser

import (
	typeSys "cuteify/type"
	"fmt"
	"os"

	"strings"
)

// isTypeParam 判断类型是否为泛型类型参数（T），单态化前没有具体 Kind/Size。
func isTypeParam(t typeSys.Type) bool {
	_, ok := t.(*typeSys.TypeParam)
	return ok
}

// isPtrLike 判断是否为地址语义类型：系统 ptr 或任意 *T。
func isPtrLike(t typeSys.Type) bool {
	if t == nil {
		return false
	}
	return t.IsPointer() || t.Type() == "ptr"
}

// isAssignSeparator 判断是否为赋值类运算符。
func isAssignSeparator(sep string) bool {
	switch sep {
	case "=", ":=", "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>=":
		return true
	}
	return false
}

// isBuiltinIndexKind 判断类型是否由编译器内建索引/切片路径处理。
func isBuiltinIndexKind(t typeSys.Type) bool {
	if t == nil {
		return false
	}
	// *[]T：codegen 的 indexAccess/indexSet 会先解引用指针再按 list 处理，
	// Check 必须与 codegen 保持同一种归类，不能把 *[]T 当自定义类型去
	// lower 成 get/set（ListType 没有方法表）。
	if t.IsPointer() {
		if elem := t.Elem(); elem != nil && elem.Kind() == "list" {
			return true
		}
	}
	switch t.Kind() {
	case "list", "string", "array", "map":
		return true
	}
	return false
}

// builtinIndexTarget 返回内建索引/切片语义所针对的容器类型。
// *[]T 解引用为 []T（与 codegen 的 indexAccess/indexSet 一致）。
func builtinIndexTarget(t typeSys.Type) typeSys.Type {
	if t != nil && t.IsPointer() {
		if elem := t.Elem(); elem != nil && elem.Kind() == "list" {
			return elem
		}
	}
	return t
}

// intLiteral 构造 int 字面量表达式（供切片缺省边界使用）。
func intLiteral(v int) *Expression {
	return &Expression{Num: float64(v), Type: typeSys.GetSystemType("int")}
}

// lowerMethodCall 把当前表达式改写成接收者上的方法调用。
// receiver 必须是左值（VarBlock）；args 是除接收者外的实参。
// 找不到候选时返回 false，由调用方决定是否报错。
func (exp *Expression) lowerMethodCall(p *Parser, receiver *Expression, method string, args []*Expression) bool {
	if receiver == nil || receiver.Type == nil {
		return false
	}
	if receiver.Var == nil {
		p.Error.MissError("Type Error", p.Lexer.Cursor,
			"operator receiver of type "+receiver.Type.Type()+" must be an lvalue")
		return false
	}
	candidates := methodCandidates(receiver.Type, method)
	if len(candidates) == 0 {
		return false
	}
	call := &CallBlock{
		Name: NewName(receiver.Type.Type(), method),
		Args: make([]*ArgBlock, 0, len(args)+1),
	}
	// 接收者作为第一个参数显式传入（新 ABI：编译器自动传入第一个参数）。
	call.Args = append(call.Args, &ArgBlock{Value: receiver, Name: NewName("_receiver"), Type: receiver.Type})
	for _, arg := range args {
		call.Args = append(call.Args, &ArgBlock{Value: arg, Type: arg.Type})
	}
	sel, _, ambiguous := selectCallCandidate(call, candidates)
	if sel == nil {
		if ambiguous {
			p.Error.MissError("Call Error", p.Lexer.Cursor,
				"ambiguous operator method "+receiver.Type.Type()+"."+method)
		}
		return false
	}
	applyReceiverConversion(call, sel, receiver)
	call.Func = sel
	sel.Useful = true
	if !call.Check(p) {
		return false
	}
	// 改写成普通调用表达式：generate 先按 Separator 分派，必须清空索引形状。
	exp.Call = call
	exp.Separator = ""
	exp.Left = nil
	exp.Right = nil
	exp.Var = nil
	exp.Index = [3]*Expression{}
	exp.IndexSlice = false
	exp.Type = nil
	if len(sel.Return) > 0 {
		exp.Type = sel.Return[0]
	}
	return true
}

// Check 表达式语义检查入口：类型推导 + 常量折叠。
// 按优先级分发：变量引用 → 函数调用 → 运算符检查 → 常量。
func (exp *Expression) Check(p *Parser) bool {
	if exp.checked {
		return true
	}

	if exp.Var != nil {
		if !exp.checkVar(p) {
			return false
		}
	} else if exp.Call != nil {
		if !exp.checkCall(p) {
			return false
		}
	} else if exp.Separator != "" {
		if !exp.checkOp(p) {
			return false
		}
	}

	exp.checked = true
	return true
}

// checkVar 解析变量引用类型。通过 Var.ParseDefine 查找定义并复制 Type/Offset。
func (exp *Expression) checkVar(p *Parser) bool {
	if exp.Var == nil {
		return true
	}

	exp.Var.ParseDefine(p)

	if exp.Var.Type != nil {
		exp.Type = exp.Var.Type
		return true
	}

	// 同包跨文件/跨包定义在 parse 期不可见（parse 期只解析当前文件），
	// 此处静默返回，由合并后的 rootNode.Check() 统一重试与报错。
	return false
}

// checkCall 检查函数调用并设置返回类型。
func (exp *Expression) checkCall(p *Parser) bool {
	if !exp.Call.Check(p) {
		return false
	}

	if exp.Call.Func != nil {
		if nret := len(exp.Call.Func.Return); nret == 1 || (nret > 1 && exp.stmt) {
			exp.Type = exp.Call.Func.Return[0]
			// 泛型调用：把返回类型中的类型参数换成显式类型实参或实参推断出的具体类型
			if subst := exp.Call.typeSubst(); len(subst) > 0 {
				if ret := typeSys.SubstituteTypeParams(exp.Type, subst); ret != nil {
					exp.Type = ret
				}
			}
			return true
		}
		// 语句位置的 void 调用（slices.push[T](...) / slices.set[T](...) 等）：
		// 经 ParseExp 走表达式路径，本身没有返回值是合法的，Type 留空即可。
		if len(exp.Call.Func.Return) == 0 && exp.stmt {
			exp.Type = nil
			return true
		}
		p.Error.MissError("Type Error", p.Lexer.Cursor, "function call must return one value")
		return false
	}

	return false
}

// checkOp 运算符类型检查 + 常量折叠分发器。
func (exp *Expression) checkOp(p *Parser) bool {
	if envChk := os.Getenv("CUTE_DEBUG_CHK"); envChk != "" {
		rInfo := ""
		if exp.Right != nil {
			rInfo = " rsep=" + exp.Right.Separator + " rcall=" + fmt.Sprint(exp.Right.Call != nil)
			if exp.Right.Call != nil {
				rInfo += " rname=" + exp.Right.Call.Name.String()
			}
		}
		fmt.Fprintf(os.Stderr, "CHKOP sep=%s stmt=%v l=%v r=%v%s\n", exp.Separator, exp.stmt, exp.Left != nil, exp.Right != nil, rInfo)
	}

	// 空运算符，直接通过
	if exp.Separator == "" {
		return true
	}

	switch exp.Separator {
	case "list_lit", "array_lit":
		return exp.checkListLiteral(p)
	case "map_lit":
		return exp.checkMapLiteral(p)
	case "!", "~":
		return exp.checkUnary(p)
	case "*", "&":
		if exp.Left == nil {
			return exp.checkUnary(p)
		}
	case "-":
		if exp.Left == nil {
			return exp.checkUnary(p)
		}
	}

	// 递归检查子节点。
	// 赋值表达式的 LHS 是索引时不能在这里 Check：checkIndex 会把 v[i] 提前
	// lower 成 get 调用，checkAssign/checkIndexAssign 就看不到原始索引形状了。
	// 由 checkIndexAssign 自己检查接收者与索引表达式，再决定内建 []= 或 set。
	skipLeft := isAssignSeparator(exp.Separator) && exp.Left != nil && exp.Left.Separator == "[]"
	if exp.Left != nil && !skipLeft {
		if !exp.Left.Check(p) {
			if os.Getenv("CUTE_DEBUG_CHK") != "" {
				fmt.Fprintf(os.Stderr, "CHKOP RET-L sep=%s\n", exp.Separator)
			}
			return false
		}
	}
	if exp.Right != nil {
		if !exp.Right.Check(p) {
			if os.Getenv("CUTE_DEBUG_CHK") != "" {
				fmt.Fprintf(os.Stderr, "CHKOP RET-R sep=%s\n", exp.Separator)
			}
			return false
		}
	}

	switch exp.Separator {
	case "[]":
		return exp.checkIndex(p)
	case "+":
		return exp.checkAdd(p)
	case "*":
		return exp.checkMul(p)
	case "==", "!=":
		return exp.checkEq(p)
	case "<", ">", "<=", ">=":
		return exp.checkCmp(p)
	case "&&", "||":
		return exp.checkLogic(p)
	case "-", "/", "%", "<<", ">>", "&", "|", "^":
		return exp.checkArith(p)
	case "=", ":=", "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>=":
		return exp.checkAssign(p)
	case "++", "--":
		return exp.checkIncDec(p)
	}

	return true
}

// checkLogic 检查逻辑运算符 && ||，要求左右均为 bool。
func (exp *Expression) checkLogic(p *Parser) bool {
	leftKind := exp.Left.Type.Kind()
	rightKind := exp.Right.Type.Kind()

	if leftKind != "bool" || rightKind != "bool" {
		p.Error.MissError("Type Error", p.Lexer.Cursor, "operands of '"+exp.Separator+"' must be bool")
		return false
	}

	if exp.Left.IsConst() && exp.Right.IsConst() {
		if exp.Separator == "&&" {
			exp.Bool = exp.Left.Bool && exp.Right.Bool
		} else {
			exp.Bool = exp.Left.Bool || exp.Right.Bool
		}
		exp.foldBin()
	}

	exp.Type = typeSys.GetSystemType("bool")
	return true
}

// checkAssign 检查赋值运算符类型兼容性。若左子为索引表达式则交给
// checkIndexAssign 统一处理（内建 []= 或自定义 set），若左子为解引用表达式
// 则转换为 deref=。
func (exp *Expression) checkAssign(p *Parser) bool {
	if os.Getenv("CUTE_DEBUG_CHK") != "" {
		lsep, lright := "", false
		if exp.Left != nil {
			lsep = exp.Left.Separator
			lright = exp.Left.Right != nil
		}
		fmt.Fprintf(os.Stderr, "CHKASSIGN sep=%s l.sep=%s l.L=%v l.R=%v\n", exp.Separator, lsep, exp.Left != nil && exp.Left.Left != nil, lright)
	}
	// 索引赋值：arr[i] = val / arr[i] op= val，由 checkIndexAssign 决定
	// 走内建 []= 还是自定义类型的 set 方法。
	if exp.Left != nil && exp.Left.Separator == "[]" {
		return exp.checkIndexAssign(p)
	}

	// 解引用赋值转换：*p = val → deref=(val, p)
	if exp.Left != nil && exp.Left.Separator == "*" && exp.Left.Left == nil {
		if os.Getenv("CUTE_DEBUG_CHK") != "" {
			fmt.Fprintf(os.Stderr, "CHKDEREFCONV fired\n")
		}
		ptr := exp.Left.Right
		exp.Separator = "deref="
		exp.Left = exp.Right
		exp.Right = ptr
		return exp.checkDerefAssign(p)
	}

	// 递归检查右值
	if exp.Right != nil {
		if !exp.Right.Check(p) {
			return false
		}
	}

	// 复合赋值运算符需要检查左值
	switch exp.Separator {
	case "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>=":
		if exp.Left != nil {
			if !exp.Left.Check(p) {
				return false
			}
		}
	}

	if exp.Left != nil && exp.Right != nil && exp.Left.Type != nil && exp.Right.Type != nil {
		if !typeSys.AutoType(exp.Right.Type, exp.Left.Type, exp.Right.IsConst()) {
			p.Error.MissError("Type Error", p.Lexer.Cursor,
				"cannot use "+exp.Right.Type.Type()+" as type "+exp.Left.Type.Type()+" in assignment")
			return false
		}
	}

	exp.Type = exp.Left.Type
	return true
}

// lowerOperator 把运算符 lowering 到 receiver.method(args)。
// 没有候选方法或候选不匹配时报告 opName 在该类型上不可用。
func (exp *Expression) lowerOperator(p *Parser, receiver *Expression, method string, args []*Expression, opName string) bool {
	if receiver == nil || receiver.Type == nil {
		p.Error.MissError("Type Error", p.Lexer.Cursor, "operator "+opName+" has no operand type")
		return false
	}
	if len(methodCandidates(receiver.Type, method)) == 0 {
		p.Error.MissError("Type Error", p.Lexer.Cursor,
			"operator "+opName+" not defined for type "+receiver.Type.Type())
		return false
	}
	if !exp.lowerMethodCall(p, receiver, method, args) {
		// lowerMethodCall 已报告非左值/歧义；候选存在但签名不匹配时在这里补报。
		if receiver.Var != nil {
			p.Error.MissError("Call Error", p.Lexer.Cursor,
				"no matching overload for operator "+opName+" on type "+receiver.Type.Type())
		}
		return false
	}
	return true
}

// checkIndexAssign 检查索引赋值 arr[index] = value / arr[index] op= value。
// 节点形状：exp.Left 是 [] 索引节点，exp.Right 是右值。
// 内建 list/string/array/map 保持原 []= 路径；自定义类型 lowering 成
// receiver.set(index, value)。复合赋值展开成 set(index, get(index) op value)。
func (exp *Expression) checkIndexAssign(p *Parser) bool {
	idxNode := exp.Left
	value := exp.Right
	if value != nil {
		if !value.Check(p) {
			return false
		}
	}
	if idxNode == nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "index assignment has no left operand")
		return false
	}
	receiver := idxNode.Right
	if receiver == nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "index assignment has no receiver")
		return false
	}
	if !receiver.Check(p) {
		return false
	}
	if receiver.Type == nil {
		p.Error.MissError("Type Error", p.Lexer.Cursor, "index assignment receiver has no type")
		return false
	}

	// 自定义类型：不调用 idxNode.Check（那会把 LHS lower 成 get）。
	if !isBuiltinIndexKind(receiver.Type) {
		if idxNode.IndexSlice {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "cannot assign to slice expression")
			return false
		}
		for i := 0; i < 3; i++ {
			if idxNode.Index[i] != nil {
				if !idxNode.Index[i].Check(p) {
					return false
				}
			}
		}
		if idxNode.Index[0] == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "index assignment is empty")
			return false
		}
		return exp.lowerCustomIndexAssign(p, idxNode, value)
	}

	if !idxNode.Check(p) {
		return false
	}

	if idxNode.Right.Type != nil && idxNode.Right.Type.Kind() == "map" {
		mt, ok := idxNode.Right.Type.(*typeSys.MapType)
		if !ok || mt.Elem() == nil {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "invalid map type in index assignment")
			return false
		}
		elemType := mt.Elem()
		if value != nil && value.Type != nil && !typeSys.AutoType(value.Type, elemType, value.IsConst()) {
			p.Error.MissError("Type Error", p.Lexer.Cursor,
				"cannot use "+value.Type.Type()+" as type "+elemType.Type()+" in map assignment")
			return false
		}
	}

	// codegen 的 indexSet 依赖 []= 形状。
	exp.Separator = "[]="
	return true
}

// lowerCustomIndexAssign 把自定义类型索引赋值改写成 set 调用。
// 简单赋值：v[i] = x       → v.set(i, x)
// 复合赋值：v[i] += x      → v.set(i, v.get(i) + x)
func (exp *Expression) lowerCustomIndexAssign(p *Parser, idxNode *Expression, value *Expression) bool {
	receiver := idxNode.Right
	index := idxNode.Index[0]
	simple := exp.Separator == "=" || exp.Separator == ":="
	if !simple && isAssignSeparator(exp.Separator) {
		op := strings.TrimSuffix(exp.Separator, "=")
		// get 与 set 复用同一个已检查的接收者/索引表达式；接收者必须是
		// 变量（lowerMethodCall 会再次校验），重复求值不会产生副作用。
		getNode := &Expression{Separator: "[]", Right: receiver, Index: idxNode.Index}
		if !getNode.Check(p) {
			return false
		}
		bin := &Expression{Separator: op, Left: getNode, Right: value}
		if !bin.Check(p) {
			return false
		}
		return exp.lowerOperator(p, receiver, "set", []*Expression{index, bin}, "[]=")
	}
	return exp.lowerOperator(p, receiver, "set", []*Expression{index, value}, "[]=")
}

// checkDerefAssign 检查解引用赋值 *addr = value（节点形状 deref=(值, 指针)）。
func (exp *Expression) checkDerefAssign(p *Parser) bool {
	if exp.Right != nil {
		if !exp.Right.Check(p) {
			return false
		}
	}
	if exp.Left != nil {
		if !exp.Left.Check(p) {
			return false
		}
	}

	if exp.Right.Type == nil || !exp.Right.Type.IsPointer() {
		p.Error.MissError("Type Error", p.Lexer.Cursor, "cannot assign through non-pointer")
		return false
	}

	elemType := typeSys.GetSystemType(exp.Right.Type.Type())
	if exp.Left.Type != nil && elemType != nil && !typeSys.AutoType(exp.Left.Type, elemType, exp.Left.IsConst()) {
		p.Error.MissError("Type Error", p.Lexer.Cursor,
			"cannot use "+exp.Left.Type.Type()+" as type "+elemType.Type()+" in dereference assignment")
		return false
	}

	return true
}

// checkIncDec 检查自增自减运算符 ++ --，要求操作数为数值类型。
func (exp *Expression) checkIncDec(p *Parser) bool {
	if exp.Left == nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "operator '"+exp.Separator+"' needs operand")
		return false
	}

	if !exp.Left.Check(p) {
		return false
	}

	if !typeSys.IsNum(exp.Left.Type) {
		p.Error.MissError("Type Error", p.Lexer.Cursor,
			"operator '"+exp.Separator+"' requires numeric type, got "+exp.Left.Type.Kind())
		return false
	}

	exp.Type = exp.Left.Type
	return true
}

// checkOverload 检查运算符重载方法，把表达式 lowering 成方法调用。
// 二元运算符接收者是 Left，一元运算符接收者是 Right（此时 Left 为 nil）。
func (exp *Expression) checkOverload(p *Parser) bool {
	operand := exp.Left
	unary := false
	if operand == nil {
		operand = exp.Right
		unary = true
	}
	if operand == nil || operand.Type == nil {
		return false
	}

	methodName := ""
	var args []*Expression
	if unary {
		methodName = unaryOpMethodMap[exp.Separator]
	} else {
		methodName = opMethodMap[exp.Separator]
		if exp.Right != nil {
			args = []*Expression{exp.Right}
		}
	}
	if methodName == "" {
		return false
	}

	return exp.lowerOperator(p, operand, methodName, args, exp.Separator)
}

// checkIndex 检查列表索引/切片，推导元素类型或列表类型。
func (exp *Expression) checkIndex(p *Parser) bool {
	// The indexed variable is stored in exp.Right (due to Insert logic)
	indexed := exp.Right
	if indexed == nil || indexed.Type == nil {
		p.Error.MissError("Type Error", p.Lexer.Cursor, "index operand has no type")
		return false
	}

	// 检查索引表达式类型
	for i := 0; i < 3; i++ {
		if exp.Index[i] != nil {
			if !exp.Index[i].Check(p) {
				return false
			}
		}
	}

	indexedType := builtinIndexTarget(indexed.Type)
	kind := indexedType.Kind()

	switch kind {
	case "list":
		listType := indexedType.(*typeSys.ListType)
		// 切片判断：源码中存在冒号（含 a[lo:] / a[:hi] / a[:] 等省略端点）
		if exp.IndexSlice {
			// 切片操作，返回相同列表类型
			exp.Type = indexedType
		} else {
			// 索引操作，返回元素类型
			if listType.Elem() != nil {
				exp.Type = listType.Elem()
			}
		}
		return true

	case "string":
		// 字符串索引返回 byte
		if !exp.IndexSlice {
			exp.Type = typeSys.GetSystemType("byte")
		} else {
			// 字符串切片返回 string
			exp.Type = typeSys.GetSystemType("string")
		}
		return true

	case "array":
		// 定长数组不支持切片：a[i] 返回元素类型
		if exp.IndexSlice {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "cannot slice a fixed-size array")
			return false
		}
		if arrType, ok := indexed.Type.(*typeSys.ArrayType); ok && arrType.Elem() != nil {
			exp.Type = arrType.Elem()
		}
		return true

	case "map":
		mt, ok := indexed.Type.(*typeSys.MapType)
		if !ok || mt.Elem() == nil {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "index operand has invalid map type")
			return false
		}
		if exp.IndexSlice {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "cannot slice a map")
			return false
		}
		if exp.Index[0] == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "map index is empty")
			return false
		}
		keyType := mt.Key()
		idxType := exp.Index[0].Type
		if keyType != nil && idxType != nil && !typeSys.AutoType(idxType, keyType, exp.Index[0].IsConst()) {
			p.Error.MissError("Type Error", p.Lexer.Cursor,
				"cannot use "+safeTypeName(idxType)+" as map key type "+safeTypeName(keyType))
			return false
		}
		exp.Type = mt.Elem()
		return true

	default:
		// 自定义类型：lowering 成 get/slice 方法调用。
		if exp.IndexSlice {
			start := exp.Index[0]
			if start == nil {
				start = intLiteral(0)
			}
			end := exp.Index[1]
			if end == nil {
				end = intLiteral(-1)
			}
			step := exp.Index[2]
			if step == nil {
				step = intLiteral(1)
			}
			return exp.lowerOperator(p, indexed, "slice",
				[]*Expression{start, end, step}, "[::]")
		}
		if exp.Index[0] == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "index is empty")
			return false
		}
		return exp.lowerOperator(p, indexed, "get",
			[]*Expression{exp.Index[0]}, "[]")
	}
}

// mapIntrinsicUnsupportedTarget 报告当前目标是否不支持手写的 SysV 寄存器 ABI
// 内建（map 字面量、嵌套列表字面量的多层 callee-save 方案等）。
// 32 位（x86/cdecl/stdcall）与 win64 的参数传递/保存寄存器布局不同，
// 在这些目标上下文里本编译器的手写调用序列会静默产出错误字节码。
func mapIntrinsicUnsupportedTarget() bool {
	switch typeSys.TargetArch() {
	case "x86_64", "x86_64.sysv":
		return false
	default:
		return true
	}
}

// checkMapLiteral 检查 map 字面量的键/值类型与声明保持一致。
func (exp *Expression) checkMapLiteral(p *Parser) bool {
	if mapIntrinsicUnsupportedTarget() {
		p.Error.MissError("Type Error", p.Lexer.Cursor,
			"map literal requires x86_64 (SysV) target")
		return false
	}
	mt, ok := exp.Type.(*typeSys.MapType)
	if !ok {
		p.Error.MissError("Type Error", p.Lexer.Cursor,
			"map literal has no map type")
		return false
	}
	kt, vt := mt.Key(), mt.Elem()
	for _, entry := range exp.MapElems {
		if entry.Key == nil || entry.Value == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "malformed map entry")
			return false
		}
		if !entry.Key.Check(p) {
			return false
		}
		if entry.Key.Type != nil && !typeSys.AutoType(entry.Key.Type, kt, entry.Key.IsConst()) {
			p.Error.MissError("Type Error", p.Lexer.Cursor,
				"cannot use "+entry.Key.Type.Type()+" as map key of type "+kt.Type())
			return false
		}
		if !entry.Value.Check(p) {
			return false
		}
		if entry.Value.Type != nil && !typeSys.AutoType(entry.Value.Type, vt, entry.Value.IsConst()) {
			p.Error.MissError("Type Error", p.Lexer.Cursor,
				"cannot use "+entry.Value.Type.Type()+" as map value of type "+vt.Type())
			return false
		}
	}
	return true
}

// checkListLiteral 检查列表字面量元素类型。
func (exp *Expression) checkListLiteral(p *Parser) bool {
	if mapIntrinsicUnsupportedTarget() {
		for _, elem := range exp.ListElems {
			if elem != nil && elem.Type != nil && elem.Type.Kind() == "list" {
				p.Error.MissError("Type Error", p.Lexer.Cursor,
					"nested list literal requires x86_64 (SysV) target")
				return false
			}
		}
	}
	// If type is not set, infer from first element
	if exp.Type == nil {
		if len(exp.ListElems) == 0 {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "empty list literal has no type")
			return false
		}
		if !exp.ListElems[0].Check(p) {
			return false
		}
		elemType := exp.ListElems[0].Type
		if elemType == nil {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "cannot infer type of list element")
			return false
		}
		exp.Type = typeSys.NewList(elemType)
	}

	listType, ok := exp.Type.(*typeSys.ListType)
	if !ok {
		// 定长数组字面量：逐元素检查类型 + 元素个数
		if arrType, isArr := exp.Type.(*typeSys.ArrayType); isArr && arrType.Elem() != nil {
			if len(exp.ListElems) != arrType.Len() {
				p.Error.MissError("Type Error", p.Lexer.Cursor,
					"array literal has "+itoa(len(exp.ListElems))+" elements but wants "+
						itoa(arrType.Len()))
				return false
			}
			for _, elem := range exp.ListElems {
				if !elem.Check(p) {
					return false
				}
				if elem.Type != nil && !typeSys.AutoType(elem.Type, arrType.Elem(), elem.IsConst()) {
					p.Error.MissError("Type Error", p.Lexer.Cursor,
						"cannot use "+safeTypeName(elem.Type)+" as type "+arrType.Elem().Type()+
							" in array literal")
					return false
				}
			}
		}
		return true
	}

	for _, elem := range exp.ListElems {
		if !elem.Check(p) {
			return false
		}
		elemType := listType.Elem()
		if elem.Type != nil && !typeSys.AutoType(elem.Type, elemType, elem.IsConst()) {
			p.Error.MissError("Type Error", p.Lexer.Cursor,
				"cannot use "+elem.Type.Type()+" as type "+elemType.Type()+" in list literal")
			return false
		}
	}

	return true
}

// checkUnary 检查一元运算符（前缀 -、!、~）+ 常量折叠。
func (exp *Expression) checkUnary(p *Parser) bool {
	if exp.Right == nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "unary operator '"+exp.Separator+"' needs operand")
		return false
	}

	if !exp.Right.Check(p) {
		return false
	}

	switch exp.Separator {
	case "-":
		if !typeSys.IsNum(exp.Right.Type) {
			return exp.checkOverload(p)
		}
		exp.Type = exp.Right.Type
		if exp.Right.IsConst() {
			exp.Num = -exp.Right.Num
			exp.foldNum(exp.Num)
		}

	case "!":
		if typeSys.CheckKind(exp.Right.Type, "bool") {
			exp.Type = typeSys.GetSystemType("bool")
			if exp.Right.IsConst() {
				exp.Bool = !exp.Right.Bool
				exp.foldBin()
			}
			return true
		}
		// 整数按真值取反（!0 为真，!n 为假）；代码生成按与 0 比较处理。
		if typeSys.IsNum(exp.Right.Type) {
			exp.Type = typeSys.GetSystemType("bool")
			if exp.Right.IsConst() {
				exp.Bool = exp.Right.Num == 0
				exp.foldBin()
			}
			return true
		}
		return exp.checkOverload(p)

	case "~":
		// 位取反适用于所有整数类型（含 uint/byte）；float 才走运算符重载。
		if !typeSys.IsNum(exp.Right.Type) || typeSys.CheckKind(exp.Right.Type, "float") {
			return exp.checkOverload(p)
		}
		exp.Type = exp.Right.Type
		if exp.Right.IsConst() {
			exp.Num = float64(^int64(exp.Right.Num))
			exp.foldNum(exp.Num)
		}

	case "*":
		if !exp.Right.Type.IsPointer() {
			p.Error.MissError("Type Error", p.Lexer.Cursor,
				"operator '*' requires pointer operand, got "+exp.Right.Type.Type())
			return false
		}
		elem := exp.Right.Type.Elem()
		if elem == nil {
			p.Error.MissError("Type Error", p.Lexer.Cursor,
				"cannot dereference type "+exp.Right.Type.Type())
			return false
		}
		if elem.Size() > 8 {
			p.Error.MissError("Type Error", p.Lexer.Cursor,
				"cannot dereference type "+elem.Type()+" (size > 8, use field access instead)")
			return false
		}
		exp.Type = elem

	case "&":
		if exp.Right.Var == nil {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "operator '&' requires a variable operand")
			return false
		}
		t := typeSys.GetSystemType(exp.Right.Type.Type())
		if t == nil {
			if exp.Right.Type == nil || exp.Right.Type.Kind() == "unknown" {
				p.Error.MissError("Type Error", p.Lexer.Cursor, "cannot take address of type "+exp.Right.Type.Type())
				return false
			}
			t = exp.Right.Type
		}
		exp.Type = typeSys.MakePointer(t)
	}

	return true
}

// checkAdd 检查加法运算：数值加法 + 字符串拼接 + 指针算术 + 运算符重载。
func (exp *Expression) checkAdd(p *Parser) bool {
	switch {
	case typeSys.CheckKind(exp.Left.Type, "string") && typeSys.CheckKind(exp.Right.Type, "string"):
		exp.Type = typeSys.GetSystemType("string")
		if exp.Left.IsConst() && exp.Right.IsConst() {
			exp.StringVal = exp.Left.StringVal + exp.Right.StringVal
			exp.foldBin()
		}
		return true

	case exp.Left.Type.IsPointer() && typeSys.IsNum(exp.Right.Type):
		exp.Type = exp.Left.Type
		return true

	case typeSys.IsNum(exp.Left.Type) && exp.Right.Type.IsPointer():
		exp.Type = exp.Right.Type
		return true

	case typeSys.IsNum(exp.Left.Type) && typeSys.IsNum(exp.Right.Type):
		return exp.checkArith(p)

	default:
		return exp.checkOverload(p)
	}
}

// checkMul 检查乘法运算：数值乘法 + 字符串重复 + 运算符重载。
func (exp *Expression) checkMul(p *Parser) bool {
	switch {
	case typeSys.CheckKind(exp.Left.Type, "string") && typeSys.CheckKind(exp.Right.Type, "int"):
		exp.Type = typeSys.GetSystemType("string")
		if exp.Left.IsConst() && exp.Right.IsConst() {
			// 常量折叠：n <= 0 与 repeatN 语义一致，返回空串。
			// 不能把负数直接交给 strings.Repeat，否则编译期 panic。
			n := int(exp.Right.Num)
			if n <= 0 {
				exp.StringVal = ""
			} else {
				exp.StringVal = strings.Repeat(exp.Left.StringVal, n)
			}
			exp.foldBin()
			return true
		}
		// 运行期重复 lowering 到 std:strings.repeatN；表项缺失或
		// CUTE_NO_INTRINSIC 开启时显式报错，不能再静默生成空结果。
		if exp.tryIntrinsicStringMul(p) {
			return true
		}
		return exp.checkOverload(p)

	case typeSys.IsNum(exp.Left.Type) && typeSys.IsNum(exp.Right.Type):
		return exp.checkArith(p)

	default:
		return exp.checkOverload(p)
	}
}

// checkArith 检查算术运算（- / % << >> & | ^），数值类型推导 + 常量折叠。
func (exp *Expression) checkArith(p *Parser) bool {
	if !typeSys.IsNum(exp.Left.Type) {
		return exp.checkOverload(p)
	}
	if !typeSys.IsNum(exp.Right.Type) {
		return exp.checkOverload(p)
	}

	// 泛型类型参数优先：TypeParam.Size()==-1，走位宽比较会把 T * int
	// 误推导成 int（位宽不符），必须保留 TypeParam 一侧，具体类型
	// 在单态化时由 substituteBodyTypes 替换。
	if isTypeParam(exp.Left.Type) {
		exp.Type = exp.Left.Type
		return true
	}
	if isTypeParam(exp.Right.Type) {
		exp.Type = exp.Right.Type
		return true
	}

	// 类型推导：float→f64；否则宽类型获胜。
	// 修复：int * u64 原先推导为 int，32 位架构下乘积被截断
	// （如 365*DAY 纳秒数），必须提升到 8 字节操作数的类型。
	//
	// 常量操作数不参与宽度提升：`u32 变量 + 1` 的结果仍是 u32。
	// 常量字面量（如 1）默认是 int，x86_64 上 int 是 8 字节；若按宽度
	// 提升会把整个表达式变成 int，后续与 u32 比较就会被判为类型不符。
	leftConst, rightConst := exp.Left.IsConst(), exp.Right.IsConst()
	switch {
	case leftConst && !rightConst:
		exp.Type = exp.Right.Type
		if typeSys.CheckKind(exp.Left.Type, "float") && !typeSys.CheckKind(exp.Right.Type, "float") {
			exp.Type = typeSys.GetSystemType("f64")
		}
	case rightConst && !leftConst:
		exp.Type = exp.Left.Type
		if typeSys.CheckKind(exp.Right.Type, "float") && !typeSys.CheckKind(exp.Left.Type, "float") {
			exp.Type = typeSys.GetSystemType("f64")
		}
	case typeSys.CheckKind(exp.Left.Type, "float") || typeSys.CheckKind(exp.Right.Type, "float"):
		exp.Type = typeSys.GetSystemType("f64")
	case exp.Right.Type.Size() > exp.Left.Type.Size():
		exp.Type = exp.Right.Type
	default:
		exp.Type = exp.Left.Type
	}

	if exp.Left.IsConst() && exp.Right.IsConst() {
		if !exp.foldArith(p) {
			return false
		}
	}

	return true
}

// checkEq 检查相等比较（== !=），只要左右类型相同即可。
func (exp *Expression) checkEq(p *Parser) bool {
	// 内建类型映射：string 的内容比较交给 std:strings.eq/ne。
	// 必须在通用三槽比较与常量折叠之前改写；字面量仍本地折叠。
	if exp.tryIntrinsicStringEq(p) {
		return true
	}

	// 自定义类型：同类型时优先调用 eq/ne 方法；没有方法则回退原生比较。
	if exp.Left != nil && exp.Right != nil && exp.Left.Type != nil && exp.Right.Type != nil &&
		!isTypeParam(exp.Left.Type) && !isTypeParam(exp.Right.Type) &&
		typeSys.TypeEqual(exp.Left.Type, exp.Right.Type) {
		method := opMethodMap[exp.Separator]
		if len(methodCandidates(exp.Left.Type, method)) > 0 {
			return exp.lowerOperator(p, exp.Left, method, []*Expression{exp.Right}, exp.Separator)
		}
	}

	// nil 与任意指针类型（ptr / *T）比较恒合法
	nilL := exp.Left.ConstNil && isPtrLike(exp.Right.Type)
	nilR := exp.Right.ConstNil && isPtrLike(exp.Left.Type)
	if !nilL && !nilR && !isTypeParam(exp.Left.Type) && !isTypeParam(exp.Right.Type) &&
		!typeSys.TypeEqual(exp.Left.Type, exp.Right.Type) {
		// 数值常量可与任何数值类型比较（如 u64 == 0）
		constNum := (exp.Left.IsConst() && typeSys.IsNum(exp.Left.Type) && typeSys.IsNum(exp.Right.Type)) ||
			(exp.Right.IsConst() && typeSys.IsNum(exp.Right.Type) && typeSys.IsNum(exp.Left.Type))
		if !constNum {
			return exp.checkOverload(p)
		}
	}

	exp.Type = typeSys.GetSystemType("bool")

	if exp.Left.IsConst() && exp.Right.IsConst() {
		exp.foldEq()
	}

	return true
}

// checkCmp 检查比较运算（< > <= >=），仅支持数值类型。
func (exp *Expression) checkCmp(p *Parser) bool {
	if !typeSys.IsNum(exp.Left.Type) {
		return exp.checkOverload(p)
	}
	if !typeSys.IsNum(exp.Right.Type) {
		return exp.checkOverload(p)
	}

	exp.Type = typeSys.GetSystemType("bool")
	if exp.Left.IsConst() && exp.Right.IsConst() {
		exp.foldCmp()
	}

	return true
}

// foldNum 常量折叠：设置数值、推导类型、清空子节点。
func (exp *Expression) foldNum(value float64) {
	exp.Num = value
	// 浮点上下文保留 f64：-1.0、1.0+1.0 的折叠结果仍是浮点常量，
	// 不能因数值恰好是整数就退回 int（两者的位模式完全不同）。
	if typeSys.CheckKind(exp.Type, "float") {
		exp.Type = typeSys.GetSystemType("f64")
	} else if exp.Num == float64(int(exp.Num)) {
		// 值超出 int32 范围时使用 i64，避免 x86 上 mov DWORD[mem], imm 溢出
		// (NASM 将超出 int32 范围的负数当作无符号处理，产生错误的位模式)
		if exp.Num > 2147483647 || exp.Num < -2147483648 {
			exp.Type = typeSys.GetSystemType("i64")
		} else {
			exp.Type = typeSys.GetSystemType("int")
		}
	} else {
		exp.Type = typeSys.GetSystemType("f64")
	}
	exp.foldBin()
}

// foldBin 二元常量折叠：清空运算符和子节点（值已存入 Num/Bool）。
func (exp *Expression) foldBin() {
	exp.Separator = ""
	exp.Left = nil
	exp.Right = nil
}

// foldArith 算术常量折叠，返回 false 表示折叠失败（如除零）。
func (exp *Expression) foldArith(p *Parser) bool {
	left := exp.Left.Num
	right := exp.Right.Num

	switch exp.Separator {
	case "+":
		exp.Num = left + right
	case "-":
		exp.Num = left - right
	case "*":
		exp.Num = left * right
	case "/":
		if right == 0 {
			// 浮点除零按 IEEE-754 折叠为 ±Inf / NaN。当前后端没有 XMM
			// 浮点除法，留到运行期会走整数 idiv 触发 SIGFPE。
			if typeSys.CheckKind(exp.Type, "float") {
				exp.Num = left / right
				break
			}
			p.Error.MissError("Runtime Error", p.Lexer.Cursor, "division by zero")
			return false
		}
		// 整数常量折叠：与运行期 idiv 语义一致（向零截断）。
		// 否则 ((10+5)*2-8)/4+3 会折成 8.5 并赋 int 类型，
		// 生成非法的 "mov RAX, 8.5"。
		if left == float64(int64(left)) && right == float64(int64(right)) {
			exp.Num = float64(int64(left) / int64(right))
		} else {
			exp.Num = left / right
		}
	case "%":
		if right == 0 {
			p.Error.MissError("Runtime Error", p.Lexer.Cursor, "modulo by zero")
			return false
		}
		exp.Num = float64(int(left) % int(right))
	case "^":
		exp.Num = float64(int(left) ^ int(right))
	case "<<":
		exp.Num = float64(int(left) << int(right))
	case ">>":
		exp.Num = float64(int(left) >> int(right))
	case "&":
		exp.Num = float64(int(left) & int(right))
	case "|":
		exp.Num = float64(int(left) | int(right))
	}

	exp.foldNum(exp.Num)
	return true
}

// foldCmp 比较常量折叠，结果存入 Bool。
func (exp *Expression) foldCmp() {
	left := exp.Left.Num
	right := exp.Right.Num
	result := false

	switch exp.Separator {
	case "<":
		result = left < right
	case ">":
		result = left > right
	case "<=":
		result = left <= right
	case ">=":
		result = left >= right
	}

	exp.Bool = result
	exp.foldBin()
}

// foldEq 相等常量折叠，整数用 int64 精确比较。
func (exp *Expression) foldEq() {
	left := exp.Left
	right := exp.Right
	result := false

	leftKind := left.Type.Kind()
	rightKind := right.Type.Kind()

	if leftKind == "int" || leftKind == "uint" || rightKind == "int" || rightKind == "uint" {
		// 整数精确比较
		result = int64(left.Num) == int64(right.Num)
	} else {
		// 浮点直接比较
		result = left.Num == right.Num
	}

	if exp.Separator == "!=" {
		result = !result
	}

	exp.Bool = result
	exp.foldBin()
}
