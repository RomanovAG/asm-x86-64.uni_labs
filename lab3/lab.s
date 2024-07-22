bits	64
;	Reverse symbols in words
section .data

size	equ		1024

msg1:
		db		"Enter string: "
msg1len	equ		$-msg1

str:
		times	size	db		0

msg2:
		db		34
		
newstr:
		times	size	db		0

fd:
		dq		0
        
section .text
global  _start

_start:
		cmp		dword[rsp], 2 			;выход, если не передали параметр при запуске / передали больше, чем нужно
		jne		ExitError

		mov		rsi, [rsp+16]
		xor		edi, edi
.a0:
		or		byte[rsi+rdi], 0
		je		.a1
		inc		edi						;вычисляем длину параметра
		jmp		.a0	
.a1:
		mov		r15d, edi				;сохраняем длину параметра
		mov		edx, 3  				;envp начинается с 32 (4*8)
.a2:
		inc		edx
		mov		rbx, [rsp+rdx*8]		;в rbx очередной ук. на строку в env
		or		rbx, 0x0				;дошли до конца и не нашли нужную перменную
		je		ExitError
		xor		edi, edi
.a3:
		mov		al, [rbx+rdi]
		cmp		al, [rsi+rdi]			;побайтово сравниваем...
		jne		.a2
		inc		edi
		cmp		edi, r15d				;сравниваем с длиной параметра
		jl		.a3

		cmp		byte[rbx+rdi], '='
		jne		.a2
tmp:
		;mov		eax, 85
		mov		eax, 2
		mov		rsi, 0x241
		;mov		rsi, 0102o
		lea		rdi, [rbx+rdi+1]		;кладём адрес начала строки, где хранится путь к нужному файлу
		mov		edx, 0666o
		syscall
		or		rax, rax
		jl		ExitError
		mov		[fd], rax
		
cycle:
		mov		eax, 1
		mov		edi, 1
		mov		rsi, msg1
		mov		edx, msg1len
		syscall							;вывод приглашения для ввода

		xor		eax, eax
		xor		edi, edi
		mov		rsi, str
		mov		edx, size
		syscall							;сам ввод

		or		eax, eax
		jl		ExitError				;ошибка
		je		ExitSuccess				;CTRL+D
		cmp		eax, size
		je		ExitError
		mov		rsi, str
		mov		rdi, newstr
		cmp		byte[rsi+rax-1], 10
		jne		ExitError
		xor		ecx, ecx
.m0:
		mov		al, [rsi]				;rsi двигается по исходной строке
		inc		rsi
		cmp		al, 10 					;сравнение с '\n'
		je		.m1
		cmp		al, ' '					;сравнение с пробелом
		je		.m1
		cmp		al, 9					;сравнение с '\t'
		je		.m1
		inc		ecx						;если попался другой символ (обычно буква/цифра)
		jmp		.m0
.m1:
		jecxz	.m4						;если пробел/'\t'/'\n' встретился после другого символа из этого списка (в ecx хранится длина слова)
		cmp		rdi, newstr				;если пока не записали ни одного символа...
		je		.m2
		mov		byte[rdi], ' '			;...иначе пишем пробел после слова, записанного последним
		inc		rdi						;в rdi указатель на память, куда пишем очередное слово
.m2:
		mov		rdx, rsi				;в rdx хранится указатель на "после пробела/таба/\n"
		dec		rdx						;теперь на пробел
.m3:
		dec		rdx						;идем от конца слова до его начала...
		mov		bl, [rdx]
		mov		[rdi], bl				;...и пишем в новую строку
		inc		rdi
		loop	.m3						;вначале в ecx хранилась длина слова
.m4:
		cmp		al, 10 
		jne		.m0
		mov		byte[rdi], 34	;2560+34
		inc		rdi
		mov		byte[rdi], 10
		inc		rdi						;rdi указывает на "после конца строки"

;Writing to file...
		mov		eax, 1
		mov		rsi, msg2
		mov		rdx, rdi
		sub		rdx, msg2
		mov		rdi, [fd]
		syscall
		
		jmp		cycle

CloseFile:
		cmp		rdi, 2
		jle 	.r 						;проверка на корректность дескриптора
		mov		eax, 3
		syscall
.r:
		ret
		
ExitSuccess:
		mov		rdi, [fd]
		call	CloseFile
		xor		edi, edi
		jmp		Exit
ExitError:
		mov		rdi, [fd]
		call	CloseFile
		mov		edi, 1
Exit:
		mov		eax, 60
		syscall
