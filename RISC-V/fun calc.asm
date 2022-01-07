;;Lian Attily 	|	Section A	| Labtest1	| October 30th, 2020
;;Evaluates an expression that has operators * or + followed by two operands
STR:	DC 	" + 3 *12 2\0"
SPTR:	DD 	STR

	addi	sp, sp, 0		;;initialize sp
	addi	a0, x0, SPTR		;;a0 address is 0x08 but contains 0x00
	jal	ra, funcalc		;;invoke funcalc
	ecall	x0, a0, 0		;;print funcalc result
	ebreak	x0, x0, 0

	;;a0<address of first non-space byte
	;;t0<ascii of space
	;;t2<*s
	;;t3<char c
eatblanks:	
	ld	t2, 0(a0)		;;t2 has address of s (0x00)
	lbu	t3, 0(t2)		;;t3 has char c value
	addi	t0, x0, ' '		;;t0 has ascii of space
	bne	t0, t3, end		;; c!=' ' then end
while:	
	addi	t2, t2, 1		;;*s++
	sd	t2, 0(a0)		;;save address back into a0 (update)
	lbu	t3, 0(t2)		;;load next byte (c)
	beq	t0, t3, while		;; if c=' ' then loop
end:	jalr	x0, 0(ra)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;a0<address of first non-blank byte
	;;s0<res
	;;t0<'+' or '*' or '0'
	;;t1<'9'
	;;t2<*s
	;;t3<c (first char without blanks)
	;;t5<10
funcalc:
	addi	sp, sp, -24
	sd	ra, 0(sp)
	sd	a0, 8(sp)		
	sd	s0, 16(sp)
	jal	ra, eatblanks		
	ld	t2, 0(a0)		;;t2 has address of s (0x00)
	lbu	t3, 0(t2)		;;t3 has char c value (c=*s[0])

	addi	t0, x0, '0'		;;t0 = asci of '0'
	addi	t1, x0, '9'		;;t1 = asci of '9'

	blt	t3, t0, add
	blt	t1, t3, add		;;!('0'<=c<='9')

	addi	s0, x0, 0		;;initialize res=0
	addi	t5, x0, 10		;;t5=10

loop:	mul	s0, s0, t5		;;res=res*10
	sub	t4, t3, t0		;;t4=c-'0' (converts c to int value)
	add	s0, s0, t4		;;res+=t4
	addi	t2, t2, 1		;;*s++
	sd	t2, 0(a0)		
	lbu	t3, 0(t2)		;;load next byte

	bge	t3, t0, loop		;;c>=48
	blt	t1, t3, loop		;;c<=57	('0'<=c<='9')

eval:	add	t6, x0, s0		;;save s0 into temp before restoring
	ld	ra, 0(sp)		;;restore ra
	ld	a0, 8(sp)		;;restore a0
	ld	s0, 24(sp)		;;restore s0
	addi	sp, sp, 24
	addi	a0, t6, 0		;;copy value of t0(res) into a0

	jalr	x0, 0(ra)		;;return to caller

			
add:	addi	t0, x0, '+'		;;t0 = asci of '+'
	bne	t0, t3, mult		;; c!='+'
	addi	t2, t2, 1		;;*s++
	sd	t2, 0(a0)
	jal	ra, funcalc		;;first recursive call
	addi	s0, a0, 0		;;res=funcalc(s)
	
	ld	a0, 8(sp)		;;read/copy old a0 from the stack 
	sd	s0, 16(sp)		;;save res onto stack
	jal	ra, funcalc		;;second recursive call
	ld	s0, 16(sp)		;;read old value of res
	add	s0, s0, a0		;;res*=funcalc(s)

	ld	a0, 8(sp)		;;read/copy old a0 from the stack
	sd	s0, 16(sp)		;;push res onto stack
	beq	x0, x0, exit

mult:	addi	t0, x0, '*'		;;t0 = asci of '*'
	bne	t0, t3, return		;; c!='*'
	addi	t2, t2, 1		;;*s++
	sd	t2, 0(a0)
	jal	ra, funcalc		;;first recursive call
	addi	s0, a0, 0		;;res=funcalc(s)

	ld	a0, 8(sp)		;;read/copy old a0 from the stack
	sd	s0, 16(sp)		;;save res onto stack
	jal	ra, funcalc		;;second recursive call
	ld	s0, 16(sp)		;;read old value of res
	mul	s0, s0, a0		;;res*=funcalc(s)
	ld	a0, 8(sp)		;;read old a0 from the stack 
	sd	s0, 16(sp)		;;push res onto stack

exit:	
	ld	s0, 16(sp)
	ld	a0, 8(sp)
	ld	ra, 0(sp)
	addi	sp, sp, 24
	addi	a0, s0, 0
	jalr	x0, 0(ra)		;;return to caller

;;invalid input return -1
return:	ld	s0, 16(sp)
	ld	a0, 8(sp)
	ld	ra, 0(sp)
	addi	sp, sp, 24
	addi	a0, x0, -1		;;copy -1 into a0
	jalr	x0, 0(ra)		;;return to caller
	