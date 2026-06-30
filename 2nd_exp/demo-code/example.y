%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern int yylex(void); 
extern int yyparse(void); 
extern char *yytext;

void yyerror(const char *s) {
	printf("[error] %s", s);
}

int main(int argc, char *argv[]) {
	freopen (argv[1], "r", stdin);

    yyparse();

	return 0;
}
%}

%token INT ELSE ADD

%%
CALC:
    Number OP Number {
        int answer = $1 + $3;
        printf("The answer is %d\n", answer);
    }
;
OP:
    ADD {
        printf("There is a operator: %s\n", yytext);
    }
Number:
    INT {
        $$ = atoi(yytext);
        printf("There is a INT: %d\n", atoi(yytext));
    }
    | ELSE {
        printf('error\n');
    }
;
