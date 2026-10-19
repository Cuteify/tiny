// parser/gc_model.go — GC 分析的数据模型
//
// 两个结构体撑起全部状态：
//
//	Life    挂在 VarBlock / ArgBlock 上，是**变量的**视角：
//	        我指向哪个对象、我的绑定处在哪个作用域、我被写进过哪些左值。
//	Object 挂在每次分配上，是**堆块**的视角：
//	        谁指向它、在哪释放、释放时读哪个槽。
//
// 变量是槽位，对象是内存 —— 两者分开是整个分析能自洽的前提。
// 同一变量连续两次 new() 就是两个对象，否则"这条赋值顶掉的是哪一块"分不清。
//
// Disposal 是给后端的唯一入口，三态见下面的 const 块。

package parser

// FieldBinding 结构体容器的某个字段装着哪个对象。
type FieldBinding struct {
	Field string    // 字段名
	Val   *VarBlock // 字段值的代表定义
	Obj   *Object   // 字段值对象；字段收敛时用它核对 Val 的栈槽是否仍持有该对象
}

// Object 一次分配产生的堆块。对象身份与变量无关 —— 同一变量连续两次
// new() 就是两个对象，这样"这条语句覆盖掉的是哪一块"才分得清。
//
// 一个对象至多一个释放点：身份全程唯一，"在哪释放、读哪个槽"也就唯一。
// 所以这里是两个标量，不是 map。
//
// 处置只有两类（见 Disposal）：帧内可达就在 FreeScope 处 free，帧外可达退回 RC。
// 作用域释放集的唯一来源就是 FreeScope，每个块恰好被 free 一次。
// FieldVals 只用于**排序**（字段值先于容器自身），不决定"是否释放" ——
// 字段值通常自己也有 FreeScope，按两者并集释放会双重释放。
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

// Life 一个变量的归属与逃逸信息。
//
// Check 期只写**一条正向事实**：我指向哪个对象（Obj）、我这个绑定处在哪个作用域（Scope）。
// 重绑就是覆盖这条记录，不需要撤销任何东西 —— 旧对象自然失去这个名字，
// 因为"某对象当前被哪些名字指着"由 Finalize 反转一次算出来，不是增量维护的。
type Life struct {
	// --- 归属（Check 期写入，可被覆盖）---
	Obj   *Object // 我指向的对象；nil = 借用/参数/字段读
	Scope Block   // 我这个绑定所处的作用域（声明时确定，重绑不改）
	alloc *Object // 若本语句是分配点，对象在此；多轮 Check 复用同一个

	// --- 该赋值语句 ---
	ReleasesOld bool    // 写入前应先释放旧值（Finalize 判定：旧对象已无绑定名）
	OldObj      *Object // 写入前的旧对象

	// --- 使用 ---
	Escapes bool        // 我是否跑出本帧
	WroteTo []*VarBlock // 我作为**右值**被写进过哪些左值。释放点取这些左值作用域的最大值。
	// WroteTo 记在右值上而不是左值上：左值一个槽只能存一个对象，后写的会
	// 把先写的挤掉（分支里 result = n1 / n2 就是这样）；记在右值上两条边都在。

	// --- 参数链（跨函数摘要用，见 gc_summary.go）
	arg       *ArgBlock    // 非 nil 表示我是某个参数
	fromParam *ArgBlock    // 我这个借用来自哪个参数
	PassedTo  []int        // 我作为第 i 个实参被传出过，目标函数的第几号参数
	passedAt  []*CallBlock // 与 PassedTo 一一对应的调用点

	owner *VarBlock // 宿主变量（登记时写入）；参数为 nil
}

// paramRoot 这个借用的最早来源：直接是参数（arg），或经由借用链记到的
// 参数（fromParam）。collectArgs 记实参传出、mkFromParam 记借用来源时
// 都要做同一件事 —— 二选一的判断只在这里写一次。
func (l *Life) paramRoot() *ArgBlock {
	if l.arg != nil {
		return l.arg
	}
	return l.fromParam
}

// Disposal 一个对象怎么处置。后端只调这一个方法，不要自己拼条件。
type Disposal uint8

