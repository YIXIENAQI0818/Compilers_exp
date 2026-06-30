%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern FILE *yyin;
extern int cur_line;
extern int cur_col;

typedef struct Node {
    char *name;
    char *text;
    struct Node *child[32];
    int child_count;
} Node;

Node *root = NULL;
FILE *rule_file = NULL;
int node_id_counter = 0;

Node *new_node(const char *name, const char *text)
{
    Node *p = (Node *)malloc(sizeof(Node));
    p->name = strdup(name);
    p->text = text ? strdup(text) : NULL;
    p->child_count = 0;
    for (int i = 0; i < 32; i++) p->child[i] = NULL;
    return p;
}

void add_child(Node *parent, Node *child)
{
    if (parent && child && parent->child_count < 32)
        parent->child[parent->child_count++] = child;
}

int print_dot_node(FILE *fp, Node *root)
{
    if (!root) return -1;

    int my_id = node_id_counter++;

    if (root->text)
        fprintf(fp, "    node%d [label=\"%s\\n%s\"];\n", my_id, root->name, root->text);
    else
        fprintf(fp, "    node%d [label=\"%s\"];\n", my_id, root->name);

    for (int i = 0; i < root->child_count; i++)
    {
        int child_id = print_dot_node(fp, root->child[i]);
        if (child_id != -1)
            fprintf(fp, "    node%d -> node%d;\n", my_id, child_id);
    }

    return my_id;
}

void export_dot(Node *root, const char *filename)
{
    FILE *fp = fopen(filename, "w");
    if (!fp)
    {
        perror("fopen");
        return;
    }

    fprintf(fp, "digraph SyntaxTree {\n");
    fprintf(fp, "    rankdir=TB;\n");
    fprintf(fp, "    node [shape=box, fontname=\"SimSun\"];\n");

    node_id_counter = 0;
    print_dot_node(fp, root);

    fprintf(fp, "}\n");
    fclose(fp);
}

void yyerror(const char *s)
{
    fprintf(stderr, "Syntax error at (%d,%d): %s\n", cur_line, cur_col, s);
}

%}

%union {
    char *str;
    Node *node;
}

%token CONST INT VOID IF ELSE WHILE BREAK CONTINUE RETURN
%token EQ NE LE GE AND OR
%token PLUS MINUS MUL DIV MOD
%token ASSIGN LT GT NOT
%token SEMICOLON COMMA
%token LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE
%token <str> IDENT INT_CONST

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%type <node> CompUnit
%type <node> Decl ConstDecl VarDecl BType
%type <node> ConstDef ConstInitVal VarDef InitVal
%type <node> FuncDef FuncFParams FuncFParam
%type <node> Block BlockItem Stmt
%type <node> Exp Cond LVal PrimaryExp Number
%type <node> UnaryExp UnaryOp FuncRParams
%type <node> MulExp AddExp RelExp EqExp LAndExp LOrExp ConstExp

/* 辅助非终结符 */
%type <node> CompUnitItems CompUnitItem
%type <node> ConstDefs VarDefs
%type <node> ConstArrayDims VarArrayDims
%type <node> ConstArrayDim VarArrayDim
%type <node> ConstInitValList InitValList
%type <node> FuncArraySuffixs FuncArraySuffix
%type <node> BlockItems
%type <node> OptExp
%type <node> LValIndexList

%%

CompUnit
    : CompUnitItems
      {
          fprintf(rule_file, "CompUnit -> CompUnitItems\n");
          $$ = new_node("CompUnit", NULL);
          add_child($$, $1);
          root = $$;
      }
    ;

CompUnitItems
    : CompUnitItem
      {
          fprintf(rule_file, "CompUnitItems -> CompUnitItem\n");
          $$ = new_node("CompUnitItems", NULL);
          add_child($$, $1);
      }
    | CompUnitItems CompUnitItem
      {
          fprintf(rule_file, "CompUnitItems -> CompUnitItems CompUnitItem\n");
          $$ = $1;
          add_child($$, $2);
      }
    ;

