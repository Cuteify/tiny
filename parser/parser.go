package parser

import (
	errorUtil "cuteify/error"
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
	typeSys "cuteify/type"
	"os"
	"strconv"
)

type Parser struct {
	Block             *Node
	ThisBlock         *Node
	Lexer             *lexer.Lexer
	BracketsNum       int
	Error             *errorUtil.Error
	Package           *packageFmt.Info
	DontBack          int
	PreventNameAssign bool
	CurStructName     string                  // 当前正在解析的结构体名（支持自引用字段 *T）
	CurStructType     typeSys.Type            // 当前正在解析的结构体类型实例（与注册后同一实例）
	CurTypeParams     map[string]typeSys.Type // 当前泛型函数的类型参数（fn f[T]{} 体内 T 解析为 TypeParam）
	FileImports       []ImportItem            // 文件级 import 声明（Wave L，仅记录，别名注册在 package 层）
	FinalCheck        bool                    // 包合并后的最终 Check：此时“查不到/无匹配”才是真错误
	PendingBuilds     []*Build                // 顶层 build os/arch/bits，等待下一个声明消费
	exprStop          int                     // 表达式解析的临时停止点（0 表示未设置），用于 for post 等场景
}

// takePendingBuilds 取走并清空待消费的顶层 build。
func (p *Parser) takePendingBuilds() []*Build {
	if len(p.PendingBuilds) == 0 {
		return nil
	}
	builds := p.PendingBuilds
	p.PendingBuilds = nil
	return builds
}

func buildsIgnored(builds []*Build) bool {
	for _, b := range builds {
		if b != nil && b.Ignore {
			return true
		}
	}
	return false
}

// pendingDeclIgnored 报告紧随其后的声明是否被顶层 build 过滤。
func (p *Parser) pendingDeclIgnored() bool {
	if p.ThisBlock != p.Block {
		return false
	}
	return buildsIgnored(p.PendingBuilds)
}

// addDeclNode 添加声明节点；顶层声明同时消费 PendingBuilds，
// 被过滤的声明挂 BuildIgnored（不能复用 Ignore：变量节点 Ignore 仍要 Check）。
func (p *Parser) addDeclNode(node *Node) {
	if p.ThisBlock == p.Block {
		node.BuildIgnored = buildsIgnored(p.takePendingBuilds())
		if vb, ok := node.Value.(*VarBlock); ok && vb.IsDefine && p.Package != nil && p.Package.Path != "" &&
			vb.Name.Length() > 0 && !node.BuildIgnored {
			packageFmt.RegisterGlobalVar(p.Package.Path, vb.Name.Last(), vb)
		}
	}
	p.ThisBlock.AddChild(node)
}

// ParsePhase 为 true 表示各包/各文件尚未合并成同一棵树。
// 此时查不到的名称可能是跨文件前向引用（文件按字母序解析），
// 不立即报错，标记 Unresolved 留给 rootNode.Check 重试；
// 合并完成后 package 包会把它置 false，此后再查不到才是真错误。
var ParsePhase = true

// multiAssignCounter 为多返回值赋值生成唯一临时变量名（a, b = f() 的展开）。
var multiAssignCounter int

