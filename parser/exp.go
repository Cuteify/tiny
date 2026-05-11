// Package parser 实现了表达式解析和类型检查
package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"fmt"
	"math"
	"strconv"
	"strings"
)

// Expression 表达式结构体
type Expression struct {
	Call      *CallBlock   // 函数调用
	Num       float64      // 数值
	Separator string       // 操作符
	Right     *Expression  // 右子表达式
	Left      *Expression  // 左子表达式
	Father    *Expression  // 父表达式
	Var       *VarBlock    // 变量
	StringVal string       // 字符串值
	Bool      bool         // 布尔值
	ConstBool bool         // 常量布尔值
	Type      typeSys.Type // 类型
	Field     *Expression  // 字段访问（用于结构体字段访问，如 obj.field）
	checked   bool
}

// Check 检查表达式的有效性并进行类型推导和常量折叠优化
// 参数:
//   - p: 解析器
//
// 返回:
//   - bool: 表达式是否有效
func (exp *Expression) Check(p *Parser) bool {
	if exp.checked {
		return true
	}

	exp.CheckVar(p)

	if exp.Call != nil {
		if !exp.checkCall(p) {
			return false
		}
	}

	if exp.Separator != "" {
		if !exp.checkOperator(p) {
			return false
		}
	}

	exp.checked = true
	return true
}

func (exp *Expression) checkCall(p *Parser) bool {
	if !exp.Call.Check(p) {
		return false
	}
	if len(exp.Call.Func.Return) != 1 {
		p.Error.MissError("Expression Error", p.Lexer.Cursor, "function call must have exactly one return value in expression context")
		return false
	}
	exp.Type = exp.Call.Func.Return[0]
	exp.checked = true
	return true
}

func (exp *Expression) checkOperator(p *Parser) bool {
	if exp.Left == nil || exp.Right == nil {
		return false
	}

	left, right := exp.Left, exp.Right
	left.Check(p)
	right.Check(p)

	switch exp.Separator {
	case ".":
		return exp.checkFieldAccess(p, left, right)
	case "-", "/", "%", "^", "<<", ">>", "&", "|":
		return exp.checkArithmeticOp(p, left, right)
	case "+":
		return exp.checkAddOp(p, left, right)
	case "*":
		return exp.checkMulOp(p, left, right)
	case "==", "!=":
		return exp.checkEqualityOp(p, left, right)
	case "<", ">", "<=", ">=":
		return exp.checkComparisonOp(p, left, right)
	case "&&", "||":
		return exp.checkLogicalOp(p, left, right)
	case "":
		exp.checked = true
		return true
	default:
		return false
	}
}

func (exp *Expression) checkArithmeticOp(_ *Parser, left, right *Expression) bool {
	if !typeSys.CheckTypeType(left.Type, "uint", "int", "float") || !typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
		return false
	}

	if left.IsConst() && right.IsConst() {
		exp.foldArithmeticConstants(left, right)
	} else if typeSys.CheckTypeType(left.Type, "float") && typeSys.CheckTypeType(right.Type, "float") {
		exp.Type = typeSys.GetSystemType("f64")
	} else {
		exp.Type = typeSys.GetSystemType("int")
	}

	exp.checked = true
	return true
}

func (exp *Expression) checkAddOp(_ *Parser, left, right *Expression) bool {
	// 数值加法
	if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
		if left.IsConst() && right.IsConst() {
			exp.foldNumericConstants(left.Num + right.Num)
		} else if typeSys.CheckTypeType(left.Type, "float") && typeSys.CheckTypeType(right.Type, "float") {
			exp.Type = typeSys.GetSystemType("f64")
		} else {
			exp.Type = typeSys.GetSystemType("int")
		}
		exp.checked = true
		return true
	}

	// 字符串拼接
	if typeSys.CheckType(left.Type, typeSys.GetSystemType("string")) && typeSys.CheckType(right.Type, typeSys.GetSystemType("string")) {
		exp.Type = typeSys.GetSystemType("string")
		exp.StringVal = left.StringVal + right.StringVal
		exp.checked = true
		return true
	}

	return false
}

