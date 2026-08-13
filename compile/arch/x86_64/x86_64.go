package x86_64

import "cuteify/compile/regmgr"

var Regs = []*regmgr.Reg{
	{Name: "RAX", ClassMask: ClassGPR | ClassDiv, RegIndex: 0},
	{Name: "RBX", CalleeSave: true, ClassMask: ClassGPR, RegIndex: 1},
	{Name: "RCX", ClassMask: ClassGPR, RegIndex: 2},
	{Name: "RDX", ClassMask: ClassGPR | ClassDiv, RegIndex: 3},
	{Name: "RSI", ClassMask: ClassGPR, RegIndex: 4},
	{Name: "RDI", ClassMask: ClassGPR, RegIndex: 5},
	{Name: "R8", ClassMask: ClassGPR, RegIndex: 6},
	{Name: "R9", ClassMask: ClassGPR, RegIndex: 7},
	{Name: "R10", ClassMask: ClassGPR, RegIndex: 8},
	{Name: "R11", ClassMask: ClassGPR, RegIndex: 9},
	{Name: "R12", CalleeSave: true, ClassMask: ClassGPR, RegIndex: 10},
	{Name: "R13", CalleeSave: true, ClassMask: ClassGPR, RegIndex: 11},
	{Name: "R14", CalleeSave: true, ClassMask: ClassGPR, RegIndex: 12},
	{Name: "R15", CalleeSave: true, ClassMask: ClassGPR, RegIndex: 13},
}

func GetLenName(size int) string {
	switch size {
	case 1:
		return "BYTE"
	case 2:
		return "WORD"
	case 4:
		return "DWORD"
	case 8:
		return "QWORD"
	default:
		return ""
	}
}

// cloneRegs 复制寄存器表，并按给定 callee-save 列表标记 CalleeSave 标志
// （SysV 与 Win64 的 callee-save 集合不同，不能共用同一个表）
func cloneRegs(src []*regmgr.Reg, calleeSaveList []string) []*regmgr.Reg {
	dst := make([]*regmgr.Reg, len(src))
	for i, r := range src {
		cp := *r
		cp.CalleeSave = false
		for _, name := range calleeSaveList {
			if r.Name == name {
				cp.CalleeSave = true
				break
			}
		}
		dst[i] = &cp
	}
	return dst
}
