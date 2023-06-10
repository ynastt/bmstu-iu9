% "Лабораторная работа 3.2 «Форматтер исходных текстов»"
% 23 мая 2023 г.
% Яровикова Анастасия, ИУ9-61Б

# Цель работы
Целью данной работы является приобретение навыков использования генератора синтаксических анализаторов bison.

# Индивидуальный вариант
Слабый форматтер, определение процедуры в языке Visual Basic.

# Реализация
Грамматика и Лексическая структура
```
Proc ::= "Sub" Ident "(" Params ")" ENTER Statements "End" "Sub" 
Params ::= Param | Param "," ENTER Params 
Param ::= "ByVal" Ident "As" Type 
Type ::= "Integer" | "String" | "Boolean" | "Double" | "Long"
Statements ::= Statement Statements | eps

Statement ::= Assign_statement | DimStatement 
            | Loop_statement | Exit_statement |
            | COMMENT 

DimStatement ::= "Dim" Ident "As" Type ENTER
Assign_statement ::= Ident "=" Expr ENTER
Loop_statement ::= "For" Ident "As" Type "=" Expr "To" Expr ENTER Statements "Next" ENTER
Exit_statement ::= "Exit For" ENTER | "Exit Sub" ENTER

Expr ::= Ident | Literal | Expr Op Expr | eps
Op ::= "+" | "-" | "*" | "/" 
Literal ::= NUMBER | STRING | Boolean_literal 

Boolean_literal ::= "True" | "False"
Double_literal ::= Int_literal "." Int_literal

Ident ::= [A-Za-z][A-Za-z0-9]*
STRING ::= \"[A-Za-z][A-Za-z]*\"
NUMBER ::= [0-9]+(\.[0-9]+)?
COMMENT ::= '[^\n]*
ENTER ::= "\n" | eps
```

Лексер
```lex
%option reentrant noyywrap bison-bridge bison-locations
%option extra-type="struct Extra *"

/* Подавление предупреждений для -Wall */
%option noinput nounput

%{

#include <stdio.h>
#include <stdlib.h>
#include "lexer.h"
#include "parser.tab.h"  /* файл генерируется Bison’ом */

#define YY_USER_ACTION \
  { \
    int i; \
    struct Extra *extra = yyextra; \
    if (! extra->continued ) { \
      yylloc->first_line = extra->cur_line; \
      yylloc->first_column = extra->cur_column; \
    } \
    extra->continued = false; \
    for (i = 0; i < yyleng; ++i) { \
      if (yytext[i] == '\n') { \
        extra->cur_line += 1; \
        extra->cur_column = 1; \
      } else { \
        extra->cur_column += 1; \
      } \
    } \
    yylloc->last_line = extra->cur_line; \
    yylloc->last_column = extra->cur_column; \
  }

void yyerror(YYLTYPE *loc, yyscan_t scanner, long env[26], int i, int tab, bool user_tab, const char *message) {
    printf("Error (%d,%d): %s\n", loc->first_line, loc->first_column, message);
}
%}

%%
[\r ]+

[\n]+ return ENTER;

Sub return SUB;
ByVal return BYVAL;
As return AS;
Dim return DIM;
End return END;
If return IF;
For return FOR;
To return TO;
Then return THEN;
Exit return MY_EXIT;
Next return NEXT;
Return return MY_RETURN; 

=  return ASSIGN;
\+  return '+';
\-  return '-';
\*  return MUL;
\/  return DIV;
\( return LEFT_PAREN;
\) return RIGHT_PAREN;
\> return GREATER_THAN;
,   return COMMA;
True return MY_TRUE;
False return MY_FALSE;


[0-9]+(\.[0-9]+)? {
    yylval->number = atoi(yytext);
    return NUMBER;
}

[A-Za-z][A-Za-z0-9]*  {
    yylval->ident = yytext;
    return IDENT;
}

\"[A-Za-z][A-Za-z]*\"   {
    yylval->string = yytext;
    return STRING;
}

'[^\n]*   {
    yylval->string = yytext;
    return COMMENT;
}

%%

void init_scanner(FILE *input, yyscan_t *scanner, struct Extra *extra) {
    extra->continued = false;
    extra->cur_line = 1;
    extra->cur_column = 1;

    yylex_init(scanner);
    yylex_init_extra(extra, scanner);
    yyset_in(input, *scanner);
}

void destroy_scanner(yyscan_t scanner) {
    yylex_destroy(scanner);
}
```

