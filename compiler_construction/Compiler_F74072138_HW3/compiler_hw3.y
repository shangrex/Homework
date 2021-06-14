/*	Definition section */
%{
    #include "common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;

    #define codegen(...) \
        do { \
            for (int i = 0; i < INDENT; i++) { \
                fprintf(fout, "\t"); \
            } \
            fprintf(fout, __VA_ARGS__); \
        } while (0)

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;
    
    /* Other global variables */
    FILE *fout = NULL;
    bool HAS_ERROR = false;
    int INDENT = 0;
    
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
    Symbol tmp_symboltable[20];
    int tmp_address = 0;
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
    int label = 0;
    int scope_lable_in[10];
    int scope_lable_out[10];
    char *tmp_name;

       /* Symbol table function - you can add new function if needed. */
    static void create_symbol();
    static void insert_symbol(char* name, char* type, int scope_number, int index_number, char* element_type);
    static int check_symbol(char* name);
    static Symbol lookup_symbol(char* name);
    static void dump_symbol();
%}

/* %error-verbose */

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
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN
%token ADD SUB MUL QUO REM INC DEC GTR LSS GEQ LEQ EQL NEQ NOT AND OR
%token ASGN WHILE IF ELSE ELIF FOR
%token SEMICOLON NEWLINE
%token PRINT LPAREN RPAREN RBRACK LBRACK LBRACE RBRACE

/* Token with return, which need to sepcify type */
%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%token <s_val> STRING_LIT
%token <s_val> BOOL_LIT
%token <s_val> IDENT

/* Nonterminal with return, which need to sepcify type */
%type <s_val> TypeName
%type <s_val> Type Const
%type <s_val> DeclarationStmt
%type <s_val> Literal INCDEC_stmt Paren_stmt Unary_stmt MQR_Arithmetic_stmt AS_Arithmetic_stmt
%type <s_val> Compare_Arithmetic_stmt AND_Arithmetic_stmt Arithmetic_stmt Execution_stmt  Brak_stmt PIDENT
%type <s_val> Tag_while AIDENT
/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    : Program StatementList 
    | StatementList 
;

StatementList
    : Statement {
    for(int i = 0;i < tmp_address; i++){
            Symbol x;
            x.name="";
            x.type="";
            x.address = 0;
            x.lineno = 0;
            x.element_type = "";
            tmp_symboltable[i] = x;
        }
        tmp_address = 0;
    
    }

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
    : Const
    | PIDENT 
    | LPAREN Type RPAREN FLOAT_LIT {
        printf("FLOAT_LIT %f\n", $4);

        char * t;
        if(strcmp($2, "float") == 0){
            t = "F";
        }
        else if(strcmp($2, "int") == 0){
            t = "I";
        }
        printf("F to %s\n", t);
        $$ = $2;
    }
    | LPAREN Type RPAREN INT_LIT {
        printf("INT_LIT %d\n", $4);

        char * t;
        if(strcmp($2, "float") == 0){
            t = "F";
        }
        else if(strcmp($2, "int") == 0){
            t = "I";
        }
        printf("I to %s\n", t);
        $$ = $2;
    }
    | LPAREN Type RPAREN IDENT {
        Symbol table1 = lookup_symbol($4);
        printf("IDENT (name=%s, address=%d)\n", table1.name, table1.address);

        char * f;
        char * t;
        if(strcmp($2, "float") == 0){
            t = "F";
        }
        else if(strcmp($2, "int") == 0){
            t = "I";
        }
        if(strcmp(table1.type, "float") == 0){
            f = "F";
        }
        else if(strcmp(table1.type, "int") == 0){
            f = "I";
        }
        printf("%s to %s\n", f, t);
        $$ = $2;
    }
;