// Next 解析下一个语法单元，返回是否结束
func (p *Parser) Next() (finish bool) {
	beforeCursor := p.Lexer.Cursor
	code := p.Lexer.Next()

	if code.IsEmpty() {
		return p.handleEmptyToken(beforeCursor)
	}

	// 顶层 build 只作用于紧随其后的声明：遇到非声明 token 即作废。
	// import 不打断（文件头 build + import + fn 是 std 包的常见形状），
	// FUNC/TYPE/VAR 由各自处理器消费，BUILD 继续累积。
	if p.ThisBlock == p.Block {
		clear := true
		switch code.Type {
		case lexer.FUNC, lexer.TYPE, lexer.VAR, lexer.BUILD, lexer.IMPORT:
			clear = false
		case lexer.NAME:
			// 省略 var 的顶层声明 `x: T = v` / 多返回值 `q, r := f()`：
			// 下一 token 是 ':' 或 ',' 才保留 pending。
			save := p.Lexer.Cursor
			next := p.Lexer.Next()
			p.Lexer.SetCursor(save)
			clear = !(next.Type == lexer.SEPARATOR && (next.Value == ":" || next.Value == ","))
		case lexer.SEPARATOR:
			if code.Value == "\n" || code.Value == "\r" || code.Value == ";" {
				clear = false
			}
		}
		if clear {
			p.PendingBuilds = nil
		}
	}

	if code.Value == "}" && code.Type == lexer.SEPARATOR {
		// case 分支与所属 switch 只共用一个 '}'：若当前停在 case 上，
		// 要连退两层，否则 switch 之后的语句会被挂进 switch 节点里。
		if _, isCase := p.ThisBlock.Value.(*CaseBlock); isCase {
			p.checkFallthroughFinalCase()
			p.Back(1)
			if _, isSwitch := p.ThisBlock.Value.(*SwitchBlock); isSwitch {
				p.Back(1)
			}
			return
		}
		// 宿主具名函数关闭：把宿主内的闭包提升到包根（不能提升嵌套命名函数）
		// 只在被关闭的是宿主具名函数时触发；嵌套或匿名单元在父闭包触发时一起提升。
		if fb, ok := p.ThisBlock.Value.(*FuncBlock); ok && fb != nil && !fb.Anon && p.ThisBlock.Father == p.Block {
			hoistClosures(p, p.ThisBlock)
		}
		p.Back(1)
		return
	}

	//fmt.Println(code.Type)

	switch code.Type {
	case lexer.FUNC:
		p.processFuncToken(code)
	case lexer.PROCESSCONTROL:
		p.processControlToken(code)
	case lexer.NAME:
		p.processNameToken(code, beforeCursor)
	case lexer.VAR:
		p.processVarToken(beforeCursor, code)
	case lexer.TYPE:
		p.processTypeToken(code)
	case lexer.BUILD:
		p.processBuildToken(code)
	case lexer.IMPORT:
		p.processImportToken(code)
	default:
		// *p = v / *p 解引用语句（以 * 开头的语句）
		if code.Type == lexer.SEPARATOR && code.Value == "*" {
			p.processDerefStmt(beforeCursor)
			return
		}
		// 独立作用域块：{ stmts }。等价于一个不带条件的 ElseBlock
		if code.Type == lexer.SEPARATOR && code.Value == "{" {
			block := &ElseBlock{}
			p.ThisBlock.AddChild(&Node{Value: block})
			p.ThisBlock = p.ThisBlock.Children[len(p.ThisBlock.Children)-1]
			return
		}
		p.processDefaultToken(code)
	}

	return
}

// parseTypeRef 解析类型引用，支持 []Type 和 *Type 语法
func (p *Parser) parseTypeRef() typeSys.Type {
	token := p.Lexer.Next()

	// 检查是否是 *Type 语法（指针类型）
	if token.Type == lexer.SEPARATOR && token.Value == "*" {
		elemType := p.parseTypeRef()
		if elemType != nil {
			return typeSys.MakePointer(elemType)
		}
		return nil
	}

	// 检查是否是 fn(...) R 函数类型
	if token.Type == lexer.FUNC {
		return p.parseFuncTypeRef()
	}

	// 检查是否是 []Type / [N]Type 语法
	if token.Type == lexer.SEPARATOR && token.Value == "[" {
		nextToken := p.Lexer.Next()
		if nextToken.Type == lexer.SEPARATOR && nextToken.Value == "]" {
			// 解析元素类型
			elemType := p.parseTypeRef()
			if elemType == nil {
				return nil
			}
			return typeSys.NewList(elemType)
		}
		// [N]Type 定长数组：`[` 后是长度常量
		if nextToken.Type == lexer.NUMBER {
			n, atoiErr := strconv.Atoi(nextToken.Value)
			closeToken := p.Lexer.Next()
			if atoiErr != nil || closeToken.Type != lexer.SEPARATOR || closeToken.Value != "]" {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need ']' in array type")
				return nil
			}
			elemType := p.parseTypeRef()
			if elemType != nil {
				return typeSys.NewArray(elemType, n)
			}
			return nil
		}
		// 不是 []，退格
		p.Lexer.SetCursor(token.Cursor)
	} else {
		// 退格，使用 Name 解析
		p.Lexer.SetCursor(token.Cursor)
	}

	// 解析类型名称
	typeName, _ := p.ParseName(false)
	if typeName.IsEmpty() {
		return nil
	}

	// 泛型类型参数（fn f[T]{} 体内的 sizeof[T]() 等）：T 解析为 TypeParam 占位类型
	if t, ok := p.CurTypeParams[typeName.String()]; ok {
		return t
	}

	// map[K]V 语法：Name 解析在 '[' 处停住，此处补读键/值类型
	if typeName.String() == "map" {
		if t := p.parseMapTypeRef(); t != nil {
			return t
		}
	}

	// 再查找用户定义类型
	results := p.Find(Name(typeName), FindTypeType)
	if len(results) > 0 {
		if tb, ok := results[0].Value.(*TypeBlock); ok {
			t := tb.Type()
			if st := structOfType(t); st != nil {
				if inst := p.maybeInstantiateGenericStruct(st); inst != nil {
					return inst
				}
				return nil
			}
			return t
		}
		if t, ok := results[0].Value.(typeSys.Type); ok {
			if st := structOfType(t); st != nil {
				if inst := p.maybeInstantiateGenericStruct(st); inst != nil {
					return inst
				}
				return nil
			}
			return t
		}
	}

	return nil
}

