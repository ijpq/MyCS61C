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
	addi sp, sp, -24 # start
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw ra, 20(sp)	
    mv s0, a0 # a pointer to filename
	mv s1, a1
    mv s2, a2
    mul s1, s1, s2 # number of bytes
  
  
    # fopen 
    mv a1, s0
    li a2, 0
    jal fopen
   mv s4, a0 # a pointer to a string represent filename
   li t0, -1
   beq s4, t0, fopenException
   
   
     # malloc
    mv a0, s1
    jal ra, malloc
    mv s3, a0 # a pointer to allocated memory for bytes
    beq x0, s3 mallocException
    

    
    # fread
    mv a1, s4
    mv a2, s3
    mv a3, s1
    jal ra, fread
    mv t0, a0
    bne s1, t0, freadException
    
    # fclose
    mv a0, s1
    jal ra, fclose
    mv t0, a0
    li t1, -1
    beq t0, t1, fcloseException 

	
    # Epilogue
    mv a0, s4
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)	
	addi sp, sp, 24
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