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
    sub esp, 16; 分配局部变量栈空间(16字节)
    ; ---- 函数开始 ----
    mov EAX, DWORD[ebp+8]
    mov end_if_1, EAX; 
    if_1:
    mov EAX, 1; return值存入EAX
    ; ---- 退出函数 ----
    add esp, 16; 清理局部变量栈空间(16字节)
    pop EBX; 恢复EBX
    leave
    ret

    end_if_1:
    mov EAX, DWORD[ebp-4]
    mov DWORD[ebp-4], EAX; 设置变量prev
    mov ECX, DWORD[ebp-4]
    mov DWORD[ebp-4], ECX; 设置变量curr
    mov DWORD[ebp-4], 0; 设置变量next
    mov EDX, DWORD[ebp-4]
    mov DWORD[ebp-4], EDX; 设置变量loop_var
    
    
    
    
    for_1: ; for循环开始
    mov EBX, EDX
    mov EBX, DWORD[ebp+8]
    cmp EBX, EBX
    jg for_1_end; 判断后跳转到目标
    
    
    
    
    jmp for_1; for循环
    for_1_end: ; for循环结束
    mov EAX, ECX; return值存入EAX
    ; ---- 退出函数 ----
    add esp, 16; 清理局部变量栈空间(16字节)
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
    ; ---- 函数开始 ----
    push 30; 参数0
    call fib1
    add esp, 4; 清理参数栈(cdecl)
    ; ---- 退出函数 ----
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

