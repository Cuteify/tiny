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
    __global_std_memory_ptrSize dq 8
    __global_std_memory_gAllocCount dq 0
    __global_std_memory_gFreeCount dq 0
    __global_std_memory_gLeakCount dq 0
section .text
global _start

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
    sub rsp, 88; 分配局部变量空间(88字节, 含对齐)
    mov QWORD[rbp-48], 2
; 设置变量x
    mov RAX, QWORD[rbp-48]
; switch target
    mov RCX, 1
; case value
    mov R12, RAX; 保存switch目标到callee-save
    cmp RAX, RCX
    mov RAX, R12; 恢复switch目标
    je case_switch_1_0
    mov RCX, 2
; case value
    mov R12, RAX; 保存switch目标到callee-save
    cmp RAX, RCX
    mov RAX, R12; 恢复switch目标
    je case_switch_1_1
    jmp switch_default_switch_1
    case_switch_1_0:
    mov RAX, 10
; return值存入RAX
    jmp func_end_main
    jmp switch_end_switch_1
    case_switch_1_1:
    mov RAX, 20
; return值存入RAX
    jmp func_end_main
    jmp switch_end_switch_1
    switch_default_switch_1:
    mov RAX, 30
; return值存入RAX
    jmp func_end_main
    switch_end_switch_1:
    mov RAX, 0
; return值存入RAX
    jmp func_end_main
    func_end_main:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


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
    mov RAX, QWORD [rbp-64+0]
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
    mov RAX, QWORD [rbp-64+0]
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
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
    mov EAX, DWORD[rbp-68]
    mov RBX, RAX
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_1
    mov QWORD [rsp+0+8], 2
    mov QWORD [rsp+0+16], 2
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring
    mov QWORD [rsp+8], RAX
; 参数1
    mov QWORD [rsp+16], 1
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_syscall_write
    mov RCX, RAX
    mov RAX, RBX
    add RAX, RCX
; return值存入RAX
    jmp func_end_std_builtin_println
    func_end_std_builtin_println:
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




    for_1: ; for循环开始
    mov RAX, QWORD[rbp-68]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_1_end
    for_1_body:


    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-68]
    mov QWORD[rbp-76], RAX
    add QWORD[rbp-76], RBX
; unsafe.cast
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


    jmp for_1; for循环
    for_1_end: ; for循环结束
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
    je end_if_1
    if_1:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_maps_bytesEq
    end_if_1:
    mov QWORD[rbp-80], 0
; 设置变量i




    for_2: ; for循环开始
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_2_end
    for_2_body:


    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-80]
    mov QWORD[rbp-88], RAX
    add QWORD[rbp-88], RBX
; unsafe.cast
; 设置变量ap
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-80]
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RBX
; unsafe.cast
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
    je end_if_2
    if_2:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_maps_bytesEq
    end_if_2:
    mov RAX, QWORD[rbp-80]
    mov RBX, 1
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量i


    jmp for_2; for循环
    for_2_end: ; for循环结束
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
    je end_if_3
    if_3:
    jmp func_end_std_memory_initFreeHeads
    end_if_3:
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
    jnb end_if_4
    if_4:
    jmp func_end_std_memory_initFreeHeads
    end_if_4:
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
    jne end_if_5
    if_5:
    mov RAX, 32
; return值存入RAX
    jmp func_end_std_memory_blkSizeOfTiny
    end_if_5:
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
    jnb end_if_6
    if_6:
    mov QWORD[rbp-72], 16
; 设置变量step
    end_if_6:
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


    jmp for_3; for循环
    for_3_end: ; for循环结束
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
    add RAX, RBX
    mov RBX, 1
    sub RAX, RBX
    mov RCX, QWORD[rel __global_std_memory_ptrSize]
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
    jne end_if_7
    if_7:
    mov RAX, 2048
; return值存入RAX
    jmp func_end_std_memory_blkSizeOfSmall
    end_if_7:
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
    jnbe end_if_8
    if_8:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOfTiny
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf
    end_if_8:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 35
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_9
    if_9:
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
    end_if_9:
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
    jnbe end_if_10
    if_10:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_slotOfTiny
    end_if_10:
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
    jnb end_if_11
    if_11:
    mov QWORD[rbp-72], 16
; 设置变量step
    end_if_11:
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
    jb end_if_12
    if_12:
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_slotOfTiny
    end_if_12:
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-56], RAX
; 设置变量s
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量cls


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
    jnbe end_if_13
    if_13:
    mov RAX, 34
; return值存入RAX
    jmp func_end_std_memory_slotOfSmall
    end_if_13:
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
    jnbe end_if_14
    if_14:
    mov RAX, 36
; return值存入RAX
    jmp func_end_std_memory_slotOfMiddle
    end_if_14:
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
    jb end_if_15
    if_15:
    mov RBX, QWORD[rbp-64]
    mov RAX, 36
    add RAX, RBX
    mov RBX, 1
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_slotOfMiddle
    end_if_15:
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-56], RAX
; 设置变量s
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    mov QWORD[rbp-64], RAX
    add QWORD[rbp-64], RBX
; 设置变量cls


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
    jnbe end_if_16
    if_16:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfTiny
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_16:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_SMALL_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_17
    if_17:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfSmall
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_17:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
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
    call std_memory_slotOfMiddle
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_18:
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
    jb end_if_19
    if_19:
    mov RAX, 60
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_19:




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
    jnbe end_if_20
    if_20:
    mov RAX, QWORD[rbp-56]
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_20:
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD[rbp-56], RAX
    sub QWORD[rbp-56], RBX
