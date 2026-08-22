section .data
    __global_std_time_SECOND dq 1000000000
    __global_std_time_MINUTE dq 60000000000
    __global_std_time_HOUR dq 3600000000000
    __global_std_time_DAY dq 86400000000000
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
    __global_std_console_STDIN dd 0
    __global_std_console_STDOUT dd 1
    __global_std_console_STDERR dd 2
section .text
global _start

; ==============================
; Function: fib1
fib1:
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
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_1
    if_1:
    mov RAX, QWORD[rbp+16]
; return值存入RAX
    jmp func_end_fib1
    end_if_1:
    mov RBX, QWORD[rbp+16]
    mov RCX, 1
    sub RBX, RCX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call fib1
    mov RBX, RAX
    mov RDX, QWORD[rbp+16]
    mov RSI, 2
    sub RDX, RSI
    push RDX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call fib1
    mov RCX, RAX
    mov RAX, RBX
    add RAX, RCX
; return值存入RAX
    jmp func_end_fib1
    func_end_fib1:
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
    sub rsp, 144; 分配局部变量空间(144字节)
    lea R10, [rbp-144]; 大值返回槽地址
    call std_time_now0
    mov RAX, QWORD [RBP-144+0]
    mov QWORD [rbp-64+0], RAX
    mov RAX, QWORD [RBP-144+8]
    mov QWORD [rbp-64+8], RAX
    mov RAX, QWORD [RBP-144+16]
    mov QWORD [rbp-64+16], RAX
; 设置变量t0
    push 30
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call fib1
    mov QWORD[rbp-72], RAX
; 设置变量r
    lea R10, [rbp-144]; 大值返回槽地址
    call std_time_now0
    mov RAX, QWORD [RBP-144+0]
    mov QWORD [rbp-96+0], RAX
    mov RAX, QWORD [RBP-144+8]
    mov QWORD [rbp-96+8], RAX
    mov RAX, QWORD [RBP-144+16]
    mov QWORD [rbp-96+16], RAX
; 设置变量t1
    push QWORD [rbp-96+16]
    push QWORD [rbp-96+8]
    push QWORD [rbp-96]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push QWORD [rbp-64+16]
    push QWORD [rbp-64+8]
    push QWORD [rbp-64]
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_time_sub2
    mov QWORD[rbp-104], RAX
; 设置变量ns
    push QWORD[rbp-104]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_strings_fromI641
    mov QWORD[rbp-112], RAX
; 设置变量nsi
    push 8
    push 8
    push str_1
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_console_print1
    push QWORD[rbp-72]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push 10
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    lea R10, [rbp-144]; 大值返回槽地址
    call std_strings_toString2
    push QWORD [RBP-144+16]
    push QWORD [RBP-144+8]
    push QWORD [RBP-144]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_console_print1
    push 9
    push 9
    push str_2
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_console_print1
    push QWORD[rbp-112]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push 10
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    lea R10, [rbp-144]; 大值返回槽地址
    call std_strings_toString2
    push QWORD [RBP-144+16]
    push QWORD [RBP-144+8]
    push QWORD [RBP-144]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_console_print1
    push 2
    push 2
    push str_3
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_console_println1
    mov RAX, 0
; return值存入RAX
    jmp func_end_main
    func_end_main:
    add rsp, 144; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_time_daysFromCivil3
std_time_daysFromCivil3:
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
    mov QWORD [rbp+32], RDX; 保存参数2到栈
    mov RAX, QWORD[rbp+16]
    mov QWORD[rbp-48], RAX
; 设置变量y
    mov RAX, QWORD[rbp+24]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_2
    if_2:
    mov RAX, 1
    sub QWORD[rbp-48], RAX
; 设置变量y
    end_if_2:
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-56], RAX
    mov RAX, 400
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-56]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-56], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量era
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_3
    if_3:
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-56], RAX
    mov RAX, 399
    sub QWORD[rbp-56], RAX
    mov RAX, 400
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-56]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-56], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量era
    end_if_3:
    mov RAX, QWORD[rbp-56]
    mov RBX, 400
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-64], RBX
    sub QWORD[rbp-64], RAX
; 设置变量yoe
    mov RAX, QWORD[rbp+24]
    mov QWORD[rbp-72], RAX
; 设置变量mp
    mov RAX, QWORD[rbp+24]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle else_if_4
    if_4:
    mov RBX, QWORD[rbp+24]
    mov QWORD[rbp-72], RBX
    mov RAX, 3
    sub QWORD[rbp-72], RAX
; 设置变量mp
    jmp end_if_4
    else_if_4:
    mov RBX, QWORD[rbp+24]
    mov QWORD[rbp-72], RBX
    mov RAX, 9
    add QWORD[rbp-72], RAX
; 设置变量mp
    end_if_4:
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-80], 153
    push RAX; 保护RAX(左子结果)
    push RAX; 暂存乘数
    mov RAX, QWORD[rbp-80]
    imul RAX, qword [rsp]
    mov QWORD[rbp-80], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
    mov RAX, 2
    add QWORD[rbp-80], RAX
    mov RAX, 5
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-80]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-80], rax
    pop RAX; 恢复RAX(左子结果)
    mov RAX, QWORD[rbp+32]
    add QWORD[rbp-80], RAX
    mov RAX, 1
    sub QWORD[rbp-80], RAX
; 设置变量doy
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-88], RAX
    mov RAX, 365
    push RAX; 保护RAX(左子结果)
    push RAX; 暂存乘数
    mov RAX, QWORD[rbp-88]
    imul RAX, qword [rsp]
    mov QWORD[rbp-88], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
    mov RBX, QWORD[rbp-88]
    mov RAX, QWORD[rbp-64]
    mov RCX, 4
    push RCX; 保存除数
    mov rax, RAX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RAX, rax
    mov QWORD[rbp-88], RBX
    add QWORD[rbp-88], RAX
    mov RBX, QWORD[rbp-88]
    mov RAX, QWORD[rbp-64]
    mov RCX, 100
    push RCX; 保存除数
    mov rax, RAX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RAX, rax
    mov QWORD[rbp-88], RBX
    sub QWORD[rbp-88], RAX
    mov RAX, QWORD[rbp-80]
    add QWORD[rbp-88], RAX
; 设置变量doe
    mov RAX, QWORD[rbp-56]
    mov RBX, 146097
    imul RAX, RBX
    mov RBX, QWORD[rbp-88]
    add RAX, RBX
    mov RBX, 719468
    sub RAX, RBX
; return值存入RAX
    jmp func_end_std_time_daysFromCivil3
    func_end_std_time_daysFromCivil3:
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
; Function: std_time_civilFromDays1
std_time_civilFromDays1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 176; 分配局部变量空间(176字节)
    mov QWORD [rbp-152], R10; 保存返回槽地址
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp+16]
    mov QWORD[rbp-48], RAX
    mov RAX, 719468
    add QWORD[rbp-48], RAX
; 设置变量zz
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-56], RAX
    mov RAX, 146097
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-56]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-56], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量era
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_5
    if_5:
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-56], RAX
    mov RAX, 146096
    sub QWORD[rbp-56], RAX
    mov RAX, 146097
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-56]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-56], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量era
    end_if_5:
    mov RAX, QWORD[rbp-56]
    mov RBX, 146097
    imul RAX, RBX
    mov RBX, QWORD[rbp-48]
    mov QWORD[rbp-64], RBX
    sub QWORD[rbp-64], RAX
; 设置变量doe
    mov RAX, QWORD[rbp-64]
    mov RBX, 1460
    push RBX; 保存除数
    mov rax, RAX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RAX, rax
    mov RBX, QWORD[rbp-64]
    mov QWORD[rbp-72], RBX
    sub QWORD[rbp-72], RAX
    mov RBX, QWORD[rbp-72]
    mov RAX, QWORD[rbp-64]
    mov RCX, 36524
    push RCX; 保存除数
    mov rax, RAX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RAX, rax
    mov QWORD[rbp-72], RBX
    add QWORD[rbp-72], RAX
    mov RBX, QWORD[rbp-72]
    mov RAX, QWORD[rbp-64]
    mov RCX, 146096
    push RCX; 保存除数
    mov rax, RAX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RAX, rax
    mov QWORD[rbp-72], RBX
    sub QWORD[rbp-72], RAX
    mov RAX, 365
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-72]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-72], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量yoe
    mov RAX, QWORD[rbp-56]
    mov RBX, 400
    imul RAX, RBX
    mov RBX, QWORD[rbp-72]
    mov QWORD[rbp-80], RBX
    add QWORD[rbp-80], RAX
; 设置变量y
    mov RBX, QWORD[rbp-72]
    mov RAX, 365
    imul RAX, RBX
    mov RBX, RAX
    mov RCX, QWORD[rbp-72]
    mov RDX, 4
    push RAX; 保护RAX(左子结果)
    push RDX; 保存除数
    mov rax, RCX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RCX, rax
    pop RAX; 恢复RAX(左子结果)
    mov RAX, RBX
    add RAX, RCX
    mov RBX, RAX
    mov RCX, QWORD[rbp-72]
    mov RDX, 100
    push RAX; 保护RAX(左子结果)
    push RDX; 保存除数
    mov rax, RCX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RCX, rax
    pop RAX; 恢复RAX(左子结果)
    mov RAX, RBX
    sub RAX, RCX
    mov RBX, QWORD[rbp-64]
    mov QWORD[rbp-88], RBX
    sub QWORD[rbp-88], RAX
; 设置变量doy
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-96], 5
    push RAX; 保护RAX(左子结果)
    push RAX; 暂存乘数
    mov RAX, QWORD[rbp-96]
    imul RAX, qword [rsp]
    mov QWORD[rbp-96], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
    mov RAX, 2
    add QWORD[rbp-96], RAX
    mov RAX, 153
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-96]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-96], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量mp
    mov RBX, QWORD[rbp-96]
    mov RAX, 153
    imul RAX, RBX
    mov RBX, 2
    add RAX, RBX
    mov RCX, 5
    push RCX; 保存除数
    mov rax, RAX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RAX, rax
    mov RBX, QWORD[rbp-88]
    mov QWORD[rbp-104], RBX
    sub QWORD[rbp-104], RAX
    mov RDX, 1
    add QWORD[rbp-104], RDX
; 设置变量d
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-112], RAX
    mov RBX, 3
    add QWORD[rbp-112], RBX
; 设置变量m
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 12
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_6
    if_6:
    mov RBX, 12
    sub QWORD[rbp-112], RBX
; 设置变量m
    mov RBX, 1
    add QWORD[rbp-80], RBX
; 设置变量y
    end_if_6:
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-136], RAX
; 设置变量r.y
    mov RAX, QWORD[rbp-112]
    mov QWORD[rbp-128], RAX
; 设置变量r.m
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-120], RAX
; 设置变量r.d
    mov RAX, QWORD [rbp-136+0]
    mov QWORD [rbp-176+0], RAX
    mov RAX, QWORD [rbp-136+8]
    mov QWORD [rbp-176+8], RAX
    mov RAX, QWORD [rbp-136+16]
    mov QWORD [rbp-176+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-152]; 恢复返回槽地址
    mov RAX, QWORD [rbp-176]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-168]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-160]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_civilFromDays1
    func_end_std_time_civilFromDays1:
    add rsp, 176; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_time_floorDiv2
std_time_floorDiv2:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 96; 分配局部变量空间(96字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp+16]
    mov QWORD[rbp-48], RAX
    mov RAX, QWORD[rbp+24]
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-48]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-48], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量q
    mov RAX, QWORD[rbp+16]
    mov QWORD[rbp-56], RAX
    mov RAX, QWORD[rbp+24]
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-56]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-56], rdx
    pop RAX; 恢复RAX(左子结果)
; 设置变量r
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_7
    if_7:
    mov RAX, 1
    sub QWORD[rbp-48], RAX
; 设置变量q
    end_if_7:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_time_floorDiv2
    func_end_std_time_floorDiv2:
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
; Function: std_time_date7
std_time_date7:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 112; 分配局部变量空间(112字节)
    mov QWORD [rbp-88], R10; 保存返回槽地址
    mov RAX, [rbp+16]; 保存栈参数6槽0到栈
    mov [rbp+64], RAX
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    mov QWORD [rbp+32], RDX; 保存参数2到栈
    mov QWORD [rbp+40], RCX; 保存参数3到栈
    mov QWORD [rbp+48], R8; 保存参数4到栈
    mov QWORD [rbp+56], R9; 保存参数5到栈
    push QWORD[rbp+16]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp+24]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp+32]
; 参数2
    sub rsp, 80; 下沉暂存标量参数
    mov RDX, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+168]; 装载暂存参数
    mov RDI, QWORD [rsp+256]; 装载暂存参数
    add rsp, 264; 清理暂存参数
    call std_time_daysFromCivil3
    mov QWORD[rbp-48], RAX
; 设置变量days
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-56], RAX
    mov RAX, 86400
    push RAX; 保护RAX(左子结果)
    push RAX; 暂存乘数
    mov RAX, QWORD[rbp-56]
    imul RAX, qword [rsp]
    mov QWORD[rbp-56], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
    mov RAX, QWORD[rbp+40]
    mov RBX, 3600
    imul RAX, RBX
    add QWORD[rbp-56], RAX
    mov RAX, QWORD[rbp+48]
    mov RBX, 60
    imul RAX, RBX
    add QWORD[rbp-56], RAX
    mov RAX, QWORD[rbp+56]
    add QWORD[rbp-56], RAX
; 设置变量sec
    push QWORD[rbp-56]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_strings_toU641
    mov QWORD[rbp-80], RAX
; 设置变量t.sec
    mov RAX, QWORD[rbp+64]
    mov QWORD[rbp-72], RAX
; 设置变量t.nsec
    mov QWORD[rbp-64], 0
; 设置变量t.offset
    mov RAX, QWORD [rbp-80+0]
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
    jmp func_end_std_time_date7
    func_end_std_time_date7:
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
; Function: std_time_seconds1
std_time_seconds1:
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
    push QWORD[rbp+16]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_strings_fromI641
; return值存入RAX
    jmp func_end_std_time_seconds1
    func_end_std_time_seconds1:
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
; Function: std_time_localSec1
std_time_localSec1:
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
    push QWORD[rbp+16]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_strings_fromI641
    mov RBX, QWORD[rbp+32]
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_time_localSec1
    func_end_std_time_localSec1:
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
; Function: std_time_splitLocal1
std_time_splitLocal1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 88; 分配局部变量空间(88字节)
    mov QWORD [rbp-72], R10; 保存返回槽地址
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_time_localSec1
    mov QWORD[rbp-64], RAX
