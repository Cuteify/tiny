section .bss
    __global_std_memory_gFreeHeads resq 1
    __global_std_memory_gLeaks resq 1
section .data
    __global_std_os_STDOUT dd 1
    __global_std_os_STDERR dd 2
    __global_std_os_STDIN dd 0
    __global_std_os_ENOENT dq 2
    __global_std_os_EACCES dq 13
    __global_std_os_EEXIST dq 17
    __global_std_os_ENOTDIR dq 20
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
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD[rbp-48], 0
; 设置变量failures
    mov EAX, DWORD[rel __global_std_os_STDOUT]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_1
    if_1:
    mov RAX, QWORD[rbp-48]
    mov RBX, 1
    mov QWORD[rbp-48], RAX
    add QWORD[rbp-48], RBX
; 设置变量failures
    end_if_1:
    mov EAX, DWORD[rel __global_std_os_STDERR]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_2
    if_2:
    mov RAX, QWORD[rbp-48]
    mov RBX, 1
    mov QWORD[rbp-48], RAX
    add QWORD[rbp-48], RBX
; 设置变量failures
    end_if_2:
    mov EAX, DWORD[rel __global_std_os_STDIN]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_3
    if_3:
    mov RAX, QWORD[rbp-48]
    mov RBX, 1
    mov QWORD[rbp-48], RAX
    add QWORD[rbp-48], RBX
; 设置变量failures
    end_if_3:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 2
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_os_isNotExist
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_4
    if_4:
    mov RAX, QWORD[rbp-48]
    mov RBX, 1
    mov QWORD[rbp-48], RAX
    add QWORD[rbp-48], RBX
; 设置变量failures
    end_if_4:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 17
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_os_isExist
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_5
    if_5:
    mov RAX, QWORD[rbp-48]
    mov RBX, 1
    mov QWORD[rbp-48], RAX
    add QWORD[rbp-48], RBX
; 设置变量failures
    end_if_5:
    lea R10, [rbp-112]; 大值返回槽地址
    call std_os_getcwd
    mov RAX, QWORD [RBP-112]
    mov QWORD [rbp-72+0], RAX
    mov RAX, QWORD [RBP-112+8]
    mov QWORD [rbp-72+8], RAX
    mov RAX, QWORD [RBP-112+16]
    mov QWORD [rbp-72+16], RAX
; 设置变量cwd
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_6
    if_6:
    mov RAX, QWORD[rbp-48]
    mov RBX, 1
    mov QWORD[rbp-48], RAX
    add QWORD[rbp-48], RBX
; 设置变量failures
    end_if_6:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_7
    if_7:
    mov RAX, 42
; return值存入RAX
    jmp func_end_main
    end_if_7:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_main
    func_end_main:
    add rsp, 120; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_os_getcwd progbits alloc exec nowrite align=16
global std_os_getcwd
; ==============================
; Function: std_os_getcwd
std_os_getcwd:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-72], R10; 保存返回槽地址
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 4096
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-48], RAX
; 设置变量buf
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 4096
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_syscall_getcwd
    mov QWORD[rbp-56], RAX
; 设置变量n
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_8
    if_8:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    mov QWORD QWORD[rbp-96], 0
    mov QWORD [rbp-96+8], 0
    mov QWORD [rbp-96+16], 0
; return值存入返回槽
    mov R10, QWORD [rbp-72]; 恢复返回槽地址
    mov RAX, QWORD [rbp-96]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-88]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10+16], RAX
    jmp func_end_std_os_getcwd
    end_if_8:
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-64], RAX
; 设置变量len
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+16], RAX
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
    jmp func_end_std_os_getcwd
    func_end_std_os_getcwd:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_os_isExist progbits alloc exec nowrite align=16
global std_os_isExist
; ==============================
; Function: std_os_isExist
std_os_isExist:
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
    mov RBX, QWORD[rel __global_std_os_EEXIST]
    cmp RAX, RBX
    sete al
    movzx RAX, al
; return值存入RAX
    jmp func_end_std_os_isExist
    func_end_std_os_isExist:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_os_isNotExist progbits alloc exec nowrite align=16
global std_os_isNotExist
; ==============================
; Function: std_os_isNotExist
std_os_isNotExist:
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
    mov RBX, QWORD[rel __global_std_os_ENOENT]
    cmp RAX, RBX
    sete al
    movzx RAX, al
