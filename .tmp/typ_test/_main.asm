section .bss
    __global_std_memory_gFreeHeads resq 1
    __global_std_memory_gLeaks resq 1
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
section .text progbits alloc exec nowrite align=16
global _start

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
    sub rsp, 152; 分配局部变量空间(152字节, 含对齐)
    mov QWORD [rbp-64], 0
    mov QWORD [rbp-64+8], 0
    mov QWORD [rbp-64+16], 0; 空容器
; 设置变量args
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
    mov QWORD [RBX+0], str_1
    mov QWORD [RBX+0+8], 1
    mov QWORD [RBX+0+16], 1
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rbp-72], RBX
; 设置变量a1
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
    mov QWORD [RBX+0], str_2
    mov QWORD [RBX+0+8], 1
    mov QWORD [RBX+0+16], 1
    mov RBX, QWORD [RSP]
    add RSP, 8; drop new obj
    mov QWORD [rbp-80], RBX
; 设置变量a2
    sub rsp, 16; register args buffer
    lea RAX, [rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_slices_push__T__Arg
    sub rsp, 16; register args buffer
    lea RAX, [rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_slices_push__T__Arg


    sub rsp, 16; register args buffer
    lea RBX, [rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_slices_len__T__Arg
    mov RBX, 1
    mov QWORD[rbp-88], RAX
    sub QWORD[rbp-88], RBX
; 设置变量i


    for_1: ; for循环开始
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl for_1_end
    for_1_body:


    mov RAX, QWORD[rbp-88]
    test RAX, RAX
    jge idx_norm_ok_2f93614e9c20
    add RAX, QWORD [rbp-64+8]
    idx_norm_ok_2f93614e9c20:
    test RAX, RAX
    js idx_oob_2f93614e9d10
    cmp QWORD [rbp-64+8], RAX
    jg idx_ok_2f93614e9d10
    idx_oob_2f93614e9d10:
    push RAX
    call _panic_index_oob
    idx_ok_2f93614e9d10:
    mov RBX, QWORD [rbp-64]
    imul RAX, 8
    add RBX, RAX
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-96], RAX
; 设置变量a
    mov RBX, QWORD [RBP-96]
    test RBX, RBX
    je _panic_nil_deref
    mov QWORD QWORD[RBX+24], str_3
    mov QWORD [RBX+24+8], 3
    mov QWORD [RBX+24+16], 3
; 设置变量a.typ
    for_1_continue:


    mov RAX, QWORD[rbp-88]
    mov RBX, 1
    mov QWORD[rbp-88], RAX
    sub QWORD[rbp-88], RBX
; 设置变量i
    jmp for_1; for循环
    for_1_end: ; for循环结束


    mov QWORD[rbp-88], 0
; 设置变量i


    for_2: ; for循环开始
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    sub rsp, 16; register args buffer
    lea RAX, [rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_slices_len__T__Arg
    mov RCX, RAX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_2_end
    for_2_body:


    mov RAX, QWORD[rbp-88]
    test RAX, RAX
    jge idx_norm_ok_2f9361502870
    add RAX, QWORD [rbp-64+8]
    idx_norm_ok_2f9361502870:
    test RAX, RAX
    js idx_oob_2f9361502960
    cmp QWORD [rbp-64+8], RAX
    jg idx_ok_2f9361502960
    idx_oob_2f9361502960:
    push RAX
    call _panic_index_oob
    idx_ok_2f9361502960:
    mov RBX, QWORD [rbp-64]
    imul RAX, 8
    add RBX, RAX
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-112], RAX
; 设置变量a
    sub rsp, 32; register args buffer
    mov RSI, QWORD [RBP-112]
    test RSI, RSI
    je _panic_nil_deref
    mov RCX, QWORD [RSI]
    mov RDX, QWORD [RSI+8]
    push RCX
    push RDX
    mov RCX, str_4
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
    mov QWORD [RBP-144], RAX
    mov QWORD [RBP-144+8], R9
    mov QWORD [RBP-144+16], R12
    mov RBX, QWORD [RBP-144]
    mov RAX, QWORD [RBP-144+8]
    push RBX
    push RAX
    mov RCX, QWORD [RBP-112]
    test RCX, RCX
    je _panic_nil_deref
    mov RAX, QWORD [RCX+24]
    mov RBX, QWORD [RCX+24+8]
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
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_println
    for_2_continue:


    mov RAX, QWORD[rbp-88]
    mov RBX, 1
    mov QWORD[rbp-88], RAX
    add QWORD[rbp-88], RBX
; 设置变量i
    jmp for_2; for循环
    for_2_end: ; for循环结束
    mov RAX, 0
; return值存入RAX
    jmp func_end_main
    func_end_main:
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


section .text.std_syscall_open progbits alloc exec nowrite align=16
global std_syscall_open
; ==============================
; Function: std_syscall_open
std_syscall_open:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov DWORD [rbp-56], ESI; 保存参数1到栈
    mov DWORD [rbp-64], EDX; 保存参数2到栈
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], 2
; 参数0
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov EBX, DWORD[rbp-56]
    mov QWORD [rsp+16], RBX
; 参数2
    mov EBX, DWORD[rbp-64]
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
    jmp func_end_std_syscall_open
    func_end_std_syscall_open:
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
    je end_if_1
    if_1:
    jmp func_end_std_memory_initFreeHeads
    end_if_1:
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
    jnb end_if_2
    if_2:
    jmp func_end_std_memory_initFreeHeads
    end_if_2:
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
    jne end_if_3
    if_3:
    mov RAX, 32
; return值存入RAX
    jmp func_end_std_memory_blkSizeOfTiny
    end_if_3:
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
    jnb end_if_4
    if_4:
    mov QWORD[rbp-72], 16
; 设置变量step
    end_if_4:
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
    jne end_if_5
    if_5:
    mov RAX, 2048
; return值存入RAX
    jmp func_end_std_memory_blkSizeOfSmall
    end_if_5:
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
    jnbe end_if_6
    if_6:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOfTiny
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf
    end_if_6:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 35
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_7
    if_7:
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
    end_if_7:
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
    jnbe end_if_8
    if_8:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_slotOfTiny
    end_if_8:
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
    jnb end_if_9
    if_9:
    mov QWORD[rbp-72], 16
; 设置变量step
    end_if_9:
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
    jb end_if_10
    if_10:
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_slotOfTiny
    end_if_10:
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
    jnbe end_if_11
    if_11:
    mov RAX, 34
; return值存入RAX
    jmp func_end_std_memory_slotOfSmall
    end_if_11:
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
    jnbe end_if_12
    if_12:
    mov RAX, 36
; return值存入RAX
    jmp func_end_std_memory_slotOfMiddle
    end_if_12:
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
    jb end_if_13
    if_13:
    mov RBX, QWORD[rbp-64]
    mov RAX, 36
    add RAX, RBX
    mov RBX, 1
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_slotOfMiddle
    end_if_13:
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
    jnbe end_if_14
    if_14:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfTiny
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_14:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_SMALL_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_15
    if_15:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfSmall
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_15:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_16
    if_16:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfMiddle
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_16:
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
    jb end_if_17
    if_17:
    mov RAX, 60
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_17:




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
    jnbe end_if_18
    if_18:
    mov RAX, QWORD[rbp-56]
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_18:
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
    jbe end_if_19
    if_19:
    mov RAX, 60
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_19:
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
    jb end_if_20
    if_20:
    jmp func_end_std_memory_insertFreeList
    end_if_20:
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
    je end_if_21
    if_21:
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
    end_if_21:
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
    jb end_if_22
    if_22:
    jmp func_end_std_memory_removeFreeList
    end_if_22:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je else_if_23
    if_23:
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
    jmp end_if_23
    else_if_23:
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
    end_if_23:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_24
    if_24:
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
    end_if_24:
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
    sub rsp, 168; 分配局部变量空间(168字节, 含对齐)
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
    jnb end_if_25
    if_25:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_commit
    end_if_25:
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-80], RAX
; 设置变量head
    mov QWORD[rbp-88], 0
; 设置变量prev
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-96], RAX
; 设置变量p
    mov RBX, QWORD[rbp-64]
    mov RAX, QWORD[rel __global_std_memory_CHUNK_SIZE]
    mov QWORD[rbp-104], RBX
    add QWORD[rbp-104], RAX
; 设置变量end




    for_8: ; for循环开始
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-56]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe for_8_end
    for_8_body:


    mov RBX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD[rbp-112], RBX
; 设置变量flags
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_26
    if_26:
    mov RBX, QWORD[rbp-112]
    mov RDX, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD[rbp-112], RBX
    or QWORD[rbp-112], RDX
; 设置变量flags
    end_if_26:
    mov RBX, QWORD[rbp-56]
    mov RDX, QWORD[rbp-112]
    mov QWORD[rbp-120], RBX
    or QWORD[rbp-120], RDX
; 设置变量full
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-96]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-120]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-96]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-120]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-96]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeSetNext
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-96]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-88]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeSetPrev
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_27
    if_27:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-88]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-96]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeSetNext
    end_if_27:
    mov RBX, QWORD[rbp-96]
    mov QWORD[rbp-88], RBX
; 设置变量prev
    mov RDX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-96], RDX
    add QWORD[rbp-96], RBX
; 设置变量p
    for_8_continue:


    jmp for_8; for循环
    for_8_end: ; for循环结束
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-80]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_setHead
    mov RAX, QWORD[rbp-64]
; return值存入RAX
    jmp func_end_std_memory_commit
    func_end_std_memory_commit:
    add rsp, 168; 清理局部变量 + 对齐
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
    jnbe end_if_28
    if_28:
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
    je end_if_29
    and_mid_1:
    mov RAX, QWORD[rbp-88]
    mov RCX, QWORD[rel __global_std_memory_IS_FREE]
    and RAX, RCX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_29
    if_29:
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
    end_if_29:
    end_if_28:
    mov RAX, QWORD[rbp-56]
    mov RDX, QWORD[rel __global_std_memory_PREV_FREE]
    and RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je else_if_30
    if_30:
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
    jmp end_if_30
    else_if_30:
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
    end_if_30:
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
    jnbe end_if_31
    if_31:
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
    je end_if_32
    if_32:
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
    end_if_32:
    end_if_31:
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
    sub rsp, 328; 分配局部变量空间(328字节, 含对齐)
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
    jnb end_if_33
    if_33:
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-56], RAX
; 设置变量req
    end_if_33:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_LARGE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_34
    if_34:
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
    jnb end_if_35
    if_35:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_35:
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
    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_34:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_36
    if_36:
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
    mov QWORD[rbp-96], RBX
    and QWORD[rbp-96], RAX
; 设置变量aligned
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-104], RAX
; 设置变量old
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-104]
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RBX
    add QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-112], RAX
; 设置变量nb
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
    mov RAX, QWORD[rbp-96]
    add RCX, RAX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_37
    if_37:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_37:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RBX, QWORD[rbp-96]
    mov RAX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RBX
    or QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RBX, QWORD[rbp-96]
    mov RAX, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RBX
    or QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_coalesce
    mov QWORD[rbp-120], RAX
; 设置变量merged
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-128], RAX
; 设置变量mRaw
    mov RBX, QWORD[rbp-128]
    mov RDX, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RAX, RDX
    not RAX
    mov QWORD[rbp-136], RBX
    and QWORD[rbp-136], RAX
; 设置变量mPure
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-136]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-136]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    mov RBX, QWORD[rbp-120]
    mov RDX, QWORD[rbp-136]
    mov QWORD[rbp-144], RBX
    add QWORD[rbp-144], RDX
; 设置变量nextM
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-152], RAX
; 设置变量brkTop
    mov RAX, QWORD[rbp-144]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-152]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_38
    if_38:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-144]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-160], RAX
; 设置变量ns
    mov RAX, QWORD[rbp-160]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_39
    if_39:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-144]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-160]
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
    mov RBX, QWORD[rbp-144]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-160]
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
    end_if_39:
    end_if_38:
    mov RAX, QWORD[rbp-120]
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RDX
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_36:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOf
    mov QWORD[rbp-168], RAX
; 设置变量cls
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-168]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOf
    mov QWORD[rbp-176], RAX
; 设置变量blkSize
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-168]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_headOf
    mov QWORD[rbp-184], RAX
; 设置变量head
    mov RAX, QWORD[rbp-184]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_40
    if_40:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-168]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-176]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_commit
    mov QWORD[rbp-184], RAX
; 设置变量head
    mov RAX, QWORD[rbp-184]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_41
    if_41:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_41:
    end_if_40:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-184]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeNext
    mov QWORD[rbp-192], RAX
; 设置变量next
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-168]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-192]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_setHead
    mov RAX, QWORD[rbp-192]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_42
    if_42:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-192]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeSetPrev
    end_if_42:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-184]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov RDX, RAX
    mov RSI, QWORD[rel __global_std_memory_FLAG_MASK]
    mov RBX, RSI
    not RBX
    mov QWORD[rbp-200], RDX
    and QWORD[rbp-200], RBX
