// Package optimizer 提供编译器优化功能
package optimizer

import (
	"cuteify/optimizer/recursion"
	"cuteify/parser"
	typeSys "cuteify/type"
	"fmt"
)

// AnalyzeRecursion 分析递归
func AnalyzeRecursion(f *parser.Node) {
	_ = recursion.DetectRecursion(f, nil)
}

// OptimizeRecursion 优化递归函数
// 尝试将递归函数转换为迭代版本
func OptimizeRecursion(funcNode *parser.Node) {
	if funcNode == nil {
		return
	}

	_ = recursion.DetectRecursionPattern(funcNode, nil)
	_ = recursion.ConvertToIteration(funcNode)
}

// ConvertRecursionToIteration 直接转换递归为迭代
func ConvertRecursionToIteration(funcNode *parser.Node) bool {
	if funcNode == nil {
		return false
	}

	result := recursion.ConvertToIteration(funcNode)

	// 如果转换成功，替换原函数的 AST
	if result.CanConvert && result.ModifiedFunc != nil {
		if _, ok := funcNode.Value.(*parser.FuncBlock); ok {
			if _, ok := result.ModifiedFunc.Value.(*parser.FuncBlock); ok {
				funcNode.Children = result.ModifiedFunc.Children
				// 展开所有复合赋值运算符
				ExpandCompoundAssignments(funcNode)
				return true
			}
		}
	}

	return result.CanConvert
}

// OptimizeAllRecursions 优化程序中的所有递归函数
func OptimizeAllRecursions(programNode *parser.Node) {
	if programNode == nil {
		return
	}

	// 收集所有函数
	funcs := collectFuncNodes(programNode)

	for _, funcNode := range funcs {
		OptimizeRecursion(funcNode)
	}
}

// ConvertAllRecursions 转换所有递归函数
func ConvertAllRecursions(programNode *parser.Node) []bool {
	if programNode == nil {
		return nil
	}

	funcs := collectFuncNodes(programNode)
	results := make([]bool, len(funcs))

	for i, funcNode := range funcs {
		results[i] = ConvertRecursionToIteration(funcNode)
	}

	return results
}

// isCompoundAssignment 检查是否是复合赋值运算符
func isCompoundAssignment(op string) bool {
	switch op {
	case "+=", "-=", "*=", "/=", "%=", "^=", "&=", "|=", "<<=", ">>=":
		return true
	default:
		return false
	}
}

// isIncDec 检查是否是自增自减运算符
func isIncDec(op string) bool {
	return op == "++" || op == "--"
}

// ExpandCompoundAssignments 展开所有复合赋值运算符
// 将 *=, +=, -=, ++, -- 等运算符展开为普通的 VarBlock 赋值
func ExpandCompoundAssignments(node *parser.Node) {
	if node == nil {
		return
	}

	// 处理 ForBlock 的 Increment 字段
	if forBlock, ok := node.Value.(*parser.ForBlock); ok {
		if forBlock.Increment != nil {
			// 临时调试输出
			if forBlock.Increment.Separator == "++" {
				fmt.Printf("Found ++ in ForBlock.Increment, Left: %v, Left.Var: %v\n", forBlock.Increment.Left, forBlock.Increment.Left != nil && forBlock.Increment.Left.Var)
			}
			expandCompoundAssignmentsInExpression(nil, forBlock.Increment)
		}
	}

	// 处理 IfBlock 的 Condition 字段
	if ifBlock, ok := node.Value.(*parser.IfBlock); ok {
		if ifBlock.Condition != nil {
			expandCompoundAssignmentsInExpression(nil, ifBlock.Condition)
		}
	}

	// 遍历所有子节点，查找复合赋值表达式并替换为 VarBlock
	var newChildren []*parser.Node
	for _, child := range node.Children {
		if exp, ok := child.Value.(*parser.Expression); ok {
			if isCompoundAssignment(exp.Separator) && exp.Left != nil && exp.Left.Var != nil {
				// 将复合赋值表达式转换为 VarBlock
				varBlock := convertCompoundAssignmentToVarBlock(child, exp)
				if varBlock != nil {
					// 替换当前节点
					newNode := &parser.Node{Value: varBlock, Father: node, Parser: child.Parser}
					newNode.Children = child.Children // 保留子节点
					for _, subChild := range newNode.Children {
						subChild.Father = newNode
					}
					newChildren = append(newChildren, newNode)
					continue
				}
			} else if isIncDec(exp.Separator) && exp.Left != nil && exp.Left.Var != nil {
				// 将自增自减表达式转换为 VarBlock
				varBlock := convertIncDecToVarBlock(child, exp)
				if varBlock != nil {
					// 替换当前节点
					newNode := &parser.Node{Value: varBlock, Father: node, Parser: child.Parser}
					newNode.Children = child.Children // 保留子节点
					for _, subChild := range newNode.Children {
						subChild.Father = newNode
					}
					newChildren = append(newChildren, newNode)
					continue
				}
			}
		} else if varBlock, ok := child.Value.(*parser.VarBlock); ok {
			// 检查 VarBlock 的 Value 是否包含复合赋值或自增自减
			if varBlock.Value != nil {
				expandCompoundAssignmentsInExpression(varBlock, varBlock.Value)
			}
		}

		// 递归处理子节点
		ExpandCompoundAssignments(child)
		newChildren = append(newChildren, child)
	}

	// 更新子节点列表（仅在有变化时）
	if len(newChildren) > 0 && len(newChildren) == len(node.Children) {
		// 检查是否有替换发生
		hasReplacement := false
		for i := range newChildren {
			if newChildren[i] != node.Children[i] {
				hasReplacement = true
				break
			}
		}
		if hasReplacement {
			node.Children = newChildren
		}
	}
}

