#!/bin/bash
cd "$(dirname "$0")/.."
cd workspace
flex lexical_analyzer.l
yacc -d Parser.y
g++ y.tab.c lex.yy.c -o mc -O2 -w