Const
    : INT_LIT {
        printf("INT_LIT %d\n", $<i_val>$);
        codegen("ldc %d\n", $<i_val>$);
        $$ = "int";
    }
    | FLOAT_LIT {
        printf("FLOAT_LIT %f\n", $<f_val>$);
        codegen("ldc %f\n", $<f_val>$);
        $$ = "float";
    }
    | '"' STRING_LIT '"' {
        printf("STRING_LIT %s\n", $2);
        codegen("ldc \"%s\"\n", $2);
        $$ = "string";
    }
    | BOOL_LIT {
        printf("%s\n", $<s_val>$);
        if(strcmp($<s_val>$, "TRUE") == 0){
            codegen("iconst_1\n");
        }
        if(strcmp($<s_val>$, "FALSE") == 0){
            codegen("iconst_0\n");            
        }
        $$ = "bool";
    }

PIDENT
    : IDENT {
        Symbol table1 = lookup_symbol($1);

        if(strcmp(table1.name, "") == 0){
            printf("error:%d: undefined: %s\n", yylineno, $1);
        }
        else {
            printf("IDENT (name=%s, address=%d)\n", table1.name, table1.address);
            if(strcmp(table1.type, "int") == 0){
                codegen("iload %d\n", table1.address);
            }
            if(strcmp(table1.type, "float") == 0){
                codegen("fload %d\n",table1.address);
            }
            if(strcmp(table1.type, "string") == 0){
                codegen("aload %d\n",table1.address);
            }
            if(strcmp(table1.type, "bool") == 0){
                codegen("iload %d\n",table1.address);

            }
        }
        if(strcmp(table1.type, "array") == 0){
            $$ = table1.element_type;
        }
        else {
            $$ = table1.type;
        }
        tmp_symboltable[tmp_address++] = table1;
    }
;

AIDENT
    : IDENT {
        Symbol table1 = lookup_symbol($1);

        if(strcmp(table1.name, "") == 0){
            printf("error:%d: undefined: %s\n", yylineno, $1);
        }
        else {
            printf("IDENT (name=%s, address=%d)\n", table1.name, table1.address);
            tmp_name = table1.name;
            // if(strcmp(table1.type, "int") == 0){
            //     codegen("istore %d\n", table1.address);
            // }
            // if(strcmp(table1.type, "float") == 0){
            //     codegen("fstore %d\n",table1.address);
            // }
            // if(strcmp(table1.type, "string") == 0){
            //     codegen("astore %d\n",table1.address);
            // }
            // if(strcmp(table1.type, "bool") == 0){
            //     codegen("istore %d\n",table1.address);

            // }
        }
        if(strcmp(table1.type, "array") == 0){
            $$ = table1.element_type;
        }
        else {
            $$ = table1.type;
        }
        tmp_symboltable[tmp_address++] = table1;
    }
;

Statement
    : DeclarationStmt SEMICOLON
    | Expression 
    | Compound_stmt

;


DeclarationStmt
    : Type IDENT {
        if(check_symbol($2) == 0){
            insert_symbol($2, $1, scope_number, ++symbol_index[scope_number], "");
            Symbol table1 = lookup_symbol($2);
            if(strcmp(table1.type, "int") == 0){
                codegen("ldc 0\n");
                codegen("istore %d\n", table1.address);
            }
            if(strcmp(table1.type, "float") == 0){
                codegen("ldc 0.0\n");
                codegen("fstore %d\n", table1.address);
            }

        }
        else {
            Symbol table1 = lookup_symbol($2);
            printf("error:%d: %s redeclared in this block. previous declaration at line %d\n", yylineno, $2, table1.lineno);
        }
        $$ = $1;
    }
    | Type IDENT ASGN Arithmetic_stmt {
        if(check_symbol($2) == 0){
            insert_symbol($2, $1, scope_number, ++symbol_index[scope_number], "");
            Symbol table1 = lookup_symbol($2);
            if(strcmp(table1.type, "int") == 0){
                codegen("istore %d\n", table1.address);
            }
            if(strcmp(table1.type, "float") == 0){
                codegen("fstore %d\n", table1.address);
            }
            if(strcmp(table1.type, "string") == 0){
                codegen("astore %d\n", table1.address);
            }
            if(strcmp(table1.type, "bool") == 0){
                codegen("istore %d\n", table1.address);
            }
        };
    }
    | Type IDENT LBRACK Arithmetic_stmt RBRACK {
        if(check_symbol($2) == 0){
            insert_symbol($2, "array", scope_number, ++symbol_index[scope_number], $1);
        };
        $$ = $1;
    }
