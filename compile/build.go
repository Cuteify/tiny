package compile

import "cuteify/parser"

func (c *Compiler) CompileBuild(n *parser.Node) (code string) {
	block := n.Value.(*parser.Build)
	switch block.Type {
	case "asm":
		code = block.Asm + "\n"
	}
	return
}