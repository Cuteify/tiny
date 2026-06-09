package typeSys

type FieldAccess int

const (
	AccessPublic FieldAccess = iota
	AccessPrivate
	AccessProtected
	AccessReadOnly
	AccessWriteOnly
)

type StructTag struct {
	Key   string
	Value string
}

type StructField struct {
	Name       string
	Type       Type
	Default    any
	Tags       []StructTag
	Offset     int
	Size       int
	Alignment  int
	Access     FieldAccess
	Alias      string
	ParentName string
	IsAnon     bool
}

func (f *StructField) IsPrivate() bool {
	return f.Access == AccessPrivate
}

func (f *StructField) IsReadOnly() bool {
	return f.Access == AccessReadOnly
}

func (f *StructField) IsWriteOnly() bool {
	return f.Access == AccessWriteOnly
}

func (f *StructField) IsPublic() bool {
	return f.Access == AccessPublic
}

func (f *StructField) CanRead() bool {
	return f.Access == AccessPublic || f.Access == AccessReadOnly
}

func (f *StructField) CanWrite() bool {
	return f.Access == AccessPublic || f.Access == AccessWriteOnly
}

func (f *StructField) ParseTags(tags string) {
	isString := false
	isName := true
	f.Tags = append(f.Tags, StructTag{})

	for _, tag := range tags[:] {
		switch tag {
		case '"':
			isString = !isString
			if !isString {
				isName = true
				f.Tags = append(f.Tags, StructTag{})
			}
		case ':':
			if isString {
				f.Tags[len(f.Tags)-1].Value += string(tag)
				continue
			}
			isName = false
		case ' ':
			isName = true
			f.Tags = append(f.Tags, StructTag{})
		default:
			if isString {
				f.Tags[len(f.Tags)-1].Value += string(tag)
			} else if isName {
				f.Tags[len(f.Tags)-1].Key += string(tag)
			}
		}
	}
}

type StructType struct {
	RType
	StructFields StructFileds
}

func (s *StructType) Size() int {
	// 计算结构体的大小
	s.Layout()
	return s.RSize
}

func (s *StructType) Fields() StructFileds {
	return s.StructFields
}

func (s *StructType) Layout() {
	offset := 0
	maxAlignment := 1

	for _, field := range s.StructFields {
		alignment := 1
		if field.Type != nil {
			size := field.Type.Size()
			if size > 0 {
				alignment = size
			}
		}
		field.Alignment = alignment
		if alignment > maxAlignment {
			maxAlignment = alignment
		}

		padding := (alignment - (offset % alignment)) % alignment
		offset += padding
		field.Offset = offset

		if field.Type != nil && field.Type.Size() > 0 {
			field.Size = field.Type.Size()
		} else {
			field.Size = 1
		}
		offset += field.Size
	}

	s.RSize = offset
	s.RAlignment = maxAlignment
}

func (s *StructType) Field(name string) *StructField {
	for _, field := range s.StructFields {
		if field.Name == name {
			return field
		}
	}
	return nil
}

func (s *StructType) Kind() string {
	return "struct"
}

func (s *StructType) Inherit(find func(string) *StructType) {
	var inherited StructFileds
	var rest StructFileds

	for _, field := range s.StructFields {
		if field.ParentName == "" {
			rest = append(rest, field)
			continue
		}

		parentStruct := find(field.ParentName)
		if parentStruct == nil {
			rest = append(rest, field)
			continue
		}
		parentStruct.Inherit(find)
		parentStruct.Layout()

		if field.IsAnon {
			for _, pf := range parentStruct.StructFields {
				inherited = append(inherited, &StructField{
					Name:   pf.Name,
					Type:   pf.Type,
					Tags:   pf.Tags,
					Access: pf.Access,
				})
			}
		} else {
			inherited = append(inherited, &StructField{
				Name: field.Alias,
				Type: parentStruct,
			})
		}
	}

	s.StructFields = append(inherited, rest...)
}
