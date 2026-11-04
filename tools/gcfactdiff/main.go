// gcfactdiff — Stage 2 双轨对拍：旧链（parser.Check 期事实 + gcfe.SimulateRC）
// vs 新链（gc.CollectFront 后置 pass）。
//
// 用法：gcfactdiff ./test/xxx
// 输出：五态计数、按分配语句对齐的对象字段差异、语句级 ReleasesOld 差异。
// 只读，不写任何文件。

package main

import (
	"fmt"
	"os"
	"sort"
	"strings"

	"cuteify/gc"
	packageSys "cuteify/package"
	"cuteify/parser"
)

func main() {
	path := "./test"
	if len(os.Args) > 1 {
		path = os.Args[1]
	}
	info, err := packageSys.GetPackage(path, true)
	if err != nil {
		fmt.Printf("FAIL %s: %v\n", path, err)
		os.Exit(2)
	}
	root := info.AST.(*parser.Node)

	oldObjs := parser.Objects()
	oldStats := countOld(oldObjs)

	gc.CollectFront(root)
	newObjs := gc.Objects()
	newStats := gc.Stats()

	oldBySite, oldNoSite, oldLabel := oldAllocSites(root, oldObjs)
	newBySite, newNoSite, newLabel := newAllocSites(newObjs)
	if os.Getenv("GCFACT_DEBUG") != "" {
		for site, oo := range oldBySite {
			fmt.Printf("OLDOBJ %s #%d %s esc=%v xfer=%v\n", oldLabel[site], oo.ID, legacyDisposal(oo), oo.Escapes, oo.Transferred)
		}
		for site, no := range newBySite {
			fmt.Printf("NEWOBJ %s #%d %s esc=%v xfer=%v\n", newLabel[site], no.ID, gc.DisposalOf(no), no.Escapes, no.Transferred)
		}
	}

	fmt.Printf("DIR %s\n", path)
	fmt.Printf("old %s\n", fmtStats(oldStats))
	fmt.Printf("new %s\n", fmtStats(newStats))
	prem, premDetail := gc.Premature()
	fmt.Printf("new diag prem=%d holderBad=%d\n", prem, newStats.HolderBad)
	if os.Getenv("GCFACT_DEBUG") != "" {
		for _, d := range premDetail {
			fmt.Println("PREMATURE " + d)
		}
	}
	fmt.Printf("site old=%d nos=%d new=%d nos=%d common=%d oldOnly=%d newOnly=%d\n",
		len(oldBySite), oldNoSite, len(newBySite), newNoSite,
		commonKeys(oldBySite, newBySite), onlyKeys(oldBySite, newBySite), onlyKeys(newBySite, oldBySite))

	mismatches := 0
	// 旧有新无
	for site, oo := range oldBySite {
		if _, ok := newBySite[site]; !ok {
			fmt.Printf("OLDONLY %s #%d %s\n", oldLabel[site], oo.ID, legacyDisposal(oo))
			mismatches++
		}
	}
	// 新有旧无
	for site, no := range newBySite {
		if _, ok := oldBySite[site]; !ok {
			fmt.Printf("NEWONLY %s #%d %s\n", newLabel[site], no.ID, gc.DisposalOf(no))
			mismatches++
		}
	}
	// 共同分配点逐字段比
	sites := make([]*parser.VarBlock, 0, len(newBySite))
	for site := range newBySite {
		if _, ok := oldBySite[site]; ok {
			sites = append(sites, site)
		}
	}
	sort.Slice(sites, func(i, j int) bool {
		return newLabel[sites[i]] < newLabel[sites[j]]
	})
	limit := 40
	for _, site := range sites {
		oo, no := oldBySite[site], newBySite[site]
		diffs := compareObjects(oo, no, oldBySite, newBySite)
		if len(diffs) == 0 {
			continue
		}
		mismatches++
		if mismatches > limit {
			continue
		}
		fmt.Printf("OBJ %s old#%d/%s new#%d/%s: %s\n",
			oldLabel[site], oo.ID, legacyDisposal(oo), no.ID, gc.DisposalOf(no), strings.Join(diffs, "; "))
	}

	// 语句级 ReleasesOld / OldObj
	stmtMismatch := 0
	walkStatements(root, func(v *parser.VarBlock, label string) {
		oldRel := v.Life.ReleasesOld
		var oldOld *parser.VarBlock
		if v.Life.OldObj != nil {
			oldOld = oldObjectSite(v.Life.OldObj, oldBySite)
		}
		newRel, newOldObj := gc.StatementFlags(v)
		var newOld *parser.VarBlock
		if newOldObj != nil {
			newOld = newOldObj.AllocSite()
		}
		if oldRel == newRel && oldOld == newOld {
			return
		}
		stmtMismatch++
		if stmtMismatch <= limit {
			fmt.Printf("STMT %s old(rel=%v old=%v) new(rel=%v old=%v)\n",
				label, oldRel, siteName(oldOld), newRel, siteName(newOld))
		}
	})
	fmt.Printf("mismatch obj=%d stmt=%d\n\n", mismatches, stmtMismatch)
}

