package lexer

import (
	errorUtil "cuteify/error"
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
	Type      int
	Value     string
	Cursor    int
	EndCursor int
}

// 不可见字符表
var invisibleChar = map[string]string{
	" ":  "[SPACE]",
	"\t": "\\t",
	"\n": "\\n",
	"\r": "\\r",
}

func (t Token) String() string {
	typeName := ""
	for i, v := range LexTokenType {
		if v == t.Type {
			typeName = i
		}
	}
	val := t.Value
	val = makeVisible(val)
	return "[" + typeName + "]" + val
}

func (t Token) Len() int {
	return len(t.Value)
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
		l.AddCursor(1)
		if l.Text[l.Cursor] == '`' {
			break
		}
	}
	return l.Text[startCursor : l.Cursor-1]
}

func (l *Lexer) SkipSep() {
	if l.Text[l.Cursor] == ' ' {
		for i := l.Cursor; i < l.TextLength; i++ {
			if l.Text[i] != ' ' {
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
		// 遍历分隔符列表
		for e := 2; e > 0; e-- {
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
	switch word {
	case "\"":
		token := l.GetString()
		return Token{
			Type:      STRING,
			Value:     token,
			EndCursor: l.Cursor,
			Cursor:    l.Cursor - len(token),
		}, nil
	case "`":
		token := Token{
			Type:      RAW,
			Value:     l.GetRawString(),
			EndCursor: l.Cursor,
		}
		token.Cursor = l.Cursor - token.Len()
		return token, nil
	case "'":
		token := Token{
			Type:      CHAR,
			Value:     l.GetChar(),
			EndCursor: l.Cursor,
		}
		token.Cursor = l.Cursor - token.Len()
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
			Cursor:    l.Cursor - len(word),
		}, nil
	}
}

func (l *Lexer) GetToken() (Token, error) {
	if l.Cursor >= l.TextLength {
		return Token{}, io.EOF
	}
	// 直接操作光标，获取Token
	word, isSep := l.GetWord()
	if isSep {
		return l.handleSep(word)
	}
	// 匹配Token，返回类型
	if typeNum, ok := keywords[word]; ok {
		if typeNum == BOOL && (word == "true" || word == "false") {
			goto other
		}
		token := Token{
			Type:      typeNum,
			Value:     word,
			EndCursor: l.Cursor,
		}
		token.Cursor = l.Cursor - token.Len()
		return token, nil
	}
other:
	if isDigit(word) {
		oldCursor := l.Cursor
		word2, _ := l.GetWord()
		word3, _ := l.GetWord()
		if word2 == "." && isDigit(word3) {
			token := Token{
				Type:      NUMBER,
				Value:     word + "." + word3,
				EndCursor: l.Cursor,
			}
			token.Cursor = l.Cursor - token.Len()
			return token, nil
		}
		l.SetCursor(oldCursor)
		token := Token{
			Type:      NUMBER,
			Value:     word,
			EndCursor: l.Cursor,
		}
		token.Cursor = l.Cursor - token.Len()
		return token, nil
	} else {
		token := Token{
			Type:      NAME,
			Value:     word,
			EndCursor: l.Cursor,
		}
		token.Cursor = l.Cursor - token.Len()
		return token, nil
	}
}

func (l *Lexer) Next() Token {
	code, err := l.GetToken()
	if l.Text[code.Cursor:code.EndCursor] != code.Value {
		panic("Lexer: Next Token Value Error")
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
		l.Error.MissError("Syntax Error", l.Cursor, "need "+makeVisible(string(s)))
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
	return token.Type == 0
}

func isDigit(str string) bool {
	strLength := len(str)
	for i := 0; i < strLength; i++ {
		if str[i] < '0' || str[i] > '9' {
			return false
		}
	}
	return true
}

func makeVisible(str string) string {
	// 转换不可见字符，使用map表
	for k, v := range invisibleChar {
		str = strings.ReplaceAll(str, k, v)
	}
	return str
}