;

Expression
    : Assignment_stmt SEMICOLON
    | Arithmetic_stmt SEMICOLON
    | Execution_stmt SEMICOLON
    | INCDEC_stmt SEMICOLON
    | Loop_stmt 
    | If_stmt
    | For_stmt
;

Compound_stmt
    :  LBRACE RBRACE
    | LBRACE Program RBRACE {
        dump_symbol();
        if(scope_number > 0) scope_number--;
        else {
            printf("negative scope number\n");
        }
        codegen("goto label%d\n", scope_lable_in[scope_number]);
        codegen("label%d :\n", scope_lable_out[scope_number]);
    }
;

For_stmt
    : FOR LPAREN Assignment_stmt SEMICOLON  Arithmetic_stmt SEMICOLON INCDEC_stmt RPAREN {
        scope_number++;
    }
;

If_stmt
    : IF LPAREN Arithmetic_stmt RPAREN {
        if(strcmp($3, "bool") != 0){
           printf("error:%d: non-bool (type %s) used as for condition\n", yylineno+1, $3);
        }

        scope_number++;
    }
    | ELIF LPAREN Arithmetic_stmt RPAREN {
        if(strcmp($3, "bool") != 0){
           printf("error:%d: non-bool (type %s) used as for condition\n", yylineno+1, $3);
        }
        scope_number++;
    }
    | ELSE {
        scope_number++;
    }
;

Loop_stmt
    : Tag_while LPAREN Arithmetic_stmt RPAREN {
        if(strcmp($3, "bool") != 0){
           printf("error:%d: non-bool (type %s) used as for condition\n", yylineno+1, $3);
        }
        codegen("ifeq label%d\n", label);
        scope_lable_out[scope_number] = label;
        label ++;
        scope_number++; 
    }
;

Tag_while
    : WHILE {
        codegen("label%d :\n", label);
        scope_lable_in[scope_number] = label;
        label++;
    }
;

INCDEC_stmt
    : Literal INC {
        printf("INC\n");
        if(strcmp($1, "int") == 0){
            codegen("ldc 1\n");
            codegen("iadd\n");
            codegen("istore %d\n", tmp_symboltable[0].address);
        }
        if(strcmp($1, "float") == 0){
            codegen("ldc 1.0\n");
            codegen("fadd\n");
            codegen("fstore %d\n", tmp_symboltable[0].address);
        }
    }
    | Literal DEC {
        printf("DEC\n");
        if(strcmp($1, "int") == 0){
            codegen("ldc 1\n");
            codegen("isub\n");
            codegen("istore %d\n", tmp_symboltable[0].address);
        }
        if(strcmp($1, "float") == 0){
            codegen("ldc 1.0\n");
            codegen("fsub\n");
            codegen("fstore %d\n", tmp_symboltable[0].address);
        }
    }
;

