package lexer

import (
	"os"
	"path/filepath"
	"testing"
)

func tokensOf(t *testing.T, src string) []Token {
	t.Helper()
	path := filepath.Join(t.TempDir(), "case.cute")
	if err := os.WriteFile(path, []byte(src), 0o644); err != nil {
		t.Fatalf("write temp file: %v", err)
	}
	l := NewLexer(path)
	var out []Token
	for {
		tok := l.Next()
		if tok.Type == NONE {
			break
		}
		out = append(out, tok)
	}
	return out
}

func assertSeq(t *testing.T, toks []Token, wantTyp []TokenType, wantVal []string) {
	t.Helper()
	if len(toks) != len(wantTyp) {
		t.Fatalf("token count = %d, want %d; tokens = %#v", len(toks), len(wantTyp), toks)
	}
	for i := range wantTyp {
		if toks[i].Type != wantTyp[i] {
			t.Errorf("tok[%d].Type = %v, want %v", i, toks[i].Type, wantTyp[i])
		}
		if toks[i].Value != wantVal[i] {
			t.Errorf("tok[%d].Value = %q, want %q", i, toks[i].Value, wantVal[i])
		}
	}
}

func TestStringEscapeQuote(t *testing.T) {
	src := "var s: string = \"a\\\"b\"\n"
	toks := tokensOf(t, src)
	assertSeq(t, toks,
		[]TokenType{VAR, NAME, SEPARATOR, NAME, SEPARATOR, STRING, SEPARATOR},
		[]string{"var", "s", ":", "string", "=", "a\\\"b", "\n"},
	)
}

func TestStringEscapeBackslash(t *testing.T) {
	src := "var s: string = \"a\\\\b\"\n"
	toks := tokensOf(t, src)
	assertSeq(t, toks,
		[]TokenType{VAR, NAME, SEPARATOR, NAME, SEPARATOR, STRING, SEPARATOR},
		[]string{"var", "s", ":", "string", "=", "a\\\\b", "\n"},
	)
}

func TestStringEscapeMixed(t *testing.T) {
	src := "var s: string = \"\\x41\\mB\\nT\\rX\\tY\"\n"
	toks := tokensOf(t, src)
	assertSeq(t, toks,
		[]TokenType{VAR, NAME, SEPARATOR, NAME, SEPARATOR, STRING, SEPARATOR},
		[]string{"var", "s", ":", "string", "=", "\\x41\\mB\\nT\\rX\\tY", "\n"},
	)
}

func TestStringEscapeSpaces(t *testing.T) {
	src := "var s: string = \"tick \\\\ slash\"\n"
	toks := tokensOf(t, src)
	assertSeq(t, toks,
		[]TokenType{VAR, NAME, SEPARATOR, NAME, SEPARATOR, STRING, SEPARATOR},
		[]string{"var", "s", ":", "string", "=", "tick \\\\ slash", "\n"},
	)
}

func TestStringEscapeQuoteInMiddle(t *testing.T) {
	src := "var s: string = \"SAY \\\"HI\\\" loud\"\n"
	toks := tokensOf(t, src)
	assertSeq(t, toks,
		[]TokenType{VAR, NAME, SEPARATOR, NAME, SEPARATOR, STRING, SEPARATOR},
		[]string{"var", "s", ":", "string", "=", "SAY \\\"HI\\\" loud", "\n"},
	)
}

func TestCharEscape(t *testing.T) {
	src := "var c: int = '\\n'\n"
	toks := tokensOf(t, src)
	assertSeq(t, toks,
		[]TokenType{VAR, NAME, SEPARATOR, NAME, SEPARATOR, CHAR, SEPARATOR},
		[]string{"var", "c", ":", "int", "=", "\\n", "\n"},
	)
}

func TestCharEscapeQuote(t *testing.T) {
	src := "var c: int = '\\''\n"
	toks := tokensOf(t, src)
	assertSeq(t, toks,
		[]TokenType{VAR, NAME, SEPARATOR, NAME, SEPARATOR, CHAR, SEPARATOR},
		[]string{"var", "c", ":", "int", "=", "\\'", "\n"},
	)
}

func TestRawStringNotEscapes(t *testing.T) {
	src := "var r: string = `a\\n`\n"
	toks := tokensOf(t, src)
	assertSeq(t, toks,
		[]TokenType{VAR, NAME, SEPARATOR, NAME, SEPARATOR, RAW, SEPARATOR},
		[]string{"var", "r", ":", "string", "=", "a\\n", "\n"},
	)
}
