	.text
	.file	"output.ll"
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
	subq	$24, %rsp
	.cfi_offset %rbx, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	callq	getint@PLT
	movl	%eax, -36(%rbp)
	callq	getint@PLT
	movl	%eax, -32(%rbp)
	movl	$0, -28(%rbp)
	movq	a@GOTPCREL(%rip), %rbx
	.p2align	4, 0x90
.LBB0_1:                                # %label_1
                                        # =>This Inner Loop Header: Depth=1
	movl	-28(%rbp), %eax
	cmpl	-36(%rbp), %eax
	jge	.LBB0_3
# %bb.2:                                # %label_2
                                        #   in Loop: Header=BB0_1 Depth=1
	movslq	-28(%rbp), %r14
	callq	getint@PLT
	movl	%eax, (%rbx,%r14,4)
	incl	-28(%rbp)
	jmp	.LBB0_1
.LBB0_3:                                # %label_3
	movl	$0, -28(%rbp)
	movq	b@GOTPCREL(%rip), %r14
	.p2align	4, 0x90
.LBB0_4:                                # %label_4
                                        # =>This Inner Loop Header: Depth=1
	movl	-28(%rbp), %eax
	cmpl	-32(%rbp), %eax
	jge	.LBB0_6
# %bb.5:                                # %label_5
                                        #   in Loop: Header=BB0_4 Depth=1
	movslq	-28(%rbp), %r15
	callq	getint@PLT
	movl	%eax, (%r14,%r15,4)
	incl	-28(%rbp)
	jmp	.LBB0_4
.LBB0_6:                                # %label_6
	movq	%rsp, %rcx
	leaq	-16(%rcx), %rax
	movq	%rax, %rsp
	movl	$0, -16(%rcx)
	movl	$0, -28(%rbp)
	movq	c@GOTPCREL(%rip), %r15
	jmp	.LBB0_7
	.p2align	4, 0x90
.LBB0_11:                               # %label_12
                                        #   in Loop: Header=BB0_7 Depth=1
	incl	-28(%rbp)
.LBB0_7:                                # %label_7
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_9 Depth 2
	movl	-28(%rbp), %ecx
	cmpl	-36(%rbp), %ecx
	jge	.LBB0_12
# %bb.8:                                # %label_8
                                        #   in Loop: Header=BB0_7 Depth=1
	movl	$0, (%rax)
	.p2align	4, 0x90
.LBB0_9:                                # %label_10
                                        #   Parent Loop BB0_7 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	(%rax), %ecx
	cmpl	-32(%rbp), %ecx
	jge	.LBB0_11
# %bb.10:                               # %label_11
                                        #   in Loop: Header=BB0_9 Depth=2
	movslq	-28(%rbp), %rcx
	movslq	(%rax), %rdx
	movl	(%rbx,%rcx,4), %ecx
	imull	(%r14,%rdx,4), %ecx
	movq	%rsp, %rdx
	leaq	-16(%rdx), %rsp
	movl	%ecx, -16(%rdx)
	movl	-28(%rbp), %edx
	addl	(%rax), %edx
	movslq	%edx, %rdx
	addl	%ecx, (%r15,%rdx,4)
	incl	(%rax)
	jmp	.LBB0_9
.LBB0_12:                               # %label_9
	movl	$0, -28(%rbp)
	.p2align	4, 0x90
.LBB0_13:                               # %label_13
                                        # =>This Inner Loop Header: Depth=1
	movl	-36(%rbp), %eax
	movl	-32(%rbp), %ecx
	leal	-1(%rax,%rcx), %eax
	cmpl	%eax, -28(%rbp)
	jge	.LBB0_15
# %bb.14:                               # %label_14
                                        #   in Loop: Header=BB0_13 Depth=1
	movslq	-28(%rbp), %rax
	movl	(%r15,%rax,4), %edi
	callq	putint@PLT
	incl	-28(%rbp)
	jmp	.LBB0_13
.LBB0_15:                               # %label_15
	xorl	%eax, %eax
	leaq	-24(%rbp), %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	N,@object                       # @N
	.section	.rodata,"a",@progbits
	.globl	N
	.p2align	2, 0x0
N:
	.long	10                              # 0xa
	.size	N, 4

	.type	a,@object                       # @a
	.bss
	.globl	a
	.p2align	4, 0x0
a:
	.zero	40
	.size	a, 40

	.type	b,@object                       # @b
	.globl	b
	.p2align	4, 0x0
b:
	.zero	40
	.size	b, 40

	.type	c,@object                       # @c
	.globl	c
	.p2align	4, 0x0
c:
	.zero	40
	.size	c, 40

	.section	".note.GNU-stack","",@progbits
