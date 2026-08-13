// Package compile utils.go 包含编译器工具函数
package compile

import (
	"cuteify/compile/arch"
	"cuteify/compile/arch/x86"
	"cuteify/compile/arch/x86_64"
	"cuteify/compile/context"
	typeSys "cuteify/type"
)

// NewArch 根据架构名称创建对应的架构处理器
// 支持的架构: x86 (默认为cdecl), x86.cdecl, x86.stdcall, x86_64, x86_64.sysv
// 参数:
//   - archName: 架构名称字符串
//   - ctx: 编译上下文
//
// 返回: 架构处理器实例
func NewArch(archName string, ctx *context.Context) arch.Arch {
	var archHandle arch.Arch

	switch archName {
	case "x86":
		archHandle = x86.NewCdecl(ctx)
		typeSys.SetTargetPointerSize(4)
	case "x86.cdecl":
		archHandle = x86.NewCdecl(ctx)
		typeSys.SetTargetPointerSize(4)
	case "x86.stdcall":
		archHandle = x86.NewStdcall(ctx)
		typeSys.SetTargetPointerSize(4)
	case "x86_64", "x86_64.sysv":
		archHandle = x86_64.NewSysV(ctx)
		typeSys.SetTargetPointerSize(8)
	case "x86_64.win64":
		archHandle = x86_64.NewWin64(ctx)
		typeSys.SetTargetPointerSize(8)
	default:
		archHandle = x86.NewCdecl(ctx)
		typeSys.SetTargetPointerSize(4)
	}

	ctx.Arch = archHandle
	return archHandle
}
