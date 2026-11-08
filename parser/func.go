package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"strconv"
	"strings"
)

// FuncBlock 函数定义结构体
type FuncBlock struct {
	Args            []*ArgBlock             // 函数参数列表
	Class           typeSys.Type            // 所属类类型（面向对象时使用）
	Return          []typeSys.Type          // 返回值类型列表（支持多返回值）
	Name            Name                    // 函数名
	BuildFlags      []*Build                // 编译标志
	Useful          bool                    // 是否有用（用于优化）
	TypeParams      []TypeParamInfo         // 泛型类型参数（名字 + 占位类型）
	MangledOverride string                  // 覆盖的 mangled 名称
	typeParamTypes  map[string]typeSys.Type // TypeParams → TypeParam 类型实例（解析期用）
}

// overloadSet 同名函数（重载集合）。
// 键是 NASM 名：mangling 冲突只取决于最终汇编标签，而不是源码名称。
type overloadSet struct {
	funcs    []*FuncBlock
	byArity  map[int][]*FuncBlock
	conflict map[int]bool // 该 arity 是否有多个定义 → 需要追加类型标签
}

var overloadRegistry = map[string]*overloadSet{}

// MangledName 返回函数的 mangled 名称。
//
//   - 非重载函数：保持原名，完全向后兼容；
//   - 同名不同 arity：name + arity；
//   - 同名且同 arity 有多个定义：name + arity + "_" + 参数类型标签。
//
// 类型标签只对真正冲突的 arity 生效，其他 arity 的标签面保持最小。
func (f *FuncBlock) MangledName() string {
	if f.MangledOverride != "" {
		return f.MangledOverride
	}
	n := f.Name.NASM()
	if n == "main" {
		return n
	}
	set := overloadRegistry[n]
	if set == nil || len(set.funcs) <= 1 {
		return n
	}
	arity := len(f.Args)
	n += strconv.Itoa(arity)
	if !set.conflict[arity] {
		return n
	}
	return n + "_" + overloadTypeTag(f.Args)
}

// overloadTypeTag 为一组形参生成稳定、可用于汇编标签的类型标签。
func overloadTypeTag(args []*ArgBlock) string {
	parts := make([]string, 0, len(args))
	for _, a := range args {
		if a == nil {
			parts = append(parts, "any")
			continue
		}
		parts = append(parts, overloadTypeCode(a.Type))
	}
	if len(parts) == 0 {
		return "void"
	}
	tag := strings.Join(parts, "_")
	// 极长标签用 FNV-1a 截断，规则固定在计划文档里：
	// 超过 64 个字符时保留前 16 字符 + 8 位十六进制哈希。
	if len(tag) > 64 {
		tag = tag[:16] + "_" + shortHash(tag)
	}
	return tag
}

// overloadTypeCode 类型 → 标签片段（稳定优先，只保留 [A-Za-z0-9_]）。
func overloadTypeCode(t typeSys.Type) string {
	if t == nil {
		return "any"
	}
	if _, isTP := t.(*typeSys.TypeParam); isTP {
		return "tp_" + sanitizeTypeCode(t.Type())
	}
	if t.IsPointer() {
		if elem := t.Elem(); elem != nil {
			return "p_" + overloadTypeCode(elem)
		}
		return "p"
	}
	switch t.Kind() {
	case "list":
		if elem := t.Elem(); elem != nil {
			return "list_" + overloadTypeCode(elem)
		}
		return "list"
	case "array":
		if elem := t.Elem(); elem != nil {
			return "array_" + overloadTypeCode(elem)
		}
		return "array"
	case "map":
		if mt, ok := t.(*typeSys.MapType); ok {
			return "map_" + overloadTypeCode(mt.Key()) + "_" + overloadTypeCode(mt.Elem())
		}
		return "map"
	case "struct":
		return sanitizeTypeCode(t.Type())
	}
	return sanitizeTypeCode(t.Type())
}

func sanitizeTypeCode(s string) string {
	if s == "" {
		return "any"
	}
	var b strings.Builder
	b.Grow(len(s))
	for _, r := range s {
		switch {
		case r >= 'a' && r <= 'z', r >= 'A' && r <= 'Z', r >= '0' && r <= '9', r == '_':
			b.WriteRune(r)
		default:
			b.WriteByte('_')
		}
	}
	return b.String()
}

