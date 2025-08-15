package typeSys

import (
	"math"
	"strings"
	"unsafe"
)

type Type interface {
	// Type returns the type of the value.
	Type() string
	// String returns the string representation of the value.
	String() string
	// Value returns the value of the type.
	Fields() StructFileds
	// Set sets the value of the type.
	Set(interface{})
	// Size returns the RSize of the type.
	Size() int
	// RFather returns the RFather of the type.
	Father() Type
	// IsPointer returns true if the type is a pointer.
	IsPointer() bool
}

type StructFileds []*StructField

type StructField struct {
	Name   string
	Type   Type
	Tag    string
	Offset int
}

type RType struct {
	TypeName string
	RSize    int
	RFather  Type
	IsPtr    bool
}

func (r *RType) Father() Type {
	return r.RFather
}

func (r *RType) IsPointer() bool {
	return r.IsPtr
}

func (r *RType) Type() string {
	return r.TypeName
}

func (r *RType) Size() int {
	if r.RSize == 0 {
		switch r.TypeName {
		case "int", "uint":
			if math.MaxInt == math.MaxInt32 {
				r.RSize = 4
			} else {
				r.RSize = 8
			}
		case "i64", "u64", "f64":
			r.RSize = 8
		case "i32", "u32", "f32":
			r.RSize = 4
		case "i16", "u16":
			r.RSize = 2
		case "i8", "u8", "bool", "byte":
			r.RSize = 1
		}
	}
	return r.RSize
}

func (r *RType) Set(name any) {
	r.TypeName = name.(string)
}

func (r *RType) String() string {
	return r.TypeName
}

func (r *RType) Fields() StructFileds {
	if r.TypeName != "struct" {
		return nil
	}
	return (*StructType)(unsafe.Pointer(r)).StructFields
}

type StructType struct {
	RType
	StructFields StructFileds
}

func NewStructField(father Type, name string, typ Type) (sf *StructField) {
	if father != nil {
		if father.Type() != "struct" {
			panic("RFather is not struct")
		}
		sf = &StructField{
			Name:   name,
			Type:   typ,
			Offset: typ.Size() + father.Size(),
		}
		father.(*RType).RSize += typ.Size()
	} else {
		panic("RFather is nil")
	}
	return
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
	case "string":
		return &StringType{RType: RType{TypeName: "string"}}
	default:
		return nil
	}
}

func ToRType(t Type) *RType {
	return (*RType)(unsafe.Pointer((*[2]uintptr)(unsafe.Pointer(&t))[1]))
}

func AutoType(before, after Type, IsConst bool) (ok bool) {
	if before != nil && after != nil {
		if CheckType(before, after) {
			return true
		}
		if GetTypeType(before) == GetTypeType(after) && before.IsPointer() == after.IsPointer() {
			if IsConst {
				switch GetTypeType(before) {
				case "int", "uint", "float":
					return true
				}
			}
			if before.Size() == after.Size() {
				return true
			}
		}
		if IsConst && before.IsPointer() == after.IsPointer() {
			switch GetTypeType(before) {
			case "int", "uint", "float":
				switch GetTypeType(after) {
				case "int", "uint", "float":
					return true
				}
			}
		}
	}
	return false
}

func GetTypeType(t Type) string {
	switch t.Type() {
	case "int", "i64", "i32", "i16", "i8":
		return "int"
	case "uint", "u64", "u32", "u16", "u8":
		return "uint"
	case "f32", "f64":
		return "float"
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
		if t.Type() == allows[i].Type() && t.IsPointer() == allows[i].IsPointer() {
			if t.Type() == "struct" {
				for j := 0; j < len(t.Fields()); j++ {
					if CheckType(t.Fields()[j].Type, allows[i].Fields()[j].Type) {
						ok = true
					}
				}
				if ok {
					return true
				}
			} else if t.Size() == allows[i].Size() {
				return true
			}
		}
	}
	return false
}

func CheckTypeType(t Type, allows ...string) (ok bool) {
	if t == nil || GetTypeType(t) == "unknown" {
		return false
	}
	for i := 0; i < len(allows); i++ {
		if allows[i] == "unknown" || allows[i] == "" {
			continue
		}
		if GetTypeType(t) == allows[i] {
			return true
		}
	}
	return false
}
