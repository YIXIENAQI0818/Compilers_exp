/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 1 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"

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

#line 825 "y.tab.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

/* Use api.header.include to #include this header
   instead of duplicating it here.  */
#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    CONST = 258,                   /* CONST  */
    INT = 259,                     /* INT  */
    VOID = 260,                    /* VOID  */
    IF = 261,                      /* IF  */
    ELSE = 262,                    /* ELSE  */
    WHILE = 263,                   /* WHILE  */
    BREAK = 264,                   /* BREAK  */
    CONTINUE = 265,                /* CONTINUE  */
    RETURN = 266,                  /* RETURN  */
    EQ = 267,                      /* EQ  */
    NE = 268,                      /* NE  */
    LE = 269,                      /* LE  */
    GE = 270,                      /* GE  */
    AND = 271,                     /* AND  */
    OR = 272,                      /* OR  */
    PLUS = 273,                    /* PLUS  */
    MINUS = 274,                   /* MINUS  */
    MUL = 275,                     /* MUL  */
    DIV = 276,                     /* DIV  */
    MOD = 277,                     /* MOD  */
    ASSIGN = 278,                  /* ASSIGN  */
    LT = 279,                      /* LT  */
    GT = 280,                      /* GT  */
    NOT = 281,                     /* NOT  */
    SEMICOLON = 282,               /* SEMICOLON  */
    COMMA = 283,                   /* COMMA  */
    LPAREN = 284,                  /* LPAREN  */
    RPAREN = 285,                  /* RPAREN  */
    LBRACK = 286,                  /* LBRACK  */
    RBRACK = 287,                  /* RBRACK  */
    LBRACE = 288,                  /* LBRACE  */
    RBRACE = 289,                  /* RBRACE  */
    IDENT = 290,                   /* IDENT  */
    INT_CONST = 291,               /* INT_CONST  */
    LOWER_THAN_ELSE = 292          /* LOWER_THAN_ELSE  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEMPTY -2
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define CONST 258
#define INT 259
#define VOID 260
#define IF 261
#define ELSE 262
#define WHILE 263
#define BREAK 264
#define CONTINUE 265
#define RETURN 266
#define EQ 267
#define NE 268
#define LE 269
#define GE 270
#define AND 271
#define OR 272
#define PLUS 273
#define MINUS 274
#define MUL 275
#define DIV 276
#define MOD 277
#define ASSIGN 278
#define LT 279
#define GT 280
#define NOT 281
#define SEMICOLON 282
#define COMMA 283
#define LPAREN 284
#define RPAREN 285
#define LBRACK 286
#define RBRACK 287
#define LBRACE 288
#define RBRACE 289
#define IDENT 290
#define INT_CONST 291
#define LOWER_THAN_ELSE 292

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 755 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"

    char *str;
    int ival;
    Value *value;
    CondNode *cond;
    ArgList *args;
    DimList *dims;
    ParamList *params;

#line 962 "y.tab.c"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_CONST = 3,                      /* CONST  */
  YYSYMBOL_INT = 4,                        /* INT  */
  YYSYMBOL_VOID = 5,                       /* VOID  */
  YYSYMBOL_IF = 6,                         /* IF  */
  YYSYMBOL_ELSE = 7,                       /* ELSE  */
  YYSYMBOL_WHILE = 8,                      /* WHILE  */
  YYSYMBOL_BREAK = 9,                      /* BREAK  */
  YYSYMBOL_CONTINUE = 10,                  /* CONTINUE  */
  YYSYMBOL_RETURN = 11,                    /* RETURN  */
  YYSYMBOL_EQ = 12,                        /* EQ  */
  YYSYMBOL_NE = 13,                        /* NE  */
  YYSYMBOL_LE = 14,                        /* LE  */
  YYSYMBOL_GE = 15,                        /* GE  */
  YYSYMBOL_AND = 16,                       /* AND  */
  YYSYMBOL_OR = 17,                        /* OR  */
  YYSYMBOL_PLUS = 18,                      /* PLUS  */
  YYSYMBOL_MINUS = 19,                     /* MINUS  */
  YYSYMBOL_MUL = 20,                       /* MUL  */
  YYSYMBOL_DIV = 21,                       /* DIV  */
  YYSYMBOL_MOD = 22,                       /* MOD  */
  YYSYMBOL_ASSIGN = 23,                    /* ASSIGN  */
  YYSYMBOL_LT = 24,                        /* LT  */
  YYSYMBOL_GT = 25,                        /* GT  */
  YYSYMBOL_NOT = 26,                       /* NOT  */
  YYSYMBOL_SEMICOLON = 27,                 /* SEMICOLON  */
  YYSYMBOL_COMMA = 28,                     /* COMMA  */
  YYSYMBOL_LPAREN = 29,                    /* LPAREN  */
  YYSYMBOL_RPAREN = 30,                    /* RPAREN  */
  YYSYMBOL_LBRACK = 31,                    /* LBRACK  */
  YYSYMBOL_RBRACK = 32,                    /* RBRACK  */
  YYSYMBOL_LBRACE = 33,                    /* LBRACE  */
  YYSYMBOL_RBRACE = 34,                    /* RBRACE  */
  YYSYMBOL_IDENT = 35,                     /* IDENT  */
  YYSYMBOL_INT_CONST = 36,                 /* INT_CONST  */
  YYSYMBOL_LOWER_THAN_ELSE = 37,           /* LOWER_THAN_ELSE  */
  YYSYMBOL_YYACCEPT = 38,                  /* $accept  */
  YYSYMBOL_CompUnit = 39,                  /* CompUnit  */
  YYSYMBOL_CompUnitItems = 40,             /* CompUnitItems  */
  YYSYMBOL_CompUnitItem = 41,              /* CompUnitItem  */
  YYSYMBOL_Decl = 42,                      /* Decl  */
  YYSYMBOL_ConstDecl = 43,                 /* ConstDecl  */
  YYSYMBOL_ConstDefs = 44,                 /* ConstDefs  */
  YYSYMBOL_BType = 45,                     /* BType  */
  YYSYMBOL_ConstDef = 46,                  /* ConstDef  */
  YYSYMBOL_ConstArrayDims = 47,            /* ConstArrayDims  */
  YYSYMBOL_ConstArrayDim = 48,             /* ConstArrayDim  */
  YYSYMBOL_ConstInitVal = 49,              /* ConstInitVal  */
  YYSYMBOL_ConstInitValList = 50,          /* ConstInitValList  */
  YYSYMBOL_VarDecl = 51,                   /* VarDecl  */
  YYSYMBOL_VarDefs = 52,                   /* VarDefs  */
  YYSYMBOL_VarDef = 53,                    /* VarDef  */
  YYSYMBOL_VarArrayDims = 54,              /* VarArrayDims  */
  YYSYMBOL_VarArrayDim = 55,               /* VarArrayDim  */
  YYSYMBOL_InitVal = 56,                   /* InitVal  */
  YYSYMBOL_InitValList = 57,               /* InitValList  */
  YYSYMBOL_FuncDef = 58,                   /* FuncDef  */
  YYSYMBOL_59_1 = 59,                      /* $@1  */
  YYSYMBOL_60_2 = 60,                      /* $@2  */
  YYSYMBOL_FuncFParams = 61,               /* FuncFParams  */
  YYSYMBOL_FuncFParam = 62,                /* FuncFParam  */
  YYSYMBOL_FuncArraySuffixs = 63,          /* FuncArraySuffixs  */
  YYSYMBOL_FuncArraySuffix = 64,           /* FuncArraySuffix  */
  YYSYMBOL_Block = 65,                     /* Block  */
  YYSYMBOL_BlockBegin = 66,                /* BlockBegin  */
  YYSYMBOL_BlockItems = 67,                /* BlockItems  */
  YYSYMBOL_BlockItem = 68,                 /* BlockItem  */
  YYSYMBOL_Stmt = 69,                      /* Stmt  */
  YYSYMBOL_MatchedStmt = 70,               /* MatchedStmt  */
  YYSYMBOL_UnmatchedStmt = 71,             /* UnmatchedStmt  */
  YYSYMBOL_NonIfStmt = 72,                 /* NonIfStmt  */
  YYSYMBOL_OptExp = 73,                    /* OptExp  */
  YYSYMBOL_Exp = 74,                       /* Exp  */
  YYSYMBOL_Cond = 75,                      /* Cond  */
  YYSYMBOL_LVal = 76,                      /* LVal  */
  YYSYMBOL_LValIndexList = 77,             /* LValIndexList  */
  YYSYMBOL_PrimaryExp = 78,                /* PrimaryExp  */
  YYSYMBOL_Number = 79,                    /* Number  */
  YYSYMBOL_UnaryExp = 80,                  /* UnaryExp  */
  YYSYMBOL_UnaryOp = 81,                   /* UnaryOp  */
  YYSYMBOL_FuncRParams = 82,               /* FuncRParams  */
  YYSYMBOL_MulExp = 83,                    /* MulExp  */
  YYSYMBOL_AddExp = 84,                    /* AddExp  */
  YYSYMBOL_RelExp = 85,                    /* RelExp  */
  YYSYMBOL_EqExp = 86,                     /* EqExp  */
  YYSYMBOL_LAndExp = 87,                   /* LAndExp  */
  YYSYMBOL_LOrExp = 88,                    /* LOrExp  */
  YYSYMBOL_ConstExp = 89,                  /* ConstExp  */
  YYSYMBOL_ConstEvalBegin = 90,            /* ConstEvalBegin  */
  YYSYMBOL_IfHead = 91,                    /* IfHead  */
  YYSYMBOL_ElseHead = 92,                  /* ElseHead  */
  YYSYMBOL_WhileBegin = 93,                /* WhileBegin  */
  YYSYMBOL_WhileCond = 94                  /* WhileCond  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_uint8 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if !defined yyoverflow

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* !defined yyoverflow */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  14
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   174

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  38
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  57
/* YYNRULES -- Number of rules.  */
#define YYNRULES  111
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  185

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   292


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   796,   796,   800,   801,   805,   806,   810,   811,   815,
     819,   820,   824,   828,   843,   844,   848,   856,   861,   868,
     869,   870,   874,   878,   879,   883,   894,   910,   911,   915,
     923,   924,   931,   932,   933,   938,   937,   946,   945,   956,
     957,   958,   962,   969,   970,   974,   975,   979,   986,   994,
     995,   999,  1000,  1004,  1005,  1009,  1010,  1014,  1021,  1025,
    1029,  1036,  1040,  1041,  1042,  1046,  1050,  1057,  1058,  1062,
    1066,  1070,  1083,  1084,  1088,  1089,  1090,  1094,  1101,  1102,
    1116,  1128,  1129,  1130,  1134,  1135,  1136,  1140,  1141,  1142,
    1143,  1147,  1148,  1149,  1153,  1154,  1155,  1156,  1157,  1161,
    1162,  1163,  1167,  1168,  1175,  1176,  1183,  1188,  1195,  1203,
    1211,  1219
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if YYDEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "CONST", "INT", "VOID",
  "IF", "ELSE", "WHILE", "BREAK", "CONTINUE", "RETURN", "EQ", "NE", "LE",
  "GE", "AND", "OR", "PLUS", "MINUS", "MUL", "DIV", "MOD", "ASSIGN", "LT",
  "GT", "NOT", "SEMICOLON", "COMMA", "LPAREN", "RPAREN", "LBRACK",
  "RBRACK", "LBRACE", "RBRACE", "IDENT", "INT_CONST", "LOWER_THAN_ELSE",
  "$accept", "CompUnit", "CompUnitItems", "CompUnitItem", "Decl",
  "ConstDecl", "ConstDefs", "BType", "ConstDef", "ConstArrayDims",
  "ConstArrayDim", "ConstInitVal", "ConstInitValList", "VarDecl",
  "VarDefs", "VarDef", "VarArrayDims", "VarArrayDim", "InitVal",
  "InitValList", "FuncDef", "$@1", "$@2", "FuncFParams", "FuncFParam",
  "FuncArraySuffixs", "FuncArraySuffix", "Block", "BlockBegin",
  "BlockItems", "BlockItem", "Stmt", "MatchedStmt", "UnmatchedStmt",
  "NonIfStmt", "OptExp", "Exp", "Cond", "LVal", "LValIndexList",
  "PrimaryExp", "Number", "UnaryExp", "UnaryOp", "FuncRParams", "MulExp",
  "AddExp", "RelExp", "EqExp", "LAndExp", "LOrExp", "ConstExp",
  "ConstEvalBegin", "IfHead", "ElseHead", "WhileBegin", "WhileCond", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-138)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-20)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
      21,    46,  -138,    56,    47,    21,  -138,  -138,  -138,    63,
    -138,  -138,    68,    49,  -138,  -138,    76,    59,  -138,  -138,
      81,  -138,    46,    46,    -1,  -138,   100,    22,  -138,    68,
     101,    27,  -138,    37,    71,  -138,  -138,  -138,  -138,    23,
    -138,  -138,  -138,    79,    46,  -138,  -138,  -138,  -138,  -138,
     103,    71,   108,  -138,  -138,  -138,  -138,  -138,  -138,  -138,
     103,    60,    75,   103,    35,  -138,   103,   103,   109,  -138,
    -138,   107,   107,   112,  -138,    12,   103,   113,  -138,   103,
     103,   103,   103,   103,    75,   114,  -138,    36,  -138,   115,
    -138,  -138,  -138,  -138,  -138,  -138,    71,  -138,  -138,    43,
     103,  -138,  -138,  -138,    60,    60,  -138,    23,  -138,  -138,
     117,    25,  -138,   103,  -138,   118,  -138,   103,   116,  -138,
     122,   124,   103,  -138,  -138,   100,  -138,  -138,  -138,  -138,
    -138,  -138,   125,  -138,   120,    66,   126,  -138,  -138,   121,
     103,  -138,  -138,   127,  -138,   103,  -138,   149,   103,    66,
    -138,   128,    75,    -5,   111,   141,   142,  -138,   133,  -138,
      66,   131,  -138,  -138,  -138,   103,   103,   103,   103,   103,
     103,   103,   103,  -138,  -138,  -138,  -138,    75,    75,    75,
      75,    -5,    -5,   111,   141
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       0,     0,    12,     0,     0,     2,     3,     5,     7,     0,
       8,     6,     0,     0,     1,     4,    27,     0,    23,    14,
       0,    10,    39,    39,    25,    22,     0,     0,     9,     0,
       0,     0,    40,     0,     0,   107,    28,    27,    24,   107,
     107,    15,    11,    43,     0,    37,    35,    81,    82,    83,
       0,    32,    72,    77,    26,    30,    75,    78,    76,    87,
       0,    91,    69,     0,   107,    13,     0,     0,     0,    42,
      41,     0,     0,     0,    33,     0,    84,    71,    80,     0,
       0,     0,     0,     0,   106,     0,    20,     0,    17,     0,
      45,    48,    38,    49,    36,    74,     0,    31,    85,     0,
       0,    88,    89,    90,    92,    93,    29,   107,    18,    16,
      44,    67,    34,     0,    79,     0,    21,     0,     0,   110,
       0,     0,    67,    47,    51,     0,    63,    50,    52,    53,
      54,    55,     0,    68,    75,    67,     0,    86,    73,     0,
       0,    64,    65,     0,    62,     0,    58,    53,     0,    67,
      46,     0,    94,    99,   102,   104,    70,    66,     0,   109,
      67,     0,    57,    60,   108,     0,     0,     0,     0,     0,
       0,     0,     0,    61,    56,    59,   111,    97,    98,    95,
      96,   100,   101,   103,   105
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -138,  -138,  -138,   157,    52,  -138,  -138,     1,   135,  -138,
    -138,   -59,  -138,  -138,  -138,   139,  -138,  -138,   -47,  -138,
    -138,  -138,  -138,   143,   123,  -138,  -138,    54,  -138,  -138,
    -138,    33,  -128,  -137,  -138,    48,   -34,    24,  -108,  -138,
    -138,  -138,   -42,  -138,  -138,    45,   -52,   -39,    -2,     2,
    -138,    67,   -27,  -138,  -138,  -138,  -138
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_uint8 yydefgoto[] =
{
       0,     4,     5,     6,     7,     8,    20,    30,    21,    27,
      41,    65,    87,    10,    17,    18,    24,    36,    54,    75,
      11,    72,    71,    31,    32,    69,   110,   126,    93,   111,
     127,   128,   129,   130,   131,   132,   133,   151,    56,    77,
      57,    58,    59,    60,    99,    61,    62,   153,   154,   155,
     156,    85,    66,   135,   160,   136,   149
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      55,     9,    12,   134,    74,    86,     9,   147,    63,   165,
     166,    84,   163,    67,    84,    84,    73,    55,    78,   167,
     168,   162,    34,   175,     1,     2,     3,   134,     1,     2,
      35,   118,   174,   119,   120,   121,   122,   101,   102,   103,
      96,   134,    98,    47,    48,    39,    97,    14,   116,   112,
       2,    49,   134,    40,    50,    44,    64,    45,    91,   123,
      52,    53,    55,   -19,   107,    44,   115,    46,    64,   -19,
     108,   113,   118,   114,   119,   120,   121,   122,    22,   137,
      79,    80,    81,   139,    47,    48,    25,    26,   152,    47,
      48,    13,    49,    82,    83,    50,   152,    49,    16,    91,
      50,    52,    53,    19,    51,    23,    52,    53,    28,    29,
      68,   158,   125,   177,   178,   179,   180,   152,   152,   152,
     152,    47,    48,   169,   170,    92,    94,   104,   105,    49,
     181,   182,    50,    88,    89,    37,    43,    76,    52,    53,
      91,    90,    95,   145,   100,   140,   106,   109,   117,   141,
     138,   142,   144,   150,   157,   148,   159,   171,   164,   172,
     173,   176,    15,   124,    42,    38,    33,    70,   146,   183,
     143,     0,   161,     0,   184
};

