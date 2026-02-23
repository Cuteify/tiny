package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strings"
)

type FieldAccess int

const (
	AccessPublic FieldAccess = iota
	AccessPrivate
	AccessReadOnly
	AccessWriteOnly
)

type StructTag struct {
	Key   string
	Value string
}

type StructField struct {
	Name         string
	Type         typeSys.Type
	DefaultValue *Expression
	Tags         []StructTag
	Offset       int
	Size         int
	Alignment    int
	EndCursor    int
	StartCursor  int
	Access       FieldAccess
}

type StructBlock struct {
	Name        string
	Parents     []string
	Fields      []*StructField
	Methods     []*FuncBlock
	StartCursor int
	EndCursor   int
	Size        int
	Alignment   int
	Checked     bool
}

func (f *StructField) IsPrivate() bool {
	return f.Access == AccessPrivate
}

func (f *StructField) IsReadOnly() bool {
	return f.Access == AccessReadOnly
}

func (f *StructField) IsWriteOnly() bool {
	return f.Access == AccessWriteOnly
}

func (f *StructField) IsPublic() bool {
	return f.Access == AccessPublic
}

func (f *StructField) CanRead() bool {
	return f.Access == AccessPublic || f.Access == AccessReadOnly
}

func (f *StructField) CanWrite() bool {
	return f.Access == AccessPublic || f.Access == AccessWriteOnly
}

func (s *StructBlock) Parse(p *Parser) {
	token := p.Lexer.Next()
	if token.Type != lexer.NAME && token.Type != lexer.IDENTIFIER {
		p.Error.MissError("Struct Error", token.Cursor, "struct name required")
	}
	s.Name = token.Value

	if !utils.CheckName(s.Name) {
		p.Error.MissError("Struct Error", token.Cursor, "invalid struct name: '"+s.Name+"'")
	}

	s.StartCursor = p.Lexer.Cursor

	nextToken := p.Lexer.Next()
	if nextToken.Type == lexer.SEPARATOR && nextToken.Value == ":" {
		s.Parents = p.parseStructInheritance()
		openBraceToken := p.Lexer.Next()
		if openBraceToken.Value != "{" {
			p.Error.MissError("Struct Error", openBraceToken.Cursor, "expected '{'")
		}
	} else {
		if nextToken.Value != "{" {
			p.Error.MissError("Struct Error", nextToken.Cursor, "expected '{'")
		}
	}

	p.CurrentStruct = s
	p.parseStructFields(s)
	p.CurrentStruct = nil
	s.CalculateMemoryLayout()
}

func (p *Parser) parseStructInheritance() []string {
	var parents []string

	token := p.Lexer.Next()
	if token.Type != lexer.NAME && token.Type != lexer.IDENTIFIER {
		p.Error.MissError("Struct Error", token.Cursor, "parent struct name required")
	}
	parents = append(parents, token.Value)

	for {
		token = p.Lexer.Next()
		if token.Value != "+" {
			p.Lexer.SetCursor(token.Cursor)
			break
		}

		token = p.Lexer.Next()
		if token.Type != lexer.NAME && token.Type != lexer.IDENTIFIER {
			p.Error.MissError("Struct Error", token.Cursor, "parent struct name required")
		}
		parents = append(parents, token.Value)
	}

	return parents
}

func (p *Parser) parseStructFields(s *StructBlock) {
	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Struct Error", p.Lexer.Cursor, "unexpected EOF in struct")
		}

		if token.Value == "}" {
			s.EndCursor = token.Cursor
			break
		}

		if token.Type == lexer.FUNC {
			method := p.parseStructMethod(s)
			if method != nil {
				s.Methods = append(s.Methods, method)
			}
			continue
		}

		if token.Type == lexer.SEPARATOR {
			if token.Value == "!" || token.Value == "?" {
				p.Lexer.SetCursor(token.Cursor)
				field := p.parseStructField()
				if field != nil {
					s.Fields = append(s.Fields, field)
				}
				continue
			}
			continue
		}

		p.Lexer.SetCursor(token.Cursor)
		field := p.parseStructField()
		if field != nil {
			s.Fields = append(s.Fields, field)
		}
	}
}

