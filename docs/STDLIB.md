# Cuteify 标准库参考

> 标准库以 `std:` 前缀在 `package.json` 的 `imports` 中引用，映射到 `pkg/` 目录下的包。
> 例：`"fs": "std:fs"` → `pkg/fs/`。未声明 import 的包无法直接使用。

## 包总览

| 包 | 目录 | 状态 | 架构支持 |
|----|------|------|---------|
| `std:fs` | `pkg/fs` | 现行 | x86_64 / x86 双架构 |
| `std:console` | `pkg/console` | 现行 | x86_64 / x86 双架构 |
| `std:memory` | `pkg/memory` | 现行 | x86_64 / x86 双架构 |
| `std:syscall` | `pkg/syscall` | 现行 | x86_64 / x86 双架构 |
| `std:strings` | `pkg/strings` | 现行（经 linkname 链接编译器全局符号） | x86_64 / x86 双架构 |
| （空） | `pkg/lists` | 空目录，无包 | - |

旧包 `std:io` 已删除，文件操作归入 `std:fs`、标准输出打印归入 `std:console`；`pkg/lists` 为空目录。

---

## 一、std:syscall（Linux 系统调用封装）

底层封装，`build os("linux")` 限定。x86_64 用 `syscall` 指令，x86 用 `int 0x80`（并 `mov edx, 0` 清高 32 位）。仅 `syscall`/`syscall6`/`syscall64` 三个原始函数保留内联汇编，其余便捷封装均为纯 Cuteify 转发。

### 通用调用

| 函数 | 签名 | 说明 |
|------|------|------|
| `syscall` | `(trap u64, a1 u64, a2 u64, a3 u64) u64` | 3 参数系统调用（x86_64 用 RAX/RDI/RSI/RDX；x86 为 `(trap u32, a1..a3 u32) u32`，用 EAX/EBX/ECX/EDX） |
| `syscall6` | `(trap u64, a1..a6 u64) u64` | 6 参数系统调用（x86_64 追加 R10/R8/R9；x86 为 `(trap u32, a1..a6 u32) u32`，用 ESI/EDI） |
| `syscall64` | `(trap u64, a1..a5 u64) u64` | 返回 64 位结果的 5 参数系统调用（x86 为 `(trap u32, a1..a5 u32) u64`） |

### 便捷封装

| 函数 | 签名 | 说明 |
|------|------|------|
| `exit` | `(code i32)` | 进程退出（x64 调用 60，x86 调用 1） |
| `brk` | `(addr ptr) ptr` | 调整堆边界，`brk(0)` 取当前堆顶（x64 调用 12，x86 调用 45） |
| `write` | `(fd i32, buf ptr, count u64) i32` | 写文件描述符，返回实际写入字节数（x64 调用 1，x86 调用 4） |
| `read` | `(fd i32, buf ptr, count u64) i32` | 读文件描述符，返回实际读取字节数，EOF 返回 0（x64 调用 0，x86 调用 3） |
| `open` | `(pathname u64, flags i32, mode u32) i32` | 打开文件，失败返回负值（x64 调用 2，x86 调用 5） |
| `close` | `(fd i32) i32` | 关闭文件描述符（x64 调用 3，x86 调用 6） |

---

## 二、std:memory（内存管理）

基于 brk 的分桶分配器：9 个固定块桶（32/48/64/96/128/192/256/384/512 字节，16 字节块头 `[next][size]`），`size+16 > 512` 的大块直接 brk 申请。依赖 `std:syscall`。

### 内存读写

| 函数 | 签名 | 说明 |
|------|------|------|
| `load8` | `(addr ptr) u8` | 读 1 字节 |
| `load32` | `(addr ptr) u32` | 读 4 字节 |
| `load64` | `(addr ptr) u64` | 读 8 字节 |
| `store8` | `(addr ptr, val u8)` | 写 1 字节 |
| `store32` | `(addr ptr, val u32)` | 写 4 字节 |
| `store64` | `(addr ptr, val u64)` | 写 8 字节 |

### 分配/释放