; 设置变量ls
    push QWORD[rbp-64]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push 86400
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_time_floorDiv2
    mov QWORD[rbp-56], RAX
; 设置变量sp.days
    mov RAX, QWORD[rbp-56]
    mov RBX, 86400
    imul RAX, RBX
    mov RBX, QWORD[rbp-64]
    mov QWORD[rbp-48], RBX
    sub QWORD[rbp-48], RAX
; 设置变量sp.tod
    mov RAX, QWORD [rbp-56+0]
    mov QWORD [rbp-88+0], RAX
    mov RAX, QWORD [rbp-56+8]
    mov QWORD [rbp-88+8], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-72]; 恢复返回槽地址
    mov RAX, QWORD [rbp-88]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10+8], RAX
    jmp func_end_std_time_splitLocal1
    func_end_std_time_splitLocal1:
    add rsp, 88; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_time_ymd1
std_time_ymd1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 96; 分配局部变量空间(96字节)
    mov QWORD [rbp-72], R10; 保存返回槽地址
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    lea R10, [rbp-96]; 大值返回槽地址
    call std_time_splitLocal1
    mov RAX, QWORD [RBP-96+0]
    mov QWORD [rbp-56+0], RAX
    mov RAX, QWORD [RBP-96+8]
    mov QWORD [rbp-56+8], RAX
; 设置变量sp
    push QWORD[rbp-56]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    lea R10, [rbp-96]; 大值返回槽地址
    call std_time_civilFromDays1
    mov RAX, QWORD [RBP-96+0]
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
    jmp func_end_std_time_ymd1
    func_end_std_time_ymd1:
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
; Function: std_time_hour1
std_time_hour1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 96; 分配局部变量空间(96字节)
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    lea R10, [rbp-96]; 大值返回槽地址
    call std_time_splitLocal1
    mov RAX, QWORD [RBP-96+0]
    mov QWORD [rbp-56+0], RAX
    mov RAX, QWORD [RBP-96+8]
    mov QWORD [rbp-56+8], RAX
; 设置变量sp
    mov RAX, QWORD[rbp-48]
    mov RBX, 3600
    push RBX; 保存除数
    mov rax, RAX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RAX, rax
; return值存入RAX
    jmp func_end_std_time_hour1
    func_end_std_time_hour1:
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
; Function: std_time_minute1
std_time_minute1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 96; 分配局部变量空间(96字节)
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    lea R10, [rbp-96]; 大值返回槽地址
    call std_time_splitLocal1
    mov RAX, QWORD [RBP-96+0]
    mov QWORD [rbp-56+0], RAX
    mov RAX, QWORD [RBP-96+8]
    mov QWORD [rbp-56+8], RAX
; 设置变量sp
    mov RAX, QWORD[rbp-48]
    mov RBX, 3600
    push RBX; 保存除数
    mov rax, RAX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RAX, rdx
    mov RBX, 60
    push RBX; 保存除数
    mov rax, RAX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RAX, rax
; return值存入RAX
    jmp func_end_std_time_minute1
    func_end_std_time_minute1:
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
; Function: std_time_second1
std_time_second1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 96; 分配局部变量空间(96字节)
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    lea R10, [rbp-96]; 大值返回槽地址
    call std_time_splitLocal1
    mov RAX, QWORD [RBP-96+0]
    mov QWORD [rbp-56+0], RAX
    mov RAX, QWORD [RBP-96+8]
    mov QWORD [rbp-56+8], RAX
; 设置变量sp
    mov RAX, QWORD[rbp-48]
    mov RBX, 60
    push RBX; 保存除数
    mov rax, RAX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RAX, rdx
; return值存入RAX
    jmp func_end_std_time_second1
    func_end_std_time_second1:
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
; Function: std_time_weekday1
std_time_weekday1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 112; 分配局部变量空间(112字节)
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    lea R10, [rbp-112]; 大值返回槽地址
    call std_time_splitLocal1
    mov RAX, QWORD [RBP-112+0]
    mov QWORD [rbp-56+0], RAX
    mov RAX, QWORD [RBP-112+8]
    mov QWORD [rbp-56+8], RAX
; 设置变量sp
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-64], RAX
    mov RAX, 4
    add QWORD[rbp-64], RAX
; 设置变量w
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-72], RAX
    mov RAX, 7
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-72]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-72], rdx
    pop RAX; 恢复RAX(左子结果)
; 设置变量r
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_8
    if_8:
    mov RAX, 7
    add QWORD[rbp-72], RAX
; 设置变量r
    end_if_8:
    mov RAX, QWORD[rbp-72]
; return值存入RAX
    jmp func_end_std_time_weekday1
    func_end_std_time_weekday1:
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
; Function: std_time_sub2
std_time_sub2:
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
    mov QWORD [rbp+40], RCX; 保存参数1槽0到栈
    mov QWORD [rbp+48], R8; 保存参数1槽1到栈
    mov QWORD [rbp+56], R9; 保存参数1槽2到栈
    mov RAX, QWORD[rbp+16]
    mov RBX, QWORD[rbp+40]
    sub RAX, RBX
    mov RBX, QWORD[rel __global_std_time_SECOND]
    imul RAX, RBX
    mov RBX, QWORD[rbp+24]
    add RAX, RBX
    mov RBX, QWORD[rbp+48]
    sub RAX, RBX
; return值存入RAX
    jmp func_end_std_time_sub2
    func_end_std_time_sub2:
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
; Function: std_time_layoutAt3
std_time_layoutAt3:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 112; 分配局部变量空间(112字节)
    mov RAX, [rbp+16]; 保存栈参数2槽0到栈
    mov [rbp+48], RAX
    mov RAX, [rbp+24]; 保存栈参数2槽1到栈
    mov [rbp+56], RAX
    mov RAX, [rbp+32]; 保存栈参数2槽2到栈
    mov [rbp+64], RAX
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp+40], RCX; 保存参数1到栈
    push QWORD [rbp+48+16]
    push QWORD [rbp+48+8]
    push QWORD [rbp+48+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_strings_len1
    mov QWORD[rbp-48], RAX
; 设置变量tn
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
    mov QWORD[rbp-56], RAX
; 设置变量ln
    mov RAX, QWORD[rbp+40]
    mov RBX, QWORD[rbp-48]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_9
    if_9:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_time_layoutAt3
    end_if_9:
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
    mov QWORD[rbp-64], RAX
; 设置变量p
    push QWORD [rbp+48+16]
    push QWORD [rbp+48+8]
    push QWORD [rbp+48+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_strings_toCstring1
    mov QWORD[rbp-72], RAX
; 设置变量tp
    mov QWORD[rbp-80], 0
; 设置变量k




    for_1: ; for循环开始
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_1_end


    mov RBX, QWORD[rbp-64]
    mov RAX, QWORD[rbp+40]
    add RBX, RAX
    mov RAX, QWORD[rbp-80]
    add RBX, RAX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load81
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RBX, QWORD[rbp-72]
    mov RAX, QWORD[rbp-80]
    add RBX, RAX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load81
    mov RCX, RAX
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_10
    if_10:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_time_layoutAt3
    end_if_10:
    mov RAX, 1
    add QWORD[rbp-80], RAX
; 设置变量k


    jmp for_1; for循环
    for_1_end: ; for循环结束
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_time_layoutAt3
    func_end_std_time_layoutAt3:
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
; Function: std_time_writeDigits4
std_time_writeDigits4:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 96; 分配局部变量空间(96字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    mov QWORD [rbp+32], RDX; 保存参数2到栈
    mov QWORD [rbp+40], RCX; 保存参数3到栈
    push QWORD[rbp+32]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_strings_toU641
    mov QWORD[rbp-48], RAX
; 设置变量tmp
    mov RAX, QWORD[rbp+24]
    mov QWORD[rbp-56], RAX
    mov RAX, QWORD[rbp+40]
    add QWORD[rbp-56], RAX
    mov RAX, 1
    sub QWORD[rbp-56], RAX
; 设置变量pos
    mov QWORD[rbp-64], 0
; 设置变量k




    for_2: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp+40]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_2_end


    mov RAX, QWORD[rbp+16]
    mov RBX, QWORD[rbp-56]
    add RAX, RBX
    push RAX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RAX, QWORD[rbp-48]
    mov RBX, 10
    push RBX; 保存除数
    mov rax, RAX
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov RAX, rdx
    mov RBX, 48
    add RAX, RBX
    push RAX
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store82
    mov RAX, 10
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-48]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-48], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量tmp
    mov RAX, 1
    sub QWORD[rbp-56], RAX
; 设置变量pos
    mov RAX, 1
    add QWORD[rbp-64], RAX
; 设置变量k


    jmp for_2; for循环
    for_2_end: ; for循环结束
    mov RAX, QWORD[rbp+24]
    mov RBX, QWORD[rbp+40]
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_time_writeDigits4
    func_end_std_time_writeDigits4:
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
; Function: std_time_writeText3
std_time_writeText3:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 96; 分配局部变量空间(96字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    mov QWORD [rbp+32], RDX; 保存参数2槽0到栈
    mov QWORD [rbp+40], RCX; 保存参数2槽1到栈
    mov QWORD [rbp+48], R8; 保存参数2槽2到栈
    push QWORD [rbp+32+16]
    push QWORD [rbp+32+8]
    push QWORD [rbp+32+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_strings_len1
    mov QWORD[rbp-48], RAX
; 设置变量tn
    push QWORD [rbp+32+16]
    push QWORD [rbp+32+8]
    push QWORD [rbp+32+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_strings_toCstring1
    mov QWORD[rbp-56], RAX
; 设置变量tp
    mov QWORD[rbp-64], 0
; 设置变量k




    for_3: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_3_end


    mov RAX, QWORD[rbp+16]
    mov RBX, QWORD[rbp+24]
    add RAX, RBX
    mov RBX, QWORD[rbp-64]
    add RAX, RBX
    push RAX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-64]
    add RAX, RBX
    push RAX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load81
    push RAX
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store82
    mov RAX, 1
    add QWORD[rbp-64], RAX
; 设置变量k


    jmp for_3; for循环
    for_3_end: ; for循环结束
    mov RAX, QWORD[rbp+24]
    mov RBX, QWORD[rbp-48]
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_time_writeText3
    func_end_std_time_writeText3:
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
; Function: std_time_readNumVal4
std_time_readNumVal4:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 112; 分配局部变量空间(112字节)
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp+40], RCX; 保存参数1到栈
    mov QWORD [rbp+48], R8; 保存参数2到栈
    mov QWORD [rbp+56], R9; 保存参数3到栈
    mov QWORD[rbp-48], 0
; 设置变量v
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
    mov QWORD[rbp-56], RAX
; 设置变量p
    mov QWORD[rbp-64], 0
; 设置变量k




    for_4: ; for循环开始
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp+48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_4_end


    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp+40]
    add RAX, RBX
    mov RBX, QWORD[rbp-64]
    add RAX, RBX
    push RAX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load81
    mov BYTE[rbp-65], al
; 设置变量d
    mov RAX, 10
    push RAX; 保护RAX(左子结果)
    push RAX; 暂存乘数
    mov RAX, QWORD[rbp-48]
    imul RAX, qword [rsp]
    mov QWORD[rbp-48], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
    movzx RAX, BYTE[rbp-65]
    add QWORD[rbp-48], RAX
    mov RAX, 48
    sub QWORD[rbp-48], RAX
; 设置变量v
    mov RBX, 1
    add QWORD[rbp-64], RBX
; 设置变量k


    jmp for_4; for循环
    for_4_end: ; for循环结束
    push QWORD[rbp+56]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-48]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_time_numOut2
    mov RAX, QWORD[rbp+40]
    mov RBX, QWORD[rbp+48]
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_time_readNumVal4
    func_end_std_time_readNumVal4:
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
; Function: std_time_zoneOffset2
std_time_zoneOffset2:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 208; 分配局部变量空间(208字节)
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp+40], RCX; 保存参数1到栈
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    lea R10, [rbp-208]; 大值返回槽地址
    call std_time_findZoneData1
    mov RAX, QWORD [RBP-208+0]
    mov QWORD [rbp-64+0], RAX
    mov RAX, QWORD [RBP-208+8]
    mov QWORD [rbp-64+8], RAX
    mov RAX, QWORD [RBP-208+16]
    mov QWORD [rbp-64+16], RAX
; 设置变量data
    push QWORD [rbp-64+16]
    push QWORD [rbp-64+8]
    push QWORD [rbp-64+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_strings_len1
    mov QWORD[rbp-72], RAX
; 设置变量n
    push QWORD [rbp-64+16]
    push QWORD [rbp-64+8]
    push QWORD [rbp-64+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    mov RSI, QWORD [rsp+88]; 装载暂存参数
    mov RDX, QWORD [rsp+96]; 装载暂存参数
    add rsp, 104; 清理暂存参数
    call std_strings_toCstring1
    mov QWORD[rbp-80], RAX
; 设置变量p
    mov QWORD[rbp-88], 0
; 设置变量i




    for_5: ; for循环开始
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_5_end
    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rbp-88]
    add RAX, RBX
    push RAX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load81
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 124
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je for_5_end


    mov RAX, 1
    add QWORD[rbp-88], RAX
; 设置变量i


    jmp for_5; for循环
    for_5_end: ; for循环结束
    mov RAX, 1
    add QWORD[rbp-88], RAX
; 设置变量i
    mov QWORD[rbp-96], 0
; 设置变量last




    for_6: ; for循环开始
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_6_end


    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-104], RAX
; 设置变量tStart




    for_7: ; for循环开始
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_7_end
    mov RBX, QWORD[rbp-80]
    mov RAX, QWORD[rbp-88]
    add RBX, RAX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load81
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 44
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je for_7_end


    mov RAX, 1
    add QWORD[rbp-88], RAX
; 设置变量i


    jmp for_7; for循环
    for_7_end: ; for循环结束
    mov RBX, QWORD [rbp-64]
    sub RSP, 24
    mov RAX, QWORD[rbp-104]
    imul RAX, 1
    mov QWORD [RSP+16], RAX; R.cap 槽暂存 lo
    mov RAX, QWORD [rbp-64]
    add RAX, [RSP+16]
    mov QWORD [RSP], RAX; R.ptr
    mov RAX, QWORD[rbp-88]
    sub RAX, [RSP+16]
    mov QWORD [RSP+8], RAX; R.len
    mov RAX, QWORD [rbp-64+16]
    sub RAX, [RSP+16]
    mov QWORD [RSP+16], RAX; R.cap
    mov RAX, QWORD [RSP]
    mov QWORD [rbp-128], RAX
    mov RAX, QWORD [RSP+8]
    mov QWORD [rbp-128+8], RAX
    mov RAX, QWORD [RSP+16]
    mov QWORD [rbp-128+16], RAX
    add RSP, 24