// expandCompoundAssignmentsInExpression 在表达式中递归展开复合赋值运算符
func expandCompoundAssignmentsInExpression(parentVarBlock *parser.VarBlock, exp *parser.Expression) {
	if exp == nil {
		return
	}

	// 检查当前表达式是否是复合赋值或自增自减
	if isCompoundAssignment(exp.Separator) && exp.Left != nil && exp.Left.Var != nil {
		// 转换复合赋值表达式
		baseOp := exp.Separator[0:1]
		refVar := exp.Left.Var
		if refVar.Type == nil {
			refVar.Type = typeSys.GetSystemType("int")
		}

		// 创建新的表达式: x * y
		newExp := &parser.Expression{
			Left: &parser.Expression{
				Var:  &parser.VarBlock{Name: refVar.Name, Type: refVar.Type, IsDefine: false, Define: refVar.Define},
				Type: refVar.Type,
			},
			Separator: baseOp,
			Right:     exp.Right,
			Type:      refVar.Type,
		}

		// 设置子表达式的 Father
		if newExp.Left != nil {
			newExp.Left.Father = newExp
		}
		if newExp.Right != nil {
			newExp.Right.Father = newExp
		}

		// 用新表达式替换当前表达式
		*exp = *newExp

	} else if isIncDec(exp.Separator) {
		// 处理自增自减表达式
		// 注意：这里不需要检查 exp.Left.Var 是否为 nil，因为 loop_var++ 这种形式是合法的
		op := "+"
		if exp.Separator == "--" {
			op = "-"
		}

		var refVar *parser.VarBlock
		if exp.Left != nil && exp.Left.Var != nil {
			refVar = exp.Left.Var
		} else if exp.Left != nil {
			// 如果 Left 是一个没有 Var 的 Expression，我们需要处理这种情况
			// 这在 for 循环的 Increment 中可能出现
			// 不需要做任何处理，因为 loop_var++ 这种形式在 for 循环中是合法的
		}

		if refVar != nil {
			if refVar.Type == nil {
				refVar.Type = typeSys.GetSystemType("int")
			}

			// 创建常量表达式: 1
			constExp := &parser.Expression{
				Num:  1,
				Type: typeSys.GetSystemType("int"),
			}

			// 创建新的表达式: x + 1
			newExp := &parser.Expression{
				Left: &parser.Expression{
					Var:  &parser.VarBlock{Name: refVar.Name, Type: refVar.Type, IsDefine: false, Define: refVar.Define},
					Type: refVar.Type,
				},
				Separator: op,
				Right:     constExp,
				Type:      refVar.Type,
			}

			// 设置子表达式的 Father
			if newExp.Left != nil {
				newExp.Left.Father = newExp
			}
			if newExp.Right != nil {
				newExp.Right.Father = newExp
			}

			// 用新表达式替换当前表达式
			*exp = *newExp
		}
	}

	// 递归处理左右子表达式
	if exp.Left != nil {
		expandCompoundAssignmentsInExpression(nil, exp.Left)
	}
	if exp.Right != nil {
		expandCompoundAssignmentsInExpression(nil, exp.Right)
	}
}