; 设置变量rawSize
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, 4
    mov QWORD[rbp-208], RDX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存乘数
    mov RAX, QWORD[rbp-208]
    imul RAX, qword [rsp]
    mov QWORD[rbp-208], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量minBlk
    mov RAX, QWORD[rbp-208]
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
    jnb end_if_43
    if_43:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOf
    mov QWORD[rbp-208], RAX
; 设置变量minBlk
    end_if_43:
    mov RAX, QWORD[rbp-200]
    mov QWORD[rbp-216], RAX
; 设置变量useSize
    mov QWORD[rbp-224], 0
; 设置变量rem
    mov RAX, QWORD[rbp-200]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-176]
    mov RDX, QWORD[rbp-208]
    add RCX, RDX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_44
    if_44:
    mov RAX, QWORD[rbp-176]
    mov QWORD[rbp-216], RAX
; 设置变量useSize
    mov RDX, QWORD[rbp-200]
    mov RSI, QWORD[rbp-176]
    mov QWORD[rbp-224], RDX
    sub QWORD[rbp-224], RSI
; 设置变量rem
    jmp end_if_44
    else_if_44:
    mov RAX, QWORD[rbp-200]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-176]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_45
    if_45:
    mov RAX, QWORD[rbp-176]
    mov QWORD[rbp-216], RAX
; 设置变量useSize
    end_if_45:
    end_if_44:
    mov RAX, QWORD[rbp-224]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-208]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_46
    if_46:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-184]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-216]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-184]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-216]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    mov RDX, QWORD[rbp-184]
    mov RSI, QWORD[rbp-216]
    mov QWORD[rbp-232], RDX
    add QWORD[rbp-232], RSI
; 设置变量remBlk
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-232]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDX, QWORD[rbp-224]
    mov RSI, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RSI
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-232]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDX, QWORD[rbp-224]
    mov RSI, QWORD[rel __global_std_memory_IS_FREE]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RSI
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-232]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_insertFreeList
    mov RDX, QWORD[rbp-232]
    mov RSI, QWORD[rbp-224]
    mov QWORD[rbp-240], RDX
    add QWORD[rbp-240], RSI
; 设置变量afterRem
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-248], RAX
; 设置变量brkRem
    mov RAX, QWORD[rbp-240]
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-248]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_47
    if_47:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-240]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-256], RAX
; 设置变量nsr
    mov RAX, QWORD[rbp-256]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_48
    if_48:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-240]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-256]
    mov RSI, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RSI
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-240]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-256]
    mov RSI, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD [rsp+8], RDX
    or QWORD [rsp+8], RSI
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    end_if_48:
    end_if_47:
    jmp end_if_46
    else_if_46:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-184]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-216]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetSizeRaw
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-184]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-216]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSetFooter
    end_if_46:
    mov RDX, QWORD[rbp-184]
    mov RSI, QWORD[rbp-216]
    mov QWORD[rbp-264], RDX
    add QWORD[rbp-264], RSI
; 设置变量nextBlk
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_brk
    mov QWORD[rbp-272], RAX
; 设置变量brkTop
    mov RAX, QWORD[rbp-264]
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-272]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_49
    if_49:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-264]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_hdrSizeRaw
    mov QWORD[rbp-280], RAX
; 设置变量ns
    mov RAX, QWORD[rbp-280]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_50
    if_50:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-264]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-280]
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
    mov RBX, QWORD[rbp-264]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDX, QWORD[rbp-280]
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
    end_if_50:
    end_if_49:
    mov RAX, QWORD[rbp-184]
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RDX
; return值存入RAX
    jmp func_end_std_memory_malloc
    func_end_std_memory_malloc:
    add rsp, 328; 清理局部变量 + 对齐
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
    jbe end_if_51
    if_51:
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
    jne end_if_52
    if_52:
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
    end_if_52:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_freeAt
    end_if_51:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_53
    if_53:
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
    jne end_if_54
    if_54:
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
    end_if_54:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_freeAt
    end_if_53:
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
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_55
    if_55:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_free
    end_if_55:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
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
    je end_if_56
    if_56:
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
    end_if_56:
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov QWORD[rbp-64], RAX
    sub QWORD[rbp-64], RBX
; 设置变量base
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeAt
; return值存入RAX
    jmp func_end_std_memory_free
    func_end_std_memory_free:
    add rsp, 104; 清理局部变量 + 对齐
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
    jne end_if_57
    if_57:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeSlot
    end_if_57:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
; condition
    test RAX, RAX
    jz end_if_58
    if_58:
    mov RAX, 0
    mov RBX, QWORD[rbp-48]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeSlot
    end_if_58:
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
    jne end_if_59
    if_59:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_59:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_60
    if_60:
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
    end_if_60:
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
    jnbe end_if_61
    if_61:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_61:
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
    jnbe end_if_62
    if_62:
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
    je end_if_63
    and_mid_2:
    mov RAX, QWORD[rbp-104]
    mov RCX, QWORD[rel __global_std_memory_IS_FREE]
    and RAX, RCX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_63
    if_63:
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
    jb end_if_64
    if_64:
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
    jnbe end_if_65
    if_65:
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
    je end_if_66
    if_66:
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
    end_if_66:
    end_if_65:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_64:
    end_if_63:
    end_if_62:
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
    jne end_if_67
    if_67:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_67:
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
    jbe end_if_68
    if_68:
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-144], RAX
; 设置变量copySize
    end_if_68:
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




    for_9: ; for循环开始
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_9_end
    for_9_body:


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
    for_9_continue:


    jmp for_9; for循环
    for_9_end: ; for循环结束
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, QWORD[rbp-72]
    imul RAX, RBX
    mov RBX, QWORD[rbp-64]
    mov QWORD[rbp-104], RBX
    sub QWORD[rbp-104], RAX
; 设置变量rem
    mov QWORD[rbp-112], 0
; 设置变量j




    for_10: ; for循环开始
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_10_end
    for_10_body:


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
    for_10_continue:


    jmp for_10; for循环
    for_10_end: ; for循环结束
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


section .text.std_memory_memset progbits alloc exec nowrite align=16
global std_memory_memset
; ==============================
; Function: std_memory_memset
std_memory_memset:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 168; 分配局部变量空间(168字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov BYTE [rbp-56], SIL; 保存参数1到栈
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    movzx RAX, BYTE[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_69
    if_69:
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




    for_11: ; for循环开始
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_11_end
    for_11_body:


    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, QWORD[rbp-80]
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-88], RBX
    add QWORD[rbp-88], RAX
; 设置变量p
    mov RBX, 0
    mov RAX, QWORD[rbp-88]
    mov QWORD [RAX], RBX
; expression statement
    mov RBX, QWORD[rbp-80]
    mov RAX, 1
    mov QWORD[rbp-80], RBX
    add QWORD[rbp-80], RAX
; 设置变量i
    for_11_continue:


    jmp for_11; for循环
    for_11_end: ; for循环结束
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, QWORD[rbp-72]
    imul RAX, RBX
    mov RBX, QWORD[rbp-64]
    mov QWORD[rbp-96], RBX
    sub QWORD[rbp-96], RAX
; 设置变量rem
    mov QWORD[rbp-104], 0
; 设置变量j




    for_12: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_12_end
    for_12_body:


    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RCX, QWORD[rbp-72]
    imul RAX, RCX
    mov RBX, QWORD[rbp-48]
    add RBX, RAX
    mov RCX, QWORD[rbp-104]
    mov QWORD[rbp-112], RBX
    add QWORD[rbp-112], RCX
; 设置变量bp
    movzx RBX, BYTE[rbp-56]
    mov RAX, QWORD[rbp-112]
    mov BYTE [RAX], bl
; expression statement
    mov RAX, QWORD[rbp-104]
    mov RCX, 1
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RCX
; 设置变量j
    for_12_continue:


    jmp for_12; for循环
    for_12_end: ; for循环结束
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_memset
    end_if_69:
    mov QWORD[rbp-120], 0
; 设置变量b




    for_13: ; for循环开始
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-64]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_13_end
    for_13_body:


    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-120]
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量bp2
    movzx RAX, BYTE[rbp-56]
    mov RBX, QWORD[rbp-128]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-120]
    mov RCX, 1
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RCX
; 设置变量b
    for_13_continue:


    jmp for_13; for循环
    for_13_end: ; for循环结束
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_memset
    func_end_std_memory_memset:
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
    jnb end_if_70
    if_70:
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-64], RAX
; 设置变量req
    end_if_70:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_LARGE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_71
    if_71:
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
    jnb end_if_72
    if_72:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_72:
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
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackAlloc
    mov RAX, QWORD[rbp-96]
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_71:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_73
    if_73:
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
    jnb end_if_74
    if_74:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_74:
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
    jnbe end_if_75
    if_75:
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
    je end_if_76
    if_76:
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
    end_if_76:
    end_if_75:
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
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackAlloc
    mov RAX, QWORD[rbp-184]
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_73:
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
    jne end_if_77
    if_77:
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
    jne end_if_78
    if_78:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_78:
    end_if_77:
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
    je end_if_79
    if_79:
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
    end_if_79:
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
    jnbe end_if_80
    if_80:
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
    je end_if_81
    if_81:
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
    end_if_81:
    end_if_80:
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
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_trackAlloc
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
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_82
    if_82:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeRC
    end_if_82:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RCX, 3
    imul RBX, RCX
    mov RCX, QWORD[rbp-48]
    mov QWORD [rsp+0], RCX
    sub QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeAt
; return值存入RAX
    jmp func_end_std_memory_freeRC
    func_end_std_memory_freeRC:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_freeRCSlot progbits alloc exec nowrite align=16
global std_memory_freeRCSlot
; ==============================
; Function: std_memory_freeRCSlot
std_memory_freeRCSlot:
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
    jne end_if_83
    if_83:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeRCSlot
    end_if_83:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeRC
; condition
    test RAX, RAX
    jz end_if_84
    if_84:
    mov RAX, 0
    mov RBX, QWORD[rbp-48]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeRCSlot
    end_if_84:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_freeRCSlot
    func_end_std_memory_freeRCSlot:
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
    jne end_if_85
    if_85:
    jmp func_end_std_memory_rcInc
    end_if_85:
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
    jne end_if_86
    if_86:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcDec
    end_if_86:
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
    jne end_if_87
    if_87:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcDec
    end_if_87:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_88
    if_88:
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
    end_if_88:
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


section .text.std_memory_rcGet progbits alloc exec nowrite align=16
global std_memory_rcGet
; ==============================
; Function: std_memory_rcGet
std_memory_rcGet:
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
    jne end_if_89
    if_89:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_rcGet
    end_if_89:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcLoad
; return值存入RAX
    jmp func_end_std_memory_rcGet
    func_end_std_memory_rcGet:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_rcTryRelease progbits alloc exec nowrite align=16
global std_memory_rcTryRelease
; ==============================
; Function: std_memory_rcTryRelease
std_memory_rcTryRelease:
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
    jne end_if_90
    if_90:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcTryRelease
    end_if_90:
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
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_91
    if_91:
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
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcTryRelease
    end_if_91:
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
    jmp func_end_std_memory_rcTryRelease
    func_end_std_memory_rcTryRelease:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_rcIsOne progbits alloc exec nowrite align=16
global std_memory_rcIsOne
; ==============================
; Function: std_memory_rcIsOne
std_memory_rcIsOne:
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
    jne end_if_92
    if_92:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_rcIsOne
    end_if_92:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcLoad
    mov RBX, 1
    cmp RAX, RBX
    sete al
    movzx RAX, al
; return值存入RAX
    jmp func_end_std_memory_rcIsOne
    func_end_std_memory_rcIsOne:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_rcSet progbits alloc exec nowrite align=16
global std_memory_rcSet
; ==============================
; Function: std_memory_rcSet
std_memory_rcSet:
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
    jne end_if_93
    if_93:
    jmp func_end_std_memory_rcSet
    end_if_93:
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
    call std_memory_rcStore
    func_end_std_memory_rcSet:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_rcAdd progbits alloc exec nowrite align=16
global std_memory_rcAdd
; ==============================
; Function: std_memory_rcAdd
std_memory_rcAdd:
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
    jne end_if_94
    if_94:
    jmp func_end_std_memory_rcAdd
    end_if_94:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcLoad
    mov QWORD[rbp-64], RAX
; 设置变量rc
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
    add QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcStore
    func_end_std_memory_rcAdd:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_rcSub progbits alloc exec nowrite align=16
global std_memory_rcSub
; ==============================
; Function: std_memory_rcSub
std_memory_rcSub:
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
    jne end_if_95
    if_95:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcSub
    end_if_95:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcLoad
    mov QWORD[rbp-64], RAX
