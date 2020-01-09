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
	
	# Macro : exit
        # Usage: exit
        .macro exit
	li 	$v0, 10 
	syscall
	.end_macro
	
