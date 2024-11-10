package parser

import (
	"future/lexer"
)

type Build struct {
	Type string
	Asm  string
}

func (b *Build) Parse(p *Parser) {
	tmp := p.Lexer.Next()
	switch tmp.Value {
	case "asm":
		p.Wait("{")
		oldCurser := p.Lexer.Cursor
		for {
			code := p.Lexer.Next()
			if code.IsEmpty() {
				if p.ThisBlock.Father != nil {
					p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need }")
				}
			}
			if code.Value == "}" && code.Type == lexer.LexTokenType["SEPARATOR"] {
				break
			}
		}
		b.Asm = p.Lexer.Text[oldCurser : p.Lexer.Cursor-1]
		b.Type = "asm"
	default:
		return
	}
	p.ThisBlock.AddChild(&Node{Value: b})
}
