build arch "amd64"
build os "windows"

const PAGE_READWRITE = 

// 释放分配的内存
// 这里由汇编实现
// ptr<u8>: 要释放的内存指针
fn free(ptr: u8) {
    build nasm {
    push 0               ; 参数2: 0（释放整个内存块）
    push %%ptr%%             ; 参数1: 之前分配的内存地址
    mov %$VirtualFreeCallCode$%, 0x1000     ; 系统调用号，表示 VirtualFree
    call %$VirtualFreeCallCode$%             ; 释放内存
    }
}

// 意外退出
// 这里由汇编实现
// message<string>: 错误信息
fn pinic(message: string) {}

// 分配内存
// 这里由汇编实现
// size<u64>: 要分配的内存大小
// 返回值<u8>: 分配的内存指针
fn malloc(size: u64) -> u8 {}

// 分配内存
// 这里由汇编实现
// size<u64>: 要分配的内存大小
// 起始位置<u8>: 起始位置
// flAllocationType: <u8>
// flProtect: <u8>
// 返回值<u8>: 分配的内存指针
fn malloc(size: u64, start: u8, flAllocationType: u8 = , flProtect: u8) -> u8 {}
