%option noyywrap bison-bridge bison-locations
%{
    #include <stdio.h>
    #include <stdlib.h>

    #define TAG_IDENT 1
    #define TAG_CHAR 2
    #define TAG_KEYWORD_Z 3
    #define TAG_KEYWORD_FOR 4
    #define TAG_KEYWORD_FORWARD 5
    #define TAG_ERROR 6

    char *tag_names[] = {
        "END_OF_PROGRAM", "IDENT", "CHAR", "KEYWORD_Z", "KEYWORD_FOR", "KEYWORD_FORWARD", "ERROR"
    };

    typedef struct Position Position;
    struct Position {
        int line, pos, index;
    };

    void print_pos(Position *p) {
        printf("(%d,%d)",p->line,p->pos);
    }

    struct Fragment {
        Position starting, following;
    };

    typedef struct Fragment YYLTYPE;
    typedef struct Fragment Fragment;

    void print_frag(Fragment* f) {
    	print_pos(&(f->starting));
    	printf("-");
    	print_pos(&(f->following));
    }

    union Token {
        int charCode;
        int ident_num;
        char *keywordToken; 
    };

    typedef union Token YYSTYPE;

    int continued;
    struct Position cur;
    #define YY_USER_ACTION {             \
        int i;                           \
        if (!continued)                  \
            yylloc->starting = cur;      \
        continued = 0;                   \
        for ( i = 0; i < yyleng; i++){   \
            if ( yytext[i] == '\n'){     \
                cur.line++;              \
                cur.pos = 1;             \
            }                            \
            else                         \
                cur.pos++;               \
            cur.index++;                 \
        }                                \
        yylloc->following = cur;         \
    } 


    void init_scanner (char *program){
        continued = 0;
        cur.line = 1;
        cur.pos = 1;
        cur.index = 0;
        yy_scan_string(program);
    }

    void err (char *msg){
        printf ("Error");
        print_pos(&cur);
        printf(":%s\n",msg);
    }

    int lexem_size;

    typedef struct{
        int size;
        char** names;
    } identTable;

    void create_ident_table(identTable * t){
        t->size = 0;
        t->names = NULL;
    }

    int add_ident(identTable* table, char* name){
        for (int i = 0; i < table->size; i++){
            if (strcmp(name, table->names[i]) == 0){
                return i;
            }
        }

        table->size++;
        if (table->size == 1){
            table->names = (char**)malloc(sizeof(char*) * (table->size));
        }
        else {
            table->names = (char**)realloc(table->names, sizeof(char*) * (table->size));
        }
        table->names[table->size - 1] = (char*)malloc(sizeof(char)*strlen(name));
        strcpy(table->names[table->size - 1], name);
        return table->size-1;
    }

    identTable table;
    
%}


KEYWORD_Z       (z)
KEYWORD_FOR     (for)
KEYWORD_FORWARD (forward)
IDENT           [a-zA-Z0-9]{2,10}
%x CHAR1 CHAR2 CHAR3

%%

[\n\t ]+

\'          	  	        {
						        BEGIN(CHAR1); 
						        continued = 1; 
                            }    

<CHAR1><<EOF>>              {
                                err("found EOF but \"'\" expected");
                                return 0;
                            }
<CHAR1,CHAR2>\n             {
                                err("newline in symbol");
                                BEGIN(0);
                                yylval->charCode = 0;
                                return TAG_CHAR;
                            }
<CHAR1>\\n                  {
                                yylval->charCode = '\n';
                                BEGIN(CHAR2);
                                continued = 1;                         
                            }
<CHAR1>\\'                  {
                                yylval->charCode = '\'';
                                BEGIN(CHAR2);
                                continued = 1;                         
                            }                     
<CHAR1>\\\\                 {
                                yylval->charCode = '\\';
                                BEGIN(CHAR2);
                                continued = 1;    
                            }
                          
<CHAR1>\'                   {
                                err("empty character literal");
                                BEGIN(0);
                                yylval->charCode = 0;
                                return TAG_CHAR;    
                            }                    
<CHAR1>\\0x                  {
                                yylval->charCode= yytext[0];
                                BEGIN(CHAR3);
                                continued = 1;
                            }
<CHAR3>[0-9a-zA-Z]*         {
                                int x;
                                sscanf(yytext, "%x", &x);
                                yylval->charCode = x;
                                BEGIN(CHAR2);
                                continued = 1;   
                            }                            
<CHAR1>.                    {
                                yylval->charCode = yytext[0];
                                BEGIN(CHAR2);
                                continued = 1;   
                            }
<CHAR2>\'                   {
                                BEGIN(0);
                                return TAG_CHAR;    
                            }                            
<CHAR2>[^\n\']*             {
                                err("too many charachters in literal");
                            }



{KEYWORD_Z}         {
                        yylval->keywordToken = yytext;
                        return TAG_KEYWORD_Z;
                    }

{KEYWORD_FOR}       {
                        yylval->keywordToken = yytext;
                        return TAG_KEYWORD_FOR;
                    }

{KEYWORD_FORWARD}   {
                        yylval->keywordToken = yytext;
                        return TAG_KEYWORD_FORWARD;
                    }

                      
{IDENT}               { 
                        yylval->ident_num = add_ident(&table, yytext);
                        return TAG_IDENT;
                      }

.                     err ("ERROR unknown symbol");

<<EOF>>               return 0;


%%

int main(){
    int tag;
    YYSTYPE value;
    YYLTYPE coords;
   	FILE *input;
	long size;
	char *buf;
	union Token token;
	{
        input = fopen("test1.txt","r");
        if (input == NULL) {
            fputs("File not found", stderr);
            exit(1);
        }
        fseek(input, 0, SEEK_END);
        size = ftell(input);
        rewind(input);

        buf = (char*)malloc(sizeof(char) * (size + 1));
        if (buf == NULL) {
            fputs("Memory error", stderr);
            exit(2);
        }    
        size_t n = fread(buf, sizeof(char), size, input);
        if (n != size) {
            fputs ("Reading error", stderr);
            exit (3);
        }
    }

    buf[size] = '\0';
    fclose (input);
    init_scanner(buf);
    create_ident_table(&table);
    do{ 
        tag = yylex(&value,&coords);
        if (tag == 0)
            break;

        printf("%s ",tag_names[tag]);
        print_frag(&coords);
        
        if (tag == TAG_KEYWORD_Z || tag == TAG_KEYWORD_FOR || tag == TAG_KEYWORD_FORWARD){
            printf(": %s", value.keywordToken); 
        } 
        
        if (tag == TAG_CHAR){
            printf(": %d", value.charCode);
        }

        if (tag == TAG_IDENT){
            printf(": %d", value.ident_num); 
        } 

        printf("\n");        
    } while (tag != 0); 
    
    free(table.names);
	free(buf);
    return 0;
}
