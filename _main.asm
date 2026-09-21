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
    mov RAX, 42
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
; Function: std_strings_trimLeft__string__string
std_strings_trimLeft__string__string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 264; 分配局部变量空间(264字节, 含对齐)
    mov QWORD [rbp-232], R10; 保存返回槽地址
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-64], R8; 保存参数1槽1到栈
    mov QWORD [rbp-56], R9; 保存参数1槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-48]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-48+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-48+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD[rbp-96], RAX
; 设置变量sPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-48]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-48+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-48+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len__string
    mov QWORD[rbp-104], RAX
; 设置变量sLen
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD[rbp-112], RAX
; 设置变量cPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len__string
    mov QWORD[rbp-120], RAX
; 设置变量cLen
    mov QWORD[rbp-128], 0
; 设置变量i




    for_1: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_1_end


    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-136], RAX
    mov RAX, QWORD[rbp-128]
    add QWORD[rbp-136], RAX
; 设置变量_p1
    mov RAX, QWORD[rbp-136]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-144], RAX
; 设置变量ch
    mov BYTE[rbp-145], 0
; 设置变量found
    mov QWORD[rbp-153], 0
; 设置变量j




    for_2: ; for循环开始
    mov RAX, QWORD[rbp-153]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_2_end


    mov RAX, QWORD[rbp-112]
    mov QWORD[rbp-161], RAX
    mov RAX, QWORD[rbp-153]
    add QWORD[rbp-161], RAX
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
    jne end_if_1
    if_1:
    mov BYTE[rbp-145], 1
; 设置变量found
    jmp for_2_end
    end_if_1:
    mov RAX, 1
    add QWORD[rbp-153], RAX
; 设置变量j


    jmp for_2; for循环
    for_2_end: ; for循环结束
    movzx RAX, BYTE[rbp-145]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_2
    if_2:
    jmp for_1_end
    end_if_2:
    mov RAX, 1
    add QWORD[rbp-128], RAX
; 设置变量i


    jmp for_1; for循环
    for_1_end: ; for循环结束
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-177], RAX
    mov RAX, QWORD[rbp-128]
    sub QWORD[rbp-177], RAX
; 设置变量newLen
    mov QWORD[rbp-185], RAX
; 设置变量buf
    mov QWORD[rbp-193], 0
; 设置变量k




    for_3: ; for循环开始
    mov RAX, QWORD[rbp-193]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-177]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_3_end


    mov RAX, QWORD[rbp-185]
    mov QWORD[rbp-201], RAX
    mov RAX, QWORD[rbp-193]
    add QWORD[rbp-201], RAX
; 设置变量_p3
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-209], RAX
    mov RAX, QWORD[rbp-128]
    add QWORD[rbp-209], RAX
    mov RAX, QWORD[rbp-193]
    add QWORD[rbp-209], RAX
; 设置变量_p4
    mov RBX, QWORD[rbp-209]
    movzx RAX, BYTE [RBX]
; unsafe.cast
    mov RBX, QWORD[rbp-201]
    mov BYTE [RBX], al
; expression statement
    mov RAX, 1
    add QWORD[rbp-193], RAX
; 设置变量k


    jmp for_3; for循环
    for_3_end: ; for循环结束
    mov RAX, QWORD[rbp-185]
    mov QWORD[rbp-217], RAX
    mov RAX, QWORD[rbp-177]
    add QWORD[rbp-217], RAX
; 设置变量_p5
    mov RAX, 0
; unsafe.cast
    mov RBX, QWORD[rbp-217]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-185]
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
    lea R10, [rbp-256]; 大值返回槽地址
    call std_strings_makeString__ptr__uint__uint
    mov RAX, QWORD [RBP-256+0]
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
    jmp func_end_std_strings_trimLeft__string__string
    func_end_std_strings_trimLeft__string__string:
    add rsp, 264; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_strings_trimRight__string__string
std_strings_trimRight__string__string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 264; 分配局部变量空间(264字节, 含对齐)
    mov QWORD [rbp-232], R10; 保存返回槽地址
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-64], R8; 保存参数1槽1到栈
    mov QWORD [rbp-56], R9; 保存参数1槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-48]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-48+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-48+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD[rbp-96], RAX
; 设置变量sPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-48]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-48+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-48+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len__string
    mov QWORD[rbp-104], RAX
; 设置变量sLen
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD[rbp-112], RAX
; 设置变量cPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len__string
    mov QWORD[rbp-120], RAX
; 设置变量cLen
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-128], RAX
; 设置变量end




    for_4: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_4_end


    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-136], RAX
    mov RAX, QWORD[rbp-128]
    add QWORD[rbp-136], RAX
    mov RAX, 1
    sub QWORD[rbp-136], RAX
; 设置变量_p6
    mov RAX, QWORD[rbp-136]
    movzx RAX, BYTE [RAX]
    mov QWORD[rbp-144], RAX
; 设置变量ch
    mov BYTE[rbp-145], 0
; 设置变量found
    mov QWORD[rbp-153], 0
; 设置变量j




    for_5: ; for循环开始
    mov RAX, QWORD[rbp-153]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-120]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_5_end


    mov RAX, QWORD[rbp-112]
    mov QWORD[rbp-161], RAX
    mov RAX, QWORD[rbp-153]
    add QWORD[rbp-161], RAX
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
    jne end_if_3
    if_3:
    mov BYTE[rbp-145], 1
