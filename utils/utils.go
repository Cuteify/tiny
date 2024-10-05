package utils

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
