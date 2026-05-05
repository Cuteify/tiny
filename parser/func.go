package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
)

// FuncBlock 函数定义结构体
type FuncBlock struct {
	Args       []*ArgBlock    // 函数参数列表
	Class      typeSys.Type   // 所属类类型（面向对象时使用）
	Return     []typeSys.Type // 返回值类型列表（支持多返回值）
	Name       Name           // 函数名
	BuildFlags []*Build       // 编译标志
	Useful     bool           // 是否有用（用于优化）
}

// ArgBlock 函数参数结构体
type ArgBlock struct {
	Name    Name         // 参数名
	Type    typeSys.Type // 参数类型
	Default *Expression  // 默认值表达式
	Defind  *ArgBlock    // 指向参数定义（用于类型检查）
	Value   *Expression  // 参数实际传入的值
	Offset  int          // 参数在栈中的偏移量（用于代码生成）
}

// Check 检查参数的有效性
func (f *ArgBlock) Check(p *Parser) bool {
	if f.Default != nil {
		return f.Default.Check(p)
	}
	if f.Value != nil {
		return f.Value.Check(p)
	}
	if f.Defind != nil {
		if !f.Defind.Check(p) {
			return false
		}
		// 检测类型
		return typeSys.CheckType(f.Type, f.Defind.Type)
	}
	return true
}

// Parse 解析函数定义
// 语法格式: funcName(arg1 type1, arg2 type2) returnType { ... }
// 或者: fn Type.methodName(arg1 type1, arg2 type2) returnType { ... }
func (f *FuncBlock) Parse(p *Parser) {
	// 检查函数是否嵌套定义（不支持）
	if p.ThisBlock.Father != nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Function can't be defined in Function")
	}

	oldCursor := p.Lexer.Cursor
	// 判断有没有父类
	code := p.Lexer.Next()
	if code.Type == lexer.NAME {
		// 退格到函数名开始位置
		p.Lexer.SetCursor(oldCursor)
		f.Name, _ = p.Name(false)

		if len(f.Name) == 0 {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need Function name")
			return
		}

		if len(f.Name) > 2 {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Function name can't be more than 2 parts")
			return
		}

		//TODO：解析成员函数
		/*if len(f.Name) == 2 {
			structName := NewName(f.Name[0])
			_, structBlock := p.FindStruct(structName)
			if structBlock == nil {
				p.Error.MissError("Struct Error", p.Lexer.Cursor, "struct '"+structName.String()+"' not found")
			}
			f.Class = structBlock.Type()
			structBlock.Methods = append(structBlock.Methods, f)
		}*/
	} else if code.Value == "(" { // 匿名函数/闭包支持
		p.Lexer.SetCursor(code.Cursor)
	} else {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need Function name")
	}

	// 解析参数
	f.ParseArgs(p)

	// 返回类型
	f.ParseRetType(p)

	p.Wait("{")

	if code.Type == lexer.NAME {
		nodeTmp := &Node{Value: f}
		// 将函数添加到当前作用域
		p.ThisBlock.AddChild(nodeTmp)

		// 进入函数作用域
		p.ThisBlock = nodeTmp
	}

	// TODO: 处理编译标志
}

// ParseArgs 解析函数参数列表
// 语法格式: (arg1 type1, arg2 type2 = default, ...)
func (f *FuncBlock) ParseArgs(p *Parser) {
	// 跳过开始的(
	p.Lexer.Skip('(')

	// 自动机，找到分割符号 = 或者 )
	token := p.Lexer.Next()

	// 状态
	bracketCount := 0
	argTmp := &ArgBlock{}

	// 存入第一个参数的名字
	if token.Type != lexer.NAME {
		if token.Value != ")" || token.Type != lexer.SEPARATOR {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need )")
		}
		return
	}

	p.Lexer.SetCursor(token.Cursor)
	n, _ := p.Name(false)
	argTmp.Name = n

	for !token.IsEmpty() {
		if token.Type != lexer.SEPARATOR { // 遇到非分割符，跳过
			token = p.Lexer.Next()
			continue
		}

		if token.Value == "\n" || token.Value == "\r" {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need )")
		}

		if bracketCount <= -1 { // 找到参数结束的)
			if !argTmp.Name.IsEmpty() {
				f.Args = append(f.Args, argTmp)
			}
			break
		}

		// 处理括号
		if token.Value == "(" {
			bracketCount++
			continue
		}
		if token.Value == ")" {
			bracketCount--
			continue
		}

		// 处理其他部分
		if bracketCount == 0 {
			if token.Value == ":" {
				// 先后解析一个Name作为参数类型
				n, _ := p.Name(false)
				_, argTmp.Type = p.FindType(n)
				if argTmp.Type == nil {
					p.Lexer.Error.MissError("Type Error", p.Lexer.Cursor, "type not found")
					token = p.Lexer.Next()
					continue
				}
			}

			// TODO: 处理指针类型（token.Value == "*"）
			// if token.Value == "*" {
			// 	argTmp.Type = typeSys.NewPointerType(argTmp.Type)
			// }

			if token.Value == "=" {
				oldCursor := token.Cursor
				p.Wait(",")
				stopCursor := token.Cursor
				p.Lexer.SetCursor(oldCursor)
				// 处理默认值
				argTmp.Default = p.ParseExp(stopCursor - 1)
			}

			if token.Value == "," {
				f.Args = append(f.Args, argTmp)
				argTmp = &ArgBlock{}
				// 获取下一参数的名称
				n, _ := p.Name(false)
				argTmp.Name = n
			}
		}
		token = p.Lexer.Next()
	}
}

