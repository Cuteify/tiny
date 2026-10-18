package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
)

// ForBlock for 循环结构体
type ForBlock struct {
	Init      *Expression // for 循环的变量定义
	Condition *Expression // 循环条件
	Increment *Expression // 循环后执行的增量表达式
	// for i, v := range coll 形态：Range 是被遍历的 list/string 表达式，
	// RangeNames 是绑定到栈槽的循环变量（[0]=索引，[1]=值）。
	// 非 range 形态时两者都是 nil，代码生成器据此走传统 for 那条路。
	Range      *Expression
	RangeNames []*VarBlock
	Offset     int
}

// Parse 解析 for 循环
func (f *ForBlock) Parse(p *Parser) {
	// 由于循环的条件部分的变量定义属于循环内，所以需要先插入Node
	// 创建ForBlock节点并添加到AST
	forNode := &Node{Value: f}

	// for i, v := range coll 形态优先试。判据是"能解析出「名字(,名字)* := range」
	// 这个前缀"——传统 for 的 init 形状不同（以 := / = / 表达式开头），
	// 撞不上这个前缀，所以失败即回退是安全的。
	if f.parseRange(p) {
		p.ThisBlock.AddChild(forNode)
		p.ThisBlock = forNode
		p.Lexer.Skip('{')
		return
	}

	// 解析初始化部分, 保证初始化所有变量插入在ForBlock节点前
	f.parseInit(p)

	// 进入ForBlock的作用域并解析循环体
	p.ThisBlock.AddChild(forNode)
	p.ThisBlock = forNode

	// 解析条件部分
	f.parseCondition(p)

	// 解析增量部分
	f.parseIncrement(p)

	// 开启循环体
	p.Lexer.Skip('{')
}

// parseRange 解析 `for i, v := range coll`。成功返回 true，失败时游标已复位。
//
// RangeNames 的类型留到 Check 里定：被遍历表达式的类型在 Parse 期常常还
// 没解析出来（元素类型可能来自另一个包），那时填等于猜。
func (f *ForBlock) parseRange(p *Parser) bool {
	start := p.Lexer.Cursor
	restore := func() bool { p.Lexer.SetCursor(start); return false }

	// 先看原始 token 是不是名字 —— 不能拿 ParseName 当探针：它末尾会对名字
	// 做 Check()，空名字直接报"name contains invalid characters"，
	// 于是"这里不是 range 形态"就会被误报成语法错。
	before := p.Lexer.Cursor
	probe := p.Lexer.Next()
	if probe.Type != lexer.NAME {
		return restore()
	}
	// 回到 Next() 之前 —— token.Cursor 是 Next() **之后**的位置，
	// 用它会把变量名本身跳过去。
	p.Lexer.SetCursor(before)

	var names []Name
	for {
		name, _ := p.ParseName(false)
		if len(name) == 0 {
			return restore()
		}
		names = append(names, name)
		t := p.Lexer.Next()
		if t.IsEmpty() {
			return restore()
		}
		if t.Type == lexer.SEPARATOR && t.Value == "," {
			continue
		}
		// := 与 = 都接受（for i := range x / for i = range x）
		if t.Type == lexer.SEPARATOR && (t.Value == ":=" || t.Value == "=") {
			kw := p.Lexer.Next()
			// range 是关键字（PROCESSCONTROL，见 lexer/keywords.go），
			// 不能判 NAME —— 判了就永远匹配不上。
			if kw.Value == "range" {
				break
			}
		}
		return restore()
	}
	if len(names) > 2 {
		// range 最多绑定两个名字（索引 + 值）
		return restore()
	}

	endCursor := p.Has(lexer.Token{Type: lexer.SEPARATOR, Value: "{"}, p.FindEndCursor())
	if endCursor == -1 {
		return restore()
	}
	// ParseExp 会把游标停在 endCursor-1，也就是 '{' 之前 —— 后面的 Skip('{')
	// 正好接上。不要再 SetCursor(endCursor)：p.Has 返回的是该 token **之后**
	// 的位置，多设一次就跳过 '{' 了（症状是后面报 "need {"）。
	f.Range = p.ParseExp(endCursor - 1)
	if f.Range == nil {
		return restore()
	}

	// range 循环没有条件 —— 终止条件在代码生成里按索引与长度比较。
	f.Condition = &Expression{
		Type: typeSys.GetSystemType("bool"),
		Bool: true,
	}
	for _, n := range names {
		f.RangeNames = append(f.RangeNames, &VarBlock{
			Name:     n,
			IsDefine: true,
			Used:     true,
		})
	}
	return true
}

