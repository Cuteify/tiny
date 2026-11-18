package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
)

// reResolveDeferredType 回填一处 deferred 类型引用：把文本当成新的类型引用重新走 TypeRef 流水线。
// 在解析期（ParsePhase）文本一定重解析回 deferred 占位 —— 返回 nil 表示本轮还无法兑现；
// 在 ParsePhase 之后找不到也返回 nil，调用方自行决定报错或等下一轮 MergeRound。
// t 本身不是 deferred：递归回填包装类型（*T、[]T、[N]T、map[K]V）里的元素，
// 把里层回填出的新元素重建进一个等价包装后返回；整个返回值能完全兑现才算齐活。
func reResolveDeferredType(p *Parser, t typeSys.Type) typeSys.Type {
	if t == nil {
		return nil
	}
	switch dt := t.(type) {
	case *typeSys.DeferredType:
		return parseDeferredText(p, dt)
	}
	// 包装类型里的 deferred 元素：递归回填后重建包装；
	// 任何一层兑现不了本轮就整体返回 nil，交给下一轮 MergeRound 重试。
	switch wt := t.(type) {
	case *typeSys.RType:
		if wt.IsPointer() {
			elem := reResolveDeferredType(p, wt.Elem())
			if elem == nil {
				return nil
			}
			if elem == wt.Elem() {
				return t
			}
			return typeSys.MakePointer(elem)
		}
		return t
	case *typeSys.ListType:
		elem := reResolveDeferredType(p, wt.Elem())
		if elem == nil {
			return nil
		}
		if elem == wt.Elem() {
			return t
		}
		return typeSys.NewList(elem)
	case *typeSys.ArrayType:
		elem := reResolveDeferredType(p, wt.Elem())
		if elem == nil {
			return nil
		}
		if elem == wt.Elem() {
			return t
		}
		return typeSys.NewArray(elem, wt.Len())
	case *typeSys.MapType:
		k := reResolveDeferredType(p, wt.Key())
		if k == nil {
			return nil
		}
		v := reResolveDeferredType(p, wt.Elem())
		if v == nil {
			return nil
		}
		if k == wt.Key() && v == wt.Elem() {
			return t
		}
		return typeSys.NewMapType(k, v)
	}
	return t
}

// parseDeferredText 把一处 deferred 类型的文本重新走 TypeRef 流水线。
// 解析期（ParsePhase）回填一定再回 deferred 占位，返回 nil 表示本轮无法兑现；
// 合并后找不到也返回 nil，调用方自行决定报错或下一轮重试。
func parseDeferredText(p *Parser, dt *typeSys.DeferredType) typeSys.Type {
	if ParsePhase {
		return nil
	}
	savedLexer, savedError := p.Lexer, p.Error
	p.Lexer = lexer.NewLexerFromString(dt.Text, dt.Path)
	p.Error = p.Lexer.Error
	res := p.parseTypeRef()
	p.Lexer, p.Error = savedLexer, savedError
	return res
}
