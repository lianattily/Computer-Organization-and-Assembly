A:	DF	1.21, 5.85, -7.3, 23.1, -5.55
B:	DF 	3.14, -2.1, 44.2, 11.0, -7.77

	addi	t0, x0, 0		//i=0
	addi	t1, x0, 40

loop:	fld	f1, A(t0)
	fld	f2, B(t0)
	fmul.d	f4, f1, f2
	fadd.d	f3, f3, f4
	addi	t0, t0, 8
	beq	t0, t1, end
	jal	ra, loop

end:	fsd	f3, dst(x0)
	ecall	x0, f3, 1
	ebreak 	x0, x0, 0

dst:	DM	1