; 设置变量rc
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_96
    if_96:
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
    jmp func_end_std_memory_rcSub
    end_if_96:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
    sub QWORD [rsp+8], RBX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_rcStore
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_rcSub
    func_end_std_memory_rcSub:
    add rsp, 104; 清理局部变量 + 对齐
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
    je end_if_97
    if_97:
    jmp func_end_std_memory_initLeakTracker
    end_if_97:
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
    mov RBX, 2048
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
    mov RBX, 2048
    add RCX, RBX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_98
    if_98:
    jmp func_end_std_memory_initLeakTracker
    end_if_98:
    mov RAX, QWORD[rbp-48]
    mov QWORD[rel __global_std_memory_gLeaks], RAX
; 设置变量gLeaks
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
    mov RAX, QWORD[rbp-48]
    mov RBX, 8
    imul RAX, RBX
    mov RBX, QWORD[rel __global_std_memory_gLeaks]
    mov QWORD[rbp-56], RBX
    add QWORD[rbp-56], RAX
; 设置变量_p
    mov RBX, QWORD[rbp-56]
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
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-48]
    mov RBX, 8
    imul RAX, RBX
    mov RBX, QWORD[rel __global_std_memory_gLeaks]
    mov QWORD[rbp-64], RBX
    add QWORD[rbp-64], RAX
; 设置变量_p
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD[rbp-64]
    mov QWORD [RAX], RBX
; expression statement
    func_end_std_memory_leakStore:
    add rsp, 104; 清理局部变量 + 对齐
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
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_99
    if_99:
    jmp func_end_std_memory_trackAlloc
    end_if_99:
    call std_memory_initLeakTracker
    mov RAX, QWORD[rel __global_std_memory_gAllocCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gAllocCount], RAX
    add QWORD[rel __global_std_memory_gAllocCount], RBX
; 设置变量gAllocCount
    mov RAX, QWORD[rel __global_std_memory_gLeakCount]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 256
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_100
    if_100:
    mov RAX, QWORD[rel __global_std_memory_gLeakCount]
    mov QWORD[rbp-56], RAX
; 设置变量cntV
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_leakStore
    mov RAX, QWORD[rel __global_std_memory_gLeakCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gLeakCount], RAX
    add QWORD[rel __global_std_memory_gLeakCount], RBX
; 设置变量gLeakCount
    end_if_100:
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
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_101
    if_101:
    jmp func_end_std_memory_trackFree
    end_if_101:
    call std_memory_initLeakTracker
    mov RAX, QWORD[rel __global_std_memory_gFreeCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gFreeCount], RAX
    add QWORD[rel __global_std_memory_gFreeCount], RBX
; 设置变量gFreeCount
    mov QWORD[rbp-56], 0
; 设置变量i




    for_14: ; for循环开始
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_gLeakCount]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_14_end
    for_14_body:


    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_leakLoad
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_102
    if_102:
    mov RAX, QWORD[rel __global_std_memory_gLeakCount]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    sub QWORD[rbp-64], RBX
; 设置变量lastIdx
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_leakLoad
    mov QWORD[rbp-72], RAX
; 设置变量tmp
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_leakStore
    mov RAX, QWORD[rel __global_std_memory_gLeakCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gLeakCount], RAX
    sub QWORD[rel __global_std_memory_gLeakCount], RBX
; 设置变量gLeakCount
    jmp func_end_std_memory_trackFree
    end_if_102:
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD[rbp-56], RAX
    add QWORD[rbp-56], RBX
; 设置变量i
    for_14_continue:


    jmp for_14; for循环
    for_14_end: ; for循环结束
    func_end_std_memory_trackFree:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_reportLeaks progbits alloc exec nowrite align=16
global std_memory_reportLeaks
; ==============================
; Function: std_memory_reportLeaks
std_memory_reportLeaks:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov RAX, QWORD[rel __global_std_memory_gLeakCount]
; return值存入RAX
    jmp func_end_std_memory_reportLeaks
    func_end_std_memory_reportLeaks:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_reportAllocCount progbits alloc exec nowrite align=16
global std_memory_reportAllocCount
; ==============================
; Function: std_memory_reportAllocCount
std_memory_reportAllocCount:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov RAX, QWORD[rel __global_std_memory_gAllocCount]
; return值存入RAX
    jmp func_end_std_memory_reportAllocCount
    func_end_std_memory_reportAllocCount:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_reportFreeCount progbits alloc exec nowrite align=16
global std_memory_reportFreeCount
; ==============================
; Function: std_memory_reportFreeCount
std_memory_reportFreeCount:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov RAX, QWORD[rel __global_std_memory_gFreeCount]
; return值存入RAX
    jmp func_end_std_memory_reportFreeCount
    func_end_std_memory_reportFreeCount:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_memory_resetLeakTracker progbits alloc exec nowrite align=16
global std_memory_resetLeakTracker
; ==============================
; Function: std_memory_resetLeakTracker
std_memory_resetLeakTracker:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD[rbp-48], 0
; 设置变量zeroU
    mov RAX, QWORD[rbp-48]
    mov QWORD[rel __global_std_memory_gAllocCount], RAX
; 设置变量gAllocCount
    mov RAX, QWORD[rbp-48]
    mov QWORD[rel __global_std_memory_gFreeCount], RAX
; 设置变量gFreeCount
    mov RAX, QWORD[rbp-48]
    mov QWORD[rel __global_std_memory_gLeakCount], RAX
; 设置变量gLeakCount
    func_end_std_memory_resetLeakTracker:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_count progbits alloc exec nowrite align=16
global std_strings_count
; ==============================
; Function: std_strings_count
std_strings_count:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 184; 分配局部变量空间(184字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
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
    mov QWORD[rbp-96], RAX
; 设置变量sLen
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
    mov QWORD[rbp-104], RAX
; 设置变量tLen
    call std_strings_notFound
    mov QWORD[rbp-112], RAX
; 设置变量nf
    mov QWORD[rbp-120], 0
; 设置变量cnt
    mov QWORD[rbp-128], 0
; 设置变量scanPos
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_103
    if_103:
    mov RAX, QWORD[rbp-96]
    mov RBX, 1
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_strings_count
    end_if_103:




    for_15: ; for循环开始


    sub rsp, 8; align stack for stack args
    push QWORD[rbp-128]
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
    mov QWORD[rbp-136], RAX
; 设置变量idx
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-112]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_104
    if_104:
    jmp for_15_end
    end_if_104:
    mov RAX, QWORD[rbp-120]
    mov RBX, 1
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量cnt
    mov RAX, QWORD[rbp-136]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量scanPos
    for_15_continue:


    jmp for_15; for循环
    for_15_end: ; for循环结束
    mov RAX, QWORD[rbp-120]
; return值存入RAX
    jmp func_end_std_strings_count
    func_end_std_strings_count:
    add rsp, 184; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_isSpace progbits alloc exec nowrite align=16
global std_strings_isSpace
; ==============================
; Function: std_strings_isSpace
std_strings_isSpace:
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
    mov RCX, 32
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_105
    if_105:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_isSpace
    end_if_105:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 9
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_106
    if_106:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_isSpace
    end_if_106:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 10
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_107
    if_107:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_isSpace
    end_if_107:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 13
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_108
    if_108:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_isSpace
    end_if_108:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_isSpace
    func_end_std_strings_isSpace:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_trimLeft progbits alloc exec nowrite align=16
global std_strings_trimLeft
; ==============================
; Function: std_strings_trimLeft
std_strings_trimLeft:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 280; 分配局部变量空间(280字节, 含对齐)
    mov QWORD [rbp-248], R10; 保存返回槽地址
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-96], RAX
; 设置变量sPtr
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
; 设置变量sLen
    mov RAX, QWORD [rbp-88]
    mov QWORD [rbp-112], RAX
; 设置变量cPtr
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
; 设置变量cLen
    mov QWORD[rbp-128], 0
; 设置变量i




    for_16: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_16_end
    for_16_body:


    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-128]
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量_p1
    mov RAX, QWORD[rbp-136]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-144], RAX
; 设置变量ch
    mov BYTE[rbp-145], 0
; 设置变量found
    mov QWORD[rbp-153], 0
; 设置变量j




    for_17: ; for循环开始
    mov RAX, QWORD[rbp-153]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_17_end
    for_17_body:


    mov RAX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-153]
    mov QWORD[rbp-161], RAX
    add QWORD[rbp-161], RBX
; 设置变量_p2
    mov RAX, QWORD[rbp-161]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-169], RAX
; 设置变量cj
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-169]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_109
    if_109:
    mov BYTE[rbp-145], 1
; 设置变量found
    jmp for_17_end
    end_if_109:
    mov RAX, QWORD[rbp-153]
    mov RBX, 1
    mov QWORD[rbp-153], RAX
    add QWORD[rbp-153], RBX
; 设置变量j
    for_17_continue:


    jmp for_17; for循环
    for_17_end: ; for循环结束
    movzx RAX, BYTE[rbp-145]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_110
    if_110:
    jmp for_16_end
    end_if_110:
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量i
    for_16_continue:


    jmp for_16; for循环
    for_16_end: ; for循环结束
    mov RAX, QWORD[rbp-104]
    mov RBX, QWORD[rbp-128]
    mov QWORD[rbp-177], RAX
    sub QWORD[rbp-177], RBX
; 设置变量newLen
    mov RAX, QWORD[rbp-177]
    mov RBX, 1
    mov QWORD[rbp-185], RAX
    add QWORD[rbp-185], RBX
; 设置变量bufN
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-185]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-193], RAX
; 设置变量buf
    mov QWORD[rbp-201], 0
; 设置变量k




    for_18: ; for循环开始
    mov RAX, QWORD[rbp-201]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-177]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_18_end
    for_18_body:


    mov RAX, QWORD[rbp-193]
    mov RBX, QWORD[rbp-201]
    mov QWORD[rbp-209], RAX
    add QWORD[rbp-209], RBX
; 设置变量_p3
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-128]
    add RAX, RBX
    mov RBX, QWORD[rbp-201]
    mov QWORD[rbp-217], RAX
    add QWORD[rbp-217], RBX
; 设置变量_p4
    mov RAX, QWORD[rbp-217]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-225], RAX
; 设置变量_pc_p4
    mov RAX, QWORD[rbp-225]
    mov RBX, QWORD[rbp-209]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-201]
    mov RBX, 1
    mov QWORD[rbp-201], RAX
    add QWORD[rbp-201], RBX
; 设置变量k
    for_18_continue:


    jmp for_18; for循环
    for_18_end: ; for循环结束
    mov RAX, QWORD[rbp-193]
    mov RBX, QWORD[rbp-177]
    mov QWORD[rbp-233], RAX
    add QWORD[rbp-233], RBX
; 设置变量_p5
    mov RAX, 0
    mov RBX, QWORD[rbp-233]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-193]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-177]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-177]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-272]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-272]
    mov QWORD [rbp-272+0], RAX
    mov RAX, QWORD [RBP-272+8]
    mov QWORD [rbp-272+8], RAX
    mov RAX, QWORD [RBP-272+16]
    mov QWORD [rbp-272+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-248]; 恢复返回槽地址
    mov RAX, QWORD [rbp-272]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-264]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-256]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_trimLeft
    func_end_std_strings_trimLeft:
    add rsp, 280; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_trimRight progbits alloc exec nowrite align=16
global std_strings_trimRight
; ==============================
; Function: std_strings_trimRight
std_strings_trimRight:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 280; 分配局部变量空间(280字节, 含对齐)
    mov QWORD [rbp-248], R10; 保存返回槽地址
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-96], RAX
; 设置变量sPtr
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
; 设置变量sLen
    mov RAX, QWORD [rbp-88]
    mov QWORD [rbp-112], RAX
; 设置变量cPtr
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
; 设置变量cLen
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-128], RAX
; 设置变量end




    for_19: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_19_end
    for_19_body:


    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-128]
    add RAX, RBX
    mov RBX, 1
    mov QWORD[rbp-136], RAX
    sub QWORD[rbp-136], RBX
; 设置变量_p6
    mov RAX, QWORD[rbp-136]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-144], RAX
; 设置变量ch
    mov BYTE[rbp-145], 0
; 设置变量found
    mov QWORD[rbp-153], 0
; 设置变量j




    for_20: ; for循环开始
    mov RAX, QWORD[rbp-153]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_20_end
    for_20_body:


    mov RAX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-153]
    mov QWORD[rbp-161], RAX
    add QWORD[rbp-161], RBX
; 设置变量_p7
    mov RAX, QWORD[rbp-161]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-169], RAX
; 设置变量cj
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-169]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_111
    if_111:
    mov BYTE[rbp-145], 1
; 设置变量found
    jmp for_20_end
    end_if_111:
    mov RAX, QWORD[rbp-153]
    mov RBX, 1
    mov QWORD[rbp-153], RAX
    add QWORD[rbp-153], RBX
; 设置变量j
    for_20_continue:


    jmp for_20; for循环
    for_20_end: ; for循环结束
    movzx RAX, BYTE[rbp-145]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_112
    if_112:
    jmp for_19_end
    end_if_112:
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    sub QWORD[rbp-128], RBX
; 设置变量end
    for_19_continue:


    jmp for_19; for循环
    for_19_end: ; for循环结束
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-177], RAX
    add QWORD[rbp-177], RBX
