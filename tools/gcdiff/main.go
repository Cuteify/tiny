// gcdiff — Phase 1 只读对拍工具：前端 gc 计划 vs 后端 compile/gc LLR。
//
// 它只分析、不编译、不改代码生成。输出三份文件到 -o 目录：
//
//	gcfe_plan.json  前端对象级计划（FreeScope / Holder / ReleasesOld）
//	gc_llr.json     后端 gc.LLRResults 的原样导出
//	gc_diff.txt     逐函数并排对比 + 差异归类
//
// 用法：
//
//	go run ./tools/gcdiff -o /tmp/gcdiff/test-gcBlocks ./test/gcBlocks
//
// 注意：两套分析的对象编号互不相通，不能按 ID 对齐；对拍口径是“函数 +
// 释放类别”。对象级明细看 gcfe_plan.json。
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"cuteify/gc"
	packageSys "cuteify/package"
	"cuteify/parser"
)

type feFn struct {
	Objects  int
	Scope    int
	RC       int
	Transfer int
	Borrow   int
	Leak     int
	Inplace  int
	Field    int
	ByKind   map[string]int
}

func (f *feFn) releases() int { return f.Scope + f.Inplace + f.Field }

type beFn struct {
	Objects  int
	FrameOwn int
	Exit     int
	Block    int
	Loop     int
	Assign   int
	Field    int
	Ret      int
	Cond     int
	Incr     int
}

func (f *beFn) releases() int {
	return f.Exit + f.Block + f.Assign + f.Field + f.Ret + f.Cond + f.Incr
}

