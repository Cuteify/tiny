package gc

import (
	"encoding/json"
	"fmt"
	"io"
	"sort"
)

// Mode 描述被调函数对拥有指针参数的使用模式
type Mode uint8

const (
	ModeRead        Mode = iota // 仅读取指向的数据，不修改不传播
	ModeWrite                   // 修改数据内容，不转移所有权
	ModeDeepCopy                // 复制内容到新分配内存，原数据不受影响
	ModeShallowCopy             // 仅复制指针值，产生别名
	ModeOtherRef                // 指针逃逸：存储到他处/返回/传给其他函数
)

// Escape 描述拥有指针的逃逸层级
type Escape uint8

const (
	EscNone    Escape = iota // 不逃逸：仅当前函数作用域内使用
	EscCaller                // 通过返回值或输出参数逃逸到上层
	EscHeapObj               // 存储到另一个堆对象的字段
	EscGlobal                // 存储到全局变量
	EscAny                   // 未知（无摘要的外部调用等）
)

// modeNames 模式的可读名称表
var modeNames = map[Mode]string{
	ModeRead:        "Read",
	ModeWrite:       "Write",
	ModeDeepCopy:    "DeepCopy",
	ModeShallowCopy: "ShallowCopy",
	ModeOtherRef:    "OtherRef",
}

// String 返回模式的可读名称，未知值返回 "Unknown"
func (m Mode) String() string {
	if n, ok := modeNames[m]; ok {
		return n
	}
	return "Unknown"
}

// escNames 逃逸层级的可读名称表
var escNames = map[Escape]string{
	EscNone:    "None",
	EscCaller:  "Caller",
	EscHeapObj: "HeapObj",
	EscGlobal:  "Global",
	EscAny:     "Any",
}

// String 返回逃逸层级的可读名称，未知值返回 "Any"
func (e Escape) String() string {
	if n, ok := escNames[e]; ok {
		return n
	}
	return "Any"
}

// modeRank 模式强度序查表（越大越强）：OtherRef > ShallowCopy > DeepCopy > Write > Read；未知值视为最弱占位
var modeRank = [8]int{
	int(ModeRead):        1,
	int(ModeWrite):       2,
	int(ModeDeepCopy):    3,
	int(ModeShallowCopy): 4,
	int(ModeOtherRef):    5,
}

// Merge 合并两个模式，取更强者；保证幂等：m.Merge(m) == m
func (m Mode) Merge(o Mode) Mode {
	if modeRank[o] > modeRank[m] {
		return o
	}
	return m
}

// escRank 逃逸强度序查表（越大越强）：Any > Global > HeapObj > Caller > None
var escRank = [8]int{
	int(EscNone):    1,
	int(EscCaller):  2,
	int(EscHeapObj): 3,
	int(EscGlobal):  4,
	int(EscAny):     5,
}

// Merge 合并两个逃逸层级，取更强者；保证幂等：e.Merge(e) == e
func (e Escape) Merge(o Escape) Escape {
	if escRank[o] > escRank[e] {
		return o
	}
	return e
}

// ParamSummary 单个拥有指针参数的摘要
type ParamSummary struct {
	Index  int    `json:"index"`  // 参数序号（0 起）
	Mode   Mode   `json:"mode"`   // 使用模式（多模式取最强：OtherRef > ShallowCopy > DeepCopy > Write > Read）
	Escape Escape `json:"escape"` // 最高逃逸层级
}

// FnSummary 单个函数的摘要
type FnSummary struct {
	Name      string         `json:"name"`      // 全路径名（跨包 SetPkgPath 后的形态）
	Params    []ParamSummary `json:"params"`    // 仅含有指针参数
	RetOwned  bool           `json:"retOwned"`  // 返回值是否携带新分配的拥有指针
	RetEscape Escape         `json:"retEscape"` // 返回值的最高逃逸层级（RetOwned 时有意义）
	CallsAny  []string       `json:"callsAny"` // 调用过的无摘要函数名（导致参数退化为 any）

	// HasGlobalOwnStore 函数体内存在“全局 = 拥有值”赋值（含调用结果直接存全局）。
	// 此类函数禁用自动释放优化（保守门槛，防止 use-after-free）。
	HasGlobalOwnStore bool `json:"hasGlobalOwnStore,omitempty"`

	Sorted bool `json:"-"` // Params 是否已按 Index 排序
}

// Table 全程序摘要表（键 = 函数全路径名）
var Table = map[string]*FnSummary{}

// LLRResults 全程序 LLR 分析结果
var LLRResults = map[string]*LLRResult{}

// DumpLLRs 输出全部 LLR 结果
func DumpLLRs() string {
	keys := make([]string, 0, len(LLRResults))
	for k := range LLRResults {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	out := ""
	for _, k := range keys {
		out += DumpLLR(LLRResults[k])
	}
	return out
}

// EnsureParam 确保 Params 包含序号为 idx 的条目且整体按 Index 升序排列，返回该条目的指针；
// 缺失时插入零值并保持有序（每次直接重新排序，不依赖 Sorted 标志）
func (f *FnSummary) EnsureParam(idx int) *ParamSummary {
	for i := range f.Params {
		if f.Params[i].Index == idx {
			f.Sorted = true
			return &f.Params[i]
		}
	}
	f.Params = append(f.Params, ParamSummary{Index: idx})
	sort.Slice(f.Params, func(i, j int) bool {
		return f.Params[i].Index < f.Params[j].Index
	})
	f.Sorted = true
	for i := range f.Params {
		if f.Params[i].Index == idx {
			return &f.Params[i]
		}
	}
	return nil // 不可达：刚插入的元素必然存在
}

// JSON 返回两格缩进的 JSON 序列化结果；序列化失败时返回空串
func (f *FnSummary) JSON() string {
	b, err := json.MarshalIndent(f, "", "  ")
	if err != nil {
		return ""
	}
	return string(b)
}

// DumpAll 把 Table 中所有函数摘要按 Name 排序后逐个写入 w：
// 每个函数一段，先输出前缀行 "== " + Name，随后是该函数的 JSON 文本
func DumpAll(w io.Writer) error {
	names := make([]string, 0, len(Table))
	for name := range Table {
		names = append(names, name)
	}
	sort.Strings(names)
	for _, name := range names {
		if _, err := fmt.Fprintf(w, "== %s\n%s\n", name, Table[name].JSON()); err != nil {
			return err
		}
	}
	return nil
}
