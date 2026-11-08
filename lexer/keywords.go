package lexer

// TokenType 是词法单元类型的枚举。
// 数值与自举版 selfhost/lex/lex.cute 的 enum TokenType 一一对应。
type TokenType int

const (
	NONE TokenType = iota
	FUNC
	VAR
	PROCESSCONTROL
	SEPARATOR
	STRING
	NUMBER
	NAME
	CHAR
	TYPE
	RAW
	BOOL
	BUILD
	IMPORT
)

// String 返回 token 类型名；未知类型返回空串。
func (t TokenType) String() string {
	switch t {
	case NONE:
		return "NONE"
	case FUNC:
		return "FUNC"
	case VAR:
		return "VAR"
	case PROCESSCONTROL:
		return "PROCESSCONTROL"
	case SEPARATOR:
		return "SEPARATOR"
	case STRING:
		return "STRING"
	case NUMBER:
		return "NUMBER"
	case NAME:
		return "NAME"
	case CHAR:
		return "CHAR"
	case TYPE:
		return "TYPE"
	case RAW:
		return "RAW"
	case BOOL:
		return "BOOL"
	case BUILD:
		return "BUILD"
	case IMPORT:
		return "IMPORT"
	default:
		return ""
	}
}

// TokenTypeName 返回 token 枚举对应的名称；未知类型返回空串。
// 保留函数入口，与自举版 tname 对照；新代码可直接用 TokenType.String。
func TokenTypeName(tokenType TokenType) string {
	return tokenType.String()
}

// 关键字
var (
	keywords = map[string]TokenType{
		"if":        PROCESSCONTROL,
		"while":     PROCESSCONTROL,
		"for":       PROCESSCONTROL,
		"return":    PROCESSCONTROL,
		"ret":       PROCESSCONTROL, // 旧拼法，保留兼容
		"break":     PROCESSCONTROL,
		"continue":  PROCESSCONTROL,
		"fallthrough": PROCESSCONTROL,
		"else":      PROCESSCONTROL,
		"switch":    PROCESSCONTROL,
		"case":      PROCESSCONTROL,
		"default":   PROCESSCONTROL,
		"range":     PROCESSCONTROL,
		"defer":     PROCESSCONTROL,
		"try":       PROCESSCONTROL,
		"except":    PROCESSCONTROL,
		"finally":   PROCESSCONTROL,
		"//":        SEPARATOR,
		";":         SEPARATOR,
		"{":         SEPARATOR,
		"}":         SEPARATOR,
		"(":         SEPARATOR,
		")":         SEPARATOR,
		"[":         SEPARATOR,
		"]":         SEPARATOR,
		",":         SEPARATOR,
		" ":         SEPARATOR,
		"=":         SEPARATOR,
		"+":         SEPARATOR,
		"-":         SEPARATOR,
		"*":         SEPARATOR,
		"/":         SEPARATOR,
		"%":         SEPARATOR,
		":":         SEPARATOR,
		"<":         SEPARATOR,
		">":         SEPARATOR,
		".":         SEPARATOR,
		"&":         SEPARATOR,
		"|":         SEPARATOR,
		"^":         SEPARATOR,
		"!":         SEPARATOR,
		"?":         SEPARATOR,
		"~":         SEPARATOR,
		"\"":        SEPARATOR,
		"'":         SEPARATOR,
		"\\":        SEPARATOR,
		"@":         SEPARATOR,
		"\n":        SEPARATOR,
		"\r":        SEPARATOR,
		"`":         SEPARATOR,
		"==":        SEPARATOR,
		"!=":        SEPARATOR,
		"<=":        SEPARATOR,
		">=":        SEPARATOR,
		"++":        SEPARATOR,
		"--":        SEPARATOR,
		"->":        SEPARATOR,
		"...":       SEPARATOR,
		"&&":        SEPARATOR,
		"||":        SEPARATOR,
		"<<":        SEPARATOR,
		">>":        SEPARATOR,
		":=":        SEPARATOR,
		"+=":        SEPARATOR,
		"-=":        SEPARATOR,
		"*=":        SEPARATOR,
		"/=":        SEPARATOR,
		"%=":        SEPARATOR,
		"^=":        SEPARATOR,
		"&=":        SEPARATOR,
		"|=":        SEPARATOR,
		"<<=":       SEPARATOR,
		">>=":       SEPARATOR,
		"type":      TYPE,
		"struct":    TYPE,
		"interface": TYPE,
		"enum":      TYPE,
		"self":      NAME,
		"true":      BOOL,
		"false":     BOOL,
		"nil":       BOOL,
		"fn":        FUNC,
		"const":     VAR,
		"var":       VAR,
		"let":       VAR,
		"build":     BUILD,
		"import":    IMPORT,
	}

	// LexToken类型：token 名称 → 枚举值，覆盖全部枚举（含 NONE）
	LexTokenType = map[string]TokenType{
		"NONE":           NONE,
		"FUNC":           FUNC,
		"VAR":            VAR,
		"PROCESSCONTROL": PROCESSCONTROL,
		"SEPARATOR":      SEPARATOR,
		"STRING":         STRING,
		"NUMBER":         NUMBER,
		"NAME":           NAME,
		"CHAR":           CHAR,
		"TYPE":           TYPE,
		"RAW":            RAW,
		"BOOL":           BOOL,
		"BUILD":          BUILD,
		"IMPORT":         IMPORT,
	}
)

var SepListLength = 32
var FuncListLength = 1
var VarListLength = 3
var ProcessControlListLength = 16
var TypeListLength = 2
var BoolListLength = 2
var BuildListLength = 1
var ImportListLength = 1
