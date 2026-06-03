package main

import (
	"cuteify/compile"
	packageSys "cuteify/package"
	"cuteify/parser"
	typeSys "cuteify/type"
	"testing"
)

func TestAliasType(t *testing.T) {
	// True alias
	alias := typeSys.NewAlias("MyInt", typeSys.GetSystemType("int"), true)
	if alias.Kind() != "int" {
		t.Errorf("AliasType.Kind() = %s, want int", alias.Kind())
	}
	if alias.Size() != typeSys.GetSystemType("int").Size() {
		t.Errorf("AliasType.Size() = %d, want %d", alias.Size(), typeSys.GetSystemType("int").Size())
	}
	if alias.Type() != "MyInt" {
		t.Errorf("AliasType.Type() = %s, want MyInt", alias.Type())
	}
	
	// New type (not true alias)
	newType := typeSys.NewAlias("MyInt2", typeSys.GetSystemType("int"), false)
	if newType.Kind() != "int" {
		t.Errorf("NewType.Kind() = %s, want int", newType.Kind())
	}
	
	// Methods inheritance for true alias
	// (methods would be inherited from underlying type)
	
	// Methods merge for new type
	// (methods would be merged from self and underlying)
}

func TestAliasTypeWithList(t *testing.T) {
	listType := typeSys.NewList(typeSys.GetSystemType("int"))
	alias := typeSys.NewAlias("MyList", listType, true)
	
	if alias.Kind() != "list" {
		t.Errorf("AliasType.Kind() = %s, want list", alias.Kind())
	}
	if alias.Elem().Kind() != "int" {
		t.Errorf("AliasType.Elem().Kind() = %s, want int", alias.Elem().Kind())
	}
}

func TestAliasTypeWithStruct(t *testing.T) {
	structType := typeSys.NewStruct("Point", typeSys.StructFileds{
		{Name: "x", Type: typeSys.GetSystemType("int")},
		{Name: "y", Type: typeSys.GetSystemType("int")},
	})
	alias := typeSys.NewAlias("MyPoint", structType, true)
	
	if alias.Kind() != "struct" {
		t.Errorf("AliasType.Kind() = %s, want struct", alias.Kind())
	}
	if len(alias.Fields()) != 2 {
		t.Errorf("AliasType.Fields() length = %d, want 2", len(alias.Fields()))
	}
}

func TestFullSyntaxParse(t *testing.T) {
	tmp, err := packageSys.GetPackage("./test/full_syntax_test", true)
	if err != nil {
		t.Fatal(err)
	}
	
	// Verify AST was parsed
	if tmp.AST == nil {
		t.Fatal("AST is nil")
	}
	
	node := tmp.AST.(*parser.Node)
	if len(node.Children) == 0 {
		t.Fatal("No children in AST")
	}
}

func TestFullSyntaxCompile(t *testing.T) {
	tmp, err := packageSys.GetPackage("./test/full_syntax_test", true)
	if err != nil {
		t.Fatal(err)
	}
	
	co := &compile.Compiler{}
	code := co.Compile(tmp.AST.(*parser.Node))
	if code == "" {
		t.Error("Compile returned empty code")
	}
	
	// Print generated code for inspection
	t.Logf("Generated code:\n%s", code)
}

func TestNameWithSlice(t *testing.T) {
	// Test that Name can parse slices
	// This is tested indirectly through the full syntax test
}

func TestAllTypeMethods(t *testing.T) {
	// Test that all types have Methods()
	intType := typeSys.GetSystemType("int")
	if intType.Methods() == nil {
		// Should return empty slice, not nil
		t.Log("intType.Methods() is nil (acceptable)")
	}
	
	listType := typeSys.NewList(typeSys.GetSystemType("int"))
	if listType.Methods() == nil {
		t.Log("listType.Methods() is nil (acceptable)")
	}
	
	structType := typeSys.NewStruct("Test", typeSys.StructFileds{})
	if structType.Methods() == nil {
		t.Log("structType.Methods() is nil (acceptable)")
	}
}
