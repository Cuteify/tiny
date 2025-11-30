package parser

import (
	"cuteify/lexer"
)

type ReturnBlock struct {
	Value []*Expression
}

func (r *ReturnBlock) Parse(p *Parser) {
	// 解析逗号
	count := 0
	brecket := 0
	for {
		code := p.Lexer.Next()
		count += code.Len()
		if code.Type == lexer.SEPARATOR && (code.Value == "(" || code.Value == ")") {
			if code.Value == "(" {
				brecket++
			} else {
				brecket--
			}
		}
		if brecket == 0 && code.Type == lexer.SEPARATOR && (code.Value == "\n" || code.Value == "\r") {
			cursor := p.Lexer.Cursor - 1
			p.Lexer.Back(count)
			r.Value = append(r.Value, p.ParseExpression(cursor))
			break
		}
		if brecket == 0 && code.Type == lexer.SEPARATOR && code.Value == "," {
			cursor := p.Lexer.Cursor - 1
			p.Lexer.Back(count)
			r.Value = append(r.Value, p.ParseExpression(cursor))
			p.Lexer.Cursor++
			count = 0
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
