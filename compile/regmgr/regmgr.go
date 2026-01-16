package regmgr

import (
	"cuteify/parser"
	"cuteify/utils"
	"fmt"
	"strconv"
)

// RegMgr 寄存器管理器
type RegMgr struct {
	Record     map[*parser.Expression]*Reg // 寄存器分配记录
	Regs       []*Reg                      // 寄存器状态数组
	RegCount   int                         // 已分配寄存器数量
	index      int                         // 分配索引（LRU）
	totalReg   int                         // 总寄存器数量
	genVarAddr func(varBlock *parser.VarBlock) string
}

// Reg 寄存器信息
type Reg struct {
	StoreCode  string       // 溢出存储代码
	Name       string       // 寄存器名称
	RegIndex   int          // 物理寄存器索引
	index      int          // 分配索引
	UsingNode  *parser.Node // 使用节点
	Using      bool         // 是否使用
	CalleeSave bool         // 被调用者保存
	Locked     bool         // 锁定状态（关键字段）
	SpillCount int          // 溢出次数统计
}

// NewRegMgr 创建新的寄存器管理器
func NewRegMgr(regs []*Reg, genVarAddr func(varBlock *parser.VarBlock) string) *RegMgr {
	rm := &RegMgr{
		Regs:       regs,
		Record:     make(map[*parser.Expression]*Reg),
		totalReg:   len(regs),
		genVarAddr: genVarAddr,
	}
	return rm
}

// Get 为表达式分配寄存器（支持生命周期感知）
func (rm *RegMgr) Get(n *parser.Node, exp *parser.Expression, needCalleeSave bool) (reg *Reg) {
	rm.index++
	// 检查是否已分配
	if existing := rm.Record[exp]; existing != nil && existing.Using {
		existing.index = rm.index
		return existing
	}

	if !needCalleeSave {
		// 分配不需要callee保存的的寄存器
		if reg = rm.allocate(n, exp, false); reg != nil {
			return reg
		}
	}

	if reg == nil {
		if reg = rm.allocate(n, exp, true); reg != nil {
			return reg
		}
	}

	// 寄存器不足，执行溢出处理（跳过锁定寄存器）
	reg = rm.spillReg(n, exp, needCalleeSave)
	return reg
}

func (rm *RegMgr) allocate(n *parser.Node, exp *parser.Expression, needCalleeSave bool) *Reg {
	// 检查是否有剩余寄存器
	if rm.RegCount >= rm.totalReg {
		return nil
	}

	// 分配寄存器
	for i := 0; i < rm.totalReg; i++ {
		reg := rm.Regs[i]

		if reg != nil && (reg.Using || reg.CalleeSave) {
			continue
		}

		// 写入新的所有权数据
		reg.Reset()
		rm.Record[exp] = reg
		reg.UsingNode = n
		reg.index = rm.index
		reg.Using = true
		rm.calcUsingReg()

		return reg
	}

	return nil
}

// calculateSpillCost 计算溢出代价
func (rm *RegMgr) calcSpillCost(reg *Reg, needCalleeSave bool) int {
	cost := reg.index // 基本成本：最近使用程度

	// 锁定寄存器的代价无限大（绝对不溢出）
	if reg.Locked {
		return int(^uint(0) >> 1)
	}

	// 根据偏好调整成本
	if needCalleeSave && reg.CalleeSave {
		cost += 1000
	} else if !needCalleeSave && !reg.CalleeSave {
		cost += 500
	}

	// 考虑溢出历史
	cost += reg.SpillCount * 100

	return cost
}

// Force 强制分配特定寄存器
func (rm *RegMgr) Force(reg *Reg, n *parser.Node, exp *parser.Expression) *Reg {
	rm.index++

	if reg == nil {
		return nil
	}

	// 获取寄存器索引
	regIndex := reg.RegIndex
	if reg.Name != "" {
		for i := 0; i < rm.totalReg; i++ {
			if rm.Regs[i].Name == reg.Name {
				regIndex = i
				break
			}
		}
	}

	// 检查索引
	if regIndex < 0 || regIndex >= rm.totalReg {
		panic("无效的寄存器索引: " + strconv.Itoa(regIndex))
	}

	// 写入数据到临时变量
	*reg = *rm.Regs[regIndex]

	// 检查是否被锁定
	if reg.Locked {
		panic(fmt.Sprintf("编译器内部错误: 无法强制获取寄存器 %s，该寄存器已被锁定",
			rm.Regs[regIndex].Name))
	}

	// 检查是否被占用
	if reg.Using {
		// 溢出当前占用的寄存器
		rm.genSpill(reg)
	}

	// 写入新的所有权数据
	reg.Reset()
	reg.index = rm.index
	reg.UsingNode = n
	reg.Using = true

	rm.Record[exp] = reg
	rm.calcUsingReg()

	return reg
}

