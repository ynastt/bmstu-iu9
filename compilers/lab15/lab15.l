%option noyywrap bison-bridge bison-locations

%{
    #include <stdio.h>
    #include <stdlib.h>

    #define TAG_IDENT 1
    #define TAG_SYMBOL 2
    #define TAG_KEYWORD_Z 3
    #define TAG_KEYWORD_FOR 4
    #define TAG_KEYWORD_FORWARD 5
    #define TAG_ERROR 6

    char *tag_names[] = {
        "END_OF_PROGRAM", "IDENT", "SYMBOL", "KEYWORD_Z", "KEYWORD_FOR", "KEYWORD_FORWARD", "ERROR"
    };

    typedef struct Position Position; 

    struct Position {
        int line, pos, index;
    };

    void print_pos(Position * p) {
        printf("(%d,%d)", p->line, p->pos);
    }

    struct Fragment {
        Position starting, following;
    };

    typedef struct Fragment YYLTYPE;
    typedef struct Fragment Fragment; 

    void print_frag(Fragment *f) {
        print_pos(&(f->starting));
        printf(" - ");
        print_pos(&(f->following));
    }

    union Token {
        int symbolToken;
        int identToken;
        char *keywordToken;  
    };

    typedef union Token YYSTYPE;

    int continued;
    struct Position cur;

    #define YY_USER_ACTION           \
    {                                \
        int i;                       \
        if (!continued)              \
            yylloc->starting = cur;  \
        continued = 0;               \
        for (i = 0; i < yyleng; i++) \
        {                            \
            if (yytext[i] == '\n')   \
            {                        \
                cur.line++;          \
                cur.pos = 1;         \
            }                        \
            else                     \
                cur.pos++;           \
            cur.index++;             \
        }                            \
        yylloc->following = cur;     \
    }

    typedef struct {
        char** names;
        size_t codes;
        size_t size;
    } Dictionary;

    void initDict(Dictionary*  d, int initSize) {
        d->names = malloc(initSize * sizeof(char*));
        d->codes = 0;
        d->size = initSize;
    }

    void addName(Dictionary* d, char* name) {
        if (d->codes == d->size) {
            d->size *= 2;
            d->names = realloc(d->names, d->size * sizeof(char*));
        }
        d->names[d->codes++] = name;
    }

    int findName(Dictionary * d, char *name) {
        for (int i = 0; i < d->codes; i++) {
            if (strcmp(name, d->names[i]) == 0) {
                return i;
            }
        }
        return -1;
    }

    void clearDict(Dictionary * d) {
        free(d->names);
        d->names = NULL;
        d->codes = 0;
        d->size = 0;
    }

    Dictionary name_codes;
    Dictionary syms;  

    void init_scanner(char *program) {
        continued = 0;
        cur.line = 1;
        cur.pos = 1;
        cur.index = 0;
        initDict(&name_codes, 2);
        yy_scan_string(program);
    }

    void err(char *msg)
    {
        printf("Error ");
        print_pos(&cur);
        printf(": %s\n", msg);
    }
%}

SYMBOL          `([^0-9A-F]|\n|\'|\\[0-9A-F]{4})+`
KEYWORD_Z       (z)
KEYWORD_FOR     (for)
KEYWORD_FORWARD (forward)
IDENT           [a-eg-tw-yA-Z][\x00-\x7F]{0,8}[a-yA-Z]

%% 

[\n\t ]+

{IDENT}     {
                addName(&name_codes, yytext);
                yylval->identToken = findName(&name_codes, yytext);
                return TAG_IDENT;
            }

{KEYWORD_Z} {
                yylval->keywordToken = yytext;
                return TAG_KEYWORD_Z;
            }

{KEYWORD_FOR} {
                yylval->keywordToken = yytext;
                return TAG_KEYWORD_FOR;
            }

{KEYWORD_FORWARD} {
                yylval->keywordToken = yytext;
                return TAG_KEYWORD_FORWARD;
            }

{SYMBOL}    {
                addName(&syms, yytext);
                yylval->symbolToken = findName(&syms, yytext);
                return TAG_SYMBOL;
            }

<<EOF>>     return 0;

.           {
                err("unexpected character");
                return TAG_ERROR;
            }

%%

    int main() {
    int tag;
    YYSTYPE value;
    YYLTYPE coords;
    // union Token token;

    FILE *file = fopen("test1.txt", "r");
    if (file == NULL)
    {
        fputs("File not found", stderr);
        exit(1);
    }

    char buf[1001];
    char c;
    int i = 0;
    while((c = fgetc(file)) != EOF && i < 1000){
        buf[i++] = c;
    }
    fclose(file);
    buf[1000] = '\0';
    init_scanner(buf);
    do {
        tag = yylex(&value, &coords);
        if (tag != 0 && tag != TAG_ERROR) {
            printf("%s ", tag_names[tag]);
            print_frag(&coords);
            if (strcmp(tag_names[tag], "IDENT") == 0) {
                printf(": %d\n", value.identToken);
            } else if (strcmp(tag_names[tag], "SYMBOL") == 0) {
                printf(": %s\n", syms.names[value.symbolToken]);
            } else if (strcmp(tag_names[tag], "KEYWORD_Z") == 0) {
                printf(": %s\n", value.keywordToken);
            } else if (strcmp(tag_names[tag], "KEYWORD_FOR") == 0) {
                printf(": %s\n", value.keywordToken);
            } else if (strcmp(tag_names[tag], "KEYWORD_FORWARD") == 0) {
                printf(": %s\n", value.keywordToken);
            } else {
                printf(": \n");
            }
        }
    } while (tag != 0);

    clearDict(&name_codes);
    clearDict(&syms);
    return 0;
}
