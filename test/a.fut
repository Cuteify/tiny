import "go.os"

fn hiMyLang(hi:f32, b:i32 = 1) i32 {
    if (b+3 > 6666) {
        ret 8
    }
    var a:f64 = hi
    var b:f64 = 123
    if (b > a) {
        //hiMyLang((6.6+9)*5, 9)
        b = 9
    } else {
        b = 10
    }
    ret a+b
}

fn hiFn(hi:int, b:i32 = "hi") i32 {
    hiMyLang((6.6+9)*5, 9)
    var abcdefg:i32 = 5
    var b:i32 = 123*abcdefg
    b=6
    if (b > abcdefg) {
        b = 0
    } else {
        b = 10
    }
    if (b > 0) {
        b = 9
        //hiMyLang((6.6+9)*5, 9)
    } else {
        ret 0
    }
    if (b > 0) {
        b = 9
        //hiMyLang((6.6+9)*5, 9)
    }
}

fn GetStdHandle(mode:i32) int {
    build UseMoreStack
    build ext GetStdHandle@1
}

fn print() {
    GetStdHandle(-11)
    build asm {
extern WriteFile

    ; 准备WriteConsoleW的参数
    push 0      ; 第五个参数：不保留额外
    push 0          ; 第四个参数：缓冲区，用于接收实际写入的字节数
    push messageLen ; 第三个参数：字符串的长度
    push message ; 第二个参数：指向要写入的字符串
    push eax      ; 第一个参数：句柄
    
    ; 调用WriteFileW
    call WriteFile

    xor eax, eax
    }
}


fn main() i32 {
    hiFn(100, 1)
print()
}