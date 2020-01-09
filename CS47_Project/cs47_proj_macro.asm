# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

#####################################################################
# extract_nth_bit
#	- extract nth bit from bit pattern
# regD: contains 0x0 or 0x1 depending on whether n is 0 or 1
# regS: source bit pattern
# regT: index / bit position n (0 to 31)
# LEC 18: Slide 19
#####################################################################

.macro extract_nth_bit($regD, $regS, $regT)
	move	$s0, $regS		# s0 = regS for manipulation
	srlv	$s0, $s0, $regT		# shift right regS by value in regT
	andi	$regD, $s0, 0x1		# puts needed value in regD
.end_macro

#####################################################################
# insert_to_nth_bit
#	- insert bit 1 at nth bit to a bit pattern
# regD: bit pattern in which 1 (or 0) to be inserted at nth position
# regS: value n, from which position the bit to be inserted (0-31)
# regT: register that contains 0x1 or 0x0 (bit value to insert)
# maskedReg: register to hold temporary mask
# LEC 18: Slide 20
#####################################################################

.macro insert_to_nth_bit($regD, $regS, $regT, $maskedReg)
	addi	$maskedReg, $maskedReg, 0x1	# set maskReg at 1
	sllv	$maskedReg, $maskedReg, $regS	# shifts 1 by value in regS
	not	$maskedReg, $maskedReg		# invert maskReg
	and	$regD, $regD, $maskedReg	# mask regD with maskReg
	sllv	$regT, $regT, $regS		# shifts regT by value in regS
	or	$regD, $regD, $regT		# OR resultant pattern to $regD to insert bit at nth position
.end_macro 
	
	
	
	
