// parser/gc_model.go — GC 分析的数据模型
//
// Life 是变量的视角（挂在 VarBlock / ArgBlock 上），Object 是堆块的视角
// （挂在每次分配上）。变量是槽位、对象是内存，两者分开是分析自洽的前提：
// 同一变量连续两次 new() 是两个对象，否则"这条赋值顶掉的是哪一块"分不清。
// Disposal 是给后端的唯一入口。

package parser

// FieldBinding 结构体容器的某个字段装着哪个对象。
type FieldBinding struct {
	Field string    // 字段名
	Val   *VarBlock // 字段值的代表定义
	Obj   *Object   // 字段值对象；字段收敛时用它核对 Val 的栈槽是否仍持有该对象
}

// Object 一次分配产生的堆块。一个对象至多一个释放点：身份全程唯一，
// "在哪释放、读哪个槽"就唯一 —— 所以这里是两个标量，不是 map。
// FieldVals 仅用于排序（字段值先于容器自身），不决定是否释放：
// 字段值通常自己也有 FreeScope，按并集释放会双重释放。
type Object struct {
	ID          int            // 标号：第几次分配（调试、诊断、后端表索引用）
	Owner       *VarBlock      // 初始持有者（创建处的栈槽；可能已被改绑）
	Scope       Block          // 创建作用域（块，不是语句）
	Escapes     bool           // 是否有绑定名跑出本帧（→ 退回 RC）
	Transferred bool           // 所有权已转移给调用者（ret 本地对象）：本帧不再释放
	Names       []*VarBlock    // 当前指向它的全部名字（collectNames 反转得出）
	FreeScope   Block          // 作用域释放点；nil = 不按作用域释放
	Holder      *VarBlock      // 释放时读哪个栈槽（创建者被改绑时指向另一个绑定名）
	FieldVals   []FieldBinding // 字段关系：仅用于排序，同一字段只留最后一次写入
}

// objects 本次编译分配出的全部对象（单线程解析期，线性追加）。
var objects []*Object

func newObject(owner *VarBlock, scope Block) *Object {
	o := &Object{ID: len(objects) + 1, Owner: owner, Scope: scope}
	objects = append(objects, o)
	return o
}

// Life 一个变量的归属与逃逸信息。Check 期只写正向事实（Obj / Scope），
// 重绑就是覆盖，不需要撤销 —— "谁指着它"由 collectNames 反转得出。
type Life struct {
	// --- 归属（Check 期写入，可被覆盖）---
	Obj   *Object // 我指向的对象；nil = 借用/参数/字段读
	Scope Block   // 我这个绑定所处的作用域（声明时确定，重绑不改）
	alloc *Object // 若本语句是分配点，对象在此；多轮 Check 复用同一个

	// --- 该赋值语句 ---
	ReleasesOld bool    // 写入前先释放旧值（由就地释放模拟判定）
	OldObj      *Object // 写入前的旧对象

	// --- 使用 ---
	Escapes bool        // 我是否跑出本帧
	WroteTo []*VarBlock // 我作为右值被写进过哪些左值（记在右值上：同槽后写会挤掉
	// 前写，分支里 result = n1 / n2 的两条边都得留下）。释放点取最大值。

	// --- 参数链（跨函数摘要用，见 gc_summary.go）
	arg       *ArgBlock    // 非 nil 表示我是某个参数
	fromParam *ArgBlock    // 我这个借用来自哪个参数
	PassedTo  []int        // 我作为第 i 个实参被传出过，目标函数的第几号参数
	passedAt  []*CallBlock // 与 PassedTo 一一对应的调用点

	owner *VarBlock // 宿主变量（登记时写入）；参数为 nil
}

// paramRoot 借用的最早来源参数：arg，或借用链记下的 fromParam。二选一只写一次。
func (l *Life) paramRoot() *ArgBlock {
	if l.arg != nil {
		return l.arg
	}
	return l.fromParam
}

// Disposal 一个对象怎么处置。后端只调这一个方法，不要自己拼条件。
type Disposal uint8

const (
	// DisposalBorrow 不是本帧分配的块（参数 / 字段读 / 索引 / 调用结果 / newRC）。
	DisposalBorrow Disposal = iota
	// DisposalScope 帧内可达，在 ReleaseScope() 处 free。
	// 释放点 = 最外层绑定作用域，一条公式同时覆盖"逃逸结束位置"和"本级尾部"。
	DisposalScope
	// DisposalRC 帧外可达（返回 / 存全局 / 传给摘要未知的函数），退回引用计数。全局属此类。
	DisposalRC
)

