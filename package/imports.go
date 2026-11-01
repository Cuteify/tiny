package packageSys

import (
	"fmt"
	"os"
	"path"
	"path/filepath"
	"regexp"
	"strings"

	packageFmt "cuteify/package/fmt"
	"cuteify/parser"
)

// 项目根信息（Wave L）：根包加载时设置。
// projectRoot 用于 <name>:rel（项目顶层相对）与 :third/party（vendor/）解析。
var projectRoot string
var projectName string

// 文件级 import 预扫描正则（仅匹配行首无缩进的顶层 import）。
// 与 parser/import.go 的语法保持一致：别名仅限 \w+（含 _），路径一律双引号，
// `.` 点导入与反引号 RAW 不匹配（由解析器报错）。
var (
	reImportGroup  = regexp.MustCompile(`(?m)^import[ \t]*\(([^)]*)\)`)
	reImportSingle = regexp.MustCompile(`(?m)^import[ \t]*(?:(\w+)[ \t]+)?"([^"\n]*)"`)
	reImportEntry  = regexp.MustCompile(`(?m)^[ \t]*(?:(\w+)[ \t]+)?"([^"]*)"`)
)

// scanImports 用正则预扫描文件级 import。
// 预扫描先于解析执行：别名注册进包导入表后，解析期的别名查找才能命中。
// 真实语法解析在 parser.ImportBlock.Parse（含更好的错误位置）。
func scanImports(content string) []parser.ImportItem {
	var items []parser.ImportItem
	for _, m := range reImportGroup.FindAllStringSubmatch(content, -1) {
		for _, em := range reImportEntry.FindAllStringSubmatch(m[1], -1) {
			items = append(items, parser.ImportItem{Alias: em[1], Path: em[2]})
		}
	}
	for _, m := range reImportSingle.FindAllStringSubmatch(content, -1) {
		items = append(items, parser.ImportItem{Alias: m[1], Path: m[2]})
	}
	return items
}

// resolveImportPath 按冒号位置判别五种形态（零启发式，见 PLAN v2 P10）：
//
//	std:xxx / ext:xxx / api:xxx   官方逻辑源（std=标准库、ext=标准库扩展、
//	                              api=其他语言 API 绑定；一期均映射本地 <root>/pkg/<sub>）
//	<name>:rel                    冒号前 == 根包名 → 项目顶层相对（name/module 合一）
//	:third/party                  冒号在最前（无名字无协议）→ 第三方，vendor/ 优先
//	./rel ../rel /abs             本地路径（本地文件没有冒号）
//	其它（未知名冒号 / 裸短名）     非法报错
func resolveImportPath(item parser.ImportItem, packagePath string) (string, error) {
	p := item.Path
	if p == "" {
		return "", fmt.Errorf("empty import path")
	}
	// 官方逻辑源
	for _, prefix := range []string{"std:", "ext:", "api:"} {
		if strings.HasPrefix(p, prefix) {
			sub := p[len(prefix):]
			if sub == "" {
				return "", fmt.Errorf("import %q: missing package name", p)
			}
			return stdPackageDir(sub)
		}
	}
	// 冒号在最前：第三方
	if strings.HasPrefix(p, ":") {
		if p[1:] == "" {
			return "", fmt.Errorf("import %q: missing package path", p)
		}
		if vendored := vendorPath(p[1:]); vendored != "" {
			return vendored, nil
		}
		return "", fmt.Errorf("third-party package %q is not vendored (vendor/%s); fetching is not supported yet", p, p[1:])
	}
	// 本地路径
	if strings.HasPrefix(p, "/") {
		return path.Clean(p), nil
	}
	if strings.HasPrefix(p, "./") || strings.HasPrefix(p, "../") {
		return path.Clean(path.Join(packagePath, p)), nil
	}
	// 名字 + 冒号：冒号前必须等于根包名 → 项目顶层相对
	if i := strings.Index(p, ":"); i > 0 {
		name := p[:i]
		rel := p[i+1:]
		if projectName != "" && name == projectName && rel != "" {
			return path.Clean(path.Join(projectRoot, rel)), nil
		}
		return "", fmt.Errorf("import %q: unknown source prefix %q (official: std:/ext:/api:)", p, name)
	}
	// 裸短名：非法（裸名只允许出现在 package.json 的相对路径语义中）
	return "", fmt.Errorf("import %q: bare short name is not allowed (use std:/ext:/api:, ./rel, /abs, name:rel or :vendor)", p)
}

