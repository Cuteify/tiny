package parser

import "cuteify/lexer"

// DeferBlock defer 语句结构体
type DeferBlock struct {
	Call *CallBlock // 要延迟执行的函数调用
}

// Parse 解析 defer 语句
func (d *DeferBlock) Parse(p *Parser) {
	code := p.Lexer.Next()
	if code.IsEmpty() || code.Type != lexer.NAME {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "defer requires a function call")
		return
	}

	call := &CallBlock{Name: NewName(code.Value)}
	call.ParseCall(p)
	d.Call = call
}

// Check 检查 defer 语句的有效性
func (d *DeferBlock) Check(p *Parser) bool {
	if d.Call == nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "defer requires a function call")
		return false
	}
	return d.Call.Check(p)
}
