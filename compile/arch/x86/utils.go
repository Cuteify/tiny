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
		return GetLengthName(size) + "[ebp]"
	}
	return GetLengthName(size) + "[ebp + " + strconv.FormatInt(int64(offset), 10) + "]"
}

// globalVarName 返回全局变量的定义名（引用端从 Define 取定义块名，保证与生成端一致）
func globalVarName(v *parser.VarBlock) string {
	if v.Define.Value != nil {
		if vb, ok := v.Define.Value.(*parser.VarBlock); ok && vb.Name != nil {
			return vb.Name.String()
		}
	}
	return v.Name.String()
}

func genVarAddr(ctx *context.Context, v *parser.VarBlock) string {	if v.Name.First() == "this" {
		if len(v.Name) > 1 {
			thisAddr := "[ebp+8]"
			fieldOffset := calculateThisFieldOffset(ctx, v)
			var addr string
			if fieldOffset > 0 {
				addr = "[ebp+8+" + strconv.FormatInt(int64(fieldOffset), 10) + "]"
			} else {
				addr = thisAddr
			}
			sizePrefix := GetLengthName(v.Type.Size())
			return sizePrefix + addr
		}
		return "DWORD[ebp+8]"
	}

	if v.IsGlobal {
		return "[__global_" + utils.ToNASMName(globalVarName(v)) + "]"
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
		case parser.FindTypeField:
			// 字段偏移在 calculateFieldOffset 中计算；基础变量/参数偏移取自 Path[0]
			if len(v.Define.Path) > 0 {
				switch base := v.Define.Path[0].(type) {
				case *parser.VarBlock:
					v.Offset = base.Offset
				case *parser.ArgBlock:
					v.Offset = base.Offset
				}
			}
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
	// 跨包引用的常量（const）合并后 Type 可能为空：按指针宽槽兜底
	if v.Type == nil {
		return "DWORD" + addr
	}
	sizePrefix := GetLengthName(v.Type.Size())
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

	// 累加字段路径偏移
	return walkFieldOffsets(v, currentType)
}

func calculateFieldOffset(ctx *context.Context, v *parser.VarBlock) int {
	if len(v.Name) <= 1 {
		return 0
	}

	// 列表索引访问（如 a[0]、a[0].len）：从 Path 恢复列表类型
	if v.Define.Type == parser.FindTypeItem {
		return calcListIndexOffset(v)
	}

	// 从 FindResult.Path 获取基础类型（Path[0] 为访问前起始类型）
	var baseType typeSys.Type
	if v.Define.Node != nil && len(v.Define.Path) > 0 {
		switch t := v.Define.Path[0].(type) {
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

	return walkFieldOffsets(v, baseType)
}

// walkFieldOffsets 沿 v.Name[1:] 字段路径累加结构体字段偏移
// （指针字段会在中间层自动解引用）
func walkFieldOffsets(v *parser.VarBlock, currentType typeSys.Type) int {
	totalOffset := 0
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

// calcListIndexOffset 计算列表索引访问（a[i]、a[i].len 等）的偏移
func calcListIndexOffset(v *parser.VarBlock) int {
	if len(v.Define.Path) == 0 {
		return 0
	}

	// Path[0] 是最外层列表变量/类型
	var base typeSys.Type
	switch t := v.Define.Path[0].(type) {
	case typeSys.Type:
		base = t
	case *parser.VarBlock:
		base = t.Type
	case *parser.ArgBlock:
		base = t.Type
	}
	if base == nil {
		return 0
	}
	if base.IsPointer() {
		base = base.Elem()
	}
	if base == nil {
		return 0
	}
	lt, ok := base.(*typeSys.ListType)
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
				totalOffset += typeSys.TargetPointerSize
			case "cap":
				totalOffset += typeSys.TargetPointerSize * 2
			case "ptr":
				// ptr 字段偏移为0
			}
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
		"eax", "ebx", "ecx", "edx", "esi", "edi", "esp", "ebp",
		"EDX:EAX", "edx:eax":
		return true
	}
	return false
}

// isRegPair 判断是否是 64 位寄存器对结果（值已在 EAX:EDX 中，无需额外存储）
func isRegPair(name string) bool {
	return name == "EDX:EAX" || name == "edx:eax"
}

func is64Type(t typeSys.Type) bool {
	if t == nil {
		return false
	}
	return t.Size() == 8 && (t.Type() == "i64" || t.Type() == "u64" || t.Type() == "f64")
}

func genLoAddr(ctx *context.Context, v *parser.VarBlock) string {
	if v.IsGlobal {
		return "[__global_" + utils.ToNASMName(globalVarName(v)) + "]"
	}
	addr := genVarAddr(ctx, v)
	idx := strings.Index(addr, "[ebp")
	if idx == -1 {
		return addr
	}
	return addr[idx:]
}

func genHiAddr(ctx *context.Context, v *parser.VarBlock) string {
	if v.IsGlobal {
		return "[__global_" + utils.ToNASMName(globalVarName(v)) + "+4]"
	}
	addr := genVarAddr(ctx, v)
	idx := strings.Index(addr, "[ebp")
	if idx == -1 {
		return addr
	}
	ebpPart := addr[idx:]
	closeIdx := strings.Index(ebpPart, "]")
	if closeIdx == -1 {
		return ebpPart
	}
	offsetStr := ebpPart[4:closeIdx]
	if offsetStr == "" {
		return "[ebp+4]"
	}
	offset, err := strconv.Atoi(offsetStr)
	if err != nil {
		return ebpPart
	}
	offset += 4
	if offset < 0 {
		return "[ebp" + strconv.Itoa(offset) + "]"
	}
	return "[ebp+" + strconv.Itoa(offset) + "]"
}