static const yytype_int16 yycheck[] =
{
      34,     0,     1,   111,    51,    64,     5,   135,    35,    14,
      15,    63,   149,    40,    66,    67,    50,    51,    60,    24,
      25,   149,    23,   160,     3,     4,     5,   135,     3,     4,
      31,     6,   160,     8,     9,    10,    11,    79,    80,    81,
      28,   149,    76,    18,    19,    23,    34,     0,   107,    96,
       4,    26,   160,    31,    29,    28,    33,    30,    33,    34,
      35,    36,    96,    28,    28,    28,   100,    30,    33,    34,
      34,    28,     6,    30,     8,     9,    10,    11,    29,   113,
      20,    21,    22,   117,    18,    19,    27,    28,   140,    18,
      19,    35,    26,    18,    19,    29,   148,    26,    35,    33,
      29,    35,    36,    35,    33,    29,    35,    36,    27,    28,
      31,   145,   111,   165,   166,   167,   168,   169,   170,   171,
     172,    18,    19,    12,    13,    71,    72,    82,    83,    26,
     169,   170,    29,    66,    67,    35,    35,    29,    35,    36,
      33,    32,    30,    23,    31,    29,    32,    32,    31,    27,
      32,    27,    27,    32,    27,    29,     7,    16,    30,    17,
      27,    30,     5,   111,    29,    26,    23,    44,   135,   171,
     122,    -1,   148,    -1,   172
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,     3,     4,     5,    39,    40,    41,    42,    43,    45,
      51,    58,    45,    35,     0,    41,    35,    52,    53,    35,
      44,    46,    29,    29,    54,    27,    28,    47,    27,    28,
      45,    61,    62,    61,    23,    31,    55,    35,    53,    23,
      31,    48,    46,    35,    28,    30,    30,    18,    19,    26,
      29,    33,    35,    36,    56,    74,    76,    78,    79,    80,
      81,    83,    84,    90,    33,    49,    90,    90,    31,    63,
      62,    60,    59,    74,    56,    57,    29,    77,    80,    20,
      21,    22,    18,    19,    84,    89,    49,    50,    89,    89,
      32,    33,    65,    66,    65,    30,    28,    34,    74,    82,
      31,    80,    80,    80,    83,    83,    32,    28,    34,    32,
      64,    67,    56,    28,    30,    74,    49,    31,     6,     8,
       9,    10,    11,    34,    42,    45,    65,    68,    69,    70,
      71,    72,    73,    74,    76,    91,    93,    74,    32,    74,
      29,    27,    27,    73,    27,    23,    69,    70,    29,    94,
      32,    75,    84,    85,    86,    87,    88,    27,    74,     7,
      92,    75,    70,    71,    30,    14,    15,    24,    25,    12,
      13,    16,    17,    27,    70,    71,    30,    84,    84,    84,
      84,    85,    85,    86,    87
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    38,    39,    40,    40,    41,    41,    42,    42,    43,
      44,    44,    45,    46,    47,    47,    48,    49,    49,    50,
      50,    50,    51,    52,    52,    53,    53,    54,    54,    55,
      56,    56,    57,    57,    57,    59,    58,    60,    58,    61,
      61,    61,    62,    63,    63,    64,    64,    65,    66,    67,
      67,    68,    68,    69,    69,    70,    70,    70,    71,    71,
      71,    72,    72,    72,    72,    72,    72,    73,    73,    74,
      75,    76,    77,    77,    78,    78,    78,    79,    80,    80,
      80,    81,    81,    81,    82,    82,    82,    83,    83,    83,
      83,    84,    84,    84,    85,    85,    85,    85,    85,    86,
      86,    86,    87,    87,    88,    88,    89,    90,    91,    92,
      93,    94
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     1,     2,     1,     1,     1,     1,     4,
       1,     3,     1,     4,     0,     2,     4,     2,     3,     0,
       1,     3,     3,     1,     3,     2,     4,     0,     2,     4,
       1,     3,     0,     1,     3,     0,     7,     0,     7,     0,
       1,     3,     3,     0,     3,     0,     4,     3,     1,     0,
       2,     1,     1,     1,     1,     1,     4,     3,     2,     4,
       3,     4,     2,     1,     2,     2,     3,     0,     1,     1,
       1,     2,     0,     4,     3,     1,     1,     1,     1,     4,
       2,     1,     1,     1,     0,     1,     3,     1,     3,     3,
       3,     1,     3,     3,     1,     3,     3,     3,     3,     1,
       3,     3,     1,     3,     1,     3,     1,     0,     4,     1,
       1,     3
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)]);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif






/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep)
{
  YY_USE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = YYEOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 12: /* BType: INT  */
#line 824 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
          { (yyval.ival) = 0; }
#line 2170 "y.tab.c"
    break;

  case 13: /* ConstDef: IDENT ConstArrayDims ASSIGN ConstInitVal  */
#line 829 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          if (in_function) {
              if ((yyvsp[-2].dims) && (yyvsp[-2].dims)->count > 0) {
                  add_local_array_symbol((yyvsp[-3].str), (yyvsp[-2].dims));
              } else {
                  add_local_const_symbol((yyvsp[-3].str), const_value_of((yyvsp[0].value)));
              }
          } else {
              add_global_symbol((yyvsp[-3].str), (yyvsp[-2].dims), 1, const_value_of((yyvsp[0].value)));
          }
      }
#line 2186 "y.tab.c"
    break;

  case 14: /* ConstArrayDims: %empty  */
#line 843 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                  { (yyval.dims) = new_dim_list(); }
#line 2192 "y.tab.c"
    break;

  case 15: /* ConstArrayDims: ConstArrayDims ConstArrayDim  */
#line 844 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                                   { (yyval.dims) = append_dim((yyvsp[-1].dims), (yyvsp[0].ival)); }
#line 2198 "y.tab.c"
    break;

  case 16: /* ConstArrayDim: LBRACK ConstEvalBegin ConstExp RBRACK  */