// convertCompoundAssignmentToVarBlock 将复合赋值表达式转换为 VarBlock
// 例如: x *= y 转换为 VarBlock{Name: x, Value: x * y}
func convertCompoundAssignmentToVarBlock(node *parser.Node, exp *parser.Expression) *parser.VarBlock {
	// 检查是否是复合赋值运算符
	if !isCompoundAssignment(exp.Separator) {
		return nil
	}

	// 左边必须是变量
	if exp.Left == nil || exp.Left.Var == nil {
		return nil
	}

	// 提取基础操作符
	baseOp := exp.Separator[0:1]

	// 获取变量引用
	refVar := exp.Left.Var
	if refVar == nil {
		return nil
	}

	// 设置类型
	if refVar.Type == nil {
		refVar.Type = typeSys.GetSystemType("int")
	}

	// 创建新的表达式: x * y
	rightExp := &parser.Expression{
		Left: &parser.Expression{
			Var:  &parser.VarBlock{Name: refVar.Name, Type: refVar.Type, IsDefine: false, Define: refVar.Define},
			Type: refVar.Type,
		},
		Separator: baseOp,
		Right:     exp.Right,
		Type:      refVar.Type,
	}

	// 设置子表达式的 Father 指针
	if rightExp.Left != nil {
		rightExp.Left.Father = rightExp
	}
	if rightExp.Right != nil {
		rightExp.Right.Father = rightExp
	}

	// 创建 VarBlock: resultVar
	varBlock := &parser.VarBlock{
		Name:     refVar.Name,
		Value:    rightExp,
		IsDefine: false,
		Type:     refVar.Type,
	}
	// 注意：VarBlock 中的 Expression 的 Father 应该是 nil，而不是指向 VarBlock
	rightExp.Father = nil

	return varBlock
}

// convertIncDecToVarBlock 将自增自减表达式转换为 VarBlock
// 例如: x++ 转换为 VarBlock{Name: x, Value: x + 1}
func convertIncDecToVarBlock(node *parser.Node, exp *parser.Expression) *parser.VarBlock {
	// 检查是否是自增自减运算符
	if !isIncDec(exp.Separator) {
		return nil
	}

	// 左边必须是变量
	if exp.Left == nil || exp.Left.Var == nil {
		return nil
	}

	// 提取操作符
	op := "+"
	if exp.Separator == "--" {
		op = "-"
	}

	// 获取变量引用
	refVar := exp.Left.Var
	if refVar == nil {
		return nil
	}

	// 设置类型
	if refVar.Type == nil {
		refVar.Type = typeSys.GetSystemType("int")
	}

	// 创建常量表达式: 1
	constExp := &parser.Expression{
		Num:  1,
		Type: typeSys.GetSystemType("int"),
	}

	// 创建新的表达式: x + 1
	rightExp := &parser.Expression{
		Left: &parser.Expression{
			Var:  &parser.VarBlock{Name: refVar.Name, Type: refVar.Type, IsDefine: false, Define: refVar.Define},
			Type: refVar.Type,
		},
		Separator: op,
		Right:     constExp,
		Type:      refVar.Type,
	}

	// 设置子表达式的 Father 指针
	if rightExp.Left != nil {
		rightExp.Left.Father = rightExp
	}
	if rightExp.Right != nil {
		rightExp.Right.Father = rightExp
	}

	// 创建 VarBlock
	varBlock := &parser.VarBlock{
		Name:     refVar.Name,
		Value:    rightExp,
		IsDefine: false,
		Type:     refVar.Type,
	}
	// 注意：VarBlock 中的 Expression 的 Father 应该是 nil，而不是指向 VarBlock
	rightExp.Father = nil

	return varBlock
}

// collectFuncNodes 收集所有函数节点
func collectFuncNodes(root *parser.Node) []*parser.Node {
	var funcs []*parser.Node

	if root == nil {
		return funcs
	}

	// 如果当前节点是函数定义
	if _, ok := root.Value.(*parser.FuncBlock); ok {
		funcs = append(funcs, root)
	}

	// 递归收集子节点中的函数
	for _, child := range root.Children {
		funcs = append(funcs, collectFuncNodes(child)...)
	}

	return funcs
}