; 设置变量cls


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
    jbe end_if_21
    if_21:
    mov RAX, 60
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_21:
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
    jb end_if_22
    if_22:
    jmp func_end_std_memory_insertFreeList
    end_if_22:
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
    je end_if_23
    if_23:
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
    end_if_23:
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
    jb end_if_24
    if_24:
    jmp func_end_std_memory_removeFreeList
    end_if_24:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je else_if_25
    if_25:
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
    jmp end_if_25
    else_if_25:
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
    end_if_25:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_26
    if_26:
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
    end_if_26:
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
    jnb end_if_27
    if_27:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_commit
    end_if_27:
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
    je end_if_28
    if_28:
    mov RBX, QWORD[rbp-112]
    mov RDX, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD[rbp-112], RBX
    or QWORD[rbp-112], RDX
; 设置变量flags
    end_if_28:
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
    je end_if_29
    if_29:
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
    end_if_29:
    mov RBX, QWORD[rbp-96]
    mov QWORD[rbp-88], RBX
; 设置变量prev
    mov RDX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-56]
    mov QWORD[rbp-96], RDX
    add QWORD[rbp-96], RBX
; 设置变量p


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
    mov RCX, QWORD[rel __global_std_memory_ptrSize]
    add RAX, RCX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_30
    if_30:
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
    je end_if_31
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
    je end_if_31
    if_31:
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
    end_if_31:
    end_if_30:
    mov RAX, QWORD[rbp-56]
    mov RDX, QWORD[rel __global_std_memory_PREV_FREE]
    and RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je else_if_32
    if_32:
    mov RDX, QWORD[rbp-48]
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    jmp end_if_32
    else_if_32:
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
    end_if_32:
    mov RBX, QWORD[rbp-48]
    mov RDX, QWORD[rbp-64]
    mov QWORD[rbp-136], RBX
    add QWORD[rbp-136], RDX
; 设置变量nextAfter
    mov RAX, QWORD[rbp-136]
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_33
    if_33:
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
    je end_if_34
    if_34:
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
    end_if_34:
    end_if_33:
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
    mov RAX, QWORD[rel __global_std_memory_ptrSize]
    mov RBX, 2
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-56], RBX
    add QWORD[rbp-56], RAX
; 设置变量req
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    jnb end_if_35
    if_35:
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-56], RAX
; 设置变量req
    end_if_35:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_LARGE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_36
    if_36:
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD[rel __global_std_memory_ptrSize]
    add RBX, RAX
    mov RAX, 1
    sub RBX, RAX
    mov RCX, QWORD[rel __global_std_memory_ptrSize]
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
    jnb end_if_37
    if_37:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_37:
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_36:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_38
    if_38:
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD[rel __global_std_memory_ptrSize]
    add RBX, RAX
    mov RDX, 1
    sub RBX, RDX
    mov RDX, QWORD[rel __global_std_memory_ptrSize]
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
    jnb end_if_39
    if_39:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_39:
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-152]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_40
    if_40:
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
    je end_if_41
    if_41:
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
    end_if_41:
    end_if_40:
    mov RAX, QWORD[rbp-120]
    mov RDX, QWORD[rel __global_std_memory_ptrSize]
    add RAX, RDX
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_38:
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
    jne end_if_42
    if_42:
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
    jne end_if_43
    if_43:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_43:
    end_if_42:
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
    je end_if_44
    if_44:
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
    end_if_44:
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
    mov RDX, QWORD[rel __global_std_memory_ptrSize]
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
    jnb end_if_45
    if_45:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOf
    mov QWORD[rbp-208], RAX
; 设置变量minBlk
    end_if_45:
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
    jb else_if_46
    if_46:
    mov RAX, QWORD[rbp-176]
    mov QWORD[rbp-216], RAX
; 设置变量useSize
    mov RDX, QWORD[rbp-200]
    mov RSI, QWORD[rbp-176]
    mov QWORD[rbp-224], RDX
    sub QWORD[rbp-224], RSI
; 设置变量rem
    jmp end_if_46
    else_if_46:
    mov RAX, QWORD[rbp-200]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-176]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_47
    if_47:
    mov RAX, QWORD[rbp-176]
    mov QWORD[rbp-216], RAX
; 设置变量useSize
    end_if_47:
    end_if_46:
    mov RAX, QWORD[rbp-224]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-208]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_48
    if_48:
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
    mov RDX, QWORD[rel __global_std_memory_ptrSize]
    add RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-248]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_49
    if_49:
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
    je end_if_50
    if_50:
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
    end_if_50:
    end_if_49:
    jmp end_if_48
    else_if_48:
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
    end_if_48:
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
    mov RDX, QWORD[rel __global_std_memory_ptrSize]
    add RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-272]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_51
    if_51:
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
    je end_if_52
    if_52:
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
    end_if_52:
    end_if_51:
    mov RAX, QWORD[rbp-184]
    mov RDX, QWORD[rel __global_std_memory_ptrSize]
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
    jbe end_if_53
    if_53:
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
    jne end_if_54
    if_54:
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
    end_if_54:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_freeAt
    end_if_53:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_55
    if_55:
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
    jne end_if_56
    if_56:
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
    end_if_56:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_freeAt
    end_if_55:
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
    jne end_if_57
    if_57:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_free
    end_if_57:
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
    je end_if_58
    if_58:
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
    end_if_58:
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    jne end_if_59
    if_59:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeSlot
    end_if_59:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
