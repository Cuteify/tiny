package typeSys

import (
	"os"
	"strings"
	"unsafe"
)

var TargetPointerSize int = 4

func init() {
	if os.Getenv("CUTE_ARCH") == "x86_64" {
		TargetPointerSize = 8
	}
}

func SetTargetPointerSize(size int) {
	TargetPointerSize = size
}

type Type interface {
	// Type returns the type of the value.
	Type() string
	// String returns the string representation of the value.
	String() string
	// Value returns the value of the type.
	Fields() StructFileds
	// Size returns the RSize of the type.
	Size() int
	// RFather returns the RFather of the type.
	Parent() Type
	// IsPointer returns true if the type is a pointer.
	IsPointer() bool
	// Alignment returns the alignment of the type.
	Alignment() int
	// Kind returns the kind of the type.
	Kind() string
	// Elem returns the element type of the list or struct or pointer.
	// If the type is not a list, struct, or pointer, it returns nil.
	Elem() Type
	// Methods returns the methods of the type.
	// []any as []*FuncBlock.
	Methods() []any
	// IsOwning returns true if the type itself carries a heap pointer
	// (*T / list / string) and therefore needs reference management.
	IsOwning() bool
}

type StructFileds []*StructField

type RType struct {
	TypeName   string
	RSize      int
	RParent    Type
	IsPtr      bool
	RAlignment int
	_methods   []any
	_ptrElem   Type // 真实指针（IsPtr）的被指类型
}

func (r *RType) Kind() string {
	return getSystemKind(r)
}

// IsOwning 类型自己就带一个堆指针（*T / list / string）→ 需要引用管理。
//
// 不含接口与含 owning 字段的结构体值：那两类是"复制会把字段指针一起带走"
// （判据见 parser/gc_pred.go 的 copiesFields），语义不同 —— 一个是"我自己
// 有块"，一个是"我拖着别人的块"。
func (r *RType) IsOwning() bool {
	if r == nil {
		return false
	}
	if r.IsPtr {
		return true // *T：堆块的唯一入口
	}
	switch r.Kind() {
	case "list", "string":
		return true
	}
	return false
}

func (r RType) Alignment() int {
	if r.RAlignment == 0 {
		switch r.TypeName {
		case "int", "uint":
			return TargetPointerSize
		case "ptr":
			return TargetPointerSize
		case "string":
			return TargetPointerSize
		default:
			return r.RSize
		}
	}
	return r.RAlignment
}

func (r *RType) Parent() Type {
	return r.RParent
}

func (r *RType) IsPointer() bool {
	return r.IsPtr
}

func (r RType) Type() string {
	return r.TypeName
}

func (r RType) Size() int {
	if r.RSize == 0 {
		if r.IsPtr {
			// 指针类型大小 = 目标指针大小，而非元素大小
			if TargetPointerSize == 8 {
				r.RSize = 8
			} else {
				r.RSize = 4
			}
			return r.RSize
		}
		switch r.TypeName {
		case "int", "uint":
			if TargetPointerSize == 8 {
				r.RSize = 8
			} else {
				r.RSize = 4
			}
		case "i64", "u64", "f64":
			r.RSize = 8
		case "i32", "u32", "f32":
			r.RSize = 4
		case "i16", "u16":
			r.RSize = 2
		case "i8", "u8", "bool", "byte":
			r.RSize = 1
		case "ptr":
			if TargetPointerSize == 8 {
				r.RSize = 8
			} else {
				r.RSize = 4
			}
		case "string":
			if TargetPointerSize == 8 {
				r.RSize = 24
			} else {
				r.RSize = 12
			}
		}
	}
	return r.RSize
}

func (r *RType) Elem() Type {
	if r.IsPtr {
		return r._ptrElem
	}
	return nil
}

func (r RType) String() string {
	return r.TypeName
}

func (r *RType) Fields() StructFileds {
	return nil
}

func (r *RType) Methods() []any {
	return r._methods
}

func (r *RType) AddMethod(m any) {
	r._methods = append(r._methods, m)
}

