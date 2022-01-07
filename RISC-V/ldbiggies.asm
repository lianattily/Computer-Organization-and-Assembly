;; Lab A Programming Question
;; Load immediately 4 number with more that 12 bits
;; but less than 32
;; Minas Spetsakis, Jan 2020
// CONVENTIONS: comments that start with // are tutorial comments
//   or comments that I included, but your code should not.
// Comments that start with ; are comments that is good to have
CON1:	EQU 6000
CON2:	EQU 6245
CON3:	EQU 10000
CON4:	EQU 10245
A:	DM 4                         ; DM is Define Memory

	addi	t1,  x0, A           ; t1 = &A

	lui	t0,  (CON1>>12) + ((CON1 & 0x0800)>>11)
	addi	t0,  t0, CON1&0xFFF
	sd	t0,  0(t1)            // Cut and paste from last question of Quiz1
                                      // Blank line between groups of statements
	lui	t0,  (CON2>>12) + ((CON2 & 0x0800)>>11)
	addi	t0,  t0, CON2&0xFFF
	sd	t0,  8(t1)

	lui	t0,  (CON3>>12) + ((CON3 & 0x0800)>>11)
	addi	t0,  t0, CON3&0xFFF
	sd	t0,  16(t1)

	lui	t0,  (CON4>>12) + ((CON4 & 0x0800)>>11)
	addi	t0,  t0, CON4&0xFFF
	sd	t0,  24(t1)
                                      // We need this to avoid the NO INSTRUCTION error
	ebreak x0, x0, 0              ; Suspend program.