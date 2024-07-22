bits 64
;		Heap sort
section .data
size	equ		1
siz 	equ		4

a:
		db		8
		db		7
		db		1
		db		9
		db		5
		db		2
		db		6
		db		0
		db		4
		db		3

n:
		dd		10
mas:
		db		8, 7, 1, 9, 5, 2, 6, 0, 4, 3
mas2:
		dd		0,	0,	0,	0,	0,	0,	0,	0,	0,	0
		
section .text
global _start
_start:
		lea		eax,				[a]
		mov		dword[mas2],		eax
		lea		eax,				[a+size*1]
		mov		dword[mas2+siz*1],	eax
		lea		eax,				[a+size*2]
		mov		dword[mas2+siz*2],	eax
		lea		eax,				[a+size*3]
		mov		dword[mas2+siz*3],	eax
		lea		eax,				[a+size*4]
		mov		dword[mas2+siz*4],	eax
		lea		eax,				[a+size*5]
		mov		dword[mas2+siz*5],	eax
		lea		eax,				[a+size*6]
		mov		dword[mas2+siz*6],	eax
		lea		eax,				[a+size*7]
		mov		dword[mas2+siz*7],	eax
		lea		eax,				[a+size*8]
		mov		dword[mas2+siz*8],	eax
		lea		eax,				[a+size*9]
		mov		dword[mas2+siz*9],	eax


		mov		ebx, mas2
		mov		esi, [n]
		mov		edi, esi
		dec		edi
		or		edi, edi
		jle		m8
		shr		esi, 1
m1:
		or		esi, esi
		jnz		m2
		cmp		edi, 1
		jz		m7
		mov		eax, [rbx]
		mov		r8b, byte[rax]
		mov		r9d, dword[rbx+rdi*siz]
		xchg	r8b, byte[r9d]
		mov		[rax], r8b		;здесь остановился
		dec		edi
		jmp		m3
m2:
		dec		esi
m3:
		mov		eax, [rbx+rsi*siz]
		mov		r8b, byte[rax]
		push	rsi
		mov		ecx, esi
m4:
		shl		ecx, 1
		inc		ecx
		cmp		ecx, edi
		je		m5
		jg		m6
		mov		edx, dword[rbx+rcx*siz]
		mov		r10b, byte[rdx]
		mov		r11d, dword[rbx+rcx*siz+siz]
		cmp		r10b, byte[r11d] ;fafcesfcsz
		jge		m5
		inc		ecx
m5:
		mov 	r9d, dword[rbx+rcx*siz]
		cmp		r8b, byte[r9d]
		jge		m6
		mov		edx, dword[rbx+rcx*siz]
		mov		r12b, byte[rdx]
		mov		r13d, [rbx+rsi*siz]
		mov		[r13d], r12b
		mov		esi, ecx
		jmp		m4
m6:
		mov		r9d, dword[rbx+rsi*siz]
		mov		[r9d], r8b
		pop		rsi
		jmp		m1
m7:
		mov		eax, dword[rbx]
		mov		r8b, byte[eax]
		mov		r9d, dword[rbx+siz]
		cmp		r8b, byte[r9d]
		jle		m8
		xchg	r8b, byte[r9d]
		mov		[rax], r8b
m8:
		mov		eax, 60
		xor		edi, edi
		syscall