func (exp *Expression) checkMulOp(_ *Parser, left, right *Expression) bool {
	// 数值乘法
	if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
		if left.IsConst() && right.IsConst() {
			exp.foldNumericConstants(left.Num * right.Num)
		} else if typeSys.CheckTypeType(left.Type, "float") && typeSys.CheckTypeType(right.Type, "float") {
			exp.Type = typeSys.GetSystemType("f64")
		} else {
			exp.Type = typeSys.GetSystemType("int")
		}
		exp.checked = true
		return true
	}

	// 字符串重复
	if typeSys.CheckType(left.Type, typeSys.GetSystemType("string")) && typeSys.CheckType(right.Type, typeSys.GetSystemType("int")) {
		exp.Type = typeSys.GetSystemType("string")
		if left.IsConst() && right.IsConst() {
			exp.StringVal = strings.Repeat(left.StringVal, int(right.Num))
			exp.Separator = ""
			exp.Left, exp.Right = nil, nil
		}
		exp.checked = true
		return true
	}

	return false
}

func (exp *Expression) checkEqualityOp(_ *Parser, left, right *Expression) bool {
	if typeSys.GetTypeType(left.Type) != typeSys.GetTypeType(right.Type) {
		return false
	}

	exp.Type = typeSys.GetSystemType("bool")

	if left.IsConst() && right.IsConst() {
		exp.foldEqualityConstants(left, right)
	}

	return true
}

func (exp *Expression) checkComparisonOp(_ *Parser, left, right *Expression) bool {
	if !typeSys.CheckTypeType(left.Type, "uint", "int", "float") || !typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
		return false
	}

	if left.IsConst() && right.IsConst() {
		exp.foldComparisonConstants(left.Num, right.Num)
	}

	exp.Type = typeSys.GetSystemType("bool")
	return true
}

func (exp *Expression) checkLogicalOp(_ *Parser, left, right *Expression) bool {
	if !typeSys.CheckType(left.Type, typeSys.GetSystemType("bool")) || !typeSys.CheckType(right.Type, typeSys.GetSystemType("bool")) {
		return false
	}

	exp.Type = typeSys.GetSystemType("bool")

	if left.IsConst() && right.IsConst() {
		if exp.Separator == "&&" {
			exp.Bool = left.Bool && right.Bool
		} else {
			exp.Bool = left.Bool || right.Bool
		}
		exp.foldBinaryOpConstants()
	}

	return false
}

func (exp *Expression) checkFieldAccess(p *Parser, left, right *Expression) bool {
	left.Check(p)
	if left.Type == nil {
		p.Error.MissError("Field access error", p.Lexer.Cursor, "left operand of '.' must have a type")
		return false
	}

	// TODO: structName := left.Type.Type()
	// TODO: _, structBlock, _ := p.FindStruct(NewName(structName))
	// TODO: if structBlock == nil {
	// TODO: 	p.Error.MissError("Field access error", p.Lexer.Cursor, "type '"+structName+"' is not a struct")
	// TODO: 	return false
	// TODO: }
	// TODO:
	// TODO: structBlock.Check(p)
	// TODO:
	// TODO: if right.Var == nil {
	// TODO: 	p.Error.MissError("Field access error", p.Lexer.Cursor, "right operand of '.' must be a field name")
	// TODO: 	return false
	// TODO: }
	// TODO:
	// TODO: fieldName := right.Var.Name.String()
	// TODO: field := structBlock.GetFieldByName(fieldName)
	// TODO: if field == nil {
	// TODO: 	p.Error.MissError("Field access error", p.Lexer.Cursor, "struct '"+structName+"' has no field '"+fieldName+"'")
	// TODO: 	return false
	// TODO: }
	// TODO:
	// TODO: if field.IsPrivate() {
	// TODO: 	p.Error.MissError("Field access error", p.Lexer.Cursor, "field '"+fieldName+"' is private")
	// TODO: 	return false
	// TODO: }
	// TODO:
	// TODO: exp.Type = field.Type
	// TODO: exp.Field = right
	exp.checked = true
	return true
}

