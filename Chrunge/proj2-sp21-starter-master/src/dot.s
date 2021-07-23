.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 123.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 124.
# =======================================================
dot:

    # Prologue
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw ra, 24(sp)
    
    addi s0, a0, 0
    addi s1, a1, 0
    addi s2, a2, 0 #the length of the vectors
    addi s3, a3, 0
    slli s3, s3, 2
    addi s4, a4, 0
    slli s4, s4, 2
    addi s5, x0, 0 # result
    
    bge x0, s2, exception1
    bge x0, s3, exception2
    bge x0, s4, exception2

	addi t0, x0, 0 # index of element, considering stride

loop_start:
	beq t0, s2, loop_end
    
	mul t3, t0, s3
    add t3, s0, t3
    lw t3, 0(t3) #get v0 element
    
    mul t4, t0, s4
    add t4, s1, t4
    lw t4, 0(t4) # get v1 element
    
    mul t5, t3, t4
    add s5, s5, t5 # add the result of multiply to result
    
    addi t0, t0, 1
    j loop_start


loop_end:
	addi a0, s5, 0
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28
    
    ret
    
exception1:
    addi a1, x0, 123
    j exit2
    
exception2:
    addi a1, x0, 124
	j exit2	
