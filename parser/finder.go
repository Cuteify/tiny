package parser

import (
	typeSys "cuteify/type"
)

/*
import (
	"strings"

	typeSys "cuteify/type"
)

func (p *Parser) FindVar(name Name) (*Node, any) {
	if p.Block == p.ThisBlock || p.ThisBlock.Father == nil {
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
		if funcBlock, ok := p.ThisBlock.Value.(*FuncBlock); ok {
			for _, arg := range funcBlock.Args {
				if arg.Name.Eq(name) {
					p.ThisBlock = oldThisBlock
					return nil, arg
				}
			}
		}

		for i := len(p.ThisBlock.Children) - 1; i >= 0; i-- {
			child := p.ThisBlock.Children[i]
			if child.Value == nil {
				continue
			}

			if vb, ok := child.Value.(*VarBlock); ok {
				if vb.Name.MatchT(name, vb.Type) && vb.IsDefine {
					p.ThisBlock = oldThisBlock
					return child, vb
				}
			}
		}

		p.ThisBlock = p.ThisBlock.Father
	}

	p.ThisBlock = oldThisBlock

	return nil, nil
}

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

	for i := len(p.Block.Children) - 1; i >= 0; i-- {
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

func (p *Parser) FindStruct(name Name) (*Node, *TypeBlock) {
	for i := len(p.Block.Children) - 1; i >= 0; i-- {
		child := p.Block.Children[i]
		if child.Value == nil {
			continue
		}

		if tb, ok := child.Value.(*TypeBlock); ok {
			if tb.Kind == TypeStruct && tb.Name.Eq(name) {
				return child, tb
			}
		}
	}

	return nil, nil
}

func (p *Parser) FindGlobal(_name Name) *Node {
	var children = []*Node{}
	name := _name.Fork()
	if name.IsPath() {
		name.FixPath(p.Package)
		children = p.Package.AST.(*Node).Children
	} else {
		children = p.Block.Children
	}

	for i := len(children) - 1; i >= 0; i-- {
		child := children[i]
		switch v := child.Value.(type) {
		case *VarBlock:
			if v.Name.MatchT(name, v.Type) && v.IsDefine {
				return child
			}
		case *TypeBlock:
			if v.Name.Eq(name) {
				return child
			}
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

	nameStr := name.String()
	listPrefix := ""
	elemNameStr := nameStr
	if strings.HasPrefix(nameStr, "lists.[]") {
		listPrefix = "lists.[]"
		elemNameStr = nameStr[8:]
	} else if strings.HasPrefix(nameStr, "[]") {
		listPrefix = "[]"
		elemNameStr = nameStr[2:]
	}
	if listPrefix != "" {
		elemName := NewName(elemNameStr)
		_, elemType := p.FindType(elemName)
		if elemType != nil {
			return nil, typeSys.GetListType(elemType)
		}
	}

	for i := len(p.Block.Children) - 1; i >= 0; i-- {
		child := p.Block.Children[i]
		if child.Value == nil {
			continue
		}

		if tb, ok := child.Value.(*TypeBlock); ok {
			if tb.Name.Eq(name) {
				return child, tb.Type()
			}
		}
	}

	return nil, nil
}
*/

type FindType int

const (
	FindTypeUnknown FindType = 0
	FindTypeVar     FindType = 1 << iota
	FindTypeFunc
	FindTypeType
	FindTypeField
	FindTypeItem
	FindTypeArg
	FindTypeSelf
)

type FindResult struct {
	Node  *Node
	Value any
	Path  []any
	Type  FindType
}

type FindResults []FindResult

