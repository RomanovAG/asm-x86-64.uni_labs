bits	64
;		Filter function that uses kernel
global	apply_filter_asm

section	.text

data	equ		8
width	equ		data+4
height	equ		width+4
kernel	equ		height+8
kernel_size		equ		kernel+4
div_	equ		kernel_size+4

kernel_radius	equ		div_+4
out_	equ		kernel_radius+8

nr		equ		out_+1
ng		equ		nr+1
nb		equ		ng+1

;rcx - y
;rbx - x
;rdi - ky
;rsi - kx
;r8  - nx
;r9  - ny
;r10 - (data/kernel/out)_ptr
;r11 - offset
;r12 - tmp_y
;r13 - r
;r14 - g
;r15 - b
;rax - tmp

apply_filter_asm:
        push	rbp
		mov		rbp, rsp
		sub		rsp, nb+1	;0x48
		push	rbx
		push	rsi
		push	rdi
		push	r12
		push	r13
		push	r14
		push	r15
.p:
        mov		[rbp-data], rdi
        mov		[rbp-out_], rsi
		mov		[rbp-width], edx
		mov		[rbp-height], ecx
		mov		[rbp-kernel], r8
		mov		[rbp-kernel_size], r9d
		mov		eax, [rbp+16]
		mov		[rbp-div_], eax

        shr		r9d, 1
		mov		[rbp-kernel_radius], r9d	;int kernel_radius = kernel_size / 2;

        xor		ecx, ecx					;y = 0
.for_y:
        xor		ebx, ebx					;x = 0
.for_x:
		xor		r13d, r13d
		xor		r14d, r14d
		xor		r15d, r15d

        xor		r10d, r10d
		xor		r11d, r11d
		xor		eax, eax

        xor		edi, edi					;ky = 0
.for_ky:
        xor		esi, esi					;kx = 0
.for_kx:
        mov		r8d, ebx
		add		r8d, esi
		sub		r8d, [rbp-kernel_radius]	;int nx = x + kx - kernel_radius;

        mov		r9d, ecx
		add		r9d, edi
		sub		r9d, [rbp-kernel_radius]	;int ny = y + ky - kernel_radius;
.nx:
        or		r8d, r8d					;If the neighboring pixel is not within the image bounds
		jl		.not_in_bounds
		or		r9d, r9d
		jl		.not_in_bounds
		cmp		r8d, [rbp-width]
		jge		.not_in_bounds
		cmp		r9d, [rbp-height]
		jge		.not_in_bounds
		jmp		.calculate_pixel
.not_in_bounds:
        cmp		r8d, ebx
		je		.m1
		cmp		r9d, ecx
		je		.m1

        or		r8d, r8d
		jge		.if1
		or		r9d, r9d
		jl		.m1
.if1:
        cmp		r8d, [rbp-width]
		jl		.if2
		or		r9d, r9d
		jl		.m1
.if2:
        or		r8d, r8d
		jge		.if3
		cmp		r9d, [rbp-height]
		jge		.m1
.if3:
        cmp		r8d, [rbp-width]
		jl		.elif
		cmp		r9d, [rbp-height]
		jge		.m1
.elif:
        or		r8d, r8d
		jl		.m3
		cmp		r8d, [rbp-width]
		jl		.m2
		jmp		.m3
.m1:
        mov		r8d, ebx
		mov		r9d, ecx
		jmp		.calculate_pixel
.m2:
        mov		r9d, ecx
		jmp		.calculate_pixel
.m3:
        mov		r8d, ebx
.calculate_pixel:
        mov		r10, [rbp-data]

        mov		eax, r9d
		mul		dword[rbp-width]
		add		eax, r8d
		mov 	r11d, 3
		mul		r11d
		mov 	r11d, eax						;(nx + ny * width) * 3

        mov		al, [r10+r11+0]
		mov		[rbp-nr], al
		mov		al, [r10+r11+1]
		mov		[rbp-ng], al
		mov		al, [r10+r11+2]
		mov		[rbp-nb], al

        mov		r10, [rbp-kernel]

        mov		eax, edi
		mul		dword[rbp-kernel_size]
		add		eax, esi
		mov 	r11d, eax					;kx + ky * kernel_size
.t0:
        movzx	eax, byte[rbp-nr]
		mul		dword[r10+r11*4]
		add		r13d, eax					;r += nr * kernel[kx + ky * kernel_size];

        movzx	eax, byte[rbp-ng]
		mul		dword[r10+r11*4]
		add		r14d, eax					;g += ng * kernel[kx + ky * kernel_size];

        movzx	eax, byte[rbp-nb]
		mul		dword[r10+r11*4]
		add		r15d, eax					;b += nb * kernel[kx + ky * kernel_size];

        inc		esi
		cmp		esi, [rbp-kernel_size]
		jl		.for_kx
		inc		edi
		cmp		edi, [rbp-kernel_size]
		jl		.for_ky
.t1:
		mov		eax, r13d
		xor		edx, edx
		div		dword[rbp-div_]
		mov		r13d, eax
		mov		eax, r14d
		xor		edx, edx
		div		dword[rbp-div_]
		mov		r14d, eax
		mov		eax, r15d
		xor		edx, edx
		div		dword[rbp-div_]
		mov		r15d, eax

        mov		r10, [rbp-out_]

        mov		eax, ecx
		mul		dword[rbp-width]
		add		eax, ebx
		mov 	r11d, 3
		mul		r11d
		mov 	r11d, eax
.test:
        mov		[r10+r11+0], r13b
		mov		[r10+r11+1], r14b
		mov		[r10+r11+2], r15b

        inc		ebx
		cmp		ebx, [rbp-width]
		jl		.for_x
		inc		ecx
		cmp		ecx, [rbp-height]
		jl		.for_y

        xor		eax, eax
.return:
        pop		r15
		pop		r14
		pop		r13
		pop		r12
		pop		rdi
		pop		rsi
		pop		rbx
        leave
		ret
