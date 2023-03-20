stdn macro msg			; ввести строку
	mov ax, 0
	mov dx, offset msg
	mov ah, 09h
	int 21h		
endm

symbol macro			;ввод символа
	mov ah, 01h
	int 21h		
endm

replace macro sa, sb	;замена символа [sa] на [sb]
	rep1:
		inc si
		mov al,[si]
		cmp al,[syma]
		jne rep2
		mov al,[symb]
		mov [si],al
		
	rep2:
		loop rep1
endm	

exit_app macro			;завершение программы
	mov ah, 4ch
	int 21h
endm