; 设置变量bufN
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-177]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-185], RAX
; 设置变量buf
    mov QWORD[rbp-193], 0
; 设置变量k




    for_21: ; for循环开始
    mov RAX, QWORD[rbp-193]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-128]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_21_end
    for_21_body:


    mov RAX, QWORD[rbp-185]
    mov RBX, QWORD[rbp-193]
    mov QWORD[rbp-201], RAX
    add QWORD[rbp-201], RBX
; 设置变量_p8
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-193]
    mov QWORD[rbp-209], RAX
    add QWORD[rbp-209], RBX
; 设置变量_p9
    mov RAX, QWORD[rbp-209]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-217], RAX
; 设置变量_pc_p9
    mov RAX, QWORD[rbp-217]
    mov RBX, QWORD[rbp-201]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-193]
    mov RBX, 1
    mov QWORD[rbp-193], RAX
    add QWORD[rbp-193], RBX
; 设置变量k
    for_21_continue:


    jmp for_21; for循环
    for_21_end: ; for循环结束
    mov RAX, QWORD[rbp-185]
    mov RBX, QWORD[rbp-128]
    mov QWORD[rbp-225], RAX
    add QWORD[rbp-225], RBX
; 设置变量_p10
    mov RAX, 0
    mov RBX, QWORD[rbp-225]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-185]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-128]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-128]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-272]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-272]
    mov QWORD [rbp-272+0], RAX
    mov RAX, QWORD [RBP-272+8]
    mov QWORD [rbp-272+8], RAX
    mov RAX, QWORD [RBP-272+16]
    mov QWORD [rbp-272+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-248]; 恢复返回槽地址
    mov RAX, QWORD [rbp-272]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-264]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-256]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_trimRight
    func_end_std_strings_trimRight:
    add rsp, 280; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_indexByte progbits alloc exec nowrite align=16
global std_strings_indexByte
; ==============================
; Function: std_strings_indexByte
std_strings_indexByte:
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
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-80], RAX
; 设置变量sPtr
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
    mov QWORD[rbp-88], RAX
; 设置变量sLen
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-96], RAX
; 设置变量byteVal
    mov QWORD[rbp-104], 0
; 设置变量i




    for_22: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_22_end
    for_22_body:


    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-112], RAX
    add QWORD[rbp-112], RBX
; 设置变量_p13
    mov RAX, QWORD[rbp-112]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-120], RAX
; 设置变量mv
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_113
    if_113:
    mov RAX, QWORD[rbp-104]
; return值存入RAX
    jmp func_end_std_strings_indexByte
    end_if_113:
    mov RAX, QWORD[rbp-104]
    mov RBX, 1
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量i
    for_22_continue:


    jmp for_22; for循环
    for_22_end: ; for循环结束
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_indexByte
    func_end_std_strings_indexByte:
    add rsp, 168; 清理局部变量 + 对齐
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
    jnb end_if_114
    if_114:
    mov RAX, QWORD[rbp-120]
    mov QWORD[rbp-128], RAX
; 设置变量minLen
    end_if_114:
    mov QWORD[rbp-136], 0
; 设置变量i




    for_23: ; for循环开始
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-128]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_23_end
    for_23_body:


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
    jnb end_if_115
    if_115:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_115:
    mov RAX, QWORD[rbp-152]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-168]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_116
    if_116:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_116:
    mov RAX, QWORD[rbp-136]
    mov RBX, 1
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量i
    for_23_continue:


    jmp for_23; for循环
    for_23_end: ; for循环结束
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_117
    if_117:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_117:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_118
    if_118:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_118:
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


section .text.std_strings_bufNew progbits alloc exec nowrite align=16
global std_strings_bufNew
; ==============================
; Function: std_strings_bufNew
std_strings_bufNew:
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
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
; return值存入RAX
    jmp func_end_std_strings_bufNew
    func_end_std_strings_bufNew:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_bufSetByte progbits alloc exec nowrite align=16
global std_strings_bufSetByte
; ==============================
; Function: std_strings_bufSetByte
std_strings_bufSetByte:
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
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-72], RAX
    add QWORD[rbp-72], RBX
; 设置变量_p28
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-72]
    mov BYTE [RBX], al
; expression statement
    func_end_std_strings_bufSetByte:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_bufSetInt progbits alloc exec nowrite align=16
global std_strings_bufSetInt
; ==============================
; Function: std_strings_bufSetInt
std_strings_bufSetInt:
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
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_119
    if_119:
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-72], RAX
    add QWORD[rbp-72], RBX
; 设置变量_p29
    mov RAX, 48
    mov RBX, QWORD[rbp-72]
    mov BYTE [RBX], al
; expression statement
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_bufSetInt
    end_if_119:
    mov QWORD[rbp-80], 0
; 设置变量negative
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-88], RAX
; 设置变量num
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_120
    if_120:
    mov QWORD[rbp-80], 1
; 设置变量negative
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-88], 0
    sub QWORD[rbp-88], RAX
; 设置变量num
    end_if_120:
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-96], RAX
; 设置变量temp
    mov QWORD[rbp-104], 0
; 设置变量digitCount




    for_24: ; for循环开始
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle for_24_end
    for_24_body:


    mov RBX, QWORD[rbp-96]
    mov RAX, 10
    mov QWORD[rbp-96], RBX
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-96]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-96], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量temp
    mov RBX, QWORD[rbp-104]
    mov RAX, 1
    mov QWORD[rbp-104], RBX
    add QWORD[rbp-104], RAX
; 设置变量digitCount
    for_24_continue:


    jmp for_24; for循环
    for_24_end: ; for循环结束
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-112], RAX
; 设置变量total
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_121
    if_121:
    mov RBX, QWORD[rbp-112]
    mov RAX, 1
    mov QWORD[rbp-112], RBX
    add QWORD[rbp-112], RAX
; 设置变量total
    end_if_121:
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-120], RAX
; 设置变量pos
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-128], RAX
; 设置变量remaining




    for_25: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle for_25_end
    for_25_body:


    mov RBX, QWORD[rbp-120]
    mov RAX, 1
    mov QWORD[rbp-120], RBX
    sub QWORD[rbp-120], RAX
; 设置变量pos
    mov RAX, QWORD[rbp-128]
    mov RBX, 10
    push RBX; 保存除数
    mov rax, RAX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RAX, rax
    mov RBX, 10
    imul RAX, RBX
    mov RBX, QWORD[rbp-128]
    mov QWORD[rbp-136], RBX
    sub QWORD[rbp-136], RAX
; 设置变量digit
    mov RBX, QWORD[rbp-48]
    mov RAX, QWORD[rbp-56]
    add RBX, RAX
    mov RAX, QWORD[rbp-120]
    mov QWORD[rbp-144], RBX
    add QWORD[rbp-144], RAX
; 设置变量_p30
    mov RAX, QWORD[rbp-136]
    mov RBX, 48
    add RBX, RAX
    mov RAX, QWORD[rbp-144]
    mov BYTE [RAX], bl
; expression statement
    mov RAX, QWORD[rbp-128]
    mov RBX, 10
    mov QWORD[rbp-128], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-128]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-128], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量remaining
    for_25_continue:


    jmp for_25; for循环
    for_25_end: ; for循环结束
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_122
    if_122:
    mov RAX, QWORD[rbp-120]
    mov RBX, 1
    mov QWORD[rbp-120], RAX
    sub QWORD[rbp-120], RBX
; 设置变量pos
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-56]
    add RAX, RBX
    mov RBX, QWORD[rbp-120]
    mov QWORD[rbp-152], RAX
    add QWORD[rbp-152], RBX
; 设置变量_p31
    mov RAX, 45
    mov RBX, QWORD[rbp-152]
    mov BYTE [RBX], al
; expression statement
    end_if_122:
    mov RAX, QWORD[rbp-112]
; return值存入RAX
    jmp func_end_std_strings_bufSetInt
    func_end_std_strings_bufSetInt:
    add rsp, 200; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_bufToString progbits alloc exec nowrite align=16
global std_strings_bufToString
; ==============================
; Function: std_strings_bufToString
std_strings_bufToString:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-88], R10; 保存返回槽地址
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-112]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-112]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [RBP-112+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [RBP-112+16]
    mov QWORD [rbp-80+16], RAX
; 设置变量s
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
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
    jmp func_end_std_strings_bufToString
    func_end_std_strings_bufToString:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_bufCopyFrom progbits alloc exec nowrite align=16
global std_strings_bufCopyFrom
; ==============================
; Function: std_strings_bufCopyFrom
std_strings_bufCopyFrom:
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
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    mov QWORD [rbp-72], RCX; 保存参数3到栈
    mov QWORD[rbp-80], 0
; 设置变量i




    for_26: ; for循环开始
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_26_end
    for_26_body:


    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-56]
    add RAX, RBX
    mov RBX, QWORD[rbp-80]
    mov QWORD[rbp-88], RAX
    add QWORD[rbp-88], RBX
; 设置变量_p32
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-80]
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RBX
; 设置变量_p33
    mov RAX, QWORD[rbp-96]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-104], RAX
; 设置变量_pc_p33
    mov RAX, QWORD[rbp-104]
    mov RBX, QWORD[rbp-88]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-80]
    mov RBX, 1
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量i
    for_26_continue:


    jmp for_26; for循环
    for_26_end: ; for循环结束
    func_end_std_strings_bufCopyFrom:
    add rsp, 152; 清理局部变量 + 对齐
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
    jne end_if_123
    if_123:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_eq
    end_if_123:
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
    je end_if_124
    if_124:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_ne
    end_if_124:
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




    for_27: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_27_end
    for_27_body:


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
    for_27_continue:


    jmp for_27; for循环
    for_27_end: ; for循环结束
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
    jge else_if_125
    if_125:
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
    jmp end_if_125
    else_if_125:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64
    mov QWORD[rbp-65], RAX
; 设置变量num
    end_if_125:
    mov QWORD[rbp-73], 1
; 设置变量digits
    mov RAX, QWORD[rbp-65]
    mov QWORD[rbp-81], RAX
; 设置变量tmp




    for_28: ; for循环开始
    mov RAX, QWORD[rbp-81]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb for_28_end
    for_28_body:


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
    for_28_continue:


    jmp for_28; for循环
    for_28_end: ; for循环结束
    mov RAX, QWORD[rbp-73]
    mov QWORD[rbp-89], RAX
; 设置变量total
    movzx RAX, BYTE[rbp-57]
; condition
    test RAX, RAX
    jz end_if_126
    if_126:
    mov RAX, QWORD[rbp-89]
    mov RBX, 1
    mov QWORD[rbp-89], RAX
    add QWORD[rbp-89], RBX
; 设置变量total
    end_if_126:
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
    jne else_if_127
    if_127:
    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-121], RAX
; 设置变量_p14
    mov RAX, 48
    mov RBX, QWORD[rbp-121]
    mov BYTE [RBX], al
; expression statement
    jmp end_if_127
    else_if_127:
    mov QWORD[rbp-129], 0
; 设置变量i




    for_29: ; for循环开始
    mov RAX, QWORD[rbp-113]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_29_end
    for_29_body:


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
    jnb else_if_128
    if_128:
    mov RAX, QWORD[rbp-137]
    mov RBX, 48
    mov QWORD[rbp-145], RAX
    add QWORD[rbp-145], RBX
; 设置变量ch
    jmp end_if_128
    else_if_128:
    mov RAX, QWORD[rbp-137]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 36
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_129
    if_129:
    mov RAX, QWORD[rbp-137]
    mov RBX, 97
    add RAX, RBX
    mov RBX, 10
    mov QWORD[rbp-145], RAX
    sub QWORD[rbp-145], RBX
; 设置变量ch
    jmp end_if_129
    else_if_129:
    mov RAX, QWORD[rbp-137]
    mov RBX, 65
    add RAX, RBX
    mov RBX, 36
    mov QWORD[rbp-145], RAX
    sub QWORD[rbp-145], RBX
; 设置变量ch
    end_if_129:
    end_if_128:
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
    for_29_continue:


    jmp for_29; for循环
    for_29_end: ; for循环结束
    end_if_127:
    movzx RAX, BYTE[rbp-57]
; condition
    test RAX, RAX
    jz end_if_130
    if_130:
    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-161], RAX
; 设置变量_p16
    mov RAX, 45
    mov RBX, QWORD[rbp-161]
    mov BYTE [RBX], al
; expression statement
    end_if_130:
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
    jne end_if_131
    if_131:
    mov BYTE[rbp-121], 1
; 设置变量neg
    mov QWORD[rbp-120], 1
; 设置变量i
    end_if_131:
    mov QWORD[rbp-145], 0
; 设置变量val
    mov BYTE[rbp-146], 0
