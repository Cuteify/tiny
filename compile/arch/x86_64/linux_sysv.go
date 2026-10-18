package x86_64

import (
	"cuteify/compile/arch"
	"cuteify/compile/context"
	"cuteify/compile/regmgr"
	"cuteify/parser"
	typeSys "cuteify/type"
	"cuteify/utils"
	"strings"
	"strconv"
)

// sysvArgRegs System V AMD64 ABI å‚æ•°å¯„å­˜å™¨ï¼ˆç¬¬1-6ä¸ªå‚æ•°ï¼‰
var sysvArgRegs = []string{"RDI", "RSI", "RDX", "RCX", "R8", "R9"}

// sysvCalleeSaved System V ABI çš„ callee-save å¯„å­˜å™¨
var sysvCalleeSaved = []string{"RBX", "R12", "R13", "R14", "R15"}

// SysV å®ç° x86_64 System V AMD64 ABI è°ƒç”¨çº¦å®šã€‚
type SysV struct {
	ctx *context.Context
	*x86_64Ops
}

func NewSysV(ctx *context.Context) *SysV {
	a := &SysV{
		ctx:       ctx,
		x86_64Ops: newOps(ctx, sysvCalleeSaved),
	}
	regs := cloneRegs(Regs, sysvCalleeSaved)
	ctx.Reg = regmgr.NewRegMgr(regs)
	ctx.PointerSize = 8
	ctx.Is64Bit = true
	ctx.StackAlignment = 16
	ctx.ThisSlot = -48 // Prologue å°† this ä¿å­˜åˆ° [rbp-48]
	return a
}

// Info è¿”å›è°ƒç”¨çº¦å®šçš„åç§°
func (a *SysV) Info() string { return "x86_64 System V AMD64 ABI" }

// rbpOffset è¿”å› rbp ç›¸å¯¹åœ°å€ï¼ˆæ­£åç§»ç”¨ +ï¼Œè´Ÿåç§»ç”¨ -ï¼‰
func rbpOffset(offset int) string {
	if offset >= 0 {
		return "[rbp+" + strconv.Itoa(offset) + "]"
	}
	return "[rbp-" + strconv.Itoa(-offset) + "]"
}

// SetArgsOffset å°†å‚æ•°åç§»ä»è°ƒç”¨è€…å¸§ä½ç½®åˆ·æ–°ä¸º callee-local ä½ç½®
func (a *SysV) SetArgsOffset(fn *parser.FuncBlock) { setArgsOffset(fn) }

