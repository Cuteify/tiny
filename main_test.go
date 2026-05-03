package main

import (
	"cuteify/compile"
	packageSys "cuteify/package"
	"cuteify/parser"
	"testing"
)

func BenchmarkCompiler(b *testing.B) {
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		tmp, err := packageSys.GetPackage("./test/fs_test", true)
		if err != nil {
			b.Fatal(err)
		}
		co := &compile.Compiler{}
		co.Compile(tmp.AST.(*parser.Node))
	}
}

func BenchmarkCompilerWithOutput(b *testing.B) {
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		tmp, err := packageSys.GetPackage("./test/fs_test", true)
		if err != nil {
			b.Fatal(err)
		}
		co := &compile.Compiler{}
		code := co.Compile(tmp.AST.(*parser.Node))
		_ = code
	}
}
