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


 



    typedef struct Symbols {
        char* index;
        char* name;
        char* type;
        int address;
        int lineno;
        char* element_type;
    } Symbol;

    Symbol symboltable[10][20];
    // store each row variable count of symboltable  
    int symbol_index[10];
    // store current scope number
    // if wanna print dump then use printDump=1
    // lex will print dump and decrement scope
    // if only wanna decrement scope just -- 
    int scope_number = 0;
    int index_number = 0;
    int print_dump = 0;
    static int num_address = 0;


       /* Symbol table function - you can add new function if needed. */
    static void create_symbol();
    static void insert_symbol(char* name, char* type, int scope_number, int index_number);
    static int check_symbol(char* name);
    static Symbol lookup_symbol(char* name);
    static void dump_symbol();
%}

// %error-verbose

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
%token ADD SUB MUL QUO REM INC DEC GTR LSS GEQ LEQ EQL NEQ NOT AND OR
%token ASGN
%token SEMICOLON
%token PRINT LPAREN RPAREN RBRACK LBRACK


/* Token with return, which need to sepcify type */
%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%token <s_val> STRING_LIT
%token <s_val> BOOL_LIT
%token <s_val> IDENT


/* Nonterminal with return, which need to sepcify type */
%type <s_val> TypeName
%type <s_val> Type
%type <s_val> DeclarationStmt
%type <s_val> Literal INCDEC_stmt Paren_stmt Unary_stmt MQR_Arithmetic_stmt AS_Arithmetic_stmt
%type <s_val> Compare_Arithmetic_stmt AND_Arithmetic_stmt Arithmetic_stmt Execution_stmt
/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    : Program StatementList 
    | StatementList 
;

StatementList
    : Statement 
;

Type
    : TypeName 
;

TypeName
    : INT { $$ = "int"; }
    | FLOAT { $$ = "float"; }
    | STRING { $$ = "string"; }
    | BOOL { $$ = "bool"; }
;

Literal
    : INT_LIT {
        printf("INT_LIT %d\n", $<i_val>$);
        $$ = "int";
    }
    | FLOAT_LIT {
        printf("FLOAT_LIT %f\n", $<f_val>$);
        $$ = "float";
    }
    | STRING_LIT {
        printf("STRING_LIT %s\n", $<s_val>$);
        $$ = "string";
    }
    | BOOL_LIT {
        printf("%s\n", $<s_val>$);
        $$ = "bool";
    }
    | IDENT {
        Symbol table1 = lookup_symbol($1);
        printf("IDENT (name=%s, address=%d)\n", table1.name, table1.address);
        $$ = table1.type;
    }
;

Statement
    : DeclarationStmt SEMICOLON
    | Expression SEMICOLON
;


DeclarationStmt
    : Type IDENT {
        if(check_symbol($2) == 0){
            insert_symbol($2, $1, scope_number, ++symbol_index[scope_number]);
        };
        $$ = $1;
    }
    | Type IDENT ASGN Expression
;

Expression
    : Assignment_stmt
    | Arithmetic_stmt
    | Execution_stmt
    | INCDEC_stmt

;

INCDEC_stmt
    : Literal INC {
        printf("INC\n");
    }
    | Literal DEC {
        printf("DEC\n");
    }

Assignment_stmt
    : IDENT ASGN Arithmetic_stmt 
;

Arithmetic_stmt
    : Arithmetic_stmt OR AND_Arithmetic_stmt {
        printf("OR\n");
        $$ = "bool";
    }
    | AND_Arithmetic_stmt
;

AND_Arithmetic_stmt
    : AND_Arithmetic_stmt AND Compare_Arithmetic_stmt {
        printf("AND\n");
        $$ = "bool";
    }
    | Compare_Arithmetic_stmt
;

Compare_Arithmetic_stmt
    : Compare_Arithmetic_stmt GTR AS_Arithmetic_stmt {
        printf("GTR\n");
        $$ = "bool";
    }
    | Compare_Arithmetic_stmt LSS AS_Arithmetic_stmt {
        printf("LSS\n");
        $$ = "bool";
    }
    | Compare_Arithmetic_stmt GEQ AS_Arithmetic_stmt {
        printf("GEQ\n");
        $$ = "bool";
    }
    | Compare_Arithmetic_stmt LEQ AS_Arithmetic_stmt {
        printf("LEQ\n");
        $$ = "bool";
    }
    | Compare_Arithmetic_stmt EQL AS_Arithmetic_stmt {
        printf("EQL\n");
        $$ = "bool";
    }
    | Compare_Arithmetic_stmt NEQ AS_Arithmetic_stmt {
        printf("NEQ\n");
        $$ = "bool";
    }
    | AS_Arithmetic_stmt