func (exp *Expression) foldComparisonConstants(left, right float64) {
	switch exp.Separator {
	case "<":
		exp.Bool = left < right
	case ">":
		exp.Bool = left > right
	case "<=":
		exp.Bool = left <= right
	case ">=":
		exp.Bool = left >= right
	}
	exp.foldBinaryOpConstants()
}

func (exp *Expression) foldEqualityConstants(left, right *Expression) {
	if typeSys.CheckTypeType(left.Type, "int", "uint") {
		leftNum := int64(left.Num)
		rightNum := int64(right.Num)
		switch exp.Separator {
		case "==":
			exp.Bool = leftNum == rightNum
		case "!=":
			exp.Bool = leftNum != rightNum
		}
	} else {
		switch exp.Separator {
		case "==":
			exp.Bool = left.Num == right.Num
		case "!=":
			exp.Bool = left.Num != right.Num
		}
	}
	exp.foldBinaryOpConstants()
}

func (exp *Expression) foldBinaryOpConstants() {
	exp.Separator = ""
	exp.Left, exp.Right = nil, nil
}

func (exp *Expression) foldArithmeticConstants(left, right *Expression) {
	switch exp.Separator {
	case "-":
		exp.foldNumericConstants(left.Num - right.Num)
	case "/":
		exp.foldNumericConstants(left.Num / right.Num)
	case "%":
		exp.foldNumericConstants(float64(int(left.Num) % int(right.Num)))
	case "^":
		exp.foldNumericConstants(math.Pow(left.Num, right.Num))
	case "<<":
		exp.foldNumericConstants(float64(int(left.Num) << int(right.Num)))
	case ">>":
		exp.foldNumericConstants(float64(int(left.Num) >> int(right.Num)))
	case "&":
		exp.foldNumericConstants(float64(int(left.Num) & int(right.Num)))
	case "|":
		exp.foldNumericConstants(float64(int(left.Num) | int(right.Num)))
	}
}

func (exp *Expression) foldNumericConstants(value float64) {
	exp.Num = value
	if float64(int(exp.Num)) == exp.Num {
		exp.Type = typeSys.GetSystemType("int")
	} else {
		exp.Type = typeSys.GetSystemType("f64")
	}
	exp.Separator = ""
	exp.Left, exp.Right = nil, nil
}

// CheckVar 检查表达式中的变量引用是否有效
func (exp *Expression) CheckVar(p *Parser) bool {
	if exp.Var == nil {
		return true
	}

	if exp.Var.Value != nil {
		if ok := exp.Var.Check(p); ok {
			exp.Type = exp.Var.Type
			return ok
		}
		return false
	}

	if exp.Var.Define == nil {
		exp.Var.ParseDefine(p)
	}

	if exp.Var.Type != nil {
		exp.Type = exp.Var.Type
		return true
	}

	if exp.Var.Define == nil {
		return false
	}

	exp.setVarInfo(exp.Var)
	return true
}

func (exp *Expression) setVarInfo(varBlock *VarBlock) {
	if varBlock.Define == nil {
		exp.Type = varBlock.Type
		varBlock.Type = exp.Type
		return
	}
	switch varBlock.Define.Value.(type) {
	case *VarBlock:
		varDef := varBlock.Define.Value.(*VarBlock)
		varBlock.Offset = varDef.Offset
		exp.Type = varDef.Type
	case *ArgBlock:
		argDef := varBlock.Define.Value.(*ArgBlock)
		varBlock.Offset = argDef.Offset
		exp.Type = argDef.Type
	}
	varBlock.Type = exp.Type
}

// IsConst 判断表达式是否为常量
// 返回:
//   - bool: 是否为常量表达式
func (exp *Expression) IsConst() bool {
	// 如果没有变量、函数调用且没有操作符，则为常量
	return exp.Var == nil && exp.Call == nil && exp.Separator == ""
}