// Prologue å‡½æ•°å‰åºä»£ç 
func (a *SysV) Prologue(fn *parser.FuncBlock) (code string) {
	if fn == nil {
		panic("å†…éƒ¨é”™è¯¯")
	}

	// è®¾ç½®å‚æ•°åç§»é‡ï¼ˆcallee å±€éƒ¨å˜é‡åŒº rbp-48 èµ·ï¼Œå¦‚ C/Rustï¼‰
	setArgsOffset(fn)

	code += utils.Format("push rbp")
	code += utils.Format("mov rbp, rsp")

	// å›ºå®šä¿å­˜æ‰€æœ‰ callee-save å¯„å­˜å™¨ï¼ˆä¸ä¾èµ–åˆ†é…å™¨è®°å½•ï¼Œä¿è¯ç¡®å®šæ€§å’Œæ ˆå¸ƒå±€ä¸€è‡´æ€§ï¼‰
	csRegs := a.CalleeSaveRegs()
	for _, regName := range csRegs {
		code += utils.Format("push " + regName + "; ä¿å­˜" + regName)
	}

	// å‚æ•°æ§½æ‰“åŒ…åŒºåº•ç•Œï¼ˆè§ setArgsOffsetï¼šæ§½ä½å‘ä¸Šç”Ÿé•¿ï¼Œé¦–å‚ @-48ï¼Œ
	// åç»­å„å‚æ•°æ•´ä½“ä¸‹ç§»æœ¬å‚æ•°å¤§å°ï¼‰ã€‚å±€éƒ¨å˜é‡å¿…é¡»ä»è¯¥åº•ç•Œç»§ç»­å‘ä¸‹åˆ†é…ï¼Œ
	// å¦åˆ™ä¼šä¸æœ€åä¸€ä¸ªå‚æ•°æ§½é‡å ã€‚ç­‰ä»·å…³ç³»ï¼šå…¨ 8 å­—èŠ‚å‚æ•°æ—¶
	// åº•ç•Œ = -40 - Î£sizeï¼Œä¸æ—§å…¬å¼ä¸€è‡´ï¼›é¦–å‚æ•°ä¸è¶³ 8 å­—èŠ‚æ—¶æ—§å…¬å¼ä¼šåæµ…ã€‚
	argsBottom := -8 * len(csRegs)
	if len(fn.Args) > 0 {
		first := -48
		if fn.Class != nil {
			first = -56
		}
		rest := 0
		for i := 1; i < len(fn.Args); i++ {
			rest += fn.Args[i].Type.Size()
		}
		argsBottom = first - rest
	} else if fn.Class != nil {
		argsBottom = -48 // ä»… this æŒ‡é’ˆ @-48
	}

	a.ctx.StackSize = arch.SetupVarOffsets(a.ctx.Now, a.ctx.StackAlignment, argsBottom)

	// é¢„ç•™å¤§å€¼è¿”å›æ§½ï¼šå®¹å™¨ 24B + R10 ä¿å­˜ 8Bï¼›ç»“æ„ä½“æŒ‰æ§½æ•°ï¼ˆSize/8ï¼‰è®¡ç®—
	retBytes := 24
	if arch.FuncReturnsLarge(fn) {
		retBytes = arch.ArgSlots(fn.Return[0]) * 8
	}
	a.ctx.RetSlot = -(a.ctx.StackSize) - retBytes - 8
	a.ctx.StackSize += retBytes + 8

	// ç¼–è¯‘æœŸ 16 å­—èŠ‚å¯¹é½ï¼šcall å‹è¿”å›åœ°å€(-8) + push rbp(-8) + 5 callee-save(-40) = -56
	// RSP = RBP - 40 - StackSizeï¼Œéœ€ StackSize â‰¡ 8 (mod 16) ä½¿ RSP â‰¡ 0 (mod 16)
	totalPushed := 8 + 8 + 8*len(csRegs) // return addr + rbp + 5 callee-saves = 56
	need := (16 - (totalPushed % 16)) % 16 // = 8
	if a.ctx.StackSize%16 != need {
		a.ctx.StackSize += (need - a.ctx.StackSize%16 + 16) % 16
	}

	if a.ctx.StackSize > 0 {
		code += utils.Format("sub rsp, " + strconv.Itoa(a.ctx.StackSize) + "; åˆ†é…å±€éƒ¨å˜é‡ç©ºé—´(" + strconv.Itoa(a.ctx.StackSize) + "å­—èŠ‚, å«å¯¹é½)")
	}

	// å¤§å€¼è¿”å›å‡½æ•°ï¼šä¿å­˜è°ƒç”¨è€…ä¼ å…¥çš„è¿”å›æ§½åœ°å€ï¼ˆR10ï¼‰
	if arch.FuncReturnsLarge(fn) {
		code += utils.Format("mov QWORD [rbp" + strconv.Itoa(a.ctx.RetSlot+retBytes) + "], R10; ä¿å­˜è¿”å›æ§½åœ°å€")
	}

	// å°†å¯„å­˜å™¨å‚æ•°ä¿å­˜åˆ°æ ˆä¸Šï¼ˆSysV ABI: RDI, RSI, RDX, RCX, R8, R9ï¼‰
	// ä¿å­˜åˆ° callee è‡ªå·±çš„å±€éƒ¨å˜é‡åŒºï¼ˆå¦‚ C/Rustï¼‰ï¼Œä¸å†™å…¥è°ƒç”¨è€…æ ˆå¸§
	argRegIdx := 0
	stackArgBase := 16
	if fn.Class != nil {
		// this æŒ‡é’ˆä¿å­˜åˆ° [rbp-48]ï¼ˆcallee å±€éƒ¨å˜é‡åŒºé¡¶éƒ¨ï¼‰
		code += utils.Format("mov QWORD " + rbpOffset(-48) + ", " + sysvArgRegs[0] + "; this pointer")
		argRegIdx = 1
		stackArgBase = 24
	}

	// å…ˆæ¬ç§»æ ˆå‚æ•°ï¼ˆSysV ç¬¬ 7+ ä¸ªï¼‰ï¼šå…¶åŸå§‹ä½ç½®åœ¨ [rbp+16]ï¼ˆå« this æ—¶ [rbp+24]ï¼‰èµ·çš„
	// è°ƒç”¨è€…æ ˆå‚æ•°åŒºï¼Œæ¬åˆ° callee å±€éƒ¨å˜é‡åŒºçš„ç¼–è¯‘å™¨å‚æ•°æ§½ï¼ˆarg.Offsetï¼‰ã€‚
	{
		stackSlot := 0
		regIdx := argRegIdx
		for i := 0; i < len(fn.Args); i++ {
			arg := fn.Args[i]
			slots := arch.ArgSlots(arg.Type)
			if regIdx+slots-1 < len(sysvArgRegs) {
				regIdx += slots
				continue
			}
			for j := 0; j < slots; j++ {
				src := "[rbp+" + strconv.Itoa(stackArgBase+(stackSlot+j)*8) + "]"
				dst := rbpOffset(arg.Offset + j*8)
				code += utils.Format("mov RAX, " + src + "; ä¿å­˜æ ˆå‚æ•°" + strconv.Itoa(i) + "æ§½" + strconv.Itoa(j) + "åˆ°æ ˆ")
				code += utils.Format("mov " + dst + ", RAX")
			}
			stackSlot += slots
			regIdx += slots
		}
	}

	for i := 0; i < len(fn.Args); i++ {
		arg := fn.Args[i]
		slots := arch.ArgSlots(arg.Type)
		if slots > 1 {
			// å®¹å™¨ï¼ˆ3 æ§½ï¼‰/ å¤§ç»“æ„ä½“ï¼ˆå¤šæ§½ï¼‰å‚æ•°å è¿ç»­å¯„å­˜å™¨
			if argRegIdx+slots-1 < len(sysvArgRegs) {
				for j := 0; j < slots; j++ {
					regName := sysvArgRegs[argRegIdx+j]
					addr := rbpOffset(arg.Offset + j*8)
					code += utils.Format("mov QWORD " + addr + ", " + regName + "; ä¿å­˜å‚æ•°" + strconv.Itoa(i) + "æ§½" + strconv.Itoa(j) + "åˆ°æ ˆ")
				}
			}
			argRegIdx += slots
		} else {
			if argRegIdx < len(sysvArgRegs) {
				regName := sysvArgRegs[argRegIdx]
				addr := rbpOffset(arg.Offset)
				// çª„ç±»å‹ï¼ˆi32 ç­‰ï¼‰æŒ‰å®½åº¦ä¿å­˜ï¼Œé¿å…è¶Šç•Œè¦†ç›–ä¸‹ä¸€å‚æ•°æ§½
				size := arg.Type.Size()
				if size != 8 {
					regName = sysvWidthName(regName, size)
				}
				code += utils.Format("mov " + GetLenName(size) + " " + addr + ", " + regName + "; ä¿å­˜å‚æ•°" + strconv.Itoa(i) + "åˆ°æ ˆ")
			}
			argRegIdx++
		}
	}

	return code
}

