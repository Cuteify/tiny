package packageSys

import (
	"cuteify/lexer"
	packageFmt "cuteify/package/fmt"
	"cuteify/parser"
	"encoding/json"
	"os"
	"path"
	"strconv"
)

type All struct {
	Funcs map[string]*parser.Node
	Types map[string]*parser.Node
}

var packages = make(map[string]*packageFmt.Info)
var packagesCount = make(map[string]int)

var all *All = &All{
	Funcs: make(map[string]*parser.Node),
	Types: make(map[string]*parser.Node),
}

func GetPackage(packagePath string) (*packageFmt.Info, error) {
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

	// 处理子目录和.fut文件
	for _, file := range files {
		if file.IsDir() {
			continue
		}
		if path.Ext(file.Name()) == ".fut" {
			lex := lexer.NewLexer(path.Join(packagePath, file.Name()))
			p := parser.NewParser(lex)
			p.Funcs = all.Funcs
			p.Types = all.Types
			p.Package = packageInfo
			packageInfo.AST = append(packageInfo.AST, p.Parse())
			all.Funcs = p.Funcs
			all.Types = p.Types
		}
	}

	// 处理包名重复
	if packagesCount[packageInfo.Name] == 0 {
		packages[packageInfo.Name] = packageInfo
	} else {
		packagesCount[packageInfo.Name]++
		packageInfo.Name += "_" + strconv.Itoa(packagesCount[packageInfo.Name]) // 优化包名处理
		packages[packageInfo.Name] = packageInfo
	}
	return packageInfo, nil
}
