bits	64
;		exp(x*cos(a))*cos(x*sin(a))
section .data
format:
				db				"w", 0
msg0:
				db				"Enter x: ", 0
msg1:
                db              "Enter a: ", 0
msg2:
                db              "Enter accuracy: ", 0
msg3:
                db              "%lf", 0
msg4:
                db              "lib(%.10g, %.10g) = %.10g", 10, 0
msg5:
                db              " my(%.10g, %.10g) = %.10g", 10, 0
msg6:
                db              "%2d: %.10g", 10, 0
err1:
                db              "No file provided", 10, 0
err2:
                db              "Accuracy is lower or equal to zero", 10, 0

section .text
flib:
		_Xlib 	equ 	8
		_Alib 	equ 	_Xlib+8
		_tmp	equ 	_Alib+8
		push	rbp
		mov 	rbp, rsp
		sub		rsp, _tmp

		movsd	[rbp-_Xlib], xmm0
		movsd 	[rbp-_Alib], xmm1

		movsd	xmm0, [rbp-_Alib]
		call	cos
		mulsd	xmm0, [rbp-_Xlib]
		call	exp
		movsd	[rbp-_tmp], xmm0

		movsd	xmm0, [rbp-_Alib]
		call	sin
		mulsd	xmm0, [rbp-_Xlib]
		call	cos

		mulsd	xmm0, [rbp-_tmp]
		leave
		ret
fmy:
                _file   equ		8
                _format equ		_file+8
                _ACC   	equ		_format+8
                _Xmy	equ		_ACC+8
                _Amy	equ		_Xmy+8
                _EDX    equ		_Amy+8
                _SUM    equ		_EDX+8
                _XMM3   equ		_SUM+8
                _XMM5   equ		_XMM3+8
                push	rbp
                mov 	rbp, rsp
                sub		rsp, _XMM5+8

                mov		[rbp-_file], rdi
                mov 	[rbp-_format], rsi
                movsd   [rbp-_ACC], xmm2
                movsd   [rbp-_Xmy], xmm0
                movsd	[rbp-_Amy], xmm1
                
                pxor	xmm3, xmm3              ;xmm3 - n
                movsd   xmm5, [.one]            ;xmm5 - x^n / n!
				movsd   [rbp-_SUM], xmm5        ;xmm2 - sum
                mov 	dword[rbp-_EDX], 1
.m0:
                mov 	edx, [rbp-_EDX]
                mov 	eax, 1
                movsd   [rbp-_XMM3], xmm3       ;saving registers...
                movsd   [rbp-_XMM5], xmm5
                mov 	rdi, [rbp-_file]
                mov 	rsi, [rbp-_format]
                call    fprintf
                movsd	xmm0, [rbp-_Amy]
                movsd   xmm3, [rbp-_XMM3]
                addsd   xmm3, [.one]            ;inc xmm3
                mulsd	xmm0, xmm3
                movsd   [rbp-_XMM3], xmm3
                call	mycos
                
                movsd   xmm5, [rbp-_XMM5]
                movsd   xmm3, [rbp-_XMM3]
                mulsd   xmm5, [rbp-_Xmy]
                
                divsd   xmm5, xmm3
                mulsd	xmm0, xmm5
                ucomisd xmm0, [rbp-_ACC]
                jb 		.abs
.m2:
                movsd   xmm2, [rbp-_SUM]
                addsd   xmm2, xmm0
                movsd   [rbp-_SUM], xmm2
                inc		dword[rbp-_EDX]
                jmp		.m0
.one:
                dq		1.0
.minus:
				dq		-1.0
.abs:
				mulsd	xmm0, [.minus]
				ucomisd xmm0, [rbp-_ACC]
				jb 		.m1
				mulsd	xmm0, [.minus]
				jmp		.m2
.m1:
                movsd   xmm0, [rbp-_SUM]
                leave
                ret
