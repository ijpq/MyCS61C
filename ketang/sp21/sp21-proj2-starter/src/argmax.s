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
    mv t0, a0
    mv t1, a1
    li t6, 1
    blt t1, t6, exce_120
    li t2, 0
    li t3, 0 # current element
    li t4, 0 # max element
    li t5, 0 # max element index
loop_start:
    beq t2, t1, loop_end
    lw t3, 0(t0)
    blt t4, t3, markmax
    j loop_continue
markmax:
    mv t4, t3
    mv t5, t2

loop_continue:
    addi t2, t2, 1
    addi t0, t0, 4
    j loop_start


loop_end:
    # Epilogue
    mv a0, t5
    ret

exce_120:
    li a1, 120
    li a0, 17
    ecall
    ret
