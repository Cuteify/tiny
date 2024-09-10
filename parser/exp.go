package parser

import (
    "fmt"
    "future/lexer"
    typeSys "future/type"
    "math"
    "strconv"
    "strings"
)

type Expression struct {
    Call *CallBlock
    Num float64
    Separator string
    Right *Expression
    Left *Expression
    Father *Expression
    Var *VarBlock
    StringVal string
    Bool bool
    Type typeSys.Type
}

func (e *Expression) Check(p *Parser) (ok bool) {
    if e.Separator != "" {
        if e.Separator != "" && i-2 < 0 {
            ok = false
            return
        }
        left, right := e.Left, e.Right
        switch e.Separator {
            case "-",
                "/",
                "%",
                "^",
                "<<",
                ">>",
                "&",
                "|":
                if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
                    if left.IsConst() && right.IsConst() {
                        switch e.Separator {
                        case "-":
                            child.Num = left.Num - right.Num
                        case "/":
                            child.Num = left.Num / right.Num
                        case "%":
                            child.Num = float64(int(left.Num) % int(right.Num))
                        case "^":
                            child.Num = math.Pow(left.Num, right.Num)
                        case "<<":
                            child.Num = float64(int(left.Num) << int(right.Num))
                        case ">>":
                            child.Num = float64(int(left.Num) >> int(right.Num))
                        case "&":
                            child.Num = float64(int(left.Num) & int(right.Num))
                        case "|":
                            child.Num = float64(int(left.Num) | int(right.Num))
                        }
                        if float64(int(child.Num)) == child.Num {
                            child.Type = typeSys.GetSystemType("int")
                        } else {
                            child.Type = typeSys.GetSystemType("f64")
                        }
                        e.Separator = ""
                        e.Left, e.Right = nil, nil
                    } else if typeSys.CheckTypeType(left.Type, "float") && typeSys.CheckTypeType(right.Type, "float") {
                        child.Type = typeSys.GetSystemType("int")
                    } else {
                        child.Type = typeSys.GetSystemType("f64")
                    }
                } else {
                    ok = false
                    return
                }
            case "+":
                if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
                    if left.IsConst() && right.IsConst() {
                        child.Num = left.Num + right.Num
                        child.Type = typeSys.GetSystemType("int")
                    } else {
                        child.Type = typeSys.GetSystemType("f64")
                    }
                    e.Separator = ""
                    e.Left, e.Right = nil, nil
                } else if typeSys.CheckType(left.Type, typeSys.GetSystemType("f64")) && typeSys.CheckType(right.Type, typeSys.GetSystemType("f64")) {
                    child.Type = typeSys.GetSystemType("int")
                } else {
                    child.Type = typeSys.GetSystemType("f64")
                }
        } else if typeSys.CheckType(left.Type, typeSys.GetSystemType("string")) && typeSys.CheckType(right.Type, typeSys.GetSystemType("string")) {
            child.Type = typeSys.GetSystemType("string")
            child.StringVal = left.StringVal + right.StringVal
        } else {
            ok = false
            return
        }
    case "*":
        if typeSys.CheckTypeType(left.Type, "uint", "int", "float") && typeSys.CheckTypeType(right.Type, "uint", "int", "float") {
            if left.IsConst() && right.IsConst() {
                child.Num = left.Num * right.Num
                if float64(int(child.Num)) == child.Num {
                    child.Type = typeSys.GetSystemType("int")
                } else {
                    child.Type = typeSys.GetSystemType("f64")
                }
                e.Separator = ""
                e.Left, e.Right = nil, nil
            } else if typeSys.CheckType(left.Type, typeSys.GetSystemType("f64")) && typeSys.CheckType(right.Type, typeSys.GetSystemType("f64")) {
                child.Type = typeSys.GetSystemType("int")
            } else {
                child.Type = typeSys.GetSystemType("f64")
            }
        } else if typeSys.CheckType(left.Type, typeSys.GetSystemType("string")) && typeSys.CheckType(left.Type, typeSys.GetSystemType("f64"), typeSys.GetSystemType("int")) {
            child.Type = typeSys.GetSystemType("string")
            child.StringVal = strings.Repeat(left.StringVal, int(right.Num))
        } else {
            ok = false
            return
        }
    case "==",
        "!=",
        "<",
        ">",
        "<=",
        ">=":
        if typeSys.GetTypeType(left.Type) == typeSys.GetTypeType(right.Type) {
            child.Type = typeSys.GetSystemType("bool")
        } else {
            ok = false
            return
        }
        continue
    case "&&",
        "||":
        if typeSys.CheckType(left.Type, typeSys.GetSystemType("bool")) && typeSys.CheckType(right.Type, typeSys.GetSystemType("bool")) {
            child.Type = typeSys.GetSystemType("bool")
            if e.Separator == "&&" {
                child.Bool = left.Bool && right.Bool
            } else {
                child.Bool = left.Bool || right.Bool
            }
        } else {
            ok = false
            return
        }
        continue
    case "":
        continue
    default:
        ok = false
        return
    } else {
        ok = false
    }

    return
}

func (e *Expression) IsConst() bool {
    return e.Father != nil && e.Var == nil && e.Call == nil && e.Separator == ""
}