// ParseExp 解析表达式
// 参数:
//   - p: 解析器
//   - stopCursor: 停止解析的位置
//
// 返回:
//   - *Expression: 解析得到的表达式
func (p *Parser) ParseExp(stopCursor int) *Expression {
	// 操作数栈和操作符栈
	stackNum := []*Expression{}
	stackSep := []*Expression{}

	// 如果已经到达停止位置，则返回nil
	if p.Lexer.Cursor == stopCursor {
		return nil
	}

	// 负号标志
	nextIsNar := false

	// 循环解析直到停止位置
	for p.Lexer.Cursor < stopCursor {
		// 获取下一个词法单元
		token := p.Lexer.Next()

		if token.EndCursor > stopCursor {
			p.Error.MissError("expression error", p.Lexer.Cursor, "expression error")
		}

		var exp *Expression
		// 根据词法单元类型进行处理
		switch token.Type {
		case lexer.SEPARATOR:
			if token.Value == ";" {
				p.Lexer.SetCursor(token.Cursor) // 退格
				goto end
			}
			// 分隔符
			stackSep = append(stackSep, &Expression{
				Separator: token.Value,
			})
		case lexer.STRING, lexer.CHAR, lexer.RAW:
			// 字符串、字符、原始字符串
			exp = &Expression{
				StringVal: token.Value,
				Type:      typeSys.GetSystemType("string"),
			}
		case lexer.NAME:
			// 标识符
			exp = &Expression{}
			if f := exp.parseName(p, token, stopCursor); f {
				return exp
			}
		case lexer.NUMBER:
			// 数字
			num, err := strconv.ParseFloat(token.Value, 64)
			if err != nil {
				p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, err.Error())
			}
			exp = &Expression{
				Num: num,
			}
			exp.handleNum(p, nextIsNar)
		case lexer.BOOL:
			// 布尔值
			exp = &Expression{
				Bool: token.Value == "true",
				Type: typeSys.GetSystemType("bool"),
			}
		default:
			// 其他类型报错
			p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Missing "+token.String())
		}

		if exp != nil {
			stackNum = append(stackNum, exp)
		}

		// 处理括号和操作符优先级
		if len(stackSep)-len(stackNum) >= 2 {
			if stackSep[len(stackSep)-2].Separator == "(" {
				// 左括号后的第一个操作符可能是负号
				stackSep = stackSep[:len(stackSep)-1]
			} else {
				p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Missing "+token.String())
			}
		}

		// 处理操作符优先级和表达式构建
		if len(stackNum) >= 2 && len(stackSep) >= 2 &&
			(token.Type != lexer.SEPARATOR || stackSep[len(stackSep)-1].Separator == ")") {
			stackNum, stackSep = handleWe(stackNum, stackSep)
		}
	}
end:
	if len(stackNum) == 0 {
		p.Error.MissError("Invalid expression", p.Lexer.Cursor, "Missing expression")
	}
	return afterHandle(stackNum, stackSep)
}

func (exp *Expression) parseName(p *Parser, nameToken lexer.Token, stopCursor int) (finish bool) {
	p.Lexer.SetCursor(nameToken.Cursor)
	name, nameStart := p.Name(false)

	if len(name) > 1 {
		token := p.Lexer.Next()
		if token.Value == "(" {
			p.Lexer.SetCursor(token.Cursor)
			exp.handleMethodCall(p, name)
			return true
		}
		afterName := p.Lexer.Cursor
		p.Lexer.SetCursor(nameToken.Cursor)
		exp.handleFieldAccess(p, name)
		p.Lexer.SetCursor(afterName)
		return true
	}

	if p.Lexer.Cursor+2 > stopCursor {
		exp.handleVar(p, name)
		return
	}

	token := p.Lexer.Next()
	if token.IsEmpty() {
		p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Incomplete expression")
		return
	}
	p.Lexer.SetCursor(token.Cursor)

	if token.Type == lexer.SEPARATOR {
		switch token.Value {
		case "(":
			exp.Call = &CallBlock{Name: name}
			exp.Call.ParseCall(p)
			return
		case ".":
			p.Lexer.SetCursor(nameStart)
			checkToken := p.Lexer.Next()
			if checkToken.Value == "(" {
				p.Lexer.SetCursor(nameStart)
				fullName, _ := p.Name(false)
				exp.handleMethodCall(p, fullName)
				return
			}
			p.Lexer.SetCursor(checkToken.Cursor)
			exp.handleFieldAccess(p, name)
			return
		case "=", ":=", "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>=", "++", "--":
			block := &VarBlock{}
			p.Lexer.SetCursor(nameStart)
			block.ParseVar(p)
			exp.Var = block
			p.AddChild(&Node{Value: block, Ignore: true})
			finish = true
			return
		}
	}
	exp.handleVar(p, name)
	return
}

