section .bss
    __global_std_memory_gFreeHeads resq 1
    __global_std_memory_gLeaks resq 1
    __global_std_memory_gLeakSizes resq 1
    __global_std_memory_gAllLeaks resq 1
    __global_std_memory_gAllLeakSizes resq 1
    __global__home_gx_Desktop_tiny_selfhost_lexer_gKwList resb 24
    __global__home_gx_Desktop_tiny_selfhost_lexer_gKwReady resb 1
    __global__home_gx_Desktop_tiny_selfhost_lexer_gDelimList resb 24
    __global__home_gx_Desktop_tiny_selfhost_lexer_gDelimReady resb 1
section .data
    __global_std_memory_TINY_MAX dq 1024
    __global_std_memory_SMALL_MAX dq 4096
    __global_std_memory_MIDDLE_MAX dq 65536
    __global_std_memory_LARGE_MAX dq 262144
    __global_std_memory_CHUNK_SIZE dq 65536
    __global_std_memory_IS_FREE dq 1
    __global_std_memory_PREV_FREE dq 2
    __global_std_memory_RC_BIT dq 4
    __global_std_memory_FLAG_MASK dq 7
    __global_std_memory_HDR_SIZE dq 2
    __global_std_memory_PTR_SIZE dq 8
    __global_std_memory_gAllocCount dq 0
    __global_std_memory_gFreeCount dq 0
    __global_std_memory_gLeakCount dq 0
    __global_std_memory_gAllAllocCount dq 0
    __global_std_memory_gAllFreeCount dq 0
    __global_std_memory_gAllLeakCount dq 0
    __global_std_memory_gAllLeakOverflow dq 0
    __global_std_memory_gDropCount dq 0
    __global_std_console_ESC dq 27
    __global_std_console_STDOUT_FD dq 1
    __global_std_console_COLOR_BLACK dq 0
    __global_std_console_COLOR_RED dq 1
    __global_std_console_COLOR_GREEN dq 2
    __global_std_console_COLOR_YELLOW dq 3
    __global_std_console_COLOR_BLUE dq 4
    __global_std_console_COLOR_MAGENTA dq 5
    __global_std_console_COLOR_CYAN dq 6
    __global_std_console_COLOR_WHITE dq 7
    __global_std_console_COLOR_BRIGHT_BLACK dq 8
    __global_std_console_COLOR_BRIGHT_RED dq 9
    __global_std_console_COLOR_BRIGHT_GREEN dq 10
    __global_std_console_COLOR_BRIGHT_YELLOW dq 11
    __global_std_console_COLOR_BRIGHT_BLUE dq 12
    __global_std_console_COLOR_BRIGHT_MAGENTA dq 13
    __global_std_console_COLOR_BRIGHT_CYAN dq 14
    __global_std_console_COLOR_BRIGHT_WHITE dq 15
    __global_std_console_STYLE_BOLD dq 1
    __global_std_console_STYLE_DIM dq 2
    __global_std_console_STYLE_ITALIC dq 3
    __global_std_console_STYLE_UNDERLINE dq 4
    __global_std_console_STYLE_BLINK dq 5
    __global_std_console_STYLE_REVERSE dq 7
    __global_std_console_STYLE_HIDDEN dq 8
    __global_std_console_STYLE_STRIKETHROUGH dq 9
    __global_std_console_CURSOR_UP dq 65
    __global_std_console_CURSOR_DOWN dq 66
    __global_std_console_CURSOR_RIGHT dq 67
    __global_std_console_CURSOR_LEFT dq 68
    __global_std_console_gTrueColor dq 0
    __global_std_console_g256Color dq 0
    __global_std_console_gMouse dq 0
    __global_std_console_gSixel dq 0
    __global_std_console_gTermDetected dq 0
    __global_std_console_COLOR_AUTO dq 0
    __global_std_console_COLOR_16 dq 1
    __global_std_console_COLOR_256 dq 2
    __global_std_console_COLOR_TRUE dq 3
    __global_std_console_FEATURE_AUTO dq 0
    __global_std_console_FEATURE_ON dq 1
    __global_std_console_FEATURE_OFF dq -1
    __global_std_console_FG_BLACK dq 0
    __global_std_console_FG_RED dq 1
    __global_std_console_FG_GREEN dq 2
    __global_std_console_FG_YELLOW dq 3
    __global_std_console_FG_BLUE dq 4
    __global_std_console_FG_MAGENTA dq 5
    __global_std_console_FG_CYAN dq 6
    __global_std_console_FG_WHITE dq 7
    __global_std_console_FG_BRIGHT_BLACK dq 8
    __global_std_console_FG_BRIGHT_RED dq 9
    __global_std_console_FG_BRIGHT_GREEN dq 10
    __global_std_console_FG_BRIGHT_YELLOW dq 11
    __global_std_console_FG_BRIGHT_BLUE dq 12
    __global_std_console_FG_BRIGHT_MAGENTA dq 13
    __global_std_console_FG_BRIGHT_CYAN dq 14
    __global_std_console_FG_BRIGHT_WHITE dq 15
    __global_std_console_BG_BLACK dq 0
    __global_std_console_BG_RED dq 1
    __global_std_console_BG_GREEN dq 2
    __global_std_console_BG_YELLOW dq 3
    __global_std_console_BG_BLUE dq 4
    __global_std_console_BG_MAGENTA dq 5
    __global_std_console_BG_CYAN dq 6
    __global_std_console_BG_WHITE dq 7
    __global_std_console_BG_BRIGHT_BLACK dq 8
    __global_std_console_BG_BRIGHT_RED dq 9
    __global_std_console_BG_BRIGHT_GREEN dq 10
    __global_std_console_BG_BRIGHT_YELLOW dq 11
    __global_std_console_BG_BRIGHT_BLUE dq 12
    __global_std_console_BG_BRIGHT_MAGENTA dq 13
    __global_std_console_BG_BRIGHT_CYAN dq 14
    __global_std_console_BG_BRIGHT_WHITE dq 15
    __global_std_console_C256_RED dq 196
    __global_std_console_C256_GREEN dq 46
    __global_std_console_C256_BLUE dq 21
    __global_std_console_C256_YELLOW dq 226
    __global_std_console_C256_MAGENTA dq 201
    __global_std_console_C256_CYAN dq 51
    __global_std_console_C256_ORANGE dq 208
    __global_std_console_C256_PINK dq 213
    __global_std_console_C256_LIME dq 154
    __global_std_console_C256_SKY dq 117
    __global_std_console_C256_WHITE dq 231
    __global_std_console_C256_GRAY dq 243
    __global_std_console_gAdvancedEnabled dq 1
    __global_std_console_gColorMode dq 0
    __global_std_console_gMouseMode dq 0
    __global_std_console_gSixelMode dq 0
    __global_std_console_STDIN dd 0
    __global_std_console_STDOUT dd 1
    __global_std_console_STDERR dd 2
    __global__home_gx_Desktop_tiny_selfhost_lexer_NONE dq 0
    __global__home_gx_Desktop_tiny_selfhost_lexer_STRING dq 1
    __global__home_gx_Desktop_tiny_selfhost_lexer_KEYWORD dq 2
    __global__home_gx_Desktop_tiny_selfhost_lexer_DELIMITER dq 3
    __global__home_gx_Desktop_tiny_selfhost_lexer_NUMBER dq 4
    __global__home_gx_Desktop_tiny_selfhost_lexer_NAME dq 5
    __global__home_gx_Desktop_tiny_selfhost_lexer_PREFETCH_CAP dq 24
    __global__home_gx_Desktop_tiny_selfhost_parse_ExprConst dq 0
    __global__home_gx_Desktop_tiny_selfhost_parse_ExprVar dq 1
    __global__home_gx_Desktop_tiny_selfhost_parse_ExprCall dq 2
    __global__home_gx_Desktop_tiny_selfhost_parse_ExprAnonCall dq 3
    __global__home_gx_Desktop_tiny_selfhost_parse_ExprBinOp dq 4
    __global__home_gx_Desktop_tiny_selfhost_parse_ExprUnaryOp dq 5
    __global__home_gx_Desktop_tiny_selfhost_parse_ExprSlice dq 6
    __global__home_gx_Desktop_tiny_selfhost_parse_ExprArrayLit dq 7
    __global__home_gx_Desktop_tiny_selfhost_parse_ExprMapLit dq 8
    __global__home_gx_Desktop_tiny_selfhost_parse_ExprStatement dq 9
    __global__home_gx_Desktop_tiny_selfhost_parse_Num dq 0
    __global__home_gx_Desktop_tiny_selfhost_parse_Ident dq 1
    __global__home_gx_Desktop_tiny_selfhost_parse_Op dq 2
    __global__home_gx_Desktop_tiny_selfhost_parse_LParen dq 3
    __global__home_gx_Desktop_tiny_selfhost_parse_RParen dq 4
    __global__home_gx_Desktop_tiny_selfhost_parse_OK dq 0
    __global__home_gx_Desktop_tiny_selfhost_parse_ETOK dq 1
    __global__home_gx_Desktop_tiny_selfhost_parse_EDECL dq 2
    __global__home_gx_Desktop_tiny_selfhost_parse_ETYPE dq 3
    __global__home_gx_Desktop_tiny_selfhost_parse_ESTMT dq 4
    __global__home_gx_Desktop_tiny_selfhost_parse_EEXPR dq 5
section .text progbits alloc exec nowrite align=16
global _start

section .text._home_gx_Desktop_tiny_selfhost_cmd_parsedump_a progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_cmd_parsedump_a
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_cmd_parsedump_a
_home_gx_Desktop_tiny_selfhost_cmd_parsedump_a:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], 0; gc: zero exit slot sf
    mov QWORD [rbp-64], 0; gc: zero exit slot p
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_1
    mov QWORD [rsp+0+8], 53
    mov QWORD [rsp+0+16], 53
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_testutil_loadSourceFile
    mov QWORD[rbp-48], RAX
; 设置变量sf
    sub rsp, 32; register args buffer
    mov RBX, QWORD [RBP-48]
    test RBX, RBX
    je _panic_nil_deref
    mov RCX, RBX; copySlots base
    mov RAX, QWORD [RCX]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RCX+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RCX+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_newLexer
    mov QWORD[rbp-56], RAX
; 设置变量lex
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_parse_newParser
    mov QWORD[rbp-64], RAX
; 设置变量p




    for_1: ; for循环开始


    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_parse_Parser_next
; condition
    test RAX, RAX
    jz end_if_1
    if_1:
    jmp for_1_end
    end_if_1:
    for_1_continue:


    jmp for_1; for循环
    for_1_end: ; for循环结束
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_cmd_parsedump_a
    func_end__home_gx_Desktop_tiny_selfhost_cmd_parsedump_a:
    push rax; 保存返回值
    push rdx; 保存返回值(第二槽)
    ; gc: free sf
    lea RDI, [rbp-48]
    call std_memory_freeSlot
    ; gc: free p
    mov RDI, QWORD [rbp-64]
    test RDI, RDI
    jz gc_drop_skip1
    call __gc_drop__Parser
    mov QWORD [rbp-64], 0
    gc_drop_skip1:
    pop rdx; 恢复返回值(第二槽)
    pop rax; 恢复返回值
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.main progbits alloc exec nowrite align=16
global main
; ==============================
; Function: main
main:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-104], 0; gc ret scratch 清零
    call _home_gx_Desktop_tiny_selfhost_cmd_parsedump_a
    call std_memory_dumpAllocator
    call std_memory_releaseAllLeakTracker
    call std_memory_releaseLeakTracker
    call std_memory_trim
    call std_memory_dumpAllocator
    call std_memory_reportAllAllocCount
    mov QWORD[rbp-48], RAX
; 设置变量a
    call std_memory_reportAllFreeCount
    mov QWORD[rbp-56], RAX
; 设置变量f
    call std_memory_reportAllLeaks
    mov QWORD[rbp-64], RAX
; 设置变量lk
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_2
    mov QWORD [rsp+0+8], 20
    mov QWORD [rsp+0+16], 20
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_print
    sub rsp, 32; register args buffer
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 10
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-96]; 大值返回槽地址
    call std_strings_toString
    mov RAX, QWORD [rbp-96]; gc ret scratch ptr
    mov QWORD [rbp-104], RAX; gc ret scratch store
    mov RAX, QWORD [RBP-96]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RBP-96+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RBP-96+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_print
    ; gc: call temp free $cond0
    lea RDI, [rbp-104]
    call std_memory_freeSlot
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_3
    mov QWORD [rsp+0+8], 6
    mov QWORD [rsp+0+16], 6
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_print
    sub rsp, 32; register args buffer
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 10
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-96]; 大值返回槽地址
    call std_strings_toString
    mov RAX, QWORD [rbp-96]; gc ret scratch ptr
    mov QWORD [rbp-104], RAX; gc ret scratch store
    mov RAX, QWORD [RBP-96]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RBP-96+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RBP-96+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_print
    ; gc: call temp free $cond0
    lea RDI, [rbp-104]
    call std_memory_freeSlot
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_4
    mov QWORD [rsp+0+8], 7
    mov QWORD [rsp+0+16], 7
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_print
    sub rsp, 32; register args buffer
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 10
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-96]; 大值返回槽地址
    call std_strings_toString
    mov RAX, QWORD [rbp-96]; gc ret scratch ptr
    mov QWORD [rbp-104], RAX; gc ret scratch store
    mov RAX, QWORD [RBP-96]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RBP-96+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RBP-96+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_println
    ; gc: call temp free $cond0
    lea RDI, [rbp-104]
    call std_memory_freeSlot
    call std_memory_releaseAllLeakTracker
    call std_memory_releaseLeakTracker
    call std_memory_trim
    mov RAX, 0
; return值存入RAX
    jmp func_end_main
    func_end_main:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_testutil_loadSourceFile progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_testutil_loadSourceFile
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_testutil_loadSourceFile
_home_gx_Desktop_tiny_selfhost_testutil_loadSourceFile:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 168; 分配局部变量空间(168字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring
    mov QWORD[rbp-72], RAX
; 设置变量cpath
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], 2
; 参数0
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+8], RAX
; 参数1
    mov QWORD [rsp+16], 0
; 参数2
    mov QWORD [rsp+24], 0
; 参数3
    mov QWORD [rsp+32], 0
; 参数4
    mov QWORD [rsp+40], 0
; 参数5
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数3
    mov R8, QWORD [rsp+32]; 装载参数4
    mov R9, QWORD [rsp+40]; 装载参数5
    add rsp, 48; 释放寄存器参数 buffer
    call std_syscall_syscall64
    mov QWORD[rbp-80], RAX
; 设置变量rawfd
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    mov RDI, 32
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rbp-88], RBX
; 设置变量r
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0x43e0000000000000
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_2
    if_2:
    mov RBX, QWORD [RBP-88]
    test RBX, RBX
    je _panic_nil_deref
    mov QWORD QWORD[RBX], 0
    mov QWORD [RBX+8], 0
    mov QWORD [RBX+16], 0
; 设置变量r.Src
    mov RBX, QWORD [RBP-88]
    test RBX, RBX
    je _panic_nil_deref
    mov BYTE[RBX+24], 0
; 设置变量r.Ok
    mov RAX, QWORD[rbp-88]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_testutil_loadSourceFile
    end_if_2:
    mov RAX, QWORD[rbp-80]
    mov DWORD[rbp-92], EAX
; 设置变量srcfd
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 65536
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-100], RAX
; 设置变量buf
    mov QWORD[rbp-108], 0
; 设置变量pos




    for_2: ; for循环开始
    mov RAX, QWORD[rbp-108]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65536
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_2_end
    for_2_body:


    sub rsp, 32; register args buffer
    mov EAX, DWORD[rbp-92]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-100]
    mov RBX, QWORD[rbp-108]
    mov QWORD [rsp+8], RAX
    add QWORD [rsp+8], RBX
; 参数1
    mov RAX, QWORD[rbp-108]
    mov QWORD [rsp+16], 65536
    sub QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_syscall_read
    mov DWORD[rbp-112], EAX
; 设置变量n
    mov EAX, DWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_3
    if_3:
    jmp for_2_end
    end_if_3:
    mov RBX, QWORD[rbp-108]
    mov RBX, RBX
    mov EAX, DWORD[rbp-112]
    mov QWORD[rbp-108], RBX
    add QWORD[rbp-108], RAX
; 设置变量pos
    for_2_continue:


    jmp for_2; for循环
    for_2_end: ; for循环结束
    sub rsp, 16; register args buffer
    mov EAX, DWORD[rbp-92]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_close
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-108]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-120], RAX
; 设置变量dst
    mov RAX, QWORD[rbp-108]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_4
    if_4:
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-100]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-108]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_memcpy
    end_if_4:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-100]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    mov RBX, QWORD [RBP-88]
    test RBX, RBX
    je _panic_nil_deref
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-108]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-108]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-160]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-160]
    mov QWORD [RBX+0], RAX
    mov RAX, QWORD [RBP-160+8]
    mov QWORD [RBX+8], RAX
    mov RAX, QWORD [RBP-160+16]
    mov QWORD [RBX+16], RAX
; 设置变量r.Src
    mov RBX, QWORD [RBP-88]
    test RBX, RBX
    je _panic_nil_deref
    mov BYTE[RBX+24], 1
; 设置变量r.Ok
    mov RAX, QWORD[rbp-88]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_testutil_loadSourceFile
    func_end__home_gx_Desktop_tiny_selfhost_testutil_loadSourceFile:
    add rsp, 168; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_initFreeHeads progbits alloc exec nowrite align=16
global std_memory_initFreeHeads
; ==============================
; Function: std_memory_initFreeHeads
std_memory_initFreeHeads:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov RAX, QWORD[rel __global_std_memory_gFreeHeads]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_5
    if_5:
    jmp func_end_std_memory_initFreeHeads
    end_if_5:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-48], RAX
; 设置变量cur
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov RBX, 480
    mov QWORD [rsp+0], RAX
    add QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-56], RAX
; 设置变量nb
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
    mov RBX, 480
    add RCX, RBX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_6
    if_6:
    jmp func_end_std_memory_initFreeHeads
    end_if_6:
    mov RAX, QWORD[rbp-48]
    mov QWORD[rel __global_std_memory_gFreeHeads], RAX
; 设置变量gFreeHeads
    func_end_std_memory_initFreeHeads:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_blkSizeOfTiny progbits alloc exec nowrite align=16
global std_memory_blkSizeOfTiny
; ==============================
; Function: std_memory_blkSizeOfTiny
std_memory_blkSizeOfTiny:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_7
    if_7:
    mov RAX, 32
; return值存入RAX
    jmp func_end_std_memory_blkSizeOfTiny
    end_if_7:
    mov QWORD[rbp-56], 32
; 设置变量s
    mov QWORD[rbp-64], 0
; 设置变量i




    for_3: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_3_end
    for_3_body:


    mov RAX, QWORD[rbp-56]
    mov RBX, 3
    mov QWORD[rbp-72], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存移位计数
    mov cl, byte [rsp]
    sar QWORD[rbp-72], cl
    add rsp, 8; 清理移位计数
    pop RAX; 恢复RAX(左子结果)
; 设置变量step
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 16
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_8
    if_8:
    mov QWORD[rbp-72], 16
; 设置变量step
    end_if_8:
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-72]
    mov QWORD[rbp-56], RAX
    add QWORD[rbp-56], RBX
; 设置变量s
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量i
    for_3_continue:


    jmp for_3; for循环
    for_3_end: ; for循环结束
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RBX
    mov RBX, 1
    sub RAX, RBX
    mov RCX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RDX, 1
    sub RCX, RDX
    mov RBX, RCX
    not RBX
    and RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_blkSizeOfTiny
    func_end_std_memory_blkSizeOfTiny:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_blkSizeOfSmall progbits alloc exec nowrite align=16
global std_memory_blkSizeOfSmall
; ==============================
; Function: std_memory_blkSizeOfSmall
std_memory_blkSizeOfSmall:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_9
    if_9:
    mov RAX, 2048
; return值存入RAX
    jmp func_end_std_memory_blkSizeOfSmall
    end_if_9:
    mov RAX, 4096
; return值存入RAX
    jmp func_end_std_memory_blkSizeOfSmall
    func_end_std_memory_blkSizeOfSmall:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_blkSizeOfMiddle progbits alloc exec nowrite align=16
global std_memory_blkSizeOfMiddle
; ==============================
; Function: std_memory_blkSizeOfMiddle
std_memory_blkSizeOfMiddle:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD[rbp-56], 4096
; 设置变量s
    mov QWORD[rbp-64], 0
; 设置变量i




    for_4: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_4_end
    for_4_body:


    mov RAX, QWORD[rbp-56]
    mov RBX, 3
    push RBX; 暂存移位计数
    mov cl, byte [rsp]
    sar RAX, cl
    add rsp, 8; 清理移位计数
    add QWORD[rbp-56], RAX
; 设置变量s
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量i
    for_4_continue:


    jmp for_4; for循环
    for_4_end: ; for循环结束
    mov RAX, QWORD[rbp-56]
; return值存入RAX
    jmp func_end_std_memory_blkSizeOfMiddle
    func_end_std_memory_blkSizeOfMiddle:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_blkSizeOf progbits alloc exec nowrite align=16
global std_memory_blkSizeOf
; ==============================
; Function: std_memory_blkSizeOf
std_memory_blkSizeOf:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 33
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_10
    if_10:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOfTiny
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf
    end_if_10:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 35
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_11
    if_11:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov RCX, 34
    mov QWORD [rsp+0], RBX
    sub QWORD [rsp+0], RCX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOfSmall
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf
    end_if_11:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov RCX, 36
    mov QWORD [rsp+0], RBX
    sub QWORD [rsp+0], RCX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOfMiddle
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf
    func_end_std_memory_blkSizeOf:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_slotOfTiny progbits alloc exec nowrite align=16
global std_memory_slotOfTiny
; ==============================
; Function: std_memory_slotOfTiny
std_memory_slotOfTiny:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 32
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_12
    if_12:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_slotOfTiny
    end_if_12:
    mov QWORD[rbp-56], 32
; 设置变量s
    mov QWORD[rbp-64], 0
; 设置变量cls




    for_5: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 33
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_5_end
    for_5_body:


    mov RAX, QWORD[rbp-56]
    mov RBX, 3
    mov QWORD[rbp-72], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存移位计数
    mov cl, byte [rsp]
    sar QWORD[rbp-72], cl
    add rsp, 8; 清理移位计数
    pop RAX; 恢复RAX(左子结果)
; 设置变量step
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 16
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_13
    if_13:
    mov QWORD[rbp-72], 16
; 设置变量step
    end_if_13:
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-72]
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量next
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_14
    if_14:
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_slotOfTiny
    end_if_14:
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-56], RAX
; 设置变量s
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量cls
    for_5_continue:


    jmp for_5; for循环
    for_5_end: ; for循环结束
    mov RAX, 33
; return值存入RAX
    jmp func_end_std_memory_slotOfTiny
    func_end_std_memory_slotOfTiny:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_slotOfSmall progbits alloc exec nowrite align=16
global std_memory_slotOfSmall
; ==============================
; Function: std_memory_slotOfSmall
std_memory_slotOfSmall:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2048
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_15
    if_15:
    mov RAX, 34
; return值存入RAX
    jmp func_end_std_memory_slotOfSmall
    end_if_15:
    mov RAX, 35
; return值存入RAX
    jmp func_end_std_memory_slotOfSmall
    func_end_std_memory_slotOfSmall:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_slotOfMiddle progbits alloc exec nowrite align=16
global std_memory_slotOfMiddle
; ==============================
; Function: std_memory_slotOfMiddle
std_memory_slotOfMiddle:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 4096
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_16
    if_16:
    mov RAX, 36
; return值存入RAX
    jmp func_end_std_memory_slotOfMiddle
    end_if_16:
    mov QWORD[rbp-56], 4096
; 设置变量s
    mov QWORD[rbp-64], 0
; 设置变量cls




    for_6: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 23
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_6_end
    for_6_body:


    mov RAX, QWORD[rbp-56]
    mov RBX, 3
    push RBX; 暂存移位计数
    mov cl, byte [rsp]
    sar RAX, cl
    add rsp, 8; 清理移位计数
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-72], RBX
    add QWORD[rbp-72], RAX
; 设置变量next
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_17
    if_17:
    mov RBX, QWORD[rbp-64]
    mov RAX, 36
    add RAX, RBX
    mov RBX, 1
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_slotOfMiddle
    end_if_17:
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-56], RAX
; 设置变量s
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量cls
    for_6_continue:


    jmp for_6; for循环
    for_6_end: ; for循环结束
    mov RAX, 59
; return值存入RAX
    jmp func_end_std_memory_slotOfMiddle
    func_end_std_memory_slotOfMiddle:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_slotOf progbits alloc exec nowrite align=16
global std_memory_slotOf
; ==============================
; Function: std_memory_slotOf
std_memory_slotOf:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_TINY_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_18
    if_18:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfTiny
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_18:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_SMALL_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_19
    if_19:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfSmall
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_19:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_20
    if_20:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfMiddle
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_20:
    mov RAX, 60
; return值存入RAX
    jmp func_end_std_memory_slotOf
    func_end_std_memory_slotOf:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_headOf progbits alloc exec nowrite align=16
global std_memory_headOf
; ==============================
; Function: std_memory_headOf
std_memory_headOf:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
    mov RBX, 8
    imul RAX, RBX
    mov RBX, QWORD[rel __global_std_memory_gFreeHeads]
    mov QWORD[rbp-56], RBX
    add QWORD[rbp-56], RAX
; 设置变量_p
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_memory_headOf
    func_end_std_memory_headOf:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_setHead progbits alloc exec nowrite align=16
global std_memory_setHead
; ==============================
; Function: std_memory_setHead
std_memory_setHead:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-48]
    mov RBX, 8
    imul RAX, RBX
    mov RBX, QWORD[rel __global_std_memory_gFreeHeads]
    mov QWORD[rbp-64], RBX
    add QWORD[rbp-64], RAX
; 设置变量_p
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD[rbp-64]
    mov QWORD [RAX], RBX
; expression statement
    func_end_std_memory_setHead:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_freeListClassOf progbits alloc exec nowrite align=16
global std_memory_freeListClassOf
; ==============================
; Function: std_memory_freeListClassOf
std_memory_freeListClassOf:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOf
    mov QWORD[rbp-56], RAX
; 设置变量cls
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 60
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_21
    if_21:
    mov RAX, 60
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_21:




    for_7: ; for循环开始
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_7_end
    for_7_body:


    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOf
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_22
    if_22:
    mov RAX, QWORD[rbp-56]
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_22:
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD[rbp-56], RAX
    sub QWORD[rbp-56], RBX
; 设置变量cls
    for_7_continue:


    jmp for_7; for循环
    for_7_end: ; for循环结束
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOf
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_23
    if_23:
    mov RAX, 60
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_23:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    func_end_std_memory_freeListClassOf:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_insertFreeList progbits alloc exec nowrite align=16
global std_memory_insertFreeList
; ==============================
; Function: std_memory_insertFreeList
std_memory_insertFreeList:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov RCX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RBX, RCX
    not RBX
    mov QWORD[rbp-56], RAX
    and QWORD[rbp-56], RBX
; 设置变量size
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeListClassOf
    mov QWORD[rbp-64], RAX
; 设置变量cls
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 60
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_24
    if_24:
    jmp func_end_std_memory_insertFreeList
    end_if_24:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_headOf
    mov QWORD[rbp-72], RAX
; 设置变量oldHead
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeSetNext
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeSetPrev
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_25
    if_25:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeSetPrev
    end_if_25:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_setHead
    func_end_std_memory_insertFreeList:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_removeFreeList progbits alloc exec nowrite align=16
global std_memory_removeFreeList
; ==============================
; Function: std_memory_removeFreeList
std_memory_removeFreeList:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freePrev
    mov QWORD[rbp-56], RAX
; 设置变量prev
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeNext
    mov QWORD[rbp-64], RAX
; 设置变量next
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov RCX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RBX, RCX
    not RBX
    mov QWORD[rbp-72], RAX
    and QWORD[rbp-72], RBX
; 设置变量size
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeListClassOf
    mov QWORD[rbp-80], RAX
; 设置变量cls
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 60
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_26
    if_26:
    jmp func_end_std_memory_removeFreeList
    end_if_26:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je else_if_27
    if_27:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeSetNext
    jmp end_if_27
    else_if_27:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_setHead
    end_if_27:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_28
    if_28:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeSetPrev
    end_if_28:
    func_end_std_memory_removeFreeList:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_commit progbits alloc exec nowrite align=16
global std_memory_commit
; ==============================
; Function: std_memory_commit
std_memory_commit:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 248; 分配局部变量空间(248字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-64], RAX
; 设置变量chunk
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rel __global_std_memory_CHUNK_SIZE]
    mov QWORD [rsp+0], RAX
    add QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-72], RAX
; 设置变量nb
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-64]
    mov RAX, QWORD[rel __global_std_memory_CHUNK_SIZE]
    add RCX, RAX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_29
    if_29:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_commit
    end_if_29:
    mov QWORD[rbp-80], 0
; 设置变量prev
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-88], RAX
; 设置变量p
    mov RBX, QWORD[rbp-64]
    mov RAX, QWORD[rel __global_std_memory_CHUNK_SIZE]
    mov QWORD[rbp-96], RBX
    add QWORD[rbp-96], RAX
; 设置变量end
    mov QWORD[rbp-104], 0
; 设置变量firstPrevFree
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_30
    if_30:
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-112], RAX
    sub QWORD[rbp-112], RBX
; 设置变量_pfp
    mov RAX, QWORD[rbp-112]
    mov RAX, QWORD [RAX]
    mov QWORD[rbp-120], RAX
; 设置变量pf
    mov RAX, QWORD[rbp-120]
    mov RBX, QWORD[rel __global_std_memory_IS_FREE]
    and RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_31
    and_mid_2:
    mov RAX, QWORD[rbp-120]
    mov RDX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RBX, RDX
    not RBX
    and RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 32
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_31
    if_31:
    mov RBX, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD[rbp-104], RBX
; 设置变量firstPrevFree
    end_if_31:
    end_if_30:




    for_8: ; for循环开始
    mov RAX, QWORD[rbp-88]
    mov RDX, QWORD[rbp-56]
    add RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe for_8_end
    for_8_body:


    mov RBX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD[rbp-128], RBX
; 设置变量flags
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je else_if_32
    if_32:
    mov RDX, QWORD[rbp-128]
    mov RBX, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD[rbp-128], RDX
    or QWORD[rbp-128], RBX
; 设置变量flags
    jmp end_if_32
    else_if_32:
    mov RBX, QWORD[rbp-128]
    mov RDX, QWORD[rbp-104]
    mov QWORD[rbp-128], RBX
    or QWORD[rbp-128], RDX
; 设置变量flags
    end_if_32:
    mov RBX, QWORD[rbp-56]
    mov RDX, QWORD[rbp-128]
    mov QWORD[rbp-136], RBX
    or QWORD[rbp-136], RDX
; 设置变量full
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-88]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-136]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-88]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-136]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-88]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_insertFreeList
    mov RBX, QWORD[rbp-88]
    mov QWORD[rbp-80], RBX
; 设置变量prev
    mov RDX, QWORD[rbp-88]
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-88], RDX
    add QWORD[rbp-88], RBX
; 设置变量p
    for_8_continue:


    jmp for_8; for循环
    for_8_end: ; for循环结束
    mov RBX, QWORD[rbp-96]
    mov RDX, QWORD[rbp-88]
    mov QWORD[rbp-144], RBX
    sub QWORD[rbp-144], RDX
; 设置变量tail
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 32
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_33
    if_33:
    mov RBX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD[rbp-152], RBX
; 设置变量flags
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_34
    if_34:
    mov RDX, QWORD[rbp-152]
    mov RBX, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD[rbp-152], RDX
    or QWORD[rbp-152], RBX
; 设置变量flags
    end_if_34:
    mov RBX, QWORD[rbp-144]
    mov RDX, QWORD[rbp-152]
    mov QWORD[rbp-160], RBX
    or QWORD[rbp-160], RDX
; 设置变量full
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-88]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-160]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-88]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-160]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-88]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_insertFreeList
    jmp end_if_33
    else_if_33:
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_35
    and_mid_3:
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_35
    if_35:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_removeFreeList
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-168], RAX
; 设置变量prevRaw
    mov RDX, QWORD[rbp-168]
    mov RSI, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RBX, RSI
    not RBX
    mov QWORD[rbp-176], RDX
    and QWORD[rbp-176], RBX
; 设置变量prevPure
    mov RDX, QWORD[rbp-176]
    mov RSI, QWORD[rbp-144]
    mov QWORD[rbp-184], RDX
    add QWORD[rbp-184], RSI
; 设置变量newSize
    mov RBX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD[rbp-192], RBX
; 设置变量flags2
    mov RAX, QWORD[rbp-168]
    mov RDX, QWORD[rel __global_std_memory_PREV_FREE]
    and RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_36
    if_36:
    mov RDX, QWORD[rbp-192]
    mov RSI, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD[rbp-192], RDX
    or QWORD[rbp-192], RSI
; 设置变量flags2
    end_if_36:
    mov RDX, QWORD[rbp-184]
    mov RSI, QWORD[rbp-192]
    mov QWORD[rbp-200], RDX
    or QWORD[rbp-200], RSI
; 设置变量full2
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-200]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-200]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_insertFreeList
    end_if_35:
    end_if_33:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_headOf
; return值存入RAX
    jmp func_end_std_memory_commit
    func_end_std_memory_commit:
    add rsp, 248; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_coalesce progbits alloc exec nowrite align=16
global std_memory_coalesce
; ==============================
; Function: std_memory_coalesce
std_memory_coalesce:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 184; 分配局部变量空间(184字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-56], RAX
; 设置变量raw
    mov RAX, QWORD[rbp-56]
    mov RCX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RBX, RCX
    not RBX
    mov QWORD[rbp-64], RAX
    and QWORD[rbp-64], RBX
; 设置变量pure
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-72], RAX
; 设置变量brkTop
    mov RAX, QWORD[rbp-48]
    mov RCX, QWORD[rbp-64]
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RCX
; 设置变量nextBlk
    mov RAX, QWORD[rbp-80]
    mov RCX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RCX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_37
    if_37:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-88], RAX
; 设置变量ns
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_38
    and_mid_4:
    mov RAX, QWORD[rbp-88]
    mov RCX, QWORD[rel __global_std_memory_IS_FREE]
    and RAX, RCX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_38
    if_38:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_removeFreeList
    mov RBX, QWORD[rbp-88]
    mov RDX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RCX, RDX
    not RCX
    and RBX, RCX
    add QWORD[rbp-64], RBX
; 设置变量pure
    end_if_38:
    end_if_37:
    mov RAX, QWORD[rbp-56]
    mov RDX, QWORD[rel __global_std_memory_PREV_FREE]
    and RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je else_if_39
    if_39:
    mov RDX, QWORD[rbp-48]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-96], RDX
    sub QWORD[rbp-96], RBX
; 设置变量prevFooterP
    mov RBX, QWORD[rbp-96]
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-104], RAX
; 设置变量prevFooter
    mov RBX, QWORD[rbp-104]
    mov RDX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RCX, RDX
    not RCX
    mov QWORD[rbp-112], RBX
    and QWORD[rbp-112], RCX
; 设置变量prevSize
    mov RBX, QWORD[rbp-48]
    mov RDX, QWORD[rbp-112]
    mov QWORD[rbp-120], RBX
    sub QWORD[rbp-120], RDX
; 设置变量prevBlk
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-120]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_removeFreeList
    mov RDX, QWORD[rbp-104]
    mov RCX, QWORD[rel __global_std_memory_PREV_FREE]
    and RDX, RCX
    mov RCX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD[rbp-128], RDX
    or QWORD[rbp-128], RCX
; 设置变量mergedFlags
    mov RDX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-64]
    mov QWORD[rbp-64], RDX
    add QWORD[rbp-64], RBX
; 设置变量pure
    mov RBX, QWORD[rbp-120]
    mov QWORD[rbp-48], RBX
; 设置变量blk
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-128]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-128]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    jmp end_if_39
    else_if_39:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-64]
    mov RBX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-64]
    mov RBX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    end_if_39:
    mov RBX, QWORD[rbp-48]
    mov RDX, QWORD[rbp-64]
    mov QWORD[rbp-136], RBX
    add QWORD[rbp-136], RDX
; 设置变量nextAfter
    mov RAX, QWORD[rbp-136]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_40
    if_40:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-136]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-144], RAX
; 设置变量ns2
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_41
    if_41:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-136]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-144]
    mov RBX, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-136]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-144]
    mov RBX, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    end_if_41:
    end_if_40:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_coalesce
    func_end_std_memory_coalesce:
    add rsp, 184; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_malloc progbits alloc exec nowrite align=16
global std_memory_malloc
; ==============================
; Function: std_memory_malloc
std_memory_malloc:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 344; 分配局部变量空间(344字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    call std_memory_initFreeHeads
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, 2
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-56], RBX
    add QWORD[rbp-56], RAX
; 设置变量req
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RAX, 4
    mov QWORD[rbp-64], RBX
    push RAX; 保护RAX(左子结果)
    push RAX; 暂存乘数
    mov RAX, QWORD[rbp-64]
    imul RAX, qword [rsp]
    mov QWORD[rbp-64], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量minReq
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-64]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_42
    if_42:
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-56], RAX
; 设置变量req
    end_if_42:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_LARGE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_43
    if_43:
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RBX, RAX
    mov RAX, 1
    sub RBX, RAX
    mov RCX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RDX, 1
    sub RCX, RDX
    mov RAX, RCX
    not RAX
    mov QWORD[rbp-72], RBX
    and QWORD[rbp-72], RAX
; 设置变量aligned
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-80], RAX
; 设置变量old
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RBX
    add QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-88], RAX
; 设置变量nb
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
    mov RAX, QWORD[rbp-72]
    add RCX, RAX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_44
    if_44:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_44:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    mov RBX, QWORD[rbp-80]
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-96], RBX
    add QWORD[rbp-96], RAX
; 设置变量p
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackAllocAll
    mov RAX, QWORD[rbp-96]
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_43:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_45
    if_45:
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RBX, RAX
    mov RDX, 1
    sub RBX, RDX
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RSI, 1
    sub RDX, RSI
    mov RAX, RDX
    not RAX
    mov QWORD[rbp-104], RBX
    and QWORD[rbp-104], RAX
; 设置变量aligned
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-112], RAX
; 设置变量old
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-112]
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+0], RBX
    add QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-120], RAX
; 设置变量nb
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-112]
    mov RAX, QWORD[rbp-104]
    add RCX, RAX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_46
    if_46:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_46:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-112]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RBX, QWORD[rbp-104]
    mov RAX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RBX
    or QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-112]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RBX, QWORD[rbp-104]
    mov RAX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RBX
    or QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-112]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_coalesce
    mov QWORD[rbp-128], RAX
; 设置变量merged
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-128]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-136], RAX
; 设置变量mRaw
    mov RBX, QWORD[rbp-136]
    mov RDX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RAX, RDX
    not RAX
    mov QWORD[rbp-144], RBX
    and QWORD[rbp-144], RAX
; 设置变量mPure
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-128]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-144]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-128]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-144]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    mov RBX, QWORD[rbp-128]
    mov RDX, QWORD[rbp-144]
    mov QWORD[rbp-152], RBX
    add QWORD[rbp-152], RDX
; 设置变量nextM
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-160], RAX
; 设置变量brkTop
    mov RAX, QWORD[rbp-152]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-160]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_47
    if_47:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-152]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-168], RAX
; 设置变量ns
    mov RAX, QWORD[rbp-168]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_48
    if_48:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-152]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-168]
    mov RSI, QWORD[rel __global_std_memory_PREV_FREE]
    mov RBX, RSI
    not RBX
    mov QWORD [rsp+8], RDX
    and QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-152]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-168]
    mov RSI, QWORD[rel __global_std_memory_PREV_FREE]
    mov RBX, RSI
    not RBX
    mov QWORD [rsp+8], RDX
    and QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    end_if_48:
    end_if_47:
    mov RDX, QWORD[rbp-128]
    mov RSI, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-176], RDX
    add QWORD[rbp-176], RSI
; 设置变量lp
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-176]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackAllocAll
    mov RAX, QWORD[rbp-176]
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_45:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOf
    mov QWORD[rbp-184], RAX
; 设置变量cls
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-184]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOf
    mov QWORD[rbp-192], RAX
; 设置变量blkSize
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-184]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_headOf
    mov QWORD[rbp-200], RAX
; 设置变量head
    mov RAX, QWORD[rbp-200]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_49
    if_49:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-184]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-192]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_commit
    mov QWORD[rbp-200], RAX
; 设置变量head
    mov RAX, QWORD[rbp-200]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_50
    if_50:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_50:
    end_if_49:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-200]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeNext
    mov QWORD[rbp-208], RAX
; 设置变量next
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-184]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-208]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_setHead
    mov RAX, QWORD[rbp-208]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_51
    if_51:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-208]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeSetPrev
    end_if_51:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-200]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov RDX, RAX
    mov RSI, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RAX, RSI
    not RAX
    mov QWORD[rbp-216], RDX
    and QWORD[rbp-216], RAX
; 设置变量rawSize
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RAX, 4
    mov QWORD[rbp-224], RDX
    push RAX; 保护RAX(左子结果)
    push RAX; 暂存乘数
    mov RAX, QWORD[rbp-224]
    imul RAX, qword [rsp]
    mov QWORD[rbp-224], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量minBlk
    mov RAX, QWORD[rbp-224]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOf
    mov RCX, RAX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_52
    if_52:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOf
    mov QWORD[rbp-224], RAX
; 设置变量minBlk
    end_if_52:
    mov RBX, QWORD[rbp-216]
    mov QWORD[rbp-232], RBX
; 设置变量useSize
    mov QWORD[rbp-240], 0
; 设置变量rem
    mov RAX, QWORD[rbp-216]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-192]
    mov RDX, QWORD[rbp-224]
    add RCX, RDX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_53
    if_53:
    mov RBX, QWORD[rbp-192]
    mov QWORD[rbp-232], RBX
; 设置变量useSize
    mov RDX, QWORD[rbp-216]
    mov RSI, QWORD[rbp-192]
    mov QWORD[rbp-240], RDX
    sub QWORD[rbp-240], RSI
; 设置变量rem
    jmp end_if_53
    else_if_53:
    mov RAX, QWORD[rbp-216]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-192]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_54
    if_54:
    mov RBX, QWORD[rbp-192]
    mov QWORD[rbp-232], RBX
; 设置变量useSize
    end_if_54:
    end_if_53:
    mov RAX, QWORD[rbp-240]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-224]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_55
    if_55:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-200]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-232]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-200]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-232]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    mov RDX, QWORD[rbp-200]
    mov RSI, QWORD[rbp-232]
    mov QWORD[rbp-248], RDX
    add QWORD[rbp-248], RSI
; 设置变量remBlk
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-248]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-240]
    mov RSI, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RSI
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-248]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-240]
    mov RSI, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RSI
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-248]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_insertFreeList
    mov RDX, QWORD[rbp-248]
    mov RSI, QWORD[rbp-240]
    mov QWORD[rbp-256], RDX
    add QWORD[rbp-256], RSI
; 设置变量afterRem
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-264], RAX
; 设置变量brkRem
    mov RAX, QWORD[rbp-256]
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-264]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_56
    if_56:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-256]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-272], RAX
; 设置变量nsr
    mov RAX, QWORD[rbp-272]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_57
    if_57:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-256]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-272]
    mov RSI, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RSI
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-256]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-272]
    mov RSI, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RSI
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    end_if_57:
    end_if_56:
    jmp end_if_55
    else_if_55:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-200]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-232]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-200]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-232]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    end_if_55:
    mov RDX, QWORD[rbp-200]
    mov RSI, QWORD[rbp-232]
    mov QWORD[rbp-280], RDX
    add QWORD[rbp-280], RSI
; 设置变量nextBlk
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-288], RAX
; 设置变量brkTop
    mov RAX, QWORD[rbp-280]
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-288]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_58
    if_58:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-280]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-296], RAX
; 设置变量ns
    mov RAX, QWORD[rbp-296]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_59
    if_59:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-280]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-296]
    mov RSI, QWORD[rel __global_std_memory_PREV_FREE]
    mov RBX, RSI
    not RBX
    mov QWORD [rsp+8], RDX
    and QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-280]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-296]
    mov RSI, QWORD[rel __global_std_memory_PREV_FREE]
    mov RBX, RSI
    not RBX
    mov QWORD [rsp+8], RDX
    and QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    end_if_59:
    end_if_58:
    mov RDX, QWORD[rbp-200]
    mov RSI, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-304], RDX
    add QWORD[rbp-304], RSI
; 设置变量sp
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-304]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackAllocAll
    mov RAX, QWORD[rbp-304]
; return值存入RAX
    jmp func_end_std_memory_malloc
    func_end_std_memory_malloc:
    add rsp, 344; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_freeAt progbits alloc exec nowrite align=16
global std_memory_freeAt
; ==============================
; Function: std_memory_freeAt
std_memory_freeAt:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 152; 分配局部变量空间(152字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-56], RAX
; 设置变量raw
    mov RAX, QWORD[rbp-56]
    mov RCX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RBX, RCX
    not RBX
    mov QWORD[rbp-64], RAX
    and QWORD[rbp-64], RBX
; 设置变量pure
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_LARGE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_60
    if_60:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-72], RAX
; 设置变量cur
    mov RAX, QWORD[rbp-48]
    mov RCX, QWORD[rbp-64]
    add RAX, RCX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_61
    if_61:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeAt
    end_if_61:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_freeAt
    end_if_60:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_62
    if_62:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_coalesce
    mov QWORD[rbp-80], RAX
; 设置变量merged
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-88], RAX
; 设置变量mRaw
    mov RAX, QWORD[rbp-88]
    mov RCX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RBX, RCX
    not RBX
    mov QWORD[rbp-96], RAX
    and QWORD[rbp-96], RBX
; 设置变量mPure
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-104], RAX
; 设置变量cur
    mov RAX, QWORD[rbp-80]
    mov RCX, QWORD[rbp-96]
    add RAX, RCX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_63
    if_63:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeAt
    end_if_63:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_insertFreeList
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeAt
    end_if_62:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_coalesce
    mov QWORD[rbp-112], RAX
; 设置变量merged
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-112]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_insertFreeList
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeAt
    func_end_std_memory_freeAt:
    add rsp, 152; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_free progbits alloc exec nowrite align=16
global std_memory_free
; ==============================
; Function: std_memory_free
std_memory_free:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_64
    if_64:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_free
    end_if_64:
    mov RAX, QWORD[rel __global_std_memory_gAllLeaks]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_65
    and_mid_6:
    mov RAX, QWORD[rel __global_std_memory_gAllLeakOverflow]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_65
    and_mid_5:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_isTrackedAll
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_65
    if_65:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_free
    end_if_65:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_flagLoad
    mov QWORD[rbp-56], RAX
; 设置变量flags
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rel __global_std_memory_RC_BIT]
    and RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_66
    if_66:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcDec
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_free
    end_if_66:
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-64], RAX
    sub QWORD[rbp-64], RBX
; 设置变量base
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeAt
    mov BYTE[rbp-65], al
; 设置变量ok
    movzx RAX, BYTE[rbp-65]
; condition
    test RAX, RAX
    jz end_if_67
    if_67:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackFreeAll
    end_if_67:
    movzx RAX, BYTE[rbp-65]
; return值存入RAX
    jmp func_end_std_memory_free
    func_end_std_memory_free:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_freeSlot progbits alloc exec nowrite align=16
global std_memory_freeSlot
; ==============================
; Function: std_memory_freeSlot
std_memory_freeSlot:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
    mov RAX, QWORD [RAX]
    mov QWORD[rbp-56], RAX
; 设置变量p
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_68
    if_68:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeSlot
    end_if_68:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
; condition
    test RAX, RAX
    jz end_if_69
    if_69:
    mov RAX, 0
    mov RBX, QWORD[rbp-48]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeSlot
    end_if_69:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_freeSlot
    func_end_std_memory_freeSlot:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_realloc progbits alloc exec nowrite align=16
global std_memory_realloc
; ==============================
; Function: std_memory_realloc
std_memory_realloc:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 184; 分配局部变量空间(184字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_70
    if_70:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_70:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_71
    if_71:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_71:
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-64], RAX
    sub QWORD[rbp-64], RBX
; 设置变量blk
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov RCX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RBX, RCX
    not RBX
    mov QWORD[rbp-72], RAX
    and QWORD[rbp-72], RBX
; 设置变量oldPure
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RAX, 2
    imul RBX, RAX
    mov RCX, QWORD[rbp-56]
    mov QWORD[rbp-80], RCX
    add QWORD[rbp-80], RBX
; 设置变量req
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_72
    if_72:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_72:
    mov RCX, QWORD[rbp-64]
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-88], RCX
    add QWORD[rbp-88], RAX
; 设置变量nextBlk
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-96], RAX
; 设置变量brkTop
    mov RAX, QWORD[rbp-88]
    mov RCX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RCX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_73
    if_73:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-88]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-104], RAX
; 设置变量ns
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_74
    and_mid_7:
    mov RAX, QWORD[rbp-104]
    mov RCX, QWORD[rel __global_std_memory_IS_FREE]
    and RAX, RCX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_74
    if_74:
    mov RBX, QWORD[rbp-104]
    mov RDX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RCX, RDX
    not RCX
    and RBX, RCX
    mov RDX, QWORD[rbp-72]
    mov QWORD[rbp-112], RDX
    add QWORD[rbp-112], RBX
; 设置变量merged
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_75
    if_75:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-88]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_removeFreeList
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-112]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-112]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    mov RDX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-112]
    mov QWORD[rbp-120], RDX
    add QWORD[rbp-120], RBX
; 设置变量nn
    mov RAX, QWORD[rbp-120]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_76
    if_76:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-120]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-128], RAX
; 设置变量nn2
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_77
    if_77:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-120]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-128]
    mov RCX, QWORD[rel __global_std_memory_PREV_FREE]
    mov RBX, RCX
    not RBX
    mov QWORD [rsp+8], RDX
    and QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-120]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RCX, QWORD[rbp-128]
    mov RDX, QWORD[rel __global_std_memory_PREV_FREE]
    mov RBX, RDX
    not RBX
    mov QWORD [rsp+8], RCX
    and QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    end_if_77:
    end_if_76:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_75:
    end_if_74:
    end_if_73:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-136], RAX
; 设置变量np
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_78
    if_78:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_78:
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RAX, 2
    imul RBX, RAX
    mov RCX, QWORD[rbp-72]
    mov QWORD[rbp-144], RCX
    sub QWORD[rbp-144], RBX
; 设置变量copySize
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_79
    if_79:
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-144], RAX
; 设置变量copySize
    end_if_79:
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-136]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-144]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_memcpy
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    mov RAX, QWORD[rbp-136]
; return值存入RAX
    jmp func_end_std_memory_realloc
    func_end_std_memory_realloc:
    add rsp, 184; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_trim progbits alloc exec nowrite align=16
global std_memory_trim
; ==============================
; Function: std_memory_trim
std_memory_trim:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 152; 分配局部变量空间(152字节, 含对齐)
    mov QWORD[rbp-48], 0
; 设置变量total




    for_9: ; for循环开始


    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-56], RAX
; 设置变量top
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_80
    if_80:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_trim
    end_if_80:
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-64], RAX
    sub QWORD[rbp-64], RBX
; 设置变量footerAddr
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-72], RAX
; 设置变量_fp
    mov RBX, QWORD[rbp-72]
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-80], RAX
; 设置变量raw
    mov RBX, QWORD[rbp-80]
    mov RCX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RAX, RCX
    not RAX
    mov QWORD[rbp-88], RBX
    and QWORD[rbp-88], RAX
; 设置变量pure
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 32
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_81
    if_81:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_trim
    end_if_81:
    mov RBX, QWORD[rbp-56]
    mov RCX, QWORD[rbp-88]
    mov QWORD[rbp-96], RBX
    sub QWORD[rbp-96], RCX
; 设置变量blk
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_82
    if_82:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_trim
    end_if_82:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-104], RAX
; 设置变量hdr
    mov RAX, QWORD[rbp-104]
    mov RBX, QWORD[rel __global_std_memory_IS_FREE]
    and RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_83
    if_83:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_trim
    end_if_83:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_removeFreeList
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov RBX, QWORD[rbp-48]
    mov RCX, QWORD[rbp-88]
    mov QWORD[rbp-48], RBX
    add QWORD[rbp-48], RCX
; 设置变量total
    for_9_continue:


    jmp for_9; for循环
    for_9_end: ; for循环结束
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_trim
    func_end_std_memory_trim:
    add rsp, 152; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_ws progbits alloc exec nowrite align=16
global std_memory_ws
; ==============================
; Function: std_memory_ws
std_memory_ws:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    lea RAX, [rbp-64]
    mov QWORD[rbp-72], RAX
; 设置变量h
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_syscall_write
    func_end_std_memory_ws:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_wnl progbits alloc exec nowrite align=16
global std_memory_wnl
; ==============================
; Function: std_memory_wnl
std_memory_wnl:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_5
    mov QWORD [rsp+0+8], 1
    mov QWORD [rsp+0+16], 1
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    func_end_std_memory_wnl:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_wu progbits alloc exec nowrite align=16
global std_memory_wu
; ==============================
; Function: std_memory_wu
std_memory_wu:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 168; 分配局部变量空间(168字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 32
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-56], RAX
; 设置变量buf
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_84
    if_84:
    jmp func_end_std_memory_wu
    end_if_84:
    mov QWORD[rbp-64], 0
; 设置变量i
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_85
    if_85:
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-72], RAX
; 设置变量_b
    mov RAX, 48
    mov RBX, QWORD[rbp-72]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov QWORD [rsp+16], 1
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_syscall_write
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    jmp func_end_std_memory_wu
    end_if_85:
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-80], RAX
; 设置变量x




    for_10: ; for循环开始
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_10_end
    for_10_body:


    mov RAX, QWORD[rbp-80]
    mov RBX, 10
    mov QWORD[rbp-88], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-88]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-88], rdx
    pop RAX; 恢复RAX(左子结果)
; 设置变量d
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-64]
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RBX
; 设置变量_b
    mov RAX, QWORD[rbp-88]
    mov RBX, 48
    add RAX, RBX
    mov RBX, QWORD[rbp-96]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量i
    mov RAX, QWORD[rbp-80]
    mov RBX, 10
    mov QWORD[rbp-80], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-80]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-80], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量x
    for_10_continue:


    jmp for_10; for循环
    for_10_end: ; for循环结束
    mov QWORD[rbp-104], 0
; 设置变量j




    for_11: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-64]
    mov RBX, 2
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, RCX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RCX, rax
    pop RAX; 恢复RAX(左子结果)
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_11_end
    for_11_body:


    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-112], RAX
    add QWORD[rbp-112], RBX
; 设置变量_a
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    sub RAX, RBX
    mov RBX, QWORD[rbp-104]
    sub RAX, RBX
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-120], RBX
    add QWORD[rbp-120], RAX
; 设置变量_c
    mov RBX, QWORD[rbp-112]
    movzx RAX, BYTE [RBX]
    mov BYTE[rbp-121], al
; 设置变量tmp
    mov RAX, QWORD[rbp-120]
    movzx RBX, BYTE [RAX]
    mov RAX, QWORD[rbp-112]
    mov BYTE [RAX], bl
; expression statement
    movzx RBX, BYTE[rbp-121]
    mov RAX, QWORD[rbp-120]
    mov BYTE [RAX], bl
; expression statement
    mov RAX, QWORD[rbp-104]
    mov RBX, 1
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量j
    for_11_continue:


    jmp for_11; for循环
    for_11_end: ; for循环结束
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_syscall_write
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    func_end_std_memory_wu:
    add rsp, 168; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_dumpAllocator progbits alloc exec nowrite align=16
global std_memory_dumpAllocator
; ==============================
; Function: std_memory_dumpAllocator
std_memory_dumpAllocator:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 312; 分配局部变量空间(312字节, 含对齐)
    call std_memory_initFreeHeads
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_6
    mov QWORD [rsp+0+8], 23
    mov QWORD [rsp+0+16], 23
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-48], RAX
; 设置变量top
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_7
    mov QWORD [rsp+0+8], 4
    mov QWORD [rsp+0+16], 4
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    call std_memory_wnl
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_8
    mov QWORD [rsp+0+8], 10
    mov QWORD [rsp+0+16], 10
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gFreeHeads]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    call std_memory_wnl
    mov QWORD[rbp-56], 0
; 设置变量cls
    mov QWORD[rbp-64], 0
; 设置变量totalFree
    mov QWORD[rbp-72], 0
; 设置变量totalFreeBytes




    for_12: ; for循环开始
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 60
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_12_end
    for_12_body:


    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_headOf
    mov QWORD[rbp-80], RAX
; 设置变量h
    mov QWORD[rbp-88], 0
; 设置变量n
    mov QWORD[rbp-96], 0
; 设置变量bytes
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-104], RAX
; 设置变量cur
    mov QWORD[rbp-112], 0
; 设置变量guard




    for_13: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je for_13_end
    for_and_mid_1:
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 200000
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_13_end
    for_13_body:


    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-120], RAX
; 设置变量raw
    mov RAX, QWORD[rbp-120]
    mov RCX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RBX, RCX
    not RBX
    mov QWORD[rbp-128], RAX
    and QWORD[rbp-128], RBX
; 设置变量pure
    mov RAX, QWORD[rbp-88]
    mov RBX, 1
    mov QWORD[rbp-88], RAX
    add QWORD[rbp-88], RBX
; 设置变量n
    mov RAX, QWORD[rbp-96]
    mov RCX, QWORD[rbp-128]
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RCX
; 设置变量bytes
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeNext
    mov QWORD[rbp-104], RAX
; 设置变量cur
    mov RCX, QWORD[rbp-112]
    mov RBX, 1
    mov QWORD[rbp-112], RCX
    add QWORD[rbp-112], RBX
; 设置变量guard
    for_13_continue:


    jmp for_13; for循环
    for_13_end: ; for循环结束
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_86
    if_86:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_9
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_10
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOf
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_11
    mov QWORD [rsp+0+8], 6
    mov QWORD [rsp+0+16], 6
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-88]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_12
    mov QWORD [rsp+0+8], 7
    mov QWORD [rsp+0+16], 7
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 200000
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_87
    if_87:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_13
    mov QWORD [rsp+0+8], 7
    mov QWORD [rsp+0+16], 7
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    end_if_87:
    call std_memory_wnl
    mov RCX, QWORD[rbp-64]
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-64], RCX
    add QWORD[rbp-64], RAX
; 设置变量totalFree
    mov RAX, QWORD[rbp-72]
    mov RCX, QWORD[rbp-96]
    mov QWORD[rbp-72], RAX
    add QWORD[rbp-72], RCX
; 设置变量totalFreeBytes
    end_if_86:
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD[rbp-56], RAX
    add QWORD[rbp-56], RBX
; 设置变量cls
    for_12_continue:


    jmp for_12; for循环
    for_12_end: ; for循环结束
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_14
    mov QWORD [rsp+0+8], 10
    mov QWORD [rsp+0+16], 10
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_15
    mov QWORD [rsp+0+8], 11
    mov QWORD [rsp+0+16], 11
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    call std_memory_wnl
    mov RAX, QWORD[rel __global_std_memory_gFreeHeads]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_88
    if_88:
    jmp func_end_std_memory_dumpAllocator
    end_if_88:
    mov RCX, QWORD[rel __global_std_memory_gFreeHeads]
    mov RBX, 480
    mov QWORD[rbp-136], RCX
    add QWORD[rbp-136], RBX
; 设置变量cur
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-144], RAX
; 设置变量heapTop
    mov QWORD[rbp-152], 0
; 设置变量allocN
    mov QWORD[rbp-160], 0
; 设置变量allocB
    mov QWORD[rbp-168], 0
; 设置变量freeN
    mov QWORD[rbp-176], 0
; 设置变量freeB
    mov QWORD[rbp-184], 0
; 设置变量bad




    for_14: ; for循环开始
    mov RAX, QWORD[rbp-136]
    mov RCX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RCX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-144]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe for_14_end
    for_14_body:


    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-136]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-192], RAX
; 设置变量raw
    mov RCX, QWORD[rbp-192]
    mov RDX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RBX, RDX
    not RBX
    mov QWORD[rbp-200], RCX
    and QWORD[rbp-200], RBX
; 设置变量pure
    mov RAX, QWORD[rbp-200]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 32
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_89
    if_89:
    mov RCX, QWORD[rbp-184]
    mov RBX, 1
    mov QWORD[rbp-184], RCX
    add QWORD[rbp-184], RBX
; 设置变量bad
    jmp for_14_end
    end_if_89:
    mov RAX, QWORD[rbp-192]
    mov RCX, QWORD[rel __global_std_memory_IS_FREE]
    and RAX, RCX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je else_if_90
    if_90:
    mov RCX, QWORD[rbp-168]
    mov RBX, 1
    mov QWORD[rbp-168], RCX
    add QWORD[rbp-168], RBX
; 设置变量freeN
    mov RCX, QWORD[rbp-176]
    mov RDX, QWORD[rbp-200]
    mov QWORD[rbp-176], RCX
    add QWORD[rbp-176], RDX
; 设置变量freeB
    jmp end_if_90
    else_if_90:
    mov RCX, QWORD[rbp-152]
    mov RBX, 1
    mov QWORD[rbp-152], RCX
    add QWORD[rbp-152], RBX
; 设置变量allocN
    mov RCX, QWORD[rbp-160]
    mov RDX, QWORD[rbp-200]
    mov QWORD[rbp-160], RCX
    add QWORD[rbp-160], RDX
; 设置变量allocB
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_16
    mov QWORD [rsp+0+8], 10
    mov QWORD [rsp+0+16], 10
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-136]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_17
    mov QWORD [rsp+0+8], 6
    mov QWORD [rsp+0+16], 6
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-200]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_18
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-192]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_19
    mov QWORD [rsp+0+8], 7
    mov QWORD [rsp+0+16], 7
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RCX, QWORD[rbp-192]
    mov RBX, QWORD[rel __global_std_memory_RC_BIT]
    and RCX, RBX
    mov RBX, 2
    mov QWORD [rsp+0], RCX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存移位计数
    mov cl, byte [rsp]
    sar QWORD [rsp+16], cl
    add rsp, 8; 清理移位计数
    pop RAX; 恢复RAX(左子结果)
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_20
    mov QWORD [rsp+0+8], 9
    mov QWORD [rsp+0+16], 9
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    sub rsp, 16; register args buffer
    mov RCX, QWORD[rbp-136]
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD [rsp+0], RCX
    add QWORD [rsp+0], RDX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_isTrackedAll
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_gFreeHeads]
    mov RBX, 480
    add RCX, RBX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_91
    if_91:
    mov RDX, QWORD[rbp-136]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-208], RDX
    sub QWORD[rbp-208], RBX
; 设置变量_pfp
    mov RBX, QWORD[rbp-208]
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-216], RAX
; 设置变量pf
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_21
    mov QWORD [rsp+0+8], 7
    mov QWORD [rsp+0+16], 7
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-216]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_22
    mov QWORD [rsp+0+8], 10
    mov QWORD [rsp+0+16], 10
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RDX, QWORD[rbp-216]
    mov RSI, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RBX, RSI
    not RBX
    mov QWORD [rsp+0], RDX
    and QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    end_if_91:
    call std_memory_wnl
    end_if_90:
    mov RDX, QWORD[rbp-136]
    mov RSI, QWORD[rbp-200]
    mov QWORD[rbp-224], RDX
    add QWORD[rbp-224], RSI
; 设置变量next
    mov RAX, QWORD[rbp-224]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-136]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe if_92
    mov RAX, QWORD[rbp-224]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-144]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    ja if_92
    jbe end_if_92
    if_92:
    mov RDX, QWORD[rbp-184]
    mov RBX, 1
    mov QWORD[rbp-184], RDX
    add QWORD[rbp-184], RBX
; 设置变量bad
    jmp for_14_end
    end_if_92:
    mov RBX, QWORD[rbp-224]
    mov QWORD[rbp-136], RBX
; 设置变量cur
    for_14_continue:


    jmp for_14; for循环
    for_14_end: ; for循环结束
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_23
    mov QWORD [rsp+0+8], 12
    mov QWORD [rsp+0+16], 12
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-152]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_24
    mov QWORD [rsp+0+8], 8
    mov QWORD [rsp+0+16], 8
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-160]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_25
    mov QWORD [rsp+0+8], 7
    mov QWORD [rsp+0+16], 7
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-168]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_26
    mov QWORD [rsp+0+8], 7
    mov QWORD [rsp+0+16], 7
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-176]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_27
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-184]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_28
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-136]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    call std_memory_wnl
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_PTR_SIZE]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_93
    if_93:
    mov RDX, QWORD[rbp-144]
    mov RSI, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-232], RDX
    sub QWORD[rbp-232], RSI
; 设置变量_fp
    mov RDX, QWORD[rbp-232]
    mov RAX, QWORD [RDX]
    mov QWORD[rbp-240], RAX
; 设置变量rawTop
    mov RDX, QWORD[rbp-240]
    mov RSI, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RBX, RSI
    not RBX
    mov QWORD[rbp-248], RDX
    and QWORD[rbp-248], RBX
; 设置变量pureTop
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_29
    mov QWORD [rsp+0+8], 14
    mov QWORD [rsp+0+16], 14
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-240]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_17
    mov QWORD [rsp+0+8], 6
    mov QWORD [rsp+0+16], 6
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-248]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_30
    mov QWORD [rsp+0+8], 8
    mov QWORD [rsp+0+16], 8
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RDX, QWORD[rbp-240]
    mov RSI, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+0], RDX
    and QWORD [rsp+0], RSI
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    call std_memory_wnl
    mov RAX, QWORD[rbp-248]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 32
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_94
    and_mid_8:
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-248]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_94
    if_94:
    mov RDX, QWORD[rbp-144]
    mov RSI, QWORD[rbp-248]
    mov QWORD[rbp-256], RDX
    sub QWORD[rbp-256], RSI
; 设置变量blk
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-256]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-264], RAX
; 设置变量hdr
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_31
    mov QWORD [rsp+0+8], 11
    mov QWORD [rsp+0+16], 11
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-264]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_30
    mov QWORD [rsp+0+8], 8
    mov QWORD [rsp+0+16], 8
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RDX, QWORD[rbp-264]
    mov RSI, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+0], RDX
    and QWORD [rsp+0], RSI
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_32
    mov QWORD [rsp+0+8], 4
    mov QWORD [rsp+0+16], 4
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RDX, QWORD[rbp-264]
    mov RBX, QWORD[rel __global_std_memory_RC_BIT]
    and RDX, RBX
    mov RBX, 2
    mov QWORD [rsp+0], RDX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存移位计数
    mov cl, byte [rsp]
    sar QWORD [rsp+16], cl
    add rsp, 8; 清理移位计数
    pop RAX; 恢复RAX(左子结果)
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_33
    mov QWORD [rsp+0+8], 6
    mov QWORD [rsp+0+16], 6
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-256]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_wu
    call std_memory_wnl
    end_if_94:
    end_if_93:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_34
    mov QWORD [rsp+0+8], 12
    mov QWORD [rsp+0+16], 12
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_ws
    func_end_std_memory_dumpAllocator:
    add rsp, 312; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_memmove progbits alloc exec nowrite align=16
global std_memory_memmove
; ==============================
; Function: std_memory_memmove
std_memory_memmove:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    mov rdi, [rbp-48]
    mov rsi, [rbp-56]
    mov rdx, [rbp-64]
    call _memmove
    func_end_std_memory_memmove:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_memcpy progbits alloc exec nowrite align=16
global std_memory_memcpy
; ==============================
; Function: std_memory_memcpy
std_memory_memcpy:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 168; 分配局部变量空间(168字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-72], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-72]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-72], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量words
    mov QWORD[rbp-80], 0
; 设置变量i




    for_15: ; for循环开始
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_15_end
    for_15_body:


    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, QWORD[rbp-80]
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-88], RBX
    add QWORD[rbp-88], RAX
; 设置变量dstP
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, QWORD[rbp-80]
    imul RAX, RBX
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-96], RBX
    add QWORD[rbp-96], RAX
; 设置变量srcP
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD [RAX]
    mov RAX, QWORD[rbp-88]
    mov QWORD [RAX], RBX
; expression statement
    mov RBX, QWORD[rbp-80]
    mov RAX, 1
    mov QWORD[rbp-80], RBX
    add QWORD[rbp-80], RAX
; 设置变量i
    for_15_continue:


    jmp for_15; for循环
    for_15_end: ; for循环结束
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, QWORD[rbp-72]
    imul RAX, RBX
    mov RBX, QWORD[rbp-64]
    mov QWORD[rbp-104], RBX
    sub QWORD[rbp-104], RAX
; 设置变量rem
    mov QWORD[rbp-112], 0
; 设置变量j




    for_16: ; for循环开始
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_16_end
    for_16_body:


    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RCX, QWORD[rbp-72]
    imul RAX, RCX
    mov RBX, QWORD[rbp-48]
    add RBX, RAX
    mov RCX, QWORD[rbp-112]
    mov QWORD[rbp-120], RBX
    add QWORD[rbp-120], RCX
; 设置变量dstB
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RCX, QWORD[rbp-72]
    imul RAX, RCX
    mov RBX, QWORD[rbp-56]
    add RBX, RAX
    mov RCX, QWORD[rbp-112]
    mov QWORD[rbp-128], RBX
    add QWORD[rbp-128], RCX
; 设置变量srcB
    mov RCX, QWORD[rbp-128]
    movzx RBX, BYTE [RCX]
    mov RCX, QWORD[rbp-120]
    mov BYTE [RCX], bl
; expression statement
    mov RBX, QWORD[rbp-112]
    mov RCX, 1
    mov QWORD[rbp-112], RBX
    add QWORD[rbp-112], RCX
; 设置变量j
    for_16_continue:


    jmp for_16; for循环
    for_16_end: ; for循环结束
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_memcpy
    func_end_std_memory_memcpy:
    add rsp, 168; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_hdrSizeRaw progbits alloc exec nowrite align=16
global std_memory_hdrSizeRaw
; ==============================
; Function: std_memory_hdrSizeRaw
std_memory_hdrSizeRaw:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-56], RAX
; 设置变量_p
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_memory_hdrSizeRaw
    func_end_std_memory_hdrSizeRaw:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_hdrSetSizeRaw progbits alloc exec nowrite align=16
global std_memory_hdrSetSizeRaw
; ==============================
; Function: std_memory_hdrSetSizeRaw
std_memory_hdrSetSizeRaw:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-64], RAX
; 设置变量_p
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-64]
    mov QWORD [RBX], RAX
; expression statement
    func_end_std_memory_hdrSetSizeRaw:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_hdrSetFooter progbits alloc exec nowrite align=16
global std_memory_hdrSetFooter
; ==============================
; Function: std_memory_hdrSetFooter
std_memory_hdrSetFooter:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-56]
    mov RBX, -4
    mov QWORD[rbp-64], RAX
    and QWORD[rbp-64], RBX
; 设置变量pureSize
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-64]
    add RAX, RBX
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-72], RAX
    sub QWORD[rbp-72], RBX
; 设置变量_p
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-72]
    mov QWORD [RBX], RAX
; expression statement
    func_end_std_memory_hdrSetFooter:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_rcLoad progbits alloc exec nowrite align=16
global std_memory_rcLoad
; ==============================
; Function: std_memory_rcLoad
std_memory_rcLoad:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RAX, 2
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-56], RBX
    sub QWORD[rbp-56], RAX
; 设置变量_p
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_memory_rcLoad
    func_end_std_memory_rcLoad:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_rcStore progbits alloc exec nowrite align=16
global std_memory_rcStore
; ==============================
; Function: std_memory_rcStore
std_memory_rcStore:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RAX, 2
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-64], RBX
    sub QWORD[rbp-64], RAX
; 设置变量_p
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD[rbp-64]
    mov QWORD [RAX], RBX
; expression statement
    func_end_std_memory_rcStore:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_flagLoad progbits alloc exec nowrite align=16
global std_memory_flagLoad
; ==============================
; Function: std_memory_flagLoad
std_memory_flagLoad:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-56], RAX
    sub QWORD[rbp-56], RBX
; 设置变量_p
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_memory_flagLoad
    func_end_std_memory_flagLoad:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_flagStore progbits alloc exec nowrite align=16
global std_memory_flagStore
; ==============================
; Function: std_memory_flagStore
std_memory_flagStore:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-64], RAX
    sub QWORD[rbp-64], RBX
; 设置变量_p
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-64]
    mov QWORD [RBX], RAX
; expression statement
    func_end_std_memory_flagStore:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_freeNext progbits alloc exec nowrite align=16
global std_memory_freeNext
; ==============================
; Function: std_memory_freeNext
std_memory_freeNext:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-56], RAX
    add QWORD[rbp-56], RBX
; 设置变量_p
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_memory_freeNext
    func_end_std_memory_freeNext:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_freeSetNext progbits alloc exec nowrite align=16
global std_memory_freeSetNext
; ==============================
; Function: std_memory_freeSetNext
std_memory_freeSetNext:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量_p
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-64]
    mov QWORD [RBX], RAX
; expression statement
    func_end_std_memory_freeSetNext:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_freePrev progbits alloc exec nowrite align=16
global std_memory_freePrev
; ==============================
; Function: std_memory_freePrev
std_memory_freePrev:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RAX, 2
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-56], RBX
    add QWORD[rbp-56], RAX
; 设置变量_p
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_memory_freePrev
    func_end_std_memory_freePrev:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_freeSetPrev progbits alloc exec nowrite align=16
global std_memory_freeSetPrev
; ==============================
; Function: std_memory_freeSetPrev
std_memory_freeSetPrev:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RAX, 2
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-64], RBX
    add QWORD[rbp-64], RAX
; 设置变量_p
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD[rbp-64]
    mov QWORD [RAX], RBX
; expression statement
    func_end_std_memory_freeSetPrev:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_mallocRC progbits alloc exec nowrite align=16
global std_memory_mallocRC
; ==============================
; Function: std_memory_mallocRC
std_memory_mallocRC:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 312; 分配局部变量空间(312字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    call std_memory_initFreeHeads
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, 3
    mov QWORD[rbp-56], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存乘数
    mov RAX, QWORD[rbp-56]
    imul RAX, qword [rsp]
    mov QWORD[rbp-56], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量rcPrefix
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量req
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, 5
    mov QWORD[rbp-72], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存乘数
    mov RAX, QWORD[rbp-72]
    imul RAX, qword [rsp]
    mov QWORD[rbp-72], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量minReq
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_95
    if_95:
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-64], RAX
; 设置变量req
    end_if_95:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_LARGE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_96
    if_96:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-80], RAX
; 设置变量old
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
    add QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-88], RAX
; 设置变量nb
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
    mov RAX, QWORD[rbp-64]
    add RCX, RAX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_97
    if_97:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_97:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    mov RBX, QWORD[rbp-80]
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-96], RBX
    add QWORD[rbp-96], RAX
; 设置变量p
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcStore
    mov RAX, QWORD[rel __global_std_memory_RC_BIT]
    mov QWORD[rbp-104], RAX
; 设置变量flagRC
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_flagStore
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackAlloc
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackAllocAll
    mov RAX, QWORD[rbp-96]
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_96:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_98
    if_98:
    mov RBX, QWORD[rbp-64]
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RBX, RAX
    mov RAX, 1
    sub RBX, RAX
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RSI, 1
    sub RDX, RSI
    mov RAX, RDX
    not RAX
    mov QWORD[rbp-112], RBX
    and QWORD[rbp-112], RAX
; 设置变量aligned
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-120], RAX
; 设置变量old
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-120]
    mov RAX, QWORD[rbp-112]
    mov QWORD [rsp+0], RBX
    add QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-128], RAX
; 设置变量nb
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
    mov RAX, QWORD[rbp-112]
    add RCX, RAX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_99
    if_99:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_99:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RBX, QWORD[rbp-112]
    mov RAX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RBX
    or QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RBX, QWORD[rbp-112]
    mov RAX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RBX
    or QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_coalesce
    mov QWORD[rbp-136], RAX
; 设置变量merged
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-136]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-144], RAX
; 设置变量mRaw
    mov RBX, QWORD[rbp-144]
    mov RDX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RAX, RDX
    not RAX
    mov QWORD[rbp-152], RBX
    and QWORD[rbp-152], RAX
; 设置变量mPure
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-136]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-152]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-136]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-152]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    mov RBX, QWORD[rbp-136]
    mov RDX, QWORD[rbp-152]
    mov QWORD[rbp-160], RBX
    add QWORD[rbp-160], RDX
; 设置变量nextM
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-168], RAX
; 设置变量brkTop
    mov RAX, QWORD[rbp-160]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-168]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_100
    if_100:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-160]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-176], RAX
; 设置变量ns
    mov RAX, QWORD[rbp-176]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_101
    if_101:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-160]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-176]
    mov RSI, QWORD[rel __global_std_memory_PREV_FREE]
    mov RBX, RSI
    not RBX
    mov QWORD [rsp+8], RDX
    and QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-160]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-176]
    mov RSI, QWORD[rel __global_std_memory_PREV_FREE]
    mov RBX, RSI
    not RBX
    mov QWORD [rsp+8], RDX
    and QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    end_if_101:
    end_if_100:
    mov RDX, QWORD[rbp-136]
    mov RSI, QWORD[rbp-56]
    mov QWORD[rbp-184], RDX
    add QWORD[rbp-184], RSI
; 设置变量p
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-184]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcStore
    mov RBX, QWORD[rel __global_std_memory_RC_BIT]
    mov QWORD[rbp-192], RBX
; 设置变量flagRC
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-184]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-192]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_flagStore
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-184]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackAlloc
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-184]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackAllocAll
    mov RAX, QWORD[rbp-184]
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_98:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOf
    mov QWORD[rbp-200], RAX
; 设置变量cls
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-200]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOf
    mov QWORD[rbp-208], RAX
; 设置变量blkSize
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-200]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_headOf
    mov QWORD[rbp-216], RAX
; 设置变量head
    mov RAX, QWORD[rbp-216]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_102
    if_102:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-200]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-208]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_commit
    mov QWORD[rbp-216], RAX
; 设置变量head
    mov RAX, QWORD[rbp-216]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_103
    if_103:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_103:
    end_if_102:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-216]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeNext
    mov QWORD[rbp-224], RAX
; 设置变量next
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-200]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-224]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_setHead
    mov RAX, QWORD[rbp-224]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_104
    if_104:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-224]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeSetPrev
    end_if_104:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-216]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-208]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-216]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-208]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    mov RDX, QWORD[rbp-216]
    mov RSI, QWORD[rbp-208]
    mov QWORD[rbp-232], RDX
    add QWORD[rbp-232], RSI
; 设置变量nextBlk
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-240], RAX
; 设置变量brkTop
    mov RAX, QWORD[rbp-232]
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-240]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_105
    if_105:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-232]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-248], RAX
; 设置变量ns
    mov RAX, QWORD[rbp-248]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_106
    if_106:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-232]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-248]
    mov RSI, QWORD[rel __global_std_memory_PREV_FREE]
    mov RBX, RSI
    not RBX
    mov QWORD [rsp+8], RDX
    and QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-232]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-248]
    mov RSI, QWORD[rel __global_std_memory_PREV_FREE]
    mov RBX, RSI
    not RBX
    mov QWORD [rsp+8], RDX
    and QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    end_if_106:
    end_if_105:
    mov RDX, QWORD[rbp-216]
    mov RSI, QWORD[rbp-56]
    mov QWORD[rbp-256], RDX
    add QWORD[rbp-256], RSI
; 设置变量p
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-256]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcStore
    mov RBX, QWORD[rel __global_std_memory_RC_BIT]
    mov QWORD[rbp-264], RBX
; 设置变量flagRC
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-256]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-264]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_flagStore
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-256]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackAlloc
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-256]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackAllocAll
    mov RAX, QWORD[rbp-256]
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    func_end_std_memory_mallocRC:
    add rsp, 312; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_freeRC progbits alloc exec nowrite align=16
global std_memory_freeRC
; ==============================
; Function: std_memory_freeRC
std_memory_freeRC:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_107
    if_107:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeRC
    end_if_107:
    mov RAX, QWORD[rel __global_std_memory_gAllLeaks]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_108
    and_mid_10:
    mov RAX, QWORD[rel __global_std_memory_gAllLeakOverflow]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_108
    and_mid_9:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_isTrackedAll
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_108
    if_108:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeRC
    end_if_108:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, 3
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
    sub QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeAt
    mov BYTE[rbp-49], al
; 设置变量ok
    movzx RAX, BYTE[rbp-49]
; condition
    test RAX, RAX
    jz end_if_109
    if_109:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackFreeAll
    end_if_109:
    movzx RAX, BYTE[rbp-49]
; return值存入RAX
    jmp func_end_std_memory_freeRC
    func_end_std_memory_freeRC:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_rcInc progbits alloc exec nowrite align=16
global std_memory_rcInc
; ==============================
; Function: std_memory_rcInc
std_memory_rcInc:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_110
    if_110:
    jmp func_end_std_memory_rcInc
    end_if_110:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcLoad
    mov QWORD[rbp-56], RAX
; 设置变量rc
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD [rsp+8], RAX
    add QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcStore
    func_end_std_memory_rcInc:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_rcDec progbits alloc exec nowrite align=16
global std_memory_rcDec
; ==============================
; Function: std_memory_rcDec
std_memory_rcDec:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_111
    if_111:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcDec
    end_if_111:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcLoad
    mov QWORD[rbp-56], RAX
; 设置变量rc
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_112
    if_112:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcDec
    end_if_112:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_113
    if_113:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcStore
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackFree
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeRC
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcDec
    end_if_113:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD [rsp+8], RAX
    sub QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcStore
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_rcDec
    func_end_std_memory_rcDec:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_dropInc progbits alloc exec nowrite align=16
global std_memory_dropInc
; ==============================
; Function: std_memory_dropInc
std_memory_dropInc:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov RAX, QWORD[rel __global_std_memory_gDropCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gDropCount], RAX
    add QWORD[rel __global_std_memory_gDropCount], RBX
; 设置变量gDropCount
    func_end_std_memory_dropInc:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_initLeakTracker progbits alloc exec nowrite align=16
global std_memory_initLeakTracker
; ==============================
; Function: std_memory_initLeakTracker
std_memory_initLeakTracker:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov RAX, QWORD[rel __global_std_memory_gLeaks]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_114
    if_114:
    jmp func_end_std_memory_initLeakTracker
    end_if_114:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-48], RAX
; 设置变量cur
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, 2
    imul RAX, RBX
    mov QWORD[rbp-56], 65536
    add QWORD[rbp-56], RAX
; 设置变量total
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
    add QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-64], RAX
; 设置变量nb
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
    mov RAX, QWORD[rbp-56]
    add RCX, RAX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_115
    if_115:
    jmp func_end_std_memory_initLeakTracker
    end_if_115:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    mov RBX, QWORD[rbp-48]
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rel __global_std_memory_gLeaks], RBX
    add QWORD[rel __global_std_memory_gLeaks], RAX
; 设置变量gLeaks
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RBX
    mov RBX, 32768
    mov QWORD[rel __global_std_memory_gLeakSizes], RAX
    add QWORD[rel __global_std_memory_gLeakSizes], RBX
; 设置变量gLeakSizes
    func_end_std_memory_initLeakTracker:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_initAllLeakTracker progbits alloc exec nowrite align=16
global std_memory_initAllLeakTracker
; ==============================
; Function: std_memory_initAllLeakTracker
std_memory_initAllLeakTracker:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov RAX, QWORD[rel __global_std_memory_gAllLeaks]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_116
    if_116:
    jmp func_end_std_memory_initAllLeakTracker
    end_if_116:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-48], RAX
; 设置变量cur
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, 2
    imul RAX, RBX
    mov QWORD[rbp-56], 65536
    add QWORD[rbp-56], RAX
; 设置变量total
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
    add QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-64], RAX
; 设置变量nb
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
    mov RAX, QWORD[rbp-56]
    add RCX, RAX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_117
    if_117:
    jmp func_end_std_memory_initAllLeakTracker
    end_if_117:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    mov RBX, QWORD[rbp-48]
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rel __global_std_memory_gAllLeaks], RBX
    add QWORD[rel __global_std_memory_gAllLeaks], RAX
; 设置变量gAllLeaks
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RBX
    mov RBX, 32768
    mov QWORD[rel __global_std_memory_gAllLeakSizes], RAX
    add QWORD[rel __global_std_memory_gAllLeakSizes], RBX
; 设置变量gAllLeakSizes
    func_end_std_memory_initAllLeakTracker:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_leakLoad progbits alloc exec nowrite align=16
global std_memory_leakLoad
; ==============================
; Function: std_memory_leakLoad
std_memory_leakLoad:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-56]
    mov RBX, 8
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-64], RBX
    add QWORD[rbp-64], RAX
; 设置变量_p
    mov RBX, QWORD[rbp-64]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_memory_leakLoad
    func_end_std_memory_leakLoad:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_leakStore progbits alloc exec nowrite align=16
global std_memory_leakStore
; ==============================
; Function: std_memory_leakStore
std_memory_leakStore:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    mov RAX, QWORD[rbp-56]
    mov RBX, 8
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-72], RBX
    add QWORD[rbp-72], RAX
; 设置变量_p
    mov RBX, QWORD[rbp-64]
    mov RAX, QWORD[rbp-72]
    mov QWORD [RAX], RBX
; expression statement
    func_end_std_memory_leakStore:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_leakSizeLoad progbits alloc exec nowrite align=16
global std_memory_leakSizeLoad
; ==============================
; Function: std_memory_leakSizeLoad
std_memory_leakSizeLoad:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-56]
    mov RBX, 8
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-64], RBX
    add QWORD[rbp-64], RAX
; 设置变量_p
    mov RBX, QWORD[rbp-64]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_memory_leakSizeLoad
    func_end_std_memory_leakSizeLoad:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_leakSizeStore progbits alloc exec nowrite align=16
global std_memory_leakSizeStore
; ==============================
; Function: std_memory_leakSizeStore
std_memory_leakSizeStore:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    mov RAX, QWORD[rbp-56]
    mov RBX, 8
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-72], RBX
    add QWORD[rbp-72], RAX
; 设置变量_p
    mov RBX, QWORD[rbp-64]
    mov RAX, QWORD[rbp-72]
    mov QWORD [RAX], RBX
; expression statement
    func_end_std_memory_leakSizeStore:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_trackAlloc progbits alloc exec nowrite align=16
global std_memory_trackAlloc
; ==============================
; Function: std_memory_trackAlloc
std_memory_trackAlloc:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_118
    if_118:
    jmp func_end_std_memory_trackAlloc
    end_if_118:
    call std_memory_initLeakTracker
    mov RAX, QWORD[rel __global_std_memory_gAllocCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gAllocCount], RAX
    add QWORD[rel __global_std_memory_gAllocCount], RBX
; 设置变量gAllocCount
    mov RAX, QWORD[rel __global_std_memory_gLeakCount]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 4096
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_119
    if_119:
    mov RAX, QWORD[rel __global_std_memory_gLeakCount]
    mov QWORD[rbp-64], RAX
; 设置变量cntV
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gLeaks]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_leakStore
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gLeakSizes]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_leakSizeStore
    mov RAX, QWORD[rel __global_std_memory_gLeakCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gLeakCount], RAX
    add QWORD[rel __global_std_memory_gLeakCount], RBX
; 设置变量gLeakCount
    end_if_119:
    func_end_std_memory_trackAlloc:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_trackFree progbits alloc exec nowrite align=16
global std_memory_trackFree
; ==============================
; Function: std_memory_trackFree
std_memory_trackFree:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_120
    if_120:
    jmp func_end_std_memory_trackFree
    end_if_120:
    call std_memory_initLeakTracker
    mov RAX, QWORD[rel __global_std_memory_gFreeCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gFreeCount], RAX
    add QWORD[rel __global_std_memory_gFreeCount], RBX
; 设置变量gFreeCount
    mov QWORD[rbp-56], 0
; 设置变量i




    for_17: ; for循环开始
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_gLeakCount]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_17_end
    for_17_body:


    sub rsp, 16; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gLeaks]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_leakLoad
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_121
    if_121:
    mov RAX, QWORD[rel __global_std_memory_gLeakCount]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    sub QWORD[rbp-64], RBX
; 设置变量lastIdx
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gLeaks]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gLeaks]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_leakLoad
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_leakStore
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gLeakSizes]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gLeakSizes]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_leakSizeLoad
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_leakSizeStore
    mov RAX, QWORD[rel __global_std_memory_gLeakCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gLeakCount], RAX
    sub QWORD[rel __global_std_memory_gLeakCount], RBX
; 设置变量gLeakCount
    jmp func_end_std_memory_trackFree
    end_if_121:
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD[rbp-56], RAX
    add QWORD[rbp-56], RBX
; 设置变量i
    for_17_continue:


    jmp for_17; for循环
    for_17_end: ; for循环结束
    func_end_std_memory_trackFree:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_trackAllocAll progbits alloc exec nowrite align=16
global std_memory_trackAllocAll
; ==============================
; Function: std_memory_trackAllocAll
std_memory_trackAllocAll:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_122
    if_122:
    jmp func_end_std_memory_trackAllocAll
    end_if_122:
    call std_memory_initAllLeakTracker
    mov RAX, QWORD[rel __global_std_memory_gAllAllocCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gAllAllocCount], RAX
    add QWORD[rel __global_std_memory_gAllAllocCount], RBX
; 设置变量gAllAllocCount
    mov RAX, QWORD[rel __global_std_memory_gAllLeakCount]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 4096
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_123
    if_123:
    mov RAX, QWORD[rel __global_std_memory_gAllLeakCount]
    mov QWORD[rbp-64], RAX
; 设置变量cntV
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gAllLeaks]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_leakStore
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gAllLeakSizes]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_leakSizeStore
    mov RAX, QWORD[rel __global_std_memory_gAllLeakCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gAllLeakCount], RAX
    add QWORD[rel __global_std_memory_gAllLeakCount], RBX
; 设置变量gAllLeakCount
    jmp end_if_123
    else_if_123:
    mov QWORD[rel __global_std_memory_gAllLeakOverflow], 1
; 设置变量gAllLeakOverflow
    end_if_123:
    func_end_std_memory_trackAllocAll:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_trackFreeAll progbits alloc exec nowrite align=16
global std_memory_trackFreeAll
; ==============================
; Function: std_memory_trackFreeAll
std_memory_trackFreeAll:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_124
    if_124:
    jmp func_end_std_memory_trackFreeAll
    end_if_124:
    call std_memory_initAllLeakTracker
    mov RAX, QWORD[rel __global_std_memory_gAllFreeCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gAllFreeCount], RAX
    add QWORD[rel __global_std_memory_gAllFreeCount], RBX
; 设置变量gAllFreeCount
    mov QWORD[rbp-56], 0
; 设置变量i




    for_18: ; for循环开始
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_gAllLeakCount]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_18_end
    for_18_body:


    sub rsp, 16; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gAllLeaks]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_leakLoad
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_125
    if_125:
    mov RAX, QWORD[rel __global_std_memory_gAllLeakCount]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    sub QWORD[rbp-64], RBX
; 设置变量lastIdx
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gAllLeaks]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gAllLeaks]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_leakLoad
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_leakStore
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gAllLeakSizes]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gAllLeakSizes]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_leakSizeLoad
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_leakSizeStore
    mov RAX, QWORD[rel __global_std_memory_gAllLeakCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gAllLeakCount], RAX
    sub QWORD[rel __global_std_memory_gAllLeakCount], RBX
; 设置变量gAllLeakCount
    jmp func_end_std_memory_trackFreeAll
    end_if_125:
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD[rbp-56], RAX
    add QWORD[rbp-56], RBX
; 设置变量i
    for_18_continue:


    jmp for_18; for循环
    for_18_end: ; for循环结束
    func_end_std_memory_trackFreeAll:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_reportAllLeaks progbits alloc exec nowrite align=16
global std_memory_reportAllLeaks
; ==============================
; Function: std_memory_reportAllLeaks
std_memory_reportAllLeaks:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov RAX, QWORD[rel __global_std_memory_gAllLeakCount]
; return值存入RAX
    jmp func_end_std_memory_reportAllLeaks
    func_end_std_memory_reportAllLeaks:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_reportAllAllocCount progbits alloc exec nowrite align=16
global std_memory_reportAllAllocCount
; ==============================
; Function: std_memory_reportAllAllocCount
std_memory_reportAllAllocCount:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov RAX, QWORD[rel __global_std_memory_gAllAllocCount]
; return值存入RAX
    jmp func_end_std_memory_reportAllAllocCount
    func_end_std_memory_reportAllAllocCount:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_reportAllFreeCount progbits alloc exec nowrite align=16
global std_memory_reportAllFreeCount
; ==============================
; Function: std_memory_reportAllFreeCount
std_memory_reportAllFreeCount:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov RAX, QWORD[rel __global_std_memory_gAllFreeCount]
; return值存入RAX
    jmp func_end_std_memory_reportAllFreeCount
    func_end_std_memory_reportAllFreeCount:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_releaseAllLeakTracker progbits alloc exec nowrite align=16
global std_memory_releaseAllLeakTracker
; ==============================
; Function: std_memory_releaseAllLeakTracker
std_memory_releaseAllLeakTracker:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 136; 分配局部变量空间(136字节, 含对齐)
    mov RAX, QWORD[rel __global_std_memory_gAllLeaks]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_126
    if_126:
    jmp func_end_std_memory_releaseAllLeakTracker
    end_if_126:
    mov RAX, QWORD[rel __global_std_memory_gAllLeaks]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-48], RAX
    sub QWORD[rbp-48], RBX
; 设置变量base
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-56], RAX
; 设置变量raw
    mov RBX, QWORD[rbp-56]
    mov RCX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RAX, RCX
    not RAX
    mov QWORD[rbp-64], RBX
    and QWORD[rbp-64], RAX
; 设置变量pure
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RBX, QWORD[rbp-64]
    mov RCX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RBX
    or QWORD [rsp+8], RCX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RBX, QWORD[rbp-64]
    mov RCX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RBX
    or QWORD [rsp+8], RCX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-72], RAX
; 设置变量top
    mov RBX, QWORD[rbp-48]
    mov RCX, QWORD[rbp-64]
    mov QWORD[rbp-80], RBX
    add QWORD[rbp-80], RCX
; 设置变量next
    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_127
    if_127:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-88], RAX
; 设置变量ns
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_128
    if_128:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RCX, QWORD[rbp-88]
    mov RBX, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD [rsp+8], RCX
    or QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RCX, QWORD[rbp-88]
    mov RBX, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD [rsp+8], RCX
    or QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    end_if_128:
    end_if_127:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_insertFreeList
    mov QWORD[rel __global_std_memory_gAllLeaks], 0
; 设置变量gAllLeaks
    mov QWORD[rel __global_std_memory_gAllLeakSizes], 0
; 设置变量gAllLeakSizes
    mov QWORD[rel __global_std_memory_gAllLeakCount], 0
; 设置变量gAllLeakCount
    mov QWORD[rel __global_std_memory_gAllAllocCount], 0
; 设置变量gAllAllocCount
    mov QWORD[rel __global_std_memory_gAllFreeCount], 0
; 设置变量gAllFreeCount
    mov QWORD[rel __global_std_memory_gAllLeakOverflow], 0
; 设置变量gAllLeakOverflow
    func_end_std_memory_releaseAllLeakTracker:
    add rsp, 136; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_releaseLeakTracker progbits alloc exec nowrite align=16
global std_memory_releaseLeakTracker
; ==============================
; Function: std_memory_releaseLeakTracker
std_memory_releaseLeakTracker:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 136; 分配局部变量空间(136字节, 含对齐)
    mov RAX, QWORD[rel __global_std_memory_gLeaks]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_129
    if_129:
    jmp func_end_std_memory_releaseLeakTracker
    end_if_129:
    mov RAX, QWORD[rel __global_std_memory_gLeaks]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-48], RAX
    sub QWORD[rbp-48], RBX
; 设置变量base
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-56], RAX
; 设置变量raw
    mov RBX, QWORD[rbp-56]
    mov RCX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RAX, RCX
    not RAX
    mov QWORD[rbp-64], RBX
    and QWORD[rbp-64], RAX
; 设置变量pure
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RBX, QWORD[rbp-64]
    mov RCX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RBX
    or QWORD [rsp+8], RCX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RBX, QWORD[rbp-64]
    mov RCX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RBX
    or QWORD [rsp+8], RCX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-72], RAX
; 设置变量top
    mov RBX, QWORD[rbp-48]
    mov RCX, QWORD[rbp-64]
    mov QWORD[rbp-80], RBX
    add QWORD[rbp-80], RCX
; 设置变量next
    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_130
    if_130:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-88], RAX
; 设置变量ns
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_131
    if_131:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RCX, QWORD[rbp-88]
    mov RBX, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD [rsp+8], RCX
    or QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RCX, QWORD[rbp-88]
    mov RBX, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD [rsp+8], RCX
    or QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    end_if_131:
    end_if_130:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_insertFreeList
    mov QWORD[rel __global_std_memory_gLeaks], 0
; 设置变量gLeaks
    mov QWORD[rel __global_std_memory_gLeakSizes], 0
; 设置变量gLeakSizes
    mov QWORD[rel __global_std_memory_gLeakCount], 0
; 设置变量gLeakCount
    mov QWORD[rel __global_std_memory_gAllocCount], 0
; 设置变量gAllocCount
    mov QWORD[rel __global_std_memory_gFreeCount], 0
; 设置变量gFreeCount
    func_end_std_memory_releaseLeakTracker:
    add rsp, 136; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_isTrackedAll progbits alloc exec nowrite align=16
global std_memory_isTrackedAll
; ==============================
; Function: std_memory_isTrackedAll
std_memory_isTrackedAll:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_132
    if_132:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_isTrackedAll
    end_if_132:
    mov RAX, QWORD[rel __global_std_memory_gAllLeaks]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_133
    if_133:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_isTrackedAll
    end_if_133:
    mov QWORD[rbp-56], 0
; 设置变量i




    for_19: ; for循环开始
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_gAllLeakCount]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_19_end
    for_19_body:


    sub rsp, 16; register args buffer
    mov RAX, QWORD[rel __global_std_memory_gAllLeaks]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_leakLoad
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_134
    if_134:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_isTrackedAll
    end_if_134:
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD[rbp-56], RAX
    add QWORD[rbp-56], RBX
; 设置变量i
    for_19_continue:


    jmp for_19; for循环
    for_19_end: ; for循环结束
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_isTrackedAll
    func_end_std_memory_isTrackedAll:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_compare progbits alloc exec nowrite align=16
global std_strings_compare
; ==============================
; Function: std_strings_compare
std_strings_compare:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 216; 分配局部变量空间(216字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-96], RAX
; 设置变量aPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
    mov QWORD[rbp-104], RAX
; 设置变量aLen
    mov RAX, QWORD [rbp-88]
    mov QWORD [rbp-112], RAX
; 设置变量bPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-88+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-88+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
    mov QWORD[rbp-120], RAX
; 设置变量bLen
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-128], RAX
; 设置变量minLen
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_135
    if_135:
    mov RAX, QWORD[rbp-120]
    mov QWORD[rbp-128], RAX
; 设置变量minLen
    end_if_135:
    mov QWORD[rbp-136], 0
; 设置变量i




    for_20: ; for循环开始
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-128]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_20_end
    for_20_body:


    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-136]
    mov QWORD[rbp-144], RAX
    add QWORD[rbp-144], RBX
; 设置变量_p16
    mov RAX, QWORD[rbp-144]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-152], RAX
; 设置变量ca
    mov RAX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-136]
    mov QWORD[rbp-160], RAX
    add QWORD[rbp-160], RBX
; 设置变量_p17
    mov RAX, QWORD[rbp-160]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-168], RAX
; 设置变量cb
    mov RAX, QWORD[rbp-152]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-168]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_136
    if_136:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_136:
    mov RAX, QWORD[rbp-152]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-168]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_137
    if_137:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_137:
    mov RAX, QWORD[rbp-136]
    mov RBX, 1
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量i
    for_20_continue:


    jmp for_20; for循环
    for_20_end: ; for循环结束
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_138
    if_138:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_138:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_139
    if_139:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_139:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_compare
    func_end_std_strings_compare:
    add rsp, 216; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_clone progbits alloc exec nowrite align=16
global std_strings_clone
; ==============================
; Function: std_strings_clone
std_strings_clone:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 184; 分配局部变量空间(184字节, 含对齐)
    mov QWORD [rbp-152], R10; 保存返回槽地址
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
    mov QWORD[rbp-72], RAX
; 设置变量sLen
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_140
    if_140:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-176+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rbp-176+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rbp-176+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-152]; 恢复返回槽地址
    mov RAX, QWORD [rbp-176]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-168]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-160]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_clone
    end_if_140:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-80], RAX
; 设置变量sPtr
    mov RAX, QWORD[rbp-72]
    mov RBX, 1
    mov QWORD[rbp-88], RAX
    add QWORD[rbp-88], RBX
; 设置变量bufN
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-88]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-96], RAX
; 设置变量buf
    mov QWORD[rbp-104], 0
; 设置变量i




    for_21: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_21_end
    for_21_body:


    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-112], RAX
    add QWORD[rbp-112], RBX
; 设置变量_p51
    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量_p52
    mov RAX, QWORD[rbp-120]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-128], RAX
; 设置变量_pc_p52
    mov RAX, QWORD[rbp-128]
    mov RBX, QWORD[rbp-112]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-104]
    mov RBX, 1
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量i
    for_21_continue:


    jmp for_21; for循环
    for_21_end: ; for循环结束
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-72]
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量_p53
    mov RAX, 0
    mov RBX, QWORD[rbp-136]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-176]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-176]
    mov QWORD [rbp-176+0], RAX
    mov RAX, QWORD [RBP-176+8]
    mov QWORD [rbp-176+8], RAX
    mov RAX, QWORD [RBP-176+16]
    mov QWORD [rbp-176+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-152]; 恢复返回槽地址
    mov RAX, QWORD [rbp-176]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-168]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-160]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_clone
    func_end_std_strings_clone:
    add rsp, 184; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_replaceAll progbits alloc exec nowrite align=16
global std_strings_replaceAll
; ==============================
; Function: std_strings_replaceAll
std_strings_replaceAll:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 264; 分配局部变量空间(264字节, 含对齐)
    mov QWORD [rbp-232], R10; 保存返回槽地址
    mov RAX, [rbp+16]; 保存栈参数2槽0到栈
    mov [rbp-112], RAX
    mov RAX, [rbp+24]; 保存栈参数2槽1到栈
    mov [rbp-104], RAX
    mov RAX, [rbp+32]; 保存栈参数2槽2到栈
    mov [rbp-96], RAX
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-88+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-88+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
    mov QWORD[rbp-120], RAX
; 设置变量oLen
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_141
    if_141:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-256]; 大值返回槽地址
    call std_strings_clone
    mov RAX, QWORD [RBP-256]
    mov QWORD [rbp-256+0], RAX
    mov RAX, QWORD [RBP-256+8]
    mov QWORD [rbp-256+8], RAX
    mov RAX, QWORD [RBP-256+16]
    mov QWORD [rbp-256+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-232]; 恢复返回槽地址
    mov RAX, QWORD [rbp-256]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-248]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-240]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_replaceAll
    end_if_141:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
    mov QWORD[rbp-128], RAX
; 设置变量sLen
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-112]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-112+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-112+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
    mov QWORD[rbp-136], RAX
; 设置变量nLen
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-144], RAX
; 设置变量sU8
    mov RAX, QWORD [rbp-112]
    mov QWORD [rbp-152], RAX
; 设置变量nU8
    mov QWORD[rbp-160], 0
; 设置变量cnt
    mov QWORD[rbp-168], 0
; 设置变量scan
    call std_strings_notFound
    mov QWORD[rbp-176], RAX
; 设置变量nf




    for_22: ; for循环开始


    sub rsp, 8; align stack for stack args
    push QWORD[rbp-168]
; 参数2
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-88]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-88+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-88+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_indexFrom
    add rsp, 16; clean stack args
    mov QWORD[rbp-184], RAX
; 设置变量idx
    mov RAX, QWORD[rbp-184]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-176]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_142
    if_142:
    jmp for_22_end
    end_if_142:
    mov RAX, QWORD[rbp-160]
    mov RBX, 1
    mov QWORD[rbp-160], RAX
    add QWORD[rbp-160], RBX
; 设置变量cnt
    mov RAX, QWORD[rbp-184]
    mov RBX, QWORD[rbp-120]
    mov QWORD[rbp-168], RAX
    add QWORD[rbp-168], RBX
; 设置变量scan
    for_22_continue:


    jmp for_22; for循环
    for_22_end: ; for循环结束
    mov RBX, QWORD[rbp-136]
    mov RCX, QWORD[rbp-120]
    sub RBX, RCX
    mov RAX, QWORD[rbp-160]
    imul RAX, RBX
    mov RCX, QWORD[rbp-128]
    mov QWORD[rbp-192], RCX
    add QWORD[rbp-192], RAX
; 设置变量outLen
    sub rsp, 16; register args buffer
    mov RCX, QWORD[rbp-192]
    mov RAX, 1
    mov QWORD [rsp+0], RCX
    add QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-200], RAX
; 设置变量out
    mov QWORD[rbp-208], 0
; 设置变量o
    mov QWORD[rbp-168], 0
; 设置变量scan




    for_23: ; for循环开始


    sub rsp, 8; align stack for stack args
    push QWORD[rbp-168]
; 参数2
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-88]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-88+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-88+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_indexFrom
    add rsp, 16; clean stack args
    mov QWORD[rbp-216], RAX
; 设置变量idx
    mov RAX, QWORD[rbp-216]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-176]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_143
    if_143:




    for_24: ; for循环开始
    mov RAX, QWORD[rbp-168]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-128]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_24_end
    for_24_body:


    mov RAX, QWORD[rbp-144]
    mov RBX, QWORD[rbp-168]
    add RAX, RBX
    movzx RCX, BYTE [RAX]
    mov RAX, QWORD[rbp-200]
    mov RBX, QWORD[rbp-208]
    add RAX, RBX
    mov BYTE [RAX], cl
; expression statement
    mov RCX, QWORD[rbp-208]
    mov RAX, 1
    mov QWORD[rbp-208], RCX
    add QWORD[rbp-208], RAX
; 设置变量o
    mov RCX, QWORD[rbp-168]
    mov RAX, 1
    mov QWORD[rbp-168], RCX
    add QWORD[rbp-168], RAX
; 设置变量scan
    for_24_continue:


    jmp for_24; for循环
    for_24_end: ; for循环结束
    jmp for_23_end
    end_if_143:




    for_25: ; for循环开始
    mov RAX, QWORD[rbp-168]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-216]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_25_end
    for_25_body:


    mov RAX, QWORD[rbp-144]
    mov RBX, QWORD[rbp-168]
    add RAX, RBX
    movzx RCX, BYTE [RAX]
    mov RAX, QWORD[rbp-200]
    mov RBX, QWORD[rbp-208]
    add RAX, RBX
    mov BYTE [RAX], cl
; expression statement
    mov RCX, QWORD[rbp-208]
    mov RAX, 1
    mov QWORD[rbp-208], RCX
    add QWORD[rbp-208], RAX
; 设置变量o
    mov RCX, QWORD[rbp-168]
    mov RAX, 1
    mov QWORD[rbp-168], RCX
    add QWORD[rbp-168], RAX
; 设置变量scan
    for_25_continue:


    jmp for_25; for循环
    for_25_end: ; for循环结束
    mov QWORD[rbp-224], 0
; 设置变量j




    for_26: ; for循环开始
    mov RAX, QWORD[rbp-224]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-136]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_26_end
    for_26_body:


    mov RAX, QWORD[rbp-152]
    mov RBX, QWORD[rbp-224]
    add RAX, RBX
    movzx RCX, BYTE [RAX]
    mov RAX, QWORD[rbp-200]
    mov RBX, QWORD[rbp-208]
    add RAX, RBX
    mov BYTE [RAX], cl
; expression statement
    mov RCX, QWORD[rbp-208]
    mov RAX, 1
    mov QWORD[rbp-208], RCX
    add QWORD[rbp-208], RAX
; 设置变量o
    mov RCX, QWORD[rbp-224]
    mov RAX, 1
    mov QWORD[rbp-224], RCX
    add QWORD[rbp-224], RAX
; 设置变量j
    for_26_continue:


    jmp for_26; for循环
    for_26_end: ; for循环结束
    mov RCX, QWORD[rbp-216]
    mov RAX, QWORD[rbp-120]
    mov QWORD[rbp-168], RCX
    add QWORD[rbp-168], RAX
; 设置变量scan
    for_23_continue:


    jmp for_23; for循环
    for_23_end: ; for循环结束
    mov RAX, 0
    mov RBX, QWORD[rbp-200]
    mov RCX, QWORD[rbp-208]
    add RBX, RCX
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-200]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-208]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-208]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-256]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-256]
    mov QWORD [rbp-256+0], RAX
    mov RAX, QWORD [RBP-256+8]
    mov QWORD [rbp-256+8], RAX
    mov RAX, QWORD [RBP-256+16]
    mov QWORD [rbp-256+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-232]; 恢复返回槽地址
    mov RAX, QWORD [rbp-256]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-248]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-240]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_replaceAll
    func_end_std_strings_replaceAll:
    add rsp, 264; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_parseUint progbits alloc exec nowrite align=16
global std_strings_parseUint
; ==============================
; Function: std_strings_parseUint
std_strings_parseUint:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 168; 分配局部变量空间(168字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
    mov QWORD[rbp-80], RAX
; 设置变量sLen
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_144
    if_144:
    mov RAX, 0
; return值存入RAX
    mov RDX, 0
; return值存入RDX
    jmp func_end_std_strings_parseUint
    end_if_144:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-88], RAX
; 设置变量p
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-96], RAX
; 设置变量pU8
    mov QWORD[rbp-104], 0
; 设置变量v
    mov QWORD[rbp-112], 0
; 设置变量i




    for_27: ; for循环开始
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_27_end
    for_27_body:


    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-112]
    add RAX, RBX
    movzx RAX, BYTE [RAX]
    mov BYTE[rbp-113], al
; 设置变量b
    mov QWORD[rbp-121], 0
; 设置变量d
    movzx RAX, BYTE[rbp-113]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 48
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_145
    and_mid_11:
    movzx RAX, BYTE[rbp-113]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 57
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_145
    if_145:
    movzx RAX, BYTE[rbp-113]
    mov RBX, 48
    mov QWORD[rbp-121], RAX
    sub QWORD[rbp-121], RBX
; 设置变量d
    jmp end_if_145
    else_if_145:
    movzx RAX, BYTE[rbp-113]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 97
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_146
    and_mid_12:
    movzx RAX, BYTE[rbp-113]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 122
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_146
    if_146:
    movzx RAX, BYTE[rbp-113]
    mov RBX, 97
    sub RAX, RBX
    mov RBX, 10
    mov QWORD[rbp-121], RAX
    add QWORD[rbp-121], RBX
; 设置变量d
    jmp end_if_146
    else_if_146:
    movzx RAX, BYTE[rbp-113]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_147
    and_mid_13:
    movzx RAX, BYTE[rbp-113]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 90
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_147
    if_147:
    movzx RAX, BYTE[rbp-113]
    mov RBX, 65
    sub RAX, RBX
    mov RBX, 10
    mov QWORD[rbp-121], RAX
    add QWORD[rbp-121], RBX
; 设置变量d
    jmp end_if_147
    else_if_147:
    mov RAX, 0
; return值存入RAX
    mov RDX, 0
; return值存入RDX
    jmp func_end_std_strings_parseUint
    end_if_147:
    end_if_146:
    end_if_145:
    mov RAX, QWORD[rbp-121]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_148
    if_148:
    mov RAX, 0
; return值存入RAX
    mov RDX, 0
; return值存入RDX
    jmp func_end_std_strings_parseUint
    end_if_148:
    mov RAX, QWORD[rbp-104]
    mov RBX, QWORD[rbp-72]
    imul RAX, RBX
    mov RBX, QWORD[rbp-121]
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量v
    mov RAX, QWORD[rbp-112]
    mov RBX, 1
    mov QWORD[rbp-112], RAX
    add QWORD[rbp-112], RBX
; 设置变量i
    for_27_continue:


    jmp for_27; for循环
    for_27_end: ; for循环结束
    mov RAX, QWORD[rbp-104]
; return值存入RAX
    mov RDX, 1
; return值存入RDX
    jmp func_end_std_strings_parseUint
    func_end_std_strings_parseUint:
    add rsp, 168; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_digitToF64 progbits alloc exec nowrite align=16
global std_strings_digitToF64
; ==============================
; Function: std_strings_digitToF64
std_strings_digitToF64:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_149
    if_149:
    mov RAX, 0x0
; return值存入RAX
    jmp func_end_std_strings_digitToF64
    end_if_149:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_150
    if_150:
    mov RAX, 0x3ff0000000000000
; return值存入RAX
    jmp func_end_std_strings_digitToF64
    end_if_150:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_151
    if_151:
    mov RAX, 0x4000000000000000
; return值存入RAX
    jmp func_end_std_strings_digitToF64
    end_if_151:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_152
    if_152:
    mov RAX, 0x4008000000000000
; return值存入RAX
    jmp func_end_std_strings_digitToF64
    end_if_152:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 4
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_153
    if_153:
    mov RAX, 0x4010000000000000
; return值存入RAX
    jmp func_end_std_strings_digitToF64
    end_if_153:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 5
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_154
    if_154:
    mov RAX, 0x4014000000000000
; return值存入RAX
    jmp func_end_std_strings_digitToF64
    end_if_154:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 6
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_155
    if_155:
    mov RAX, 0x4018000000000000
; return值存入RAX
    jmp func_end_std_strings_digitToF64
    end_if_155:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 7
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_156
    if_156:
    mov RAX, 0x401c000000000000
; return值存入RAX
    jmp func_end_std_strings_digitToF64
    end_if_156:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 8
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_157
    if_157:
    mov RAX, 0x4020000000000000
; return值存入RAX
    jmp func_end_std_strings_digitToF64
    end_if_157:
    mov RAX, 0x4022000000000000
; return值存入RAX
    jmp func_end_std_strings_digitToF64
    func_end_std_strings_digitToF64:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_parseFloat progbits alloc exec nowrite align=16
global std_strings_parseFloat
; ==============================
; Function: std_strings_parseFloat
std_strings_parseFloat:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 216; 分配局部变量空间(216字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
    mov QWORD[rbp-72], RAX
; 设置变量sLen
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_158
    if_158:
    mov RAX, 0x0
; return值存入RAX
    mov RDX, 0
; return值存入RDX
    jmp func_end_std_strings_parseFloat
    end_if_158:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-80], RAX
; 设置变量p
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-88], RAX
; 设置变量pU8
    mov QWORD[rbp-96], 0
; 设置变量i
    mov DWORD[rbp-104], 0; 64bit low
    mov DWORD[rbp-100], 1072693248; 64bit high
; 设置变量sign
    mov RAX, QWORD[rbp-88]
    mov RBX, QWORD[rbp-96]
    add RAX, RBX
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 43
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne else_if_159
    if_159:
    mov RAX, QWORD[rbp-96]
    mov RBX, 1
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RBX
; 设置变量i
    jmp end_if_159
    else_if_159:
    mov RAX, QWORD[rbp-88]
    mov RBX, QWORD[rbp-96]
    add RAX, RBX
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 45
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_160
    if_160:
    mov DWORD[rbp-104], 0; 64bit low
    mov DWORD[rbp-100], 3220176896; 64bit high
; 设置变量sign
    mov RAX, QWORD[rbp-96]
    mov RBX, 1
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RBX
; 设置变量i
    end_if_160:
    end_if_159:
    mov DWORD[rbp-112], 0; 64bit low
    mov DWORD[rbp-108], 0; 64bit high
; 设置变量intPart
    mov BYTE[rbp-113], 0
; 设置变量sawDigit




    for_28: ; for循环开始
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_28_end
    for_and_mid_2:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-88]
    mov RBX, QWORD[rbp-96]
    add RAX, RBX
    movzx RAX, BYTE [RAX]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigitByte
; condition
    test RAX, RAX
    jz for_28_end
    for_28_body:


    mov RAX, QWORD[rbp-112]
    mov RBX, 0x4024000000000000
    movq XMM0, RAX
    movq XMM1, RBX
    mulsd XMM0, XMM1
    movq RAX, XMM0
    mov RBX, RAX
    sub rsp, 16; register args buffer
    mov RDX, QWORD[rbp-88]
    mov RSI, QWORD[rbp-96]
    add RDX, RSI
    movzx RAX, BYTE [RDX]
    movzx RAX, al; zero-extend u8
    mov RCX, RAX
    mov RDX, 48
    mov QWORD [rsp+0], RCX
    sub QWORD [rsp+0], RDX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_digitToF64
    movq XMM0, RBX
    movq XMM1, RAX
    addsd XMM0, XMM1
    movq QWORD[rbp-112], XMM0
; 设置变量intPart
    mov BYTE[rbp-113], 1
; 设置变量sawDigit
    mov RCX, QWORD[rbp-96]
    mov RAX, 1
    mov QWORD[rbp-96], RCX
    add QWORD[rbp-96], RAX
; 设置变量i
    for_28_continue:


    jmp for_28; for循环
    for_28_end: ; for循环结束
    mov DWORD[rbp-121], 0; 64bit low
    mov DWORD[rbp-117], 0; 64bit high
; 设置变量frac
    mov DWORD[rbp-129], 0; 64bit low
    mov DWORD[rbp-125], 1072693248; 64bit high
; 设置变量fracDiv
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_161
    and_mid_14:
    mov RCX, QWORD[rbp-88]
    mov RAX, QWORD[rbp-96]
    add RCX, RAX
    movzx RAX, BYTE [RCX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 46
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_161
    if_161:
    mov RCX, QWORD[rbp-96]
    mov RAX, 1
    mov QWORD[rbp-96], RCX
    add QWORD[rbp-96], RAX
; 设置变量i




    for_29: ; for循环开始
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_29_end
    for_and_mid_3:
    sub rsp, 16; register args buffer
    mov RCX, QWORD[rbp-88]
    mov RAX, QWORD[rbp-96]
    add RCX, RAX
    movzx RAX, BYTE [RCX]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigitByte
; condition
    test RAX, RAX
    jz for_29_end
    for_29_body:


    mov RCX, QWORD[rbp-121]
    mov RBX, 0x4024000000000000
    movq XMM0, RCX
    movq XMM1, RBX
    mulsd XMM0, XMM1
    movq RCX, XMM0
    mov RBX, RCX
    sub rsp, 16; register args buffer
    mov RDX, QWORD[rbp-88]
    mov RSI, QWORD[rbp-96]
    add RDX, RSI
    movzx RAX, BYTE [RDX]
    movzx RAX, al; zero-extend u8
    mov RCX, RAX
    mov RDX, 48
    mov QWORD [rsp+0], RCX
    sub QWORD [rsp+0], RDX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_digitToF64
    movq XMM0, RBX
    movq XMM1, RAX
    addsd XMM0, XMM1
    movq QWORD[rbp-121], XMM0
; 设置变量frac
    mov RCX, QWORD[rbp-129]
    mov RAX, 0x4024000000000000
    movq XMM0, RCX
    movq XMM1, RAX
    mulsd XMM0, XMM1
    movq QWORD[rbp-129], XMM0
; 设置变量fracDiv
    mov BYTE[rbp-113], 1
; 设置变量sawDigit
    mov RCX, QWORD[rbp-96]
    mov RAX, 1
    mov QWORD[rbp-96], RCX
    add QWORD[rbp-96], RAX
; 设置变量i
    for_29_continue:


    jmp for_29; for循环
    for_29_end: ; for循环结束
    end_if_161:
    movzx RCX, BYTE[rbp-113]
    cmp RCX, 0
    sete cl
    movzx RCX, cl
    mov RAX, RCX
; condition
    test RAX, RAX
    jz end_if_162
    if_162:
    mov RAX, 0x0
; return值存入RAX
    mov RDX, 0
; return值存入RDX
    jmp func_end_std_strings_parseFloat
    end_if_162:
    mov RAX, QWORD[rbp-121]
    mov RCX, QWORD[rbp-129]
    movq XMM0, RAX
    movq XMM1, RCX
    divsd XMM0, XMM1
    movq RAX, XMM0
    mov RCX, QWORD[rbp-112]
    mov QWORD[rbp-137], RCX
    movq XMM0, QWORD[rbp-137]
    movq XMM1, RAX
    addsd XMM0, XMM1
    movq QWORD[rbp-137], XMM0
; 设置变量v
    mov QWORD[rbp-145], 1
; 设置变量expSign
    mov QWORD[rbp-153], 0
; 设置变量expVal
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_163
    and_mid_15:
    mov RCX, QWORD[rbp-88]
    mov RAX, QWORD[rbp-96]
    add RCX, RAX
    movzx RAX, BYTE [RCX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 101
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_163
    mov RCX, QWORD[rbp-88]
    mov RAX, QWORD[rbp-96]
    add RCX, RAX
    movzx RAX, BYTE [RCX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 69
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_163
    jne end_if_163
    if_163:
    mov RCX, QWORD[rbp-96]
    mov RAX, 1
    mov QWORD[rbp-96], RCX
    add QWORD[rbp-96], RAX
; 设置变量i
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_164
    and_mid_16:
    mov RCX, QWORD[rbp-88]
    mov RAX, QWORD[rbp-96]
    add RCX, RAX
    movzx RAX, BYTE [RCX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 43
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne else_if_164
    if_164:
    mov RCX, QWORD[rbp-96]
    mov RAX, 1
    mov QWORD[rbp-96], RCX
    add QWORD[rbp-96], RAX
; 设置变量i
    jmp end_if_164
    else_if_164:
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_165
    and_mid_17:
    mov RCX, QWORD[rbp-88]
    mov RAX, QWORD[rbp-96]
    add RCX, RAX
    movzx RAX, BYTE [RCX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 45
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_165
    if_165:
    mov QWORD[rbp-145], -1
; 设置变量expSign
    mov RCX, QWORD[rbp-96]
    mov RAX, 1
    mov QWORD[rbp-96], RCX
    add QWORD[rbp-96], RAX
; 设置变量i
    end_if_165:
    end_if_164:
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jae if_166
    sub rsp, 16; register args buffer
    mov RSI, QWORD[rbp-88]
    mov RAX, QWORD[rbp-96]
    add RSI, RAX
    movzx RAX, BYTE [RSI]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigitByte
    mov RCX, RAX
    cmp RCX, 0
    sete cl
    movzx RCX, cl
    mov RAX, RCX
; ||-chain leaf
    test RAX, RAX
    jnz if_166
    jz end_if_166
    if_166:
    mov RAX, 0x0
; return值存入RAX
    mov RDX, 0
; return值存入RDX
    jmp func_end_std_strings_parseFloat
    end_if_166:




    for_30: ; for循环开始
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_30_end
    for_and_mid_4:
    sub rsp, 16; register args buffer
    mov RCX, QWORD[rbp-88]
    mov RAX, QWORD[rbp-96]
    add RCX, RAX
    movzx RAX, BYTE [RCX]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigitByte
; condition
    test RAX, RAX
    jz for_30_end
    for_30_body:


    mov RCX, QWORD[rbp-153]
    mov RBX, 10
    imul RCX, RBX
    mov RBX, RCX
    mov RCX, QWORD[rbp-88]
    mov RDX, QWORD[rbp-96]
    add RCX, RDX
    movzx RAX, BYTE [RCX]
    mov RCX, 48
    sub RAX, RCX
    movzx RAX, al; zero-extend u8
    mov QWORD[rbp-153], RBX
    add QWORD[rbp-153], RAX
; 设置变量expVal
    mov RSI, QWORD[rbp-96]
    mov RAX, 1
    mov QWORD[rbp-96], RSI
    add QWORD[rbp-96], RAX
; 设置变量i
    for_30_continue:


    jmp for_30; for循环
    for_30_end: ; for循环结束
    end_if_163:
    mov DWORD[rbp-161], 0; 64bit low
    mov DWORD[rbp-157], 1072693248; 64bit high
; 设置变量pow10
    mov QWORD[rbp-169], 0
; 设置变量k




    for_31: ; for循环开始
    mov RAX, QWORD[rbp-169]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-153]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_31_end
    for_and_mid_5:
    mov RAX, QWORD[rbp-169]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 308
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_31_end
    for_31_body:


    mov RSI, QWORD[rbp-161]
    mov RAX, 0x4024000000000000
    movq XMM0, RSI
    movq XMM1, RAX
    mulsd XMM0, XMM1
    movq QWORD[rbp-161], XMM0
; 设置变量pow10
    mov RSI, QWORD[rbp-169]
    mov RAX, 1
    mov QWORD[rbp-169], RSI
    add QWORD[rbp-169], RAX
; 设置变量k
    for_31_continue:


    jmp for_31; for循环
    for_31_end: ; for循环结束
    mov RAX, QWORD[rbp-145]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_167
    if_167:
    mov RAX, QWORD[rbp-104]
    mov RDX, QWORD[rbp-137]
    movq XMM0, RAX
    movq XMM1, RDX
    mulsd XMM0, XMM1
    movq RAX, XMM0
    mov RDX, QWORD[rbp-161]
    movq XMM0, RAX
    movq XMM1, RDX
    divsd XMM0, XMM1
    movq RAX, XMM0
; return值存入RAX
    mov RDX, 1
; return值存入RDX
    jmp func_end_std_strings_parseFloat
    end_if_167:
    mov RAX, QWORD[rbp-104]
    mov RDX, QWORD[rbp-137]
    movq XMM0, RAX
    movq XMM1, RDX
    mulsd XMM0, XMM1
    movq RAX, XMM0
    mov RDX, QWORD[rbp-161]
    movq XMM0, RAX
    movq XMM1, RDX
    mulsd XMM0, XMM1
    movq RAX, XMM0
; return值存入RAX
    mov RDX, 1
; return值存入RDX
    jmp func_end_std_strings_parseFloat
    func_end_std_strings_parseFloat:
    add rsp, 216; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_isDigitByte progbits alloc exec nowrite align=16
global std_strings_isDigitByte
; ==============================
; Function: std_strings_isDigitByte
std_strings_isDigitByte:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov BYTE [rbp-48], DIL; 保存参数0到栈
    movzx RAX, BYTE[rbp-48]
    mov RBX, 48
    cmp RAX, RBX
    setge al
    movzx RAX, al
    movzx RBX, BYTE[rbp-48]
    mov RCX, 57
    cmp RBX, RCX
    setle bl
    movzx RBX, bl
    and RAX, RBX
; return值存入RAX
    jmp func_end_std_strings_isDigitByte
    func_end_std_strings_isDigitByte:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_isDigit progbits alloc exec nowrite align=16
global std_strings_isDigit
; ==============================
; Function: std_strings_isDigit
std_strings_isDigit:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov BYTE [rbp-48], DIL; 保存参数0到栈
    movzx RAX, BYTE[rbp-48]
    mov QWORD[rbp-56], RAX
; 设置变量bi
    mov RAX, QWORD[rbp-56]
    mov RBX, 48
    cmp RAX, RBX
    setge al
    movzx RAX, al
    mov RBX, QWORD[rbp-56]
    mov RCX, 57
    cmp RBX, RCX
    setle bl
    movzx RBX, bl
    and RAX, RBX
; return值存入RAX
    jmp func_end_std_strings_isDigit
    func_end_std_strings_isDigit:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_isIntDigit progbits alloc exec nowrite align=16
global std_strings_isIntDigit
; ==============================
; Function: std_strings_isIntDigit
std_strings_isIntDigit:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov BYTE [rbp-48], DIL; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD[rbp-64], 0
; 设置变量d
    movzx RAX, BYTE[rbp-48]
    mov QWORD[rbp-72], RAX
; 设置变量bi
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 48
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl else_if_168
    and_mid_18:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 57
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg else_if_168
    if_168:
    mov RAX, QWORD[rbp-72]
    mov RBX, 48
    mov QWORD[rbp-64], RAX
    sub QWORD[rbp-64], RBX
; 设置变量d
    jmp end_if_168
    else_if_168:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 97
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl else_if_169
    and_mid_19:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 102
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg else_if_169
    if_169:
    mov RBX, QWORD[rbp-72]
    mov RAX, 97
    sub RBX, RAX
    mov RAX, 10
    mov QWORD[rbp-64], RBX
    add QWORD[rbp-64], RAX
; 设置变量d
    jmp end_if_169
    else_if_169:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl else_if_170
    and_mid_20:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 70
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg else_if_170
    if_170:
    mov RBX, QWORD[rbp-72]
    mov RAX, 65
    sub RBX, RAX
    mov RAX, 10
    mov QWORD[rbp-64], RBX
    add QWORD[rbp-64], RAX
; 设置变量d
    jmp end_if_170
    else_if_170:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_isIntDigit
    end_if_170:
    end_if_169:
    end_if_168:
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-56]
    cmp RAX, RBX
    setl al
    movzx RAX, al
; return值存入RAX
    jmp func_end_std_strings_isIntDigit
    func_end_std_strings_isIntDigit:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_fromByte progbits alloc exec nowrite align=16
global std_strings_fromByte
; ==============================
; Function: std_strings_fromByte
std_strings_fromByte:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-72], R10; 保存返回槽地址
    mov BYTE [rbp-48], DIL; 保存参数0到栈
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 2
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-56], RAX
; 设置变量buf
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-64], RAX
; 设置变量bufu8
    movzx RAX, BYTE[rbp-48]
    mov RBX, QWORD[rbp-64]
    mov BYTE [RBX], al
; expression statement
    mov RAX, 0
    mov RBX, QWORD[rbp-64]
    mov RCX, 1
    add RBX, RCX
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov QWORD [rsp+16], 1
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-96]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-96]
    mov QWORD [rbp-96+0], RAX
    mov RAX, QWORD [RBP-96+8]
    mov QWORD [rbp-96+8], RAX
    mov RAX, QWORD [RBP-96+16]
    mov QWORD [rbp-96+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-72]; 恢复返回槽地址
    mov RAX, QWORD [rbp-96]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-88]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_fromByte
    func_end_std_strings_fromByte:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_len progbits alloc exec nowrite align=16
global std_strings_len
global __string_len
; ==============================
; Function: std_strings_len
__string_len:
std_strings_len:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    lea RAX, [rbp-64]
    mov QWORD[rbp-72], RAX
; 设置变量p
    mov RAX, QWORD[rbp-72]
    mov RBX, 8
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量_p1
    mov RBX, QWORD[rbp-80]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_strings_len
    func_end_std_strings_len:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_cap progbits alloc exec nowrite align=16
global std_strings_cap
global __string_cap
; ==============================
; Function: std_strings_cap
__string_cap:
std_strings_cap:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    lea RAX, [rbp-64]
    mov QWORD[rbp-72], RAX
; 设置变量p
    mov RAX, QWORD[rbp-72]
    mov RBX, 16
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量_p2
    mov RBX, QWORD[rbp-80]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_strings_cap
    func_end_std_strings_cap:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_eq progbits alloc exec nowrite align=16
global std_strings_eq
global __string_eq
; ==============================
; Function: std_strings_eq
__string_eq:
std_strings_eq:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 136; 分配局部变量空间(136字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-88]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-88+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-88+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_171
    if_171:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_eq
    end_if_171:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_eq
    func_end_std_strings_eq:
    add rsp, 136; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_ne progbits alloc exec nowrite align=16
global std_strings_ne
global __string_ne
; ==============================
; Function: std_strings_ne
__string_ne:
std_strings_ne:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 136; 分配局部变量空间(136字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-88]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-88+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-88+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_172
    if_172:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_ne
    end_if_172:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_ne
    func_end_std_strings_ne:
    add rsp, 136; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_toCstring progbits alloc exec nowrite align=16
global std_strings_toCstring
global __string_toCstring
; ==============================
; Function: std_strings_toCstring
__string_toCstring:
std_strings_toCstring:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 200; 分配局部变量空间(200字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov RDI, QWORD [rbp-64]
    mov RSI, QWORD [rbp-64+8]
    mov RDX, QWORD [rbp-64+16]
    call __string_len
    mov QWORD[rbp-72], RAX
; 设置变量n
    mov RAX, QWORD[rbp-72]
    mov RBX, 1
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量bufN
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-88], RAX
; 设置变量buf
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-96], RAX
; 设置变量src
    mov QWORD[rbp-104], 0
; 设置变量i




    for_32: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_32_end
    for_32_body:


    mov RAX, QWORD[rbp-88]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-112], RAX
    add QWORD[rbp-112], RBX
; 设置变量_dst
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量_src
    mov RAX, QWORD[rbp-120]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-128], RAX
; 设置变量_ch
    mov RAX, QWORD[rbp-128]
    mov RBX, QWORD[rbp-112]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-104]
    mov RBX, 1
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量i
    for_32_continue:


    jmp for_32; for循环
    for_32_end: ; for循环结束
    mov RAX, QWORD[rbp-88]
    mov RBX, QWORD[rbp-72]
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量_tail
    mov RAX, 0
    mov RBX, QWORD[rbp-136]
    mov BYTE [RBX], al
; expression statement
    mov QWORD[rbp-144], 0
; 设置变量r
    lea RAX, [rbp-144]
    mov QWORD[rbp-152], RAX
; 设置变量rp
    mov RBX, QWORD[rbp-88]
    mov RAX, QWORD[rbp-152]
    mov QWORD [RAX], RBX
; expression statement
    mov RAX, QWORD[rbp-144]
; return值存入RAX
    jmp func_end_std_strings_toCstring
    func_end_std_strings_toCstring:
    add rsp, 200; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_toU64 progbits alloc exec nowrite align=16
global std_strings_toU64
global __string_toU64
; ==============================
; Function: std_strings_toU64
__string_toU64:
std_strings_toU64:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    lea RAX, [rbp-48]
    mov QWORD[rbp-56], RAX
; 设置变量p
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-64], RAX
; 设置变量_p12
    mov RBX, QWORD[rbp-64]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_strings_toU64
    func_end_std_strings_toU64:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_fromI64 progbits alloc exec nowrite align=16
global std_strings_fromI64
global __string_fromI64
; ==============================
; Function: std_strings_fromI64
__string_fromI64:
std_strings_fromI64:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD[rbp-56], 0
; 设置变量x
    lea RAX, [rbp-56]
    mov QWORD[rbp-64], RAX
; 设置变量p
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-72], RAX
; 设置变量_p13
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-72]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, QWORD[rbp-56]
; return值存入RAX
    jmp func_end_std_strings_fromI64
    func_end_std_strings_fromI64:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_toString progbits alloc exec nowrite align=16
global std_strings_toString
global __string_toString
; ==============================
; Function: std_strings_toString
__string_toString:
std_strings_toString:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 280; 分配局部变量空间(280字节, 含对齐)
    mov QWORD [rbp-248], R10; 保存返回槽地址
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov BYTE[rbp-57], 0
; 设置变量neg
    mov QWORD[rbp-65], 0
; 设置变量num
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge else_if_173
    if_173:
    mov BYTE[rbp-57], 1
; 设置变量neg
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], 0
    sub QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64
    mov QWORD[rbp-65], RAX
; 设置变量num
    jmp end_if_173
    else_if_173:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64
    mov QWORD[rbp-65], RAX
; 设置变量num
    end_if_173:
    mov QWORD[rbp-73], 1
; 设置变量digits
    mov RAX, QWORD[rbp-65]
    mov QWORD[rbp-81], RAX
; 设置变量tmp




    for_33: ; for循环开始
    mov RAX, QWORD[rbp-81]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb for_33_end
    for_33_body:


    mov RAX, QWORD[rbp-81]
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-81], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-81]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-81], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量tmp
    mov RAX, QWORD[rbp-73]
    mov RBX, 1
    mov QWORD[rbp-73], RAX
    add QWORD[rbp-73], RBX
; 设置变量digits
    for_33_continue:


    jmp for_33; for循环
    for_33_end: ; for循环结束
    mov RAX, QWORD[rbp-73]
    mov QWORD[rbp-89], RAX
; 设置变量total
    movzx RAX, BYTE[rbp-57]
; condition
    test RAX, RAX
    jz end_if_174
    if_174:
    mov RAX, QWORD[rbp-89]
    mov RBX, 1
    mov QWORD[rbp-89], RAX
    add QWORD[rbp-89], RBX
; 设置变量total
    end_if_174:
    mov RAX, QWORD[rbp-89]
    mov RBX, 1
    mov QWORD[rbp-97], RAX
    add QWORD[rbp-97], RBX
; 设置变量bufN
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-97]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-105], RAX
; 设置变量buf
    mov RAX, QWORD[rbp-65]
    mov QWORD[rbp-113], RAX
; 设置变量v
    mov RAX, QWORD[rbp-113]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne else_if_175
    if_175:
    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-121], RAX
; 设置变量_p14
    mov RAX, 48
    mov RBX, QWORD[rbp-121]
    mov BYTE [RBX], al
; expression statement
    jmp end_if_175
    else_if_175:
    mov QWORD[rbp-129], 0
; 设置变量i




    for_34: ; for循环开始
    mov RAX, QWORD[rbp-113]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_34_end
    for_34_body:


    mov RAX, QWORD[rbp-113]
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-137], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-137]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-137], rdx
    pop RAX; 恢复RAX(左子结果)
; 设置变量digit
    mov QWORD[rbp-145], 0
; 设置变量ch
    mov RAX, QWORD[rbp-137]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 10
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_176
    if_176:
    mov RAX, QWORD[rbp-137]
    mov RBX, 48
    mov QWORD[rbp-145], RAX
    add QWORD[rbp-145], RBX
; 设置变量ch
    jmp end_if_176
    else_if_176:
    mov RAX, QWORD[rbp-137]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 36
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_177
    if_177:
    mov RAX, QWORD[rbp-137]
    mov RBX, 97
    add RAX, RBX
    mov RBX, 10
    mov QWORD[rbp-145], RAX
    sub QWORD[rbp-145], RBX
; 设置变量ch
    jmp end_if_177
    else_if_177:
    mov RAX, QWORD[rbp-137]
    mov RBX, 65
    add RAX, RBX
    mov RBX, 36
    mov QWORD[rbp-145], RAX
    sub QWORD[rbp-145], RBX
; 设置变量ch
    end_if_177:
    end_if_176:
    mov RAX, QWORD[rbp-89]
    mov RBX, 1
    sub RAX, RBX
    mov RBX, QWORD[rbp-129]
    sub RAX, RBX
    mov RBX, QWORD[rbp-105]
    mov QWORD[rbp-153], RBX
    add QWORD[rbp-153], RAX
; 设置变量_p15
    mov RBX, QWORD[rbp-145]
    mov RAX, QWORD[rbp-153]
    mov BYTE [RAX], bl
; expression statement
    mov RAX, QWORD[rbp-113]
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-113], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-113]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-113], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量v
    mov RAX, QWORD[rbp-129]
    mov RBX, 1
    mov QWORD[rbp-129], RAX
    add QWORD[rbp-129], RBX
; 设置变量i
    for_34_continue:


    jmp for_34; for循环
    for_34_end: ; for循环结束
    end_if_175:
    movzx RAX, BYTE[rbp-57]
; condition
    test RAX, RAX
    jz end_if_178
    if_178:
    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-161], RAX
; 设置变量_p16
    mov RAX, 45
    mov RBX, QWORD[rbp-161]
    mov BYTE [RBX], al
; expression statement
    end_if_178:
    mov RAX, QWORD[rbp-105]
    mov RBX, QWORD[rbp-89]
    mov QWORD[rbp-169], RAX
    add QWORD[rbp-169], RBX
; 设置变量_p17
    mov RAX, 0
    mov RBX, QWORD[rbp-169]
    mov BYTE [RBX], al
; expression statement
    mov QWORD [rbp-193], 0
    mov QWORD [rbp-193+8], 0
    mov QWORD [rbp-193+16], 0
    ; 零值容器 s
    lea RAX, [rbp-193]
    mov QWORD[rbp-201], RAX
; 设置变量p
    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-209], RAX
; 设置变量b
    mov RAX, QWORD[rbp-201]
    mov QWORD[rbp-217], RAX
; 设置变量_p18
    mov RBX, QWORD[rbp-209]
    mov RAX, QWORD[rbp-217]
    mov QWORD [RAX], RBX
; expression statement
    mov RAX, QWORD[rbp-201]
    mov RBX, 8
    mov QWORD[rbp-225], RAX
    add QWORD[rbp-225], RBX
; 设置变量_p19
    mov RAX, QWORD[rbp-89]
    mov RBX, QWORD[rbp-225]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, QWORD[rbp-201]
    mov RBX, 16
    mov QWORD[rbp-233], RAX
    add QWORD[rbp-233], RBX
; 设置变量_p20
    mov RAX, QWORD[rbp-89]
    mov RBX, QWORD[rbp-233]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, QWORD [rbp-193]
    mov QWORD [rbp-272+0], RAX
    mov RAX, QWORD [rbp-193+8]
    mov QWORD [rbp-272+8], RAX
    mov RAX, QWORD [rbp-193+16]
    mov QWORD [rbp-272+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-248]; 恢复返回槽地址
    mov RAX, QWORD [rbp-272]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-264]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-256]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_toString
    func_end_std_strings_toString:
    add rsp, 280; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_parse progbits alloc exec nowrite align=16
global std_strings_parse
global __string_parse
; ==============================
; Function: std_strings_parse
__string_parse:
std_strings_parse:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 232; 分配局部变量空间(232字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1到栈
    lea RAX, [rbp-64]
    mov QWORD[rbp-80], RAX
; 设置变量p
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-88], RAX
; 设置变量_p21
    mov RAX, QWORD[rbp-88]
    mov RAX, QWORD [RAX]
    mov QWORD[rbp-96], RAX
; 设置变量ptrVal
    mov RAX, QWORD[rbp-80]
    mov RBX, 8
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量_p22
    mov RAX, QWORD[rbp-104]
    mov RAX, QWORD [RAX]
    mov QWORD[rbp-112], RAX
; 设置变量n
    mov QWORD[rbp-120], 0
; 设置变量i
    mov BYTE[rbp-121], 0
; 设置变量neg
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-129], RAX
; 设置变量_p23
    mov RAX, QWORD[rbp-129]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-137], RAX
; 设置变量c
    mov RAX, QWORD[rbp-137]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 45
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_179
    if_179:
    mov BYTE[rbp-121], 1
; 设置变量neg
    mov QWORD[rbp-120], 1
; 设置变量i
    end_if_179:
    mov QWORD[rbp-145], 0
; 设置变量val
    mov BYTE[rbp-146], 0
; 设置变量bad




    for_35: ; for循环开始
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-112]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_35_end
    for_35_body:


    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-120]
    mov QWORD[rbp-154], RAX
    add QWORD[rbp-154], RBX
; 设置变量_p24
    mov RAX, QWORD[rbp-154]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-162], RAX
; 设置变量d
    mov QWORD[rbp-170], 0
; 设置变量v
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 48
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_180
    and_mid_21:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 57
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_180
    if_180:
    mov RAX, QWORD[rbp-162]
    mov RBX, 48
    mov QWORD[rbp-170], RAX
    sub QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_180
    else_if_180:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 97
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_181
    and_mid_22:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 122
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_181
    if_181:
    mov RAX, QWORD[rbp-162]
    mov RBX, 97
    sub RAX, RBX
    mov RBX, 10
    mov QWORD[rbp-170], RAX
    add QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_181
    else_if_181:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_182
    and_mid_23:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 90
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_182
    if_182:
    mov RAX, QWORD[rbp-162]
    mov RBX, 65
    sub RAX, RBX
    mov RBX, 36
    mov QWORD[rbp-170], RAX
    add QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_182
    else_if_182:
    mov BYTE[rbp-146], 1
; 设置变量bad
    end_if_182:
    end_if_181:
    end_if_180:
    movzx RAX, BYTE[rbp-146]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_183
    if_183:
    mov RAX, QWORD[rbp-145]
    mov RBX, QWORD[rbp-72]
    imul RAX, RBX
    mov RBX, QWORD[rbp-170]
    mov QWORD[rbp-145], RAX
    add QWORD[rbp-145], RBX
; 设置变量val
    end_if_183:
    mov RAX, QWORD[rbp-120]
    mov RBX, 1
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量i
    for_35_continue:


    jmp for_35; for循环
    for_35_end: ; for循环结束
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-145]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_fromI64
    mov QWORD[rbp-178], RAX
; 设置变量r
    movzx RAX, BYTE[rbp-121]
; condition
    test RAX, RAX
    jz end_if_184
    if_184:
    mov RBX, QWORD[rbp-178]
    mov QWORD[rbp-178], 0
    sub QWORD[rbp-178], RBX
; 设置变量r
    end_if_184:
    mov RAX, QWORD[rbp-178]
; return值存入RAX
    jmp func_end_std_strings_parse
    func_end_std_strings_parse:
    add rsp, 232; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_notFound progbits alloc exec nowrite align=16
global std_strings_notFound
; ==============================
; Function: std_strings_notFound
std_strings_notFound:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD[rbp-48], -1
; 设置变量v
    lea RAX, [rbp-48]
    mov QWORD[rbp-56], RAX
; 设置变量p
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-64], RAX
; 设置变量_p25
    mov RBX, QWORD[rbp-64]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_strings_notFound
    func_end_std_strings_notFound:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_view progbits alloc exec nowrite align=16
global std_strings_view
; ==============================
; Function: std_strings_view
std_strings_view:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 168; 分配局部变量空间(168字节, 含对齐)
    mov QWORD [rbp-136], R10; 保存返回槽地址
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    mov QWORD [rbp-88], 0
    mov QWORD [rbp-88+8], 0
    mov QWORD [rbp-88+16], 0
    ; 零值容器 result
    lea RAX, [rbp-88]
    mov QWORD[rbp-96], RAX
; 设置变量rp
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-104], RAX
; 设置变量_p26
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-104]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, QWORD[rbp-96]
    mov RBX, 8
    mov QWORD[rbp-112], RAX
    add QWORD[rbp-112], RBX
; 设置变量_p27
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-112]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, QWORD[rbp-96]
    mov RBX, 16
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量_p28
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-120]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, QWORD [rbp-88]
    mov QWORD [rbp-160+0], RAX
    mov RAX, QWORD [rbp-88+8]
    mov QWORD [rbp-160+8], RAX
    mov RAX, QWORD [rbp-88+16]
    mov QWORD [rbp-160+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-136]; 恢复返回槽地址
    mov RAX, QWORD [rbp-160]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-152]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-144]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_view
    func_end_std_strings_view:
    add rsp, 168; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_indexFrom progbits alloc exec nowrite align=16
global std_strings_indexFrom
; ==============================
; Function: std_strings_indexFrom
std_strings_indexFrom:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 216; 分配局部变量空间(216字节, 含对齐)
    mov RAX, [rbp+16]; 保存栈参数2槽0到栈
    mov [rbp-96], RAX
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
    mov RDI, QWORD [rbp-64]
    mov RSI, QWORD [rbp-64+8]
    mov RDX, QWORD [rbp-64+16]
    call __string_len
    mov QWORD[rbp-104], RAX
; 设置变量sLen
    mov RDI, QWORD [rbp-88]
    mov RSI, QWORD [rbp-88+8]
    mov RDX, QWORD [rbp-88+16]
    call __string_len
    mov QWORD[rbp-112], RAX
; 设置变量tLen
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_185
    if_185:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    end_if_185:
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_186
    if_186:
    call std_strings_notFound
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    end_if_186:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-120], RAX
; 设置变量sPtr
    mov RAX, QWORD [rbp-88]
    mov QWORD [rbp-128], RAX
; 设置变量tPtr
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-136], RAX
; 设置变量i
    mov RAX, QWORD[rbp-104]
    mov RBX, QWORD[rbp-112]
    mov QWORD[rbp-144], RAX
    sub QWORD[rbp-144], RBX
; 设置变量limit




    for_36: ; for循环开始
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-144]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe for_36_end
    for_36_body:


    mov BYTE[rbp-145], 1
; 设置变量found
    mov QWORD[rbp-153], 0
; 设置变量j




    for_37: ; for循环开始
    mov RAX, QWORD[rbp-153]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-112]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_37_end
    for_37_body:


    mov RAX, QWORD[rbp-120]
    mov RBX, QWORD[rbp-136]
    add RAX, RBX
    mov RBX, QWORD[rbp-153]
    mov QWORD[rbp-161], RAX
    add QWORD[rbp-161], RBX
; 设置变量_p29
    mov RAX, QWORD[rbp-128]
    mov RBX, QWORD[rbp-153]
    mov QWORD[rbp-169], RAX
    add QWORD[rbp-169], RBX
; 设置变量_p30
    mov RAX, QWORD[rbp-161]
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RAX, QWORD[rbp-169]
    movzx RCX, BYTE [RAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_187
    if_187:
    mov BYTE[rbp-145], 0
; 设置变量found
    jmp for_37_end
    end_if_187:
    mov RAX, QWORD[rbp-153]
    mov RBX, 1
    mov QWORD[rbp-153], RAX
    add QWORD[rbp-153], RBX
; 设置变量j
    for_37_continue:


    jmp for_37; for循环
    for_37_end: ; for循环结束
    movzx RAX, BYTE[rbp-145]
; condition
    test RAX, RAX
    jz end_if_188
    if_188:
    mov RAX, QWORD[rbp-136]
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    end_if_188:
    mov RAX, QWORD[rbp-136]
    mov RBX, 1
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量i
    for_36_continue:


    jmp for_36; for循环
    for_36_end: ; for循环结束
    call std_strings_notFound
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    func_end_std_strings_indexFrom:
    add rsp, 216; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_print progbits alloc exec nowrite align=16
global std_console_print
; ==============================
; Function: std_console_print
std_console_print:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring
    mov QWORD[rbp-72], RAX
; 设置变量cstr
    sub rsp, 32; register args buffer
    mov EAX, DWORD[rel __global_std_console_STDOUT]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+8], RAX
; 参数1
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_syscall_write
    mov DWORD[rbp-76], EAX
; 设置变量n
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    mov EAX, DWORD[rbp-76]
; return值存入RAX
    jmp func_end_std_console_print
    func_end_std_console_print:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_println progbits alloc exec nowrite align=16
global std_console_println
; ==============================
; Function: std_console_println
std_console_println:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_print
    mov DWORD[rbp-68], EAX
; 设置变量n
    mov EAX, DWORD[rbp-68]
    mov RBX, RAX
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_5
    mov QWORD [rsp+0+8], 1
    mov QWORD [rsp+0+16], 1
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_print
    mov DWORD[rbp-68], EBX
    add DWORD[rbp-68], EAX
; 设置变量n
    mov EAX, DWORD[rbp-68]
; return值存入RAX
    jmp func_end_std_console_println
    func_end_std_console_println:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_kwTable progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_kwTable
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_kwTable
_home_gx_Desktop_tiny_selfhost_lexer_kwTable:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-56], R10; 保存返回槽地址
    movzx RAX, BYTE[rel __global__home_gx_Desktop_tiny_selfhost_lexer_gKwReady]
; condition
    test RAX, RAX
    jz end_if_189
    if_189:
    mov RAX, QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gKwList]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gKwList+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gKwList+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_kwTable
    end_if_189:
    mov RDI, 720
    call std_memory_malloc
    mov R12, RAX; list buffer
    mov QWORD [R12+0], str_35
    mov QWORD [R12+8], 5
    mov QWORD [R12+16], 5
    mov QWORD [R12+24], str_36
    mov QWORD [R12+32], 5
    mov QWORD [R12+40], 5
    mov QWORD [R12+48], str_37
    mov QWORD [R12+56], 4
    mov QWORD [R12+64], 4
    mov QWORD [R12+72], str_38
    mov QWORD [R12+80], 5
    mov QWORD [R12+88], 5
    mov QWORD [R12+96], str_39
    mov QWORD [R12+104], 8
    mov QWORD [R12+112], 8
    mov QWORD [R12+120], str_40
    mov QWORD [R12+128], 7
    mov QWORD [R12+136], 7
    mov QWORD [R12+144], str_41
    mov QWORD [R12+152], 5
    mov QWORD [R12+160], 5
    mov QWORD [R12+168], str_42
    mov QWORD [R12+176], 4
    mov QWORD [R12+184], 4
    mov QWORD [R12+192], str_43
    mov QWORD [R12+200], 4
    mov QWORD [R12+208], 4
    mov QWORD [R12+216], str_44
    mov QWORD [R12+224], 6
    mov QWORD [R12+232], 6
    mov QWORD [R12+240], str_45
    mov QWORD [R12+248], 11
    mov QWORD [R12+256], 11
    mov QWORD [R12+264], str_46
    mov QWORD [R12+272], 5
    mov QWORD [R12+280], 5
    mov QWORD [R12+288], str_47
    mov QWORD [R12+296], 7
    mov QWORD [R12+304], 7
    mov QWORD [R12+312], str_48
    mov QWORD [R12+320], 2
    mov QWORD [R12+328], 2
    mov QWORD [R12+336], str_49
    mov QWORD [R12+344], 3
    mov QWORD [R12+352], 3
    mov QWORD [R12+360], str_50
    mov QWORD [R12+368], 2
    mov QWORD [R12+376], 2
    mov QWORD [R12+384], str_51
    mov QWORD [R12+392], 6
    mov QWORD [R12+400], 6
    mov QWORD [R12+408], str_52
    mov QWORD [R12+416], 9
    mov QWORD [R12+424], 9
    mov QWORD [R12+432], str_53
    mov QWORD [R12+440], 3
    mov QWORD [R12+448], 3
    mov QWORD [R12+456], str_54
    mov QWORD [R12+464], 3
    mov QWORD [R12+472], 3
    mov QWORD [R12+480], str_55
    mov QWORD [R12+488], 5
    mov QWORD [R12+496], 5
    mov QWORD [R12+504], str_56
    mov QWORD [R12+512], 3
    mov QWORD [R12+520], 3
    mov QWORD [R12+528], str_57
    mov QWORD [R12+536], 6
    mov QWORD [R12+544], 6
    mov QWORD [R12+552], str_58
    mov QWORD [R12+560], 6
    mov QWORD [R12+568], 6
    mov QWORD [R12+576], str_59
    mov QWORD [R12+584], 6
    mov QWORD [R12+592], 6
    mov QWORD [R12+600], str_60
    mov QWORD [R12+608], 4
    mov QWORD [R12+616], 4
    mov QWORD [R12+624], str_61
    mov QWORD [R12+632], 3
    mov QWORD [R12+640], 3
    mov QWORD [R12+648], str_62
    mov QWORD [R12+656], 4
    mov QWORD [R12+664], 4
    mov QWORD [R12+672], str_63
    mov QWORD [R12+680], 3
    mov QWORD [R12+688], 3
    mov QWORD [R12+696], str_64
    mov QWORD [R12+704], 5
    mov QWORD [R12+712], 5
    mov QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gKwList], R12
    mov QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gKwList+8], 30
    mov QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gKwList+16], 30
; 设置变量gKwList
    mov BYTE[rel __global__home_gx_Desktop_tiny_selfhost_lexer_gKwReady], 1
; 设置变量gKwReady
    mov RAX, QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gKwList]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gKwList+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gKwList+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_kwTable
    func_end__home_gx_Desktop_tiny_selfhost_lexer_kwTable:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_delimTable progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_delimTable
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_delimTable
_home_gx_Desktop_tiny_selfhost_lexer_delimTable:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-72], R10; 保存返回槽地址
    movzx RAX, BYTE[rel __global__home_gx_Desktop_tiny_selfhost_lexer_gDelimReady]
; condition
    test RAX, RAX
    jz end_if_190
    if_190:
    mov RAX, QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gDelimList]
    mov QWORD [rbp-96+0], RAX
    mov RAX, QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gDelimList+8]
    mov QWORD [rbp-96+8], RAX
    mov RAX, QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gDelimList+16]
    mov QWORD [rbp-96+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-72]; 恢复返回槽地址
    mov RAX, QWORD [rbp-96]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-88]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_delimTable
    end_if_190:
    mov RDI, 1392
    call std_memory_malloc
    mov R12, RAX; list buffer
    mov QWORD [R12+0], 0
    mov QWORD [R12+8], 0
    mov QWORD [R12+16], 0
    mov QWORD [R12+24], 0
    mov QWORD [R12+32], 0
    mov QWORD [R12+40], 0
    mov QWORD [R12+48], 0
    mov QWORD [R12+56], 0
    mov QWORD [R12+64], 0
    mov QWORD [R12+72], str_65
    mov QWORD [R12+80], 1
    mov QWORD [R12+88], 1
    mov QWORD [R12+96], str_66
    mov QWORD [R12+104], 1
    mov QWORD [R12+112], 1
    mov QWORD [R12+120], str_67
    mov QWORD [R12+128], 2
    mov QWORD [R12+136], 2
    mov QWORD [R12+144], str_68
    mov QWORD [R12+152], 1
    mov QWORD [R12+160], 1
    mov QWORD [R12+168], str_69
    mov QWORD [R12+176], 1
    mov QWORD [R12+184], 1
    mov QWORD [R12+192], str_70
    mov QWORD [R12+200], 2
    mov QWORD [R12+208], 2
    mov QWORD [R12+216], str_71
    mov QWORD [R12+224], 1
    mov QWORD [R12+232], 1
    mov QWORD [R12+240], str_72
    mov QWORD [R12+248], 2
    mov QWORD [R12+256], 2
    mov QWORD [R12+264], str_73
    mov QWORD [R12+272], 2
    mov QWORD [R12+280], 2
    mov QWORD [R12+288], str_74
    mov QWORD [R12+296], 1
    mov QWORD [R12+304], 1
    mov QWORD [R12+312], str_75
    mov QWORD [R12+320], 1
    mov QWORD [R12+328], 1
    mov QWORD [R12+336], str_76
    mov QWORD [R12+344], 1
    mov QWORD [R12+352], 1
    mov QWORD [R12+360], str_77
    mov QWORD [R12+368], 1
    mov QWORD [R12+376], 1
    mov QWORD [R12+384], str_78
    mov QWORD [R12+392], 2
    mov QWORD [R12+400], 2
    mov QWORD [R12+408], str_79
    mov QWORD [R12+416], 1
    mov QWORD [R12+424], 1
    mov QWORD [R12+432], str_80
    mov QWORD [R12+440], 2
    mov QWORD [R12+448], 2
    mov QWORD [R12+456], str_81
    mov QWORD [R12+464], 2
    mov QWORD [R12+472], 2
    mov QWORD [R12+480], str_82
    mov QWORD [R12+488], 1
    mov QWORD [R12+496], 1
    mov QWORD [R12+504], str_83
    mov QWORD [R12+512], 1
    mov QWORD [R12+520], 1
    mov QWORD [R12+528], str_84
    mov QWORD [R12+536], 2
    mov QWORD [R12+544], 2
    mov QWORD [R12+552], str_85
    mov QWORD [R12+560], 2
    mov QWORD [R12+568], 2
    mov QWORD [R12+576], str_86
    mov QWORD [R12+584], 2
    mov QWORD [R12+592], 2
    mov QWORD [R12+600], str_87
    mov QWORD [R12+608], 1
    mov QWORD [R12+616], 1
    mov QWORD [R12+624], str_88
    mov QWORD [R12+632], 3
    mov QWORD [R12+640], 3
    mov QWORD [R12+648], str_89
    mov QWORD [R12+656], 1
    mov QWORD [R12+664], 1
    mov QWORD [R12+672], str_90
    mov QWORD [R12+680], 2
    mov QWORD [R12+688], 2
    mov QWORD [R12+696], str_91
    mov QWORD [R12+704], 2
    mov QWORD [R12+712], 2
    mov QWORD [R12+720], str_92
    mov QWORD [R12+728], 2
    mov QWORD [R12+736], 2
    mov QWORD [R12+744], str_93
    mov QWORD [R12+752], 1
    mov QWORD [R12+760], 1
    mov QWORD [R12+768], str_94
    mov QWORD [R12+776], 2
    mov QWORD [R12+784], 2
    mov QWORD [R12+792], str_95
    mov QWORD [R12+800], 1
    mov QWORD [R12+808], 1
    mov QWORD [R12+816], str_96
    mov QWORD [R12+824], 1
    mov QWORD [R12+832], 1
    mov QWORD [R12+840], str_97
    mov QWORD [R12+848], 2
    mov QWORD [R12+856], 2
    mov QWORD [R12+864], str_98
    mov QWORD [R12+872], 3
    mov QWORD [R12+880], 3
    mov QWORD [R12+888], str_99
    mov QWORD [R12+896], 2
    mov QWORD [R12+904], 2
    mov QWORD [R12+912], str_100
    mov QWORD [R12+920], 1
    mov QWORD [R12+928], 1
    mov QWORD [R12+936], str_101
    mov QWORD [R12+944], 2
    mov QWORD [R12+952], 2
    mov QWORD [R12+960], str_102
    mov QWORD [R12+968], 1
    mov QWORD [R12+976], 1
    mov QWORD [R12+984], str_103
    mov QWORD [R12+992], 2
    mov QWORD [R12+1000], 2
    mov QWORD [R12+1008], str_104
    mov QWORD [R12+1016], 2
    mov QWORD [R12+1024], 2
    mov QWORD [R12+1032], str_105
    mov QWORD [R12+1040], 3
    mov QWORD [R12+1048], 3
    mov QWORD [R12+1056], str_106
    mov QWORD [R12+1064], 1
    mov QWORD [R12+1072], 1
    mov QWORD [R12+1080], str_107
    mov QWORD [R12+1088], 1
    mov QWORD [R12+1096], 1
    mov QWORD [R12+1104], str_108
    mov QWORD [R12+1112], 1
    mov QWORD [R12+1120], 1
    mov QWORD [R12+1128], str_109
    mov QWORD [R12+1136], 1
    mov QWORD [R12+1144], 1
    mov QWORD [R12+1152], str_110
    mov QWORD [R12+1160], 1
    mov QWORD [R12+1168], 1
    mov QWORD [R12+1176], str_111
    mov QWORD [R12+1184], 1
    mov QWORD [R12+1192], 1
    mov QWORD [R12+1200], str_112
    mov QWORD [R12+1208], 2
    mov QWORD [R12+1216], 2
    mov QWORD [R12+1224], str_113
    mov QWORD [R12+1232], 1
    mov QWORD [R12+1240], 1
    mov QWORD [R12+1248], str_114
    mov QWORD [R12+1256], 1
    mov QWORD [R12+1264], 1
    mov QWORD [R12+1272], str_115
    mov QWORD [R12+1280], 1
    mov QWORD [R12+1288], 1
    mov QWORD [R12+1296], str_116
    mov QWORD [R12+1304], 2
    mov QWORD [R12+1312], 2
    mov QWORD [R12+1320], str_117
    mov QWORD [R12+1328], 2
    mov QWORD [R12+1336], 2
    mov QWORD [R12+1344], str_118
    mov QWORD [R12+1352], 1
    mov QWORD [R12+1360], 1
    mov QWORD [R12+1368], str_119
    mov QWORD [R12+1376], 1
    mov QWORD [R12+1384], 1
    mov QWORD [rbp-64], R12
    mov QWORD [rbp-64+8], 58
    mov QWORD [rbp-64+16], 58
; 设置变量ds
    mov RBX, QWORD [rbp-64]
    mov QWORD [RBX], str_120
    mov QWORD [RBX+8], 1
    mov QWORD [RBX+16], 1
; list index assignment
    mov R12, QWORD [rbp-64]
    add R12, 24
    mov QWORD [R12], str_5
    mov QWORD [R12+8], 1
    mov QWORD [R12+16], 1
; list index assignment
    mov R13, QWORD [rbp-64]
    add R13, 48
    mov QWORD [R13], str_121
    mov QWORD [R13+8], 1
    mov QWORD [R13+16], 1
; list index assignment
    mov RAX, QWORD [rbp-64]
    mov QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gDelimList+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gDelimList+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gDelimList+16], RAX
; 设置变量gDelimList
    mov BYTE[rel __global__home_gx_Desktop_tiny_selfhost_lexer_gDelimReady], 1
; 设置变量gDelimReady
    mov RAX, QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gDelimList]
    mov QWORD [rbp-96+0], RAX
    mov RAX, QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gDelimList+8]
    mov QWORD [rbp-96+8], RAX
    mov RAX, QWORD [rel __global__home_gx_Desktop_tiny_selfhost_lexer_gDelimList+16]
    mov QWORD [rbp-96+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-72]; 恢复返回槽地址
    mov RAX, QWORD [rbp-96]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-88]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_delimTable
    func_end__home_gx_Desktop_tiny_selfhost_lexer_delimTable:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_isKeyword progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_isKeyword
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_isKeyword
_home_gx_Desktop_tiny_selfhost_lexer_isKeyword:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 168; 分配局部变量空间(168字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], 0; gc: zero exit slot kwList
    lea R10, [rbp-160]; 大值返回槽地址
    call _home_gx_Desktop_tiny_selfhost_lexer_kwTable
    mov RAX, QWORD [RBP-160]
    mov QWORD [rbp-88+0], RAX
    mov RAX, QWORD [RBP-160+8]
    mov QWORD [rbp-88+8], RAX
    mov RAX, QWORD [RBP-160+16]
    mov QWORD [rbp-88+16], RAX
; 设置变量kwList
    mov QWORD[rbp-96], 0
; 设置变量lo
    mov RAX, QWORD [rbp-88+8]
    mov RBX, 1
    mov QWORD[rbp-104], RAX
    sub QWORD[rbp-104], RBX
; 设置变量hi




    for_38: ; for循环开始
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg for_38_end
    for_38_body:


    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-104]
    add RAX, RBX
    mov RBX, 2
    mov QWORD[rbp-112], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-112]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-112], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量mid
    sub rsp, 48; register args buffer
    mov RAX, QWORD[rbp-112]
    test RAX, RAX
    jge idx_norm_ok_34d5186864b0
    add RAX, QWORD [rbp-88+8]
    idx_norm_ok_34d5186864b0:
    test RAX, RAX
    js idx_oob_34d5186865a0
    cmp QWORD [rbp-88+8], RAX
    jg idx_ok_34d5186865a0
    idx_oob_34d5186865a0:
    push RAX
    call _panic_index_oob
    idx_ok_34d5186865a0:
    mov RBX, QWORD [rbp-88]
    imul RAX, 24
    add RBX, RAX
    mov RCX, RBX; copySlots base
    mov RAX, QWORD [RCX]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RCX+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RCX+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_compare
    mov QWORD[rbp-120], RAX
; 设置变量cmp
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_191
    if_191:
    mov RAX, 1
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_isKeyword
    end_if_191:
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge else_if_192
    if_192:
    mov RBX, QWORD[rbp-112]
    mov RAX, 1
    mov QWORD[rbp-96], RBX
    add QWORD[rbp-96], RAX
; 设置变量lo
    jmp end_if_192
    else_if_192:
    mov RBX, QWORD[rbp-112]
    mov RAX, 1
    mov QWORD[rbp-104], RBX
    sub QWORD[rbp-104], RAX
; 设置变量hi
    end_if_192:
    for_38_continue:


    jmp for_38; for循环
    for_38_end: ; for循环结束
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_isKeyword
    func_end__home_gx_Desktop_tiny_selfhost_lexer_isKeyword:
    push rax; 保存返回值
    push rdx; 保存返回值(第二槽)
    ; gc: free kwList
    lea RDI, [rbp-88]
    call std_memory_freeSlot
    pop rdx; 恢复返回值(第二槽)
    pop rax; 恢复返回值
    add rsp, 168; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_isDelimiter progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_isDelimiter
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_isDelimiter
_home_gx_Desktop_tiny_selfhost_lexer_isDelimiter:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 168; 分配局部变量空间(168字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], 0; gc: zero exit slot delimList
    lea R10, [rbp-160]; 大值返回槽地址
    call _home_gx_Desktop_tiny_selfhost_lexer_delimTable
    mov RAX, QWORD [RBP-160]
    mov QWORD [rbp-88+0], RAX
    mov RAX, QWORD [RBP-160+8]
    mov QWORD [rbp-88+8], RAX
    mov RAX, QWORD [RBP-160+16]
    mov QWORD [rbp-88+16], RAX
; 设置变量delimList
    mov QWORD[rbp-96], 0
; 设置变量lo
    mov RAX, QWORD [rbp-88+8]
    mov RBX, 1
    mov QWORD[rbp-104], RAX
    sub QWORD[rbp-104], RBX
; 设置变量hi




    for_39: ; for循环开始
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg for_39_end
    for_39_body:


    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-104]
    add RAX, RBX
    mov RBX, 2
    mov QWORD[rbp-112], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-112]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-112], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量mid
    sub rsp, 48; register args buffer
    mov RAX, QWORD[rbp-112]
    test RAX, RAX
    jge idx_norm_ok_34d5181b24b0
    add RAX, QWORD [rbp-88+8]
    idx_norm_ok_34d5181b24b0:
    test RAX, RAX
    js idx_oob_34d5181b25a0
    cmp QWORD [rbp-88+8], RAX
    jg idx_ok_34d5181b25a0
    idx_oob_34d5181b25a0:
    push RAX
    call _panic_index_oob
    idx_ok_34d5181b25a0:
    mov RBX, QWORD [rbp-88]
    imul RAX, 24
    add RBX, RAX
    mov RCX, RBX; copySlots base
    mov RAX, QWORD [RCX]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RCX+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RCX+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_compare
    mov QWORD[rbp-120], RAX
; 设置变量cmp
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_193
    if_193:
    mov RAX, 1
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_isDelimiter
    end_if_193:
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge else_if_194
    if_194:
    mov RBX, QWORD[rbp-112]
    mov RAX, 1
    mov QWORD[rbp-96], RBX
    add QWORD[rbp-96], RAX
; 设置变量lo
    jmp end_if_194
    else_if_194:
    mov RBX, QWORD[rbp-112]
    mov RAX, 1
    mov QWORD[rbp-104], RBX
    sub QWORD[rbp-104], RAX
; 设置变量hi
    end_if_194:
    for_39_continue:


    jmp for_39; for循环
    for_39_end: ; for循环结束
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_isDelimiter
    func_end__home_gx_Desktop_tiny_selfhost_lexer_isDelimiter:
    push rax; 保存返回值
    push rdx; 保存返回值(第二槽)
    ; gc: free delimList
    lea RDI, [rbp-88]
    call std_memory_freeSlot
    pop rdx; 恢复返回值(第二槽)
    pop rax; 恢复返回值
    add rsp, 168; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_TokenType_string progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_TokenType_string
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_TokenType_string
_home_gx_Desktop_tiny_selfhost_lexer_TokenType_string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-56], R10; 保存返回槽地址
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; switch target
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NONE]
; case value
    mov R12, RAX; 保存switch目标到callee-save
    cmp RAX, RCX
    mov RAX, R12; 恢复switch目标
    je case_switch_1_0
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_STRING]
; case value
    mov R12, RAX; 保存switch目标到callee-save
    cmp RAX, RCX
    mov RAX, R12; 恢复switch目标
    je case_switch_1_1
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_KEYWORD]
; case value
    mov R12, RAX; 保存switch目标到callee-save
    cmp RAX, RCX
    mov RAX, R12; 恢复switch目标
    je case_switch_1_2
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_DELIMITER]
; case value
    mov R12, RAX; 保存switch目标到callee-save
    cmp RAX, RCX
    mov RAX, R12; 恢复switch目标
    je case_switch_1_3
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NUMBER]
; case value
    mov R12, RAX; 保存switch目标到callee-save
    cmp RAX, RCX
    mov RAX, R12; 恢复switch目标
    je case_switch_1_4
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NAME]
; case value
    mov R12, RAX; 保存switch目标到callee-save
    cmp RAX, RCX
    mov RAX, R12; 恢复switch目标
    je case_switch_1_5
    jmp case_switch_1_6
    case_switch_1_0:
    mov QWORD QWORD[rbp-80], str_122
    mov QWORD [rbp-80+8], 4
    mov QWORD [rbp-80+16], 4
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_TokenType_string
    jmp switch_end_switch_1
    case_switch_1_1:
    mov QWORD QWORD[rbp-80], str_123
    mov QWORD [rbp-80+8], 6
    mov QWORD [rbp-80+16], 6
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_TokenType_string
    jmp switch_end_switch_1
    case_switch_1_2:
    mov QWORD QWORD[rbp-80], str_124
    mov QWORD [rbp-80+8], 7
    mov QWORD [rbp-80+16], 7
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_TokenType_string
    jmp switch_end_switch_1
    case_switch_1_3:
    mov QWORD QWORD[rbp-80], str_125
    mov QWORD [rbp-80+8], 9
    mov QWORD [rbp-80+16], 9
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_TokenType_string
    jmp switch_end_switch_1
    case_switch_1_4:
    mov QWORD QWORD[rbp-80], str_126
    mov QWORD [rbp-80+8], 6
    mov QWORD [rbp-80+16], 6
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_TokenType_string
    jmp switch_end_switch_1
    case_switch_1_5:
    mov QWORD QWORD[rbp-80], str_127
    mov QWORD [rbp-80+8], 4
    mov QWORD [rbp-80+16], 4
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_TokenType_string
    jmp switch_end_switch_1
    case_switch_1_6:
    mov QWORD QWORD[rbp-80], str_122
    mov QWORD [rbp-80+8], 4
    mov QWORD [rbp-80+16], 4
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_TokenType_string
    jmp switch_end_switch_1
    switch_end_switch_1:
    func_end__home_gx_Desktop_tiny_selfhost_lexer_TokenType_string:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Token_string progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Token_string
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Token_string
_home_gx_Desktop_tiny_selfhost_lexer_Token_string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 136; 分配局部变量空间(136字节, 含对齐)
    mov QWORD [rbp-128], 0; gc ret scratch 清零
    mov QWORD [rbp-120], 0; gc ret scratch 清零
    mov QWORD [rbp-88], R10; 保存返回槽地址
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-56], RAX
; 设置变量tt
    mov RSI, str_108
    mov RDI, 1
    push RSI
    push RDI
    sub rsp, 16; register args buffer
    mov R8, QWORD[rbp-56]
    mov QWORD [rsp+0], R8
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-112]; 大值返回槽地址
    call _home_gx_Desktop_tiny_selfhost_lexer_TokenType_string
    mov RSI, QWORD [RBP-112]
    mov RDI, QWORD [RBP-112+8]
    push RSI
    push RDI
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [RBP-112], RAX
    mov QWORD [RBP-112+8], R9
    mov QWORD [RBP-112+16], R12
    mov QWORD [rbp-120], RAX; gc scratch concat
    mov RCX, QWORD [RBP-112]
    mov RDX, QWORD [RBP-112+8]
    push RCX
    push RDX
    mov RCX, str_110
    mov RDX, 1
    push RCX
    push RDX
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [RBP-112], RAX
    mov QWORD [RBP-112+8], R9
    mov QWORD [RBP-112+16], R12
    mov QWORD [rbp-128], RAX; gc scratch concat
    mov RAX, QWORD [RBP-112]
    mov RBX, QWORD [RBP-112+8]
    push RAX
    push RBX
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+24]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RBX+24+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RBX+24+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-112]; 大值返回槽地址
    call _home_gx_Desktop_tiny_selfhost_lexer_renderVisible
    mov RSI, QWORD [RBP-112]
    mov RAX, QWORD [RBP-112+8]
    push RSI
    push RAX
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [rbp-80], RAX
    mov QWORD [rbp-80+8], R9
    mov QWORD [rbp-80+16], R12
; 设置变量sb
    ; gc: assign temp free $cond0
    lea RDI, [rbp-128]
    call std_memory_freeSlot
    ; gc: assign temp free $cond1
    lea RDI, [rbp-120]
    call std_memory_freeSlot
    mov RAX, QWORD [rbp-80]
    mov QWORD [rbp-112+0], RAX
    mov RAX, QWORD [rbp-80+8]
    mov QWORD [rbp-112+8], RAX
    mov RAX, QWORD [rbp-80+16]
    mov QWORD [rbp-112+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-88]; 恢复返回槽地址
    mov RAX, QWORD [rbp-112]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-104]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-96]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_string
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_string:
    add rsp, 136; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Token_isLineEnd progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Token_isLineEnd
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Token_isLineEnd
_home_gx_Desktop_tiny_selfhost_lexer_Token_isLineEnd:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_195
    if_195:
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_isLineEnd
    end_if_195:
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_DELIMITER]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_196
    if_196:
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_isLineEnd
    end_if_196:
    mov RBX, QWORD[rbp+-48]
    mov RDI, QWORD [RBX+24]
    mov RSI, QWORD [RBX+24+8]
    mov RDX, QWORD [RBX+24+16]
    call __string_len
    mov RAX, RAX; len/cap 结果
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_197
    if_197:
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_isLineEnd
    end_if_197:
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+24]
    movzx RAX, BYTE [RAX]
    mov BYTE[rbp-49], al
; 设置变量b
    movzx RAX, BYTE[rbp-49]
    mov QWORD[rbp-57], RAX
; 设置变量bi
    mov RAX, QWORD[rbp-57]
    mov RBX, 10
    cmp RAX, RBX
    sete al
    movzx RAX, al
    mov RBX, QWORD[rbp-57]
    mov RCX, 13
    cmp RBX, RCX
    sete bl
    movzx RBX, bl
    or RAX, RBX
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_isLineEnd
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_isLineEnd:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Token_isSemiOrNewline progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Token_isSemiOrNewline
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Token_isSemiOrNewline
_home_gx_Desktop_tiny_selfhost_lexer_Token_isSemiOrNewline:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_198
    if_198:
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_isSemiOrNewline
    end_if_198:
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_DELIMITER]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_199
    if_199:
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_isSemiOrNewline
    end_if_199:
    sub rsp, 48; register args buffer
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+24]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RBX+24+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RBX+24+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_95
    mov QWORD [rsp+24+8], 1
    mov QWORD [rsp+24+16], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_eq
; condition
    test RAX, RAX
    jz end_if_200
    if_200:
    mov RAX, 1
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_isSemiOrNewline
    end_if_200:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Token_isLineEnd
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_isSemiOrNewline
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_isSemiOrNewline:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Token_is progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Token_is
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Token_is
_home_gx_Desktop_tiny_selfhost_lexer_Token_is:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD [rbp-80], RDX; 保存参数2槽0到栈
    mov QWORD [rbp-72], RCX; 保存参数2槽1到栈
    mov QWORD [rbp-64], R8; 保存参数2槽2到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_201
    if_201:
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_is
    end_if_201:
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_202
    if_202:
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_is
    end_if_202:
    sub rsp, 48; register args buffer
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+24]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RBX+24+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RBX+24+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-80]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-80+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-80+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_eq
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_is
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Token_is:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_renderVisible progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_renderVisible
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_renderVisible
_home_gx_Desktop_tiny_selfhost_lexer_renderVisible:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 184; 分配局部变量空间(184字节, 含对齐)
    mov QWORD [rbp-152], R10; 保存返回槽地址
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
    mov QWORD[rbp-72], RAX
; 设置变量n
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_203
    if_203:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-176+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rbp-176+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rbp-176+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-152]; 恢复返回槽地址
    mov RAX, QWORD [rbp-176]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-168]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-160]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_renderVisible
    end_if_203:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring
    mov QWORD[rbp-80], RAX
; 设置变量pU8
    mov RBX, QWORD[rbp-72]
    mov RAX, 2
    imul RAX, RBX
    mov RBX, 1
    add RAX, RBX
    mov RCX, RAX
    add RAX, 7
    and RAX, ~7
    mov RDI, RAX
    call std_memory_malloc
    mov RBX, RAX; string buffer
    xor RAX, RAX
    mov RCX, RCX
    mov RDI, RBX
    rep stosb
    mov QWORD [rbp-104], RBX
    mov QWORD [rbp-104+8], RCX
    mov QWORD [rbp-104+16], RCX
; 设置变量buf
    mov RAX, QWORD [rbp-104]
    mov QWORD [rbp-112], RAX
; 设置变量bufu8
    mov QWORD[rbp-120], 0
; 设置变量w
    mov QWORD[rbp-128], 0
; 设置变量i




    for_40: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_40_end
    for_40_body:


    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rbp-128]
    add RAX, RBX
    movzx RAX, BYTE [RAX]
    mov BYTE[rbp-129], al
; 设置变量b
    movzx RAX, BYTE[rbp-129]
    mov QWORD[rbp-137], RAX
; 设置变量bi
    mov RAX, QWORD[rbp-137]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 10
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne else_if_204
    if_204:
    mov RAX, 92
    mov RBX, QWORD[rbp-112]
    mov RDX, QWORD[rbp-120]
    add RBX, RDX
    mov BYTE [RBX], al
; expression statement
    mov RAX, 110
    mov RBX, QWORD[rbp-112]
    mov RDX, QWORD[rbp-120]
    add RBX, RDX
    mov RDX, 1
    add RBX, RDX
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-120]
    mov RBX, 2
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量w
    jmp end_if_204
    else_if_204:
    mov RAX, QWORD[rbp-137]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 13
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne else_if_205
    if_205:
    mov RAX, 92
    mov RBX, QWORD[rbp-112]
    mov RDX, QWORD[rbp-120]
    add RBX, RDX
    mov BYTE [RBX], al
; expression statement
    mov RAX, 114
    mov RBX, QWORD[rbp-112]
    mov RDX, QWORD[rbp-120]
    add RBX, RDX
    mov RDX, 1
    add RBX, RDX
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-120]
    mov RBX, 2
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量w
    jmp end_if_205
    else_if_205:
    mov RAX, QWORD[rbp-137]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 9
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne else_if_206
    if_206:
    mov RAX, 92
    mov RBX, QWORD[rbp-112]
    mov RDX, QWORD[rbp-120]
    add RBX, RDX
    mov BYTE [RBX], al
; expression statement
    mov RAX, 116
    mov RBX, QWORD[rbp-112]
    mov RDX, QWORD[rbp-120]
    add RBX, RDX
    mov RDX, 1
    add RBX, RDX
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-120]
    mov RBX, 2
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量w
    jmp end_if_206
    else_if_206:
    movzx RAX, BYTE[rbp-129]
    mov RBX, QWORD[rbp-112]
    mov RDX, QWORD[rbp-120]
    add RBX, RDX
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-120]
    mov RBX, 1
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量w
    end_if_206:
    end_if_205:
    end_if_204:
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量i
    for_40_continue:


    jmp for_40; for循环
    for_40_end: ; for循环结束
    mov RAX, 0
    mov RBX, QWORD[rbp-112]
    mov RDX, QWORD[rbp-120]
    add RBX, RDX
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD [rbp-104]
    push RAX; 保护基址
    mov RBX, QWORD[rbp-120]
    sub RBX, 0
    mov RAX, QWORD [rbp-104+16]
    mov RDX, [RSP]
    add RSP, 8
    mov QWORD [rbp-176], RDX
    mov QWORD [rbp-176+8], RBX
    mov QWORD [rbp-176+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-152]; 恢复返回槽地址
    mov RAX, QWORD [rbp-176]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-168]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-160]
    mov QWORD [R10+16], RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_renderVisible
    func_end__home_gx_Desktop_tiny_selfhost_lexer_renderVisible:
    add rsp, 184; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_newRingBuffer progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_newRingBuffer
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_newRingBuffer
_home_gx_Desktop_tiny_selfhost_lexer_newRingBuffer:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_207
    if_207:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_128
    mov QWORD [rsp+0+8], 13
    mov QWORD [rsp+0+16], 13
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_panic
    end_if_207:
    mov RDI, 48
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rbp-56], RBX
; 设置变量r
    mov RAX, QWORD[rbp-48]
    mov RCX, RAX
    imul RAX, 8
    add RAX, 7
    and RAX, ~7
    mov RDI, RAX
    call std_memory_malloc
    mov RBX, RAX; list buffer
    mov RAX, 0
    mov RAX, QWORD[rbp-48]
    mov RDX, RAX
    imul RAX, 8
    shr RAX, 3
    mov RAX, RAX
    cmp RAX, 0
    je make_1_zero_done
    make_1_zero_loop:
    mov QWORD [RBX+RAX*8 - 8], 0
    sub RAX, 1
    jnz make_1_zero_loop
    make_1_zero_done:
    mov QWORD [rbp-80], RBX
    mov QWORD [rbp-80+8], RDX
    mov QWORD [rbp-80+16], RCX
; 设置变量arr
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [rbp-80]
    mov QWORD [RBX+0], RAX
    mov RAX, QWORD [rbp-80+8]
    mov QWORD [RBX+8], RAX
    mov RAX, QWORD [rbp-80+16]
    mov QWORD [RBX+16], RAX
; 设置变量r.buf
    mov RAX, QWORD[rbp-56]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_newRingBuffer
    func_end__home_gx_Desktop_tiny_selfhost_lexer_newRingBuffer:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isFull progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isFull
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isFull
_home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isFull:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RBX, QWORD[rbp+-48]
    movzx RAX, BYTE [RBX+40]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isFull
    func_end__home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isFull:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isEmpty progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isEmpty
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isEmpty
_home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isEmpty:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX+24]
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+32]
    cmp RBX, RCX
    sete bl
    movzx RBX, bl
    mov RDX, QWORD[rbp+-48]
    movzx RCX, BYTE [RDX+40]
    cmp RCX, 0
    sete cl
    movzx RCX, cl
    mov RAX, RCX
    and RAX, RBX
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isEmpty
    func_end__home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isEmpty:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_write progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_write
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_write
_home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_write:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isFull
; condition
    test RAX, RAX
    jz end_if_208
    if_208:
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_write
    end_if_208:
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+32]
    mov RBX, QWORD[rbp+-48]
    test RAX, RAX
    jge idx_norm_ok_34d51843f770
    add RAX, QWORD [RBX+8]
    idx_norm_ok_34d51843f770:
    test RAX, RAX
    js idxw_oob_34d51843f950
    cmp QWORD [RBX+8], RAX
    jg idxw_ok_34d51843f950
    idxw_oob_34d51843f950:
    push RAX
    call _panic_index_oob
    idxw_ok_34d51843f950:
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX]
    imul RAX, 8
    add RBX, RAX
    mov RAX, QWORD[rbp-56]
    mov QWORD [RBX], RAX
; list index assignment
    mov RCX, QWORD[rbp+-48]
    mov RDX, QWORD[rbp+-48]
    mov RAX, QWORD [RDX+32]
    mov RDX, 1
    add RAX, RDX
    mov R12, RAX
    mov RDX, QWORD[rbp+-48]
    mov RAX, QWORD [RDX+8]
    mov QWORD[RCX+32], R12
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[RCX+32]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[RCX+32], rdx
    pop RAX; 恢复RAX(左子结果)
; 设置变量self.WritePos
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+32]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp+-48]
    mov RCX, QWORD [RCX+24]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_209
    if_209:
    mov RCX, QWORD[rbp+-48]
    mov BYTE[RCX+40], 1
; 设置变量self.f
    end_if_209:
    mov RAX, 1
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_write
    func_end__home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_write:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_read progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_read
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_read
_home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_read:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isEmpty
; condition
    test RAX, RAX
    jz end_if_210
    if_210:
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_read
    end_if_210:
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+24]
    mov RBX, QWORD[rbp+-48]
    test RAX, RAX
    jge idx_norm_ok_34d518456f00
    add RAX, QWORD [RBX+8]
    idx_norm_ok_34d518456f00:
    test RAX, RAX
    js idx_oob_34d518456ff0
    cmp QWORD [RBX+8], RAX
    jg idx_ok_34d518456ff0
    idx_oob_34d518456ff0:
    push RAX
    call _panic_index_oob
    idx_ok_34d518456ff0:
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX]
    imul RAX, 8
    add RBX, RAX
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-56], RAX
; 设置变量val
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+24]
    mov RBX, QWORD[rbp+-48]
    test RAX, RAX
    jge idx_norm_ok_34d5184572c0
    add RAX, QWORD [RBX+8]
    idx_norm_ok_34d5184572c0:
    test RAX, RAX
    js idxw_oob_34d5184574a0
    cmp QWORD [RBX+8], RAX
    jg idxw_ok_34d5184574a0
    idxw_oob_34d5184574a0:
    push RAX
    call _panic_index_oob
    idxw_ok_34d5184574a0:
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX]
    imul RAX, 8
    add RBX, RAX
    mov RAX, 0
    mov QWORD [RBX], RAX
; list index assignment
    mov RCX, QWORD[rbp+-48]
    mov RDX, QWORD[rbp+-48]
    mov RAX, QWORD [RDX+24]
    mov RDX, 1
    add RAX, RDX
    mov R12, RAX
    mov RDX, QWORD[rbp+-48]
    mov RAX, QWORD [RDX+8]
    mov QWORD[RCX+24], R12
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[RCX+24]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[RCX+24], rdx
    pop RAX; 恢复RAX(左子结果)
; 设置变量self.ReadPos
    mov RCX, QWORD[rbp+-48]
    mov BYTE[RCX+40], 0
; 设置变量self.f
    mov RAX, QWORD[rbp-56]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_read
    func_end__home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_read:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_freeToken progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_freeToken
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_freeToken
_home_gx_Desktop_tiny_selfhost_lexer_freeToken:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_211
    if_211:
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_freeToken
    end_if_211:
    mov RBX, QWORD [RBP-48]
    test RBX, RBX
    je _panic_nil_deref
    lea RBX, [RBX+24]
    mov QWORD[rbp-56], RBX
; 设置变量sp
    mov RAX, QWORD[rbp-56]
    mov RAX, QWORD [RAX]
    mov QWORD[rbp-64], RAX
; 设置变量p
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_212
    and_mid_24:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_isTrackedAll
; condition
    test RAX, RAX
    jz end_if_212
    if_212:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    end_if_212:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_isTrackedAll
; condition
    test RAX, RAX
    jz end_if_213
    if_213:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    end_if_213:
    func_end__home_gx_Desktop_tiny_selfhost_lexer_freeToken:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_clear progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_clear
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_clear
_home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_clear:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 136; 分配局部变量空间(136字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+8]
    mov QWORD[rbp-56], RAX
; 设置变量n
    mov RBX, QWORD[rbp+-48]
    movzx RAX, BYTE [RBX+40]
; condition
    test RAX, RAX
    jz else_if_214
    if_214:
    mov QWORD[rbp-64], 0
; 设置变量i




    for_41: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_41_end
    for_41_body:


    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp+-48]
    test RAX, RAX
    jge idx_norm_ok_34d51845a960
    add RAX, QWORD [RBX+8]
    idx_norm_ok_34d51845a960:
    test RAX, RAX
    js idx_oob_34d51845aa50
    cmp QWORD [RBX+8], RAX
    jg idx_ok_34d51845aa50
    idx_oob_34d51845aa50:
    push RAX
    call _panic_index_oob
    idx_ok_34d51845aa50:
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX]
    imul RAX, 8
    add RBX, RAX
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-72], RAX
; 设置变量t
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_215
    if_215:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_freeToken
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp+-48]
    test RAX, RAX
    jge idx_norm_ok_34d51845b1d0
    add RAX, QWORD [RBX+8]
    idx_norm_ok_34d51845b1d0:
    test RAX, RAX
    js idxw_oob_34d51845b3b0
    cmp QWORD [RBX+8], RAX
    jg idxw_ok_34d51845b3b0
    idxw_oob_34d51845b3b0:
    push RAX
    call _panic_index_oob
    idxw_ok_34d51845b3b0:
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX]
    imul RAX, 8
    add RBX, RAX
    mov RAX, 0
    mov QWORD [RBX], RAX
; list index assignment
    end_if_215:
    mov RAX, QWORD[rbp-64]
    mov RCX, 1
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RCX
; 设置变量i
    for_41_continue:


    jmp for_41; for循环
    for_41_end: ; for循环结束
    jmp end_if_214
    else_if_214:
    sub rsp, 16; register args buffer
    mov RCX, QWORD[rbp-48]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_isEmpty
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_216
    if_216:
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+24]
    mov QWORD[rbp-80], RAX
; 设置变量i




    for_42: ; for循环开始


    mov RAX, QWORD[rbp-80]
    mov RCX, QWORD[rbp+-48]
    test RAX, RAX
    jge idx_norm_ok_34d51845be00
    add RAX, QWORD [RCX+8]
    idx_norm_ok_34d51845be00:
    test RAX, RAX
    js idx_oob_34d51845c000
    cmp QWORD [RCX+8], RAX
    jg idx_ok_34d51845c000
    idx_oob_34d51845c000:
    push RAX
    call _panic_index_oob
    idx_ok_34d51845c000:
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX]
    imul RAX, 8
    add RCX, RAX
    mov RAX, QWORD [RCX]
    mov QWORD[rbp-88], RAX
; 设置变量t
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_217
    if_217:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-88]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_freeToken
    mov RAX, QWORD[rbp-80]
    mov RCX, QWORD[rbp+-48]
    test RAX, RAX
    jge idx_norm_ok_34d51845c780
    add RAX, QWORD [RCX+8]
    idx_norm_ok_34d51845c780:
    test RAX, RAX
    js idxw_oob_34d51845c960
    cmp QWORD [RCX+8], RAX
    jg idxw_ok_34d51845c960
    idxw_oob_34d51845c960:
    push RAX
    call _panic_index_oob
    idxw_ok_34d51845c960:
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX]
    imul RAX, 8
    add RCX, RAX
    mov RAX, 0
    mov QWORD [RCX], RAX
; list index assignment
    end_if_217:
    mov RAX, QWORD[rbp-80]
    mov RDX, 1
    add RAX, RDX
    mov RDX, QWORD[rbp-56]
    mov QWORD[rbp-80], RAX
    push RAX; 保护RAX(左子结果)
    push RDX; 保存除数
    mov rax, QWORD[rbp-80]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-80], rdx
    pop RAX; 恢复RAX(左子结果)
; 设置变量i
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+32]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_218
    if_218:
    jmp for_42_end
    end_if_218:
    for_42_continue:


    jmp for_42; for循环
    for_42_end: ; for循环结束
    end_if_216:
    end_if_214:
    mov RDX, QWORD[rbp+-48]
    mov QWORD[RDX+24], 0
; 设置变量self.ReadPos
    mov RDX, QWORD[rbp+-48]
    mov QWORD[RDX+32], 0
; 设置变量self.WritePos
    mov RDX, QWORD[rbp+-48]
    mov BYTE[RDX+40], 0
; 设置变量self.f
    func_end__home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_clear:
    add rsp, 136; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_newLexer progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_newLexer
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_newLexer
_home_gx_Desktop_tiny_selfhost_lexer_newLexer:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov RDI, 88
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [RBX+64], RAX
    mov QWORD [RBX+72], RAX
    mov QWORD [RBX+80], RAX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rbp-72], RBX
; 设置变量l
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [rbp-64]
    mov QWORD [RBX+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [RBX+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [RBX+16], RAX
; 设置变量l.Text
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov QWORD[RBX+32], 1
; 设置变量l.Line
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov QWORD[RBX+40], 1
; 设置变量l.Col
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov QWORD[RBX+72], 1
; 设置变量l.pfLine
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov QWORD[RBX+64], 1
; 设置变量l.pfCol
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov QWORD[RBX+24], 0
; 设置变量l.Pos
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov QWORD[RBX+56], 0
; 设置变量l.pfPos
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_PREFETCH_CAP]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_newRingBuffer
    mov QWORD[RBX+80], RAX
; 设置变量l.pfCache
    mov RAX, QWORD[rbp-72]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_newLexer
    func_end__home_gx_Desktop_tiny_selfhost_lexer_newLexer:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_tokenCoord progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_tokenCoord
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_tokenCoord
_home_gx_Desktop_tiny_selfhost_lexer_tokenCoord:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RDI, 104
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [RBX+64], RAX
    mov QWORD [RBX+72], RAX
    mov QWORD [RBX+80], RAX
    mov QWORD [RBX+88], RAX
    mov QWORD [RBX+96], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-48]
    mov QWORD [RBX+56], RCX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-56]
    mov QWORD [RBX+64], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov RAX, RBX
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_tokenCoord
    func_end__home_gx_Desktop_tiny_selfhost_lexer_tokenCoord:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_coordFromTokenEnd progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_coordFromTokenEnd
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_coordFromTokenEnd
_home_gx_Desktop_tiny_selfhost_lexer_coordFromTokenEnd:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_219
    if_219:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_129
    mov QWORD [rsp+0+8], 28
    mov QWORD [rsp+0+16], 28
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_panic
    end_if_219:
    mov RDI, 24
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov RBX, QWORD [RSP]
    mov RDX, QWORD [RBP-48]
    test RDX, RDX
    je _panic_nil_deref
    mov RCX, QWORD [RDX+64]
    mov QWORD [RBX+0], RCX
    mov RBX, QWORD [RSP]
    mov RDX, QWORD [RBP-48]
    test RDX, RDX
    je _panic_nil_deref
    mov RCX, QWORD [RDX+88]
    mov QWORD [RBX+8], RCX
    mov RBX, QWORD [RSP]
    mov RDX, QWORD [RBP-48]
    test RDX, RDX
    je _panic_nil_deref
    mov RCX, QWORD [RDX+96]
    mov QWORD [RBX+16], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov RAX, RBX
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_coordFromTokenEnd
    func_end__home_gx_Desktop_tiny_selfhost_lexer_coordFromTokenEnd:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Lexer_savePfPos progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Lexer_savePfPos
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Lexer_savePfPos
_home_gx_Desktop_tiny_selfhost_lexer_Lexer_savePfPos:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RDI, 24
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov RBX, QWORD [RSP]
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+56]
    mov QWORD [RBX+0], RCX
    mov RBX, QWORD [RSP]
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+72]
    mov QWORD [RBX+8], RCX
    mov RBX, QWORD [RSP]
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+64]
    mov QWORD [RBX+16], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov RAX, RBX
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_savePfPos
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_savePfPos:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPos progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPos
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPos
_home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPos:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_220
    if_220:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_130
    mov QWORD [rsp+0+8], 23
    mov QWORD [rsp+0+16], 23
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_panic
    end_if_220:
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD [RBP-56]
    test RCX, RCX
    je _panic_nil_deref
    mov RAX, QWORD [RCX]
    mov QWORD[RBX+24], RAX
; 设置变量self.Pos
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD [RBP-56]
    test RCX, RCX
    je _panic_nil_deref
    mov RAX, QWORD [RCX+8]
    mov QWORD[RBX+32], RAX
; 设置变量self.Line
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD [RBP-56]
    test RCX, RCX
    je _panic_nil_deref
    mov RAX, QWORD [RCX+16]
    mov QWORD[RBX+40], RAX
; 设置变量self.Col
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD [RBP-56]
    test RCX, RCX
    je _panic_nil_deref
    mov RAX, QWORD [RCX]
    mov QWORD[RBX+56], RAX
; 设置变量self.pfPos
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD [RBP-56]
    test RCX, RCX
    je _panic_nil_deref
    mov RAX, QWORD [RCX+8]
    mov QWORD[RBX+72], RAX
; 设置变量self.pfLine
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD [RBP-56]
    test RCX, RCX
    je _panic_nil_deref
    mov RAX, QWORD [RCX+16]
    mov QWORD[RBX+64], RAX
; 设置变量self.pfCol
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_clear
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPos:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPosAsPfPos progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPosAsPfPos
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPosAsPfPos
_home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPosAsPfPos:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_clear
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+56]
    mov QWORD[RBX+24], RAX
; 设置变量self.Pos
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+72]
    mov QWORD[RBX+32], RAX
; 设置变量self.Line
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+64]
    mov QWORD[RBX+40], RAX
; 设置变量self.Col
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPosAsPfPos:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Lexer_consume progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Lexer_consume
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Lexer_consume
_home_gx_Desktop_tiny_selfhost_lexer_Lexer_consume:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 152; 分配局部变量空间(152字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RBX, QWORD[rbp+-48]
    mov RCX, RBX; copySlots base
    mov RAX, QWORD [RCX]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [RCX+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [RCX+16]
    mov QWORD [rbp-80+16], RAX
; 设置变量text
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+56]
    mov QWORD[rbp-88], RAX
; 设置变量k
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+64]
    mov QWORD[rbp-96], RAX
; 设置变量end




    for_43: ; for循环开始
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_43_end
    for_43_body:


    mov RAX, QWORD[rbp-88]
    test RAX, RAX
    jge idx_norm_ok_34d5184772c0
    add RAX, QWORD [rbp-80+8]
    idx_norm_ok_34d5184772c0:
    test RAX, RAX
    js idx_oob_34d5184773b0
    cmp QWORD [rbp-80+8], RAX
    jg idx_ok_34d5184773b0
    idx_oob_34d5184773b0:
    push RAX
    call _panic_index_oob
    idx_ok_34d5184773b0:
    mov RBX, QWORD [rbp-80]
    imul RAX, 1
    add RBX, RAX
    movzx RAX, BYTE [RBX]
    mov BYTE[rbp-97], al
; 设置变量b
    movzx RAX, BYTE[rbp-97]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 10
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne else_if_221
    if_221:
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+72]
    mov RCX, 1
    mov QWORD[RBX+72], RAX
    add QWORD[RBX+72], RCX
; 设置变量self.pfLine
    mov RBX, QWORD[rbp+-48]
    mov QWORD[RBX+64], 1
; 设置变量self.pfCol
    jmp end_if_221
    else_if_221:
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+64]
    mov RCX, 1
    mov QWORD[RBX+64], RAX
    add QWORD[RBX+64], RCX
; 设置变量self.pfCol
    end_if_221:
    mov RAX, QWORD[rbp-88]
    mov RCX, 1
    mov QWORD[rbp-88], RAX
    add QWORD[rbp-88], RCX
; 设置变量k
    for_43_continue:


    jmp for_43; for循环
    for_43_end: ; for循环结束
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD [RBP-56]
    test RCX, RCX
    je _panic_nil_deref
    mov RAX, QWORD [RCX+64]
    mov QWORD[RBX+56], RAX
; 设置变量self.pfPos
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_consume:
    add rsp, 152; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken
_home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+72]
    mov QWORD[RBX+72], RAX
; 设置变量t.Line
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+64]
    mov QWORD[RBX+80], RAX
; 设置变量t.Col
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_consume
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+72]
    mov QWORD[RBX+88], RAX
; 设置变量t.EndLine
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+64]
    mov QWORD[RBX+96], RAX
; 设置变量t.EndCol
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_write
    mov RAX, QWORD[rbp-56]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_numberBase progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_numberBase
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_numberBase
_home_gx_Desktop_tiny_selfhost_lexer_numberBase:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1到栈
    mov RAX, QWORD[rbp-72]
    mov RBX, 1
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RDI, QWORD [rbp-64]
    mov RSI, QWORD [rbp-64+8]
    mov RDX, QWORD [rbp-64+16]
    call __string_len
    mov RCX, RAX; len/cap 结果
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl end_if_222
    if_222:
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_numberBase
    end_if_222:
    mov RAX, QWORD[rbp-72]
    test RAX, RAX
    jge idx_norm_ok_34d51848de00
    add RAX, QWORD [rbp-64+8]
    idx_norm_ok_34d51848de00:
    test RAX, RAX
    js idx_oob_34d51848e0f0
    cmp QWORD [rbp-64+8], RAX
    jg idx_ok_34d51848e0f0
    idx_oob_34d51848e0f0:
    push RAX
    call _panic_index_oob
    idx_ok_34d51848e0f0:
    mov RBX, QWORD [rbp-64]
    imul RAX, 1
    add RBX, RAX
    movzx RAX, BYTE [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 48
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_223
    if_223:
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_numberBase
    end_if_223:
    mov RAX, QWORD[rbp-72]
    mov RBX, 1
    add RAX, RBX
    test RAX, RAX
    jge idx_norm_ok_34d51848e690
    add RAX, QWORD [rbp-64+8]
    idx_norm_ok_34d51848e690:
    test RAX, RAX
    js idx_oob_34d51848ea50
    cmp QWORD [rbp-64+8], RAX
    jg idx_ok_34d51848ea50
    idx_oob_34d51848ea50:
    push RAX
    call _panic_index_oob
    idx_ok_34d51848ea50:
    mov RBX, QWORD [rbp-64]
    imul RAX, 1
    add RBX, RAX
    movzx RAX, BYTE [RBX]
    mov BYTE[rbp-73], al
; 设置变量c
    movzx RAX, BYTE[rbp-73]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 120
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_224
    movzx RAX, BYTE[rbp-73]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 88
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_224
    jne end_if_224
    if_224:
    mov RAX, 16
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_numberBase
    end_if_224:
    movzx RAX, BYTE[rbp-73]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 98
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_225
    movzx RAX, BYTE[rbp-73]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 66
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_225
    jne end_if_225
    if_225:
    mov RAX, 2
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_numberBase
    end_if_225:
    movzx RAX, BYTE[rbp-73]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 111
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_226
    movzx RAX, BYTE[rbp-73]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 79
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_226
    jne end_if_226
    if_226:
    mov RAX, 8
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_numberBase
    end_if_226:
    mov RAX, 0
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_numberBase
    func_end__home_gx_Desktop_tiny_selfhost_lexer_numberBase:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleNumber progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleNumber
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleNumber
_home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleNumber:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 328; 分配局部变量空间(328字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-128], 0; gc: zero exit slot rawText
    mov QWORD [rbp-240], 0; gc: zero exit slot s
    mov RBX, QWORD[rbp+-48]
    mov RCX, RBX; copySlots base
    mov RAX, QWORD [RCX]
    mov QWORD [rbp-72+0], RAX
    mov RAX, QWORD [RCX+8]
    mov QWORD [rbp-72+8], RAX
    mov RAX, QWORD [RCX+16]
    mov QWORD [rbp-72+16], RAX
; 设置变量text
    mov RDI, QWORD [rbp-72]
    mov RSI, QWORD [rbp-72+8]
    mov RDX, QWORD [rbp-72+16]
    call __string_len
    mov QWORD[rbp-80], RAX
; 设置变量plen
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+56]
    mov QWORD[rbp-88], RAX
; 设置变量i
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD[rbp-88]
    mov QWORD [rsp+24], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_numberBase
    mov QWORD[rbp-96], RAX
; 设置变量base
    mov QWORD [rbp-128], 0; gc: zero slot rawText
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_227
    if_227:
    mov RAX, QWORD[rbp-88]
    mov RBX, 2
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量e




    for_44: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_44_end
    for_and_mid_6:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-104]
    test RAX, RAX
    jge idx_norm_ok_34d5184da000
    add RAX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184da000:
    test RAX, RAX
    js idx_oob_34d5184da0f0
    cmp QWORD [rbp-72+8], RAX
    jg idx_ok_34d5184da0f0
    idx_oob_34d5184da0f0:
    push RAX
    call _panic_index_oob
    idx_ok_34d5184da0f0:
    mov RBX, QWORD [rbp-72]
    imul RAX, 1
    add RBX, RAX
    movzx RAX, BYTE [RBX]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isIntDigit
; ||-chain leaf
    test RAX, RAX
    jnz for_44_body
    mov RAX, QWORD[rbp-104]
    test RAX, RAX
    jge idx_norm_ok_34d5184da780
    add RAX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184da780:
    test RAX, RAX
    js idx_oob_34d5184da870
    cmp QWORD [rbp-72+8], RAX
    jg idx_ok_34d5184da870
    idx_oob_34d5184da870:
    push RAX
    call _panic_index_oob
    idx_ok_34d5184da870:
    mov RBX, QWORD [rbp-72]
    imul RAX, 1
    add RBX, RAX
    movzx RAX, BYTE [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 95
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je for_44_body
    jne for_44_end
    for_44_body:


    mov RAX, QWORD[rbp-104]
    mov RBX, 1
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量e
    for_44_continue:


    jmp for_44; for循环
    for_44_end: ; for循环结束
    sub rsp, 8; align stack for stack args
    push 0
    push 0
    push 0
; 参数2
    sub rsp, 48; register args buffer
    sub RSP, 40
    mov RAX, QWORD [rbp-72]
    mov QWORD [RSP+32], RAX; staging right
    mov RAX, QWORD[rbp-88]
    mov RBX, 2
    add RAX, RBX
    mov QWORD [RSP+24], RAX; staging lo idx
    mov RAX, [RSP+24]
    imul RAX, 1
    add RAX, [RSP+32]
    mov QWORD [RSP], RAX; R.ptr
    mov RAX, QWORD[rbp-104]
    sub RAX, [RSP+24]; R.len = hi|len - lo
    mov QWORD [RSP+8], RAX; R.len
    mov RAX, QWORD [rbp-72+16]
    sub RAX, [RSP+24]
    mov QWORD [RSP+16], RAX; R.cap
    mov RBX, [RSP]
    mov RCX, [RSP+8]
    mov RDX, [RSP+16]
    add RSP, 40
    mov QWORD [rsp+0], RBX
    mov QWORD [rsp+0+8], RCX
    mov QWORD [rsp+0+16], RDX
; 参数0
    mov QWORD [rsp+24], str_131
    mov QWORD [rsp+24+8], 1
    mov QWORD [rsp+24+16], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    lea R10, [rbp-320]; 大值返回槽地址
    call std_strings_replaceAll
    add rsp, 32; clean stack args
    mov RAX, QWORD [RBP-320]
    mov QWORD [rbp-128+0], RAX
    mov RAX, QWORD [RBP-320+8]
    mov QWORD [rbp-128+8], RAX
    mov RAX, QWORD [RBP-320+16]
    mov QWORD [rbp-128+16], RAX
; 设置变量rawText
    mov RDI, QWORD [rbp-128]
    mov RSI, QWORD [rbp-128+8]
    mov RDX, QWORD [rbp-128+16]
    call __string_len
    mov RAX, RAX; len/cap 结果
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_228
    if_228:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-128]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-128+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-128+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+24], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_parseUint
; multi-return call
    mov QWORD [rbp-144], RAX; multi-return: vu
    mov QWORD [rbp-136], RDX; multi-return: vok
    mov RAX, QWORD[rbp-136]
; condition
    test RAX, RAX
    jz end_if_229
    if_229:
    mov RAX, QWORD[rbp-144]
    mov QWORD[rbp-152], RAX
; 设置变量xnum
    sub RSP, 40
    mov RAX, QWORD [rbp-72]
    mov QWORD [RSP+32], RAX; staging right
    mov RAX, QWORD[rbp-88]
    mov QWORD [RSP+24], RAX; staging lo idx
    mov RAX, [RSP+24]
    imul RAX, 1
    add RAX, [RSP+32]
    mov QWORD [RSP], RAX; R.ptr
    mov RAX, QWORD[rbp-104]
    sub RAX, [RSP+24]; R.len = hi|len - lo
    mov QWORD [RSP+8], RAX; R.len
    mov RAX, QWORD [rbp-72+16]
    sub RAX, [RSP+24]
    mov QWORD [RSP+16], RAX; R.cap
    mov RBX, [RSP]
    mov RCX, [RSP+8]
    mov RDX, [RSP+16]
    add RSP, 40
    mov QWORD [rbp-176], RBX
    mov QWORD [rbp-176+8], RCX
    mov QWORD [rbp-176+16], RDX
; 设置变量xstr
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, 104
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [RBX+64], RAX
    mov QWORD [RBX+72], RAX
    mov QWORD [RBX+80], RAX
    mov QWORD [RBX+88], RAX
    mov QWORD [RBX+96], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NUMBER]
    mov QWORD [RBX+0], RCX
    mov RBX, QWORD [RSP]
    mov RAX, QWORD [rbp-176]
    mov QWORD [RBX+24+0], RAX
    mov RAX, QWORD [rbp-176+8]
    mov QWORD [RBX+24+8], RAX
    mov RAX, QWORD [rbp-176+16]
    mov QWORD [RBX+24+16], RAX
    mov RBX, QWORD [RSP]
    mov RAX, QWORD[rbp-152]
    cvtsi2sd XMM0, RAX; int -> f64
    movq RAX, XMM0
    mov RCX, RAX
    mov QWORD [RBX+48], RCX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-88]
    mov QWORD [RBX+56], RCX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-104]
    mov QWORD [RBX+64], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleNumber
    end_if_229:
    end_if_228:
    sub RSP, 40
    mov RAX, QWORD [rbp-72]
    mov QWORD [RSP+32], RAX; staging right
    mov RAX, QWORD[rbp-88]
    mov QWORD [RSP+24], RAX; staging lo idx
    mov RAX, [RSP+24]
    imul RAX, 1
    add RAX, [RSP+32]
    mov QWORD [RSP], RAX; R.ptr
    mov RAX, QWORD[rbp-88]
    mov RBX, 2
    add RAX, RBX
    sub RAX, [RSP+24]; R.len = hi|len - lo
    mov QWORD [RSP+8], RAX; R.len
    mov RAX, QWORD [rbp-72+16]
    sub RAX, [RSP+24]
    mov QWORD [RSP+16], RAX; R.cap
    mov RBX, [RSP]
    mov RCX, [RSP+8]
    mov RDX, [RSP+16]
    add RSP, 40
    mov QWORD [rbp-200], RBX
    mov QWORD [rbp-200+8], RCX
    mov QWORD [rbp-200+16], RDX
; 设置变量nm
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, 104
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [RBX+64], RAX
    mov QWORD [RBX+72], RAX
    mov QWORD [RBX+80], RAX
    mov QWORD [RBX+88], RAX
    mov QWORD [RBX+96], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NAME]
    mov QWORD [RBX+0], RCX
    mov RBX, QWORD [RSP]
    mov RAX, QWORD [rbp-200]
    mov QWORD [RBX+24+0], RAX
    mov RAX, QWORD [rbp-200+8]
    mov QWORD [RBX+24+8], RAX
    mov RAX, QWORD [rbp-200+16]
    mov QWORD [RBX+24+16], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-88]
    mov QWORD [RBX+56], RCX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-88]
    mov RDX, 2
    add RCX, RDX
    mov QWORD [RBX+64], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleNumber
    ; gc: block free rawText
    lea RDI, [rbp-128]
    call std_memory_freeSlot
    end_if_227:
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-208], RAX
; 设置变量e




    for_45: ; for循环开始
    mov RAX, QWORD[rbp-208]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_45_end
    for_and_mid_7:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-208]
    test RAX, RAX
    jge idx_norm_ok_34d5184df4a0
    add RAX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184df4a0:
    test RAX, RAX
    js idx_oob_34d5184df590
    cmp QWORD [rbp-72+8], RAX
    jg idx_ok_34d5184df590
    idx_oob_34d5184df590:
    push RAX
    call _panic_index_oob
    idx_ok_34d5184df590:
    mov RCX, QWORD [rbp-72]
    imul RAX, 1
    add RCX, RAX
    movzx RAX, BYTE [RCX]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigit
; ||-chain leaf
    test RAX, RAX
    jnz for_45_body
    mov RAX, QWORD[rbp-208]
    test RAX, RAX
    jge idx_norm_ok_34d5184dfb30
    add RAX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184dfb30:
    test RAX, RAX
    js idx_oob_34d5184dfc20
    cmp QWORD [rbp-72+8], RAX
    jg idx_ok_34d5184dfc20
    idx_oob_34d5184dfc20:
    push RAX
    call _panic_index_oob
    idx_ok_34d5184dfc20:
    mov RBX, QWORD [rbp-72]
    imul RAX, 1
    add RBX, RAX
    movzx RAX, BYTE [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 95
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je for_45_body
    jne for_45_end
    for_45_body:


    mov RCX, QWORD[rbp-208]
    mov RAX, 1
    mov QWORD[rbp-208], RCX
    add QWORD[rbp-208], RAX
; 设置变量e
    for_45_continue:


    jmp for_45; for循环
    for_45_end: ; for循环结束
    mov RAX, QWORD[rbp-208]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_230
    and_mid_27:
    mov RAX, QWORD[rbp-208]
    test RAX, RAX
    jge idx_norm_ok_34d5184e4a50
    add RAX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184e4a50:
    test RAX, RAX
    js idx_oob_34d5184e4b40
    cmp QWORD [rbp-72+8], RAX
    jg idx_ok_34d5184e4b40
    idx_oob_34d5184e4b40:
    push RAX
    call _panic_index_oob
    idx_ok_34d5184e4b40:
    mov RBX, QWORD [rbp-72]
    imul RAX, 1
    add RBX, RAX
    movzx RAX, BYTE [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 46
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_230
    and_mid_26:
    mov RAX, QWORD[rbp-208]
    mov RBX, 1
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_230
    and_mid_25:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-208]
    mov RCX, 1
    add RBX, RCX
    test RBX, RBX
    jge idx_norm_ok_34d5184e5860
    add RBX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184e5860:
    test RBX, RBX
    js idx_oob_34d5184e5a40
    cmp QWORD [rbp-72+8], RBX
    jg idx_ok_34d5184e5a40
    idx_oob_34d5184e5a40:
    push RBX
    call _panic_index_oob
    idx_ok_34d5184e5a40:
    mov RCX, QWORD [rbp-72]
    imul RBX, 1
    add RCX, RBX
    movzx RAX, BYTE [RCX]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigit
; condition
    test RAX, RAX
    jz end_if_230
    if_230:
    mov RCX, QWORD[rbp-208]
    mov RBX, 2
    mov QWORD[rbp-208], RCX
    add QWORD[rbp-208], RBX
; 设置变量e




    for_46: ; for循环开始
    mov RAX, QWORD[rbp-208]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_46_end
    for_and_mid_8:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-208]
    test RBX, RBX
    jge idx_norm_ok_34d5184e6960
    add RBX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184e6960:
    test RBX, RBX
    js idx_oob_34d5184e6a50
    cmp QWORD [rbp-72+8], RBX
    jg idx_ok_34d5184e6a50
    idx_oob_34d5184e6a50:
    push RBX
    call _panic_index_oob
    idx_ok_34d5184e6a50:
    mov RCX, QWORD [rbp-72]
    imul RBX, 1
    add RCX, RBX
    movzx RAX, BYTE [RCX]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigit
; ||-chain leaf
    test RAX, RAX
    jnz for_46_body
    mov RBX, QWORD[rbp-208]
    test RBX, RBX
    jge idx_norm_ok_34d5184e6ff0
    add RBX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184e6ff0:
    test RBX, RBX
    js idx_oob_34d5184e70e0
    cmp QWORD [rbp-72+8], RBX
    jg idx_ok_34d5184e70e0
    idx_oob_34d5184e70e0:
    push RBX
    call _panic_index_oob
    idx_ok_34d5184e70e0:
    mov RCX, QWORD [rbp-72]
    imul RBX, 1
    add RCX, RBX
    movzx RAX, BYTE [RCX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 95
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je for_46_body
    jne for_46_end
    for_46_body:


    mov RBX, QWORD[rbp-208]
    mov RCX, 1
    mov QWORD[rbp-208], RBX
    add QWORD[rbp-208], RCX
; 设置变量e
    for_46_continue:


    jmp for_46; for循环
    for_46_end: ; for循环结束
    end_if_230:
    mov RAX, QWORD[rbp-208]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_231
    and_mid_28:
    mov RBX, QWORD[rbp-208]
    test RBX, RBX
    jge idx_norm_ok_34d5184e8000
    add RBX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184e8000:
    test RBX, RBX
    js idx_oob_34d5184e80f0
    cmp QWORD [rbp-72+8], RBX
    jg idx_ok_34d5184e80f0
    idx_oob_34d5184e80f0:
    push RBX
    call _panic_index_oob
    idx_ok_34d5184e80f0:
    mov RCX, QWORD [rbp-72]
    imul RBX, 1
    add RCX, RBX
    movzx RAX, BYTE [RCX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 101
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_231
    mov RBX, QWORD[rbp-208]
    test RBX, RBX
    jge idx_norm_ok_34d5184e8780
    add RBX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184e8780:
    test RBX, RBX
    js idx_oob_34d5184e8870
    cmp QWORD [rbp-72+8], RBX
    jg idx_ok_34d5184e8870
    idx_oob_34d5184e8870:
    push RBX
    call _panic_index_oob
    idx_ok_34d5184e8870:
    mov RCX, QWORD [rbp-72]
    imul RBX, 1
    add RCX, RBX
    movzx RAX, BYTE [RCX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 69
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_231
    jne end_if_231
    if_231:
    mov RBX, QWORD[rbp-208]
    mov RCX, 1
    mov QWORD[rbp-216], RBX
    add QWORD[rbp-216], RCX
; 设置变量m
    mov RAX, QWORD[rbp-216]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_232
    and_mid_29:
    mov RBX, QWORD[rbp-216]
    test RBX, RBX
    jge idx_norm_ok_34d5184e9680
    add RBX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184e9680:
    test RBX, RBX
    js idx_oob_34d5184e9770
    cmp QWORD [rbp-72+8], RBX
    jg idx_ok_34d5184e9770
    idx_oob_34d5184e9770:
    push RBX
    call _panic_index_oob
    idx_ok_34d5184e9770:
    mov RCX, QWORD [rbp-72]
    imul RBX, 1
    add RCX, RBX
    movzx RAX, BYTE [RCX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 43
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_232
    mov RBX, QWORD[rbp-216]
    test RBX, RBX
    jge idx_norm_ok_34d5184e9e00
    add RBX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184e9e00:
    test RBX, RBX
    js idx_oob_34d5184ee000
    cmp QWORD [rbp-72+8], RBX
    jg idx_ok_34d5184ee000
    idx_oob_34d5184ee000:
    push RBX
    call _panic_index_oob
    idx_ok_34d5184ee000:
    mov RCX, QWORD [rbp-72]
    imul RBX, 1
    add RCX, RBX
    movzx RAX, BYTE [RCX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 45
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_232
    jne end_if_232
    if_232:
    mov RBX, QWORD[rbp-216]
    mov RCX, 1
    mov QWORD[rbp-216], RBX
    add QWORD[rbp-216], RCX
; 设置变量m
    end_if_232:
    mov RAX, QWORD[rbp-216]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_233
    and_mid_30:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-216]
    test RBX, RBX
    jge idx_norm_ok_34d5184eed20
    add RBX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184eed20:
    test RBX, RBX
    js idx_oob_34d5184eee10
    cmp QWORD [rbp-72+8], RBX
    jg idx_ok_34d5184eee10
    idx_oob_34d5184eee10:
    push RBX
    call _panic_index_oob
    idx_ok_34d5184eee10:
    mov RCX, QWORD [rbp-72]
    imul RBX, 1
    add RCX, RBX
    movzx RAX, BYTE [RCX]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigit
; condition
    test RAX, RAX
    jz end_if_233
    if_233:
    mov RCX, QWORD[rbp-216]
    mov RBX, 1
    mov QWORD[rbp-216], RCX
    add QWORD[rbp-216], RBX
; 设置变量m




    for_47: ; for循环开始
    mov RAX, QWORD[rbp-216]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_47_end
    for_and_mid_9:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-216]
    test RBX, RBX
    jge idx_norm_ok_34d5184efc20
    add RBX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184efc20:
    test RBX, RBX
    js idx_oob_34d5184efd10
    cmp QWORD [rbp-72+8], RBX
    jg idx_ok_34d5184efd10
    idx_oob_34d5184efd10:
    push RBX
    call _panic_index_oob
    idx_ok_34d5184efd10:
    mov RCX, QWORD [rbp-72]
    imul RBX, 1
    add RCX, RBX
    movzx RAX, BYTE [RCX]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigit
; ||-chain leaf
    test RAX, RAX
    jnz for_47_body
    mov RBX, QWORD[rbp-216]
    test RBX, RBX
    jge idx_norm_ok_34d5184f03c0
    add RBX, QWORD [rbp-72+8]
    idx_norm_ok_34d5184f03c0:
    test RBX, RBX
    js idx_oob_34d5184f04b0
    cmp QWORD [rbp-72+8], RBX
    jg idx_ok_34d5184f04b0
    idx_oob_34d5184f04b0:
    push RBX
    call _panic_index_oob
    idx_ok_34d5184f04b0:
    mov RCX, QWORD [rbp-72]
    imul RBX, 1
    add RCX, RBX
    movzx RAX, BYTE [RCX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 95
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je for_47_body
    jne for_47_end
    for_47_body:


    mov RBX, QWORD[rbp-216]
    mov RCX, 1
    mov QWORD[rbp-216], RBX
    add QWORD[rbp-216], RCX
; 设置变量m
    for_47_continue:


    jmp for_47; for循环
    for_47_end: ; for循环结束
    mov RBX, QWORD[rbp-216]
    mov QWORD[rbp-208], RBX
; 设置变量e
    end_if_233:
    end_if_231:
    sub rsp, 8; align stack for stack args
    push 0
    push 0
    push 0
; 参数2
    sub rsp, 48; register args buffer
    sub RSP, 40
    mov RBX, QWORD [rbp-72]
    mov QWORD [RSP+32], RBX; staging right
    mov RAX, QWORD[rbp-88]
    mov QWORD [RSP+24], RAX; staging lo idx
    mov RAX, [RSP+24]
    imul RAX, 1
    add RAX, [RSP+32]
    mov QWORD [RSP], RAX; R.ptr
    mov RAX, QWORD[rbp-208]
    sub RAX, [RSP+24]; R.len = hi|len - lo
    mov QWORD [RSP+8], RAX; R.len
    mov RAX, QWORD [rbp-72+16]
    sub RAX, [RSP+24]
    mov QWORD [RSP+16], RAX; R.cap
    mov RCX, [RSP]
    mov RDX, [RSP+8]
    mov RSI, [RSP+16]
    add RSP, 40
    mov QWORD [rsp+0], RCX
    mov QWORD [rsp+0+8], RDX
    mov QWORD [rsp+0+16], RSI
; 参数0
    mov QWORD [rsp+24], str_131
    mov QWORD [rsp+24+8], 1
    mov QWORD [rsp+24+16], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    lea R10, [rbp-320]; 大值返回槽地址
    call std_strings_replaceAll
    add rsp, 32; clean stack args
    mov RAX, QWORD [RBP-320]
    mov QWORD [rbp-240+0], RAX
    mov RAX, QWORD [RBP-320+8]
    mov QWORD [rbp-240+8], RAX
    mov RAX, QWORD [RBP-320+16]
    mov QWORD [rbp-240+16], RAX
; 设置变量s
    mov DWORD[rbp-248], 0; 64bit low
    mov DWORD[rbp-244], 0; 64bit high
; 设置变量num
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-240]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-240+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-240+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_parseFloat
; multi-return call
    mov QWORD [rbp-264], RAX; multi-return: vf
    mov QWORD [rbp-256], RDX; multi-return: vok
    mov RAX, QWORD[rbp-256]
; condition
    test RAX, RAX
    jz end_if_234
    if_234:
    mov RBX, QWORD[rbp-264]
    mov QWORD[rbp-248], RBX
; 设置变量num
    end_if_234:
    sub RSP, 40
    mov RBX, QWORD [rbp-72]
    mov QWORD [RSP+32], RBX; staging right
    mov RAX, QWORD[rbp-88]
    mov QWORD [RSP+24], RAX; staging lo idx
    mov RAX, [RSP+24]
    imul RAX, 1
    add RAX, [RSP+32]
    mov QWORD [RSP], RAX; R.ptr
    mov RAX, QWORD[rbp-208]
    sub RAX, [RSP+24]; R.len = hi|len - lo
    mov QWORD [RSP+8], RAX; R.len
    mov RAX, QWORD [rbp-72+16]
    sub RAX, [RSP+24]
    mov QWORD [RSP+16], RAX; R.cap
    mov RCX, [RSP]
    mov RDX, [RSP+8]
    mov RSI, [RSP+16]
    add RSP, 40
    mov QWORD [rbp-288], RCX
    mov QWORD [rbp-288+8], RDX
    mov QWORD [rbp-288+16], RSI
; 设置变量numStr
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, 104
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [RBX+64], RAX
    mov QWORD [RBX+72], RAX
    mov QWORD [RBX+80], RAX
    mov QWORD [RBX+88], RAX
    mov QWORD [RBX+96], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NUMBER]
    mov QWORD [RBX+0], RCX
    mov RBX, QWORD [RSP]
    mov RAX, QWORD [rbp-288]
    mov QWORD [RBX+24+0], RAX
    mov RAX, QWORD [rbp-288+8]
    mov QWORD [RBX+24+8], RAX
    mov RAX, QWORD [rbp-288+16]
    mov QWORD [RBX+24+16], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-248]
    mov QWORD [RBX+48], RCX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-88]
    mov QWORD [RBX+56], RCX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-208]
    mov QWORD [RBX+64], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleNumber
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleNumber:
    push rax; 保存返回值
    push rdx; 保存返回值(第二槽)
    ; gc: free rawText
    lea RDI, [rbp-128]
    call std_memory_freeSlot
    ; gc: free s
    lea RDI, [rbp-240]
    call std_memory_freeSlot
    pop rdx; 恢复返回值(第二槽)
    pop rax; 恢复返回值
    add rsp, 328; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleComment progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleComment
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleComment
_home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleComment:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 184; 分配局部变量空间(184字节, 含对齐)
    mov QWORD [rbp-184], 0; gc ret scratch 清零
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-72], RSI; 保存参数1槽0到栈
    mov QWORD [rbp-64], RDX; 保存参数1槽1到栈
    mov QWORD [rbp-56], RCX; 保存参数1槽2到栈
    mov RBX, QWORD[rbp+-48]
    mov RCX, RBX; copySlots base
    mov RAX, QWORD [RCX]
    mov QWORD [rbp-96+0], RAX
    mov RAX, QWORD [RCX+8]
    mov QWORD [rbp-96+8], RAX
    mov RAX, QWORD [RCX+16]
    mov QWORD [rbp-96+16], RAX
; 设置变量text
    mov RDI, QWORD [rbp-96]
    mov RSI, QWORD [rbp-96+8]
    mov RDX, QWORD [rbp-96+16]
    call __string_len
    mov QWORD[rbp-104], RAX
; 设置变量plen
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+56]
    mov QWORD[rbp-112], RAX
; 设置变量start
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_91
    mov QWORD [rsp+24+8], 2
    mov QWORD [rsp+24+16], 2
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_eq
; condition
    test RAX, RAX
    jz end_if_235
    if_235:
    mov RAX, QWORD[rbp-112]
    mov RBX, 2
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量j




    for_48: ; for循环开始
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_48_end
    for_48_body:


    mov RAX, QWORD[rbp-120]
    test RAX, RAX
    jge idx_norm_ok_34d5184f82d0
    add RAX, QWORD [rbp-96+8]
    idx_norm_ok_34d5184f82d0:
    test RAX, RAX
    js idx_oob_34d5184f83c0
    cmp QWORD [rbp-96+8], RAX
    jg idx_ok_34d5184f83c0
    idx_oob_34d5184f83c0:
    push RAX
    call _panic_index_oob
    idx_ok_34d5184f83c0:
    mov RBX, QWORD [rbp-96]
    imul RAX, 1
    add RBX, RAX
    movzx RAX, BYTE [RBX]
    mov BYTE[rbp-121], al
; 设置变量b
    movzx RAX, BYTE[rbp-121]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 10
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_236
    if_236:
    jmp for_48_end
    end_if_236:
    mov RBX, QWORD[rbp-120]
    mov RAX, 1
    mov QWORD[rbp-120], RBX
    add QWORD[rbp-120], RAX
; 设置变量j
    for_48_continue:


    jmp for_48; for循环
    for_48_end: ; for循环结束
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-112]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_tokenCoord
    mov QWORD [rbp-184], RAX; gc ret scratch store
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_consume
    ; gc: call temp free $cond0
    lea RDI, [rbp-184]
    call std_memory_freeSlot
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleComment
    end_if_235:
    mov RBX, QWORD[rbp-112]
    mov RAX, 2
    mov QWORD[rbp-129], RBX
    add QWORD[rbp-129], RAX
; 设置变量j




    for_49: ; for循环开始
    mov RAX, QWORD[rbp-129]
    mov RBX, 1
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_49_end
    for_49_body:


    mov RBX, QWORD[rbp-129]
    test RBX, RBX
    jge idx_norm_ok_34d5184f9a40
    add RBX, QWORD [rbp-96+8]
    idx_norm_ok_34d5184f9a40:
    test RBX, RBX
    js idx_oob_34d5184f9b30
    cmp QWORD [rbp-96+8], RBX
    jg idx_ok_34d5184f9b30
    idx_oob_34d5184f9b30:
    push RBX
    call _panic_index_oob
    idx_ok_34d5184f9b30:
    mov RCX, QWORD [rbp-96]
    imul RBX, 1
    add RCX, RBX
    movzx RAX, BYTE [RCX]
    mov BYTE[rbp-130], al
; 设置变量b
    mov RBX, QWORD[rbp-129]
    mov RCX, 1
    add RBX, RCX
    test RBX, RBX
    jge idx_norm_ok_34d5184fa000
    add RBX, QWORD [rbp-96+8]
    idx_norm_ok_34d5184fa000:
    test RBX, RBX
    js idx_oob_34d5184fa1e0
    cmp QWORD [rbp-96+8], RBX
    jg idx_ok_34d5184fa1e0
    idx_oob_34d5184fa1e0:
    push RBX
    call _panic_index_oob
    idx_ok_34d5184fa1e0:
    mov RCX, QWORD [rbp-96]
    imul RBX, 1
    add RCX, RBX
    movzx RAX, BYTE [RCX]
    mov BYTE[rbp-131], al
; 设置变量b2
    movzx RAX, BYTE[rbp-130]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 42
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_237
    and_mid_31:
    movzx RAX, BYTE[rbp-131]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 47
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_237
    if_237:
    jmp for_49_end
    end_if_237:
    mov RCX, QWORD[rbp-129]
    mov RBX, 1
    mov QWORD[rbp-129], RCX
    add QWORD[rbp-129], RBX
; 设置变量j
    for_49_continue:


    jmp for_49; for循环
    for_49_end: ; for循环结束
    mov RAX, QWORD[rbp-129]
    mov RBX, 1
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_238
    if_238:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-112]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-129]
    mov RCX, 2
    mov QWORD [rsp+8], RBX
    add QWORD [rsp+8], RCX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_tokenCoord
    mov QWORD [rbp-184], RAX; gc ret scratch store
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_consume
    ; gc: call temp free $cond0
    lea RDI, [rbp-184]
    call std_memory_freeSlot
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleComment
    end_if_238:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-112]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-104]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_tokenCoord
    mov QWORD [rbp-184], RAX; gc ret scratch store
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_consume
    ; gc: call temp free $cond0
    lea RDI, [rbp-184]
    call std_memory_freeSlot
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleComment:
    add rsp, 184; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleString progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleString
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleString
_home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleString:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 232; 分配局部变量空间(232字节, 含对齐)
    mov QWORD [rbp-224], 0; gc ret scratch 清零
    mov QWORD [rbp-216], 0; gc ret scratch 清零
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-72], RSI; 保存参数1槽0到栈
    mov QWORD [rbp-64], RDX; 保存参数1槽1到栈
    mov QWORD [rbp-56], RCX; 保存参数1槽2到栈
    mov RBX, QWORD[rbp+-48]
    mov RCX, RBX; copySlots base
    mov RAX, QWORD [RCX]
    mov QWORD [rbp-96+0], RAX
    mov RAX, QWORD [RCX+8]
    mov QWORD [rbp-96+8], RAX
    mov RAX, QWORD [RCX+16]
    mov QWORD [rbp-96+16], RAX
; 设置变量text
    mov RDI, QWORD [rbp-96]
    mov RSI, QWORD [rbp-96+8]
    mov RDX, QWORD [rbp-96+16]
    call __string_len
    mov QWORD[rbp-104], RAX
; 设置变量plen
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+56]
    test RAX, RAX
    jge idx_norm_ok_34d5185045a0
    add RAX, QWORD [rbp-96+8]
    idx_norm_ok_34d5185045a0:
    test RAX, RAX
    js idx_oob_34d518504780
    cmp QWORD [rbp-96+8], RAX
    jg idx_ok_34d518504780
    idx_oob_34d518504780:
    push RAX
    call _panic_index_oob
    idx_ok_34d518504780:
    mov RBX, QWORD [rbp-96]
    imul RAX, 1
    add RBX, RAX
    movzx RAX, BYTE [RBX]
    mov BYTE[rbp-105], al
; 设置变量q
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+56]
    mov QWORD[rbp-113], RAX
; 设置变量start
    mov RDI, QWORD [rbp-72]
    mov RSI, QWORD [rbp-72+8]
    mov RDX, QWORD [rbp-72+16]
    call __string_len
    mov QWORD[rbp-121], RAX
; 设置变量dl
    mov RAX, QWORD[rbp-113]
    mov RBX, QWORD[rbp-121]
    mov QWORD[rbp-129], RAX
    add QWORD[rbp-129], RBX
; 设置变量i




    for_50: ; for循环开始
    mov RAX, QWORD[rbp-129]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_50_end
    for_50_body:


    movzx RAX, BYTE[rbp-105]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 96
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_239
    and_mid_32:
    mov RAX, QWORD[rbp-129]
    test RAX, RAX
    jge idx_norm_ok_34d518505950
    add RAX, QWORD [rbp-96+8]
    idx_norm_ok_34d518505950:
    test RAX, RAX
    js idx_oob_34d518505a40
    cmp QWORD [rbp-96+8], RAX
    jg idx_ok_34d518505a40
    idx_oob_34d518505a40:
    push RAX
    call _panic_index_oob
    idx_ok_34d518505a40:
    mov RBX, QWORD [rbp-96]
    imul RAX, 1
    add RBX, RAX
    movzx RAX, BYTE [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 10
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_239
    if_239:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-72]
    mov RBX, QWORD [rbp-72+8]
    push RAX
    push RBX
    sub rsp, 16; register args buffer
    mov RCX, QWORD[rbp-129]
    test RCX, RCX
    jge idx_norm_ok_34d51851a3c0
    add RCX, QWORD [rbp-96+8]
    idx_norm_ok_34d51851a3c0:
    test RCX, RCX
    js idx_oob_34d51851a4b0
    cmp QWORD [rbp-96+8], RCX
    jg idx_ok_34d51851a4b0
    idx_oob_34d51851a4b0:
    push RCX
    call _panic_index_oob
    idx_ok_34d51851a4b0:
    mov RDX, QWORD [rbp-96]
    imul RCX, 1
    add RDX, RCX
    movzx RAX, BYTE [RDX]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-208]; 大值返回槽地址
    call std_strings_fromByte
    mov RAX, QWORD [rbp-208]; gc ret scratch ptr
    mov QWORD [rbp-216], RAX; gc ret scratch store
    mov RAX, QWORD [RBP-208]
    mov RBX, QWORD [RBP-208+8]
    push RAX
    push RBX
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [rsp+0], RAX
    mov QWORD [rsp+0+8], R9
    mov QWORD [rsp+0+16], R12
    mov QWORD [rbp-224], RAX; gc scratch concat
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_panic
    ; gc: call temp free $cond0
    lea RDI, [rbp-224]
    call std_memory_freeSlot
    ; gc: call temp free $cond1
    lea RDI, [rbp-216]
    call std_memory_freeSlot
    end_if_239:
    mov RAX, QWORD[rbp-129]
    test RAX, RAX
    jge idx_norm_ok_34d51851ac30
    add RAX, QWORD [rbp-96+8]
    idx_norm_ok_34d51851ac30:
    test RAX, RAX
    js idx_oob_34d51851ad20
    cmp QWORD [rbp-96+8], RAX
    jg idx_ok_34d51851ad20
    idx_oob_34d51851ad20:
    push RAX
    call _panic_index_oob
    idx_ok_34d51851ad20:
    mov RDX, QWORD [rbp-96]
    imul RAX, 1
    add RDX, RAX
    movzx RAX, BYTE [RDX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    movzx RCX, BYTE[rbp-105]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_240
    if_240:
    sub RSP, 40
    mov RAX, QWORD [rbp-96]
    mov QWORD [RSP+32], RAX; staging right
    mov RAX, QWORD[rbp-113]
    mov RBX, QWORD[rbp-121]
    add RAX, RBX
    mov QWORD [RSP+24], RAX; staging lo idx
    mov RAX, [RSP+24]
    imul RAX, 1
    add RAX, [RSP+32]
    mov QWORD [RSP], RAX; R.ptr
    mov RAX, QWORD[rbp-129]
    sub RAX, [RSP+24]; R.len = hi|len - lo
    mov QWORD [RSP+8], RAX; R.len
    mov RAX, QWORD [rbp-96+16]
    sub RAX, [RSP+24]
    mov QWORD [RSP+16], RAX; R.cap
    mov RBX, [RSP]
    mov RCX, [RSP+8]
    mov RDX, [RSP+16]
    add RSP, 40
    mov QWORD [rbp-153], RBX
    mov QWORD [rbp-153+8], RCX
    mov QWORD [rbp-153+16], RDX
; 设置变量str
    movzx RAX, BYTE[rbp-105]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 39
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_241
    and_mid_34:
    mov RDI, QWORD [rbp-153]
    mov RSI, QWORD [rbp-153+8]
    mov RDX, QWORD [rbp-153+16]
    call __string_len
    mov RAX, RAX; len/cap 结果
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_241
    and_mid_33:
    mov RDI, QWORD [rbp-153]
    mov RSI, QWORD [rbp-153+8]
    mov RDX, QWORD [rbp-153+16]
    call __string_len
    mov RAX, RAX; len/cap 结果
    mov RBX, 1
    cmp RAX, RBX
    setge al
    movzx RAX, al
    mov RBX, RAX
    mov RDX, QWORD [rbp-153]
    movzx RCX, BYTE [RDX]
    mov RDX, 92
    cmp RCX, RDX
    sete cl
    movzx RCX, cl
    mov RAX, RBX
    and RAX, RCX
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_241
    if_241:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 0
    mov QWORD [rsp+0+8], 0
    mov QWORD [rsp+0+16], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_panic
    end_if_241:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, 104
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [RBX+64], RAX
    mov QWORD [RBX+72], RAX
    mov QWORD [RBX+80], RAX
    mov QWORD [RBX+88], RAX
    mov QWORD [RBX+96], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_STRING]
    mov QWORD [RBX+0], RCX
    mov RBX, QWORD [RSP]
    mov RAX, QWORD [rbp-153]
    mov QWORD [RBX+24+0], RAX
    mov RAX, QWORD [rbp-153+8]
    mov QWORD [RBX+24+8], RAX
    mov RAX, QWORD [rbp-153+16]
    mov QWORD [RBX+24+16], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-113]
    mov QWORD [RBX+56], RCX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-129]
    mov RDX, QWORD[rbp-121]
    add RCX, RDX
    mov QWORD [RBX+64], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleString
    end_if_240:
    mov RAX, QWORD[rbp-129]
    mov RBX, 1
    mov QWORD[rbp-129], RAX
    add QWORD[rbp-129], RBX
; 设置变量i
    for_50_continue:


    jmp for_50; for循环
    for_50_end: ; for循环结束
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-113]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_tokenCoord
    mov QWORD [rbp-224], RAX; gc ret scratch store
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_consume
    ; gc: call temp free $cond0
    lea RDI, [rbp-224]
    call std_memory_freeSlot
    mov RDI, 104
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [RBX+64], RAX
    mov QWORD [RBX+72], RAX
    mov QWORD [RBX+80], RAX
    mov QWORD [RBX+88], RAX
    mov QWORD [RBX+96], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NONE]
    mov QWORD [RBX+0], RCX
    mov RBX, QWORD [RSP]
    mov QWORD [RBX+24], 0
    mov QWORD [RBX+24+8], 0
    mov QWORD [RBX+24+16], 0
    mov RBX, QWORD [RSP]
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+72]
    mov QWORD [RBX+72], RCX
    mov RBX, QWORD [RSP]
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+64]
    mov QWORD [RBX+80], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rbp-161], RBX
; 设置变量te
    mov RAX, QWORD[rbp-161]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleString
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleString:
    add rsp, 232; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
_home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 296; 分配局部变量空间(296字节, 含对齐)
    mov QWORD [rbp-296], 0; gc ret scratch 清零
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RBX, QWORD[rbp+-48]
    mov RDI, QWORD [RBX]
    mov RSI, QWORD [RBX+8]
    mov RDX, QWORD [RBX+16]
    call __string_len
    mov QWORD[rbp-56], RAX
; 设置变量plen
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+56]
    mov QWORD[rbp-64], RAX
; 设置变量i




    for_51: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_51_end
    for_51_body:


    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp+-48]
    test RAX, RAX
    jge idx_norm_ok_34d51855f770
    add RAX, QWORD [RBX+8]
    idx_norm_ok_34d51855f770:
    test RAX, RAX
    js idx_oob_34d51855f860
    cmp QWORD [RBX+8], RAX
    jg idx_ok_34d51855f860
    idx_oob_34d51855f860:
    push RAX
    call _panic_index_oob
    idx_ok_34d51855f860:
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX]
    imul RAX, 1
    add RBX, RAX
    movzx RAX, BYTE [RBX]
    mov QWORD[rbp-72], RAX
; 设置变量ib
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 32
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_242
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 9
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_242
    jne end_if_242
    if_242:
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量i
    jmp for_51_continue
    end_if_242:
    jmp for_51_end
    for_51_continue:


    jmp for_51; for循环
    for_51_end: ; for循环结束
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_tokenCoord
    mov QWORD [rbp-296], RAX; gc ret scratch store
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_consume
    ; gc: call temp free $cond0
    lea RDI, [rbp-296]
    call std_memory_freeSlot
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_243
    if_243:
    mov RDI, 104
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [RBX+64], RAX
    mov QWORD [RBX+72], RAX
    mov QWORD [RBX+80], RAX
    mov QWORD [RBX+88], RAX
    mov QWORD [RBX+96], RAX
    mov RBX, QWORD [RSP]
    mov RAX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NONE]
    mov QWORD [RBX+0], RAX
    mov RBX, QWORD [RSP]
    mov QWORD [RBX+24], 0
    mov QWORD [RBX+24+8], 0
    mov QWORD [RBX+24+16], 0
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+72]
    mov QWORD [RBX+72], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+64]
    mov QWORD [RBX+80], RAX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rbp-80], RBX
; 设置变量t
    mov RAX, QWORD[rbp-80]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
    end_if_243:
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+56]
    mov RBX, QWORD[rbp+-48]
    test RAX, RAX
    jge idx_norm_ok_34d518571590
    add RAX, QWORD [RBX+8]
    idx_norm_ok_34d518571590:
    test RAX, RAX
    js idx_oob_34d518571770
    cmp QWORD [RBX+8], RAX
    jg idx_ok_34d518571770
    idx_oob_34d518571770:
    push RAX
    call _panic_index_oob
    idx_ok_34d518571770:
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX]
    imul RAX, 1
    add RBX, RAX
    movzx RAX, BYTE [RBX]
    mov BYTE[rbp-81], al
; 设置变量firstByte
    mov BYTE[rbp-82], 0
; 设置变量secondByte
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+56]
    mov RBX, 1
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_244
    if_244:
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+56]
    mov RDX, 1
    add RCX, RDX
    mov RBX, QWORD[rbp+-48]
    test RCX, RCX
    jge idx_norm_ok_34d5185a64b0
    add RCX, QWORD [RBX+8]
    idx_norm_ok_34d5185a64b0:
    test RCX, RCX
    js idx_oob_34d5185a6690
    cmp QWORD [RBX+8], RCX
    jg idx_ok_34d5185a6690
    idx_oob_34d5185a6690:
    push RCX
    call _panic_index_oob
    idx_ok_34d5185a6690:
    mov RDX, QWORD[rbp+-48]
    mov RBX, QWORD [RDX]
    imul RCX, 1
    add RBX, RCX
    movzx RAX, BYTE [RBX]
    mov BYTE[rbp-82], al
; 设置变量secondByte
    end_if_244:
    sub rsp, 16; register args buffer
    movzx RBX, BYTE[rbp-81]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigit
; ||-chain leaf
    test RAX, RAX
    jnz if_245
    movzx RAX, BYTE[rbp-81]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 46
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne or_and_35
    and_mid_37:
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+56]
    mov RBX, 1
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb or_and_35
    and_mid_36:
    sub rsp, 16; register args buffer
    movzx RBX, BYTE[rbp-82]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigit
; condition
    test RAX, RAX
    jz or_and_35
    jmp if_245
    or_and_35:
    jmp end_if_245
    if_245:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleNumber
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
    end_if_245:
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+56]
    mov QWORD[rbp-64], RAX
; 设置变量i




    for_52: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_52_end
    for_52_body:


    mov QWORD[rbp-90], 0
; 设置变量delimLen
    mov QWORD[rbp-98], 3
; 设置变量e




    for_53: ; for循环开始
    mov RAX, QWORD[rbp-98]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle for_53_end
    for_53_body:


    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-98]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_246
    if_246:
    mov RBX, QWORD[rbp-98]
    mov RCX, 1
    mov QWORD[rbp-98], RBX
    sub QWORD[rbp-98], RCX
; 设置变量e
    jmp for_53_continue
    end_if_246:
    sub RSP, 40
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX]
    mov QWORD [RSP+32], RBX; staging right
    mov RAX, QWORD[rbp-64]
    mov QWORD [RSP+24], RAX; staging lo idx
    mov RAX, [RSP+24]
    imul RAX, 1
    add RAX, [RSP+32]
    mov QWORD [RSP], RAX; R.ptr
    mov RAX, QWORD[rbp-64]
    mov R12, RAX
    mov RCX, QWORD[rbp-98]
    mov RAX, R12
    add RAX, RCX
    sub RAX, [RSP+24]; R.len = hi|len - lo
    mov QWORD [RSP+8], RAX; R.len
    mov RAX, QWORD [rbp-48+16]
    sub RAX, [RSP+24]
    mov QWORD [RSP+16], RAX; R.cap
    mov RCX, [RSP]
    mov RDX, [RSP+8]
    mov RSI, [RSP+16]
    add RSP, 40
    mov QWORD [rbp-122], RCX
    mov QWORD [rbp-122+8], RDX
    mov QWORD [rbp-122+16], RSI
; 设置变量cand
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-122]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-122+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-122+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_isDelimiter
; condition
    test RAX, RAX
    jz end_if_247
    if_247:
    mov RBX, QWORD[rbp-98]
    mov QWORD[rbp-90], RBX
; 设置变量delimLen
    jmp for_53_end
    end_if_247:
    mov RBX, QWORD[rbp-98]
    mov RCX, 1
    mov QWORD[rbp-98], RBX
    sub QWORD[rbp-98], RCX
; 设置变量e
    for_53_continue:


    jmp for_53; for循环
    for_53_end: ; for循环结束
    mov RAX, QWORD[rbp-90]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_248
    if_248:
    mov RBX, QWORD[rbp-64]
    mov RCX, 1
    mov QWORD[rbp-64], RBX
    add QWORD[rbp-64], RCX
; 设置变量i
    jmp for_52_continue
    end_if_248:
    sub RSP, 40
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX]
    mov QWORD [RSP+32], RBX; staging right
    mov RAX, QWORD[rbp-64]
    mov QWORD [RSP+24], RAX; staging lo idx
    mov RAX, [RSP+24]
    imul RAX, 1
    add RAX, [RSP+32]
    mov QWORD [RSP], RAX; R.ptr
    mov RAX, QWORD[rbp-64]
    mov R12, RAX
    mov RCX, QWORD[rbp-90]
    mov RAX, R12
    add RAX, RCX
    sub RAX, [RSP+24]; R.len = hi|len - lo
    mov QWORD [RSP+8], RAX; R.len
    mov RAX, QWORD [rbp-48+16]
    sub RAX, [RSP+24]
    mov QWORD [RSP+16], RAX; R.cap
    mov RCX, [RSP]
    mov RDX, [RSP+8]
    mov RSI, [RSP+16]
    add RSP, 40
    mov QWORD [rbp-146], RCX
    mov QWORD [rbp-146+8], RDX
    mov QWORD [rbp-146+16], RSI
; 设置变量delimiter
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-146]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-146+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-146+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_91
    mov QWORD [rsp+24+8], 2
    mov QWORD [rsp+24+16], 2
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_eq
; ||-chain leaf
    test RAX, RAX
    jnz if_249
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-146]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-146+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-146+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_90
    mov QWORD [rsp+24+8], 2
    mov QWORD [rsp+24+16], 2
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_eq
; ||-chain leaf
    test RAX, RAX
    jnz if_249
    jz end_if_249
    if_249:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD [RBX+56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_250
    if_250:
    sub RSP, 40
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX]
    mov QWORD [RSP+32], RBX; staging right
    mov RCX, QWORD[rbp+-48]
    mov RAX, QWORD [RCX+56]
    mov QWORD [RSP+24], RAX; staging lo idx
    mov RAX, [RSP+24]
    imul RAX, 1
    add RAX, [RSP+32]
    mov QWORD [RSP], RAX; R.ptr
    mov RAX, QWORD[rbp-64]
    sub RAX, [RSP+24]; R.len = hi|len - lo
    mov QWORD [RSP+8], RAX; R.len
    mov RAX, QWORD [rbp-48+16]
    sub RAX, [RSP+24]
    mov QWORD [RSP+16], RAX; R.cap
    mov RCX, [RSP]
    mov RDX, [RSP+8]
    mov RSI, [RSP+16]
    add RSP, 40
    mov QWORD [rbp-170], RCX
    mov QWORD [rbp-170+8], RDX
    mov QWORD [rbp-170+16], RSI
; 设置变量head
    mov RBX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NAME]
    mov QWORD[rbp-178], RBX
; 设置变量headTyp
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-170]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-170+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-170+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_isKeyword
; condition
    test RAX, RAX
    jz end_if_251
    if_251:
    mov RBX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_KEYWORD]
    mov QWORD[rbp-178], RBX
; 设置变量headTyp
    end_if_251:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, 104
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [RBX+64], RAX
    mov QWORD [RBX+72], RAX
    mov QWORD [RBX+80], RAX
    mov QWORD [RBX+88], RAX
    mov QWORD [RBX+96], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-178]
    mov QWORD [RBX+0], RCX
    mov RBX, QWORD [RSP]
    mov RAX, QWORD [rbp-170]
    mov QWORD [RBX+24+0], RAX
    mov RAX, QWORD [rbp-170+8]
    mov QWORD [RBX+24+8], RAX
    mov RAX, QWORD [rbp-170+16]
    mov QWORD [RBX+24+16], RAX
    mov RBX, QWORD [RSP]
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+56]
    mov QWORD [RBX+56], RCX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-64]
    mov QWORD [RBX+64], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
    end_if_250:
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD [rbp-146]
    mov QWORD [rsp+8+0], RAX
    mov RAX, QWORD [rbp-146+8]
    mov QWORD [rsp+8+8], RAX
    mov RAX, QWORD [rbp-146+16]
    mov QWORD [rsp+8+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数1
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleComment
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
    end_if_249:
    mov RDI, QWORD [rbp-146]
    mov RSI, QWORD [rbp-146+8]
    mov RDX, QWORD [rbp-146+16]
    call __string_len
    mov RAX, RAX; len/cap 结果
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_252
    and_mid_38:
    mov RAX, QWORD [rbp-146]
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 96
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_252
    mov RAX, QWORD [rbp-146]
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 39
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_252
    mov RAX, QWORD [rbp-146]
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 34
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_252
    jne end_if_252
    if_252:
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RAX, QWORD [rbp-146]
    mov QWORD [rsp+8+0], RAX
    mov RAX, QWORD [rbp-146+8]
    mov QWORD [rsp+8+8], RAX
    mov RAX, QWORD [rbp-146+16]
    mov QWORD [rsp+8+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数1
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_handleString
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
    end_if_252:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD [RBX+56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_253
    if_253:
    sub RSP, 40
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD [RBX]
    mov QWORD [RSP+32], RCX; staging right
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+56]
    mov QWORD [RSP+24], RAX; staging lo idx
    mov RAX, [RSP+24]
    imul RAX, 1
    add RAX, [RSP+32]
    mov QWORD [RSP], RAX; R.ptr
    mov RAX, QWORD[rbp-64]
    sub RAX, [RSP+24]; R.len = hi|len - lo
    mov QWORD [RSP+8], RAX; R.len
    mov RAX, QWORD [rbp-48+16]
    sub RAX, [RSP+24]
    mov QWORD [RSP+16], RAX; R.cap
    mov RBX, [RSP]
    mov RDX, [RSP+8]
    mov RSI, [RSP+16]
    add RSP, 40
    mov QWORD [rbp-202], RBX
    mov QWORD [rbp-202+8], RDX
    mov QWORD [rbp-202+16], RSI
; 设置变量val
    mov RAX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NAME]
    mov QWORD[rbp-210], RAX
; 设置变量tokenTyp
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-202]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-202+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-202+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_isKeyword
; condition
    test RAX, RAX
    jz end_if_254
    if_254:
    mov RAX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_KEYWORD]
    mov QWORD[rbp-210], RAX
; 设置变量tokenTyp
    end_if_254:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, 104
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [RBX+64], RAX
    mov QWORD [RBX+72], RAX
    mov QWORD [RBX+80], RAX
    mov QWORD [RBX+88], RAX
    mov QWORD [RBX+96], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-210]
    mov QWORD [RBX+0], RCX
    mov RBX, QWORD [RSP]
    mov RAX, QWORD [rbp-202]
    mov QWORD [RBX+24+0], RAX
    mov RAX, QWORD [rbp-202+8]
    mov QWORD [RBX+24+8], RAX
    mov RAX, QWORD [rbp-202+16]
    mov QWORD [RBX+24+16], RAX
    mov RBX, QWORD [RSP]
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+56]
    mov QWORD [RBX+56], RCX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-64]
    mov QWORD [RBX+64], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
    end_if_253:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, 104
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [RBX+64], RAX
    mov QWORD [RBX+72], RAX
    mov QWORD [RBX+80], RAX
    mov QWORD [RBX+88], RAX
    mov QWORD [RBX+96], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_DELIMITER]
    mov QWORD [RBX+0], RCX
    mov RBX, QWORD [RSP]
    mov RAX, QWORD [rbp-146]
    mov QWORD [RBX+24+0], RAX
    mov RAX, QWORD [rbp-146+8]
    mov QWORD [RBX+24+8], RAX
    mov RAX, QWORD [rbp-146+16]
    mov QWORD [RBX+24+16], RAX
    mov RBX, QWORD [RSP]
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+56]
    mov QWORD [RBX+56], RCX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-64]
    mov R12, RCX
    mov RDX, QWORD[rbp-90]
    mov RCX, R12
    add RCX, RDX
    mov QWORD [RBX+64], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
    for_52_continue:


    jmp for_52; for循环
    for_52_end: ; for循环结束
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD [RBX+56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_255
    if_255:
    sub RSP, 40
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD [RBX]
    mov QWORD [RSP+32], RCX; staging right
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+56]
    mov QWORD [RSP+24], RAX; staging lo idx
    mov RAX, [RSP+24]
    imul RAX, 1
    add RAX, [RSP+32]
    mov QWORD [RSP], RAX; R.ptr
    mov RAX, QWORD[rbp-64]
    sub RAX, [RSP+24]; R.len = hi|len - lo
    mov QWORD [RSP+8], RAX; R.len
    mov RAX, QWORD [rbp-48+16]
    sub RAX, [RSP+24]
    mov QWORD [RSP+16], RAX; R.cap
    mov RBX, [RSP]
    mov RDX, [RSP+8]
    mov RSI, [RSP+16]
    add RSP, 40
    mov QWORD [rbp-234], RBX
    mov QWORD [rbp-234+8], RDX
    mov QWORD [rbp-234+16], RSI
; 设置变量val
    mov RAX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NAME]
    mov QWORD[rbp-242], RAX
; 设置变量tokenTyp2
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-234]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-234+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-234+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_isKeyword
; condition
    test RAX, RAX
    jz end_if_256
    if_256:
    mov RAX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_KEYWORD]
    mov QWORD[rbp-242], RAX
; 设置变量tokenTyp2
    end_if_256:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, 104
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [RBX+64], RAX
    mov QWORD [RBX+72], RAX
    mov QWORD [RBX+80], RAX
    mov QWORD [RBX+88], RAX
    mov QWORD [RBX+96], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-242]
    mov QWORD [RBX+0], RCX
    mov RBX, QWORD [RSP]
    mov RAX, QWORD [rbp-234]
    mov QWORD [RBX+24+0], RAX
    mov RAX, QWORD [rbp-234+8]
    mov QWORD [RBX+24+8], RAX
    mov RAX, QWORD [rbp-234+16]
    mov QWORD [RBX+24+16], RAX
    mov RBX, QWORD [RSP]
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+56]
    mov QWORD [RBX+56], RCX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-64]
    mov QWORD [RBX+64], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_makeToken
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
    end_if_255:
    mov RDI, 104
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [RBX+64], RAX
    mov QWORD [RBX+72], RAX
    mov QWORD [RBX+80], RAX
    mov QWORD [RBX+88], RAX
    mov QWORD [RBX+96], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NONE]
    mov QWORD [RBX+0], RCX
    mov RBX, QWORD [RSP]
    mov QWORD [RBX+24], 0
    mov QWORD [RBX+24+8], 0
    mov QWORD [RBX+24+16], 0
    mov RBX, QWORD [RSP]
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+72]
    mov QWORD [RBX+72], RCX
    mov RBX, QWORD [RSP]
    mov RDX, QWORD[rbp+-48]
    mov RCX, QWORD [RDX+64]
    mov QWORD [RBX+80], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rbp-250], RBX
; 设置变量te
    mov RAX, QWORD[rbp-250]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch:
    add rsp, 296; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Lexer_next progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Lexer_next
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Lexer_next
_home_gx_Desktop_tiny_selfhost_lexer_Lexer_next:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-120], 0; gc ret scratch 清零
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_read
    mov QWORD[rbp-56], RAX
; 设置变量hit
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_257
    if_257:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_coordFromTokenEnd
    mov QWORD [rbp-120], RAX; gc ret scratch store
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPos
    ; gc: call temp free $cond0
    lea RDI, [rbp-120]
    call std_memory_freeSlot
    mov RAX, QWORD[rbp-56]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_next
    end_if_257:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
    mov QWORD[rbp-64], RAX
; 设置变量tok
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NONE]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_258
    if_258:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_savePfPos
    mov QWORD [rbp-120], RAX; gc ret scratch store
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPos
    ; gc: call temp free $cond0
    lea RDI, [rbp-120]
    call std_memory_freeSlot
    mov RAX, QWORD[rbp-64]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_next
    end_if_258:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_RingBuffer_read
    mov QWORD[rbp-72], RAX
; 设置变量dropT
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_259
    if_259:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_coordFromTokenEnd
    mov QWORD [rbp-120], RAX; gc ret scratch store
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPos
    ; gc: call temp free $cond0
    lea RDI, [rbp-120]
    call std_memory_freeSlot
    mov RAX, QWORD[rbp-64]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_next
    end_if_259:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_coordFromTokenEnd
    mov QWORD [rbp-120], RAX; gc ret scratch store
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPos
    ; gc: call temp free $cond0
    lea RDI, [rbp-120]
    call std_memory_freeSlot
    mov RAX, QWORD[rbp-64]
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_next
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_next:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_lexer_Lexer_skipToken progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_lexer_Lexer_skipToken
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_lexer_Lexer_skipToken
_home_gx_Desktop_tiny_selfhost_lexer_Lexer_skipToken:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 152; 分配局部变量空间(152字节, 含对齐)
    mov QWORD [rbp-152], 0; gc ret scratch 清零
    mov QWORD [rbp-144], 0; gc ret scratch 清零
    mov QWORD [rbp-136], 0; gc ret scratch 清零
    mov QWORD [rbp-128], 0; gc ret scratch 清零
    mov QWORD [rbp-120], 0; gc ret scratch 清零
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-72], RSI; 保存参数1槽0到栈
    mov QWORD [rbp-64], RDX; 保存参数1槽1到栈
    mov QWORD [rbp-56], RCX; 保存参数1槽2到栈
    mov QWORD [rbp-80], 0; gc: zero exit slot nt
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_next
    mov QWORD[rbp-80], RAX
; 设置变量nt
    mov RBX, QWORD [RBP-80]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_KEYWORD]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je or_and_39
    and_mid_40:
    mov RBX, QWORD [RBP-80]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_DELIMITER]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je or_and_39
    jmp if_260
    or_and_39:
    sub rsp, 48; register args buffer
    mov RBX, QWORD [RBP-80]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+24]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RBX+24+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RBX+24+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_ne
; ||-chain leaf
    test RAX, RAX
    jnz if_260
    jz end_if_260
    if_260:
    sub rsp, 32; register args buffer
    mov R8, str_132
    mov R9, 12
    push R8
    push R9
    mov R8, QWORD [rbp-72]
    mov R9, QWORD [rbp-72+8]
    push R8
    push R9
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [RBP-112], RAX
    mov QWORD [RBP-112+8], R9
    mov QWORD [RBP-112+16], R12
    mov QWORD [rbp-128], RAX; gc scratch concat
    mov RSI, QWORD [RBP-112]
    mov RDI, QWORD [RBP-112+8]
    push RSI
    push RDI
    mov RSI, str_133
    mov RDI, 13
    push RSI
    push RDI
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [RBP-112], RAX
    mov QWORD [RBP-112+8], R9
    mov QWORD [RBP-112+16], R12
    mov QWORD [rbp-136], RAX; gc scratch concat
    mov RCX, QWORD [RBP-112]
    mov RDX, QWORD [RBP-112+8]
    push RCX
    push RDX
    sub rsp, 16; register args buffer
    mov RDX, QWORD[rbp-80]
    mov QWORD [rsp+0], RDX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-112]; 大值返回槽地址
    call _home_gx_Desktop_tiny_selfhost_lexer_Token_string
    mov RAX, QWORD [rbp-112]; gc ret scratch ptr
    mov QWORD [rbp-120], RAX; gc ret scratch store
    mov R8, QWORD [RBP-112]
    mov RCX, QWORD [RBP-112+8]
    push R8
    push RCX
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [RBP-112], RAX
    mov QWORD [RBP-112+8], R9
    mov QWORD [RBP-112+16], R12
    mov QWORD [rbp-144], RAX; gc scratch concat
    mov RAX, QWORD [RBP-112]
    mov RBX, QWORD [RBP-112+8]
    push RAX
    push RBX
    mov RSI, str_68
    mov RAX, 1
    push RSI
    push RAX
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [rsp+0], RAX
    mov QWORD [rsp+0+8], R9
    mov QWORD [rsp+0+16], R12
    mov QWORD [rbp-152], RAX; gc scratch concat
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_panic
    ; gc: call temp free $cond0
    lea RDI, [rbp-152]
    call std_memory_freeSlot
    ; gc: call temp free $cond1
    lea RDI, [rbp-144]
    call std_memory_freeSlot
    ; gc: call temp free $cond2
    lea RDI, [rbp-136]
    call std_memory_freeSlot
    ; gc: call temp free $cond3
    lea RDI, [rbp-128]
    call std_memory_freeSlot
    ; gc: call temp free $cond4
    lea RDI, [rbp-120]
    call std_memory_freeSlot
    end_if_260:
    func_end__home_gx_Desktop_tiny_selfhost_lexer_Lexer_skipToken:
    push rax; 保存返回值
    push rdx; 保存返回值(第二槽)
    ; gc: free nt
    mov RDI, QWORD [rbp-80]
    test RDI, RDI
    jz gc_drop_skip41
    call __gc_drop__Token
    mov QWORD [rbp-80], 0
    gc_drop_skip41:
    pop rdx; 恢复返回值(第二槽)
    pop rax; 恢复返回值
    add rsp, 152; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_syscall_syscall progbits alloc exec nowrite align=16
global std_syscall_syscall
; ==============================
; Function: std_syscall_syscall
std_syscall_syscall:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    mov QWORD [rbp-72], RCX; 保存参数3到栈
    mov RAX, QWORD[rbp-48]
    mov RDI, QWORD[rbp-56]
    mov RSI, QWORD[rbp-64]
    mov RDX, QWORD[rbp-72]
    syscall
    func_end_std_syscall_syscall:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_syscall_syscall64 progbits alloc exec nowrite align=16
global std_syscall_syscall64
; ==============================
; Function: std_syscall_syscall64
std_syscall_syscall64:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 136; 分配局部变量空间(136字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    mov QWORD [rbp-72], RCX; 保存参数3到栈
    mov QWORD [rbp-80], R8; 保存参数4到栈
    mov QWORD [rbp-88], R9; 保存参数5到栈
    mov RAX, QWORD[rbp-48]
    mov RDI, QWORD[rbp-56]
    mov RSI, QWORD[rbp-64]
    mov RDX, QWORD[rbp-72]
    mov R10, QWORD[rbp-80]
    mov R8, QWORD[rbp-88]
    syscall
    func_end_std_syscall_syscall64:
    add rsp, 136; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_syscall_exit progbits alloc exec nowrite align=16
global std_syscall_exit
; ==============================
; Function: std_syscall_exit
std_syscall_exit:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov DWORD [rbp-48], EDI; 保存参数0到栈
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 60
; 参数0
    mov EAX, DWORD[rbp-48]
    mov QWORD [rsp+8], RAX
; 参数1
    mov QWORD [rsp+16], 0
; 参数2
    mov QWORD [rsp+24], 0
; 参数3
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数3
    add rsp, 32; 释放寄存器参数 buffer
    call std_syscall_syscall
    func_end_std_syscall_exit:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_syscall_brk progbits alloc exec nowrite align=16
global std_syscall_brk
; ==============================
; Function: std_syscall_brk
std_syscall_brk:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], 12
; 参数0
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov QWORD [rsp+16], 0
; 参数2
    mov QWORD [rsp+24], 0
; 参数3
    mov QWORD [rsp+32], 0
; 参数4
    mov QWORD [rsp+40], 0
; 参数5
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数3
    mov R8, QWORD [rsp+32]; 装载参数4
    mov R9, QWORD [rsp+40]; 装载参数5
    add rsp, 48; 释放寄存器参数 buffer
    call std_syscall_syscall64
; return值存入RAX
    jmp func_end_std_syscall_brk
    func_end_std_syscall_brk:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_syscall_write progbits alloc exec nowrite align=16
global std_syscall_write
; ==============================
; Function: std_syscall_write
std_syscall_write:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov DWORD [rbp-48], EDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
    mov EBX, DWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+16], RBX
; 参数2
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+24], RBX
; 参数3
    mov QWORD [rsp+32], 0
; 参数4
    mov QWORD [rsp+40], 0
; 参数5
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数3
    mov R8, QWORD [rsp+32]; 装载参数4
    mov R9, QWORD [rsp+40]; 装载参数5
    add rsp, 48; 释放寄存器参数 buffer
    call std_syscall_syscall64
; return值存入RAX
    jmp func_end_std_syscall_write
    func_end_std_syscall_write:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_syscall_read progbits alloc exec nowrite align=16
global std_syscall_read
; ==============================
; Function: std_syscall_read
std_syscall_read:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov DWORD [rbp-48], EDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov EBX, DWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+16], RBX
; 参数2
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+24], RBX
; 参数3
    mov QWORD [rsp+32], 0
; 参数4
    mov QWORD [rsp+40], 0
; 参数5
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数3
    mov R8, QWORD [rsp+32]; 装载参数4
    mov R9, QWORD [rsp+40]; 装载参数5
    add rsp, 48; 释放寄存器参数 buffer
    call std_syscall_syscall64
; return值存入RAX
    jmp func_end_std_syscall_read
    func_end_std_syscall_read:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_syscall_close progbits alloc exec nowrite align=16
global std_syscall_close
; ==============================
; Function: std_syscall_close
std_syscall_close:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov DWORD [rbp-48], EDI; 保存参数0到栈
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 3
; 参数0
    mov EBX, DWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov QWORD [rsp+16], 0
; 参数2
    mov QWORD [rsp+24], 0
; 参数3
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数3
    add rsp, 32; 释放寄存器参数 buffer
    call std_syscall_syscall
; return值存入RAX
    jmp func_end_std_syscall_close
    func_end_std_syscall_close:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_builtin_print progbits alloc exec nowrite align=16
global std_builtin_print
; ==============================
; Function: std_builtin_print
std_builtin_print:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring
    mov QWORD[rbp-72], RAX
; 设置变量cstr
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+8], RAX
; 参数1
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_syscall_write
    mov DWORD[rbp-76], EAX
; 设置变量n
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    mov EAX, DWORD[rbp-76]
; return值存入RAX
    jmp func_end_std_builtin_print
    func_end_std_builtin_print:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_builtin_println progbits alloc exec nowrite align=16
global std_builtin_println
; ==============================
; Function: std_builtin_println
std_builtin_println:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 136; 分配局部变量空间(136字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_print
    mov DWORD[rbp-68], EAX
; 设置变量n
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-76], RAX
; 设置变量buf
    mov RAX, QWORD[rbp-76]
    mov QWORD[rbp-84], RAX
; 设置变量q
    mov RAX, 10
    mov RBX, QWORD[rbp-84]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
    mov RAX, QWORD[rbp-76]
    mov QWORD [rsp+8], RAX
; 参数1
    mov QWORD [rsp+16], 1
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_syscall_write
    mov DWORD[rbp-88], EAX
; 设置变量w
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-76]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    mov EAX, DWORD[rbp-68]
    mov EBX, DWORD[rbp-88]
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_builtin_println
    func_end_std_builtin_println:
    add rsp, 136; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_builtin_panic progbits alloc exec nowrite align=16
global std_builtin_panic
; ==============================
; Function: std_builtin_panic
std_builtin_panic:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_print
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 0
    mov QWORD [rsp+0+8], 0
    mov QWORD [rsp+0+16], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_println
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_exit
    func_end_std_builtin_panic:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_parse_FnBlock_parse progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_parse_FnBlock_parse
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_parse_FnBlock_parse
_home_gx_Desktop_tiny_selfhost_parse_FnBlock_parse:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 136; 分配局部变量空间(136字节, 含对齐)
    mov QWORD [rbp-136], 0; gc ret scratch 清零
    mov QWORD [rbp-128], 0; gc ret scratch 清零
    mov QWORD [rbp-120], 0; gc ret scratch 清零
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD [rbp-64], 0; gc: zero exit slot tok
    sub rsp, 32; register args buffer
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], str_48
    mov QWORD [rsp+8+8], 2
    mov QWORD [rsp+8+16], 2
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数1
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_skipToken
    sub rsp, 16; register args buffer
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_next
    mov QWORD[rbp-64], RAX
; 设置变量tok
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NAME]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_261
    if_261:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_134
    mov QWORD [rsp+0+8], 18
    mov QWORD [rsp+0+16], 18
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_panic
    end_if_261:
    mov RBX, QWORD[rbp+-48]
    mov RCX, QWORD [RBP-64]
    test RCX, RCX
    je _panic_nil_deref
    mov RAX, QWORD [RCX+24]
    mov QWORD [RBX+0], RAX
    mov RAX, QWORD [RCX+24+8]
    mov QWORD [RBX+8], RAX
    mov RAX, QWORD [RCX+24+16]
    mov QWORD [RBX+16], RAX
; 设置变量self.name
    ; gc: assign free tok
    lea RDI, [rbp-64]
    call std_memory_freeSlot
    sub rsp, 16; register args buffer
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
    mov QWORD[rbp-64], RAX
; 设置变量tok
    sub rsp, 48; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_DELIMITER]
    mov QWORD [rsp+8], RAX
; 参数1
    mov QWORD [rsp+16], str_108
    mov QWORD [rsp+16+8], 1
    mov QWORD [rsp+16+16], 1
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数2
    mov R8, QWORD [rsp+32]; 装载参数2
    add rsp, 48; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Token_is
; condition
    test RAX, RAX
    jz end_if_262
    if_262:
    ; gc: assign free tok
    lea RDI, [rbp-64]
    call std_memory_freeSlot
    sub rsp, 16; register args buffer
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
    mov QWORD[rbp-64], RAX
; 设置变量tok
    end_if_262:
    sub rsp, 48; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_DELIMITER]
    mov QWORD [rsp+8], RAX
; 参数1
    mov QWORD [rsp+16], str_75
    mov QWORD [rsp+16+8], 1
    mov QWORD [rsp+16+16], 1
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数2
    mov R8, QWORD [rsp+32]; 装载参数2
    add rsp, 48; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Token_is
; condition
    test RAX, RAX
    jz end_if_263
    if_263:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, [rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_parse_FnBlock_parseArgs
    end_if_263:
    sub rsp, 32; register args buffer
    mov RCX, str_135
    mov RDX, 17
    push RCX
    push RDX
    mov RSI, QWORD[rbp+-48]
    mov RCX, QWORD [RSI]
    mov RDX, QWORD [RSI+8]
    push RCX
    push RDX
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [RBP-112], RAX
    mov QWORD [RBP-112+8], R9
    mov QWORD [RBP-112+16], R12
    mov QWORD [rbp-128], RAX; gc scratch concat
    mov RAX, QWORD [RBP-112]
    mov RBX, QWORD [RBP-112+8]
    push RAX
    push RBX
    mov RAX, str_136
    mov RBX, 7
    push RAX
    push RBX
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [rsp+0], RAX
    mov QWORD [rsp+0+8], R9
    mov QWORD [rsp+0+16], R12
    mov QWORD [rbp-136], RAX; gc scratch concat
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_print
    ; gc: call temp free $cond0
    lea RDI, [rbp-136]
    call std_memory_freeSlot
    ; gc: call temp free $cond1
    lea RDI, [rbp-128]
    call std_memory_freeSlot


    mov QWORD[rbp-72], 0
; 设置变量i


    for_54: ; for循环开始
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    lea RBX, [RBX+24]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_slices_len__T__Arg
    mov RCX, RAX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_54_end
    for_54_body:


    mov RAX, QWORD[rbp-72]
    mov RBX, QWORD[rbp+-48]
    test RAX, RAX
    jge idx_norm_ok_34d5187afa40
    add RAX, QWORD [RBX+24+8]
    idx_norm_ok_34d5187afa40:
    test RAX, RAX
    js idx_oob_34d5187afb30
    cmp QWORD [RBX+24+8], RAX
    jg idx_ok_34d5187afb30
    idx_oob_34d5187afb30:
    push RAX
    call _panic_index_oob
    idx_ok_34d5187afb30:
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX+24]
    imul RAX, 8
    add RBX, RAX
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-80], RAX
; 设置变量a
    sub rsp, 32; register args buffer
    mov R8, QWORD [RBP-80]
    test R8, R8
    je _panic_nil_deref
    mov RSI, QWORD [R8]
    mov RDI, QWORD [R8+8]
    push RSI
    push RDI
    mov RSI, str_108
    mov RDI, 1
    push RSI
    push RDI
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [RBP-112], RAX
    mov QWORD [RBP-112+8], R9
    mov QWORD [RBP-112+16], R12
    mov QWORD [rbp-120], RAX; gc scratch concat
    mov RCX, QWORD [RBP-112]
    mov RDX, QWORD [RBP-112+8]
    push RCX
    push RDX
    mov RSI, QWORD [RBP-80]
    test RSI, RSI
    je _panic_nil_deref
    mov RCX, QWORD [RSI+24]
    mov RDX, QWORD [RSI+24+8]
    push RCX
    push RDX
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [RBP-112], RAX
    mov QWORD [RBP-112+8], R9
    mov QWORD [RBP-112+16], R12
    mov QWORD [rbp-128], RAX; gc scratch concat
    mov RBX, QWORD [RBP-112]
    mov RAX, QWORD [RBP-112+8]
    push RBX
    push RAX
    mov RAX, str_137
    mov RBX, 2
    push RAX
    push RBX
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [rsp+0], RAX
    mov QWORD [rsp+0+8], R9
    mov QWORD [rsp+0+16], R12
    mov QWORD [rbp-136], RAX; gc scratch concat
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_print
    ; gc: call temp free $cond0
    lea RDI, [rbp-136]
    call std_memory_freeSlot
    ; gc: call temp free $cond1
    lea RDI, [rbp-128]
    call std_memory_freeSlot
    ; gc: call temp free $cond2
    lea RDI, [rbp-120]
    call std_memory_freeSlot
    for_54_continue:


    mov RAX, QWORD[rbp-72]
    mov RBX, 1
    mov QWORD[rbp-72], RAX
    add QWORD[rbp-72], RBX
; 设置变量i
    jmp for_54; for循环
    for_54_end: ; for循环结束
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 0
    mov QWORD [rsp+0+8], 0
    mov QWORD [rsp+0+16], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_println
    func_end__home_gx_Desktop_tiny_selfhost_parse_FnBlock_parse:
    push rax; 保存返回值
    push rdx; 保存返回值(第二槽)
    ; gc: free tok
    mov RDI, QWORD [rbp-64]
    test RDI, RDI
    jz gc_drop_skip42
    call __gc_drop__Token
    mov QWORD [rbp-64], 0
    gc_drop_skip42:
    pop rdx; 恢复返回值(第二槽)
    pop rax; 恢复返回值
    add rsp, 136; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_parse_FnBlock_parseArgs progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_parse_FnBlock_parseArgs
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_parse_FnBlock_parseArgs
_home_gx_Desktop_tiny_selfhost_parse_FnBlock_parseArgs:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 200; 分配局部变量空间(200字节, 含对齐)
    mov QWORD [rbp-192], 0; gc ret scratch 清零
    mov QWORD [rbp-184], 0; gc ret scratch 清零
    mov QWORD [rbp-176], 0; gc ret scratch 清零
    mov QWORD [rbp-168], 0; gc ret scratch 清零
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD [rbp-72], 0; gc: zero exit slot tok
    mov RBX, QWORD[rbp+-48]
    mov QWORD QWORD[RBX+24], 0
    mov QWORD [RBX+24+8], 0
    mov QWORD [RBX+24+16], 0; 空容器
; 设置变量self.args
    sub rsp, 32; register args buffer
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], str_75
    mov QWORD [rsp+8+8], 1
    mov QWORD [rsp+8+16], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数1
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_skipToken
    mov QWORD[rbp-64], 1
; 设置变量bracketCount
    mov QWORD [rbp-72+0], 0
    ; 零值结构体 tok
    sub rsp, 16; register args buffer
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_next
    mov QWORD[rbp-72], RAX
; 设置变量tok
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NAME]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_264
    if_264:
    sub rsp, 48; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_DELIMITER]
    mov QWORD [rsp+8], RAX
; 参数1
    mov QWORD [rsp+16], str_76
    mov QWORD [rsp+16+8], 1
    mov QWORD [rsp+16+16], 1
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数2
    mov R8, QWORD [rsp+32]; 装载参数2
    add rsp, 48; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Token_is
; condition
    test RAX, RAX
    jz else_if_265
    if_265:
    jmp func_end__home_gx_Desktop_tiny_selfhost_parse_FnBlock_parseArgs
    jmp end_if_265
    else_if_265:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_138
    mov QWORD [rsp+0+8], 6
    mov QWORD [rsp+0+16], 6
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_panic
    end_if_265:
    end_if_264:
    mov RDI, 56
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD [RBP-72]
    test RCX, RCX
    je _panic_nil_deref
    mov RAX, QWORD [RCX+24]
    mov QWORD [RBX+0+0], RAX
    mov RAX, QWORD [RCX+24+8]
    mov QWORD [RBX+0+8], RAX
    mov RAX, QWORD [RCX+24+16]
    mov QWORD [RBX+0+16], RAX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rbp-80], RBX
; 设置变量newArg
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    lea RBX, [RBX+24]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_slices_push__T__Arg




    for_55: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je for_55_end
    for_55_body:


    ; gc: assign free tok
    lea RDI, [rbp-72]
    call std_memory_freeSlot
    sub rsp, 16; register args buffer
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_next
    mov QWORD[rbp-72], RAX
; 设置变量tok
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Token_isSemiOrNewline
; condition
    test RAX, RAX
    jz end_if_266
    if_266:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_139
    mov QWORD [rsp+0+8], 9
    mov QWORD [rsp+0+16], 9
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_panic
    end_if_266:
    sub rsp, 56; switch target spill
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+24]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RBX+24+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RBX+24+16]
    mov QWORD [rsp+0+16], RAX
; switch target
    mov QWORD [rsp+32], str_75
    mov QWORD [rsp+32+8], 1
    mov QWORD [rsp+32+16], 1
; switch case value
    mov RDI, QWORD [rsp+0]
    mov RSI, QWORD [rsp+8]
    mov RDX, QWORD [rsp+16]
    mov RCX, QWORD [rsp+32]
    mov R8, QWORD [rsp+40]
    mov R9, QWORD [rsp+48]
    call std_strings_eq
    cmp RAX, 0
    jne case_switch_2_0
    mov QWORD [rsp+32], str_76
    mov QWORD [rsp+32+8], 1
    mov QWORD [rsp+32+16], 1
; switch case value
    mov RDI, QWORD [rsp+0]
    mov RSI, QWORD [rsp+8]
    mov RDX, QWORD [rsp+16]
    mov RCX, QWORD [rsp+32]
    mov R8, QWORD [rsp+40]
    mov R9, QWORD [rsp+48]
    call std_strings_eq
    cmp RAX, 0
    jne case_switch_2_1
    mov QWORD [rsp+32], str_82
    mov QWORD [rsp+32+8], 1
    mov QWORD [rsp+32+16], 1
; switch case value
    mov RDI, QWORD [rsp+0]
    mov RSI, QWORD [rsp+8]
    mov RDX, QWORD [rsp+16]
    mov RCX, QWORD [rsp+32]
    mov R8, QWORD [rsp+40]
    mov R9, QWORD [rsp+48]
    call std_strings_eq
    cmp RAX, 0
    jne case_switch_2_2
    mov QWORD [rsp+32], str_93
    mov QWORD [rsp+32+8], 1
    mov QWORD [rsp+32+16], 1
; switch case value
    mov RDI, QWORD [rsp+0]
    mov RSI, QWORD [rsp+8]
    mov RDX, QWORD [rsp+16]
    mov RCX, QWORD [rsp+32]
    mov R8, QWORD [rsp+40]
    mov R9, QWORD [rsp+48]
    call std_strings_eq
    cmp RAX, 0
    jne case_switch_2_3
    jmp switch_end_switch_2
    add rsp, 56
    case_switch_2_0:
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量bracketCount
    jmp switch_end_switch_2
    case_switch_2_1:
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    sub QWORD[rbp-64], RBX
; 设置变量bracketCount
    jmp switch_end_switch_2
    case_switch_2_2:
    ; gc: assign free tok
    lea RDI, [rbp-72]
    call std_memory_freeSlot
    sub rsp, 16; register args buffer
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_next
    mov QWORD[rbp-72], RAX
; 设置变量tok
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NAME]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_267
    if_267:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_138
    mov QWORD [rsp+0+8], 6
    mov QWORD [rsp+0+16], 6
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_panic
    end_if_267:
    mov RDI, 56
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD [RBP-72]
    test RCX, RCX
    je _panic_nil_deref
    mov RAX, QWORD [RCX+24]
    mov QWORD [RBX+0+0], RAX
    mov RAX, QWORD [RCX+24+8]
    mov QWORD [RBX+0+8], RAX
    mov RAX, QWORD [RCX+24+16]
    mov QWORD [RBX+0+16], RAX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rbp-80], RBX
; 设置变量newArg
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    lea RBX, [RBX+24]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_slices_push__T__Arg
    jmp switch_end_switch_2
    case_switch_2_3:
    ; gc: assign free tok
    lea RDI, [rbp-72]
    call std_memory_freeSlot
    sub rsp, 16; register args buffer
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_next
    mov QWORD[rbp-72], RAX
; 设置变量tok
    sub rsp, 48; register args buffer
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+24]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RBX+24+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RBX+24+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_77
    mov QWORD [rsp+24+8], 1
    mov QWORD [rsp+24+16], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_eq
; condition
    test RAX, RAX
    jz end_if_268
    if_268:
    jmp for_55_continue
    end_if_268:
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NAME]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_269
    if_269:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_138
    mov QWORD [rsp+0+8], 6
    mov QWORD [rsp+0+16], 6
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_panic
    end_if_269:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    lea RBX, [RBX+24]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_slices_len__T__Arg
    mov RBX, 1
    mov QWORD[rbp-96], RAX
    sub QWORD[rbp-96], RBX
; 设置变量/home/gx/Desktop/______/tiny/selfhost/parse.i


    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    lea RBX, [RBX+24]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_slices_len__T__Arg
    mov RBX, 1
    mov QWORD[rbp-96], RAX
    sub QWORD[rbp-96], RBX
; 设置变量/home/gx/Desktop/______/tiny/selfhost/parse.i


    for_56: ; for循环开始
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl for_56_end
    for_56_body:


    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp+-48]
    test RAX, RAX
    jge idx_norm_ok_34d5187ce4b0
    add RAX, QWORD [RBX+24+8]
    idx_norm_ok_34d5187ce4b0:
    test RAX, RAX
    js idx_oob_34d5187ce5a0
    cmp QWORD [RBX+24+8], RAX
    jg idx_ok_34d5187ce5a0
    idx_oob_34d5187ce5a0:
    push RAX
    call _panic_index_oob
    idx_ok_34d5187ce5a0:
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX+24]
    imul RAX, 8
    add RBX, RAX
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-104], RAX
; 设置变量a
    sub rsp, 48; register args buffer
    mov RBX, QWORD [RBP-104]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+24]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RBX+24+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RBX+24+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], 0
    mov QWORD [rsp+24+8], 0
    mov QWORD [rsp+24+16], 0
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_ne
; condition
    test RAX, RAX
    jz end_if_270
    if_270:
    jmp for_56_end
    end_if_270:
    mov RBX, QWORD [RBP-104]
    test RBX, RBX
    je _panic_nil_deref
    mov RCX, QWORD [RBP-72]
    test RCX, RCX
    je _panic_nil_deref
    mov RAX, QWORD [RCX+24]
    mov QWORD [RBX+24+0], RAX
    mov RAX, QWORD [RCX+24+8]
    mov QWORD [RBX+24+8], RAX
    mov RAX, QWORD [RCX+24+16]
    mov QWORD [RBX+24+16], RAX
; 设置变量a.typ
    for_56_continue:


    mov RAX, QWORD[rbp-96]
    mov RBX, 1
    mov QWORD[rbp-96], RAX
    sub QWORD[rbp-96], RBX
; 设置变量/home/gx/Desktop/______/tiny/selfhost/parse.i
    jmp for_56; for循环
    for_56_end: ; for循环结束
    jmp switch_end_switch_2
    switch_end_switch_2:
    for_55_continue:


    jmp for_55; for循环
    for_55_end: ; for循环结束


    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    lea RBX, [RBX+24]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_slices_len__T__Arg
    mov RBX, 1
    mov QWORD[rbp-113], RAX
    sub QWORD[rbp-113], RBX
; 设置变量/home/gx/Desktop/______/tiny/selfhost/parse.i


    for_57: ; for循环开始
    mov RAX, QWORD[rbp-113]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl for_57_end
    for_57_body:


    mov RAX, QWORD[rbp-113]
    mov RBX, QWORD[rbp+-48]
    test RAX, RAX
    jge idx_norm_ok_34d5187cfc20
    add RAX, QWORD [RBX+24+8]
    idx_norm_ok_34d5187cfc20:
    test RAX, RAX
    js idx_oob_34d5187cfd10
    cmp QWORD [RBX+24+8], RAX
    jg idx_ok_34d5187cfd10
    idx_oob_34d5187cfd10:
    push RAX
    call _panic_index_oob
    idx_ok_34d5187cfd10:
    mov RCX, QWORD[rbp+-48]
    mov RBX, QWORD [RCX+24]
    imul RAX, 8
    add RBX, RAX
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-121], RAX
; 设置变量a
    sub rsp, 48; register args buffer
    mov RBX, QWORD [RBP-121]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+24]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RBX+24+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RBX+24+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], 0
    mov QWORD [rsp+24+8], 0
    mov QWORD [rsp+24+16], 0
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_ne
; condition
    test RAX, RAX
    jz end_if_271
    if_271:
    jmp for_57_end
    end_if_271:
    mov BYTE[rbp-105], 1
; 设置变量err
    sub rsp, 32; register args buffer
    mov R8, str_140
    mov R9, 9
    push R8
    push R9
    mov R10, QWORD[rbp+-48]
    mov R8, QWORD [R10]
    mov R9, QWORD [R10+8]
    push R8
    push R9
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [RBP-160], RAX
    mov QWORD [RBP-160+8], R9
    mov QWORD [RBP-160+16], R12
    mov QWORD [rbp-168], RAX; gc scratch concat
    mov RSI, QWORD [RBP-160]
    mov RDI, QWORD [RBP-160+8]
    push RSI
    push RDI
    mov RSI, str_141
    mov RDI, 4
    push RSI
    push RDI
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [RBP-160], RAX
    mov QWORD [RBP-160+8], R9
    mov QWORD [RBP-160+16], R12
    mov QWORD [rbp-176], RAX; gc scratch concat
    mov RCX, QWORD [RBP-160]
    mov RDX, QWORD [RBP-160+8]
    push RCX
    push RDX
    mov RDX, QWORD [RBP-121]
    test RDX, RDX
    je _panic_nil_deref
    mov R8, QWORD [RDX]
    mov RCX, QWORD [RDX+8]
    push R8
    push RCX
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [RBP-160], RAX
    mov QWORD [RBP-160+8], R9
    mov QWORD [RBP-160+16], R12
    mov QWORD [rbp-184], RAX; gc scratch concat
    mov RAX, QWORD [RBP-160]
    mov RBX, QWORD [RBP-160+8]
    push RAX
    push RBX
    mov RSI, str_142
    mov RAX, 10
    push RSI
    push RAX
    pop R12
    pop R13
    pop R14
    pop R15
    mov R9, R14
    add R9, R12
    lea RDI, [R9+8]
    and RDI, -8
    mov RDI, RDI
    call std_memory_malloc
    mov RAX, RAX
    mov RDI, RAX
    add RDI, R14
    mov RSI, R13
    mov RCX, R12
    rep movsb
    mov RDI, RAX
    mov RSI, R15
    mov RCX, R14
    rep movsb
    mov R9, R14
    add R9, R12
    mov byte [RAX+R9], 0
    mov byte [RAX+R9+1], 0
    lea R12, [R9+8]
    and R12, -8
    dec R12
    mov QWORD [rsp+0], RAX
    mov QWORD [rsp+0+8], R9
    mov QWORD [rsp+0+16], R12
    mov QWORD [rbp-192], RAX; gc scratch concat
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_println
    ; gc: call temp free $cond0
    lea RDI, [rbp-192]
    call std_memory_freeSlot
    ; gc: call temp free $cond1
    lea RDI, [rbp-184]
    call std_memory_freeSlot
    ; gc: call temp free $cond2
    lea RDI, [rbp-176]
    call std_memory_freeSlot
    ; gc: call temp free $cond3
    lea RDI, [rbp-168]
    call std_memory_freeSlot
    for_57_continue:


    mov RAX, QWORD[rbp-113]
    mov RBX, 1
    mov QWORD[rbp-113], RAX
    sub QWORD[rbp-113], RBX
; 设置变量/home/gx/Desktop/______/tiny/selfhost/parse.i
    jmp for_57; for循环
    for_57_end: ; for循环结束
    movzx RAX, BYTE[rbp-105]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_272
    if_272:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 0
    mov QWORD [rsp+0+8], 0
    mov QWORD [rsp+0+16], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_panic
    end_if_272:
    func_end__home_gx_Desktop_tiny_selfhost_parse_FnBlock_parseArgs:
    push rax; 保存返回值
    push rdx; 保存返回值(第二槽)
    ; gc: free tok
    mov RDI, QWORD [rbp-72]
    test RDI, RDI
    jz gc_drop_skip43
    call __gc_drop__Token
    mov QWORD [rbp-72], 0
    gc_drop_skip43:
    pop rdx; 恢复返回值(第二槽)
    pop rax; 恢复返回值
    add rsp, 200; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_parse_newParser progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_parse_newParser
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_parse_newParser
_home_gx_Desktop_tiny_selfhost_parse_newParser:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RDI, 24
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov RBX, QWORD [RSP]
    mov RCX, QWORD[rbp-48]
    mov QWORD [RBX+16], RCX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov RAX, RBX
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_parse_newParser
    func_end__home_gx_Desktop_tiny_selfhost_parse_newParser:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text._home_gx_Desktop_tiny_selfhost_parse_Parser_next progbits alloc exec nowrite align=16
global _home_gx_Desktop_tiny_selfhost_parse_Parser_next
; ==============================
; Function: _home_gx_Desktop_tiny_selfhost_parse_Parser_next
_home_gx_Desktop_tiny_selfhost_parse_Parser_next:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], 0; gc: zero exit slot t
    mov QWORD [rbp-64], 0; gc: zero exit slot f
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+16]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_prefetch
    mov QWORD[rbp-56], RAX
; 设置变量t
    mov QWORD [rbp-64], 0; gc: zero slot f
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_KEYWORD]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_273
    if_273:
    sub rsp, 56; switch target spill
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+24]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RBX+24+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RBX+24+16]
    mov QWORD [rsp+0+16], RAX
; switch target
    mov QWORD [rsp+32], str_48
    mov QWORD [rsp+32+8], 2
    mov QWORD [rsp+32+16], 2
; switch case value
    mov RDI, QWORD [rsp+0]
    mov RSI, QWORD [rsp+8]
    mov RDX, QWORD [rsp+16]
    mov RCX, QWORD [rsp+32]
    mov R8, QWORD [rsp+40]
    mov R9, QWORD [rsp+48]
    call std_strings_eq
    cmp RAX, 0
    jne case_switch_3_0
    jmp switch_end_switch_3
    add rsp, 56
    case_switch_3_0:
    mov RDI, 48
    call std_memory_malloc
    push RAX; save new obj
    mov RBX, QWORD [RSP]
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rbp-64], RBX
; 设置变量f
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_parse_FnBlock_parse
    jmp switch_end_switch_3
    switch_end_switch_3:
    ; gc: block free f
    mov RDI, QWORD [rbp-64]
    test RDI, RDI
    jz gc_drop_skip44
    call __gc_drop__FnBlock
    mov QWORD [rbp-64], 0
    gc_drop_skip44:
    end_if_273:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp+-48]
    mov RAX, QWORD [RBX+16]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call _home_gx_Desktop_tiny_selfhost_lexer_Lexer_setPosAsPfPos
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov RBX, QWORD[rel __global__home_gx_Desktop_tiny_selfhost_lexer_NONE]
    cmp RAX, RBX
    sete al
    movzx RAX, al
; return值存入RAX
    jmp func_end__home_gx_Desktop_tiny_selfhost_parse_Parser_next
    func_end__home_gx_Desktop_tiny_selfhost_parse_Parser_next:
    push rax; 保存返回值
    push rdx; 保存返回值(第二槽)
    ; gc: free t
    mov RDI, QWORD [rbp-56]
    test RDI, RDI
    jz gc_drop_skip45
    call __gc_drop__Token
    mov QWORD [rbp-56], 0
    gc_drop_skip45:
    ; gc: free f
    mov RDI, QWORD [rbp-64]
    test RDI, RDI
    jz gc_drop_skip46
    call __gc_drop__FnBlock
    mov QWORD [rbp-64], 0
    gc_drop_skip46:
    pop rdx; 恢复返回值(第二槽)
    pop rax; 恢复返回值
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_slices_len__T__Arg progbits alloc exec nowrite align=16
global std_slices_len__T__Arg
; ==============================
; Function: std_slices_len__T__Arg
std_slices_len__T__Arg:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-56], RAX
; 设置变量sAddr
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-64], RAX
; 设置变量hdr
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
; return值存入RAX
    jmp func_end_std_slices_len__T__Arg
    func_end_std_slices_len__T__Arg:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_slices_push__T__Arg progbits alloc exec nowrite align=16
global std_slices_push__T__Arg
; ==============================
; Function: std_slices_push__T__Arg
std_slices_push__T__Arg:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 152; 分配局部变量空间(152字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-64], RAX
; 设置变量sAddr
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_274
    if_274:
    jmp func_end_std_slices_push__T__Arg
    end_if_274:
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-72], RAX
; 设置变量hdr
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
    mov QWORD[rbp-80], RAX
; 设置变量curLen
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD[rbp-88], RAX
; 设置变量curCap
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_275
    if_275:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_slices_grow__T__Arg
; expression statement
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
    mov QWORD[rbp-80], RAX
; 设置变量curLen
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD[rbp-88], RAX
; 设置变量curCap
    end_if_275:
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl end_if_276
    if_276:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_slices_grow__T__Arg
; expression statement
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
    mov QWORD[rbp-80], RAX
; 设置变量curLen
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD[rbp-88], RAX
; 设置变量curCap
    end_if_276:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_slices_elemPtr__T__Arg
    mov QWORD[rbp-96], RAX
; 设置变量elemAddr
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-104], RAX
; 设置变量valPtr
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-104]
    mov QWORD [RBX], RAX
; expression statement
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-80]
    mov RCX, 1
    mov QWORD[RBX+8], RAX
    add QWORD[RBX+8], RCX
; 设置变量hdr.n
    func_end_std_slices_push__T__Arg:
    add rsp, 152; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_slices_grow__T__Arg progbits alloc exec nowrite align=16
global std_slices_grow__T__Arg
; ==============================
; Function: std_slices_grow__T__Arg
std_slices_grow__T__Arg:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 200; 分配局部变量空间(200字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-64], RAX
; 设置变量sAddr
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-72], RAX
; 设置变量hdr
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov RCX, QWORD [RBP-72]
    test RCX, RCX
    je _panic_nil_deref
    mov RBX, QWORD [RCX+8]
    mov QWORD[rbp-80], RAX
    sub QWORD[rbp-80], RBX
; 设置变量has
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_277
    if_277:
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
; return值存入RAX
    jmp func_end_std_slices_grow__T__Arg
    end_if_277:
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
    mov QWORD[rbp-88], RAX
; 设置变量oldLen
    mov RAX, QWORD[rbp-88]
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RBX
; 设置变量target
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD[rbp-104], RAX
; 设置变量newCap
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 512
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge else_if_278
    if_278:
    mov RAX, QWORD[rbp-104]
    mov RBX, 2
    mov QWORD[rbp-104], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存乘数
    mov RAX, QWORD[rbp-104]
    imul RAX, qword [rsp]
    mov QWORD[rbp-104], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量newCap
    jmp end_if_278
    else_if_278:
    mov RAX, QWORD[rbp-104]
    mov RBX, 4
    mov QWORD[rbp-112], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-112]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-112], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量q
    mov RAX, QWORD[rbp-104]
    mov RBX, QWORD[rbp-112]
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量newCap
    end_if_278:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_279
    if_279:
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-104], RAX
; 设置变量newCap
    end_if_279:
    mov QWORD[rbp-120], 8
; 设置变量elemSize
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-128], RAX
; 设置变量oldData
    mov RAX, QWORD[rbp-104]
    mov RBX, QWORD[rbp-120]
    mov QWORD[rbp-136], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存乘数
    mov RAX, QWORD[rbp-136]
    imul RAX, qword [rsp]
    mov QWORD[rbp-136], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量newBufSize
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-136]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-144], RAX
; 设置变量newData
    mov RBX, QWORD[rbp-88]
    mov RAX, QWORD[rbp-120]
    mov QWORD[rbp-152], RBX
    push RAX; 保护RAX(左子结果)
    push RAX; 暂存乘数
    mov RAX, QWORD[rbp-152]
    imul RAX, qword [rsp]
    mov QWORD[rbp-152], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量copyBytes
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-144]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-128]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-152]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_memmove
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-128]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-144]
    mov QWORD[RBX], RAX
; 设置变量hdr.p
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-104]
    mov QWORD[RBX+16], RAX
; 设置变量hdr.c
    mov RAX, QWORD[rbp-104]
; return值存入RAX
    jmp func_end_std_slices_grow__T__Arg
    func_end_std_slices_grow__T__Arg:
    add rsp, 200; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_slices_elemPtr__T__Arg progbits alloc exec nowrite align=16
global std_slices_elemPtr__T__Arg
; ==============================
; Function: std_slices_elemPtr__T__Arg
std_slices_elemPtr__T__Arg:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov QWORD[rbp-64], 8
; 设置变量elemSize
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-72], RAX
; 设置变量hdr
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-80], RAX
; 设置变量data
    mov RBX, QWORD[rbp-56]
    mov RCX, QWORD[rbp-64]
    imul RBX, RCX
    mov RAX, QWORD[rbp-80]
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_slices_elemPtr__T__Arg
    func_end_std_slices_elemPtr__T__Arg:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======



; ==============================
; 程序入口点 (ELF入口)
_start:
    call main
    ._hang_after_exit:
    pause
    jmp ._hang_after_exit

section .text._panic_index_oob progbits alloc exec nowrite align=1
; ==============================
; Runtime helper: index out of range panic
_panic_index_oob:
push rbp
mov rbp, rsp
push rbx
mov rax, 1
mov rdi, 2
lea rsi, [rel _oob_msg]
mov rdx, 21
syscall
mov rax, 60
mov rdi, 1
syscall
pop rbx
pop rbp
ret
section .text._panic_nil_deref progbits alloc exec nowrite align=1
; ==============================
; Runtime helper: nil pointer dereference panic
_panic_nil_deref:
push rbp
mov rbp, rsp
push rbx
mov rax, 1
mov rdi, 2
lea rsi, [rel _nil_msg]
mov rdx, 23
syscall
mov rax, 60
mov rdi, 1
syscall
pop rbx
pop rbp
ret
section .text._memmove progbits alloc exec nowrite align=1
; ==============================
; Runtime helper: memmove(dst, src, n)
_memmove:
push rbp
mov rbp, rsp
push rbx
mov rcx, rdx
cmp rdi, rsi
jge .memmove_rev
cld
rep movsb
jmp .memmove_done
.memmove_rev:
std
lea rsi, [rsi+rcx-1]
lea rdi, [rdi+rcx-1]
rep movsb
cld
.memmove_done:
pop rbx
pop rbp
ret

section .data._oob_msg progbits alloc nowrite align=1
    _oob_msg db "index out of range", 10
    _oob_msg_len equ $ - _oob_msg
    _nil_msg db "nil pointer dereference", 10
    _nil_msg_len equ $ - _nil_msg
section .data
    str_82 db `,`, 0
    str_82_len equ $ - str_82
    str_90 db `/*`, 0
    str_90_len equ $ - str_90
    str_4 db `|leaks=`, 0
    str_4_len equ $ - str_4
    str_19 db ` rcbit=`, 0
    str_19_len equ $ - str_19
    str_103 db `>=`, 0
    str_103_len equ $ - str_103
    str_110 db `]`, 0
    str_110_len equ $ - str_110
    str_46 db `false`, 0
    str_46_len equ $ - str_46
    str_69 db `%`, 0
    str_69_len equ $ - str_69
    str_78 db `*=`, 0
    str_78_len equ $ - str_78
    str_86 db `->`, 0
    str_86_len equ $ - str_86
    str_133 db `\", but miss \"`, 0
    str_133_len equ $ - str_133
    str_142 db ` need type`, 0
    str_142_len equ $ - str_142
    str_115 db `|`, 0
    str_115_len equ $ - str_115
    str_125 db `DELIMITER`, 0
    str_125_len equ $ - str_125
    str_137 db `] `, 0
    str_137_len equ $ - str_137
    str_20 db ` tracked=`, 0
    str_20_len equ $ - str_20
    str_23 db `scan allocN=`, 0
    str_23_len equ $ - str_23
    str_89 db `/`, 0
    str_89_len equ $ - str_89
    str_105 db `>>=`, 0
    str_105_len equ $ - str_105
    str_134 db `function need name`, 0
    str_134_len equ $ - str_134
    str_140 db `Function:`, 0
    str_140_len equ $ - str_140
    str_73 db `&=`, 0
    str_73_len equ $ - str_73
    str_135 db `Parse Function：`, 0
    str_135_len equ $ - str_135
    str_45 db `fallthrough`, 0
    str_45_len equ $ - str_45
    str_98 db `<<=`, 0
    str_98_len equ $ - str_98
    str_100 db `=`, 0
    str_100_len equ $ - str_100
    str_18 db ` hdr=`, 0
    str_18_len equ $ - str_18
    str_79 db `+`, 0
    str_79_len equ $ - str_79
    str_108 db `[`, 0
    str_108_len equ $ - str_108
    str_25 db ` freeN=`, 0
    str_25_len equ $ - str_25
    str_10 db ` blk=`, 0
    str_10_len equ $ - str_10
    str_11 db ` free=`, 0
    str_11_len equ $ - str_11
    str_53 db `let`, 0
    str_53_len equ $ - str_53
    str_67 db `!=`, 0
    str_67_len equ $ - str_67
    str_75 db `(`, 0
    str_75_len equ $ - str_75
    str_117 db `||`, 0
    str_117_len equ $ - str_117
    str_121 db `\r`, 0
    str_121_len equ $ - str_121
    str_56 db `ret`, 0
    str_56_len equ $ - str_56
    str_63 db `var`, 0
    str_63_len equ $ - str_63
    str_36 db `build`, 0
    str_36_len equ $ - str_36
    str_43 db `enum`, 0
    str_43_len equ $ - str_43
    str_54 db `nil`, 0
    str_54_len equ $ - str_54
    str_64 db `while`, 0
    str_64_len equ $ - str_64
    str_99 db `<=`, 0
    str_99_len equ $ - str_99
    str_12 db ` bytes=`, 0
    str_12_len equ $ - str_12
    str_16 db `ALLOC blk=`, 0
    str_16_len equ $ - str_16
    str_72 db `&&`, 0
    str_72_len equ $ - str_72
    str_107 db `@`, 0
    str_107_len equ $ - str_107
    str_119 db `~`, 0
    str_119_len equ $ - str_119
    str_27 db ` bad=`, 0
    str_27_len equ $ - str_27
    str_8 db `freeHeads=`, 0
    str_8_len equ $ - str_8
    str_21 db ` prevF=`, 0
    str_21_len equ $ - str_21
    str_35 db `break`, 0
    str_35_len equ $ - str_35
    str_39 db `continue`, 0
    str_39_len equ $ - str_39
    str_42 db `else`, 0
    str_42_len equ $ - str_42
    str_93 db `:`, 0
    str_93_len equ $ - str_93
    str_122 db `NONE`, 0
    str_122_len equ $ - str_122
    str_1 db `/home/gx/Desktop/代码/tiny/pkg/console/console.cute`, 0
    str_1_len equ $ - str_1
    str_50 db `if`, 0
    str_50_len equ $ - str_50
    str_92 db `/=`, 0
    str_92_len equ $ - str_92
    str_109 db `\\`, 0
    str_109_len equ $ - str_109
    str_120 db `\t`, 0
    str_120_len equ $ - str_120
    str_81 db `+=`, 0
    str_81_len equ $ - str_81
    str_97 db `<<`, 0
    str_97_len equ $ - str_97
    str_5 db `\n`, 0
    str_5_len equ $ - str_5
    str_34 db `=== end ===\n`, 0
    str_34_len equ $ - str_34
    str_37 db `case`, 0
    str_37_len equ $ - str_37
    str_48 db `fn`, 0
    str_48_len equ $ - str_48
    str_51 db `import`, 0
    str_51_len equ $ - str_51
    str_80 db `++`, 0
    str_80_len equ $ - str_80
    str_88 db `...`, 0
    str_88_len equ $ - str_88
    str_114 db `{`, 0
    str_114_len equ $ - str_114
    str_30 db ` isFree=`, 0
    str_30_len equ $ - str_30
    str_111 db `^`, 0
    str_111_len equ $ - str_111
    str_118 db `}`, 0
    str_118_len equ $ - str_118
    str_132 db `need token \"`, 0
    str_132_len equ $ - str_132
    str_52 db `interface`, 0
    str_52_len equ $ - str_52
    str_62 db `type`, 0
    str_62_len equ $ - str_62
    str_85 db `-=`, 0
    str_85_len equ $ - str_85
    str_123 db `STRING`, 0
    str_123_len equ $ - str_123
    str_3 db `|free=`, 0
    str_3_len equ $ - str_3
    str_31 db `topBlk hdr=`, 0
    str_31_len equ $ - str_31
    str_40 db `default`, 0
    str_40_len equ $ - str_40
    str_57 db `return`, 0
    str_57_len equ $ - str_57
    str_91 db `//`, 0
    str_91_len equ $ - str_91
    str_95 db `;`, 0
    str_95_len equ $ - str_95
    str_101 db `==`, 0
    str_101_len equ $ - str_101
    str_2 db `SELFHOST_LEAK|alloc=`, 0
    str_2_len equ $ - str_2
    str_47 db `finally`, 0
    str_47_len equ $ - str_47
    str_126 db `NUMBER`, 0
    str_126_len equ $ - str_126
    str_14 db `freeTotal=`, 0
    str_14_len equ $ - str_14
    str_77 db `*`, 0
    str_77_len equ $ - str_77
    str_94 db `:=`, 0
    str_94_len equ $ - str_94
    str_102 db `>`, 0
    str_102_len equ $ - str_102
    str_32 db ` rc=`, 0
    str_32_len equ $ - str_32
    str_33 db ` addr=`, 0
    str_33_len equ $ - str_33
    str_38 db `const`, 0
    str_38_len equ $ - str_38
    str_41 db `defer`, 0
    str_41_len equ $ - str_41
    str_116 db `|=`, 0
    str_116_len equ $ - str_116
    str_66 db `!`, 0
    str_66_len equ $ - str_66
    str_74 db `'`, 0
    str_74_len equ $ - str_74
    str_129 db `coordFromTokenEnd: nil token`, 0
    str_129_len equ $ - str_129
    str_139 db `故障！`, 0
    str_139_len equ $ - str_139
    str_96 db `<`, 0
    str_96_len equ $ - str_96
    str_130 db `Lexer.setPos: nil Coord`, 0
    str_130_len equ $ - str_130
    str_24 db ` allocB=`, 0
    str_24_len equ $ - str_24
    str_49 db `for`, 0
    str_49_len equ $ - str_49
    str_60 db `true`, 0
    str_60_len equ $ - str_60
    str_71 db `&`, 0
    str_71_len equ $ - str_71
    str_84 db `--`, 0
    str_84_len equ $ - str_84
    str_106 db `?`, 0
    str_106_len equ $ - str_106
    str_112 db `^=`, 0
    str_112_len equ $ - str_112
    str_127 db `NAME`, 0
    str_127_len equ $ - str_127
    str_28 db ` end=`, 0
    str_28_len equ $ - str_28
    str_59 db `switch`, 0
    str_59_len equ $ - str_59
    str_68 db `\"`, 0
    str_68_len equ $ - str_68
    str_113 db `\``, 0
    str_113_len equ $ - str_113
    str_124 db `KEYWORD`, 0
    str_124_len equ $ - str_124
    str_138 db `故障`, 0
    str_138_len equ $ - str_138
    str_13 db ` CYCLE?`, 0
    str_13_len equ $ - str_13
    str_15 db ` freeBytes=`, 0
    str_15_len equ $ - str_15
    str_44 db `except`, 0
    str_44_len equ $ - str_44
    str_65 db ` `, 0
    str_65_len equ $ - str_65
    str_104 db `>>`, 0
    str_104_len equ $ - str_104
    str_131 db `_`, 0
    str_131_len equ $ - str_131
    str_17 db ` pure=`, 0
    str_17_len equ $ - str_17
    str_29 db `topFooter raw=`, 0
    str_29_len equ $ - str_29
    str_128 db `size must > 0`, 0
    str_128_len equ $ - str_128
    str_55 db `range`, 0
    str_55_len equ $ - str_55
    str_6 db `=== allocator dump ===\n`, 0
    str_6_len equ $ - str_6
    str_9 db `slot=`, 0
    str_9_len equ $ - str_9
    str_58 db `struct`, 0
    str_58_len equ $ - str_58
    str_83 db `-`, 0
    str_83_len equ $ - str_83
    str_136 db `, Args:`, 0
    str_136_len equ $ - str_136
    str_22 db ` prevPure=`, 0
    str_22_len equ $ - str_22
    str_87 db `.`, 0
    str_87_len equ $ - str_87
    str_26 db ` freeB=`, 0
    str_26_len equ $ - str_26
    str_70 db `%=`, 0
    str_70_len equ $ - str_70
    str_141 db `Arg:`, 0
    str_141_len equ $ - str_141
    str_7 db `brk=`, 0
    str_7_len equ $ - str_7
    str_61 db `try`, 0
    str_61_len equ $ - str_61
    str_76 db `)`, 0
    str_76_len equ $ - str_76

section .text.__gc_drop__Node progbits alloc exec nowrite align=16
__gc_drop__Node:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    test rbx, rbx
    jz __gc_drop__Node_done
    call std_memory_dropInc
    ; drop interface field Value
    mov r12, QWORD [rbx+0]
    mov rax, QWORD [rbx+8]
    mov QWORD [rbx+0], 0
    mov QWORD [rbx+8], 0
    test rax, rax
    jnz __gc_drop__Node_f_Value_has_data
    test r12, r12
    jz __gc_drop__Node_f_Value_end
    mov rdi, r12
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__Node_f_Value_end
    mov rdi, r12
    call std_memory_free
    jmp __gc_drop__Node_f_Value_end
__gc_drop__Node_f_Value_has_data:
    test r12, r12
    jz __gc_drop__Node_f_Value_free_only
    mov rdi, r12
    call std_memory_isTrackedAll
    test rax, rax
    jnz __gc_drop__Node_f_Value_free_only
    mov r12, QWORD [r12]
    test r12, r12
    jz __gc_drop__Node_f_Value_free_only
    mov rdi, rax
    call r12
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__Node_done
    jmp __gc_drop__Node_f_Value_end
__gc_drop__Node_f_Value_free_only:
    mov rdi, rax
    call std_memory_free
__gc_drop__Node_f_Value_end:
    ; drop field Father
    mov r12, QWORD [rbx+16]
    mov QWORD [rbx+16], 0
    test r12, r12
    jz __gc_drop__Node_f_Father_end
    mov rdi, r12
    call __gc_drop__Node
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__Node_done
__gc_drop__Node_f_Father_end:
    ; drop slice field Children
    mov rax, QWORD [rbx+24]
    test rax, rax
    jz __gc_drop__Node_f_Children_end
    push rax
    mov rax, QWORD [rbx+32]
    push rax
    mov QWORD [rbx+24], 0
    mov QWORD [rbx+32], 0
    mov QWORD [rbx+40], 0
__gc_drop__Node_f_Children_loop:
    mov rax, [rsp]
    test rax, rax
    jz __gc_drop__Node_f_Children_loop_end
    dec QWORD [rsp]
    mov rax, [rsp]
    imul rax, 8
    add rax, [rsp+8]
    mov rax, QWORD [rax]
    test rax, rax
    jz __gc_drop__Node_f_Children_loop
    push rdi
    mov rdi, rax
    call __gc_drop__Node
    pop rdi
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__Node_f_Children_self_freed
    jmp __gc_drop__Node_f_Children_loop
__gc_drop__Node_f_Children_self_freed:
    add rsp, 8
    pop rax
    mov rdi, rax
    call std_memory_free
    jmp __gc_drop__Node_done
__gc_drop__Node_f_Children_loop_end:
    add rsp, 8
    pop rax
    mov rdi, rax
    call std_memory_free
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__Node_f_Children_end
    mov QWORD [rbx+24], 0
    mov QWORD [rbx+32], 0
    mov QWORD [rbx+40], 0
__gc_drop__Node_f_Children_end:
    mov rdi, rbx
    call std_memory_free
__gc_drop__Node_done:
    pop r12
    pop rbx
    leave
    ret

section .text.__gc_drop__Token progbits alloc exec nowrite align=16
__gc_drop__Token:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    test rbx, rbx
    jz __gc_drop__Token_done
    call std_memory_dropInc
    ; drop string field Value
    mov r12, QWORD [rbx+24]
    mov QWORD [rbx+24], 0
    mov QWORD [rbx+32], 0
    mov QWORD [rbx+40], 0
    test r12, r12
    jz __gc_drop__Token_f_Value_end
    mov rdi, r12
    call std_memory_free
__gc_drop__Token_f_Value_end:
    mov rdi, rbx
    call std_memory_free
__gc_drop__Token_done:
    pop r12
    pop rbx
    leave
    ret

section .text.__gc_drop__RingBuffer progbits alloc exec nowrite align=16
__gc_drop__RingBuffer:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    test rbx, rbx
    jz __gc_drop__RingBuffer_done
    call std_memory_dropInc
    ; drop slice field buf
    mov rax, QWORD [rbx+0]
    test rax, rax
    jz __gc_drop__RingBuffer_f_buf_end
    push rax
    mov rax, QWORD [rbx+8]
    push rax
    mov QWORD [rbx+0], 0
    mov QWORD [rbx+8], 0
    mov QWORD [rbx+16], 0
__gc_drop__RingBuffer_f_buf_loop:
    mov rax, [rsp]
    test rax, rax
    jz __gc_drop__RingBuffer_f_buf_loop_end
    dec QWORD [rsp]
    mov rax, [rsp]
    imul rax, 8
    add rax, [rsp+8]
    mov rax, QWORD [rax]
    test rax, rax
    jz __gc_drop__RingBuffer_f_buf_loop
    push rdi
    mov rdi, rax
    call __gc_drop__Token
    pop rdi
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__RingBuffer_f_buf_self_freed
    jmp __gc_drop__RingBuffer_f_buf_loop
__gc_drop__RingBuffer_f_buf_self_freed:
    add rsp, 8
    pop rax
    mov rdi, rax
    call std_memory_free
    jmp __gc_drop__RingBuffer_done
__gc_drop__RingBuffer_f_buf_loop_end:
    add rsp, 8
    pop rax
    mov rdi, rax
    call std_memory_free
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__RingBuffer_f_buf_end
    mov QWORD [rbx+0], 0
    mov QWORD [rbx+8], 0
    mov QWORD [rbx+16], 0
__gc_drop__RingBuffer_f_buf_end:
    mov rdi, rbx
    call std_memory_free
__gc_drop__RingBuffer_done:
    pop r12
    pop rbx
    leave
    ret

section .text.__gc_drop__Lexer progbits alloc exec nowrite align=16
__gc_drop__Lexer:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    test rbx, rbx
    jz __gc_drop__Lexer_done
    call std_memory_dropInc
    ; drop string field Text
    mov r12, QWORD [rbx+0]
    mov QWORD [rbx+0], 0
    mov QWORD [rbx+8], 0
    mov QWORD [rbx+16], 0
    test r12, r12
    jz __gc_drop__Lexer_f_Text_end
    mov rdi, r12
    call std_memory_free
__gc_drop__Lexer_f_Text_end:
    ; drop field pfCache
    mov r12, QWORD [rbx+80]
    mov QWORD [rbx+80], 0
    test r12, r12
    jz __gc_drop__Lexer_f_pfCache_end
    mov rdi, r12
    call __gc_drop__RingBuffer
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__Lexer_done
__gc_drop__Lexer_f_pfCache_end:
    mov rdi, rbx
    call std_memory_free
__gc_drop__Lexer_done:
    pop r12
    pop rbx
    leave
    ret

section .text.__gc_drop__Parser progbits alloc exec nowrite align=16
__gc_drop__Parser:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    test rbx, rbx
    jz __gc_drop__Parser_done
    call std_memory_dropInc
    ; drop field Block
    mov r12, QWORD [rbx+0]
    mov QWORD [rbx+0], 0
    test r12, r12
    jz __gc_drop__Parser_f_Block_end
    mov rdi, r12
    call __gc_drop__Node
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__Parser_done
__gc_drop__Parser_f_Block_end:
    ; drop field ThisBlock
    mov r12, QWORD [rbx+8]
    mov QWORD [rbx+8], 0
    test r12, r12
    jz __gc_drop__Parser_f_ThisBlock_end
    mov rdi, r12
    call __gc_drop__Node
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__Parser_done
__gc_drop__Parser_f_ThisBlock_end:
    ; drop field Lexer
    mov r12, QWORD [rbx+16]
    mov QWORD [rbx+16], 0
    test r12, r12
    jz __gc_drop__Parser_f_Lexer_end
    mov rdi, r12
    call __gc_drop__Lexer
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__Parser_done
__gc_drop__Parser_f_Lexer_end:
    mov rdi, rbx
    call std_memory_free
__gc_drop__Parser_done:
    pop r12
    pop rbx
    leave
    ret

section .text.__gc_drop__Expression progbits alloc exec nowrite align=16
__gc_drop__Expression:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    test rbx, rbx
    jz __gc_drop__Expression_done
    call std_memory_dropInc
    ; drop string field op
    mov r12, QWORD [rbx+0]
    mov QWORD [rbx+0], 0
    mov QWORD [rbx+8], 0
    mov QWORD [rbx+16], 0
    test r12, r12
    jz __gc_drop__Expression_f_op_end
    mov rdi, r12
    call std_memory_free
__gc_drop__Expression_f_op_end:
    ; drop string field val
    mov r12, QWORD [rbx+24]
    mov QWORD [rbx+24], 0
    mov QWORD [rbx+32], 0
    mov QWORD [rbx+40], 0
    test r12, r12
    jz __gc_drop__Expression_f_val_end
    mov rdi, r12
    call std_memory_free
__gc_drop__Expression_f_val_end:
    ; drop field right
    mov r12, QWORD [rbx+56]
    mov QWORD [rbx+56], 0
    test r12, r12
    jz __gc_drop__Expression_f_right_end
    mov rdi, r12
    call __gc_drop__Expression
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__Expression_done
__gc_drop__Expression_f_right_end:
    ; drop field left
    mov r12, QWORD [rbx+64]
    mov QWORD [rbx+64], 0
    test r12, r12
    jz __gc_drop__Expression_f_left_end
    mov rdi, r12
    call __gc_drop__Expression
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__Expression_done
__gc_drop__Expression_f_left_end:
    ; drop field father
    mov r12, QWORD [rbx+72]
    mov QWORD [rbx+72], 0
    test r12, r12
    jz __gc_drop__Expression_f_father_end
    mov rdi, r12
    call __gc_drop__Expression
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__Expression_done
__gc_drop__Expression_f_father_end:
    mov rdi, rbx
    call std_memory_free
__gc_drop__Expression_done:
    pop r12
    pop rbx
    leave
    ret

section .text.__gc_drop__Arg progbits alloc exec nowrite align=16
__gc_drop__Arg:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    test rbx, rbx
    jz __gc_drop__Arg_done
    call std_memory_dropInc
    ; drop string field name
    mov r12, QWORD [rbx+0]
    mov QWORD [rbx+0], 0
    mov QWORD [rbx+8], 0
    mov QWORD [rbx+16], 0
    test r12, r12
    jz __gc_drop__Arg_f_name_end
    mov rdi, r12
    call std_memory_free
__gc_drop__Arg_f_name_end:
    ; drop string field typ
    mov r12, QWORD [rbx+24]
    mov QWORD [rbx+24], 0
    mov QWORD [rbx+32], 0
    mov QWORD [rbx+40], 0
    test r12, r12
    jz __gc_drop__Arg_f_typ_end
    mov rdi, r12
    call std_memory_free
__gc_drop__Arg_f_typ_end:
    ; drop field defaultVal
    mov r12, QWORD [rbx+48]
    mov QWORD [rbx+48], 0
    test r12, r12
    jz __gc_drop__Arg_f_defaultVal_end
    mov rdi, r12
    call __gc_drop__Expression
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__Arg_done
__gc_drop__Arg_f_defaultVal_end:
    mov rdi, rbx
    call std_memory_free
__gc_drop__Arg_done:
    pop r12
    pop rbx
    leave
    ret

section .text.__gc_drop__FnBlock progbits alloc exec nowrite align=16
__gc_drop__FnBlock:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    test rbx, rbx
    jz __gc_drop__FnBlock_done
    call std_memory_dropInc
    ; drop string field name
    mov r12, QWORD [rbx+0]
    mov QWORD [rbx+0], 0
    mov QWORD [rbx+8], 0
    mov QWORD [rbx+16], 0
    test r12, r12
    jz __gc_drop__FnBlock_f_name_end
    mov rdi, r12
    call std_memory_free
__gc_drop__FnBlock_f_name_end:
    ; drop slice field args
    mov rax, QWORD [rbx+24]
    test rax, rax
    jz __gc_drop__FnBlock_f_args_end
    push rax
    mov rax, QWORD [rbx+32]
    push rax
    mov QWORD [rbx+24], 0
    mov QWORD [rbx+32], 0
    mov QWORD [rbx+40], 0
__gc_drop__FnBlock_f_args_loop:
    mov rax, [rsp]
    test rax, rax
    jz __gc_drop__FnBlock_f_args_loop_end
    dec QWORD [rsp]
    mov rax, [rsp]
    imul rax, 8
    add rax, [rsp+8]
    mov rax, QWORD [rax]
    test rax, rax
    jz __gc_drop__FnBlock_f_args_loop
    push rdi
    mov rdi, rax
    call __gc_drop__Arg
    pop rdi
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__FnBlock_f_args_self_freed
    jmp __gc_drop__FnBlock_f_args_loop
__gc_drop__FnBlock_f_args_self_freed:
    add rsp, 8
    pop rax
    mov rdi, rax
    call std_memory_free
    jmp __gc_drop__FnBlock_done
__gc_drop__FnBlock_f_args_loop_end:
    add rsp, 8
    pop rax
    mov rdi, rax
    call std_memory_free
    mov rdi, rbx
    call std_memory_isTrackedAll
    test rax, rax
    jz __gc_drop__FnBlock_f_args_end
    mov QWORD [rbx+24], 0
    mov QWORD [rbx+32], 0
    mov QWORD [rbx+40], 0
__gc_drop__FnBlock_f_args_end:
    mov rdi, rbx
    call std_memory_free
__gc_drop__FnBlock_done:
    pop r12
    pop rbx
    leave
    ret
