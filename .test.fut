fn main() {
    // 定义多个变量用于测试寄存器分配
    a := 10;
    b := 20;
    c := 30;
    d := 40;
    e := 50;
    f := 60;
    
    // 复杂表达式计算，测试寄存器重用
    x := a + b;           // 简单加法
    y := c * d;           // 简单乘法
    z := x + y;           // 使用之前计算结果
    
    // 更复杂的表达式，强制使用多个寄存器
    result1 := (a + b) * (c + d);     // 重用a+b和c+d的计算结果
    result2 := (a * b) + (c * d);     // 重用a*b和c*d的计算结果
    result3 := (a + b + c) * d;       // 复杂表达式
    
    // 测试寄存器溢出情况
    temp1 := a + b;
    temp2 := c + d;
    temp3 := e + f;
    temp4 := a * b;
    temp5 := c * d;
    temp6 := e * f;
    temp7 := temp1 + temp2 + temp3 + temp4 + temp5 + temp6;
    
    // 使用所有计算结果防止被优化掉
    ret temp7 + result1 + result2 + result3 + z;
}