// parseMapTypeRef 解析 map[K]V 的 [K]V 部分（游标位于 '[' 处）。
// 解析成功返回 MapType；不是 map[K]V 语法时回退游标并返回 nil，
// 由调用方按普通类型名继续处理（最终报 "need type"）。
func (p *Parser) parseMapTypeRef() typeSys.Type {
	openCursor := p.Lexer.Cursor
	open := p.Lexer.Next()
	if open.Type != lexer.SEPARATOR || open.Value != "[" {
		p.Lexer.SetCursor(openCursor)
		return nil
	}
	keyType := p.parseTypeRef()
	if keyType == nil {
		p.Lexer.SetCursor(openCursor)
		return nil
	}
	closeToken := p.Lexer.Next()
	if closeToken.Type != lexer.SEPARATOR || closeToken.Value != "]" {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need ']' in map type")
		return nil
	}
	valType := p.parseTypeRef()
	if valType == nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need value type in map[K]V")
		return nil
	}
	return typeSys.NewMapType(keyType, valType)
}

// parseFuncTypeRef 解析 fn(T1, T2) [R] 函数类型。
// 调用时 'fn' 已被消费。
func (p *Parser) parseFuncTypeRef() typeSys.Type {
	open := p.Lexer.Next()
	if open.Type != lexer.SEPARATOR || open.Value != "(" {
		p.Lexer.SetCursor(open.Cursor)
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need '(' in fn type")
		return nil
	}
	var args []typeSys.Type
	for {
		t := p.Lexer.Next()
		if t.IsEmpty() {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "unexpected EOF in fn type")
			return nil
		}
		if t.Type == lexer.SEPARATOR && t.Value == ")" {
			break
		}
		if t.Type == lexer.SEPARATOR && t.Value == "," {
			continue
		}
		p.Lexer.SetCursor(t.Cursor)
		at := p.parseTypeAnnotation()
		if at == nil {
			p.Error.MissError("Type Error", p.Lexer.Cursor, "need type in fn type")
			return nil
		}
		args = append(args, at)
	}
	// 可选返回类型：')' 之后、同一行内的类型
	rets := []typeSys.Type{}
	lineEnd := p.FindEndCursor()
	t := p.Lexer.Next()
	if !t.IsEmpty() && t.Cursor < lineEnd &&
		(t.Type == lexer.NAME || t.Type == lexer.FUNC || t.Type == lexer.SEPARATOR && t.Value == "*" ||
			t.Type == lexer.SEPARATOR && t.Value == "[") {
		p.Lexer.SetCursor(t.Cursor)
		rt := p.parseTypeAnnotation()
		if rt != nil {
			rets = append(rets, rt)
		}
	} else if !t.IsEmpty() {
		p.Lexer.SetCursor(t.Cursor)
	}
	return &typeSys.FuncType{
		RType:   typeSys.RType{TypeName: "fn"},
		Args:    args,
		Returns: rets,
	}
}

