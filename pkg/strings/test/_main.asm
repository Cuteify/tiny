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
    sub rsp, 2392; 分配局部变量空间(2392字节, 含对齐)
    mov QWORD[rbp-48], 0
; 设置变量err
    mov QWORD [rbp-72], str_1
    mov QWORD [rbp-72+8], 5
    mov QWORD [rbp-72+16], 5
; 设置变量hello
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
    mov QWORD[rbp-80], RAX
; 设置变量l1
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 5
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_1
    if_1:
    mov QWORD[rbp-48], 1
; 设置变量err
    end_if_1:
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 5
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_2
    if_2:
    mov QWORD[rbp-48], 1
; 设置变量err
    end_if_2:
    mov QWORD [rbp-104], 0
    mov QWORD [rbp-104+8], 0
    mov QWORD [rbp-104+16], 0
; 设置变量empty
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-104]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-104+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-104+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
    mov QWORD[rbp-112], RAX
; 设置变量l2
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_3
    if_3:
    mov QWORD[rbp-48], 2
; 设置变量err
    end_if_3:
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_4
    if_4:
    mov QWORD[rbp-48], 2
; 设置变量err
    end_if_4:
    mov QWORD [rbp-136], str_2
    mov QWORD [rbp-136+8], 3
    mov QWORD [rbp-136+16], 3
; 设置变量abc
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-136]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-136+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-136+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-136]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-136+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-136+16]
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
    mov BYTE[rbp-137], al
; 设置变量e1
    movzx RAX, BYTE[rbp-137]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_5
    if_5:
    mov QWORD[rbp-48], 3
; 设置变量err
    end_if_5:
    mov QWORD [rbp-161], str_3
    mov QWORD [rbp-161+8], 3
    mov QWORD [rbp-161+16], 3
; 设置变量abd
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-136]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-136+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-136+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-161]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-161+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-161+16]
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
    mov BYTE[rbp-162], al
; 设置变量e2
    movzx RAX, BYTE[rbp-162]
; condition
    test RAX, RAX
    jz end_if_6
    if_6:
    mov QWORD[rbp-48], 4
; 设置变量err
    end_if_6:
    mov QWORD [rbp-186], str_2
    mov QWORD [rbp-186+8], 3
    mov QWORD [rbp-186+16], 3
; 设置变量abc2
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-136]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-136+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-136+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-186]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-186+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-186+16]
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
    mov BYTE[rbp-187], al
; 设置变量e3
    movzx RAX, BYTE[rbp-187]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_7
    if_7:
    mov QWORD[rbp-48], 40
; 设置变量err
    end_if_7:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 2
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderNew
    mov QWORD[rbp-195], RAX
; 设置变量eqBld
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-195]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], str_2
    mov QWORD [rsp+8+8], 3
    mov QWORD [rsp+8+16], 3
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数1
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_builderWriteString
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-195]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_builderString
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-219+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-219+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-219+16], RAX
; 设置变量made
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-219]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-219+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-219+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_2
    mov QWORD [rsp+24+8], 3
    mov QWORD [rsp+24+16], 3
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
    jz end_if_8
    if_8:
    mov QWORD[rbp-48], 41
; 设置变量err
    end_if_8:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-219]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-219+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-219+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_2
    mov QWORD [rsp+24+8], 3
    mov QWORD [rsp+24+16], 3
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
    jz end_if_9
    if_9:
    mov QWORD[rbp-48], 42
; 设置变量err
    end_if_9:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-195]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderFree
    mov QWORD [rbp-243], str_4
    mov QWORD [rbp-243+8], 1
    mov QWORD [rbp-243+16], 1
; 设置变量a
    mov QWORD [rbp-267], str_5
    mov QWORD [rbp-267+8], 1
    mov QWORD [rbp-267+16], 1
; 设置变量b
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-243]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-243+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-243+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-267]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-267+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-267+16]
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
    mov BYTE[rbp-268], al
; 设置变量n1
    movzx RAX, BYTE[rbp-268]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_10
    if_10:
    mov QWORD[rbp-48], 5
; 设置变量err
    end_if_10:
    mov QWORD [rbp-292], str_6
    mov QWORD [rbp-292+8], 11
    mov QWORD [rbp-292+16], 11
; 设置变量helloworld
    mov QWORD [rbp-316], str_7
    mov QWORD [rbp-316+8], 5
    mov QWORD [rbp-316+16], 5
; 设置变量world
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-292]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-292+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-292+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-316]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-316+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-316+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_index
    mov QWORD[rbp-324], RAX
; 设置变量i1
    mov RAX, QWORD[rbp-324]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 6
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_11
    if_11:
    mov QWORD[rbp-48], 6
; 设置变量err
    end_if_11:
    mov RAX, QWORD[rbp-324]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 6
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_12
    if_12:
    mov QWORD[rbp-48], 6
; 设置变量err
    end_if_12:
    mov QWORD [rbp-348], str_8
    mov QWORD [rbp-348+8], 3
    mov QWORD [rbp-348+16], 3
; 设置变量xyz
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-348]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-348+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-348+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_index
    mov QWORD[rbp-356], RAX
; 设置变量i2
    mov RAX, QWORD[rbp-356]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_13
    if_13:
    mov QWORD[rbp-48], 7
; 设置变量err
    end_if_13:
    mov RAX, QWORD[rbp-356]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_14
    if_14:
    mov QWORD[rbp-48], 7
; 设置变量err
    end_if_14:
    mov QWORD [rbp-380], str_9
    mov QWORD [rbp-380+8], 3
    mov QWORD [rbp-380+16], 3
; 设置变量ell
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-380]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-380+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-380+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_contains
    mov BYTE[rbp-381], al
; 设置变量c1
    movzx RAX, BYTE[rbp-381]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_15
    if_15:
    mov QWORD[rbp-48], 8
; 设置变量err
    end_if_15:
    mov QWORD [rbp-405], str_10
    mov QWORD [rbp-405+8], 3
    mov QWORD [rbp-405+16], 3
; 设置变量hel
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-405]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-405+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-405+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_hasPrefix
    mov BYTE[rbp-406], al
; 设置变量hp1
    movzx RAX, BYTE[rbp-406]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_16
    if_16:
    mov QWORD[rbp-48], 9
; 设置变量err
    end_if_16:
    mov QWORD [rbp-430], str_11
    mov QWORD [rbp-430+8], 3
    mov QWORD [rbp-430+16], 3
; 设置变量llo
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-430]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-430+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-430+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_hasSuffix
    mov BYTE[rbp-431], al
; 设置变量hs1
    movzx RAX, BYTE[rbp-431]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_17
    if_17:
    mov QWORD[rbp-48], 10
; 设置变量err
    end_if_17:
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
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_toUpper
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-455+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-455+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-455+16], RAX
; 设置变量u1
    mov QWORD [rbp-479], str_12
    mov QWORD [rbp-479+8], 5
    mov QWORD [rbp-479+16], 5
; 设置变量HELLO
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-455]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-455+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-455+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-479]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-479+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-479+16]
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
    jle end_if_18
    if_18:
    mov QWORD[rbp-48], 11
; 设置变量err
    end_if_18:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-455]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-455+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-455+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-479]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-479+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-479+16]
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
    jge end_if_19
    if_19:
    mov QWORD[rbp-48], 11
; 设置变量err
    end_if_19:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-479]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-479+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-479+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_toLower
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-503+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-503+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-503+16], RAX
; 设置变量lo1
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-503]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-503+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-503+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_20
    if_20:
    mov QWORD[rbp-48], 12
; 设置变量err
    end_if_20:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-503]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-503+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-503+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_21
    if_21:
    mov QWORD[rbp-48], 12
; 设置变量err
    end_if_21:
    mov QWORD [rbp-527], str_13
    mov QWORD [rbp-527+8], 9
    mov QWORD [rbp-527+16], 9
; 设置变量spaced
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-527]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-527+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-527+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_trimSpace
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-551+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-551+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-551+16], RAX
; 设置变量ts1
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-551]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-551+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-551+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_22
    if_22:
    mov QWORD[rbp-48], 13
; 设置变量err
    end_if_22:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-551]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-551+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-551+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_23
    if_23:
    mov QWORD[rbp-48], 13
; 设置变量err
    end_if_23:
    mov QWORD [rbp-575], str_14
    mov QWORD [rbp-575+8], 3
    mov QWORD [rbp-575+16], 3
; 设置变量aaa
    mov QWORD [rbp-599], str_4
    mov QWORD [rbp-599+8], 1
    mov QWORD [rbp-599+16], 1
; 设置变量a_char
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-575]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-575+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-575+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-599]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-599+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-599+16]
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
    mov QWORD[rbp-607], RAX
; 设置变量cnt1
    mov RAX, QWORD[rbp-607]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_24
    if_24:
    mov QWORD[rbp-48], 14
; 设置变量err
    end_if_24:
    mov RAX, QWORD[rbp-607]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_25
    if_25:
    mov QWORD[rbp-48], 14
; 设置变量err
    end_if_25:
    mov QWORD [rbp-631], str_15
    mov QWORD [rbp-631+8], 7
    mov QWORD [rbp-631+16], 7
; 设置变量xxhello
    mov QWORD [rbp-655], str_16
    mov QWORD [rbp-655+8], 1
    mov QWORD [rbp-655+16], 1
; 设置变量x_char
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-631]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-631+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-631+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-655]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-655+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-655+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_trimLeft
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-679+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-679+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-679+16], RAX
; 设置变量tl1
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-679]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-679+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-679+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_26
    if_26:
    mov QWORD[rbp-48], 15
; 设置变量err
    end_if_26:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-679]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-679+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-679+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_27
    if_27:
    mov QWORD[rbp-48], 15
; 设置变量err
    end_if_27:
    mov QWORD [rbp-703], str_17
    mov QWORD [rbp-703+8], 7
    mov QWORD [rbp-703+16], 7
; 设置变量helloxx
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-703]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-703+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-703+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-655]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-655+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-655+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_trimRight
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-727+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-727+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-727+16], RAX
; 设置变量tr1
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-727]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-727+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-727+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_28
    if_28:
    mov QWORD[rbp-48], 16
; 设置变量err
    end_if_28:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-727]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-727+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-727+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_29
    if_29:
    mov QWORD[rbp-48], 16
; 设置变量err
    end_if_29:
    mov QWORD [rbp-751], str_18
    mov QWORD [rbp-751+8], 9
    mov QWORD [rbp-751+16], 9
; 设置变量xxhelloxx
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-751]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-751+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-751+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-655]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-655+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-655+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_trim
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-775+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-775+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-775+16], RAX
; 设置变量trm1
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-775]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-775+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-775+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_30
    if_30:
    mov QWORD[rbp-48], 17
; 设置变量err
    end_if_30:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-775]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-775+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-775+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_31
    if_31:
    mov QWORD[rbp-48], 17
; 设置变量err
    end_if_31:
    mov QWORD [rbp-799], str_19
    mov QWORD [rbp-799+8], 1
    mov QWORD [rbp-799+16], 1
; 设置变量o_char
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-292]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-292+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-292+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-799]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-799+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-799+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_lastIndex
    mov QWORD[rbp-807], RAX
; 设置变量li1
    mov RAX, QWORD[rbp-807]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 7
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_32
    if_32:
    mov QWORD[rbp-48], 18
; 设置变量err
    end_if_32:
    mov RAX, QWORD[rbp-807]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 7
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_33
    if_33:
    mov QWORD[rbp-48], 18
; 设置变量err
    end_if_33:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], 104
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_indexByte
    mov QWORD[rbp-815], RAX
; 设置变量ib1
    mov RAX, QWORD[rbp-815]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_34
    if_34:
    mov QWORD[rbp-48], 19
; 设置变量err
    end_if_34:
    mov RAX, QWORD[rbp-815]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_35
    if_35:
    mov QWORD[rbp-48], 19
; 设置变量err
    end_if_35:
    mov QWORD [rbp-839], str_20
    mov QWORD [rbp-839+8], 5
    mov QWORD [rbp-839+16], 5
; 设置变量vowels
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-839]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-839+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-839+16]
    mov QWORD [rsp+24+16], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_containsAny
    mov BYTE[rbp-840], al
; 设置变量ca1
    movzx RAX, BYTE[rbp-840]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_36
    if_36:
    mov QWORD[rbp-48], 20
; 设置变量err
    end_if_36:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-136]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-136+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-136+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-136]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-136+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-136+16]
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
    mov QWORD[rbp-848], RAX
; 设置变量cmp1
    mov RAX, QWORD[rbp-848]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_37
    if_37:
    mov QWORD[rbp-48], 21
; 设置变量err
    end_if_37:
    mov RAX, QWORD[rbp-848]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_38
    if_38:
    mov QWORD[rbp-48], 21
; 设置变量err
    end_if_38:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-136]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-136+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-136+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-161]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-161+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-161+16]
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
    mov QWORD[rbp-856], RAX
; 设置变量cmp2
    mov RAX, QWORD[rbp-856]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_39
    if_39:
    mov QWORD[rbp-48], 22
; 设置变量err
    end_if_39:
    mov RAX, QWORD[rbp-856]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_40
    if_40:
    mov QWORD[rbp-48], 22
; 设置变量err
    end_if_40:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-161]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-161+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-161+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-136]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-136+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-136+16]
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
    mov QWORD[rbp-864], RAX
; 设置变量cmp3
    mov RAX, QWORD[rbp-864]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_41
    if_41:
    mov QWORD[rbp-48], 23
; 设置变量err
    end_if_41:
    mov RAX, QWORD[rbp-864]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_42
    if_42:
    mov QWORD[rbp-48], 23
; 设置变量err
    end_if_42:
    mov QWORD [rbp-888], str_21
    mov QWORD [rbp-888+8], 3
    mov QWORD [rbp-888+16], 3
; 设置变量numstr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-888]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-888+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-888+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_atoi
    mov QWORD[rbp-896], RAX
; 设置变量a1
    mov RAX, QWORD[rbp-896]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 123
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_43
    if_43:
    mov QWORD[rbp-48], 24
; 设置变量err
    end_if_43:
    mov RAX, QWORD[rbp-896]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 123
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_44
    if_44:
    mov QWORD[rbp-48], 24
; 设置变量err
    end_if_44:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 123
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_itoa
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-920+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-920+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-920+16], RAX
; 设置变量it1
    mov QWORD [rbp-944], str_21
    mov QWORD [rbp-944+8], 3
    mov QWORD [rbp-944+16], 3
; 设置变量num123
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-920]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-920+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-920+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-944]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-944+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-944+16]
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
    jle end_if_45
    if_45:
    mov QWORD[rbp-48], 25
; 设置变量err
    end_if_45:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-920]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-920+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-920+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-944]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-944+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-944+16]
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
    jge end_if_46
    if_46:
    mov QWORD[rbp-48], 25
; 设置变量err
    end_if_46:
    mov QWORD [rbp-968], str_22
    mov QWORD [rbp-968+8], 4
    mov QWORD [rbp-968+16], 4
; 设置变量truestr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-968]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-968+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-968+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_parseBool
    mov BYTE[rbp-969], al
; 设置变量pb1
    movzx RAX, BYTE[rbp-969]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_47
    if_47:
    mov QWORD[rbp-48], 26
; 设置变量err
    end_if_47:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_formatBool
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-993+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-993+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-993+16], RAX
; 设置变量fb1
    mov QWORD [rbp-1017], str_23
    mov QWORD [rbp-1017+8], 5
    mov QWORD [rbp-1017+16], 5
; 设置变量falsestr
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-993]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-993+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-993+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1017]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1017+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1017+16]
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
    jle end_if_48
    if_48:
    mov QWORD[rbp-48], 27
; 设置变量err
    end_if_48:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-993]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-993+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-993+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1017]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1017+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1017+16]
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
    jge end_if_49
    if_49:
    mov QWORD[rbp-48], 27
; 设置变量err
    end_if_49:
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_24
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov QWORD [rsp+24], str_1
    mov QWORD [rsp+24+8], 5
    mov QWORD [rsp+24+16], 5
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_equalFold
    mov BYTE[rbp-1018], al
; 设置变量ef1
    movzx RAX, BYTE[rbp-1018]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_50
    if_50:
    mov QWORD[rbp-48], 30
; 设置变量err
    end_if_50:
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_2
    mov QWORD [rsp+0+8], 3
    mov QWORD [rsp+0+16], 3
; 参数0
    mov QWORD [rsp+24], str_25
    mov QWORD [rsp+24+8], 3
    mov QWORD [rsp+24+16], 3
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_equalFold
    mov BYTE[rbp-1019], al
; 设置变量ef2
    movzx RAX, BYTE[rbp-1019]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_51
    if_51:
    mov QWORD[rbp-48], 31
; 设置变量err
    end_if_51:
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_2
    mov QWORD [rsp+0+8], 3
    mov QWORD [rsp+0+16], 3
; 参数0
    mov QWORD [rsp+24], str_3
    mov QWORD [rsp+24+8], 3
    mov QWORD [rsp+24+16], 3
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_equalFold
    mov BYTE[rbp-1020], al
; 设置变量ef3
    movzx RAX, BYTE[rbp-1020]
; condition
    test RAX, RAX
    jz end_if_52
    if_52:
    mov QWORD[rbp-48], 32
; 设置变量err
    end_if_52:
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_2
    mov QWORD [rsp+0+8], 3
    mov QWORD [rsp+0+16], 3
; 参数0
    mov QWORD [rsp+24], str_26
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
    call std_strings_equalFold
    mov BYTE[rbp-1021], al
; 设置变量ef4
    movzx RAX, BYTE[rbp-1021]
