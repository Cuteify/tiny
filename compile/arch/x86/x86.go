package x86

import "cuteify/compile/regmgr"

var regs = []regmgr.RegInfo{
	{Name: "EAX", CallerSave: true},
	{Name: "EBX", CalleeSave: true}, // CalleeSave
	{Name: "ECX", CallerSave: true},
	{Name: "EDX", CallerSave: true},
}

// GetLengthName 返回大小对应的汇编长度前缀
func GetLengthName(size int) string {
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
