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
}

// Check 检查表达式的有效性并进行类型推导和常量折叠优化
// 参数:
//   - p: 解析器
//
// 返回:
//   - bool: 表达式是否有效
func (e *Expression) Check(p *Parser) bool {
	// 如果有操作符
	if e.Separator != "" {
		// 检查左右子表达式是否存在
		if e.Left == nil || e.Right == nil {
			return false
		}

		// 获取左右子表达式
		left, right := e.Left, e.Right

		// 根据操作符类型进行不同的检查和处理
		switch e.Separator {
		case "-", "/", "%", "^", "<<", ">>", "&", "|":
			// 数值运算操作符
			if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
				// 如果左右操作数都是常量，则进行常量折叠优化
				if left.IsConst() && right.IsConst() {
					// 根据操作符执行计算
					switch e.Separator {
					case "-":
						e.Num = left.Num - right.Num
					case "/":
						e.Num = left.Num / right.Num
					case "%":
						e.Num = float64(int(left.Num) % int(right.Num))
					case "^":
						e.Num = math.Pow(left.Num, right.Num)
					case "<<":
						e.Num = float64(int(left.Num) << int(right.Num))
					case ">>":
						e.Num = float64(int(left.Num) >> int(right.Num))
					case "&":
						e.Num = float64(int(left.Num) & int(right.Num))
					case "|":
						e.Num = float64(int(left.Num) | int(right.Num))
					}

					// 根据计算结果设置类型
					if float64(int(e.Num)) == e.Num {
						e.Type = typeSys.GetSystemType("int")
					} else {
						e.Type = typeSys.GetSystemType("f64")
					}

					// 清除操作符和子表达式，将表达式转换为常量
					e.Separator = ""
					e.Left, e.Right = nil, nil
				} else if typeSys.CheckTypeType(left.Type, "float") && typeSys.CheckTypeType(right.Type, "float") {
					// 浮点数运算
					e.Type = typeSys.GetSystemType("f64")
				} else {
					// 整数运算
					e.Type = typeSys.GetSystemType("int")
				}
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
					e.Num = left.Num + right.Num
					if float64(int(e.Num)) == e.Num {
						e.Type = typeSys.GetSystemType("int")
					} else {
						e.Type = typeSys.GetSystemType("f64")
					}
					e.Separator = ""
					e.Left, e.Right = nil, nil
				} else if typeSys.CheckTypeType(left.Type, "float") && typeSys.CheckTypeType(right.Type, "float") {
					e.Type = typeSys.GetSystemType("f64")
				} else {
					e.Type = typeSys.GetSystemType("int")
				}
				return true
			} else if typeSys.CheckType(left.Type, typeSys.GetSystemType("string")) && typeSys.CheckType(right.Type, typeSys.GetSystemType("string")) {
				// 字符串连接
				e.Type = typeSys.GetSystemType("string")
				e.StringVal = left.StringVal + right.StringVal
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
					e.Num = left.Num * right.Num
					if float64(int(e.Num)) == e.Num {
						e.Type = typeSys.GetSystemType("int")
					} else {
						e.Type = typeSys.GetSystemType("f64")
					}
					e.Separator = ""
					e.Left, e.Right = nil, nil
				} else if typeSys.CheckTypeType(left.Type, "float") && typeSys.CheckTypeType(right.Type, "float") {
					e.Type = typeSys.GetSystemType("f64")
				} else {
					e.Type = typeSys.GetSystemType("int")
				}
				return true
			} else if typeSys.CheckType(left.Type, typeSys.GetSystemType("string")) && typeSys.CheckType(left.Type, typeSys.GetSystemType("f64"), typeSys.GetSystemType("int")) {
				// 字符串重复
				e.Type = typeSys.GetSystemType("string")
				e.StringVal = strings.Repeat(left.StringVal, int(right.Num))
				return true
			} else {
				// 类型不匹配
				return false
			}
		case "==", "!=":
			// 相等比较操作符
			if typeSys.GetTypeType(left.Type) == typeSys.GetTypeType(right.Type) {
				e.Type = typeSys.GetSystemType("bool")
				return true
			} else {
				// 类型不匹配
				return false
			}
		case "<", ">", "<=", ">=":
			// 大小比较操作符
			if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
				// 如果左右操作数都是常量，则进行常量折叠优化
				if left.IsConst() && right.IsConst() {
					// 根据操作符计算结果
					switch e.Separator {
					case "<":
						e.Bool = left.Num < right.Num
					case ">":
						e.Bool = left.Num > right.Num
					case "<=":
						e.Bool = left.Num <= right.Num
					case ">=":
						e.Bool = left.Num >= right.Num
					}
					e.Separator = ""
					e.Left, e.Right = nil, nil
				}
				e.Type = typeSys.GetSystemType("bool")
				return true
			} else {
				// 类型不匹配
				return false
			}
		case "&&", "||":
			// 逻辑操作符
			if typeSys.CheckType(left.Type, typeSys.GetSystemType("bool")) && typeSys.CheckType(right.Type, typeSys.GetSystemType("bool")) {
				e.Type = typeSys.GetSystemType("bool")
				if e.Left.IsConst() && e.Right.IsConst() {
					// 常量折叠优化
					if e.Separator == "&&" {
						e.Bool = left.Bool && right.Bool
					} else {
						e.Bool = left.Bool || right.Bool
					}
				}
				return true
			} else {
				// 类型不匹配
				return false
			}
		case "":
			// 空操作符
			return true
		default:
			// 不支持的操作符
			return false
		}
	} else {
		// 没有操作符的情况
		return false
	}
}

