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

	if c.checkBuiltin(p) {
		return true
	}

	if c.Func == nil {
		results := p.Find(c.Name, FindTypeFunc)
		for _, node := range results {
			fb, ok := node.Value.(*FuncBlock)
			if !ok {
				continue
			}
			ignored := false
			for _, buildFlag := range fb.BuildFlags {
				if buildFlag.Ignore {
					ignored = true
					break
				}
			}
			if ignored {
				continue
			}
			fb.Useful = true
			if c.Func == nil {
				c.Func = fb
				// 包名被方法分支误判为接收者时，清除伪 ThisVar
				if fb.Class == nil {
					c.ThisVar = nil
				}
			}
		}
	}

	// 方法调用（找到的 Func 属于类型）：设置 ThisVar 为接收者
	if c.Func != nil && c.Func.Class != nil && c.ThisVar == nil && c.Name.IsPath() {
		receiverName := c.Name.Fork()
		receiverName = receiverName[:len(receiverName)-1]
		c.ThisVar = &VarBlock{Name: receiverName}
		c.ThisVar.ParseDefine(p)
	}

	// If still not found and name is a path (e.g. a.len), try method call
	if c.Func == nil && c.Name.IsPath() && c.ThisVar == nil {
		receiverName := c.Name.Fork()
		receiverName = receiverName[:len(receiverName)-1]
		c.ThisVar = &VarBlock{Name: receiverName}
		c.ThisVar.ParseDefine(p)
	}

	if c.Func == nil && c.ThisVar != nil {
		results := p.Find(c.ThisVar.Name, FindTypeVar|FindTypeItem)
		if len(results) > 0 {
			if vb, ok := results[0].Value.(*VarBlock); ok {
				c.ThisVar = vb
			} else if arg, ok := results[0].Value.(*ArgBlock); ok {
				c.ThisVar = &VarBlock{
					Name: arg.Name,
					Type: arg.Type,
				}
			}
		}
		if c.ThisVar.Type != nil && c.ThisVar.Type.Kind() == "list" {
			methodName := c.Name.Last()
			switch methodName {
			case "len", "cap", "ptr":
				c.Func = &FuncBlock{
					Return: []typeSys.Type{typeSys.GetSystemType("int")},
					Name:   NewName("__list_" + methodName),
				}
			}
		}
	}

	if c.Func == nil {
		if c.Name.IsPath() {
			// 跨包调用：包函数在全部包解析完成合并后才可见，
			// 此处静默返回，由合并后的 rootNode.Check() 重试解析
			return true
		}
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
				if p.Lexer.Cursor <= stopCursor {
					p.Lexer.Skip(')')
				}
				c.Check(p)
				return
			}

			if token.Value == "," {
				stopCursor := token.Cursor
				p.Lexer.SetCursor(oldCursor)

				argExp := p.ParseExp(stopCursor)
				if argExp != nil {
					c.Args = append(c.Args, &ArgBlock{Value: argExp})
				}
				if p.Lexer.Cursor <= token.Cursor {
					p.Lexer.SetCursor(token.Cursor + 1)
				}
				break
			}
		}
	}
	c.Check(p)
}

func (c *CallBlock) Parse(p *Parser) {
	c.ParseCall(p)
	p.ThisBlock.AddChild(&Node{Value: c})
}

func (c *CallBlock) checkBuiltin(p *Parser) bool {
	name := c.Name.String()
	switch name {
	case "len", "lists_len":
		if len(c.Args) == 1 {
			c.Args[0].Value.Check(p)
			argType := c.Args[0].Value.Type
			if argType != nil && (argType.Kind() == "string" || argType.Kind() == "list") {
				c.Func = &FuncBlock{
					Return: []typeSys.Type{typeSys.GetSystemType("int")},
				}
				return true
			}
		}
	case "cap", "lists_cap":
		if len(c.Args) == 1 {
			c.Args[0].Value.Check(p)
			argType := c.Args[0].Value.Type
			if argType != nil && (argType.Kind() == "string" || argType.Kind() == "list") {
				c.Func = &FuncBlock{
					Return: []typeSys.Type{typeSys.GetSystemType("int")},
				}
				return true
			}
		}
	}
	return false
}
