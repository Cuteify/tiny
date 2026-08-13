package x86

// 寄存器类别位定义
const (
	ClassGPR uint32 = 1 << iota // 通用寄存器
	ClassDiv                    // 除法专用寄存器（EAX, EDX）
)
