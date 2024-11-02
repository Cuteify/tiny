section .text
global main


; ==============================
; Function:test.hiMyLang2
test.hiMyLang2:
    push ebp; 函数基指针入栈
    mov ebp, esp; 设置基指针
    sub esp, 16; 调整栈指针
    mov EBX, DWORD[ebp+16]; 保存表达式左边的值
    add EBX, 3; 计算表达式的值
    mov EAX, EBX; 
    cmp EAX, 6666; 比较表达式的值
    jnl end_if_1; 判断后跳转到目标
    if_1:
    add esp, 16; 还原栈指针
    pop ebp; 跳转到函数返回部分
    ret

    end_if_1:
    mov  QWORD[ebp-16], 123; 设置变量
    cmp 123, EAX; 比较表达式的值
    jnl else_if_2; 判断后跳转到目标
    if_2:
    mov  QWORD[ebp-16], 9.5; 设置变量
    else_if_2:
    mov  QWORD[ebp-16], 10.4; 设置变量
    end_if_2:
    add esp, 16; 还原栈指针
    pop ebp; 跳转到函数返回部分
    ret

; ======函数完毕=======

; ==============================
; Function:test.hiFn2
test.hiFn2:
    push ebp; 函数基指针入栈
    mov ebp, esp; 设置基指针
    sub esp, 20; 调整栈指针
    mov DWORD[esp+12], 9; 设置函数参数
    mov QWORD[esp+8], 78; 设置函数参数
    call test.hiMyLang2; 调用函数
    mov  DWORD[ebp-4], 5; 设置变量
    mov  DWORD[ebp-8], 6; 设置变量
    mov else_if_3, 1; 
    if_3:
    mov  DWORD[ebp-8], 0; 设置变量
    else_if_3:
    mov  DWORD[ebp-8], 10; 设置变量
    end_if_3:
    cmp EAX, 0; 比较表达式的值
    jnl else_if_4; 判断后跳转到目标
    if_4:
    mov  DWORD[ebp-8], 9; 设置变量
    else_if_4:
    add esp, 20; 还原栈指针
    pop ebp; 跳转到函数返回部分
    ret

    end_if_4:
    cmp EAX, 0; 比较表达式的值
    jnl end_if_5; 判断后跳转到目标
    if_5:
    mov  DWORD[ebp-8], 9; 设置变量
    end_if_5:
    add esp, 20; 还原栈指针
    pop ebp; 弹出函数基指针
    ret

; ======函数完毕=======

; ==============================
; Function:test.main0
test.main0:
    push ebp; 函数基指针入栈
    mov ebp, esp; 设置基指针
    sub esp, 16; 调整栈指针
    mov QWORD[esp+16], 1; 设置函数参数
    mov QWORD[esp+8], 100; 设置函数参数
    call test.hiFn2; 调用函数
    add esp, 16; 还原栈指针
    pop ebp; 弹出函数基指针
    ret

; ======函数完毕=======


main:
call test.main0
PRINT_STRING "MyLang First Finish!"
ret