; condition
    test RAX, RAX
    jz end_if_60
    if_60:
    mov RAX, 0
    mov RBX, QWORD[rbp-48]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeSlot
    end_if_60:
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
    jne end_if_61
    if_61:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_61:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_62
    if_62:
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
    end_if_62:
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    jnbe end_if_63
    if_63:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_63:
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
    mov RCX, QWORD[rel __global_std_memory_ptrSize]
    add RAX, RCX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_64
    if_64:
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
    je end_if_65
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
    je end_if_65
    if_65:
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
    jb end_if_66
    if_66:
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_67
    if_67:
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
    je end_if_68
    if_68:
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
    end_if_68:
    end_if_67:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_66:
    end_if_65:
    end_if_64:
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
    jne end_if_69
    if_69:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_69:
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    jbe end_if_70
    if_70:
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-144], RAX
; 设置变量copySize
    end_if_70:
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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


    mov RAX, QWORD[rel __global_std_memory_ptrSize]
    mov RBX, QWORD[rbp-80]
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-88], RBX
    add QWORD[rbp-88], RAX
; 设置变量dstP
    mov RAX, QWORD[rel __global_std_memory_ptrSize]
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


    jmp for_9; for循环
    for_9_end: ; for循环结束
    mov RAX, QWORD[rel __global_std_memory_ptrSize]
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


    mov RAX, QWORD[rel __global_std_memory_ptrSize]
    mov RCX, QWORD[rbp-72]
    imul RAX, RCX
    mov RBX, QWORD[rbp-48]
    add RBX, RAX
    mov RCX, QWORD[rbp-112]
    mov QWORD[rbp-120], RBX
    add QWORD[rbp-120], RCX
; 设置变量dstB
    mov RAX, QWORD[rel __global_std_memory_ptrSize]
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
    jne end_if_71
    if_71:
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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


    mov RAX, QWORD[rel __global_std_memory_ptrSize]
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


    jmp for_11; for循环
    for_11_end: ; for循环结束
    mov RAX, QWORD[rel __global_std_memory_ptrSize]
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


    mov RAX, QWORD[rel __global_std_memory_ptrSize]
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


    jmp for_12; for循环
    for_12_end: ; for循环结束
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_memset
    end_if_71:
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    mov RAX, QWORD[rel __global_std_memory_ptrSize]
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
    mov RAX, QWORD[rel __global_std_memory_ptrSize]
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
    jnb end_if_72
    if_72:
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-64], RAX
; 设置变量req
    end_if_72:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_LARGE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_73
    if_73:
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
    jnb end_if_74
    if_74:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_74:
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
    end_if_73:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_75
    if_75:
    mov RBX, QWORD[rbp-64]
    mov RAX, QWORD[rel __global_std_memory_ptrSize]
    add RBX, RAX
    mov RAX, 1
    sub RBX, RAX
    mov RDX, QWORD[rel __global_std_memory_ptrSize]
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
    jnb end_if_76
    if_76:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_76:
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
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-168]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_77
    if_77:
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
    je end_if_78
    if_78:
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
    end_if_78:
    end_if_77:
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
    end_if_75:
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
    jne end_if_79
    if_79:
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
    jne end_if_80
    if_80:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_80:
    end_if_79:
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
    je end_if_81
    if_81:
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
    end_if_81:
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
    mov RDX, QWORD[rel __global_std_memory_ptrSize]
    add RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-240]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_82
    if_82:
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
    je end_if_83
    if_83:
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
    end_if_83:
    end_if_82:
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
    jne end_if_84
    if_84:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeRC
    end_if_84:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
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
    jne end_if_85
    if_85:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeRCSlot
    end_if_85:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeRC
; condition
    test RAX, RAX
    jz end_if_86
    if_86:
    mov RAX, 0
    mov RBX, QWORD[rbp-48]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeRCSlot
    end_if_86:
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
    jne end_if_87
    if_87:
    jmp func_end_std_memory_rcInc
    end_if_87:
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
    jne end_if_88
    if_88:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcDec
    end_if_88:
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
    jne end_if_89
    if_89:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcDec
    end_if_89:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_90
    if_90:
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
    end_if_90:
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
    jne end_if_91
    if_91:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_rcGet
    end_if_91:
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
    jne end_if_92
    if_92:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcTryRelease
    end_if_92:
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
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcTryRelease
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
    jne end_if_94
    if_94:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_rcIsOne
    end_if_94:
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
    jne end_if_95
    if_95:
    jmp func_end_std_memory_rcSet
    end_if_95:
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
    jne end_if_96
    if_96:
    jmp func_end_std_memory_rcAdd
    end_if_96:
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
    jne end_if_97
    if_97:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcSub
    end_if_97:
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
    jnbe end_if_98
    if_98:
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
    end_if_98:
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
    je end_if_99
    if_99:
    jmp func_end_std_memory_initLeakTracker
    end_if_99:
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
    jnb end_if_100
    if_100:
    jmp func_end_std_memory_initLeakTracker
    end_if_100:
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
    jne end_if_101
    if_101:
    jmp func_end_std_memory_trackAlloc
    end_if_101:
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
    jnb end_if_102
    if_102:
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
    end_if_102:
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
    jne end_if_103
    if_103:
    jmp func_end_std_memory_trackFree
    end_if_103:
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
    jne end_if_104
    if_104:
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
    end_if_104:
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD[rbp-56], RAX
    add QWORD[rbp-56], RBX
; 设置变量i


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
    sub rsp, 200; 分配局部变量空间(200字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
    mov QWORD[rbp-96], RAX
; 设置变量sPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88+0]
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
    call std_strings_toCstring
    mov QWORD[rbp-112], RAX