func (p *Parser) handleEmptyToken(beforeCursor int) bool {
	if p.ThisBlock.Father != nil {
		p.Error.MissErrors("Syntax Error", beforeCursor, p.Lexer.Cursor, "Need }")
	}
	return true
}

func (p *Parser) processFuncToken(code lexer.Token) {
	if code.Value == "fn" {
		block := &FuncBlock{}
		block.Parse(p)
	}
}

// checkFallthroughFinalCase 在 switch 关闭时检查最后一个 case 是否以
// fallthrough 结尾——最后一个 case 没有下一个 body 可跳，必须报错。
func (p *Parser) checkFallthroughFinalCase() {
	children := p.ThisBlock.Children
	if len(children) == 0 {
		return
	}
	if _, ok := children[len(children)-1].Value.(*FallthroughBlock); ok {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "cannot fallthrough final case in switch")
	}
}

func (p *Parser) processControlToken(code lexer.Token) {
	switch code.Value {
	case "if":
		block := &IfBlock{}
		block.Parse(p)
	case "else":
		block := &ElseBlock{}
		block.Parse(p)
	case "return", "ret":
		ret := &ReturnBlock{}
		ret.Parse(p)
	case "for":
		block := &ForBlock{}
		block.Parse(p)
	case "while":
		block := &ForBlock{}
		block.ParseWhile(p)
	case "break":
		block := &BreakBlock{}
		block.Parse(p)
		node := &Node{Value: block}
		p.ThisBlock.AddChild(node)
	case "continue":
		block := &ContinueBlock{}
		block.Parse(p)
		p.ThisBlock.AddChild(&Node{Value: block})
	case "fallthrough":
		block := &FallthroughBlock{}
		block.Parse(p)
		p.ThisBlock.AddChild(&Node{Value: block})
	case "try", "except", "finally":
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "'"+code.Value+"' is not supported yet")
	case "switch":
		block := &SwitchBlock{}
		block.Parse(p)
	case "case":
		// 上一个 case 体结束后，ThisBlock 仍停在 CaseBlock 上；
		// 新 case 到来时先退回所属 SwitchBlock，否则 CaseBlock.Parse
		// 会误判为 "case outside of switch"。
		if _, isCase := p.ThisBlock.Value.(*CaseBlock); isCase {
			p.Back(1)
		}
		block := &CaseBlock{}
		block.Parse(p)
	case "default":
		if _, isCase := p.ThisBlock.Value.(*CaseBlock); isCase {
			p.Back(1)
		}
		block := &CaseBlock{IsDefault: true}
		block.Parse(p)
	}
}

func (p *Parser) processNameToken(code lexer.Token, beforeCursor int) {
	p.Lexer.SetCursor(beforeCursor)
	name, _ := p.ParseName(false)

	code2 := p.Lexer.Next()

	if code2.Value == "." {
		checkToken := p.Lexer.Next()
		if checkToken.Value == "(" {
			p.Lexer.SetCursor(code2.Cursor)
			fullName, _ := p.ParseName(false)
			call := &CallBlock{Name: fullName}
			call.Parse(p)
			return
		}
		// Check if after the field name there's an assignment operator
		// We need to parse the full field access first, then check for assignment
		p.Lexer.SetCursor(code2.Cursor)
		exp := p.fieldExpr(name)
		if exp == nil {
			return
		}
		// Check if next token is an assignment operator
		assignOp := p.Lexer.Next()
		assignOps := []string{"=", ":=", "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>="}
		isAssign := false
		for _, op := range assignOps {
			if assignOp.Value == op {
				isAssign = true
				break
			}
		}
		if isAssign {
			// This is a field assignment like container.count = 5
			p.Lexer.SetCursor(beforeCursor)
			block := &VarBlock{}
			block.Parse(p)
			return
		}
		// Not an assignment, just field access
		p.Lexer.SetCursor(assignOp.Cursor)
		exp.SetStmt()
		p.AddChild(&Node{Value: exp})
		return
	}

	switch code2.Value {
	case "(":
		p.Lexer.SetCursor(code2.Cursor)
		block := &CallBlock{Name: name}
		block.Parse(p)
	case "=", ":=", "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>=", "++", "--":
		// If name has multiple parts (field access), handle as expression assignment
		if len(name) > 1 {
			p.Lexer.SetCursor(beforeCursor)
			stopCursor := p.FindEndCursor()
			exp := p.ParseExp(stopCursor)
			if exp != nil {
				exp.SetStmt()
				exp.Check(p)
				p.AddChild(&Node{Value: exp})
			}
			return
		}
		p.Lexer.SetCursor(beforeCursor)
		block := &VarBlock{}
		block.Parse(p)
	case ":":
		// 类型注解声明（省略 var 的写法）：x: int = 5
		p.Lexer.SetCursor(beforeCursor)
		block := &VarBlock{}
		block.ParseKeywordVar(p, lexer.Token{Type: lexer.VAR, Value: "VAR"}, p.FindEndCursor())
		p.addDeclNode(&Node{Value: block})
	case ",":
		// 多返回值声明：q, r := divide(17, 5)
		p.parseMultiDeclare(beforeCursor)
	case "[":
		p.Lexer.SetCursor(beforeCursor)
		stopCursor := p.FindEndCursor()
		exp := p.ParseExp(stopCursor)
		if exp != nil {
			exp.SetStmt()
			p.AddChild(&Node{Value: exp})
		}
	default:
		beforeCursor++
		p.Error.MissErrors("Syntax Error", beforeCursor, beforeCursor+code.Len(), "'"+name.String()+"' is not a valid expression")
	}
}

