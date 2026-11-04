// gc/inplace.go — 就地释放：这条赋值能不能提前 free
//
// 释放点（release.go）答“最终在哪释放”，这里答“能不能提前”：等作用域
// 出口是对的但不及时。判定 = 写完之后旧对象还有没有任何槽位 / 字段指着
// —— 是非题，扫一遍答完。必须连字段一起看：
//
//	head = prepend(head, 4)   旧 head 的名字没了，但新节点的 .next 还指着它
//
// 只数变量会漏，漏了就是 use-after-free。槽位表（局部变量与各字段当前持有什么）
// 按语句顺序走一遍树，顺序敏感 —— 模拟的是“覆盖前先释放旧值”。刻意不做引用
// 计数：计数要多一张表、一套 inc/dec 和出口回退，换来的还是同一个答案。
//
// 前提：只处理帧内对象；帧外可达的由 Disposal 判 RC，不参与本模拟。

package gc

import "cuteify/parser"

// rcScope 模拟中的一层作用域，记录本层声明的局部变量。
type rcScope struct {
	vars []*parser.VarBlock
}

// rcSim 跟踪“此刻哪些槽位 / 字段还指着哪个对象”。
type rcSim struct {
	a      *analysis
	slot   map[*parser.VarBlock]*Object            // 局部变量当前持有哪个对象
	fields map[*parser.VarBlock]map[string]*Object // 容器各字段当前持有哪个对象
	stack  []*rcScope                              // 作用域栈（出口时清掉本层槽位）
}

// walk 按语句顺序走一遍（顺序敏感，与迭代次数无关）。调用点不处理：“实参被
// 被调方存下”由跨函数摘要判逃逸（事实收集期），逃逸对象本来进不了槽位表。
func (s *rcSim) walk(n *parser.Node) {
	if n == nil {
		return
	}
	if parser.IsScopeBlock(n.Value) {
		sc := &rcScope{}
		s.stack = append(s.stack, sc)
		parser.EachSubNode(n, s.walk)
		s.stack = s.stack[:len(s.stack)-1]
		s.leaveScope(sc) // 出作用域：本层槽位失效
		return
	}
	if v, ok := n.Value.(*parser.VarBlock); ok {
		s.stmt(v)
	}
	parser.EachSubNode(n, s.walk)
}

// leaveScope 退出作用域：本层变量逐个失效，槽位删除。
func (s *rcSim) leaveScope(sc *rcScope) {
	for _, v := range sc.vars {
		delete(s.slot, v) // 缺键时 delete 是 no-op
	}
}

// releasesOld 能就地释放 = 写完之后没有任何栈槽或字段指着它。
// 字段引用必须一起看：head = prepend(head, 4) 漏了就是 use-after-free。
func (s *rcSim) releasesOld(old *Object, at *parser.VarBlock) {
	if at == nil || old == nil || old.Inplace || old.Escapes || old.Transferred || s.referenced(old) {
		return
	}
	s.a.state(at).releasesOld = true
	old.Inplace = true // 与作用域释放互斥；scopeRelease 会跳过它
}

// referenced 此刻是否还有任何栈位或字段指着 o。
func (s *rcSim) referenced(o *Object) bool {
	for _, v := range s.slot {
		if v == o {
			return true
		}
	}
	for _, fs := range s.fields {
		for _, v := range fs {
			if v == o {
				return true
			}
		}
	}
	return false
}

// slotOf 变量当前持有的对象；未初始化过则回退到 binding.obj。
func (s *rcSim) slotOf(v *parser.VarBlock) *Object {
	if o, ok := s.slot[v]; ok {
		return o
	}
	if l := s.a.lifeOf(v); l != nil {
		return l.obj
	}
	return nil
}

// fieldVal 容器某字段当前持有的对象。
func (s *rcSim) fieldVal(base *parser.VarBlock, field string) *Object {
	m := s.fields[base]
	if m == nil {
		return nil
	}
	return m[field]
}

func (s *rcSim) setField(base *parser.VarBlock, field string, o *Object) {
	m := s.fields[base]
	if m == nil {
		m = map[string]*Object{}
		s.fields[base] = m
	}
	m[field] = o
}

