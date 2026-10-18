// parser/gc_diag.go — 诊断：抓两类错
//
//	checkPremature   释放点早于某个绑定名的作用域 → use-after-free。
//	                 这是**正确性**检查。用最终快照判，能抓"数据已对但释放点算早"，
//	                 抓不到"某条路径上曾持有过"那类（那要路径分析）。
//
//	TransferReport   所有权转移出去却没人接管 → 泄漏。交出 / 接管 / 无人接管三个数。
//
// 这两个不是给人看的，是给改这套分析的人看的。改动后基线必须是 0。

package parser

import "fmt"

// Premature 提前释放的对象（诊断）。
//
// 判据：对象 O 的释放点是 S，但 O 的某个绑定名 n 的作用域比 S 更外层
// —— 也就是说 n 在 S 退出之后还活着，却在 S 就被 free 了。这是 use-after-free。
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
