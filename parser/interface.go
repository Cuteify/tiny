package parser

// InterfaceBlock 接口定义
type InterfaceBlock struct {
	Name        Name  // 接口名称
	Methods     []any // 方法定义（简化处理）
	StartCursor int
	EndCursor   int
}

// Parse 解析接口
func (i *InterfaceBlock) Parse(p *Parser) {
	// 解析接口名称
	nameParts, _ := p.Name(true) // 等待名称
	i.Name = nameParts
	i.StartCursor = p.Lexer.Cursor

	// 解析接口内容（简化实现）
	// 期望 {
	token := p.Lexer.Next()
	if token.Value != "{" {
		p.Error.MissError("Interface Error", token.Cursor, "expected '{'")
	}

	// 解析到 }
	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Interface Error", p.Lexer.Cursor, "unexpected EOF in interface")
		}

		if token.Value == "}" {
			i.EndCursor = token.Cursor
			break
		}
		// 这里可以添加方法解析逻辑，但现在简化处理
	}
}