CompUnitItem
    : Decl
      {
          fprintf(rule_file, "CompUnitItem -> Decl\n");
          $$ = new_node("CompUnitItem", NULL);
          add_child($$, $1);
      }
    | FuncDef
      {
          fprintf(rule_file, "CompUnitItem -> FuncDef\n");
          $$ = new_node("CompUnitItem", NULL);
          add_child($$, $1);
      }
    ;

Decl
    : ConstDecl
      {
          fprintf(rule_file, "Decl -> ConstDecl\n");
          $$ = new_node("Decl", NULL);
          add_child($$, $1);
      }
    | VarDecl
      {
          fprintf(rule_file, "Decl -> VarDecl\n");
          $$ = new_node("Decl", NULL);
          add_child($$, $1);
      }
    ;

ConstDecl
    : CONST BType ConstDefs SEMICOLON
      {
          fprintf(rule_file, "ConstDecl -> CONST BType ConstDefs SEMICOLON\n");
          $$ = new_node("ConstDecl", NULL);
          add_child($$, new_node("CONST", "const"));
          add_child($$, $2);
          add_child($$, $3);
          add_child($$, new_node("SEMICOLON", ";"));
      }
    | CONST BType error SEMICOLON
        {
            fprintf(rule_file, "ConstDecl -> CONST BType error SEMICOLON\n");
            $$ = new_node("ConstDecl", NULL);
            add_child($$, new_node("CONST", "const"));
            add_child($$, $2);
            add_child($$, new_node("ERROR", "ConstDecl"));
            add_child($$, new_node("SEMICOLON", ";"));
            yyerrok;
        }
    ;

ConstDefs
    : ConstDef
      {
          fprintf(rule_file, "ConstDefs -> ConstDef\n");
          $$ = new_node("ConstDefs", NULL);
          add_child($$, $1);
      }
    | ConstDefs COMMA ConstDef
      {
          fprintf(rule_file, "ConstDefs -> ConstDefs COMMA ConstDef\n");
          $$ = $1;
          add_child($$, new_node("COMMA", ","));
          add_child($$, $3);
      }
    ;

BType
    : INT
      {
          fprintf(rule_file, "BType -> INT\n");
          $$ = new_node("BType", NULL);
          add_child($$, new_node("INT", "int"));
      }
    ;
    
ConstDef
    : IDENT ConstArrayDims ASSIGN ConstInitVal
      {
          fprintf(rule_file, "ConstDef -> IDENT ConstArrayDims ASSIGN ConstInitVal\n");
          $$ = new_node("ConstDef", NULL);
          add_child($$, new_node("IDENT", $1));
          add_child($$, $2);
          add_child($$, new_node("ASSIGN", "="));
          add_child($$, $4);
      }
    ;

ConstArrayDims
    : /* empty */
      {
          fprintf(rule_file, "ConstArrayDims -> empty\n");
          $$ = NULL;
      }
    | ConstArrayDims ConstArrayDim
      {
          fprintf(rule_file, "ConstArrayDims -> ConstArrayDims ConstArrayDim\n");
          if ($1 == NULL)
              $$ = new_node("ConstArrayDims", NULL);
          else
              $$ = $1;
          add_child($$, $2);
      }
    ;

ConstArrayDim
    : LBRACK ConstExp RBRACK
      {
          fprintf(rule_file, "ConstArrayDim -> LBRACK ConstExp RBRACK\n");
          $$ = new_node("ConstArrayDim", NULL);
          add_child($$, new_node("LBRACK", "["));
          add_child($$, $2);
          add_child($$, new_node("RBRACK", "]"));
      }
    ;

