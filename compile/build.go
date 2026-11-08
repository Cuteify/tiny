package compile

import (
	"cuteify/parser"
	typeSys "cuteify/type"
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
	case "ext", "extret":
		// build ext("funcname") / build extret("funcname") — 调用外部 C 函数。
		// extret 在调用后用返回值直接跳函数出口，等价于 `ret ext(...)`。
		extName := strings.Trim(block.Ext, "\"'")
		if block.Type == "extret" {
			extName = strings.Trim(block.ExtRet, "\"'")
		}
		fn := c.Ctx.CurrentFunc
		if fn == nil || extName == "" {
			return ""
		}
		if c.Ctx.Is64Bit {
			code = c.buildExtSysV(fn, extName)
		} else {
			code = c.buildExtCdecl(fn, extName)
		}
		if block.Type == "extret" {
			code += utils.Format("jmp func_end_" + fn.MangledName() + "; extret: 直接以外部函数返回值返回")
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

// extArgBase 去掉别名包装，取底层类型用于判断符号/宽度。
// `type MyInt int` 的 Kind/Size/IsPointer 都来自底层 int，但 AliasType 的
// IsPointer 来自自身 RType（恒 false），指针别名必须解到最底层再判断。
func extArgBase(t typeSys.Type) typeSys.Type {
	for {
		a, ok := t.(*typeSys.AliasType)
		if !ok {
			return t
		}
		t = a.Underlying
	}
}

// extArgLoadSysV 生成按声明宽度装载整数/指针参数的指令。
// C 的 int 是 32 位有符号：声明为 int/i32 时符号扩展；uint/u32/bool/byte
// 零扩展。8 字节整数/指针整槽装载。
func extArgLoadSysV(dst64, dst32, addr string, t typeSys.Type) string {
	if t == nil {
		return "mov " + dst64 + ", QWORD" + addr
	}
	base := extArgBase(t)
	if base.IsPointer() || base.Type() == "ptr" || base.Size() >= 8 {
		return "mov " + dst64 + ", QWORD" + addr
	}
	signed := base.Kind() == "int"
	switch base.Size() {
	case 4:
		if signed {
			return "movsxd " + dst64 + ", DWORD" + addr
		}
		return "mov " + dst32 + ", DWORD" + addr
	case 2:
		if signed {
			return "movsx " + dst64 + ", WORD" + addr
		}
		return "movzx " + dst64 + ", WORD" + addr
	case 1:
		if signed {
			return "movsx " + dst64 + ", BYTE" + addr
		}
		return "movzx " + dst64 + ", BYTE" + addr
	}
	return "mov " + dst64 + ", QWORD" + addr
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
	sysvRegs := [][2]string{
		{"RDI", "EDI"}, {"RSI", "ESI"}, {"RDX", "EDX"},
		{"RCX", "ECX"}, {"R8", "R8D"}, {"R9", "R9D"},
	}
	for i := 0; i < len(fn.Args) && i < len(sysvRegs); i++ {
		arg := fn.Args[i]
		// 使用 arg.Offset（setArgsOffset 设置的 callee-local 偏移，如 -48）
		addr := fmt.Sprintf("[rbp%+d]", arg.Offset)
		code += utils.Format(extArgLoadSysV(sysvRegs[i][0], sysvRegs[i][1], addr, arg.Type) +
			"; ext arg " + strconv.Itoa(i))
	}
	code += utils.Format("call " + extName)
	return code
}

// extArgSlots 返回参数在 x86 栈上的槽字节数（4 字节粒度，与 setArgsOffset 一致）。
func extArgSlots(t typeSys.Type) int {
	size := 4
	if t != nil && t.Size() > 4 {
		size = ((t.Size() + 3) / 4) * 4
	}
	return size
}

// buildExtCdecl 生成 x86 cdecl 外部函数调用
func (c *Compiler) buildExtCdecl(fn *parser.FuncBlock, extName string) string {
	var code string
	// 记录需要的 extern 声明
	if c.Ctx.Externs == nil {
		c.Ctx.Externs = make(map[string]bool)
	}
	c.Ctx.Externs[extName] = true
	// cdecl: 参数从右到左压栈。参数在栈上的位置由 setArgsOffset 决定
	// （ebp+8 起，class/大值返回槽会把起点后移），直接使用 arg.Offset，
	// 不再用 Type.Size() 重算，避免与真实槽带错位。
	// 8 字节参数按高/低两个 dword 压栈：先高后低，低字最后入栈（栈顶）。
	argBytes := 0
	for i := len(fn.Args) - 1; i >= 0; i-- {
		arg := fn.Args[i]
		slots := extArgSlots(arg.Type)
		argBytes += slots
		for off := slots - 4; off >= 0; off -= 4 {
			code += utils.Format("push DWORD [ebp+" + strconv.Itoa(arg.Offset+off) + "]; ext arg " + strconv.Itoa(i))
		}
	}
	// 保存对齐前 ESP，对齐后 call，call 后恢复 ESP 再清理参数。
	// 必须用 callee-saved 寄存器：EDX 是 caller-saved，外部函数可随意破坏。
	// EBX 由本函数 prologue 保存、epilogue 恢复，此处覆盖不会泄漏。
	code += utils.Format("mov ebx, esp; 保存对齐前 ESP（callee-saved）")
	code += utils.Format("and esp, -16; 16 字节对齐")
	code += utils.Format("call " + extName)
	code += utils.Format("mov esp, ebx; 恢复 ESP（撤销对齐）")
	// cdecl: 调用者清理栈
	if argBytes > 0 {
		code += utils.Format("add esp, " + strconv.Itoa(argBytes) + "; cdecl cleanup")
	}
	return code
}
