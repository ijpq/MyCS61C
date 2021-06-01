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
    addi x1, x0, zero
    addi x1, x1, 1
    blt a1, x1, loop_end # if length less than 1 jmp to end

    add x18, x0, zero
    
loop_start:
    bge x18, a1, loop_end
    lw x20, (a0)
    bge x20, zero, loop_continue
    sub x20, zero, x20
    j loop_continue


loop_continue:
    addi a0, a0, 4
    addi x18, x18, 1
    

loop_end:


    # Epilogue

    
	ret
