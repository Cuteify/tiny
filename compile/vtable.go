// Package compile vtable generation for interface runtime dispatch.
package compile

import (
	typeSys "cuteify/type"
	"cuteify/utils"
)

// CompileVtableSection generates the .data section for all registered vtables.
func (c *Compiler) CompileVtableSection() string {
	if len(c.Ctx.VtableEntries) == 0 {
		return ""
	}
	ps := c.Ctx.Arch.PointerSize()
	dq := "dq"
	if ps == 4 {
		dq = "dd"
	}

	code := "\n; ============= vtable section =============\n"
	code += "section .data\n"
	for _, entry := range c.Ctx.VtableEntries {
		code += utils.Format(entry.Label + ":")
		utils.Count++
		// type_info placeholder (0 for now; could be a type descriptor pointer)
		code += utils.Format(dq + " 0 ; type_info")
		// method function pointers
		for _, methodLabel := range entry.Methods {
			code += utils.Format(dq + " " + methodLabel)
		}
		utils.Count--
	}
	return code
}

// Ensure InterfaceType is referenced to avoid import cycle issues
var _ = (*typeSys.InterfaceType)(nil)
