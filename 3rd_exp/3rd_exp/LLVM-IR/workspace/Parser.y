%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern FILE *yyin;
extern int cur_line;
extern int cur_col;

FILE *ir_file = NULL;


int current_return_type = 0; /* 0: int, 1: void */
int function_has_return = 0;
int reg_count = 1;
int const_eval_mode = 0;
int label_count = 1;
int current_block_terminated = 0;
int semantic_error_count = 0;

typedef struct Symbol {
    char *name;
    char *ptr;
    int is_global;
    int is_const;
    int is_array;
    int dim_count;
    int dims[8];
    int total_size;
    int const_value;
    int scope_level;
} Symbol;



typedef struct Value {
    char *text;
    char *ptr;
    int is_lvalue;
    int is_const;
    int const_value;
} Value;

typedef struct CondNode {
    int kind; /* 0: value, 1: and, 2: or */
    Value *value;
    struct CondNode *left;
    struct CondNode *right;
} CondNode;

typedef struct DimList {
    int dims[8];
    int count;
} DimList;

typedef struct ArgList {
    Value *args[32];
    int count;
} ArgList;

typedef struct ParamList {
    char *names[32];
    int count;
} ParamList;

typedef struct IfContext {
    char *else_label;
    char *end_label;
    int then_terminated;
    int else_terminated;
} IfContext;

typedef struct LoopContext {
    char *cond_label;
    char *body_label;
    char *end_label;
} LoopContext;

char *value_as_rvalue(Value *value);
Value *emit_binary(const char *op, Value *lhs, Value *rhs);
void emit_cond_branch(CondNode *cond, const char *true_label, const char *false_label);

Symbol symbols[256];
int symbol_count = 0;
int in_function = 0;
int current_scope_level = 0;
IfContext if_stack[128];
int if_stack_top = 0;
LoopContext loop_stack[128];
int loop_stack_top = 0;

char *dup_printf(const char *fmt, const char *a, const char *b)
{
    char buf[128];
    if (b)
        snprintf(buf, sizeof(buf), fmt, a, b);
    else
        snprintf(buf, sizeof(buf), fmt, a);
    return strdup(buf);
}

char *new_reg(void)
{
    char buf[32];
    snprintf(buf, sizeof(buf), "%%r%d", reg_count++);
    return strdup(buf);
}

char *new_label(void)
{
    char buf[32];
    snprintf(buf, sizeof(buf), "label_%d", label_count++);
    return strdup(buf);
}

Value *new_value(const char *text)
{
    Value *v = (Value *)malloc(sizeof(Value));
    v->text = strdup(text);
    v->ptr = NULL;
    v->is_lvalue = 0;
    v->is_const = 0;
    v->const_value = 0;
    return v;
}

Value *new_const_value(int value)
{
    char buf[32];
    snprintf(buf, sizeof(buf), "%d", value);
    Value *v = new_value(buf);
    v->is_const = 1;
    v->const_value = value;
    return v;
}

Value *new_lvalue(const char *ptr)
{
    Value *v = new_value(ptr);
    v->ptr = strdup(ptr);
    v->is_lvalue = 1;
    return v;
}

CondNode *new_cond_value(Value *value)
{
    CondNode *node = (CondNode *)malloc(sizeof(CondNode));
    node->kind = 0;
    node->value = value;
    node->left = NULL;
    node->right = NULL;
    return node;
}

CondNode *new_cond_binary(int kind, CondNode *left, CondNode *right)
{
    CondNode *node = (CondNode *)malloc(sizeof(CondNode));
    node->kind = kind;
    node->value = NULL;
    node->left = left;
    node->right = right;
    return node;
}

DimList *new_dim_list(void)
{
    DimList *list = (DimList *)malloc(sizeof(DimList));
    list->count = 0;
    for (int i = 0; i < 8; ++i)
        list->dims[i] = 0;
    return list;
}

DimList *append_dim(DimList *list, int dim)
{
    if (!list)
        list = new_dim_list();
    if (list->count < 8)
        list->dims[list->count++] = dim;
    return list;
}

