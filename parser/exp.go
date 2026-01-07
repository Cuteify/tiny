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

	// 如果是函数调用，检查函数调用
	if exp.Call != nil {
		if !exp.Call.Check(p) {
			return false
		}
		if len(exp.Call.Func.Return) != 1 {
			p.Error.MissError("Expression Error", p.Lexer.Cursor, "function call must have exactly one return value in expression context")
			return false
		}
		// 设置表达式类型为函数返回类型
		exp.Type = exp.Call.Func.Return[0]
		exp.checked = true
		return true
	}

	// 如果有操作符
	if exp.Separator != "" {
		// 检查左右子表达式是否存在
		if exp.Left == nil || exp.Right == nil {
			return false
		}

		// 获取左右子表达式
		left, right := exp.Left, exp.Right
		left.Check(p)
		right.Check(p)

		// 根据操作符类型进行不同的检查和处理
		switch exp.Separator {
		case "-", "/", "%", "^", "<<", ">>", "&", "|":
			// 数值运算操作符
			if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
				// 如果左和右操作数都是常量，则进行常量折叠优化
				if left.IsConst() && right.IsConst() {
					// 根据操作符执行计算
					switch exp.Separator {
					case "-":
						exp.Num = left.Num - right.Num
					case "/":
						exp.Num = left.Num / right.Num
					case "%":
						exp.Num = float64(int(left.Num) % int(right.Num))
					case "^":
						exp.Num = math.Pow(left.Num, right.Num)
					case "<<":
						exp.Num = float64(int(left.Num) << int(right.Num))
					case ">>":
						exp.Num = float64(int(left.Num) >> int(right.Num))
					case "&":
						exp.Num = float64(int(left.Num) & int(right.Num))
					case "|":
						exp.Num = float64(int(left.Num) | int(right.Num))
					}

					// 根据计算结果设置类型
					if float64(int(exp.Num)) == exp.Num {
						exp.Type = typeSys.GetSystemType("int")
					} else {
						exp.Type = typeSys.GetSystemType("f64")
					}

					// 清除操作符和子表达式，将表达式转换为常量
					exp.Separator = ""
					exp.Left, exp.Right = nil, nil
				} else if typeSys.CheckTypeType(left.Type, "float") && typeSys.CheckTypeType(right.Type, "float") {
					// 浮点数运算
					exp.Type = typeSys.GetSystemType("f64")
				} else {
					// 整数运算
					exp.Type = typeSys.GetSystemType("int")
				}
				exp.checked = true
				return true
			} else {
				// 类型不匹配
				return false
			}
		case "+":
			// 加法操作符
			if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
				// 数值加法
				if left.IsConst() && right.IsConst() {
					exp.Num = left.Num + right.Num
					if float64(int(exp.Num)) == exp.Num {
						exp.Type = typeSys.GetSystemType("int")
					} else {
						exp.Type = typeSys.GetSystemType("f64")
					}
					exp.Separator = ""
					exp.Left, exp.Right = nil, nil
				} else if typeSys.CheckTypeType(left.Type, "float") && typeSys.CheckTypeType(right.Type, "float") {
					exp.Type = typeSys.GetSystemType("f64")
				} else {
					exp.Type = typeSys.GetSystemType("int")
				}
				exp.checked = true
				return true
			} else if typeSys.CheckType(left.Type, typeSys.GetSystemType("string")) && typeSys.CheckType(right.Type, typeSys.GetSystemType("string")) {
				// 字符串连接
				exp.Type = typeSys.GetSystemType("string")
				exp.StringVal = left.StringVal + right.StringVal
				exp.checked = true
				return true
			} else {
				// 类型不匹配
				return false
			}
		case "*":
			// 乘法操作符
			if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
				// 数值乘法
				if left.IsConst() && right.IsConst() {
					exp.Num = left.Num * right.Num
					if float64(int(exp.Num)) == exp.Num {
						exp.Type = typeSys.GetSystemType("int")
					} else {
						exp.Type = typeSys.GetSystemType("f64")
					}
					exp.Separator = ""
					exp.Left, exp.Right = nil, nil
				} else if typeSys.CheckTypeType(left.Type, "float") && typeSys.CheckTypeType(right.Type, "float") {
					exp.Type = typeSys.GetSystemType("f64")
				} else {
					exp.Type = typeSys.GetSystemType("int")
				}
				exp.checked = true
				return true
			} else if typeSys.CheckType(left.Type, typeSys.GetSystemType("string")) && typeSys.CheckType(right.Type, typeSys.GetSystemType("int")) {
				// 字符串重复
				exp.Type = typeSys.GetSystemType("string")
				if left.IsConst() && right.IsConst() {
					exp.StringVal = strings.Repeat(left.StringVal, int(right.Num))
					exp.Separator = ""
					exp.Left, exp.Right = nil, nil
				}
				exp.checked = true
				return true
			} else {
				// 类型不匹配
				return false
			}
		case "==", "!=":
			// 相等比较操作符
			if typeSys.GetTypeType(left.Type) == typeSys.GetTypeType(right.Type) {
				exp.Type = typeSys.GetSystemType("bool")
				// 常量折叠优化
				if left.IsConst() && right.IsConst() {
					switch exp.Separator {
					case "==":
						if typeSys.CheckTypeType(left.Type, "int", "uint") {
							exp.Bool = int64(left.Num) == int64(right.Num)
						} else {
							exp.Bool = left.Num == right.Num
						}
					case "!=":
						if typeSys.CheckTypeType(left.Type, "int", "uint") {
							exp.Bool = int64(left.Num) != int64(right.Num)
						} else {
							exp.Bool = left.Num != right.Num
						}
					}
					exp.Separator = ""
					exp.Left, exp.Right = nil, nil
				}
				return true
			} else {
				// 类型不匹配
				return false
			}
		case "<", ">", "<=", ">=":
			// 大小比较操作符
			if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
				// 如果左和右操作数都是常量，则进行常量折叠优化
				if left.IsConst() && right.IsConst() {
					// 根据操作符计算结果
					switch exp.Separator {
					case "<":
						exp.Bool = left.Num < right.Num
					case ">":
						exp.Bool = left.Num > right.Num
					case "<=":
						exp.Bool = left.Num <= right.Num
					case ">=":
						exp.Bool = left.Num >= right.Num
					}
					exp.Separator = ""
					exp.Left, exp.Right = nil, nil
				}
				exp.Type = typeSys.GetSystemType("bool")
				return true
			} else {
				// 类型不匹配
				return false
			}
		case "&&", "||":
			// 逻辑操作符
			if typeSys.CheckType(left.Type, typeSys.GetSystemType("bool")) && typeSys.CheckType(right.Type, typeSys.GetSystemType("bool")) {
				exp.Type = typeSys.GetSystemType("bool")
				if left.IsConst() && right.IsConst() {
					// 常量折叠优化
					if exp.Separator == "&&" {
						exp.Bool = left.Bool && right.Bool
					} else {
						exp.Bool = left.Bool || right.Bool
					}
					exp.Separator = ""
					exp.Left, exp.Right = nil, nil
				}
				return true
			} else {
				// 类型不匹配
				return false
			}
		case "":
			// 空操作符
			exp.checked = true
			return true
		default:
			// 不支持的操作符
			return false
		}
	} else {
		// 没有操作符的情况
		exp.checked = true
		return true
	}
}