; 设置变量tPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88+0]
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
; 设置变量tLen
    call std_strings_notFound
    mov QWORD[rbp-128], RAX
; 设置变量nf
    mov QWORD[rbp-136], 0
; 设置变量cnt
    mov QWORD[rbp-144], 0
; 设置变量scanPos
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_105
    if_105:
    mov RAX, QWORD[rbp-104]
    mov RBX, 1
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_strings_count
    end_if_105:




    for_15: ; for循环开始


    sub rsp, 48; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-112]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+24], RAX
; 参数3
    mov RAX, QWORD[rbp-144]
    mov QWORD [rsp+32], RAX
; 参数4
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数3
    mov R8, QWORD [rsp+32]; 装载参数4
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_indexFrom
    mov QWORD[rbp-152], RAX
; 设置变量idx
    mov RAX, QWORD[rbp-152]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-128]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_106
    if_106:
    jmp for_15_end
    end_if_106:
    mov RAX, QWORD[rbp-136]
    mov RBX, 1
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量cnt
    mov RAX, QWORD[rbp-152]
    mov RBX, QWORD[rbp-120]
    mov QWORD[rbp-144], RAX
    add QWORD[rbp-144], RBX
; 设置变量scanPos


    jmp for_15; for循环
    for_15_end: ; for循环结束
    mov RAX, QWORD[rbp-136]
; return值存入RAX
    jmp func_end_std_strings_count
    func_end_std_strings_count:
    add rsp, 200; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


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
    jne end_if_107
    if_107:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_isSpace
    end_if_107:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 9
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_108
    if_108:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_isSpace
    end_if_108:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 10
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_109
    if_109:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_isSpace
    end_if_109:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 13
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_110
    if_110:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_isSpace
    end_if_110:
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
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
    mov QWORD[rbp-96], RAX
; 设置变量sPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88+0]
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
    call std_strings_toCstring
    mov QWORD[rbp-112], RAX
; 设置变量cPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88+0]
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
    jne end_if_111
    if_111:
    mov BYTE[rbp-145], 1
; 设置变量found
    jmp for_17_end
    end_if_111:
    mov RAX, QWORD[rbp-153]
    mov RBX, 1
    mov QWORD[rbp-153], RAX
    add QWORD[rbp-153], RBX
; 设置变量j


    jmp for_17; for循环
    for_17_end: ; for循环结束
    movzx RAX, BYTE[rbp-145]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_112
    if_112:
    jmp for_16_end
    end_if_112:
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量i


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
    mov RBX, QWORD[rbp-225]
; unsafe.cast
    mov RBX, RBX
    mov RAX, QWORD[rbp-209]
    mov BYTE [RAX], bl
; expression statement
    mov RAX, QWORD[rbp-201]
    mov RBX, 1
    mov QWORD[rbp-201], RAX
    add QWORD[rbp-201], RBX
; 设置变量k


    jmp for_18; for循环
    for_18_end: ; for循环结束
    mov RAX, QWORD[rbp-193]
    mov RBX, QWORD[rbp-177]
    mov QWORD[rbp-233], RAX
    add QWORD[rbp-233], RBX
; 设置变量_p5
    mov RAX, 0
; unsafe.cast
    mov RBX, RAX
    mov RCX, QWORD[rbp-233]
    mov BYTE [RCX], bl
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
    call std_strings_makeString
    mov RAX, QWORD [RBP-272+0]
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
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
    mov QWORD[rbp-96], RAX
; 设置变量sPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88+0]
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
    call std_strings_toCstring
    mov QWORD[rbp-112], RAX
; 设置变量cPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88+0]
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
    jne end_if_113
    if_113:
    mov BYTE[rbp-145], 1
; 设置变量found
    jmp for_20_end
    end_if_113:
    mov RAX, QWORD[rbp-153]
    mov RBX, 1
    mov QWORD[rbp-153], RAX
    add QWORD[rbp-153], RBX
; 设置变量j


    jmp for_20; for循环
    for_20_end: ; for循环结束
    movzx RAX, BYTE[rbp-145]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_114
    if_114:
    jmp for_19_end
    end_if_114:
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    sub QWORD[rbp-128], RBX
; 设置变量end


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
; unsafe.cast
    mov RBX, RAX
    mov RCX, QWORD[rbp-201]
    mov BYTE [RCX], bl
; expression statement
    mov RBX, QWORD[rbp-193]
    mov RAX, 1
    mov QWORD[rbp-193], RBX
    add QWORD[rbp-193], RAX
; 设置变量k


    jmp for_21; for循环
    for_21_end: ; for循环结束
    mov RBX, QWORD[rbp-185]
    mov RAX, QWORD[rbp-128]
    mov QWORD[rbp-225], RBX
    add QWORD[rbp-225], RAX
; 设置变量_p10
    mov RAX, 0
; unsafe.cast
    mov RBX, RAX
    mov RCX, QWORD[rbp-225]
    mov BYTE [RCX], bl
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
    call std_strings_makeString
    mov RAX, QWORD [RBP-272+0]
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
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
; 设置变量sPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
    jne end_if_115
    if_115:
    mov RAX, QWORD[rbp-104]
; return值存入RAX
    jmp func_end_std_strings_indexByte
    end_if_115:
    mov RAX, QWORD[rbp-104]
    mov RBX, 1
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量i


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
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
    mov QWORD[rbp-96], RAX
; 设置变量aPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88+0]
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
    call std_strings_toCstring
    mov QWORD[rbp-112], RAX