ArgList *new_arg_list(void)
{
    ArgList *list = (ArgList *)malloc(sizeof(ArgList));
    list->count = 0;
    for (int i = 0; i < 32; ++i)
        list->args[i] = NULL;
    return list;
}

ArgList *append_arg(ArgList *list, Value *value)
{
    if (!list)
        list = new_arg_list();
    if (list->count < 32)
        list->args[list->count++] = value;
    return list;
}

ParamList *new_param_list(void)
{
    ParamList *list = (ParamList *)malloc(sizeof(ParamList));
    list->count = 0;
    for (int i = 0; i < 32; ++i)
        list->names[i] = NULL;
    return list;
}

ParamList *append_param(ParamList *list, const char *name)
{
    if (!list)
        list = new_param_list();
    if (list->count < 32)
        list->names[list->count++] = strdup(name);
    return list;
}

void reset_function_state(void)
{
    reg_count = 1;
    label_count = 1;
    current_block_terminated = 0;
    if_stack_top = 0;
    loop_stack_top = 0;
    int write = 0;
    for (int read = 0; read < symbol_count; ++read) {
        if (symbols[read].is_global)
            symbols[write++] = symbols[read];
    }
    symbol_count = write;
    current_scope_level = 0;
}

void push_scope(void)
{
    current_scope_level++;
}

void pop_scope(void)
{
    int write = 0;
    for (int read = 0; read < symbol_count; ++read) {
        if (symbols[read].is_global || symbols[read].scope_level < current_scope_level)
            symbols[write++] = symbols[read];
    }
    symbol_count = write;
    if (current_scope_level > 0)
        current_scope_level--;
}

Symbol *find_symbol(const char *name)
{
    for (int i = symbol_count - 1; i >= 0; --i) {
        if (strcmp(symbols[i].name, name) == 0)
            return &symbols[i];
    }
    return NULL;
}

char *add_local_symbol(const char *name)
{
    for (int i = symbol_count - 1; i >= 0; --i) {
        if (!symbols[i].is_global && symbols[i].scope_level == current_scope_level &&
            strcmp(symbols[i].name, name) == 0)
            return symbols[i].ptr;
    }

    char *ptr = new_reg();
    fprintf(ir_file, "  %s = alloca i32\n", ptr);
    symbols[symbol_count].name = strdup(name);
    symbols[symbol_count].ptr = strdup(ptr);
    symbols[symbol_count].is_global = 0;
    symbols[symbol_count].is_const = 0;
    symbols[symbol_count].is_array = 0;
    symbols[symbol_count].dim_count = 0;
    symbols[symbol_count].total_size = 1;
    symbols[symbol_count].const_value = 0;
    symbols[symbol_count].scope_level = current_scope_level;
    symbol_count++;
    return ptr;
}

Symbol *add_local_const_symbol(const char *name, int value)
{
    for (int i = symbol_count - 1; i >= 0; --i) {
        if (!symbols[i].is_global && symbols[i].scope_level == current_scope_level &&
            strcmp(symbols[i].name, name) == 0)
            return &symbols[i];
    }

    Symbol *sym = &symbols[symbol_count++];
    sym->name = strdup(name);
    sym->ptr = NULL;
    sym->is_global = 0;
    sym->is_const = 1;
    sym->is_array = 0;
    sym->dim_count = 0;
    sym->total_size = 1;
    sym->const_value = value;
    sym->scope_level = current_scope_level;
    for (int i = 0; i < 8; ++i)
        sym->dims[i] = 0;
    return sym;
}

int const_value_of(Value *value)
{
    if (!value)
        return 0;
    if (value->is_const)
        return value->const_value;
    return atoi(value->text);
}

int total_size_of(DimList *dims)
{
    int total = 1;
    if (!dims || dims->count == 0)
        return 1;
    for (int i = 0; i < dims->count; ++i)
        total *= dims->dims[i];
    return total;
}

void fill_symbol_dims(Symbol *sym, DimList *dims)
{
    sym->dim_count = dims ? dims->count : 0;
    sym->is_array = sym->dim_count > 0;
    sym->total_size = total_size_of(dims);
    for (int i = 0; i < 8; ++i)
        sym->dims[i] = (dims && i < dims->count) ? dims->dims[i] : 0;
}

