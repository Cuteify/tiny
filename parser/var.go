// Package parser 实现了变量解析和类型检查功能
package parser

import (
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strconv"
)

// VarBlock 描述一个变量的声明或定义
// 包含变量的名称、类型、值、作用域信息等
type VarBlock struct {
	Name          Name           // 变量名（支持路径形式，如 "obj.field"）
	IsConst       bool           // 是否为常量（const关键字）
	Value         *Expression    // 变量的值表达式（如初始化表达式）
	IsDefine      bool           // 是否为定义（:=）而非声明（=）
	IsInitialized bool           // 是否已初始化
	Define        FindResult     // 查找结果（Value 是真正的定义对象）
	Used          bool           // 变量是否已被使用（用于优化/警告）
	StartCursor   int            // 变量名在源代码中的起始位置
	Offset        int            // 变量在栈帧中的偏移量（编译时使用）
	Type          typeSys.Type   // 变量的数据类型
	IsGlobal      bool           // 是否为全局变量（顶层定义）
	RangeVar      bool           // range 循环变量（无初始化值，不参与"need value"检查）
	MultiNames    []Name         // 多返回值变量名列表（持 Name 以便按段取首段名）
	MultiOffsets  []int          // 多返回值偏移量列表
	MultiTypes    []typeSys.Type // 多返回值类型列表
	MultiIndex    int            // 多返回值索引
	Unresolved    bool           // 解析期未找到定义（跨文件前向引用），留待合并后重查
	// Life 归属与逃逸信息（Obj/Scope/Escapes/WroteTo…，见 escape.go）。
	//
	// 具名字段而非匿名内嵌：内嵌会把 Obj/Scope/Escapes 提升成 VarBlock 自己的字段，
	// 于是 v.Obj 和 v.Life.Obj 两种写法都成立，读代码时分不清"这是变量的属性"
	// 还是"这是生命周期记录的属性"。具名之后只有一种写法，也不会意外让
	// VarBlock 继承 Life 的方法。
	Life Life
}

func (p *Parser) parseTypeAnnotation() typeSys.Type {
	code := p.Lexer.Next()
	if code.Type == lexer.FUNC {
		// fn(T1, T2) R 函数类型注解
		return p.parseFuncTypeRef()
	}
	if code.Type == lexer.SEPARATOR && code.Value == "[" {
		next := p.Lexer.Next()
		if next.Type == lexer.SEPARATOR && next.Value == "]" {
			elemType := p.parseTypeAnnotation()
			if elemType != nil {
				return typeSys.NewList(elemType)
			}
			return nil
		}
		// [N]Type 定长数组：`[` 后是长度常量
		if next.Type == lexer.NUMBER {
			n, atoiErr := strconv.Atoi(next.Value)
			closeToken := p.Lexer.Next()
			if atoiErr != nil || closeToken.Type != lexer.SEPARATOR || closeToken.Value != "]" {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need ']' in array type")
				return nil
			}
			elemType := p.parseTypeAnnotation()
			if elemType != nil {
				return typeSys.NewArray(elemType, n)
			}
			return nil
		}
		p.Lexer.SetCursor(code.Cursor)
		return nil
	}
	if code.Type == lexer.SEPARATOR && code.Value == "*" {
		elemType := p.parseTypeAnnotation()
		if elemType != nil {
			return typeSys.MakePointer(elemType)
		}
		return nil
	}
	if code.Type == lexer.NAME {
		nameStr := code.Value
		next := p.Lexer.Next()
		if next.Type == lexer.SEPARATOR && next.Value == "." {
			if nameStr == "lists" {
				innerType := p.parseTypeAnnotation()
				if innerType != nil {
					if _, ok := innerType.(*typeSys.ListType); ok {
						return innerType
					}
					return typeSys.NewList(innerType)
				}
				return nil
			}
			subType := p.parseTypeAnnotation()
			if subType != nil {
				fullName := nameStr + "." + subType.Type()
				results := p.Find(NewName(fullName), FindTypeType)
				if len(results) > 0 {
					if tb, ok := results[0].Value.(*TypeBlock); ok {
						return tb.Type()
					}
					if t, ok := results[0].Value.(typeSys.Type); ok {
						return t
					}
				}
				return nil
			}
			return nil
		}
		// next 不是 "."，回退到 next 之前的位置
		p.Lexer.SetCursor(next.Cursor)
		// map[K]V：Name 解析在 '[' 处停住，此处补读键/值类型
		if nameStr == "map" {
			if t := p.parseMapTypeRef(); t != nil {
				return t
			}
		}
		// 先检查系统类型
		if sysType := typeSys.GetSystemType(nameStr); sysType != nil {
			return sysType
		}
		// 泛型类型参数（fn f[T](x: T)）：T 解析为 TypeParam 占位类型
		if t, ok := p.CurTypeParams[nameStr]; ok {
			return t
		}
		// 自引用结构体字段（type Node struct { next: *Node }）：当前结构体尚未注册到作用域
		if p.CurStructName != "" && nameStr == p.CurStructName {
			if p.CurStructType != nil {
				return p.CurStructType
			}
		}
		results := p.Find(NewName(nameStr), FindTypeType)
		if len(results) > 0 {
			if tb, ok := results[0].Value.(*TypeBlock); ok {
				return tb.Type()
			}
			if t, ok := results[0].Value.(typeSys.Type); ok {
				return t
			}
		}
		return nil
	}
	p.Lexer.SetCursor(code.Cursor)
	return nil
}

