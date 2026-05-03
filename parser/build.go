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
	VarMap       map[string]*VarBlock // 变量名 -> 临时VarBlock（已填充Offset）
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
		rawAsm := p.Lexer.Text[oldCurser : p.Lexer.Cursor-1]
		b.Asm = b.stripLeadingWhitespace(rawAsm)
		b.Type = "asm"

		// 自动向前查找 FuncBlock 并展开变量替换
		b.expandAsmWithFuncArgs(p)
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

// expandAsmWithFuncArgs 自动查找变量，存储 VarBlock
func (b *Build) expandAsmWithFuncArgs(p *Parser) {
	// 提取所有 $变量名
	variables := b.extractVariables()

	// 存储变量映射
	b.VarMap = make(map[string]*VarBlock)
	for _, varName := range variables {
		name := NewName(varName)

		// 创建临时 VarBlock
		tmpVar := &VarBlock{Name: name, IsDefine: false}

		// 让 VarBlock 自己查找 Define
		tmpVar.ParseDefine(p)

		// 检查是否找到了变量（Offset 被设置）
		if tmpVar.Define != nil || tmpVar.Offset != 0 {
			b.VarMap[varName] = tmpVar
		}
	}
}

// extractVariables 从汇编代码中提取所有 $变量名
func (b *Build) extractVariables() []string {
	var variables []string
	lines := strings.Split(b.Asm, "\n")
	for _, line := range lines {
		// 查找 $ 开头的变量名
		for i := 0; i < len(line); i++ {
			if line[i] == '$' && i+1 < len(line) {
				// 提取变量名
				start := i + 1
				end := start
				for end < len(line) && (isAlphaNum(line[end]) || line[end] == '_') {
					end++
				}
				if end > start {
					varName := line[start:end]
					// 检查是否已存在
					found := false
					for _, v := range variables {
						if v == varName {
							found = true
							break
						}
					}
					if !found {
						variables = append(variables, varName)
					}
				}
			}
		}
	}
	return variables
}

// isAlphaNum 检查字符是否是字母或数字
func isAlphaNum(c byte) bool {
	return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')
}

// stripLeadingWhitespace 去除每行前导空白，找到最小缩进并统一去除
func (b *Build) stripLeadingWhitespace(asm string) string {
	lines := strings.Split(asm, "\n")

	// 找到最小缩进
	minIndent := -1
	for _, line := range lines {
		if strings.TrimSpace(line) == "" {
			continue
		}
		indent := 0
		for _, ch := range line {
			if ch == ' ' || ch == '\t' {
				indent++
			} else {
				break
			}
		}
		if minIndent == -1 || indent < minIndent {
			minIndent = indent
		}
	}

	if minIndent <= 0 {
		return asm
	}

	// 去除最小缩进
	for i, line := range lines {
		if len(line) >= minIndent {
			lines[i] = line[minIndent:]
		}
	}

	return strings.Join(lines, "\n")
}
