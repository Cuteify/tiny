// gc/model.go — 前端 GC 数据模型：对象、字段关系、五态处置。
//
// Object 是堆块的视角（每次分配一个），变量是槽位；两者的关联不再挂在
// parser.VarBlock 上，而是由 gc 内部的旁挂表维护。后端的 LLR 是另一套
// 语句级模型，不复用这里的 Object 身份。

package gc

import "cuteify/parser"

// FieldBinding 结构体容器的某个字段装着哪个对象。
type FieldBinding struct {
	Field string           // 字段名
	Val   *parser.VarBlock // 字段值的代表定义
	Obj   *Object          // 字段值对象；绑定时的快照，字段释放读容器 + 字段名，不读 Val 槽
	Stale bool             // Val 槽之后被改绑；仅表示不能拿 Val 当读槽，不影响字段关系
}

// Object 一次分配产生的堆块。一个对象至多一个释放点：身份全程唯一，
// "在哪释放、读哪个槽"就唯一 —— 所以这里是两个标量，不是 map。
// FieldVals 记录容器字段的绑定关系，供字段 cascade 释放只被容器持有的对象；
// 有变量名持有的字段值仍由自己的 FreeScope 释放，避免双重释放。
type Object struct {
	ID          int                // 标号：第几次分配（调试、诊断用）
	Owner       *parser.VarBlock   // 初始持有者（创建处的栈槽；可能已被改绑）
	Scope       parser.Block       // 创建作用域（块，不是语句）
	Escapes     bool               // 是否有绑定名跑出本帧（→ 退回 RC）
	Transferred bool               // 所有权已转移给调用者（ret 本地对象）：本帧不再释放
	Names       []*parser.VarBlock // 当前指向它的全部名字（collectNames 反转得出）
	FreeScope   parser.Block       // 作用域释放点；nil = 不按作用域释放
	Holder      *parser.VarBlock   // 释放时读哪个栈槽（创建者被改绑时指向另一个绑定名）
	Inplace     bool               // 已在覆盖赋值点就地释放；此时 FreeScope/Holder 不再生效
	FieldOwner  *Object            // 只被该容器的字段持有；释放 = free FieldOwner.FieldName
	FieldName   string             // 持有本对象的字段名（FieldOwner 非 nil 时有效）
	FieldVals   []FieldBinding     // 字段关系：同一字段只留最后一次写入

	allocSite *parser.VarBlock // 分配语句（对拍/诊断用；不参与判定）
}

// AllocSite 分配语句节点。仅供诊断与双轨对拍使用。
func (o *Object) AllocSite() *parser.VarBlock {
	if o == nil {
		return nil
	}
	return o.allocSite
}

// Disposal 一个对象怎么处置。后端只调这一个判据，不要自己拼条件。
type Disposal uint8

const (
	// DisposalBorrow 不是本帧分配的块（参数 / 字段读 / 索引 / 调用结果 / newRC）。
	DisposalBorrow Disposal = iota
	// DisposalScope 帧内可达，在释放作用域处 free。
	DisposalScope
	// DisposalRC 帧外可达（返回 / 存全局 / 传给摘要未知的函数），退回引用计数。
	DisposalRC
	// DisposalInplace 已在覆盖赋值点就地释放。
	DisposalInplace
	// DisposalField 只被容器的字段持有；在容器释放点先 free 容器.字段。
	DisposalField
)

// DisposalOf 对象级处置判定。
func DisposalOf(o *Object) Disposal {
	if o == nil {
		return DisposalBorrow
	}
	if o.Inplace {
		return DisposalInplace
	}
	if o.Transferred {
		return DisposalBorrow
	}
	if o.FieldOwner != nil {
		return DisposalField
	}
	if o.Escapes {
		return DisposalRC
	}
	if o.FreeScope == nil {
		return DisposalBorrow
	}
	return DisposalScope
}

// String 诊断用：可读的五态名（Scope / Field / Inplace / RC / Borrow）。
func (d Disposal) String() string {
	switch d {
	case DisposalScope:
		return "Scope"
	case DisposalRC:
		return "RC"
	case DisposalInplace:
		return "Inplace"
	case DisposalField:
		return "Field"
	default:
		return "Borrow"
	}
}
