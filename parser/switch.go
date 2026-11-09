package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
)

// SwitchBlock switch 语句结构体
type SwitchBlock struct {
	Target *Expression  // switch 后面的表达式
	Cases  []*CaseBlock // case 分支的值列表（在 Parse 阶段填充，供编译器使用）
	Offset int          // 代码生成期分配的唯一编号（switch_<n> / break 定位）
}

// CaseBlock 存储单个 case 分支的信息（供编译器使用）
type CaseBlock struct {
	Values    []*Expression // case 后面的值列表（允许多值匹配）
	IsDefault bool          // 是否为 default 分支
	Switch    *SwitchBlock
}

// Parse 解析 switch 语句头部，进入作用域后返回（主循环继续解析 body）
func (s *SwitchBlock) Parse(p *Parser) {
	// switch { ... }：无目标条件 switch —— 每个 case 按布尔条件独立判断。
	if peek := p.Lexer.PeekToken(); peek.Type == lexer.SEPARATOR && peek.Value == "{" {
		s.Target = nil
		p.Lexer.Skip('{')
		n := &Node{Value: s}
		p.AddChild(n)
		p.ThisBlock = n
		return
	}
	// 获取条件表达式
	stopCursor := p.Has(lexer.Token{Type: lexer.SEPARATOR, Value: "{"}, p.FindEndCursor())
	s.Target = p.ParseExp(stopCursor - 1)

	// 跳过块开头符
	p.Lexer.Skip('{')

	// 插入AST并切换作用域
	n := &Node{Value: s}
	p.AddChild(n)
	p.ThisBlock = n
}

// Check 检查 switch 语句的有效性
func (s *SwitchBlock) Check(p *Parser) bool {
	if s.Target != nil {
		if !s.Target.Check(p) {
			return false
		}
	}

	hasDefault := false
	for i := 0; i < len(s.Cases); i++ {
		if s.Cases[i].IsDefault && hasDefault {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "'default' already exist.")
		}
		if s.Cases[i].IsDefault {
			hasDefault = true
		}
	}

	return true
}

func (c *CaseBlock) Parse(p *Parser) {
	// 获取条件值
	lastSep := p.Lexer.Cursor
	for p.Lexer.Cursor < p.Lexer.TextLength {
		t := p.Lexer.Next()
		if t.IsLineEnd() {
			return
		}

		// default 分支没有 case 值，只读到 ':' 即可；否则会把冒号
		// 前面的空区间交给 ParseExp，产生 nil 表达式。
		if c.IsDefault {
			if t.Value == ":" {
				break
			}
			continue
		}

		switch t.Value {
		case ":", ",":
			p.Lexer.SetCursor(lastSep)
			c.Values = append(c.Values, p.ParseExp(t.Cursor))
			p.Lexer.SetCursor(t.EndCursor)
			lastSep = t.EndCursor
		}

		if t.Value == ":" {
			break
		}
	}
	if sw, ok := p.ThisBlock.Value.(*SwitchBlock); ok {
		sw.Cases = append(sw.Cases, c)
		c.Switch = sw
		// 插入AST并切换作用域
		n := &Node{Value: c}
		p.AddChild(n)
		p.ThisBlock = n
	} else {
		if c.IsDefault {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "'default' outside of switch")
		} else {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "'case' outside of switch")
		}
	}

}

// Check 检查 case 语句的有效性
func (c *CaseBlock) Check(p *Parser) bool {
	// 无目标 switch：case 值是条件表达式，不做目标类型相等检查
	if c.Switch.Target == nil {
		for i := 0; i < len(c.Values); i++ {
			if !c.Values[i].Check(p) {
				return false
			}
		}
		return true
	}
	// 检查表达式
	for i := 0; i < len(c.Values); i++ {
		if !c.Values[i].Check(p) {
			return false
		}
		if c.Switch.Target != nil && c.Switch.Target.Type != nil && c.Values[i].Type != nil {
			if !typeSys.KindEqual(c.Switch.Target.Type, c.Values[i].Type) {
				return false
			}
		}
	}
	return true
}
