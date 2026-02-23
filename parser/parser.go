package parser

import (
	"bytes"
	errorUtil "cuteify/error"
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strings"
)

type Parser struct {
	Block         *Node
	ThisBlock     *Node
	Lexer         *lexer.Lexer
	BracketsNum   int
	Error         *errorUtil.Error
	Package       *packageFmt.Info
	DontBack      int
	CurrentStruct *StructBlock
}

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
		p.processBuildToken()
	default:
		p.processDefaultToken(code)
	}

	return
}

func (p *Parser) handleEmptyToken(beforeCursor int) bool {
	if p.ThisBlock.Father != nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need }")
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
	name, _ := p.Name(false)

	code2 := p.Lexer.Next()

	if code2.Value == "." {
		checkToken := p.Lexer.Next()
		if checkToken.Value == "(" {
			p.Lexer.SetCursor(code2.Cursor)
			exp := &Expression{}
			fullName, _ := p.Name(false)
			exp.handleMethodCall(p, fullName)
			return
		}
		p.Lexer.SetCursor(code2.Cursor)
		exp := &Expression{}
		exp.handleFieldAccess(p, name)
		return
	}

	switch code2.Value {
	case "(":
		p.Lexer.SetCursor(code2.Cursor)
		block := &CallBlock{Name: name}
		block.Parse(p)
	case "=", ":=", "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>=", "++", "--":
		p.Lexer.SetCursor(beforeCursor)
		block := &VarBlock{}
		block.Parse(p)
	default:
		beforeCursor++
		p.Error.MissErrors("Syntax Error", beforeCursor, beforeCursor+code.Len(), "'"+name.String()+"' is not a valid expression")
	}
}

func (p *Parser) processVarToken(beforeCursor int) {
	p.Lexer.SetCursor(beforeCursor)
	block := &VarBlock{}
	block.Parse(p)
}

func (p *Parser) processTypeToken(code lexer.Token) {
	switch code.Value {
	case "struct":
		block := &StructBlock{}
		block.Parse(p)
		p.AddChild(&Node{Value: block})
	case "interface":
		block := &InterfaceBlock{}
		block.Parse(p)
		p.AddChild(&Node{Value: block})
	default:
		p.processDefaultToken(code)
	}
}

func (p *Parser) processBuildToken() {
	// 回退到"build"开始位置
	cursor := p.Lexer.Cursor - len("build")
	p.Lexer.SetCursor(cursor)
	block := &Build{}
	block.Parse(p)
}

func (p *Parser) processDefaultToken(code lexer.Token) {
	if code.Value != ";" && code.Value != "\n" && code.Value != "\r" {
		p.Lexer.Error.MissError("Syntax Error", p.Lexer.Cursor, "Miss "+code.Value)
	}
}

func (p *Parser) AddChild(node *Node) {
	p.ThisBlock.AddChild(node)
}

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

func (p *Parser) FindEndCursor() int {
	tmp := strings.Index(p.Lexer.Text[p.Lexer.Cursor:], p.Lexer.LineFeed)
	if tmp == -1 {
		return len(p.Lexer.Text) - 1
	}
	return tmp + p.Lexer.Cursor
}

func (p *Parser) Wait(value string) int {
	return len(p.Need(value))
}

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

