.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 120.
# =================================================================
argmax:
	addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw ra, 8(sp)

    # Prologue
    addi s0, a0, 0
    addi s1, a1, 0 


loop_start:
	bge x0, s1, exception
    
    addi t2, x0, 1 
    slli t2, t2, 2 # size of element
    
    addi t0, x0, 0 # the index of greatest element
    addi t1, x0, 0 # current index of element
    lw t3, 0(s0) # load the largest element
    lw t4, 4(s0) # load the current element
	
loop_continue:
	beq t1, s1, loop_end
	mul t6, t2, t1
    add t5, s0, t6
    lw t4 0(t5) # load the current item
	blt t3 t4 changeindex
L1:
    addi t1, t1, 1
    j loop_continue
    
    
changeindex:
	addi t0 t1 0
   	mul t6, t2, t0
    add t5, s0, t6
    lw t3, 0(t5)
	j L1
    
loop_end:
    addi a0, t0, 0
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    ret
    # Epilogue

exception:
	addi a1, x0, 120
	j exit2	