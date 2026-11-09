package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strconv"
)

// CallBlock 函数调用结构体
type CallBlock struct {
	Name         Name
	Args         []*ArgBlock
	Func         *FuncBlock
	Node         *Node
	ThisVar      *VarBlock
	NewType      typeSys.Type // new(T) 的目标类型（内建堆对象创建）
	NewTypes     []typeSys.Type // 泛型调用的显式类型实参 f[T, U](…)；单类型退化为 NewType 同表
	ConvertType  typeSys.Type // int(x)/f64(x) 等显式数值转换的目标类型
	IsRC         bool         // 是否为 RC（引用计数）调用
	IsVariadic   bool         // 调用是否包含变参参数
	VariadicType typeSys.Type // 变参参数的元素类型
	VariadicArgs []*ArgBlock  // 变参参数列表
}

// safeTypeName nil 安全的类型名（首趟未解析的跨包调用实参 Type 为 nil）
func safeTypeName(t typeSys.Type) string {
	if t == nil {
		return "<unresolved>"
	}
	return t.Type()
}

// collectCallCandidates 收集同名函数候选（去重、跳过当前目标平台忽略的定义）。
func collectCallCandidates(p *Parser, name Name) []*FuncBlock {
	var out []*FuncBlock
	if p == nil || name.IsEmpty() {
		return out
	}
	seen := map[*FuncBlock]bool{}
	for _, node := range p.Find(name, FindTypeFunc) {
		fb, ok := node.Value.(*FuncBlock)
		if !ok || fb == nil || funcBuildIgnored(fb) || seen[fb] {
			continue
		}
		seen[fb] = true
		out = append(out, fb)
	}
	return out
}

// appendUniqueFuncs 按指针去重追加候选。
func appendUniqueFuncs(dst []*FuncBlock, fbs ...*FuncBlock) []*FuncBlock {
	if len(fbs) == 0 {
		return dst
	}
	seen := make(map[*FuncBlock]bool, len(dst)+len(fbs))
	for _, f := range dst {
		seen[f] = true
	}
	for _, f := range fbs {
		if f == nil || seen[f] || funcBuildIgnored(f) {
			continue
		}
		seen[f] = true
		dst = append(dst, f)
	}
	return dst
}

// receiverNameCheckable 报告路径的每个段都是合法标识符（可交给 ParseDefine 解析）。
// /home/.../pkg.fn 这类包路径含 '/' 的段不合法——跳过，避免 CheckName 报错；
// 带 Slice 的段（a[0].m() 作为列表元素接收者）合法，交给 Find/codegen 的索引链处理。
func receiverNameCheckable(name Name) bool {
	for _, part := range name {
		if part.Name == "" {
			return false
		}
		if !utils.CheckName(part.Name) {
			return false
		}
	}
	return true
}

// methodCandidates 收集接收者类型上所有同名方法（含重载）。
// enterTypeFind 只返回 Methods() 里第一个命中项，无法支撑同 arity 方法重载。
func methodCandidates(t typeSys.Type, method string) []*FuncBlock {
	for t != nil && t.IsPointer() {
		t = t.Elem()
	}
	if t == nil {
		return nil
	}
	var out []*FuncBlock
	for _, m := range t.Methods() {
		fb, ok := m.(*FuncBlock)
		if !ok || fb == nil || funcBuildIgnored(fb) {
			continue
		}
		if fb.Name.Last() == method {
			out = append(out, fb)
		}
	}
	return out
}

// applyReceiverConversion 按选中候选的接收者形态做 P ↔ *P 转换（编译器自动取址/解引用）。
func applyReceiverConversion(call *CallBlock, sel *FuncBlock, receiver *Expression) {
	if call == nil || sel == nil || receiver == nil || len(sel.Args) == 0 || len(call.Args) == 0 {
		return
	}
	want := sel.Args[0].Type
	recvT := receiver.Type
	if want == nil || recvT == nil || want.IsPointer() == recvT.IsPointer() {
		return
	}
	if want.IsPointer() {
		// 方法要 *T，接收者是 T（路径 lvalue）→ 取地址
		call.Args[0].Value = &Expression{Separator: "&", Right: receiver, Type: want}
		call.Args[0].Type = want
		return
	}
	// 方法要 T（值），接收者是 *T → 解引用
	call.Args[0].Value = &Expression{Separator: "*", Right: receiver, Type: want}
	call.Args[0].Type = want
}