// Epilogue å‡½æ•°ååºä»£ç (å…¬å…±è¿”å›ç‚¹)
func (a *SysV) Epilogue(fn *parser.FuncBlock) string {
	funcName := formatFuncName(fn)
	code := utils.Format("func_end_" + funcName + ":")

	// æ¸…ç†å±€éƒ¨å˜é‡ + å¯¹é½ paddingï¼ˆStackSize å·²å«ç¼–è¯‘æœŸå¯¹é½ï¼‰
	if a.ctx.StackSize > 0 {
		code += utils.Format("add rsp, " + strconv.Itoa(a.ctx.StackSize) + "; æ¸…ç†å±€éƒ¨å˜é‡ + å¯¹é½")
	}

	// æ¢å¤ callee-save å¯„å­˜å™¨(é€†åº)
	csRegs := a.CalleeSaveRegs()
	for i := len(csRegs) - 1; i >= 0; i-- {
		code += utils.Format("pop " + csRegs[i] + "; æ¢å¤" + csRegs[i])
	}

	code += utils.Format("leave; æ¢å¤æ ˆå¸§")
	code += utils.Format("ret")
	code += "\n"
	return code
}

// Call å‡½æ•°è°ƒç”¨ï¼ˆSysVï¼šå‰6ä¸ªå‚æ•°ç”¨å¯„å­˜å™¨ RDI/RSI/RDX/RCX/R8/R9ï¼Œå…¶ä½™å‹æ ˆï¼‰
func (a *SysV) Call(call *parser.CallBlock) (code string) {
	if call == nil || call.Func == nil {
		return ""
	}

	// å¤„ç† list æ–¹æ³•è°ƒç”¨ï¼ˆlen/cap/ptrï¼‰
	if call.ThisVar != nil && call.ThisVar.Type != nil &&
		call.ThisVar.Type.Kind() == "list" && len(call.Args) == 0 {
		methodName := call.Name.Last()
		var fieldOffset int
		switch methodName {
		case "len":
			fieldOffset = 8
		case "cap":
			fieldOffset = 16
		case "ptr":
			fieldOffset = 0
		default:
			goto normalCall
		}
		addr := GenListFieldAddr(a.ctx, call.ThisVar, fieldOffset)
		return utils.Format("mov rax, QWORD " + addr + "; " + methodName + "()")
	}

	// Interface dispatch: if receiver is an interface type, dispatch via vtable
	if call.ThisVar != nil && call.ThisVar.Type != nil {
		if ifaceType, ok := call.ThisVar.Type.(*typeSys.InterfaceType); ok {
			return a.interfaceDispatch(call, ifaceType)
		}
	}

normalCall:
	fn := call.Func

	// å¤§å€¼è¿”å›å‡½æ•°ï¼šé¢„ç•™è°ƒç”¨è€…è¿”å›æ§½åœ°å€ï¼ˆR10ï¼‰
	isContainerRet := arch.FuncReturnsLarge(call.Func)

	// åˆ¤æ–­æ˜¯å¦ä¸ºå‡½æ•°æŒ‡é’ˆé—´æ¥è°ƒç”¨
	isIndirect := call.ThisVar != nil && call.ThisVar.Type != nil &&
		call.ThisVar.Type.Kind() == "func"

	// ç»Ÿè®¡éœ€è¦å‹æ ˆçš„å‚æ•°ä¸ªæ•°ï¼ˆå®¹å™¨å‚æ•°å  3 ä¸ªå¯„å­˜å™¨/3 ä¸ªæ ˆæ§½ï¼‰
	argRegIdx := 0

	// this æŒ‡é’ˆä½œä¸ºç¬¬ä¸€ä¸ªå¯„å­˜å™¨å‚æ•°ï¼ˆå‡½æ•°æŒ‡é’ˆé—´æ¥è°ƒç”¨ä¸å‹ thisï¼‰
	if call.ThisVar != nil && !isIndirect {
		thisAddr := GenVarAddr(a.ctx, call.ThisVar)
		if call.ThisVar.Type != nil && !call.ThisVar.Type.IsPointer() {
			// å€¼è¯­ä¹‰ï¼šä¼ ç»“æ„ä½“åœ°å€ï¼ˆlea å–åœ°å€ï¼‰
			addrOnly := thisAddr[strings.Index(thisAddr, "["):]
			code += utils.Format("lea " + sysvArgRegs[0] + ", " + addrOnly + "; this pointer")
		} else {
			code += utils.Format("mov " + sysvArgRegs[0] + ", " + thisAddr + "; this pointer")
		}
		argRegIdx = 1
	}

	// é¢„è®¡ç®—æ¯ä¸ªå‚æ•°çš„å¯„å­˜å™¨åŒºé—´
	argRegStart := make([]int, len(call.Args))
	cursor := argRegIdx
	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		argRegStart[i] = cursor
		cursor += arch.ArgSlots(arg.Type)
	}

	// æ ˆå‚æ•°å¯¹é½ï¼ˆrsp 16 å­—èŠ‚å¯¹é½ï¼‰
	stackArgs := 0
	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		need := arch.ArgSlots(arg.Type)
		if argRegStart[i]+need > len(sysvArgRegs) {
			stackArgs += need
		}
	}
	if stackArgs > 0 {
		if stackArgs%2 != 0 {
			code += utils.Format("sub rsp, 8; align stack for stack args")
		}
	}

	// å‹æ ˆå‚æ•°ï¼ˆä»å³åˆ°å·¦ï¼Œå®¹å™¨å‹ 3 æ§½ï¼šcap/len/ptrï¼Œptr æœ€åå‹è½åœ¨ä½åœ°å€ [rbp+16] æ§½ï¼‰
	for i := len(call.Args) - 1; i >= 0; i-- {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		need := arch.ArgSlots(arg.Type)
		if argRegStart[i]+need > len(sysvArgRegs) {
			if arch.IsListLikeType(arg.Type) {
				code += a.pushContainer(arg.Value, "å‚æ•°"+strconv.Itoa(i))
			} else {
				code += a.Exp(arg.Value, "push", "å‚æ•°"+strconv.Itoa(i))
			}
		}
	}

	// å¯„å­˜å™¨å‚æ•°ï¼šé¢„åˆ†é…å›ºå®š bufferï¼Œæ¯ä¸ªå‚æ•°æ±‚å€¼åç›´æ¥å†™å…¥ buffer[i]ã€‚
	// buffer åœ¨ RSP ä¸‹æ–¹ï¼ŒåµŒå¥— call çš„ buffer ä¹Ÿåœ¨ RSP ä¸‹æ–¹ä½†å„è‡ªå¹³è¡¡ï¼ˆsub/add æˆå¯¹ï¼‰ï¼Œ
	// æ‰€ä»¥ä¸» buffer çš„åç§»ä¸å—åµŒå¥— call å½±å“ã€‚
	// è£…è½½åˆ°å¯„å­˜å™¨åé‡Šæ”¾ bufferã€‚
	numRegArgs := 0
	cursor = argRegIdx
	for i := 0; i < len(call.Args); i++ {
		arg := call.Args[i]
		if arg == nil {
			continue
		}
		slots := arch.ArgSlots(arg.Type)
		if cursor+slots <= len(sysvArgRegs) {
			numRegArgs += slots
		}
		cursor += slots
	}
	if numRegArgs > 0 {
		bufferBytes := numRegArgs * 8
		if bufferBytes%16 != 0 {
			bufferBytes += 8
		}
		code += utils.Format("sub rsp, " + strconv.Itoa(bufferBytes) + "; register args buffer")
		// æ±‚å€¼æ¯ä¸ªå‚æ•°ï¼Œç›´æ¥å†™å…¥ buffer æ§½ä½
		cursor = argRegIdx
		bufIdx := 0
		ps := a.ctx.PointerSize
		ln := a.ctx.Arch.LengthName(ps)
		for i := 0; i < len(call.Args); i++ {
			arg := call.Args[i]
			if arg == nil {
				continue
			}
			slots := arch.ArgSlots(arg.Type)
			if cursor+slots <= len(sysvArgRegs) {
				bufOff := bufIdx * 8
				if arch.IsListLikeType(arg.Type) {
					// å®¹å™¨ç›´æ¥å†™ bufferï¼šptrâ†’[bufOff], lenâ†’[bufOff+8], capâ†’[bufOff+16]
					exp := arg.Value
					if exp == nil {
						code += utils.Format("mov QWORD [rsp+"+strconv.Itoa(bufOff)+"], 0")
						code += utils.Format("mov QWORD [rsp+"+strconv.Itoa(bufOff+8)+"], 0")
						code += utils.Format("mov QWORD [rsp+"+strconv.Itoa(bufOff+16)+"], 0")
					} else if exp.Call != nil {
						// åµŒå¥—è°ƒç”¨ï¼šå…ˆ callï¼ˆç»“æœåœ¨ RetSlotï¼‰ï¼Œå†ä» RetSlot å†™åˆ° buffer
						code += a.Call(exp.Call)
						code += utils.Format("mov RAX, " + ln + " [rbp"+strconv.Itoa(a.ctx.RetSlot)+"]")
						code += utils.Format("mov " + ln + " [rsp+"+strconv.Itoa(bufOff)+"], RAX")
						code += utils.Format("mov RAX, " + ln + " [rbp"+strconv.Itoa(a.ctx.RetSlot+ps)+"]")
						code += utils.Format("mov " + ln + " [rsp+"+strconv.Itoa(bufOff+ps)+"], RAX")
						code += utils.Format("mov RAX, " + ln + " [rbp"+strconv.Itoa(a.ctx.RetSlot+2*ps)+"]")
						code += utils.Format("mov " + ln + " [rsp+"+strconv.Itoa(bufOff+2*ps)+"], RAX")
					} else if exp.IsConst() {
						label := "0"
						if exp.StringVal != "" {
							label = a.stringLabel(exp.StringVal)
						}
						slen := len(exp.StringVal)
						code += utils.Format("mov QWORD [rsp+"+strconv.Itoa(bufOff)+"], "+label+"; ptr")
						code += utils.Format("mov QWORD [rsp+"+strconv.Itoa(bufOff+8)+"], "+strconv.Itoa(slen)+"; len")
						code += utils.Format("mov QWORD [rsp+"+strconv.Itoa(bufOff+16)+"], "+strconv.Itoa(slen)+"; cap")
					} else if exp.Var != nil {
						src := stripOuterBrackets(GenVarAddr(a.ctx, exp.Var))
						code += utils.Format("mov RAX, " + ln + " ["+src+"]")
						code += utils.Format("mov " + ln + " [rsp+"+strconv.Itoa(bufOff)+"], RAX")
						code += utils.Format("mov RAX, " + ln + " ["+src+"+"+strconv.Itoa(ps)+"]")
						code += utils.Format("mov " + ln + " [rsp+"+strconv.Itoa(bufOff+ps)+"], RAX")
						code += utils.Format("mov RAX, " + ln + " ["+src+"+"+strconv.Itoa(2*ps)+"]")
						code += utils.Format("mov " + ln + " [rsp+"+strconv.Itoa(bufOff+2*ps)+"], RAX")
					} else {
						code += utils.Format("mov QWORD [rsp+"+strconv.Itoa(bufOff)+"], 0")
						code += utils.Format("mov QWORD [rsp+"+strconv.Itoa(bufOff+8)+"], 0")
						code += utils.Format("mov QWORD [rsp+"+strconv.Itoa(bufOff+16)+"], 0")
					}
					bufIdx += slots
				} else {
					// æ ‡é‡ç›´æ¥å†™ buffer
					code += a.Exp(arg.Value, "QWORD [rsp+"+strconv.Itoa(bufOff)+"]", "å‚æ•°"+strconv.Itoa(i))
					bufIdx += slots
				}
			}
			cursor += slots
		}
		// ä» buffer è£…è½½åˆ°å¯„å­˜å™¨
		cursor = argRegIdx
		bufIdx = 0
		for i := 0; i < len(call.Args); i++ {
			arg := call.Args[i]
			if arg == nil {
				continue
			}
			slots := arch.ArgSlots(arg.Type)
			if cursor+slots <= len(sysvArgRegs) {
				for k := 0; k < slots; k++ {
					bufOff := (bufIdx + k) * 8
					code += utils.Format("mov " + sysvArgRegs[cursor+k] + ", QWORD [rsp+" + strconv.Itoa(bufOff) + "]; è£…è½½å‚æ•°" + strconv.Itoa(i))
				}
				bufIdx += slots
			}
			cursor += slots
		}
		code += utils.Format("add rsp, " + strconv.Itoa(bufferBytes) + "; é‡Šæ”¾å¯„å­˜å™¨å‚æ•° buffer")
	}

	if isContainerRet {
		code += utils.Format("lea R10, [rbp" + strconv.Itoa(a.ctx.RetSlot) + "]; å¤§å€¼è¿”å›æ§½åœ°å€")
	}

	// å˜å‚æ‰“åŒ…ï¼šå°†å˜å‚å‚æ•°æ‰“åŒ…ä¸º []T ä¼ é€’ï¼ˆåœ¨ call ä¹‹å‰ç”Ÿæˆï¼‰
	var variadicArrayBytes int
	if call.IsVariadic && len(call.VariadicArgs) > 0 {
		// è·å–å˜å‚å…ƒç´ ç±»å‹ï¼ˆcall.VariadicType æ˜¯ []Tï¼Œéœ€è¦å– Elem()ï¼‰
		elemType := call.VariadicType
		if lt, ok := elemType.(*typeSys.ListType); ok {
			elemType = lt.Elem()
		}
		elemSize := elemType.Size()
		if elemSize <= 0 {
			elemSize = 8
		}
		count := len(call.VariadicArgs)
		variadicArrayBytes = count * elemSize

		// åœ¨æ ˆä¸Šåˆ†é…ä¸´æ—¶æ•°ç»„
		if variadicArrayBytes > 0 {
			code += utils.Format("sub rsp, " + strconv.Itoa(variadicArrayBytes) + "; variadic array space")
		}

		// å°†æ¯ä¸ªå˜å‚å‚æ•°å­˜å…¥æ•°ç»„
		for i, varg := range call.VariadicArgs {
			offset := i * elemSize
			expCode := a.Exp(varg.Value, "RAX", "variadic "+strconv.Itoa(i))
			var storeCode string
			if elemSize == 8 {
				storeCode = utils.Format("mov QWORD [rsp+" + strconv.Itoa(offset) + "], RAX; variadic " + strconv.Itoa(i))
			} else if elemSize == 4 {
				storeCode = utils.Format("mov DWORD [rsp+" + strconv.Itoa(offset) + "], EAX; variadic " + strconv.Itoa(i))
			}
			code += expCode
			code += storeCode
		}

		// å°† slice {ptr, len, cap} æ”¾å…¥ä¸‹ä¸€ä¸ªå¯ç”¨çš„å¯„å­˜å™¨æˆ–æ ˆ
		// SysV ABI: RDI RSI RDX RCX R8 R9
		// variadic slice å  3 ä¸ª slots (ptr=8, len=8, cap=8)
		sliceRegs := []string{"RDI", "RSI", "RDX", "RCX", "R8", "R9"}
		usedRegs := 0
		for i := 0; i < len(call.Args) && i < len(sliceRegs); i++ {
			usedRegs++
		}
		if usedRegs+3 <= len(sliceRegs) {
			code += utils.Format("lea " + sliceRegs[usedRegs] + ", [rsp]; variadic ptr")
			code += utils.Format("mov " + sliceRegs[usedRegs+1] + ", " + strconv.Itoa(count) + "; variadic len")
			code += utils.Format("mov " + sliceRegs[usedRegs+2] + ", " + strconv.Itoa(count) + "; variadic cap")
		} else {
			code += utils.Format("push " + strconv.Itoa(count) + "; variadic cap")
			code += utils.Format("push " + strconv.Itoa(count) + "; variadic len")
			code += utils.Format("push rsp; variadic ptr")
			stackArgs += 3
		}
	}

	if isIndirect {
		thisAddr := GenVarAddr(a.ctx, call.ThisVar)
		code += utils.Format("mov rax, QWORD " + thisAddr + "; åŠ è½½å‡½æ•°æŒ‡é’ˆ")
		code += utils.Format("call rax; é—´æ¥è°ƒç”¨")
	} else {
		name := formatFuncName(fn)
		code += utils.Format("call " + name)
	}

	// æ¸…ç†æ ˆå‚æ•°
	if stackArgs > 0 {
		totalStackArgs := stackArgs * 8
		if stackArgs%2 != 0 {
			totalStackArgs += 8
		}
		code += utils.Format("add rsp, " + strconv.Itoa(totalStackArgs) + "; clean stack args")
	}

	// æ¸…ç†å˜å‚æ•°ç»„
	if variadicArrayBytes > 0 {
		code += utils.Format("add rsp, " + strconv.Itoa(variadicArrayBytes) + "; clean variadic array")
	}

	return code
}