func countOld(objs []*parser.Object) gc.FrontStats {
	st := gc.FrontStats{ByScopeKind: map[string]int{}}
	for _, o := range objs {
		d := parser.DisposalOf(o)
		st.Objects++
		switch d {
		case parser.DisposalScope:
			st.Scope++
			st.ByScopeKind[oldScopeKind(o.FreeScope)]++
			if !oldHolderValid(o) {
				st.HolderBad++
			}
		case parser.DisposalRC:
			st.RC++
		case parser.DisposalInplace:
			st.InplaceObj++
		case parser.DisposalField:
			st.Field++
		case parser.DisposalBorrow:
			if o.Transferred {
				st.Transfer++
			} else {
				st.Borrow++
				if o.FreeScope == nil && !o.Escapes {
					st.Leak++
				}
			}
		}
	}
	return st
}

func fmtStats(s gc.FrontStats) string {
	return fmt.Sprintf("obj=%d scope=%d rc=%d inplaceObj=%d field=%d transfer=%d borrow=%d leak=%d prem=%d",
		s.Objects, s.Scope, s.RC, s.InplaceObj, s.Field, s.Transfer, s.Borrow, s.Leak, 0)
}

func oldScopeKind(b parser.Block) string {
	switch b.(type) {
	case *parser.FuncBlock:
		return "fn"
	case *parser.ForBlock:
		return "for"
	case *parser.IfBlock:
		return "if"
	case *parser.ElseBlock:
		return "else"
	case *parser.SwitchBlock:
		return "switch"
	case *parser.CaseBlock:
		return "case"
	}
	return "?"
}

func oldHolderValid(o *parser.Object) bool {
	if o.Holder == nil || o.FreeScope == nil {
		return false
	}
	return oldHolderLives(o.Holder, o.FreeScope)
}

func oldHolderLives(v *parser.VarBlock, scope parser.Block) bool {
	if v.Life.Scope == nil {
		return false
	}
	return oldDepth(v.Life.Scope) <= oldDepth(scope)
}

func oldDepth(b parser.Block) int {
	d := 0
	for ; b != nil; b = oldParent(b) {
		d++
	}
	return d
}

func oldParent(b parser.Block) parser.Block {
	for n := parser.BlockNode(b); n != nil && n.Father != nil; n = n.Father {
		if n.Father.Value != nil && parser.IsScopeBlock(n.Father.Value) {
			return n.Father.Value
		}
	}
	return nil
}

func legacyDisposal(o *parser.Object) string {
	return parser.DisposalOf(o).String()
}

func oldAllocSites(root *parser.Node, objs []*parser.Object) (map[*parser.VarBlock]*parser.Object, int, map[*parser.VarBlock]string) {
	m := map[*parser.VarBlock]*parser.Object{}
	label := map[*parser.VarBlock]string{}
	seen := map[*parser.Object]bool{}
	walkStatements(root, func(v *parser.VarBlock, l string) {
		if o := v.Life.Alloc(); o != nil {
			m[v] = o
			label[v] = l
			seen[o] = true
		}
	})
	noSite := 0
	for _, o := range objs {
		if !seen[o] {
			noSite++
		}
	}
	return m, noSite, label
}

func newAllocSites(objs []*gc.Object) (map[*parser.VarBlock]*gc.Object, int, map[*parser.VarBlock]string) {
	m := map[*parser.VarBlock]*gc.Object{}
	label := map[*parser.VarBlock]string{}
	noSite := 0
	for _, o := range objs {
		site := o.AllocSite()
		if site == nil {
			noSite++
			continue
		}
		m[site] = o
		label[site] = siteLabel(site)
	}
	return m, noSite, label
}

func siteLabel(site *parser.VarBlock) string {
	if site == nil {
		return "<nil>"
	}
	return site.Name.String()
}

func siteName(site *parser.VarBlock) string {
	if site == nil {
		return "<nil>"
	}
	return site.Name.String()
}