| 函数 | 签名 | 说明 |
|------|------|------|
| `malloc` | `(size u64) ptr` | 分配 `size` 字节，返回数据指针（实际块含 16 字节头）；失败返回 0 |
| `free` | `(ptr ptr) ptr` | 释放：小块回对应桶；大块且为堆顶时收缩 brk；`free(0)` 安全 |
| `realloc` | `(ptr ptr, new_size u64) ptr` | 调整大小：总是 malloc 新块 + 逐字节拷贝（取新旧较小者）+ free 旧块，返回新指针；失败返回 0 且原指针保持有效；`realloc(0, n)` 等价 `malloc(n)`。成功时旧指针作废 |

### 内部辅助（通常无需直接调用）

`slot_of(req) u64`（size+16 对应桶号 0..8）、`blk_size_of(idx) u64`（桶固定块大小）、`head_of(idx) ptr` / `set_head(idx, v) ptr`（桶头读写）、`refill(idx, blk_size) ptr`（brk 申请 4096 字节切块填桶）。桶头全局变量 `g_h0`..`g_h8`。

---

## 三、std:fs（文件操作）

文件抽象，复用 `std:syscall`（依赖声明见 `pkg/fs/package.json`），路径参数经 `std:strings` 的 `to_cstring` 转裸地址；仅 `read`/`write` 保留 `*u64` 转裸地址的 `build asm` 桥接（语言层不做 `*T` → `u64` 隐式转换，且 x86 上指针为 4 字节，直接传 8 字节 `u64` 有尺寸问题）。

### 常量

| 常量 | 值 | 说明 |
|------|----|------|
| `O_RDONLY` / `O_WRONLY` / `O_RDWR` | 0 / 1 / 2 | 打开模式 |
| `O_CREAT` / `O_TRUNC` / `O_APPEND` | 64 / 512 / 1024 | 打开标志（Linux x86/x86_64 数值相同） |

### 文件操作

| 函数 | 签名 | 说明 |
|------|------|------|
| `open` | `(path string, flags i32, mode u32) i32` | 打开文件（经 `strings.to_cstring(path)` 取 NUL 终止地址传给 syscall）；失败返回负值 |
| `read` | `(fd i32, buf *u64, count u64) i32` | 读入缓冲区，返回实际字节数；EOF 返回 0 |
| `write` | `(fd i32, buf *u64, count u64) i32` | 写出缓冲区，返回实际字节数 |
| `close` | `(fd i32) i32` | 关闭 |

> 缓冲注意：`read`/`write` 的 `buf` 类型是 `*u64`，以 8 字节为单位；不足 8 字节的读写（如 `count=5`）同样按字节计数，但请以 `u64` 变量做缓冲。

---

## 四、std:console（标准输出打印）

`build os("linux")`，复用 `std:syscall`（依赖声明见 `pkg/console/package.json`）。

### 常量

| 常量 | 值 | 说明 |
|------|----|------|
| `STDIN` / `STDOUT` / `STDERR` | 0 / 1 / 2 | 标准文件描述符 |

### 打印

| 函数 | 签名 | 说明 |
|------|------|------|
| `print` | `(s string) i32` | 打印字符串到 STDOUT，返回实际写出的字节数（不含换行） |
| `println` | `(s string) i32` | 打印字符串并追加换行，返回字节数（含换行 = `print(s)+1`） |

> 实现：`print` = `fs.write(STDOUT, to_cstring(s), len(s))`；`println` = 累计 `print(s)` 与 `write(STDOUT, "\n", 1)` 的返回值。

---

## 五、std:strings（字符串内省与转换）

`build os("linux")` + `build arch(...)` 双架构实现。核心函数通过 `build asm` 调用**编译器生成的全局符号**（linkname 约定，符号名 `__string_*`），绕开语言层缺少的 string 容器槽读取语法，返回结果由调用约定（RAX/EAX）带回：

| 函数 | 签名 | 说明 |
|------|------|------|
| `len` | `(s string) uint` | 按字节计数（UTF-8 中文每字 3 字节），等价内建 `len(s)` |
| `cap` | `(s string) uint` | 容器 cap 槽，等价内建 `cap(s)` |
| `eq` | `(s string, t string) bool` | 按 ptr 槽比较（字符串常量经 intern 同值同地址），等价 `==` |
| `ne` | `(s string, t string) bool` | 按 ptr 槽比较，等价 `!=` |
| `to_cstring` | `(s string) uint` | **安全的 string.ptr**：读取容器 ptr 槽为裸地址（uint 为平台原生字宽：x86_64 8 字节、x86 4 字节），可直接传给 `syscall.open` 等以 `u64` 收地址的函数 |
| `toString` | `(n int, base uint) string` | 整数转字符串（2-62 进制）：`0-9`→`0-9`、`10-35`→`a-z`、`36-61`→`A-Z`；负数带前导 `-`（补码最小值经位模式桥安全取反）；返回新分配堆字符串（容器 ptr/len/cap 三槽齐全，尾随 `\0`） |
| `parse` | `(s string, base uint) int` | 字符串转整数（2-62 进制，大小写字母均可）：支持前导 `-`；非法字符立即停止解析（返回已解析部分） |

