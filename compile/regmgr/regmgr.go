package regmgr

import (
	"cuteify/parser"
	"cuteify/utils"
	"fmt"
	"strconv"
)

// RegMgr 寄存器管理器
type RegMgr struct {
	Record        map[*parser.Expression]*Reg // 寄存器分配记录
	Registers     []*Reg                      // 寄存器状态数组
	RegisterCount int                         // 已分配寄存器数量
	Index         int                         // 分配索引（LRU）
	RegInfo       []RegInfo                   // 寄存器架构信息
	TotalReg      int                         // 总寄存器数
	LockedRegs    map[int]bool                // 锁定寄存器标记
	Records       []RegInfo
	RecordEnable  bool
}

// RegInfo 寄存器基本信息
type RegInfo struct {
	Name       string
	CalleeSave bool // 是否为被调用者保存
	CallerSave bool // 是否为调用者保存
}

// Reg 寄存器信息
type Reg struct {
	StoreCode  string       // 溢出存储代码
	Name       string       // 寄存器名称
	RegIndex   int          // 物理寄存器索引
	Index      int          // 分配索引
	UsingNode  *parser.Node // 使用节点
	Destroyed  bool         // 是否已销毁
	CalleeSave bool         // 被调用者保存
	CallerSave bool         // 调用者保存
	Locked     bool         // 锁定状态（关键字段）
	SpillCount int          // 溢出次数统计
}

// NewRegMgr 创建新的寄存器管理器
func NewRegMgr(regs []RegInfo) *RegMgr {
	rm := &RegMgr{
		RegInfo:    regs,
		TotalReg:   len(regs),
		Registers:  make([]*Reg, len(regs)),
		Record:     make(map[*parser.Expression]*Reg),
		LockedRegs: make(map[int]bool),
	}
	return rm
}

// Get 为表达式分配寄存器（支持生命周期感知）
func (rm *RegMgr) Get(n *parser.Node, exp *parser.Expression, lifespanCrossesCall bool) *Reg {
	rm.Index++

	// 检查是否已分配
	if existing := rm.Record[exp]; existing != nil && !existing.Destroyed {
		existing.Index = rm.Index
		rm.record(existing)
		return existing
	}

	// 根据生命周期选择寄存器类型
	preferredType := "caller"
	if lifespanCrossesCall {
		preferredType = "callee"
	}

	// 第一轮：尝试分配首选类型寄存器
	if reg := rm.allocatePreferredType(preferredType, n, exp); reg != nil {
		rm.record(reg)
		return reg
	}

	// 第二轮：尝试分配任何可用寄存器
	if reg := rm.allocateAnyAvailable(n, exp); reg != nil {
		rm.record(reg)
		return reg
	}

	// 寄存器不足，执行溢出处理（跳过锁定寄存器）
	reg := rm.handleRegisterSpill(n, exp, preferredType)
	rm.record(reg)
	return reg
}

// allocatePreferredType 分配首选类型的寄存器
func (rm *RegMgr) allocatePreferredType(preferredType string, n *parser.Node, exp *parser.Expression) *Reg {
	for i := 0; i < rm.TotalReg; i++ {
		if rm.Registers[i] != nil && !rm.Registers[i].Destroyed {
			continue
		}

		// 检查寄存器类型匹配且未被锁定
		regInfo := rm.RegInfo[i]
		matchesPreference := (preferredType == "callee" && regInfo.CalleeSave) ||
			(preferredType == "caller" && regInfo.CallerSave)

		if matchesPreference && !rm.LockedRegs[i] {
			reg := &Reg{
				RegIndex:   i,
				Name:       regInfo.Name,
				CalleeSave: regInfo.CalleeSave,
				CallerSave: regInfo.CallerSave,
				Index:      rm.Index,
				UsingNode:  n,
				Destroyed:  false,
				Locked:     false,
			}

			rm.Registers[i] = reg
			rm.Record[exp] = reg
			rm.updateRegisterCount()
			return reg
		}
	}
	return nil
}

// allocateAnyAvailable 分配任何可用寄存器
func (rm *RegMgr) allocateAnyAvailable(n *parser.Node, exp *parser.Expression) *Reg {
	for i := 0; i < rm.TotalReg; i++ {
		if rm.Registers[i] == nil || rm.Registers[i].Destroyed {
			if !rm.LockedRegs[i] { // 跳过锁定的寄存器
				regInfo := rm.RegInfo[i]
				reg := &Reg{
					RegIndex:   i,
					Name:       regInfo.Name,
					CalleeSave: regInfo.CalleeSave,
					CallerSave: regInfo.CallerSave,
					Index:      rm.Index,
					UsingNode:  n,
					Destroyed:  false,
					Locked:     false,
				}

				rm.Registers[i] = reg
				rm.Record[exp] = reg
				rm.updateRegisterCount()
				return reg
			}
		}
	}
	return nil
}

