bits 64
;	(a*e - b*c + d/b) / ((b + c)*a)
section .bss

result resq 1

section .data

a dd -3
b dw 2
c dd -1
d dw -8
e dd -9

section .text

global _start
_start:

	movsx eax, word[b]
	mov ebx, dword[c]
	mov edi, dword[e]
	imul ebx	
	mov rbx, rax
	mov eax, dword[a]
	imul edi
	xor edx, edx
	sub eax, ebx
	mov rbx, rax
	movsx eax, word[d]
	movsx edi, word[b]
	cdq
	idiv edi
	cdqe
	xor rdx, rdx
	add ebx, eax
; /
	movsx eax, word[b]
	mov edi, dword[c]
	mov esi, dword[a]
	add eax, edi
	imul esi
	xchg rax, rbx
	cdq
	idiv ebx
	cdqe
	mov [result], rax
;RETURN
	mov eax, 60
	xor edi, edi
	syscall
