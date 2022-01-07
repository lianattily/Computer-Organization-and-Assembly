recfun:	addi	sp, sp, -8
	sd	ra, 0(sp)
	bnq	a0, x0, rec		;;a>0 go to rec, else return b
	addi	a0, a1, 0		;;a=b
	ld	ra, 0(sp)
	addi	sp, sp, 8
	jalr	x0, 0(ra)		;;return b

rec: 
	addi	a0, a0, -1		;;a=a-1
	addi	a1, a1, 1		;;b=b+1
	jal	ra, fun
	jal	ra, recfun

;;LIAN ATTILY