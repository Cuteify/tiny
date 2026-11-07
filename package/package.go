package packageSys

import (
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
	"cuteify/parser"
	"encoding/json"
	"os"
	"path"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"
)

type All struct {
	Funcs map[string]*parser.Node
	Types map[string]*parser.Node
}

var packages = make(map[string]*packageFmt.Info)

// 文件级 build 指令预检正则（仅匹配行首无缩进的顶层 build 语句）
var (
	reBuildArch = regexp.MustCompile(`(?m)^build\s+arch\s*\(([^)]*)\)`)
	reBuildOS   = regexp.MustCompile(`(?m)^build\s+os\s*\(([^)]*)\)`)
)

// preFilterBuild 在解析前检查文件级 build arch/os 指令。
// 返回 false 表示该文件不匹配当前架构/系统，应跳过。
func splitNames(s string) []string {
	var names []string
	for _, f := range strings.FieldsFunc(s, func(r rune) bool {
		return r == ',' || r == '"' || r == '\'' || r == ' ' || r == '\t'
	}) {
		names = append(names, f)
	}
	return names
}

func preFilterBuild(pkgPath string) (bool, error) {
	content, err := os.ReadFile(pkgPath)
	if err != nil {
		return false, err
	}
	currentArch := os.Getenv("CUTE_ARCH")
	if currentArch == "" {
		currentArch = "x86"
	}
	if m := reBuildArch.FindStringSubmatch(string(content)); m != nil {
		matched := false
		for _, n := range splitNames(m[1]) {
			if n == currentArch {
				matched = true
				break
			}
		}
		if !matched {
			return false, nil
		}
	}
	if m := reBuildOS.FindStringSubmatch(string(content)); m != nil {
		matched := false
		for _, n := range splitNames(m[1]) {
			if n == runtime.GOOS {
				matched = true
				break
			}
		}
		if !matched {
			return false, nil
		}
	}
	return true, nil
}

var all *All = &All{
	Funcs: make(map[string]*parser.Node),
	Types: make(map[string]*parser.Node),
}

// fixNamePath 固定一个跨包名称的第一段。
// 先按导入别名解析；别名里没有、且第一段正好等于本包名时，按“包名自引用”
// 固定为本包完整路径——std 包内部大量使用 `strings.foo` 这种写法，但包
// 不会 import 自己，根包也没有对应别名。若不处理，这些调用在合并后的
// Find 中永远匹配不到完整路径函数，Check 无法把被调函数标记 Useful。
func fixNamePath(name *parser.Name, pkg *packageFmt.Info) bool {
	if name == nil || pkg == nil || !name.IsPath() {
		return false
	}
	if name.FixPath(pkg) {
		return true
	}
	if (*name)[0].Name != pkg.Name || pkg.Name == "" || pkg.Path == "" {
		return false
	}
	(*name)[0].Name = packageFmt.FixPathName(pkg.Path)
	(*name)[0].IsPkgPath = true
	return true
}

// fixPkgNamePaths 使用包自身的导入表把跨包名称的第一段固定为包路径前缀。
// 合并后的树共享根 Parser（根包导入表不含本包别名），若不在此固定，
// rootNode.Check 阶段的 FixPath 找不到别名，导致跨包调用解析失败
// （Func 为 nil、不被标记 Useful，调用不生成代码）。
// 第一段不是导入别名的名称（结构体方法、局部变量等）保持原样。
func fixPkgNamePaths(n *parser.Node, pkg *packageFmt.Info) {
	if n == nil {
		return
	}
	switch v := n.Value.(type) {
	case *parser.CallBlock:
		if v.Name.IsPath() {
			fixNamePath(&v.Name, pkg)
		} else if v.Func == nil {
			v.Name.SetPkgPath(pkg.Path)
		}
		for _, arg := range v.Args {
			if arg != nil && arg.Value != nil {
				fixExpNamePaths(arg.Value, pkg)
			}
		}
	case *parser.Expression:
		fixExpNamePaths(v, pkg)
	case *parser.VarBlock:
		if v.Value != nil {
			fixExpNamePaths(v.Value, pkg)
		}
	case *parser.ReturnBlock:
		for _, exp := range v.Value {
			if exp != nil {
				fixExpNamePaths(exp, pkg)
			}
		}
	case *parser.IfBlock:
		if v.Condition != nil {
			fixExpNamePaths(v.Condition, pkg)
		}
		if v.ElseBlock != nil {
			fixPkgNamePaths(v.ElseBlock, pkg)
		}
	case *parser.ElseBlock:
		if v.IfCondition != nil {
			fixExpNamePaths(v.IfCondition, pkg)
		}
	case *parser.ForBlock:
		if v.Init != nil {
			fixExpNamePaths(v.Init, pkg)
		}
		if v.Condition != nil {
			fixExpNamePaths(v.Condition, pkg)
		}
		if v.Increment != nil {
			fixExpNamePaths(v.Increment, pkg)
		}
	}
	for _, c := range n.Children {
		fixPkgNamePaths(c, pkg)
	}
}

