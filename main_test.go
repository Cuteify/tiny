package main_test

import (
	"fmt"
	"future/compile"
	"future/lexer"
	"future/parser"
	"os"
	"testing"
)

func BenchmarkCompile(b *testing.B) {
	path := "./test/a.fut"
	text, _ := os.ReadFile(path)
	lex := &lexer.Lexer{
		Text:     string(text),
		Filename: path,
	}
	lex.Init()
	for i := 0; i < b.N; i++ {
		lex.Cursor = 0
		/*for {
			token := lex.Next()
			if token.IsEmpty() {
				break
			}
			fmt.Println(token, token.Cursor)
		}*/
		p := parser.NewParser(lex)
		for {
			if p.Next() {
				break
			}
		}
		co := &compile.Compiler{}
		//fmt.Println(co.Compile(p.Block))
		co.Compile(p.Block)
		//pr(p.Block, 0)
	}
}

var count int = 0

func pr(block *parser.Node, tabnum int) {
	if tabnum == 0 {
		count = 0
	}
	tmp := ""
	for i := 0; i < tabnum; i++ {
		tmp += "\t"
	}
	count++
	fmt.Println(tmp, block.CFG)
	for _, k := range block.Children {
		pr(k, tabnum+1)
	}
	if tabnum == 0 {
		fmt.Println("Total count:", count)
	}
}
