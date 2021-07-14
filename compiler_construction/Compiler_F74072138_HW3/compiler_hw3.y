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
    int label = 0; //the jump tag label
    int lable_in[10];
    int lable_out[10];
    int if_in[10];
    int if_out[10];
    int if_label_in = 0;
    int if_label_out = 0;
    int scope_if_in = 0;
    int scope_if_out = 0;
       /* Symbol table function - you can add new function if needed. */
    static void create_symbol();
    static void insert_symbol(char* name, char* type, int scope_number, int index_number, char* element_type);
    static int check_symbol(char* name);
    static Symbol lookup_symbol(char* name);
    static void dump_symbol();
    static char* convert_type();
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
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN
%token ADD SUB MUL QUO REM INC DEC GTR LSS GEQ LEQ EQL NEQ NOT AND OR
%token ASGN WHILE IF ELSE ELIF FOR
%token SEMICOLON
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
%type <s_val> AIDENT Tag_while Assign_add_tmp Assign_sub_tmp Assign_mul_tmp Assign_quo_tmp Assign_rem_tmp Tag_for
/* %type <s_val>  If_first_con If_second_con If_first If_second If_third */
/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    : Program StatementList {
        INDENT--;
        codegen(" ;%d \n", yylineno);
        INDENT++;
    }
    | StatementList {
        INDENT--;
        codegen(" ;%d \n", yylineno);
        INDENT++;
    } 
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
        if(strcmp($2, "int") == 0){
            codegen("ldc %f\n", $4);
            codegen("f2i\n");
        }
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
        if(strcmp($2, "float") == 0){
            codegen("ldc %d\n", $4);
            codegen("i2f\n");
        }
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


        if(strcmp($2, "float") == 0 && strcmp(table1.type, "int") == 0){
            codegen("iload %d\n", table1.address);
            codegen("i2f\n");
        }
        if(strcmp($2, "int") == 0 && strcmp(table1.type, "float") == 0){
            codegen("fload %d\n", table1.address);
            codegen("f2i\n");
        }
        $$ = $2;
    }
    | LPAREN Type RPAREN PIDENT LBRACK Arithmetic_stmt RBRACK {
        Symbol table1 = lookup_symbol($4);

        if(strcmp(table1.element_type, "int") == 0 && strcmp($2, "float") == 0){
            codegen("iaload\n");
            codegen("i2f\n");
        }
        else if(strcmp(table1.element_type, "float") == 0 && strcmp($2, "int") == 0){
            codegen("faload\n");
            codegen("f2i\n");
        }
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
;
AIDENT
    : IDENT {
        Symbol table1 = lookup_symbol($1);

        if(strcmp(table1.name, "") == 0){
            printf("error:%d: undefined: %s\n", yylineno, $1);
        }
        else {
            printf("IDENT (name=%s, address=%d)\n", table1.name, table1.address);
            if(strcmp(table1.type, "array") == 0){
                codegen("aload %d\n", table1.address);
            }
        }
        
        if(strcmp(table1.type, "array") == 0){
            $$ = table1.element_type;
        }
        else {
            $$ = table1.type;
        }
        $$ = table1.name;
    }
;
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
            if(strcmp(table1.element_type, "int") == 0){
                codegen("aload %d\n",table1.address);
            }
            else if(strcmp(table1.element_type, "float") == 0){
                codegen("aload %d\n",table1.address);
            }
        }
        if(strcmp(table1.type, "array") == 0){
            $$ = table1.element_type;
        }
        else {
            $$ = table1.type;
        }
        $$ = table1.name;
    }
;


Statement
    : DeclarationStmt 
    | Expression 
;