// ParseRetType 解析函数返回类型
func (f *FuncBlock) ParseRetType(p *Parser) {
	// TODO:多参数支持
	typName, _ := p.Name(false)
	_, typ := p.FindType(typName)
	f.Return = append(f.Return, typ)
}

/*
func (f *FuncBlock) parseArgToken(p *Parser, v *BracketsValue, lastVal string, isPtr *bool, oldCursor *int) {
	switch lastVal {
	case "":
		f.parseFirstArg(p, v)
		*oldCursor = v.Value.Cursor
	case ",":
		f.parseCommaArg(p, v)
		*oldCursor = v.Value.Cursor
	case ":":
		f.parseTypeArg(p, v, *isPtr, *oldCursor)
	case "*":
		*isPtr = true
	}
}

func (f *FuncBlock) parseFirstArg(p *Parser, v *BracketsValue) {
	f.Args = []*ArgBlock{{}} // 第一个参数
	// 解析参数名
	(&f.Args[0].Name).ReadFromToken(v.Value)
	if !f.Args[0].Name.Check() || f.Args[0].Name.IsPath() {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
}

func (f *FuncBlock) parseCommaArg(p *Parser, v *BracketsValue) {
	f.Args = append(f.Args, &ArgBlock{})
	// 解析参数名
	(&f.Args[len(f.Args)-1].Name).ReadFromToken(v.Value)
	if !f.Args[len(f.Args)-1].Name.Check() || f.Args[len(f.Args)-1].Name.IsPath() {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
}

func (f *FuncBlock) parseTypeArg(p *Parser, v *BracketsValue, isPtr bool, oldCursor int) {
	tb := &TypeBlock{}
	tmp := tb.FindDefine(p, Name([]string{v.Value.Value}))
	f.Args[len(f.Args)-1].Type = tmp

	if tmp != nil {
		rtmp := typeSys.ToRType(tmp)
		rtmp.IsPtr = isPtr
	} else {
		p.Error.MissErrors("Syntax Error", oldCursor, v.Value.Cursor, "need type")
	}
}

func (f *FuncBlock) parseArgDefault(p *Parser, brackets *Brackets, i int) int {
	tmp := []lexer.Token{}
	for {
		i++
		if i >= len(brackets.Children) {
			break
		}
		v := brackets.Children[i]
		tmp = append(tmp, v.Value)
		if v.Value.Value == "," {
			break
		}
	}
	p.Lexer.SetCursor(brackets.Children[i].Value.EndCursor)
	f.Args[len(f.Args)-1].Default = p.ParseExp(tmp[len(tmp)-1].EndCursor)
	return i
}

func (f *FuncBlock) validateDefaultOrder(p *Parser) {
	if len(f.Args) >= 2 && f.Args[len(f.Args)-1].Default == nil && f.Args[len(f.Args)-2].Default != nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "miss default value, before "+f.Args[len(f.Args)-1].Name.String())
	}
}

func (f *FuncBlock) validateAllArgTypes(p *Parser) {
	for i := len(f.Args) - 1; i >= 0; i-- {
		if f.Args[i].Type == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "miss type")
		}
	}
}*/

// Check 检查函数定义的有效性，并计算参数的栈偏移量
// 在 cdecl 调用约定中，参数从右到左压栈
// 返回地址占用 4 字节，所以第一个参数从 [ebp+8] 开始
func (f *FuncBlock) Check(p *Parser) bool {
	// 计算参数起始偏移量
	argCount := 8

	for _, v := range f.Args {
		if !v.Check(p) {
			return false
		}
		v.Offset = argCount
		argCount += v.Type.Size()
	}
	return true
}
