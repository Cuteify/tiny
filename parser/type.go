package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"cuteify/utils"
)

type TypeBlock struct {
	Type typeSys.Type
	Name string
}

func (t *TypeBlock) Parse(p *Parser) {
	tmp := &typeSys.RType{}
	code := p.Lexer.Next()
	if code.Type == lexer.NAME {
		t.Name = code.Value
		if !utils.CheckName(t.Name) {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
		}
		tmp.TypeName = code.Value
		code2 := p.Lexer.Next()
		if code2.Type == lexer.NAME {
			tmp.RFather = t.FindDefine(p, code2.Value)
		} else if code2.Type == lexer.TYPE && code2.Value == "STRUCT" {
			tmp.TypeName = "STRUCT"
		}
	} else {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
	}
	t.Type = tmp
}

func (t *TypeBlock) FindDefine(p *Parser, name string) typeSys.Type {
	// 寻找定义位置，如果找不到，则报错，int, float, uint, i64, u64, f64, bool, byte
	// 从当前作用域开始向上寻找
	switch name {
	case "int", "float", "uint", "i64", "u64", "f64", "bool", "byte", "i32", "u32", "f32", "i16", "u16", "i8", "u8":
		return typeSys.GetSystemType(name)
	}
	if !utils.CheckName(name) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
	for {
		if p.ThisBlock.Father == nil && p.ThisBlock.Value == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need define "+name)
		}
		for i := 0; i < len(p.ThisBlock.Children); i++ {
			switch p.ThisBlock.Children[i].Value.(type) {
			case *TypeBlock:
				tmp := p.ThisBlock.Children[i].Value.(*TypeBlock)
				if tmp.Name == name {
					return p.ThisBlock.Children[i].Value.(*TypeBlock).Type
				}
			}
		}
	}
}

func (t *TypeBlock) ParseStruct(p *Parser) (name string, Type typeSys.Type, tag string, Default *Expression) {
	// 解析结构体
	code := p.Lexer.Next()
	if code.Type == lexer.NAME {
		name = code.Value
		if code := p.Lexer.Next(); code.Type == lexer.SEPARATOR && code.Value == ":" {
			code = p.Lexer.Next()
			if code.Type == lexer.NAME {
				Type = t.FindDefine(p, code.Value)
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
