# LLVM 与 LLVM IR 技术报告

## 一、LLVM 概述

### 1.1 什么是 LLVM

LLVM 最初是 "Low Level Virtual Machine" 的缩写，但现在已发展为**一套模块化、可重用的编译器基础设施**，而不仅仅是一个虚拟机。它由伊利诺伊大学香槟分校的 Chris Lattner 于 2000 年发起，现已成为工业界和学术界最广泛使用的编译器框架之一。

LLVM 的核心理念是**前端-中端-后端三阶段设计**：

```
┌──────────┐     ┌──────────────┐     ┌───────────┐
│  前端     │ ──→ │  中端(优化器)  │ ──→ │   后端     │
│ (Clang)  │     │   (LLVM IR)  │     │ (LLVM后端) │
└──────────┘     └──────────────┘     └───────────┘
   C/C++/ObjC        LLVM IR           x86/ARM/RISC-V/...
```

- **前端**：将源代码翻译为 LLVM IR
- **中端**：对 IR 进行与目标平台无关的优化
- **后端**：将 IR 翻译为目标平台的机器码

这种设计意味着：如果有一种新语言，只需写一个前端生成 LLVM IR；如果有一种新硬件，只需写一个后端从 IR 生成机器码。**M × N 问题变成了 M + N 问题**。

### 1.2 LLVM 的核心组件

| 组件 | 功能 |
|------|------|
| **LLVM Core** | IR 的定义、验证、读写 |
| **LLVM IR (Intermediate Representation)** | 中间表示，编译流程的核心数据格式 |
| **Clang** | C/C++/Objective-C 前端 |
| **LLDB** | 调试器 |
| **LLD** | 链接器 |
| **LLVM Passes** | 优化和分析的插件式框架 |
| **LLVM MC** | 机器码生成、汇编、反汇编 |

## 二、LLVM 的工作原理

### 2.1 编译流程

```
源代码 (C/C++/Rust/Swift/...)
    │
    ▼  前端 (Parser + Semantic Analysis)
  AST (抽象语法树)
    │
    ▼  IRGen (IR 生成)
  LLVM IR (.ll / .bc)
    │
    ▼  opt (优化器 - Pass 管线)
  优化后的 LLVM IR
    │
    ▼  llc (静态编译器)
  汇编 / 目标文件 (.s / .o)
    │
    ▼  链接器 (lld / ld)
  可执行文件
```

### 2.2 LLVM IR 的设计哲学

LLVM IR 的设计遵循三个核心原则：

1. **SSA (Static Single Assignment) 形式**：每个虚拟寄存器在整个程序中只被赋值一次。这极大简化了数据流分析、死代码消除、常量传播等优化的实现。

2. **三地址码 (Three-Address Code)**：每条指令最多有三个操作数（两个源，一个目标）。这种形式接近机器指令但保留了足够的抽象信息。

3. **强类型系统**：所有值都有明确类型（`i32`、`double`、`i8*` 等），类型检查在 IR 层面即可进行，避免了许多运行时错误。

### 2.3 优化管线 (Pass Pipeline)

LLVM 的优化以 Pass 为单位组织。每个 Pass 完成一个特定的分析或转换任务：

```
未优化的 IR
    │
    ▼  -mem2reg (内存到寄存器提升)
    ▼  -instcombine (指令合并)
    ▼  -reassociate (重结合)
    ▼  -gvn (全局值编号)
    ▼  -simplifycfg (简化控制流)
    ▼  -loop-rotate (循环旋转变换)
    ▼  -licm (循环不变量外提)
    ▼  -indvars (归纳变量优化)
    ▼  -slp-vectorizer (超字级并行向量化)
    ▼  -loop-vectorize (循环向量化)
    │
    ▼
  优化后的 IR
```

## 三、为什么要用 LLVM

### 3.1 与直接生成汇编相比

| 方案 | 优点 | 缺点 |
|------|------|------|
| **直接生成汇编** | 实现简单，无外部依赖 | 不能利用优化；每种目标平台需重写后端；调试困难 |
| **生成 LLVM IR** | 享受全套优化；多平台支持；利于调试；IR 可读性好 | 依赖 LLVM 工具链 |

对于一个教学编译器来说，生成 LLVM IR 的体验极佳——只需关注"语义翻译"的正确性，**性能优化交给 llc/opt**，且可以通过 `lli` 直接解释执行 IR 来调试。

### 3.2 与其他 IR 的对比