// shortHash FNV-1a 32 位，8 位十六进制。
func shortHash(s string) string {
	var h uint32 = 2166136261
	for i := 0; i < len(s); i++ {
		h ^= uint32(s[i])
		h *= 16777619
	}
	return strconv.FormatUint(uint64(h), 16)
}

func funcBuildIgnored(f *FuncBlock) bool {
	if f == nil {
		return true
	}
	for _, b := range f.BuildFlags {
		if b != nil && b.Ignore {
			return true
		}
	}
	return false
}

// registerOverload 把函数登记到解析期注册表（定义解析完成时调用）。
func registerOverload(f *FuncBlock) {
	if f == nil || len(f.Name) == 0 || funcBuildIgnored(f) {
		return
	}
	n := f.Name.NASM()
	if n == "main" {
		return
	}
	set := overloadRegistry[n]
	if set == nil {
		set = &overloadSet{
			byArity:  map[int][]*FuncBlock{},
			conflict: map[int]bool{},
		}
		overloadRegistry[n] = set
	}
	for _, old := range set.funcs {
		if old == f {
			return
		}
	}
	set.funcs = append(set.funcs, f)
	arity := len(f.Args)
	set.byArity[arity] = append(set.byArity[arity], f)
	// 同 arity 出现多个定义就必须追加类型标签，否则 NASM 会看到两个同名标签。
	// 类型完全相同的重复定义仍会撞标签——那本来就是非法定义，交给汇编期报错。
	if len(set.byArity[arity]) > 1 {
		set.conflict[arity] = true
	}
}

// sameTypeShape 判断两个类型是否形状相同（Type() + 指针 + 递归元素）。
func sameTypeShape(a, b typeSys.Type) bool {
	if a == nil || b == nil {
		return a == b
	}
	if a.IsPointer() != b.IsPointer() {
		return false
	}
	if a.IsPointer() {
		return sameTypeShape(a.Elem(), b.Elem())
	}
	if a.Type() != b.Type() {
		return false
	}
	switch a.Kind() {
	case "list", "array":
		return sameTypeShape(a.Elem(), b.Elem())
	case "map":
		am, aok := a.(*typeSys.MapType)
		bm, bok := b.(*typeSys.MapType)
		if !aok || !bok {
			return aok == bok
		}
		return sameTypeShape(am.Key(), bm.Key()) && sameTypeShape(am.Elem(), bm.Elem())
	}
	return true
}

// sameFuncSignature 判断两个函数定义是否同签名。
func sameFuncSignature(a, b *FuncBlock) bool {
	if a == nil || b == nil || len(a.Args) != len(b.Args) {
		return false
	}
	for i := range a.Args {
		if a.Args[i] == nil || b.Args[i] == nil {
			if a.Args[i] != b.Args[i] {
				return false
			}
			continue
		}
		if !sameTypeShape(a.Args[i].Type, b.Args[i].Type) {
			return false
		}
	}
	return true
}

// funcMatchesType 判断函数定义的形参形状是否与 fn(...) 类型一致。
func funcMatchesType(f *FuncBlock, ft *typeSys.FuncType) bool {
	if f == nil || ft == nil || len(f.Args) != len(ft.Args) {
		return false
	}
	for i := range f.Args {
		if f.Args[i] == nil || !sameTypeShape(f.Args[i].Type, ft.Args[i]) {
			return false
		}
	}
	return true
}

// FindFuncValueByType 在候选重载中按函数指针类型选一个。
// 没有精确匹配时退回第一个候选（保持旧的“函数名作为值”行为）。
func FindFuncValueByType(p *Parser, name Name, ft *typeSys.FuncType) (FindResult, bool) {
	var fallback *FindResult
	for _, fr := range p.Find(name, FindTypeFunc) {
		fb, ok := fr.Value.(*FuncBlock)
		if !ok || fb == nil || funcBuildIgnored(fb) {
			continue
		}
		if fallback == nil {
			f := fr
			fallback = &f
		}
		if funcMatchesType(fb, ft) {
			return fr, true
		}
	}
	if fallback != nil {
		return *fallback, true
	}
	return FindResult{}, false
}