func (p *Parser) parseStructMethod(s *StructBlock) *FuncBlock {
	method := &FuncBlock{
		Class: createStructType(s),
	}

	code := p.Lexer.Next()
	if code.Type != lexer.NAME {
		p.Error.MissError("Method Error", p.Lexer.Cursor, "method name required")
		return nil
	}

	method.Name = Name([]string{s.Name, code.Value})

	method.ParseArgs(p)

	code = p.Lexer.Next()
	if code.Type == lexer.NAME {
		method.Return = []typeSys.Type{typeSys.GetSystemType(code.Value)}
	} else {
		p.Lexer.SetCursor(code.Cursor)
		method.Return = []typeSys.Type{}
	}

	p.Wait("{")
	nodeTmp := &Node{Value: method}
	p.ThisBlock.AddChild(nodeTmp)
	p.ThisBlock = nodeTmp

	p.parseMethodBody()

	return method
}

func (p *Parser) parseMethodBody() {
	braceCount := 1
	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Method Error", p.Lexer.Cursor, "unexpected EOF in method body")
			return
		}

		if token.Value == "{" {
			braceCount++
		} else if token.Value == "}" {
			braceCount--
			if braceCount == 0 {
				p.ThisBlock = p.ThisBlock.Father
				return
			}
		}

		p.Lexer.SetCursor(token.Cursor)
		p.Next()
	}
}

func (p *Parser) parseStructField() *StructField {
	field := &StructField{Access: AccessPublic}
	field.StartCursor = p.Lexer.Cursor

	token := p.Lexer.Next()

	if token.Type == lexer.SEPARATOR {
		switch token.Value {
		case "!":
			field.Access = AccessReadOnly
		case "?":
			field.Access = AccessWriteOnly
		default:
			p.Error.MissError("Struct Error", token.Cursor, "invalid field prefix: '"+token.Value+"'")
		}
		token = p.Lexer.Next()
	}

	if token.Type != lexer.NAME && token.Type != lexer.IDENTIFIER {
		p.Error.MissError("Struct Error", token.Cursor, "field name required")
	}

	p.Lexer.SetCursor(token.Cursor)
	name, _ := p.Name(false)
	fieldName := name.String()

	if !utils.CheckName(fieldName) {
		p.Error.MissError("Struct Error", token.Cursor, "invalid field name: '"+fieldName+"'")
	}

	field.Name = fieldName

	if len(fieldName) > 0 && fieldName[0] == '_' {
		field.Access = AccessPrivate
	}

	token = p.Lexer.Next()
	if token.Value != ":" {
		p.Error.MissError("Struct Error", token.Cursor, "expected ':' after field name")
	}

	typeToken := p.Lexer.Next()
	if typeToken.Type != lexer.NAME && typeToken.Type != lexer.IDENTIFIER {
		p.Error.MissError("Struct Error", typeToken.Cursor, "field type required")
	}
	field.Type = p.findType(typeToken.Value)

	nextToken := p.Lexer.Next()
	switch nextToken.Value {
	case "`":
		p.Lexer.SetCursor(nextToken.Cursor)
		field.Tags = p.parseStructTags()
		nextToken = p.Lexer.Next()
		if nextToken.Value == "=" {
			field.DefaultValue = p.ParseExpression(p.FindEndCursor())
		} else {
			p.Lexer.SetCursor(nextToken.Cursor)
		}
	case "=":
		field.DefaultValue = p.ParseExpression(p.FindEndCursor())
	case ";", "\n", "}":
		p.Lexer.SetCursor(nextToken.Cursor)
		return field
	default:
		p.Lexer.SetCursor(nextToken.Cursor)
		return field
	}

	return field
}

func (p *Parser) parseStructTags() []StructTag {
	var tags []StructTag

	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Struct Error", p.Lexer.Cursor, "expected '`' to close tags")
		}

		if token.Value == "`" {
			break
		}

		if token.Type != lexer.NAME && token.Type != lexer.IDENTIFIER {
			p.Error.MissError("Struct Error", token.Cursor, "tag key required")
		}
		key := token.Value

		token = p.Lexer.Next()
		if token.Value != ":" {
			p.Error.MissError("Struct Error", token.Cursor, "expected ':' after tag key")
		}

		token = p.Lexer.Next()
		if token.Type == lexer.STRING {
			value := strings.Trim(token.Value, "\"")
			tags = append(tags, StructTag{Key: key, Value: value})
		} else if token.Type == lexer.NAME || token.Type == lexer.IDENTIFIER {
			tags = append(tags, StructTag{Key: key, Value: token.Value})
		} else {
			p.Error.MissError("Struct Error", token.Cursor, "tag value required")
		}
	}

	return tags
}

