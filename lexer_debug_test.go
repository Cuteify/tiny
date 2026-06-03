package main

import (
	"cuteify/lexer"
	"fmt"
	"testing"
)

func TestLexerInt(t *testing.T) {
	l := &lexer.Lexer{
		Text:       "type MyInt = int\n",
		Cursor:     0,
		TextLength: len("type MyInt = int\n"),
		LineFeed:   "\n",
	}
	
	// 读取 type
	tok := l.Next()
	fmt.Printf("Token 1: %s (type=%d)\n", tok.Value, tok.Type)
	
	// 读取 MyInt
	tok = l.Next()
	fmt.Printf("Token 2: %s (type=%d, cursor=%d)\n", tok.Value, tok.Type, tok.Cursor)
	
	// 读取 =
	tok = l.Next()
	fmt.Printf("Token 3: %s (type=%d, cursor=%d)\n", tok.Value, tok.Type, tok.Cursor)
	
	// 读取 int
	tok = l.Next()
	fmt.Printf("Token 4: %s (type=%d, cursor=%d)\n", tok.Value, tok.Type, tok.Cursor)
	
	// 退回到 int
	l.SetCursor(tok.Cursor)
	fmt.Printf("Cursor after SetCursor: %d\n", l.Cursor)
	
	// 再读取
	tok = l.Next()
	fmt.Printf("Token 5: %s (type=%d, cursor=%d)\n", tok.Value, tok.Type, tok.Cursor)
}