// fixExpNamePaths 递归修复表达式树中的跨包调用/变量名
func fixExpNamePaths(exp *parser.Expression, pkg *packageFmt.Info) {
	if exp == nil {
		return
	}
	if exp.Call != nil {
		if exp.Call.Name.IsPath() {
			fixNamePath(&exp.Call.Name, pkg)
		} else if exp.Call.Func == nil {
			exp.Call.Name.SetPkgPath(pkg.Path)
		}
		for _, arg := range exp.Call.Args {
			if arg != nil && arg.Value != nil {
				fixExpNamePaths(arg.Value, pkg)
			}
		}
	}
	if exp.Var != nil {
		if exp.Var.Name.IsPath() {
			fixNamePath(&exp.Var.Name, pkg)
		} else if exp.Var.Type == nil {
			// 同包跨文件全局变量/常量引用（parse 期未解析出类型）
			exp.Var.Name.SetPkgPath(pkg.Path)
		}
	}
	fixExpNamePaths(exp.Left, pkg)
	fixExpNamePaths(exp.Right, pkg)
	for _, idx := range exp.Index {
		fixExpNamePaths(idx, pkg)
	}
	for _, elem := range exp.ListElems {
		fixExpNamePaths(elem, pkg)
	}
}

func GetPackage(packagePath string, isRoot bool) (*packageFmt.Info, error) {
	// 列出目录下所有文件
	files, err := os.ReadDir(packagePath)
	if err != nil {
		return nil, err // 返回错误
	}

	// 打开package.json文件（Wave L：package.json 可选——缺失时合成默认信息，name = 目录名）
	packageInfo := &packageFmt.Info{}
	packFile, err := os.OpenFile(path.Join(packagePath, "package.json"), os.O_RDONLY, 0666)
	if err == nil {
		// 解码package.json内容
		jsonDe := json.NewDecoder(packFile)
		if err := jsonDe.Decode(packageInfo); err != nil {
			packFile.Close()
			return nil, err // 返回错误
		}
		packFile.Close()
	} else if os.IsNotExist(err) {
		packageInfo.Name = path.Base(packagePath)
	} else {
		return nil, err // 打开失败（非不存在）仍报错
	}
	// Wave I：package.json 只承载 name/version/description/builtin 等元数据，
	// imports 字段被 Info 的 `json:"-"` 完全忽略——依赖声明唯一通道 = 文件级 import。
	packageInfo.Path = packagePath
	packageInfo.AST = &parser.Node{}
	//packageInfo.Children = make(map[string]*packageFmt.Info)
	if isRoot {
		// Wave L：记录项目根（绝对路径）与项目名，供 name:rel 与 :vendor 解析
		if abs, err := filepath.Abs(packagePath); err == nil {
			projectRoot = abs
		}
		projectName = packageInfo.Name
		// 根包自动导入内置包：顶层函数可无命名空间直接调用。
		// 包导入表只由文件级 import（registerFileImports）与此处 builtin 注入写入。
		if packageInfo.Imports == nil {
			packageInfo.Imports = map[string]string{}
		}
		if _, ok := packageInfo.Imports["builtin"]; !ok {
			builtinPath, err := stdPackageDir("builtin")
			if err != nil {
				return nil, err
			}
			packageInfo.Imports["builtin"] = builtinPath
			if _, ok := packages[builtinPath]; !ok {
				info, err := GetPackage(builtinPath, false)
				if err != nil {
					return nil, err
				}
				packages[builtinPath] = info
			}
		}

		// 内建类型映射：根包预加载 string/map/slice 的 std 实现。
		// 不写入根包 import 别名——parser lowering 用完整包路径构造调用名，
		// 避免占用用户可能已经使用的 strings/maps/slices 别名。
		if os.Getenv("CUTE_NO_INTRINSIC") == "" {
			for _, name := range []string{"strings", "maps", "slices"} {
				pkgPath, err := stdPackageDir(name)
				if err != nil {
					return nil, err
				}
				if _, ok := packages[pkgPath]; !ok {
					info, err := GetPackage(pkgPath, false)
					if err != nil {
						return nil, err
					}
					packages[pkgPath] = info
				}
				parser.IntrinsicPkgs[name] = pkgPath
			}
		}
	}

	// 处理子目录和.cute文件
	var rootNode *parser.Node
	for _, file := range files {
		if file.IsDir() {
			continue
		}
		if path.Ext(file.Name()) == ".cute" {
			cuteFile := path.Join(packagePath, file.Name())
			// 解析前预检文件级 build arch/os 指令，不匹配当前目标则跳过文件。
			// 避免不匹配架构的文件参与解析（其引用的跨文件类型/函数可能在
			// 本包其他文件解析后才有定义，导致 "type not found"）。
			keep, err := preFilterBuild(cuteFile)
			if err != nil {
				return nil, err
			}
			if !keep {
				continue
			}
			// Wave L：注册文件级 import（别名进包导入表 + 加载被导入包），
			// 须在解析前完成——解析期的别名查找依赖包导入表。
			if err := registerFileImports(packageInfo, cuteFile); err != nil {
				return nil, err
			}
			lex := lexer.NewLexer(cuteFile)
			p := parser.NewParser(lex)
			p.Block.Parser = p
			p.Package = packageInfo
			p.Parse()
			// 文件级 build arch/os 过滤：顶层声明不匹配当前目标则跳过整个文件
			fileSkipped := false
			for _, child := range p.Block.Children {
				if b, ok := child.Value.(*parser.Build); ok && b.Type == "arch" && b.Ignore {
					fileSkipped = true
					break
				}
			}
			if fileSkipped {
				continue
			}
			if !isRoot {
				for i := 0; i < len(p.Block.Children); i++ {
					switch v := p.Block.Children[i].Value.(type) {
					case *parser.FuncBlock:
						v.Name.SetPkgPath(packagePath)
						ignored := false
						for _, bf := range v.BuildFlags {
							if bf.Ignore {
								ignored = true
								break
							}
						}
						if !ignored {
							parser.RegisterIntrinsicFunc(v)
						}
					case *parser.VarBlock:
						v.Name.SetPkgPath(packagePath)
					case *parser.TypeBlock:
						v.Name.SetPkgPath(packagePath)
					}
				}
				// 用本包导入表把跨包名称固定为包路径前缀。
				// 合并后的树共享根 Parser（根包导入表不含本包别名），
				// 若不在此固定，rootNode.Check 阶段的 FixPath 找不到别名，
				// 导致跨包调用解析失败（Func 为 nil、不被标记 Useful）。
				fixPkgNamePaths(p.Block, packageInfo)
			}
			// build link 提供者登记：编译器内建走 link 路径时标记 Useful
			for i := 0; i < len(p.Block.Children); i++ {
				fb, ok := p.Block.Children[i].Value.(*parser.FuncBlock)
				if !ok {
					continue
				}
				// 跳过被 arch/os build 标记忽略的函数（编译器不会编译它）
				ignored := false
				for _, bf := range fb.BuildFlags {
					if bf.Ignore {
						ignored = true
						break
					}
				}
				if ignored {
					continue
				}
				for _, bf := range fb.BuildFlags {
					if bf.Type == "link" && bf.Link != "" {
						parser.LinkProviders[bf.Link] = fb
					}
				}
			}
			// 内置包：逐文件注册顶层函数（先注册保证包内跨文件裸调用可用）
			if packageInfo.Builtin {
				for i := 0; i < len(p.Block.Children); i++ {
					if fb, ok := p.Block.Children[i].Value.(*parser.FuncBlock); ok {
						parser.BuiltinFuncs[fb.Name.Last()] = fb
					}
				}
			}
			if rootNode == nil {
				rootNode = p.Block
				packageInfo.AST = p.Block
			} else {
				// 将当前文件的子节点合并到 rootNode
				for _, child := range p.Block.Children {
					rootNode.AddChild(child)
				}
			}
		}
	}

	if isRoot {
		rootNode := packageInfo.AST.(*parser.Node)
		for _, info := range packages {
			tmp := info.AST.(*parser.Node)
			for _, child := range tmp.Children {
				// 直接挂载，不触发 Check（fixParser/Check 统一在后面执行）
				child.Father = rootNode
				rootNode.Children = append(rootNode.Children, child)
			}
		}
		// 将所有包的AST都设置成合并后的全局AST
		for _, info := range packages {
			info.AST = packageInfo.AST
		}
		// 统一整棵合并树的 Parser 为根文件 Parser：
		// 包内节点的 Parser 原本指向各自包文件的小树，跨包 Find 会找不到其它包
		rootNode = packageInfo.AST.(*parser.Node)
		var fixParser func(n *parser.Node)
		fixParser = func(n *parser.Node) {
			n.Parser = rootNode.Parser
			if ib, ok := n.Value.(*parser.IfBlock); ok && ib.ElseBlock != nil {
				fixParser(ib.ElseBlock)
			}
			for _, c := range n.Children {
				fixParser(c)
			}
		}
		fixParser(rootNode)

		// 重载注册表必须在合并后的完整树上重建：解析期只见过当前文件，
		// 跨文件前向引用和跨包函数都要靠这一次统一登记。
		parser.RebuildOverloadRegistry(rootNode)
		// 合并完成后的 Check 才允许把“无匹配重载/歧义”当成真错误。
		if rootNode.Parser != nil {
			rootNode.Parser.FinalCheck = true
		}

		for round := 0; round < 50; round++ {
			if !rootNode.Check() {
				break
			}
		}
	}

	return packageInfo, nil
}
