package x86_64

import (
	"cuteify/compile/context"
	"cuteify/parser"
	typeSys "cuteify/type"
	"strconv"
	"strings"
)

func GenVarAddr(ctx *context.Context, v *parser.VarBlock) string {
	// 处理 this 或 self 指针
	firstName := v.Name.First()
	if firstName == "this" || firstName == "self" {
		// this/self 指针本身在 [rbp+16]
		if len(v.Name) == 1 {
			return "QWORD[rbp+16]"
		}
		// 访问 this/self 的字段
		fieldOffset := calcThisFieldOffset(ctx, v)
		totalOffset := 16 + fieldOffset
		sizePrefix := GetLenName(v.Type.Size())
		return sizePrefix + MakeRbpAddr(totalOffset)
	}

	if v.IsGlobal {
		sizePrefix := GetLenName(v.Type.Size())
		return sizePrefix + "[rel __global_" + v.Name.First() + "]"
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
			// 字段偏移在 calcFieldOffset 中计算；基础变量/参数偏移取自 Path[0]
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
		fieldOffset = calcFieldOffset(ctx, v)
	}

	totalOffset := baseOffset + fieldOffset

	if !isDefineInArg {
		totalOffset += ctx.BpOffset
	}

	var addr string
	offsetStr := strconv.FormatInt(int64(totalOffset), 10)
	if totalOffset < 0 {
		addr = "[rbp" + offsetStr + "]"
	} else if totalOffset == 0 {
		addr = "[rbp]"
	} else {
		addr = "[rbp+" + offsetStr + "]"
	}
	sizePrefix := GetLenName(v.Type.Size())
	return sizePrefix + addr
}

func calcThisFieldOffset(ctx *context.Context, v *parser.VarBlock) int {
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

func calcFieldOffset(ctx *context.Context, v *parser.VarBlock) int {
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

func GenListFieldAddr(ctx *context.Context, v *parser.VarBlock, fieldOffset int) string {
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
		return "[rbp" + strconv.Itoa(totalOffset) + "]"
	} else if totalOffset == 0 {
		return "[rbp]"
	}
	return "[rbp+" + strconv.Itoa(totalOffset) + "]"
}

func GetRbpOffset(addr string) (int, bool) {
	idx := strings.Index(addr, "[rbp")
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

func MakeRbpAddr(offset int) string {
	if offset < 0 {
		return "[rbp" + strconv.Itoa(offset) + "]"
	} else if offset == 0 {
		return "[rbp]"
	}
	return "[rbp+" + strconv.Itoa(offset) + "]"
}

func IsReg(name string) bool {
	switch strings.ToUpper(name) {
	case "RAX", "RBX", "RCX", "RDX", "RSI", "RDI", "RBP", "RSP",
		"R8", "R9", "R10", "R11", "R12", "R13", "R14", "R15":
		return true
	}
	return false
}
