// Package type 的 deferred 类型：堆积所有尚未解析的类型引用，待全局合并后回填。
//
// 解析期遇到无法定位的类型（跨文件/跨包前向/环引用），不报错也不留 nil，
// 而是产出 *DeferredType 占位；包合并后全局 Check 逐块 re-parseTypeRef 回填。
// 第 49 轮仍无法解析，才算真错误。kind/selflow 之类的环自检时 DeferredType
// 也能共存 —— 它的 Kind() 与 Type() 都与任何已知类型不同。

package typeSys

// DeferredType 未决的类型引用（延迟绑定）。Text 为引用原文，
// Pos/Path 仅用于报错定位。
type DeferredType struct {
	Text string
	Pos  int
	Path string
}

// NewDeferredType 记录一处未决的类型引用。
func NewDeferredType(text string, pos int, path string) Type {
	return &DeferredType{Text: text, Pos: pos, Path: path}
}

// IsDeferred 判断 t 是否为 deferred 占位。
func IsDeferred(t Type) bool {
	_, ok := t.(*DeferredType)
	return ok
}

func (d *DeferredType) Type() string    { return "deferred" }
func (d *DeferredType) String() string  { return d.Text }
func (d *DeferredType) Kind() string    { return "deferred" }
func (d *DeferredType) Size() int       { return -1 }
func (d *DeferredType) Parent() Type    { return nil }
func (d *DeferredType) IsPointer() bool { return false }
func (d *DeferredType) Alignment() int  { return TargetPointerSize }
func (d *DeferredType) Elem() Type      { return nil }
func (d *DeferredType) Methods() []any  { return nil }
func (d *DeferredType) Fields() StructFileds { return nil }
func (d *DeferredType) IsOwning() bool  { return false }