func (p *Parser) Find(name Name, typ FindType) (res FindResults) {
	if (typ&FindTypeSelf) != 0 && name.First() == "self" {
		return []FindResult{findSelf(p, name, typ)}
	}

	nowBlock := p.ThisBlock
	for nowBlock != nil {
		if nowBlock == p.Block || nowBlock.Father == nil {
			// 把名称转换为全局名称
			nameFork := name.Fork()
			nameFork.FixPath(p.Package)
			name = nameFork
		}
		if fb, ok := nowBlock.Value.(*FuncBlock); ok {
			r, ok := findArg(fb, name, nowBlock)
			if ok && (r.Type&typ) != 0 {
				res = append(res, r)
			}
		}
		for i := 0; i < len(nowBlock.Children); i++ {
			child := nowBlock.Children[i]
			if child.Value == nil {
				continue
			}

			switch v := child.Value.(type) {
			case *TypeBlock:
				if (typ&FindTypeType) != 0 && v.Name.Eq(name) {
					res = append(res, FindResult{Node: child, Value: v, Path: []any{v}, Type: FindTypeType})
				}
			case *FuncBlock:
				if (typ&FindTypeFunc) != 0 && v.Name.Eq(name) {
					res = append(res, FindResult{Node: child, Value: v, Path: []any{v}, Type: FindTypeFunc})
				}
			case *VarBlock:
				if (typ&FindTypeVar) != 0 && v.IsDefine {
					if name.IsPath() {
						if n := name.Match(v.Name); n > 0 {
							ok, r := enterTypeFind(name[n:], v.Type)
							if ok && (r.Type&typ) != 0 {
								r.Node = child
								res = append(res, r)
							}
						}
					} else {
						if v.Name.Eq(name) {
							res = append(res, FindResult{Node: child, Value: v, Path: []any{v}, Type: FindTypeVar})
						}
					}
				}
			}
		}
		nowBlock = nowBlock.Father
	}
	return res
}

func enterTypeFind(name Name, t typeSys.Type) (ok bool, res FindResult) {
	if name.Length() == 0 {
		return false, FindResult{}
	}
	// 在t中查找类型是否为List或Struct
	n := name.Fork()
	nowType := t
	findPath := []any{}
	for nowType != nil && n.Length() > 0 {

		switch nowType.Kind() {
		case "list":
			if n[0].Slice == nil {
				ok = false
				return
			}
			// 找到List类型
			nowType = nowType.Elem()
			n = n[1:]
			findPath = append(findPath, nowType)
			res.Type = FindTypeItem
		case "struct":
			// 找到Struct类型
			if n[0].Name == "" {
				ok = false
				return
			}
			// 找到Struct字段
			fields := nowType.Fields()
			for _, field := range fields {
				if field.Name == n[0].Name {
					nowType = field.Type
					break
				}
			}
			if nowType == nil {
				ok = false
				return
			}
			n = n[1:]
			findPath = append(findPath, nowType)
			res.Type = FindTypeField
		default:
			// 继续查找
			nowType = nowType.Elem()
		}
	}
	ok = true
	res.Path = findPath
	res.Value = nowType
	return ok, res
}

func findArg(fb *FuncBlock, name Name, nowBlock *Node) (res FindResult, ok bool) {
	// 查询函数参数
	for _, arg := range fb.Args {
		if name.IsPath() {
			if n := name.Match(arg.Name); n > 0 {
				ok, r := enterTypeFind(name[n:], arg.Type)
				if ok {
					r.Node = nowBlock
					return r, true
				}
			}
		} else {
			if arg.Name.Eq(name) {
				res = FindResult{Node: nowBlock, Value: arg, Path: []any{arg}, Type: FindTypeArg}
			}
		}
	}
	return res, false
}

func findSelf(p *Parser, name Name, typ FindType) FindResult {
	// 找到func self
	nowBlock := p.ThisBlock
	for nowBlock != nil {
		if _, ok := nowBlock.Value.(*FuncBlock); ok {
			break
		}
	}
	if nowBlock == nil {
		p.Error.MissError("Call Error", p.Lexer.Cursor, "self must be in function")
		return FindResult{}
	}

	fn := nowBlock.Value.(*FuncBlock)

	// 检查是否有所属类型
	if fn.Class == nil {
		p.Error.MissError("Call Error", p.Lexer.Cursor, "self must be in class")
		return FindResult{}
	}

	if name.String() == "self" {
		return FindResult{Node: nowBlock, Value: fn.Class, Path: []any{fn}, Type: FindTypeSelf}
	} else {
		ok, r := enterTypeFind(name[1:], fn.Class)
		if ok && (r.Type&typ) != 0 {
			r.Node = nowBlock
			return r
		}
	}

	return FindResult{}
}
