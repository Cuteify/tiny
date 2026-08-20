package parser

import (
	typeSys "cuteify/type"

	"strings"
)

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
		if len(exp.Call.Func.Return) == 1 {
			exp.Type = exp.Call.Func.Return[0]
			return true
		}
		p.Error.MissError("Type Error", p.Lexer.Cursor, "function call must return one value")
		return false
	}

	return false
}

// checkOp 运算符类型检查 + 常量折叠分发器。
func (exp *Expression) checkOp(p *Parser) bool {
	// 空运算符，直接通过
	if exp.Separator == "" {
		return true
	}

	switch exp.Separator {
	case "list_lit":
		return exp.checkListLiteral(p)
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

	// 递归检查子节点
	if exp.Left != nil {
		if !exp.Left.Check(p) {
			return false
		}
	}
	if exp.Right != nil {
		if !exp.Right.Check(p) {
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

// checkAssign 检查赋值运算符类型兼容性。若左子为索引表达式则转换为 []=，
// 若左子为解引用表达式则转换为 deref=。
func (exp *Expression) checkAssign(p *Parser) bool {
	// 索引赋值转换：arr[i] = val → arr[]=[i, val]
	if exp.Left != nil && exp.Left.Separator == "[]" {
		exp.Separator = "[]="
		return exp.checkIndexAssign(p)
	}

	// 解引用赋值转换：*p = val → deref=(val, p)
	if exp.Left != nil && exp.Left.Separator == "*" && exp.Left.Left == nil {
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

// checkIndexAssign 检查索引赋值 list[index] = value。
func (exp *Expression) checkIndexAssign(p *Parser) bool {
	// The indexed variable is stored in exp.Right (due to Insert logic)
	indexed := exp.Right
	if indexed != nil {
		if !indexed.Check(p) {
			return false
		}
	}
	// The value being assigned is in exp.Left
	if exp.Left != nil {
		if !exp.Left.Check(p) {
			return false
		}
	}

	if indexed.Type != nil && indexed.Type.Kind() == "list" {
		listType := indexed.Type.(*typeSys.ListType)
		elemType := listType.Elem()
		if exp.Left.Type != nil && !typeSys.AutoType(exp.Left.Type, elemType, exp.Left.IsConst()) {
			p.Error.MissError("Type Error", p.Lexer.Cursor,
				"cannot use "+exp.Left.Type.Type()+" as type "+elemType.Type()+" in index assignment")
			return false
		}
	}

	return true
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

// checkOverload 检查运算符重载方法，通过 FindFunc 查找 TypeName.method 方法。
func (exp *Expression) checkOverload(p *Parser) bool {
	if exp.Left == nil || exp.Left.Type == nil {
		return false
	}

	leftTypeName := exp.Left.Type.Type()
	if leftTypeName == "" {
		return false
	}

	methodName := ""
	if exp.Left != nil && exp.Right != nil {
		methodName = opMethodMap[exp.Separator]
	} else {
		methodName = unaryOpMethodMap[exp.Separator]
	}

	if methodName == "" {
		return false
	}

	methodFullName := NewName(leftTypeName, methodName)
	results := p.Find(methodFullName, FindTypeFunc)

	if len(results) > 0 {
		if funcBlock, ok := results[0].Value.(*FuncBlock); ok {
			exp.Type = funcBlock.Return[0]
			return true
		}
	}

	p.Error.MissError("Type Error", p.Lexer.Cursor,
		"operator "+exp.Separator+" not defined for type "+leftTypeName)
	return false
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

	kind := indexed.Type.Kind()

	switch kind {
	case "list":
		listType := indexed.Type.(*typeSys.ListType)
		// 切片判断：end 或 step 非 nil
		if exp.Index[1] != nil || exp.Index[2] != nil {
			// 切片操作，返回相同列表类型
			exp.Type = indexed.Type
		} else {
			// 索引操作，返回元素类型
			if listType.Elem() != nil {
				exp.Type = listType.Elem()
			}
		}
		return true

	case "string":
		// 字符串索引返回 byte
		if exp.Index[1] == nil && exp.Index[2] == nil {
			exp.Type = typeSys.GetSystemType("byte")
		} else {
			// 字符串切片返回 string
			exp.Type = typeSys.GetSystemType("string")
		}
		return true

	default:
		// 自定义类型，尝试运算符重载
		return exp.checkOverload(p)
	}
}

// checkListLiteral 检查列表字面量元素类型。
func (exp *Expression) checkListLiteral(p *Parser) bool {
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
	if !ok || listType.Elem() == nil {
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
		if !typeSys.CheckKind(exp.Right.Type, "bool") {
			return exp.checkOverload(p)
		}
		exp.Type = typeSys.GetSystemType("bool")
		if exp.Right.IsConst() {
			exp.Bool = !exp.Right.Bool
			exp.foldBin()
		}

	case "~":
		if !typeSys.CheckKind(exp.Right.Type, "int") {
			return exp.checkOverload(p)
		}
		exp.Type = typeSys.GetSystemType("int")
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
			exp.StringVal = strings.Repeat(exp.Left.StringVal, int(exp.Right.Num))
			exp.foldBin()
		}
		return true

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

	// 类型推导：float+float→f64，否则→左操作数类型
	if typeSys.CheckKind(exp.Left.Type, "float") || typeSys.CheckKind(exp.Right.Type, "float") {
		exp.Type = typeSys.GetSystemType("f64")
	} else {
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

	if !typeSys.TypeEqual(exp.Left.Type, exp.Right.Type) {
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
	if exp.Num == float64(int(exp.Num)) {
		exp.Type = typeSys.GetSystemType("int")
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
			p.Error.MissError("Runtime Error", p.Lexer.Cursor, "division by zero")
			return false
		}
		exp.Num = left / right
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
