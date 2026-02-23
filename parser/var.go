package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"cuteify/utils"
)

type VarBlock struct {
	Name          Name
	IsConst       bool
	Value         *Expression
	IsDefine      bool
	IsInitialized bool
	Define        *Node
	Used          bool
	StartCursor   int
	Offset        int
	Type          typeSys.Type
}

func (v *VarBlock) Parse(p *Parser) {
	v.ParseVar(p)
	p.AddChild(&Node{Value: v})
}

func (v *VarBlock) ParseVar(p *Parser) {
	code := p.Lexer.Next()

	switch code.Type {
	case lexer.NAME:
		v.ParseNameVar(p, code, p.FindEndCursor())
	case lexer.VAR:
		v.ParseKeywordVar(p, code, p.FindEndCursor())
	default:
		if p.Lexer.Cursor == 0 {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
		}
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
	}
}

func (v *VarBlock) ParseNameVar(p *Parser, code lexer.Token, stopCursor int) {
	v.StartCursor = p.Lexer.Cursor

	p.Lexer.SetCursor(code.Cursor)
	name, _ := p.Name(false)
	v.Name = name

	if !utils.CheckName(v.Name.First()) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}

	v.ParseDefine(p)

	code = p.Lexer.Next()

	if code.Type != lexer.SEPARATOR {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need '=', ':=' or other")
	}

	if code.Value == "++" || code.Value == "--" {
		valPart := &Expression{
			Var: &VarBlock{Name: Name([]string{v.Name.First()})},
		}

		v.Value = &Expression{
			Separator: code.Value[0 : len(code.Value)-1],
			Left:      &Expression{Num: 1, Type: typeSys.GetSystemType("int")},
			Right:     valPart,
		}

		v.Value.Left.Father = v.Value
		v.Value.Right.Father = v.Value

		valPart.Var.ParseDefine(p)
		return
	}

	v.Value = p.ParseExpression(stopCursor)

	switch code.Value {
	case ":=":
		v.IsDefine = true
		return
	case "=":
		v.removeOldStaticVal(p)
	case "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>=":
		valPart := &Expression{
			Var: &VarBlock{Name: Name([]string{v.Name.First()})},
		}

		v.Value = &Expression{
			Separator: code.Value[0 : len(code.Value)-1],
			Left:      v.Value,
			Right:     valPart,
		}

		v.Value.Left.Father = v.Value
		v.Value.Right.Father = v.Value

		valPart.Var.ParseDefine(p)
	}
	v.ParseDefine(p)
}

func (v *VarBlock) ParseKeywordVar(p *Parser, code lexer.Token, stopCursor int) {
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
			tmp := tb.FindDefine(p, Name([]string{code.Value}))
			v.Type = typeSys.ToRType(tmp)
		} else if code.Type == lexer.SEPARATOR && code.Value == "*" {
			code = p.Lexer.Next()
			if code.Type == lexer.NAME {
				tb := &TypeBlock{}
				tmp := tb.FindDefine(p, Name([]string{code.Value}))
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
		v.IsInitialized = true
		v.Value = p.ParseExpression(stopCursor)
	} else {
		v.IsInitialized = false
		p.Lexer.SetCursor(code.Cursor)
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
	// 先退格到名称开始位置
	p.Lexer.SetCursor(code.Cursor)
	v.StartCursor = code.Cursor
	name, _ := p.Name(false)

	// 如果是定义，那就不能是path
	if v.IsDefine && name.IsPath() {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}

	// 赋值给VarBlock的Name
	v.Name = name
}

func (v *VarBlock) ParseDefine(p *Parser) bool {
	oldThisBlock := p.ThisBlock

	if len(v.Name) > 1 && v.Name.First() == "this" {
		return v.handleThisFieldAccess(p)
	}

	if v.Name.First() == "this" {
		return v.handleThisKeyword(p)
	}

	if !utils.CheckName(v.Name.First()) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}

	v.Used = true

	if !v.IsDefine && v.Define == nil && (p.Block == p.ThisBlock || p.ThisBlock == nil) {
		return v.findGlobalVar(p)
	}

	return v.findLocalVar(p, oldThisBlock)
}

func (v *VarBlock) handleThisFieldAccess(p *Parser) bool {
	for current := p.ThisBlock; current != nil; current = current.Father {
		if funcBlock, ok := current.Value.(*FuncBlock); ok {
			if funcBlock.Class != nil {
				structName := funcBlock.Class.Type()
				structBlock := p.FindStruct(structName)
				if structBlock == nil {
					p.Error.MissError("Field access error", p.Lexer.Cursor, "type '"+structName+"' is not a struct")
					return false
				}

				currentType := funcBlock.Class
				for i := 1; i < len(v.Name); i++ {
					fieldName := v.Name[i]
					field := structBlock.GetFieldByName(fieldName)
					if field == nil {
						p.Error.MissError("Field access error", p.Lexer.Cursor, "struct '"+structName+"' has no field '"+fieldName+"'")
						return false
					}
					currentType = field.Type
				}

				v.Type = currentType
				v.Offset = 8
				v.Define = &Node{Value: &VarBlock{
					Name:     Name([]string{"this"}),
					Type:     funcBlock.Class,
					IsDefine: true,
					Offset:   8,
				}}
				return true
			}
		}
	}
	p.Error.MissError("Syntax Error", p.Lexer.Cursor, "'this' can only be used in member function")
	return false
}