// parseMultiDeclare 解析多返回值声明/赋值。
// := 模式：新建 owner VarBlock（MultiNames 为源码名）。
// = 模式（a, b = f()）：语义等价于先 tmp1, tmp2 := f()，再逐个 a = tmp1; b = tmp2。
func (p *Parser) parseMultiDeclare(beforeCursor int) {
	p.Lexer.SetCursor(beforeCursor)

	var names []Name
	var op string
	for {
		name, _ := p.ParseName(false)
		if name.Length() != 1 {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need variable name")
		}
		names = append(names, name)
		code := p.Lexer.Next()
		if code.Value == "," {
			continue
		}
		if code.Value == ":=" || code.Value == "=" {
			op = code.Value
			break
		}
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need ':=' or '=' in multi-value assignment")
	}

	exp := p.ParseExp(p.FindEndCursor())
	if exp == nil {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need value")
	}
	// 右侧是多返回值调用：按语句位置检查，绕开 "must return one value"，
	// 每个槽位的具体类型由 VarBlock.Check 在 Func 解析出来后填充。
	exp.SetStmt()

	if op == ":=" {
		vb := &VarBlock{
			Name:          names[0],
			IsDefine:      true,
			IsInitialized: true,
			Value:         exp,
			MultiNames:    names,
		}
		if !vb.Check(p) {
			// 跨包被调函数在解析期尚未合并进当前树，右侧调用无法绑定，
			// 多返回值类型自然也算不出来。节点不能丢：标记未解析，等
			// rootNode.Check() 在包合并后重试（否则后续引用只剩一个空壳）。
			vb.Unresolved = true
		}
		p.addDeclNode(&Node{Value: vb})
		return
	}

	// "=" 模式：a, b = f() → tmp1, tmp2 := f(); a = tmp1; b = tmp2
	multiAssignCounter++
	tmpNames := make([]Name, len(names))
	for i := range names {
		tmpNames[i] = NewName("__mvt" + itoa(multiAssignCounter) + "_" + itoa(i))
	}
	tmpVar := &VarBlock{
		Name:          tmpNames[0],
		IsDefine:      true,
		IsInitialized: true,
		Value:         exp,
		MultiNames:    tmpNames,
	}
	if !tmpVar.Check(p) {
		tmpVar.Unresolved = true
	}
	p.addDeclNode(&Node{Value: tmpVar})

	for i, name := range names {
		rhs := &Expression{Var: &VarBlock{Name: tmpNames[i]}}
		rhs.Var.ParseDefine(p)
		as := &VarBlock{
			Name:  name,
			Value: rhs,
		}
		as.Check(p)
		p.addDeclNode(&Node{Value: as})
	}
}

