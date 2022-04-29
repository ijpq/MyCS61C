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
    addi sp, sp, -40
    sw s0, 0(sp) # num of arr
    sw s1, 4(sp) # iter i
    sw s2, 8(sp) # fp
    sw s3, 12(sp) # filepath
    sw s4, 16(sp) # arr ptr
    sw s5, 20(sp) # load elem
    sw s6, 24(sp) # ptr to 4B
    sw s7, 28(sp) # save rows
    sw s8, 32(sp) # save cols
    sw ra, 36(sp)

    # save filepath, matrix pointer, num of items, rows, cols
    mul s0, a2, a3 # save num
    li s1, 0
    mv s3, a0
    mv s4, a1
    mv s7, a2
    mv s8, a3

    # init
    li s2, 0
    li s5, 0
    li s6, 0

    #fopen
    mv a1, a0
    li a2, 1
    jal ra, fopen
    li t0, -1
    beq a0, t0, error_112
    mv s2, a0

    # write rows to heap
    li t0, 4
    jal ra, sbrk
    sw s7, 0(a0) # write rows to heap
    mv s6, a0 # ptr to 4B

    # fwirte
    mv a1, s2
    mv a2, s6
    li a3, 1 # num of items
    li a4, 4 # size of each item
    jal ra, fwrite
    li t0, 1
    bne a0, t0, error_113
    
    sw s8, 0(s6) # write cols to heap
    mv a1, s2
    mv a2, s6
    li a3, 1
    li a4, 4
    jal ra, fwrite
    li t0, 1
    # TODO: free while fwrite error
    bne a0, t0, error_113
    mv a0, s6
    jal ra, free
    j write_loop


write_loop:
    beq s1, s0, loop_end
    lw s5, 0(s4)
    # DEBUG
    # mv a1, s5
    # jal ra, print_int

    mv a1, s2
    mv a2, s4
    li a3, 1
    li a4, 4
    jal ra, fwrite
    li t0, 1
    bne a0, t0, error_113
    
    addi s4, s4, 4
    addi s1, s1, 1
    j write_loop

error_112:
    li a1, 112
    j epilogue

error_113:
    mv a1, s2
    jal ra, fflush
    li a1, 113
    j epilogue

error_114:
    li a1, 114
    j epilogue

loop_end:
    mv a1, s2
    jal ra, fclose
    mv t0, a0
    li t0, -1
    beq a0, t0, error_114 

    # Epilogue
    lw s0, 0(sp) # num of arr
    lw s1, 4(sp) # iter i
    lw s2, 8(sp) # fp
    lw s3, 12(sp) # filepath
    lw s4, 16(sp) # arr ptr
    lw s5, 20(sp) # load elem
    lw s6, 24(sp) # ptr to 4B
    lw s7, 28(sp) # save rows
    lw s8, 32(sp) # save cols
    lw ra, 36(sp)
    addi sp, sp, 40
    ret

epilogue:
    lw s0, 0(sp) # num of arr
    lw s1, 4(sp) # iter i
    lw s2, 8(sp) # fp
    lw s3, 12(sp) # filepath
    lw s4, 16(sp) # arr ptr
    lw s5, 20(sp) # load elem
    lw s6, 24(sp) # ptr to 4B
    lw s7, 28(sp) # save rows
    lw s8, 32(sp) # save cols
    lw ra, 36(sp)
    addi sp, sp, 40
    j exit2
