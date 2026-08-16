section .data
    __global_g_h0 dd 0
    __global_g_h1 dd 0
    __global_g_h2 dd 0
    __global_g_h3 dd 0
    __global_g_h4 dd 0
    __global_g_h5 dd 0
    __global_g_h6 dd 0
    __global_g_h7 dd 0
    __global_g_h8 dd 0
section .text
global _start

; ==============================
; Function: Vector2D_length0
Vector2D_length0:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EBX, DWORD[ebp+8]
    mov EAX, DWORD [EBX]
    mov ECX, DWORD[ebp+8]
    mov EBX, DWORD [ECX]
    imul EAX, EBX
    mov ECX, DWORD[ebp+8]
    mov EBX, DWORD [ECX+4]
    mov EDX, DWORD[ebp+8]
    mov ECX, DWORD [EDX+4]
    imul EBX, ECX
    add EAX, EBX
; return值存入EAX
    jmp func_end_Vector2D_length0; 跳转到公共返回点
    func_end_Vector2D_length0:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: Vector2D_scale1
Vector2D_scale1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EBX, DWORD[ebp+8]
    mov ECX, DWORD[ebp+8]
    mov EAX, DWORD [ECX]
    mov DWORD[EBX], EAX
    mov EAX, DWORD[ebp+12]
    push EAX; 暂存乘数
    mov EAX, DWORD[EBX]
    imul EAX, dword [esp]
    mov DWORD[EBX], EAX
    add esp, 4; 清理乘数
; 设置变量self.x
    mov EBX, DWORD[ebp+8]
    mov ECX, DWORD[ebp+8]
    mov EAX, DWORD [ECX+4]
    mov DWORD[EBX+4], EAX
    mov EAX, DWORD[ebp+12]
    push EAX; 暂存乘数
    mov EAX, DWORD[EBX+4]
    imul EAX, dword [esp]
    mov DWORD[EBX+4], EAX
    add esp, 4; 清理乘数
; 设置变量self.y
    func_end_Vector2D_scale1:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: Matrix_get2
Matrix_get2:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov ECX, DWORD[ebp+8]
    mov ECX, DWORD[ebp+12]
    mov EAX, DWORD[ebp+8]
    mov EDX, DWORD [EAX+16]
    imul ECX, EDX
    mov EDX, DWORD[ebp+16]
    add ECX, EDX
    imul ECX, 4
    add EBX, ECX
    mov EAX, DWORD [EBX]
; return值存入EAX
    jmp func_end_Matrix_get2; 跳转到公共返回点
    func_end_Matrix_get2:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: Matrix_set3
Matrix_set3:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+20]
    mov ECX, DWORD[ebp+8]
    mov ECX, DWORD[ebp+12]
    mov EAX, DWORD[ebp+8]
    mov EDX, DWORD [EAX+16]
    imul ECX, EDX
    mov EDX, DWORD[ebp+16]
    add ECX, EDX
    imul ECX, 4
    add EBX, ECX
    mov DWORD [EBX], EAX
; list index assignment
    func_end_Matrix_set3:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: fibonacci1
fibonacci1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 1
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_1
    if_1:
    mov EAX, DWORD[ebp+8]
; return值存入EAX
    jmp func_end_fibonacci1; 跳转到公共返回点
    end_if_1:
    mov EBX, DWORD[ebp+8]
    mov ECX, 1
    sub EBX, ECX
    push EBX
; 参数0
    call fibonacci1
    add esp, 4; cdecl: 清理参数栈
    mov EBX, EAX
    mov EDX, DWORD[ebp+8]
    mov EAX, 2
    sub EDX, EAX
    push EDX
; 参数0
    call fibonacci1
    add esp, 4; cdecl: 清理参数栈
    mov ECX, EAX
    mov EAX, EBX
    add EAX, ECX
; return值存入EAX
    jmp func_end_fibonacci1; 跳转到公共返回点
    func_end_fibonacci1:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: factorial1
factorial1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 1
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_2
    if_2:
    mov EAX, 1
; return值存入EAX
    jmp func_end_factorial1; 跳转到公共返回点
    end_if_2:
    mov EAX, DWORD[ebp+8]
    mov EBX, EAX
    mov EDX, DWORD[ebp+8]
    mov EAX, 1
    sub EDX, EAX
    push EDX
; 参数0
    call factorial1
    add esp, 4; cdecl: 清理参数栈
    mov ECX, EAX
    mov EAX, EBX
    imul EAX, ECX
; return值存入EAX
    jmp func_end_factorial1; 跳转到公共返回点
    func_end_factorial1:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: power2
power2:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+12]
; left operand
    push EAX; 保护左操作数

    mov ECX, 0
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_3
    if_3:
    mov EAX, 1
; return值存入EAX
    jmp func_end_power2; 跳转到公共返回点
    end_if_3:
    mov EAX, DWORD[ebp+12]
    mov EBX, 2
    push EBX; 保存除数
    mov eax, EAX
    cdq
    idiv dword [esp]
    add esp, 4; 清理除数
    mov EAX, edx
; left operand
    push EAX; 保护左操作数

    mov ECX, 0
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_4
    if_4:
    mov EBX, DWORD[ebp+12]
    mov ECX, 2
    push ECX; 保存除数
    mov eax, EBX
    cdq
    idiv dword [esp]
    add esp, 4; 清理除数
    mov EBX, eax
    push EBX
; 参数1
    push DWORD[ebp+8]
