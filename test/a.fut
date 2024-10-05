import "go.os"

fn hiMyLang(hi:i32, b:i32 = 1) i32 {
    if (b+3 > 6666) {
        ret 8
    }
    var a:i32 = hi
    var b:i32 = 123
    if (b > a) {
        //hiMyLang((6.6+9)*5, 9)
        b = 9
    } else {
        b = 10
    }
    ret a+b
}

fn hiFn(hi:int, b:i64 = "hi") i32 {
    hiMyLang((6.6+9)*5, 9)
    var abcdefg:i32 = 1
    var b:i32 = 123*abcdefg
    if (b > abcdefg) {
        b = 0
        //hiMyLang((6.6+9)*5, 9)
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

fn main() i32 {
    hiFn(100, 1)
}