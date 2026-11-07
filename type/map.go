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

// Size map 值语义是单个 header 指针（std:maps 的 mapHdr*）。
// 早期按 ptr+len+cap 三槽预留是未落地的设想；WAVE Mp 起 pkg/maps
// 以单指针作为唯一句柄，这里必须与运行期表示一致，否则 map 值
// 作为参数/局部变量会整体错位。
func (m *MapType) Size() int {
	return TargetPointerSize
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
