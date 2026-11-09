// grouped 声明（var / const / let / type）与裸 interface 语法。
//
// Go 风格分组：
//
//	var (           // var/const/let/type 关键字后跟 `( ... )`
//	    x = 5       // 推断类型（x 未先定义时按定义处理）
//	    y: int = 6  // 同普通声明
//	    typeAlias int
//	    P struct { a: int }
//	    I interface { m() int }
//	    A = int     // 真别名
//	    B int       // 定义新类型
//	)
//
// 裸接口形式 `interface I { ... }` 与 `type I interface { ... }` 等价。
package parser

import (
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
	typeSys "cuteify/type"
)

// parseTypeEntry 解析 type 分组的一条条目。条目形状：
//   - `interface I { ... }`  → 等价于 `type I interface { ... }`
//   - `Name [=] struct/interface/R type` 等 → 与顶层 type 声明一致
func (p *Parser) parseTypeEntry(token lexer.Token) *TypeBlock {
	// `interface I { ... }` 条目
	if token.Type == lexer.TYPE && token.Value == "interface" {
		nameToken := p.Lexer.Next()
		if nameToken.Type != lexer.NAME {
			p.Error.MissError("Syntax Error", nameToken.Cursor, "need interface name")
		}
		return p.newInterfaceBlock(token.Cursor, nameToken)
	}
	// 名称开头的普通条目（`P struct { ... }` / `I interface { ... }` / `A int` / `A = int`）
	if token.Type != lexer.NAME && !(token.Type == lexer.TYPE && token.Value == "struct") {
		p.Error.MissError("Syntax Error", token.Cursor, "need type name in type group")
	}
	p.Lexer.SetCursor(token.Cursor)
	block := &TypeBlock{}
	block.Parse(p)
	return block
}

// newInterfaceBlock 构造一个裸接口声明 `interface Name { ... }` 的节点。
// 与 `type Name interface { ... }` 走同一条 TypeBlock 注册路径。
// kwCursor 为 `interface` 关键字的起始位置。
func (p *Parser) newInterfaceBlock(kwCursor int, nameToken lexer.Token) *TypeBlock {
	block := &TypeBlock{Kind: TypeInterface, Interface: &InterfaceDef{}}
	block.StartCursor = kwCursor
	block.Name = NewName(nameToken.Value)
	p.CurTypeParams = nil
	savedName := p.CurStructName
	savedType := p.CurStructType
	p.CurStructName = nameToken.Value
	p.CurStructType = &typeSys.RType{TypeName: nameToken.Value}
	block.Interface.Parse(p)
	p.CurStructName = savedName
	p.CurStructType = savedType
	block.EndCursor = block.Interface.EndCursor
	if p.Package != nil && p.Package.Path != "" {
		packageFmt.RegisterType(p.Package.Path, block.Name.String(), block.Type())
	}
	return block
}

// parseGroupedDecl 解析 var/const/let/type 的分组形式。
// 调用时游标位于 `(` 之后。每个条目独立解析、独立 addDeclNode。
// kind 取 "VAR" / "CONST" / "LET" / "TYPE"。
func (p *Parser) parseGroupedDecl(kind string) {
	label := groupKindLabel(kind)
	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need ')' in "+label+" group")
		}
		if token.Type == lexer.SEPARATOR {
			switch token.Value {
			case ")":
				return
			case "\n", "\r", ";":
				continue
			default:
				p.Error.MissError("Syntax Error", token.Cursor, "unexpected '"+token.Value+"' in "+label+" group")
			}
		}
		if kind == "TYPE" {
			if p.ThisBlock != p.Block {
				p.Error.MissError("Syntax Error", token.Cursor, "type declaration is only allowed at top level")
			}
			entry := p.parseTypeEntry(token)
			p.addDeclNode(&Node{Value: entry})
			continue
		}
		p.Lexer.SetCursor(token.Cursor)
		entry := &VarBlock{}
		entry.ParseGroupedVar(p, kind)
		p.addDeclNode(&Node{Value: entry})
	}
}

func groupKindLabel(kind string) string {
	switch kind {
	case "TYPE":
		return "type"
	default:
		return "var"
	}
}
