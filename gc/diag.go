// gc/diag.go — 诊断两查：checkPremature 抓 use-after-free（正确性），
// transferReport 抓没人接管的转移（泄漏）。给改这套分析的人看：改动后
// 基线必须为 0。

package gc

import (
	"fmt"
)

// checkPremature 遍历所有对象校验释放点不早于任何一个绑定名的作用域。
func (a *analysis) checkPremature() {
	a.premature, a.prematureDetail = 0, nil
	for _, o := range a.objects {
		if o.Inplace || o.FieldOwner != nil || o.Escapes || o.Transferred || o.FreeScope == nil || len(o.Names) == 0 {
			continue
		}
		dRel := scopeDepth(o.FreeScope)
		for _, n := range o.Names {
			if n == nil || a.state(n).scope == nil {
				continue
			}
			if scopeDepth(a.state(n).scope) < dRel {
				a.premature++
				a.prematureDetail = append(a.prematureDetail,
					fmt.Sprintf("#%d 在 %s 释放，但绑定名 %s 活在更外层的 %s",
						o.ID, scopeKindOf(o.FreeScope), n.Name, scopeKindOf(a.state(n).scope)))
				break
			}
		}
	}
}

// transferReport 转移统计：交出去多少、调用方接住多少、没人接=泄漏。
func (a *analysis) transferReport() (sent, taken, orphan int, detail []string) {
	for _, o := range a.objects {
		if !o.Transferred {
			continue
		}
		sent++
		if o.FreeScope != nil {
			taken++
			continue
		}
		orphan++
		if len(detail) < 8 {
			detail = append(detail, fmt.Sprintf("#%d owner=%s 无调用方接管 → 泄漏", o.ID, o.Owner.Name))
		}
	}
	return
}

// Stats 当前前端分析的聚合计数。front 未就绪时返回零值。
func Stats() PlanSummary {
	st := PlanSummary{ByScopeKind: map[string]int{}}
	if front == nil {
		return st
	}
	for _, o := range front.objects {
		st.countObject(front, o)
	}
	st.Inplace = front.inplaceCount()
	return st
}

// countObject 把一个对象计入五态。Stats 与 Plan 共用，避免两套口径漂移。
func (st *PlanSummary) countObject(a *analysis, o *Object) {
	d := DisposalOf(o)
	st.Objects++
	switch d {
	case DisposalScope:
		st.Scope++
		st.ByScopeKind[scopeKindOf(o.FreeScope)]++
		if !a.holderValid(o) {
			st.HolderBad++
		}
	case DisposalRC:
		st.RC++
	case DisposalInplace:
		st.InplaceObj++
	case DisposalField:
		st.Field++
		if !a.fieldPlanValid(o) {
			st.HolderBad++
		}
	case DisposalBorrow:
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

// Premature 提前释放的对象数与明细（应恒为 0）。
func Premature() (int, []string) {
	if front == nil {
		return 0, nil
	}
	return front.premature, front.prematureDetail
}

// TransferReport 交出 / 接住 / 无人接管的转移统计。
func TransferReport() (sent, taken, orphan int, detail []string) {
	if front == nil {
		return 0, 0, 0, nil
	}
	return front.transferReport()
}

// holderValid 释放点读的槽必须仍持有 o，且活得至少和 FreeScope 一样久。
// 否则函数出口读内层块槽可能读到已被复用的栈位（free 错对象）。
func (a *analysis) holderValid(o *Object) bool {
	if o.Holder == nil || o.FreeScope == nil || !containsName(o.Names, o.Holder) {
		return false
	}
	return a.holderLivesTo(o.Holder, o.FreeScope)
}

// fieldPlanValid 字段释放的容器链必须落在有效的作用域释放点上，
// 且读槽仍持有最顶端容器、不早于释放点失效。
func (a *analysis) fieldPlanValid(o *Object) bool {
	if o.FieldOwner == nil || o.FieldName == "" {
		return false
	}
	root := o
	for n := 0; root.FieldOwner != nil; n++ {
		if n > len(a.objects) {
			return false // 成环
		}
		root = root.FieldOwner
	}
	if root == o || root.Inplace || root.FreeScope == nil {
		return false
	}
	return a.holderValid(root)
}

// inplaceCount 已标记就地释放的语句数。
func (a *analysis) inplaceCount() int {
	n := 0
	for _, b := range a.vars {
		if b.releasesOld {
			n++
		}
	}
	return n
}
