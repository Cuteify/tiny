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
	// 解析变量名
	code := p.Lexer.Next()
	if code.Type == lexer.LexTokenType["NAME"] {
		v.StartCursor = p.Lexer.Cursor
		v.Name = code.Value
		if !utils.CheckName(v.Name) {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
		}
		code := p.Lexer.Next()
		if code.Type == lexer.LexTokenType["SEPARATOR"] && code.Value == ":=" {
			v.IsDefine = true
			// 找到行尾，解析表达式
			v.Value = p.ParseExpression(p.FindEndCursor())
			if v.Value.Type != nil {
				v.Type = v.Value.Type
			} else {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need type")
			}
		} else if code.Type == lexer.LexTokenType["SEPARATOR"] && code.Value == "=" {
			tmp := v.FindStaticVal(p)
			if tmp != nil && !tmp.Used {
				tmp.Value = p.ParseExpression(p.FindEndCursor())
				return
			} else {
				// 找到行尾，解析表达式
				v.Value = p.ParseExpression(p.FindEndCursor())
				v.ParseDefine(p)
				v.Type = v.Value.Type
				if typeSys.AutoType(v.Type, v.Define.Value.(*VarBlock).Type, v.Value.IsConst()) {
					v.Type = v.Define.Value.(*VarBlock).Type
				} else {
					p.Error.MissError("Type Error", p.Lexer.Cursor, "need type "+v.Type.Type()+", not "+v.Define.Value.(*VarBlock).Type.Type())
				}
				if v.Define.Value.(*VarBlock).IsConst {
					p.Error.MissError("Syntax Error", p.Lexer.Cursor, v.Name+":const can not be redefined")
				}
			}
		}
	} else if code.Type == lexer.LexTokenType["VAR"] {
		v.IsDefine = true
		switch code.Value {
		case "CONST":
			v.IsConst = true
		case "VAR":
			v.IsConst = false
		case "LET":
			v.IsConst = false
			p.Error.Warning("let is not support, use var instead")
		}
		code = p.Lexer.Next()
		if code.Type != lexer.LexTokenType["NAME"] {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
		}
		v.StartCursor = p.Lexer.Cursor
		v.Name = code.Value
		if !utils.CheckName(v.Name) {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
		}
		code = p.Lexer.Next()
		if code.Type == lexer.LexTokenType["SEPARATOR"] && code.Value == ":" {
			code = p.Lexer.Next()
			if code.Type == lexer.LexTokenType["NAME"] {
				tb := &TypeBlock{}
				tmp := tb.FindDefine(p, code.Value)
				rTmp := typeSys.ToRType(tmp)
				v.Type = rTmp
			} else if code.Type == lexer.LexTokenType["SEPARATOR"] && code.Value == "*" {
				// 指针
				code = p.Lexer.Next()
				if code.Type == lexer.LexTokenType["NAME"] {
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
		if code.Type == lexer.LexTokenType["SEPARATOR"] && code.Value == "=" {
			v.Value = p.ParseExpression(p.FindEndCursor())
			if typeSys.AutoType(v.Value.Type, v.Type, true) {
				v.Value.Type = v.Type
			} else {
				p.Error.MissError("Type Error", p.Lexer.Cursor, "need type "+v.Type.Type()+", not "+v.Value.Type.Type())
			}
		} else {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need value")
		}
	} else {
		if p.Lexer.Cursor == 0 {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
		}
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
	}
	p.AddChild(&Node{Value: v})

}

func (v *VarBlock) ParseDefine(p *Parser) *VarBlock {
	// 找到定义位置
	oldThisBlock := p.ThisBlock
	if !utils.CheckName(v.Name) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
	for {
		for i := 0; i < len(p.ThisBlock.Children); i++ {
			switch p.ThisBlock.Children[i].Value.(type) {
			case *VarBlock:
				tmp := p.ThisBlock.Children[i].Value.(*VarBlock)
				if tmp.Name == v.Name && tmp.IsDefine {
					v.Define = p.ThisBlock.Children[i]
					v.Type = tmp.Type
					p.ThisBlock = oldThisBlock
					return tmp
				}
			}
		}
		if p.ThisBlock.Father == nil && p.ThisBlock.Value == nil {
			p.Error.MissErrors("Syntax Error", p.Lexer.Cursor-len(v.Name), p.Lexer.Cursor, "need define "+v.Name)
		}
		switch p.ThisBlock.Value.(type) {
		case *FuncBlock:
			tmp := p.ThisBlock.Value.(*FuncBlock)
			for j := 0; j < len(tmp.Args); j++ {
				if tmp.Args[j].Name == v.Name {
					arg := tmp.Args[j]
					v.Define = &Node{Value: arg}
					v.Type = arg.Type
					p.ThisBlock = oldThisBlock
					return nil
				}
			}
		}

		p.ThisBlock = p.ThisBlock.Father
	}
}

func (v *VarBlock) FindStaticVal(p *Parser) *VarBlock {
	if v.Define == nil {
		v.ParseDefine(p)
	}
	if v.Define.Father.Father == nil {
		return nil
	}
	oldThisBlock := p.ThisBlock

	if !utils.CheckName(v.Name) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
	for {
		for i := len(p.ThisBlock.Children) - 1; i >= 0; i-- {
			switch p.ThisBlock.Children[i].Value.(type) {
			case *IfBlock:
				goto end
			case *VarBlock:
				tmp := p.ThisBlock.Children[i].Value.(*VarBlock)
				if tmp.Name == v.Name {
					if tmp.Value.IsConst() {
						v.Value = new(Expression)
						*v.Value = *tmp.Value
					}
					p.ThisBlock = oldThisBlock
					return tmp
				}
			}
		}
		switch p.ThisBlock.Value.(type) {
		case *FuncBlock:
			goto end
		}
		p.ThisBlock = p.ThisBlock.Father
	}
end:
	p.ThisBlock = oldThisBlock
	return nil
}