; 设置变量found
    jmp for_5_end
    end_if_3:
    mov RAX, 1
    add QWORD[rbp-153], RAX
; 设置变量j


    jmp for_5; for循环
    for_5_end: ; for循环结束
    movzx RAX, BYTE[rbp-145]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_4
    if_4:
    jmp for_4_end
    end_if_4:
    mov RAX, 1
    sub QWORD[rbp-128], RAX
; 设置变量end


    jmp for_4; for循环
    for_4_end: ; for循环结束
    mov QWORD[rbp-177], RAX
; 设置变量buf
    mov QWORD[rbp-185], 0
; 设置变量k




    for_6: ; for循环开始
    mov RAX, QWORD[rbp-185]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-128]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_6_end


    mov RAX, QWORD[rbp-177]
    mov QWORD[rbp-193], RAX
    mov RAX, QWORD[rbp-185]
    add QWORD[rbp-193], RAX
; 设置变量_p8
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-201], RAX
    mov RAX, QWORD[rbp-185]
    add QWORD[rbp-201], RAX
; 设置变量_p9
    mov RBX, QWORD[rbp-201]
    movzx RAX, BYTE [RBX]
; unsafe.cast
    mov RBX, QWORD[rbp-193]
    mov BYTE [RBX], al
; expression statement
    mov RAX, 1
    add QWORD[rbp-185], RAX
; 设置变量k


    jmp for_6; for循环
    for_6_end: ; for循环结束
    mov RAX, QWORD[rbp-177]
    mov QWORD[rbp-209], RAX
    mov RAX, QWORD[rbp-128]
    add QWORD[rbp-209], RAX
; 设置变量_p10
    mov RAX, 0
; unsafe.cast
    mov RBX, QWORD[rbp-209]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-177]
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
    lea R10, [rbp-256]; 大值返回槽地址
    call std_strings_makeString__ptr__uint__uint
    mov RAX, QWORD [RBP-256+0]
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
    jmp func_end_std_strings_trimRight__string__string
    func_end_std_strings_trimRight__string__string:
    add rsp, 264; 清理局部变量 + 对齐
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_strings_indexByte__string__int
std_strings_indexByte__string__int:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 168; 分配局部变量空间(168字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-48]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-48+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-48+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD[rbp-80], RAX
; 设置变量sPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-48]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-48+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-48+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len__string
    mov QWORD[rbp-88], RAX
; 设置变量sLen
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-96], RAX
; 设置变量byteVal
    mov QWORD[rbp-104], 0
; 设置变量i




    for_7: ; for循环开始
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_7_end


    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-112], RAX
    mov RAX, QWORD[rbp-104]
    add QWORD[rbp-112], RAX
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
    jne end_if_5
    if_5:
    mov RAX, QWORD[rbp-104]
; return值存入RAX
    jmp func_end_std_strings_indexByte__string__int
    end_if_5:
    mov RAX, 1
    add QWORD[rbp-104], RAX
; 设置变量i


    jmp for_7; for循环
    for_7_end: ; for循环结束
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_indexByte__string__int
    func_end_std_strings_indexByte__string__int:
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
; Function: std_strings_len__string
__string_len:
std_strings_len__string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    lea RAX, [rbp-48]
    mov QWORD[rbp-72], RAX
; 设置变量p
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-80], RAX
    mov RAX, 8
    add QWORD[rbp-80], RAX
; 设置变量_p1
    mov RBX, QWORD[rbp-80]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_strings_len__string
    func_end_std_strings_len__string:
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
; Function: std_strings_cap__string
__string_cap:
std_strings_cap__string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    lea RAX, [rbp-48]
    mov QWORD[rbp-72], RAX
; 设置变量p
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-80], RAX
    mov RAX, 16
    add QWORD[rbp-80], RAX
; 设置变量_p2
    mov RBX, QWORD[rbp-80]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_strings_cap__string
    func_end_std_strings_cap__string:
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
; Function: std_strings_eq__string__string
__string_eq:
std_strings_eq__string__string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 216; 分配局部变量空间(216字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-64], R8; 保存参数1槽1到栈
    mov QWORD [rbp-56], R9; 保存参数1槽2到栈
    lea RAX, [rbp-48]
    mov QWORD[rbp-96], RAX
; 设置变量p
    lea RAX, [rbp-72]
    mov QWORD[rbp-104], RAX
; 设置变量q
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-112], RAX
; 设置变量_p3
    mov RAX, QWORD[rbp-112]
    mov RAX, QWORD [RAX]
    mov QWORD[rbp-120], RAX
; 设置变量x0
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-128], RAX
; 设置变量_p4
    mov RAX, QWORD[rbp-128]
    mov RAX, QWORD [RAX]
    mov QWORD[rbp-136], RAX
; 设置变量y0
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-136]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_6
    if_6:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_eq__string__string
    end_if_6:
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-144], RAX
    mov RAX, 8
    add QWORD[rbp-144], RAX
; 设置变量_p5
    mov RAX, QWORD[rbp-144]
    mov RAX, QWORD [RAX]
    mov QWORD[rbp-152], RAX
; 设置变量x1
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-160], RAX
    mov RAX, 8
    add QWORD[rbp-160], RAX
; 设置变量_p6
    mov RAX, QWORD[rbp-160]
    mov RAX, QWORD [RAX]
    mov QWORD[rbp-168], RAX
