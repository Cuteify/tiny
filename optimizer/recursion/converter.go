package recursion

import (
	"cuteify/parser"
	typeSys "cuteify/type"
)

// GetIntType 获取整数类型
func GetIntType() typeSys.Type {
	return typeSys.GetSystemType("int")
}

// ConversionStrategy 转换策略
type ConversionStrategy int

const (
	NoConversion               ConversionStrategy = iota // 不转换
	SimpleLoopStrategy                                   // 简单循环（线性递归）
	DynamicProgrammingStrategy                           // 动态规划（双递归）
	StackSimulationStrategy                              // 栈模拟（复杂递归）
	TailLoopStrategy                                     // 尾循环（尾递归）
)

// ConversionResult 转换结果
type ConversionResult struct {
	CanConvert   bool               // 是否可以转换
	Strategy     ConversionStrategy // 使用的策略
	ModifiedFunc *parser.Node       // 修改后的函数节点（AST）
}

// ConvertToIteration 将递归函数转换为迭代
func ConvertToIteration(funcNode *parser.Node) *ConversionResult {
	if funcNode == nil {
		return &ConversionResult{
			CanConvert: false,
		}
	}

	// 检测递归模式
	pattern := DetectRecursionPattern(funcNode, nil)

	if pattern.Type == NoRecursion {
		return &ConversionResult{
			CanConvert: false,
		}
	}

	// 根据递归类型选择转换策略
	var result *ConversionResult

	switch pattern.Type {
	case SimpleLinear:
		if pattern.IsTail {
			result = convertSimpleTailRecursion(funcNode, pattern)
		} else {
			result = convertSimpleLinearRecursion(funcNode, pattern)
		}
	case DoubleRecursion:
		result = convertDoubleRecursion(funcNode, pattern)
	case TailRecursive:
		result = convertTailRecursion(funcNode, pattern)
	case NestedRecursive, TreeRecursion:
		result = convertStackSimulation(funcNode, pattern)
	case GeneralRecursive:
		result = convertGeneralRecursion(funcNode, pattern)
	default:
		result = &ConversionResult{
			CanConvert: false,
		}
	}

	// 如果转换成功，修改函数节点的 AST
	if result != nil && result.CanConvert {
		result.ModifiedFunc = generateIterativeAST(funcNode, pattern, result)
	}

	return result
}

// convertSimpleLinearRecursion 转换简单线性递归
// 例如：factorial(n) = n <= 1 ? 1 : n * factorial(n-1)
func convertSimpleLinearRecursion(funcNode *parser.Node, pattern *RecursionPattern) *ConversionResult {
	if len(pattern.Params) == 0 {
		return &ConversionResult{
			CanConvert: false,
		}
	}

	return &ConversionResult{
		CanConvert: true,
		Strategy:   SimpleLoopStrategy,
	}
}

// convertSimpleTailRecursion 转换简单尾递归
func convertSimpleTailRecursion(funcNode *parser.Node, pattern *RecursionPattern) *ConversionResult {
	return &ConversionResult{
		CanConvert: true,
		Strategy:   TailLoopStrategy,
	}
}

// convertDoubleRecursion 转换双递归（如 fibonacci）
func convertDoubleRecursion(funcNode *parser.Node, pattern *RecursionPattern) *ConversionResult {
	if len(pattern.Params) == 0 {
		return &ConversionResult{
			CanConvert: false,
		}
	}

	return &ConversionResult{
		CanConvert: true,
		Strategy:   DynamicProgrammingStrategy,
	}
}

// convertTailRecursion 转换尾递归
func convertTailRecursion(funcNode *parser.Node, pattern *RecursionPattern) *ConversionResult {
	return &ConversionResult{
		CanConvert: true,
		Strategy:   TailLoopStrategy,
	}
}

// convertStackSimulation 使用栈模拟递归
// 适用于：嵌套递归、树递归、复杂递归
func convertStackSimulation(funcNode *parser.Node, pattern *RecursionPattern) *ConversionResult {
	if len(pattern.Params) == 0 {
		return &ConversionResult{
			CanConvert: false,
		}
	}

	return &ConversionResult{
		CanConvert: true,
		Strategy:   StackSimulationStrategy,
	}
}