#line 849 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          const_eval_mode = (yyvsp[-2].ival);
          (yyval.ival) = const_value_of((yyvsp[-1].value));
      }
#line 2207 "y.tab.c"
    break;

  case 17: /* ConstInitVal: ConstEvalBegin ConstExp  */
#line 857 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          const_eval_mode = (yyvsp[-1].ival);
          (yyval.value) = (yyvsp[0].value);
      }
#line 2216 "y.tab.c"
    break;

  case 18: /* ConstInitVal: LBRACE ConstInitValList RBRACE  */
#line 862 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          (yyval.value) = new_const_value(0);
      }
#line 2224 "y.tab.c"
    break;

  case 25: /* VarDef: IDENT VarArrayDims  */
#line 884 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          if (in_function) {
              if ((yyvsp[0].dims) && (yyvsp[0].dims)->count > 0)
                  add_local_array_symbol((yyvsp[-1].str), (yyvsp[0].dims));
              else
                  add_local_symbol((yyvsp[-1].str));
          } else {
              add_global_symbol((yyvsp[-1].str), (yyvsp[0].dims), 0, 0);
          }
      }
#line 2239 "y.tab.c"
    break;

  case 26: /* VarDef: IDENT VarArrayDims ASSIGN InitVal  */
#line 895 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          if (in_function) {
              if ((yyvsp[-2].dims) && (yyvsp[-2].dims)->count > 0) {
                  add_local_array_symbol((yyvsp[-3].str), (yyvsp[-2].dims));
              } else {
                  char *ptr = add_local_symbol((yyvsp[-3].str));
                  emit_store(new_lvalue(ptr), (yyvsp[0].value));
              }
          } else {
              add_global_symbol((yyvsp[-3].str), (yyvsp[-2].dims), 0, const_value_of((yyvsp[0].value)));
          }
      }