// fieldExpr 解析字段访问表达式（如 a.b.c），返回表达式节点。
// 将多级字段访问构建为左嵌套的 Expression 树：Separator="."，Left=左侧表达式，Right=字段名变量。
func (p *Parser) fieldExpr(name Name) *Expression {
	p.Lexer.Next() // 跳过 "."
	fieldName, _ := p.ParseName(false)
	if len(fieldName) == 0 {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "expected field name after '.'")
		return nil
	}

	// 构建左侧变量表达式
	left := &Expression{
		Var: &VarBlock{Name: name},
	}

	// 构建右侧字段名表达式
	right := &Expression{
		Var: &VarBlock{Name: fieldName},
	}

	// 构建 "." 运算表达式
	exp := &Expression{
		Separator: ".",
		Left:      left,
		Right:     right,
	}
	left.Father = exp
	right.Father = exp

	// 如果后面还有 "."，继续递归解析
	nextToken := p.Lexer.Next()
	if nextToken.Type == lexer.SEPARATOR && nextToken.Value == "." {
		p.Lexer.SetCursor(nextToken.Cursor)
		// 将当前表达式作为左侧，继续解析右侧字段
		return p.fieldExprFromExp(exp)
	}

	p.Lexer.SetCursor(nextToken.Cursor)
	return exp
}

// fieldExprFromExp 从已有的表达式继续解析字段访问（用于处理 a.b.c 的多级链式访问）。
func (p *Parser) fieldExprFromExp(left *Expression) *Expression {
	p.Lexer.Next() // 跳过 "."
	fieldName, _ := p.ParseName(false)
	if len(fieldName) == 0 {
		p.Error.MissError("Syntax Error", p.Lexer.Cursor, "expected field name after '.'")
		return nil
	}

	right := &Expression{
		Var: &VarBlock{Name: fieldName},
	}

	exp := &Expression{
		Separator: ".",
		Left:      left,
		Right:     right,
	}
	left.Father = exp
	right.Father = exp

	// 如果后面还有 "."，继续递归
	nextToken := p.Lexer.Next()
	if nextToken.Type == lexer.SEPARATOR && nextToken.Value == "." {
		p.Lexer.SetCursor(nextToken.Cursor)
		return p.fieldExprFromExp(exp)
	}

	p.Lexer.SetCursor(nextToken.Cursor)
	return exp
}

func (p *Parser) processVarToken(beforeCursor int, code lexer.Token) {
	p.Lexer.SetCursor(beforeCursor)
	// 游标位于关键字首字节：先读过关键字，再看下一 token 是否为 "("
	kw := p.Lexer.Next()
	if next := p.Lexer.Next(); next.Type == lexer.SEPARATOR && next.Value == "(" {
		switch kw.Value {
		case "var", "VAR":
			p.parseGroupedDecl("VAR")
		case "const", "CONST":
			p.parseGroupedDecl("CONST")
		case "let", "LET":
			p.parseGroupedDecl("LET")
		default:
			p.Error.MissError("Syntax Error", kw.Cursor, "expected var/const/let")
		}
		return
	}
	p.Lexer.SetCursor(beforeCursor)
	block := &VarBlock{}
	block.Parse(p)
}

