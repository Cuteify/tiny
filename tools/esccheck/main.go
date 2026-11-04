// esccheck — 前端 GC 五态基线检查。
//
// 用法：esccheck ./test/xxx
// 基线：泄漏=0  提前释放=0  HolderBad=0；五态计数见 docs/gc_migration_plan.md。
package main

import (
	"fmt"
	"os"

	"cuteify/gc"
	packageSys "cuteify/package"
	"cuteify/parser"
)

func main() {
	path := "./test"
	if len(os.Args) > 1 {
		path = os.Args[1]
	}
	pkg, err := packageSys.GetPackage(path, true)
	if err != nil {
		panic(err)
	}
	root := pkg.AST.(*parser.Node)
	gc.Analyze(root)

	st := gc.Stats()
	sent, taken, orphan, _ := gc.TransferReport()
	prem, detail := gc.Premature()

	fmt.Printf("对象=%d  RC/泄漏释放=%d  泄漏=%d  提前释放=%d  就地释放=%d  字段释放=%d\n",
		st.Objects, st.RC, st.Leak, prem, st.InplaceObj, st.Field)
	fmt.Printf("  作用域释放=%d  转移=%d  RC=%d  真泄漏=%d  HolderBad=%d  (转移报告 交出=%d 接管=%d 无人接管=%d)\n",
		st.Scope, st.Transfer, st.RC, st.Leak, st.HolderBad, sent, taken, orphan)
	for _, o := range gc.Objects() {
		if !o.Inplace && o.FieldOwner == nil && !o.Transferred && o.FreeScope == nil && !o.Escapes {
			fmt.Printf("  真泄漏 #%d owner=%v\n", o.ID, o.Owner.Name)
		}
	}
	for _, d := range detail {
		fmt.Println("  提前释放: " + d)
	}
}
