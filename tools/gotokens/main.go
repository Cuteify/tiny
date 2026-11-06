// gotokens 用 Go 版 lexer 打印 token 序列，供自举 lexer 对拍。
//
// 输出格式与 selfhost/cmd/tokdump 对齐：
//
//	line:col  TYPE  [text]  [start,end)
//	EOF line:col  tokens=N
//
// STRING/CHAR/RAW 的区间按内容计算（不含定界符），与自举 lexer 的
// start/end 约定一致；换行/回车/制表渲染为可见转义。
package main

import (
	"fmt"
	"os"
	"strings"

	"cuteify/lexer"
)

func advance(s string, from, to int, line, col *int) {
	if from >= to {
		return
	}
	if from < 0 {
		from = 0
	}
	if to > len(s) {
		to = len(s)
	}
	for i := from; i < to; i++ {
		if s[i] == '\n' {
			*line++
			*col = 1
		} else {
			*col++
		}
	}
}

func visible(s string) string {
	var b strings.Builder
	for i := 0; i < len(s); i++ {
		switch s[i] {
		case '\n':
			b.WriteString(`\n`)
		case '\r':
			b.WriteString(`\r`)
		case '\t':
			b.WriteString(`\t`)
		default:
			b.WriteByte(s[i])
		}
	}
	return b.String()
}

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintln(os.Stderr, "用法: gotokens <file.cute>")
		os.Exit(2)
	}

	l := lexer.NewLexer(os.Args[1])
	line, col := 1, 1
	last := 0
	count := 0

	for {
		tok := l.Next()
		if tok.Type == lexer.NONE {
			break
		}

		start, end := tok.Cursor, tok.EndCursor
		switch tok.Type {
		case lexer.STRING, lexer.CHAR, lexer.RAW:
			// Go 版 Cursor/EndCursor 含定界符；自举版只给内容区间。
			start++
			end--
		}

		advance(l.Text, last, start, &line, &col)
		fmt.Printf("%d:%d  %s  [%s]  [%d,%d)\n", line, col, tok.Type.String(), visible(tok.Value), start, end)
		count++

		advance(l.Text, start, end, &line, &col)
		last = end
	}

	advance(l.Text, last, len(l.Text), &line, &col)
	fmt.Printf("EOF %d:%d  tokens=%d\n", line, col, count)
}
