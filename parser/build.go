package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"runtime"
	"strconv"
	"strings"
)

type Build struct {
	Type         string
	Export       string // export("alias")：把当前函数以别名导出
	Asm          string
	Ext          string
	ExtRet       string
	UseMoreStack bool
	OS           []string
	Archs        []string
	Ignore       bool
	Link         string
	// Align 打包对齐上限（Wave L）：build align(N)，noalign = 1。
	// 仅对紧随其后的 struct 生效（严格紧随语义），对函数透明。
	Align  int
	VarMap map[string]*VarBlock // 变量名 -> 临时VarBlock（已填充Offset）
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
	case "arch":
		p.Lexer.Skip('(')
		stopToken := p.Has(lexer.Token{Value: ")", Type: lexer.SEPARATOR}, p.FindEndCursor())
		for p.Lexer.Cursor < stopToken {
			archName := p.Lexer.Next()
			switch archName.Type {
			case lexer.SEPARATOR:
				if archName.Value == ")" {
					break
				}
				if archName.Value != "," {
					p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need ,")
				}
			case lexer.STRING, lexer.NAME, lexer.RAW, lexer.CHAR:
				b.Archs = append(b.Archs, archName.Value)
			}
		}
		b.Type = "arch"
		b.checkArchMatch()
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
		switch p.ThisBlock.Value.(type) {
		case *FuncBlock:
			p.ThisBlock.Value.(*FuncBlock).BuildFlags = append(p.ThisBlock.Value.(*FuncBlock).BuildFlags, b)
		default:
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "link only in func")
		}
	case "align":
		// build align(N)：设置打包对齐上限，作用于紧随其后的 struct
		b.Type = "align"
		open := p.Lexer.Next()
		if open.Type != lexer.SEPARATOR || open.Value != "(" {
			p.Error.MissError("Syntax Error", open.Cursor, "build align needs (N)")
		}
		num := p.Lexer.Next()
		if num.Type != lexer.NUMBER {
			p.Error.MissError("Syntax Error", num.Cursor, "build align needs a positive number")
		}
		n, atoiErr := strconv.Atoi(num.Value)
		if atoiErr != nil || n < 1 {
			p.Error.MissError("Syntax Error", num.Cursor, "build align needs a positive number")
		}
		closeToken := p.Lexer.Next()
		if closeToken.Type != lexer.SEPARATOR || closeToken.Value != ")" {
			p.Error.MissError("Syntax Error", closeToken.Cursor, "build align needs )")
		}
		b.Align = n
	case "noalign":
		// build noalign：等价于 align(1)，字段紧密排列无填充
		b.Type = "align"
		b.Align = 1
	default:
		return
	}
	p.ThisBlock.AddChild(&Node{Value: b})
}

// attachPendingAlign 检查当前作用域最后一个子节点是否为 align Build
// （build align(N)/noalign）。是则把对齐上限应用到结构体，并把该 Build
// 从树中移除（已消费）。严格紧随语义：align 与 struct 之间隔了任何
// 其它声明（最后一个子节点不是 align）即孤儿，不生效。
func (p *Parser) attachPendingAlign(st *typeSys.StructType) {
	children := p.ThisBlock.Children
	if len(children) == 0 {
		return
	}
	last := children[len(children)-1]
	b, ok := last.Value.(*Build)
	if !ok || b.Type != "align" {
		return
	}
	st.Align = b.Align
	p.ThisBlock.Children = children[:len(children)-1]
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

func (b *Build) checkArchMatch() {
	currentArch := typeSys.TargetArch()
	for _, arch := range b.Archs {
		arch = strings.TrimSpace(arch)
		if arch == currentArch {
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
		if tmpVar.Define.Node != nil || tmpVar.Offset != 0 {
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
