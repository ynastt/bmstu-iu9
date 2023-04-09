#!/bin/sh
flex lab15.l
gcc lex.yy.c -lfl
./a.out