ConstInitVal
    : ConstExp
      {
          fprintf(rule_file, "ConstInitVal -> ConstExp\n");
          $$ = new_node("ConstInitVal", NULL);
          add_child($$, $1);
      }
    | LBRACE ConstInitValList RBRACE
      {
          fprintf(rule_file, "ConstInitVal -> LBRACE ConstInitValList RBRACE\n");
          $$ = new_node("ConstInitVal", NULL);
          add_child($$, new_node("LBRACE", "{"));
          add_child($$, $2);
          add_child($$, new_node("RBRACE", "}"));
      }
    ;

ConstInitValList
    : /* empty */
      {
          fprintf(rule_file, "ConstInitValList -> empty\n");
          $$ = NULL;
      }
    | ConstInitVal
      {
          fprintf(rule_file, "ConstInitValList -> ConstInitVal\n");
          $$ = new_node("ConstInitValList", NULL);
          add_child($$, $1);
      }
    | ConstInitValList COMMA ConstInitVal
      {
          fprintf(rule_file, "ConstInitValList -> ConstInitValList COMMA ConstInitVal\n");
          if ($1 == NULL)
              $$ = new_node("ConstInitValList", NULL);
          else
              $$ = $1;
          add_child($$, new_node("COMMA", ","));
          add_child($$, $3);
      }
    ;

VarDecl
    : BType VarDefs SEMICOLON
        {
            fprintf(rule_file, "VarDecl -> BType VarDefs SEMICOLON\n");
            $$ = new_node("VarDecl", NULL);
            add_child($$, $1);
            add_child($$, $2);
            add_child($$, new_node("SEMICOLON", ";"));
        }
    | BType error SEMICOLON
        {
            fprintf(rule_file, "VarDecl -> BType error SEMICOLON\n");
            $$ = new_node("VarDecl", NULL);
            add_child($$, $1);
            add_child($$, new_node("ERROR", "VarDecl"));
            add_child($$, new_node("SEMICOLON", ";"));
            yyerrok;
        }
    ;

VarDefs
    : VarDef
      {
          fprintf(rule_file, "VarDefs -> VarDef\n");
          $$ = new_node("VarDefs", NULL);
          add_child($$, $1);
      }
    | VarDefs COMMA VarDef
      {
          fprintf(rule_file, "VarDefs -> VarDefs COMMA VarDef\n");
          $$ = $1;
          add_child($$, new_node("COMMA", ","));
          add_child($$, $3);
      }
    ;

VarDef
    : IDENT VarArrayDims
      {
          fprintf(rule_file, "VarDef -> IDENT VarArrayDims\n");
          $$ = new_node("VarDef", NULL);
          add_child($$, new_node("IDENT", $1));
          add_child($$, $2);
      }
    | IDENT VarArrayDims ASSIGN InitVal
      {
          fprintf(rule_file, "VarDef -> IDENT VarArrayDims ASSIGN InitVal\n");
          $$ = new_node("VarDef", NULL);
          add_child($$, new_node("IDENT", $1));
          add_child($$, $2);
          add_child($$, new_node("ASSIGN", "="));
          add_child($$, $4);
      }
    ;

VarArrayDims
    : /* empty */
      {
          fprintf(rule_file, "VarArrayDims -> empty\n");
          $$ = NULL;
      }
    | VarArrayDims VarArrayDim
      {
          fprintf(rule_file, "VarArrayDims -> VarArrayDims VarArrayDim\n");
          if ($1 == NULL)
              $$ = new_node("VarArrayDims", NULL);
          else
              $$ = $1;
          add_child($$, $2);
      }
    ;

VarArrayDim
    : LBRACK ConstExp RBRACK
      {
          fprintf(rule_file, "VarArrayDim -> LBRACK ConstExp RBRACK\n");
          $$ = new_node("VarArrayDim", NULL);
          add_child($$, new_node("LBRACK", "["));
          add_child($$, $2);
          add_child($$, new_node("RBRACK", "]"));
      }
    ;

