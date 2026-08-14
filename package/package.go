package packageSys

import (
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
	"cuteify/parser"
	"encoding/json"
	"os"
	"path"
)

type All struct {
	Funcs map[string]*parser.Node
	Types map[string]*parser.Node
}

var packages = make(map[string]*packageFmt.Info)

var all *All = &All{
	Funcs: make(map[string]*parser.Node),
	Types: make(map[string]*parser.Node),
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
			v.Name.FixPath(pkg)
		}
	case *parser.Expression:
		if v.Call != nil && v.Call.Name.IsPath() {
			v.Call.Name.FixPath(pkg)
		}
		if v.Var != nil && v.Var.Name.IsPath() {
			v.Var.Name.FixPath(pkg)
		}
	case *parser.VarBlock:
		if v.Value != nil && v.Value.Call != nil && v.Value.Call.Name.IsPath() {
			v.Value.Call.Name.FixPath(pkg)
		}
	}
	for _, c := range n.Children {
		fixPkgNamePaths(c, pkg)
	}
}

func GetPackage(packagePath string, isRoot bool) (*packageFmt.Info, error) {
	// 列出目录下所有文件
	files, err := os.ReadDir(packagePath)
	if err != nil {
		return nil, err // 返回错误
	}

	// 打开package.json文件
	packFile, err := os.OpenFile(path.Join(packagePath, "package.json"), os.O_RDONLY, 0666)
	if err != nil {
		return nil, err // 返回错误
	}
	defer packFile.Close()

	// 解码package.json内容
	jsonDe := json.NewDecoder(packFile)
	packageInfo := &packageFmt.Info{}
	if err := jsonDe.Decode(packageInfo); err != nil {
		return nil, err // 返回错误
	}
	packageInfo.Path = packagePath
	packageInfo.AST = &parser.Node{}
	//packageInfo.Children = make(map[string]*packageFmt.Info)
	for k, ppath := range packageInfo.Imports {
		if _, ok := packages[ppath]; !ok {
			if ppath[:4] == "std:" {
				stdPath, err := os.Getwd()
				if err != nil {
					return nil, err
				}

				ppath = path.Join(stdPath, "pkg", ppath[4:])
			} else {
				ppath = path.Join(packagePath, ppath)
			}
			info, err := GetPackage(ppath, false)
			if err != nil {
				return nil, err
			}
			// 回写import
			packageInfo.Imports[k] = ppath
			packages[ppath] = info
		}
	}

	// 处理子目录和.cute文件
	var rootNode *parser.Node
	for _, file := range files {
		if file.IsDir() {
			continue
		}
		if path.Ext(file.Name()) == ".cute" {
			lex := lexer.NewLexer(path.Join(packagePath, file.Name()))
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
					switch p.Block.Children[i].Value.(type) {
					case *parser.FuncBlock:
						funcBlock := p.Block.Children[i].Value.(*parser.FuncBlock)
						funcBlock.Name.SetPkgPath(packagePath)
					}
				}
				// 用本包导入表把跨包名称固定为包路径前缀。
				// 合并后的树共享根 Parser（根包导入表不含本包别名），
				// 若不在此固定，rootNode.Check 阶段的 FixPath 找不到别名，
				// 导致跨包调用解析失败（Func 为 nil、不被标记 Useful）。
				fixPkgNamePaths(p.Block, packageInfo)
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
				rootNode.AddChild(child)
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
			for _, c := range n.Children {
				fixParser(c)
			}
		}
		fixParser(rootNode)
		rootNode.Check()
	}

	return packageInfo, nil
}
