package optimizer

import (
	"cuteify/parser"
	"fmt"
)

func AnalyzeRecursion(f *parser.Node) {
	info := DetectRecursion(f, nil)
	fmt.Println(info.Report)
}