; return值存入RAX
    jmp func_end_std_os_isNotExist
    func_end_std_os_isNotExist:
    add rsp, 88; 清理局部变量 + 对齐
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


section .text.std_syscall_getcwd progbits alloc exec nowrite align=16
global std_syscall_getcwd
; ==============================
; Function: std_syscall_getcwd
std_syscall_getcwd:
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
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], 79
; 参数0
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+16], RBX
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
    jmp func_end_std_syscall_getcwd
    func_end_std_syscall_getcwd:
    add rsp, 104; 清理局部变量 + 对齐
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
    je end_if_9
    if_9:
    jmp func_end_std_memory_initFreeHeads
    end_if_9:
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
    jnb end_if_10
    if_10:
    jmp func_end_std_memory_initFreeHeads
    end_if_10:
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
    jne end_if_11
    if_11:
    mov RAX, 32
; return值存入RAX
    jmp func_end_std_memory_blkSizeOfTiny
    end_if_11:
    mov QWORD[rbp-56], 32
; 设置变量s
    mov QWORD[rbp-64], 0
; 设置变量i




    for_1: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_1_end
    for_1_body:


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
    jnb end_if_12
    if_12:
    mov QWORD[rbp-72], 16
; 设置变量step
    end_if_12:
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
    for_1_continue:


    jmp for_1; for循环
    for_1_end: ; for循环结束
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
    jne end_if_13
    if_13:
    mov RAX, 2048
; return值存入RAX
    jmp func_end_std_memory_blkSizeOfSmall
    end_if_13:
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




    for_2: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_2_end
    for_2_body:


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
    for_2_continue:


    jmp for_2; for循环
    for_2_end: ; for循环结束
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
    jnbe end_if_14
    if_14:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOfTiny
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf
    end_if_14:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 35
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_15
    if_15:
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
    end_if_15:
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
    jnbe end_if_16
    if_16:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_slotOfTiny
    end_if_16:
    mov QWORD[rbp-56], 32
; 设置变量s
    mov QWORD[rbp-64], 0
; 设置变量cls




    for_3: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 33
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
    jnb end_if_17
    if_17:
    mov QWORD[rbp-72], 16
; 设置变量step
    end_if_17:
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
    jb end_if_18
    if_18:
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_slotOfTiny
    end_if_18:
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-56], RAX
; 设置变量s
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量cls
    for_3_continue:


    jmp for_3; for循环
    for_3_end: ; for循环结束
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
    jnbe end_if_19
    if_19:
    mov RAX, 34
; return值存入RAX
    jmp func_end_std_memory_slotOfSmall
    end_if_19:
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
    jnbe end_if_20
    if_20:
    mov RAX, 36
; return值存入RAX
    jmp func_end_std_memory_slotOfMiddle
    end_if_20:
    mov QWORD[rbp-56], 4096
; 设置变量s
    mov QWORD[rbp-64], 0
; 设置变量cls




    for_4: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 23
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
    jb end_if_21
    if_21:
    mov RBX, QWORD[rbp-64]
    mov RAX, 36
    add RAX, RBX
    mov RBX, 1
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_slotOfMiddle
    end_if_21:
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-56], RAX
; 设置变量s
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量cls
    for_4_continue:


    jmp for_4; for循环
    for_4_end: ; for循环结束
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
    jnbe end_if_22
    if_22:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfTiny
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_22:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_SMALL_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_23
    if_23:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfSmall
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_23:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_24
    if_24:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfMiddle
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_24:
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
    jb end_if_25
    if_25:
    mov RAX, 60
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_25:




    for_5: ; for循环开始
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_5_end
    for_5_body:


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
    jnbe end_if_26
    if_26:
    mov RAX, QWORD[rbp-56]
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_26:
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD[rbp-56], RAX
    sub QWORD[rbp-56], RBX
; 设置变量cls
    for_5_continue:


    jmp for_5; for循环
    for_5_end: ; for循环结束
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
    jbe end_if_27
    if_27:
    mov RAX, 60
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_27:
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
    jb end_if_28
    if_28:
    jmp func_end_std_memory_insertFreeList
    end_if_28:
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
    je end_if_29
    if_29:
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
    end_if_29:
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
    jb end_if_30
    if_30:
    jmp func_end_std_memory_removeFreeList
    end_if_30:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je else_if_31
    if_31:
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
    jmp end_if_31
    else_if_31:
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
    end_if_31:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_32
    if_32:
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
    end_if_32:
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
    jnb end_if_33
    if_33:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_commit
    end_if_33:
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




    for_6: ; for循环开始
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-56]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe for_6_end
    for_6_body:


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
    je end_if_34
    if_34:
    mov RBX, QWORD[rbp-112]
    mov RDX, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD[rbp-112], RBX
    or QWORD[rbp-112], RDX
