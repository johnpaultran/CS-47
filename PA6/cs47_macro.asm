#<------------------ MACRO DEFINITIONS ---------------------->#
        # Macro : print_str
        # Usage: print_str(<address of the string>)
        .macro print_str($arg)
	li	$v0, 4     # System call code for print_str  
	la	$a0, $arg   # Address of the string to print
	syscall            # Print the string        
	.end_macro
	
	# Macro : print_int
        # Usage: print_int(<val>)
        .macro print_int($arg)
	li 	$v0, 1     # System call code for print_int
	li	$a0, $arg  # Integer to print
	syscall            # Print the integer
	.end_macro
	
	# Macro : read_int
	# Usage : read_int(<register of int>)
	.macro read_int($reg)
	li	$v0, 5	# System call code for read_int
	syscall		# Read the integer
	move $reg, $v0 # Set $reg to contents of $v0
	.end_macro 
	
	# Macro : print_reg_int
	# Usage: print_reg_int(<register of int>)
	.macro print_reg_int($reg)
	li	$v0, 1 # System call for print_int
	move	$a0, $reg # Set $a0 to contents of $reg (tells what to print)
	syscall # Print the integer read
	.end_macro 
	
	# Macro : swap_hi_lo
	# Usage : swap_hi_lo(<HI>, <LO>)
	.macro swap_hi_lo($temp1, $temp2)
	mfhi 	$temp1 # Set address of $temp1 to address of value stored in Hi
	mflo 	$temp2 # Set address of $temp2 to address of value stored in Lo
	move 	$t2, $temp1 # Move $temp1 to a temporary address for manipulation
	move 	$t3, $temp2 # Move $temp2 to a temporary address for manipulation
	mthi 	$t3 # Swap value of Hi with our Lo value
	mtlo 	$t2 # Swap value of Lo value with our Hi value
	syscall
	.end_macro
	
	# Macro: print_hi_lo
	# Usage: print_hi_lo(<val>, <val>, <val>, <val>)
	.macro print_hi_lo ($strHi, $strEqual, $strComma, $strLo) 
	print_str($strHi)
	print_str($strEqual)
	mfhi	$t2
	print_reg_int($t2)
	print_str($strComma)
	print_str($strLo)
	print_str($strEqual)
	mflo	$t1
	print_reg_int($t1)
	.end_macro
	
	# Macro: lwi
	# Usage: lwi (<reg>, <upper>, <lower>)
	.macro lwi ($reg, $ui, $li)
	lui $reg, $ui
	ori $reg, $reg, $li
	.end_macro
	
	# Macro : exit
        # Usage: exit
        .macro exit
	li 	$v0, 10 
	syscall
	.end_macro
	
