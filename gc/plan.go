// gc/plan.go — 前端 GC 计划的只读快照。
//
// 用途是 Phase 1 对拍：把“每个对象在哪释放、读哪个槽、哪条赋值就地释放”
// 落成稳定 JSON，与 compile 的后端 LLRResults 并排比较。它不参与代码生成，
// 也不改变 Analyze 的任何判定。
//
// 调用前提：Analyze / CollectFront 已跑完。BuildPlan 只读 front 与 AST，
// 不重跑分析。对象编号只在本次分析内稳定；后端 LLR 的对象编号是另一套，
// 两者不能按 ID 对齐，只能按函数 + 释放类别比较。

package gc

import (
	"fmt"
	"sort"

	"cuteify/parser"
)

// Plan 一次前端 GC 分析的计划快照。
type Plan struct {
	Summary PlanSummary   `json:"summary"`
	Objects []ObjectPlan  `json:"objects"`
	Inplace []InplacePlan `json:"inplace"`
}

// PlanSummary 聚合数字，与 Stats 的口径一致。
type PlanSummary struct {
	Objects     int            `json:"objects"`
	Scope       int            `json:"scope"`      // FreeScope != nil
	RC          int            `json:"rc"`         // Escapes（退回引用计数）
	Transfer    int            `json:"transfer"`   // Transferred（所有权交给调用方）
	Field       int            `json:"field"`      // 只被容器字段持有，随容器释放
	Borrow      int            `json:"borrow"`     // 参数 / 字段读 / 无绑定名
	Leak        int            `json:"leak"`       // 五态都不沾（真泄漏）
	Inplace     int            `json:"inplace"`    // ReleasesOld 语句数
	InplaceObj  int            `json:"inplaceObj"` // 已就地释放的对象数
	HolderBad   int            `json:"holderBad"`  // 释放点读的槽已不持有该对象 / 活不到释放点
	ByScopeKind map[string]int `json:"byScopeKind"`
}

// ObjectPlan 单个堆对象的释放计划。
type ObjectPlan struct {
	ID          int         `json:"id"`
	Function    string      `json:"function"`
	Owner       string      `json:"owner"`                // 初始持有者（创建处栈槽）
	OwnerType   string      `json:"ownerType"`            // 创建处栈槽类型 Kind
	Scope       string      `json:"scope"`                // 创建作用域（kind#id）
	Disposal    string      `json:"disposal"`             // scope / rc / inplace / field / transfer / borrow
	FreeScope   string      `json:"freeScope"`            // 释放作用域（kind#id）；空 = 无
	Holder      string      `json:"holder"`               // 释放时读哪个栈槽
	FieldOwner  int         `json:"fieldOwner,omitempty"` // 通过哪个容器对象的字段持有（ID）
	FieldName   string      `json:"fieldName,omitempty"`  // 容器字段名
	Escapes     bool        `json:"escapes"`
	Transferred bool        `json:"transferred"`
	Names       []string    `json:"names"`
	Fields      []FieldPlan `json:"fields,omitempty"`
}

// FieldPlan 容器字段与子对象的绑定关系。record 是 FieldVals 的最终快照；
// 对象是否随字段释放由 Object.FieldOwner 决定（最小安全版字段 cascade）。
type FieldPlan struct {
	Field    string `json:"field"`
	Value    string `json:"value"`
	ObjectID int    `json:"objectId"`
	Stale    bool   `json:"stale,omitempty"` // 值变量已改绑；释放读容器字段，不读 Value 槽
}

// InplacePlan 一条覆盖赋值上的就地释放判定。
type InplacePlan struct {
	Function  string `json:"function"`
	Variable  string `json:"variable"`
	OldObject int    `json:"oldObject"` // 被顶掉的旧对象 ID
}

// blockIndex 作用域块的稳定编号、归属函数，以及同一次遍历收集的就地释放。
// 只在本 Plan 内有效。
type blockIndex struct {
	info    map[parser.Block]blockInfo
	inplace []InplacePlan
}

type blockInfo struct {
	id   int
	kind string
	fn   string
}

