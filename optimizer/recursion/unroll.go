package recursion

import (
	"cuteify/parser"
	"fmt"
)

// UnrollResult 递归展开结果
type UnrollResult struct {
	Success     bool   // 是否成功展开
	Message     string // 展开消息
	NewFuncName string // 新函数名（如果需要重命名）
}

// LinearUnroll 线性递归展开
// 将像 fib(n) = fib(n-1) + fib(n-2) 这样的递归转换为迭代版本
func LinearUnroll(funcNode *parser.Node) *UnrollResult {
	if funcNode == nil {
		return &UnrollResult{
			Success: false,
			Message: "错误: 无效的函数节点",
		}
	}

	funcBlock, ok := funcNode.Value.(*parser.FuncBlock)
	if !ok {
		return &UnrollResult{
			Success: false,
			Message: "错误: 节点不是函数定义",
		}
	}

	// 检查是否是简单的线性递归（如 factorial）
	if isSimpleLinearRecursion(funcNode) {
		return transformToSimpleLoop(funcNode, funcBlock)
	}

	// 检查是否是双递归（如 fibonacci）
	if isDoubleRecursion(funcNode) {
		return transformFibonacciToIterative(funcNode, funcBlock)
	}

	return &UnrollResult{
		Success: false,
		Message: "函数结构不支持自动展开为迭代",
	}
}

// isSimpleLinearRecursion 检测简单线性递归
// 例如：factorial(n) = n <= 1 ? 1 : n * factorial(n-1)
func isSimpleLinearRecursion(funcNode *parser.Node) bool {
	if funcNode == nil || len(funcNode.Children) == 0 {
		return false
	}

	// 查找 if 语句
	for _, child := range funcNode.Children {
		if ifBlock, ok := child.Value.(*parser.IfBlock); ok {
			// 检查条件是否是对参数的简单比较
			if ifBlock.Condition != nil {
				if ifBlock.Condition.Left != nil && ifBlock.Condition.Left.Var != nil {
					// 条件是参数比较
					if ifBlock.Condition.Right != nil && ifBlock.Condition.Right.IsConst() {
						// 有终止条件
						return true
					}
				}
			}

			// 检查递归调用是否只传递参数 - 1 或类似
			if ifBlock.Else && ifBlock.ElseBlock != nil {
				if hasSingleRecursiveCall(ifBlock.ElseBlock, funcNode) {
					return true
				}
			}
		}
	}

	return false
}

// isDoubleRecursion 检测双递归（如 fibonacci）
// 例如：fib(n) = n <= 2 ? 1 : fib(n-1) + fib(n-2)
func isDoubleRecursion(funcNode *parser.Node) bool {
	if funcNode == nil || len(funcNode.Children) == 0 {
		return false
	}

	recursiveCalls := 0

	// 统计递归调用次数
	for _, child := range funcNode.Children {
		countRecursiveCalls(child, funcNode, &recursiveCalls)
	}

	// 双递归通常有 2 次递归调用
	return recursiveCalls >= 2
}

// countRecursiveCalls 递归统计递归调用次数
func countRecursiveCalls(node *parser.Node, funcNode *parser.Node, count *int) {
	if node == nil {
		return
	}

	switch v := node.Value.(type) {
	case *parser.Expression:
		if v.Call != nil && v.Call.Func != nil {
			funcBlock, _ := funcNode.Value.(*parser.FuncBlock)
			if v.Call.Func.Name == funcBlock.Name {
				*count++
			}
		}
	}

	for _, child := range node.Children {
		countRecursiveCalls(child, funcNode, count)
	}
}

// hasSingleRecursiveCall 检查节点中是否只有一个递归调用
func hasSingleRecursiveCall(node *parser.Node, funcNode *parser.Node) bool {
	count := 0
	countRecursiveCalls(node, funcNode, &count)
	return count == 1
}

