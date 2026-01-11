package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"cuteify/utils"
)

type VarBlock struct {
	Name        string
	IsConst     bool
	Value       *Expression
	IsDefine    bool
	Define      *Node
	Used        bool
	StartCursor int
	Offset      int
	Type        typeSys.Type
}

func (v *VarBlock) Parse(p *Parser) {
	v.ParseVar(p)
	p.AddChild(&Node{Value: v})
}

func (v *VarBlock) ParseVar(p *Parser) {
	code := p.Lexer.Next()

	switch code.Type {
	case lexer.NAME:
		v.parseNameVar(p, code)
	case lexer.VAR:
		v.parseKeywordVar(p, code)
	default:
		if p.Lexer.Cursor == 0 {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
		}
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
	}
}

func (v *VarBlock) parseNameVar(p *Parser, code lexer.Token) {
	v.StartCursor = p.Lexer.Cursor
	v.Name = code.Value
	if !utils.CheckName(v.Name) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}

	code = p.Lexer.Next()
	if code.Type == lexer.SEPARATOR && code.Value == ":=" {
		v.IsDefine = true
		v.Value = p.ParseExpression(p.FindEndCursor())
	} else if code.Type == lexer.SEPARATOR && code.Value == "=" {
		v.Value = p.ParseExpression(p.FindEndCursor())
		v.removeOldStaticVal(p)
	}
}

func (v *VarBlock) parseKeywordVar(p *Parser, code lexer.Token) {
	v.IsDefine = true
	v.setVarConst(p, code.Value)

	code = p.Lexer.Next()
	if code.Type != lexer.NAME {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
	}
	v.parseVarName(p, code)

	code = p.Lexer.Next()
	if code.Type == lexer.SEPARATOR && code.Value == ":" {
		code = p.Lexer.Next()
		if code.Type == lexer.NAME {
			tb := &TypeBlock{}
			tmp := tb.FindDefine(p, code.Value)
			v.Type = typeSys.ToRType(tmp)
		} else if code.Type == lexer.SEPARATOR && code.Value == "*" {
			code = p.Lexer.Next()
			if code.Type == lexer.NAME {
				tb := &TypeBlock{}
				tmp := tb.FindDefine(p, code.Value)
				rTmp := typeSys.ToRType(tmp)
				rTmp.IsPtr = true
				v.Type = rTmp
			} else {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need type")
			}
		} else {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need type")
		}
	} else {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need type")
	}

	code = p.Lexer.Next()
	if code.Type == lexer.SEPARATOR && code.Value == "=" {
		v.Value = p.ParseExpression(p.FindEndCursor())
	} else {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need value")
	}
}

func (v *VarBlock) setVarConst(p *Parser, keyword string) {
	switch keyword {
	case "CONST":
		v.IsConst = true
	case "VAR":
		v.IsConst = false
	case "LET":
		v.IsConst = false
		p.Error.Warning("let is not support, use var instead")
	}
}

func (v *VarBlock) parseVarName(p *Parser, code lexer.Token) {
	v.StartCursor = p.Lexer.Cursor
	v.Name = code.Value
	if !utils.CheckName(v.Name) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
}

func (v *VarBlock) ParseDefine(p *Parser) bool {
	oldThisBlock := p.ThisBlock

	if !utils.CheckName(v.Name) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
	v.Used = true

	if p.Block == p.ThisBlock || p.ThisBlock == nil {
		return v.findGlobalVar(p)
	}

	return v.findLocalVar(p, oldThisBlock)
}

func (v *VarBlock) findGlobalVar(p *Parser) bool {
	varNode := p.Find(v.Name, v)
	varNode.Value.(*VarBlock).Check(p)
	v.Define = varNode
	return varNode != nil
}

func (v *VarBlock) findLocalVar(p *Parser, oldThisBlock *Node) bool {
	for {
		if p.ThisBlock == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name "+v.Name)
		}

		if ok := v.searchInBlock(p); ok {
			p.ThisBlock = oldThisBlock
			return ok
		}

		if p.ThisBlock.Father == nil {
			if ok := v.searchInGlobal(p); ok {
				p.ThisBlock = oldThisBlock
				return ok
			}
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name "+v.Name)
		}

		p.ThisBlock = p.ThisBlock.Father
	}
}

func (v *VarBlock) searchInBlock(p *Parser) bool {
	if ok := v.searchInChildren(p); ok {
		return ok
	}

	if ok := v.searchInFuncArgs(p); ok {
		return ok
	}

	if ok := v.searchInForVar(p); ok {
		return ok
	}

	return false
}

func (v *VarBlock) searchInChildren(p *Parser) bool {
	for i := 0; i < len(p.ThisBlock.Children); i++ {
		if tmp, ok := p.ThisBlock.Children[i].Value.(*VarBlock); ok {
			if tmp.Name == v.Name && tmp.IsDefine {
				v.Define = p.ThisBlock.Children[i]
				v.Type = tmp.Type
				tmp.Check(p)
				return true
			}
		}
	}
	return false
}