; condition
    test RAX, RAX
    jz end_if_53
    if_53:
    mov QWORD[rbp-48], 33
; 设置变量err
    end_if_53:
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_1
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov QWORD [rsp+24], str_20
    mov QWORD [rsp+24+8], 5
    mov QWORD [rsp+24+16], 5
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_indexAny
    mov QWORD[rbp-1029], RAX
; 设置变量ia1
    mov RAX, QWORD[rbp-1029]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_54
    if_54:
    mov QWORD[rbp-48], 34
; 设置变量err
    end_if_54:
    mov RAX, QWORD[rbp-1029]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_55
    if_55:
    mov QWORD[rbp-48], 34
; 设置变量err
    end_if_55:
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_1
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov QWORD [rsp+24], str_8
    mov QWORD [rsp+24+8], 3
    mov QWORD [rsp+24+16], 3
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_indexAny
    mov QWORD[rbp-1037], RAX
; 设置变量ia2
    mov RAX, QWORD[rbp-1037]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_56
    if_56:
    mov QWORD[rbp-48], 35
; 设置变量err
    end_if_56:
    mov RAX, QWORD[rbp-1037]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_57
    if_57:
    mov QWORD[rbp-48], 35
; 设置变量err
    end_if_57:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-292]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-292+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-292+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], 111
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_lastIndexByte
    mov QWORD[rbp-1045], RAX
; 设置变量lib1
    mov RAX, QWORD[rbp-1045]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 7
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_58
    if_58:
    mov QWORD[rbp-48], 36
; 设置变量err
    end_if_58:
    mov RAX, QWORD[rbp-1045]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 7
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_59
    if_59:
    mov QWORD[rbp-48], 36
; 设置变量err
    end_if_59:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-292]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-292+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-292+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], 120
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_lastIndexByte
    mov QWORD[rbp-1053], RAX
; 设置变量lib2
    mov RAX, QWORD[rbp-1053]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_60
    if_60:
    mov QWORD[rbp-48], 37
; 设置变量err
    end_if_60:
    mov RAX, QWORD[rbp-1053]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, -1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_61
    if_61:
    mov QWORD[rbp-48], 37
; 设置变量err
    end_if_61:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-575]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-575+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-575+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], 97
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_countByte
    mov QWORD[rbp-1061], RAX
; 设置变量cb1
    mov RAX, QWORD[rbp-1061]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_62
    if_62:
    mov QWORD[rbp-48], 38
; 设置变量err
    end_if_62:
    mov RAX, QWORD[rbp-1061]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_63
    if_63:
    mov QWORD[rbp-48], 38
; 设置变量err
    end_if_63:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], 120
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_countByte
    mov QWORD[rbp-1069], RAX
; 设置变量cb2
    mov RAX, QWORD[rbp-1069]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_64
    if_64:
    mov QWORD[rbp-48], 39
; 设置变量err
    end_if_64:
    mov RAX, QWORD[rbp-1069]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_65
    if_65:
    mov QWORD[rbp-48], 39
; 设置变量err
    end_if_65:
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
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_clone
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1093+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1093+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1093+16], RAX
; 设置变量cl1
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1093]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1093+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1093+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_66
    if_66:
    mov QWORD[rbp-48], 41
; 设置变量err
    end_if_66:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1093]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1093+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1093+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_67
    if_67:
    mov QWORD[rbp-48], 41
; 设置变量err
    end_if_67:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_2
    mov QWORD [rsp+0+8], 3
    mov QWORD [rsp+0+16], 3
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_clone
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1117+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1117+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1117+16], RAX
; 设置变量cl2
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-1117]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1117+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1117+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_68
    if_68:
    mov QWORD[rbp-48], 42
; 设置变量err
    end_if_68:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_2
    mov QWORD [rsp+0+8], 3
    mov QWORD [rsp+0+16], 3
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_reverse
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1141+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1141+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1141+16], RAX
; 设置变量rv1
    mov QWORD [rbp-1165], str_27
    mov QWORD [rbp-1165+8], 3
    mov QWORD [rbp-1165+16], 3
; 设置变量cba
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1141]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1141+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1141+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1165]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1165+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1165+16]
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
    jle end_if_69
    if_69:
    mov QWORD[rbp-48], 43
; 设置变量err
    end_if_69:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1141]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1141+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1141+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1165]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1165+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1165+16]
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
    jge end_if_70
    if_70:
    mov QWORD[rbp-48], 43
; 设置变量err
    end_if_70:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 0
    mov QWORD [rsp+0+8], 0
    mov QWORD [rsp+0+16], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_reverse
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1189+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1189+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1189+16], RAX
; 设置变量rv2
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-1189]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1189+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1189+16]
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
    jbe end_if_71
    if_71:
    mov QWORD[rbp-48], 44
; 设置变量err
    end_if_71:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_26
    mov QWORD [rsp+0+8], 2
    mov QWORD [rsp+0+16], 2
; 参数0
    mov QWORD [rsp+24], 3
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_repeatN
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1213+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1213+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1213+16], RAX
; 设置变量rp1
    mov QWORD [rbp-1237], str_28
    mov QWORD [rbp-1237+8], 6
    mov QWORD [rbp-1237+16], 6
; 设置变量ababab
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1213]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1213+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1213+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1237]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1237+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1237+16]
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
    jle end_if_72
    if_72:
    mov QWORD[rbp-48], 45
; 设置变量err
    end_if_72:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1213]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1213+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1213+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1237]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1237+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1237+16]
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
    jge end_if_73
    if_73:
    mov QWORD[rbp-48], 45
; 设置变量err
    end_if_73:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_16
    mov QWORD [rsp+0+8], 1
    mov QWORD [rsp+0+16], 1
; 参数0
    mov QWORD [rsp+24], 0
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_repeatN
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1261+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1261+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1261+16], RAX
; 设置变量rp2
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-1261]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1261+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1261+16]
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
    jbe end_if_74
    if_74:
    mov QWORD[rbp-48], 46
; 设置变量err
    end_if_74:
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_6
    mov QWORD [rsp+0+8], 11
    mov QWORD [rsp+0+16], 11
; 参数0
    mov QWORD [rsp+24], str_29
    mov QWORD [rsp+24+8], 6
    mov QWORD [rsp+24+16], 6
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_trimPrefix
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1285+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1285+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1285+16], RAX
; 设置变量tp1
    mov QWORD [rbp-1309], str_7
    mov QWORD [rbp-1309+8], 5
    mov QWORD [rbp-1309+16], 5
; 设置变量world2
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1285]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1285+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1285+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1309]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1309+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1309+16]
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
    jle end_if_75
    if_75:
    mov QWORD[rbp-48], 47
; 设置变量err
    end_if_75:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1285]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1285+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1285+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1309]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1309+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1309+16]
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
    jge end_if_76
    if_76:
    mov QWORD[rbp-48], 47
; 设置变量err
    end_if_76:
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_30
    mov QWORD [rsp+0+8], 8
    mov QWORD [rsp+0+16], 8
; 参数0
    mov QWORD [rsp+24], str_31
    mov QWORD [rsp+24+8], 3
    mov QWORD [rsp+24+16], 3
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_trimSuffix
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1333+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1333+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1333+16], RAX
; 设置变量ts2
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1333]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1333+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1333+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_77
    if_77:
    mov QWORD[rbp-48], 48
; 设置变量err
    end_if_77:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1333]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1333+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1333+16]
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_78
    if_78:
    mov QWORD[rbp-48], 48
; 设置变量err
    end_if_78:
    push 0
; 参数3
    push 4
    push 4
    push str_32
; 参数2
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_6
    mov QWORD [rsp+0+8], 11
    mov QWORD [rsp+0+16], 11
; 参数0
    mov QWORD [rsp+24], str_7
    mov QWORD [rsp+24+8], 5
    mov QWORD [rsp+24+16], 5
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_replace
    add rsp, 32; clean stack args
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1357+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1357+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1357+16], RAX
; 设置变量rpl1
    mov QWORD [rbp-1381], str_33
    mov QWORD [rbp-1381+8], 10
    mov QWORD [rbp-1381+16], 10
; 设置变量hellolute
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1357]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1357+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1357+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1381]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1381+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1381+16]
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
    jle end_if_79
    if_79:
    mov QWORD[rbp-48], 49
; 设置变量err
    end_if_79:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1357]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1357+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1357+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1381]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1381+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1381+16]
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
    jge end_if_80
    if_80:
    mov QWORD[rbp-48], 49
; 设置变量err
    end_if_80:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_26
    mov QWORD [rsp+0+8], 2
    mov QWORD [rsp+0+16], 2
; 参数0
    mov QWORD [rsp+24], 2
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_repeat
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1405+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1405+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1405+16], RAX
; 设置变量rpt1
    mov QWORD [rbp-1429], str_34
    mov QWORD [rbp-1429+8], 4
    mov QWORD [rbp-1429+16], 4
; 设置变量abab
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1405]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1405+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1405+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1429]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1429+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1429+16]
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
    jle end_if_81
    if_81:
    mov QWORD[rbp-48], 50
; 设置变量err
    end_if_81:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1405]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1405+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1405+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1429]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1429+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1429+16]
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
    jge end_if_82
    if_82:
    mov QWORD[rbp-48], 50
; 设置变量err
    end_if_82:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], 104
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_containsRune
    mov BYTE[rbp-1430], al
; 设置变量cr1
    movzx RAX, BYTE[rbp-1430]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_83
    if_83:
    mov QWORD[rbp-48], 58
; 设置变量err
    end_if_83:
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_1
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov QWORD [rsp+24], str_8
    mov QWORD [rsp+24+8], 3
    mov QWORD [rsp+24+16], 3
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_containsAny
    mov BYTE[rbp-1431], al
; 设置变量ca2
    movzx RAX, BYTE[rbp-1431]
; condition
    test RAX, RAX
    jz end_if_84
    if_84:
    mov QWORD[rbp-48], 59
; 设置变量err
    end_if_84:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-72+16]
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
    call std_strings_lastIndex
    mov QWORD[rbp-1439], RAX
; 设置变量li2
    mov RAX, QWORD[rbp-1439]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 5
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_85
    if_85:
    mov QWORD[rbp-48], 60
; 设置变量err
    end_if_85:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_35
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_parseBool
    mov BYTE[rbp-1440], al
; 设置变量pb2
    movzx RAX, BYTE[rbp-1440]
; condition
    test RAX, RAX
    jz end_if_86
    if_86:
    mov QWORD[rbp-48], 61
; 设置变量err
    end_if_86:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_23
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_parseBool
    mov BYTE[rbp-1441], al
; 设置变量pb3
    movzx RAX, BYTE[rbp-1441]
; condition
    test RAX, RAX
    jz end_if_87
    if_87:
    mov QWORD[rbp-48], 62
; 设置变量err
    end_if_87:
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_36
    mov QWORD [rsp+0+8], 1
    mov QWORD [rsp+0+16], 1
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_parseBool
    mov BYTE[rbp-1442], al
; 设置变量pb4
    movzx RAX, BYTE[rbp-1442]
; condition
    test RAX, RAX
    jz end_if_88
    if_88:
    mov QWORD[rbp-48], 63
; 设置变量err
    end_if_88:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_formatBool
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1466+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1466+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1466+16], RAX
; 设置变量fb2
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1466]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1466+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1466+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-968]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-968+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-968+16]
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
    jle end_if_89
    if_89:
    mov QWORD[rbp-48], 64
; 设置变量err
    end_if_89:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1466]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1466+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1466+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-968]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-968+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-968+16]
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
    jge end_if_90
    if_90:
    mov QWORD[rbp-48], 64
; 设置变量err
    end_if_90:
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], 0
    mov QWORD [rsp+0+8], 0
    mov QWORD [rsp+0+16], 0
; 参数0
    mov QWORD [rsp+24], str_16
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
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_trim
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1490+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1490+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1490+16], RAX
; 设置变量trm2
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-1490]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1490+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1490+16]
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
    jbe end_if_91
    if_91:
    mov QWORD[rbp-48], 65
; 设置变量err
    end_if_91:
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], 0
    mov QWORD [rsp+0+8], 0
    mov QWORD [rsp+0+16], 0
; 参数0
    mov QWORD [rsp+24], str_16
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
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_trimLeft
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1514+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1514+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1514+16], RAX
; 设置变量tl2
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-1514]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1514+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1514+16]
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
    jbe end_if_92
    if_92:
    mov QWORD[rbp-48], 66
; 设置变量err
    end_if_92:
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], 0
    mov QWORD [rsp+0+8], 0
    mov QWORD [rsp+0+16], 0
; 参数0
    mov QWORD [rsp+24], str_16
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
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_trimRight
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1538+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1538+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1538+16], RAX
; 设置变量tr2
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-1538]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1538+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1538+16]
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
    jbe end_if_93
    if_93:
    mov QWORD[rbp-48], 67
; 设置变量err
    end_if_93:
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_37
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov QWORD [rsp+24], str_38
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
    call std_strings_split
    mov QWORD[rbp-1546], RAX
; 设置变量r1
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1546]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_94
    if_94:
    mov QWORD[rbp-48], 70
; 设置变量err
    end_if_94:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1546]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_splitGet
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1570+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1570+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1570+16], RAX
; 设置变量d1a
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1570]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1570+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1570+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_4
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_95
    if_95:
    mov QWORD[rbp-48], 71
; 设置变量err
    end_if_95:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1570]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1570+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1570+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_4
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_96
    if_96:
    mov QWORD[rbp-48], 71
; 设置变量err
    end_if_96:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1546]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_splitGet
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1594+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1594+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1594+16], RAX
; 设置变量d1b
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1594]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1594+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1594+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_5
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_97
    if_97:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1594]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1594+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1594+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_5
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_98
    if_98:
    mov QWORD[rbp-48], 72
; 设置变量err
    end_if_98:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1594]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1594+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1594+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_5
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_99
    if_99:
    mov QWORD[rbp-48], 72
; 设置变量err
    end_if_99:
    end_if_97:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1546]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 2
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_splitGet
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1618+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1618+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1618+16], RAX
; 设置变量d1c
    mov QWORD [rbp-1642], str_39
    mov QWORD [rbp-1642+8], 1
    mov QWORD [rbp-1642+16], 1
; 设置变量expC
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1618]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1618+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1618+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1642]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1642+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1642+16]
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
    jle end_if_100
    if_100:
    mov QWORD[rbp-48], 73
; 设置变量err
    end_if_100:
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1618]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1618+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1618+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1642]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1642+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1642+16]
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
    jge end_if_101
    if_101:
    mov QWORD[rbp-48], 73
; 设置变量err
    end_if_101:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1546]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitFree
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_2
    mov QWORD [rsp+0+8], 3
    mov QWORD [rsp+0+16], 3
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
    call std_strings_split
    mov QWORD[rbp-1650], RAX
; 设置变量r2
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1650]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_102
    if_102:
    mov QWORD[rbp-48], 74
; 设置变量err
    end_if_102:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1650]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_splitGet
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1674+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1674+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1674+16], RAX
; 设置变量d5b
    mov QWORD [rbp-1698], str_5
    mov QWORD [rbp-1698+8], 1
    mov QWORD [rbp-1698+16], 1
; 设置变量expB
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1674]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1674+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1674+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1698]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1698+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1698+16]
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
    je end_if_103
    if_103:
    mov QWORD[rbp-48], 75
; 设置变量err
    end_if_103:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1650]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitFree
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_2
    mov QWORD [rsp+0+8], 3
    mov QWORD [rsp+0+16], 3
; 参数0
    mov QWORD [rsp+24], str_8
    mov QWORD [rsp+24+8], 3
    mov QWORD [rsp+24+16], 3
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    mov R8, QWORD [rsp+32]; 装载参数1
    mov R9, QWORD [rsp+40]; 装载参数1
    add rsp, 48; 释放寄存器参数 buffer
    call std_strings_split
    mov QWORD[rbp-1706], RAX
; 设置变量r3
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1706]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_104
    if_104:
    mov QWORD[rbp-48], 76
; 设置变量err
    end_if_104:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1706]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_splitGet
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1730+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1730+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1730+16], RAX
; 设置变量d6a
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1730]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1730+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1730+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-136]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-136+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-136+16]
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
    je end_if_105
    if_105:
    mov QWORD[rbp-48], 77
; 设置变量err
    end_if_105:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1706]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitFree
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_40
    mov QWORD [rsp+0+8], 2
    mov QWORD [rsp+0+16], 2
; 参数0
    mov QWORD [rsp+24], str_38
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
    call std_strings_split
    mov QWORD[rbp-1738], RAX
; 设置变量r4
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1738]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_106
    if_106:
    mov QWORD[rbp-48], 78
; 设置变量err
    end_if_106:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1738]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_splitGet
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1762+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1762+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1762+16], RAX
; 设置变量d7b
    mov QWORD [rbp-1786], 0
    mov QWORD [rbp-1786+8], 0
    mov QWORD [rbp-1786+16], 0
; 设置变量expEmpty
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1762]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1762+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1762+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1786]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1786+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1786+16]
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
    je end_if_107
    if_107:
    mov QWORD[rbp-48], 79
; 设置变量err
    end_if_107:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1738]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitFree
    sub rsp, 8; align stack for stack args
    push 0
; 参数2
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_37
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov QWORD [rsp+24], str_38
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
    call std_strings_splitN
    add rsp, 16; clean stack args
    mov QWORD[rbp-1794], RAX
; 设置变量r5
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1794]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_108
    if_108:
    mov QWORD[rbp-48], 80
; 设置变量err
    end_if_108:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1794]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitFree
    sub rsp, 8; align stack for stack args
    push 1
