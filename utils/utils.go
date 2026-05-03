package utils

import (
	"strconv"
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

// ToNASMName 将函数名转换为 NASM 兼容的标签名称
// 转换规则：
//   - main → main（保持不变）
//   - 系统包（/pkg/ 路径下）→ std_ 开头，如 std_fs_open
//   - 外部包 → pkg_ 开头
//   - 本地包 → 使用相对路径
//   - 中文/特殊字符 → _u{Unicode码点} 格式
func ToNASMName(name string) string {
	if name == "main" {
		return name
	}

	// 判断是否是系统包（路径中包含 /pkg/）
	isSystemPkg := strings.Contains(name, "/pkg/") || strings.Contains(name, "\\pkg\\")

	var result string
	if isSystemPkg {
		// 系统包：提取 pkg 后面的部分
		pkgIndex := strings.LastIndex(name, "/pkg/")
		if pkgIndex == -1 {
			pkgIndex = strings.LastIndex(name, "\\pkg\\")
		}
		if pkgIndex != -1 {
			result = "std_" + name[pkgIndex+len("/pkg/"):]
		}
	} else {
		// 外部包或本地包：使用相对路径
		// 尝试找到项目根目录后的部分
		result = name
	}

	// 清理非法字符
	result = sanitizeNASMName(result)

	return result
}

// sanitizeNASMName 清理 NASM 标签中的非法字符
func sanitizeNASMName(name string) string {
	var result strings.Builder
	for _, r := range name {
		if (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9') || r == '_' {
			result.WriteRune(r)
		} else if r == '/' || r == '\\' || r == '.' || r == '-' {
			result.WriteRune('_')
		} else {
			// 中文或其他特殊字符 → _u{Unicode码点}
			result.WriteString("_u" + strconv.Itoa(int(r)))
		}
	}

	// 清理连续的下划线
	cleaned := result.String()
	for strings.Contains(cleaned, "__") {
		cleaned = strings.ReplaceAll(cleaned, "__", "_")
	}

	// 确保不以数字开头
	if len(cleaned) > 0 && cleaned[0] >= '0' && cleaned[0] <= '9' {
		cleaned = "_" + cleaned
	}

	return cleaned
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
