# Compilers Experiments

> 编译原理课程实验 — 2026 春 · 第六学期 · 程宣赫 (2023202250)

## 实验概览

| 实验 | 主题 | 工具 | 核心内容 |
|------|------|------|---------|
| 1st exp | 词法分析器 | Flex | 正则→NFA→DFA，Token 识别，SysY 语言 |
| 2nd exp | 语法分析器 | Flex + Bison | CFG、LR 分析、AST 语法树生成 |
| 3rd exp | 语义分析器 | LLVM IR + 汇编 | 类型检查、中间代码生成、目标代码 |

## 目录结构

```
Compilers_exp/
├── 1st exp/                      # 词法分析器
│   ├── demo-code/                #   示例代码
│   │   ├── example.l             #   Flex 词法规则
│   │   └── test.sy               #   SysY 测试程序
│   ├── workspace/                #   作业代码
│   │   └── Lexical_analyzer.l    #   完整词法分析器
│   ├── test-cases/               #   测试用例 (1-6.sy)
│   └── 词法分析器实验.pdf          #   实验说明
│
├── 2nd_exp/                      # 语法分析器
│   ├── demo-code/
│   │   ├── example.l / example.y #   Flex + Bison 示例
│   │   └── test.sy
│   ├── workspace/
│   │   ├── lexer.l               #   词法规则
│   │   ├── parser.y              #   语法规则 (Bison)
│   │   └── output/               #   测试输出 (语法树)
│   ├── example/
│   │   └── Tree.png              #   语法树可视化
│   ├── test-cases/ (1-3.sy)
│   └── 语法分析器实验报告.pdf
│
├── 3rd_exp/                      # 语义分析器
│   ├── 3rd_exp/
│   │   ├── LLVM-IR/              #   LLVM IR 方案
│   │   │   ├── workspace/
│   │   │   │   ├── lexical_analyzer.l
│   │   │   │   ├── Parser.y      #   带语义动作的语法分析
│   │   │   │   ├── report.tex    #   实验报告 (LaTeX)
│   │   │   │   └── output/       #   IR + 汇编 + 可执行文件
│   │   │   ├── runtime.c         #   运行时库
│   │   │   └── reference/        #   LLVM 参考资料
│   │   └── assemble/             #   汇编方案
│   │       ├── workspace/
│   │       └── reference/
│   └── 语义分析器实验报告.pdf
│
└── README.md
```

## 编译流程

```
SysY 源码 (.sy)
    │
    ▼ [Flex - 词法分析]
Token 序列
    │
    ▼ [Bison - 语法分析]
AST 语法树
    │
    ▼ [语义动作]
LLVM IR (.ll)
    │
    ▼ [LLVM/Clang]
汇编 (.s) → 目标文件 (.o) → 可执行文件
```

## 运行

```bash
# 实验一 — 词法分析
cd 1st_exp/workspace
flex Lexical_analyzer.l && gcc lex.yy.c -o lexer
./lexer < ../test-cases/1.sy

# 实验二 — 语法分析
cd 2nd_exp/workspace
flex lexer.l && bison -d parser.y
gcc lex.yy.c y.tab.c -o parser
./parser < ../test-cases/1.sy

# 实验三 — 语义分析 (LLVM IR)
cd 3rd_exp/3rd_exp/LLVM-IR/scripts
bash compile.sh   # Flex + Bison + 生成 LLVM IR
bash test.sh      # 编译为可执行文件并运行
```

## License

Educational purpose — Compilers coursework.