// RebuildOverloadRegistry 在包合并完成后重建重载注册表。
// 解析期注册只覆盖“已经解析到”的定义；跨文件前向引用、跨包合并都要靠这里。
func RebuildOverloadRegistry(root *Node) {
	overloadRegistry = map[string]*overloadSet{}
	if root == nil {
		return
	}
	var walk func(*Node)
	walk = func(n *Node) {
		if n == nil {
			return
		}
		if f, ok := n.Value.(*FuncBlock); ok {
			registerOverload(f)
		}
		EachSubNode(n, walk)
	}
	walk(root)
}

// GetNameString 返回函数名（供 ImplementsInterface 的接口方法名匹配使用，
// 形如 "Dog.stringify"，匹配时按点分段比对最后一段）
func (f *FuncBlock) GetNameString() string {
	return f.Name.String()
}

// funcTypeOf 由函数定义构造函数指针类型 fn(T1, T2) R
func funcTypeOf(f *FuncBlock) *typeSys.FuncType {
	args := make([]typeSys.Type, 0, len(f.Args))
	for _, a := range f.Args {
		if a != nil && a.Type != nil {
			args = append(args, a.Type)
		}
	}
	return &typeSys.FuncType{
		RType:   typeSys.RType{TypeName: "fn"},
		Args:    args,
		Returns: f.Return,
	}
}

// funcTypeToFuncBlock 由函数类型构造合成 FuncBlock（用于通过函数指针变量的间接调用）
func funcTypeToFuncBlock(name Name, ft *typeSys.FuncType) *FuncBlock {
	fb := &FuncBlock{Name: name}
	for i, at := range ft.Args {
		fb.Args = append(fb.Args, &ArgBlock{Name: NewName("_a" + itoa(i)), Type: at})
	}
	fb.Return = ft.Returns
	return fb
}

// ArgBlock 函数参数结构体
type ArgBlock struct {
	Name       Name         // 参数名
	Type       typeSys.Type // 参数类型
	Default    *Expression  // 默认值表达式
	Defind     *ArgBlock    // 指向参数定义（用于类型检查）
	Value      *Expression  // 参数实际传入的值
	Offset     int          // 参数在栈中的偏移量（用于代码生成）
	IsVariadic bool         // 是否为变参参数
}

// Check 检查参数的有效性
func (f *ArgBlock) Check(p *Parser) bool {
	if f.Type == nil {
		return false
	}
	if f.Default != nil {
		return f.Default.Check(p)
	}
	if f.Value != nil {
		return f.Value.Check(p)
	}
	if f.Defind != nil {
		if !f.Defind.Check(p) {
			return false
		}
		// 检测类型
		return typeSys.CheckType(f.Type, f.Defind.Type)
	}
	return true
}