#line 2256 "y.tab.c"
    break;

  case 27: /* VarArrayDims: %empty  */
#line 910 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                  { (yyval.dims) = new_dim_list(); }
#line 2262 "y.tab.c"
    break;

  case 28: /* VarArrayDims: VarArrayDims VarArrayDim  */
#line 911 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                               { (yyval.dims) = append_dim((yyvsp[-1].dims), (yyvsp[0].ival)); }
#line 2268 "y.tab.c"
    break;

  case 29: /* VarArrayDim: LBRACK ConstEvalBegin ConstExp RBRACK  */
#line 916 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          const_eval_mode = (yyvsp[-2].ival);
          (yyval.ival) = const_value_of((yyvsp[-1].value));
      }
#line 2277 "y.tab.c"
    break;

  case 30: /* InitVal: Exp  */
#line 923 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
          { (yyval.value) = (yyvsp[0].value); }
#line 2283 "y.tab.c"
    break;

  case 31: /* InitVal: LBRACE InitValList RBRACE  */
#line 925 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          (yyval.value) = new_const_value(0);
      }
#line 2291 "y.tab.c"
    break;

  case 35: /* $@1: %empty  */
#line 938 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          begin_function((yyvsp[-3].str), (yyvsp[-4].ival), (yyvsp[-1].params));
      }
