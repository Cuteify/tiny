package parser

import (
	errorUtil "cuteify/error"
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
	typeSys "cuteify/type"
	"os"
	"strings"
)

type Parser struct {
	Block             *Node
	ThisBlock         *Node
	Lexer             *lexer.Lexer
	BracketsNum       int
	Error             *errorUtil.Error
	Package           *packageFmt.Info
	DontBack          int
	PreventNameAssign bool
	CurStructName     string       // 当前正在解析的结构体名（支持自引用字段 *T）
	CurStructType     typeSys.Type // 当前正在解析的结构体类型实例（与注册后同一实例）
}

// Next 解析下一个语法单元，返回是否结束
func (p *Parser) Next() (finish bool) {
	beforeCursor := p.Lexer.Cursor
	code := p.Lexer.Next()

	if code.IsEmpty() {
		return p.handleEmptyToken(beforeCursor)
	}

	if code.Value == "}" && code.Type == lexer.SEPARATOR {
		p.Back(1)
		return
	}

	//fmt.Println(code.Type)

	switch code.Type {
	case lexer.FUNC:
		p.processFuncToken(code)
	case lexer.PROCESSCONTROL:
		p.processControlToken(code)
	case lexer.NAME:
		p.processNameToken(code, beforeCursor)
	case lexer.VAR:
		p.processVarToken(beforeCursor)
	case lexer.TYPE:
		p.processTypeToken(code)
	case lexer.BUILD:
		p.processBuildToken(code)
	default:
		// *p = v / *p 解引用语句（以 * 开头的语句）
		if code.Type == lexer.SEPARATOR && code.Value == "*" {
			p.processDerefStmt(beforeCursor)
			return
		}
		p.processDefaultToken(code)
	}

	return
}

// parseTypeRef 解析类型引用，支持 []Type 和 *Type 语法
func (p *Parser) parseTypeRef() typeSys.Type {
	token := p.Lexer.Next()

	// 检查是否是 *Type 语法（指针类型）
	if token.Type == lexer.SEPARATOR && token.Value == "*" {
		elemType := p.parseTypeRef()
		if elemType != nil {
			return typeSys.MakePointer(elemType)
		}
		return nil
	}

	// 检查是否是 []Type 语法
	if token.Type == lexer.SEPARATOR && token.Value == "[" {
		nextToken := p.Lexer.Next()
		if nextToken.Type == lexer.SEPARATOR && nextToken.Value == "]" {
			// 解析元素类型
			elemType := p.parseTypeRef()
			if elemType == nil {
				return nil
			}
			return typeSys.NewList(elemType)
		}
		// 不是 []，退格
		p.Lexer.SetCursor(token.Cursor)
	} else {
		// 退格，使用 Name 解析
		p.Lexer.SetCursor(token.Cursor)
	}

	// 解析类型名称
	typeName, _ := p.ParseName(false)
	if typeName.IsEmpty() {
		return nil
	}

	// 再查找用户定义类型
	results := p.Find(Name(typeName), FindTypeType)
	if len(results) > 0 {
		if tb, ok := results[0].Value.(typeSys.Type); ok {
			return tb
		}
	}

	return nil
}

func (p *Parser) handleEmptyToken(beforeCursor int) bool {
	if p.ThisBlock.Father != nil {
		p.Error.MissErrors("Syntax Error", beforeCursor, p.Lexer.Cursor, "Need }")
	}
	return true
}

func (p *Parser) processFuncToken(code lexer.Token) {
	if code.Value == "fn" {
		block := &FuncBlock{}
		block.Parse(p)
	}
}

func (p *Parser) processControlToken(code lexer.Token) {
	switch code.Value {
	case "if":
		block := &IfBlock{}
		block.Parse(p)
	case "else":
		block := &ElseBlock{}
		block.Parse(p)
	case "ret":
		ret := &ReturnBlock{}
		ret.Parse(p)
	case "for":
		block := &ForBlock{}
		block.Parse(p)
	}
}