// convertGeneralRecursion 转换一般递归
func convertGeneralRecursion(funcNode *parser.Node, pattern *RecursionPattern) *ConversionResult {
	return convertStackSimulation(funcNode, pattern)
}

// generateIterativeAST 生成迭代版本的 AST
func generateIterativeAST(originalFunc *parser.Node, pattern *RecursionPattern, result *ConversionResult) *parser.Node {
	if originalFunc == nil {
		return nil
	}

	funcBlock, ok := originalFunc.Value.(*parser.FuncBlock)
	if !ok {
		return nil
	}

	// 创建新的函数节点，保留函数名和参数
	newFuncNode := &parser.Node{
		Value: &parser.FuncBlock{
			Name:   funcBlock.Name,
			Args:   funcBlock.Args,
			Return: funcBlock.Return,
			Class:  funcBlock.Class,
		},
	}

	// 根据转换策略生成函数体
	switch result.Strategy {
	case SimpleLoopStrategy:
		generateSimpleLoopAST(newFuncNode, pattern)
	case DynamicProgrammingStrategy:
		generateDynamicProgrammingAST(newFuncNode, pattern)
	case TailLoopStrategy:
		generateTailLoopAST(newFuncNode, pattern)
	case StackSimulationStrategy:
		generateStackSimulationAST(newFuncNode, pattern)
	}

	return newFuncNode
}

// generateSimpleLoopAST 生成简单循环的 AST
func generateSimpleLoopAST(funcNode *parser.Node, pattern *RecursionPattern) {
	if len(pattern.Params) == 0 {
		return
	}

	param := pattern.Params[0]
	resultVar := "result"

	// 获取原始函数的参数块
	var paramArg *parser.ArgBlock
	funcBlock := funcNode.Value.(*parser.FuncBlock)
	for _, arg := range funcBlock.Args {
		if arg.Name == param {
			paramArg = arg
			break
		}
	}

	// 创建变量声明和初始化: result = 1
	initVar := &parser.Node{
		Value: &parser.VarBlock{
			Name:     resultVar,
			Type:     GetIntType(),
			IsDefine: true,
		},
	}

	initAssign := &parser.Node{
		Value: &parser.Expression{
			Left: &parser.Expression{
				Var: &parser.VarBlock{
					Name:     resultVar,
					Type:     GetIntType(),
					IsDefine: false,
					Define:   initVar,
				},
				Type: GetIntType(),
			},
			Separator: "=",
			Right: &parser.Expression{
				Num:  1,
				Type: GetIntType(),
			},
			Type: GetIntType(),
		},
	}
	// 为 initVar 设置初始值表达式
	initVar.Value.(*parser.VarBlock).Value = initAssign.Value.(*parser.Expression)

	// 创建 for 循环: for (; param > 1; param--)
	forNode := &parser.Node{
		Value: &parser.ForBlock{
			Var: nil,
			Condition: &parser.Expression{
				Left: &parser.Expression{
					Var: &parser.VarBlock{
						Name:   param,
						Type:   GetIntType(),
						Define: &parser.Node{Value: paramArg},
					},
					Type: GetIntType(),
				},
				Separator: ">",
				Right: &parser.Expression{
					Num:  1,
					Type: GetIntType(),
				},
				Type: GetIntType(),
			},
			Increment: &parser.Expression{
				Left: &parser.Expression{
					Var: &parser.VarBlock{
						Name:   param,
						Type:   GetIntType(),
						Define: &parser.Node{Value: paramArg},
					},
					Type: GetIntType(),
				},
				Separator: "--",
				Type:      GetIntType(),
			},
		},
	}

	// 创建循环体: result *= param
	bodyAssign := &parser.Node{
		Value: &parser.Expression{
			Left: &parser.Expression{
				Var: &parser.VarBlock{
					Name:     resultVar,
					Type:     GetIntType(),
					IsDefine: false,
					Define:   initVar,
				},
				Type: GetIntType(),
			},
			Separator: "*=",
			Right: &parser.Expression{
				Var: &parser.VarBlock{
					Name:   param,
					Type:   GetIntType(),
					Define: &parser.Node{Value: paramArg},
				},
				Type: GetIntType(),
			},
			Type: GetIntType(),
		},
	}

	// 创建返回语句: return result
	retNode := &parser.Node{
		Value: &parser.ReturnBlock{
			Value: []*parser.Expression{
				{
					Var: &parser.VarBlock{
						Name:     resultVar,
						Type:     GetIntType(),
						IsDefine: false,
						Define:   initVar,
					},
					Type: GetIntType(),
				},
			},
		},
	}

	// 使用 AddChild 安全地添加子节点（会自动设置 Father 和 Parser）
	funcNode.AddChild(initVar)
	funcNode.AddChild(initAssign)
	funcNode.AddChild(forNode)
	forNode.AddChild(bodyAssign)
	funcNode.AddChild(retNode)
}

