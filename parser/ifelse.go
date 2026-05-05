package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"reflect"
)

// IfBlock if 条件块结构体
type IfBlock struct {
	ElseBlock *Node
	Else      bool // 是否有else
	Condition *Expression
}

// ElseBlock else 块结构体
type ElseBlock struct {
	IfCondition *Expression
}

// Parse 解析 if 条件块
func (i *IfBlock) Parse(p *Parser) {
	bracketsCount := 0
	oldCursor := p.Lexer.Cursor

	// 找到末尾的{
	for p.FindEndCursor() > p.Lexer.Cursor {
		code := p.Lexer.Next()
		switch code.Value {
		case "(":
			bracketsCount++
		case ")":
			bracketsCount--
		}
		if bracketsCount == 0 && code.Value == "{" && code.Type == lexer.SEPARATOR {
			break
		}
	}
	stopCursor := p.Lexer.Cursor
	p.Lexer.SetCursor(oldCursor)
	i.Condition = p.ParseExp(stopCursor)
	p.Wait("{")
}

// Check 检查 if 条件块的有效性
func (i *IfBlock) Check(p *Parser) bool {
	if !i.Condition.Check(p) {
		return false
	}
	if !typeSys.CheckTypeType(i.Condition.Type, "bool") {
		return false
	}
	if i.Else {
		if !i.ElseBlock.Value.(*ElseBlock).IfCondition.Check(p) {
			return false
		}
		if !typeSys.CheckTypeType(i.ElseBlock.Value.(*ElseBlock).IfCondition.Type, "bool") {
			return false
		}
	}
	return true
}

// Parse 解析 else 块
func (e *ElseBlock) Parse(p *Parser) {
	tmp := p.Lexer.Next()
	if tmp.Value == "IF" && tmp.Type == lexer.PROCESSCONTROL {
		bracketsCount := 0
		oldCursor := p.Lexer.Cursor

		// 找到末尾的{
		for p.FindEndCursor() > p.Lexer.Cursor {
			code := p.Lexer.Next()
			switch code.Value {
			case "(":
				bracketsCount++
			case ")":
				bracketsCount--
			}
			if bracketsCount == 0 && code.Value == "{" && code.Type == lexer.SEPARATOR {
				break
			}
		}
		stopCursor := p.Lexer.Cursor
		p.Lexer.SetCursor(oldCursor)
		e.IfCondition = p.ParseExp(stopCursor)
		p.Wait("{")
	} else if !(tmp.Value == "{" && tmp.Type == lexer.SEPARATOR) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need {")
	}
	if len(p.ThisBlock.Children) == 0 {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "else before if")
	}
	if reflect.TypeOf(p.ThisBlock.Children[len(p.ThisBlock.Children)-1].Value) == reflect.TypeOf(&IfBlock{}) {
		nodeTmp := &Node{Value: e, Father: p.ThisBlock}
		p.ThisBlock.Children[len(p.ThisBlock.Children)-1].Value.(*IfBlock).Else = true
		p.ThisBlock.Children[len(p.ThisBlock.Children)-1].Value.(*IfBlock).ElseBlock = nodeTmp
		p.ThisBlock = nodeTmp
	} else {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "else before if")
	}

}