// recvPtrCompatible 报告 P ↔ *P 接收者形态是否匹配（按元素类型名比较）。
func recvPtrCompatible(at, dt typeSys.Type) bool {
	if at == nil || dt == nil {
		return false
	}
	if at.IsPointer() == dt.IsPointer() {
		return false // 同形：走 AutoType
	}
	if at.IsPointer() {
		elem := at.Elem()
		return elem != nil && elem.Type() == dt.Type()
	}
	elem := dt.Elem()
	return elem != nil && elem.Type() == at.Type()
}

func absInt(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

const (
	callScoreExactArity = 1 << 20
	callScoreExactType  = 100
	callScoreSameKind   = 40
	callScoreNumeric    = 10
	callScoreAssignable = 1
)

// matchCallCandidate 判断实参与候选函数是否兼容，并给出消歧分。
// 类型未知（跨文件未解析）的实参不参与判负，只降低可比较度。
func matchCallCandidate(c *CallBlock, fb *FuncBlock) (ok bool, score int) {
	if c == nil || fb == nil {
		return false, 0
	}
	n := len(c.Args)
	last := len(fb.Args) - 1
	isVariadic := last >= 0 && fb.Args[last] != nil && fb.Args[last].IsVariadic
	var elemType typeSys.Type
	if isVariadic {
		if lt, ok := fb.Args[last].Type.(*typeSys.ListType); ok {
			elemType = lt.Elem()
		}
	}
	if n > len(fb.Args) && !isVariadic {
		return false, 0
	}
	// 缺少的形参必须有默认值；变参形参可以整体省略
	for i := n; i < len(fb.Args); i++ {
		if i == last && isVariadic {
			continue
		}
		if fb.Args[i] == nil || fb.Args[i].Default == nil {
			return false, 0
		}
	}
	if n == len(fb.Args) {
		score += callScoreExactArity
	} else {
		score -= (absInt(len(fb.Args)-n)) * 1000
	}
	for i := 0; i < n; i++ {
		arg := c.Args[i]
		if arg == nil || arg.Value == nil {
			continue
		}
		at := arg.Value.Type
		var dt typeSys.Type
		switch {
		case i < last || (i == last && !isVariadic):
			if i < len(fb.Args) && fb.Args[i] != nil {
				dt = fb.Args[i].Type
			}
		default:
			dt = elemType
		}
		if at == nil || dt == nil {
			continue
		}
		if !typeSys.AutoType(at, dt, true) {
			// 接收者位置允许 P ↔ *P 互转：方法调用是隐式取址/解引用的，
			// 按“可赋值”记分（精确形态由 sameTypeShape 分支继续打分）。
			if i == 0 && fb.Class != nil && recvPtrCompatible(at, dt) {
				score += callScoreAssignable
				continue
			}
			return false, 0
		}
		switch {
		case sameTypeShape(at, dt):
			score += callScoreExactType
		case at.Type() == dt.Type():
			score += callScoreExactType / 2
		case at.Kind() == dt.Kind():
			score += callScoreSameKind
		case typeSys.IsNum(at) && typeSys.IsNum(dt):
			score += callScoreNumeric
		default:
			score += callScoreAssignable
		}
	}
	return true, score
}

// selectCallCandidate 从候选中选一个。
// compatible 是兼容候选数；ambiguous 表示实参类型已知但最高分仍无法唯一确定。
func selectCallCandidate(c *CallBlock, candidates []*FuncBlock) (sel *FuncBlock, compatible int, ambiguous bool) {
	type scored struct {
		fb    *FuncBlock
		score int
	}
	var best []scored
	allKnown := true
	for _, arg := range c.Args {
		if arg == nil || arg.Value == nil || arg.Value.Type == nil {
			allKnown = false
			break
		}
	}
	for _, fb := range candidates {
		ok, sc := matchCallCandidate(c, fb)
		if !ok {
			continue
		}
		compatible++
		if len(best) == 0 || sc > best[0].score {
			best = append(best[:0], scored{fb: fb, score: sc})
		} else if sc == best[0].score {
			best = append(best, scored{fb: fb, score: sc})
		}
	}
	if len(best) == 0 {
		return nil, compatible, false
	}
	if len(best) == 1 || !allKnown {
		return best[0].fb, compatible, false
	}
	// 同分且实参类型已知：签名完全相同（重复定义）时取第一个，
	// 签名不同则说明打分器无法可靠区分 → 歧义。
	for _, b := range best[1:] {
		if !sameFuncSignature(best[0].fb, b.fb) {
			return nil, compatible, true
		}
	}
	return best[0].fb, compatible, false
}

// pathBuiltinCalls 由 codegen 直接分派、不绑定 FuncBlock 的路径名内建调用。
// 这些名字没有对应的真实函数定义，最终 Check 不能按“未解析跨包调用”报错。
var pathBuiltinCalls = map[string]bool{
	"unsafe.cast":   true,
	"memory.new":    true,
	"memory.sizeof": true,
}

// Check 检查函数调用的参数数量和类型是否匹配
func (c *CallBlock) Check(p *Parser) bool {
	if c.Name.IsEmpty() {
		p.Error.MissError("Call Error", p.Lexer.Cursor, "function name is empty")
		return false
	}

	if c.checkBuiltin(p) {
		return true
	}

	// 函数重载 Phase 2：先收集全部同名候选，再按 arity / 实参类型选择。
	// 不能像旧实现那样“取第一个并顺手把所有同名函数标 Useful”，
	// 否则同名不同 arity 的调用会绑定到错误定义，或产生重复汇编标签。
	var candidates []*FuncBlock
	if c.Func == nil {
		candidates = collectCallCandidates(p, c.Name)
	}

	// 内置包兜底：无命名空间调用（print(...)）→ 注册表直接定位函数块。
	// 本地/用户函数优先：仅在上方查找失败后进入。
	if c.Func == nil && c.ThisVar == nil && len(candidates) == 0 && !c.Name.IsPath() {
		if fb, ok := BuiltinFuncs[c.Name.First()]; ok && !funcBuildIgnored(fb) {
			candidates = append(candidates, fb)
		}
	}

	// 函数指针局部变量：f(x) —— 局部变量优先于同名函数。
	// 绑定为 ThisVar（Type.Kind()=="func"），由 arch 走 isIndirect 间接调用；
	// 合成 FuncFunc 形参表，让实参检查照常跑。
	// 只认“真变量”（Define.Type ∈ {Var, Arg}）；裸函数名（Define.Type == Func）
	// 也是 FuncType —— 那是函数引用，不是变量调用。
	if c.Func == nil && c.ThisVar == nil && c.Name.Length() == 1 && !c.Name.IsPath() {
		vb := &VarBlock{Name: c.Name}
		vb.ParseDefine(p)
		if vb.Type != nil && vb.Type.Kind() == "func" &&
			(vb.Define.Type == FindTypeVar || vb.Define.Type == FindTypeArg) {
			c.ThisVar = vb
			// 合成函数签名（argType 来自 FuncType），供实参个数/类型检查使用
			if fType, ok := vb.Type.(*typeSys.FuncType); ok {
				fb := &FuncBlock{Name: c.Name, Return: append([]typeSys.Type{}, fType.Returns...)}
				for i, a := range fType.Args {
					fb.Args = append(fb.Args, &ArgBlock{Type: a, Name: NewName("arg" + strconv.Itoa(i))})
				}
				c.Func = fb
				for _, arg := range c.Args {
					if arg != nil && arg.Value != nil {
						arg.Value.Check(p)
					}
				}
				return c.finishCallCheck(p)
			}
		}
	}

	// 方法调用（候选属于类型）：接收者 = 点号左边的路径（a.b.m() → a.b）。
	// 调用点把接收者作为第一个参数显式传入（编译器自动传入第一个参数）。
	// 列表内建 len/cap/ptr 不走本路径：保留 ThisVar 通道（arch 按 ThisVar.Kind()=="list" 直分派）。
	// 非路径接收者（如 f().m()）无法取地址/重入，保持原路（按普通名报错）。
	var receiverExp *Expression
	if c.Func == nil && c.ThisVar == nil && c.Name.IsPath() {
		methodName := c.Name.Last()
		receiverName := c.Name.Fork()
		receiverName = receiverName[:len(receiverName)-1]
		if receiverName.Length() > 0 && receiverNameCheckable(receiverName) {
			// 注：包路径（/home/.../memory.store64）含 '/' → IsPath()==true，
			// 不会走进这里；本分支只处理 "a.b.m" 形式中的 a.b。
			recv := &VarBlock{Name: receiverName}
			recv.ParseDefine(p)
			receiverExp = &Expression{Var: recv}
			receiverExp.Check(p) // 填充 Type（仅供打分/方法查找；失败不致命）
			recvType := receiverExp.Type
			if recvType == nil {
				// 跨文件/跨包未解析：报告 nil（ref 可能是变量而非包路径）——
				// 退化为普通名解析（后续 Argument 检查会对齐报错）。
				results := p.Find(receiverExp.Var.Name, FindTypeVar|FindTypeItem)
				if len(results) > 0 {
					if vb, ok := results[0].Value.(*VarBlock); ok {
						receiverExp.Var = vb
						recvType = vb.Type
					} else if arg, ok := results[0].Value.(*ArgBlock); ok {
						receiverExp.Var = &VarBlock{Name: arg.Name, Type: arg.Type}
						recvType = arg.Type
					}
				}
			}
			switch {
			case recvType != nil && recvType.Kind() == "list":
				switch methodName {
				case "len", "cap", "ptr":
					// 列表内建：保持旧的 ThisVar 通道（arch 直分派到 __list_*）
					c.ThisVar = receiverExp.Var
					if len(candidates) == 0 {
						c.Func = &FuncBlock{
							Return: []typeSys.Type{typeSys.GetSystemType("int")},
							Name:   NewName("__list_" + methodName),
						}
					}
					receiverExp = nil
				}
			case recvType == nil:
				receiverExp = nil
			}
			if receiverExp != nil {
				ms := methodCandidates(recvType, methodName)
				if len(ms) == 0 {
					receiverExp = nil // 不是方法调用：按普通名解析（pkg.fn 或报错）
				} else {
					candidates = appendUniqueFuncs(candidates, ms...)
				}
			}
		}
	}

	// 接收者作为第一个参数显式传入（编译器自动传入第一个参数）。
	if receiverExp != nil {
		arg := &ArgBlock{Value: receiverExp, Name: receiverExp.Var.Name, Type: receiverExp.Type}
		c.Args = append([]*ArgBlock{arg}, c.Args...)
	}

	if c.Func == nil && c.ThisVar == nil && len(candidates) > 0 {
		// 消歧需要实参类型：先做 Check（幂等），跨文件未解析的类型保持 nil，
		// 打分器会把它当作“未知”而不是“不匹配”。
		for _, arg := range c.Args {
			if arg != nil && arg.Value != nil {
				arg.Value.Check(p)
			}
		}
		sel, compatible, ambiguous := selectCallCandidate(c, candidates)
		if sel == nil {
			if p.FinalCheck {
				if ambiguous {
					p.Error.MissError("Call Error", p.Lexer.Cursor,
						"ambiguous call to "+c.Name.String()+": "+itoa(len(candidates))+" overloads match")
					return false
				}
				if compatible == 0 {
					p.Error.MissError("Call Error", p.Lexer.Cursor,
						"no matching overload for "+c.Name.String()+" with "+itoa(len(c.Args))+" arguments")
					return false
				}
			}
			// 解析期：可能还有同名定义尚未解析到，留给合并后的 Check 重试。
			return false
		}
		c.Func = sel
		if receiverExp != nil && sel.Class != nil && len(sel.Args) > 0 && len(c.Args) > 0 {
			// 按选中候选的接收者形态做 P ↔ *P 转换（编译器自动取址/解引用）。
			applyReceiverConversion(c, sel, receiverExp)
		}
		c.ThisVar = nil
	}

	if c.Func == nil {
		if c.Name.IsPath() {
			// 跨包调用：包函数在全部包解析完成合并后才可见，
			// 解析期静默返回，由合并后的 rootNode.Check() 重试解析。
			// 最终 Check 仍解析不到，说明包没有显式 import（或函数不存在）：
			// 必须报错，不能静默生成空调用。
			if p.FinalCheck && !pathBuiltinCalls[c.Name.String()] {
				p.Error.MissError("Call Error", p.Lexer.Cursor, "not found function '"+c.Name.String()+"'")
				return false
			}
			return true
		}
		if p.Block == p.ThisBlock {
			p.Error.MissError("Call Error", p.Lexer.Cursor, "not found function '"+c.Name.String()+"'")
		}
		return false
	}

	c.Func.Useful = true

	return c.finishCallCheck(p)
}

// finishCallCheck 参数个数/默认参数/变参拆分/逐参类型检查（普通调用与函数指针调用共用）。
func (c *CallBlock) finishCallCheck(p *Parser) bool {
	// 检查参数个数是否匹配（考虑默认参数与变参形参）
	if len(c.Func.Args) > 0 {
		last := len(c.Func.Args) - 1
		if !(c.Func.Args[last] != nil && c.Func.Args[last].IsVariadic) && len(c.Args) > len(c.Func.Args) {
			p.Error.MissError("Call Error", p.Lexer.Cursor, "too many arguments in call to "+c.Name.String())
			return false
		}
	}

	// 处理默认参数
	if len(c.Func.Args) > 0 {
		last := len(c.Func.Args) - 1
		variadicLast := c.Func.Args[last] != nil && c.Func.Args[last].IsVariadic
		if len(c.Args) < len(c.Func.Args) {
			for i := len(c.Args); i < len(c.Func.Args); i++ {
				if i == last && variadicLast {
					// 变参整体省略：留空
					break
				}
				if c.Func.Args[i].Default == nil {
					p.Error.MissError("Call Error", p.Lexer.Cursor, "not enough arguments in call to "+c.Name.String())
					return false
				}
				// 添加默认参数
				c.Args = append(c.Args, &ArgBlock{
					Value:  c.Func.Args[i].Default,
					Defind: c.Func.Args[i],
					Name:   c.Func.Args[i].Name,
					Type:   c.Func.Args[i].Type,
				})
			}
		}
	}
	// 变参拆分：把超出固定形参数量的实参收进 VariadicArgs
	if len(c.Func.Args) > 0 {
		last := len(c.Func.Args) - 1
		if c.Func.Args[last] != nil && c.Func.Args[last].IsVariadic && len(c.Args) > last {
			c.IsVariadic = true
			if lt, ok := c.Func.Args[last].Type.(*typeSys.ListType); ok {
				c.VariadicType = lt.Elem()
			}
			c.VariadicArgs = c.Args[last:]
			c.Args = c.Args[:last]
		}
	}

	// 检查每个参数
	for i, arg := range c.Args {
		// 获取对应的函数定义参数
		defArg := c.Func.Args[i]

		arg.Value.Check(p)

		// 类型检查。首趟解析时跨包调用尚未解析，arg.Value.Type 可能为 nil，
		// 此时跳过检查（合并后 rootNode.Check 重试会补齐）；错误消息里的
		// 类型名同样需要判空，避免构造消息时二次崩溃。
		if arg.Value.Type != nil && defArg.Type != nil &&
			!typeSys.AutoType(arg.Value.Type, defArg.Type, true) {
			p.Error.MissError("Type Error", p.Lexer.Cursor-1,
				"cannot use "+safeTypeName(arg.Value.Type)+" as type "+
					safeTypeName(defArg.Type)+" in argument to "+c.Name.String())
			return false
		}

		arg.Type = defArg.Type
		arg.Name = defArg.Name
		arg.Offset = defArg.Offset
	}

	return true
}

// ParseCall 解析函数调用
func (c *CallBlock) ParseCall(p *Parser) {
	p.Lexer.Skip('(')
	var token lexer.Token
	depth := 0 // 括号深度：支持嵌套调用作为参数（如 f(g(x), y)）

	for {
		oldCursor := p.Lexer.Cursor
		for {
			token = p.Lexer.Next()
			// 输入到头还没碰上 ')' 或 ','：必须在这里停。
			// 原来没有这个判断，畸形调用（缺右括号）会把这个 for 转死循环。
			if token.IsEmpty() {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "missing ')' in call")
				c.Check(p)
				return
			}

			if token.Type == lexer.SEPARATOR && token.Value == "(" {
				depth++
				continue
			}
			if token.Type == lexer.SEPARATOR && token.Value == ")" && depth > 0 {
				depth--
				continue
			}

			if token.Type == lexer.SEPARATOR && token.Value == ")" {
				stopCursor := token.Cursor
				p.Lexer.SetCursor(oldCursor)

				argExp := p.ParseExp(stopCursor)
				if argExp != nil {
					c.Args = append(c.Args, &ArgBlock{Value: argExp})
				}
				if p.Lexer.Cursor <= stopCursor {
					p.Lexer.Skip(')')
				}
				c.Check(p)
				return
			}

			if token.Type == lexer.SEPARATOR && token.Value == "," && depth == 0 {
				stopCursor := token.Cursor
				p.Lexer.SetCursor(oldCursor)

				argExp := p.ParseExp(stopCursor)
				if argExp != nil {
					c.Args = append(c.Args, &ArgBlock{Value: argExp})
				}
				if p.Lexer.Cursor <= token.Cursor {
					p.Lexer.SetCursor(token.Cursor + 1)
				}
				break
			}
		}
	}
}

