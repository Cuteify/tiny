import "go.os"

fn hiMyLang(hi:int, b:i64 = "hi") i64 {
    if (b+3 > hi) {
        ret 8
    }
    a := hi
    var b:i32 = 123
    if (b > a) {
        hiMyLang((6.6+9)*5, 9)
        b = 9
    } else {
        b = 10
    }
    ret a+b
}

fn hiFn(hi:int, b:i64 = "hi") i64 {
    hiMyLang((6.6+9)*5, 9)
    abcdefg := 1
    var b:i32 = 123*abcdefg
    if (b > abcdefg) {
        //b = 12345
        hiMyLang((6.6+9)*5, 9)
    } else {
        b = 10
    }
    if (b > 0) {
        b = 9
        hiMyLang((6.6+9)*5, 9)
    } else {
        b = 10
    }
    if (b > 0) {
        b = 9
        hiMyLang((6.6+9)*5, 9)
    }
}

fn main() i64 {
    hiFn(1)
}