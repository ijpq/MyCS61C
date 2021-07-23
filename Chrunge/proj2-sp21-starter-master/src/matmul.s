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
#     this function terminates the program with exit code 125.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 126.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 127.
# =======================================================
matmul:

    # Error checks
	mul t0, a1, a2
    bge x0, t0, exception1
    mul t1, a4, a5
    bge x0, t1, exception2
    bne a2, a4, exception3

    # Prologue
    addi sp, sp, -32
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw ra, 28(sp)
    
    addi s0, a0, 0
    addi s1, a1, 0
    addi s2, a2, 0
    addi s3, a3, 0
    addi s4, a4, 0
    addi s5, a5, 0
    addi s6, a6, 0
    
    mv t2, s6
    addi t0, x0, 0 # row of m0 
   
outer_loop_start:
	beq t0, s1, outer_loop_end
    addi t1, x0, 0 # col of m1
    


inner_loop_start:
	beq t1, s5, inner_loop_end
    
	mv a0, s0
    mv a1, s3
    mv a2, s2
    addi a3, x0, 1 # stride of different cols
    mv a4, s5 # stride of different rows
	
    # prologue
    addi sp, sp, -12
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    jal ra, dot # go to dot
    # epilogue
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    addi sp, sp, 12
    
    sw a0, 0(t2) # store result
    addi t2, t2, 4
    addi t1, t1, 1
    
    # choose the right col: add 4 bytes
    addi s3, s3, 4
    j inner_loop_start
    
inner_loop_end:
	addi t0, t0, 1
    
    li t3, 4
    mul t3, t3, s5
    sub s3, s3, t3
    
    # choose the right row: add 4 * m0 cols bytes
    li t3, 4
    mul t3, t3, s2
    add s0, s0, t3
	j outer_loop_start



outer_loop_end:
	mv a6, s6
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    # Epilogue    
    ret
    
    
exception1:
    addi a1, x0, 123
	j exit2
    
exception2:
    addi a1, x0, 124
	j exit2

exception3:
    addi a1, x0, 125
    j exit2