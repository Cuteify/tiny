section .bss
    __global_gbuf resb 24
section .data
    __global_std_memory_gH0 dq 0
    __global_std_memory_gH1 dq 0
    __global_std_memory_gH2 dq 0
    __global_std_memory_gH3 dq 0
    __global_std_memory_gH4 dq 0
    __global_std_memory_gH5 dq 0
    __global_std_memory_gH6 dq 0
    __global_std_memory_gH7 dq 0
    __global_std_memory_gH8 dq 0
    __global_std_memory_ptrSize dq 8
section .text
global _start

; ==============================
; Function: store1
store1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    mov RAX, QWORD [rbp+16+0]
    mov QWORD [rel __global_gbuf+0], RAX
    mov RAX, QWORD [rbp+16+8]
    mov QWORD [rel __global_gbuf+8], RAX
    mov RAX, QWORD [rbp+16+16]
    mov QWORD [rel __global_gbuf+16], RAX
; 设置变量gbuf
    func_end_store1:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


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
    sub rsp, 96; 分配局部变量空间(96字节)
    mov RDI, 64
    call std_memory_malloc1
    mov RBX, RAX; list buffer
    mov RAX, 0
    mov QWORD [RBX+0], RAX
    mov QWORD [RBX+8], RAX
    mov QWORD [RBX+16], RAX
    mov QWORD [RBX+24], RAX
    mov QWORD [RBX+32], RAX
    mov QWORD [RBX+40], RAX
    mov QWORD [RBX+48], RAX
    mov QWORD [RBX+56], RAX
    mov QWORD [rbp-64], RBX
    mov QWORD [rbp-64+8], 8
    mov QWORD [rbp-64+16], 8
; 设置变量loc
    mov RAX, QWORD [rbp-64]
    add RAX, 24
    mov RBX, 77
    mov QWORD [RAX], RBX
; list index assignment
    push QWORD [rbp-64+16]
    push QWORD [rbp-64+8]
    push QWORD [rbp-64+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call store1
    mov RBX, QWORD [rel __global_gbuf]
    add RBX, 24
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_main
    func_end_main:
    add rsp, 96; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_builtin_print1
std_builtin_print1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    push 1
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_strings_toCstring1
    push RAX
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_strings_len1
    push RAX
; 参数2
    sub rsp, 80; 下沉暂存标量参数
    mov RDX, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+168]; 装载暂存参数
    mov RDI, QWORD [rsp+256]; 装载暂存参数
    add rsp, 264; 清理暂存参数
    call std_syscall_write3
; return值存入RAX
    jmp func_end_std_builtin_print1
    func_end_std_builtin_print1:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_builtin_println1
std_builtin_println1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_builtin_print1
    mov DWORD[rbp-44], EAX
; 设置变量n
    mov EAX, DWORD[rbp-44]
    mov RBX, RAX
    push 1
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push 2
    push 2
    push str_1
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_strings_toCstring1
    push RAX
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    push 1
; 参数2
    sub rsp, 80; 下沉暂存标量参数
    mov RDX, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+168]; 装载暂存参数
    mov RDI, QWORD [rsp+256]; 装载暂存参数
    add rsp, 264; 清理暂存参数
    call std_syscall_write3
    mov RCX, RAX
    mov RAX, RBX
    add RAX, RCX
; return值存入RAX
    jmp func_end_std_builtin_println1
    func_end_std_builtin_println1:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_syscall_syscall4
std_syscall_syscall4:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    mov QWORD [rbp+32], RDX; 保存参数2到栈
    mov QWORD [rbp+40], RCX; 保存参数3到栈
    mov RAX, QWORD[rbp+16]
    mov RDI, QWORD[rbp+24]
    mov RSI, QWORD[rbp+32]
    mov RDX, QWORD[rbp+40]
    syscall
    func_end_std_syscall_syscall4:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_syscall_syscall646
std_syscall_syscall646:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    mov QWORD [rbp+32], RDX; 保存参数2到栈
    mov QWORD [rbp+40], RCX; 保存参数3到栈
    mov QWORD [rbp+48], R8; 保存参数4到栈
    mov QWORD [rbp+56], R9; 保存参数5到栈
    mov RAX, QWORD[rbp+16]
    mov RDI, QWORD[rbp+24]
    mov RSI, QWORD[rbp+32]
    mov RDX, QWORD[rbp+40]
    mov R10, QWORD[rbp+48]
    mov R8, QWORD[rbp+56]
    syscall
    func_end_std_syscall_syscall646:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_syscall_exit1
