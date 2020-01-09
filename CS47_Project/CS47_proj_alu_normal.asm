.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################

au_normal:
	# frame creation
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	# set operation codes
	li	$t0, '+'
	li	$t1, '-'
	li	$t2, '*'
	li	$t3, '/'
	
	# check operation code then branch to operation
	beq	$a2, $t0, addition
	beq	$a2, $t1, subtraction
	beq	$a2, $t2, multiplication
	beq	$a2, $t3, division
	
	j	end_au_normal
	
addition:
	add	$v0, $a0, $a1	# v0 = a0 + a1
	j	end_au_normal
	
subtraction:
	sub	$v0, $a0, $a1	# v0 = a0 - a1
	j	end_au_normal
	
multiplication:
	mult	$a0, $a1	# a0 * a1
	mflo	$v0		# v0 = lo
	mfhi	$v1		# v1 = hi
	j	end_au_normal
	
division:
	div	$a0, $a1	# a0 / a1
	mflo	$v0		# v0 = lo
	mfhi	$v1		# v1 = hi
	j	end_au_normal
	
end_au_normal:
	#restore frame
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr	$ra

