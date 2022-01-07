;; Minas Spetsakis
;; Solution for the first lab
;; Adds four elements of an array without a loop.
;; Sep. 22, 2020

ARR:	DD 500, 10, 20, 40

	addi	t0, x0, ARR		;; Initialize two registers
				;; t0 is the address of ARR
	addi	t2, x0, 0		;; t2 is the sum
	ld	t1, 0(t0)		;; Load the first element
				;; t1 = ARR[0]
	add	t2, t2, t1		;; t2 += t1
	ld	t1, 8(t0)		;; To load the first element
	add	t2, t2, t1		;; we use 8 for the offset
	ld	t1, 16(t0)
	add	t2, t2, t1
	ld	t1, 24(t0)
	add	t2, t2, t1

	ecall	x0, t2, 0		;; Print an integer
	ebreak	x0, x0, 0		;; Stop the program.

;; NOTE:
;; Things like
;;	ld	t1, 0(t1)
;;	ld	t2, 0(t2)
;; where t1 and t2 have not been initialized, make no sense. 