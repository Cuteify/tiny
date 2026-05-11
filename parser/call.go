package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
)

// CallBlock 函数调用结构体
type CallBlock struct {
	Name    Name
	Args    []*ArgBlock
	Func    *FuncBlock
	Node    *Node
	ThisVar *VarBlock
}

// Check 检查函数调用的参数数量和类型是否匹配
func (c *CallBlock) Check(p *Parser) bool {
	if c.Name.IsEmpty() {
		p.Error.MissError("Call Error", p.Lexer.Cursor, "function name is empty")
		return false
	}

	if c.Func == nil {
		_, funcBlock := p.FindFunc(c.Name)
		c.Func = funcBlock
	}

	if c.Func == nil && len(c.Name) == 2 {
		_, rawVar := p.FindVar(NewName(c.Name[0]))
		if rawVar != nil {
			var thisVar *VarBlock
			switch v := rawVar.(type) {
			case *VarBlock:
				thisVar = v
			case *ArgBlock:
				if v.Type != nil {
					thisVar = &VarBlock{
						Name:   v.Name,
						Type:   v.Type,
						Offset: v.Offset,
					}
				}
			}
			if thisVar != nil && thisVar.Type != nil {
				methodName := Name{thisVar.Type.Type(), c.Name[1]}
				_, funcBlock := p.FindFunc(methodName)
				if funcBlock != nil {
					c.Func = funcBlock
					c.ThisVar = thisVar
				}
			}
		}
	}

	if c.Func == nil {
		if p.Block == p.ThisBlock {
			p.Error.MissError("Call Error", p.Lexer.Cursor, "not found function '"+c.Name.String()+"'")
		}
		return false
	}

	c.Func.Useful = true

	selfOffset := 0
	if c.ThisVar != nil {
		selfOffset = 1
	}

	if len(c.Args) > len(c.Func.Args)-selfOffset {
		p.Error.MissError("Call Error", p.Lexer.Cursor, "too many arguments in call to "+c.Name.String())
		return false
	}

	if len(c.Args) < len(c.Func.Args)-selfOffset {
		for i := len(c.Args); i < len(c.Func.Args)-selfOffset; i++ {
			if c.Func.Args[i+selfOffset].Default == nil {
				p.Error.MissError("Call Error", p.Lexer.Cursor, "not enough arguments in call to "+c.Name.String())
				return false
			}
			c.Args = append(c.Args, &ArgBlock{
				Value:  c.Func.Args[i+selfOffset].Default,
				Defind: c.Func.Args[i+selfOffset],
				Name:   c.Func.Args[i+selfOffset].Name,
				Type:   c.Func.Args[i+selfOffset].Type,
			})
		}
	}

	for i, arg := range c.Args {
		defArg := c.Func.Args[i+selfOffset]

		arg.Value.Check(p)

		if !typeSys.AutoType(arg.Value.Type, defArg.Type, true) {
			p.Error.MissError("Type Error", p.Lexer.Cursor-1,
				"cannot use "+arg.Value.Type.Type()+" as type "+
					defArg.Type.Type()+" in argument to "+c.Name.String())
			return false
		}

		arg.Type = defArg.Type
		arg.Name = defArg.Name
		arg.Offset = defArg.Offset
	}

	return true
}

// ParseCall 解析函数调用
func (c *CallBlock) ParseCall(p *Parser) {
	p.Lexer.Skip('(')
	var token lexer.Token

	for {
		oldCursor := p.Lexer.Cursor
		for {
			token = p.Lexer.Next()

			if token.Value == ")" {
				stopCursor := token.Cursor
				p.Lexer.SetCursor(oldCursor)

				argExp := p.ParseExp(stopCursor)
				if argExp != nil {
					c.Args = append(c.Args, &ArgBlock{Value: argExp})
				}
				p.Lexer.Skip(')')
				return
			}

			if token.Value == "," {
				stopCursor := token.Cursor
				p.Lexer.SetCursor(oldCursor)

				argExp := p.ParseExp(stopCursor)
				if argExp != nil {
					c.Args = append(c.Args, &ArgBlock{Value: argExp})
				}
				p.Lexer.SetCursor(token.Cursor + 1)
				break
			}
		}
	}
}

func (c *CallBlock) Parse(p *Parser) {
	c.ParseCall(p)
	p.ThisBlock.AddChild(&Node{Value: c})
}