; 参数0
    call power2
    add esp, 8; cdecl: 清理参数栈
    mov DWORD[ebp-8], EAX
; 设置变量half
    mov EAX, DWORD[ebp-8]
    mov EBX, DWORD[ebp-8]
    imul EAX, EBX
; return值存入EAX
    jmp func_end_power2; 跳转到公共返回点
    end_if_4:
    mov EAX, DWORD[ebp+8]
    mov EBX, EAX
    mov EDX, DWORD[ebp+12]
    mov EAX, 1
    sub EDX, EAX
    push EDX
; 参数1
    push DWORD[ebp+8]
; 参数0
    call power2
    add esp, 8; cdecl: 清理参数栈
    mov ECX, EAX
    mov EAX, EBX
    imul EAX, ECX
; return值存入EAX
    jmp func_end_power2; 跳转到公共返回点
    func_end_power2:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: sum33
sum33:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
    mov EBX, DWORD[ebp+12]
    add EAX, EBX
    mov EBX, DWORD[ebp+16]
    add EAX, EBX
; return值存入EAX
    jmp func_end_sum33; 跳转到公共返回点
    func_end_sum33:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: max33
max33:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
    mov DWORD[ebp-8], EAX
; 设置变量max
    mov EAX, DWORD[ebp+12]
; left operand
    push EAX; 保护左操作数

    mov ECX, DWORD[ebp-8]
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jle end_if_5
    if_5:
    mov EAX, DWORD[ebp+12]
    mov DWORD[ebp-8], EAX
; 设置变量max
    end_if_5:
    mov EAX, DWORD[ebp+16]
; left operand
    push EAX; 保护左操作数

    mov ECX, DWORD[ebp-8]
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jle end_if_6
    if_6:
    mov EAX, DWORD[ebp+16]
    mov DWORD[ebp-8], EAX
; 设置变量max
    end_if_6:
    mov EAX, DWORD[ebp-8]
; return值存入EAX
    jmp func_end_max33; 跳转到公共返回点
    func_end_max33:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: stringLength1
stringLength1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD [ebp+8+4]
; return值存入EAX
    jmp func_end_stringLength1; 跳转到公共返回点
    func_end_stringLength1:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: repeatString2
repeatString2:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 24; 分配栈空间(24字节)


    mov [ebp-16], 0
; 设置变量result


    mov DWORD[ebp-20], 0
; 设置变量i


    for_1: ; for循环开始
    mov EAX, DWORD[ebp-20]
; left operand
    mov ECX, DWORD[ebp+20]
; right operand
    cmp EAX, ECX
    jge for_1_end


    mov EAX, [ebp+8]
    add [ebp-16], EAX
; 设置变量result


    mov EAX, 1
    add DWORD[ebp-20], EAX
; 设置变量i
    jmp for_1; for循环
    for_1_end: ; for循环结束
    mov EAX, [ebp-16]
