// gc/state.go — 旁挂表：Check 之后事实收集的账本。
//
// parser 不再持有 GC 状态。每个参与分析的 VarBlock / ArgBlock 在这里有
// 一份 binding；语句自己的就地释放记录也按语句节点存（同一变量多次赋值
// 各有各的旧对象）。所有查询都以 AST 指针为键，不做身份复制。

package gc

import (
	"fmt"
	"os"

	"cuteify/parser"
	typeSys "cuteify/type"
)

// paramOut 一条传出边。存调用点而非 cb.Func：跨包首查时未解析，读取时活解。
type paramOut struct {
	cb *parser.CallBlock
	i  int
}

// binding 一个变量 / 参数在本次分析中的归属与逃逸信息。
type binding struct {
	// --- 归属 ---
	obj   *Object      // 我指向的对象；nil = 借用/参数/字段读
	scope parser.Block // 我这个绑定所处的作用域（声明时确定，重绑不改）
	alloc *Object      // 若本语句是分配点，对象在此；多轮分析复用同一个

	// --- 该赋值语句 ---
	releasesOld bool    // 写入前先释放旧值（由就地释放模拟判定）
	oldObj      *Object // 写入前的旧对象

	// --- 使用 ---
	escapes bool               // 我是否跑出本帧
	wroteTo []*parser.VarBlock // 我作为右值被写进过哪些左值（记在右值上）

	// --- 参数链 ---
	arg       *parser.ArgBlock // 非 nil 表示我是某个参数
	fromParam *parser.ArgBlock // 我这个借用来自哪个参数
	out       []paramOut       // 被当实参传出：第 i 实参传给了哪次调用

	owner *parser.VarBlock // 宿主变量；参数为 nil
}

// paramRoot 借用的最早来源参数：arg，或借用链记下的 fromParam。二选一只写一次。
func (b *binding) paramRoot() *parser.ArgBlock {
	if b.arg != nil {
		return b.arg
	}
	return b.fromParam
}

// analysis 一次前端分析的完整状态。单进程单根包串行编译，故用包级当前实例；
// 每次 CollectFront 都重建一份，AST 重建后指针键不复用。
type analysis struct {
	vars map[*parser.VarBlock]*binding
	args map[*parser.ArgBlock]*binding

	objects  []*Object
	curScope parser.Block
	curFunc  *parser.FuncBlock

	// 参数逃逸摘要（原 parser/gc_summary.go）
	paramBusy   map[*parser.FuncBlock]bool
	paramMemo   map[*parser.FuncBlock][]bool
	paramGround map[*parser.FuncBlock][]bool

	// 返回值来源摘要（原 parser/gc_retsum.go）
	retSumMemo   map[*parser.FuncBlock]ReturnKind
	retSumBusy   map[*parser.FuncBlock]bool
	retLocalBusy map[*parser.FuncBlock]map[string]bool
	retAddrMemo  map[*parser.FuncBlock]map[string]bool

	// 诊断：提前释放（应恒为 0）
	premature       int
	prematureDetail []string
}

// front 当前前端分析。CollectFront 之前为 nil；仅供诊断工具读取。
var front *analysis

// gcDebug 打开逃逸决策的 stderr 输出（仅排查用，进程内只读一次）。
var gcDebug = os.Getenv("GC_DEBUG") != ""

func newAnalysis() *analysis {
	return &analysis{
		vars:         map[*parser.VarBlock]*binding{},
		args:         map[*parser.ArgBlock]*binding{},
		paramBusy:    map[*parser.FuncBlock]bool{},
		paramMemo:    map[*parser.FuncBlock][]bool{},
		paramGround:  map[*parser.FuncBlock][]bool{},
		retSumMemo:   map[*parser.FuncBlock]ReturnKind{},
		retSumBusy:   map[*parser.FuncBlock]bool{},
		retLocalBusy: map[*parser.FuncBlock]map[string]bool{},
		retAddrMemo:  map[*parser.FuncBlock]map[string]bool{},
	}
}

// state 取 / 建一个 VarBlock 的账本。语句节点与定义节点共用同一张表，
// 但它们是不同指针，所以"这条语句的 alloc / OldObj"不会写到定义上。
func (a *analysis) state(v *parser.VarBlock) *binding {
	if v == nil {
		return &binding{}
	}
	if b, ok := a.vars[v]; ok {
		return b
	}
	b := &binding{}
	a.vars[v] = b
	return b
}

