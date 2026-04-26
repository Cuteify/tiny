package parser

import (
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strings"
)

type CFGNode struct {
	After     *Node
	Before    *Node
	Condition *Expression
}

type Block interface {
	//Parse(p *Parser)
}

type Name []string

type Node struct {
	Value    Block
	Father   *Node
	Children []*Node
	Ignore   bool

	//CFG []CFGNode // 存储与该节点相关的CFG
	// Code string
	//CFG []CFGNode // 存储与该节点相关的CFG
	// Code string

	Checked bool
	Parser  *Parser
}

func (n *Node) Check() bool {
	if n.Checked && n.Father != nil {
		return true
	}
	n.Checked = true
	for _, child := range n.Children {
		if !child.Check() {
			return false
		}
	}
	switch n.Value.(type) {
	case *CallBlock:
		callBlock := n.Value.(*CallBlock)
		return callBlock.Check(n.Parser)
	case *VarBlock:
		varBlock := n.Value.(*VarBlock)
		return varBlock.Check(n.Parser)
	case *Expression:
		expression := n.Value.(*Expression)
		return expression.Check(n.Parser)
	case *FuncBlock:
		funcBlock := n.Value.(*FuncBlock)
		for _, arg := range funcBlock.Args {
			if !arg.Check(n.Parser) {
				return false
			}
		}
	case *IfBlock:
		ifBlock := n.Value.(*IfBlock)
		return ifBlock.Check(n.Parser)
	case *ForBlock:
		forBlock := n.Value.(*ForBlock)
		return forBlock.Check(n.Parser)
	// TODO: case *StructBlock:
	// TODO: 	structBlock := n.Value.(*StructBlock)
	// TODO: 	return structBlock.Check(n.Parser)
	}
	return true
}

func (n *Node) AddChild(node *Node) {
	n.Children = append(n.Children, node)
	node.Parser = n.Parser
	node.Father = n
	// 判断是否为转移或跳转节点，包括添加的子节点和目标父节点，如果不是将CFG的Before指向前一个节点，并将前一个的CFG的After指向该节点，都设为无条件转移
	/*if len(n.Children) == 1 {
		switch n.Value.(type) {
		case *IfBlock:
			// 添加CFG
			node.CFG = append(node.CFG, CFGNode{Before: n})
			n.CFG = append(n.CFG, CFGNode{After: node, Condition: n.Value.(*IfBlock).Condition})
		case *ElseBlock:
			// 添加CFG，添加到他的IfBlock的CFG中
			node.CFG = append(node.CFG, CFGNode{Before: n.Father})
			n.Father.CFG = append(n.Father.CFG, CFGNode{After: node, Condition: n.Value.(*ElseBlock).IfCondition})
		case *FuncBlock:
			node.CFG = append(node.CFG, CFGNode{Before: n})
			n.CFG = append(n.CFG, CFGNode{After: node})
		}
	} else {
		tmp := n.Children[len(n.Children)-2]
		switch tmp.Value.(type) {
		case *IfBlock:
			// 把他的子节点的最后一个的After指向该节点
			if len(tmp.Children) >= 1 {
				node.CFG = append(node.CFG, CFGNode{Before: tmp.Children[len(tmp.Children)-1], Condition: tmp.Value.(*IfBlock).Condition})
			} else {
				node.CFG = append(node.CFG, CFGNode{Before: n.Children[len(n.Children)-2]})
				tmp.CFG = append(n.CFG, CFGNode{After: node})
			}
			if tmp.Value.(*IfBlock).Else {
				if len(tmp.Value.(*IfBlock).ElseBlock.Children) >= 1 {
					node.CFG = append(node.CFG, CFGNode{Before: tmp.Value.(*IfBlock).ElseBlock.Children[len(tmp.Value.(*IfBlock).ElseBlock.Children)-1], Condition: tmp.Value.(*IfBlock).Condition})
				}
			}
		default:
			// before这是上个节点，after是下个节点
			node.CFG = append(node.CFG, CFGNode{Before: n.Children[len(n.Children)-2]})
			tmp.CFG = append(n.CFG, CFGNode{After: node})
		}
	}*/
}

func (n Name) String() string {
	return strings.Join(n, ".")
}

func (n Name) Path() string {
	return strings.Join(n[:len(n)-1], ".")
}

func (n Name) Last() string {
	return n[len(n)-1]
}

func (n Name) First() string {
	return n[0]
}

func (n Name) IsPrivate() bool {
	for _, part := range n {
		if part[0] == '_' {
			return true
		}
	}
	return false
}

func (n Name) Eq(other Name) bool {
	if len(n) != len(other) {
		return false
	}
	for i := 0; i < len(n); i++ {
		if n[i] != other[i] {
			return false
		}
	}
	return true
}

func (n Name) IsEmpty() bool {
	return len(n) == 0
}

func (n Name) IsPath() bool {
	return len(n) > 1
}

func (n Name) Check() bool {
	ok := !n.IsEmpty()
	for _, part := range n {
		ok = ok && utils.CheckName(part)
	}
	return ok
}

func (n *Name) ReadFromToken(t lexer.Token) bool {
	if t.Type == lexer.NAME {
		*n = append(*n, t.Value)
		return true
	}
	return false
}

func (n Name) Fork() Name {
	nn := make(Name, len(n))
	copy(nn, n)
	return nn
}

func (n Name) MatchN(name Name) int {
	// 模糊匹配，匹配前n个部分
	for i := 0; i < len(n); i++ {
		if len(name) > i || n[i] != name[i] {
			return i
		}
	}
	return len(name)

}

func (n Name) MatchT(name Name, valType typeSys.Type) bool {
	// 模糊匹配，匹配前n个部分
	nowType := valType
	for i := 0; i < len(n); i++ {
		if len(name) <= i {
			// 查看对应类型是否存在
			ok := false
			for _, field := range nowType.Fields() {
				if field.Name == name[i] {
					nowType = field.Type
					ok = true
					break
				}
			}
			if !ok {
				return false
			}
		}
		if n[i] != name[i] {
			return false
		}
	}
	return true
}

func (n Name) FixPath(pkg *packageFmt.Info) bool {
	if !n.IsPath() {
		return false
	}
	importName := n[0]
	pkgRealPath := packageFmt.FixPathName(pkg.Imports[importName])
	n[0] = pkgRealPath
	return true
}

func (n Name) SetPkgPath(pkgPath string) {
	n = append([]string{packageFmt.FixPathName(pkgPath)}, n...)
}

func (n *Name) Join(other ...string) {
	*n = append(*n, other...)
}

func (n Name) ForkJoin(other ...string) Name {
	nn := n.Fork()
	nn.Join(other...)
	return nn
}

// 裁切匹配路径部分
func (n *Name) Slice(other Name) {
	*n = (*n)[:n.MatchN(other)]
}

func (n Name) ForkSlice(other Name) Name {
	nn := n.Fork()
	nn.Slice(other)
	return nn
}

func NewName(parts ...string) Name {
	return Name(parts)
}
