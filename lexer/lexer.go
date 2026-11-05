package lexer

import (
	errorUtil "cuteify/error"
	"cuteify/utils"
	"io"
	"os"
	"strings"
	"unsafe"
)

// Lexer 词法分析
type Lexer struct {
	Text       string
	LineFeed   string
	Cursor     int
	IsString   bool
	Error      *errorUtil.Error
	Filename   string
	TextLength int
	SepTmp     string
}

type Token struct {
	Type      TokenType
	Value     string
	Cursor    int
	EndCursor int
}

func (t Token) String() string {
	return "[" + TokenTypeName(t.Type) + "]" + utils.MakeVisible(t.Value)
}

func (t Token) Len() int {
	return len(t.Value)
}

func (t Token) IsLineEnd() bool {
	return t.IsEmpty() || (t.Type == SEPARATOR && (t.Value == "\n" || t.Value == "\r"))
}

func NewLexer(filename string) *Lexer {
	l := &Lexer{
		Filename: filename,
	}
	tmp, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	l.Text = unsafe.String(unsafe.SliceData(tmp), len(tmp))
	if l.Text == "" {
		panic("Lexer:Text is empty")
	}
	if strings.Count(l.Text, "\r\n") != 0 {
		l.LineFeed = "\r\n"
	} else if strings.Count(l.Text, "\n\r") != 0 {
		l.LineFeed = "\n\r"
	} else if strings.Count(l.Text, "\r") != 0 {
		l.LineFeed = "\r"
	} else {
		l.LineFeed = "\n"
	}
	l.Error = errorUtil.NewError(l.Filename, l.Text, l.LineFeed)
	l.TextLength = len(l.Text)
	l.Cursor = 0
	return l
}

func (l *Lexer) GetString() string {
	startCursor := l.Cursor
	for {
		if l.Cursor >= l.TextLength-1 {
			l.Error.MissError("Syntax Error", startCursor, "Only one \"\\\"\" mark was found")
		}
		word := l.Text[l.Cursor]
		if word == '\n' || word == '\r' {
			l.Error.MissError("Syntax Error", startCursor, "Only one \"\\\"\" mark was found")
		}
		l.AddCursor(1)
		if word == '"' {
			break
		}
	}
	return l.Text[startCursor : l.Cursor-1]
}

func (l *Lexer) GetChar() string {
	startCursor := l.Cursor
	for {
		if l.Cursor >= l.TextLength-1 {
			l.Error.MissError("Syntax Error", startCursor, "Only one \"\\\"\" mark was found")
		}
		word := l.Text[l.Cursor]
		if word == '\n' || word == '\r' {
			l.Error.MissError("Syntax Error", startCursor, "Only one \"\\\"\" mark was found")
		}
		l.AddCursor(1)
		if word == '\'' {
			break
		}
	}
	str := l.Text[startCursor : l.Cursor-1]
	if str[0:1] != "\\" && len(str) != 1 {
		l.Error.MissError("Syntax Error", startCursor, "The character is not one")
	}
	return str
}

func (l *Lexer) GetRawString() string {
	startCursor := l.Cursor
	for {
		if l.Cursor >= l.TextLength-1 { // 安全检查，防止越界
			l.Error.MissError("Lexer Error", startCursor, "expected '`' to close raw string")
			return l.Text[startCursor:l.Cursor]
		}
		l.AddCursor(1)
		if l.Text[l.Cursor] == '`' {
			break
		}
	}
	l.AddCursor(1)
	return l.Text[startCursor : l.Cursor-1]
}

func (l *Lexer) SkipSep() {
	if l.Cursor >= l.TextLength {
		return
	}
	if l.Text[l.Cursor] == ' ' || l.Text[l.Cursor] == '\t' {
		for i := l.Cursor; i < l.TextLength; i++ {
			if l.Text[i] != ' ' && l.Text[i] != '\t' {
				l.SetCursor(i)
				break
			}
		}
	}
}