func (c *CallBlock) Parse(p *Parser) {
	c.ParseCall(p)
	p.ThisBlock.AddChild(&Node{Value: c})
}

// convertTypeNames 显式数值转换的函数名到系统类型名映射。
// 别名（int64/uint32…）与 GetSystemType 保持一致，byte 视作 u8。
var convertTypeNames = map[string]string{
	"int": "int", "uint": "uint",
	"i8": "i8", "i16": "i16", "i32": "i32", "i64": "i64",
	"u8": "u8", "u16": "u16", "u32": "u32", "u64": "u64",
	"int8": "i8", "int16": "i16", "int32": "i32", "int64": "i64",
	"uint8": "u8", "uint16": "u16", "uint32": "u32", "uint64": "u64",
	"byte": "byte",
	"f32":  "f32", "f64": "f64",
}

// isNumericConvertSource 判断类型能否作为显式数值转换的源。
// byte 是一字节无符号整数，允许参与；bool/string/容器不允许。
func isNumericConvertSource(t typeSys.Type) bool {
	if t == nil {
		return false
	}
	if _, ok := t.(*typeSys.TypeParam); ok {
		return true
	}
	return typeSys.CheckKind(t, "int", "uint", "float", "byte")
}

// checkConvertBuiltin 处理 int(x)/i64(x)/f64(x) 等显式数值转换。
// 转换语义是数值转换（截断/扩展/浮点舍入），不是 unsafe.cast 的位重解释。
func (c *CallBlock) checkConvertBuiltin(p *Parser, name string) bool {
	targetName, ok := convertTypeNames[name]
	if !ok {
		return false
	}
	target := typeSys.GetSystemType(targetName)
	if target == nil {
		return false
	}
	if len(c.Args) != 1 || c.Args[0] == nil || c.Args[0].Value == nil {
		p.Error.MissError("Call Error", p.Lexer.Cursor,
			"conversion to "+name+" expects exactly one argument")
		return false
	}
	arg := c.Args[0].Value
	if !arg.Check(p) {
		return false
	}
	src := arg.Type
	if src == nil {
		// 跨文件/跨包类型尚未解析：留待合并后的 Check 重试。
		return false
	}
	if !isNumericConvertSource(src) {
		p.Error.MissError("Type Error", p.Lexer.Cursor,
			"cannot convert "+safeTypeName(src)+" to "+targetName)
		return false
	}
	// 32 位后端暂不支持浮点转换与 64 位标量转换：显式报错，避免生成错误代码。
	if typeSys.TargetPointerSize == 4 {
		unsupported := ""
		if typeSys.CheckKind(src, "float") || typeSys.CheckKind(target, "float") {
			unsupported = "floating-point"
		} else if src.Size() > 4 || target.Size() > 4 {
			unsupported = "64-bit"
		}
		if unsupported != "" {
			p.Error.MissError("Type Error", p.Lexer.Cursor,
				unsupported+" conversion "+safeTypeName(src)+" -> "+targetName+
					" is not supported on 32-bit target")
			return false
		}
	}
	c.ConvertType = target
	c.Func = &FuncBlock{Return: []typeSys.Type{target}}
	return true
}

