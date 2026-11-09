// 结构体字面量 P{field: expr, ...}
//
// 语义：按字段声明顺序把实参传给 new(P, ...)（栈内结构体槽 + 零值）。
// 与 Go 的组合字面量不同，P{} 在本编译器里总是堆对象：直接 lowering 成
// 内建 new 调用，再由 GC 逃逸分析决定释放点。
//
// 实现限制（v1）：
//   - 字段按名称匹配，声明顺序无关；
//   - 未提供的字段按零值填充；
//   - 匿名嵌入字段不支持字面量初始化（需要逐字段路径）。
package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
)

// parseStructLiteral 尝试把 P{field: expr, ...} 解析为等价的 new(P, ...) 调用。
// 若 name 不是已知结构体类型，返回 nil（调用者回退到普通变量引用/表达式）。
func (p *Parser) parseStructLiteral(name Name) *Expression {
	st := lookupStructTypeByName(p, name)
	if st == nil {
		return nil
	}

	saved := p.Lexer.Cursor
	open := p.Lexer.Next()
	if open.Type != lexer.SEPARATOR || open.Value != "{" {
		p.Lexer.SetCursor(saved)
		return nil
	}

	// 字段名 → 值表达式
	pairs := map[string]*Expression{}
	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Struct Error", p.Lexer.Cursor, "unexpected EOF in struct literal")
		}
		if token.Type == lexer.SEPARATOR {
			switch token.Value {
			case "}":
				goto done
			case "\n", "\r", ";", ",":
				continue
			default:
				p.Error.MissError("Struct Error", token.Cursor, "expected field name in struct literal, got '"+token.Value+"'")
			}
		}
		if token.Type != lexer.NAME {
			p.Error.MissError("Struct Error", token.Cursor, "expected field name in struct literal")
		}
		fieldName := token.Value
		colon := p.Lexer.Next()
		if colon.Type != lexer.SEPARATOR || colon.Value != ":" {
			p.Error.MissError("Struct Error", colon.Cursor, "expected ':' after field name '"+fieldName+"' in struct literal")
		}
		value := parseFieldValue(p)
		if value == nil {
			p.Error.MissError("Struct Error", colon.Cursor, "invalid value for field '"+fieldName+"' in struct literal")
		}
		pairs[fieldName] = value
	}
done:

	// 按字段声明顺序组装 new 调用实参
	callBlock := &CallBlock{Name: NewName("new"), NewType: st}
	for i := range st.StructFields {
		f := st.StructFields[i]
		if f.IsAnon {
			p.Error.MissError("Struct Error", p.Lexer.Cursor, "anonymous embedded field '"+f.ParentName+"' cannot be initialized in struct literal")
		}
		v, ok := pairs[f.Name]
		if !ok {
			continue // 零值字段：new(P) 已经零填充过
		}
		arg := &ArgBlock{Value: v, Name: NewName(f.Name), Type: v.Type}
		callBlock.Args = append(callBlock.Args, arg)
	}

	// 未知字段名报错
	for name := range pairs {
		found := false
		for i := range st.StructFields {
			if st.StructFields[i].Name == name {
				found = true
				break
			}
		}
		if !found {
			p.Error.MissError("Struct Error", p.Lexer.Cursor, "unknown field '"+name+"' in struct literal")
		}
	}

	_ = callBlock
	_ = pairs
	exp := &Expression{Call: callBlock, Type: typeSys.MakePointer(st)}
	return exp
}

// lookupStructTypeByName 从全局类型注册表/作用域查找结构体类型。
// 与 Find 不同，这里不要求进入作用域树（字面量通常在函数体内使用）。
func lookupStructTypeByName(p *Parser, name Name) *typeSys.StructType {
	if name.Length() != 1 {
		return nil
	}
	nameStr := name.String()
	results := p.Find(NewName(nameStr), FindTypeType)
	for _, r := range results {
		if r.Value == nil {
			continue
		}
		switch t := r.Value.(type) {
		case *typeSys.StructType:
			return t
		default:
			// TypeBlock 以 (*TypeBlock) 注册时，走 Type()
			if tb, ok := r.Value.(*TypeBlock); ok {
				if st, ok := tb.Type().(*typeSys.StructType); ok {
					return st
				}
			}
		}
	}
	return nil
}

// parseFieldValue 解析字段值，遇到顶层 ',' 或 '}' 停止。
// startCursor 必须位于值的第一个 token。
func parseFieldValue(p *Parser) *Expression {
	c := p.Lexer.Cursor
	stop := findValueStop(p)
	if stop <= c {
		return nil
	}
	p.Lexer.SetCursor(c)
	return p.ParseExp(stop)
}

// findValueStop 扫描顶层 ',' 或 '}'（深度优先于嵌套的括号/花括号/列表/map/string）。
// 返回停止符的光标位置（即值的结束位置）。
func findValueStop(p *Parser) int {
	depth := 0
	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			return p.Lexer.Cursor
		}
		switch token.Value {
		case "(", "[", "{":
			depth++
		case ")", "]", "}":
			if depth == 0 {
				return token.Cursor
			}
			depth--
		case ",", "\n", "\r", ";":
			if depth == 0 {
				return token.Cursor
			}
		}
	}
}