func (l *Lexer) GetWord() (string, bool) {
	if l.SepTmp != "" {
		tmp := l.SepTmp
		l.AddCursor(len(tmp))
		if tmp == " " { // 空格不作为分隔符返回
			return l.GetWord()
		}
		return tmp, true
	}

	l.SkipSep()

	for i := l.Cursor; i < l.TextLength; i++ {
		//判断是否是分隔符
		// 遍历分隔符列表（先检查3字符，再2字符，再1字符）
		for e := 3; e > 0; e-- {
			if i+e-1 >= l.TextLength {
				continue
			}
			word := l.Text[i : i+e]
			if keywords[word] == SEPARATOR {
				text := l.Text[l.Cursor:i]
				l.SetCursor(i)
				l.SepTmp = word
				if text == "" {
					return l.GetWord()
				}
				return text, false
			}
		}
	}
	tmp2 := l.Text[l.Cursor:]
	l.AddCursor(len(tmp2))
	return tmp2, false
}

func (l *Lexer) handleSep(word string) (Token, error) {
	startCursor := l.Cursor - len(word)
	switch word {
	case "\"":
		token := l.GetString()
		return Token{
			Type:      STRING,
			Value:     token,
			EndCursor: l.Cursor, // more
			Cursor:    startCursor,
		}, nil
	case "`":
		token := Token{
			Type:      RAW,
			Value:     l.GetRawString(),
			Cursor:    startCursor,
			EndCursor: l.Cursor,
		}
		return token, nil
	case "'":
		token := Token{
			Type:      CHAR,
			Value:     l.GetChar(),
			Cursor:    startCursor,
			EndCursor: l.Cursor,
		}
		return token, nil
	case "//":
		// 找到行末
		for i := l.Cursor; i < l.TextLength; i++ {
			if l.Text[i-len(l.LineFeed):i] == l.LineFeed {
				l.SetCursor(i - len(l.LineFeed))
				return l.GetToken()
			}
		}
		return Token{}, io.EOF
	default:
		return Token{
			Type:      SEPARATOR,
			Value:     word,
			EndCursor: l.Cursor,
			Cursor:    startCursor,
		}, nil
	}
}

func (l *Lexer) GetToken() (Token, error) {
	if l.Cursor >= l.TextLength {
		return Token{}, io.EOF
	}
	// 数字扫描前先跳过行内空白，否则光标停在 `= 0` 的空格上会直接
	// 落入 GetWord，把 `0` 当成 NAME。
	l.SkipSep()
	if l.Cursor >= l.TextLength {
		return Token{}, io.EOF
	}
	// 数字字面量单独扫描：十六进制/二进制/八进制前缀、科学计数法和
	// 下划线分隔符都不是 GetWord 的"非分隔符字符"模型能正确切分的。
	if token, ok := l.scanNumber(); ok {
		return token, nil
	}
	// 直接操作光标，获取Token
	word, isSep := l.GetWord()

	if isSep {
		return l.handleSep(word)
	}
	// 匹配Token，返回类型
	if typeNum, ok := keywords[word]; ok {
		token := Token{
			Type:      typeNum,
			Value:     word,
			EndCursor: l.Cursor,
		}
		token.Cursor = l.Cursor - token.Len()
		return token, nil
	}
	token := Token{
		Type:      NAME,
		Value:     word,
		EndCursor: l.Cursor,
	}
	token.Cursor = l.Cursor - token.Len()
	return token, nil
}

