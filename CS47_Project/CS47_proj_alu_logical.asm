.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################

au_logical:
	# frame creation
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	# starts off similar to normal
	li	$t0, '+'
	li	$t1, '-'
	li	$t2, '*'
	li	$t3, '/'
	
	# check operation code then branch to operation
	beq	$a2, $t0, add_logical
	beq	$a2, $t1, sub_logical
	beq	$a2, $t2, mult_signed
	beq	$a2, $t3, div_signed

end_au_logical:
	# restore frame
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr	$ra

#####################################################################
# add_logical
#	- calls add_sub_logical with a2 = 0x00000000
# a0: first number
# a1: second number
# v0: a0 + a1
# LEC 18: Slide 23
#####################################################################

add_logical:
	# frame creation
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	li	$a2, 0x00000000		# set a2 as 0x00000000 (addition mode)
	jal	add_sub_logical		# jump and link to add_sub_logical
	
	# restore frame
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr	$ra
	
#####################################################################
# sub_logical
#	- calls add_sub_logical with a2 = 0xFFFFFFFF
# a0 = first number
# a1 = second number
# v0 = a0 - a1
# LEC 18: Slide 23
#####################################################################

sub_logical:
	#frame creation
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	li	$a2, 0xFFFFFFFF		# set a2 as 0xFFFFFFFF (subtraction mode)
	jal	add_sub_logical		# jump and link to add_sub_logical
	
	# restore frame
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr 	$ra

#####################################################################
# add_sub_logical
#	- common procedure for addition and subtraction
# a0: first number
# a1: second number
# a2: operation mode
#	- addition (0x00000000) or subtraction (0xFFFFFFFF)
# v0: a0 + a1 in addition mode; a0 - a1 in subtraction mode
# LEC 18: Slide 21, 22
#####################################################################

add_sub_logical:
	# frame creation
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$a2, 12($sp)
	sw	$s0, 8($sp)
	addi	$fp, $sp, 28
	
	add	$t0, $zero, $zero			# I = index (0 to 31)
	extract_nth_bit($t1, $a2, $zero)		# set C as 1st bit of the mode value in a2
	add	$t2, $zero, $zero			# S = result of operation
	beq	$a2, 0xFFFFFFFF, subtraction_mode	# test if a2 is addition or subtraction mode
	j	loop
	
subtraction_mode:
	not	$a1, $a1				# invert second number if subtraction mode
	j	loop					# continue to loop
loop:
	beq	$t0, 0x20, end_add_sub_logical		# loop again if index is not at 32
	extract_nth_bit($t3, $a0, $t0)			# t3 = A; A = a0 at I
	extract_nth_bit($t4, $a1, $t0)			# t4 = B; B = a1 at I
	# one bit full adder logical equation
	xor	$t5, $t3, $t4				# t5 = XOR of A and B
	xor	$t6, $t5, $t1				# t6 = XOR of t5 and C
	and	$t7, $t3, $t4				# t7 = AND of A and B
	and	$t1, $t1, $t5				# C = AND of C and t5
	or	$t1, $t1, $t7				# C = OR of C and t7
	insert_to_nth_bit($t2, $t0, $t6, $t8)		# insert sum bit (Y) into I position of result
	addi	$t0, $t0, 0x1				# I = I + 1
	j	loop
	
end_add_sub_logical:
	move	$v0, $t2				# v0 = S
	move	$v1, $t1				# final carry out: v1 = carry bit
	# restore frame
	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$a2, 12($sp)
	lw	$s0, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra

#####################################################################
# twos_complement
#	- use add_logical and not to compute ~a0 + 1
# a0: number of which 2's complement to be computed
# v0: 2's compliment of a0
# LEC 19: Slide 9
#####################################################################

twos_complement:
	# frame creation
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$a2, 12($sp)
	sw	$s0, 8($sp)
	addi	$fp, $sp, 28
	
	not	$a0, $a0		# invert a0 to get ~a0
	li	$a1, 0x1		# set a1 as 1
	jal	add_logical		# ~a0 + 1 to get 2's complement
	
	# restore frame
	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$a2, 12($sp)
	lw	$s0, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra

#####################################################################
# twos_complement_if_neg
#	- test if a0 is less than zero and use if needed
# a0: number of which 2's complement to be computed
# v0: 2's complement of a0 if a0 is negative
# LEC 19: Slide 10
#####################################################################
	
