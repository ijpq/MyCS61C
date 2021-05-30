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






	# =====================================
    # LOAD MATRICES
    # =====================================
    li t0, 5
    bne t0, a0, argsException
    
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
    
    
	mv s0, a0
    mv s1, a1 
    mv s2, a2
	



    # Load pretrained m0
	
    addi a0, x0, 8
    jal malloc
    beq x0, a0, mallocException
    
    add a1, a0, x0
    addi a2, a0, 4
    lw a0, 0(s1)
    jal read_matrix
    mv s3, a0
    lw s4, 0(a1) # m0 rows
    lw s5, 0(a2) # m0 cols
    
    add a0, a1, x0
    jal free


    # Load pretrained m1
	
    addi a0, x0, 8
    jal malloc
    beq x0, a0, mallocException
    
    add a1, a0, x0
    addi a2, a0, 4
    lw a0, 4(s1)
    jal read_matrix
    mv s6, a0
	lw s7, 0(a1) # m1 rows
	
    add a0, a1, x0
    jal free





    # Load input matrix
	
    addi a0, x0, 8
    jal malloc
    beq x0, a0, mallocException
    
    add a1, a0, x0
    addi a2, a0, 4
	lw a0, 8(s1)
    jal read_matrix
    mv s9, a0
    lw s8, 0(a2) # input cols

	add a0, a1, x0
    jal free



    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
	
    # Linear Layer
	
    
	mul t0, s4, s8
    slli a0, t0, 2
    jal malloc
    beq x0, a0, mallocException
    mv s10, a0 # pointer of hidder_layer
    
    mv a0, s3
    mv a1, s4
    mv a2, s5
    mv a3, s9
    mv a4, s5
    mv a5, s8
    mv a6, s10
    jal matmul
    
    # Nonlinear layer
	
    
    mv a0, s10
    mul t0, s4, s8
    mv a1, t0
    jal relu
    
    # Linear layer
	
    
    mul t0, s7, s8
    slli a0, t0, 2
    jal malloc
    beq x0, a0, mallocException
    mv s11, a0 # pointer of final matrix
    
    mv a0, s6
    mv a1, s7
    mv a2, s4
    mv a3, s10
    mv a4, s5
    mv a5, s8
    mv a6, s11
    jal matmul
    

    


    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
	lw a0, 12(s1)
	mv a1, s11
    mv a2, s7
    mv s3, s8
    jal write_matrix



    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
	mv a0, s11
    mul t0, s7, s8
    mv a1, t0
    jal argmax

	
    

    # Print classification
    bne x0, s2, printNothing
    mv a1, a0
    jal print_int
    



    # Print newline afterwards for clarity
	li a1, '\n'
	jal print_char

printNothing:
	# epilogue
    mv a0, s3
    jal free
    mv a0, s6
    jal free
    mv a0, s9
    jal free
    mv a0, s10
    jal free
    mv a0, s11
    jal free
    
    
	sw s0, 0(sp)
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
    
argsException:
	li a0, 121
    j exit2
    
mallocException:
	li a0, 116
    j exit2


