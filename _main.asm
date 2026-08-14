section .text
global _start

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
    sub rsp, 448; 分配局部变量空间(448字节)
    mov RDI, [rbp-64]
; 参数0
    call 0
    mov QWORD[rbp-72], RAX
; 设置变量emptyLen
    mov RDI, [rbp-96]
; 参数0
    call 0
    mov QWORD[rbp-104], RAX
; 设置变量singleLen
    mov RAX, QWORD[rbp]
    mov QWORD[rbp-112], RAX
; 设置变量singleVal
    mov RDI, [rbp-136]
; 参数0
    call 0
    mov QWORD[rbp-144], RAX
; 设置变量multiLen
    mov RAX, QWORD[rbp]
    mov QWORD[rbp-152], RAX
; 设置变量first
    mov RAX, QWORD[rbp]
    mov QWORD[rbp-160], RAX
; 设置变量last
    mov RDI, [rbp-184]
; 参数0
    call 0
    mov QWORD[rbp-192], RAX
; 设置变量negLen
    mov RAX, QWORD[rbp]
    mov QWORD[rbp-200], RAX
; 设置变量negFirst
    mov RAX, QWORD[rbp]
    mov QWORD[rbp-208], RAX
; 设置变量negLast
    mov RDI, [rbp-232]
; 参数0
    call 0
    mov QWORD[rbp-240], RAX
; 设置变量largeLen
    mov RAX, QWORD[rbp]
    mov QWORD[rbp-248], RAX
    mov RAX, QWORD[rbp]
    add QWORD[rbp-248], RAX
    mov RAX, QWORD[rbp]
    add QWORD[rbp-248], RAX
; 设置变量largeSum
    mov , QWORD[rbp]
; expression statement
    mov , QWORD[rbp]
; expression statement
    mov , QWORD[rbp]
; expression statement
    mov RAX, QWORD[rbp]
    mov QWORD[rbp-280], RAX
    mov RAX, QWORD[rbp]
    add QWORD[rbp-280], RAX
    mov RAX, QWORD[rbp]
    add QWORD[rbp-280], RAX
; 设置变量modSum
    mov RAX, [rbp]
    mov [rbp-328], RAX
; 设置变量slice1
    mov RDI, [rbp-328]
; 参数0
    call 0
    mov QWORD[rbp-336], RAX
; 设置变量slice1Len
    mov RAX, [rbp]
    mov [rbp-360], RAX
; 设置变量slice2
    mov RDI, [rbp-360]
; 参数0
    call 0
    mov QWORD[rbp-368], RAX
; 设置变量slice2Len
    mov RAX, [rbp]
    mov [rbp-392], RAX
; 设置变量slice3
    mov RDI, [rbp-392]
; 参数0
    call 0
    mov QWORD[rbp-400], RAX
; 设置变量slice3Len
    mov RDI, [rbp-424]
; 参数0
    call 0
    mov QWORD[rbp-432], RAX
; 设置变量repLen
    mov RAX, QWORD[rbp]
    mov QWORD[rbp-440], RAX
    mov RAX, QWORD[rbp]
    add QWORD[rbp-440], RAX
    mov RAX, QWORD[rbp]
    add QWORD[rbp-440], RAX
    mov RAX, QWORD[rbp]
    add QWORD[rbp-440], RAX
    mov RAX, QWORD[rbp]
    add QWORD[rbp-440], RAX
; 设置变量repSum
    mov RAX, QWORD[rbp-72]
    mov RBX, QWORD[rbp-104]
    add RAX, RBX
    mov RBX, QWORD[rbp-112]
    add RAX, RBX
    mov RBX, QWORD[rbp-144]
    add RAX, RBX
    mov RBX, QWORD[rbp-152]
    add RAX, RBX
    mov RBX, QWORD[rbp-160]
    add RAX, RBX
    mov RBX, QWORD[rbp-192]
    add RAX, RBX
    mov RBX, QWORD[rbp-200]
    add RAX, RBX
    mov RBX, QWORD[rbp-208]
    add RAX, RBX
    mov RBX, QWORD[rbp-240]
    add RAX, RBX
    mov RBX, QWORD[rbp-248]
    add RAX, RBX
    mov RBX, QWORD[rbp-280]
    add RAX, RBX
    mov RBX, QWORD[rbp-336]
    add RAX, RBX
    mov RBX, QWORD[rbp-368]
    add RAX, RBX
    mov RBX, QWORD[rbp-400]
    add RAX, RBX
    mov RBX, QWORD[rbp-432]
    add RAX, RBX
    mov RBX, QWORD[rbp-440]
    add RAX, RBX
; return值存入RAX
    jmp func_end_main
    func_end_main:
    add rsp, 448; 清理局部变量栈空间
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

