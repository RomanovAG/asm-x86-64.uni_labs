bits 64
;       (a*e - b*c + d/b) / ((b + c)*a)
section .bss

result resq 1

section .data

a dd 2000000000
b dw -1
c dd 2147483647
d dw 8
e dd 3

section .text
global _start

divByZero:
	mov eax, 60
	mov edi, 1
	syscall

overflow:
	mov eax, 60
	mov edi, 2
	syscall

exitSuccess:
	mov eax, 60
	xor edi, edi
	syscall

a1:
	sal rdx, 32
	or rax, rdx
	movsx rbx, ebx
	movsx rcx, ecx
	movsx rdi, edi
	movsx rsi, esi
	jmp b1

a2:
	sal rdx, 32
	or rax, rdx
	movsx rbx, ebx
	movsx rcx, ecx
	movsx rdi, edi
	movsx rsi, esi
	jmp b2

a3:
	sal rdx, 32
	or rax, rdx
	movsx rbx, ebx
	movsx rcx, ecx
	movsx rdi, edi
	movsx rsi, esi
	jmp b3

;x1:
;	movsx rcx, eax ;b*c
;	movsx rax, dword[a]
;	imul dword[e]
;	xchg rax, rcx
;	jmp b2
;
;x2:
;	movsx rcx, eax
;	movsx 

extendedRegisters:
	movsx rax, dword[a]
	movsx rbx, dword[e]
	imul rbx		   ;a*e
	jo overflow
b1:
	mov rcx, rax
	movsx rax, word[b]
	movsx rbx, dword[c]
	imul rbx	 	   ;b*c
	jo overflow
b2:
	sub rcx, rax       ;a*e - b*c
	jo overflow
	movsx rax, word[d]
	movsx rsi, word[b]
	cmp rsi, 0
	je divByZero
	cqo
	idiv rsi
	cdqe			   ;d/b
	add rcx, rax	   ;a*e - b*c + d/b
	jo overflow
	movsx rax, dword[c]
	add rax, rsi	   ;b + c
	jo overflow
	movsx rbx, dword[a]
	imul rbx		   ;(b + c)*a
	jo overflow
b3:
	mov rdi, rax
	mov rax, rcx
	cmp rdi, 0
	je divByZero
	cqo
	idiv rdi		   ;/
	cdqe
	mov qword[result], rax

	jmp exitSuccess

_start:
	mov eax, dword[a]
	imul dword[e]	   ;a*e
	jo a1
	js a1
	mov ecx, eax
	movsx eax, word[b]
	imul dword[c] 	   ;b*c
	jo a2
	js a2
	sub ecx, eax       ;a*e - b*c
	jo extendedRegisters
	movsx eax, word[d]
	movsx esi, word[b]
	cmp esi, 0
	je divByZero
	cdq
	idiv esi		   ;d/b
	add ecx, eax	   ;a*e - b*c + d/b
	jo extendedRegisters
	mov eax, dword[c]
	add eax, esi	   ;b + c
	jo extendedRegisters
	imul dword[a]	   ;(b + c)*a
	jo a3
	js a3
	mov edi, eax
	mov eax, ecx
	cmp edi, 0
	je divByZero
	cdq
	idiv edi		   ;/
	cdqe
	mov qword[result], rax

	jmp exitSuccess