// Parse 解析函数定义
// 语法格式: funcName(arg1 type1, arg2 type2) returnType { ... }
// 或者: fn Type.methodName(arg1 type1, arg2 type2) returnType { ... }
func (f *FuncBlock) Parse(p *Parser) {
	// 检查函数是否嵌套定义（不支持）
	if p.ThisBlock.Father != nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Function can't be defined in Function")
	}

	oldCursor := p.Lexer.Cursor
	// 判断有没有父类
	code := p.Lexer.Next()
	// 具名函数（含方法简写）才建 FuncBlock 节点；匿名函数/闭包走表达式路径
	namedFunc := code.Type == lexer.NAME
	if code.Type == lexer.NAME {
		// 退格到函数名开始位置
		p.Lexer.SetCursor(oldCursor)
		f.Name, _ = p.ParseName(false)

		if len(f.Name) == 0 {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need Function name")
			return
		}

		if len(f.Name) > 2 {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Function name can't be more than 2 parts")
			return
		}

		if len(f.Name) == 2 {
			structName := NewName(f.Name[0].Name)
			results := p.Find(structName, FindTypeType)
			if len(results) > 0 {
				if typeBlock, ok := results[0].Value.(typeSys.Type); ok {
					f.Class = typeBlock
					typeSys.ToRType(typeBlock).AddMethod(f)
				}
			}
		}
	} else if code.Value == "(" { // 匿名函数/闭包，或方法简写 fn (self Type) name(...)
		p.Lexer.SetCursor(code.Cursor)
		if recvType, methodName, ok := p.parseSelfReceiver(); ok {
			// 归一化成标准的 fn Type.methodName(...) 形式：
			// Name 两段 + Class 绑定 + AddMethod，与上面的分支完全一致。
			f.Name = NewName(recvType, methodName)
			namedFunc = true
			results := p.Find(NewName(recvType), FindTypeType)
			if len(results) > 0 {
				if typeBlock, ok2 := results[0].Value.(typeSys.Type); ok2 {
					f.Class = typeBlock
					typeSys.ToRType(typeBlock).AddMethod(f)
				}
			}
		}
	} else {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need Function name")
	}

	// 解析泛型类型参数列表 fn f[T, U](...)
	f.parseTypeParams(p)

	// 参数/返回类型/函数体中的 T 解析为 TypeParam 占位类型；
	// 非泛型函数显式置 nil，避免继承上一个泛型函数的类型参数。
	// 注意：此处不恢复旧值——函数体在本方法返回后才解析，需要保持生效。
	p.CurTypeParams = f.typeParamTypes

	// 解析参数
	f.ParseArgs(p)

	// 返回类型
	f.ParseRetType(p)

	// 注册重载信息（参数个数已知）：同名不同参 → MangledName 追加参数个数
	registerOverload(f)

	p.Wait("{")

	if namedFunc {
		nodeTmp := &Node{Value: f}
		// 顶层 build os(...)/arch(...) 作用于紧随其后的函数：
		// 回溯连续的 os/arch 指令挂到该函数上，Ignore 才能生效。
		// 否则这些 Build 只是根节点下的孤儿，编译期等于没有平台过滤。
		for i := len(p.ThisBlock.Children) - 1; i >= 0; i-- {
			b, ok := p.ThisBlock.Children[i].Value.(*Build)
			if !ok {
				break
			}
			if b.Type == "align" {
				// build align 对函数透明：跳过继续回溯，不挂在函数上，
				// 留待紧随其后的 struct 消费（attachPendingAlign）。
				continue
			}
			if b.Type != "os" && b.Type != "arch" {
				break
			}
			f.BuildFlags = append(f.BuildFlags, b)
		}
		// 将函数添加到当前作用域
		p.ThisBlock.AddChild(nodeTmp)

		// 进入函数作用域
		p.ThisBlock = nodeTmp
	}

	// TODO: 处理编译标志
}

// parseSelfReceiver 识别方法简写 fn (self Type) name(args...)。
// 扫描首组括号：内容必须是 self Type，且配对 ')' 之后紧跟 "name("。
// 命中则消费接收者部分并返回 (类型名, 方法名)，否则不消费任何 token。
func (p *Parser) parseSelfReceiver() (recvType, methodName string, ok bool) {
	saved := p.Lexer.Cursor

	// 找到配对的 ')'
	matched := false
	depth := 0
	for !matched {
		t := p.Lexer.Next()
		if t.IsEmpty() {
			break
		}
		if t.Type != lexer.SEPARATOR {
			continue
		}
		switch t.Value {
		case "(":
			depth++
		case ")":
			depth--
			if depth == 0 {
				matched = true
			}
		case "\n", "\r", ";":
			// 接收者与方法名必须写在同一行，换行即判定为匿名函数
			p.Lexer.SetCursor(saved)
			return "", "", false
		}
	}
	if !matched {
		p.Lexer.SetCursor(saved)
		return "", "", false
	}

	// ')' 之后必须紧跟 name(
	t1 := p.Lexer.Next()
	t2 := p.Lexer.Next()
	if t1.Type != lexer.NAME || t2.Type != lexer.SEPARATOR || t2.Value != "(" {
		p.Lexer.SetCursor(saved)
		return "", "", false
	}

	// 回到开头解析 "(self Type)"，然后消费方法名
	p.Lexer.SetCursor(saved)
	if p.Lexer.Next().Value != "(" {
		p.Lexer.SetCursor(saved)
		return "", "", false
	}
	if x := p.Lexer.Next(); x.Type != lexer.NAME || x.Value != "self" {
		p.Lexer.SetCursor(saved)
		return "", "", false
	}
	x := p.Lexer.Next()
	if x.Type != lexer.NAME {
		p.Lexer.SetCursor(saved)
		return "", "", false
	}
	recvType = x.Value
	if p.Lexer.Next().Value != ")" {
		p.Lexer.SetCursor(saved)
		return "", "", false
	}
	m := p.Lexer.Next()
	if m.Type != lexer.NAME {
		p.Lexer.SetCursor(saved)
		return "", "", false
	}
	return recvType, m.Value, true
}

