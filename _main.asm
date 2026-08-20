section .data
    __global_std_memory_gH0 dd 0
    __global_std_memory_gH1 dd 0
    __global_std_memory_gH2 dd 0
    __global_std_memory_gH3 dd 0
    __global_std_memory_gH4 dd 0
    __global_std_memory_gH5 dd 0
    __global_std_memory_gH6 dd 0
    __global_std_memory_gH7 dd 0
    __global_std_memory_gH8 dd 0
    __global_std_memory_ptrSize dd 4
section .text
global _start

; ==============================
; Function: sumBig2
sumBig2:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 24; 分配栈空间(24字节)


    mov EAX, DWORD[ebp+8]
    mov EBX, DWORD[ebp+12]
    add EAX, EBX
    mov EBX, DWORD[ebp+16]
    add EAX, EBX
    mov EBX, DWORD[ebp+20]
    add EAX, EBX
    mov EBX, DWORD[ebp+24]
    add EAX, EBX
    mov EBX, DWORD[ebp+28]
    add EAX, EBX
; return值存入EAX
    jmp func_end_sumBig2; 跳转到公共返回点
    func_end_sumBig2:
    add esp, 24; 清理局部变量栈空间(24字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: makeBig0
makeBig0:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 48; 分配栈空间(48字节)
    mov EAX, DWORD [ebp+8]; 保存返回槽地址
    mov DWORD [ebp-28], EAX


    mov DWORD[ebp-24], 1
; 设置变量r.a
    mov DWORD[ebp-20], 2
; 设置变量r.b
    mov DWORD[ebp-16], 3
; 设置变量r.c
    mov DWORD[ebp-12], 4
; 设置变量r.d
    mov DWORD[ebp-8], 5
; 设置变量r.e
    mov EAX, DWORD [ebp-24+0]
    mov DWORD [ebp-48+0], EAX
    mov EAX, DWORD [ebp-24+4]
    mov DWORD [ebp-48+4], EAX
    mov EAX, DWORD [ebp-24+8]
    mov DWORD [ebp-48+8], EAX
    mov EAX, DWORD [ebp-24+12]
    mov DWORD [ebp-48+12], EAX
    mov EAX, DWORD [ebp-24+16]
    mov DWORD [ebp-48+16], EAX
; return值存入返回槽
    mov EDI, DWORD [ebp-28]; 恢复返回槽地址
    mov EAX, DWORD [ebp-48]
    mov DWORD [EDI], EAX
    mov EAX, DWORD [ebp-44]
    mov DWORD [EDI+4], EAX
    mov EAX, DWORD [ebp-40]
    mov DWORD [EDI+8], EAX
    mov EAX, DWORD [ebp-36]
    mov DWORD [EDI+12], EAX
    mov EAX, DWORD [ebp-32]
    mov DWORD [EDI+16], EAX
    jmp func_end_makeBig0; 跳转到公共返回点
    func_end_makeBig0:
    add esp, 48; 清理局部变量栈空间(48字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: mkNode1
mkNode1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 24; 分配栈空间(24字节)


    push 8
; 参数0
    call std_memory_malloc1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-8], EAX
; 设置变量p
    mov EBX, DWORD [EBP-8]
    mov EAX, DWORD[ebp+8]
    mov DWORD[EBX], EAX
; 设置变量p.x
    mov EBX, DWORD [EBP-8]
    mov EAX, DWORD[ebp+8]
    mov DWORD[EBX+4], EAX
    mov EAX, 1
    add DWORD[EBX+4], EAX
; 设置变量p.y
    mov EAX, DWORD[ebp-8]
; return值存入EAX
    jmp func_end_mkNode1; 跳转到公共返回点
    func_end_mkNode1:
    add esp, 24; 清理局部变量栈空间(24字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: bump1
bump1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 24; 分配栈空间(24字节)


    mov EBX, DWORD [EBP+8]
    mov ECX, DWORD [EBP+8]
    mov EAX, DWORD [ECX]
    mov DWORD[EBX], EAX
    mov EAX, 100
    add DWORD[EBX], EAX
; 设置变量p.x
    func_end_bump1:
    add esp, 24; 清理局部变量栈空间(24字节)
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
    sub esp, 128; 分配栈空间(128字节)


    mov DWORD[ebp-8], 0
; 设置变量ok
    mov DWORD[ebp-28], 1
; 设置变量s.a
    mov DWORD[ebp-24], 2
; 设置变量s.b
    mov DWORD[ebp-20], 3
; 设置变量s.c
    mov DWORD[ebp-16], 4
; 设置变量s.d
    mov DWORD[ebp-12], 5
; 设置变量s.e
    mov EAX, DWORD [ebp-28+0]
    mov DWORD [ebp-48+0], EAX
    mov EAX, DWORD [ebp-28+4]
    mov DWORD [ebp-48+4], EAX
    mov EAX, DWORD [ebp-28+8]
    mov DWORD [ebp-48+8], EAX
    mov EAX, DWORD [ebp-28+12]
    mov DWORD [ebp-48+12], EAX
    mov EAX, DWORD [ebp-28+16]
    mov DWORD [ebp-48+16], EAX
; 设置变量t
    mov DWORD[ebp-32], 50
; 设置变量t.e
    mov EAX, DWORD[ebp-28]
; left operand
    push EAX; 保护左操作数

    mov ECX, 1
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_1
    mov EAX, DWORD[ebp-32]
; left operand
    push EAX; 保护左操作数

    mov ECX, 50
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_1
    mov EAX, DWORD[ebp-48]
; left operand
    push EAX; 保护左操作数

    mov ECX, 1
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_1
    if_1:
    mov EAX, 1
    add DWORD[ebp-8], EAX
; 设置变量ok
    end_if_1:
    push 10
; 参数1
    push DWORD [ebp-28+16]
    push DWORD [ebp-28+12]
    push DWORD [ebp-28+8]
    push DWORD [ebp-28+4]
    push DWORD [ebp-28]
; 参数0
    call sumBig2
    add esp, 24; cdecl: 清理参数栈
    mov DWORD[ebp-52], EAX
; 设置变量r1
    mov EAX, DWORD[ebp-52]
; left operand
    push EAX; 保护左操作数

    mov ECX, 25
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_2
    if_2:
    mov EAX, 1
    add DWORD[ebp-8], EAX
; 设置变量ok
    end_if_2:
    lea EAX, [ebp-128]; 大值返回槽地址
    push EAX; 大值返回槽地址
    call makeBig0
    add esp, 4; 清理返回槽地址
    mov EAX, DWORD [EBP-128+0]
    mov DWORD [ebp-72+0], EAX
    mov EAX, DWORD [EBP-128+4]
    mov DWORD [ebp-72+4], EAX
    mov EAX, DWORD [EBP-128+8]
    mov DWORD [ebp-72+8], EAX
    mov EAX, DWORD [EBP-128+12]
    mov DWORD [ebp-72+12], EAX
    mov EAX, DWORD [EBP-128+16]
    mov DWORD [ebp-72+16], EAX
; 设置变量u
    mov EAX, DWORD[ebp-72]
    mov EBX, DWORD[ebp-68]
    add EAX, EBX
    mov EBX, DWORD[ebp-64]
    add EAX, EBX
    mov EBX, DWORD[ebp-60]
    add EAX, EBX
    mov EBX, DWORD[ebp-56]
    add EAX, EBX
; left operand
    push EAX; 保护左操作数

    mov ECX, 15
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_3
    if_3:
    mov EBX, 1
    add DWORD[ebp-8], EBX
; 设置变量ok
    end_if_3:
    push 7
; 参数0
    call mkNode1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-76], EAX
; 设置变量np
    mov EBX, DWORD [EBP-76]
    mov EAX, DWORD [EBX]
; left operand
    push EAX; 保护左操作数

    mov ECX, 7
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_4
    mov EBX, DWORD [EBP-76]
    mov EAX, DWORD [EBX+4]
; left operand
    push EAX; 保护左操作数

    mov ECX, 8
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_4
    if_4:
    mov EBX, 1
    add DWORD[ebp-8], EBX
; 设置变量ok
    end_if_4:
    push DWORD[ebp-76]
; 参数0
    call bump1
    add esp, 4; cdecl: 清理参数栈
    mov EBX, DWORD [EBP-76]
    mov EAX, DWORD [EBX]
; left operand
    push EAX; 保护左操作数

    mov ECX, 107
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_5
    if_5:
    mov EBX, 1
    add DWORD[ebp-8], EBX
; 设置变量ok
    end_if_5:
    mov DWORD[ebp-88], 3
; 设置变量n.p.x
    mov DWORD[ebp-84], 4
; 设置变量n.p.y
    mov DWORD[ebp-80], 5
; 设置变量n.z
    mov EAX, DWORD [ebp-88+0]
    mov DWORD [ebp-100+0], EAX
    mov EAX, DWORD [ebp-88+4]
    mov DWORD [ebp-100+4], EAX
    mov EAX, DWORD [ebp-88+8]
    mov DWORD [ebp-100+8], EAX
; 设置变量m
    mov DWORD[ebp-100], 30
; 设置变量m.p.x
    mov EAX, DWORD[ebp-88]
; left operand
    push EAX; 保护左操作数

    mov ECX, 3
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_6
    mov EAX, DWORD[ebp-100]
; left operand
    push EAX; 保护左操作数

    mov ECX, 30
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_6
    mov EAX, DWORD[ebp-96]
; left operand
    push EAX; 保护左操作数

    mov ECX, 4
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_6
    mov EAX, DWORD[ebp-92]
; left operand
    push EAX; 保护左操作数

    mov ECX, 5
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_6
    if_6:
    mov EBX, 1
    add DWORD[ebp-8], EBX
; 设置变量ok
    end_if_6:
    push 8
; 参数0
    call std_memory_malloc1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-104], EAX
