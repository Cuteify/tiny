package parser

import (
	typeSys "cuteify/type"
)

type TypeBlock struct {
	Type typeSys.Type
	Name Name
}

// TODO: func (t *TypeBlock) Parse(p *Parser) {
// TODO: 	tmp := &typeSys.RType{}
// TODO: 	code := p.Lexer.Next()
// TODO: 	if code.Type == lexer.NAME {
// TODO: 		t.Name = Name([]string{code.Value})
// TODO: 		if !utils.CheckName(t.Name.String()) {
// TODO: 			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
// TODO: 		}
// TODO: 		tmp.TypeName = code.Value
// TODO: 		code2 := p.Lexer.Next()
// TODO: 		if code2.Type == lexer.NAME {
// TODO: 			tmp.RParent = t.FindDefine(p, Name([]string{code2.Value}))
// TODO: 		} else if code2.Type == lexer.SEPARATOR && code2.Value == "STRUCT" {
// TODO: 			tmp.TypeName = "STRUCT"
// TODO: 		}
// TODO: 	} else {
// TODO: 		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
// TODO: 	}
// TODO: 	t.Type = tmp
// TODO: }

// TODO: func (t *TypeBlock) FindDefine(p *Parser, name Name) typeSys.Type {
// TODO: 	nameStr := name
// TODO: 	switch nameStr.String() {
// TODO: 	case "int", "float", "uint", "i64", "u64", "f64", "bool", "byte", "i32", "u32", "f32", "i16", "u16", "i8", "u8":
// TODO: 		return typeSys.GetSystemType(nameStr.String())
// TODO: 	}
// TODO: 	if !nameStr.Check() {
// TODO: 		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
// TODO: 	}
// TODO:
// TODO: 	for i := 0; i < len(p.Block.Children); i++ {
// TODO: 		switch p.Block.Children[i].Value.(type) {
// TODO: 		case *TypeBlock:
// TODO: 			tmp := p.Block.Children[i].Value.(*TypeBlock)
// TODO: 			if tmp.Name.String() == name.String() {
// TODO: 				return p.Block.Children[i].Value.(*TypeBlock).Type
// TODO: 			}
// TODO: 		// TODO: case *StructBlock:
// TODO: 		// TODO: 	sb := p.Block.Children[i].Value.(*StructBlock)
// TODO: 		// TODO: 	if sb.Name.Eq(nameStr) {
// TODO: 		// TODO: 		return createStructTypeFromBlock(sb, p)
// TODO: 		// TODO: 	}
// TODO: 		}
// TODO: 	}
// TODO:
// TODO: 	// TODO: if currentStruct := p.getCurrentStruct(); currentStruct != nil {
// TODO: 	// TODO: 	if currentStruct.Name.Eq(nameStr) {
// TODO: 	// TODO: 		return createStructTypeFromBlock(currentStruct, p)
// TODO: 	// TODO: 	}
// TODO: 	// TODO: }
// TODO:
// TODO: 	p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need define "+nameStr.String())
// TODO: 	return nil
// TODO: }

// TODO: func createStructTypeFromBlock(sb *StructBlock, p *Parser) typeSys.Type {
// TODO: 	sb.Check(p)
// TODO: 	return &typeSys.StructType{
// TODO: 		RType: typeSys.RType{
// TODO: 			TypeName: sb.Name.String(),
// TODO: 			RSize:    sb.Size,
// TODO: 		},
// TODO: 		StructFields: convertFieldsFromBlock(sb.Fields),
// TODO: 	}
// TODO: }

// TODO: func convertFieldsFromBlock(fields []*StructField) typeSys.StructFileds {
// TODO: 	var result typeSys.StructFileds
// TODO: 	for _, f := range fields {
// TODO: 		result = append(result, &typeSys.StructField{
// TODO: 			Name:   f.Name.String(),
// TODO: 			Type:   f.Type,
// TODO: 			Offset: f.Offset,
// TODO: 		})
// TODO: 	}
// TODO: 	return result
// TODO: }

// TODO: func (t *TypeBlock) ParseStruct(p *Parser) (name Name, Type typeSys.Type, tag string, Default *Expression) {
// TODO: 	// 解析结构体
// TODO: 	code := p.Lexer.Next()
// TODO: 	if code.Type == lexer.NAME {
// TODO: 		name = Name([]string{code.Value})
// TODO: 		if code := p.Lexer.Next(); code.Type == lexer.SEPARATOR && code.Value == ":" {
// TODO: 			code = p.Lexer.Next()
// TODO: 			if code.Type == lexer.NAME {
// TODO: 				Type = t.FindDefine(p, Name([]string{code.Value}))
// TODO: 				if code := p.Lexer.Next(); code.Type == lexer.SEPARATOR && (code.Value == "\n" || code.Value == "\r") {
// TODO: 					return
// TODO: 				} else if code.Type == lexer.SEPARATOR && code.Value == "=" {
// TODO: 					oldCursor := p.Lexer.Cursor
// TODO: 					end := 0
// TODO: 					for {
// TODO: 						code = p.Lexer.Next()
// TODO: 						if code.Type == lexer.RAW {
// TODO: 							tag = code.Value
// TODO: 							end = p.Lexer.Cursor - 1
// TODO: 							break
// TODO: 						} else if code.Type == lexer.SEPARATOR && (code.Value == "\n" || code.Value == "\r") {
// TODO: 							end = p.Lexer.Cursor - 1
// TODO: 							break
// TODO: 						}
// TODO: 					}
// TODO: 					p.Lexer.SetCursor(oldCursor)
// TODO: 					Default = p.ParseExp(end)
// TODO: 				} else if code.Type == lexer.RAW {
// TODO: 					tag = code.Value
// TODO: 				}
// TODO: 			} else {
// TODO: 				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
// TODO: 			}
// TODO: 		} else {
// TODO: 			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need :")
// TODO: 		}
// TODO: 	} else {
// TODO: 		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
// TODO: 	}
// TODO: 	return
// TODO: }
