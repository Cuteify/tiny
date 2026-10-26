// 临时调试工具：打印逃逸分析的最终判定（不属于交付物，验证完即删）
//
// 用法：esccheck ./test/xxx
// 改动 parser/gc_*.go 之后基线必须是：对象=114  RC/泄漏释放=6  泄漏=0  提前释放=0
// （markArgs 挂接后的口径，数字来源与分布见 docs/gc_frontend_design.md §5）。
package main

import (
	"fmt"
	"os"

	packageSys "cuteify/package"
	"cuteify/parser"
)

func main() {
	path := "./test"
	if len(os.Args) > 1 {
		path = os.Args[1]
	}
	_, err := packageSys.GetPackage(path, true)
	if err != nil {
		panic(err)
	}

	objs := parser.Objects()
	sent, taken, orphan, _ := parser.TransferReport()

	// 口径：对象只有三条出路 —— 作用域释放（FreeScope）/ 转移给调用方
	//（Transferred）/ 退回引用计数（Escapes）。三者都不沾的才是**真泄漏**：
	// 没人会 free 它，也没人会管它。
	scope, xfer, rcn, leak := 0, 0, 0, 0
	for _, o := range objs {
		switch {
		case o.Transferred:
			xfer++
		case o.FreeScope != nil:
			scope++
		case o.Escapes:
			rcn++
		default:
			leak++
		}
	}

	fmt.Printf("对象=%d  RC/泄漏释放=%d  泄漏=%d  提前释放=%d\n",
		len(objs), rcn, leak, parser.Premature)
	fmt.Printf("  作用域释放=%d  转移=%d  RC=%d  真泄漏=%d  (转移报告 交出=%d 接管=%d 无人接管=%d)\n",
		scope, xfer, rcn, leak, sent, taken, orphan)
	for _, o := range objs {
		if !o.Transferred && o.FreeScope == nil && !o.Escapes {
			fmt.Printf("  真泄漏 #%d owner=%v\n", o.ID, o.Owner.Name)
		}
	}
	for _, d := range parser.PrematureDetail {
		fmt.Println("  提前释放: " + d)
	}
}