InitVal
    : Exp
      {
          fprintf(rule_file, "InitVal -> Exp\n");
          $$ = new_node("InitVal", NULL);
          add_child($$, $1);
      }
    | LBRACE InitValList RBRACE
      {
          fprintf(rule_file, "InitVal -> LBRACE InitValList RBRACE\n");
          $$ = new_node("InitVal", NULL);
          add_child($$, new_node("LBRACE", "{"));
          add_child($$, $2);
          add_child($$, new_node("RBRACE", "}"));
      }
    ;

InitValList
    : /* empty */
      {
          fprintf(rule_file, "InitValList -> empty\n");
          $$ = NULL;
      }
    | InitVal
      {
          fprintf(rule_file, "InitValList -> InitVal\n");
          $$ = new_node("InitValList", NULL);
          add_child($$, $1);
      }
    | InitValList COMMA InitVal
      {
          fprintf(rule_file, "InitValList -> InitValList COMMA InitVal\n");
          if ($1 == NULL)
              $$ = new_node("InitValList", NULL);
          else
              $$ = $1;
          add_child($$, new_node("COMMA", ","));
          add_child($$, $3);
      }
    ;

FuncDef
    : BType IDENT LPAREN FuncFParams RPAREN Block
      {
          fprintf(rule_file, "FuncDef -> BType IDENT LPAREN FuncFParams RPAREN Block\n");
          $$ = new_node("FuncDef", NULL);
          add_child($$, $1);
          add_child($$, new_node("IDENT", $2));
          add_child($$, new_node("LPAREN", "("));
          add_child($$, $4);
          add_child($$, new_node("RPAREN", ")"));
          add_child($$, $6);
      }
    | VOID IDENT LPAREN FuncFParams RPAREN Block
      {
          fprintf(rule_file, "FuncDef -> VOID IDENT LPAREN FuncFParams RPAREN Block\n");
          $$ = new_node("FuncDef", NULL);
          add_child($$, new_node("VOID", "void"));
          add_child($$, new_node("IDENT", $2));
          add_child($$, new_node("LPAREN", "("));
          add_child($$, $4);
          add_child($$, new_node("RPAREN", ")"));
          add_child($$, $6);
      }
    ;

FuncFParams
    : /* empty */
      {
          fprintf(rule_file, "FuncFParams -> empty\n");
          $$ = NULL;
      }
    | FuncFParam
      {
          fprintf(rule_file, "FuncFParams -> FuncFParam\n");
          $$ = new_node("FuncFParams", NULL);
          add_child($$, $1);
      }
    | FuncFParams COMMA FuncFParam
      {
          fprintf(rule_file, "FuncFParams -> FuncFParams COMMA FuncFParam\n");
          if ($1 == NULL)
              $$ = new_node("FuncFParams", NULL);
          else
              $$ = $1;
          add_child($$, new_node("COMMA", ","));
          add_child($$, $3);
      }
    ;

FuncFParam
    : BType IDENT FuncArraySuffixs
      {
          fprintf(rule_file, "FuncFParam -> BType IDENT FuncArraySuffixs\n");
          $$ = new_node("FuncFParam", NULL);
          add_child($$, $1);
          add_child($$, new_node("IDENT", $2));
          add_child($$, $3);
      }
    ;

FuncArraySuffixs
    : /* empty */
      {
          fprintf(rule_file, "FuncArraySuffixs -> empty\n");
          $$ = NULL;
      }
    | LBRACK RBRACK FuncArraySuffix
      {
          fprintf(rule_file, "FuncArraySuffixs -> LBRACK RBRACK FuncArraySuffix\n");
          $$ = new_node("FuncArraySuffixs", NULL);
          add_child($$, new_node("LBRACK", "["));
          add_child($$, new_node("RBRACK", "]"));
          add_child($$, $3);
      }
    ;