#line 2299 "y.tab.c"
    break;

  case 36: /* FuncDef: BType IDENT LPAREN FuncFParams RPAREN $@1 Block  */
#line 942 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          end_function();
      }
#line 2307 "y.tab.c"
    break;

  case 37: /* $@2: %empty  */
#line 946 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          begin_function((yyvsp[-3].str), 1, (yyvsp[-1].params));
      }
#line 2315 "y.tab.c"
    break;

  case 38: /* FuncDef: VOID IDENT LPAREN FuncFParams RPAREN $@2 Block  */
#line 950 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          end_function();
      }
#line 2323 "y.tab.c"
    break;

  case 39: /* FuncFParams: %empty  */
#line 956 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                  { (yyval.params) = new_param_list(); }
#line 2329 "y.tab.c"
    break;

  case 40: /* FuncFParams: FuncFParam  */
#line 957 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                 { (yyval.params) = append_param(new_param_list(), (yyvsp[0].str)); }
#line 2335 "y.tab.c"
    break;

  case 41: /* FuncFParams: FuncFParams COMMA FuncFParam  */
#line 958 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                                   { (yyval.params) = append_param((yyvsp[-2].params), (yyvsp[0].str)); }
#line 2341 "y.tab.c"
    break;

  case 42: /* FuncFParam: BType IDENT FuncArraySuffixs  */
#line 963 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          (yyval.str) = (yyvsp[-1].str);
      }
#line 2349 "y.tab.c"
    break;

  case 47: /* Block: BlockBegin BlockItems RBRACE  */
#line 980 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          pop_scope();
      }
#line 2357 "y.tab.c"
    break;

  case 48: /* BlockBegin: LBRACE  */
#line 987 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          push_scope();
          (yyval.ival) = 0;
      }
#line 2366 "y.tab.c"
    break;

  case 56: /* MatchedStmt: IfHead MatchedStmt ElseHead MatchedStmt  */
#line 1011 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          finish_if_with_else();
      }
#line 2374 "y.tab.c"
    break;

  case 57: /* MatchedStmt: WhileBegin WhileCond MatchedStmt  */
#line 1015 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          end_while();
      }
#line 2382 "y.tab.c"
    break;

  case 58: /* UnmatchedStmt: IfHead Stmt  */
#line 1022 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          finish_if_without_else();
      }
#line 2390 "y.tab.c"
    break;

  case 59: /* UnmatchedStmt: IfHead MatchedStmt ElseHead UnmatchedStmt  */
#line 1026 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          finish_if_with_else();
      }
#line 2398 "y.tab.c"
    break;

  case 60: /* UnmatchedStmt: WhileBegin WhileCond UnmatchedStmt  */
#line 1030 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          end_while();
      }
#line 2406 "y.tab.c"
    break;

  case 61: /* NonIfStmt: LVal ASSIGN Exp SEMICOLON  */
#line 1037 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          emit_store((yyvsp[-3].value), (yyvsp[-1].value));
      }
#line 2414 "y.tab.c"
    break;

  case 64: /* NonIfStmt: BREAK SEMICOLON  */
#line 1043 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          emit_break();
      }
#line 2422 "y.tab.c"
    break;

  case 65: /* NonIfStmt: CONTINUE SEMICOLON  */
#line 1047 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          emit_continue();
      }
#line 2430 "y.tab.c"
    break;

  case 66: /* NonIfStmt: RETURN OptExp SEMICOLON  */
#line 1051 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          emit_return((yyvsp[-1].value));
      }
#line 2438 "y.tab.c"
    break;

  case 67: /* OptExp: %empty  */
#line 1057 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                  { (yyval.value) = new_const_value(0); }
#line 2444 "y.tab.c"
    break;

  case 68: /* OptExp: Exp  */
#line 1058 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
          { (yyval.value) = (yyvsp[0].value); }