// Parse 解析变量声明/定义并添加到当前作用域
// 这是入口函数，会调用ParseVar然后将自身添加到语法树
func (v *VarBlock) Parse(p *Parser) {
	v.ParseVar(p)
	if p.ThisBlock == p.Block && v.IsDefine {
		v.IsGlobal = true
		// 注册到全局变量表，供同包其它文件及跨包解析期/编译期查找
		if p.Package != nil && p.Package.Path != "" && v.Name.Length() > 0 {
			packageFmt.RegisterGlobalVar(p.Package.Path, v.Name.Last(), v)
		}
	}
	p.AddChild(&Node{Value: v})
}

// ParseVar 根据下一个token类型选择解析方式
// 支持两种形式：
//   - NAME: 普通变量声明，如 "x = 5" 或 "x := 5"
//   - VAR: 带关键字的声明，如 "var x int = 5"
func (v *VarBlock) ParseVar(p *Parser) {
	code := p.Lexer.Next()

	switch code.Type {
	case lexer.NAME:
		// 普通变量名形式
		v.ParseNameVar(p, code, p.FindEndCursor())
	case lexer.VAR:
		// var关键字形式
		v.ParseKeywordVar(p, code, p.FindEndCursor())
	default:
		// 语法错误：需要变量名
		if p.Lexer.Cursor == 0 {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
		}
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
	}
}

// ParseNameVar 解析普通变量声明（不带var/const/let关键字）
// 支持的语法形式：
//   - "x = 5"     : 赋值
//   - "x := 5"    : 定义并初始化（自动类型推断）
//   - "x++" / "x--": 自增/自减
//   - "x += 5"    : 复合赋值
func (v *VarBlock) ParseNameVar(p *Parser, code lexer.Token, stopCursor int) {
	v.StartCursor = p.Lexer.Cursor

	// 回退词法分析器到变量名开始位置，以正确解析名称
	p.Lexer.SetCursor(code.Cursor)
	name, _ := p.ParseName(false)
	v.Name = name

	// 检查变量名是否合法（不能是路径形式用于定义）
	if !utils.CheckName(v.Name.First()) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}

	// 解析变量引用（查找定义）
	v.ParseDefine(p)

	code = p.Lexer.Next()

	// 检查是否有赋值操作符
	if code.Type != lexer.SEPARATOR {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need '=', ':=' or other")
	}

	// 处理自增/自减操作 (x++ 或 x--)
	if code.Value == "++" || code.Value == "--" {
		valPart := &Expression{
			Var: &VarBlock{Name: NewName(v.Name.First())},
		}

		// 将 x++ 转换为表达式: x = x + 1
		v.Value = &Expression{
			Separator: code.Value[0 : len(code.Value)-1], // "+" 或 "-"
			Left:      valPart,
			Right:     &Expression{Num: 1, Type: typeSys.GetSystemType("int")},
		}

		// 建立父子关系
		v.Value.Left.Father = v.Value
		v.Value.Right.Father = v.Value

		// 解析右侧变量引用
		valPart.Var.ParseDefine(p)
		return
	}

	// 解析赋值表达式（右侧部分）
	v.Value = p.ParseExp(stopCursor)
	if v.Value != nil {
		v.Value.Check(p)
	}

	// 根据操作符类型处理
	switch code.Value {
	case ":=":
		v.IsDefine = true
		if v.Type == nil && v.Value != nil && v.Value.Type != nil {
			v.Type = v.Value.Type
		}
		return
	case "=":
		// 普通赋值：x = 5，需要移除旧的常量值
		v.removeOldStaticVal(p)
	case "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>=":
		// 复合赋值：x += 5，需要转换为 x = x + 5
		valPart := &Expression{
			Var: &VarBlock{Name: v.Name.Fork()},
		}

		v.Value = &Expression{
			Separator: code.Value[0 : len(code.Value)-1], // "+", "-", "*" 等
			Left:      valPart,
			Right:     v.Value,
		}

		// 建立父子关系
		v.Value.Left.Father = v.Value
		v.Value.Right.Father = v.Value

		// 解析右侧变量引用
		valPart.Var.ParseDefine(p)
	}
	// 再次解析变量引用（处理赋值后的定义）
	v.ParseDefine(p)
}

