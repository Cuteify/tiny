package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"errors"
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
		c.Func = parser.Find(c.Name, c.Func).Value.(*FuncBlock)
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
		// 获取对应的函数定义参数
		defArg := c.Func.Args[i]

		arg.Value.Check(parser)

		// 类型检查
		if !typeSys.AutoType(arg.Value.Type, defArg.Type, true) {
			parser.Error.MissError("Type Error", parser.Lexer.Cursor-1,
				"cannot use "+arg.Value.Type.Type()+" as type "+
					defArg.Type.Type()+" in argument to "+c.Name)
			return false
		}

		arg.Type = defArg.Type
		arg.Name = defArg.Name
		arg.Offset = defArg.Offset

		arg.Defind = defArg
	}

	if err := c.ParseArgsDefault(parser); err != nil {
		parser.Error.MissError("Call Error", 0, err.Error())
	}

	// 所有检查通过
	return true
}

func (c *CallBlock) Parse(p *Parser) {
	c.ParseCall(p)
	c.Node.Ignore = false
}

func (c *CallBlock) ParseCall(p *Parser) {
	// 解析括号
	rightBra := p.FindRightBracket(true)
	for p.Lexer.Cursor < rightBra {
		sepCursor := p.Has(lexer.Token{Type: lexer.SEPARATOR, Value: ","}, rightBra)
		if sepCursor == -1 {
			exp := p.ParseExpression(rightBra - 1)
			arg := &ArgBlock{Value: exp}
			if arg.Value == nil {
				break
			}
			arg.Type = arg.Value.Type
			c.Args = append(c.Args, arg)
			break
		}
		arg := &ArgBlock{Value: p.ParseExpression(sepCursor - 1)}
		arg.Type = arg.Value.Type
		p.Lexer.Skip(',')
		c.Args = append(c.Args, arg)
	}
	// 查找父级内容，找到定义位置
	p.Lexer.Skip(')')

	node := &Node{Value: c}
	c.Node = node
	p.ThisBlock.AddChild(node)
	c.Node.Ignore = true
}

func (c *CallBlock) ParseArgsDefault(p *Parser) error {
	if len(c.Args) == len(c.Func.Args) {
		return nil
	}
	for i := len(c.Args); i < len(c.Func.Args); i++ {
		if len(c.Args) <= i && c.Func.Args[i].Default == nil {
			return errors.New("args length error")
		} else {
			c.Args = append(c.Args, &ArgBlock{Value: c.Func.Args[i].Default, Defind: c.Func.Args[i]})
		}
	}
	return nil
}