// stdPackageDir 解析官方逻辑源的本地目录。
// CUTE_ROOT 显式设置即权威（不回退）；否则依次尝试编译器可执行目录及其上级、
// Getwd 兜底，候选须 <root>/pkg/<sub> 存在。
func stdPackageDir(sub string) (string, error) {
	if env := os.Getenv("CUTE_ROOT"); env != "" {
		dir := filepath.Join(env, "pkg", sub)
		if !dirExists(dir) {
			return "", fmt.Errorf("std package %q not found under CUTE_ROOT=%s", sub, env)
		}
		return dir, nil
	}
	for _, root := range stdRootCandidates() {
		dir := filepath.Join(root, "pkg", sub)
		if dirExists(dir) {
			return dir, nil
		}
	}
	return "", fmt.Errorf("std package %q not found (set CUTE_ROOT to the std root)", sub)
}

// stdRootCandidates 兜底候选根：编译器可执行目录及其上级，然后 Getwd。
func stdRootCandidates() []string {
	var roots []string
	if exe, err := os.Executable(); err == nil {
		dir := filepath.Dir(exe)
		for i := 0; i < 8; i++ {
			roots = append(roots, dir)
			parent := filepath.Dir(dir)
			if parent == dir {
				break
			}
			dir = parent
		}
	}
	if wd, err := os.Getwd(); err == nil {
		roots = append(roots, wd)
	}
	return roots
}

// vendorPath 在 vendor 候选根中查找第三方包目录（一期仅项目根 vendor/，二期拉取）。
func vendorPath(rel string) string {
	if projectRoot == "" {
		return ""
	}
	cand := path.Join(projectRoot, "vendor", rel)
	if dirExists(cand) {
		return cand
	}
	return ""
}

func dirExists(p string) bool {
	info, err := os.Stat(p)
	return err == nil && info.IsDir()
}

// registerFileImports 扫描单个文件的文件级 import，解析路径并注册别名。
// 别名写入包导入表（info.Imports，与 package.json imports 同一通道），
// 解析期 FixPath / fixPkgNamePaths / lookupGlobalType 的既有机器零改动可用。
// 被导入的包在此处加载（物理路径去重），与 json imports 行为一致。
// 注意：包自导入（如 pkg/memory 里 import "std:memory"）与 a↔b 循环
// 会无限递归——与 json 现状 bug-for-bug 保持，暂不设环防护。
func registerFileImports(info *packageFmt.Info, filePath string) error {
	content, err := os.ReadFile(filePath)
	if err != nil {
		return err
	}
	for _, item := range scanImports(string(content)) {
		alias := item.Alias
		if alias == "" {
			alias = packageFmt.DefaultImportAlias(item.Path)
		}
		resolved, err := resolveImportPath(item, info.Path)
		if err != nil {
			return fmt.Errorf("%s: %w", filePath, err)
		}
		// 同名别名：同物理路径去重，异物理路径报错
		if prev, ok := info.Imports[alias]; ok {
			if prev == resolved {
				continue
			}
			return fmt.Errorf("%s: import alias %q already maps to %q", filePath, alias, prev)
		}
		if alias != "_" {
			// "_" 空导入：只为副作用加载包，不绑定名称
			if info.Imports == nil {
				info.Imports = map[string]string{}
			}
			info.Imports[alias] = resolved
		}
		if _, ok := packages[resolved]; !ok {
			sub, err := GetPackage(resolved, false)
			if err != nil {
				return fmt.Errorf("%s: import %q: %w", filePath, item.Path, err)
			}
			packages[resolved] = sub
		}
	}
	return nil
}