// ParseKeywordVar 解析带关键字的变量声明
// 支持的语法形式：
//   - "var x int = 5"    : 带类型的变量定义
//   - "var x *int = nil"  : 指针类型
//   - "const x int = 5"   : 常量定义
func (v *VarBlock) ParseKeywordVar(p *Parser, code lexer.Token, stopCursor int) {
	v.IsDefine = true
	v.setVarConst(p, code.Value)

	code = p.Lexer.Next()
	if code.Type != lexer.NAME {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name")
	}
	v.parseVarName(p, code)

	// 解析类型注解（支持 :Type）
	p.Lexer.Skip(':')
	v.Type = p.parseTypeRef()
	if v.Type == nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need type")
	}

	// 解析初始化值
	code = p.Lexer.Next()
	if code.Type == lexer.SEPARATOR && code.Value == "=" {
		v.IsInitialized = true
		v.Value = p.ParseExp(stopCursor)
		if v.Value != nil {
			v.Value.Check(p)
			// 如果字面量值超出 int32 范围，将变量类型提升为 i64
			// 避免 x86 上 mov DWORD[mem], imm 溢出问题
			if v.Value != nil && v.Value.IsConst() && v.Type != nil &&
				v.Value.Type != nil && v.Value.Type.Type() == "i64" &&
				v.Type.Type() == "int" {
				if v.Value.Num > 2147483647 || v.Value.Num < -2147483648 {
					v.Type = typeSys.GetSystemType("i64")
				}
			}
		}
	} else {
		v.IsInitialized = false
		// 回退词法分析器到"="之后的位置
		p.Lexer.SetCursor(code.Cursor)
	}
}

// setVarConst 根据关键字设置常量和警告
// const  -> IsConst = true
// var    -> IsConst = false
// let    -> IsConst = false (但发出警告)
func (v *VarBlock) setVarConst(p *Parser, keyword string) {
	switch keyword {
	case "CONST":
		v.IsConst = true
	case "VAR":
		v.IsConst = false
	case "LET":
		v.IsConst = false
		p.Error.Warning("let is not support, use var instead")
	}
}

// parseVarName 解析变量名称并验证
// 关键点：如果是定义语句，变量名不能是路径形式（如 "a.b"）
func (v *VarBlock) parseVarName(p *Parser, code lexer.Token) {
	// 先退格到名称开始位置
	p.Lexer.SetCursor(code.Cursor)
	v.StartCursor = code.Cursor
	name, _ := p.ParseName(false)

	// 如果是定义，那就不能是path
	if v.IsDefine && name.IsPath() {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}

	// 赋值给VarBlock的Name
	v.Name = name
}

// fillMultiTypes 多返回值声明的槽位类型：从被调函数的返回类型表取得。
// 调用尚未解析（跨文件前向引用）时静默返回，留给下一轮 Check 重试。
func (v *VarBlock) fillMultiTypes(p *Parser) {
	if len(v.MultiTypes) == len(v.MultiNames) {
		return
	}
	if v.Value == nil || v.Value.Call == nil || v.Value.Call.Func == nil {
		return
	}
	rets := v.Value.Call.Func.Return
	if len(rets) != len(v.MultiNames) {
		p.Error.MissError("Type Error", p.Lexer.Cursor,
			"assignment mismatch: "+itoa(len(v.MultiNames))+" variables but "+itoa(len(rets))+" return values")
	}
	v.MultiTypes = rets
	if v.Type == nil && len(rets) > 0 {
		v.Type = rets[0]
	}
}

