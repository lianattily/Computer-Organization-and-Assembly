a:	EQU	3
b:	EQU	5

	lui 	a0, (a & 0xffffffff) >> 12
	addi 	a0, a0, a & 0xfff 		;;load a
	lui 	a1, (b & 0xffffffff) >> 12
	addi 	a1, a1, b & 0xfff 		;;load b
	jal	ra, FUN				;;invoke FUN
	ecall	x0, a0, 0			;;print FUN
	break	x0, x0, 0