; 设置变量flags
    end_if_34:
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
    je end_if_35
    if_35:
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
    end_if_35:
    mov RBX, QWORD[rbp-96]
    mov QWORD[rbp-88], RBX
; 设置变量prev
    mov RDX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-96], RDX
    add QWORD[rbp-96], RBX
; 设置变量p
    for_6_continue:


    jmp for_6; for循环
    for_6_end: ; for循环结束
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
    jnbe end_if_36
    if_36:
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
    je end_if_37
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
    je end_if_37
    if_37:
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
    end_if_37:
    end_if_36:
    mov RAX, QWORD[rbp-56]
    mov RDX, QWORD[rel __global_std_memory_PREV_FREE]
    and RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je else_if_38
    if_38:
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
    jmp end_if_38
    else_if_38:
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
    end_if_38:
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
    jnbe end_if_39
    if_39:
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
    je end_if_40
    if_40:
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
    end_if_40:
    end_if_39:
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
    jnb end_if_41
    if_41:
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-56], RAX
; 设置变量req
    end_if_41:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_LARGE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_42
    if_42:
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
    jnb end_if_43
    if_43:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_43:
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
    end_if_42:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_44
    if_44:
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
    jnb end_if_45
    if_45:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_45:
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
    jnbe end_if_46
    if_46:
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
    je end_if_47
    if_47:
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
    end_if_47:
    end_if_46:
    mov RAX, QWORD[rbp-120]
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RDX
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_44:
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
    jne end_if_48
    if_48:
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
    jne end_if_49
    if_49:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_49:
    end_if_48:
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
    je end_if_50
    if_50:
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
    end_if_50:
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
    jnb end_if_51
    if_51:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOf
    mov QWORD[rbp-208], RAX
; 设置变量minBlk
    end_if_51:
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
    jb else_if_52
    if_52:
    mov RAX, QWORD[rbp-176]
    mov QWORD[rbp-216], RAX
; 设置变量useSize
    mov RDX, QWORD[rbp-200]
    mov RSI, QWORD[rbp-176]
    mov QWORD[rbp-224], RDX
    sub QWORD[rbp-224], RSI
; 设置变量rem
    jmp end_if_52
    else_if_52:
    mov RAX, QWORD[rbp-200]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-176]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_53
    if_53:
    mov RAX, QWORD[rbp-176]
    mov QWORD[rbp-216], RAX
; 设置变量useSize
    end_if_53:
    end_if_52:
    mov RAX, QWORD[rbp-224]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-208]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_54
    if_54:
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
    jnbe end_if_55
    if_55:
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
    je end_if_56
    if_56:
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
    end_if_56:
    end_if_55:
    jmp end_if_54
    else_if_54:
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
    end_if_54:
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
    jnbe end_if_57
    if_57:
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
    je end_if_58
    if_58:
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
    end_if_58:
    end_if_57:
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
    jbe end_if_59
    if_59:
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
    jne end_if_60
    if_60:
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
    end_if_60:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_freeAt
    end_if_59:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_61
    if_61:
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
    jne end_if_62
    if_62:
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
    end_if_62:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_freeAt
    end_if_61:
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
    jne end_if_63
    if_63:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_free
    end_if_63:
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
    je end_if_64
    if_64:
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
    end_if_64:
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
    jne end_if_65
    if_65:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeSlot
    end_if_65:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
; condition
    test RAX, RAX
    jz end_if_66
    if_66:
    mov RAX, 0
    mov RBX, QWORD[rbp-48]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeSlot
    end_if_66:
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
    jne end_if_67
    if_67:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_67:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_68
    if_68:
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
    end_if_68:
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
    jnbe end_if_69
    if_69:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_69:
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
    jnbe end_if_70
    if_70:
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
    je end_if_71
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
    je end_if_71
    if_71:
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
    jb end_if_72
    if_72:
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
    jnbe end_if_73
    if_73:
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
    je end_if_74
    if_74:
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
    end_if_74:
    end_if_73:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_72:
    end_if_71:
    end_if_70:
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
    jne end_if_75
    if_75:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_75:
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
    jbe end_if_76
    if_76:
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-144], RAX
; 设置变量copySize
    end_if_76:
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




    for_7: ; for循环开始
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_7_end
    for_7_body:


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
    for_7_continue:


    jmp for_7; for循环
    for_7_end: ; for循环结束
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, QWORD[rbp-72]
    imul RAX, RBX
    mov RBX, QWORD[rbp-64]
    mov QWORD[rbp-104], RBX
    sub QWORD[rbp-104], RAX