; 设置变量bad




    for_30: ; for循环开始
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-112]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_30_end
    for_30_body:


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
    jb else_if_132
    and_mid_3:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 57
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_132
    if_132:
    mov RAX, QWORD[rbp-162]
    mov RBX, 48
    mov QWORD[rbp-170], RAX
    sub QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_132
    else_if_132:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 97
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_133
    and_mid_4:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 122
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_133
    if_133:
    mov RAX, QWORD[rbp-162]
    mov RBX, 97
    sub RAX, RBX
    mov RBX, 10
    mov QWORD[rbp-170], RAX
    add QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_133
    else_if_133:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_134
    and_mid_5:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 90
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_134
    if_134:
    mov RAX, QWORD[rbp-162]
    mov RBX, 65
    sub RAX, RBX
    mov RBX, 36
    mov QWORD[rbp-170], RAX
    add QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_134
    else_if_134:
    mov BYTE[rbp-146], 1
; 设置变量bad
    end_if_134:
    end_if_133:
    end_if_132:
    movzx RAX, BYTE[rbp-146]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_135
    if_135:
    mov RAX, QWORD[rbp-145]
    mov RBX, QWORD[rbp-72]
    imul RAX, RBX
    mov RBX, QWORD[rbp-170]
    mov QWORD[rbp-145], RAX
    add QWORD[rbp-145], RBX
; 设置变量val
    end_if_135:
    mov RAX, QWORD[rbp-120]
    mov RBX, 1
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量i
    for_30_continue:


    jmp for_30; for循环
    for_30_end: ; for循环结束
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
    jz end_if_136
    if_136:
    mov RBX, QWORD[rbp-178]
    mov QWORD[rbp-178], 0
    sub QWORD[rbp-178], RBX
; 设置变量r
    end_if_136:
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
    jne end_if_137
    if_137:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    end_if_137:
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_138
    if_138:
    call std_strings_notFound
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    end_if_138:
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




    for_31: ; for循环开始
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-144]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe for_31_end
    for_31_body:


    mov BYTE[rbp-145], 1
; 设置变量found
    mov QWORD[rbp-153], 0
; 设置变量j




    for_32: ; for循环开始
    mov RAX, QWORD[rbp-153]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-112]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_32_end
    for_32_body:


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
    je end_if_139
    if_139:
    mov BYTE[rbp-145], 0
; 设置变量found
    jmp for_32_end
    end_if_139:
    mov RAX, QWORD[rbp-153]
    mov RBX, 1
    mov QWORD[rbp-153], RAX
    add QWORD[rbp-153], RBX
; 设置变量j
    for_32_continue:


    jmp for_32; for循环
    for_32_end: ; for循环结束
    movzx RAX, BYTE[rbp-145]
; condition
    test RAX, RAX
    jz end_if_140
    if_140:
    mov RAX, QWORD[rbp-136]
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    end_if_140:
    mov RAX, QWORD[rbp-136]
    mov RBX, 1
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量i
    for_31_continue:


    jmp for_31; for循环
    for_31_end: ; for循环结束
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


section .text.std_strings_index progbits alloc exec nowrite align=16
global std_strings_index
; ==============================
; Function: std_strings_index
std_strings_index:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 152; 分配局部变量空间(152字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
    call std_strings_notFound
    mov QWORD[rbp-96], RAX
; 设置变量nf
    sub rsp, 8; align stack for stack args
    push 0
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
    mov QWORD[rbp-104], RAX
; 设置变量r
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_141
    if_141:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_index
    end_if_141:
    mov RAX, QWORD[rbp-104]
; return值存入RAX
    jmp func_end_std_strings_index
    func_end_std_strings_index:
    add rsp, 152; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_hasPrefix progbits alloc exec nowrite align=16
global std_strings_hasPrefix
; ==============================
; Function: std_strings_hasPrefix
std_strings_hasPrefix:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 184; 分配局部变量空间(184字节, 含对齐)
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
    mov QWORD[rbp-96], RAX
; 设置变量sLen
    mov RDI, QWORD [rbp-88]
    mov RSI, QWORD [rbp-88+8]
    mov RDX, QWORD [rbp-88+16]
    call __string_len
    mov QWORD[rbp-104], RAX
; 设置变量tLen
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_142
    if_142:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasPrefix
    end_if_142:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_143
    if_143:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_hasPrefix
    end_if_143:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-112], RAX
; 设置变量sPtr
    mov RAX, QWORD [rbp-88]
    mov QWORD [rbp-120], RAX
; 设置变量tPtr
    mov QWORD[rbp-128], 0
; 设置变量i




    for_33: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_33_end
    for_33_body:


    mov RAX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-128]
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量_p31
    mov RAX, QWORD[rbp-120]
    mov RBX, QWORD[rbp-128]
    mov QWORD[rbp-144], RAX
    add QWORD[rbp-144], RBX
; 设置变量_p32
    mov RAX, QWORD[rbp-136]
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RAX, QWORD[rbp-144]
    movzx RCX, BYTE [RAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_144
    if_144:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasPrefix
    end_if_144:
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量i
    for_33_continue:


    jmp for_33; for循环
    for_33_end: ; for循环结束
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_hasPrefix
    func_end_std_strings_hasPrefix:
    add rsp, 184; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_hasSuffix progbits alloc exec nowrite align=16
global std_strings_hasSuffix
; ==============================
; Function: std_strings_hasSuffix
std_strings_hasSuffix:
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
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
    mov RDI, QWORD [rbp-64]
    mov RSI, QWORD [rbp-64+8]
    mov RDX, QWORD [rbp-64+16]
    call __string_len
    mov QWORD[rbp-96], RAX
; 设置变量sLen
    mov RDI, QWORD [rbp-88]
    mov RSI, QWORD [rbp-88+8]
    mov RDX, QWORD [rbp-88+16]
    call __string_len
    mov QWORD[rbp-104], RAX
; 设置变量tLen
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_145
    if_145:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasSuffix
    end_if_145:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_146
    if_146:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_hasSuffix
    end_if_146:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-112], RAX
; 设置变量sPtr
    mov RAX, QWORD [rbp-88]
    mov QWORD [rbp-120], RAX
; 设置变量tPtr
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-128], RAX
    sub QWORD[rbp-128], RBX
; 设置变量offset
    mov QWORD[rbp-136], 0
; 设置变量i




    for_34: ; for循环开始
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_34_end
    for_34_body:


    mov RAX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-128]
    add RAX, RBX
    mov RBX, QWORD[rbp-136]
    mov QWORD[rbp-144], RAX
    add QWORD[rbp-144], RBX
; 设置变量_p33
    mov RAX, QWORD[rbp-120]
    mov RBX, QWORD[rbp-136]
    mov QWORD[rbp-152], RAX
    add QWORD[rbp-152], RBX
; 设置变量_p34
    mov RAX, QWORD[rbp-144]
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RAX, QWORD[rbp-152]
    movzx RCX, BYTE [RAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_147
    if_147:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasSuffix
    end_if_147:
    mov RAX, QWORD[rbp-136]
    mov RBX, 1
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量i
    for_34_continue:


    jmp for_34; for循环
    for_34_end: ; for循环结束
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_hasSuffix
    func_end_std_strings_hasSuffix:
    add rsp, 200; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_repeat progbits alloc exec nowrite align=16
global std_strings_repeat
; ==============================
; Function: std_strings_repeat
std_strings_repeat:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 200; 分配局部变量空间(200字节, 含对齐)
    mov QWORD [rbp-168], R10; 保存返回槽地址
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1到栈
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-80], RAX
; 设置变量sPtr
    mov RDI, QWORD [rbp-64]
    mov RSI, QWORD [rbp-64+8]
    mov RDX, QWORD [rbp-64+16]
    call __string_len
    mov QWORD[rbp-88], RAX
; 设置变量sLen
    mov RAX, QWORD[rbp-88]
    mov RBX, QWORD[rbp-72]
    mov QWORD[rbp-96], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存乘数
    mov RAX, QWORD[rbp-96]
    imul RAX, qword [rsp]
    mov QWORD[rbp-96], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量total
    mov RAX, QWORD[rbp-96]
    mov RBX, 1
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量bufN
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-112], RAX
; 设置变量buf
    mov QWORD[rbp-120], 0
; 设置变量i




    for_35: ; for循环开始
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_35_end
    for_35_body:


    mov QWORD[rbp-128], 0
; 设置变量j




    for_36: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_36_end
    for_36_body:


    mov RBX, QWORD[rbp-120]
    mov RCX, QWORD[rbp-88]
    imul RBX, RCX
    mov RAX, QWORD[rbp-112]
    add RAX, RBX
    mov RCX, QWORD[rbp-128]
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RCX
; 设置变量_p52
    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rbp-128]
    mov QWORD[rbp-144], RAX
    add QWORD[rbp-144], RBX
; 设置变量_p53
    mov RAX, QWORD[rbp-144]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-152], RAX
; 设置变量_pc_p53
    mov RAX, QWORD[rbp-152]
    mov RBX, QWORD[rbp-136]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-128]
    mov RCX, 1
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RCX
; 设置变量j
    for_36_continue:


    jmp for_36; for循环
    for_36_end: ; for循环结束
    mov RAX, QWORD[rbp-120]
    mov RCX, 1
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RCX
; 设置变量i
    for_35_continue:


    jmp for_35; for循环
    for_35_end: ; for循环结束
    mov RAX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-96]
    mov QWORD[rbp-160], RAX
    add QWORD[rbp-160], RBX
; 设置变量_p54
    mov RAX, 0
    mov RBX, QWORD[rbp-160]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-112]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-192]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-192]
    mov QWORD [rbp-192+0], RAX
    mov RAX, QWORD [RBP-192+8]
    mov QWORD [rbp-192+8], RAX
    mov RAX, QWORD [RBP-192+16]
    mov QWORD [rbp-192+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-168]; 恢复返回槽地址
    mov RAX, QWORD [rbp-192]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-184]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-176]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_repeat
    func_end_std_strings_repeat:
    add rsp, 200; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_putByte progbits alloc exec nowrite align=16
global std_strings_putByte
; ==============================
; Function: std_strings_putByte
std_strings_putByte:
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
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-64]
    mov QWORD[rbp-72], RAX
    add QWORD[rbp-72], RBX
; 设置变量dAddr
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-80], RAX
; 设置变量dP
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-88], RBX
    add QWORD[rbp-88], RAX
; 设置变量sAddr
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-96], RAX
; 设置变量sP
    mov RBX, QWORD[rbp-96]
    movzx RAX, BYTE [RBX]
    mov QWORD[rbp-104], RAX
; 设置变量v
    mov RBX, QWORD[rbp-104]
    mov RAX, QWORD[rbp-80]
    mov BYTE [RAX], bl
; expression statement
    jmp func_end_std_strings_putByte
    func_end_std_strings_putByte:
    add rsp, 152; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_byteAt progbits alloc exec nowrite align=16
global std_strings_byteAt
; ==============================
; Function: std_strings_byteAt
std_strings_byteAt:
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
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量bAddr
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-72], RAX
; 设置变量bP
    mov RBX, QWORD[rbp-72]
    movzx RAX, BYTE [RBX]
    mov QWORD[rbp-80], RAX
; 设置变量bV
    mov RAX, QWORD[rbp-80]
; return值存入RAX
    jmp func_end_std_strings_byteAt
    func_end_std_strings_byteAt:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_putPiece progbits alloc exec nowrite align=16
global std_strings_putPiece
; ==============================
; Function: std_strings_putPiece
std_strings_putPiece:
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
    mov QWORD [rbp-64], RDX; 保存参数2到栈
    mov QWORD [rbp-72], RCX; 保存参数3到栈
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
    mov QWORD[rbp-96], 0
; 设置变量i




    for_37: ; for循环开始
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_37_end
    for_37_body:


    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-88]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_putByte
    mov RAX, QWORD[rbp-96]
    mov RBX, 1
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RBX
; 设置变量i
    for_37_continue:


    jmp for_37; for循环
    for_37_end: ; for循环结束
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-104], RAX
; 设置变量tailIdx
    mov RAX, QWORD[rbp-88]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-112], RAX
    add QWORD[rbp-112], RBX
; 设置变量tailAddr
    mov RAX, QWORD[rbp-112]
    mov QWORD[rbp-120], RAX
; 设置变量tailP
    mov QWORD[rbp-128], 0
; 设置变量zeroU
    mov RBX, QWORD[rbp-128]
    mov RAX, QWORD[rbp-120]
    mov BYTE [RAX], bl
; expression statement
    mov QWORD[rbp-136], 24
; 设置变量elemSize
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-136]
    mov QWORD[rbp-144], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存乘数
    mov RAX, QWORD[rbp-144]
    imul RAX, qword [rsp]
    mov QWORD[rbp-144], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量dstOff
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-144]
    mov QWORD[rbp-152], RAX
    add QWORD[rbp-152], RBX
; 设置变量cellAddr
    mov RAX, QWORD[rbp-152]
    mov QWORD[rbp-160], RAX
; 设置变量cell
    mov RBX, QWORD [RBP-160]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-88]
    mov QWORD[RBX], RAX
; 设置变量cell.p
    mov RBX, QWORD [RBP-160]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-72]
    mov QWORD[RBX+8], RAX