; 设置变量y1
    mov RAX, QWORD[rbp-152]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-168]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_7
    if_7:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_eq__string__string
    end_if_7:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_eq__string__string
    func_end_std_strings_eq__string__string:
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
; Function: std_strings_ne__string__string
__string_ne:
std_strings_ne__string__string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 216; 分配局部变量空间(216字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-64], R8; 保存参数1槽1到栈
    mov QWORD [rbp-56], R9; 保存参数1槽2到栈
    lea RAX, [rbp-48]
    mov QWORD[rbp-96], RAX
; 设置变量p
    lea RAX, [rbp-72]
    mov QWORD[rbp-104], RAX
; 设置变量q
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-112], RAX
; 设置变量_p7
    mov RAX, QWORD[rbp-112]
    mov RAX, QWORD [RAX]
    mov QWORD[rbp-120], RAX
; 设置变量x0
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-128], RAX
; 设置变量_p8
    mov RAX, QWORD[rbp-128]
    mov RAX, QWORD [RAX]
    mov QWORD[rbp-136], RAX
; 设置变量y0
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-136]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_8
    if_8:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_ne__string__string
    end_if_8:
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-144], RAX
    mov RAX, 8
    add QWORD[rbp-144], RAX
; 设置变量_p9
    mov RAX, QWORD[rbp-144]
    mov RAX, QWORD [RAX]
    mov QWORD[rbp-152], RAX
; 设置变量x1
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-160], RAX
    mov RAX, 8
    add QWORD[rbp-160], RAX
; 设置变量_p10
    mov RAX, QWORD[rbp-160]
    mov RAX, QWORD [RAX]
    mov QWORD[rbp-168], RAX
; 设置变量y1
    mov RAX, QWORD[rbp-152]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-168]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    je end_if_9
    if_9:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_ne__string__string
    end_if_9:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_ne__string__string
    func_end_std_strings_ne__string__string:
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
; Function: std_strings_toCstring__string
__string_toCstring:
std_strings_toCstring__string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    lea RAX, [rbp-48]
    mov QWORD[rbp-72], RAX
; 设置变量p
    mov RAX, QWORD[rbp-72]
    mov QWORD[rbp-80], RAX
; 设置变量_p11
    mov RBX, QWORD[rbp-80]
    mov RAX, QWORD [RBX]
; return值存入RAX
    jmp func_end_std_strings_toCstring__string
    func_end_std_strings_toCstring__string:
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
; Function: std_strings_toU64__int
__string_toU64:
std_strings_toU64__int:
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
    jmp func_end_std_strings_toU64__int
    func_end_std_strings_toU64__int:
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
; Function: std_strings_fromI64__u64
__string_fromI64:
std_strings_fromI64__u64:
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
    mov RBX, QWORD[rbp-72]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, QWORD[rbp-56]
; return值存入RAX
    jmp func_end_std_strings_fromI64__u64
    func_end_std_strings_fromI64__u64:
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
; Function: std_strings_toString__int__uint
__string_toString:
std_strings_toString__int__uint:
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
    jge else_if_10
    if_10:
    mov BYTE[rbp-57], 1
; 设置变量neg
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], 0
    sub QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64__int
    mov QWORD[rbp-65], RAX
; 设置变量num
    jmp end_if_10
    else_if_10:
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-48]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_toU64__int
    mov QWORD[rbp-65], RAX
; 设置变量num
    end_if_10:
    mov QWORD[rbp-73], 1
; 设置变量digits
    mov RAX, QWORD[rbp-65]
    mov QWORD[rbp-81], RAX
; 设置变量tmp




    for_8: ; for循环开始
    mov RAX, QWORD[rbp-81]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb for_8_end


    mov RAX, QWORD[rbp-56]
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-81]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-81], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量tmp
    mov RAX, 1
    add QWORD[rbp-73], RAX
; 设置变量digits


    jmp for_8; for循环
    for_8_end: ; for循环结束
    mov RAX, QWORD[rbp-73]
    mov QWORD[rbp-89], RAX
; 设置变量total
    movzx RAX, BYTE[rbp-57]
; condition
    test RAX, RAX
    jz end_if_11
    if_11:
    mov RAX, 1
    add QWORD[rbp-89], RAX
; 设置变量total
    end_if_11:
    mov QWORD[rbp-97], RAX
; 设置变量buf
    mov RAX, QWORD[rbp-65]
    mov QWORD[rbp-105], RAX
; 设置变量v
    mov RAX, QWORD[rbp-105]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne else_if_12
    if_12:
    mov RAX, QWORD[rbp-97]
    mov QWORD[rbp-113], RAX
; 设置变量_p14
    mov RAX, 48
; unsafe.cast
    mov RBX, QWORD[rbp-113]
    mov BYTE [RBX], al
; expression statement
    jmp end_if_12
    else_if_12:
    mov QWORD[rbp-121], 0
; 设置变量i




    for_9: ; for循环开始
    mov RAX, QWORD[rbp-105]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe for_9_end


    mov RAX, QWORD[rbp-105]
    mov QWORD[rbp-129], RAX
    mov RAX, QWORD[rbp-56]
    push RAX; 保护RAX(左子结果)
    push RAX; 保存除数
    mov rax, QWORD[rbp-129]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-129], rdx
    pop RAX; 恢复RAX(左子结果)