; 设置变量bPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88+0]
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
    jnb end_if_116
    if_116:
    mov RAX, QWORD[rbp-120]
    mov QWORD[rbp-128], RAX
; 设置变量minLen
    end_if_116:
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
    jnb end_if_117
    if_117:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_117:
    mov RAX, QWORD[rbp-152]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-168]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_118
    if_118:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_118:
    mov RAX, QWORD[rbp-136]
    mov RBX, 1
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量i


    jmp for_23; for循环
    for_23_end: ; for循环结束
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_119
    if_119:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_119:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_120
    if_120:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_120:
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
    mov RAX, QWORD [rbp-64+0]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-88+0]
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
    jne end_if_121
    if_121:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_eq
    end_if_121:
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
    mov RAX, QWORD [rbp-64+0]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-88+0]
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
    je end_if_122
    if_122:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_ne
    end_if_122:
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
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    lea RAX, [rbp-64]
    mov QWORD[rbp-72], RAX
; 设置变量p
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-80], RAX
; 设置变量_p11
    mov RBX, QWORD[rbp-80]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_strings_toCstring
    func_end_std_strings_toCstring:
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
; unsafe.cast
    mov RBX, RAX
    mov RCX, QWORD[rbp-72]
    mov QWORD [RCX], RBX
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
    jge else_if_123
    if_123:
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
    jmp end_if_123
    else_if_123:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64
    mov QWORD[rbp-65], RAX
; 设置变量num
    end_if_123:
    mov QWORD[rbp-73], 1
; 设置变量digits
    mov RAX, QWORD[rbp-65]
    mov QWORD[rbp-81], RAX
; 设置变量tmp




    for_24: ; for循环开始
    mov RAX, QWORD[rbp-81]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb for_24_end
    for_24_body:


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


    jmp for_24; for循环
    for_24_end: ; for循环结束
    mov RAX, QWORD[rbp-73]
    mov QWORD[rbp-89], RAX
; 设置变量total
    movzx RAX, BYTE[rbp-57]
; condition
    test RAX, RAX
    jz end_if_124
    if_124:
    mov RAX, QWORD[rbp-89]
    mov RBX, 1
    mov QWORD[rbp-89], RAX
    add QWORD[rbp-89], RBX
; 设置变量total
    end_if_124:
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
    jne else_if_125
    if_125:
    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-121], RAX
; 设置变量_p14
    mov RBX, 48
; unsafe.cast
    mov RBX, RBX
    mov RAX, QWORD[rbp-121]
    mov BYTE [RAX], bl
; expression statement
    jmp end_if_125
    else_if_125:
    mov QWORD[rbp-129], 0
; 设置变量i




    for_25: ; for循环开始
    mov RAX, QWORD[rbp-113]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_25_end
    for_25_body:


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
    jnb else_if_126
    if_126:
    mov RAX, QWORD[rbp-137]
    mov RBX, 48
    mov QWORD[rbp-145], RAX
    add QWORD[rbp-145], RBX
; 设置变量ch
    jmp end_if_126
    else_if_126:
    mov RAX, QWORD[rbp-137]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 36
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_127
    if_127:
    mov RAX, QWORD[rbp-137]
    mov RBX, 97
    add RAX, RBX
    mov RBX, 10
    mov QWORD[rbp-145], RAX
    sub QWORD[rbp-145], RBX
; 设置变量ch
    jmp end_if_127
    else_if_127:
    mov RAX, QWORD[rbp-137]
    mov RBX, 65
    add RAX, RBX
    mov RBX, 36
    mov QWORD[rbp-145], RAX
    sub QWORD[rbp-145], RBX
; 设置变量ch
    end_if_127:
    end_if_126:
    mov RAX, QWORD[rbp-89]
    mov RBX, 1
    sub RAX, RBX
    mov RBX, QWORD[rbp-129]
    sub RAX, RBX
    mov RBX, QWORD[rbp-105]
    mov QWORD[rbp-153], RBX
    add QWORD[rbp-153], RAX
; 设置变量_p15
    mov RAX, QWORD[rbp-145]
; unsafe.cast
    mov RBX, RAX
    mov RCX, QWORD[rbp-153]
    mov BYTE [RCX], bl
; expression statement
    mov RBX, QWORD[rbp-113]
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-113], RBX
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
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


    jmp for_25; for循环
    for_25_end: ; for循环结束
    end_if_125:
    movzx RAX, BYTE[rbp-57]
; condition
    test RAX, RAX
    jz end_if_128
    if_128:
    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-161], RAX
; 设置变量_p16
    mov RBX, 45
; unsafe.cast
    mov RBX, RBX
    mov RAX, QWORD[rbp-161]
    mov BYTE [RAX], bl
; expression statement
    end_if_128:
    mov RAX, QWORD[rbp-105]
    mov RBX, QWORD[rbp-89]
    mov QWORD[rbp-169], RAX
    add QWORD[rbp-169], RBX
; 设置变量_p17
    mov RAX, 0
; unsafe.cast
    mov RBX, RAX
    mov RCX, QWORD[rbp-169]
    mov BYTE [RCX], bl
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
    mov RAX, QWORD[rbp-209]
; unsafe.cast
    mov RBX, RAX
    mov RCX, QWORD[rbp-217]
    mov QWORD [RCX], RBX
; expression statement
    mov RBX, QWORD[rbp-201]
    mov RAX, 8
    mov QWORD[rbp-225], RBX
    add QWORD[rbp-225], RAX
; 设置变量_p19
    mov RAX, QWORD[rbp-89]
; unsafe.cast
    mov RBX, RAX
    mov RCX, QWORD[rbp-225]
    mov QWORD [RCX], RBX
