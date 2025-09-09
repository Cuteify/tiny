package parser

import "cuteify/lexer"

type Brackets struct {
	Father   *Brackets
	Children []*BracketsValue
}

type BracketsValue struct {
	Value    lexer.Token
	Brackets *Brackets
}

func (p *Parser) Brackets(parseToken bool) *Brackets {
	br := &Brackets{}
	if parseToken {
		startCursor := p.Lexer.Cursor
		for {
			tmp := p.Lexer.Next()
			if tmp.IsEmpty() || tmp.Value == "\n" || tmp.Value == "\r" {
				p.Lexer.Error.MissError("Syntax Error", startCursor, "Need (")
			}
			if tmp.Value == "(" {
				break
			}
		}
	}
	for {
		tmp := p.Lexer.Next()
		if tmp.Type == lexer.SEPARATOR {

			if tmp.IsEmpty() || tmp.Value == "\n" || tmp.Value == "\r" {
				p.Lexer.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need )")
			}
			if tmp.Value == "(" {
				br.AddChild(&BracketsValue{Brackets: p.Brackets(false)})
				continue
			}
			if tmp.Value == ")" {
				break
			}
		}
		br.AddChild(&BracketsValue{Value: tmp})
	}
	return br
}

func (p *Parser) FindRightBracket(parseToken bool) int {
	if parseToken {
		startCursor := p.Lexer.Cursor
		for {
			tmp := p.Lexer.Next()
			if tmp.IsEmpty() || tmp.Value == "\n" {
				p.Lexer.Error.MissError("Syntax Error", startCursor, "Need )")
			}

			if tmp.Value == "(" {
				break
			}
		}
	}
	startCursor := p.Lexer.Cursor
	count := 1
	for {
		tmp := p.Lexer.Next()
		if tmp.IsEmpty() || tmp.Value == "\n" {
			p.Lexer.Error.MissError("Syntax Error", startCursor, "Need )")
		}
		if tmp.Value == "(" {
			count++
		}
		if tmp.Value == ")" {
			count--
		}
		if count == 0 {
			cursorTmp := p.Lexer.Cursor
			p.Lexer.Cursor = startCursor
			return cursorTmp
		}
	}
}

func (b *Brackets) AddChild(value *BracketsValue) {
	b.Children = append(b.Children, value)
	if value.Brackets != nil {
		value.Brackets.Father = b
	}
}
