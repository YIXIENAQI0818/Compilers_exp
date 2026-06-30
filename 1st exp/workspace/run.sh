#!/bin/bash

flex Lexical_analyzer.l
gcc lex.yy.c -o a

case "$1" in
  example)
    ./a < ../example/example.sy
    ;;
  test1)
    ./a < ../test-cases/1.sy
    ;;
  test2)
    ./a < ../test-cases/2.sy
    ;;
  test3)
    ./a < ../test-cases/3.sy
    ;;
  test4)
    ./a < ../test-cases/4.sy
    ;;
  test5)
    ./a < ../test-cases/5.sy
    ;;
  test6)
    ./a < ../test-cases/6.sy
    ;;
  *)
    ;;
esac

rm -f a lex.yy.c