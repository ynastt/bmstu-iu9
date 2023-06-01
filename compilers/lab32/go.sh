#!/bin/bash

flex lexer.l
bison -d parser.y
gcc -o lab parser.tab.c lex.yy.c
./lab input.txt