; return值存入EAX
    jmp func_end_repeatString2; 跳转到公共返回点
    func_end_repeatString2:
    add esp, 24; 清理局部变量栈空间(24字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: bitwiseOps2
bitwiseOps2:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 32; 分配栈空间(32字节)


    mov EAX, DWORD[ebp+8]
    mov DWORD[ebp-8], EAX
    mov EAX, DWORD[ebp+12]
    and DWORD[ebp-8], EAX
; 设置变量andVal
    mov EAX, DWORD[ebp+8]
    mov DWORD[ebp-12], EAX
    mov EAX, DWORD[ebp+12]
    or DWORD[ebp-12], EAX
; 设置变量orVal
    mov EAX, DWORD[ebp+8]
    mov DWORD[ebp-16], EAX
    mov EAX, DWORD[ebp+12]
    xor DWORD[ebp-16], EAX
; 设置变量xorVal
    mov EAX, DWORD[ebp+8]
    mov DWORD[ebp-20], EAX
    not DWORD[ebp-20]
; 设置变量notVal
    mov EAX, DWORD[ebp+8]
    mov DWORD[ebp-24], EAX
    mov EAX, 2
    push EAX; 暂存移位计数
    mov cl, byte [esp]
    shl DWORD[ebp-24], cl
    add esp, 4; 清理移位计数
; 设置变量shiftL
    mov EAX, DWORD[ebp+8]
    mov DWORD[ebp-28], EAX
    mov EAX, 2
    push EAX; 暂存移位计数
    mov cl, byte [esp]
    sar DWORD[ebp-28], cl
    add esp, 4; 清理移位计数
; 设置变量shiftR
    mov EAX, DWORD[ebp-8]
    mov EBX, DWORD[ebp-12]
    add EAX, EBX
    mov EBX, DWORD[ebp-16]
    add EAX, EBX
    mov EBX, DWORD[ebp-20]
    add EAX, EBX
    mov EBX, DWORD[ebp-24]
    add EAX, EBX
    mov EBX, DWORD[ebp-28]
    add EAX, EBX
; return值存入EAX
    jmp func_end_bitwiseOps2; 跳转到公共返回点
    func_end_bitwiseOps2:
    add esp, 32; 清理局部变量栈空间(32字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: complexExpression3
complexExpression3:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
    mov EBX, DWORD[ebp+12]
    add EAX, EBX
    mov EBX, DWORD[ebp+16]
    mov ECX, DWORD[ebp+8]
    sub EBX, ECX
    imul EAX, EBX
    mov EBX, DWORD[ebp+12]
    mov ECX, 1
    add EBX, ECX
    push EBX; 保存除数
    mov eax, EAX
    cdq
    idiv dword [esp]
    add esp, 4; 清理除数
    mov EAX, eax
    mov EBX, DWORD[ebp+16]
    mov ECX, 2
    add EBX, ECX
    push EBX; 保存除数
    mov eax, EAX
    cdq
    idiv dword [esp]
    add esp, 4; 清理除数
    mov EAX, edx
    mov EBX, DWORD[ebp+8]
    mov ECX, DWORD[ebp+12]
    and EBX, ECX
    mov ECX, DWORD[ebp+12]
    mov EDX, DWORD[ebp+16]
    or ECX, EDX
    xor EBX, ECX
    or EAX, EBX
; return值存入EAX
    jmp func_end_complexExpression3; 跳转到公共返回点
    func_end_complexExpression3:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: multiCondition3
multiCondition3:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, DWORD[ebp+12]
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jle end_if_7
    mov EAX, DWORD[ebp+12]
; left operand
    push EAX; 保护左操作数

    mov ECX, DWORD[ebp+16]
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jle end_if_7
    if_7:
    mov EAX, 1
; return值存入EAX
    jmp func_end_multiCondition3; 跳转到公共返回点
    end_if_7:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, DWORD[ebp+12]
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jge end_if_8
    mov EAX, DWORD[ebp+12]
; left operand
    push EAX; 保护左操作数

    mov ECX, DWORD[ebp+16]
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jge end_if_8
    if_8:
    mov EAX, 2
; return值存入EAX
    jmp func_end_multiCondition3; 跳转到公共返回点
    end_if_8:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, DWORD[ebp+12]
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_9
    mov EAX, DWORD[ebp+12]
; left operand
    push EAX; 保护左操作数

    mov ECX, DWORD[ebp+16]
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_9
    if_9:
    mov EAX, 3
; return值存入EAX
    jmp func_end_multiCondition3; 跳转到公共返回点
    end_if_9:
    mov EAX, 4
; return值存入EAX
    jmp func_end_multiCondition3; 跳转到公共返回点
    func_end_multiCondition3:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: nestedLoops1
nestedLoops1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 24; 分配栈空间(24字节)


    mov DWORD[ebp-8], 0
; 设置变量sum


    mov DWORD[ebp-12], 0
; 设置变量i


    for_2: ; for循环开始
    mov EAX, DWORD[ebp-12]
; left operand
    mov ECX, DWORD[ebp+8]
; right operand
    cmp EAX, ECX
    jge for_2_end




    mov DWORD[ebp-16], 0
; 设置变量j


    for_3: ; for循环开始
    mov EAX, DWORD[ebp-16]
; left operand
    mov ECX, DWORD[ebp-12]
; right operand
    cmp EAX, ECX
    jg for_3_end




    mov DWORD[ebp-20], 0
; 设置变量k


    for_4: ; for循环开始
    mov EAX, DWORD[ebp-20]
; left operand
    mov ECX, DWORD[ebp-16]
; right operand
    cmp EAX, ECX
    jg for_4_end


    mov EAX, DWORD[ebp-12]
    mov EBX, DWORD[ebp-16]
    add EAX, EBX
    mov EBX, DWORD[ebp-20]
    add EAX, EBX
    add DWORD[ebp-8], EAX
; 设置变量sum


    mov EAX, 1
    add DWORD[ebp-20], EAX
; 设置变量k
    jmp for_4; for循环
    for_4_end: ; for循环结束


    mov EAX, 1
    add DWORD[ebp-16], EAX
; 设置变量j
    jmp for_3; for循环
    for_3_end: ; for循环结束


    mov EAX, 1
    add DWORD[ebp-12], EAX
; 设置变量i
    jmp for_2; for循环
    for_2_end: ; for循环结束
    mov EAX, DWORD[ebp-8]
; return值存入EAX
    jmp func_end_nestedLoops1; 跳转到公共返回点
    func_end_nestedLoops1:
    add esp, 24; 清理局部变量栈空间(24字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: listOperations0
listOperations0:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 48; 分配栈空间(48字节)


    push 40
    call std_memory_malloc1
    add esp, 4
    mov EBX, EAX; list buffer
    mov DWORD [EBX+0], 5
    mov DWORD [EBX+4], 2
    mov DWORD [EBX+8], 8
    mov DWORD [EBX+12], 1
    mov DWORD [EBX+16], 9
    mov DWORD [EBX+20], 3
    mov DWORD [EBX+24], 7
    mov DWORD [EBX+28], 4
    mov DWORD [EBX+32], 6
    mov DWORD [ebp-16], EBX
    mov DWORD [ebp-16+4], 9
    mov DWORD [ebp-16+8], 9
; 设置变量list
    mov EAX, [ebp-16]
    mov EAX, DWORD [EAX]
    mov DWORD[ebp-20], EAX
; 设置变量first
    mov EAX, [ebp-16]
    mov EBX, DWORD [ebp-16+4]
    mov ECX, 1
    sub EBX, ECX
    imul EBX, 4
    add EAX, EBX
    mov EAX, DWORD [EAX]
    mov DWORD[ebp-24], EAX
; 设置变量last
    mov EAX, [ebp-16]
    add EAX, 8
    mov EAX, DWORD [ebp-16+8]
    sub EAX, 2
    mov DWORD [ebp-36], EAX
    mov DWORD [ebp-36+4], 3
    mov DWORD [ebp-36+8], EAX
; 设置变量slice1
    mov EAX, 100
    mov EBX, [ebp-16]
    mov DWORD [EBX], EAX
; list index assignment
    mov EAX, 200
    mov EBX, [ebp-16]
    mov ECX, DWORD [ebp-16+4]
    mov EDX, 1
    sub ECX, EDX
    imul ECX, 4
    add EBX, ECX
    mov DWORD [EBX], EAX
; list index assignment
    mov EAX, [ebp-16]
    add EAX, 8
    push DWORD [EAX]
; 参数2
    mov EAX, [ebp-16]
    add EAX, 4
    push DWORD [EAX]
; 参数1
    mov EAX, [ebp-16]
    push DWORD [EAX]
; 参数0
    call sum33
    add esp, 12; cdecl: 清理参数栈
    mov DWORD[ebp-40], EAX
; 设置变量sum
    mov EAX, [ebp-16]
    add EAX, 8
    push DWORD [EAX]
; 参数2
    mov EAX, [ebp-16]
    add EAX, 4
    push DWORD [EAX]
; 参数1
    mov EAX, [ebp-16]
    push DWORD [EAX]
; 参数0
    call max33
    add esp, 12; cdecl: 清理参数栈
    mov DWORD[ebp-44], EAX
; 设置变量max
    mov EAX, DWORD[ebp-20]
    mov EBX, DWORD[ebp-24]
    add EAX, EBX
    mov EBX, EAX
    mov ECX, DWORD [ebp-36+4]
    mov EAX, EBX
    add EAX, ECX
    mov EBX, DWORD[ebp-40]
    add EAX, EBX
    mov EBX, DWORD[ebp-44]
    add EAX, EBX
; return值存入EAX
    jmp func_end_listOperations0; 跳转到公共返回点
    func_end_listOperations0:
    add esp, 48; 清理局部变量栈空间(48字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: stringOperations0
stringOperations0:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 64; 分配栈空间(64字节)


    mov [ebp-16], 0
; 设置变量s1
    mov [ebp-28], 0
; 设置变量s2
    mov EAX, [ebp-16]
    mov [ebp-40], EAX
    mov EAX, 0
    add [ebp-40], EAX
    mov EAX, [ebp-28]
    add [ebp-40], EAX
; 设置变量s3
    push [ebp-16]
; 参数0
    call stringLength1
    add esp, 12; cdecl: 清理参数栈
    mov DWORD[ebp-44], EAX
; 设置变量len1
    push [ebp-40]
; 参数0
    call stringLength1
    add esp, 12; cdecl: 清理参数栈
    mov DWORD[ebp-48], EAX
; 设置变量len3
    push 3
; 参数1
    push [ebp-16]
; 参数0
    call repeatString2
    add esp, 16; cdecl: 清理参数栈
    mov [ebp-60], EAX
; 设置变量repeated
    push [ebp-60]
; 参数0
    call stringLength1
    add esp, 12; cdecl: 清理参数栈
    mov DWORD[ebp-64], EAX
; 设置变量lenRep
    mov EAX, DWORD[ebp-44]
    mov EBX, DWORD[ebp-48]
    add EAX, EBX
    mov EBX, DWORD[ebp-64]
    add EAX, EBX
; return值存入EAX
    jmp func_end_stringOperations0; 跳转到公共返回点
    func_end_stringOperations0:
    add esp, 64; 清理局部变量栈空间(64字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: structOperations0
structOperations0:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 16; 分配栈空间(16字节)


    mov DWORD[ebp-12], 3
; 设置变量v1.x
    mov DWORD[ebp-8], 4
; 设置变量v1.y
    lea eax, [ebp-12]; this pointer
    push eax; push this pointer
    call Vector2D_length0
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-16], EAX
; 设置变量length
    push 2
; 参数0
    lea eax, [ebp-12]; this pointer
    push eax; push this pointer
    call Vector2D_scale1
    add esp, 8; cdecl: 清理参数栈
    mov EAX, DWORD[ebp-16]
    mov EBX, DWORD[ebp-12]
    add EAX, EBX
    mov EBX, DWORD[ebp-8]
    add EAX, EBX
; return值存入EAX
    jmp func_end_structOperations0; 跳转到公共返回点
    func_end_structOperations0:
    add esp, 16; 清理局部变量栈空间(16字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: matrixOperations0
matrixOperations0:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 40; 分配栈空间(40字节)


    mov DWORD[ebp-12], 2
; 设置变量m.rows
    mov DWORD[ebp-8], 3
; 设置变量m.cols
    push 24
    call std_memory_malloc1
    add esp, 4
    mov EBX, EAX; list buffer
    mov DWORD [EBX+0], 1
    mov DWORD [EBX+4], 2
    mov DWORD [EBX+8], 3
    mov DWORD [EBX+12], 4
    mov DWORD [EBX+16], 5
    mov DWORD [EBX+20], 6
    mov DWORD [ebp-24], EBX
    mov DWORD [ebp-24+4], 6
    mov DWORD [ebp-24+8], 6
; 设置变量m.data
    push 0
; 参数1
    push 0
; 参数0
    lea eax, [ebp-24]; this pointer
    push eax; push this pointer
    call Matrix_get2
    add esp, 12; cdecl: 清理参数栈
    mov DWORD[ebp-28], EAX
; 设置变量val1
    push 2
; 参数1
    push 1
; 参数0
    lea eax, [ebp-24]; this pointer
    push eax; push this pointer
    call Matrix_get2
    add esp, 12; cdecl: 清理参数栈
    mov DWORD[ebp-32], EAX
; 设置变量val2
    push 10
; 参数2
    push 1
; 参数1
    push 0
; 参数0
    lea eax, [ebp-24]; this pointer
    push eax; push this pointer
    call Matrix_set3
    add esp, 16; cdecl: 清理参数栈
    push 1
; 参数1
    push 0
; 参数0
    lea eax, [ebp-24]; this pointer
    push eax; push this pointer
    call Matrix_get2
    add esp, 12; cdecl: 清理参数栈
    mov DWORD[ebp-36], EAX
; 设置变量val3
    mov EAX, DWORD[ebp-28]
    mov EBX, DWORD[ebp-32]
    add EAX, EBX
    mov EBX, DWORD[ebp-36]
    add EAX, EBX
; return值存入EAX
    jmp func_end_matrixOperations0; 跳转到公共返回点
    func_end_matrixOperations0:
    add esp, 40; 清理局部变量栈空间(40字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: recursiveTests0
recursiveTests0:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 16; 分配栈空间(16字节)


    push 10
; 参数0
    call fibonacci1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-8], EAX
; 设置变量fib10
    push 5
; 参数0
    call factorial1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-12], EAX
; 设置变量fact5
    push 10
; 参数1
    push 2
; 参数0
    call power2
    add esp, 8; cdecl: 清理参数栈
    mov DWORD[ebp-16], EAX
; 设置变量pow2_10
    mov EAX, DWORD[ebp-8]
    mov EBX, DWORD[ebp-12]
    add EAX, EBX
    mov EBX, DWORD[ebp-16]
    add EAX, EBX
; return值存入EAX
    jmp func_end_recursiveTests0; 跳转到公共返回点
    func_end_recursiveTests0:
    add esp, 16; 清理局部变量栈空间(16字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: bitwiseTests0
bitwiseTests0:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 16; 分配栈空间(16字节)


    mov DWORD[ebp-8], 255
; 设置变量a
    mov DWORD[ebp-12], 15
; 设置变量b
    push DWORD[ebp-12]
; 参数1
    push DWORD[ebp-8]
; 参数0
    call bitwiseOps2
    add esp, 8; cdecl: 清理参数栈
    mov DWORD[ebp-16], EAX
; 设置变量result
    mov EAX, DWORD[ebp-16]
; return值存入EAX
    jmp func_end_bitwiseTests0; 跳转到公共返回点
    func_end_bitwiseTests0:
    add esp, 16; 清理局部变量栈空间(16字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: expressionTests0
expressionTests0:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 32; 分配栈空间(32字节)


    mov DWORD[ebp-8], 10
; 设置变量x
    mov DWORD[ebp-12], 20
; 设置变量y
    mov DWORD[ebp-16], 30
; 设置变量z
    push DWORD[ebp-16]
; 参数2
    push DWORD[ebp-12]
; 参数1
    push DWORD[ebp-8]
; 参数0
    call complexExpression3
    add esp, 12; cdecl: 清理参数栈
    mov DWORD[ebp-20], EAX
; 设置变量result1
    push 15
; 参数2
    push 10
; 参数1
    push 5
; 参数0
    call multiCondition3
    add esp, 12; cdecl: 清理参数栈
    mov DWORD[ebp-24], EAX
; 设置变量result2
    push 5
; 参数0
    call nestedLoops1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-28], EAX
; 设置变量result3
    mov EAX, DWORD[ebp-20]
    mov EBX, DWORD[ebp-24]
    add EAX, EBX
    mov EBX, DWORD[ebp-28]
    add EAX, EBX
; return值存入EAX
    jmp func_end_expressionTests0; 跳转到公共返回点
    func_end_expressionTests0:
    add esp, 32; 清理局部变量栈空间(32字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: main
main:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 40; 分配栈空间(40字节)


    call listOperations0
    mov DWORD[ebp-8], EAX
; 设置变量listResult
    call stringOperations0
    mov DWORD[ebp-12], EAX
; 设置变量stringResult
    call structOperations0
    mov DWORD[ebp-16], EAX
; 设置变量structResult
    call matrixOperations0
    mov DWORD[ebp-20], EAX
; 设置变量matrixResult
    call recursiveTests0
    mov DWORD[ebp-24], EAX
; 设置变量recursiveResult
    call bitwiseTests0
    mov DWORD[ebp-28], EAX
; 设置变量bitwiseResult
    call expressionTests0
    mov DWORD[ebp-32], EAX
; 设置变量expressionResult
    mov EAX, DWORD[ebp-8]
    mov DWORD[ebp-36], EAX
    mov EAX, DWORD[ebp-12]
    add DWORD[ebp-36], EAX
    mov EAX, DWORD[ebp-16]
    add DWORD[ebp-36], EAX
    mov EAX, DWORD[ebp-20]
    add DWORD[ebp-36], EAX
    mov EAX, DWORD[ebp-24]
    add DWORD[ebp-36], EAX
    mov EAX, DWORD[ebp-28]
    add DWORD[ebp-36], EAX
    mov EAX, DWORD[ebp-32]
    add DWORD[ebp-36], EAX
; 设置变量total
    mov EAX, DWORD[ebp-36]
; return值存入EAX
    jmp func_end_main; 跳转到公共返回点
    func_end_main:
    add esp, 40; 清理局部变量栈空间(40字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_syscall_brk1
std_syscall_brk1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, 45
    mov EBX, DWORD[ebp+8]
    int 0x80
    mov edx, 0
    func_end_std_syscall_brk1:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_load81
std_memory_load81:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
    movzx EAX, byte[EAX]
    func_end_std_memory_load81:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_load321
std_memory_load321:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
    mov EAX, [EAX]
    func_end_std_memory_load321:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_store82
std_memory_store82:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
    mov ECX, DWORD[ebp+12]
    mov [EAX], CL
    func_end_std_memory_store82:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_store322
std_memory_store322:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
    mov ECX, DWORD[ebp+12]
    mov [EAX], ECX
    func_end_std_memory_store322:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_slot_of1
std_memory_slot_of1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 32
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_10
    if_10:
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_slot_of1; 跳转到公共返回点
    end_if_10:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 48
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_11
    if_11:
    mov EAX, 1
; return值存入EAX
    jmp func_end_std_memory_slot_of1; 跳转到公共返回点
    end_if_11:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 64
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_12
    if_12:
    mov EAX, 2
; return值存入EAX
    jmp func_end_std_memory_slot_of1; 跳转到公共返回点
    end_if_12:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 96
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_13
    if_13:
    mov EAX, 3
; return值存入EAX
    jmp func_end_std_memory_slot_of1; 跳转到公共返回点
    end_if_13:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 128
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_14
    if_14:
    mov EAX, 4
; return值存入EAX
    jmp func_end_std_memory_slot_of1; 跳转到公共返回点
    end_if_14:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 192
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_15
    if_15:
    mov EAX, 5
; return值存入EAX
    jmp func_end_std_memory_slot_of1; 跳转到公共返回点
    end_if_15:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 256
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_16
    if_16:
    mov EAX, 6
; return值存入EAX
    jmp func_end_std_memory_slot_of1; 跳转到公共返回点
    end_if_16:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 384
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_17
    if_17:
    mov EAX, 7
; return值存入EAX
    jmp func_end_std_memory_slot_of1; 跳转到公共返回点
    end_if_17:
    mov EAX, 8
; return值存入EAX
    jmp func_end_std_memory_slot_of1; 跳转到公共返回点
    func_end_std_memory_slot_of1:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_blk_size_of1
std_memory_blk_size_of1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 0
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_18
    if_18:
    mov EAX, 32
; return值存入EAX
    jmp func_end_std_memory_blk_size_of1; 跳转到公共返回点
    end_if_18:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 1
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_19
    if_19:
    mov EAX, 48
; return值存入EAX
    jmp func_end_std_memory_blk_size_of1; 跳转到公共返回点
    end_if_19:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 2
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_20
    if_20:
    mov EAX, 64
; return值存入EAX
    jmp func_end_std_memory_blk_size_of1; 跳转到公共返回点
    end_if_20:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 3
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_21
    if_21:
    mov EAX, 96
; return值存入EAX
    jmp func_end_std_memory_blk_size_of1; 跳转到公共返回点
    end_if_21:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 4
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_22
    if_22:
    mov EAX, 128
; return值存入EAX
    jmp func_end_std_memory_blk_size_of1; 跳转到公共返回点
    end_if_22:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 5
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_23
    if_23:
    mov EAX, 192
; return值存入EAX
    jmp func_end_std_memory_blk_size_of1; 跳转到公共返回点
    end_if_23:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 6
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_24
    if_24:
    mov EAX, 256
; return值存入EAX
    jmp func_end_std_memory_blk_size_of1; 跳转到公共返回点
    end_if_24:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 7
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_25
    if_25:
    mov EAX, 384
; return值存入EAX
    jmp func_end_std_memory_blk_size_of1; 跳转到公共返回点
    end_if_25:
    mov EAX, 512
; return值存入EAX
    jmp func_end_std_memory_blk_size_of1; 跳转到公共返回点
    func_end_std_memory_blk_size_of1:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_head_of1
std_memory_head_of1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 0
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_26
    if_26:
    mov EAX, [__global_g_h0]
; return值存入EAX
    jmp func_end_std_memory_head_of1; 跳转到公共返回点
    end_if_26:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 1
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_27
    if_27:
    mov EAX, [__global_g_h1]
; return值存入EAX
    jmp func_end_std_memory_head_of1; 跳转到公共返回点
    end_if_27:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 2
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_28
    if_28:
    mov EAX, [__global_g_h2]
; return值存入EAX
    jmp func_end_std_memory_head_of1; 跳转到公共返回点
    end_if_28:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 3
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_29
    if_29:
    mov EAX, [__global_g_h3]
; return值存入EAX
    jmp func_end_std_memory_head_of1; 跳转到公共返回点
    end_if_29:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 4
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_30
    if_30:
    mov EAX, [__global_g_h4]
; return值存入EAX
    jmp func_end_std_memory_head_of1; 跳转到公共返回点
    end_if_30:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 5
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_31
    if_31:
    mov EAX, [__global_g_h5]
; return值存入EAX
    jmp func_end_std_memory_head_of1; 跳转到公共返回点
    end_if_31:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 6
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_32
    if_32:
    mov EAX, [__global_g_h6]
; return值存入EAX
    jmp func_end_std_memory_head_of1; 跳转到公共返回点
    end_if_32:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 7
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_33
    if_33:
    mov EAX, [__global_g_h7]
; return值存入EAX
    jmp func_end_std_memory_head_of1; 跳转到公共返回点
    end_if_33:
    mov EAX, [__global_g_h8]
; return值存入EAX
    jmp func_end_std_memory_head_of1; 跳转到公共返回点
    func_end_std_memory_head_of1:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_set_head2
std_memory_set_head2:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)


    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 0
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_34
    if_34:
    mov EAX, DWORD[ebp+12]
    mov [__global_g_h0], EAX
; 设置变量g_h0
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_set_head2; 跳转到公共返回点
    end_if_34:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 1
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_35
    if_35:
    mov EAX, DWORD[ebp+12]
    mov [__global_g_h1], EAX
; 设置变量g_h1
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_set_head2; 跳转到公共返回点
    end_if_35:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 2
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_36
    if_36:
    mov EAX, DWORD[ebp+12]
    mov [__global_g_h2], EAX
; 设置变量g_h2
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_set_head2; 跳转到公共返回点
    end_if_36:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 3
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_37
    if_37:
    mov EAX, DWORD[ebp+12]
    mov [__global_g_h3], EAX
; 设置变量g_h3
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_set_head2; 跳转到公共返回点
    end_if_37:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 4
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_38
    if_38:
    mov EAX, DWORD[ebp+12]
    mov [__global_g_h4], EAX
; 设置变量g_h4
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_set_head2; 跳转到公共返回点
    end_if_38:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 5
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_39
    if_39:
    mov EAX, DWORD[ebp+12]
    mov [__global_g_h5], EAX
; 设置变量g_h5
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_set_head2; 跳转到公共返回点
    end_if_39:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 6
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_40
    if_40:
    mov EAX, DWORD[ebp+12]
    mov [__global_g_h6], EAX
; 设置变量g_h6
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_set_head2; 跳转到公共返回点
    end_if_40:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 7
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_41
    if_41:
    mov EAX, DWORD[ebp+12]
    mov [__global_g_h7], EAX
; 设置变量g_h7
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_set_head2; 跳转到公共返回点
    end_if_41:
    mov EAX, DWORD[ebp+12]
    mov [__global_g_h8], EAX
; 设置变量g_h8
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_set_head2; 跳转到公共返回点
    func_end_std_memory_set_head2:
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_refill2
std_memory_refill2:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 32; 分配栈空间(32字节)


    push 0
; 参数0
    call std_syscall_brk1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-8], EAX
; 设置变量chunk
    mov EAX, DWORD[ebp-8]
    mov EBX, 4096
    add EAX, EBX
    push EAX
; 参数0
    call std_syscall_brk1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-12], EAX
; 设置变量nb
    mov EAX, DWORD[ebp-12]
; left operand
    push EAX; 保护左操作数

    mov ECX, DWORD[ebp-8]
    mov EBX, 4096
    add ECX, EBX
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jge end_if_42
    if_42:
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_refill2; 跳转到公共返回点
    end_if_42:
    push DWORD[ebp+12]
; 参数1
    mov EAX, DWORD[ebp-8]
    mov EBX, 4
    add EAX, EBX
    push EAX
; 参数0
    call std_memory_store322
    add esp, 8; cdecl: 清理参数栈
    mov EAX, DWORD[ebp-8]
    mov DWORD[ebp-16], EAX
; 设置变量head
    mov DWORD[ebp-20], 0
; 设置变量prev
    mov EAX, DWORD[ebp-8]
    mov DWORD[ebp-24], EAX
; 设置变量p
    mov EAX, DWORD[ebp-8]
    mov DWORD[ebp-28], EAX
    mov EBX, 4096
    add DWORD[ebp-28], EBX
; 设置变量end




    for_5: ; for循环开始
    mov EAX, DWORD[ebp-24]
    mov EBX, DWORD[ebp+12]
    add EAX, EBX
; left operand
    mov ECX, DWORD[ebp-28]
; right operand
    cmp EAX, ECX
    jg for_5_end


    push 0
; 参数1
    push DWORD[ebp-24]
; 参数0
    call std_memory_store322
    add esp, 8; cdecl: 清理参数栈
    mov EAX, DWORD[ebp-20]
; left operand
    push EAX; 保护左操作数

    mov ECX, 0
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    je end_if_43
    if_43:
    push DWORD[ebp-24]
; 参数1
    push DWORD[ebp-20]
; 参数0
    call std_memory_store322
    add esp, 8; cdecl: 清理参数栈
    end_if_43:
    push DWORD[ebp+12]
; 参数1
    mov EBX, DWORD[ebp-24]
    mov EDX, 4
    add EBX, EDX
    push EBX
; 参数0
    call std_memory_store322
    add esp, 8; cdecl: 清理参数栈
    mov EBX, DWORD[ebp-24]
    mov DWORD[ebp-20], EBX
; 设置变量prev
    mov EBX, DWORD[ebp+12]
    add DWORD[ebp-24], EBX
; 设置变量p


    jmp for_5; for循环
    for_5_end: ; for循环结束
    push DWORD[ebp-16]
; 参数1
    push DWORD[ebp+8]
; 参数0
    call std_memory_set_head2
    add esp, 8; cdecl: 清理参数栈
    mov EAX, DWORD[ebp-8]
; return值存入EAX
    jmp func_end_std_memory_refill2; 跳转到公共返回点
    func_end_std_memory_refill2:
    add esp, 32; 清理局部变量栈空间(32字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_malloc1
std_memory_malloc1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 32; 分配栈空间(32字节)


    mov EAX, DWORD[ebp+8]
    mov DWORD[ebp-8], EAX
    mov EAX, 8
    add DWORD[ebp-8], EAX
; 设置变量req
    mov EAX, DWORD[ebp-8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 512
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jle end_if_44
    if_44:
    push 0
; 参数0
    call std_syscall_brk1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-12], EAX
; 设置变量old
    mov EAX, DWORD[ebp-12]
    mov EBX, DWORD[ebp-8]
    add EAX, EBX
    push EAX
; 参数0
    call std_syscall_brk1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-16], EAX
; 设置变量nb
    mov EAX, DWORD[ebp-16]
; left operand
    push EAX; 保护左操作数

    mov ECX, DWORD[ebp-12]
    mov EAX, DWORD[ebp-8]
    add ECX, EAX
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jge end_if_45
    if_45:
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_malloc1; 跳转到公共返回点
    end_if_45:
    push 0
; 参数1
    push DWORD[ebp-12]
; 参数0
    call std_memory_store322
    add esp, 8; cdecl: 清理参数栈
    push DWORD[ebp-8]
; 参数1
    mov EAX, DWORD[ebp-12]
    mov EBX, 4
    add EAX, EBX
    push EAX
; 参数0
    call std_memory_store322
    add esp, 8; cdecl: 清理参数栈
    mov EAX, DWORD[ebp-12]
    mov EBX, 8
    add EAX, EBX
; return值存入EAX
    jmp func_end_std_memory_malloc1; 跳转到公共返回点
    end_if_44:
    push DWORD[ebp-8]
; 参数0
    call std_memory_slot_of1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-20], EAX
; 设置变量idx
    push DWORD[ebp-20]
; 参数0
    call std_memory_blk_size_of1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-24], EAX
; 设置变量blk_size
    push DWORD[ebp-20]
; 参数0
    call std_memory_head_of1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-28], EAX
; 设置变量head
    mov EAX, DWORD[ebp-28]
; left operand
    push EAX; 保护左操作数

    mov ECX, 0
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_46
    if_46:
    push DWORD[ebp-24]
; 参数1
    push DWORD[ebp-20]
; 参数0
    call std_memory_refill2
    add esp, 8; cdecl: 清理参数栈
    mov DWORD[ebp-28], EAX
; 设置变量head
    mov EAX, DWORD[ebp-28]
; left operand
    push EAX; 保护左操作数

    mov ECX, 0
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_47
    if_47:
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_malloc1; 跳转到公共返回点
    end_if_47:
    end_if_46:
    push DWORD[ebp-28]
; 参数0
    call std_memory_load321
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-32], EAX
; 设置变量next
    push DWORD[ebp-32]
