package compile

import (
	"cuteify/parser"
	"strconv"
	"unsafe"
)

// Architecture 定义CPU架构及其寄存器集合
type Architecture struct {
	Name          string   // 架构名称
	Registers     []string // 架构支持的寄存器列表
	RegisterCount int      // 寄存器总数
}

// 定义各种CPU架构及其寄存器
var architectures = map[string]Architecture{
	"x86": {
		Name: "x86",
		Registers: []string{
			"EAX", "EBX", "ECX", "EDX",
			"ESI", "EDI",
		},
		RegisterCount: 6,
	},
	"amd64": {
		Name: "x86-64",
		Registers: []string{
			"RAX", "RBX", "RCX", "RDX",
			"R8", "R9", "R10", "R11",
			"R12", "R13", "R14", "R15",
		},
		RegisterCount: 12,
	},
	"ARM": {
		Name: "ARM",
		Registers: []string{
			"R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7",
			"R8", "R9", "R10", "R11", "R12",
			"SP", "LR",
		},
		RegisterCount: 15,
	},
	"MIPS": {
		Name: "MIPS",
		Registers: []string{
			"$0", "$at", "$v0", "$v1",
			"$a0", "$a1", "$a2", "$a3",
			"$t0", "$t1", "$t2", "$t3", "$t4", "$t5", "$t6", "$t7", "$t8", "$t9",
			"$k0", "$k1",
			"$gp", "$sp", "$fp",
			"$gp", "$sp", "$fp",
		},
		RegisterCount: 32,
	},
	"PowerPC": {
		Name: "PowerPC",
		Registers: []string{
			"r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7",
			"r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15",
			"r16", "r17", "r18", "r19", "r20", "r21", "r22", "r23",
			"r24", "r25", "r26", "r27", "r28", "r29", "r30", "r31",
		},
		RegisterCount: 32,
	},
	"SPARC": {
		Name: "SPARC",
		Registers: []string{
			"g1", "g2", "g3", "g4", "g5", "g6",
			"o0", "o1", "o2", "o3", "o4", "o5", "o6", "o7",
			"i0", "i1", "i2", "i3", "i4", "i5", "i6", "i7",
			"l0", "l1", "l2", "l3", "l4", "l5", "l6", "l7",
		},
		RegisterCount: 32,
	},
	"RISC_V": {
		Name: "RISC-n",
		Registers: []string{
			"x0", "x1", "x2", "x3", "x4", "x5", "x6", "x7",
			"x8", "x9", "x10", "x11", "x12", "x13", "x14", "x15",
			"x16", "x17", "x18", "x19", "x20", "x21", "x22", "x23",
			"x24", "x25", "x26", "x27", "x28", "x29", "x30", "x31",
		},
		RegisterCount: 32,
	},
}

// Register 寄存器管理器结构
type Register struct {
	Record        map[*parser.Expression]*Reg // 寄存器分配记录
	Registers     []bool                      // 寄存器使用状态数组
	RegisterCount int                         // 已分配的寄存器数量
	Index         int                         // 分配索引，用于LRU算法
}

// Reg 寄存器信息结构
type Reg struct {
	StoreCode string // 在使用寄存器前需要执行的代码
	//AfterCode string       // 在释放寄存器后需要执行的代码
	Name      string       // 寄存器名称
	RegIndex  int          // 寄存器在架构中的索引
	Index     int          // 分配时的索引，用于LRU算法
	UsingNode *parser.Node // 正在使用该寄存器的节点
	Destroyed bool
}

// GetRegister 为表达式分配寄存器
// 参数:
//   - n: 当前AST节点
//   - exp: 表达式
//
// 返回:
//   - regInfo: 分配的寄存器信息
func (reg *Register) GetRegister(n *parser.Node, exp *parser.Expression) (regInfo *Reg) {
	// 增加分配索引
	reg.Index++

	// 初始化寄存器记录映射
	if reg.Record == nil {
		reg.Record = make(map[*parser.Expression]*Reg)
	}

	// 初始化寄存器使用状态数组
	if reg.Registers == nil {
		reg.Registers = make([]bool, architectures[GoArch].RegisterCount)
	}

	// 如果该表达式已经有分配的寄存器，则直接返回
	if reg.Record[exp] != nil {
		regInfo = reg.Record[exp]
		regInfo.Index = reg.Index
		return
	}

	// 如果还有可用寄存器，则分配一个新寄存器
	if architectures[GoArch].RegisterCount > reg.RegisterCount {
		for i := reg.RegisterCount; i < architectures[GoArch].RegisterCount; i++ {
			if !reg.Registers[i] {
				regInfo = &Reg{}
				regInfo.Index = reg.Index
				reg.Record[exp] = regInfo
				regInfo.Name = architectures[GoArch].Registers[i]
				reg.Registers[i] = true
				regInfo.RegIndex = i
				regInfo.UsingNode = n
				reg.setCount()
				return
			}
		}
	} else {
		// TODO: 当寄存器不足时的处理逻辑需要完善
		/*var indexOldest *Reg
		for _, regInfo := range reg.Record {
			if indexOldest == nil || regInfo.RegIndex < indexOldest.RegIndex {
				indexOldest = regInfo
			}
		}
		newRegInfo := &Reg{}
		newRegInfo.RegName = indexOldest.RegName
		newRegInfo.RegIndex = indexOldest.RegIndex
		newRegInfo.Index = reg.Index
		newRegInfo.AfterCode = "pop " + indexOldest.RegName
		newRegInfo.BeforeCode = "push " + newRegInfo.RegName
		newRegInfo.Occupie = true
		reg.Record[name] = newRegInfo
		newRegInfo.Name = name
		regInfo = newRegInfo
		return*/
		// 判断变量定义，找到变量定义，溢出不再使用的变量
		for vn, r := range reg.Record {
			if reg.isVarNotNeed(r, n) {
				r.Destroyed = true
				delete(reg.Record, vn)
				reg.Record[exp] = r
				r.UsingNode = n
			}
		}
		// 找到最早使用的变量
		var indexOldest *Reg
		for _, r := range reg.Record {
			if indexOldest == nil || r.Index < indexOldest.Index {
				indexOldest = r
			}
		}
		reg.setCount()
		reg.Registers[indexOldest.Index] = false
		regInfo := reg.GetRegister(n, exp)
		v := indexOldest.UsingNode.Value.(*parser.VarBlock)
		switch v.Define.Value.(type) {
		case *parser.VarBlock:
			v.Offset = v.Define.Value.(*parser.VarBlock).Offset
		case *parser.ArgBlock:
			v.Offset = v.Define.Value.(*parser.ArgBlock).Offset
		}
		addr := ""
		if v.Offset < 0 {
			addr = "[ebp" + strconv.FormatInt(int64(v.Offset), 10) + "]"
		} else if v.Offset == 0 {
			addr = "[ebp]"
		} else {
			addr = "[ebp+" + strconv.FormatInt(int64(v.Offset), 10) + "]"
		}
		result := getLengthName(v.Type.Size()) + addr
		regInfo.StoreCode = "mov " + result + ", " + indexOldest.Name + "; 溢出到局部变量栈"
	}
	regInfo = nil
	return
}