| 特性 | LLVM IR | Java Bytecode | .NET CIL | GCC GIMPLE |
|------|---------|---------------|----------|------------|
| **抽象层次** | 低级（接近汇编） | 高级（面向对象） | 高级（面向对象） | 低级 |
| **类型系统** | 强类型、低级类型 | 强类型、高级类型 | 强类型 | 弱类型 |
| **SSA 形式** | 是（严格要求） | 否（栈式） | 否（栈式） | 是 |
| **平台无关** | 是 | 是 | 是 | 否（已目标化） |
| **可读文本格式** | 有 (.ll) | 有 (jasmin) | 有 (ilasm) | 有 (GIMPLE dump) |
| **JIT 支持** | 原生支持 | 原生支持 | 原生支持 | 无 |

## 四、LLVM 与 GCC 的区别

### 4.1 架构对比

```
GCC:                           LLVM/Clang:
┌─────────────────────┐        ┌──────────┐
│   GCC (单体架构)      │        │  Clang   │  (前端)
│                     │        ├──────────┤
│  前端 ─── GIMPLE ───│        │  LLVM IR │  (中间表示)
│       优化 ── RTL ──│        ├──────────┤
│          后端       │        │  LLVM    │  (后端)
└─────────────────────┘        └──────────┘
```

### 4.2 关键差异

| 维度 | GCC | LLVM/Clang |
|------|-----|------------|
| **架构** | 单体式，前后端耦合较紧 | 模块化，清晰的库边界 |
| **中间表示** | GENERIC → GIMPLE → RTL 三层 | 单一 IR，贯穿编译全程 |
| **API/库化** | 库化程度较低，嵌入困难 | 设计为库，易于嵌入 IDE、编辑器、JIT 等 |
| **前端** | C/C++/Fortran/Ada/Go 等 | Clang (C/C++/ObjC)，另有 rustc、swiftc 等 |
| **后端** | 支持大量架构 | 支持主流架构 + WebAssembly + GPU |
| **编译速度** | 较快（整体） | 较快（尤其增量编译，得益于模块化） |
| **错误信息** | 较简略（近年改善） | 极其友好，带 fix-it 建议 |
| **许可证** | GPLv3（传染性） | Apache 2.0（商业友好） |
| **工具链** | 集成 binutils | 自有 LLD 链接器、LLDB 调试器 |
| **社区** | GNU 项目，FSF 管理 | LLVM 基金会，工业界广泛参与 |

### 4.3 许可证差异的影响

这是工业界选择 LLVM 的重要原因之一：

- **GCC (GPLv3)**：任何基于 GCC 构建的衍生工具或库都必须以 GPL 开源。这对商业编译器、IDE 插件、嵌入式工具链等有很强的限制。
- **LLVM (Apache 2.0)**：允许闭源商业使用。因此 Apple (Swift/Xcode)、NVIDIA (CUDA)、AMD (ROCm)、Intel (oneAPI)、Sony (PS5 SDK) 等都构建在 LLVM 之上。

### 4.4 模块化对比：一个具体例子

如果你想在 IDE 中实现"悬停显示变量类型"功能：

- **用 GCC**：几乎不可能，GCC 不提供这样的库接口
- **用 Clang/LLVM**：链接 `libclang`，几行代码即可获取 AST 的类型信息

```cpp
// 使用 libclang 获取类型信息
CXType type = clang_getCursorType(cursor);
CXString typeName = clang_getTypeSpelling(type);
```

## 五、LLVM IR 详解

### 5.1 IR 的三种形式

LLVM IR 有三种等价的表示形式：

| 形式 | 格式 | 用途 |
|------|------|------|
| **文本格式** | `.ll` 文件 | 人类可读，调试、教学 |
| **位码格式** | `.bc` 文件 | 紧凑二进制，高效存储和传输 |
| **内存格式** | C++ 对象 (`llvm::Module`) | 程序化构建和操作 |

三者可以无损互转：
```bash
llvm-as  input.ll  -o output.bc    # 文本 → 位码
llvm-dis input.bc  -o output.ll    # 位码 → 文本
```

### 5.2 模块结构

LLVM IR 的顶层组织如下：

```
Module (模块)
├── Target Triple (目标平台描述)
├── Data Layout (数据布局)
├── Global Variables (全局变量)
│   ├── @x = global i32 0
│   └── @arr = global [10 x i32] zeroinitializer
├── Function Declarations (函数声明)
│   └── declare i32 @getint()
└── Function Definitions (函数定义)
    ├── define i32 @main() { ... }
    └── define i32 @factorial(i32 %n) { ... }
        ├── Basic Block 0 (entry)
        │   ├── alloca 指令
        │   ├── store 指令
        │   └── br 指令 (终止)
        ├── Basic Block 1
        │   ├── load 指令
        │   ├── icmp 指令
        │   └── br 指令 (终止)
        └── Basic Block N
            └── ret 指令 (终止)
```

