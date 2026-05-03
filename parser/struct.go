package parser

import (
	typeSys "cuteify/type"
	"unsafe"
)

type StructType struct {
	typeSys.RType
	Name         Name
	StructFields typeSys.StructFileds
	Methods      []any
}

func (s *StructType) ToType() *typeSys.StructType {
	return (*typeSys.StructType)(unsafe.Pointer(s))
}

func (s *StructType) FromType(st *typeSys.StructType) {
	*s = *(*StructType)(unsafe.Pointer(st))
}

type StructBlock struct {
	StructType
	Checked     bool
	StartCursor int
}

// TODO: func (s *StructBlock) Parse(p *Parser) {
// TODO: 	token := p.Lexer.Next()
// TODO: 	if token.Type != lexer.NAME {
// TODO: 		p.Error.MissError("Struct Error", token.Cursor, "struct name required")
// TODO: 	}
// TODO: 	s.Name = Name([]string{token.Value})
// TODO:
// TODO: 	if !utils.CheckName(s.Name.String()) {
// TODO: 		p.Error.MissError("Struct Error", token.Cursor, "invalid struct name: '"+s.Name.String()+"'")
// TODO: 	}
// TODO:
// TODO: 	nextToken := p.Lexer.Next()
// TODO: 	if nextToken.Type == lexer.SEPARATOR && nextToken.Value == ":" {
// TODO: 		s.RParents = s.parseInheritance(p)
// TODO: 		openBraceToken := p.Lexer.Next()
// TODO: 		if openBraceToken.Value != "{" {
// TODO: 			p.Error.MissError("Struct Error", openBraceToken.Cursor, "expected '{'")
// TODO: 		}
// TODO: 	} else {
// TODO: 		if nextToken.Value != "{" {
// TODO: 			p.Error.MissError("Struct Error", nextToken.Cursor, "expected '{'")
// TODO: 		}
// TODO: 	}
// TODO:
// TODO: 	p.CurrentStruct = s
// TODO: 	s.parseFields(p)
// TODO: 	p.CurrentStruct = nil
// TODO: 	s.CalculateMemoryLayout()
// TODO: }

// TODO: func (s *StructBlock) parseInheritance(p *Parser) []string {
// TODO: 	var parents []string
// TODO:
// TODO: 	token := p.Lexer.Next()
// TODO: 	if token.Type != lexer.NAME {
// TODO: 		p.Error.MissError("Struct Error", token.Cursor, "parent struct name required")
// TODO: 	}
// TODO: 	parents = append(parents, token.Value)
// TODO:
// TODO: 	for {
// TODO: 		token = p.Lexer.Next()
// TODO: 		if token.Value != "+" {
// TODO: 			p.Lexer.SetCursor(token.Cursor)
// TODO: 			break
// TODO: 		}
// TODO:
// TODO: 		token = p.Lexer.Next()
// TODO: 		if token.Type != lexer.NAME {
// TODO: 			p.Error.MissError("Struct Error", token.Cursor, "parent struct name required")
// TODO: 		}
// TODO: 		parents = append(parents, token.Value)
// TODO: 	}
// TODO:
// TODO: 	return parents
// TODO: }

// TODO: func (s *StructBlock) parseFields(p *Parser) {
// TODO: 	for {
// TODO: 		token := p.Lexer.Next()
// TODO: 		fmt.Println(token)
// TODO: 		if token.IsEmpty() {
// TODO: 			p.Error.MissError("Struct Error", p.Lexer.Cursor, "unexpected EOF in struct")
// TODO: 		}
// TODO:
// TODO: 		if token.Value == "}" {
// TODO: 			break
// TODO: 		}
// TODO:
// TODO: 		s.parseField(p)
// TODO: 	}
// TODO: }

