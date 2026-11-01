package arch

import (
	"cuteify/parser"
	"cuteify/type"
)

// IsListLikeType 判断是否为三字段容器类型（list/string）
func IsListLikeType(t typeSys.Type) bool {
	return t != nil && (t.Kind() == "list" || t.Kind() == "string")
}

// ArgSaveBytes 计算 x86_64 SysV Prologue 的参数保存区字节数（局部槽起始游标预扣）。
//
// [病灶⑬修复 2026-11-01] 旧公式 Σ裸 Type.Size() 与 setArgsOffset 的槽带消耗
// （窄类型也按满 8B 步进，见 arch/x86_64/ops.go）两本账同式不同值：memset(s,c,n)
// 三参 Σ裸=17 与槽带消耗 24 差 7B，Prologue 局部槽游标从旧终点 −57 起步，
// 回咬 n:uint 条带 [−64..−57]，词清零循环把 n 槽冲成 0 → rem 无符号化写飞。
// 本 helper 与 setArgsOffset 单源同式：每参消耗 = ((Size+7)/8)*8；
// 全 8B 参数/无参时与旧 Σ裸 size 恒等（旧布局不漂移），仅含窄参函数加深让带。
// 注意：此 helper 专用于 x86_64 参数在 callee-local 区的布局（SysV）；
// x86(32 位) 参数在 ebp+8 正区、Win64 Prologue 无预扣，均不消费此值。
func ArgSaveBytes(fn *parser.FuncBlock) int {
	save := 0
	if fn != nil && fn.Class != nil {
		save += typeSys.TargetPointerSize // this 指针占满一个槽
	}
	if fn != nil {
		for i := 0; i < len(fn.Args); i++ {
			size := fn.Args[i].Type.Size()
			save += ((size + typeSys.TargetPointerSize - 1) / typeSys.TargetPointerSize) * typeSys.TargetPointerSize
		}
	}
	return save
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
				if len(v.MultiNames) > 0 {
					// 多返回值解构：为每个变量分配独立的栈空间
					v.MultiOffsets = make([]int, len(v.MultiNames))
					for i := range v.MultiNames {
						varSize := 8 // 默认按指针大小分配
						if i < len(v.MultiTypes) && v.MultiTypes[i] != nil {
							varSize = v.MultiTypes[i].Size()
						}
						if varSize == 0 {
							varSize = 8
						}
						*offset -= varSize
						v.MultiOffsets[i] = *offset
					}
				} else {
					varSize := v.Type.Size()
					if varSize == 0 {
						varSize = 4
					}
					*offset -= varSize
					v.Offset = *offset
				}
			}
		case *parser.ForBlock:
			if v.Init != nil && v.Init.Var != nil {
				initVar := v.Init.Var
				varSize := initVar.Type.Size()
				*offset -= varSize
				initVar.Offset = *offset
			}
			// for i, v := range coll：索引与值各占一个栈槽。索引是平台整型，
			// 值与被遍历容器的元素同型。
			for _, rn := range v.RangeNames {
				if rn == nil || rn.Offset != 0 {
					continue
				}
				varSize := 8
				if rn.Type != nil && rn.Type.Size() > 0 {
					varSize = rn.Type.Size()
				}
				*offset -= varSize
				rn.Offset = *offset
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