// parseTypeParams 解析泛型类型参数列表 [T, U]（fn f[T](x: T) T {...}）。
// 无方括号时不消费任何 token，普通函数定义不受影响。
func (f *FuncBlock) parseTypeParams(p *Parser) {
	saved := p.Lexer.Cursor
	token := p.Lexer.Next()
	if token.Type != lexer.SEPARATOR || token.Value != "[" {
		p.Lexer.SetCursor(saved)
		return
	}
	p.Lexer.SetCursor(token.EndCursor)
	for {
		n, _ := p.ParseName(false)
		if len(n) == 0 {
			break
		}
		tpName := n[0].Name
		if f.typeParamTypes == nil {
			f.typeParamTypes = map[string]typeSys.Type{}
		}
		// 每个类型参数对应一个 TypeParam 占位类型，解析期用它替代真实类型，
		// 编译期由 monomorphize.substituteBodyTypes 替换为具体类型。
		f.typeParamTypes[tpName] = typeSys.NewTypeParam(tpName)
		f.TypeParams = append(f.TypeParams, TypeParamInfo{Name: tpName, Type: f.typeParamTypes[tpName]})

		peek := p.Lexer.Next()
		if peek.Type == lexer.SEPARATOR && peek.Value == "," {
			continue
		}
		p.Lexer.SetCursor(peek.Cursor)
		break
	}
	p.Lexer.Skip(']')
}

// ParseArgs 解析函数参数列表
// 语法格式: (arg1 type1, arg2 type2 = default, ...)
func (f *FuncBlock) ParseArgs(p *Parser) {
	// 跳过开始的(
	p.Lexer.Skip('(')

	// 自动机，找到分割符号 = 或者 )
	token := p.Lexer.Next()

	// 状态
	bracketCount := 0
	argTmp := &ArgBlock{}

	// 存入第一个参数的名字
	if token.Type != lexer.NAME {
		if token.Value != ")" || token.Type != lexer.SEPARATOR {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need )")
		}
		return
	}

	p.Lexer.SetCursor(token.Cursor)
	n, _ := p.ParseName(false)
	argTmp.Name = n

	token = p.Lexer.Next()
	for !token.IsEmpty() {
		if token.Type == lexer.NAME {
			// 遇到名称，解析为参数类型
			p.Lexer.SetCursor(token.Cursor)
			argTmp.Type = p.parseTypeAnnotation()
			if argTmp.Type == nil {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need type")
			}
			token = p.Lexer.Next()
			continue
		}
		if token.Type != lexer.SEPARATOR { // 遇到非分割符，跳过
			token = p.Lexer.Next()
			continue
		}

		if token.Value == "\n" || token.Value == "\r" {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "Need )")
		}

		// 处理参数列表结束与嵌套括号。
		// '(' 和嵌套 ')' 必须推进 token，否则同一 token 会在循环里原地打转。
		if token.Value == "(" {
			bracketCount++
			token = p.Lexer.Next()
			continue
		}
		if token.Value == ")" {
			if bracketCount == 0 {
				// 参数列表结束；token 已由 Next 读入，游标已越过 ')'
				if !argTmp.Name.IsEmpty() {
					f.Args = append(f.Args, argTmp)
				}
				break
			}
			bracketCount--
			token = p.Lexer.Next()
			continue
		}

		// 指针/切片类型前缀（*T、[]T）
		if bracketCount == 0 && (token.Value == "*" || token.Value == "[") {
			p.Lexer.SetCursor(token.Cursor)
			argTmp.Type = p.parseTypeAnnotation()
			if argTmp.Type == nil {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need type")
			}
			token = p.Lexer.Next()
			continue
		}

		// 处理其他部分
		if bracketCount == 0 {
			if token.Value == ":" {
				// 指针/切片/映射参数（*T、[]T、map[K]V）走类型注解解析
				nextTok := p.Lexer.Next()
				if nextTok.Value == "*" || nextTok.Value == "[" ||
					(nextTok.Type == lexer.NAME && nextTok.Value == "map") {
					p.Lexer.SetCursor(nextTok.Cursor)
					argTmp.Type = p.parseTypeAnnotation()
				} else {
					p.Lexer.SetCursor(nextTok.Cursor)
					// 先后解析一个Name作为参数类型
					n, _ := p.ParseName(false)
					var results FindResults
					if sysType := typeSys.GetSystemType(n.String()); sysType != nil {
						argTmp.Type = sysType
					} else if t, ok := p.CurTypeParams[n.String()]; ok {
						// 泛型类型参数 fn f[T](x: T)
						argTmp.Type = t
					} else {
						results = p.Find(n, FindTypeType)
						if len(results) > 0 {
							if t, ok := results[0].Value.(typeSys.Type); ok {
								argTmp.Type = t
							}
						}
					}
				}
				if argTmp.Type == nil {
					p.Lexer.Error.MissError("Type Error", p.Lexer.Cursor, "type not found")
					token = p.Lexer.Next()
					continue
				}
			}

			// TODO: 处理指针类型（token.Value == "*"）
			// if token.Value == "*" {
			// 	argTmp.Type = typeSys.NewPointerType(argTmp.Type)
			// }

			if token.Value == "=" {
				oldCursor := token.Cursor
				p.Wait(",")
				stopCursor := token.Cursor
				p.Lexer.SetCursor(oldCursor)
				// 处理默认值
				argTmp.Default = p.ParseExp(stopCursor - 1)
			}

			if token.Value == "," {
				if argTmp.Type == nil {
					p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need type")
					token = p.Lexer.Next()
					continue
				}
				f.Args = append(f.Args, argTmp)
				argTmp = &ArgBlock{}
				// 获取下一参数的名称
				n, _ := p.ParseName(false)
				argTmp.Name = n
			}
		}
		token = p.Lexer.Next()
	}
}

