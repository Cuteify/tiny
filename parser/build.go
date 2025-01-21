package parser

import (
	"cuteify/lexer"
)

type Build struct {
	Type         string
	Asm          string
	Ext          string
	ExtRet       string
	UseMoreStack bool
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
	case "ext":
		if p.FindEndCursor() <= p.Lexer.Cursor {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need )")
		}
		b.Ext = p.Lexer.Text[p.Lexer.Cursor:p.FindEndCursor()]
		p.Lexer.Cursor = p.FindEndCursor()
		b.Type = "ext"
		switch p.ThisBlock.Value.(type) {
		case *FuncBlock:
			p.ThisBlock.Value.(*FuncBlock).BuildFlags = append(p.ThisBlock.Value.(*FuncBlock).BuildFlags, b)
		default:
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "ext only in func")
		}
	case "extret":
		if p.FindEndCursor() <= p.Lexer.Cursor {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need )")
		}
		b.ExtRet = p.Lexer.Text[p.Lexer.Cursor:p.FindEndCursor()]
		p.Lexer.Cursor = p.FindEndCursor()
		b.Type = "extret"
		switch p.ThisBlock.Value.(type) {
		case *FuncBlock:
			p.ThisBlock.Value.(*FuncBlock).BuildFlags = append(p.ThisBlock.Value.(*FuncBlock).BuildFlags, b)
		default:
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "extret only in func")
		}
	case "UseMoreStack":
		b.UseMoreStack = true
		b.Type = "UseMoreStack"
		switch p.ThisBlock.Value.(type) {
		case *FuncBlock:
			p.ThisBlock.Value.(*FuncBlock).BuildFlags = append(p.ThisBlock.Value.(*FuncBlock).BuildFlags, b)
		default:
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "UseMoreStack only in func")
		}
	default:
		return
	}
	p.ThisBlock.AddChild(&Node{Value: b})
}
