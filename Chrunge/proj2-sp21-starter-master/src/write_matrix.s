.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 112.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 113.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 114.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1 , 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw ra, 24(sp)

	mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    
    
    # fopen
    mv a1, s0
    li a2, 1
    jal ra, fopen
    mv s4, a0 # file descriptor
    li t0, -1
    beq t0, s4, fopenException
    
    # fwrite rows and cols
    li a0, 8
    jal malloc
    mv s5, a0
    sw s2, 0(s5)
    sw s3, 4(s5)
    
    mv a1, s4
    mv a2, a0
    li a3, 2
	li a4, 4
    jal fwrite
    bne a0, a3, fwriteException
    
    
    
    # fwrite matrix
    mv a1, s4
    mv a2, s1 # buffer to read from
    
    mul t0, s2, s3
    mv a3, t0 # number of element
    
    li t1, 1
    slli t1, t1, 2
    mv a4, t1 # size equal to 4 bytes
    
    jal ra, fwrite
    mv t2, a0
    bne t2, a3, fwriteException
    
	# fclose
    mv a1, s4
    jal ra, fclose
    bne x0, a0, fcloseException
    
    # free
    mv a0, s5
    jal free

    # Epilogue
    lw s0, 0(sp)
    lw s1 , 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28
    ret
    
    
fopenException:
 	li a1, 112
    j exit2

fwriteException:
	li a1, 113
    j exit2
    
fcloseException:
	li a1, 114
    j exit2