section .text
global main

; ==============================
; Function:fib1
fib1:
    push ebp; 保存栈帧
    ; ---- 保存寄存器 ----
    push EBX; 保存寄存器
    ; ---- 分配栈空间 ----
    mov ebp, esp; 创建新的栈帧
    sub esp, 8; 创建栈空间
    ; ---- 函数内容 ----
    mov EAX, DWORD[ebp+8]; 临时存储内存数据
    cmp EAX, 2; 比较表达式的值
    jle end_if_1; 判断后跳转到目标
    if_1:
    pop EBX; 保存寄存器
    pop ebp; 跳转到函数返回部分
    ret

    end_if_1:
    sub esp, 4; 创建参数栈空间
    mov ECX, DWORD[ebp+8]; 临时存储内存数据
    sub ECX, 1; 计算表达式的值
    mov DWORD[ebp], ECX; 
    call fib1
    add esp, 4; 清理参数栈
    sub esp, 4; 创建参数栈空间
    mov EDX, DWORD[ebp+8]; 临时存储内存数据
    sub EDX, 2; 计算表达式的值
    mov DWORD[ebp], EDX; 
    call fib1
    add esp, 4; 清理参数栈
    mov EBX, EAX; 临时存储内存数据
    add EBX, EAX; 计算表达式的值
    mov EAX, EBX; return
    pop EBX; 保存寄存器
    pop ebp; 跳转到函数返回部分
    ret

; ======函数完毕=======


; ==============================
; Function:callee_function8
callee_function8:
    push ebp; 保存栈帧
    ; ---- 保存寄存器 ----
    push EBX; 保存寄存器
    ; ---- 分配栈空间 ----
    mov ebp, esp; 创建新的栈帧
    sub esp, 8; 创建栈空间
    ; ---- 函数内容 ----
    mov EAX, DWORD[ebp+12]; 临时存储内存数据
    add EAX, DWORD[ebp+8]; 计算表达式的值
    mov QWORD[ebp-8], EAX; 溢出到局部变量栈
    mov EAX, DWORD[ebp+20]; 临时存储内存数据
    add EAX, DWORD[ebp+16]; 计算表达式的值
    imul EAX, EAX; 计算表达式的值
    mov QWORD[ebp-8], EAX; 溢出到局部变量栈
    mov EAX, DWORD[ebp+24]; 临时存储内存数据
    add EAX, DWORD[ebp+20]; 计算表达式的值
    add EAX, DWORD[ebp+28]; 计算表达式的值
    mov QWORD[ebp-8], EAX; 溢出到局部变量栈
    mov EAX, DWORD[ebp+36]; 临时存储内存数据
    add EAX, DWORD[ebp+32]; 计算表达式的值
    imul EAX, EAX; 计算表达式的值
    sub EAX, EAX; 计算表达式的值
    mov QWORD[ebp-8], EAX; 设置变量result
    mov EAX, QWORD[ebp-8]; 临时存储内存数据
    mov EAX, EAX; return
    pop EBX; 保存寄存器
    pop ebp; 跳转到函数返回部分
    ret

; ======函数完毕=======


; ==============================
; Function:main
main:
    push ebp; 保存栈帧
    ; ---- 保存寄存器 ----
    push EBX; 保存寄存器
    ; ---- 分配栈空间 ----
    mov ebp, esp; 创建新的栈帧
    sub esp, 4; 创建栈空间
    ; ---- 函数内容 ----
    sub esp, 4; 创建参数栈空间
    call fib1
    add esp, 4; 清理参数栈
    pop EBX; 保存寄存器
    pop ebp; 跳转到函数返回部分
    ret

; ======函数完毕=======


