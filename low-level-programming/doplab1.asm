assume CS:code, DS:data

data segment
a dw 5
b dw 7
c dw 3
d dw 4
;для доп лабы
res dw ?		
msg db 2 dup(30h), 0dh, 0ah, "$"	;0dh -возврат каретки,0ah - подача след строки
msg2 db 2 dup(30h), "$"	
data ends

sseg segment stack
db 100h dup (?)
sseg ends

code segment
start:      
;(a+b)/c + d + 3
;(5+7)/3 + 4 + 3 = 11 (0B)
mov AX, data
mov DS, AX      ;указывает на data сегмент
mov AX, a      	;AX = 5
add AX, b      	;AX = 5 + 7 |12 = 0C
cwd             ;слово в двойное слово
div c          	;AX = 12/3 |4
add AX, d     	;AX = 4+4 |8
add AX, 3       ;AX = 8+3 |11 =0B
mov res, AX	;сохраним результат в переменную

; --Вывод десятичного числа--
mov DI, offset msg 		; DI  - destination index указывает на начало строки
push DI				; сохраняю DI в стек

mov BX, 10			; основание системы счисления
xor CX, CX 			; обнуление счетчика цифр
inDec: 	
	xor DX, DX 		; обнуляем dx
	div BX			; делим число на основание сс. В остатке - последняя цифра. ax - частное, dx - остаток
	add DL, 30h 		; в dl будет находится код символа цифры, и чтобы получить в al именно код символа, нужно прибавить код символа "0", который равен 30h 
	push DX			; сохраним цифру из остатка в стек
	inc CX			
	or AX, AX 		; проверка ax == 0
	jne inDec		; переход по адресу inDec, если частное не ноль  (продолжаем до конца числа)

makeStr:
	pop AX			; извлекаем цифру
	mov [DI], AL		; перемещаем цифру в строку (по адресу из DI)
	inc DI				
	dec CX				
	or CX, CX
	jne makeStr

mov AH, 09h			; 09h - вывод всех символов строки (она хранится в DX) до символа "$"
pop DI				; получили адрес начала строки
mov DX, DI			
int 21h	

; --Вывод шестнадцатиричного числа--
xor DI,DI			; обнуляем после вывода в 10сс !
mov DI, offset msg2 		
push DI
				
mov AX, res			; сохраняем значение результата в ax 
mov BX, 16			
xor CX, CX 			
inHex: 	
	xor DX, DX 		
	div BX			
	cmp DL, 9		; тк основание сс больше 10
	jbe oi1
	add DL, 7		; основание сс 16
	oi1:
		add DL, 30h	
	push DX			
	inc CX			
	or AX, AX 		
	jne inHex		; переход по адресу inHex, если частное не ноль  (продолжаем до конца числа)

mov [DI], byte ptr '0' 		;для вывода с незначащим нулем
inc DI

makeStr2:
	pop AX			
	mov [DI], AL		
	inc DI				
	dec CX				
	or CX, CX
	jne makeStr2

mov AH, 09h			
pop DI				
mov DX, DI			
int 21h	

mov AX, 4C00h   ;завершение программы
int 21h
code ends
end start