func (exp *Expression) CheckVar(p *Parser) bool {
	if exp.Var == nil {
		return true
	}

	if exp.Var.Define == nil {
		exp.Var.ParseDefine(p)
	}
	if exp.Var.Define == nil {
		return false
	}

	switch exp.Var.Define.Value.(type) {
	case *VarBlock:
		exp.Var.Offset = exp.Var.Define.Value.(*VarBlock).Offset
		exp.Type = exp.Var.Define.Value.(*VarBlock).Type
	case *ArgBlock:
		exp.Var.Type = exp.Var.Define.Value.(*ArgBlock).Type
		exp.Var.Offset = exp.Var.Define.Value.(*ArgBlock).Offset
		exp.Type = exp.Var.Define.Value.(*ArgBlock).Type
	}
	exp.Var.Type = exp.Type
	return true
}

// IsConst 判断表达式是否为常量
// 返回:
//   - bool: 是否为常量表达式
func (exp *Expression) IsConst() bool {
	// 如果没有变量、函数调用且没有操作符，则为常量
	return exp.Var == nil && exp.Call == nil && exp.Separator == ""
}

// ParseExpression 解析表达式
// 参数:
//   - p: 解析器
//   - stopCursor: 停止解析的位置
//
// 返回:
//   - *Expression: 解析得到的表达式
func (p *Parser) ParseExpression(stopCursor int) *Expression {
	// 操作数栈和操作符栈
	stackNum := []*Expression{}
	stackSep := []*Expression{}

	// 表达式起始位置
	//expStartCursor := p.Lexer.Cursor

	// 负号标志
	nextIsNar := false

	// 如果已经到达停止位置，则返回nil
	if p.Lexer.Cursor == stopCursor {
		return nil
	}

	// 循环解析直到停止位置
	for p.Lexer.Cursor < stopCursor {
		// 获取下一个词法单元
		token := p.Lexer.Next()

		if p.Lexer.Cursor > stopCursor {
			p.Error.MissError("expression error", p.Lexer.Cursor, "expression error")
		}

		var exp *Expression
		// 根据词法单元类型进行处理
		switch token.Type {
		case lexer.SEPARATOR:
			if token.Value == ";" {
				continue
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
			name := token.Value
			exp = &Expression{}
			exp.parseName(p, name, stopCursor)
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
		if len(stackNum) >= 2 && len(stackSep) >= 2 && // 栈中有需要计算的表达式
			(token.Type != lexer.SEPARATOR || stackSep[len(stackSep)-1].Separator == ")") { // 不是除)外的操作符
			stackNum, stackSep = handleWe(stackNum, stackSep)
		}
	}
	if len(stackNum) == 0 {
		p.Error.MissError("Invalid expression", p.Lexer.Cursor, "Missing expression")
	}
	return afterHandle(stackNum, stackSep)
}

func (exp *Expression) parseName(p *Parser, name string, stopCursor int) {
	// 如果下一个位置在停止位置之前
	if p.Lexer.Cursor+2 <= stopCursor {
		token := p.Lexer.Next()

		// 如果是空词法单元，则报错
		if token.IsEmpty() {
			p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Incomplete expression")
		}
		p.Lexer.SetCursor(token.Cursor)
		// 如果是左括号，则解析函数调用
		if token.Type == lexer.SEPARATOR && token.Value == "(" {
			exp.Call = &CallBlock{
				Name: name,
			}
			exp.Call.ParseCall(p)
		} else {
			// 否则解析变量
			exp.handleVar(p, name)
		}
	} else {
		exp.handleVar(p, name)
	}
}

func (exp *Expression) handleVar(p *Parser, name string) {
	varBlock := &VarBlock{
		Name: name,
	}
	exp.Var = varBlock
	exp.Var.ParseDefine(p)
	switch varBlock.Define.Value.(type) {
	case *VarBlock:
		varBlock.Offset = varBlock.Define.Value.(*VarBlock).Offset
		exp.Type = varBlock.Define.Value.(*VarBlock).Type
	case *ArgBlock:
		varBlock.Offset = varBlock.Define.Value.(*ArgBlock).Offset
		exp.Type = varBlock.Define.Value.(*ArgBlock).Type
	}
}

func (exp *Expression) handleNum(p *Parser, nextIsNar bool) {
	if exp.Num == float64(int(exp.Num)) {
		exp.Type = typeSys.GetSystemType("int")
	} else {
		exp.Type = typeSys.GetSystemType("f64")
	}

	// 如果是负号，则对数值取反
	if nextIsNar {
		if exp.IsConst() {
			exp.Num = -exp.Num
		}
	}
}

func (exp *Expression) SetOperator(left *Expression, right *Expression) {
	exp.Left = left
	exp.Right = right
	left.Father = exp
	right.Father = exp
}

func handleWe(stackNum, stackSep []*Expression) ([]*Expression, []*Expression) {
	// 处理右括号
	if stackSep[len(stackSep)-1].Separator == ")" {
		if stackSep[len(stackSep)-2].Separator == "(" {
			stackSep = stackSep[:len(stackSep)-2] // 遇到前面马上就是前括号的，就删除一对括号
		} else {
			lastSep := stackSep[len(stackSep)-2] // 因为包含括回，所以最后的操作符在倒数第二位
			lastSep.SetOperator(stackNum[len(stackNum)-2], stackNum[len(stackNum)-1])
			stackNum = stackNum[:len(stackNum)-2] // 删除使用完的两个数字
			stackNum = append(stackNum, lastSep)
			stackSep = stackSep[:len(stackSep)-3] // 删除使用完的括回和当前的操作符还有前括号
		}
	}

	// 如果操作数或操作符不足，则继续
	if len(stackNum) < 2 && len(stackSep) < 2 {
		return stackNum, stackSep
	}

	// 如果遇到左括号，则继续
	// 添加对stackSep长度的检查以避免数组越界
	if len(stackSep) >= 2 {
		if stackSep[len(stackSep)-1].Separator == "(" || stackSep[len(stackSep)-2].Separator == "(" {
			return stackNum, stackSep

		}
	} else if len(stackSep) >= 1 {
		if stackSep[len(stackSep)-1].Separator == "(" {
			return stackNum, stackSep

		}
	}

	// 获取操作符优先级 (添加长度检查)
	// 只有在有足够的操作符时才进行优先级比较
	if len(stackSep) < 2 {
		// 操作符不足，继续处理下一个token
		return stackNum, stackSep

	}

	tokenWe := getWe(stackSep[len(stackSep)-1].Separator)     // 获取当前操作符的优先级
	lastTokenWe := getWe(stackSep[len(stackSep)-2].Separator) // 获取上一个操作符的优先级

	// 获取两个操作数
	num1, num2 := stackNum[len(stackNum)-2], stackNum[len(stackNum)-1] // 获取两个操作数
	stackNum = stackNum[:len(stackNum)-2]                              // 然后删除

	// 根据优先级构建表达式树
	if tokenWe > lastTokenWe { // 如果当前操作符的优先级高于上一个操作符
		nowSep := stackSep[len(stackSep)-1]
		nowSep.SetOperator(num1, num2)
		stackNum = append(stackNum, nowSep)
	} else {
		lastSep := stackSep[len(stackSep)-2]
		lastSep.SetOperator(stackNum[len(stackNum)-1], num1)
		stackNum = stackNum[:len(stackNum)-1]                 // 删除
		stackNum = append(stackNum, lastSep, num2)            // 添加高优先级的操作符，保持低优先级的操作数num2
		stackSep[len(stackSep)-2] = stackSep[len(stackSep)-1] // 替换栈顶的操作符（因为后续栈顶被删除了，所以需要替换）
	}
	stackSep = stackSep[:len(stackSep)-1] // 弹出操作符
	return stackNum, stackSep
}

func afterHandle(stackNum, stackSep []*Expression) *Expression {

	for len(stackNum) >= 2 && len(stackSep) >= 1 {
		// 获取操作符优先级 (添加长度检查)
		// 只有在有足够的操作符时才进行优先级比较
		lastTokenWe := 0
		if len(stackSep) >= 2 {
			// 操作符不足，继续处理下一个token
			lastTokenWe = getWe(stackSep[len(stackSep)-2].Separator) // 获取上一个操作符的优先级
		}

		tokenWe := getWe(stackSep[len(stackSep)-1].Separator) // 获取当前操作符的优先级

		// 获取两个操作数
		num1, num2 := stackNum[len(stackNum)-2], stackNum[len(stackNum)-1] // 获取两个操作数
		stackNum = stackNum[:len(stackNum)-2]                              // 然后删除

		// 根据优先级构建表达式树
		if tokenWe > lastTokenWe { // 如果当前操作符的优先级高于上一个操作符
			nowSep := stackSep[len(stackSep)-1]
			nowSep.SetOperator(num1, num2)
			stackNum = append(stackNum, nowSep)
		} else {
			lastSep := stackSep[len(stackSep)-2]
			lastSep.SetOperator(stackNum[len(stackNum)-3], num1)
			stackNum = append(stackNum[:len(stackNum)-3], stackNum[len(stackNum)-2:]...) // 删除
			stackNum = append(stackNum, lastSep, num2)                                   // 添加高优先级的操作符，保持低优先级的操作数num2
			stackSep[len(stackSep)-2] = stackSep[len(stackSep)-1]                        // 替换栈顶的操作符（因为后续栈顶被删除了，所以需要替换）
		}
	}
	return stackNum[0]
}

func toTree(stackNum, stackSep []*Expression) *Expression {

	// 处理剩余的操作数和操作符

	for len(stackNum) >= 2 && len(stackSep) >= 1 {
		num1, num2 := stackNum[len(stackNum)-2], stackNum[len(stackNum)-1]
		stackNum = stackNum[:len(stackNum)-2]
		stackSep[0].Left = num1
		stackSep[0].Right = num2
		num1.Father = stackSep[0]
		num2.Father = stackSep[0]
		stackNum = stackNum[:1]
		stackNum[0] = stackSep[0]
		if len(stackNum) == 0 {
			return nil
		}
	}

	// 处理负号

	if len(stackNum) == 1 && len(stackSep) == 1 && stackSep[0].Separator == "-" {
		if stackNum[len(stackNum)-1].IsConst() {
			stackNum[len(stackNum)-1].Num = -stackNum[len(stackNum)-1].Num
		} else {
			stackNum[len(stackNum)-1] = &Expression{
				Type: stackNum[len(stackNum)-1].Type,
				Left: stackNum[len(stackNum)-1],
				Right: &Expression{
					Type: stackNum[len(stackNum)-1].Type,
					Num:  -1,
				},
				Separator: "*",
			}
		}
		stackSep = stackSep[:len(stackSep)-1]
		//stackNum[len(stackNum)-1].Check(p)
	}

	// 如果没有操作数，则返回nil

	if len(stackNum) == 0 {
		return nil
	}

	// 返回构建好的表达式
	return stackNum[0]
}

// FindVar 在表达式中查找变量
// 参数:
//   - v: 要查找的变量
//
// 返回:
//   - bool: 是否找到该变量
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

// Print 打印表达式（用于调试）
func (exp *Expression) String() (buf string) {
	// 先打印左子表达式
	if exp.Left != nil {
		buf += exp.Left.String()
	}

	// 再打印右子表达式

	if exp.Right != nil {
		buf += exp.Right.String()
	}

	// 打印当前节点
	if exp.Separator != "" {
		buf += fmt.Sprint(exp.Separator)
	} else {
		if exp.Var != nil {
			buf += fmt.Sprint(exp.Var.Name)
		} else if exp.Call != nil {
			buf += fmt.Sprint(exp.Call.Name) + "(" + strconv.Itoa(len(exp.Call.Args)) + ")"
		} else if exp.StringVal != "" {
			buf += fmt.Sprint("\"" + exp.StringVal + "\"")
		} else if exp.Type == typeSys.GetSystemType("bool") {
			if exp.Bool {
				buf += fmt.Sprint("true")
			} else {
				buf += fmt.Sprint("false")
			}
		} else {
			buf += fmt.Sprint(exp.Num)
		}
	}
	buf += " "
	if exp.Father == nil {
		buf = "Exp[" + buf[:len(buf)-1] + "]"
	}
	return buf
}

func (exp *Expression) Print() {
	// 如果是根节点，则换行
	if exp.Father == nil {
		fmt.Println(exp)
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
		"/":
		return 4
	case "^":
		return 5
	}
	return 0
}

/*
b+3>666

b3+
>*/
