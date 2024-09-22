package packageSys

import "future/parser"

type Info struct {
	Name    string            `json:"name"`
	Version string            `json:"version"`
	Import  map[string]string `json:"import"`
	Action  map[string]string `json:"action"`
	Path    string
	AST     *parser.Node
	Children []*Info
}