; 设置变量cell.n
    mov RBX, QWORD [RBP-160]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-72]
    mov QWORD[RBX+16], RAX
; 设置变量cell.c
    jmp func_end_std_strings_putPiece
    func_end_std_strings_putPiece:
    add rsp, 200; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_splitN progbits alloc exec nowrite align=16
global std_strings_splitN
; ==============================
; Function: std_strings_splitN
std_strings_splitN:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 392; 分配局部变量空间(392字节, 含对齐)
    mov RAX, [rbp+16]; 保存栈参数2槽0到栈
    mov [rbp-96], RAX
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-104], RAX
; 设置变量sPtr
    mov RDI, QWORD [rbp-64]
    mov RSI, QWORD [rbp-64+8]
    mov RDX, QWORD [rbp-64+16]
    call __string_len
    mov QWORD[rbp-112], RAX
; 设置变量sLen
    mov RAX, QWORD [rbp-88]
    mov QWORD [rbp-120], RAX
; 设置变量sepPtr
    mov RDI, QWORD [rbp-88]
    mov RSI, QWORD [rbp-88+8]
    mov RDX, QWORD [rbp-88+16]
    call __string_len
    mov QWORD[rbp-128], RAX
; 设置变量sepLen
    mov RAX, QWORD[rbp-96]
    mov RBX, 0
    mov BYTE[rbp-129], al
    cmp BYTE[rbp-129], bl
    setl al
    mov BYTE[rbp-129], al
; 设置变量nNeg
    mov QWORD[rbp-137], 0
; 设置变量nMag
    movzx RAX, BYTE[rbp-129]
; condition
    test RAX, RAX
    jz else_if_148
    if_148:
    mov RBX, QWORD[rbp-96]
    mov QWORD[rbp-145], 0
    sub QWORD[rbp-145], RBX
; 设置变量absN
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-145]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64
    mov QWORD[rbp-137], RAX
; 设置变量nMag
    jmp end_if_148
    else_if_148:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64
    mov QWORD[rbp-137], RAX
; 设置变量nMag
    end_if_148:
    mov QWORD[rbp-153], 0
; 设置变量totalPieces
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe else_if_149
    if_149:
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
    call std_strings_count
    mov QWORD[rbp-161], RAX
; 设置变量numSeps
    mov RAX, QWORD[rbp-161]
    mov RBX, 1
    mov QWORD[rbp-169], RAX
    add QWORD[rbp-169], RBX
; 设置变量withSelf
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-169]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64
    mov QWORD[rbp-153], RAX
; 设置变量totalPieces
    jmp end_if_149
    else_if_149:
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_150
    if_150:
    mov QWORD[rbp-153], 1
; 设置变量totalPieces
    jmp end_if_150
    else_if_150:
    mov RAX, QWORD[rbp-112]
    mov QWORD[rbp-153], RAX
; 设置变量totalPieces
    end_if_150:
    end_if_149:
    mov RAX, QWORD[rbp-153]
    mov QWORD[rbp-177], RAX
; 设置变量pieces
    movzx RAX, BYTE[rbp-129]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_151
    if_151:
    mov RAX, QWORD[rbp-177]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-137]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_152
    if_152:
    mov RAX, QWORD[rbp-137]
    mov QWORD[rbp-177], RAX
; 设置变量pieces
    end_if_152:
    end_if_151:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 24
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-185], RAX
; 设置变量outer
    mov QWORD[rbp-193], 24
; 设置变量elemSize
    mov QWORD[rbp-201], 0
; 设置变量dataSize
    mov RAX, QWORD[rbp-177]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_153
    if_153:
    mov RAX, QWORD[rbp-177]
    mov RBX, QWORD[rbp-193]
    mov QWORD[rbp-201], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存乘数
    mov RAX, QWORD[rbp-201]
    imul RAX, qword [rsp]
    mov QWORD[rbp-201], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量dataSize
    end_if_153:
    mov RAX, QWORD[rbp-185]
    mov QWORD[rbp-209], RAX
; 设置变量hdr
    mov QWORD[rbp-217], 0
; 设置变量data
    mov RAX, QWORD[rbp-177]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_154
    if_154:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-201]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-217], RAX
; 设置变量data
    end_if_154:
    mov RBX, QWORD [RBP-209]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-217]
    mov QWORD[RBX], RAX
; 设置变量hdr.p
    mov RBX, QWORD [RBP-209]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-177]
    mov QWORD[RBX+16], RAX
; 设置变量hdr.c
    mov QWORD[rbp-225], 0
; 设置变量cellCount
    mov RAX, QWORD[rbp-177]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_155
    if_155:
    mov QWORD[rbp-233], 0
; 设置变量scanPos
    mov QWORD[rbp-241], 0
; 设置变量pieceI
    call std_strings_notFound
    mov QWORD[rbp-249], RAX
; 设置变量nf
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe else_if_156
    if_156:
    mov RAX, QWORD[rbp-177]
    mov RBX, 1
    mov QWORD[rbp-257], RAX
    sub QWORD[rbp-257], RBX
; 设置变量limitM1




    for_38: ; for循环开始
    mov RAX, QWORD[rbp-241]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-257]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_38_end
    for_38_body:


    sub rsp, 8; align stack for stack args
    push QWORD[rbp-233]
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
    mov QWORD[rbp-265], RAX
; 设置变量sIdx
    mov RAX, QWORD[rbp-265]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-249]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_157
    if_157:
    jmp for_38_end
    end_if_157:
    mov RAX, QWORD[rbp-233]
    mov QWORD[rbp-273], RAX
; 设置变量segOff
    mov RAX, QWORD[rbp-104]
    mov RBX, QWORD[rbp-273]
    mov QWORD[rbp-281], RAX
    add QWORD[rbp-281], RBX
; 设置变量segSrc
    mov RAX, QWORD[rbp-265]
    mov RBX, QWORD[rbp-233]
    mov QWORD[rbp-289], RAX
    sub QWORD[rbp-289], RBX
; 设置变量segLenU
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-217]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-241]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-281]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RAX, QWORD[rbp-289]
    mov QWORD [rsp+24], RAX
; 参数3
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数3
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_putPiece
    mov RBX, QWORD[rbp-265]
    mov RAX, QWORD[rbp-128]
    mov QWORD[rbp-233], RBX
    add QWORD[rbp-233], RAX
; 设置变量scanPos
    mov RAX, QWORD[rbp-241]
    mov RBX, 1
    mov QWORD[rbp-241], RAX
    add QWORD[rbp-241], RBX
; 设置变量pieceI
    for_38_continue:


    jmp for_38; for循环
    for_38_end: ; for循环结束
    jmp end_if_156
    else_if_156:
    mov RAX, QWORD[rbp-177]
    mov RBX, 1
    mov QWORD[rbp-297], RAX
    sub QWORD[rbp-297], RBX
; 设置变量bsLimit




    for_39: ; for循环开始
    mov RAX, QWORD[rbp-241]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-297]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_39_end
    for_39_body:


    mov RAX, QWORD[rbp-233]
    mov QWORD[rbp-305], RAX
; 设置变量bOff
    mov RAX, QWORD[rbp-104]
    mov RBX, QWORD[rbp-305]
    mov QWORD[rbp-313], RAX
    add QWORD[rbp-313], RBX
; 设置变量bSrc
    mov QWORD[rbp-321], 1
; 设置变量bLen
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-217]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-241]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-313]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RAX, QWORD[rbp-321]
    mov QWORD [rsp+24], RAX
; 参数3
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数3
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_putPiece
    mov RBX, QWORD[rbp-233]
    mov RAX, 1
    mov QWORD[rbp-233], RBX
    add QWORD[rbp-233], RAX
; 设置变量scanPos
    mov RBX, QWORD[rbp-241]
    mov RAX, 1
    mov QWORD[rbp-241], RBX
    add QWORD[rbp-241], RAX
; 设置变量pieceI
    for_39_continue:


    jmp for_39; for循环
    for_39_end: ; for循环结束
    end_if_156:
    mov RAX, QWORD[rbp-233]
    mov QWORD[rbp-329], RAX
; 设置变量tailOff
    mov RBX, QWORD[rbp-104]
    mov RAX, QWORD[rbp-329]
    mov QWORD[rbp-337], RBX
    add QWORD[rbp-337], RAX
; 设置变量tailSrc
    mov RAX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-233]
    mov QWORD[rbp-345], RAX
    sub QWORD[rbp-345], RBX
; 设置变量tailLen
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-217]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-241]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-337]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RAX, QWORD[rbp-345]
    mov QWORD [rsp+24], RAX
; 参数3
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数3
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_putPiece
    mov RBX, QWORD[rbp-241]
    mov RAX, 1
    mov QWORD[rbp-241], RBX
    add QWORD[rbp-241], RAX
; 设置变量pieceI
    mov RAX, QWORD[rbp-241]
    mov QWORD[rbp-225], RAX
; 设置变量cellCount
    end_if_155:
    mov RBX, QWORD [RBP-209]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-225]
    mov QWORD[RBX+8], RAX
; 设置变量hdr.n
    mov RAX, QWORD[rbp-185]
; return值存入RAX
    jmp func_end_std_strings_splitN
    func_end_std_strings_splitN:
    add rsp, 392; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_cellP progbits alloc exec nowrite align=16
global std_strings_cellP
; ==============================
; Function: std_strings_cellP
std_strings_cellP:
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
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-64], RAX
; 设置变量rAddrH
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-72], RAX
; 设置变量hdrH
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-80], RAX
; 设置变量dataH
    mov QWORD[rbp-88], 24
; 设置变量elemH
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-88]
    mov QWORD[rbp-96], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存乘数
    mov RAX, QWORD[rbp-96]
    imul RAX, qword [rsp]
    mov QWORD[rbp-96], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量offH
    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rbp-96]
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量cellAddrH
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-112], RAX
; 设置变量cellH
    mov RBX, QWORD [RBP-112]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-120], RAX
; 设置变量cellPH
    mov RAX, QWORD[rbp-120]
; return值存入RAX
    jmp func_end_std_strings_cellP
    func_end_std_strings_cellP:
    add rsp, 168; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_bGrow progbits alloc exec nowrite align=16
global std_strings_bGrow
; ==============================
; Function: std_strings_bGrow
std_strings_bGrow:
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
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-64], RAX
; 设置变量box
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
    mov QWORD[rbp-72], RAX
; 设置变量n0
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD[rbp-80], RAX
; 设置变量c0
    mov RAX, QWORD[rbp-72]
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-88], RAX
    add QWORD[rbp-88], RBX
; 设置变量total
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_158
    if_158:
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-96], RAX
; 设置变量ncap
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 512
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_159
    if_159:
    mov RBX, QWORD[rbp-80]
    mov RAX, 2
    mov QWORD[rbp-96], RBX
    push RAX; 保护RAX(左子结果)
    push RAX; 暂存乘数
    mov RAX, QWORD[rbp-96]
    imul RAX, qword [rsp]
    mov QWORD[rbp-96], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量ncap
    jmp end_if_159
    else_if_159:
    mov RBX, QWORD[rbp-80]
    mov RAX, 4
    mov QWORD[rbp-104], RBX
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-104]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-104], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量q
    mov RBX, QWORD[rbp-80]
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-96], RBX
    add QWORD[rbp-96], RAX
; 设置变量ncap
    end_if_159:
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_160
    if_160:
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-96], RAX
; 设置变量ncap
    end_if_160:
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-112], RAX
; 设置变量oldData
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-120], RAX
; 设置变量nbuf
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-128], RAX
; 设置变量moveN
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-112]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-128]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_memory_memmove
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-112]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-120]
    mov QWORD[RBX], RAX
; 设置变量box.p
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-96]
    mov QWORD[RBX+16], RAX
; 设置变量box.c
    end_if_158:
    jmp func_end_std_strings_bGrow
    func_end_std_strings_bGrow:
    add rsp, 168; 清理局部变量 + 对齐
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
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
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
; return值存入RAX
    jmp func_end_std_builtin_print
    func_end_std_builtin_print:
    add rsp, 104; 清理局部变量 + 对齐
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


section .text.std_maps_roundUpU progbits alloc exec nowrite align=16
global std_maps_roundUpU
; ==============================
; Function: std_maps_roundUpU
std_maps_roundUpU:
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
    mov RBX, QWORD[rbp-56]
    add RAX, RBX
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    sub QWORD[rbp-64], RBX
; 设置变量q
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-56]
    push RBX; 保存除数
    mov rax, RAX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RAX, rax
    mov RBX, QWORD[rbp-56]
    imul RAX, RBX
; return值存入RAX
    jmp func_end_std_maps_roundUpU
    func_end_std_maps_roundUpU:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_maps_fnv1a progbits alloc exec nowrite align=16
global std_maps_fnv1a
; ==============================
; Function: std_maps_fnv1a
std_maps_fnv1a:
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
    mov DWORD[rbp-60], 2166136261
; 设置变量h
    mov QWORD[rbp-68], 0