func (c *CallBlock) checkBuiltin(p *Parser) bool {
	name := c.Name.String()
	if !c.Name.IsPath() {
		if c.checkConvertBuiltin(p, name) {
			return true
		}
	}
	switch name {
	case "new":
		// new(T[, v...])：堆对象创建内建，返回 *T；
		// new(list[T], len[, cap])：列表创建内建，按值返回列表
		if c.NewType != nil {
			retType := typeSys.Type(typeSys.MakePointer(c.NewType))
			if lt, ok := c.NewType.(*typeSys.ListType); ok && lt.Elem() != nil {
				retType = lt
			}
			c.Func = &FuncBlock{
				Return: []typeSys.Type{retType},
			}
			for _, arg := range c.Args {
				if arg != nil && arg.Value != nil {
					arg.Value.Check(p)
				}
			}
			return true
		}
	case "sizeof":
		// sizeof[T]()：T 的字节大小。编译器内建 —— pkg/memory 里那个
		// sizeof[T] 只是 link 到 __memory_sizeof 的壳，直接调用不带命名空间，
		// 所以必须在这里分派。提前标记 provider Useful，否则它会因"无人显式
		// 调用"被死代码消除，链接期符号未定义（同 len/cap 的处理）。
		if c.NewType != nil {
			if fb, ok := LinkProviders["__memory_sizeof"]; ok {
				fb.Useful = true
			}
			c.Func = &FuncBlock{
				Return: []typeSys.Type{typeSys.GetSystemType("int")},
			}
			return true
		}
	case "newRC":
		// newRC(T[, v...])：同 new，但块带 RC 头。逃逸分析把 RC 块判成借用
		// （DisposalBorrow），作用域释放管不到，交回用户手工 rcDec。
		if c.NewType != nil {
			retType := typeSys.Type(typeSys.MakePointer(c.NewType))
			if lt, ok := c.NewType.(*typeSys.ListType); ok && lt.Elem() != nil {
				retType = lt
			}
			c.Func = &FuncBlock{
				Return: []typeSys.Type{retType},
			}
			for _, arg := range c.Args {
				if arg != nil && arg.Value != nil {
					arg.Value.Check(p)
				}
			}
			return true
		}
	case "len", "lists_len":
		if len(c.Args) == 1 {
			c.Args[0].Value.Check(p)
			argType := c.Args[0].Value.Type
			if argType != nil && (argType.Kind() == "string" || argType.Kind() == "list" || argType.Kind() == "map") {
				// 字符串走 link 路径（call __string_len）：提前标记提供者 Useful，
				// 否则提供者可能因无人显式调用被死代码消除（链接期符号未定义）
				if argType.Kind() == "string" {
					if fb, ok := LinkProviders["__string_len"]; ok {
						fb.Useful = true
					}
				}
				c.Func = &FuncBlock{
					Return: []typeSys.Type{typeSys.GetSystemType("int")},
				}
				return true
			}
		}
	case "cap", "lists_cap":
		if len(c.Args) == 1 {
			c.Args[0].Value.Check(p)
			argType := c.Args[0].Value.Type
			if argType != nil && (argType.Kind() == "string" || argType.Kind() == "list") {
				if argType.Kind() == "string" {
					if fb, ok := LinkProviders["__string_cap"]; ok {
						fb.Useful = true
					}
				}
				c.Func = &FuncBlock{
					Return: []typeSys.Type{typeSys.GetSystemType("int")},
				}
				return true
			}
		}
	case "copy":
		// copy(dst, src)：同 Kind（str/str 或 list/list）元素拷贝，
		// 拷贝 min(len(dst), len(src)) 个元素，返回拷贝计数
		if len(c.Args) == 2 && c.Args[0].Value != nil && c.Args[1].Value != nil {
			c.Args[0].Value.Check(p)
			c.Args[1].Value.Check(p)
			dstType := c.Args[0].Value.Type
			srcType := c.Args[1].Value.Type
			if dstType != nil && srcType != nil &&
				dstType.Kind() == srcType.Kind() &&
				(dstType.Kind() == "string" || dstType.Kind() == "list") {
				c.Func = &FuncBlock{
					Return: []typeSys.Type{typeSys.GetSystemType("int")},
				}
				return true
			}
		}
	}
	return false
}