std_syscall_exit1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov DWORD [rbp+16], EDI; 保存参数0到栈
    push 60
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov EAX, DWORD[rbp+16]
    push RAX
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    push 0
; 参数2
    sub rsp, 80; 下沉暂存标量参数
    push 0
; 参数3
    sub rsp, 80; 下沉暂存标量参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov RDX, QWORD [rsp+168]; 装载暂存参数
    mov RSI, QWORD [rsp+256]; 装载暂存参数
    mov RDI, QWORD [rsp+344]; 装载暂存参数
    add rsp, 352; 清理暂存参数
    call std_syscall_syscall4
    func_end_std_syscall_exit1:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_syscall_brk1
std_syscall_brk1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    push 12
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp+16]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    push 0
; 参数2
    sub rsp, 80; 下沉暂存标量参数
    push 0
; 参数3
    sub rsp, 80; 下沉暂存标量参数
    push 0
; 参数4
    sub rsp, 80; 下沉暂存标量参数
    push 0
; 参数5
    sub rsp, 80; 下沉暂存标量参数
    mov R9, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+168]; 装载暂存参数
    mov RCX, QWORD [rsp+256]; 装载暂存参数
    mov RDX, QWORD [rsp+344]; 装载暂存参数
    mov RSI, QWORD [rsp+432]; 装载暂存参数
    mov RDI, QWORD [rsp+520]; 装载暂存参数
    add rsp, 528; 清理暂存参数
    call std_syscall_syscall646
; return值存入RAX
    jmp func_end_std_syscall_brk1
    func_end_std_syscall_brk1:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_syscall_write3
std_syscall_write3:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov DWORD [rbp+16], EDI; 保存参数0到栈
    mov QWORD [rbp+20], RSI; 保存参数1到栈
    mov QWORD [rbp+28], RDX; 保存参数2到栈
    push 1
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov EAX, DWORD[rbp+16]
    push RAX
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp+20]
; 参数2
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp+28]
; 参数3
    sub rsp, 80; 下沉暂存标量参数
    push 0
; 参数4
    sub rsp, 80; 下沉暂存标量参数
    push 0
; 参数5
    sub rsp, 80; 下沉暂存标量参数
    mov R9, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+168]; 装载暂存参数
    mov RCX, QWORD [rsp+256]; 装载暂存参数
    mov RDX, QWORD [rsp+344]; 装载暂存参数
    mov RSI, QWORD [rsp+432]; 装载暂存参数
    mov RDI, QWORD [rsp+520]; 装载暂存参数
    add rsp, 528; 清理暂存参数
    call std_syscall_syscall646
; return值存入RAX
    jmp func_end_std_syscall_write3
    func_end_std_syscall_write3:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_slotOf1
std_memory_slotOf1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 32
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_1
    if_1:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_1:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 48
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_2
    if_2:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_2:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 64
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_3
    if_3:
    mov RAX, 2
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_3:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 96
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_4
    if_4:
    mov RAX, 3
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_4:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 128
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_5
    if_5:
    mov RAX, 4
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_5:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 192
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_6
    if_6:
    mov RAX, 5
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_6:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 256
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_7
    if_7:
    mov RAX, 6
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_7:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 384
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_8
    if_8:
    mov RAX, 7
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_8:
    mov RAX, 8
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    func_end_std_memory_slotOf1:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_blkSizeOf1
std_memory_blkSizeOf1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_9
    if_9:
    mov RAX, 32
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_9:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_10
    if_10:
    mov RAX, 48
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_10:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_11
    if_11:
    mov RAX, 64
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_11:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_12
    if_12:
    mov RAX, 96
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_12:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 4
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_13
    if_13:
    mov RAX, 128
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_13:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 5
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_14
    if_14:
    mov RAX, 192
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_14:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 6
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_15
    if_15:
    mov RAX, 256
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_15:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 7
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_16
    if_16:
    mov RAX, 384
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_16:
    mov RAX, 512
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    func_end_std_memory_blkSizeOf1:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_headOf1
std_memory_headOf1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_17
    if_17:
    mov RAX, QWORD[rel __global_std_memory_gH0]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_17:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_18
    if_18:
    mov RAX, QWORD[rel __global_std_memory_gH1]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_18:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_19
    if_19:
    mov RAX, QWORD[rel __global_std_memory_gH2]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_19:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_20
    if_20:
    mov RAX, QWORD[rel __global_std_memory_gH3]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_20:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 4
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_21
    if_21:
    mov RAX, QWORD[rel __global_std_memory_gH4]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_21:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 5
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_22
    if_22:
    mov RAX, QWORD[rel __global_std_memory_gH5]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_22:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 6
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_23
    if_23:
    mov RAX, QWORD[rel __global_std_memory_gH6]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_23:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 7
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_24
    if_24:
    mov RAX, QWORD[rel __global_std_memory_gH7]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_24:
    mov RAX, QWORD[rel __global_std_memory_gH8]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    func_end_std_memory_headOf1:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_setHead2