type (
	IntType struct {
		RType
	}
	UintType struct {
		RType
	}
	Int64Type struct {
		RType
	}
	Uint64Type struct {
		RType
	}
	Int32Type struct {
		RType
	}
	Uint32Type struct {
		RType
	}
	Int16Type struct {
		RType
	}
	Uint16Type struct {
		RType
	}
	Int8Type struct {
		RType
	}
	Uint8Type struct {
		RType
	}
	BoolType struct {
		RType
	}
	ByteType struct {
		RType
	}
	Float32Type struct {
		RType
	}
	Float64Type struct {
		RType
	}
	PtrType struct {
		RType
	}
	StringType struct {
		RType
	}
)

// InterfaceMethodDef interface method signature definition
type InterfaceMethodDef struct {
	Name    string
	Args    []Type
	Returns []Type
}

// InterfaceType interface type (boxed value: {vtable_ptr, data_ptr})
type InterfaceType struct {
	RType
	InterfaceMethods []InterfaceMethodDef
}

// Size returns the size of an interface value: 2 * pointerSize
func (i *InterfaceType) Size() int {
	return 2 * TargetPointerSize
}

// Methods returns the interface methods as []any (satisfies Type interface).
func (i *InterfaceType) Methods() []any {
	out := make([]any, len(i.InterfaceMethods))
	for j := range i.InterfaceMethods {
		out[j] = &i.InterfaceMethods[j]
	}
	return out
}

// ImplementsInterface checks if the given concrete type implements this interface.
// A concrete type implements the interface if it has all methods with matching signatures.
func (i *InterfaceType) ImplementsInterface(concreteType Type) bool {
	if concreteType == nil {
		return false
	}
	for _, ifaceMethod := range i.InterfaceMethods {
		found := false
		for _, cm := range concreteType.Methods() {
			var methodName string
			switch m := cm.(type) {
			case *InterfaceMethodDef:
				methodName = m.Name
			case interface{ GetNameString() string }:
				methodName = m.GetNameString()
			case interface{ Name() string }:
				methodName = m.Name()
			case interface{ String() string }:
				methodName = m.String()
			}
			if methodName == ifaceMethod.Name {
				found = true
				break
			}
			// Handle qualified names like "Dog.stringify" → match "stringify"
			if dotIdx := strings.LastIndex(methodName, "."); dotIdx >= 0 {
				if methodName[dotIdx+1:] == ifaceMethod.Name {
					found = true
					break
				}
			}
		}
		if !found {
			return false
		}
	}
	return true
}

// ErrorInterface is the built-in error interface: { Error() string }
// Any type with an Error() string method implements this interface.
type ErrorInterface struct {
	InterfaceType
}

// NewErrorInterface creates the built-in error interface type
func NewErrorInterface() *ErrorInterface {
	return &ErrorInterface{
		InterfaceType: InterfaceType{
			RType: RType{TypeName: "error"},
			InterfaceMethods: []InterfaceMethodDef{
				{Name: "Error", Args: []Type{}, Returns: []Type{&StringType{RType: RType{TypeName: "string"}}}},
			},
		},
	}
}

