package compile

// Architecture defines the CPU architecture and its registers.
type Architecture struct {
	Name          string   // The name of the architecture.
	Registers     []string // List of registers for the architecture.
	RegisterCount int      // The total number of registers.
}

// Define architectures and their registers.
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
		Name: "RISC-V",
		Registers: []string{
			"x0", "x1", "x2", "x3", "x4", "x5", "x6", "x7",
			"x8", "x9", "x10", "x11", "x12", "x13", "x14", "x15",
			"x16", "x17", "x18", "x19", "x20", "x21", "x22", "x23",
			"x24", "x25", "x26", "x27", "x28", "x29", "x30", "x31",
		},
		RegisterCount: 32,
	},
}

type Register struct {
	Record        map[string]*Reg
	Registers     []bool
	RegisterCount int
	Index         int
}

type Reg struct {
	BeforeCode string
	AfterCode  string
	RegName    string
	RegIndex   int
	Index      int
	Occupie    bool
	Name       string
}

func (reg *Register) GetRegister(name string) (regInfo *Reg) {
	reg.Index++
	if reg.Record == nil {
		reg.Record = make(map[string]*Reg)
	}
	if reg.Registers == nil {
		reg.Registers = make([]bool, architectures[GoArch].RegisterCount)
	}
	if reg.Record[name] != nil {
		regInfo = reg.Record[name]
		regInfo.Index = reg.Index
		regInfo.Name = name
		return
	}
	if architectures[GoArch].RegisterCount > reg.RegisterCount {
		for i := reg.RegisterCount; i < architectures[GoArch].RegisterCount; i++ {
			if reg.Registers[i] == false {
				reg.Record[name] = &Reg{}
				reg.Record[name].RegName = architectures[GoArch].Registers[i]
				reg.Registers[i] = true
				regInfo = reg.Record[name]
				regInfo.Index = reg.Index
				regInfo.RegIndex = i
				regInfo.Name = name
				reg.RegisterCount++
				return
			}
		}
	} else {
		var indexOldest *Reg
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
		return
	}
	regInfo = nil
	return
}

func (reg *Register) FreeRegister(name string) {
	reg.Index++
	if reg.Record == nil {
		reg.Record = make(map[string]*Reg)
		return
	}
	if reg.Registers == nil {
		reg.Registers = make([]bool, architectures[GoArch].RegisterCount)
	}
	if reg.Record[name] == nil {
		return
	} else {
		regInfo := reg.Record[name]
		reg.RegisterCount--
		reg.Registers[regInfo.RegIndex] = false
		delete(reg.Record, name)
	}
}
