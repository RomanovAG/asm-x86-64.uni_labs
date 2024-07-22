bits	64

section .data

fd:
		dq		0

msg:
		db		"message", 10
msglen	equ		$-msg

section .text
global _start

_start:
		

		;mov		eax, 85
		;mov		rdi, [rsp+16]
		;mov		rsi, 0666o
		;syscall
		;mov		[fd], rax

		

		mov		eax, 3
		mov		rdi, 1
		syscall
		mov		rsi, 0
		lea		rip, [rsi+0]

		mov		eax, 1
		mov		edi, 1
		mov		rsi, msg
		mov		edi, msglen
		syscall

ExitSuccess:
		xor		edi, edi
		jmp		Exit
ExitError:
		mov		edi, 1
Exit:
		mov		eax, 60
		syscall