// IsBuiltinNewAlloc 该调用是否为内建 new/newRC 分配形态（NewType 是"分配目标类型"）。
//
// NewType 有两种来源，语义完全不同：
//   - new(T)/newRC(T)：ParseNew 把 T 记进 NewType —— 是分配目标，产生新块；
//   - 泛型调用 f[T](…)（handleName 的 "[" 分支）：NewType 只承载类型实参
//     （单态化信息），不产生新块。
//
// 早期判据 `Call.NewType != nil → 是分配` 把两者混为一体：unsafe.cast[*T](p+i)
// 这类泛型形态的借用别名（指针算术结果）会被 GC 通路（exprAllocates /
// freshAllocExpr / gc_write）误判为全新 owned 对象，继而在块尾插入
// memory.free(借用指针) —— pkg/maps fnv1a 的 bp 即实战撞点（2026-11-01，
// mp/mp_map x64 运行 139 SIGSEGV的第一现场）。判据收窄到 new/newRC 后：
// cast 形态走 null_init-escaped（不 free，不误放借名指针）；
// cast 的实参里若真含 malloc（unsafe.cast[*T](memory.malloc(n))），
// 由实参递归判据保额，所有权照旧成立。
func (c *CallBlock) IsBuiltinNewAlloc() bool {
	if c == nil || c.NewType == nil {
		return false
	}
	if c.IsRC {
		return true // newRC：ParseNew 产物，ParseNew 已置位
	}
	return c.Name != nil && c.Name.String() == "new"
}