Assignment_stmt
    : AIDENT ASGN Arithmetic_stmt {
        if(strcmp($1, $3) != 0 && strcmp($1,"") != 0){
            printf("error:%d: invalid operation: ASSIGN (mismatched types %s and %s)\n", yylineno , $1, $3);
        }
        else {
            Symbol table1 = lookup_symbol(tmp_name);
            if(strcmp(table1.type, "int") == 0){
                codegen("istore %d\n", table1.address);
            }
            if(strcmp(table1.type, "float") == 0){
                codegen("fstore %d\n",table1.address);
            }
            if(strcmp(table1.type, "string") == 0){
                codegen("astore %d\n",table1.address);
            }
            if(strcmp(table1.type, "bool") == 0){
                codegen("istore %d\n",table1.address);

            }
        } 
        printf("ASSIGN\n");
    }
    | PIDENT ADD_ASSIGN Arithmetic_stmt {
        printf("ADD_ASSIGN\n");
    }
    | Const ADD_ASSIGN Arithmetic_stmt {
        printf("error:%d: cannot assign to %s\n",yylineno, $1);
        printf("ADD_ASSIGN\n");
    }
    | PIDENT SUB_ASSIGN Arithmetic_stmt {
        printf("SUB_ASSIGN\n");
    }
    | PIDENT MUL_ASSIGN Arithmetic_stmt {
        printf("MUL_ASSIGN\n");
    }
    | PIDENT QUO_ASSIGN Arithmetic_stmt {
        printf("QUO_ASSIGN\n");
    }
    | PIDENT REM_ASSIGN Arithmetic_stmt {
        printf("REM_ASSIGN\n");
    }
    | PIDENT LBRACK Arithmetic_stmt RBRACK ASGN Arithmetic_stmt {
        printf("ASSIGN\n");        
    }
;

Arithmetic_stmt
    : Arithmetic_stmt OR AND_Arithmetic_stmt {
        if(strcmp($3, "bool") != 0){
            printf("error:%d: invalid operation: (operator OR not defined on %s)\n", yylineno, $3);
        }
        else if(strcmp($1, "bool") != 0){
            printf("error:%d: invalid operation: (operator OR not defined on %s)\n", yylineno, $1);
        }
        printf("OR\n");
        if(strcmp($1, $3) == 0){
            codegen("ior\n");
        }
        $$ = "bool";
    }
    | AND_Arithmetic_stmt
;

AND_Arithmetic_stmt
    : AND_Arithmetic_stmt AND Compare_Arithmetic_stmt {
        if(strcmp($3, "bool") != 0){
            printf("error:%d: invalid operation: (operator AND not defined on %s)\n", yylineno, $3);
        }
        else if(strcmp($1, "bool") != 0){
            printf("error:%d: invalid operation: (operator AND not defined on %s)\n", yylineno, $1);
        }
        printf("AND\n");
        if(strcmp($1, $3) == 0){
            codegen("iand\n");
        }
        $$ = "bool";
    }
    | Compare_Arithmetic_stmt
;

