package parser

import (
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
	typeSys "cuteify/type"
	"cuteify/utils"
)

// processEnumToken 解析 enum 声明，把每个枚举成员降级为同作用域的 int 常量：
//
//	enum TokenType {
//	    NONE
//	    FUNC
//	    PROCESSCONTROL = 3
//	}
//
// 成员默认从 0 开始自增，可用 `= 整数常量` 指定值；成员名可直接使用。
// 枚举名同时注册为 int 的真别名，便于 `var t: TokenType` 类型标注。
// 当前不支持 `TokenType.NONE` 作用域限定访问。
func (p *Parser) processEnumToken() {
	startCursor := p.Lexer.Cursor

	nameToken := p.Lexer.Next()
	if nameToken.Type != lexer.NAME {
		p.Error.MissError("Syntax Error", nameToken.Cursor, "expected enum name")
	}
	enumName := nameToken.Value
	if !utils.CheckName(enumName) {
		p.Error.MissError("Syntax Error", nameToken.Cursor, "invalid enum name: '"+enumName+"'")
	}

	openToken := p.Lexer.Next()
	if openToken.Type != lexer.SEPARATOR || openToken.Value != "{" {
		p.Error.MissError("Syntax Error", openToken.Cursor, "need '{' after enum name")
	}

	// 枚举名作为 int 真别名注册，先于成员声明进入作用域。
	enumType := &TypeBlock{
		Name:        NewName(enumName),
		Kind:        TypeAlias,
		Alias:       typeSys.NewAlias(enumName, typeSys.GetSystemType("int"), true),
		StartCursor: startCursor,
	}
	if p.Package != nil && p.Package.Path != "" {
		packageFmt.RegisterType(p.Package.Path, enumName, enumType.Type())
	}
	p.AddChild(&Node{Value: enumType})

	nextValue := 0.0
	seen := make(map[string]bool)

	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Syntax Error", token.Cursor, "unexpected EOF in enum "+enumName)
		}
		if token.Type == lexer.SEPARATOR && token.Value == "}" {
			break
		}
		if isEnumSeparator(token) {
			continue
		}
		if token.Type != lexer.NAME {
			p.Error.MissError("Syntax Error", token.Cursor, "expected enum member name")
		}

		member := token.Value
		if !utils.CheckName(member) {
			p.Error.MissError("Syntax Error", token.Cursor, "invalid enum member name: '"+member+"'")
		}
		if seen[member] {
			p.Error.MissError("Syntax Error", token.Cursor, "duplicate enum member: "+member)
		}
		seen[member] = true

		value := nextValue
		next := p.Lexer.Next()
		if next.Type == lexer.SEPARATOR && next.Value == "=" {
			value = p.parseEnumValue(enumName, member)
		} else {
			// 没有显式值：把刚读到的分隔符/右花括号退回去，交给循环处理。
			p.Lexer.SetCursor(next.Cursor)
		}

		p.addEnumMember(member, value, token.Cursor)
		nextValue = value + 1
	}
}

// isEnumSeparator 枚举成员之间允许换行、逗号或分号分隔。
func isEnumSeparator(token lexer.Token) bool {
	if token.Type != lexer.SEPARATOR {
		return false
	}
	switch token.Value {
	case ",", ";", "\n", "\r":
		return true
	}
	return false
}

// parseEnumValue 解析 `= <整数常量>`，支持十进制/十六进制/二进制/八进制和负号。
func (p *Parser) parseEnumValue(enumName, member string) float64 {
	token := p.Lexer.Next()
	negative := false
	if token.Type == lexer.SEPARATOR && token.Value == "-" {
		negative = true
		token = p.Lexer.Next()
	}
	if token.Type != lexer.NUMBER {
		p.Error.MissError("Syntax Error", token.Cursor,
			"enum "+enumName+" member "+member+" needs an integer value")
	}
	value, err := parseNumberLiteral(token.Value)
	if err != nil {
		p.Error.MissError("Syntax Error", token.Cursor,
			"invalid enum value for "+enumName+"."+member+": "+err.Error())
	}
	if value != float64(int64(value)) {
		p.Error.MissError("Syntax Error", token.Cursor,
			"enum "+enumName+" member "+member+" value must be an integer")
	}
	if negative {
		value = -value
	}
	return value
}

// addEnumMember 把一个枚举成员注册成和 `const NAME: int = value` 等价的变量块。
func (p *Parser) addEnumMember(name string, value float64, cursor int) {
	valueType := typeSys.GetSystemType("int")
	if value > 2147483647 || value < -2147483648 {
		valueType = typeSys.GetSystemType("i64")
	}
	block := &VarBlock{
		Name:          NewName(name),
		IsConst:       true,
		IsDefine:      true,
		IsInitialized: true,
		StartCursor:   cursor,
		Type:          valueType,
		Value: &Expression{
			Num:  value,
			Type: valueType,
		},
	}
	block.IsGlobal = p.ThisBlock == p.Block
	if block.IsGlobal && p.Package != nil && p.Package.Path != "" {
		packageFmt.RegisterGlobalVar(p.Package.Path, name, block)
	}
	p.AddChild(&Node{Value: block})
}
