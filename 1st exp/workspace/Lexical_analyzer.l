%option noyywrap
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

void print_token(const char *lexeme, const char *type, int line, int col)
{
    printf("%s\t%s\t(%d,%d)\n", lexeme, type, line, col);
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
    printf("UnclosedComment\tT\t(%d,%d)\n", comment_start_line, comment_start_col);
    return 0;
}

"const"|"int"|"void"|"if"|"else"|"while"|"break"|"continue"|"return" {
    print_token(yytext, "K", cur_line, cur_col);
    update_pos(yytext);
}

{const_int} {
    print_token(yytext, "C", cur_line, cur_col);
    update_pos(yytext);
}

{identifier} {
    print_token(yytext, "I", cur_line, cur_col);
    update_pos(yytext);
}

"=="|"!="|"<="|">="|"&&"|"||" {
    print_token(yytext, "O", cur_line, cur_col);
    update_pos(yytext);
}

"+"|"-"|"*"|"/"|"%"|"="|"<"|">"|"!" {
    print_token(yytext, "O", cur_line, cur_col);
    update_pos(yytext);
}

";"|","|"("|")"|"["|"]"|"{"|"}" {
    print_token(yytext, "D", cur_line, cur_col);
    update_pos(yytext);
}

0[0-9]+ {
    print_token(yytext, "T", cur_line, cur_col);
    update_pos(yytext);
}

{bad_iden} {
    print_token(yytext, "T", cur_line, cur_col);
    update_pos(yytext);
}

. {
    print_token(yytext, "T", cur_line, cur_col);
    update_pos(yytext);
}

%%

int main(int argc, char *argv[]) {
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (!fp) {
            perror("fopen");
            return 1;
        }
        yyin = fp;
    } else {
        yyin = stdin;
    }

    yylex();

    if (argc > 1 && yyin) {
        fclose(yyin);
    }
    return 0;
}