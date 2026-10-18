package parser

import (
	"cuteify/lexer"
	typeSys "cuteify/type"
	"os"
	"strconv"
)

// FuncBlock 函数定义结构体
type FuncBlock struct {
	Args            []*ArgBlock             // 函数参数列表
	Class           typeSys.Type            // 所属类类型（面向对象时使用）
	Return          []typeSys.Type          // 返回值类型列表（支持多返回值）
	Name            Name                    // 函数名
	BuildFlags      []*Build                // 编译标志
	Useful          bool                    // 是否有用（用于优化）
	ReturnsOwned    bool                    // 过程摘要：返回值含本帧分配、所有权转移给调用者的对象
	TypeParams      []string                // 泛型类型参数名列表
	MangledOverride string                  // 覆盖的 mangled 名称
	typeParamTypes  map[string]typeSys.Type // TypeParams → TypeParam 类型实例（解析期用）
}

// MangledName 返回函数的 mangled 名称。
// 同名不同参函数（重载）标签后接参数个数消歧，否则 NASM 报
// "label `add' inconsistently redefined"。
func (f *FuncBlock) MangledName() string {
	if f.MangledOverride != "" {
		return f.MangledOverride
	}
	n := f.Name.NASM()
	if n != "main" && isOverloadedName(n) {
		n += strconv.Itoa(len(f.Args))
	}
	return n
}

// overloadNames 记录每个函数名出现过的参数个数集合（解析期注册）
var overloadNames = map[string]map[int]bool{}

func registerOverload(f *FuncBlock) {
	if len(f.Name) == 0 {
		return
	}
	n := f.Name.NASM()
	if n == "main" {
		return
	}
	m := overloadNames[n]
	if m == nil {
		m = map[int]bool{}
		overloadNames[n] = m
	}
	m[len(f.Args)] = true
}

// isOverloadedName 判断同名函数是否存在不同参数个数的重载
func isOverloadedName(n string) bool {
	return len(overloadNames[n]) > 1
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
	// Life 归属与逃逸信息。同 VarBlock.Life 为何具名而不内嵌。
	// 参数由调用者持有 → Check 里置 Escapes = true。
	Life Life
}

// Check 检查参数的有效性
func (f *ArgBlock) Check(p *Parser) bool {
	// 参数由调用者持有：本帧永远不自动释放（与 gc_model.go 的 Life 约定一致）
	f.Life.Escapes = true
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
			if !ok || (b.Type != "os" && b.Type != "arch") {
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
		f.TypeParams = append(f.TypeParams, tpName)
		if f.typeParamTypes == nil {
			f.typeParamTypes = map[string]typeSys.Type{}
		}
		// 每个类型参数对应一个 TypeParam 占位类型，解析期用它替代真实类型，
		// 编译期由 monomorphize.substituteBodyTypes 替换为具体类型。
		f.typeParamTypes[tpName] = typeSys.NewTypeParam(tpName)

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

		if bracketCount <= -1 { // 找到参数结束的)
			if !argTmp.Name.IsEmpty() {
				f.Args = append(f.Args, argTmp)
			}
			break
		}

		// 处理括号
		if token.Value == "(" {
			bracketCount++
			continue
		}
		if token.Value == ")" {
			bracketCount--
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
				// 指针/切片参数（*T、[]T）走类型注解解析
				nextTok := p.Lexer.Next()
				if nextTok.Value == "*" || nextTok.Value == "[" {
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
	if os.Getenv("CUTE_ARCH") == "x86_64" {
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
