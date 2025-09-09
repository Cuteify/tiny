package packageFmt

import (
	"unsafe"
)

type Info struct {
	Version string            `json:"version"`
	Import  map[string]string `json:"import"`
	Action  map[string]string `json:"action"`
	Path    string
	AST     any
}

func FixPathName(path string) string {
	tmp := make([]byte, len(path))
	for n, char := range path {
		tmp[n] = byte(char)
		switch char {
		case '\\':
			tmp[n] = '/'
		case ' ':
			tmp[n] = '_'
		case ':':
			tmp[n] = '_'
		}
		// 处理非常规字符
		if char > 128 {
			tmp[n] = '_'
		}
		if char < 32 {
			tmp[n] = '_'
		}
	}
	return unsafe.String(unsafe.SliceData(tmp), len(tmp))
}