DeclarationStmt
    : Type IDENT SEMICOLON {
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
            if(strcmp(table1.type, "string") == 0){
                codegen("ldc \"\"\n");
                codegen("astore %d\n", table1.address);
            }
        }
        else {
            Symbol table1 = lookup_symbol($2);
           HAS_ERROR = true;
            printf("error:%d: %s redeclared in this block. previous declaration at line %d\n", yylineno, $2, table1.lineno);
        }
        $$ = $1;
    }
    | Type IDENT ASGN Arithmetic_stmt SEMICOLON {
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
    | Type IDENT LBRACK Arithmetic_stmt RBRACK SEMICOLON {
        if(check_symbol($2) == 0){
            insert_symbol($2, "array", scope_number, ++symbol_index[scope_number], $1);
            Symbol table1 = lookup_symbol($2);
            // printf("%s\n", table1.element_type);
            if(strcmp(table1.element_type, "int") == 0){
                codegen("newarray %s\n", table1.element_type);
                codegen("astore %d\n", table1.address);
            }
            if(strcmp(table1.element_type, "float") == 0){
                codegen("newarray %s\n", table1.element_type);
                codegen("astore %d\n", table1.address);
            }
            if(strcmp(table1.element_type, "string") == 0){
                codegen("newarray %s\n", table1.element_type);
                codegen("astore %d\n", table1.address);
            }
            if(strcmp(table1.element_type, "bool") == 0){
                codegen("newarray %s\n", table1.element_type);
                codegen("istore %d\n", table1.address);
            }
        };
        $$ = $1;
    }
;

Expression
    : Assignment_stmt SEMICOLON
    | Arithmetic_stmt SEMICOLON
    | Execution_stmt SEMICOLON
    | INCDEC_stmt SEMICOLON
    | Loop_stmt Compound_stmt {
        codegen(" ; scope number %d\n", scope_number);
        codegen("goto label%d\n", lable_in[scope_number]);
        codegen("label%d :\n", lable_out[scope_number]);
    }
    | If_stmt 
    | For_stmt 
;

Compound_stmt
    :  LBRACE RBRACE {
        scope_number--;
    }
    | LBRACE Program RBRACE {
        dump_symbol();
        if(scope_number > 0) scope_number--;
        else {
            printf("negative scope number\n");
        }
    }
;

For_stmt
    : Befor Literal INC RPAREN Compound_stmt {
        char *c_type1 = convert_type($2);
        Symbol table1 = lookup_symbol($2);
        if(strcmp(c_type1, "int") == 0){
            codegen("ldc 1\n");
            codegen("iadd\n");
            codegen("istore %d\n", table1.address);
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("ldc 1.0\n");
            codegen("fadd\n");
            codegen("fstore %d\n", table1.address);
        }
        codegen("goto label%d\n", lable_in[scope_number]);
        codegen("label%d :\n", lable_out[scope_number]);
        scope_number++;
    }
    | Befor Literal DEC RPAREN Compound_stmt {
        char *c_type1 = convert_type($2);
        Symbol table1 = lookup_symbol($2);
        if(strcmp(c_type1, "int") == 0){
            codegen("ldc 1\n");
            codegen("isub\n");
            codegen("istore %d\n", table1.address);
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("ldc 1.0\n");
            codegen("fsub\n");
            codegen("fstore %d\n", table1.address);
        }
        codegen("goto label%d\n", lable_in[scope_number]);
        codegen("label%d :\n", lable_out[scope_number]);
        scope_number++;
    }
;
Befor
    : Aefor Arithmetic_stmt SEMICOLON {
        lable_out[scope_number] = label;
        label++;
        codegen("ifeq label%d\n", lable_out[scope_number]);
        scope_number++;
}
;

Aefor
    : FOR LPAREN Assignment_stmt SEMICOLON {
        codegen("label%d :\n", label);
        lable_in[scope_number] = label;
        label++;
}
;

If_stmt
	: If_con  {
        codegen("if_label_out%d :\n", if_out[scope_if_out]);
    }
	| If_con  If_else {
        codegen("if_label_out%d :\n", if_out[scope_if_out]);
    }
	| If_con  If_elif  If_else {
        codegen("if_label_out%d :\n", if_out[scope_if_out]);
    }
If_con
    : If_con_con Compound_stmt {
        scope_if_in--;
        scope_if_out--;
        codegen("goto if_label_out%d\n", if_out[scope_if_out]);
        codegen("if_label_in%d :\n", if_in[scope_if_in]);
    }
;
If_con_con
    : IF LPAREN Arithmetic_stmt RPAREN {
        if(strcmp($3, "bool") != 0){
           HAS_ERROR = true;
           printf("error:%d: non-bool (type %s) used as for condition\n", yylineno+1, $3);
        }
        else {
            if_in[scope_if_in] = if_label_in;
            if_label_in++;
            codegen("ifeq if_label_in%d\n", if_in[scope_if_in]);
            scope_if_in++;

            if_out[scope_if_out] = if_label_out;
            if_label_out++;
            scope_if_out++;
            // if_label++;
        }
        scope_number++;
    }
;
If_elif
    : If_elif_con Compound_stmt{
        // codegen(" ; scope number %d scope content %d \n", scope_if, if_out[scope_if]);
        codegen("goto if_label_out%d\n", if_out[scope_if_out]);
        scope_if_in--;
        codegen("if_label_in%d :\n", if_in[scope_if_in]);
    }
;
If_elif_con
    : ELIF LPAREN Arithmetic_stmt RPAREN {
        if(strcmp($3, "bool") != 0){
           HAS_ERROR = true;
           printf("error:%d: non-bool (type %s) used as for condition\n", yylineno+1, $3);
        }
        else {
            if_in[scope_if_in] = if_label_in;
            if_label_in++;
            codegen("ifeq if_label_in%d\n", if_in[scope_if_in]);
            scope_if_in++;
            // if_label++;
            // scope_if ++;
        }
        scope_number++;
}
;
If_else
    :  If_else_con Compound_stmt {
        codegen(" ; end else \n");
        // codegen("goto if_label%d\n", if_out[scope_if]);
        scope_if_in--;
        codegen("goto if_label_out%d\n", if_out[scope_if_out]);
        codegen("if_label_in%d :\n", if_in[scope_if_in]);
    }
;
If_else_con
    : ELSE {
        if_in[scope_if_in] = if_label_in;
        if_label_in++;
        codegen("iconst_1\n");
        codegen("ifeq if_label_in%d\n", if_in[scope_if_in]);
        scope_if_in++;
        // if_label ++;
        // scope_if ++;
        scope_number++;
    }    
;
Loop_stmt
    : Tag_while LPAREN Arithmetic_stmt RPAREN {
        if(strcmp($3, "bool") != 0){
            HAS_ERROR = true;
           printf("error:%d: non-bool (type %s) used as for condition\n", yylineno+1, $3);
        }
        codegen(" ; scope number %d\n", scope_number);
        codegen("ifeq label%d\n", label);
        lable_out[scope_number] = label;
        label ++;
        scope_number++; 
    }
;

Tag_while
    : WHILE {
        codegen(" ; scope number %d\n", scope_number);
        codegen("label%d :\n", label);
        lable_in[scope_number] = label;
        label++;
    }
;
INCDEC_stmt
    : Literal INC {
        char *c_type1 = convert_type($1);
        Symbol table1 = lookup_symbol($1);
        printf("INC\n");
        if(strcmp(c_type1, "int") == 0){
            codegen("ldc 1\n");
            codegen("iadd\n");
            codegen("istore %d\n", table1.address);
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("ldc 1.0\n");
            codegen("fadd\n");
            codegen("fstore %d\n", table1.address);
        }
    }
    | Literal DEC {
        char *c_type1 = convert_type($1);
        Symbol table1 = lookup_symbol($1);
        printf("DEC\n");
        if(strcmp(c_type1, "int") == 0){
            codegen("ldc 1\n");
            codegen("isub\n");
            codegen("istore %d\n", table1.address);
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("ldc 1.0\n");
            codegen("fsub\n");
            codegen("fstore %d\n", table1.address);
        }
    }
;

Assignment_stmt
    : AIDENT ASGN Arithmetic_stmt {
        char *c_type1 = convert_type($1);
        char *c_type2 = convert_type($3);
        Symbol table1 = lookup_symbol($1);
        if(strcmp(c_type1, c_type2) != 0 && strcmp(c_type1,"") != 0){
            printf("error:%d: invalid operation: ASSIGN (mismatched types %s and %s)\n", yylineno , $1, $3);
        }
        else {
            if(strcmp(c_type1, "int") == 0){
                codegen("istore %d\n", table1.address);
            }
            if(strcmp(c_type1, "float") == 0){
                codegen("fstore %d\n",table1.address);
            }
            if(strcmp(c_type1, "string") == 0){
                codegen("astore %d\n",table1.address);
            }
            if(strcmp(c_type1, "bool") == 0){
                codegen("istore %d\n",table1.address);
            }
        }
        printf("ASSIGN\n");
    }
    | Assign_add_tmp Arithmetic_stmt {
        char *c_type1 = convert_type($1);
        Symbol table1 = lookup_symbol($1);
        if(strcmp(c_type1, "int") == 0){
            codegen("iadd\n");
            codegen("istore %d\n", table1.address);            
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("fadd\n");
            codegen("fstore %d\n", table1.address);            
        }
    }
    | Assign_sub_tmp Arithmetic_stmt {
        char *c_type1 = convert_type($1);
        Symbol table1 = lookup_symbol($1);
        if(strcmp(c_type1, "int") == 0){
            codegen("isub\n");
            codegen("istore %d\n", table1.address);            
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("fsub\n");
            codegen("fstore %d\n", table1.address);            
        }
    }
    | Assign_mul_tmp Arithmetic_stmt {
        char *c_type1 = convert_type($1);
        Symbol table1 = lookup_symbol($1);
        if(strcmp(c_type1, "int") == 0){
            codegen("imul\n");
            codegen("istore %d\n", table1.address);            
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("fmul\n");
            codegen("fstore %d\n", table1.address);            
        }
    }
    | Assign_quo_tmp Arithmetic_stmt {
        char *c_type1 = convert_type($1);
        Symbol table1 = lookup_symbol($1);
        if(strcmp(c_type1, "int") == 0){
            codegen("idiv\n");
            codegen("istore %d\n", table1.address);
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("fdiv\n");
            codegen("fstore %d\n", table1.address);            
        }
    }
    | Assign_rem_tmp Arithmetic_stmt {
        char *c_type1 = convert_type($1);
        Symbol table1 = lookup_symbol($1);
        if(strcmp(c_type1, "int") == 0){
            codegen("irem\n");
            codegen("istore %d\n", table1.address);            
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("frem\n");
            codegen("fstore %d\n", table1.address);          
        }
    }
    | Const ADD_ASSIGN Arithmetic_stmt {
        printf("error:%d: cannot assign to %s\n",yylineno, $1);
        printf("ADD_ASSIGN\n");
    }
    | AIDENT LBRACK Arithmetic_stmt RBRACK ASGN Arithmetic_stmt {
        char *c_type1 = convert_type($1);
        Symbol table1 = lookup_symbol($1);
        printf("ASSIGN\n");
        if(strcmp(c_type1, "int") == 0){
            codegen("istore %d\n", table1.address);
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("fstore %d\n",table1.address);
        }
        if(strcmp(c_type1, "string") == 0){
            codegen("astore %d\n",table1.address);
        }
        if(strcmp(c_type1, "bool") == 0){
            codegen("istore %d\n",table1.address);
        }
        if(strcmp(c_type1, "array") == 0){
            if(strcmp(table1.element_type, "int") == 0){
                codegen("iastore\n");
            }
            if(strcmp(table1.element_type, "float") == 0){
                codegen("fastore\n");
            }
        }         
    }
;

Assign_add_tmp
    : AIDENT ADD_ASSIGN {
        printf("ADD_ASSIGN\n");
        char *c_type1 = convert_type($1);
        Symbol table1 = lookup_symbol($1);
        if(strcmp(c_type1, "int") == 0){
            codegen("iload %d\n", table1.address);
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("fload %d\n",table1.address);
        }
    }
Assign_sub_tmp
    : AIDENT SUB_ASSIGN {
        printf("SUB_ASSIGN\n");
        char *c_type1 = convert_type($1);
        Symbol table1 = lookup_symbol($1);
        if(strcmp(c_type1, "int") == 0){
            codegen("iload %d\n", table1.address);
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("fload %d\n",table1.address);
        }
    }
Assign_mul_tmp
    : AIDENT MUL_ASSIGN {
        printf("MUL_ASSIGN\n");
        char *c_type1 = convert_type($1);
        Symbol table1 = lookup_symbol($1);
        if(strcmp(c_type1, "int") == 0){
            codegen("iload %d\n", table1.address);
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("fload %d\n",table1.address);
        }

    }
Assign_quo_tmp
    : AIDENT QUO_ASSIGN {
        printf("QUO_ASSIGN\n");
        char *c_type1 = convert_type($1);
        Symbol table1 = lookup_symbol($1);
        if(strcmp(c_type1, "int") == 0){
            codegen("iload %d\n", table1.address);
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("fload %d\n",table1.address);
        }
    }
Assign_rem_tmp
    : AIDENT REM_ASSIGN {
        printf("REM_ASSIGN\n");
        char *c_type1 = convert_type($1);
        Symbol table1 = lookup_symbol($1);
        if(strcmp(c_type1, "int") == 0){
            codegen("iload %d\n", table1.address);
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("fload %d\n",table1.address);
        }
    }
;

Arithmetic_stmt
    : Arithmetic_stmt OR AND_Arithmetic_stmt {
        char *c_type1 = convert_type($1);
        char *c_type2 = convert_type($3);
        if(strcmp(c_type1, "bool") != 0){
            printf("error:%d: invalid operation: (operator OR not defined on %s)\n", yylineno, c_type1);
        }
        else if(strcmp(c_type2, "bool") != 0){
            printf("error:%d: invalid operation: (operator OR not defined on %s)\n", yylineno, c_type2);
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
        char *c_type1 = convert_type($1);
        char *c_type2 = convert_type($3);
        // printf("converted type1 %s type2 %s \n", $1, $3);
        if(strcmp(c_type1, "bool") != 0){
            printf("error:%d: invalid operation: (operator AND not defined on %s)\n", yylineno, c_type1);
        }
        else if(strcmp(c_type2, "bool") != 0){
            printf("error:%d: invalid operation: (operator AND not defined on %s)\n", yylineno, c_type2);
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
        char *c_type1 = convert_type($1);
        char *c_type2 = convert_type($3);
        printf("GTR\n");
        if(strcmp(c_type1, c_type2) == 0 && strcmp(c_type1, "int") == 0){
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
        if(strcmp(c_type1, c_type2) == 0 && strcmp(c_type1, "float") == 0){
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
        char *c_type1 = convert_type($1);
        char *c_type2 = convert_type($3);
        if(strcmp(c_type1, c_type2) == 0 && strcmp(c_type1, "int") == 0){
            int tmp_label1 = label, tmp_label2 = label+1;
            codegen("isub\n");
            codegen("ifge label%d\n", tmp_label1);
            codegen("iconst_1\n");
            codegen("goto label%d\n", tmp_label2);
            codegen("label%d :\n", tmp_label1);
            codegen("iconst_0\n");
            codegen("label%d :\n", tmp_label2);
            label += 2;
        }
        if(strcmp(c_type1, c_type2) == 0 && strcmp(c_type2, "float") == 0){
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
        char *c_type1 = convert_type($1);
        char *c_type2 = convert_type($3);
        if(strcmp(c_type1, c_type2) == 0 && strcmp(c_type1, "int") == 0){
            int tmp_label1 = label, tmp_label2 = label+1;
            codegen("isub\n");
            codegen("ifle label%d\n", tmp_label1);
            codegen("iconst_0\n");
            codegen("goto label%d\n", tmp_label2);
            codegen("label%d :\n", tmp_label1);
            codegen("iconst_1\n");
            codegen("label%d :\n", tmp_label2);
            label += 2;
        }
        if(strcmp(c_type1, c_type2) == 0 && strcmp(c_type1, "float") == 0){
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
    | Compare_Arithmetic_stmt EQL AS_Arithmetic_stmt {
        char *c_type1 = convert_type($1);
        char *c_type2 = convert_type($3);
        printf("EQL\n");
        if(strcmp(c_type1, c_type2) == 0 && strcmp(c_type1, "int") == 0){
            int tmp_label1 = label, tmp_label2 = label+1;
            codegen("isub\n");
            codegen("ifeq label%d\n", tmp_label1);
            codegen("iconst_0\n");
            codegen("goto label%d\n", tmp_label2);
            codegen("label%d :\n", tmp_label1);
            codegen("iconst_1\n");
            codegen("label%d :\n", tmp_label2);
            label += 2;
        }
        $$ = "bool";
    }
    | Compare_Arithmetic_stmt NEQ AS_Arithmetic_stmt {
        printf("NEQ\n");
        char *c_type1 = convert_type($1);
        char *c_type2 = convert_type($3);
        if(strcmp(c_type1, c_type2) == 0 && strcmp(c_type1, "int") == 0){
            int tmp_label1 = label, tmp_label2 = label+1;
            codegen("isub\n");
            codegen("ifeq label%d\n", tmp_label1);
            codegen("iconst_1\n");
            codegen("goto label%d\n", tmp_label2);
            codegen("label%d :\n", tmp_label1);
            codegen("iconst_0\n");
            codegen("label%d :\n", tmp_label2);
            label += 2;
        }
        $$ = "bool";
    }
    | AS_Arithmetic_stmt
;

AS_Arithmetic_stmt
    : AS_Arithmetic_stmt ADD MQR_Arithmetic_stmt {
        char *c_type1 = convert_type($1);
        char *c_type2 = convert_type($3);
        Symbol table1 = lookup_symbol($1);
        Symbol table2 = lookup_symbol($3);
        if(strcmp(c_type1, "array") == 0){
            c_type1 = table1.element_type;
        }
        else if(strcmp(c_type2, "array") == 0){
            c_type2 = table2.element_type;
        }

        if(strcmp(c_type1, c_type2) != 0){
            HAS_ERROR = true;
            printf("error:%d: invalid operation: ADD (mismatched types %s and %s)\n", yylineno , $1, $3);
        }
        // printf("converted name1 %s,  name2 %s \n", table1.name, table2.name);
        if(strcmp(c_type1, "int") == 0 && strcmp(c_type2, "int") == 0){
            codegen("iadd\n");
        }
        if(strcmp(c_type1, "float") == 0 && strcmp(c_type2, "float") == 0){
            codegen("fadd\n");
        }
        printf("ADD\n");
    }
    | AS_Arithmetic_stmt SUB MQR_Arithmetic_stmt {
        char *c_type1 = convert_type($1);
        char *c_type2 = convert_type($3);
        Symbol table1 = lookup_symbol($1);
        Symbol table2 = lookup_symbol($3);
        if(strcmp(c_type1, "array") == 0){
            c_type1 = table1.element_type;
        }
        else if(strcmp(c_type2, "array") == 0){
            c_type2 = table2.element_type;
        }
        // printf("converted name1 %s,  name2 %s \n", c_type1, c_type2);

        if(strcmp(c_type1, c_type2) != 0){
            HAS_ERROR = true;
            printf("error:%d: invalid operation: SUB (mismatched types %s and %s)\n", yylineno , $1, $3);
        }
        if(strcmp(c_type1, "int") == 0 && strcmp(c_type2, "int") == 0){
            codegen("isub\n");
        }
        if(strcmp(c_type1, "float") == 0 && strcmp(c_type2, "float") == 0){
            codegen("fsub\n");
        }
        printf("SUB\n");
    }
    | MQR_Arithmetic_stmt
;

MQR_Arithmetic_stmt
    : MQR_Arithmetic_stmt MUL Unary_stmt {
        char *c_type1 = convert_type($1);
        char *c_type2 = convert_type($3);
        Symbol table1 = lookup_symbol($1);
        Symbol table2 = lookup_symbol($3);
        if(strcmp(c_type1, "array") == 0){
            c_type1 = table1.element_type;
        }
        else if(strcmp(c_type2, "array") == 0){
            c_type2 = table2.element_type;
        }
        printf("MUL\n");
        if(strcmp(c_type1, "int") == 0 && strcmp(c_type2, "int") == 0){
            codegen("imul\n");
        }
        if(strcmp(c_type1, "float") == 0 && strcmp(c_type2, "float") == 0){
            codegen("fmul\n");
        }
    }
    | MQR_Arithmetic_stmt QUO Unary_stmt {
        char *c_type1 = convert_type($1);
        char *c_type2 = convert_type($3);
        Symbol table1 = lookup_symbol($1);
        Symbol table2 = lookup_symbol($3);
        if(strcmp(c_type1, "array") == 0){
            c_type1 = table1.element_type;
        }
        else if(strcmp(c_type2, "array") == 0){
            c_type2 = table2.element_type;
        }
        printf("QUO\n");
        if(strcmp(c_type1, "int") == 0 && strcmp(c_type2, "int") == 0){
            codegen("idiv\n");
        }
        if(strcmp(c_type1, "float") == 0 && strcmp(c_type2, "float") == 0){
            codegen("fdiv\n");
        }
    }
    | MQR_Arithmetic_stmt REM Unary_stmt {
        char *c_type1 = convert_type($1);
        char *c_type2 = convert_type($3);
        if(strcmp($3, "float") == 0){
            HAS_ERROR = true;
            printf("error:%d: invalid operation: (operator REM not defined on %s)\n", yylineno, $3);
        }
        else if(strcmp($1, "float") == 0){
            HAS_ERROR = true;
            printf("error:%d: invalid operation: (operator REM not defined on %s)\n", yylineno, $1);
        }
        printf("REM\n");
        if(strcmp(c_type1, "int") == 0 && strcmp(c_type2, "int") == 0){
            codegen("irem\n");
        }
        if(strcmp(c_type1, "float") == 0 && strcmp(c_type2, "float") == 0){
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
        Symbol table1 = lookup_symbol($1);
        if(strcmp(table1.element_type, "int") == 0){
            codegen("iaload\n");
        }
        else if(strcmp(table1.element_type, "float") == 0){
            codegen("faload\n");
        }
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
        char *c_type1 = convert_type($3);
        Symbol table1 = lookup_symbol($3);
        printf("PRINT %s\n", $3);
        if(strcmp(c_type1, "bool") == 0){
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
        if(strcmp(c_type1, "int") == 0){
            codegen("invokevirtual java/io/PrintStream/print(I)V\n");   
        }
        if(strcmp(c_type1, "string") == 0){
            codegen("invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");   
        }
        if(strcmp(c_type1, "float") == 0){
            codegen("invokevirtual java/io/PrintStream/print(F)V\n");   
        }
        if(strcmp(c_type1, "bool") == 0){
            codegen("invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");   
        }
        if(strcmp(c_type1, "array") == 0){
            if(strcmp(table1.element_type, "int") == 0){
                codegen("invokevirtual java/io/PrintStream/print(I)V\n");   
            }
            else if(strcmp(table1.element_type, "float") == 0){
                codegen("invokevirtual java/io/PrintStream/print(F)V\n");   
            }
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

static char* convert_type(char *source){
    if(strcmp(source, "int") == 0 || strcmp(source, "float") == 0 || strcmp(source, "bool") == 0
        || strcmp(source, "string") == 0){
            return source;
    }
    else if(strcmp(source, "array") == 0){
        Symbol table1 = lookup_symbol(source);
        return table1.element_type;
    }
    else {
        Symbol table1 = lookup_symbol(source);
        return table1.type;
    }
    
}

