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
	for i, entry := range c.Ctx.VtableEntries {
		dropLabel := "0"
		if st, ok := entry.Concrete.(*typeSys.StructType); ok {
			dropLabel = c.ensureDropFunc(st)
		} else if entry.Concrete != nil && entry.Concrete.IsPointer() {
			if st, ok := entry.Concrete.Elem().(*typeSys.StructType); ok {
				dropLabel = c.ensureDropFunc(st)
			}
		}
		c.Ctx.VtableEntries[i].DropFunc = dropLabel
		code += utils.Format(entry.Label + ":")
		utils.Count++
		// slot 0: drop/destructor for data_ptr (used by deep drop of interface fields)
		code += utils.Format(dq + " " + dropLabel + " ; drop_fn")
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