; 参数2
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_37
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov QWORD [rsp+24], str_38
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
    call std_strings_splitN
    add rsp, 16; clean stack args
    mov QWORD[rbp-1802], RAX
; 设置变量r6
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1802]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_109
    if_109:
    mov QWORD[rbp-48], 81
; 设置变量err
    end_if_109:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1802]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_splitGet
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1826+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1826+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1826+16], RAX
; 设置变量p1a
    mov QWORD [rbp-1850], str_37
    mov QWORD [rbp-1850+8], 5
    mov QWORD [rbp-1850+16], 5
; 设置变量expWhole
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1826]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1826+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1826+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1850]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1850+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1850+16]
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
    je end_if_110
    if_110:
    mov QWORD[rbp-48], 82
; 设置变量err
    end_if_110:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1802]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitFree
    sub rsp, 8; align stack for stack args
    push 2
; 参数2
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_37
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov QWORD [rsp+24], str_38
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
    call std_strings_splitN
    add rsp, 16; clean stack args
    mov QWORD[rbp-1858], RAX
; 设置变量r7
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1858]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_111
    if_111:
    mov QWORD[rbp-48], 83
; 设置变量err
    end_if_111:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1858]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_splitGet
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1882+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1882+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1882+16], RAX
; 设置变量p2b
    mov QWORD [rbp-1906], str_41
    mov QWORD [rbp-1906+8], 3
    mov QWORD [rbp-1906+16], 3
; 设置变量expBC
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1882]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1882+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1882+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-1906]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-1906+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-1906+16]
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
    je end_if_112
    if_112:
    mov QWORD[rbp-48], 84
; 设置变量err
    end_if_112:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1858]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitFree
    sub rsp, 8; align stack for stack args
    push 5
; 参数2
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_37
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov QWORD [rsp+24], str_38
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
    call std_strings_splitN
    add rsp, 16; clean stack args
    mov QWORD[rbp-1914], RAX
; 设置变量r8
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1914]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_113
    if_113:
    mov QWORD[rbp-48], 85
; 设置变量err
    end_if_113:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1914]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitFree
    mov QWORD[rbp-1922], -1
; 设置变量negOne
    sub rsp, 8; align stack for stack args
    push QWORD[rbp-1922]
; 参数2
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], str_37
    mov QWORD [rsp+0+8], 5
    mov QWORD [rsp+0+16], 5
; 参数0
    mov QWORD [rsp+24], str_38
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
    call std_strings_splitN
    add rsp, 16; clean stack args
    mov QWORD[rbp-1930], RAX
; 设置变量r9
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1930]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_114
    if_114:
    mov QWORD[rbp-48], 86
; 设置变量err
    end_if_114:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1930]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitFree
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_42
    mov QWORD [rsp+0+8], 7
    mov QWORD [rsp+0+16], 7
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_fields
    mov QWORD[rbp-1938], RAX
; 设置变量rA
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1938]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 2
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_115
    if_115:
    mov QWORD[rbp-48], 87
; 设置变量err
    end_if_115:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1938]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 0
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_splitGet
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1962+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1962+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1962+16], RAX
; 设置变量f1a
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1962]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1962+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1962+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_4
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_116
    if_116:
    mov QWORD[rbp-48], 88
; 设置变量err
    end_if_116:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1938]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_splitGet
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-1986+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-1986+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-1986+16], RAX
; 设置变量f1b
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-1986]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-1986+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-1986+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov QWORD [rsp+24], str_5
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
    call std_strings_compare
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_117
    if_117:
    mov QWORD[rbp-48], 89
; 设置变量err
    end_if_117:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1938]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitFree
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 0
    mov QWORD [rsp+0+8], 0
    mov QWORD [rsp+0+16], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_fields
    mov QWORD[rbp-1994], RAX
; 设置变量rB
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1994]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_118
    if_118:
    mov QWORD[rbp-48], 90
; 设置变量err
    end_if_118:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-1994]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitFree
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 16
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderNew
    mov QWORD[rbp-2002], RAX
; 设置变量fld0
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-2002]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], str_4
    mov QWORD [rsp+8+8], 1
    mov QWORD [rsp+8+16], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数1
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_builderWriteString
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2002]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 9
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderWrite
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-2002]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], str_43
    mov QWORD [rsp+8+8], 5
    mov QWORD [rsp+8+16], 5
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数1
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_builderWriteString
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2002]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 9
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderWrite
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-2002]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], str_44
    mov QWORD [rsp+8+8], 2
    mov QWORD [rsp+8+16], 2
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数1
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_builderWriteString
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2002]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_builderString
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-2026+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-2026+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-2026+16], RAX
; 设置变量fldS
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2002]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderFree
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-2026]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-2026+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-2026+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_fields
    mov QWORD[rbp-2034], RAX
; 设置变量rD
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2034]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 4
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_119
    if_119:
    mov QWORD[rbp-48], 91
; 设置变量err
    end_if_119:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2034]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 2
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_splitGet
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-2058+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-2058+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-2058+16], RAX
; 设置变量f3c
    mov QWORD [rbp-2082], str_45
    mov QWORD [rbp-2082+8], 2
    mov QWORD [rbp-2082+16], 2
; 设置变量expCD
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-2058]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-2058+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-2058+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-2082]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-2082+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-2082+16]
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
    je end_if_120
    if_120:
    mov QWORD[rbp-48], 92
; 设置变量err
    end_if_120:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2034]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_splitFree
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 8
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderNew
    mov QWORD[rbp-2090], RAX
; 设置变量bld
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-2090]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], str_26
    mov QWORD [rsp+8+8], 2
    mov QWORD [rsp+8+16], 2
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数1
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_builderWriteString
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-2090]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], str_45
    mov QWORD [rsp+8+8], 2
    mov QWORD [rsp+8+16], 2
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数1
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_builderWriteString
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2090]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 4
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_121
    if_121:
    mov QWORD[rbp-48], 93
; 设置变量err
    end_if_121:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2090]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_builderString
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-2114+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-2114+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-2114+16], RAX
; 设置变量out1
    mov QWORD [rbp-2138], str_46
    mov QWORD [rbp-2138+8], 4
    mov QWORD [rbp-2138+16], 4
; 设置变量expABCD
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-2114]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-2114+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-2114+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-2138]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-2138+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-2138+16]
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
    mov QWORD[rbp-48], 94
; 设置变量err
    end_if_122:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2090]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_builderString
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-2162+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-2162+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-2162+16], RAX
; 设置变量out2
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-2162]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-2162+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-2162+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-2138]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-2138+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-2138+16]
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
    je end_if_123
    if_123:
    mov QWORD[rbp-48], 95
; 设置变量err
    end_if_123:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2090]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 120
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderWrite
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2090]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 5
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_124
    if_124:
    mov QWORD[rbp-48], 96
; 设置变量err
    end_if_124:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2090]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_builderString
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-2186+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-2186+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-2186+16], RAX
; 设置变量out3
    mov QWORD [rbp-2210], str_47
    mov QWORD [rbp-2210+8], 5
    mov QWORD [rbp-2210+16], 5
; 设置变量expABCDX
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-2186]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-2186+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-2186+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-2210]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-2210+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-2210+16]
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
    je end_if_125
    if_125:
    mov QWORD[rbp-48], 97
; 设置变量err
    end_if_125:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2090]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderFree
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 2
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderNew
    mov QWORD[rbp-2218], RAX
; 设置变量bld2
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-2218]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], str_2
    mov QWORD [rsp+8+8], 3
    mov QWORD [rsp+8+16], 3
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数1
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_builderWriteString
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2218]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderLen
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 3
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_126
    if_126:
    mov QWORD[rbp-48], 98
; 设置变量err
    end_if_126:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2218]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_builderString
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-2242+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-2242+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-2242+16], RAX
; 设置变量out4
    mov QWORD [rbp-2266], str_2
    mov QWORD [rbp-2266+8], 3
    mov QWORD [rbp-2266+16], 3
; 设置变量expABC
    sub rsp, 48; register args buffer
    mov RAX, QWORD [rbp-2242]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-2242+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-2242+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD [rbp-2266]
    mov QWORD [rsp+24+0], RAX
    mov RAX, QWORD [rbp-2266+8]
    mov QWORD [rsp+24+8], RAX
    mov RAX, QWORD [rbp-2266+16]
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
    je end_if_127
    if_127:
    mov QWORD[rbp-48], 99
; 设置变量err
    end_if_127:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-2218]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_builderFree
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 48
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigit
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_128
    if_128:
    mov QWORD[rbp-48], 110
; 设置变量err
    end_if_128:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 58
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigit
; condition
    test RAX, RAX
    jz end_if_129
    if_129:
    mov QWORD[rbp-48], 111
; 设置变量err
    end_if_129:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 57
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigit
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_130
    if_130:
    mov QWORD[rbp-48], 112
; 设置变量err
    end_if_130:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 96
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isDigit
; condition
    test RAX, RAX
    jz end_if_131
    if_131:
    mov QWORD[rbp-48], 113
; 设置变量err
    end_if_131:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 32
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isSpaceByte
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_132
    if_132:
    mov QWORD[rbp-48], 114
; 设置变量err
    end_if_132:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 9
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isSpaceByte
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_133
    if_133:
    mov QWORD[rbp-48], 115
; 设置变量err
    end_if_133:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 10
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isSpaceByte
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_134
    if_134:
    mov QWORD[rbp-48], 116
; 设置变量err
    end_if_134:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 13
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isSpaceByte
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_135
    if_135:
    mov QWORD[rbp-48], 117
; 设置变量err
    end_if_135:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 33
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isSpaceByte
; condition
    test RAX, RAX
    jz end_if_136
    if_136:
    mov QWORD[rbp-48], 118
; 设置变量err
    end_if_136:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 97
; 参数0
    mov QWORD [rsp+8], 16
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isIntDigit
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_137
    if_137:
    mov QWORD[rbp-48], 120
; 设置变量err
    end_if_137:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 103
; 参数0
    mov QWORD [rsp+8], 16
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isIntDigit
; condition
    test RAX, RAX
    jz end_if_138
    if_138:
    mov QWORD[rbp-48], 121
; 设置变量err
    end_if_138:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 66
; 参数0
    mov QWORD [rsp+8], 16
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isIntDigit
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_139
    if_139:
    mov QWORD[rbp-48], 122
; 设置变量err
    end_if_139:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 71
; 参数0
    mov QWORD [rsp+8], 16
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isIntDigit
; condition
    test RAX, RAX
    jz end_if_140
    if_140:
    mov QWORD[rbp-48], 123
; 设置变量err
    end_if_140:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 95
; 参数0
    mov QWORD [rsp+8], 16
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isIntDigit
; condition
    test RAX, RAX
    jz end_if_141
    if_141:
    mov QWORD[rbp-48], 124
; 设置变量err
    end_if_141:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 10
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_fromByte
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-2290+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-2290+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-2290+16], RAX
; 设置变量fb
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-2290]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-2290+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-2290+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_142
    if_142:
    mov QWORD[rbp-48], 130
; 设置变量err
    end_if_142:
    mov RAX, QWORD [rbp-2290]
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 10
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_143
    if_143:
    mov QWORD[rbp-48], 131
; 设置变量err
    end_if_143:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 9
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_fromByte
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-2314+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-2314+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-2314+16], RAX
; 设置变量fb9
    mov RAX, QWORD [rbp-2314]
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 9
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_144
    if_144:
    mov QWORD[rbp-48], 132
; 设置变量err
    end_if_144:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 65
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-2384]; 大值返回槽地址
    call std_strings_fromByte
    mov RAX, QWORD [RBP-2384]
    mov QWORD [rbp-2338+0], RAX
    mov RAX, QWORD [RBP-2384+8]
    mov QWORD [rbp-2338+8], RAX
    mov RAX, QWORD [RBP-2384+16]
    mov QWORD [rbp-2338+16], RAX
; 设置变量fb65
    mov RAX, QWORD [rbp-2338]
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_145
    if_145:
    mov QWORD[rbp-48], 133
; 设置变量err
    end_if_145:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jle end_if_146
    if_146:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_main
    end_if_146:
    mov RAX, 42
; return值存入RAX
    jmp func_end_main
    func_end_main:
    add rsp, 2392; 清理局部变量 + 对齐
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
    je end_if_147
    if_147:
    jmp func_end_std_memory_initFreeHeads
    end_if_147:
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
    jnb end_if_148
    if_148:
    jmp func_end_std_memory_initFreeHeads
    end_if_148:
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
    jne end_if_149
    if_149:
    mov RAX, 32
; return值存入RAX
    jmp func_end_std_memory_blkSizeOfTiny
    end_if_149:
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
    jnb end_if_150
    if_150:
    mov QWORD[rbp-72], 16
; 设置变量step
    end_if_150:
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
    jne end_if_151
    if_151:
    mov RAX, 2048
; return值存入RAX
    jmp func_end_std_memory_blkSizeOfSmall
    end_if_151:
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
    jnbe end_if_152
    if_152:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOfTiny
; return值存入RAX
    jmp func_end_std_memory_blkSizeOf
    end_if_152:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 35
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_153
    if_153:
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
    end_if_153:
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
    jnbe end_if_154
    if_154:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_slotOfTiny
    end_if_154:
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
    jnb end_if_155
    if_155:
    mov QWORD[rbp-72], 16
; 设置变量step
    end_if_155:
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
    jb end_if_156
    if_156:
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_slotOfTiny
    end_if_156:
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
    jnbe end_if_157
    if_157:
    mov RAX, 34
; return值存入RAX
    jmp func_end_std_memory_slotOfSmall
    end_if_157:
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
    jnbe end_if_158
    if_158:
    mov RAX, 36
; return值存入RAX
    jmp func_end_std_memory_slotOfMiddle
    end_if_158:
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
    jb end_if_159
    if_159:
    mov RBX, QWORD[rbp-64]
    mov RAX, 36
    add RAX, RBX
    mov RBX, 1
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_memory_slotOfMiddle
    end_if_159:
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
    jnbe end_if_160
    if_160:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfTiny
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_160:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_SMALL_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_161
    if_161:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfSmall
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_161:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_162
    if_162:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_slotOfMiddle
; return值存入RAX
    jmp func_end_std_memory_slotOf
    end_if_162:
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
    jb end_if_163
    if_163:
    mov RAX, 60
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_163:




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
    jnbe end_if_164
    if_164:
    mov RAX, QWORD[rbp-56]
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_164:
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
    jbe end_if_165
    if_165:
    mov RAX, 60
; return值存入RAX
    jmp func_end_std_memory_freeListClassOf
    end_if_165:
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
    jb end_if_166
    if_166:
    jmp func_end_std_memory_insertFreeList
    end_if_166:
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
    je end_if_167
    if_167:
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
    end_if_167:
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
    jb end_if_168
    if_168:
    jmp func_end_std_memory_removeFreeList
    end_if_168:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je else_if_169
    if_169:
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
    jmp end_if_169
    else_if_169:
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
    end_if_169:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_170
    if_170:
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
    end_if_170:
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
    jnb end_if_171
    if_171:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_commit
    end_if_171:
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
    je end_if_172
    if_172:
    mov RBX, QWORD[rbp-112]
    mov RDX, QWORD[rel __global_std_memory_PREV_FREE]
    mov QWORD[rbp-112], RBX
    or QWORD[rbp-112], RDX
; 设置变量flags
    end_if_172:
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
    je end_if_173
    if_173:
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
    end_if_173:
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
    jnbe end_if_174
    if_174:
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
    je end_if_175
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
    je end_if_175
    if_175:
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
    end_if_175:
    end_if_174:
    mov RAX, QWORD[rbp-56]
    mov RDX, QWORD[rel __global_std_memory_PREV_FREE]
    and RAX, RDX
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je else_if_176
    if_176:
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
    jmp end_if_176
    else_if_176:
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
    end_if_176:
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
    jnbe end_if_177
    if_177:
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
    je end_if_178
    if_178:
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
    end_if_178:
    end_if_177:
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
    jnb end_if_179
    if_179:
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-56], RAX
; 设置变量req
    end_if_179:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_LARGE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_180
    if_180:
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
    jnb end_if_181
    if_181:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_181:
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
    end_if_180:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_182
    if_182:
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
    jnb end_if_183
    if_183:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_183:
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
    jnbe end_if_184
    if_184:
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
    je end_if_185
    if_185:
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
    end_if_185:
    end_if_184:
    mov RAX, QWORD[rbp-120]
    mov RDX, QWORD[rel __global_std_memory_PTR_SIZE]
    add RAX, RDX
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_182:
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
    jne end_if_186
    if_186:
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
    jne end_if_187
    if_187:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_malloc
    end_if_187:
    end_if_186:
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
    je end_if_188
    if_188:
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
    end_if_188:
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
    jnb end_if_189
    if_189:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_blkSizeOf
    mov QWORD[rbp-208], RAX
; 设置变量minBlk
    end_if_189:
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
    jb else_if_190
    if_190:
    mov RAX, QWORD[rbp-176]
    mov QWORD[rbp-216], RAX
; 设置变量useSize
    mov RDX, QWORD[rbp-200]
    mov RSI, QWORD[rbp-176]
    mov QWORD[rbp-224], RDX
    sub QWORD[rbp-224], RSI
; 设置变量rem
    jmp end_if_190
    else_if_190:
    mov RAX, QWORD[rbp-200]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-176]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_191
    if_191:
    mov RAX, QWORD[rbp-176]
    mov QWORD[rbp-216], RAX
