package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"cuteify/utils"
)

type TypeBlock struct {
	Type typeSys.Type
	Name Name
}

func (t *TypeBlock) Parse(p *Parser) {
	tmp := &typeSys.RType{}
	code := p.Lexer.Next()
	if code.Type == lexer.NAME {
		t.Name = Name([]string{code.Value})
		if !utils.CheckName(t.Name.String()) {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
		}
		tmp.TypeName = code.Value
		code2 := p.Lexer.Next()
		if code2.Type == lexer.NAME {
			tmp.RFather = t.FindDefine(p, Name([]string{code2.Value}))
		} else if code2.Type == lexer.SEPARATOR && code2.Value == "STRUCT" {
			tmp.TypeName = "STRUCT"
		}
	} else {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
	}
	t.Type = tmp
}

func (t *TypeBlock) FindDefine(p *Parser, name Name) typeSys.Type {
	// 寻找定义位置，如果找不到，则报错，int, float, uint, i64, u64, f64, bool, byte
	// 从当前作用域开始向上寻找
	nameStr := name.String()
	switch nameStr {
	case "int", "float", "uint", "i64", "u64", "f64", "bool", "byte", "i32", "u32", "f32", "i16", "u16", "i8", "u8":
		return typeSys.GetSystemType(nameStr)
	}
	if !utils.CheckName(nameStr) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
	for {
		if p.ThisBlock.Father == nil && p.ThisBlock.Value == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need define "+nameStr)
		}
		for i := 0; i < len(p.ThisBlock.Children); i++ {
			switch p.ThisBlock.Children[i].Value.(type) {
			case *TypeBlock:
				tmp := p.ThisBlock.Children[i].Value.(*TypeBlock)
				if tmp.Name.String() == name.String() {
					return p.ThisBlock.Children[i].Value.(*TypeBlock).Type
				}
			}
		}
	}
}

func (t *TypeBlock) ParseStruct(p *Parser) (name Name, Type typeSys.Type, tag string, Default *Expression) {
	// 解析结构体
	code := p.Lexer.Next()
	if code.Type == lexer.NAME {
		name = Name([]string{code.Value})
		if code := p.Lexer.Next(); code.Type == lexer.SEPARATOR && code.Value == ":" {
			code = p.Lexer.Next()
			if code.Type == lexer.NAME {
				Type = t.FindDefine(p, Name([]string{code.Value}))
				if code := p.Lexer.Next(); code.Type == lexer.SEPARATOR && (code.Value == "\n" || code.Value == "\r") {
					return
				} else if code.Type == lexer.SEPARATOR && code.Value == "=" {
					oldCursor := p.Lexer.Cursor
					end := 0
					for {
						code = p.Lexer.Next()
						if code.Type == lexer.RAW {
							tag = code.Value
							end = p.Lexer.Cursor - 1
							break
						} else if code.Type == lexer.SEPARATOR && (code.Value == "\n" || code.Value == "\r") {
							end = p.Lexer.Cursor - 1
							break
						}
					}
					p.Lexer.SetCursor(oldCursor)
					Default = p.ParseExpression(end)
				} else if code.Type == lexer.RAW {
					tag = code.Value
				}
			} else {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
			}
		} else {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need :")
		}
	} else {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
	}
	return
}