// ParseRetType 解析函数返回类型
func (f *FuncBlock) ParseRetType(p *Parser) {
	token := p.Lexer.Next()
	if token.Value == "{" {
		p.Lexer.SetCursor(token.Cursor)
		return
	}
	// 多返回值 (T1, T2, ...)
	if token.Value == "(" {
		for {
			tok := p.Lexer.Next()
			if tok.Value == ")" {
				break
			}
			p.Lexer.SetCursor(tok.Cursor)
			typName, _ := p.ParseName(false)
			if typName.IsEmpty() {
				p.Error.MissError("Type Error", p.Lexer.Cursor, "type not found")
				break
			}
			// 泛型多返回值 fn f[T]() (T, int)
			if t, ok := p.CurTypeParams[typName.String()]; ok {
				f.Return = append(f.Return, t)
			} else {
				results := p.Find(typName, FindTypeType)
				if len(results) > 0 {
					if tb, ok := results[0].Value.(typeSys.Type); ok {
						f.Return = append(f.Return, tb)
					}
				} else {
					p.Error.MissError("Type Error", p.Lexer.Cursor, "type not found")
				}
			}
			tok = p.Lexer.Next()
			if tok.Value == "," {
				continue
			}
			if tok.Value == ")" {
				break
			}
			p.Lexer.SetCursor(tok.Cursor)
			break
		}
		return
	}
	// 指针/切片返回类型（*T、[]T）走类型注解解析
	if token.Value == "*" || token.Value == "[" {
		p.Lexer.SetCursor(token.Cursor)
		if t := p.parseTypeAnnotation(); t != nil {
			f.Return = append(f.Return, t)
		} else {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "type not found")
		}
		return
	}
	p.Lexer.SetCursor(token.Cursor)
	typName, _ := p.ParseName(false)
	if typName.IsEmpty() {
		return
	}
	// 泛型返回类型 fn f[T]() T
	if t, ok := p.CurTypeParams[typName.String()]; ok {
		f.Return = append(f.Return, t)
		return
	}
	results := p.Find(typName, FindTypeType)
	if len(results) > 0 {
		if tb, ok := results[0].Value.(typeSys.Type); ok {
			f.Return = append(f.Return, tb)
		} else {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "type not found")
		}
	} else {
		p.Error.MissError("Type Error", p.Lexer.Cursor, "type not found")
	}
}