// IsConst 判断表达式是否为常量
// 返回:
//   - bool: 是否为常量表达式
func (e *Expression) IsConst() bool {
	// 如果没有变量、函数调用且没有操作符，则为常量
	return e.Var == nil && e.Call == nil && e.Separator == ""
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
	expStartCursor := p.Lexer.Cursor

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
			exp := &Expression{
				StringVal: token.Value,
				Type:      typeSys.GetSystemType("string"),
			}
			stackNum = append(stackNum, exp)
		case lexer.NAME:
			// 标识符
			name := token.Value

			// 如果下一个位置在停止位置之前
			if p.Lexer.Cursor+1 < stopCursor {
				token := p.Lexer.Next()

				// 如果是空词法单元，则报错
				if token.IsEmpty() {
					p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Incomplete expression")
				}

				// 如果是左括号，则解析函数调用
				if token.Type == lexer.SEPARATOR && token.Value == "(" {
					p.Lexer.Back(1)
					call := &CallBlock{
						Name: name,
					}
					call.Parse(p)
					if len(call.Func.Return) != 1 {
						p.Lexer.Error.MissErrors("Invalid expression", expStartCursor, token.Cursor, "Invalid function call, need one return values")
					}
					exp := &Expression{
						Call: call,
						Type: call.Func.Return[0],
					}
					stackNum = append(stackNum, exp)
				} else {
					// 否则解析变量
					p.Lexer.Back(1)
					varBlock := &VarBlock{
						Name: name,
					}
					varBlock.ParseDefine(p)
					var exp *Expression
					switch varBlock.Define.Value.(type) {
					case *VarBlock:
						varBlock.Offset = varBlock.Define.Value.(*VarBlock).Offset
						tmp := varBlock.FindStaticVal(p)
						if tmp != nil {
							tmp.Used = true
						}
						if varBlock.Value != nil {
							exp = varBlock.Value
						} else {
							exp = &Expression{
								Var:  varBlock,
								Type: varBlock.Define.Value.(*VarBlock).Type,
							}
						}
					case *ArgBlock:
						varBlock.Offset = varBlock.Define.Value.(*ArgBlock).Offset
						exp = &Expression{
							Var:  varBlock,
							Type: varBlock.Define.Value.(*ArgBlock).Type,
						}
					}
					stackNum = append(stackNum, exp)
				}
			} else {
				// 解析变量
				varBlock := &VarBlock{
					Name: name,
				}
				varBlock.ParseDefine(p)
				var exp *Expression
				switch varBlock.Define.Value.(type) {
				case *VarBlock:
					varBlock.Offset = varBlock.Define.Value.(*VarBlock).Offset
					tmp := varBlock.FindStaticVal(p)
					if tmp != nil {
						tmp.Used = true
					}
					if varBlock.Value != nil {
						exp = varBlock.Value
					} else {
						exp = &Expression{
							Var:  varBlock,
							Type: varBlock.Define.Value.(*VarBlock).Type,
						}
					}
				case *ArgBlock:
					varBlock.Offset = varBlock.Define.Value.(*ArgBlock).Offset
					exp = &Expression{
						Var:  varBlock,
						Type: varBlock.Define.Value.(*ArgBlock).Type,
					}
				}
				stackNum = append(stackNum, exp)
			}
		case lexer.NUMBER:
			// 数字
			num, err := strconv.ParseFloat(token.Value, 64)
			if err != nil {
				p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, err.Error())
			}
			exp := &Expression{
				Num: num,
			}
			if num == float64(int(num)) {
				exp.Type = typeSys.GetSystemType("int")
			} else {
				exp.Type = typeSys.GetSystemType("f64")
			}
			stackNum = append(stackNum, exp)

			// 如果是负号，则对数值取反
			if nextIsNar {
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
			}
		case lexer.BOOL:
			// 布尔值
			exp := &Expression{
				Bool: token.Value == "true",
				Type: typeSys.GetSystemType("bool"),
			}
			stackNum = append(stackNum, exp)
		default:
			// 其他类型报错
			p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Missing "+token.String())
		}

		// 处理括号和操作符优先级
		if len(stackSep)-len(stackNum) >= 2 {
			if stackSep[len(stackSep)-2].Separator == "(" {
				nextIsNar = true
				stackSep = stackSep[:len(stackSep)-1]
			} else {
				p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Missing "+token.String())
			}
		}

		// 处理操作符优先级和表达式构建
		if len(stackNum) >= 2 && len(stackSep) >= 2 && (token.Type != lexer.SEPARATOR || stackSep[len(stackSep)-1].Separator == ")") {
			if stackNum[len(stackNum)-1].Type == nil || stackNum[len(stackNum)-2] == nil {
				p.Error.MissError("experr", p.Lexer.Cursor, "")
			}

			// 处理右括号
			if stackSep[len(stackSep)-1].Separator == ")" {
				if stackSep[len(stackSep)-2].Separator == "(" {
					stackSep = stackSep[:len(stackSep)-2]
				} else {
					stackSep = stackSep[:len(stackSep)-1]
					num1, num2 := stackNum[len(stackNum)-2], stackNum[len(stackNum)-1]
					stackNum = stackNum[:len(stackNum)-2]
					stackSep[len(stackSep)-1].Left = num2
					stackSep[len(stackSep)-1].Right = num1
					num2.Father = stackSep[len(stackSep)-1]
					num1.Father = stackSep[len(stackSep)-1]
					stackNum = append(stackNum, stackSep[len(stackSep)-1])
					stackSep = stackSep[:len(stackSep)-2]
					if !stackNum[len(stackNum)-1].Check(p) {
						p.Error.MissError("experr", p.Lexer.Cursor, "")
					}
				}
			}

			// 如果操作数或操作符不足，则继续
			if len(stackNum) < 2 && len(stackSep) < 2 {
				continue
			}

			// 如果遇到左括号，则继续
			// 添加对stackSep长度的检查以避免数组越界
			if len(stackSep) >= 2 {
				if stackSep[len(stackSep)-1].Separator == "(" || stackSep[len(stackSep)-2].Separator == "(" {
					continue
				}
			} else if len(stackSep) >= 1 {
				if stackSep[len(stackSep)-1].Separator == "(" {
					continue
				}
			}

			// 获取操作符优先级 (添加长度检查)
			// 只有在有足够的操作符时才进行优先级比较
			if len(stackSep) < 2 {
				// 操作符不足，继续处理下一个token
				continue
			}

			tokenWe := getWe(stackSep[len(stackSep)-1].Separator)
			lastTokenWe := getWe(stackSep[len(stackSep)-2].Separator)

			// 获取两个操作数
			num1, num2 := stackNum[len(stackNum)-2], stackNum[len(stackNum)-1]
			stackNum = stackNum[:len(stackNum)-2]

			// 根据优先级构建表达式树
			if tokenWe > lastTokenWe {
				stackSep[len(stackSep)-1].Left = num1
				stackSep[len(stackSep)-1].Right = num2
				num1.Father = stackSep[len(stackSep)-1]
				num2.Father = stackSep[len(stackSep)-1]
				stackNum = append(stackNum, stackSep[len(stackSep)-1])
				if !stackNum[len(stackNum)-1].Check(p) {
					p.Error.MissError("experr", p.Lexer.Cursor, "")
				}
			} else {
				stackSep[len(stackSep)-2].Left = stackNum[len(stackNum)-1]
				stackSep[len(stackSep)-2].Right = num1
				stackNum[len(stackNum)-1].Father = stackSep[len(stackSep)-2]
				num1.Father = stackSep[len(stackSep)-2]
				stackNum = stackNum[:len(stackNum)-1]
				stackNum = append(stackNum, stackSep[len(stackSep)-2], num2)
				stackSep[len(stackSep)-2] = stackSep[len(stackSep)-1]
				if !stackNum[len(stackNum)-2].Check(p) {
					p.Error.MissError("experr", p.Lexer.Cursor, "")
				}
			}
			stackSep = stackSep[:len(stackSep)-1]
		}
	}

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
		if !stackNum[0].Check(p) {
			p.Error.MissError("experr", p.Lexer.Cursor, "")
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
		stackNum[len(stackNum)-1].Check(p)
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
func (e *Expression) FindVar(v Block) bool {
	// 在当前表达式的变量中查找
	var vd Block
	if e.Var != nil {
		if e.Var.Define != nil {
			vd = e.Var.Define.Value
		} else {
			vd = e.Var
		}
		if vd == v {
			return true
		}
	}

	// 在右子表达式中递归查找
	if e.Right != nil && e.Right.FindVar(v) {
		return true
	}

	// 在左子表达式中递归查找
	if e.Left != nil && e.Left.FindVar(v) {
		return true
	}

	// 没有找到
	return false
}

// Print 打印表达式（用于调试）
func (e *Expression) Print() {
	// 先打印左子表达式
	if e.Left != nil {
		e.Left.Print()
	}

	// 再打印右子表达式
	if e.Right != nil {
		e.Right.Print()
	}

	// 打印当前节点
	if e.Separator != "" {
		fmt.Print(e.Separator)
	} else {
		if e.Var != nil {
			fmt.Print(e.Var.Name)
		} else if e.Call != nil {
			fmt.Print(e.Call.Name)
		} else if e.StringVal != "" {
			fmt.Print("\"" + e.StringVal + "\"")
		} else if e.Type == typeSys.GetSystemType("bool") {
			if e.Bool {
				fmt.Print("true")
			} else {
				fmt.Print("false")
			}
		} else {
			fmt.Print(e.Num)
		}
	}

	// 如果是根节点，则换行
	if e.Father == nil {
		fmt.Print("\n")
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