Парсер
```c
%{
#include <stdio.h>
#include "lexer.h"
%}

%define api.pure
%locations
%lex-param {yyscan_t scanner}  /* параметр для yylex() */
/* параметры для yyparse() */
%parse-param {yyscan_t scanner}
%parse-param {long env[26]}
%parse-param {int tab}
%parse-param {bool user_tab}

%union {
    long number;
    char* string;
    char* ident;
    char* comment;
}

%left '+' '-'
%left MUL DIV
%token LEFT_PAREN RIGHT_PAREN COMMA END SUB BYVAL AS DIM ASSIGN MY_TRUE MY_FALSE ENTER
%token IF FOR TO NEXT THEN ELSE MY_RETURN MY_EXIT GREATER_THAN

%token <number> NUMBER
%token <comment> COMMENT
%token <ident> IDENT
%token <string> STRING

%{
int yylex(YYSTYPE *yylval_param, YYLTYPE *yylloc_param, yyscan_t scanner);
void yyerror(YYLTYPE *loc, yyscan_t scanner, long env[26], int tab, bool user_tab, const char *message);
%}

%{
void print_tabs(int tab) {
    for(int i = 0; i < tab; i++) {
        printf("  ");
    }
}


%}

%%
Program:
        Proc TestEnter Program
        |
        ;
Proc: 
        SUB {printf("Sub ");} IDENT[L] {printf("%s", $L);} LEFT_PAREN {printf("(");}
        Params RIGHT_PAREN {printf(") ");} StatementBlock END SUB {printf("End Sub\n"); tab = 0; user_tab = false;} 
        ;
Params:
        Param 
        | Param COMMA {printf(",");} TestEnter Params
        ;
TestEnter:
        ENTER {printf("\n"); user_tab = true; }
        | {printf(" "); user_tab = false;}
        ;        
Param:
        BYVAL {printf("ByVal ");} IDENT[L] {printf("%s ", $L);} 
          AS {printf("As ");} IDENT[R] {printf("%s", $R);} 
        ;     
StatementBlock:
        ENTER {printf("\n"); user_tab = true; tab += 1;} Statements 
        | {user_tab = false;} Statements 
Statements:
        Statement Statements
        |
        ;
Statement:
        AssignStatement
        | DimStatement
        | LoopStatement
        | ExitStatement
        | COMMENT {printf("%s\n", $1);}
        ; 
DimStatement:
        DIM 
        { 
            if (user_tab){
                print_tabs(tab);
                user_tab = false;     
            }
            printf("Dim ");
        } 
        IDENT[L] {printf("%s ", $L);} AS {printf("As ");} IDENT[R] {printf("%s", $R);} TestEnter      
        ;
AssignStatement:
        IDENT 
		{   
            if (user_tab){
                print_tabs(tab);
                user_tab = false;     
            }
            printf("%s ", $1);
		} 
		ASSIGN {printf("= ");} Expr TestEnter
        ;
LoopStatement:
        FOR 
		{ 
            if (user_tab){
                print_tabs(tab);
                user_tab = false;         
            }
            printf("For ");
            tab += 1;
		} 
        IDENT[L] {printf("%s ", $L);} 
        AS {printf("As ");} IDENT[R] {printf("%s ", $R);}
        ASSIGN {printf("= ");} Expr TO {printf("To ");} Expr TestEnter
        {
            if (user_tab){
                print_tabs(tab);
                user_tab = false;     
            }
		} 
		Statements NEXT 
		{
			tab -= 1; 
			if (user_tab){
                print_tabs(tab);
                user_tab = false;     
            }
			printf("Next ");
		} 
		TestEnter
        ;

ExitStatement:
        MY_EXIT 
        {
            if (user_tab){
                print_tabs(tab);
                user_tab = false;     
            }
        }
        FOR {printf("Exit For");} TestEnter 
        | MY_EXIT 
            {
            if (user_tab){
                print_tabs(tab);
                user_tab = false;     
            }
            }
            SUB {printf("Exit Sub");} TestEnter  
        ;  
                                    
Expr:
        IDENT {printf("%s", $1);}
        | Literal
        | Expr '+' { printf(" + "); } Expr  
        | Expr '-' { printf(" - "); } Expr  
        | Expr MUL { printf(" * "); } Expr 
        | Expr DIV { printf(" / "); } Expr
        ;
Literal:
        NUMBER {printf("%ld", $1);}
        | STRING {printf("%s", $1);}
        | MY_TRUE {printf("True ");}
        | MY_FALSE {printf("False ");}
        ;
            
%%

int main(int argc, char *argv[]) {
    FILE *input = 0;
    long env[26] = { 0 };
    int tab = 0;
    bool user_tab = false;
    yyscan_t scanner;
    struct Extra extra;

    if (argc > 1) {
        printf("Read file %s\n", argv[1]);
        input = fopen(argv[1], "r");
    } else {
        printf("No file in command line, use stdin\n");
        input = stdin;
    }

    init_scanner(input, &scanner, &extra);
    yyparse(scanner, env, tab, user_tab);
    destroy_scanner(scanner);

    if (input != stdin) {
        fclose(input);
    }

    return 0;
}
```
# Тестирование