// spillReg 溢出单个寄存器
func (rm *RegMgr) spillReg(n *parser.Node, exp *parser.Expression, needCalleeSave bool) *Reg {
	// 计算代价
	minCost := int(^uint(0) >> 1)
	var minReg *Reg
	for _, reg := range rm.Regs {
		cost := rm.calcSpillCost(reg, needCalleeSave)
		if cost < minCost {
			minCost = cost
			minReg = reg
		}
	}

	if minReg == nil {
		panic("编译器内部错误: 无法溢出寄存器")
	}

	// 执行溢出操作
	delete(rm.Record, exp)
	minReg.StoreCode = rm.genSpill(minReg)

	// 重新分配所有权
	minReg.Reset()
	minReg.Using = true
	minReg.UsingNode = n
	minReg.SpillCount++
	minReg.index = rm.index

	// 重新计算使用中的寄存器
	rm.calcUsingReg()

	// 返回的溢出寄存器
	return minReg
}

// genSpill 生成溢出代码（NASM格式）
func (rm *RegMgr) genSpill(reg *Reg) string {
	if reg.UsingNode == nil {
		return ""
	}

	if vb, ok := reg.UsingNode.Value.(*parser.VarBlock); ok {
		addr := rm.genVarAddr(vb)
		// x86 32位平台所有寄存器都是32位，溢出时只能存储32位
		// 强制使用dword避免类型不匹配问题
		code := utils.Format("mov dword " + addr + ", " + reg.Name + "; spill")
		reg.StoreCode = code
		return code
	}

	// 临时表达式值不溢出到栈（通过EBX callee-save寄存器处理）
	// 中间值应该已经在表达式中正确处理，这里不需要生成溢出代码
	return ""
}

// Free 释放寄存器
func (rm *RegMgr) Free(exp *parser.Expression) {
	rm.index++

	// 检查是否存在记录
	if rm.Record[exp] == nil {
		return
	}

	// 释放寄存器
	reg := rm.Record[exp]
	reg.Reset()
	//delete(rm.Record, exp)

	// 重新计算使用中的寄存器
	rm.calcUsingReg()
}

// calcUsingReg 更新寄存器计数
func (rm *RegMgr) calcUsingReg() {
	count := 0
	for i := 0; i < rm.totalReg; i++ {
		if rm.Regs[i] != nil && rm.Regs[i].Using {
			count++
		}
	}
	rm.RegCount = count
}

// Reuse 重用节点寄存器
func (rm *RegMgr) Reuse(n *parser.Node) *Reg {
	for _, reg := range rm.Record {
		if reg.UsingNode == n && reg.Using {
			return reg
		}
	}
	return nil
}

func (rm *RegMgr) Save(exp *parser.Expression) (code string) {
	// 生成溢出代码
	rm.genSpill(rm.Record[exp])
	delete(rm.Record, exp)
	rm.calcUsingReg()
	return
}

func (rm *RegMgr) SaveAll(calleeSave bool) (codes []string) {
	// 强制回写全部
	for exp, ri := range rm.Record {
		if ri.CalleeSave != calleeSave || ri.Locked {
			continue
		}
		// 生成溢出代码
		codes = append(codes, rm.genSpill(ri))
		delete(rm.Record, exp)
	}
	rm.calcUsingReg()
	return
}

func (rm *RegMgr) Reset() {
	// 清理寄存器记录
	rm.Record = map[*parser.Expression]*Reg{}
	for i := 0; i < rm.totalReg; i++ {
		reg := rm.Regs[i]
		if reg != nil && reg.Using {
			reg.Reset()
			reg.SpillCount = 0
		}
	}
	rm.calcUsingReg()
	rm.index = 0
	rm.RegCount = 0
}

func (reg *Reg) Reset() {
	reg.Using = false
	reg.Locked = false
	reg.UsingNode = nil
	reg.StoreCode = ""
}

func (rm *RegMgr) GetRegUsage() (int, int, int) {
	rm.calcUsingReg()
	return rm.RegCount, rm.totalReg, rm.index
}
