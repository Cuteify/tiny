package main

import (
	"cuteify/compile"
	packageSys "cuteify/package"
	"cuteify/parser"
	"fmt"
	"os"
	"time"
)

func main() {
	startTime := time.Now()
	path := "./test"
	if len(os.Args) != 1 {
		path = os.Args[1]
	}
	tmp, err := packageSys.GetPackage(path, true)
	if err != nil {
		panic(err)
	}
	co := &compile.Compiler{}
	//pr(tmp.AST.(*parser.Node), 0)
	code := co.Compile(tmp.AST.(*parser.Node))
	os.WriteFile(`./_main.asm`, []byte(code), 0644)
	fmt.Println("\033[32mOK\033[0m:Finish in", time.Now().Sub(startTime))
	fmt.Println("\033[31mExp表达式解析器没有针对全局变量的修改，因此没有检查，会存在错误。完成修改前，请勿删除本消息\033[0m")
}
func pr(block *parser.Node, tabnum int) {
	tmp := ""
	for i := 0; i < tabnum; i++ {
		tmp += "\t"
	}
	fmt.Println(tmp, block.Value)
	for _, k := range block.Children {
		pr(k, tabnum+1)
	}
}