// transformToSimpleLoop 将简单线性递归转换为循环
// 例如：factorial(n) -> while(n > 1) { result *= n; n--; }
func transformToSimpleLoop(funcNode *parser.Node, funcBlock *parser.FuncBlock) *UnrollResult {
	if len(funcBlock.Args) == 0 {
		return &UnrollResult{
			Success: false,
			Message: "函数没有参数",
		}
	}

	paramName := funcBlock.Args[0].Name
	newFuncName := funcBlock.Name + "_iter"

	// 这里只是生成转换信息，实际AST转换需要更复杂的实现
	message := fmt.Sprintf("函数 %s 可以转换为迭代版本 %s\n", funcBlock.Name, newFuncName)
	message += fmt.Sprintf("原递归: if(%s <= 1) return 1; else return %s * %s(%s-1);\n",
		paramName, funcBlock.Name, funcBlock.Name, paramName)
	message += fmt.Sprintf("迭代版本: result = 1; while(%s > 1) { result *= %s; %s--; } return result;\n",
		paramName, paramName, paramName)

	return &UnrollResult{
		Success:     true,
		Message:     message,
		NewFuncName: newFuncName,
	}
}

// transformFibonacciToIterative 将斐波那契递归转换为迭代
// fib(n) = fib(n-1) + fib(n-2) -> 使用循环和变量保存中间结果
func transformFibonacciToIterative(funcNode *parser.Node, funcBlock *parser.FuncBlock) *UnrollResult {
	if len(funcBlock.Args) == 0 {
		return &UnrollResult{
			Success: false,
			Message: "函数没有参数",
		}
	}

	paramName := funcBlock.Args[0].Name
	newFuncName := funcBlock.Name + "_iter"

	// 生成转换信息
	message := fmt.Sprintf("函数 %s 可以转换为迭代版本 %s\n", funcBlock.Name, newFuncName)
	message += fmt.Sprintf("原递归: if(%s <= 2) return 1; else return %s(%s-1) + %s(%s-2);\n",
		paramName, funcBlock.Name, paramName, funcBlock.Name, paramName)
	message += "迭代版本:\n"
	message += "  if(n <= 2) return 1;\n"
	message += "  prev = 1; curr = 1;\n"
	message += "  for(i = 3; i <= n; i++) {\n"
	message += "    next = prev + curr;\n"
	message += "    prev = curr;\n"
	message += "    curr = next;\n"
	message += "  }\n"
	message += "  return curr;\n"

	return &UnrollResult{
		Success:     true,
		Message:     message,
		NewFuncName: newFuncName,
	}
}

// GenerateIterativeAST 生成迭代版本的AST（简化版本）
// 注意：这是一个简化实现，完整的AST转换需要更复杂的逻辑
func GenerateIterativeAST(originalFunc *parser.Node, result *UnrollResult) *parser.Node {
	if !result.Success {
		return nil
	}

	// 创建新的函数节点
	newFuncNode := &parser.Node{
		Value: createIterativeFuncBlock(originalFunc, result.NewFuncName),
	}

	// 标记原始函数为已转换
	// 在实际实现中，这里应该完全替换函数体

	return newFuncNode
}

// createIterativeFuncBlock 创建迭代版本的函数块（简化）
func createIterativeFuncBlock(originalFunc *parser.Node, newName string) *parser.FuncBlock {
	originalFuncBlock, _ := originalFunc.Value.(*parser.FuncBlock)

	// 创建新的函数块（简化版本，只复制基本信息）
	return &parser.FuncBlock{
		Name: newName,
		Args: originalFuncBlock.Args, // 保留相同的参数
		// 注意：这里应该生成新的函数体，但简化实现中留空
	}
}

// GenerateIterativeCode 生成交代版本的伪代码
func GenerateIterativeCode(funcNode *parser.Node) string {
	result := LinearUnroll(funcNode)

	if !result.Success {
		return "// 函数无法自动转换为迭代\n"
	}

	code := "// === 递归到迭代转换 ===\n"
	code += "// 原始函数：\n"
	// code += "// " + generateFunctionSignature(funcNode) + " { ... }\n\n"
	code += "\n"
	code += "// 迭代版本建议：\n"
	code += "// " + result.Message
	code += "\n// 注意：这是转换建议，需要手动实现或使用更高级的编译器优化\n"

	return code
}
