package parser

import (
	"cuteify/lexer"
)

type ReturnBlock struct {
	Value []*Expression
}

func (r *ReturnBlock) Parse(p *Parser) {
	p.Lexer.Skip(' ')           // 跳过空格
	oldCursor := p.Lexer.Cursor // 记录初始位置
	brecket := 0
	for {
		code := p.Lexer.Next()
		if code.Type == lexer.SEPARATOR {
			if code.Value == "(" {
				brecket++
			} else if code.Value == ")" {
				brecket--
			}
		}
		if code.Type == lexer.SEPARATOR && (code.Value == "\n" || code.Value == "\r") {
			if brecket == 0 {
				cursor := code.Cursor // 到终止符
				p.Lexer.SetCursor(oldCursor)
				r.Value = append(r.Value, p.ParseExpression(cursor))
				break
			} else {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "miss )")
			}
		}
		if brecket == 0 && code.Type == lexer.SEPARATOR && code.Value == "," {
			cursor := code.Cursor // 到终止符
			p.Lexer.SetCursor(oldCursor)
			r.Value = append(r.Value, p.ParseExpression(cursor))
			tmp := p.Lexer.Next()
			oldCursor = tmp.EndCursor
		}
	}
	node := &Node{Value: r}
	p.ThisBlock.AddChild(node)
}

func (r *ReturnBlock) Check(p *Parser) bool {
	for _, v := range r.Value {
		if !v.Check(p) {
			return false
		}
	}

	return true
}
