.text
#-------------------------------------------
# Procedure: insertion_sort
# Argument: 
#	$a0: Base address of the array
#       $a1: Number of array element
# Return:
#       None
# Notes: Implement insertion sort, base array 
#        at $a0 will be sorted after the routine
#	 is done.
#-------------------------------------------
# for i ← 1 to length(A)
#    j ← i
#    while j > 0 and A[j-1] > A[j]		Given in Assignment
#        swap A[j] and A[j-1]
#        j ← j - 1
#    end while
# end for
insertion_sort:
	# Caller RTE store
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1, 8($sp)
	addi	$fp, $sp, 20
	# Implement insertion sort
	li	$t0, 1 # i = 1
	addi	$a1, $a1, -1 # set a1 to array length (-1)
	
for_loop:
	bgt	$t0, $a1, insertion_sort_end # ends loop if i > array length
	add	$t1, $t0, $zero # j = i
	
while:
	blez 	$t1, end_for_loop # if j <= 0, then break
	addi	$t2, $t1, -1	# t2 = j - 1
	add	$t3, $t1, $zero # t3 = j
	add	$t2, $t2 $t2
	add	$t2, $t2 $t2 # t2 = (j - 1) * 4
	add	$t3, $t3 $t3
	add	$t3, $t3 $t3 # t3 = j * 4
	add	$t2, $t2, $a0 # t2 = base address + (j - 1) * 4
	add	$t3, $t3, $a0 # t3 = base address + j * 4
	lw	$t4, 0($t2) # t4 = A[j - 1]
	lw	$t5, 0($t3) # t5 = A[j]
	ble	$t4, $t5, end_for_loop # if A[j - 1] <= A[j], then break
swap:
	sw	$t4, 0($t3) # A[j] = $t4
	sw	$t5, 0($t2) # A[j - 1] = $t5
	addi	$t1, $t1, -1 # j = j - 1
	j	while
end_for_loop:
	addi	$t0, $t0, 1 # i = i + 1
	j	for_loop
insertion_sort_end:
	# Caller RTE restore 
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 20
	# Return to Caller
	jr	$ra