func (p *Parser) processTypeToken(code lexer.Token) {
	// 分组形式：type ( ... )
	save := p.Lexer.Cursor
	if code.Value == "type" {
		if next := p.Lexer.Next(); next.Type == lexer.SEPARATOR && next.Value == "(" {
			if p.ThisBlock != p.Block {
				p.Error.MissError("Syntax Error", next.Cursor, "type declaration is only allowed at top level")
			}
			p.parseGroupedDecl("TYPE")
			return
		}
		p.Lexer.SetCursor(save)
	}
	switch code.Value {
	case "type":
		block := &TypeBlock{}
		block.Parse(p)
		p.addDeclNode(&Node{Value: block})
	case "struct":
		// struct Name { ... } 与 type Name struct { ... } 等价：统一构造 TypeBlock。
		// 若只挂一个裸 StructBlock，p.Find(name, FindTypeType) 认不出它
		// （finder 只匹配 *TypeBlock），导致 `var d: Dog` 与 `fn Dog.m()` 的
		// Class 绑定都失败，也拿不到全局类型注册与 Struct.Layout()。
		block := &TypeBlock{Kind: TypeStruct, Struct: &StructBlock{}}
		block.StartCursor = p.Lexer.Cursor
		p.CurTypeParams = nil
		nameToken := p.Lexer.Next()
		if nameToken.Type != lexer.NAME {
			p.Error.MissError("Struct Error", nameToken.Cursor, "expected struct name")
		}
		block.Name = NewName(nameToken.Value)
		// StructBlock.Parse 会自行读取结构体名称，回退到名称位置
		p.Lexer.SetCursor(nameToken.Cursor)
		savedName := p.CurStructName
		savedType := p.CurStructType
		p.CurStructName = nameToken.Value
		p.CurStructType = &block.Struct.Type
		block.Struct.Parse(p)
		p.CurStructName = savedName
		p.CurStructType = savedType
		block.EndCursor = block.Struct.EndCursor
		if p.Package != nil && p.Package.Path != "" && !p.pendingDeclIgnored() {
			packageFmt.RegisterType(p.Package.Path, block.Name.String(), block.Type())
		}
		// build align(N)/noalign 紧随其后才生效（严格紧随：隔了其他声明即孤儿）
		p.attachPendingAlign(&block.Struct.Type)
		p.addDeclNode(&Node{Value: block})
	case "interface":
		if p.ThisBlock != p.Block {
			p.Error.MissError("Syntax Error", code.Cursor, "interface declaration is only allowed at top level")
		}
		nameToken := p.Lexer.Next()
		if nameToken.Type != lexer.NAME {
			p.Error.MissError("Syntax Error", nameToken.Cursor, "need interface name")
		}
		block := p.newInterfaceBlock(p.Lexer.Cursor, nameToken)
		p.addDeclNode(&Node{Value: block})
	case "enum":
		p.processEnumToken()
	default:
		p.processDefaultToken(code)
	}
}

func (p *Parser) processBuildToken(token lexer.Token) {
	block := &Build{}
	block.Parse(p)
}

// processImportToken 解析文件级 import 声明（Wave L）。
// 语法校验在 ImportBlock.Parse；别名注册由 package 层的
// registerFileImports 在解析开始前完成（别名可见性 = 包级，与 json 一致）。
// 这里只把条目记进 FileImports，不向语法树挂节点。
func (p *Parser) processImportToken(code lexer.Token) {
	block := &ImportBlock{}
	block.Parse(p)
	for _, item := range block.Items {
		p.FileImports = appendImportItem(p, p.FileImports, item)
	}
}

// processDerefStmt 解析以 * 开头的解引用赋值/表达式语句
func (p *Parser) processDerefStmt(beforeCursor int) {
	p.Lexer.SetCursor(beforeCursor)
	p.PreventNameAssign = true
	exp := p.ParseExp(p.FindEndCursor())
	p.PreventNameAssign = false
	if exp == nil {
		return
	}
	exp.SetStmt()
	p.AddChild(&Node{Value: exp})
}

func (p *Parser) processDefaultToken(code lexer.Token) {
	if code.Value != ";" && code.Value != "\n" && code.Value != "\r" {
		p.Lexer.Error.MissError("Syntax Error", p.Lexer.Cursor, "Miss "+code.Value)
	}
}

// AddChild 向当前作用域添加子节点
func (p *Parser) AddChild(node *Node) {
	p.ThisBlock.AddChild(node)
}

// Back 从当前作用域回退 num 层
func (p *Parser) Back(num int) error {
	if num == 0 {
		return nil
	}
	if p.ThisBlock.Father == nil {
		p.Error.MissError("Internal Compiler Errors", p.Lexer.Cursor, "Back at root")
	}
	if p.DontBack != 0 {
		p.DontBack--
		return p.Back(num - 1)
	}
	p.ThisBlock = p.ThisBlock.Father
	if num < 0 {
		num = -num
	}
	return p.Back(num - 1)
}

