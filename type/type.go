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
}

type StructFileds []*StructField

type RType struct {
	TypeName   string
	RSize      int
	RParent    Type
	IsPtr      bool
	RAlignment int
	_methods   []any
}

func (r *RType) Kind() string {
	return getSystemKind(r)
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
	default:
		if strings.HasPrefix(name, "[]") {
			return NewList(GetSystemType(name[2:]))
		}
		return nil
	}
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

func NewStruct(name string, fields StructFileds) *StructType {
	return &StructType{
		RType:        RType{TypeName: name},
		StructFields: fields,
	}
}

func ToRType(t Type) *RType {
	return (*RType)(unsafe.Pointer((*[2]uintptr)(unsafe.Pointer(&t))[1]))
}

func AutoType(before, after Type, IsConst bool) (ok bool) {
	if before != nil && after != nil {
		beforeType := before.Type()
		afterType := after.Type()
		beforePtr := before.IsPointer()
		afterPtr := after.IsPointer()
		if beforeType == afterType && beforePtr == afterPtr {
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