; 设置变量rem
    mov QWORD[rbp-112], 0
; 设置变量j




    for_8: ; for循环开始
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_8_end
    for_8_body:


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
    for_8_continue:


    jmp for_8; for循环
    for_8_end: ; for循环结束
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
    jnb end_if_77
    if_77:
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-64], RAX
; 设置变量req
    end_if_77:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_LARGE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_78
    if_78:
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
    jnb end_if_79
    if_79:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_79:
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
    end_if_78:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_80
    if_80:
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
    jnb end_if_81
    if_81:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_81:
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
    jnbe end_if_82
    if_82:
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
    je end_if_83
    if_83:
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
    end_if_83:
    end_if_82:
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
    end_if_80:
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
    jne end_if_84
    if_84:
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
    jne end_if_85
    if_85:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_85:
    end_if_84:
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
    je end_if_86
    if_86:
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
    end_if_86:
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
    jnbe end_if_87
    if_87:
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
    je end_if_88
    if_88:
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
    end_if_88:
    end_if_87:
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
    jne end_if_89
    if_89:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeRC
    end_if_89:
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
    jne end_if_90
    if_90:
    jmp func_end_std_memory_rcInc
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
    jne end_if_91
    if_91:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcDec
    end_if_91:
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
    jne end_if_92
    if_92:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcDec
    end_if_92:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_93
    if_93:
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
    end_if_93:
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
    je end_if_94
    if_94:
    jmp func_end_std_memory_initLeakTracker
    end_if_94:
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
    jnb end_if_95
    if_95:
    jmp func_end_std_memory_initLeakTracker
    end_if_95:
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
    jne end_if_96
    if_96:
    jmp func_end_std_memory_trackAlloc
    end_if_96:
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
    jnb end_if_97
    if_97:
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
    end_if_97:
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
    jne end_if_98
    if_98:
    jmp func_end_std_memory_trackFree
    end_if_98:
    call std_memory_initLeakTracker
    mov RAX, QWORD[rel __global_std_memory_gFreeCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gFreeCount], RAX
    add QWORD[rel __global_std_memory_gFreeCount], RBX
; 设置变量gFreeCount
    mov QWORD[rbp-56], 0
; 设置变量i




    for_9: ; for循环开始
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_gLeakCount]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_9_end
    for_9_body:


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
    jne end_if_99
    if_99:
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
    end_if_99:
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD[rbp-56], RAX
    add QWORD[rbp-56], RBX
; 设置变量i
    for_9_continue:


    jmp for_9; for循环
    for_9_end: ; for循环结束
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
    jnb end_if_100
    if_100:
    mov RAX, QWORD[rbp-120]
    mov QWORD[rbp-128], RAX
; 设置变量minLen
    end_if_100:
    mov QWORD[rbp-136], 0
; 设置变量i




    for_10: ; for循环开始
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-128]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_10_end
    for_10_body:


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
    jnb end_if_101
    if_101:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_101:
    mov RAX, QWORD[rbp-152]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-168]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_102
    if_102:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_102:
    mov RAX, QWORD[rbp-136]
    mov RBX, 1
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量i
    for_10_continue:


    jmp for_10; for循环
    for_10_end: ; for循环结束
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_103
    if_103:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_103:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_104
    if_104:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_104:
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
    jne end_if_105
    if_105:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_eq
    end_if_105:
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
    je end_if_106
    if_106:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_ne
    end_if_106:
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




    for_11: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_11_end
    for_11_body:


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
    for_11_continue:


    jmp for_11; for循环
    for_11_end: ; for循环结束
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
    jge else_if_107
    if_107:
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
    jmp end_if_107
    else_if_107:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64
    mov QWORD[rbp-65], RAX
; 设置变量num
    end_if_107:
    mov QWORD[rbp-73], 1
; 设置变量digits
    mov RAX, QWORD[rbp-65]
    mov QWORD[rbp-81], RAX