; 参数1
    push DWORD[ebp-20]
; 参数0
    call std_memory_set_head2
    add esp, 8; cdecl: 清理参数栈
    push DWORD[ebp-24]
; 参数1
    mov EAX, DWORD[ebp-28]
    mov EBX, 4
    add EAX, EBX
    push EAX
; 参数0
    call std_memory_store322
    add esp, 8; cdecl: 清理参数栈
    mov EAX, DWORD[ebp-28]
    mov EBX, 8
    add EAX, EBX
; return值存入EAX
    jmp func_end_std_memory_malloc1; 跳转到公共返回点
    func_end_std_memory_malloc1:
    add esp, 32; 清理局部变量栈空间(32字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_free1
std_memory_free1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 24; 分配栈空间(24字节)


    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 0
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_48
    if_48:
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_free1; 跳转到公共返回点
    end_if_48:
    mov EAX, DWORD[ebp+8]
    mov DWORD[ebp-8], EAX
    mov EAX, 8
    sub DWORD[ebp-8], EAX
; 设置变量blk
    mov EAX, DWORD[ebp-8]
    mov EBX, 4
    add EAX, EBX
    push EAX
; 参数0
    call std_memory_load321
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-12], EAX
; 设置变量size
    mov EAX, DWORD[ebp-12]