FuncArraySuffix
    : /* empty */
      {
          fprintf(rule_file, "FuncArraySuffix -> empty\n");
          $$ = NULL;
      }
    | FuncArraySuffix LBRACK Exp RBRACK
      {
          fprintf(rule_file, "FuncArraySuffix -> FuncArraySuffix LBRACK Exp RBRACK\n");
          if ($1 == NULL)
              $$ = new_node("FuncArraySuffix", NULL);
          else
              $$ = $1;
          add_child($$, new_node("LBRACK", "["));
          add_child($$, $3);
          add_child($$, new_node("RBRACK", "]"));
      }
    ;

Block
    : LBRACE BlockItems RBRACE
      {
          fprintf(rule_file, "Block -> LBRACE BlockItems RBRACE\n");
          $$ = new_node("Block", NULL);
          add_child($$, new_node("LBRACE", "{"));
          add_child($$, $2);
          add_child($$, new_node("RBRACE", "}"));
      }
    ;

BlockItems
    : /* empty */
      {
          fprintf(rule_file, "BlockItems -> empty\n");
          $$ = NULL;
      }
    | BlockItems BlockItem
      {
          fprintf(rule_file, "BlockItems -> BlockItems BlockItem\n");
          if ($1 == NULL)
              $$ = new_node("BlockItems", NULL);
          else
              $$ = $1;
          add_child($$, $2);
      }
    ;

BlockItem
    : Decl
        {
            fprintf(rule_file, "BlockItem -> Decl\n");
            $$ = new_node("BlockItem", NULL);
            add_child($$, $1);
        }
    | Stmt
        {
            fprintf(rule_file, "BlockItem -> Stmt\n");
            $$ = new_node("BlockItem", NULL);
            add_child($$, $1);
        }
    ;

Stmt
    : LVal ASSIGN Exp SEMICOLON
        {
            fprintf(rule_file, "Stmt -> LVal ASSIGN Exp SEMICOLON\n");
            $$ = new_node("Stmt", NULL);
            add_child($$, $1);
            add_child($$, new_node("ASSIGN", "="));
            add_child($$, $3);
            add_child($$, new_node("SEMICOLON", ";"));
        }
    | OptExp SEMICOLON
        {
            fprintf(rule_file, "Stmt -> OptExp SEMICOLON\n");
            $$ = new_node("Stmt", NULL);
            add_child($$, $1);
            add_child($$, new_node("SEMICOLON", ";"));
        }
    | Block
        {
            fprintf(rule_file, "Stmt -> Block\n");
            $$ = new_node("Stmt", NULL);
            add_child($$, $1);
        }
    | IF LPAREN Cond RPAREN Stmt %prec LOWER_THAN_ELSE
        {
            fprintf(rule_file, "Stmt -> IF LPAREN Cond RPAREN Stmt\n");
            $$ = new_node("Stmt", NULL);
            add_child($$, new_node("IF", "if"));
            add_child($$, new_node("LPAREN", "("));
            add_child($$, $3);
            add_child($$, new_node("RPAREN", ")"));
            add_child($$, $5);
        }
    | IF LPAREN Cond RPAREN Stmt ELSE Stmt
        {
            fprintf(rule_file, "Stmt -> IF LPAREN Cond RPAREN Stmt ELSE Stmt\n");
            $$ = new_node("Stmt", NULL);
            add_child($$, new_node("IF", "if"));
            add_child($$, new_node("LPAREN", "("));
            add_child($$, $3);
            add_child($$, new_node("RPAREN", ")"));
            add_child($$, $5);
            add_child($$, new_node("ELSE", "else"));
            add_child($$, $7);
        }
    | WHILE LPAREN Cond RPAREN Stmt
        {
            fprintf(rule_file, "Stmt -> WHILE LPAREN Cond RPAREN Stmt\n");
            $$ = new_node("Stmt", NULL);
            add_child($$, new_node("WHILE", "while"));
            add_child($$, new_node("LPAREN", "("));
            add_child($$, $3);
            add_child($$, new_node("RPAREN", ")"));
            add_child($$, $5);
        }
    | BREAK SEMICOLON
        {
            fprintf(rule_file, "Stmt -> BREAK SEMICOLON\n");
            $$ = new_node("Stmt", NULL);
            add_child($$, new_node("BREAK", "break"));
            add_child($$, new_node("SEMICOLON", ";"));
        }
    | CONTINUE SEMICOLON
        {
            fprintf(rule_file, "Stmt -> CONTINUE SEMICOLON\n");
            $$ = new_node("Stmt", NULL);
            add_child($$, new_node("CONTINUE", "continue"));
            add_child($$, new_node("SEMICOLON", ";"));
        }
    | RETURN OptExp SEMICOLON
        {
            fprintf(rule_file, "Stmt -> RETURN OptExp SEMICOLON\n");
            $$ = new_node("Stmt", NULL);
            add_child($$, new_node("RETURN", "return"));
            add_child($$, $2);
            add_child($$, new_node("SEMICOLON", ";"));
        }
    | error SEMICOLON
        {
            fprintf(rule_file, "Stmt -> error SEMICOLON\n");
            $$ = new_node("Stmt", NULL);
            add_child($$, new_node("ERROR", "Stmt"));
            add_child($$, new_node("SEMICOLON", ";"));
            yyerrok;
        }
    ;