Compare_Arithmetic_stmt
    : Compare_Arithmetic_stmt GTR AS_Arithmetic_stmt {
        printf("GTR\n");
        if(strcmp($1, $3) == 0 && strcmp($1, "int") == 0){
            int tmp_label1 = label, tmp_label2 = label+1;
            codegen("isub\n");
            codegen("ifgt label%d\n", tmp_label1);
            codegen("iconst_0\n");
            codegen("goto label%d\n", tmp_label2);
            codegen("label%d :\n", tmp_label1);
            codegen("iconst_1\n");
            codegen("label%d :\n", tmp_label2);
            label += 2;
        }
        if(strcmp($1, $3) == 0 && strcmp($1, "float") == 0){
            int tmp_label1 = label, tmp_label2 = label+1;
            codegen("fcmpl\n");
            codegen("iflt label%d\n", tmp_label1);
            codegen("iconst_1\n");
            codegen("goto label%d\n", tmp_label2);
            codegen("label%d :\n", tmp_label1);
            codegen("iconst_0\n");
            codegen("label%d :\n", tmp_label2);
            label += 2;
        }
        
        $$ = "bool";
    }
    | Compare_Arithmetic_stmt LSS AS_Arithmetic_stmt {
        printf("LSS\n");
        if(strcmp($1, $3) == 0 && strcmp($1, "int") == 0){
            int tmp_label1 = label, tmp_label2 = label+1;
            codegen("isub\n");
            codegen("ifgt label%d\n", tmp_label1);
            codegen("iconst_1\n");
            codegen("goto label%d\n", tmp_label2);
            codegen("label%d :\n", tmp_label1);
            codegen("iconst_0\n");
            codegen("label%d :\n", tmp_label2);
            label += 2;
        }
        if(strcmp($1, $3) == 0 && strcmp($1, "float") == 0){
            int tmp_label1 = label, tmp_label2 = label+1;
            codegen("fcmpl\n");
            codegen("iflt label%d\n", tmp_label1);
            codegen("iconst_0\n");
            codegen("goto label%d\n", tmp_label2);
            codegen("label%d :\n", tmp_label1);
            codegen("iconst_1\n");
            codegen("label%d :\n", tmp_label2);
            label += 2;
        }
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
        if(strcmp($1, $3) != 0){
            printf("error:%d: invalid operation: ADD (mismatched types %s and %s)\n", yylineno , $1, $3);
        }
        if(strcmp($1, "int") == 0 && strcmp($3, "int") == 0){
            codegen("iadd\n");
        }
        if(strcmp($1, "float") == 0 && strcmp($3, "float") == 0){
            codegen("fadd\n");
        }
        printf("ADD\n");
    }
    | AS_Arithmetic_stmt SUB MQR_Arithmetic_stmt {
        if(strcmp($1, $3) != 0){
            printf("error:%d: invalid operation: SUB (mismatched types %s and %s)\n", yylineno , $1, $3);
        }
        if(strcmp($1, "int") == 0 && strcmp($3, "int") == 0){
            codegen("isub\n");
        }
        if(strcmp($1, "float") == 0 && strcmp($3, "float") == 0){
            codegen("fsub\n");
        }
        printf("SUB\n");
    }
    | MQR_Arithmetic_stmt
;

MQR_Arithmetic_stmt
    : MQR_Arithmetic_stmt MUL Unary_stmt {
        printf("MUL\n");
        if(strcmp($1, "int") == 0 && strcmp($3, "int") == 0){
            codegen("imul\n");
        }
        if(strcmp($1, "float") == 0 && strcmp($3, "float") == 0){
            codegen("fmul\n");
        }
    }
    | MQR_Arithmetic_stmt QUO Unary_stmt {
        printf("QUO\n");
        if(strcmp($1, "int") == 0 && strcmp($3, "int") == 0){
            codegen("idiv\n");
        }
        if(strcmp($1, "float") == 0 && strcmp($3, "float") == 0){
            codegen("fdiv\n");
        }
    }
    | MQR_Arithmetic_stmt REM Unary_stmt {
        if(strcmp($3, "float") == 0){
            printf("error:%d: invalid operation: (operator REM not defined on %s)\n", yylineno, $3);
        }
        else if(strcmp($1, "float") == 0){
            printf("error:%d: invalid operation: (operator REM not defined on %s)\n", yylineno, $1);
        }
        printf("REM\n");
        if(strcmp($1, "int") == 0 && strcmp($3, "int") == 0){
            codegen("irem\n");
        }
        if(strcmp($1, "float") == 0 && strcmp($3, "float") == 0){
            codegen("frem\n");
        }
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
        if(strcmp($2, "int") == 0){
            codegen("ineg\n");
        }
        if(strcmp($2, "float") == 0){
            codegen("fneg\n");
        }
        $$ = $2;
    }
    | NOT Unary_stmt {
        printf("NOT\n");
        codegen("iconst_1\n");
        codegen("ixor\n");
        $$ = $2;
    }
    | Brak_stmt
;

