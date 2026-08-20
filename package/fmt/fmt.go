package packageFmt

import (
	"unsafe"
)

type Info struct {
	Version string            `json:"version"`
	Imports map[string]string `json:"imports"`
	Action  map[string]string `json:"action"`
	Path    string
	AST     any
}

func FixPathName(path string) string {
	tmp := make([]byte, len(path))
	for n := 0; n < len(path); n++ {
		char := path[n]
		switch char {
		case '\\':
			char = '/'
		case ' ':
			char = '_'
		case ':':
			char = '_'
		}
		// 处理非常规字符
		if char > 127 || char < 32 {
			char = '_'
		}
		tmp[n] = char
	}
	return unsafe.String(unsafe.SliceData(tmp), len(tmp))
}