// Need 持续读取 Token 直到遇到指定值，返回所有经过的 Token
func (p *Parser) Need(value string) []lexer.Token {
	tmp2 := []lexer.Token{}
	for {
		tmp := p.Lexer.Next()
		if tmp.IsEmpty() {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need '"+value+"'")
		}
		if tmp.Value == "\n" {
			p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need '"+value+"'")
		}
		tmp2 = append(tmp2, tmp)
		if tmp.Value == value && tmp.Type != lexer.STRING && tmp.Type != lexer.RAW {
			return tmp2
		}
	}
}

// FindEndCursor 查找当前语句末尾的光标位置（下一行的 LineFeed 起点；行尾是 EOF 则返回 len-1）。
// 对字符串字面量具备感知能力："" / '' / `` 包裹的换行不被视为语句结束，
// 因此 `"a\nb"`（字面含义）与跨行的裸字符串都能正确定位到语句尾。
func (p *Parser) FindEndCursor() int {
	text := p.Lexer.Text
	lineFeed := p.Lexer.LineFeed
	n := len(text)
	i := p.Lexer.Cursor
	for i < n {
		c := text[i]
		switch c {
		case '"':
			// 普通字符串：跳过到闭合引号（含反斜杠转义跳过）
			i++
			for i < n && text[i] != '"' {
				if text[i] == '\\' {
					i++ // 跳过转义字符
				}
				i++
			}
			if i < n {
				i++ // 跳过闭合引号
			}
			continue
		case '`':
			// 裸字符串：原样到下一个反引号
			i++
			for i < n && text[i] != '`' {
				i++
			}
			if i < n {
				i++
			}
			continue
		case '\'':
			// 字符字面量（含转义）
			i++
			for i < n && text[i] != '\'' {
				if text[i] == '\\' {
					i++
				}
				i++
			}
			if i < n {
				i++
			}
			continue
		default:
			if i+len(lineFeed) <= n && text[i:i+len(lineFeed)] == lineFeed {
				return i
			}
			i++
		}
	}
	return n - 1
}

// Wait 等待并跳过直到遇到指定值，返回经过的 Token 数量
func (p *Parser) Wait(value string) int {
	return len(p.Need(value))
}

// Has 在指定范围内查找匹配的 Token，返回其结束位置
func (p *Parser) Has(token lexer.Token, stopCursor int) int {
	startCursor := p.Lexer.Cursor
	for stopCursor > p.Lexer.Cursor {
		code := p.Lexer.Next()
		if code.IsEmpty() {
			p.Lexer.Error.MissError("Invalid expression", p.Lexer.Cursor, "Incomplete expression")
		}
		if code.Value == token.Value && code.Type == token.Type {
			cursorTmp := p.Lexer.Cursor
			p.Lexer.SetCursor(startCursor)
			return cursorTmp
		}
	}
	p.Lexer.SetCursor(startCursor)
	return -1
}

// CheckUnusedVar 递归检查未使用的变量定义
func (p *Parser) CheckUnusedVar(node *Node) {
	for i := 0; i < len(node.Children); i++ {
		/*if node.Children[i].CFG == nil {
			node.Children = append(node.Children[:i], node.Children[i+1:]...)
			i--
		}*/
		switch node.Children[i].Value.(type) {
		case *VarBlock:
			varBlock := node.Children[i].Value.(*VarBlock)
			if varBlock.IsDefine && !varBlock.Used {
				p.Lexer.Error.MissErrors("Variable Error", varBlock.StartCursor-len(varBlock.Name)+1, varBlock.StartCursor, varBlock.Name.String()+" is unused")
			}
		}
		p.CheckUnusedVar(node.Children[i])
	}
}

// NewParser 创建新的语法分析器
func NewParser(lexer *lexer.Lexer) *Parser {
	p := &Parser{
		Lexer: lexer,
		Error: lexer.Error,
	}
	p.Block = &Node{}
	p.ThisBlock = p.Block
	return p
}

// Parse 执行完整的语法分析，返回 AST 根节点
func (p *Parser) Parse() *Node {
	for {
		if p.Next() {
			if p.Block != p.ThisBlock {
				p.Error.MissError("Syntax Error", p.Lexer.Cursor, "need '}'")
			}
			file, _ := os.OpenFile("ast.html", os.O_CREATE|os.O_WRONLY, 0644)
			file.Truncate(0)
			defer file.Close()
			generateASTHTML(p.Block, file)
			break
		}
	}
	return p.Block
}
