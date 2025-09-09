package parser

type CFGNode struct {
	After     *Node
	Before    *Node
	Condition *Expression
}

type Block interface {
	//Parse(p *Parser)
}

type Node struct {
	Value    Block
	Father   *Node
	Children []*Node

	CFG []CFGNode // 存储与该节点相关的CFG

	Checked bool
}

func (n *Node) Check(p *Parser) {
	if n.Checked {
		return
	}
	n.Checked = true
	for _, child := range n.Children {
		child.Check(p)
	}
	switch n.Value.(type) {
	case *CallBlock:
		callBlock := n.Value.(*CallBlock)
		callBlock.Check(p)
	}
}

func (n *Node) AddChild(node *Node) {
	n.Children = append(n.Children, node)
	node.Father = n
	// 判断是否为转移或跳转节点，包括添加的子节点和目标父节点，如果不是将CFG的Before指向前一个节点，并将前一个的CFG的After指向该节点，都设为无条件转移
	if len(n.Children) == 1 {
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
	}
}