OptExp
    : /* empty */
      {
          fprintf(rule_file, "OptExp -> empty\n");
          $$ = NULL;
      }
    | Exp
      {
          fprintf(rule_file, "OptExp -> Exp\n");
          $$ = new_node("OptExp", NULL);
          add_child($$, $1);
      }
    ;

Exp
    : AddExp
      {
          fprintf(rule_file, "Exp -> AddExp\n");
          $$ = new_node("Exp", NULL);
          add_child($$, $1);
      }
    ;

Cond
    : LOrExp
      {
          fprintf(rule_file, "Cond -> LOrExp\n");
          $$ = new_node("Cond", NULL);
          add_child($$, $1);
      }
    ;

LVal
    : IDENT LValIndexList
      {
          fprintf(rule_file, "LVal -> IDENT LValIndexList\n");
          $$ = new_node("LVal", NULL);
          add_child($$, new_node("IDENT", $1));
          add_child($$, $2);
      }
    ;

LValIndexList
    : /* empty */
      {
          fprintf(rule_file, "LValIndexList -> empty\n");
          $$ = NULL;
      }
    | LValIndexList LBRACK Exp RBRACK
      {
          fprintf(rule_file, "LValIndexList -> LValIndexList LBRACK Exp RBRACK\n");
          if ($1 == NULL)
              $$ = new_node("LValIndexList", NULL);
          else
              $$ = $1;
          add_child($$, new_node("LBRACK", "["));
          add_child($$, $3);
          add_child($$, new_node("RBRACK", "]"));
      }
    ;

PrimaryExp
    : LPAREN Exp RPAREN
      {
          fprintf(rule_file, "PrimaryExp -> LPAREN Exp RPAREN\n");
          $$ = new_node("PrimaryExp", NULL);
          add_child($$, new_node("LPAREN", "("));
          add_child($$, $2);
          add_child($$, new_node("RPAREN", ")"));
      }
    | LVal
      {
          fprintf(rule_file, "PrimaryExp -> LVal\n");
          $$ = new_node("PrimaryExp", NULL);
          add_child($$, $1);
      }
    | Number
      {
          fprintf(rule_file, "PrimaryExp -> Number\n");
          $$ = new_node("PrimaryExp", NULL);
          add_child($$, $1);
      }
    ;

Number
    : INT_CONST
      {
          fprintf(rule_file, "Number -> INT_CONST\n");
          $$ = new_node("Number", NULL);
          add_child($$, new_node("INT_CONST", $1));
      }
    ;

