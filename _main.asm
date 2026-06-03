section .text
global _start

section .text
global _start

; ==============================
; Function: sys_exit1
sys_exit1:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)
    ; ---- 函数开始 ----
    mov EAX, 1
    mov EBX, DWORD[ebp+8]
    int 0x80
    ; ---- 退出函数 ----
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave
    ret

; ======函数完毕=======


; ==============================
; Function: sys_mmap6
sys_mmap6:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)
    ; ---- 函数开始 ----
    mov EAX, 9
    mov EBX, DWORD[ebp+8]
    mov ECX, DWORD[ebp+16]
    mov EDX, DWORD[ebp+24]
    mov ESI, DWORD[ebp+28]
    mov EDI, DWORD[ebp+32]
    mov EBP, DWORD[ebp+36]
    int 0x80
    mov EAX, 0; return值存入EAX
    ; ---- 退出函数 ----
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave
    ret

; ======函数完毕=======


; ==============================
; Function: sys_munmap2
sys_munmap2:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)
    ; ---- 函数开始 ----
    mov EAX, 91
    mov EBX, DWORD[ebp+8]
    mov ECX, DWORD[ebp+16]
    int 0x80
    mov EAX, 0; return值存入EAX
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
    push 0; 参数0
    call sys_exit1
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

