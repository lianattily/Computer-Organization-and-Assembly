;; Minas Spetsakis, Oct. 2020
;; Function addupper and main program to test Function addupper

	ORG 64

STR:	DC "Minas E. Spetsakis\0"
STR1:	DC "minas e. spetsakis\\;;AA\0"
LEN:	EQU 8

	addi	a0, x0, STR1		;; first arg
	addi	a1, x0, LEN		;; sec. arg (try a few numbers)

	jal	ra, addupper
	ecall	x0, a0, 0
	ebreak x0, x0, 0

addupper:
	addi	t5, x0, 'A'		;; t5<-A
	addi	t6, x0, 'Z'		;; t6<-Z
addupper1:
	lb	t0, 0(a0)
	beq	t0, x0, ENDadd		;; similar to last lab
	blt	t0, t5, RECadd
	blt	t6, t0, RECadd
	addi	a1, a1, 1
RECadd:
	addi	a0, a0, 1		;; Recursive call
	jal	x0, addupper1		;; note it is tail recursive
ENDadd:
	addi	a0, a1, 0
	jalr	x0, 0(ra)