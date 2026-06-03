package main

import (
	"cuteify/compile"
	packageSys "cuteify/package"
	"cuteify/parser"
	typeSys "cuteify/type"
	"testing"
)

func TestListTypeDefinition(t *testing.T) {
	lt := typeSys.NewList(typeSys.GetSystemType("int"))
	if lt.Size() != 12 {
		t.Errorf("ListType.Size() = %d, want 12", lt.Size())
	}
	if lt.Alignment() != 4 {
		t.Errorf("ListType.Alignment() = %d, want 4", lt.Alignment())
	}
	if lt.Type() != "[]int" {
		t.Errorf("ListType.Type() = %s, want []int", lt.Type())
	}
	if lt.Elem().Type() != "int" {
		t.Errorf("ListType.Elem().Type() = %s, want int", lt.Elem().Type())
	}
}

func TestListTypeGetTypeType(t *testing.T) {
	lt := typeSys.NewList(typeSys.GetSystemType("int"))
	if lt.Kind() != "list" {
		t.Errorf("GetKind(lists.[]int) = %s, want list", lt.Kind())
	}
}

func TestNestedListType(t *testing.T) {
	inner := typeSys.NewList(typeSys.GetSystemType("int"))
	outer := typeSys.NewList(inner)
	if outer.Type() != "[][]int" {
		t.Errorf("nested ListType.Type() = %s, want [][]int", outer.Type())
	}
	if outer.Kind() != "list" {
		t.Errorf("GetKind(lists.[]lists.[]int) = %s, want list", outer.Kind())
	}
}

func TestGetSystemTypeListRedirect(t *testing.T) {
	lt := typeSys.GetSystemType("[]int")
	if lt == nil {
		t.Fatal("GetSystemType([]int) returned nil")
	}
	if lt.Type() != "[]int" {
		t.Errorf("GetSystemType([]int).Type() = %s, want []int", lt.Type())
	}
	if lt.Kind() != "list" {
		t.Errorf("GetKind([]int redirect) = %s, want list", lt.Kind())
	}
}

func TestGetSystemTypeListsFull(t *testing.T) {
	lt := typeSys.GetSystemType("lists.[]int")
	if lt == nil {
		t.Fatal("GetSystemType(lists.[]int) returned nil")
	}
	if lt.Type() != "lists.[]int" {
		t.Errorf("GetSystemType(lists.[]int).Type() = %s, want lists.[]int", lt.Type())
	}
}

func TestStringTypeSize(t *testing.T) {
	st := typeSys.GetSystemType("string")
	if st.Size() != 12 {
		t.Errorf("StringType.Size() = %d, want 12", st.Size())
	}
}

func TestListParseAndCompile(t *testing.T) {
	tmp, err := packageSys.GetPackage("./test/list_test", true)
	if err != nil {
		t.Fatal(err)
	}
	co := &compile.Compiler{}
	code := co.Compile(tmp.AST.(*parser.Node))
	if code == "" {
		t.Error("Compile returned empty code")
	}
}
