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
	LastSepTmp string
}

type Token struct {
	Type      int
	Value     string
	Cursor    int
	EndCursor int
}

func (t Token) String() string {
	typeName := ""
	for i, v := range LexTokenType {
		if v == t.Type {
			typeName = i
		}
	}
	return "[" + typeName + "]" + t.Value
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
		l.Cursor++
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
		l.Cursor++
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
		l.Cursor++
		if l.Text[l.Cursor] == '`' {
			break
		}
	}
	return l.Text[startCursor : l.Cursor-1]
}

func (l *Lexer) GetWord() (string, bool) {
	if l.LastSepTmp != "" {
		tmp := l.LastSepTmp
		l.LastSepTmp = ""
		l.Cursor += len(tmp)
		if tmp == " " {
			return l.GetWord()
		}
		return tmp, true
	}
	if l.Text[l.Cursor] == ' ' {
		for i := l.Cursor; i < l.TextLength; i++ {
			if l.Text[i] != ' ' {
				l.Cursor = i
				break
			}
		}
		return l.GetWord()
	}
	for e := 2; e > 0; e-- {
		if l.Cursor+e-1 >= l.TextLength {
			continue
		}
		word := l.Text[l.Cursor : l.Cursor+e]
		if keywords[word] == SEPARATOR {
			if word == " " {
				return l.GetWord()
			}
			l.Cursor += e
			return word, true
		}
	}
	for i := l.Cursor; i < l.TextLength; i++ {
		//判断是否是分隔符
		// 遍历分隔符列表
		word := l.Text[i : i+2]
		if i+1 < l.TextLength {
			if keywords[word] == SEPARATOR {
				text := l.Text[l.Cursor:i]
				l.Cursor = i
				l.LastSepTmp = word
				return text, false
			}
		}
		word = l.Text[i : i+1]
		if keywords[word] == SEPARATOR {
			text := l.Text[l.Cursor:i]
			l.Cursor = i
			l.LastSepTmp = word
			return text, false
		}
	}
	tmp2 := l.Text[l.Cursor:]
	l.Cursor += len(tmp2)
	return tmp2, false
}

func (l *Lexer) GetToken() (Token, error) {
	if l.Cursor >= l.TextLength {
		return Token{}, io.EOF
	}
	// 直接操作光标，获取Token
	word, isSep := l.GetWord()
	if isSep {
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
			token.Cursor = l.Cursor - len(token.Value)
			return token, nil
		case "'":
			token := Token{
				Type:      CHAR,
				Value:     l.GetChar(),
				EndCursor: l.Cursor,
			}
			token.Cursor = l.Cursor - len(token.Value)
			return token, nil
		case "//":
			// 找到行末
			for i := l.Cursor; i < l.TextLength; i++ {
				if l.Text[i-len(l.LineFeed):i] == l.LineFeed {
					l.Cursor = i - len(l.LineFeed)
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
		token.Cursor = l.Cursor - len(token.Value)
		return token, nil
	}
other:
	if IsDigit(word) {
		word2, _ := l.GetWord()
		word3, _ := l.GetWord()
		if word2 == "." && IsDigit(word3) {
			token := Token{
				Type:      NUMBER,
				Value:     word + "." + word3,
				EndCursor: l.Cursor,
			}
			token.Cursor = l.Cursor - len(token.Value)
			return token, nil
		}
		l.Back(len(word2 + word3))
		token := Token{
			Type:      NUMBER,
			Value:     word,
			EndCursor: l.Cursor,
		}
		token.Cursor = l.Cursor - len(token.Value)
		return token, nil
	} else {
		token := Token{
			Type:      NAME,
			Value:     word,
			EndCursor: l.Cursor,
		}
		token.Cursor = l.Cursor - len(token.Value)
		return token, nil
	}
}

func (l *Lexer) Next() Token {
	code, err := l.GetToken()
	if err == io.EOF {
		return Token{}
	}
	if err != nil {
		l.Error.MissError("Syntax Error", l.Cursor, err.Error())
	}
	return code
}

func (l *Lexer) Back(num int) {
	if num < 0 {
		num = -num
	}
	// 统计之间的空格，并回退
	// 统计之间的空格，并回退

	l.Cursor -= strings.Count(l.Text[l.Cursor-num:l.Cursor], " ")
	l.Cursor -= num
	l.LastSepTmp = ""
	if l.Cursor < 0 {
		l.Cursor = 0
	}
}

func (token Token) IsEmpty() bool {
	return token.Type == 0
}

func IsDigit(str string) bool {
	strLength := len(str)
	for i := 0; i < strLength; i++ {
		if str[i] < '0' || str[i] > '9' {
			return false
		}
	}
	return true
}
