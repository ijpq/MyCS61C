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
    addi sp, sp, -52
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw s0, 16(sp) # num of arr
    sw s1, 20(sp) # iter i
    sw s2, 24(sp) # fp
    sw s3, 28(sp) # filepath
    sw s4, 32(sp) # arr ptr
    sw s5, 36(sp) # load elem
    sw s6, 40(sp) # ptr to rows
    sw s7, 44(sp) # ptr to cols
    sw ra, 48(sp)
    mul s0, a2, a3 # save num
    li s1, 0 # init i
    mv s3, a0
    mv s4, a1

    #fopen
    li s2, 0
    mv a1, s3
    li a2, 1
    jal ra, fopen
    mv s2, a0
    # TODO errorchk

    # malloc for rows and cols
    li a0, 4
    jal ra, malloc
    mv s6, a0
    #TODO errorchk
    lw t0, 8(sp) #rows
    sw t0, 0(s6)
    
    mv a1, s2
    mv a2, s6
    li a3, 1
    li a4, 4
    jal ra, fwrite
    
    li a0, 4
    jal ra, malloc
    mv s7, a0
    #TODO errorchk
    lw t0, 12(sp) #cols
    sw t0, 0(s7)
    
    mv a1, s2
    mv a2, s7
    li a3, 1
    li a4, 4
    jal ra, fwrite


write_loop:
    beq s1, s0, loop_end
    lw s5, 0(s4)
    mv a1, s5
    #jal ra, print_int

    mv a1, s2
    mv a2, s4
    li a3, 1
    li a4, 4
    jal ra, fwrite
    mv t0, a0
    # TODO errorchk
    
    addi s4, s4, 4
    addi s1, s1, 1
    j write_loop

loop_end:
    mv a1, s2
    jal ra, fclose
    mv t0, a0
    # TODO errorchk


    # Epilogue
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw s0, 16(sp)
    lw s1, 20(sp)
    lw s2, 24(sp)
    lw s3, 28(sp)
    lw s4, 32(sp)
    lw s5, 36(sp)
    lw s6, 40(sp)
    lw s7, 44(sp)
    lw ra, 48(sp)
    addi sp, sp, 52


    ret
