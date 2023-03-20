; lab4
assume cs: code, ds: data

data segment
string1 db 25, ?, 25 dup (0) ; число 1 
string2 db 25, ?, 25 dup (0) ; число 2
string11 db 25, ?, 25 dup (0) 
string22 db 25, ?, 25 dup (0) 
string3 db 50, 50 dup (0)    ;для +
string33 db 50, 50 dup (0)      
string4  db 50, 50 dup (0)   ; для -
string44 db 50, 50 dup (0)   
string5  db 50, 50 dup (0)   ; для *
string55 db 50, 50 dup (0) 
msg1 db 0ah, 0dh, "Enter first numebr: $"
msg2 db 0ah, 0dh, "Enter second number: $"	
s db 0ah, 0dh, "THE BASIS OF SYSTEM IS 10 $"
sss db 0ah, 0dh, "THE BASIS OF SYSTEM IS 16 $"	
msg3 db 0ah, 0dh, "Result of addition in dec: $"
msg33 db 0ah, 0dh, "Result of addition in hex: $"
msg4 db 0ah, 0dh, "Result of substraction in dec: $"
msg44 db 0ah, 0dh, "Result of substraction in hex: $"
msg5 db 0ah, 0dh, "Result of multiplication in dec: $"
msg55 db 0ah, 0dh, "Result of multiplication in hex: $"
line db 0ah, 0dh, '$'
data ends

sseg segment stack
db 255 dup (?)
sseg ends

code segment

stdn macro m, buf
	mov ax, 0
	mov dx, offset m
	mov ah, 09h
	int 21h		; вывели просьбу ввести строку
	
	mov dx, offset buf
	mov ah, 0ah
	int 21h		; ввели строку с клавиатуры в буфер
endm

fromString proc ;перевод из ascii 
	pop bp ;адрес возврата
	pop di ;строка (1 байт -макс размер, 2 - реальный размер, 3 - сама строка)
	mov cx, 0
	mov cl, [di] ; след блок будет выполнен <длина строки> раз
	add di, 1
	cycle:
		cmp byte ptr [di], 48
		jb exit				; меньше '0' - недопустимый символ
		cmp byte ptr [di], 57
		ja inhex				; больше '9' - пытаемся перевести в 16сс
		sub byte ptr [di], 30h		; перевод в 10сс
		jmp incr
		inhex: 	
			cmp byte ptr [di], 65
			jb exit				; меньше 'A' - недопустимый символ 
			cmp byte ptr [di], 70			
			ja lower			; больше 'F' - проверка на нижний регистр
			sub byte ptr [di], 55	;перевод в значения a - 10,..., f - 15 для 16сс
			jmp incr
		lower: 	
			cmp byte ptr [di], 97
			jb exit				; меньше 'a' - выход 
			cmp byte ptr [di], 102
			ja exit				; больше 'f' - выход 
			sub byte ptr [di], 87	;перевод в значения a - 10,..., f - 15 для 16сс	
		incr: 
			inc di			
			dec cx
			or cx, cx
			jne cycle
			jmp next
	exit: 
		mov ah, 4ch
		int 21h
	next: 
	mov byte ptr [di], '$'	
	push bp
	ret	
fromString endp

toString proc ;перевод в ascii 
	pop bp
	pop di
	mov cx, 0
	mov cl, [di]
	add di, 1
	mov dx, di
	makeStr:
		cmp byte ptr [di], 9		; больше 9, значит буква
		ja letter
		add byte ptr [di], 48 		;переводим в символ	
		jmp nxt
		letter:
			add byte ptr [di], 55 	; a(10) -> a(65)
		nxt:
			inc di				
			dec cx				
			or cx, cx
			jne makeStr
	mov byte ptr [di], '$'			
	mov ah, 09h
	int 21h	
	mov dx, offset line
	int 21h
	push bp
	ret
toString endp