### 5.3 类型系统

LLVM IR 的类型系统分为**基本类型**和**派生类型**：

```
类型层次：
  void          — 空类型（函数无返回值）
  i1            — 1位整数（布尔值）
  i8, i16, i32, i64  — 定宽整数
  half, float, double — 浮点类型
  label         — 基本块标签类型
  pointer       — 指针类型，如 i32*
  array         — 数组类型，如 [10 x i32]
  struct        — 结构体类型，如 {i32, float}
  vector        — 向量类型（SIMD），如 <4 x i32>
  function      — 函数类型，如 i32 (i32, i32)
```

**重要**：LLVM IR 中 `i1` 和 `i32` 是不同的类型，不能隐式转换。需要用 `zext`（零扩展）、`sext`（符号扩展）或 `trunc`（截断）显式转换。

### 5.4 核心指令集

#### 内存操作
```llvm
%ptr = alloca i32                         ; 在栈上分配
%val = load i32, i32* %ptr               ; 从内存读取
store i32 42, i32* %ptr                  ; 写入内存
%p = getelementptr [10 x i32], [10 x i32]* %arr, i32 0, i32 %i  ; 地址计算
```

#### 算术运算
```llvm
%r = add i32 %a, %b       ; 加法
%r = sub i32 %a, %b       ; 减法
%r = mul i32 %a, %b       ; 乘法
%r = sdiv i32 %a, %b      ; 有符号除法
%r = udiv i32 %a, %b      ; 无符号除法
%r = srem i32 %a, %b      ; 有符号取余
%r = urem i32 %a, %b      ; 无符号取余
```

#### 位运算
```llvm
%r = shl i32 %a, 3        ; 左移
%r = lshr i32 %a, 3       ; 逻辑右移
%r = ashr i32 %a, 3       ; 算术右移
%r = and i32 %a, %b       ; 按位与
%r = or i32 %a, %b        ; 按位或
%r = xor i32 %a, %b       ; 按位异或
```

#### 比较运算
```llvm
%r = icmp eq i32 %a, %b           ; ==
%r = icmp ne i32 %a, %b           ; !=
%r = icmp slt i32 %a, %b          ; <  (有符号)
%r = icmp sgt i32 %a, %b          ; >  (有符号)
%r = icmp sle i32 %a, %b          ; <= (有符号)
%r = icmp sge i32 %a, %b          ; >= (有符号)
%r = icmp ult i32 %a, %b          ; <  (无符号)
```

比较结果类型为 `i1`（单比特布尔值）。在 SysY 中需要 `zext` 到 `i32`：
```llvm
%cmp = icmp slt i32 %a, %b       ; i1 结果
%r = zext i1 %cmp to i32         ; 扩展到 i32 (0 或 1)
```

#### 类型转换
```llvm
%r = zext i1 %x to i32           ; 零扩展
%r = sext i8 %x to i32           ; 符号扩展
%r = trunc i32 %x to i8          ; 截断
%r = bitcast [10 x i32]* %p to i32*   ; 位重解释（不改变位模式）
%r = inttoptr i64 %x to i32*     ; 整数→指针
%r = ptrtoint i32* %p to i64     ; 指针→整数
```

#### 控制流
```llvm
br label %next_block                   ; 无条件跳转
br i1 %cond, label %true, label %false ; 条件跳转
ret i32 0                              ; 函数返回
ret void
```

**关键规则**：每个基本块必须以 `br` 或 `ret`（终结指令）结束。不能在终结指令之后再写其他指令。

#### 函数调用
```llvm
%r = call i32 @factorial(i32 5)
call void @putint(i32 %val)
```

#### phi 指令（SSA 的关键）
当不同控制流路径汇合时，`phi` 指令选择正确的值：
```llvm
merge:
  %result = phi i32 [ 1, %then_block ], [ %rec_val, %else_block ]
  ; 如果从 then_block 来，result=1；如果从 else_block 来，result=%rec_val
```

### 5.5 SSA 形式的深入理解

SSA (Static Single Assignment) 是 LLVM IR 最核心的特性。在 SSA 形式中：

1. **每个虚拟寄存器恰好被赋值一次**
2. **使用前必须先定义**
3. **phi 指令处理控制流汇合处的值选择**

**为什么 SSA 很重要？**

以死代码消除为例：
```llvm
  %x = add i32 1, 2        ; %x = 3
  %y = mul i32 %x, 4       ; %y = 12
  ret i32 0                 ; 不使用 %y！
```
在 SSA 形式下，由于 `%y` 从未被使用，可以立即删除 `%y = mul ...`。然后 `%x` 也未被使用，继续删除 `%x = add ...`。这种稀疏分析在 SSA 下是 O(1) 的——检查 use-list 是否为空即可。