// ParseNew 解析 new(T[, v1, v2...])：首个参数为类型名（parseTypeAnnotation），其余为字段初值
func (c *CallBlock) ParseNew(p *Parser) {
	// newRC(T) 与 new(T) 同形态，区别是块带 RC 头、生命周期由用户手工 rcDec 管。
	// 解析期就置位：逃逸分析的 isRCExpr 判据读这个位。
	if c.Name != nil && c.Name.String() == "newRC" {
		c.IsRC = true
	}
	p.Lexer.Skip('(')
	c.NewType = p.parseTypeAnnotation()
	if c.NewType == nil {
		p.Error.MissError("Type Error", p.Lexer.Cursor, "type not found in new()")
		return
	}
	depth := 0
	for {
		oldCursor := p.Lexer.Cursor
		for {
			token := p.Lexer.Next()
			if token.IsEmpty() {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "expected ')' in new()")
				return
			}
			if token.Type == lexer.SEPARATOR && token.Value == "(" {
				depth++
				continue
			}
			if token.Type == lexer.SEPARATOR && token.Value == ")" && depth > 0 {
				depth--
				continue
			}
			if token.Type == lexer.SEPARATOR && token.Value == ")" {
				stopCursor := token.Cursor
				p.Lexer.SetCursor(oldCursor)
				argExp := p.ParseExp(stopCursor)
				if argExp != nil {
					c.Args = append(c.Args, &ArgBlock{Value: argExp})
				}
				if p.Lexer.Cursor <= stopCursor {
					p.Lexer.Skip(')')
				}
				c.Check(p)
				return
			}
			if token.Type == lexer.SEPARATOR && token.Value == "," && depth == 0 {
				stopCursor := token.Cursor
				p.Lexer.SetCursor(oldCursor)
				argExp := p.ParseExp(stopCursor)
				if argExp != nil {
					c.Args = append(c.Args, &ArgBlock{Value: argExp})
				}
				if p.Lexer.Cursor <= stopCursor {
					p.Lexer.Skip(',')
				}
				break
			}
		}
	}
}