; 设置变量digit
    mov QWORD[rbp-137], 0
; 设置变量ch
    mov RAX, QWORD[rbp-129]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 10
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_13
    if_13:
    mov RAX, QWORD[rbp-129]
    mov QWORD[rbp-137], RAX
    mov RAX, 48
    add QWORD[rbp-137], RAX
; 设置变量ch
    jmp end_if_13
    else_if_13:
    mov RAX, QWORD[rbp-129]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 36
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb else_if_14
    if_14:
    mov RAX, QWORD[rbp-129]
    mov QWORD[rbp-137], RAX
    mov RAX, 97
    add QWORD[rbp-137], RAX
    mov RAX, 10
    sub QWORD[rbp-137], RAX
; 设置变量ch
    jmp end_if_14
    else_if_14:
    mov RAX, QWORD[rbp-129]
    mov QWORD[rbp-137], RAX
    mov RAX, 65
    add QWORD[rbp-137], RAX
    mov RAX, 36
    sub QWORD[rbp-137], RAX
; 设置变量ch
    end_if_14:
    end_if_13:
    mov RAX, QWORD[rbp-89]
    mov RBX, 1
    sub RAX, RBX
    mov RBX, QWORD[rbp-121]
    sub RAX, RBX
    mov RBX, QWORD[rbp-97]
    mov QWORD[rbp-145], RBX
    add QWORD[rbp-145], RAX
; 设置变量_p15
    mov RBX, QWORD[rbp-137]
; unsafe.cast
    mov RAX, QWORD[rbp-145]
    mov BYTE [RAX], bl
; expression statement
    mov RBX, QWORD[rbp-56]
    push RAX; 保护RAX(左子结果)
    push RBX; 保存除数
    mov rax, QWORD[rbp-105]
    cqo
    idiv qword [rsp]
    add rsp, 8; 清理除数
    mov QWORD[rbp-105], rax
    pop RAX; 恢复RAX(左子结果)
; 设置变量v
    mov RAX, 1
    add QWORD[rbp-121], RAX
; 设置变量i


    jmp for_9; for循环
    for_9_end: ; for循环结束
    end_if_12:
    movzx RAX, BYTE[rbp-57]
; condition
    test RAX, RAX
    jz end_if_15
    if_15:
    mov RAX, QWORD[rbp-97]
    mov QWORD[rbp-153], RAX
; 设置变量_p16
    mov RBX, 45
; unsafe.cast
    mov RAX, QWORD[rbp-153]
    mov BYTE [RAX], bl
; expression statement
    end_if_15:
    mov RBX, QWORD[rbp-97]
    mov QWORD[rbp-161], RBX
    mov RBX, QWORD[rbp-89]
    add QWORD[rbp-161], RBX
; 设置变量_p17
    mov RBX, 0
; unsafe.cast
    mov RAX, QWORD[rbp-161]
    mov BYTE [RAX], bl
; expression statement
    mov QWORD [rbp-185], 0
    mov QWORD [rbp-185+8], 0
    mov QWORD [rbp-185+16], 0
    ; 零值容器 s
    lea RAX, [rbp-185]
    mov QWORD[rbp-193], RAX
; 设置变量p
    mov RAX, QWORD[rbp-97]
    mov QWORD[rbp-201], RAX
; 设置变量b
    mov RAX, QWORD[rbp-193]
    mov QWORD[rbp-209], RAX
; 设置变量_p18
    mov RBX, QWORD[rbp-201]
; unsafe.cast
    mov RAX, QWORD[rbp-209]
    mov QWORD [RAX], RBX
; expression statement
    mov RBX, QWORD[rbp-193]
    mov QWORD[rbp-217], RBX
    mov RAX, 8
    add QWORD[rbp-217], RAX
; 设置变量_p19
    mov RBX, QWORD[rbp-89]
; unsafe.cast
    mov RAX, QWORD[rbp-217]
    mov QWORD [RAX], RBX
; expression statement
    mov RBX, QWORD[rbp-193]
    mov QWORD[rbp-225], RBX
    mov RAX, 16
    add QWORD[rbp-225], RAX
; 设置变量_p20
    mov RBX, QWORD[rbp-89]
; unsafe.cast
    mov RAX, QWORD[rbp-225]
    mov QWORD [RAX], RBX
; expression statement
    mov RAX, QWORD [rbp-185+0]
    mov QWORD [rbp-272+0], RAX
    mov RAX, QWORD [rbp-185+8]
    mov QWORD [rbp-272+8], RAX
    mov RAX, QWORD [rbp-185+16]
    mov QWORD [rbp-272+16], RAX
; return值存入返回槽
    mov R10, QWORD [rbp-248]; 恢复返回槽地址
    mov RAX, QWORD [rbp-272]
    mov QWORD [R10], RAX
    mov RAX, QWORD [rbp-264]
    mov QWORD [R10+8], RAX
    mov RAX, QWORD [rbp-256]
    mov QWORD [R10+16], RAX
    jmp func_end_std_strings_toString__int__uint
    func_end_std_strings_toString__int__uint:
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
; Function: std_strings_parse__string__uint
__string_parse:
std_strings_parse__string__uint:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 232; 分配局部变量空间(232字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1到栈
    lea RAX, [rbp-48]
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
    mov QWORD[rbp-104], RAX
    mov RAX, 8
    add QWORD[rbp-104], RAX
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
    jne end_if_16
    if_16:
    mov BYTE[rbp-121], 1
; 设置变量neg
    mov QWORD[rbp-120], 1
; 设置变量i
    end_if_16:
    mov QWORD[rbp-145], 0
; 设置变量val
    mov BYTE[rbp-146], 0
; 设置变量bad




    for_10: ; for循环开始
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-112]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_10_end


    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-154], RAX
    mov RAX, QWORD[rbp-120]
    add QWORD[rbp-154], RAX
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
    jb else_if_17
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 57
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_17
    if_17:
    mov RAX, QWORD[rbp-162]
    mov QWORD[rbp-170], RAX
    mov RAX, 48
    sub QWORD[rbp-170], RAX