func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	neg := n < 0
	if neg {
		n = -n
	}
	var b []byte
	for n > 0 {
		b = append([]byte{byte('0' + n%10)}, b...)
		n /= 10
	}
	if neg {
		return "-" + string(b)
	}
	return string(b)
}

// multiNameHit 多返回值声明里除第一个名字外的变量也由同一个 owner VarBlock
// 定义（q, r := foo() 只产生一个节点），查找时按 MultiNames 兜底命中。
func (v *VarBlock) multiNameHit(name Name) bool {
	if len(v.MultiNames) <= 1 || name.Length() != 1 {
		return false
	}
	first := name.First()
	for _, mn := range v.MultiNames {
		if mn.First() == first {
			return true
		}
	}
	return false
}

// ParseDefine 解析变量引用，查找变量定义的位置
// 这是变量解析的核心函数，会沿着作用域链向上查找
func (v *VarBlock) ParseDefine(p *Parser) bool {
	oldThisBlock := p.ThisBlock

	// 检查变量名是否合法
	if !v.Name.Check() {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}

	v.Used = true

	// 使用 Find 查找变量定义
	if !v.IsDefine && v.Define.Node == nil {
		results := p.Find(v.Name, FindTypeVar|FindTypeItem|FindTypeSelf|FindTypeField|FindTypeArg)
		// 兜底：跨文件/跨包全局变量（根包合并树中查找）
		if len(results) == 0 && v.Define.Node == nil {
			if n, vb := findGlobalVar(p, v.Name); vb != nil {
				results = append(results, FindResult{Node: n, Value: vb, Path: []any{vb}, Type: FindTypeVar})
			}
		}
		for _, result := range results {
			switch result.Type {
			case FindTypeVar:
				if vb, ok := result.Value.(*VarBlock); ok {
					v.Type = vb.Type
					v.Offset = vb.Offset
					v.IsGlobal = vb.IsGlobal
					v.Define = result
					// 多返回值解构：取自己在 MultiNames 中的槽位与类型
					if len(vb.MultiNames) > 1 {
						for i, mn := range vb.MultiNames {
							if mn.First() == v.Name.First() {
								v.MultiIndex = i
								if i < len(vb.MultiTypes) && vb.MultiTypes[i] != nil {
									v.Type = vb.MultiTypes[i]
								}
								break
							}
						}
					}
				}
			case FindTypeArg:
				if ab, ok := result.Value.(*ArgBlock); ok {
					v.Type = ab.Type
					v.Offset = ab.Offset
					v.Define = result
				}
			case FindTypeSelf:
				if fn, ok := result.Value.(*FuncBlock); ok {
					v.Type = fn.Class
					v.Define = result
				}
			case FindTypeField:
				if field, ok := result.Value.(*typeSys.StructField); ok {
					v.Type = field.Type
					v.Define = result
				}
			case FindTypeItem:
				if t, ok := result.Value.(typeSys.Type); ok {
					v.Type = t
					v.Define = result
				}
			}
			if v.Define.Node != nil {
				p.ThisBlock = oldThisBlock
				return true
			}
		}
		// 不是变量：函数名作为值使用（函数指针 / 取函数地址）
		if v.Define.Node == nil {
			for _, fr := range p.Find(v.Name, FindTypeFunc) {
				if fb, ok := fr.Value.(*FuncBlock); ok && fb != nil {
					v.Type = funcTypeOf(fb)
					v.Define = FindResult{Node: fr.Node, Value: fb, Path: fr.Path, Type: FindTypeFunc}
					// 函数被作为值引用：标记 Useful，否则死代码消除会不发这个
					// 函数的标签，取地址处 lea rax, [name] 链接期符号未定义
					fb.Useful = true
					p.ThisBlock = oldThisBlock
					return true
				}
			}
		}
		p.ThisBlock = oldThisBlock
		return false
	}

	p.ThisBlock = oldThisBlock
	return true
}

