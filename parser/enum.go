// 枚举（enum）语法：
//
//   // 显式底层类型
//   enum Color: string {
//       Red   = "red"
//       Blue  = "blue"
//   }
//   enum Small {
//       A
//       B = 16
//   }
//
//   // 自动推断（首成员或全员为 string → string；否则默认 int）
//   enum TokenType {
//       Plus     = "+"
//       Minus    = "-"
//   }
//
// 支持：
//   - 可选 `: 底层类型`，底层类型必须是 int / uint / i8..u64 / byte / bool / string。
//   - 未写 `: 类型` 时按成员值类型推断：全部为字符串字面量 → string；
//     其余默认为 int（原支持整数枚举向后兼容）。
//   - `Color.Red` 限定访问：enum 当作命名空间；路径解析
//     （enterTypeFind）把 `Color` 识别为 enum 类型， `.Red` 走出口查找。
//   - switch 支持 enum 类型作 target 表达式 + enum 限定成员作 case 值（与
//     裸常量等价）。
package parser

import (
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
	typeSys "cuteify/type"
	"cuteify/utils"
)

// processEnumToken 解析 enum 声明：为枚举创建独立命名类型，并把每个成员
// 注册为同作用域内该类型的常量。枚举名注册为非真别名（type Name underlying
// 语义，成员类型就是枚举类型）；成员通过 enum 的 Methods()/Fields() 间接
// 支持 `Color.Red` 路径限定访问。
type memberKindEnum int
const (
	memberKindIntMember memberKindEnum = iota
	memberKindStringMember
	memberKindBoolMember
)

