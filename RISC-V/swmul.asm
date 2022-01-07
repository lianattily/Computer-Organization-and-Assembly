;;Lian Attily | Section A | Labtest Q1 | October 30th, 2020
;;performs multiplication on two integers without the mul instruction (imitates the hardware command mul)
	ORG 64
x:	DD	12
y:	DD	40		
max:	DD	63	

	;;note: on some rvs it take ~10-15 seconds to finish executing

	ld	a0, x(x0)		;;a0=x
	ld	a1, y(x0)		;;a1=y
	
	mul	t0, a0, a1		;;test and compare swmul with mul command
	ecall	x0, t0, 0		;;prints x*y calculated by mul command

	jal	ra, swmul		;;invoke swmul
	ecall	x0, a0, 0		;;print multiplication result
	ebreak	x0, x0, 0

	;;a0<-x
	;;a1<-y
	;;s0<-res
	;;t0<-i
	;;t2<-max
swmul:	ld	t2, max(x0)		;;t2=63
	addi	t0, x0, 0		;;i=0
	addi	s0, x0, 0		;;res=0

loop:	andi	t1, a1, 1		;;t1= y AND 1 (if y is odd)
	beq	t1, x0, do		;;t1==0 (fals) skip res+=x
	add	s0, s0, a0		;;res+=x

do:	slli	a0, a0, 1		;;x=shift left
	srai	a1, a1, 1		;;y=shift right
	addi	t0, t0, 1		;;i++
	bne	t0, t2, loop		;;i<63? loop again
	addi	a0, s0, 0		;;copy result onto a0
	jalr	x0, 0(ra) 		;;return to caller