std_memory_setHead2:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_25
    if_25:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH0], RAX
; 设置变量gH0
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_25:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_26
    if_26:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH1], RAX
; 设置变量gH1
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_26:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_27
    if_27:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH2], RAX
; 设置变量gH2
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_27:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_28
    if_28:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH3], RAX
; 设置变量gH3
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_28:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 4
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_29
    if_29:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH4], RAX
; 设置变量gH4
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_29:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 5
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_30
    if_30:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH5], RAX
; 设置变量gH5
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_30:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 6
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_31
    if_31:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH6], RAX
; 设置变量gH6
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_31:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 7
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_32
    if_32:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH7], RAX
; 设置变量gH7
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_32:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH8], RAX
; 设置变量gH8
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    func_end_std_memory_setHead2:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_refill2
std_memory_refill2:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 128; 分配局部变量空间(128字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    push 0
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_syscall_brk1
    mov QWORD[rbp-48], RAX
; 设置变量chunk
    mov RAX, QWORD[rbp-48]
    mov RBX, 4096
    add RAX, RBX
    push RAX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_syscall_brk1
    mov QWORD[rbp-56], RAX
; 设置变量nb
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
    mov RBX, 4096
    add RCX, RBX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_33
    if_33:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_refill2
    end_if_33:
    push QWORD[rbp-48]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp+24]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_hdrSetSize2
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-64], RAX
; 设置变量head
    mov QWORD[rbp-72], 0
; 设置变量prev
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-80], RAX
; 设置变量p
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-88], RAX
    mov RBX, 4096
    add QWORD[rbp-88], RBX
; 设置变量end




    for_1: ; for循环开始
    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rbp+24]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg for_1_end


    push QWORD[rbp-80]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push 0
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_hdrSetNext2
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_34
    if_34:
    push QWORD[rbp-72]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-80]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_hdrSetNext2
    end_if_34:
    push QWORD[rbp-80]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp+24]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_hdrSetSize2
    mov RBX, QWORD[rbp-80]
    mov QWORD[rbp-72], RBX
; 设置变量prev
    mov RBX, QWORD[rbp+24]
    add QWORD[rbp-80], RBX
; 设置变量p


    jmp for_1; for循环
    for_1_end: ; for循环结束
    push QWORD[rbp+16]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-64]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_setHead2
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_refill2
    func_end_std_memory_refill2:
    add rsp, 128; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_malloc1
std_memory_malloc1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 128; 分配局部变量空间(128字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov RAX, QWORD[rel __global_std_memory_ptrSize]
    mov RBX, 2
    imul RAX, RBX
    mov RBX, QWORD[rbp+16]
    mov QWORD[rbp-48], RBX
    add QWORD[rbp-48], RAX
; 设置变量req
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 512
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_35
    if_35:
    push 0
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_syscall_brk1
    mov QWORD[rbp-56], RAX
; 设置变量old
    mov RBX, QWORD[rbp-56]
    mov RAX, QWORD[rbp-48]
    add RBX, RAX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_syscall_brk1
    mov QWORD[rbp-64], RAX
; 设置变量nb
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
    mov RAX, QWORD[rbp-48]
    add RCX, RAX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_36
    if_36:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc1
    end_if_36:
    push QWORD[rbp-56]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push 0
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_hdrSetNext2
    push QWORD[rbp-56]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-48]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_hdrSetSize2
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
    mov RDX, 2
    imul RBX, RDX
    mov RAX, QWORD[rbp-56]
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_malloc1
    end_if_35:
    push QWORD[rbp-48]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_slotOf1
    mov QWORD[rbp-72], RAX
; 设置变量idx
    push QWORD[rbp-72]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_blkSizeOf1
    mov QWORD[rbp-80], RAX
; 设置变量blkSize
    push QWORD[rbp-72]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_headOf1
    mov QWORD[rbp-88], RAX
; 设置变量head
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_37
    if_37:
    push QWORD[rbp-72]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-80]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_refill2
    mov QWORD[rbp-88], RAX
; 设置变量head
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_38
    if_38:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc1
    end_if_38:
    end_if_37:
    push QWORD[rbp-88]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_hdrNext1
    mov QWORD[rbp-96], RAX
; 设置变量next
    push QWORD[rbp-72]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-96]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_setHead2
    push QWORD[rbp-88]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-80]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_hdrSetSize2
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
    mov RDX, 2
    imul RBX, RDX
    mov RAX, QWORD[rbp-88]
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_malloc1
    func_end_std_memory_malloc1:
    add rsp, 128; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_free1
