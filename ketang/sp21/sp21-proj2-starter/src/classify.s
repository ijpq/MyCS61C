.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 121.
    # - If malloc fails, this function terminates the program with exit code 116 (though we will also accept exit code 122).
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
    
    addi sp, sp, -64
    sw s0, 0(sp) # m0path ptr
    sw s1, 4(sp) # m1path ptr
    sw s2, 8(sp) # inputpath ptr
    sw s3, 12(sp) # outputpath ptr
    sw s4, 16(sp) # matmul result mat
    sw s5, 20(sp) # ptr m0
    sw s6, 24(sp) # m0.rows&cols
    sw s7, 28(sp) # ptr m1
    sw s8, 32(sp) # m1.rows&cols
    sw s9, 36(sp) # save argc
    sw s10, 40(sp) # save argv
    sw s11, 44(sp) # next matmul result mat
    sw a0, 48(sp)
    sw a1, 52(sp)
    sw a2, 56(sp)
    sw ra, 60(sp)
    li t3, 0 # input mat ptr
    li t4, 0 # input mat.rows&cols
    li t6, 0 # argmax result
    mv s9, a0
    mv s10, a1

    # load argument from argv
    # iterate argv by adding char** +4
    lw s0, 4(a1)
    lw s1, 8(a1)
    lw s2, 12(a1)
    lw s3, 16(a1)

    ## test print
    #mv a1, a0
    #jal ra, print_int



	# =====================================
    # LOAD MATRICES
    # =====================================

    # load m0 and attri
    # rows&cols malloc
    li a0, 8
    jal ra, malloc
    mv t0, a0
    #TODO chk
    mv s6, a0
    
    mv a0, s0  # char *
    mv a1, s6  # ptr of m0.rows
    addi a2, s6, 4 # ptr of m0.cols
    jal ra, read_matrix
    mv t0, a0
    #TODO chk
    mv s5, a0
    #debug - printm0
    li a1, 13
    jal ra, print_char
    mv a0, s5
    lw a1, 0(s6)
    lw a2, 4(s6)
    jal ra, print_int_array
    li a1, 13
    jal ra, print_char
    

    # load m1 and attri
    li a0, 8
    jal ra, malloc
    mv t0, a0
    #TODO chk
    mv s8, a0 # ptr of m1.rows&cols
    
    mv a0, s1
    mv a1, s8
    addi a2, s8, 4
    jal ra, read_matrix
    mv t0, a0
    #TODO chk
    mv s7, a0

    # load input mat and attri
    li a0, 8
    jal ra, malloc
    mv t0, a0
    #TODO chk
    mv t4, a0
    addi sp, sp, -4 # save t4
    sw t4, 0(sp)

    mv a0, s2
    mv a1, t4
    addi a2, t4, 4
    jal ra, read_matrix
    mv t0, a0
    #TODO chk
    mv t3, a0
    addi sp, sp, -4 # save (t3)inputmat.addr after read_matrix() return
    sw t3, 0(sp)
    #debug - print input mat
    li a1, 13
    jal ra, print_char
    lw a0, 0(sp)
    lw t4, 4(sp)
    lw a1, 0(t4)
    lw a2, 4(t4)
    jal ra, print_int_array
    li a1, 13
    jal ra, print_char
    

    # load m1 and attri
    li a0, 8
    jal ra, malloc
    mv t0, a0
    #TODO chk
    mv s8, a0 # ptr of m1.rows&cols
    
    mv a0, s1


    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    #1
    # prepare
    mv a0, s5 # m0.addr
    lw a1, 0(s6) # m0.rows
    lw a2, 4(s6) # m0.cols
    lw t4, 4(sp) # inputmat.rows&cols.addr
    lw t3, 0(sp) # load input mat.addr from RAM
    mv a3, t3 # inputmat.addr
    lw a4, 0(t4) # inputmat.rows
    lw a5, 4(t4) # inputmat.cols
    mul t0, a1, a5
    slli t0, t0, 2
    mv a0, t0
    jal ra, malloc
    mv t0, a0
    #TODO chk
    mv s4, a0

    # matmul
    mv a0, s5 # m0.addr
    lw a1, 0(s6)
    lw a2, 4(s6)
    lw t3, 0(sp)
    #addi sp, sp, 4 # get t3
    mv a3, t3
    lw t4, 4(sp)
    lw a4, 0(t4)
    lw a5, 4(t4)
    mv a6, s4
    jal ra, matmul
    #TODO chk


    #2
    lw t1, 0(s6)
    lw t4, 4(sp)
    lw t2, 4(t4)
    mul t0, t1, t2
    addi sp, sp, -8
    sw t1, 0(sp) # store m0.rows
    sw t2, 4(sp) # store input.cols
    
    mv a0, s4 # (m0*input).addr
    mv a1, t0 # (m0*input).size
    jal ra, relu
    #TODO chk
    # debug - print relu(m0*input)
    li a1, 13
    jal ra, print_char
    mv a0, s4
    lw a1, 0(sp)
    lw a2, 4(sp)
    addi sp, sp, 8
    jal ra, print_int_array
    li a1, 13
    jal ra, print_char


    
    # 3
    mv a0, s7
    lw a1, 0(s8)
    lw a2, 4(s8)
    mv a3, s4 # relu(m0*input).addr
    lw t4, 4(sp)
    lw a4, 0(t4)
    lw a5, 4(t4)
    #addi sp, sp, 4
    
    mul t0, a1, a5
    addi sp, sp, -8
    sw a1, 0(sp)
    sw a5, 4(sp)
    #mv t1, a1
    #mv t2, a5
    slli t0, t0, 2
    jal ra, malloc
    mv t0, a0
    #TODO chk
    mv s11, a0

    #debug-
    li a1, 99
    jal ra, print_int
    
    mv a0, s7
    lw a1, 0(s8)
    lw a2, 4(s8)
    mv a3, s4
    lw a4, 0(s6)
    lw t4, 4(sp)
    lw a5, 4(t4)
    mv a6, s11
    jal ra, matmul
    mv t0, a0
    #TODO chk
    mv s4, a0 # save final mat.addr into s4 register, but attribute is supposed to inference.
    #debug-
    li a1, 13
    jal ra, print_char
    li a1, 99
    jal ra, print_int

    # debug - print final mat
    li a1, 13
    jal ra, print_char
    mv a0, s4
    lw a1, 0(s8)
    lw t4, 4(sp)
    lw a2, 4(t4)
    jal ra, print_int_array
    li a1, 13
    jal ra, print_char



    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    
    # load num of rows&cols
    mv a0, s3
    mv a1, s4 # mat ptr
    lw a2, 0(s8)
    lw a3, 4(sp)
    jal ra, write_matrix
    mv t0, a0
    #TODO chk




    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    lw t0, 0(s8) 
    lw t1, 4(sp)
    mul t2, t0, t1
    mv a0, s4
    mv a1, t2
    jal ra, argmax
    mv t6, a0

    ##debug
    #mv a1, a0
    #jal ra, print_int
    ##debug
    #TODO chk
    addi sp, sp, 16 # get print_out setting
    lw t5, 56(sp)
    addi sp, sp, -16
    #beq t5, x0, print_out
    j end




    # Print classification
print_out:
    mv a1, t6
    addi sp, sp, -4
    sw t6, 0(sp)
    jal ra, print_int
    

    # Print newline afterwards for clarity
    li a1, 13
    jal ra, print_char
    lw t6, 0(sp)
    addi sp, sp, 4
    j end


end:
    mv a0, t6 # temp reg would not changed if print_out didn't set.
    addi sp, sp, 16
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw s10, 40(sp)
    lw s11, 44(sp)
    lw a0, 48(sp)
    lw a1, 52(sp)
    lw a2, 56(sp)
    lw ra, 60(sp)
    addi sp, sp, 64



    ret