/*func (e *Expression) Print(p *Parser) {
	if e.Check(p) {
		fmt.Print("\033[32m[TRUE]\033[0m ")
	} else {
		fmt.Print("\033[31m[FALSE]\033[0m ")
	}
	if e.Father == nil {
		fmt.Print("[")
		for i := 0; i < len(e.Children); i++ {
			child := e.Children[i]
			fmt.Print(child)
			if i != len(e.Children)-1 {
				fmt.Print(", ")
			}
		}
		fmt.Println("]")
	}
}*/

func (p *Parser) ParseExpression(stopCursor int) *Expression {
    stackNum: = []*Expression{}
    stackSep: = []*Expression{}
    for p.Lexer.Cursor <= stopCursor {
        token: = p.Lexer.Next()
        switch token.Type {
        case lexer.LexTokenType["SEPARATOR"]:
            if len(stackSep) == 0 {
                stackSep: = append(stackSep, &Expression {
                    Separator: token.Value
                })
                continue
            }
            tokenWe: = getWe(token.Value)
            lastTokenWe: = getWe(stackSep[len(stackSep)-1])
            if len(stackNum) < 2 || stackNum[len(stackNum)-1].Type == nil || stackNum[len(stackNum)-2] == nil {
                p.Error.MissError("experr", p.Lexer.Cursor, "")
            }
            num1,
            num2: = stackNum[len(stackNum)-2],
            stackNum[len(stackNum)-1]
            stackNum = stackNum[: len(stackNum)-2]
            if tokenWe > lastTokenWe {
                stackNum = append(stackNum, &Expression {
                    Separator: token.Value,
                    Left: num1,
                    Right: num2,
                })
                if 
            } else {
                stackNum = append(stackNum, stackSep[len(stackSep)-1])
                stackSep[len(stackSep)-1] = &Expression {
                    Separator: token.Value,
                    Left: num1,
                    Right: num2,
                }
            }
        case lexer.LexTokenType["STRING"],
            lexer.LexTokenType["CHAR"],
            lexer.LexTokenType["RAW"]:
            exp: = &Expression {
                StringVal: token.Value,
                Type: typeSys.GetSystemType("string"),
            }
            stackNum = append(stackNum, exp)
        case lexer.LexTokenType["NAME"]:
            name: = token.Value
            if p.Lexer.Cursor+1 < stopCursor {
                token: = p.Lexer.Next()
                if token.IsEmpty() {
                    p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Incomplete expression")
                }
                if token.Type == lexer.LexTokenType["SEPARATOR"] && token.Value == "(" {
                    p.Lexer.Back(1)
                    call: = &CallBlock {
                        Name: name,
                    }
                    call.Parse(p)
                    if len(call.Func.Return) != 1 {
                        p.Lexer.Error.MissErrors("Invalid expression", expStartCursor, token.Cursor, "Invalid function call, need one return values")
                    }
                    exp: = &Expression {
                        Call: call,
                        Type: call.Func.Return[0],
                    }
                    stackNum = append(stackNum, exp)
                } else {
                    p.Lexer.Back(1)
                    varBlock: = &VarBlock {
                        Name: name,
                    }
                    varBlock.ParseDefine(p)
                    varBlock.Type = varBlock.Define.Value.(*VarBlock).Type
                    exp: = &Expression {
                        Var: varBlock,
                        Type: varBlock.Define.Value.(*VarBlock).Type,
                    }
                    stackNum = append(stackNum, exp)
                }
            } else {
                varBlock: = &VarBlock {
                    Name: name,
                }
                varBlock.ParseDefine(p)
                varBlock.Type = varBlock.Define.Value.(*VarBlock).Type
                exp: = &Expression {
                    Var: varBlock,
                    Type: varBlock.Define.Value.(*VarBlock).Type,
                }
                stackNum = append(stackNum, exp)
            }
        case lexer.LexTokenType["NUMBER"]:
            num, err: = strconv.ParseFloat(token.Value, 64)
            if err != nil {
                p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, err.Error())
            }
            exp: = &Expression {
                Num: num,
            }
            if num == float64(int(num)) {
                exp.Type = typeSys.GetSystemType("int")
            } else {
                exp.Type = typeSys.GetSystemType("f64")
            }
            stackNum = append(stackNum, exp)
        case lexer.LexTokenType["BOOL"]:
            exp: = &Expression {
                Bool: token.Value == "true",
                Type: typeSys.GetSystemType("bool"),
            }
            stackNum = append(stackNum, exp)
        default:
            p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Missing "+token.String())
        }
    }
    return stackNum[0]
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
}

func (e *Expression) Print(level int) {
    if e == nil {
        return
    }

    indent: = strings.Repeat("  ", level)
    fmt.Printf("%s", indent)

    switch {
    case e.Separator != "":
        fmt.Printf("Operator: %s\n", e.Separator)
    case e.StringVal != "":
        fmt.Printf("String: %s, Type: %s\n", e.StringVal, e.Type.Type())
    case e.Num != 0:
        fmt.Printf("Number: %f, Type: %s\n", e.Num, e.Type.Type())
    case e.Bool:
        fmt.Printf("Bool: true, Type: %s\n", e.Type.Type())
    case e.Var != nil:
        fmt.Printf("Variable: %s, Type: %s\n", e.Var.Name, e.Type.Type())
    case e.Call != nil:
        fmt.Printf("Function Call: %s, Type: %s\n", e.Call.Name, e.Type.Type())
    default:
        fmt.Println("Unknown node")
    }
}