UnaryExp
    : PrimaryExp
      {
          fprintf(rule_file, "UnaryExp -> PrimaryExp\n");
          $$ = new_node("UnaryExp", NULL);
          add_child($$, $1);
      }
    | IDENT LPAREN FuncRParams RPAREN
      {
          fprintf(rule_file, "UnaryExp -> IDENT LPAREN FuncRParams RPAREN\n");
          $$ = new_node("UnaryExp", NULL);
          add_child($$, new_node("IDENT", $1));
          add_child($$, new_node("LPAREN", "("));
          add_child($$, $3);
          add_child($$, new_node("RPAREN", ")"));
      }
    | UnaryOp UnaryExp
      {
          fprintf(rule_file, "UnaryExp -> UnaryOp UnaryExp\n");
          $$ = new_node("UnaryExp", NULL);
          add_child($$, $1);
          add_child($$, $2);
      }
    ;

UnaryOp
    : PLUS
      {
          fprintf(rule_file, "UnaryOp -> PLUS\n");
          $$ = new_node("UnaryOp", NULL);
          add_child($$, new_node("PLUS", "+"));
      }
    | MINUS
      {
          fprintf(rule_file, "UnaryOp -> MINUS\n");
          $$ = new_node("UnaryOp", NULL);
          add_child($$, new_node("MINUS", "-"));
      }
    | NOT
      {
          fprintf(rule_file, "UnaryOp -> NOT\n");
          $$ = new_node("UnaryOp", NULL);
          add_child($$, new_node("NOT", "!"));
      }
    ;

FuncRParams
    : /* empty */
      {
          fprintf(rule_file, "FuncRParams -> empty\n");
          $$ = NULL;
      }
    | Exp
      {
          fprintf(rule_file, "FuncRParams -> Exp\n");
          $$ = new_node("FuncRParams", NULL);
          add_child($$, $1);
      }
    | FuncRParams COMMA Exp
      {
          fprintf(rule_file, "FuncRParams -> FuncRParams COMMA Exp\n");
          if ($1 == NULL)
              $$ = new_node("FuncRParams", NULL);
          else
              $$ = $1;
          add_child($$, new_node("COMMA", ","));
          add_child($$, $3);
      }
    ;

MulExp
    : UnaryExp
      {
          fprintf(rule_file, "MulExp -> UnaryExp\n");
          $$ = new_node("MulExp", NULL);
          add_child($$, $1);
      }
    | MulExp MUL UnaryExp
      {
          fprintf(rule_file, "MulExp -> MulExp MUL UnaryExp\n");
          $$ = new_node("MulExp", NULL);
          add_child($$, $1);
          add_child($$, new_node("MUL", "*"));
          add_child($$, $3);
      }
    | MulExp DIV UnaryExp
      {
          fprintf(rule_file, "MulExp -> MulExp DIV UnaryExp\n");
          $$ = new_node("MulExp", NULL);
          add_child($$, $1);
          add_child($$, new_node("DIV", "/"));
          add_child($$, $3);
      }
    | MulExp MOD UnaryExp
      {
          fprintf(rule_file, "MulExp -> MulExp MOD UnaryExp\n");
          $$ = new_node("MulExp", NULL);
          add_child($$, $1);
          add_child($$, new_node("MOD", "%"));
          add_child($$, $3);
      }
    ;

AddExp
    : MulExp
      {
          fprintf(rule_file, "AddExp -> MulExp\n");
          $$ = new_node("AddExp", NULL);
          add_child($$, $1);
      }
    | AddExp PLUS MulExp
      {
          fprintf(rule_file, "AddExp -> AddExp PLUS MulExp\n");
          $$ = new_node("AddExp", NULL);
          add_child($$, $1);
          add_child($$, new_node("PLUS", "+"));
          add_child($$, $3);
      }
    | AddExp MINUS MulExp
      {
          fprintf(rule_file, "AddExp -> AddExp MINUS MulExp\n");
          $$ = new_node("AddExp", NULL);
          add_child($$, $1);
          add_child($$, new_node("MINUS", "-"));
          add_child($$, $3);
      }
    ;

