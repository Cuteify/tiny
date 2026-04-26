// Package parser 实现了名称查找功能
package parser

import typeSys "cuteify/type"

// FindVar 查找变量，使用迭代自动机方式
func (p *Parser) FindVar(name Name) (*Node, *VarBlock) {
	if p.Block == p.ThisBlock {
		n := p.FindGlobal(name)
		if n == nil {
			return nil, nil
		}

		if vb, ok := n.Value.(*VarBlock); ok {
			return n, vb
		}
	}

	for p.ThisBlock != nil {
		// 查找函数参数
		if funcBlock, ok := p.ThisBlock.Value.(*FuncBlock); ok {
			for _, arg := range funcBlock.Args {
				if arg.Name.String() == name.First() {
					return nil, p.varFromArg(arg)
				}
			}
		}

		for i := len(p.ThisBlock.Children) - 1; i >= 0; i-- { // 从后往前查找，确保先找到最近的变量
			child := p.ThisBlock.Children[i]
			if child.Value == nil {
				continue
			}

			if vb, ok := child.Value.(*VarBlock); ok {
				if vb.Name.MatchT(name, vb.Type) && vb.IsDefine {
					if len(name) == 1 {
						return child, vb
					}
					return child, vb
				}
			}
		}

		// 返回上一层
		p.ThisBlock = p.ThisBlock.Father
	}

	return nil, nil
}

// varFromArg 将ArgBlock转换为VarBlock
func (p *Parser) varFromArg(arg *ArgBlock) *VarBlock {
	return &VarBlock{
		Name:   arg.Name,
		Type:   arg.Type,
		Offset: arg.Offset,
	}
}

// FindFunc 查找函数
func (p *Parser) FindFunc(name Name) (*Node, *FuncBlock) {
	if p.Block == p.ThisBlock {
		n := p.FindGlobal(name)
		if n == nil {
			return nil, nil
		}

		if f, ok := n.Value.(*FuncBlock); ok {
			return n, f
		}
	}

	for i := len(p.Block.Children) - 1; i >= 0; i-- { // 从后往前查找，确保先找到最近的函数
		child := p.Block.Children[i]
		if child.Value == nil {
			continue
		}

		if fb, ok := child.Value.(*FuncBlock); ok {
			if fb.Name.Eq(name) {
				return child, fb
			}
		}
	}

	return nil, nil
}

// TODO: // FindStruct 查找结构体
// TODO: func (p *Parser) FindStruct(name Name) (*Node, *StructBlock) {
// TODO: 	if p.Block == p.ThisBlock {
// TODO: 		n := p.FindGlobal(name)
// TODO: 		if n == nil {
// TODO: 			return nil, nil
// TODO: 		}
// TODO:
// TODO: 		if sb, ok := n.Value.(*StructBlock); ok {
// TODO: 			return n, sb
// TODO: 		}
// TODO: 	}
// TODO:
// TODO: 	for i := len(p.Block.Children) - 1; i >= 0; i-- { // 从后往前查找，确保先找到最近的结构体
// TODO: 		child := p.Block.Children[i]
// TODO: 		if child.Value == nil {
// TODO: 			continue
// TODO: 		}
// TODO:
// TODO: 		if sb, ok := child.Value.(*StructBlock); ok {
// TODO: 			if sb.Name.Eq(name) {
// TODO: 				return child, sb
// TODO: 			}
// TODO: 		}
// TODO: 	}
// TODO:
// TODO: 	return nil, nil
// TODO: }

// FindGlobalVar 查找全局变量
func (p *Parser) FindGlobal(_name Name) *Node {
	var children = []*Node{}
	name := _name.Fork()
	if name.IsPath() {
		name.FixPath(p.Package)
		children = p.Package.AST.(*Node).Children
	} else {
		children = p.Block.Children
	}

	// 查询引入的包
	for i := len(children) - 1; i >= 0; i-- { // 从后往前查找
		child := children[i]
		switch v := child.Value.(type) {
		case *VarBlock:
			if v.Name.MatchT(name, v.Type) && v.IsDefine {
				return child
			}
		// TODO: case *StructBlock:
		// TODO: 	if v.Name.MatchT(name, v.Type()) {
		// TODO: 		for _, field := range v.Fields() {
		// TODO: 			if v.Name.ForkSlice(name).First() == field.Name {
		// TODO: 				return child
		// TODO: 			}
		// TODO: 		}
		// TODO: 	}
		case *FuncBlock:
			if v.Name.Eq(name) {
				return child
			}
		}
	}

	return nil
}

func (p *Parser) FindType(name Name) (*Node, typeSys.Type) {
	if p.Block == p.ThisBlock {
		n := p.FindGlobal(name)
		if n == nil {
			return nil, nil
		}

		// TODO: if sb, ok := n.Value.(*StructBlock); ok {
		// TODO: 	return n, sb.Type()
		// TODO: }

		if tb, ok := n.Value.(*TypeBlock); ok {
			return n, tb.Type
		}
	}

	// TODO: // 查询类型定义或者结构体
	// TODO: for i := len(p.Block.Children) - 1; i >= 0; i-- { // 从后往前查找，确保先找到最近的结构体
	// TODO: 	child := p.Block.Children[i]
	// TODO: 	if child.Value == nil {
	// TODO: 		continue
	// TODO: 	}
	// TODO:
	// TODO: 	if sb, ok := child.Value.(*StructBlock); ok {
	// TODO: 		if sb.Name.Eq(name) {
	// TODO: 			return child, sb.Type()
	// TODO: 		}
	// TODO: 	}
	// TODO:
	// TODO: 	if tb, ok := child.Value.(*TypeBlock); ok {
	// TODO: 		if tb.Name.Eq(name) {
	// TODO: 			return child, tb.Type
	// TODO: 		}
	// TODO: 	}
	// TODO: }

	return nil, nil
}
