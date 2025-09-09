package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"errors"
	//"strings"
)

type CallBlock struct {
	Name string
	Args []*ArgBlock
	Func *FuncBlock
	Node *Node
}

func (c *CallBlock) Check(parser *Parser) bool {
	// 检查函数名
	if c.Name == "" {
		parser.Error.MissError("Call Error", parser.Lexer.Cursor, "function name is empty")
		return false
	}

	// 查找函数定义
	if c.Func == nil {
		c.Func = parser.FindFunc(c.Name).Value.(*FuncBlock)
	}

	// 检查参数个数是否匹配（考虑默认参数）
	if len(c.Args) > len(c.Func.Args) {
		parser.Error.MissError("Call Error", parser.Lexer.Cursor, "too many arguments in call to "+c.Name)
		return false
	}

	// 处理默认参数
	if len(c.Args) < len(c.Func.Args) {
		for i := len(c.Args); i < len(c.Func.Args); i++ {
			if c.Func.Args[i].Default == nil {
				parser.Error.MissError("Call Error", parser.Lexer.Cursor, "not enough arguments in call to "+c.Name)
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
		/*if !arg.Value.Check(parser) {
			return false
		}*/

		// 获取对应的函数定义参数
		defArg := c.Func.Args[i]

		// 类型检查
		if !typeSys.AutoType(arg.Value.Type, defArg.Type, arg.Value.IsConst()) {
			parser.Error.MissError("Type Error", parser.Lexer.Cursor,
				"cannot use "+arg.Value.Type.Type()+" as type "+defArg.Type.Type()+" in argument to "+c.Name)
			return false
		}

		arg.Defind = defArg
	}

	if err := c.ParseArgsDefault(parser); err != nil {
		parser.Error.MissError("Call Error", 0, err.Error())
	}

	// 所有检查通过
	return true
}

func (c *CallBlock) Parse(p *Parser) {
	// 找到定义位置
	//oldThisBlock := p.ThisBlock
	/*for {
			if p.ThisBlock.Father == nil && p.ThisBlock.Value == nil {
				// 查找根级内容
				for i := 0; i < len(p.ThisBlock.Children); i++ {
					switch p.ThisBlock.Children[i].Value.(type) {
					case *FuncBlock:
						tmp := p.ThisBlock.Children[i].Value.(*FuncBlock)
						if tmp.Name == c.Name {
							c.Func = tmp
							goto end
						}
					}
				}
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need define "+c.Name)
			}
			for i := 0; i < len(p.ThisBlock.Children); i++ {
				switch p.ThisBlock.Children[i].Value.(type) {
				case *FuncBlock:
					tmp := p.ThisBlock.Children[i].Value.(*FuncBlock)
					if tmp.Name == c.Name {
						c.Func = tmp
						goto end
					}
				}
			}
			p.ThisBlock = p.ThisBlock.Father
		}
	end:
		p.ThisBlock = oldThisBlock*/
	// 解析括号
	rightBra := p.FindRightBracket(false)
	for p.Lexer.Cursor < rightBra {
		//oldCursor := p.Lexer.Cursor
		sepCursor := p.Has(lexer.Token{Type: lexer.SEPARATOR, Value: ","}, rightBra)
		if sepCursor == -1 {
			arg := &ArgBlock{Value: p.ParseExpression(rightBra - 1)}
			if arg.Value == nil {
				break
			}
			arg.Type = arg.Value.Type
			c.Args = append(c.Args, arg)
			/*if len(c.Func.Args) < 1 {
				p.Error.MissErrors("Call Error", oldCursor, rightBra+1, "Args length error")
			}
			arg.Defind = c.Func.Args[len(c.Args)-1]
			if typeSys.AutoType(arg.Type, arg.Defind.Type, arg.Value.IsConst()) {
				arg.Type = arg.Defind.Type
			} else {
				p.Error.MissErrors("Type Error", oldCursor, rightBra+1, "need type "+arg.Defind.Type.Type()+", not "+arg.Value.Type.Type())
			}*/
			break
		}
		arg := &ArgBlock{Value: p.ParseExpression(sepCursor - 1)}
		arg.Type = arg.Value.Type
		p.Lexer.Cursor++
		c.Args = append(c.Args, arg)
		/*if len(c.Func.Args) <= len(c.Args) {
			p.Error.MissErrors("Call Error", oldCursor, rightBra+1, "Args length error")
		}
		arg.Defind = c.Func.Args[len(c.Args)-1]
		arg.Name = arg.Defind.Name

		if typeSys.AutoType(arg.Type, arg.Defind.Type, arg.Value.IsConst()) {
			arg.Type = arg.Defind.Type
		} else {
			p.Error.MissErrors("Type Error", oldCursor, sepCursor+1, "need type "+arg.Defind.Type.Type()+", not "+arg.Value.Type.Type())
		}*/
	}
	/*if err := c.ParseArgsDefault(p); err != nil {
		p.Error.MissError("Call Error", rightBra-1, err.Error())
	}*/
	// 查找父级内容，找到定义位置
	node := &Node{Value: c}
	c.Node = node
	p.ThisBlock.AddChild(node)
	p.Lexer.Cursor++

}

func (c *CallBlock) ParseArgsDefault(p *Parser) error {
	if len(c.Args) == len(c.Func.Args) {
		return nil
	}
	for i := len(c.Args); i < len(c.Func.Args); i++ {
		if len(c.Args) <= i && c.Func.Args[i].Default == nil {
			return errors.New("Args length error")
		} else {
			c.Args = append(c.Args, &ArgBlock{Value: c.Func.Args[i].Default, Defind: c.Func.Args[i]})
		}
	}
	return nil
}