func (p *Parser) processNameToken(code lexer.Token, beforeCursor int) {
	p.Lexer.SetCursor(beforeCursor)
	name, _ := p.ParseName(false)

	code2 := p.Lexer.Next()

	if code2.Value == "." {
		checkToken := p.Lexer.Next()
		if checkToken.Value == "(" {
			p.Lexer.SetCursor(code2.Cursor)
			fullName, _ := p.ParseName(false)
			call := &CallBlock{Name: fullName}
			call.Parse(p)
			return
		}
		// Check if after the field name there's an assignment operator
		// We need to parse the full field access first, then check for assignment
		p.Lexer.SetCursor(code2.Cursor)
		exp := p.fieldExpr(name)
		if exp == nil {
			return
		}
		// Check if next token is an assignment operator
		assignOp := p.Lexer.Next()
		assignOps := []string{"=", ":=", "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>="}
		isAssign := false
		for _, op := range assignOps {
			if assignOp.Value == op {
				isAssign = true
				break
			}
		}
		if isAssign {
			// This is a field assignment like container.count = 5
			p.Lexer.SetCursor(beforeCursor)
			block := &VarBlock{}
			block.Parse(p)
			return
		}
		// Not an assignment, just field access
		p.Lexer.SetCursor(assignOp.Cursor)
		p.AddChild(&Node{Value: exp})
		return
	}

	switch code2.Value {
	case "(":
		p.Lexer.SetCursor(code2.Cursor)
		block := &CallBlock{Name: name}
		block.Parse(p)
	case "=", ":=", "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>=", "++", "--":
		// If name has multiple parts (field access), handle as expression assignment
		if len(name) > 1 {
			p.Lexer.SetCursor(beforeCursor)
			stopCursor := p.FindEndCursor()
			exp := p.ParseExp(stopCursor)
			if exp != nil {
				exp.Check(p)
				p.AddChild(&Node{Value: exp})
			}
			return
		}
		p.Lexer.SetCursor(beforeCursor)
		block := &VarBlock{}
		block.Parse(p)
	case "[":
		p.Lexer.SetCursor(beforeCursor)
		stopCursor := p.FindEndCursor()
		exp := p.ParseExp(stopCursor)
		if exp != nil {
			p.AddChild(&Node{Value: exp})
		}
	default:
		beforeCursor++
		p.Error.MissErrors("Syntax Error", beforeCursor, beforeCursor+code.Len(), "'"+name.String()+"' is not a valid expression")
	}
}

// fieldExpr 解析字段访问表达式（如 a.b.c），返回表达式节点。
// 将多级字段访问构建为左嵌套的 Expression 树：Separator="."，Left=左侧表达式，Right=字段名变量。
func (p *Parser) fieldExpr(name Name) *Expression {
	p.Lexer.Next() // 跳过 "."
	fieldName, _ := p.ParseName(false)
	if len(fieldName) == 0 {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "expected field name after '.'")
		return nil
	}

	// 构建左侧变量表达式
	left := &Expression{
		Var: &VarBlock{Name: name},
	}

	// 构建右侧字段名表达式
	right := &Expression{
		Var: &VarBlock{Name: fieldName},
	}

	// 构建 "." 运算表达式
	exp := &Expression{
		Separator: ".",
		Left:      left,
		Right:     right,
	}
	left.Father = exp
	right.Father = exp

	// 如果后面还有 "."，继续递归解析
	nextToken := p.Lexer.Next()
	if nextToken.Type == lexer.SEPARATOR && nextToken.Value == "." {
		p.Lexer.SetCursor(nextToken.Cursor)
		// 将当前表达式作为左侧，继续解析右侧字段
		return p.fieldExprFromExp(exp)
	}

	p.Lexer.SetCursor(nextToken.Cursor)
	return exp
}

// fieldExprFromExp 从已有的表达式继续解析字段访问（用于处理 a.b.c 的多级链式访问）。
func (p *Parser) fieldExprFromExp(left *Expression) *Expression {
	p.Lexer.Next() // 跳过 "."
	fieldName, _ := p.ParseName(false)
	if len(fieldName) == 0 {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "expected field name after '.'")
		return nil
	}

	right := &Expression{
		Var: &VarBlock{Name: fieldName},
	}

	exp := &Expression{
		Separator: ".",
		Left:      left,
		Right:     right,
	}
	left.Father = exp
	right.Father = exp

	// 如果后面还有 "."，继续递归
	nextToken := p.Lexer.Next()
	if nextToken.Type == lexer.SEPARATOR && nextToken.Value == "." {
		p.Lexer.SetCursor(nextToken.Cursor)
		return p.fieldExprFromExp(exp)
	}

	p.Lexer.SetCursor(nextToken.Cursor)
	return exp
}

func (p *Parser) processVarToken(beforeCursor int) {
	p.Lexer.SetCursor(beforeCursor)
	block := &VarBlock{}
	block.Parse(p)
}

func (p *Parser) processTypeToken(code lexer.Token) {
	switch code.Value {
	case "type":
		block := &TypeBlock{}
		block.Parse(p)
		p.AddChild(&Node{Value: block})
	case "struct":
		block := &StructBlock{}
		block.Parse(p)
		p.AddChild(&Node{Value: block})
	case "interface":
		block := &InterfaceDef{}
		block.Parse(p)
		p.AddChild(&Node{Value: block})
	default:
		p.processDefaultToken(code)
	}
}