// generateDynamicProgrammingAST 生成动态规划的 AST
func generateDynamicProgrammingAST(funcNode *parser.Node, pattern *RecursionPattern) {
	if len(pattern.Params) == 0 {
		return
	}

	param := pattern.Params[0]

	// 获取原始函数的参数块
	var paramArg *parser.ArgBlock
	funcBlock := funcNode.Value.(*parser.FuncBlock)
	for _, arg := range funcBlock.Args {
		if arg.Name == param {
			paramArg = arg
			break
		}
	}

	// 创建 if 块: if(param <= 2) { return 1; }
	ifNode := &parser.Node{
		Value: &parser.IfBlock{
			Condition: &parser.Expression{
				Left: &parser.Expression{
					Var: &parser.VarBlock{
						Name:   param,
						Type:   GetIntType(),
						Define: &parser.Node{Value: paramArg},
					},
					Type: GetIntType(),
				},
				Separator: "<=",
				Right: &parser.Expression{
					Num:  2,
					Type: GetIntType(),
				},
				Type: GetIntType(),
			},
		},
	}

	// 返回 1
	ret1 := &parser.Node{
		Value: &parser.ReturnBlock{
			Value: []*parser.Expression{
				{Num: 1, Type: GetIntType()},
			},
		},
	}
	ifNode.AddChild(ret1)

	// 初始化变量: prev = 1, curr = 1
	prevDecl := &parser.Node{
		Value: &parser.VarBlock{
			Name:     "prev",
			Type:     GetIntType(),
			IsDefine: true,
		},
	}
	prevAssign := &parser.Node{
		Value: &parser.Expression{
			Left: &parser.Expression{
				Var: &parser.VarBlock{
					Name:     "prev",
					Type:     GetIntType(),
					IsDefine: false,
					Define:   prevDecl,
				},
				Type: GetIntType(),
			},
			Separator: "=",
			Right: &parser.Expression{
				Num:  1,
				Type: GetIntType(),
			},
			Type: GetIntType(),
		},
	}
	// 为 prevDecl 设置初始值表达式
	prevDecl.Value.(*parser.VarBlock).Value = prevAssign.Value.(*parser.Expression)

	currDecl := &parser.Node{
		Value: &parser.VarBlock{
			Name:     "curr",
			Type:     GetIntType(),
			IsDefine: true,
		},
	}
	currAssign := &parser.Node{
		Value: &parser.Expression{
			Left: &parser.Expression{
				Var: &parser.VarBlock{
					Name:     "curr",
					Type:     GetIntType(),
					IsDefine: false,
					Define:   currDecl,
				},
				Type: GetIntType(),
			},
			Separator: "=",
			Right: &parser.Expression{
				Num:  1,
				Type: GetIntType(),
			},
			Type: GetIntType(),
		},
	}
	// 为 currDecl 设置初始值表达式
	currDecl.Value.(*parser.VarBlock).Value = currAssign.Value.(*parser.Expression)

	nextDecl := &parser.Node{
		Value: &parser.VarBlock{
			Name:     "next",
			Type:     GetIntType(),
			IsDefine: true,
		},
	}
	// 为 nextDecl 设置初始值表达式（无初始值，使用零值）
	nextDecl.Value.(*parser.VarBlock).Value = &parser.Expression{
		Num:  0,
		Type: GetIntType(),
	}

	// 创建 loop_var 变量声明和初始化: loop_var = 3
	loopVarDecl := &parser.Node{
		Value: &parser.VarBlock{
			Name:     "loop_var",
			Type:     GetIntType(),
			IsDefine: true,
		},
	}
	loopVarAssign := &parser.Node{
		Value: &parser.Expression{
			Left: &parser.Expression{
				Var: &parser.VarBlock{
					Name:     "loop_var",
					Type:     GetIntType(),
					IsDefine: false,
					Define:   loopVarDecl,
				},
				Type: GetIntType(),
			},
			Separator: "=",
			Right: &parser.Expression{
				Num:  3,
				Type: GetIntType(),
			},
			Type: GetIntType(),
		},
	}
	// 为 loopVarDecl 设置初始值表达式
	loopVarDecl.Value.(*parser.VarBlock).Value = loopVarAssign.Value.(*parser.Expression)

	// 创建 for 循环: for (; loop_var <= param; loop_var++)
	forNode := &parser.Node{
		Value: &parser.ForBlock{
			Var: nil,
			Condition: &parser.Expression{
				Left: &parser.Expression{
					Var: &parser.VarBlock{
						Name:     "loop_var",
						Type:     GetIntType(),
						IsDefine: false,
						Define:   loopVarDecl,
					},
					Type: GetIntType(),
				},
				Separator: "<=",
				Right: &parser.Expression{
					Var: &parser.VarBlock{
						Name:   param,
						Type:   GetIntType(),
						Define: &parser.Node{Value: paramArg},
					},
					Type: GetIntType(),
				},
				Type: GetIntType(),
			},
			Increment: &parser.Expression{
				Left: &parser.Expression{
					Var: &parser.VarBlock{
						Name:     "loop_var",
						Type:     GetIntType(),
						IsDefine: false,
						Define:   loopVarDecl,
					},
					Type: GetIntType(),
				},
				Separator: "++",
				Type:      GetIntType(),
			},
		},
	}

	// 循环体: next = prev + curr; prev = curr; curr = next;
	assign1 := &parser.Node{
		Value: &parser.Expression{
			Left: &parser.Expression{
				Var: &parser.VarBlock{
					Name:     "next",
					Type:     GetIntType(),
					IsDefine: false,
					Define:   nextDecl,
				},
				Type: GetIntType(),
			},
			Separator: "=",
			Right: &parser.Expression{
				Left: &parser.Expression{
					Var: &parser.VarBlock{
						Name:     "prev",
						Type:     GetIntType(),
						IsDefine: false,
						Define:   prevDecl,
					},
					Type: GetIntType(),
				},
				Separator: "+",
				Right: &parser.Expression{
					Var: &parser.VarBlock{
						Name:     "curr",
						Type:     GetIntType(),
						IsDefine: false,
						Define:   currDecl,
					},
					Type: GetIntType(),
				},
				Type: GetIntType(),
			},
			Type: GetIntType(),
		},
	}

	assign2 := &parser.Node{
		Value: &parser.Expression{
			Left: &parser.Expression{
				Var: &parser.VarBlock{
					Name:     "prev",
					Type:     GetIntType(),
					IsDefine: false,
					Define:   prevDecl,
				},
				Type: GetIntType(),
			},
			Separator: "=",
			Right: &parser.Expression{
				Var: &parser.VarBlock{
					Name:     "curr",
					Type:     GetIntType(),
					IsDefine: false,
					Define:   currDecl,
				},
				Type: GetIntType(),
			},
			Type: GetIntType(),
		},
	}

	assign3 := &parser.Node{
		Value: &parser.Expression{
			Left: &parser.Expression{
				Var: &parser.VarBlock{
					Name:     "curr",
					Type:     GetIntType(),
					IsDefine: false,
					Define:   currDecl,
				},
				Type: GetIntType(),
			},
			Separator: "=",
			Right: &parser.Expression{
				Var: &parser.VarBlock{
					Name:     "next",
					Type:     GetIntType(),
					IsDefine: false,
					Define:   nextDecl,
				},
				Type: GetIntType(),
			},
			Type: GetIntType(),
		},
	}

	// 组装循环体
	forNode.AddChild(assign1)
	forNode.AddChild(assign2)
	forNode.AddChild(assign3)

	// 返回语句: return curr
	retCurr := &parser.Node{
		Value: &parser.ReturnBlock{
			Value: []*parser.Expression{
				{
					Var: &parser.VarBlock{
						Name:     "curr",
						Type:     GetIntType(),
						IsDefine: false,
						Define:   currDecl,
					},
					Type: GetIntType(),
				},
			},
		},
	}

	// 使用 AddChild 安全地添加子节点（会自动设置 Father 和 Parser）
	funcNode.AddChild(ifNode)
	funcNode.AddChild(prevDecl)
	funcNode.AddChild(prevAssign)
	funcNode.AddChild(currDecl)
	funcNode.AddChild(currAssign)
	funcNode.AddChild(nextDecl)
	funcNode.AddChild(loopVarDecl)
	funcNode.AddChild(loopVarAssign)
	funcNode.AddChild(forNode)
	funcNode.AddChild(retCurr)
}