func GetSystemType(name string) Type {
	name = strings.ToLower(name)
	switch name {
	case "int":
		return &IntType{RType: RType{TypeName: "int"}}
	case "uint":
		return &UintType{RType: RType{TypeName: "uint"}}
	case "i64":
		return &Int64Type{RType: RType{TypeName: "i64"}}
	case "u64":
		return &Uint64Type{RType: RType{TypeName: "u64"}}
	case "i32":
		return &Int32Type{RType: RType{TypeName: "i32"}}
	case "u32":
		return &Uint32Type{RType: RType{TypeName: "u32"}}
	case "i16":
		return &Int16Type{RType: RType{TypeName: "i16"}}
	case "u16":
		return &Uint16Type{RType: RType{TypeName: "u16"}}
	case "i8":
		return &Int8Type{RType: RType{TypeName: "i8"}}
	case "u8":
		return &Uint8Type{RType: RType{TypeName: "u8"}}
	case "bool":
		return &BoolType{RType: RType{TypeName: "bool"}}
	case "byte":
		return &ByteType{RType: RType{TypeName: "byte"}}
	case "f32":
		return &Float32Type{RType: RType{TypeName: "f32"}}
	case "f64":
		return &Float64Type{RType: RType{TypeName: "f64"}}
	case "ptr":
		return &PtrType{RType: RType{TypeName: "ptr"}}
	case "string":
		return &StringType{RType: RType{TypeName: "string"}}
	case "error":
		return NewErrorInterface()
	default:
		if strings.HasPrefix(name, "[]") {
			return NewList(GetSystemType(name[2:]))
		}
		// [N]T 数组类型：name = "[N]T"
		if len(name) > 2 && name[0] == '[' {
			// 找到 ] 的位置
			for i := 1; i < len(name); i++ {
				if name[i] == ']' {
					numStr := name[1:i]
					elemName := name[i+1:]
					length := atoi(numStr)
					if length > 0 {
						elemType := GetSystemType(elemName)
						if elemType != nil {
							return NewArray(elemType, length)
						}
					}
					break
				}
			}
		}
		return nil
	}
}

func atoi(s string) int {
	n := 0
	for _, ch := range s {
		if ch >= '0' && ch <= '9' {
			n = n*10 + int(ch-'0')
		} else {
			return 0
		}
	}
	return n
}

func NewList(elem Type) *ListType {
	if elem == nil {
		panic("elem is nil")
	}
	typeName := "[]" + elem.Type()
	return &ListType{
		RType: RType{TypeName: typeName},
		_elem: elem,
	}
}

func NewArray(elem Type, length int) *ArrayType {
	if elem == nil {
		panic("elem is nil")
	}
	if length <= 0 {
		panic("array length must be > 0")
	}
	typeName := "[" + itoa(length) + "]" + elem.Type()
	return &ArrayType{
		RType: RType{TypeName: typeName},
		_elem: elem,
		_len:  length,
	}
}

func NewStruct(name string, fields StructFileds) *StructType {
	return &StructType{
		RType:        RType{TypeName: name},
		StructFields: fields,
	}
}

func ToRType(t Type) *RType {
	return (*RType)(unsafe.Pointer((*[2]uintptr)(unsafe.Pointer(&t))[1]))
}

// MakePointer 创建真实指针类型：标记 IsPtr 并记录被指类型（元素信息）。
// 返回新的类型对象，不修改原类型（避免污染共享的 StructType/ListType/AliasType）。
// 系统 ptr（地址号类型）不是指针，IsPointer() 为 false，无元素信息。
func MakePointer(t Type) Type {
	return &RType{
		TypeName:   t.Type(),
		RParent:    t,
		IsPtr:      true,
		RAlignment: TargetPointerSize,
		_ptrElem:   t,
	}
}

// IsKindOf t 的 Kind 是否属于给定的任一 Kind。
func IsKindOf(t Type, kinds ...string) bool {
	if t == nil {
		return false
	}
	k := t.Kind()
	for _, want := range kinds {
		if k == want {
			return true
		}
	}
	return false
}