; 设置变量useSize
    end_if_191:
    end_if_190:
    mov RAX, QWORD[rbp-224]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-208]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_192
    if_192:
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
    jnbe end_if_193
    if_193:
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
    je end_if_194
    if_194:
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
    end_if_194:
    end_if_193:
    jmp end_if_192
    else_if_192:
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
    end_if_192:
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
    jnbe end_if_195
    if_195:
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
    je end_if_196
    if_196:
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
    end_if_196:
    end_if_195:
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
    jbe end_if_197
    if_197:
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
    jne end_if_198
    if_198:
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
    end_if_198:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_freeAt
    end_if_197:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_199
    if_199:
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
    jne end_if_200
    if_200:
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
    end_if_200:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_freeAt
    end_if_199:
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
    jne end_if_201
    if_201:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_free
    end_if_201:
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
    je end_if_202
    if_202:
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
    end_if_202:
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
    jne end_if_203
    if_203:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeSlot
    end_if_203:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
; condition
    test RAX, RAX
    jz end_if_204
    if_204:
    mov RAX, 0
    mov RBX, QWORD[rbp-48]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeSlot
    end_if_204:
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
    jne end_if_205
    if_205:
    sub rsp, 16; register args buffer
    mov RBX, QWORD[rbp-56]
    mov QWORD [rsp+0], RBX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_205:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_206
    if_206:
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
    end_if_206:
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
    jnbe end_if_207
    if_207:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_207:
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
    jnbe end_if_208
    if_208:
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
    je end_if_209
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
    je end_if_209
    if_209:
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
    jb end_if_210
    if_210:
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
    jnbe end_if_211
    if_211:
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
    je end_if_212
    if_212:
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
    end_if_212:
    end_if_211:
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_210:
    end_if_209:
    end_if_208:
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
    jne end_if_213
    if_213:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_realloc
    end_if_213:
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
    jbe end_if_214
    if_214:
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-144], RAX
; 设置变量copySize
    end_if_214:
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
    jne end_if_215
    if_215:
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
    for_9_continue:


    jmp for_9; for循环
    for_9_end: ; for循环结束
    mov RAX, QWORD[rel __global_std_memory_PTR_SIZE]
    mov RBX, QWORD[rbp-72]
    imul RAX, RBX
    mov RBX, QWORD[rbp-64]
    mov QWORD[rbp-96], RBX
    sub QWORD[rbp-96], RAX
; 设置变量rem
    mov QWORD[rbp-104], 0
; 设置变量j




    for_10: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
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
    for_10_continue:


    jmp for_10; for循环
    for_10_end: ; for循环结束
    mov RAX, QWORD[rbp-48]
; return值存入RAX
    jmp func_end_std_memory_memset
    end_if_215:
    mov QWORD[rbp-120], 0
; 设置变量b




    for_11: ; for循环开始
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-64]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_11_end
    for_11_body:


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
    for_11_continue:


    jmp for_11; for循环
    for_11_end: ; for循环结束
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
    jnb end_if_216
    if_216:
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-64], RAX
; 设置变量req
    end_if_216:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_LARGE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_217
    if_217:
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
    jnb end_if_218
    if_218:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_218:
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
    end_if_217:
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_MIDDLE_MAX]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_219
    if_219:
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
    jnb end_if_220
    if_220:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_220:
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
    jnbe end_if_221
    if_221:
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
    je end_if_222
    if_222:
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
    end_if_222:
    end_if_221:
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
    end_if_219:
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
    jne end_if_223
    if_223:
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
    jne end_if_224
    if_224:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_mallocRC
    end_if_224:
    end_if_223:
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
    je end_if_225
    if_225:
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
    end_if_225:
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
    jnbe end_if_226
    if_226:
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
    je end_if_227
    if_227:
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
    end_if_227:
    end_if_226:
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
    jne end_if_228
    if_228:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeRC
    end_if_228:
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
    jne end_if_229
    if_229:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeRCSlot
    end_if_229:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_freeRC
; condition
    test RAX, RAX
    jz end_if_230
    if_230:
    mov RAX, 0
    mov RBX, QWORD[rbp-48]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_freeRCSlot
    end_if_230:
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
    jne end_if_231
    if_231:
    jmp func_end_std_memory_rcInc
    end_if_231:
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
    jne end_if_232
    if_232:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcDec
    end_if_232:
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
    jne end_if_233
    if_233:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcDec
    end_if_233:
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_234
    if_234:
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
    end_if_234:
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
    jne end_if_235
    if_235:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_rcGet
    end_if_235:
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
    jne end_if_236
    if_236:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcTryRelease
    end_if_236:
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
    jnbe end_if_237
    if_237:
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
    end_if_237:
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
    jne end_if_238
    if_238:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_memory_rcIsOne
    end_if_238:
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
    jne end_if_239
    if_239:
    jmp func_end_std_memory_rcSet
    end_if_239:
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
    jne end_if_240
    if_240:
    jmp func_end_std_memory_rcAdd
    end_if_240:
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
    jne end_if_241
    if_241:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_memory_rcSub
    end_if_241:
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
    jnbe end_if_242
    if_242:
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
    end_if_242:
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
    je end_if_243
    if_243:
    jmp func_end_std_memory_initLeakTracker
    end_if_243:
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
    jnb end_if_244
    if_244:
    jmp func_end_std_memory_initLeakTracker
    end_if_244:
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
    jne end_if_245
    if_245:
    jmp func_end_std_memory_trackAlloc
    end_if_245:
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
    jnb end_if_246
    if_246:
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
    end_if_246:
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
    jne end_if_247
    if_247:
    jmp func_end_std_memory_trackFree
    end_if_247:
    call std_memory_initLeakTracker
    mov RAX, QWORD[rel __global_std_memory_gFreeCount]
    mov RBX, 1
    mov QWORD[rel __global_std_memory_gFreeCount], RAX
    add QWORD[rel __global_std_memory_gFreeCount], RBX
; 设置变量gFreeCount
    mov QWORD[rbp-56], 0
; 设置变量i




    for_12: ; for循环开始
    mov RAX, QWORD[rbp-56]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rel __global_std_memory_gLeakCount]
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
    call std_memory_leakLoad
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-48]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_248
    if_248:
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
    end_if_248:
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD[rbp-56], RAX
    add QWORD[rbp-56], RBX
; 设置变量i
    for_12_continue:


    jmp for_12; for循环
    for_12_end: ; for循环结束
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
    jnb end_if_249
    if_249:
    mov RAX, QWORD[rbp-96]
    mov RBX, 1
    add RAX, RBX
; return值存入RAX
    jmp func_end_std_strings_count
    end_if_249:




    for_13: ; for循环开始


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
    jb end_if_250
    if_250:
    jmp for_13_end
    end_if_250:
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
    for_13_continue:


    jmp for_13; for循环
    for_13_end: ; for循环结束
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
    jne end_if_251
    if_251:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_isSpace
    end_if_251:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 9
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_252
    if_252:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_isSpace
    end_if_252:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 10
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_253
    if_253:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_isSpace
    end_if_253:
    mov RAX, QWORD[rbp-48]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 13
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_254
    if_254:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_isSpace
    end_if_254:
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




    for_14: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_14_end
    for_14_body:


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




    for_15: ; for循环开始
    mov RAX, QWORD[rbp-153]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_15_end
    for_15_body:


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
    jne end_if_255
    if_255:
    mov BYTE[rbp-145], 1
; 设置变量found
    jmp for_15_end
    end_if_255:
    mov RAX, QWORD[rbp-153]
    mov RBX, 1
    mov QWORD[rbp-153], RAX
    add QWORD[rbp-153], RBX
; 设置变量j
    for_15_continue:


    jmp for_15; for循环
    for_15_end: ; for循环结束
    movzx RAX, BYTE[rbp-145]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_256
    if_256:
    jmp for_14_end
    end_if_256:
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量i
    for_14_continue:


    jmp for_14; for循环
    for_14_end: ; for循环结束
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




    for_16: ; for循环开始
    mov RAX, QWORD[rbp-201]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-177]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_16_end
    for_16_body:


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
    for_16_continue:


    jmp for_16; for循环
    for_16_end: ; for循环结束
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




    for_17: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_17_end
    for_17_body:


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




    for_18: ; for循环开始
    mov RAX, QWORD[rbp-153]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_18_end
    for_18_body:


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
    jne end_if_257
    if_257:
    mov BYTE[rbp-145], 1
; 设置变量found
    jmp for_18_end
    end_if_257:
    mov RAX, QWORD[rbp-153]
    mov RBX, 1
    mov QWORD[rbp-153], RAX
    add QWORD[rbp-153], RBX
; 设置变量j
    for_18_continue:


    jmp for_18; for循环
    for_18_end: ; for循环结束
    movzx RAX, BYTE[rbp-145]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_258
    if_258:
    jmp for_17_end
    end_if_258:
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    sub QWORD[rbp-128], RBX
; 设置变量end
    for_17_continue:


    jmp for_17; for循环
    for_17_end: ; for循环结束
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




    for_19: ; for循环开始
    mov RAX, QWORD[rbp-193]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-128]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_19_end
    for_19_body:


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
    for_19_continue:


    jmp for_19; for循环
    for_19_end: ; for循环结束
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


section .text.std_strings_trim progbits alloc exec nowrite align=16
global std_strings_trim
; ==============================
; Function: std_strings_trim
std_strings_trim:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 136; 分配局部变量空间(136字节, 含对齐)
    mov QWORD [rbp-104], R10; 保存返回槽地址
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
    sub rsp, 48; register args buffer
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
    lea R10, [rbp-128]; 大值返回槽地址
    call std_strings_trimLeft
    mov RAX, QWORD [RBP-128]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [RBP-128+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [RBP-128+16]
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
    lea R10, [rbp-128]; 大值返回槽地址
    call std_strings_trimRight
    mov RAX, QWORD [RBP-128]
    mov QWORD [rbp-128+0], RAX
    mov RAX, QWORD [RBP-128+8]
    mov QWORD [rbp-128+8], RAX
    mov RAX, QWORD [RBP-128+16]
    mov QWORD [rbp-128+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-104]; 恢复返回槽地址
    mov RAX, QWORD [rbp-128]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-120]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-112]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_trim
    func_end_std_strings_trim:
    add rsp, 136; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_lastIndex progbits alloc exec nowrite align=16
global std_strings_lastIndex
; ==============================
; Function: std_strings_lastIndex
std_strings_lastIndex:
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
; 设置变量tPtr
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
; 设置变量tLen
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_259
    if_259:
    mov RAX, QWORD[rbp-104]
; return值存入RAX
    jmp func_end_std_strings_lastIndex
    end_if_259:
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_260
    if_260:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_lastIndex
    end_if_260:
    mov RAX, QWORD[rbp-104]
    mov RBX, QWORD[rbp-120]
    mov QWORD[rbp-128], RAX
    sub QWORD[rbp-128], RBX
; 设置变量i
    mov QWORD[rbp-136], -1
; 设置变量lastFound




    for_20: ; for循环开始


    mov BYTE[rbp-137], 1
; 设置变量found
    mov QWORD[rbp-145], 0
; 设置变量j




    for_21: ; for循环开始
    mov RAX, QWORD[rbp-145]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_21_end
    for_21_body:


    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-128]
    add RAX, RBX
    mov RBX, QWORD[rbp-145]
    mov QWORD[rbp-153], RAX
    add QWORD[rbp-153], RBX
; 设置变量_p11
    mov RAX, QWORD[rbp-153]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-161], RAX
; 设置变量a
    mov RAX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-145]
    mov QWORD[rbp-169], RAX
    add QWORD[rbp-169], RBX
; 设置变量_p12
    mov RAX, QWORD[rbp-169]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-177], RAX
; 设置变量b
    mov RAX, QWORD[rbp-161]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-177]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_261
    if_261:
    mov BYTE[rbp-137], 0
; 设置变量found
    jmp for_21_end
    end_if_261:
    mov RAX, QWORD[rbp-145]
    mov RBX, 1
    mov QWORD[rbp-145], RAX
    add QWORD[rbp-145], RBX
; 设置变量j
    for_21_continue:


    jmp for_21; for循环
    for_21_end: ; for循环结束
    movzx RAX, BYTE[rbp-137]
; condition
    test RAX, RAX
    jz end_if_262
    if_262:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-128]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_fromI64
    mov QWORD[rbp-136], RAX
; 设置变量lastFound
    jmp for_20_end
    end_if_262:
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_263
    if_263:
    jmp for_20_end
    end_if_263:
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    sub QWORD[rbp-128], RBX
; 设置变量i
    for_20_continue:


    jmp for_20; for循环
    for_20_end: ; for循环结束
    mov RAX, QWORD[rbp-136]
; return值存入RAX
    jmp func_end_std_strings_lastIndex
    func_end_std_strings_lastIndex:
    add rsp, 232; 清理局部变量 + 对齐
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
    jne end_if_264
    if_264:
    mov RAX, QWORD[rbp-104]
; return值存入RAX
    jmp func_end_std_strings_indexByte
    end_if_264:
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


section .text.std_strings_containsAny progbits alloc exec nowrite align=16
global std_strings_containsAny
; ==============================
; Function: std_strings_containsAny
std_strings_containsAny:
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




    for_23: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_23_end
    for_23_body:


    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-128]
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量_p14
    mov RAX, QWORD[rbp-136]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-144], RAX
; 设置变量ch
    mov QWORD[rbp-152], 0
; 设置变量j




    for_24: ; for循环开始
    mov RAX, QWORD[rbp-152]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_24_end
    for_24_body:


    mov RAX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-152]
    mov QWORD[rbp-160], RAX
    add QWORD[rbp-160], RBX
; 设置变量_p15
    mov RAX, QWORD[rbp-160]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-168], RAX
; 设置变量cj
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-168]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_265
    if_265:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_containsAny
    end_if_265:
    mov RAX, QWORD[rbp-152]
    mov RBX, 1
    mov QWORD[rbp-152], RAX
    add QWORD[rbp-152], RBX
; 设置变量j
    for_24_continue:


    jmp for_24; for循环
    for_24_end: ; for循环结束
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量i
    for_23_continue:


    jmp for_23; for循环
    for_23_end: ; for循环结束
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_containsAny
    func_end_std_strings_containsAny:
    add rsp, 216; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_containsRune progbits alloc exec nowrite align=16
global std_strings_containsRune
; ==============================
; Function: std_strings_containsRune
std_strings_containsRune:
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
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 128
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jge end_if_266
    if_266:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+24], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_indexByte
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl end_if_267
    if_267:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_containsRune
    end_if_267:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_containsRune
    end_if_266:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_containsRune
    func_end_std_strings_containsRune:
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
    jnb end_if_268
    if_268:
    mov RAX, QWORD[rbp-120]
    mov QWORD[rbp-128], RAX
; 设置变量minLen
    end_if_268:
    mov QWORD[rbp-136], 0
; 设置变量i




    for_25: ; for循环开始
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-128]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_25_end
    for_25_body:


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
    jnb end_if_269
    if_269:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_269:
    mov RAX, QWORD[rbp-152]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-168]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_270
    if_270:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_270:
    mov RAX, QWORD[rbp-136]
    mov RBX, 1
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量i
    for_25_continue:


    jmp for_25; for循环
    for_25_end: ; for循环结束
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_271
    if_271:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_271:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_272
    if_272:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_compare
    end_if_272:
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


section .text.std_strings_atoi progbits alloc exec nowrite align=16
global std_strings_atoi
; ==============================
; Function: std_strings_atoi
std_strings_atoi:
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
    mov QWORD [rsp+24], 10
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_parse
; return值存入RAX
    jmp func_end_std_strings_atoi
    func_end_std_strings_atoi:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_itoa progbits alloc exec nowrite align=16
global std_strings_itoa
; ==============================
; Function: std_strings_itoa
std_strings_itoa:
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
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 10
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    lea R10, [rbp-80]; 大值返回槽地址
    call std_strings_toString
    mov RAX, QWORD [RBP-80]
    mov QWORD [rbp-80+0], RAX
    mov RAX, QWORD [RBP-80+8]
    mov QWORD [rbp-80+8], RAX
    mov RAX, QWORD [RBP-80+16]
    mov QWORD [rbp-80+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-56]; 恢复返回槽地址
    mov RAX, QWORD [rbp-80]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-72]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-64]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_itoa
    func_end_std_strings_itoa:
    add rsp, 88; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_parseBool progbits alloc exec nowrite align=16
global std_strings_parseBool
; ==============================
; Function: std_strings_parseBool
std_strings_parseBool:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 280; 分配局部变量空间(280字节, 含对齐)
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
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-80], RAX
; 设置变量sPtr
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_273
    if_273:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_parseBool
    end_if_273:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_274
    if_274:
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-88], RAX
; 设置变量_p18
    mov RAX, QWORD[rbp-88]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-96], RAX
; 设置变量ch
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 49
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_275
    if_275:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_parseBool
    end_if_275:
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 48
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_276
    if_276:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_parseBool
    end_if_276:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_parseBool
    end_if_274:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 4
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_277
    if_277:
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-104], RAX
; 设置变量_p19
    mov RAX, QWORD[rbp-104]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-112], RAX
; 设置变量a
    mov RAX, QWORD[rbp-80]
    mov RBX, 1
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量_p20
    mov RAX, QWORD[rbp-120]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-128], RAX
; 设置变量b
    mov RAX, QWORD[rbp-80]
    mov RBX, 2
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量_p21
    mov RAX, QWORD[rbp-136]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-144], RAX
; 设置变量c
    mov RAX, QWORD[rbp-80]
    mov RBX, 3
    mov QWORD[rbp-152], RAX
    add QWORD[rbp-152], RBX
