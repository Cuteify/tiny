package parser

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
		p.Need("}")
		b.Asm = p.Lexer.Text[oldCurser:p.Lexer.Cursor]
		b.Type = "asm"
	default:
		return
	}
	p.ThisBlock.AddChild(&Node{Value: b})
}
