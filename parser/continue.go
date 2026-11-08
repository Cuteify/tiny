package parser

import (
	"cuteify/lexer"
	"strconv"
)

// ContinueBlock continue 语句节点
type ContinueBlock struct {
	Level int // continue 继续的外层循环层数（默认 1）
}

// Parse 解析 continue [N] 语句，并校验目标循环存在。
// Go 语义：continue 只作用于 for 循环，switch 不计数。
func (c *ContinueBlock) Parse(p *Parser) {
	c.Level = 1
	nextToken := p.Lexer.Next()
	if nextToken.Value == "(" {
		numToken := p.Lexer.Next()
		if numToken.Type == lexer.NUMBER {
			n, err := strconv.Atoi(numToken.Value)
			if err == nil && n >= 1 {
				c.Level = n
			}
		}
		p.Lexer.Skip(')')
	} else if nextToken.Type == lexer.NUMBER {
		n, err := strconv.Atoi(nextToken.Value)
		if err == nil && n >= 1 {
			c.Level = n
		}
	} else {
		p.Lexer.SetCursor(nextToken.Cursor)
	}

	depth := 0
	for b := p.ThisBlock; b != nil; b = b.Father {
		if _, ok := b.Value.(*ForBlock); ok {
			depth++
		}
	}
	if depth == 0 {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "'continue' outside of loop")
		return
	}
	if c.Level > depth {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor,
			"continue level "+strconv.Itoa(c.Level)+" exceeds enclosing loop depth "+strconv.Itoa(depth))
	}
}
