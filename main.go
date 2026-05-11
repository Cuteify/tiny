package main

import (
	"cuteify/compile"
	packageSys "cuteify/package"
	"cuteify/parser"
	"fmt"
	"os"
	"reflect"
	"strings"
	"time"
)

func main() {
	startTime := time.Now()
	path := "./test"
	if len(os.Args) != 1 {
		path = os.Args[1]
	}
	tmp, err := packageSys.GetPackage(path, true)
	if err != nil {
		panic(err)
	}
	co := &compile.Compiler{}
	pr(tmp.AST.(*parser.Node), 0)
	code := co.Compile(tmp.AST.(*parser.Node))
	os.WriteFile(`./_main.asm`, []byte(code), 0644)
	fmt.Println("\033[32mOK\033[0m:Finish in", time.Since(startTime))
}

func pr(block *parser.Node, tabnum int) {
	html := buildHTML(block)
	os.WriteFile("./_ast.html", []byte(html), 0644)
	fmt.Println("AST HTML saved to _ast.html")
}

func buildHTML(block *parser.Node) string {
	var sb strings.Builder
	sb.WriteString(`<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8">
<title>AST 节点树</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: 'Segoe UI', system-ui, sans-serif; background: #1e1e2e; color: #cdd6f4; padding: 20px; }
.tree { list-style: none; padding-left: 20px; border-left: 1px solid #45475a; margin-left: 10px; }
.node { margin: 4px 0; }
.node-header { display: inline-flex; align-items: center; gap: 8px; cursor: pointer; padding: 4px 10px; border-radius: 6px; background: #313244; transition: 0.15s; }
.node-header:hover { background: #45475a; }
.toggle { color: #89b4fa; font-size: 12px; width: 16px; text-align: center; user-select: none; }
.type-badge { font-size: 11px; padding: 1px 8px; border-radius: 10px; font-weight: 600; }
.badge-func { background: #a6e3a1; color: #1e1e2e; }
.badge-var { background: #89b4fa; color: #1e1e2e; }
.badge-type { background: #f9e2af; color: #1e1e2e; }
.badge-call { background: #fab387; color: #1e1e2e; }
.badge-if { background: #cba6f7; color: #1e1e2e; }
.badge-while { background: #94e2d5; color: #1e1e2e; }
.badge-for { background: #74c7ec; color: #1e1e2e; }
.badge-return { background: #f38ba8; color: #1e1e2e; }
.badge-break { background: #eba0ac; color: #1e1e2e; }
.badge-build { background: #585b70; color: #cdd6f4; }
.badge-brackets { background: #6c7086; color: #cdd6f6; }
.badge-default { background: #585b70; color: #cdd6f4; }
.node-value { color: #a6adc8; font-size: 13px; margin-left: 4px; }
.node-value .key { color: #89b4fa; }
.node-value .str { color: #a6e3a1; }
.node-value .num { color: #fab387; }
.node-value .nil { color: #6c7086; font-style: italic; }
.collapsed > .tree { display: none; }
.code-block { display: block; background: #11111b; color: #a6e3a1; font-family: 'Fira Code', 'Cascadia Code', monospace; font-size: 12px; padding: 8px 12px; border-radius: 6px; margin-top: 4px; white-space: pre; overflow-x: auto; }
.exp-inline { color: #a6adc8; font-size: 12px; margin-left: 4px; }
.exp-inline .key { color: #89b4fa; }
.exp-inline .str { color: #a6e3a1; }
.exp-inline .num { color: #fab387; }
.exp-inline .nil { color: #6c7086; font-style: italic; }
.arg-item { display: inline-block; background: #45475a; padding: 0 6px; border-radius: 4px; margin: 0 2px; font-size: 12px; }
</style>
</head>
<body>
<h2 style="margin-bottom:16px;color:#89b4fa;">📦 AST 节点树</h2>
`)
	writeNode(&sb, block, 0)
	sb.WriteString(`<script>
document.querySelectorAll('.node-header').forEach(h => {
	h.addEventListener('click', () => {
		h.parentElement.classList.toggle('collapsed');
	});
});
</script>
</body>
</html>`)
	return sb.String()
}