; 设置变量_p22
    mov RAX, QWORD[rbp-152]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-160], RAX
; 设置变量d
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 116
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_278
    and_mid_5:
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 114
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_278
    and_mid_4:
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 117
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_278
    and_mid_3:
    mov RAX, QWORD[rbp-160]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 101
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_278
    if_278:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_parseBool
    end_if_278:
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 84
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_279
    and_mid_8:
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 82
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_279
    and_mid_7:
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 85
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_279
    and_mid_6:
    mov RAX, QWORD[rbp-160]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 69
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_279
    if_279:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_parseBool
    end_if_279:
    end_if_277:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 5
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_280
    if_280:
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-168], RAX
; 设置变量_p23
    mov RAX, QWORD[rbp-168]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-176], RAX
; 设置变量a2
    mov RAX, QWORD[rbp-80]
    mov RBX, 1
    mov QWORD[rbp-184], RAX
    add QWORD[rbp-184], RBX
; 设置变量_p24
    mov RAX, QWORD[rbp-184]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-192], RAX
; 设置变量b2
    mov RAX, QWORD[rbp-80]
    mov RBX, 2
    mov QWORD[rbp-200], RAX
    add QWORD[rbp-200], RBX
; 设置变量_p25
    mov RAX, QWORD[rbp-200]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-208], RAX
; 设置变量c2
    mov RAX, QWORD[rbp-80]
    mov RBX, 3
    mov QWORD[rbp-216], RAX
    add QWORD[rbp-216], RBX
; 设置变量_p26
    mov RAX, QWORD[rbp-216]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-224], RAX
; 设置变量d2
    mov RAX, QWORD[rbp-80]
    mov RBX, 4
    mov QWORD[rbp-232], RAX
    add QWORD[rbp-232], RBX
; 设置变量_p27
    mov RAX, QWORD[rbp-232]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-240], RAX
; 设置变量e2
    mov RAX, QWORD[rbp-176]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 102
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_281
    and_mid_12:
    mov RAX, QWORD[rbp-192]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 97
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_281
    and_mid_11:
    mov RAX, QWORD[rbp-208]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 108
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_281
    and_mid_10:
    mov RAX, QWORD[rbp-224]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 115
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_281
    and_mid_9:
    mov RAX, QWORD[rbp-240]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 101
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_281
    if_281:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_parseBool
    end_if_281:
    mov RAX, QWORD[rbp-176]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 70
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_282
    and_mid_16:
    mov RAX, QWORD[rbp-192]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_282
    and_mid_15:
    mov RAX, QWORD[rbp-208]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 76
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_282
    and_mid_14:
    mov RAX, QWORD[rbp-224]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 83
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_282
    and_mid_13:
    mov RAX, QWORD[rbp-240]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 69
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_282
    if_282:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_parseBool
    end_if_282:
    end_if_280:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_parseBool
    func_end_std_strings_parseBool:
    add rsp, 280; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_formatBool progbits alloc exec nowrite align=16
global std_strings_formatBool
; ==============================
; Function: std_strings_formatBool
std_strings_formatBool:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 200; 分配局部变量空间(200字节, 含对齐)
    mov QWORD [rbp-168], R10; 保存返回槽地址
    mov BYTE [rbp-48], DIL; 保存参数0到栈
    movzx RAX, BYTE[rbp-48]
; condition
    test RAX, RAX
    jz end_if_283
    if_283:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 5
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-56], RAX
; 设置变量tbuf
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-64], RAX
; 设置变量_p34
    mov RAX, 116
    mov RBX, QWORD[rbp-64]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-56]
    mov RBX, 1
    mov QWORD[rbp-72], RAX
    add QWORD[rbp-72], RBX
; 设置变量_p35
    mov RAX, 114
    mov RBX, QWORD[rbp-72]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-56]
    mov RBX, 2
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量_p36
    mov RAX, 117
    mov RBX, QWORD[rbp-80]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-56]
    mov RBX, 3
    mov QWORD[rbp-88], RAX
    add QWORD[rbp-88], RBX
; 设置变量_p37
    mov RAX, 101
    mov RBX, QWORD[rbp-88]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-56]
    mov RBX, 4
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RBX
; 设置变量_p38
    mov RAX, 0
    mov RBX, QWORD[rbp-96]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 4
; 参数1
    mov QWORD [rsp+16], 4
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
    jmp func_end_std_strings_formatBool
    end_if_283:
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 6
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-104], RAX
; 设置变量fbuf
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-112], RAX
; 设置变量_p39
    mov RBX, 102
    mov RAX, QWORD[rbp-112]
    mov BYTE [RAX], bl
; expression statement
    mov RAX, QWORD[rbp-104]
    mov RBX, 1
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量_p40
    mov RAX, 97
    mov RBX, QWORD[rbp-120]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-104]
    mov RBX, 2
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量_p41
    mov RAX, 108
    mov RBX, QWORD[rbp-128]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-104]
    mov RBX, 3
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量_p42
    mov RAX, 115
    mov RBX, QWORD[rbp-136]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-104]
    mov RBX, 4
    mov QWORD[rbp-144], RAX
    add QWORD[rbp-144], RBX
; 设置变量_p43
    mov RAX, 101
    mov RBX, QWORD[rbp-144]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-104]
    mov RBX, 5
    mov QWORD[rbp-152], RAX
    add QWORD[rbp-152], RBX
; 设置变量_p44
    mov RAX, 0
    mov RBX, QWORD[rbp-152]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 5
; 参数1
    mov QWORD [rsp+16], 5
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
    jmp func_end_std_strings_formatBool
    func_end_std_strings_formatBool:
    add rsp, 200; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_equalFold progbits alloc exec nowrite align=16
global std_strings_equalFold
; ==============================
; Function: std_strings_equalFold
std_strings_equalFold:
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
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_284
    if_284:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_equalFold
    end_if_284:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-112], RAX
; 设置变量sPtr
    mov RAX, QWORD [rbp-88]
    mov QWORD [rbp-120], RAX
; 设置变量tPtr
    mov QWORD[rbp-128], 0
; 设置变量i




    for_26: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_26_end
    for_26_body:


    mov RAX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-128]
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量_p45
    mov RAX, QWORD[rbp-136]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-144], RAX
; 设置变量a
    mov RAX, QWORD[rbp-120]
    mov RBX, QWORD[rbp-128]
    mov QWORD[rbp-152], RAX
    add QWORD[rbp-152], RBX
; 设置变量_p46
    mov RAX, QWORD[rbp-152]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-160], RAX
; 设置变量b
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_285
    and_mid_17:
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 90
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_285
    if_285:
    mov RAX, QWORD[rbp-144]
    mov RBX, 32
    mov QWORD[rbp-144], RAX
    add QWORD[rbp-144], RBX
; 设置变量a
    end_if_285:
    mov RAX, QWORD[rbp-160]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_286
    and_mid_18:
    mov RAX, QWORD[rbp-160]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 90
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_286
    if_286:
    mov RAX, QWORD[rbp-160]
    mov RBX, 32
    mov QWORD[rbp-160], RAX
    add QWORD[rbp-160], RBX
; 设置变量b
    end_if_286:
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-160]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_287
    if_287:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_equalFold
    end_if_287:
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量i
    for_26_continue:


    jmp for_26; for循环
    for_26_end: ; for循环结束
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_equalFold
    func_end_std_strings_equalFold:
    add rsp, 200; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_indexAny progbits alloc exec nowrite align=16
global std_strings_indexAny
; ==============================
; Function: std_strings_indexAny
std_strings_indexAny:
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




    for_27: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_27_end
    for_27_body:


    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-128]
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量_p47
    mov RAX, QWORD[rbp-136]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-144], RAX
; 设置变量ch
    mov QWORD[rbp-152], 0
; 设置变量j




    for_28: ; for循环开始
    mov RAX, QWORD[rbp-152]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_28_end
    for_28_body:


    mov RAX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-152]
    mov QWORD[rbp-160], RAX
    add QWORD[rbp-160], RBX
; 设置变量_p48
    mov RAX, QWORD[rbp-160]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-168], RAX
; 设置变量cj
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-168]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_288
    if_288:
    mov RAX, QWORD[rbp-128]
; return值存入RAX
    jmp func_end_std_strings_indexAny
    end_if_288:
    mov RAX, QWORD[rbp-152]
    mov RBX, 1
    mov QWORD[rbp-152], RAX
    add QWORD[rbp-152], RBX
; 设置变量j
    for_28_continue:


    jmp for_28; for循环
    for_28_end: ; for循环结束
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量i
    for_27_continue:


    jmp for_27; for循环
    for_27_end: ; for循环结束
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_indexAny
    func_end_std_strings_indexAny:
    add rsp, 216; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_lastIndexByte progbits alloc exec nowrite align=16
global std_strings_lastIndexByte
; ==============================
; Function: std_strings_lastIndexByte
std_strings_lastIndexByte:
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
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-104], RAX
; 设置变量i




    for_29: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_29_end
    for_29_body:


    mov RAX, QWORD[rbp-104]
    mov RBX, 1
    mov QWORD[rbp-104], RAX
    sub QWORD[rbp-104], RBX
; 设置变量i
    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-112], RAX
    add QWORD[rbp-112], RBX
; 设置变量_p49
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
    jne end_if_289
    if_289:
    mov RAX, QWORD[rbp-104]
; return值存入RAX
    jmp func_end_std_strings_lastIndexByte
    end_if_289:
    for_29_continue:


    jmp for_29; for循环
    for_29_end: ; for循环结束
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_lastIndexByte
    func_end_std_strings_lastIndexByte:
    add rsp, 168; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_countByte progbits alloc exec nowrite align=16
global std_strings_countByte
; ==============================
; Function: std_strings_countByte
std_strings_countByte:
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
; 设置变量cnt
    mov QWORD[rbp-112], 0
; 设置变量i




    for_30: ; for循环开始
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_30_end
    for_30_body:


    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rbp-112]
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量_p50
    mov RAX, QWORD[rbp-120]
    movzx RAX, BYTE [RAX]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_290
    if_290:
    mov RAX, QWORD[rbp-104]
    mov RBX, 1
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量cnt
    end_if_290:
    mov RAX, QWORD[rbp-112]
    mov RBX, 1
    mov QWORD[rbp-112], RAX
    add QWORD[rbp-112], RBX
; 设置变量i
    for_30_continue:


    jmp for_30; for循环
    for_30_end: ; for循环结束
    mov RAX, QWORD[rbp-104]
; return值存入RAX
    jmp func_end_std_strings_countByte
    func_end_std_strings_countByte:
    add rsp, 168; 清理局部变量 + 对齐
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
    jne end_if_291
    if_291:
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
    end_if_291:
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




    for_31: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_31_end
    for_31_body:


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
    for_31_continue:


    jmp for_31; for循环
    for_31_end: ; for循环结束
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


section .text.std_strings_reverse progbits alloc exec nowrite align=16
global std_strings_reverse
; ==============================
; Function: std_strings_reverse
std_strings_reverse:
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
    jne end_if_292
    if_292:
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
    jmp func_end_std_strings_reverse
    end_if_292:
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


    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-112], RAX
    add QWORD[rbp-112], RBX
; 设置变量_p54
    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rbp-72]
    add RAX, RBX
    mov RBX, 1
    sub RAX, RBX
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-120], RAX
    sub QWORD[rbp-120], RBX
; 设置变量_p55
    mov RAX, QWORD[rbp-120]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-128], RAX
; 设置变量_pc_p55
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
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-72]
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量_p56
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
    jmp func_end_std_strings_reverse
    func_end_std_strings_reverse:
    add rsp, 184; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_repeatN progbits alloc exec nowrite align=16
global std_strings_repeatN
; ==============================
; Function: std_strings_repeatN
std_strings_repeatN:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-88], R10; 保存返回槽地址
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1到栈
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg end_if_293
    if_293:
    mov QWORD QWORD[rbp-112], 0
    mov QWORD [rbp-112+8], 0
    mov QWORD [rbp-112+16], 0
; return值存入返回槽
    mov R10, QWORD [rbp-88]; 恢复返回槽地址
    mov RAX, QWORD [rbp-112]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-104]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-96]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_repeatN
    end_if_293:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-64]
    mov QWORD [rsp+0+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rsp+0+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rsp+0+16], RAX
; 参数0
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+24], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    mov RCX, QWORD [rsp+24]; 装载参数1
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-112]; 大值返回槽地址
    call std_strings_repeat
    mov RAX, QWORD [RBP-112]
    mov QWORD [rbp-112+0], RAX
    mov RAX, QWORD [RBP-112+8]
    mov QWORD [rbp-112+8], RAX
    mov RAX, QWORD [RBP-112+16]
    mov QWORD [rbp-112+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-88]; 恢复返回槽地址
    mov RAX, QWORD [rbp-112]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-104]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-96]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_repeatN
    func_end_std_strings_repeatN:
    add rsp, 120; 清理局部变量 + 对齐
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


section .text.std_strings_isSpaceByte progbits alloc exec nowrite align=16
global std_strings_isSpaceByte
; ==============================
; Function: std_strings_isSpaceByte
std_strings_isSpaceByte:
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
    mov RBX, 32
    cmp RAX, RBX
    sete al
    movzx RAX, al
    mov RBX, QWORD[rbp-56]
    mov RCX, 9
    cmp RBX, RCX
    sete bl
    movzx RBX, bl
    or RAX, RBX
    mov RBX, QWORD[rbp-56]
    mov RCX, 10
    cmp RBX, RCX
    sete bl
    movzx RBX, bl
    or RAX, RBX
    mov RBX, QWORD[rbp-56]
    mov RCX, 13
    cmp RBX, RCX
    sete bl
    movzx RBX, bl
    or RAX, RBX
; return值存入RAX
    jmp func_end_std_strings_isSpaceByte
    func_end_std_strings_isSpaceByte:
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
    jl else_if_294
    and_mid_19:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 57
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg else_if_294
    if_294:
    mov RAX, QWORD[rbp-72]
    mov RBX, 48
    mov QWORD[rbp-64], RAX
    sub QWORD[rbp-64], RBX
; 设置变量d
    jmp end_if_294
    else_if_294:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 97
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl else_if_295
    and_mid_20:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 102
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg else_if_295
    if_295:
    mov RBX, QWORD[rbp-72]
    mov RAX, 97
    sub RBX, RAX
    mov RAX, 10
    mov QWORD[rbp-64], RBX
    add QWORD[rbp-64], RAX
; 设置变量d
    jmp end_if_295
    else_if_295:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl else_if_296
    and_mid_21:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 70
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jg else_if_296
    if_296:
    mov RBX, QWORD[rbp-72]
    mov RAX, 65
    sub RBX, RAX
    mov RAX, 10
    mov QWORD[rbp-64], RBX
    add QWORD[rbp-64], RAX
; 设置变量d
    jmp end_if_296
    else_if_296:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_isIntDigit
    end_if_296:
    end_if_295:
    end_if_294:
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
    jne end_if_297
    if_297:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_eq
    end_if_297:
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
    je end_if_298
    if_298:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_ne
    end_if_298:
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




    for_33: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_33_end
    for_33_body:


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
    for_33_continue:


    jmp for_33; for循环
    for_33_end: ; for循环结束
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
    jge else_if_299
    if_299:
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
    jmp end_if_299
    else_if_299:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64
    mov QWORD[rbp-65], RAX
; 设置变量num
    end_if_299:
    mov QWORD[rbp-73], 1
; 设置变量digits
    mov RAX, QWORD[rbp-65]
    mov QWORD[rbp-81], RAX
; 设置变量tmp




    for_34: ; for循环开始
    mov RAX, QWORD[rbp-81]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb for_34_end
    for_34_body:


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
    for_34_continue:


    jmp for_34; for循环
    for_34_end: ; for循环结束
    mov RAX, QWORD[rbp-73]
    mov QWORD[rbp-89], RAX
; 设置变量total
    movzx RAX, BYTE[rbp-57]
; condition
    test RAX, RAX
    jz end_if_300
    if_300:
    mov RAX, QWORD[rbp-89]
    mov RBX, 1
    mov QWORD[rbp-89], RAX
    add QWORD[rbp-89], RBX
; 设置变量total
    end_if_300:
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
    jne else_if_301
    if_301:
    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-121], RAX
; 设置变量_p14
    mov RAX, 48
    mov RBX, QWORD[rbp-121]
    mov BYTE [RBX], al
; expression statement
    jmp end_if_301
    else_if_301:
    mov QWORD[rbp-129], 0
; 设置变量i




    for_35: ; for循环开始
    mov RAX, QWORD[rbp-113]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_35_end
    for_35_body:


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
    jnb else_if_302
    if_302:
    mov RAX, QWORD[rbp-137]
    mov RBX, 48
    mov QWORD[rbp-145], RAX
    add QWORD[rbp-145], RBX
; 设置变量ch
    jmp end_if_302
    else_if_302:
    mov RAX, QWORD[rbp-137]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 36
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_303
    if_303:
    mov RAX, QWORD[rbp-137]
    mov RBX, 97
    add RAX, RBX
    mov RBX, 10
    mov QWORD[rbp-145], RAX
    sub QWORD[rbp-145], RBX
; 设置变量ch
    jmp end_if_303
    else_if_303:
    mov RAX, QWORD[rbp-137]
    mov RBX, 65
    add RAX, RBX
    mov RBX, 36
    mov QWORD[rbp-145], RAX
    sub QWORD[rbp-145], RBX
; 设置变量ch
    end_if_303:
    end_if_302:
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
    for_35_continue:


    jmp for_35; for循环
    for_35_end: ; for循环结束
    end_if_301:
    movzx RAX, BYTE[rbp-57]