#line 2450 "y.tab.c"
    break;

  case 69: /* Exp: AddExp  */
#line 1062 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
             { (yyval.value) = (yyvsp[0].value); }
#line 2456 "y.tab.c"
    break;

  case 70: /* Cond: LOrExp  */
#line 1066 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
             { (yyval.cond) = (yyvsp[0].cond); }
#line 2462 "y.tab.c"
    break;

  case 71: /* LVal: IDENT LValIndexList  */
#line 1071 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          Symbol *sym = find_symbol((yyvsp[-1].str));
          if (sym)
              (yyval.value) = lvalue_from_symbol(sym, (yyvsp[0].args));
          else {
              semantic_error("undefined symbol", (yyvsp[-1].str));
              (yyval.value) = new_const_value(0);
          }
      }
#line 2476 "y.tab.c"
    break;

  case 72: /* LValIndexList: %empty  */
#line 1083 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                  { (yyval.args) = new_arg_list(); }
#line 2482 "y.tab.c"
    break;

  case 73: /* LValIndexList: LValIndexList LBRACK Exp RBRACK  */
#line 1084 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                                      { (yyval.args) = append_arg((yyvsp[-3].args), (yyvsp[-1].value)); }
#line 2488 "y.tab.c"
    break;

  case 74: /* PrimaryExp: LPAREN Exp RPAREN  */
#line 1088 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                        { (yyval.value) = (yyvsp[-1].value); }
#line 2494 "y.tab.c"
    break;

  case 75: /* PrimaryExp: LVal  */
#line 1089 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
           { (yyval.value) = (yyvsp[0].value); }
#line 2500 "y.tab.c"
    break;

  case 76: /* PrimaryExp: Number  */
#line 1090 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
             { (yyval.value) = (yyvsp[0].value); }
#line 2506 "y.tab.c"
    break;

  case 77: /* Number: INT_CONST  */
#line 1095 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          (yyval.value) = new_const_value(parse_int_literal((yyvsp[0].str)));
      }
#line 2514 "y.tab.c"
    break;

  case 78: /* UnaryExp: PrimaryExp  */
#line 1101 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                 { (yyval.value) = (yyvsp[0].value); }
#line 2520 "y.tab.c"
    break;

  case 79: /* UnaryExp: IDENT LPAREN FuncRParams RPAREN  */
#line 1103 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          if (strcmp((yyvsp[-3].str), "scanf") == 0) {
              if ((yyvsp[-1].args) && (yyvsp[-1].args)->count > 0)
                  emit_scanf((yyvsp[-1].args)->args[0]);
              (yyval.value) = new_const_value(0);
          } else if (strcmp((yyvsp[-3].str), "printf") == 0) {
              if ((yyvsp[-1].args) && (yyvsp[-1].args)->count > 0)
                  emit_printf((yyvsp[-1].args)->args[0]);
              (yyval.value) = new_const_value(0);
          } else {
              (yyval.value) = emit_call((yyvsp[-3].str), (yyvsp[-1].args));
          }
      }
#line 2538 "y.tab.c"
    break;

  case 80: /* UnaryExp: UnaryOp UnaryExp  */
#line 1117 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          if ((yyvsp[-1].ival) == 1)
              (yyval.value) = emit_binary("sub", new_const_value(0), (yyvsp[0].value));
          else if ((yyvsp[-1].ival) == 2)
              (yyval.value) = emit_compare("eq", (yyvsp[0].value), new_const_value(0));
          else
              (yyval.value) = (yyvsp[0].value);
      }
#line 2551 "y.tab.c"
    break;

  case 81: /* UnaryOp: PLUS  */
#line 1128 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
           { (yyval.ival) = 0; }
#line 2557 "y.tab.c"
    break;

  case 82: /* UnaryOp: MINUS  */
#line 1129 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
            { (yyval.ival) = 1; }
#line 2563 "y.tab.c"
    break;

  case 83: /* UnaryOp: NOT  */
#line 1130 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
          { (yyval.ival) = 2; }
#line 2569 "y.tab.c"
    break;

  case 84: /* FuncRParams: %empty  */
#line 1134 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                  { (yyval.args) = new_arg_list(); }
#line 2575 "y.tab.c"
    break;

  case 85: /* FuncRParams: Exp  */
#line 1135 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
          { (yyval.args) = append_arg(new_arg_list(), (yyvsp[0].value)); }
#line 2581 "y.tab.c"
    break;

  case 86: /* FuncRParams: FuncRParams COMMA Exp  */
#line 1136 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                            { (yyval.args) = append_arg((yyvsp[-2].args), (yyvsp[0].value)); }
#line 2587 "y.tab.c"
    break;

  case 87: /* MulExp: UnaryExp  */
#line 1140 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
               { (yyval.value) = (yyvsp[0].value); }
#line 2593 "y.tab.c"
    break;

  case 88: /* MulExp: MulExp MUL UnaryExp  */
#line 1141 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                          { (yyval.value) = emit_binary("mul", (yyvsp[-2].value), (yyvsp[0].value)); }
#line 2599 "y.tab.c"
    break;

  case 89: /* MulExp: MulExp DIV UnaryExp  */
