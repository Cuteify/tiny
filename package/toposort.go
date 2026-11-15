package packageSys

import (
	"cuteify/lexer"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
)

// 跨文件前向引用：cute 文件的解析顺序决定了名称是否可见。
// 依赖关系藏在源码的顶层声明里（类型声明被其它文件引用），
// 因此先对每个 .cute 文件做一次纯词法扫描，得到：
//   - 该文件声明的类型名集合（type/struct/interface/enum，含 type (...) 分组）
//   - 该文件出现的全部 NAME token（用于判断它引用了哪些类型）
// 然后按“声明类型的文件先于引用它的文件”做拓扑排序（Kahn 算法），
// 同一层保持字母序。这样解析期 FindTypeType 总能命中，
// 无需等待合并后的全局 Check 重试。
type fileScan struct {
	types map[string]bool
	names map[string]bool
}

func scanCuteFile(full string) (res *fileScan, err error) {
	// 扫描必须不杀死进程：词法错误（未闭合字符串/块注释）按普通源码
	// 也会在正式解析时 panic，这里 recover 后回退到字母序即可。
	defer func() {
		if r := recover(); r != nil {
			res = nil
			err = fmt.Errorf("scan %s: %v", full, r)
		}
	}()
	l := lexer.NewLexer(full)
	res = &fileScan{types: map[string]bool{}, names: map[string]bool{}}

	pendingType := false                 // 刚看到 type/struct/interface/enum，下一个 NAME 是类型名
	inTypeGroup, groupDepth := false, 0  // 位于 type ( ... ) 分组内
	for {
		code, tokErr := l.GetToken()
		if tokErr == io.EOF || (code.Type == 0 && code.Value == "") {
			break
		}
		if code.Type == lexer.NAME {
			res.names[code.Value] = true
		}
		switch {
		case code.Type == lexer.SEPARATOR && code.Value == "(":
			if pendingType {
				inTypeGroup, groupDepth = true, 1
				pendingType = false
			} else if inTypeGroup {
				groupDepth++
			}
		case code.Type == lexer.SEPARATOR && code.Value == ")":
			if inTypeGroup {
				groupDepth--
				if groupDepth == 0 {
					inTypeGroup = false
				}
			}
		case code.Type == lexer.TYPE:
			switch code.Value {
			case "type", "struct", "interface", "enum":
				pendingType = true
			}
		case code.Type == lexer.NAME:
			switch {
			case pendingType:
				res.types[code.Value] = true
				pendingType = false
			case inTypeGroup && groupDepth == 1:
				// 分组条目：Pt struct { ... } / M int / M = int 都以 NAME 开头
				res.types[code.Value] = true
			}
		default:
			// 其它 token 不影响分组判定（type 分组只有括号配对）
		}
	}
	return res, nil
}

// topoOrderCuteFiles 把 .cute 文件按类型声明依赖关系拓扑排序：
// 声明某个类型的文件排在引用该类型的文件之前；同一层保持字母序（稳定）。
// 依赖存在环（跨文件循环类型引用）时，剩余文件按原字母序追加（回退为现状行为）。
func topoOrderCuteFiles(packagePath string, files []fs.DirEntry) []fs.DirEntry {
	isCute := func(e fs.DirEntry) bool {
		return !e.IsDir() && filepath.Ext(e.Name()) == ".cute"
	}
	// 扫描全部 .cute 文件；扫描失败的文件不声明类型（只参与字母序）。
	scans := make([]*fileScan, len(files))
	for i, e := range files {
		if !isCute(e) {
			continue
		}
		rs, err := scanCuteFile(filepath.Join(packagePath, e.Name()))
		if err != nil {
			fmt.Fprintf(os.Stderr, "cuteify: warning: %s\n", err)
			continue
		}
		scans[i] = rs
	}
	// 依赖边：文件 i 引用了文件 j 声明的类型，i 必须排在 j 之后。
	incoming := make([]int, len(files))
	deps := make([][]int, len(files))
	for i := range files {
		if scans[i] == nil {
			continue
		}
		for j := range files {
			if i == j || scans[j] == nil {
				continue
			}
			for t := range scans[j].types {
				if scans[i].names[t] {
					deps[i] = append(deps[i], j)
					incoming[i]++
					break
				}
			}
		}
	}
	// Kahn：零依赖文件先解析；同层按字母序（files 原本字母序）。
	emitted := make([]bool, len(files))
	queue := []int{}
	for i := range files {
		if incoming[i] == 0 {
			queue = append(queue, i)
		}
	}
	out := make([]fs.DirEntry, 0, len(files))
	for len(queue) > 0 {
		i := queue[0]
		queue = queue[1:]
		if emitted[i] {
			continue
		}
		emitted[i] = true
		out = append(out, files[i])
		for j := range files {
			if emitted[j] || incoming[j] == 0 {
				continue
			}
			for _, d := range deps[j] {
				if d == i {
					incoming[j]--
					break
				}
			}
			if incoming[j] == 0 {
				queue = append(queue, j)
			}
		}
	}
	// 环：按原顺序追加剩余文件（回退到字母序行为）。
	for i, e := range files {
		if !emitted[i] {
			out = append(out, e)
		}
	}
	return out
}
