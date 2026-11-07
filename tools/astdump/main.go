// astdump 输出单个 .cute 文件的规范化 AST 文本，用于与自举 parser 逐节点对拍。
//
// Go parser 的 AST 是有损/已脱糖的（const 不带 IsConst、+=/++ 都变成
// x = x + 1、for 的 init/post 被提升/下沉等）。本工具按 Go 可观察形状
// 归一化成稳定文本；自举 parser 在 S3 按同一形状构建并输出。
//
// 用法：astdump <file.cute>
package main

import (
	"cuteify/lexer"
	"cuteify/parser"
	typeSys "cuteify/type"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

type printer struct {
	b strings.Builder
	d int
}

func (p *printer) line(format string, args ...any) {
	p.b.WriteString(strings.Repeat("  ", p.d))
	fmt.Fprintf(&p.b, format, args...)
	p.b.WriteByte('\n')
}

// typeStr 把解析后的类型还原成源码形状的规范文本。
//
// 系统类型名保持原样；指针类型在 Go 里 TypeName 只存元素名，必须靠
// RType.IsPtr 补回 '*'; 容器类型按 Elem/Key/Len 递归拼。
func typeStr(t typeSys.Type) string {
	if t == nil {
		return "?"
	}
	switch v := t.(type) {
	case *typeSys.RType:
		if v.IsPtr {
			return "*" + typeStr(v.Parent())
		}
		return v.TypeName
	case *typeSys.AliasType:
		return v.TypeName
	case *typeSys.ListType:
		return "[]" + typeStr(v.Elem())
	case *typeSys.ArrayType:
		return "[" + strconv.Itoa(v.Len()) + "]" + typeStr(v.Elem())
	case *typeSys.MapType:
		return "map[" + typeStr(v.Key()) + "]" + typeStr(v.Elem())
	case *typeSys.FuncType:
		// FuncType.String() 在参数列表后固定带一个空格（fn() / fn(int) T），
		// canonical 文本去掉尾部空格，避免与自举侧源码形状不一致。
		return strings.TrimRight(v.String(), " ")
	case *typeSys.TypeParam:
		return v.String()
	case *typeSys.StructType:
		return v.TypeName
	default:
		return t.Type()
	}
}

func varFlags(v *parser.VarBlock) string {
	var b strings.Builder
	if v.IsConst {
		b.WriteByte('c')
	}
	if v.IsGlobal {
		b.WriteByte('g')
	}
	if v.IsDefine {
		b.WriteByte('d')
	}
	if v.IsInitialized {
		b.WriteByte('i')
	}
	if v.RangeVar {
		b.WriteByte('r')
	}
	return b.String()
}

func (p *printer) varNode(v *parser.VarBlock) {
	f := varFlags(v)
	if f == "" {
		p.line("VAR name=%s", v.Name.String())
	} else {
		p.line("VAR name=%s flags=%s", v.Name.String(), f)
	}
	if v.Value != nil {
		p.d++
		p.expr(v.Value)
		p.d--
	}
}

func (p *printer) args(args []*parser.ArgBlock) {
	for _, a := range args {
		suffix := ""
		if a.IsVariadic {
			suffix = " variadic=1"
		}
		p.line("ARG name=%s type=%s%s", a.Name.String(), typeStr(a.Type), suffix)
	}
}

func (p *printer) typeBlock(t *parser.TypeBlock, isEnum bool) {
	switch t.Kind {
	case parser.TypeStruct:
		p.line("TYPE name=%s kind=struct", t.Name.String())
		if t.Struct != nil {
			for _, f := range t.Struct.Type.Fields() {
				suffix := ""
				if f.IsAnon {
					suffix = " anon=1"
				}
				if f.Access != typeSys.AccessPublic {
					suffix += " access=" + strconv.Itoa(int(f.Access))
				}
				p.lineIndent(1, "FIELD name=%s type=%s%s", f.Name, typeStr(f.Type), suffix)
			}
		}
	case parser.TypeInterface:
		p.line("TYPE name=%s kind=interface", t.Name.String())
		if t.Interface != nil {
			for _, m := range t.Interface.Methods {
				p.lineIndent(1, "METHOD name=%s nargs=%d", m.Name.String(), len(m.Args))
				for _, r := range m.Returns {
					p.lineIndent(2, "RET type=%s", typeStr(r))
				}
			}
		}
	case parser.TypeAlias:
		if isEnum {
			p.line("TYPE name=%s kind=enum", t.Name.String())
			return
		}
		kind := "newtype"
		under := "?"
		if a, ok := t.Alias.(*typeSys.AliasType); ok {
			if a.IsTrueAlias {
				kind = "alias"
			}
			under = typeStr(a.Underlying)
		} else {
			under = typeStr(t.Alias)
		}
		p.line("TYPE name=%s kind=%s under=%s", t.Name.String(), kind, under)
	}
}

// lineIndent 在额外缩进下输出一行，用于 TYPE 的字段/方法等元数据行。
func (p *printer) lineIndent(extra int, format string, args ...any) {
	p.d += extra
	p.line(format, args...)
	p.d -= extra
}

func (p *printer) node(n *parser.Node) {
	switch v := n.Value.(type) {
	case nil:
		p.line("FILE")
		for _, c := range n.Children {
			p.d++
			p.node(c)
			p.d--
		}
	case *parser.VarBlock:
		p.varNode(v)
	case *parser.TypeBlock:
		p.typeBlock(v, enumTypes[v])
		for _, c := range n.Children {
			p.d++
			p.node(c)
			p.d--
		}
	case *parser.FuncBlock:
		p.line("FN name=%s", v.Name.String())
		p.d++
		p.args(v.Args)
		for _, r := range v.Return {
			p.line("RET type=%s", typeStr(r))
		}
		for _, c := range n.Children {
			p.node(c)
		}
		p.d--
	case *parser.IfBlock:
		p.line("IF")
		p.d++
		if v.Condition != nil {
			p.line("COND")
			p.d++
			p.expr(v.Condition)
			p.d--
		}
		for _, c := range n.Children {
			p.node(c)
		}
		if v.ElseBlock != nil {
			p.line("ELSE")
			p.d++
			for _, c := range v.ElseBlock.Children {
				p.node(c)
			}
			p.d--
		}
		p.d--
	case *parser.ElseBlock:
		for _, c := range n.Children {
			p.node(c)
		}
	case *parser.ForBlock:
		p.line("FOR")
		p.d++
		if v.Init != nil {
			p.line("INIT")
			p.d++
			p.expr(v.Init)
			p.d--
		}
		if v.Condition != nil {
			p.line("COND")
			p.d++
			p.expr(v.Condition)
			p.d--
		}
		if v.Increment != nil {
			p.line("POST")
			p.d++
			p.expr(v.Increment)
			p.d--
		}
		if v.Range != nil {
			p.line("RANGE")
			p.d++
			p.expr(v.Range)
			p.d--
			for _, rn := range v.RangeNames {
				p.line("RNAME name=%s", rn.Name.String())
			}
		}
		for _, c := range n.Children {
			p.node(c)
		}
		p.d--
	case *parser.SwitchBlock:
		p.line("SWITCH")
		p.d++
		if v.Target != nil {
			p.line("TARGET")
			p.d++
			p.expr(v.Target)
			p.d--
		}
		for _, c := range n.Children {
			p.node(c)
		}
		p.d--
	case *parser.CaseBlock:
		if v.IsDefault {
			p.line("CASE default=1")
		} else {
			p.line("CASE")
		}
		p.d++
		for _, val := range v.Values {
			p.line("VAL")
			p.d++
			p.expr(val)
			p.d--
		}
		for _, c := range n.Children {
			p.node(c)
		}
		p.d--
	case *parser.ReturnBlock:
		p.line("RETURN")
		p.d++
		for _, e := range v.Value {
			p.expr(e)
		}
		p.d--
	case *parser.BreakBlock:
		p.line("BREAK level=%d", v.Level)
	case *parser.CallBlock:
		// 节点位置的 CallBlock：语句级函数调用。Go 版 parser 不区分
		// defer 与普通调用（defer token 在 processControlToken 里被丢弃），
		// 因此二者 canonical 形状相同。
		p.call(v)
	case *parser.Expression:
		// 字段赋值 p.x = 1 会额外挂一个裸变量引用 Expression，属于
		// Go parser 的实现噪声；纯 VAR-REF 语句没有语义，统一丢弃。
		if v.Call == nil && v.Separator == "" && v.Left == nil && v.Right == nil &&
			v.Var != nil && len(v.ListElems) == 0 {
			for _, c := range n.Children {
				p.node(c)
			}
			return
		}
		p.line("EXPR")
		p.d++
		p.expr(v)
		p.d--
		for _, c := range n.Children {
			p.node(c)
		}
	case *parser.Build:
		// build 是编译指令，不进规范化 AST（S3 v0 范围声明）。
		for _, c := range n.Children {
			p.node(c)
		}
	default:
		p.line("UNKNOWN %T", n.Value)
		for _, c := range n.Children {
			p.node(c)
		}
	}
}

func (p *printer) call(c *parser.CallBlock) {
	p.line("CALL name=%s", c.Name.String())
	p.d++
	for _, a := range c.Args {
		p.line("ARG")
		if a.Value != nil {
			p.d++
			p.expr(a.Value)
			p.d--
		}
	}
	p.d--
}

func (p *printer) expr(e *parser.Expression) {
	if e == nil {
		p.line("EXP nil")
		return
	}
	if e.Call != nil {
		p.call(e.Call)
		return
	}
	if e.Separator == "list_lit" || e.Separator == "array_lit" {
		if e.Separator == "list_lit" {
			p.line("LIST")
		} else {
			p.line("ARRAY")
		}
		p.d++
		for _, el := range e.ListElems {
			p.expr(el)
		}
		p.d--
		return
	}
	if e.Separator == "[]" {
		idx := e.Index
		// IndexSlice 区分 a[i] 与 a[i:]：后者 hi/step 都省略时
		// Index[1]/Index[2] 也是 nil，只靠下标判空会误判成 INDEX。
		if !e.IndexSlice && idx[0] != nil && idx[1] == nil && idx[2] == nil {
			p.line("INDEX")
			p.d++
			p.expr(e.Right)
			p.expr(idx[0])
			p.d--
			return
		}
		p.line("SLICE")
		p.d++
		p.expr(e.Right)
		if idx[0] != nil {
			p.line("LO")
			p.d++
			p.expr(idx[0])
			p.d--
		}
		if idx[1] != nil {
			p.line("HI")
			p.d++
			p.expr(idx[1])
			p.d--
		}
		if idx[2] != nil {
			p.line("MAX")
			p.d++
			p.expr(idx[2])
			p.d--
		}
		p.d--
		return
	}
	if e.Separator != "" {
		if e.Left != nil && e.Right != nil {
			p.line("BIN op=%s", e.Separator)
			p.d++
			p.expr(e.Left)
			p.expr(e.Right)
			p.d--
			return
		}
		if e.Right != nil {
			p.line("UN op=%s", e.Separator)
			p.d++
			p.expr(e.Right)
			p.d--
			return
		}
	}
	if e.Var != nil {
		p.line("NAME %s", e.Var.Name.String())
		return
	}
	if e.ConstNil {
		p.line("NIL")
		return
	}
	if e.Type != nil && e.Type.Kind() == "string" {
		p.line("STR %q", e.StringVal)
		return
	}
	if e.Type != nil && e.Type.Kind() == "bool" {
		p.line("BOOL %v", e.Bool)
		return
	}
	if e.Type != nil {
		p.line("LIT %v", e.Num)
		return
	}
	p.line("EXPR?")
}

// enumTypes 记录哪些 TypeBlock 是 enum 声明。
//
// enum 在 Go AST 里没有专门节点：TypeBlock 是 alias 壳，成员是紧跟其后的
// 兄弟 VarBlock(IsConst=true)。只能在根节点序列上做一次前瞻标记。
var enumTypes = map[*parser.TypeBlock]bool{}

func markEnumTypes(root *parser.Node) {
	for i, c := range root.Children {
		tb, ok := c.Value.(*parser.TypeBlock)
		if !ok || tb.Kind != parser.TypeAlias {
			continue
		}
		for j := i + 1; j < len(root.Children); j++ {
			vb, ok := root.Children[j].Value.(*parser.VarBlock)
			if !ok || !vb.IsConst {
				break
			}
			if vb.Type != nil && vb.Type.Type() == tb.Name.String() {
				enumTypes[tb] = true
				break
			}
		}
	}
}

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintln(os.Stderr, "usage: astdump <file.cute>")
		os.Exit(2)
	}
	abs, err := filepath.Abs(os.Args[1])
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(2)
	}
	// parser.Parse() 会在 cwd 写 ast.html；换到临时目录避免污染仓库。
	tmp, err := os.MkdirTemp("", "astdump")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(2)
	}
	defer os.RemoveAll(tmp)
	if err := os.Chdir(tmp); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(2)
	}
	lex := lexer.NewLexer(abs)
	p := parser.NewParser(lex)
	p.Block.Parser = p
	root := p.Parse()
	markEnumTypes(root)
	var pr printer
	pr.node(root)
	os.Stdout.WriteString(pr.b.String())
}
