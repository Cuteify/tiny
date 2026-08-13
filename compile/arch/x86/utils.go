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
	if v.Name.First() == "this" {
		if len(v.Name) > 1 {
			thisAddr := "[ebp+8]"
			fieldOffset := calculateThisFieldOffset(ctx, v)
			var addr string
			if fieldOffset > 0 {
				addr = "[ebp+8+" + strconv.FormatInt(int64(fieldOffset), 10) + "]"
			} else {
				addr = thisAddr
			}
			sizePrefix := utils.GetLengthName(v.Type.Size())
			return sizePrefix + addr
		}
		return "DWORD[ebp+8]"
	}

	if v.IsGlobal {
		return "[__global_" + v.Name.First() + "]"
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

	// TODO: var currentType typeSys.Type
	// TODO: for current := ctx.Parser.ThisBlock; current != nil; current = current.Father {
	// TODO: 	if funcBlock, ok := current.Value.(*parser.FuncBlock); ok {
	// TODO: 		if funcBlock.Class != nil {
	// TODO: 			currentType = funcBlock.Class
	// TODO: 			break
	// TODO: 		}
	// TODO: 	}
	// TODO: }
	// TODO:
	// TODO: if currentType == nil {
	// TODO: 	return 0
	// TODO: }
	// TODO:
	// TODO: totalOffset := 0
	// TODO: for i := 1; i < len(v.Name); i++ {
	// TODO: 	fieldName := v.Name[i].Name
	// TODO: 	structName := currentType.Type()
	// TODO: 	structBlock, exists := ctx.GetStruct(structName)
	// TODO: 	if !exists {
	// TODO: 		return 0
	// TODO: 	}
	// TODO: 	field := structBlock.GetFieldByName(fieldName)
	// TODO: 	if field == nil {
	// TODO: 		return 0
	// TODO: 	}
	// TODO: 	totalOffset += field.Offset
	// TODO: 	currentType = field.Type
	// TODO: }
	// TODO: return totalOffset
	return 0
}

func calculateFieldOffset(ctx *context.Context, v *parser.VarBlock) int {
	if len(v.Name) <= 1 {
		return 0
	}

	return 0
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
		return "[__global_" + v.Name.First() + "]"
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
		return "[__global_" + v.Name.First() + "+4]"
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