func writeNode(sb *strings.Builder, block *parser.Node, depth int) {
	if block == nil || block.Ignore {
		return
	}

	typ := reflect.TypeOf(block.Value)
	typeName := ""
	if typ != nil {
		typeName = typ.String()
	}

	badgeClass := "badge-default"
	shortLabel := typeName
	valueStr := formatValue(block.Value)

	switch block.Value.(type) {
	case *parser.FuncBlock:
		badgeClass = "badge-func"
		if fb, ok := block.Value.(*parser.FuncBlock); ok {
			shortLabel = "fn " + fb.Name.String()
		}
	case *parser.VarBlock:
		badgeClass = "badge-var"
		if vb, ok := block.Value.(*parser.VarBlock); ok {
			shortLabel = "var " + vb.Name.String()
		}
	case *parser.TypeBlock:
		badgeClass = "badge-type"
		if tb, ok := block.Value.(*parser.TypeBlock); ok {
			shortLabel = "type " + tb.Name.String()
		}
	case *parser.CallBlock:
		badgeClass = "badge-call"
		if cb, ok := block.Value.(*parser.CallBlock); ok {
			shortLabel = "call " + cb.Name.String()
		}
	case *parser.IfBlock:
		badgeClass = "badge-if"
		shortLabel = "if"
	case *parser.ElseBlock:
		badgeClass = "badge-if"
		shortLabel = "else"
	case *parser.WhileBlock:
		badgeClass = "badge-while"
		shortLabel = "while"
	case *parser.ForBlock:
		badgeClass = "badge-for"
		shortLabel = "for"
	case *parser.ReturnBlock:
		badgeClass = "badge-return"
		shortLabel = "return"
	case *parser.BreakBlock:
		badgeClass = "badge-break"
		shortLabel = "break"
	case *parser.Build:
		badgeClass = "badge-build"
		shortLabel = "build"
	}

	hasChildren := len(block.Children) > 0

	sb.WriteString(`<div class="node">`)
	sb.WriteString(`<div class="node-header">`)
	if hasChildren {
		sb.WriteString(`<span class="toggle">▼</span>`)
	} else {
		sb.WriteString(`<span class="toggle" style="color:#45475a;">·</span>`)
	}
	sb.WriteString(`<span class="type-badge ` + badgeClass + `">` + shortLabel + `</span>`)
	sb.WriteString(`<span class="node-value">` + valueStr + `</span>`)
	sb.WriteString(`</div>`)

	if hasChildren {
		sb.WriteString(`<ul class="tree">`)
		for _, child := range block.Children {
			sb.WriteString(`<li>`)
			writeNode(sb, child, depth+1)
			sb.WriteString(`</li>`)
		}
		sb.WriteString(`</ul>`)
	}

	sb.WriteString(`</div>`)
}

