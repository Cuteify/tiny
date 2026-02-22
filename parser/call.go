package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"strings"
)

type CallBlock struct {
	Name Name
	Args []*ArgBlock
	Func *FuncBlock
	Node *Node
}

func (c *CallBlock) Check(parser *Parser) bool {
	// 检查函数名
	if c.Name.IsEmpty() {
		parser.Error.MissError("Call Error", parser.Lexer.Cursor, "function name is empty")
		return false
	}

	// 查找函数定义
	if c.Func == nil {
		c.Func = parser.Find(c.Name, c.Func).Value.(*FuncBlock)
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
	// 解析参数列表 (...)
	p.Lexer.Skip('(')
	var token lexer.Token

	// 解析参数直到遇到右括号
	for {
		oldCursor := p.Lexer.Cursor // 记录当前位置，用于解析参数表达式
		// 等待参数分割
		for {
			token = p.Lexer.Next()

			if token.Value == ")" {
				stopCursor := token.Cursor   // 记录参数结束位置
				p.Lexer.SetCursor(oldCursor) // 回退token，让表达式解析器处理

				argExp := p.ParseExpression(stopCursor)
				if argExp != nil {
					c.Args = append(c.Args, &ArgBlock{Value: argExp})
				}
				// 消耗右括号
				p.Lexer.Skip(')')
				// 结束参数列表
				return
			}

			if token.Value == "," && len(c.Args) == 0 {
				p.Error.MissError("Call Error", token.Cursor, "expected argument before ','")
			}

			if token.Value == "," {
				break
			}
		}

		stopCursor := token.Cursor   // 记录参数结束位置
		p.Lexer.SetCursor(oldCursor) // 回退token，让表达式解析器处理

		argExp := p.ParseExpression(stopCursor)
		if argExp != nil {
			c.Args = append(c.Args, &ArgBlock{Value: argExp})
		}
	}
}

func (c *CallBlock) Parse(p *Parser) {
	c.ParseCall(p)
	p.ThisBlock.AddChild(&Node{Value: c})
}
