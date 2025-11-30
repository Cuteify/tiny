package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"cuteify/utils"
)

type FuncBlock struct {
	Args       []*ArgBlock
	Class      typeSys.Type
	Return     []typeSys.Type
	Name       string
	BuildFlags []*Build
}

type ArgBlock struct {
	Name    string
	Type    typeSys.Type
	Default *Expression
	Defind  *ArgBlock
	Value   *Expression
	Offset  int
}

func (f *FuncBlock) Parse(p *Parser) {
	if p.ThisBlock.Father != nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Function can't be defined in Function")
	}
	// 判断有没有父类
	code := p.Lexer.Next()
	if code.Type == lexer.NAME {
		// 匹配名字
		f.Name = code.Value
		if !utils.CheckName(f.Name) {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
		}
		// 匹配参数
		code := p.Lexer.Next()
		if code.Value != "(" {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need (")
		}
		f.ParseArgs(p)
		// 获取返回值类型
		f.Return = []typeSys.Type{}
		// 开始获取返回值
		code = p.Lexer.Next()
		if code.Type == lexer.NAME {
			f.Return = append(f.Return, typeSys.GetSystemType(code.Value))
		} else {
			p.Lexer.Back(code.Len())
		}
		p.Wait("{")
		nodeTmp := &Node{Value: f}
		//p.Funcs[f.Name] = nodeTmp
		p.ThisBlock.AddChild(nodeTmp)
		p.ThisBlock = nodeTmp
	} else if code.Value == "(" {
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

func (f *FuncBlock) ParseArgs(p *Parser) {
	//解析括号
	brackets := p.Brackets(false)
	lastVal := ""
	oldCursor := p.Lexer.Cursor
	for i := 0; i < len(brackets.Children); i++ {
		v := brackets.Children[i]
		isPtr := false
		if v.Brackets != nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "miss )")
		}
		if v.Value.Type == lexer.NAME && lastVal == "" {
			f.Args = []*ArgBlock{{Name: v.Value.Value}}
			if !utils.CheckName(v.Value.Value) {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
			}
			oldCursor = v.Value.Cursor
		} else if v.Value.Type == lexer.NAME && lastVal == "," {
			f.Args = append(f.Args, &ArgBlock{Name: v.Value.Value})
			if !utils.CheckName(v.Value.Value) {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
			}
			oldCursor = v.Value.Cursor
		} else if v.Value.Type == lexer.NAME && lastVal == ":" {
			tb := &TypeBlock{}
			tmp := tb.FindDefine(p, v.Value.Value)
			f.Args[len(f.Args)-1].Type = tmp
			rtmp := typeSys.ToRType(tmp)
			if f.Args[len(f.Args)-1].Type != nil {
				rtmp.IsPtr = isPtr
			} else {
				p.Error.MissErrors("Syntax Error", oldCursor, v.Value.Cursor, "need type")
			}
		} else if v.Value.Type == lexer.NAME && lastVal == "*" {
			isPtr = true
		} else if v.Value.Value == "=" {
			tmp := []lexer.Token{}
			// 遍历直到遇到,或结束
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
			p.Lexer.Cursor = v.Value.EndCursor
			f.Args[len(f.Args)-1].Default = p.ParseExpression(tmp[len(tmp)-1].EndCursor)
		}
		if len(f.Args)-2 >= 0 && f.Args[len(f.Args)-1].Default == nil && f.Args[len(f.Args)-2].Default != nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "miss default value, before "+f.Args[len(f.Args)-1].Name)
		}
		lastVal = v.Value.Value
	}
	// 如果没有参数类型，则报错
	for i := len(f.Args) - 1; i >= 0; i-- {
		if f.Args[i].Type == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "miss type")
		}
	}
}

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

func (f *FuncBlock) Check(p *Parser) bool {
	argCount := 4 // Todo: 返回指针长度，需要根据Arch改后续！
	for _, v := range f.Args {
		if !v.Check(p) {
			return false
		}
		v.Offset = argCount + v.Type.Size()
	}
	return true
}