// argState 参数账本。参数天然归调用方：创建即逃逸，不参与作用域释放。
func (a *analysis) argState(arg *parser.ArgBlock) *binding {
	if arg == nil {
		return &binding{}
	}
	if b, ok := a.args[arg]; ok {
		return b
	}
	b := &binding{arg: arg, escapes: true}
	a.args[arg] = b
	return b
}

// lifeOf 解析一个引用指向的定义账本——语义一句话："这个写站点的账本，
// 挂在谁的 binding 上"。变量写挂定义、参数写挂参数、字段写挂容器。
// 真解析不出（跨包前向等）返回 nil。
func (a *analysis) lifeOf(ref *parser.VarBlock) *binding {
	if ref == nil {
		return nil
	}
	switch d := ref.Define.Value.(type) {
	case *parser.VarBlock:
		return a.state(d)
	case *parser.ArgBlock:
		// 参数天然归调用方：走 Escapes 基线而不是 markEscapes 级联。
		return a.argState(d)
	case *typeSys.StructField:
		// 字段写的账本挂在容器的 binding 上：沿解析链取容器本体。
		for _, p := range ref.Define.Path {
			if vb, ok := p.(*parser.VarBlock); ok {
				return a.state(vb)
			}
			if ab, ok := p.(*parser.ArgBlock); ok {
				return a.argState(ab)
			}
		}
		return nil
	}
	return nil
}

// hostOf 变量绑定的宿主：赋值语句归到它的定义上，槽位按宿主唯一。
func (a *analysis) hostOf(v *parser.VarBlock) *parser.VarBlock {
	if b := a.lifeOf(v); b != nil && b.owner != nil {
		return b.owner
	}
	return v
}

// newObject 登记一次分配。ID 仅在本次分析内稳定。
func (a *analysis) newObject(owner *parser.VarBlock, scope parser.Block) *Object {
	o := &Object{ID: len(a.objects) + 1, Owner: owner, Scope: scope}
	a.objects = append(a.objects, o)
	return o
}

// Objects 当前分析的全部对象，只读。给诊断工具与计划导出用。
func Objects() []*Object {
	if front == nil {
		return nil
	}
	return front.objects
}

// markEscapes 只增不减。帧外可达退回 RC，不是泄漏。
func (a *analysis) markEscapes(b *binding) {
	if b == nil {
		return
	}
	if gcDebug {
		name := "<nil>"
		if b.owner != nil {
			name = b.owner.Name.String()
		}
		id := 0
		if b.obj != nil {
			id = b.obj.ID
		}
		fmt.Fprintf(os.Stderr, "ESC var=%s obj=%d arg=%v\n", name, id, b.arg != nil)
	}
	b.escapes = true
	if b.obj != nil {
		b.obj.Escapes = true
	}
	if b.fromParam != nil {
		a.argState(b.fromParam).escapes = true
	}
}

// initBinding 定义点初始化：登记宿主，清空上一轮记录（alloc 保留）。
func (a *analysis) initBinding(b *binding, owner *parser.VarBlock) {
	if b == nil {
		return
	}
	alloc := b.alloc
	*b = binding{owner: owner, alloc: alloc}
}

// claim 声明"我拥有一块新分配的内存"。对象挂在语句上复用（重复分析不重复建）；
// 同一变量多处 new 各自是独立对象，否则 ReleasesOld 无从判定。
func (a *analysis) claim(b *binding, stmt *parser.VarBlock) {
	if b == nil {
		return
	}
	st := a.state(stmt)
	o := st.alloc
	if o == nil {
		o = a.newObject(b.owner, b.scope)
		st.alloc = o
	} else {
		o.Owner, o.Scope = b.owner, b.scope
	}
	b.obj = o
}

// unify 让两个名字绑定到同一个对象：直接抄对方的对象身份。
func (b *binding) unify(other *binding) {
	if other != nil && other.obj != nil {
		b.obj = other.obj
	}
}

// bindField 记录"容器的某个字段装着这个对象"。
func (a *analysis) bindField(container *parser.VarBlock, field string, val *parser.VarBlock) {
	b := a.state(container)
	if b.obj == nil || val == nil {
		return
	}
	b.obj.FieldVals = append(b.obj.FieldVals, FieldBinding{Field: field, Val: val, Obj: a.state(val).obj})
}