// handleRegisterSpill 处理寄存器溢出（核心：跳过锁定寄存器）
func (rm *RegMgr) handleRegisterSpill(n *parser.Node, exp *parser.Expression, preferredType string) *Reg {
	// 寻找最佳的溢出候选（排除锁定寄存器）
	spillCandidate := rm.findSpillCandidate(preferredType)
	if spillCandidate == nil {
		// 所有可用寄存器都被锁定
		panic("编译器内部错误: 所有寄存器都被锁定，无法分配新寄存器")
	}

	// 生成溢出代码
	spillCode := rm.generateSpillCode(spillCandidate)

	// 创建新的寄存器记录
	newReg := &Reg{
		RegIndex:   spillCandidate.RegIndex,
		Name:       spillCandidate.Name,
		CalleeSave: spillCandidate.CalleeSave,
		CallerSave: spillCandidate.CallerSave,
		Index:      rm.Index,
		UsingNode:  n,
		Destroyed:  false,
		Locked:     false,
		StoreCode:  spillCode,
		SpillCount: spillCandidate.SpillCount + 1,
	}

	// 清理原记录
	if oldExp := rm.findExpressionByReg(spillCandidate.RegIndex); oldExp != nil {
		delete(rm.Record, oldExp)
	}

	// 更新记录
	rm.Registers[spillCandidate.RegIndex] = newReg
	rm.Record[exp] = newReg
	rm.updateRegisterCount()

	return newReg
}

// findSpillCandidate 寻找溢出候选（关键：排除锁定寄存器）
func (rm *RegMgr) findSpillCandidate(currentPreference string) *Reg {
	var bestCandidate *Reg
	minCost := int(^uint(0) >> 1)

	for _, reg := range rm.Record {
		if reg == nil || reg.Destroyed || reg.Locked { // 关键：跳过锁定寄存器
			continue
		}

		cost := rm.calculateSpillCost(reg, currentPreference)
		if cost < minCost {
			minCost = cost
			bestCandidate = reg
		}
	}
	return bestCandidate
}

// calculateSpillCost 计算溢出代价
func (rm *RegMgr) calculateSpillCost(reg *Reg, currentPreference string) int {
	cost := reg.Index // 基本成本：最近使用程度

	// 锁定寄存器的代价无限大（绝对不溢出）
	if reg.Locked {
		return int(^uint(0) >> 1)
	}

	// 根据偏好调整成本
	if currentPreference == "callee" && reg.CalleeSave {
		cost += 1000
	} else if currentPreference == "caller" && reg.CallerSave {
		cost += 500
	}

	// 考虑溢出历史
	cost += reg.SpillCount * 100

	return cost
}

// Force 强制分配特定寄存器（锁定感知版本）
func (rm *RegMgr) Force(regInfo *Reg, n *parser.Node, exp *parser.Expression) *Reg {
	rm.Index++
	if regInfo.Name != "" {
		for i := 0; i < rm.TotalReg; i++ {
			if rm.RegInfo[i].Name == regInfo.Name {
				regInfo.RegIndex = i
				break
			}
		}
	}
	regIndex := regInfo.RegIndex

	if regIndex < 0 || regIndex >= rm.TotalReg {
		panic("无效的寄存器索引: " + strconv.Itoa(regIndex))
	}

	// 检查目标寄存器是否被锁定
	if rm.LockedRegs[regIndex] {
		panic(fmt.Sprintf("编译器内部错误: 无法强制获取寄存器 %s，该寄存器已被锁定",
			rm.RegInfo[regIndex].Name))
	}

	// 检查目标寄存器是否被占用
	if occupiedReg := rm.Registers[regIndex]; occupiedReg != nil && !occupiedReg.Destroyed {
		if occupiedReg.Locked {
			panic(fmt.Sprintf("编译器内部错误: 无法强制获取寄存器 %s，该寄存器已被锁定",
				rm.RegInfo[regIndex].Name))
		}
		// 溢出当前占用的寄存器
		rm.spillRegister(occupiedReg, rm.findExpressionByReg(regIndex))
	}

	// 分配目标寄存器
	regInfo.Name = rm.RegInfo[regIndex].Name
	regInfo.CalleeSave = rm.RegInfo[regIndex].CalleeSave
	regInfo.CallerSave = rm.RegInfo[regIndex].CallerSave
	regInfo.Index = rm.Index
	regInfo.UsingNode = n
	regInfo.Destroyed = false
	regInfo.Locked = true

	// 设置锁定状态
	rm.LockedRegs[regIndex] = true

	rm.Registers[regIndex] = regInfo
	rm.Record[exp] = regInfo
	rm.updateRegisterCount()

	return regInfo
}

// spillRegister 溢出单个寄存器
func (rm *RegMgr) spillRegister(reg *Reg, exp *parser.Expression) {
	if reg.UsingNode != nil {
		// 生成溢出代码
		reg.StoreCode = rm.generateSpillCode(reg)
	}
	reg.Destroyed = true
	delete(rm.Record, exp)
	rm.updateRegisterCount()
}