func walkStatements(root *parser.Node, fn func(v *parser.VarBlock, label string)) {
	var walk func(n *parser.Node, fnName string)
	walk = func(n *parser.Node, fnName string) {
		if n == nil {
			return
		}
		if fb, ok := n.Value.(*parser.FuncBlock); ok {
			fnName = fb.Name.String()
		}
		if v, ok := n.Value.(*parser.VarBlock); ok && v != nil {
			fn(v, fnName+":"+v.Name.String())
		}
		parser.EachSubNode(n, func(c *parser.Node) { walk(c, fnName) })
	}
	walk(root, "<global>")
}

func oldObjectSite(o *parser.Object, oldBySite map[*parser.VarBlock]*parser.Object) *parser.VarBlock {
	for site, x := range oldBySite {
		if x == o {
			return site
		}
	}
	return nil
}

func compareObjects(oo *parser.Object, no *gc.Object, oldBySite map[*parser.VarBlock]*parser.Object, newBySite map[*parser.VarBlock]*gc.Object) []string {
	var d []string
	if oo.Scope != no.Scope {
		d = append(d, fmt.Sprintf("scope old=%s new=%s", oldScopeKind(oo.Scope), scopeKind(no.Scope)))
	}
	if oo.FreeScope != no.FreeScope {
		d = append(d, fmt.Sprintf("free old=%s new=%s", oldScopeKind(oo.FreeScope), scopeKind(no.FreeScope)))
	}
	if oo.Holder != no.Holder {
		d = append(d, fmt.Sprintf("holder old=%s new=%s", siteName(oo.Holder), siteName(no.Holder)))
	}
	if oo.Escapes != no.Escapes {
		d = append(d, fmt.Sprintf("esc old=%v new=%v", oo.Escapes, no.Escapes))
	}
	if oo.Transferred != no.Transferred {
		d = append(d, fmt.Sprintf("xfer old=%v new=%v", oo.Transferred, no.Transferred))
	}
	if oo.Inplace != no.Inplace {
		d = append(d, fmt.Sprintf("inplace old=%v new=%v", oo.Inplace, no.Inplace))
	}
	oldField := oldObjectSite(oo.FieldOwner, oldBySite)
	newField := (*parser.VarBlock)(nil)
	if no.FieldOwner != nil {
		newField = no.FieldOwner.AllocSite()
	}
	if oldField != newField || oo.FieldName != no.FieldName {
		d = append(d, fmt.Sprintf("field old=%s.%s new=%s.%s", siteName(oldField), oo.FieldName, siteName(newField), no.FieldName))
	}
	if !sameNames(oo.Names, no.Names) {
		d = append(d, fmt.Sprintf("names old=%v new=%v", varNames(oo.Names), varNames(no.Names)))
	}
	if !sameFields(oo.FieldVals, no.FieldVals, oldBySite, newBySite) {
		d = append(d, fmt.Sprintf("fieldvals old=%d new=%d", len(oo.FieldVals), len(no.FieldVals)))
	}
	return d
}

func scopeKind(b parser.Block) string {
	switch b.(type) {
	case *parser.FuncBlock:
		return "fn"
	case *parser.ForBlock:
		return "for"
	case *parser.IfBlock:
		return "if"
	case *parser.ElseBlock:
		return "else"
	case *parser.SwitchBlock:
		return "switch"
	case *parser.CaseBlock:
		return "case"
	}
	return "?"
}

func sameNames(a, b []*parser.VarBlock) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}

func sameFields(a []parser.FieldBinding, b []gc.FieldBinding, oldBySite map[*parser.VarBlock]*parser.Object, newBySite map[*parser.VarBlock]*gc.Object) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i].Field != b[i].Field || a[i].Val != b[i].Val || a[i].Stale != b[i].Stale {
			return false
		}
		var oldObjSite, newObjSite *parser.VarBlock
		if a[i].Obj != nil {
			oldObjSite = oldObjectSite(a[i].Obj, oldBySite)
		}
		if b[i].Obj != nil {
			newObjSite = b[i].Obj.AllocSite()
		}
		if oldObjSite != newObjSite {
			return false
		}
	}
	return true
}

func varNames(ns []*parser.VarBlock) []string {
	out := make([]string, 0, len(ns))
	for _, n := range ns {
		if n == nil {
			continue
		}
		out = append(out, n.Name.String())
	}
	return out
}

func commonKeys[V any, W any](a map[*parser.VarBlock]V, b map[*parser.VarBlock]W) int {
	n := 0
	for k := range a {
		if _, ok := b[k]; ok {
			n++
		}
	}
	return n
}

func onlyKeys[V any, W any](a map[*parser.VarBlock]V, b map[*parser.VarBlock]W) int {
	n := 0
	for k := range a {
		if _, ok := b[k]; !ok {
			n++
		}
	}
	return n
}
