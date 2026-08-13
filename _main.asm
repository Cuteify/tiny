section .text
global _start

; ==============================
; Function: sys_exit1
sys_exit1:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 48; 分配局部变量空间(48字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov EAX, 1
    mov EBX, QWORD[rbp+16]
    int 0x80
    func_end_sys_exit1:
    add rsp, 48; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: sys_mmap6
sys_mmap6:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 48; 分配局部变量空间(48字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    mov QWORD [rbp+32], RDX; 保存参数2到栈
    mov QWORD [rbp+36], RCX; 保存参数3到栈
    mov QWORD [rbp+40], R8; 保存参数4到栈
    mov QWORD [rbp+44], R9; 保存参数5到栈
    mov EAX, 9
    mov EBX, QWORD[rbp+16]
    mov ECX, QWORD[rbp+24]
    mov EDX, QWORD[rbp+32]
    mov ESI, QWORD[rbp+36]
    mov EDI, QWORD[rbp+40]
    mov EBP, QWORD[rbp+44]
    int 0x80
    mov RAX, 0
; return值存入RAX
    jmp func_end_sys_mmap6
    func_end_sys_mmap6:
    add rsp, 48; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


; ==============================
; Function: sys_munmap2
sys_munmap2:
    push rbp
    mov rbp, rsp
    push RBX; 保存RBX
    push R12; 保存R12
    push R13; 保存R13
    push R14; 保存R14
    push R15; 保存R15
    sub rsp, 48; 分配局部变量空间(48字节)
    mov QWORD [rbp+16], RDI; 保存参数0到栈
    mov QWORD [rbp+24], RSI; 保存参数1到栈
    mov EAX, 91
    mov EBX, QWORD[rbp+16]
    mov ECX, QWORD[rbp+24]
    int 0x80
    mov RAX, 0
; return值存入RAX
    jmp func_end_sys_munmap2
    func_end_sys_munmap2:
    add rsp, 48; 清理局部变量栈空间
    pop R15; 恢复R15
    pop R14; 恢复R14
    pop R13; 恢复R13
    pop R12; 恢复R12
    pop RBX; 恢复RBX
    leave; 恢复栈帧
    ret

; ======函数完毕=======


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
    sub rsp, 48; 分配局部变量空间(48字节)
    mov RDI, 0
; 参数0
    call sys_exit1
    mov RAX, 0
; return值存入RAX
    jmp func_end_main
    func_end_main:
    add rsp, 48; 清理局部变量栈空间
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

