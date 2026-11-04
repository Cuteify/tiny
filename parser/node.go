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

// blockNode Block → 包裹它的 Node 的全局反向索引。
//
// Block 接口本身不携带父指针，作用域（for/if/fn 体）却是 Block 而不是 Node，
// 后端要在某个块的尾部发代码时需要拿回该块的节点来定位位置，故建此索引。
// 键都是指针型 Block（VarBlock/FuncBlock/...），接口值可比较。
var blockNode = map[Block]*Node{}

// BlockNode 反查包裹 b 的节点；b 不在树里（如单态化深拷贝出的块）返回 nil。
func BlockNode(b Block) *Node {
	if b == nil {
		return nil
	}
	return blockNode[b]
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
// 注意：Check 返回 false 表示"本次还查不到（跨文件前向引用），稍后重试"，
// 不是致命错误（真正错误都会 MissError → panic）。因此这里绝不能中断遍历，
// 否则合并后的 rootNode.Check 第一个未解析节点之后的所有节点都会被跳过，
// 它们的类型永远停留在 nil，到后端 GenVarAddr 才 panic。
// 有子节点未通过时不置 Checked，留给下一轮 Check 重试。
func (n *Node) Check() bool {
	if n.Checked && n.Father != nil {
		return true

	}

	ok := true
	for _, child := range n.Children {
		if !child.Check() {
			ok = false
		}
	}

	if checker, okc := n.Value.(Checker); okc {
		if !checker.Check(n.Parser) {
			ok = false
		}
	}

	if ok {
		n.Checked = true
	}

	return ok
}

// isScopeBlock 这个块是否圈出一个作用域（变量的释放点候选）。
func isScopeBlock(b Block) bool {
	switch b.(type) {
	case *ForBlock, *IfBlock, *ElseBlock, *FuncBlock, *SwitchBlock, *CaseBlock:
		return true
	}
	return false
}

// IsScopeBlock 导出版：判断块是否圈定一个作用域。
// gcfe 的释放点与就地释放模拟需要与 parser 使用同一份判据。
func IsScopeBlock(b Block) bool { return isScopeBlock(b) }

// eachSubNode 按顺序遍历 n 的全部子节点：Children，以及挂在字段上的 else 体。
//
// IfBlock.ElseBlock 是结构体字段而非 Children（只有条件是编译期常量时才会被
// Replace 摊平进父节点）。只走 Children 会整个漏掉 else 分支 —— 里面的
// 分配、赋值、作用域一个都看不见。
func eachSubNode(n *Node, fn func(*Node)) {
	for _, c := range n.Children {
		fn(c)
	}
	if ib, ok := n.Value.(*IfBlock); ok && ib.ElseBlock != nil {
		fn(ib.ElseBlock)
	}
}

// EachSubNode 导出版：遍历 n 的全部子节点（Children + 挂在字段上的 else 体）。
// 工具与后端遍历 AST 时必须用它 —— 只走 Children 会漏掉整个 else 分支。
func EachSubNode(n *Node, fn func(*Node)) { eachSubNode(n, fn) }

// RebuildBlockIndex 重建 Block → Node 的反向索引。包合并时有一批节点是
// 直接挂到根上的（绕过 AddChild），新建的 AST 也可能没有索引；GC 后置
// 分析要在 parser 包外按 Block 反查祖先链，必须先整体重建一次。
func RebuildBlockIndex(root *Node) {
	if root == nil {
		return
	}
	var walk func(*Node)
	walk = func(n *Node) {
		if n == nil {
			return
		}
		if n.Value != nil {
			blockNode[n.Value] = n
		}
		eachSubNode(n, walk)
	}
	walk(root)
}

// AddChild 向当前节点添加子节点并建立父子关系
func (n *Node) AddChild(node *Node) {
	n.Children = append(n.Children, node)
	node.Father = n
	if node.Value != nil {
		blockNode[node.Value] = node
	}
	for p := n; p != nil; p = p.Father {
		if p.Parser != nil {
			node.Parser = p.Parser
			break
		}
	}
	if checker, ok := node.Value.(Checker); ok {
		checker.Check(node.Parser)
	}
	// 跨文件变量前向引用在解析期不可见（同包其它文件尚未合并），
	// 与下面的跨包调用一样保持未检查状态，留给 rootNode.Check() 重试
	if vb, ok := node.Value.(*VarBlock); ok && vb.Unresolved {
		node.Checked = false
		for f := node.Father; f != nil; f = f.Father {
			f.Checked = false
		}
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