twos_complement_if_neg:
	# frame creation
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$a2, 12($sp)
	sw	$s0, 8($sp)
	addi	$fp, $sp, 28
	
	move	$v0, $a0				# v0 = a0
	bgt	$a0, $zero, end_twos_complement_if_neg	# if a0 > 0, do not 2's complement
	jal	twos_complement				# v0 = 2's complement of a0

end_twos_complement_if_neg:
	# restore frame
	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$a2, 12($sp)
	lw	$s0, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra
	
#####################################################################
# twos_complement_64bit
#	- upgrade add_logical to return final carryout in v1
# a0: lo of the number
# a1: hi of the number
# v0: lo part of 2's complemented 64 bit
# v1: hi part of 2's complemented 64 bit
# LEC 19: Slide 11
#####################################################################

twos_complement_64bit:
	# frame creation
	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$a0, 28($sp)
	sw	$a1, 24($sp)
	sw	$a2, 20($sp)
	sw	$s0, 16($sp)
	sw	$s1, 12($sp)
	sw	$s2, 8($sp)
	addi	$fp, $sp, 36
	
	not	$a0, $a0		# invert a0 (lo)
	not	$a1, $a1		# invert a1 (hi)
	move	$s0, $a1		# s0 = a1
	add	$a1, $zero, 0x1		# a1 = 1
	jal	add_logical		# v0 = 2's compliment of lo
	move	$s1, $v0		# s1 = 2's compliment of lo
	move	$s2, $v1		# s2 = carry bit
	move	$a0, $s0		# a0 = inverted hi
	move	$a1, $s2		# a1 = previous carry bit
	jal	add_logical		# v0 = a1 + carry bit of 2's complement of lo
	move	$v1, $v0		# v1 = 2's complement of hi
	move	$v0, $s1		# v0 = 2's complement of lo

	# restore frame
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$a0, 28($sp)
	lw	$a1, 24($sp)
	lw	$a2, 20($sp)
	lw	$s0, 16($sp)
	lw	$s1, 12($sp)
	lw	$s2, 8($sp)
	addi	$sp, $sp, 36
	jr	$ra
	
#####################################################################
# bit_replicator
#	- replicate given bit value to 32 times
# a0: 0x0 or 0x1 (the bit value to be replicated)
# v0: 	0x00000000 if a0 = 0x0
#	0xFFFFFFFF if a0 = 0x1
# LEC 19: Slide 12
#####################################################################
	
bit_replicator:
	# frame creation
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$a2, 12($sp)
	sw	$s0, 8($sp)
	addi	$fp, $sp, 28
	
	beq	$a0, $zero, zero_replicate	# if a0 = 0, v0 = 0x00000000
	beq	$a0, 0x1, one_replicate		# if a0 = 1, v0 = 0xFFFFFFFF
	
zero_replicate:
	li	$v0, 0x00000000			# v0 = 0x00000000
	j	end_bit_replicator
	
one_replicate:
	li	$v0, 0xFFFFFFFF			# v0 = 0xFFFFFFFF
	j	end_bit_replicator
	
end_bit_replicator:
	# restore frame
	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$a2, 12($sp)
	lw	$s0, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra
	
#####################################################################
# mult_unsigned
# a0: multiplicant
# a1: multiplier
# v0: lo part of result
# v1: hi part of result
# LEC 19: Slide 13,14
#####################################################################
	
mult_unsigned:
	# frame creation
	addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw	$a2, 44($sp)
	sw	$a3, 40($sp)
	sw	$s0, 36($sp)
	sw	$s1, 32($sp)
	sw	$s2, 28($sp)
	sw	$s3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 60
	
	add	$s1, $zero, $zero		# s1 = I = index = 0
	add	$s2, $zero, $zero		# s2 = H = hi = 0
	move	$s3, $a1			# s3 = L = MLPR
	move	$s4, $a0			# s4 = M = MCND
	
