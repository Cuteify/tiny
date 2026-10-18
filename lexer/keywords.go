package lexer

// 关键字
var (
	keywords = map[string]int{
		"if":        PROCESSCONTROL,
		"while":     PROCESSCONTROL,
		"for":       PROCESSCONTROL,
		"return":    PROCESSCONTROL,
		"ret":       PROCESSCONTROL, // 旧拼法，保留兼容
		"break":     PROCESSCONTROL,
		"continue":  PROCESSCONTROL,
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
		"self":      NAME,
		"true":      BOOL,
		"false":     BOOL,
		"nil":       BOOL,
		"fn":        FUNC,
		"const":     VAR,
		"var":       VAR,
		"let":       VAR,
		"build":     BUILD,
	}

	// LexToken类型
	LexTokenType = map[string]int{
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
	}
)

const (
	NONE = iota
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
)

var SepListLength = 32
var FuncListLength = 1
var VarListLength = 3
var ProcessControlListLength = 16
var TypeListLength = 2
var BoolListLength = 2
var BuildListLength = 1
