package parser

import (
	"os"
	"strings"

	packageFmt "cuteify/package/fmt"
	typeSys "cuteify/type"
)

// IntrinsicForm 类型内建算子表的目标形态。
type IntrinsicForm uint8

const (
	// IntrinsicCall 降成一次普通函数调用（parser Check 期改写为 CallBlock）。
	IntrinsicCall IntrinsicForm = iota
	// IntrinsicNative 保留编译器现有内建/代码生成（不在 parser 期改写）。
	IntrinsicNative
	// IntrinsicIndexGet 索引读，需要 codegen 分配临时地址（map[k]）。
	IntrinsicIndexGet
	// IntrinsicIndexSet 索引写，需要 codegen 分配临时地址（map[k] = v）。
	IntrinsicIndexSet
)

// IntrinsicEntry 描述“某类型的某操作由哪个 std 实现承载”。
// 这是类型映射的唯一事实源：parser / codegen / 文档都应查这张表。
type IntrinsicEntry struct {
	Kind string // string | map | list
	Op   string // ==, !=, +, [], []=, len, cap ...
	Pkg  string // std:strings / std:maps / std:slices；Native 时为空
	Fn   string // 包内函数名；Native 时为空
	Form IntrinsicForm
	Phase int // 1=string, 2=map, 3=list
}

// IntrinsicFuncs 已解析包内函数的注册表，键为完整包路径 + "." + 函数名。
// 根包文件的 Check 可能在包合并前发生（var 初始化、字段赋值等在解析期检查），
// 此时 p.Find 看不到依赖包；预加载包时把 FuncBlock 指针登记到这里，
// 内建映射即可在解析期直接绑定。合并后指针仍指向同一棵树的函数块。
var IntrinsicFuncs = map[string]*FuncBlock{}

// RegisterIntrinsicFunc 由包加载器登记已解析的顶层函数。
func RegisterIntrinsicFunc(fb *FuncBlock) {
	if fb == nil || fb.Name.IsEmpty() {
		return
	}
	IntrinsicFuncs[fb.Name.String()] = fb
}

// IntrinsicPkgs 由 packageSys 在根包加载时填充：逻辑包名（strings/maps/slices）
// → 解析后的本地目录。parser 不直接依赖 packageSys，避免循环 import。
var IntrinsicPkgs = map[string]string{}

// intrinsicTable 第一版表。Native 行只用于文档/后续切换，不参与 lowering。
var intrinsicTable = []IntrinsicEntry{
	// string：内容比较交给 std:strings.eq/ne；+ / len / cap / 索引保留原生实现。
	{Kind: "string", Op: "==", Pkg: "std:strings", Fn: "eq", Form: IntrinsicCall, Phase: 1},
	{Kind: "string", Op: "!=", Pkg: "std:strings", Fn: "ne", Form: IntrinsicCall, Phase: 1},
	{Kind: "string", Op: "+", Form: IntrinsicNative, Phase: 1},
	{Kind: "string", Op: "len", Form: IntrinsicNative, Phase: 1},
	{Kind: "string", Op: "cap", Form: IntrinsicNative, Phase: 1},
	{Kind: "string", Op: "[]", Form: IntrinsicNative, Phase: 1},
	{Kind: "string", Op: "[]=", Form: IntrinsicNative, Phase: 1},

	// map：索引读写在 codegen 降低；len 保留原生实现（nil map 返回 0，
	// 直接调 std:maps.len 会解引空 header）。
	{Kind: "map", Op: "len", Form: IntrinsicNative, Phase: 2},
	{Kind: "map", Op: "[]", Pkg: "std:maps", Fn: "get", Form: IntrinsicIndexGet, Phase: 2},
	{Kind: "map", Op: "[]=", Pkg: "std:maps", Fn: "set", Form: IntrinsicIndexSet, Phase: 2},

	// list：现有编译器内建优先；std:slices 仅作为自动可用的命名 API。
	{Kind: "list", Op: "len", Form: IntrinsicNative, Phase: 3},
	{Kind: "list", Op: "cap", Form: IntrinsicNative, Phase: 3},
	{Kind: "list", Op: "[]", Form: IntrinsicNative, Phase: 3},
	{Kind: "list", Op: "[]=", Form: IntrinsicNative, Phase: 3},
}

// LookupIntrinsic 查表。kind/op 为空或未命中返回 nil。
func LookupIntrinsic(kind, op string) *IntrinsicEntry {
	if kind == "" || op == "" {
		return nil
	}
	for i := range intrinsicTable {
		e := &intrinsicTable[i]
		if e.Kind == kind && e.Op == op {
			return e
		}
	}
	return nil
}