; condition
    test RAX, RAX
    jz end_if_304
    if_304:
    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-161], RAX
; 设置变量_p16
    mov RAX, 45
    mov RBX, QWORD[rbp-161]
    mov BYTE [RBX], al
; expression statement
    end_if_304:
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
    jne end_if_305
    if_305:
    mov BYTE[rbp-121], 1
; 设置变量neg
    mov QWORD[rbp-120], 1
; 设置变量i
    end_if_305:
    mov QWORD[rbp-145], 0
; 设置变量val
    mov BYTE[rbp-146], 0
; 设置变量bad




    for_36: ; for循环开始
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-112]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_36_end
    for_36_body:


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
    jb else_if_306
    and_mid_22:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 57
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_306
    if_306:
    mov RAX, QWORD[rbp-162]
    mov RBX, 48
    mov QWORD[rbp-170], RAX
    sub QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_306
    else_if_306:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 97
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_307
    and_mid_23:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 122
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_307
    if_307:
    mov RAX, QWORD[rbp-162]
    mov RBX, 97
    sub RAX, RBX
    mov RBX, 10
    mov QWORD[rbp-170], RAX
    add QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_307
    else_if_307:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_308
    and_mid_24:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 90
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_308
    if_308:
    mov RAX, QWORD[rbp-162]
    mov RBX, 65
    sub RAX, RBX
    mov RBX, 36
    mov QWORD[rbp-170], RAX
    add QWORD[rbp-170], RBX
; 设置变量v
    jmp end_if_308
    else_if_308:
    mov BYTE[rbp-146], 1
; 设置变量bad
    end_if_308:
    end_if_307:
    end_if_306:
    movzx RAX, BYTE[rbp-146]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_309
    if_309:
    mov RAX, QWORD[rbp-145]
    mov RBX, QWORD[rbp-72]
    imul RAX, RBX
    mov RBX, QWORD[rbp-170]
    mov QWORD[rbp-145], RAX
    add QWORD[rbp-145], RBX
; 设置变量val
    end_if_309:
    mov RAX, QWORD[rbp-120]
    mov RBX, 1
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量i
    for_36_continue:


    jmp for_36; for循环
    for_36_end: ; for循环结束
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
    jz end_if_310
    if_310:
    mov RBX, QWORD[rbp-178]
    mov QWORD[rbp-178], 0
    sub QWORD[rbp-178], RBX
; 设置变量r
    end_if_310:
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
    jne end_if_311
    if_311:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    end_if_311:
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_312
    if_312:
    call std_strings_notFound
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    end_if_312:
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




    for_37: ; for循环开始
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-144]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe for_37_end
    for_37_body:


    mov BYTE[rbp-145], 1
; 设置变量found
    mov QWORD[rbp-153], 0
; 设置变量j




    for_38: ; for循环开始
    mov RAX, QWORD[rbp-153]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-112]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_38_end
    for_38_body:


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
    je end_if_313
    if_313:
    mov BYTE[rbp-145], 0
; 设置变量found
    jmp for_38_end
    end_if_313:
    mov RAX, QWORD[rbp-153]
    mov RBX, 1
    mov QWORD[rbp-153], RAX
    add QWORD[rbp-153], RBX
; 设置变量j
    for_38_continue:


    jmp for_38; for循环
    for_38_end: ; for循环结束
    movzx RAX, BYTE[rbp-145]
; condition
    test RAX, RAX
    jz end_if_314
    if_314:
    mov RAX, QWORD[rbp-136]
; return值存入RAX
    jmp func_end_std_strings_indexFrom
    end_if_314:
    mov RAX, QWORD[rbp-136]
    mov RBX, 1
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量i
    for_37_continue:


    jmp for_37; for循环
    for_37_end: ; for循环结束
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
    jne end_if_315
    if_315:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_index
    end_if_315:
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


section .text.std_strings_contains progbits alloc exec nowrite align=16
global std_strings_contains
; ==============================
; Function: std_strings_contains
std_strings_contains:
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
    call std_strings_index
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jl end_if_316
    if_316:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_contains
    end_if_316:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_contains
    func_end_std_strings_contains:
    add rsp, 136; 清理局部变量 + 对齐
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
    jbe end_if_317
    if_317:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasPrefix
    end_if_317:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_318
    if_318:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_hasPrefix
    end_if_318:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-112], RAX
; 设置变量sPtr
    mov RAX, QWORD [rbp-88]
    mov QWORD [rbp-120], RAX
; 设置变量tPtr
    mov QWORD[rbp-128], 0
; 设置变量i




    for_39: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_39_end
    for_39_body:


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
    je end_if_319
    if_319:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasPrefix
    end_if_319:
    mov RAX, QWORD[rbp-128]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量i
    for_39_continue:


    jmp for_39; for循环
    for_39_end: ; for循环结束
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
    jbe end_if_320
    if_320:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasSuffix
    end_if_320:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_321
    if_321:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_hasSuffix
    end_if_321:
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




    for_40: ; for循环开始
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_40_end
    for_40_body:


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
    je end_if_322
    if_322:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasSuffix
    end_if_322:
    mov RAX, QWORD[rbp-136]
    mov RBX, 1
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量i
    for_40_continue:


    jmp for_40; for循环
    for_40_end: ; for循环结束
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


section .text.std_strings_toUpper progbits alloc exec nowrite align=16
global std_strings_toUpper
; ==============================
; Function: std_strings_toUpper
std_strings_toUpper:
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
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-72], RAX
; 设置变量sPtr
    mov RDI, QWORD [rbp-64]
    mov RSI, QWORD [rbp-64+8]
    mov RDX, QWORD [rbp-64+16]
    call __string_len
    mov QWORD[rbp-80], RAX
; 设置变量sLen
    mov RAX, QWORD[rbp-80]
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




    for_41: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_41_end
    for_41_body:


    mov RAX, QWORD[rbp-72]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-112], RAX
    add QWORD[rbp-112], RBX
; 设置变量_p35
    mov RAX, QWORD[rbp-112]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-120], RAX
; 设置变量ch
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 97
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_323
    and_mid_25:
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 122
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_323
    if_323:
    mov RAX, QWORD[rbp-120]
    mov RBX, 32
    mov QWORD[rbp-120], RAX
    sub QWORD[rbp-120], RBX
; 设置变量ch
    end_if_323:
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量_p36
    mov RAX, QWORD[rbp-120]
    mov RBX, QWORD[rbp-128]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-104]
    mov RBX, 1
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量i
    for_41_continue:


    jmp for_41; for循环
    for_41_end: ; for循环结束
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-80]
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量_p37
    mov RAX, 0
    mov RBX, QWORD[rbp-136]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-80]
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
    jmp func_end_std_strings_toUpper
    func_end_std_strings_toUpper:
    add rsp, 184; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_toLower progbits alloc exec nowrite align=16
global std_strings_toLower
; ==============================
; Function: std_strings_toLower
std_strings_toLower:
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
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-72], RAX
; 设置变量sPtr
    mov RDI, QWORD [rbp-64]
    mov RSI, QWORD [rbp-64+8]
    mov RDX, QWORD [rbp-64+16]
    call __string_len
    mov QWORD[rbp-80], RAX
; 设置变量sLen
    mov RAX, QWORD[rbp-80]
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




    for_42: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_42_end
    for_42_body:


    mov RAX, QWORD[rbp-72]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-112], RAX
    add QWORD[rbp-112], RBX
; 设置变量_p38
    mov RAX, QWORD[rbp-112]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-120], RAX
; 设置变量ch
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb end_if_324
    and_mid_26:
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 90
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe end_if_324
    if_324:
    mov RAX, QWORD[rbp-120]
    mov RBX, 32
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量ch
    end_if_324:
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量_p39
    mov RAX, QWORD[rbp-120]
    mov RBX, QWORD[rbp-128]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-104]
    mov RBX, 1
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量i
    for_42_continue:


    jmp for_42; for循环
    for_42_end: ; for循环结束
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-80]
    mov QWORD[rbp-136], RAX
    add QWORD[rbp-136], RBX
; 设置变量_p40
    mov RAX, 0
    mov RBX, QWORD[rbp-136]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-80]
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
    jmp func_end_std_strings_toLower
    func_end_std_strings_toLower:
    add rsp, 184; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_trimSpace progbits alloc exec nowrite align=16
global std_strings_trimSpace
; ==============================
; Function: std_strings_trimSpace
std_strings_trimSpace:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 232; 分配局部变量空间(232字节, 含对齐)
    mov QWORD [rbp-200], R10; 保存返回槽地址
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-72], RAX
; 设置变量sPtr
    mov RDI, QWORD [rbp-64]
    mov RSI, QWORD [rbp-64+8]
    mov RDX, QWORD [rbp-64+16]
    call __string_len
    mov QWORD[rbp-80], RAX
; 设置变量sLen
    mov QWORD[rbp-88], 0
; 设置变量start




    for_43: ; for循环开始
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_43_end
    for_43_body:


    mov RAX, QWORD[rbp-72]
    mov RBX, QWORD[rbp-88]
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RBX
; 设置变量_p41
    mov RAX, QWORD[rbp-96]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-104], RAX
; 设置变量ch
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 32
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_325
    and_mid_29:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 9
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_325
    and_mid_28:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 10
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_325
    and_mid_27:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 13
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_325
    if_325:
    jmp for_43_end
    end_if_325:
    mov RAX, QWORD[rbp-88]
    mov RBX, 1
    mov QWORD[rbp-88], RAX
    add QWORD[rbp-88], RBX
; 设置变量start
    for_43_continue:


    jmp for_43; for循环
    for_43_end: ; for循环结束
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-112], RAX
; 设置变量end




    for_44: ; for循环开始
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_44_end
    for_44_body:


    mov RAX, QWORD[rbp-72]
    mov RBX, QWORD[rbp-112]
    add RAX, RBX
    mov RBX, 1
    mov QWORD[rbp-120], RAX
    sub QWORD[rbp-120], RBX
; 设置变量_p42
    mov RAX, QWORD[rbp-120]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-128], RAX
; 设置变量ch
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 32
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_326
    and_mid_32:
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 9
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_326
    and_mid_31:
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 10
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_326
    and_mid_30:
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 13
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_326
    if_326:
    jmp for_44_end
    end_if_326:
    mov RAX, QWORD[rbp-112]
    mov RBX, 1
    mov QWORD[rbp-112], RAX
    sub QWORD[rbp-112], RBX
; 设置变量end
    for_44_continue:


    jmp for_44; for循环
    for_44_end: ; for循环结束
    mov RAX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-88]
    mov QWORD[rbp-136], RAX
    sub QWORD[rbp-136], RBX
; 设置变量newLen
    mov RAX, QWORD[rbp-136]
    mov RBX, 1
    mov QWORD[rbp-144], RAX
    add QWORD[rbp-144], RBX
; 设置变量bufN
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-144]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-152], RAX
; 设置变量buf
    mov QWORD[rbp-160], 0
; 设置变量i




    for_45: ; for循环开始
    mov RAX, QWORD[rbp-160]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-136]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_45_end
    for_45_body:


    mov RAX, QWORD[rbp-152]
    mov RBX, QWORD[rbp-160]
    mov QWORD[rbp-168], RAX
    add QWORD[rbp-168], RBX
; 设置变量_p43
    mov RAX, QWORD[rbp-72]
    mov RBX, QWORD[rbp-88]
    add RAX, RBX
    mov RBX, QWORD[rbp-160]
    mov QWORD[rbp-176], RAX
    add QWORD[rbp-176], RBX
; 设置变量_p44
    mov RAX, QWORD[rbp-176]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-184], RAX
; 设置变量_pc_p44
    mov RAX, QWORD[rbp-184]
    mov RBX, QWORD[rbp-168]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-160]
    mov RBX, 1
    mov QWORD[rbp-160], RAX
    add QWORD[rbp-160], RBX
; 设置变量i
    for_45_continue:


    jmp for_45; for循环
    for_45_end: ; for循环结束
    mov RAX, QWORD[rbp-152]
    mov RBX, QWORD[rbp-136]
    mov QWORD[rbp-192], RAX
    add QWORD[rbp-192], RBX
; 设置变量_p45
    mov RAX, 0
    mov RBX, QWORD[rbp-192]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-152]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-136]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-136]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-224]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-224]
    mov QWORD [rbp-224+0], RAX
    mov RAX, QWORD [RBP-224+8]
    mov QWORD [rbp-224+8], RAX
    mov RAX, QWORD [RBP-224+16]
    mov QWORD [rbp-224+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-200]; 恢复返回槽地址
    mov RAX, QWORD [rbp-224]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-216]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-208]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_trimSpace
    func_end_std_strings_trimSpace:
    add rsp, 232; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_trimPrefix progbits alloc exec nowrite align=16
global std_strings_trimPrefix
; ==============================
; Function: std_strings_trimPrefix
std_strings_trimPrefix:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 216; 分配局部变量空间(216字节, 含对齐)
    mov QWORD [rbp-184], R10; 保存返回槽地址
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
    call std_strings_hasPrefix
; condition
    test RAX, RAX
    jz end_if_327
    if_327:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-96], RAX
; 设置变量sPtr
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
    mov RAX, QWORD[rbp-104]
    mov RBX, QWORD[rbp-112]
    mov QWORD[rbp-120], RAX
    sub QWORD[rbp-120], RBX
; 设置变量newLen
    mov RAX, QWORD[rbp-120]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量bufN
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-128]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-136], RAX
; 设置变量buf
    mov QWORD[rbp-144], 0
; 设置变量i




    for_46: ; for循环开始
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_46_end
    for_46_body:


    mov RAX, QWORD[rbp-136]
    mov RBX, QWORD[rbp-144]
    mov QWORD[rbp-152], RAX
    add QWORD[rbp-152], RBX
; 设置变量_p46
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-112]
    add RAX, RBX
    mov RBX, QWORD[rbp-144]
    mov QWORD[rbp-160], RAX
    add QWORD[rbp-160], RBX
; 设置变量_p47
    mov RAX, QWORD[rbp-160]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-168], RAX
; 设置变量_pc_p47
    mov RAX, QWORD[rbp-168]
    mov RBX, QWORD[rbp-152]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-144]
    mov RBX, 1
    mov QWORD[rbp-144], RAX
    add QWORD[rbp-144], RBX
; 设置变量i
    for_46_continue:


    jmp for_46; for循环
    for_46_end: ; for循环结束
    mov RAX, QWORD[rbp-136]
    mov RBX, QWORD[rbp-120]
    mov QWORD[rbp-176], RAX
    add QWORD[rbp-176], RBX
; 设置变量_p48
    mov RAX, 0
    mov RBX, QWORD[rbp-176]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-136]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-208]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-208]
    mov QWORD [rbp-208+0], RAX
    mov RAX, QWORD [RBP-208+8]
    mov QWORD [rbp-208+8], RAX
    mov RAX, QWORD [RBP-208+16]
    mov QWORD [rbp-208+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-184]; 恢复返回槽地址
    mov RAX, QWORD [rbp-208]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-200]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-192]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_trimPrefix
    end_if_327:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-208+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rbp-208+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rbp-208+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-184]; 恢复返回槽地址
    mov RAX, QWORD [rbp-208]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-200]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-192]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_trimPrefix
    func_end_std_strings_trimPrefix:
    add rsp, 216; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_trimSuffix progbits alloc exec nowrite align=16
global std_strings_trimSuffix
; ==============================
; Function: std_strings_trimSuffix
std_strings_trimSuffix:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 216; 分配局部变量空间(216字节, 含对齐)
    mov QWORD [rbp-184], R10; 保存返回槽地址
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
    call std_strings_hasSuffix
; condition
    test RAX, RAX
    jz end_if_328
    if_328:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-96], RAX
; 设置变量sPtr
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
    mov RAX, QWORD[rbp-104]
    mov RBX, QWORD[rbp-112]
    mov QWORD[rbp-120], RAX
    sub QWORD[rbp-120], RBX
; 设置变量newLen
    mov RAX, QWORD[rbp-120]
    mov RBX, 1
    mov QWORD[rbp-128], RAX
    add QWORD[rbp-128], RBX
; 设置变量bufN
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-128]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-136], RAX
; 设置变量buf
    mov QWORD[rbp-144], 0
; 设置变量i




    for_47: ; for循环开始
    mov RAX, QWORD[rbp-144]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_47_end
    for_47_body:


    mov RAX, QWORD[rbp-136]
    mov RBX, QWORD[rbp-144]
    mov QWORD[rbp-152], RAX
    add QWORD[rbp-152], RBX
; 设置变量_p49
    mov RAX, QWORD[rbp-96]
    mov RBX, QWORD[rbp-144]
    mov QWORD[rbp-160], RAX
    add QWORD[rbp-160], RBX
; 设置变量_p50
    mov RAX, QWORD[rbp-160]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-168], RAX
; 设置变量_pc_p50
    mov RAX, QWORD[rbp-168]
    mov RBX, QWORD[rbp-152]
    mov BYTE [RBX], al
; expression statement
    mov RAX, QWORD[rbp-144]
    mov RBX, 1
    mov QWORD[rbp-144], RAX
    add QWORD[rbp-144], RBX
; 设置变量i
    for_47_continue:


    jmp for_47; for循环
    for_47_end: ; for循环结束
    mov RAX, QWORD[rbp-136]
    mov RBX, QWORD[rbp-120]
    mov QWORD[rbp-176], RAX
    add QWORD[rbp-176], RBX