func (p *Parser) Name(wait bool) (name Name, cursor int) {
	if wait {
		// 等待名称
		for {
			oldCursor := p.Lexer.Cursor
			code := p.Lexer.Next()
			if code.IsEmpty() {
				// 语法错误：需要名称
				p.Lexer.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
			}
			if code.Value == "\n" || code.Value == "\r" || code.Value == ";" {
				// 语法错误：需要名称
				p.Lexer.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
			}
			if code.Type == lexer.NAME {
				// 退格，获取完整名称
				p.Lexer.SetCursor(oldCursor)
				break
			}
		}
	}

	// 记录名称起始位置
	cursor = p.Lexer.Cursor

	buf := ""

	lastCursor := p.Lexer.Cursor

	// 开始获取完整名称
	for {
		// 记录当前位置
		lastCursor = p.Lexer.Cursor
		code := p.Lexer.Next()
		switch code.Type {
		case lexer.NAME:
			buf += code.Value
		case lexer.SEPARATOR:
			// 必须是一个字符的分隔符
			// 检查是否是可用于名称的符号
			if len(code.Value) != 1 || bytes.IndexByte([]byte{'.', '_'}, code.Value[0]) == -1 {
				goto nameFindEnd
			}
			buf += code.Value
		default:
			goto nameFindEnd
		}
	}

nameFindEnd:
	// 还原到名称结束位置
	p.Lexer.SetCursor(lastCursor)

	// 对名称完整性检查
	if len(buf) > 0 && (buf[len(buf)-1] == '.' || buf[len(buf)-1] == '_') {
		// 语法错误：名称不能以 '.' 或 '_' 结尾
		p.Lexer.Error.MissError("Syntax Error", p.Lexer.Cursor, "name cannot end with '.' or '_'")
	}

	// 使用.解析路径
	if buf == "" {
		// 如果缓冲区为空，这是错误情况
		p.Lexer.Error.MissError("Syntax Error", p.Lexer.Cursor, "empty name is not allowed")
		name = []string{""} // 返回一个占位符，但实际上不会继续执行
	} else if strings.Contains(buf, ".") {
		name = strings.Split(buf, ".")
	} else {
		name = []string{buf}
	}

	// 检查路径中的每个元素是否为有效名称
	for _, part := range name {
		if part == "" || !utils.CheckName(part) {
			p.Lexer.Error.MissError("Syntax Error", p.Lexer.Cursor, "invalid name part: "+part)
		}
	}

	return
}

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

func NewParser(lexer *lexer.Lexer) *Parser {
	p := &Parser{
		Lexer: lexer,
		Error: lexer.Error,
	}
	p.Block = &Node{}
	p.ThisBlock = p.Block
	return p
}

func (p *Parser) Parse() *Node {
	for {
		if p.Next() {
			break
		}
	}
	return p.Block
}

func (p *Parser) Find(_name Name, dstType any) *Node {
	if len(_name) == 2 {
		objName := _name[0]
		methodName := _name[1]

		var varType typeSys.Type
		for _, child := range p.Block.Children {
			if vb, ok := child.Value.(*VarBlock); ok {
				if vb.Name.First() == objName {
					varType = vb.Type
					break
				}
			}
		}

		if varType != nil {
			structName := varType.Type()
			structBlock := p.FindStruct(structName)
			if structBlock != nil && len(structBlock.Methods) > 0 {
				for _, method := range structBlock.Methods {
					if method.Name.Last() == methodName {
						return &Node{Value: method}
					}
				}
			}
		}
	}

	var children []*Node

	name := _name.Fork()

	if name.IsPath() {
		name.FixPath(p.Package)
		children = p.Package.AST.(*Node).Children
	} else {
		children = p.Block.Children
	}

	for i := 0; i < len(children); i++ {
		value := children[i].Value
		switch dstType.(type) {
		case *VarBlock:
			v, ok := value.(*VarBlock)
			if !ok {
				continue
			}
			if name.Eq(v.Name) {
				return children[i]
			}
		case *FuncBlock:
			f, ok := value.(*FuncBlock)
			if !ok {
				continue
			}
			if name.Eq(f.Name) {
				return children[i]
			}
		}
	}
	p.Lexer.Error.MissError("func", p.Lexer.Cursor-1, "not found function '"+name.String()+"'")
	return nil
}

func (p *Parser) FindStruct(name string) *StructBlock {
	if p.CurrentStruct != nil && p.CurrentStruct.Name == name {
		return p.CurrentStruct
	}
	for _, child := range p.Block.Children {
		if sb, ok := child.Value.(*StructBlock); ok {
			if sb.Name == name {
				return sb
			}
		}
	}
	return nil
}

func (p *Parser) getCurrentStruct() *StructBlock {
	return p.CurrentStruct
}
