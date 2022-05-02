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
    
    addi sp, sp, -56
    sw s0, 0(sp) # m0path ptr(char *), and save classification result later
    sw s1, 4(sp) # m1path ptr(char *)
    sw s2, 8(sp) # inputpath ptr(char *)
    sw s3, 12(sp) # outputpath ptr(char *)
    sw s4, 16(sp) # matmul result mat
    sw s5, 20(sp) # ptr m0
    sw s6, 24(sp) # m0.rows&cols
    sw s7, 28(sp) # ptr m1
    sw s8, 32(sp) # m1.rows&cols
    sw s9, 36(sp) # ptr input mat
    sw s10, 40(sp) # input mat rows&cols
    sw s11, 44(sp) # final matmul result mat
    sw ra, 48(sp)
    sw a2, 52(sp) # hard coding

    # init saved register
    li s0, 0
    li s1, 0
    li s2, 0
    li s3, 0
    li s4, 0
    li s5, 0
    li s6, 0
    li s7, 0
    li s8, 0
    li s9, 0
    li s10, 0
    li s11, 0

    ##### args check #####
    li t0, 5
    bne a0, t0, error_121

    # load argument from argv
    # iterate argv by adding char** +4 (4B pointer address)
    lw s0, 4(a1) # M0_PATH
    lw s1, 8(a1) # M1_PATH
    lw s2, 12(a1) # INPUT_PATH
    lw s3, 16(a1) # OUTPUT_PATH
    
	# =====================================
    # LOAD MATRICES
    # =====================================

    ##### load M0 #####
    # malloc for 2*4B mem for read_matrix
    li a0, 8
    jal ra, malloc
    beq a0, x0, malloc_error
    mv s6, a0 # ptr of m0.rows&cols
    
    # m0 read_mat
    mv a0, s0  # filepath (char *)
    mv a1, s6  # ptr of m0.rows
    addi a2, s6, 4 # ptr of m0.cols
    jal ra, read_matrix

    # rows and cols pointer has set within read matrix
    mv s5, a0 # ptr of m0
    
    ##### load M1 #####
    # malloc for 2*4B mem for read_matrix
    li a0, 8
    jal ra, malloc
    beq a0, x0, malloc_error
    mv s8, a0 # ptr of m1.rows&cols
    
    # m1 read_mat
    mv a0, s1
    mv a1, s8
    addi a2, s8, 4
    jal ra, read_matrix

    # rows and cols pointer has set within read matrix
    mv s7, a0 # ptr of m1

    ##### load input #####
    # malloc for 2*4B mem for read_matrix
    li a0, 8
    jal ra, malloc
    beq a0, x0, malloc_error

    mv s10, a0 # ptr of input.rows&cols
    
    # input read_mat
    mv a0, s2
    mv a1, s10
    addi a2, s10, 4
    jal ra, read_matrix

    # rows and cols pointer has set within read matrix
    mv s9, a0 # ptr of input
    
    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # 1. LINEAR_LAYER
    # malloc for m0*input matrix
    lw t1, 0(s6)
    lw t2, 4(s10)
    mul t0, t1, t2
    slli t0, t0, 2
    mv a0, t0
    jal ra, malloc
    li t0, 0
    beq a0, t0, malloc_error
    mv s4, a0

    # matmul
    mv a0, s5 # m0.addr
    lw a1, 0(s6) # m0.rows
    lw a2, 4(s6) # m0.cols
    mv a3, s9 # inputmat.addr
    lw a4, 0(s10) # inputmat.rows
    lw a5, 4(s10) # inputmat.cols
    mv a6, s4
    jal ra, matmul # result write to a6

    # free m0, because m0*input finished.
    mv a0, s5
    jal ra, free
    # free input, because m0*input finished.
    mv a0, s9
    jal ra, free

    # 2. NONLINEAR LAYER
    # execute inplace relu
    mv a0, s4 # (m0*input).addr
    lw t0, 0(s6)
    lw t1, 4(s10)
    mul a1, t0, t1 # (m0*input).size
    jal ra, relu
    
    # 3. LINEAR LAYER
    # prepare final mat allocating
    lw t1, 0(s8) # rows of m1
    lw t2, 4(s10) # cols of input
    mul t0, t1, t2
    slli t0, t0, 2
    mv a0, t0
    jal ra, malloc
    beq a0, x0, malloc_error
    mv s11, a0 # ptr to matrix of (m1.rows, input.cols) dim

    # m1*relu(m0, input)
    mv a0, s7 # m1.ptr
    lw a1, 0(s8) # m1.rows
    lw a2, 4(s8) # m1.cols
    mv a3, s4 # relu(m0, input).ptr
    lw a4, 0(s6) # m0.rows
    lw a5, 4(s10) # input.cols
    mv a6, s11 # final mat ptr
    jal ra, matmul

    # free m1, because m1*relu(...) finished
    mv a0, s7
    jal ra, free
    # free relu(m0*input), because m1*relu(...) finished
    mv a0, s4
    jal ra, free

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    
    mv a0, s3
    mv a1, s11 # mat ptr
    lw a2, 0(s8)
    lw a3, 4(s10)
    # mv a1, sp
    # jal ra, print_hex
    jal ra, write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax

    mv a0, s11
    lw t1, 0(s8)
    lw t2, 4(s10)
    mul t0, t1, t2
    mv a1, t0
    jal ra, argmax
    mv s0, a0

    # free m1*relu(...), because argmax finished.
    mv a0, s11
    jal ra, free

    lw t0, 52(sp) # print_out args, 52 is hard coding
    beq t0, x0, print_out
    j end

print_out:
    # Print classification
    mv a1, s0
    jal ra, print_int
    j end

malloc_error:
    li a1, 116
    j error_end

error_121:
    li a1, 121
    j error_end

error_end:
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
    lw ra, 48(sp)
    lw a2, 52(sp)
    addi sp, sp, 56
    j error

    
end:
    # mv a0, s0
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
    lw ra, 48(sp)
    lw a2, 52(sp)
    addi sp, sp, 56
    ret

error:
    j exit2
