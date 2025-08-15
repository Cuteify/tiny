package parser

import "cuteify/lexer"

type ReturnBlock struct {
	Value []*Expression
}

func (r *ReturnBlock) Parse(p *Parser) {
	// 解析逗号
	count := 0
	for {
		code := p.Lexer.Next()
		count++
		if code.Type == lexer.LexTokenType["SEPARATOR"] && (code.Value == "\n" || code.Value == "\r") {
			p.Lexer.Back(count)
			r.Value = append(r.Value, p.ParseExpression(p.Lexer.Cursor+count))
			break
		}
		if code.Type == lexer.LexTokenType["SEPARATOR"] && code.Value == "," {
			p.Lexer.Back(count)
			r.Value = append(r.Value, p.ParseExpression(p.Lexer.Cursor+count))
			p.Lexer.Cursor++
			count = 0
		}
	}
	node := &Node{Value: r}
	p.ThisBlock.AddChild(node)

}
