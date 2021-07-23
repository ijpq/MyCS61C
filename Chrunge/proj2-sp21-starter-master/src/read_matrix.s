.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 116.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 117.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 118.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 119.
# ==============================================================================
read_matrix:

    # Prologue
	addi sp, sp, -40 # start
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw ra, 36(sp)	
    mv s0, a0 # a pointer to filename
    mv s7, a1
    mv s8, a2
    
  
  
   # fopen
    mv a1, s0
    li a2, 0
    jal ra, fopen # something wrong here, I don't know why.
    mv s1, a0 # s1 is a file descriptor 
    li t0, -1
    beq s1, t0, fopenException
   
   
     # malloc for rows and cols
    li t0, 2
    slli a0, t0, 2 
    jal ra, malloc
    mv s2, a0 # a pointer to allocated memory for 8 bytes for rows and cols
    beq x0, s2 mallocException
    
    # fread to rows and cols
    ebreak
   mv a1, s1
   mv a2, s2
   li t3, 8
   mv a3, t3
   jal ra, fread
   li t3, 8
   bne t3, a0, freadException
    
     # malloc for matirx
    lw s3, 0(s2) # rows 
    lw s4, 4(s2) # cols
    mul s5, s3, s4
    slli a0, s5, 2
    jal ra, malloc
    mv s6, a0 # a pointer for storing matrix
    beq x0, s6 mallocException
    
     # fread matrix
    mv a1, s1
    mv a2, s6
   	slli t5, s5, 2
    mv a3, t5
    jal ra, fread
    slli t5, s5, 2
    bne t5, a0, freadException

    
     # fclose
    mv a0, s1
    jal ra, fclose
    mv t0, a0
    li t1, -1
    beq t0, t1, fcloseException 
    
    mv a0, s2
    jal ra, free

	
    # Epilogue
    mv a0, s6
    mv a1, s7
    mv a2, s8
    sw s3, 0(a1)
    sw s4, 0(a2)
    

    
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw ra, 36(sp)
	addi sp, sp, 40
     # final
    ret
    
mallocException:
	li a1, 116
    j exit2

 fopenException:
 	li a1, 117
    j exit2
    
freadException:
	li a1, 118
    j exit2
    
fcloseException:
	li a1, 119
    j exit2