; 设置变量v
    jmp end_if_17
    else_if_17:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 97
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_18
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 122
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_18
    if_18:
    mov RAX, QWORD[rbp-162]
    mov QWORD[rbp-170], RAX
    mov RAX, 97
    sub QWORD[rbp-170], RAX
    mov RAX, 10
    add QWORD[rbp-170], RAX
; 设置变量v
    jmp end_if_18
    else_if_18:
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 65
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jb else_if_19
    mov RAX, QWORD[rbp-162]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 90
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe else_if_19
    if_19:
    mov RAX, QWORD[rbp-162]
    mov QWORD[rbp-170], RAX
    mov RAX, 65
    sub QWORD[rbp-170], RAX
    mov RAX, 36
    add QWORD[rbp-170], RAX
; 设置变量v
    jmp end_if_19
    else_if_19:
    mov BYTE[rbp-146], 1
; 设置变量bad
    end_if_19:
    end_if_18:
    end_if_17:
    movzx RAX, BYTE[rbp-146]
    cmp RAX, 0
    sete al
    movzx RAX, al
; condition
    test RAX, RAX
    jz end_if_20
    if_20:
    mov RAX, QWORD[rbp-72]
    push RAX; 保护RAX(左子结果)
    push RAX; 暂存乘数
    mov RAX, QWORD[rbp-145]
    imul RAX, qword [rsp]
    mov QWORD[rbp-145], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
    mov RAX, QWORD[rbp-170]
    add QWORD[rbp-145], RAX
; 设置变量val
    end_if_20:
    mov RAX, 1
    add QWORD[rbp-120], RAX
; 设置变量i


    jmp for_10; for循环
    for_10_end: ; for循环结束
    sub rsp, 16; register args buffer
    mov RAX, QWORD[rbp-145]
    mov QWORD [rsp+0], RAX
; 参数0
    mov RDI, QWORD [rsp+0]; 装载参数0
    add rsp, 16; 释放寄存器参数 buffer
    call std_strings_fromI64__u64
    mov QWORD[rbp-178], RAX
; 设置变量r
    movzx RAX, BYTE[rbp-121]
; condition
    test RAX, RAX
    jz end_if_21
    if_21:
    mov RAX, QWORD[rbp-178]
    mov QWORD[rbp-178], 0
    sub QWORD[rbp-178], RAX
; 设置变量r
    end_if_21:
    mov RAX, QWORD[rbp-178]
; return值存入RAX
    jmp func_end_std_strings_parse__string__uint
    func_end_std_strings_parse__string__uint:
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
; Function: std_strings_makeString__ptr__uint__uint
std_strings_makeString__ptr__uint__uint:
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
    mov RBX, QWORD[rbp-104]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-112], RAX
    mov RAX, 8
    add QWORD[rbp-112], RAX
; 设置变量_p27
    mov RAX, QWORD[rbp-56]
; unsafe.cast
    mov RBX, QWORD[rbp-112]
    mov QWORD [RBX], RAX
; expression statement
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-120], RAX
    mov RAX, 16
    add QWORD[rbp-120], RAX
; 设置变量_p28
    mov RAX, QWORD[rbp-64]
; unsafe.cast
    mov RBX, QWORD[rbp-120]
    mov QWORD [RBX], RAX
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
    jmp func_end_std_strings_makeString__ptr__uint__uint
    func_end_std_strings_makeString__ptr__uint__uint:
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
; Function: std_strings_indexFrom__ptr__uint__ptr__uint__uint
std_strings_indexFrom__ptr__uint__ptr__uint__uint:
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
    jne end_if_22
    if_22:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_indexFrom__ptr__uint__ptr__uint__uint
    end_if_22:
    mov RAX, QWORD[rbp-72]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-56]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jbe end_if_23
    if_23:
    call std_strings_notFound
; return值存入RAX
    jmp func_end_std_strings_indexFrom__ptr__uint__ptr__uint__uint
    end_if_23:
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-88], RAX
; 设置变量i
    mov RAX, QWORD[rbp-56]
    mov QWORD[rbp-96], RAX
    mov RAX, QWORD[rbp-72]
    sub QWORD[rbp-96], RAX
; 设置变量limit




    for_11: ; for循环开始
    mov RAX, QWORD[rbp-88]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-96]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnbe for_11_end


    mov BYTE[rbp-97], 1
; 设置变量found
    mov QWORD[rbp-105], 0
; 设置变量j




    for_12: ; for循环开始
    mov RAX, QWORD[rbp-105]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_12_end


    mov RAX, QWORD[rbp-48]
    mov QWORD[rbp-113], RAX
    mov RAX, QWORD[rbp-88]
    add QWORD[rbp-113], RAX
    mov RAX, QWORD[rbp-105]
    add QWORD[rbp-113], RAX