// typeSubst 泛型调用的类型实参替换表：被调函数的类型参数名 → 具体类型。
//
// 泛型实参没有单独存（`f[int](x)` 的 int 在解析时就被 AutoType 吃掉），
// 所以只能从实参反推：被调方的第 i 个形参类型若是 TypeParam，就把它绑到
// 调用方第 i 个实参的具体类型上。
//
// 推不出来的参数不出现在表里 —— SubstituteTypeParams 遇到表里没有的类型
// 参数会原样保留占位符，那正是"没写实参也没法推断"的情况，交给后面的
// AutoType 兜底，不要在这里瞎猜。
func (cb *CallBlock) typeSubst() map[string]typeSys.Type {
	if cb == nil || cb.Func == nil || len(cb.Func.TypeParams) == 0 {
		return nil
	}
	subst := map[string]typeSys.Type{}
	if len(cb.NewTypes) > 0 {
		for i, t := range cb.NewTypes {
			if i < len(cb.Func.TypeParams) && t != nil {
				subst[cb.Func.TypeParams[i].Name] = t
			}
		}
	} else if cb.NewType != nil {
		for _, tp := range cb.Func.TypeParams {
			subst[tp.Name] = cb.NewType
		}
	}
	bind := func(declared, actual typeSys.Type) {
		if declared == nil || actual == nil {
			return
		}
		if _, isTP := declared.(*typeSys.TypeParam); !isTP {
			return
		}
		name := declared.Type()
		// 同一个类型参数被多个实参绑定：取第一个非空的，后续冲突不覆盖
		// （泛型函数体内同一个 T 必须处处同型，冲突说明推断不可靠，宁可留空）。
		if cur, ok := subst[name]; ok && cur != nil {
			return
		}
		if _, isTP := actual.(*typeSys.TypeParam); isTP {
			return // 实参本身还是占位符，推不出具体类型
		}
		subst[name] = actual
	}
	for i, ag := range cb.Args {
		if ag == nil || i >= len(cb.Func.Args) {
			continue
		}
		bind(cb.Func.Args[i].Type, ag.Type)
	}
	// 变参：被调方的形参列表里最后那个是 "list[T]"，实参是元素类型。
	if n := len(cb.Func.Args); n > 0 && len(cb.VariadicArgs) > 0 {
		if dt := cb.Func.Args[n-1].Type; dt != nil {
			bind(dt.Elem(), cb.VariadicArgs[0].Type)
		}
	}
	if len(subst) == 0 {
		return nil
	}
	return subst
}
