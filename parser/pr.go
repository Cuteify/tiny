package parser

import (
	"fmt"
	"html"
	"io"
	"reflect"
	"strings"
)

func pr(block *Node, tabnum int) {
	/*if block.Ignore {
		return
	}*/
	fmt.Println(strings.Repeat("\t", tabnum), reflect.TypeOf(block.Value), block.Value)
	/*TODO：
	if sb, ok := block.Value.(*StructBlock); ok {
		fmt.Printf("\n=== Struct: %s ===\n", sb.Name)
		fmt.Println("Fields:")
		for _, f := range sb.Fields {
			accessStr := "public"
			if f.Access == AccessReadOnly {
				accessStr = "readonly"
			} else if f.Access == AccessWriteOnly {
				accessStr = "writeonly"
			} else if f.Access == AccessPrivate {
				accessStr = "private"
			}
			defaultStr := ""
			if f.DefaultValue != nil {
				defaultStr = fmt.Sprintf(" (default: %v)", f.DefaultValue)
			}
			tagStr := ""
			if len(f.Tags) > 0 {
				var tagParts []string
				for _, t := range f.Tags {
					tagParts = append(tagParts, t.Key+":"+t.Value)
				}
				tagStr = fmt.Sprintf(" (tags: %v)", tagParts)
			}
			fmt.Printf("  - %s: %v (access: %s)%s%s\n", f.Name, f.Type, accessStr, defaultStr, tagStr)
		}
		fmt.Println("Methods:")
		for _, m := range sb.Methods {
			fmt.Printf("  - %s\n", m.Name.String())
		}
		fmt.Println("=====================\n")
	}*/

	for _, k := range block.Children {
		pr(k, tabnum+1)
	}
}

var nodeIDCounter int

