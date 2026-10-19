// parser/gc_pred.go — 判据：类型和表达式形态
//
// 逃逸分析要反复回答三类问题，都在这里：
//
//	owningType / copiesFields / fieldTypeOwning
//	    类型自己带不带堆指针 / 复制它会不会带走字段指针 / 某个字段带不带指针
//
//	freshAllocExpr / isRCExpr / bareRef / bareVar
//	    这个表达式是不是**确定**的新分配 / 是不是 newRC / 是不是裸变量引用
//
//	ArgEscapeOf（开关）
//	    作为第 idx 个实参传出时，引用方要不要升级逃逸 —— 查跨函数摘要
//
// 判断一律保守：只认明确的形式。字段读 / 索引 / 普通调用都返回 false，
// 它们可能只是抄了别人的指针，误判成新分配会凭空多出一块内存。

package parser

import typeSys "cuteify/type"

// owningType 是 nil 安全的 IsOwning 包装。
// IsOwning 定义在 RType 上（值嵌入），类型未定型时（解析期前向引用、
// 跨包调用未解析）Type 为 nil，直接调用会 panic。
func owningType(t typeSys.Type) bool {
	if t == nil {
		return false
	}
	return t.IsOwning()
}

// copiesFields 赋值/定义到这种类型时，是"把源的字段指针复制走"，源必须跟着逃逸。
// 只包括接口/any（两槽里含数据指针）与含 owning 字段的结构体值。
// owning 类型（*T / string / list）不算：那是所有权转移或别名，由 unify 处理。
// copiesFields 赋值/定义到这种类型时，是"把源的字段指针复制走"而非别名。
// 只包括接口/any 与含 owning 字段的结构体值；owning 类型（*T/string/list）是别名。
// 正确做法是把源的存活期延到副本的作用域，暂未实现（见 docs/gc.md），先保守标逃逸。
func copiesFields(t typeSys.Type) bool {
	if owningType(t) {
		return false
	}
	if _, ok := t.(*typeSys.InterfaceType); ok {
		return true
	}
	st := structOf(t)
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

// structOf 取出指针指向的结构体类型；不是结构体返回 nil。
func structOf(t typeSys.Type) *typeSys.StructType {
	if t == nil {
		return nil
	}
	if st, ok := t.(*typeSys.StructType); ok {
		return st
	}
	if t.IsPointer() {
		if st, ok := t.Elem().(*typeSys.StructType); ok {
			return st
		}
	}
	return nil
}

// fieldTypeOwning t 的第 field 个字段是否带堆指针。
// 往这个字段写值要管引用，所以得先问它带不带指针。
func fieldTypeOwning(t typeSys.Type, field string) bool {
	st := structOf(t)
	if st == nil || field == "" {
		return false
	}
	f := st.Field(field)
	return f != nil && owningType(f.Type)
}

// ============================================================
// 使用模式
// ============================================================

// ArgEscapeOf 决定"作为第 idx 个实参传出"时引用方如何升级逃逸。
// 默认 true —— 前端还没有跨函数摘要，任何"传出去"都可能被存到别处。
// 接入被调参数摘要后改这里：
//
//	ArgEscapeOf = func(cb *CallBlock, idx int) bool {
//	    if cb == nil || cb.Func == nil || idx >= len(cb.Func.Args) { return true }
//	    return cb.Func.Args[idx].Escapes
//	}
//
// ArgEscapeOf 决定"作为第 idx 个实参传出"时引用方如何升级逃逸。
// 查跨函数过程摘要（见 gc_summary.go）；算不出来一律 true。
var ArgEscapeOf = func(cb *CallBlock, idx int) bool {
	if cb == nil {
		return true
	}
	return paramEscapeOfFunc(cb.Func, idx)
}

// TreatMethodReceiverAsArg：方法接收者是否与实参同等对待（true=保守不释放）。
var TreatMethodReceiverAsArg = true

// ============================================================
// 表达式里的引用
// ============================================================

// AssumeOwningCallResultOwned：调用结果是否算本帧新分配。
// 默认 false（安全）：它可能只是把某个参数原样返回。
var AssumeOwningCallResultOwned = false

// freshAllocExpr 表达式是否**确定**在本帧产生一个新块：new / newRC / make / 字符串拼接。
// freshAllocExpr 表达式是否**确定**在本帧产生一个新块：
//
//	new(T) / newRC / make / 字符串拼接 /
//	被调方声明"返回值里有它自己分配的对象"（所有权已转移，调用结果算调用者的）
//
// 判断保守：只认这些明确形式。字段读 / 索引 / 普通调用一律 false ——
// 它们可能只是抄了别人的指针，claim 一个新对象会凭空多出一块内存。
func freshAllocExpr(e *Expression) bool {
	if e == nil {
		return false
	}
	if e.Call != nil {
		if e.Call.NewType != nil {
			return true // newRC 由 isRCExpr 另行排除
		}
		// 过程摘要：被调方声明"返回值里有它自己分配的对象"，所有权已转给调用者，
		// 所以这次调用结果就是调用者自己的新分配。
		if e.Call.Func != nil && e.Call.Func.ReturnsOwned {
			return true
		}
		if AssumeOwningCallResultOwned && e.Call.Func != nil &&
			len(e.Call.Func.Return) > 0 && owningType(e.Call.Func.Return[0]) {
			return true
		}
	}
	return e.Separator == "+" && e.Type != nil && e.Type.Kind() == "string"
}

// isRCExpr 是否 newRC() 分配（带 RC 头，由用户手工 rcDec 管理，不进自动释放）。
func isRCExpr(e *Expression) bool {
	return e != nil && e.Call != nil && e.Call.IsRC
}

// bareRef 若表达式是裸变量引用，返回它指向的定义（变量或参数）。
func bareRef(e *Expression) *Life {
	l := bareVar(e)
	if l == nil {
		return nil
	}
	return LifeOf(l)
}

// bareVar 同 bareRef，但给出引用到的 VarBlock 而不是它的 Life。
// 摘要的预扫描在 Check 之前跑，那时 Life.owner 还没被 bind 填上，
// 只有 VarBlock 能拿到（localOf 就是拿 VarBlock 当键的）。
func bareVar(e *Expression) *VarBlock {
	if e == nil || e.Var == nil || e.Var.IsDefine {
		return nil
	}
	if e.Call != nil || e.Left != nil || e.Right != nil || e.ListElems != nil {
		return nil
	}
	if e.Index[0] != nil || e.Index[1] != nil || e.Index[2] != nil {
		return nil
	}
	return e.Var
}
