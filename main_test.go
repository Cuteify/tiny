package main_test

import (
	"cuteify/compile"
	packageSys "cuteify/package"
	"cuteify/parser"
	"testing"
)

func BenchmarkMain(b *testing.B) {
	for i := 0; i < b.N; i++ {
		path := "./test"
		tmp, err := packageSys.GetPackage(path, true)
		if err != nil {
			panic(err)
		}
		co := &compile.Compiler{}
		//pr(tmp.AST.(*parser.Node), 0)
		co.Compile(tmp.AST.(*parser.Node))
		//os.WriteFile(`./_main.asm`, []byte(code), 0644)
	}
}
