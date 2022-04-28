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
    addi sp, sp, -44
    sw s0, 0(sp) # save argument filepath
    sw s1, 4(sp) # save argument rows
    sw s2, 8(sp) # save argument cols
    sw s3, 12(sp) # store fp
    sw s4, 16(sp) # store fread retval
    sw s5, 20(sp) # points to matrix
    sw s6, 24(sp) # 4B pointer
    sw s7, 28(sp) # INT count for matrix
    sw ra, 32(sp) # store return addr of read_matrix()
    # store two pointer address
    sw a1, 36(sp) 
    sw a2, 40(sp)
    
    # init registers
    add s0, a0, x0
    add s1, x0, x0 
    add s2, x0, x0 
    add s3, x0, x0
    add s4, x0, x0
    add s5, x0, x0
    add s6, x0, x0
    add s7, x0, x0

    # call fopen
    add a1, x0, s0
    li a2, 0
    jal x1, fopen
    add s3, a0, x0 # save fp
    
    # check fopen
    li t0, -1
    beq s3, t0, fopen_error

    # malloc for read row and col
    li a0, 4
    jal x1, malloc
    beq a0, x0, malloc_error
    add s6, x0, a0 # store buffer pointer
    
    # get rows
    # fread
    # setting args
    add a1, x0, s3 # fp
    add a2, x0, s6 # buffer pointer
    li a3, 4 # bytes to be read

    jal x1, fread
    li t0, 4
    bne a0, t0, fread_error

    lw s1, 0(s6) # deref pointer to get rows
    
    # get cols
    # fread
    # setting args
    add a1, x0, s3
    add a2, x0, s6
    addi a3, x0, 4

    jal x1, fread
    li t0, 4
    bne a0, t0, fread_error

    lw s2, 0(s6) # deref pointer to get cols

    # free, merge other free blocks around it if any exists.
    mv a0, s6
    jal x1, free
    
    # call malloc for buffer
    mul t5, s1, s2 # num of int
    add s7, x0, t5
    slli t5, t5, 2 # num of bytes
    add a0, x0, t5
    jal x1, malloc
    add s5, a0, x0 # a0 points to the buffer
    beq s5, x0, malloc_error
	
    li t0, 0 # cnt
    add a2, x0, s5 # pointer to buffer
read_loop:
    # fread paras
    addi sp, sp, -8
    sw t0, 0(sp)
    sw a2, 4(sp)
    
    add a1, x0, s3 # fp
    li a3, 4 # bytes to be read
    
    jal x1, fread
    li t0, 4
    bne a0, t0, fread_error_inloop

    lw a2, 4(sp)
    lw t0, 0(sp)
    addi sp, sp, 8

    # update cnt
    addi a2, a2, 4 # move to next index in arr
    addi t0, t0, 1 
    blt t0, s7, read_loop
    j fclose_label

fread_error_inloop:
    addi sp, sp, 8
    j fread_error
    
fclose_label:
    # fclose 
    add a1, s3, x0
    jal x1, fclose
    li t0, -1
    beq a0, t0, fclose_error

    # # DEBUG: print array
    # mv a0, s5
    # mv a1, s1
    # mv a2, s2
    # jal x1, print_int_array
    
    # normal epilogue proceedure
    mv a0, s5 # setting return value
    lw a1, 36(sp)
    lw a2, 40(sp)
    # write to a1,a2
    sw s1, 0(a1)
    sw s2, 0(a2)

    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp) 
    lw s7, 28(sp)
    lw ra, 32(sp)
    addi sp, sp, 44
    ret

fopen_error:
    li a1, 117
    j error_epilogue

malloc_error:
    li a1, 116
    j error_epilogue

fread_error:
    li a1, 118
    j error_epilogue

fclose_error:
    li a1, 119
    j error_epilogue

# pay attention to CALLING CONVENTION
error_epilogue:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp) 
    lw s7, 28(sp)
    lw ra, 32(sp)
    # a1 and a2 should not be restore
    # lw a1, 36(sp)
    # lw a2, 40(sp)
    j error_exit
    
error_exit:
    j exit2
