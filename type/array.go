package typeSys

// ArrayType 固定长度数组类型 [N]T
type ArrayType struct {
	RType
	_elem Type
	_len  int
}

func (a *ArrayType) Size() int {
	return a._elem.Size() * a._len
}

func (a *ArrayType) Alignment() int {
	return a._elem.Alignment()
}

func (a *ArrayType) String() string {
	if a._elem == nil {
		panic("elem is nil")
	}
	return "[" + itoa(a._len) + "]" + a._elem.Type()
}

func (a *ArrayType) Elem() Type {
	return a._elem
}

func (a *ArrayType) Len() int {
	return a._len
}

func (a *ArrayType) Kind() string {
	return "array"
}

func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	buf := [20]byte{}
	i := len(buf)
	for n > 0 {
		i--
		buf[i] = byte('0' + n%10)
		n /= 10
	}
	return string(buf[i:])
}
