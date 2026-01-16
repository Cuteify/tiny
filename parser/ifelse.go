package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"reflect"
)

type IfBlock struct {
	ElseBlock *Node
	Else      bool // 是否有else
	Condition *Expression
}

type ElseBlock struct {
	IfCondition *Expression
}

func (i *IfBlock) Parse(p *Parser) {
	// 解析括号
	brackets := p.Brackets(true)
	p.Lexer.SetCursor(brackets.Children[0].Value.Cursor)
	i.Condition = p.ParseExpression(brackets.Children[len(brackets.Children)-1].Value.EndCursor)
	p.Wait("{")
	nodeTmp := &Node{Value: i}
	p.ThisBlock.AddChild(nodeTmp)
	p.ThisBlock = nodeTmp

}

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

func (e *ElseBlock) Parse(p *Parser) {
	tmp := p.Lexer.Next()
	if tmp.Value == "IF" && tmp.Type == lexer.PROCESSCONTROL {
		brackets := p.Brackets(true)
		p.Lexer.SetCursor(brackets.Children[0].Value.Cursor)
		e.IfCondition = p.ParseExpression(brackets.Children[len(brackets.Children)-1].Value.EndCursor)
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
