all:
	echo "\n\tChoose between \"ascending (a)\" and \"descending (d)\"\n"
a:
	/usr/bin/nasm -g -f elf64 lab.s -o lab.o -D ascending
	/usr/bin/ld -g -static lab.o -o lab
d:
	/usr/bin/nasm -g -f elf64 lab.s -o lab.o -D descending
	/usr/bin/ld -g -static lab.o -o lab
