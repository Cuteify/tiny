// Package compile utils.go 包含编译器工具函数
package compile

import (
	"cuteify/compile/arch"
	"cuteify/compile/arch/x86"
	"cuteify/compile/context"
)

// NewArch 根据架构名称创建对应的架构处理器
// 支持的架构: x86 (默认为cdecl), x86.cdecl, x86.stdcall
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
	case "x86.cdecl":
		archHandle = x86.NewCdecl(ctx)
	case "x86.stdcall":
		archHandle = x86.NewStdcall(ctx)
	/*case "x86.fastcall":
	return &x86FastcallArch{}*/
	default:
		// 默认使用 cdecl 调用约定
		archHandle = x86.NewCdecl(ctx)
	}

	ctx.Arch = archHandle
	return archHandle
}
