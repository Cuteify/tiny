package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"strings"
)

type CallBlock struct {
	Name    Name
	Args    []*ArgBlock
	Func    *FuncBlock
	Node    *Node
	ThisVar *VarBlock
}

func (c *CallBlock) Check(parser *Parser) bool {
	if c.Name.IsEmpty() {
		parser.Error.MissError("Call Error", parser.Lexer.Cursor, "function name is empty")
		return false
	}

	if c.Func == nil {
		funcNode := parser.Find(c.Name, c.Func)
		if funcNode != nil {
			c.Func = funcNode.Value.(*FuncBlock)
		}
	}

	if c.Func == nil {
		parser.Error.MissError("Call Error", parser.Lexer.Cursor, "not found function '"+c.Name.String()+"'")
		return false
	}

	// 检查参数个数是否匹配（考虑默认参数）
	if len(c.Args) > len(c.Func.Args) {
		parser.Error.MissError("Call Error", parser.Lexer.Cursor, "too many arguments in call to "+c.Name.String())
		return false
	}

	// 处理默认参数
	if len(c.Args) < len(c.Func.Args) {
		for i := len(c.Args); i < len(c.Func.Args); i++ {
			if c.Func.Args[i].Default == nil {
				parser.Error.MissError("Call Error", parser.Lexer.Cursor, "not enough arguments in call to "+c.Name.String())
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

		arg.Value.Check(parser)

		// 类型检查
		if !typeSys.AutoType(arg.Value.Type, defArg.Type, true) {
			nameStr := strings.Join(c.Name, ".") // 将Name转换为点分隔的字符串
			parser.Error.MissError("Type Error", parser.Lexer.Cursor-1,
				"cannot use "+arg.Value.Type.Type()+" as type "+
					defArg.Type.Type()+" in argument to "+nameStr)
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

				argExp := p.ParseExpression(stopCursor)
				if argExp != nil {
					c.Args = append(c.Args, &ArgBlock{Value: argExp})
				}
				p.Lexer.Skip(')')
				return
			}

			if token.Value == "," {
				stopCursor := token.Cursor
				p.Lexer.SetCursor(oldCursor)

				argExp := p.ParseExpression(stopCursor)
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
