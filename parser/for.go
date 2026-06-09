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

// Parse 解析 for 循环
func (f *ForBlock) Parse(p *Parser) {
	// 由于循环的条件部分的变量定义属于循环内，所以需要先插入Node
	// 创建ForBlock节点并添加到AST
	forNode := &Node{Value: f}

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
		return
	}

	// 有增量表达式
	p.Lexer.SetCursor(incToken.Cursor)
	f.Increment = p.ParseExp(endCursor - 1)
}

// Check 检查 for 循环的有效性
func (f *ForBlock) Check(p *Parser) bool {
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
