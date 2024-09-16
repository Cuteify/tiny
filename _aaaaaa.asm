
section .text
global main


; ==============================
; Function:hiMyLang2
hiMyLang2:
    push ebp; 函数基指针入栈
    mov ebp, esp; 设置基指针
    sub rsp, 12; 为局部变量分配空间
    mov RDX, 3; 保存表达式左边的值
    add RDX, QWORD[ebp0]; 计算表达式的值
    mov RCX, RDX; 保存表达式的值
    cmp RBX, RCX; 比较表达式的值
    jnl end_if_1; 判断后跳转到目标
    if_1:
    pop ebp; 跳转到函数返回部分
    ret

    end_if_1:
    cmp RSI, RDI; 比较表达式的值
    jnl else_if_2; 判断后跳转到目标
    if_2:
    call hiMyLang2; 调用函数
    else_if_2:
    end_if_2:
    pop ebp; 跳转到函数返回部分
    ret

; ======函数完毕=======

; ==============================
; Function:hiFn2
hiFn2:
    push ebp; 函数基指针入栈
    mov ebp, esp; 设置基指针
    sub rsp, 12; 为局部变量分配空间
    call hiMyLang2; 调用函数
    mov RBP, 123; 保存表达式左边的值
    mul RBP, QWORD[ebp-8]; 计算表达式的值
    mov  DWORD[ebp-12], RBP; 保存表达式的值
    cmp RSP, R8; 比较表达式的值
    jnl else_if_3; 判断后跳转到目标
    if_3:
    call hiMyLang2; 调用函数
    else_if_3:
    end_if_3:
    cmp R9, 0; 比较表达式的值
    jnl else_if_4; 判断后跳转到目标
    if_4:
    call hiMyLang2; 调用函数
    else_if_4:
    end_if_4:
    cmp R10, 0; 比较表达式的值
    jnl end_if_5; 判断后跳转到目标
    if_5:
    call hiMyLang2; 调用函数
    end_if_5:
; ======函数完毕=======