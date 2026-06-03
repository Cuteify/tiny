package typeSys

type ListType struct {
	RType
	_elem Type
}

func (l *ListType) Size() int {
	if TargetPointerSize == 8 {
		return 24
	}
	return 12
}

func (l *ListType) Alignment() int {
	return TargetPointerSize
}

func (l *ListType) String() string {
	if l._elem == nil {
		panic("elem is nil")
	}
	return "[]" + l._elem.Type()
}

func (l *ListType) Elem() Type {
	return l._elem
}

func (l *ListType) Kind() string {
	return "list"
}
