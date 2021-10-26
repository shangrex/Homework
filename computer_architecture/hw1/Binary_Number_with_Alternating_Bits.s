	.file	"Binary_Number_with_Alternating_Bits.c"
	.text
	.section	.rodata
.LC0:
	.string	"The answer is True."
.LC1:
	.string	"The answer is False."
.LC2:
	.string	"The answer is %s\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB6:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movl	$10, -28(%rbp)
	movl	-28(%rbp), %eax
	andl	$1, %eax
	testl	%eax, %eax
	setne	%al
	movb	%al, -29(%rbp)
	leaq	.LC0(%rip), %rax
	movq	%rax, -16(%rbp)
	leaq	.LC1(%rip), %rax
	movq	%rax, -8(%rbp)
	movq	-16(%rbp), %rax
	movq	%rax, -24(%rbp)
	jmp	.L2
.L4:
	sarl	-28(%rbp)
	movzbl	-29(%rbp), %eax
	movl	-28(%rbp), %edx
	andl	$1, %edx
	cmpl	%edx, %eax
	jne	.L3
	movq	-8(%rbp), %rax
	movq	%rax, -24(%rbp)
.L3:
	movl	-28(%rbp), %eax
	andl	$1, %eax
	testl	%eax, %eax
	setne	%al
	movb	%al, -29(%rbp)
.L2:
	cmpl	$0, -28(%rbp)
	jne	.L4
	movq	-24(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC2(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
