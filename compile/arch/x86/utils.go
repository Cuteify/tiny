package x86

import (
	"cuteify/compile/context"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strconv"
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

	var isDefineInArg bool
	if v.Define != nil {
		switch def := v.Define.Value.(type) {
		case *parser.VarBlock:
			v.Offset = def.Offset
		case *parser.ArgBlock:
			isDefineInArg = true
			v.Offset = def.Offset
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

	var currentType typeSys.Type
	for current := ctx.Parser.ThisBlock; current != nil; current = current.Father {
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

	totalOffset := 0
	for i := 1; i < len(v.Name); i++ {
		fieldName := v.Name[i]
		structName := currentType.Type()
		structBlock, exists := ctx.GetStruct(structName)
		if !exists {
			return 0
		}
		field := structBlock.GetFieldByName(fieldName)
		if field == nil {
			return 0
		}
		totalOffset += field.Offset
		currentType = field.Type
	}
	return totalOffset
}

func calculateFieldOffset(ctx *context.Context, v *parser.VarBlock) int {
	if len(v.Name) <= 1 {
		return 0
	}

	var currentType typeSys.Type
	if v.Define != nil {
		switch def := v.Define.Value.(type) {
		case *parser.VarBlock:
			currentType = def.Type
		case *parser.ArgBlock:
			currentType = def.Type
		}
	}

	totalOffset := 0
	for i := 1; i < len(v.Name); i++ {
		fieldName := v.Name[i]
		structName := currentType.Type()
		structBlock, exists := ctx.GetStruct(structName)
		if !exists {
			return 0
		}
		field := structBlock.GetFieldByName(fieldName)
		if field == nil {
			return 0
		}
		totalOffset += field.Offset
		currentType = field.Type
	}
	return totalOffset
}
