package x86

import (
	"cuteify/compile/context"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strconv"
	"strings"
)

// caldAddrWithLen 生成带长度前缀的内存地址表达式
// 用于函数参数传递时的栈地址计算
func caldAddrWithLen(size int, offset int) (code string) {
	if offset == 0 {
		return utils.GetLengthName(size) + "[ebp]"
	}
	return utils.GetLengthName(size) + "[ebp + " + strconv.FormatInt(int64(offset), 10) + "]"
}

func genVarAddr(ctx *context.Context, v *parser.VarBlock) string {
	// 处理 this 或 self 指针
	firstName := v.Name.First()
	if firstName == "this" || firstName == "self" {
		// this/self 指针本身在 [ebp+8]
		if len(v.Name) == 1 {
			return "DWORD[ebp+8]"
		}
		// 访问 this/self 的字段
		fieldOffset := calculateThisFieldOffset(ctx, v)
		totalOffset := 8 + fieldOffset
		sizePrefix := utils.GetLengthName(v.Type.Size())
		return sizePrefix + "[ebp+" + strconv.Itoa(totalOffset) + "]"
	}

	var isDefineInArg bool
	if v.Define.Node != nil {
		switch v.Define.Type {
		case parser.FindTypeVar:
			if vb, ok := v.Define.Value.(*parser.VarBlock); ok {
				v.Offset = vb.Offset
			}
		case parser.FindTypeArg:
			isDefineInArg = true
			if ab, ok := v.Define.Value.(*parser.ArgBlock); ok {
				v.Offset = ab.Offset
			}
		case parser.FindTypeItem:
			// 列表索引访问，如 a[0]、a[1]
			// Path[0] 是列表变量的 VarBlock，Path[1] 是元素类型
			if len(v.Define.Path) > 0 {
				if vb, ok := v.Define.Path[0].(*parser.VarBlock); ok {
					v.Offset = vb.Offset
				}
			}
		case parser.FindTypeField:
			// 字段偏移在 calculateFieldOffset 中计算
		case parser.FindTypeSelf:
			// self 指向 this 指针
		}
	}

	baseOffset := v.Offset
	fieldOffset := 0

	if len(v.Name) > 1 {
		fieldOffset = calculateFieldOffset(ctx, v)
	}

	totalOffset := baseOffset + fieldOffset

	if !isDefineInArg {
		totalOffset += ctx.BpOffset
	}

	var addr string
	offsetStr := strconv.FormatInt(int64(totalOffset), 10)
	if totalOffset < 0 {
		addr = "[ebp" + offsetStr + "]"
	} else if totalOffset == 0 {
		addr = "[ebp]"
	} else {
		addr = "[ebp+" + offsetStr + "]"
	}
	sizePrefix := utils.GetLengthName(v.Type.Size())
	return sizePrefix + addr
}

func calculateThisFieldOffset(ctx *context.Context, v *parser.VarBlock) int {
	if len(v.Name) <= 1 {
		return 0
	}

	// 从当前函数获取 this 的类型
	var currentType typeSys.Type
	for current := ctx.Now; current != nil; current = current.Father {
		if funcBlock, ok := current.Value.(*parser.FuncBlock); ok {
			if funcBlock.Class != nil {
				currentType = funcBlock.Class
				break
			}
		}
	}

	if currentType == nil {
		return 0
	}

	// 如果是指针类型，先解引用
	if currentType.IsPointer() {
		currentType = currentType.Elem()
	}

	// 确保是结构体类型
	st, ok := currentType.(*typeSys.StructType)
	if !ok {
		return 0
	}

	// 计算 Layout 以获取正确的字段偏移
	st.Layout()

	// 遍历字段路径，累加偏移
	totalOffset := 0
	for i := 1; i < len(v.Name); i++ {
		fieldName := v.Name[i].Name
		field := st.Field(fieldName)
		if field == nil {
			return 0
		}
		totalOffset += field.Offset

		// 更新当前类型到字段类型
		currentType = field.Type
		if currentType == nil {
			return 0
		}

		// 如果字段是指针且还有后续路径，解引用
		if i < len(v.Name)-1 && currentType.IsPointer() {
			currentType = currentType.Elem()
		}

		// 如果字段是结构体，继续遍历
		if nextSt, ok := currentType.(*typeSys.StructType); ok {
			nextSt.Layout()
			st = nextSt
		}
	}

	return totalOffset
}

