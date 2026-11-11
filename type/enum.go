// EnumType 表示枚举类型——声明的类型别名（如 Color）底层绑定底层的基础类型。
package typeSys

// EnumMember 一个枚举成员（名字 + 底层常量值 + 所属枚举类型）。
type EnumMember struct {
	Name  string
	Value any
	Type  *EnumType
}

// EnumType 枚举类型别名。
//
//   底层类型沿用 int/string 等基础类型的 Kind/Size；枚举是“新类型”
//     （与 type Color int 语义一致）：Kind() 委托给底层，使整数/字符串
//     比较、IsNum、AutoType 等规则直接按底层生效。
//   Fields() 返回登记的成员（作为伪 struct field），供 enterTypeFind 走“
//     类型命名空间 → 成员名”路径解析（Color.RED 可解出 RED 常量）。
type EnumType struct {
	RType
	Underlying  Type
	IsTrueAlias bool
	MemberConsts []*EnumMember
}

// Kind 返回底层类型的种类（int/uint/float/bool/string），
// 让枚举与同底层的基础类型在类型检查里等价（type Color int 语义）。
func (e *EnumType) Kind() string {
	return e.Underlying.Kind()
}

func (e *EnumType) Size() int        { return e.Underlying.Size() }
func (e *EnumType) Alignment() int   { return e.Underlying.Alignment() }
func (e *EnumType) Elem() Type       { return e.Underlying.Elem() }
func (e *EnumType) String() string   { return e.TypeName }
func (e *EnumType) Methods() []any   { return e.RType.Methods() }

// Fields 返回所有成员作为伪 struct 字段（供字段/下标路径解析）。
// 字段的 Offset 用成员在声明顺序里的索引约定标记（不用于真实内存布局）。
func (e *EnumType) Fields() StructFileds {
	out := make(StructFileds, 0, len(e.MemberConsts))
	for i, m := range e.MemberConsts {
		out = append(out, &StructField{
			Name:   m.Name,
			Type:   e,
			Offset: i * 8,
			Access: AccessPublic,
		})
	}
	return out
}

// IsMember 判断 name 是否为本枚举登记的成员名。
func (e *EnumType) IsMember(name string) bool {
	for _, m := range e.MemberConsts {
		if m.Name == name {
			return true
		}
	}
	return false
}

// Member 取给定名字的成员（找不到返回 nil）。
func (e *EnumType) Member(name string) *EnumMember {
	for _, m := range e.MemberConsts {
		if m.Name == name {
			return m
		}
	}
	return nil
}

// NewEnumType 创建枚举类型（非真别名：type Color int 语义）。
func NewEnumType(name string, underlying Type) *EnumType {
	if underlying == nil {
		panic("underlying type is nil")
	}
	return &EnumType{
		RType:      RType{TypeName: name},
		Underlying: underlying,
	}
}
