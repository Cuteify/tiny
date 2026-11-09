// 泛型结构体（Box[T]）：声明解析、模板登记、按实参实例化。
//
// 形态：struct Box[T] { value: T }
//   - StructBlock.Parse 读取 `[T, U]` 类型参数，标记 StructType.TypeParams（模板）；
//   - 类型引用点（parseTypeAnnotation / parseTypeRef）解析到模板 StructType 时，
//     若紧跟 `[` 则按实参实例化出具体 StructType，否则报 "generic type ... requires type arguments"；
//   - 具体实例按 (模板名, 实参类型列表) 缓存，多次引用同一实例。
//
// 模板实例字段里的 TypeParam 占位符由 SubstituteTypeParams 替换；实例即
// 普通 StructType（TypeParams==nil），所有既有字段访问/布局/代码生成路径直接生效。
package parser

import (
	"strconv"
	"strings"

	"cuteify/lexer"
	typeSys "cuteify/type"
)

// genericStructInstances 泛型结构体实例缓存：key = 模板名 + "#" + 实参类型名列表。
var genericStructInstances = map[string]*typeSys.StructType{}

// parseGenericArgList 解析通用类型实参列表 `[T, U, ...]`。
// 前置游标位于 '['；返回后游标位于 ']' 之后。实参非法时直接报错。
func (p *Parser) parseGenericArgList() []typeSys.Type {
	p.Lexer.Skip('[')
	var args []typeSys.Type
	for {
		t := p.parseTypeRef()
		if t == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor,
				"expected type in generic type arguments")
			return nil
		}
		args = append(args, t)
		peek := p.Lexer.Next()
		if peek.Type == lexer.SEPARATOR && peek.Value == "," {
			continue
		}
		p.Lexer.SetCursor(peek.Cursor)
		break
	}
	p.Lexer.Skip(']')
	return args
}

// genericTypeName 把类型名清洗成 NASM 安全的实例名（Box__int 风格）。
func genericTypeName(base string, args []typeSys.Type) string {
	var sb strings.Builder
	sb.WriteString(base)
	for _, a := range args {
		sb.WriteString("__")
		if a == nil {
			sb.WriteString("any")
			continue
		}
		name := a.Type()
		for _, r := range name {
			switch {
			case r >= 'a' && r <= 'z', r >= 'A' && r <= 'Z', r >= '0' && r <= '9', r == '_':
				sb.WriteRune(r)
			default:
				sb.WriteByte('_')
			}
		}
	}
	return sb.String()
}

// genericStructKey 实例缓存键。
func genericStructKey(name string, args []typeSys.Type) string {
	parts := make([]string, 0, len(args))
	for _, a := range args {
		if a == nil {
			parts = append(parts, "nil")
		} else {
			parts = append(parts, a.Type())
		}
	}
	return name + "#" + strings.Join(parts, ",")
}

// instantiateGenericStruct 把模板 st 用 args 实例化（args 已从 [...] 解析出来）。
// 实参数与模板参数个数不匹配时报错；返回的实例已 Layout。
func instantiateGenericStruct(st *typeSys.StructType, args []typeSys.Type) *typeSys.StructType {
	if len(args) != len(st.TypeParams) {
		return nil
	}
	key := genericStructKey(st.TypeName, args)
	if cached, ok := genericStructInstances[key]; ok {
		return cached
	}
	subst := map[string]typeSys.Type{}
	for i, name := range st.TypeParams {
		subst[name] = args[i]
	}
	inst := &typeSys.StructType{
		Align: st.Align,
	}
	inst.RType.TypeName = genericTypeName(st.TypeName, args)
	for _, f := range st.StructFields {
		ft := typeSys.SubstituteTypeParams(f.Type, subst)
		nf := &typeSys.StructField{
			Name:       f.Name,
			Type:       ft,
			Default:    f.Default,
			Tags:       f.Tags,
			Access:     f.Access,
			Alias:      f.Alias,
			ParentName: f.ParentName,
			IsAnon:     f.IsAnon,
		}
		inst.StructFields = append(inst.StructFields, nf)
	}
	inst.Layout()
	genericStructInstances[key] = inst
	return inst
}

// maybeInstantiateGenericStruct 在游标位于模板名之后（通常停在 '[' 上）时：
//   - 若 st 不是泛型模板（TypeParams 为空），原样返回；
//   - 若紧跟 '['，按实参实例化并返回具体 StructType；
//   - 若 st 是模板但没写实参，报 "requires type arguments" 并返回 nil；
//   - 若 st 是模板且写了实参，实参非法时返回 nil。
// 游标位于 '[' 或其前一位置均可（函数内部前瞻）。
func (p *Parser) maybeInstantiateGenericStruct(st *typeSys.StructType) typeSys.Type {
	if st == nil || len(st.TypeParams) == 0 {
		return st
	}
	// 前瞻 '['：游标可能停在 '[' 上，也可能停在名字之后一位。
	saved := p.Lexer.Cursor
	token := p.Lexer.Next()
	if token.Type == lexer.SEPARATOR && token.Value == "[" {
		p.Lexer.SetCursor(token.Cursor)
		args := p.parseGenericArgList()
		if args == nil {
			return nil
		}
		inst := instantiateGenericStruct(st, args)
		if inst == nil {
			p.Error.MissError("Type Error", p.Lexer.Cursor,
				"generic struct '"+st.TypeName+"' expects "+strconv.Itoa(len(st.TypeParams))+" type arguments, got "+strconv.Itoa(len(args)))
			return nil
		}
		return inst
	}
	// 没有实参：模板不能裸用
	p.Lexer.SetCursor(saved)
	p.Error.MissError("Type Error", p.Lexer.Cursor,
		"generic struct '"+st.TypeName+"' requires type arguments")
	return nil
}

// structOfType 把类型解包成 *StructType（不是结构体则返回 nil）。
func structOfType(t typeSys.Type) *typeSys.StructType {
	if t == nil {
		return nil
	}
	if st, ok := t.(*typeSys.StructType); ok {
		return st
	}
	// 真别名解包
	if ba, ok := t.(*typeSys.AliasType); ok && ba.IsTrueAlias {
		if st, ok := ba.Unwrap().(*typeSys.StructType); ok {
			return st
		}
	}
	return nil
}

// lookupGenericStructTemplate 按名字查找泛型结构体模板（跨包/跨文件可见）。
// 没有时返回 nil。
func lookupGenericStructTemplate(p *Parser, name string) *typeSys.StructType {
	results := p.Find(NewName(name), FindTypeType)
	for _, r := range results {
		if tb, ok := r.Value.(*TypeBlock); ok {
			if st, ok2 := tb.Type().(*typeSys.StructType); ok2 && len(st.TypeParams) > 0 {
				return st
			}
		}
		if st, ok := r.Value.(typeSys.Type); ok {
			if st, ok2 := st.(*typeSys.StructType); ok2 && len(st.TypeParams) > 0 {
				return st
			}
		}
	}
	return nil
}
