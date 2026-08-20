package compile

import (
	"cuteify/parser"
	"cuteify/utils"
	"fmt"
	"strings"
)

func (c *Compiler) CompileBuild(n *parser.Node) (code string) {
	block := n.Value.(*parser.Build)
	switch block.Type {
	case "asm":
		asm := block.Asm
		// 使用存储的 VarBlock 进行替换
		for varName, tmpVar := range block.VarMap {
			// 局部变量：Offset 在编译期 SetupVarOffsets 才分配（Parse 期为 0），此处用真实偏移
			if tmpVar.Define.Node != nil {
				if vb, ok := tmpVar.Define.Value.(*parser.VarBlock); ok && !vb.IsGlobal && vb.IsDefine {
					tmpVar.Offset = vb.Offset
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
				addr = fmt.Sprintf("%s[rbp+%d]", sizePrefix, tmpVar.Offset)
				bare = fmt.Sprintf("[rbp+%d]", tmpVar.Offset)
			} else {
				addr = fmt.Sprintf("DWORD[ebp+%d]", tmpVar.Offset)
				bare = fmt.Sprintf("[ebp+%d]", tmpVar.Offset)
			}
			// 先替换 [$x]（内存寻址），再替换 $x（值加载）
			asm = strings.ReplaceAll(asm, "["+placeholder+"]", bare)
			asm = strings.ReplaceAll(asm, placeholder, addr)
		}
		// 使用 Format 格式化每一行
		lines := strings.Split(strings.TrimSpace(asm), "\n")
		for _, line := range lines {
			if strings.TrimSpace(line) != "" {
				code += utils.Format(line)
			}
		}
	}
	return
}