func (exp *Expression) handleMethodCall(p *Parser, name Name) {
	exp.Call = &CallBlock{
		Name: name,
	}
	exp.Call.ParseCall(p)
}

func (exp *Expression) handleFieldAccess(p *Parser, name Name) {
	objName := name[0]

	if objName == "this" && len(name) > 1 {
		thisVar := &VarBlock{
			Name:     name,
			IsDefine: true,
		}
		thisVar.ParseDefine(p)
		exp.Var = thisVar
		exp.Type = thisVar.Type
		return
	}

	varBlock := &VarBlock{
		Name: name,
	}
	if varBlock.ParseDefine(p) {
		exp.Var = varBlock
		exp.Type = varBlock.Type
	}
}

func (exp *Expression) handleVar(p *Parser, name Name) {
	// 将字符串名称转换为Name类型
	varBlock := &VarBlock{
		Name: name,
	}
	exp.Var = varBlock
	if exp.Var.ParseDefine(p) {
		exp.setVarInfo(varBlock)
	}
}

func (exp *Expression) handleNum(_ *Parser, isNegative bool) {
	// 确定类型
	if exp.Num == float64(int(exp.Num)) {
		exp.Type = typeSys.GetSystemType("int")
	} else {
		exp.Type = typeSys.GetSystemType("f64")
	}

	// 负数处理
	if isNegative && exp.IsConst() {
		exp.Num = -exp.Num
	}
}

// SetOperator 设置表达式的左右子表达式和操作符关系
func (exp *Expression) SetOperator(left *Expression, right *Expression) {
	exp.Left = left
	exp.Right = right
	left.Father = exp
	right.Father = exp
}

// handleWe 处理操作符优先级栈的归约
func handleWe(stackNum, stackSep []*Expression) ([]*Expression, []*Expression) {
	// 处理右括号
	if stackSep[len(stackSep)-1].Separator == ")" {
		if stackSep[len(stackSep)-2].Separator == "(" {
			// 删除成对括号
			stackSep = stackSep[:len(stackSep)-2]
			return stackNum, stackSep
		}

		// 括号内计算
		lastSep := stackSep[len(stackSep)-2]
		lastSep.SetOperator(stackNum[len(stackNum)-2], stackNum[len(stackNum)-1])
		stackNum = stackNum[:len(stackNum)-2]
		stackNum = append(stackNum, lastSep)
		stackSep = stackSep[:len(stackSep)-3]
		return stackNum, stackSep
	}

	// 检查是否有足够的操作数和操作符
	if len(stackNum) < 2 || len(stackSep) < 2 {
		return stackNum, stackSep
	}

	// 遇到左括号则停止
	if stackSep[len(stackSep)-1].Separator == "(" || stackSep[len(stackSep)-2].Separator == "(" {
		return stackNum, stackSep
	}

	// 根据优先级构建表达式树
	currentPrec := getWe(stackSep[len(stackSep)-1].Separator)
	prevPrec := getWe(stackSep[len(stackSep)-2].Separator)

	num1, num2 := stackNum[len(stackNum)-2], stackNum[len(stackNum)-1]
	stackNum = stackNum[:len(stackNum)-2]

	if currentPrec > prevPrec {
		nowSep := stackSep[len(stackSep)-1]
		nowSep.SetOperator(num1, num2)
		stackNum = append(stackNum, nowSep)
	} else {
		lastSep := stackSep[len(stackSep)-2]
		lastSep.SetOperator(stackNum[len(stackNum)-1], num1)
		stackNum = stackNum[:len(stackNum)-1]
		stackNum = append(stackNum, lastSep, num2)
		stackSep[len(stackSep)-2] = stackSep[len(stackSep)-1]
	}
	stackSep = stackSep[:len(stackSep)-1]
	return stackNum, stackSep
}