Symbol *add_global_symbol(const char *name, DimList *dims, int is_const, int init_value)
{
    for (int i = 0; i < symbol_count; ++i) {
        if (symbols[i].is_global && strcmp(symbols[i].name, name) == 0)
            return &symbols[i];
    }

    Symbol *sym = &symbols[symbol_count++];
    sym->name = strdup(name);
    sym->is_global = 1;
    sym->is_const = is_const;
    sym->const_value = init_value;
    sym->scope_level = 0;
    fill_symbol_dims(sym, dims);

    char buf[128];
    snprintf(buf, sizeof(buf), "@%s", name);
    sym->ptr = strdup(buf);

    if (sym->is_array) {
        fprintf(ir_file, "@%s = global [%d x i32] zeroinitializer\n", name, sym->total_size);
    } else if (is_const) {
        fprintf(ir_file, "@%s = constant i32 %d\n", name, init_value);
    } else {
        fprintf(ir_file, "@%s = global i32 %d\n", name, init_value);
    }

    return sym;
}

Symbol *add_local_array_symbol(const char *name, DimList *dims)
{
    for (int i = symbol_count - 1; i >= 0; --i) {
        if (!symbols[i].is_global && symbols[i].scope_level == current_scope_level &&
            strcmp(symbols[i].name, name) == 0)
            return &symbols[i];
    }

    int total = total_size_of(dims);
    char *raw = new_reg();
    char *base = new_reg();
    fprintf(ir_file, "  %s = alloca [%d x i32]\n", raw, total);
    fprintf(ir_file, "  %s = bitcast [%d x i32]* %s to i32*\n", base, total, raw);

    Symbol *sym = &symbols[symbol_count++];
    sym->name = strdup(name);
    sym->ptr = strdup(base);
    sym->is_global = 0;
    sym->is_const = 0;
    sym->scope_level = current_scope_level;
    fill_symbol_dims(sym, dims);
    sym->const_value = 0;
    return sym;
}

char *value_as_rvalue(Value *value)
{
    if (!value)
        return strdup("0");

    if (!value->is_lvalue)
        return strdup(value->text);

    if (const_eval_mode)
        return strdup(value->text);

    char *reg = new_reg();
    fprintf(ir_file, "  %s = load i32, i32* %s\n", reg, value->ptr);
    return reg;
}

char *value_as_i1(Value *value)
{
    char *text = value_as_rvalue(value);
    char *reg = new_reg();
    fprintf(ir_file, "  %s = icmp ne i32 %s, 0\n", reg, text);
    return reg;
}

void emit_label(const char *label)
{
    fprintf(ir_file, "%s:\n", label);
    current_block_terminated = 0;
}

void emit_br(const char *label)
{
    if (!current_block_terminated) {
        fprintf(ir_file, "  br label %%%s\n", label);
        current_block_terminated = 1;
    }
}

void emit_cond_branch(CondNode *cond, const char *true_label, const char *false_label)
{
    if (!cond) {
        fprintf(ir_file, "  br label %%%s\n", false_label);
        current_block_terminated = 1;
        return;
    }

    if (cond->kind == 1) {
        char *rhs_label = new_label();
        emit_cond_branch(cond->left, rhs_label, false_label);
        emit_label(rhs_label);
        emit_cond_branch(cond->right, true_label, false_label);
        return;
    }

    if (cond->kind == 2) {
        char *rhs_label = new_label();
        emit_cond_branch(cond->left, true_label, rhs_label);
        emit_label(rhs_label);
        emit_cond_branch(cond->right, true_label, false_label);
        return;
    }

    char *cond_value = value_as_i1(cond->value);
    fprintf(ir_file, "  br i1 %s, label %%%s, label %%%s\n", cond_value, true_label, false_label);
    current_block_terminated = 1;
}

