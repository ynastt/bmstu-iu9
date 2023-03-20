;lab 5
;вариант 2. Заменить все вхождения заданного символа в строке текста на
;указанный новый символ
assume cs: code, ds: data, es: data

data segment
;str1 db 25, ?, 25 dup ('$') ; текст
str1 db 25, 25 dup (90h)
syma db 0 ; символ, который заменяем
symb db 0 ; указанный новый символ
size_ db 0
msg1 db 0ah, 0dh, "Enter text: $"
msg2 db 0ah, 0dh, "Enter the char that you want to replace: $"
msg3 db 0ah, 0dh, "Enter new char: $"
msg4 db 0ah, 0dh, "Result: $"
line db 0ah, 0dh, '$'
data ends

sseg segment stack
db 255 dup (?)
sseg ends

code segment

include mymacro.asm
	
start:	
	mov ax, data
	mov ds, ax
	mov es, ax
	
	stdn msg1
	mov dx, offset str1
	mov ah, 0ah
	int 21h		; ввели строку с клавиатуры 
	
	stdn msg2
	symbol		; ввели символ, который меняем
	mov [syma], al
	
	stdn msg3
	symbol		; ввели символ, на который меняем
	mov [symb], al
	
	mov si,offset str1
	inc si
	mov al,[si]
	mov [size_],al
 
	xor cx,cx
	mov cl,[size_]

	replace syma, symb		;производим замену
	
	cld
	mov di,offset str1
	xor bx,bx
	mov bl,[size_]
	add di,bx
	add di,2
	mov si,offset line
	mov cx,3
	rep movsb				;копируем строку в es:di для вывода
 
	stdn msg4
	stdn str1+2		;вывод измененной строки
	exit_app

	code ends
	end start