// TODO: func (p *Parser) parseStructMethod(s *StructBlock) *FuncBlock {
// TODO: 	method := &FuncBlock{
// TODO: 		Class: createStructType(s),
// TODO: 	}
// TODO:
// TODO: 	code := p.Lexer.Next()
// TODO: 	if code.Type != lexer.NAME {
// TODO: 		p.Error.MissError("Method Error", p.Lexer.Cursor, "method name required")
// TODO: 		return nil
// TODO: 	}
// TODO:
// TODO: 	method.Name = append(s.Name, code.Value)
// TODO:
// TODO: 	method.ParseArgs(p)
// TODO:
// TODO: 	code = p.Lexer.Next()
// TODO: 	if code.Type == lexer.NAME {
// TODO: 		method.Return = []typeSys.Type{typeSys.GetSystemType(code.Value)}
// TODO: 	} else {
// TODO: 		p.Lexer.SetCursor(code.Cursor)
// TODO: 		method.Return = []typeSys.Type{}
// TODO: 	}
// TODO:
// TODO: 	p.Wait("{")
// TODO: 	nodeTmp := &Node{Value: method}
// TODO: 	p.ThisBlock.AddChild(nodeTmp)
// TODO: 	p.ThisBlock = nodeTmp
// TODO:
// TODO: 	p.parseMethodBody()
// TODO:
// TODO: 	return method
// TODO: }

// TODO: func (p *Parser) parseMethodBody() {
// TODO: 	braceCount := 1
// TODO: 	for {
// TODO: 		token := p.Lexer.Next()
// TODO: 		if token.IsEmpty() {
// TODO: 			p.Error.MissError("Method Error", p.Lexer.Cursor, "unexpected EOF in method body")
// TODO: 			return
// TODO: 		}
// TODO:
// TODO: 		if token.Value == "{" {
// TODO: 			braceCount++
// TODO: 		} else if token.Value == "}" {
// TODO: 			braceCount--
// TODO: 			if braceCount == 0 {
// TODO: 				p.ThisBlock = p.ThisBlock.Father
// TODO: 				return
// TODO: 			}
// TODO: 		}
// TODO:
// TODO: 		p.Lexer.SetCursor(token.Cursor)
// TODO: 		p.Next()
// TODO: 	}
// TODO: }

// TODO: func (s *StructBlock) parseField(p *Parser) {
// TODO: 	field := &StructField{Access: AccessPublic}
// TODO: 	field.StartCursor = p.Lexer.Cursor
// TODO:
// TODO: 	// 解析字段标识
// TODO: 	token := p.Lexer.Next()
// TODO:
// TODO: 	if token.Type == lexer.SEPARATOR {
// TODO: 		switch token.Value {
// TODO: 		case "!":
// TODO: 			field.Access = AccessReadOnly
// TODO: 		case "?":
// TODO: 			field.Access = AccessWriteOnly
// TODO: 		default:
// TODO: 			p.Error.MissError("Struct Error", token.Cursor, "invalid field prefix: '"+token.Value+"'")
// TODO: 		}
// TODO: 	} else {
// TODO: 		p.Lexer.SetCursor(token.Cursor)
// TODO: 	}
// TODO:
// TODO: 	// 解析字段名
// TODO: 	s.parseFieldName(p, field)
// TODO:
// TODO: 	// 解析字段类型
// TODO: 	s.parseFieldType(p, field)
// TODO:
// TODO: 	// 其他数据
// TODO: 	stopCursor := p.Lexer.Cursor
// TODO: 	for p.Lexer.Cursor < stopCursor {
// TODO: 		s.parseFieldOthers(p, field)
// TODO: 	}
// TODO: }

// TODO: func (s *StructBlock) parseFieldType(p *Parser, field *StructField) {
// TODO: 	// 跳过：
// TODO: 	p.Lexer.Skip(':')
// TODO:
// TODO: 	name, _ := p.Name(false)
// TODO:
// TODO: 	field.Type = typeSys.GetSystemType(name.String())
// TODO: }

// TODO: func (s *StructBlock) parseFieldName(p *Parser, field *StructField) {
// TODO: 	name, _ := p.Name(false)
// TODO:
// TODO: 	field.Name = name.Last()
// TODO:
// TODO: 	if len(name) > 0 && name.Last()[0] == '_' {
// TODO: 		field.Access = AccessPrivate
// TODO: 	}
// TODO: }

// TODO: func (s *StructBlock) parseFieldOthers(p *Parser, field *StructField) {
// TODO: 	// 其他数据
// TODO: 	nextToken := p.Lexer.Next()
// TODO: 	if nextToken.Type == lexer.RAW {
// TODO: 		field.parseTags(nextToken.Value)
// TODO: 	}
// TODO: 	switch nextToken.Value {
// TODO: 	case "=":
// TODO: 		field.DefaultValue = p.ParseExp(p.FindEndCursor())
// TODO: 	case ";", "\n", "\r", "}":
// TODO: 		s.Fields = append(s.Fields, field)
// TODO: 	}
// TODO: }