; left operand
    push EAX; 保护左操作数

    mov ECX, 512
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jle end_if_49
    if_49:
    push 0
; 参数0
    call std_syscall_brk1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-16], EAX
; 设置变量cur
    mov EAX, DWORD[ebp-8]
    mov EBX, DWORD[ebp-12]
    add EAX, EBX
; left operand
    push EAX; 保护左操作数

    mov ECX, DWORD[ebp-16]
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_50
    if_50:
    push DWORD[ebp-8]
; 参数0
    call std_syscall_brk1
    add esp, 4; cdecl: 清理参数栈
    end_if_50:
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_free1; 跳转到公共返回点
    end_if_49:
    push DWORD[ebp-12]
; 参数0
    call std_memory_slot_of1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-20], EAX
; 设置变量idx
    push DWORD[ebp-20]
; 参数0
    call std_memory_head_of1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-24], EAX
; 设置变量head
    push DWORD[ebp-24]
; 参数1
    push DWORD[ebp-8]
; 参数0
    call std_memory_store322
    add esp, 8; cdecl: 清理参数栈
    push DWORD[ebp-8]
; 参数1
    push DWORD[ebp-20]
; 参数0
    call std_memory_set_head2
    add esp, 8; cdecl: 清理参数栈
    func_end_std_memory_free1:
    add esp, 24; 清理局部变量栈空间(24字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; 程序入口点 (ELF入口)
_start:
    call main
    mov ebx, eax
    mov eax, 1
    int 0x80