// Disposal 有任何一个绑定名逃出本帧就不能作用域释放（悬垂），退回 RC。
func (l *Life) Disposal() Disposal {
	o := l.Obj
	if o == nil {
		return DisposalBorrow
	}
	if o.Transferred {
		return DisposalBorrow // 所有权已交给调用者，本帧不碰
	}
	if o.Escapes {
		return DisposalRC
	}
	for _, n := range o.Names {
		if n != nil && n.Life.Escapes {
			return DisposalRC
		}
	}
	if o.FreeScope == nil {
		return DisposalBorrow // 没有名字指向它：孤儿，交给上层
	}
	return DisposalScope
}

// String 诊断用：可读的三态名（Scope / RC / Borrow）。
func (d Disposal) String() string {
	switch d {
	case DisposalScope:
		return "Scope"
	case DisposalRC:
		return "RC"
	default:
		return "Borrow"
	}
}

// IsRep 我是否拥有这个对象（分配就发生在我这个栈槽上）。
func (l *Life) IsRep() bool {
	return l.owner != nil && l.Obj != nil && l.Obj.Owner == l.owner
}

// ReleaseScope 释放点：scopeRelease 算出的最外层绑定作用域（nil = 不释放）。
func (l *Life) ReleaseScope() Block {
	o := l.Obj
	if o == nil {
		return nil
	}
	return o.FreeScope
}

// Holder 释放时读哪个栈槽。创建者若已被改绑（栈槽被覆盖），
// 这里给的是另一个仍持有该对象的绑定名。
func (l *Life) Holder() *VarBlock {
	o := l.Obj
	if o == nil {
		return nil
	}
	return o.Holder
}

// markEscapes 只增不减。帧外可达退回 RC，不是泄漏。
func (l *Life) markEscapes() {
	l.Escapes = true
	if l.Obj != nil {
		l.Obj.Escapes = true // 对象级：一个名字跑出本帧，整个对象就得走 RC
	}
	if l.fromParam != nil { // var q = p; g = q：逃逸要算回参数头上
		l.fromParam.Life.Escapes = true
	}
}

// Init 定义点每个 Check 轮次调一次：登记宿主，清空上一轮全部记录。
func (l *Life) Init(owner *VarBlock) {
	// alloc 是唯一要保的：它属于"这条语句是分配点"这个事实，与轮次无关，
	// 清掉会让多轮 Check 反复建对象。
	alloc := l.alloc
	*l = Life{owner: owner}
	l.alloc = alloc
}

// claim 声明"我拥有一块新分配的内存"。对象挂在 stmt 上复用（Check 多轮不
// 重复建）；同一变量多处 new 各自是独立对象，否则 ReleasesOld 无从判定。
func (l *Life) claim(stmt *VarBlock) {
	o := stmt.Life.alloc
	if o == nil {
		o = newObject(l.owner, l.Scope)
		stmt.Life.alloc = o
	} else {
		o.Owner, o.Scope = l.owner, l.Scope
	}
	l.Obj = o
}

// unify 让两个名字绑定到同一个对象：直接抄对方的对象身份。
// 已经指向别的对象的会被覆盖 —— 这就是"重绑"。
func (l *Life) unify(other *Life) {
	if obj := other.Obj; obj != nil {
		l.Obj = obj
	}
}

// bindField 记录"容器的某个字段装着这个对象"。
// 同一字段重复写入时由 collectNames 收敛，只保留最后一次。
func (l *Life) bindField(field string, val *VarBlock) {
	o := l.Obj
	if o == nil || val == nil {
		return
	}
	o.FieldVals = append(o.FieldVals, FieldBinding{Field: field, Val: val, Obj: val.Life.Obj})
}

// ============================================================
// 作用域
// ============================================================

// LifeOf 解析一个**引用** VarBlock（lhs = rhs 里的 rhs 那种）指向的定义的
// 归属信息；解析不出返回 nil。
func LifeOf(ref *VarBlock) *Life {
	if ref == nil {
		return nil
	}
	switch d := ref.Define.Value.(type) {
	case *VarBlock:
		return &d.Life
	case *ArgBlock:
		// 参数天然归调用方：走 Escapes 基线而不是 markEscapes 级联，
		// 否则每个参数都会被判成"被传出"。
		d.Life.Escapes = true
		d.Life.arg = d
		return &d.Life
	}
	return nil
}

// CopyLife 单态化深拷贝 VarBlock 时必须调用：Life 非导出，字面量不会带上它，
// 漏拷会让特化副本误以为"不逃逸且自有" → 提前释放。
func CopyLife(dst, src *VarBlock) {
	if dst == nil || src == nil {
		return
	}
	dst.Life = src.Life
	dst.Life.owner = dst // 宿主要指向拷贝自己，不能指回原节点
}

// Objects 全部对象，只读。给包外诊断工具（tools/esccheck）用。
func Objects() []*Object { return objects }
