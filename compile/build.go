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
		// 使用存储的 VarBlock 进行替换
		for varName, tmpVar := range block.VarMap {
			placeholder := "$" + varName
			addr := fmt.Sprintf("DWORD[ebp+%d]", tmpVar.Offset)
			asm = strings.ReplaceAll(asm, placeholder, addr)
		}
		// 使用 Format 格式化每一行
		lines := strings.Split(strings.TrimSpace(asm), "\n")
		for _, line := range lines {
			if strings.TrimSpace(line) != "" {
				code += utils.Format(line)
			}
		}
	case "system_call":
		syscallNum := block.Ext
		code += utils.Format("mov EAX, " + syscallNum + "; syscall number")

		// 从父函数获取参数偏移量
		funcNode := n.Father
		if funcBlock, ok := funcNode.Value.(*parser.FuncBlock); ok {
			regs := []string{"EBX", "ECX", "EDX", "ESI", "EDI", "EBP"}
			for i := 0; i < len(funcBlock.Args) && i < len(regs); i++ {
				arg := funcBlock.Args[i]
				offset := arg.Offset
				code += utils.Format("mov " + regs[i] + ", DWORD[ebp+" + strconv.Itoa(offset) + "]; arg" + strconv.Itoa(i+1))
			}
		}
		code += utils.Format("int 0x80")
	}
	return
}
