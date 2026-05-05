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

	if c.Func == nil {
		if p.Block == p.ThisBlock {
			p.Error.MissError("Call Error", p.Lexer.Cursor, "not found function '"+c.Name.String()+"'")
		}
		return false
	}

	c.Func.Useful = true

	// 检查参数个数是否匹配（考虑默认参数）
	if len(c.Args) > len(c.Func.Args) {
		p.Error.MissError("Call Error", p.Lexer.Cursor, "too many arguments in call to "+c.Name.String())
		return false
	}

	// 处理默认参数
	if len(c.Args) < len(c.Func.Args) {
		for i := len(c.Args); i < len(c.Func.Args); i++ {
			if c.Func.Args[i].Default == nil {
				p.Error.MissError("Call Error", p.Lexer.Cursor, "not enough arguments in call to "+c.Name.String())
				return false
			}
			// 添加默认参数
			c.Args = append(c.Args, &ArgBlock{
				Value:  c.Func.Args[i].Default,
				Defind: c.Func.Args[i],
				Name:   c.Func.Args[i].Name,
				Type:   c.Func.Args[i].Type,
			})
		}
	}

	// 检查每个参数
	for i, arg := range c.Args {
		// 检查参数表达式
		// 获取对应的函数定义参数
		defArg := c.Func.Args[i]

		arg.Value.Check(p)

		// 类型检查
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