void begin_if_unified(CondNode *cond)
{
    char *then_label = new_label();
    char *else_label = new_label();
    char *end_label = new_label();

    emit_cond_branch(cond, then_label, else_label);
    emit_label(then_label);

    if_stack[if_stack_top].else_label = else_label;
    if_stack[if_stack_top].end_label = end_label;
    if_stack[if_stack_top].then_terminated = 0;
    if_stack[if_stack_top].else_terminated = 0;
    if_stack_top++;
}

void switch_to_else(void)
{
    IfContext *ctx = &if_stack[if_stack_top - 1];
    ctx->then_terminated = current_block_terminated;
    emit_br(ctx->end_label);
    emit_label(ctx->else_label);
}

void finish_if_without_else(void)
{
    IfContext ctx = if_stack[--if_stack_top];
    emit_br(ctx.end_label);
    emit_label(ctx.else_label);
    emit_br(ctx.end_label);
    emit_label(ctx.end_label);
}

void finish_if_with_else(void)
{
    IfContext ctx = if_stack[--if_stack_top];
    ctx.else_terminated = current_block_terminated;
    if (ctx.then_terminated && ctx.else_terminated) {
        current_block_terminated = 1;
        return;
    }
    emit_br(ctx.end_label);
    emit_label(ctx.end_label);
}

void begin_while(void)
{
    char *cond_label = new_label();
    char *body_label = new_label();
    char *end_label = new_label();

    emit_br(cond_label);
    emit_label(cond_label);

    loop_stack[loop_stack_top].cond_label = cond_label;
    loop_stack[loop_stack_top].body_label = body_label;
    loop_stack[loop_stack_top].end_label = end_label;
    loop_stack_top++;
}

void while_condition(CondNode *cond)
{
    LoopContext *ctx = &loop_stack[loop_stack_top - 1];
    emit_cond_branch(cond, ctx->body_label, ctx->end_label);
    emit_label(ctx->body_label);
}

void end_while(void)
{
    LoopContext ctx = loop_stack[--loop_stack_top];
    emit_br(ctx.cond_label);
    emit_label(ctx.end_label);
}

void emit_break(void)
{
    if (loop_stack_top > 0)
        emit_br(loop_stack[loop_stack_top - 1].end_label);
}

void emit_continue(void)
{
    if (loop_stack_top > 0)
        emit_br(loop_stack[loop_stack_top - 1].cond_label);
}

Value *lvalue_from_symbol(Symbol *sym, ArgList *indices)
{
    if (!sym)
        return new_const_value(0);

    if (sym->is_const && !sym->is_array)
        return new_const_value(sym->const_value);

    if (!sym->is_array || !indices || indices->count == 0)
        return new_lvalue(sym->ptr);

    char *base = sym->ptr;
    if (sym->is_global) {
        base = new_reg();
        fprintf(ir_file, "  %s = bitcast [%d x i32]* %s to i32*\n", base, sym->total_size, sym->ptr);
    }

    Value *offset = new_const_value(0);
    if (indices->count == 1) {
        offset = indices->args[0];
    } else if (indices->count >= 2) {
        Value *row = emit_binary("mul", indices->args[0], new_const_value(sym->dims[1]));
        offset = emit_binary("add", row, indices->args[1]);
    }

    char *idx = value_as_rvalue(offset);
    char *ptr = new_reg();
    fprintf(ir_file, "  %s = getelementptr i32, i32* %s, i32 %s\n", ptr, base, idx);
    return new_lvalue(ptr);
}

Value *emit_binary(const char *op, Value *lhs, Value *rhs)
{
    if (const_eval_mode) {
        int left = lhs ? lhs->const_value : 0;
        int right = rhs ? rhs->const_value : 0;
        if (strcmp(op, "add") == 0)
            return new_const_value(left + right);
        if (strcmp(op, "sub") == 0)
            return new_const_value(left - right);
        if (strcmp(op, "mul") == 0)
            return new_const_value(left * right);
        if (strcmp(op, "sdiv") == 0)
            return new_const_value(right == 0 ? 0 : left / right);
        if (strcmp(op, "srem") == 0)
            return new_const_value(right == 0 ? 0 : left % right);
        if (strcmp(op, "and") == 0)
            return new_const_value(left && right);
        if (strcmp(op, "or") == 0)
            return new_const_value(left || right);
    }

    char *left = value_as_rvalue(lhs);
    char *right = value_as_rvalue(rhs);
    char *reg = new_reg();
    fprintf(ir_file, "  %s = %s i32 %s, %s\n", reg, op, left, right);
    return new_value(reg);
}