; 设置变量_p29
    mov RAX, QWORD[rbp-64]
    mov QWORD[rbp-121], RAX
    mov RAX, QWORD[rbp-105]
    add QWORD[rbp-121], RAX
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
    je end_if_24
    if_24:
    mov BYTE[rbp-97], 0
; 设置变量found
    jmp for_12_end
    end_if_24:
    mov RAX, 1
    add QWORD[rbp-105], RAX
; 设置变量j


    jmp for_12; for循环
    for_12_end: ; for循环结束
    movzx RAX, BYTE[rbp-97]
; condition
    test RAX, RAX
    jz end_if_25
    if_25:
    mov RAX, QWORD[rbp-88]
; return值存入RAX
    jmp func_end_std_strings_indexFrom__ptr__uint__ptr__uint__uint
    end_if_25:
    mov RAX, 1
    add QWORD[rbp-88], RAX
; 设置变量i


    jmp for_11; for循环
    for_11_end: ; for循环结束
    call std_strings_notFound
; return值存入RAX
    jmp func_end_std_strings_indexFrom__ptr__uint__ptr__uint__uint
    func_end_std_strings_indexFrom__ptr__uint__ptr__uint__uint:
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
; Function: std_strings_index__string__string
std_strings_index__string__string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 184; 分配局部变量空间(184字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-64], R8; 保存参数1槽1到栈
    mov QWORD [rbp-56], R9; 保存参数1槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-48]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-48+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-48+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD[rbp-96], RAX
; 设置变量sPtr
    mov RDI, QWORD [rbp-48]
    mov RSI, QWORD [rbp-48+8]
    mov RDX, QWORD [rbp-48+16]
    call __string_len
    mov QWORD[rbp-104], RAX
; 设置变量sLen
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD[rbp-112], RAX
; 设置变量tPtr
    mov RDI, QWORD [rbp-72]
    mov RSI, QWORD [rbp-72+8]
    mov RDX, QWORD [rbp-72+16]
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
    call std_strings_indexFrom__ptr__uint__ptr__uint__uint
    mov QWORD[rbp-136], RAX
; 设置变量r
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-128]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_26
    if_26:
    mov RAX, -1
; return值存入RAX
    jmp func_end_std_strings_index__string__string
    end_if_26:
    mov RAX, QWORD[rbp-136]
; return值存入RAX
    jmp func_end_std_strings_index__string__string
    func_end_std_strings_index__string__string:
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
; Function: std_strings_hasPrefix__string__string
std_strings_hasPrefix__string__string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 184; 分配局部变量空间(184字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-64], R8; 保存参数1槽1到栈
    mov QWORD [rbp-56], R9; 保存参数1槽2到栈
    mov RDI, QWORD [rbp-48]
    mov RSI, QWORD [rbp-48+8]
    mov RDX, QWORD [rbp-48+16]
    call __string_len
    mov QWORD[rbp-96], RAX
; 设置变量sLen
    mov RDI, QWORD [rbp-72]
    mov RSI, QWORD [rbp-72+8]
    mov RDX, QWORD [rbp-72+16]
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
    jbe end_if_27
    if_27:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasPrefix__string__string
    end_if_27:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_28
    if_28:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_hasPrefix__string__string
    end_if_28:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-48]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-48+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-48+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD[rbp-112], RAX
; 设置变量sPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD[rbp-120], RAX
; 设置变量tPtr
    mov QWORD[rbp-128], 0
; 设置变量i




    for_13: ; for循环开始
    mov RAX, QWORD[rbp-128]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_13_end


    mov RAX, QWORD[rbp-112]
    mov QWORD[rbp-136], RAX
    mov RAX, QWORD[rbp-128]
    add QWORD[rbp-136], RAX
; 设置变量_p31
    mov RAX, QWORD[rbp-120]
    mov QWORD[rbp-144], RAX
    mov RAX, QWORD[rbp-128]
    add QWORD[rbp-144], RAX
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
    je end_if_29
    if_29:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasPrefix__string__string
    end_if_29:
    mov RAX, 1
    add QWORD[rbp-128], RAX
; 设置变量i


    jmp for_13; for循环
    for_13_end: ; for循环结束
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_hasPrefix__string__string
    func_end_std_strings_hasPrefix__string__string:
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
; Function: std_strings_hasSuffix__string__string
std_strings_hasSuffix__string__string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 200; 分配局部变量空间(200字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1槽0到栈
    mov QWORD [rbp-64], R8; 保存参数1槽1到栈
    mov QWORD [rbp-56], R9; 保存参数1槽2到栈
    mov RDI, QWORD [rbp-48]
    mov RSI, QWORD [rbp-48+8]
    mov RDX, QWORD [rbp-48+16]
    call __string_len
    mov QWORD[rbp-96], RAX
; 设置变量sLen
    mov RDI, QWORD [rbp-72]
    mov RSI, QWORD [rbp-72+8]
    mov RDX, QWORD [rbp-72+16]
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
    jbe end_if_30
    if_30:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasSuffix__string__string
    end_if_30:
    mov RAX, QWORD[rbp-104]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, 0
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jne end_if_31
    if_31:
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_hasSuffix__string__string
    end_if_31:
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-48]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-48+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-48+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD[rbp-112], RAX
; 设置变量sPtr
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-72]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-72+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-72+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD[rbp-120], RAX
; 设置变量tPtr
    mov RAX, QWORD[rbp-96]
    mov QWORD[rbp-128], RAX
    mov RAX, QWORD[rbp-104]
    sub QWORD[rbp-128], RAX
