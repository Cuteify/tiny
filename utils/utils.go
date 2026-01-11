package utils

import (
	"strings"
)

// Count 用于全局控制 Format 缩进级别 (与之前 compile 包中的 count 一致)
var Count int = 0
var LineNum int = 0

func CheckName(name string) bool {
	if len(name) == 0 {
		return false
	}
	// 判断第一位是否不是字母或_
	if (name[0] < 'a' || name[0] > 'z') && (name[0] < 'A' || name[0] > 'Z') && name[0] != '_' {
		return false
	}
	// 判断剩余字符必须是字母数字_
	for i := 1; i < len(name); i++ {
		if (name[i] < 'a' || name[i] > 'z') && (name[i] < 'A' || name[i] > 'Z') && (name[i] < '0' || name[i] > '9') && name[i] != '_' {
			return false
		}
	}
	return true
}

// Format 格式化汇编代码行（带缩进）
func Format(text string) string {
	LineNum++
	return strings.Repeat("    ", Count) + text + "\n"
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
