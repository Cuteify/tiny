package parser

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

type Node struct {
	Value    Block
	Father   *Node
	Children []*Node
	Ignore   bool

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
}
