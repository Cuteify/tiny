package gc

import (
	"cuteify/parser"
	typeSys "cuteify/type"
)

// fieldAliasStructs 记录出现过“同基对象字段互赋”的结构体类型名
// （例如 x.cur = x.root）。这类字段可能互为别名，函数出口逐字段释放会
// 双重释放；因此对该类型整体禁用字段级联释放，宁可漏放。
var fieldAliasStructs = map[string]bool{}

// markFieldAliasStructs 扫描全程序函数体，收集存在同基字段互赋的结构体。
// 字段级联释放只对“字段各自独立拥有子对象”的类型安全；一旦出现
// x.f = x.g，f 与 g 在运行期可能指向同一块内存。
func markFieldAliasStructs(fns map[string]*parser.FuncBlock, nodes map[string]*parser.Node) {
	fieldAliasStructs = map[string]bool{}
	for key, fb := range fns {
		body := nodes[key]
		if body == nil {
			continue
		}
		walkFieldAliases(fb, body, func(st *typeSys.StructType) {
			if st.TypeName != "" {
				fieldAliasStructs[st.TypeName] = true
			}
		})
	}
}

// walkFieldAliases 遍历函数体，对每条 `x.f = x.g` 形式的赋值回调宿主类型。
func walkFieldAliases(fb *parser.FuncBlock, body *parser.Node, mark func(*typeSys.StructType)) {
	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if n == nil {
			return
		}
		if vb, ok := n.Value.(*parser.VarBlock); ok {
			if !vb.IsDefine && len(vb.Name) > 1 && vb.Value != nil &&
				vb.Value.Var != nil && vb.Value.Call == nil &&
				vb.Value.Left == nil && vb.Value.Right == nil {
				base := vb.Name.First()
				ref := vb.Value.Var.Name
				if len(ref) > 1 && ref.First() == base {
					if st := structTypeOfVar(fb, body, base); st != nil {
						mark(st)
					}
				}
			}
		}
		for _, ch := range n.Children {
			walk(ch)
		}
	}
	walk(body)
}

// structTypeOfVar 查找变量（参数或函数体内定义）的 struct 类型，
// 兼容直接 struct 值与 *struct 指针。
func structTypeOfVar(fb *parser.FuncBlock, body *parser.Node, name string) *typeSys.StructType {
	find := func(t typeSys.Type) *typeSys.StructType {
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
	if fb != nil {
		for _, ag := range fb.Args {
			if ag.Name != nil && ag.Name.First() == name {
				if st := find(ag.Type); st != nil {
					return st
				}
			}
		}
	}
	var found *typeSys.StructType
	var walk func(n *parser.Node)
	walk = func(n *parser.Node) {
		if n == nil || found != nil {
			return
		}
		if vb, ok := n.Value.(*parser.VarBlock); ok && vb.IsDefine &&
			vb.Type != nil && vb.Name != nil && vb.Name.First() == name {
			found = find(vb.Type)
			return
		}
		for _, ch := range n.Children {
			walk(ch)
		}
	}
	walk(body)
	return found
}
