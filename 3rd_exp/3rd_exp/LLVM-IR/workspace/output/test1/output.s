	.text
	.file	"output.ll"
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	callq	getint@PLT
	movl	%eax, 12(%rsp)
	callq	getint@PLT
	movl	%eax, 20(%rsp)
	addl	12(%rsp), %eax
	movl	%eax, 16(%rsp)
	movl	%eax, %edi
	callq	putint@PLT
	xorl	%eax, %eax
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
