// Package parser 实现了名称查找功能
package parser

import (
	typeSys "cuteify/type"
)

// FindVar 查找变量，使用迭代自动机方式
func (p *Parser) FindVar(name Name) (*Node, any) {
	// fmt.Println("FIND", p.Block == p.ThisBlock || p.ThisBlock.Father == nil, p.ThisBlock.Value, "FATHER=", p.ThisBlock.Father)
	if p.Block == p.ThisBlock || p.ThisBlock.Father == nil {
		// fmt.Println("GLOOOOOBAL", name)
		n := p.FindGlobal(name)
		if n == nil {
			return nil, nil
		}

		if vb, ok := n.Value.(*VarBlock); ok {
			return n, vb
		}
	}

	oldThisBlock := p.ThisBlock

	for p.ThisBlock != nil {
		// fmt.Println("LOOP", p.ThisBlock.Value)
		// 查找函数参数
		if funcBlock, ok := p.ThisBlock.Value.(*FuncBlock); ok {
			for _, arg := range funcBlock.Args {
				if arg.Name.Eq(name) {
					p.ThisBlock = oldThisBlock
					return nil, arg
				}
			}
		}

		for i := len(p.ThisBlock.Children) - 1; i >= 0; i-- { // 从后往前查找，确保先找到最近的变量
			child := p.ThisBlock.Children[i]
			if child.Value == nil {
				continue
			}

			if vb, ok := child.Value.(*VarBlock); ok {
				//fmt.Println(vb.Name, name)
				if vb.Name.MatchT(name, vb.Type) && vb.IsDefine {
					p.ThisBlock = oldThisBlock
					if len(name) == 1 {
						return child, vb
					}
					return child, vb
				}
			}
		}

		// 返回上一层
		// fmt.Println("GOING UP FROM", p.ThisBlock.Value, "FATHER=", p.ThisBlock.Father)
		p.ThisBlock = p.ThisBlock.Father
	}

	p.ThisBlock = oldThisBlock

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

// FindStruct 查找结构体
func (p *Parser) FindStruct(name Name) (*Node, *StructBlock) {
	if p.Block == p.ThisBlock {
		n := p.FindGlobal(name)
		if n == nil {
			return nil, nil
		}

		if sb, ok := n.Value.(*StructBlock); ok {
			return n, sb
		}
	}

	for i := len(p.Block.Children) - 1; i >= 0; i-- {
		child := p.Block.Children[i]
		if child.Value == nil {
			continue
		}

		if sb, ok := child.Value.(*StructBlock); ok {
			if sb.Name.Eq(name) {
				return child, sb
			}
		}
	}

	return nil, nil
}

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
	if t := typeSys.GetSystemType(name.String()); t != nil {
		return nil, t
	}

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
