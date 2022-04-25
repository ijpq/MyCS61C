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
    addi sp, sp, -36
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp) # store fp
    sw s4, 16(sp) # store fread retval
    sw s5, 20(sp) # points to matrix
    sw ra, 24(sp) # store return addr of read_matrix()
    sw a1, 28(sp) # save ptr of a1
    sw a2, 32(sp) # save ptr of a2
    
    # init s registers
    add s0, a0, x0 # save argument filepath
    add s1, x0, x0 # save argument rows
    add s2, x0, x0 # save argument cols
    add s3, x0, x0
    add s4, x0, x0
    add s5, x0, x0

    # call fopen
    add a1, x0, s0
    addi a2, x0, 0
    add s3, x0, x0
    jal x1, fopen
    add s3, a0, x0 # get return val
    
    add t0, x0, s3
    addi t0, t0, 1
    beq t0, x0, error_117
    add t0, x0, x0 # reset

    addi s4, x0, 1 # fread retval

    # get rows and cols
    # malloc
    addi a0, x0, 4
    jal x1, malloc
    add x28, a0, x0 # x28 : points to height
    beq x28, x0, error_116

    # fread
    add a1, x0, s3
    add a2, x0, x28
    addi a3, x0, 4
    addi sp, sp, -8
    sw a3, 0(sp)
    sw x28, 4(sp)
    jal x1, fread
    lw a3, 0(sp)
    lw x28, 4(sp)
    addi sp, sp, 8
    bne a0, a3, error_118 
    lw s1, 0(x28)
    
    # malloc 
    addi a0, x0, 4
    jal x1, malloc
    add x29, a0, x0 # x29 : points to width
    beq x29, x0, error_116

    # fread
    add a1, x0, s3
    add a2, x0, x29
    addi a3, x0, 4
    addi sp, sp, -8
    sw a3, 0(sp)
    sw x29, 4(sp)
    jal x1, fread
    lw a3, 0(sp)
    lw x29, 4(sp)
    addi sp, sp, 8
    bne a0, a3, error_118
    lw s2, 0(x29)
    
    # call malloc for buffer
    mul x30, s1, s2 # num of int
    addi x30, x30, 1
    slli x30, x30, 2 # num of bytes
    add a0, x0, x30
    jal x1, malloc
    add s5, a0, x0 # x31 points to the buffer
    beq s5, x0, error_116
    
    # save matrix starter addr
    addi sp, sp, -4
    sw s5, 0(sp)
	
read_loop:
    # fread paras
    add a1, x0, s3
    add a2, x0, s5
    addi a3, x0, 4
    addi sp, sp, -4
    sw a3, 0(sp)
    jal x1, fread
    lw t0, 0(sp)
    addi sp, sp, 4
    # read to eof results in a0 get -1
    addi sp, sp, -4
    sw a0, 0(sp)
    addi a0, a0, 1
    beq a0, x0, set_sp
    lw a0, 0(sp)
    addi sp, sp, 4
    bne a0, t0, fread_error

    addi s5, s5, 4 # move to next index in arr
    j read_loop
set_sp:
    addi sp, sp, 4
    j read_loop_end

read_loop_end:
    add a1, s3, x0
    jal x1, fclose
    addi a0, a0, 1
    beq a0, x0, error_119
    addi a0, a0, -1

    lw s5, 0(sp)
    addi sp, sp, 4
    add a0, x0, s5

    # have to set a1 a2 here. consider it why
    lw a1, 28(sp)
    lw a2, 32(sp)

    j exit

error_116:
    addi a1, x0, 116
    j exit

error_117:
    addi a1, x0, 117
    j exit

fread_error:
    add a1, x0, s3
    jal x1, ferror
    bne a0, x0, read_loop_end # eof reached, back to end procedure
    j error_118

error_118:
    addi a1, x0, 118
    j exit

error_119:
    addi a1, x0, 119
    j exit
    # Epilogue

epilogue:
    # final return label
    lw t0, 28(sp)
    lw a1, 28(sp)
    lw a2, 32(sp)
    sw s1, 0(a1)
    sw s2, 0(a2)
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 36
    bne a1, t0, error_exit # if a1 have set and not equal to ptr 

ret_label:
    ret

error_exit:
    j exit2
