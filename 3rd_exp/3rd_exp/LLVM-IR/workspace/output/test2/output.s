	.text
	.file	"output.ll"
	.globl	f                               # -- Begin function f
	.p2align	4, 0x90
	.type	f,@function
f:                                      # @f
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%rbx
	pushq	%rax
	.cfi_offset %rbx, -24
	movl	%edi, -12(%rbp)
	cmpl	$1, %edi
	jne	.LBB0_3
# %bb.1:                                # %label_1
	movl	$1, %eax
	jmp	.LBB0_2
.LBB0_3:                                # %label_2
	movq	%rsp, %rbx
	leaq	-16(%rbx), %rsp
	movl	$1, -16(%rbx)
	movl	-12(%rbp), %edi
	decl	%edi
	callq	f@PLT
	imull	-12(%rbp), %eax
	movl	%eax, -16(%rbx)
.LBB0_2:                                # %label_1
	leaq	-8(%rbp), %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end0:
	.size	f, .Lfunc_end0-f
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%rbx
	pushq	%rax
	.cfi_offset %rbx, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	movl	$10, %edi
	callq	f@PLT
	movl	%eax, -28(%rbp)
	cmpl	$3628800, %eax                  # imm = 0x375F00
	jne	.LBB1_2
# %bb.1:                                # %label_4
	cmpl	$0, -28(%rbp)
	je	.LBB1_5
.LBB1_2:                                # %label_1
	movl	$2333, %edi                     # imm = 0x91D
	callq	putint@PLT
	cmpl	$0, -28(%rbp)
	jne	.LBB1_4
# %bb.3:                                # %label_5
	addl	$-10, -28(%rbp)
	jmp	.LBB1_6
.LBB1_4:                                # %label_6
	addl	$10, -28(%rbp)
	jmp	.LBB1_6
.LBB1_5:                                # %label_2
	movl	-28(%rbp), %edi
	callq	putint@PLT
.LBB1_6:                                # %label_3
	movl	-28(%rbp), %edi
	callq	putint@PLT
	movq	%rsp, %rax
	leaq	-16(%rax), %rbx
	movq	%rbx, %rsp
	movl	$0, -16(%rax)
	movq	%rsp, %rax
	leaq	-16(%rax), %r14
	movq	%r14, %rsp
	movl	$0, -16(%rax)
	cmpl	$3, (%rbx)
	jle	.LBB1_8
	jmp	.LBB1_12
	.p2align	4, 0x90
.LBB1_9:                                # %label_11
                                        #   in Loop: Header=BB1_8 Depth=1
	incl	(%rbx)
	cmpl	$3, (%rbx)
	jg	.LBB1_12
.LBB1_8:                                # %label_9
                                        # =>This Inner Loop Header: Depth=1
	cmpl	$1, (%rbx)
	je	.LBB1_9
# %bb.10:                               # %label_12
                                        #   in Loop: Header=BB1_8 Depth=1
	cmpl	$3, (%rbx)
	je	.LBB1_12
# %bb.11:                               # %label_15
                                        #   in Loop: Header=BB1_8 Depth=1
	movl	(%rbx), %edi
	callq	putint@PLT
	incl	(%rbx)
	cmpl	$3, (%rbx)
	jle	.LBB1_8
.LBB1_12:                               # %label_10
	movq	%rsp, %r15
	leaq	-80(%r15), %rsp
	movl	$1, (%rbx)
	movl	$2, (%r14)
	movl	(%rbx), %eax
	addl	$4, %eax
	movl	%eax, -80(%r15)
	movl	(%rbx), %eax
	leal	(%rax,%rax,2), %eax
	addl	%eax, %eax
	addl	(%r14), %eax
	cltq
	movl	$3, -80(%r15,%rax,4)
	movl	-80(%r15), %edi
	callq	putint@PLT
	movl	(%rbx), %eax
	leal	(%rax,%rax,2), %eax
	addl	%eax, %eax
	addl	(%r14), %eax
	cltq
	movl	-80(%r15,%rax,4), %edi
	callq	putint@PLT
	movl	(%rbx), %eax
	leal	(%rax,%rax,2), %eax
	addl	%eax, %eax
	addl	(%r14), %eax
	cltq
	movl	-80(%r15,%rax,4), %edi
	addl	-80(%r15), %edi
	movq	%rsp, %rax
	leaq	-16(%rax), %rsp
	movl	%edi, -16(%rax)
	callq	putint@PLT
	movq	a@GOTPCREL(%rip), %rbx
	movl	$5, (%rbx)
	movl	$2, 28(%rbx)
	movl	$5, %edi
	callq	putint@PLT
	movl	28(%rbx), %edi
	callq	putint@PLT
	callq	getint@PLT
	movl	%eax, 28(%rbx)
	movl	%eax, %edi
	callq	putint@PLT
	xorl	%eax, %eax
	leaq	-24(%rbp), %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	N,@object                       # @N
	.section	.rodata,"a",@progbits
	.globl	N
	.p2align	2, 0x0
N:
	.long	3                               # 0x3
	.size	N, 4

	.type	a,@object                       # @a
	.bss
	.globl	a
	.p2align	4, 0x0
a:
	.zero	72
	.size	a, 72

	.section	".note.GNU-stack","",@progbits