; 设置变量head
    mov EBX, DWORD [EBP-104]
    mov DWORD[EBX], 1
; 设置变量head.v
    mov EBX, DWORD [EBP-104]
    push 8
; 参数0
    call std_memory_malloc1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[EBX+4], EAX
; 设置变量head.next
    mov EBX, DWORD [EBP-104]
    mov EBX, DWORD [EBX+4]
    mov DWORD[EBX], 2
; 设置变量head.next.v
    mov EBX, DWORD [EBP-104]
    mov EBX, DWORD [EBX+4]
    push 8
; 参数0
    call std_memory_malloc1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[EBX+4], EAX
; 设置变量head.next.next
    mov EBX, DWORD [EBP-104]
    mov EBX, DWORD [EBX+4]
    mov EBX, DWORD [EBX+4]
    mov DWORD[EBX], 3
; 设置变量head.next.next.v
    mov EBX, DWORD [EBP-104]
    mov EAX, DWORD [EBX]
    mov DWORD[ebp-108], EAX
    mov ECX, DWORD [EBP-104]
    mov ECX, DWORD [ECX+4]
    mov EBX, DWORD [ECX]
    add DWORD[ebp-108], EBX
    mov ECX, DWORD [EBP-104]
    mov ECX, DWORD [ECX+4]
    mov ECX, DWORD [ECX+4]
    mov EBX, DWORD [ECX]
    add DWORD[ebp-108], EBX
