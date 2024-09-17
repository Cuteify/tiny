section .text
global main


; ==============================
; Function:hiMyLang2
hiMyLang2:
    push ebp; 函数基指针入栈
    mov ebp, esp; 设置基指针
    sub esp, 28; 调整栈指针
    mov RCX, 3; 保存表达式左边的值
    add RCX, QWORD[ebp0]; 计算表达式的值
    mov RBX, RCX; 保存表达式的值
    cmp RAX, RBX; 比较表达式的值
    jnl end_if_1; 判断后跳转到目标
    if_1:
    pop ebp; 跳转到函数返回部分
    ret

    end_if_1:
    mov  DWORD[ebp-12], 123; 修改局部变量
    cmp RDX, R8; 比较表达式的值
    jnl else_if_2; 判断后跳转到目标
    if_2:
    mov QWORD[ebp+36], 9; 修改局部变量
    mov QWORD[ebp+28], 78; 修改局部变量
    call hiMyLang2; 调用函数
    mov  DWORD[ebp-12], 9; 修改局部变量
    else_if_2:
    mov  DWORD[ebp-12], 10; 修改局部变量
    end_if_2:
    pop ebp; 跳转到函数返回部分
    ret

; ======函数完毕=======

; ==============================
; Function:hiFn2
hiFn2:
    push ebp; 函数基指针入栈
    mov ebp, esp; 设置基指针
    sub esp, 76; 调整栈指针
    mov QWORD[ebp+36], 9; 修改局部变量
    mov QWORD[ebp+28], 78; 修改局部变量
    call hiMyLang2; 调用函数
    mov  QWORD[ebp-8], 1; 修改局部变量
    mov R9, 123; 保存表达式左边的值
    mul R9, QWORD[ebp-8]; 计算表达式的值
    mov  DWORD[ebp-12], R9; 保存表达式的值
    cmp R10, R11; 比较表达式的值
    jnl else_if_3; 判断后跳转到目标
    if_3:
    mov QWORD[ebp+36], 9; 修改局部变量
    mov QWORD[ebp+28], 78; 修改局部变量
    call hiMyLang2; 调用函数
    else_if_3:
    mov  DWORD[ebp-12], 10; 修改局部变量
    end_if_3:
    cmp R12, 0; 比较表达式的值
    jnl else_if_4; 判断后跳转到目标
    if_4:
    mov  DWORD[ebp-12], 9; 修改局部变量
    mov QWORD[ebp+36], 9; 修改局部变量
    mov QWORD[ebp+28], 78; 修改局部变量
    call hiMyLang2; 调用函数
    else_if_4:
    mov  DWORD[ebp-12], 10; 修改局部变量
    end_if_4:
    cmp R13, 0; 比较表达式的值
    jnl end_if_5; 判断后跳转到目标
    if_5:
    mov  DWORD[ebp-12], 9; 修改局部变量
    mov QWORD[ebp+36], 9; 修改局部变量
    mov QWORD[ebp+28], 78; 修改局部变量
    call hiMyLang2; 调用函数
    end_if_5:
; ======函数完毕=======