; 设置变量i




    for_40: ; for循环开始
    mov RAX, QWORD[rbp-68]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_40_end
    for_40_body:


    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-68]
    mov QWORD[rbp-76], RAX
    add QWORD[rbp-76], RBX
; 设置变量bp
    mov RAX, QWORD[rbp-76]
    movzx RAX, BYTE [RAX]
    mov DWORD[rbp-80], EAX
; 设置变量b
    mov EAX, DWORD[rbp-60]
    mov EBX, DWORD[rbp-80]
    mov DWORD[rbp-60], EAX
    xor DWORD[rbp-60], EBX
; 设置变量h
    mov EAX, DWORD[rbp-60]
    mov RBX, 16777619
    mov DWORD[rbp-60], EAX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存乘数
    mov eax, DWORD[rbp-60]
    imul RAX, qword [rsp]
    mov DWORD[rbp-60], EAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量h
    mov RAX, QWORD[rbp-68]
    mov RBX, 1
    mov QWORD[rbp-68], RAX
    add QWORD[rbp-68], RBX
; 设置变量i
    for_40_continue:


    jmp for_40; for循环
    for_40_end: ; for循环结束
    mov EAX, DWORD[rbp-60]
; return值存入RAX
    jmp func_end_std_maps_fnv1a
    func_end_std_maps_fnv1a:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_maps_bytesEq progbits alloc exec nowrite align=16
global std_maps_bytesEq
; ==============================
; Function: std_maps_bytesEq
std_maps_bytesEq:
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
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_161
    if_161:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_maps_bytesEq
    end_if_161:
    mov QWORD[rbp-80], 0
; 设置变量i




    for_41: ; for循环开始
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_41_end
    for_41_body:


    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-80]
    mov QWORD[rbp-88], RAX
    add QWORD[rbp-88], RBX
; 设置变量ap
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-80]
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RBX
; 设置变量bp
    mov RAX, QWORD[rbp-88]
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RAX, QWORD[rbp-96]
    movzx RCX, BYTE [RAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_162
    if_162:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_maps_bytesEq
    end_if_162:
    mov RAX, QWORD[rbp-80]
    mov RBX, 1
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量i
    for_41_continue:


    jmp for_41; for循环
    for_41_end: ; for循环结束
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_maps_bytesEq
    func_end_std_maps_bytesEq:
    add rsp, 136; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_writeStr progbits alloc exec nowrite align=16
global std_console_writeStr
; ==============================
; Function: std_console_writeStr
std_console_writeStr:
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
    mov RBX, QWORD[rel __global_std_console_STDOUT_FD]
    mov QWORD [rsp+0], RBX
; 参数0
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
; return值存入RAX
    jmp func_end_std_console_writeStr
    func_end_std_console_writeStr:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_bufAndStr progbits alloc exec nowrite align=16
global std_console_bufAndStr
; ==============================
; Function: std_console_bufAndStr
std_console_bufAndStr:
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
    lea R10, [rbp-112]; 大值返回槽地址
    call std_strings_bufToString
    mov RAX, QWORD [RBP-112]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [RBP-112+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [RBP-112+16]
    mov QWORD [rbp-80+16], RAX
; 设置变量s
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-80]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-80+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-80+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_console_writeStr
; return值存入RAX
    jmp func_end_std_console_bufAndStr
    func_end_std_console_bufAndStr:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_writeEsc2Param progbits alloc exec nowrite align=16
global std_console_writeEsc2Param
; ==============================
; Function: std_console_writeEsc2Param
std_console_writeEsc2Param:
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
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 32
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_bufNew
    mov QWORD[rbp-72], RAX
; 设置变量buf
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RAX, QWORD[rel __global_std_console_ESC]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov QWORD [rsp+16], 91
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov QWORD[rbp-80], 2
; 设置变量pos
    mov RAX, QWORD[rbp-80]
    mov RBX, RAX
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-80]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RCX, QWORD[rbp-48]
    mov QWORD [rsp+16], RCX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetInt
    mov QWORD[rbp-80], RBX
    add QWORD[rbp-80], RAX
; 设置变量pos
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-80]
    mov QWORD [rsp+8], RCX
; 参数1
    mov QWORD [rsp+16], 59
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov RAX, QWORD[rbp-80]
    mov RBX, 1
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量pos
    mov RAX, QWORD[rbp-80]
    mov RBX, RAX
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-80]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RCX, QWORD[rbp-56]
    mov QWORD [rsp+16], RCX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetInt
    mov QWORD[rbp-80], RBX
    add QWORD[rbp-80], RAX
; 设置变量pos
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-80]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RCX, QWORD[rbp-64]
    mov QWORD [rsp+16], RCX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov RAX, QWORD[rbp-80]
    mov RBX, 1
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量pos
    sub rsp, 16; register args buffer
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-80]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_bufAndStr
; return值存入RAX
    jmp func_end_std_console_writeEsc2Param
    func_end_std_console_writeEsc2Param:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_writeEsc1Param progbits alloc exec nowrite align=16
global std_console_writeEsc1Param
; ==============================
; Function: std_console_writeEsc1Param
std_console_writeEsc1Param:
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
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 32
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_bufNew
    mov QWORD[rbp-64], RAX
; 设置变量buf
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RAX, QWORD[rel __global_std_console_ESC]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov QWORD [rsp+16], 91
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov QWORD[rbp-72], 2
; 设置变量pos
    mov RAX, QWORD[rbp-72]
    mov RBX, RAX
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-64]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RCX, QWORD[rbp-48]
    mov QWORD [rsp+16], RCX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetInt
    mov QWORD[rbp-72], RBX
    add QWORD[rbp-72], RAX
; 设置变量pos
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-64]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RCX, QWORD[rbp-56]
    mov QWORD [rsp+16], RCX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov RAX, QWORD[rbp-72]
    mov RBX, 1
    mov QWORD[rbp-72], RAX
    add QWORD[rbp-72], RBX
; 设置变量pos
    sub rsp, 16; register args buffer
    mov RCX, QWORD[rbp-64]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_bufAndStr
; return值存入RAX
    jmp func_end_std_console_writeEsc1Param
    func_end_std_console_writeEsc1Param:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_writeEscCSI progbits alloc exec nowrite align=16
global std_console_writeEscCSI
; ==============================
; Function: std_console_writeEscCSI
std_console_writeEscCSI:
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
    mov QWORD [rsp+0], 8
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_bufNew
    mov QWORD[rbp-56], RAX
; 设置变量buf
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RAX, QWORD[rel __global_std_console_ESC]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov QWORD [rsp+16], 91
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 2
; 参数1
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 3
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_bufAndStr
; return值存入RAX
    jmp func_end_std_console_writeEscCSI
    func_end_std_console_writeEscCSI:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_writeEscParamCSI progbits alloc exec nowrite align=16
global std_console_writeEscParamCSI
; ==============================
; Function: std_console_writeEscParamCSI
std_console_writeEscParamCSI:
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
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 32
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_bufNew
    mov QWORD[rbp-72], RAX
; 设置变量buf
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RAX, QWORD[rel __global_std_console_ESC]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov QWORD [rsp+16], 91
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov QWORD[rbp-80], 2
; 设置变量pos
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_163
    if_163:
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+8], RAX
; 参数1
    mov QWORD [rsp+16], 63
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov RAX, QWORD[rbp-80]
    mov RBX, 1
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量pos
    end_if_163:
    mov RAX, QWORD[rbp-80]
    mov RBX, RAX
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-80]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RCX, QWORD[rbp-56]
    mov QWORD [rsp+16], RCX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetInt
    mov QWORD[rbp-80], RBX
    add QWORD[rbp-80], RAX
; 设置变量pos
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-80]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RCX, QWORD[rbp-64]
    mov QWORD [rsp+16], RCX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov RAX, QWORD[rbp-80]
    mov RBX, 1
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量pos
    sub rsp, 16; register args buffer
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-80]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_bufAndStr
; return值存入RAX
    jmp func_end_std_console_writeEscParamCSI
    func_end_std_console_writeEscParamCSI:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_rgbToAnsi256 progbits alloc exec nowrite align=16
global std_console_rgbToAnsi256
; ==============================
; Function: std_console_rgbToAnsi256
std_console_rgbToAnsi256:
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
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 200
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_164
    if_164:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 200
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_165
    if_165:
    mov RAX, 11
; return值存入RAX
    jmp func_end_std_console_rgbToAnsi256
    end_if_165:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 200
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_166
    if_166:
    mov RAX, 13
; return值存入RAX
    jmp func_end_std_console_rgbToAnsi256
    end_if_166:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_console_rgbToAnsi256
    end_if_164:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 200
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_167
    if_167:
    mov RAX, 2
; return值存入RAX
    jmp func_end_std_console_rgbToAnsi256
    end_if_167:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 200
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_168
    if_168:
    mov RAX, 4
; return值存入RAX
    jmp func_end_std_console_rgbToAnsi256
    end_if_168:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 100
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_169
    if_169:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 100
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_170
    if_170:
    mov RAX, 3
; return值存入RAX
    jmp func_end_std_console_rgbToAnsi256
    end_if_170:
    mov RAX, 9
; return值存入RAX
    jmp func_end_std_console_rgbToAnsi256
    end_if_169:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 100
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_171
    if_171:
    mov RAX, 10
; return值存入RAX
    jmp func_end_std_console_rgbToAnsi256
    end_if_171:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 100
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_172
    if_172:
    mov RAX, 12
; return值存入RAX
    jmp func_end_std_console_rgbToAnsi256
    end_if_172:
    mov RAX, 7
; return值存入RAX
    jmp func_end_std_console_rgbToAnsi256
    func_end_std_console_rgbToAnsi256:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_setFg progbits alloc exec nowrite align=16
global std_console_setFg
; ==============================
; Function: std_console_setFg
std_console_setFg:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    call std_console_shouldUseAdvanced
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_173
    if_173:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_console_setFg
    end_if_173:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], 30
    add QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 109
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_writeEsc1Param
; return值存入RAX
    jmp func_end_std_console_setFg
    func_end_std_console_setFg:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_setBg progbits alloc exec nowrite align=16
global std_console_setBg
; ==============================
; Function: std_console_setBg
std_console_setBg:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    call std_console_shouldUseAdvanced
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_174
    if_174:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_console_setBg
    end_if_174:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], 40
    add QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 109
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_writeEsc1Param
; return值存入RAX
    jmp func_end_std_console_setBg
    func_end_std_console_setBg:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_setFgBright progbits alloc exec nowrite align=16
global std_console_setFgBright
; ==============================
; Function: std_console_setFgBright
std_console_setFgBright:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    call std_console_shouldUseAdvanced
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_175
    if_175:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_console_setFgBright
    end_if_175:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], 90
    add QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 109
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_writeEsc1Param
; return值存入RAX
    jmp func_end_std_console_setFgBright
    func_end_std_console_setFgBright:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_setBgBright progbits alloc exec nowrite align=16
global std_console_setBgBright
; ==============================
; Function: std_console_setBgBright
std_console_setBgBright:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    call std_console_shouldUseAdvanced
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_176
    if_176:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_console_setBgBright
    end_if_176:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], 100
    add QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 109
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_writeEsc1Param
; return值存入RAX
    jmp func_end_std_console_setBgBright
    func_end_std_console_setBgBright:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_setFg256 progbits alloc exec nowrite align=16
global std_console_setFg256
; ==============================
; Function: std_console_setFg256
std_console_setFg256:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    call std_console_shouldUseAdvanced
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_177
    if_177:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_console_setFg256
    end_if_177:
    call std_console_supports256Color
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_178
    if_178:
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-56], RAX
; 设置变量c16
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 15
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_179
    if_179:
    mov RAX, QWORD[rbp-56]
    mov RBX, 16
    mov QWORD[rbp-56], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-56]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-56], rdx
    pop RAX; 恢复RAX(左子结果)
; 设置变量c16
    end_if_179:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 8
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl end_if_180
    if_180:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-56]
    mov RCX, 8
    mov QWORD [rsp+0], RBX
    sub QWORD [rsp+0], RCX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_setFgBright
; return值存入RAX
    jmp func_end_std_console_setFg256
    end_if_180:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_setFg
; return值存入RAX
    jmp func_end_std_console_setFg256
    end_if_178:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 32
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_bufNew
    mov QWORD[rbp-64], RAX
; 设置变量buf
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RBX, QWORD[rel __global_std_console_ESC]
    mov QWORD [rsp+16], RBX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov QWORD [rsp+16], 91
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 2
; 参数1
    mov QWORD [rsp+16], 51
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 3
; 参数1
    mov QWORD [rsp+16], 56
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 4
; 参数1
    mov QWORD [rsp+16], 59
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 5
; 参数1
    mov QWORD [rsp+16], 53
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 6
; 参数1
    mov QWORD [rsp+16], 59
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov QWORD[rbp-72], 7
; 设置变量pos
    mov RAX, QWORD[rbp-72]
    mov RBX, RAX
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-64]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RCX, QWORD[rbp-48]
    mov QWORD [rsp+16], RCX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetInt
    mov QWORD[rbp-72], RBX
    add QWORD[rbp-72], RAX
