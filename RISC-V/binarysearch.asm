prompt:	DC	"integer:"
arr:	DD	10,20,21,30,33,41,42,46,99,118,121,122, 130
max:	EQU	12

	addi	sp, x0, 0		;;initialize stack ptr
	addi	a0, x0, arr		;;a0=*arr
	ld	a1, prompt(x0)
	ecall	a1, a1, 5		;;input integer to search for (a1)
	addi	a2, x0, 0		;;low
	addi	a3, x0, max		;;high
	jal	x0, bsearch
	ecall	x0, a0, 0
	ebreak	x0, x0, 0

bsearch:	blt	a3, a2, none		;;(high>low) end
	 add	t0, a2, a3		;;t0=high+low
	 srai	t0, t0, 1		;;t0=(high+low)/2 aka mid
	 slli	t2, t0, 3		;;t0*8
	 add	t1, t2, a0		;;t1=*arr+offset(t2) bytes
	 ld	t1, 0(t1)		;;load array[mid] into t1
	 blt	a1, t1, if1		;;element<mid? first if
	 blt	a0, a1, if2		;;element>mid? second if
	 add	a0, t0, 0		;;else element=mid and return
	 jalr	x0, 0(ra)

if1:	addi	a3, t0, -1		;;high=mid-1
	jal	x0, bsearch

if2:	addi	a2, t0, 1		;;low=mid+1
	jal	x0, bsearch

none:	addi	a0, x0, -1		;;element not found return -1
	jalr	x0, 0(ra)		