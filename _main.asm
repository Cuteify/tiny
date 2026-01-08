section .text
global _start

; ==============================
; Function: fib1
fib1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    ; ---- 函数开始 ----
    mov EAX, [ebp+8]
    cmp EAX, 2
    jg end_if_1; 判断后跳转到目标
    if_1:
    mov EAX, 1; return值存入EAX
    ; ---- 退出函数 ----
    pop EBX; 恢复EBX
    leave
    ret

    end_if_1:
    mov ECX, [ebp+8]
    sub ECX, 1
    push ECX; 参数0
    call fib1
    add esp, 4; 清理参数栈(cdecl)
    mov EBX, EAX; 函数返回值直接移到EBX
    mov EDX, [ebp+8]
    sub EDX, 2
    push EDX; 参数0
    call fib1
    add esp, 4; 清理参数栈(cdecl)
    add EBX, EAX; EBX = fib(i-1) + fib(i-2)
    mov EAX, EBX; return值存入EAX
    ; ---- 退出函数 ----
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

