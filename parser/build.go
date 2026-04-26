package parser

import (
	"cuteify/lexer"
	"runtime"
	"strings"
)

type Build struct {
	Type         string
	Asm          string
	Ext          string
	ExtRet       string
	UseMoreStack bool
	OS           []string
	Ignore       bool
	Link         string
}

func (b *Build) Parse(p *Parser) {
	tmp := p.Lexer.Next()
	switch tmp.Value {
	case "asm":
		p.Wait("{")
		oldCurser := p.Lexer.Cursor
		for {
			code := p.Lexer.Next()
			if code.IsEmpty() {
				if p.ThisBlock.Father != nil {
					p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need }")
				}
			}
			if code.Value == "}" && code.Type == lexer.SEPARATOR {
				break
			}
		}
		b.Asm = p.Lexer.Text[oldCurser : p.Lexer.Cursor-1]
		b.Type = "asm"
	case "ext":
		if p.FindEndCursor() <= p.Lexer.Cursor {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need )")
		}
		b.Ext = p.Lexer.Text[p.Lexer.Cursor:p.FindEndCursor()]
		p.Lexer.SetCursor(p.FindEndCursor())
		b.Type = "ext"
		switch p.ThisBlock.Value.(type) {
		case *FuncBlock:
			p.ThisBlock.Value.(*FuncBlock).BuildFlags = append(p.ThisBlock.Value.(*FuncBlock).BuildFlags, b)
		default:
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "ext only in func")
		}
	case "extret":
		if p.FindEndCursor() <= p.Lexer.Cursor {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need )")
		}
		b.ExtRet = p.Lexer.Text[p.Lexer.Cursor:p.FindEndCursor()]
		p.Lexer.SetCursor(p.FindEndCursor())
		b.Type = "extret"
		switch p.ThisBlock.Value.(type) {
		case *FuncBlock:
			p.ThisBlock.Value.(*FuncBlock).BuildFlags = append(p.ThisBlock.Value.(*FuncBlock).BuildFlags, b)
		default:
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "extret only in func")
		}
	case "os":
		p.Lexer.Skip('(')
		stopToken := p.Has(lexer.Token{Value: ")", Type: lexer.SEPARATOR}, p.FindEndCursor())
		for p.Lexer.Cursor < stopToken {
			osName := p.Lexer.Next()
			switch osName.Type {
			case lexer.SEPARATOR:
				if osName.Value == ")" {
					break
				}
				if osName.Value != "," {
					p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need ,")
				}
			case lexer.STRING, lexer.NAME, lexer.RAW, lexer.CHAR:
				b.OS = append(b.OS, osName.Value)
			}
		}
		b.Type = "os"
		b.checkOSMatch()
		switch p.ThisBlock.Value.(type) {
		case *FuncBlock:
			p.ThisBlock.Value.(*FuncBlock).BuildFlags = append(p.ThisBlock.Value.(*FuncBlock).BuildFlags, b)
		default:
		}
	case "link":
		b.Type = "link"
		p.Lexer.Skip('(')
		stopToken := p.Has(lexer.Token{Value: ")", Type: lexer.SEPARATOR}, p.FindEndCursor())
		linkname := p.Lexer.Next()
		switch linkname.Type {
		case lexer.STRING, lexer.NAME, lexer.RAW, lexer.CHAR:
			b.Link = linkname.Value
		default:
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need link name")
		}
		p.Lexer.SetCursor(stopToken)
	default:
		return
	}
	p.ThisBlock.AddChild(&Node{Value: b})
}

func (b *Build) checkOSMatch() {
	currentOS := runtime.GOOS
	for _, os := range b.OS {
		os = strings.TrimSpace(os)
		if os == currentOS {
			return
		}
	}
	b.Ignore = true
}
