package typeSys

// AliasType 表示一个类型别名
// IsTrueAlias = true:  type A = B  (真别名，与原类型完全等价)
// IsTrueAlias = false: type A B    (新类型，B为底层类型)
type AliasType struct {
	RType
	Underlying  Type
	IsTrueAlias bool
}

func (a *AliasType) Kind() string {
	return a.Underlying.Kind()
}

func (a *AliasType) Size() int {
	return a.Underlying.Size()
}

func (a *AliasType) Alignment() int {
	return a.Underlying.Alignment()
}

func (a *AliasType) Elem() Type {
	return a.Underlying.Elem()
}

func (a *AliasType) Fields() StructFileds {
	return a.Underlying.Fields()
}

func (a *AliasType) String() string {
	return a.TypeName
}

func (a *AliasType) Methods() []any {
	if a.IsTrueAlias {
		return a.Underlying.Methods()
	}
	// 新类型：合并自身方法和底层类型方法
	methods := a.RType.Methods()
	underlyingMethods := a.Underlying.Methods()
	return append(methods, underlyingMethods...)
}

// Unwrap 返回用于类型检查的实际类型
// 真别名返回底层类型，新类型返回自身
func (a *AliasType) Unwrap() Type {
	if a.IsTrueAlias {
		return a.Underlying
	}
	return a
}

// NewAlias 创建一个新的别名类型
func NewAlias(name string, underlying Type, isTrueAlias bool) *AliasType {
	if underlying == nil {
		panic("underlying type is nil")
	}
	return &AliasType{
		RType:       RType{TypeName: name},
		Underlying:  underlying,
		IsTrueAlias: isTrueAlias,
	}
}
