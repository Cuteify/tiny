package parser

import (
	"cuteify/lexer"
	"cuteify/utils"
	"fmt"
)

// ReturnBlock return 语句结构体
type ReturnBlock struct {
	Value []*Expression
}

// Parse 解析 return 语句
func (r *ReturnBlock) Parse(p *Parser) {
	p.Lexer.Skip(' ')           // 跳过空格
	oldCursor := p.Lexer.Cursor // 记录初始位置
	brecket := 0
	for {
		code := p.Lexer.Next()
		if code.Type == lexer.SEPARATOR {
			switch code.Value {
			case "(":
				brecket++
			case ")":
				brecket--
			}
		}
		if code.Type == lexer.SEPARATOR && (code.Value == "\n" || code.Value == "\r") {
			if brecket == 0 {
				cursor := code.Cursor
				p.Lexer.SetCursor(oldCursor)
							fmt.Println(utils.MakeVisible(p.Lexer.Text[oldCursor:cursor]))
				r.Value = append(r.Value, p.ParseExp(cursor-1))
				p.Lexer.SetCursor(code.EndCursor)
				break
			} else {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "miss )")
			}
		}
		if brecket == 0 && code.Type == lexer.SEPARATOR && code.Value == "," {
			cursor := code.Cursor // 到终止符
			p.Lexer.SetCursor(oldCursor)
			fmt.Println(p.Lexer.Text[oldCursor:cursor])
			r.Value = append(r.Value, p.ParseExp(cursor-1))
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
		if !v.Check(p) {
			return false
		}
	}

	return true
}