; 设置变量_p51
    mov RAX, 0
    mov RBX, QWORD[rbp-176]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-136]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-208]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-208]
    mov QWORD [rbp-208+0], RAX
    mov RAX, QWORD [RBP-208+8]
    mov QWORD [rbp-208+8], RAX
    mov RAX, QWORD [RBP-208+16]
    mov QWORD [rbp-208+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-184]; 恢复返回槽地址
    mov RAX, QWORD [rbp-208]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-200]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-192]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_trimSuffix
    end_if_328:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-208+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rbp-208+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rbp-208+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-184]; 恢复返回槽地址
    mov RAX, QWORD [rbp-208]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-200]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-192]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_trimSuffix
    func_end_std_strings_trimSuffix:
    add rsp, 216; 清理局部变量 + 对齐
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




    for_48: ; for循环开始
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_48_end
    for_48_body:


    mov QWORD[rbp-128], 0
; 设置变量j




    for_49: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_49_end
    for_49_body:


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
    for_49_continue:


    jmp for_49; for循环
    for_49_end: ; for循环结束
    mov RAX, QWORD[rbp-120]
    mov RCX, 1
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RCX
; 设置变量i
    for_48_continue:


    jmp for_48; for循环
    for_48_end: ; for循环结束
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


section .text.std_strings_replace progbits alloc exec nowrite align=16
global std_strings_replace
; ==============================
; Function: std_strings_replace
std_strings_replace:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 424; 分配局部变量空间(424字节, 含对齐)
    mov QWORD [rbp-392], R10; 保存返回槽地址
    mov RAX, [rbp+16]; 保存栈参数2槽0到栈
    mov [rbp-112], RAX
    mov RAX, [rbp+24]; 保存栈参数2槽1到栈
    mov [rbp-104], RAX
    mov RAX, [rbp+32]; 保存栈参数2槽2到栈
    mov [rbp-96], RAX
    mov RAX, [rbp+40]; 保存栈参数3槽0到栈
    mov [rbp-120], RAX
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-88], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-80], R8; 保存参数1槽1到栈
    mov QWORD [rbp-72], R9; 保存参数1槽2到栈
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-128], RAX
; 设置变量sPtr
    mov RDI, QWORD [rbp-64]
    mov RSI, QWORD [rbp-64+8]
    mov RDX, QWORD [rbp-64+16]
    call __string_len
    mov QWORD[rbp-136], RAX
; 设置变量sLen
    mov RAX, QWORD [rbp-88]
    mov QWORD [rbp-144], RAX
; 设置变量oPtr
    mov RDI, QWORD [rbp-88]
    mov RSI, QWORD [rbp-88+8]
    mov RDX, QWORD [rbp-88+16]
    call __string_len
    mov QWORD[rbp-152], RAX
; 设置变量oLen
    mov RAX, QWORD [rbp-112]
    mov QWORD [rbp-160], RAX
; 设置变量nPtr
    mov RDI, QWORD [rbp-112]
    mov RSI, QWORD [rbp-112+8]
    mov RDX, QWORD [rbp-112+16]
    call __string_len
    mov QWORD[rbp-168], RAX
; 设置变量nLen
    call std_strings_notFound
    mov QWORD[rbp-176], RAX
; 设置变量nf
    mov RAX, QWORD[rbp-152]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_329
    if_329:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-416+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rbp-416+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rbp-416+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-392]; 恢复返回槽地址
    mov RAX, QWORD [rbp-416]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-408]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-400]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_replace
    end_if_329:
    mov QWORD[rbp-184], 0
; 设置变量count
    mov QWORD[rbp-192], 0
; 设置变量scanPos
    mov BYTE[rbp-193], 1
; 设置变量scanning




    for_50: ; for循环开始
    movzx RAX, BYTE[rbp-193]
; condition
    test RAX, RAX
    jz for_50_end
    for_50_body:


    sub rsp, 8; align stack for stack args
    push QWORD[rbp-192]
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
    mov QWORD[rbp-201], RAX
; 设置变量idx
    mov RAX, QWORD[rbp-201]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-176]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_330
    if_330:
    jmp for_50_end
    end_if_330:
    mov RAX, QWORD[rbp-184]
    mov RBX, 1
    mov QWORD[rbp-184], RAX
    add QWORD[rbp-184], RBX
; 设置变量count
    mov RAX, QWORD[rbp-201]
    mov RBX, QWORD[rbp-152]
    mov QWORD[rbp-192], RAX
    add QWORD[rbp-192], RBX
; 设置变量scanPos
    for_50_continue:


    jmp for_50; for循环
    for_50_end: ; for循环结束
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_331
    if_331:
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-184]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_332
    if_332:
    mov RAX, QWORD[rbp-120]
    mov QWORD[rbp-184], RAX
; 设置变量count
    end_if_332:
    end_if_331:
    mov RAX, QWORD[rbp-184]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_333
    if_333:
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-416+0], RAX
    mov RAX, QWORD [rbp-64+8]
    mov QWORD [rbp-416+8], RAX
    mov RAX, QWORD [rbp-64+16]
    mov QWORD [rbp-416+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-392]; 恢复返回槽地址
    mov RAX, QWORD [rbp-416]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-408]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-400]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_replace
    end_if_333:
    mov RBX, QWORD[rbp-168]
    mov RCX, QWORD[rbp-152]
    sub RBX, RCX
    mov RAX, QWORD[rbp-184]
    imul RAX, RBX
    mov RCX, QWORD[rbp-136]
    mov QWORD[rbp-209], RCX
    add QWORD[rbp-209], RAX
; 设置变量newLen
    mov RCX, QWORD[rbp-209]
    mov RAX, 1
    mov QWORD[rbp-217], RCX
    add QWORD[rbp-217], RAX
; 设置变量bufN
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-217]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-225], RAX
; 设置变量buf
    mov QWORD[rbp-233], 0
; 设置变量srcPos
    mov QWORD[rbp-241], 0
; 设置变量dstPos
    mov QWORD[rbp-249], 0
; 设置变量replaced




    for_51: ; for循环开始
    mov RAX, QWORD[rbp-249]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-184]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_51_end
    for_51_body:


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
    mov QWORD[rbp-257], RAX
; 设置变量idx
    mov RCX, QWORD[rbp-257]
    mov RAX, QWORD[rbp-233]
    mov QWORD[rbp-265], RCX
    sub QWORD[rbp-265], RAX
; 设置变量segLen
    mov QWORD[rbp-273], 0
; 设置变量k




    for_52: ; for循环开始
    mov RAX, QWORD[rbp-273]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-265]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_52_end
    for_52_body:


    mov RAX, QWORD[rbp-225]
    mov RBX, QWORD[rbp-241]
    add RAX, RBX
    mov RBX, QWORD[rbp-273]
    mov QWORD[rbp-281], RAX
    add QWORD[rbp-281], RBX
; 设置变量_p55
    mov RAX, QWORD[rbp-128]
    mov RBX, QWORD[rbp-233]
    add RAX, RBX
    mov RBX, QWORD[rbp-273]
    mov QWORD[rbp-289], RAX
    add QWORD[rbp-289], RBX
; 设置变量_p56
    mov RAX, QWORD[rbp-289]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-297], RAX
; 设置变量_pc_p56
    mov RAX, QWORD[rbp-297]
    mov RCX, QWORD[rbp-281]
    mov BYTE [RCX], al
; expression statement
    mov RAX, QWORD[rbp-273]
    mov RBX, 1
    mov QWORD[rbp-273], RAX
    add QWORD[rbp-273], RBX
; 设置变量k
    for_52_continue:


    jmp for_52; for循环
    for_52_end: ; for循环结束
    mov RAX, QWORD[rbp-241]
    mov RCX, QWORD[rbp-265]
    mov QWORD[rbp-241], RAX
    add QWORD[rbp-241], RCX
; 设置变量dstPos
    mov QWORD[rbp-273], 0
; 设置变量k




    for_53: ; for循环开始
    mov RAX, QWORD[rbp-273]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-168]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_53_end
    for_53_body:


    mov RAX, QWORD[rbp-225]
    mov RBX, QWORD[rbp-241]
    add RAX, RBX
    mov RBX, QWORD[rbp-273]
    mov QWORD[rbp-305], RAX
    add QWORD[rbp-305], RBX
; 设置变量_p57
    mov RAX, QWORD[rbp-160]
    mov RCX, QWORD[rbp-273]
    mov QWORD[rbp-313], RAX
    add QWORD[rbp-313], RCX
; 设置变量_p58
    mov RAX, QWORD[rbp-313]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-321], RAX
; 设置变量_pc_p58
    mov RAX, QWORD[rbp-321]
    mov RCX, QWORD[rbp-305]
    mov BYTE [RCX], al
; expression statement
    mov RAX, QWORD[rbp-273]
    mov RBX, 1
    mov QWORD[rbp-273], RAX
    add QWORD[rbp-273], RBX
; 设置变量k
    for_53_continue:


    jmp for_53; for循环
    for_53_end: ; for循环结束
    mov RAX, QWORD[rbp-241]
    mov RCX, QWORD[rbp-168]
    mov QWORD[rbp-241], RAX
    add QWORD[rbp-241], RCX
; 设置变量dstPos
    mov RAX, QWORD[rbp-257]
    mov RCX, QWORD[rbp-152]
    mov QWORD[rbp-233], RAX
    add QWORD[rbp-233], RCX
; 设置变量srcPos
    mov RAX, QWORD[rbp-249]
    mov RBX, 1
    mov QWORD[rbp-249], RAX
    add QWORD[rbp-249], RBX
; 设置变量replaced
    for_51_continue:


    jmp for_51; for循环
    for_51_end: ; for循环结束
    mov RAX, QWORD[rbp-136]
    mov RCX, QWORD[rbp-233]
    mov QWORD[rbp-329], RAX
    sub QWORD[rbp-329], RCX
; 设置变量rest
    mov QWORD[rbp-337], 0
; 设置变量k




    for_54: ; for循环开始
    mov RAX, QWORD[rbp-337]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-329]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_54_end
    for_54_body:


    mov RAX, QWORD[rbp-225]
    mov RBX, QWORD[rbp-241]
    add RAX, RBX
    mov RBX, QWORD[rbp-337]
    mov QWORD[rbp-345], RAX
    add QWORD[rbp-345], RBX
; 设置变量_p59
    mov RAX, QWORD[rbp-128]
    mov RBX, QWORD[rbp-233]
    add RAX, RBX
    mov RBX, QWORD[rbp-337]
    mov QWORD[rbp-353], RAX
    add QWORD[rbp-353], RBX
; 设置变量_p60
    mov RAX, QWORD[rbp-353]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-361], RAX
; 设置变量_pc_p60
    mov RAX, QWORD[rbp-361]
    mov RCX, QWORD[rbp-345]
    mov BYTE [RCX], al
; expression statement
    mov RAX, QWORD[rbp-337]
    mov RBX, 1
    mov QWORD[rbp-337], RAX
    add QWORD[rbp-337], RBX
; 设置变量k
    for_54_continue:


    jmp for_54; for循环
    for_54_end: ; for循环结束
    mov RAX, QWORD[rbp-225]
    mov RCX, QWORD[rbp-209]
    mov QWORD[rbp-369], RAX
    add QWORD[rbp-369], RCX
; 设置变量_p61
    mov RAX, 0
    mov RCX, QWORD[rbp-369]
    mov BYTE [RCX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-225]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-209]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-209]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-416]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-416]
    mov QWORD [rbp-416+0], RAX
    mov RAX, QWORD [RBP-416+8]
    mov QWORD [rbp-416+8], RAX
    mov RAX, QWORD [RBP-416+16]
    mov QWORD [rbp-416+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-392]; 恢复返回槽地址
    mov RAX, QWORD [rbp-416]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-408]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-400]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_replace
    func_end_std_strings_replace:
    add rsp, 424; 清理局部变量 + 对齐
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




    for_55: ; for循环开始
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_55_end
    for_55_body:


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
    for_55_continue:


    jmp for_55; for循环
    for_55_end: ; for循环结束
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
    jz else_if_334
    if_334:
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
    jmp end_if_334
    else_if_334:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64
    mov QWORD[rbp-137], RAX
; 设置变量nMag
    end_if_334:
    mov QWORD[rbp-153], 0
; 设置变量totalPieces
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe else_if_335
    if_335:
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
    jmp end_if_335
    else_if_335:
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_336
    if_336:
    mov QWORD[rbp-153], 1
; 设置变量totalPieces
    jmp end_if_336
    else_if_336:
    mov RAX, QWORD[rbp-112]
    mov QWORD[rbp-153], RAX
; 设置变量totalPieces
    end_if_336:
    end_if_335:
    mov RAX, QWORD[rbp-153]
    mov QWORD[rbp-177], RAX
; 设置变量pieces
    movzx RAX, BYTE[rbp-129]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_337
    if_337:
    mov RAX, QWORD[rbp-177]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-137]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_338
    if_338:
    mov RAX, QWORD[rbp-137]
    mov QWORD[rbp-177], RAX
; 设置变量pieces
    end_if_338:
    end_if_337:
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
    jbe end_if_339
    if_339:
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
    end_if_339:
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
    jbe end_if_340
    if_340:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-201]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-217], RAX
; 设置变量data
    end_if_340:
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
    jbe end_if_341
    if_341:
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
    jbe else_if_342
    if_342:
    mov RAX, QWORD[rbp-177]
    mov RBX, 1
    mov QWORD[rbp-257], RAX
    sub QWORD[rbp-257], RBX
; 设置变量limitM1




    for_56: ; for循环开始
    mov RAX, QWORD[rbp-241]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-257]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_56_end
    for_56_body:


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
    jne end_if_343
    if_343:
    jmp for_56_end
    end_if_343:
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
    for_56_continue:


    jmp for_56; for循环
    for_56_end: ; for循环结束
    jmp end_if_342
    else_if_342:
    mov RAX, QWORD[rbp-177]
    mov RBX, 1
    mov QWORD[rbp-297], RAX
    sub QWORD[rbp-297], RBX
; 设置变量bsLimit




    for_57: ; for循环开始
    mov RAX, QWORD[rbp-241]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-297]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_57_end
    for_57_body:


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
    for_57_continue:


    jmp for_57; for循环
    for_57_end: ; for循环结束
    end_if_342:
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
    end_if_341:
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


section .text.std_strings_split progbits alloc exec nowrite align=16
global std_strings_split
; ==============================
; Function: std_strings_split
std_strings_split:
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
    sub rsp, 8; align stack for stack args
    push -1
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
    call std_strings_splitN
    add rsp, 16; clean stack args
; return值存入RAX
    jmp func_end_std_strings_split
    func_end_std_strings_split:
    add rsp, 136; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_splitLen progbits alloc exec nowrite align=16
global std_strings_splitLen
; ==============================
; Function: std_strings_splitLen
std_strings_splitLen:
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
; 设置变量rAddr
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-64], RAX
; 设置变量hdr
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
; return值存入RAX
    jmp func_end_std_strings_splitLen
    func_end_std_strings_splitLen:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_splitGet progbits alloc exec nowrite align=16
global std_strings_splitGet
; ==============================
; Function: std_strings_splitGet
std_strings_splitGet:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 152; 分配局部变量空间(152字节, 含对齐)
    mov QWORD [rbp-120], R10; 保存返回槽地址
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-56], RSI; 保存参数1到栈
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-64], RAX
; 设置变量rAddr
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-72], RAX
; 设置变量hdr
    mov RBX, QWORD [RBP-72]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-80], RAX
; 设置变量data
    mov QWORD[rbp-88], 24
; 设置变量elemSize
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
; 设置变量off
    mov RAX, QWORD[rbp-80]
    mov RBX, QWORD[rbp-96]
    mov QWORD[rbp-104], RAX
    add QWORD[rbp-104], RBX
; 设置变量cellAddr
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-112], RAX
; 设置变量cell
    sub rsp, 32; register args buffer
    mov RBX, QWORD [RBP-112]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RBX, QWORD [RBP-112]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RBX, QWORD [RBP-112]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+16]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    lea R10, [rbp-144]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-144]
    mov QWORD [rbp-144+0], RAX
    mov RAX, QWORD [RBP-144+8]
    mov QWORD [rbp-144+8], RAX
    mov RAX, QWORD [RBP-144+16]
    mov QWORD [rbp-144+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-120]; 恢复返回槽地址
    mov RAX, QWORD [rbp-144]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-136]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-128]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_splitGet
    func_end_std_strings_splitGet:
    add rsp, 152; 清理局部变量 + 对齐
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


section .text.std_strings_splitFree progbits alloc exec nowrite align=16
global std_strings_splitFree
; ==============================
; Function: std_strings_splitFree
std_strings_splitFree:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 136; 分配局部变量空间(136字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-56], RAX
; 设置变量rAddr2
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-64], RAX
; 设置变量hdr2
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
    mov QWORD[rbp-72], RAX
; 设置变量count0
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-80], RAX
; 设置变量data2
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_344
    if_344:
    mov QWORD[rbp-88], 0
; 设置变量i2




    for_58: ; for循环开始
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_58_end
    for_58_body:


    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-88]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_cellP
    mov QWORD[rbp-96], RAX
; 设置变量cellP
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_345
    if_345:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    end_if_345:
    mov RAX, QWORD[rbp-88]
    mov RBX, 1
    mov QWORD[rbp-88], RAX
    add QWORD[rbp-88], RBX
; 设置变量i2
    for_58_continue:


    jmp for_58; for循环
    for_58_end: ; for循环结束
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    end_if_344:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    jmp func_end_std_strings_splitFree
    func_end_std_strings_splitFree:
    add rsp, 136; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_fields progbits alloc exec nowrite align=16
