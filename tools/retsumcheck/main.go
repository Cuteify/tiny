// retsumcheck — 返回值来源摘要对拍：前端 gc.RetSourceOf vs 后端 gc.Table.RetKind。
//
// 用途：守住“前端 Fresh 必须是后端 Fresh 的严格子集”这条不变量。前端比后端
// 更保守（Unknown 多于 Fresh）是允许的；反过来（前端 Fresh、后端非 Fresh）
// 意味着调用方可能把一个本不该接管的块当成新分配，属于所有权错误。
//
// 用法：
//
//	go run ./tools/retsumcheck ./test/gc_loop
//	go run ./tools/retsumcheck -check ./test/gc_loop
//
// 输出每行：函数名、前端摘要、后端摘要；违反子集时追加
// `<== FRONT_FRESH_BACK_NOT`。-check 模式下有违反则退出码 1，便于 CI 守卫。
package main

import (
	"flag"
	"fmt"
	"os"
	"sort"

	"cuteify/gc"
	packageSys "cuteify/package"
	"cuteify/parser"
)

func main() {
	check := flag.Bool("check", false, "存在 front=Fresh/back!=Fresh 时退出码 1")
	flag.Parse()
	if flag.NArg() != 1 {
		fmt.Fprintln(os.Stderr, "用法: retsumcheck [-check] <包目录>")
		os.Exit(2)
	}

	pkg, err := packageSys.GetPackage(flag.Arg(0), true)
	if err != nil {
		fmt.Fprintf(os.Stderr, "解析失败: %v\n", err)
		os.Exit(2)
	}
	root := pkg.AST.(*parser.Node)
	gc.Analyze(root)

	type row struct{ name, front, back string }
	var rows []row
	mismatch := 0
	parser.EachSubNode(root, func(n *parser.Node) {
		fb, ok := n.Value.(*parser.FuncBlock)
		if !ok || fb == nil {
			return
		}
		front := gc.RetSourceOf(fb)
		back := "?"
		if fs := gc.Table[fb.Name.String()]; fs != nil {
			back = fs.RetKind.String()
		} else if fs := gc.Table[fb.MangledName()]; fs != nil {
			back = fs.RetKind.String()
		}
		if front != gc.ReturnNone || back != "None" {
			if front == gc.ReturnFresh && back != "Fresh" {
				mismatch++
			}
			rows = append(rows, row{fb.Name.String(), front.String(), back})
		}
	})

	sort.Slice(rows, func(i, j int) bool { return rows[i].name < rows[j].name })
	for _, r := range rows {
		mark := ""
		if r.front == "Fresh" && r.back != "Fresh" {
			mark = "  <== FRONT_FRESH_BACK_NOT"
		}
		fmt.Printf("%s\tfront=%s\tback=%s%s\n", r.name, r.front, r.back, mark)
	}

	if *check && mismatch > 0 {
		fmt.Fprintf(os.Stderr, "返回值摘要越界: %d 个函数 front=Fresh/back!=Fresh\n", mismatch)
		os.Exit(1)
	}
}
