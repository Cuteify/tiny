package lexer

// 关键字
var (
	keywords = map[string]int{
		"export":   PACKAGE,
		"import":   PACKAGE,
		"from":     PACKAGE,
		"as":       PACKAGE,
		"if":       PROCESSCONTROL,
		"while":    PROCESSCONTROL,
		"for":      PROCESSCONTROL,
		"ret":      PROCESSCONTROL,
		"break":    PROCESSCONTROL,
		"continue": PROCESSCONTROL,
		"else":     PROCESSCONTROL,
		"elif":     PROCESSCONTROL,
		"switch":   PROCESSCONTROL,
		"case":     PROCESSCONTROL,
		"try":      PROCESSCONTROL,
		"except":   PROCESSCONTROL,
		"finally":  PROCESSCONTROL,
		"exit":     PROCESSCONTROL,
		"//":       SEPARATOR,
		";":        SEPARATOR,
		"{":        SEPARATOR,
		"}":        SEPARATOR,
		"(":        SEPARATOR,
		")":        SEPARATOR,
		"[":        SEPARATOR,
		"]":        SEPARATOR,
		",":        SEPARATOR,
		" ":        SEPARATOR,
		"=":        SEPARATOR,
		"+":        SEPARATOR,
		"-":        SEPARATOR,
		"*":        SEPARATOR,
		"/":        SEPARATOR,
		"%":        SEPARATOR,
		":":        SEPARATOR,
		"<":        SEPARATOR,
		">":        SEPARATOR,
		".":        SEPARATOR,
		"&":        SEPARATOR,
		"|":        SEPARATOR,
		"^":        SEPARATOR,
		"!":        SEPARATOR,
		"~":        SEPARATOR,
		"\"":       SEPARATOR,
		"'":        SEPARATOR,
		"\\":       SEPARATOR,
		"@":        SEPARATOR,
		"\n":       SEPARATOR,
		"\r":       SEPARATOR,
		"`":        SEPARATOR,
		"==":       SEPARATOR,
		"!=":       SEPARATOR,
		"<=":       SEPARATOR,
		">=":       SEPARATOR,
		"++":       SEPARATOR,
		"--":       SEPARATOR,
		"->":       SEPARATOR,
		"&&":       SEPARATOR,
		"||":       SEPARATOR,
		"<<":       SEPARATOR,
		">>":       SEPARATOR,
		":=":       SEPARATOR,
		"type":     TYPE,
		"struct":   TYPE,
		"true":     BOOL,
		"false":    BOOL,
		"fn":       FUNC,
		"const":    VAR,
		"var":      VAR,
		"let":      VAR,
		"build":    BUILD,
	}

	// LexToken类型
	LexTokenType = map[string]int{
		"FUNC":           0x1,
		"VAR":            0x2,
		"PROCESSCONTROL": 0x3,
		"PACKAGE":        0x4,
		"SEPARATOR":      0x5,
		"STRING":         0x6,
		"NUMBER":         0x7,
		"IDENTIFIER":     0x8,
		"NAME":           0x9,
		"CHAR":           0xA,
		"TYPE":           0xB,
		"RAW":            0xC,
		"BOOL":           0xD,
		"BUILD":          0xE,
	}
)

const (
	FUNC = iota + 1
	VAR
	PROCESSCONTROL
	PACKAGE
	SEPARATOR
	STRING
	NUMBER
	IDENTIFIER
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
var ProcessControlListLength = 14
var PackageListLength = 4
var TypeListLength = 2
var BoolListLength = 2
var BuildListLength = 1
