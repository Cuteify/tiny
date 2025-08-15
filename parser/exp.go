package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"fmt"
	"math"
	"strconv"
	"strings"
)

type Expression struct {
	Call      *CallBlock
	Num       float64
	Separator string
	Right     *Expression
	Left      *Expression
	Father    *Expression
	Var       *VarBlock
	StringVal string
	Bool      bool
	ConstBool bool
	Type      typeSys.Type
}

func (e *Expression) Check() bool {
	if e.Separator != "" {
		if e.Left == nil || e.Right == nil {
			return false
		}
		left, right := e.Left, e.Right
		if !left.Check() || !right.Check() {
			return false
		}
		switch e.Separator {
		case "-", "/", "%", "^", "<<", ">>", "&", "|":
			if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
				if left.IsConst() && right.IsConst() {
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
			} else {
				return false
			}
		case "+":
			if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
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
				e.Type = typeSys.GetSystemType("string")
				e.StringVal = left.StringVal + right.StringVal
				return true
			} else {
				return false
			}
		case "*":
			if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
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
				e.Type = typeSys.GetSystemType("string")
				e.StringVal = strings.Repeat(left.StringVal, int(right.Num))
				return true
			} else {
				return false
			}
		case "==", "!=":
			if typeSys.GetTypeType(left.Type) == typeSys.GetTypeType(right.Type) {
				e.Type = typeSys.GetSystemType("bool")
				return true
			} else {
				return false
			}
		case "<", ">", "<=", ">=":
			if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
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
				return false
			}
		case "&&", "||":
			if typeSys.CheckType(left.Type, typeSys.GetSystemType("bool")) && typeSys.CheckType(right.Type, typeSys.GetSystemType("bool")) {
				e.Type = typeSys.GetSystemType("bool")
				if e.Left.IsConst() && e.Right.IsConst() {
					if e.Separator == "&&" {
						e.Bool = left.Bool && right.Bool
					} else {
						e.Bool = left.Bool || right.Bool
					}
				}
				return true
			} else {
				return false
			}
		case "":
			return true
		default:
			return false
		}
	} else {
		return false
	}

}
func (e *Expression) IsConst() bool {
	return e.Var == nil && e.Call == nil && e.Separator == ""
}

func (p *Parser) ParseExpression(stopCursor int) *Expression {
	stackNum := []*Expression{}
	stackSep := []*Expression{}
	expStartCursor := p.Lexer.Cursor
	nextIsNar := false
	if p.Lexer.Cursor == stopCursor {
		return nil
	}
	for p.Lexer.Cursor < stopCursor {
		token := p.Lexer.Next()
		switch token.Type {
		case lexer.LexTokenType["SEPARATOR"]:
			stackSep = append(stackSep, &Expression{
				Separator: token.Value,
			})
		case lexer.LexTokenType["STRING"], lexer.LexTokenType["CHAR"], lexer.LexTokenType["RAW"]:
			exp := &Expression{
				StringVal: token.Value,
				Type:      typeSys.GetSystemType("string"),
			}
			stackNum = append(stackNum, exp)
		case lexer.LexTokenType["NAME"]:
			name := token.Value
			if p.Lexer.Cursor+1 < stopCursor {
				token := p.Lexer.Next()
				if token.IsEmpty() {
					p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Incomplete expression")
				}
				if token.Type == lexer.LexTokenType["SEPARATOR"] && token.Value == "(" {
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
		case lexer.LexTokenType["NUMBER"]:
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
		case lexer.LexTokenType["BOOL"]:
			exp := &Expression{
				Bool: token.Value == "true",
				Type: typeSys.GetSystemType("bool"),
			}
			stackNum = append(stackNum, exp)
		default:
			p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Missing "+token.String())
		}
		if len(stackSep)-len(stackNum) >= 2 {
			if stackSep[len(stackSep)-2].Separator == "(" {
				nextIsNar = true
				stackSep = stackSep[:len(stackSep)-1]
			} else {
				p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Missing "+token.String())
			}
		}
		if len(stackNum) >= 2 && len(stackSep) >= 2 && (token.Type != lexer.LexTokenType["SEPARATOR"] || stackSep[len(stackSep)-1].Separator == ")") {
			if stackNum[len(stackNum)-1].Type == nil || stackNum[len(stackNum)-2] == nil {
				p.Error.MissError("experr", p.Lexer.Cursor, "")
			}
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
				}
			}
			if len(stackNum) < 2 && len(stackSep) < 2 {
				continue
			}
			if stackSep[len(stackSep)-1].Separator == "(" || stackSep[len(stackSep)-2].Separator == "(" {
				continue
			}
			tokenWe := getWe(stackSep[len(stackSep)-1].Separator)
			lastTokenWe := getWe(stackSep[len(stackSep)-2].Separator)
			num1, num2 := stackNum[len(stackNum)-2], stackNum[len(stackNum)-1]
			stackNum = stackNum[:len(stackNum)-2]
			if tokenWe > lastTokenWe {
				stackSep[len(stackSep)-1].Left = num1
				stackSep[len(stackSep)-1].Right = num2
				num1.Father = stackSep[len(stackSep)-1]
				num2.Father = stackSep[len(stackSep)-1]
				stackNum = append(stackNum, stackSep[len(stackSep)-1])
			} else {
				stackSep[len(stackSep)-2].Left = stackNum[len(stackNum)-1]
				stackSep[len(stackSep)-2].Right = num1
				stackNum[len(stackNum)-1].Father = stackSep[len(stackSep)-2]
				num1.Father = stackSep[len(stackSep)-2]
				stackNum = stackNum[:len(stackNum)-1]
				stackNum = append(stackNum, stackSep[len(stackSep)-2], num2)
				stackSep[len(stackSep)-2] = stackSep[len(stackSep)-1]
			}
			stackSep = stackSep[:len(stackSep)-1]
		}
	}
	if len(stackNum) == 2 && len(stackSep) == 1 {
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
	}
	if len(stackNum) == 0 {
		return nil
	}
	return stackNum[0]
}

func (e *Expression) Print() {
	if e.Left != nil {
		e.Left.Print()
	}
	if e.Right != nil {
		e.Right.Print()
	}
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
	if e.Father == nil {
		fmt.Print("\n")
	}
}

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
