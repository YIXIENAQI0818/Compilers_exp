#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/output"
COMPILE_DIR="$OUTPUT_DIR/compile"

compile() {
    mkdir -p "$COMPILE_DIR"
    rm -f "$COMPILE_DIR"/lex.yy.c "$COMPILE_DIR"/y.tab.c "$COMPILE_DIR"/y.tab.h
    rm -f "$COMPILE_DIR"/mc "$COMPILE_DIR"/runtime.o

    cd "$COMPILE_DIR"
    flex "$SCRIPT_DIR/lexical_analyzer.l"
    yacc -d "$SCRIPT_DIR/Parser.y"
    g++ y.tab.c lex.yy.c -o mc -O2 -w
    gcc -c "$ROOT_DIR/runtime.c" -o runtime.o
}

case_input() {
    case "$1" in
        example)
            echo "$ROOT_DIR/example/test.sy"
            ;;
        test1)
            echo "$ROOT_DIR/test-cases/1.sy"
            ;;
        test2)
            echo "$ROOT_DIR/test-cases/2.sy"
            ;;
        test3)
            echo "$ROOT_DIR/test-cases/3.sy"
            ;;
        test4)
            echo "$ROOT_DIR/test-cases/4.sy"
            ;;
        *)
            return 1
            ;;
    esac
}

run_case() {
    local name="$1"
    local input_file
    input_file="$(case_input "$name")"
    local case_dir="$OUTPUT_DIR/$name"

    if [ ! -x "$COMPILE_DIR/mc" ] || [ ! -f "$COMPILE_DIR/runtime.o" ]; then
        compile
    fi

    rm -rf "$case_dir"
    mkdir -p "$case_dir"
    cp "$input_file" "$case_dir/input.sy"

    cd "$case_dir"
    "$COMPILE_DIR/mc" "$input_file" > mc_stdout.txt 2> mc_stderr.txt
    llc output.ll -o output.s
    gcc output.s "$COMPILE_DIR/runtime.o" -o program

    if [ "$name" = "example" ]; then
        ./program > program_stdout.txt 2> program_stderr.txt
    fi
}

clean() {
    rm -rf "$OUTPUT_DIR"
}

usage() {
    echo "Usage: $0 {compile|example|test1|test2|test3|test4|all|clean}"
}

case "$1" in
    compile)
        compile
        ;;
    example|test1|test2|test3|test4)
        run_case "$1"
        ;;
    all)
        compile
        run_case example
        run_case test1
        run_case test2
        run_case test3
        run_case test4
        ;;
    clean)
        clean
        ;;
    *)
        usage
        exit 1
        ;;
esac
