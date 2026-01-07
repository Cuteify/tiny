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
	if code.Type == lexer.NAME {
		v.StartCursor = p.Lexer.Cursor
		v.Name = code.Value
		if !utils.CheckName(v.Name) {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
		}
		code := p.Lexer.Next()
		if code.Type == lexer.SEPARATOR && code.Value == ":=" {
			v.IsDefine = true
			// 找到行尾，解析表达式
			v.Value = p.ParseExpression(p.FindEndCursor())
		} else if code.Type == lexer.SEPARATOR && code.Value == "=" {
			tmp := v.FindStaticVal(p)
			if tmp != nil && !tmp.Used {
				tmp.Value = p.ParseExpression(p.FindEndCursor())
				return
			} else {
				// 找到行尾，解析表达式
				v.Value = p.ParseExpression(p.FindEndCursor())
			}
		}
	} else if code.Type == lexer.VAR {
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
		if code.Type != lexer.NAME {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
		}
		v.StartCursor = p.Lexer.Cursor
		v.Name = code.Value
		if !utils.CheckName(v.Name) {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
		}
		code = p.Lexer.Next()
		if code.Type == lexer.SEPARATOR && code.Value == ":" {
			code = p.Lexer.Next()
			if code.Type == lexer.NAME {
				tb := &TypeBlock{}
				tmp := tb.FindDefine(p, code.Value)
				rTmp := typeSys.ToRType(tmp)
				v.Type = rTmp
			} else if code.Type == lexer.SEPARATOR && code.Value == "*" {
				// 指针
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
	v.Used = true
	if p.Block == p.ThisBlock || p.ThisBlock == nil {
		// 全局变量查找
		varDef := p.Find(v.Name, v).Value.(*VarBlock)
		varDef.Check(p)
		return varDef
	}
	for {
		if p.ThisBlock == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name "+v.Name)
		}
		for i := 0; i < len(p.ThisBlock.Children); i++ {
			switch p.ThisBlock.Children[i].Value.(type) {
			case *VarBlock:
				tmp := p.ThisBlock.Children[i].Value.(*VarBlock)
				if tmp.Name == v.Name && tmp.IsDefine {
					v.Define = p.ThisBlock.Children[i]
					v.Type = tmp.Type
					p.ThisBlock = oldThisBlock
					tmp.Check(p)
					return tmp
				}
			}
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

		// 如果父节点是 Block 的根节点，说明查找到了全局作用域
		if p.ThisBlock.Father == nil {
			// 在全局作用域查找变量
			for i := 0; i < len(p.Block.Children); i++ {
				switch p.Block.Children[i].Value.(type) {
				case *VarBlock:
					tmp := p.Block.Children[i].Value.(*VarBlock)
					if tmp.Name == v.Name && tmp.IsDefine {
						v.Define = p.Block.Children[i]
						v.Type = tmp.Type
						p.ThisBlock = oldThisBlock
						tmp.Check(p)
						return tmp
					}
				}
			}
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name "+v.Name)
		}

		p.ThisBlock = p.ThisBlock.Father
	}
}

func (v *VarBlock) FindStaticVal(p *Parser) *VarBlock {
	if v.Define == nil {
		v.ParseDefine(p)
	}
	if v.Define == nil {
		return nil
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
				if tmp.Name == v.Name && tmp.Value.IsConst() {
					v.Value = new(Expression)
					*v.Value = *tmp.Value
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