// afterHandle 将表达式栈归约为最终表达式树
func afterHandle(stackNum, stackSep []*Expression) *Expression {
	for len(stackNum) >= 2 && len(stackSep) >= 1 {
		lastTokenWe := 0
		if len(stackSep) >= 2 {
			lastTokenWe = getWe(stackSep[len(stackSep)-2].Separator)
		}

		tokenWe := getWe(stackSep[len(stackSep)-1].Separator)

		num1, num2 := stackNum[len(stackNum)-2], stackNum[len(stackNum)-1]
		stackNum = stackNum[:len(stackNum)-2]

		if tokenWe > lastTokenWe {
			nowSep := stackSep[len(stackSep)-1]
			nowSep.SetOperator(num1, num2)
			stackNum = append(stackNum, nowSep)
		} else {
			lastSep := stackSep[len(stackSep)-2]
			lastSep.SetOperator(stackNum[len(stackNum)-3], num1)
			stackNum = append(stackNum[:len(stackNum)-3], stackNum[len(stackNum)-2:]...)
			stackNum = append(stackNum, lastSep, num2)
			stackSep[len(stackSep)-2] = stackSep[len(stackSep)-1]
		}
	}
	return stackNum[0]
}

// FindVar 在表达式中查找变量
// 参数:
//   - v: 要查找的变量
//
// 返回:
//   - bool: 是否找到该变量
//
// FindVar 在表达式树中查找指定的变量块
func (exp *Expression) FindVar(v Block) bool {
	// 在当前表达式的变量中查找
	var vd Block
	if exp.Var != nil {
		if exp.Var.Define != nil {
			vd = exp.Var.Define.Value
		} else {
			vd = exp.Var
		}
		if vd == v {
			return true
		}
	}

	// 在右子表达式中递归查找
	if exp.Right != nil && exp.Right.FindVar(v) {
		return true
	}

	// 在左子表达式中递归查找
	if exp.Left != nil && exp.Left.FindVar(v) {
		return true
	}

	// 没有找到
	return false
}

// String 返回表达式的字符串表示
func (exp *Expression) String() (buf string) {
	if exp.Left != nil {
		buf += exp.Left.String()
	}

	if exp.Right != nil {
		buf += exp.Right.String()
	}

	if exp.Separator != "" {
		buf += fmt.Sprint(exp.Separator)
	} else {
		buf += exp.valueString()
	}

	buf += " "
	if exp.Father == nil {
		buf = "Exp[" + buf[:len(buf)-1] + "]"
	}
	return buf
}

func (exp *Expression) valueString() string {
	if exp.Var != nil {
		return fmt.Sprint(exp.Var.Name)
	}
	if exp.Call != nil {
		return fmt.Sprintf("%s(%d)", exp.Call.Name, len(exp.Call.Args))
	}
	if exp.StringVal != "" {
		return fmt.Sprintf("\"%s\"", exp.StringVal)
	}
	if exp.Type == typeSys.GetSystemType("bool") {
		if exp.Bool {
			return "true"
		}
		return "false"
	}
	return fmt.Sprint(exp.Num)
}

// Print 打印表达式的字符串表示（仅根节点）
func (exp *Expression) Print() {
	if exp.Father == nil {
		fmt.Println(exp.String())
	}
}

// getWe 获取操作符优先级
// 参数:
//   - token: 操作符
//
// 返回:
//   - int: 优先级（数字越大优先级越高）
func getWe(token string) int {
	switch token {
	case "||",
		"&&":
		return 1
	case "==",
		"<=",
		">=",
		">",
		"<":
		return 2
	case "+",
		"-":
		return 3
	case "*",
		"/",
		"%":
		return 4
	case "^":
		return 5
	}
	return 0
}
