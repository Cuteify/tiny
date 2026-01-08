// Package optimizer 提供编译器优化工具集
//
// 示例：递归检测工具使用方法
//
//  1. 检测单个函数的递归特性
//     info := optimizer.DetectRecursion(funcNode, nil)
//     if info.IsRecursive {
//     fmt.Println("递归类型:", info.RecursionType)
//     fmt.Println(info.Report)
//     }
//
//  2. 构建调用图并检测间接递归
//     callGraph := optimizer.BuildSimpleCallGraph(programNode)
//     for _, funcNode := range functions {
//     info := optimizer.DetectRecursion(funcNode, callGraph)
//     if info.IsRecursive && info.RecursionType == optimizer.IndirectRecursion {
//     fmt.Println("间接递归:", info.CallChain)
//     }
//     }
//
//  3. 根据检测结果进行优化决策
//     if info.IsRecursive {
//     if info.DepthControlled {
//     // 深度可控，可以考虑尾递归优化或转换为循环
//     applyTailRecursionOptimization(funcNode)
//     } else {
//     // 深度不可控，添加警告
//     addStackOverflowWarning(funcNode)
//     }
//     }
package optimizer

// 示例代码仅供参考，实际使用时需要导入 parser 包
// import "cuteify/parser"
// import "fmt"
//
// func ExampleDetectRecursion() {
//     // 假设有一个程序 AST
//     var programNode *parser.Node
//
//     // 构建调用图
//     callGraph := BuildSimpleCallGraph(programNode)
//
//     // 收集所有函数
//     funcs := collectFunctions(programNode)
//
//     // 对每个函数进行递归检测
//     for _, funcNode := range funcs {
//         info := DetectRecursion(funcNode, callGraph)
//
//         // 输出检测结果
//         if info.IsRecursive {
//             fmt.Println("--- 发现递归函数 ---")
//             fmt.Println(info.Report)
//         }
//     }
// }
