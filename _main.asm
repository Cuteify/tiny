section .text
global _start

section .text
global _start

; ==============================
; Struct: Person
; Size: 24 bytes
; Alignment: 8 bytes
; ==============================
; Field: name (string) - Offset: 0, Size: 8
; Field: age (int) - Offset: 8, Size: 4
; Field: address (string) - Offset: 16, Size: 8
; ======结构体定义完毕=======

; ==============================
; Struct: Student
; Size: 32 bytes
; Alignment: 8 bytes
; ==============================
; Field: name (string) - Offset: 0, Size: 8
; Field: age (int) - Offset: 8, Size: 4
; Field: address (string) - Offset: 16, Size: 8
; Field: grade (int) - Offset: 24, Size: 4
; Field: score (float) - Offset: 28, Size: 4
; ======结构体定义完毕=======

; ==============================
; Struct: EmptyStruct
; Size: 0 bytes
; Alignment: 1 bytes
; ==============================
; ======结构体定义完毕=======

; ==============================
; Function: main
main:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)
    ; ---- 函数开始 ----
    mov EAX, 0; return值存入EAX
    ; ---- 退出函数 ----
    add esp, 8; 清理局部变量栈空间(8字节)
    pop EBX; 恢复EBX
    leave
    ret

; ======函数完毕=======


; ==============================
; Struct: Person
; Size: 24 bytes
; Alignment: 8 bytes
; ==============================
; Field: name (string) - Offset: 0, Size: 8
; Field: age (int) - Offset: 8, Size: 4
; Field: address (string) - Offset: 16, Size: 8
; ======结构体定义完毕=======

; ==============================
; Struct: Student
; Size: 32 bytes
; Alignment: 8 bytes
; ==============================
; Field: name (string) - Offset: 0, Size: 8
; Field: age (int) - Offset: 8, Size: 4
; Field: address (string) - Offset: 16, Size: 8
; Field: grade (int) - Offset: 24, Size: 4
; Field: score (float) - Offset: 28, Size: 4
; ======结构体定义完毕=======

; ==============================
; Function: main
main:
    push ebp; 保存调用者的栈帧基址
    mov ebp, esp; 设置当前栈帧基址
    push EBX; 保存EBX
    sub esp, 8; 分配栈空间(8字节)
    ; ---- 函数开始 ----
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

