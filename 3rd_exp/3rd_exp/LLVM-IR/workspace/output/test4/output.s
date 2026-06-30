	.text
	.file	"output.ll"
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	subq	$152, %rsp
	.cfi_def_cfa_offset 160
	movl	$1, 4(%rsp)
	movl	$1, (%rsp)
	.p2align	4, 0x90
.LBB0_1:                                # %label_1
                                        # =>This Inner Loop Header: Depth=1
	xorl	%eax, %eax
	cmpl	$5, (%rsp)
	setl	%cl
	cmpl	$4, 4(%rsp)
	jg	.LBB0_4
# %bb.2:                                # %label_1
                                        #   in Loop: Header=BB0_1 Depth=1
	movb	%cl, %al
	testl	%eax, %eax
	je	.LBB0_4
# %bb.3:                                # %label_2
                                        #   in Loop: Header=BB0_1 Depth=1
	movl	4(%rsp), %eax
	leal	(%rax,%rax,2), %ecx
	movl	(%rsp), %edx
	leal	(%rdx,%rcx,2), %ecx
	movslq	%ecx, %rcx
	addl	%edx, %eax
	movl	%eax, 8(%rsp,%rcx,4)
	incl	%edx
	movl	%edx, (%rsp)
	jmp	.LBB0_1
	.p2align	4, 0x90
.LBB0_5:                                # %label_5
                                        #   in Loop: Header=BB0_4 Depth=1
	movb	%cl, %al
	testl	%eax, %eax
	je	.LBB0_7
# %bb.6:                                # %label_6
                                        #   in Loop: Header=BB0_4 Depth=1
	movl	4(%rsp), %eax
	leal	(%rax,%rax,2), %ecx
	movl	(%rsp), %edx
	leal	(%rdx,%rcx,2), %ecx
	movslq	%ecx, %rcx
	movl	%eax, %esi
	subl	%edx, %esi
	movl	%esi, 8(%rsp,%rcx,4)
	incl	%eax
	movl	%eax, 4(%rsp)
.LBB0_4:                                # %label_5
                                        # =>This Inner Loop Header: Depth=1
	xorl	%eax, %eax
	cmpl	$6, (%rsp)
	setl	%cl
	cmpl	$4, 4(%rsp)
	jle	.LBB0_5
.LBB0_7:                                # %label_7
	movl	36(%rsp), %edi
	addl	48(%rsp), %edi
	addl	124(%rsp), %edi
	callq	putint@PLT
	xorl	%eax, %eax
	addq	$152, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
