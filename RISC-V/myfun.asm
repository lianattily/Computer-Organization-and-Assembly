myfun:	addi	sp, sp, -32
	sd	ra, 0(sp)
	sd	a0, 8(sp)
	sd	a1, 16(sp)
	sd	s0, 24(sp)

	add	s0, a0, a1		;;s0=a+b

	sub	a0, a0, a1		;;a0=a-b
	
	jal	ra, fun		;;fun(a0)
	sub	a0, a0, s0		;;fun(a-b) - a+b
	jal	ra, fun		;;fun(a0) again
	
	sd	s0, 24(sp)
	sd	a1, 16(sp)
	ld	a0, 8(sp)
	ld	ra, 0(sp)
	addi	sp, sp, 32
	jalr	x0, 0(ra)		;;return to caller



;;LIAN ATTILY