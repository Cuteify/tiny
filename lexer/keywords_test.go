package lexer

import "testing"

// TestTokenTypeString 校验 token 枚举的名称映射完整且与 LexTokenType 一致。
func TestTokenTypeString(t *testing.T) {
	tests := []struct {
		typ  TokenType
		want string
	}{
		{NONE, "NONE"},
		{FUNC, "FUNC"},
		{VAR, "VAR"},
		{PROCESSCONTROL, "PROCESSCONTROL"},
		{SEPARATOR, "SEPARATOR"},
		{STRING, "STRING"},
		{NUMBER, "NUMBER"},
		{NAME, "NAME"},
		{CHAR, "CHAR"},
		{TYPE, "TYPE"},
		{RAW, "RAW"},
		{BOOL, "BOOL"},
		{BUILD, "BUILD"},
		{IMPORT, "IMPORT"},
		{TokenType(99), ""},
	}
	for _, tt := range tests {
		if got := tt.typ.String(); got != tt.want {
			t.Errorf("TokenType(%d).String() = %q, want %q", tt.typ, got, tt.want)
		}
		if got := TokenTypeName(tt.typ); got != tt.want {
			t.Errorf("TokenTypeName(%d) = %q, want %q", tt.typ, got, tt.want)
		}
	}

	if len(LexTokenType) != 14 {
		t.Fatalf("LexTokenType has %d entries, want 14", len(LexTokenType))
	}
	for name, typ := range LexTokenType {
		if got := typ.String(); got != name {
			t.Errorf("LexTokenType[%q] = %d (%q), name mismatch", name, typ, got)
		}
	}
}