// IntrinsicDisabled 是否通过环境变量关闭隐式映射。
func IntrinsicDisabled() bool {
	return os.Getenv("CUTE_NO_INTRINSIC") != ""
}

// intrinsicPkgPath 返回逻辑包名对应的本地路径；未加载时返回空。
func intrinsicPkgPath(pkg string) string {
	pkg = strings.TrimPrefix(pkg, "std:")
	return IntrinsicPkgs[pkg]
}

// makeIntrinsicName 用完整包路径构造调用名，避免占用用户 import 别名。
// 包路径必须与合并树中的名字一致：所有包名在加载时经过 FixPathName
// （非 ASCII 目录字符会被替换成 '_'）。
func makeIntrinsicName(pkgPath, fn string) Name {
	return Name{
		{Name: packageFmt.FixPathName(pkgPath), IsPkgPath: true},
		{Name: fn},
	}
}

// resolveIntrinsicFunc 查找目标函数。
// 优先查加载期注册表：根包文件在解析期就会做部分 Check，此时依赖包还没合并进
// 根 AST，p.Find 看不到它们。注册表保存的是同一批 FuncBlock 指针，合并后仍有效。
func resolveIntrinsicFunc(p *Parser, entry *IntrinsicEntry) *FuncBlock {
	if entry == nil || entry.Pkg == "" || entry.Fn == "" {
		return nil
	}
	path := intrinsicPkgPath(entry.Pkg)
	if path == "" {
		return nil
	}
	name := makeIntrinsicName(path, entry.Fn)
	if fb := IntrinsicFuncs[name.String()]; fb != nil {
		return fb
	}
	results := p.Find(name, FindTypeFunc)
	for _, r := range results {
		if fb, ok := r.Value.(*FuncBlock); ok {
			return fb
		}
	}
	return nil
}

// LookupIntrinsicFunc 按逻辑包名（"std:maps" 或 "maps"）和函数名取已登记的包函数。
// 根包文件解析期依赖包尚未合并时也能命中（注册表保存同一批 FuncBlock 指针）。
func LookupIntrinsicFunc(pkg, fn string) *FuncBlock {
	path := intrinsicPkgPath(pkg)
	if path == "" {
		return nil
	}
	name := makeIntrinsicName(path, fn)
	return IntrinsicFuncs[name.String()]
}

// isStringLiteral 判断表达式是否为字符串字面量（含常量折叠后的字面量）。
func isStringLiteral(exp *Expression) bool {
	return exp != nil && exp.Var == nil && exp.Call == nil && exp.Separator == "" &&
		exp.Type != nil && exp.Type.Kind() == "string"
}

// tryIntrinsicStringEq 在 string ==/!= 的运行期路径上把表达式改写成
// std:strings.eq/ne 调用。常量字面量仍走本地折叠，避免无谓调用。
//
// 调用时机：checkEq 开头，左右子节点已完成 Check。
func (exp *Expression) tryIntrinsicStringEq(p *Parser) bool {
	if IntrinsicDisabled() {
		return false
	}
	if exp.Left == nil || exp.Right == nil {
		return false
	}
	if exp.Left.Type == nil || exp.Right.Type == nil {
		return false
	}
	if exp.Left.Type.Kind() != "string" || exp.Right.Type.Kind() != "string" {
		return false
	}
	entry := LookupIntrinsic("string", exp.Separator)
	if entry == nil || entry.Form != IntrinsicCall {
		return false
	}

	// 两个字面量在编译期比较，避免引入调用；StringVal 是源码字面量内容。
	if isStringLiteral(exp.Left) && isStringLiteral(exp.Right) {
		eq := exp.Left.StringVal == exp.Right.StringVal
		if exp.Separator == "!=" {
			eq = !eq
		}
		exp.Bool = eq
		exp.Type = typeSys.GetSystemType("bool")
		exp.foldBin()
		return true
	}

	fb := resolveIntrinsicFunc(p, entry)
	if fb == nil {
		// std 包未加载时回退旧行为；CUTE_NO_INTRINSIC 已显式关闭。
		return false
	}
	if len(fb.Args) != 2 {
		return false
	}
	fb.Useful = true

	exp.Call = &CallBlock{
		Name: fb.Name,
		Func: fb,
		Args: []*ArgBlock{
			{Value: exp.Left, Type: exp.Left.Type},
			{Value: exp.Right, Type: exp.Right.Type},
		},
	}
	exp.Separator = ""
	exp.Left = nil
	exp.Right = nil
	exp.Type = typeSys.GetSystemType("bool")
	return true
}
