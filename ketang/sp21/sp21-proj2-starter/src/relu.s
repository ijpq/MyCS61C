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
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # error check
    li t0, 1
    blt a1, t0, error # if length less than 1 jmp to end

    # Prologue
    addi sp, sp, -20
    sw s0, 0(sp) # ptr to elem
    sw s1, 4(sp) # num of arr
    sw s2, 8(sp) # i
    sw a0, 12(sp) # ptr to arr
    sw ra, 16(sp)

    # init
    mv s0, a0
    mv s1, a1
    li s2, 0
    j loop_start
    
loop_start:
    beq s2, s1, loop_end # limit check
    addi sp, sp, -4
    sw s0, 0(sp) # write address to stack
    jal ra, relu_this
    addi sp, sp, 4
    
    addi s0, s0, 4 # incr pointer
    addi s2, s2, 1 # incr i
    j loop_start

relu_this:
    lw t6, 0(sp) # read value from stack
    lw t5, 0(t6)
    bge t5, x0, return 
    sw x0, 0(t6)
    ret

error:
    li a1, 78
    j exit2
    
loop_end:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw a0, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    ret
    
return:
	ret
