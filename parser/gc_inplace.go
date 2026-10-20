// parser/gc_inplace.go — 就地释放：这条赋值能不能提前 free
//
// 释放点（gc_release.go）答"最终在哪释放"，这里答"能不能提前"：等作用域
// 出口是对的但不及时。判定 = 写完之后旧对象还有没有任何槽位 / 字段指着
// —— 是非题，扫一遍答完。必须连字段一起看：
//
//	head = prepend(head, 4)   旧 head 的名字没了，但新节点的 .next 还指着它
//
// 只数变量会漏，漏了就是 use-after-free。槽位表（局部变量与各字段当前持有什么）
// 按语句顺序走一遍树，顺序敏感 —— 模拟的是"覆盖前先释放旧值"。刻意不做引用
// 计数：计数要多一张表、一套 inc/dec 和出口回退，换来的还是同一个答案。
//
// 前提：只处理帧内对象；帧外可达的由 Disposal 判 RC，不参与本模拟。

package parser

// rcScope 模拟中的一层作用域，记录本层声明的局部变量。
type rcScope struct {
	block Block
	vars  []*VarBlock
}

// rcSim 跟踪"此刻哪些槽位 / 字段还指着哪个对象"。
type rcSim struct {
	slot   map[*VarBlock]*Object            // 局部变量当前持有哪个对象
	fields map[*VarBlock]map[string]*Object // 容器各字段当前持有哪个对象
	stack  []*rcScope                       // 作用域栈（出口时清掉本层槽位）
}

// walk 按语句顺序走一遍（顺序敏感，与迭代次数无关）。
func (s *rcSim) walk(n *Node) {
	if n == nil {
		return
	}
	if isScopeBlock(n.Value) {
		sc := &rcScope{block: n.Value}
		s.stack = append(s.stack, sc)
		eachSubNode(n, s.walk)
		s.stack = s.stack[:len(s.stack)-1]
		s.leaveScope(sc) // 出作用域：本层槽位失效
		return
	}
	switch v := n.Value.(type) {
	case *VarBlock:
		s.stmt(v)
	case *CallBlock:
		s.call(v)
	}
	eachSubNode(n, s.walk)
}

// leaveScope 退出作用域：本层变量逐个失效，槽位删除。
func (s *rcSim) leaveScope(sc *rcScope) {
	for _, v := range sc.vars {
		o := s.slot[v]
		if o == nil {
			continue
		}
		delete(s.slot, v) // 本层变量出作用域：槽位失效
	}
}

// releasesOld 能就地释放 = 写完之后没有任何栈槽或字段指着它。
// 字段引用必须一起看：head = prepend(head, 4) 漏了就是 use-after-free。
func (s *rcSim) releasesOld(old *Object, at *VarBlock) {
	if at == nil || old == nil || old.Escapes || s.referenced(old) {
		return
	}
	at.Life.ReleasesOld = true
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

// slotOf 变量当前持有的对象；未初始化过则回退到 Life.Obj。
func (s *rcSim) slotOf(v *VarBlock) *Object {
	if o, ok := s.slot[v]; ok {
		return o
	}
	if l := LifeOf(v); l != nil {
		return l.Obj
	}
	return nil
}

// fieldVal 容器某字段当前持有的对象。
func (s *rcSim) fieldVal(base *VarBlock, field string) *Object {
	m := s.fields[base]
	if m == nil {
		return nil
	}
	return m[field]
}

func (s *rcSim) setField(base *VarBlock, field string, o *Object) {
	m := s.fields[base]
	if m == nil {
		m = map[string]*Object{}
		s.fields[base] = m
	}
	m[field] = o
}

// hostOf 变量绑定的宿主：赋值语句归到它的定义上，槽位按宿主唯一。
func hostOf(v *VarBlock) *VarBlock {
	if l := LifeOf(v); l != nil && l.owner != nil {
		return l.owner
	}
	return v
}

// stmt 一条变量语句：定义 / 赋值 / 字段写入。
func (s *rcSim) stmt(v *VarBlock) {
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
	host := hostOf(v)
	if host == nil || !s.tracked(v) {
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
	case freshAllocExpr(v.Value):
		// 这条分配语句自己的对象（多处 new 是不同对象）；Transferred 同 Escapes
		// 一样不进本系统：所有权已交调用者，本帧不释放也不参与计数
		o := v.Life.alloc
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
func (s *rcSim) tracked(v *VarBlock) bool {
	if isRCExpr(v.Value) {
		return false
	}
	h := hostOf(v)
	if h == nil {
		return false
	}
	if l := LifeOf(h); l != nil && l.owner == nil {
		return false // 参数
	}
	return true
}

// evalCopy 求值出一个新引用（只认裸变量），判据必须与 bareRef 一致：
// 字段读 / 索引 / 调用结果指向的是**基对象**，算成裸引用会把引用记到基对象
// 头上 → 引用虚高 → 释放点推后 → 泄漏。
func (s *rcSim) evalCopy(e *Expression) *Object {
	l := bareRef(e)
	if l == nil {
		return nil
	}
	o := s.slotOf(hostOf(l.owner))
	if o != nil && o.Escapes {
		return nil // 逃逸对象的引用不参与模拟
	}
	return o
}

// fieldWrite p.f = y：字段旧值失去引用，新的接管。
func (s *rcSim) fieldWrite(v *VarBlock) {
	field := v.Name.Last()
	base := fieldBaseOf(s.cur(), v)
	if base == nil {
		return
	}
	host := hostOf(base)
	if host == nil {
		return
	}
	if old := s.fieldVal(host, field); old != nil {
		s.setField(host, field, nil) // 先摘掉这个字段
		s.releasesOld(old, v)
	}
	if o := s.evalCopy(v.Value); o != nil {
		s.setField(host, field, o)
	}
}

// call 空维护："实参被被调方存下"由摘要判逃逸（Check 期），逃逸对象本来就
// 进不了槽位表（o.Escapes 过滤）。
func (s *rcSim) call(cb *CallBlock) {
	_ = cb
}

// cur 当前作用域（作用域栈顶）。
func (s *rcSim) cur() Block {
	if len(s.stack) == 0 {
		return nil
	}
	return s.stack[len(s.stack)-1].block
}

// declare 登记到当前作用域层，出口时对它失效。
func (s *rcSim) declare(v *VarBlock) {
	if len(s.stack) == 0 {
		return
	}
	sc := s.stack[len(s.stack)-1]
	sc.vars = append(sc.vars, v)
}