// stmt 一条变量语句：定义 / 赋值 / 字段写入。
func (s *rcSim) stmt(v *parser.VarBlock) {
	if v.Type != nil && !owningType(v.Type) {
		return
	}
	if v.IsGlobal {
		return // 全局不在帧内，Disposal 判为 RC
	}
	if !v.IsDefine && len(v.Name) > 1 {
		s.fieldWrite(v)
		return
	}
	host := s.a.hostOf(v)
	if !s.tracked(v, host) {
		return
	}

	// 覆盖：旧值先失去这一个引用
	if old, ok := s.slot[host]; ok && old != nil {
		delete(s.slot, host)  // 先摘掉这个槽位
		s.releasesOld(old, v) // 再看它还有没有别人指着
	}

	// 定义即登记到本作用域层，出口时统一失效。必须无条件登记：
	// `var head: *T = nil` 这种先声明后赋值的槽位，此刻还没有对象，
	// 但它随后会拿到对象，出口时那个对象要靠这一条来清。
	if v.IsDefine {
		s.declare(host)
	}

	// 取新值
	switch {
	case s.a.freshAllocExpr(v.Value):
		// 这条分配语句自己的对象（多处 new 是不同对象）；Transferred 同 Escapes
		// 一样不进本系统：所有权已交调用者，本帧不释放也不参与计数
		o := s.a.state(v).alloc
		if o == nil || o.Escapes || o.Transferred {
			return
		}
		s.slot[host] = o
	case isRCExpr(v.Value):
		return // newRC：手动 rcDec 管生命周期，不进本系统
	default:
		if o := s.evalCopy(v.Value); o != nil { // 裸变量 → 复制一份指针
			s.slot[host] = o
		}
	}
}

// tracked 这条语句涉及的对象是否参与模拟（参数与 newRC 不参与）。
// host 已由 stmt 算好传入，这里不重算（它永不返回 nil）。
func (s *rcSim) tracked(v, host *parser.VarBlock) bool {
	if isRCExpr(v.Value) {
		return false
	}
	if l := s.a.lifeOf(host); l != nil && l.owner == nil {
		return false // 参数
	}
	return true
}

// evalCopy 求值出一个新引用（只认裸变量），判据必须与 bareRef 一致：
// 字段读 / 索引 / 调用结果指向的是**基对象**，算成裸引用会把引用记到基对象
// 头上 → 引用虚高 → 释放点推后 → 泄漏。
func (s *rcSim) evalCopy(e *parser.Expression) *Object {
	l := s.a.bareRef(e)
	if l == nil {
		return nil
	}
	o := s.slotOf(s.a.hostOf(l.owner))
	if o != nil && o.Escapes {
		return nil // 逃逸对象的引用不参与模拟
	}
	return o
}

// fieldWrite p.f = y：字段旧值失去引用，新的接管。
func (s *rcSim) fieldWrite(v *parser.VarBlock) {
	field := v.Name.Last()

	// 解析字段写入的基对象（p.f 中的 p）：从解析期 Path 里取首个非全局
	// *VarBlock；全局容器 / 参数容器认不出，模拟直接跳过（多标方向）。
	var base *parser.VarBlock
	for _, p := range v.Define.Path {
		if vb, ok := p.(*parser.VarBlock); ok && !vb.IsGlobal {
			base = vb
			break
		}
	}
	if base == nil {
		return
	}
	host := s.a.hostOf(base) // hostOf 永不返回 nil，直接用
	if old := s.fieldVal(host, field); old != nil {
		s.setField(host, field, nil) // 先摘掉这个字段
		s.releasesOld(old, v)
	}
	if o := s.evalCopy(v.Value); o != nil {
		s.setField(host, field, o)
	}
}

// declare 把变量登记到当前作用域层，出口时对它失效。
func (s *rcSim) declare(v *parser.VarBlock) {
	if len(s.stack) == 0 {
		return
	}
	sc := s.stack[len(s.stack)-1]
	sc.vars = append(sc.vars, v)
}