global std_strings_fields
; ==============================
; Function: std_strings_fields
std_strings_fields:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 264; 分配局部变量空间(264字节, 含对齐)
    mov QWORD [rbp-64], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-56], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-48], RDX; 保存参数0槽2到栈
    mov RAX, QWORD [rbp-64]
    mov QWORD [rbp-72], RAX
; 设置变量sPtr
    mov RDI, QWORD [rbp-64]
    mov RSI, QWORD [rbp-64+8]
    mov RDX, QWORD [rbp-64+16]
    call __string_len
    mov QWORD[rbp-80], RAX
; 设置变量sLen
    mov QWORD[rbp-88], 0
; 设置变量fieldCount
    mov QWORD[rbp-96], 0
; 设置变量scanI




    for_59: ; for循环开始
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_59_end
    for_59_body:


    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_byteAt
    mov QWORD[rbp-104], RAX
; 设置变量ch0
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-104]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isSpace
    mov BYTE[rbp-105], al
; 设置变量isWs0
    movzx RAX, BYTE[rbp-105]
; condition
    test RAX, RAX
    jz else_if_346
    if_346:
    mov RAX, QWORD[rbp-96]
    mov RBX, 1
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RBX
; 设置变量scanI
    jmp end_if_346
    else_if_346:
    mov RAX, QWORD[rbp-88]
    mov RBX, 1
    mov QWORD[rbp-88], RAX
    add QWORD[rbp-88], RBX
; 设置变量fieldCount




    for_60: ; for循环开始
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_60_end
    for_60_body:


    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-96]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_byteAt
    mov QWORD[rbp-113], RAX
; 设置变量ch1
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-113]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isSpace
    mov BYTE[rbp-114], al
; 设置变量isWs1
    movzx RAX, BYTE[rbp-114]
; condition
    test RAX, RAX
    jz end_if_347
    if_347:
    jmp for_60_end
    end_if_347:
    mov RAX, QWORD[rbp-96]
    mov RBX, 1
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RBX
; 设置变量scanI
    for_60_continue:


    jmp for_60; for循环
    for_60_end: ; for循环结束
    end_if_346:
    for_59_continue:


    jmp for_59; for循环
    for_59_end: ; for循环结束
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 24
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-122], RAX
; 设置变量outerF
    mov QWORD[rbp-130], 24
; 设置变量elemSizeF
    mov QWORD[rbp-138], 0
; 设置变量dataF
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_348
    if_348:
    mov RAX, QWORD[rbp-88]
    mov RBX, QWORD[rbp-130]
    mov QWORD[rbp-146], RAX
    push RAX; 保护RAX(左子结果)
    push RBX; 暂存乘数
    mov RAX, QWORD[rbp-146]
    imul RAX, qword [rsp]
    mov QWORD[rbp-146], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量dataSizeF
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-146]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-138], RAX
; 设置变量dataF
    end_if_348:
    mov RAX, QWORD[rbp-122]
    mov QWORD[rbp-154], RAX
; 设置变量hdrF
    mov RBX, QWORD [RBP-154]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-138]
    mov QWORD[RBX], RAX
; 设置变量hdrF.p
    mov RBX, QWORD [RBP-154]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-88]
    mov QWORD[RBX+16], RAX
; 设置变量hdrF.c
    mov QWORD[rbp-162], 0
; 设置变量fieldI
    mov QWORD[rbp-170], 0
; 设置变量scanJ




    for_61: ; for循环开始
    mov RAX, QWORD[rbp-170]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_61_end
    for_61_body:


    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-170]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_byteAt
    mov QWORD[rbp-178], RAX
; 设置变量ch2
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-178]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isSpace
    mov BYTE[rbp-179], al
; 设置变量isWs2
    movzx RAX, BYTE[rbp-179]
; condition
    test RAX, RAX
    jz else_if_349
    if_349:
    mov RAX, QWORD[rbp-170]
    mov RBX, 1
    mov QWORD[rbp-170], RAX
    add QWORD[rbp-170], RBX
; 设置变量scanJ
    jmp end_if_349
    else_if_349:
    mov RAX, QWORD[rbp-170]
    mov QWORD[rbp-187], RAX
; 设置变量startI




    for_62: ; for循环开始
    mov RAX, QWORD[rbp-170]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-80]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_62_end
    for_62_body:


    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-72]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-170]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_byteAt
    mov QWORD[rbp-195], RAX
; 设置变量ch3
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-195]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_isSpace
    mov BYTE[rbp-196], al
; 设置变量isWs3
    movzx RAX, BYTE[rbp-196]
; condition
    test RAX, RAX
    jz end_if_350
    if_350:
    jmp for_62_end
    end_if_350:
    mov RAX, QWORD[rbp-170]
    mov RBX, 1
    mov QWORD[rbp-170], RAX
    add QWORD[rbp-170], RBX
; 设置变量scanJ
    for_62_continue:


    jmp for_62; for循环
    for_62_end: ; for循环结束
    mov RAX, QWORD[rbp-187]
    mov QWORD[rbp-204], RAX
; 设置变量segOffF
    mov RAX, QWORD[rbp-72]
    mov RBX, QWORD[rbp-204]
    mov QWORD[rbp-212], RAX
    add QWORD[rbp-212], RBX
; 设置变量segSrcF
    mov RAX, QWORD[rbp-170]
    mov RBX, QWORD[rbp-187]
    mov QWORD[rbp-220], RAX
    sub QWORD[rbp-220], RBX
; 设置变量segLenF
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-138]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-162]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-212]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RAX, QWORD[rbp-220]
    mov QWORD [rsp+24], RAX
; 参数3
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    mov RCX, QWORD [rsp+24]; 装载参数3
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_putPiece
    mov RBX, QWORD[rbp-162]
    mov RAX, 1
    mov QWORD[rbp-162], RBX
    add QWORD[rbp-162], RAX
; 设置变量fieldI
    end_if_349:
    for_61_continue:


    jmp for_61; for循环
    for_61_end: ; for循环结束
    mov RBX, QWORD [RBP-154]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-162]
    mov QWORD[RBX+8], RAX
; 设置变量hdrF.n
    mov RAX, QWORD[rbp-122]
; return值存入RAX
    jmp func_end_std_strings_fields
    func_end_std_strings_fields:
    add rsp, 264; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_builderNew progbits alloc exec nowrite align=16
global std_strings_builderNew
; ==============================
; Function: std_strings_builderNew
std_strings_builderNew:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 136; 分配局部变量空间(136字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    sub rsp, 16; register args buffer
    mov QWORD [rsp+0], 24
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-56], RAX
; 设置变量b
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-64], RAX
; 设置变量box
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-72], RAX
; 设置变量cap0
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 1
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_351
    if_351:
    mov QWORD[rbp-72], 1
; 设置变量cap0
    end_if_351:
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-80], RAX
; 设置变量bufN
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-88], RAX
; 设置变量buf0
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-88]
    mov QWORD[RBX], RAX
; 设置变量box.p
    mov QWORD[rbp-96], 0
; 设置变量zeroN
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-96]
    mov QWORD[RBX+8], RAX
; 设置变量box.n
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-72]
    mov QWORD[RBX+16], RAX
; 设置变量box.c
    mov RAX, QWORD[rbp-56]
; return值存入RAX
    jmp func_end_std_strings_builderNew
    func_end_std_strings_builderNew:
    add rsp, 136; 清理局部变量 + 对齐
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
    jbe end_if_352
    if_352:
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
    jnb else_if_353
    if_353:
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
    jmp end_if_353
    else_if_353:
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
    end_if_353:
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb end_if_354
    if_354:
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-96], RAX
; 设置变量ncap
    end_if_354:
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
    end_if_352:
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


section .text.std_strings_builderWrite progbits alloc exec nowrite align=16
global std_strings_builderWrite
; ==============================
; Function: std_strings_builderWrite
std_strings_builderWrite:
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
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov QWORD [rsp+8], 1
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_bGrow
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-64], RAX
; 设置变量box
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-72], RAX
; 设置变量data
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
    mov QWORD[rbp-80], RAX
; 设置变量n0
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-56]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64
    mov QWORD[rbp-88], RAX
; 设置变量chU
    mov RAX, QWORD[rbp-72]
    mov RBX, QWORD[rbp-80]
    mov QWORD[rbp-96], RAX
    add QWORD[rbp-96], RBX
; 设置变量wAddr
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-104], RAX
; 设置变量wP
    mov RBX, QWORD[rbp-88]
    mov RAX, QWORD[rbp-104]
    mov BYTE [RAX], bl
; expression statement
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
    mov QWORD[rbp-112], RAX
; 设置变量nNow
    mov RAX, QWORD[rbp-112]
    mov RBX, 1
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量nNext
    mov RBX, QWORD [RBP-64]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-120]
    mov QWORD[RBX+8], RAX
; 设置变量box.n
    jmp func_end_std_strings_builderWrite
    func_end_std_strings_builderWrite:
    add rsp, 168; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_builderWriteString progbits alloc exec nowrite align=16
global std_strings_builderWriteString
; ==============================
; Function: std_strings_builderWriteString
std_strings_builderWriteString:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 184; 分配局部变量空间(184字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0到栈
    mov QWORD [rbp-72], RSI; 保存参数1槽0到栈
    mov QWORD [rbp-64], RDX; 保存参数1槽1到栈
    mov QWORD [rbp-56], RCX; 保存参数1槽2到栈
    mov RAX, QWORD [rbp-72]
    mov QWORD [rbp-80], RAX
; 设置变量sPtr
    mov RDI, QWORD [rbp-72]
    mov RSI, QWORD [rbp-72+8]
    mov RDX, QWORD [rbp-72+16]
    call __string_len
    mov QWORD[rbp-88], RAX
; 设置变量sLen
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-88]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_bGrow
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-96], RAX
; 设置变量box
    mov RBX, QWORD [RBP-96]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-104], RAX
; 设置变量data
    mov RBX, QWORD [RBP-96]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
    mov QWORD[rbp-112], RAX
; 设置变量nN
    mov RAX, QWORD[rbp-104]
    mov RBX, QWORD[rbp-112]
    mov QWORD[rbp-120], RAX
    add QWORD[rbp-120], RBX
; 设置变量dstBase
    mov QWORD[rbp-128], 0
; 设置变量i




    for_63: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_63_end
    for_63_body:


    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-120]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+8], RAX
; 参数1
    mov RAX, QWORD[rbp-128]
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_putByte
    mov RBX, QWORD[rbp-128]
    mov RAX, 1
    mov QWORD[rbp-128], RBX
    add QWORD[rbp-128], RAX
; 设置变量i
    for_63_continue:


    jmp for_63; for循环
    for_63_end: ; for循环结束
    mov RBX, QWORD[rbp-112]
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-136], RBX
    add QWORD[rbp-136], RAX
; 设置变量nAfter
    mov RBX, QWORD [RBP-96]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD[rbp-136]
    mov QWORD[RBX+8], RAX
; 设置变量box.n
    jmp func_end_std_strings_builderWriteString
    func_end_std_strings_builderWriteString:
    add rsp, 184; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_builderLen progbits alloc exec nowrite align=16
global std_strings_builderLen
; ==============================
; Function: std_strings_builderLen
std_strings_builderLen:
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
; 设置变量box
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
; return值存入RAX
    jmp func_end_std_strings_builderLen
    func_end_std_strings_builderLen:
    add rsp, 104; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_builderString progbits alloc exec nowrite align=16
global std_strings_builderString
; ==============================
; Function: std_strings_builderString
std_strings_builderString:
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
    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-56], RAX
; 设置变量box
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX+8]
    mov QWORD[rbp-64], RAX
; 设置变量n0
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-72], RAX
; 设置变量data
    mov RAX, QWORD[rbp-64]
    mov RBX, 1
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量sizeN
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-80]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_malloc
    mov QWORD[rbp-88], RAX
; 设置变量out
    mov QWORD[rbp-96], 0
; 设置变量i




    for_64: ; for循环开始
    mov RAX, QWORD[rbp-96]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-64]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_64_end
    for_64_body:


    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-88]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RAX, QWORD[rbp-72]
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
    for_64_continue:


    jmp for_64; for循环
    for_64_end: ; for循环结束
    mov RAX, QWORD[rbp-64]
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
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-88]
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
    lea R10, [rbp-160]; 大值返回槽地址
    call std_strings_view
    mov RAX, QWORD [RBP-160]
    mov QWORD [rbp-160+0], RAX
    mov RAX, QWORD [RBP-160+8]
    mov QWORD [rbp-160+8], RAX
    mov RAX, QWORD [RBP-160+16]
    mov QWORD [rbp-160+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-136]; 恢复返回槽地址
    mov RAX, QWORD [rbp-160]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-152]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-144]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_builderString
    func_end_std_strings_builderString:
    add rsp, 168; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


section .text.std_strings_builderFree progbits alloc exec nowrite align=16
global std_strings_builderFree
; ==============================
; Function: std_strings_builderFree
std_strings_builderFree:
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
; 设置变量box
    mov RBX, QWORD [RBP-56]
    test RBX, RBX
    je _panic_nil_deref
    mov RAX, QWORD [RBX]
    mov QWORD[rbp-64], RAX
; 设置变量data
    mov RAX, QWORD[rbp-64]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_355
    if_355:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-64]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    end_if_355:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_memory_free
    jmp func_end_std_strings_builderFree
    func_end_std_strings_builderFree:
    add rsp, 104; 清理局部变量 + 对齐
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




    for_65: ; for循环开始
    mov RAX, QWORD[rbp-68]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_65_end
    for_65_body:


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
    for_65_continue:


    jmp for_65; for循环
    for_65_end: ; for循环结束
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
    je end_if_356
    if_356:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_maps_bytesEq
    end_if_356:
    mov QWORD[rbp-80], 0
; 设置变量i




    for_66: ; for循环开始
    mov RAX, QWORD[rbp-80]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_66_end
    for_66_body:


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
    je end_if_357
    if_357:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_maps_bytesEq
    end_if_357:
    mov RAX, QWORD[rbp-80]
    mov RBX, 1
    mov QWORD[rbp-80], RAX
    add QWORD[rbp-80], RBX
; 设置变量i
    for_66_continue:


    jmp for_66; for循环
    for_66_end: ; for循环结束
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
    str_7 db `world`, 0
    str_7_len equ $ - str_7
    str_8 db `xyz`, 0
    str_8_len equ $ - str_8
    str_21 db `123`, 0
    str_21_len equ $ - str_21
    str_25 db `ABC`, 0
    str_25_len equ $ - str_25
    str_31 db `.go`, 0
    str_31_len equ $ - str_31
    str_39 db `c`, 0
    str_39_len equ $ - str_39
    str_45 db `cd`, 0
    str_45_len equ $ - str_45
    str_47 db `abcdx`, 0
    str_47_len equ $ - str_47
    str_13 db `  hello  `, 0
    str_13_len equ $ - str_13
    str_33 db `hello cute`, 0
    str_33_len equ $ - str_33
    str_42 db `  a b  `, 0
    str_42_len equ $ - str_42
    str_44 db ` e`, 0
    str_44_len equ $ - str_44
    str_6 db `hello world`, 0
    str_6_len equ $ - str_6
    str_9 db `ell`, 0
    str_9_len equ $ - str_9
    str_20 db `aeiou`, 0
    str_20_len equ $ - str_20
    str_30 db `hello.go`, 0
    str_30_len equ $ - str_30
    str_38 db `,`, 0
    str_38_len equ $ - str_38
    str_5 db `b`, 0
    str_5_len equ $ - str_5
    str_23 db `false`, 0
    str_23_len equ $ - str_23
    str_24 db `Hello`, 0
    str_24_len equ $ - str_24
    str_36 db `0`, 0
    str_36_len equ $ - str_36
    str_46 db `abcd`, 0
    str_46_len equ $ - str_46
    str_14 db `aaa`, 0
    str_14_len equ $ - str_14
    str_3 db `abd`, 0
    str_3_len equ $ - str_3
    str_4 db `a`, 0
    str_4_len equ $ - str_4
    str_12 db `HELLO`, 0
    str_12_len equ $ - str_12
    str_15 db `xxhello`, 0
    str_15_len equ $ - str_15
    str_16 db `x`, 0
    str_16_len equ $ - str_16
    str_18 db `xxhelloxx`, 0
    str_18_len equ $ - str_18
    str_22 db `true`, 0
    str_22_len equ $ - str_22
    str_1 db `hello`, 0
    str_1_len equ $ - str_1
    str_26 db `ab`, 0
    str_26_len equ $ - str_26
    str_27 db `cba`, 0
    str_27_len equ $ - str_27
    str_28 db `ababab`, 0
    str_28_len equ $ - str_28
    str_32 db `cute`, 0
    str_32_len equ $ - str_32
    str_40 db `a,`, 0
    str_40_len equ $ - str_40
    str_41 db `b,c`, 0
    str_41_len equ $ - str_41
    str_10 db `hel`, 0
    str_10_len equ $ - str_10
    str_17 db `helloxx`, 0
    str_17_len equ $ - str_17
    str_19 db `o`, 0
    str_19_len equ $ - str_19
    str_34 db `abab`, 0
    str_34_len equ $ - str_34
    str_35 db `FALSE`, 0
    str_35_len equ $ - str_35
    str_37 db `a,b,c`, 0
    str_37_len equ $ - str_37
    str_43 db `b  cd`, 0
    str_43_len equ $ - str_43
    str_2 db `abc`, 0
    str_2_len equ $ - str_2
    str_11 db `llo`, 0
    str_11_len equ $ - str_11
    str_29 db `hello `, 0
    str_29_len equ $ - str_29