func generateASTHTML(root *Node, w io.Writer) {
	nodeIDCounter = 0
	fmt.Fprint(w, `<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8">
<title>Cuteify AST</title>
<style>
:root{--bg:#1a1b26;--bg2:#24283b;--fg:#a9b1d6;--dim:#565f89;--line:#3b3d57;--accent:#7aa2f7}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'JetBrains Mono','SF Mono','Fira Code','Consolas',monospace;background:var(--bg);color:var(--fg);padding:32px 40px;line-height:1.7;font-size:13px}
h1{color:var(--accent);font-size:20px;font-weight:700;margin-bottom:4px;letter-spacing:-.3px}
.subtitle{color:var(--dim);font-size:12px;margin-bottom:20px}
.toolbar{display:flex;gap:10px;margin-bottom:20px;align-items:center}
#search{background:var(--bg2);border:1px solid var(--line);color:var(--fg);padding:7px 14px;border-radius:6px;font-family:inherit;font-size:13px;width:280px;outline:none;transition:border .2s}
#search:focus{border-color:var(--accent)}
#search::placeholder{color:var(--dim)}
.btn{background:var(--bg2);border:1px solid var(--line);color:var(--dim);padding:5px 12px;border-radius:6px;cursor:pointer;font-family:inherit;font-size:12px;transition:all .15s}
.btn:hover{color:var(--fg);border-color:var(--accent)}
.tree{padding-left:0}
.node{list-style:none;position:relative;padding:2px 0}
.node::before{content:'';position:absolute;top:0;left:14px;border-left:1px dashed var(--line);height:100%}
.node:last-child::before{height:15px}
.node-content{display:inline-flex;align-items:center;gap:8px;padding:3px 10px 3px 6px;border-radius:6px;cursor:default;position:relative;z-index:1;background:var(--bg);transition:background .15s}
.node-content:hover{background:var(--bg2)}
.tag{font-size:10px;font-weight:700;padding:2px 7px;border-radius:4px;text-transform:uppercase;letter-spacing:.6px;white-space:nowrap}
.tag-func{background:#1a3a5c;color:#7aa2f7}
.tag-var{background:#2d1f3d;color:#bb9af7}
.tag-call{background:#1a3a2a;color:#73daca}
.tag-expr{background:#3b2a1a;color:#e0af68}
.tag-if{background:#3a1a2a;color:#f7768e}
.tag-else{background:#3a1a2a;color:#f7768e;opacity:.8}
.tag-for{background:#1a2a3a;color:#7dcfff}
.tag-return{background:#3a2a1a;color:#ff9e64}
.tag-type{background:#2a1a3a;color:#b4f9f8}
.tag-struct{background:#1a2a2a;color:#9ece6a}
.tag-interface{background:#2a2a1a;color:#e0af68}
.tag-build{background:#2a1a1a;color:#f7768e}
.tag-arg{background:#1a1a2a;color:#7dcfff}
.node-name{color:#c0caf5;font-weight:600}
.node-type{color:#9ece6a;font-size:12px;font-weight:500}
.node-detail{color:var(--dim);font-size:12px}
.node-sep{color:#f7768e;font-weight:700;font-size:12px}
.children{padding-left:28px;position:relative}
.children::before{content:'';position:absolute;top:0;left:14px;border-left:1px dashed var(--line);height:calc(100% - 12px)}
.collapsible{cursor:pointer;user-select:none}
.collapsible .toggle{display:inline-block;width:14px;height:14px;text-align:center;line-height:14px;font-size:9px;color:var(--dim);border-radius:3px;transition:all .15s;margin-right:2px}
.collapsible:hover .toggle{background:var(--bg2);color:var(--fg)}
.collapsed .toggle{transform:rotate(-90deg)}
.collapsed~.children{display:none}
.highlight{background:#33467c!important;border-radius:4px}
.dimmed{opacity:.25}
.legend{display:flex;gap:12px;flex-wrap:wrap;margin-bottom:16px}
.legend-item{display:flex;align-items:center;gap:4px;font-size:11px;color:var(--dim)}
.legend-dot{width:8px;height:8px;border-radius:2px}
</style>
</head>
<body>
<h1>Cuteify AST</h1>
<div class="subtitle">Abstract Syntax Tree Visualizer</div>
<div class="toolbar">
<input type="text" id="search" placeholder="Filter nodes..." autocomplete="off">
<button class="btn" onclick="toggleAll(false)">Expand All</button>
<button class="btn" onclick="toggleAll(true)">Collapse All</button>
</div>
<div class="legend">
<span class="legend-item"><span class="legend-dot" style="background:#7aa2f7"></span>fn</span>
<span class="legend-item"><span class="legend-dot" style="background:#bb9af7"></span>var</span>
<span class="legend-item"><span class="legend-dot" style="background:#73daca"></span>call</span>
<span class="legend-item"><span class="legend-dot" style="background:#e0af68"></span>expr</span>
<span class="legend-item"><span class="legend-dot" style="background:#f7768e"></span>if/ret</span>
<span class="legend-item"><span class="legend-dot" style="background:#7dcfff"></span>for</span>
<span class="legend-item"><span class="legend-dot" style="background:#9ece6a"></span>struct</span>
<span class="legend-item"><span class="legend-dot" style="background:#b4f9f8"></span>type</span>
</div>
`)
	var stats struct{ nodes, funcs, vars int }
	fmt.Fprintf(w, "<ul class=\"tree\">\n")
	emitNodeHTML(root, w, &stats)
	fmt.Fprintf(w, "</ul>\n")
	fmt.Fprintf(w, "<div class=\"subtitle\" style=\"margin-top:20px\">%d nodes · %d functions · %d variables</div>\n", stats.nodes, stats.funcs, stats.vars)
	fmt.Fprint(w, `<script>
function toggleAll(collapse){
  document.querySelectorAll('.collapsible').forEach(n=>{
    if(collapse) n.classList.add('collapsed');
    else n.classList.remove('collapsed');
  });
}
document.addEventListener('click',e=>{
  const t=e.target.closest('.collapsible');
  if(t){t.classList.toggle('collapsed');e.stopPropagation()}
});
const search=document.getElementById('search');
search.addEventListener('input',()=>{
  const q=search.value.toLowerCase();
  document.querySelectorAll('.node-content').forEach(n=>{
    n.classList.remove('highlight','dimmed');
    if(q && n.textContent.toLowerCase().includes(q)) n.classList.add('highlight');
  });
  if(q){
    document.querySelectorAll('.node-content:not(.highlight)').forEach(n=>n.classList.add('dimmed'));
    document.querySelectorAll('.collapsible.collapsed').forEach(n=>{
      if(n.querySelector('.highlight')||n.parentElement.querySelector('.highlight')) n.classList.remove('collapsed');
    });
  }
});
</script>
</body></html>`)
}

