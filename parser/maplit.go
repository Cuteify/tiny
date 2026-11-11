// map 字面量 map[K]V{k: v, ...}：指令颗粒上构造 maps.new 调用
// + 逐对 maps.set 插入（与嵌套通用泛型一样在同包编译内建完成）。
package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
)

// MapEntry 一个 map 字面量元素（键值对）。
type MapEntry struct {
	Key   *Expression
	Value *Expression
}

// isMapLitAhead 光标已指向 NAME("map") 之后的 '['——确认后面是 `]` → `类型` → `{`。
// 调用方负责回退游标。
func (p *Parser) isMapLitAhead() bool {
	saved := p.Lexer.Cursor
	defer p.Lexer.SetCursor(saved)
	token := p.Lexer.Next()
	if token.Type != lexer.SEPARATOR || token.Value != "[" {
		return false
	}
	// 跳过键类型——map 类型注解允许多 token（[]int、*P 等）
	depth := 1
	for depth > 0 {
		t := p.Lexer.Next()
		if t.IsEmpty() {
			return false
		}
		if t.Type != lexer.SEPARATOR {
			continue
		}
		switch t.Value {
		case "[":
			depth++
		case "]":
			depth--
		}
	}
	// 值类型必须以 NAME/'*'/'[' 起头，以 '{' 结束——否则不是 map 字面量
	depth = 0
	for {
		t := p.Lexer.Next()
		if t.IsEmpty() {
			return false
		}
		if t.Type == lexer.SEPARATOR {
			switch t.Value {
			case "[":
				depth++
				continue
			case "]":
				depth--
				continue
			case "*", ",", " ", "\t":
				continue
			case "{":
				if depth == 0 {
					return true
				}
				return false
			}
			return false
		}
		if t.Type == lexer.NAME || t.Type == lexer.NUMBER {
			continue
		}
		return false
	}
}

// handleMapLit 解析 map[K]V{k: v, ...} 字面量。调用前读完 "map" 名字，
// 光标位于第一个 '['。
func (p *Parser) handleMapLit() *Expression {
	saved := p.Lexer.Cursor

	p.Lexer.SetCursor(saved)
	p.Lexer.Skip('[')
	keyType := p.parseTypeRef()
	if keyType == nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "expected map key type")
		return nil
	}
	if tok := p.Lexer.Next(); tok.Type != lexer.SEPARATOR || tok.Value != "]" {
		p.Error.MissError("Syntax Error", tok.Cursor, "expected ']' after map key type")
		return nil
	}
	valType := p.parseTypeRef()
	if valType == nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "expected map value type")
		return nil
	}
	open := p.Lexer.Next()
	if open.Type != lexer.SEPARATOR || open.Value != "{" {
		p.Error.MissError("Syntax Error", open.Cursor, "expected '{' to start map literal")
		return nil
	}

	var elems []MapEntry
	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "unexpected EOF in map literal")
		}
		if token.Type == lexer.SEPARATOR && token.Value == "}" {
			break
		}
		if isEnumSeparator(token) {
			continue
		}
		// 回跳到元素起始并解析“键 : 值”对
		p.Lexer.SetCursor(token.Cursor)

		// 先定位本对内的顶层 ':'（键与值之间的分隔符）。
		colonCursor := p.topLevelToken(":", "}", ",", "\n", "\r", ";")
		if colonCursor < 0 {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "expected ':' in map entry")
			return nil
		}
		keyExp := p.ParseExp(colonCursor)
		if keyExp == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "expected key in map entry")
			return nil
		}
		colon := p.Lexer.Next() // 跳过 ':'
		_ = colon
		valueCursor := p.Lexer.Cursor
		valueStop := findValueStop(p)
		p.Lexer.SetCursor(valueCursor)
		if valueStop <= valueCursor {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "expected value after ':'")
			return nil
		}
		valueExp := p.ParseExp(valueStop)
		if valueExp == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "expected value in map entry")
			return nil
		}
		elems = append(elems, MapEntry{Key: keyExp, Value: valueExp})

		sep := p.Lexer.Next()
		if sep.Type == lexer.SEPARATOR && sep.Value == "}" {
			// '}' 已被消费，结束键值对列表
			break
		}
		if sep.Type == lexer.SEPARATOR && (sep.Value == "," || sep.Value == "\n" || sep.Value == "\r" || sep.Value == ";") {
			continue
		}
		p.Error.MissError("Syntax Error", sep.Cursor, "expected ',' or '}' in map literal")
		return nil
	}

	return &Expression{
		Separator: "map_lit",
		MapElems:  elems,
		Type:      typeSys.NewMapType(keyType, valType),
	}
}

// topLevelToken 从当前光标前进扫描，返回目标 token（深度 0 内）的光标；
// 遇到 stop token 或 EOF 返回 -1。嵌套 []、{}、() 深度 > 0 时不视为顶层。
func (p *Parser) topLevelToken(target string, stops ...string) int {
	depth := 0
	sav := p.Lexer.Cursor
	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			return -1
		}
		if token.Type != lexer.SEPARATOR {
			continue
		}
		switch token.Value {
		case "[", "{", "(":
			depth++
		case "]", "}", ")":
			depth--
			if depth < 0 {
				p.Lexer.SetCursor(sav)
				return -1
			}
		default:
			if depth == 0 {
				if token.Value == target {
					p.Lexer.SetCursor(sav)
					return token.Cursor
				}
				for _, s := range stops {
					if token.Value == s {
						p.Lexer.SetCursor(sav)
						return -1
					}
				}
			}
		}
	}
}