func calculateFieldOffset(ctx *context.Context, v *parser.VarBlock) int {
	if len(v.Name) <= 1 {
		return 0
	}

	// 检查是否是列表索引访问
	if v.Define.Type == parser.FindTypeItem {
		// 列表索引访问：从 Path 获取列表变量和索引表达式
		if len(v.Define.Path) > 0 {
			if listVar, ok := v.Define.Path[0].(*parser.VarBlock); ok {
				// 获取列表类型
				listType := listVar.Type
				if listType == nil {
					return 0
				}
				// 解引用指针（如果是列表指针）
				if listType.IsPointer() {
					listType = listType.Elem()
				}
				lt, ok := listType.(*typeSys.ListType)
				if !ok {
					return 0
				}
				elemSize := lt.Elem().Size()

				// 遍历名称路径，计算索引偏移
				totalOffset := 0
				for i := 1; i < len(v.Name); i++ {
					namePart := v.Name[i]
					if namePart.Slice != nil && namePart.Slice.Start != nil {
						// 索引表达式
						idxExpr := namePart.Slice.Start
						if idxExpr.IsConst() && typeSys.CheckKind(idxExpr.Type, "int", "uint") {
							// 常量索引
							totalOffset += int(idxExpr.Num) * elemSize
						} else {
							// 非常量索引，返回0，在运行时计算
							return 0
						}
					} else if namePart.Name != "" {
						// 字段访问（如 .len, .cap, .ptr）
						switch namePart.Name {
						case "len":
							totalOffset += ctx.Arch.PointerSize(ctx)
						case "cap":
							totalOffset += ctx.Arch.PointerSize(ctx) * 2
						case "ptr":
							// ptr 字段偏移为0
						}
					}
				}
				return totalOffset
			}
		}
		return 0
	}

	// 从 FindResult.Path 获取基础类型
	var baseType typeSys.Type
	if v.Define.Node != nil && len(v.Define.Path) > 0 {
		last := v.Define.Path[len(v.Define.Path)-1]
		switch t := last.(type) {
		case typeSys.Type:
			baseType = t
		case *parser.VarBlock:
			baseType = t.Type
		case *parser.ArgBlock:
			baseType = t.Type
		case *parser.FuncBlock:
			baseType = t.Class
		case *typeSys.StructField:
			baseType = t.Type
		}
	}
	if baseType == nil {
		baseType = v.Type
	}
	if baseType == nil {
		return 0
	}

	// 如果基础类型是指针，先解引用拿到结构体类型
	if baseType.IsPointer() {
		baseType = baseType.Elem()
	}
	if baseType == nil {
		return 0
	}

	// 确保 Layout 已计算
	if st, ok := baseType.(*typeSys.StructType); ok {
		st.Layout()
	}

	// 遍历字段路径，累加偏移
	totalOffset := 0
	currentType := baseType

	for i := 1; i < len(v.Name); i++ {
		fieldName := v.Name[i].Name
		st, ok := currentType.(*typeSys.StructType)
		if !ok {
			return 0
		}
		st.Layout()

		field := st.Field(fieldName)
		if field == nil {
			return 0
		}
		totalOffset += field.Offset

		// 更新当前类型到字段类型
		currentType = field.Type
		if currentType == nil {
			return 0
		}

		// 如果字段是指针且还有后续路径，解引用
		if i < len(v.Name)-1 && currentType.IsPointer() {
			currentType = currentType.Elem()
		}
	}

	return totalOffset
}

func listFieldAddr(ctx *context.Context, v *parser.VarBlock, fieldOffset int) string {
	var baseOffset int
	var isArg bool

	if v.Define.Node != nil {
		switch v.Define.Type {
		case parser.FindTypeVar:
			if vb, ok := v.Define.Value.(*parser.VarBlock); ok {
				baseOffset = vb.Offset
			}
		case parser.FindTypeArg:
			if ab, ok := v.Define.Value.(*parser.ArgBlock); ok {
				baseOffset = ab.Offset
				isArg = true
			}
		}
	} else {
		baseOffset = v.Offset
	}

	if !isArg {
		baseOffset += ctx.BpOffset
	}

	totalOffset := baseOffset + fieldOffset

	if totalOffset < 0 {
		return "[ebp" + strconv.Itoa(totalOffset) + "]"
	} else if totalOffset == 0 {
		return "[ebp]"
	}
	return "[ebp+" + strconv.Itoa(totalOffset) + "]"
}

func extractEbpOffset(addr string) (int, bool) {
	idx := strings.Index(addr, "[ebp")
	if idx == -1 {
		return 0, false
	}
	rest := addr[idx+4:]
	closeIdx := strings.Index(rest, "]")
	if closeIdx == -1 {
		return 0, false
	}
	offsetStr := rest[:closeIdx]
	if offsetStr == "" {
		return 0, true
	}
	offset, err := strconv.Atoi(offsetStr)
	if err != nil {
		return 0, false
	}
	return offset, true
}

func makeEbpAddr(offset int) string {
	if offset < 0 {
		return "[ebp" + strconv.Itoa(offset) + "]"
	} else if offset == 0 {
		return "[ebp]"
	}
	return "[ebp+" + strconv.Itoa(offset) + "]"
}

func isRegName(name string) bool {
	switch name {
	case "EAX", "EBX", "ECX", "EDX", "ESI", "EDI", "ESP", "EBP",
		"eax", "ebx", "ecx", "edx", "esi", "edi", "esp", "ebp":
		return true
	}
	return false
}

func is64Type(t typeSys.Type) bool {
	if t == nil {
		return false
	}
	return t.Size() == 8 && (t.Type() == "i64" || t.Type() == "u64" || t.Type() == "f64")
}

func genLoAddr(ctx *context.Context, v *parser.VarBlock) string {
	addr := genVarAddr(ctx, v)
	idx := strings.Index(addr, "[ebp")
	if idx == -1 {
		return "DWORD" + addr
	}
	return "DWORD" + addr[idx:]
}

func genHiAddr(ctx *context.Context, v *parser.VarBlock) string {
	addr := genVarAddr(ctx, v)
	idx := strings.Index(addr, "[ebp")
	if idx == -1 {
		return "DWORD" + addr
	}
	ebpPart := addr[idx:]
	closeIdx := strings.Index(ebpPart, "]")
	if closeIdx == -1 {
		return "DWORD" + ebpPart
	}
	offsetStr := ebpPart[4:closeIdx]
	if offsetStr == "" {
		return "DWORD[ebp+4]"
	}
	offset, err := strconv.Atoi(offsetStr)
	if err != nil {
		return "DWORD" + ebpPart
	}
	offset += 4
	if offset < 0 {
		return "DWORD[ebp" + strconv.Itoa(offset) + "]"
	}
	return "DWORD[ebp+" + strconv.Itoa(offset) + "]"
}