// stripOuterBrackets å»æ‰å®½åº¦å‰ç¼€ä¸å¤–å±‚æ–¹æ‹¬å·ï¼šQWORD[rbp-96] â†’ rbp-96
func stripOuterBrackets(addr string) string {
	addr = strings.TrimSpace(addr)
	for _, p := range []string{"BYTE", "WORD", "DWORD", "QWORD"} {
		if strings.HasPrefix(addr, p) {
			addr = strings.TrimSpace(addr[len(p):])
			break
		}
	}
	if len(addr) >= 2 && strings.HasPrefix(addr, "[") && strings.HasSuffix(addr, "]") {
		return addr[1 : len(addr)-1]
	}
	return addr
}

// interfaceDispatch generates indirect call via vtable for interface method dispatch.
// Layout: interface var = {vtable_ptr, data_ptr} at [rbp+offset].
// Vtable layout: [type_info | method_0 | method_1 | ...].
func (a *SysV) interfaceDispatch(call *parser.CallBlock, ifaceType *typeSys.InterfaceType) string {
	ps := a.ctx.PointerSize
	dq := "QWORD"
	if ps == 4 {
		dq = "DWORD"
	}

	// Get interface variable address
	thisAddr := GenVarAddr(a.ctx, call.ThisVar)
	thisBase := stripOuterBrackets(thisAddr)

	// Method name from call
	methodName := call.Name.Last()

	// Find method index in interface
	methodIdx := -1
	for i, m := range ifaceType.InterfaceMethods {
		if m.Name == methodName {
			methodIdx = i
			break
		}
	}
	if methodIdx < 0 {
		return "; interface dispatch: unknown method " + methodName + "\n"
	}

	// Vtable method offset: ps (type_info) + methodIdx * ps
	vtableMethodOff := ps + methodIdx*ps

	var code string

	// 1. Load vtable_ptr from interface variable (first slot)
	vtableReg := "R11"
	code += utils.Format("mov " + vtableReg + ", " + dq + " [" + thisBase + "]; vtable_ptr")

	// 2. Load data_ptr from interface variable (second slot) - this is the this pointer
	thisReg := "RDI" // first argument in SysV
	code += utils.Format("mov " + thisReg + ", " + dq + " [" + thisBase + "+" + strconv.Itoa(ps) + "]; data_ptr (this)")

	// 3. Set R10 (return slot) for methods returning large values (string/list)
	if methodIdx >= 0 && methodIdx < len(ifaceType.InterfaceMethods) {
		mret := ifaceType.InterfaceMethods[methodIdx].Returns
		if len(mret) > 0 && mret[0] != nil && arch.IsListLikeType(mret[0]) {
			code += utils.Format("lea R10, [rbp" + strconv.Itoa(a.ctx.RetSlot) + "]; å¤§å€¼è¿”å›æ§½åœ°å€ (interface)")
		} else if len(mret) > 0 && mret[0] != nil && mret[0].Size() > ps && !(mret[0].Size() == 8 && (mret[0].Type() == "i64" || mret[0].Type() == "u64" || mret[0].Type() == "f64")) {
			code += utils.Format("lea R10, [rbp" + strconv.Itoa(a.ctx.RetSlot) + "]; å¤§å€¼è¿”å›æ§½åœ°å€ (interface)")
		}
	}

	// 4. Load function pointer from vtable and call indirectly
	code += utils.Format("call " + dq + " [" + vtableReg + "+" + strconv.Itoa(vtableMethodOff) + "]; interface dispatch: " + methodName)

	code += utils.Format("; interface dispatch: " + methodName + "\n")
	return code
}

