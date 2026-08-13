package x86_64

import (
	"cuteify/compile/context"
	"cuteify/parser"
	"strconv"
	"strings"
)

func GenVarAddr(ctx *context.Context, v *parser.VarBlock) string {
	if v.Name.First() == "this" {
		if len(v.Name) > 1 {
			thisAddr := "[rbp+16]"
			fieldOffset := calcThisFieldOffset(ctx, v)
			var addr string
			if fieldOffset > 0 {
				addr = "[rbp+16+" + strconv.FormatInt(int64(fieldOffset), 10) + "]"
			} else {
				addr = thisAddr
			}
			sizePrefix := GetLenName(v.Type.Size())
			return sizePrefix + addr
		}
		return "QWORD[rbp+16]"
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
			// 字段偏移在 calcFieldOffset 中计算
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
	return 0
}

func calcFieldOffset(ctx *context.Context, v *parser.VarBlock) int {
	if len(v.Name) <= 1 {
		return 0
	}
	return 0
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
