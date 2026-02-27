package main

import (
	"cuteify/compile"
	packageSys "cuteify/package"
	"cuteify/parser"
	"fmt"
	"os"
	"reflect"
	"strings"
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
	pr(tmp.AST.(*parser.Node), 0)
	co := &compile.Compiler{}
	//pr(tmp.AST.(*parser.Node), 0)
	code := co.Compile(tmp.AST.(*parser.Node))
	os.WriteFile(`./_main.asm`, []byte(code), 0644)
	fmt.Println("\033[32mOK\033[0m:Finish in", time.Now().Sub(startTime))
}

func pr(block *parser.Node, tabnum int) {
	if block.Ignore {
		return
	}
	fmt.Println(strings.Repeat("\t", tabnum), reflect.TypeOf(block.Value), block.Value)
	
	if sb, ok := block.Value.(*parser.StructBlock); ok {
		fmt.Printf("\n=== Struct: %s ===\n", sb.Name)
		fmt.Println("Fields:")
		for _, f := range sb.Fields {
			accessStr := "public"
			if f.Access == parser.AccessReadOnly {
				accessStr = "readonly"
			} else if f.Access == parser.AccessWriteOnly {
				accessStr = "writeonly"
			} else if f.Access == parser.AccessPrivate {
				accessStr = "private"
			}
			defaultStr := ""
			if f.DefaultValue != nil {
				defaultStr = fmt.Sprintf(" (default: %v)", f.DefaultValue)
			}
			tagStr := ""
			if len(f.Tags) > 0 {
				var tagParts []string
				for _, t := range f.Tags {
					tagParts = append(tagParts, t.Key+":"+t.Value)
				}
				tagStr = fmt.Sprintf(" (tags: %v)", tagParts)
			}
			fmt.Printf("  - %s: %v (access: %s)%s%s\n", f.Name, f.Type, accessStr, defaultStr, tagStr)
		}
		fmt.Println("Methods:")
		for _, m := range sb.Methods {
			fmt.Printf("  - %s\n", m.Name.String())
		}
		fmt.Println("=====================\n")
	}
	
	for _, k := range block.Children {
		pr(k, tabnum+1)
	}
}