// scanNumber 从当前光标扫描一个完整数字字面量。
// 支持：0x/0X 十六进制、0b/0B 二进制、0o/0O 八进制、十进制小数、
// 科学计数法（e/E 可带正负号）以及数字间的下划线。
func (l *Lexer) scanNumber() (Token, bool) {
	start := l.Cursor
	if start >= l.TextLength || !isDecDigit(l.Text[start]) {
		return Token{}, false
	}

	i := start
	if l.Text[i] == '0' && i+1 < l.TextLength {
		switch l.Text[i+1] {
		case 'x', 'X':
			i += 2
			digits := 0
			for i < l.TextLength && (isHexDigit(l.Text[i]) || l.Text[i] == '_') {
				if l.Text[i] != '_' {
					digits++
				}
				i++
			}
			if digits == 0 {
				return Token{}, false
			}
			return l.numberToken(start, i), true
		case 'b', 'B':
			i += 2
			digits := 0
			for i < l.TextLength && (l.Text[i] == '0' || l.Text[i] == '1' || l.Text[i] == '_') {
				if l.Text[i] != '_' {
					digits++
				}
				i++
			}
			if digits == 0 {
				return Token{}, false
			}
			return l.numberToken(start, i), true
		case 'o', 'O':
			i += 2
			digits := 0
			for i < l.TextLength && ((l.Text[i] >= '0' && l.Text[i] <= '7') || l.Text[i] == '_') {
				if l.Text[i] != '_' {
					digits++
				}
				i++
			}
			if digits == 0 {
				return Token{}, false
			}
			return l.numberToken(start, i), true
		}
	}

	for i < l.TextLength && (isDecDigit(l.Text[i]) || l.Text[i] == '_') {
		i++
	}
	// 小数部分：`.` 后必须紧跟数字，避免把 `1.foo` 吞进数字。
	if i+1 < l.TextLength && l.Text[i] == '.' && isDecDigit(l.Text[i+1]) {
		i += 2
		for i < l.TextLength && (isDecDigit(l.Text[i]) || l.Text[i] == '_') {
			i++
		}
	}
	// 指数部分：e/E 后可选 +/-，必须至少有一位数字。
	if i < l.TextLength && (l.Text[i] == 'e' || l.Text[i] == 'E') {
		j := i + 1
		if j < l.TextLength && (l.Text[j] == '+' || l.Text[j] == '-') {
			j++
		}
		if j < l.TextLength && isDecDigit(l.Text[j]) {
			j++
			for j < l.TextLength && (isDecDigit(l.Text[j]) || l.Text[j] == '_') {
				j++
			}
			i = j
		}
	}
	return l.numberToken(start, i), true
}

func (l *Lexer) numberToken(start, end int) Token {
	l.SetCursor(end)
	return Token{
		Type:      NUMBER,
		Value:     l.Text[start:end],
		Cursor:    start,
		EndCursor: end,
	}
}

func (l *Lexer) Next() Token {
	code, err := l.GetToken()
	//fmt.Println(l.Text[code.Cursor:code.EndCursor], code.Value)
	if l.Text[code.Cursor:code.EndCursor] != code.Value {
		switch code.Type {
		case STRING, RAW, CHAR:
			if code.Cursor+1 > code.EndCursor-1 && l.Text[code.Cursor+1:code.EndCursor-1] != code.Value {
				l.Error.MissError("Syntax Error", code.Cursor, "need "+utils.MakeVisible(code.Value))
			}
		default:
			l.Error.MissError("Syntax Error", code.Cursor, "need "+utils.MakeVisible(code.Value))
		}
	}
	if err == io.EOF {
		return Token{}
	}
	if err != nil {
		l.Error.MissError("Syntax Error", l.Cursor, err.Error())
	}
	return code
}

func (l *Lexer) Skip(s ...byte) {
	if string(s) != " " {
		l.SkipSep()
	}
	if l.Text[l.Cursor:l.Cursor+len(s)] != string(s) {
		l.Error.MissError("Syntax Error", l.Cursor, "need "+utils.MakeVisible(string(s)))
	}
	l.AddCursor(len(s))
}

func (l *Lexer) SetCursor(cursor int) {
	l.Cursor = cursor
	l.SepTmp = ""
}

func (l *Lexer) AddCursor(cursor int) {
	l.Cursor += cursor
	l.SepTmp = ""
}

func (token Token) IsEmpty() bool {
	return token.Type == NONE
}

func isDigit(str string) bool {
	strLength := len(str)
	for i := 0; i < strLength; i++ {
		if !isDecDigit(str[i]) {
			return false
		}
	}
	return true
}

func isDecDigit(c byte) bool {
	return c >= '0' && c <= '9'
}

func isHexDigit(c byte) bool {
	return isDecDigit(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
}
