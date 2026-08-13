package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
)

// IfBlock if 条件块结构体
type IfBlock struct {
	ElseBlock *Node
	Else      bool // 是否有else
	Condition *Expression
	Node      *Node
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
	stopCursor := p.Lexer.Cursor - 1
	p.Lexer.SetCursor(oldCursor)
	i.Condition = p.ParseExp(stopCursor)
	i.Condition.Check(p)
	p.Wait("{")
	n := &Node{Value: i, Father: p.ThisBlock}
	i.Node = n
	p.AddChild(n)
	p.ThisBlock = n
}

// Check 检查 if 条件块的有效性
func (i *IfBlock) Check(p *Parser) bool {
	if !i.Condition.Check(p) {
		return false
	}

	if !typeSys.CheckKind(i.Condition.Type, "bool") {
		return false
	}

	if i.Condition.IsConst() && p.ThisBlock.Father == nil {
		if i.Condition.Bool {
			// 条件为 true，将当前 if 块替换为 then 块
			i.Node.Replace(i.Node.Children...)
			return true
		}
		// 条件为 false
		if i.Else && i.ElseBlock != nil {
			// 有 else 块，用 else 块替换 if 块
			i.Node.Replace(i.ElseBlock.Children...)
			return true
		}
		// 没有 else 块，直接删除 if 块
		i.Node.Replace()
		return true
	}

	if i.Else {
		if i.ElseBlock.Value.(*ElseBlock).IfCondition != nil {
			if !i.ElseBlock.Value.(*ElseBlock).IfCondition.Check(p) {
				return false
			}
			if !typeSys.CheckKind(i.ElseBlock.Value.(*ElseBlock).IfCondition.Type, "bool") {
				return false
			}
		}
		i.ElseBlock.Check()
	}
	return true
}

// innermostIf 沿 else-if 容器链下钻到最内层 if 分支
func innermostIf(ib *IfBlock) *IfBlock {
	for ib.ElseBlock != nil {
		if _, ok := ib.ElseBlock.Value.(*ElseBlock); !ok || len(ib.ElseBlock.Children) == 0 {
			break
		}
		n2, ok := ib.ElseBlock.Children[0].Value.(*IfBlock)
		if !ok {
			break
		}
		ib = n2
	}
	return ib
}

// Parse 解析 else 块
func (e *ElseBlock) Parse(p *Parser) {
	tmp := p.Lexer.Next()
	if tmp.Value == "if" && tmp.Type == lexer.PROCESSCONTROL {
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
		stopCursor := p.Lexer.Cursor - 1
		p.Lexer.SetCursor(oldCursor)
		cond := p.ParseExp(stopCursor)
		p.Wait("{")
		if len(p.ThisBlock.Children) == 0 {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "else before if")
		}
		ib, ok := p.ThisBlock.Children[len(p.ThisBlock.Children)-1].Value.(*IfBlock)
		if !ok {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "else before if")
		}
		// else-if 链：沿容器下钻到最内层 if 分支再挂载
		ib = innermostIf(ib)
		// else 容器内嵌套一个新的 if 块，承载 else-if 的条件与分支
		nodeTmp := &Node{Value: e, Father: p.ThisBlock}
		if2 := &IfBlock{Condition: cond}
		node2 := &Node{Value: if2, Father: p.ThisBlock, Parser: p}
		if2.Node = node2
		nodeTmp.Children = append(nodeTmp.Children, node2)
		ib.Else = true
		ib.ElseBlock = nodeTmp
		p.ThisBlock = node2
		return
	}
	if !(tmp.Value == "{" && tmp.Type == lexer.SEPARATOR) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need {")
	}
	if len(p.ThisBlock.Children) == 0 {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "else before if")
	}
	if ib, ok := p.ThisBlock.Children[len(p.ThisBlock.Children)-1].Value.(*IfBlock); ok {
		// else-if 链：沿 else-if 容器下钻到最内层 if 分支
		ib = innermostIf(ib)
		nodeTmp := &Node{Value: e, Father: p.ThisBlock}
		ib.Else = true
		ib.ElseBlock = nodeTmp
		p.ThisBlock = nodeTmp
	} else {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "else before if")
	}
}