// BuildPlan 生成只读计划快照。必须在 Analyze / CollectFront 之后调用。
// 对象的处置按 DisposalOf 的五态判定归类：Inplace / Field / Transfer / RC / Scope。
func BuildPlan(root *parser.Node) Plan {
	if front == nil {
		return Plan{Summary: PlanSummary{ByScopeKind: map[string]int{}}}
	}
	idx := indexBlocks(root)
	p := Plan{
		Summary: PlanSummary{ByScopeKind: map[string]int{}},
		Inplace: idx.inplace,
	}
	for _, o := range front.objects {
		p.Objects = append(p.Objects, ObjectPlan{
			ID:          o.ID,
			Function:    objectFunction(o, idx),
			Owner:       varName(o.Owner),
			OwnerType:   varKind(o.Owner),
			Scope:       idx.describe(o.Scope),
			Disposal:    disposalName(DisposalOf(o)),
			FreeScope:   idx.describe(o.FreeScope),
			Holder:      varName(o.Holder),
			FieldOwner:  objectID(o.FieldOwner),
			FieldName:   o.FieldName,
			Escapes:     o.Escapes,
			Transferred: o.Transferred,
			Names:       objectNames(o),
			Fields:      objectFields(o),
		})
		p.Summary.countObject(front, o)
	}
	p.Summary.Inplace = len(p.Inplace)
	return p
}

// describe 作用域的可读身份；nil 或不在树里返回空串。
func (bi blockIndex) describe(b parser.Block) string {
	if b == nil {
		return ""
	}
	if info, ok := bi.info[b]; ok {
		return fmt.Sprintf("%s#%d", info.kind, info.id)
	}
	return scopeKindOf(b) + "#?"
}

// indexBlocks 前序遍历 AST：给每个作用域块编号，并顺带收集就地释放语句。
// 编号只用于诊断输出；不用源码位置，因为 Block 不携带游标。
func indexBlocks(root *parser.Node) blockIndex {
	bi := blockIndex{info: map[parser.Block]blockInfo{}}
	var walk func(n *parser.Node, fn string)
	walk = func(n *parser.Node, fn string) {
		if n == nil {
			return
		}
		if fb, ok := n.Value.(*parser.FuncBlock); ok {
			fn = fb.Name.String()
		}
		if v, ok := n.Value.(*parser.VarBlock); ok {
			if b, ok := front.vars[v]; ok && b.releasesOld {
				ip := InplacePlan{Function: fn, Variable: varName(v)}
				if b.oldObj != nil {
					ip.OldObject = b.oldObj.ID
				}
				bi.inplace = append(bi.inplace, ip)
			}
		}
		if parser.IsScopeBlock(n.Value) {
			if _, dup := bi.info[n.Value]; !dup {
				bi.info[n.Value] = blockInfo{
					id:   len(bi.info) + 1,
					kind: scopeKindOf(n.Value),
					fn:   fn,
				}
			}
		}
		parser.EachSubNode(n, func(c *parser.Node) { walk(c, fn) })
	}
	walk(root, "")
	return bi
}

// objectFunction 对象所属函数：优先看释放点，其次创建作用域。
// 字段释放的对象没有自己的 FreeScope，跟容器走。
func objectFunction(o *Object, idx blockIndex) string {
	if o.FieldOwner != nil {
		return objectFunction(o.FieldOwner, idx)
	}
	if info, ok := idx.info[o.FreeScope]; ok {
		return info.fn
	}
	if info, ok := idx.info[o.Scope]; ok {
		return info.fn
	}
	if fb := funcOfBlock(o.Scope); fb != nil {
		return fb.Name.String()
	}
	return "<global>"
}

func disposalName(d Disposal) string {
	switch d {
	case DisposalScope:
		return "scope"
	case DisposalRC:
		return "rc"
	case DisposalInplace:
		return "inplace"
	case DisposalField:
		return "field"
	default:
		return "borrow"
	}
}

func objectID(o *Object) int {
	if o == nil {
		return 0
	}
	return o.ID
}

func varName(v *parser.VarBlock) string {
	if v == nil || v.Name == nil {
		return ""
	}
	return v.Name.String()
}

func varKind(v *parser.VarBlock) string {
	if v == nil || v.Type == nil {
		return ""
	}
	return v.Type.Kind()
}

func objectNames(o *Object) []string {
	out := make([]string, 0, len(o.Names))
	for _, n := range o.Names {
		if n != nil && n.Name != nil {
			out = append(out, n.Name.String())
		}
	}
	sort.Strings(out)
	return out
}

func objectFields(o *Object) []FieldPlan {
	if len(o.FieldVals) == 0 {
		return nil
	}
	out := make([]FieldPlan, 0, len(o.FieldVals))
	for _, fb := range o.FieldVals {
		fp := FieldPlan{Field: fb.Field, Value: varName(fb.Val), Stale: fb.Stale}
		if fb.Obj != nil {
			fp.ObjectID = fb.Obj.ID
		}
		out = append(out, fp)
	}
	sort.Slice(out, func(i, j int) bool {
		if out[i].Field != out[j].Field {
			return out[i].Field < out[j].Field
		}
		return out[i].ObjectID < out[j].ObjectID
	})
	return out
}