addition proc
	push bp			; сохраняем содержимое bp
	mov bp, sp		;запоминаем текующую вершину стека
	
	mov di, [bp+4]		; указатель на 1 число
	mov si, [bp+6]		; указатель на 2 число
	mov bx, [bp+8]		; указатель на результат сложения

	mov cx, 0
	mov dx, 0
	mov cl, [di]	; длина 1 числа
	mov dl, [si]	; длина 2 числа
	add di, cx 		; перемещаемся в младщий разряд 1 числа
	add si, dx		; -//-
	cmp dx, cx		; сравниваем какое число длиннее
	ja larger		; 2 длиннее 1	
		xchg cx, dx		; если 1 длиннее 2, то меняем cx - длина 2 строки (меньшей длины)
		xchg  di, si	; di - указатель на 2 строку (меньшей длины)
	larger:
		sub dx, cx		; в dx = dx - cx - столько цифр останется переместить в результат помимо cx 
	add bx, [bx]	; перемещаемся в младший разряд строки - результата сложения ([bx] - длина) 
	push dx
	mov dl, [bp + 10]		; система счисления
	xor ax, ax		;обнуляем ax
	sumcycle:
		or cx, cx	;если дошли до старшего разряда - выходим
		je then
		add al, byte ptr [di]	;складываем порязрядно
		add al, byte ptr [si]
		div dl				; в al - десяток для переноса в след разряд (старший разряд), в ah - младший разряд результата
		mov byte ptr [bx], ah ;записываем младший разряд
		xor ah, ah		; обнуляем т.к. больше не нужен
		dec di	;уменьшаем для перехода к след. разряду
		dec si
		dec cx
		dec bx
		jmp sumcycle
	then: 
		pop cx
	sumlast:	;прописываем старшие рязряды (есть у одного числа, нет у другого)
		xor ah, ah
		or cx, cx
		je addexit
		add al, byte ptr [si]
		div dl		
		mov byte ptr [bx], ah
		xor ah, ah		
		dec si
		dec cx
		dec bx
		jmp sumlast
	addexit: 
	mov byte ptr [bx], al		; последний перенос в старший разряд, если есть
	mov sp, bp ; вершина стека 
	pop bp     ;адрес возврата
	ret 6	   ;удаляем 6 байт из стека при возврате из процедуры
addition endp

substraction proc
	push bp			; сохраняем содержимое bp
	mov bp, sp		;запоминаем текующую вершину стека
	
	mov di, [bp+4]		; указатель на 1 число
	mov si, [bp+6]		; указатель на 2 число
	mov bx, [bp+8]		; указатель на результат сложения

	mov cx, 0
	mov dx, 0
	mov cl, [di]	; длина 1 числа
	mov dl, [si]	; длина 2 числа
	add di, cx 		; перемещаемся в младщий разряд 1 числа
	add si, dx		; -//-
	
	sub cx, dx		 
	add bx, [bx]	; перемещаемся в младший разряд строки - результата сложения ([bx] - длина) 
	
	push cx
	xor ax, ax		
	xor cx, cx		
	subcycle:
		or dx, dx	;если дошли до старшего разряда - выходим
		je thensub
		mov al, byte ptr [di]	
		cmp al, cl
		jnb subelse
		add al, [bp+10]
		dec al
		jmp subt
		subelse:
			sub al, cl
			xor cx, cx
		subt:
			cmp al, byte ptr [si]
			jnb ssub
			add al, [bp+10]
			mov cx, 1
		ssub:
			sub al, byte ptr [si]
		mov byte ptr [bx], al ;записываем младший разряд
		dec di	;уменьшаем для перехода к след. разряду
		dec si
		dec dx
		dec bx
		jmp subcycle
	thensub: 
		pop dx
	sublast:	
		xor ah, ah
		or dx, dx
		je subexit
		mov al, byte ptr [di]
		cmp al, cl
		jnb subb
		add al, [bp+10]
		dec al
		jmp subs
		subb:
			sub al, cl
			xor cx, cx
		subs:	
			mov byte ptr [bx], al
			xor ah, ah		
			dec di
			dec dx
			dec bx
		jmp sublast
	subexit: 
	mov sp, bp ; вершина стека 
	pop bp     ;адрес возврата
	ret 6	   ;удаляем 6 байт из стека при возврате из процедуры
substraction endp

