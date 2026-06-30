	.text
	.file	"output.ll"
	.globl	func                            # -- Begin function func
	.p2align	4, 0x90
	.type	func,@function
func:                                   # @func
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbx
	.cfi_def_cfa_offset 16
	subq	$16, %rsp
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -16
	movl	%edi, 12(%rsp)
	xorl	%eax, %eax
	testl	%edi, %edi
	sete	%cl
	cmpl	$1, %edi
	je	.LBB0_2
# %bb.1:                                # %label_4
	movb	%cl, %al
	testl	%eax, %eax
	je	.LBB0_4
.LBB0_2:                                # %label_1
	movl	$1, %eax
.LBB0_3:                                # %label_1
	addq	$16, %rsp
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.LBB0_4:                                # %label_2
	.cfi_def_cfa_offset 32
	movl	12(%rsp), %edi
	decl	%edi
	callq	func@PLT
	movl	%eax, %ebx
	movl	12(%rsp), %edi
	addl	$-2, %edi
	callq	func@PLT
	addl	%ebx, %eax
	jmp	.LBB0_3
.Lfunc_end0:
	.size	func, .Lfunc_end0-func
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbx
	.cfi_def_cfa_offset 16
	subq	$16, %rsp
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -16
	movl	$10, 12(%rsp)
	movq	a@GOTPCREL(%rip), %rbx
	movl	$12, %edi
	callq	func@PLT
	movl	%eax, (%rbx)
	movl	%eax, %edi
	callq	putint@PLT
	xorl	%eax, %eax
	addq	$16, %rsp
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
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
	.long	100                             # 0x64
	.size	N, 4

	.type	a,@object                       # @a
	.bss
	.globl	a
	.p2align	4, 0x0
a:
	.zero	400
	.size	a, 400

	.section	".note.GNU-stack","",@progbits
