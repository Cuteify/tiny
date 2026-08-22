package parser

import (
	packageFmt "cuteify/package/fmt"
	typeSys "cuteify/type"
)

type TypeKind int

const (
	TypeAlias TypeKind = iota
	TypeStruct
	TypeInterface
)

type TypeBlock struct {
	Name        Name
	Kind        TypeKind
	Struct      *StructBlock
	Interface   *InterfaceDef
	Alias       typeSys.Type
	StartCursor int
	EndCursor   int
}

func (t *TypeBlock) Parse(p *Parser) {
	t.StartCursor = p.Lexer.Cursor

	name, nameCursor := p.ParseName(false)
	t.Name = name
	if !name.Check() {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "invalid type name: '"+name.String()+"'")
	}

	token := p.Lexer.Next()

	isTrueAlias := false
	if token.Value == "=" {
		isTrueAlias = true
		token = p.Lexer.Next()
	}

	switch token.Value {
	case "struct":
		t.Kind = TypeStruct
		t.Struct = &StructBlock{}
		// StructBlock.Parse 会自行读取结构体名称，回退到名称位置
		p.Lexer.SetCursor(nameCursor)
		savedName := p.CurStructName
		savedType := p.CurStructType
		p.CurStructName = name.String()
		p.CurStructType = &t.Struct.Type
		t.Struct.Parse(p)
		p.CurStructName = savedName
		p.CurStructType = savedType
		t.EndCursor = t.Struct.EndCursor
	case "interface":
		t.Kind = TypeInterface
		t.Interface = &InterfaceDef{}
		t.Interface.Parse(p)
		t.EndCursor = t.Interface.EndCursor
	default:
		t.Kind = TypeAlias
		p.Lexer.SetCursor(token.Cursor)

		// 解析类型引用（支持 []Type 语法）
		t.Alias = p.parseTypeRef()
		if t.Alias == nil {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "type expected")
		}
		if isTrueAlias {
			t.Alias = typeSys.NewAlias(name.String(), t.Alias, true)
		} else {
			t.Alias = typeSys.NewAlias(name.String(), t.Alias, false)
		}
	}
	// 注册到全局类型表，供同包其它文件（及跨包）解析期引用
	if p.Package != nil && p.Package.Path != "" {
		packageFmt.RegisterType(p.Package.Path, name.String(), t.Type())
	}
}

func (t *TypeBlock) Check(p *Parser) bool {
	if t.Kind == TypeStruct {
		t.Struct.Type.Inherit(func(name string) *typeSys.StructType {
			n := NewName(name)
			results := p.Find(n, FindTypeType)
			if len(results) > 0 {
				if tb, ok := results[0].Value.(*TypeBlock); ok {
					if st, ok := tb.Type().(*typeSys.StructType); ok {
						return st
					}
				}
			}
			return nil
		})
		t.Struct.Type.Layout()
	}
	return true
}

func (t *TypeBlock) Type() typeSys.Type {
	switch t.Kind {
	case TypeStruct:
		return &t.Struct.Type
	case TypeAlias:
		return t.Alias
	default:
		return &typeSys.RType{TypeName: t.Name.String()}
	}
}