func formatValue(v any) string {
	if v == nil {
		return `<span class="nil">nil</span>`
	}

	switch val := v.(type) {
	case *parser.FuncBlock:
		parts := []string{}
		if val.Class != nil {
			parts = append(parts, `<span class="key">class:</span> <span class="str">`+val.Class.Type()+`</span>`)
		}
		if len(val.Return) > 0 {
			retTypes := []string{}
			for _, r := range val.Return {
				retTypes = append(retTypes, r.Type())
			}
			parts = append(parts, `<span class="key">ret:</span> <span class="str">`+strings.Join(retTypes, ",")+`</span>`)
		}
		if len(val.Args) > 0 {
			argStrs := []string{}
			for _, a := range val.Args {
				t := "<nil>"
				if a.Type != nil {
					t = a.Type.Type()
				}
				argStrs = append(argStrs, a.Name.String()+":"+t)
			}
			parts = append(parts, `<span class="key">args:</span>(`+strings.Join(argStrs, ", ")+`)`)
		}
		return strings.Join(parts, " ")
	case *parser.VarBlock:
		parts := []string{}
		parts = append(parts, `<span class="key">name:</span> <span class="str">`+val.Name.String()+`</span>`)
		if val.Type != nil {
			parts = append(parts, `<span class="key">type:</span> <span class="str">`+val.Type.Type()+`</span>`)
		}
		parts = append(parts, fmt.Sprintf(`<span class="key">offset:</span> <span class="num">%d</span>`, val.Offset))
		if val.IsConst {
			parts = append(parts, `<span class="key">const</span>`)
		}
		return strings.Join(parts, " ")
	case *parser.TypeBlock:
		parts := []string{}
		parts = append(parts, `<span class="key">name:</span> <span class="str">`+val.Name.String()+`</span>`)
		if val.Type != nil {
			parts = append(parts, `<span class="key">type:</span> <span class="str">`+val.Type.Type()+`</span>`)
			if val.Type.Fields() != nil {
				fieldStrs := []string{}
				for _, f := range val.Type.Fields() {
					fieldStrs = append(fieldStrs, f.Name+":"+f.Type.Type())
				}
				parts = append(parts, `<span class="key">fields:</span>(`+strings.Join(fieldStrs, ", ")+`)`)
			}
		}
		return strings.Join(parts, " ")
	case *parser.CallBlock:
		parts := []string{}
		parts = append(parts, `<span class="key">name:</span> <span class="str">`+val.Name.String()+`</span>`)
		if val.Func != nil {
			parts = append(parts, `<span class="key">func:</span> <span class="str">`+val.Func.Name.String()+`</span>`)
		}
		if val.ThisVar != nil {
			parts = append(parts, `<span class="key">this:</span> <span class="str">`+val.ThisVar.Name.String()+`</span>`)
		}
		if len(val.Args) > 0 {
			argStrs := []string{}
			for _, a := range val.Args {
				s := a.Name.String() + ":"
				if a.Value != nil {
					s += formatExpression(a.Value)
				} else {
					s += "<span class=\"nil\">nil</span>"
				}
				argStrs = append(argStrs, `<span class="arg-item">`+s+`</span>`)
			}
			parts = append(parts, `<span class="key">args:</span> `+strings.Join(argStrs, " "))
		}
		return strings.Join(parts, " ")
	case *parser.IfBlock:
		return ""
	case *parser.ElseBlock:
		return ""
	case *parser.WhileBlock:
		return ""
	case *parser.ForBlock:
		return ""
	case *parser.ReturnBlock:
		parts := []string{}
		if len(val.Value) > 0 {
			expStrs := []string{}
			for _, e := range val.Value {
				expStrs = append(expStrs, formatExpression(e))
			}
			parts = append(parts, `<span class="key">ret:</span> `+strings.Join(expStrs, ", "))
		}
		return strings.Join(parts, " ")
	case *parser.BreakBlock:
		return ""
	case *parser.Build:
		parts := []string{}
		parts = append(parts, `<span class="key">type:</span> <span class="str">`+val.Type+`</span>`)
		switch val.Type {
		case "asm":
			if val.Asm != "" {
				escaped := strings.ReplaceAll(val.Asm, "&", "&amp;")
				escaped = strings.ReplaceAll(escaped, "<", "&lt;")
				escaped = strings.ReplaceAll(escaped, ">", "&gt;")
				parts = append(parts, `<span class="code-block">`+escaped+`</span>`)
			}
		case "ext":
			parts = append(parts, `<span class="key">ext:</span> <span class="str">`+val.Ext+`</span>`)
		case "extret":
			parts = append(parts, `<span class="key">extret:</span> <span class="str">`+val.ExtRet+`</span>`)
		case "link":
			parts = append(parts, `<span class="key">link:</span> <span class="str">`+val.Link+`</span>`)
		case "os":
			parts = append(parts, `<span class="key">os:</span> <span class="str">`+strings.Join(val.OS, ", ")+`</span>`)
		}
		return strings.Join(parts, " ")
	case *parser.Expression:
		parts := []string{}
		if val.Var != nil {
			parts = append(parts, `<span class="key">var:</span> <span class="str">`+val.Var.Name.String()+`</span>`)
		}
		if val.Type != nil {
			parts = append(parts, `<span class="key">type:</span> <span class="str">`+val.Type.Type()+`</span>`)
		}
		if val.Call != nil {
			parts = append(parts, `<span class="key">call:</span> <span class="str">`+val.Call.Name.String()+`</span>`)
		}
		if val.Separator != "" {
			parts = append(parts, `<span class="key">op:</span> <span class="str">`+val.Separator+`</span>`)
		}
		if val.Num != 0 {
			parts = append(parts, fmt.Sprintf(`<span class="key">num:</span> <span class="num">%v</span>`, val.Num))
		}
		if val.Bool {
			parts = append(parts, `<span class="key">bool:</span> <span class="num">true</span>`)
		}
		return strings.Join(parts, " ")
	default:
		return fmt.Sprintf(`<span class="str">%v</span>`, v)
	}
}

func formatExpression(exp *parser.Expression) string {
	if exp == nil {
		return `<span class="nil">nil</span>`
	}
	parts := []string{}
	if exp.Var != nil {
		parts = append(parts, `<span class="key">var:</span> <span class="str">`+exp.Var.Name.String()+`</span>`)
	}
	if exp.Call != nil {
		parts = append(parts, `<span class="key">call:</span> <span class="str">`+exp.Call.Name.String()+`</span>`)
	}
	if exp.Num != 0 {
		parts = append(parts, fmt.Sprintf(`<span class="key">num:</span> <span class="num">%v</span>`, exp.Num))
	}
	if exp.Bool {
		parts = append(parts, `<span class="key">bool:</span> <span class="num">true</span>`)
	}
	if exp.StringVal != "" {
		parts = append(parts, `<span class="key">str:</span> <span class="str">"`+exp.StringVal+`"</span>`)
	}
	if exp.Type != nil {
		parts = append(parts, `<span class="key">type:</span> <span class="str">`+exp.Type.Type()+`</span>`)
	}
	if exp.Separator != "" {
		parts = append(parts, `<span class="key">op:</span> <span class="str">`+exp.Separator+`</span>`)
	}
	if len(parts) == 0 {
		return `<span class="nil">empty</span>`
	}
	return `<span class="exp-inline">` + strings.Join(parts, " ") + `</span>`
}