; 设置变量offset
    mov QWORD[rbp-136], 0
; 设置变量i




    for_14: ; for循环开始
    mov RAX, QWORD[rbp-136]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-104]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_14_end


    mov RAX, QWORD[rbp-112]
    mov QWORD[rbp-144], RAX
    mov RAX, QWORD[rbp-128]
    add QWORD[rbp-144], RAX
    mov RAX, QWORD[rbp-136]
    add QWORD[rbp-144], RAX
; 设置变量_p33
    mov RAX, QWORD[rbp-120]
    mov QWORD[rbp-152], RAX
    mov RAX, QWORD[rbp-136]
    add QWORD[rbp-152], RAX
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
    je end_if_32
    if_32:
    mov RAX, 0
; return值存入RAX
    jmp func_end_std_strings_hasSuffix__string__string
    end_if_32:
    mov RAX, 1
    add QWORD[rbp-136], RAX
; 设置变量i


    jmp for_14; for循环
    for_14_end: ; for循环结束
    mov RAX, 1
; return值存入RAX
    jmp func_end_std_strings_hasSuffix__string__string
    func_end_std_strings_hasSuffix__string__string:
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
; Function: std_strings_repeat__string__uint
std_strings_repeat__string__uint:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 184; 分配局部变量空间(184字节, 含对齐)
    mov QWORD [rbp-152], R10; 保存返回槽地址
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    mov QWORD [rbp-72], RCX; 保存参数1到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-48]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-48+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-48+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD[rbp-80], RAX
; 设置变量sPtr
    mov RDI, QWORD [rbp-48]
    mov RSI, QWORD [rbp-48+8]
    mov RDX, QWORD [rbp-48+16]
    call __string_len
    mov QWORD[rbp-88], RAX
; 设置变量sLen
    mov RAX, QWORD[rbp-88]
    mov QWORD[rbp-96], RAX
    mov RAX, QWORD[rbp-72]
    push RAX; 保护RAX(左子结果)
    push RAX; 暂存乘数
    mov RAX, QWORD[rbp-96]
    imul RAX, qword [rsp]
    mov QWORD[rbp-96], RAX
    add rsp, 8; 清理乘数
    pop RAX; 恢复RAX(左子结果)
; 设置变量total
    mov QWORD[rbp-104], RAX
; 设置变量buf
    mov QWORD[rbp-112], 0
; 设置变量i




    for_15: ; for循环开始
    mov RAX, QWORD[rbp-112]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-72]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_15_end


    mov QWORD[rbp-120], 0
; 设置变量j




    for_16: ; for循环开始
    mov RAX, QWORD[rbp-120]
; left operand
    mov R12, RAX; 保存左操作数到callee-save
    mov RCX, QWORD[rbp-88]
; right operand
    mov RAX, R12; 恢复左操作数
    cmp RAX, RCX
    jnb for_16_end


    mov RAX, QWORD[rbp-112]
    mov RBX, QWORD[rbp-88]
    imul RAX, RBX
    mov RBX, QWORD[rbp-104]
    mov QWORD[rbp-128], RBX
    add QWORD[rbp-128], RAX
    mov RBX, QWORD[rbp-120]
    add QWORD[rbp-128], RBX
; 设置变量_p52
    mov RAX, QWORD[rbp-80]
    mov QWORD[rbp-136], RAX
    mov RAX, QWORD[rbp-120]
    add QWORD[rbp-136], RAX
; 设置变量_p53
    mov RBX, QWORD[rbp-136]
    movzx RAX, BYTE [RBX]
; unsafe.cast
    mov RBX, QWORD[rbp-128]
    mov BYTE [RBX], al
; expression statement
    mov RAX, 1
    add QWORD[rbp-120], RAX
; 设置变量j


    jmp for_16; for循环
    for_16_end: ; for循环结束
    mov RAX, 1
    add QWORD[rbp-112], RAX
; 设置变量i


    jmp for_15; for循环
    for_15_end: ; for循环结束
    mov RAX, QWORD[rbp-104]
    mov QWORD[rbp-144], RAX
    mov RAX, QWORD[rbp-96]
    add QWORD[rbp-144], RAX
; 设置变量_p54
    mov RAX, 0
; unsafe.cast
    mov RBX, QWORD[rbp-144]
    mov BYTE [RBX], al
; expression statement
    sub rsp, 32; register args buffer
    mov RAX, QWORD[rbp-104]
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
    lea R10, [rbp-176]; 大值返回槽地址
    call std_strings_makeString__ptr__uint__uint
    mov RAX, QWORD [RBP-176+0]
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
    jmp func_end_std_strings_repeat__string__uint
    func_end_std_strings_repeat__string__uint:
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
; Function: std_syscall_syscall__u64__u64__u64__u64
std_syscall_syscall__u64__u64__u64__u64:
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
    func_end_std_syscall_syscall__u64__u64__u64__u64:
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
; Function: std_syscall_syscall64__u64__u64__u64__u64__u64__u64
std_syscall_syscall64__u64__u64__u64__u64__u64__u64:
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
    func_end_std_syscall_syscall64__u64__u64__u64__u64__u64__u64:
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
; Function: std_syscall_exit__i32
std_syscall_exit__i32:
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
    call std_syscall_syscall__u64__u64__u64__u64
    func_end_std_syscall_exit__i32:
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
; Function: std_syscall_brk__ptr
std_syscall_brk__ptr:
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
    call std_syscall_syscall64__u64__u64__u64__u64__u64__u64