mycos: 
		mulsd	xmm0, xmm0
		movsd	xmm1, [.minus]
		mulsd	xmm1, xmm1		;xmm1 = 1.0 ;xmm1 - member
		movsd	xmm2, xmm1		;xmm2 - sum
		pxor	xmm3, xmm3		;xmm3 - n
		movsd	xmm4, xmm1		;xmm4 - 1.0 (const)
		pxor	xmm5, xmm5		;xmm5 - 0.0 (const)
.m0:
		mulsd	xmm1, xmm0
		mulsd	xmm1, [.minus]
		addsd	xmm3, xmm4
		divsd	xmm1, xmm3
		addsd	xmm3, xmm4
		divsd	xmm1, xmm3
		ucomisd	xmm1, xmm5		;== 0?
		je		.m1
		addsd	xmm2, xmm1
		jmp		.m0
.minus:
		dq		-1.0
.m1:
		movsd	xmm0, xmm2
		ret
extern  fopen
extern  fclose
extern  fprintf
extern  printf
extern  scanf
extern  exp
extern	sin
extern	cos
global  main
main:
		size	equ             8
		FILE	equ 			size
		x		equ             FILE+size
		a 		equ 			x+size
		acc		equ             a+size
		result  equ             acc+size
                push	rbp
                mov 	rbp, rsp
                sub		rsp, result+8
                mov 	qword[rbp-FILE], 0

                cmp		edi, 2
                jne		.ExitNoFile
                mov     rdi, [rsi+8]
                mov 	rsi, format
                call    fopen
                mov 	[rbp-FILE], rax
.m0:
                mov 	rdi, msg0
                xor		eax, eax
                call	printf

                mov 	rdi, msg3
	            lea		rsi, [rbp-x]
                call    scanf
                or		eax, eax
                jl		.ExitSuccess

				mov 	rdi, msg1
				xor 	eax, eax
				call	printf

				mov     rdi, msg3
				lea     rsi, [rbp-a]
                call    scanf
				or      eax, eax
				jl      .ExitSuccess
				
                mov     rdi, msg2
                xor     eax, eax
                call    printf

                mov     rdi, msg3
                lea     rsi, [rbp-acc]
                call    scanf
                or      eax, eax
                jl      .ExitSuccess
        
                movsd   xmm0, [rbp-x]
                movsd 	xmm1, [rbp-a]
                call    flib
                movsd   [rbp-result], xmm0

                mov     rdi, msg4
                movsd   xmm0, [rbp-x]
                movsd 	xmm1, [rbp-a]
                movsd   xmm2, [rbp-result]
                mov     eax, 3
                call    printf

                movsd   xmm0, [rbp-x]
                movsd 	xmm1, [rbp-a]
                movsd   xmm2, [rbp-acc]
                pxor	xmm3, xmm3
                ucomisd xmm2, xmm3
                jbe     .ExitZero
                mov     rdi, [rbp-FILE]
                mov     rsi, msg6
                call    fmy
                movsd   [rbp-result], xmm0

                mov     rdi, msg5
                movsd   xmm0, [rbp-x]
                movsd 	xmm1, [rbp-a]
                movsd   xmm2, [rbp-result]
                mov     eax, 3
                call    printf
                jmp     .ExitSuccess
.ExitSuccess:
                mov     rdi, [rbp-FILE]
                call    CloseFile
                xor     eax, eax
                jmp     .Exit
.ExitError:
                mov     rdi, [rbp-FILE]
                call    CloseFile
                mov     eax, 1
                jmp     .Exit
.ExitNoFile:
                mov     rdi, err1
                call    printf
                mov     rdi, [rbp-FILE]
                call    CloseFile
                jmp     .Exit
.ExitZero:
                mov     rdi, err2
                call    printf
                mov     rdi, [rbp-FILE]
                call    CloseFile
.Exit:
                leave
                ret
CloseFile:
                push	rbp
                mov 	rbp, rsp
                or		rdi, rdi
                jz		.r
                call    fclose
.r:
                leave
                ret

