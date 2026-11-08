package parser

import (
	"cuteify/lexer"
	"strconv"
)

// BreakBlock break 语句节点
type BreakBlock struct {
	Level int // break 跳出的循环层数（默认 1）
}

// Parse 解析 break [N] 语句
func (b *BreakBlock) Parse(p *Parser) {
	b.Level = 1
	nextToken := p.Lexer.Next()
	if nextToken.Value == "(" {
		numToken := p.Lexer.Next()
		if numToken.Type == lexer.NUMBER {
			n, err := strconv.Atoi(numToken.Value)
			if err == nil && n >= 1 {
				b.Level = n
			}
		}
		p.Lexer.Skip(')')
	} else if nextToken.Type == lexer.NUMBER {
		n, err := strconv.Atoi(nextToken.Value)
		if err == nil && n >= 1 {
			b.Level = n
		}
	} else {
		p.Lexer.SetCursor(nextToken.Cursor)
	}

	depth := 0
	for b := p.ThisBlock; b != nil; b = b.Father {
		switch b.Value.(type) {
		case *ForBlock, *SwitchBlock:
			depth++
		}
	}
	if depth == 0 {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "'break' outside of loop or switch")
		return
	}
	if b.Level > depth {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor,
			"break level "+strconv.Itoa(b.Level)+" exceeds enclosing loop/switch depth "+strconv.Itoa(depth))
	}
}