const (
	// DisposalBorrow 不是本帧分配的块（参数 / 字段读 / 索引 / 调用结果 / newRC）：
	// 存储归别人，本帧什么都不做。
	DisposalBorrow Disposal = iota
	// DisposalScope 帧内可达：在 ReleaseScope() 处 free。
	//   - 有绑定名在本作用域之外 → 那是"逃逸结束位置"（最外层绑定作用域的出口）
	//   - 全部绑定名都在本级内   → 那是"本级尾部"（创建作用域的出口）
	// 两种情形是同一条公式：释放点 = 最外层绑定作用域。
	DisposalScope
	// DisposalRC 帧外可达（返回 / 存到全局 / 传给摘要未知的函数）：
	// 作用域释放管不到，退回引用计数。全局就是这一类。
	DisposalRC
)

// Disposal 该对象如何处置。
// 同一个对象只要有**任何一个**绑定名逃出本帧，就不能用作用域释放 —— 释放后
// 逃出去的那个名字就是悬垂指针。这种情况不是"泄漏了事"，而是退回引用计数。
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

// ReleaseScope 释放点：Finalize 算出的最外层绑定作用域（nil = 不释放）。
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

// markEscapes 标记为"跑出本帧"（只增不减）。帧外可达的处置是退回引用计数，
// 不是泄漏 —— 见 DisposalRC。why 只用于诊断：区分"真需要 RC"与"只是缺摘要"。
func (l *Life) markEscapes() {
	l.Escapes = true
	if l.Obj != nil {
		l.Obj.Escapes = true // 对象级：一个名字跑出本帧，整个对象就得走 RC
	}
	if l.fromParam != nil {
		// 我是某个参数的借用：真正的逃逸要算到那个参数头上，
		// 否则 var q = p; g = q 这种会把参数的逃逸吃掉。
		l.fromParam.Life.Escapes = true
	}
}

// Init 登记宿主并清空上一轮的全部记录。定义点每个 Check 轮次都会调一次。
func (l *Life) Init(owner *VarBlock) {
	// 零值就是默认值（Escapes false、Obj/Scope/OldObj nil、ReleasesOld false），
	// 逐字段再赋一遍是冗余 —— 一条结构体赋值清空全部。
	//
	// alloc 是唯一要保的：它属于"这条语句是不是分配点"这个事实，与轮次无关，
	// 清掉会导致多轮 Check 反复建对象。
	alloc := l.alloc
	*l = Life{owner: owner}
	l.alloc = alloc
}

// claim 声明"我拥有一块新分配的内存"。
//
// stmt 是这条分配语句。同一变量可以有多处 new，各自是独立的对象（否则
// "这条赋值顶掉的是哪一块"分不清，ReleasesOld 就无从判定）。对象挂在 stmt 上
// 复用，Check 跑三轮不会重复建。
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

// bindField 记录"容器的某个字段装着这个对象"。同一字段被重复写入时，
// Finalize 只保留最后一次（先前的字段值不再被容器持有）。
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
		// 参数由调用者持有：本帧永远不自动释放。
		// 在这里置位而不是在解析时初始化，参数就没有额外的登记入口。
		// 注意走 Escapes 而不是 markEscapes：这是"天然归调用方"的基线，
		// 不算"被传出"，否则每个参数都会被判成逃逸。
		d.Life.Escapes = true
		d.Life.arg = d
		return &d.Life
	}
	return nil
}

// CopyLife 把 src 的归属与逃逸信息复制到 dst。
// 单态化深拷贝 VarBlock 时必须调用：Life 非导出，结构体字面量不会自动带上它，
// 漏拷会让特化函数误以为"不逃逸且自有"→ 提前释放。
func CopyLife(dst, src *VarBlock) {
	if dst == nil || src == nil {
		return
	}
	dst.Life = src.Life
	dst.Life.owner = dst // 宿主要指向拷贝自己，不能指回原节点
}

// Objects 本次编译分配出的全部对象，只读。
// 给包外的诊断工具（tools/esccheck）用 —— objects 本身是包级私有的。
// 属于"文件缺失逼出来的改动"：esccheck 源码丢了，重写它需要这个入口。
func Objects() []*Object { return objects }
