bits	64
;		Sorting columns in matrix
section .data

n:
		db		4
m:
 		db		5
	
matrix:
	 	db		4,	6,	1,	8,	2
		db		1,	2,	3,	4,	5
		db		0,	-7,	3,	-1,	-1
		db		11,	-12,13,	-14,15

mas:
		dq		0x0
		dq		0x0
		dq		0x0
		dq		0x0

section .text
global _start

_start:
		cmp		byte[n], 1
		jle		ExitSuccess
		mov		rbx, matrix
		movzx	ecx, byte[m]
li:
		push	rcx
		movzx	ecx, byte[n]
		xor		esi, esi
		xor		edi, edi
lj:
		lea		r8, [rbx+rsi*1]
		mov		[mas+rdi*8], r8
		add		sil, byte[m]
		inc		edi
		loop	lj
;Here sorting starts...

		push	rbx
		
		mov		rbx, mas
		movzx	esi, byte[n]
		mov		edi, esi
		dec		edi
		or		edi, edi
		jle		m8
		shr		esi, 1
m1:
		or 		esi, esi
		jnz		m2
		cmp		edi, 1
		jz		m7
		mov		rax, qword[rbx]
		mov		r8b, byte[rax]
		mov		r9, qword[rbx+rdi*8]
		xchg	r8b, byte[r9]
		mov 	[rax], r8b
		dec		edi
		jmp		m3
m2:
		dec		esi
m3:
		mov		rax, qword[rbx+rsi*8]
		mov		r8b, byte[rax]
		push	rsi
		mov		ecx, esi
m4:
		shl		ecx, 1
		inc		ecx
		cmp		ecx, edi
		je		m5
		jg		m6
		mov		rdx, qword[rbx+rcx*8]
		mov		r10b, byte[rdx]
		mov		r11, qword[rbx+rcx*8+8]
		cmp		r10b, byte[r11]
%ifdef	ascending
		jge		m5
%endif

%ifdef	descending
		jle		m5
%endif
		inc		ecx
m5:
		mov		r9, qword[rbx+rcx*8]
		cmp		r8b, byte[r9]
%ifdef	ascending
		jge		m6
%endif

%ifdef	descending
		jle		m6
%endif
		mov		rdx, qword[rbx+rcx*8]
		mov		r12b, byte[rdx]
		mov		r13, qword[rbx+rsi*8]
		mov 	[r13], r12b
		mov		esi, ecx
		jmp		m4
m6:
		mov		r9, qword[rbx+rsi*8]
		mov 	[r9], r8b
		pop		rsi
		jmp		m1
m7:
		mov		rax, qword[rbx]
		mov		r8b, byte[rax]
		mov		r9, qword[rbx+8]
		cmp		r8b, byte[r9]
%ifdef	ascending
		jle		m8
%endif

%ifdef	descending
		jge		m8
%endif
		xchg	r8b, byte[r9]
		mov 	[rax], r8b
m8:
;Ends...
		pop		rbx
		pop		rcx
		inc		ebx
		dec		ecx
		jnz		li
	
ExitSuccess:
		mov		eax, 60
		xor		edi, edi
		syscall
