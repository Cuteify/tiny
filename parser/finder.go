package parser

import (
	packageFmt "cuteify/package/fmt"
	typeSys "cuteify/type"
	"fmt"
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

	// 兜底：跨文件/跨包全局变量（根包合并树中查找）
	if n := p.FindGlobal(name); n != nil {
		if vb, ok := n.Value.(*VarBlock); ok {
			return n, vb
		}
	}

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
	// MultiIndex 命中的是多返回值解构（a, b := foo()）里的第几个名字。
	// 引用处按它取对应栈槽（见 VarBlock.MultiIndex 与 MultiOffsets）。
	MultiIndex int
}

type FindResults []FindResult

func (p *Parser) Find(name Name, typ FindType) (res FindResults) {
	if (typ&FindTypeSelf) != 0 && name.First() == "self" {
		return []FindResult{findSelf(p, name, typ)}
	}

	if (typ & FindTypeType) != 0 {
		if t := typeSys.GetSystemType(name.String()); t != nil {
			res = append(res, FindResult{Value: t, Path: []any{t}, Type: FindTypeType})
		}
		// 解析期跨文件/跨包类型查找（全局注册表）
		if len(res) == 0 {
			if t := lookupGlobalType(p, name); t != nil {
				res = append(res, FindResult{Value: t, Path: []any{t}, Type: FindTypeType})
			}
		}
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
			if child.Value == nil || child.Ignore == true {
				continue
			}

			switch v := child.Value.(type) {
			case *TypeBlock:
				if (typ&FindTypeType) != 0 && v.Name.Eq(name) {
					res = append(res, FindResult{Node: child, Value: v.Type(), Path: []any{v.Type()}, Type: FindTypeType})
				}
			case *FuncBlock:
				if (typ&FindTypeFunc) != 0 && v.Name.Eq(name) {
					res = append(res, FindResult{Node: child, Value: v, Path: []any{v}, Type: FindTypeFunc})
				}
			case *ForBlock:
				var tmp *VarBlock
				if v.Init != nil && v.Init.Var != nil && v.Init.Var.IsDefine {
					tmp = v.Init.Var
				}
				// for i, v in coll：循环变量在体内可见，登记方式与 Init.Var 一致。
				if len(v.RangeNames) > 0 {
					for _, rn := range v.RangeNames {
						if rn != nil && rn.IsDefine && name.Eq(rn.Name) {
							res = append(res, FindResult{Node: child, Value: rn, Path: []any{rn}, Type: FindTypeVar})
						}
					}
				}
				if v.Increment != nil && v.Increment.Var != nil && v.Increment.Var.IsDefine {
					tmp = v.Increment.Var
				}
				if name.IsPath() {
					if tmp != nil {
						if n := name.Match(tmp.Name); n > 0 {
							ok, r := enterTypeFind(name[n:], tmp.Type)
							if ok && (r.Type&typ) != 0 {
								r.Node = child
								r.Path = append([]any{tmp}, r.Path...)
								res = append(res, r)
							}
						}
					}
				} else {
					if tmp != nil && tmp.Name.Eq(name) && (typ&FindTypeVar) != 0 {
						res = append(res, FindResult{Node: child, Value: tmp, Path: []any{v, tmp}, Type: FindTypeVar})
					}
				}
			case *VarBlock:
				if v.IsDefine {
					if name.IsPath() {
						if n := name.Match(v.Name); n > 0 {
							if n == name.Length() {
								// 完全匹配（跨包常量/全局变量）
								if (typ & FindTypeVar) != 0 {
									res = append(res, FindResult{Node: child, Value: v, Path: []any{v}, Type: FindTypeVar})
								}
								continue
							}
							ok, r := enterTypeFind(name[n:], v.Type)
							if ok && (r.Type&typ) != 0 {
								r.Node = child
								r.Path = append([]any{v}, r.Path...)
								res = append(res, r)
							}
						}
					} else {
						if v.Name.Eq(name) && (typ&FindTypeVar) != 0 {
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
	// 记录基础类型（访问前的起始类型），供编译层计算字段/元素偏移
	if nowType != nil {
		findPath = append(findPath, nowType)
	}
	for nowType != nil && n.Length() > 0 {
		// 指针基类型/中间指针：解引用一层后继续查找字段
		// （p.x / p.x.y / head.next.x，支持多层指针链）
		if nowType.IsPointer() {
			elem := nowType.Elem()
			if elem == nil {
				ok = false
				return
			}
			nowType = elem
			findPath = append(findPath, nowType)
		}
		switch nowType.Kind() {
		case "list":
			if n[0].Slice == nil {
				// 检查是否是len字段
				if n[0].Name == "len" && n.Length() == 1 {
					findPath = append(findPath, nowType)
					res.Type = FindTypeField
					res.Value = genVLen()
					res.Path = findPath
					ok = true
					return
				}
				ok = false
				return
			}

			// 检查NamePart是否为切片还是索引
			// 无上界的下标（list[i]）取元素类型；有上界的是切片，
			// 类型就是容器本身（list[a:b] 的结果仍是 list）。
			if n[0].Slice.End == nil {
				nowType = nowType.Elem()
			}
			n = n[1:]
			findPath = append(findPath, nowType)
			res.Type = FindTypeItem
			res.Value = nowType
		case "struct":
			// 找到Struct类型
			if n[0].Name == "" {
				ok = false
				return
			}

			// 查找Method
			methods := nowType.Methods()
			for _, method := range methods {
				if method.(*FuncBlock).Name.Last() == n.Last() {
					ok = true
					res.Type = FindTypeFunc
					res.Value = method
					findPath = append(findPath, nowType)
					res.Path = findPath
					return
				}
			}

			// 找到Struct字段
			fields := nowType.Fields()
			findField := false
			var field *typeSys.StructField
			for _, field = range fields {
				if field.Name == n.First() {
					findField = true
					nowType = field.Type
					break
				}
			}
			// 啥也找不到
			if !findField {
				fmt.Println("not find field", n[0].Name)
				ok = false
				return
			}
			n = n[1:]
			findPath = append(findPath, nowType)
			res.Type = FindTypeField
			res.Value = field
		default:
			// 继续查找
			ok = false
			return
		}
	}
	ok = true
	res.Path = findPath
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
					r.Path = append([]any{arg}, r.Path...)
					return r, true
				}
			}
		} else {
			if arg.Name.Eq(name) {
				return FindResult{Node: nowBlock, Value: arg, Path: []any{arg}, Type: FindTypeArg}, true
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

	if name.Length() == 1 && name.First() == "self" {
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

func genVLen() *typeSys.StructField {
	sf := &typeSys.StructField{
		Name:   "len",
		Type:   typeSys.GetSystemType("int"),
		Offset: 0,
	}
	sf.Size = sf.Type.Size()
	sf.Alignment = sf.Type.Alignment()
	sf.Access = typeSys.AccessProtected
	sf.ParseTags("json:\"len\"")
	return sf
}

// lookupGlobalType 解析期跨文件/跨包类型查找（全局注册表）。
// 单段名（Time）按当前包路径查；路径名（time.Time）按导入解析包路径后查。
func lookupGlobalType(p *Parser, name Name) any {
	if p.Package == nil {
		return nil
	}
	if name.IsPath() {
		first := name[0]
		rest := ""
		for i, part := range name[1:] {
			if i > 0 {
				rest += "."
			}
			rest += part.Name
		}
		pkgPath := first.Name
		if !first.IsPkgPath {
			if p.Package.Imports == nil {
				return nil
			}
			real, ok := p.Package.Imports[first.Name]
			if !ok {
				return nil
			}
			pkgPath = real
		}
		return packageFmt.LookupType(pkgPath, rest)
	}
	return packageFmt.LookupType(p.Package.Path, name.String())
}

// findGlobalVar 跨文件/跨包全局变量查找（全局注册表 + AST 合并树）。
// 单段引用名匹配定义名末段（同包跨文件，如 SECOND）；
// 路径引用名（FixPath 后）与定义名（SetPkgPath 后）完全相等。
func findGlobalVar(p *Parser, name Name) (*Node, *VarBlock) {

	var children = []*Node{}
	n := name.Fork()
	pkgPath := ""
	if n.IsPath() {
		n.FixPath(p.Package)
		first := n[0]
		if first.IsPkgPath {
			pkgPath = first.Name
		} else if p.Package != nil && p.Package.Imports != nil {
			pkgPath = p.Package.Imports[first.Name]
		}
		if p.Package != nil && p.Package.AST != nil {
			children = p.Package.AST.(*Node).Children
		}
	} else if p.Block != nil {
		children = p.Block.Children
		if p.Package != nil {
			pkgPath = p.Package.Path
		}
	}
	// 全局注册表优先（编译期跨包内联展开场景，AST 合并树未必可见）
	if pkgPath != "" {
		t := packageFmt.LookupGlobalVar(pkgPath, n.Last())
		if t != nil {
			if vb, ok := t.(*VarBlock); ok && vb.IsDefine {
				return nil, vb
			}
		}
	}
	for i := len(children) - 1; i >= 0; i-- {
		child := children[i]
		if child.Value == nil {
			continue
		}
		if vb, ok := child.Value.(*VarBlock); ok {
			if !vb.IsDefine {
				continue
			}
			if n.IsPath() {
				if vb.Name.Eq(n) {
					return child, vb
				}
			} else if vb.Name.Last() == n.Last() {
				return child, vb
			}
		}
	}
	return nil, nil
}