// parseInit 解析 for 循环的初始化部分
func (f *ForBlock) parseInit(p *Parser) {
	sepCursor := p.Has(lexer.Token{Type: lexer.SEPARATOR, Value: ";"}, p.FindEndCursor())
	switch sepCursor {
	case -1: // 只有条件部分
		return
	case p.Lexer.Cursor: // 没有初始化部分
		return
	}
	// 使用VarBlock解析变量定义
	f.Init = p.ParseExp(sepCursor - 1)
	p.Lexer.Skip(';')
}

// parseCondition 解析 for 循环的条件部分
func (f *ForBlock) parseCondition(p *Parser) {
	sepCursor := p.Has(lexer.Token{Type: lexer.SEPARATOR, Value: ";"}, p.FindEndCursor())
	endCursor := p.Has(lexer.Token{Type: lexer.SEPARATOR, Value: "{"}, p.FindEndCursor())
	if endCursor == -1 {
		// 没有结尾，报错
		p.Error.MissError("For Loop Error", p.Lexer.Cursor, "for loop must end by '{'")
	}
	if sepCursor == -1 {
		f.Condition = p.ParseExp(endCursor - 1)
	} else if sepCursor == p.Lexer.Cursor && endCursor == p.Lexer.Cursor {
		f.Condition = &Expression{
			Type: typeSys.GetSystemType("bool"),
			Bool: true,
		}
		if sepCursor == p.Lexer.Cursor {
			p.Lexer.Skip(';')
		}
	} else if sepCursor == p.Lexer.Cursor {
		// for ; cond; inc 形式：init 为空，条件在下一个 ; 之前
		p.Lexer.Skip(';')
		sepCursor2 := p.Has(lexer.Token{Type: lexer.SEPARATOR, Value: ";"}, p.FindEndCursor())
		if sepCursor2 == p.Lexer.Cursor {
			f.Condition = nil
		} else {
			f.Condition = p.ParseExp(sepCursor2 - 1)
		}
		p.Lexer.Skip(';')
	} else {
		f.Condition = p.ParseExp(sepCursor - 1)
		p.Lexer.Skip(';')
	}
}

// parseIncrement 解析 for 循环的增量部分
func (f *ForBlock) parseIncrement(p *Parser) {
	endCursor := p.Has(lexer.Token{Type: lexer.SEPARATOR, Value: "{"}, p.FindEndCursor())
	if endCursor == -1 {
		// 没有结尾，报错
		p.Error.MissError("For Loop Error", p.Lexer.Cursor, "for loop must end by '{'")
		return
	}

	incToken := p.Lexer.Next()
	// 检查是否直接遇到 ')' 或 ';' 后面是 '{'
	if incToken.Type == lexer.SEPARATOR && (incToken.Value == "{" || incToken.Value == ";") {
		p.Lexer.SetCursor(incToken.Cursor)
		return
	}

	// 有增量表达式
	p.Lexer.SetCursor(incToken.Cursor)
	f.Increment = p.ParseExp(endCursor - 1)
}

// Check 检查 for 循环的有效性
func (f *ForBlock) Check(p *Parser) bool {
	// range 形态：被遍历表达式 + 循环变量类型
	if f.Range != nil {
		if !f.Range.Check(p) {
			return false
		}
		elem := f.Range.Type
		if t, ok := elem.(*typeSys.ListType); ok && t.Elem() != nil {
			elem = t.Elem()
		}
		for i, rn := range f.RangeNames {
			if rn == nil {
				continue
			}
			if i == 0 {
				// 索引恒为平台整型（代码生成按指针宽度读写）
				rn.Type = typeSys.GetSystemType("int")
			} else if elem != nil {
				rn.Type = elem
			}
		}
		return true
	}

	// 检查初始化表达式
	if f.Init != nil {
		if !f.Init.Check(p) {
			return false
		}
	}

	// 检查条件表达式
	if f.Condition != nil {
		if !f.Condition.Check(p) {
			return false
		}
		// 条件必须是布尔类型
		if !typeSys.CheckType(f.Condition.Type, typeSys.GetSystemType("bool")) {
			p.Error.MissError("For Loop Error", p.Lexer.Cursor, "for loop condition must be boolean")
			return false
		}
	}

	// 检查增量表达式
	if f.Increment != nil {
		if !f.Increment.Check(p) {
			return false
		}
	}

	return true
}
