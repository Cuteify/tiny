package parser

import (
	errorUtil "cuteify/error"
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
	"strings"
)

type Parser struct {
	Block       *Node // block
	ThisBlock   *Node // 当前block
	Lexer       *lexer.Lexer
	BracketsNum int
	Error       *errorUtil.Error
	Package     *packageFmt.Info
	DontBack    int
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
	code2 := p.Lexer.Next()
	if code2.Type != lexer.SEPARATOR {
		beforeCursor++
		p.Error.MissErrors("Syntax Error", beforeCursor, beforeCursor+code.Len(), "'"+code.Value+"' is not a valid expression")
	}

	switch code2.Value {
	case "(":
		p.Lexer.SetCursor(code2.Cursor)
		block := &CallBlock{Name: code.Value}
		block.Parse(p)
	/*case ".":
	p.Lexer.SetCursor(beforeCursor)
	block := &VarBlock{Name: code.Value}
	block.ParseDefine(p)
	block.Type = block.Define.Value.(*VarBlock).Type*/
	case "=", ":=", "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>=", "++", "--":
		p.Lexer.SetCursor(beforeCursor)
		block := &VarBlock{}
		block.Parse(p)
	default:
		beforeCursor++
		p.Error.MissErrors("Syntax Error", beforeCursor, beforeCursor+code.Len(), "'"+code.Value+"' is not a valid expression")
	}
}

func (p *Parser) processVarToken(beforeCursor int) {
	p.Lexer.SetCursor(beforeCursor)
	block := &VarBlock{}
	block.Parse(p)
}

func (p *Parser) processBuildToken() {
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
				p.Lexer.Error.MissErrors("Variable Error", varBlock.StartCursor-len(varBlock.Name)+1, varBlock.StartCursor, varBlock.Name+" is unused")
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

func (p *Parser) Find(name string, dstType any) *Node {
	// 查找包名
	tmp := strings.Split(name, ".")
	var children []*Node
	if len(tmp) != 1 {
		packageName, funcName := tmp[0], tmp[len(tmp)-1]
		importPackage := packageFmt.FixPathName(p.Package.Import[packageName])
		name = importPackage + "." + funcName
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
			if v.Name == name {
				return children[i]
			}
		case *FuncBlock:
			f, ok := value.(*FuncBlock)
			if !ok {
				continue
			}
			if f.Name == name {
				return children[i]
			}
		}
	}
	p.Lexer.Error.MissError("func", p.Lexer.Cursor-1, "not found function '"+name+"'")
	return nil
}
