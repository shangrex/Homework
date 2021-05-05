/*	Definition section */
%{
    #include "common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;

    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }


    /* Symbol table function - you can add new function if needed. */
    static void create_symbol(/* ... */);
    static void insert_symbol(/* ... */);
    static void lookup_symbol(/* ... */);
    static void dump_symbol(/* ... */);
%}

%error-verbose

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 */
%union {
    int i_val;
    float f_val;
    char *s_val;
    /* ... */
}

/* Token without return */
%token INT FLOAT BOOL STRING
%token SEMICOLON

/* Token with return, which need to sepcify type */
%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%token <s_val> STRING_LIT

/* Nonterminal with return, which need to sepcify type */

/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    : StatementList
;

StatementList
    : Statement 

Type
    : TypeName { $$ = $1; }
;

TypeName
    : INT
    | FLOAT
    | STRING
    | BOOL
;

Literal
    : INT_LIT {
        printf("INT_LIT %d\n", $<i_val>$);
    }
    | FLOAT_LIT {
        printf("FLOAT_LIT %f\n", $<f_val>$);
    }
;

Statement
    : DeclarationStmt
    | Block
    | IfStmt
    | LoopStmt
    | PrintStmt
;

DeclarationStmt
    : Type identifier [ "=" Expression ] SEMICOLON
    | Type identifier "[" Expression "]" SEMICOLON

SEMICOLON
    : ;
%%

/* C code section */
int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }

    yyparse();

	printf("Total lines: %d\n", yylineno);
    fclose(yyin);
    return 0;
}

static void create_symbol(){
    for(int i=0 ;i<=9 ; i++){
        for(int j=0 ;j<=19; j++){
            symbolTable[i][j].name="";
            symbolTable[i][j].kind="";
            symbolTable[i][j].type="";
            symbolTable[i][j].attribute="";
        }
        symbolIndex[i]=-1;
    }
}
static void insert_symbol(){

}
static void lookup_symbol(){

}

static void dump_symbol(){
    
    printf("> Dump symbol table (scope level: %d)\n", table->scope_level);
    printf("%-10s%-10s%-10s%-10s%-10s%s\n", "Index", "Name", "Type", "Address", "Lineno",
    "Element type");
    printf("%-10d%-10s%-10s%-10d%-10d",
    cur->index, cur->name,
    get_type_name(cur->type),
    cur->address, cur->lineno);
}