std_memory_free1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 112; 分配局部变量空间(112字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_39
    if_39:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_free1
    end_if_39:
    mov RAX, QWORD[rel __global_std_memory_ptrSize]
    mov RBX, 2
    imul RAX, RBX
    mov RBX, QWORD[rbp+16]
    mov QWORD[rbp-48], RBX
    sub QWORD[rbp-48], RAX
; 设置变量blk
    push QWORD[rbp-48]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_hdrSizeOf1
    mov QWORD[rbp-56], RAX
; 设置变量size
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 512
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_40
    if_40:
    push 0
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_syscall_brk1
    mov QWORD[rbp-64], RAX
; 设置变量cur
    mov RAX, QWORD[rbp-48]
    mov RBX, QWORD[rbp-56]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-64]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_41
    if_41:
    push QWORD[rbp-48]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_syscall_brk1
    end_if_41:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_free1
    end_if_40:
    push QWORD[rbp-56]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_slotOf1
    mov QWORD[rbp-72], RAX
; 设置变量idx
    push QWORD[rbp-72]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_headOf1
    mov QWORD[rbp-80], RAX
; 设置变量head
    push QWORD[rbp-48]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-80]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_hdrSetNext2
    push QWORD[rbp-72]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-48]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_setHead2
    func_end_std_memory_free1:
    add rsp, 112; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_load81
std_memory_load81:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp+16]
    movzx EAX, byte[RAX]
    func_end_std_memory_load81:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_load641
std_memory_load641:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp+16]
    mov RAX, [RAX]
    func_end_std_memory_load641:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_store82
std_memory_store82:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov BYTE [rbp+24], SIL; 保存参数1到栈
    mov RAX, QWORD[rbp+16]
    mov CL, BYTE[rbp+24]
    mov [RAX], CL
    func_end_std_memory_store82:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_store642
std_memory_store642:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp+16]
    mov RCX, QWORD[rbp+24]
    mov [RAX], RCX
    func_end_std_memory_store642:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_hdrNext1
std_memory_hdrNext1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    push QWORD[rbp+16]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load641
; return值存入RAX
    jmp func_end_std_memory_hdrNext1
    func_end_std_memory_hdrNext1:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_hdrSetNext2
std_memory_hdrSetNext2:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    push QWORD[rbp+16]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp+24]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store642
    func_end_std_memory_hdrSetNext2:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_hdrSizeOf1
std_memory_hdrSizeOf1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov RBX, QWORD[rbp+16]
    mov RCX, QWORD[rel __global_std_memory_ptrSize]
    add RBX, RCX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load641
; return值存入RAX
    jmp func_end_std_memory_hdrSizeOf1
    func_end_std_memory_hdrSizeOf1:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_hdrSetSize2
std_memory_hdrSetSize2:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp+16]
    mov RBX, QWORD[rel __global_std_memory_ptrSize]
    add RAX, RBX
    push RAX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp+24]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store642
    func_end_std_memory_hdrSetSize2:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_strings_len1
__string_len:
std_strings_len1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    lea RAX, [rbp+16]
    mov QWORD[rbp-48], RAX
; 设置变量p
    mov RBX, QWORD[rbp-48]
    mov RCX, 8
    add RBX, RCX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load641
; return值存入RAX
    jmp func_end_std_strings_len1
    func_end_std_strings_len1:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_strings_toCstring1
__string_toCstring:
std_strings_toCstring1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    lea RAX, [rbp+16]
    mov QWORD[rbp-48], RAX
; 设置变量p
    push QWORD[rbp-48]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load641
; return值存入RAX
    jmp func_end_std_strings_toCstring1
    func_end_std_strings_toCstring1:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_strings_toU641
__string_toU64:
std_strings_toU641:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    lea RAX, [rbp+16]
    mov QWORD[rbp-48], RAX
; 设置变量p
    push QWORD[rbp-48]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load641
; return值存入RAX
    jmp func_end_std_strings_toU641
    func_end_std_strings_toU641:
    add rsp, 80; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_strings_fromI641
__string_fromI64:
std_strings_fromI641:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 96; 分配局部变量空间(96字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD[rbp-48], 0
; 设置变量x
    lea RAX, [rbp-48]
    mov QWORD[rbp-56], RAX
; 设置变量p
    push QWORD[rbp-56]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp+16]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store642
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_strings_fromI641
    func_end_std_strings_fromI641:
    add rsp, 96; 清理局部变量栈空间
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


section .data
    str_1 db "\\n", 0
    str_1_len equ $ - str_1