; 设置变量tStr
    mov RAX, 1
    add QWORD[rbp-88], RAX
; 设置变量i
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-136], RAX
; 设置变量oStart




    for_8: ; for循环开始
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_8_end
    mov RBX, QWORD[rbp-80]
    mov RAX, QWORD[rbp-88]
    add RBX, RAX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load81
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 44
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je for_8_end


    mov RAX, 1
    add QWORD[rbp-88], RAX
; 设置变量i


    jmp for_8; for循环
    for_8_end: ; for循环结束
    mov RBX, QWORD [rbp-64]
    sub RSP, 24
    mov RAX, QWORD[rbp-136]
    imul RAX, 1
    mov QWORD [RSP+16], RAX; R.cap 槽暂存 lo
    mov RAX, QWORD [rbp-64]
    add RAX, [RSP+16]
    mov QWORD [RSP], RAX; R.ptr
    mov RAX, QWORD[rbp-88]
    sub RAX, [RSP+16]
    mov QWORD [RSP+8], RAX; R.len
    mov RAX, QWORD [rbp-64+16]
    sub RAX, [RSP+16]
    mov QWORD [RSP+16], RAX; R.cap
    mov RAX, QWORD [RSP]
    mov QWORD [rbp-160], RAX
    mov RAX, QWORD [RSP+8]
    mov QWORD [rbp-160+8], RAX
    mov RAX, QWORD [RSP+16]
    mov QWORD [rbp-160+16], RAX
    add RSP, 24
; 设置变量oStr
    mov RAX, 1
    add QWORD[rbp-88], RAX
; 设置变量i




    for_9: ; for循环开始
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_9_end
    mov RBX, QWORD[rbp-80]
    mov RAX, QWORD[rbp-88]
    add RBX, RAX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load81
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 124
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je for_9_end


    mov RAX, 1
    add QWORD[rbp-88], RAX
; 设置变量i


    jmp for_9; for循环
    for_9_end: ; for循环结束
    push QWORD [rbp-128+16]
    push QWORD [rbp-128+8]
    push QWORD [rbp-128+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 10
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    mov RSI, QWORD [rsp+176]; 装载暂存参数
    mov RDX, QWORD [rsp+184]; 装载暂存参数
    add rsp, 192; 清理暂存参数
    call std_strings_parse2
    mov QWORD[rbp-168], RAX
; 设置变量tVal
    mov RAX, QWORD[rbp-168]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp+40]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg else_if_11
    if_11:
    push QWORD [rbp-160+16]
    push QWORD [rbp-160+8]
    push QWORD [rbp-160+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 10
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    mov RSI, QWORD [rsp+176]; 装载暂存参数
    mov RDX, QWORD [rsp+184]; 装载暂存参数
    add rsp, 192; 清理暂存参数
    call std_strings_parse2
    mov QWORD[rbp-96], RAX
; 设置变量last
    jmp end_if_11
    else_if_11:
    end_if_11:
    mov RAX, 1
    add QWORD[rbp-88], RAX
; 设置变量i


    jmp for_6; for循环
    for_6_end: ; for循环结束
    mov RAX, QWORD[rbp-96]
; return值存入RAX
    jmp func_end_std_time_zoneOffset2
    func_end_std_time_zoneOffset2:
    add rsp, 208; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_time_now0
std_time_now0:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 128; 分配局部变量空间(128字节)
    mov QWORD [rbp-104], R10; 保存返回槽地址
    mov QWORD[rbp-48], 0
; 设置变量buf
    lea RAX, [rbp-48]
    mov QWORD[rbp-56], RAX
; 设置变量p
    push 228
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push 0
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-56]
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
    push QWORD[rbp-56]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load641
    mov QWORD[rbp-64], RAX
; 设置变量sec
    mov RAX, QWORD[rbp-56]
    mov RBX, 8
    add RAX, RBX
    push RAX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load641
    mov QWORD[rbp-72], RAX
; 设置变量nsec
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-96], RAX
; 设置变量t.sec
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-88], RAX
; 设置变量t.nsec
    mov QWORD[rbp-80], 0
; 设置变量t.offset
    mov RAX, QWORD [rbp-96+0]
    mov QWORD [rbp-128+0], RAX
    mov RAX, QWORD [rbp-96+8]
    mov QWORD [rbp-128+8], RAX
    mov RAX, QWORD [rbp-96+16]
    mov QWORD [rbp-128+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-104]; 恢复返回槽地址
    mov RAX, QWORD [rbp-128]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-120]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-112]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_now0
    func_end_std_time_now0:
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
; Function: std_time_strSlots4
std_time_strSlots4:
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
    mov RAX, QWORD[rbp+16]
    mov RBX, 8
    add RAX, RBX
    push RAX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp+32]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store642
    mov RAX, QWORD[rbp+16]
    mov RBX, 16
    add RAX, RBX
    push RAX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp+40]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store642
    func_end_std_time_strSlots4:
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
; Function: std_time_numOut2
std_time_numOut2:
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
    func_end_std_time_numOut2:
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
; Function: std_time_findZoneData1
std_time_findZoneData1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 80; 分配局部变量空间(80字节)
    mov QWORD [rbp-56], R10; 保存返回槽地址
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 3
    push 3
    push str_4
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_12
    if_12:
    mov RAX, QWORD [rel __global_std_time_tzUTC+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzUTC+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzUTC+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_12:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 13
    push 13
    push str_5
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_13
    if_13:
    mov RAX, QWORD [rel __global_std_time_tzAsia_Shanghai+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Shanghai+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Shanghai+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_13:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 14
    push 14
    push str_6
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_14
    if_14:
    mov RAX, QWORD [rel __global_std_time_tzAsia_Hong_Kong+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Hong_Kong+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Hong_Kong+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_14:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 11
    push 11
    push str_7
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_15
    if_15:
    mov RAX, QWORD [rel __global_std_time_tzAsia_Taipei+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Taipei+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Taipei+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_15:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 10
    push 10
    push str_8
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_16
    if_16:
    mov RAX, QWORD [rel __global_std_time_tzAsia_Tokyo+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Tokyo+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Tokyo+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_16:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 10
    push 10
    push str_9
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_17
    if_17:
    mov RAX, QWORD [rel __global_std_time_tzAsia_Seoul+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Seoul+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Seoul+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_17:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 14
    push 14
    push str_10
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_18
    if_18:
    mov RAX, QWORD [rel __global_std_time_tzAsia_Singapore+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Singapore+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Singapore+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_18:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 12
    push 12
    push str_11
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_19
    if_19:
    mov RAX, QWORD [rel __global_std_time_tzAsia_Kolkata+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Kolkata+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Kolkata+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_19:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 10
    push 10
    push str_12
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_20
    if_20:
    mov RAX, QWORD [rel __global_std_time_tzAsia_Dubai+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Dubai+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAsia_Dubai+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_20:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 13
    push 13
    push str_13
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_21
    if_21:
    mov RAX, QWORD [rel __global_std_time_tzEurope_London+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzEurope_London+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzEurope_London+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_21:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 12
    push 12
    push str_14
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_22
    if_22:
    mov RAX, QWORD [rel __global_std_time_tzEurope_Paris+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzEurope_Paris+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzEurope_Paris+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_22:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 13
    push 13
    push str_15
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_23
    if_23:
    mov RAX, QWORD [rel __global_std_time_tzEurope_Moscow+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzEurope_Moscow+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzEurope_Moscow+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_23:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 13
    push 13
    push str_16
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_24
    if_24:
    mov RAX, QWORD [rel __global_std_time_tzEurope_Berlin+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzEurope_Berlin+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzEurope_Berlin+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_24:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 16
    push 16
    push str_17
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_25
    if_25:
    mov RAX, QWORD [rel __global_std_time_tzAmerica_New_York+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAmerica_New_York+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAmerica_New_York+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_25:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 15
    push 15
    push str_18
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_26
    if_26:
    mov RAX, QWORD [rel __global_std_time_tzAmerica_Chicago+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAmerica_Chicago+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAmerica_Chicago+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_26:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 14
    push 14
    push str_19
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_27
    if_27:
    mov RAX, QWORD [rel __global_std_time_tzAmerica_Denver+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAmerica_Denver+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAmerica_Denver+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_27:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 19
    push 19
    push str_20
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_28
    if_28:
    mov RAX, QWORD [rel __global_std_time_tzAmerica_Los_Angeles+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAmerica_Los_Angeles+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAmerica_Los_Angeles+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_28:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 17
    push 17
    push str_21
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_29
    if_29:
    mov RAX, QWORD [rel __global_std_time_tzAmerica_Sao_Paulo+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAmerica_Sao_Paulo+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAmerica_Sao_Paulo+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_29:
    push QWORD [rbp+16+16]
    push QWORD [rbp+16+8]
    push QWORD [rbp+16+0]
; 参数0
    sub rsp, 80; 下沉暂存多槽参数
    push 16
    push 16
    push str_22
; 参数1
    sub rsp, 80; 下沉暂存多槽参数
    mov RCX, QWORD [rsp+80]; 装载暂存参数
    mov R8, QWORD [rsp+88]; 装载暂存参数
    mov R9, QWORD [rsp+96]; 装载暂存参数
    mov RDI, QWORD [rsp+184]; 装载暂存参数
    mov RSI, QWORD [rsp+192]; 装载暂存参数
    mov RDX, QWORD [rsp+200]; 装载暂存参数
    add rsp, 208; 清理暂存参数
    call std_strings_eq2
; condition
    test RAX, RAX
    jz end_if_30
    if_30:
    mov RAX, QWORD [rel __global_std_time_tzAustralia_Sydney+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzAustralia_Sydney+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzAustralia_Sydney+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    end_if_30:
    mov RAX, QWORD [rel __global_std_time_tzUTC+0]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [rel __global_std_time_tzUTC+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [rel __global_std_time_tzUTC+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_time_findZoneData1
    func_end_std_time_findZoneData1:
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
    jg end_if_31
    if_31:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_31:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 48
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_32
    if_32:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_32:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 64
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_33
    if_33:
    mov RAX, 2
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_33:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 96
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_34
    if_34:
    mov RAX, 3
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_34:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 128
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_35
    if_35:
    mov RAX, 4
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_35:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 192
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_36
    if_36:
    mov RAX, 5
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_36:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 256
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_37
    if_37:
    mov RAX, 6
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_37:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 384
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_38
    if_38:
    mov RAX, 7
; return值存入RAX
    jmp func_end_std_memory_slotOf1
    end_if_38:
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
    jne end_if_39
    if_39:
    mov RAX, 32
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_39:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_40
    if_40:
    mov RAX, 48
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_40:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_41
    if_41:
    mov RAX, 64
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_41:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_42
    if_42:
    mov RAX, 96
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_42:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 4
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_43
    if_43:
    mov RAX, 128
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_43:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 5
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_44
    if_44:
    mov RAX, 192
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_44:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 6
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_45
    if_45:
    mov RAX, 256
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_45:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 7
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_46
    if_46:
    mov RAX, 384
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf1
    end_if_46:
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
    jne end_if_47
    if_47:
    mov RAX, QWORD[rel __global_std_memory_gH0]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_47:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_48
    if_48:
    mov RAX, QWORD[rel __global_std_memory_gH1]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_48:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_49
    if_49:
    mov RAX, QWORD[rel __global_std_memory_gH2]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_49:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_50
    if_50:
    mov RAX, QWORD[rel __global_std_memory_gH3]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_50:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 4
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_51
    if_51:
    mov RAX, QWORD[rel __global_std_memory_gH4]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_51:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 5
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_52
    if_52:
    mov RAX, QWORD[rel __global_std_memory_gH5]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_52:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 6
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_53
    if_53:
    mov RAX, QWORD[rel __global_std_memory_gH6]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_53:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 7
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_54
    if_54:
    mov RAX, QWORD[rel __global_std_memory_gH7]
; return值存入RAX
    jmp func_end_std_memory_headOf1
    end_if_54:
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
    jne end_if_55
    if_55:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH0], RAX
; 设置变量gH0
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_55:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_56
    if_56:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH1], RAX
; 设置变量gH1
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_56:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_57
    if_57:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH2], RAX
; 设置变量gH2
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_57:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_58
    if_58:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH3], RAX
; 设置变量gH3
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_58:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 4
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_59
    if_59:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH4], RAX
; 设置变量gH4
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_59:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 5
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_60
    if_60:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH5], RAX
; 设置变量gH5
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_60:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 6
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_61
    if_61:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH6], RAX
; 设置变量gH6
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_61:
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 7
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_62
    if_62:
    mov RAX, QWORD[rbp+24]
    mov QWORD[rel __global_std_memory_gH7], RAX
; 设置变量gH7
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_setHead2
    end_if_62:
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
    jge end_if_63
    if_63:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_refill2
    end_if_63:
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




    for_10: ; for循环开始
    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rbp+24]
    add RAX, RBX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg for_10_end


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
    je end_if_64
    if_64:
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
    end_if_64:
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


    jmp for_10; for循环
    for_10_end: ; for循环结束
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
    jle end_if_65
    if_65:
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
    jge end_if_66
    if_66:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc1
    end_if_66:
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
    end_if_65:
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
    jne end_if_67
    if_67:
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
    jne end_if_68
    if_68:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc1
    end_if_68:
    end_if_67:
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
    jne end_if_69
    if_69:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_free1
    end_if_69:
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
    jle end_if_70
    if_70:
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
    jne end_if_71
    if_71:
    push QWORD[rbp-48]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_syscall_brk1
    end_if_71:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_free1
    end_if_70:
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
; Function: std_strings_eq2
__string_eq:
std_strings_eq2:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 112; 分配局部变量空间(112字节)
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp+40], RCX; 保存参数1槽0到栈
    mov QWORD [rbp+48], R8; 保存参数1槽1到栈
    mov QWORD [rbp+56], R9; 保存参数1槽2到栈
    lea RAX, [rbp+16]
    mov QWORD[rbp-48], RAX
; 设置变量p
    lea RAX, [rbp+40]
    mov QWORD[rbp-56], RAX
; 设置变量q
    push QWORD[rbp-48]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load641
    mov QWORD[rbp-64], RAX
; 设置变量x
    push QWORD[rbp-56]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load641
    mov QWORD[rbp-72], RAX
; 设置变量y
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_72
    if_72:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_eq2
    end_if_72:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_eq2
    func_end_std_strings_eq2:
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
; Function: std_strings_toString2
__string_toString:
std_strings_toString2:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 192; 分配局部变量空间(192字节)
    mov QWORD [rbp-168], R10; 保存返回槽地址
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    mov BYTE[rbp-41], 0
; 设置变量neg
    mov QWORD[rbp-49], 0
; 设置变量num
    mov RAX, QWORD[rbp+16]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge else_if_73
    if_73:
    mov BYTE[rbp-41], 1
; 设置变量neg
    mov RAX, QWORD[rbp+16]
    mov RBX, 0
    sub RBX, RAX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_strings_toU641
    mov QWORD[rbp-49], RAX
; 设置变量num
    jmp end_if_73
    else_if_73:
    push QWORD[rbp+16]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_strings_toU641
    mov QWORD[rbp-49], RAX
; 设置变量num
    end_if_73:
    mov QWORD[rbp-57], 1
; 设置变量digits
    mov RAX, QWORD[rbp-49]
    mov QWORD[rbp-65], RAX
; 设置变量tmp




    for_11: ; for循环开始
    mov RAX, QWORD[rbp-65]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp+24]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl for_11_end


    mov RBX, QWORD[rbp+24]
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-65]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-65], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量tmp
    mov RAX, 1
    add QWORD[rbp-57], RAX
; 设置变量digits


    jmp for_11; for循环
    for_11_end: ; for循环结束
    mov RAX, QWORD[rbp-57]
    mov QWORD[rbp-73], RAX
; 设置变量total
    movzx RAX, BYTE[rbp-41]
; condition
    test RAX, RAX
    jz end_if_74
    if_74:
    mov RAX, 1
    add QWORD[rbp-73], RAX
; 设置变量total
    end_if_74:
    mov RBX, QWORD[rbp-73]
    mov RAX, 1
    add RBX, RAX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_malloc1
    mov QWORD[rbp-81], RAX
; 设置变量buf
    mov RAX, QWORD[rbp-49]
    mov QWORD[rbp-89], RAX
; 设置变量v
    mov RAX, QWORD[rbp-89]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne else_if_75
    if_75:
    push QWORD[rbp-81]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push 48
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store82
    jmp end_if_75
    else_if_75:
    mov QWORD[rbp-97], 0
; 设置变量i




    for_12: ; for循环开始
    mov RAX, QWORD[rbp-89]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle for_12_end


    mov RBX, QWORD[rbp-89]
    mov QWORD[rbp-105], RBX
    mov RBX, QWORD[rbp+24]
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-105]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-105], rdx
    pop RAX; 恢复RAX(左子结果)
; 设置变量digit
    mov QWORD[rbp-113], 0
; 设置变量ch
    mov RAX, QWORD[rbp-105]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 10
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge else_if_76
    if_76:
    mov RBX, QWORD[rbp-105]
    mov QWORD[rbp-113], RBX
    mov RAX, 48
    add QWORD[rbp-113], RAX
; 设置变量ch
    jmp end_if_76
    else_if_76:
    mov RAX, QWORD[rbp-105]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 36
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge else_if_77
    if_77:
    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-113], RAX
    mov RAX, 97
    add QWORD[rbp-113], RAX
    mov RAX, 10
    sub QWORD[rbp-113], RAX
; 设置变量ch
    jmp end_if_77
    else_if_77:
    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-113], RAX
    mov RAX, 65
    add QWORD[rbp-113], RAX
    mov RAX, 36
    sub QWORD[rbp-113], RAX
; 设置变量ch
    end_if_77:
    end_if_76:
    mov RAX, QWORD[rbp-73]
    mov RBX, 1
    sub RAX, RBX
    mov RBX, QWORD[rbp-97]
    sub RAX, RBX
    mov RBX, QWORD[rbp-81]
    add RBX, RAX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-113]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store82
    mov RBX, QWORD[rbp+24]
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-89]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-89], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量v
    mov RAX, 1
    add QWORD[rbp-97], RAX
; 设置变量i


    jmp for_12; for循环
    for_12_end: ; for循环结束
    end_if_75:
    movzx RAX, BYTE[rbp-41]
; condition
    test RAX, RAX
    jz end_if_78
    if_78:
    push QWORD[rbp-81]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push 45
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store82
    end_if_78:
    mov RBX, QWORD[rbp-81]
    mov RAX, QWORD[rbp-73]
    add RBX, RAX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push 0
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store82
    mov QWORD [rbp-137], 0
    mov QWORD [rbp-137+8], 0
    mov QWORD [rbp-137+16], 0
    ; 零值容器 s
    lea RAX, [rbp-137]
    mov QWORD[rbp-145], RAX
; 设置变量p
    mov RAX, QWORD[rbp-81]
    mov QWORD[rbp-153], RAX
; 设置变量b
    push QWORD[rbp-145]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-153]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store642
    mov RBX, QWORD[rbp-145]
    mov RAX, 8
    add RBX, RAX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-73]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store642
    mov RBX, QWORD[rbp-145]
    mov RAX, 16
    add RBX, RAX
    push RBX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push QWORD[rbp-73]
