package packageFmt

type Info struct {
	Name     string            `json:"name"`
	Version  string            `json:"version"`
	Import   map[string]string `json:"import"`
	Action   map[string]string `json:"action"`
	Path     string
	AST      []any
	Children []*Info
}
