%option noyywrap
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct Node Node;
#include "y.tab.h"

int cur_line = 1;
int cur_col  = 1;

int comment_start_line = 0;
int comment_start_col  = 0;

void update_pos(const char *text)
{
    for (int i = 0; text[i] != '\0'; i++)
    {
        if (text[i] == '\n')
        {
            cur_line++;
            cur_col = 1;
        }
        else if (text[i] == '\r')
        {}
        else
            cur_col++;
    }
}
%}

%x COMMENT

digit      [0-9]
letter     [A-Za-z_]
identifier {letter}({letter}|{digit})*

dec_int    0|([1-9]{digit}*)
oct_int    0[0-7]+
hex_int    0[xX][0-9a-fA-F]+
const_int  {dec_int}|{oct_int}|{hex_int}

bad_iden   {digit}+{letter}({letter}|{digit})*

%%

\r\n { update_pos(yytext); }

\n { update_pos(yytext); }

[ \t]+ { update_pos(yytext); }

"//"[^\r\n]* { update_pos(yytext); }

"/*" {
    comment_start_line = cur_line;
    comment_start_col  = cur_col;
    update_pos(yytext);
    BEGIN(COMMENT);
}

<COMMENT>"*/" {
    update_pos(yytext);
    BEGIN(INITIAL);
}

<COMMENT>\r\n { update_pos(yytext); }
<COMMENT>\n { update_pos(yytext); }
<COMMENT>. { update_pos(yytext); }

<COMMENT><<EOF>> {
    fprintf(stderr, "Lexical error: unclosed comment at (%d,%d)\n",
            comment_start_line, comment_start_col);
    return 0;
}

"const"    { update_pos(yytext); return CONST; }
"int"      { update_pos(yytext); return INT; }
"void"     { update_pos(yytext); return VOID; }
"if"       { update_pos(yytext); return IF; }
"else"     { update_pos(yytext); return ELSE; }
"while"    { update_pos(yytext); return WHILE; }
"break"    { update_pos(yytext); return BREAK; }
"continue" { update_pos(yytext); return CONTINUE; }
"return"   { update_pos(yytext); return RETURN; }

{const_int} {
    yylval.str = strdup(yytext);
    update_pos(yytext);
    return INT_CONST;
}

{identifier} {
    yylval.str = strdup(yytext);
    update_pos(yytext);
    return IDENT;
}

"==" { update_pos(yytext); return EQ; }
"!=" { update_pos(yytext); return NE; }
"<=" { update_pos(yytext); return LE; }
">=" { update_pos(yytext); return GE; }
"&&" { update_pos(yytext); return AND; }
"||" { update_pos(yytext); return OR; }

"+"  { update_pos(yytext); return PLUS; }
"-"  { update_pos(yytext); return MINUS; }
"*"  { update_pos(yytext); return MUL; }
"/"  { update_pos(yytext); return DIV; }
"%"  { update_pos(yytext); return MOD; }
"="  { update_pos(yytext); return ASSIGN; }
"<"  { update_pos(yytext); return LT; }
">"  { update_pos(yytext); return GT; }
"!"  { update_pos(yytext); return NOT; }

";"  { update_pos(yytext); return SEMICOLON; }
","  { update_pos(yytext); return COMMA; }
"("  { update_pos(yytext); return LPAREN; }
")"  { update_pos(yytext); return RPAREN; }
"["  { update_pos(yytext); return LBRACK; }
"]"  { update_pos(yytext); return RBRACK; }
"{"  { update_pos(yytext); return LBRACE; }
"}"  { update_pos(yytext); return RBRACE; }

0[0-9]+ {
    fprintf(stderr, "Lexical error at (%d,%d): invalid integer %s\n",
            cur_line, cur_col, yytext);
    update_pos(yytext);
}

{bad_iden} {
    fprintf(stderr, "Lexical error at (%d,%d): invalid identifier %s\n",
            cur_line, cur_col, yytext);
    update_pos(yytext);
}

. {
    fprintf(stderr, "Lexical error at (%d,%d): unknown character %s\n",
            cur_line, cur_col, yytext);
    update_pos(yytext);
}

%%

