package typeSys

// FuncType represents a function type (function pointer)
// e.g., fn(int, string) -> bool
type FuncType struct {
	RType
	Args    []Type // Parameter types
	Returns []Type // Return types
}

// Size returns the size of a function pointer (one pointer)
func (f *FuncType) Size() int {
	return TargetPointerSize
}

// String returns the string representation of the function type
func (f *FuncType) String() string {
	s := "fn("
	for i, arg := range f.Args {
		if i > 0 {
			s += ", "
		}
		s += arg.Type()
	}
	s += ") "
	if len(f.Returns) == 1 {
		s += f.Returns[0].Type()
	} else if len(f.Returns) > 1 {
		s += "("
		for i, ret := range f.Returns {
			if i > 0 {
				s += ", "
			}
			s += ret.Type()
		}
		s += ")"
	}
	return s
}

// Kind returns the kind of the type
func (f *FuncType) Kind() string {
	return "func"
}