; 参数1
    sub rsp, 80; 下沉暂存标量参数
    mov RSI, QWORD [rsp+80]; 装载暂存参数
    mov RDI, QWORD [rsp+168]; 装载暂存参数
    add rsp, 176; 清理暂存参数
    call std_memory_store642
    mov RAX, QWORD [rbp-137+0]
    mov QWORD [rbp-192+0], RAX
    mov RAX, QWORD [rbp-137+8]
    mov QWORD [rbp-192+8], RAX
    mov RAX, QWORD [rbp-137+16]
    mov QWORD [rbp-192+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-168]; 恢复返回槽地址
    mov RAX, QWORD [rbp-192]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-184]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-176]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_toString2
    func_end_std_strings_toString2:
    add rsp, 192; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_strings_parse2
__string_parse:
std_strings_parse2:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 160; 分配局部变量空间(160字节)
    mov QWORD [rbp+16], RDI; 保存参数0槽0到栈
    mov QWORD [rbp+24], RSI; 保存参数0槽1到栈
    mov QWORD [rbp+32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp+40], RCX; 保存参数1到栈
    lea RAX, [rbp+16]
    mov QWORD[rbp-48], RAX
; 设置变量p
    push QWORD[rbp-48]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load641
    mov QWORD[rbp-56], RAX
; 设置变量ptrVal
    mov RAX, QWORD[rbp-48]
    mov RBX, 8
    add RAX, RBX
    push RAX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load641
    mov QWORD[rbp-64], RAX
; 设置变量n
    mov QWORD[rbp-72], 0
; 设置变量i
    mov BYTE[rbp-73], 0
; 设置变量neg
    push QWORD[rbp-56]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load81
    mov QWORD[rbp-81], RAX
; 设置变量c
    mov RAX, QWORD[rbp-81]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 45
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_79
    if_79:
    mov BYTE[rbp-73], 1
; 设置变量neg
    mov QWORD[rbp-72], 1
; 设置变量i
    end_if_79:
    mov QWORD[rbp-89], 0
; 设置变量val
    mov BYTE[rbp-90], 0
; 设置变量bad




    for_13: ; for循环开始
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-64]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge for_13_end


    mov RAX, QWORD[rbp-56]
    mov RBX, QWORD[rbp-72]
    add RAX, RBX
    push RAX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_memory_load81
    mov QWORD[rbp-98], RAX
; 设置变量d
    mov QWORD[rbp-106], 0
; 设置变量v
    mov RAX, QWORD[rbp-98]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 48
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl else_if_80
    mov RAX, QWORD[rbp-98]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 57
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg else_if_80
    if_80:
    mov RAX, QWORD[rbp-98]
    mov QWORD[rbp-106], RAX
    mov RAX, 48
    sub QWORD[rbp-106], RAX
; 设置变量v
    jmp end_if_80
    else_if_80:
    mov RAX, QWORD[rbp-98]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 97
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl else_if_81
    mov RAX, QWORD[rbp-98]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 122
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg else_if_81
    if_81:
    mov RAX, QWORD[rbp-98]
    mov QWORD[rbp-106], RAX
    mov RAX, 97
    sub QWORD[rbp-106], RAX
    mov RAX, 10
    add QWORD[rbp-106], RAX
; 设置变量v
    jmp end_if_81
    else_if_81:
    mov RAX, QWORD[rbp-98]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl else_if_82
    mov RAX, QWORD[rbp-98]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 90
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg else_if_82
    if_82:
    mov RAX, QWORD[rbp-98]
    mov QWORD[rbp-106], RAX
    mov RAX, 65
    sub QWORD[rbp-106], RAX
    mov RAX, 36
    add QWORD[rbp-106], RAX
; 设置变量v
    jmp end_if_82
    else_if_82:
    mov BYTE[rbp-90], 1
; 设置变量bad
    end_if_82:
    end_if_81:
    end_if_80:
    movzx RBX, BYTE[rbp-90]
    cmp RBX, 0
    sete bl
    movzx RBX, bl
    mov RAX, RBX
; condition
    test RAX, RAX
    jz end_if_83
    if_83:
    mov RAX, QWORD[rbp+40]
    push RAX; 保护RAX(左子结果)
    push RAX; 暂存乘数
    mov RAX, QWORD[rbp-89]
    imul RAX, qword [rsp]
    mov QWORD[rbp-89], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
    mov RAX, QWORD[rbp-106]
    add QWORD[rbp-89], RAX
; 设置变量val
    end_if_83:
    mov RAX, 1
    add QWORD[rbp-72], RAX
; 设置变量i


    jmp for_13; for循环
    for_13_end: ; for循环结束
    push QWORD[rbp-89]
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    mov RDI, QWORD [rsp+80]; 装载暂存参数
    add rsp, 88; 清理暂存参数
    call std_strings_fromI641
    mov QWORD[rbp-114], RAX
; 设置变量r
    movzx RAX, BYTE[rbp-73]
; condition
    test RAX, RAX
    jz end_if_84
    if_84:
    mov RAX, QWORD[rbp-114]
    mov QWORD[rbp-114], 0
    sub QWORD[rbp-114], RAX
; 设置变量r
    end_if_84:
    mov RAX, QWORD[rbp-114]
; return值存入RAX
    jmp func_end_std_strings_parse2
    func_end_std_strings_parse2:
    add rsp, 160; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_console_print1
std_console_print1:
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
    mov EAX, DWORD[rel __global_std_console_STDOUT]
    push RAX
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
    jmp func_end_std_console_print1
    func_end_std_console_print1:
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
; Function: std_console_println1
std_console_println1:
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
    call std_console_print1
    mov DWORD[rbp-44], EAX
; 设置变量n
    mov EAX, DWORD[rbp-44]
    mov RBX, RAX
    mov EAX, DWORD[rel __global_std_console_STDOUT]
    push RAX
; 参数0
    sub rsp, 80; 下沉暂存标量参数
    push 2
    push 2
    push str_23
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
    jmp func_end_std_console_println1
    func_end_std_console_println1:
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
    push str_23
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
; 程序入口点 (ELF入口)
_start:
    call main
    mov rdi, rax
    mov rax, 60
    syscall


