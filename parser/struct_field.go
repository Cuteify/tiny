package parser

import (
	"cuteify/lexer"
)

func (p *Parser) parseStructField() *StructField {
	field := &StructField{Access: AccessPublic}
	field.StartCursor = p.Lexer.Cursor

	token := p.Lexer.Next()

	if token.Type == lexer.SEPARATOR && (token.Value == "!" || token.Value == "?") {
		switch token.Value {
		case "!":
			field.Access = AccessReadOnly
		case "?":
			field.Access = AccessWriteOnly
		}
		token = p.Lexer.Next()
	}

	if token.Type != lexer.NAME && token.Type != lexer.IDENTIFIER {
		p.Error.MissError("Struct Error", token.Cursor, "field name required")
	}

	field.Name = token.Value

	p.Lexer.Skip(':')

	typeToken := p.Lexer.Next()
	if typeToken.Type != lexer.NAME && typeToken.Type != lexer.IDENTIFIER {
		p.Error.MissError("Struct Error", typeToken.Cursor, "field type required")
	}
	field.Type = p.findType(typeToken.Value)

	typeEndCursor := typeToken.EndCursor
	lineEnd := p.FindEndCursor()

	if typeEndCursor < lineEnd {
		p.Lexer.SetCursor(typeEndCursor)

		for p.Lexer.Cursor < lineEnd {
			if p.Lexer.Text[p.Lexer.Cursor] == ' ' {
				p.Lexer.Cursor++
				continue
			}

			if p.Lexer.Text[p.Lexer.Cursor] == '`' {
				p.Lexer.Cursor++
				tagEnd := p.Lexer.Cursor
				for tagEnd < len(p.Lexer.Text) && p.Lexer.Text[tagEnd] != '`' {
					tagEnd++
				}
				tagValue := p.Lexer.Text[p.Lexer.Cursor:tagEnd]
				parts := parseTagString(tagValue)
				for _, part := range parts {
					kv := splitTagKeyValue(part)
					field.Tags = append(field.Tags, StructTag{Key: kv[0], Value: kv[1]})
				}
				p.Lexer.Cursor = tagEnd + 1
				continue
			}

			if p.Lexer.Text[p.Lexer.Cursor] == '=' {
				p.Lexer.Cursor++
				p.Lexer.Skip(' ')
				field.DefaultValue = p.ParseExpression(lineEnd)
				p.Lexer.SetCursor(lineEnd)
				return field
			}

			break
		}
	}

	p.Lexer.SetCursor(lineEnd)
	return field
}

func parseTagString(s string) []string {
	var result []string
	var current []rune
	inQuote := false

	for _, r := range s {
		if r == '"' {
			inQuote = !inQuote
			current = append(current, r)
		} else if r == ' ' && !inQuote {
			if len(current) > 0 {
				result = append(result, string(current))
				current = nil
			}
		} else {
			current = append(current, r)
		}
	}

	if len(current) > 0 {
		result = append(result, string(current))
	}

	return result
}

func splitTagKeyValue(s string) []string {
	for i, r := range s {
		if r == ':' {
			key := s[:i]
			value := s[i+1:]
			value = value[1 : len(value)-1]
			return []string{key, value}
		}
	}
	return []string{s, ""}
}
