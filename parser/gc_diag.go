// parser/gc_diag.go — 诊断两查：checkPremature 抓 use-after-free（正确性），
// TransferReport 抓没人接管的转移（泄漏）。给改这套分析的人看：改动后基线必须为 0。

package parser

import "fmt"

// Premature 提前释放的对象数：释放点早于某绑定名的作用域 = use-after-free。
var Premature int

var PrematureDetail []string

// checkPremature 遍历所有对象校验释放点不早于任何一个绑定名的作用域。
func checkPremature() {
	Premature, PrematureDetail = 0, nil
	for _, o := range objects {
		if o.Escapes || o.Transferred || o.FreeScope == nil || len(o.Names) == 0 {
			continue
		}
		dRel := scopeDepth(o.FreeScope)
		for _, n := range o.Names {
			if n == nil || n.Life.Scope == nil {
				continue
			}
			if scopeDepth(n.Life.Scope) < dRel {
				Premature++
				PrematureDetail = append(PrematureDetail,
					fmt.Sprintf("#%d 在 %s 释放，但绑定名 %s 活在更外层的 %s",
						o.ID, scopeKindOf(o.FreeScope), n.Name, scopeKindOf(n.Life.Scope)))
				break
			}
		}
	}
}

// TransferReport 转移统计：交出去多少、调用方接住多少、没人接=泄漏。
func TransferReport() (sent, taken, orphan int, detail []string) {
	for _, o := range objects {
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
