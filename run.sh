goimports -w .
gofmt -d -w -s .
clear
go build -o cuteify
CUTE_CALLCONV="cdecl" ./cuteify test
nasm -f elf32 -o main.o _main.asm
ld -m elf_i386 -o first main.o  --entry _start
#./first