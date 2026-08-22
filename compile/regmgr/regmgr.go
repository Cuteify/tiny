package regmgr

import (
	"cuteify/parser"
)

// MemAddr 内存地址接口
type MemAddr interface {
	String() string
	Size() int
	IsPtr() bool
	Eq(MemAddr) bool
}

// Reg 寄存器信息
type Reg struct {
	Name       string  // 寄存器名称
	RegIndex   int     // 物理寄存器索引
	ClassMask  uint32  // 寄存器类别掩码（硬件固有属性）
	CalleeSave bool    // 是否 callee-save
	User       MemAddr // 溢出回写地址
	ExpID      int     // 绑定的表达式 ID（用于复用）
	Free       bool    // 是否空闲
	StoreCode  string  // 溢出存储代码
}

// RegMgr 寄存器管理器
type RegMgr struct {
	Record   map[*parser.Expression]*Reg // 表达式 -> 寄存器
	Regs     []*Reg                      // 所有寄存器
	TotalReg int                         // 总寄存器数量
}

// NewRegMgr 创建寄存器管理器
// 支持两种调用方式：
// 1. NewRegMgr(regs) - 只传寄存器列表
// 2. NewRegMgr(regs, genVarAddr) - 传寄存器列表和地址生成函数
func NewRegMgr(regs []*Reg) *RegMgr {
	rm := &RegMgr{
		Record:   make(map[*parser.Expression]*Reg),
		Regs:     regs,
		TotalReg: len(regs),
	}
	// 初始化所有寄存器为空闲
	for _, reg := range regs {
		reg.Free = true
	}
	return rm
}

// SaveAll 保存所有已使用的寄存器（生成 push 指令）
func (rm *RegMgr) SaveAll(calleeOnly bool) []string {
	var codes []string
	for _, reg := range rm.Regs {
		if !reg.Free {
			if calleeOnly && !reg.CalleeSave {
				continue
			}
			codes = append(codes, "push "+reg.Name+"; save "+reg.Name)
		}
	}
	return codes
}

// Force 强制将表达式绑定到指定寄存器
func (rm *RegMgr) Force(reg *Reg, exp *parser.Expression) {
	// 释放该寄存器之前绑定的表达式
	for e, r := range rm.Record {
		if r == reg {
			delete(rm.Record, e)
			break
		}
	}
	// 绑定新表达式
	rm.Record[exp] = reg
	reg.Free = false
}

// FindByName 按名称查找寄存器（返回 regmgr.Regs 中的真实对象）
func (rm *RegMgr) FindByName(name string) *Reg {
	for _, reg := range rm.Regs {
		if reg.Name == name {
			return reg
		}
	}
	return nil
}

// AllocCalleeSaveBind 分配一个空闲的 callee-save 寄存器并把 exp 绑定到它，
// 返回寄存器名；无可用时返回 ""。skip 中列出的寄存器名不分配
// （如 RBX：binop 的中间值保存逻辑硬编码使用它）。
// 用途：在函数调用边界保存中间值——callee-save 寄存器跨调用保持；
// 而压栈保存会被被调函数参数槽 [rbp+16]（=调用点 rsp）覆盖（调用者栈顶临时值）。
func (rm *RegMgr) AllocCalleeSaveBind(exp *parser.Expression, names []string, skip ...string) string {
	for _, name := range names {
		skipped := false
		for _, s := range skip {
			if name == s {
				skipped = true
				break
			}
		}
		if skipped {
			continue
		}
		reg := rm.FindByName(name)
		if reg != nil && reg.Free {
			rm.Force(reg, exp)
			return name
		}
	}
	return ""
}

// Get 获取或分配寄存器（兼容旧 API）
func (rm *RegMgr) Get(node *parser.Node, exp *parser.Expression, mask uint32, calleeSave bool) *Reg {
	// 检查是否已分配
	if reg, ok := rm.Record[exp]; ok {
		return reg
	}
	// 分配新寄存器
	return rm.AllocPref(exp, mask, nil, nil, 0, nil, "")
}