mult_unsigned_loop:
	beq	$s1, 0x20, end_mult_unsigned	# loop again if index =/= 32
	extract_nth_bit($a0, $s3, $zero)	# L[0] = 0th bit of L to be put in bit_replicator
	jal	bit_replicator			# v0 = 32 replication of L[0]
	move	$s5, $v0			# s5 = R = {32{L[0]}}
	and	$s6, $s4, $s5			# s6 = X = M & R
	move	$a0, $s2			# a0 = H to be used for adding
	move	$a1, $s6			# a1 = X to be used for adding
	jal	add_logical			# v0 = H + X
	move	$s2, $v0			# H = H + X
	srl	$s3, $s3, 0x1			# L >> 1
	extract_nth_bit($s7, $s2, $zero)	# s7 = H[0]
	add	$t0, $zero, 31			# t0 = 31
	insert_to_nth_bit($s3, $t0, $s7, $t1)	# L[31] = H[0]
	srl	$s2, $s2, 0x1			# H >> 1
	addi	$s1, $s1, 0x1			# I = I + 1
	j	mult_unsigned_loop
	
end_mult_unsigned:
	move	$v0, $s3			# v0 = lo
	move	$v1, $s2			# v1 = hi
	# restore frame
	lw	$fp, 60($sp)
	lw	$ra, 56($sp)
	lw	$a0, 52($sp)
	lw	$a1, 48($sp)
	lw	$a2, 44($sp)
	lw	$a3, 40($sp)
	lw	$s0, 36($sp)
	lw	$s1, 32($sp)
	lw	$s2, 28($sp)
	lw	$s3, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 60
	jr	$ra
	
#####################################################################
# mult_signed
# a0: multiplicand
# a1: multiplier
# v0: lo part of result
# v1: hi part of result
# LEC 19: Slide 15, 16
#####################################################################
	
mult_signed: 
	# frame creation
	addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw	$a2, 44($sp)
	sw	$a3, 40($sp)
	sw	$s0, 36($sp)
	sw	$s1, 32($sp)
	sw	$s2, 28($sp)
	sw	$s3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 60
	
	move	$s3, $a0			# s3 = n1 = copy of a0
	move	$a2, $a0			# a2 = extra copy
	move	$s4, $a1			# s4 = n2 = copy of a1
	move	$a3, $a1			# a3 = extra copy
	jal	twos_complement_if_neg		# gets the 2's complement of n1
	move	$s3, $v0			# n1 = v0
	move	$a0, $s4			# a0 = s4
	jal	twos_complement_if_neg		# get's the twos complement of n2
	move	$s4, $v0			# n2 = v0
	move	$a0, $s3			# a0 = n1
	move	$a1, $s4			# a1 = n2
	jal	mult_unsigned			# n1 * n2
	move	$s3, $v0			# s3 = Rlo
	move	$s4, $v1			# s4 = Rhi
	add	$t0, $zero, 0x1F		# t0 = 31
	extract_nth_bit($t1, $a2, $t0)		# extract a0[31]
	extract_nth_bit($t2, $a3, $t0)		# extract a1[31]
	xor	$t3, $t1, $t2			# t3 = S = a0[31] XOR a1[31]
	# if S = 1, use 2's complement 64 bit to determine 2's complement form of 64 bit number in Rhi, Rlo
	beq	$t3, 0x1, twos_comp_64bit
	j	end_mult_unsigned

twos_comp_64bit:
	move	$a0, $s3			# a0 = Rlo
	move	$a1, $s4			# a1 = Rhi
	jal	twos_complement_64bit
	move	$s3, $v0			# s3 = 2's complement of lo
	move	$s4, $v1			# s4 = 2's complement of hi
	
end_mult_signed:
	move	$v0, $s3			# v0 = lo
	move	$v1, $s4			# v1 = hi
	# restore frame
	lw	$fp, 60($sp)
	lw	$ra, 56($sp)
	lw	$a0, 52($sp)
	lw	$a1, 48($sp)
	lw	$a2, 44($sp)
	lw	$a3, 40($sp)
	lw	$s0, 36($sp)
	lw	$s1, 32($sp)
	lw	$s2, 28($sp)
	lw	$s3, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 60
	jr	$ra
	
#####################################################################
# div_unsigned
# a0: dividend
# a1: divisor
# v0: quotient
# v1: remainder
# LEC 20: Slide 9, 10
#####################################################################

div_unsigned:
	# frame creation
	addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw	$a2, 44($sp)
	sw	$a3, 40($sp)
	sw	$s0, 36($sp)
	sw	$s1, 32($sp)
	sw	$s2, 28($sp)
	sw	$s3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 60

	add	$s1, $zero, $zero		# s1 = I = index = 0
	move	$s2, $a0			# s2 = Q = DVND
	move	$s3, $a1			# s3 = D = DVSR
	add	$s4, $zero, $zero		# s4 = R = remainder = 0
	
