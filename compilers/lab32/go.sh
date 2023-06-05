#!/bin/bash

flex lexer.l
bison -d -Wcounterexamples parser.y
gcc -o lab parser.tab.c lex.yy.c
./lab input.txt