func (v *VarBlock) searchInFuncArgs(p *Parser) bool {
	if funcBlock, ok := p.ThisBlock.Value.(*FuncBlock); ok {
		for j := 0; j < len(funcBlock.Args); j++ {
			if funcBlock.Args[j].Name == v.Name {
				arg := funcBlock.Args[j]
				v.Define = &Node{Value: arg}
				v.Type = arg.Type
				return true
			}
		}
	}
	return false
}

func (v *VarBlock) searchInForVar(p *Parser) bool {
	if forBlock, ok := p.ThisBlock.Value.(*ForBlock); ok {
		if forBlock.Var != nil && forBlock.Var.Name == v.Name && forBlock.Var.IsDefine {
			v.Define = &Node{Value: forBlock.Var}
			v.Type = forBlock.Var.Type
			return true
		}
	}
	return false
}

func (v *VarBlock) searchInGlobal(p *Parser) bool {
	for i := 0; i < len(p.Block.Children); i++ {
		if tmp, ok := p.Block.Children[i].Value.(*VarBlock); ok {
			if tmp.Name == v.Name && tmp.IsDefine {
				v.Define = p.Block.Children[i]
				v.Type = tmp.Type
				tmp.Check(p)
				return true
			}
		}
	}
	return false
}

func (v *VarBlock) removeOldStaticVal(p *Parser) { // 多次赋值时，删除旧的静态值，内联优化器
	if v.Define == nil {
		v.ParseDefine(p)
	}
	if v.Define == nil {
		return
	}
	oldThisBlock := p.ThisBlock

	if !utils.CheckName(v.Name) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
	for {
		for i := len(p.ThisBlock.Children) - 1; i >= 0; i-- {
			if p.ThisBlock.Children[i].Ignore {
				continue
			}
			switch p.ThisBlock.Children[i].Value.(type) {
			case *FuncBlock, *ForBlock, *ElseBlock, *IfBlock:
				goto end
			case *VarBlock:
				tmp := p.ThisBlock.Children[i].Value.(*VarBlock)
				if tmp.Name == v.Name && tmp.Value.IsConst() {
					if i == len(p.ThisBlock.Children)-1 {
						p.ThisBlock.Children = p.ThisBlock.Children[:i]
					} else {
						p.ThisBlock.Children = append(p.ThisBlock.Children[:i], p.ThisBlock.Children[i+1:]...)
					}
				}
			}
		}
		p.ThisBlock = p.ThisBlock.Father
	}
end:
	p.ThisBlock = oldThisBlock
}

func (v *VarBlock) Check(p *Parser) bool {
	if v.IsDefine {
		if ok := v.Value.Check(p); !ok {
			return false
		}
		if v.Value.Type == nil {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "need type")
		}
		if v.Type == nil {
			v.Type = v.Value.Type
		}
		if !typeSys.AutoType(v.Value.Type, v.Type, true) {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "need type "+v.Type.Type()+", not "+v.Value.Type.Type())
		}
	} else {
		if v.Define == nil {
			v.ParseDefine(p)
		}
		if v.Define == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name "+v.Name)
		}
		// 检查是否为全局变量，如果是则进行类型检查
		if v.Define.Father != nil && v.Define.Father.Father == nil {
			// 全局变量定义
			if v.Value == nil {
				if _, ok := v.Define.Value.(*VarBlock); ok {
					v.Value = v.Define.Value.(*VarBlock).Value
				} else {
					v.Value = v.Define.Value.(*ArgBlock).Value
				}
			} else {
				// 修改全局变量，需要进行类型检查
				if ok := v.Value.Check(p); !ok {
					return false
				}
			}
		} else {
			// 局部变量
			if v.Value == nil {
				if _, ok := v.Define.Value.(*VarBlock); ok {
					v.Value = v.Define.Value.(*VarBlock).Value
				} else {
					v.Value = v.Define.Value.(*ArgBlock).Value
				}
			} else {
				if ok := v.Value.Check(p); !ok {
					return false
				}
			}
		}
		if varDef, ok := v.Define.Value.(*VarBlock); ok {
			v.Type = varDef.Type
			if varDef.IsConst {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, v.Name+":const can not be redefined")
			}
			if !typeSys.AutoType(v.Value.Type, varDef.Type, v.Value.IsConst()) {
				p.Error.MissError("Type Error", p.Lexer.Cursor, "need type "+v.Type.Type()+", not "+varDef.Type.Type())
			}
			v.Type = varDef.Type
			v.Offset = varDef.Offset
		} else {
			argDef := v.Define.Value.(*ArgBlock)
			v.Type = argDef.Type
			if !typeSys.AutoType(v.Value.Type, argDef.Type, v.Value.IsConst()) {
				p.Error.MissError("Type Error", p.Lexer.Cursor, "need type "+v.Type.Type()+", not "+argDef.Type.Type())
			}
			v.Type = argDef.Type
			v.Offset = argDef.Offset
		}
	}
	return true
}
