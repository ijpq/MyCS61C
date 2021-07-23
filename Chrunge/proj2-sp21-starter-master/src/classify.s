.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc: number of arguments
    #   a1 (char**) argv: pointer to list containing arguments
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # ERROR CHECK
    addi t0, x0, 5
    bne a0, t0, error_89
    
    # Prologue
    addi sp, sp, -52
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp) 
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10, 40(sp)
    sw s11, 44(sp)
    sw ra, 48(sp)

    addi s2, a1, 4      # s2 is pointer to list of filenames
    
    add s11, x0, a2      # s11 is to print or not to print 
 


	# =====================================
    # LOAD MATRICES
    # =====================================

    # Load pretrained m0

    addi a0, x0, 8          #make a0 = 8 for malloc
    jal ra, malloc          #malloc 8 bytes for row and col ints
    beq a0, x0, malloc_error 
    add a1, x0, a0          #make a1 point to the allocated space for rows for read_matrix
    addi a2, a1, 4          #make a2 point to the allocated space for cols for read_matrix
    addi s3, a1, 0          #make s3 point to the allocated space for rows & cols for m0
    lw a0, 0(s2)            #make a0 filename pointer to m0 for read_matrix
    jal ra, read_matrix
    addi s4, a0, 0          #s4 is pointer to the matrix m0 in memory

    # Load pretrained m1
    addi a0, x0, 8          #make a0 = 8 for malloc
    jal ra, malloc          #malloc 8 bytes for row and col ints
    beq a0, x0, malloc_error 
    add a1, x0, a0          #make a1 point to the allocated space for rows for read_matrix
    addi a2, a1, 4          #make a2 point to the allocated space for cols for read_matrix
    addi s5, a1, 0          #make s5 point to the allocated space for rows & cols for m1
    lw a0, 4(s2)            #make a0 filename pointer to m1 for read_matrix
    jal ra, read_matrix
    addi s6, a0, 0          #s6 is pointer to the matrix m1 in memory

    # Load input matrix
    
    addi a0, x0, 8          #make a0 = 8 for malloc
    jal ra, malloc          #malloc 8 bytes for row and col ints
    beq a0, x0, malloc_error 
    add a1, x0, a0          #make a1 point to the allocated space for rows for read_matrix
    addi a2, a1, 4          #make a2 point to the allocated space for cols for read_matrix
    addi s7, a1, 0          #make s7 point to the allocated space for rows & cols for input matrix
    lw a0, 8(s2)            #make a0 filename pointer to input matrix for read_matrix
    jal ra, read_matrix
    addi s8, a0, 0          #s8 is pointer to input matrix in memory
   
    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # LINEAR LAYER -- MATMUL m0 * input
    lw t0, 0(s3)            # t0 = rows of m0
    lw t1, 4(s7)            # t1 = cols of input
    mul a0, t0, t1          # a0 = rows of m0 x cols of input
    addi s10, a0, 0         # save no. of elements in d
    li t2 4 
    mul a0, a0, t2          # a0 is number of bytes of layer 1 matrix 
    jal ra, malloc          # malloc no. of elements in d for row and col ints
    beq a0, x0, malloc_error 
    
    addi a6, a0, 0          # a6 is pointer to start of layer 1 matrix
    addi a0, s4, 0          # a0 = pointer to start of m0
    lw a1, 0(s3)            # a1 = number of m0 rows
    lw a2, 4(s3)            # a2 = number of m0 cols

    addi a3, s8, 0          # a3 = pointer to start of input
    lw a4, 0(s7)            # a4 = number of input rows
    lw a5, 4(s7)            # a5 = number of input cols

    addi s9, a6, 0          # s9 points to layer 1 matrix
    jal ra, matmul
    
    #NONLINEAR LAYER: Relu(layer 1 matrix) 
    addi a0, s9, 0          # a0 is pointer to layer 1 matrix, soon to be layer 2 matrix
    addi a1, s10, 0         # a1 is # elements in layer 1 matrix, soon to be layer 2 matrix

    jal ra, relu 

    #LINEAR LAYER: m1 x d

    lw t0, 0(s5)            #t0 = rows of m1
    lw t1, 4(s7)            #t1 = cols of layer 2 matrix, which we get by finding cols of input

    mul a0, t0, t1          #a0 = rows of m1 * cols of layer 2 matrix
    li t2 4 
    mul a0, a0, t2          #a0 is number of bytes of layer 3 matrix 
    jal ra, malloc          #malloc no. of elements in layer 3 matrix for row and col ints
    beq a0, x0, malloc_error 
    addi a6, a0, 0          # a6 is pointer to start of layer 3 matrix


    addi a0, s6, 0          # a0 = pointer to start of m1
    lw a1, 0(s5)            # a1 = number of m1 rows
    lw a2, 4(s5)            # a2 = number of m1 cols

    addi a3, s9, 0          # a3 = pointer to start of layer 2
    lw a4, 0(s3)            # a4 = number of layer 2 rows = d rows = m0 rows 
    lw a5, 4(s7)            # a5 = number of layer 2 cols = d cols = input cols 

    addi s0, a6, 0          # s0 points to layer 3 matrix
    jal ra, matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix

    lw a0, 12(s2)           #a0 is the pointer to string representing the filename 
    addi a1, s0, 0          #a1 is the pointer to the start of layer 3 matrix
    lw a2, 0(s5)            #a2 is num rows in layer 3 matrix = rows of m1
    lw a3, 4(s7)            #a3 is num cols in layer 3 matrix

    jal ra, write_matrix 

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    
    
    lw t0, 0(s5)        # t0 = # rows
    lw t1, 4(s7)        # t1 = # cols 
    mul a1, t0, t1      # a1 = # elements
    addi a0, s0, 0      # a0 is pointer to start of matrix
    jal ra, argmax

    addi s1, a0, 0      #s1 is our classification

    # Print classification

    bne s11, x0, after_print
    addi a1, s1, 0 
    jal ra, print_int

after_print:

    # Print newline afterwards for clarity
    li a1 '\n'
    jal ra, print_char

    # Free all mallocs
    addi a0, s3, 0
    jal ra, free
    
    addi a0, s5, 0
    jal ra, free
    
    addi a0, s7, 0
    jal ra, free

    addi a0, s9, 0
    jal ra, free
    
    addi a0, s0, 0
    jal ra, free

    #EPILOGUE
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
    addi sp, sp, 52
    
    ret

error_89:
    addi a1, x0, 89
    jal exit2

malloc_error:
    addi a1, x0, 88
    jal exit2