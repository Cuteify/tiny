// probe_tmp —— 临时探针:dump if 条件表达式树形(收口前删除)
package main

import (
	"fmt"
	"os"

	"cuteify/lexer"
	"cuteify/parser"
)

func dumpE(e *parser.Expression, ind string) {
	if e == nil {
		return
	}
	desc := "sep=" + fmt.Sprintf("%q", e.Separator)
	if e.Var != nil {
		desc += fmt.Sprintf(" var=%v", e.Var.Name)
	}
	if e.Left != nil || e.Right != nil {
		fmt.Printf("%snode {%s}\n", ind, desc)
		if e.Left != nil {
			fmt.Printf("%sL:\n", ind+"  ")
			dumpE(e.Left, ind+"    ")
		}
		if e.Right != nil {
			fmt.Printf("%sR:\n", ind+"  ")
			dumpE(e.Right, ind+"    ")
		}
	} else {
		fmt.Printf("%sleaf {%s}\n", ind, desc)
	}
}

func walk(n *parser.Node) {
	if n == nil {
		return
	}
	if ib, ok := n.Value.(*parser.IfBlock); ok && ib.Condition != nil {
		fmt.Printf("---- IF cond ----\n")
		dumpE(ib.Condition, "")
	}
	for _, ch := range n.Children {
		walk(ch)
	}
}

func main() {
	lex := lexer.NewLexer(os.Args[1])
	p := parser.NewParser(lex)
	p.Parse()
	walk(p.Block)
}
