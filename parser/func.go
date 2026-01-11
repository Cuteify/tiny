package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"cuteify/utils"
)

// FuncBlock 函数定义结构体
type FuncBlock struct {
	Args       []*ArgBlock    // 函数参数列表
	Class      typeSys.Type   // 所属类类型（面向对象时使用）
	Return     []typeSys.Type // 返回值类型列表（支持多返回值）
	Name       string         // 函数名
	BuildFlags []*Build       // 编译标志
}

// ArgBlock 函数参数结构体
type ArgBlock struct {
	Name    string       // 参数名
	Type    typeSys.Type // 参数类型
	Default *Expression  // 默认值表达式
	Defind  *ArgBlock    // 指向参数定义（用于类型检查）
	Value   *Expression  // 参数实际传入的值
	Offset  int          // 参数在栈中的偏移量（用于代码生成）
}

// Parse 解析函数定义
// 语法格式: funcName(arg1 type1, arg2 type2) returnType { ... }
func (f *FuncBlock) Parse(p *Parser) {
	// 检查函数是否嵌套定义（不支持）
	if p.ThisBlock.Father != nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Function can't be defined in Function")
	}

	// 判断有没有父类
	code := p.Lexer.Next()
	if code.Type == lexer.NAME {
		// 匹配函数名
		f.Name = code.Value
		if !utils.CheckName(f.Name) {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
		}
		// 匹配参数列表
		code := p.Lexer.Next()
		if code.Value != "(" {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need (")
		}
		f.ParseArgs(p)
		// 获取返回值类型
		f.Return = []typeSys.Type{}
		// 开始获取返回值类型
		code = p.Lexer.Next()
		if code.Type == lexer.NAME {
			f.Return = append(f.Return, typeSys.GetSystemType(code.Value))
		} else {
			p.Lexer.SetCursor(code.Cursor)
		}
		// 等待函数体开始
		p.Wait("{")
		nodeTmp := &Node{Value: f}
		// 将函数添加到当前作用域
		p.ThisBlock.AddChild(nodeTmp)
		// 进入函数作用域
		p.ThisBlock = nodeTmp
	} else if code.Value == "(" {
		// 匿名函数/闭包支持
		tmp := p.Brackets(true)
		for _, v := range tmp.Children {
			if v.Brackets != nil {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "miss (")
			}
		}
	} else {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need Function name")
	}
}

// ParseArgs 解析函数参数列表
// 语法格式: (arg1 type1, arg2 type2 = default, ...)
func (f *FuncBlock) ParseArgs(p *Parser) {
	brackets := p.Brackets(false)
	oldCursor := p.Lexer.Cursor
	isPtr := false
	lastVal := ""

	for i := 0; i < len(brackets.Children); i++ {
		v := brackets.Children[i]

		if v.Brackets != nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "miss )")
		}

		if v.Value.Value == "=" {
			i = f.parseArgDefault(p, brackets, i)
		} else if v.Value.Type == lexer.NAME {
			f.parseArgToken(p, v, lastVal, &isPtr, &oldCursor)
		}

		f.validateDefaultOrder(p)

		lastVal = v.Value.Value
	}

	f.validateAllArgTypes(p)
}

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
	f.Args = []*ArgBlock{{Name: v.Value.Value}}
	if !utils.CheckName(v.Value.Value) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
}

func (f *FuncBlock) parseCommaArg(p *Parser, v *BracketsValue) {
	f.Args = append(f.Args, &ArgBlock{Name: v.Value.Value})
	if !utils.CheckName(v.Value.Value) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
}

func (f *FuncBlock) parseTypeArg(p *Parser, v *BracketsValue, isPtr bool, oldCursor int) {
	tb := &TypeBlock{}
	tmp := tb.FindDefine(p, v.Value.Value)
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
	f.Args[len(f.Args)-1].Default = p.ParseExpression(tmp[len(tmp)-1].EndCursor)
	return i
}

func (f *FuncBlock) validateDefaultOrder(p *Parser) {
	if len(f.Args) >= 2 && f.Args[len(f.Args)-1].Default == nil && f.Args[len(f.Args)-2].Default != nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "miss default value, before "+f.Args[len(f.Args)-1].Name)
	}
}

func (f *FuncBlock) validateAllArgTypes(p *Parser) {
	for i := len(f.Args) - 1; i >= 0; i-- {
		if f.Args[i].Type == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "miss type")
		}
	}
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
