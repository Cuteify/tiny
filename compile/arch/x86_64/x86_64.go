package x86_64

import "cuteify/compile/regmgr"

var Regs = []*regmgr.Reg{
	{Name: "RAX", RegIndex: 0},
	{Name: "RBX", CalleeSave: true, RegIndex: 1},
	{Name: "RCX", RegIndex: 2},
	{Name: "RDX", RegIndex: 3},
	{Name: "RSI", RegIndex: 4},
	{Name: "RDI", RegIndex: 5},
	{Name: "R8", RegIndex: 6},
	{Name: "R9", RegIndex: 7},
	{Name: "R10", RegIndex: 8},
	{Name: "R11", RegIndex: 9},
	{Name: "R12", CalleeSave: true, RegIndex: 10},
	{Name: "R13", CalleeSave: true, RegIndex: 11},
	{Name: "R14", CalleeSave: true, RegIndex: 12},
	{Name: "R15", CalleeSave: true, RegIndex: 13},
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