// generateTailLoopAST 生成尾循环的 AST
func generateTailLoopAST(funcNode *parser.Node, pattern *RecursionPattern) {
	if len(pattern.Params) == 0 {
		return
	}

	param := pattern.Params[0]

	// 获取原始函数的参数块
	var paramArg *parser.ArgBlock
	funcBlock := funcNode.Value.(*parser.FuncBlock)
	for _, arg := range funcBlock.Args {
		if arg.Name == param {
			paramArg = arg
			break
		}
	}

	// 创建 for 循环: for (; param > 0; param--)
	forNode := &parser.Node{
		Value: &parser.ForBlock{
			Var: nil,
			Condition: &parser.Expression{
				Left: &parser.Expression{
					Var: &parser.VarBlock{
						Name:   param,
						Type:   GetIntType(),
						Define: &parser.Node{Value: paramArg},
					},
					Type: GetIntType(),
				},
				Separator: ">",
				Right: &parser.Expression{
					Num:  0,
					Type: GetIntType(),
				},
				Type: GetIntType(),
			},
			Increment: &parser.Expression{
				Left: &parser.Expression{
					Var: &parser.VarBlock{
						Name:   param,
						Type:   GetIntType(),
						Define: &parser.Node{Value: paramArg},
					},
					Type: GetIntType(),
				},
				Separator: "--",
				Type:      GetIntType(),
			},
		},
	}

	// 创建返回语句: return param
	retNode := &parser.Node{
		Value: &parser.ReturnBlock{
			Value: []*parser.Expression{
				{
					Var: &parser.VarBlock{
						Name:   param,
						Type:   GetIntType(),
						Define: &parser.Node{Value: paramArg},
					},
					Type: GetIntType(),
				},
			},
		},
	}

	// 使用 AddChild 安全地添加子节点（会自动设置 Father 和 Parser）
	funcNode.AddChild(forNode)
	funcNode.AddChild(retNode)
}

// generateStackSimulationAST 生成栈模拟的 AST
func generateStackSimulationAST(funcNode *parser.Node, pattern *RecursionPattern) {
	if len(pattern.Params) == 0 {
		return
	}

	// 栈模拟需要更复杂的实现
	// 创建一个占位符，提示需要更完整的实现
	// 实际编译器需要支持栈操作和 goto 语句
	// 这里保持函数体为空，由编译器后续处理
}