multiplication proc
	push bp			; сохраняем содержимое bp
	mov bp, sp		;запоминаем текующую вершину стека

	mov di, [bp+4]		; указатель на 1 число
	mov si, [bp+6]		; указатель на 2 число
	mov bx, [bp+8]		; указатель на результат умножения

	mov cx, 0
	mov dx, 0
	mov cl, [di]	; длина 1 числа
	mov dl, [si]	; длина 2 числа
	add di, cx 		; перемещаемся в младщий разряд 1 числа
	add si, dx		; -//-
	cmp cx, dx		; сравниваем какое число длиннее	
	ja largr		; 1 большей длины - ок	
		xchg cx, dx		; если 1 короче 2, то меняем cx - длина 1 строки (большей длины)
		xchg  di, si	; di - указатель на 2 строку (меньшей длины)
	largr: 
	add bx, [bx]	; перемещаемся в младший разряд строки - результата умножения ([bx] - длина) 
	xor ax, ax		;обнуляем ax
	
	mulcycle:
		or dx, dx	;если дошли до старшего разряда 2 множителя- выходим
		je mulexit
		;запоминаем в стеке адерсы концов строк и освобождаем регистры для дальнейших оперраций
		push bx	
		push di	
		push si			
		push cx			
		push dx			
		;обнуляем		
		xor dx, dx ; будем хранить переносы (dl, dh) в старший разряд, изначально он нулевой
		xor ax, ax
		mulccl:
			or cx, cx ; если дошли до конца 1 множителя - выходим
			je eout
			mov al, byte ptr [di]	;умножаем 
			mul byte ptr [si]	;
			add al, dh		;+ перенос
			div byte ptr [bp+10]	;делим на основание системы счисления, в al - десяток для переноса в след разряд (старший разряд), в ah - младший разряд результата
			mov dh, al				
			mov al, byte ptr [bx]	 
			add al, ah		
			add al, dl		
			xor ah, ah
			div byte ptr [bp+10]	
			mov [bx], ah
			mov dl, al	
			dec di
			dec cx
			dec bx
			jmp mulccl
		eout:
			; складываем  после умножения 1 числа на очередную цифру 2 числа
			xor ax, ax
			mov al, byte ptr [bx]
			add al, dh		
			add al, dl		
			div byte ptr [bp+10]	
			mov byte ptr [bx], ah
			mov byte ptr [bx-1], al

			pop dx			
			pop cx			
			pop si			
			pop di			
			pop bx	
			
			dec bx			
			dec si			
			dec dx
		jmp mulcycle	
			
	mulexit:
		mov sp, bp ; вершина стека 
		pop bp     ;адрес возврата
		ret 6	   ;удаляем 6 байт из стека при возврате из процедуры
multiplication endp

start:	
	mov ax, data
	mov ds, ax
	
	lea dx, s	;10 CC
	mov ah, 09h
	int 21h
	
	stdn msg1, string1
	stdn msg2, string2
	
	mov dx, offset string1 + 1
	push dx		
	call fromString	
	mov dx, offset string2 + 1
	push dx		
	call fromString
	;сложение
	push 10
	push offset string3
	push offset string2 + 1
	push offset string1 + 1
	call addition
	
	lea dx, msg3
	mov ah, 09h
	int 21h	
	push offset string3
	call toString
	;вычитание
	push 10
	push offset string4
	push offset string2 + 1
	push offset string1 + 1
	call substraction
	
	lea dx, msg4
	mov ah, 09h
	int 21h	
	push offset string4
	call toString
	;умножение
	push 10
	push offset string5
	push offset string1 + 1
	push offset string2 + 1
	call multiplication
	
	lea dx, msg5
	mov ah, 09h
	int 21h	
	push offset string5
	call toString	
	
	;16 CC
	lea dx, sss
	mov ah, 09h
	int 21h
	;сложение
	stdn msg1, string11
	stdn msg2, string22
	
	mov dx, offset string11 + 1
	push dx		
	call fromString
		
	mov dx, offset string22 + 1
	push dx		
	call fromString
	;сложение
	push 16
	push offset string33
	push offset string22 + 1
	push offset string11 + 1
	call addition
	
	lea dx, msg33
	mov ah, 09h
	int 21h	
	push offset string33
	call toString
	;вычитание
	push 16
	push offset string44
	push offset string22 + 1
	push offset string11 + 1
	call substraction
	
	lea dx, msg44
	mov ah, 09h
	int 21h	
	push offset string44
	call toString
	;умножение
	push 16
	push offset string55
	push offset string11 + 1
	push offset string22 + 1
	call multiplication
	
	lea dx, msg55
	mov ah, 09h
	int 21h	
	push offset string55
	call toString
	
	mov ah, 4ch
	int 21h

	code ends
	end start