; 设置变量pos
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-72]
    mov QWORD [rsp+8], RBX
; 参数1
    mov QWORD [rsp+16], 109
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov RAX, QWORD[rbp-72]
    mov RBX, 1
    mov QWORD[rbp-72], RAX
    add QWORD[rbp-72], RBX
; 设置变量pos
    sub rsp, 16; register args buffer
    mov RCX, QWORD[rbp-64]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_bufAndStr
; return值存入RAX
    jmp func_end_std_console_setFg256
    func_end_std_console_setFg256:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_setBg256 progbits alloc exec nowrite align=16
global std_console_setBg256
; ==============================
; Function: std_console_setBg256
std_console_setBg256:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    call std_console_shouldUseAdvanced
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_181
    if_181:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_console_setBg256
    end_if_181:
    call std_console_supports256Color
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_182
    if_182:
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-56], RAX
; 设置变量c16
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 15
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_183
    if_183:
    mov RAX, QWORD[rbp-56]
    mov RBX, 16
    mov QWORD[rbp-56], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-56]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-56], rdx
    pop RAX; 恢复RAX(左子结果)
; 设置变量c16
    end_if_183:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 8
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl end_if_184
    if_184:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-56]
    mov RCX, 8
    mov QWORD [rsp+0], RBX
    sub QWORD [rsp+0], RCX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_setBgBright
; return值存入RAX
    jmp func_end_std_console_setBg256
    end_if_184:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_setBg
; return值存入RAX
    jmp func_end_std_console_setBg256
    end_if_182:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 32
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_bufNew
    mov QWORD[rbp-64], RAX
; 设置变量buf
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RBX, QWORD[rel __global_std_console_ESC]
    mov QWORD [rsp+16], RBX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov QWORD [rsp+16], 91
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 2
; 参数1
    mov QWORD [rsp+16], 52
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 3
; 参数1
    mov QWORD [rsp+16], 56
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 4
; 参数1
    mov QWORD [rsp+16], 59
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 5
; 参数1
    mov QWORD [rsp+16], 53
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 6
; 参数1
    mov QWORD [rsp+16], 59
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov QWORD[rbp-72], 7
; 设置变量pos
    mov RAX, QWORD[rbp-72]
    mov RBX, RAX
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-64]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RCX, QWORD[rbp-48]
    mov QWORD [rsp+16], RCX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetInt
    mov QWORD[rbp-72], RBX
    add QWORD[rbp-72], RAX
; 设置变量pos
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rbp-64]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-72]
    mov QWORD [rsp+8], RBX
; 参数1
    mov QWORD [rsp+16], 109
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov RAX, QWORD[rbp-72]
    mov RBX, 1
    mov QWORD[rbp-72], RAX
    add QWORD[rbp-72], RBX
; 设置变量pos
    sub rsp, 16; register args buffer
    mov RCX, QWORD[rbp-64]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_bufAndStr
; return值存入RAX
    jmp func_end_std_console_setBg256
    func_end_std_console_setBg256:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_clearScreen progbits alloc exec nowrite align=16
global std_console_clearScreen
; ==============================
; Function: std_console_clearScreen
std_console_clearScreen:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 74
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_writeEscCSI
; return值存入RAX
    jmp func_end_std_console_clearScreen
    func_end_std_console_clearScreen:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_sixelBegin progbits alloc exec nowrite align=16
global std_console_sixelBegin
; ==============================
; Function: std_console_sixelBegin
std_console_sixelBegin:
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
    call std_console_shouldUseAdvanced
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_185
    call std_console_supportsSixel
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_185
    jne end_if_185
    if_185:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_console_sixelBegin
    end_if_185:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 128
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_bufNew
    mov QWORD[rbp-72], RAX
; 设置变量buf
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RAX, QWORD[rel __global_std_console_ESC]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov QWORD [rsp+16], 80
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 2
; 参数1
    mov QWORD [rsp+16], 48
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 3
; 参数1
    mov QWORD [rsp+16], 59
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 4
; 参数1
    mov QWORD [rsp+16], 48
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 5
; 参数1
    mov QWORD [rsp+16], 59
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 6
; 参数1
    mov QWORD [rsp+16], 48
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 7
; 参数1
    mov QWORD [rsp+16], 59
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 8
; 参数1
    mov QWORD [rsp+16], 48
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 9
; 参数1
    mov QWORD [rsp+16], 113
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 10
; 参数1
    mov QWORD [rsp+16], 34
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 11
; 参数1
    mov QWORD [rsp+16], 49
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 12
; 参数1
    mov QWORD [rsp+16], 59
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 13
; 参数1
    mov QWORD [rsp+16], 49
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 14
; 参数1
    mov QWORD [rsp+16], 59
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov QWORD[rbp-80], 15
; 设置变量pos
    mov RAX, QWORD[rbp-80]
    mov RBX, RAX
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-80]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RCX, QWORD[rbp-48]
    mov QWORD [rsp+16], RCX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetInt
    mov QWORD[rbp-80], RBX
    add QWORD[rbp-80], RAX
; 设置变量pos
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-80]
    mov QWORD [rsp+8], RCX
; 参数1
    mov QWORD [rsp+16], 59
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov RAX, QWORD[rbp-80]
    mov RBX, 1
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量pos
    mov RAX, QWORD[rbp-80]
    mov RBX, RAX
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-80]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RCX, QWORD[rbp-56]
    mov QWORD [rsp+16], RCX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetInt
    mov QWORD[rbp-80], RBX
    add QWORD[rbp-80], RAX
; 设置变量pos
    sub rsp, 32; register args buffer
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-80]
    mov QWORD [rsp+8], RCX
; 参数1
    mov QWORD [rsp+16], 114
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    mov RAX, QWORD[rbp-80]
    mov RBX, 1
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量pos
    sub rsp, 16; register args buffer
    mov RCX, QWORD[rbp-72]
    mov QWORD [rsp+0], RCX
; 参数0
    mov RCX, QWORD[rbp-80]
    mov QWORD [rsp+8], RCX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_bufAndStr
; return值存入RAX
    jmp func_end_std_console_sixelBegin
    func_end_std_console_sixelBegin:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_sixelData progbits alloc exec nowrite align=16
global std_console_sixelData
; ==============================
; Function: std_console_sixelData
std_console_sixelData:
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
    call std_console_shouldUseAdvanced
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_186
    call std_console_supportsSixel
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_186
    jne end_if_186
    if_186:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_console_sixelData
    end_if_186:
    sub rsp, 32; register args buffer
    mov RBX, QWORD[rel __global_std_console_STDOUT_FD]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+16], RBX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_syscall_write
; return值存入RAX
    jmp func_end_std_console_sixelData
    func_end_std_console_sixelData:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_sixelEnd progbits alloc exec nowrite align=16
global std_console_sixelEnd
; ==============================
; Function: std_console_sixelEnd
std_console_sixelEnd:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    call std_console_shouldUseAdvanced
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_187
    call std_console_supportsSixel
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_187
    jne end_if_187
    if_187:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_console_sixelEnd
    end_if_187:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 4
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_bufNew
    mov QWORD[rbp-48], RAX
; 设置变量buf
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RAX, QWORD[rel __global_std_console_ESC]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov QWORD [rsp+16], 92
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_bufSetByte
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov QWORD [rsp+8], 2
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_console_bufAndStr
; return值存入RAX
    jmp func_end_std_console_sixelEnd
    func_end_std_console_sixelEnd:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_detectAllCaps progbits alloc exec nowrite align=16
global std_console_detectAllCaps
; ==============================
; Function: std_console_detectAllCaps
std_console_detectAllCaps:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov RAX, QWORD[rel __global_std_console_gTermDetected]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_188
    if_188:
    jmp func_end_std_console_detectAllCaps
    end_if_188:
    mov QWORD[rel __global_std_console_g256Color], 1
; 设置变量g256Color
    mov QWORD[rel __global_std_console_gTrueColor], -1
; 设置变量gTrueColor
    mov QWORD[rel __global_std_console_gMouse], -1
; 设置变量gMouse
    mov QWORD[rel __global_std_console_gSixel], -1
; 设置变量gSixel
    mov QWORD[rel __global_std_console_gTermDetected], 1
; 设置变量gTermDetected
    func_end_std_console_detectAllCaps:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_supportsTrueColor progbits alloc exec nowrite align=16
global std_console_supportsTrueColor
; ==============================
; Function: std_console_supportsTrueColor
std_console_supportsTrueColor:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov RAX, QWORD[rel __global_std_console_gColorMode]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_189
    if_189:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_console_supportsTrueColor
    end_if_189:
    mov RAX, QWORD[rel __global_std_console_gColorMode]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_190
    mov RAX, QWORD[rel __global_std_console_gColorMode]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_190
    jne end_if_190
    if_190:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_console_supportsTrueColor
    end_if_190:
    call std_console_detectAllCaps
    mov RAX, QWORD[rel __global_std_console_gTrueColor]
; return值存入RAX
    jmp func_end_std_console_supportsTrueColor
    func_end_std_console_supportsTrueColor:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_supports256Color progbits alloc exec nowrite align=16
global std_console_supports256Color
; ==============================
; Function: std_console_supports256Color
std_console_supports256Color:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov RAX, QWORD[rel __global_std_console_gColorMode]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_191
    mov RAX, QWORD[rel __global_std_console_gColorMode]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je if_191
    jne end_if_191
    if_191:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_console_supports256Color
    end_if_191:
    mov RAX, QWORD[rel __global_std_console_gColorMode]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_192
    if_192:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_console_supports256Color
    end_if_192:
    call std_console_detectAllCaps
    mov RAX, QWORD[rel __global_std_console_g256Color]
; return值存入RAX
    jmp func_end_std_console_supports256Color
    func_end_std_console_supports256Color:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_supportsMouse progbits alloc exec nowrite align=16
global std_console_supportsMouse
; ==============================
; Function: std_console_supportsMouse
std_console_supportsMouse:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov RAX, QWORD[rel __global_std_console_gMouseMode]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_193
    if_193:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_console_supportsMouse
    end_if_193:
    mov RAX, QWORD[rel __global_std_console_gMouseMode]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_194
    if_194:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_console_supportsMouse
    end_if_194:
    call std_console_detectAllCaps
    mov RAX, QWORD[rel __global_std_console_gMouse]
; return值存入RAX
    jmp func_end_std_console_supportsMouse
    func_end_std_console_supportsMouse:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_supportsSixel progbits alloc exec nowrite align=16
global std_console_supportsSixel
; ==============================
; Function: std_console_supportsSixel
std_console_supportsSixel:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov RAX, QWORD[rel __global_std_console_gSixelMode]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_195
    if_195:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_console_supportsSixel
    end_if_195:
    mov RAX, QWORD[rel __global_std_console_gSixelMode]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_196
    if_196:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_console_supportsSixel
    end_if_196:
    call std_console_detectAllCaps
    mov RAX, QWORD[rel __global_std_console_gSixel]
; return值存入RAX
    jmp func_end_std_console_supportsSixel
    func_end_std_console_supportsSixel:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_console_shouldUseAdvanced progbits alloc exec nowrite align=16
global std_console_shouldUseAdvanced
; ==============================
; Function: std_console_shouldUseAdvanced
std_console_shouldUseAdvanced:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov RAX, QWORD[rel __global_std_console_gAdvancedEnabled]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_197
    if_197:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_console_shouldUseAdvanced
    end_if_197:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_console_shouldUseAdvanced
    func_end_std_console_shouldUseAdvanced:
    add rsp, 88; 清理局部变量 + 对齐
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
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov EBX, DWORD[rel __global_std_console_STDOUT]
    mov QWORD [rsp+0], RBX
; 参数0
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
; return值存入RAX
    jmp func_end_std_console_print
    func_end_std_console_print:
    add rsp, 104; 清理局部变量 + 对齐
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
    jne end_if_198
    if_198:
    jmp func_end_std_slices_push__T__Arg
    end_if_198:
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
    jne end_if_199
    if_199:
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
    end_if_199:
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl end_if_200
    if_200:
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
    end_if_200:
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
    jg end_if_201
    if_201:
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
; return值存入RAX
    jmp func_end_std_slices_grow__T__Arg
    end_if_201:
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
    jge else_if_202
    if_202:
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
    jmp end_if_202
    else_if_202:
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
    end_if_202:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_203
    if_203:
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-104], RAX
; 设置变量newCap
    end_if_203:
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
    mov rdi, rax
    mov rax, 60
    syscall

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
    str_1 db `x`, 0
    str_1_len equ $ - str_1
    str_2 db `y`, 0
    str_2_len equ $ - str_2
    str_3 db `int`, 0
    str_3_len equ $ - str_3
    str_4 db `:`, 0
    str_4_len equ $ - str_4
    str_5 db `\n`, 0
    str_5_len equ $ - str_5