; return值存入RAX
    jmp func_end_std_syscall_brk__ptr
    func_end_std_syscall_brk__ptr:
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
; Function: std_syscall_write__i32__ptr__u64
std_syscall_write__i32__ptr__u64:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov DWORD [rbp-48], EDI; 保存参数0到栈
    mov QWORD [rbp-52], RSI; 保存参数1到栈
    mov QWORD [rbp-60], RDX; 保存参数2到栈
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
    mov EBX, DWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RBX, QWORD[rbp-52]
    mov QWORD [rsp+16], RBX
; 参数2
    mov RBX, QWORD[rbp-60]
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
    call std_syscall_syscall64__u64__u64__u64__u64__u64__u64
; return值存入RAX
    jmp func_end_std_syscall_write__i32__ptr__u64
    func_end_std_syscall_write__i32__ptr__u64:
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
; Function: std_syscall_read__i32__ptr__u64
std_syscall_read__i32__ptr__u64:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov DWORD [rbp-48], EDI; 保存参数0到栈
    mov QWORD [rbp-52], RSI; 保存参数1到栈
    mov QWORD [rbp-60], RDX; 保存参数2到栈
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], 0
; 参数0
    mov EBX, DWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov RBX, QWORD[rbp-52]
    mov QWORD [rsp+16], RBX
; 参数2
    mov RBX, QWORD[rbp-60]
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
    call std_syscall_syscall64__u64__u64__u64__u64__u64__u64
; return值存入RAX
    jmp func_end_std_syscall_read__i32__ptr__u64
    func_end_std_syscall_read__i32__ptr__u64:
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
; Function: std_syscall_open__u64__i32__u32
std_syscall_open__u64__i32__u32:
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
    mov DWORD [rbp-60], EDX; 保存参数2到栈
    sub rsp, 48; register args buffer
    mov QWORD [rsp+0], 2
; 参数0
    mov RBX, QWORD[rbp-48]
    mov QWORD [rsp+8], RBX
; 参数1
    mov EBX, DWORD[rbp-56]
    mov QWORD [rsp+16], RBX
; 参数2
    mov EBX, DWORD[rbp-60]
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
    call std_syscall_syscall64__u64__u64__u64__u64__u64__u64
; return值存入RAX
    jmp func_end_std_syscall_open__u64__i32__u32
    func_end_std_syscall_open__u64__i32__u32:
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
; Function: std_syscall_close__i32
std_syscall_close__i32:
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
    call std_syscall_syscall__u64__u64__u64__u64
; return值存入RAX
    jmp func_end_std_syscall_close__i32
    func_end_std_syscall_close__i32:
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
; Function: std_builtin_print__string
std_builtin_print__string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 104; 分配局部变量空间(104字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-48]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-48+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-48+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD [rsp+8], RAX
; 参数1
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-48]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-48+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-48+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_len__string
    mov QWORD [rsp+16], RAX
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_syscall_write__i32__ptr__u64
; return值存入RAX
    jmp func_end_std_builtin_print__string
    func_end_std_builtin_print__string:
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
; Function: std_builtin_println__string
std_builtin_println__string:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 120; 分配局部变量空间(120字节, 含对齐)
    mov QWORD [rbp-48], RDI; 保存参数0槽0到栈
    mov QWORD [rbp-40], RSI; 保存参数0槽1到栈
    mov QWORD [rbp-32], RDX; 保存参数0槽2到栈
    sub rsp, 32; register args buffer
    mov RAX, QWORD [rbp-48]
    mov QWORD [rsp+0], RAX
    mov RAX, QWORD [rbp-48+8]
    mov QWORD [rsp+8], RAX
    mov RAX, QWORD [rbp-48+16]
    mov QWORD [rsp+16], RAX
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_builtin_print__string
    mov DWORD[rbp-68], EAX
; 设置变量n
    mov EAX, DWORD[rbp-68]
    mov RBX, RAX
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], 1
; 参数0
    sub rsp, 32; register args buffer
    mov QWORD [rsp+0], str_1; ptr
    mov QWORD [rsp+8], 2; len
    mov QWORD [rsp+16], 2; cap
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数0
    mov RDX, QWORD [rsp+16]; 装载参数0
    add rsp, 32; 释放寄存器参数 buffer
    call std_strings_toCstring__string
    mov QWORD [rsp+8], RAX
; 参数1
    mov QWORD [rsp+16], 1
; 参数2
    mov RDI, QWORD [rsp+0]; 装载参数0
    mov RSI, QWORD [rsp+8]; 装载参数1
    mov RDX, QWORD [rsp+16]; 装载参数2
    add rsp, 32; 释放寄存器参数 buffer
    call std_syscall_write__i32__ptr__u64
    mov RCX, RAX
    mov RAX, RBX
    add RAX, RCX
; return值存入RAX
    jmp func_end_std_builtin_println__string
    func_end_std_builtin_println__string:
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
    str_1 db "\\n", 0
    str_1_len equ $ - str_1