func main() {
	out := flag.String("o", "", "输出目录（缺省用系统临时目录新建）")
	flag.Parse()
	if flag.NArg() == 0 {
		fmt.Fprintln(os.Stderr, "用法: gcdiff [-o outdir] <包目录>")
		os.Exit(2)
	}
	dir := flag.Arg(0)

	pkg, err := packageSys.GetPackage(dir, true)
	if err != nil {
		fmt.Fprintf(os.Stderr, "解析失败: %v\n", err)
		os.Exit(1)
	}
	root, ok := pkg.AST.(*parser.Node)
	if !ok || root == nil {
		fmt.Fprintln(os.Stderr, "AST 根节点不可用")
		os.Exit(1)
	}

	gc.Analyze(root)
	plan := gc.BuildPlan(root)

	outDir := *out
	if outDir == "" {
		outDir, err = os.MkdirTemp("", "gcdiff-")
		if err != nil {
			fmt.Fprintf(os.Stderr, "创建输出目录失败: %v\n", err)
			os.Exit(1)
		}
	}
	if err := os.MkdirAll(outDir, 0o755); err != nil {
		fmt.Fprintf(os.Stderr, "创建输出目录失败: %v\n", err)
		os.Exit(1)
	}

	fePath := filepath.Join(outDir, "gcfe_plan.json")
	bePath := filepath.Join(outDir, "gc_llr.json")
	diffPath := filepath.Join(outDir, "gc_diff.txt")

	if err := writeJSON(fePath, plan); err != nil {
		fmt.Fprintf(os.Stderr, "写前端计划失败: %v\n", err)
		os.Exit(1)
	}
	if err := writeJSON(bePath, gc.LLRResults); err != nil {
		fmt.Fprintf(os.Stderr, "写后端计划失败: %v\n", err)
		os.Exit(1)
	}

	report, counts := buildReport(dir, plan, gc.LLRResults)
	if err := os.WriteFile(diffPath, []byte(report), 0o644); err != nil {
		fmt.Fprintf(os.Stderr, "写差异报告失败: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("目录: %s\n", dir)
	fmt.Printf("前端: 对象=%d 作用域=%d RC=%d 转移=%d 就地=%d 就地对象=%d 字段=%d 真泄漏=%d HolderBad=%d\n",
		plan.Summary.Objects, plan.Summary.Scope, plan.Summary.RC,
		plan.Summary.Transfer, plan.Summary.Inplace, plan.Summary.InplaceObj,
		plan.Summary.Field, plan.Summary.Leak, plan.Summary.HolderBad)
	fmt.Printf("差异: 前端独有=%d  后端独有=%d  两边都有=%d\n",
		counts["fe-only"], counts["be-only"], counts["both"])
	fmt.Printf("输出: %s\n      %s\n      %s\n", fePath, bePath, diffPath)
	if counts["be-only"] > 0 {
		fmt.Println("警告: 存在“后端有释放、前端无计划”的函数，直接切换会退化为漏释放（详见报告）。")
	}
	if plan.Summary.Leak > 0 {
		fmt.Println("警告: 前端存在五态都不沾的对象（真泄漏）。")
	}
	if plan.Summary.HolderBad > 0 {
		fmt.Println("警告: 存在 Holder 无效的释放计划（槽已改绑或活不到释放点）。")
	}
}

func writeJSON(path string, v any) error {
	data, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		return err
	}
	data = append(data, '\n')
	return os.WriteFile(path, data, 0o644)
}

// buildReport 逐函数并排，并按“谁有释放能力”归类。
func buildReport(dir string, plan gc.Plan, be map[string]*gc.LLRResult) (string, map[string]int) {
	fe := map[string]*feFn{}
	for _, o := range plan.Objects {
		f := fe[o.Function]
		if f == nil {
			f = &feFn{ByKind: map[string]int{}}
			fe[o.Function] = f
		}
		f.Objects++
		switch o.Disposal {
		case "scope":
			f.Scope++
			if i := strings.IndexByte(o.FreeScope, '#'); i > 0 {
				f.ByKind[o.FreeScope[:i]]++
			}
		case "rc":
			f.RC++
		case "inplace":
			// 对象级就地释放；语句级已由 plan.Inplace 计入 f.Inplace。
		case "field":
			f.Field++
		case "transfer":
			f.Transfer++
		default:
			f.Borrow++
		}
	}
	for _, ip := range plan.Inplace {
		f := fe[ip.Function]
		if f == nil {
			f = &feFn{ByKind: map[string]int{}}
			fe[ip.Function] = f
		}
		f.Inplace++
	}
	// 真泄漏按对象算，这里回填到函数。
	for _, o := range plan.Objects {
		if o.Disposal == "borrow" && o.FreeScope == "" && !o.Escapes && !o.Transferred {
			if f := fe[o.Function]; f != nil {
				f.Leak++
			}
		}
	}

	bad := map[string]*beFn{}
	for name, r := range be {
		if r == nil {
			continue
		}
		b := &beFn{Objects: len(r.Objects), Exit: len(r.Frees), Field: len(r.FieldFrees), Ret: len(r.RetFrees)}
		for _, o := range r.Objects {
			if o.FrameOwn {
				b.FrameOwn++
			}
		}
		for _, fs := range r.BlockFreesMap {
			b.Block += len(fs)
		}
		for _, fs := range r.LoopExitFrees {
			b.Loop += len(fs)
		}
		for _, fs := range r.AssignFrees {
			b.Assign += len(fs)
		}
		for _, fs := range r.CondFreesMap {
			b.Cond += len(fs)
		}
		for _, fs := range r.IncrFreesMap {
			b.Incr += len(fs)
		}
		bad[name] = b
	}

	names := map[string]bool{}
	for n := range fe {
		names[n] = true
	}
	for n, b := range bad {
		if b.releases() > 0 || b.FrameOwn > 0 {
			names[n] = true
		}
	}
	list := make([]string, 0, len(names))
	for n := range names {
		list = append(list, n)
	}
	sort.Strings(list)

	counts := map[string]int{}
	var rows, feOnly, beOnly, both []string
	for _, name := range list {
		f := fe[name]
		if f == nil {
			f = &feFn{ByKind: map[string]int{}}
		}
		b := bad[name]
		if b == nil {
			b = &beFn{}
		}
		class := "—"
		switch {
		case f.releases() > 0 && b.releases() == 0:
			class = "前端独有"
			feOnly = append(feOnly, name)
		case f.releases() == 0 && b.releases() > 0:
			class = "后端独有"
			beOnly = append(beOnly, name)
		case f.releases() > 0 && b.releases() > 0:
			class = "两边都有"
			both = append(both, name)
		}
		counts[classToKey(class)]++
		if class == "—" && f.Objects == 0 && b.releases() == 0 && b.FrameOwn == 0 {
			continue
		}
		rows = append(rows, fmt.Sprintf("%-40s %6d %6d %6d %6d %6d %6d %6d %6d %6d %6d  %s",
			name, f.Objects, f.Scope, f.Inplace, f.Field, b.Objects, b.Exit, b.Block, b.Assign, b.Field,
			b.Ret+b.Cond+b.Incr, class))
	}

	beObjs, beFrame, beExit, beBlock, beLoop, beAssign, beField, beRet, beCond, beIncr := 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	beFns := 0
	for _, b := range bad {
		if b.releases() > 0 || b.FrameOwn > 0 {
			beFns++
		}
		beObjs += b.Objects
		beFrame += b.FrameOwn
		beExit += b.Exit
		beBlock += b.Block
		beLoop += b.Loop
		beAssign += b.Assign
		beField += b.Field
		beRet += b.Ret
		beCond += b.Cond
		beIncr += b.Incr
	}

	var sb strings.Builder
	fmt.Fprintf(&sb, "# GC 计划对拍\n\n目录: %s\n\n", dir)
	fmt.Fprintf(&sb, "## 汇总\n\n")
	fmt.Fprintf(&sb, "前端 gc: 对象=%d 作用域=%d RC=%d 转移=%d 就地对象=%d 语句=%d 字段=%d Borrow=%d 真泄漏=%d HolderBad=%d\n",
		plan.Summary.Objects, plan.Summary.Scope, plan.Summary.RC,
		plan.Summary.Transfer, plan.Summary.InplaceObj, plan.Summary.Inplace,
		plan.Summary.Field, plan.Summary.Borrow, plan.Summary.Leak, plan.Summary.HolderBad)
	kinds := make([]string, 0, len(plan.Summary.ByScopeKind))
	for k := range plan.Summary.ByScopeKind {
		kinds = append(kinds, k)
	}
	sort.Strings(kinds)
	var kp []string
	for _, k := range kinds {
		kp = append(kp, fmt.Sprintf("%s=%d", k, plan.Summary.ByScopeKind[k]))
	}
	fmt.Fprintf(&sb, "  作用域分布: %s\n", strings.Join(kp, " "))
	fmt.Fprintf(&sb, "后端 compile/gc: 函数=%d 有释函数=%d 对象=%d frameOwn=%d 出口=%d 块尾=%d 循环=%d 覆盖=%d 字段=%d 临时=%d (ret=%d cond=%d incr=%d)\n\n",
		len(be), beFns, beObjs, beFrame, beExit, beBlock, beLoop, beAssign, beField,
		beRet+beCond+beIncr, beRet, beCond, beIncr)
	fmt.Fprintf(&sb, "口径: FE 对象编号与 BE 对象编号互不相通，只能按函数 + 释放类别比较；\n")
	fmt.Fprintf(&sb, "      “循环”是“块尾”在 for 节点上的副本，不计入释放总数。\n\n")

	fmt.Fprintf(&sb, "## 逐函数并排\n\n")
	fmt.Fprintf(&sb, "%-40s %6s %6s %6s %6s %6s %6s %6s %6s %6s %6s  %s\n",
		"函数", "FE对象", "FE作用", "FE就地", "FE字段", "BE对象", "BE出口", "BE块尾", "BE覆盖", "BE字段", "BE临时", "判定")
	for _, row := range rows {
		sb.WriteString(row)
		sb.WriteByte('\n')
	}

	writeClass := func(title, note string, names []string) {
		fmt.Fprintf(&sb, "\n## %s（%d）\n\n", title, len(names))
		if note != "" {
			fmt.Fprintf(&sb, "%s\n\n", note)
		}
		for _, n := range names {
			f := fe[n]
			b := bad[n]
			if f == nil {
				f = &feFn{ByKind: map[string]int{}}
			}
			if b == nil {
				b = &beFn{}
			}
			fmt.Fprintf(&sb, "  %-40s FE: 作用域=%d 就地=%d 字段=%d RC=%d 转移=%d 泄漏=%d | BE: 出口=%d 块尾=%d 覆盖=%d 字段=%d 临时=%d\n",
				n, f.Scope, f.Inplace, f.Field, f.RC, f.Transfer, f.Leak,
				b.Exit, b.Block, b.Assign, b.Field, b.Ret+b.Cond+b.Incr)
		}
	}
	writeClass("前端独有释放（切换会新增释放）", "FE 有作用域/就地释放，BE 当前没有任何释放计划。", feOnly)
	writeClass("后端独有释放（切换会退化为漏释放）", "BE 有释放计划，FE 当前没有对象或没有释放。Phase 2 必须先补齐。", beOnly)
	writeClass("两边都有释放", "只表示两侧都具备释放能力，不表示释放的是同一批对象。", both)

	fmt.Fprintf(&sb, "\n## 前端对象计划\n\n")
	for _, o := range plan.Objects {
		fmt.Fprintf(&sb, "  #%-3d %-32s %-8s owner=%-20s scope=%-12s free=%-12s holder=%s",
			o.ID, o.Function, o.Disposal, o.Owner, o.Scope, o.FreeScope, o.Holder)
		if o.FieldOwner != 0 {
			fmt.Fprintf(&sb, " field=%s@#%d", o.FieldName, o.FieldOwner)
		}
		if len(o.Names) > 0 {
			fmt.Fprintf(&sb, " names=%s", strings.Join(o.Names, ","))
		}
		if len(o.Fields) > 0 {
			var fp []string
			for _, f := range o.Fields {
				fp = append(fp, fmt.Sprintf("%s→#%d(%s)", f.Field, f.ObjectID, f.Value))
			}
			fmt.Fprintf(&sb, " fields=%s", strings.Join(fp, ","))
		}
		sb.WriteByte('\n')
	}
	if len(plan.Inplace) > 0 {
		fmt.Fprintf(&sb, "\n## 就地释放语句\n\n")
		for _, ip := range plan.Inplace {
			fmt.Fprintf(&sb, "  %-40s %s → 旧对象 #%d\n", ip.Function, ip.Variable, ip.OldObject)
		}
	}
	return sb.String(), counts
}

func classToKey(class string) string {
	switch class {
	case "前端独有":
		return "fe-only"
	case "后端独有":
		return "be-only"
	case "两边都有":
		return "both"
	}
	return "none"
}
