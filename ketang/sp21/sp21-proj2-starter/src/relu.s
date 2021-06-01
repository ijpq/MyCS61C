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
    # Prologue
    addi x5, x0, 0
    addi x5, x5, 1
    blt a1, x5, loop_end # if length less than 1 jmp to end
    add x28, x0, zero
    add x29, a0, zero
    
loop_start:
    bge x28, a1, loop_end
    lw x30, 0(x29)
    bge x30, x0, loop_continue
    sw x0, 0(x29)
    j loop_continue


loop_continue:
    
    addi x29, x29, 4
    addi x28, x28, 1
    j loop_start

loop_end:

    sub x30, x30, x30
    sub x29, x29, x29
    sub x28, x28, x28 

    # Epilogue

    
	ret
