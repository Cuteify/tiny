package typeSys

// MapType map[K]V 类型
type MapType struct {
	RType
	key   Type
	value Type
}

func NewMapType(key, value Type) *MapType {
	return &MapType{key: key, value: value}
}

func (m *MapType) Size() int {
	if TargetPointerSize == 8 {
		return 24 // ptr + len + cap (8 × 3)
	}
	return 12 // ptr + len + cap (4 × 3)
}

func (m *MapType) Alignment() int {
	return TargetPointerSize
}

func (m *MapType) String() string {
	return "map[" + m.key.String() + "]" + m.value.String()
}

func (m *MapType) Kind() string {
	return "map"
}

func (m *MapType) Elem() Type {
	return m.value
}

func (m *MapType) Key() Type {
	return m.key
}
