section .text
global _start

section .text
global _start

; ==============================
; Function: Open3
Open3:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)
    ; ---- 函数开始 ----
    mov EAX, 5; return值存入EAX
    ; ---- 退出函数 ----
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave
    ret

; ======函数完毕=======


; ==============================
; Function: Close1
Close1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)
    ; ---- 函数开始 ----
    mov EAX, 6; return值存入EAX
    ; ---- 退出函数 ----
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave
    ret

; ======函数完毕=======


; ==============================
; Function: Write3
Write3:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)
    ; ---- 函数开始 ----
    mov EAX, 4; return值存入EAX
    ; ---- 退出函数 ----
    add esp, 8; 清理局部变量栈空间(8字节)
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
    push 420; 参数2
    push 1; 参数1
    push 0; 参数0
    call Open3
    add esp, 20; 清理参数栈(cdecl)
    mov DWORD[ebp-8], EAX; 设置变量fd
    push 5; 参数2
    push 0; 参数1
    mov EAX, DWORD[ebp-8]
    push EAX; 参数0
    call Write3
    add esp, 20; 清理参数栈(cdecl)
    mov EAX, DWORD[ebp-8]
    push EAX; 参数0
    call Close1
    add esp, 4; 清理参数栈(cdecl)
    mov EAX, 0; return值存入EAX
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