Value *emit_compare(const char *pred, Value *lhs, Value *rhs)
{
    if (const_eval_mode) {
        int left = lhs ? lhs->const_value : 0;
        int right = rhs ? rhs->const_value : 0;
        if (strcmp(pred, "slt") == 0)
            return new_const_value(left < right);
        if (strcmp(pred, "sgt") == 0)
            return new_const_value(left > right);
        if (strcmp(pred, "sle") == 0)
            return new_const_value(left <= right);
        if (strcmp(pred, "sge") == 0)
            return new_const_value(left >= right);
        if (strcmp(pred, "eq") == 0)
            return new_const_value(left == right);
        if (strcmp(pred, "ne") == 0)
            return new_const_value(left != right);
    }

    char *left = value_as_rvalue(lhs);
    char *right = value_as_rvalue(rhs);
    char *cmp = new_reg();
    char *as_i32 = new_reg();
    fprintf(ir_file, "  %s = icmp %s i32 %s, %s\n", cmp, pred, left, right);
    fprintf(ir_file, "  %s = zext i1 %s to i32\n", as_i32, cmp);
    return new_value(as_i32);
}

void emit_store(Value *target, Value *source)
{
    if (!target || !target->is_lvalue)
        return;

    char *value = value_as_rvalue(source);
    fprintf(ir_file, "  store i32 %s, i32* %s\n", value, target->ptr);
}

void emit_scanf(Value *target)
{
    if (!target || !target->is_lvalue)
        return;

    char *reg = new_reg();
    fprintf(ir_file, "  %s = call i32 @getint()\n", reg);
    fprintf(ir_file, "  store i32 %s, i32* %s\n", reg, target->ptr);
}

void emit_printf(Value *value)
{
    char *text = value_as_rvalue(value);
    fprintf(ir_file, "  call void @putint(i32 %s)\n", text);
}

Value *emit_call(const char *name, ArgList *args)
{
    char *reg = new_reg();
    char *arg_values[32];
    for (int i = 0; i < 32; ++i)
        arg_values[i] = NULL;

    for (int i = 0; args && i < args->count; ++i)
        arg_values[i] = value_as_rvalue(args->args[i]);

    fprintf(ir_file, "  %s = call i32 @%s(", reg, name);
    for (int i = 0; args && i < args->count; ++i) {
        if (i > 0)
            fprintf(ir_file, ", ");
        fprintf(ir_file, "i32 %s", arg_values[i]);
    }
    fprintf(ir_file, ")\n");
    return new_value(reg);
}

int parse_int_literal(const char *text)
{
    return (int)strtol(text, NULL, 0);
}

void emit_runtime_decls(void)
{
    fprintf(ir_file, "declare i32 @getint()\n");
    fprintf(ir_file, "declare void @putint(i32)\n");
    fprintf(ir_file, "declare void @putch(i32)\n\n");
}

void semantic_error(const char *message, const char *name)
{
    fprintf(stderr, "Semantic error: %s '%s'\n", message, name);
    semantic_error_count++;
}

void begin_function(const char *name, int return_type, ParamList *params)
{
    current_return_type = return_type;
    function_has_return = 0;
    in_function = 1;
    reset_function_state();
    push_scope();

    if (return_type == 1)
        fprintf(ir_file, "define void @%s(", name);
    else
        fprintf(ir_file, "define i32 @%s(", name);

    for (int i = 0; params && i < params->count; ++i) {
        if (i > 0)
            fprintf(ir_file, ", ");
        fprintf(ir_file, "i32 %%%s_p", params->names[i]);
    }

    fprintf(ir_file, ") {\n");

    fprintf(ir_file, "entry:\n");

    for (int i = 0; params && i < params->count; ++i) {
        char *ptr = add_local_symbol(params->names[i]);
        fprintf(ir_file, "  store i32 %%%s_p, i32* %s\n", params->names[i], ptr);
    }
}