section .data
    str_42 db "America/Los_Angeles|-2717640000,-28800,PST|-1633269600,-25200,PDT|-1615129200,-28800,PST|-1601820000,-25200,PDT|-1583679600,-28800,PST|-880207200,-25200,PWT|-769395600,-25200,PPT|-765385200,-28800,PST|-687967140,-25200,PDT|-662655600,-28800,PST|-620838000,-25200,PDT|-608137200,-28800,PST|-589388400,-25200,PDT|-576082800,-28800,PST|-557938800,-25200,PDT|-544633200,-28800,PST|-526489200,-25200,PDT|-513183600,-28800,PST|-495039600,-25200,PDT|-481734000,-28800,PST|-463590000,-25200,PDT|-450284400,-28800,PST|-431535600,-25200,PDT|-418230000,-28800,PST|-400086000,-25200,PDT|-386780400,-28800,PST|-368636400,-25200,PDT|-355330800,-28800,PST|-337186800,-25200,PDT|-323881200,-28800,PST|-305737200,-25200,PDT|-292431600,-28800,PST|-273682800,-25200,PDT|-260982000,-28800,PST|-242233200,-25200,PDT|-226508400,-28800,PST|-210783600,-25200,PDT|-195058800,-28800,PST|-179334000,-25200,PDT|-163609200,-28800,PST|-147884400,-25200,PDT|-131554800,-28800,PST|-116434800,-25200,PDT|-100105200,-28800,PST|-84376800,-25200,PDT|-68655600,-28800,PST|-52927200,-25200,PDT|-37206000,-28800,PST|-21477600,-25200,PDT|-5756400,-28800,PST|9972000,-25200,PDT|25693200,-28800,PST|41421600,-25200,PDT|57747600,-28800,PST|73476000,-25200,PDT|89197200,-28800,PST|104925600,-25200,PDT|120646800,-28800,PST|126698400,-25200,PDT|152096400,-28800,PST|162381600,-25200,PDT|183546000,-28800,PST|199274400,-25200,PDT|215600400,-28800,PST|230724000,-25200,PDT|247050000,-28800,PST|262778400,-25200,PDT|278499600,-28800,PST|294228000,-25200,PDT|309949200,-28800,PST|325677600,-25200,PDT|341398800,-28800,PST|357127200,-25200,PDT|372848400,-28800,PST|388576800,-25200,PDT|404902800,-28800,PST|420026400,-25200,PDT|436352400,-28800,PST|452080800,-25200,PDT|467802000,-28800,PST|483530400,-25200,PDT|499251600,-28800,PST|514980000,-25200,PDT|530701200,-28800,PST|544615200,-25200,PDT|562150800,-28800,PST|576064800,-25200,PDT|594205200,-28800,PST|607514400,-25200,PDT|625654800,-28800,PST|638964000,-25200,PDT|657104400,-28800,PST|671018400,-25200,PDT|688554000,-28800,PST|702468000,-25200,PDT|720003600,-28800,PST|733917600,-25200,PDT|752058000,-28800,PST|765367200,-25200,PDT|783507600,-28800,PST|796816800,-25200,PDT|814957200,-28800,PST|828871200,-25200,PDT|846406800,-28800,PST|860320800,-25200,PDT|877856400,-28800,PST|891770400,-25200,PDT|909306000,-28800,PST|923220000,-25200,PDT|941360400,-28800,PST|954669600,-25200,PDT|972810000,-28800,PST|986119200,-25200,PDT|1004259600,-28800,PST|1018173600,-25200,PDT|1035709200,-28800,PST|1049623200,-25200,PDT|1067158800,-28800,PST|1081072800,-25200,PDT|1099213200,-28800,PST|1112522400,-25200,PDT|1130662800,-28800,PST|1143972000,-25200,PDT|1162112400,-28800,PST|1173607200,-25200,PDT|1193907600,-28800,PST|1205402400,-25200,PDT|1225962000,-28800,PST|1236852000,-25200,PDT|1257411600,-28800,PST|1268301600,-25200,PDT|1288861200,-28800,PST|1299751200,-25200,PDT|1320310800,-28800,PST|1331200800,-25200,PDT|1351760400,-28800,PST|1363255200,-25200,PDT|1383814800,-28800,PST|1394704800,-25200,PDT|1415264400,-28800,PST|1426154400,-25200,PDT|1446714000,-28800,PST|1457604000,-25200,PDT|1478163600,-28800,PST|1489053600,-25200,PDT|1509613200,-28800,PST|1520503200,-25200,PDT|1541062800,-28800,PST|1552557600,-25200,PDT|1573117200,-28800,PST|1584007200,-25200,PDT|1604566800,-28800,PST|1615456800,-25200,PDT|1636016400,-28800,PST|1646906400,-25200,PDT|1667466000,-28800,PST|1678356000,-25200,PDT|1698915600,-28800,PST|1710410400,-25200,PDT|1730970000,-28800,PST|1741860000,-25200,PDT|1762419600,-28800,PST|1773309600,-25200,PDT|1793869200,-28800,PST|1804759200,-25200,PDT|1825318800,-28800,PST|1836208800,-25200,PDT|1856768400,-28800,PST|1867658400,-25200,PDT|1888218000,-28800,PST|1899712800,-25200,PDT|1920272400,-28800,PST|1931162400,-25200,PDT|1951722000,-28800,PST|1962612000,-25200,PDT|1983171600,-28800,PST|1994061600,-25200,PDT|2014621200,-28800,PST|2025511200,-25200,PDT|2046070800,-28800,PST|2056960800,-25200,PDT|2077520400,-28800,PST|2089015200,-25200,PDT|2109574800,-28800,PST|2120464800,-25200,PDT|2141024400,-28800,PST", 0
    str_42_len equ $ - str_42
    str_7 db "Asia/Taipei", 0
    str_7_len equ $ - str_7
    str_12 db "Asia/Dubai", 0
    str_12_len equ $ - str_12
    str_29 db "Asia/Taipei|-2335248360,28800,CST|-1017820800,32400,JST|-766224000,28800,CST|-745833600,32400,CDT|-733827600,28800,CST|-716889600,32400,CDT|-699613200,28800,CST|-683884800,32400,CDT|-670669200,28800,CST|-652348800,32400,CDT|-639133200,28800,CST|-620812800,32400,CDT|-607597200,28800,CST|-589276800,32400,CDT|-576061200,28800,CST|-562924800,32400,CDT|-541760400,28800,CST|-528710400,32400,CDT|-510224400,28800,CST|-497174400,32400,CDT|-478688400,28800,CST|-465638400,32400,CDT|-449830800,28800,CST|-434016000,32400,CDT|-418208400,28800,CST|-402480000,32400,CDT|-386672400,28800,CST|-370944000,32400,CDT|-355136400,28800,CST|-339408000,32400,CDT|-323600400,28800,CST|-302515200,32400,CDT|-291978000,28800,CST|-270979200,32400,CDT|-260442000,28800,CST|133977600,32400,CDT|149785200,28800,CST|165513600,32400,CDT|181321200,28800,CST|299606400,32400,CDT|307551600,28800,CST", 0
    str_29_len equ $ - str_29
    str_34 db "Asia/Dubai|-1577936472,14400,+04", 0
    str_34_len equ $ - str_34
    str_36 db "Europe/Paris|-2486592561,561,PMT|-1855958961,0,WET|-1689814800,3600,WEST|-1680397200,0,WET|-1665363600,3600,WEST|-1648342800,0,WET|-1635123600,3600,WEST|-1616893200,0,WET|-1604278800,3600,WEST|-1585443600,0,WET|-1574038800,3600,WEST|-1552266000,0,WET|-1539997200,3600,WEST|-1520557200,0,WET|-1507510800,3600,WEST|-1490576400,0,WET|-1470618000,3600,WEST|-1459126800,0,WET|-1444006800,3600,WEST|-1427677200,0,WET|-1411952400,3600,WEST|-1396227600,0,WET|-1379293200,3600,WEST|-1364778000,0,WET|-1348448400,3600,WEST|-1333328400,0,WET|-1316394000,3600,WEST|-1301274000,0,WET|-1284339600,3600,WEST|-1269824400,0,WET|-1253494800,3600,WEST|-1238374800,0,WET|-1221440400,3600,WEST|-1206925200,0,WET|-1191200400,3600,WEST|-1175475600,0,WET|-1160355600,3600,WEST|-1143421200,0,WET|-1127696400,3600,WEST|-1111971600,0,WET|-1096851600,3600,WEST|-1080522000,0,WET|-1063587600,3600,WEST|-1049072400,0,WET|-1033347600,3600,WEST|-1017622800,0,WET|-1002502800,3600,WEST|-986173200,0,WET|-969238800,3600,WEST|-950490000,0,WET|-942012000,3600,WEST|-932436000,7200,CEST|-857257200,3600,CET|-844556400,7200,CEST|-828226800,3600,CET|-812502000,7200,CEST|-800071200,7200,WEMT|-796266000,3600,WEST|-781052400,7200,WEMT|-766623600,3600,CET|196819200,7200,CEST|212540400,3600,CET|228877200,7200,CEST|243997200,3600,CET|260326800,7200,CEST|276051600,3600,CET|291776400,7200,CEST|307501200,3600,CET|323830800,7200,CEST|338950800,3600,CET|354675600,7200,CEST|370400400,3600,CET|386125200,7200,CEST|401850000,3600,CET|417574800,7200,CEST|433299600,3600,CET|449024400,7200,CEST|465354000,3600,CET|481078800,7200,CEST|496803600,3600,CET|512528400,7200,CEST|528253200,3600,CET|543978000,7200,CEST|559702800,3600,CET|575427600,7200,CEST|591152400,3600,CET|606877200,7200,CEST|622602000,3600,CET|638326800,7200,CEST|654656400,3600,CET|670381200,7200,CEST|686106000,3600,CET|701830800,7200,CEST|717555600,3600,CET|733280400,7200,CEST|749005200,3600,CET|764730000,7200,CEST|780454800,3600,CET|796179600,7200,CEST|811904400,3600,CET|828234000,7200,CEST|846723600,3600,CET|859424400,7200,CEST|878173200,3600,CET|890874000,7200,CEST|909622800,3600,CET|922323600,7200,CEST|941072400,3600,CET|954378000,7200,CEST|972522000,3600,CET|985827600,7200,CEST|1003971600,3600,CET|1017277200,7200,CEST|1036026000,3600,CET|1048726800,7200,CEST|1067475600,3600,CET|1080176400,7200,CEST|1098925200,3600,CET|1112230800,7200,CEST|1130374800,3600,CET|1143680400,7200,CEST|1161824400,3600,CET|1175130000,7200,CEST|1193274000,3600,CET|1206579600,7200,CEST|1225328400,3600,CET|1238029200,7200,CEST|1256778000,3600,CET|1269478800,7200,CEST|1288227600,3600,CET|1301533200,7200,CEST|1319677200,3600,CET|1332982800,7200,CEST|1351126800,3600,CET|1364432400,7200,CEST|1383181200,3600,CET|1395882000,7200,CEST|1414630800,3600,CET|1427331600,7200,CEST|1446080400,3600,CET|1459386000,7200,CEST|1477530000,3600,CET|1490835600,7200,CEST|1508979600,3600,CET|1522285200,7200,CEST|1540429200,3600,CET|1553734800,7200,CEST|1572483600,3600,CET|1585184400,7200,CEST|1603933200,3600,CET|1616634000,7200,CEST|1635382800,3600,CET|1648688400,7200,CEST|1666832400,3600,CET|1680138000,7200,CEST|1698282000,3600,CET|1711587600,7200,CEST|1730336400,3600,CET|1743037200,7200,CEST|1761786000,3600,CET|1774486800,7200,CEST|1793235600,3600,CET|1805936400,7200,CEST|1824685200,3600,CET|1837990800,7200,CEST|1856134800,3600,CET|1869440400,7200,CEST|1887584400,3600,CET|1900890000,7200,CEST|1919638800,3600,CET|1932339600,7200,CEST|1951088400,3600,CET|1963789200,7200,CEST|1982538000,3600,CET|1995843600,7200,CEST|2013987600,3600,CET|2027293200,7200,CEST|2045437200,3600,CET|2058742800,7200,CEST|2076886800,3600,CET|2090192400,7200,CEST|2108941200,3600,CET|2121642000,7200,CEST|2140390800,3600,CET", 0
    str_36_len equ $ - str_36
    str_40 db "America/Chicago|-2717647200,-21600,CST|-1633276800,-18000,CDT|-1615136400,-21600,CST|-1601827200,-18000,CDT|-1583686800,-21600,CST|-1563724800,-18000,CDT|-1551632400,-21600,CST|-1538928000,-18000,CDT|-1520182800,-21600,CST|-1504454400,-18000,CDT|-1491757200,-21600,CST|-1473004800,-18000,CDT|-1459702800,-21600,CST|-1441555200,-18000,CDT|-1428253200,-21600,CST|-1410105600,-18000,CDT|-1396803600,-21600,CST|-1378656000,-18000,CDT|-1365354000,-21600,CST|-1347206400,-18000,CDT|-1333904400,-21600,CST|-1315152000,-18000,CDT|-1301850000,-21600,CST|-1283702400,-18000,CDT|-1270400400,-21600,CST|-1252252800,-18000,CDT|-1238950800,-21600,CST|-1220803200,-18000,CDT|-1207501200,-21600,CST|-1189353600,-18000,CDT|-1176051600,-21600,CST|-1157299200,-18000,CDT|-1144602000,-21600,CST|-1125849600,-18000,CDT|-1112547600,-21600,CST|-1094400000,-18000,CDT|-1081098000,-21600,CST|-1067788800,-18000,EST|-1045414800,-21600,CST|-1031500800,-18000,CDT|-1018198800,-21600,CST|-1000051200,-18000,CDT|-986749200,-21600,CST|-967996800,-18000,CDT|-955299600,-21600,CST|-936547200,-18000,CDT|-923245200,-21600,CST|-905097600,-18000,CDT|-891795600,-21600,CST|-880214400,-18000,CWT|-769395600,-18000,CPT|-765392400,-21600,CST|-747244800,-18000,CDT|-733942800,-21600,CST|-715795200,-18000,CDT|-702493200,-21600,CST|-684345600,-18000,CDT|-671043600,-21600,CST|-652896000,-18000,CDT|-639594000,-21600,CST|-620841600,-18000,CDT|-608144400,-21600,CST|-589392000,-18000,CDT|-576090000,-21600,CST|-557942400,-18000,CDT|-544640400,-21600,CST|-526492800,-18000,CDT|-513190800,-21600,CST|-495043200,-18000,CDT|-481741200,-21600,CST|-463593600,-18000,CDT|-447267600,-21600,CST|-431539200,-18000,CDT|-415818000,-21600,CST|-400089600,-18000,CDT|-384368400,-21600,CST|-368640000,-18000,CDT|-352918800,-21600,CST|-337190400,-18000,CDT|-321469200,-21600,CST|-305740800,-18000,CDT|-289414800,-21600,CST|-273686400,-18000,CDT|-257965200,-21600,CST|-242236800,-18000,CDT|-226515600,-21600,CST|-210787200,-18000,CDT|-195066000,-21600,CST|-179337600,-18000,CDT|-163616400,-21600,CST|-147888000,-18000,CDT|-131562000,-21600,CST|-116438400,-18000,CDT|-100112400,-21600,CST|-84384000,-18000,CDT|-68662800,-21600,CST|-52934400,-18000,CDT|-37213200,-21600,CST|-21484800,-18000,CDT|-5763600,-21600,CST|9964800,-18000,CDT|25686000,-21600,CST|41414400,-18000,CDT|57740400,-21600,CST|73468800,-18000,CDT|89190000,-21600,CST|104918400,-18000,CDT|120639600,-21600,CST|126691200,-18000,CDT|152089200,-21600,CST|162374400,-18000,CDT|183538800,-21600,CST|199267200,-18000,CDT|215593200,-21600,CST|230716800,-18000,CDT|247042800,-21600,CST|262771200,-18000,CDT|278492400,-21600,CST|294220800,-18000,CDT|309942000,-21600,CST|325670400,-18000,CDT|341391600,-21600,CST|357120000,-18000,CDT|372841200,-21600,CST|388569600,-18000,CDT|404895600,-21600,CST|420019200,-18000,CDT|436345200,-21600,CST|452073600,-18000,CDT|467794800,-21600,CST|483523200,-18000,CDT|499244400,-21600,CST|514972800,-18000,CDT|530694000,-21600,CST|544608000,-18000,CDT|562143600,-21600,CST|576057600,-18000,CDT|594198000,-21600,CST|607507200,-18000,CDT|625647600,-21600,CST|638956800,-18000,CDT|657097200,-21600,CST|671011200,-18000,CDT|688546800,-21600,CST|702460800,-18000,CDT|719996400,-21600,CST|733910400,-18000,CDT|752050800,-21600,CST|765360000,-18000,CDT|783500400,-21600,CST|796809600,-18000,CDT|814950000,-21600,CST|828864000,-18000,CDT|846399600,-21600,CST|860313600,-18000,CDT|877849200,-21600,CST|891763200,-18000,CDT|909298800,-21600,CST|923212800,-18000,CDT|941353200,-21600,CST|954662400,-18000,CDT|972802800,-21600,CST|986112000,-18000,CDT|1004252400,-21600,CST|1018166400,-18000,CDT|1035702000,-21600,CST|1049616000,-18000,CDT|1067151600,-21600,CST|1081065600,-18000,CDT|1099206000,-21600,CST|1112515200,-18000,CDT|1130655600,-21600,CST|1143964800,-18000,CDT|1162105200,-21600,CST|1173600000,-18000,CDT|1193900400,-21600,CST|1205395200,-18000,CDT|1225954800,-21600,CST|1236844800,-18000,CDT|1257404400,-21600,CST|1268294400,-18000,CDT|1288854000,-21600,CST|1299744000,-18000,CDT|1320303600,-21600,CST|1331193600,-18000,CDT|1351753200,-21600,CST|1363248000,-18000,CDT|1383807600,-21600,CST|1394697600,-18000,CDT|1415257200,-21600,CST|1426147200,-18000,CDT|1446706800,-21600,CST|1457596800,-18000,CDT|1478156400,-21600,CST|1489046400,-18000,CDT|1509606000,-21600,CST|1520496000,-18000,CDT|1541055600,-21600,CST|1552550400,-18000,CDT|1573110000,-21600,CST|1584000000,-18000,CDT|1604559600,-21600,CST|1615449600,-18000,CDT|1636009200,-21600,CST|1646899200,-18000,CDT|1667458800,-21600,CST|1678348800,-18000,CDT|1698908400,-21600,CST|1710403200,-18000,CDT|1730962800,-21600,CST|1741852800,-18000,CDT|1762412400,-21600,CST|1773302400,-18000,CDT|1793862000,-21600,CST|1804752000,-18000,CDT|1825311600,-21600,CST|1836201600,-18000,CDT|1856761200,-21600,CST|1867651200,-18000,CDT|1888210800,-21600,CST|1899705600,-18000,CDT|1920265200,-21600,CST|1931155200,-18000,CDT|1951714800,-21600,CST|1962604800,-18000,CDT|1983164400,-21600,CST|1994054400,-18000,CDT|2014614000,-21600,CST|2025504000,-18000,CDT|2046063600,-21600,CST|2056953600,-18000,CDT|2077513200,-21600,CST|2089008000,-18000,CDT|2109567600,-21600,CST|2120457600,-18000,CDT|2141017200,-21600,CST", 0
    str_40_len equ $ - str_40
    str_2 db " elapsed=", 0
    str_2_len equ $ - str_2
    str_26 db "UTC|0,0,UTC", 0
    str_26_len equ $ - str_26
    str_28 db "Asia/Hong_Kong|-2056690800,28800,HKT|-900910800,32400,HKST|-891579600,30600,HKWT|-884248200,32400,JST|-761209200,28800,HKT|-747907200,32400,HKST|-728541000,28800,HKT|-717049800,32400,HKST|-697091400,28800,HKT|-683785800,32400,HKST|-668061000,28800,HKT|-654755400,32400,HKST|-636611400,28800,HKT|-623305800,32400,HKST|-605161800,28800,HKT|-591856200,32400,HKST|-573712200,28800,HKT|-559801800,32400,HKST|-541657800,28800,HKT|-528352200,32400,HKST|-510211800,28800,HKT|-498112200,32400,HKST|-478762200,28800,HKT|-466662600,32400,HKST|-446707800,28800,HKT|-435213000,32400,HKST|-415258200,28800,HKT|-403158600,32400,HKST|-383808600,28800,HKT|-371709000,32400,HKST|-352359000,28800,HKT|-340259400,32400,HKST|-320909400,28800,HKT|-308809800,32400,HKST|-288855000,28800,HKT|-277360200,32400,HKST|-257405400,28800,HKT|-245910600,32400,HKST|-225955800,28800,HKT|-213856200,32400,HKST|-194506200,28800,HKT|-182406600,32400,HKST|-163056600,28800,HKT|-148537800,32400,HKST|-132816600,28800,HKT|-117088200,32400,HKST|-101367000,28800,HKT|-85638600,32400,HKST|-69312600,28800,HKT|-53584200,32400,HKST|-37863000,28800,HKT|-22134600,32400,HKST|-6413400,28800,HKT|9315000,32400,HKST|25036200,28800,HKT|40764600,32400,HKST|56485800,28800,HKT|72214200,32400,HKST|88540200,28800,HKT|104268600,32400,HKST|119989800,28800,HKT|126041400,32400,HKST|151439400,28800,HKT|167167800,32400,HKST|182889000,28800,HKT|198617400,32400,HKST|214338600,28800,HKT|295385400,32400,HKST|309292200,28800,HKT", 0
    str_28_len equ $ - str_28
    str_3 db "ns", 0
    str_3_len equ $ - str_3
    str_18 db "America/Chicago", 0
    str_18_len equ $ - str_18
    str_19 db "America/Denver", 0
    str_19_len equ $ - str_19
    str_23 db "\\n", 0
    str_23_len equ $ - str_23
    str_24 db "JanFebMarAprMayJunJulAugSepOctNovDec", 0
    str_24_len equ $ - str_24
    str_27 db "Asia/Shanghai|-2177481943,28800,CST|-1600675200,32400,CDT|-1585904400,28800,CST|-933667200,32400,CDT|-922093200,28800,CST|-908870400,32400,CDT|-888829200,28800,CST|-881049600,32400,CDT|-767869200,28800,CST|-745833600,32400,CDT|-733827600,28800,CST|-716889600,32400,CDT|-699613200,28800,CST|-683884800,32400,CDT|-670669200,28800,CST|-652348800,32400,CDT|-650019600,28800,CST|515527200,32400,CDT|527014800,28800,CST|545162400,32400,CDT|558464400,28800,CST|577216800,32400,CDT|589914000,28800,CST|608666400,32400,CDT|621968400,28800,CST|640116000,32400,CDT|653418000,28800,CST|671565600,32400,CDT|684867600,28800,CST", 0
    str_27_len equ $ - str_27
    str_32 db "Asia/Singapore|-2177477725,24925,SMT|-2038200925,25200,+07|-1167634800,26400,+0720|-894180000,27000,+0730|-879665400,32400,+09|-767005200,27000,+0730|378662400,28800,+08", 0
    str_32_len equ $ - str_32
    str_1 db "fib(30)=", 0
    str_1_len equ $ - str_1
    str_21 db "America/Sao_Paulo", 0
    str_21_len equ $ - str_21
    str_25 db "SunMonTueWedThuFriSat", 0
    str_25_len equ $ - str_25
    str_33 db "Asia/Kolkata|-3645237208,21200,HMT|-3155694800,19270,MMT|-2019705670,19800,IST|-891581400,23400,+0630|-872058600,19800,IST|-862637400,23400,+0630|-764145000,19800,IST", 0
    str_33_len equ $ - str_33
    str_35 db "Europe/London|-3852662325,0,GMT|-1691964000,3600,BST|-1680472800,0,GMT|-1664143200,3600,BST|-1650146400,0,GMT|-1633903200,3600,BST|-1617487200,0,GMT|-1601848800,3600,BST|-1586037600,0,GMT|-1570399200,3600,BST|-1552168800,0,GMT|-1538344800,3600,BST|-1522533600,0,GMT|-1507500000,3600,BST|-1490565600,0,GMT|-1473631200,3600,BST|-1460930400,0,GMT|-1442786400,3600,BST|-1428876000,0,GMT|-1410732000,3600,BST|-1396216800,0,GMT|-1379282400,3600,BST|-1364767200,0,GMT|-1348437600,3600,BST|-1333317600,0,GMT|-1315778400,3600,BST|-1301263200,0,GMT|-1284328800,3600,BST|-1269813600,0,GMT|-1253484000,3600,BST|-1238364000,0,GMT|-1221429600,3600,BST|-1206914400,0,GMT|-1189980000,3600,BST|-1175464800,0,GMT|-1159135200,3600,BST|-1143410400,0,GMT|-1126476000,3600,BST|-1111960800,0,GMT|-1095631200,3600,BST|-1080511200,0,GMT|-1063576800,3600,BST|-1049061600,0,GMT|-1032127200,3600,BST|-1017612000,0,GMT|-1001282400,3600,BST|-986162400,0,GMT|-969228000,3600,BST|-950479200,0,GMT|-942012000,3600,BST|-904518000,7200,BDST|-896050800,3600,BST|-875487600,7200,BDST|-864601200,3600,BST|-844038000,7200,BDST|-832546800,3600,BST|-812588400,7200,BDST|-798073200,3600,BST|-781052400,7200,BDST|-772066800,3600,BST|-764805600,0,GMT|-748476000,3600,BST|-733356000,0,GMT|-719445600,3600,BST|-717030000,7200,BDST|-706748400,3600,BST|-699487200,0,GMT|-687996000,3600,BST|-668037600,0,GMT|-654732000,3600,BST|-636588000,0,GMT|-622072800,3600,BST|-605743200,0,GMT|-590623200,3600,BST|-574293600,0,GMT|-558568800,3600,BST|-542239200,0,GMT|-527119200,3600,BST|-512604000,0,GMT|-496274400,3600,BST|-481154400,0,GMT|-464220000,3600,BST|-449704800,0,GMT|-432165600,3600,BST|-417650400,0,GMT|-401320800,3600,BST|-386200800,0,GMT|-369266400,3600,BST|-354751200,0,GMT|-337816800,3600,BST|-323301600,0,GMT|-306972000,3600,BST|-291852000,0,GMT|-276732000,3600,BST|-257983200,0,GMT|-245282400,3600,BST|-226533600,0,GMT|-213228000,3600,BST|-195084000,0,GMT|-182383200,3600,BST|-163634400,0,GMT|-150933600,3600,BST|-132184800,0,GMT|-119484000,3600,BST|-100735200,0,GMT|-88034400,3600,BST|-68680800,0,GMT|-59004000,3600,BST|57722400,0,GMT|69818400,3600,BST|89172000,0,GMT|101268000,3600,BST|120621600,0,GMT|132717600,3600,BST|152071200,0,GMT|164167200,3600,BST|183520800,0,GMT|196221600,3600,BST|214970400,0,GMT|227671200,3600,BST|246420000,0,GMT|259120800,3600,BST|278474400,0,GMT|290570400,3600,BST|309924000,0,GMT|322020000,3600,BST|341373600,0,GMT|354675600,3600,BST|372819600,0,GMT|386125200,3600,BST|404269200,0,GMT|417574800,3600,BST|435718800,0,GMT|449024400,3600,BST|467773200,0,GMT|481078800,3600,BST|499222800,0,GMT|512528400,3600,BST|530672400,0,GMT|543978000,3600,BST|562122000,0,GMT|575427600,3600,BST|593571600,0,GMT|606877200,3600,BST|625626000,0,GMT|638326800,3600,BST|657075600,0,GMT|670381200,3600,BST|688525200,0,GMT|701830800,3600,BST|719974800,0,GMT|733280400,3600,BST|751424400,0,GMT|764730000,3600,BST|782874000,0,GMT|796179600,3600,BST|814323600,0,GMT|827974800,3600,BST|846723600,0,GMT|859424400,3600,BST|878173200,0,GMT|890874000,3600,BST|909622800,0,GMT|922323600,3600,BST|941072400,0,GMT|954378000,3600,BST|972522000,0,GMT|985827600,3600,BST|1003971600,0,GMT|1017277200,3600,BST|1036026000,0,GMT|1048726800,3600,BST|1067475600,0,GMT|1080176400,3600,BST|1098925200,0,GMT|1112230800,3600,BST|1130374800,0,GMT|1143680400,3600,BST|1161824400,0,GMT|1175130000,3600,BST|1193274000,0,GMT|1206579600,3600,BST|1225328400,0,GMT|1238029200,3600,BST|1256778000,0,GMT|1269478800,3600,BST|1288227600,0,GMT|1301533200,3600,BST|1319677200,0,GMT|1332982800,3600,BST|1351126800,0,GMT|1364432400,3600,BST|1383181200,0,GMT|1395882000,3600,BST|1414630800,0,GMT|1427331600,3600,BST|1446080400,0,GMT|1459386000,3600,BST|1477530000,0,GMT|1490835600,3600,BST|1508979600,0,GMT|1522285200,3600,BST|1540429200,0,GMT|1553734800,3600,BST|1572483600,0,GMT|1585184400,3600,BST|1603933200,0,GMT|1616634000,3600,BST|1635382800,0,GMT|1648688400,3600,BST|1666832400,0,GMT|1680138000,3600,BST|1698282000,0,GMT|1711587600,3600,BST|1730336400,0,GMT|1743037200,3600,BST|1761786000,0,GMT|1774486800,3600,BST|1793235600,0,GMT|1805936400,3600,BST|1824685200,0,GMT|1837990800,3600,BST|1856134800,0,GMT|1869440400,3600,BST|1887584400,0,GMT|1900890000,3600,BST|1919638800,0,GMT|1932339600,3600,BST|1951088400,0,GMT|1963789200,3600,BST|1982538000,0,GMT|1995843600,3600,BST|2013987600,0,GMT|2027293200,3600,BST|2045437200,0,GMT|2058742800,3600,BST|2076886800,0,GMT|2090192400,3600,BST|2108941200,0,GMT|2121642000,3600,BST|2140390800,0,GMT", 0
    str_35_len equ $ - str_35
    str_4 db "UTC", 0
    str_4_len equ $ - str_4
    str_14 db "Europe/Paris", 0
    str_14_len equ $ - str_14
    str_16 db "Europe/Berlin", 0
    str_16_len equ $ - str_16
    str_20 db "America/Los_Angeles", 0
    str_20_len equ $ - str_20
    str_39 db "America/New_York|-2717650800,-18000,EST|-1633280400,-14400,EDT|-1615140000,-18000,EST|-1601830800,-14400,EDT|-1583690400,-18000,EST|-1570381200,-14400,EDT|-1551636000,-18000,EST|-1536512400,-14400,EDT|-1523210400,-18000,EST|-1504458000,-14400,EDT|-1491760800,-18000,EST|-1473008400,-14400,EDT|-1459706400,-18000,EST|-1441558800,-14400,EDT|-1428256800,-18000,EST|-1410109200,-14400,EDT|-1396807200,-18000,EST|-1378659600,-14400,EDT|-1365357600,-18000,EST|-1347210000,-14400,EDT|-1333908000,-18000,EST|-1315155600,-14400,EDT|-1301853600,-18000,EST|-1283706000,-14400,EDT|-1270404000,-18000,EST|-1252256400,-14400,EDT|-1238954400,-18000,EST|-1220806800,-14400,EDT|-1207504800,-18000,EST|-1189357200,-14400,EDT|-1176055200,-18000,EST|-1157302800,-14400,EDT|-1144605600,-18000,EST|-1125853200,-14400,EDT|-1112551200,-18000,EST|-1094403600,-14400,EDT|-1081101600,-18000,EST|-1062954000,-14400,EDT|-1049652000,-18000,EST|-1031504400,-14400,EDT|-1018202400,-18000,EST|-1000054800,-14400,EDT|-986752800,-18000,EST|-968000400,-14400,EDT|-955303200,-18000,EST|-936550800,-14400,EDT|-923248800,-18000,EST|-905101200,-14400,EDT|-891799200,-18000,EST|-880218000,-14400,EWT|-769395600,-14400,EPT|-765396000,-18000,EST|-747248400,-14400,EDT|-733946400,-18000,EST|-715798800,-14400,EDT|-702496800,-18000,EST|-684349200,-14400,EDT|-671047200,-18000,EST|-652899600,-14400,EDT|-639597600,-18000,EST|-620845200,-14400,EDT|-608148000,-18000,EST|-589395600,-14400,EDT|-576093600,-18000,EST|-557946000,-14400,EDT|-544644000,-18000,EST|-526496400,-14400,EDT|-513194400,-18000,EST|-495046800,-14400,EDT|-481744800,-18000,EST|-463597200,-14400,EDT|-447271200,-18000,EST|-431542800,-14400,EDT|-415821600,-18000,EST|-400093200,-14400,EDT|-384372000,-18000,EST|-368643600,-14400,EDT|-352922400,-18000,EST|-337194000,-14400,EDT|-321472800,-18000,EST|-305744400,-14400,EDT|-289418400,-18000,EST|-273690000,-14400,EDT|-257968800,-18000,EST|-242240400,-14400,EDT|-226519200,-18000,EST|-210790800,-14400,EDT|-195069600,-18000,EST|-179341200,-14400,EDT|-163620000,-18000,EST|-147891600,-14400,EDT|-131565600,-18000,EST|-116442000,-14400,EDT|-100116000,-18000,EST|-84387600,-14400,EDT|-68666400,-18000,EST|-52938000,-14400,EDT|-37216800,-18000,EST|-21488400,-14400,EDT|-5767200,-18000,EST|9961200,-14400,EDT|25682400,-18000,EST|41410800,-14400,EDT|57736800,-18000,EST|73465200,-14400,EDT|89186400,-18000,EST|104914800,-14400,EDT|120636000,-18000,EST|126687600,-14400,EDT|152085600,-18000,EST|162370800,-14400,EDT|183535200,-18000,EST|199263600,-14400,EDT|215589600,-18000,EST|230713200,-14400,EDT|247039200,-18000,EST|262767600,-14400,EDT|278488800,-18000,EST|294217200,-14400,EDT|309938400,-18000,EST|325666800,-14400,EDT|341388000,-18000,EST|357116400,-14400,EDT|372837600,-18000,EST|388566000,-14400,EDT|404892000,-18000,EST|420015600,-14400,EDT|436341600,-18000,EST|452070000,-14400,EDT|467791200,-18000,EST|483519600,-14400,EDT|499240800,-18000,EST|514969200,-14400,EDT|530690400,-18000,EST|544604400,-14400,EDT|562140000,-18000,EST|576054000,-14400,EDT|594194400,-18000,EST|607503600,-14400,EDT|625644000,-18000,EST|638953200,-14400,EDT|657093600,-18000,EST|671007600,-14400,EDT|688543200,-18000,EST|702457200,-14400,EDT|719992800,-18000,EST|733906800,-14400,EDT|752047200,-18000,EST|765356400,-14400,EDT|783496800,-18000,EST|796806000,-14400,EDT|814946400,-18000,EST|828860400,-14400,EDT|846396000,-18000,EST|860310000,-14400,EDT|877845600,-18000,EST|891759600,-14400,EDT|909295200,-18000,EST|923209200,-14400,EDT|941349600,-18000,EST|954658800,-14400,EDT|972799200,-18000,EST|986108400,-14400,EDT|1004248800,-18000,EST|1018162800,-14400,EDT|1035698400,-18000,EST|1049612400,-14400,EDT|1067148000,-18000,EST|1081062000,-14400,EDT|1099202400,-18000,EST|1112511600,-14400,EDT|1130652000,-18000,EST|1143961200,-14400,EDT|1162101600,-18000,EST|1173596400,-14400,EDT|1193896800,-18000,EST|1205391600,-14400,EDT|1225951200,-18000,EST|1236841200,-14400,EDT|1257400800,-18000,EST|1268290800,-14400,EDT|1288850400,-18000,EST|1299740400,-14400,EDT|1320300000,-18000,EST|1331190000,-14400,EDT|1351749600,-18000,EST|1363244400,-14400,EDT|1383804000,-18000,EST|1394694000,-14400,EDT|1415253600,-18000,EST|1426143600,-14400,EDT|1446703200,-18000,EST|1457593200,-14400,EDT|1478152800,-18000,EST|1489042800,-14400,EDT|1509602400,-18000,EST|1520492400,-14400,EDT|1541052000,-18000,EST|1552546800,-14400,EDT|1573106400,-18000,EST|1583996400,-14400,EDT|1604556000,-18000,EST|1615446000,-14400,EDT|1636005600,-18000,EST|1646895600,-14400,EDT|1667455200,-18000,EST|1678345200,-14400,EDT|1698904800,-18000,EST|1710399600,-14400,EDT|1730959200,-18000,EST|1741849200,-14400,EDT|1762408800,-18000,EST|1773298800,-14400,EDT|1793858400,-18000,EST|1804748400,-14400,EDT|1825308000,-18000,EST|1836198000,-14400,EDT|1856757600,-18000,EST|1867647600,-14400,EDT|1888207200,-18000,EST|1899702000,-14400,EDT|1920261600,-18000,EST|1931151600,-14400,EDT|1951711200,-18000,EST|1962601200,-14400,EDT|1983160800,-18000,EST|1994050800,-14400,EDT|2014610400,-18000,EST|2025500400,-14400,EDT|2046060000,-18000,EST|2056950000,-14400,EDT|2077509600,-18000,EST|2089004400,-14400,EDT|2109564000,-18000,EST|2120454000,-14400,EDT|2141013600,-18000,EST", 0
    str_39_len equ $ - str_39
    str_13 db "Europe/London", 0
    str_13_len equ $ - str_13
    str_15 db "Europe/Moscow", 0
    str_15_len equ $ - str_15
    str_17 db "America/New_York", 0
    str_17_len equ $ - str_17
    str_37 db "Europe/Moscow|-2840149817,9017,MMT|-1688265017,9079,MMT|-1656819079,12679,MST|-1641353479,9079,MMT|-1627965079,16279,MDST|-1618716679,12679,MST|-1596429079,16279,MDST|-1593820800,14400,MSD|-1589860800,10800,MSK|-1542427200,14400,MSD|-1539493200,18000,+05|-1525323600,14400,MSD|-1522728000,10800,MSK|-1491188400,7200,EET|-1247536800,10800,MSK|354920400,14400,MSD|370728000,10800,MSK|386456400,14400,MSD|402264000,10800,MSK|417992400,14400,MSD|433800000,10800,MSK|449614800,14400,MSD|465346800,10800,MSK|481071600,14400,MSD|496796400,10800,MSK|512521200,14400,MSD|528246000,10800,MSK|543970800,14400,MSD|559695600,10800,MSK|575420400,14400,MSD|591145200,10800,MSK|606870000,14400,MSD|622594800,10800,MSK|638319600,14400,MSD|654649200,10800,MSK|670374000,10800,EEST|686102400,7200,EET|695779200,10800,MSK|701823600,14400,MSD|717548400,10800,MSK|733273200,14400,MSD|748998000,10800,MSK|764722800,14400,MSD|780447600,10800,MSK|796172400,14400,MSD|811897200,10800,MSK|828226800,14400,MSD|846370800,10800,MSK|859676400,14400,MSD|877820400,10800,MSK|891126000,14400,MSD|909270000,10800,MSK|922575600,14400,MSD|941324400,10800,MSK|954025200,14400,MSD|972774000,10800,MSK|985474800,14400,MSD|1004223600,10800,MSK|1017529200,14400,MSD|1035673200,10800,MSK|1048978800,14400,MSD|1067122800,10800,MSK|1080428400,14400,MSD|1099177200,10800,MSK|1111878000,14400,MSD|1130626800,10800,MSK|1143327600,14400,MSD|1162076400,10800,MSK|1174777200,14400,MSD|1193526000,10800,MSK|1206831600,14400,MSD|1224975600,10800,MSK|1238281200,14400,MSD|1256425200,10800,MSK|1269730800,14400,MSD|1288479600,10800,MSK|1301180400,14400,MSK|1414274400,10800,MSK", 0
    str_37_len equ $ - str_37
    str_41 db "America/Denver|-2717643600,-25200,MST|-1633273200,-21600,MDT|-1615132800,-25200,MST|-1601823600,-21600,MDT|-1583683200,-25200,MST|-1570374000,-21600,MDT|-1551628800,-25200,MST|-1538924400,-21600,MDT|-1534089600,-25200,MST|-880210800,-21600,MWT|-769395600,-21600,MPT|-765388800,-25200,MST|-147884400,-21600,MDT|-131558400,-25200,MST|-116434800,-21600,MDT|-100108800,-25200,MST|-84380400,-21600,MDT|-68659200,-25200,MST|-52930800,-21600,MDT|-37209600,-25200,MST|-21481200,-21600,MDT|-5760000,-25200,MST|9968400,-21600,MDT|25689600,-25200,MST|41418000,-21600,MDT|57744000,-25200,MST|73472400,-21600,MDT|89193600,-25200,MST|104922000,-21600,MDT|120643200,-25200,MST|126694800,-21600,MDT|152092800,-25200,MST|162378000,-21600,MDT|183542400,-25200,MST|199270800,-21600,MDT|215596800,-25200,MST|230720400,-21600,MDT|247046400,-25200,MST|262774800,-21600,MDT|278496000,-25200,MST|294224400,-21600,MDT|309945600,-25200,MST|325674000,-21600,MDT|341395200,-25200,MST|357123600,-21600,MDT|372844800,-25200,MST|388573200,-21600,MDT|404899200,-25200,MST|420022800,-21600,MDT|436348800,-25200,MST|452077200,-21600,MDT|467798400,-25200,MST|483526800,-21600,MDT|499248000,-25200,MST|514976400,-21600,MDT|530697600,-25200,MST|544611600,-21600,MDT|562147200,-25200,MST|576061200,-21600,MDT|594201600,-25200,MST|607510800,-21600,MDT|625651200,-25200,MST|638960400,-21600,MDT|657100800,-25200,MST|671014800,-21600,MDT|688550400,-25200,MST|702464400,-21600,MDT|720000000,-25200,MST|733914000,-21600,MDT|752054400,-25200,MST|765363600,-21600,MDT|783504000,-25200,MST|796813200,-21600,MDT|814953600,-25200,MST|828867600,-21600,MDT|846403200,-25200,MST|860317200,-21600,MDT|877852800,-25200,MST|891766800,-21600,MDT|909302400,-25200,MST|923216400,-21600,MDT|941356800,-25200,MST|954666000,-21600,MDT|972806400,-25200,MST|986115600,-21600,MDT|1004256000,-25200,MST|1018170000,-21600,MDT|1035705600,-25200,MST|1049619600,-21600,MDT|1067155200,-25200,MST|1081069200,-21600,MDT|1099209600,-25200,MST|1112518800,-21600,MDT|1130659200,-25200,MST|1143968400,-21600,MDT|1162108800,-25200,MST|1173603600,-21600,MDT|1193904000,-25200,MST|1205398800,-21600,MDT|1225958400,-25200,MST|1236848400,-21600,MDT|1257408000,-25200,MST|1268298000,-21600,MDT|1288857600,-25200,MST|1299747600,-21600,MDT|1320307200,-25200,MST|1331197200,-21600,MDT|1351756800,-25200,MST|1363251600,-21600,MDT|1383811200,-25200,MST|1394701200,-21600,MDT|1415260800,-25200,MST|1426150800,-21600,MDT|1446710400,-25200,MST|1457600400,-21600,MDT|1478160000,-25200,MST|1489050000,-21600,MDT|1509609600,-25200,MST|1520499600,-21600,MDT|1541059200,-25200,MST|1552554000,-21600,MDT|1573113600,-25200,MST|1584003600,-21600,MDT|1604563200,-25200,MST|1615453200,-21600,MDT|1636012800,-25200,MST|1646902800,-21600,MDT|1667462400,-25200,MST|1678352400,-21600,MDT|1698912000,-25200,MST|1710406800,-21600,MDT|1730966400,-25200,MST|1741856400,-21600,MDT|1762416000,-25200,MST|1773306000,-21600,MDT|1793865600,-25200,MST|1804755600,-21600,MDT|1825315200,-25200,MST|1836205200,-21600,MDT|1856764800,-25200,MST|1867654800,-21600,MDT|1888214400,-25200,MST|1899709200,-21600,MDT|1920268800,-25200,MST|1931158800,-21600,MDT|1951718400,-25200,MST|1962608400,-21600,MDT|1983168000,-25200,MST|1994058000,-21600,MDT|2014617600,-25200,MST|2025507600,-21600,MDT|2046067200,-25200,MST|2056957200,-21600,MDT|2077516800,-25200,MST|2089011600,-21600,MDT|2109571200,-25200,MST|2120461200,-21600,MDT|2141020800,-25200,MST", 0
    str_41_len equ $ - str_41
    str_43 db "America/Sao_Paulo|-1767214412,-10800,-03|-1206957600,-7200,-02|-1191362400,-10800,-03|-1175374800,-7200,-02|-1159826400,-10800,-03|-633819600,-7200,-02|-622069200,-10800,-03|-602283600,-7200,-02|-591832800,-10800,-03|-570747600,-7200,-02|-560210400,-10800,-03|-539125200,-7200,-02|-531352800,-10800,-03|-195426000,-7200,-02|-184197600,-10800,-03|-155163600,-7200,-02|-150069600,-10800,-03|-128898000,-7200,-02|-121125600,-10800,-03|-99954000,-7200,-02|-89589600,-10800,-03|-68418000,-7200,-02|-57967200,-10800,-03|499748400,-7200,-02|511236000,-10800,-03|530593200,-7200,-02|540266400,-10800,-03|562129200,-7200,-02|571197600,-10800,-03|592974000,-7200,-02|602042400,-10800,-03|624423600,-7200,-02|634701600,-10800,-03|656478000,-7200,-02|666756000,-10800,-03|687927600,-7200,-02|697600800,-10800,-03|719982000,-7200,-02|728445600,-10800,-03|750826800,-7200,-02|761709600,-10800,-03|782276400,-7200,-02|793159200,-10800,-03|813726000,-7200,-02|824004000,-10800,-03|844570800,-7200,-02|856058400,-10800,-03|876106800,-7200,-02|888717600,-10800,-03|908074800,-7200,-02|919562400,-10800,-03|938919600,-7200,-02|951616800,-10800,-03|970974000,-7200,-02|982461600,-10800,-03|1003028400,-7200,-02|1013911200,-10800,-03|1036292400,-7200,-02|1045360800,-10800,-03|1066532400,-7200,-02|1076810400,-10800,-03|1099364400,-7200,-02|1108864800,-10800,-03|1129431600,-7200,-02|1140314400,-10800,-03|1162695600,-7200,-02|1172368800,-10800,-03|1192330800,-7200,-02|1203213600,-10800,-03|1224385200,-7200,-02|1234663200,-10800,-03|1255834800,-7200,-02|1266717600,-10800,-03|1287284400,-7200,-02|1298167200,-10800,-03|1318734000,-7200,-02|1330221600,-10800,-03|1350788400,-7200,-02|1361066400,-10800,-03|1382238000,-7200,-02|1392516000,-10800,-03|1413687600,-7200,-02|1424570400,-10800,-03|1445137200,-7200,-02|1456020000,-10800,-03|1476586800,-7200,-02|1487469600,-10800,-03|1508036400,-7200,-02|1518919200,-10800,-03|1541300400,-7200,-02|1550368800,-10800,-03", 0
    str_43_len equ $ - str_43
    str_8 db "Asia/Tokyo", 0
    str_8_len equ $ - str_8
    str_9 db "Asia/Seoul", 0
    str_9_len equ $ - str_9
    str_11 db "Asia/Kolkata", 0
    str_11_len equ $ - str_11
    str_22 db "Australia/Sydney", 0
    str_22_len equ $ - str_22
    str_30 db "Asia/Tokyo|-2587712400,32400,JST|-683802000,36000,JDT|-672310800,32400,JST|-654771600,36000,JDT|-640861200,32400,JST|-620298000,36000,JDT|-609411600,32400,JST|-588848400,36000,JDT|-577962000,32400,JST", 0
    str_30_len equ $ - str_30
    str_38 db "Europe/Berlin|-2422054408,3600,CET|-1693706400,7200,CEST|-1680483600,3600,CET|-1663455600,7200,CEST|-1650150000,3600,CET|-1632006000,7200,CEST|-1618700400,3600,CET|-938905200,7200,CEST|-857257200,3600,CET|-844556400,7200,CEST|-828226800,3600,CET|-812502000,7200,CEST|-796777200,3600,CET|-781052400,7200,CEST|-776563200,10800,CEMT|-765936000,7200,CEST|-761180400,3600,CET|-748479600,7200,CEST|-733273200,3600,CET|-717631200,7200,CEST|-714610800,10800,CEMT|-710380800,7200,CEST|-701910000,3600,CET|-684975600,7200,CEST|-670460400,3600,CET|-654130800,7200,CEST|-639010800,3600,CET|323830800,7200,CEST|338950800,3600,CET|354675600,7200,CEST|370400400,3600,CET|386125200,7200,CEST|401850000,3600,CET|417574800,7200,CEST|433299600,3600,CET|449024400,7200,CEST|465354000,3600,CET|481078800,7200,CEST|496803600,3600,CET|512528400,7200,CEST|528253200,3600,CET|543978000,7200,CEST|559702800,3600,CET|575427600,7200,CEST|591152400,3600,CET|606877200,7200,CEST|622602000,3600,CET|638326800,7200,CEST|654656400,3600,CET|670381200,7200,CEST|686106000,3600,CET|701830800,7200,CEST|717555600,3600,CET|733280400,7200,CEST|749005200,3600,CET|764730000,7200,CEST|780454800,3600,CET|796179600,7200,CEST|811904400,3600,CET|828234000,7200,CEST|846723600,3600,CET|859424400,7200,CEST|878173200,3600,CET|890874000,7200,CEST|909622800,3600,CET|922323600,7200,CEST|941072400,3600,CET|954378000,7200,CEST|972522000,3600,CET|985827600,7200,CEST|1003971600,3600,CET|1017277200,7200,CEST|1036026000,3600,CET|1048726800,7200,CEST|1067475600,3600,CET|1080176400,7200,CEST|1098925200,3600,CET|1112230800,7200,CEST|1130374800,3600,CET|1143680400,7200,CEST|1161824400,3600,CET|1175130000,7200,CEST|1193274000,3600,CET|1206579600,7200,CEST|1225328400,3600,CET|1238029200,7200,CEST|1256778000,3600,CET|1269478800,7200,CEST|1288227600,3600,CET|1301533200,7200,CEST|1319677200,3600,CET|1332982800,7200,CEST|1351126800,3600,CET|1364432400,7200,CEST|1383181200,3600,CET|1395882000,7200,CEST|1414630800,3600,CET|1427331600,7200,CEST|1446080400,3600,CET|1459386000,7200,CEST|1477530000,3600,CET|1490835600,7200,CEST|1508979600,3600,CET|1522285200,7200,CEST|1540429200,3600,CET|1553734800,7200,CEST|1572483600,3600,CET|1585184400,7200,CEST|1603933200,3600,CET|1616634000,7200,CEST|1635382800,3600,CET|1648688400,7200,CEST|1666832400,3600,CET|1680138000,7200,CEST|1698282000,3600,CET|1711587600,7200,CEST|1730336400,3600,CET|1743037200,7200,CEST|1761786000,3600,CET|1774486800,7200,CEST|1793235600,3600,CET|1805936400,7200,CEST|1824685200,3600,CET|1837990800,7200,CEST|1856134800,3600,CET|1869440400,7200,CEST|1887584400,3600,CET|1900890000,7200,CEST|1919638800,3600,CET|1932339600,7200,CEST|1951088400,3600,CET|1963789200,7200,CEST|1982538000,3600,CET|1995843600,7200,CEST|2013987600,3600,CET|2027293200,7200,CEST|2045437200,3600,CET|2058742800,7200,CEST|2076886800,3600,CET|2090192400,7200,CEST|2108941200,3600,CET|2121642000,7200,CEST|2140390800,3600,CET", 0
    str_38_len equ $ - str_38
    str_44 db "Australia/Sydney|-2364113092,36000,AEST|-1672560000,39600,AEDT|-1665388800,36000,AEST|-883641600,39600,AEDT|-876124800,36000,AEST|-860400000,39600,AEDT|-844675200,36000,AEST|-828345600,39600,AEDT|-813225600,36000,AEST|57686400,39600,AEDT|67968000,36000,AEST|89136000,39600,AEDT|100022400,36000,AEST|120585600,39600,AEDT|131472000,36000,AEST|152035200,39600,AEDT|162921600,36000,AEST|183484800,39600,AEDT|194976000,36000,AEST|215539200,39600,AEDT|226425600,36000,AEST|246988800,39600,AEDT|257875200,36000,AEST|278438400,39600,AEDT|289324800,36000,AEST|309888000,39600,AEDT|320774400,36000,AEST|341337600,39600,AEDT|352224000,36000,AEST|372787200,39600,AEDT|386697600,36000,AEST|404841600,39600,AEDT|415728000,36000,AEST|436291200,39600,AEDT|447177600,36000,AEST|467740800,39600,AEDT|478627200,36000,AEST|499190400,39600,AEDT|511286400,36000,AEST|530035200,39600,AEDT|542736000,36000,AEST|562089600,39600,AEDT|574790400,36000,AEST|594144000,39600,AEDT|606240000,36000,AEST|625593600,39600,AEDT|636480000,36000,AEST|657043200,39600,AEDT|667929600,36000,AEST|688492800,39600,AEDT|699379200,36000,AEST|719942400,39600,AEDT|731433600,36000,AEST|751996800,39600,AEDT|762883200,36000,AEST|783446400,39600,AEDT|794332800,36000,AEST|814896000,39600,AEDT|828201600,36000,AEST|846345600,39600,AEDT|859651200,36000,AEST|877795200,39600,AEDT|891100800,36000,AEST|909244800,39600,AEDT|922550400,36000,AEST|941299200,39600,AEDT|954000000,36000,AEST|967305600,39600,AEDT|985449600,36000,AEST|1004198400,39600,AEDT|1017504000,36000,AEST|1035648000,39600,AEDT|1048953600,36000,AEST|1067097600,39600,AEDT|1080403200,36000,AEST|1099152000,39600,AEDT|1111852800,36000,AEST|1130601600,39600,AEDT|1143907200,36000,AEST|1162051200,39600,AEDT|1174752000,36000,AEST|1193500800,39600,AEDT|1207411200,36000,AEST|1222876800,39600,AEDT|1238601600,36000,AEST|1254326400,39600,AEDT|1270051200,36000,AEST|1286380800,39600,AEDT|1302105600,36000,AEST|1317830400,39600,AEDT|1333555200,36000,AEST|1349280000,39600,AEDT|1365004800,36000,AEST|1380729600,39600,AEDT|1396454400,36000,AEST|1412179200,39600,AEDT|1427904000,36000,AEST|1443628800,39600,AEDT|1459958400,36000,AEST|1475683200,39600,AEDT|1491408000,36000,AEST|1507132800,39600,AEDT|1522857600,36000,AEST|1538582400,39600,AEDT|1554307200,36000,AEST|1570032000,39600,AEDT|1585756800,36000,AEST|1601481600,39600,AEDT|1617206400,36000,AEST|1633536000,39600,AEDT|1649260800,36000,AEST|1664985600,39600,AEDT|1680710400,36000,AEST|1696435200,39600,AEDT|1712160000,36000,AEST|1727884800,39600,AEDT|1743609600,36000,AEST|1759334400,39600,AEDT|1775059200,36000,AEST|1790784000,39600,AEDT|1806508800,36000,AEST|1822838400,39600,AEDT|1838563200,36000,AEST|1854288000,39600,AEDT|1870012800,36000,AEST|1885737600,39600,AEDT|1901462400,36000,AEST|1917187200,39600,AEDT|1932912000,36000,AEST|1948636800,39600,AEDT|1964361600,36000,AEST|1980691200,39600,AEDT|1996416000,36000,AEST|2012140800,39600,AEDT|2027865600,36000,AEST|2043590400,39600,AEDT|2059315200,36000,AEST|2075040000,39600,AEDT|2090764800,36000,AEST|2106489600,39600,AEDT|2122214400,36000,AEST|2137939200,39600,AEDT", 0
    str_44_len equ $ - str_44
    str_5 db "Asia/Shanghai", 0
    str_5_len equ $ - str_5
    str_6 db "Asia/Hong_Kong", 0
    str_6_len equ $ - str_6
    str_10 db "Asia/Singapore", 0
    str_10_len equ $ - str_10
    str_31 db "Asia/Seoul|-1948782472,30600,KST|-1830414600,32400,JST|-767350800,32400,KST|-681210000,36000,KDT|-672228000,32400,KST|-654771600,36000,KDT|-640864800,32400,KST|-623408400,36000,KDT|-609415200,32400,KST|-588848400,36000,KDT|-577965600,32400,KST|-498128400,30600,KST|-462702600,34200,KDT|-451733400,30600,KST|-429784200,34200,KDT|-418296600,30600,KST|-399544200,34200,KDT|-387451800,30600,KST|-368094600,34200,KDT|-356002200,30600,KST|-336645000,34200,KDT|-324552600,30600,KST|-305195400,34200,KDT|-293103000,30600,KST|-264933000,32400,KST|547578000,36000,KDT|560883600,32400,KST|579027600,36000,KDT|592333200,32400,KST", 0
    str_31_len equ $ - str_31
    __global_std_time_monAbbr dq str_24
    __global_std_time_monAbbr_len dq 36
    __global_std_time_monAbbr_cap dq 36
    __global_std_time_weekAbbr dq str_25
    __global_std_time_weekAbbr_len dq 21
    __global_std_time_weekAbbr_cap dq 21
    __global_std_time_tzUTC dq str_26
    __global_std_time_tzUTC_len dq 11
    __global_std_time_tzUTC_cap dq 11
    __global_std_time_tzAsia_Shanghai dq str_27
    __global_std_time_tzAsia_Shanghai_len dq 613
    __global_std_time_tzAsia_Shanghai_cap dq 613
    __global_std_time_tzAsia_Hong_Kong dq str_28
    __global_std_time_tzAsia_Hong_Kong_len dq 1468
    __global_std_time_tzAsia_Hong_Kong_cap dq 1468
    __global_std_time_tzAsia_Taipei dq str_29
    __global_std_time_tzAsia_Taipei_len dq 868
    __global_std_time_tzAsia_Taipei_cap dq 868
    __global_std_time_tzAsia_Tokyo dq str_30
    __global_std_time_tzAsia_Tokyo_len dq 200
    __global_std_time_tzAsia_Tokyo_cap dq 200
    __global_std_time_tzAsia_Seoul dq str_31
    __global_std_time_tzAsia_Seoul_len dq 617
    __global_std_time_tzAsia_Seoul_cap dq 617
    __global_std_time_tzAsia_Singapore dq str_32
    __global_std_time_tzAsia_Singapore_len dq 169
    __global_std_time_tzAsia_Singapore_cap dq 169
    __global_std_time_tzAsia_Kolkata dq str_33
    __global_std_time_tzAsia_Kolkata_len dq 166
    __global_std_time_tzAsia_Kolkata_cap dq 166
    __global_std_time_tzAsia_Dubai dq str_34
    __global_std_time_tzAsia_Dubai_len dq 32
    __global_std_time_tzAsia_Dubai_cap dq 32
    __global_std_time_tzEurope_London dq str_35
    __global_std_time_tzEurope_London_len dq 4474
    __global_std_time_tzEurope_London_cap dq 4474
    __global_std_time_tzEurope_Paris dq str_36
    __global_std_time_tzEurope_Paris_len dq 3705
    __global_std_time_tzEurope_Paris_cap dq 3705
    __global_std_time_tzEurope_Moscow dq str_37
    __global_std_time_tzEurope_Moscow_len dq 1622
    __global_std_time_tzEurope_Moscow_cap dq 1622
    __global_std_time_tzEurope_Berlin dq str_38
    __global_std_time_tzEurope_Berlin_len dq 2912
    __global_std_time_tzEurope_Berlin_cap dq 2912
    __global_std_time_tzAmerica_New_York dq str_39
    __global_std_time_tzAmerica_New_York_len dq 5173
    __global_std_time_tzAmerica_New_York_cap dq 5173
    __global_std_time_tzAmerica_Chicago dq str_40
    __global_std_time_tzAmerica_Chicago_len dq 5172
    __global_std_time_tzAmerica_Chicago_cap dq 5172
    __global_std_time_tzAmerica_Denver dq str_41
    __global_std_time_tzAmerica_Denver_len dq 3422
    __global_std_time_tzAmerica_Denver_cap dq 3422
    __global_std_time_tzAmerica_Los_Angeles dq str_42
    __global_std_time_tzAmerica_Los_Angeles_len dq 4039
    __global_std_time_tzAmerica_Los_Angeles_cap dq 4039
    __global_std_time_tzAmerica_Sao_Paulo dq str_43
    __global_std_time_tzAmerica_Sao_Paulo_len dq 1943
    __global_std_time_tzAmerica_Sao_Paulo_cap dq 1943
    __global_std_time_tzAustralia_Sydney dq str_44
    __global_std_time_tzAustralia_Sydney_len dq 3080
    __global_std_time_tzAustralia_Sydney_cap dq 3080
