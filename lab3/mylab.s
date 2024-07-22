bits 64
;		Task
section .data
size	equ		1024

msg1:
		db		"Enter string: "
msg1len	equ		$-msg1

msg2:
		db		"Result: ", 34
msg2len	equ		$-msg2

msg3:
		db		34, 10
msg3len	equ		$-msg3

str:
		times	size	db		0

newstr:
		times	size	db		0

em:
		db		0

section .text
global _start

Empty:
		mov		eax, 1
		mov		edi, 1
		mov		esi, em
		mov		edx, 1
		syscall
		jmp		ExitSuccess
		
_start:
		mov		eax, 1
		mov		edi, 1
		mov		esi, msg1
		mov		edx, msg1len
		syscall

		xor		eax, eax
		xor		edi, edi
		mov		esi, str
		mov		edx, size
		syscall

		or		eax, eax
		jl		ExitError
		je		ExitSuccess
		cmp		eax, size
		je		ExitError

		cmp		byte[str], 10
		je		Empty

		mov		ecx, eax
		dec		ecx
		xor		edi, edi

l:
		cmp		byte[str+rdi], "	"
		jne		a1
		mov		byte[str+rdi], " "
a1:
		inc		edi
		loop	l
		
		mov		ecx, eax
		dec		ecx
		xor		edi, edi
		xor		esi, esi
		
		jmp		m2

m0:
		or		esi, esi
		je		m1
		cmp		byte[str+rdi+1], 10
		je		m1
		cmp		byte[str+rdi+1], " "
		jne		m3
m1:
		inc		edi
m2:
		cmp		byte[str+rdi], " "
		je		m0
m3:
		movzx	eax, byte[str+rdi]
		mov		[newstr+rsi], al
		cmp		edi, ecx
		je		m4
		inc		edi
		inc		esi
		cmp		edi, ecx
		jl		m2
m4:
		mov		r8d, esi
		;dec		r8d
tmp:
		mov		eax, 1
		mov		edi, 1
		mov		esi, msg2
		mov		edx, msg2len
		syscall

		mov		edx, r8d
		mov		eax, 1
		mov		edi, 1
		mov		esi, newstr
		syscall

		mov		eax, 1
		mov		edi, 1
		mov		esi, msg3
		mov		edx, msg3len
		syscall
		jmp		_start

ExitError:
		mov		edi, 1
		jmp		Exit
ExitSuccess:
		xor		edi, edi
Exit:
		xor		eax, eax
		mov		al, 60
		syscall