// FreeRegister 释放寄存器
// 参数:
//   - n: 当前AST节点
//   - exp: 表达式
func (reg *Register) FreeRegister(exp *parser.Expression) {
	// 创建寄存器索引

	// 增加分配索引
	reg.Index++

	// 初始化寄存器记录映射
	if reg.Record == nil {
		reg.Record = make(map[*parser.Expression]*Reg)
		return
	}

	// 初始化寄存器使用状态数组
	if reg.Registers == nil {
		reg.Registers = make([]bool, architectures[GoArch].RegisterCount)
	}

	// 如果该表达式没有分配寄存器，则直接返回
	if reg.Record[exp] == nil {
		return
	} else {
		// 释放寄存器
		regInfo := reg.Record[exp]
		reg.setCount()
		reg.Registers[regInfo.RegIndex] = false
		if _, ok := regInfo.UsingNode.Value.(*parser.VarBlock); !ok || exp.Father == nil {
			regInfo.Destroyed = true
			delete(reg.Record, exp)
		}
	}
}

// isVarNotNeed 检查变量是否不再需要
// 参数:
//   - n: 节点
//   - now: 当前节点
//
// 返回:
//   - use: 是否还在使用
func (reg *Register) isVarNotNeed(r *Reg, now *parser.Node) (use bool) {
	v := r.UsingNode.Value.(*parser.VarBlock)
	var vd *parser.VarBlock
	if v.Define != nil {
		vd = v.Define.Value.(*parser.VarBlock)
	} else {
		vd = v
	}
	var f *parser.Node
	// 子级别查询
	for i := 0; i < len(now.Children); i++ {
		if reg.isVarUse(v, now.Children[i]) {
			use = true
			return
		}
	}

	// 同级别查询
	waitFindSelf := true
	for i := 0; i < len(r.UsingNode.Children); i++ {
		if r.UsingNode.Children[i].Value == vd {
			waitFindSelf = false
		}
		if !waitFindSelf {
			if reg.isVarUse(v, r.UsingNode.Children[i]) {
				use = true
				return
			}
		}
	}

	for f = now; f != nil; f = f.Father {
		for i := 0; i < len(f.Children); i++ {
			if reg.isVarUse(v, f.Children[i]) {
				use = true
				return
			}
		}
	}
	return
}

// isVarUse 检查变量是否在节点中被使用
// 参数:
//   - v: 变量块
//   - n: 节点
//
// 返回:
//   - use: 是否被使用
func (reg *Register) isVarUse(v *parser.VarBlock, n *parser.Node) (use bool) {
	switch n.Value.(type) {
	case *parser.VarBlock:
		varBlock := n.Value.(*parser.VarBlock)
		return varBlock.Value.FindVar(v)
	case *parser.CallBlock:
		for _, arg := range n.Value.(*parser.CallBlock).Args {
			return arg.Value != nil && arg.Value.FindVar(v)
		}
	case *parser.IfBlock:
		return n.Value.(*parser.IfBlock).Condition.FindVar(v)
	}
	for i := 0; i < len(n.Children); i++ {
		if reg.isVarUse(v, n.Children[i]) {
			return true
		}
	}
	return
}

func (reg *Register) ReuseNode(n *parser.Node) (regInfo *Reg) {
	for _, r := range reg.Record {
		if r.UsingNode == n && !r.Destroyed {
			return r
		}
	}
	return nil
}

func (reg *Register) Reuse(n any) (regInfo *Reg) {
	for _, r := range reg.Record {
		nPtr := (*uintptr)(unsafe.Pointer(uintptr(unsafe.Pointer(&n)) + unsafe.Sizeof(uintptr(0))))
		unPtr := (*uintptr)(unsafe.Pointer(uintptr(unsafe.Pointer(&r.UsingNode.Value)) + unsafe.Sizeof(uintptr(0))))
		if unPtr == nPtr && !r.Destroyed {
			return r
		}
	}
	return nil
}

func (reg *Register) setCount() {
	c := 0
	for _, r := range reg.Record {
		if !r.Destroyed {
			c++
		}
	}
}