div_unsigned_loop:
	beq	$s1, 0x20, end_div_unsigned
	sll	$s4, $s4, 0x1			# R = R << 1
	addi	$s5, $zero, 0x1F		# s5 = 31
	extract_nth_bit($s6, $s2, $s5)		# s6 = Q[31]
	add	$t9, $zero, $zero		# t1 = 0
	insert_to_nth_bit($s4, $zero, $s6, $t9) # R[0] = Q[31]
	sll	$s2, $s2, 0x1			# Q = Q << 1
	move	$a0, $s4			# a0 = R
	move	$a1, $s3			# a0 = D
	jal	sub_logical			# v0 = S = R - D
	move	$s7, $v0			# s7 = S
	bltz	$s7, end_div_unsigned_loop	# if S < 0, loop again
	move	$s4, $s7			# R = S
	add	$t4, $zero, $zero		# t4 = 0
	addi	$t3, $zero, 0x1			# t3 = 1
	insert_to_nth_bit($s2, $zero, $t3, $t4)	# Q[0] = 1
	
end_div_unsigned_loop:
	addi	$s1, $s1, 0x1			# I = I + 1
	jal	div_unsigned_loop
	
end_div_unsigned:
	move	$v0, $s2			# v0 = Q
	move	$v1, $s4			# v1 = R
	# restore frame
	lw	$fp, 60($sp)
	lw	$ra, 56($sp)
	lw	$a0, 52($sp)
	lw	$a1, 48($sp)
	lw	$a2, 44($sp)
	lw	$a3, 40($sp)
	lw	$s0, 36($sp)
	lw	$s1, 32($sp)
	lw	$s2, 28($sp)
	lw	$s3, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 60
	jr	$ra
	
	
#####################################################################
# div_signed
# a0: dividend
# a1: divisor
# v0: quotient
# v1: remainder
# LEC 20: Slide 11, 12
#####################################################################

div_signed:
	# frame creation
	addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw	$a2, 44($sp)
	sw	$a3, 40($sp)
	sw	$s0, 36($sp)
	sw	$s1, 32($sp)
	sw	$s2, 28($sp)
	sw	$s3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 60
	
	move	$s3, $a0			# s3 = a0 = n1
	move	$s4, $a1			# s4 = a1 = n2
	jal	twos_complement_if_neg
	move	$s1, $v0			# s1 = 2's complement of n1
	move	$a0, $a1			# a0 = n2 to find 2's complement
	jal	twos_complement_if_neg		
	move	$s2, $v0			# s2 = 2's complement of n2
	move	$a0, $s1			# a0 = n1
	move	$a1, $s2			# a1 = n2
	jal	div_unsigned			# unsigned div of n1 & n2
	move	$s1, $v0			# s1 = Q
	move	$s2, $v1			# s2 = R
	# find sign of Q
	addi	$t0, $zero, 0x1F		# t0 = 31
	extract_nth_bit($s5, $s3, $t0)		# s5 = a0[31]
	extract_nth_bit($s6, $s4, $t0)		# s6 = a1[31]
	xor	$s7, $s5, $s6			# s7 = S = s5 XOR s6
	beq	$s7, 0x1, twos_comp_q		# if S = 1, find 2's complement of Q
	bne	$s7, 0x1, twos_comp_r		# if S =/= 1, find 2's complement of R
	
twos_comp_q:
	move	$a0, $s1			# a0 = Q
	jal	twos_complement
	move	$s1, $v0			# s1 = 2's complement of Q
	j	twos_comp_r
	
	# find sign of R
twos_comp_r:
	move	$s7, $s5			# S = a0[31]
	bne	$s7, 0x1, end_div_signed	# if S =/= 1, go to end
	move	$a0, $s2			# a0 = R
	jal	twos_complement
	move	$s2, $v0			# s2 = 2's complement of R
	j	end_div_signed
	
end_div_signed:
	move	$v0, $s1			# v0 = Q
	move	$v1, $s2			# v1 = R
	# restore frame
	lw	$fp, 60($sp)
	lw	$ra, 56($sp)
	lw	$a0, 52($sp)
	lw	$a1, 48($sp)
	lw	$a2, 44($sp)
	lw	$a3, 40($sp)
	lw	$s0, 36($sp)
	lw	$s1, 32($sp)
	lw	$s2, 28($sp)
	lw	$s3, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 60
	jr	$ra
	