func (p *Parser) findType(typeName string) typeSys.Type {
	switch typeName {
	case "int", "float", "uint", "i64", "u64", "f64", "bool", "byte",
		"i32", "u32", "f32", "i16", "u16", "i8", "u8":
		return typeSys.GetSystemType(typeName)
	default:
		if sb := p.FindStruct(typeName); sb != nil {
			return createStructType(sb)
		}
		return typeSys.GetSystemType("int")
	}
}

func createStructType(sb *StructBlock) typeSys.Type {
	return &typeSys.StructType{
		RType: typeSys.RType{
			TypeName: sb.Name,
			RSize:    sb.Size,
		},
		StructFields: convertStructFields(sb.Fields),
	}
}

func convertStructFields(fields []*StructField) typeSys.StructFileds {
	var result typeSys.StructFileds
	for _, f := range fields {
		result = append(result, &typeSys.StructField{
			Name:   f.Name,
			Type:   f.Type,
			Offset: f.Offset,
		})
	}
	return result
}

func (s *StructBlock) Check(p *Parser) bool {
	if s.Checked {
		return true
	}
	s.Checked = true

	if len(s.Parents) > 0 {
		s.processInheritance(p)
	}

	s.CalculateMemoryLayout()
	return true
}

func (s *StructBlock) processInheritance(p *Parser) {
	var inheritedFields []*StructField

	for _, parentName := range s.Parents {
		parent := p.FindStruct(parentName)
		if parent == nil {
			p.Error.MissError("Struct Error", s.StartCursor,
				"parent struct '"+parentName+"' not found")
			continue
		}
		parent.Check(p)
		for _, field := range parent.Fields {
			newField := &StructField{
				Name:   field.Name,
				Type:   field.Type,
				Tags:   field.Tags,
				Access: field.Access,
			}
			inheritedFields = append(inheritedFields, newField)
		}
	}
	s.Fields = append(inheritedFields, s.Fields...)
}

func (s *StructBlock) CalculateMemoryLayout() {
	offset := 0
	maxAlignment := 1

	for _, field := range s.Fields {
		var alignment int
		if field.Type != nil {
			size := field.Type.Size()
			if size == 0 {
				alignment = 1
			} else {
				alignment = size
			}
		} else {
			alignment = 1
		}
		field.Alignment = alignment
		if field.Alignment > maxAlignment {
			maxAlignment = field.Alignment
		}

		if field.Alignment > 0 {
			padding := (field.Alignment - (offset % field.Alignment)) % field.Alignment
			offset += padding
		}
		field.Offset = offset

		if field.Type != nil {
			field.Size = field.Type.Size()
			if field.Size == 0 {
				field.Size = 1
			}
		} else {
			field.Size = 1
		}
		offset += field.Size
		typeStr := ""
		if field.Type != nil {
			typeStr = field.Type.Type()
		} else {
			typeStr = "unknown"
		}
		field.EndCursor = field.StartCursor + len(field.Name) + len(typeStr) + 5
	}

	s.Size = offset
	s.Alignment = maxAlignment
}

func (s *StructBlock) GetFieldByName(name string) *StructField {
	for _, field := range s.Fields {
		if field.Name == name {
			return field
		}
	}
	return nil
}

func (s *StructBlock) HasField(name string) bool {
	return s.GetFieldByName(name) != nil
}

func (s *StructBlock) GetPublicFields() []*StructField {
	var publicFields []*StructField
	for _, field := range s.Fields {
		if field.Access == AccessPublic {
			publicFields = append(publicFields, field)
		}
	}
	return publicFields
}

func (s *StructBlock) GetPrivateFields() []*StructField {
	var privateFields []*StructField
	for _, field := range s.Fields {
		if field.Access == AccessPrivate {
			privateFields = append(privateFields, field)
		}
	}
	return privateFields
}

func (s *StructBlock) GetSize() int {
	return s.Size
}

func (s *StructBlock) GetAlignment() int {
	return s.Alignment
}