// generateSpillCode 生成溢出代码
func (rm *RegMgr) generateSpillCode(reg *Reg) string {
	if reg.UsingNode == nil {
		return ""
	}

	if vb, ok := reg.UsingNode.Value.(*parser.VarBlock); ok {
		addr := rm.calculateMemoryAddress(vb)
		sizeSpec := utils.GetLengthName(vb.Type.Size())
		return utils.Format("mov " + sizeSpec + addr + ", " + reg.Name + "; 溢出到局部变量栈")
	}

	return utils.Format("mov [esp], " + reg.Name + "; 溢出到临时栈位置")
}

// calculateMemoryAddress 计算内存地址
func (rm *RegMgr) calculateMemoryAddress(vb *parser.VarBlock) string {
	if vb.Define != nil {
		switch def := vb.Define.Value.(type) {
		case *parser.VarBlock:
			vb.Offset = def.Offset
		case *parser.ArgBlock:
			vb.Offset = def.Offset
		}
	}

	if vb.Offset < 0 {
		return "[ebp" + strconv.FormatInt(int64(vb.Offset), 10) + "]"
	} else if vb.Offset == 0 {
		return "[ebp]"
	} else {
		return "[ebp+" + strconv.FormatInt(int64(vb.Offset), 10) + "]"
	}
}

// Free 释放寄存器（可释放锁定寄存器）
func (rm *RegMgr) Free(exp *parser.Expression) {
	rm.Index++

	if rm.Record[exp] == nil {
		return
	}

	regInfo := rm.Record[exp]
	// 允许释放锁定的寄存器
	regInfo.Destroyed = true
	regInfo.Locked = false
	rm.LockedRegs[regInfo.RegIndex] = false
	rm.Registers[regInfo.RegIndex] = nil
	delete(rm.Record, exp)
	rm.updateRegisterCount()
}

// SetLock 设置寄存器锁定状态
func (rm *RegMgr) SetLock(exp *parser.Expression, locked bool) {
	if reg, exists := rm.Record[exp]; exists && !reg.Destroyed {
		reg.Locked = locked
		rm.LockedRegs[reg.RegIndex] = locked
	}
}

// findExpressionByReg 通过寄存器索引查找表达式
func (rm *RegMgr) findExpressionByReg(regIndex int) *parser.Expression {
	for exp, reg := range rm.Record {
		if reg != nil && reg.RegIndex == regIndex && !reg.Destroyed {
			return exp
		}
	}
	return nil
}

// updateRegisterCount 更新寄存器计数
func (rm *RegMgr) updateRegisterCount() {
	count := 0
	for i := 0; i < rm.TotalReg; i++ {
		if rm.Registers[i] != nil && !rm.Registers[i].Destroyed {
			count++
		}
	}
	rm.RegisterCount = count
}

// GetRegisterUsage 获取寄存器使用统计
func (rm *RegMgr) GetRegisterUsage() (used, total, locked int) {
	used = 0
	locked = 0
	for i := 0; i < rm.TotalReg; i++ {
		if rm.Registers[i] != nil && !rm.Registers[i].Destroyed {
			used++
			if rm.Registers[i].Locked {
				locked++
			}
		}
	}
	return used, rm.TotalReg, locked
}

// Reuse 重用节点寄存器
func (rm *RegMgr) Reuse(n *parser.Node) *Reg {
	for _, r := range rm.Record {
		if r.UsingNode == n && !r.Destroyed {
			return r
		}
	}
	return nil
}

// IsLocked 检查寄存器是否被锁定
func (rm *RegMgr) IsLocked(regIndex int) bool {
	return rm.LockedRegs[regIndex]
}

// GetLockedRegisters 获取所有被锁定的寄存器信息
func (rm *RegMgr) GetLockedRegisters() []string {
	var locked []string
	for i, isLocked := range rm.LockedRegs {
		if isLocked && rm.Registers[i] != nil && !rm.Registers[i].Destroyed {
			locked = append(locked, rm.Registers[i].Name)
		}
	}
	return locked
}

func (rm *RegMgr) record(r *Reg) {
	if rm.RecordEnable {
		for i := 0; i < len(rm.RegInfo); i++ {
			regInfo := rm.RegInfo[i]
			if regInfo.Name == r.Name {
				rm.Records = append(rm.Records, regInfo)
			}
		}
	}
}

func (rm *RegMgr) Save(exp *parser.Expression) (code string) {
	// 强制回写
	// 生成溢出代码
	code = rm.generateSpillCode(rm.Record[exp])
	delete(rm.Record, exp)
	rm.updateRegisterCount()
	return
}

func (rm *RegMgr) SaveAll(calleeSave bool) (codes []string) {
	// 强制回写全部
	for exp, ri := range rm.Record {
		if ri.CalleeSave != calleeSave || rm.LockedRegs[ri.RegIndex] {
			continue
		}
		// 生成溢出代码
		codes = append(codes, rm.generateSpillCode(ri))
		delete(rm.Record, exp)
	}
	rm.updateRegisterCount()
	return
}
