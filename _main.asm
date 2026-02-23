section .text
global _start

section .text
global _start

; ==============================
; Function: main
main:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 24; 分配栈空间(24字节)
    ; ---- 函数开始 ----
    mov DWORD[ebp-12], 10; 设置变量p.x
    mov DWORD[ebp-8], 20; 设置变量p.y
    mov DWORD[ebp-24], 1; 设置变量cp.x
    mov DWORD[ebp-20], 2; 设置变量cp.y
    mov DWORD[ebp-16], 255; 设置变量cp.color
    mov EAX, 0; return值存入EAX
    ; ---- 退出函数 ----
    add esp, 24; 清理局部变量栈空间(24字节)
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

