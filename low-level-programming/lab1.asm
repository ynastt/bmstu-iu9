assume CS:code, DS:data

data segment
a dw 5
b dw 7
c dw 3
d dw 4

data ends

sseg segment stack
db 100h dup (?)
sseg ends

code segment
start:      
;(a+b)/c + d + 3
;(5+7)/3 + 4 + 3 = 11
mov ax, data
mov ds, ax      ;указывает на data сегмент
mov ax, a      ;ax = 5
add ax, b      ;ax = 5 + 7 |12 = 0C
cwd             ;слово в двойное слово
div c          ;ax = 12/3 |4
add ax, d     ;ax = 4+4 |8
add ax, 3       ;ax = 8+3 |11 =0B

mov AX, 4C00h   ;завершение программы
int 21h
code ends
end start
