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

%union {
    long number;
    char* string;
    char* ident;
    char* comment;
}

%left '+' '-'
%token LEFT_PAREN RIGHT_PAREN COMMA END SUB BYVAL AS DIM ASSIGN MY_TRUE MY_FALSE ENTER

%token <number> NUMBER
%token <comment> COMMENT
%token <ident> IDENT
%token <string> STRING

%{
int yylex(YYSTYPE *yylval_param, YYLTYPE *yylloc_param, yyscan_t scanner);
void yyerror(YYLTYPE *loc, yyscan_t scanner, long env[26], const char *message);
%}

%{

int space = 0;
int first_space = 1;
void print_space() {
    for(int i = 0; i < space; i++) {
        printf("   ");
    }
}
%}

%%
Program:
        Proc Program
        |
        ;
Proc: 
        SUB {printf("Sub ");} Header Statements END SUB {printf("End Sub\n");}
        ;
Header:
        IDENT LEFT_PAREN {printf("%s(", $1);} Params RIGHT_PAREN {printf(")\n");} ENTER
        ;
Params:
        BYVAL IDENT AS IDENT {printf("ByVal %s As %s", $2, $4);} MoreParams
        |
        ;
MoreParams:
        COMMA BYVAL IDENT AS IDENT {printf(", ByVal %s As %s", $3, $5);} MoreParams
        |
        ;
Statements:
        Statement Statements
        | 
        ;
Statement:
        IDENT ASSIGN {printf("\t"); printf("%s ", $1);} Expr {printf("\n");} ENTER
        | {printf("\t");} DIM {printf("Dim ");} IDENT[L] {printf("%s ", $L);} AS {printf("As ");} IDENT[R] {printf("%s", $R);} ENTER {printf("\n");}
        | COMMENT {printf("\t"); printf("%s\n", $1);} ENTER
        | ENTER {printf("\n");}
        ;
Expr:
        IDENT {printf("%s ", $1);}
        | Literal
        | Expr '+' { printf("+ "); } Expr  
        | Expr '-' { printf("- "); } Expr  
        ;
Literal:
        NUMBER {printf("%ld ", $1);}
        | STRING {printf("%s ", $1);}
        | MY_TRUE {printf("True ");}
        | MY_FALSE {printf("False ");}
        ;
            
%%



int main(int argc, char *argv[]) {
    FILE *input = 0;
    long env[26] = { 0 };
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
    yyparse(scanner, env);
    destroy_scanner(scanner);

    if (input != stdin) {
        fclose(input);
    }

    return 0;
}