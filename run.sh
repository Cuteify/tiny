goimports -w -v .
gofmt -d -w -s .
clear
go build
CUTE_CALLCONV="cdecl" ./cuteify
nasm -f elf32 -o mian.o _main.asm
ld -m elf_i386 -o first mian.o  --entry main
#./first