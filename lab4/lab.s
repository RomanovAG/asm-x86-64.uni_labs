bits	64
;		cosh(x)
section	.data
format:
		db		"w", 0
FILE:
		dq		0
msg1:
		db		"Enter x: ", 0
msg2:
		db		"Enter accuracy: ", 0
msg3:
		db		"%f", 0
msg4:
		db		"  cosh(%.10g) = %.10g", 10, 0
msg5:
		db		"mycosh(%.10g) = %.10g", 10, 0
msg6:
		db		"%2d: %.10g", 10, 0
err1:
		db		"No file provided", 10, 0
err2:
		db		"Accuracy is lower or equal to zero", 10, 0

section	.text	
mycoshf:
		_file	equ		8
		_format	equ		_file+8
		_ACC	equ		_format+4
		_X_2	equ		_ACC+4		;x^2
		_EDX	equ		_X_2+4
		_SUM	equ		_EDX+4
		_XMM3	equ		_SUM+4
		_XMM5	equ		_XMM3+4
		
		push	rbp
		mov		rbp, rsp
		sub		rsp, _XMM5+8

		mulss	xmm0, xmm0
		mov		[rbp-_file], rdi
		mov		[rbp-_format], rsi
		movss	[rbp-_ACC], xmm1
		movss	[rbp-_X_2], xmm0	;x^2
		
		xorps	xmm3, xmm3			;xmm3 = 0.0
		movss	xmm5, [.one]		;xmm5 - member
		movss	[rbp-_SUM], xmm5	;xmm2 - sum
		mov		dword[rbp-_EDX], 1
.m0:
		cvtss2sd	xmm0, xmm5
		mov		edx, [rbp-_EDX]
		mov		eax, 1
		movss	[rbp-_XMM3], xmm3	;saving registers...
		movss	[rbp-_XMM5], xmm5
		call	fprintf
		movss	xmm3, [rbp-_XMM3]
		movss	xmm5, [rbp-_XMM5]
		mov		rdi, [rbp-_file]
		mov		rsi, [rbp-_format]
		
		mulss	xmm5, [rbp-_X_2]
		addss	xmm3, [.one]		;inc xmm3
		divss	xmm5, xmm3
		addss	xmm3, [.one]		;inc xmm3
		divss	xmm5, xmm3
		ucomiss	xmm5, [rbp-_ACC]
		jb		.m1
		movss	xmm2, [rbp-_SUM]
		addss	xmm2, xmm5
		movss	[rbp-_SUM], xmm2
		inc		dword[rbp-_EDX]
		jmp		.m0
.one:
		dd		1.0
.m1:
		movss	xmm0, [rbp-_SUM]
		leave
		ret
size	equ		4
input	equ		size
acc		equ		input+size
result	equ		acc+size
extern	fopen
extern	fclose
extern	fprintf
extern	printf
extern	scanf
extern	coshf
global 	main
main:
		push	rbp
		mov		rbp, rsp
		sub		rsp, result+4

		cmp		edi, 2
		jne		.ExitNoFile
		mov 	rdi, [rsi+8]
		mov		rsi, format
		call	fopen
		mov		[FILE], rax
.m0:
		mov		rdi, msg1
		xor		eax, eax
		call	printf

		mov		rdi, msg3
		lea		rsi, [rbp-input]
		call	scanf
		or		eax, eax
		jl		.ExitSuccess

		mov		rdi, msg2
		xor		eax, eax
		call	printf

		mov		rdi, msg3
		lea		rsi, [rbp-acc]
		call	scanf
		or		eax, eax
		jl		.ExitSuccess
	
		movss	xmm0, [rbp-input]
		call	coshf
		movss	[rbp-result], xmm0

		mov		rdi, msg4
		cvtss2sd	xmm0, [rbp-input]
		cvtss2sd	xmm1, [rbp-result]
		mov		eax, 2
		call	printf

		movss	xmm0, [rbp-input]
		movss	xmm1, [rbp-acc]
		xorps	xmm2, xmm2
		ucomiss	xmm1, xmm2
		jbe		.ExitZero
		mov		rdi, [FILE]
		mov		rsi, msg6
		call	mycoshf
		movss	[rbp-result], xmm0

		mov		rdi, msg5
		cvtss2sd	xmm0, [rbp-input]
		cvtss2sd	xmm1, [rbp-result]
		mov		eax, 2
		call	printf
		jmp		.ExitSuccess
.ExitSuccess:
		mov		rdi, [FILE]
		call	CloseFile
		xor		eax, eax
		jmp		.Exit
.ExitError:
		mov		rdi, [FILE]
		call	CloseFile
		mov		eax, 1
		jmp		.Exit
.ExitNoFile:
		mov 	rdi, err1
		call	printf
		mov		rdi, [FILE]
		call	CloseFile
		jmp		.Exit
.ExitZero:
		mov 	rdi, err2
		call	printf
		mov		rdi, [FILE]
		call	CloseFile
.Exit:
		leave
		ret
CloseFile:
		push	rbp
		mov		rbp, rsp
		or		rdi, rdi
		jz		.r
		call	fclose
.r:
		leave
		ret