// AllocPref 偏好分配寄存器。
// mask: 必须满足的类别掩码
// prefer: 偏好分数数组（index 对应 RegIndex，越大越优先）
// avoid: 厌恶分数数组（index 对应 RegIndex，越大越避免）
// expID: 当前表达式 ID（用于复用）
// user: 溢出回写地址
// avoidName: 必须避开的寄存器名（该寄存器值仍在使用）
func (rm *RegMgr) AllocPref(
	exp *parser.Expression,
	mask uint32,
	prefer []int,
	avoid []int,
	expID int,
	user MemAddr,
	avoidName string,
) *Reg {
	// 1. 已分配则直接返回
	if reg, ok := rm.Record[exp]; ok {
		return reg
	}

	// 2. 复用：找相同 expID 且空闲的寄存器
	for _, reg := range rm.Regs {
		if reg.ClassMask&mask != 0 && reg.Free && reg.ExpID == expID && expID != 0 && reg.Name != avoidName {
			reg.Free = false
			reg.User = user
			rm.Record[exp] = reg
			return reg
		}
	}

	// 3. 找空闲寄存器：优先 prefer 最高的
	bestReg := (*Reg)(nil)
	bestScore := -1
	for _, reg := range rm.Regs {
		if reg.ClassMask&mask != 0 && reg.Free && reg.Name != avoidName {
			score := 0
			if reg.RegIndex < len(prefer) {
				score = prefer[reg.RegIndex]
			}
			if score > bestScore {
				bestScore = score
				bestReg = reg
			}
		}
	}
	if bestReg != nil {
		bestReg.Free = false
		bestReg.User = user
		bestReg.ExpID = expID
		rm.Record[exp] = bestReg
		return bestReg
	}

	// 4. 必须溢出：优先选有回写地址的寄存器（可真正保存值），否则选 avoid 最低的
	worstReg := (*Reg)(nil)
	worstScore := int(^uint(0) >> 1)
	for _, reg := range rm.Regs {
		if reg.ClassMask&mask != 0 && reg.User != nil && reg.Name != avoidName {
			score := 0
			if reg.RegIndex < len(avoid) {
				score = avoid[reg.RegIndex]
			}
			if score < worstScore {
				worstScore = score
				worstReg = reg
			}
		}
	}
	if worstReg == nil {
		for _, reg := range rm.Regs {
			if reg.ClassMask&mask != 0 && reg.Name != avoidName {
				score := 0
				if reg.RegIndex < len(avoid) {
					score = avoid[reg.RegIndex]
				}
				if score < worstScore {
					worstScore = score
					worstReg = reg
				}
			}
		}
	}
	if worstReg != nil {
		rm.Spill(worstReg)
		worstReg.Free = false
		worstReg.User = user
		worstReg.ExpID = expID
		rm.Record[exp] = worstReg
		return worstReg
	}

	return nil
}

// Free 释放寄存器的占用，但保留 User（用于溢出回写）
func (rm *RegMgr) Free(exp *parser.Expression) {
	reg := rm.Record[exp]
	if reg != nil {
		reg.Free = true
		delete(rm.Record, exp)
	}
}

// Spill 溢出寄存器，生成回写代码
func (rm *RegMgr) Spill(reg *Reg) (code string) {
	if reg.User != nil {
		code = "mov " + reg.User.String() + ", " + reg.Name + "\n"
		reg.StoreCode = code
	}
	reg.Free = true
	reg.User = nil
	reg.ExpID = 0
	return code
}

// UpdateUser 更新寄存器的 User（当寄存器值被修改时调用）
func (rm *RegMgr) UpdateUser(reg *Reg, user MemAddr) {
	if reg != nil {
		reg.User = user
	}
}

// Reset 重置所有寄存器
func (rm *RegMgr) Reset() {
	for _, reg := range rm.Regs {
		reg.Free = true
		reg.User = nil
		reg.ExpID = 0
	}
	rm.Record = map[*parser.Expression]*Reg{}
}

// AvailableRegs 统计符合掩码的空闲寄存器数量
func (rm *RegMgr) AvailableRegs(mask uint32) (count int) {
	for _, reg := range rm.Regs {
		if reg.ClassMask&mask != 0 && reg.Free {
			count++
		}
	}
	return
}