func emitNodeHTML(n *Node, w io.Writer, stats *struct{ nodes, funcs, vars int }) {
	/*if n.Ignore {
		return
	}*/
	stats.nodes++
	id := nodeIDCounter
	nodeIDCounter++

	fmt.Fprintf(w, "<li class=\"node\">\n")

	val := n.Value
	if val == nil {
		fmt.Fprintf(w, "  <span class=\"node-content\"><span class=\"tag tag-expr\">root</span></span>\n")
		emitChildrenHTML(n, w, stats)
		fmt.Fprintf(w, "</li>\n")
		return
	}

	tag, name, detail, tagClass, typStr := blockInfo(val)
	switch val.(type) {
	case *FuncBlock:
		stats.funcs++
	case *VarBlock:
		stats.vars++
	}

	hasChildren := len(n.Children) > 0
	collClass := ""
	if hasChildren {
		collClass = " collapsible"
	}

	fmt.Fprintf(w, "  <span class=\"node-content%s\" data-id=\"%d\">\n", collClass, id)
	if hasChildren {
		fmt.Fprintf(w, "    <span class=\"toggle\">▾</span>\n")
	}
	fmt.Fprintf(w, "    <span class=\"tag %s\">%s</span>\n", tagClass, tag)
	if name != "" {
		fmt.Fprintf(w, "    <span class=\"node-name\">%s</span>\n", html.EscapeString(name))
	}
	if typStr != "" {
		fmt.Fprintf(w, "    <span class=\"node-type\">%s</span>\n", html.EscapeString(typStr))
	}
	if detail != "" {
		fmt.Fprintf(w, "    <span class=\"node-detail\">%s</span>\n", html.EscapeString(detail))
	}
	fmt.Fprintf(w, "  </span>\n")

	emitChildrenHTML(n, w, stats)
	fmt.Fprintf(w, "</li>\n")
}

func emitChildrenHTML(n *Node, w io.Writer, stats *struct{ nodes, funcs, vars int }) {
	if len(n.Children) == 0 {
		return
	}
	fmt.Fprintf(w, "  <ul class=\"children\">\n")
	for _, child := range n.Children {
		emitNodeHTML(child, w, stats)
	}
	fmt.Fprintf(w, "  </ul>\n")
}

func blockInfo(b Block) (tag, name, detail, tagClass, typStr string) {
	rv := reflect.ValueOf(b)
	if rv.Kind() == reflect.Ptr {
		rv = rv.Elem()
	}
	typeName := rv.Type().Name()

	switch v := b.(type) {
	case *FuncBlock:
		tagClass = "tag-func"
		tag = "fn"
		name = v.Name.String()
		var argStrs []string
		for _, a := range v.Args {
			argStrs = append(argStrs, argInfo(a))
		}
		detail = "(" + strings.Join(argStrs, ", ") + ")"
		if len(v.Return) > 0 {
			var retStrs []string
			for _, r := range v.Return {
				retStrs = append(retStrs, r.Type())
			}
			typStr = "→ " + strings.Join(retStrs, ", ")
		}
		if v.Class != nil {
			detail = "impl " + v.Class.Type() + " " + detail
		}
	case *VarBlock:
		tagClass = "tag-var"
		if v.IsConst {
			tag = "const"
		} else if v.IsDefine {
			tag = "var:="
		} else {
			tag = "var"
		}
		name = v.Name.String()
		if v.Type != nil {
			typStr = v.Type.Type()
		}
		if v.Value != nil {
			detail = "= " + exprSummary(v.Value)
		}
	case *CallBlock:
		tagClass = "tag-call"
		tag = "call"
		name = v.Name.String()
		var argStrs []string
		for _, a := range v.Args {
			argStrs = append(argStrs, argInfo(a))
		}
		detail = "(" + strings.Join(argStrs, ", ") + ")"
	case *Expression:
		tagClass = "tag-expr"
		tag = "expr"
		detail = exprSummary(v)
		if v.Type != nil {
			typStr = v.Type.Type()
		}
	case *IfBlock:
		tagClass = "tag-if"
		tag = "if"
		if v.Condition != nil {
			detail = exprSummary(v.Condition)
		}
	case *ElseBlock:
		tagClass = "tag-else"
		tag = "else"
	case *ForBlock:
		tagClass = "tag-for"
		tag = "for"
		parts := []string{}
		if v.Init != nil {
			parts = append(parts, exprSummary(v.Init))
		}
		parts = append(parts, ";")
		if v.Condition != nil {
			parts = append(parts, exprSummary(v.Condition))
		}
		parts = append(parts, ";")
		if v.Increment != nil {
			parts = append(parts, exprSummary(v.Increment))
		}
		detail = strings.Join(parts, " ")
	case *ReturnBlock:
		tagClass = "tag-return"
		tag = "ret"
		if len(v.Value) > 0 {
			var vals []string
			for _, e := range v.Value {
				vals = append(vals, exprSummary(e))
			}
			detail = strings.Join(vals, ", ")
		}
	case *TypeBlock:
		tagClass = "tag-type"
		tag = "type"
		name = v.Name.String()
		switch v.Kind {
		case TypeAlias:
			detail = "= " + v.Alias.Type()
		case TypeStruct:
			detail = "struct"
		case TypeInterface:
			detail = "interface"
		}
	case *StructBlock:
		tagClass = "tag-struct"
		tag = "struct"
		fields := v.Type.Fields()
		var fieldStrs []string
		for _, f := range fields {
			s := f.Name
			if f.Type != nil {
				s += ": " + f.Type.Type()
			}
			fieldStrs = append(fieldStrs, s)
		}
		detail = "{" + strings.Join(fieldStrs, ", ") + "}"
	case *InterfaceDef:
		tagClass = "tag-interface"
		tag = "interface"
		var methStrs []string
		for _, m := range v.Methods {
			s := m.Name.String() + "("
			var argStrs []string
			for _, a := range m.Args {
				argStrs = append(argStrs, argInfo(a))
			}
			s += strings.Join(argStrs, ", ") + ")"
			if len(m.Returns) > 0 {
				var retStrs []string
				for _, r := range m.Returns {
					retStrs = append(retStrs, r.Type())
				}
				s += " → " + strings.Join(retStrs, ", ")
			}
			methStrs = append(methStrs, s)
		}
		detail = "{" + strings.Join(methStrs, ", ") + "}"
	case *Build:
		tagClass = "tag-build"
		tag = "build"
		detail = v.Type
	default:
		tag = strings.ToLower(typeName)
		tagClass = "tag-expr"
	}
	return
}

