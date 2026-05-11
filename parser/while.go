package parser

import (
	"cuteify/lexer"
)

type WhileBlock struct {
	Condition *Expression
	Offset    int
}

func (w *WhileBlock) Parse(p *Parser) {
	bracketsCount := 0
	oldCursor := p.Lexer.Cursor

	for p.FindEndCursor() > p.Lexer.Cursor {
		code := p.Lexer.Next()
		switch code.Value {
		case "(":
			bracketsCount++
		case ")":
			bracketsCount--
		}
		if bracketsCount == 0 && code.Value == "{" && code.Type == lexer.SEPARATOR {
			break
		}
	}
	stopCursor := p.Lexer.Cursor - 2
	p.Lexer.SetCursor(oldCursor)
	w.Condition = p.ParseExp(stopCursor)

	p.Wait("{")

	whileNode := &Node{Value: w}
	p.ThisBlock.AddChild(whileNode)
	p.ThisBlock = whileNode
}
