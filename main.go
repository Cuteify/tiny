package main

import (
	"cuteify/compile"
	packageSys "cuteify/package"
	"cuteify/parser"
	"fmt"
	"os"
)

func main() {
	path := "./test"
	if len(os.Args) != 1 {
		path = os.Args[1]
	}
	tmp, _ := packageSys.GetPackage(path)
	pr(tmp.AST[0].(*parser.Node), 0)
	co := &compile.Compiler{}
	code := co.Compile(tmp.AST[0].(*parser.Node))
	//fmt.Println(code)
	os.WriteFile(`./_main.asm`, []byte(code), 0644)
	/*lex := lexer.NewLexer(path)
	p := parser.NewParser(lex)
	p.Parse()
	//p.CheckUnusedVar(p.Block)
	//compile.DelEmptyCFGNode(p.Block)
	pr(p.Block, 0)
	fmt.Println("\n" + strings.Repeat("=", 50) + "\n")
	//fmt.Println(compile.Compile(p.Block))
	//fmt.Println("\n" + strings.Repeat("=", 50) + "\n")
	co := &compile.Compiler{}
	fmt.Println(co.Compile(p.Block))*/
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
