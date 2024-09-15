package main

import (
	"fmt"
	"future/lexer"
	"future/parser"
	"future/compile"
	"os"
    "strings"
)

func main() {
	path := "./test/a.fut"
	if len(os.Args) != 1 {
		path = os.Args[1]
	}
	text, _ := os.ReadFile(path)
	lex := &lexer.Lexer{
		Text:     string(text),
		Filename: path,
	}
	lex.Init()
	p := parser.NewParser(lex)
	for {
		if p.Next() {
			break
		}
	}
	//p.CheckUnusedVar(p.Block)
	//compile.DelEmptyCFGNode(p.Block)
	pr(p.Block, 0)
	fmt.Println("\n" + strings.Repeat("=", 50) + "\n")
	//fmt.Println(compile.Compile(p.Block))
	//fmt.Println("\n" + strings.Repeat("=", 50) + "\n")
	co := &compile.Compiler{}
	fmt.Println(co.Compile(p.Block))
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
