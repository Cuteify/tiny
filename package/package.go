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
	for _, ppath := range packageInfo.Import {
		if _, ok := packages[ppath]; !ok {
			ppath = path.Join(packagePath, ppath)
			info, err := GetPackage(ppath, false)
			if err != nil {
				return nil, err
			}
			packages[ppath] = info
		}
	}

	// 处理子目录和.cute文件
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
			if !isRoot {
				for i := 0; i < len(p.Block.Children); i++ {
					switch p.Block.Children[i].Value.(type) {
					case *parser.FuncBlock:
						funcBlock := p.Block.Children[i].Value.(*parser.FuncBlock)
						funcBlock.Name = packageFmt.FixPathName(packagePath) + "." + funcBlock.Name
					}
				}
			}
			packageInfo.AST = p.Block
		}
	}

	if isRoot {
		for _, info := range packages {
			tmp := info.AST.(*parser.Node)
			packageInfo.AST.(*parser.Node).Children = append(packageInfo.AST.(*parser.Node).Children, tmp.Children...)
		}
		packageInfo.AST.(*parser.Node).Check()
	}

	return packageInfo, nil
}
