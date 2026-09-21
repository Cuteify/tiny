package typeSys

// TypeParam 表示泛型函数中的类型参数（占位符）。
// 例如 func max[T](a T, b T) T 中的 T。
type TypeParam struct {
	RType
	Name string // 类型参数名（如 "T"、"K"、"V"）
}

func (tp *TypeParam) Type() string     { return tp.Name }
func (tp *TypeParam) String() string   { return tp.Name }
func (tp *TypeParam) Size() int        { return -1 } // 未实例化时无大小
func (tp *TypeParam) Kind() string     { return "typeparam" }
func (tp *TypeParam) Fields() StructFileds { return nil }
func (tp *TypeParam) Parent() Type     { return nil }
func (tp *TypeParam) IsPointer() bool  { return false }
func (tp *TypeParam) Alignment() int   { return 0 }
func (tp *TypeParam) Elem() Type       { return nil }
func (tp *TypeParam) Methods() []any   { return nil }

// NewTypeParam 创建类型参数
func NewTypeParam(name string) *TypeParam {
	return &TypeParam{
		Name: name,
	}
}

// SubstituteTypeParams 递归替换类型中的 TypeParam 占位符。
// 如果 t 是 TypeParam 且在 subst 中有对应映射，返回具体类型。
// 对指针、列表等复合类型递归替换其内部类型。
func SubstituteTypeParams(t Type, subst map[string]Type) Type {
	if t == nil {
		return nil
	}
	typeName := t.Type()
	if concrete, ok := subst[typeName]; ok {
		return concrete
	}
	if t.IsPointer() {
		elem := t.Elem()
		if elem != nil {
			newElem := SubstituteTypeParams(elem, subst)
			if newElem != elem {
				return MakePointer(newElem)
			}
		}
	}
	if lt, ok := t.(*ListType); ok {
		newElem := SubstituteTypeParams(lt.Elem(), subst)
		if newElem != lt.Elem() {
			return NewList(newElem)
		}
	}
	return t
}