func (p *Parser) processEnumToken() {
	startCursor := p.Lexer.Cursor
	ignored := p.pendingDeclIgnored()

	nameToken := p.Lexer.Next()
	if nameToken.Type != lexer.NAME {
		p.Error.MissError("Syntax Error", nameToken.Cursor, "expected enum name")
	}
	enumName := nameToken.Value
	if !utils.CheckName(enumName) {
		p.Error.MissError("Syntax Error", nameToken.Cursor, "invalid enum name: '"+enumName+"'")
	}

	// enum Name [: TypeAnnotation] { ... }
	next := p.Lexer.Next()
	var underlying typeSys.Type
	explicitUnderlying := false
	if next.Type == lexer.SEPARATOR && next.Value == ":" {
		underlying = p.parseTypeAnnotation()
		if underlying == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "enum "+enumName+" needs a valid underlying type")
			return
		}
		underlying = trimEnumUnderlying(underlying)
		if underlying == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor,
				"enum "+enumName+" underlying type must be int/uint/i64/u64/string")
			return
		}
		explicitUnderlying = true
		next = p.Lexer.Next()
	}
	if next.Type != lexer.SEPARATOR || next.Value != "{" {
		p.Error.MissError("Syntax Error", next.Cursor, "need '{' after enum name")
	}

	type enumMember struct {
		name       string
		intValue   float64
		stringValue string
		boolValue  bool
		memberKind memberKindEnum
		cursor     int
	}
	var members []enumMember
	seen := map[string]bool{}
	kindCount := map[memberKindEnum]int{}
	tautoValue := 0.0

	for {
		token := p.Lexer.Next()
		if token.IsEmpty() {
			p.Error.MissError("Syntax Error", token.Cursor, "unexpected EOF in enum "+enumName)
		}
		if token.Type == lexer.SEPARATOR && token.Value == "}" {
			break
		}
		if isEnumSeparator(token) {
			continue
		}
		if token.Type != lexer.NAME {
			p.Error.MissError("Syntax Error", token.Cursor, "expected enum member name")
		}
		member := token.Value
		if !utils.CheckName(member) {
			p.Error.MissError("Syntax Error", token.Cursor, "invalid enum member name: '"+member+"'")
		}
		if seen[member] {
			p.Error.MissError("Syntax Error", token.Cursor, "duplicate enum member: "+member)
		}
		seen[member] = true

		m := enumMember{name: member, cursor: token.Cursor}
		peek := p.Lexer.PeekToken()
		if peek.Type == lexer.SEPARATOR && peek.Value == "=" {
			p.Lexer.Next()
			parsedValue, parsedKind := p.parseEnumValue(enumName, member)
			m.intValue = parsedValue.intValue
			m.stringValue = parsedValue.stringValue
			m.boolValue = parsedValue.boolValue
			m.memberKind = parsedKind
		} else {
			// 未显式值：仅允许整数成员（自增）；其余报错
			m.intValue = tautoValue
			m.memberKind = memberKindIntMember
			tautoValue++
		}
		members = append(members, m)
		kindCount[m.memberKind]++
		switch m.memberKind {
		case memberKindIntMember:
			// 显式值写入后沿用 C 语义恢复自增序列：BLUE = 10 → 后续未指定成员从 11 开始。
			tautoValue = m.intValue + 1
		}
	}

	// 没有任何成员值是合法的（{ }）仅当显式指定底层类型时才允许，否则默认 int 自动推断/默认空枚举
	if len(members) == 0 && !explicitUnderlying {
		underlying = typeSys.GetSystemType("int")
	}
	// 推断底层类型（未显式）
	if !explicitUnderlying {
		switch {
		case kindCount[memberKindStringMember] > 0 &&
			(kindCount[memberKindIntMember]+kindCount[memberKindBoolMember]) > 0:
			p.Error.MissError("Syntax Error", p.Lexer.Cursor,
				"enum "+enumName+" mixes string and integer members without an explicit underlying type")
			return
		case kindCount[memberKindStringMember] > 0:
			underlying = typeSys.GetSystemType("string")
		case kindCount[memberKindBoolMember] > 0 && kindCount[memberKindIntMember] == 0:
			underlying = typeSys.GetSystemType("bool")
		default:
			underlying = typeSys.GetSystemType("int")
		}
	} else {
		// 显式类型对成员值种类做匹配检查
		switch trimEnumUnderlying(underlying).Type() {
		case "string":
			if kindCount[memberKindIntMember]+kindCount[memberKindBoolMember] > 0 {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor,
					"enum "+enumName+" declared string but contains non-string members")
				return
			}
		case "bool":
			if kindCount[memberKindIntMember]+kindCount[memberKindStringMember] > 0 {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor,
					"enum "+enumName+" declared bool but contains non-bool members")
				return
			}
		default:
			if kindCount[memberKindStringMember] > 0 {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor,
					"enum "+enumName+" declared integer but contains string members")
				return
			}
		}
	}
	underlying = trimEnumUnderlying(underlying)

	// 整数枚举：超 int32 退到 i64；若显式 i64 设定，保留（不改）。
	if underlying.Type() == "int" {
		for _, m := range members {
			if m.memberKind == memberKindIntMember {
				v := m.intValue
				if v > 2147483647 || v < -2147483648 {
					underlying = typeSys.GetSystemType("i64")
					break
				}
			}
		}
	}

	// 构造 EnumType（能力通过 Methods/Fields 暴露，供 path 寻址解析 Color.RED）
	enumType := typeSys.NewEnumType(enumName, underlying)
	for _, m := range members {
		vr := &typeSys.EnumMember{Name: m.name, Type: enumType}
		switch m.memberKind {
		case memberKindIntMember:
			vr.Value = m.intValue
		case memberKindStringMember:
			vr.Value = m.stringValue
		case memberKindBoolMember:
			vr.Value = m.boolValue
		}
		enumType.MemberConsts = append(enumType.MemberConsts, vr)
	}
	typeBlock := &TypeBlock{
		Name:        NewName(enumName),
		Kind:        TypeAlias,
		Alias:       enumType,
		StartCursor: startCursor,
	}
	if p.Package != nil && p.Package.Path != "" && !ignored {
		packageFmt.RegisterType(p.Package.Path, enumName, typeBlock.Type())
	}
	p.addDeclNode(&Node{Value: typeBlock})

	for _, m := range members {
		block := &VarBlock{
			Name:          NewName(m.name),
			IsConst:       true,
			IsDefine:      true,
			IsInitialized: true,
			StartCursor:   m.cursor,
			Type:          enumType,
			Value: &Expression{
				Type: enumType,
			},
		}
		switch m.memberKind {
		case memberKindIntMember:
			block.Value.Num = m.intValue
		case memberKindStringMember:
			block.Value.StringVal = m.stringValue
		case memberKindBoolMember:
			block.Value.Bool = m.boolValue
		}
		block.IsGlobal = p.ThisBlock == p.Block
		if block.IsGlobal && p.Package != nil && p.Package.Path != "" && !ignored {
			packageFmt.RegisterGlobalVar(p.Package.Path, m.name, block)
		}
		p.ThisBlock.AddChild(&Node{Value: block, BuildIgnored: ignored})
	}
}

