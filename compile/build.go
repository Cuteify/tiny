package compile

import (
	"cuteify/parser"
	"cuteify/utils"
	"fmt"
	"strconv"
	"strings"
)

func (c *Compiler) CompileBuild(n *parser.Node) (code string) {
	block := n.Value.(*parser.Build)
	switch block.Type {
	case "asm":
		asm := block.Asm
		// 使用存储的 VarBlock/ArgBlock 进行替换
		for varName, tmpVar := range block.VarMap {
			// Offset 在编译期 SetupVarOffsets / setArgsOffset 才分配（Parse 期为调用者帧偏移），此处刷新为真实偏移
			if tmpVar.Define.Node != nil {
				switch def := tmpVar.Define.Value.(type) {
				case *parser.VarBlock:
					if !def.IsGlobal && def.IsDefine {
						tmpVar.Offset = def.Offset
					}
				case *parser.ArgBlock:
					// 函数参数：setArgsOffset 已将 Offset 改为 callee-local 偏移（负值）
					tmpVar.Offset = def.Offset
				}
			}
			placeholder := "$" + varName
			var addr, bare string
			if c.Ctx.Is64Bit {
				sizePrefix := "QWORD"
				switch tmpVar.Type.Size() {
				case 1:
					sizePrefix = "BYTE"
				case 2:
					sizePrefix = "WORD"
				case 4:
					sizePrefix = "DWORD"
				}
				// 正确处理负偏移（callee-local: rbp-48）和正偏移
				if tmpVar.Offset < 0 {
					addr = fmt.Sprintf("%s[rbp%d]", sizePrefix, tmpVar.Offset)
					bare = fmt.Sprintf("[rbp%d]", tmpVar.Offset)
				} else {
					addr = fmt.Sprintf("%s[rbp+%d]", sizePrefix, tmpVar.Offset)
					bare = fmt.Sprintf("[rbp+%d]", tmpVar.Offset)
				}
			} else {
				addr = fmt.Sprintf("DWORD[ebp+%d]", tmpVar.Offset)
				bare = fmt.Sprintf("[ebp+%d]", tmpVar.Offset)
			}
			// 先替换 [$x]（内存寻址），再替换 $x（值加载）
			asm = strings.ReplaceAll(asm, "["+placeholder+"]", bare)
			asm = strings.ReplaceAll(asm, placeholder, addr)
		}
		// Auto-detect extern calls in asm blocks (call XXX where XXX is not a local label)
		if c.Ctx.Externs == nil {
			c.Ctx.Externs = make(map[string]bool)
		}
		// 已知运行时辅助函数（定义在同一文件中，不应标记为 extern）
		runtimeHelpers := map[string]bool{
			"_panic_index_oob": true,
			"_memmove":         true,
		}
		for _, line := range strings.Split(asm, "\n") {
			trimmed := strings.TrimSpace(line)
			if strings.HasPrefix(trimmed, "call ") && !strings.HasPrefix(trimmed, "call [") {
				funcName := strings.TrimSpace(strings.TrimPrefix(trimmed, "call "))
				// Skip indirect calls (call rax, call [rbx], etc.)
				if !strings.Contains(funcName, " ") && !strings.Contains(funcName, "[") && !runtimeHelpers[funcName] {
					c.Ctx.Externs[funcName] = true
				}
			}
		}
		// 使用 Format 格式化每一行
		lines := strings.Split(strings.TrimSpace(asm), "\n")
		for _, line := range lines {
			if strings.TrimSpace(line) != "" {
				code += utils.Format(line)
			}
		}
	case "ext":
		// build ext("funcname") — 调用外部 C 函数
		extName := strings.Trim(block.Ext, "\"'")
		fn := c.Ctx.CurrentFunc
		if fn == nil {
			return ""
		}
		if c.Ctx.Is64Bit {
			code = c.buildExtSysV(fn, extName)
		} else {
			code = c.buildExtCdecl(fn, extName)
		}
	case "export":
		// build export("alias") — 导出当前函数为指定别名
		exportName := strings.Trim(block.Export, "\"'")
		fn := c.Ctx.CurrentFunc
		if fn == nil {
			return ""
		}
		if c.Ctx.Exports == nil {
			c.Ctx.Exports = make(map[string]string)
		}
		c.Ctx.Exports[exportName] = fn.MangledName()
		// 仅记录，别名标签在 compileRootTail 统一生成（避免放在函数体内跳过 prologue）
	}
	return
}

// buildExtSysV 生成 x86_64 SysV ABI 外部函数调用
func (c *Compiler) buildExtSysV(fn *parser.FuncBlock, extName string) string {
	var code string
	// 记录需要的 extern 声明
	if c.Ctx.Externs == nil {
		c.Ctx.Externs = make(map[string]bool)
	}
	c.Ctx.Externs[extName] = true
	// x86_64 SysV: 前6个整数参数 → RDI, RSI, RDX, RCX, R8, R9
	// 参数由 setArgsOffset 保存到 callee-local 区（rbp-48 起）
	sysvRegs := []string{"RDI", "RSI", "RDX", "RCX", "R8", "R9"}
	for i := 0; i < len(fn.Args) && i < 6; i++ {
		arg := fn.Args[i]
		// 使用 arg.Offset（setArgsOffset 设置的 callee-local 偏移，如 -48）
		var argAddr string
		if arg.Offset < 0 {
			argAddr = "QWORD[rbp" + strconv.Itoa(arg.Offset) + "]"
		} else {
			argAddr = "QWORD[rbp+" + strconv.Itoa(arg.Offset) + "]"
		}
		code += utils.Format("mov " + sysvRegs[i] + ", " + argAddr + "; ext arg " + strconv.Itoa(i))
	}
	code += utils.Format("call " + extName)
	return code
}

// buildExtCdecl 生成 x86 cdecl 外部函数调用
func (c *Compiler) buildExtCdecl(fn *parser.FuncBlock, extName string) string {
	var code string
	// 记录需要的 extern 声明
	if c.Ctx.Externs == nil {
		c.Ctx.Externs = make(map[string]bool)
	}
	c.Ctx.Externs[extName] = true
	// cdecl: 参数从右到左压栈
	// 参数在栈上的位置: ebp+8 (第1个), ebp+12 (第2个), ...
	argOffset := 8
	offsets := make([]int, len(fn.Args))
	for i := 0; i < len(fn.Args); i++ {
		offsets[i] = argOffset
		argOffset += fn.Args[i].Type.Size()
	}
	// 从右到左压栈
	for i := len(fn.Args) - 1; i >= 0; i-- {
		code += utils.Format("push DWORD [ebp+" + strconv.Itoa(offsets[i]) + "]; ext arg " + strconv.Itoa(i))
	}
	// 保存对齐前 ESP，对齐后 call，call 后恢复 ESP 再清理参数
	code += utils.Format("mov edx, esp; 保存对齐前 ESP")
	code += utils.Format("and esp, -16; 16 字节对齐")
	code += utils.Format("call " + extName)
	code += utils.Format("mov esp, edx; 恢复 ESP（撤销对齐）")
	// cdecl: 调用者清理栈
	argBytes := argOffset - 8
	if argBytes > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(argBytes) + "; cdecl cleanup")
	}
	return code
}
