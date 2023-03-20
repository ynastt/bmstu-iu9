
macro replace str, char1, char2	
{
	mov si, str
	mov di, char1
	mov bl, byte [di]
	mov di, char2
	mov dl, byte [di]
	mov cl, 19
	rep1:
		inc si
		mov al, byte [si]
		cmp al, bl
		jne rep2
		mov al, dl
		mov byte [si], al
	dec cx
	cmp cx, 0
	je ex1
	rep2:
		loop rep1
	ex1:
}	









				
	