// removeOldStaticVal 移除旧的常量值
// 当执行 "x = 5" 赋值时，如果之前x有常量值，需要先移除旧值
// 这是为了确保常量折叠等优化能正确处理
func (v *VarBlock) removeOldStaticVal(p *Parser) {
	if v.Define.Node == nil {
		v.ParseDefine(p)
	}
	if v.Define.Node == nil {
		return
	}
	oldThisBlock := p.ThisBlock

	if !utils.CheckName(v.Name.First()) {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "name is not valid")
	}
	searchName := v.Name.First()

	// 从当前块向前遍历，查找常量赋值并移除
	for {
		for i := len(p.ThisBlock.Children) - 1; i >= 0; i-- {
			if p.ThisBlock.Children[i].Ignore {
				continue
			}
			switch p.ThisBlock.Children[i].Value.(type) {
			case *FuncBlock, *ForBlock, *ElseBlock, *IfBlock:
				// 遇到控制流块，停止搜索
				goto end
			case *VarBlock:
				tmp := p.ThisBlock.Children[i].Value.(*VarBlock)
				// 定义节点必须保留，否则后续引用会变成 undefined
				if tmp.IsDefine {
					continue
				}
				// 如果找到同名变量的常量赋值，移除它
				if tmp.Name.String() == searchName && tmp.Value != nil && tmp.Value.IsConst() {
					if i == len(p.ThisBlock.Children)-1 {
						p.ThisBlock.Children = p.ThisBlock.Children[:i]
					} else {
						p.ThisBlock.Children = append(p.ThisBlock.Children[:i], p.ThisBlock.Children[i+1:]...)
					}
				}
			}
		}
		p.ThisBlock = p.ThisBlock.Father
	}
end:
	p.ThisBlock = oldThisBlock
}

// Check 类型检查和验证函数
// 确保变量定义和使用时的类型一致性
func (v *VarBlock) Check(p *Parser) bool {
	if v.IsDefine {
		// 定义分支：var x int = 5
		if v.Value != nil {
			if ok := v.Value.Check(p); !ok {
				return false
			}
			// 多返回值解构：调用解析出 Func 后补齐每个槽位的类型
			if len(v.MultiNames) > 0 {
				v.fillMultiTypes(p)
			}
			if v.Value.Type == nil {
				p.Error.MissError("Type Error", p.Lexer.Cursor, "need type")
			}
			// 如果变量没有显式类型，从值推断
			if v.Type == nil {
				v.Type = v.Value.Type
			}
			// 检查类型兼容性
			if !typeSys.AutoType(v.Value.Type, v.Type, true) {
				p.Error.MissError("Type Error", p.Lexer.Cursor, "need type "+v.Type.Type()+", not "+v.Value.Type.Type())
			}
		}
		// 无初始值的声明（var result: *Node）也要登记：它同样属于某个作用域，
		// 后面被赋值时要按"绑定名里最外层的作用域"算释放点。
		v.Life.markDefine(v)
	} else {
		// 使用分支：x = 5（使用已定义的变量）
		if v.Define.Value == nil {
			v.ParseDefine(p)
		}
		if v.Define.Value == nil {
			// 包内文件按字母序解析，跨文件的全局变量前向引用此时还查不到
			// （如 pkg/memory 的 allocator.cute 引用 memory.cute 里的 gDbgD）。
			// 解析期不报错，标记未解析并让 AddChild 置 Checked=false，
			// 等所有包合并成一棵树后的 rootNode.Check 再重查；仍找不到才报错。
			if ParsePhase {
				v.Unresolved = true
				return true
			}
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need name "+v.Name.String())
		}
		v.Unresolved = false
		if v.Value == nil {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need value for "+v.Name.String())
		}
		if ok := v.Value.Check(p); !ok {
			return false
		}
		// 字段访问时需要检查字段类型
		if v.Type == nil && len(v.Name) > 1 {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "field type not resolved for "+v.Name.String())
		}
		// 检查赋值类型兼容性
		if v.Type != nil && v.Value.Type != nil {
			if !typeSys.AutoType(v.Value.Type, v.Type, v.Value.IsConst()) {
				p.Error.MissError("Type Error", p.Lexer.Cursor, "need type "+v.Type.Type()+", not "+v.Value.Type.Type())
			}
		}
		if l := LifeOf(v); l != nil {
			l.markAssign(v)
		}
	}
	return true
}
