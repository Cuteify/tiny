section .text
global _start

section .text
global _start

; ==============================
; Function: fib1
fib1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)
    ; ---- 函数开始 ----
    mov EAX, DWORD[ebp+8]
    cmp EAX, 2
    jg end_if_1; 判断后跳转到目标
    if_1:
    mov EAX, 1; return值存入EAX
    ; ---- 退出函数 ----
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave
    ret

    end_if_1:
    mov EAX, DWORD[ebp+8]
    sub EAX, 1
    push EAX; 参数0
    call fib1
    add esp, 4; 清理参数栈(cdecl)
    mov EBX, EAX; 函数返回值直接移到EBX
    mov ECX, DWORD[ebp+8]
    sub ECX, 2
    push ECX; 参数0
    call fib1
    add esp, 4; 清理参数栈(cdecl)
    add EBX, EAX; EBX = fib(i-1) + fib(i-2)
    mov EAX, EBX; return值存入EAX
    ; ---- 退出函数 ----
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave
    ret

; ======函数完毕=======


; ==============================
; Function: fib21
fib21:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 24; 分配栈空间(24字节)
    ; ---- 函数开始 ----
    mov DWORD[ebp-8], 0; 设置变量prev
    mov DWORD[ebp-12], 1; 设置变量cur
    
    
    mov DWORD[ebp-16], 0; 设置变量j
    
    
    for_1: ; for循环开始
    mov ECX, DWORD[ebp-16]
    mov EDX, DWORD[ebp+8]
    cmp ECX, EDX
    jnl for_1_end; 判断后跳转到目标
    
    
    mov ECX, DWORD[ebp-8]
    mov EDX, DWORD[ebp-12]
    add ECX, EDX
    mov DWORD[ebp-20], ECX; 设置变量next
    mov EDX, DWORD[ebp-12]
    mov DWORD[ebp-8], EDX; 设置变量prev
    mov EDX, ECX
    mov DWORD[ebp-12], EDX; 设置变量cur
    
    
    mov EDX, DWORD[ebp-16]
    add EDX, 1
    mov DWORD[ebp-16], EDX; 设置变量j
    jmp for_1; for循环
    for_1_end: ; for循环结束
    mov EAX, DWORD[ebp-8]; return值存入EAX
    ; ---- 退出函数 ----
    add esp, 24; 清理局部变量栈空间(24字节)
    pop EBX; 恢复EBX
    leave
    ret

; ======函数完毕=======


; ==============================
; Function: main
main:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)
    ; ---- 函数开始 ----
    push 30; 参数0
    call fib21
    add esp, 4; 清理参数栈(cdecl)
    ; ---- 退出函数 ----
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave
    ret

; ======函数完毕=======


; ==============================
; 程序入口点 (ELF入口)
_start:
    ; 调用main函数
    call main
    ; 使用系统调用退出程序 (sys_exit = 1)
    ; 返回值在EAX中
    mov ebx, eax; 返回码
    mov eax, 1; sys_exit
    int 0x80; 调用内核