func (p *Parser) processBuildToken(token lexer.Token) {
	block := &Build{}
	block.Parse(p)
}

// processDerefStmt 解析以 * 开头的解引用赋值/表达式语句
func (p *Parser) processDerefStmt(beforeCursor int) {
	p.Lexer.SetCursor(beforeCursor)
	p.PreventNameAssign = true
	exp := p.ParseExp(p.FindEndCursor())
	p.PreventNameAssign = false
	if exp == nil {
		return
	}
	p.AddChild(&Node{Value: exp})
}

func (p *Parser) processDefaultToken(code lexer.Token) {
	if code.Value != ";" && code.Value != "\n" && code.Value != "\r" {
		p.Lexer.Error.MissError("Syntax Error", p.Lexer.Cursor, "Miss "+code.Value)
	}
}

// AddChild 向当前作用域添加子节点
func (p *Parser) AddChild(node *Node) {
	p.ThisBlock.AddChild(node)
}

// Back 从当前作用域回退 num 层
func (p *Parser) Back(num int) error {
	if num == 0 {
		return nil
	}
	if p.ThisBlock.Father == nil {
		p.Error.MissError("Internal Compiler Errors", p.Lexer.Cursor, "Back at root")
	}
	if p.DontBack != 0 {
		p.DontBack--
		return p.Back(num - 1)
	}
	p.ThisBlock = p.ThisBlock.Father
	if num < 0 {
		num = -num
	}
	return p.Back(num - 1)
}

// Need 持续读取 Token 直到遇到指定值，返回所有经过的 Token
func (p *Parser) Need(value string) []lexer.Token {
	tmp2 := []lexer.Token{}
	for {
		tmp := p.Lexer.Next()
		if tmp.IsEmpty() {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need '"+value+"'")
		}
		if tmp.Value == "\n" {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need '"+value+"'")
		}
		tmp2 = append(tmp2, tmp)
		if tmp.Value == value && tmp.Type != lexer.STRING && tmp.Type != lexer.RAW {
			return tmp2
		}
	}
}

// FindEndCursor 查找当前行末尾的光标位置
func (p *Parser) FindEndCursor() int {
	tmp := strings.Index(p.Lexer.Text[p.Lexer.Cursor:], p.Lexer.LineFeed)
	if tmp == -1 {
		return len(p.Lexer.Text) - 1
	}
	return tmp + p.Lexer.Cursor
}

// Wait 等待并跳过直到遇到指定值，返回经过的 Token 数量
func (p *Parser) Wait(value string) int {
	return len(p.Need(value))
}

// Has 在指定范围内查找匹配的 Token，返回其结束位置
func (p *Parser) Has(token lexer.Token, stopCursor int) int {
	startCursor := p.Lexer.Cursor
	for stopCursor > p.Lexer.Cursor {
		code := p.Lexer.Next()
		if code.IsEmpty() {
			p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Incomplete expression")
		}
		if code.Value == token.Value && code.Type == token.Type {
			cursorTmp := p.Lexer.Cursor
			p.Lexer.SetCursor(startCursor)
			return cursorTmp
		}
	}
	p.Lexer.SetCursor(startCursor)
	return -1
}

// CheckUnusedVar 递归检查未使用的变量定义
func (p *Parser) CheckUnusedVar(node *Node) {
	for i := 0; i < len(node.Children); i++ {
		/*if node.Children[i].CFG == nil {
			node.Children = append(node.Children[:i], node.Children[i+1:]...)
			i--
		}*/
		switch node.Children[i].Value.(type) {
		case *VarBlock:
			varBlock := node.Children[i].Value.(*VarBlock)
			if varBlock.IsDefine && !varBlock.Used {
				p.Lexer.Error.MissErrors("Variable Error", varBlock.StartCursor-len(varBlock.Name)+1, varBlock.StartCursor, varBlock.Name.String()+" is unused")
			}
		}
		p.CheckUnusedVar(node.Children[i])
	}
}

// NewParser 创建新的语法分析器
func NewParser(lexer *lexer.Lexer) *Parser {
	p := &Parser{
		Lexer: lexer,
		Error: lexer.Error,
	}
	p.Block = &Node{}
	p.ThisBlock = p.Block
	return p
}

// Parse 执行完整的语法分析，返回 AST 根节点
func (p *Parser) Parse() *Node {
	for {
		if p.Next() {
			if p.Block != p.ThisBlock {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need '}'")
			}
			file, _ := os.OpenFile("ast.html", os.O_CREATE|os.O_WRONLY, 0644)
			file.Truncate(0)
			defer file.Close()
			generateASTHTML(p.Block, file)
			break
		}
	}
	return p.Block
}
