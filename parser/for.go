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
	Offset    int
}

// ParseFor 解析 for 循环
func (f *ForBlock) Parse(p *Parser) {
	// 跳过 '('
	p.Lexer.Skip('(')

	// 由于循环的条件部分的变量定义属于循环内，所以需要先插入Node
	// 创建ForBlock节点并添加到AST
	forNode := &Node{Value: f}
	p.ThisBlock.AddChild(forNode)

	// 进入ForBlock的作用域并解析循环体
	p.ThisBlock = forNode

	// 解析初始化部分
	f.parseInit(p)

	// 解析条件部分
	f.parseCondition(p)

	// 解析增量部分
	f.parseIncrement(p)

	// 跳过 ')'
	p.Lexer.Skip(')')

	// 开启循环体
	p.Lexer.Skip('{')
}

// parseInit 解析 for 循环的初始化部分
func (f *ForBlock) parseInit(p *Parser) {
	sepCursor := p.Has(lexer.Token{Type: lexer.SEPARATOR, Value: ";"}, p.FindEndCursor())
	if sepCursor == -1 { // 只有条件
		return
	} else if sepCursor == p.Lexer.Cursor { // 没有初始化部分
		return
	}
	// 使用VarBlock解析变量定义
	f.Init = p.ParseExpression(sepCursor)
	p.Lexer.Skip(';')
}

// parseCondition 解析 for 循环的条件部分
func (f *ForBlock) parseCondition(p *Parser) {
	sepCursor := p.Has(lexer.Token{Type: lexer.SEPARATOR, Value: ";"}, p.FindEndCursor())
	endCursor := p.Has(lexer.Token{Type: lexer.SEPARATOR, Value: ")"}, p.FindEndCursor())
	if endCursor == -1 {
		// 没有结尾，报错
		p.Error.MissError("For Loop Error", p.Lexer.Cursor, "for loop must end by ')'")
	}
	if sepCursor == -1 {
		f.Condition = p.ParseExpression(endCursor)
		p.Lexer.Skip(')')
	} else if sepCursor == p.Lexer.Cursor && endCursor == p.Lexer.Cursor {
		f.Condition = &Expression{
			Type: typeSys.GetSystemType("bool"),
			Bool: true,
		}
		if sepCursor == p.Lexer.Cursor {
			p.Lexer.Skip(';')
		} else {
			p.Lexer.Skip(')')
		}
	} else {
		f.Condition = p.ParseExpression(sepCursor)
		p.Lexer.Skip(';')
	}
}

// parseIncrement 解析 for 循环的增量部分
func (f *ForBlock) parseIncrement(p *Parser) {
	endCursor := p.Has(lexer.Token{Type: lexer.SEPARATOR, Value: ")"}, p.FindEndCursor())
	if endCursor == -1 {
		// 没有结尾，报错
		p.Error.MissError("For Loop Error", p.Lexer.Cursor, "for loop must end by ')'")
		return
	}

	incToken := p.Lexer.Next()
	// 检查是否直接遇到 ')' 或 ';' 后面是 ')'
	if incToken.Type == lexer.SEPARATOR && (incToken.Value == ")" || incToken.Value == ";") {
		return
	}

	// 有增量表达式
	p.Lexer.SetCursor(incToken.Cursor)
	f.Increment = p.ParseExpression(endCursor)
	p.ThisBlock.Children = p.ThisBlock.Children[:len(p.ThisBlock.Children)-1]
}

// Check 检查 for 循环的有效性
func (f *ForBlock) Check(p *Parser) bool {
	// 检查初始化表达式
	if f.Increment != nil {
		if !f.Increment.Check(p) {
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
