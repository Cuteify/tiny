package typeSys

type StructType struct {
	RType
	Name         []string
	StructFields StructFileds
	Methods      []any
}

func (s *StructType) Fields() StructFileds {
	return s.StructFields
}

type FieldAccess int

const (
	AccessPublic FieldAccess = iota
	AccessPrivate
	AccessReadOnly
	AccessWriteOnly
)

type StructTag struct {
	Key   string
	Value string
}

type StructField struct {
	Name      string
	Type      Type
	Default   any
	Tags      []StructTag
	Offset    int
	Size      int
	Alignment int
	Access    FieldAccess
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

func (s *StructField) parseTags(tags string) {
	// 状态机变量
	isString := false
	isName := true

	// 解析标签
	for _, tag := range tags[:] {
		switch tag {
		case '"':
			isString = !isString
			if !isString {
				isName = true
				s.Tags = append(s.Tags, StructTag{})
			}
		case ':':
			if isString {
				s.Tags[len(s.Tags)-1].Value += string(tag)
				continue
			}
			isName = false
		case ' ':
			isName = true
			s.Tags = append(s.Tags, StructTag{})
		default:
			if isString {
				s.Tags[len(s.Tags)-1].Value += string(tag)
			} else if isName {
				s.Tags[len(s.Tags)-1].Key += string(tag)
			}
		}
	}
}

func splitTagKeyValue(s string) []string {
	for i, r := range s {
		if r == ':' {
			key := s[:i]
			value := s[i+1:]
			// 安全地去除首尾引号
			if len(value) >= 2 && value[0] == '"' && value[len(value)-1] == '"' {
				value = value[1 : len(value)-1]
			}
			return []string{key, value}
		}
	}
	return []string{s, ""}
}

func NewStructField(father Type, name string, typ Type) (sf *StructField) {
	if father == nil {
		panic("RFather is nil")
	}
	sf = &StructField{
		Name: name,
		Type: typ,
	}
	if st, ok := father.(*StructType); ok {
		sf.Offset = st.RSize
		st.RSize += typ.Size()
		st.StructFields = append(st.StructFields, sf)
	} else {
		sf.Offset = father.Size()
	}
	return
}
