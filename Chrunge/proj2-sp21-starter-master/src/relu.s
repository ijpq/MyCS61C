.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 115.
# ==============================================================================
relu:
    # Prologue
    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw ra, 8(sp)
    

    
    
loop_start:
    addi s0, a0, 0 #pointer of array
    addi s1, a1, 0 #number of element
    addi t1, x0, 1 
    slli t1, t1, 2 #sizeof(element)
    addi t0, x0, 1
    addi t3, x0, 0 # index of element
    
    blt s1, t0, Exception

    
loop_continue:
    beq t3, s1, loop_end
    addi t2, s0, 0
    lw s0, 0(s0)
compare:
    blt s0, x0, negate
    sw s0, 0(t2)
    addi s0, t2, 0
    add s0, s0, t1
    addi t3, t3, 1
    j loop_continue
    
negate:
	addi s0, x0, 0
    j compare

    
loop_end:
	lw s0, 0(sp)
    lw s1, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    # Epilogue
	ret
    


Exception:
	addi a1, x0, 115
    addi a0, x0, 17
    ecall
