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

type Checker interface {
	Check(p *Parser) bool
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

// Check 递归检查节点及其子节点的语义有效性
func (n *Node) Check() bool {
	if n.Checked && n.Father != nil {
		return true

	}

	for _, child := range n.Children {
		if !child.Check() {
			return false
		}
	}

	if checker, ok := n.Value.(Checker); ok {
		if !checker.Check(n.Parser) {
			return false
		}
	}

	n.Checked = true

	return true
}

// AddChild 向当前节点添加子节点并建立父子关系
func (n *Node) AddChild(node *Node) {
	n.Children = append(n.Children, node)
	node.Parser = n.Parser
	node.Father = n
	if checker, ok := node.Value.(Checker); ok {
		checker.Check(n.Parser)
	}
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

// String 返回名称的点分连接形式（NASM 安全格式）
func (n Name) String() string {
	return utils.ToNASMName(strings.Join(n, "."))
}

// Path 返回名称的路径部分（除最后一部分外的点分连接）
func (n Name) Path() string {
	return utils.ToNASMName(strings.Join(n[:len(n)-1], "."))
}

// Last 返回名称的最后一部分
func (n Name) Last() string {
	return n[len(n)-1]
}

// First 返回名称的第一部分
func (n Name) First() string {
	return n[0]
}

// IsPrivate 判断名称是否包含以下划线开头的私有部分
func (n Name) IsPrivate() bool {
	for _, part := range n {
		if part[0] == '_' {
			return true
		}
	}
	return false
}

// Eq 判断两个名称是否完全相等
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

// IsEmpty 判断名称是否为空
func (n Name) IsEmpty() bool {
	return len(n) == 0
}

// IsPath 判断名称是否为多段路径
func (n Name) IsPath() bool {
	return len(n) > 1
}

// Check 检查名称各部分是否均为有效标识符
func (n Name) Check() bool {
	ok := !n.IsEmpty()
	for _, part := range n {
		ok = ok && utils.CheckName(part)
	}
	return ok
}

// ReadFromToken 从词法 Token 中读取名称部分
func (n *Name) ReadFromToken(t lexer.Token) bool {
	if t.Type == lexer.NAME {
		*n = append(*n, t.Value)
		return true
	}
	return false
}

// Fork 创建名称的深拷贝
func (n Name) Fork() Name {
	nn := make(Name, len(n))
	copy(nn, n)
	return nn
}

// MatchN 模糊匹配名称前缀，返回匹配的段数
func (n Name) MatchN(name Name) int {
	// 模糊匹配，匹配前n个部分
	for i := 0; i < len(n); i++ {
		if len(name) > i || n[i] != name[i] {
			return i
		}
	}
	return len(name)

}

// MatchT 按类型层级模糊匹配名称
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

// FixPath 将名称的第一段替换为包导入的实际路径
func (n Name) FixPath(pkg *packageFmt.Info) bool {
	if !n.IsPath() {
		return false
	}
	importName := n[0]
	pkgRealPath := packageFmt.FixPathName(pkg.Imports[importName])
	n[0] = pkgRealPath
	return true
}

// SetPkgPath 在名称前添加包路径前缀
func (n Name) SetPkgPath(pkgPath string) {
	n = append([]string{packageFmt.FixPathName(pkgPath)}, n...)
}

// Join 向名称追加更多段
func (n *Name) Join(other ...string) {
	*n = append(*n, other...)
}

// ForkJoin 创建名称拷贝后追加更多段
func (n Name) ForkJoin(other ...string) Name {
	nn := n.Fork()
	nn.Join(other...)
	return nn
}

// Slice 裁切名称中匹配 other 的前缀部分
func (n *Name) Slice(other Name) {
	*n = (*n)[:n.MatchN(other)]
}

// ForkSlice 创建名称拷贝后裁切匹配前缀
func (n Name) ForkSlice(other Name) Name {
	nn := n.Fork()
	nn.Slice(other)
	return nn
}

// NewName 从字符串列表创建 Name
func NewName(parts ...string) Name {
	return Name(parts)
}
