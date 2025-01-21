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
	Funcs       map[string]*Node
	Vars        map[string]*Node
	Types       map[string]*Node
	Package     *packageFmt.Info
	DontBack    int
}

func (p *Parser) Next() (finish bool) {
	beforeCursor := p.Lexer.Cursor
	code := p.Lexer.Next()
	if code.IsEmpty() {
		if p.ThisBlock.Father != nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need }")
		}
		finish = true
		return
	}
	if code.Value == "}" && code.Type == lexer.LexTokenType["SEPARATOR"] {
		p.Back(1)
		return
	}
	switch code.Type {
	case lexer.LexTokenType["FUNC"]:
		if code.Value == "fn" {
			block := &FuncBlock{}
			block.Parse(p)
		}
	case lexer.LexTokenType["PROCESSCONTROL"]:
		if code.Value == "if" {
			block := &IfBlock{}
			block.Parse(p)
		} else if code.Value == "else" {
			block := &ElseBlock{}
			block.Parse(p)
		} else if code.Value == "ret" {
			ret := &ReturnBlock{}
			ret.Parse(p)
		}
	case lexer.LexTokenType["NAME"]:
		code2 := p.Lexer.Next()
		if code2.Type != lexer.LexTokenType["SEPARATOR"] {
			beforeCursor++
			p.Error.MissErrors("Syntax Error", beforeCursor, beforeCursor+len(code.Value), "'"+code.Value+"' is not a valid expression")
		}
		if code2.Value == "(" {
			block := &CallBlock{
				Name: code.Value,
			}
			block.Parse(p)
		} else if code2.Value == "." {
			p.Lexer.Cursor = beforeCursor
			block := &VarBlock{
				Name: code.Value,
			}
			block.ParseDefine(p)
			block.Type = block.Define.Value.(*VarBlock).Type
			code3 := p.Lexer.Next()
			if code3.Type == lexer.LexTokenType["NAME"] {

			}
		} else if code2.Value == "=" {
			p.Lexer.Cursor = beforeCursor
			block := &VarBlock{}
			block.Parse(p)
		} else if code2.Value == ":=" {
			p.Lexer.Cursor = beforeCursor
			block := &VarBlock{}
			block.Parse(p)
		} else {
			beforeCursor++
			p.Error.MissErrors("Syntax Error", beforeCursor, beforeCursor+len(code.Value), "'"+code.Value+"' is not a valid expression")
		}
	case lexer.LexTokenType["VAR"]:
		p.Lexer.Cursor = beforeCursor
		block := &VarBlock{}
		block.Parse(p)
	case lexer.LexTokenType["BUILD"]:
		block := &Build{}
		block.Parse(p)
	default:
		if code.Type == lexer.LexTokenType["SEPARATOR"] && code.Value != ";" && code.Value != "\n" && code.Value != "\r" {
			p.Lexer.Error.MissError("Syntax Error", p.Lexer.Cursor, "Miss "+code.Value)
		}
	}
	return
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
		if tmp.Value == value && tmp.Type != lexer.LexTokenType["STRING"] && tmp.Type != lexer.LexTokenType["RAW"] {
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
			p.Lexer.Cursor = startCursor
			return cursorTmp
		}
	}
	p.Lexer.Cursor = startCursor
	return -1
}

func (p *Parser) CheckUnusedVar(node *Node) {
	for i := 0; i < len(node.Children); i++ {
		if node.Children[i].CFG == nil {
			node.Children = append(node.Children[:i], node.Children[i+1:]...)
			i--
		}
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
