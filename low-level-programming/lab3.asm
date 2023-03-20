; лабораторная работа 3 
; 3 вариант
assume cs: code, ds: data, es: data

data segment
string1 db 100, 99 dup (0)
string2 db 100, 99 dup (0)
msg1 db "Enter string1: $"
msg2 db 0ah, 0dh, "Enter string2: $"		
msg3 db 0ah, 0dh, "Result of execution strcmp(string1, string2): $"
data ends

sseg segment stack
db 100h dup (?)
sseg ends

code segment
strcmp proc
    	pop bp	; указатель на вершину стека - адрес возврата
    	pop dx  ; указатель на string2
    	pop bx	; указатель на string1 
	
	strloop:
		cld		; направление df=0 
		
		mov cx, 100 	; кол-во повторений строковых операций	
		mov di, dx 	; указатель на string 2 
		mov si, bx	; указатель на string1
		repe cmpsb 	; повторение до первого несовпадения 
		jne noeq	; строки не равны (нашли различные байты) => перескакиваем на noeq
		cmp cx, 0
		je eql		; если cx=0 - мы дошли до конца строки => они равны => перескакиваем на eql
		jmp strloop	; безусловный переход на начало цикла, если мы не перешли в noeq или eql 
		noeq:
			dec si		; Если несовпадение было найдено, то DI и SI будут указывать на байты, следующие непосредственно за байтами, которые не совпали
			dec di		; пусть di и si указывают на сами несовпадающие байты, а не на следующие после них
					; Нужно сравнить [di] и [si]
			mov ax, [si]
			cmp ax, [di] 	; ax - [di] сравнивается с 0
			ja gr		;больше
			jb ls		;меньше
			jmp strloop
			gr:			; в случае string1 > string 2 должно возвращаться положительное число 
				sub ax, [di]
				mov dx, ax
				mov bx, 0 	;0 ЗНАЧИТ ЧИСЛО ПОЛОЖИТЕЛЬНОЕ	
				jmp ext
			ls:			; в случае string1 < string 2 должно возвращаться отрицательное число 
				sub ax, [di]	; отрицательное число в процессоре будет в дополнительном коде
				sub ax, 1	; доп код -> обратный код
				mov dx, ax
				mov bx, 1 	;1 ЗНАЧИТ ЧИСЛО ОТРИЦАТЕЛЬНОЕ
				jmp ext
		eql:
			mov dx, 0		; string1 = string2 возвращается 0
			jmp ext
	ext:
		push dx		; возвращаемое значение
		push bx		; ОПОЗНАВАТЕЛЬ ПОЛОЖИТЕЛЬНОГО/ОТРИЦАТЕЛЬНОГО ЗНАЧЕНИЯ
		push bp		; кладем в стек адрес возврата
		ret		; возврат управления вызывающей программе
strcmp endp


start:	
	mov ax, data
	mov ds, ax
	mov es, ax
	lea dx, msg1
	mov ah, 09h
	int 21h		; вывели просьбу ввести 1ю строку
	lea dx, string1
	mov ah, 0ah
	int 21h		; ввели 1 строку с клавиатуры
	push dx		; отправялем в стек
	lea dx, msg2
	mov ah, 09h
	int 21h		; вывели просьбу ввести 2ю строку
	lea dx, string2
	mov ah, 0ah
	int 21h		; ввели 2 строку с клавиатуры
	push dx		; отправялем в стек
	lea dx, msg3
	mov ah, 09h
	int 21h		; выводим 3 строку, далее результат вычисления функции 
	call strcmp	
	pop bx 		;1 ИЛИ 0 - ОТРИЦ ИЛИ ПОЛОЖ ЧИСЛО
	
	cmp bx,1 	;ОТРИЦАТЕЛЬНОЕ ?
	jne answer 	;ЕСЛИ ПОЛОЖИТЕЛЬНОЕ
	mov ah,02h
	mov dl,'-' 	;ВЫВОДИМ ЗНАК '-'
	int 21h
	pop ax		; запоминаем результат функции в ax
	not ax		;ИНВЕРТИРУЕМ
	push ax

answer:				
	pop ax			; запоминаем результат функции в ax
	mov bx, 10		; вывод значения в 10сс
	mov cx, 0 		; обнуление счетчика цифр (xor cx, cx)
inDec: 	
	xor dx, dx 		; обнуляем dx
	div bx			; делим число на основание сс. В остатке - последняя цифра. ax - частное, dx - остаток
	add dl, 30h 		; в dl будет находится код символа цифры, и чтобы получить в al именно код символа, нужно прибавить код символа "0", который равен 30h 
	push dx			; сохраним цифру из остатка в стек
	inc cx			
	or ax, ax 		; проверка ax == 0 
	jne inDec		; переход по адресу inDec, если частное не ноль  (продолжаем до конца числа)

outp:
	mov ah, 02h		; 02h - вывод символа
	pop dx			
	int 21h
	loop outp	
jmp away	

away:		
	mov ah, 4ch
	int 21h
	code ends
	end start