// Return å‡½æ•°è¿”å›
func (a *SysV) Return(ret *parser.ReturnBlock) (code string) {
	code = a.returnValue(ret)
	code += a.returnJump()
	return code
}

// stringLabel è·å–/æ³¨å†Œå­—ç¬¦ä¸²å¸¸é‡æ ‡ç­¾
func (a *SysV) stringLabel(val string) string {
	if label, ok := a.ctx.StringConsts[val]; ok {
		return label
	}
	a.ctx.StrCount++
	label := "str_" + strconv.Itoa(a.ctx.StrCount)
	a.ctx.StringConsts[val] = label
	return label
}

// loadContainer3 å®¹å™¨ï¼ˆlist/stringï¼‰å®å‚è£…è½½åˆ° 3 ä¸ªè¿ç»­å¯„å­˜å™¨
func (a *SysV) loadContainer3(exp *parser.Expression, regs []string, desc string) string {
	ps := a.ctx.PointerSize
	ln := a.ctx.Arch.LengthName(ps)
	if exp == nil {
		return ""
	}
	// åµŒå¥—è°ƒç”¨ï¼šå…ˆ callï¼ˆè¿”å›å€¼åœ¨æœ¬å¸§è¿”å›æ§½ï¼‰ï¼Œå†ä»è¿”å›æ§½è¯»ä¸‰æ§½
	if exp.Call != nil {
		code := a.Call(exp.Call)Áî0Æ©¿Ğ xk¶Or‘3N{‘°eO[SpÆ¶—rcj¤-´ØÜO_a¸)È¹àºfF¦jİ
0ûiVVm’bá<.&E5§ğc}¯¡¼„"IÃ\¶ã1’’^)C;_İö¬Gc¶¦"=¨f‘èÓVfzf×‘¦¶
`ôîÆİû+_”!|¡¬ÂT>zMtxà–Ã»÷&«ş¨ ºYs[ÍœáDgÊ =Èß«ÛòÇR|‘TÉò/!âíd¹&Wˆéñ5xò$w*©U™
¤Ğç#A¥*Ğ1ñù+Ù½^.MuSÁıÚ®¾Ş{]™}I#ro¡ïÇ1ØqëD—:`xë8Ôá	…ÔF&ªŞL£æG}5÷'çËœÂ-Ô[rÜa,â¿æ3k‡aôc{]FŞ=sôÎ¢–‹ÖÃõ8seö¶p÷ÇÀ'Kı&Û  ç@·Z#°Z¦ ¦Ğ”}0ß”`³P×ÒkÔ‚ƒ2$fgø„]~ùìßxÓ-èç*·+yTİy»Ôâdìùt´ëğ®z¢&ô!„Y»<Ğá<±Æt,Z—îpU)Øœ•”‰ãòØÏ[İ¡I’"TêHíè7*UGï"*³§2"©œQ~¸q_§S‡“ú´òÉ	Ó:ók·yùvÑªğk)‰t-ù=mĞUd²Ó®<¹èpG…èÕ';Öè®BmkòáSOÁù4ªºàACw¥(¯¯œ’ŒkÔ¯9&eÁãY qÿ,‘œ¼¶§n¦‡5ö‚!sœ.8F™%¥–|hMÄÃ99†ÀÆßÈ”Ç«vı’åè5tùh4Î3‡4‚ÒÇ)_TÚ˜ËtK…”Ì¹(ûtGi‡Ô<|J~¿™2Ç„“»Õ*fÅR`PØ#Ù:-â*»i™fç”CåU¹¼p¦„¥'<ƒãŒVAíô}ÍŠ»ı•¼¾H;Mš!~^Û“‚èR]u„ª #{ìaÓÍ´ísÃÑu›¿8T¸?å£Ní|¼ó"ÙàÓüì3Æ1MÉ±ğ9ÎµÁÒ÷úBÑ·H~Àõ„‘,ÄåÏÁa'>ÿå	Q²İ)·ÿ*àqq.½~wQêiˆç<QQÖPtKÕ<-zs¡®¨8ÊR¬C°xÉÔ¸¡Ùœ#êHæc€°†B”îø-~OOñTí>7á½1Ïuyö<½Æ†émcnvåQVn4*PıÅ²é——“Ò•7Ò>‡Â‘nõmŠ•¶©:O= eÉg«Óæeß´Ä²* à´‹3/'0Õµ„Û¬ìÈ;Å8ÿUçşÖÇ†2í#7L¥GÅæ®açŒÉ‡_E[´ ÌÖe“æÅÀ[ø¡ƒfåû#®[Îh¹\DFŸøójXnÜa*PzT½¨e)šÿ*985ÅO?(ÇuUã'ÀØûüï/IûùÑ‰‡9jg{nyÙ‘šóŞFİ_å!fö{*Ş´Éú· £ä`S{ãüÀÍ8-ñ$ÓôÃ=¼XĞY#nş%6RCëBmàÙs8XŸ¶FyÏAñ¡SY‰¬x6f;£¡ÌÙW¼˜İ©Ç#ê¢ÿxl‹Våò,H<ÙÕ> Ñîü&|°íõÅ¤ Óˆ6Á‰çˆ€$7£ë³k—…ÔW£øŠÕvCXqhúâÁàËÇÙ™õ$–2¹]Š`[ZXÎïGIíBİšÈpßzñ5‰…_0•>5sÙ±Øó0HåìJ5+lE&¦+ÈRõkgÌşG`ëYƒ¶KE:
† ÿÔÄ©†ˆêÂ%4ÅÀ“ò·z·a*5O´±WŠşÓ˜ceˆ§ÙbjîYÁ%½T9E(&CÙ×:ä—nÌ7—k/õƒ-›Ş·OªeÀiTè3ª5vˆíÎÈÅY_õ«ÍôI*('¢s‰;X×ZZiçüîÊôõo¡H Szßè&OÜ–’P=f^|L¾GâxŞşL! ¦ÒŞ4¶ü£v©%×Õ‹Š‚»)œÂ€à[Á?fÕÄ­ÙÛ&èVk;ª{‚ĞBm‹dJa'u‘@áªÕáŸPú‰ÓøVoŒ‡äÍX½à¦Ÿwe«©hàŸ›/àÊµ­¶n„2·ØéàäŠı“çdúpZTÒÙö¾47µs2ıª¬N<o…AKBİ§€¸ŒüV*ì`»ğ²{z}´½fd»	Æ+˜<{J=½ãÚm¬kI¾9ÌØ¾6ˆäõHö:œïáW+)v<®ô²ØÃ›~V4z%Ñ=-7.ÅDD¾ƒú4ã¹`Â^o«¿¿˜vñÄË×/¶Ş¹“³éªD
r>¬¥Ÿå"»ÙÎˆB_"öÍŠÎL{ŞY ú48à!ôÒğLM8ûÚüV=ªB°ÅXº\dórÛv²i9@VZkâà×ËpT${ş§›©»ÕC|­4œáÅLh(ÃLÀº.æ\¤ê@º/ä˜işó¨ı×ŒIèåƒ%Rß”ÍífÚZ­As³éÊßÂ½}éB¾H.xu±“Kñ2£Ñ¿›˜•‡/S©we1Ï²Ö•!+ìR½§­QŒç0Å>W@3c&öi;Êù“/ØÃ>°6¨­›OVÎvµÚ˜Qqe3gÃ_ª¥@\¬S¸ë—uW¡İëç?Š[l¾Ó¼‡’Õ©¨mE˜óWÒ1Ğ]hA˜«ä¦5æ<TcpËÊÿ£øÂ.Y½gc¶(º^°ÏÔ…áÂSˆHz§OıĞßÎ›ò èó¨6#.¶øoåZè‚ã$tï³_Õ|}s[§¥;„‡g]D‚YšÀÖôwkMC˜ó#UOÕiÖPtzTPêÙŸSC«ß,¶Ã¥´€¨ÉvYğ q¡1û0ÆrHÓIöÈê~Í+ÎñÃ½‹™İŸ½ôwÛº6¢BñìQ›ø©ã¬ëCøıUÑíîñğn/ÂZí~OôauUÁWëúZ§‰¶}™„ë.ù0}ÿ—D¢>§2öÕ´Zó“ ü¥¥‚gêÆğNåQVçİÎ4$ "JĞ÷DEœÏÒít˜ Ó:#Õ¹a\Û\?¦GÛéäŞß×MÃ3SôE´1áLÚ00ªA·µØÊacUy©_Ïã®’tñ©‰jœMš2J¥³£µì:^œÅ0-ª…´»ˆhònVñıß£«e•eyáö˜«Öº¸òÅå1¯ÏçŞ¼“äŸ
ô§zª±ÓÆ±ü)£‡B‚é¬
ø¨¤”'ÚDqeñµ†šn­åHHÖÈ'úúªë=bA_#‡}r›µ	jä+¿±½ùãâaFª]¸²sÅŠ‹ô¶¶ŒŞm¥
4ãƒ!ÿ½­ò6ôz¡G2>÷òÌvSĞ=ÂoÑ;ñO–¿³å÷…“å§ÒÔ´Æ’y'	ß¥›ß^¬4mw¦Ô¤Õ*Å®Òã˜ÍÚzÅúÇô63 ‹6Nl'ÀgÖh´§£Œj®‘†Oñ,<j#û+Œ·¬Û`a8ùêY«K­a+†¨mRPº|fè!--YO«jjj?A“tQ·-MŒ={€(ö(O²à&ã|·³ÂÎöOÑU³¶Öü±¥øºâêÁ$áZım]3‚L´Ö¿¥ F-EuyMç¿öÉiÈ™ë€ï“oƒó¢½·f¸/BõÜÏü¡‰AÈpË26šcş˜öÌ!>N³½ÌçéÿÔ¿ß÷J‹ ”WıIı$ßÂê|Ô“:(ğ¿[1ß•!ø;%4õÛNú›K^.)lSè£áÛ]!Œ…@»Ï³†øGšà—PÆ0•´D5†hşFAœ¨¢P›åy-¯jc,êQüÿ‡I¸"}øs–RõqOéŸ‘TäUÍºÖÂ’›tœó©öo…á×¤QøHÂs€®Z#—?ô$_`¬h£÷MƒÍ€5rïsÚêvJµëEB‡e ÁˆÈô”¶Ğíek³3] '»¿ƒ	8¿˜€ Ø8‡Ñ?ÓĞ¬Àdªò|I‹@ú
§¿]Pa\2öY_ï^˜`ò‚‚g#0æĞ‚ËfŒUQ¯Lù
JòbJEœ—Û€]JNù¸ó	ë! ½\Á^ cbMèp‚¤pëÚbÔ:‘4f]ç…Ï‘ÓàÂ³°ÔÇ$–Z¬ìº=Í8d/LSÜ™tm†ïöQ2åñUà¦:?VÆıàõß!cjvŸÄ
´qM3ÄCµ:²œŞ›İÃ¶¸TC$D1PnÜñ$»ë5’'µ[H¹ºeV
Ü