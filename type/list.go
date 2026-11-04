package typeSys

type ListType struct {
	RType
	_elem Type
	// shape（S0-2，P11 类型视图铁律）：内建容器形状的显式 StructType 视图。
	// 一经懒构造即缓存；展开点（索引/字面量/sliceExp/append/make/len/cap/清零）
	// 一律经 Shape() 查表取字段偏移，禁止手写 +0/+8/+16 字面算术。
	shape *StructType
}

// Shape 返回容器形状视图：data: *T@0 / len: uint / cap: uint（P8/P11，Go 序）。
// 布局由 StructType.Layout 依 typeSys 元数据自然计算：x64 = 0/8/16，
// x86 cdecl（指针 4B）= 0/4/8 —— 与编译器既有算术布局逐位一致。
func (l *ListType) Shape() *StructType {
	if l.shape == nil {
		var ptrT Type
		if l._elem != nil {
			ptrT = MakePointer(l._elem)
		} else {
			ptrT = GetSystemType("ptr")
		}
		l.shape = NewStruct("sliceHdr", StructFileds{
			{Name: "data", Type: ptrT},
			{Name: "len", Type: GetSystemType("uint")},
			{Name: "cap", Type: GetSystemType("uint")},
		})
	}
	return l.shape
}

func (l *ListType) Size() int {
	// S0-2（P11）：大小不再 hand-coded 24/12 字面量——经 shape 视图 Layout
	// 自然计算（x64: 8+8+8=24；x86: 4+4+4=12），与既有值逐位一致。
	return l.Shape().Size()
}

func (l *ListType) Alignment() int {
	// S0-2（P11）：对齐同理经 shape（= TargetPointerSize，逐位一致）。
	return l.Shape().Alignment()
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

// IsOwning []T 的值携带 data 堆指针，需要引用管理。
//
// 必须在这里显式实现：ListType 内嵌 RType，若走提升的 RType.IsOwning，
// 接收者是内嵌的 *RType，r.Kind() 只会看到 "unknown"，list 会被漏掉。
func (l *ListType) IsOwning() bool {
	return l != nil
}
