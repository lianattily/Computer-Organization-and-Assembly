	
scramble:	lb	t0, 0(a0)		
	beq	t0, x0, end		;;terminate if done
	addi	a0, a0, 1		;;next byte
	rem	t1, t0, 2		;;check if odd or even
	bne	t1, x0, scramble	
	addi	t0, t0, 1	
	
end:	ebreak	x0, x0, 0