func AutoType(before, after Type, IsConst bool) (ok bool) {
	if before != nil && after != nil {
		// TypeParam (generic type parameter) accepts any type
		if _, isTP := before.(*TypeParam); isTP {
			return true
		}
		if _, isTP := after.(*TypeParam); isTP {
			return true
		}
		beforeType := before.Type()
		afterType := after.Type()
		beforePtr := before.IsPointer()
		afterPtr := after.IsPointer()
		if beforeType == afterType && beforePtr == afterPtr {
			return true
		}
		// 指针放宽：同为指针类（IsPtr 或系统 ptr）且 Kind 相同 → 允许互转（如 memory.malloc 返回的 ptr 赋给 *T）
		beforeIsPtr := beforePtr || beforeType == "ptr"
		afterIsPtr := afterPtr || afterType == "ptr"
		if beforeIsPtr && afterIsPtr && KindEqual(before, after) && IsNum(before) && IsNum(after) {
			return true
		}
		// 任意指针 → 系统 ptr：地址语义一致（如 &s 容器地址赋给 ptr 交给 memory.load64 读槽）
		if beforePtr && afterType == "ptr" && !afterPtr {
			return true
		}
		// fn → 系统 ptr：函数指针地址语义一致（如 workerFn 赋给 ptr 传给 pthread_create）
		if beforeType == "fn" && afterType == "ptr" && !afterPtr {
			return true
		}
		// 系统 ptr → 任意 *T：地址语义一致（如 memory.malloc 返回的 ptr 赋给 *T）
		if !beforePtr && beforeType == "ptr" && afterPtr {
			return true
		}
		// 数字常量 0 → 指针：空指针
		if afterPtr && IsConst && IsNum(before) && beforeType != "ptr" && before.Size() <= after.Size() {
			return true
		}
		// 数值同 Kind 尺寸不同 → 允许隐式转换（零扩展/截断，如 x86 上 u32 地址扩展为 u64）
		if KindEqual(before, after) && !beforePtr && !afterPtr && IsNum(before) && IsNum(after) &&
			before.Size() != after.Size() {
			return true
		}
		// 整型符号位互换：uint 与 int 是同一类位模式，语言层面不区分有符号，
		// 指针偏移量、长度、下标这类地方两边混用是常态。尺寸不等时按截断处理
		// —— 与上面"同 Kind 尺寸不同"那条一致。float 不在此列。
		if !beforePtr && !afterPtr &&
			IsKindOf(before, "int", "uint") && IsKindOf(after, "int", "uint") {
			return true
		}
		if KindEqual(before, after) && before.IsPointer() == after.IsPointer() {
			if CheckKind(before, "list") {
				return false
			}
			if IsConst && IsNum(before) {
				return true
			}
			if before.Size() == after.Size() {
				return true
			}
		}
		if IsConst && before.IsPointer() == after.IsPointer() {
			if IsNum(before) && IsNum(after) {
				return true
			}
		}
		// Interface satisfaction: concrete → interface
		if afterIf, ok := after.(*InterfaceType); ok {
			if afterIf.ImplementsInterface(before) {
				return true
			}
		}
	}
	return false
}

func getSystemKind(t Type) string {
	typeName := t.Type()

	if _, ok := t.(*StructType); ok {
		return "struct"
	}
	if _, ok := t.(*ListType); ok {
		return "list"
	}
	if _, ok := t.(*ArrayType); ok {
		return "array"
	}

	switch typeName {
	case "int", "i64", "i32", "i16", "i8":
		return "int"
	case "uint", "u64", "u32", "u16", "u8":
		return "uint"
	case "f32", "f64":
		return "float"
	case "ptr":
		return "uint"
	case "bool":
		return "bool"
	case "byte":
		return "byte"
	case "string":
		return "string"
	}
	return "unknown"
}

func CheckType(t Type, allows ...Type) (ok bool) {
	for i := 0; i < len(allows); i++ {
		if t == nil || allows[i] == nil {
			continue
		}
		tType := t.Type()
		aType := allows[i].Type()
		if tType == aType && t.IsPointer() == allows[i].IsPointer() {
			return true
		}
	}
	return false
}

func CheckKind(t Type, allows ...string) (ok bool) {
	if t == nil || t.Kind() == "unknown" {
		return false
	}
	for i := 0; i < len(allows); i++ {
		if allows[i] == "unknown" || allows[i] == "" {
			continue
		}
		if t.Kind() == allows[i] {
			return true
		}
	}
	return false
}

func KindEqual(t Type, t2 Type) bool {
	return t.Kind() == t2.Kind()
}

func TypeEqual(t Type, t2 Type) bool {
	return t.Type() == t2.Type() && t.IsPointer() == t2.IsPointer()
}

func IsNum(t Type) bool {
	return CheckKind(t, "int", "uint", "float")
}
