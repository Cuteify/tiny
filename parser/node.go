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
	node.Father = n
	for p := n; p != nil; p = p.Father {
		if p.Parser != nil {
			node.Parser = p.Parser
			break
		}
	}
	if checker, ok := node.Value.(Checker); ok {
		checker.Check(node.Parser)
	}
	// 跨包调用在解析期不可见（包函数尚未合并），保持未检查状态，
	// 等待所有包合并后的 rootNode.Check() 重试解析
	if cb, ok := node.Value.(*CallBlock); ok {
		if cb.Func == nil && cb.Name.IsPath() {
			node.Checked = false
			for f := node.Father; f != nil; f = f.Father {
				f.Checked = false
			}
		}
	}
}

func (n *Node) Replace(newNodes ...*Node) {
	children := n.Father.Children
	for i, child := range children {
		if child == n {
			n.Father.Children = make([]*Node, 0, len(children)+len(newNodes)-1)
			n.Father.Children = append(n.Father.Children, children[:i]...)
			for _, node := range newNodes {
				n.Father.AddChild(node)
			}
			if i < len(children)-1 {
				n.Father.Children = append(n.Father.Children, children[i+1:]...)
			}
			break
		}
	}
}