; 设置变量sum
    mov EAX, DWORD[ebp-108]
; left operand
    push EAX; 保护左操作数

    mov ECX, 6
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_7
    if_7:
    mov EBX, 1
    add DWORD[ebp-8], EBX
; 设置变量ok
    end_if_7:
    mov EAX, DWORD[ebp-8]
; return值存入EAX
    jmp func_end_main; 跳转到公共返回点
    func_end_main:
    add esp, 128; 清理局部变量栈空间(128字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_syscall_syscall4
std_syscall_syscall4:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 24; 分配栈空间(24字节)


    mov EAX, DWORD[ebp+8]
    mov EBX, DWORD[ebp+12]
    mov ECX, DWORD[ebp+16]
    mov EDX, DWORD[ebp+20]
    int 0x80
    mov edx, 0
    func_end_std_syscall_syscall4:
    add esp, 24; 清理局部变量栈空间(24字节)
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
    sub esp, 24; 分配栈空间(24字节)


    push 0
; 参数3
    push 0
; 参数2
    push DWORD[ebp+8]
; 参数1
    push 45
; 参数0
    call std_syscall_syscall4
    add esp, 16; cdecl: 清理参数栈
; return值存入EAX
    jmp func_end_std_syscall_brk1; 跳转到公共返回点
    func_end_std_syscall_brk1:
    add esp, 24; 清理局部变量栈空间(24字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_slotOf1
std_memory_slotOf1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 24; 分配栈空间(24字节)


    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 32
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_8
    if_8:
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_slotOf1; 跳转到公共返回点
    end_if_8:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 48
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_9
    if_9:
    mov EAX, 1
; return值存入EAX
    jmp func_end_std_memory_slotOf1; 跳转到公共返回点
    end_if_9:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 64
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_10
    if_10:
    mov EAX, 2
; return值存入EAX
    jmp func_end_std_memory_slotOf1; 跳转到公共返回点
    end_if_10:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 96
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_11
    if_11:
    mov EAX, 3
; return值存入EAX
    jmp func_end_std_memory_slotOf1; 跳转到公共返回点
    end_if_11:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 128
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_12
    if_12:
    mov EAX, 4
; return值存入EAX
    jmp func_end_std_memory_slotOf1; 跳转到公共返回点
    end_if_12:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 192
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_13
    if_13:
    mov EAX, 5
; return值存入EAX
    jmp func_end_std_memory_slotOf1; 跳转到公共返回点
    end_if_13:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 256
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_14
    if_14:
    mov EAX, 6
; return值存入EAX
    jmp func_end_std_memory_slotOf1; 跳转到公共返回点
    end_if_14:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 384
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jg end_if_15
    if_15:
    mov EAX, 7
; return值存入EAX
    jmp func_end_std_memory_slotOf1; 跳转到公共返回点
    end_if_15:
    mov EAX, 8
; return值存入EAX
    jmp func_end_std_memory_slotOf1; 跳转到公共返回点
    func_end_std_memory_slotOf1:
    add esp, 24; 清理局部变量栈空间(24字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_blkSizeOf1
std_memory_blkSizeOf1:
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
    jne end_if_16
    if_16:
    mov EAX, 32
; return值存入EAX
    jmp func_end_std_memory_blkSizeOf1; 跳转到公共返回点
    end_if_16:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 1
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_17
    if_17:
    mov EAX, 48
; return值存入EAX
    jmp func_end_std_memory_blkSizeOf1; 跳转到公共返回点
    end_if_17:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 2
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_18
    if_18:
    mov EAX, 64
; return值存入EAX
    jmp func_end_std_memory_blkSizeOf1; 跳转到公共返回点
    end_if_18:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 3
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_19
    if_19:
    mov EAX, 96
; return值存入EAX
    jmp func_end_std_memory_blkSizeOf1; 跳转到公共返回点
    end_if_19:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 4
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_20
    if_20:
    mov EAX, 128
; return值存入EAX
    jmp func_end_std_memory_blkSizeOf1; 跳转到公共返回点
    end_if_20:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 5
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_21
    if_21:
    mov EAX, 192
; return值存入EAX
    jmp func_end_std_memory_blkSizeOf1; 跳转到公共返回点
    end_if_21:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 6
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_22
    if_22:
    mov EAX, 256
; return值存入EAX
    jmp func_end_std_memory_blkSizeOf1; 跳转到公共返回点
    end_if_22:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 7
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_23
    if_23:
    mov EAX, 384
; return值存入EAX
    jmp func_end_std_memory_blkSizeOf1; 跳转到公共返回点
    end_if_23:
    mov EAX, 512
; return值存入EAX
    jmp func_end_std_memory_blkSizeOf1; 跳转到公共返回点
    func_end_std_memory_blkSizeOf1:
    add esp, 24; 清理局部变量栈空间(24字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_headOf1
std_memory_headOf1:
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
    jne end_if_24
    if_24:
    mov EAX, [__global_std_memory_gH0]
; return值存入EAX
    jmp func_end_std_memory_headOf1; 跳转到公共返回点
    end_if_24:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 1
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_25
    if_25:
    mov EAX, [__global_std_memory_gH1]
; return值存入EAX
    jmp func_end_std_memory_headOf1; 跳转到公共返回点
    end_if_25:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 2
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_26
    if_26:
    mov EAX, [__global_std_memory_gH2]
; return值存入EAX
    jmp func_end_std_memory_headOf1; 跳转到公共返回点
    end_if_26:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 3
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_27
    if_27:
    mov EAX, [__global_std_memory_gH3]
; return值存入EAX
    jmp func_end_std_memory_headOf1; 跳转到公共返回点
    end_if_27:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 4
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_28
    if_28:
    mov EAX, [__global_std_memory_gH4]
; return值存入EAX
    jmp func_end_std_memory_headOf1; 跳转到公共返回点
    end_if_28:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 5
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_29
    if_29:
    mov EAX, [__global_std_memory_gH5]
; return值存入EAX
    jmp func_end_std_memory_headOf1; 跳转到公共返回点
    end_if_29:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 6
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_30
    if_30:
    mov EAX, [__global_std_memory_gH6]
; return值存入EAX
    jmp func_end_std_memory_headOf1; 跳转到公共返回点
    end_if_30:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 7
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_31
    if_31:
    mov EAX, [__global_std_memory_gH7]
; return值存入EAX
    jmp func_end_std_memory_headOf1; 跳转到公共返回点
    end_if_31:
    mov EAX, [__global_std_memory_gH8]
; return值存入EAX
    jmp func_end_std_memory_headOf1; 跳转到公共返回点
    func_end_std_memory_headOf1:
    add esp, 24; 清理局部变量栈空间(24字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_setHead2
std_memory_setHead2:
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
    jne end_if_32
    if_32:
    mov EAX, DWORD[ebp+12]
    mov [__global_std_memory_gH0], EAX
; 设置变量gH0
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_setHead2; 跳转到公共返回点
    end_if_32:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 1
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_33
    if_33:
    mov EAX, DWORD[ebp+12]
    mov [__global_std_memory_gH1], EAX
; 设置变量gH1
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_setHead2; 跳转到公共返回点
    end_if_33:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 2
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_34
    if_34:
    mov EAX, DWORD[ebp+12]
    mov [__global_std_memory_gH2], EAX
; 设置变量gH2
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_setHead2; 跳转到公共返回点
    end_if_34:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 3
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_35
    if_35:
    mov EAX, DWORD[ebp+12]
    mov [__global_std_memory_gH3], EAX
; 设置变量gH3
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_setHead2; 跳转到公共返回点
    end_if_35:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 4
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_36
    if_36:
    mov EAX, DWORD[ebp+12]
    mov [__global_std_memory_gH4], EAX
; 设置变量gH4
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_setHead2; 跳转到公共返回点
    end_if_36:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 5
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_37
    if_37:
    mov EAX, DWORD[ebp+12]
    mov [__global_std_memory_gH5], EAX
; 设置变量gH5
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_setHead2; 跳转到公共返回点
    end_if_37:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 6
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_38
    if_38:
    mov EAX, DWORD[ebp+12]
    mov [__global_std_memory_gH6], EAX
; 设置变量gH6
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_setHead2; 跳转到公共返回点
    end_if_38:
    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 7
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_39
    if_39:
    mov EAX, DWORD[ebp+12]
    mov [__global_std_memory_gH7], EAX
; 设置变量gH7
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_setHead2; 跳转到公共返回点
    end_if_39:
    mov EAX, DWORD[ebp+12]
    mov [__global_std_memory_gH8], EAX
; 设置变量gH8
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_setHead2; 跳转到公共返回点
    func_end_std_memory_setHead2:
    add esp, 24; 清理局部变量栈空间(24字节)
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
    sub esp, 48; 分配栈空间(48字节)


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
    jge end_if_40
    if_40:
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_refill2; 跳转到公共返回点
    end_if_40:
    mov EAX, DWORD[ebp+12]
; 参数1
    push 0

    push EAX; 参数1 扩展到64位

    mov EAX, DWORD[ebp-8]
    mov EBX, [__global_std_memory_ptrSize]
    add EAX, EBX
    push EAX
; 参数0
    call std_memory_store642
    add esp, 12; cdecl: 清理参数栈
    mov EAX, DWORD[ebp-8]
    mov DWORD[ebp-16], EAX
; 设置变量head
    mov DWORD[ebp-20], 0
; 设置变量prev
    mov EAX, DWORD[ebp-8]
    mov DWORD[ebp-24], EAX
; 设置变量p
    mov EBX, DWORD[ebp-8]
    mov DWORD[ebp-28], EBX
    mov EAX, 4096
    add DWORD[ebp-28], EAX
; 设置变量end




    for_1: ; for循环开始
    mov EAX, DWORD[ebp-24]
    mov EBX, DWORD[ebp+12]
    add EAX, EBX
; left operand
    mov ECX, DWORD[ebp-28]
; right operand
    cmp EAX, ECX
    jg for_1_end


    mov EAX, 0
; 参数1
    push 0

    push EAX; 参数1 扩展到64位

    push DWORD[ebp-24]
; 参数0
    call std_memory_store642
    add esp, 12; cdecl: 清理参数栈
    mov EAX, DWORD[ebp-20]
; left operand
    push EAX; 保护左操作数

    mov ECX, 0
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    je end_if_41
    if_41:
    mov EAX, DWORD[ebp-24]
; 参数1
    push 0

    push EAX; 参数1 扩展到64位

    push DWORD[ebp-20]
; 参数0
    call std_memory_store642
    add esp, 12; cdecl: 清理参数栈
    end_if_41:
    mov EAX, DWORD[ebp+12]
; 参数1
    push 0

    push EAX; 参数1 扩展到64位

    mov EBX, DWORD[ebp-24]
    mov EDX, [__global_std_memory_ptrSize]
    add EBX, EDX
    push EBX
; 参数0
    call std_memory_store642
    add esp, 12; cdecl: 清理参数栈
    mov EBX, DWORD[ebp-24]
    mov DWORD[ebp-20], EBX
; 设置变量prev
    mov EDX, DWORD[ebp+12]
    add DWORD[ebp-24], EDX
; 设置变量p


    jmp for_1; for循环
    for_1_end: ; for循环结束
    push DWORD[ebp-16]
; 参数1
    push DWORD[ebp+8]
; 参数0
    call std_memory_setHead2
    add esp, 8; cdecl: 清理参数栈
    mov EAX, DWORD[ebp-8]
; return值存入EAX
    jmp func_end_std_memory_refill2; 跳转到公共返回点
    func_end_std_memory_refill2:
    add esp, 48; 清理局部变量栈空间(48字节)
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
    sub esp, 48; 分配栈空间(48字节)


    mov EAX, [__global_std_memory_ptrSize]
    mov EBX, 2
    imul EAX, EBX
    mov EBX, DWORD[ebp+8]
    mov DWORD[ebp-8], EBX
    add DWORD[ebp-8], EAX
; 设置变量req
    mov EAX, DWORD[ebp-8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 512
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jle end_if_42
    if_42:
    push 0
; 参数0
    call std_syscall_brk1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-12], EAX
; 设置变量old
    mov EBX, DWORD[ebp-12]
    mov EAX, DWORD[ebp-8]
    add EBX, EAX
    push EBX
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
    jge end_if_43
    if_43:
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_malloc1; 跳转到公共返回点
    end_if_43:
    mov EAX, 0
; 参数1
    push 0

    push EAX; 参数1 扩展到64位

    push DWORD[ebp-12]
; 参数0
    call std_memory_store642
    add esp, 12; cdecl: 清理参数栈
    mov EAX, DWORD[ebp-8]
; 参数1
    push 0

    push EAX; 参数1 扩展到64位

    mov EAX, DWORD[ebp-12]
    mov EBX, [__global_std_memory_ptrSize]
    add EAX, EBX
    push EAX
; 参数0
    call std_memory_store642
    add esp, 12; cdecl: 清理参数栈
    mov EBX, [__global_std_memory_ptrSize]
    mov EDX, 2
    imul EBX, EDX
    mov EAX, DWORD[ebp-12]
    add EAX, EBX
; return值存入EAX
    jmp func_end_std_memory_malloc1; 跳转到公共返回点
    end_if_42:
    push DWORD[ebp-8]
; 参数0
    call std_memory_slotOf1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-20], EAX
; 设置变量idx
    push DWORD[ebp-20]
; 参数0
    call std_memory_blkSizeOf1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-24], EAX
; 设置变量blkSize
    push DWORD[ebp-20]
; 参数0
    call std_memory_headOf1
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
    jne end_if_44
    if_44:
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
    jne end_if_45
    if_45:
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_malloc1; 跳转到公共返回点
    end_if_45:
    end_if_44:
    push DWORD[ebp-28]
; 参数0
    call std_memory_load641
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-32], EAX
; 设置变量next
    push DWORD[ebp-32]
; 参数1
    push DWORD[ebp-20]
; 参数0
    call std_memory_setHead2
    add esp, 8; cdecl: 清理参数栈
    mov EAX, DWORD[ebp-24]
; 参数1
    push 0

    push EAX; 参数1 扩展到64位

    mov EAX, DWORD[ebp-28]
    mov EBX, [__global_std_memory_ptrSize]
    add EAX, EBX
    push EAX
; 参数0
    call std_memory_store642
    add esp, 12; cdecl: 清理参数栈
    mov EBX, [__global_std_memory_ptrSize]
    mov EDX, 2
    imul EBX, EDX
    mov EAX, DWORD[ebp-28]
    add EAX, EBX
; return值存入EAX
    jmp func_end_std_memory_malloc1; 跳转到公共返回点
    func_end_std_memory_malloc1:
    add esp, 48; 清理局部变量栈空间(48字节)
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
    sub esp, 40; 分配栈空间(40字节)


    mov EAX, DWORD[ebp+8]
; left operand
    push EAX; 保护左操作数

    mov ECX, 0
; right operand
    pop EAX; 恢复左操作数

    cmp EAX, ECX
    jne end_if_46
    if_46:
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_free1; 跳转到公共返回点
    end_if_46:
    mov EAX, [__global_std_memory_ptrSize]
    mov EBX, 2
    imul EAX, EBX
    mov EBX, DWORD[ebp+8]
    mov DWORD[ebp-8], EBX
    sub DWORD[ebp-8], EAX
; 设置变量blk
    mov EBX, DWORD[ebp-8]
    mov EAX, [__global_std_memory_ptrSize]
    add EBX, EAX
    push EBX
; 参数0
    call std_memory_load641
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
    jle end_if_47
    if_47:
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
    jne end_if_48
    if_48:
    push DWORD[ebp-8]
; 参数0
    call std_syscall_brk1
    add esp, 4; cdecl: 清理参数栈
    end_if_48:
    mov EAX, 0
; return值存入EAX
    jmp func_end_std_memory_free1; 跳转到公共返回点
    end_if_47:
    push DWORD[ebp-12]
; 参数0
    call std_memory_slotOf1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-20], EAX
; 设置变量idx
    push DWORD[ebp-20]
; 参数0
    call std_memory_headOf1
    add esp, 4; cdecl: 清理参数栈
    mov DWORD[ebp-24], EAX
; 设置变量head
    mov EAX, DWORD[ebp-24]
; 参数1
    push 0

    push EAX; 参数1 扩展到64位

    push DWORD[ebp-8]
; 参数0
    call std_memory_store642
    add esp, 12; cdecl: 清理参数栈
    push DWORD[ebp-8]
; 参数1
    push DWORD[ebp-20]
; 参数0
    call std_memory_setHead2
    add esp, 8; cdecl: 清理参数栈
    func_end_std_memory_free1:
    add esp, 40; 清理局部变量栈空间(40字节)
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
    sub esp, 24; 分配栈空间(24字节)


    mov EAX, DWORD[ebp+8]
    movzx EAX, byte[EAX]
    func_end_std_memory_load81:
    add esp, 24; 清理局部变量栈空间(24字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_load641
std_memory_load641:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 24; 分配栈空间(24字节)


    mov EAX, DWORD[ebp+8]
    mov EDX, [EAX+4]
    mov EAX, [EAX]
    func_end_std_memory_load641:
    add esp, 24; 清理局部变量栈空间(24字节)
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
    sub esp, 24; 分配栈空间(24字节)


    mov EAX, DWORD[ebp+8]
    mov ECX, DWORD[ebp+12]
    mov [EAX], CL
    func_end_std_memory_store82:
    add esp, 24; 清理局部变量栈空间(24字节)
    pop EBX; 恢复EBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: std_memory_store642
std_memory_store642:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 24; 分配栈空间(24字节)


    mov EAX, DWORD[ebp+8]
    mov ECX, DWORD[ebp+12]
    mov [EAX], ECX
    mov ECX, 0
    mov [EAX+4], ECX
    func_end_std_memory_store642:
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