; expression statement
    mov RBX, QWORD[rbp-201]
    mov RAX, 16
    mov QWORD[rbp-233], RBX
    add QWORD[rbp-233], RAX
; 设置变量_p20
    mov RAX, QWORD[rbp-89]
; unsafe.cast
    mov RBX, RAX
    mov RCX, QWORD[rbp-233]
    mov QWORD [RCX], RBX
; expression statement
    mov RAX, QWORD [rbp-193+0]
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
    jne end_if_129
    if_129:
    mov BYTE[rbp-121], 1
; 设置变量neg
    mov QWORD[rbp-120], 1
; 设置变量i
    end_if_129:
    mov QWORD[rbp-145], 0
; 设置变量val
    mov BYTE[rbp-146], 0
; 设置变量bad




    for_26: ; for循环开始
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-112]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_26_end
    for_26_body:


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
    jb else_if_130
    and_mid_3:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 57
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_130
    if_130:
    mov RAX, QWORD[rbp-162]
    mov RBX, 48
    mov QWORD[rbp-170], RAX
    sub QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_130
    else_if_130:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 97
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_131
    and_mid_4:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 122
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_131
    if_131:
    mov RAX, QWORD[rbp-162]
    mov RBX, 97
    sub RAX, RBX
    mov RBX, 10
    mov QWORD[rbp-170], RAX
    add QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_131
    else_if_131:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_132
    and_mid_5:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 90
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_132
    if_132:
    mov RAX, QWORD[rbp-162]
    mov RBX, 65
    sub RAX, RBX
    mov RBX, 36
    mov QWORD[rbp-170], RAX
    add QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_132
    else_if_132:
    mov BYTE[rbp-146], 1
; 设置变量bad
    end_if_132:
    end_if_131:
    end_if_130:
    movzx RAX, BYTE[rbp-146]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_133
    if_133:
    mov RAX, QWORD[rbp-145]
    mov RBX, QWORD[rbp-72]
    imul RAX, RBX
    mov RBX, QWORD[rbp-170]
    mov QWORD[rbp-145], RAX
    add QWORD[rbp-145], RBX
; 设置变量val
    end_if_133:
    mov RAX, QWORD[rbp-120]
    mov RBX, 1
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量i


    jmp for_26; for循环
    for_26_end: ; for循环结束
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
    jz end_if_134
    if_134:
    mov RBX, QWORD[rbp-178]
    mov QWORD[rbp-178], 0
    sub QWORD[rbp-178], RBX
; 设置变量r
    end_if_134:
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


; ==============================
; Function: std_strings_makeString
std_strings_makeString:
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
; unsafe.cast
    mov RBX, RAX
    mov RCX, QWORD[rbp-104]
    mov QWORD [RCX], RBX
; expression statement
    mov RAX, QWORD[rbp-96]
    mov RBX, 8
    mov QWORD[rbp-112], RAX
    add QWORD[rbp-112], RBX
; 设置变量_p27
    mov RBX, QWORD[rbp-56]
; unsafe.cast
    mov RBX, RBX
    mov RAX, QWORD[rbp-112]
    mov QWORD [RAX], RBX
; expression statement
    mov RAX, QWORD[rbp-96]
    mov RBX, 16
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量_p28
    mov RBX, QWORD[rbp-64]
; unsafe.cast
    mov RBX, RBX
    mov RAX, QWORD[rbp-120]
    mov QWORD [RAX], RBX
; expression statement
    mov RAX, QWORD [rbp-88+0]
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
    jmp func_end_std_strings_makeString
    func_end_std_strings_makeString:
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
; Function: std_strings_indexFrom
std_strings_indexFrom:
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
    mov QWORD [rbp-72], RCX; 保存参数3到栈
    mov QWORD [rbp-80], R8; 保存参数4到栈
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_135
    if_135:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    end_if_135:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_136
    if_136:
    call std_strings_notFound
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    end_if_136:
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-88], RAX
; 设置变量i
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-72]
    mov QWORD[rbp-96], RAX
    sub QWORD[rbp-96], RBX
; 设置变量limit




    for_27: ; for循环开始
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe for_27_end
    for_27_body:


    mov BYTE[rbp-97], 1
; 设置变量found
    mov QWORD[rbp-105], 0
; 设置变量j




    for_28: ; for循环开始
    mov RAX, QWORD[rbp-105]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_28_end
    for_28_body:


    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-88]
    add RAX, RBX
    mov RBX, QWORD[rbp-105]
    mov QWORD[rbp-113], RAX
    add QWORD[rbp-113], RBX
; 设置变量_p29
    mov RAX, QWORD[rbp-64]
    mov RBX, QWORD[rbp-105]
    mov QWORD[rbp-121], RAX
    add QWORD[rbp-121], RBX
