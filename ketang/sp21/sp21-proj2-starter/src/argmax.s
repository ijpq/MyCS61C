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

    # Prologue
    # x28 is iteration i
    # x29 is var t
    # x30 is var r
    # x31 ptr
    add x31, a0, x0
    add x28, x0, x0
    add x29, x0, x0
    add x30, x0, x0
    add x5, x0, x0
    
loop_start:
    lw x29, 0(a0)
    add x30, x28, x0


loop_continue:
    addi x31, x31, 4
    addi x28, x28, 1
    bge x28, a1, loop_end
    lw x5, 0(x31)
    bge x5, x29, loop_start
    j loop_continue


loop_end:
    add a0, x30, x0
    

    # Epilogue


    ret
