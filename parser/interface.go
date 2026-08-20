package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
)

type InterfaceMethod struct {
	Name    Name
	Args    []*ArgBlock
	Returns []typeSys.Type
}

type InterfaceDef struct {
	Methods   []InterfaceMethod
	EndCursor int
}

func (i *InterfaceDef) Parse(p *Parser) {
	token := p.Lexer.Next()
	if token.Value != "{" {
		p.Error.MissError("Interface Error", token.Cursor, "expected '{'")
	}

	braceCount := 1

	for braceCount > 0 {
		token = p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Interface Error", p.Lexer.Cursor, "unexpected EOF in interface")
		}

		switch token.Value {
		case "}":
			braceCount--
			if braceCount == 0 {
				i.EndCursor = token.Cursor
			}
		case "{":
			braceCount++
		case "\n", "\r", ";":
		default:
			p.Lexer.SetCursor(token.Cursor)
			i.parseMethod(p)
		}
	}
}

func (i *InterfaceDef) parseMethod(p *Parser) {
	methodName, _ := p.ParseName(false)
	if methodName.IsEmpty() {
		p.Error.MissError("Interface Error", p.Lexer.Cursor, "method name required")
		return
	}

	method := InterfaceMethod{Name: methodName}

	token := p.Lexer.Next()
	if token.Value != "(" {
		p.Error.MissError("Interface Error", token.Cursor, "expected '(' after method name")
		return
	}

	p.Lexer.SetCursor(token.Cursor)
	method.Args = i.parseMethodArgs(p)

	retToken := p.Lexer.Next()
	if retToken.Type == lexer.NAME {
		p.Lexer.SetCursor(retToken.Cursor)
		retName, _ := p.ParseName(false)
		results := p.Find(retName, FindTypeType)
		if len(results) > 0 {
			if t, ok := results[0].Value.(typeSys.Type); ok {
				method.Returns = append(method.Returns, t)
			}
		}
	} else {
		p.Lexer.SetCursor(retToken.Cursor)
	}

	i.Methods = append(i.Methods, method)
}

func (i *InterfaceDef) parseMethodArgs(p *Parser) []*ArgBlock {
	p.Lexer.Skip('(')

	var args []*ArgBlock
	token := p.Lexer.Next()

	if token.Value == ")" {
		return args
	}

	p.Lexer.SetCursor(token.Cursor)

	for {
		argName, _ := p.ParseName(false)
		arg := &ArgBlock{Name: argName}

		colonToken := p.Lexer.Next()
		if colonToken.Value == ":" {
			typeName, _ := p.ParseName(false)
			results := p.Find(typeName, FindTypeType)
			if len(results) > 0 {
				if tb, ok := results[0].Value.(*TypeBlock); ok {
					arg.Type = tb.Type()
				}
			}
		} else {
			p.Lexer.SetCursor(colonToken.Cursor)
		}

		args = append(args, arg)

		nextToken := p.Lexer.Next()
		if nextToken.Value == ")" {
			break
		}
		if nextToken.Value != "," {
			p.Lexer.SetCursor(nextToken.Cursor)
			break
		}
	}

	return args
}
