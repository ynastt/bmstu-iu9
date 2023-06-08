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