// TODO: func convertStructFields(fields []*StructField) typeSys.StructFileds {
// TODO: 	var result typeSys.StructFileds
// TODO: 	for _, f := range fields {
// TODO: 		result = append(result, &typeSys.StructField{
// TODO: 			Name:   f.Name,
// TODO: 			Type:   f.Type,
// TODO: 			Offset: f.Offset,
// TODO: 		})
// TODO: 	}
// TODO: 	return result
// TODO: }

// TODO: func (s *StructBlock) Check(p *Parser) bool {
// TODO: 	if s.Checked {
// TODO: 		return true
// TODO: 	}
// TODO: 	s.Checked = true
// TODO:
// TODO: 	if len(s.Parents) > 0 {
// TODO: 		s.processInheritance(p)
// TODO: 	}
// TODO:
// TODO: 	s.CalculateMemoryLayout()
// TODO: 	return true
// TODO: }

// TODO: func (s *StructBlock) processInheritance(p *Parser) {
// TODO: 	var inheritedFields []*StructField
// TODO:
// TODO: 	for _, parentName := range s.Parents {
// TODO: 		parent := p.FindStruct(parentName)
// TODO: 		if parent == nil {
// TODO: 			p.Error.MissError("Struct Error", s.StartCursor,
// TODO: 				"parent struct '"+parentName+"' not found")
// TODO: 			continue
// TODO: 		}
// TODO: 		parent.Check(p)
// TODO: 		for _, field := range parent.Fields {
// TODO: 			newField := &StructField{
// TODO: 				Name:   field.Name,
// TODO: 				Type:   field.Type,
// TODO: 				Tags:   field.Tags,
// TODO: 				Access: field.Access,
// TODO: 			}
// TODO: 			inheritedFields = append(inheritedFields, newField)
// TODO: 		}
// TODO: 	}
// TODO: 	s.Fields = append(inheritedFields, s.Fields...)
// TODO: }

// TODO: func (s *StructBlock) CalculateMemoryLayout() {
// TODO: 	offset := 0
// TODO: 	maxAlignment := 1
// TODO:
// TODO: 	for _, field := range s.Fields {
// TODO: 		var alignment int
// TODO: 		if field.Type != nil {
// TODO: 			size := field.Type.Size()
// TODO: 			if size == 0 {
// TODO: 				alignment = 1
// TODO: 			} else {
// TODO: 				alignment = size
// TODO: 			}
// TODO: 		} else {
// TODO: 			alignment = 1
// TODO: 		}
// TODO: 		field.Alignment = alignment
// TODO: 		if field.Alignment > maxAlignment {
// TODO: 			maxAlignment = field.Alignment
// TODO: 		}
// TODO:
// TODO: 		if field.Alignment > 0 {
// TODO: 			padding := (field.Alignment - (offset % field.Alignment)) % field.Alignment
// TODO: 			offset += padding
// TODO: 		}
// TODO: 		field.Offset = offset
// TODO:
// TODO: 		if field.Type != nil {
// TODO: 			field.Size = field.Type.Size()
// TODO: 			if field.Size == 0 {
// TODO: 				field.Size = 1
// TODO: 			}
// TODO: 		} else {
// TODO: 			field.Size = 1
// TODO: 		}
// TODO: 		offset += field.Size
// TODO: 		typeStr := ""
// TODO: 		if field.Type != nil {
// TODO: 			typeStr = field.Type.Type()
// TODO: 		} else {
// TODO: 			typeStr = "unknown"
// TODO: 		}
// TODO: 		field.EndCursor = field.StartCursor + len(field.Name) + len(typeStr) + 5
// TODO: 	}
// TODO:
// TODO: 	s.Size = offset
// TODO: 	s.Alignment = maxAlignment
// TODO: }

// TODO: func (s *StructBlock) GetFieldByName(fieldName any) *StructField {
// TODO: 	var searchName string
// TODO: 	switch n := fieldName.(type) {
// TODO: 	case Name:
// TODO: 		searchName = n.String()
// TODO: 	case string:
// TODO: 		searchName = n
// TODO: 	default:
// TODO: 		return nil
// TODO: 	}
// TODO:
// TODO: 	for _, field := range s.Fields {
// TODO: 		if field.Name == searchName {
// TODO: 			return field
// TODO: 		}
// TODO: 	}
// TODO: 	return nil
// TODO: }

// TODO: func (s *StructBlock) Type() typeSys.Type {
// TODO: 	return s.ToType()
// TODO: }
