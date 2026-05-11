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
	baseAddr := genVarAddrBase(ctx, v)
	sizePrefix := utils.GetLengthName(v.Type.Size())
	return sizePrefix + baseAddr
}

func genVarAddrBase(ctx *context.Context, v *parser.VarBlock) string {
	if v.Name.First() == "this" {
		if len(v.Name) > 1 {
			fieldOffset := calculateThisFieldOffset(ctx, v)
			if fieldOffset > 0 {
				return "[ebp+8+" + strconv.FormatInt(int64(fieldOffset), 10) + "]"
			}
			return "[ebp+8]"
		}
		return "[ebp+8]"
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

	offsetStr := strconv.FormatInt(int64(totalOffset), 10)
	if totalOffset < 0 {
		return "[ebp" + offsetStr + "]"
	} else if totalOffset == 0 {
		return "[ebp]"
	}
	return "[ebp+" + offsetStr + "]"
}

func calculateThisFieldOffset(ctx *context.Context, v *parser.VarBlock) int {
	if len(v.Name) <= 1 {
		return 0
	}

	var currentType typeSys.Type
	if ctx.CurrentFunc != nil && ctx.CurrentFunc.Class != nil {
		currentType = ctx.CurrentFunc.Class
	}

	if currentType == nil {
		return 0
	}

	totalOffset := 0
	for i := 1; i < len(v.Name); i++ {
		fieldName := v.Name[i]
		found := false
		for _, field := range currentType.Fields() {
			if field.Name == fieldName {
				totalOffset += field.Offset
				currentType = field.Type
				found = true
				break
			}
		}
		if !found {
			return 0
		}
	}
	return totalOffset
}

func calculateFieldOffset(ctx *context.Context, v *parser.VarBlock) int {
	if len(v.Name) <= 1 {
		return 0
	}

	var currentType typeSys.Type
	if v.BaseType != nil {
		currentType = v.BaseType
	} else if v.Define != nil {
		switch def := v.Define.Value.(type) {
		case *parser.VarBlock:
			currentType = def.Type
		case *parser.ArgBlock:
			currentType = def.Type
		}
	}

	if currentType == nil {
		return 0
	}

	totalOffset := 0
	for i := 1; i < len(v.Name); i++ {
		fieldName := v.Name[i]
		found := false
		for _, field := range currentType.Fields() {
			if field.Name == fieldName {
				totalOffset += field.Offset
				currentType = field.Type
				found = true
				break
			}
		}
		if !found {
			return 0
		}
	}
	return totalOffset
}
