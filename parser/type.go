package parser

import (
	"cuteify/lexer"
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

	// 泛型声明：type Box[T, U] struct / interface。结构体/接口的 Parse 自行消费
	// “[T, U]”并建占位表；这里只按“名称后的 [...] 前瞻”决定走 struct/interface 分支。
	if token.Type == lexer.SEPARATOR && token.Value == "[" {
		// 前瞻（不消费）：token 自己就是那个“[”，从它之后扫到匹配的 ]
		save := p.Lexer.Cursor
		depth := 1
		for {
			t2 := p.Lexer.Next()
			if t2.IsEmpty() {
				p.Lexer.SetCursor(save)
				p.Error.MissError("Syntax Error", save, "unbalanced '[' in type declaration")
				return
			}
			if t2.Type == lexer.SEPARATOR && t2.Value == "[" {
				depth++
			}
			if t2.Type == lexer.SEPARATOR && t2.Value == "]" {
				depth--
				if depth == 0 {
					break
				}
			}
		}
		kw := p.Lexer.Next()
		p.Lexer.SetCursor(save)
		switch kw.Value {
		case "struct", "interface":
			token = kw
		default:
			p.Lexer.SetCursor(save)
			// 不是 struct/interface，按原逻辑走（会在 typeRef 处报“need type”）
			token = p.Lexer.Next()
		}
	}

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
		// build align(N)/noalign 紧随其后才生效（严格紧随：隔了其他声明即孤儿）
		p.attachPendingAlign(&t.Struct.Type)
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
	// 注册到全局类型表，供同包其它文件（及跨包）解析期引用。
	// 被顶层 build 过滤的声明不注册，避免其它文件解析到本平台不存在的类型。
	if p.Package != nil && p.Package.Path != "" && !p.pendingDeclIgnored() {
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
	case TypeInterface:
		// 用户接口：构造带方法签名的 InterfaceType（boxed value：{vtable_ptr, data_ptr}）。
		// 构造结果注册进全局类型表（packages RegisterType），被赋值/方法调用路径消费。
		it := &typeSys.InterfaceType{
			RType: typeSys.RType{TypeName: t.Name.String()},
		}
		if t.Interface != nil {
			for _, m := range t.Interface.Methods {
				def := typeSys.InterfaceMethodDef{Name: m.Name.Last()}
				for _, a := range m.Args {
					if a != nil && a.Type != nil {
						def.Args = append(def.Args, a.Type)
					}
				}
				def.Returns = m.Returns
				it.InterfaceMethods = append(it.InterfaceMethods, def)
			}
		}
		return it
	default:
		return &typeSys.RType{TypeName: t.Name.String()}
	}
}