void end_function(void)
{
    if (!function_has_return) {
        if (current_return_type == 1)
            fprintf(ir_file, "  ret void\n");
        else
            fprintf(ir_file, "  ret i32 0\n");
    }
    fprintf(ir_file, "}\n\n");
    while (current_scope_level > 0)
        pop_scope();
    in_function = 0;
}

void emit_return(Value *value)
{
    if (current_return_type == 1) {
        fprintf(ir_file, "  ret void\n");
    } else {
        char *text = value_as_rvalue(value);
        fprintf(ir_file, "  ret i32 %s\n", text);
    }
    function_has_return = 1;
    current_block_terminated = 1;
}

void yyerror(const char *s)
{
    fprintf(stderr, "Syntax error at (%d,%d): %s\n", cur_line, cur_col, s);
}
%}

%union {
    char *str;
    int ival;
    Value *value;
    CondNode *cond;
    ArgList *args;
    DimList *dims;
    ParamList *params;
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

%type <ival> BType
%type <value> Exp PrimaryExp Number UnaryExp
%type <value> MulExp AddExp RelExp EqExp ConstExp ConstInitVal
%type <cond> Cond LAndExp LOrExp
%type <value> OptExp InitVal LVal
%type <args> FuncRParams LValIndexList
%type <dims> ConstArrayDims VarArrayDims
%type <ival> ConstArrayDim VarArrayDim
%type <params> FuncFParams
%type <str> FuncFParam
%type <ival> UnaryOp

%type <ival> ConstEvalBegin
%type <ival> IfHead ElseHead
%type <ival> WhileBegin WhileCond
%type <ival> BlockBegin

%%

CompUnit
    : CompUnitItems
    ;

CompUnitItems
    : CompUnitItem
    | CompUnitItems CompUnitItem
    ;

CompUnitItem
    : Decl
    | FuncDef
    ;

Decl
    : ConstDecl
    | VarDecl
    ;

ConstDecl
    : CONST BType ConstDefs SEMICOLON
    ;

ConstDefs
    : ConstDef
    | ConstDefs COMMA ConstDef
    ;

BType
    : INT { $$ = 0; }
    ;

ConstDef
    : IDENT ConstArrayDims ASSIGN ConstInitVal
      {
          if (in_function) {
              if ($2 && $2->count > 0) {
                  add_local_array_symbol($1, $2);
              } else {
                  add_local_const_symbol($1, const_value_of($4));
              }
          } else {
              add_global_symbol($1, $2, 1, const_value_of($4));
          }
      }
    ;

ConstArrayDims
    : /* empty */ { $$ = new_dim_list(); }
    | ConstArrayDims ConstArrayDim { $$ = append_dim($1, $2); }
    ;

ConstArrayDim
    : LBRACK ConstEvalBegin ConstExp RBRACK
      {
          const_eval_mode = $2;
          $$ = const_value_of($3);
      }
    ;

ConstInitVal
    : ConstEvalBegin ConstExp
      {
          const_eval_mode = $1;
          $$ = $2;
      }
    | LBRACE ConstInitValList RBRACE
      {
          $$ = new_const_value(0);
      }
    ;

ConstInitValList
    : /* empty */
    | ConstInitVal
    | ConstInitValList COMMA ConstInitVal
    ;

VarDecl
    : BType VarDefs SEMICOLON
    ;

VarDefs
    : VarDef
    | VarDefs COMMA VarDef
    ;

VarDef
    : IDENT VarArrayDims
      {
          if (in_function) {
              if ($2 && $2->count > 0)
                  add_local_array_symbol($1, $2);
              else
                  add_local_symbol($1);
          } else {
              add_global_symbol($1, $2, 0, 0);
          }
      }
    | IDENT VarArrayDims ASSIGN InitVal
      {
          if (in_function) {
              if ($2 && $2->count > 0) {
                  add_local_array_symbol($1, $2);
              } else {
                  char *ptr = add_local_symbol($1);
                  emit_store(new_lvalue(ptr), $4);
              }
          } else {
              add_global_symbol($1, $2, 0, const_value_of($4));
          }
      }
    ;

VarArrayDims
    : /* empty */ { $$ = new_dim_list(); }
    | VarArrayDims VarArrayDim { $$ = append_dim($1, $2); }
    ;

VarArrayDim
    : LBRACK ConstEvalBegin ConstExp RBRACK
      {
          const_eval_mode = $2;
          $$ = const_value_of($3);
      }
    ;

InitVal
    : Exp { $$ = $1; }
    | LBRACE InitValList RBRACE
      {
          $$ = new_const_value(0);
      }
    ;

InitValList
    : /* empty */
    | InitVal
    | InitValList COMMA InitVal
    ;

FuncDef
    : BType IDENT LPAREN FuncFParams RPAREN
      {
          begin_function($2, $1, $4);
      }
      Block
      {
          end_function();
      }
    | VOID IDENT LPAREN FuncFParams RPAREN
      {
          begin_function($2, 1, $4);
      }
      Block
      {
          end_function();
      }
    ;

FuncFParams
    : /* empty */ { $$ = new_param_list(); }
    | FuncFParam { $$ = append_param(new_param_list(), $1); }
    | FuncFParams COMMA FuncFParam { $$ = append_param($1, $3); }
    ;

FuncFParam
    : BType IDENT FuncArraySuffixs
      {
          $$ = $2;
      }
    ;

FuncArraySuffixs
    : /* empty */
    | LBRACK RBRACK FuncArraySuffix
    ;

FuncArraySuffix
    : /* empty */
    | FuncArraySuffix LBRACK Exp RBRACK
    ;

Block
    : BlockBegin BlockItems RBRACE
      {
          pop_scope();
      }
    ;

BlockBegin
    : LBRACE
      {
          push_scope();
          $$ = 0;
      }
    ;

BlockItems
    : /* empty */
    | BlockItems BlockItem
    ;

BlockItem
    : Decl
    | Stmt
    ;

Stmt
    : MatchedStmt
    | UnmatchedStmt
    ;

MatchedStmt
    : NonIfStmt
    | IfHead MatchedStmt ElseHead MatchedStmt
      {
          finish_if_with_else();
      }
    | WhileBegin WhileCond MatchedStmt
      {
          end_while();
      }
    ;

UnmatchedStmt
    : IfHead Stmt
      {
          finish_if_without_else();
      }
    | IfHead MatchedStmt ElseHead UnmatchedStmt
      {
          finish_if_with_else();
      }
    | WhileBegin WhileCond UnmatchedStmt
      {
          end_while();
      }
    ;

NonIfStmt
    : LVal ASSIGN Exp SEMICOLON
      {
          emit_store($1, $3);
      }
    | OptExp SEMICOLON
    | Block
    | BREAK SEMICOLON
      {
          emit_break();
      }
    | CONTINUE SEMICOLON
      {
          emit_continue();
      }
    | RETURN OptExp SEMICOLON
      {
          emit_return($2);
      }
    ;

OptExp
    : /* empty */ { $$ = new_const_value(0); }
    | Exp { $$ = $1; }
    ;

Exp
    : AddExp { $$ = $1; }
    ;

Cond
    : LOrExp { $$ = $1; }
    ;

LVal
    : IDENT LValIndexList
      {
          Symbol *sym = find_symbol($1);
          if (sym)
              $$ = lvalue_from_symbol(sym, $2);
          else {
              semantic_error("undefined symbol", $1);
              $$ = new_const_value(0);
          }
      }
    ;

LValIndexList
    : /* empty */ { $$ = new_arg_list(); }
    | LValIndexList LBRACK Exp RBRACK { $$ = append_arg($1, $3); }
    ;

PrimaryExp
    : LPAREN Exp RPAREN { $$ = $2; }
    | LVal { $$ = $1; }
    | Number { $$ = $1; }
    ;

Number
    : INT_CONST
      {
          $$ = new_const_value(parse_int_literal($1));
      }
    ;

UnaryExp
    : PrimaryExp { $$ = $1; }
    | IDENT LPAREN FuncRParams RPAREN
      {
          if (strcmp($1, "scanf") == 0) {
              if ($3 && $3->count > 0)
                  emit_scanf($3->args[0]);
              $$ = new_const_value(0);
          } else if (strcmp($1, "printf") == 0) {
              if ($3 && $3->count > 0)
                  emit_printf($3->args[0]);
              $$ = new_const_value(0);
          } else {
              $$ = emit_call($1, $3);
          }
      }
    | UnaryOp UnaryExp
      {
          if ($1 == 1)
              $$ = emit_binary("sub", new_const_value(0), $2);
          else if ($1 == 2)
              $$ = emit_compare("eq", $2, new_const_value(0));
          else
              $$ = $2;
      }
    ;

UnaryOp
    : PLUS { $$ = 0; }
    | MINUS { $$ = 1; }
    | NOT { $$ = 2; }
    ;

FuncRParams
    : /* empty */ { $$ = new_arg_list(); }
    | Exp { $$ = append_arg(new_arg_list(), $1); }
    | FuncRParams COMMA Exp { $$ = append_arg($1, $3); }
    ;

MulExp
    : UnaryExp { $$ = $1; }
    | MulExp MUL UnaryExp { $$ = emit_binary("mul", $1, $3); }
    | MulExp DIV UnaryExp { $$ = emit_binary("sdiv", $1, $3); }
    | MulExp MOD UnaryExp { $$ = emit_binary("srem", $1, $3); }
    ;

AddExp
    : MulExp { $$ = $1; }
    | AddExp PLUS MulExp { $$ = emit_binary("add", $1, $3); }
    | AddExp MINUS MulExp { $$ = emit_binary("sub", $1, $3); }
    ;

RelExp
    : AddExp { $$ = $1; }
    | RelExp LT AddExp { $$ = emit_compare("slt", $1, $3); }
    | RelExp GT AddExp { $$ = emit_compare("sgt", $1, $3); }
    | RelExp LE AddExp { $$ = emit_compare("sle", $1, $3); }
    | RelExp GE AddExp { $$ = emit_compare("sge", $1, $3); }
    ;

EqExp
    : RelExp { $$ = $1; }
    | EqExp EQ RelExp { $$ = emit_compare("eq", $1, $3); }
    | EqExp NE RelExp { $$ = emit_compare("ne", $1, $3); }
    ;

LAndExp
    : EqExp { $$ = new_cond_value($1); }
    | LAndExp AND EqExp
      {
          $$ = new_cond_binary(1, $1, new_cond_value($3));
      }
    ;

LOrExp
    : LAndExp { $$ = $1; }
    | LOrExp OR LAndExp
      {
          $$ = new_cond_binary(2, $1, $3);
      }
    ;

ConstExp
    : AddExp { $$ = $1; }
    ;

ConstEvalBegin
    : /* empty */
      {
          $$ = const_eval_mode;
          const_eval_mode = 1;
      }
    ;

IfHead
    : IF LPAREN Cond RPAREN
      {
          begin_if_unified($3);
          $$ = 0;
      }
    ;

ElseHead
    : ELSE
      {
          switch_to_else();
          $$ = 0;
      }
    ;

WhileBegin
    : WHILE
      {
          begin_while();
          $$ = 0;
      }
    ;

WhileCond
    : LPAREN Cond RPAREN
      {
          while_condition($2);
          $$ = 0;
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

    ir_file = fopen("output.ll", "w");
    if (!ir_file) {
        perror("fopen");
        return 1;
    }

    emit_runtime_decls();

    int parse_result = yyparse();

    if (ir_file) fclose(ir_file);
    if (argc > 1 && yyin) fclose(yyin);

    if (parse_result == 0 && semantic_error_count == 0) {
        printf("LLVM IR generated: output.ll\n");
        return 0;
    }

    if (semantic_error_count > 0)
        fprintf(stderr, "Semantic analysis failed with %d error(s).\n", semantic_error_count);

    return 1;
}