### linkname 全局符号（编译器生成，勿手动定义）

| 符号 | 调用约定 | 语义 |
|------|----------|------|
| `__string_len` / `__string_cap` | x86_64：`lea RDI, [rbp+16]`（容器地址）→ 返回 RAX；x86：push 容器地址 → 读 `[esp+4]` | 读容器 len/cap 槽（x86_64 槽偏移 +8/+16；x86 三槽 4 字节，偏移 +4/+8） |
| `__string_eq` / `__string_ne` | 同上传容器地址 | 先解引用容器取 ptr 槽再比较，返回 0/1 |
| `__string_to_cstring` | 同上 | 返回 ptr 槽值（x86 零扩展到 EAX） |

符号定义由编译器在链接前一次性生成（`compile/compiler.go` 的 `generateStringSyms`），只收集被 `build asm` 中 `call __string_*` 引用的符号，落在 `.text` 段。

> 注：语言层不提供 string 容器槽读取语法与 `as` 类型转换，`to_cstring` 即这两者的安全替代，用于替代手写 `build asm` 桥接（旧版 `std:io` 的 open 即此类桥接，现已改用 `to_cstring`）。

---

## 六、编译器内建操作（无包导入）

| 能力 | 形式 | 说明 |
|------|------|------|
| 长度/容量 | `len(x)`、`cap(x)` | 对 string/list 读取容器 len/cap 槽；`len` 对 string 按字节计（UTF-8 中文每字 3 字节） |
| 追加 | `append(list, v)` | len<cap 直写，否则 realloc 扩容（暂只支持变量 a） |
| 构造 | `new(T[, v...])` | 堆上分配 Size(T) 并零填充，返回 `*T`；初值按字段顺序写入（标量） |
| 构造 | `make([]T, len[, cap])` | 运行时分配并零填充 |
| 拼接 | `s1 + s2` | 运行期 malloc + 双段 `rep movsb`，结果 `{ptr, len, cap}` 三槽 |
| 比较 | `s == t`、`s != t` | 字符串按 ptr 槽比较（常量 intern 后同值同 label；运行期按身份） |
| 索引 | `s[i]`、`s[i] = v` | 按字节读/写（索引赋值仅支持标量值） |

---

## 七、runtime/（内部运行时，非 std 包）

`runtime/` 是遗留运行时目录，不通过 `std:` 导入，当前编译器不依赖：

| 文件 | 内容 |
|------|------|
| `minimal.cute` | `build extern` 声明 write/exit + 基于系统调用的 print/println |
| `string.cute` | `strlen`/`strcpy`/`strcmp`/`memcpy`/`memset`（符号被遗留 `pkg/strings` 引用） |
| `syscall.cute` | 旧式 `syscall1`/`syscall3`/`sys_write`/`sys_exit` |
| `memory.cute` | 旧式 16MB BSS 静态堆 `sbrk`/分配器 |
| `std.cute` | 旧式泛型 `new[T]`/`make_slice[T]`、`str_eq`/`str_len`、`itoa`、`abs`/`min_int` 等 |

---

## 附：标准库使用示例

```cute
// package.json
{
    "name": "demo",
    "version": "1.0.0",
    "imports": {
        "fs": "std:fs",
        "console": "std:console",
        "memory": "std:memory",
        "syscall": "std:syscall"
    }
}
```

```cute
// main.cute
fn main() int {
    console.println("Hello Cuteify")

    var buf: u64 = 0
    var n: i32 = 1
    for n > 0 {
        n = fs.read(fs.STDIN, &buf, 8)   // echo
        if n > 0 {
            fs.write(fs.STDOUT, &buf, n)
        }
    }

    var p: ptr = memory.malloc(64)
    memory.store64(p, 42)
    var v: u64 = memory.load64(p)
    memory.free(p)
    ret 0
}
```