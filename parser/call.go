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
	NewType typeSys.Type // new(T) 的目标类型（内建堆对象创建）
}


// safeTypeName nil 安全的类型名（首趟未解析的跨包调用实参 Type 为 nil）
func safeTypeName(t typeSys.Type) string {
	if t == nil {
		return "<unresolved>"
	}
	return t.Type()
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
				fb.Useful = true
				c.Func = fb
				// 包名被方法分支误判为接收者时，清除伪 ThisVar
				if fb.Class == nil {
					c.ThisVar = nil
				}
			}
		}
	}

	// 内置包兜底：无命名空间调用（print(...)）→ 注册表直接定位函数块。
	// 本地/用户函数优先：仅在上方查找失败后进入；
	// 直接设置 c.Func，首趟即完成参数检查，无需等待包合并重试。
	if c.Func == nil && !c.Name.IsPath() {
		if fb, ok := BuiltinFuncs[c.Name.First()]; ok {
			fb.Useful = true
			c.Func = fb
			c.ThisVar = nil
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
		// 接收者必须为简单名：FixPkgNamePaths 固定的完整包路径（如
		// /home/.../pkg/memory.store64）不是方法调用，跳过 ParseDefine
		//（CheckName 会因路径段中的 '/' 报 "name is not valid"）。
		if !receiverName.IsPath() {
			c.ThisVar = &VarBlock{Name: receiverName}
			c.ThisVar.ParseDefine(p)
		}
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
		// 获取对应的函数定义参数
		defArg := c.Func.Args[i]

		arg.Value.Check(p)

		// 类型检查。首趟解析时跨包调用尚未解析，arg.Value.Type 可能为 nil，
		// 此时跳过检查（合并后 rootNode.Check 重试会补齐）；错误消息里的
		// 类型名同样需要判空，避免构造消息时二次崩溃。
		if arg.Value.Type != nil && defArg.Type != nil &&
			!typeSys.AutoType(arg.Value.Type, defArg.Type, true) {
			p.Error.MissError("Type Error", p.Lexer.Cursor-1,
				"cannot use "+safeTypeName(arg.Value.Type)+" as type "+
					safeTypeName(defArg.Type)+" in argument to "+c.Name.String())
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
	depth := 0 // 括号深度：支持嵌套调用作为参数（如 f(g(x), y)）

	for {
		oldCursor := p.Lexer.Cursor
		for {
			token = p.Lexer.Next()

			if token.Type == lexer.SEPARATOR && token.Value == "(" {
				depth++
				continue
			}
			if token.Type == lexer.SEPARATOR && token.Value == ")" && depth > 0 {
				depth--
				continue
			}

			if token.Type == lexer.SEPARATOR && token.Value == ")" {
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

			if token.Type == lexer.SEPARATOR && token.Value == "," && depth == 0 {
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
	case "new":
		// new(T[, v...])：堆对象创建内建，返回 *T；
		// new(list[T], len[, cap])：列表创建内建，按值返回列表
		if c.NewType != nil {
			retType := typeSys.Type(typeSys.MakePointer(c.NewType))
			if lt, ok := c.NewType.(*typeSys.ListType); ok && lt.Elem() != nil {
				retType = lt
			}
			c.Func = &FuncBlock{
				Return: []typeSys.Type{retType},
			}
			for _, arg := range c.Args {
				if arg != nil && arg.Value != nil {
					arg.Value.Check(p)
				}
			}
			return true
		}
	case "len", "lists_len":
		if len(c.Args) == 1 {
			c.Args[0].Value.Check(p)
			argType := c.Args[0].Value.Type
			if argType != nil && (argType.Kind() == "string" || argType.Kind() == "list") {
				// 字符串走 link 路径（call __string_len）：提前标记提供者 Useful，
				// 否则提供者可能因无人显式调用被死代码消除（链接期符号未定义）
				if argType.Kind() == "string" {
					if fb, ok := LinkProviders["__string_len"]; ok {
						fb.Useful = true
					}
				}
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
				if argType.Kind() == "string" {
					if fb, ok := LinkProviders["__string_cap"]; ok {
						fb.Useful = true
					}
				}
				c.Func = &FuncBlock{
					Return: []typeSys.Type{typeSys.GetSystemType("int")},
				}
				return true
			}
		}
	case "copy":
		// copy(dst, src)：同 Kind（str/str 或 list/list）元素拷贝，
		// 拷贝 min(len(dst), len(src)) 个元素，返回拷贝计数
		if len(c.Args) == 2 && c.Args[0].Value != nil && c.Args[1].Value != nil {
			c.Args[0].Value.Check(p)
			c.Args[1].Value.Check(p)
			dstType := c.Args[0].Value.Type
			srcType := c.Args[1].Value.Type
			if dstType != nil && srcType != nil &&
				dstType.Kind() == srcType.Kind() &&
				(dstType.Kind() == "string" || dstType.Kind() == "list") {
				c.Func = &FuncBlock{
					Return: []typeSys.Type{typeSys.GetSystemType("int")},
				}
				return true
			}
		}
	}
	return false
}


// ParseNew 解析 new(T[, v1, v2...])：首个参数为类型名（parseTypeAnnotation），其余为字段初值
func (c *CallBlock) ParseNew(p *Parser) {
	p.Lexer.Skip('(')
	c.NewType = p.parseTypeAnnotation()
	if c.NewType == nil {
		p.Error.MissError("Type Error", p.Lexer.Cursor, "type not found in new()")
		return
	}
	depth := 0
	for {
		oldCursor := p.Lexer.Cursor
		for {
			token := p.Lexer.Next()
			if token.IsEmpty() {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "expected ')' in new()")
				return
			}
			if token.Type == lexer.SEPARATOR && token.Value == "(" {
				depth++
				continue
			}
			if token.Type == lexer.SEPARATOR && token.Value == ")" && depth > 0 {
				depth--
				continue
			}
			if token.Type == lexer.SEPARATOR && token.Value == ")" {
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
			if token.Type == lexer.SEPARATOR && token.Value == "," && depth == 0 {
				stopCursor := token.Cursor
				p.Lexer.SetCursor(oldCursor)
				argExp := p.ParseExp(stopCursor)
				if argExp != nil {
					c.Args = append(c.Args, &ArgBlock{Value: argExp})
				}
				if p.Lexer.Cursor <= stopCursor {
					p.Lexer.Skip(',')
				}
				break
			}
		}
	}
}