/*
func (f *FuncBlock) parseArgToken(p *Parser, v *BracketsValue, lastVal string, isPtr *bool, oldCursor *int) {
	switch lastVal {
	case "":
		f.parseFirstArg(p, v)
		*oldCursor = v.Value.Cursor
	case ",":
		f.parseCommaArg(p, v)
		*oldCursor = v.Value.Cursor
	case ":":
		f.parseTypeArg(p, v, *isPtr, *oldCursor)
	case "*":
		*isPtr = true
	}
}

func (f *FuncBlock) parseFirstArg(p *Parser, v *BracketsValue) {
	f.Args = []*ArgBlock{{}} // 第一个参数
	// 解析参数名
	(&f.Args[0].Name).ReadFromToken(v.Value)
	if !f.Args[0].Name.Check() || f.Args[0].Name.IsPath() {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
}

func (f *FuncBlock) parseCommaArg(p *Parser, v *BracketsValue) {
	f.Args = append(f.Args, &ArgBlock{})
	// 解析参数名
	(&f.Args[len(f.Args)-1].Name).ReadFromToken(v.Value)
	if !f.Args[len(f.Args)-1].Name.Check() || f.Args[len(f.Args)-1].Name.IsPath() {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
}

func (f *FuncBlock) parseTypeArg(p *Parser, v *BracketsValue, isPtr bool, oldCursor int) {
	tb := &TypeBlock{}
	tmp := tb.FindDefine(p, Name([]string{v.Value.Value}))
	f.Args[len(f.Args)-1].Type = tmp

	if tmp != nil {
		if isPtr {
			f.Args[len(f.Args)-1].Type = typeSys.MakePointer(tmp)
		} else {
			f.Args[len(f.Args)-1].Type = tmp
		}
	} else {
		p.Error.MissErrors("Syntax Error", oldCursor, v.Value.Cursor, "need type")
	}
}

func (f *FuncBlock) parseArgDefault(p *Parser, brackets *Brackets, i int) int {
	tmp := []lexer.Token{}
	for {
		i++
		if i >= len(brackets.Children) {
			break
		}
		v := brackets.Children[i]
		tmp = append(tmp, v.Value)
		if v.Value.Value == "," {
			break
		}
	}
	p.Lexer.SetCursor(brackets.Children[i].Value.EndCursor)
	f.Args[len(f.Args)-1].Default = p.ParseExp(tmp[len(tmp)-1].EndCursor)
	return i
}

func (f *FuncBlock) validateDefaultOrder(p *Parser) {
	if len(f.Args) >= 2 && f.Args[len(f.Args)-1].Default == nil && f.Args[len(f.Args)-2].Default != nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "miss default value, before "+f.Args[len(f.Args)-1].Name.String())
	}
}

func (f *FuncBlock) validateAllArgTypes(p *Parser) {
	for i := len(f.Args) - 1; i >= 0; i-- {
		if f.Args[i].Type == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "miss type")
		}
	}
}*/

// Check 检查函数定义的有效性，并计算参数的栈偏移量
// 在 cdecl 调用约定中，参数从右到左压栈
// 返回地址占用 4 字节，所以第一个参数从 [ebp+8] 开始（x86）
// x86_64 下参数从 [rbp+16] 开始
// Checking 正在 Check 途中的函数。
//
// Node.Checked 区分不出"在栈上"和"还没开始"，而跨函数逃逸摘要需要这个区别：
// 被调方还没查完 → 调用方该等下一轮；被调方正查着自己 → 那是递归，等不了，
// 只能保守判逃逸。调用方的等待队列就是靠它判断的。
var Checking = map[*FuncBlock]bool{}

// funcCheckMark 在检查函数体**之前**登记，退出时清除。
//
// 不能放在 FuncBlock.Check 里 —— 那是 Node.Check 递归完所有子节点之后才调的，
// 那时函数体早就检查完了，递归窗口抓不到。
func funcCheckMark(n *Node) func() {
	fb, ok := n.Value.(*FuncBlock)
	if !ok || fb == nil {
		return func() {}
	}
	Checking[fb] = true
	return func() { delete(Checking, fb) }
}

func (f *FuncBlock) Check(p *Parser) bool {
	// 计算参数起始偏移量
	argCount := 8
	if typeSys.TargetArch() == "x86_64" {
		argCount = 16
	}

	for _, v := range f.Args {
		if !v.Check(p) {
			return false
		}
		v.Offset = argCount
		argCount += v.Type.Size()
	}
	return true
}

// TypeParamInfo 一个泛型类型参数：名字（源码里写的）与它对应的占位类型。
// 占位类型在解析期用来把 T 顶住，编译期由 monomorphize 换成具体类型。
type TypeParamInfo struct {
	Name string
	Type typeSys.Type
}
