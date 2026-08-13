package parser

import (
	"cuteify/lexer"
)

// ReturnBlock return 语句结构体
type ReturnBlock struct {
	Value []*Expression
}

// Parse 解析 return 语句
func (r *ReturnBlock) Parse(p *Parser) {
	if p.Lexer.Text[p.Lexer.Cursor] == ' ' {
		p.Lexer.Skip(' ')
	}
	oldCursor := p.Lexer.Cursor // 记录初始位置
	round := 0                  // () 深度：只用于配对/闭合检查
	curly := 0                  // {} 深度：决定 } 是否终止、逗号是否顶层
	for {
		code := p.Lexer.Next()
		if code.Type == lexer.SEPARATOR {
			if code.Value == "}" && round == 0 && curly == 0 {
				// curly==0 到达的 } 是外层块收尾，终止语句
				if oldCursor < code.Cursor {
					p.Lexer.SetCursor(oldCursor)
					exp := p.ParseExp(code.Cursor)
					if exp != nil {
						r.Value = append(r.Value, exp)
					}
				}
				p.Lexer.SetCursor(code.Cursor)
				break
			}
			switch code.Value {
			case "(":
				round++
			case ")":
				round--
			case "{":
				curly++
			case "}":
				if curly > 0 {
					curly--
				}
			}
		}
		if code.Type == lexer.SEPARATOR && round == 0 && curly == 0 &&
			(code.Value == "\n" || code.Value == "\r" || code.Value == ";") {
			if oldCursor < code.Cursor {
				p.Lexer.SetCursor(oldCursor)
				exp := p.ParseExp(code.Cursor)
				if exp != nil {
					r.Value = append(r.Value, exp)
				}
			}
			p.Lexer.SetCursor(code.EndCursor)
			break
		}
		if round == 0 && curly == 0 && code.Type == lexer.SEPARATOR && code.Value == "," {
			p.Lexer.SetCursor(oldCursor)
			exp := p.ParseExp(code.Cursor)
			r.Value = append(r.Value, exp)
			tmp := p.Lexer.Next()
			oldCursor = tmp.EndCursor
		}
	}

	node := &Node{Value: r}
	p.ThisBlock.AddChild(node)
}

// Check 检查 return 语句的有效性
func (r *ReturnBlock) Check(p *Parser) bool {
	for _, v := range r.Value {
		if v != nil && !v.Check(p) {
			return false
		}
	}

	return true
}