; 设置变量_p30
    mov RAX, QWORD[rbp-113]
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RAX, QWORD[rbp-121]
    movzx RCX, BYTE [RAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_137
    if_137:
    mov BYTE[rbp-97], 0
; 设置变量found
    jmp for_28_end
    end_if_137:
    mov RAX, QWORD[rbp-105]
    mov RBX, 1
    mov QWORD[rbp-105], RAX
    add QWORD[rbp-105], RBX
; 设置变量j


    jmp for_28; for循环
    for_28_end: ; for循环结束
    movzx RAX, BYTE[rbp-97]
; condition
    test RAX, RAX
    jz end_if_138
    if_138:
    mov RAX, QWORD[rbp-88]
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    end_if_138:
    mov RAX, QWORD[rbp-88]
    mov RBX, 1
    mov QWORD[rbp-88], RAX
    add QWORD[rbp-88], RBX
; 设置变量i


    jmp for_27; for循环
    for_27_end: ; for循环结束
    call std_strings_notFound
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    func_end_std_strings_indexFrom:
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
; Function: std_strings_index
std_strings_index:
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
    mov RAX, QWORD [rbp-64+0]
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
    mov QWORD[rbp-96], RAX
; 设置变量sPtr
    mov RDI, QWORD [rbp-64]
    mov RSI, QWORD [rbp-64+8]
    mov RDX, QWORD [rbp-64+16]
    call __string_len
    mov QWORD[rbp-104], RAX
; 设置变量sLen
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88+0]
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
    call std_strings_toCstring
    mov QWORD[rbp-112], RAX
; 设置变量tPtr
    mov RDI, QWORD [rbp-88]
    mov RSI, QWORD [rbp-88+8]
    mov RDX, QWORD [rbp-88+16]
    call __string_len
    mov QWORD[rbp-120], RAX
; 设置变量tLen
    call std_strings_notFound
    mov QWORD[rbp-128], RAX
; 设置变量nf
    sub rsp, 48; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-112]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+24], RAX
; 参数3
    mov QWORD [rsp+32], 0
; 参数4
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数3
    mov R8, QWORD [rsp+32]; 装载参数4
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_indexFrom
    mov QWORD[rbp-136], RAX
; 设置变量r
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-128]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_139
    if_139:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_index
    end_if_139:
    mov RAX, QWORD[rbp-136]
; return值存入RAX
    jmp func_end_std_strings_index
    func_end_std_strings_index:
    add rsp, 184; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


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
    jbe end_if_140
    if_140:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasPrefix
    end_if_140:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_141
    if_141:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_hasPrefix
    end_if_141:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
    mov QWORD[rbp-112], RAX
; 设置变量sPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88+0]
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
    call std_strings_toCstring
    mov QWORD[rbp-120], RAX
; 设置变量tPtr
    mov QWORD[rbp-128], 0
; 设置变量i




    for_29: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_29_end
    for_29_body:


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
    je end_if_142
    if_142:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasPrefix
    end_if_142:
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量i


    jmp for_29; for循环
    for_29_end: ; for循环结束
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
    jbe end_if_143
    if_143:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasSuffix
    end_if_143:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_144
    if_144:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_hasSuffix
    end_if_144:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
    mov QWORD[rbp-112], RAX
; 设置变量sPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88+0]
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
    call std_strings_toCstring
    mov QWORD[rbp-120], RAX
; 设置变量tPtr
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-128], RAX
    sub QWORD[rbp-128], RBX
; 设置变量offset
    mov QWORD[rbp-136], 0
; 设置变量i




    for_30: ; for循环开始
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_30_end
    for_30_body:


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
    je end_if_145
    if_145:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasSuffix
    end_if_145:
    mov RAX, QWORD[rbp-136]
    mov RBX, 1
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量i


    jmp for_30; for循环
    for_30_end: ; for循环结束
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
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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




    for_31: ; for循环开始
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_31_end
    for_31_body:


    mov QWORD[rbp-128], 0
; 设置变量j




    for_32: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_32_end
    for_32_body:


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
    mov RCX, QWORD[rbp-152]
; unsafe.cast
    mov RBX, RCX
    mov RAX, QWORD[rbp-136]
    mov BYTE [RAX], bl
; expression statement
    mov RBX, QWORD[rbp-128]
    mov RCX, 1
    mov QWORD[rbp-128], RBX
    add QWORD[rbp-128], RCX
; 设置变量j


    jmp for_32; for循环
    for_32_end: ; for循环结束
    mov RBX, QWORD[rbp-120]
    mov RCX, 1
    mov QWORD[rbp-120], RBX
    add QWORD[rbp-120], RCX
; 设置变量i


    jmp for_31; for循环
    for_31_end: ; for循环结束
    mov RBX, QWORD[rbp-112]
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-160], RBX
    add QWORD[rbp-160], RAX
; 设置变量_p54
    mov RCX, 0
; unsafe.cast
    mov RBX, RCX
    mov RAX, QWORD[rbp-160]
    mov BYTE [RAX], bl
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
    call std_strings_makeString
    mov RAX, QWORD [RBP-192+0]
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
; unsafe.cast
; 设置变量dP
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-88], RBX
    add QWORD[rbp-88], RAX
; 设置变量sAddr
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-96], RAX
; unsafe.cast
; 设置变量sP
    mov RBX, QWORD[rbp-96]
    movzx RAX, BYTE [RBX]
    mov QWORD[rbp-104], RAX
; 设置变量v
    mov RAX, QWORD[rbp-104]
; unsafe.cast
    mov RBX, RAX
    mov RCX, QWORD[rbp-80]
    mov BYTE [RCX], bl
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
; unsafe.cast
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




    for_33: ; for循环开始
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_33_end
    for_33_body:


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


    jmp for_33; for循环
    for_33_end: ; for循环结束
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
; unsafe.cast
; 设置变量tailP
    mov QWORD[rbp-128], 0
; 设置变量zeroU
    mov RAX, QWORD[rbp-128]
; unsafe.cast
    mov RBX, RAX
    mov RCX, QWORD[rbp-120]
    mov BYTE [RCX], bl
; expression statement
    mov QWORD[rbp-136], 24
