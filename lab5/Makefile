all:
	gcc -c main.c -o  main.o
	gcc -c -o3 filter.c -o filter.o
	gcc -c implementation.c -o implementation.o
	nasm -f elf64 filter_asm.s -o filter_asm.o
	gcc -z noexecstack -static main.o filter.o implementation.o filter_asm.o -o lab -lm
