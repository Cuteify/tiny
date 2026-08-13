package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
)

type StructBlock struct {
	Type      typeSys.StructType
	EndCursor int
}

func (s *StructBlock) Parse(p *Parser) {
	// 读取结构体名称
	nameToken := p.Lexer.Next()
	if nameToken.Type != lexer.NAME {
		p.Error.MissError("Struct Error", nameToken.Cursor, "expected struct name")
	}
	s.Type.TypeName = nameToken.Value

	// 检查是否有继承（: ParentStruct）
	token := p.Lexer.Next()
	if token.Value == "struct" {
		// type 声明形式（type Name struct），跳过 struct 关键字
		token = p.Lexer.Next()
	}
	if token.Value == ":" {
		// 读取父结构体名称
		parentToken := p.Lexer.Next()
		if parentToken.Type != lexer.NAME {
			p.Error.MissError("Struct Error", parentToken.Cursor, "expected parent struct name")
		}
		// TODO: 处理继承
		token = p.Lexer.Next()
	}

	if token.Value != "{" {
		p.Error.MissError("Struct Error", token.Cursor, "expected '{'")
	}

	braceCount := 1

	for braceCount > 0 {
		token = p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Struct Error", p.Lexer.Cursor, "unexpected EOF in struct")
		}

		switch token.Value {
		case "}":
			braceCount--
			if braceCount == 0 {
				s.EndCursor = token.Cursor
			}
		case "{":
			braceCount++
		case "\n", "\r", ";":
		default:
			p.Lexer.SetCursor(token.Cursor)
			s.parseLine(p)
		}
	}
}

func (s *StructBlock) parseLine(p *Parser) {
	token := p.Lexer.Next()
	if token.IsEmpty() {
		return
	}

	switch {
	case token.Value == "@":
		parentName, _ := p.ParseName(false)
		s.Type.StructFields = append(s.Type.StructFields, &typeSys.StructField{
			ParentName: parentName.String(),
			IsAnon:     true,
		})
		s.skipLineEnd(p)

	case token.Value == "!":
		s.parseField(p, "", typeSys.AccessReadOnly)

	case token.Value == "?":
		s.parseField(p, "", typeSys.AccessWriteOnly)

	case token.Type == lexer.NAME:
		nextToken := p.Lexer.Next()

		switch nextToken.Value {
		case "@":
			parentName, _ := p.ParseName(false)
			s.Type.StructFields = append(s.Type.StructFields, &typeSys.StructField{
				Alias:      token.Value,
				ParentName: parentName.String(),
				IsAnon:     false,
			})
			s.skipLineEnd(p)

		case ":":
			s.parseFieldType(p, token.Value, typeSys.AccessPublic)

		default:
			p.Lexer.SetCursor(nextToken.Cursor)
		}

	case token.Value == "}", token.Value == "{":
		p.Lexer.SetCursor(token.Cursor)

	default:
		s.skipLineEnd(p)
	}
}

func (s *StructBlock) parseField(p *Parser, _ string, access typeSys.FieldAccess) {
	nameToken := p.Lexer.Next()
	if nameToken.Type != lexer.NAME {
		p.Error.MissError("Struct Error", nameToken.Cursor, "expected field name")
	}
	s.parseFieldWithName(p, nameToken.Value, access)
}

func (s *StructBlock) parseFieldWithName(p *Parser, fieldName string, access typeSys.FieldAccess) {
	if len(fieldName) > 0 && fieldName[0] == '_' {
		access = typeSys.AccessPrivate
	}

	colon := p.Lexer.Next()
	if colon.Value != ":" {
		p.Error.MissError("Struct Error", colon.Cursor, "expected ':' after field name")
	}

	s.parseFieldType(p, fieldName, access)
}

func (s *StructBlock) parseFieldType(p *Parser, fieldName string, access typeSys.FieldAccess) {
	if len(fieldName) > 0 && fieldName[0] == '_' {
		access = typeSys.AccessPrivate
	}

	fieldType := p.parseTypeAnnotation()
	if fieldType == nil {
		p.Error.MissError("Type Error", p.Lexer.Cursor, "type expected")
	}

	field := &typeSys.StructField{
		Name:   fieldName,
		Type:   fieldType,
		Access: access,
	}

	s.parseFieldTail(p, field)
	s.Type.StructFields = append(s.Type.StructFields, field)
}

func (s *StructBlock) parseFieldTail(p *Parser, field *typeSys.StructField) {
	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			return
		}

		switch {
		case token.Value == "=":
			endCursor := p.FindEndCursor()
			field.Default = p.ParseExp(endCursor)
		case token.Type == lexer.RAW:
			field.ParseTags(token.Value)
		case token.Value == "\n", token.Value == "\r", token.Value == ";":
			return
		case token.Value == "}":
			p.Lexer.SetCursor(token.Cursor)
			return
		default:
			p.Lexer.SetCursor(token.Cursor)
			return
		}
	}
}

func (s *StructBlock) skipLineEnd(p *Parser) {
	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			return
		}
		if token.Value == "\n" || token.Value == "\r" || token.Value == ";" {
			return
		}
		if token.Value == "}" {
			p.Lexer.SetCursor(token.Cursor)
			return
		}
	}
}