; 设置变量tmp




    for_12: ; for循环开始
    mov RAX, QWORD[rbp-81]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb for_12_end
    for_12_body:


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
    for_12_continue:


    jmp for_12; for循环
    for_12_end: ; for循环结束
    mov RAX, QWORD[rbp-73]
    mov QWORD[rbp-89], RAX
; 设置变量total
    movzx RAX, BYTE[rbp-57]
; condition
    test RAX, RAX
    jz end_if_108
    if_108:
    mov RAX, QWORD[rbp-89]
    mov RBX, 1
    mov QWORD[rbp-89], RAX
    add QWORD[rbp-89], RBX
; 设置变量total
    end_if_108:
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
    jne else_if_109
    if_109:
    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-121], RAX
; 设置变量_p14
    mov RAX, 48
    mov RBX, QWORD[rbp-121]
    mov BYTE [RBX], al
; expression statement
    jmp end_if_109
    else_if_109:
    mov QWORD[rbp-129], 0
; 设置变量i




    for_13: ; for循环开始
    mov RAX, QWORD[rbp-113]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_13_end
    for_13_body:


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
    jnb else_if_110
    if_110:
    mov RAX, QWORD[rbp-137]
    mov RBX, 48
    mov QWORD[rbp-145], RAX
    add QWORD[rbp-145], RBX
; 设置变量ch
    jmp end_if_110
    else_if_110:
    mov RAX, QWORD[rbp-137]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 36
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_111
    if_111:
    mov RAX, QWORD[rbp-137]
    mov RBX, 97
    add RAX, RBX
    mov RBX, 10
    mov QWORD[rbp-145], RAX
    sub QWORD[rbp-145], RBX
; 设置变量ch
    jmp end_if_111
    else_if_111:
    mov RAX, QWORD[rbp-137]
    mov RBX, 65
    add RAX, RBX
    mov RBX, 36
    mov QWORD[rbp-145], RAX
    sub QWORD[rbp-145], RBX
; 设置变量ch
    end_if_111:
    end_if_110:
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
    for_13_continue:


    jmp for_13; for循环
    for_13_end: ; for循环结束
    end_if_109:
    movzx RAX, BYTE[rbp-57]
; condition
    test RAX, RAX
    jz end_if_112
    if_112:
    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-161], RAX
; 设置变量_p16
    mov RAX, 45
    mov RBX, QWORD[rbp-161]
    mov BYTE [RBX], al
; expression statement
    end_if_112:
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
    jne end_if_113
    if_113:
    mov BYTE[rbp-121], 1
; 设置变量neg
    mov QWORD[rbp-120], 1
; 设置变量i
    end_if_113:
    mov QWORD[rbp-145], 0
; 设置变量val
    mov BYTE[rbp-146], 0
; 设置变量bad




    for_14: ; for循环开始
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-112]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_14_end
    for_14_body:


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
    jb else_if_114
    and_mid_3:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 57
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_114
    if_114:
    mov RAX, QWORD[rbp-162]
    mov RBX, 48
    mov QWORD[rbp-170], RAX
    sub QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_114
    else_if_114:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 97
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_115
    and_mid_4:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 122
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_115
    if_115:
    mov RAX, QWORD[rbp-162]
    mov RBX, 97
    sub RAX, RBX
    mov RBX, 10
    mov QWORD[rbp-170], RAX
    add QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_115
    else_if_115:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_116
    and_mid_5:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 90
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_116
    if_116:
    mov RAX, QWORD[rbp-162]
    mov RBX, 65
    sub RAX, RBX
    mov RBX, 36
    mov QWORD[rbp-170], RAX
    add QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_116
    else_if_116:
    mov BYTE[rbp-146], 1
; 设置变量bad
    end_if_116:
    end_if_115:
    end_if_114:
    movzx RAX, BYTE[rbp-146]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_117
    if_117:
    mov RAX, QWORD[rbp-145]
    mov RBX, QWORD[rbp-72]
    imul RAX, RBX
    mov RBX, QWORD[rbp-170]
    mov QWORD[rbp-145], RAX
    add QWORD[rbp-145], RBX
; 设置变量val
    end_if_117:
    mov RAX, QWORD[rbp-120]
    mov RBX, 1
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量i
    for_14_continue:


    jmp for_14; for循环
    for_14_end: ; for循环结束
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
    jz end_if_118
    if_118:
    mov RBX, QWORD[rbp-178]
    mov QWORD[rbp-178], 0
    sub QWORD[rbp-178], RBX
; 设置变量r
    end_if_118:
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