Входные данные

```vb
Sub mySub(ByVal q As String, ByVal q2 As Integer)
  Dim d As Int
  Dim str As String 
  str = "hello" 
  str = q 
  d = 2 + 5
End Sub

Sub myExitTextSub(ByVal name As Integer)
    name = 5 + 3
    Exit Sub
    'hello there
    name = 1
End Sub

Sub name(ByVal n As Long, ByVal z As String)
  Dim q As Long 
  q = 3
For i As Long = 1 To 5
    For j As Long = 2 To 3
      n = n + q
    Exit Sub
      n = n - q 
      n = n + q
  Next    
  Next
End Sub

Sub    mySub(ByVal q As String, ByVal q2 As Integer,
ByVal c2 As Integer)  Dim d As Int
Dim str As String str="hello" 'inline comment
str = q
d=2+5           End Sub
```

Вывод на `stdout`

```vb
Read file input.txt
Sub  mySub(ByVal q As String, ByVal q2 As Integer) 
  Dim d As Int
  Dim str As String
  str = "hello"
  str = q
  d = 2 + 5
End Sub

Sub  myExitTextSub(ByVal name As Integer) 
  name = 5 + 3
  Exit Sub
  'hello there
  name = 1
End Sub

Sub  name(ByVal n As Long, ByVal z As String) 
  Dim q As Long
  q = 3
  For i As Long = 1To 5
    For j As Long = 2To 3
      n = n + q
      Exit Sub
      n = n - q
      n = n + q
    Next 
  Next 
End Sub

Sub  mySub(ByVal q As String, ByVal q2 As Integer,
ByVal c2 As Integer) Dim d As Int
Dim str As String str = "hello" 'inline comment
str = q
d = 2 + 5 End Sub
```

# Вывод
В ходе данной лабораторной работы был получен навык использования генератора 
синтаксических анализаторов biso
Разработанный слабый форматтер принимает на вход определения процедур на языке 
Visual Basic с нарушенным форматированием, а на выходе предоставляет 
отформатированный текст.
