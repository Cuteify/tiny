package x86

import (
	"cuteify/compile/context"
	"cuteify/parser"
	"cuteify/utils"
	"fmt"
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
	if v.Define != nil {
		switch def := v.Define.Value.(type) {
		case *parser.VarBlock:
			v.Offset = def.Offset
		case *parser.ArgBlock:
			v.Offset = def.Offset
		}
	}
	// 编译初始化表达式到变量地址
	addr := ""
	if v.Offset < 0 {
		addr = "[ebp" + ctx.Bp(v.Offset) + "]"
	} else if v.Offset == 0 {
		fmt.Println("WARNING")
		addr = "[ebp]"
	} else {
		addr = "[ebp+" + ctx.Bp(v.Offset) + "]"
	}
	sizePrefix := utils.GetLengthName(v.Type.Size())
	return sizePrefix + addr
}
