package typeSys

// BackendType 后端类型标签
// 后端编译器通过这个标签决定：
// - 值的大小（字节数）
// - 使用什么指令（整数/浮点/向量）
// - 需要什么寄存器类别
type BackendType uint8

const (
	BTUnknown BackendType = iota
	BTInt8                // 8位整数
	BTInt16               // 16位整数
	BTInt32               // 32位整数
	BTInt64               // 64位整数
	BTUint8               // 8位无符号
	BTUint16              // 16位无符号
	BTUint32              // 32位无符号
	BTUint64              // 64位无符号
	BTFloat32             // 32位浮点
	BTFloat64             // 64位浮点
	BTBool                // 布尔
	BTPointer             // 指针（大小等于架构指针大小）
	BTString              // 字符串（ptr + len + cap）
	BTList                // 列表（ptr + len + cap，元素信息另存）
	BTStruct              // 结构体（大小由架构计算）
)

var btMap = map[string]BackendType{
	"int8": BTInt8, "int16": BTInt16, "int32": BTInt32, "int64": BTInt64,
	"uint8": BTUint8, "uint16": BTUint16, "uint32": BTUint32, "uint64": BTUint64,
	"f32": BTFloat32, "f64": BTFloat64,
	"bool": BTBool, "string": BTString,
}

func NewBackendType(t Type) BackendType {
	if _, ok := t.(*StructType); ok {
		return BTStruct
	}
	if _, ok := t.(*ListType); ok {
		return BTList
	}

	typeName := t.Type()
	return btMap[typeName]
}

// Size 获取后端类型的大小（字节数）
func (bt BackendType) Size() int {
	switch bt {
	case BTInt8, BTUint8, BTBool:
		return 1
	case BTInt16, BTUint16:
		return 2
	case BTInt32, BTUint32, BTFloat32:
		return 4
	case BTInt64, BTUint64, BTFloat64:
		return 8
	case BTPointer:
		return TargetPointerSize
	case BTString, BTList:
		return TargetPointerSize * 3 // ptr + len + cap
	default:
		return -1
	}
}

// IsInteger 是否为整数类型
func (bt BackendType) IsInteger() bool {
	return bt >= BTInt8 && bt <= BTUint64
}

// IsFloat 是否为浮点类型
func (bt BackendType) IsFloat() bool {
	return bt == BTFloat32 || bt == BTFloat64
}

// IsNumeric 是否为数值类型
func (bt BackendType) IsNumeric() bool {
	return bt.IsInteger() || bt.IsFloat()
}

// IsComposite 是否为复合类型（需要多个字段）
func (bt BackendType) IsComposite() bool {
	return bt == BTString || bt == BTList || bt == BTStruct
}