而在非 SSA 的汇编中，需要全局的数据流分析来确定一个寄存器的写入是否被后续读取，复杂度为 O(N²) 甚至更差。

### 5.6 getelementptr (GEP) 详解

GEP 是 LLVM IR 中计算地址的唯一方式。它**只计算地址，不访问内存**：

```llvm
; 对于 @arr = global [3 x [4 x i32]]
%p = getelementptr [3 x [4 x i32]], [3 x [4 x i32]]* @arr, i32 0, i32 %i, i32 %j
;                          类型               基址指针          基址偏移  行      列

; 结果：%p 指向 @arr[i][j] 的地址（i32* 类型）
```

GEP 的通用形式：
```
getelementptr <base_type>, <base_type>* <base_ptr>, <index_type> <index1>, ...
```

**GEP 不是简单的指针算术**——它理解类型，会自动按 `sizeof(element)` 缩放索引。

### 5.7 一个完整的递归函数示例

SysY 代码：
```c
int f(int x) {
    if (x == 1)
        return 1;
    return x * f(x - 1);
}
```

对应的 LLVM IR：
```llvm
define i32 @f(i32 %x_p) {
entry:
  %x = alloca i32
  store i32 %x_p, i32* %x
  %v = load i32, i32* %x
  %c = icmp eq i32 %v, 1
  br i1 %c, label %then, label %else

then:
  ret i32 1

else:
  %v2 = load i32, i32* %x
  %dec = sub i32 %v2, 1
  %rec = call i32 @f(i32 %dec)
  %v3 = load i32, i32* %x
  %r = mul i32 %v3, %rec
  ret i32 %r
}
```

关键观察点：
- **entry 块**：为参数分配栈空间，加载、比较、条件跳转
- **then 块**：递归基条件，直接返回 1
- **else 块**：递归调用自身，计算 `x * f(x-1)`，返回结果
- 所有值都是 SSA 格式，每个 `%v` 只用 `alloca`+`store`/`load` 模式绕过多重赋值限制

### 5.8 IR 验证

LLVM 提供内置的 IR 验证器：

```bash
llc output.ll -o /dev/null        # 编译时自动验证
opt -verify input.ll -o /dev/null # 显式验证
```

验证内容包括：
- 类型一致性检查
- SSA 形式正确性（每个值在被使用前恰好定义一次）
- 基本块正确终止
- 支配关系正确
- phi 指令的参数与到达路径匹配

## 六、LLVM 生态系统

```
┌─────────────────────────────────────────────────┐
│                  LLVM 生态系统                     │
├─────────────┬──────────────┬─────────────────────┤
│   语言前端    │    工具链     │      应用领域        │
├─────────────┼──────────────┼─────────────────────┤
│ Clang (C/C) │ lli (解释器)  │ JIT 编译 (Julia,    │
│ Swift       │ opt (优化器)  │   PostgreSQL)       │
│ Rust        │ llc (编译器)  │ GPU 计算 (CUDA,     │
│ Kotlin/Nat  │ lld (链接器)  │   OpenCL, Vulkan)   │
│ Zig         │ llvm-mca     │ 静态分析 (Clang      │
│ Haskell     │   (微架构分析) │   Static Analyzer)  │
│ Fortran     │ llvm-cov     │ 代码转换 (Emscripten │
│ Julia       │   (覆盖率)    │   → WebAssembly)    │
│ ...         │ llvm-profdata│ 嵌入式、内核...      │
└─────────────┴──────────────┴─────────────────────┘
```

## 七、总结

LLVM 的成功源于其**模块化设计 + 优秀的中间表示 + 友好的许可证**。对于编译原理学习来说：

1. **LLVM IR 是理想的教学目标**——足够底层以展示编译器的实际工作机制，又足够高层以聚焦语义翻译本身
2. **工具链完善**——`llc` 验证正确性，`lli` 直接执行，`opt` 观察优化效果
3. **可读性强**——文本格式的 `.ll` 文件清晰易懂，便于调试
4. **工业相关性**——学习 LLVM 的知识可直接应用于工业编译器开发

## 参考资源

- [LLVM Language Reference Manual](https://llvm.org/docs/LangRef.html)
- [LLVM Programmer's Manual](https://llvm.org/docs/ProgrammersManual.html)
- [The Architecture of Open Source Applications: LLVM](https://aosabook.org/en/llvm.html)
- [Mapping High Level Constructs to LLVM IR](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/)
