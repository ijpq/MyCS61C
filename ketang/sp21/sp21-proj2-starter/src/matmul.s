.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with Exit code 125.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with Exit code 126.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with Exit code 127.
# =======================================================
matmul:

    # Error checks
    bne a2, a4, Exit
    addi x5, x0, 1
    blt a1, x5, Exit
    blt a2, x5, Exit
    blt a4, x5, Exit
    blt a5, x5, Exit

    # Prologue
    addi sp, sp, -40
    sw s5, 32(sp)
    sw s4, 24(sp) # get addr in dest
    sw s3, 16(sp) # temp 
    sw s1, 8(sp) # get addr in m0
    sw s2, 0(sp) # get addr in m1

    add x31, x0, x0 #global sum
    add x30, x0, x0 #local sum
    add x28, x0, x0 #element from m0
    add x29, x0, x0 #element from m1
    
    add x5, x0, x0 #iteration i for m0
    add x6, x0, x0 #iteration j for m1
    add x7, x0, x0 #iteration k for inner_inner_loop

outer_loop_start:
    beq x5, a1, outer_loop_end
    add x6, x0, x0 #init

inner_loop_start:
    beq x6, a5, inner_loop_end
    add x31, x0, x0
    add x7, x0, x0

inner_inner_loop_start:
    beq x7, a4, inner_inner_loop_end
    
    # reset index
    add s1, x0, x0
    add s2, x0, x0
    
    # calculate index in m0
    add s1, x0, x7
    slli s3, x5, 1
    add s1, s1, s3
    slli s1, s1, 2
    add s1, a0, s1

    # calculate index in m1
    add s2, x0, x6
    mul s3, x7, a5
    add s2, s2, s3
    slli s2, s2, 2
    add s2, a3, s2
    
    lw x28, 0(s1)
    lw x29, 0(s2)
    mul x30, x28, x29
    add x31, x31, x30

    addi x7, x7, 1 # increase k
    j inner_inner_loop_start

inner_inner_loop_end:
    #add x7, x0, x0
    add s4, x0, x0
    
    #calculate index
    mul s3, x5, a5
    add s4, s3, x6
    slli s4, s4, 2
    add s4, a6, s4

    sw x31, 0(s4)
    addi x6, x6, 1
    j inner_loop_start

inner_loop_end:
    addi x5, x5, 1 # increment i
    j outer_loop_start

outer_loop_end:

    # Epilogue
    lw s2, 0(sp)
    lw s1, 8(sp)
    lw s3, 16(sp)
    lw s4, 24(sp)
    lw s5, 32(sp)
    addi sp, sp 40
    
Exit:
    
    ret