; 设置变量elemSize
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD[rbp-136]
    mov QWORD[rbp-144], RBX
    push RAX; 保护RAX(左子结果)
    push RAX; 暂存乘数
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
; unsafe.cast
; 设置变量cell
    mov RBX, QWORD [RBP-160]
    mov RAX, QWORD[rbp-88]
    mov QWORD[RBX], RAX
; 设置变量cell.p
    mov RBX, QWORD [RBP-160]
    mov RAX, QWORD[rbp-72]
    mov QWORD[RBX+8], RAX
; 设置变量cell.n
    mov RBX, QWORD [RBP-160]
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
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64+0]
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
    mov QWORD[rbp-104], RAX
; 设置变量sPtr
    mov RDI, QWORD [rbp-64]
    mov RSI, QWORD [rbp-64+8]
    mov RDX, QWORD [rbp-64+16]
    call __string_len
    mov QWORD[rbp-112], RAX
; 设置变量sLen
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-88+0]
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
    call std_strings_toCstring
    mov QWORD[rbp-120], RAX
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
    jz else_if_146
    if_146:
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
    jmp end_if_146
    else_if_146:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64
    mov QWORD[rbp-137], RAX
; 设置变量nMag
    end_if_146:
    mov QWORD[rbp-153], 0
; 设置变量totalPieces
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe else_if_147
    if_147:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-64+0]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-88+0]
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
    jmp end_if_147
    else_if_147:
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_148
    if_148:
    mov QWORD[rbp-153], 1
; 设置变量totalPieces
    jmp end_if_148
    else_if_148:
    mov RAX, QWORD[rbp-112]
    mov QWORD[rbp-153], RAX
; 设置变量totalPieces
    end_if_148:
    end_if_147:
    mov RAX, QWORD[rbp-153]
    mov QWORD[rbp-177], RAX
; 设置变量pieces
    movzx RAX, BYTE[rbp-129]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_149
    if_149:
    mov RAX, QWORD[rbp-177]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-137]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_150
    if_150:
    mov RAX, QWORD[rbp-137]
    mov QWORD[rbp-177], RAX
; 设置变量pieces
    end_if_150:
    end_if_149:
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
    jbe end_if_151
    if_151:
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
    end_if_151:
    mov RAX, QWORD[rbp-185]
    mov QWORD[rbp-209], RAX
; unsafe.cast
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
    jbe end_if_152
    if_152:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-201]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-217], RAX
; 设置变量data
    end_if_152:
    mov RBX, QWORD [RBP-209]
    mov RAX, QWORD[rbp-217]
    mov QWORD[RBX], RAX
; 设置变量hdr.p
    mov RBX, QWORD [RBP-209]
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
    jbe end_if_153
    if_153:
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
    jbe else_if_154
    if_154:
    mov RAX, QWORD[rbp-177]
    mov RBX, 1
    mov QWORD[rbp-257], RAX
    sub QWORD[rbp-257], RBX
; 设置变量limitM1




    for_34: ; for循环开始
    mov RAX, QWORD[rbp-241]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-257]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_34_end
    for_34_body:


    sub rsp, 48; register args buffer
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-112]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RAX, QWORD[rbp-128]
    mov QWORD [rsp+24], RAX
; 参数3
    mov RAX, QWORD[rbp-233]
    mov QWORD [rsp+32], RAX
; 参数4
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数3
    mov R8, QWORD [rsp+32]; 装载参数4
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_indexFrom
    mov QWORD[rbp-265], RAX
; 设置变量sIdx
    mov RAX, QWORD[rbp-265]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-249]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_155
    if_155:
    jmp for_34_end
    end_if_155:
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


    jmp for_34; for循环
    for_34_end: ; for循环结束
    jmp end_if_154
    else_if_154:
    mov RAX, QWORD[rbp-177]
    mov RBX, 1
    mov QWORD[rbp-297], RAX
    sub QWORD[rbp-297], RBX
; 设置变量bsLimit




    for_35: ; for循环开始
    mov RAX, QWORD[rbp-241]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-297]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_35_end
    for_35_body:


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


    jmp for_35; for循环
    for_35_end: ; for循环结束
    end_if_154:
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
    end_if_153:
    mov RBX, QWORD [RBP-209]
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
; unsafe.cast
; 设置变量rAddrH
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-72], RAX
; unsafe.cast
; 设置变量hdrH
    mov RBX, QWORD [RBP-72]
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
; unsafe.cast
; 设置变量cellH
    mov RBX, QWORD [RBP-112]
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
; unsafe.cast
; 设置变量box
    mov RBX, QWORD [RBP-64]
    mov RAX, QWORD [RBX+8]
    mov QWORD[rbp-72], RAX
; 设置变量n0
    mov RBX, QWORD [RBP-64]
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
    jbe end_if_156
    if_156:
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
    jnb else_if_157
    if_157:
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
    jmp end_if_157
    else_if_157:
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
    end_if_157:
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_158
    if_158:
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-96], RAX
; 设置变量ncap
    end_if_158:
    mov RBX, QWORD [RBP-64]
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
    mov RAX, QWORD[rbp-120]
    mov QWORD[RBX], RAX
; 设置变量box.p
    mov RBX, QWORD [RBP-64]
    mov RAX, QWORD[rbp-96]
    mov QWORD[RBX+16], RAX
; 设置变量box.c
    end_if_156:
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



; ==============================
; 程序入口点 (ELF入口)
_start:
    call main
    mov rdi, rax
    mov rax, 60
    syscall

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

section .data
    _oob_msg db "index out of range", 10
    _oob_msg_len equ $ - _oob_msg
    str_1 db `\\n`, 0
    str_1_len equ $ - str_1