func (v *VarBlock) handleThisKeyword(p *Parser) bool {
	for current := p.ThisBlock; current != nil; current = current.Father {
		if funcBlock, ok := current.Value.(*FuncBlock); ok {
			if funcBlock.Class != nil {
				v.Type = funcBlock.Class
				v.IsDefine = true
				v.Offset = 8
				v.Define = &Node{Value: &VarBlock{
					Name:     Name([]string{"this"}),
					Type:     funcBlock.Class,
					IsDefine: true,
					Offset:   8,
				}}
				return true
			}
		}
	}
	p.Error.MissError("Syntax Error", p.Lexer.Cursor, "'this' can only be used in member function")
	return false
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
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name "+v.Name.String())
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
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name "+v.Name.String())
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

	return false
}

func (v *VarBlock) searchInChildren(p *Parser) bool {
	searchName := v.Name.First()
	for i := 0; i < len(p.ThisBlock.Children); i++ {
		if tmp, ok := p.ThisBlock.Children[i].Value.(*VarBlock); ok {
			if tmp.Name.String() == searchName && tmp.IsDefine {
				v.Define = p.ThisBlock.Children[i]
				v.Type = tmp.Type
				tmp.Check(p)
				if len(v.Name) > 1 {
					v.resolveFieldAccess(p)
				}
				return true
			}
		}
	}
	return false
}

func (v *VarBlock) resolveFieldAccess(p *Parser) {
	currentType := v.Type
	for i := 1; i < len(v.Name); i++ {
		fieldName := v.Name[i]
		structName := currentType.Type()
		structBlock := p.FindStruct(structName)
		if structBlock == nil {
			p.Error.MissError("Field access error", p.Lexer.Cursor, "type '"+structName+"' is not a struct")
			return
		}
		structBlock.Check(p)
		field := structBlock.GetFieldByName(fieldName)
		if field == nil {
			p.Error.MissError("Field access error", p.Lexer.Cursor, "struct '"+structName+"' has no field '"+fieldName+"'")
			return
		}
		currentType = field.Type
	}
	v.Type = currentType
}

func (v *VarBlock) searchInFuncArgs(p *Parser) bool {
	searchName := v.Name.First()
	if funcBlock, ok := p.ThisBlock.Value.(*FuncBlock); ok {
		for j := 0; j < len(funcBlock.Args); j++ {
			if funcBlock.Args[j].Name.String() == searchName {
				arg := funcBlock.Args[j]
				v.Define = &Node{Value: arg}
				v.Type = arg.Type
				if len(v.Name) > 1 {
					v.resolveFieldAccess(p)
				}
				return true
			}
		}
	}
	return false
}

func (v *VarBlock) searchInGlobal(p *Parser) bool {
	searchName := v.Name.First()
	for i := 0; i < len(p.Block.Children); i++ {
		if tmp, ok := p.Block.Children[i].Value.(*VarBlock); ok {
			if tmp.Name.String() == searchName && tmp.IsDefine {
				v.Define = p.Block.Children[i]
				v.Type = tmp.Type
				tmp.Check(p)
				if len(v.Name) > 1 {
					v.resolveFieldAccess(p)
				}
				return true
			}
		}
	}
	return false
}

func (v *VarBlock) removeOldStaticVal(p *Parser) {
	if v.Define == nil {
		v.ParseDefine(p)
	}
	if v.Define == nil {
		return
	}
	oldThisBlock := p.ThisBlock

	if !utils.CheckName(v.Name.First()) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
	searchName := v.Name.First()
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
				if tmp.Name.String() == searchName && tmp.Value != nil && tmp.Value.IsConst() {
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
		if v.Value != nil {
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
		}
	} else {
		if v.Define == nil {
			v.ParseDefine(p)
		}
		if v.Define == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name "+v.Name.String())
		}
		if v.Value == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need value for "+v.Name.String())
		}
		if ok := v.Value.Check(p); !ok {
			return false
		}
		if v.Type == nil && len(v.Name) > 1 {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "field type not resolved for "+v.Name.String())
		}
		if v.Type != nil && v.Value.Type != nil {
			if !typeSys.AutoType(v.Value.Type, v.Type, v.Value.IsConst()) {
				p.Error.MissError("Type Error", p.Lexer.Cursor, "need type "+v.Type.Type()+", not "+v.Value.Type.Type())
			}
		}
	}
	return true
}