// trimEnumUnderlying 规整（真别名展开）并校验底层类型是否被支持。
func trimEnumUnderlying(t typeSys.Type) typeSys.Type {
	if t == nil {
		return nil
	}
	if a, ok := t.(*typeSys.AliasType); ok && a.IsTrueAlias {
		if u := a.Unwrap(); u != nil {
			t = u
		}
	}
	if !isEnumUnderlying(t) {
		return nil
	}
	return t
}

// isEnumUnderlying 合法的底层类型白名单。
// 只允许架构字长整数和 i64/u64 与 string：全局 const 的 .data 发射
// 只处理 4/8 字节槽，1/2 字节（i8/i16/u8/u16/byte/bool）的常量会漏发初值，
// 读出来永远是 0；bool 也不支持（避免枚举值被当成隐式 bool 转换）。
func isEnumUnderlying(t typeSys.Type) bool {
	if t == nil {
		return false
	}
	switch t.Type() {
	case "int", "uint", "i64", "u64", "string":
		return true
	}
	return false
}

// isEnumSeparator 枚举成员之间允许换行、逗号或分号分隔。
func isEnumSeparator(token lexer.Token) bool {
	if token.Type != lexer.SEPARATOR {
		return false
	}
	switch token.Value {
	case ",", ";", "\n", "\r":
		return true
	}
	return false
}

type enumValue struct {
	intValue    float64
	stringValue string
	boolValue   bool
}

// parseEnumValue 解析 `= <值>`。支持整数常量（含负号）/字符串字面量/true/false。
func (p *Parser) parseEnumValue(enumName, member string) (enumValue, memberKindEnum) {
	token := p.Lexer.Next()
	if token.Type == lexer.STRING || token.Type == lexer.RAW {
		return enumValue{stringValue: token.Value}, memberKindStringMember
	}
	if token.Type == lexer.BOOL {
		switch token.Value {
		case "true":
			return enumValue{boolValue: true}, memberKindBoolMember
		case "false":
			return enumValue{boolValue: false}, memberKindBoolMember
		}
	}
	// 数值常量（允许可选 - 前导）
	negative := false
	if token.Type == lexer.SEPARATOR && token.Value == "-" {
		negative = true
		token = p.Lexer.Next()
	}
	if token.Type != lexer.NUMBER {
		p.Error.MissError("Syntax Error", token.Cursor,
			"enum "+enumName+" member "+member+" needs a numeric / string / bool constant")
		return enumValue{}, 0
	}
	value, err := parseNumberLiteral(token.Value)
	if err != nil {
		p.Error.MissError("Syntax Error", token.Cursor,
			"invalid enum value for "+enumName+"."+member+": "+err.Error())
		return enumValue{}, memberKindIntMember
	}
	if value != float64(int64(value)) {
		p.Error.MissError("Syntax Error", token.Cursor,
			"enum "+enumName+" member "+member+" value must be an integer")
		return enumValue{}, memberKindIntMember
	}
	if negative {
		value = -value
	}
	return enumValue{intValue: value}, 0 /* memberKindIntMember */
}
