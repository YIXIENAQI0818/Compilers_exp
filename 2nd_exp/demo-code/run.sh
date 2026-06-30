flex example.l
yacc -d example.y
gcc y.tab.c lex.yy.c -o mc -O2 -w
./mc test.sy

rm y.tab.c y.tab.h lex.yy.c mc