#line 1142 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                          { (yyval.value) = emit_binary("sdiv", (yyvsp[-2].value), (yyvsp[0].value)); }
#line 2605 "y.tab.c"
    break;

  case 90: /* MulExp: MulExp MOD UnaryExp  */
#line 1143 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                          { (yyval.value) = emit_binary("srem", (yyvsp[-2].value), (yyvsp[0].value)); }
#line 2611 "y.tab.c"
    break;

  case 91: /* AddExp: MulExp  */
#line 1147 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
             { (yyval.value) = (yyvsp[0].value); }
#line 2617 "y.tab.c"
    break;

  case 92: /* AddExp: AddExp PLUS MulExp  */
#line 1148 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                         { (yyval.value) = emit_binary("add", (yyvsp[-2].value), (yyvsp[0].value)); }
#line 2623 "y.tab.c"
    break;

  case 93: /* AddExp: AddExp MINUS MulExp  */
#line 1149 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                          { (yyval.value) = emit_binary("sub", (yyvsp[-2].value), (yyvsp[0].value)); }
#line 2629 "y.tab.c"
    break;

  case 94: /* RelExp: AddExp  */
#line 1153 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
             { (yyval.value) = (yyvsp[0].value); }
#line 2635 "y.tab.c"
    break;

  case 95: /* RelExp: RelExp LT AddExp  */
#line 1154 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                       { (yyval.value) = emit_compare("slt", (yyvsp[-2].value), (yyvsp[0].value)); }
#line 2641 "y.tab.c"
    break;

  case 96: /* RelExp: RelExp GT AddExp  */
#line 1155 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                       { (yyval.value) = emit_compare("sgt", (yyvsp[-2].value), (yyvsp[0].value)); }
#line 2647 "y.tab.c"
    break;

  case 97: /* RelExp: RelExp LE AddExp  */
#line 1156 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                       { (yyval.value) = emit_compare("sle", (yyvsp[-2].value), (yyvsp[0].value)); }
#line 2653 "y.tab.c"
    break;

  case 98: /* RelExp: RelExp GE AddExp  */
#line 1157 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                       { (yyval.value) = emit_compare("sge", (yyvsp[-2].value), (yyvsp[0].value)); }
#line 2659 "y.tab.c"
    break;

  case 99: /* EqExp: RelExp  */
#line 1161 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
             { (yyval.value) = (yyvsp[0].value); }
#line 2665 "y.tab.c"
    break;

  case 100: /* EqExp: EqExp EQ RelExp  */
#line 1162 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                      { (yyval.value) = emit_compare("eq", (yyvsp[-2].value), (yyvsp[0].value)); }
#line 2671 "y.tab.c"
    break;

  case 101: /* EqExp: EqExp NE RelExp  */
#line 1163 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
                      { (yyval.value) = emit_compare("ne", (yyvsp[-2].value), (yyvsp[0].value)); }
#line 2677 "y.tab.c"
    break;

  case 102: /* LAndExp: EqExp  */
#line 1167 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
            { (yyval.cond) = new_cond_value((yyvsp[0].value)); }
#line 2683 "y.tab.c"
    break;

  case 103: /* LAndExp: LAndExp AND EqExp  */
#line 1169 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          (yyval.cond) = new_cond_binary(1, (yyvsp[-2].cond), new_cond_value((yyvsp[0].value)));
      }
#line 2691 "y.tab.c"
    break;

  case 104: /* LOrExp: LAndExp  */
#line 1175 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
              { (yyval.cond) = (yyvsp[0].cond); }
#line 2697 "y.tab.c"
    break;

  case 105: /* LOrExp: LOrExp OR LAndExp  */
#line 1177 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          (yyval.cond) = new_cond_binary(2, (yyvsp[-2].cond), (yyvsp[0].cond));
      }
#line 2705 "y.tab.c"
    break;

  case 106: /* ConstExp: AddExp  */
#line 1183 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
             { (yyval.value) = (yyvsp[0].value); }
#line 2711 "y.tab.c"
    break;

  case 107: /* ConstEvalBegin: %empty  */
#line 1188 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          (yyval.ival) = const_eval_mode;
          const_eval_mode = 1;
      }
#line 2720 "y.tab.c"
    break;

  case 108: /* IfHead: IF LPAREN Cond RPAREN  */
#line 1196 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          begin_if_unified((yyvsp[-1].cond));
          (yyval.ival) = 0;
      }
#line 2729 "y.tab.c"
    break;

  case 109: /* ElseHead: ELSE  */
#line 1204 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          switch_to_else();
          (yyval.ival) = 0;
      }
#line 2738 "y.tab.c"
    break;

  case 110: /* WhileBegin: WHILE  */
#line 1212 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          begin_while();
          (yyval.ival) = 0;
      }
#line 2747 "y.tab.c"
    break;

  case 111: /* WhileCond: LPAREN Cond RPAREN  */
#line 1220 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"
      {
          while_condition((yyvsp[-1].cond));
          (yyval.ival) = 0;
      }
#line 2756 "y.tab.c"
    break;


#line 2760 "y.tab.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (YY_("syntax error"));
    }

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 1226 "/home/yixienaqi0818/3rd_exp/LLVM-IR/workspace/Parser.y"


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