Brak_stmt
    : PIDENT LBRACK Arithmetic_stmt RBRACK {
        $$ = $1;
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
        if(strcmp($3, "bool") == 0){
            int tmp_label1 = label, tmp_label2 = label+1;
            codegen("ifne label%d\n", tmp_label1);
            codegen("ldc \"false\"\n");
            codegen("goto label%d\n", tmp_label2);
            codegen("label%d:\n", tmp_label1);
            codegen("ldc \"true\"\n");
            codegen("label%d:\n", tmp_label2);
            label += 2;
        }        
        codegen("getstatic java/lang/System/out Ljava/io/PrintStream;\n");
        codegen("swap\n");
        if(strcmp($3, "int") == 0){
            codegen("invokevirtual java/io/PrintStream/print(I)V\n");   
        }
        if(strcmp($3, "string") == 0){
            codegen("invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");   
        }
        if(strcmp($3, "float") == 0){
            codegen("invokevirtual java/io/PrintStream/print(F)V\n");   
        }
        if(strcmp($3, "bool") == 0){
            codegen("invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");   
        }
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

    /* Codegen output init */
    char *bytecode_filename = "hw3.j";
    fout = fopen(bytecode_filename, "w");
    codegen(".source hw3.j\n");
    codegen(".class public Main\n");
    codegen(".super java/lang/Object\n");
    codegen(".method public static main([Ljava/lang/String;)V\n");
    codegen(".limit stack 100\n");
    codegen(".limit locals 100\n");
    INDENT++;


    create_symbol();

    yyparse();

    dump_symbol();

	printf("Total lines: %d\n", yylineno);

    /* Codegen end */
    codegen("return\n");
    INDENT--;
    codegen(".end method\n");
    fclose(fout);
    fclose(yyin);

    if (HAS_ERROR) {
        remove(bytecode_filename);
    }
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

static void insert_symbol(char* name, char* type, int scope_number, int index_number, char* element_type){
    /* printf("scope number %d \n index number %d \n", scope_number, index_number); */
    if(strcmp(type, "array") != 0){
        symboltable[scope_number][index_number].name = name;
        symboltable[scope_number][index_number].type = type;
        symboltable[scope_number][index_number].address = num_address++;
        symboltable[scope_number][index_number].lineno = yylineno;
    }
    else {
        symboltable[scope_number][index_number].name = name;
        symboltable[scope_number][index_number].type = type;
        symboltable[scope_number][index_number].address = num_address++;
        symboltable[scope_number][index_number].lineno = yylineno; 
        symboltable[scope_number][index_number].element_type = element_type; 
    }
    printf("> Insert {%s} into symbol table (scope level: %d)", name, scope_number);
    /* printf("> Insert {%s} into symbol table (scope level: %d) %d", name, scope_number, num_address-1); */
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
    for(int s = scope_number; s >= 0; s--){
        for(int i = 0; i <= symbol_index[s]; i++){
            //already exist name
            if(strcmp(name, symboltable[s][i].name) == 0){
                return symboltable[s][i];
            }
        }
    }
    Symbol x;
    x.name="";
    x.type="";
    x.address = 0;
    x.lineno = 0;
    x.element_type = "";
    return  x;
}

static void dump_symbol(){
    // printf("scope%d\n", scope_number);
    printf("> Dump symbol table (scope level: %d)\n", scope_number);
    printf("%-10s%-10s%-10s%-10s%-10s%s\n", "Index", "Name", "Type", "Address", "Lineno","Element type");
        // printf("symbol index %d\n", symbol_index[s]);
        for(int i = 0; i <= symbol_index[scope_number]; i++){
            printf("%-10d%-10s%-10s%-10d%-10d%s",
                i, symboltable[scope_number][i].name,
                symboltable[scope_number][i].type,
                symboltable[scope_number][i].address, 
                symboltable[scope_number][i].lineno,
                symboltable[scope_number][i].element_type);
            printf("\n");
        }
        //clear table
        for(int i = 0; i <= symbol_index[scope_number]; i++){
            symboltable[scope_number][i].name = "",
            symboltable[scope_number][i].type = "",
            symboltable[scope_number][i].address = -1, 
            symboltable[scope_number][i].lineno = -1,
            symboltable[scope_number][i].element_type = "-";
        }
        symbol_index[scope_number] = -1;

}