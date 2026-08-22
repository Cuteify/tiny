package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"cuteify/utils"
	"fmt"
	"strconv"
)

// Expression 表示表达式AST节点
type Expression struct {
	Call      *CallBlock     // 函数调用块，非nil时表示调用表达式
	Num       float64        // 数值常量（整数和浮点数统一用float64存储）
	Separator string         // 运算符
	Right     *Expression    // 右操作数（二元运算的右子、一元运算的唯一子节点）
	Left      *Expression    // 左操作数（二元运算的左子）
	Father    *Expression    // 父表达式节点，用于向上遍历
	Var       *VarBlock      // 变量引用，非nil时表示变量表达式
	StringVal string         // 字符串常量值
	Bool      bool           // 布尔常量值
	ConstBool bool           // 是否为常量布尔（当前未使用，预留）
	Type      typeSys.Type   // 表达式的数据类型，由Check阶段推导
	checked   bool           // 是否已通过语义检查，防止重复检查
	Index     [3]*Expression // 列表索引
	ListElems []*Expression  // 列表字面量元素，Separator="list_lit"时有效
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
	if typeSys.CheckType(exp.Type, typeSys.GetSystemType("bool")) {
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

func (e *Expression) Insert(exp *Expression) {
	e.Right = exp
	exp.Father = e
}

func (e *Expression) SetLeft(exp *Expression) {
	e.Left = exp
	exp.Father = e
}

func (e *Expression) BeParent(exp *Expression) {
	if e.Father != nil {
		e.Father.Right = exp
	}
	e.Father = exp
	exp.Left = e
}

// opTable 运算符优先级表
var opTable = map[string]int{
	"=":  0,
	"||": 1,
	"&&": 2,
	"==": 3,
	"!=": 3,
	"<":  4,
	">":  4,
	"<=": 4,
	">=": 4,
	"|":  5,
	"^":  6,
	"&":  7,
	"~":  8,
	"!":  8,
	"<<": 9,
	">>": 9,
	"+":  10,
	"-":  10,
	"*":  11,
	"/":  11,
	"%":  11,
	"[]": 100,
	// 复合赋值运算符
	"+=":  12,
	"-=":  12,
	"*=":  12,
	"/=":  12,
	"%=":  12,
	"^=":  12,
	"&=":  12,
	"|=":  12,
	"<<=": 12,
	">>=": 12,
	// 自增自减运算符
	"++": 13,
	"--": 13,
}

// opMethodMap 二元运算符到结构体方法名的映射，用于运算符重载解析。
// 当左操作数是自定义类型时，编译器会查找 TypeName.methodName 方法。
var opMethodMap = map[string]string{
	"+":    "add",
	"-":    "sub",
	"*":    "mul",
	"/":    "div",
	"%":    "mod",
	"^":    "pow",
	"==":   "eq",
	"!=":   "ne",
	"<":    "lt",
	">":    "gt",
	"<=":   "le",
	">=":   "ge",
	"&":    "band",
	"|":    "bor",
	"<<":   "shl",
	">>":   "shr",
	"[]":   "get",
	"[]=":  "set",
	"[::]": "slice",
}

// unaryOpMethodMap 一元运算符到结构体方法名的映射，用于运算符重载解析。
var unaryOpMethodMap = map[string]string{
	"-": "neg",
	"!": "not",
	"~": "bnot",
}

// IsConst 判断表达式是否为编译期常量。条件：无变量引用、无函数调用、
func (exp *Expression) IsConst() bool {
	return exp.Var == nil && exp.Call == nil && exp.Separator == ""
}

func (p *Parser) ParseExp(stopCursor int) *Expression {
	if p.Lexer.Cursor >= stopCursor {
		return nil
	}

	// 迭代变量
	var root, current *Expression
	justEnterBracket := false
	justClosedBracket := false
	var bracketRoot *Expression
	var bracketStack []*Expression // 括号外层的 current
	var rootStack []*Expression    // 括号前的外层 root
	bracketCount := 0

	// 迭代解析表达式
	for p.Lexer.Cursor < stopCursor {
		exp := p.getExp(stopCursor)

		if exp == nil {
			break
		}

		if exp.Separator == "(" {
			bracketCount++
			bracketStack = append(bracketStack, current)
			rootStack = append(rootStack, root)
			// 括号内独立解析：current 与 root 从头开始
			current = nil
			root = nil
			justEnterBracket = true
			justClosedBracket = false
			continue
		}

		if exp.Separator == ")" {
			if bracketCount <= 0 {
				p.Error.MissError("Expression Error", p.Lexer.Cursor, "expected ')'")
				return nil
			}
			if current == nil {
				p.Error.MissError("Expression Error", p.Lexer.Cursor, "empty parentheses")
				return nil
			}
			bracketCount--
			outer := bracketStack[len(bracketStack)-1]
			bracketStack = bracketStack[:len(bracketStack)-1]
			savedRoot := rootStack[len(rootStack)-1]
			rootStack = rootStack[:len(rootStack)-1]

			// 定位括号根：向上走到 Father 为 nil 或等于括号外层节点
			for current.Father != nil && current.Father != outer {
				current = current.Father
			}
			bracketRoot = current
			if outer != nil && bracketRoot.Father == nil {
				// 括号内容作为整体挂到外层节点上
				outer.Insert(bracketRoot)
				current = outer
				root = savedRoot
			} else {
				// 括号根独立（或已挂在外层），当前指向括号根
				current = bracketRoot
				root = bracketRoot
			}
			justClosedBracket = true
			justEnterBracket = false
			continue
		}

		if root == nil {
			if exp.Separator == "[" {
				// Check if this is a Go-style list literal []type{...}
				if p.isListLitAfterBracket() {
					exp = p.handleListLit()
					if exp == nil {
						return nil
					}
				} else {
					// Bare '[' at start of expression is invalid
					p.Error.MissError("Expression Error", p.Lexer.Cursor, "unexpected '['")
					return nil
				}
			}
			root = exp
			current = root
			continue
		}

		isRoot := current == root

		if exp.Separator == "[" {
			// Check if this is a list literal (when current needs a right operand)
			if current.Separator != "" && current.Right == nil {
				if p.isListLitAfterBracket() {
					exp = p.handleListLit()
					if exp == nil {
						return nil
					}
					current.Insert(exp)
					continue
				}
			}
			exp = p.handleIndex()
			// 插入
			if current.Separator == "" || current.Separator == "[]" {
				// 当前节点不是运算符，需要把当前节点插入到exp的右子节点，然后把exp作为当前节点
				// 相当于BeParent反过来的操作
				exp.Insert(current)
				if isRoot {
					root = exp
				}
				current = exp
			} else {
				if current.Right == nil {
					if current.Left == nil {
						p.Error.MissError("Expression Error", p.Lexer.Cursor, "expected left operand")
						return nil
					}
					exp.Insert(current.Left)
					current.SetLeft(exp)
				} else {
					// 需要把原本的右子节点作为exp的右子节点
					exp.Insert(current.Right)
					// 把原本右子节点换位exp
					current.Insert(exp)
				}
			}
			continue
		}
		if current.Separator != "" && exp.Separator != "" {
			if justClosedBracket {
				// 刚关闭括号：括号根作为整体操作数参与运算。
				// 若括号根挂在外部节点上（如 a-(b+c)*d），运算符取代其在父节点的位置；
				// 若括号根独立（如 (a+b)*c、(x-y)/z），运算符成为其父（上溯 + BeParent）。
				if bracketRoot != nil && bracketRoot.Father != nil {
					father := bracketRoot.Father
					exp.SetLeft(bracketRoot)
					father.Insert(exp)
				} else {
					for current.Father != nil && opTable[current.Father.Separator] >= opTable[exp.Separator] {
						current = current.Father
					}
					current.BeParent(exp)
				}
				justClosedBracket = false
				justEnterBracket = false
				current = exp
				if current.Right == root || current.Left == root {
					root = current
				}
				continue
			}
			// 如果括号是根节点，应该把括号的优先级做到最高
			if (opTable[current.Separator] < opTable[exp.Separator] || justEnterBracket) && current.Left != nil {
				// 等价于BeParent，但是无法确定Right是否存在，所以手动处理
				if current.Right != nil {
					exp.SetLeft(current.Right)
				}
				current.Insert(exp)
			} else if current.Right == nil {
				current.Insert(exp) // 二元后跟随一元运算符的情况
			} else {
				// 左结合：新运算符优先级不高于当前链时，上溯到优先级更低（或根）的祖先处挂接，
				// 避免 `a*b + c/d - e/f + g` 这类链式运算被错误归组为 `a*b + (c/d - (e/f + g))`
				for current.Father != nil && opTable[current.Father.Separator] >= opTable[exp.Separator] {
					current = current.Father
				}
				current.BeParent(exp)
			}
			justEnterBracket = false // 增加进入括号的计数
			// TODO：错误返回导致ROOT被覆盖
			current = exp
		} else if current.Separator == "" && exp.Separator != "" {
			// ++ and -- after a value are postfix operators (no right operand needed)
			if exp.Separator == "++" || exp.Separator == "--" {
				exp.SetLeft(current)
				current = exp
				// Don't expect right operand, continue to next token
				if isRoot && current.Father == root {
					root = current
				}
				continue
			}
			exp.SetLeft(current)     // 把当前节点插入到exp的左子节点
			current = exp            // 把exp作为当前节点
			justEnterBracket = false // 增加进入括号的计数
		} else if current.Separator != "" && exp.Separator == "" {
			current.Insert(exp)
		} else {
			p.Error.MissError("Expression Error", p.Lexer.Cursor, "unexpected token: "+utils.MakeVisible(exp.Separator))
			return nil
		}
		if current.Right == root || current.Left == root {
			root = current
		}
	}

	// 表达式完整性检查
	if bracketCount != 0 {
		p.Error.MissError("Expression Error", p.Lexer.Cursor, "expected ')'")
		return nil
	}

	if current != nil && current.Separator != "" && current.Right == nil {
		// ++, -- can be postfix; list_lit is a complete literal
		if current.Separator != "++" && current.Separator != "--" && current.Separator != "list_lit" {
			p.Error.MissError("Expression Error", p.Lexer.Cursor, "expected right operand")
			return nil
		}
	}

	return root
}

func (p *Parser) getExp(stopCursor int) *Expression {
	code := p.Lexer.Next()
	if code.IsEmpty() {
		return nil
	}

	if p.Lexer.Cursor > stopCursor {
		p.Lexer.SetCursor(code.Cursor)
		return nil
	}

	switch code.Type {
	case lexer.NUMBER:
		num, err := strconv.ParseFloat(code.Value, 64)
		if err != nil {
			p.Error.MissError("Expression Error", p.Lexer.Cursor, err.Error())
			return nil
		}
		exp := &Expression{Num: num}
		if exp.Num == float64(int(exp.Num)) {
			exp.Type = typeSys.GetSystemType("int")
		} else {
			exp.Type = typeSys.GetSystemType("f64")
		}
		return exp

	case lexer.STRING, lexer.CHAR, lexer.RAW:
		return &Expression{
			StringVal: code.Value,
			Type:      typeSys.GetSystemType("string"),
		}

	case lexer.BOOL:
		return &Expression{
			ConstBool: true,
			Bool:      code.Value == "true",
			Type:      typeSys.GetSystemType("bool"),
		}

	case lexer.NAME:
		p.Lexer.SetCursor(code.Cursor)
		return p.handleName()
	case lexer.SEPARATOR:
		if code.Value == "\n" || code.Value == ";" || code.Value == "\r" {
			p.Lexer.SetCursor(code.Cursor)
			return nil
		}
		return &Expression{Separator: code.Value}
	}

	p.Error.MissError("Expression Error", code.Cursor, "unexpected token: "+code.Value)
	return nil
}

func (p *Parser) handleName() *Expression {
	nameStart := p.Lexer.Cursor
	name, _ := p.ParseName(false)
	exp := &Expression{}

	// 尝试匹配(
	token := p.Lexer.Next()
	p.Lexer.SetCursor(token.Cursor)
	if token.Type == lexer.SEPARATOR {
		switch token.Value {
		case "(":
			callBlock := &CallBlock{Name: name}
			if name.String() == "new" {
				callBlock.ParseNew(p)
			} else {
				callBlock.ParseCall(p)
			}
			exp.Call = callBlock
			if callBlock.NewType != nil {
				exp.Type = typeSys.MakePointer(callBlock.NewType)
			}
			return exp
		case "=", ":=", "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>=", "++", "--":
			// 在解引用语句（*p = v）中，"=" 必须留在表达式树中作为运算符
			if p.PreventNameAssign && token.Value == "=" {
				p.Lexer.SetCursor(token.Cursor)
				break
			}
			block := &VarBlock{}
			// 把指针放到name之前
			p.Lexer.SetCursor(nameStart)
			block.ParseVar(p)
			exp.Var = block
			p.AddChild(&Node{Value: block, Ignore: true})
			return exp
		}
	}

	// 写入变量引用
	exp.Var = &VarBlock{Name: name}
	exp.Var.ParseDefine(p)
	return exp
}

func (p *Parser) handleIndex() *Expression {
	// 状态机解析 [start:end:step]
	index := [3]*Expression{}
	state := 0 // 0=start, 1=end, 2=step
	bracketDepth := 1
	// startCursor tracks the start of the current expression within brackets
	// Cursor is already past '[' when handleIndex is called
	startCursor := p.Lexer.Cursor

	for bracketDepth > 0 {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Expression Error", p.Lexer.Cursor, "expected ']'")
			return nil
		}

		if token.Type == lexer.SEPARATOR {
			switch token.Value {
			case "[":
				bracketDepth++
				continue
			case "]":
				bracketDepth--
				if bracketDepth == 0 {
					// 解析最后一个表达式（如果有）
					if startCursor < token.Cursor {
						p.Lexer.SetCursor(startCursor)
						exp := p.ParseExp(token.Cursor)
						if exp != nil {
							index[state] = exp
						}
					}
					// Advance cursor past the closing ']'
					p.Lexer.SetCursor(token.EndCursor)
					return &Expression{
						Separator: "[]",
						Index:     index,
					}
				}
				continue
			case ":":
				if bracketDepth == 1 {
					if startCursor < token.Cursor {
						p.Lexer.SetCursor(startCursor)
						exp := p.ParseExp(token.Cursor)
						if exp != nil {
							index[state] = exp
						}
					}
					state++
					if state > 2 {
						p.Error.MissError("Expression Error", p.Lexer.Cursor, "too many ':' in index")
						return nil
					}
					// 跳过 ':'，推进游标避免重复读取
					p.Lexer.SetCursor(token.EndCursor)
					startCursor = p.Lexer.Cursor
					continue
				}
			}
		}
	}

	return &Expression{
		Separator: "[]",
		Index:     index,
	}
}

// isListLitAfterBracket checks if we're at a Go-style list literal `[]type{...}`.
// Assumes cursor is positioned AFTER the opening `[` (already consumed).
// Returns true if next tokens are `]` then a type name then `{`.
func (p *Parser) isListLitAfterBracket() bool {
	savedCursor := p.Lexer.Cursor

	// Must be `]`
	next := p.Lexer.Next()
	if next.Type != lexer.SEPARATOR || next.Value != "]" {
		p.Lexer.SetCursor(savedCursor)
		return false
	}

	// Must be followed by a type name
	peek := p.Lexer.Next()
	if peek.Type != lexer.NAME && !(peek.Type == lexer.SEPARATOR && peek.Value == "*") {
		p.Lexer.SetCursor(savedCursor)
		return false
	}

	// Must be followed by `{`
	after := p.Lexer.Next()
	if after.Type != lexer.SEPARATOR || after.Value != "{" {
		p.Lexer.SetCursor(savedCursor)
		return false
	}

	p.Lexer.SetCursor(savedCursor)
	return true
}

func (p *Parser) handleListLit() *Expression {
	// Parse []type{elem1, elem2, ...}
	// Cursor is positioned after the opening '[' (already consumed by getExp)

	// Consume "]"
	token := p.Lexer.Next()
	if token.Type != lexer.SEPARATOR || token.Value != "]" {
		p.Error.MissError("Expression Error", p.Lexer.Cursor, "expected ']'")
		return nil
	}

	// Parse type annotation
	elemType := p.parseTypeAnnotation()
	if elemType == nil {
		p.Error.MissError("Expression Error", p.Lexer.Cursor, "expected type after ']'")
		return nil
	}

	// Consume "{"
	token = p.Lexer.Next()
	if token.Type != lexer.SEPARATOR || token.Value != "{" {
		p.Error.MissError("Expression Error", p.Lexer.Cursor, "expected '{'")
		return nil
	}

	// Parse {elem1, elem2, ...}
	elems := p.parseBraceList()
	if elems == nil {
		return nil
	}

	return &Expression{
		Separator: "list_lit",
		ListElems: elems,
		Type:      typeSys.NewList(elemType),
	}
}

// parseBraceList parses {elem1, elem2, ...} and returns the list of expressions
func (p *Parser) parseBraceList() []*Expression {
	elems := []*Expression{}
	braceDepth := 1
	startCursor := p.Lexer.Cursor

	for braceDepth > 0 {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Expression Error", p.Lexer.Cursor, "expected '}'")
			return nil
		}

		if token.Type == lexer.SEPARATOR {
			switch token.Value {
			case "{":
				braceDepth++
				continue
			case "}":
				braceDepth--
				if braceDepth == 0 {
					// Parse last element if any
					if startCursor < token.Cursor {
						p.Lexer.SetCursor(startCursor)
						exp := p.ParseExp(token.Cursor)
						if exp != nil {
							elems = append(elems, exp)
						}
					}
					p.Lexer.SetCursor(token.Cursor + 1)
					return elems
				}
				continue
			case ",":
				if braceDepth == 1 {
					if startCursor < token.Cursor {
						p.Lexer.SetCursor(startCursor)
						exp := p.ParseExp(token.Cursor)
						if exp != nil {
							elems = append(elems, exp)
						}
					}
					startCursor = p.Lexer.Cursor
					continue
				}
			}
		}
	}

	return elems
}
