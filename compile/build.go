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
	}
	return
}
