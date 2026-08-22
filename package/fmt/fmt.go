package packageFmt

import (
	"unsafe"
)

type Info struct {
	Version string            `json:"version"`
	Imports map[string]string `json:"imports"`
	Action  map[string]string `json:"action"`
	// Builtin 标记内置包：根包自动导入，顶层函数可无命名空间直接调用
	Builtin bool `json:"builtin,omitempty"`
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

// 全局类型注册表：解析期跨文件/跨包类型查找。
// key = FixPathName(包路径) + "/" + 类型名，value 为 typeSys.Type。
var typeTable = make(map[string]any)

// RegisterType 注册类型到全局表（解析期调用，供其它文件提前引用）
func RegisterType(pkgPath, typeName string, t any) {
	typeTable[FixPathName(pkgPath)+"/"+typeName] = t
}

// LookupType 按包路径 + 类型名查询全局类型表
func LookupType(pkgPath, typeName string) any {
	return typeTable[FixPathName(pkgPath)+"/"+typeName]
}

// 全局变量注册表：解析期/编译期跨文件、跨包全局变量查找。
// key = FixPathName(包路径) + "/" + 变量末段名，value 为 *parser.VarBlock。
var globalVarTable = make(map[string]any)

// RegisterGlobalVar 注册全局变量到全局表
func RegisterGlobalVar(pkgPath, varName string, v any) {
	globalVarTable[FixPathName(pkgPath)+"/"+varName] = v
}

// LookupGlobalVar 按包路径 + 变量名查询全局变量表
func LookupGlobalVar(pkgPath, varName string) any {
	return globalVarTable[FixPathName(pkgPath)+"/"+varName]
}
