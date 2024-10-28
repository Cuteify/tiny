import "go.os"

fn hiMyLang(hi:f64, b:i32 = 1) i32 {
    if (b+3 > 6666) {
        ret 8
    }
    var a:f64 = hi
    var b:f64 = 123.1
    if (b > a) {
        //hiMyLang((6.6+9)*5, 9)
        b = 9.5
    } else {
        b = 10.4
    }
    ret a+b
}

fn hiFn(hi:int, b:i64 = "hi") i32 {
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

fn main() i32 {
    hiFn(100, 1)
}