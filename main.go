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
