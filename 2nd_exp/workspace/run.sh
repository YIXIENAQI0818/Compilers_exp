#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_ROOT="$SCRIPT_DIR/output"

# 根据参数选择输入文件
case "$1" in
    example)
        INPUT_FILE="$SCRIPT_DIR/../example/test.sy"
        TASK_NAME="example"
        ;;
    test1)
        INPUT_FILE="$SCRIPT_DIR/../test-cases/1.sy"
        TASK_NAME="test1"
        ;;
    test2)
        INPUT_FILE="$SCRIPT_DIR/../test-cases/2.sy"
        TASK_NAME="test2"
        ;;
    test3)
        INPUT_FILE="$SCRIPT_DIR/../test-cases/3.sy"
        TASK_NAME="test3"
        ;;
    *)
        echo "用法: $0 {example|test1|test2|test3}"
        exit 1
        ;;
esac

# 检查输入文件是否存在
if [ ! -f "$INPUT_FILE" ]; then
    echo "错误: 输入文件不存在: $INPUT_FILE"
    exit 1
fi

# 输出目录：每次重新生成，避免旧结果残留
TASK_OUTPUT_DIR="$OUTPUT_ROOT/$TASK_NAME"
rm -rf "$TASK_OUTPUT_DIR"
mkdir -p "$TASK_OUTPUT_DIR"

echo "========== 开始编译 =========="

cd "$SCRIPT_DIR"

# 清理旧的编译文件
rm -f lex.yy.c y.tab.c y.tab.h parser

# 生成并编译
flex ./lexer.l
yacc -d ./parser.y
gcc y.tab.c lex.yy.c -o parser -O2 -w -lfl

echo "========== 编译完成 =========="
echo "输入文件: $INPUT_FILE"
echo "输出目录: $TASK_OUTPUT_DIR"

# 切到输出目录运行，使 rules.txt/tree.dot/tree.png 输出到这里
cd "$TASK_OUTPUT_DIR"

cp "$INPUT_FILE" ./input.sy

# 运行程序
"$SCRIPT_DIR/parser" "$INPUT_FILE" > stdout.txt 2> stderr.txt

# 如果生成了 tree.dot，就尝试生成 tree.png
if [ -f "tree.dot" ]; then
    if command -v dot >/dev/null 2>&1; then
        dot -Tpng tree.dot -o tree.png
        echo "已生成: $TASK_OUTPUT_DIR/tree.png"
    else
        echo "检测到 tree.dot，但系统未安装 graphviz，未生成 tree.png"
    fi
fi

echo "========== 运行完成 =========="
echo "输出文件位于: $TASK_OUTPUT_DIR"

# 回到 workspace，清理编译产物
cd "$SCRIPT_DIR"
rm -f lex.yy.c y.tab.c y.tab.h parser parser.tab.c parser.tab.h