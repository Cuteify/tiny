// Package exp 表达式收集器
package exp

import (
	"crypto/sha256"
	"cuteify/parser"
	"encoding/hex"
	"strconv"
)

// ExpInfo 表达式信息
type ExpInfo struct {
	Exp          *parser.Expression
	Left, Right  *ExpInfo
	MinPeak      int    // SU 数
	HardBindMask uint32 // 硬绑定掩码
	HasCall      bool   // 是否有调用
	BindIndex    int    // 基于 SU 顺序的 index（第二趟分配）
	ExpID        int    // 表达式结构 ID（用于复用）
}

// Collect 第一趟：自底向上收集信息
func (c *ECompiler) Collect(root *parser.Expression) {
	if root == nil {
		return
	}

	// 后序遍历收集
	c.collectRec(root)

	// 分配表达式 ID
	c.assignExpID(root)
}

// collectRec 递归收集
func (c *ECompiler) collectRec(exp *parser.Expression) *ExpInfo {
	if exp == nil {
		return nil
	}

	ei := &ExpInfo{Exp: exp}
	c.expInfo[exp] = ei

	// 先递归子节点
	ei.Left = c.collectRec(exp.Left)
	ei.Right = c.collectRec(exp.Right)

	// 叶子节点
	if exp.Separator == "" {
		if exp.IsConst() {
			ei.MinPeak = 0
		} else {
			ei.MinPeak = 1
		}
		// 检查是否是函数调用
		if exp.Call != nil {
			ei.HasCall = true
		}
		return ei
	}

	// 二元运算：SU 算法
	c.collectBin(exp, ei)
	return ei
}

// collectBin 收集二元运算信息
func (c *ECompiler) collectBin(exp *parser.Expression, ei *ExpInfo) {
	li, ri := ei.Left, ei.Right

	// 保护 nil 子节点
	if li == nil || ri == nil {
		ei.MinPeak = 1
		return
	}

	// HasCall
	ei.HasCall = li.HasCall || ri.HasCall

	// SU 核心：计算最小寄存器峰值
	leftPeak := max(li.MinPeak, 1)
	rightPeak := max(ri.MinPeak, 1)

	if leftPeak == rightPeak {
		ei.MinPeak = leftPeak + 1
	} else {
		ei.MinPeak = max(leftPeak, rightPeak)
	}

	// 硬绑定掩码
	ei.HardBindMask = li.HardBindMask | ri.HardBindMask
	ei.HardBindMask |= c.ctx.Arch.NeedBindMask(exp.Separator)
}

// assignExpID 分配表达式 ID
func (c *ECompiler) assignExpID(root *parser.Expression) {
	c.expCounter = 0
	c.expIDMap = make(map[string]int)
	c.assignExpIDRec(root)
}

// assignExpIDRec 递归分配 ID
func (c *ECompiler) assignExpIDRec(exp *parser.Expression) {
	if exp == nil {
		return
	}

	key := c.expKey(exp)
	if id, ok := c.expIDMap[key]; ok {
		c.expInfo[exp].ExpID = id
	} else {
		c.expCounter++
		c.expIDMap[key] = c.expCounter
		c.expInfo[exp].ExpID = c.expCounter
	}

	c.assignExpIDRec(exp.Left)
	c.assignExpIDRec(exp.Right)
}

// expKey 生成表达式结构 key（排除调用和变量）
func (c *ECompiler) expKey(exp *parser.Expression) string {
	if exp == nil {
		return ""
	}
	if exp.Call != nil || exp.Var != nil {
		return "" // 不参与复用
	}

	h := sha256.New()
	h.Write([]byte(exp.Separator))
	if exp.IsConst() {
		h.Write([]byte(strconv.FormatFloat(exp.Num, 'f', -1, 64)))
	}
	if exp.Left != nil {
		h.Write([]byte(c.expKey(exp.Left)))
	}
	if exp.Right != nil {
		h.Write([]byte(c.expKey(exp.Right)))
	}
	return hex.EncodeToString(h.Sum(nil))
}

// BuildSuffixMask 构建后缀硬绑定掩码数组
// 返回：每个 BindIndex 位置的后缀掩码（包含该位置及之后所有节点的硬绑定）
func (c *ECompiler) BuildSuffixMask(nodeCount int) []uint32 {
	// 收集每个 index 的掩码
	indexMask := make([]uint32, nodeCount)
	for exp, ei := range c.expInfo {
		if ei.BindIndex < nodeCount {
			indexMask[ei.BindIndex] |= ei.HardBindMask
			_ = exp
		}
	}

	// 从后往前累或
	suffix := make([]uint32, nodeCount)
	suffix[nodeCount-1] = indexMask[nodeCount-1]
	for i := nodeCount - 2; i >= 0; i-- {
		suffix[i] = indexMask[i] | suffix[i+1]
	}

	return suffix
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
