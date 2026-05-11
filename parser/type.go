package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
)

type TypeBlock struct {
	Type typeSys.Type
	Name Name
}

func (t *TypeBlock) Parse(p *Parser) {
	code := p.Lexer.Next()
	if code.Type != lexer.NAME && code.Type != lexer.TYPE {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need type name")
		return
	}
	t.Name = Name([]string{code.Value})

	code = p.Lexer.Next()
	if code.Type != lexer.TYPE || code.Value != "struct" {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need 'struct'")
		return
	}

	p.Wait("{")

	st := &typeSys.StructType{
		RType: typeSys.RType{
			TypeName: t.Name.String(),
		},
	}
	offset := 0

	for {
		code := p.Lexer.Next()
		if code.IsEmpty() {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "unexpected EOF in struct")
			return
		}
		if code.Value == "}" && code.Type == lexer.SEPARATOR {
			break
		}

		fieldName := ""
		if code.Type == lexer.SEPARATOR && (code.Value == "!" || code.Value == "?") {
			// skip access modifier
		} else if code.Type == lexer.NAME {
			fieldName = code.Value
		} else if code.Value == "_" {
			fieldName = "_"
		}

		if fieldName == "" {
			if code.Type == lexer.SEPARATOR && (code.Value == "!" || code.Value == "?") {
				nextCode := p.Lexer.Next()
				if nextCode.Type == lexer.NAME {
					fieldName = nextCode.Value
				} else {
					continue
				}
			} else {
				continue
			}
		}

		// expect ':'
		colon := p.Lexer.Next()
		if colon.Value != ":" {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need ':' after field name")
			return
		}

		// field type
		typeCode := p.Lexer.Next()
		fieldType := typeSys.GetSystemType(typeCode.Value)
		if fieldType == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "unknown type '"+typeCode.Value+"'")
			return
		}

		typeSys.NewStructField(st, fieldName, fieldType)
		offset += fieldType.Size()
	}

	t.Type = st

	typeSys.RegisterType(t.Name.String(), st)

	p.ThisBlock.AddChild(&Node{Value: t})
}