RelExp
    : AddExp
      {
          fprintf(rule_file, "RelExp -> AddExp\n");
          $$ = new_node("RelExp", NULL);
          add_child($$, $1);
      }
    | RelExp LT AddExp
      {
          fprintf(rule_file, "RelExp -> RelExp LT AddExp\n");
          $$ = new_node("RelExp", NULL);
          add_child($$, $1);
          add_child($$, new_node("LT", "<"));
          add_child($$, $3);
      }
    | RelExp GT AddExp
      {
          fprintf(rule_file, "RelExp -> RelExp GT AddExp\n");
          $$ = new_node("RelExp", NULL);
          add_child($$, $1);
          add_child($$, new_node("GT", ">"));
          add_child($$, $3);
      }
    | RelExp LE AddExp
      {
          fprintf(rule_file, "RelExp -> RelExp LE AddExp\n");
          $$ = new_node("RelExp", NULL);
          add_child($$, $1);
          add_child($$, new_node("LE", "<="));
          add_child($$, $3);
      }
    | RelExp GE AddExp
      {
          fprintf(rule_file, "RelExp -> RelExp GE AddExp\n");
          $$ = new_node("RelExp", NULL);
          add_child($$, $1);
          add_child($$, new_node("GE", ">="));
          add_child($$, $3);
      }
    ;

EqExp
    : RelExp
      {
          fprintf(rule_file, "EqExp -> RelExp\n");
          $$ = new_node("EqExp", NULL);
          add_child($$, $1);
      }
    | EqExp EQ RelExp
      {
          fprintf(rule_file, "EqExp -> EqExp EQ RelExp\n");
          $$ = new_node("EqExp", NULL);
          add_child($$, $1);
          add_child($$, new_node("EQ", "=="));
          add_child($$, $3);
      }
    | EqExp NE RelExp
      {
          fprintf(rule_file, "EqExp -> EqExp NE RelExp\n");
          $$ = new_node("EqExp", NULL);
          add_child($$, $1);
          add_child($$, new_node("NE", "!="));
          add_child($$, $3);
      }
    ;

LAndExp
    : EqExp
      {
          fprintf(rule_file, "LAndExp -> EqExp\n");
          $$ = new_node("LAndExp", NULL);
          add_child($$, $1);
      }
    | LAndExp AND EqExp
      {
          fprintf(rule_file, "LAndExp -> LAndExp AND EqExp\n");
          $$ = new_node("LAndExp", NULL);
          add_child($$, $1);
          add_child($$, new_node("AND", "&&"));
          add_child($$, $3);
      }
    ;

LOrExp
    : LAndExp
      {
          fprintf(rule_file, "LOrExp -> LAndExp\n");
          $$ = new_node("LOrExp", NULL);
          add_child($$, $1);
      }
    | LOrExp OR LAndExp
      {
          fprintf(rule_file, "LOrExp -> LOrExp OR LAndExp\n");
          $$ = new_node("LOrExp", NULL);
          add_child($$, $1);
          add_child($$, new_node("OR", "||"));
          add_child($$, $3);
      }
    ;

ConstExp
    : AddExp
      {
          fprintf(rule_file, "ConstExp -> AddExp\n");
          $$ = new_node("ConstExp", NULL);
          add_child($$, $1);
      }
    ;

%%

int main(int argc, char *argv[])
{
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("fopen");
            return 1;
        }
    }

    rule_file = fopen("rules.txt", "w");
    if (!rule_file) {
        perror("fopen");
        return 1;
    }

    if (yyparse() == 0) {
        printf("Parse succeeded.\n");
        export_dot(root, "tree.dot");
    }

    if (rule_file) fclose(rule_file);
    if (argc > 1 && yyin) fclose(yyin);
    return 0;
}