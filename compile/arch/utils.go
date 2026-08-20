package arch

import (
	"cuteify/parser"
	"cuteify/type"
)

// IsListLikeType 判断是否为三字段容器类型（list/string）
func IsListLikeType(t typeSys.Type) bool {
	return t != nil && (t.Kind() == "list" || t.Kind() == "string")
}

// ArgSlots 计算参数/返回值占用的指针宽度槽数：
// 容器固定 3 槽（ptr/len/cap）；>指针宽度的结构体按 Size/PointerSize 拆槽；其余 1 槽。
func ArgSlots(t typeSys.Type) int {
	if t == nil {
		return 1
	}
	if IsListLikeType(t) {
		return 3
	}
	if t.Size() > typeSys.TargetPointerSize {
		return t.Size() / typeSys.TargetPointerSize
	}
	return 1
}

// FuncReturnsContainer 判断函数是否返回容器类型
func FuncReturnsContainer(fn *parser.FuncBlock) bool {
	return fn != nil && len(fn.Return) > 0 && IsListLikeType(fn.Return[0])
}

// FuncReturnsLarge 判断函数是否返回大值（容器 3 槽 / 结构体多槽），需返回槽机制
func FuncReturnsLarge(fn *parser.FuncBlock) bool {
	if fn == nil || len(fn.Return) == 0 {
		return false
	}
	t := fn.Return[0]
	if t == nil {
		return false
	}
	if IsListLikeType(t) {
		return true
	}
	// 64 位标量（i64/u64/f64）走寄存器/双寄存器（EDX:EAX），不走返回槽
	if t.Size() == 8 && (t.Type() == "i64" || t.Type() == "u64" || t.Type() == "f64") {
		return false
	}
	return t.Size() > typeSys.TargetPointerSize
}

// CalcArgsSize 计算函数参数大小
func CalcArgsSize(fn *parser.FuncBlock, align int) (size int) {
	if len(fn.Args) == 0 {
		return 0
	}

	// 计算函数参数大小
	for i := 0; i < len(fn.Args); i++ {
		arg := fn.Args[i]
		size += arg.Type.Size()
	}

	return Align(size, align)
}

// SetArgsOffset 设置函数参数offset
func SetArgsOffset(fn *parser.FuncBlock, align int) (size int) {
	if len(fn.Args) == 0 {
		return 0
	}

	// 计算函数参数offset
	argOffset := 8
	if fn.Class != nil {
		argOffset += 4
	}

	for i := 0; i < len(fn.Args); i++ {
		arg := fn.Args[i]
		arg.Offset = argOffset
		argOffset += arg.Type.Size()
	}

	return Align(argOffset, align)
}

// Align 取整对齐
func Align(size int, align int) int {
	return (size + align - 1) / align * align
}

// SetVarOffset 设置函数中所有变量的栈偏移量
// 返回：相对给定 offset 所需额外对齐的字节数（已对齐的栈大小 = -offset + 返回值）
func SetVarOffset(fnode *parser.Node, alignment int, offset int) int {
	collectVarOffsets(fnode, &offset)

	// 计算栈大小（最小偏移量的绝对值），使用对齐值
	stackSize := -offset
	if alignment > 0 && stackSize%alignment != 0 {
		stackSize = (stackSize + alignment - 1) & ^(alignment - 1)
	}

	return stackSize
}

// SetupVarOffsets 设置函数中所有变量的栈偏移量
// 在进入函数体之前调用，确保所有变量都有正确的栈位置
// 返回计算出的栈大小（已对齐）
func SetupVarOffsets(funcNode *parser.Node, alignment int, offset int) int {
	collectVarOffsets(funcNode, &offset)

	// 计算栈大小（最小偏移量的绝对值），使用对齐值
	stackSize := -offset
	if alignment > 0 && stackSize%alignment != 0 {
		stackSize = (stackSize + alignment - 1) & ^(alignment - 1)
	}

	return stackSize
}

// collectVarOffsets 递归收集并设置所有变量的偏移量
func collectVarOffsets(node *parser.Node, offset *int) {
	for _, child := range node.Children {
		if child.Ignore {
			continue
		}

		switch v := child.Value.(type) {
		case *parser.VarBlock:
			if v.IsDefine {
				varSize := v.Type.Size()
				if varSize == 0 {
					varSize = 4
				}
				*offset -= varSize
				v.Offset = *offset
			}
		case *parser.ForBlock:
			if v.Init != nil && v.Init.Var != nil {
				initVar := v.Init.Var
				varSize := initVar.Type.Size()
				*offset -= varSize
				initVar.Offset = *offset
			}
			collectVarOffsets(child, offset)
		case *parser.IfBlock:
			// 递归处理 if 块中的变量
			collectVarOffsets(child, offset)
			// 如果有 else 块，也递归处理    mov EBX, DWORD[ebp-16]

			if v.Else {
				collectVarOffsets(v.ElseBlock, offset)
			}
		case *parser.FuncBlock:
			// 跳过嵌套函数（如果有的话）
			collectVarOffsets(child, offset)
			continue
		}
	}
}
