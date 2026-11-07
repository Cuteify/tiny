// gc/pred.go — 判据：类型 / 表达式形态，只读不写。
//
// 判断一律保守，只认明确形式：字段读 / 索引 / 普通调用返回 false ——
// 误判成新分配会 claim 出凭空的一块内存，误判成裸引用会把引用算到基对象头上。

package gc

import (
	"cuteify/parser"
	typeSys "cuteify/type"
)

// owningType nil 安全的 IsOwning 包装：解析期前向引用 / 跨包未解析时 Type 是 nil。
func owningType(t typeSys.Type) bool {
	if t == nil {
		return false
	}
	return t.IsOwning()
}

// copiesFields 复制这种类型会带走源的字段指针（接口/any、含 owning 字段的
// 结构体值），源必须跟着逃逸 —— 正确做法是把源的存活期延到副本作用域，
// 未实现，先保守标逃逸。owning 类型（*T / string / list）是别名，由 unify 处理。
func copiesFields(t typeSys.Type) bool {
	if owningType(t) {
		return false
	}
	if _, ok := t.(*typeSys.InterfaceType); ok {
		return true
	}
	st := typeSys.StructOf(t)
	if st == nil {
		return false
	}
	for _, f := range st.Fields() {
		if f != nil && owningType(f.Type) {
			return true
		}
	}
	return false
}

// fieldTypeOwning 结构体某字段是否带堆指针（往它写值要管引用）。
func fieldTypeOwning(t typeSys.Type, field string) bool {
	st := typeSys.StructOf(t)
	if st == nil || field == "" {
		return false
	}
	f := st.Field(field)
	return f != nil && owningType(f.Type)
}

// argEscapeOf 作为第 idx 个实参传出时引用方如何升级逃逸：查被调函数摘要；
// 算不出来一律 true（= 退回 RC = 安全）。
func (a *analysis) argEscapeOf(cb *parser.CallBlock, idx int) bool {
	if cb == nil {
		return true
	}
	return a.paramEscapeOfFunc(cb.Func, idx)
}

// freshAllocExpr 是否确定在本帧产生新块：new / newRC（由 isRCExpr 另行排除）/
// 返回值来源为 ReturnFresh 的调用 / 字符串拼接。
func (a *analysis) freshAllocExpr(e *parser.Expression) bool {
	if e == nil {
		return false
	}
	if e.Call != nil {
		if e.Call.IsBuiltinNewAlloc() {
			return !e.Call.IsRC // newRC 由 isRCExpr 另行排除
		}
		if e.Call.Func != nil && a.retSourceOf(e.Call.Func) == ReturnFresh {
			return true
		}
	}
	return e.Separator == "+" && e.Type != nil && e.Type.Kind() == "string"
}

// isRCExpr 是否 newRC() 分配（带 RC 头，用户手工 rcDec，不进自动释放）。
func isRCExpr(e *parser.Expression) bool {
	return e != nil && e.Call != nil && e.Call.IsRC
}

// bareRef 若表达式是裸变量引用，返回它指向的定义账本。
func (a *analysis) bareRef(e *parser.Expression) *binding {
	v := bareVar(e)
	if v == nil {
		return nil
	}
	return a.lifeOf(v)
}

// bareVar 同 bareRef，但给 VarBlock 而不是 binding —— 摘要的预扫描不依赖
// 旁挂表，只有 VarBlock 能当键（局部别名表就拿它当键）。
func bareVar(e *parser.Expression) *parser.VarBlock {
	if e == nil || e.Var == nil || e.Var.IsDefine {
		return nil
	}
	if e.Call != nil || e.Left != nil || e.Right != nil || e.ListElems != nil {
		return nil
	}
	if e.Index[0] != nil || e.Index[1] != nil || e.Index[2] != nil {
		return nil
	}
	if e.IndexSlice {
		return nil
	}
	return e.Var
}
