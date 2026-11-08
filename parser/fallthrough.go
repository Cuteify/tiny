package parser

// FallthroughBlock fallthrough 语句节点。
// 只允许作为 switch case 的最后一条语句；代码生成时不做任何事，
// 由 compileSwitchBlock 根据 case 末尾是否有该节点决定跳到下一个 case。
type FallthroughBlock struct{}

// Parse 校验 fallthrough 直接位于 case 体内。
// “必须是最后一条语句”由 Node.AddChild 在后续语句加入 case 时检查。
func (f *FallthroughBlock) Parse(p *Parser) {
	if _, ok := p.ThisBlock.Value.(*CaseBlock); !ok {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "'fallthrough' outside of switch case")
	}
}