;

AS_Arithmetic_stmt
    : AS_Arithmetic_stmt ADD MQR_Arithmetic_stmt {
        printf("ADD\n");
    }
    | AS_Arithmetic_stmt SUB MQR_Arithmetic_stmt {
        printf("SUB\n");
    }
    | MQR_Arithmetic_stmt
;

MQR_Arithmetic_stmt
    : MQR_Arithmetic_stmt MUL Unary_stmt {
        printf("MUL\n");
    }
    | MQR_Arithmetic_stmt QUO Unary_stmt {
        printf("QUO\n");
    }
    | MQR_Arithmetic_stmt REM Unary_stmt {
        printf("REM\n");
    }
    | Unary_stmt

;

Unary_stmt
    : ADD Unary_stmt {
        printf("POS\n");
        $$ = $2;
    }
    | SUB Unary_stmt {
        printf("NEG\n");
        $$ = $2;
    }
    | NOT Unary_stmt {
        printf("NOT\n");
        $$ = $2;
    }
    | Paren_stmt
;

Paren_stmt
    : LPAREN Arithmetic_stmt RPAREN {
        $$ = $2;
    }
    | Literal
;

Execution_stmt
    : PRINT LPAREN Arithmetic_stmt RPAREN {
        printf("PRINT %s\n", $3);
        $$ = $3;
    }
;


%%

/* C code section */
int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    
    create_symbol();

    yyparse();
    
    dump_symbol();

	printf("Total lines: %d\n", yylineno);
    fclose(yyin);
    return 0;
}

static void create_symbol(){
    for(int i = 0 ;i <= 9 ; i++){
        for(int j = 0 ;j <= 19; j++){
            symboltable[i][j].index = "";
            symboltable[i][j].name = "";
            symboltable[i][j].type = "";
            symboltable[i][j].address = -1;
            symboltable[i][j].type = "";
            symboltable[i][j].element_type = "-";
            symboltable[i][j].lineno = -1;
        }
        symbol_index[i] = -1;
    }
}

static void insert_symbol(char* name, char* type, int scope_number, int index_number){
    symboltable[scope_number][index_number].name = name;
    symboltable[scope_number][index_number].type = type;
    symboltable[scope_number][index_number].address = num_address++;
    symboltable[scope_number][index_number].lineno = yylineno;
    printf("> Insert {%s} into symbol table (scope level: %d)", name, scope_number);
    printf("\n");
}

static int check_symbol(char* name){
    for(int i = 0; i <= symbol_index[scope_number]; i++){
        //already exist name
        if(strcmp(name, symboltable[scope_number][i].name) == 0){
            return 1;
        }
    }
    return 0;
}

static Symbol lookup_symbol(char* name){
    for(int i = 0; i <= symbol_index[scope_number]; i++){
        //already exist name
        if(strcmp(name, symboltable[scope_number][i].name) == 0){
            return symboltable[scope_number][i];
        }
    }
    Symbol tmp;
    return  tmp;
}

static void dump_symbol(){
    // printf("scope%d\n", scope_number);
    for (int s = 0; s <= scope_number; s++){
        printf("> Dump symbol table (scope level: %d)\n", s);
        printf("%-10s%-10s%-10s%-10s%-10s%s\n", "Index", "Name", "Type", "Address", "Lineno","Element type");
        if(symbol_index[s] == -1){
            continue;
        }
        // printf("symbol index %d\n", symbol_index[s]);
        for(int i = 0; i <= symbol_index[s]; i++){
            printf("%-10d%-10s%-10s%-10d%-10d%s",
                i, symboltable[s][i].name,
                symboltable[s][i].type,
                symboltable[s][i].address, 
                symboltable[s][i].lineno,
                symboltable[s][i].element_type);
            printf("\n");
        }
    }
}