func argInfo(a *ArgBlock) string {
	s := a.Name.String()
	if a.Value != nil {
		s += " = " + exprSummary(a.Value)
	} else if a.Type != nil {
		s += ": " + a.Type.Type()
	}
	return s
}

func exprSummary(e *Expression) string {
	if e == nil {
		return "nil"
	}
	if e.Var != nil {
		s := e.Var.Name.String()
		return s
	}
	if e.Call != nil {
		var argStrs []string
		for _, a := range e.Call.Args {
			argStrs = append(argStrs, argInfo(a))
		}
		return e.Call.Name.String() + "(" + strings.Join(argStrs, ", ") + ")"
	}
	if e.Separator == "list_lit" {
		var elems []string
		for _, el := range e.ListElems {
			elems = append(elems, exprSummary(el))
		}
		return "[" + strings.Join(elems, ", ") + "]"
	}
	if e.Separator == "[]" {
		return exprSummary(e.Left) + "[" + exprSummary(e.Right) + "]"
	}
	if e.Separator == "[]=" {
		idxStr := ""
		valStr := ""
		if e.Right != nil {
			if e.Right.Left != nil {
				idxStr = exprSummary(e.Right.Left)
			}
			if e.Right.Right != nil {
				valStr = exprSummary(e.Right.Right)
			}
		}
		return exprSummary(e.Left) + "[" + idxStr + "] = " + valStr
	}
	if e.Separator == "[::]" {
		startStr := ""
		endStr := ""
		stepStr := ""
		if e.Right != nil {
			if e.Right.Left != nil {
				startStr = exprSummary(e.Right.Left)
			}
			if e.Right.Right != nil {
				if e.Right.Right.Left != nil {
					endStr = exprSummary(e.Right.Right.Left)
				}
				if e.Right.Right.Right != nil {
					stepStr = exprSummary(e.Right.Right.Right)
				}
			}
		}
		s := exprSummary(e.Left) + "[" + startStr + ":" + endStr
		if stepStr != "" {
			s += ":" + stepStr
		}
		return s + "]"
	}
	if e.Separator != "" {
		left := exprSummary(e.Left)
		right := exprSummary(e.Right)
		if e.Separator == "." {
			return left + "." + right
		}
		return "(" + left + " " + e.Separator + " " + right + ")"
	}
	if e.StringVal != "" {
		return "\"" + e.StringVal + "\""
	}
	if e.ConstBool {
		return fmt.Sprintf("%v", e.Bool)
	}
	if e.Num != 0 || (e.Left == nil && e.Right == nil && e.Var == nil && e.Call == nil && e.Separator == "") {
		return fmt.Sprintf("%v", e.Num)
	}
	if e.Type != nil {
		return e.Type.Type()
	}
	return "?"
}
